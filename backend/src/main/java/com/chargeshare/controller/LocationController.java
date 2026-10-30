package com.chargeshare.controller;
import com.chargeshare.model.*;import com.chargeshare.service.LocationService;import com.chargeshare.security.*;
import jakarta.validation.Valid;import org.springframework.web.bind.annotation.*;import org.springframework.http.HttpStatus;import java.util.List;import java.util.Map;import com.chargeshare.repository.UserAccountRepository;import com.chargeshare.repository.LocationRepository;import org.springframework.web.server.ResponseStatusException;
@RestController @RequestMapping("/api/locations")
public class LocationController {
 private final LocationService service; private final UserAccountRepository users; private final LocationRepository locations;
 public LocationController(LocationService service,UserAccountRepository users,LocationRepository locations){this.service=service;this.users=users;this.locations=locations;}
 @GetMapping public List<ChargingLocation> list(@RequestParam(required=false) String q,@RequestParam(required=false) LocationType type,@RequestParam(required=false) Boolean solar,@RequestParam(required=false) Boolean available){return service.search(q,type,solar,available);}
 @GetMapping("/{id}") public ChargingLocation get(@PathVariable Long id){return service.get(id);}
 @PostMapping public ChargingLocation create(@Valid @RequestBody ChargingLocation l){CurrentUser.require(Role.ADMIN);return service.create(l);}
 @PutMapping("/{id}") public ChargingLocation update(@PathVariable Long id,@Valid @RequestBody ChargingLocation l){CurrentUser.require(Role.ADMIN);return service.update(id,l);}
 @DeleteMapping("/{id}") @ResponseStatus(HttpStatus.NO_CONTENT) public void delete(@PathVariable Long id){CurrentUser.require(Role.ADMIN);service.delete(id);}
 @GetMapping("/host/availability") public Map<String,Boolean> availability(){var s=CurrentUser.require(Role.HOST);var u=users.findById(s.userId()).orElseThrow();return Map.of("available",u.isHostAvailable());}
 @PutMapping("/{id}/availability") public ChargingLocation setLocationAvailability(@PathVariable Long id,@RequestBody Map<String,Boolean> body){var s=CurrentUser.require(Role.ADMIN,Role.HOST);var l=service.get(id);if(s.role()==Role.HOST&&(l.getHostEmail()==null||!l.getHostEmail().equalsIgnoreCase(s.email())))throw new ResponseStatusException(HttpStatus.FORBIDDEN,"You can only change availability for your own charging locations");l.setHostAvailable(Boolean.TRUE.equals(body.get("available")));return locations.save(l);}
}
