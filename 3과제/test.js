import http from'k6/http';
import { htmlReport } from'https://raw.githubusercontent.com/benc-uk/k6-reporter/main/dist/bundle.js';
import { sleep } from'k6';

const numRecords = 100000;
const baseURL = 'http://ddz9za8yt0vqv.cloudfront.net/v1/token';
let numValue=50001


function getNameForRequest(iteration) {
  const requestNumber = (iteration % numRecords) + 50001;
  return`dump${requestNumber}`;
}
export default function() {
  const iteration = __ITER;
  const nameValue = getNameForRequest(iteration);
  // const url = `${baseURL}?first_name=${nameValue}&last_name=${nameValue}`;
  // http.get(url);  
  const url =baseURL;
  numValue+=1;
  let body = {"emp_no":numValue,"birth_date":"1957-05-02","first_name":"dbdump","last_name":"dbdump","gender":"M","hire_date":"1997-11-30"};
  http.post(url, JSON.stringify(body), {
    headers: { 'Content-Type': 'application/json' }
  })

}

export const options = {
  vus: 100,
  duration: '60s'
};

export function handleSummary(data) {
  return {
    "summary.html": htmlReport(data),
  };
}
