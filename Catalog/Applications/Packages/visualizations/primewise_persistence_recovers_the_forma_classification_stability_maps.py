"""
Visualization: Stability of Arithmetic Persistence Classifier

Demonstrates the stability theorem: the height regime classifier is robust
under bounded perturbation of slope data, with stability radius equal to
half the minimal nonzero deviation from the symmetry center.

This visualizes the key result that makes the framework computationally viable:
even with noisy or approximate Frobenius data, the supersingular/finite-height
dichotomy can be reliably detected.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import random

# ---- Inline implementations ----

def height_signature(slopes, center, eps):
    return sum(1 for s in slopes if abs(s - center) <= eps)

def classify(slopes, center, eps):
    return len(slopes) == height_signature(slopes, center, eps)

def min_deviation(slopes, center):
    devs = [abs(s - center) for s in slopes if abs(s - center) > 1e-15]
    return min(devs) if devs else 0.0

def perturb(slopes, delta, rng):
    return [s + rng.uniform(-delta, delta) for s in slopes]

# ---- Profile constructors ----

def ordinary_slopes():
    return [0.0] + [1.0] * 20 + [2.0]

def height_h_slopes(h):
    slopes = []
    for k in range(1, h + 1):
        slopes.append(1.0 + k / h)
        slopes.append(1.0 - k / h)
    slopes.extend([1.0] * (22 - len(slopes)))
    return slopes

# ---- Build figure ----

center = 1.0
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

test_profiles = [
    ('Ordinary (h=1)', ordinary_slopes()),
    ('Height h=3', height_h_slopes(3)),
    ('Height h=8', height_h_slopes(8)),
]

for ax_idx, (name, base_slopes) in enumerate(test_profiles):
    ax = axes[ax_idx]
    md = min_deviation(base_slopes, center)
    stab_r = md / 2

    delta_range = np.linspace(0, md * 2, 40)
    eps_range = np.linspace(0.01, 1.5, 40)

    rng = random.Random(42)
    accuracy_map = np.zeros((len(eps_range), len(delta_range)))

    for i, eps in enumerate(eps_range):
        base_cls = classify(base_slopes, center, eps)
        for j, delta in enumerate(delta_range):
            correct = 0
            num_trials = 30
            for _ in range(num_trials):
                noisy = perturb(base_slopes, delta, rng)
                if classify(noisy, center, eps) == base_cls:
                    correct += 1
            accuracy_map[i, j] = correct / num_trials

    im = ax.imshow(accuracy_map, aspect='auto', origin='lower',
                  extent=[0, md*2, eps_range[0], eps_range[-1]],
                  cmap='RdYlGn', vmin=0, vmax=1)
    ax.axvline(x=stab_r, color='white', linestyle='--', linewidth=2.5)
    ax.text(stab_r + md*0.05, eps_range[-1]*0.9,
           f'r = {stab_r:.3f}', color='white', fontsize=9, fontweight='bold')
    ax.set_xlabel('Perturbation δ', fontsize=11)
    if ax_idx == 0:
        ax.set_ylabel('Scale ε', fontsize=11)
    ax.set_title(f'{name}\nmin. dev. = {md:.3f}', fontsize=11, fontweight='bold')

plt.colorbar(im, ax=axes.tolist(), label='Classification accuracy', shrink=0.8)
plt.suptitle('Classification Stability Under Slope Perturbation',
            fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_stability.png', dpi=150, bbox_inches='tight')
print("Saved: viz_stability.png")
plt.close()
