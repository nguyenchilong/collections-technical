// No More Nested Try-Catch
async function getData () {
	const [error, response] ?= await fetch('https://api.example.com');
	if (error) return handleError (error);
	return response;
}
