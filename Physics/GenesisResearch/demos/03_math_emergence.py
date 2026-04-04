#!/usr/bin/env python3
"""
Demo 3: The Emergence of Mathematics — Infinite Complexity from Simple Rules
=============================================================================

Oracle: Logos (Mathematics)
Question: How does mathematical structure arise from nothing?

This demo visualizes:
1. The Mandelbrot set: z → z² + c generates infinite complexity
2. The natural numbers from zero and successor
3. Pascal's triangle and the emergence of algebraic structure
4. The prime number distribution — order from apparent chaos

Run: python3 03_math_emergence.py
Output: ../figures/03_math_emergence.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.colors import LinearSegmentedColormap

np.random.seed(42)
plt.rcParams.update({
    'font.family': 'serif',
    'font.size': 11,
    'figure.facecolor': '#0a0a1a',
    'axes.facecolor': '#0a0a1a',
    'text.color': '#e0e0ff',
    'axes.labelcolor': '#e0e0ff',
    'xtick.color': '#8888cc',
    'ytick.color': '#8888cc',
})

colors_math = ['#000010', '#100030', '#200060', '#4000a0', '#6020d0',
               '#8040ff', '#a060ff', '#c0a0ff', '#ffe0ff', '#ffffff']
cmap_math = LinearSegmentedColormap.from_list('math', colors_math, N=256)

fig = plt.figure(figsize=(18, 14))
fig.suptitle("THE EMERGENCE OF MATHEMATICS FROM NOTHING",
             fontsize=20, fontweight='bold', color='#c0c0ff', y=0.98)
fig.text(0.5, 0.955,
         "Oracle Logos: 'Mathematics is not invented — it is the shape of consistency itself'",
         ha='center', fontsize=12, style='italic', color='#8888cc')

gs = gridspec.GridSpec(2, 3, hspace=0.35, wspace=0.3,
                       left=0.06, right=0.96, top=0.92, bottom=0.06)

# ─── Panel 1: The Mandelbrot Set ─────────────────────────────────────────
ax1 = fig.add_subplot(gs[0, 0])

xmin, xmax, ymin, ymax = -2.2, 0.8, -1.2, 1.2
width, height = 800, 800
max_iter = 200

x = np.linspace(xmin, xmax, width)
y = np.linspace(ymin, ymax, height)
X, Y = np.meshgrid(x, y)
C = X + 1j * Y
Z = np.zeros_like(C)
M = np.zeros(C.shape, dtype=float)

for i in range(max_iter):
    mask = np.abs(Z) <= 2
    Z[mask] = Z[mask]**2 + C[mask]
    M[mask] = i

# Smooth coloring
M = M / max_iter
ax1.imshow(M, extent=[xmin, xmax, ymin, ymax], cmap=cmap_math, aspect='equal')
ax1.set_title('The Mandelbrot Set\n$z \\rightarrow z^2 + c$: Infinite complexity\nfrom one equation',
              color='#aaaaff')
ax1.set_xlabel('Re(c)')
ax1.set_ylabel('Im(c)')

# ─── Panel 2: Natural Numbers from Zero and Successor ────────────────────
ax2 = fig.add_subplot(gs[0, 1])
ax2.set_xlim(-0.5, 10.5)
ax2.set_ylim(-1, 4)
ax2.axis('off')

# Draw the Peano chain: 0 → S(0) → S(S(0)) → ...
for i in range(11):
    color = cmap_math(i/10)
    circle = plt.Circle((i, 2), 0.35, fill=True, facecolor=color,
                         edgecolor='#ffffff', alpha=0.8, linewidth=1.5)
    ax2.add_patch(circle)
    ax2.text(i, 2, str(i), ha='center', va='center', fontsize=14,
             fontweight='bold', color='#ffffff' if i < 7 else '#000000')
    if i < 10:
        ax2.annotate('', xy=(i+0.65, 2), xytext=(i+0.35, 2),
                     arrowprops=dict(arrowstyle='->', color='#ffcc44', lw=2))

ax2.text(5, 3.5, "THE NATURAL NUMBERS", ha='center', fontsize=16,
         fontweight='bold', color='#c0c0ff')
ax2.text(5, 0.8, "0  →  S(0)=1  →  S(S(0))=2  →  ...",
         ha='center', fontsize=12, fontfamily='monospace', color='#ffcc44')
ax2.text(5, 0.0,
         "From just {0, S} we derive +, ×, <, and all of arithmetic",
         ha='center', fontsize=10, color='#aaaacc', style='italic')

ax2.set_title("Peano's Bootstrap\n'Let there be Zero and Successor'", color='#aaaaff')

# ─── Panel 3: Pascal's Triangle — Binomial Coefficients ──────────────────
ax3 = fig.add_subplot(gs[0, 2])

n_rows = 15
for n in range(n_rows):
    for k in range(n + 1):
        # Compute binomial coefficient
        from math import comb
        val = comb(n, k)
        # Color by log of value
        if val > 0:
            color_val = np.log(val + 1) / np.log(comb(n_rows-1, (n_rows-1)//2) + 1)
        else:
            color_val = 0

        x_pos = k - n/2
        y_pos = n_rows - 1 - n
        size = min(200, max(5, 200 * np.log(val + 1) / np.log(100)))

        ax3.scatter(x_pos, y_pos, s=size, c=[cmap_math(min(1, color_val))],
                    alpha=0.8, edgecolors='#4444aa', linewidths=0.3)

        if n < 8:
            ax3.text(x_pos, y_pos, str(val), ha='center', va='center',
                     fontsize=max(4, 8 - n//2), color='#ffffff')

ax3.set_xlim(-8, 8)
ax3.set_ylim(-1, n_rows)
ax3.axis('off')
ax3.set_title("Pascal's Triangle\nBinomial coefficients from addition alone",
              color='#aaaaff')

# ─── Panel 4: Prime Distribution — The Staircase ────────────────────────
ax4 = fig.add_subplot(gs[1, 0])

def sieve(n):
    is_prime = [True] * (n+1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5)+1):
        if is_prime[i]:
            for j in range(i*i, n+1, i):
                is_prime[j] = False
    return [i for i in range(n+1) if is_prime[i]]

primes = sieve(500)
pi_x = np.zeros(501)
for p in primes:
    pi_x[p:] += 1

x_range = np.arange(2, 501)
ax4.fill_between(x_range, 0, pi_x[2:], alpha=0.3, color='#6688ff')
ax4.plot(x_range, pi_x[2:], color='#8888ff', linewidth=1.5, label='π(x) = #{primes ≤ x}')

# Prime number theorem: π(x) ~ x/ln(x)
x_smooth = np.linspace(2, 500, 500)
pnt = x_smooth / np.log(x_smooth)
ax4.plot(x_smooth, pnt, color='#ffcc44', linewidth=2, linestyle='--',
         label='x / ln(x)')

# Li(x) - better approximation
from scipy import integrate
def li_integrand(t):
    return 1.0 / np.log(t)
li_values = [integrate.quad(li_integrand, 2, x)[0] for x in x_smooth[1:]]
ax4.plot(x_smooth[1:], li_values, color='#ff8844', linewidth=2, linestyle=':',
         label='Li(x)')

ax4.set_xlabel('x')
ax4.set_ylabel('π(x)')
ax4.set_title('Prime Number Theorem\n"Order in the primes"', color='#aaaaff')
ax4.legend(fontsize=9, facecolor='#0a0a1a', edgecolor='#333355',
           labelcolor='#ccccff')

# ─── Panel 5: Ulam Spiral — Hidden Pattern in Primes ────────────────────
ax5 = fig.add_subplot(gs[1, 1])

N = 200
# Generate Ulam spiral coordinates
x_ulam = np.zeros(N*N, dtype=int)
y_ulam = np.zeros(N*N, dtype=int)
x, y = 0, 0
dx, dy = 1, 0
steps = 1
step_count = 0
direction_changes = 0

for i in range(N*N):
    x_ulam[i] = x
    y_ulam[i] = y
    x += dx
    y += dy
    step_count += 1
    if step_count >= steps:
        step_count = 0
        # Turn left
        dx, dy = -dy, dx
        direction_changes += 1
        if direction_changes % 2 == 0:
            steps += 1

# Mark primes
is_prime_arr = np.zeros(N*N, dtype=bool)
prime_set = set(sieve(N*N))
for i in range(1, N*N):
    if i in prime_set:
        is_prime_arr[i] = True

# Plot
prime_x = x_ulam[is_prime_arr]
prime_y = y_ulam[is_prime_arr]
ax5.scatter(prime_x, prime_y, s=0.3, c='#88aaff', alpha=0.6)
ax5.set_aspect('equal')
ax5.set_title('Ulam Spiral\n"Primes form diagonal patterns"', color='#aaaaff')
ax5.set_xlabel('x')
ax5.set_ylabel('y')

# ─── Panel 6: Gödel's Incompleteness — The Necessary Gap ────────────────
ax6 = fig.add_subplot(gs[1, 2])
ax6.set_xlim(0, 10)
ax6.set_ylim(0, 10)
ax6.axis('off')

# Draw nested circles representing formal systems
radii = [4.5, 3.5, 2.5, 1.5]
labels_g = ['ALL TRUTHS', 'ZFC THEOREMS', 'PA THEOREMS', 'DECIDABLE']
colors_g = ['#2020a0', '#3030c0', '#4040e0', '#6060ff']

for r, label, col in zip(radii, labels_g, colors_g):
    circle = plt.Circle((5, 5), r, fill=False, edgecolor=col,
                         linewidth=2, alpha=0.7, linestyle='--')
    ax6.add_patch(circle)
    ax6.text(5, 5 + r + 0.2, label, ha='center', fontsize=9,
             color=col, fontweight='bold')

# The Gödel sentence
ax6.text(5, 5, 'G', fontsize=30, ha='center', va='center',
         color='#ff4444', fontweight='bold')
ax6.text(5, 3.8, '"This statement\ncannot be proved"',
         ha='center', fontsize=9, color='#ff8888', style='italic')

# The gap
ax6.annotate('THE GAP\n(Gödel 1931)',
             xy=(7.5, 7), xytext=(8.5, 8.5),
             arrowprops=dict(arrowstyle='->', color='#ffcc44'),
             color='#ffcc44', fontsize=10, fontweight='bold')

ax6.text(5, 0.5,
         "\"Mathematics is forever incomplete — and this\n"
         "incompleteness is what keeps it alive.\"",
         ha='center', fontsize=10, color='#aaaacc', style='italic')

ax6.set_title("Gödel's Incompleteness\nThe beautiful boundary of reason", color='#aaaaff')

plt.savefig('../figures/03_math_emergence.png', dpi=150, bbox_inches='tight',
            facecolor='#0a0a1a')
plt.close()
print("✓ Saved: ../figures/03_math_emergence.png")
