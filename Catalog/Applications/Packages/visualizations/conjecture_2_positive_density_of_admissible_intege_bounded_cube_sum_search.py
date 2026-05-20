from typing import Optional

def find_cube_root(n: int) -> Optional[int]:
    if n == 0: return 0
    sign = 1 if n > 0 else -1
    a = abs(n)
    z = round(a ** (1/3))
    for c in range(max(0, z-2), z+3):
        if c**3 == a: return sign * c
        if c**3 > a: break
    return None

def bounded_search(k: int, B: int) -> Optional[tuple]:
    for x in range(-B, B+1):
        x3 = x**3
        for y in range(-B, B+1):
            z3 = k - x3 - y**3
            z = find_cube_root(z3)
            if z is not None and abs(z) <= B:
                return (x, y, z)
    return None

# Demo
for k in [2, 3, 10, 17, 29, 42]:
    result = bounded_search(k, 100)
    if result:
        x, y, z = result
        print(f"{k} = {x}^3 + {y}^3 + {z}^3 = {x**3+y**3+z**3}")
    else:
        print(f"{k}: no representation found with B=100")