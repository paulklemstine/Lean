def tropical_conv(f, g, n):
    """Min-plus convolution: min over k in [0,n] of f(k) + g(n-k)."""
    return min(f[k] + g[n - k] for k in range(n + 1))

# Verify associativity
import math
f = [k*k % 7 + 1 for k in range(20)]
g = [(k+3) % 5 + 2 for k in range(20)]
h = [abs(k-4) + 1 for k in range(20)]

for n in range(15):
    fg = [tropical_conv(f, g, m) for m in range(n+1)]
    gh = [tropical_conv(g, h, m) for m in range(n+1)]
    lhs = tropical_conv(fg, h, n)
    rhs = tropical_conv(f, gh, n)
    assert lhs == rhs, f"Associativity failed at n={n}"
print("Associativity verified for n in [0, 14]")