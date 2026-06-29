import matplotlib.pyplot as plt
from math import gcd

def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def lcm(a: int, b: int) -> int:
    return a // gcd(a, b) * b

def divides_fib(p: int, m: int) -> bool:
    return fib(m) % p == 0

M = 60
primes = [2, 3, 5, 11, 13]          # entry points 3,4,5,10,7
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

for row, p in enumerate(primes):
    xs = [m for m in range(1, M + 1) if divides_fib(p, m)]
    ax1.scatter(xs, [row] * len(xs), s=40)
ax1.set_yticks(range(len(primes)))
ax1.set_yticklabels([f'p={p}' for p in primes])
ax1.set_xlabel('index m'); ax1.set_title('Apparition calendars: p | F(m)')

p, q = 2, 11                         # e(p)=3, e(q)=10, lcm=30
xp = [m for m in range(1, M + 1) if divides_fib(p, m)]
xq = [m for m in range(1, M + 1) if divides_fib(q, m)]
both = [m for m in range(1, M + 1) if divides_fib(p, m) and divides_fib(q, m)]
ax2.scatter(xp, [0] * len(xp), s=40, label=f'{p} | F(m)')
ax2.scatter(xq, [1] * len(xq), s=40, label=f'{q} | F(m)')
ax2.scatter(both, [0.5] * len(both), s=120, marker='*',
            label=f'both (mult. of lcm={lcm(3,10)})')
ax2.set_xlabel('index m'); ax2.set_title('Join law: simultaneous apparition')
ax2.legend(loc='upper right')

plt.tight_layout(); plt.savefig('apparition_calendars.png', dpi=150)
print('wrote apparition_calendars.png')
