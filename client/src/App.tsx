import React, { useState, useEffect, ChangeEvent } from 'react';
import { useAsync } from 'react-async';
import httpClient from 'superagent';
import moment from 'moment';
import { Form, Input, Button, Card, Comment, Typography } from 'antd';

import './App.css';

// allows the static CRA app to use runtime environment variables
// @ts-ignore
const apiUrl = window._env.REACT_APP_SERVER_URL;
if (!apiUrl) {
  throw new Error('environment variable REACT_APP_SERVER_URL missing');
}

export default function App() {
  const { data: initialItems, error: loadError } = useAsync({ promiseFn: getItems });
  const [items, setItems] = useState<Item[]|undefined>();
  useEffect(() => setItems(initialItems), [setItems, initialItems]);
  const [saveError, setSaveError] = useState('');

  const handleNewItem = (item: Item) => {
    const next = items ? [...items] : [];
    next.unshift(item);
    setItems(next);
    setSaveError('');
  }

  return (
    <div id="hero-outer">
      <div id="hero-inner">
        <div id="content">
          <AppForm
            onNewItem={handleNewItem}
            onError={setSaveError}
            errorMessage={saveError ? 'Error saving data :(' : ''}
          />

          <div id="items">
            {loadError &&
            <Typography.Text type="danger" id="load-error">Error loading data :(</Typography.Text>
            }

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
  errorMessage?: string,
}

function AppForm({ onNewItem, onError, errorMessage }: FormProps) {
  const [value, setValue] = useState('');
  const valueIsValid = !!value && value.length <= 280;

  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    setValue(e.target.value);
    onError('');
  };

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
    <Form layout="inline">
      <Form.Item
        validateStatus={!!errorMessage ? 'error' : undefined}
        help={errorMessage}
      >
        <Input
          id="input"
          value={value}
          onChange={handleChange}
        />
      </Form.Item>
      <Form.Item className="form-item-submit">
        <Button
          id="button"
          onClick={handleSubmit}
          loading={isSaving}
          disabled={!valueIsValid || isSaving}
          type="primary"
        >Submit</Button>
      </Form.Item>

    </Form>
  );
}

interface ItemViewProps {
  ts: number,
  value: string
}
function ItemView({ ts, value }: ItemViewProps) {
  const formattedTs = moment(new Date(ts * 1000)).format('M-D-YYYY h:mm a');

  return (
    <Card className="item">
      <Comment
        author={<span>{formattedTs}</span>}
        content={<Typography.Text>{value}</Typography.Text>}
      />
    </Card>
  );
}
