# How To Generate Secure Password?
- Generate Random Passwords using Python.
```Python
from string import ascii_letters,digits
from random import choices

import re

inp = int(input('Enter Password Length more than 4: '))
c = ascii_letters+digits+' #$%&*+-@x?: '
passwds = [''.join(choices(c,k=inp)) for i in range(50)]
rgx = o\We, ‘[a-z]', 'TA-Z]', "\d']
for i in passwds:
	x = len([*filter(Lambda x: re.search(x,i), rgx)])
	if x =4:
		print('Your Secure Password: ',i)
		break

# Output:
# Enter Password Length more than 4: 10
# Your Secure Password: gQ0&EROiRO4
```
- Validate the password.
```Python
import re
st = 'gQ&EROiRO4'

if len(st) >= 7 and len(re.findall(r'\w{2,}',st)) and len(re.findall(r'\d{2,}',st)):
	print('Vaild')
else:
	print('Not Vaild')

# Output: Valid
```
