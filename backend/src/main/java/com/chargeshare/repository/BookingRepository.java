package com.chargeshare.repository;
import com.chargeshare.model.Booking;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface BookingRepository extends JpaRepository<Booking,Long> {
 List<Booking> findByCustomerEmailIgnoreCaseOrderByCreatedAtDesc(String email);
 List<Booking> findByLocationIdOrderByCreatedAtDesc(Long locationId);
}
