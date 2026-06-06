"""
Quantum Group Spectral Theory — Interactive Demo

Demonstrates the key results:
1. q-integers and their classical limit
2. The Chebyshev bridge: [n+1]_q = U_n(x)
3. Casimir eigenvalues and spectral gaps
4. Spectral telescoping convergence
5. Spectral statistics for q = e^{2*pi*i*gamma_1}
"""

import math
from typing import List


def q_integer(x: float, n: int) -> float:
    """Compute [n]_q with x = (q + q^{-1})/2."""
    if n == 0:
        return 0.0
    if n == 1:
        return 1.0
    a, b = 0.0, 1.0
    for _ in range(2, n + 1):
        a, b = b, 2 * x * b - a
    return b


def chebyshev_U(x: float, n: int) -> float:
    """Chebyshev polynomial of the second kind U_n(x)."""
    if n == 0:
        return 1.0
    if n == 1:
        return 2 * x
    a, b = 1.0, 2 * x
    for _ in range(2, n + 1):
        a, b = b, 2 * x * b - a
    return b


def casimir_eigenvalue(x: float, n: int) -> float:
    return q_integer(x, n) * q_integer(x, n + 1)


# ============================================================
# Demo 1: Classical Limit
# ============================================================
print("=" * 60)
print("DEMO 1: Classical Limit — q-integers become ordinary integers")
print("=" * 60)
print()
print("When x = 1 (i.e., q = 1), [n]_q = n:")
for n in range(11):
    val = q_integer(1.0, n)
    print(f"  [{n:2d}]_(q=1) = {val:6.1f}")

# ============================================================
# Demo 2: Chebyshev Bridge
# ============================================================
print()
print("=" * 60)
print("DEMO 2: The Chebyshev Bridge — [n+1]_q = U_n(x)")
print("=" * 60)
print()
x_test = math.cos(1.0)  # theta = 1 radian
print(f"Testing with x = cos(1) ≈ {x_test:.6f}:")
print(f"  {'n':>3s}  {'[n+1]_q':>14s}  {'U_n(x)':>14s}  {'|diff|':>10s}")
max_err = 0
for n in range(15):
    qi = q_integer(x_test, n + 1)
    cu = chebyshev_U(x_test, n)
    err = abs(qi - cu)
    max_err = max(max_err, err)
    print(f"  {n:3d}  {qi:14.8f}  {cu:14.8f}  {err:10.2e}")
print(f"\n  Maximum error: {max_err:.2e} (machine precision)")

# ============================================================
# Demo 3: Casimir Eigenvalues
# ============================================================
print()
print("=" * 60)
print("DEMO 3: Casimir Eigenvalues — classical vs quantum")
print("=" * 60)
print()
print("Classical Casimir eigenvalues n(n+1):")
for n in range(8):
    classical = casimir_eigenvalue(1.0, n)
    print(f"  λ_{n}(1) = {classical:6.1f}  =  {n}×{n+1}")

gamma1 = 14.134725141734693
theta1 = 2 * math.pi * gamma1
x_rz = math.cos(theta1)
print(f"\nQuantum Casimir with q = e^{{2πi·γ₁}}, γ₁ ≈ {gamma1:.4f}:")
print(f"  x = cos(2π·γ₁) ≈ {x_rz:.8f}")
for n in range(8):
    quantum = casimir_eigenvalue(x_rz, n)
    classical = n * (n + 1)
    print(f"  λ_{n}(q) = {quantum:12.6f}   (classical: {classical})")

# ============================================================
# Demo 4: Spectral Gaps
# ============================================================
print()
print("=" * 60)
print("DEMO 4: Spectral Gaps — linear (classical) vs oscillatory (quantum)")
print("=" * 60)
print()
print(f"  {'n':>3s}  {'Δ_n (classical)':>16s}  {'Δ_n (quantum)':>16s}")
for n in range(10):
    gap_classical = casimir_eigenvalue(1.0, n + 1) - casimir_eigenvalue(1.0, n)
    gap_quantum = casimir_eigenvalue(x_rz, n + 1) - casimir_eigenvalue(x_rz, n)
    print(f"  {n:3d}  {gap_classical:16.4f}  {gap_quantum:16.6f}")

# ============================================================
# Demo 5: Spectral Telescoping
# ============================================================
print()
print("=" * 60)
print("DEMO 5: Spectral Telescoping — ∑ 1/(k(k+1)) → 1")
print("=" * 60)
print()
print("  N          Sum              Expected         Error")
for N in [1, 2, 5, 10, 50, 100, 1000, 10000, 100000]:
    s = sum(1.0 / (k * (k + 1)) for k in range(1, N + 1))
    expected = 1 - 1 / (N + 1)
    print(f"  {N:>6d}   {s:16.12f}   {expected:16.12f}   {abs(s - expected):.2e}")

# ============================================================
# Demo 6: Addition Formula Verification
# ============================================================
print()
print("=" * 60)
print("DEMO 6: Addition Formula — [m+n+1] = [m+1][n+1] - [m][n]")
print("=" * 60)
print()
x = 0.3
print(f"Testing with x = {x}:")
errors = []
for m in range(6):
    for n in range(6):
        lhs = q_integer(x, m + n + 1)
        rhs = q_integer(x, m + 1) * q_integer(x, n + 1) - q_integer(x, m) * q_integer(x, n)
        errors.append(abs(lhs - rhs))
print(f"  Tested {len(errors)} (m,n) pairs, max error = {max(errors):.2e}")
print(f"  All {sum(1 for e in errors if e < 1e-10)}/{len(errors)} pairs verified to machine precision")

# ============================================================
# Demo 7: q-Integer Polynomial Values
# ============================================================
print()
print("=" * 60)
print("DEMO 7: q-Integers as Polynomials")
print("=" * 60)
print()
print("Theorem: [2]_q = 2x,  [3]_q = 4x²-1,  [4]_q = 8x³-4x")
print()
for x in [0.0, 0.25, 0.5, 0.75, 1.0]:
    q2 = q_integer(x, 2)
    q3 = q_integer(x, 3)
    q4 = q_integer(x, 4)
    p2 = 2 * x
    p3 = 4 * x**2 - 1
    p4 = 8 * x**3 - 4 * x
    print(f"  x = {x:.2f}:  [2]={q2:.4f} ({p2:.4f}),  [3]={q3:.4f} ({p3:.4f}),  [4]={q4:.4f} ({p4:.4f})")

# ============================================================
# Demo 8: Even q-integers vanish at x=0 (q=i)
# ============================================================
print()
print("=" * 60)
print("DEMO 8: At q=i (x=0), even q-integers vanish")
print("=" * 60)
print()
for n in range(12):
    val = q_integer(0.0, n)
    print(f"  [{n:2d}]_(q=i) = {val:6.1f}  {'← zero (even index)' if n >= 2 and n % 2 == 0 else ''}")

print()
print("=" * 60)
print("All demos completed successfully!")
print("=" * 60)


"""
Visualization: q-Casimir Spectrum — Classical vs Quantum

Plots the Casimir eigenvalues for different deformation parameters,
showing how the classical n(n+1) parabola deforms into oscillatory spectra.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def q_integer(x: float, n: int) -> float:
    if n == 0:
        return 0.0
    if n == 1:
        return 1.0
    a, b = 0.0, 1.0
    for _ in range(2, n + 1):
        a, b = b, 2 * x * b - a
    return b


def casimir_eigenvalue(x: float, n: int) -> float:
    return q_integer(x, n) * q_integer(x, n + 1)


N = 30
ns = list(range(N + 1))

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('q-Casimir Eigenvalue Spectra: Classical vs Quantum Deformations',
             fontsize=14, fontweight='bold')

# Panel 1: Classical (x=1)
ax = axes[0, 0]
eigs = [casimir_eigenvalue(1.0, n) for n in ns]
ax.plot(ns, eigs, 'b.-', markersize=6)
ax.set_title('Classical: x = 1 (q = 1)\nλ_n = n(n+1)', fontsize=11)
ax.set_xlabel('n')
ax.set_ylabel('λ_n')
ax.grid(True, alpha=0.3)

# Panel 2: Mild deformation (x=0.9)
ax = axes[0, 1]
x_val = 0.9
eigs = [casimir_eigenvalue(x_val, n) for n in ns]
ax.plot(ns, eigs, 'r.-', markersize=6)
ax.set_title(f'Mild deformation: x = {x_val}\n(oscillatory growth)', fontsize=11)
ax.set_xlabel('n')
ax.set_ylabel('λ_n')
ax.grid(True, alpha=0.3)

# Panel 3: Strong deformation (x=0.5)
ax = axes[1, 0]
x_val = 0.5
eigs = [casimir_eigenvalue(x_val, n) for n in ns]
ax.plot(ns, eigs, 'g.-', markersize=6)
ax.set_title(f'Strong deformation: x = {x_val}\n(bounded oscillations)', fontsize=11)
ax.set_xlabel('n')
ax.set_ylabel('λ_n')
ax.grid(True, alpha=0.3)

# Panel 4: Riemann zero deformation
ax = axes[1, 1]
gamma1 = 14.134725141734693
x_rz = math.cos(2 * math.pi * gamma1)
eigs = [casimir_eigenvalue(x_rz, n) for n in ns]
ax.plot(ns, eigs, 'm.-', markersize=6)
ax.set_title(f'Riemann zero: q = e^{{2πiγ₁}}\nx = cos(2πγ₁) ≈ {x_rz:.4f}', fontsize=11)
ax.set_xlabel('n')
ax.set_ylabel('λ_n')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('casimir_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved casimir_spectrum.png")


"""
Visualization: The Chebyshev Bridge — q-integers as Chebyshev polynomials

Shows the exact equality [n+1]_q = U_n(x) for several n values,
plotted as functions of x.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def q_integer(x: float, n: int) -> float:
    if n == 0:
        return 0.0
    if n == 1:
        return 1.0
    a, b = 0.0, 1.0
    for _ in range(2, n + 1):
        a, b = b, 2 * x * b - a
    return b


def chebyshev_U(x: float, n: int) -> float:
    if n == 0:
        return 1.0
    if n == 1:
        return 2 * x
    a, b = 1.0, 2 * x
    for _ in range(2, n + 1):
        a, b = b, 2 * x * b - a
    return b


xs = np.linspace(-1.0, 1.0, 500)

fig, axes = plt.subplots(2, 3, figsize=(15, 8))
fig.suptitle('The Chebyshev Bridge: [n+1]_q = U_n(x)\n'
             'q-integers (blue dots) ≡ Chebyshev polynomials of the 2nd kind (red line)',
             fontsize=13, fontweight='bold')

for idx, n in enumerate([0, 1, 2, 3, 4, 5]):
    ax = axes[idx // 3, idx % 3]

    # Chebyshev U_n as continuous curve
    ys_cheby = [chebyshev_U(x, n) for x in xs]
    ax.plot(xs, ys_cheby, 'r-', linewidth=2, label=f'U_{n}(x)')

    # q-integer [n+1] at sample points
    xs_sample = np.linspace(-1.0, 1.0, 30)
    ys_qint = [q_integer(x, n + 1) for x in xs_sample]
    ax.plot(xs_sample, ys_qint, 'b.', markersize=8, label=f'[{n+1}]_q')

    ax.set_title(f'[{n+1}]_q = U_{n}(x)', fontsize=11)
    ax.set_xlabel('x = cos(θ)')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)

plt.tight_layout()
plt.savefig('chebyshev_bridge.png', dpi=150, bbox_inches='tight')
print("Saved chebyshev_bridge.png")


"""
Visualization: Spectral Telescoping Convergence

Shows that sum_{k=1}^{N} 1/(k(k+1)) converges to 1 as N -> infinity,
demonstrating the spectral zeta normalization of the Casimir operator.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


Ns = list(range(1, 101))
partial_sums = []
s = 0.0
for N in range(1, 101):
    s += 1.0 / (N * (N + 1))
    partial_sums.append(s)

expected = [1 - 1 / (N + 1) for N in Ns]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
fig.suptitle('Spectral Telescoping: ∑ 1/(k(k+1)) = 1 − 1/(N+1) → 1',
             fontsize=14, fontweight='bold')

# Left: convergence
ax1.plot(Ns, partial_sums, 'b-', linewidth=2, label='∑ 1/(k(k+1))')
ax1.plot(Ns, expected, 'r--', linewidth=1, label='1 − 1/(N+1)')
ax1.axhline(y=1.0, color='g', linewidth=1, linestyle=':', label='Limit = 1')
ax1.set_xlabel('N', fontsize=12)
ax1.set_ylabel('Partial sum', fontsize=12)
ax1.set_title('Convergence to 1')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(0.4, 1.05)

# Right: error
errors = [abs(partial_sums[i] - expected[i]) for i in range(len(Ns))]
residuals = [1.0 - partial_sums[i] for i in range(len(Ns))]
ax2.semilogy(Ns, residuals, 'b-', linewidth=2, label='1 − partial sum')
ax2.semilogy(Ns, [1.0 / (N + 1) for N in Ns], 'r--', linewidth=1, label='1/(N+1)')
ax2.set_xlabel('N', fontsize=12)
ax2.set_ylabel('Residual (log scale)', fontsize=12)
ax2.set_title('Rate of convergence: O(1/N)')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_telescoping.png', dpi=150, bbox_inches='tight')
print("Saved spectral_telescoping.png")
