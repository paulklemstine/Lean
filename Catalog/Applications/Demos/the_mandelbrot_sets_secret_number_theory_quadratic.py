#!/usr/bin/env python3
"""
Mandelbrot Number Theory: Numerical Demonstrations

Demonstrates the connection between quadratic iteration z_{n+1} = z_n² + c
and number theory, including necklace divisibility, dynatomic point counting,
and tropical Mandelbrot dynamics.
"""

import math
from functools import lru_cache


def mandelbrot_iter(c: complex, n: int) -> complex:
    """Compute f_c^n(0) where f_c(z) = z² + c."""
    z = 0
    for _ in range(n):
        z = z * z + c
    return z


def mandelbrot_iter_mod(c: int, n: int, modulus: int) -> int:
    """Compute f_c^n(0) mod m."""
    z = 0
    for _ in range(n):
        z = (z * z + c) % modulus
    return z


def moebius(n: int) -> int:
    """Compute the Möbius function μ(n)."""
    if n == 1:
        return 1
    factors = []
    temp = n
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            count = 0
            while temp % d == 0:
                temp //= d
                count += 1
            if count > 1:
                return 0
            factors.append(d)
        d += 1
    if temp > 1:
        factors.append(temp)
    return (-1) ** len(factors)


def divisors(n: int) -> list:
    """Return sorted list of divisors of n."""
    divs = []
    for d in range(1, n + 1):
        if n % d == 0:
            divs.append(d)
    return divs


def dynatomic_sum(n: int) -> int:
    """Compute Ψ(n) = ∑_{d|n} μ(n/d) · 2^d."""
    return sum(moebius(n // d) * (2 ** d) for d in divisors(n))


def necklace_number(n: int) -> int:
    """Number of distinct binary necklaces of length n = Ψ(n)/n."""
    return dynatomic_sum(n) // n


def tropical_quad_iter(c: float, z: float, n: int) -> float:
    """Tropical iteration: max(2z, c)."""
    for _ in range(n):
        z = max(2 * z, c)
    return z


# === DEMO 1: Necklace Divisibility ===
print("=" * 60)
print("DEMO 1: Necklace Divisibility — n | Ψ(n)")
print("=" * 60)
print(f"{'n':>4} {'Ψ(n)':>10} {'N(n)=Ψ(n)/n':>12} {'n|Ψ(n)?':>8}")
print("-" * 40)
for n in range(1, 21):
    psi = dynatomic_sum(n)
    neck = necklace_number(n)
    divides = "✓" if psi % n == 0 else "✗"
    print(f"{n:>4} {psi:>10} {neck:>12} {divides:>8}")

# === DEMO 2: Dynatomic-Totient Analogy ===
print("\n" + "=" * 60)
print("DEMO 2: Dynatomic-Totient Analogy for Prime Powers")
print("=" * 60)
print(f"{'p^k':>8} {'Ψ(p^k)':>12} {'2^(p^k)-2^(p^(k-1))':>22} {'Match?':>7}")
print("-" * 55)
for p in [2, 3, 5, 7]:
    for k in range(1, 5):
        pk = p ** k
        if pk > 1000:
            continue
        psi = dynatomic_sum(pk)
        expected = 2 ** pk - 2 ** (p ** (k - 1))
        match = "✓" if psi == expected else "✗"
        print(f"{p}^{k} = {pk:>4} {psi:>12} {expected:>22} {match:>7}")

# === DEMO 3: Mandelbrot Period Classification ===
print("\n" + "=" * 60)
print("DEMO 3: Period Classification via Mandelbrot Iteration")
print("=" * 60)
print("Period-2 centers: f²(0) = 0, f(0) ≠ 0")
for c_val in [0, -1, -2, 0.25]:
    c = complex(c_val)
    f1 = mandelbrot_iter(c, 1)
    f2 = mandelbrot_iter(c, 2)
    f3 = mandelbrot_iter(c, 3)
    print(f"  c = {c_val:>6}: f(0) = {f1:.4f}, f²(0) = {f2:.4f}, f³(0) = {f3:.4f}")

print("\nPeriod-3: f³(0) = 0 iff c(c³+2c²+c+1) = 0")
print("  Roots of c³+2c²+c+1 (approximately):")
# Find roots numerically
import cmath
coeffs_check = lambda c: c**3 + 2*c**2 + c + 1
# Newton's method for real root
x = -1.75
for _ in range(100):
    f = x**3 + 2*x**2 + x + 1
    fp = 3*x**2 + 4*x + 1
    if abs(fp) < 1e-15:
        break
    x -= f / fp
print(f"    Real root: c ≈ {x:.10f}")
print(f"    Verify: c³+2c²+c+1 = {coeffs_check(x):.2e}")
print(f"    f³(0) at this c: {abs(mandelbrot_iter(complex(x), 3)):.2e}")

# === DEMO 4: Tropical Mandelbrot Dynamics ===
print("\n" + "=" * 60)
print("DEMO 4: Tropical Mandelbrot Dynamics")
print("=" * 60)
print("Tropical iteration: z ↦ max(2z, c)")
print("\nCase 1: c = -1 ≤ 0 (bounded, orbit stays at 0)")
for n in range(6):
    val = tropical_quad_iter(-1, 0, n)
    print(f"  Step {n}: {val}")

print("\nCase 2: c = 2 > 0 (escaping)")
for n in range(6):
    val = tropical_quad_iter(2, 0, n)
    print(f"  Step {n}: {val}")

print("\nCase 3: Escape theorem — z=3, c=1 (c < 2z), orbit = 2^n · z")
for n in range(6):
    val = tropical_quad_iter(1, 3, n)
    expected = (2 ** n) * 3
    print(f"  Step {n}: {val} (expected 2^{n}·3 = {expected})")

# === DEMO 5: Orbit Counting and Fermat's Little Theorem ===
print("\n" + "=" * 60)
print("DEMO 5: Orbit Counting — Dynamical Fermat's Little Theorem")
print("=" * 60)
print("p | 2^p - 2 (Fermat's Little Theorem as orbit count)")
for p in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]:
    val = 2**p - 2
    orbits = val // p
    print(f"  p={p:>2}: 2^p - 2 = {val:>12}, orbits = {orbits:>10}, "
          f"p | (2^p-2)? {'✓' if val % p == 0 else '✗'}")

# === DEMO 6: Mandelbrot Roots mod p ===
print("\n" + "=" * 60)
print("DEMO 6: Roots of P_n(c) mod p — Dynatomic Polynomial Splitting")
print("=" * 60)
print(f"{'p':>4} {'Period 1':>9} {'Period 2':>9} {'Period 3':>9} {'Period 4':>9}")
for p in [3, 5, 7, 11, 13, 17, 19, 23]:
    roots = []
    for n in range(1, 5):
        count = sum(1 for c in range(p) if mandelbrot_iter_mod(c, n, p) == 0)
        roots.append(count)
    print(f"{p:>4} {roots[0]:>9} {roots[1]:>9} {roots[2]:>9} {roots[3]:>9}")

print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
import json

def read(f):
    with open(f) as fh:
        return fh.read()

article = read('ARTICLE.md')
paper = read('RESEARCH_PAPER.md')
future = read('FUTURE_DIRECTIONS.md')
lean = read('MandelbrotNumberTheory.lean')
demo = read('demo.py')
algo = read('algorithms.py')
viz1 = read('viz_necklaces.py')
viz2 = read('viz_tropical.py')
viz3 = read('viz_mandelbrot_periods.py')

necklace_html = read('widget_necklace.html')
tropical_html = read('widget_tropical.html')
mandelbrot_html = read('widget_mandelbrot.html')

package = {
    'title': 'Quadratic Recurrence and Number Theory: Necklace Divisibility and Tropical Mandelbrot Dynamics',
    'domain': 'Applications',
    'article': article,
    'research_paper': paper,
    'future_directions': future,
    'demos': ['demo.py'],
    'algorithms': [
        {
            'name': 'Dynatomic Sum Computation',
            'pseudocode': 'For each divisor d of n: compute mu(n/d) * 2^d. Sum all terms.',
            'code': algo
        }
    ],
    'visualizations': [
        {'name': 'Necklace Numbers', 'code': viz1, 'description': 'Necklace numbers and dynatomic sums.'},
        {'name': 'Tropical Dynamics', 'code': viz2, 'description': 'Tropical Mandelbrot dynamics.'},
        {'name': 'Period Map', 'code': viz3, 'description': 'Mandelbrot period map.'}
    ],
    'interactive_demos': [
        {
            'name': 'Necklace Divisibility Explorer',
            'description': 'Explore dynatomic sum and necklace number for any n.',
            'html': necklace_html
        },
        {
            'name': 'Tropical Mandelbrot Iterator',
            'description': 'Simulate tropical dynamics z -> max(2z, c).',
            'html': tropical_html
        },
        {
            'name': 'Mandelbrot Period Explorer',
            'description': 'Click to analyze orbits and detect periods.',
            'html': mandelbrot_html
        }
    ],
    'lean_proofs': [
        {
            'file': 'Applications/MandelbrotNumberTheory.lean',
            'theorems': [
                'necklace_div', 'dynatomic_of_prime', 'dynatomic_prime_power',
                'orbit_mult_succ', 'mandelbrot_superattracting',
                'mandelbrot_period3_factored', 'mandelbrot_period2',
                'mandelbrot_exact_period2', 'mandelbrot_orbit_shift',
                'mandelbrot_orbit_shift_mul', 'mandelbrot_gcd_return_prime',
                'tropical_escape', 'tropical_bounded_stabilize',
                'tropical_fixed_nonpos', 'tropical_mandelbrot_bounded_iff_nonpos',
                'tropical_mandelbrot_orbit_zero',
                'mandelbrotPoly_eval', 'fermat_orbit_count',
                'prime_orbit_count_ge_two'
            ]
        }
    ]
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)
print('PACKAGE.json written')


#!/usr/bin/env python3
"""
Visualization: Mandelbrot Set Period Map

Colors each point c in the Mandelbrot set by the period of its
attracting cycle, revealing the number-theoretic structure of bulbs.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def find_period(c, max_iter=200, max_period=50, tol=1e-8):
    """Find the period of the attracting cycle for parameter c."""
    z = complex(0)
    # Iterate to settle onto the attractor
    for _ in range(max_iter):
        z = z * z + c
        if abs(z) > 10:
            return 0  # escaping
    # Now check for periodicity
    z_ref = z
    for p in range(1, max_period + 1):
        z = z * z + c
        if abs(z) > 10:
            return 0
        if abs(z - z_ref) < tol:
            return p
    return -1  # period not found


# Generate period map
nx, ny = 800, 600
x = np.linspace(-2.2, 0.8, nx)
y = np.linspace(-1.2, 1.2, ny)
periods = np.zeros((ny, nx))

for j in range(ny):
    for i in range(nx):
        c = complex(x[i], y[j])
        periods[j, i] = find_period(c)

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Plot 1: Period map
ax = axes[0]
# Create custom colormap
cmap = plt.cm.get_cmap('tab20', 20)
im = ax.imshow(periods, extent=[-2.2, 0.8, -1.2, 1.2],
               cmap=cmap, vmin=0, vmax=20, aspect='auto', origin='lower')
ax.set_xlabel('Re(c)')
ax.set_ylabel('Im(c)')
ax.set_title('Mandelbrot Set: Period of Attracting Cycles')
cbar = plt.colorbar(im, ax=ax, label='Period')
cbar.set_ticks(range(0, 21, 2))

# Annotate key bulbs
annotations = [
    (0.25, 0, '1'),
    (-0.75, 0, '2'),
    (-0.12, 0.74, '3'),
    (-1.25, 0, '3'),
    (0.28, 0.53, '4'),
    (-0.5, 0.56, '5'),
]
for cx, cy, label in annotations:
    ax.annotate(label, (cx, cy), fontsize=8, color='white',
                ha='center', va='center',
                bbox=dict(boxstyle='round,pad=0.2', fc='black', alpha=0.6))

# Plot 2: Period histogram
ax = axes[1]
period_counts = {}
for p in range(1, 21):
    count = np.sum(periods == p)
    if count > 0:
        period_counts[p] = count

bars = ax.bar(list(period_counts.keys()), list(period_counts.values()),
              color='steelblue', alpha=0.7)
# Color prime periods differently
for bar, p in zip(bars, period_counts.keys()):
    is_prime = p > 1 and all(p % d != 0 for d in range(2, int(p**0.5) + 1))
    if is_prime:
        bar.set_color('#e41a1c')
        bar.set_alpha(0.8)
ax.set_xlabel('Period')
ax.set_ylabel('Pixel count')
ax.set_title('Distribution of Periods (red = prime period)')
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('/workspace/request-project/Applications/mandelbrot_periods.png', dpi=150)
plt.close()
print("Saved mandelbrot_periods.png")


#!/usr/bin/env python3
"""
Visualization: Necklace Numbers and Dynatomic Point Counts

Shows the deep parallel between Euler's totient function φ(n)
and the dynatomic point count Ψ(n) = ∑_{d|n} μ(n/d)·2^d.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def moebius(n):
    if n == 1:
        return 1
    temp, d, factors = n, 2, 0
    while d * d <= temp:
        if temp % d == 0:
            count = 0
            while temp % d == 0:
                temp //= d
                count += 1
            if count > 1:
                return 0
            factors += 1
        d += 1
    if temp > 1:
        factors += 1
    return (-1) ** factors


def divisors(n):
    result = []
    for d in range(1, n + 1):
        if n % d == 0:
            result.append(d)
    return result


def dynatomic_sum(n):
    return sum(moebius(n // d) * (2 ** d) for d in divisors(n))


def euler_totient(n):
    result = n
    temp = n
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            while temp % d == 0:
                temp //= d
            result -= result // d
        d += 1
    if temp > 1:
        result -= result // temp
    return result


N = 30
ns = list(range(1, N + 1))
psi_vals = [dynatomic_sum(n) for n in ns]
necklace_vals = [psi_vals[i] // ns[i] for i in range(N)]
phi_vals = [euler_totient(n) for n in ns]
necklace_phi = [phi_vals[i] // 1 for i in range(N)]  # φ(n)/1

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Dynatomic sum Ψ(n) vs 2^n
ax = axes[0, 0]
ax.semilogy(ns, psi_vals, 'bo-', label='Ψ(n) = dynatomic sum', markersize=5)
ax.semilogy(ns, [2**n for n in ns], 'r--', alpha=0.5, label='2^n (total periodic pts)')
ax.set_xlabel('Period n')
ax.set_ylabel('Count (log scale)')
ax.set_title('Dynatomic Point Count Ψ(n)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: Necklace numbers N(n) = Ψ(n)/n
ax = axes[0, 1]
ax.bar(ns, necklace_vals, color='steelblue', alpha=0.7)
ax.set_xlabel('Length n')
ax.set_ylabel('N(n) = Ψ(n)/n')
ax.set_title('Binary Necklace Numbers')
ax.grid(True, alpha=0.3, axis='y')

# Plot 3: Totient-Dynatomic analogy
ax = axes[1, 0]
ax.semilogy(ns, [psi_vals[i] / ns[i] for i in range(N)], 'bo-',
            label='Ψ(n)/n (necklaces)', markersize=5)
ax.semilogy(ns, [phi_vals[i] / ns[i] for i in range(N)], 'rs-',
            label='φ(n)/n (reduced residues)', markersize=5)
ax.set_xlabel('n')
ax.set_ylabel('Ratio (log scale)')
ax.set_title('Totient-Dynatomic Analogy: Ψ(n)/n vs φ(n)/n')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 4: Prime power verification
ax = axes[1, 1]
primes = [2, 3, 5, 7]
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
for i, p in enumerate(primes):
    ks = list(range(1, 8))
    pks = [p**k for k in ks if p**k <= 200]
    ks = ks[:len(pks)]
    psi_pk = [dynatomic_sum(pk) for pk in pks]
    expected = [2**pk - 2**(p**(k-1)) for pk, k in zip(pks, ks)]
    ax.semilogy(ks, psi_pk, 'o-', color=colors[i], label=f'Ψ({p}^k)', markersize=6)
    ax.semilogy(ks, expected, 's--', color=colors[i], alpha=0.5, markersize=4)
ax.set_xlabel('k')
ax.set_ylabel('Ψ(p^k) (log scale)')
ax.set_title('Prime Power Formula: Ψ(p^k) = 2^{p^k} - 2^{p^{k-1}}')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Applications/necklace_numbers.png', dpi=150)
plt.close()
print("Saved necklace_numbers.png")


#!/usr/bin/env python3
"""
Visualization: Tropical Mandelbrot Dynamics

Shows the tropical (max-plus) analog of the Mandelbrot iteration:
z ↦ max(2z, c), and its connection to the classical Mandelbrot set.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def tropical_iterate(c, z, n):
    for _ in range(n):
        z = max(2 * z, c)
    return z


def mandelbrot_escape_time(c, max_iter=100):
    z = 0 + 0j
    for n in range(max_iter):
        z = z * z + c
        if abs(z) > 2:
            return n
    return max_iter


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Tropical orbits for various c
ax = axes[0, 0]
cs = [-2, -1, -0.5, 0, 0.5, 1, 2]
colors_list = plt.cm.coolwarm(np.linspace(0, 1, len(cs)))
steps = list(range(8))
for c_val, color in zip(cs, colors_list):
    orbit = [tropical_iterate(c_val, 0, n) for n in steps]
    ax.plot(steps, orbit, 'o-', color=color, label=f'c={c_val}', markersize=5)
ax.axhline(y=0, color='black', linewidth=0.5, linestyle='--')
ax.set_xlabel('Step n')
ax.set_ylabel('Tropical iterate')
ax.set_title('Tropical Mandelbrot Orbits: z ↦ max(2z, c)')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Plot 2: Tropical Mandelbrot set boundary
ax = axes[0, 1]
c_range = np.linspace(-3, 3, 1000)
bounded = []
for c in c_range:
    z = 0
    escaped = False
    for _ in range(50):
        z = max(2 * z, c)
        if z > 1e10:
            escaped = True
            break
    bounded.append(0 if escaped else 1)
ax.fill_between(c_range, 0, bounded, alpha=0.4, color='steelblue',
                label='Tropical M (bounded)')
ax.axvline(x=0, color='red', linestyle='--', linewidth=1.5,
           label='Boundary: c = 0')
ax.set_xlabel('c')
ax.set_ylabel('Bounded (1) / Escaping (0)')
ax.set_title('Tropical Mandelbrot Set = {c ≤ 0}')
ax.legend()
ax.set_ylim(-0.1, 1.1)
ax.grid(True, alpha=0.3)

# Plot 3: Escape theorem verification
ax = axes[1, 0]
z0 = 3.0
c_val = 1.0
steps_long = list(range(10))
actual = [tropical_iterate(c_val, z0, n) for n in steps_long]
predicted = [2**n * z0 for n in steps_long]
ax.semilogy(steps_long, actual, 'bo-', label='Actual orbit', markersize=6)
ax.semilogy(steps_long, predicted, 'r--', label='2^n · z₀', markersize=4)
ax.set_xlabel('Step n')
ax.set_ylabel('Value (log scale)')
ax.set_title(f'Tropical Escape: z₀={z0}, c={c_val} (c < 2z₀)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 4: Classical vs Tropical — side by side on real line
ax = axes[1, 1]
c_range_fine = np.linspace(-2.5, 0.5, 500)
classical_bounded = []
tropical_bounded_vals = []
for c in c_range_fine:
    # Classical
    z = 0
    classical_esc = False
    for _ in range(100):
        z = z * z + c
        if abs(z) > 2:
            classical_esc = True
            break
    classical_bounded.append(0 if classical_esc else 1)
    # Tropical
    tropical_bounded_vals.append(1 if c <= 0 else 0)

ax.fill_between(c_range_fine, 0, classical_bounded, alpha=0.4,
                color='blue', label='Classical M ∩ ℝ')
ax.fill_between(c_range_fine, 0, [t * 0.5 for t in tropical_bounded_vals],
                alpha=0.4, color='red', label='Tropical M (scaled)')
ax.set_xlabel('c (real axis)')
ax.set_ylabel('Bounded')
ax.set_title('Classical vs Tropical Mandelbrot on ℝ')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Applications/tropical_mandelbrot.png', dpi=150)
plt.close()
print("Saved tropical_mandelbrot.png")
