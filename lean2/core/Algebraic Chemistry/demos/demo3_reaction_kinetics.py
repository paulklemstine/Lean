#!/usr/bin/env python3
"""
Demo 3: Kinetic Algebra — Polynomial Dynamics of Chemical Reactions
====================================================================

This demo shows how mass-action kinetics produces polynomial ODEs,
and how algebraic invariants (deficiency, detailed balance) govern
qualitative behavior.

Part of "The Algebraic Theory of Chemistry" project.
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import odeint
from matplotlib.gridspec import GridSpec
import os

os.makedirs("output", exist_ok=True)


# ============================================================
# Mass-Action Kinetics Simulator
# ============================================================
class ReactionNetwork:
    """
    A chemical reaction network with mass-action kinetics.
    
    Algebraically: dx/dt = Γ · diag(k) · Ψ(x)
    where Ψ(x) = vector of monomials x^α for each source complex α
    """
    
    def __init__(self, species, reactions):
        """
        species: list of species names
        reactions: list of dicts with 'reactants', 'products', 'rate'
        """
        self.species = species
        self.n = len(species)
        self.reactions = reactions
        self.r = len(reactions)
        self.species_idx = {s: i for i, s in enumerate(species)}
        
        # Build stoichiometric matrix
        self.Gamma = np.zeros((self.n, self.r))
        self.source_complexes = []
        
        for j, rxn in enumerate(reactions):
            source = np.zeros(self.n)
            for s, coeff in rxn.get('reactants', {}).items():
                self.Gamma[self.species_idx[s], j] -= coeff
                source[self.species_idx[s]] = coeff
            for s, coeff in rxn.get('products', {}).items():
                self.Gamma[self.species_idx[s], j] += coeff
            self.source_complexes.append(source)
    
    def rate_vector(self, x):
        """Compute Ψ(x) · k — the rate of each reaction."""
        rates = np.zeros(self.r)
        for j, rxn in enumerate(self.reactions):
            k = rxn['rate']
            monomial = k
            for s, coeff in rxn.get('reactants', {}).items():
                idx = self.species_idx[s]
                monomial *= max(x[idx], 0) ** coeff  # mass-action
            rates[j] = monomial
        return rates
    
    def rhs(self, x, t):
        """dx/dt = Γ · v(x)"""
        v = self.rate_vector(x)
        return self.Gamma @ v
    
    def simulate(self, x0, t_span, n_points=1000):
        """Simulate the mass-action ODE."""
        t = np.linspace(t_span[0], t_span[1], n_points)
        sol = odeint(self.rhs, x0, t)
        return t, sol


# ============================================================
# EXAMPLE 1: Simple Reversible Reaction A ⇌ B
# ============================================================
def demo_reversible_reaction():
    """A ⇌ B: the simplest polynomial dynamics."""
    
    network = ReactionNetwork(
        species=['A', 'B'],
        reactions=[
            {'reactants': {'A': 1}, 'products': {'B': 1}, 'rate': 1.0},
            {'reactants': {'B': 1}, 'products': {'A': 1}, 'rate': 0.5},
        ]
    )
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    fig.suptitle('Polynomial Dynamics: A ⇌ B (Linear Mass-Action)', 
                 fontsize=16, fontweight='bold')
    
    # Time evolution
    ax1 = axes[0]
    t, sol = network.simulate([1.0, 0.0], [0, 10])
    ax1.plot(t, sol[:, 0], 'b-', linewidth=2, label='[A]')
    ax1.plot(t, sol[:, 1], 'r-', linewidth=2, label='[B]')
    ax1.axhline(y=1/3, color='b', linestyle=':', alpha=0.5)
    ax1.axhline(y=2/3, color='r', linestyle=':', alpha=0.5)
    ax1.set_xlabel('Time', fontsize=12)
    ax1.set_ylabel('Concentration', fontsize=12)
    ax1.set_title('Time Evolution', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.text(7, 0.38, 'Equilibrium: [A]* = k₋/( k₊+k₋)', fontsize=9)
    
    # Phase portrait
    ax2 = axes[1]
    for a0 in np.linspace(0, 1, 10):
        b0 = 1.0 - a0
        t2, sol2 = network.simulate([a0, b0], [0, 10])
        ax2.plot(sol2[:, 0], sol2[:, 1], 'gray', linewidth=0.8, alpha=0.5)
        ax2.scatter(a0, b0, c='green', s=30, zorder=5)
    ax2.plot([0, 1], [1, 0], 'b--', linewidth=2, label='[A]+[B]=1 (conservation)')
    eq_a = 1.0 / 3.0
    eq_b = 2.0 / 3.0
    ax2.scatter(eq_a, eq_b, c='red', s=200, zorder=10, marker='*', label='Equilibrium')
    ax2.set_xlabel('[A]', fontsize=12)
    ax2.set_ylabel('[B]', fontsize=12)
    ax2.set_title('Phase Portrait\n(Conservation law: [A]+[B] = const)', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=9)
    ax2.set_aspect('equal')
    ax2.grid(True, alpha=0.3)
    
    # Algebraic structure
    ax3 = axes[2]
    ax3.axis('off')
    info = """
    ALGEBRAIC ANALYSIS
    ━━━━━━━━━━━━━━━━━━
    
    Reactions:
      A →(k₊) B     k₊ = 1.0
      B →(k₋) A     k₋ = 0.5
    
    ODE (polynomial, degree 1):
      d[A]/dt = -k₊[A] + k₋[B]
      d[B]/dt = +k₊[A] - k₋[B]
    
    Stoichiometric Matrix:
      Γ = [-1, +1]ᵀ
          [+1, -1]
    
    Conservation Law:
      [A] + [B] = const
      (ker Γᵀ = span{(1,1)})
    
    Equilibrium (det. balance):
      k₊[A]* = k₋[B]*
      [A]*/[B]* = k₋/k₊ = 0.5
    
    Deficiency: δ = 2-1-1 = 0  ✓
    → Unique equilibrium (by DZT)
    """
    ax3.text(0.05, 0.95, info, transform=ax3.transAxes, fontsize=10,
            verticalalignment='top', fontfamily='monospace',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))
    ax3.set_title('Algebraic Summary', fontsize=13, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('output/kinetics_reversible.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: output/kinetics_reversible.png")


# ============================================================
# EXAMPLE 2: Lotka-Volterra Oscillations
# ============================================================
def demo_lotka_volterra():
    """
    The Lotka-Volterra system as chemical reactions:
    A + X → 2X  (prey growth, rate k₁)
    X + Y → 2Y  (predation, rate k₂)  
    Y → B       (predator death, rate k₃)
    
    With [A] held constant (buffered), this gives oscillations.
    """
    
    k1, k2, k3 = 1.0, 0.5, 0.5
    A_const = 1.0  # buffered
    
    def lotka_rhs(y, t):
        x, yy = y  # prey, predator
        dx = k1 * A_const * x - k2 * x * yy  # polynomial degree 2
        dy = k2 * x * yy - k3 * yy            # polynomial degree 2
        return [dx, dy]
    
    fig = plt.figure(figsize=(16, 10))
    gs = GridSpec(2, 2, figure=fig)
    fig.suptitle('Lotka-Volterra: Oscillations from Polynomial Chemistry', 
                 fontsize=16, fontweight='bold')
    
    # Time series
    ax1 = fig.add_subplot(gs[0, :])
    t = np.linspace(0, 30, 2000)
    y0 = [1.0, 0.5]
    sol = odeint(lotka_rhs, y0, t)
    
    ax1.plot(t, sol[:, 0], 'b-', linewidth=2, label='Prey [X]')
    ax1.plot(t, sol[:, 1], 'r-', linewidth=2, label='Predator [Y]')
    ax1.set_xlabel('Time', fontsize=12)
    ax1.set_ylabel('Concentration', fontsize=12)
    ax1.set_title('Sustained Oscillations (Non-equilibrium)', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    
    # Phase portrait
    ax2 = fig.add_subplot(gs[1, 0])
    
    # Multiple orbits
    colors = plt.cm.viridis(np.linspace(0, 1, 8))
    for i, x0 in enumerate(np.linspace(0.3, 3.0, 8)):
        sol2 = odeint(lotka_rhs, [x0, 0.5], t)
        ax2.plot(sol2[:, 0], sol2[:, 1], '-', linewidth=1.5, color=colors[i], alpha=0.7)
    
    # Fixed point
    x_eq = k3 / k2
    y_eq = k1 * A_const / k2
    ax2.scatter(x_eq, y_eq, c='red', s=200, zorder=10, marker='*', label=f'Fixed point ({x_eq:.1f}, {y_eq:.1f})')
    
    ax2.set_xlabel('[X] (Prey)', fontsize=12)
    ax2.set_ylabel('[Y] (Predator)', fontsize=12)
    ax2.set_title('Phase Portrait: Closed Orbits\n(Center, not limit cycle)', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)
    
    # Conserved quantity (Hamiltonian)
    ax3 = fig.add_subplot(gs[1, 1])
    
    # H(x,y) = k2(x+y) - k3 ln(x) - k1*A ln(y)
    xx = np.linspace(0.1, 4, 100)
    yy = np.linspace(0.1, 4, 100)
    X, Y = np.meshgrid(xx, yy)
    H = k2 * (X + Y) - k3 * np.log(X) - k1 * A_const * np.log(Y)
    
    contour = ax3.contour(X, Y, H, levels=20, cmap='coolwarm')
    ax3.clabel(contour, inline=True, fontsize=8)
    ax3.scatter(x_eq, y_eq, c='red', s=200, zorder=10, marker='*')
    
    ax3.set_xlabel('[X] (Prey)', fontsize=12)
    ax3.set_ylabel('[Y] (Predator)', fontsize=12)
    ax3.set_title('Conserved Quantity (Hamiltonian)\nH = k₂(x+y) - k₃ln(x) - k₁A·ln(y)', 
                  fontsize=11, fontweight='bold')
    ax3.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('output/kinetics_lotka_volterra.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: output/kinetics_lotka_volterra.png")


# ============================================================
# EXAMPLE 3: Brusselator — Chemical Chaos
# ============================================================
def demo_brusselator():
    """
    The Brusselator: a model chemical oscillator
    A → X                  (rate k₁ = a)
    2X + Y → 3X            (rate k₂ = 1)
    B + X → Y + D           (rate k₃ = b)
    X → E                   (rate k₄ = 1)
    
    With A and B held constant:
    dx/dt = a - (b+1)x + x²y    (polynomial degree 3!)
    dy/dt = bx - x²y
    """
    
    fig, axes = plt.subplots(2, 3, figsize=(18, 10))
    fig.suptitle('Brusselator: Limit Cycles from Cubic Polynomial Chemistry', 
                 fontsize=16, fontweight='bold')
    
    def brusselator_rhs(y, t, a, b):
        x, yy = y
        dx = a - (b + 1) * x + x**2 * yy
        dy = b * x - x**2 * yy
        return [dx, dy]
    
    t = np.linspace(0, 50, 5000)
    
    # Three parameter regimes
    params = [
        (1.0, 1.5, 'Stable Focus (b < 1+a²)'),
        (1.0, 2.5, 'Limit Cycle (b > 1+a²)'),
        (1.0, 4.0, 'Large Limit Cycle'),
    ]
    
    for col, (a, b, title) in enumerate(params):
        # Time series
        ax_top = axes[0][col]
        y0 = [0.5, 0.5]
        sol = odeint(brusselator_rhs, y0, t, args=(a, b))
        
        ax_top.plot(t, sol[:, 0], 'b-', linewidth=1, label='[X]')
        ax_top.plot(t, sol[:, 1], 'r-', linewidth=1, label='[Y]')
        ax_top.set_xlabel('Time', fontsize=10)
        ax_top.set_ylabel('Concentration', fontsize=10)
        ax_top.set_title(f'{title}\na={a}, b={b}', fontsize=11, fontweight='bold')
        ax_top.legend(fontsize=9)
        ax_top.grid(True, alpha=0.3)
        
        # Phase portrait
        ax_bot = axes[1][col]
        ax_bot.plot(sol[:, 0], sol[:, 1], '-', linewidth=0.8, color='purple', alpha=0.7)
        ax_bot.scatter(a, b/a, c='red', s=100, zorder=10, marker='*', 
                      label=f'Fixed pt ({a:.1f}, {b/a:.1f})')
        ax_bot.scatter(y0[0], y0[1], c='green', s=100, zorder=10, label='Start')
        ax_bot.set_xlabel('[X]', fontsize=10)
        ax_bot.set_ylabel('[Y]', fontsize=10)
        ax_bot.set_title('Phase Portrait', fontsize=11, fontweight='bold')
        ax_bot.legend(fontsize=8)
        ax_bot.grid(True, alpha=0.3)
        
        # Hopf bifurcation line
        b_crit = 1 + a**2
        stability = "STABLE" if b < b_crit else "UNSTABLE"
        ax_bot.text(0.05, 0.95, f'b_crit = 1+a² = {b_crit:.1f}\nb = {b:.1f}: {stability}',
                   transform=ax_bot.transAxes, fontsize=9, verticalalignment='top',
                   bbox=dict(boxstyle='round', facecolor='lightyellow'))
    
    plt.tight_layout()
    plt.savefig('output/kinetics_brusselator.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: output/kinetics_brusselator.png")


# ============================================================
# EXAMPLE 4: Bifurcation Diagram
# ============================================================
def demo_bifurcation():
    """Show the Hopf bifurcation in the Brusselator as b varies."""
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Hopf Bifurcation: Algebraic Transition from Equilibrium to Oscillation', 
                 fontsize=15, fontweight='bold')
    
    a = 1.0
    b_values = np.linspace(0.5, 5.0, 50)
    b_crit = 1 + a**2  # = 2.0
    
    max_amplitudes_x = []
    min_amplitudes_x = []
    
    def brusselator_rhs(y, t, b):
        x, yy = y
        dx = a - (b + 1) * x + x**2 * yy
        dy = b * x - x**2 * yy
        return [dx, dy]
    
    for b in b_values:
        t = np.linspace(0, 200, 10000)
        sol = odeint(brusselator_rhs, [0.5, 0.5], t, args=(b,))
        
        # Take last 30% to avoid transients
        late = sol[7000:, 0]
        max_amplitudes_x.append(np.max(late))
        min_amplitudes_x.append(np.min(late))
    
    ax1.fill_between(b_values, min_amplitudes_x, max_amplitudes_x, alpha=0.3, color='blue')
    ax1.plot(b_values, max_amplitudes_x, 'b-', linewidth=2, label='Max [X]')
    ax1.plot(b_values, min_amplitudes_x, 'b--', linewidth=2, label='Min [X]')
    ax1.axvline(x=b_crit, color='red', linewidth=2, linestyle=':', label=f'b_crit = {b_crit}')
    ax1.axhline(y=a, color='gray', linewidth=1, linestyle=':', alpha=0.5, label=f'[X]* = a = {a}')
    ax1.set_xlabel('Parameter b', fontsize=12)
    ax1.set_ylabel('[X] amplitude', fontsize=12)
    ax1.set_title('Bifurcation Diagram', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Eigenvalue analysis
    ax2.set_xlim(-3, 3)
    ax2.set_ylim(-3, 3)
    
    b_test = np.linspace(0.5, 5.0, 30)
    for b in b_test:
        # Jacobian at fixed point (a, b/a):
        # J = [[b-1, a²], [-b, -a²]]
        J = np.array([[b - 1, a**2], [-b, -a**2]])
        eigenvalues = np.linalg.eigvals(J)
        
        color = 'blue' if b < b_crit else 'red'
        for ev in eigenvalues:
            ax2.scatter(ev.real, ev.imag, c=color, s=30, zorder=5)
    
    ax2.axvline(x=0, color='black', linewidth=2)
    ax2.axhline(y=0, color='black', linewidth=1, alpha=0.3)
    ax2.set_xlabel('Re(λ)', fontsize=12)
    ax2.set_ylabel('Im(λ)', fontsize=12)
    ax2.set_title('Eigenvalue Trajectories\n(Blue: stable, Red: unstable)', 
                  fontsize=13, fontweight='bold')
    ax2.grid(True, alpha=0.3)
    
    blue_patch = mpatches.Patch(color='blue', label=f'b < b_crit = {b_crit}')
    red_patch = mpatches.Patch(color='red', label=f'b > b_crit = {b_crit}')
    ax2.legend(handles=[blue_patch, red_patch], fontsize=10)
    
    plt.tight_layout()
    plt.savefig('output/kinetics_bifurcation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: output/kinetics_bifurcation.png")

import matplotlib.patches as mpatches

# Run all demos
demo_reversible_reaction()
demo_lotka_volterra()
demo_brusselator()
demo_bifurcation()

print("\n✅ Demo 3 Complete: Kinetic Algebra")
print("=" * 50)
print("Key results:")
print("• Mass-action kinetics produces polynomial ODEs")
print("• Degree of polynomial = maximum molecularity of reactions")
print("• Deficiency zero → unique equilibrium (no oscillations)")
print("• Hopf bifurcation: algebraic transition from stability to oscillation")
print("• Conserved quantities are algebraic invariants of the polynomial system")
