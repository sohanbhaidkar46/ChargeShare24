package com.chargeshare.model;

import jakarta.persistence.*;
import java.time.Instant;

@Entity @Table(name="payments")
public class Payment {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
 @OneToOne(optional=false) @JoinColumn(name="booking_id", unique=true) private Booking booking;
 private String payerEmail;
 private String method;
 private String transactionReference;
 @Enumerated(EnumType.STRING) private PaymentStatus status=PaymentStatus.UNPAID;
 private Double amount;
 private Instant createdAt=Instant.now();
 public Payment(){}
 public Long getId(){return id;} public void setId(Long v){id=v;}
 public Booking getBooking(){return booking;} public void setBooking(Booking v){booking=v;}
 public String getPayerEmail(){return payerEmail;} public void setPayerEmail(String v){payerEmail=v;}
 public String getMethod(){return method;} public void setMethod(String v){method=v;}
 public String getTransactionReference(){return transactionReference;} public void setTransactionReference(String v){transactionReference=v;}
 public PaymentStatus getStatus(){return status;} public void setStatus(PaymentStatus v){status=v;}
 public Double getAmount(){return amount;} public void setAmount(Double v){amount=v;}
 public Instant getCreatedAt(){return createdAt;} public void setCreatedAt(Instant v){createdAt=v;}
}
