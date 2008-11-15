 #!/bin/env python
      
import sys, ldap
  
LDAP_HOST = 'hqstptas01'
LDAP_BASE_DN = 'cn=Windchill_8.0,cn=Application Services,o=nvidia'
MGR_CRED = 'cn=Manager'
MGR_PASSWD = 'stgpassword'
NVIDIA_FILTER = 'o=nvidia'

class NvidiaLDAPMgmt:

  def __init__(self, ldap_host=None, ldap_base_dn=None, mgr_cred=None,
mgr_passwd=None):
      if not ldap_host:
          ldap_host = LDAP_HOST
      if not ldap_base_dn:
          ldap_base_dn = LDAP_BASE_DN
      if not mgr_cred:
          mgr_cred = MGR_CRED
      if not mgr_passwd:
          mgr_passwd = MGR_PASSWD
      self.ldapconn = ldap.open(ldap_host)
      self.ldapconn.simple_bind(mgr_cred, mgr_passwd)
      self.ldap_base_dn = ldap_base_dn

  def list_nvidias(self, nvidia_filter=None, attrib=None):
      if not nvidia_filter:
          nvidia_filter = NVIDIA_FILTER
      s = self.ldapconn.search_s(self.ldap_base_dn, ldap.SCOPE_SUBTREE,nvidia_filter, attrib)
      print "Here is the complete list of nvidias:"
      nvidia_list = []
      count = 0
      for nvidia in s:
          attrib_dict = nvidia[1]
          count = count + 1
          for a in attrib:
##              out = "%s: %s" %(a, attrib_dict[a])
              out =  attrib_dict[a]
              print out
              nvidia_list.append(out)
          if count >10 :
              return nvidia_list
              
      return nvidia_list

  def add_nvidia(self, nvidia_name, nvidia_ou, nvidia_info):
      nvidia_dn = 'cn=%s,ou=%s,%s' % (nvidia_name, nvidia_ou, self.ldap_base_dn)
      nvidia_attrib = [(k, v) for (k, v) in nvidia_info.items()]
      print "Adding nvidia %s with ou=%s" % (nvidia_name, nvidia_ou)
      self.ldapconn.add_s(nvidia_dn, nvidia_attrib)    

  def modify_nvidia(self, nvidia_name, nvidia_ou, nvidia_attrib):
      nvidia_dn = 'cn=%s,ou=%s,%s' % (nvidia_name, nvidia_ou, self.ldap_base_dn)
      print "Modifying nvidia %s with ou=%s" % (nvidia_name, nvidia_ou)
      self.ldapconn.modify_s(nvidia_dn, nvidia_attrib)    

  def delete_nvidia(self, nvidia_name, nvidia_ou):
      nvidia_dn = 'cn=%s,ou=%s,%s' % (nvidia_name, nvidia_ou, self.ldap_base_dn)
      print "Deleting nvidia %s with ou=%s" % (nvidia_name, nvidia_ou)
      self.ldapconn.delete_s(nvidia_dn)



l = NvidiaLDAPMgmt()
# see if it was added
l.list_nvidias(attrib=['cn', 'mail','userPassword'])