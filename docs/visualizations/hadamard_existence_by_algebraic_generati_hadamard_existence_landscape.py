#!/usr/bin/env python3
"""
Visualization 2: Hadamard Existence Landscape

Shows which orders have certified Hadamard matrices under our construction
calculus (Sylvester + Paley + tensor), compared to the admissible orders
(multiples of 4, plus 1 and 2). The gap between generated and admissible
orders reveals where the Hadamard conjecture remains unresolved.
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def hadamard_matrix(k):
    H = np.array([[1]])
    for _ in range(k):
        H = np.block([[H, H], [H, -H]])
    return H

def legendre(a, p):
    a = a % p
    if a == 0: return 0
    r = pow(a, (p-1)//2, p)
    return r if r <= 1 else r - p

def paley1(q):
    if not is_prime(q) or q % 4 != 3: return None
    n = q + 1
    H = np.zeros((n,n), dtype=int)
    H[0,:] = 1; H[:,0] = 1
    for i in range(q):
        for j in range(q):
            H[i+1,j+1] = -1 if i==j else legendre(i-j, q)
    if np.array_equal(H@H.T, n*np.eye(n,dtype=int)): return H
    return None

def paley2(q):
    if not is_prime(q) or q % 4 != 1: return None
    Q = np.zeros((q,q),dtype=int)
    for i in range(q):
        for j in range(q):
            Q[i][j] = legendre(i-j,q)
    nc = q+1
    C = np.zeros((nc,nc),dtype=int)
    C[0,1:]=1; C[1:,0]=1; C[1:,1:]=Q
    I = np.eye(nc,dtype=int)
    H = np.block([[C+I, C-I],[C-I, -(C+I)]])
    if np.array_equal(H@H.T, H.shape[0]*np.eye(H.shape[0],dtype=int)): return H
    return None

# Build cache
_cache = {}
def construct(n):
    if n in _cache: return _cache[n]
    r = _construct(n)
    _cache[n] = r
    return r

def _construct(n):
    if n <= 0: return None
    if n == 1 or n == 2: return "base"
    if n > 2 and n % 4 != 0: return None
    m = n; k = 0
    while m > 1 and m % 2 == 0: m //= 2; k += 1
    if m == 1: return "sylvester"
    q = n - 1
    if is_prime(q) and q % 4 == 3 and paley1(q) is not None: return "paley1"
    if n % 2 == 0:
        q2 = n//2 - 1
        if q2 > 0 and is_prime(q2) and q2 % 4 == 1 and paley2(q2) is not None: return "paley2"
    for d in range(2, int(n**0.5)+1):
        if n % d == 0:
            c1 = construct(d); c2 = construct(n//d)
            if c1 and c2: return "tensor"
    return None

B = 200
orders = list(range(1, B+1))

inadmissible = [n for n in orders if n > 2 and n % 4 != 0]
admissible = [n for n in orders if n <= 2 or n % 4 == 0]
generated = [n for n in admissible if construct(n)]
not_generated = [n for n in admissible if not construct(n)]

# Plot
fig, ax = plt.subplots(figsize=(16, 3))

for n in inadmissible:
    ax.bar(n, 1, color='#e0e0e0', width=0.8)
for n in not_generated:
    ax.bar(n, 1, color='#e74c3c', width=0.8)
for n in generated:
    method = construct(n)
    colors = {'base': '#2ecc71', 'sylvester': '#3498db', 'paley1': '#9b59b6',
              'paley2': '#f39c12', 'tensor': '#1abc9c'}
    ax.bar(n, 1, color=colors.get(method, '#1abc9c'), width=0.8)

ax.set_xlim(0, B+1)
ax.set_ylim(0, 1.5)
ax.set_yticks([])
ax.set_xlabel('Order n', fontsize=12)
ax.set_title(f'Hadamard Existence Landscape (n ≤ {B})', fontsize=14, fontweight='bold')

patches = [
    mpatches.Patch(color='#e0e0e0', label='Inadmissible (4∤n, n>2)'),
    mpatches.Patch(color='#2ecc71', label='Base seed (n=1,2)'),
    mpatches.Patch(color='#3498db', label='Sylvester (2^k)'),
    mpatches.Patch(color='#9b59b6', label='Paley Type I'),
    mpatches.Patch(color='#f39c12', label='Paley Type II'),
    mpatches.Patch(color='#1abc9c', label='Tensor product'),
    mpatches.Patch(color='#e74c3c', label='Open / not generated'),
]
ax.legend(handles=patches, loc='upper right', fontsize=8, ncol=4)

plt.tight_layout()
plt.savefig('hadamard_existence.png', dpi=150, bbox_inches='tight')
print(f"Saved hadamard_existence.png")
print(f"Generated: {len(generated)}/{len(admissible)} admissible orders")
print(f"Not generated: {not_generated}")
