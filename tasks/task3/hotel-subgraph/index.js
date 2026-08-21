import { ApolloServer } from '@apollo/server';
import { startStandaloneServer } from '@apollo/server/standalone';
import { buildSubgraphSchema } from '@apollo/subgraph';
import { RestClient } from './rest-client.js';
import gql from 'graphql-tag';

const typeDefs = gql`
  type Hotel @key(fields: "id") {
    id: ID!
    name: String
    city: String
    stars: Int
  }

  type Query {
    hotelsByIds(ids: [ID!]!): [Hotel]
  }
`;

var monolithClient = new RestClient('http://monolith:8080/api');

const resolvers = {
  Hotel: {
    __resolveReference: async ({ id }) => {
      console.log('Resolve hotel ' + id);

      if (!id) return null; 

      var hotelJson = await monolithClient.fetch('/hotels/' + id);
      console.log('Got hotel: ' + JSON.stringify(hotelJson));
      return {
        id: hotelJson.id,
        name: hotelJson.name || hotelJson.description || 'No name',
        city: hotelJson.city,
        stars: hotelJson.rating,
        description: hotelJson.description || ""
      };
    },
  },

  Query: {
    hotelsByIds: async (_, { ids }) => {
      console.log("hotelsByIds");

      if (!ids) return []; 

      var hotels = Array();
      for (const id of ids) {
        var hotelJson = await monolithClient.fetch('/hotels/' + id);
        hotels.push(hotelJson);
      };

      console.log('Got hotels: ' + JSON.stringify(hotels));
      return hotels;
    },
  },  
};

const server = new ApolloServer({
  schema: buildSubgraphSchema([{ typeDefs, resolvers }]),
});

startStandaloneServer(server, {
  listen: { port: 4002 },
}).then(() => {
  console.log('✅ Hotel subgraph ready at http://localhost:4002/');
});
