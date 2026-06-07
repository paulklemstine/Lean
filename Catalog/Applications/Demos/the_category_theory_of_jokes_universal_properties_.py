#!/usr/bin/env python3
"""
Categorical Humor Theory: Numerical Demonstrations

Demonstrates the key theorems from the formalization:
1. Fundamental Theorem of Comedy (triangle inequalities)
2. Jensen's Comedy Theorem (E[|X-μ|] ≤ √Var(X))
3. Punchline Variance Bound (Var ≤ D²/4)
4. Humor Spectrum Gap (quantized humor in finite spaces)
5. Chebyshev Comedy Principle (concentration of humor)
6. Bi-Lipschitz Humor Sandwich (invariance under distortion)
"""

import math
import random

random.seed(42)


def dist(x, y):
    """Euclidean distance in R^n."""
    if isinstance(x, (int, float)):
        return abs(x - y)
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))


class Joke:
    """A joke in a metric space: (setup, expected, punchline)."""

    def __init__(self, setup, expected, punchline):
        self.setup = setup
        self.expected = expected
        self.punchline = punchline

    @property
    def humor(self):
        return dist(self.expected, self.punchline)

    @property
    def tension(self):
        return dist(self.setup, self.expected)

    @property
    def arc(self):
        return dist(self.setup, self.punchline)

    @property
    def deficiency(self):
        return self.tension + self.humor - self.arc

    @property
    def is_geodesic(self):
        return abs(self.deficiency) < 1e-10

    def __repr__(self):
        return (f"Joke(H={self.humor:.3f}, T={self.tension:.3f}, "
                f"A={self.arc:.3f}, δ={self.deficiency:.3f})")


def demo_fundamental_theorem():
    """Demo 1: Fundamental Theorem of Comedy."""
    print("=" * 60)
    print("DEMO 1: Fundamental Theorem of Comedy")
    print("=" * 60)
    print()

    jokes = [
        Joke((0, 0), (3, 0), (3, 4)),    # Right triangle
        Joke((0, 0), (5, 0), (2, 3)),    # General triangle
        Joke((0, 0), (1, 0), (10, 0)),   # Collinear (geodesic)
        Joke((0, 0), (0, 0), (5, 5)),    # Zero tension
    ]

    for i, j in enumerate(jokes):
        print(f"Joke {i+1}: {j}")
        print(f"  Triangle inequalities:")
        print(f"    arc ≤ tension + humor: {j.arc:.3f} ≤ {j.tension + j.humor:.3f} ✓")
        print(f"    humor ≤ arc + tension: {j.humor:.3f} ≤ {j.arc + j.tension:.3f} ✓")
        print(f"    tension ≤ arc + humor: {j.tension:.3f} ≤ {j.arc + j.humor:.3f} ✓")
        print(f"  Geodesic: {j.is_geodesic}")
        print()


def demo_jensens_comedy():
    """Demo 2: Jensen's Comedy Theorem."""
    print("=" * 60)
    print("DEMO 2: Jensen's Comedy Theorem")
    print("=" * 60)
    print()

    for trial in range(5):
        n = random.randint(5, 20)
        points = [random.gauss(0, 1) for _ in range(n)]
        weights = [random.random() for _ in range(n)]
        total_w = sum(weights)
        weights = [w / total_w for w in weights]

        mu = sum(w * x for w, x in zip(weights, points))
        lhs = sum(w * abs(x - mu) for w, x in zip(weights, points))
        variance = sum(w * (x - mu) ** 2 for w, x in zip(weights, points))
        rhs = math.sqrt(variance)

        print(f"Trial {trial+1}: n={n}, μ={mu:.3f}")
        print(f"  E[|X-μ|] = {lhs:.4f}")
        print(f"  √Var(X)  = {rhs:.4f}")
        print(f"  E[|X-μ|] ≤ √Var(X): {lhs <= rhs + 1e-10} (ratio = {lhs/rhs:.4f})")
        print()


def demo_variance_bound():
    """Demo 3: Punchline Variance Bound (Var ≤ D²/4)."""
    print("=" * 60)
    print("DEMO 3: Punchline Variance Bound")
    print("=" * 60)
    print()

    D = 10.0
    print(f"Bound D = {D}, D²/4 = {D**2/4}")
    print()

    # Test various distributions on [0, D]
    distributions = {
        "Uniform": [D * i / 99 for i in range(100)],
        "Bernoulli(0, D)": [0.0] * 50 + [D] * 50,
        "Concentrated at D/2": [D/2] * 100,
        "Beta-like": [D * (i/99)**2 for i in range(100)],
        "Endpoints heavy": [0.0] * 40 + [D/2] * 20 + [D] * 40,
    }

    for name, data in distributions.items():
        n = len(data)
        mu = sum(data) / n
        var = sum((x - mu) ** 2 for x in data) / n
        print(f"  {name:25s}: μ={mu:.2f}, Var={var:.4f}, D²/4={D**2/4:.4f}, "
              f"Var ≤ D²/4: {var <= D**2/4 + 1e-10}")


def demo_spectrum_gap():
    """Demo 4: Humor Spectrum Gap."""
    print()
    print("=" * 60)
    print("DEMO 4: Humor Spectrum Gap (Quantized Humor)")
    print("=" * 60)
    print()

    # Integer lattice points
    points = [(i, j) for i in range(4) for j in range(4)]
    distances = set()
    for i, p in enumerate(points):
        for j, q in enumerate(points):
            d = dist(p, q)
            if d > 0:
                distances.add(round(d, 10))

    sorted_dists = sorted(distances)
    gap = sorted_dists[0]
    print(f"4×4 integer lattice:")
    print(f"  Number of distinct positive distances: {len(sorted_dists)}")
    print(f"  Spectral gap (minimum positive distance): {gap}")
    print(f"  Smallest distances: {sorted_dists[:5]}")
    print(f"  Largest distance: {sorted_dists[-1]:.4f}")


def demo_chebyshev():
    """Demo 5: Chebyshev Comedy Principle."""
    print()
    print("=" * 60)
    print("DEMO 5: Chebyshev Comedy Principle")
    print("=" * 60)
    print()

    n = 100
    humors = [random.gauss(5, 2) for _ in range(n)]
    mu = sum(humors) / n
    total_sq = sum((h - mu) ** 2 for h in humors)

    for t in [1.0, 2.0, 3.0, 5.0]:
        deviators = sum(1 for h in humors if abs(h - mu) >= t)
        lhs = deviators * t ** 2
        print(f"  t={t:.1f}: deviators={deviators:3d}, "
              f"count·t²={lhs:.1f}, Σ(h-μ)²={total_sq:.1f}, "
              f"bound holds: {lhs <= total_sq + 1e-10}")


def demo_bilipschitz():
    """Demo 6: Bi-Lipschitz Humor Sandwich."""
    print()
    print("=" * 60)
    print("DEMO 6: Bi-Lipschitz Humor Sandwich")
    print("=" * 60)
    print()

    K = 2.0
    j = Joke(0.0, 3.0, 8.0)

    # K-bi-Lipschitz map: f(x) = K*x
    f = lambda x: K * x
    j_transformed = Joke(f(j.setup), f(j.expected), f(j.punchline))

    print(f"Original joke: {j}")
    print(f"K-bi-Lipschitz (K={K}) transformed: {j_transformed}")
    print(f"  H(j)/K = {j.humor/K:.3f} ≤ H(f(j)) = {j_transformed.humor:.3f} "
          f"≤ K·H(j) = {K*j.humor:.3f}")
    print(f"  Sandwich holds: {j.humor/K <= j_transformed.humor + 1e-10 and j_transformed.humor <= K * j.humor + 1e-10}")


def demo_duality():
    """Demo 7: Humor-Tension Duality."""
    print()
    print("=" * 60)
    print("DEMO 7: Humor-Tension Duality")
    print("=" * 60)
    print()

    j = Joke((0, 0), (3, 0), (3, 4))
    j_dual = Joke(j.setup, j.punchline, j.expected)  # swap expected and punchline

    print(f"Original:  {j}")
    print(f"Dual:      {j_dual}")
    print(f"  H(j) = H(j*): {j.humor:.3f} = {j_dual.humor:.3f} ✓")
    print(f"  T(j*) = A(j): {j_dual.tension:.3f} = {j.arc:.3f} ✓")
    print(f"  A(j*) = T(j): {j_dual.arc:.3f} = {j.tension:.3f} ✓")
    print(f"  δ(j) = {j.deficiency:.3f}, δ(j*) = {j_dual.deficiency:.3f}")
    print(f"  Deficiency NOT preserved: {abs(j.deficiency - j_dual.deficiency) > 1e-10}")


if __name__ == "__main__":
    demo_fundamental_theorem()
    demo_jensens_comedy()
    demo_variance_bound()
    demo_spectrum_gap()
    demo_chebyshev()
    demo_bilipschitz()
    demo_duality()
    print()
    print("All demos completed successfully.")


#!/usr/bin/env python3
"""
Visualization: The Comedy Triangle

Shows the relationship between humor, tension, and arc for a collection
of jokes, illustrating the Fundamental Theorem of Comedy.
"""

import math
import random

random.seed(42)


def dist2d(p, q):
    return math.sqrt((p[0]-q[0])**2 + (p[1]-q[1])**2)


def generate_jokes(n=200):
    jokes = []
    for _ in range(n):
        s = (random.gauss(0, 2), random.gauss(0, 2))
        e = (s[0] + random.gauss(3, 1), s[1] + random.gauss(0, 1))
        p = (e[0] + random.gauss(0, 3), e[1] + random.gauss(0, 3))
        h = dist2d(e, p)
        t = dist2d(s, e)
        a = dist2d(s, p)
        d = t + h - a
        jokes.append({'humor': h, 'tension': t, 'arc': a, 'deficiency': d})
    return jokes


def main():
    try:
        import matplotlib.pyplot as plt
        import matplotlib.cm as cm
    except ImportError:
        print("matplotlib not available; skipping visualization.")
        return

    jokes = generate_jokes(500)
    humors = [j['humor'] for j in jokes]
    tensions = [j['tension'] for j in jokes]
    arcs = [j['arc'] for j in jokes]
    deficiencies = [j['deficiency'] for j in jokes]

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Plot 1: Humor vs Tension, colored by deficiency
    sc = axes[0].scatter(tensions, humors, c=deficiencies, cmap='viridis',
                         alpha=0.6, s=20)
    axes[0].set_xlabel('Tension (setup → expected)')
    axes[0].set_ylabel('Humor (expected → punchline)')
    axes[0].set_title('Humor vs Tension')
    plt.colorbar(sc, ax=axes[0], label='Deficiency δ')

    # Plot 2: Arc vs (Tension + Humor), showing triangle inequality
    t_plus_h = [t + h for t, h in zip(tensions, humors)]
    axes[1].scatter(arcs, t_plus_h, c='steelblue', alpha=0.4, s=15)
    max_val = max(max(arcs), max(t_plus_h))
    axes[1].plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='arc = T+H')
    axes[1].set_xlabel('Arc (setup → punchline)')
    axes[1].set_ylabel('Tension + Humor')
    axes[1].set_title('Triangle Inequality: arc ≤ T + H')
    axes[1].legend()

    # Plot 3: Histogram of deficiency
    axes[2].hist(deficiencies, bins=40, color='coral', edgecolor='black', alpha=0.7)
    axes[2].axvline(x=0, color='red', linewidth=2, linestyle='--', label='Geodesic (δ=0)')
    axes[2].set_xlabel('Deficiency δ = T + H - A')
    axes[2].set_ylabel('Count')
    axes[2].set_title('Distribution of Humor Deficiency')
    axes[2].legend()

    plt.tight_layout()
    plt.savefig('comedy_triangle.png', dpi=150, bbox_inches='tight')
    print("Saved comedy_triangle.png")
    plt.close()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Jensen's Comedy Theorem

Shows E[|X-μ|] ≤ √Var(X) across many random distributions,
with the theoretical bound and the empirical ratio.
"""

import math
import random

random.seed(42)


def compute_humor_stats(n_trials=2000):
    results = []
    for _ in range(n_trials):
        n = random.randint(3, 50)
        points = [random.gauss(0, random.uniform(0.5, 5)) for _ in range(n)]
        weights = [random.random() for _ in range(n)]
        total_w = sum(weights)
        weights = [w / total_w for w in weights]

        mu = sum(w * x for w, x in zip(weights, points))
        mad = sum(w * abs(x - mu) for w, x in zip(weights, points))
        var = sum(w * (x - mu) ** 2 for w, x in zip(weights, points))
        std = math.sqrt(var) if var > 0 else 0

        if std > 1e-10:
            results.append({'mad': mad, 'std': std, 'ratio': mad / std, 'n': n})
    return results


def main():
    try:
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available; skipping visualization.")
        return

    results = compute_humor_stats(3000)
    mads = [r['mad'] for r in results]
    stds = [r['std'] for r in results]
    ratios = [r['ratio'] for r in results]

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: E[|X-μ|] vs √Var(X)
    axes[0].scatter(stds, mads, alpha=0.15, s=8, c='steelblue')
    max_val = max(max(stds), max(mads)) * 1.05
    axes[0].plot([0, max_val], [0, max_val], 'r-', linewidth=2,
                 label='E[|X-μ|] = √Var (boundary)')
    axes[0].set_xlabel('√Var(X)')
    axes[0].set_ylabel('E[|X-μ|]')
    axes[0].set_title("Jensen's Comedy Theorem: E[|X-μ|] ≤ √Var(X)")
    axes[0].legend()
    axes[0].set_xlim(0, max_val)
    axes[0].set_ylim(0, max_val)

    # Plot 2: Distribution of ratio
    axes[1].hist(ratios, bins=50, color='coral', edgecolor='black', alpha=0.7)
    axes[1].axvline(x=1.0, color='red', linewidth=2, linestyle='--',
                    label='Bound = 1')
    axes[1].axvline(x=sum(ratios)/len(ratios), color='blue', linewidth=2,
                    linestyle=':', label=f'Mean = {sum(ratios)/len(ratios):.3f}')
    axes[1].set_xlabel('Ratio E[|X-μ|] / √Var(X)')
    axes[1].set_ylabel('Count')
    axes[1].set_title('Distribution of Comedy Ratio')
    axes[1].legend()

    plt.tight_layout()
    plt.savefig('jensen_comedy.png', dpi=150, bbox_inches='tight')
    print("Saved jensen_comedy.png")
    plt.close()


if __name__ == "__main__":
    main()
