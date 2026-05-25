import math

def parametric_search(k, B):
    for a in range(-B, B + 1):
        for b in range(-B, B + 1):
            if -3 * a * b * (a + b) == k:
                return (a, b, -a - b)
    return None

for k in [-18, -120, 6, 60, 504, -990]:
    result = parametric_search(k, 50)
    if result:
        x, y, z = result
        print(f"k={k}: ({x})^3 + ({y})^3 + ({z})^3 = {x**3+y**3+z**3}")
    else:
        print(f"k={k}: not in family for B=50")
