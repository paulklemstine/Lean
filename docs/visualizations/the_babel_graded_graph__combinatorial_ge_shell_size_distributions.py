import matplotlib.pyplot as plt
from math import comb

def shell_size(A, L, k):
    return comb(L, k) * (A - 1) ** k

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Shell Size Distributions', fontsize=16)
for ax, (A, L, title) in zip(axes.flat, [(2,20,'Binary A=2,L=20'), (4,16,'Quaternary A=4,L=16'), (10,12,'Decimal A=10,L=12'), (25,10,'Borges A=25,L=10')]):
    ks = list(range(L+1))
    sizes = [shell_size(A,L,k) for k in ks]
    total = sum(sizes)
    ax.bar(ks, [s/total for s in sizes], color='steelblue')
    ax.set_title(title)
    ax.set_xlabel('Distance k')
    ax.set_ylabel('Fraction')
plt.tight_layout()
plt.savefig('shell_distributions.png', dpi=150)
print('Saved shell_distributions.png')