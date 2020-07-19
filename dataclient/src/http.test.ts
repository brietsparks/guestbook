import DataClient from './http';

const urlBase = process.env['SERVER_URL'];
if (!urlBase) {
  console.error('missing environment variable SERVER_URL');
  process.exit(1)
}

const dataClient = new DataClient(urlBase);

describe('testing', () => {
  test('create and retrieve item', async () => {
    const created = await dataClient.createItem('foobar');
    const retrieved = await dataClient.getItem(created.id);

    expect(created.value).toEqual('foobar');
    expect(typeof created.id).toEqual('string');
    expect(typeof created.ts).toEqual('number');
    expect(created).toEqual(retrieved);
  });
});
