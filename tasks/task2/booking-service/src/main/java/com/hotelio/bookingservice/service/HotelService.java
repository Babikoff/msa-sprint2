package com.hotelio.bookingservice.service;

import org.springframework.stereotype.Service;

@Service
public class HotelService {
    private final RestConnectionProxy restConnectionProxy;
    public HotelService(RestConnectionProxy restConnectionProxy) {
        this.restConnectionProxy = restConnectionProxy;
    }

    public boolean isHotelOperational(String hotelId) {
        return "true".equalsIgnoreCase(restConnectionProxy.GetStringValue("hotels/" + hotelId +"/operational"));
    }

    public boolean isHotelFullyBooked(String hotelId) {
        return "true".equalsIgnoreCase(restConnectionProxy.GetStringValue("hotels/" + hotelId +"/fully-booked"));
    }
}
