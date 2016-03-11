import subprocess, os, re, shutil
from selenium import webdriver
from pyvirtualdisplay import Display

def wrong_dir_error():
    print "ERROR\tTest ran from wrong directory!"
    print "\tRun test from top level directory, outside of test folder"
    exit(1)

def check_path_test_dir(current_dir):
    for x in ["test","integration"]:
        if x in current_dir:
            wrong_dir_error()

def configure_headless_browser():
    global DRIVER, DISPLAY
    DISPLAY = Display(visible=1)
    DISPLAY.start()
    DRIVER = webdriver.Firefox() # initilize selenium

def log_into_ci():
    DRIVER.get("http://admin:password@localhost/redmine")

#def log_into_redmine():
#    DRIVER.get("http://localhost/redmine/login")
#    element = DRIVER.find_element_by_id("username")
#    element.send_keys("admin")
#    element = DRIVER.find_element_by_id("password")
#    element.send_keys("admin")
#    DRIVER.find_element_by_name("login").click()

def create_redmine_project():
    DRIVER.get("http://localhost/redmine/projects")
    DRIVER.get("http://localhost/redmine/projects/new")
    DRIVER.find_element_by_id("project_name").send_keys("Test Project")
    DRIVER.find_element_by_name("commit").click()

def create_redmine_issue():
    DRIVER.get("http://localhost/redmine/projects/test-project/issues/new")
    DRIVER.find_element_by_id("issue_subject").send_keys("Test Issue of Type Bug")
    DRIVER.find_element_by_name("commit").click()

def setup_function(function):
    current_dir = os.getcwd() # get current directory
    check_path_test_dir(current_dir) # ensure we aren't in the test directory
    test_dir = os.path.abspath(os.path.join(current_dir, "test", "integration")) # get test directory path
    global PROJECT_DIR
    PROJECT_DIR = current_dir 
    recreate_path = os.path.join(PROJECT_DIR, 'recreate.sh') # restart ci environment
    subprocess.call([recreate_path]) # call run script (how do I do verbose)?

    configure_headless_browser()
    log_into_ci()
#    log_into_redmine()
    create_redmine_project()
    create_redmine_issue()


def teardown_function(function):
    #TODO: Understand pytest scope, setup, and tear down along with execution sequence
    DRIVER.close()
    DISPLAY.stop()

def test_redmine_backup_and_restore():
    redmine_dir = os.path.join(PROJECT_DIR, 'img-scripts', 'redmine-docker')
    backup_dir = os.path.join(redmine_dir, 'backups')

    # Run backup script
    backup_script = os.path.join(redmine_dir, 'backupRedmine.sh')
    subprocess.call([backup_script, backup_dir])

    for file in os.listdir(backup_dir):
            assert file.endswith(".sql")

    # build blank environment
    recreate_path = os.path.join(PROJECT_DIR, 'recreate.sh')
    subprocess.call([recreate_path])

    # Restore environment
    restore_script = os.path.join(redmine_dir, 'restoreRedmineBackup.sh')
    subprocess.call([restore_script, backup_dir])

    # Restart environment after restore
    restart_path = os.path.join(PROJECT_DIR, 'restart.sh')
    subprocess.call([restart_path])

    # Log back in
    log_into_ci()
    log_into_redmine()
    
    # Check if project exists
    DRIVER.get("http://localhost/redmine/projects/")
    assert DRIVER.find_element_by_id("projects-index").text.find('Test Project') != -1

    # Check if issue exists
    DRIVER.get("http://localhost/redmine/issues")
    assert DRIVER.find_element_by_id("content").text.find('Test Issue of Type Bug') != -1

    # Cleanup backup directory
    try:
        shutil.rmtree(backup_dir)
    except Exception, e:
        print e
        exit(1)
