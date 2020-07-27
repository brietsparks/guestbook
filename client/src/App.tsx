import React, { useState, useEffect } from 'react';
import { useAsync } from 'react-async';
import httpClient from 'superagent';
import moment from 'moment';

import './App.css';

const apiUrl = process.env.REACT_APP_API_URL;
if (!apiUrl) {
  throw new Error('environment variable REACT_APP_API_URL missing');
}

export default function App() {
  const {
    data: initialItems,
    error: loadError,
    // isPending: isLoading // todo
  } = useAsync({ promiseFn: getItems });

  const [items, setItems] = useState();
  useEffect(() => setItems(initialItems), [setItems, initialItems]);

  const handleNewItem = (item: Item) => {
    const next = [...items];
    next.unshift(item);
    setItems(next);
  }

  return (
    <div id="hero-outer">
      <div id="hero-inner">
        <div id="content">
          <Form onNewItem={handleNewItem} />

          {loadError &&
          <p>Error loading data</p>
          }

          <ol id="items">
            {items?.length && items.slice(0, 10).map((item: Item) => (
              <li key={item.ts}>
                <ItemView value={item.value} ts={item.ts} />
              </li>
            ))}
          </ol>
        </div>
      </div>
    </div>
  );
}

export interface Item {
  ip: string,
  value: string,
  ts: number,
}

const delay = (ms: number) => new Promise(res => setTimeout(res, ms));
async function createItem(value: string): Promise<Item> {
  const response = await httpClient
    .post(`${apiUrl}/items`)
    .send({ value });

  await delay(1000)

  return response.body as Item;
}

async function getItems(): Promise<Item[]> {
  const response = await httpClient
    .get(`${apiUrl}/items`)

  return response.body as Item[];
}

interface FormProps {
  onNewItem: (item: Item) => void
}

function Form({ onNewItem }: FormProps) {
  const [value, setValue] = useState('');
  const valueIsValid = !!value && value.length <= 280;

  const handleResolve = (item: Item) => {
    setValue('');
    onNewItem(item);
  }

  const {
    isPending: isSaving,
    error: saveError,
    run: save
  } = useAsync({
    deferFn: ([value]) => createItem(value),
    onResolve: handleResolve,
  });

  const handleSubmit = () => {
    if (valueIsValid) {
      save(value);
    }
  }

  return (
    <div id="form">
      <input
        id="input"
        value={value}
        onChange={e => setValue(e.target.value)}
      />

      <button
        id="button"
        onClick={handleSubmit}
        disabled={!valueIsValid || isSaving}
      >Submit</button>

      {saveError && <p>Oops, an error occurred!</p>}
    </div>
  );
}

interface ItemViewProps {
  ts: number,
  value: string
}
function ItemView({ ts, value }: ItemViewProps) {
  const formattedTs = moment(new Date(ts * 1000)).format('M-D-YYYY h:mm a');

  return (
    <div className="item">
      <p className="ts">{formattedTs}</p>
      <p className="value">{value}</p>
    </div>
  );
}
