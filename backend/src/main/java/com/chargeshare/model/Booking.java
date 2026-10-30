package com.chargeshare.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import java.time.Instant;
import java.time.LocalDateTime;

@Entity @Table(name="bookings")
public class Booking {
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
    @ManyToOne(optional=false, fetch=FetchType.EAGER) @JoinColumn(name="location_id") private ChargingLocation location;
    @NotBlank @Size(max=100) private String customerName;
    @NotBlank @Email @Size(max=150) private String customerEmail;
    @NotNull @Future private LocalDateTime startTime;
    @NotNull @DecimalMin("0.1") @DecimalMax("500.0") private Double energyKwh;
    @NotNull @DecimalMin("0.0") private Double totalPrice;
    @Enumerated(EnumType.STRING) @Column(columnDefinition="varchar(20)") private BookingStatus status = BookingStatus.CONFIRMED;
    @Enumerated(EnumType.STRING) private PaymentStatus paymentStatus = PaymentStatus.UNPAID;
    private Instant createdAt = Instant.now();
    public Booking() {}
    public Long getId(){return id;} public void setId(Long v){id=v;}
    public ChargingLocation getLocation(){return location;} public void setLocation(ChargingLocation v){location=v;}
    public String getCustomerName(){return customerName;} public void setCustomerName(String v){customerName=v;}
    public String getCustomerEmail(){return customerEmail;} public void setCustomerEmail(String v){customerEmail=v;}
    public LocalDateTime getStartTime(){return startTime;} public void setStartTime(LocalDateTime v){startTime=v;}
    public Double getEnergyKwh(){return energyKwh;} public void setEnergyKwh(Double v){energyKwh=v;}
    public Double getTotalPrice(){return totalPrice;} public void setTotalPrice(Double v){totalPrice=v;}
    public BookingStatus getStatus(){return status;} public void setStatus(BookingStatus v){status=v;}
    public PaymentStatus getPaymentStatus(){return paymentStatus;} public void setPaymentStatus(PaymentStatus v){paymentStatus=v;}
    public Instant getCreatedAt(){return createdAt;} public void setCreatedAt(Instant v){createdAt=v;}
}
