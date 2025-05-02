"""
Creating triangle patterns using asterisks (*) is a common Python programming exercise to understand loops, string manipulation, and logic.
Below are four ways to generate a left-aligned triangle
"""
# Method 1: Using nested for loop
rows = 5
for i in range(0, rows):
	for j in range(0, i + 1):
		print("*", end=' ')
	print("\r")

# Method 2: Using a single for loop
rows = 5
for j in range(1, rows + 1):
	print("* " * j)
	
# Method 3: Using nested for loop with reversed order
rows = 5
for i in range(rows + 1, 0, -1):
	for j in range(0, i - 1):
		print("*", end=' ')
	print(" ")

# Method 4: Using recursion
rows = 5
k = 2 * rows - 2
for i in range(rows, -1, -1):
	for j in range (k, 0, -1):
		print(end=" ")
	k = k + 1
	for j in range(0, i + 1):
		print("*", end=" ")
	print("")
