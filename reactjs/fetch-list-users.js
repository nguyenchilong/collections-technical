const fetchUserData = async (userIds) => {
	const requests = userIds.map(id =>
		fetch(`https://api.example.com/user/${id}`)
			.then(response => response.json())
			.catch(error => ({ error: error.message }))
	);
	
	const results = await Promise.allSettled(requests);
	
	const data = results.map(result =>
		result.status === "fulfilled" ? result.value : result.reason
	)
	
	console.log("User Data:", data);
	return data;
}

// Usage
fetchUserData([1, 2, 3, 41]);
