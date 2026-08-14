package com.hotelio.bookingservice.service;

import org.springframework.stereotype.Service;

@Service
public class ReviewService {
    private final RestConnectionProxy restConnectionProxy;

    public ReviewService(RestConnectionProxy restConnectionProxy) {
        this.restConnectionProxy = restConnectionProxy;
    }

    public boolean isTrustedHotel(String hotelId) {
        return "true".equalsIgnoreCase(restConnectionProxy.GetStringValue("reviews/hotel/" + hotelId +"/trusted"));
    }
}