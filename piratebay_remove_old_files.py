import os
import csv
import shutil

file="/Users/patrick/Desktop/updatingfiles.csv"

def set_mod_time(old,new):   
    print "Setting time from " + old + " onto " + new
    (mode, ino, dev, nlink, uid, gid, size, atime, mtime, ctime) = os.stat(old)
    os.utime(new,(atime, mtime))
    
    
    
def set_new_to_old(old,new):
    
    
    set_mod_time(old,new)
    if os.path.isdir(new):
        for dirName, subdirList, fileList in os.walk(new):
            for fname in fileList:
                p=os.path.join(dirName,fname)
                set_mod_time(old,p)
    
    # mv old, /Volumes/boxeedisk/backup/
    shutil.move(old, "/Volumes/boxeedisk/backup/")
    
    
with open(file) as csvfile:
    vidreader = csv.reader(csvfile, delimiter=',', quotechar='"')
    vidreader.next()
    for row in vidreader:
        old   = row[0]
        new   = row[1]
        
        if new:
            set_new_to_old(old,new)
            
