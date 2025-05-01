/** 
- Use for Loops Instead of forEach: Traditional for loops are generally faster than higher-order functions like forEach.
- Avoid Repeated Calculations: Store the length of the array in a variable instead of recalculating it on each iteration.
- Use Break and Continue Wisely: Use break to exit a loop early and continue to skip unnecessary iterations.
*/

// code example
const array = [1, 2, 3, 4, 5];

// should not use
array.forEach(item => {
  console.log(item);
});

// should use
for (let i = 0, len = array.length; i < len; i++) {
  console.log(array[i]);
}
