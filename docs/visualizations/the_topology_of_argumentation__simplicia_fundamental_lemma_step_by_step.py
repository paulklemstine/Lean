"""
Visualization: The Fundamental Lemma in Action
=================================================
Shows how admissible sets grow step-by-step via the Fundamental Lemma:
starting from ∅, we iteratively add acceptable arguments to build
a preferred extension.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
from collections import defaultdict


class ArgFramework:
    def __init__(self, arguments, attacks):
        self.arguments = frozenset(arguments)
        self.attacks = frozenset(attacks)
        self._attackers = defaultdict(set)
        self._targets = defaultdict(set)
        for a, b in attacks:
            self._attackers[b].add(a)
            self._targets[a].add(b)

    def attackers_of(self, a):
        return self._attackers.get(a, set())

    def is_conflict_free(self, S):
        for a, b in self.attacks:
            if a in S and b in S:
                return False
        return True

    def is_acceptable(self, S, a):
        for b in self.attackers_of(a):
            if not any(c in S for c in self.attackers_of(b)):
                return False
        return True

    def is_admissible(self, S):
        if not self.is_conflict_free(S):
            return False
        return all(self.is_acceptable(S, a) for a in S)


def build_preferred_steps(af):
    """Build a preferred extension step by step, recording each addition."""
    S = set()
    steps = [frozenset(S)]
    reasons = ["Start: ∅ is admissible"]

    args_ordered = sorted(af.arguments, key=str)
    changed = True
    while changed:
        changed = False
        for a in args_ordered:
            if a in S:
                continue
            S_with_a = frozenset(S | {a})
            if af.is_conflict_free(S_with_a) and af.is_acceptable(frozenset(S), a):
                S.add(a)
                steps.append(frozenset(S))

                # Build reason
                attackers = af.attackers_of(a)
                if not attackers:
                    reason = f"Add '{a}': no attackers (trivially acceptable)"
                else:
                    defenders = []
                    for b in attackers:
                        for c in S:
                            if c in af.attackers_of(b):
                                defenders.append(f"'{c}' defends against '{b}'")
                    reason = f"Add '{a}': {'; '.join(defenders) if defenders else 'acceptable'}"
                reasons.append(reason)
                changed = True
                break

    return steps, reasons


# Framework: a debate about AI safety
args = ['safe_ai', 'risk', 'alignment', 'pause', 'accelerate', 'regulation']
attacks = [
    ('risk', 'safe_ai'),       # Risk claims AI isn't safe
    ('alignment', 'risk'),      # Alignment research counters risk
    ('pause', 'accelerate'),    # Pause vs accelerate
    ('accelerate', 'pause'),    # Accelerate vs pause
    ('regulation', 'risk'),     # Regulation addresses risk
    ('risk', 'accelerate'),     # Risk argues against acceleration
]

AF = ArgFramework(set(args), set(attacks))
steps, reasons = build_preferred_steps(AF)

# Layout
n_steps = len(steps)
fig, axes = plt.subplots(1, n_steps, figsize=(4 * n_steps, 5))
if n_steps == 1:
    axes = [axes]

fig.suptitle('The Fundamental Lemma: Building a Preferred Extension Step by Step',
             fontsize=14, fontweight='bold', y=1.02)

# Argument positions (circular layout)
n_args = len(args)
positions = {}
for i, a in enumerate(sorted(args)):
    angle = 2 * np.pi * i / n_args - np.pi / 2
    positions[a] = (np.cos(angle), np.sin(angle))

for step_idx, (step, reason) in enumerate(zip(steps, reasons)):
    ax = axes[step_idx]
    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-1.8, 1.8)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title(f'Step {step_idx}', fontsize=11, fontweight='bold')

    # Draw attacks
    for a, b in attacks:
        xa, ya = positions[a]
        xb, yb = positions[b]
        dx, dy = xb - xa, yb - ya
        dist = np.sqrt(dx**2 + dy**2)
        if dist > 0:
            shrink = 0.22
            ax.annotate("", xy=(xb - shrink * dx / dist, yb - shrink * dy / dist),
                        xytext=(xa + shrink * dx / dist, ya + shrink * dy / dist),
                        arrowprops=dict(arrowstyle="->", color="#BDC3C7",
                                       lw=1, connectionstyle="arc3,rad=0.15"))

    # Draw arguments
    for a in sorted(args):
        x, y = positions[a]
        if a in step:
            color = '#2ECC71'  # In admissible set
            ec = '#27AE60'
        else:
            # Check if acceptable w.r.t. current step
            S = frozenset(step)
            S_with_a = frozenset(step | {a})
            if AF.is_conflict_free(S_with_a) and AF.is_acceptable(S, a):
                color = '#F39C12'  # Acceptable (could be added)
                ec = '#E67E22'
            else:
                color = '#ECF0F1'  # Not yet acceptable
                ec = '#BDC3C7'

        circle = plt.Circle((x, y), 0.18, color=color, ec=ec, lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, a[:4], ha='center', va='center', fontsize=7,
                fontweight='bold', zorder=6)

    # Add reason text
    ax.text(0, -1.6, reason, ha='center', va='top', fontsize=7,
            style='italic', wrap=True,
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow',
                      edgecolor='gray', alpha=0.8))

# Legend
legend_elements = [
    mpatches.Patch(facecolor='#2ECC71', edgecolor='#27AE60', label='In admissible set'),
    mpatches.Patch(facecolor='#F39C12', edgecolor='#E67E22', label='Acceptable (can add)'),
    mpatches.Patch(facecolor='#ECF0F1', edgecolor='#BDC3C7', label='Not yet acceptable'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=3, fontsize=9,
           bbox_to_anchor=(0.5, -0.02))

plt.tight_layout(rect=[0, 0.05, 1, 0.95])
plt.savefig('fundamental_lemma.png', dpi=150, bbox_inches='tight')
print("Saved: fundamental_lemma.png")
