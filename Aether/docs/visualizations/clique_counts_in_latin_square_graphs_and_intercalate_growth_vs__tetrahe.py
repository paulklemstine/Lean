from math import comb
import matplotlib.pyplot as plt


def intercalates_cyclic(n: int) -> int:
    M = lambda i, j: (i + j) % n
    return sum(
        1
        for i in range(n) for ip in range(i + 1, n)
        for j in range(n) for jp in range(j + 1, n)
        if M(i, j) == M(ip, jp) and M(i, jp) == M(ip, j)
    )


orders = list(range(3, 10))
bulk = [3 * n * comb(n, 4) for n in orders]
inter = [intercalates_cyclic(n) for n in orders]
total = [b + i for b, i in zip(bulk, inter)]

plt.figure(figsize=(8, 5))
plt.plot(orders, bulk, 'o-', label='line bulk 3n*C(n,4)')
plt.plot(orders, inter, 's-', label='intercalates I(M)')
plt.plot(orders, total, '^-', label='total K4 = bulk + I(M)')
plt.xlabel('order n')
plt.ylabel('count')
plt.yscale('log')
plt.title('Tetrahedra in cyclic Latin square graphs')
plt.legend()
plt.tight_layout()
plt.savefig('tetrahedra_growth.png', dpi=150)
print('saved tetrahedra_growth.png')
