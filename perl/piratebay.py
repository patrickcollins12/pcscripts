from bs4 import BeautifulSoup
import urllib2
import re
import os
import collections
from subprocess import call


mb = 1024*1024

def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False
        
def num(s):
    try:
        return int(s)
    except ValueError:
        return float(s)



def scrape_piratebay( film_name ):

    title = urllib2.quote(film_name)
    url= "https://thepiratebay.mn/search/" + title + "/0/99/0"

    print "Retrieving: " + url

    # open the page
    headers = { 'User-Agent' : 'Mozilla/5.0' }
    req = urllib2.Request(url, None, headers)
    html = urllib2.urlopen(req).read()

    # parse it
    soup = BeautifulSoup(html , "lxml")

    classesref = soup.find_all("div",class_='detName')

    mylist= collections.OrderedDict()
    for divdesc in classesref:
    
        # No Country For Old Men (2007) 720p BrRip x264 - 750MB - YIFY
        urlandtitle = divdesc.find("a",class_="detLink")
        title = urlandtitle.contents[0]

        # <a href="magnet:?xt=urn:btih:.com%3A80&tr=udp%3A%2F%2Fopen.com%3A6969" 
        magneta = divdesc.find_next_sibling("a")
        href = magneta.get("href")

    
        # Uploaded 06-24&nbsp;2012, Size 752.48&nbsp;MiB, ULed by
        sizeDom = divdesc.find_next_sibling("font", class_="detDesc")
        size = sizeDom.contents[0]

        td1 = divdesc.parent
        td2 = td1.find_next_sibling("td")
        seeders = td2.contents[0]

        # Get 725.5 MiB|GiB
        m = re.search("Size ([\d\.]+)",size)
        if m:
            sizefloat = num(m.groups()[0])

        m = re.search("Size.*(GiB|MiB)",size)
        if m:
            type2 = m.groups()[0]
            if type2 == "GiB":
                sizefloat*=1000
            #print type2
            #print sizefloat
    
        if sizefloat > 1000 and sizefloat < 2500:
            mydesc = "%s (%sMb - %s seeders)" % (title, sizefloat, seeders)
            mylist[mydesc] = href
            # print(href)
            # print(size)
            # print

    return mylist



def process_list(mylist,film_name, size):
    i=0
    
    for desc,href in mylist.iteritems():
        print "[%s] %s" % (i,desc)
        i+=1
    
    name = raw_input("Choose a number, r=retry, s=skip: ")
    if name == '' or name == 's':
        return
    if name == 'r':
        process( film_name )
    if is_number(name):
        num = int(name)
        print "You chose %d" % (num)
        magnet = mylist.items()[num][1]
        print "open " + magnet
        call(["open", magnet])
    else:
        process(name,size)

        
        
def process( film_name, size ):
    print "\n\n"
    print "%s (%dmb current)" %(film_name, int(size/mb))
    mylist = scrape_piratebay(film_name)
    process_list(mylist,film_name,size)
        
def walkDir(dir):

    for dirName, subdirList, fileList in os.walk(dir):

        for fname in fileList:
            p=os.path.join(dirName,fname)
            b = os.path.getsize(p)

            #print '\n>> %s %smb' % (p,b/mb)
            
            if b > 500*mb and b < 900*mb:
                
                p2 = re.sub('\.\w+$','',fname)
                p3 = re.sub(r'\((\d{4})\).*',r'\1',p2)
                
                process(p3,b)
                #print p, b/mb
            else:
                print "    Skipping " + fname
                
walkDir(".")
# getList("Divergent")