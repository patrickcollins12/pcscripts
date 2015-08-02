import mechanize
import BeautifulSoup
import urllib2 
import cookielib
import logging
log = logging.getLogger("DropBoxClass")

cj = cookielib.CookieJar()
br = mechanize.Browser()
br.set_cookiejar(cj)

br.set_handle_equiv(True)
#    br.set_handle_gzip(True)
br.set_handle_redirect(True)
br.set_handle_referer(True)
br.set_handle_robots(False)
br.addheaders = [('User-agent', ' Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1018.0 Safari/535.19')]

r = br.open("https://www.dropbox.com/login/")

isLoginForm = lambda l: l.action == "https://www.dropbox.com/login" and l.method == "POST"

try:
    if verbose: print 'selecting form...'
    br.select_form(predicate=isLoginForm)
except:
    print("Unable to find login form.");
    exit(1);

br['login_email'] = email
br['login_password'] = password


print br.response().read()
