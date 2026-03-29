#!/usr/bin/env python3
"""
Demo 3: The Prime–Zeta–Energy Connection
==========================================

Visualizes the deep connections between:
1. Prime distribution and the error term |π(x) - Li(x)|
2. The Riemann zeta function on the critical line
3. Robin's inequality as the "arithmetic shadow" of RH
4. The explicit formula connecting primes and zeta zeros

Shows why the Riemann Hypothesis controls integer energy.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import log, exp, pi, sin, cos, sqrt, floor
from cmath import exp as cexp
import os

output_dir = os.path.join(os.path.dirname(__file__), '..', 'visuals')
os.makedirs(output_dir, exist_ok=True)

# --- Sieve of Eratosthenes ---
def sieve(n):
    """Return list of primes up to n."""
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]

def prime_counting(x, primes):
    """π(x) = number of primes ≤ x."""
    from bisect import bisect_right
    return bisect_right(primes, x)

def li(x):
    """Logarithmic integral Li(x) = ∫₂ˣ dt/ln(t), approximated numerically."""
    if x <= 2:
        return 0
    # Simple numerical integration
    n_steps = max(1000, int(x))
    n_steps = min(n_steps, 100000)
    dt = (x - 2) / n_steps
    total = 0
    for i in range(n_steps):
        t = 2 + (i + 0.5) * dt
        if t > 1.01:
            total += dt / log(t)
    return total

# --- Known non-trivial zeros of zeta (imaginary parts) ---
# First 30 zeros on the critical line Re(s) = 1/2
zeta_zeros_imag = [
    14.134725, 21.022040, 25.010858, 30.424876, 32.935062,
    37.586178, 40.918719, 43.327073, 48.005151, 49.773832,
    52.970321, 56.446248, 59.347044, 60.831779, 65.112544,
    67.079811, 69.546402, 72.067158, 75.704691, 77.144840,
    79.337375, 82.910381, 84.735493, 87.425275, 88.809111,
    92.491899, 94.651344, 95.870634, 98.831194, 101.317851,
]

# --- Figure 1: Prime Counting Error and RH ---

print("Computing prime counting function and error terms...")
primes = sieve(100000)
print(f"Found {len(primes)} primes up to 100,000")

xs = np.logspace(1, 5, 500)
pi_vals = np.array([prime_counting(x, primes) for x in xs])
li_vals = np.array([li(x) for x in xs])
errors = pi_vals - li_vals

fig, axes = plt.subplots(2, 2, figsize=(16, 12))
fig.suptitle("The Prime–Zeta–Energy Connection\nHow Prime Distribution Controls Integer Energy",
             fontsize=15, fontweight='bold')

# Panel 1: π(x) vs Li(x)
ax1 = axes[0, 0]
ax1.loglog(xs, pi_vals, 'b-', linewidth=2, label=r'$\pi(x)$ (exact)')
ax1.loglog(xs, li_vals, 'r--', linewidth=2, label=r'$\mathrm{Li}(x)$ (approx)')
ax1.set_xlabel('x', fontsize=11)
ax1.set_ylabel('Count', fontsize=11)
ax1.set_title(r'Prime Counting: $\pi(x)$ vs $\mathrm{Li}(x)$', fontsize=12)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Panel 2: Error term |π(x) - Li(x)| with RH bound
ax2 = axes[0, 1]
abs_errors = np.abs(errors)
# RH prediction: |π(x) - Li(x)| ≤ c·√x·ln(x) for large x
rh_bound = 1.0 / (8 * pi) * np.sqrt(xs) * np.log(xs)

ax2.plot(xs, abs_errors, 'b-', linewidth=1.5, label=r'$|\pi(x) - \mathrm{Li}(x)|$')
ax2.plot(xs, rh_bound, 'r--', linewidth=2, alpha=0.7,
         label=r'RH bound: $c\sqrt{x}\ln x$')
ax2.set_xscale('log')
ax2.set_xlabel('x', fontsize=11)
ax2.set_ylabel('Error', fontsize=11)
ax2.set_title('Prime Counting Error — RH Controls the Bound', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: Normalized error showing oscillations from zeta zeros
ax3 = axes[1, 0]
# Normalize by √x
with np.errstate(divide='ignore', invalid='ignore'):
    norm_errors = errors / np.sqrt(xs)
    norm_errors = np.where(np.isfinite(norm_errors), norm_errors, 0)

ax3.plot(xs, norm_errors, 'darkblue', linewidth=1.2)
ax3.axhline(y=0, color='black', linewidth=0.5)
ax3.set_xscale('log')
ax3.set_xlabel('x', fontsize=11)
ax3.set_ylabel(r'$(\pi(x) - \mathrm{Li}(x)) / \sqrt{x}$', fontsize=11)
ax3.set_title('Normalized Error: Oscillations from Zeta Zeros', fontsize=12)
ax3.grid(True, alpha=0.3)

# Panel 4: Zeta zero spacings (GUE statistics)
ax4 = axes[1, 1]
spacings = np.diff(zeta_zeros_imag)
mean_spacing = np.mean(spacings)
norm_spacings = spacings / mean_spacing

# GUE distribution (Wigner surmise)
s_range = np.linspace(0, 3, 100)
wigner = (pi / 2) * s_range * np.exp(-pi * s_range**2 / 4)
poisson = np.exp(-s_range)

ax4.hist(norm_spacings, bins=10, density=True, alpha=0.7, color='steelblue',
         edgecolor='black', label='Zeta zero spacings')
ax4.plot(s_range, wigner, 'r-', linewidth=2, label='GUE (Wigner surmise)')
ax4.plot(s_range, poisson, 'g--', linewidth=2, label='Poisson (random)')
ax4.set_xlabel('Normalized spacing s', fontsize=11)
ax4.set_ylabel('Density', fontsize=11)
ax4.set_title('Zeta Zero Spacings Follow GUE Statistics', fontsize=12)
ax4.legend(fontsize=10)

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'prime_zeta_connection.png'), dpi=150, bbox_inches='tight')
plt.close()
print(f"✅ Saved: prime_zeta_connection.png")

# --- Figure 2: The Explicit Formula Visualization ---

print("\nComputing explicit formula reconstruction...")

def explicit_formula_approx(x, num_zeros=15):
    """
    Approximate π(x) using the explicit formula with first num_zeros zeros.
    
    ψ(x) ≈ x - Σ x^ρ/ρ - ln(2π) - (1/2)ln(1 - 1/x²)
    where ρ = 1/2 + iγ are the zeta zeros.
    """
    result = x  # main term
    for k in range(min(num_zeros, len(zeta_zeros_imag))):
        gamma_k = zeta_zeros_imag[k]
        # Contribution from ρ = 1/2 + iγ and its conjugate
        # x^ρ / ρ + x^ρ̄ / ρ̄ = 2 Re(x^ρ / ρ)
        if x > 0:
            log_x = log(x)
            mag = x**0.5  # x^(1/2)
            phase = gamma_k * log_x
            # x^(1/2 + iγ) = x^(1/2) · e^(iγ ln x)
            real_part = mag * cos(phase)
            imag_part = mag * sin(phase)
            # Divide by ρ = 1/2 + iγ
            rho_real, rho_imag = 0.5, gamma_k
            rho_mag_sq = rho_real**2 + rho_imag**2
            contrib_real = (real_part * rho_real + imag_part * rho_imag) / rho_mag_sq
            result -= 2 * contrib_real
    return result

fig2, axes2 = plt.subplots(2, 2, figsize=(16, 12))
fig2.suptitle("The Explicit Formula: How Zeta Zeros Build the Prime Staircase",
              fontsize=15, fontweight='bold')

x_fine = np.linspace(2, 200, 2000)

# Panel 1: Building up with more zeros
ax1 = axes2[0, 0]
ax1.step([0] + list(range(2, 201)),
         [0] + [prime_counting(x, primes) for x in range(2, 201)],
         'black', linewidth=2, label=r'$\pi(x)$ exact', where='post')

for nz, color, alpha in [(1, 'red', 0.5), (5, 'orange', 0.6),
                          (15, 'blue', 0.8), (30, 'green', 0.9)]:
    psi_approx = [explicit_formula_approx(x, nz) / log(x) if x > 1 else 0 for x in x_fine]
    ax1.plot(x_fine, psi_approx, color=color, alpha=alpha, linewidth=1.5,
             label=f'{nz} zeros')

ax1.set_xlabel('x', fontsize=11)
ax1.set_ylabel(r'$\pi(x)$ and approximations', fontsize=11)
ax1.set_title('Building π(x) from Zeta Zeros', fontsize=12)
ax1.legend(fontsize=9)
ax1.set_ylim(-5, 50)

# Panel 2: Individual zero contributions
ax2 = axes2[0, 1]
for k in range(5):
    gamma_k = zeta_zeros_imag[k]
    contributions = []
    for x in x_fine:
        if x > 1:
            log_x = log(x)
            mag = x**0.5
            phase = gamma_k * log_x
            real_part = mag * cos(phase)
            rho_mag_sq = 0.25 + gamma_k**2
            contrib = -2 * (real_part * 0.5 + mag * sin(phase) * gamma_k) / rho_mag_sq
            contributions.append(contrib / log(x))
        else:
            contributions.append(0)
    ax2.plot(x_fine, contributions, linewidth=1.5,
             label=f'γ = {gamma_k:.2f}', alpha=0.8)

ax2.axhline(y=0, color='black', linewidth=0.5)
ax2.set_xlabel('x', fontsize=11)
ax2.set_ylabel('Contribution to π(x)', fontsize=11)
ax2.set_title('Individual Zeta Zero Contributions', fontsize=12)
ax2.legend(fontsize=9)

# Panel 3: The critical strip visualization
ax3 = axes2[1, 0]
# Show the critical strip with zeros
ax3.axvline(x=0.5, color='blue', linewidth=2, label='Critical line Re(s)=1/2')
ax3.axvline(x=0, color='gray', linewidth=0.5, linestyle=':')
ax3.axvline(x=1, color='gray', linewidth=0.5, linestyle=':')
ax3.axvspan(0, 1, alpha=0.1, color='yellow', label='Critical strip')
ax3.axvspan(-0.1, 0, alpha=0.1, color='lightblue')

for gamma in zeta_zeros_imag[:20]:
    ax3.plot(0.5, gamma, 'ro', markersize=6, zorder=5)
    ax3.plot(0.5, -gamma, 'ro', markersize=6, zorder=5)

# If RH is false, a zero might be here
ax3.plot(0.75, 50, 'x', markersize=15, color='darkred', markeredgewidth=3,
         label='Hypothetical off-line zero', zorder=5)
ax3.annotate('If RH false:\nzero here would\ncause chaos in π(x)',
             (0.75, 50), textcoords='offset points', xytext=(30, 0),
             fontsize=9, color='darkred',
             arrowprops=dict(arrowstyle='->', color='darkred'))

ax3.set_xlabel('Re(s)', fontsize=11)
ax3.set_ylabel('Im(s)', fontsize=11)
ax3.set_title('The Critical Strip: Home of the Zeta Zeros', fontsize=12)
ax3.set_xlim(-0.5, 1.5)
ax3.set_ylim(-20, 110)
ax3.legend(fontsize=9, loc='lower right')

# Panel 4: Connection diagram
ax4 = axes2[1, 1]
ax4.set_xlim(0, 10)
ax4.set_ylim(0, 10)
ax4.axis('off')
ax4.set_title('The Logical Chain: Zeta → Primes → Divisors → Energy', fontsize=12)

# Draw boxes and arrows
boxes = [
    (1, 8, "Zeta Zeros\non Critical Line\n(RH)", 'lightcoral'),
    (6, 8, "Prime Distribution\n|π(x)-Li(x)| small\n(PNT refinement)", 'lightyellow'),
    (1, 4, "Divisor Sums\nσ(n) well-controlled\n(Gronwall bound)", 'lightgreen'),
    (6, 4, "Robin's Inequality\nσ(n) < eᵞ·n·ln(ln n)\nfor n ≥ 5041", 'lightblue'),
    (3.5, 1, "Integer Energy\nhas universal ceiling\n(5040 is the last spike)", 'plum'),
]

for x, y, text, color in boxes:
    ax4.add_patch(plt.Rectangle((x-1.3, y-1), 2.6, 2, facecolor=color,
                                 edgecolor='black', linewidth=1.5, zorder=2))
    ax4.text(x, y, text, ha='center', va='center', fontsize=8,
             fontweight='bold', zorder=3)

# Arrows
arrow_style = dict(arrowstyle='->', color='black', linewidth=2)
ax4.annotate('', xy=(5, 8), xytext=(3, 8), arrowprops=arrow_style)
ax4.annotate('', xy=(1, 6), xytext=(1, 7), arrowprops=arrow_style)
ax4.annotate('', xy=(6, 6), xytext=(6, 7), arrowprops=arrow_style)
ax4.annotate('', xy=(3.5, 2.5), xytext=(2, 3.5), arrowprops=arrow_style)
ax4.annotate('', xy=(3.5, 2.5), xytext=(5, 3.5), arrowprops=arrow_style)

ax4.text(4, 8.5, 'controls', ha='center', fontsize=9, style='italic')
ax4.text(0.3, 6.5, 'bounds', ha='center', fontsize=9, style='italic', rotation=90)
ax4.text(6.7, 6.5, 'implies', ha='center', fontsize=9, style='italic', rotation=90)

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'prime_zeta_explicit.png'), dpi=150, bbox_inches='tight')
plt.close()
print(f"✅ Saved: prime_zeta_explicit.png")

# --- Figure 3: σ(n) growth and the Euler product ---

print("\nComputing σ(n) Dirichlet series partial sums...")

def sigma_fn(n):
    s = 0
    for d in range(1, int(n**0.5) + 1):
        if n % d == 0:
            s += d
            if d != n // d:
                s += n // d
    return s

fig3, (ax_s1, ax_s2) = plt.subplots(1, 2, figsize=(14, 6))
fig3.suptitle(r"The Euler Product: $\sum \sigma(n)/n^s = \zeta(s)\zeta(s-1)$",
              fontsize=14, fontweight='bold')

# Partial sums of σ(n) compared to integral
xs_cum = np.arange(1, 5001)
sigma_cumsum = np.cumsum([sigma_fn(n) for n in xs_cum])
predicted = (np.pi**2 / 12) * xs_cum**2

ax_s1.plot(xs_cum, sigma_cumsum, 'b-', linewidth=1.5, label=r'$\sum_{k=1}^{n} \sigma(k)$')
ax_s1.plot(xs_cum, predicted, 'r--', linewidth=2, label=r'$\frac{\pi^2}{12} n^2$')
ax_s1.set_xlabel('n', fontsize=11)
ax_s1.set_ylabel('Cumulative sum', fontsize=11)
ax_s1.set_title(r'Partial Sums of $\sigma(n)$', fontsize=12)
ax_s1.legend(fontsize=10)

# Error in partial sum
errors_sigma = sigma_cumsum - predicted
ax_s2.plot(xs_cum, errors_sigma, 'darkgreen', linewidth=1)
ax_s2.axhline(y=0, color='black', linewidth=0.5)

# Under RH, error should be O(n^(3/2+ε))
rh_upper = 0.5 * xs_cum**(1.5)
rh_lower = -0.5 * xs_cum**(1.5)
ax_s2.fill_between(xs_cum, rh_lower, rh_upper, alpha=0.15, color='red',
                    label=r'RH bound: $O(n^{3/2})$')
ax_s2.set_xlabel('n', fontsize=11)
ax_s2.set_ylabel('Error', fontsize=11)
ax_s2.set_title(r'Error: $\sum \sigma(k) - \frac{\pi^2}{12}n^2$', fontsize=12)
ax_s2.legend(fontsize=10)

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'euler_product_connection.png'), dpi=150, bbox_inches='tight')
plt.close()
print(f"✅ Saved: euler_product_connection.png")

print("\n✅ All prime-zeta-energy visualizations complete!")
