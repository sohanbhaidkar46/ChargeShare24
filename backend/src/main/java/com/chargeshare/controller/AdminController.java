package com.chargeshare.controller;
import com.chargeshare.model.*;import com.chargeshare.repository.*;import com.chargeshare.security.CurrentUser;
import org.springframework.web.bind.annotation.*;import org.springframework.http.HttpStatus;import org.springframework.web.server.ResponseStatusException;
import java.util.*;
@RestController @RequestMapping("/api/admin")
public class AdminController {
 private final UserAccountRepository users;private final LocationRepository locations;private final BookingRepository bookings;private final PaymentRepository payments;
 public AdminController(UserAccountRepository u,LocationRepository l,BookingRepository b,PaymentRepository p){users=u;locations=l;bookings=b;payments=p;}
 public record UserView(Long id,String fullName,String email,String role,boolean enabled,boolean hostAvailable){}
 private UserView view(UserAccount u){return new UserView(u.getId(),u.getFullName(),u.getEmail(),u.getRole().name(),u.isEnabled(),u.isHostAvailable());}
 @GetMapping("/users") public List<UserView> users(){CurrentUser.require(Role.ADMIN);return users.findAll().stream().map(this::view).toList();}
 @PatchMapping("/users/{id}/enabled") public UserView enabled(@PathVariable Long id,@RequestBody Map<String,Boolean> body){CurrentUser.require(Role.ADMIN);UserAccount u=users.findById(id).orElseThrow(()->new ResponseStatusException(HttpStatus.NOT_FOUND,"User not found"));if(u.getRole()==Role.ADMIN)throw new ResponseStatusException(HttpStatus.CONFLICT,"Admin accounts cannot be suspended here");u.setEnabled(Boolean.TRUE.equals(body.get("enabled")));return view(users.save(u));}
 @GetMapping("/summary") public Map<String,Object> summary(){CurrentUser.require(Role.ADMIN);return Map.of("users",users.count(),"hosts",users.findAll().stream().filter(u->u.getRole()==Role.HOST).count(),"locations",locations.count(),"bookings",bookings.count(),"payments",payments.count(),"paidAmount",payments.findAll().stream().filter(p->p.getStatus()==PaymentStatus.PAID).mapToDouble(Payment::getAmount).sum());}
}
