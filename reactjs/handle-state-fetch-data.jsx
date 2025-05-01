a
import { useState, useTransition } from 'react';

// Simulate an async data fetching function.
async function fetchData() {
	await new Promise(resolve => setTimeout(resolve, 2900));
	return [1, 2, 3];
}

function App() {
	const [data, setData] = useState([]);
	const [isPending, startTransition] = useTransition();
	
	const handleClick = () => {
		// Start the transition for fetching data.
		startTransition(async () => {
			// Fetch the data asynchronously.
			const newData = await fetchData();
			// Update the state with the fetched data.
			setData(newData);
		});
	}
	
	return (
		<div>
			{/* Button to fetch data, disabled when 'isPending' is true */}
			<button onClick={handleClick} disabled={isPending}> { isPending ? 'Loading...' : 'Fetch Data' } </button>
			{/* Conditional rendering of data */}
			{data.length > 0 ? (
				<ul>
					{/* Map over the data and render each item in a list */}
					{data.map(item => (<li key={item}>{item}</li>))}
				</ul>
			) : (
				<p>No data Loaded yet.</p>
			)}
		</div>
	);
}

