package com.hotelio.bookingservice.service;

import com.hotelio.bookingservice.entity.PromoCode;
import org.springframework.stereotype.Service;

// import java.util.Optional;
import java.time.LocalDate;

@Service
public class PromoCodeService {
    private final RestConnectionProxy restConnectionProxy;

    public PromoCodeService(RestConnectionProxy restConnectionProxy) {
        this.restConnectionProxy = restConnectionProxy;
    }

    public PromoCode validate(String promoCode, String userId) {
        PromoCode fullPromoCode = new PromoCode();
        fullPromoCode.setCode(promoCode);
        fullPromoCode.setDiscount(15);
        fullPromoCode.setVipOnly(false);
        fullPromoCode.setExpired(false);
        fullPromoCode.setValidUntil(LocalDate.now().plusDays(1));
        fullPromoCode.setDescription("Test promo");
        return fullPromoCode;
    }
}
