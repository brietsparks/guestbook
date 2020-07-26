import DataClient from './http';
import { Item } from './types';

const urlBase = process.env['SERVER_URL'];
if (!urlBase) {
  console.error('missing environment variable SERVER_URL');
  process.exit(1)
}

const dataClient = new DataClient(urlBase);

const randomString = () => Math.random().toString(36).slice(-5);
const delay = (ms: number) => new Promise(res => setTimeout(res, ms));

describe('testing', () => {
  test('create and retrieve item', async () => {
    const values = [...Array(12)].map(randomString);
    const results: Record<number, Item> = {};

    for (let value of values) {
      const created = await dataClient.createItem(value);
      expect(created.value).toEqual(value);
      expect(typeof created.ip).toEqual('string');
      expect(typeof created.ts).toEqual('number');
      results[created.ts] = created;
      await delay(800);
    }

    const retrieved = await dataClient.getItems();
    expect(retrieved.length).toEqual(10);

    const expectedRetrieval = Object.values(results).sort((a, b) => a.ts < b.ts ? 1 : -1).slice(0, 10);
    expect(retrieved).toEqual(expectedRetrieval);
  }, 30000);
});
