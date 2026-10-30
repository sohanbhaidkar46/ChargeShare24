package com.chargeshare.service;
import com.chargeshare.model.*;import com.chargeshare.repository.*;
import com.chargeshare.security.CurrentUser;
import org.springframework.stereotype.Service;import org.springframework.transaction.annotation.Transactional;import org.springframework.http.HttpStatus;import org.springframework.web.server.ResponseStatusException;
import java.util.*;import java.util.UUID;
@Service
public class PaymentService {
 private final BookingRepository bookings; private final PaymentRepository payments;
 public PaymentService(BookingRepository bookings,PaymentRepository payments){this.bookings=bookings;this.payments=payments;}
 public List<Payment> list(){var s=CurrentUser.get();if(s.role()==Role.ADMIN)return payments.findAll();if(s.role()==Role.HOST)return payments.findAll().stream().filter(p->p.getBooking().getLocation().getHostEmail()!=null&&p.getBooking().getLocation().getHostEmail().equalsIgnoreCase(s.email())).toList();return payments.findByPayerEmailIgnoreCaseOrderByCreatedAtDesc(s.email());}
 @Transactional
 public Payment pay(Long bookingId,String method){var s=CurrentUser.require(Role.USER);Booking b=bookings.findById(bookingId).orElseThrow(()->new ResponseStatusException(HttpStatus.NOT_FOUND,"Booking not found"));if(!b.getCustomerEmail().equalsIgnoreCase(s.email()))throw new ResponseStatusException(HttpStatus.FORBIDDEN,"You can only pay for your own bookings");if(b.getStatus()!=BookingStatus.ACCEPTED&&b.getStatus()!=BookingStatus.CONFIRMED)throw new ResponseStatusException(HttpStatus.CONFLICT,"Payment is available only after the host accepts the booking");if(payments.findByBookingId(bookingId).filter(p->p.getStatus()==PaymentStatus.PAID).isPresent())throw new ResponseStatusException(HttpStatus.CONFLICT,"This booking has already been paid");Payment p=payments.findByBookingId(bookingId).orElseGet(Payment::new);p.setBooking(b);p.setPayerEmail(s.email());p.setMethod(method==null?"DEMO":method);p.setAmount(b.getTotalPrice());p.setTransactionReference("CS-DEMO-"+UUID.randomUUID().toString().substring(0,8).toUpperCase());p.setStatus(PaymentStatus.PAID);b.setPaymentStatus(PaymentStatus.PAID);bookings.save(b);return payments.save(p);}
}
