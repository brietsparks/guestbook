import React, { useState, useEffect } from 'react';
import { useAsync } from 'react-async';
import httpClient from 'superagent';
import moment from 'moment';
import './App.css';

// allows the static CRA app to use runtime environment variables
// @ts-ignore
const apiUrl = window._env.REACT_APP_SERVER_URL;
if (!apiUrl) {
  throw new Error('environment variable REACT_APP_SERVER_URL missing');
}

export default function App() {
  const { data: initialItems, error: loadError } = useAsync({ promiseFn: getItems });
  const [items, setItems] = useState();
  useEffect(() => setItems(initialItems), [setItems, initialItems]);
  const [saveError, setSaveError] = useState();

  const handleNewItem = (item: Item) => {
    const next = [...items];
    next.unshift(item);
    setItems(next);
    setSaveError('');
  }

  return (
    <div id="hero-outer">
      <div id="hero-inner">
        <div id="content">
          <Form onNewItem={handleNewItem} onError={setSaveError}/>

          <div id="items">
            {loadError && !items && <p className="error">Error loading data :(</p>}
            {saveError && <p className="error">Error saving data :(</p>}

            <ol>
            {items?.slice(0, 10).map((item: Item) => (
              <li key={item.ts}>
                <ItemView value={item.value} ts={item.ts} />
              </li>
            ))}
            </ol>
          </div>
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

async function createItem(value: string): Promise<Item> {
  const response = await httpClient
    .post(`${apiUrl}/items`)
    .send({ value });

  return response.body as Item;
}

async function getItems(): Promise<Item[]> {
  const response = await httpClient
    .get(`${apiUrl}/items`)

  return response.body as Item[];
}

interface FormProps {
  onNewItem: (item: Item) => void,
  onError: (value: string) => void,
}

function Form({ onNewItem, onError }: FormProps) {
  const [value, setValue] = useState('');
  const valueIsValid = !!value && value.length <= 280;

  const handleResolve = (item: Item) => {
    setValue('');
    onNewItem(item);
  }

  const { isPending: isSaving, run: save } = useAsync({
    deferFn: ([value]) => createItem(value),
    onResolve: handleResolve,
    onReject: e => onError(e.message),
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
