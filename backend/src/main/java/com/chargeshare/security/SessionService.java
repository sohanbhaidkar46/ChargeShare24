package com.chargeshare.security;
import com.chargeshare.model.UserAccount;
import org.springframework.stereotype.Service;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.concurrent.ConcurrentHashMap;
@Service
public class SessionService {
 private final ConcurrentHashMap<String,AuthSession> sessions=new ConcurrentHashMap<>();
 public String create(UserAccount u){byte[] b=new byte[32];new SecureRandom().nextBytes(b);String token=Base64.getUrlEncoder().withoutPadding().encodeToString(b);sessions.put(token,new AuthSession(u.getId(),u.getEmail(),u.getFullName(),u.getRole()));return token;}
 public AuthSession get(String token){return sessions.get(token);}
 public void revoke(String token){sessions.remove(token);}
}
