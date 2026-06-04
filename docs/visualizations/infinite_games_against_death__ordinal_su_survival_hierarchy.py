import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

fig, ax = plt.subplots(figsize=(10, 6))
ks = list(range(1, 21))
ax.bar(ks, ks, color='steelblue', alpha=0.7, label='bounded(k)')
ax.axhline(y=20, color='crimson', linestyle='--', linewidth=2, label='\u03c9 (full profile)')
ax.set_xlabel('Bound k')
ax.set_ylabel('Survival Ordinal')
ax.set_title('Bounded Profiles vs \u03c9')
ax.legend()
plt.tight_layout()
plt.savefig('survival_hierarchy.png', dpi=150)
plt.close()