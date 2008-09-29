import java.util.*;
 
import javax.naming.*;
import javax.naming.ldap.*;
 

    Properties prop = new Properties();
    prop.put("java.naming.factory.initial", "com.sun.jndi.ldap.LdapCtxFactory");
    prop.put("java.naming.provider.url", "ldap://z2003:389");
    prop.put("java.naming.security.principal", "cn=windchill admin,cn=Users,dc=zelos,dc=com");
    prop.put("java.naming.security.credentials", "wczelos88");
        
    try {
        System.out.println("Binding");
      LdapContext ctx = new InitialLdapContext(prop, null);
      System.out.println("Bind successful");
    }
    catch (NamingException ex) {
        System.out.println("Exception thrown");
      ex.printStackTrace();
    }
