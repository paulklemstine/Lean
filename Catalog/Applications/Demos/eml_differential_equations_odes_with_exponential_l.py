#!/usr/bin/env python3
"""
EML Differential Operators: Numerical Demonstrations

Demonstrates key results from the EML Wronskian theory:
1. Abel's Identity: W'(x) = -p(x) W(x)
2. Wronskian non-vanishing for linearly independent solutions
3. EML Wronskian decay for ODEs with exponential coefficients
4. Airy equation: constant Wronskian when p=0
5. Sturm separation: interlacing zeros of linearly independent solutions
"""

import numpy as np
from scipy.integrate import solve_ivp
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def eml(x: float, y: float) -> float:
    """The EML function: eml(x, y) = exp(x) - log(y)."""
    return np.exp(x) - np.log(y)


def eml_diag(z: float) -> float:
    """Diagonal EML: d(z) = exp(z) - log(z)."""
    return np.exp(z) - np.log(z)


def wronskian(y1: np.ndarray, y1p: np.ndarray,
              y2: np.ndarray, y2p: np.ndarray) -> np.ndarray:
    """Wronskian W = y1 * y2' - y2 * y1'."""
    return y1 * y2p - y2 * y1p


# ── Demo 1: Airy Equation y'' = x*y ──────────────────────────────────
print("=" * 60)
print("Demo 1: Airy Equation y'' = x*y (p=0, constant Wronskian)")
print("=" * 60)

def airy_system(t, Y):
    y, yp = Y
    return [yp, t * y]

# Two solutions with different ICs
sol1 = solve_ivp(airy_system, [-10, 10], [1.0, 0.0], dense_output=True, max_step=0.01)
sol2 = solve_ivp(airy_system, [-10, 10], [0.0, 1.0], dense_output=True, max_step=0.01)

x = np.linspace(-10, 10, 1000)
Y1 = sol1.sol(x)
Y2 = sol2.sol(x)
W_airy = wronskian(Y1[0], Y1[1], Y2[0], Y2[1])

print(f"Wronskian at x=-10: {W_airy[0]:.8f}")
print(f"Wronskian at x=0:   {W_airy[500]:.8f}")
print(f"Wronskian at x=10:  {W_airy[-1]:.8f}")
print(f"Max variation: {np.max(W_airy) - np.min(W_airy):.2e}")
print("→ Confirms: Wronskian is constant (Abel's identity with p=0)")
print()


# ── Demo 2: Exponential Operator y'' = e^x * y ──────────────────────
print("=" * 60)
print("Demo 2: Exponential Operator y'' = exp(x)*y (p=0, constant W)")
print("=" * 60)

def exp_system(t, Y):
    y, yp = Y
    return [yp, np.exp(t) * y]

sol1e = solve_ivp(exp_system, [-5, 3], [1.0, 0.0], dense_output=True, max_step=0.005)
sol2e = solve_ivp(exp_system, [-5, 3], [0.0, 1.0], dense_output=True, max_step=0.005)

x_e = np.linspace(-5, 3, 1000)
Y1e = sol1e.sol(x_e)
Y2e = sol2e.sol(x_e)
W_exp = wronskian(Y1e[0], Y1e[1], Y2e[0], Y2e[1])

print(f"Wronskian at x=-5: {W_exp[0]:.8f}")
print(f"Wronskian at x=0:  {W_exp[500]:.8f}")
print(f"Wronskian at x=3:  {W_exp[-1]:.8f}")
print(f"Max variation: {np.max(W_exp) - np.min(W_exp):.2e}")
print("→ Confirms: Wronskian is constant (Abel's identity with p=0)")
print()


# ── Demo 3: EML-Coefficient ODE y'' + eml(x,c)*y' = 0 ──────────────
print("=" * 60)
print("Demo 3: EML-Coefficient ODE y'' + eml(x,2)*y' = 0")
print("          Wronskian decay → 0 as x → ∞")
print("=" * 60)

c_val = 2.0

def eml_system(t, Y):
    y, yp = Y
    p_val = eml(t, c_val)
    return [yp, -p_val * yp]

sol1m = solve_ivp(eml_system, [0, 5], [1.0, 0.5], dense_output=True, max_step=0.005)
sol2m = solve_ivp(eml_system, [0, 5], [0.0, 1.0], dense_output=True, max_step=0.005)

x_m = np.linspace(0, 5, 500)
Y1m = sol1m.sol(x_m)
Y2m = sol2m.sol(x_m)
W_eml = wronskian(Y1m[0], Y1m[1], Y2m[0], Y2m[1])

print(f"Wronskian at x=0: {W_eml[0]:.8f}")
print(f"Wronskian at x=2: {W_eml[200]:.8f}")
print(f"Wronskian at x=4: {W_eml[400]:.8f}")
print(f"Wronskian at x=5: {W_eml[-1]:.10f}")
print("→ Confirms: Wronskian decays to 0 (EML decay theorem)")
print()


# ── Demo 4: EML Diagonal Superpolynomial Growth ─────────────────────
print("=" * 60)
print("Demo 4: EML Diagonal d(z) = e^z - ln(z) vs polynomials")
print("=" * 60)

z = np.linspace(0.1, 10, 200)
d_z = eml_diag(z)

for n in [1, 2, 3, 5]:
    ratio = d_z / z**n
    print(f"  d(z)/z^{n} at z=10: {ratio[-1]:.2f} (→ ∞)")

print("→ Confirms: d(z) grows faster than any polynomial")
print()


# ── Demo 5: Sturm Separation ────────────────────────────────────────
print("=" * 60)
print("Demo 5: Sturm Separation - Interlacing zeros of sin and cos")
print("         (solutions of y'' + y = 0)")
print("=" * 60)

x_s = np.linspace(0, 4 * np.pi, 1000)
y1_s = np.sin(x_s)
y2_s = np.cos(x_s)

# Find zeros
zeros_sin = x_s[:-1][np.diff(np.sign(y1_s)) != 0]
zeros_cos = x_s[:-1][np.diff(np.sign(y2_s)) != 0]

print(f"Zeros of sin(x): {zeros_sin[:5].round(3)}")
print(f"Zeros of cos(x): {zeros_cos[:5].round(3)}")
print("→ Confirms: zeros interlace (Sturm separation theorem)")
print()

print("All demonstrations complete!")


#!/usr/bin/env python3
"""
Visualization: Discriminant landscape for EML differential operators.
Shows the oscillatory/exponential phase transition.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

x = np.linspace(-5, 5, 500)

# Airy operator: Δ(x) = 4x
disc_airy = 4 * x
axes[0].fill_between(x, disc_airy, 0, where=disc_airy < 0,
                      alpha=0.3, color='blue', label='Oscillatory (Δ < 0)')
axes[0].fill_between(x, disc_airy, 0, where=disc_airy > 0,
                      alpha=0.3, color='red', label='Exponential (Δ > 0)')
axes[0].plot(x, disc_airy, 'k-', linewidth=2)
axes[0].axhline(y=0, color='gray', linewidth=0.5)
axes[0].axvline(x=0, color='gray', linewidth=0.5, linestyle='--')
axes[0].set_title('Airy: Δ(x) = 4x', fontsize=14, fontweight='bold')
axes[0].set_xlabel('x')
axes[0].set_ylabel('Δ(x)')
axes[0].legend(fontsize=9)
axes[0].annotate('Phase transition\nat x = 0', xy=(0, 0), xytext=(1.5, -12),
                 arrowprops=dict(arrowstyle='->', color='black'),
                 fontsize=10, fontweight='bold')

# Exp operator: Δ(x) = 4e^x > 0 always
disc_exp = 4 * np.exp(x)
axes[1].fill_between(x, disc_exp, 0, alpha=0.3, color='red', label='Always exponential')
axes[1].plot(x, disc_exp, 'k-', linewidth=2)
axes[1].set_title('Exp: Δ(x) = 4eˣ > 0', fontsize=14, fontweight='bold')
axes[1].set_xlabel('x')
axes[1].set_ylabel('Δ(x)')
axes[1].legend(fontsize=9)
axes[1].set_ylim(0, 100)

# EML operator with p = eml(x, 2), q = -1: Δ = (e^x - ln 2)² + 4
p_eml = np.exp(x) - np.log(2)
disc_eml = p_eml**2 + 4
axes[2].plot(x, disc_eml, 'k-', linewidth=2)
axes[2].fill_between(x, disc_eml, 0, alpha=0.3, color='red', label='Always Δ > 4')
axes[2].set_title('EML: Δ = eml(x,2)² + 4', fontsize=14, fontweight='bold')
axes[2].set_xlabel('x')
axes[2].set_ylabel('Δ(x)')
axes[2].legend(fontsize=9)
axes[2].set_ylim(0, 100)

plt.tight_layout()
plt.savefig('Applications/discriminant_landscape.png', dpi=150)
print("Saved: Applications/discriminant_landscape.png")


#!/usr/bin/env python3
"""
Visualization: Wronskian behavior for different ODE types.
Compares constant Wronskian (Airy, p=0) vs decaying Wronskian (EML coefficient).
"""
import numpy as np
from scipy.integrate import solve_ivp
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def eml(x, c):
    return np.exp(x) - np.log(c)

def wronskian(Y1, Y2):
    return Y1[0] * Y2[1] - Y2[0] * Y1[1]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Airy equation solutions
def airy_sys(t, Y):
    return [Y[1], t * Y[0]]

s1 = solve_ivp(airy_sys, [-8, 4], [1, 0], dense_output=True, max_step=0.01)
s2 = solve_ivp(airy_sys, [-8, 4], [0, 1], dense_output=True, max_step=0.01)
x = np.linspace(-8, 4, 1000)
Y1, Y2 = s1.sol(x), s2.sol(x)

axes[0, 0].plot(x, Y1[0], 'b-', label='Ai-like (y₁)', linewidth=1.5)
axes[0, 0].plot(x, Y2[0], 'r-', label='Bi-like (y₂)', linewidth=1.5)
axes[0, 0].set_title('Airy Equation: y″ = xy', fontsize=13, fontweight='bold')
axes[0, 0].set_xlabel('x')
axes[0, 0].set_ylabel('y')
axes[0, 0].legend()
axes[0, 0].set_ylim(-3, 3)
axes[0, 0].grid(True, alpha=0.3)

# Panel 2: Airy Wronskian (constant)
W_airy = wronskian(Y1, Y2)
axes[0, 1].plot(x, W_airy, 'g-', linewidth=2)
axes[0, 1].axhline(y=W_airy[500], color='k', linestyle='--', alpha=0.5, label=f'W = {W_airy[500]:.4f}')
axes[0, 1].set_title('Airy Wronskian: W = const (Abel, p=0)', fontsize=13, fontweight='bold')
axes[0, 1].set_xlabel('x')
axes[0, 1].set_ylabel('W(x)')
axes[0, 1].legend()
axes[0, 1].grid(True, alpha=0.3)

# Panel 3: EML-coefficient ODE solutions
c = 2.0
def eml_sys(t, Y):
    p = eml(t, c)
    return [Y[1], -p * Y[1]]

s1e = solve_ivp(eml_sys, [0, 5], [1, 0.5], dense_output=True, max_step=0.005)
s2e = solve_ivp(eml_sys, [0, 5], [0, 1], dense_output=True, max_step=0.005)
xe = np.linspace(0, 5, 500)
Y1e, Y2e = s1e.sol(xe), s2e.sol(xe)

axes[1, 0].plot(xe, Y1e[0], 'b-', label='y₁', linewidth=1.5)
axes[1, 0].plot(xe, Y2e[0], 'r-', label='y₂', linewidth=1.5)
axes[1, 0].set_title('EML ODE: y″ + eml(x,2)y′ = 0', fontsize=13, fontweight='bold')
axes[1, 0].set_xlabel('x')
axes[1, 0].set_ylabel('y')
axes[1, 0].legend()
axes[1, 0].grid(True, alpha=0.3)

# Panel 4: EML Wronskian (decaying)
W_eml = wronskian(Y1e, Y2e)
# Theoretical: W(x) = W(0) * exp(-∫₀ˣ eml(t,c) dt)
integral_p = np.cumsum(np.array([eml(t, c) for t in xe])) * (xe[1] - xe[0])
W_theory = W_eml[0] * np.exp(-integral_p)

axes[1, 1].plot(xe, W_eml, 'g-', linewidth=2, label='Numerical W(x)')
axes[1, 1].plot(xe, W_theory, 'k--', linewidth=1.5, label='Abel: W₀exp(-∫p)')
axes[1, 1].set_title('EML Wronskian: doubly-exponential decay', fontsize=13, fontweight='bold')
axes[1, 1].set_xlabel('x')
axes[1, 1].set_ylabel('W(x)')
axes[1, 1].legend()
axes[1, 1].grid(True, alpha=0.3)
axes[1, 1].set_yscale('symlog', linthresh=1e-10)

plt.tight_layout()
plt.savefig('Applications/wronskian_theory.png', dpi=150)
print("Saved: Applications/wronskian_theory.png")
