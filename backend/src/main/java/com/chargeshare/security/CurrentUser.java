package com.chargeshare.security;
import com.chargeshare.model.Role;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
public final class CurrentUser {
 private static final ThreadLocal<AuthSession> CURRENT=new ThreadLocal<>();
 private CurrentUser(){}
 public static void set(AuthSession s){CURRENT.set(s);}
 public static void clear(){CURRENT.remove();}
 public static AuthSession get(){AuthSession s=CURRENT.get();if(s==null)throw new ResponseStatusException(HttpStatus.UNAUTHORIZED,"Please log in");return s;}
 public static AuthSession require(Role... roles){AuthSession s=get();for(Role r:roles)if(s.role()==r)return s;throw new ResponseStatusException(HttpStatus.FORBIDDEN,"Your account type is not allowed to perform this action");}
}
