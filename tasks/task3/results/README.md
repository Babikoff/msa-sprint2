
**GraphQL запросы для тестирования**

query {
  promoCodesByIds(codes: ["TESTCODE1", "TESTCODE2"]) {
    code
  },  
  bookingsByUser(userId: "test-user-3") {
    userId
    hotel {
      name
      id
      city
      stars
    }
  },
  hotelsByIds(ids: ["test-hotel-1", "test-hotel-2"]) {
    id
    name
    city
    stars
  }  
}


query {
  bookingsByUser(userId: "test-user-3") {
    userId
    hotel {
      name
      id
      city
      stars
    }
  },
  hotelsByIds(ids: ["test-hotel-1", "test-hotel-2"]) {
    id
    name
    city
    stars
  }  
}

query {
  bookingsByUser(userId: "test-user-3") {
    userId
    hotel {
      name
      id
      city
      stars
    }
    discountPercent
    discountInfo {
      isValid
      originalDiscount  
      finalDiscount
      description
    }
  },
}
