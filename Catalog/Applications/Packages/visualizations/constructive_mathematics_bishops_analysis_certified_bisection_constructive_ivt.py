import math

def certified_bisection(f, a, b, n):
    """Certified bisection: returns (l, r) with r-l = (b-a)/2^n and f(l)<=0<=f(r)."""
    l, r = a, b
    assert f(a) <= 0 <= f(b), "Sign change required"
    for _ in range(n):
        mid = (l + r) / 2
        if f(mid) <= 0:
            l = mid
        else:
            r = mid
    return l, r, (l + r) / 2

# Example: find sqrt(2)
f = lambda x: x**2 - 2
l, r, mid = certified_bisection(f, 0, 2, 50)
print(f"sqrt(2) approx: {mid:.15f}")
print(f"Actual sqrt(2): {math.sqrt(2):.15f}")
print(f"Error: {abs(mid - math.sqrt(2)):.2e}")
print(f"Interval width: {r - l:.2e}")
print(f"Certificate: f({l}) = {f(l):.2e} <= 0 <= {f(r):.2e} = f({r})")
