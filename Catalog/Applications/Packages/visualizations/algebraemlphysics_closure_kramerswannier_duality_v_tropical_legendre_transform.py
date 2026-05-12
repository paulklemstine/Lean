#!/usr/bin/env python3
"""Tropical Legendre Transform Algorithms - Self-contained"""

def tropical_legendre(p):
    """L(p)(T) = min_S p(S) - p(T). Complexity: O(|configs|)."""
    m = min(p.values())
    return {t: m - p[t] for t in p}

def dual_tropical_legendre(q):
    """L*(q)(S) = min_T q(T) - q(S). Complexity: O(|configs|)."""
    m = min(q.values())
    return {s: m - q[s] for s in q}

def tropical_bidual(p):
    """p** = L*(L(p)). By theorem: p**(S) = p(S) - max p."""
    return dual_tropical_legendre(tropical_legendre(p))

def normalize(p):
    """Normalize: p_hat(S) = p(S) - p(empty)."""
    p0 = p[frozenset()]
    return {s: p[s] - p0 for s in p}

def certified_reconstruction(B):
    """Reconstruct dual weights from boundary data."""
    g = B[frozenset()]
    w = {s: B[s] - g for s in B}
    return w, g

# Example
configs = []
for i in range(8):
    configs.append(frozenset(j for j in range(3) if i & (1 << j)))

def ising_e(s):
    e = 0
    for i in range(2):
        si = 1 if i in s else -1
        sj = 1 if (i+1) in s else -1
        e -= si * sj
    return e

p = {s: ising_e(s) for s in configs}
lp = tropical_legendre(p)
pp = tropical_bidual(p)

print("Tropical Legendre Transform Demo")
print(f"min(p) = {min(p.values())}, max(p) = {max(p.values())}")
print(f"Bidual = p + ({min(pp.values()) - min(p.values())})")
print(f"Normalized match: {normalize(pp) == normalize(p)}")

w, g = certified_reconstruction(p)
print(f"Reconstruction certified: {all(p[s] == w[s] + g for s in p)}")
