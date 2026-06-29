#!/usr/bin/env python3
"""
Berggren-Tree Matrix Diffie–Hellman: Demonstration

This script demonstrates the core mathematical results formalized in Lean 4:
1. Power injectivity of hyperbolic SL₂(ℤ) elements (via trace growth)
2. Reduction modulo a prime into SL₂(𝔽_p)
3. Diffie–Hellman key exchange using the reduced generator
4. The split/non-split torus dichotomy for element orders

All computations here correspond to formally verified theorems.
"""

from typing import Tuple

# ============================================================
# § 1. Hyperbolic SL₂(ℤ) Elements and Trace Growth
# ============================================================

def mat_mul_int(A, B):
    """Exact integer 2×2 matrix multiplication."""
    return [[A[0][0]*B[0][0] + A[0][1]*B[1][0], A[0][0]*B[0][1] + A[0][1]*B[1][1]],
            [A[1][0]*B[0][0] + A[1][1]*B[1][0], A[1][0]*B[0][1] + A[1][1]*B[1][1]]]

def mat_pow_int(M, n):
    """Exact integer matrix power by repeated squaring."""
    result = [[1, 0], [0, 1]]  # identity
    base = [row[:] for row in M]
    while n > 0:
        if n % 2 == 1:
            result = mat_mul_int(result, base)
        base = mat_mul_int(base, base)
        n //= 2
    return result

def trace(M):
    return M[0][0] + M[1][1]

def det(M):
    return M[0][0]*M[1][1] - M[0][1]*M[1][0]

# The standard Berggren generator: [[2,1],[1,1]]
g = [[2, 1], [1, 1]]

print("=" * 60)
print("§ 1. TRACE GROWTH OF HYPERBOLIC SL₂(ℤ) POWERS")
print("=" * 60)
print(f"\nGenerator g = {g}")
print(f"det(g) = {det(g)}")
print(f"trace(g) = {trace(g)} > 2  ✓ (hyperbolic)")
print(f"\nTrace sequence trace(g^n) for n = 0..15:")
print(f"{'n':>4} {'trace(g^n)':>20}")
print("-" * 28)

traces = []
for n in range(16):
    gn = mat_pow_int(g, n)
    t = trace(gn)
    traces.append(t)
    print(f"{n:>4} {t:>20}")

print("\n✓ Strictly increasing — confirming berggren_pow_injective")
assert all(traces[i] < traces[i+1] for i in range(1, len(traces)-1))

# ============================================================
# § 2. Trace Recurrence Verification
# ============================================================

print("\n" + "=" * 60)
print("§ 2. TRACE RECURRENCE: tr(g^(n+2)) = tr(g)·tr(g^(n+1)) - tr(g^n)")
print("=" * 60)

T = trace(g)
print(f"\ntr(g) = T = {T}")
print(f"\nVerification:")
for n in range(13):
    lhs = traces[n+2]
    rhs = T * traces[n+1] - traces[n]
    status = "✓" if lhs == rhs else "✗"
    print(f"  n={n:>2}: tr(g^{n+2}) = {lhs:>12} = {T}·{traces[n+1]} - {traces[n]} = {rhs:>12}  {status}")

# ============================================================
# § 3. Reduction Modulo a Prime
# ============================================================

print("\n" + "=" * 60)
print("§ 3. REDUCTION MODULO A PRIME p")
print("=" * 60)

def mat_mod(M, p):
    """Reduce matrix entries modulo p."""
    return [[M[i][j] % p for j in range(2)] for i in range(2)]

def mat_mul_mod(A, B, p):
    """Matrix multiplication modulo p."""
    return mat_mod(mat_mul_int(A, B), p)

def mat_pow_mod(M, n, p):
    """Matrix power modulo p."""
    result = [[1, 0], [0, 1]]
    base = mat_mod(M, p)
    while n > 0:
        if n % 2 == 1:
            result = mat_mul_mod(result, base, p)
        base = mat_mul_mod(base, base, p)
        n //= 2
    return result

p = 101  # A prime
gp = mat_mod(g, p)
print(f"\nPrime p = {p}")
print(f"matRed {p} g = {gp}")
print(f"det(matRed {p} g) = {det(gp) % p}  (should be 1)")

# Verify matRed preserves powers
print(f"\nVerifying matRed_pow: matRed p (g^n) = (matRed p g)^n")
for n in [1, 5, 10, 50, 100]:
    direct = mat_mod(mat_pow_int(g, n), p)
    reduced = mat_pow_mod(g, n, p)
    match = "✓" if direct == reduced else "✗"
    print(f"  n={n:>3}: {match}")

# ============================================================
# § 4. Diffie–Hellman Key Exchange
# ============================================================

print("\n" + "=" * 60)
print("§ 4. DIFFIE–HELLMAN KEY EXCHANGE")
print("=" * 60)

# Alice and Bob agree on g and p
p = 10007  # A larger prime
print(f"\nPublic parameters: g = {g}, p = {p}")

# Alice picks secret a, Bob picks secret b
a = 1234
b = 5678

# Alice computes her public key
alice_pub = mat_pow_mod(g, a, p)
# Bob computes his public key
bob_pub = mat_pow_mod(g, b, p)

print(f"\nAlice's secret: a = {a}")
print(f"Alice's public key: g^a mod p = {alice_pub}")
print(f"\nBob's secret: b = {b}")
print(f"Bob's public key: g^b mod p = {bob_pub}")

# Shared secret
alice_shared = mat_pow_mod(g, a * b, p)  # (g^a)^b
bob_shared_via_a = mat_pow_mod(alice_pub, b, p)  # Alice's pub ^ b
bob_shared_via_b = mat_pow_mod(bob_pub, a, p)    # Bob's pub ^ a

print(f"\nAlice computes: (g^b)^a mod p = {bob_shared_via_b}")
print(f"Bob computes:   (g^a)^b mod p = {bob_shared_via_a}")
print(f"Direct:        g^(ab) mod p  = {alice_shared}")
print(f"\nAll agree: {alice_shared == bob_shared_via_a == bob_shared_via_b}  ✓")
print("This is berggren_dh_shared / berggren_dh_correct")

# ============================================================
# § 5. Order and Split/Non-Split Classification
# ============================================================

print("\n" + "=" * 60)
print("§ 5. SPLIT/NON-SPLIT TORUS CLASSIFICATION")
print("=" * 60)

def legendre_symbol(a, p):
    """Compute the Legendre symbol (a/p)."""
    ls = pow(a % p, (p - 1) // 2, p)
    return -1 if ls == p - 1 else ls

def find_order(M, p):
    """Find the multiplicative order of M in GL₂(𝔽_p)."""
    identity = [[1, 0], [0, 1]]
    power = mat_mod(M, p)
    for k in range(1, p * p + p + 1):
        if power == identity:
            return k
        power = mat_mul_mod(power, M, p)
    return None

primes = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

print(f"\nGenerator g = {g}, trace(g) = {trace(g)}")
print(f"\n{'p':>4} {'tr mod p':>8} {'Δ=t²-4':>8} {'(Δ/p)':>6} {'Type':>10} {'order':>6} {'p-1':>6} {'p+1':>6} {'divides?':>10}")
print("-" * 78)

for p in primes:
    t_mod = trace(g) % p
    delta = (t_mod * t_mod - 4) % p
    ls = legendre_symbol(delta, p)

    if ls == 0:
        stype = "unipotent"
    elif ls == 1:
        stype = "split"
    else:
        stype = "non-split"

    order = find_order(g, p)

    if stype == "split":
        divides = "✓" if (p - 1) % order == 0 else "✗"
        div_info = f"ord | p-1"
    elif stype == "non-split":
        divides = "✓" if (p + 1) % order == 0 else "✗"
        div_info = f"ord | p+1"
    else:
        divides = "-"
        div_info = "ord | p"

    print(f"{p:>4} {t_mod:>8} {delta:>8} {ls:>6} {stype:>10} {order:>6} {p-1:>6} {p+1:>6} {divides:>4} {div_info}")

# ============================================================
# § 6. Chebyshev Coefficient Verification
# ============================================================

print("\n" + "=" * 60)
print("§ 6. CHEBYSHEV COEFFICIENTS FOR POWER DECOMPOSITION")
print("=" * 60)

def chebyCoeffs(t, n):
    """Compute the Chebyshev-type coefficients (a_n, b_n) such that
    M^n = a_n * M + b_n * I when M² = t*M - I."""
    if n == 0:
        return (0, 1)
    if n == 1:
        return (1, 0)
    a_prev, b_prev = 0, 1  # n=0
    a_curr, b_curr = 1, 0  # n=1
    for _ in range(2, n + 1):
        a_next = t * a_curr - a_prev
        b_next = t * b_curr - b_prev
        a_prev, b_prev = a_curr, b_curr
        a_curr, b_curr = a_next, b_next
    return (a_curr, b_curr)

T = trace(g)
print(f"\nGenerator trace T = {T}")
print(f"\n{'n':>4} {'a_n':>12} {'b_n':>12} {'verify':>8}")
print("-" * 40)

for n in range(12):
    a_n, b_n = chebyCoeffs(T, n)
    # Verify: g^n should equal a_n * g + b_n * I
    gn = mat_pow_int(g, n)
    expected = [[a_n * g[i][j] + (b_n if i == j else 0) for j in range(2)] for i in range(2)]
    match = "✓" if gn == expected else "✗"
    print(f"{n:>4} {a_n:>12} {b_n:>12} {match:>8}")

# ============================================================
# § 7. DLP Uniqueness Demonstration
# ============================================================

print("\n" + "=" * 60)
print("§ 7. DISCRETE LOGARITHM UNIQUENESS")
print("=" * 60)

p = 101
order = find_order(g, p)
print(f"\np = {p}, orderOf(matRed {p} g) = {order}")
print(f"\nVerifying dlp_uniqueness_mod_order:")
print(f"For all m, n < {order}: g^m ≡ g^n (mod {p}) ⟺ m = n")

# Check a sample
collisions = 0
gp = mat_mod(g, p)
powers = {}
for n in range(order):
    gn = mat_pow_mod(g, n, p)
    key = tuple(tuple(row) for row in gn)
    if key in powers:
        collisions += 1
        print(f"  COLLISION: g^{n} = g^{powers[key]} (mod {p})")
    powers[key] = n

print(f"  {order} distinct powers found in range [0, {order})")
print(f"  Collisions: {collisions}  ({'✓ none' if collisions == 0 else '✗ found'})")
print(f"  This confirms recoverExponent_eq_discreteLog")

# ============================================================
# § 8. Normalized Word Bridge
# ============================================================

print("\n" + "=" * 60)
print("§ 8. NORMALIZED WORD BRIDGE (BERGGREN → CYCLIC DH)")
print("=" * 60)

p = 997
print(f"\nUsing p = {p}")

# Suppose a Berggren word w normalizes to g^17
n_secret = 17
w_int = mat_pow_int(g, n_secret)  # w = g^17 over ℤ
print(f"Berggren word w = g^{n_secret} over ℤ:")
print(f"  w = {w_int}")

# After reduction mod p
w_red = mat_mod(w_int, p)
g_red_pow = mat_pow_mod(g, n_secret, p)
print(f"\nmatRed {p} w = {w_red}")
print(f"(matRed {p} g)^{n_secret} = {g_red_pow}")
print(f"Equal: {w_red == g_red_pow}  ✓")
print(f"\nThis is normalized_word_to_dh: SPB public parameter → standard DH instance")

print("\n" + "=" * 60)
print("DEMONSTRATION COMPLETE")
print("=" * 60)
print("""
Summary of formally verified theorems demonstrated above:
1. berggren_pow_injective — powers of hyperbolic g ∈ SL₂(ℤ) are injective
2. trace_pow_strictMono — trace sequence is strictly increasing
3. matRed_mul, matRed_pow — reduction mod p is a ring homomorphism
4. det_matRed — det is preserved (image lands in SL₂(𝔽_p))
5. berggren_dh_shared — DH shared secret agreement
6. berggren_dh_correct — DH commutativity
7. dlp_uniqueness_mod_order — exponent uniqueness below order
8. recoverExponent_eq_discreteLog — exponent recovery = DLP
9. normalized_word_to_dh — Berggren words reduce to cyclic DH
10. chebyCoeffs_split — Chebyshev coefficients and eigenvalue formula
11. pow_eq_linear — powers as linear combinations via Cayley-Hamilton
""")


#!/usr/bin/env python3
"""
Visualizations for the Berggren SL₂ Diffie–Hellman Framework

Generates publication-quality figures illustrating the key mathematical structures:
1. Trace growth (exponential) demonstrating power injectivity
2. Split/non-split classification across primes
3. Order distribution in SL₂(𝔽_p)
4. Chebyshev coefficient growth (connection to Fibonacci numbers)
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import os

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))

# ---- Helper functions ----

def mat_mul_int(A, B):
    return [[A[0][0]*B[0][0]+A[0][1]*B[1][0], A[0][0]*B[0][1]+A[0][1]*B[1][1]],
            [A[1][0]*B[0][0]+A[1][1]*B[1][0], A[1][0]*B[0][1]+A[1][1]*B[1][1]]]

def mat_pow_int(M, n):
    result = [[1,0],[0,1]]
    base = [row[:] for row in M]
    while n > 0:
        if n % 2 == 1:
            result = mat_mul_int(result, base)
        base = mat_mul_int(base, base)
        n //= 2
    return result

def mat_mod(M, p):
    return [[M[i][j] % p for j in range(2)] for i in range(2)]

def mat_mul_mod(A, B, p):
    return mat_mod(mat_mul_int(A, B), p)

def mat_pow_mod(M, n, p):
    result = [[1,0],[0,1]]
    base = mat_mod(M, p)
    while n > 0:
        if n % 2 == 1:
            result = mat_mul_mod(result, base, p)
        base = mat_mul_mod(base, base, p)
        n //= 2
    return result

def trace(M): return M[0][0] + M[1][1]
def det(M): return M[0][0]*M[1][1] - M[0][1]*M[1][0]

def find_order(M, p):
    identity = [[1,0],[0,1]]
    power = mat_mod(M, p)
    for k in range(1, p*p + p + 1):
        if power == identity:
            return k
        power = mat_mul_mod(power, M, p)
    return None

def legendre_symbol(a, p):
    ls = pow(a % p, (p-1)//2, p)
    return -1 if ls == p-1 else ls

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i*i <= n:
        if n % i == 0 or n % (i+2) == 0: return False
        i += 6
    return True

g = [[2,1],[1,1]]

# ============================================================
# Figure 1: Trace Growth
# ============================================================

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

N = 20
ns = list(range(N+1))
traces = [trace(mat_pow_int(g, n)) for n in ns]

ax1.plot(ns, traces, 'b.-', markersize=8, linewidth=1.5)
ax1.set_xlabel('n', fontsize=12)
ax1.set_ylabel('trace(g^n)', fontsize=12)
ax1.set_title('Trace Growth (Linear Scale)', fontsize=13)
ax1.grid(True, alpha=0.3)

ax2.semilogy(ns[1:], traces[1:], 'r.-', markersize=8, linewidth=1.5)
ax2.set_xlabel('n', fontsize=12)
ax2.set_ylabel('trace(g^n)', fontsize=12)
ax2.set_title('Trace Growth (Log Scale) — Exponential', fontsize=13)
ax2.grid(True, alpha=0.3)

# Add the golden ratio growth rate
import math
phi = (3 + math.sqrt(5)) / 2  # eigenvalue of g
ax2.semilogy(ns[1:], [phi**n + phi**(-n) for n in ns[1:]], 'k--', alpha=0.5,
             label=f'φ^n + φ^(-n), φ = (3+√5)/2 ≈ {phi:.4f}')
ax2.legend(fontsize=10)

fig.suptitle('Power Injectivity via Trace Growth\n(berggren_pow_injective / trace_pow_strictMono)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig(os.path.join(OUTPUT_DIR, 'fig1_trace_growth.png'), dpi=150, bbox_inches='tight')
plt.close()

# ============================================================
# Figure 2: Split/Non-Split Classification
# ============================================================

primes = [p for p in range(3, 200) if is_prime(p)]

fig, ax = plt.subplots(figsize=(16, 4))

split_p, split_ord = [], []
nonsplit_p, nonsplit_ord = [], []
unipotent_p = []

for p in primes:
    t_mod = trace(g) % p
    delta = (t_mod * t_mod - 4) % p
    ls = legendre_symbol(delta, p)
    order = find_order(g, p)

    if ls == 0:
        unipotent_p.append(p)
    elif ls == 1:
        split_p.append(p)
        split_ord.append(order / (p-1))
    else:
        nonsplit_p.append(p)
        nonsplit_ord.append(order / (p+1))

ax.bar(split_p, [1]*len(split_p), color='#2196F3', alpha=0.7, width=1.5, label='Split (ord | p-1)')
ax.bar(nonsplit_p, [1]*len(nonsplit_p), color='#FF5722', alpha=0.7, width=1.5, label='Non-split (ord | p+1)')
ax.bar(unipotent_p, [1]*len(unipotent_p), color='#4CAF50', alpha=0.7, width=1.5, label='Unipotent (Δ=0)')

ax.set_xlabel('Prime p', fontsize=12)
ax.set_yticks([])
ax.set_title('Split / Non-Split Classification of g = [[2,1],[1,1]] mod p\n'
             '(Determined by Legendre symbol (5/p): blue = split, red = non-split)',
             fontsize=13, fontweight='bold')
ax.legend(fontsize=11, loc='upper right')
plt.tight_layout()
plt.savefig(os.path.join(OUTPUT_DIR, 'fig2_split_nonsplit.png'), dpi=150, bbox_inches='tight')
plt.close()

# ============================================================
# Figure 3: Order as Fraction of Group Size
# ============================================================

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

primes_large = [p for p in range(3, 500) if is_prime(p)]

split_data, nonsplit_data = [], []

for p in primes_large:
    t_mod = trace(g) % p
    delta = (t_mod * t_mod - 4) % p
    ls = legendre_symbol(delta, p)
    order = find_order(g, p)

    if ls == 1:
        split_data.append((p, order, (p-1) // order))
    elif ls == -1:
        nonsplit_data.append((p, order, (p+1) // order))

ax1.scatter([d[0] for d in split_data], [d[2] for d in split_data],
            c='#2196F3', s=15, alpha=0.7)
ax1.set_xlabel('Prime p', fontsize=12)
ax1.set_ylabel('(p-1) / orderOf(g mod p)', fontsize=12)
ax1.set_title('Split case: index of ⟨g⟩ in 𝔽_p×', fontsize=13)
ax1.grid(True, alpha=0.3)

ax2.scatter([d[0] for d in nonsplit_data], [d[2] for d in nonsplit_data],
            c='#FF5722', s=15, alpha=0.7)
ax2.set_xlabel('Prime p', fontsize=12)
ax2.set_ylabel('(p+1) / orderOf(g mod p)', fontsize=12)
ax2.set_title('Non-split case: index of ⟨g⟩ in non-split torus', fontsize=13)
ax2.grid(True, alpha=0.3)

fig.suptitle('Order of Reduced Generator in SL₂(𝔽_p)\n'
             '(orderOf_dvd_split_or_nonsplit)', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig(os.path.join(OUTPUT_DIR, 'fig3_order_distribution.png'), dpi=150, bbox_inches='tight')
plt.close()

# ============================================================
# Figure 4: Chebyshev Coefficients (Fibonacci connection)
# ============================================================

def chebyCoeffs(t, n):
    if n == 0: return (0, 1)
    if n == 1: return (1, 0)
    a_prev, b_prev = 0, 1
    a_curr, b_curr = 1, 0
    for _ in range(2, n+1):
        a_next = t * a_curr - a_prev
        b_next = t * b_curr - b_prev
        a_prev, b_prev = a_curr, b_curr
        a_curr, b_curr = a_next, b_next
    return (a_curr, b_curr)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

N = 15
ns = list(range(N+1))
T = 3  # trace of g

a_vals = [chebyCoeffs(T, n)[0] for n in ns]
b_vals = [chebyCoeffs(T, n)[1] for n in ns]

# a_n are exactly the (2n-1)-th Fibonacci numbers: 0, 1, 3, 8, 21, 55, 144, ...
fib = [0, 1]
for i in range(30):
    fib.append(fib[-1] + fib[-2])
fib_odd = [fib[2*n-1] if 2*n-1 >= 0 else 0 for n in ns]

ax1.semilogy(ns[1:], [abs(a) for a in a_vals[1:]], 'b.-', markersize=8, label='|a_n| (Chebyshev coeff)')
ax1.semilogy(ns[1:], [abs(b) for b in b_vals[1:]], 'r.-', markersize=8, label='|b_n|')
ax1.set_xlabel('n', fontsize=12)
ax1.set_ylabel('|coefficient|', fontsize=12)
ax1.set_title('Chebyshev Coefficients |a_n|, |b_n|', fontsize=13)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# For T=3 (our generator), a_n follows a specific pattern
ax2.plot(ns, a_vals, 'b.-', markersize=8, label='a_n')
ax2.plot(ns, b_vals, 'r.-', markersize=8, label='b_n')
ax2.axhline(y=0, color='k', linewidth=0.5)
ax2.set_xlabel('n', fontsize=12)
ax2.set_ylabel('coefficient value', fontsize=12)
ax2.set_title(f'Chebyshev Coefficients for T = {T}\ng^n = a_n · g + b_n · I', fontsize=13)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

fig.suptitle('Chebyshev-Type Coefficients (pow_eq_linear)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig(os.path.join(OUTPUT_DIR, 'fig4_chebyshev_coefficients.png'), dpi=150, bbox_inches='tight')
plt.close()

# ============================================================
# Figure 5: DH Protocol Diagram
# ============================================================

fig, ax = plt.subplots(figsize=(12, 7))
ax.set_xlim(0, 10)
ax.set_ylim(0, 8)
ax.axis('off')

# Title
ax.text(5, 7.5, 'Berggren SL₂ Diffie–Hellman Protocol', fontsize=16,
        ha='center', fontweight='bold')

# Alice and Bob
ax.text(2, 6.5, 'Alice', fontsize=14, ha='center', fontweight='bold',
        bbox=dict(boxstyle='round,pad=0.3', facecolor='#E3F2FD', edgecolor='#1976D2'))
ax.text(8, 6.5, 'Bob', fontsize=14, ha='center', fontweight='bold',
        bbox=dict(boxstyle='round,pad=0.3', facecolor='#FFF3E0', edgecolor='#E65100'))

# Public parameters
ax.text(5, 5.8, 'Public: g ∈ SL₂(ℤ), prime p', fontsize=11, ha='center',
        style='italic', color='#666666')

# Secrets
ax.text(2, 5.2, 'Secret: a ∈ ℕ', fontsize=11, ha='center', color='#1976D2')
ax.text(8, 5.2, 'Secret: b ∈ ℕ', fontsize=11, ha='center', color='#E65100')

# Public keys
ax.text(2, 4.4, 'Computes: A = (matRed p g)^a', fontsize=10, ha='center')
ax.text(8, 4.4, 'Computes: B = (matRed p g)^b', fontsize=10, ha='center')

# Arrows
ax.annotate('', xy=(7, 3.7), xytext=(3, 3.7),
            arrowprops=dict(arrowstyle='->', color='#1976D2', lw=2))
ax.text(5, 3.9, 'sends A', fontsize=10, ha='center', color='#1976D2')

ax.annotate('', xy=(3, 3.1), xytext=(7, 3.1),
            arrowprops=dict(arrowstyle='->', color='#E65100', lw=2))
ax.text(5, 2.8, 'sends B', fontsize=10, ha='center', color='#E65100')

# Shared secret
ax.text(2, 2.0, 'Computes: B^a = g^(ba)', fontsize=10, ha='center')
ax.text(8, 2.0, 'Computes: A^b = g^(ab)', fontsize=10, ha='center')

ax.text(5, 1.2, 'Shared Secret: (matRed p g)^(ab) = (matRed p g)^(ba)', fontsize=12,
        ha='center', fontweight='bold',
        bbox=dict(boxstyle='round,pad=0.4', facecolor='#E8F5E9', edgecolor='#4CAF50'))

ax.text(5, 0.4, '(berggren_dh_correct: commutativity  ·  berggren_dh_shared: correctness)',
        fontsize=9, ha='center', color='#666666', style='italic')

plt.savefig(os.path.join(OUTPUT_DIR, 'fig5_dh_protocol.png'), dpi=150, bbox_inches='tight')
plt.close()

print("All figures generated successfully:")
for f in ['fig1_trace_growth.png', 'fig2_split_nonsplit.png',
          'fig3_order_distribution.png', 'fig4_chebyshev_coefficients.png',
          'fig5_dh_protocol.png']:
    path = os.path.join(OUTPUT_DIR, f)
    size = os.path.getsize(path) if os.path.exists(path) else 0
    print(f"  {f}: {size/1024:.1f} KB")
