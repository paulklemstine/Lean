import math

def sech(t): return 1.0 / math.cosh(t)
def K(x, y): return sech(x)**2 - sech(y)**2

extent = 4.0
rows, cols = 25, 60
print("Curvature sign map: + = elliptic (K>0), - = hyperbolic (K<0), 0 = flat")
print()
for j in range(rows):
    y = extent - 2*extent*j/(rows-1)
    line = ""
    for i in range(cols):
        x = -extent + 2*extent*i/(cols-1)
        k = K(x, y)
        if abs(k) < 0.02: line += "0"
        elif k > 0: line += "+"
        else: line += "-"
    print(f"  {line}  y={y:+.1f}")
