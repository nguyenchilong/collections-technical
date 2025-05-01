# PYTHON FUNCTION
# A Small. Anonymous Function That Can Be Difined In A Single Line Of Code

"""
Basic Syntax
variable_name = lambda arguments: expression
- variable_name: Name of the variable that holds the lambda function.
- lambda: Keyword used to define a lambda function.
- arguments: Input parameters passed to the lambda function.
- expression: Expression or computation performed on the input arguments.
"""

add = lambda x,y: x + y
result = add (3,4)
print(result) # Output: 7


square = lambda x: x ** 2
result = square(5)
print(result) # Output: 25

# Lambda Function Can Also Be Used As Parameters For Other Functions

"""
map function applies given function to each element of the list
"""
my_list - [1, 2, 3,5]
result - List(map(lambda x: x** 2, my_list))
print(result)
# Output: [1, 4, 9, 16, 25]


"""
filter function creates a list of elements for which function is True
"""
my_list - [1, 2, 3, 4, 5, 6, 7, 8,10]
result = list(filter(lambda x: x & 2 - 0, my_ltst))
print( result)
# Output: [2, 4, 6, 8, 10]


"""
reduce function applies given function to the element of an iterable in a cumulative way, and returns a single value
"""
from functools import reduce
my_list - [1, 2, 3, 4, 5]
result = reduce( lambda x,y: x * y, my list)
print(result)
# Output: 120
