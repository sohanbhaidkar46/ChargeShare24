package com.chargeshare.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.Instant;

@Entity
@Table(name="user_accounts", uniqueConstraints=@UniqueConstraint(columnNames="email"))
public class UserAccount {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
 @NotBlank @Size(max=100) private String fullName;
 @Email @NotBlank @Column(nullable=false, unique=true) private String email;
 @Column(nullable=false, length=300) private String passwordHash;
 @Enumerated(EnumType.STRING) @Column(nullable=false, length=16) private Role role;
 private boolean enabled=true;
 private boolean hostAvailable=true;
 private Instant createdAt=Instant.now();
 public UserAccount(){}
 public Long getId(){return id;} public void setId(Long v){id=v;}
 public String getFullName(){return fullName;} public void setFullName(String v){fullName=v;}
 public String getEmail(){return email;} public void setEmail(String v){email=v;}
 public String getPasswordHash(){return passwordHash;} public void setPasswordHash(String v){passwordHash=v;}
 public Role getRole(){return role;} public void setRole(Role v){role=v;}
 public boolean isEnabled(){return enabled;} public void setEnabled(boolean v){enabled=v;}
 public boolean isHostAvailable(){return hostAvailable;} public void setHostAvailable(boolean v){hostAvailable=v;}
 public Instant getCreatedAt(){return createdAt;} public void setCreatedAt(Instant v){createdAt=v;}
}
