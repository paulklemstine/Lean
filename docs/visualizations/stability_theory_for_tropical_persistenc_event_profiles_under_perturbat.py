"""
Visualization: Tropical Event Profiles Under Perturbation

Shows the tropical event profile — a step function that records cumulative
graph-structural information as vertices enter the filtration — for an
original filtration and its perturbation. The ε-interleaving property
(proved in the stability theorem) is visible: the perturbed profile is
a time-shifted version of the original, with shift bounded by ε.

This directly illustrates the interleaving theorem:
    tropicalEventProfile G f t ≤ tropicalEventProfile G g (t + ε)
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Dict, List, Tuple
from dataclasses import dataclass


@dataclass
class SimpleGraph:
    n: int
    adj: Dict[int, List[int]]

    def degree(self, v: int) -> int:
        return len(self.adj.get(v, []))

    def max_degree(self) -> int:
        return max((self.degree(v) for v in range(self.n)), default=0)

    @classmethod
    def from_edges(cls, n: int, edges: List[Tuple[int, int]]) -> 'SimpleGraph':
        adj = {i: [] for i in range(n)}
        for u, v in edges:
            if u != v:
                if v not in adj[u]:
                    adj[u].append(v)
                if u not in adj[v]:
                    adj[v].append(u)
        return cls(n=n, adj=adj)


def tropical_event_profile(G, f, t):
    active = np.where(f <= t)[0]
    return sum(G.degree(int(v)) + 1 for v in active)


rng = np.random.default_rng(2025)

# Create a graph with interesting structure
n = 25
edges = []
# Ring
for i in range(n):
    edges.append((i, (i + 1) % n))
# Cross-connections
for i in range(0, n, 5):
    edges.append((i, (i + 7) % n))
    edges.append((i, (i + 12) % n))

G = SimpleGraph.from_edges(n, edges)

# Create filtrations
f = np.sort(rng.uniform(0, 1, n))
epsilon = 0.06
g = f + rng.uniform(-epsilon, epsilon, n)

t_values = np.linspace(-0.05, 1.05, 500)
profile_f = [tropical_event_profile(G, f, t) for t in t_values]
profile_g = [tropical_event_profile(G, g, t) for t in t_values]
# Shifted profile for interleaving visualization
profile_f_shifted = [tropical_event_profile(G, f, t - epsilon) for t in t_values]

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Panel 1: Both profiles overlaid
ax = axes[0]
ax.step(t_values, profile_f, where='post', color='#1565C0', linewidth=2.5,
        label='Profile(f)', zorder=3)
ax.step(t_values, profile_g, where='post', color='#E65100', linewidth=2.5,
        label='Profile(g)', linestyle='--', zorder=3)
ax.fill_between(t_values, profile_f, profile_g, alpha=0.12, color='gray',
                step='post')
ax.set_xlabel('Time t', fontsize=13)
ax.set_ylabel('Event Profile Value', fontsize=13)
ax.set_title('Original vs. Perturbed Profile', fontsize=14, fontweight='bold')
ax.legend(fontsize=12, loc='upper left')
ax.grid(True, alpha=0.3)

# Panel 2: Interleaving demonstration
ax = axes[1]
ax.step(t_values, profile_f, where='post', color='#1565C0', linewidth=2.5,
        label='Profile_f(t)')
ax.step(t_values, profile_f_shifted, where='post', color='#1565C0',
        linewidth=1.5, linestyle=':', alpha=0.6, label=f'Profile_f(t−ε)')
ax.step(t_values, profile_g, where='post', color='#E65100', linewidth=2.5,
        label='Profile_g(t)', linestyle='--')

# Mark interleaving region
for i in range(len(t_values)):
    if profile_f_shifted[i] > profile_g[i] + 0.5:
        ax.axvline(t_values[i], color='red', alpha=0.01, linewidth=0.5)

ax.set_xlabel('Time t', fontsize=13)
ax.set_ylabel('Event Profile Value', fontsize=13)
ax.set_title(f'ε-Interleaving (ε = {epsilon:.2f})\nProfile_f(t) ≤ Profile_g(t+ε)',
             fontsize=14, fontweight='bold')
ax.legend(fontsize=11, loc='upper left')
ax.grid(True, alpha=0.3)

# Panel 3: Profile difference
ax = axes[2]
diff = np.array(profile_f) - np.array(profile_g)
ax.step(t_values, diff, where='post', color='#7B1FA2', linewidth=2)
ax.axhline(y=0, color='black', linewidth=0.5)

D = G.max_degree()
max_diff = (D + 1)
ax.axhline(y=max_diff, color='red', linestyle='--', linewidth=1.5,
           label=f'±(D+1) = ±{max_diff}')
ax.axhline(y=-max_diff, color='red', linestyle='--', linewidth=1.5)
ax.fill_between(t_values, -max_diff, max_diff, alpha=0.08, color='red')

ax.set_xlabel('Time t', fontsize=13)
ax.set_ylabel('Profile Difference', fontsize=13)
ax.set_title('Profile Difference\n(bounded by ±(D+1) per vertex)',
             fontsize=14, fontweight='bold')
ax.legend(fontsize=12)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('event_profiles.png', dpi=150, bbox_inches='tight')
print("Saved event_profiles.png")
