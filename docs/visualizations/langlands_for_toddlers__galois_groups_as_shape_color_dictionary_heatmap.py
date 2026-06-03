import matplotlib.pyplot as plt
import numpy as np

def jacobi_symbol(a, n):
    if n <= 0 or n % 2 == 0:
        return 0
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0

def kronecker_symbol(d, n):
    if n == 0:
        return 1 if abs(d) == 1 else 0
    if n == 1:
        return 1
    result = 1
    while n % 2 == 0:
        n //= 2
        if d % 2 == 0:
            return 0
        if d % 8 in (3, 5):
            result = -result
    if n == 1:
        return result
    return result * jacobi_symbol(d, n)

def sieve_primes(limit):
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, limit + 1, i):
                sieve[j] = False
    return [i for i in range(2, limit + 1) if sieve[i]]

def is_fundamental_discriminant(d):
    if d == 0:
        return False
    def is_squarefree(n):
        n = abs(n)
        if n == 0:
            return False
        p = 2
        while p * p <= n:
            if n % (p * p) == 0:
                return False
            p += 1
        return True
    if d % 4 == 1:
        return is_squarefree(d)
    if d % 4 == 0:
        m = d // 4
        return is_squarefree(m) and m % 4 != 1 and m != 0
    return False

disc_list = sorted([d for d in range(-30, 31) if is_fundamental_discriminant(d)])
primes = sieve_primes(50)

matrix = np.array([[kronecker_symbol(d, p) for p in primes] for d in disc_list])

fig, ax = plt.subplots(figsize=(14, 8))
cmap = plt.cm.RdYlGn
im = ax.imshow(matrix, cmap=cmap, aspect='auto', vmin=-1, vmax=1)

ax.set_xticks(range(len(primes)))
ax.set_xticklabels(primes, fontsize=7, rotation=45)
ax.set_yticks(range(len(disc_list)))
ax.set_yticklabels(disc_list, fontsize=7)

ax.set_xlabel('Prime p', fontsize=12)
ax.set_ylabel('Discriminant D', fontsize=12)
ax.set_title('Shape-Color Dictionary: Kronecker Symbol (D/p)', fontsize=14)

cbar = plt.colorbar(im, ax=ax, ticks=[-1, 0, 1])
cbar.set_ticklabels(['Inert (-1)', 'Ramified (0)', 'Split (+1)'])

plt.tight_layout()
plt.savefig('shape_color_heatmap.png', dpi=150, bbox_inches='tight')
plt.show()
print('Saved shape_color_heatmap.png')
