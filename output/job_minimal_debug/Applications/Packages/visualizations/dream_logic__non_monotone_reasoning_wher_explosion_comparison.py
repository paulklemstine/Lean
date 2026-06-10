import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# Classical logic
classical_vals = ['T', 'F']
classical_contr = ['F', 'F']  # T∧¬T=F, F∧¬F=F
classical_desig = [False, False]

colors_c = ['#f44336', '#f44336']
ax1.bar(classical_vals, [1, 1], color=colors_c, edgecolor='black', linewidth=2)
ax1.set_title('Classical Logic\np ∧ ¬p', fontsize=14, fontweight='bold')
ax1.set_ylabel('', fontsize=12)
ax1.set_yticks([])
for i, (v, c) in enumerate(zip(classical_vals, classical_contr)):
    ax1.text(i, 0.5, f'p={v}\np∧¬p={c}\nNot designated', ha='center', va='center',
            fontsize=11, fontweight='bold', color='white')
ax1.set_xlabel('No contradictions possible → Explosion holds vacuously', fontsize=10)

# Belnap logic
belnap_vals = ['F', 'N', 'B', 'T']
belnap_contr = ['F', 'N', 'B', 'F']  # p∧¬p for each
belnap_desig = [False, False, True, False]

colors_b = ['#f44336' if not d else '#4CAF50' for d in belnap_desig]
ax2.bar(belnap_vals, [1, 1, 1, 1], color=colors_b, edgecolor='black', linewidth=2)
ax2.set_title('Belnap Logic (FOUR)\np ∧ ¬p', fontsize=14, fontweight='bold')
ax2.set_yticks([])
for i, (v, c, d) in enumerate(zip(belnap_vals, belnap_contr, belnap_desig)):
    status = 'DESIGNATED!' if d else 'Not designated'
    ax2.text(i, 0.5, f'p={v}\np∧¬p={c}\n{status}', ha='center', va='center',
            fontsize=10, fontweight='bold', color='white')
ax2.set_xlabel('B∧¬B = B is designated → Explosion FAILS', fontsize=10)

plt.suptitle('Explosion Principle: Classical vs Paraconsistent', fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('explosion_comparison.png', dpi=150, bbox_inches='tight')
print('Saved explosion_comparison.png')