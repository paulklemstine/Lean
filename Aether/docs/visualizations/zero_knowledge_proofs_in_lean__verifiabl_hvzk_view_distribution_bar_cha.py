import matplotlib.pyplot as plt
from itertools import permutations

a, b = 0, 1
pairs = [(x, y) for x in range(3) for y in range(3) if x != y]
counts = {p: 0 for p in pairs}
for pi in permutations((0, 1, 2)):
    counts[(pi[a], pi[b])] += 1
labels = [str(p) for p in pairs]
plt.figure(figsize=(8, 4))
plt.bar(labels, [counts[p] / 6 for p in pairs], color='#10b981')
plt.axhline(1 / 6, color='red', linestyle='--', label='uniform 1/6')
plt.xlabel('opened view (pi(a), pi(b))')
plt.ylabel('probability')
plt.title('Real view distribution for true pair (a,b)=(0,1)')
plt.legend()
plt.tight_layout()
plt.savefig('hvzk_distribution.png', dpi=150)
print('saved hvzk_distribution.png')
