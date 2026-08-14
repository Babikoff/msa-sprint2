package com.hotelio.bookingservice.service;

import org.springframework.web.client.RestTemplate;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RestConnectionProxy {
  private final RestTemplate restConnection;  
  private static final Logger log = LoggerFactory.getLogger(RestConnectionProxy.class);

  public RestConnectionProxy(RestTemplate restConnection) {
    this.restConnection = restConnection;
  }

  public String GetStringValue(String subUrl) {
    log.info("Calling " + subUrl);
    String result = restConnection.getForObject("http://hotelio-monolith:8080/api/" + subUrl, String.class);
    log.info(subUrl + " returned " + result);
    return result;
  }

}

