// Check for API Support
if (window.PaymentRequest) {
	// Create a PaymentRequest object with the required parameters:
	const paymentMethods = [
		{
			supportedMethods: 'basic-card',
			data: {
				supportedNetworks: ['visa', 'mastercard', 'amex']
			}
		}
	];
	
	const details = {
		displayItems: [
			{ label: 'Item 1', amount: '10.00' },
			{ label: 'Item 2', amount: '15.00' }
		],
		total: {
			label: 'Total',
			amount: '25.00'
		}
	};
	
	const paymentRequest = new PaymentRequest(paymentMethods, details);
	
	// Invoke the show() method to display the payment interface to the user
	paymentRequest.show().then((paymentResponse) => {
		// Process payment here
		console.log(paymentResponse);
		
		// Complete the payment
		paymentResponse.complete('success');
	}).catch((error) => {
		console.error('Payment request failed:', error);
	});
	
	// Handle the Payment Response
	const paymentData = {
		methodName: paymentResponse.methodName,
		details: paymentResponse.details
	};
	
	// Send paymentData to your server for processing
	
	
	// Ensure to complete the payment using the complete() method to inform the browser that the payment process is finished:
	paymentResponse.complete('success'); // or 'fail' depending on the outcome
} else {
	// Fallback for unsupported browsers
	console.log('Fallback for unsupported browsers');
}
