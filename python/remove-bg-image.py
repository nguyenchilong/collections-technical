# Remove Image Background using Python

from rembg import remove
from PIL import Image
input_path = 'clgot.jpeg'
output_path = 'clgot.png'
inp = Image.open(input_pah)
output = remove(inp)

Image.open('clgot.path')
