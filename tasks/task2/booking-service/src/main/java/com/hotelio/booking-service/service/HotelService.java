package com.hotelio.monolith.service;

// import com.hotelio.monolith.entity.Hotel;
// import com.hotelio.monolith.repository.HotelRepository;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.ArrayList;
import java.util.Optional;

@Service
public class HotelService {

    // private final HotelRepository repo;

    public HotelService(/*HotelRepository repo*/) {
        // this.repo = repo;
    }

    public boolean isHotelOperational(String hotelId) {
        return true; //TODO:
        // return repo.findById(hotelId).map(Hotel::isOperational).orElse(false);
    }

    public boolean isHotelFullyBooked(String hotelId) {
        return false; //TODO:
        // return repo.findById(hotelId).map(Hotel::isFullyBooked).orElse(true);
    }

    // private Hotel getTestHotel(String hotelId) {
    //     Hotel hotel = new Hotel(hotelId);
    //     hotel.setOperational(true);
    //     hotel.setFullyBooked(false);
    //     hotel.setCity("TurboCity");
    //     hotel.setRating(100500);
    //     hotel.setDescription("Test hotel descr");
    //     return hotel;
    // }

    // public Optional<Hotel> getHotelById(String hotelId) {
    //     return Optional.ofNullable(getTestHotel(hotelId));
    //     // return repo.findById(hotelId);
    // }

    // public List<Hotel> findHotelsInCity(String city) {
    //     if (city == null || city.isBlank()) return Collections.emptyList();
    //     List<Hotel> list =  new ArrayList<Hotel>();
    //     Hotel hotel = getTestHotel("TestHotel");
    //     hotel.setCity(city);
    //     list.add(hotel);
    //     return list;
    // }

    // public List<Hotel> findTopRatedHotelsInCity(String city, int limit) {
    //     if (city == null || city.isBlank()) return Collections.emptyList();
    //     List<Hotel> list =  new ArrayList<Hotel>();
    //     Hotel hotel = getTestHotel("TestHotel");
    //     hotel.setCity(city);
    //     list.add(hotel);
    //     return list;
    // }
}
