import matplotlib.pyplot as plt
from math import gcd

def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def lcm(a: int, b: int) -> int:
    return a // gcd(a, b) * b

p, q, ep, eq = 2, 11, 3, 10
L = lcm(ep, eq)
Ns = list(range(10, 1001, 10))
emp = []
count = 0
m = 0
for N in Ns:
    while m < N:
        m += 1
        if fib(m) % p == 0 and fib(m) % q == 0:
            count += 1
    emp.append(count / N)
plt.figure(figsize=(9, 5))
plt.plot(Ns, emp, label='empirical joint density')
plt.axhline(1 / L, color='red', ls='--', label=f'1/lcm = 1/{L}')
plt.xlabel('N'); plt.ylabel('density'); plt.legend()
plt.title('Joint apparition density -> 1 / lcm(e(p), e(q))')
plt.tight_layout(); plt.savefig('apparition_density.png', dpi=150)
print('wrote apparition_density.png')
