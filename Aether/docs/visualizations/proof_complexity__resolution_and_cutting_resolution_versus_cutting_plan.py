import matplotlib.pyplot as plt

ns = list(range(2, 41))
cutting_planes = [(n + 1) + n for n in ns]      # O(n)
resolution = [2 ** (0.2 * n) for n in ns]       # 2^{Omega(n)}

plt.figure(figsize=(8, 5))
plt.plot(ns, cutting_planes, 'o-', label='Cutting planes: O(n) steps')
plt.plot(ns, resolution, 's-', label='Resolution: 2^(0.2 n) (lower bound)')
plt.yscale('log')
plt.xlabel('n (holes; n+1 pigeons)')
plt.ylabel('refutation size (log scale)')
plt.title('Pigeonhole principle: resolution vs cutting planes')
plt.legend(); plt.grid(True, which='both', alpha=0.3)
plt.tight_layout(); plt.savefig('separation.png', dpi=150)
print('wrote separation.png')
