// JavaScript ?= operator

async function fetchData() {
	const [fetchError, response] ?= await fetch( 'https://x.com');
  if (fetchError)
		return console.error ("Network error:", fetchError);
	const [jsonError, jsonData] ?= await response.json();
	if (jsonError)
		return console.error ("Parsing error:", jsonError);
	return jsonData;
}

