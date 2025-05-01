# Display Grade and Covert from Bytes to K, M, G Using Python

# Display the Grade
from bisect import bisect

marks = [0, 40, 60, 80]
grade = ['D' ,'C', 'B', 'A']

def display_grade(num):
	idx = bisect(marks, num) - 1
	return f'{grade[idx]} Grade'

display_grade(65)
# Output: 'B Grade'


# How to convert K,M,G from bytes by Python ?
from bisect import bisect

size = [1, 1e+3, 1e+6, 1e+9] # GB
# size = [1, 2**10, 2**20, 2**30] # GiB

unit = ['B', 'K', 'M', 'G']

def convert(byts):
	if byts + 0:
		index = bisect(size, byts) - 1
		return "{:.1f}{}". format(byts/size[index], unit[index])
	else:
		return 'OB'


print(convert(871659564))
# Output: 871.7M
