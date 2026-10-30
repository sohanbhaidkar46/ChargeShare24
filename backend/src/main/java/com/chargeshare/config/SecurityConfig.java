package com.chargeshare.config;
import com.chargeshare.security.AuthInterceptor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.*;
@Configuration
public class SecurityConfig implements WebMvcConfigurer {
 private final AuthInterceptor auth;
 public SecurityConfig(AuthInterceptor auth){this.auth=auth;}
 @Override public void addInterceptors(InterceptorRegistry registry){registry.addInterceptor(auth).addPathPatterns("/api/**");}
 @Override public void addCorsMappings(CorsRegistry registry){registry.addMapping("/api/**").allowedOriginPatterns("http://localhost:*","http://127.0.0.1:*").allowedMethods("GET","POST","PUT","PATCH","DELETE","OPTIONS").allowedHeaders("*","Authorization").exposedHeaders("Authorization");}
}
