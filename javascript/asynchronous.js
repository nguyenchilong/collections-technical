/**
- Use async and await: These keywords make asynchronous code easier to read and maintain.
- Optimize Network Requests: Minimize the number of network requests by combining them when possible.
- Debounce and Throttle Expensive Functions: Limit the rate at which functions are executed to improve performance.
*/

// code example
async function fetchData() {
  try {
    const response = await fetch('https://api.example.com/data');
    const data = await response.json();
    console.log(data);
  } catch (error) {
    console.error('Error:', error);
  }
}

fetchData();



// and Debounce example
function debounce(func, delay) {
  let timeoutId;
  return function(...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => func.apply(this, args), delay);
  };
}

window.addEventListener('resize', debounce(() => {
  console.log('Resized');
}, 300));
