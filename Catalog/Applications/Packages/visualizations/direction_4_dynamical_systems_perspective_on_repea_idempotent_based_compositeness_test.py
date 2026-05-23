def dynamical_compositeness_test(n):
    import math
    for e in range(2, n):
        if pow(e, 2, n) == e:
            factor = math.gcd(e, n)
            if 1 < factor < n:
                return True, f"Found nontrivial idempotent e={e}, factor={factor}"
    return False, f"No nontrivial idempotent found"

# Examples
for n in [7, 13, 15, 21, 91, 561]:
    is_comp, msg = dynamical_compositeness_test(n)
    print(f"n={n}: {msg}")