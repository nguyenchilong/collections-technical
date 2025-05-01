// Your Best Friend for Search Inputs

// Your code goes here
const debounce = (func, wait) => {
	let timeout;
	return (...args) => {
		clearTimeout(timeout);
		timeout = setTimeout(() => func(...args), wait);
	}
}

const handleSearch = debounce((searchTerm) => {
	// API call or heavy computation
}, 300);

