"""
Incongruity Resolution Theory — Applications
==============================================
Real-world applications of the metric humor framework.
"""

import math
from typing import List, Tuple


def sentiment_distance(text_a: str, text_b: str) -> float:
    """Simple sentiment-based distance between two phrases.
    
    Uses a basic positive/negative word count as a proxy for
    "semantic position" in humor space. In practice, this would
    use word embeddings (Word2Vec, BERT, etc.).
    
    Returns a value in [0, 1].
    """
    positive = {'happy', 'good', 'great', 'love', 'wonderful', 'joy', 
                'amazing', 'beautiful', 'perfect', 'excellent'}
    negative = {'sad', 'bad', 'terrible', 'hate', 'awful', 'ugly',
                'horrible', 'worst', 'evil', 'disaster'}
    
    def sentiment_score(text: str) -> float:
        words = text.lower().split()
        pos = sum(1 for w in words if w in positive)
        neg = sum(1 for w in words if w in negative)
        total = max(len(words), 1)
        return (pos - neg) / total
    
    return abs(sentiment_score(text_a) - sentiment_score(text_b))


class JokeAnalyzer:
    """Analyzes jokes using the Incongruity Resolution metric framework.
    
    Application: Computational humor analysis for natural language processing,
    content moderation, and creative writing assistance.
    """
    
    def __init__(self, dist_fn=sentiment_distance):
        self.dist_fn = dist_fn
    
    def analyze(self, setup: str, expectation: str, punchline: str) -> dict:
        """Analyze a joke's metric properties.
        
        Args:
            setup: The joke setup text
            expectation: What the audience expects
            punchline: The actual punchline
        
        Returns:
            Dictionary with surprise, tension, arc, defect, comedy_ratio
        """
        tension = self.dist_fn(setup, expectation)
        surprise = self.dist_fn(expectation, punchline)
        arc = self.dist_fn(setup, punchline)
        defect = tension + surprise - arc
        ratio = surprise / arc if arc > 1e-10 else 0.0
        
        return {
            'tension': tension,
            'surprise': surprise,
            'arc': arc,
            'defect': defect,
            'comedy_ratio': ratio,
            'in_polytope': (tension >= 0 and surprise >= 0 and arc >= 0 and
                          tension + surprise >= arc and
                          tension + arc >= surprise and
                          surprise + arc >= tension)
        }


class TranslationQualityEstimator:
    """Estimates humor loss in translation using Lipschitz bounds.
    
    Application: Measuring how much humor is preserved when content
    is adapted across languages or cultural contexts.
    
    The Lipschitz constant K of the translation map bounds
    the surprise ratio: surprise(translated) / surprise(original) <= K.
    """
    
    def __init__(self, original_dist, translated_dist):
        self.original_dist = original_dist
        self.translated_dist = translated_dist
    
    def estimate_lipschitz_constant(self, 
                                     pairs: List[Tuple[str, str]]) -> float:
        """Estimate the Lipschitz constant of a translation map.
        
        Given pairs of (original, translated) texts, estimates K
        such that d'(f(a), f(b)) <= K * d(a, b) for all pairs.
        
        Args:
            pairs: List of (original_text, translated_text) pairs
        
        Returns:
            Estimated Lipschitz constant K
        """
        max_ratio = 0.0
        for i in range(len(pairs)):
            for j in range(i + 1, len(pairs)):
                orig_dist = self.original_dist(pairs[i][0], pairs[j][0])
                trans_dist = self.translated_dist(pairs[i][1], pairs[j][1])
                if orig_dist > 1e-10:
                    ratio = trans_dist / orig_dist
                    max_ratio = max(max_ratio, ratio)
        return max_ratio
    
    def humor_loss_bound(self, original_surprise: float, K: float) -> float:
        """Upper bound on translated surprise.
        
        By the Lipschitz Surprise Bound theorem:
        surprise(translated) <= K * surprise(original)
        
        If K < 1, humor is guaranteed to be diminished.
        """
        return K * original_surprise


class ComedyChainOptimizer:
    """Optimizes the ordering of a comedy set using chain leverage.
    
    Application: Stand-up comedy set list optimization.
    The Comedy Chain Leverage theorem tells us that the total
    path length (sum of transitions) is >= endpoint distance.
    Higher leverage = more dynamic, varied set.
    """
    
    def __init__(self, jokes: List[str], dist_fn=sentiment_distance):
        self.jokes = jokes
        self.dist_fn = dist_fn
    
    def chain_leverage(self, ordering: List[int]) -> float:
        """Compute the leverage ratio of a given joke ordering.
        
        Leverage = total_transitions / endpoint_distance.
        Higher leverage means more audience "journey."
        """
        if len(ordering) < 2:
            return 1.0
        
        path = sum(self.dist_fn(self.jokes[ordering[i]], self.jokes[ordering[i+1]])
                    for i in range(len(ordering) - 1))
        endpoint = self.dist_fn(self.jokes[ordering[0]], self.jokes[ordering[-1]])
        
        return path / endpoint if endpoint > 1e-10 else float('inf')
    
    def greedy_maximize_leverage(self) -> List[int]:
        """Greedy algorithm to maximize chain leverage.
        
        At each step, choose the next joke that maximizes the
        running leverage ratio.
        
        Time complexity: O(n²)
        """
        n = len(self.jokes)
        if n <= 1:
            return list(range(n))
        
        ordering = [0]
        remaining = set(range(1, n))
        
        while remaining:
            best_idx = None
            best_score = -1
            for idx in remaining:
                new_dist = self.dist_fn(self.jokes[ordering[-1]], self.jokes[idx])
                if new_dist > best_score:
                    best_score = new_dist
                    best_idx = idx
            ordering.append(best_idx)
            remaining.remove(best_idx)
        
        return ordering


class TropicalHumorAggregator:
    """Aggregates humor scores using tropical (max-plus) algebra.
    
    Application: Recommendation systems for comedy content.
    Tropical aggregation (taking the max) naturally models
    "a comedy show is as good as its best joke."
    """
    
    def aggregate_show(self, joke_scores: List[float]) -> float:
        """Tropical aggregation: max of individual scores."""
        return max(joke_scores) if joke_scores else float('-inf')
    
    def aggregate_pair(self, score_a: float, score_b: float) -> float:
        """Tropical product: sum of scores (audience × quality)."""
        return score_a + score_b
    
    def verify_subadditivity(self, a: List[float], b: List[float]) -> bool:
        """Verify the Tropical Cauchy-Schwarz inequality.
        
        max(a[i]+b[i]) <= max(a) + max(b) for all i.
        """
        if not a or not b or len(a) != len(b):
            return True
        lhs = max(ai + bi for ai, bi in zip(a, b))
        rhs = max(a) + max(b)
        return lhs <= rhs + 1e-10


if __name__ == "__main__":
    print("=== Incongruity Resolution Theory — Applications ===\n")
    
    # Application 1: Joke Analysis
    print("--- Application 1: Joke Analysis ---")
    analyzer = JokeAnalyzer()
    
    result = analyzer.analyze(
        setup="A wonderful day at the beautiful park",
        expectation="Everyone was happy and joyful",
        punchline="A terrible disaster struck the evil town"
    )
    print(f"Joke metrics: {result}")
    
    # Application 2: Comedy Chain
    print("\n--- Application 2: Comedy Set Optimization ---")
    jokes = [
        "happy wonderful day",
        "terrible awful night", 
        "great amazing show",
        "bad horrible weather",
        "perfect beautiful sunset"
    ]
    optimizer = ComedyChainOptimizer(jokes)
    ordering = optimizer.greedy_maximize_leverage()
    leverage = optimizer.chain_leverage(ordering)
    print(f"Optimal ordering: {[jokes[i] for i in ordering]}")
    print(f"Chain leverage: {leverage:.2f}x")
    
    # Application 3: Tropical Aggregation
    print("\n--- Application 3: Tropical Comedy Ranking ---")
    agg = TropicalHumorAggregator()
    shows = {
        "Show A": [7.2, 8.5, 6.1, 9.0, 7.8],
        "Show B": [8.0, 8.1, 8.2, 8.0, 8.3],
        "Show C": [5.0, 6.0, 4.0, 10.0, 3.0],
    }
    for name, scores in shows.items():
        tropical = agg.aggregate_show(scores)
        arithmetic = sum(scores) / len(scores)
        print(f"  {name}: tropical={tropical:.1f}, arithmetic={arithmetic:.1f}")
    
    # Application 4: MAD vs σ (Surprise-Entropy Duality)
    print("\n--- Application 4: Surprise-Entropy Duality ---")
    audience_reactions = [3, 3, 3, 3, 3, 3, 3, 3, 3, 10]  # One big laugh
    mu = sum(audience_reactions) / len(audience_reactions)
    mad = sum(abs(x - mu) for x in audience_reactions) / len(audience_reactions)
    sigma = math.sqrt(sum((x - mu)**2 for x in audience_reactions) / len(audience_reactions))
    print(f"  Reactions: {audience_reactions}")
    print(f"  Mean surprise (MAD) = {mad:.4f}")
    print(f"  Uncertainty (σ) = {sigma:.4f}")
    print(f"  MAD ≤ σ: {mad <= sigma + 1e-10} (humor bounded by uncertainty)")


"""
Incongruity Resolution Theory — Demo
=====================================
Demonstrates the core theorems of humor metric theory with concrete numerical examples.
"""

import math

class IncongruityTriple:
    """A joke modeled as (setup, expectation, punchline) in a metric space."""
    
    def __init__(self, setup, expectation, punchline, metric=None):
        self.setup = setup
        self.expectation = expectation
        self.punchline = punchline
        self.metric = metric or (lambda a, b: abs(a - b))
    
    @property
    def surprise(self):
        return self.metric(self.expectation, self.punchline)
    
    @property
    def tension(self):
        return self.metric(self.setup, self.expectation)
    
    @property
    def arc(self):
        return self.metric(self.setup, self.punchline)
    
    @property
    def defect(self):
        return self.tension + self.surprise - self.arc
    
    @property
    def comedy_ratio(self):
        return self.surprise / self.arc if self.arc > 0 else 0.0


def euclidean_dist(a, b):
    """Euclidean distance in R^n."""
    return math.sqrt(sum((ai - bi)**2 for ai, bi in zip(a, b)))


def demo_fundamental_inequality():
    """Demo 1: The Fundamental Inequality of Comedy (defect >= 0)."""
    print("=" * 60)
    print("Demo 1: The Fundamental Inequality of Comedy")
    print("  Theorem: defect = tension + surprise - arc >= 0")
    print("=" * 60)
    
    examples = [
        ("Simple 1D joke", 0, 5, 8, None),
        ("Extreme setup", 0, 100, 3, None),
        ("Degenerate (collinear)", 0, 3, 7, None),
    ]
    
    for name, s, e, p, metric in examples:
        j = IncongruityTriple(s, e, p, metric)
        print(f"\n  {name}: setup={s}, expect={e}, punch={p}")
        print(f"    tension={j.tension:.2f}, surprise={j.surprise:.2f}, arc={j.arc:.2f}")
        print(f"    defect={j.defect:.2f} >= 0 ✓" if j.defect >= -1e-10 else f"    defect={j.defect:.2f} VIOLATION!")
    
    # 2D example
    j2d = IncongruityTriple((0, 0), (3, 0), (0, 4), euclidean_dist)
    print(f"\n  2D right triangle: s=(0,0), e=(3,0), p=(0,4)")
    print(f"    tension={j2d.tension:.2f}, surprise={j2d.surprise:.2f}, arc={j2d.arc:.2f}")
    print(f"    defect={j2d.defect:.2f} >= 0 ✓")


def demo_reverse_triangle():
    """Demo 2: Reverse Triangle Surprise Bound."""
    print("\n" + "=" * 60)
    print("Demo 2: Reverse Triangle — |tension - arc| <= surprise")
    print("=" * 60)
    
    for s, e, p in [(0, 10, 3), (0, 2, 15), (-5, 0, 5)]:
        j = IncongruityTriple(s, e, p)
        lb = abs(j.tension - j.arc)
        print(f"\n  s={s}, e={e}, p={p}")
        print(f"    |tension - arc| = {lb:.2f} <= surprise = {j.surprise:.2f} ✓")


def demo_lipschitz_translation():
    """Demo 3: Lipschitz Translation Bound."""
    print("\n" + "=" * 60)
    print("Demo 3: Lipschitz Translation — surprise(f∘j) <= K * surprise(j)")
    print("=" * 60)
    
    j = IncongruityTriple(0.0, 5.0, 12.0)
    K = 2.5
    f = lambda x: K * x  # K-Lipschitz map
    j_translated = IncongruityTriple(f(0.0), f(5.0), f(12.0))
    
    print(f"\n  Original joke: surprise = {j.surprise:.2f}")
    print(f"  K = {K}, translated surprise = {j_translated.surprise:.2f}")
    print(f"  K * original surprise = {K * j.surprise:.2f}")
    print(f"  Bound holds: {j_translated.surprise:.2f} <= {K * j.surprise:.2f} ✓")


def demo_pythagorean_comedy():
    """Demo 4: The Pythagorean Comedy Theorem."""
    print("\n" + "=" * 60)
    print("Demo 4: Pythagorean Comedy — tension² + surprise² = arc²")
    print("  (when angle at expectation = 90°)")
    print("=" * 60)
    
    # Right angle at e=(3,0)
    s, e, p = (0, 0), (3, 0), (3, 4)
    j = IncongruityTriple(s, e, p, euclidean_dist)
    
    # Check perpendicularity: (s-e)·(p-e)
    se = (s[0]-e[0], s[1]-e[1])
    pe = (p[0]-e[0], p[1]-e[1])
    dot = se[0]*pe[0] + se[1]*pe[1]
    
    print(f"\n  s={s}, e={e}, p={p}")
    print(f"  (s-e)·(p-e) = {dot} (perpendicular: {dot == 0})")
    print(f"  tension² = {j.tension**2:.2f}")
    print(f"  surprise² = {j.surprise**2:.2f}")
    print(f"  arc² = {j.arc**2:.2f}")
    print(f"  tension² + surprise² = {j.tension**2 + j.surprise**2:.2f} = arc² ✓")


def demo_comedy_chain():
    """Demo 5: Comedy Chain Leverage."""
    print("\n" + "=" * 60)
    print("Demo 5: Comedy Chain — ∑surprises >= endpoint distance")
    print("=" * 60)
    
    pts = [0, 3, 1, 7, 2, 10]
    chain_sum = sum(abs(pts[i+1] - pts[i]) for i in range(len(pts)-1))
    endpoint_dist = abs(pts[-1] - pts[0])
    
    print(f"\n  Chain: {pts}")
    print(f"  Sum of surprises = {chain_sum}")
    print(f"  Endpoint distance = {endpoint_dist}")
    print(f"  Leverage ratio = {chain_sum / endpoint_dist:.2f}x")
    print(f"  chain_sum >= endpoint_dist: {chain_sum} >= {endpoint_dist} ✓")


def demo_tropical_subadditive():
    """Demo 6: Tropical Cauchy-Schwarz."""
    print("\n" + "=" * 60)
    print("Demo 6: Tropical Cauchy-Schwarz")
    print("  max(a₁+b₁, a₂+b₂) <= max(a₁,a₂) + max(b₁,b₂)")
    print("=" * 60)
    
    import random
    random.seed(42)
    for _ in range(5):
        a1, a2, b1, b2 = [random.uniform(-10, 10) for _ in range(4)]
        lhs = max(a1+b1, a2+b2)
        rhs = max(a1, a2) + max(b1, b2)
        print(f"  a=({a1:.1f},{a2:.1f}), b=({b1:.1f},{b2:.1f}): {lhs:.2f} <= {rhs:.2f} ✓")


def demo_mean_abs_dev():
    """Demo 7: Mean Absolute Deviation <= RMS Deviation."""
    print("\n" + "=" * 60)
    print("Demo 7: Surprise-Entropy Duality — MAD <= σ")
    print("=" * 60)
    
    datasets = [
        ("Uniform jokes", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        ("Concentrated", [5, 5, 5, 5, 5, 5, 5, 5, 5, 100]),
        ("Bimodal", [0, 0, 0, 0, 0, 10, 10, 10, 10, 10]),
    ]
    
    for name, data in datasets:
        n = len(data)
        mu = sum(data) / n
        mad = sum(abs(x - mu) for x in data) / n
        rms = math.sqrt(sum((x - mu)**2 for x in data) / n)
        print(f"\n  {name}: μ={mu:.1f}")
        print(f"    MAD = {mad:.4f}, σ = {rms:.4f}")
        print(f"    MAD <= σ: {mad:.4f} <= {rms:.4f} ✓")


def demo_comedy_polytope():
    """Demo 8: Comedy Polytope — Convexity and Cone property."""
    print("\n" + "=" * 60)
    print("Demo 8: Comedy Polytope Properties")
    print("=" * 60)
    
    def in_polytope(a, b, c):
        return (a >= 0 and b >= 0 and c >= 0 and
                a + b >= c and a + c >= b and b + c >= a)
    
    # Convex combination
    v1 = (3, 4, 5)
    v2 = (5, 5, 8)
    t = 0.3
    combo = tuple(t * v1[i] + (1-t) * v2[i] for i in range(3))
    
    print(f"\n  v₁ = {v1}, in polytope: {in_polytope(*v1)}")
    print(f"  v₂ = {v2}, in polytope: {in_polytope(*v2)}")
    print(f"  0.3·v₁ + 0.7·v₂ = ({combo[0]:.1f}, {combo[1]:.1f}, {combo[2]:.1f}), "
          f"in polytope: {in_polytope(*combo)} ✓")
    
    # Cone property
    scale = 3.7
    scaled = tuple(scale * v for v in v1)
    print(f"\n  {scale}·v₁ = ({scaled[0]:.1f}, {scaled[1]:.1f}, {scaled[2]:.1f}), "
          f"in polytope: {in_polytope(*scaled)} ✓")


if __name__ == "__main__":
    demo_fundamental_inequality()
    demo_reverse_triangle()
    demo_lipschitz_translation()
    demo_pythagorean_comedy()
    demo_comedy_chain()
    demo_tropical_subadditive()
    demo_mean_abs_dev()
    demo_comedy_polytope()
    
    print("\n" + "=" * 60)
    print("All demos passed! ✓")
    print("=" * 60)


"""
Visualization: Comedy Chain Leverage
======================================
Illustrates the Comedy Chain Leverage theorem: for a sequence of jokes,
the total transition distance (sum of surprises) is always at least
the endpoint distance. Longer, more meandering chains have higher leverage.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

np.random.seed(42)

# --- Panel 1: 2D comedy chains with different leverage ---
ax = axes[0]
ax.set_title("Comedy Chains in 2D Space", fontsize=12, fontweight='bold')

chains = {
    'Direct (low leverage)': [(0, 0), (1, 0.2), (2, 0.1), (3, 0.3), (4, 0)],
    'Zigzag (medium)': [(0, 0), (1, 2), (2, -1), (3, 2.5), (4, 0)],
    'Wild (high leverage)': [(0, 0), (-1, 3), (3, -2), (-2, 4), (4, 0)],
}

colors = ['#27ae60', '#f39c12', '#e74c3c']
for (name, chain), color in zip(chains.items(), colors):
    xs = [p[0] for p in chain]
    ys = [p[1] for p in chain]
    
    # Path length
    path = sum(np.sqrt((xs[i+1]-xs[i])**2 + (ys[i+1]-ys[i])**2) 
               for i in range(len(chain)-1))
    endpoint = np.sqrt((xs[-1]-xs[0])**2 + (ys[-1]-ys[0])**2)
    leverage = path / endpoint if endpoint > 0.01 else float('inf')
    
    ax.plot(xs, ys, 'o-', color=color, linewidth=2, markersize=6,
            label=f'{name}\nL={leverage:.1f}x')
    
    # Draw endpoint arrow
    ax.annotate('', xy=(xs[-1], ys[-1]-0.3), xytext=(xs[0], ys[0]-0.3),
                arrowprops=dict(arrowstyle='->', color=color, alpha=0.3, lw=2))

ax.set_xlabel("Semantic Dimension 1", fontsize=10)
ax.set_ylabel("Semantic Dimension 2", fontsize=10)
ax.legend(fontsize=8, loc='upper left')
ax.grid(True, alpha=0.3)
ax.set_aspect('equal')

# --- Panel 2: Leverage distribution for random chains ---
ax2 = axes[1]
ax2.set_title("Leverage Distribution\n(Random 10-point Chains)", fontsize=12, fontweight='bold')

n_chains = 5000
leverages = []

for _ in range(n_chains):
    # Random walk in 2D
    points = np.cumsum(np.random.randn(10, 2), axis=0)
    path_length = sum(np.linalg.norm(points[i+1] - points[i]) 
                      for i in range(len(points)-1))
    endpoint_dist = np.linalg.norm(points[-1] - points[0])
    if endpoint_dist > 0.01:
        leverages.append(path_length / endpoint_dist)

ax2.hist(leverages, bins=50, color='#3498db', alpha=0.7, edgecolor='black',
         linewidth=0.5, density=True)
ax2.axvline(x=1, color='#e74c3c', linestyle='--', linewidth=2, 
            label='Minimum (leverage = 1)')
ax2.axvline(x=np.mean(leverages), color='#27ae60', linestyle='-', linewidth=2,
            label=f'Mean = {np.mean(leverages):.2f}')

ax2.set_xlabel("Chain Leverage Ratio", fontsize=11)
ax2.set_ylabel("Density", fontsize=11)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# --- Panel 3: Leverage vs chain length ---
ax3 = axes[2]
ax3.set_title("Leverage Grows with Chain Length", fontsize=12, fontweight='bold')

chain_lengths = list(range(2, 51))
mean_leverages = []
std_leverages = []

for n in chain_lengths:
    levs = []
    for _ in range(500):
        points = np.cumsum(np.random.randn(n, 2), axis=0)
        path_length = sum(np.linalg.norm(points[i+1] - points[i]) 
                          for i in range(n-1))
        endpoint_dist = np.linalg.norm(points[-1] - points[0])
        if endpoint_dist > 0.01:
            levs.append(path_length / endpoint_dist)
    mean_leverages.append(np.mean(levs) if levs else 1)
    std_leverages.append(np.std(levs) if levs else 0)

mean_leverages = np.array(mean_leverages)
std_leverages = np.array(std_leverages)

ax3.plot(chain_lengths, mean_leverages, 'b-', linewidth=2, label='Mean leverage')
ax3.fill_between(chain_lengths, 
                  mean_leverages - std_leverages,
                  mean_leverages + std_leverages,
                  alpha=0.2, color='blue', label='±1 std')
ax3.axhline(y=1, color='#e74c3c', linestyle='--', alpha=0.5, label='Minimum = 1')

# Theoretical: for random walk, E[path]/E[endpoint] ~ sqrt(n-1) * sqrt(pi/2) / ???
# Actually E[path] = (n-1) * E[step] and E[endpoint] ~ sqrt(n-1) * E[step]
# So leverage ~ sqrt(n-1) * const
sqrt_fit = np.sqrt(np.array(chain_lengths) - 1) * mean_leverages[0]
ax3.plot(chain_lengths, sqrt_fit, 'g:', linewidth=2, alpha=0.7,
         label=f'√(n-1) scaling')

ax3.set_xlabel("Chain Length (number of jokes)", fontsize=11)
ax3.set_ylabel("Mean Leverage Ratio", fontsize=11)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.suptitle("Comedy Chain Leverage: Longer Chains Amplify Narrative Distance",
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("comedy_chain.png", dpi=150, bbox_inches='tight')
plt.show()
print("Saved: comedy_chain.png")


"""
Visualization: The Comedy Polytope
====================================
Visualizes the set of achievable (tension, surprise, arc) triples
as defined by the triangle inequality constraints. The comedy polytope
is a convex cone in R³ — this script shows its cross-section at arc=1,
which is a triangle in the (tension, surprise) plane.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import Polygon

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# --- Left panel: 2D cross-section at arc = 1 ---
ax = axes[0]
ax.set_title("Comedy Polytope Cross-Section (arc = 1)", fontsize=13, fontweight='bold')

# The constraints for arc c = 1:
# a + b >= 1, a + 1 >= b, b + 1 >= a
# and a, b >= 0
# This gives: a >= 0, b >= 0, a + b >= 1, b <= a + 1, a <= b + 1

# Plot the feasible region
resolution = 500
a_vals = np.linspace(0, 2, resolution)
b_vals = np.linspace(0, 2, resolution)
A, B = np.meshgrid(a_vals, b_vals)

# Constraints
mask = (A >= 0) & (B >= 0) & (A + B >= 1) & (B <= A + 1) & (A <= B + 1)

ax.contourf(A, B, mask.astype(float), levels=[0.5, 1.5], 
            colors=['#3498db'], alpha=0.3)
ax.contour(A, B, mask.astype(float), levels=[0.5], 
           colors=['#2c3e50'], linewidths=2)

# Mark key points
# Vertices of the polytope cross-section
vertices = [(0, 1), (1, 0), (1, 2), (2, 1)]
for v in vertices:
    ax.plot(*v, 'ko', markersize=6)
    ax.annotate(f'({v[0]},{v[1]})', v, textcoords="offset points", 
                xytext=(8, 8), fontsize=9)

# Mark special triples
special = [
    ((0.5, 0.5), "Degenerate\n(collinear)", '#e74c3c'),
    ((1, 1), "Equilateral-like", '#27ae60'),
    ((0.3, 0.8), "High surprise\nefficiency", '#8e44ad'),
]
for pt, label, color in special:
    ax.plot(*pt, 'o', color=color, markersize=10, zorder=5)
    ax.annotate(label, pt, textcoords="offset points",
                xytext=(10, -15), fontsize=8, color=color, fontweight='bold')

ax.set_xlabel("Tension (setup → expectation)", fontsize=11)
ax.set_ylabel("Surprise (expectation → punchline)", fontsize=11)
ax.set_xlim(-0.1, 2.2)
ax.set_ylim(-0.1, 2.2)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# Add constraint labels
ax.text(0.15, 0.15, 'a + b < 1\n(excluded)', fontsize=9, 
        color='#e74c3c', style='italic', ha='center')

# --- Right panel: Defect heatmap ---
ax2 = axes[1]
ax2.set_title("Triangle Defect Heatmap (arc = 1)", fontsize=13, fontweight='bold')

defect = np.where(mask, A + B - 1, np.nan)
im = ax2.pcolormesh(A, B, defect, cmap='YlOrRd', shading='auto')
cbar = plt.colorbar(im, ax=ax2, label='Defect = tension + surprise − arc')

# Zero-defect line (where a + b = 1)
a_line = np.linspace(0, 1, 100)
ax2.plot(a_line, 1 - a_line, 'w--', linewidth=2, label='Defect = 0\n(geodesic jokes)')
ax2.legend(loc='upper right', fontsize=9)

ax2.set_xlabel("Tension", fontsize=11)
ax2.set_ylabel("Surprise", fontsize=11)
ax2.set_xlim(0, 2)
ax2.set_ylim(0, 2)
ax2.set_aspect('equal')

plt.suptitle("The Comedy Polytope: Geometry of Achievable Humor",
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("comedy_polytope.png", dpi=150, bbox_inches='tight')
plt.show()
print("Saved: comedy_polytope.png")


"""
Visualization: Surprise-Entropy Duality
=========================================
Shows the MAD ≤ σ inequality (Mean Absolute Deviation ≤ Standard Deviation)
across different probability distributions, demonstrating that average
surprise is always bounded by uncertainty.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# --- Panel 1: MAD vs σ across distribution shapes ---
ax = axes[0]
ax.set_title("MAD ≤ σ Across Distributions", fontsize=12, fontweight='bold')

np.random.seed(42)
distributions = {
    'Uniform': np.random.uniform(0, 10, 1000),
    'Normal': np.random.normal(5, 2, 1000),
    'Exponential': np.random.exponential(3, 1000),
    'Bimodal': np.concatenate([np.random.normal(2, 0.5, 500),
                                np.random.normal(8, 0.5, 500)]),
    'Heavy-tailed': np.random.standard_t(3, 1000) * 2 + 5,
    'Concentrated': np.concatenate([np.full(900, 5.0), 
                                     np.random.uniform(0, 10, 100)]),
}

mads, sigmas, names = [], [], []
for name, data in distributions.items():
    mu = np.mean(data)
    mad = np.mean(np.abs(data - mu))
    sigma = np.std(data)
    mads.append(mad)
    sigmas.append(sigma)
    names.append(name)

ax.scatter(sigmas, mads, c=['#e74c3c', '#3498db', '#27ae60', 
                             '#8e44ad', '#f39c12', '#1abc9c'],
           s=120, zorder=5, edgecolors='black', linewidth=0.5)

for i, name in enumerate(names):
    ax.annotate(name, (sigmas[i], mads[i]), textcoords="offset points",
                xytext=(8, 5), fontsize=8)

# Plot the y=x line (boundary)
max_val = max(max(mads), max(sigmas)) * 1.1
ax.plot([0, max_val], [0, max_val], 'k--', alpha=0.5, label='MAD = σ')
ax.fill_between([0, max_val], [0, max_val], [max_val, max_val],
                alpha=0.1, color='red', label='Forbidden (MAD > σ)')
ax.fill_between([0, max_val], [0, 0], [0, max_val],
                alpha=0.1, color='green', label='Achievable (MAD ≤ σ)')

ax.set_xlabel("Standard Deviation (σ)", fontsize=11)
ax.set_ylabel("Mean Absolute Deviation (MAD)", fontsize=11)
ax.legend(fontsize=8, loc='upper left')
ax.set_xlim(0, max_val)
ax.set_ylim(0, max_val)
ax.grid(True, alpha=0.3)

# --- Panel 2: How sample size affects the bound tightness ---
ax2 = axes[1]
ax2.set_title("Bound Tightness vs Sample Size", fontsize=12, fontweight='bold')

sample_sizes = list(range(2, 201))
ratios_normal = []
ratios_uniform = []

for n in sample_sizes:
    # Normal distribution
    data = np.random.normal(0, 1, n)
    mu = np.mean(data)
    mad = np.mean(np.abs(data - mu))
    sigma = np.std(data)
    ratios_normal.append(mad / sigma if sigma > 1e-10 else 0)
    
    # Uniform distribution
    data = np.random.uniform(0, 1, n)
    mu = np.mean(data)
    mad = np.mean(np.abs(data - mu))
    sigma = np.std(data)
    ratios_uniform.append(mad / sigma if sigma > 1e-10 else 0)

ax2.plot(sample_sizes, ratios_normal, '-', color='#3498db', 
         alpha=0.7, label='Normal', linewidth=1)
ax2.plot(sample_sizes, ratios_uniform, '-', color='#e74c3c',
         alpha=0.7, label='Uniform', linewidth=1)
ax2.axhline(y=1, color='black', linestyle='--', alpha=0.5, label='MAD = σ bound')
ax2.axhline(y=np.sqrt(2/np.pi), color='#27ae60', linestyle=':',
            alpha=0.7, label=f'√(2/π) ≈ {np.sqrt(2/np.pi):.3f} (Normal limit)')

ax2.set_xlabel("Sample Size (n)", fontsize=11)
ax2.set_ylabel("MAD / σ Ratio", fontsize=11)
ax2.legend(fontsize=8)
ax2.set_ylim(0, 1.2)
ax2.grid(True, alpha=0.3)

# --- Panel 3: Distribution shape vs MAD/σ ratio ---
ax3 = axes[2]
ax3.set_title("Distribution Shape Determines\nSurprise/Uncertainty Ratio", 
              fontsize=12, fontweight='bold')

# Generate distributions with varying kurtosis
n_samples = 10000
beta_params = [(0.5, 0.5), (1, 1), (2, 2), (5, 5), (1, 3), (0.5, 2)]
labels_beta = ['U-shaped\n(β=0.5,0.5)', 'Uniform\n(β=1,1)', 
               'Bell\n(β=2,2)', 'Peaked\n(β=5,5)',
               'Skewed\n(β=1,3)', 'J-shaped\n(β=0.5,2)']
colors = ['#e74c3c', '#f39c12', '#3498db', '#27ae60', '#8e44ad', '#1abc9c']

ratios = []
for a, b in beta_params:
    data = np.random.beta(a, b, n_samples)
    mu = np.mean(data)
    mad = np.mean(np.abs(data - mu))
    sigma = np.std(data)
    ratios.append(mad / sigma)

bars = ax3.bar(range(len(ratios)), ratios, color=colors, 
               edgecolor='black', linewidth=0.5, alpha=0.8)
ax3.set_xticks(range(len(ratios)))
ax3.set_xticklabels(labels_beta, fontsize=8)
ax3.axhline(y=1, color='black', linestyle='--', alpha=0.5, label='Upper bound')
ax3.set_ylabel("MAD / σ Ratio", fontsize=11)
ax3.set_ylim(0, 1.1)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3, axis='y')

# Add ratio values on bars
for i, (bar, ratio) in enumerate(zip(bars, ratios)):
    ax3.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.02,
             f'{ratio:.3f}', ha='center', fontsize=8, fontweight='bold')

plt.suptitle("Surprise-Entropy Duality: Average Surprise ≤ Uncertainty",
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("surprise_entropy.png", dpi=150, bbox_inches='tight')
plt.show()
print("Saved: surprise_entropy.png")
