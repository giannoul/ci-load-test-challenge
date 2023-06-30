import http from 'k6/http';
import { check, group } from 'k6';
import { textSummary } from 'https://jslib.k6.io/k6-summary/0.0.2/index.js';

export let options = {
   stages: [
       { duration: '0.5m', target: 3 }, // simulate ramp-up of traffic from 1 to 3 virtual users over 0.5 minutes.
       { duration: '0.5m', target: 4}, // stay at 4 virtual users for 0.5 minutes
       { duration: '0.5m', target: 0 }, // ramp-down to 0 users
     ],
};

export default function () {
   group('foo check', () => {
       const response = http.get('http://foo.localhost');
       check(response, {
           'status code should be 200': res => res.status === 200,
       });
   });

   group('bar check', () => {
        const response = http.get('http://bar.localhost');
        check(response, {
            'status code should be 200': res => res.status === 200,
        });
    });
};

export function handleSummary(data) {
    return {
        'stdout': textSummary(data, { indent: ' ', enableColors: false })
      };
}
