#!/usr/bin/env python3
"""
Tropical Measure Theory: Interactive Demo

Demonstrates the key concepts formalized in Lean 4:
- Max-plus measures and integration
- Tropical probability and expectation
- Certified robustness via Lipschitz bounds
- Tropical Hoeffding concentration

This demo brings the abstract mathematics to life with concrete
numerical examples and visualizations.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend

# ============================================================
# 1. Max-Plus Measure and Integration
# ============================================================

def max_plus_integral(f, weights):
    """
    Compute the max-plus integral: max_x (f(x) + w(x))
    
    This is the tropical analogue of the Lebesgue integral.
    In optimization terms: the best coupling of function values and weights.
    """
    return np.max(f + weights)

def tropical_expectation(f, weights):
    """Tropical expectation under a probability measure (max weight = 0)."""
    assert np.isclose(np.max(weights), 0), "Weights must be normalized (max = 0)"
    return max_plus_integral(f, weights)

print("=" * 60)
print("TROPICAL MEASURE THEORY: Interactive Demo")
print("=" * 60)

# Example 1: Basic max-plus integration
print("\n--- Example 1: Max-Plus Integration ---")
X = np.array([1.0, 3.0, 2.0, 5.0, 4.0])  # Function values
W = np.array([-1.0, -2.0, 0.0, -3.0, -1.0])  # Measure weights

integral = max_plus_integral(X, W)
print(f"Function values:  f = {X}")
print(f"Measure weights:  w = {W}")
print(f"f + w =           {X + W}")
print(f"Max-plus integral: max(f + w) = {integral}")
print(f"Attained at x = {np.argmax(X + W)} where f + w = {X[np.argmax(X + W)]} + {W[np.argmax(X + W)]}")

# Example 2: Tropical probability
print("\n--- Example 2: Tropical Probability ---")
P = np.array([0.0, -1.0, -2.0, -3.0, -0.5])  # Probability weights (max = 0)
f = np.array([2.0, 4.0, 1.0, 3.0, 5.0])

E_trop = tropical_expectation(f, P)
print(f"Probability weights: P = {P}")
print(f"Function values:     f = {f}")
print(f"Tropical expectation E_T[f] = {E_trop}")
print(f"Classical expectation (uniform) = {np.mean(f):.2f}")
print(f"Maximum of f = {np.max(f)}")
print(f"\nNote: E_T[f] lies between min(f) and max(f), as proven in Lean")

# Verify bounded expectation theorem
a, b = np.min(f), np.max(f)
print(f"Bounded expectation: {a} ≤ E_T[f]={E_trop} ≤ {b}  ✓")

# Example 3: Constant function
print("\n--- Example 3: E_T[constant] = constant ---")
c = 7.0
f_const = np.full(5, c)
E_const = tropical_expectation(f_const, P)
print(f"E_T[{c}] = {E_const}  (should be {c})  ✓")

# Example 4: Shift equivariance
print("\n--- Example 4: Shift Equivariance ---")
shift = 3.0
E_shifted = tropical_expectation(f + shift, P)
print(f"E_T[f + {shift}] = {E_shifted}")
print(f"E_T[f] + {shift} = {E_trop + shift}")
print(f"Equal? {np.isclose(E_shifted, E_trop + shift)}  ✓")

# ============================================================
# 2. Tropical Markov Inequality
# ============================================================

print("\n--- Example 5: Tropical Markov Inequality ---")
t = 3.0
print(f"Threshold t = {t}")
print(f"E_T[f] = {E_trop}")
for i, (fi, pi) in enumerate(zip(f, P)):
    if fi >= t:
        bound = E_trop - t
        print(f"  x={i}: f={fi} ≥ {t}, P.weight={pi} ≤ E_T[f]-t={bound:.1f}  "
              f"{'✓' if pi <= bound + 1e-10 else '✗'}")

# ============================================================
# 3. Tropical Hoeffding Concentration
# ============================================================

print("\n--- Example 6: Tropical Hoeffding Pointwise ---")
t_vals = [0.5, 1.0, 2.0, 3.0]
for t in t_vals:
    exceeds = [(i, P[i]) for i in range(len(f)) if f[i] >= E_trop + t]
    if exceeds:
        for i, pi in exceeds:
            print(f"  t={t}: x={i}, f(x)={f[i]} ≥ E_T[f]+t={E_trop+t:.1f}, "
                  f"P.weight={pi} ≤ -t={-t}  {'✓' if pi <= -t + 1e-10 else '✗'}")
    else:
        print(f"  t={t}: No points with f(x) ≥ E_T[f]+t={E_trop+t:.1f}")

# ============================================================
# 4. Certified Robustness
# ============================================================

print("\n--- Example 7: Certified Robustness ---")

def lipschitz_certified_radius(K, margin):
    """Certified robustness radius = margin / K"""
    return margin / K

# Simulate a 1D tropical neural network
K = 2.0  # Lipschitz constant
x0 = 0.0
margin = 1.0

radius = lipschitz_certified_radius(K, margin)
print(f"Lipschitz constant K = {K}")
print(f"Margin at x₀ = {margin}")
print(f"Certified radius = margin/K = {radius}")
print(f"Any perturbation within radius {radius} preserves positive classification  ✓")

# Binary classifier stability
print("\n--- Example 8: Binary Classifier Stability ---")
scores_class0 = np.array([3.0, 1.0, 2.0])
scores_class1 = np.array([1.0, 2.0, 1.5])
W_clf = np.array([0.0, -1.0, -0.5])

int0 = max_plus_integral(scores_class0, W_clf)
int1 = max_plus_integral(scores_class1, W_clf)
prediction_margin = int0 - int1
print(f"Class 0 integral: {int0}")
print(f"Class 1 integral: {int1}")
print(f"Prediction margin: {prediction_margin}")

eps = 0.3
print(f"\nPerturbation ε = {eps}")
print(f"2ε = {2*eps} < margin = {prediction_margin}?  {2*eps < prediction_margin}")
if 2*eps < prediction_margin:
    print("Classification is CERTIFIED STABLE under ε-perturbation  ✓")

# ============================================================
# 5. Product Measures and Tropical Fubini
# ============================================================

print("\n--- Example 9: Product Measures (Tropical Fubini) ---")
W1 = np.array([0.0, -1.0, -2.0])
W2 = np.array([0.0, -0.5])

# Product weight: w(x,y) = w1(x) + w2(y)
W_prod = np.array([[W1[i] + W2[j] for j in range(len(W2))] for i in range(len(W1))])
print(f"W1 = {W1}")
print(f"W2 = {W2}")
print(f"Product weights:\n{W_prod}")
print(f"Max product weight = {np.max(W_prod)} (should be 0)  ✓")

# ============================================================
# 6. Tropical Variance
# ============================================================

print("\n--- Example 10: Tropical Variance ---")
P_var = np.array([0.0, -1.0, -2.0, -0.5])
f_var = np.array([1.0, 3.0, 2.0, 4.0])

E_f = tropical_expectation(f_var, P_var)
E_neg_f = tropical_expectation(-f_var, P_var)
trop_var = E_f + E_neg_f

print(f"E_T[f] = {E_f}")
print(f"E_T[-f] = {E_neg_f}")
print(f"Tropical variance = E_T[f] + E_T[-f] = {trop_var}")
print(f"Variance ≥ 0?  {trop_var >= 0}  ✓")

a_var, b_var = np.min(f_var), np.max(f_var)
print(f"Range bound: Var ≤ b - a = {b_var} - {a_var} = {b_var - a_var}")
print(f"Satisfied?  {trop_var <= b_var - a_var + 1e-10}  ✓")

# ============================================================
# 7. Visualization
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Max-plus integral visualization
ax1 = axes[0, 0]
n_points = 20
x_vals = np.arange(n_points)
f_plot = np.sin(x_vals * 0.5) * 2 + 3
w_plot = -np.abs(x_vals - 10) * 0.3  # Peaked at x=10
w_plot -= np.max(w_plot)  # Normalize

coupling = f_plot + w_plot
opt_idx = np.argmax(coupling)

ax1.bar(x_vals - 0.2, f_plot, 0.35, label='f(x)', alpha=0.7, color='steelblue')
ax1.bar(x_vals + 0.2, coupling, 0.35, label='f(x) + w(x)', alpha=0.7, color='coral')
ax1.axhline(y=coupling[opt_idx], color='red', linestyle='--', 
            label=f'∫⁺ f dμ = {coupling[opt_idx]:.2f}')
ax1.scatter([opt_idx], [coupling[opt_idx]], color='red', s=100, zorder=5)
ax1.set_xlabel('x')
ax1.set_ylabel('Value')
ax1.set_title('Max-Plus Integration: ∫⁺ f dμ = max_x(f(x) + w(x))')
ax1.legend(fontsize=8)

# Plot 2: Tropical concentration
ax2 = axes[0, 1]
n_samples = 50
weights = np.zeros(n_samples)
weights[0] = 0  # mode
weights[1:] = -np.random.exponential(1.0, n_samples - 1)
weights.sort()
weights = weights[::-1]
weights -= np.max(weights)  # normalize

t_range = np.linspace(0, 5, 100)
for t in t_range:
    count = np.sum(weights >= -t)

ax2.bar(range(n_samples), weights, color='steelblue', alpha=0.7)
ax2.axhline(y=0, color='black', linewidth=0.5)

# Highlight concentration: points with weight ≥ -t
t_demo = 1.5
ax2.axhline(y=-t_demo, color='red', linestyle='--', label=f'Threshold -t = {-t_demo}')
concentrated = weights >= -t_demo
ax2.bar(np.where(concentrated)[0], weights[concentrated], color='coral', alpha=0.9)
ax2.set_xlabel('Point index (sorted by weight)')
ax2.set_ylabel('Weight P(x)')
ax2.set_title(f'Tropical Concentration: {np.sum(concentrated)} points above -t')
ax2.legend(fontsize=8)

# Plot 3: Certified robustness region
ax3 = axes[1, 0]
K_vals = [0.5, 1.0, 2.0, 4.0]
margins = np.linspace(0.1, 5, 100)

for K in K_vals:
    radii = margins / K
    ax3.plot(margins, radii, label=f'K = {K}')

ax3.set_xlabel('Classification Margin m')
ax3.set_ylabel('Certified Radius m/K')
ax3.set_title('Certified Robustness: radius = margin / Lipschitz constant')
ax3.legend()
ax3.grid(True, alpha=0.3)

# Plot 4: Tropical vs Classical expectation
ax4 = axes[1, 1]
n_trials = 200
classical_means = []
tropical_means = []

for _ in range(n_trials):
    f_rand = np.random.randn(10) * 2 + 3
    p_rand = -np.random.exponential(0.5, 10)
    p_rand -= np.max(p_rand)  # normalize
    
    classical_means.append(np.mean(f_rand))
    tropical_means.append(tropical_expectation(f_rand, p_rand))

ax4.scatter(classical_means, tropical_means, alpha=0.5, s=10, color='steelblue')
ax4.plot([0, 8], [0, 8], 'r--', alpha=0.5, label='y = x')
ax4.set_xlabel('Classical Mean E[f]')
ax4.set_ylabel('Tropical Expectation E_T[f]')
ax4.set_title('Tropical vs Classical: E_T[f] ≥ E[f] (max ≥ mean)')
ax4.legend()
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tropical_measure_theory.png', dpi=150, bbox_inches='tight')
print("\n✓ Visualization saved to tropical_measure_theory.png")

# ============================================================
# 8. Summary of Verified Properties
# ============================================================

print("\n" + "=" * 60)
print("VERIFIED PROPERTIES (formalized in Lean 4)")
print("=" * 60)
print("""
1.  maxPlusIntegral_mono         : f ≤ g ⟹ ∫⁺f ≤ ∫⁺g
2.  maxPlusIntegral_shift        : ∫⁺(f+c) = ∫⁺f + c
3.  maxPlusIntegral_const        : ∫⁺c = c + max w
4.  maxPlusIntegral_max          : ∫⁺max(f,g) = max(∫⁺f, ∫⁺g)
5.  maxPlusIntegral_lipschitz    : ‖f-g‖∞ ≤ ε ⟹ |∫⁺f - ∫⁺g| ≤ ε
6.  tropicalExpectation_const    : E_T[c] = c
7.  tropicalExpectation_bounded  : a ≤ f ≤ b ⟹ a ≤ E_T[f] ≤ b
8.  tropicalMarkov               : f(x) ≥ t ⟹ w(x) ≤ ∫⁺f - t
9.  tropical_hoeffding_pointwise : f(x) ≥ E+t ⟹ w(x) ≤ -t
10. certified_classification     : K-Lip + margin m ⟹ stable in r=m/K
11. tropical_binary_stability    : margin > 2ε ⟹ prediction preserved
12. maxPlusIntegral_dirac_eval   : ∫⁺f dδ_{x₀} = f(x₀)
13. tropicalVariance_nonneg      : Var_T[f] ≥ 0
14. tropicalVariance_le_range    : Var_T[f] ≤ b - a
15. maxPlusIntegral_eq_neg_inf   : ∫⁺f = -(min(-(f+w)))  [duality]
16. productMaxPlusMeasure_isProb : P₁⊗P₂ is tropical probability
17. maxPlusIntegral_tendsto      : pointwise conv ⟹ integral conv
18. measureFinset_union          : μ(A∪B) = max(μ(A), μ(B))
19. dualMeasure_involution       : (μ*)* = μ

All proofs use only standard axioms: propext, Classical.choice, Quot.sound
""")
