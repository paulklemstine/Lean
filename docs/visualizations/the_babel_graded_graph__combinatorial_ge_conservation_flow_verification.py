import matplotlib.pyplot as plt
from math import comb

def shell_size(A, L, k):
    return comb(L, k) * (A - 1) ** k

A, L = 4, 20
ks = list(range(L))
up = [shell_size(A,L,k) * (L-k) * (A-1) for k in ks]
down = [shell_size(A,L,k+1) * (k+1) for k in ks]
plt.figure(figsize=(12,6))
plt.plot(ks, up, 'b-o', ms=4, label='Up flow')
plt.plot(ks, down, 'r--s', ms=4, label='Down flow')
plt.yscale('log')
plt.xlabel('Shell k')
plt.ylabel('Total flow')
plt.title('Conservation Law: Up flow = Down flow')
plt.legend()
plt.grid(alpha=0.3)
plt.tight_layout()
plt.savefig('conservation_flow.png', dpi=150)
print('Saved conservation_flow.png')