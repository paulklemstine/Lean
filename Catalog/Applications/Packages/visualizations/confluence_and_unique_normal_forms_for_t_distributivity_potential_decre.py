#!/usr/bin/env python3
"""
Visualization: Distributivity Potential Decrease Under Rewriting

Shows how the polynomial interpretation (distPotential) strictly decreases
for each of the 9 rewrite rules, with different amounts of decrease depending
on the rule and the subterm sizes.

This is a standalone script - all needed functions are inlined.
"""

import matplotlib.pyplot as plt
import numpy as np

# Compute distPotential decrease for each rule as a function of subterm sizes
# Using the polynomial interpretation:
# dp(add a b) = a + b + 1, dp(mul a b) = a*b, dp(smul a b) = a*b + 1

def rule_decrease(rule_name, a=3, b=3, c=3):
    """Compute (dp_lhs, dp_rhs, decrease) for each rule given subterm dp values."""
    rules = {
        "R1: mulVec_vecAdd":    (a * (b + c + 1),     a*b + a*c + 1),
        "R2: matAdd_mulVec":    ((a + b + 1) * c,     a*c + b*c + 1),
        "R3: smulMat_mulVec":   ((a*b + 1) * c,       a*b*c + 1),
        "R4: smulVec_vecAdd":   (a * (b + c + 1) + 1, (a*b+1) + (a*c+1) + 1),
        "R5: smulMat_matAdd":   (a * (b + c + 1) + 1, (a*b+1) + (a*c+1) + 1),
        "R6: dot_vecAdd_left":  ((a + b + 1) * c,     a*c + b*c + 1),
        "R7: dot_vecAdd_right": (a * (b + c + 1),     a*b + a*c + 1),
        "R8: dot_smulVec_left": ((a*b + 1) * c,       a*b*c),
        "R9: scalMul_scalAdd":  (a * (b + c + 1),     a*b + a*c + 1),
    }
    lhs, rhs = rules[rule_name]
    return lhs, rhs, lhs - rhs

# Create figure with two subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Decrease amount for each rule with subterm values = 3
rule_names = [
    "R1: mulVec_vecAdd", "R2: matAdd_mulVec", "R3: smulMat_mulVec",
    "R4: smulVec_vecAdd", "R5: smulMat_matAdd",
    "R6: dot_vecAdd_left", "R7: dot_vecAdd_right",
    "R8: dot_smulVec_left", "R9: scalMul_scalAdd"
]
short_names = ["R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9"]

decreases_base = [rule_decrease(r)[2] for r in rule_names]
decreases_5 = [rule_decrease(r, 5, 5, 5)[2] for r in rule_names]
decreases_10 = [rule_decrease(r, 10, 10, 10)[2] for r in rule_names]

x = np.arange(len(rule_names))
width = 0.25

bars1 = ax1.bar(x - width, decreases_base, width, label='dp(vars)=3', color='#2196F3', alpha=0.8)
bars2 = ax1.bar(x, decreases_5, width, label='dp(vars)=5', color='#FF9800', alpha=0.8)
bars3 = ax1.bar(x + width, decreases_10, width, label='dp(vars)=10', color='#4CAF50', alpha=0.8)

ax1.set_xlabel('Rewrite Rule', fontsize=12)
ax1.set_ylabel('dp(LHS) − dp(RHS)', fontsize=12)
ax1.set_title('Strict Decrease of Distributivity Potential', fontsize=14, fontweight='bold')
ax1.set_xticks(x)
ax1.set_xticklabels(short_names)
ax1.legend()
ax1.axhline(y=0, color='red', linestyle='--', alpha=0.5)
ax1.set_yscale('log')

# Add value labels on base bars
for bar, val in zip(bars1, decreases_base):
    ax1.annotate(str(val), xy=(bar.get_x() + bar.get_width()/2, bar.get_height()),
                xytext=(0, 3), textcoords="offset points", ha='center', va='bottom', fontsize=8)

# Plot 2: Potential decrease as a function of subterm size for R1 and R8
sizes = range(3, 20)
r1_decreases = [rule_decrease("R1: mulVec_vecAdd", s, s, s)[2] for s in sizes]
r4_decreases = [rule_decrease("R4: smulVec_vecAdd", s, s, s)[2] for s in sizes]
r8_decreases = [rule_decrease("R8: dot_smulVec_left", s, s, s)[2] for s in sizes]

ax2.plot(list(sizes), r1_decreases, 'o-', label='R1 (decrease = a−1)', color='#2196F3', linewidth=2)
ax2.plot(list(sizes), r4_decreases, 's-', label='R4 (decrease = a−2)', color='#FF9800', linewidth=2)
ax2.plot(list(sizes), r8_decreases, '^-', label='R8 (decrease = c)', color='#4CAF50', linewidth=2)

ax2.set_xlabel('Subterm dp value (a = b = c)', fontsize=12)
ax2.set_ylabel('dp(LHS) − dp(RHS)', fontsize=12)
ax2.set_title('Decrease Growth by Rule Type', fontsize=14, fontweight='bold')
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_potential_decrease.png', dpi=150, bbox_inches='tight')
print("Saved viz_potential_decrease.png")
