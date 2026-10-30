package com.chargeshare.controller;
import com.chargeshare.dto.BookingRequest;import com.chargeshare.model.*;import com.chargeshare.service.BookingService;import com.chargeshare.security.*;
import jakarta.validation.Valid;import org.springframework.web.bind.annotation.*;import java.util.List;import java.util.Map;
@RestController @RequestMapping("/api/bookings")
public class BookingController {
 private final BookingService service;public BookingController(BookingService service){this.service=service;}
 @GetMapping public List<Booking> list(@RequestParam(required=false) String email){return service.all(email);}
 @GetMapping("/{id}") public Booking get(@PathVariable Long id){return service.get(id);}
 @GetMapping("/location/{locationId}") public List<Booking> forLocation(@PathVariable Long locationId){return service.forLocation(locationId);}
 @PostMapping public Booking create(@Valid @RequestBody BookingRequest r){return service.create(r);}
 @PutMapping("/{id}") public Booking update(@PathVariable Long id,@Valid @RequestBody BookingRequest r){return service.update(id,r);}
 @PatchMapping("/{id}/cancel") public Booking cancel(@PathVariable Long id){return service.cancel(id);}
 @PatchMapping("/{id}/accept") public Booking accept(@PathVariable Long id){return service.respond(id,true);}
 @PatchMapping("/{id}/reject") public Booking reject(@PathVariable Long id){return service.respond(id,false);}
}
