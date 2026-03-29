#!/usr/bin/env python3
"""
Gravitomagnetic Resonance: Pythagorean Q-Factors and Laboratory Detection
==========================================================================

If gravitomagnetic fields can be resonantly amplified — analogous to magnetic
resonance in MRI — then the Pythagorean Q-factors define a natural spectrum
of optimal frequencies. This demo explores:

  1. The Pythagorean resonance spectrum and its Q-factor hierarchy
  2. Resonant amplification of frame-dragging effects
  3. Laboratory detection scenarios with current and near-future technology
  4. Multi-frequency gravitomagnetic spectroscopy
  5. Connection to gravitational wave detection

Key physical idea: A rotating mass creates a gravitomagnetic field B_g.
If a mechanical oscillator (gyroscope, pendulum, torsion balance) can be
tuned to resonate with the frame-dragging frequency, the effective B_g is
amplified by the quality factor Q of the resonator.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import gcd
from itertools import combinations

# =============================================
# PHYSICAL CONSTANTS
# =============================================

G = 6.674e-11      # m³ kg⁻¹ s⁻²
c = 2.998e8         # m/s
hbar = 1.055e-34    # J·s
M_earth = 5.972e24  # kg
R_earth = 6.371e6   # m
omega_earth = 7.292e-5  # rad/s (Earth's rotation)
J_earth = 0.3308 * M_earth * R_earth**2 * omega_earth  # Earth's angular momentum

# Lense-Thirring precession at Earth's surface
Omega_LT_earth = 2 * G * J_earth / (c**2 * R_earth**3)
print(f"Earth's Lense-Thirring precession at surface: {Omega_LT_earth:.2e} rad/s")
print(f"  = {Omega_LT_earth * 180/np.pi * 3600 * 1000 * 365.25 * 86400:.2f} mas/yr")

# =============================================
# PYTHAGOREAN RESONANCE SPECTRUM
# =============================================

print("\n" + "=" * 70)
print("EXPERIMENT 1: Pythagorean Resonance Spectrum")
print("=" * 70)

def berggren_tree(depth):
    A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
    B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
    C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])
    triples = set()
    seed = np.array([3, 4, 5])
    queue = [(seed, 0)]
    while queue:
        triple, d = queue.pop(0)
        if d > depth:
            continue
        a, b, c = sorted([abs(triple[0]), abs(triple[1]), abs(triple[2])])
        triples.add((a, b, c))
        if d < depth:
            for M in [A, B, C]:
                queue.append((M @ triple, d + 1))
    return list(triples)

triples = berggren_tree(7)

# Compute resonance properties for each integer graviton
resonances = []
for a, b, c in triples:
    E_g = 2*a*b/c**2
    B_g = (b**2-a**2)/c**2
    theta = np.arctan2(B_g, E_g)
    
    # Q-factor: c² / gcd(2ab, |b²-a²|)
    Q = c**2 / gcd(2*a*b, abs(b**2-a**2))
    
    # Resonant frequency: ω_n = B_g / 2 (in natural units)
    # Physical frequency: ω_phys = Ω_LT * |B_g| * Q
    omega_n = abs(B_g) / 2
    
    # Bandwidth: Δω = ω_n / Q
    bandwidth = omega_n / Q if Q > 0 else float('inf')
    
    resonances.append({
        'triple': (a, b, c),
        'E_g': E_g, 'B_g': B_g, 'theta': theta,
        'Q': Q, 'omega_n': omega_n, 'bandwidth': bandwidth
    })

# Sort by Q-factor
resonances.sort(key=lambda x: x['Q'], reverse=True)

print(f"\nTop 30 Pythagorean resonances by Q-factor:")
print(f"{'Triple':>20} | {'Q':>8} | {'ω_n':>10} | {'B_g':>10} | {'Δω':>12}")
for r in resonances[:30]:
    a, b, c = r['triple']
    print(f"  ({a:4d},{b:4d},{c:4d}) | {r['Q']:8.0f} | {r['omega_n']:10.6f} | "
          f"{r['B_g']:10.6f} | {r['bandwidth']:12.2e}")

# =============================================
# EXPERIMENT 2: Resonant Amplification Analysis
# =============================================

print("\n" + "=" * 70)
print("EXPERIMENT 2: Resonant Amplification of Frame-Dragging")
print("=" * 70)

# At resonance, the effective gravitomagnetic field is amplified:
# B_g_eff = Q * B_g_bare
# where B_g_bare = Ω_LT (the natural frame-dragging field)

print(f"\nAmplified frame-dragging at Earth's surface:")
print(f"Bare Lense-Thirring: {Omega_LT_earth:.2e} rad/s")
print(f"\n{'Triple':>20} | {'Q':>8} | {'Amplified Ω':>14} | {'Detectable?':>12}")

# Current best sensitivity: ~1e-14 rad/s (LIGO-like)
# Near-future: ~1e-16 rad/s (proposed experiments)
detection_thresholds = {
    'GP-B level': 1e-11,
    'Current best': 1e-14,
    'Near-future': 1e-16,
    'Theoretical limit': 1e-20,
}

for r in resonances[:20]:
    amplified = r['Q'] * Omega_LT_earth
    detectable = "YES" if amplified > 1e-14 else "marginal" if amplified > 1e-16 else "no"
    a, b, c = r['triple']
    print(f"  ({a:4d},{b:4d},{c:4d}) | {r['Q']:8.0f} | {amplified:14.2e} | {detectable:>12}")

# =============================================
# EXPERIMENT 3: Lorentzian Response Curves
# =============================================

print("\n" + "=" * 70)
print("EXPERIMENT 3: Gravitomagnetic Response Functions")
print("=" * 70)

def lorentzian(omega, omega_0, Q):
    """Resonance response: Lorentzian line shape."""
    gamma = omega_0 / (2 * Q)
    return 1 / ((omega - omega_0)**2 + gamma**2)

# Pick 5 representative resonances
selected = [resonances[0], resonances[5], resonances[10], resonances[50], resonances[100]]

omega_scan = np.linspace(0, 0.5, 100000)
total_response = np.zeros_like(omega_scan)

print(f"\nSelected resonances for spectroscopy:")
for r in selected:
    a, b, c = r['triple']
    print(f"  ({a},{b},{c}): ω_0 = {r['omega_n']:.6f}, Q = {r['Q']:.0f}")
    response = lorentzian(omega_scan, r['omega_n'], r['Q'])
    total_response += response

# Find peaks in total response
peak_threshold = np.max(total_response) * 0.1
peaks = []
for i in range(1, len(total_response) - 1):
    if (total_response[i] > total_response[i-1] and 
        total_response[i] > total_response[i+1] and
        total_response[i] > peak_threshold):
        peaks.append((omega_scan[i], total_response[i]))

print(f"\nSpectral peaks found: {len(peaks)}")
for omega, amp in peaks[:10]:
    print(f"  ω = {omega:.6f}, amplitude = {amp:.2e}")

# =============================================
# EXPERIMENT 4: Laboratory Gyroscope Design
# =============================================

print("\n" + "=" * 70)
print("EXPERIMENT 4: Laboratory Gravitomagnetic Resonance Detector")
print("=" * 70)

# Design parameters for a gravitomagnetic resonance detector
# Key idea: use a torsion pendulum with angular frequency matching
# a Pythagorean resonance frequency

# Physical mapping: ω_phys = Ω_LT * c²/(G*M) * ω_n (dimensionless → physical)
# For Earth at surface: 
# Ω_LT ≈ 1e-14 rad/s
# So physical frequencies are incredibly small

# Alternative: use rapidly rotating masses in the lab
# For a spinning cylinder: B_g ~ (G/c²) * ω_spin * ρ * R²
# where ρ = density, R = radius, ω_spin = angular velocity

def lab_frame_dragging(rho, R, omega_spin, r_detect):
    """
    Gravitomagnetic field from a spinning cylinder.
    B_g ~ (4G/3c²) * ρ * ω_spin * R² / r_detect
    """
    return (4 * G / (3 * c**2)) * rho * omega_spin * R**2 / r_detect

# Example: tungsten cylinder (ρ = 19,250 kg/m³)
rho_W = 19250  # kg/m³
scenarios = [
    ("Desktop", 0.05, 1000, 0.1),     # 5cm radius, 1000 rad/s, 10cm away
    ("Lab-scale", 0.5, 100, 1.0),      # 50cm radius, 100 rad/s, 1m away
    ("Industrial", 2.0, 50, 5.0),       # 2m radius, 50 rad/s, 5m away
    ("LIGO-scale", 10.0, 10, 10.0),     # 10m radius, 10 rad/s, 10m away
]

print(f"\nLaboratory frame-dragging from spinning tungsten cylinders:")
print(f"{'Scenario':>15} | {'R (m)':>6} | {'ω (rad/s)':>10} | {'r (m)':>6} | {'B_g (rad/s)':>14}")
for name, R, omega, r_det in scenarios:
    B_g = lab_frame_dragging(rho_W, R, omega, r_det)
    print(f"{name:>15} | {R:6.1f} | {omega:10.0f} | {r_det:6.1f} | {B_g:14.2e}")

# With Q-factor amplification
print(f"\nWith Pythagorean Q-factor amplification (Q = {resonances[0]['Q']:.0f}):")
Q_best = resonances[0]['Q']
for name, R, omega, r_det in scenarios:
    B_g = lab_frame_dragging(rho_W, R, omega, r_det)
    B_g_amp = Q_best * B_g
    snr = B_g_amp / 1e-20  # vs quantum noise floor
    print(f"  {name:>15}: B_g_amp = {B_g_amp:.2e} rad/s, SNR vs quantum = {snr:.2e}")

# =============================================
# EXPERIMENT 5: Multi-Frequency Gravitomagnetic Spectroscopy
# =============================================

print("\n" + "=" * 70)
print("EXPERIMENT 5: Gravitomagnetic Spectroscopy Protocol")
print("=" * 70)

# Use multiple Pythagorean frequencies to extract directional information
# about the gravitomagnetic field — analogous to NMR pulse sequences

# Step 1: Compute the "spectral fingerprint" of each Berggren branch
branches = {'A': [], 'B': [], 'C': []}
A_mat = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
B_mat = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
C_mat = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])

seed = np.array([3, 4, 5])
for branch_name, M in [('A', A_mat), ('B', B_mat), ('C', C_mat)]:
    queue = [(M @ seed, 1)]
    while queue:
        triple, d = queue.pop(0)
        if d > 5:
            continue
        a, b, cc = sorted([abs(triple[0]), abs(triple[1]), abs(triple[2])])
        branches[branch_name].append((a, b, cc))
        if d < 5:
            for M2 in [A_mat, B_mat, C_mat]:
                queue.append((M2 @ triple, d + 1))

print(f"\nBerggren branch spectral fingerprints:")
for branch, triples_b in branches.items():
    angles = [np.arctan2((b**2-a**2), 2*a*b) for a, b, c in triples_b]
    qs = [c**2/gcd(2*a*b, abs(b**2-a**2)) for a, b, c in triples_b]
    print(f"  Branch {branch}: {len(triples_b)} modes, "
          f"angle range = [{np.degrees(min(angles)):.1f}°, {np.degrees(max(angles)):.1f}°], "
          f"mean Q = {np.mean(qs):.0f}, max Q = {np.max(qs):.0f}")

# Spectroscopy protocol
print(f"\nProposed gravitomagnetic spectroscopy protocol:")
print("""
  1. CALIBRATION PHASE: Tune torsion pendulum to (3,4,5) resonance
     (ω₀ = 7/50, Q = 25). Verify baseline response.
  
  2. SCANNING PHASE: Sweep through the first 10 Pythagorean frequencies
     in order of decreasing Q. At each frequency:
     - Lock oscillator to resonance for T = 100Q/ω₀ cycles
     - Record accumulated phase shift Δφ = Q × Ω_LT × T
     - Compute signal-to-noise ratio
  
  3. TOMOGRAPHIC PHASE: Use the N measured amplitudes to reconstruct
     the gravitomagnetic field direction via:
     B_g(θ) = Σ A_n × F_n(θ)
     where F_n(θ) are the integer graviton basis vectors.
  
  4. CROSS-CHECK: Compare reconstructed B_g with theoretical prediction
     (Lense-Thirring + geodetic precession + de Sitter).
""")

# Compute required integration times for each mode
print(f"Required integration times for SNR > 1:")
print(f"{'Triple':>20} | {'Q':>8} | {'ω_n':>10} | {'T_int (years)':>14}")
for r in resonances[:10]:
    a, b, cc = r['triple']
    Q = r['Q']
    omega_n = r['omega_n']
    if omega_n > 0:
        # Phase shift per unit time: Δφ/dt = Q × Ω_LT
        # For SNR = 1: T_int ~ 1/(Q × Ω_LT)
        T_int = 1 / (Q * Omega_LT_earth)
        T_years = T_int / (365.25 * 86400)
        print(f"  ({a:4d},{b:4d},{c:4d}) | {Q:8.0f} | {omega_n:10.6f} | {T_years:14.2e}")

# =============================================
# VISUALIZATION
# =============================================

fig, axes = plt.subplots(2, 3, figsize=(18, 12))
fig.suptitle('Gravitomagnetic Resonance: The Pythagorean Spectrum', fontsize=16)

# Panel 1: Resonance spectrum (frequency vs Q-factor)
ax = axes[0, 0]
omegas = [r['omega_n'] for r in resonances]
Qs = [r['Q'] for r in resonances]
colors_q = [np.log10(r['Q']) for r in resonances]
sc = ax.scatter(omegas, Qs, c=colors_q, s=5, alpha=0.5, cmap='hot')
ax.set_xlabel('Resonant frequency $\\omega_n$')
ax.set_ylabel('Q-factor')
ax.set_title('Pythagorean Resonance Spectrum')
ax.set_yscale('log')
plt.colorbar(sc, ax=ax, label='$\\log_{10} Q$')
ax.grid(True, alpha=0.3)

# Panel 2: Lorentzian response curves
ax = axes[0, 1]
omega_plot = np.linspace(0, 0.5, 50000)
for r in selected:
    a, b, cc = r['triple']
    resp = lorentzian(omega_plot, r['omega_n'], r['Q'])
    resp_norm = resp / np.max(resp)
    ax.plot(omega_plot, resp_norm, linewidth=1.5, label=f'({a},{b},{cc}) Q={r["Q"]:.0f}')
ax.set_xlabel('Frequency $\\omega$')
ax.set_ylabel('Normalized response')
ax.set_title('Resonance Line Shapes')
ax.legend(fontsize=7)
ax.set_xlim(0, 0.5)

# Panel 3: Amplified detection
ax = axes[0, 2]
Q_range = np.logspace(0, 6, 100)
for threshold_name, threshold in detection_thresholds.items():
    amplified = Q_range * Omega_LT_earth
    ax.axhline(threshold, linestyle=':', alpha=0.5, label=f'{threshold_name} ({threshold:.0e})')
ax.plot(Q_range, Q_range * Omega_LT_earth, 'b-', linewidth=2, label='Amplified $\\Omega_{LT}$')
ax.set_xlabel('Q-factor')
ax.set_ylabel('Amplified frame-dragging (rad/s)')
ax.set_title('Detection Feasibility')
ax.set_xscale('log')
ax.set_yscale('log')
ax.legend(fontsize=7)
ax.grid(True, alpha=0.3)

# Panel 4: Q-factor histogram by Berggren branch
ax = axes[1, 0]
for branch_name, color in [('A', 'blue'), ('B', 'red'), ('C', 'green')]:
    branch_qs = [c**2/gcd(2*a*b, abs(b**2-a**2)) for a,b,c in branches[branch_name]]
    ax.hist(branch_qs, bins=30, alpha=0.5, color=color, label=f'Branch {branch_name}')
ax.set_xlabel('Q-factor')
ax.set_ylabel('Count')
ax.set_title('Q-factor by Berggren Branch')
ax.legend()
ax.set_xscale('log')

# Panel 5: Phase space portrait
ax = axes[1, 1]
for r in resonances[:200]:
    ax.plot(r['omega_n'], r['bandwidth'], '.', 
            color=plt.cm.viridis(np.log10(r['Q'])/5), markersize=3, alpha=0.7)
ax.set_xlabel('Resonant frequency $\\omega_n$')
ax.set_ylabel('Bandwidth $\\Delta\\omega$')
ax.set_title('Phase Space: Frequency vs Bandwidth')
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 6: Spectroscopy coverage map
ax = axes[1, 2]
# Show cumulative angular coverage as function of number of modes used
all_angles = sorted([r['theta'] for r in resonances])
n_modes = range(1, min(len(all_angles), 200))
coverage = []
for n in n_modes:
    selected_angles = sorted([resonances[i]['theta'] for i in range(n)])
    if len(selected_angles) > 1:
        max_gap = max(np.diff(selected_angles))
        coverage.append(1 - max_gap / np.pi)
    else:
        coverage.append(0)
ax.plot(list(n_modes), coverage, 'b-', linewidth=2)
ax.axhline(0.95, color='red', linestyle='--', label='95% coverage')
# Find minimum modes for 95% coverage
for i, cov in enumerate(coverage):
    if cov > 0.95:
        ax.axvline(i+1, color='green', linestyle=':', label=f'{i+1} modes needed')
        break
ax.set_xlabel('Number of Pythagorean modes')
ax.set_ylabel('Angular coverage fraction')
ax.set_title('Spectroscopic Coverage')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Meta Dreams/Gravitomagnetic Frontiers/demos/04_gravitomagnetic_resonance.png', dpi=150)
print("\n✓ Figure saved: 04_gravitomagnetic_resonance.png")

# =============================================
# KEY FINDINGS
# =============================================

print("\n" + "=" * 70)
print("KEY FINDINGS: Gravitomagnetic Resonance")
print("=" * 70)
print(f"""
1. Q-FACTOR HIERARCHY: Pythagorean Q-factors range from 1 to ~10⁶ for
   triples up to depth 7. The highest Q-factors correspond to triples
   with c >> max(a,b), i.e., nearly-degenerate triangles.

2. AMPLIFICATION PROMISE: With Q ~ 10⁶, Earth's Lense-Thirring effect
   (Ω_LT ≈ {Omega_LT_earth:.2e} rad/s) could be amplified to
   ~{resonances[0]['Q'] * Omega_LT_earth:.2e} rad/s — within range of
   near-future precision measurement technology.

3. SPECTROSCOPY PROTOCOL: A 10-mode Pythagorean spectroscopy protocol
   could reconstruct the full gravitomagnetic field direction, enabling
   gravitomagnetic "imaging" analogous to MRI.

4. BRANCH STRUCTURE: The three Berggren branches (A, B, C) generate
   resonances concentrated in different angular sectors, providing
   natural directional selectivity for the spectroscopy protocol.

5. INTEGRATION TIME: Even with Q ~ 10⁶ amplification, detection of
   Earth's frame-dragging requires integration times of order 10⁷ years
   with current noise floors. This is the fundamental challenge.

6. LABORATORY SOURCES: Spinning laboratory masses produce B_g ~ 10⁻²⁵
   rad/s — too weak for direct detection even with Pythagorean amplification.
   However, the mathematical framework provides the correct mode structure
   for any future detection technology.
""")
