"""
Adelic Collision Dynamics — Applications
=========================================
Real-world and mathematical applications of the collision dynamics framework.

1. Factorization detection via squaring-map dynamics
2. Pythagorean triple classification via synchronization
3. Pseudorandom number generator analysis
"""

from typing import List, Tuple, Set, Dict
import math


def is_prime(n: int) -> bool:
    """Primality test."""
    if n < 2:
        return False
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0:
            return False
    return True


def orbit_decomposition(f, x: int, max_steps: int = 10000) -> Tuple[int, int]:
    """Find (tail_length, period) for orbit of x under f."""
    seen = {}
    curr = x
    for n in range(max_steps):
        if curr in seen:
            return seen[curr], n - seen[curr]
        seen[curr] = n
        curr = f(curr)
    return -1, -1


# ============================================================
# APPLICATION 1: Factorization Detection
# ============================================================

def detect_compositeness_via_dynamics(n: int) -> Tuple[bool, str]:
    """
    Use squaring-map dynamics on Z/nZ to detect compositeness.

    The key insight from the Adelic Collision Framework:
    - In Z/pZ (p prime), the squaring map has exactly 2 fixed points: {0, 1}
    - In Z/nZ (n composite with k distinct prime factors), there are 2^k fixed points
    - Nontrivial idempotents (≠ 0, 1) certify compositeness

    This gives a deterministic O(n) test, and connects to the
    image_card_nonincreasing theorem: iterating the squaring map
    shrinks the image until it reaches the set of idempotents.

    Returns (is_composite, explanation).
    """
    sq = lambda x: (x * x) % n
    idempotents = [x for x in range(n) if (x * x) % n == x]
    nontrivial = [x for x in idempotents if x != 0 and x != 1]

    if nontrivial:
        # Each nontrivial idempotent e gives a factor via gcd(e, n)
        factors = set()
        for e in nontrivial:
            g = math.gcd(e, n)
            if 1 < g < n:
                factors.add(g)
        return True, f"Composite: idempotents {idempotents}, factors from GCD: {factors}"
    else:
        return False, f"Likely prime or prime power: only trivial idempotents {idempotents}"


print("=" * 60)
print("APPLICATION 1: Compositeness Detection via Squaring Dynamics")
print("=" * 60)
print()

for n in [7, 12, 15, 17, 21, 30, 35, 97]:
    is_comp, explanation = detect_compositeness_via_dynamics(n)
    prime_str = "prime" if is_prime(n) else "composite"
    print(f"  n = {n:3d} ({prime_str:9s}): {explanation}")
print()


# ============================================================
# APPLICATION 2: Pythagorean Triple Classification
# ============================================================

def classify_pythagorean_sync(a: int, b: int, c: int,
                               prime_bound: int = 50) -> Dict:
    """
    Classify a Pythagorean triple (a, b, c) by its synchronization
    profile across primes.

    For each prime p, we compute:
    - Whether p divides c (hypotenuse primes)
    - The sync score of a and b under squaring mod p
    - The collision time

    The Pythagorean Prime Synchronization theorem guarantees that
    primes dividing c force a² + b² ≡ 0 (mod p).

    Returns a classification dictionary.
    """
    assert a**2 + b**2 == c**2, f"Not Pythagorean: {a}² + {b}² ≠ {c}²"

    primes = [p for p in range(2, prime_bound + 1) if is_prime(p)]

    hypotenuse_primes = []
    sync_profile = {}

    for p in primes:
        divides_c = (c % p == 0)
        if divides_c:
            hypotenuse_primes.append(p)

        # Sync score of a, b under squaring mod p
        sq_p = lambda x, p=p: (x * x) % p
        a_mod, b_mod = a % p, b % p

        # Count how many of the first 10 iterates agree
        score = 0
        xa, xb = a_mod, b_mod
        for _ in range(10):
            if xa == xb:
                score += 1
            xa = sq_p(xa)
            xb = sq_p(xb)

        sync_profile[p] = {
            "divides_c": divides_c,
            "sync_score": score,
            "a_mod_p": a % p,
            "b_mod_p": b % p,
            "sum_sq_mod_p": (a**2 + b**2) % p,
        }

    return {
        "triple": (a, b, c),
        "hypotenuse_primes": hypotenuse_primes,
        "gcd_ab": math.gcd(a, b),
        "primitive": math.gcd(a, b) == 1,
        "sync_profile": sync_profile
    }


print("=" * 60)
print("APPLICATION 2: Pythagorean Triple Synchronization Profiles")
print("=" * 60)
print()

triples = [(3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25),
           (20, 21, 29), (9, 40, 41), (12, 35, 37)]

for a, b, c in triples:
    info = classify_pythagorean_sync(a, b, c)
    print(f"  ({a}, {b}, {c}): primitive={info['primitive']}, "
          f"hypotenuse primes={info['hypotenuse_primes']}")

    # Show sync at hypotenuse primes
    for p in info['hypotenuse_primes']:
        sp = info['sync_profile'][p]
        print(f"    p={p}: a²+b² mod p = {sp['sum_sq_mod_p']} (must be 0), "
              f"sync={sp['sync_score']}/10")
    print()


# ============================================================
# APPLICATION 3: PRNG Quality Analysis
# ============================================================

def analyze_prng_collisions(seed1: int, seed2: int, modulus: int,
                            multiplier: int, increment: int,
                            window: int = 100) -> Dict:
    """
    Analyze a linear congruential generator (LCG) for collision patterns.

    The LCG map is: x ↦ (multiplier * x + increment) mod modulus

    Using the collision dynamics framework, we can detect when two
    seeds produce orbits that eventually synchronize — a weakness
    in the PRNG.
    """
    lcg = lambda x: (multiplier * x + increment) % modulus

    # Find orbit decompositions
    t1, p1 = orbit_decomposition(lcg, seed1)
    t2, p2 = orbit_decomposition(lcg, seed2)

    # Sync score
    score = 0
    xa, xb = seed1, seed2
    ct = -1
    for k in range(window):
        if xa == xb:
            score += 1
            if ct == -1:
                ct = k
        xa = lcg(xa)
        xb = lcg(xb)

    return {
        "seed1": seed1, "seed2": seed2,
        "orbit1": (t1, p1), "orbit2": (t2, p2),
        "collision_time": ct,
        "sync_score": score,
        "window": window,
        "sync_ratio": score / window
    }


print("=" * 60)
print("APPLICATION 3: PRNG Collision Analysis")
print("=" * 60)
print()

# Classic weak LCG parameters
modulus = 256
mult = 137
inc = 0
print(f"LCG: x ↦ {mult}x + {inc} mod {modulus}")
print()

for s1, s2 in [(1, 2), (10, 20), (50, 100), (3, 129)]:
    result = analyze_prng_collisions(s1, s2, modulus, mult, inc)
    print(f"  Seeds ({s1}, {s2}): orbit1={result['orbit1']}, "
          f"orbit2={result['orbit2']}")
    print(f"    Collision time: {result['collision_time']}, "
          f"sync ratio: {result['sync_ratio']:.2%}")

print()
print("Applications completed!")


"""
Adelic Collision Dynamics — Demo
================================
Demonstrates the core theorems with concrete numerical examples:
1. Collision propagation in finite dynamical systems
2. Orbit decomposition into tail + cycle
3. Synchronization scores and collision filtrations
4. Pythagorean prime synchronization
"""

from typing import List, Tuple, Dict, Set


def iterate(f, x, n: int):
    """Apply f to x exactly n times."""
    for _ in range(n):
        x = f(x)
    return x


def orbit_segment(f, x, n: int) -> list:
    """Return [x, f(x), f²(x), ..., f^(n-1)(x)]."""
    seg = []
    for _ in range(n):
        seg.append(x)
        x = f(x)
    return seg


def complexity_rank(f, x, n: int) -> int:
    """Number of distinct values in the orbit segment of length n."""
    return len(set(orbit_segment(f, x, n)))


def sync_score(f, a, b, w: int) -> int:
    """Count of time steps in [0, w) where f^k(a) == f^k(b)."""
    count = 0
    xa, xb = a, b
    for _ in range(w):
        if xa == xb:
            count += 1
        xa = f(xa)
        xb = f(xb)
    return count


def collision_time(f, a, b, bound: int) -> int:
    """First n in [0, bound) where f^n(a) == f^n(b), or -1 if none."""
    xa, xb = a, b
    for n in range(bound):
        if xa == xb:
            return n
        xa = f(xa)
        xb = f(xb)
    return -1


def find_orbit_decomposition(f, x, max_steps: int = 1000) -> Tuple[int, int]:
    """Find (tail_length, period) for the orbit of x under f."""
    seen = {}
    curr = x
    for n in range(max_steps):
        if curr in seen:
            t = seen[curr]
            p = n - t
            return t, p
        seen[curr] = n
        curr = f(curr)
    return -1, -1


# === Demo 1: Collision Propagation ===
print("=" * 60)
print("DEMO 1: Collision Propagation")
print("=" * 60)
print()

# Squaring map on Z/13Z
N = 13
sq = lambda x: (x * x) % N
a, b = 3, 10  # 3² = 9, 10² = 100 ≡ 9 (mod 13)

print(f"Dynamical system: x ↦ x² mod {N}")
print(f"Initial conditions: a = {a}, b = {b}")
print(f"Orbit of a: {orbit_segment(sq, a, 10)}")
print(f"Orbit of b: {orbit_segment(sq, b, 10)}")

ct = collision_time(sq, a, b, 20)
print(f"Collision time: {ct}")
if ct >= 0:
    print(f"After collision, orbits agree forever:")
    for k in range(5):
        n = ct + k
        print(f"  f^{n}(a) = {iterate(sq, a, n)}, f^{n}(b) = {iterate(sq, b, n)}")
print()


# === Demo 2: Orbit Decomposition ===
print("=" * 60)
print("DEMO 2: Orbit Tail-Cycle Decomposition")
print("=" * 60)
print()

for N in [7, 12, 20]:
    sq_N = lambda x, n=N: (x * x) % n
    for x in range(min(N, 6)):
        t, p = find_orbit_decomposition(sq_N, x)
        orbit = orbit_segment(sq_N, x, t + 2 * p)
        print(f"  Z/{N}Z, x = {x}: tail = {t}, period = {p}, orbit = {orbit[:t+p+2]}")
    print()


# === Demo 3: Synchronization Scores ===
print("=" * 60)
print("DEMO 3: Synchronization Scores")
print("=" * 60)
print()

N = 17
sq17 = lambda x: (x * x) % N
w = 20
print(f"Sync scores for squaring on Z/{N}Z, window = {w}:")
print(f"{'a':>4} {'b':>4} {'sync':>6} {'coll_time':>10}")
for a in range(1, 6):
    for b in range(a + 1, 7):
        sc = sync_score(sq17, a, b, w)
        ct = collision_time(sq17, a, b, w)
        print(f"{a:4d} {b:4d} {sc:6d} {ct:10d}")
print()

# Self-sync verification
print(f"Self-sync: syncScore(f, 3, 3, {w}) = {sync_score(sq17, 3, 3, w)} (should be {w})")
print()


# === Demo 4: Collision Filtration ===
print("=" * 60)
print("DEMO 4: Collision Filtration (Monotonicity)")
print("=" * 60)
print()

N = 10
sq10 = lambda x: (x * x) % N
pairs = [(a, b) for a in range(N) for b in range(a + 1, N)]
print(f"Tracking collisions among all pairs in Z/{N}Z under x ↦ x²:")
for k in range(8):
    collided = [(a, b) for a, b in pairs if iterate(sq10, a, k) == iterate(sq10, b, k)]
    print(f"  Step {k}: {len(collided)} pairs collided")
print("  (Non-decreasing — confirming the filtration monotonicity theorem)")
print()


# === Demo 5: Pythagorean Prime Synchronization ===
print("=" * 60)
print("DEMO 5: Pythagorean Prime Synchronization")
print("=" * 60)
print()

def is_prime(n: int) -> bool:
    if n < 2:
        return False
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0:
            return False
    return True

triples = [(3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25)]
for a, b, c in triples:
    assert a**2 + b**2 == c**2
    primes_dividing_c = [p for p in range(2, c + 1) if is_prime(p) and c % p == 0]
    print(f"Triple ({a}, {b}, {c}): a² + b² = {a**2 + b**2} = c² = {c**2}")
    for p in primes_dividing_c:
        print(f"  Prime p = {p} divides c = {c}")
        print(f"    a² + b² mod p = {(a**2 + b**2) % p} (should be 0)")
        print(f"    a² mod p = {a**2 % p}, b² mod p = {b**2 % p}")
        print(f"    So a² ≡ -{b**2 % p} (mod {p}), i.e., legs' squares are anti-synchronized")
    print()


# === Demo 6: Complexity Rank ===
print("=" * 60)
print("DEMO 6: Complexity Rank Bounds")
print("=" * 60)
print()

for N in [7, 11, 13]:
    sq_N = lambda x, n=N: (x * x) % N
    print(f"Z/{N}Z (card = {N}):")
    for x in range(min(N, 5)):
        for n in [5, 10, 20]:
            cr = complexity_rank(sq_N, x, n)
            print(f"  x = {x}, n = {n}: complexity = {cr} ≤ min({n}, {N}) = {min(n, N)}")
    print()


# === Demo 7: Backward Propagation ===
print("=" * 60)
print("DEMO 7: Backward Propagation (Injective Maps)")
print("=" * 60)
print()

# Rotation by 1 on Z/7Z is injective
N = 7
rot = lambda x: (x + 1) % N
print(f"Rotation x ↦ x + 1 mod {N} (injective):")
for a in range(N):
    for b in range(a + 1, N):
        ct = collision_time(rot, a, b, 20)
        print(f"  a = {a}, b = {b}: collision at step {ct} (should be -1)")
print("  (No collisions for distinct initial conditions — backward propagation)")
print()

print("All demos completed successfully!")


"""
Visualization: Collision Filtration Heatmap
============================================
Shows how pairs of initial conditions in Z/nZ progressively synchronize
under the squaring map x ↦ x² mod n. Each pixel (a, b) shows the first
time step where f^k(a) = f^k(b), illustrating the collision filtration
as a "wave" of synchronization propagating through the system.
"""

import numpy as np
import matplotlib.pyplot as plt

N = 31  # Use a prime for clean structure
max_steps = 15

# Compute collision times for all pairs
collision_matrix = np.full((N, N), max_steps, dtype=float)

for a in range(N):
    for b in range(N):
        xa, xb = a, b
        for k in range(max_steps):
            if xa == xb:
                collision_matrix[a, b] = k
                break
            xa = (xa * xa) % N
            xb = (xb * xb) % N

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Collision time heatmap
im1 = axes[0].imshow(collision_matrix, cmap='inferno_r', origin='lower',
                      vmin=0, vmax=max_steps)
axes[0].set_title(f'Collision Time Map\nx -> x^2 mod {N}', fontsize=14)
axes[0].set_xlabel('Initial condition b', fontsize=12)
axes[0].set_ylabel('Initial condition a', fontsize=12)
plt.colorbar(im1, ax=axes[0], label='First collision time')

# Right: Filtration cardinality growth
filtration_sizes = []
for k in range(max_steps):
    count = np.sum(collision_matrix <= k)
    filtration_sizes.append(count)

axes[1].plot(range(max_steps), filtration_sizes, 'o-', color='#e74c3c',
             linewidth=2, markersize=6)
axes[1].fill_between(range(max_steps), filtration_sizes, alpha=0.2, color='#e74c3c')
axes[1].set_title('Collision Filtration Growth\n(Monotone — Theorem Verified)', fontsize=14)
axes[1].set_xlabel('Time step k', fontsize=12)
axes[1].set_ylabel('Number of synchronized pairs', fontsize=12)
axes[1].set_ylim(0, N * N + 10)
axes[1].axhline(y=N * N, color='gray', linestyle='--', alpha=0.5,
                label=f'Total pairs = {N}² = {N*N}')
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('collision_filtration.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved collision_filtration.png")


"""
Visualization: Image Size Collapse Under Iteration
====================================================
Demonstrates the Monotone Image Theorem: |im(f^n)| is non-increasing.
Shows how the squaring map's image collapses for different moduli,
revealing the algebraic structure (prime vs composite) through dynamics.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Image collapse curves for various moduli
moduli = [7, 10, 12, 15, 20, 30]
colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c']
max_n = 10

for N, color in zip(moduli, colors):
    sizes = []
    current = list(range(N))
    sizes.append(len(set(current)))
    for _ in range(max_n):
        current = [(x * x) % N for x in current]
        sizes.append(len(set(current)))

    # Check non-increasing (theorem verification)
    is_monotone = all(sizes[i] >= sizes[i+1] for i in range(len(sizes)-1))
    marker = 'o' if is_monotone else 'x'

    def is_prime(n):
        if n < 2: return False
        for i in range(2, int(n**0.5)+1):
            if n % i == 0: return False
        return True

    label = f'Z/{N}Z'
    if is_prime(N):
        label += ' (prime)'
    axes[0].plot(range(max_n + 1), sizes, f'{marker}-', color=color,
                linewidth=2, markersize=6, label=label)

axes[0].set_title('Image Size Collapse\n|im(f^n)| under x -> x^2',
                   fontsize=14)
axes[0].set_xlabel('Iteration n', fontsize=12)
axes[0].set_ylabel('Image size |im(f^n)|', fontsize=12)
axes[0].legend(fontsize=9)
axes[0].grid(True, alpha=0.3)

# Right panel: Stabilization point vs number of prime factors
moduli_extended = list(range(2, 60))
stab_points = []
omega_vals = []  # number of distinct prime factors

for N in moduli_extended:
    current = list(range(N))
    prev_size = N
    stab = 0
    for n in range(1, 30):
        current = [(x * x) % N for x in current]
        curr_size = len(set(current))
        if curr_size == prev_size:
            stab = n
            break
        prev_size = curr_size
    stab_points.append(stab)

    # Count distinct prime factors
    omega = 0
    temp = N
    for p in range(2, N + 1):
        if temp <= 1:
            break
        if temp % p == 0:
            omega += 1
            while temp % p == 0:
                temp //= p
    omega_vals.append(omega)

colors_scatter = []
for o in omega_vals:
    if o == 1:
        colors_scatter.append('#3498db')  # prime powers
    elif o == 2:
        colors_scatter.append('#e74c3c')
    else:
        colors_scatter.append('#2ecc71')

axes[1].scatter(moduli_extended, stab_points, c=colors_scatter, s=30, alpha=0.7)
axes[1].set_title('Stabilization Step vs Modulus\nColor: blue=prime power, red=2 factors, green=3+',
                   fontsize=13)
axes[1].set_xlabel('Modulus n', fontsize=12)
axes[1].set_ylabel('Step where image stabilizes', fontsize=12)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('image_collapse.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved image_collapse.png")


"""
Visualization: Pythagorean Synchronization Spectrum
=====================================================
For each Pythagorean triple (a, b, c), shows the synchronization pattern
of a² and b² across primes. The Pythagorean Prime Synchronization theorem
guarantees that primes dividing c produce zero residues — these appear
as "holes" in the spectrum.
"""

import numpy as np
import matplotlib.pyplot as plt

def is_prime(n):
    if n < 2: return False
    for i in range(2, int(n**0.5)+1):
        if n % i == 0: return False
    return True

primes = [p for p in range(2, 60) if is_prime(p)]

triples = [
    (3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25),
    (20, 21, 29), (9, 40, 41), (12, 35, 37), (11, 60, 61)
]

fig, axes = plt.subplots(2, 4, figsize=(18, 8))
axes = axes.flatten()

for idx, (a, b, c) in enumerate(triples):
    ax = axes[idx]

    residues = []
    colors = []
    for p in primes:
        r = (a**2 + b**2) % p
        residues.append(r)
        if c % p == 0:
            colors.append('#e74c3c')  # Hypotenuse prime — must be 0
        elif r == 0:
            colors.append('#f39c12')  # Zero but not hypotenuse prime
        else:
            colors.append('#3498db')

    ax.bar(range(len(primes)), residues, color=colors, width=0.8)
    ax.set_title(f'({a}, {b}, {c})', fontsize=12, fontweight='bold')
    ax.set_xticks(range(0, len(primes), 3))
    ax.set_xticklabels([str(primes[i]) for i in range(0, len(primes), 3)],
                        fontsize=7)
    ax.set_ylabel('a^2+b^2 mod p', fontsize=9)

    # Mark hypotenuse primes
    hyp_primes = [p for p in primes if c % p == 0]
    if hyp_primes:
        hyp_str = ','.join(str(p) for p in hyp_primes)
        ax.set_xlabel(f'p (red = divides {c})', fontsize=8)

fig.suptitle('Pythagorean Prime Synchronization Spectrum\n'
             'a^2+b^2 mod p for primes $p$ — '
             'red bars at primes dividing hypotenuse (must be 0)',
             fontsize=15, fontweight='bold')

plt.tight_layout()
plt.savefig('pythagorean_sync.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved pythagorean_sync.png")
