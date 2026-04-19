#!/usr/bin/env python3
"""
Inverted Berggren Tree — Quantum Walks & Error-Correcting Codes Explorer

Explores speculative applications of the inverted Berggren tree:
1. Quantum walks on the Berggren tree
2. Error-correcting codes from ghost triple redundancy
3. p-adic analysis of the ghost matrix
4. Machine learning on Berggren addresses
"""

import numpy as np
from math import gcd, sqrt, isqrt, log2
from collections import Counter

# ═══════════════════════════════════════════════════════════════
# Section 1: Setup
# ═══════════════════════════════════════════════════════════════

M = np.array([[1, 2, -2],
              [2, 1, -2],
              [-2, -2, 3]], dtype=float)

B1 = np.array([[1, -2, 2],
               [2, -1, 2],
               [2, -2, 3]], dtype=float)

B2 = np.array([[1, 2, 2],
               [2, 1, 2],
               [2, 2, 3]], dtype=float)

B3 = np.array([[-1, 2, 2],
               [-2, 1, 2],
               [-2, 2, 3]], dtype=float)

print("=" * 60)
print("QUANTUM WALKS & ERROR-CORRECTING CODES EXPLORER")
print("=" * 60)

# ═══════════════════════════════════════════════════════════════
# Section 2: Quantum Walk on Berggren Tree
# ═══════════════════════════════════════════════════════════════

print("\n1. QUANTUM WALK ON BERGGREN TREE")
print("-" * 40)

# A quantum walk assigns amplitudes α₁, α₂, α₃ to the three branches.
# The walk operator acts on states |v, d⟩ where v is a node and d ∈ {1,2,3} is direction.
# The "coin" operator determines the amplitudes.

# Grover coin (balanced superposition):
coin_grover = 2/3 * np.ones((3,3)) - np.eye(3)
print("Grover coin operator:")
print(np.round(coin_grover, 4))
print(f"Unitary check: CC† = {np.allclose(coin_grover @ coin_grover.T, np.eye(3))}")

# DFT coin:
omega = np.exp(2j * np.pi / 3)
coin_dft = 1/sqrt(3) * np.array([
    [1, 1, 1],
    [1, omega, omega**2],
    [1, omega**2, omega**4]
])
print(f"\nDFT coin is unitary: {np.allclose(coin_dft @ coin_dft.conj().T, np.eye(3))}")

# Simulate quantum walk from root
print("\nSimulating quantum walk (5 steps from root):")
print("Starting state: |root⟩ = (1/√3)(|B1⟩ + |B2⟩ + |B3⟩)")

def generate_ppts(max_c):
    triples = []
    for m in range(2, isqrt(2*max_c)+1):
        for n in range(1, m):
            if (m-n) % 2 == 0 or gcd(m,n) != 1:
                continue
            a, b, c = m*m-n*n, 2*m*n, m*m+n*n
            if c > max_c:
                break
            if a % 2 == 0:
                a, b = b, a
            triples.append((a, b, c))
    return triples

# Build tree structure
def get_children(a, b, c):
    """Get children of (a,b,c) via forward Berggren transforms."""
    c1 = (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
    c2 = (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
    c3 = (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)
    return [c1, c2, c3]

# Generate first few levels
print("\nBerggren tree first 3 levels:")
level = [(3, 4, 5)]
for depth in range(3):
    print(f"  Depth {depth}: {level}")
    next_level = []
    for triple in level:
        next_level.extend(get_children(*triple))
    level = next_level

# Quantum amplitude analysis
print("\nQuantum amplitude distribution (Grover walk, depth 3):")
print("  Each node gets amplitude from coin × transition")
print("  Probability of reaching each depth-3 node via Grover walk:")

# Simple model: amplitude at depth d node = product of coin matrix entries along path
# For Grover coin, each step multiplies by 2/3 (diagonal) or -1/3 (off-diagonal)
paths = [(i, j, k) for i in range(3) for j in range(3) for k in range(3)]
total_prob = 0
for path in paths:
    amp = 1/sqrt(3)  # initial
    for step in path:
        amp *= coin_grover[0, step]  # simplified: just use first row
    prob = abs(amp)**2
    total_prob += prob

print(f"  Total probability (sum): {total_prob:.6f}")
print(f"  Average per node: {total_prob/27:.6f}")

# ═══════════════════════════════════════════════════════════════
# Section 3: Error-Correcting Codes
# ═══════════════════════════════════════════════════════════════

print("\n\n2. ERROR-CORRECTING CODES FROM GHOST TRIPLES")
print("-" * 40)

def ghost_params(a, b, c):
    return (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

print("Six-tuple code: (a, b, c, p, q, h)")
print("Parity check equations:")
print("  H1: a² + b² - c² = 0")
print("  H2: p² + q² - h² = 0")
print("  H3: p - a - 2b + 2c = 0")
print("  H4: q - 2a - b + 2c = 0")
print("  H5: h + 2a + 2b - 3c = 0")
print("  (5 equations, 6 unknowns → rate = 1/6)")

test_triple = (5, 12, 13)
a, b, c = test_triple
p, q, h = ghost_params(a, b, c)
print(f"\nTest codeword: ({a}, {b}, {c}, {p}, {q}, {h})")

# Single-error detection and correction
print("\nSingle-error detection and correction:")
codeword = [a, b, c, p, q, h]
labels = ['a', 'b', 'c', 'p', 'q', 'h']

for pos in range(6):
    for err in [1, -1, 3]:
        corrupted = codeword.copy()
        corrupted[pos] += err

        # Check equations
        a2, b2, c2, p2, q2, h2 = corrupted
        s1 = a2**2 + b2**2 - c2**2
        s3 = p2 - a2 - 2*b2 + 2*c2
        s4 = q2 - 2*a2 - b2 + 2*c2
        s5 = h2 + 2*a2 + 2*b2 - 3*c2

        syndromes = [s1, s3, s4, s5]
        detected = any(s != 0 for s in syndromes)

        # Identify error location
        if s3 != 0 and s4 == 0 and s5 == 0:
            loc = "p"
        elif s3 == 0 and s4 != 0 and s5 == 0:
            loc = "q"
        elif s3 == 0 and s4 == 0 and s5 != 0:
            loc = "h"
        elif s3 != 0 and s4 != 0 and s5 != 0:
            loc = "a,b, or c"
        elif s3 != 0 and s4 != 0 and s5 == 0:
            loc = "ambiguous"
        else:
            loc = "none" if not detected else "unknown"

        if pos == 0 and err == 1:  # just show a few
            print(f"  Error +{err} at {labels[pos]}: syndromes={syndromes}, "
                  f"detected={detected}, location={loc}")

# Error detection rate
print("\n  Error detection rate for single-component errors ±1:")
n_detected = 0
n_total = 0
for pos in range(6):
    for err in range(-5, 6):
        if err == 0:
            continue
        corrupted = codeword.copy()
        corrupted[pos] += err
        a2, b2, c2, p2, q2, h2 = corrupted
        s1 = a2**2 + b2**2 - c2**2
        s3 = p2 - a2 - 2*b2 + 2*c2
        s4 = q2 - 2*a2 - b2 + 2*c2
        s5 = h2 + 2*a2 + 2*b2 - 3*c2
        if any(s != 0 for s in [s1, s3, s4, s5]):
            n_detected += 1
        n_total += 1

print(f"  {n_detected}/{n_total} errors detected = {100*n_detected/n_total:.1f}%")

# ═══════════════════════════════════════════════════════════════
# Section 4: p-adic Analysis
# ═══════════════════════════════════════════════════════════════

print("\n\n3. p-ADIC ANALYSIS")
print("-" * 40)

def val_p(n, p):
    """p-adic valuation of n."""
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v

print("p-adic valuations of ghost matrix entries:")
for prime in [2, 3, 5, 7]:
    vals = [[val_p(int(M[i,j]), prime) for j in range(3)] for i in range(3)]
    print(f"  v_{prime}(M) = {vals}")

print("\np-adic valuations of M^n diagonal entries:")
Mk = np.eye(3, dtype=np.int64)
for n in range(1, 8):
    Mk = Mk @ np.array(M, dtype=np.int64)
    a00 = int(Mk[0, 0])
    print(f"  M^{n}[0,0] = {a00}: v₂={val_p(a00,2)}, v₃={val_p(a00,3)}, v₅={val_p(a00,5)}")

print("\nGhost map modular reduction (mod small primes):")
for prime in [3, 5, 7]:
    M_mod = np.array(M, dtype=int) % prime
    print(f"  M mod {prime} = {M_mod.tolist()}")
    M2_mod = (np.array(M, dtype=int) @ np.array(M, dtype=int)) % prime
    print(f"  M² mod {prime} = {M2_mod.tolist()}")

# ═══════════════════════════════════════════════════════════════
# Section 5: Berggren Zeta Function
# ═══════════════════════════════════════════════════════════════

print("\n\n4. BERGGREN ZETA FUNCTION ζ_B(s) = Σ c^{-s}")
print("-" * 40)

ppts = generate_ppts(50000)
hypotenuses = sorted(set(c for a, b, c in ppts))

for s in [1.0, 1.5, 2.0, 2.5, 3.0]:
    zeta = sum(c**(-s) for a, b, c in ppts)
    print(f"  ζ_B({s:.1f}) = {zeta:.6f} (summed over {len(ppts)} PPTs with c ≤ 50000)")

# Compare with density: PPTs with c ≤ N ~ N/(2π)
print(f"\n  Estimated PPT density: N/(2π) for c ≤ N")
for N in [1000, 5000, 10000, 50000]:
    actual = sum(1 for a, b, c in ppts if c <= N)
    predicted = N / (2 * 3.14159)
    print(f"  N={N}: actual={actual}, N/(2π)={predicted:.0f}, ratio={actual/predicted:.3f}")

# ═══════════════════════════════════════════════════════════════
# Section 6: Berggren Address Feature Analysis
# ═══════════════════════════════════════════════════════════════

print("\n\n5. BERGGREN ADDRESS FEATURE ANALYSIS")
print("-" * 40)

def ghost_step(a, b, c):
    p = a + 2*b - 2*c
    q = 2*a + b - 2*c
    h = -2*a - 2*b + 3*c
    if p > 0 and q < 0:
        return (p, -q, h, 1)
    elif p > 0 and q > 0:
        return (p, q, h, 2)
    elif p < 0 and q > 0:
        return (-p, q, h, 3)
    return None

def berggren_address(a, b, c):
    addr = []
    while (a, b, c) != (3, 4, 5) and (a, b, c) != (4, 3, 5):
        result = ghost_step(a, b, c)
        if result is None:
            break
        a, b, c, br = result
        addr.append(br)
        if len(addr) > 50:
            break
    return addr

ppts_small = generate_ppts(5000)
addresses = [(a, b, c, berggren_address(a, b, c)) for a, b, c in ppts_small]

# Distribution of first branch
first_branch = Counter(addr[0] for a, b, c, addr in addresses if addr)
print("First branch distribution:")
for br in [1, 2, 3]:
    ct = first_branch.get(br, 0)
    print(f"  B{br}: {ct} ({100*ct/sum(first_branch.values()):.1f}%)")

# Address length vs hypotenuse
print("\nAddress length vs log(c):")
for a, b, c, addr in sorted(addresses, key=lambda x: x[2])[:20]:
    print(f"  ({a},{b},{c}): addr={''.join(map(str,addr))}, "
          f"len={len(addr)}, log₂(c)={log2(c):.2f}")

# ═══════════════════════════════════════════════════════════════
# Section 7: Higher-Dimensional Extension (Quadruples)
# ═══════════════════════════════════════════════════════════════

print("\n\n6. PYTHAGOREAN QUADRUPLES a²+b²+c²=d²")
print("-" * 40)

def generate_pquads(max_d):
    """Generate primitive Pythagorean quadruples with d ≤ max_d."""
    quads = []
    for d in range(3, max_d + 1):
        for a in range(1, d):
            for b in range(a, d):
                c2 = d*d - a*a - b*b
                if c2 <= 0:
                    break
                c = isqrt(c2)
                if c*c == c2 and c >= b:
                    if gcd(gcd(a, b), gcd(c, d)) == 1:
                        quads.append((a, b, c, d))
    return quads

quads = generate_pquads(50)
print(f"Primitive Pythagorean quadruples with d ≤ 50: {len(quads)}")
for q in quads[:10]:
    print(f"  {q}: {q[0]}²+{q[1]}²+{q[2]}²={q[0]**2+q[1]**2+q[2]**2}, {q[3]}²={q[3]**2}")

print("\n" + "=" * 60)
print("EXPLORATION COMPLETE")
print("=" * 60)
