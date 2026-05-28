"""
Visualization: Circuit Structure and Cancellation Budget

Shows how the cancellation budget accumulates through a circuit's structure
and how the monotone envelope bounds compare to actual support shadows.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ── Self-contained functions ─────────────────────────────────────────

def one_shadow(S):
    shadow = set()
    for alpha in S:
        for i in range(len(alpha)):
            if alpha[i] > 0:
                beta = list(alpha)
                beta[i] -= 1
                shadow.add(tuple(beta))
    return shadow

def support_mul(A, B):
    return {tuple(a + b for a, b in zip(x, y)) for x in A for y in B}


# ── Build example circuits and collect data ──────────────────────────

# Example: Circuit for a polynomial in 3 variables with increasing cancellation
# We'll simulate circuits with different amounts of cancellation and track
# how the shadow deficit and budget relate.

np.random.seed(42)
n_vars = 3

# Generate random support families
def random_support(n_vars, n_terms, max_deg=3):
    S = set()
    while len(S) < n_terms:
        v = tuple(np.random.randint(0, max_deg + 1) for _ in range(n_vars))
        S.add(v)
    return S

# Experiment: vary cancellation rate
cancel_rates = np.linspace(0, 0.9, 10)
deficits = []
budgets = []
sh_cancels = []
envelope_shadows = []
actual_shadows = []

for rate in cancel_rates:
    # Two support families of size 10 each
    A = random_support(n_vars, 10)
    B = random_support(n_vars, 10)
    envelope = A | B

    # Remove `rate` fraction to simulate cancellation
    n_to_remove = int(len(envelope) * rate)
    items = list(envelope)
    np.random.shuffle(items)
    removed = set(items[:n_to_remove])
    actual = envelope - removed

    sh_env = one_shadow(envelope)
    sh_act = one_shadow(actual)
    sh_rem = one_shadow(removed)

    deficit = max(0, len(sh_env) - len(sh_act))
    budget = len(sh_rem)

    deficits.append(deficit)
    budgets.append(budget)
    sh_cancels.append(len(sh_rem))
    envelope_shadows.append(len(sh_env))
    actual_shadows.append(len(sh_act))

# ── Create figure ────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Circuit Cancellation Budget Analysis', fontsize=14, fontweight='bold')

# Panel 1: Shadow sizes vs cancellation rate
ax = axes[0]
ax.plot(cancel_rates * 100, envelope_shadows, 'b-o', label='|Sh(envelope)|', linewidth=2)
ax.plot(cancel_rates * 100, actual_shadows, 'g-s', label='|Sh(actual)|', linewidth=2)
ax.fill_between(cancel_rates * 100, actual_shadows, envelope_shadows,
                alpha=0.2, color='red', label='Gap (deficit)')
ax.set_xlabel('Cancellation Rate (%)')
ax.set_ylabel('Shadow Size')
ax.set_title('Shadow Compression\nunder Cancellation')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 2: Deficit vs bound
ax = axes[1]
ax.plot(cancel_rates * 100, deficits, 'r-o', label='Shadow deficit', linewidth=2)
ax.plot(cancel_rates * 100, budgets, 'purple', linestyle='--', marker='s',
        label='|Sh(Cancel)| bound', linewidth=2)
ax.fill_between(cancel_rates * 100, deficits, budgets,
                alpha=0.15, color='green', label='Slack')
ax.set_xlabel('Cancellation Rate (%)')
ax.set_ylabel('Count')
ax.set_title('Deficit ≤ Budget\n(Theorem 2 verified)')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 3: Ratio analysis
ax = axes[2]
ratios = [d / max(1, b) for d, b in zip(deficits, budgets)]
ax.bar(cancel_rates * 100, ratios, width=8, color='#FF9800', alpha=0.8,
       edgecolor='#E65100')
ax.axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='Bound (ratio = 1)')
ax.set_xlabel('Cancellation Rate (%)')
ax.set_ylabel('Deficit / Budget')
ax.set_title('Tightness of\nDeficit Bound')
ax.legend()
ax.set_ylim(0, 1.5)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('circuit_cancellation_analysis.png', dpi=150, bbox_inches='tight')
print("Saved: circuit_cancellation_analysis.png")
