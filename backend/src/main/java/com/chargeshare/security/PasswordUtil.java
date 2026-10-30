package com.chargeshare.security;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.SecureRandom;
import java.util.Base64;
public final class PasswordUtil {
 private PasswordUtil(){}
 public static String hash(String password){
  try { byte[] salt=new byte[16]; new SecureRandom().nextBytes(salt); byte[] key=derive(password,salt);
   return Base64.getEncoder().encodeToString(salt)+":"+Base64.getEncoder().encodeToString(key);
  } catch(Exception e){throw new IllegalStateException(e);}
 }
 public static boolean verify(String password,String stored){
  try {String[] parts=stored.split(":"); byte[] salt=Base64.getDecoder().decode(parts[0]);byte[] expected=Base64.getDecoder().decode(parts[1]);return java.security.MessageDigest.isEqual(expected,derive(password,salt));}
  catch(Exception e){return false;}
 }
 private static byte[] derive(String p,byte[] salt)throws Exception {PBEKeySpec spec=new PBEKeySpec(p.toCharArray(),salt,120000,256);try{return SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();}finally{spec.clearPassword();}}
}
