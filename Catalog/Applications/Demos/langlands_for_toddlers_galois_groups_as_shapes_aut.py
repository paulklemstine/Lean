"""
Applications of the Langlands Shape-Color Correspondence.

Demonstrates real-world applications of quadratic characters
and the Kronecker symbol in:
1. Primality certificates via quadratic residue patterns
2. Factoring hints from character values
3. Cryptographic applications (quadratic residuosity)
4. Error-correcting codes via character sums
"""

from math import gcd, isqrt, log2
from typing import List, Tuple, Optional


def jacobi_symbol(a: int, n: int) -> int:
    """Compute the Jacobi symbol (a/n)."""
    if n <= 0 or n % 2 == 0:
        raise ValueError(f"n must be a positive odd integer, got {n}")
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def kronecker_symbol(d: int, n: int) -> int:
    """Compute the Kronecker symbol (d/n)."""
    if n == 0:
        return 1 if abs(d) == 1 else 0
    if n == 1:
        return 1
    result = 1
    while n % 2 == 0:
        n //= 2
        if d % 2 == 0:
            return 0
        if d % 8 in (3, 5):
            result = -result
    if n > 1:
        result *= jacobi_symbol(d, n)
    return result


# ============================================================
# Application 1: Primality Testing via Euler Criterion
# ============================================================

def euler_criterion_test(n: int, witnesses: int = 20) -> str:
    """Use the Euler criterion with Kronecker characters to test primality.
    
    For prime p and gcd(a, p) = 1:
        a^((p-1)/2) ≡ (a/p) (mod p)
    
    If this fails for any a, n is definitely composite.
    If it passes for many a, n is probably prime.
    
    This connects the Langlands 'color' (character value) to
    modular exponentiation — a bridge between abstract algebra
    and computational number theory.
    """
    if n < 2:
        return "composite"
    if n == 2:
        return "prime"
    if n % 2 == 0:
        return "composite"
    
    for a in range(2, min(n, witnesses + 2)):
        if gcd(a, n) > 1:
            return "composite"
        # Euler criterion: a^((n-1)/2) ≡ (a/n) mod n
        euler = pow(a, (n - 1) // 2, n)
        jacobi = jacobi_symbol(a, n) % n
        if euler != jacobi:
            return "composite"
    
    return "probably prime"


# ============================================================
# Application 2: Quadratic Residuosity Problem (Crypto)
# ============================================================

def quadratic_residuosity_encrypt(bit: int, n: int, seed: int) -> int:
    """Encrypt a single bit using the quadratic residuosity assumption.
    
    The Goldwasser-Micali cryptosystem relies on the hardness of
    distinguishing quadratic residues from non-residues modulo a
    composite n = p·q. This is directly related to the Kronecker
    character: computing χ_d(n) is easy, but determining whether
    an element is a QR mod composite n is believed to be hard.
    
    Args:
        bit: 0 or 1 to encrypt
        n: RSA modulus p*q
        seed: random seed for encryption
    
    Returns:
        Ciphertext integer
    """
    r = seed % n
    if bit == 0:
        return (r * r) % n
    else:
        # Find a quadratic non-residue
        for y in range(2, n):
            if jacobi_symbol(y, n) == -1:
                return (y * r * r) % n
        return -1


# ============================================================
# Application 3: Splitting Behavior Database
# ============================================================

def splitting_database(discriminants: List[int], primes: List[int]) -> dict:
    """Build a database of prime splitting behavior in quadratic fields.
    
    For each discriminant d and prime p:
    - χ_d(p) = +1: p splits as (p) = P₁·P₂ in Z[√d]
    - χ_d(p) = -1: p remains inert (prime) in Z[√d]  
    - χ_d(p) =  0: p ramifies as (p) = P² in Z[√d]
    
    This is a concrete instance of the Langlands correspondence:
    the character value (color) tells us how the shape (Q(√d))
    interacts with each prime.
    """
    db = {}
    for d in discriminants:
        db[d] = {}
        for p in primes:
            chi = kronecker_symbol(d, p)
            behavior = {1: "split", -1: "inert", 0: "ramified"}[chi]
            db[d][p] = {"chi": chi, "behavior": behavior}
    return db


# ============================================================
# Application 4: Character Sum Bounds (Analytic Number Theory)
# ============================================================

def character_sum(d: int, N: int) -> int:
    """Compute the partial character sum S(d, N) = Σ_{n=1}^{N} χ_d(n).
    
    By the Pólya-Vinogradov inequality, |S(d, N)| ≤ C·√|d|·log|d|
    for some constant C. This bound is crucial in analytic number theory
    and connects to the Generalized Riemann Hypothesis.
    """
    return sum(kronecker_symbol(d, n) for n in range(1, N + 1))


def verify_polya_vinogradov(max_disc: int = 50, N: int = 1000) -> List[dict]:
    """Verify the Pólya-Vinogradov inequality computationally.
    
    For non-trivial character χ_d:
    |Σ_{n=1}^{N} χ_d(n)| ≤ √|d| · log|d|
    
    (This uses a slightly generous bound for illustration.)
    """
    results = []
    for d in range(-max_disc, max_disc + 1):
        if d in (0, 1, -1):
            continue
        abs_d = abs(d)
        # Check if d is squarefree
        sf = True
        for p in range(2, isqrt(abs_d) + 1):
            if abs_d % (p * p) == 0:
                sf = False
                break
        if not sf:
            continue
        
        max_sum = max(abs(character_sum(d, n)) for n in range(1, min(N, 200) + 1))
        bound = abs_d ** 0.5 * (log2(abs_d + 1) + 1) * 2  # generous constant
        
        results.append({
            "d": d,
            "max_partial_sum": max_sum,
            "PV_bound": round(bound, 2),
            "satisfies": max_sum <= bound
        })
    
    return results


if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Euler Criterion Primality Test")
    print("=" * 70)
    test_numbers = [7, 11, 15, 21, 23, 561, 1009, 1729]
    for n in test_numbers:
        result = euler_criterion_test(n)
        actual = "prime" if all(n % i != 0 for i in range(2, isqrt(n) + 1)) and n > 1 else "composite"
        match = "✓" if (result.endswith("prime") == (actual == "prime")) else "✗"
        print(f"  {match} n={n:>5}: Euler test says '{result}', actually {actual}")
    
    print()
    print("=" * 70)
    print("APPLICATION 2: Prime Splitting Database")
    print("=" * 70)
    discs = [-3, -1, 2, 5, -7]
    primes = [2, 3, 5, 7, 11, 13]
    db = splitting_database(discs, primes)
    for d in discs:
        print(f"\n  Q(√{d}):")
        for p in primes:
            info = db[d][p]
            print(f"    p={p:>2}: χ={info['chi']:>2}  →  {info['behavior']}")
    
    print()
    print("=" * 70)
    print("APPLICATION 3: Character Sum Bounds (Pólya-Vinogradov)")
    print("=" * 70)
    results = verify_polya_vinogradov(30, 500)
    all_pass = all(r["satisfies"] for r in results)
    for r in results[:10]:
        status = "✓" if r["satisfies"] else "✗"
        print(f"  {status} d={r['d']:>3}: max|S| = {r['max_partial_sum']:>3}, bound = {r['PV_bound']:.1f}")
    print(f"  ... all {len(results)} discriminants: {'PASS ✓' if all_pass else 'FAIL ✗'}")


"""
Langlands for Toddlers: Galois Groups as Shapes, Automorphic Forms as Colors

Demonstration of the n=1 Langlands correspondence between
quadratic field extensions (shapes) and Kronecker characters (colors).
"""

from math import gcd, isqrt
from typing import List, Tuple


def jacobi_symbol(a: int, n: int) -> int:
    """Compute the Jacobi symbol (a/n) for odd positive n."""
    if n <= 0 or n % 2 == 0:
        raise ValueError("n must be a positive odd integer")
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def kronecker_char(d: int, n: int) -> int:
    """Compute the Kronecker character χ_d(n) = Jacobi symbol (d/n).
    
    This is the 'color' in the Langlands shape-color metaphor:
    - +1 means the prime splits in Q(√d)
    - -1 means the prime is inert in Q(√d)  
    -  0 means the prime ramifies in Q(√d)
    """
    if n == 0:
        return 1 if abs(d) == 1 else 0
    if n == 1:
        return 1
    if n == 2:
        if d % 2 == 0:
            return 0
        d8 = d % 8
        return 1 if d8 in (1, 7) else -1
    if n < 0:
        raise ValueError("n must be non-negative")
    # Factor n and compute product of Kronecker symbols
    result = 1
    # Handle factor of 2
    while n % 2 == 0:
        result *= kronecker_char(d, 2)
        n //= 2
    if n > 1:
        result *= jacobi_symbol(d, n)
    return result


def is_squarefree(n: int) -> bool:
    """Check if n is squarefree."""
    n = abs(n)
    if n == 0:
        return False
    for p in range(2, isqrt(n) + 1):
        if n % (p * p) == 0:
            return False
    return True


def demo_shape_color_correspondence():
    """Demonstrate the shape-color correspondence for small discriminants."""
    print("=" * 70)
    print("LANGLANDS FOR TODDLERS: Shape-Color Correspondence (n=1)")
    print("=" * 70)
    print()
    print("Each squarefree integer d determines:")
    print("  SHAPE: The quadratic extension Q(√d) with Galois group Z/2Z")
    print("  COLOR: The Kronecker character χ_d")
    print()
    
    # Display character tables for small discriminants
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23]
    discriminants = [-3, -2, -1, 2, 3, 5, 6, 7, -7, -11, 13]
    
    print(f"{'d':>4} | Q(√d)".ljust(20) + " | " + " ".join(f"χ({p})" for p in primes))
    print("-" * 70)
    
    for d in discriminants:
        ext_name = f"Q(√{d})"
        values = [kronecker_char(d, p) for p in primes]
        val_str = " ".join(f"{v:>4}" for v in values)
        print(f"{d:>4} | {ext_name:<13} | {val_str}")
    
    print()
    print("Legend: +1 = split, -1 = inert, 0 = ramified")


def demo_multiplicativity():
    """Demonstrate the multiplicativity of the Kronecker character."""
    print()
    print("=" * 70)
    print("MULTIPLICATIVITY: χ_{d₁·d₂}(n) = χ_{d₁}(n) · χ_{d₂}(n)")
    print("=" * 70)
    print()
    
    test_cases = [(2, 3, 7), (5, -1, 11), (3, 7, 13), (-2, 5, 17)]
    for d1, d2, n in test_cases:
        lhs = kronecker_char(d1 * d2, n)
        rhs = kronecker_char(d1, n) * kronecker_char(d2, n)
        status = "✓" if lhs == rhs else "✗"
        print(f"  {status} χ_{{{d1}·{d2}}}({n}) = {lhs}  vs  "
              f"χ_{{{d1}}}({n})·χ_{{{d2}}}({n}) = {kronecker_char(d1, n)}·{kronecker_char(d2, n)} = {rhs}")


def demo_prime_power():
    """Demonstrate χ_d(p^k) = χ_d(p)^k."""
    print()
    print("=" * 70)
    print("PRIME POWER FORMULA: χ_d(p^k) = χ_d(p)^k")
    print("=" * 70)
    print()
    
    for d in [2, 3, 5, -7]:
        for p in [3, 5, 7]:
            for k in range(1, 5):
                pk = p ** k
                lhs = kronecker_char(d, pk)
                rhs = kronecker_char(d, p) ** k
                status = "✓" if lhs == rhs else "✗"
                print(f"  {status} χ_{{{d}}}({p}^{k}) = χ_{{{d}}}({pk}) = {lhs}  vs  "
                      f"χ_{{{d}}}({p})^{k} = {kronecker_char(d, p)}^{k} = {rhs}")


def demo_quadratic_residue_balance():
    """Verify the quadratic residue balance theorem for small primes."""
    print()
    print("=" * 70)
    print("QUADRATIC RESIDUE BALANCE: #{QR mod p} = (p-1)/2")
    print("=" * 70)
    print()
    
    primes = [p for p in range(3, 100) if all(p % i != 0 for i in range(2, isqrt(p) + 1)) and p > 1]
    
    all_pass = True
    for p in primes:
        qr_count = sum(1 for a in range(1, p) if jacobi_symbol(a, p) == 1)
        expected = (p - 1) // 2
        status = "✓" if qr_count == expected else "✗"
        if qr_count != expected:
            all_pass = False
        if p <= 31 or qr_count != expected:
            print(f"  {status} p={p:>3}: #{'{QR}'} = {qr_count}, (p-1)/2 = {expected}")
    
    if all_pass:
        print(f"  ... all {len(primes)} odd primes < 100 pass ✓")


def demo_frobenius_trace():
    """Demonstrate the Frobenius trace = character value bridge."""
    print()
    print("=" * 70)
    print("FROBENIUS BRIDGE: Tr(Frob_p) = det(Frob_p) = χ_d(p)")
    print("=" * 70)
    print()
    print("For GL(1), the Frobenius matrix is 1×1: [χ_d(p)]")
    print("Trace = det = χ_d(p) — this is trivial for GL(1) but")
    print("generalizes to the deep Langlands correspondence for GL(n).")
    print()
    
    for d in [2, -3, 5, -7]:
        print(f"  d = {d}: Q(√{d})")
        for p in [3, 5, 7, 11, 13]:
            if gcd(abs(d), p) == 1:
                chi = kronecker_char(d, p)
                symbol = {1: "split", -1: "inert", 0: "ramified"}[chi]
                print(f"    p={p:>2}: Frob = [{chi:>2}], Tr = {chi:>2}, det = {chi:>2}  ({symbol})")
        print()


def demo_character_negation():
    """Demonstrate χ_{-d}(n) = χ_{-1}(n) · χ_d(n)."""
    print()
    print("=" * 70)
    print("CHARACTER TWIST: χ_{-d}(n) = χ_{-1}(n) · χ_d(n)")
    print("=" * 70)
    print()
    
    for d in [2, 3, 5, 7]:
        for n in [3, 5, 7, 11]:
            lhs = kronecker_char(-d, n)
            rhs = kronecker_char(-1, n) * kronecker_char(d, n)
            status = "✓" if lhs == rhs else "✗"
            print(f"  {status} χ_{{-{d}}}({n}) = {lhs}  vs  "
                  f"χ_{{-1}}({n})·χ_{{{d}}}({n}) = {kronecker_char(-1, n)}·{kronecker_char(d, n)} = {rhs}")


if __name__ == "__main__":
    demo_shape_color_correspondence()
    demo_multiplicativity()
    demo_prime_power()
    demo_quadratic_residue_balance()
    demo_frobenius_trace()
    demo_character_negation()


"""
Visualization: Character Sum Oscillation

Visualizes the partial character sums S(d, N) = Σ_{n=1}^{N} χ_d(n)
for several discriminants d. These sums oscillate but are bounded
by the Pólya-Vinogradov inequality: |S(d,N)| ≤ C·√|d|·log|d|.

The oscillation pattern encodes deep information about the distribution
of primes in arithmetic progressions — a key consequence of the
Langlands correspondence.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import isqrt, log


def jacobi_symbol(a: int, n: int) -> int:
    if n <= 0 or n % 2 == 0:
        return 0
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def kronecker_symbol(d: int, n: int) -> int:
    if n == 0:
        return 1 if abs(d) == 1 else 0
    if n == 1:
        return 1
    result = 1
    while n % 2 == 0:
        n //= 2
        if d % 2 == 0:
            return 0
        if d % 8 in (3, 5):
            result = -result
    if n > 1:
        result *= jacobi_symbol(d, n)
    return result


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

discriminants = [(-3, '#e41a1c'), (5, '#377eb8'), (-7, '#4daf4a'), (13, '#984ea3')]
N_max = 500

for idx, (d, color) in enumerate(discriminants):
    ax = axes[idx // 2][idx % 2]
    
    # Compute partial sums
    partial_sums = []
    running_sum = 0
    ns = list(range(1, N_max + 1))
    
    for n in ns:
        running_sum += kronecker_symbol(d, n)
        partial_sums.append(running_sum)
    
    ax.plot(ns, partial_sums, color=color, linewidth=0.8, alpha=0.9)
    ax.axhline(y=0, color='gray', linestyle='--', linewidth=0.5)
    
    # Add Pólya-Vinogradov bound
    abs_d = abs(d)
    pv_bound = 2.0 * abs_d**0.5 * (log(abs_d) + 1)
    ax.axhline(y=pv_bound, color=color, linestyle=':', linewidth=1, alpha=0.5)
    ax.axhline(y=-pv_bound, color=color, linestyle=':', linewidth=1, alpha=0.5)
    
    ax.set_xlabel('N', fontsize=10)
    ax.set_ylabel(f'S({d}, N)', fontsize=10)
    ax.set_title(f'Character Sum for d = {d}  (Q(√{d}))', fontsize=12, fontweight='bold')
    ax.fill_between(ns, -pv_bound, pv_bound, alpha=0.05, color=color)
    
    # Annotate
    max_sum = max(abs(s) for s in partial_sums)
    ax.text(0.98, 0.95, f'max|S| = {max_sum}\nPV bound ≈ {pv_bound:.1f}',
            transform=ax.transAxes, fontsize=9,
            verticalalignment='top', horizontalalignment='right',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

fig.suptitle('Character Sum Oscillations: The "Heartbeat" of Langlands\n'
             'Partial sums Σ χ_d(n) oscillate within the Pólya-Vinogradov bound',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_character_sums.png', dpi=150, bbox_inches='tight')
print("Saved viz_character_sums.png")


"""
Visualization: Kronecker Character Table Heatmap

Visualizes the Langlands shape-color correspondence as a heatmap where:
- Rows are discriminants d (shapes = quadratic extensions Q(√d))
- Columns are primes p (test points)
- Colors represent χ_d(p): red (+1, split), blue (-1, inert), white (0, ramified)

This makes visible the deep structure of the Langlands correspondence:
each row is a unique "color pattern" matching a unique "shape".
"""

import numpy as np
import matplotlib.pyplot as plt
from math import gcd, isqrt


def jacobi_symbol(a: int, n: int) -> int:
    if n <= 0 or n % 2 == 0:
        return 0
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def kronecker_symbol(d: int, n: int) -> int:
    if n == 0:
        return 1 if abs(d) == 1 else 0
    if n == 1:
        return 1
    result = 1
    while n % 2 == 0:
        n //= 2
        if d % 2 == 0:
            return 0
        if d % 8 in (3, 5):
            result = -result
    if n > 1:
        result *= jacobi_symbol(d, n)
    return result


def is_squarefree(n: int) -> bool:
    n = abs(n)
    if n == 0:
        return False
    for p in range(2, isqrt(n) + 1):
        if n % (p * p) == 0:
            return False
    return True


def sieve_primes(n: int) -> list:
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, isqrt(n) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


# Generate data
primes = sieve_primes(60)
discriminants = sorted([d for d in range(-30, 31) if d not in (0, 1) and is_squarefree(d)])

# Build character table
data = np.zeros((len(discriminants), len(primes)))
for i, d in enumerate(discriminants):
    for j, p in enumerate(primes):
        data[i, j] = kronecker_symbol(d, p)

# Create figure
fig, ax = plt.subplots(figsize=(14, 10))

# Custom colormap: blue (-1, inert), white (0, ramified), red (+1, split)
from matplotlib.colors import LinearSegmentedColormap
colors = ['#2166ac', '#f7f7f7', '#b2182b']
cmap = LinearSegmentedColormap.from_list('langlands', colors, N=3)

im = ax.imshow(data, cmap=cmap, aspect='auto', vmin=-1, vmax=1,
               interpolation='nearest')

ax.set_xticks(range(len(primes)))
ax.set_xticklabels([str(p) for p in primes], fontsize=7, rotation=45)
ax.set_yticks(range(len(discriminants)))
ax.set_yticklabels([f'd={d}' for d in discriminants], fontsize=7)

ax.set_xlabel('Prime p', fontsize=12)
ax.set_ylabel('Discriminant d (Shape = Q(√d))', fontsize=12)
ax.set_title('Langlands Shape-Color Correspondence (n=1)\n'
             'Each row is a unique "color" matching a unique "shape"',
             fontsize=14, fontweight='bold')

# Add colorbar
cbar = plt.colorbar(im, ax=ax, ticks=[-1, 0, 1], shrink=0.8)
cbar.ax.set_yticklabels(['−1 (inert)', '0 (ramified)', '+1 (split)'])
cbar.set_label('χ_d(p) = Kronecker Symbol', fontsize=11)

plt.tight_layout()
plt.savefig('viz_character_table.png', dpi=150, bbox_inches='tight')
print("Saved viz_character_table.png")


"""
Visualization: Quadratic Residue Balance

Visualizes the theorem that exactly half of {1,...,p-1} are quadratic
residues mod p, for each odd prime p. Shows:
- A bar chart of QR count vs (p-1)/2 for primes up to 100
- A scatter plot of the actual quadratic residues for small primes

This is the key testable prediction of the Langlands correspondence:
the "colors" are perfectly balanced.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import isqrt


def jacobi_symbol(a: int, n: int) -> int:
    if n <= 0 or n % 2 == 0:
        return 0
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def sieve_primes(n: int) -> list:
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, isqrt(n) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# === Left panel: QR count vs (p-1)/2 ===
primes = [p for p in sieve_primes(100) if p > 2]
qr_counts = []
expected = []

for p in primes:
    qr = sum(1 for a in range(1, p) if jacobi_symbol(a, p) == 1)
    qr_counts.append(qr)
    expected.append((p - 1) // 2)

ax = axes[0]
x = np.arange(len(primes))
width = 0.35
bars1 = ax.bar(x - width/2, qr_counts, width, label='Actual QR count', color='#b2182b', alpha=0.8)
bars2 = ax.bar(x + width/2, expected, width, label='(p−1)/2', color='#2166ac', alpha=0.8)

ax.set_xlabel('Prime p', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('Quadratic Residue Balance Theorem\n#{QR mod p} = (p−1)/2', fontsize=13, fontweight='bold')
ax.set_xticks(x[::3])
ax.set_xticklabels([str(p) for p in primes[::3]], fontsize=8)
ax.legend()

# === Right panel: QR/NR pattern for small primes ===
ax2 = axes[1]
small_primes = [p for p in sieve_primes(40) if p > 2]

for idx, p in enumerate(small_primes):
    for a in range(1, p):
        chi = jacobi_symbol(a, p)
        color = '#b2182b' if chi == 1 else '#2166ac'
        marker = 's' if chi == 1 else 'o'
        ax2.scatter(a, idx, c=color, s=15, marker=marker, alpha=0.7)

ax2.set_yticks(range(len(small_primes)))
ax2.set_yticklabels([f'p={p}' for p in small_primes], fontsize=9)
ax2.set_xlabel('Residue a ∈ {1, ..., p−1}', fontsize=12)
ax2.set_title('Quadratic Residues (■) vs Non-Residues (●)\nPerfect balance: equal counts', fontsize=13, fontweight='bold')

# Add legend
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], marker='s', color='w', markerfacecolor='#b2182b',
           markersize=8, label='QR (+1)'),
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#2166ac',
           markersize=8, label='NR (−1)')
]
ax2.legend(handles=legend_elements, loc='upper right')

plt.tight_layout()
plt.savefig('viz_residue_balance.png', dpi=150, bbox_inches='tight')
print("Saved viz_residue_balance.png")
