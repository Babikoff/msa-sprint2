import { ApolloServer } from '@apollo/server';
import { startStandaloneServer } from '@apollo/server/standalone';
import { buildSubgraphSchema } from '@apollo/subgraph';
import { RestClient } from './rest-client.js';
import NodeCache from 'node-cache';
import gql from 'graphql-tag';

const typeDefs = gql`
  type PromoCode @key(fields: "id") {
    id: ID!
    code: String
    discount: Float
    vipOnly: Boolean
    expired: Boolean
    validUntil: String
    isValid: Boolean
    description: String
  }

  type Query {
    promoCodesByIds(ids: [ID!]!): [PromoCode]
    validatePromoCode(code: String!, hotelId: ID): PromoCode!
  }
`;

var monolithClient = new RestClient('http://monolith:8080/api');

// In-memory cache for Promocodes (by id).
// stdTTL: 300s (5 min) expiration, checkperiod: 60s cleanup interval.
const promoCache = new NodeCache({ stdTTL: 300, checkperiod: 60 });

async function getPromoById(id) {
  const cached = promoCache.get(id);
  if (cached) {
    console.log('Cache hit for promo ' + id);
    return cached;
  }

  const promoJson = await monolithClient.fetch('/promos/' + id);
  console.log('Got promo: ' + JSON.stringify(promoJson));

  // const promoCode = {
  //   id: promoJson.id,
  //   name: promoJson.name || promoJson.description || 'No name',
  //   city: promoJson.city,
  //   stars: promoJson.rating,
  //   description: promoJson.description || ""
  // };

  promoCache.set(id, promoJson);
  console.log('Cached promo ' + id);
  return promoJson;
  //return promoCode;
}

const resolvers = {
  PromoCode: {
    __resolveReference: async ({ id }) => {
      console.log('Resolve promo ' + id);

      if (!id) return null;

      return await getPromoById(id);
    },
  },

  Query: {
    promoCodesByIds: async (_, { ids }) => {
      console.log("promosByIds");

      if (!ids) return [];

      var promos = Array();
      for (const id of ids) {
        try {
          var promo = await getPromoById(id);
          promos.push(promo);
        }
        catch (error) {
          console.error(`Could not load promo for Id: ${id}. Error: ${error}`);
        }
      };

      console.log('Got promos: ' + JSON.stringify(promos));
      return promos;
    },
  },
};

const server = new ApolloServer({
  schema: buildSubgraphSchema([{ typeDefs, resolvers }]),
});

startStandaloneServer(server, {
  listen: { port: 4003 },
}).then(() => {
  console.log('✅ PromoCode subgraph ready at http://localhost:4003/');
});