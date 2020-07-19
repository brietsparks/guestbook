import httpClient from 'superagent';
import { Item } from './types';

export default class DataClient {
  urlBase: string;

  constructor(urlBase: string) {
    this.urlBase = urlBase;
  }

  async createItem(value: string) {
    const response = await httpClient
      .post(`${this.urlBase}/item`)
      .send({ value });

    return response.body as Item;
  }

  async getItem(id: string) {
    const response = await httpClient
      .get(`${this.urlBase}/item/${id}`)

    return response.body as Item;
  }
}
