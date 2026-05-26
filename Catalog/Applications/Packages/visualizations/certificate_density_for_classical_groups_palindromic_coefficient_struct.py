#!/usr/bin/env python3
"""
Visualization: Palindromic Coefficient Structure of Self-Reciprocal Polynomials

Illustrates the coefficient symmetry property (Theorem 1: self_reciprocal_iff_coeff_symmetry)
and the dimension halving phenomenon (Theorem 2: self_reciprocal_determined_by_first_half).

Shows how the palindromic constraint reduces the parameter space from 2n to n dimensions.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def make_self_reciprocal(half, q):
    full = list(half) + list(reversed(half[:-1]))
    return [c % q for c in full]


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Palindromic Structure of Self-Reciprocal Polynomials',
             fontsize=16, fontweight='bold')

# Panel 1: Coefficient mirror symmetry visualization
ax1 = axes[0, 0]
# Example: degree 8 polynomial with palindromic coefficients
coeffs = [1, 3, 0, 2, 5, 2, 0, 3, 1]  # palindromic
n = len(coeffs)
colors = []
for i in range(n):
    if i < n // 2:
        colors.append('#3498db')  # blue for free
    elif i == n // 2:
        colors.append('#e74c3c')  # red for middle
    else:
        colors.append('#95a5a6')  # gray for determined
bars = ax1.bar(range(n), coeffs, color=colors, edgecolor='white', linewidth=1.5)

# Draw mirror arrows
for i in range(n // 2):
    j = n - 1 - i
    ax1.annotate('', xy=(j, coeffs[j] + 0.3), xytext=(i, coeffs[i] + 0.3),
                arrowprops=dict(arrowstyle='<->', color='#2c3e50', lw=1.5, alpha=0.6))

ax1.set_xlabel('Coefficient index $i$', fontsize=12)
ax1.set_ylabel('$a_i$', fontsize=12)
ax1.set_title('Palindromic Coefficients: $a_i = a_{d-i}$')
ax1.set_xticks(range(n))
ax1.set_xticklabels([f'$a_{i}$' for i in range(n)])

# Legend
free_patch = mpatches.Patch(color='#3498db', label='Free coefficients')
middle_patch = mpatches.Patch(color='#e74c3c', label='Middle coefficient')
det_patch = mpatches.Patch(color='#95a5a6', label='Determined by symmetry')
ax1.legend(handles=[free_patch, middle_patch, det_patch], fontsize=9)
ax1.grid(True, alpha=0.3, axis='y')

# Panel 2: Parameter space size comparison
ax2 = axes[0, 1]
q_vals = [2, 3, 5, 7, 11]
n_vals = [1, 2, 3, 4]

x = np.arange(len(n_vals))
width = 0.15

for idx, q in enumerate(q_vals[:4]):
    generic_sizes = [q**(2*n) for n in n_vals]
    sr_sizes = [q**n for n in n_vals]
    offset = (idx - 1.5) * width
    ax2.bar(x + offset, [np.log10(s) for s in sr_sizes], width,
            label=f'$q={q}$ self-recip', alpha=0.8)

ax2.set_xlabel('Half-degree $n$', fontsize=12)
ax2.set_ylabel('$\\log_{10}$(parameter space size)', fontsize=12)
ax2.set_title('Search Space Compression: $q^{2n} \\to q^n$')
ax2.set_xticks(x)
ax2.set_xticklabels([f'$n={n}$' for n in n_vals])
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3, axis='y')

# Panel 3: Root inverse pairing on the unit circle
ax3 = axes[1, 0]
ax3.set_aspect('equal')

theta = np.linspace(0, 2 * np.pi, 200)
ax3.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.2, linewidth=1)

# Example roots: paired as z and z^{-1}
angles = [np.pi/6, np.pi/3, 2*np.pi/3, 5*np.pi/6]
for angle in angles:
    r = 1.3  # radius (not on unit circle for visibility)
    z = r * np.exp(1j * angle)
    z_inv = 1/z

    ax3.plot(z.real, z.imag, 'o', color='#3498db', markersize=10, zorder=5)
    ax3.plot(z_inv.real, z_inv.imag, 's', color='#e74c3c', markersize=10, zorder=5)

    # Draw pairing line
    ax3.plot([z.real, z_inv.real], [z.imag, z_inv.imag],
             '--', color='#95a5a6', alpha=0.5, linewidth=1)

    # Labels
    ax3.annotate(f'$z$', (z.real, z.imag), textcoords="offset points",
                xytext=(10, 5), fontsize=9, color='#3498db')
    ax3.annotate(f'$z^{{-1}}$', (z_inv.real, z_inv.imag), textcoords="offset points",
                xytext=(10, -10), fontsize=9, color='#e74c3c')

ax3.set_xlim(-2, 2)
ax3.set_ylim(-2, 2)
ax3.axhline(y=0, color='k', linewidth=0.5)
ax3.axvline(x=0, color='k', linewidth=0.5)
ax3.set_title('Root Inverse Pairing: $z \\leftrightarrow z^{-1}$')
ax3.set_xlabel('Re', fontsize=11)
ax3.set_ylabel('Im', fontsize=11)

root_patch = mpatches.Patch(color='#3498db', label='Root $z$')
inv_patch = mpatches.Patch(color='#e74c3c', label='Inverse root $z^{-1}$')
ax3.legend(handles=[root_patch, inv_patch], fontsize=10, loc='upper right')
ax3.grid(True, alpha=0.2)

# Panel 4: Irreducibility fraction among self-reciprocal polys
ax4 = axes[1, 1]

def count_sri_fast(q, n):
    """Count self-reciprocal irreducibles of degree 2n over GF(q)."""
    from itertools import product as cart_product
    count = 0
    for params in cart_product(range(q), repeat=n):
        half = [1] + list(params)
        full = list(half) + list(reversed(half[:-1]))
        full = [c % q for c in full]
        # Quick irreducibility via Rabin
        deg = len(full) - 1
        if deg <= 0:
            continue
        if deg == 1:
            count += 1
            continue
        # Use simplified test
        x_poly = [0, 1]
        from functools import reduce

        def pmul(a, b):
            if not a or not b:
                return []
            r = [0] * (len(a) + len(b) - 1)
            for i2, ai in enumerate(a):
                for j, bj in enumerate(b):
                    r[i2 + j] = (r[i2 + j] + ai * bj) % q
            while len(r) > 1 and r[-1] == 0:
                r.pop()
            return r

        def pmod(a, b):
            a = list(a)
            while len(a) >= len(b) and a:
                if a[-1] == 0:
                    a.pop()
                    continue
                c = (a[-1] * pow(b[-1], q - 2, q)) % q
                s = len(a) - len(b)
                for i2 in range(len(b)):
                    a[s + i2] = (a[s + i2] - c * b[i2]) % q
                while a and a[-1] == 0:
                    a.pop()
            return a if a else [0]

        def ppow(base, exp, mod):
            result = [1]
            base = pmod(base, mod)
            while exp > 0:
                if exp % 2 == 1:
                    result = pmod(pmul(result, base), mod)
                base = pmod(pmul(base, base), mod)
                exp //= 2
            return result

        def pgcd(a, b):
            while b and b != [0]:
                a, b = b, pmod(a, b)
            if not a:
                return [0]
            lc_inv = pow(a[-1], q - 2, q)
            return [(c * lc_inv) % q for c in a]

        xqn = ppow(x_poly, q**deg, full, q)
        diff = list(xqn)
        if len(diff) < 2:
            diff.extend([0] * (2 - len(diff)))
        diff[1] = (diff[1] - 1) % q
        rem = pmod(diff, full, q)
        if rem != [0] and any(c != 0 for c in rem):
            continue

        irred = True
        temp = deg
        prime_divs = set()
        for p in range(2, int(temp**0.5) + 2):
            while temp % p == 0:
                prime_divs.add(p)
                temp //= p
        if temp > 1:
            prime_divs.add(temp)
        for p in prime_divs:
            m = deg // p
            xqm = ppow(x_poly, q**m, full, q)
            d2 = list(xqm)
            if len(d2) < 2:
                d2.extend([0] * (2 - len(d2)))
            d2[1] = (d2[1] - 1) % q
            while d2 and d2[-1] == 0:
                d2.pop()
            if not d2:
                d2 = [0]
            g = pgcd(d2, full)
            if len(g) > 1:
                irred = False
                break
        if irred:
            count += 1
    return count


q_range = [2, 3, 5, 7, 11, 13]
for n in [1, 2, 3]:
    fractions = []
    qs_plot = []
    for q in q_range:
        if q**n <= 2000:
            sri = count_sri_fast(q, n)
            total = q**n
            fractions.append(sri / total)
            qs_plot.append(q)
    if qs_plot:
        ax4.plot(qs_plot, fractions, 'o-', label=f'$n={n}$', markersize=6)
        ax4.axhline(y=1/(2*n), color=ax4.get_lines()[-1].get_color(),
                    linestyle='--', alpha=0.4)

ax4.set_xlabel('Field size $q$', fontsize=12)
ax4.set_ylabel('Fraction irreducible', fontsize=12)
ax4.set_title('Irreducibility Rate Among Self-Reciprocal Polys')
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('palindromic_structure_visualization.png', dpi=150, bbox_inches='tight')
print("Saved palindromic_structure_visualization.png")
