"""
Visualization: Multi-Step Shadow Decay Profiles

Compares the iterated shadow profiles of different polynomial families:
elementary symmetric polynomials (KK-optimal) vs permanent supports
(inflated). The shadow profile k -> |Shadow_k(S)| reveals how quickly
the support shrinks under repeated differentiation, providing a
complexity-theoretic fingerprint.

Output: PNG plot saved via matplotlib.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import permutations, combinations
from math import comb, factorial
from typing import Set, Tuple, List

ExponentVector = Tuple[int, ...]
Family = Set[ExponentVector]


def one_shadow(S: Family, n: int) -> Family:
    shadow: Family = set()
    for alpha in S:
        for i in range(n):
            if alpha[i] > 0:
                beta = list(alpha)
                beta[i] -= 1
                shadow.add(tuple(beta))
    return shadow


def multi_step_profile(S: Family, n: int, steps: int) -> List[int]:
    profile = [len(S)]
    current = S
    for _ in range(steps):
        current = one_shadow(current, n)
        profile.append(len(current))
        if len(current) == 0:
            break
    return profile


# Elementary symmetric e_3(x_1,...,x_6)
n_e3 = 6
e3 = set()
for triple in combinations(range(n_e3), 3):
    vec = [0] * n_e3
    for j in triple:
        vec[j] = 1
    e3.add(tuple(vec))

profile_e3 = multi_step_profile(e3, n_e3, 4)

# Permanent of 3×3
m = 3
perm_S = set()
for perm in permutations(range(m)):
    vec = [0] * (m * m)
    for i in range(m):
        vec[i * m + perm[i]] = 1
    perm_S.add(tuple(vec))

profile_perm3 = multi_step_profile(perm_S, m * m, 4)

# Power sum p_3 = sum x_i^3 in 6 variables
ps3 = set()
for i in range(n_e3):
    vec = [0] * n_e3
    vec[i] = 3
    ps3.add(tuple(vec))

profile_ps3 = multi_step_profile(ps3, n_e3, 4)

# Monomial x_1*x_2*x_3 (singleton)
mono = {(1, 1, 1, 0, 0, 0)}
profile_mono = multi_step_profile(mono, n_e3, 4)

# Create plot
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Shadow Decay Profiles: Complexity Fingerprints',
             fontsize=14, fontweight='bold')

# Left: absolute profiles
steps_e3 = list(range(len(profile_e3)))
steps_perm = list(range(len(profile_perm3)))
steps_ps3 = list(range(len(profile_ps3)))
steps_mono = list(range(len(profile_mono)))

ax1.plot(steps_e3, profile_e3, 'o-', label='e₃(x₁,...,x₆)',
         color='#3498db', linewidth=2, markersize=8)
ax1.plot(steps_perm, profile_perm3, 's-', label='perm₃',
         color='#e74c3c', linewidth=2, markersize=8)
ax1.plot(steps_ps3, profile_ps3, '^-', label='p₃ = Σxᵢ³',
         color='#2ecc71', linewidth=2, markersize=8)
ax1.plot(steps_mono, profile_mono, 'D-', label='x₁x₂x₃ (monomial)',
         color='#9b59b6', linewidth=2, markersize=8)

ax1.set_xlabel('Shadow depth k')
ax1.set_ylabel('|Shadow_k(S)|')
ax1.set_title('Absolute Shadow Profiles')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Right: normalized profiles (relative to k=0)
def normalize(profile):
    return [p / profile[0] if profile[0] > 0 else 0 for p in profile]

ax2.plot(steps_e3, normalize(profile_e3), 'o-', label='e₃(x₁,...,x₆)',
         color='#3498db', linewidth=2, markersize=8)
ax2.plot(steps_perm, normalize(profile_perm3), 's-', label='perm₃',
         color='#e74c3c', linewidth=2, markersize=8)
ax2.plot(steps_ps3, normalize(profile_ps3), '^-', label='p₃ = Σxᵢ³',
         color='#2ecc71', linewidth=2, markersize=8)
ax2.plot(steps_mono, normalize(profile_mono), 'D-', label='x₁x₂x₃',
         color='#9b59b6', linewidth=2, markersize=8)

ax2.set_xlabel('Shadow depth k')
ax2.set_ylabel('|Shadow_k(S)| / |S|')
ax2.set_title('Normalized Shadow Profiles')
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('shadow_profiles.png', dpi=150, bbox_inches='tight')
print("Saved: shadow_profiles.png")
