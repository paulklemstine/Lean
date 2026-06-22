import matplotlib.pyplot as plt
from collections import Counter

def mult_order(a, m):
    k, cur = 1, a % m
    while cur != 1:
        cur = (cur*a) % m; k += 1
    return k

p = 17
orders = [mult_order(a, p) for a in range(1, p)]
counts = Counter(orders)
xs = sorted(counts)
plt.bar([str(x) for x in xs], [counts[x] for x in xs], color='steelblue')
plt.axhline(0)
plt.xlabel('multiplicative order'); plt.ylabel('number of units')
plt.title(f'Element orders in (Z/{p}Z)^x  (max order = {p-1} = primitive roots)')
plt.tight_layout(); plt.savefig('order_histogram.png', dpi=150)
print('wrote order_histogram.png; max order =', max(orders))
