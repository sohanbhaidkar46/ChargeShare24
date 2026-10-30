package com.chargeshare.controller;
import com.chargeshare.model.Payment;import com.chargeshare.service.PaymentService;
import org.springframework.web.bind.annotation.*;import jakarta.validation.constraints.NotBlank;import java.util.List;import java.util.Map;
@RestController @RequestMapping("/api/payments")
public class PaymentController {
 private final PaymentService service;public PaymentController(PaymentService service){this.service=service;}
 @GetMapping public List<Payment> list(){return service.list();}
 @PostMapping("/booking/{bookingId}/demo") public Payment pay(@PathVariable Long bookingId,@RequestBody(required=false) Map<String,String> body){return service.pay(bookingId,body==null?"DEMO":body.getOrDefault("method","DEMO"));}
}
