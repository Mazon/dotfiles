import * as net from 'node:net';
import { pack, UnpackrStream } from 'msgpackr';
import { pipeline } from 'node:stream';

export async function msgpackRpcCall(
  server: string,
  method: string,
  args: any[] = [],
  timeout = 30000
): Promise<any> {
  return new Promise((resolve, reject) => {
    let client: net.Socket;

    const timer = setTimeout(() => {
      client?.destroy();
      reject(new Error(`msgpack-rpc call to ${method} timed out after ${timeout}ms`));
    }, timeout);

    const unpackStream = new UnpackrStream();

    client = net.createConnection(server, () => {
      // msgpack-rpc request: [type=0, msgid, method, args]
      client.write(pack([0, Date.now() % 1000000, method, args]));
    });

    pipeline(client, unpackStream, (err) => {
      if (err) {
        clearTimeout(timer);
        reject(err);
      }
    });

    unpackStream.on('data', (msg: any) => {
      clearTimeout(timer);
      client.end();

      // msgpack-rpc response: [type=1, msgid, error, result]
      if (Array.isArray(msg) && msg[0] === 1) {
        const error = msg[2];
        const result = msg[3];
        if (error !== null && error !== undefined) {
          reject(new Error(typeof error === 'string' ? error : JSON.stringify(error)));
        } else {
          resolve(result);
        }
      } else {
        resolve(msg);
      }
    });
  });
}
