import { ApolloServer } from '@apollo/server';
import { startStandaloneServer } from '@apollo/server/standalone';
import { buildSubgraphSchema } from '@apollo/subgraph';
import { RestClient } from './rest-client.js';
import gql from 'graphql-tag';

const typeDefs = gql`
  type Booking @key(fields: "id") {
    id: ID!
    userId: String!
    hotelId: String!
    promoCode: String
    discountPercent: Int
    hotel: Hotel
  }

  extend type Hotel @key(fields: "id") {
    id: ID! @external
  }

  type Query {
    bookingsByUser(userId: String!): [Booking]
  }

`;

const resolvers = {
  Query: {
    bookingsByUser: async (_, { userId }, { req }) => {
      console.log("bookingsByUser");

      if (!userId) return []; 

      // Вызов к grpc booking-сервису
      var bookingService = new RestClient('http://booking-service:8080/api');
      var json = await bookingService.fetch('/bookings?userId=' + userId);
      console.log('Got bookings: ' + JSON.stringify(json));
      return json;
    },
  },
  Booking: {
	  // TODO: Реальный вызов к grpc booking-сервису или заглушка + ACL
    
  },
};

const server = new ApolloServer({
  schema: buildSubgraphSchema([{ typeDefs, resolvers }]),
});

startStandaloneServer(server, {
  listen: { port: 4001 },
  context: async ({ req }) => ({ req }),
}).then(() => {
  console.log('✅ Booking subgraph ready at http://localhost:4001/');
});
