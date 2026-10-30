package com.chargeshare.controller;
import com.chargeshare.model.*;
import com.chargeshare.repository.UserAccountRepository;
import com.chargeshare.security.*;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import java.util.Map;

@RestController @RequestMapping("/api/auth")
public class AuthController {
 private final UserAccountRepository users; private final SessionService sessions;
 public AuthController(UserAccountRepository users,SessionService sessions){this.users=users;this.sessions=sessions;}
 public record LoginRequest(@Email @NotBlank String email,@NotBlank String password,@NotNull Role role){}
 public record RegisterRequest(@NotBlank @Size(max=100) String fullName,@Email @NotBlank String email,@NotBlank @Size(min=6,max=100) String password,@NotNull Role role){}
 @PostMapping("/login") public Map<String,Object> login(@Valid @RequestBody LoginRequest r){
  UserAccount u=users.findByEmailIgnoreCase(r.email().trim()).orElseThrow(()->new ResponseStatusException(HttpStatus.UNAUTHORIZED,"Invalid email or password"));
  if(!u.isEnabled()||u.getRole()!=r.role()||!PasswordUtil.verify(r.password(),u.getPasswordHash()))throw new ResponseStatusException(HttpStatus.UNAUTHORIZED,"Invalid credentials or selected account type");
  String token=sessions.create(u);return Map.of("token",token,"id",u.getId(),"email",u.getEmail(),"fullName",u.getFullName(),"role",u.getRole().name(),"hostAvailable",u.isHostAvailable());
 }
 @PostMapping("/register") @ResponseStatus(HttpStatus.CREATED) public Map<String,Object> register(@Valid @RequestBody RegisterRequest r){
  if(r.role()==Role.ADMIN)throw new ResponseStatusException(HttpStatus.FORBIDDEN,"Admin accounts cannot be self-registered");
  if(users.existsByEmailIgnoreCase(r.email().trim()))throw new ResponseStatusException(HttpStatus.CONFLICT,"An account with this email already exists");
  UserAccount u=new UserAccount();u.setFullName(r.fullName().trim());u.setEmail(r.email().trim().toLowerCase());u.setPasswordHash(PasswordUtil.hash(r.password()));u.setRole(r.role());u=users.save(u);
  return Map.of("message","Account created. You can now log in.","role",u.getRole().name());
 }
 @GetMapping("/me") public Map<String,Object> me(){AuthSession s=CurrentUser.get();return Map.of("id",s.userId(),"email",s.email(),"fullName",s.fullName(),"role",s.role().name());}
 @PostMapping("/logout") public Map<String,String> logout(@RequestHeader("Authorization") String h){sessions.revoke(h.substring(7).trim());return Map.of("message","Logged out");}
}
