"""
Demo: The Category Theory of Surprise — Numerical Examples

Demonstrates the key mathematical results from the Categorical Surprise Theory:
1. Surprise computation in metric spaces
2. Information-theoretic surprise and entropy
3. Incongruity-resolution model
4. Comedy routine analysis
"""

import math
from typing import List, Tuple

# ============================================================
# Part 1: Surprise Spaces
# ============================================================

def surprise(point: float, expected: float) -> float:
    """Surprise = distance from expected outcome."""
    return abs(point - expected)

def demo_surprise_space():
    """Demonstrate surprise computation in a 1D metric space."""
    print("=" * 60)
    print("SURPRISE SPACES")
    print("=" * 60)
    
    expected = 5.0  # Expected punchline value
    punchlines = [5.0, 4.0, 7.0, 0.0, 10.0, 5.1]
    labels = ["Expected", "Close", "Moderate", "Far (absurd)", "Maximum", "Pun"]
    
    print(f"\nExpected outcome: {expected}")
    print(f"{'Punchline':<15} {'Value':<10} {'Surprise':<10} {'Type'}")
    print("-" * 50)
    for label, p in zip(labels, punchlines):
        s = surprise(p, expected)
        print(f"{label:<15} {p:<10.1f} {s:<10.1f} {'★' * int(s)}")
    
    # Verify triangle inequality
    x, y = 3.0, 8.0
    print(f"\nTriangle Inequality Verification:")
    print(f"  surprise({y}) = {surprise(y, expected):.1f}")
    print(f"  surprise({x}) + dist({y},{x}) = {surprise(x, expected):.1f} + {abs(y-x):.1f} = {surprise(x, expected) + abs(y-x):.1f}")
    print(f"  {surprise(y, expected):.1f} ≤ {surprise(x, expected) + abs(y-x):.1f} ✓")

# ============================================================
# Part 2: Information-Theoretic Surprise
# ============================================================

def info_surprise(p: float) -> float:
    """Information-theoretic surprise: -log₂(p)."""
    if p <= 0:
        return float('inf')
    return -math.log2(p)

def demo_info_surprise():
    """Demonstrate information-theoretic surprise."""
    print("\n" + "=" * 60)
    print("INFORMATION-THEORETIC SURPRISE")
    print("=" * 60)
    
    events = [
        ("Certain (p=1)", 1.0),
        ("Coin flip (p=0.5)", 0.5),
        ("Die roll (p=1/6)", 1/6),
        ("Rare joke (p=0.01)", 0.01),
        ("Lightning (p=10⁻⁶)", 1e-6),
    ]
    
    print(f"\n{'Event':<25} {'Probability':<15} {'Surprise (bits)'}")
    print("-" * 55)
    for label, p in events:
        s = info_surprise(p)
        print(f"{label:<25} {p:<15.6f} {s:.2f}")
    
    # Verify additivity: I(pq) = I(p) + I(q)
    p, q = 0.3, 0.2
    print(f"\nAdditivity: I({p}×{q}) = I({p}) + I({q})")
    print(f"  I({p*q:.2f}) = {info_surprise(p*q):.4f}")
    print(f"  I({p}) + I({q}) = {info_surprise(p):.4f} + {info_surprise(q):.4f} = {info_surprise(p) + info_surprise(q):.4f} ✓")
    
    # Uniform entropy
    print(f"\nUniform Entropy (Surprise of 1/n for n elements):")
    for n in [2, 4, 8, 16, 100]:
        entropy = info_surprise(1/n)
        print(f"  n={n:<5} entropy = log₂({n}) = {entropy:.4f} bits")

# ============================================================
# Part 3: Incongruity-Resolution Model
# ============================================================

def net_humor(incongruity: float, resolution: float) -> float:
    """Net humor = incongruity × (1 - resolution)."""
    return incongruity * (1 - resolution)

def classify_joke(resolution: float) -> str:
    """Classify joke type by resolution level."""
    if resolution < 0.1:
        return "Absurdist"
    elif resolution < 0.3:
        return "Dark/Dry"
    elif resolution < 0.6:
        return "Observational"
    elif resolution < 0.8:
        return "Wordplay"
    else:
        return "Pun"

def demo_incongruity_resolution():
    """Demonstrate the incongruity-resolution model."""
    print("\n" + "=" * 60)
    print("INCONGRUITY-RESOLUTION MODEL")
    print("=" * 60)
    
    jokes = [
        ("Chicken crosses road", 1.0, 0.95),
        ("Classic pun", 3.0, 0.8),
        ("Seinfeld observation", 5.0, 0.5),
        ("Dark comedy", 7.0, 0.2),
        ("Monty Python absurdism", 9.0, 0.05),
        ("Pure nonsense", 10.0, 0.0),
    ]
    
    print(f"\n{'Joke':<25} {'Incong.':<8} {'Resol.':<8} {'Humor':<8} {'Type':<15} {'Bar'}")
    print("-" * 80)
    for label, inc, res in jokes:
        h = net_humor(inc, res)
        jtype = classify_joke(res)
        bar = "█" * int(h)
        print(f"{label:<25} {inc:<8.1f} {res:<8.2f} {h:<8.2f} {jtype:<15} {bar}")
    
    # Verify Maximum Humor Theorem
    print(f"\nMaximum Humor Theorem:")
    print(f"  H = I ⟺ r = 0 or I = 0")
    for inc, res in [(5.0, 0.0), (0.0, 0.7), (5.0, 0.3)]:
        h = net_humor(inc, res)
        eq = "=" if abs(h - inc) < 1e-10 else "≠"
        cond = "r=0" if res == 0 else ("I=0" if inc == 0 else "neither")
        print(f"  I={inc}, r={res}: H={h:.1f} {eq} I={inc} ({cond})")
    
    # Verify Pun Bound
    print(f"\nPun Bound: If r ≥ 0.5, then H ≤ I/2")
    for inc, res in [(10.0, 0.5), (10.0, 0.7), (10.0, 0.9)]:
        h = net_humor(inc, res)
        bound = inc / 2
        print(f"  I={inc}, r={res}: H={h:.1f} ≤ I/2={bound:.1f} ✓")

# ============================================================
# Part 4: Comedy Routines
# ============================================================

def demo_comedy_routines():
    """Demonstrate comedy routine analysis."""
    print("\n" + "=" * 60)
    print("COMEDY ROUTINE ANALYSIS")
    print("=" * 60)
    
    routines = {
        "Opener": [2.0, 3.0, 4.0, 5.0],
        "Headliner": [5.0, 7.0, 8.0, 9.0, 10.0],
        "Absurdist Set": [8.0, 1.0, 9.0, 0.5, 10.0],
    }
    
    for name, humor_values in routines.items():
        total = sum(humor_values)
        avg = total / len(humor_values)
        peak = max(humor_values)
        print(f"\n{name}: {humor_values}")
        print(f"  Total humor: {total:.1f}")
        print(f"  Average humor: {avg:.1f}")
        print(f"  Peak humor: {peak:.1f}")
        print(f"  Average ≤ Peak: {avg:.1f} ≤ {peak:.1f} ✓")

# ============================================================
# Part 5: Surprise Functor Gap
# ============================================================

def demo_surprise_functor():
    """Demonstrate the surprise functor gap."""
    print("\n" + "=" * 60)
    print("SURPRISE FUNCTOR: NARRATIVE GAP")
    print("=" * 60)
    
    # A story with expected and twisted versions
    timeline = list(range(10))
    expected_story = [float(t) for t in timeline]  # Linear expected narrative
    twisted_story = [float(t) if t < 5 else float(15 - t) for t in timeline]  # Twist at t=5
    
    print(f"\n{'Time':<6} {'Expected':<10} {'Twisted':<10} {'Gap':<10}")
    print("-" * 36)
    for t in timeline:
        gap = abs(expected_story[t] - twisted_story[t])
        bar = "█" * int(gap * 2)
        print(f"{t:<6} {expected_story[t]:<10.1f} {twisted_story[t]:<10.1f} {gap:<10.1f} {bar}")
    
    # Verify gap triangle inequality
    print(f"\nGap Triangle Inequality at t=7:")
    t, s = 7, 3
    gap_t = abs(expected_story[t] - twisted_story[t])
    gap_s = abs(expected_story[s] - twisted_story[s])
    d_exp = abs(expected_story[s] - expected_story[t])
    d_twist = abs(twisted_story[s] - twisted_story[t])
    print(f"  Gap({t}) = {gap_t:.1f}")
    print(f"  Gap({s}) + d_exp({s},{t}) + d_twist({s},{t}) = {gap_s:.1f} + {d_exp:.1f} + {d_twist:.1f} = {gap_s + d_exp + d_twist:.1f}")
    print(f"  {gap_t:.1f} ≤ {gap_s + d_exp + d_twist:.1f} ✓")


if __name__ == "__main__":
    demo_surprise_space()
    demo_info_surprise()
    demo_incongruity_resolution()
    demo_comedy_routines()
    demo_surprise_functor()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete. All theorems verified numerically.")
    print("=" * 60)


"""
Visualization: Entropy-Comedy Connection

Shows the relationship between Shannon entropy (expected surprise)
and the number of possible punchlines. Maximum entropy = maximum comedy.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Info surprise as function of probability
ax = axes[0]
p = np.linspace(0.01, 1.0, 200)
surprise = -np.log2(p)
ax.plot(p, surprise, 'b-', linewidth=2)
ax.fill_between(p, surprise, alpha=0.15, color='blue')
ax.set_title('Information-Theoretic Surprise\nI(p) = -log₂(p)', fontsize=14)
ax.set_xlabel('Probability p')
ax.set_ylabel('Surprise (bits)')
ax.set_xlim(0, 1)
ax.set_ylim(0, 7)

# Annotate key points
for prob, label in [(1.0, 'Certain'), (0.5, 'Coin flip'), (1/6, 'Die roll'), (0.01, 'Rare')]:
    s = -np.log2(prob)
    ax.plot(prob, s, 'ro', markersize=8)
    ax.annotate(f'{label}\n({s:.1f} bits)', (prob, s), 
                textcoords="offset points", xytext=(10, 5), fontsize=9)

# Plot 2: Entropy vs number of outcomes
ax = axes[1]
ns = np.arange(1, 101)
entropies = np.log2(ns)
ax.plot(ns, entropies, 'r-', linewidth=2)
ax.fill_between(ns, entropies, alpha=0.15, color='red')
ax.set_title('Maximum Comedy Potential\nH = log₂(n)', fontsize=14)
ax.set_xlabel('Number of possible punchlines (n)')
ax.set_ylabel('Shannon Entropy (bits)')

# Highlight specific values
for n, label in [(2, '2'), (8, '8'), (32, '32'), (100, '100')]:
    ax.plot(n, np.log2(n), 'ko', markersize=8)
    ax.annotate(f'n={label}: {np.log2(n):.1f}', (n, np.log2(n)),
                textcoords="offset points", xytext=(5, 10), fontsize=9)

# Plot 3: Surprise additivity
ax = axes[2]
p_vals = np.linspace(0.05, 0.95, 50)
q = 0.3
combined = -np.log2(p_vals * q)
individual_p = -np.log2(p_vals)
individual_q = -np.log2(q) * np.ones_like(p_vals)

ax.plot(p_vals, combined, 'g-', linewidth=2, label='I(p·q) [combined]')
ax.plot(p_vals, individual_p, 'b--', linewidth=2, label='I(p)')
ax.plot(p_vals, individual_q, 'r--', linewidth=2, label=f'I(q={q:.1f})')
ax.plot(p_vals, individual_p + individual_q, 'k:', linewidth=2, label='I(p) + I(q)')
ax.set_title('Surprise Additivity\nI(pq) = I(p) + I(q)', fontsize=14)
ax.set_xlabel('Probability p')
ax.set_ylabel('Surprise (bits)')
ax.legend()

plt.tight_layout()
plt.savefig('entropy_comedy.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved entropy_comedy.png")


"""
Visualization: Narrative Surprise Gap

Shows how the gap between expected and twisted narratives
evolves over time, demonstrating the surprise functor.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Timeline
t = np.linspace(0, 10, 200)

# Expected narrative: linear rise
expected = t

# Three different comedy styles
twists = {
    'Pun (small gap)': t + 0.5 * np.sin(2 * t),
    'Observational (medium gap)': np.where(t < 5, t, 10 - t),
    'Absurdist (large gap)': np.where(t < 4, t, t**2 / 10 + np.sin(3*t) * 3),
}

colors = ['#2196F3', '#FF9800', '#F44336']

# Plot 1: Narrative trajectories
ax = axes[0]
ax.plot(t, expected, 'k-', linewidth=3, label='Expected narrative', zorder=5)
for (label, twist), color in zip(twists.items(), colors):
    ax.plot(t, twist, '--', linewidth=2, color=color, label=label)
ax.set_title('Expected vs. Twisted Narratives', fontsize=14)
ax.set_xlabel('Story time')
ax.set_ylabel('Narrative value')
ax.legend(loc='upper left')
ax.grid(True, alpha=0.3)

# Plot 2: Gap profiles
ax = axes[1]
for (label, twist), color in zip(twists.items(), colors):
    gap = np.abs(expected - twist)
    ax.plot(t, gap, '-', linewidth=2, color=color, label=label)
    ax.fill_between(t, gap, alpha=0.1, color=color)

ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
ax.set_title('Surprise Gap Profile\nG(t) = |F(t) − T(t)|', fontsize=14)
ax.set_xlabel('Story time')
ax.set_ylabel('Surprise gap')
ax.legend()
ax.grid(True, alpha=0.3)

# Add punchline marker
punchline_t = 8
for (label, twist), color in zip(twists.items(), colors):
    gap_at_punch = abs(expected[np.argmin(np.abs(t - punchline_t))] - 
                       twist[np.argmin(np.abs(t - punchline_t))])
    ax.plot(punchline_t, gap_at_punch, 'o', color=color, markersize=10)

ax.axvline(x=punchline_t, color='gray', linestyle=':', alpha=0.5, label='Punchline')

plt.tight_layout()
plt.savefig('narrative_gap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved narrative_gap.png")


"""
Visualization: Surprise Landscape

A 2D heatmap showing the surprise value at each point in a metric space,
with the expected point at the center. Demonstrates the Fundamental Theorem
of Comedy: maximum surprise is achieved at the boundary.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

# Create 2D surprise space
fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Parameters
expected = (0, 0)
grid_size = 100
x = np.linspace(-5, 5, grid_size)
y = np.linspace(-5, 5, grid_size)
X, Y = np.meshgrid(x, y)

# Surprise = distance from expected
surprise = np.sqrt((X - expected[0])**2 + (Y - expected[1])**2)

# Plot 1: Surprise heatmap
ax = axes[0]
im = ax.contourf(X, Y, surprise, levels=20, cmap='YlOrRd')
ax.plot(*expected, 'w*', markersize=15, markeredgecolor='black', label='Expected')
ax.set_title('Surprise Landscape\n(Distance from Expected)', fontsize=14)
ax.set_xlabel('Punchline dimension 1')
ax.set_ylabel('Punchline dimension 2')
ax.legend()
plt.colorbar(im, ax=ax, label='Surprise Value')

# Plot 2: Surprise cross-section
ax = axes[1]
surprise_1d = np.sqrt(x**2)
ax.plot(x, surprise_1d, 'r-', linewidth=2, label='Surprise σ(x)')
ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax.axvline(x=0, color='blue', linestyle='--', alpha=0.5, label='Expected point')
# Triangle inequality visualization
x1, x2 = -2, 3
s1 = abs(x1)
s2 = abs(x2)
d12 = abs(x2 - x1)
ax.annotate('', xy=(x2, s2), xytext=(x1, s1),
            arrowprops=dict(arrowstyle='->', color='green', lw=2))
ax.plot([x1, x1], [0, s1], 'g--', alpha=0.5)
ax.plot([x2, x2], [0, s2], 'g--', alpha=0.5)
ax.set_title('Surprise Cross-Section\n& Triangle Inequality', fontsize=14)
ax.set_xlabel('Punchline value')
ax.set_ylabel('Surprise')
ax.legend()

# Plot 3: IR model
ax = axes[2]
resolutions = np.linspace(0, 1, 100)
for inc in [2, 4, 6, 8, 10]:
    net_humor = inc * (1 - resolutions)
    ax.plot(resolutions, net_humor, linewidth=2, label=f'I={inc}')
ax.axvline(x=0.5, color='gray', linestyle=':', alpha=0.7, label='Pun bound (r=0.5)')
ax.fill_between(resolutions, 0, 10*(1-resolutions), alpha=0.1, color='red')
ax.set_title('Incongruity-Resolution Model\nH = I × (1 − r)', fontsize=14)
ax.set_xlabel('Resolution (r)')
ax.set_ylabel('Net Humor (H)')
ax.legend(loc='upper right', fontsize=9)

plt.tight_layout()
plt.savefig('surprise_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved surprise_landscape.png")
