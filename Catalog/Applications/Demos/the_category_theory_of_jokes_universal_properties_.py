"""
Demo: The Category Theory of Jokes — Universal Properties of Humor

Numerical demonstrations of the main theorems:
1. Iterated Subversion Amplification
2. Humor Chain Inequality
3. Contraction Fixed Point Convergence
4. Surprise Entropy Computation
5. Humor Duality in Compact Spaces
"""

import math
from typing import List, Tuple


def distance(x: float, y: float) -> float:
    """Euclidean distance on R."""
    return abs(x - y)


def humor_value(expected: float, actual: float) -> float:
    """The humor value of a joke: distance between expected and actual."""
    return distance(expected, actual)


# Demo 1: Iterated Subversion Amplification
print("=" * 60)
print("Demo 1: Iterated Subversion Amplification Bound")
print("=" * 60)
print()

amplification = 1.5
x, y = 1.0, 2.0
initial_dist = distance(x, y)

print(f"Subversion map: f(x) = {amplification}*x")
print(f"Amplification constant C = {amplification}")
print(f"Initial distance d(x, y) = {initial_dist}")
print()

for n in range(8):
    fx = amplification**n * x
    fy = amplification**n * y
    actual = distance(fx, fy)
    bound = amplification**n * initial_dist
    print(f"  n={n}: d(f^n(x), f^n(y)) = {actual:.4f}, C^n * d(x,y) = {bound:.4f}, tight: {abs(actual - bound) < 1e-10}")

print()

# Demo 2: Humor Chain Inequality
print("=" * 60)
print("Demo 2: Humor Chain Inequality")
print("=" * 60)
print()

chain = [0.0, 3.0, 1.0, 7.0, 2.0, 10.0]
total_humor = sum(distance(chain[i], chain[i+1]) for i in range(len(chain)-1))
end_to_end = distance(chain[0], chain[-1])

print(f"Joke chain: {chain}")
print(f"Step humors: {[distance(chain[i], chain[i+1]) for i in range(len(chain)-1)]}")
print(f"Total humor (sum of steps) = {total_humor}")
print(f"End-to-end humor = {end_to_end}")
print(f"Chain inequality holds: {end_to_end} ≤ {total_humor} → {end_to_end <= total_humor + 1e-10}")
print()

# Demo 3: Contraction Fixed Point
print("=" * 60)
print("Demo 3: Humor Convergence — Contraction Fixed Point")
print("=" * 60)
print()

def contraction_map(x: float) -> float:
    """A contractive subversion: f(x) = 0.5*x + 1."""
    return 0.5 * x + 1.0

C = 0.5  # amplification
x0 = 10.0
fixed_point = 2.0  # solve x = 0.5x + 1 → x = 2

print(f"Subversion map: f(x) = 0.5*x + 1")
print(f"Amplification C = {C} < 1 (contraction)")
print(f"Fixed point (theoretical): {fixed_point}")
print(f"Starting point: x₀ = {x0}")
print()

x = x0
for n in range(15):
    dist_to_fp = distance(x, fixed_point)
    bound = C**n * distance(x0, fixed_point)
    print(f"  n={n:2d}: f^n(x₀) = {x:10.6f}, d(f^n(x₀), p) = {dist_to_fp:.6f}, C^n·d(x₀,p) = {bound:.6f}")
    x = contraction_map(x)

print()

# Demo 4: Surprise Entropy
print("=" * 60)
print("Demo 4: Surprise Entropy — Bridge to Information Theory")
print("=" * 60)
print()

expected = 0.0
punchlines = [1.0, 3.0, 5.0, 10.0]
weights = [0.4, 0.3, 0.2, 0.1]

entropy = sum(w * distance(p, expected) for w, p in zip(weights, punchlines))
max_surprise = max(distance(p, expected) for p in punchlines)

print(f"Expected resolution: {expected}")
print(f"Punchlines: {punchlines}")
print(f"Weights: {weights}")
print(f"Individual surprises: {[distance(p, expected) for p in punchlines]}")
print(f"Surprise entropy: {entropy:.2f}")
print(f"Maximum surprise: {max_surprise:.2f}")
print(f"Entropy ≤ max surprise: {entropy <= max_surprise + 1e-10}")
print()

# Shannon entropy comparison
print("Shannon entropy of the same weights:")
shannon = -sum(w * math.log(w) for w in weights if w > 0)
print(f"  H(w) = {shannon:.4f}")
print(f"  When punchlines are -log(w): {[-math.log(w) for w in weights]}")
surprise_entropy_shannon = sum(w * abs(math.log(w)) for w in weights)
print(f"  Surprise entropy with these punchlines: {surprise_entropy_shannon:.4f}")
print(f"  Equals Shannon entropy: {abs(surprise_entropy_shannon - shannon) < 1e-10}")
print()

# Demo 5: Humor Duality
print("=" * 60)
print("Demo 5: Humor Duality in Compact Spaces")
print("=" * 60)
print()

# Compact space: [0, 10]
space = [i * 0.5 for i in range(21)]  # [0, 0.5, 1, ..., 10]
expected = 3.7

distances = [(x, distance(x, expected)) for x in space]
funniest = max(distances, key=lambda t: t[1])
most_boring = min(distances, key=lambda t: t[1])

print(f"Compact space: [0, 10] discretized")
print(f"Expected resolution: {expected}")
print(f"Funniest punchline: {funniest[0]} (humor = {funniest[1]:.1f})")
print(f"Most boring punchline: {most_boring[0]} (humor = {most_boring[1]:.1f})")
print(f"Humor range: {funniest[1] - most_boring[1]:.1f}")
print()

# Demo 6: Surprise Cone
print("=" * 60)
print("Demo 6: Surprise Cone — Diameter Bound")
print("=" * 60)
print()

vertex = 5.0
legs = [3.0, 4.5, 6.0, 7.0, 2.0]
radius = max(distance(l, vertex) for l in legs)

print(f"Vertex: {vertex}")
print(f"Legs: {legs}")
print(f"Radius: {radius}")
print(f"Theoretical diameter bound: 2 * radius = {2 * radius}")
print()

max_leg_dist = 0.0
for i in range(len(legs)):
    for j in range(i+1, len(legs)):
        d = distance(legs[i], legs[j])
        print(f"  d(leg[{i}], leg[{j}]) = d({legs[i]}, {legs[j]}) = {d:.1f}")
        max_leg_dist = max(max_leg_dist, d)

print(f"\nMaximum pairwise distance: {max_leg_dist}")
print(f"Within 2r = {2*radius}: {max_leg_dist <= 2*radius + 1e-10}")


"""
Visualization: Contraction Fixed Point Convergence

Shows how iterating a contractive subversion map converges to the
self-referential fixed point — the "ultimate joke."
"""

import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Plot 1: Cobweb diagram for contraction convergence
    ax1 = axes[0]
    x = np.linspace(-1, 12, 200)
    f = lambda t: 0.5 * t + 1.0  # contraction with C=0.5, fixed point at 2

    ax1.plot(x, f(x), 'b-', linewidth=2, label='f(x) = 0.5x + 1')
    ax1.plot(x, x, 'k--', linewidth=1, label='y = x')

    # Cobweb from x0 = 10
    x0 = 10.0
    xn = x0
    for _ in range(12):
        xn1 = f(xn)
        ax1.plot([xn, xn], [xn, xn1], 'r-', linewidth=0.8, alpha=0.7)
        ax1.plot([xn, xn1], [xn1, xn1], 'r-', linewidth=0.8, alpha=0.7)
        xn = xn1

    ax1.plot(2, 2, 'go', markersize=10, zorder=5, label='Fixed point (2, 2)')
    ax1.plot(10, 0, 'rs', markersize=8, zorder=5, label='Start x₀ = 10')
    ax1.set_xlabel('x')
    ax1.set_ylabel('f(x)')
    ax1.set_title('Cobweb: Convergence to Fixed Point')
    ax1.legend(fontsize=8)
    ax1.set_xlim(-1, 12)
    ax1.set_ylim(-1, 12)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Distance to fixed point vs iteration
    ax2 = axes[1]
    x0_values = [10.0, 5.0, -3.0, 0.0]
    colors = ['red', 'blue', 'green', 'orange']
    C = 0.5
    fp = 2.0

    for x0, color in zip(x0_values, colors):
        distances = []
        bounds = []
        xn = x0
        d0 = abs(x0 - fp)
        for n in range(15):
            distances.append(abs(xn - fp))
            bounds.append(C**n * d0)
            xn = f(xn)

        ax2.semilogy(range(15), distances, 'o-', color=color, markersize=4,
                     label=f'x₀={x0}', linewidth=1.5)
        ax2.semilogy(range(15), bounds, '--', color=color, alpha=0.5, linewidth=1)

    ax2.set_xlabel('Iteration n')
    ax2.set_ylabel('Distance to fixed point (log scale)')
    ax2.set_title('Geometric Convergence: d(f^n(x₀), p)')
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)

    # Plot 3: Humor chain inequality visualization
    ax3 = axes[2]
    chain = np.array([0, 3, 1, 7, 2, 10])
    n = len(chain)

    # Plot the chain as a path
    for i in range(n - 1):
        ax3.plot([i, i+1], [chain[i], chain[i+1]], 'b-o', linewidth=2, markersize=8)
        mid_y = (chain[i] + chain[i+1]) / 2
        step_humor = abs(chain[i+1] - chain[i])
        ax3.annotate(f'd={step_humor}', (i + 0.5, mid_y), fontsize=8,
                    ha='center', color='blue')

    # End-to-end
    ax3.plot([0, n-1], [chain[0], chain[-1]], 'r--', linewidth=2, alpha=0.7)
    e2e = abs(chain[-1] - chain[0])
    total = sum(abs(chain[i+1] - chain[i]) for i in range(n-1))

    ax3.set_xlabel('Step')
    ax3.set_ylabel('Value')
    ax3.set_title(f'Chain Inequality: {e2e} ≤ {total}')
    ax3.annotate(f'End-to-end: {e2e}', (2, -0.5), fontsize=10, color='red',
                ha='center')
    ax3.annotate(f'Total: {total}', (2, -1.5), fontsize=10, color='blue',
                ha='center')
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('humor_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: humor_convergence.png")


if __name__ == "__main__":
    main()


"""
Visualization: Surprise Space and Humor Duality

Shows the geometry of surprise spaces — expected points, surprise radii,
and the duality between funniest and most boring jokes.
"""

import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Plot 1: 2D Surprise Space
    ax1 = axes[0]
    expected = np.array([3.0, 4.0])

    # Generate random punchlines
    np.random.seed(42)
    n_jokes = 50
    punchlines = np.random.randn(n_jokes, 2) * 3 + expected

    # Compute humor values
    humors = np.sqrt(np.sum((punchlines - expected)**2, axis=1))

    scatter = ax1.scatter(punchlines[:, 0], punchlines[:, 1], c=humors,
                         cmap='RdYlGn_r', s=50, alpha=0.8, edgecolors='gray',
                         linewidths=0.5)
    ax1.plot(*expected, 'k*', markersize=15, label='Expected', zorder=5)

    # Draw surprise radius circles
    for r in [2, 4, 6]:
        circle = plt.Circle(expected, r, fill=False, linestyle='--',
                           color='gray', alpha=0.5)
        ax1.add_patch(circle)
        ax1.text(expected[0] + r * 0.7, expected[1] + r * 0.7, f'r={r}',
                fontsize=8, color='gray')

    # Mark funniest and most boring
    idx_funny = np.argmax(humors)
    idx_boring = np.argmin(humors)

    ax1.plot(*punchlines[idx_funny], 'r^', markersize=12, label='Funniest',
            zorder=5)
    ax1.plot(*punchlines[idx_boring], 'bs', markersize=12, label='Most boring',
            zorder=5)

    ax1.set_xlabel('x')
    ax1.set_ylabel('y')
    ax1.set_title('2D Surprise Space')
    ax1.legend(fontsize=8)
    ax1.set_aspect('equal')
    ax1.grid(True, alpha=0.3)
    plt.colorbar(scatter, ax=ax1, label='Humor value')

    # Plot 2: Surprise Entropy vs Number of Punchlines
    ax2 = axes[1]
    max_n = 20
    expected_val = 0.0

    uniform_entropies = []
    concentrated_entropies = []
    ns = range(2, max_n + 1)

    for n in ns:
        punchlines_1d = np.linspace(-5, 5, n)

        # Uniform weights
        w_uniform = np.ones(n) / n
        ent_uniform = np.sum(w_uniform * np.abs(punchlines_1d - expected_val))
        uniform_entropies.append(ent_uniform)

        # Concentrated weights (most weight on closest)
        w_conc = np.exp(-np.abs(punchlines_1d - expected_val))
        w_conc /= w_conc.sum()
        ent_conc = np.sum(w_conc * np.abs(punchlines_1d - expected_val))
        concentrated_entropies.append(ent_conc)

    max_surprise = max(np.abs(np.linspace(-5, 5, max_n) - expected_val))

    ax2.plot(list(ns), uniform_entropies, 'b-o', markersize=4,
            label='Uniform weights')
    ax2.plot(list(ns), concentrated_entropies, 'r-s', markersize=4,
            label='Concentrated weights')
    ax2.axhline(y=max_surprise, color='k', linestyle='--', alpha=0.5,
               label=f'Max surprise = {max_surprise}')
    ax2.set_xlabel('Number of punchlines')
    ax2.set_ylabel('Surprise entropy')
    ax2.set_title('Entropy Bound: H ≤ max surprise')
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)

    # Plot 3: Surprise Cone Diameter Bound
    ax3 = axes[2]
    vertex = np.array([0, 0])
    n_legs = 8
    radii = [1, 2, 3, 4]
    colors_r = ['#2ecc71', '#3498db', '#e74c3c', '#9b59b6']

    for radius, color in zip(radii, colors_r):
        angles = np.linspace(0, 2 * np.pi, n_legs, endpoint=False)
        legs = radius * np.column_stack([np.cos(angles), np.sin(angles)])

        # Compute max pairwise distance
        max_pair = 0
        for i in range(n_legs):
            for j in range(i + 1, n_legs):
                d = np.sqrt(np.sum((legs[i] - legs[j])**2))
                max_pair = max(max_pair, d)

        ax3.scatter(legs[:, 0], legs[:, 1], c=color, s=30, alpha=0.7,
                   label=f'r={radius}, max_d={max_pair:.1f}≤{2*radius}')

        circle = plt.Circle(vertex, radius, fill=False, linestyle='-',
                           color=color, alpha=0.5)
        ax3.add_patch(circle)

    ax3.plot(0, 0, 'k*', markersize=12, zorder=5)
    ax3.set_xlabel('x')
    ax3.set_ylabel('y')
    ax3.set_title('Surprise Cone: d(leg_i, leg_j) ≤ 2r')
    ax3.legend(fontsize=7, loc='upper right')
    ax3.set_aspect('equal')
    ax3.set_xlim(-5, 5)
    ax3.set_ylim(-5, 5)
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('surprise_space.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: surprise_space.png")


if __name__ == "__main__":
    main()
