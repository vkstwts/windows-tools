import os
SENDMAIL = "/usr/sbin/sendmail" # sendmail location
p = os.popen("%s -t" % SENDMAIL, "w")
p.write("To: ysprathap@gmail.com\n")
p.write("From: ysprathap@gmail.com\n")
p.write("Subject: test\n")
p.write("\n") # blank line separating headers from body
p.write("Some text\n")
p.write("some more text\n")
sts = p.close()
if sts != 0:
    print "Sendmail exit status", sts
