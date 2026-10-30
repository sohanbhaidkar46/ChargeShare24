package com.chargeshare.dto;
import jakarta.validation.constraints.*;
import java.time.LocalDateTime;
public record BookingRequest(@NotNull Long locationId, @NotBlank @Size(max=100) String customerName,
 @NotBlank @Email @Size(max=150) String customerEmail, @NotNull @Future LocalDateTime startTime,
 @NotNull @DecimalMin("0.1") @DecimalMax("500.0") Double energyKwh) {}
