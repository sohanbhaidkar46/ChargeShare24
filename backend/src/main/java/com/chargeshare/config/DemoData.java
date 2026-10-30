package com.chargeshare.config;
import com.chargeshare.model.*;import com.chargeshare.repository.*;
import com.chargeshare.security.PasswordUtil;
import org.springframework.boot.CommandLineRunner;import org.springframework.context.annotation.Bean;import org.springframework.context.annotation.Configuration;
@Configuration public class DemoData {
 @Bean CommandLineRunner seedData(LocationRepository locations,UserAccountRepository users){return args->{
  seedUser(users,"ChargeShare Admin","admin@chargeshare.demo","Admin123!",Role.ADMIN);
  seedUser(users,"Demo Host","host@chargeshare.demo","Host123!",Role.HOST);
  seedUser(users,"Demo EV User","user@chargeshare.demo","User123!",Role.USER);
  if(locations.count()>0){
   for(ChargingLocation l:locations.findAll()){if(l.getHostEmail()==null||l.getHostEmail().isBlank()){l.setHostEmail("host@chargeshare.demo");l.setHostName("Demo Host");locations.save(l);}}
   return;
  }
  add(locations,"Palm Grove Home Charger","Mapusa",LocationType.HOME,12.5,true,1,"Near Mapusa market, Goa","Quiet residential charging point with solar support.","Demo Host","host@chargeshare.demo");
  add(locations,"Café Current","Panaji",LocationType.CAFE,16.0,false,2,"18th June Road, Panaji, Goa","Charge while enjoying coffee and snacks.","Demo Host","host@chargeshare.demo");
  add(locations,"Coastal Stay Charging","Calangute",LocationType.MOTEL,18.0,true,2,"Calangute, North Goa","Visitor-friendly charging near the beach belt.","Demo Host","host@chargeshare.demo");
  add(locations,"Green Fork Restaurant","Porvorim",LocationType.RESTAURANT,14.5,true,1,"Porvorim, Goa","Dine in while your EV charges.","Demo Host","host@chargeshare.demo");
  add(locations,"Riverside Public Point","Ponda",LocationType.PUBLIC,11.0,false,3,"Ponda, Goa","Community charging point with multiple bays.","Demo Host","host@chargeshare.demo");
 };}
 private void seedUser(UserAccountRepository r,String name,String email,String password,Role role){if(r.existsByEmailIgnoreCase(email))return;UserAccount u=new UserAccount();u.setFullName(name);u.setEmail(email);u.setPasswordHash(PasswordUtil.hash(password));u.setRole(role);r.save(u);}
 private void add(LocationRepository r,String name,String area,LocationType type,double price,boolean solar,int chargers,String address,String desc,String host,String email){ChargingLocation l=new ChargingLocation();l.setName(name);l.setArea(area);l.setType(type);l.setPricePerKwh(price);l.setSolarSupported(solar);l.setAvailableChargers(chargers);l.setAddress(address);l.setDescription(desc);l.setHostName(host);l.setHostEmail(email);r.save(l);}
}
