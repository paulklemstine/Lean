import matplotlib.pyplot as plt

n_values = [0, 1, 2, 3, 4, 5, 6]
preorders = [1, 1, 4, 29, 355, 6942, 209527]   # OEIS A000798

plt.figure(figsize=(7, 4.5))
plt.semilogy(n_values, preorders, 'o-', color='#34508a',
             label='topologies = preorders on n points (A000798)')
for x, y in zip(n_values, preorders):
    plt.annotate(str(y), (x, y), textcoords='offset points', xytext=(0, 8),
                 ha='center', fontsize=9)
plt.xlabel('n = number of points')
plt.ylabel('count (log scale)')
plt.title('Finite topologies = specialization preorders (exact bijection)')
plt.grid(True, which='both', alpha=0.3)
plt.legend()
plt.tight_layout()
plt.savefig('topology_count_growth.png', dpi=150)
print('wrote topology_count_growth.png')
