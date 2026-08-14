package com.hotelio.bookingservice.service;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class ReviewService extends RestConnectionProxy {
    
    public ReviewService(RestTemplate restConnection) {
        super(restConnection);
    }

    public boolean isTrustedHotel(String hotelId) {
        return "true".equalsIgnoreCase(GetStringValue("reviews/hotel/" + hotelId +"/trusted"));
    }
}