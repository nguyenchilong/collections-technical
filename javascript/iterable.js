const iterable = (obj)=> {
	return {
		...obj,
	[Symbol.iterator]: function* () {
		for (const key in obj) {
			yield [key, obj[key]]
		}
	}
}

const objDemo = iterable({name: "Aamir", id:1,designation: "Developer"});

for (const [key, value] of objDemo) {
	console.log(key, value);
}

// name Aamir
// id 1
// designation Developer

