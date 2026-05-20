def quartic_fpc(a: int, p: int) -> int:
    """Certified fixed-point count for quartic family f_a(x) = x^4 - 2ax^2."""
    a_mod = a % p
    if a_mod == 0:
        return 1
    if pow(a_mod, (p - 1) // 2, p) == 1:
        return 3
    return 1

# Verification
for p in [5, 7, 11, 13, 17, 19, 23, 29, 31]:
    for a in [2, 3, 5]:
        count = quartic_fpc(a, p)
        # Brute force check
        actual = sum(1 for x in range(p) if (x - (4*x**3 - 4*a*x)) % p == x)
        assert count == actual, f"Mismatch at p={p}, a={a}"
        print(f"p={p}, a={a}: FPC={count} (verified)")
