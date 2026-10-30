package com.chargeshare.repository;
import com.chargeshare.model.*;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface LocationRepository extends JpaRepository<ChargingLocation,Long> {
 List<ChargingLocation> findByHostEmailIgnoreCase(String hostEmail);
 List<ChargingLocation> findByAreaContainingIgnoreCase(String area);
 List<ChargingLocation> findByType(LocationType type);
 List<ChargingLocation> findBySolarSupportedTrue();
 List<ChargingLocation> findByAvailableChargersGreaterThan(int count);
}
