package com.chargeshare.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import java.time.Instant;

@Entity @Table(name="charging_locations")
public class ChargingLocation {
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
    @NotBlank @Size(max=100) private String name;
    @NotBlank @Size(max=100) private String area;
    @NotNull @Enumerated(EnumType.STRING) private LocationType type;
    @NotNull @DecimalMin("0.01") @DecimalMax("1000.00") private Double pricePerKwh;
    private boolean solarSupported;
    @Min(0) @Max(100) private int availableChargers;
    @NotBlank @Size(max=500) private String address;
    @Size(max=1000) private String description;
    @NotBlank @Size(max=100) private String hostName;
    private String hostEmail;
    // Nullable during upgrade so existing H2 rows can migrate safely.
    // Null is treated as available until the row is next saved.
    @Column(nullable=true)
    private Boolean hostAvailable = true;
    private Instant createdAt = Instant.now();
    public ChargingLocation() {}
    public Long getId(){return id;} public void setId(Long v){id=v;}
    public String getName(){return name;} public void setName(String v){name=v;}
    public String getArea(){return area;} public void setArea(String v){area=v;}
    public LocationType getType(){return type;} public void setType(LocationType v){type=v;}
    public Double getPricePerKwh(){return pricePerKwh;} public void setPricePerKwh(Double v){pricePerKwh=v;}
    public boolean isSolarSupported(){return solarSupported;} public void setSolarSupported(boolean v){solarSupported=v;}
    public int getAvailableChargers(){return availableChargers;} public void setAvailableChargers(int v){availableChargers=v;}
    public String getAddress(){return address;} public void setAddress(String v){address=v;}
    public String getDescription(){return description;} public void setDescription(String v){description=v;}
    public String getHostName(){return hostName;} public void setHostName(String v){hostName=v;}
    public String getHostEmail(){return hostEmail;} public void setHostEmail(String v){hostEmail=v;}
    public boolean isHostAvailable(){return hostAvailable == null || hostAvailable;} public void setHostAvailable(boolean v){hostAvailable=v;}
    public Instant getCreatedAt(){return createdAt;} public void setCreatedAt(Instant v){createdAt=v;}
}
