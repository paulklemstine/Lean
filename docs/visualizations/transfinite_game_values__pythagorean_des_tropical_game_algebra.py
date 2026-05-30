"""
Visualization: Tropical Game Algebra

Visualizes the tropical (min-plus) semiring structure on game values,
showing how game composition (tropical multiplication = addition)
and game choice (tropical addition = minimum) interact.
"""

import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Tropical Game Algebra: The Min-Plus Semiring', 
             fontsize=15, fontweight='bold')

# Plot 1: Tropical multiplication table (val component)
ax1 = axes[0]
n = 8
vals = np.arange(n)
mul_table = np.zeros((n, n), dtype=int)
for i in range(n):
    for j in range(n):
        mul_table[i, j] = i + j  # tropical mul = ordinary add

im1 = ax1.imshow(mul_table, cmap='YlOrRd', aspect='equal')
ax1.set_xlabel('b.val', fontsize=11)
ax1.set_ylabel('a.val', fontsize=11)
ax1.set_title('Tropical Multiplication\n(a ⊙ b).val = a.val + b.val', fontsize=12)
ax1.set_xticks(range(n))
ax1.set_yticks(range(n))

for i in range(n):
    for j in range(n):
        ax1.text(j, i, str(mul_table[i, j]), ha='center', va='center', 
                fontsize=8, color='black' if mul_table[i,j] < 10 else 'white')

plt.colorbar(im1, ax=ax1, shrink=0.8)

# Plot 2: Tropical addition table (val component)
ax2 = axes[1]
add_table = np.zeros((n, n), dtype=int)
for i in range(n):
    for j in range(n):
        add_table[i, j] = min(i, j)  # tropical add = min

im2 = ax2.imshow(add_table, cmap='YlGnBu', aspect='equal')
ax2.set_xlabel('b.val', fontsize=11)
ax2.set_ylabel('a.val', fontsize=11)
ax2.set_title('Tropical Addition\n(a ⊕ b).val = min(a.val, b.val)', fontsize=12)
ax2.set_xticks(range(n))
ax2.set_yticks(range(n))

for i in range(n):
    for j in range(n):
        ax2.text(j, i, str(add_table[i, j]), ha='center', va='center', 
                fontsize=8)

plt.colorbar(im2, ax=ax2, shrink=0.8)

# Plot 3: Distributivity visualization
ax3 = axes[2]

# Show that (a⊕b)⊙c = (a⊙c)⊕(b⊙c) when a.val ≤ b.val
a_vals = range(0, 6)
b_vals = range(0, 6)
c_val = 2  # fixed c

lhs_data = []
rhs_data = []
labels = []

for a in a_vals:
    for b in b_vals:
        if a <= b:  # condition for distributivity
            # LHS: (a⊕b)⊙c = min(a,b) + c = a + c
            lhs = min(a, b) + c_val
            # RHS: min(a+c, b+c) = a + c (since a ≤ b)
            rhs = min(a + c_val, b + c_val)
            lhs_data.append(lhs)
            rhs_data.append(rhs)
            labels.append(f'({a},{b})')

x = range(len(lhs_data))
ax3.bar([i - 0.15 for i in x], lhs_data, width=0.3, color='#3498db', 
        label='(a⊕b)⊙c', alpha=0.8)
ax3.bar([i + 0.15 for i in x], rhs_data, width=0.3, color='#e74c3c', 
        label='(a⊙c)⊕(b⊙c)', alpha=0.8)

ax3.set_xlabel('(a.val, b.val) pairs', fontsize=10)
ax3.set_ylabel('Result value', fontsize=11)
ax3.set_title(f'Distributivity Verification (c.val={c_val})\n'
              f'a.val ≤ b.val guaranteed', fontsize=12)
ax3.set_xticks(x)
ax3.set_xticklabels(labels, rotation=45, fontsize=7)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_tropical.png', dpi=150, bbox_inches='tight')
print("Saved visualization to viz_tropical.png")
