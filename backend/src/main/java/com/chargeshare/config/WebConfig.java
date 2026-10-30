package com.chargeshare.config;
import org.springframework.context.annotation.Configuration;import org.springframework.web.servlet.config.annotation.*;
@Configuration public class WebConfig implements WebMvcConfigurer {
 @Override public void addCorsMappings(CorsRegistry registry){registry.addMapping("/api/**").allowedOriginPatterns("http://localhost:*").allowedMethods("GET","POST","PUT","PATCH","DELETE","OPTIONS").allowedHeaders("*");}
}
