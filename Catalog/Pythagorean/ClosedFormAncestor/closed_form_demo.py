#!/usr/bin/env python3
"""
═══════════════════════════════════════════════════════════════════════════
CLOSED-FORM NESTED PARENT FUNCTION FOR PYTHAGOREAN TRIPLES
═══════════════════════════════════════════════════════════════════════════

MAIN THEOREM (Pell Closed Form for M^n):
The ghost matrix M = B₂⁻¹ = [[1,2,-2],[2,1,-2],[-2,-2,3]] satisfies:

  M^n = [[H², H²-ε, -2PH],
         [H²-ε, H², -2PH],
         [-2PH, -2PH, 2H²-ε]]

where H = compPell(n), P = pell(n), ε = (-1)^n.

This gives a CLOSED FORM for the G-th signed ghost ancestor of any PPT:
  (p_G, q_G, h_G) = M^G · (a, b, c)

APPLICATION: For factoring N via the trivial triple (N, (N²-1)/2, (N²+1)/2),
the ghost parameters p_G(N) ≡ C_G (mod N) where C_G is a universal constant.
Finding gcd(C_G, N) > 1 yields a factor.
"""

from math import gcd, isqrt, log2

# ═══════════════════════════════════════════════════════════════
# CORE SEQUENCES
# ═══════════════════════════════════════════════════════════════

def compPell(n):
    """Half-integer Pell (companion Pell) numbers: 1, 1, 3, 7, 17, 41, 99, 239, 577, ...
    Satisfies: H_{n+1} = 2·H_n + H_{n-1}, with H_0=1, H_1=1.
    Also: H_n = ((1+√2)^n + (1-√2)^n) / 2"""
    if n == 0: return 1
    if n == 1: return 1
    a, b = 1, 1
    for _ in range(n - 1):
        a, b = b, 2*b + a
    return b

def pell(n):
    """Pell numbers: 0, 1, 2, 5, 12, 29, 70, 169, 408, ...
    Satisfies: P_{n+1} = 2·P_n + P_{n-1}, with P_0=0, P_1=1.
    Also: P_n = ((1+√2)^n - (1-√2)^n) / (2√2)"""
    if n == 0: return 0
    if n == 1: return 1
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, 2*b + a
    return b

# ═══════════════════════════════════════════════════════════════
# THE CLOSED FORM
# ═══════════════════════════════════════════════════════════════

def M_pow_entry(n, i, j):
    """
    Closed-form entry of M^n at position (i,j).
    
    M^n = [[H², H²-ε, -2PH],
           [H²-ε, H², -2PH],
           [-2PH, -2PH, 2H²-ε]]
    
    where H = compPell(n), P = pell(n), ε = (-1)^n.
    """
    H = compPell(n)
    P = pell(n)
    eps = (-1)**n
    
    matrix = [
        [H**2,     H**2 - eps, -2*P*H],
        [H**2 - eps, H**2,     -2*P*H],
        [-2*P*H,   -2*P*H,     2*H**2 - eps]
    ]
    return matrix[i][j]

def ghost_ancestor(a, b, c, G):
    """
    THE CLOSED-FORM G-th SIGNED GHOST ANCESTOR.
    
    Returns (p_G, q_G, h_G) where:
      p_G = H²·a + (H²-ε)·b - 2PH·c
      q_G = (H²-ε)·a + H²·b - 2PH·c
      h_G = -2PH·a - 2PH·b + (2H²-ε)·c
    
    with H = compPell(G), P = pell(G), ε = (-1)^G.
    
    Properties:
      - p_G² + q_G² = h_G² (Pythagorean, if input is)
      - p_G - q_G = (-1)^G · (a - b)
      - |p_G| and |q_G| are the legs of the G-th ancestor
    """
    H = compPell(G)
    P = pell(G)
    eps = (-1)**G
    
    p = H**2 * a + (H**2 - eps) * b - 2*P*H * c
    q = (H**2 - eps) * a + H**2 * b - 2*P*H * c
    h = -2*P*H * a - 2*P*H * b + (2*H**2 - eps) * c
    
    return p, q, h

def universal_parent(a, b, c):
    """Single-step universal parent (with absolute values)."""
    p = a + 2*b - 2*c
    q = 2*a + b - 2*c
    h = 3*c - 2*(a + b)
    return abs(p), abs(q), h

def parent_chain(a, b, c, G):
    """Apply universal parent G times (actual chain)."""
    for _ in range(G):
        a, b, c = universal_parent(a, b, c)
    return a, b, c

# ═══════════════════════════════════════════════════════════════
# VERIFICATION
# ═══════════════════════════════════════════════════════════════

print("═" * 70)
print("THEOREM 1: M^n CLOSED FORM VERIFICATION")
print("═" * 70)

# Direct matrix power computation for verification
def mat_mul(A, B):
    n = len(A)
    return [[sum(A[i][k]*B[k][j] for k in range(n)) for j in range(n)] for i in range(n)]

def mat_pow(M, n):
    size = len(M)
    result = [[1 if i==j else 0 for j in range(size)] for i in range(size)]
    base = [row[:] for row in M]
    k = n
    while k > 0:
        if k % 2 == 1:
            result = mat_mul(result, base)
        base = mat_mul(base, base)
        k //= 2
    return result

M_matrix = [[1, 2, -2], [2, 1, -2], [-2, -2, 3]]

all_ok = True
for n in range(20):
    actual = mat_pow(M_matrix, n)
    for i in range(3):
        for j in range(3):
            if actual[i][j] != M_pow_entry(n, i, j):
                print(f"  MISMATCH at n={n}, ({i},{j}): actual={actual[i][j]}, formula={M_pow_entry(n,i,j)}")
                all_ok = False

if all_ok:
    print("✓ Closed form verified for all entries of M^n, n=0..19")
else:
    print("✗ VERIFICATION FAILED")

# Ghost ancestor verification
print(f"\n{'═'*70}")
print("THEOREM 2: GHOST ANCESTOR FORMULA VERIFICATION")
print("═" * 70)

test_triples = [
    (3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25),
    (20, 21, 29), (9, 40, 41), (119, 120, 169), (21, 220, 221)
]

for a, b, c in test_triples:
    if a**2 + b**2 != c**2:
        continue
    ok = True
    for G in range(8):
        p, q, h = ghost_ancestor(a, b, c, G)
        # Verify Pythagorean
        if p**2 + q**2 != h**2:
            print(f"  ({a},{b},{c}) G={G}: NOT PYTHAGOREAN")
            ok = False
        # Verify leg difference
        eps = (-1)**G
        if p - q != eps * (a - b):
            print(f"  ({a},{b},{c}) G={G}: leg difference wrong")
            ok = False
    if ok:
        print(f"✓ ({a},{b},{c}): all ghost ancestors are Pythagorean, leg difference preserved")

# ═══════════════════════════════════════════════════════════════
# DEMO 1: ANCESTRY COMPUTATION
# ═══════════════════════════════════════════════════════════════

print(f"\n{'═'*70}")
print("DEMO: INSTANT ANCESTRY via CLOSED FORM")
print("═" * 70)

def show_ancestry(a, b, c, max_G=10):
    print(f"\nTriple ({a}, {b}, {c}):")
    print(f"{'G':>3} | {'p_G':>15} {'q_G':>15} {'h_G':>15} | {'|p_G|':>10} {'|q_G|':>10} {'PPT':>5}")
    for G in range(max_G):
        p, q, h = ghost_ancestor(a, b, c, G)
        is_ppt = (abs(p) > 0 and abs(q) > 0 and h > 0 and 
                  abs(p)**2 + abs(q)**2 == h**2)
        ppt_str = "✓" if is_ppt else "—"
        print(f"{G:>3} | {p:>15} {q:>15} {h:>15} | {abs(p):>10} {abs(q):>10} {ppt_str:>5}")

show_ancestry(5, 12, 13)
show_ancestry(119, 120, 169, 12)
show_ancestry(9, 40, 41)

# ═══════════════════════════════════════════════════════════════
# DEMO 2: FACTORING via C_G CONSTANTS
# ═══════════════════════════════════════════════════════════════

print(f"\n{'═'*70}")
print("FACTORING VIA UNIVERSAL CONSTANTS C_G")
print("═" * 70)
print("""
KEY THEOREM: For the trivial triple of N, the signed ghost parameter satisfies:
  p_G(N) ≡ C_G (mod N)
where C_G = -(H_G² + 2·P_G·H_G - (-1)^G) / 2 is INDEPENDENT of N.

Therefore: gcd(p_G(N), N) = gcd(C_G, N).

This reduces factoring to: find G such that gcd(C_G, N) > 1.
""")

def C_G_constant(G):
    """The universal constant C_G = -(H² + 2PH - ε) / 2"""
    H = compPell(G)
    P = pell(G)
    eps = (-1)**G
    return -(H**2 + 2*P*H - eps) // 2

# Display C_G values and their factorizations
print("Universal constants C_G:")
for G in range(1, 25):
    C = C_G_constant(G)
    # Factor C
    absC = abs(C)
    factors = []
    temp = absC
    for d in range(2, min(1000, isqrt(absC) + 2)):
        while temp % d == 0:
            factors.append(d)
            temp //= d
    if temp > 1:
        factors.append(temp)
    fstr = " × ".join(str(f) for f in factors[:8])
    if len(factors) > 8:
        fstr += " × ..."
    print(f"  C_{G:>2} = {C:>25} = -{fstr}")

# Factoring demo
print(f"\n{'─'*70}")
print("Factoring demo:")
print(f"{'N':>10} | {'result':>15} | {'G':>3} | {'method':>20}")
print(f"{'─'*10}─┼─{'─'*15}─┼─{'─'*3}─┼─{'─'*20}")

test_numbers = [
    15, 21, 33, 35, 39, 51, 55, 65, 77, 85, 91, 95, 
    119, 143, 187, 209, 221, 247, 299, 323, 377, 391, 
    437, 493, 527, 589, 667, 713, 899, 1073, 1147,
    2021, 3127, 3233, 4891, 7387, 10001, 10403,
    100003, 1000003, 10000019
]

def factor_via_CG(N, max_G=200):
    """Factor N using the C_G constant method."""
    for G in range(1, max_G):
        C = C_G_constant(G)
        g = gcd(abs(C), N)
        if 1 < g < N:
            return g, N // g, G
    return None

# Also try D_G (from q_G mod N)
def D_G_constant(G):
    """q_G ≡ D_G (mod N) where D_G = -(H² + 2PH) / 2 (approximately)"""
    H = compPell(G)
    P = pell(G)
    eps = (-1)**G
    # 2·q_G = (H²-2PH)·N² + 2(H²-ε)·N - (H²+2PH)
    # q_G mod N = -(H²+2PH)/2
    val = -(H**2 + 2*P*H)
    return val // 2 if val % 2 == 0 else None

def factor_via_DG(N, max_G=200):
    """Factor N using the D_G constant method."""
    for G in range(1, max_G):
        D = D_G_constant(G)
        if D is None:
            continue
        g = gcd(abs(D), N)
        if 1 < g < N:
            return g, N // g, G
    return None

# Also: E_G from h_G mod N
def E_G_constant(G):
    """h_G ≡ E_G (mod N)"""
    H = compPell(G)
    P = pell(G)
    eps = (-1)**G
    # h_G = -2PH·(N + (N²-1)/2) + (2H²-ε)·(N²+1)/2
    # 2·h_G = -2PH·(2N+N²-1) + (2H²-ε)(N²+1)
    #       = (2H²-ε-2PH)·N² + (-4PH)·N + (2PH + 2H²-ε)
    # h_G mod N = (2PH + 2H² - ε)/2
    val = 2*P*H + 2*H**2 - eps
    return val // 2 if val % 2 == 0 else None

def factor_combined(N, max_G=200):
    """Factor N using C_G, D_G, and E_G."""
    for G in range(1, max_G):
        for const_fn, label in [(C_G_constant, "C"), (D_G_constant, "D"), (E_G_constant, "E")]:
            val = const_fn(G)
            if val is None:
                continue
            g = gcd(abs(val), N)
            if 1 < g < N:
                return g, N // g, G, f"{label}_{G}"
    return None

for N in test_numbers:
    result = factor_combined(N)
    if result:
        p, q, G, method = result
        print(f"{N:>10} | {p:>6} × {q:<6} | {G:>3} | {method}")
    else:
        print(f"{N:>10} | {'FAIL':>15} |     |")

# ═══════════════════════════════════════════════════════════════
# DEMO 3: COMPARISON WITH ACTUAL PARENT CHAIN
# ═══════════════════════════════════════════════════════════════

print(f"\n{'═'*70}")
print("SIGNED GHOST vs ACTUAL PARENT CHAIN")
print("═" * 70)

print("\nTriple (119, 120, 169) — depth 4 in Berggren tree:")
print(f"{'G':>3} | {'actual parent':>30} | {'|signed ghost|':>30} | {'match':>5}")
for G in range(6):
    actual = parent_chain(119, 120, 169, G)
    p, q, h = ghost_ancestor(119, 120, 169, G)
    signed = (abs(p), abs(q), h)
    match = actual == signed
    print(f"{G:>3} | {str(actual):>30} | {str(signed):>30} | {'✓' if match else '✗':>5}")

# ═══════════════════════════════════════════════════════════════
# DEMO 4: EXPLICIT CLOSED-FORM POLYNOMIALS IN N
# ═══════════════════════════════════════════════════════════════

print(f"\n{'═'*70}")
print("CLOSED-FORM POLYNOMIALS: p_G(N) for trivial triple")
print("═" * 70)

print("""
For trivial triple (N, (N²-1)/2, (N²+1)/2):

  p_G(N) = A_G · N² + B_G · N + C_G

where:
  A_G = (H² - ε - 2PH) / 2
  B_G = H²
  C_G = -(H² + 2PH - ε) / 2
""")

for G in range(1, 12):
    H = compPell(G)
    P = pell(G)
    eps = (-1)**G
    A = (H**2 - eps - 2*P*H) // 2
    B = H**2
    C = -(H**2 + 2*P*H - eps) // 2
    print(f"  G={G:>2}: p_G(N) = {A}·N² + {B}·N + ({C})")

# ═══════════════════════════════════════════════════════════════
# DEMO 5: REVERSE SOLVING
# ═══════════════════════════════════════════════════════════════

print(f"\n{'═'*70}")
print("REVERSE SOLVING: from boundary (3,4,5) back to target")
print("═" * 70)
print("""
Given N, find a Pythagorean triple containing N:
1. Compute trivial triple T = (N, (N²-1)/2, (N²+1)/2)
2. Ascend to root via parent chain
3. At each step, check if gcd with N reveals a factor

The REVERSE direction: start from (3,4,5), descend toward T,
building the triple that contains N.
""")

def find_branch_sequence(a, b, c, max_depth=100):
    """Find the branch encoding (path from root to this triple)."""
    path = []
    for _ in range(max_depth):
        if (a, b, c) == (3, 4, 5):
            return list(reversed(path))
        if c <= 1:
            return None  # not a valid PPT
        p = a + 2*b - 2*c
        q = 2*a + b - 2*c
        if p > 0 and q < 0:
            path.append(1)
        elif p > 0 and q > 0:
            path.append(2)
        elif p < 0 and q > 0:
            path.append(3)
        else:
            return None
        a, b, c = universal_parent(a, b, c)
    return None

print("Branch sequences (path from root):")
for a, b, c in [(5,12,13), (21,20,29), (15,8,17), (7,24,25), (119,120,169), (9,40,41)]:
    if a**2 + b**2 == c**2:
        seq = find_branch_sequence(a, b, c)
        print(f"  ({a},{b},{c}): path = {seq}")

# ═══════════════════════════════════════════════════════════════
# DEMO 6: NEW HYPOTHESIS — PERIODICITY OF FACTORING
# ═══════════════════════════════════════════════════════════════

print(f"\n{'═'*70}")
print("NEW HYPOTHESIS: C_G PERIODICITY MOD PRIMES")
print("═" * 70)
print("""
Since C_G = -(H_G² + 2·P_G·H_G - (-1)^G) / 2 and H, P satisfy 
linear recurrences, C_G mod p is eventually periodic for any prime p.

The period divides the Pisano-like period of the companion Pell 
sequence modulo p. This means:

  ∃ T(p) such that C_{G+T(p)} ≡ C_G (mod p) for all G.

If C_G₀ ≡ 0 (mod p) for some G₀ < T(p), then gcd(C_{G₀}, N) 
will reveal p as a factor of N = p·q.
""")

# Compute periods for small primes
for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
    # Find period of C_G mod p
    residues = []
    for G in range(1, 500):
        residues.append(C_G_constant(G) % p)
    
    # Find period
    period = None
    for T in range(1, len(residues) // 2):
        is_period = True
        for i in range(min(T * 3, len(residues) - T)):
            if residues[i] != residues[i + T]:
                is_period = False
                break
        if is_period:
            period = T
            break
    
    # Find first zero
    first_zero = None
    for G in range(len(residues)):
        if residues[G] == 0:
            first_zero = G + 1  # 1-indexed
            break
    
    zero_str = f"G₀={first_zero}" if first_zero else "no zero"
    print(f"  p={p:>3}: period T(p)={period:>4}, {zero_str}")

# ═══════════════════════════════════════════════════════════════
# DEMO 7: LARGE FACTORING TEST
# ═══════════════════════════════════════════════════════════════

print(f"\n{'═'*70}")
print("LARGE FACTORING TEST")
print("═" * 70)

import time

large_semiprimes = [
    (101, 103), (127, 131), (251, 257), (503, 509),
    (1009, 1013), (2003, 2011), (5003, 5009),
    (10007, 10009), (50021, 50023), (100003, 100019),
]

for p, q in large_semiprimes:
    N = p * q
    t0 = time.time()
    result = factor_combined(N, max_G=500)
    elapsed = time.time() - t0
    if result:
        fp, fq, G, method = result
        print(f"  N={N:>15} ({p}×{q}): factor={fp} at {method}, {elapsed:.4f}s")
    else:
        print(f"  N={N:>15} ({p}×{q}): FAILED in {elapsed:.4f}s")

# ═══════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════

print(f"\n{'═'*70}")
print("SUMMARY OF RESULTS")
print("═" * 70)
print("""
1. CLOSED-FORM M^n: Verified for all n=0..19. Formula:
   M^n = [[H², H²-ε, -2PH], [H²-ε, H², -2PH], [-2PH, -2PH, 2H²-ε]]
   where H=compPell(n), P=pell(n), ε=(-1)^n.

2. G-th GHOST ANCESTOR: Explicit formula for (p_G, q_G, h_G) as
   linear combinations of (a,b,c) with Pell-number coefficients.

3. POLYNOMIAL STRUCTURE: p_G(N) = A_G·N² + B_G·N + C_G for trivial triple.
   Key: p_G(N) ≡ C_G (mod N), so factoring reduces to gcd(C_G, N).

4. PERIODICITY: C_G mod p is periodic with period T(p). If C_G₀ ≡ 0 (mod p)
   for some G₀ ≤ T(p), the factor is found.

5. The method succeeds when T(p) < max_G for at least one prime factor p of N.

OPEN QUESTIONS:
- What fraction of primes p have C_G₀ ≡ 0 for some G₀ ≤ T(p)?
- Is there a number-theoretic characterization of when factoring fails?
- Can the period T(p) be bounded in terms of p?
- Connection to the Pisano period of Pell numbers?
""")
