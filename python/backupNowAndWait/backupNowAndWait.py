#!/usr/bin/env python
"""Backup Now for python"""

### usage: ./backupNow.py -v mycluster -u admin -j 'VM Backup'

### import pyhesity wrapper module
from pyhesity import *
from time import sleep

### command line arguments
import argparse
parser = argparse.ArgumentParser()
parser.add_argument('-v','--vip', type=str, required=True)
parser.add_argument('-u','--username', type=str, required=True)
parser.add_argument('-d','--domain',type=str,default='local')
parser.add_argument('-j','--jobName', type=str, required=True)

args = parser.parse_args()
    
vip = args.vip
username = args.username
domain = args.domain
jobName = args.jobName

### authenticate
apiauth(vip, username, domain)

### find protectionJob
job = [ job for job in api('get','protectionJobs') if job['name'].lower() == jobName.lower() ]
if not job:
    print "Job '%s' not found" % jobName
    exit()

runs = api('get','protectionRuns?jobId=%s' % job[0]['id'])
newRunId = lastRunId = runs[0]['backupRun']['jobRunId']

### wait for existing job run to finish
finishedStates = ['kCanceled', 'kSuccess', 'kFailure']
if (runs[0]['backupRun']['status'] not in finishedStates):
    print "waiting for existing job run to finish..."
    while (runs[0]['backupRun']['status'] not in finishedStates):
        sleep(5)
        runs = api('get','protectionRuns?jobId=%s' % job[0]['id'])    

### run protectionJob
print "Running %s..." % jobName
api('post',"protectionJobs/run/%s" % job[0]['id'], {'runType': 'kRegular'})

### wait for new job run to appear
#newTaskId = lastTaskId
while(newRunId == lastRunId):
    sleep(1)
    runs = api('get','protectionRuns?jobId=%s' % job[0]['id'])
    newRunId=runs[0]['backupRun']['jobRunId']

print "New Job Run ID: %s" % newRunId

### wait for job run to finish

while(runs[0]['backupRun']['status'] not in finishedStates):
    sleep(5)
    runs = api('get','protectionRuns?jobId=%s' % job[0]['id'])
print "Job finished with status: %s" % runs[0]['backupRun']['status']
