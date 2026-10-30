package com.chargeshare.security;
import com.chargeshare.model.Role;
public record AuthSession(Long userId,String email,String fullName,Role role) {}
