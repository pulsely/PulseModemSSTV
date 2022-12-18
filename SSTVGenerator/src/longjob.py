import datetime
import time
import multiprocessing
import os
import boto3

def infinite_job(pid):
    print(f"### infinite_job() with PID: {pid}")

    while True:
        print(">> running at %s" % datetime.datetime.now() )
        time.sleep(1)

def startProcess():

    print("### startProcess()")
    process = multiprocessing.Process(target=infinite_job, args=())
    process.start()

    return process

def startFork():
    print("### startFork()")
    #sqs = boto3.resource('sqs')
    #print(f"sqs: {sqs}")

    pid = os.getpid()

    infinite_job(pid)


    return pid

#def startThread():


if __name__ == '__main__':
   startProcess()
   #startThread()
