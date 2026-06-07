import matplotlib.pyplot as plt

fig, ax = plt.subplots(figsize=(10, 6))
for A in [2, 3, 4, 5, 10, 25]:
    L = 20
    Ms = list(range(L + 1))
    deficiencies = [1 - A ** (M - L) for M in Ms]
    ax.plot([M / L for M in Ms], deficiencies, 'o-', markersize=3, label=f'A={A}', linewidth=1.5)
ax.set_xlabel('Compression Ratio M/L')
ax.set_ylabel('Fraction Incompressible')
ax.set_title('Compression Deficiency vs Ratio')
ax.legend(loc='lower left')
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('compression.png', dpi=150)
plt.show()