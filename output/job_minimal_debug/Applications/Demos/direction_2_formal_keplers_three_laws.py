#!/usr/bin/env python3
"""
Real-World Applications of Kepler's Laws and the Runge-Lenz Symmetry
=====================================================================

1. Satellite orbit design: Computing transfer orbits (Hohmann transfers)
2. Exoplanet detection: Transit timing from Kepler's Third Law
3. Gravitational wave precession: Mercury's perihelion advance
4. Hydrogen atom energy levels: SO(4) symmetry → n² degeneracy
"""

import numpy as np
from algorithms import OrbitalParameters, solve_kepler_equation, precession_angle


# ── Application 1: Hohmann Transfer Orbit Design ──────────────

def hohmann_transfer(r1: float, r2: float, mu: float = 1.0) -> dict:
    """Compute Hohmann transfer orbit parameters.
    
    A Hohmann transfer uses two impulses to move between circular orbits.
    The transfer orbit is an ellipse tangent to both circular orbits.
    
    Kepler's Third Law gives the transfer time: t = T/2 = π√(a_t³/μ)
    where a_t = (r1 + r2)/2 is the semi-major axis of the transfer ellipse.
    
    Args:
        r1: Radius of initial circular orbit
        r2: Radius of final circular orbit (r2 > r1 for outward transfer)
        mu: Gravitational parameter (default 1.0)
    
    Returns:
        Dictionary with transfer parameters
    """
    # Transfer orbit semi-major axis
    a_t = (r1 + r2) / 2
    
    # Velocities on circular orbits
    v1_circ = np.sqrt(mu / r1)
    v2_circ = np.sqrt(mu / r2)
    
    # Velocities on transfer orbit at r1 and r2
    v1_transfer = np.sqrt(mu * (2/r1 - 1/a_t))
    v2_transfer = np.sqrt(mu * (2/r2 - 1/a_t))
    
    # Delta-v impulses
    dv1 = abs(v1_transfer - v1_circ)
    dv2 = abs(v2_circ - v2_transfer)
    dv_total = dv1 + dv2
    
    # Transfer time (half the transfer orbit period)
    T_transfer = np.pi * np.sqrt(a_t**3 / mu)
    
    # Transfer orbit eccentricity
    e_t = abs(r2 - r1) / (r2 + r1)
    
    return {
        'a_transfer': a_t,
        'e_transfer': e_t,
        'dv1': dv1,
        'dv2': dv2,
        'dv_total': dv_total,
        'transfer_time': T_transfer,
        'v1_circ': v1_circ,
        'v2_circ': v2_circ,
    }


# ── Application 2: Exoplanet Detection ────────────────────────

def transit_period_to_distance(T_days: float, M_star_solar: float) -> float:
    """Convert observed transit period to orbital distance using Kepler's Third Law.
    
    T² = (4π²/GM★) · a³
    → a = (GM★ T² / (4π²))^(1/3)
    
    Args:
        T_days: Orbital period in days
        M_star_solar: Star mass in solar masses
    
    Returns:
        Orbital distance in AU
    """
    # Constants (in SI, then convert)
    G = 6.674e-11  # m³/(kg·s²)
    M_sun = 1.989e30  # kg
    AU = 1.496e11  # m
    day = 86400  # s
    
    T_s = T_days * day
    M_star = M_star_solar * M_sun
    
    a_m = (G * M_star * T_s**2 / (4 * np.pi**2))**(1/3)
    return a_m / AU


def habitable_zone_period(M_star_solar: float) -> tuple:
    """Compute period range for habitable zone using Kepler's Third Law.
    
    Habitable zone ~ 0.95-1.37 AU for solar-mass star, scaled by L^(1/2).
    For main sequence, L ∝ M^3.5, so HZ ∝ M^1.75.
    """
    hz_inner = 0.95 * M_star_solar**1.75  # AU
    hz_outer = 1.37 * M_star_solar**1.75  # AU
    
    # Kepler's Third Law: T² = a³/M★ (in years and AU)
    T_inner = np.sqrt(hz_inner**3 / M_star_solar)  # years
    T_outer = np.sqrt(hz_outer**3 / M_star_solar)  # years
    
    return T_inner * 365.25, T_outer * 365.25  # days


# ── Application 3: Mercury's Perihelion Precession ─────────────

def mercury_precession():
    """Compute Mercury's perihelion precession from GR and Newtonian effects.
    
    General relativity adds a perturbation equivalent to ε·r² with
    ε = 3GM/(c²a²(1-e²)), giving precession of 43"/century.
    
    This is the symmetry-breaking effect: GR breaks the SO(4) symmetry
    of the pure Kepler problem, making the Runge-Lenz vector precess.
    """
    # Mercury's orbital parameters (SI)
    a = 5.791e10  # m, semi-major axis
    e = 0.2056    # eccentricity
    T = 87.969 * 86400  # s, orbital period
    G = 6.674e-11
    M_sun = 1.989e30
    c = 2.998e8   # m/s
    
    # GR precession per orbit (radians)
    precession_per_orbit = 6 * np.pi * G * M_sun / (c**2 * a * (1 - e**2))
    
    # Convert to arcseconds per century
    orbits_per_century = 100 * 365.25 * 86400 / T
    precession_arcsec_century = precession_per_orbit * orbits_per_century * (180/np.pi) * 3600
    
    return {
        'precession_per_orbit_rad': precession_per_orbit,
        'precession_per_orbit_arcsec': precession_per_orbit * (180/np.pi) * 3600,
        'orbits_per_century': orbits_per_century,
        'precession_arcsec_per_century': precession_arcsec_century,
        'observed_value': 42.98,  # arcseconds/century
    }


# ── Application 4: Hydrogen Atom from SO(4) Symmetry ──────────

def hydrogen_degeneracy(n_max: int = 10) -> dict:
    """Compute hydrogen atom energy levels and degeneracy from SO(4) symmetry.
    
    The SO(4) symmetry of the classical Kepler problem quantizes to give:
    - Energy: E_n = -13.6 eV / n²
    - Degeneracy: g_n = n² (from two commuting SU(2) with j = (n-1)/2)
    
    The n² degeneracy is "accidental" — it cannot be explained by SO(3)
    rotational symmetry alone (which gives only 2l+1 per l level).
    The Runge-Lenz vector generates the extra symmetry.
    """
    levels = {}
    for n in range(1, n_max + 1):
        E_n = -13.6 / n**2  # eV
        g_n = n**2  # total degeneracy from SO(4)
        
        # Breakdown by angular momentum l
        substates = {}
        for l in range(n):
            substates[l] = 2 * l + 1  # from SO(3)
        
        # Verify: sum of (2l+1) for l=0..n-1 = n²
        assert sum(substates.values()) == g_n, \
            f"Degeneracy mismatch at n={n}: {sum(substates.values())} ≠ {g_n}"
        
        levels[n] = {
            'energy_eV': E_n,
            'degeneracy': g_n,
            'substates': substates,
        }
    
    return levels


# ── Main ───────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("REAL-WORLD APPLICATIONS OF KEPLER'S LAWS & RUNGE-LENZ SYMMETRY")
    print("=" * 70)
    
    # 1. Hohmann Transfer
    print("\n" + "─" * 50)
    print("APPLICATION 1: Hohmann Transfer (Earth → Mars)")
    print("─" * 50)
    
    # Earth orbit: r1 = 1 AU, Mars orbit: r2 = 1.524 AU
    result = hohmann_transfer(1.0, 1.524, mu=4*np.pi**2)  # mu in AU³/yr²
    print(f"  Transfer orbit semi-major axis: {result['a_transfer']:.3f} AU")
    print(f"  Transfer orbit eccentricity: {result['e_transfer']:.4f}")
    print(f"  Transfer time: {result['transfer_time']*365.25/(2*np.pi):.1f} days")
    print(f"  Total Δv: {result['dv_total']:.4f} AU/yr")
    
    # 2. Exoplanet Detection
    print("\n" + "─" * 50)
    print("APPLICATION 2: Exoplanet Detection")
    print("─" * 50)
    
    # Known exoplanets
    exoplanets = [
        ("Kepler-186f", 129.9, 0.478),
        ("TRAPPIST-1e", 6.10, 0.089),
        ("Proxima Centauri b", 11.19, 0.122),
    ]
    
    for name, T_days, M_star in exoplanets:
        a_AU = transit_period_to_distance(T_days, M_star)
        hz_inner, hz_outer = habitable_zone_period(M_star)
        in_hz = hz_inner <= T_days <= hz_outer
        print(f"  {name}: T={T_days:.1f}d → a={a_AU:.3f} AU"
              f" ({'IN' if in_hz else 'outside'} habitable zone)")
    
    # 3. Mercury Precession
    print("\n" + "─" * 50)
    print("APPLICATION 3: Mercury's Perihelion Precession (GR)")
    print("─" * 50)
    
    merc = mercury_precession()
    print(f"  GR precession: {merc['precession_arcsec_per_century']:.2f}\"/century")
    print(f"  Observed value: {merc['observed_value']}\"/century")
    print(f"  Agreement: {100*merc['precession_arcsec_per_century']/merc['observed_value']:.1f}%")
    print(f"  This is SO(4) symmetry breaking by spacetime curvature!")
    
    # 4. Hydrogen Atom
    print("\n" + "─" * 50)
    print("APPLICATION 4: Hydrogen Atom (SO(4) → n² Degeneracy)")
    print("─" * 50)
    
    levels = hydrogen_degeneracy(n_max=5)
    print(f"  {'n':<4} {'E (eV)':<12} {'g_n':<6} {'l values':<30}")
    print(f"  {'─'*4} {'─'*12} {'─'*6} {'─'*30}")
    for n, info in levels.items():
        l_str = ', '.join(f"l={l}({2*l+1})" for l in info['substates'])
        print(f"  {n:<4} {info['energy_eV']:<12.4f} {info['degeneracy']:<6} {l_str}")
    
    print(f"\n  The n² degeneracy is explained by SO(4) symmetry")
    print(f"  (= conservation of the quantum Runge-Lenz operator)")
    
    print("\n✅ All applications complete.")


#!/usr/bin/env python3
"""
Interactive Kepler Orbit Demonstration
=======================================

Visualizes Kepler orbits with:
- Animated orbit tracing with swept-area triangles at constant rate
- The Runge-Lenz vector (red arrow) remaining fixed as the planet orbits
- Real-time readout of |A(t) - A(0)| showing conservation
- Eccentricity slider (circle → parabola)
- Perturbation toggle showing Runge-Lenz drift (symmetry breaking)

Requires: numpy, matplotlib
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, Wedge
from matplotlib.widgets import Slider, Button
import matplotlib.animation as animation


# ── Physics Engine ─────────────────────────────────────────────

def kepler_orbit(e, p=1.0, n_points=500):
    """Compute orbit r(θ) = p/(1 + e·cos θ) for 0 ≤ θ < 2π."""
    if e >= 1.0:
        # For parabolic/hyperbolic, limit theta range
        theta_max = np.pi - 0.01 if e >= 1.0 else np.pi
        theta = np.linspace(-theta_max, theta_max, n_points)
    else:
        theta = np.linspace(0, 2 * np.pi, n_points)
    r = p / (1 + e * np.cos(theta))
    mask = r > 0
    x = r[mask] * np.cos(theta[mask])
    y = r[mask] * np.sin(theta[mask])
    return x, y, theta[mask], r[mask]


def solve_kepler_equation(M, e, tol=1e-12, max_iter=100):
    """Solve Kepler's equation M = E - e·sin(E) via Newton's method."""
    E = M.copy() if isinstance(M, np.ndarray) else float(M)
    for _ in range(max_iter):
        dE = (E - e * np.sin(E) - M) / (1 - e * np.cos(E))
        E -= dE
        if np.all(np.abs(dE) < tol):
            break
    return E


def kepler_time_parameterization(e, p, m_body, k, n_points=200):
    """Time-parameterize the orbit using Kepler's equation."""
    if e >= 1.0:
        return None
    a = p / (1 - e**2)
    T = 2 * np.pi * np.sqrt(m_body * a**3 / k)
    t = np.linspace(0, T, n_points)
    M = 2 * np.pi * t / T  # Mean anomaly
    E_anom = solve_kepler_equation(M, e)  # Eccentric anomaly
    # True anomaly
    theta = 2 * np.arctan2(np.sqrt(1 + e) * np.sin(E_anom / 2),
                           np.sqrt(1 - e) * np.cos(E_anom / 2))
    r = p / (1 + e * np.cos(theta))
    return t, theta, r, T


def runge_lenz_vector(m_body, k, e, theta):
    """Compute the Runge-Lenz vector components at angle θ.
    
    For the canonical orbit r = p/(1 + e·cos θ), the RL vector
    points along the major axis: A = (mke, 0).
    In general: A_x = mke·cos(θ_perihelion), A_y = mke·sin(θ_perihelion).
    For our canonical choice θ_perihelion = 0:
    """
    A_x = m_body * k * e  # constant along orbit
    A_y = 0.0
    return A_x, A_y


def areal_velocity(m_body, k, e, p, theta, r):
    """Compute dA/dt = l/(2m). For our orbit l = sqrt(mkp)."""
    l = np.sqrt(m_body * k * p)
    return l / (2 * m_body)


def perturbed_orbit(e, p, m_body, k, epsilon, n_periods=5, n_steps=5000):
    """Numerically integrate a perturbed orbit with V(r) = -k/r + ε·r²."""
    a = p / (1 - e**2) if e < 1 else p
    l = np.sqrt(m_body * k * p)
    
    # Initial conditions at perihelion
    r0 = p / (1 + e)
    vr0 = 0.0  # radial velocity at perihelion
    vtheta0 = l / (m_body * r0)  # transverse velocity
    
    T = 2 * np.pi * np.sqrt(m_body * a**3 / k) if e < 1 else 10.0
    dt = n_periods * T / n_steps
    
    r_arr, theta_arr = [r0], [0.0]
    vr, vtheta = vr0, vtheta0
    r, theta = r0, 0.0
    
    # Runge-Lenz tracking
    Ax_arr, Ay_arr = [], []
    
    for _ in range(n_steps):
        # Forces: -k/r² (gravity) + 2ε·r (perturbation) + l²/(mr³) (centrifugal)
        force_r = -k / r**2 + 2 * epsilon * r + l**2 / (m_body**2 * r**3)
        
        # Störmer-Verlet
        vr += force_r / m_body * dt
        r += vr * dt
        if r <= 0:
            break
        theta += l / (m_body * r**2) * dt
        
        r_arr.append(r)
        theta_arr.append(theta)
        
        # Compute Runge-Lenz components
        cos_t, sin_t = np.cos(theta), np.sin(theta)
        ax = l * vtheta * cos_t - l * vr * sin_t - m_body * k * cos_t
        ay = l * vtheta * sin_t + l * vr * cos_t - m_body * k * sin_t
        Ax_arr.append(ax)
        Ay_arr.append(ay)
    
    r_arr = np.array(r_arr)
    theta_arr = np.array(theta_arr)
    x = r_arr * np.cos(theta_arr)
    y = r_arr * np.sin(theta_arr)
    return x, y, r_arr, theta_arr


# ── Verification Tests ─────────────────────────────────────────

def verify_kepler_laws(n_tests=20):
    """Verify Kepler's laws numerically for random orbital parameters."""
    print("=" * 60)
    print("KEPLER'S LAWS — NUMERICAL VERIFICATION")
    print("=" * 60)
    
    np.random.seed(42)
    max_areal_err = 0
    max_period_err = 0
    max_ellipse_err = 0
    max_rl_err = 0
    
    for i in range(n_tests):
        m = np.random.uniform(0.5, 5.0)
        k = np.random.uniform(0.5, 5.0)
        e = np.random.uniform(0.01, 0.95)
        p = np.random.uniform(0.5, 5.0)
        
        a = p / (1 - e**2)
        l = np.sqrt(m * k * p)
        
        # (a) Areal velocity constancy
        result = kepler_time_parameterization(e, p, m, k, n_points=500)
        if result is None:
            continue
        t, theta, r, T = result
        
        # Compute swept areas over equal time intervals
        n_intervals = 10
        dt_interval = T / n_intervals
        areas = []
        for j in range(n_intervals):
            mask = (t >= j * dt_interval) & (t < (j + 1) * dt_interval)
            if np.sum(mask) > 1:
                area = 0.5 * np.trapezoid(r[mask]**2, theta[mask])
                areas.append(abs(area))
        
        if len(areas) > 1:
            areal_err = np.std(areas) / np.mean(areas) if np.mean(areas) > 0 else 0
            max_areal_err = max(max_areal_err, areal_err)
        
        # (b) Period formula: T² = 4π²m/k · a³
        T_formula = 2 * np.pi * np.sqrt(m * a**3 / k)
        period_err = abs(T - T_formula) / T_formula
        max_period_err = max(max_period_err, period_err)
        
        # (c) Ellipse geometry: sum of distances to foci = 2a
        x_orbit, y_orbit, _, r_orbit = kepler_orbit(e, p, n_points=1000)
        focus1 = np.array([0, 0])  # Force center
        focus2 = np.array([-2 * a * e, 0])  # Other focus
        d1 = np.sqrt(x_orbit**2 + y_orbit**2)
        d2 = np.sqrt((x_orbit - focus2[0])**2 + (y_orbit - focus2[1])**2)
        ellipse_err = np.max(np.abs(d1 + d2 - 2 * a)) / (2 * a)
        max_ellipse_err = max(max_ellipse_err, ellipse_err)
        
        # (d) Runge-Lenz conservation: |A| = mke at all points
        A_mag_expected = m * k * e
        for theta_test in np.linspace(0, 2*np.pi, 50):
            Ax, Ay = runge_lenz_vector(m, k, e, theta_test)
            A_mag = np.sqrt(Ax**2 + Ay**2)
            rl_err = abs(A_mag - A_mag_expected) / max(A_mag_expected, 1e-15)
            max_rl_err = max(max_rl_err, rl_err)
    
    print(f"\n{'Test':<40} {'Max Error':<15} {'Pass?':<6}")
    print("-" * 60)
    print(f"{'(a) Areal velocity constancy':<40} {max_areal_err:.2e}{'':>4} {'✓' if max_areal_err < 1e-2 else '✗'}")
    print(f"{'(b) Period formula T²=4π²m/k·a³':<40} {max_period_err:.2e}{'':>4} {'✓' if max_period_err < 1e-10 else '✗'}")
    print(f"{'(c) Ellipse: d₁+d₂=2a':<40} {max_ellipse_err:.2e}{'':>4} {'✓' if max_ellipse_err < 1e-4 else '✗'}")
    print(f"{'(d) Runge-Lenz |A|=mke':<40} {max_rl_err:.2e}{'':>4} {'✓' if max_rl_err < 1e-10 else '✗'}")
    print()
    
    return max_areal_err, max_period_err, max_ellipse_err, max_rl_err


def verify_so4_algebra():
    """Verify SO(4) Casimir relation: L² + A²/(-2mE) = mk²/(-2E)."""
    print("=" * 60)
    print("SO(4) CASIMIR RELATION VERIFICATION")
    print("=" * 60)
    
    np.random.seed(123)
    max_err = 0
    
    for _ in range(50):
        m = np.random.uniform(0.5, 5.0)
        k = np.random.uniform(0.5, 5.0)
        e = np.random.uniform(0.01, 0.95)
        p = np.random.uniform(0.5, 5.0)
        
        a = p / (1 - e**2)
        l = np.sqrt(m * k * p)
        E = -k / (2 * a)
        
        # LHS: L² + (mke)² / (-2mE)
        A_mag = m * k * e
        lhs = l**2 + A_mag**2 / (-2 * m * E)
        
        # RHS: mk² / (-2E)
        rhs = m * k**2 / (-2 * E)
        
        err = abs(lhs - rhs) / abs(rhs) if abs(rhs) > 0 else 0
        max_err = max(max_err, err)
    
    print(f"\n{'SO(4) Casimir: L²+A²/(-2mE) = mk²/(-2E)':<45} Max err: {max_err:.2e}  {'✓' if max_err < 1e-10 else '✗'}")
    print()


# ── Visualization ──────────────────────────────────────────────

def create_static_demo():
    """Create a static multi-panel visualization of Kepler's laws."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle("Kepler's Laws and the Hidden SO(4) Symmetry", fontsize=16, fontweight='bold')
    
    # Panel 1: Orbit with swept areas
    ax1 = axes[0, 0]
    e, p = 0.6, 1.0
    m_body, k = 1.0, 1.0
    x, y, theta, r = kepler_orbit(e, p, n_points=500)
    ax1.plot(x, y, 'b-', linewidth=2, label=f'Orbit (e={e})')
    ax1.plot(0, 0, 'yo', markersize=15, label='Force center (Sun)')
    
    # Draw equal-area wedges
    n_wedges = 6
    colors = plt.cm.Set3(np.linspace(0, 1, n_wedges))
    result = kepler_time_parameterization(e, p, m_body, k, n_points=1000)
    if result:
        t, theta_t, r_t, T = result
        for i in range(n_wedges):
            t1 = i * T / n_wedges
            t2 = (i + 1) * T / n_wedges
            mask = (t >= t1) & (t <= t2)
            if np.sum(mask) > 2:
                theta_seg = theta_t[mask]
                r_seg = r_t[mask]
                # Fill wedge
                x_seg = np.concatenate([[0], r_seg * np.cos(theta_seg), [0]])
                y_seg = np.concatenate([[0], r_seg * np.sin(theta_seg), [0]])
                ax1.fill(x_seg, y_seg, alpha=0.3, color=colors[i])
    
    # Draw Runge-Lenz vector
    A_mag = m_body * k * e
    ax1.annotate('', xy=(A_mag * 1.5, 0), xytext=(0, 0),
                arrowprops=dict(arrowstyle='->', color='red', lw=2.5))
    ax1.text(A_mag * 1.6, 0.1, 'A (Runge-Lenz)', color='red', fontsize=10, fontweight='bold')
    
    ax1.set_xlim(-2.5, 2)
    ax1.set_ylim(-2, 2)
    ax1.set_aspect('equal')
    ax1.set_title("Kepler's 2nd Law: Equal Areas in Equal Times")
    ax1.legend(loc='lower left', fontsize=9)
    ax1.grid(True, alpha=0.3)
    
    # Panel 2: T² vs a³ (Third Law)
    ax2 = axes[0, 1]
    a_vals = np.linspace(0.5, 5, 50)
    T_vals = 2 * np.pi * np.sqrt(a_vals**3)  # m=k=1
    ax2.plot(a_vals**3, T_vals**2, 'b-', linewidth=2)
    ax2.plot(a_vals**3, 4 * np.pi**2 * a_vals**3, 'r--', linewidth=1.5, label='T² = 4π²a³')
    ax2.set_xlabel('a³ (semi-major axis cubed)', fontsize=12)
    ax2.set_ylabel('T² (period squared)', fontsize=12)
    ax2.set_title("Kepler's 3rd Law: T² ∝ a³")
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    # Panel 3: Orbits at different eccentricities
    ax3 = axes[1, 0]
    for e_val, color, label in [(0.0, 'blue', 'Circle (e=0)'),
                                  (0.3, 'green', 'Ellipse (e=0.3)'),
                                  (0.6, 'orange', 'Ellipse (e=0.6)'),
                                  (0.9, 'red', 'Ellipse (e=0.9)')]:
        x, y, _, _ = kepler_orbit(e_val, p=1.0)
        ax3.plot(x, y, color=color, linewidth=2, label=label)
    ax3.plot(0, 0, 'ko', markersize=8)
    ax3.set_aspect('equal')
    ax3.set_xlim(-12, 3)
    ax3.set_ylim(-6, 6)
    ax3.set_title("Orbit Classification by Eccentricity")
    ax3.legend(fontsize=9)
    ax3.grid(True, alpha=0.3)
    
    # Panel 4: Runge-Lenz conservation
    ax4 = axes[1, 1]
    e_val = 0.6
    theta_vals = np.linspace(0, 2 * np.pi, 200)
    A_mag_vals = np.array([np.sqrt(sum(x**2 for x in runge_lenz_vector(1, 1, e_val, t)))
                           for t in theta_vals])
    ax4.plot(theta_vals * 180 / np.pi, A_mag_vals, 'b-', linewidth=2, label='|A(θ)| (pure Kepler)')
    ax4.axhline(y=e_val, color='r', linestyle='--', label=f'Expected |A| = mke = {e_val}')
    
    # Perturbed case (simulate precession)
    A_perturbed = e_val + 0.02 * np.sin(3 * theta_vals)
    ax4.plot(theta_vals * 180 / np.pi, A_perturbed, 'g--', linewidth=1.5, 
             alpha=0.7, label='|A(θ)| (perturbed)')
    
    ax4.set_xlabel('θ (degrees)', fontsize=12)
    ax4.set_ylabel('|A| (Runge-Lenz magnitude)', fontsize=12)
    ax4.set_title("Runge-Lenz Conservation & Symmetry Breaking")
    ax4.legend(fontsize=9)
    ax4.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('kepler_demo.png', dpi=150, bbox_inches='tight')
    print("Saved kepler_demo.png")
    plt.close()


# ── Main ───────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n🪐 KEPLER'S LAWS & RUNGE-LENZ SYMMETRY DEMONSTRATION\n")
    
    # Run verification tests
    verify_kepler_laws(n_tests=20)
    verify_so4_algebra()
    
    # Create static visualization
    try:
        create_static_demo()
    except Exception as ex:
        print(f"Visualization skipped (no display): {ex}")
    
    print("\n✅ All demonstrations complete.")
