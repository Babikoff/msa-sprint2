package com.hotelio.bookingservice.service;

import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class AppUserService {

    // private final AppUserRepository repository;

    public AppUserService(/*AppUserRepository repository*/) {
        // this.repository = repository;
    }

    public boolean isUserBlacklisted(String userId) {
        return false; //TODO:
        // return repository.findById(userId)
        //         .map(AppUser::isBlacklisted)
        //         .orElse(false);
    }

    public boolean isUserActive(String userId) {
        return true; //TODO:
        // return repository.findById(userId)
        //         .map(AppUser::isActive)
        //         .orElse(false);
    }

    public Optional<String> getUserStatus(String userId) {
        return Optional.ofNullable("TurboVIP"); //TODO:
        // return repository.findById(userId)
        //         .map(AppUser::getStatus);
    }

    // public Optional<AppUser> getUserById(String userId) {
    //     return Optional.ofNullable(new AppUser("UserX", "VIP", false, true)); //TODO:
    // }

    // public boolean isVipUser(String userId) {
    //     return true; //TODO:
    //     // return repository.findById(userId)
    //     //         .map(user -> "VIP".equalsIgnoreCase(user.getStatus()))
    //     //         .orElse(false);
    // }

    // public boolean isAuthorized(String userId) {
    //     return true; //TODO:
    //     // return repository.findById(userId)
    //     //         .map(user -> user.isActive() && !user.isBlacklisted())
    //     //         .orElse(false);
    // }
}
