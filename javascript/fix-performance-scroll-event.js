// bad performance
addEventListener('scroll', (e) => {
	if (isInViewport(el)) callback();
})


// best/good performance
new IntersetionObserver(entries => {
	if (entries[0].isIntersecting) callback();
}).observe(el);

