import math

def point_count(a, b, p):
    """Count #E(F_p) for y² = x³ + ax + b."""
    count = 1  # infinity
    for x in range(p):
        rhs = (x**3 + a*x + b) % p
        if rhs == 0:
            count += 1
        elif pow(rhs, (p-1)//2, p) == 1:
            count += 2
    return count

def verify_hasse(a, b, p):
    """Verify Hasse bound and return diagnostics."""
    n = point_count(a, b, p)
    trace = p + 1 - n
    bound = 2 * math.sqrt(p)
    return {"#E": n, "a_p": trace, "2sqrt(p)": round(bound,2),
            "Hasse": abs(trace) <= bound}

# Verify for several primes
for p in [5, 7, 11, 23, 47, 97]:
    r = verify_hasse(1, 1, p)
    print(f"p={p}: {r}")
