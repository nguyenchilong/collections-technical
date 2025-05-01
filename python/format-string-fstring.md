# Format String By f-string

- Convert Float To Integer: `f'{234.1423: .Of}'`
- Output: `"234"`

- Converting Percentage: `f"{25/200: .0%}"`
- Output: `12%`

- Converting Thousands Separator: `f"{12345678:,}"`
- Output: `12,345,678`

- Convert to Hex,Octal,Binary from integer: `f'Int:{42:x}, Oct:{42:0}, Bin: {42:b}'`
- Output: `Int:2a, Oct:52, Bin:101010`

- f-string equal sign = trick: Equal sign to get variable name
  - name = 'Michael'
  - city = 'Chennai'
  - `print(f'{name = } {city = }')`
  - Output: `name = 'Michael' city = 'Chennai'`

