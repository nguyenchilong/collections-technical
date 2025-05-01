/**
- Batch DOM Updates: Use document.createDocumentFragment() to perform multiple updates at once and then append the fragment to the DOM.
- Cache DOM References: Store references to DOM elements that you need to access multiple times.
- Avoid Layout Thrashing: Minimize the number of times you read and write to the DOM. Group read and write operations together.
*/

// code block example
const parentElement = document.getElementById('parent');

// should not use
for (let i = 0; i < 1000; i++) {
  const newElement = document.createElement('div');
  parentElement.appendChild(newElement);
}

// should use
const fragment = document.createDocumentFragment();
for (let i = 0; i < 1000; i++) {
  const newElement = document.createElement('div');
  fragment.appendChild(newElement);
}
parentElement.appendChild(fragment);

