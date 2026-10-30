package com.chargeshare.service;
import com.chargeshare.model.*; import com.chargeshare.repository.*; import com.chargeshare.security.CurrentUser; import com.chargeshare.security.AuthSession;
import org.springframework.stereotype.Service; import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException; import org.springframework.http.HttpStatus;
import java.util.*;
@Service
public class LocationService {
 private final LocationRepository repo; private final BookingRepository bookings;
 public LocationService(LocationRepository repo, BookingRepository bookings){this.repo=repo;this.bookings=bookings;}
 public List<ChargingLocation> search(String q, LocationType type, Boolean solar, Boolean available){
  return repo.findAll().stream().filter(l->q==null||q.isBlank()||l.getName().toLowerCase().contains(q.toLowerCase())||l.getArea().toLowerCase().contains(q.toLowerCase())||l.getAddress().toLowerCase().contains(q.toLowerCase()))
   .filter(l->type==null||l.getType()==type).filter(l->solar==null||l.isSolarSupported()==solar).filter(l->available==null||!available||(l.getAvailableChargers()>0&&l.isHostAvailable())).sorted(Comparator.comparing(ChargingLocation::getName)).toList();
 }
 public ChargingLocation get(Long id){return repo.findById(id).orElseThrow(()->new ResponseStatusException(HttpStatus.NOT_FOUND,"Charging location not found"));}
 public ChargingLocation create(ChargingLocation l){CurrentUser.require(Role.ADMIN);l.setId(null);return repo.save(l);}
 public ChargingLocation update(Long id, ChargingLocation input){AuthSession u=CurrentUser.require(Role.ADMIN);ChargingLocation l=get(id); l.setName(input.getName());l.setArea(input.getArea());l.setType(input.getType());l.setPricePerKwh(input.getPricePerKwh());l.setSolarSupported(input.isSolarSupported());l.setAvailableChargers(input.getAvailableChargers());l.setAddress(input.getAddress());l.setDescription(input.getDescription());l.setHostName(input.getHostName());l.setHostEmail(input.getHostEmail());l.setHostAvailable(input.isHostAvailable());return repo.save(l);}
 @Transactional public void delete(Long id){CurrentUser.require(Role.ADMIN);ChargingLocation l=get(id); if(!bookings.findByLocationIdOrderByCreatedAtDesc(id).isEmpty()) throw new ResponseStatusException(HttpStatus.CONFLICT,"Cannot delete a location that has booking history. Cancel bookings first or retain this location.");repo.delete(l);}
}
