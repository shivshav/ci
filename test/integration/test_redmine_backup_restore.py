import subprocess, os, re
from selenium import webdriver


def log_into_ci():
    global DRIVER
    DRIVER = webdriver.Firefox() # initilize selenium
    DRIVER.get("http://admin:passwd@localhost/redmine")

def log_into_redmine():
    DRIVER.get("http://localhost/redmine/login")
    element = DRIVER.find_element_by_id("username")
    element.send_keys("admin")
    element = DRIVER.find_element_by_id("password")
    element.send_keys("admin")
    DRIVER.find_element_by_name("login").click()

def create_project():
    DRIVER.get("http://localhost/redmine/projects")
    DRIVER.get("http://localhost/redmine/projects/new")
    DRIVER.find_element_by_id("project_name").send_keys("Test Project")
    DRIVER.find_element_by_name("commit").click()


def create_issue():
    DRIVER.get("http://localhost/redmine/projects/test-project/issues/new")
    DRIVER.find_element_by_id("issue_subject").send_keys("Test Issue of Type Bug")
    DRIVER.find_element_by_name("commit").click()
    DRIVER.close()


def setup_function(function):
    current_dir = os.getcwd() # get current directory
    test_dir = os.path.abspath(os.path.join(current_dir, os.pardir)) # get parent's  absolute path
    global PROJECT_DIR
    PROJECT_DIR = os.path.abspath(os.path.join(test_dir, os.pardir)) # get parent's parent absolute path
    recreate_path = os.path.join(PROJECT_DIR, 'recreate.sh') # restart ci environment
    subprocess.call([recreate_path]) # call run script (how do I do verbose)?
    # Popen([recreate_path]).wait()

    log_into_ci()
    log_into_redmine()
    create_project()
    create_issue()


def teardown_function(function):
    #TODO: Understand pytest scope, setup, and tear down along with execution sequence
    DRIVER.close()

def test_redmine_backup_and_restore():
    # Run backup script
    backup_path = os.path.join(PROJECT_DIR, 'img-scripts/redmine-docker/backupRedmine.sh')
    subprocess.call([backup_path])

    backup_dir = os.path.join(os.getcwd(), 'backups/')
    for file in os.listdir(backup_dir):
            assert file.endswith(".sql")

    # build blank environment
    recreate_path = os.path.join(PROJECT_DIR, 'recreate.sh')
    subprocess.call([recreate_path])

    # Restore environment
    restore_path = os.path.join(PROJECT_DIR, 'img-scripts/redmine-docker/restoreRedmineBackup.sh')
    subprocess.call([restore_path])

    # Restart environment after restore
    restart_path = os.path.join(PROJECT_DIR, 'restart.sh')
    subprocess.call([restart_path])

    # Log back in
    log_into_ci()
    log_into_redmine()

    # Check if project exists
    DRIVER.get("http://localhost/redmine/projects/test-project")
    element = DRIVER.find_element_by_id("header")
    text = re.search(r'Test Project', element.text)
    assert text.re.pattern == 'Test Project'

    # Check if issue exists
    DRIVER.get("http://localhost/redmine/projects/test-project/issues")
    element = DRIVER.find_element_by_class_name("subject")
    text = re.search(r'Test Issue of Type Bug', element.text)
    assert text.re.pattern == 'Test Issue of Type Bug'

    # Close webpage
    DRIVER.close()