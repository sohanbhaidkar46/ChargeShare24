package com.chargeshare.repository;
import com.chargeshare.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
public interface PaymentRepository extends JpaRepository<Payment,Long> {
 Optional<Payment> findByBookingId(Long bookingId);
 List<Payment> findByPayerEmailIgnoreCaseOrderByCreatedAtDesc(String email);
}
