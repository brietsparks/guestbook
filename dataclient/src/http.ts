import httpClient from 'superagent';
import { Item } from './types';

export default class DataClient {
  urlBase: string;

  constructor(urlBase: string) {
    this.urlBase = urlBase;
  }

  async createItem(value: string): Promise<Item> {
    const response = await httpClient
      .post(`${this.urlBase}/items`)
      .send({ value });

    return response.body as Item;
  }

  async getItems(): Promise<Item[]> {
    const response = await httpClient
      .get(`${this.urlBase}/items`)

    return response.body as Item[];
  }
}
