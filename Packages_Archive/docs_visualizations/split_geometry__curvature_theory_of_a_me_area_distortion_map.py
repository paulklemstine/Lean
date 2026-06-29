import math

print("Area element = cosh(x)/cosh(y) at grid points:")
print(f"{'':>6}", end="")
for x in range(-4, 5):
    print(f"x={x:+d}     ", end="")
print()
for y in range(4, -5, -1):
    print(f"y={y:+d}  ", end="")
    for x in range(-4, 5):
        ae = math.cosh(x) / math.cosh(y)
        print(f"{ae:8.3f}  ", end="")
    print()
