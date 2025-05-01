// and yeah Call Stack can definitely store lot of function calls.
// but not infinite calls, Call stack also has his limit to store after that it gives error.

const call = () => {
	console. log("Infinite");
	call();
}

call();

/**
 * If you try to run the code given in previous snippet then you end up with this error.
 *
 * The Maximum Size of call stack exceeded
 * Uncaught RangeError: Maximum call stack size exceeded
 * at call (<anonymous>:2:5)
 * at call (<anonymous>:3:5)
 * at call (<anonymous>:3:5)
 * at call (<anonymous>:3:5)
 * at call (<anonymous>:3:5)
 * at call (<anonymous>:3:5)
 * at call (<anonymous>:3:5)
 * at call (<anonymous>:3:5)
 * at call (<anonymous>:3:5)
 */
