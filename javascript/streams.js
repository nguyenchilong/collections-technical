// JavaScript 50GB File Upload Technique
const fileInput = document.getELementById('fileInput');
const fileSize = 10 * 1024 * 1024; // 10 MB chunks

fileInput.addEventListener('change', () => {
	const file = fileInput.files[0];
	const reader = file.stream().getReader();
	let uploadedBytes = 0;
	
	reader.read().then(function process({done, value}) {
		if (done)
			return console.log('Upload complete');
		fetch('/upload', {
			method: 'POST',
			headers: {'Content-Range': `bytes ${uploadedBytes}-${uploadedBytes + value.length}/${file.size}`},
			body: value
		}).then(() => {
			uploadedBytes += value.length;
			console.log(`Progress: ${(uploadedBytes / file.size * 100).toFixed(2)}%`);
			reader.read().then(process);
		}).catch(() => console.error('Retrying...') && reader.read().then(process));
	});
});


