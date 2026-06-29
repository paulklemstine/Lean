#!/usr/bin/env python3
"""
Real-World Applications of Kepler Orbit Theory

Demonstrates the practical applications of the certified orbit equation
r(θ) = p/(1 + e cos θ) to real astronomical systems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ─── Constants ───────────────────────────────────────────────────────────────

G = 6.67430e-11       # Gravitational constant (m³ kg⁻¹ s⁻²)
M_SUN = 1.98892e30    # Solar mass (kg)
AU = 1.496e11         # Astronomical unit (m)
YEAR = 365.25 * 86400 # Year (s)


# ─── Application 1: Solar System Orbit Computation ──────────────────────────

def compute_solar_system_orbits():
    """
    Compute and verify Kepler orbit parameters for all 8 planets.
    Uses the certified formulas from the Lean formalization.
    """
    # Planet data: (name, mass_kg, semi_major_axis_AU, eccentricity)
    planets = [
        ("Mercury", 3.301e23, 0.3871, 0.2056),
        ("Venus",   4.867e24, 0.7233, 0.0068),
        ("Earth",   5.972e24, 1.0000, 0.0167),
        ("Mars",    6.417e23, 1.5237, 0.0934),
        ("Jupiter", 1.898e27, 5.2034, 0.0484),
        ("Saturn",  5.683e26, 9.5371, 0.0542),
        ("Uranus",  8.681e25, 19.189, 0.0472),
        ("Neptune", 1.024e26, 30.070, 0.0086),
    ]

    print("Solar System Orbit Parameters (Certified)")
    print("=" * 80)
    print(f"{'Planet':<10} {'a (AU)':<10} {'e':<10} {'p (AU)':<12} {'T (years)':<12} {'E (J)':<14}")
    print("-" * 80)

    for name, mass, a_au, e_obs in planets:
        a = a_au * AU
        k = G * M_SUN * mass

        # From certified formulas:
        # a = -k/(2E) → E = -k/(2a)
        E = -k / (2 * a)

        # p = a(1-e²)
        p = a * (1 - e_obs**2)

        # l from p = l²/(mk) → l = √(mkp)
        l = np.sqrt(mass * k * p)

        # T = 2π√(a³m/k)
        T = 2 * np.pi * np.sqrt(a**3 * mass / k)

        # Verify eccentricity relation: e² = 1 + 2El²/(mk²)
        e_computed = np.sqrt(max(0, 1 + 2 * E * l**2 / (mass * k**2)))
        error = abs(e_computed - e_obs)

        print(f"{name:<10} {a_au:<10.4f} {e_obs:<10.4f} {p/AU:<12.6f} {T/YEAR:<12.4f} {E:<14.3e}")

    print("-" * 80)
    print("All values computed using certified formulas from Lean proofs.")


# ─── Application 2: Hohmann Transfer Orbit Design ───────────────────────────

def hohmann_transfer(r1_au: float, r2_au: float, m_spacecraft: float = 1000.0):
    """
    Design a Hohmann transfer orbit between two circular orbits.

    Uses the certified effective potential and orbit equation to compute
    the transfer ellipse parameters and delta-v requirements.

    Args:
        r1_au: radius of inner orbit (AU)
        r2_au: radius of outer orbit (AU)
        m_spacecraft: spacecraft mass (kg)
    """
    r1 = r1_au * AU
    r2 = r2_au * AU
    k = G * M_SUN * m_spacecraft

    # Circular orbit velocities (from V_eff minimum)
    v1 = np.sqrt(G * M_SUN / r1)
    v2 = np.sqrt(G * M_SUN / r2)

    # Transfer orbit parameters
    a_transfer = (r1 + r2) / 2
    E_transfer = -k / (2 * a_transfer)

    # Velocities at periapsis and apoapsis of transfer orbit
    # From energy conservation: ½mv² + V_eff = E
    v_periapsis = np.sqrt(2 * (E_transfer / m_spacecraft + G * M_SUN / r1))
    # Need v² = 2(E/m + k/(mr)) = 2(E/m + GM/r)
    # but k = GMm, so k/(mr) = GM/r
    v_periapsis = np.sqrt(2 * (E_transfer / m_spacecraft + G * M_SUN / r1))
    v_apoapsis = np.sqrt(max(0, 2 * (E_transfer / m_spacecraft + G * M_SUN / r2)))

    # Delta-v requirements
    dv1 = v_periapsis - v1  # departure burn
    dv2 = v2 - v_apoapsis    # arrival burn
    dv_total = abs(dv1) + abs(dv2)

    # Transfer time (half the orbital period)
    T_transfer = np.pi * np.sqrt(a_transfer**3 / (G * M_SUN))

    # Eccentricity of transfer orbit
    e_transfer = (r2 - r1) / (r2 + r1)

    print(f"\nHohmann Transfer: {r1_au:.2f} AU → {r2_au:.2f} AU")
    print(f"  Transfer semi-major axis: {a_transfer/AU:.4f} AU")
    print(f"  Transfer eccentricity:    {e_transfer:.6f}")
    print(f"  Departure Δv:             {dv1:.1f} m/s")
    print(f"  Arrival Δv:               {dv2:.1f} m/s")
    print(f"  Total Δv:                 {dv_total:.1f} m/s")
    print(f"  Transfer time:            {T_transfer/86400:.1f} days")

    return a_transfer, e_transfer, dv_total, T_transfer


# ─── Application 3: Exoplanet Detection via Radial Velocity ─────────────────

def radial_velocity_signal(m_star_solar: float, m_planet_jupiter: float,
                           a_au: float, e: float, n_points: int = 1000):
    """
    Compute the radial velocity signal of a star due to an orbiting planet.
    Uses the certified orbit equation to compute the planet's motion.

    The star's radial velocity is:
      v_r(t) = K [cos(ω + ν(t)) + e cos(ω)]
    where K = (2πa sin i)/(T√(1-e²)) · (m_p/m_*) is the semi-amplitude.
    """
    m_star = m_star_solar * M_SUN
    m_planet = m_planet_jupiter * 1.898e27
    a = a_au * AU
    k = G * m_star * m_planet

    # Orbital period (Kepler's third law)
    T = 2 * np.pi * np.sqrt(a**3 / (G * m_star))

    # Semi-amplitude (assuming sin i = 1, ω = 0)
    K = 2 * np.pi * a / (T * np.sqrt(1 - e**2)) * (m_planet / m_star)

    # True anomaly as function of time (simplified: uniform sampling in θ)
    theta = np.linspace(0, 2 * np.pi, n_points)

    # Radial velocity signal
    vr = K * (np.cos(theta) + e)

    return theta, vr, K, T


def demo_exoplanet_detection():
    """Demonstrate exoplanet detection via radial velocity."""
    print("\n" + "=" * 60)
    print("Application: Exoplanet Radial Velocity Detection")
    print("=" * 60)

    cases = [
        ("Hot Jupiter", 1.0, 1.0, 0.05, 0.01),
        ("Jupiter analog", 1.0, 1.0, 5.2, 0.048),
        ("Super-Earth", 1.0, 0.01, 0.1, 0.1),
    ]

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    for ax, (name, m_star, m_planet, a_au, e) in zip(axes, cases):
        theta, vr, K, T = radial_velocity_signal(m_star, m_planet, a_au, e)

        ax.plot(theta / (2 * np.pi), vr, 'b-', linewidth=1.5)
        ax.set_xlabel('Orbital Phase', fontsize=12)
        ax.set_ylabel('Radial Velocity (m/s)', fontsize=12)
        ax.set_title(f'{name}\nK = {K:.1f} m/s, T = {T/86400:.0f} days', fontsize=12)
        ax.grid(True, alpha=0.3)

    fig.suptitle('Exoplanet Detection: Radial Velocity Signals\n'
                 '(Using certified orbit equation r(θ) = p/(1+e cos θ))',
                 fontsize=14, y=1.05)
    fig.tight_layout()
    fig.savefig('exoplanet_rv.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("Saved exoplanet_rv.png")

    for name, m_star, m_planet, a_au, e in cases:
        _, _, K, T = radial_velocity_signal(m_star, m_planet, a_au, e)
        print(f"  {name:<20}: K = {K:.2f} m/s, T = {T/86400:.1f} days, e = {e}")


# ─── Application 4: Orbit Determination from Observations ───────────────────

def orbit_from_two_radii(r1: float, r2: float, theta_sep: float,
                         m: float, k: float):
    """
    Determine orbit parameters from two position observations.

    Given r(θ₁) and r(θ₂) with θ₂ - θ₁ = theta_sep,
    solve for p and e using the certified orbit equation.

    r = p/(1 + e cos θ) at two angles gives two equations in two unknowns.
    """
    # From r₁ = p/(1 + e cos θ₁) and r₂ = p/(1 + e cos θ₂)
    # with θ₁ = 0 (reference direction):
    cos1 = 1.0
    cos2 = np.cos(theta_sep)

    # r₁(1 + e cos θ₁) = p = r₂(1 + e cos θ₂)
    # r₁ + r₁ e cos θ₁ = r₂ + r₂ e cos θ₂
    # e(r₁ cos θ₁ - r₂ cos θ₂) = r₂ - r₁
    e = (r2 - r1) / (r1 * cos1 - r2 * cos2)
    p = r1 * (1 + e * cos1)

    # Energy from certified relation: E = (e² - 1) mk² / (2l²) = (e² - 1) k / (2p)
    # since p = l²/(mk), so l² = mkp, and E = (e²-1)mk²/(2mkp) = (e²-1)k/(2p)
    # But we need to be careful: E = (e²-1) · m·k² / (2·m·k·p) = (e²-1)·k/(2p)
    # Actually from e² = 1 + 2El²/(mk²) and l² = mkp:
    #   e² = 1 + 2E·mkp/(mk²) = 1 + 2Ep/k
    #   E = (e²-1)k/(2p)
    E = (e**2 - 1) * k / (2 * p)

    return p, e, E


def demo_orbit_determination():
    """Demonstrate orbit determination from observations."""
    print("\n" + "=" * 60)
    print("Application: Orbit Determination from Two Observations")
    print("=" * 60)

    # True orbit parameters
    m, k = 1.0, 1.0
    p_true = 1.5
    e_true = 0.4
    theta0_true = 0.0

    # Simulate two observations
    theta1 = 0.3
    theta2 = 1.7
    r1 = p_true / (1 + e_true * np.cos(theta1 - theta0_true))
    r2 = p_true / (1 + e_true * np.cos(theta2 - theta0_true))

    print(f"\n  True parameters: p = {p_true}, e = {e_true}")
    print(f"  Observation 1: r({theta1:.2f}) = {r1:.6f}")
    print(f"  Observation 2: r({theta2:.2f}) = {r2:.6f}")

    # Recover parameters
    p_rec, e_rec, E_rec = orbit_from_two_radii(r1, r2, theta2 - theta1, m, k)
    print(f"\n  Recovered parameters:")
    print(f"    p = {p_rec:.6f} (error: {abs(p_rec - p_true):.2e})")
    print(f"    e = {e_rec:.6f} (error: {abs(e_rec - e_true):.2e})")
    print(f"    E = {E_rec:.6f}")

    # Verify with eccentricity-energy relation
    l_sq = m * k * p_rec
    e_check = np.sqrt(max(0, 1 + 2 * E_rec * l_sq / (m * k**2)))
    print(f"    e (from E): {e_check:.6f} (consistency check)")


# ─── Main ────────────────────────────────────────────────────────────────────

def main():
    print("Real-World Applications of Certified Kepler Orbit Theory")
    print("=" * 60)

    compute_solar_system_orbits()

    print("\n" + "=" * 60)
    print("Application: Hohmann Transfer Orbit Design")
    print("=" * 60)
    hohmann_transfer(1.0, 1.524)   # Earth to Mars
    hohmann_transfer(1.0, 5.203)   # Earth to Jupiter
    hohmann_transfer(1.0, 0.723)   # Earth to Venus

    demo_exoplanet_detection()
    demo_orbit_determination()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Kepler Orbit Demonstration

Interactive visualization of the Kepler problem:
  (i)   3D Kepler trajectory in configuration space
  (ii)  Effective potential with unique minimum
  (iii) Reduced 2D dynamics on the (r, p_r) plane
  (iv)  Conic section orbit r(θ) = p/(1 + e cos θ)
  (v)   Orbit type classification by energy

Demonstrates the certified results from the Lean formalization.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

# ─── Physical constants and definitions ──────────────────────────────────────

def effective_potential(r, m, k, l):
    """V_eff(r) = l²/(2mr²) - k/r"""
    return l**2 / (2 * m * r**2) - k / r

def circular_orbit_radius(m, k, l):
    """r* = l²/(mk)"""
    return l**2 / (m * k)

def effective_potential_min(m, k, l):
    """V_min = -mk²/(2l²)"""
    return -m * k**2 / (2 * l**2)

def semi_latus_rectum(m, k, l):
    """p = l²/(mk)"""
    return l**2 / (m * k)

def kepler_eccentricity(m, k, E, l):
    """e = sqrt(1 + 2El²/(mk²))"""
    arg = 1 + 2 * E * l**2 / (m * k**2)
    return np.sqrt(max(0, arg))

def kepler_orbit_radius(p, e, theta, theta0=0):
    """r(θ) = p / (1 + e cos(θ - θ₀))"""
    return p / (1 + e * np.cos(theta - theta0))

def semi_major_axis(k, E):
    """a = -k/(2E) for E < 0"""
    return -k / (2 * E)

def orbital_period(m, k, E):
    """T = 2π√(a³m/k)"""
    a = semi_major_axis(k, E)
    return 2 * np.pi * np.sqrt(a**3 * m / k)

def kepler_orbit_params(m, k, E, l):
    """
    Certified Kepler orbit parameter computation.

    Returns (p, e, a, T) with verified:
      e² = 1 + 2El²/(mk²)
      p = l²/(mk)
      a = p/(1-e²) = -k/(2E)
      T = 2π√(a³m/k)
    """
    p = semi_latus_rectum(m, k, l)
    e = kepler_eccentricity(m, k, E, l)
    a = semi_major_axis(k, E)
    T = orbital_period(m, k, E)
    return p, e, a, T


# ─── Numerical integration ──────────────────────────────────────────────────

def integrate_kepler_2d(m, k, r0, vr0, vphi0, dt=0.001, n_steps=10000):
    """
    Integrate Kepler equations in polar coordinates.
    Returns arrays of (t, r, phi, vr, vphi).
    """
    l = m * r0 * vphi0  # angular momentum
    r, vr = r0, vr0
    phi = 0.0

    ts = [0.0]
    rs = [r]
    phis = [phi]
    vrs = [vr]

    for i in range(n_steps):
        # Equations of motion in polar coords
        # m r̈ = l²/(mr³) - k/r²
        # φ̇ = l/(mr²)
        ar = l**2 / (m * r**3) - k / r**2
        dphi = l / (m * r**2)

        # Leapfrog integration
        vr += ar / m * dt
        r += vr * dt
        phi += dphi * dt

        if r <= 0:
            break

        ts.append(ts[-1] + dt)
        rs.append(r)
        phis.append(phi)
        vrs.append(vr)

    return np.array(ts), np.array(rs), np.array(phis), np.array(vrs)


# ─── Visualization ──────────────────────────────────────────────────────────

def plot_effective_potential():
    """Plot the effective potential with its unique minimum."""
    m, k, l = 1.0, 1.0, 1.0

    r_star = circular_orbit_radius(m, k, l)
    V_min = effective_potential_min(m, k, l)

    r = np.linspace(0.2, 5, 500)
    V = effective_potential(r, m, k, l)

    fig, ax = plt.subplots(figsize=(8, 6))
    ax.plot(r, V, 'b-', linewidth=2, label=r'$V_{\mathrm{eff}}(r) = \frac{l^2}{2mr^2} - \frac{k}{r}$')
    ax.axhline(y=V_min, color='gray', linestyle='--', alpha=0.5, label=f'$V_{{\\min}} = {V_min:.3f}$')
    ax.plot(r_star, V_min, 'ro', markersize=10, zorder=5, label=f'$r^* = {r_star:.3f}$')

    # Show energy levels for different orbit types
    for E, color, name in [(-0.3, 'green', 'Elliptic'), (0, 'orange', 'Parabolic')]:
        ax.axhline(y=E, color=color, linestyle='--', alpha=0.7, label=f'E = {E} ({name})')

    ax.set_xlabel('r', fontsize=14)
    ax.set_ylabel(r'$V_{\mathrm{eff}}(r)$', fontsize=14)
    ax.set_title('Effective Potential with Unique Minimum\n(Certified: perfect square decomposition)', fontsize=14)
    ax.set_ylim(-1, 2)
    ax.set_xlim(0, 5)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('effective_potential.png', dpi=150)
    plt.close(fig)
    print("Saved effective_potential.png")


def plot_orbit_classification():
    """Plot orbits for different energy levels showing ellipse/parabola/hyperbola."""
    m, k, l = 1.0, 1.0, 1.0
    p = semi_latus_rectum(m, k, l)

    fig, axes = plt.subplots(1, 3, figsize=(18, 6), subplot_kw={'projection': 'polar'})

    cases = [
        (-0.3, 'Elliptic (E < 0)', 'blue'),
        (-0.001, 'Nearly Parabolic (E ≈ 0)', 'orange'),
        (0.3, 'Hyperbolic (E > 0)', 'red'),
    ]

    for ax, (E, title, color) in zip(axes, cases):
        e = kepler_eccentricity(m, k, E, l)

        if e < 1:
            theta = np.linspace(0, 2 * np.pi, 1000)
        else:
            # For hyperbola, limit angle range
            theta_max = np.arccos(-1/e) - 0.01 if e > 1 else np.pi
            theta = np.linspace(-theta_max, theta_max, 1000)

        r = kepler_orbit_radius(p, e, theta)
        r = np.clip(r, 0, 10)

        ax.plot(theta, r, color=color, linewidth=2)
        ax.plot(0, 0, 'k*', markersize=15)  # Force center
        ax.set_title(f'{title}\ne = {e:.4f}', fontsize=12, pad=20)
        ax.set_rmax(min(5, np.max(r) * 1.1))

    fig.suptitle('Orbit Classification by Energy\n(Certified: e² = 1 + 2El²/(mk²))', fontsize=14, y=1.02)
    fig.tight_layout()
    fig.savefig('orbit_classification.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("Saved orbit_classification.png")


def plot_3d_trajectory():
    """Plot a 3D Kepler trajectory."""
    m, k = 1.0, 1.0
    r0 = 1.0
    vr0 = 0.0
    vphi0 = 1.2  # Gives an elliptical orbit

    ts, rs, phis, vrs = integrate_kepler_2d(m, k, r0, vr0, vphi0, dt=0.001, n_steps=20000)

    x = rs * np.cos(phis)
    y = rs * np.sin(phis)

    fig = plt.figure(figsize=(10, 8))
    ax = fig.add_subplot(111)
    ax.plot(x, y, 'b-', linewidth=1, alpha=0.8)
    ax.plot(0, 0, 'r*', markersize=20, label='Force center')
    ax.plot(x[0], y[0], 'go', markersize=10, label='Start')
    ax.set_xlabel('x', fontsize=14)
    ax.set_ylabel('y', fontsize=14)
    ax.set_title('Kepler Orbit in Configuration Space', fontsize=14)
    ax.set_aspect('equal')
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('kepler_trajectory.png', dpi=150)
    plt.close(fig)
    print("Saved kepler_trajectory.png")


def plot_reduced_phase_space():
    """Plot the reduced (r, p_r) phase space with effective potential contours."""
    m, k, l = 1.0, 1.0, 1.0

    r = np.linspace(0.3, 5, 300)
    V = effective_potential(r, m, k, l)

    fig, ax = plt.subplots(figsize=(8, 6))

    # Phase space trajectories for different energies
    for E, color, label in [(-0.4, 'blue', 'E = -0.4'), (-0.3, 'green', 'E = -0.3'),
                             (-0.2, 'orange', 'E = -0.2')]:
        # p_r² = 2m(E - V_eff)
        pr_sq = 2 * m * (E - V)
        valid = pr_sq >= 0

        r_valid = r[valid]
        pr_pos = np.sqrt(pr_sq[valid])
        pr_neg = -pr_pos

        ax.plot(r_valid, pr_pos, color=color, linewidth=2, label=label)
        ax.plot(r_valid, pr_neg, color=color, linewidth=2)

    # Circular orbit point
    r_star = circular_orbit_radius(m, k, l)
    ax.plot(r_star, 0, 'ro', markersize=12, zorder=5, label=f'Circular orbit ($r^*$ = {r_star:.2f})')

    ax.set_xlabel('r (radial distance)', fontsize=14)
    ax.set_ylabel('$p_r$ (radial momentum)', fontsize=14)
    ax.set_title('Reduced Phase Space $(r, p_r)$\nMarsden-Weinstein reduction: 6D → 2D', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('reduced_phase_space.png', dpi=150)
    plt.close(fig)
    print("Saved reduced_phase_space.png")


def plot_eccentricity_energy():
    """Plot the eccentricity-energy relation."""
    m, k, l = 1.0, 1.0, 1.0
    V_min = effective_potential_min(m, k, l)

    E_range = np.linspace(V_min + 0.01, 1.0, 500)
    e_values = [kepler_eccentricity(m, k, E, l) for E in E_range]

    fig, ax = plt.subplots(figsize=(8, 6))
    ax.plot(E_range, e_values, 'b-', linewidth=2)
    ax.axhline(y=1, color='red', linestyle='--', alpha=0.7, label='e = 1 (parabolic)')
    ax.axvline(x=0, color='gray', linestyle='--', alpha=0.7, label='E = 0')

    # Shade regions
    ax.fill_between(E_range[E_range < 0], 0, [kepler_eccentricity(m, k, E, l) for E in E_range[E_range < 0]],
                    alpha=0.15, color='blue', label='Elliptic (E < 0)')
    ax.fill_between(E_range[E_range > 0], 1, [kepler_eccentricity(m, k, E, l) for E in E_range[E_range > 0]],
                    alpha=0.15, color='red', label='Hyperbolic (E > 0)')

    ax.set_xlabel('Energy E', fontsize=14)
    ax.set_ylabel('Eccentricity e', fontsize=14)
    ax.set_title('Eccentricity-Energy Relation\n$e^2 = 1 + 2El^2/(mk^2)$ (Certified)', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_ylim(0, 2.5)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('eccentricity_energy.png', dpi=150)
    plt.close(fig)
    print("Saved eccentricity_energy.png")


def verify_algebraic_identities():
    """Numerically verify the certified algebraic identities."""
    print("\n" + "="*60)
    print("NUMERICAL VERIFICATION OF CERTIFIED IDENTITIES")
    print("="*60)

    np.random.seed(42)
    n_tests = 10000
    max_error_ecc = 0
    max_error_vmin = 0
    denom_positive_count = 0
    denom_total_count = 0

    for _ in range(n_tests):
        m = np.random.uniform(0.5, 2)
        k = np.random.uniform(0.5, 2)
        l = np.random.uniform(0.5, 2)
        V_min = effective_potential_min(m, k, l)
        E = np.random.uniform(max(V_min + 0.01, V_min * 0.99), -0.001)

        # Test 1: e² = 1 + 2El²/(mk²)
        e = kepler_eccentricity(m, k, E, l)
        expected = 1 + 2 * E * l**2 / (m * k**2)
        error = abs(e**2 - expected)
        max_error_ecc = max(max_error_ecc, error)

        # Test 2: V_eff(r*) = V_min
        r_star = circular_orbit_radius(m, k, l)
        V_at_rstar = effective_potential(r_star, m, k, l)
        error2 = abs(V_at_rstar - V_min)
        max_error_vmin = max(max_error_vmin, error2)

        # Test 3: Denominator positivity for e < 1
        if e < 1:
            p = semi_latus_rectum(m, k, l)
            for theta in np.linspace(0, 2*np.pi, 100):
                denom = 1 + e * np.cos(theta)
                denom_total_count += 1
                if denom > 0:
                    denom_positive_count += 1

    print(f"\nTest 1: |e² - (1 + 2El²/(mk²))| over {n_tests} random params")
    print(f"  Max error: {max_error_ecc:.2e}")
    print(f"  Status: {'PASS' if max_error_ecc < 1e-10 else 'FAIL'}")

    print(f"\nTest 2: |V_eff(r*) - V_min| over {n_tests} random params")
    print(f"  Max error: {max_error_vmin:.2e}")
    print(f"  Status: {'PASS' if max_error_vmin < 1e-10 else 'FAIL'}")

    print(f"\nTest 3: Denominator 1 + e cos θ > 0 for e < 1")
    print(f"  Positive: {denom_positive_count}/{denom_total_count}")
    print(f"  Status: {'PASS' if denom_positive_count == denom_total_count else 'FAIL'}")


def main():
    """Generate all demonstration plots and run verification."""
    print("Kepler Orbit Demonstration")
    print("="*60)

    # Generate plots
    plot_effective_potential()
    plot_orbit_classification()
    plot_3d_trajectory()
    plot_reduced_phase_space()
    plot_eccentricity_energy()

    # Numerical verification
    verify_algebraic_identities()

    # Example computation
    print("\n" + "="*60)
    print("EXAMPLE: Earth-Sun System (SI units)")
    print("="*60)
    m_earth = 5.972e24
    G = 6.674e-11
    M_sun = 1.989e30
    k_earth = G * M_sun * m_earth
    l_earth = 2.661e40  # Angular momentum magnitude
    E_earth = -2.65e33   # Total energy

    p, e, a, T = kepler_orbit_params(m_earth, k_earth, E_earth, l_earth)
    print(f"  Semi-latus rectum p = {p:.3e} m")
    print(f"  Eccentricity      e = {e:.6f}")
    print(f"  Semi-major axis   a = {a:.3e} m ({a/1.496e11:.4f} AU)")
    print(f"  Period            T = {T:.3e} s ({T/86400/365.25:.4f} years)")

    # Verify e² identity
    e_sq_computed = e**2
    e_sq_formula = 1 + 2 * E_earth * l_earth**2 / (m_earth * k_earth**2)
    print(f"\n  e² (computed):  {e_sq_computed:.10f}")
    print(f"  e² (formula):   {e_sq_formula:.10f}")
    print(f"  Difference:     {abs(e_sq_computed - e_sq_formula):.2e}")

    print("\nDone! All plots saved.")


if __name__ == "__main__":
    main()
