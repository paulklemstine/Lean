#!/usr/bin/env python3
"""
Quantum EML Neurons: Numerical Demonstrations

Demonstrates the key results from the quantum EML neuron theory:
1. Phase invariance of amplitude
2. Circle coverage for fixed coupling
3. Surjectivity (any complex number as QEML output)
4. Constructive/destructive interference
5. Classical-quantum bridge
"""

import numpy as np

def qeml(theta: float, t: float) -> complex:
    """Quantum EML neuron: exp(i*theta) * log(1 + i*t)"""
    return np.exp(1j * theta) * np.log(1 + 1j * t)

def qeml_amplitude(t: float) -> float:
    """Amplitude component: |log(1 + i*t)|"""
    return abs(np.log(1 + 1j * t))

def qeml_intrinsic_phase(t: float) -> float:
    """Intrinsic phase of log(1 + i*t)"""
    return np.angle(np.log(1 + 1j * t))


# ============================================================
# Demo 1: Phase Invariance
# ============================================================
print("=" * 60)
print("DEMO 1: Phase Invariance of Amplitude")
print("=" * 60)
print("\nFor fixed t, |qeml(θ, t)| is independent of θ:")
t_fixed = 2.0
for theta in [0, np.pi/4, np.pi/2, np.pi, 3*np.pi/2]:
    amp = abs(qeml(theta, t_fixed))
    print(f"  θ = {theta:.4f}, |qeml(θ, {t_fixed})| = {amp:.8f}")
print(f"  qemlAmplitude({t_fixed}) = {qeml_amplitude(t_fixed):.8f}")

# ============================================================
# Demo 2: Circle Coverage
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Circle Coverage (Fixed Coupling)")
print("=" * 60)
print("\nFor t = 1.5, qeml traces a circle of radius r:")
t_val = 1.5
r = qeml_amplitude(t_val)
print(f"  Radius = {r:.6f}")
thetas = np.linspace(0, 2*np.pi, 8, endpoint=False)
print("  Points on circle:")
for th in thetas:
    z = qeml(th, t_val)
    print(f"    θ={th:.2f}: ({z.real:.4f}, {z.imag:.4f}), |z|={abs(z):.6f}")

# ============================================================
# Demo 3: Surjectivity
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Surjectivity — Matching Any Complex Number")
print("=" * 60)

def find_qeml_params(z: complex) -> tuple:
    """Find (θ, t) such that qeml(θ, t) ≈ z"""
    if abs(z) < 1e-15:
        return (0.0, 0.0)
    # Binary search for t such that qeml_amplitude(t) = |z|
    target_amp = abs(z)
    t_lo, t_hi = 0.0, 1.0
    while qeml_amplitude(t_hi) < target_amp:
        t_hi *= 2
    for _ in range(100):
        t_mid = (t_lo + t_hi) / 2
        if qeml_amplitude(t_mid) < target_amp:
            t_lo = t_mid
        else:
            t_hi = t_mid
    t0 = (t_lo + t_hi) / 2
    # Find θ
    w = np.log(1 + 1j * t0)
    theta = np.angle(z / w)
    return (theta, t0)

targets = [1+0j, 0+1j, -1+0j, 2+3j, 0.5-0.5j, 10+0j]
for z_target in targets:
    theta, t = find_qeml_params(z_target)
    z_actual = qeml(theta, t)
    err = abs(z_actual - z_target)
    print(f"  Target: {str(z_target):>10s}  →  θ={theta:.4f}, t={t:.4f}  →  "
          f"qeml = ({z_actual.real:.4f}, {z_actual.imag:.4f})  error={err:.2e}")

# ============================================================
# Demo 4: Interference
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Constructive vs Destructive Interference")
print("=" * 60)

t1, t2 = 1.0, 1.0
theta = 0.0
# Constructive: same phase
z_constr = qeml(theta, t1) + qeml(theta, t2)
# Destructive: opposite phase
z_destr = qeml(theta, t1) + qeml(theta + np.pi, t2)
max_amp = qeml_amplitude(t1) + qeml_amplitude(t2)
print(f"  t₁ = {t1}, t₂ = {t2}")
print(f"  Max possible amplitude: {max_amp:.6f}")
print(f"  Constructive (same θ): |sum| = {abs(z_constr):.6f}")
print(f"  Destructive (θ+π):     |sum| = {abs(z_destr):.6f}")

# ============================================================
# Demo 5: Classical-Quantum Bridge
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Classical-Quantum Bridge")
print("=" * 60)
print("\nRe(qeml(0,t)) = log(√(1+t²)) vs classical activations:")
print(f"  {'t':>6s}  {'Re(qeml)':>10s}  {'Im(qeml)':>10s}  {'log(1+t²)/2':>12s}  {'arctan(t)':>10s}")
for t in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0]:
    z = qeml(0, t)
    log_val = 0.5 * np.log(1 + t**2)
    atan_val = np.arctan(t)
    print(f"  {t:6.1f}  {z.real:10.6f}  {z.imag:10.6f}  {log_val:12.6f}  {atan_val:10.6f}")

# ============================================================
# Demo 6: QPA Monoid Structure
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: QPA Monoid — Polar Multiplication")
print("=" * 60)

class QPA:
    def __init__(self, amplitude, phase):
        self.amplitude = max(0, amplitude)
        self.phase = phase
    def mul(self, other):
        return QPA(self.amplitude * other.amplitude, self.phase + other.phase)
    def to_complex(self):
        return self.amplitude * np.exp(1j * self.phase)
    def __repr__(self):
        return f"QPA(r={self.amplitude:.4f}, φ={self.phase:.4f})"

q1 = QPA(2.0, np.pi/4)
q2 = QPA(1.5, np.pi/3)
q3 = q1.mul(q2)
print(f"  q₁ = {q1}")
print(f"  q₂ = {q2}")
print(f"  q₁·q₂ = {q3}")
print(f"  q₁.toComplex = {q1.to_complex():.4f}")
print(f"  q₂.toComplex = {q2.to_complex():.4f}")
print(f"  Product of complexes: {q1.to_complex() * q2.to_complex():.4f}")
print(f"  (q₁·q₂).toComplex: {q3.to_complex():.4f}")
print(f"  Homomorphism check: {abs(q1.to_complex() * q2.to_complex() - q3.to_complex()):.2e}")

# ============================================================
# Demo 7: Amplitude Growth
# ============================================================
print("\n" + "=" * 60)
print("DEMO 7: Amplitude Growth (Logarithmic)")
print("=" * 60)
ts = [0.01, 0.1, 1, 10, 100, 1000, 10000]
print(f"  {'t':>8s}  {'amplitude':>10s}  {'log(t+1)':>10s}  {'ratio':>8s}")
for t in ts:
    amp = qeml_amplitude(t)
    log_bound = np.log(t + 1)
    ratio = amp / log_bound if log_bound > 0 else float('inf')
    print(f"  {t:8.1f}  {amp:10.6f}  {log_bound:10.6f}  {ratio:8.4f}")

print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Quantum EML Circle Coverage

Shows how quantum EML neurons trace circles in the complex plane
for different coupling values, demonstrating the surjectivity theorem.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def qeml(theta, t):
    """Quantum EML neuron"""
    return np.exp(1j * theta) * np.log(1 + 1j * t)

def qeml_amplitude(t):
    """Amplitude function"""
    return abs(np.log(1 + 1j * t))

# Create figure with multiple panels
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Circle coverage
ax1 = axes[0]
thetas = np.linspace(0, 2 * np.pi, 200)
couplings = [0.5, 1.0, 2.0, 5.0, 10.0]
colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(couplings)))

for t, color in zip(couplings, colors):
    zs = [qeml(th, t) for th in thetas]
    xs = [z.real for z in zs]
    ys = [z.imag for z in zs]
    ax1.plot(xs, ys, color=color, linewidth=1.5,
             label=f't = {t}')
    # Mark t=0 phase point
    z0 = qeml(0, t)
    ax1.plot(z0.real, z0.imag, 'o', color=color, markersize=4)

ax1.set_xlabel('Re(z)', fontsize=11)
ax1.set_ylabel('Im(z)', fontsize=11)
ax1.set_title('QEML Circles for Varying Coupling', fontsize=12, fontweight='bold')
ax1.legend(fontsize=9, loc='upper left')
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.3)
ax1.axhline(y=0, color='gray', linewidth=0.5)
ax1.axvline(x=0, color='gray', linewidth=0.5)

# Panel 2: Amplitude function
ax2 = axes[1]
ts = np.linspace(0, 20, 500)
amps = [qeml_amplitude(t) for t in ts]
log_bound = [np.log(t + 1) for t in ts]

ax2.plot(ts, amps, 'b-', linewidth=2, label='qemlAmplitude(t)')
ax2.plot(ts, log_bound, 'r--', linewidth=1.5, label='log(t+1)')
ax2.plot(ts, ts, 'g:', linewidth=1, label='t (linear)')

ax2.set_xlabel('Coupling parameter t', fontsize=11)
ax2.set_ylabel('Amplitude', fontsize=11)
ax2.set_title('Amplitude Growth (Logarithmic)', fontsize=12, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 4)

# Panel 3: Classical-quantum bridge
ax3 = axes[2]
ts_fine = np.linspace(0.01, 5, 200)
re_vals = [np.log(np.sqrt(1 + t**2)) for t in ts_fine]
im_vals = [np.arctan(t) for t in ts_fine]
classical_relu = [max(0, t - 1) for t in ts_fine]
classical_sigmoid = [1 / (1 + np.exp(-t)) for t in ts_fine]

ax3.plot(ts_fine, re_vals, 'b-', linewidth=2,
         label='Re(qeml(0,t)) = ½log(1+t²)')
ax3.plot(ts_fine, im_vals, 'r-', linewidth=2,
         label='Im(qeml(0,t)) = arctan(t)')
ax3.plot(ts_fine, classical_relu, 'g--', linewidth=1.5,
         label='ReLU(t-1)')
ax3.plot(ts_fine, classical_sigmoid, 'm--', linewidth=1.5,
         label='Sigmoid(t)')

ax3.set_xlabel('Input t', fontsize=11)
ax3.set_ylabel('Activation', fontsize=11)
ax3.set_title('Quantum vs Classical Activations', fontsize=12, fontweight='bold')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('Applications/qeml_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: Applications/qeml_visualization.png")
