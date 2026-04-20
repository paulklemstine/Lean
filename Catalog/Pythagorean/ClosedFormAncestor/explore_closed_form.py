#!/usr/bin/env python3
"""
Exploration: Closed-Form Nested Parent Function & Factoring Applications

The universal parent of a Pythagorean triple (a,b,c) maps via the ghost triple:
  p = a + 2b - 2c
  q = 2a + b - 2c  
  h = 3c - 2(a+b)
  parent = (|p|, |q|, h)

The "ghost matrix" M = [[1,2,-2],[2,1,-2],[-2,-2,3]] (= B₂⁻¹) governs
the signed iteration. M^n has a closed form via Pell numbers.
"""

import numpy as np
from math import gcd, isqrt, log2
import sys

# ═══════════════════════════════════════════════════════════════
# Section 1: Pell sequences
# ═══════════════════════════════════════════════════════════════

def compPell(n):
    """Companion Pell numbers: 1, 1, 3, 7, 17, 41, 99, 239, 577, 1393, ...
    Recurrence: H_{n+1} = 2·H_n + H_{n-1}, H_0=1, H_1=1"""
    if n == 0: return 1
    if n == 1: return 1
    a, b = 1, 1
    for _ in range(n - 1):
        a, b = b, 2*b + a
    return b

def pell(n):
    """Pell numbers: 0, 1, 2, 5, 12, 29, 70, 169, 408, 985, ...
    Recurrence: P_{n+1} = 2·P_n + P_{n-1}, P_0=0, P_1=1"""
    if n == 0: return 0
    if n == 1: return 1
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, 2*b + a
    return b

M = np.array([[1, 2, -2], [2, 1, -2], [-2, -2, 3]], dtype=object)

def M_pow(n):
    """Compute M^n using fast exponentiation"""
    result = np.eye(3, dtype=object)
    base = M.copy()
    k = n
    while k > 0:
        if k % 2 == 1:
            result = result @ base
        base = base @ base
        k //= 2
    return result

def M_pow_closed(n):
    """Closed form for M^n via Pell numbers"""
    H = compPell(n)
    P = pell(n)
    eps = (-1)**n
    return np.array([
        [H**2,       H**2 - eps, -2*P*H],
        [H**2 - eps, H**2,       -2*P*H],
        [-2*P*H,     -2*P*H,      2*P**2 + eps]
    ], dtype=object)

# ═══════════════════════════════════════════════════════════════
# Section 2: Verify closed form
# ═══════════════════════════════════════════════════════════════

print("═══ VERIFYING M^n CLOSED FORM ═══")
for n in range(15):
    actual = M_pow(n)
    formula = M_pow_closed(n)
    match = np.array_equal(actual, formula)
    H, P = compPell(n), pell(n)
    status = "✓" if match else "✗ MISMATCH"
    print(f"  n={n:>2}: H={H:>6}, P={P:>6}  {status}")
    if not match:
        print(f"    actual:\n{actual}")
        print(f"    formula:\n{formula}")

# ═══════════════════════════════════════════════════════════════
# Section 3: THE CLOSED FORM for f(G)
# ═══════════════════════════════════════════════════════════════

print("\n" + "="*70)
print("THEOREM: CLOSED-FORM G-th SIGNED GHOST ANCESTOR")
print("="*70)
print("""
Given a Pythagorean triple (a, b, c), define the G-th signed ghost:

  (p_G, q_G, h_G) = M^G · (a, b, c)

Then with H_G = compPell(G) and P_G = pell(G), ε = (-1)^G:

  p_G = H_G² · a + (H_G² - ε) · b - 2·P_G·H_G · c
  q_G = (H_G² - ε) · a + H_G² · b - 2·P_G·H_G · c
  h_G = -2·P_G·H_G · (a + b) + (2·P_G² + ε) · c

Beautiful identities:
  p_G - q_G = ε · (a - b)        [parity of leg difference preserved!]
  p_G + q_G = (2H_G² - ε)(a+b) - 4·P_G·H_G · c
""")

# Verify
v = np.array([5, 12, 13], dtype=object)
print("Verification with (5, 12, 13):")
for G in range(6):
    mg = M_pow_closed(G) @ v
    H, P = compPell(G), pell(G)
    eps = (-1)**G
    p_formula = H**2 * 5 + (H**2 - eps) * 12 - 2*P*H * 13
    q_formula = (H**2 - eps) * 5 + H**2 * 12 - 2*P*H * 13
    h_formula = -2*P*H * (5 + 12) + (2*P**2 + eps) * 13
    print(f"  G={G}: ghost=({int(mg[0])}, {int(mg[1])}, {int(mg[2])}), "
          f"formula=({p_formula}, {q_formula}, {h_formula}), "
          f"match={int(mg[0])==p_formula and int(mg[1])==q_formula and int(mg[2])==h_formula}")

# ═══════════════════════════════════════════════════════════════
# Section 4: Factoring via closed-form ghost
# ═══════════════════════════════════════════════════════════════

def trivial_triple(N):
    """Trivial PPT for odd N: (N, (N²-1)/2, (N²+1)/2)"""
    return (N, (N*N - 1) // 2, (N*N + 1) // 2)

def ghost_at_depth_G(N, G):
    """Closed-form ghost parameters at depth G for trivial triple of N"""
    a, b, c = trivial_triple(N)
    H = compPell(G)
    P = pell(G)
    eps = (-1)**G
    p = H**2 * a + (H**2 - eps) * b - 2*P*H * c
    q = (H**2 - eps) * a + H**2 * b - 2*P*H * c
    h = -2*P*H * (a + b) + (2*P**2 + eps) * c
    return p, q, h

def ghost_parent_actual(a, b, c):
    """Actual parent with absolute values"""
    p = a + 2*b - 2*c
    q = 2*a + b - 2*c
    h = 3*c - 2*(a + b)
    return (abs(p), abs(q), h)

print("\n" + "="*70)
print("FACTORING VIA SIGNED GHOST CHAIN")
print("="*70)

def factor_via_signed_ghost(N, max_G=100):
    """Factor N using closed-form ghost parameters"""
    for G in range(1, max_G):
        p, q, h = ghost_at_depth_G(N, G)
        for val in [p, q, h, p+q, p-q]:
            g = gcd(abs(val), N)
            if 1 < g < N:
                return g, N // g, G, 'signed'
    return None

def factor_via_actual_parent(N, max_G=100):
    """Factor N using actual parent chain (with abs at each step)"""
    a, b, c = trivial_triple(N)
    for G in range(max_G):
        for val in [a, b, a+b, abs(a-b)]:
            g = gcd(abs(val), N)
            if 1 < g < N:
                return g, N // g, G, 'actual'
        if c <= 5:
            break
        a, b, c = ghost_parent_actual(a, b, c)
    return None

print("\nComparing signed-ghost vs actual-parent factoring:")
print(f"{'N':>8} {'factors':>10} {'signed_G':>10} {'actual_G':>10}")

test_composites = [15, 21, 33, 35, 39, 51, 55, 57, 65, 77, 85, 91, 
                   143, 221, 323, 437, 667, 899, 1073, 2021, 3233, 
                   10001, 10403, 15251, 100003]

for N in test_composites:
    r1 = factor_via_signed_ghost(N, 50)
    r2 = factor_via_actual_parent(N, 500)
    
    sg = f"{r1[2]}" if r1 else "FAIL"
    ag = f"{r2[2]}" if r2 else "FAIL"
    
    if r1:
        fstr = f"{r1[0]}×{r1[1]}"
    elif r2:
        fstr = f"{r2[0]}×{r2[1]}"
    else:
        fstr = "?"
    
    print(f"{N:>8} {fstr:>10} {sg:>10} {ag:>10}")

# ═══════════════════════════════════════════════════════════════
# Section 5: Algebraic structure of ghost parameters for trivial triple
# ═══════════════════════════════════════════════════════════════

print("\n" + "="*70)
print("ALGEBRAIC STRUCTURE: p_G as polynomial in N")
print("="*70)
print("""
For the trivial triple (N, (N²-1)/2, (N²+1)/2):

  p_G(N) = H² · N + (H² - ε) · (N²-1)/2 - 2PH · (N²+1)/2
         = [(H² - ε)/2 - PH] · N² + H² · N - [(H² - ε)/2 + PH]/2
         = [(H² - ε - 2PH)/2] · N² + H² · N + [(-H² + ε - 2PH)/2] (wrong, redo)

Let me recompute:
  2·p_G = 2H²·N + (H²-ε)(N²-1) - 2PH(N²+1)
        = (H²-ε-2PH)·N² + 2H²·N - (H²-ε) - 2PH
        = (H²-ε-2PH)·N² + 2H²·N - (H²-ε+2PH)

So: p_G = [(H²-ε-2PH)/2]·N² + H²·N - [(H²+2PH-ε)/2]

Similarly for q_G.
""")

for G in range(1, 8):
    H = compPell(G)
    P = pell(G)
    eps = (-1)**G
    
    A = (H**2 - eps - 2*P*H) // 2  # coefficient of N²  
    B = H**2                         # coefficient of N
    # Check A is integer
    assert (H**2 - eps - 2*P*H) % 2 == 0, f"A not integer at G={G}"
    
    C_num = -(H**2 + 2*P*H - eps)    # negative of...
    assert C_num % 2 == 0, f"C not integer at G={G}"
    C = C_num // 2
    
    print(f"G={G}: p_G(N) = {A}·N² + {B}·N + {C}")
    
    # Verify
    for N in [15, 21, 35, 77, 143]:
        p_formula = A * N**2 + B * N + C
        p_direct = ghost_at_depth_G(N, G)[0]
        assert p_formula == p_direct, f"Mismatch at G={G}, N={N}: {p_formula} vs {p_direct}"
    
    # Factor the quadratic: A·N² + B·N + C
    # If N = r·s, then p_G(N) = A·r²·s² + B·r·s + C
    # gcd(p_G(N), N) = gcd(A·r²·s² + B·r·s + C, r·s)
    # p_G(N) mod r = A·0 + B·0 + C mod r = C mod r (if r | N)
    # Wait no: p_G(N) mod r = A·N² + B·N + C mod r = C mod r (since r | N → r | N², r | N)
    # So gcd(p_G(N), N) is nontrivial iff gcd(C, N) is nontrivial!
    print(f"       C = {C} = {A + B + C} - ({A} + {B})")
    if C != 0:
        print(f"       |C| factors: ", end="")
        absC = abs(C)
        factors = []
        for d in range(2, min(100, absC+1)):
            if absC % d == 0:
                factors.append(d)
        print(factors[:10])

print("""
★ KEY DISCOVERY: p_G(N) ≡ C_G (mod N) for any N, where:
  C_G = -(H_G² + 2·P_G·H_G - (-1)^G) / 2

This means gcd(p_G(N), N) = gcd(C_G, N).
The factoring reduces to: does C_G share a factor with N?

Since C_G grows exponentially with G (like (1+√2)^{2G}), eventually
|C_G| > N, and then C_G mod N cycles. The GCD test becomes:
does any C_G (for G = 1, 2, 3, ...) share a nontrivial factor with N?
""")

print("\n═══ C_G VALUES ═══")
for G in range(1, 20):
    H = compPell(G)
    P = pell(G)
    eps = (-1)**G
    C = -(H**2 + 2*P*H - eps) // 2
    print(f"  G={G:>2}: C_G = {C}")

print("\n═══ FACTORING VIA gcd(C_G, N) ═══")
for N in [15, 21, 35, 77, 143, 221, 323, 899, 10001, 100003]:
    found = False
    for G in range(1, 50):
        H = compPell(G)
        P = pell(G)
        eps = (-1)**G
        C = -(H**2 + 2*P*H - eps) // 2
        g = gcd(abs(C), N)
        if 1 < g < N:
            print(f"  N={N:>7}: factor {g} found via gcd(C_{G}, N)")
            found = True
            break
    if not found:
        print(f"  N={N:>7}: no factor via C_G in 50 steps")

# Same for q_G
print("\n═══ q_G ANALYSIS ═══")
for G in range(1, 8):
    H = compPell(G)
    P = pell(G)
    eps = (-1)**G
    
    # q_G = (H²-ε)·N + H²·(N²-1)/2 - 2PH·(N²+1)/2
    # 2·q_G = 2(H²-ε)·N + H²(N²-1) - 2PH(N²+1)
    #       = (H²-2PH)·N² + 2(H²-ε)·N - (H²+2PH)
    
    A = (H**2 - 2*P*H) // 2  # Need to check divisibility
    # Actually: 2·q_G = (H²-2PH)·N² + 2(H²-ε)·N - (H²+2PH)
    
    # q_G mod N: if N | N² and N | N, then q_G mod N = -(H²+2PH)/2 mod N
    D = -(H**2 + 2*P*H) // 2
    
    print(f"G={G}: q_G ≡ {D} (mod N)")

# ═══════════════════════════════════════════════════════════════
# Section 6: Better approach — work modulo a factor p of N
# ═══════════════════════════════════════════════════════════════

print("\n" + "="*70)
print("MODULAR ANALYSIS: What p_G looks like mod a prime factor")
print("="*70)

def analyze_mod_factor(N, p_factor):
    """Analyze what ghost parameters look like mod a factor of N"""
    q_factor = N // p_factor
    print(f"\nN = {N} = {p_factor} × {q_factor}")
    print(f"{'G':>3} | {'p_G mod p':>10} {'q_G mod p':>10} {'h_G mod p':>10} | {'p_G mod q':>10} {'q_G mod q':>10} {'h_G mod q':>10}")
    
    for G in range(1, 15):
        pg, qg, hg = ghost_at_depth_G(N, G)
        print(f"{G:>3} | {pg % p_factor:>10} {qg % p_factor:>10} {hg % p_factor:>10} | {pg % q_factor:>10} {qg % q_factor:>10} {hg % q_factor:>10}")

analyze_mod_factor(15, 3)
analyze_mod_factor(77, 7)
analyze_mod_factor(221, 13)

# ═══════════════════════════════════════════════════════════════
# Section 7: h_G analysis (hypotenuse chain)
# ═══════════════════════════════════════════════════════════════

print("\n" + "="*70)
print("HYPOTENUSE CHAIN ANALYSIS")
print("="*70)

for G in range(1, 8):
    H = compPell(G)
    P = pell(G)
    eps = (-1)**G
    
    # h_G = -2PH·(a+b) + (2P²+ε)·c
    # For trivial triple: a+b = N + (N²-1)/2, c = (N²+1)/2
    # h_G = -2PH·[N + (N²-1)/2] + (2P²+ε)·(N²+1)/2
    # 2·h_G = -2PH·[2N + N²-1] + (2P²+ε)(N²+1)
    #       = -2PH·(N²+2N-1) + (2P²+ε)(N²+1)
    #       = (-2PH+2P²+ε)·N² + (-4PH)·N + (2PH+2P²+ε)
    #       = (2P²-2PH+ε)·N² - 4PH·N + (2P²+2PH+ε)
    
    A2 = 2*P**2 - 2*P*H + eps  # coeff of N² in 2·h_G
    B2 = -4*P*H                 # coeff of N
    C2 = 2*P**2 + 2*P*H + eps  # constant
    
    # h_G mod N: since N | N² and N | N, h_G ≡ C2/2 mod N
    if C2 % 2 != 0:
        continue
    E = C2 // 2
    
    print(f"G={G}: h_G ≡ {E} (mod N), E = (2P²+2PH+ε)/2 = {E}")

# ═══════════════════════════════════════════════════════════════
# Section 8: The connection to reversing f(G)=(0,1,1)
# ═══════════════════════════════════════════════════════════════

print("\n" + "="*70)
print("REVERSE SOLVING: f(G) → (0,1,1) BOUNDARY")
print("="*70)
print("""
The user's key idea: for large enough G, f(G) approaches (0, 1, 1) or (1, 0, 1).
Then REVERSE the parent function to reconstruct the original triple, and
along the way, extract factors.

The forward Berggren matrices are:
  B₁: (a,b,c) → (a-2b+2c, 2a-b+2c, 2a-2b+3c)
  B₂: (a,b,c) → (a+2b+2c, 2a+b+2c, 2a+2b+3c)
  B₃: (a,b,c) → (-a+2b+2c, -2a+b+2c, -2a+2b+3c)

Starting from (1,0,1) [the parent of (3,4,5)]:
  B₁(1,0,1) = (3, 0, 1) — not valid (b=0)
  B₂(1,0,1) = (3, 4, 5) — this is the root!
  B₃(1,0,1) = (3, -2, 1) — not valid

Starting from (3,4,5):
  B₁(3,4,5) = (5, 12, 13)
  B₂(3,4,5) = (21, 20, 29)
  B₃(3,4,5) = (15, 8, 17)
""")

def forward_B1(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def forward_B2(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def forward_B3(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

# Generate some triples and check their trivial triple connection
print("Triples generated from (3,4,5) at each depth:")
current = [(3, 4, 5)]
for depth in range(4):
    print(f"  Depth {depth}: {current}")
    next_level = []
    for t in current:
        next_level.extend([forward_B1(*t), forward_B2(*t), forward_B3(*t)])
    current = next_level

# Check: for N=a (odd leg), does the trivial triple for N appear in the ancestry?
print("\n═══ REVERSE SOLVING EXPERIMENT ═══")
print("For each triple (a,b,c) at depth d, check if trivial(a) exists and its depth:")

def check_trivial_connection(a, b, c):
    """Check if the trivial triple of the odd leg is an ancestor"""
    N = a if a % 2 == 1 else b
    tt = trivial_triple(N)
    # Check if tt is Pythagorean
    if tt[0]**2 + tt[1]**2 != tt[2]**2:
        return None
    # Find depth of tt
    d = 0
    x, y, z = tt
    while d < 100 and (x, y, z) != (3, 4, 5):
        if z <= 1:
            break
        x, y, z = ghost_parent_actual(x, y, z)
        d += 1
    return d if (x, y, z) == (3, 4, 5) else None

triples_to_check = [
    (3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25),
    (20, 21, 29), (9, 40, 41), (12, 35, 37), (11, 60, 61),
    (13, 84, 85), (36, 77, 85), (20, 99, 101),
    (28, 45, 53), (33, 56, 65), (36, 77, 85),
    (48, 55, 73), (39, 80, 89), (65, 72, 97)
]

for a, b, c in triples_to_check:
    if a**2 + b**2 == c**2:
        N = a if a % 2 == 1 else b
        depth = check_trivial_connection(a, b, c)
        if depth is not None:
            print(f"  ({a},{b},{c}): odd_leg={N}, trivial_depth={depth}")

print("\n" + "="*70)
print("COMPLETE — See research paper for full analysis")
print("="*70)
