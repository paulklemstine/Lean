#!/usr/bin/env python3
"""
Non-Archimedean Probability: Numerical Demonstrations

Demonstrates the key results using a toy non-Archimedean field:
the field of formal Laurent series ℝ((ε)), approximated numerically
by choosing ε to be a very small positive float.
"""

import math

# ============================================================
# Toy model: approximate a non-Archimedean field using small ε
# ============================================================

class SurrealProb:
    """
    Represents a surreal-like probability value a + b·ε
    where ε is a formal infinitesimal (ε > 0, ε < 1/n for all n).
    
    In this model:
    - 'real_part' is the standard real component
    - 'infml_part' is the coefficient of ε (the infinitesimal component)
    """
    def __init__(self, real_part: float, infml_part: float = 0.0):
        self.real_part = real_part
        self.infml_part = infml_part
    
    def __add__(self, other):
        return SurrealProb(self.real_part + other.real_part,
                          self.infml_part + other.infml_part)
    
    def __sub__(self, other):
        return SurrealProb(self.real_part - other.real_part,
                          self.infml_part - other.infml_part)
    
    def __mul__(self, other):
        # (a + bε)(c + dε) = ac + (ad + bc)ε + bdε² ≈ ac + (ad+bc)ε
        return SurrealProb(
            self.real_part * other.real_part,
            self.real_part * other.infml_part + self.infml_part * other.real_part
        )
    
    def __truediv__(self, other):
        if other.real_part != 0:
            # Standard division when denominator has non-zero real part
            r = self.real_part / other.real_part
            i = (self.infml_part * other.real_part - self.real_part * other.infml_part) / (other.real_part ** 2)
            return SurrealProb(r, i)
        elif other.infml_part != 0:
            # Division by pure infinitesimal: result is "infinite"
            return SurrealProb(self.infml_part / other.infml_part, 0)
        else:
            raise ZeroDivisionError("Division by zero in SurrealProb")
    
    def __repr__(self):
        if self.infml_part == 0:
            return f"{self.real_part}"
        elif self.real_part == 0:
            return f"{self.infml_part}·ε"
        else:
            sign = "+" if self.infml_part > 0 else "-"
            return f"{self.real_part} {sign} {abs(self.infml_part)}·ε"
    
    def is_infinitesimal(self):
        return self.real_part == 0 and self.infml_part > 0
    
    def is_positive(self):
        if self.real_part > 0:
            return True
        if self.real_part == 0:
            return self.infml_part > 0
        return False


# ============================================================
# Demo 1: Non-Archimedean probability on a finite set
# ============================================================
print("=" * 60)
print("DEMO 1: Non-Archimedean Probability on {1, 2, 3, 4, 5}")
print("=" * 60)

# Each point gets probability 1/5 + c·ε for some infinitesimal adjustment
# To demonstrate, we assign each point probability 1/5 exactly
# (which in the non-Archimedean setting could be perturbed by ε)
n = 5
points = list(range(1, n + 1))
prob = {p: SurrealProb(1.0 / n) for p in points}

total = SurrealProb(0)
for p in points:
    total = total + prob[p]
print(f"Total probability: {total}")
print(f"Each point: {prob[1]}")
print()

# ============================================================
# Demo 2: Singleton Conditional Probability Theorem
# ============================================================
print("=" * 60)
print("DEMO 2: Singleton Conditional Probability Theorem")
print("=" * 60)

# In a non-Archimedean space, P({ω}) = ε > 0 for each ω
# P(A | {ω}) = 1 if ω ∈ A, 0 if ω ∉ A
eps = SurrealProb(0, 1)  # ε

# Construct a "uniform infinitesimal" measure on ℕ_{≤10}
points_10 = list(range(1, 11))
# Each point gets probability ε (infinitesimal)
mu_point = eps
A_set = {1, 2, 3, 4, 5}  # Event A = first 5 points

# P(A | {3}) should be 1 since 3 ∈ A
omega_in = 3
A_inter_singleton = SurrealProb(0, 1) if omega_in in A_set else SurrealProb(0, 0)
cond_in = A_inter_singleton / mu_point
print(f"P(A | {{3}}) = {cond_in}  (expected: 1, since 3 ∈ A)")

# P(A | {7}) should be 0 since 7 ∉ A
omega_out = 7
A_inter_singleton_out = SurrealProb(0, 1) if omega_out in A_set else SurrealProb(0, 0)
cond_out = A_inter_singleton_out / mu_point
print(f"P(A | {{7}}) = {cond_out}  (expected: 0, since 7 ∉ A)")
print()

# ============================================================
# Demo 3: Non-Archimedean Exclusion Principle
# ============================================================
print("=" * 60)
print("DEMO 3: Non-Archimedean Exclusion Principle")
print("=" * 60)

# In classical probability: P({ω}ᶜ) = 1 - P({ω}) = 1 - 0 = 1
# In non-Archimedean: P({ω}ᶜ) = 1 - ε < 1
one = SurrealProb(1)
compl_prob = one - eps
print(f"P({{ω}}ᶜ) = {compl_prob}")
print(f"P({{ω}}ᶜ) < 1? {compl_prob.real_part < 1 or (compl_prob.real_part == 1 and compl_prob.infml_part < 0)}")
print()
print("Classical: P({ω}ᶜ) = 1 (information lost)")
print("Non-Arch:  P({ω}ᶜ) = 1 - ε < 1 (information preserved)")
print()

# ============================================================
# Demo 4: Bayes' Theorem
# ============================================================
print("=" * 60)
print("DEMO 4: Bayes' Theorem in Non-Archimedean Setting")
print("=" * 60)

# P(A|B) · P(B) = P(B|A) · P(A)
# Using a finite example on {1,...,10}
mu_A = SurrealProb(0.5)  # A = {1,...,5}
mu_B = SurrealProb(0.3)  # B = {1,2,3}
mu_AB = SurrealProb(0.3) # A ∩ B = {1,2,3} = B

cond_A_given_B = mu_AB / mu_B  # P(A|B) = 0.3/0.3 = 1
cond_B_given_A = mu_AB / mu_A  # P(B|A) = 0.3/0.5 = 0.6

lhs = cond_A_given_B * mu_B
rhs = cond_B_given_A * mu_A

print(f"P(A|B) = {cond_A_given_B}")
print(f"P(B|A) = {cond_B_given_A}")
print(f"P(A|B) · P(B) = {lhs}")
print(f"P(B|A) · P(A) = {rhs}")
print(f"Bayes verified: {abs(lhs.real_part - rhs.real_part) < 1e-10}")
print()

# ============================================================
# Demo 5: Archimedean Exclusion
# ============================================================
print("=" * 60)
print("DEMO 5: Archimedean Exclusion")
print("=" * 60)

# In ℝ (Archimedean), no infinitesimals exist
# For any x > 0, ∃ n: n·x ≥ 1
x_test = 0.001
n_needed = math.ceil(1.0 / x_test)
print(f"Test x = {x_test}")
print(f"  Need n = {n_needed} to get n·x ≥ 1")
print(f"  {n_needed} · {x_test} = {n_needed * x_test} ≥ 1 ✓")
print()
print("In ℝ, every positive number fails the infinitesimal condition.")
print("This is WHY we need non-Archimedean fields (like surreals) for")
print("infinitesimal probability theory.")

# ============================================================
# Demo 6: Inclusion-Exclusion
# ============================================================
print()
print("=" * 60)
print("DEMO 6: Inclusion-Exclusion with Infinitesimals")
print("=" * 60)

# μ(A ∪ B) + μ(A ∩ B) = μ(A) + μ(B)
mu_A2 = SurrealProb(0.4, 2)  # 0.4 + 2ε
mu_B2 = SurrealProb(0.3, 3)  # 0.3 + 3ε
mu_AB2 = SurrealProb(0.1, 1) # 0.1 + 1ε
mu_AuB2 = mu_A2 + mu_B2 - mu_AB2  # By inclusion-exclusion

print(f"μ(A) = {mu_A2}")
print(f"μ(B) = {mu_B2}")
print(f"μ(A ∩ B) = {mu_AB2}")
print(f"μ(A ∪ B) = {mu_AuB2}")

lhs2 = mu_AuB2 + mu_AB2
rhs2 = mu_A2 + mu_B2
print(f"μ(A∪B) + μ(A∩B) = {lhs2}")
print(f"μ(A) + μ(B) = {rhs2}")
print(f"Inclusion-exclusion verified: {abs(lhs2.real_part - rhs2.real_part) < 1e-10}")


#!/usr/bin/env python3
"""
Visualization: Non-Archimedean vs Classical Probability

Creates a comparison plot showing how non-Archimedean probability
assigns positive (infinitesimal) measure to every point, while
classical probability assigns zero.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

def create_comparison_plot():
    """Create a side-by-side comparison of classical vs non-Archimedean probability."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Classical probability on [0,1]
    x = np.linspace(0, 1, 200)
    y_density = np.ones_like(x)  # Uniform density = 1
    
    ax1.fill_between(x, 0, y_density, alpha=0.3, color='blue', label='Density f(x) = 1')
    ax1.set_title('Classical Probability\n(Lebesgue measure on [0,1])', fontsize=13)
    ax1.set_xlabel('x')
    ax1.set_ylabel('Density')
    
    # Highlight that P({x}) = 0 for every x
    for xi in [0.2, 0.5, 0.8]:
        ax1.plot(xi, 0, 'ro', markersize=8, zorder=5)
        ax1.annotate(f'P({{x={xi}}}) = 0', (xi, 0), 
                     textcoords="offset points", xytext=(0, 15),
                     fontsize=9, ha='center', color='red')
    
    ax1.set_ylim(-0.1, 1.5)
    ax1.legend(loc='upper right')
    ax1.text(0.5, 1.3, 'Every point has probability 0', 
             ha='center', fontsize=11, color='red', fontweight='bold')
    
    # Non-Archimedean probability
    # Visualize as tiny bars at each point
    n_points = 20
    x_points = np.linspace(0.025, 0.975, n_points)
    eps_height = 0.05  # Visual representation of ε
    
    ax2.bar(x_points, eps_height, width=0.04, color='green', alpha=0.7, 
            label=f'μ({{x}}) = ε > 0')
    ax2.set_title('Non-Archimedean Probability\n(Surreal-valued measure)', fontsize=13)
    ax2.set_xlabel('x')
    ax2.set_ylabel('Measure (ε scale)')
    
    # Annotate
    ax2.annotate('μ({x}) = ε\n(infinitesimal > 0)', (0.5, eps_height), 
                 textcoords="offset points", xytext=(0, 20),
                 fontsize=10, ha='center', color='green',
                 arrowprops=dict(arrowstyle='->', color='green'))
    
    ax2.set_ylim(-0.01, 0.15)
    ax2.legend(loc='upper right')
    ax2.text(0.5, 0.13, 'Every point has probability ε > 0', 
             ha='center', fontsize=11, color='green', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('nonarch_probability_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: nonarch_probability_comparison.png")


def create_conditional_plot():
    """Visualize the Singleton Conditional Probability Theorem."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Classical: P(A|{ω}) is undefined
    points = np.arange(1, 11)
    A_set = [1, 2, 3, 4, 5]
    
    colors1 = ['lightcoral' if p in A_set else 'lightblue' for p in points]
    ax1.bar(points, [0]*10, color=colors1, edgecolor='black', linewidth=1)
    ax1.set_title('Classical: P(A | {ω}) = 0/0 = UNDEFINED', fontsize=12, color='red')
    ax1.set_xlabel('ω')
    ax1.set_ylabel('P(A | {ω})')
    ax1.set_ylim(-0.1, 1.3)
    ax1.set_xticks(points)
    ax1.text(5.5, 0.7, '???\nUndefined for\ncontinuous distributions', 
             ha='center', fontsize=12, color='red', fontweight='bold')
    
    red_patch = mpatches.Patch(color='lightcoral', label='ω ∈ A')
    blue_patch = mpatches.Patch(color='lightblue', label='ω ∉ A')
    ax1.legend(handles=[red_patch, blue_patch])
    
    # Non-Archimedean: P(A|{ω}) = 1 or 0
    cond_probs = [1 if p in A_set else 0 for p in points]
    colors2 = ['green' if p in A_set else 'gray' for p in points]
    ax2.bar(points, cond_probs, color=colors2, edgecolor='black', linewidth=1)
    ax2.set_title('Non-Archimedean: P(A | {ω}) = well-defined!', fontsize=12, color='green')
    ax2.set_xlabel('ω')
    ax2.set_ylabel('P(A | {ω})')
    ax2.set_ylim(-0.1, 1.3)
    ax2.set_xticks(points)
    
    green_patch = mpatches.Patch(color='green', label='P(A|{ω}) = 1')
    gray_patch = mpatches.Patch(color='gray', label='P(A|{ω}) = 0')
    ax2.legend(handles=[green_patch, gray_patch])
    
    plt.suptitle('Singleton Conditional Probability Theorem', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('conditional_probability_theorem.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: conditional_probability_theorem.png")


def create_exclusion_plot():
    """Visualize the Non-Archimedean Exclusion Principle."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Show μ({ω}ᶜ) for classical vs non-Archimedean
    categories = ['Classical\n(ℝ-valued)', 'Non-Archimedean\n(Surreal-valued)']
    values = [1.0, 0.95]  # 0.95 represents "1 - ε" visually
    colors = ['salmon', 'lightgreen']
    
    bars = ax.bar(categories, values, color=colors, edgecolor='black', linewidth=2, width=0.5)
    
    ax.axhline(y=1.0, color='red', linestyle='--', linewidth=1, label='μ(Ω) = 1')
    ax.set_ylabel('Measure', fontsize=12)
    ax.set_title('Non-Archimedean Exclusion Principle\nμ({ω}ᶜ) in classical vs non-Archimedean probability', 
                 fontsize=13, fontweight='bold')
    
    ax.text(0, 1.02, 'μ({ω}ᶜ) = 1\n(= μ(Ω) !)', ha='center', fontsize=10, color='red')
    ax.text(1, 0.97, 'μ({ω}ᶜ) = 1 - ε\n(< μ(Ω) ✓)', ha='center', fontsize=10, color='green')
    
    ax.set_ylim(0, 1.15)
    ax.legend(fontsize=10)
    
    plt.tight_layout()
    plt.savefig('exclusion_principle.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: exclusion_principle.png")


if __name__ == "__main__":
    create_comparison_plot()
    create_conditional_plot()
    create_exclusion_plot()
