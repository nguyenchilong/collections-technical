# Methods To Read Text File
- The `read()` method reads a specified number of characters (or bytes) from a file, or the entire file content if no size is specified.
```python
with open("my_file1.txt", "r") as f:
	content = f.read() #read entire file 
	print(content)
	
# with detail to explain the code
# - f: file object
# - r: mode (read)
# - my_file1.txt: path to the file
# - content: variable that stores the contents of the file
# - print(content): prints the contents of the file
```
- The `readline()` method in Python is employed to sequentially read one line at a time from a file. It returns an empty string when there are no more lines to read.
```Python
with open( "my_file1.txt", "r") as f:
	line1 = f.readline()
	print(line1)
	
	
# with detail to explain the code
# - f: file object
# - r: mode (read)
# - my_file1.txt: path to the file
# - line1: variable that stores the first line of the file
# - print(line1): prints the first line of the file
```
- The `readlines()` method reads all lines from a file, returning them as a list where each element corresponds to a line in the file.
```python
with open("my_file1.txt""r") as f:
	content_1 = f.readlines()
	print(content_1)
	

# with detail to explain the code
# - f: file object
# - r: mode (read)
# - my_file1.txt: path to the file
# - content_1: variable that stores the contents of the file as a list of strings, where each string represents a line in the file
# - print(content_1): prints the contents of the file as a list of strings
```
