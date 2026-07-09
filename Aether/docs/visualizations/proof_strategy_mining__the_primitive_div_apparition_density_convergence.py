import matplotlib.pyplot as plt

def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

# Empirical apparition density converging to 1/rank, illustrating apparition_count.
p, rank = 11, 10
Ns = list(range(1, 201))
emp = []
count = 0
for N in Ns:
    if fib(N) % p == 0:
        count += 1
    emp.append(count / N)

plt.figure(figsize=(10, 5))
plt.plot(Ns, emp, label='empirical density of {n : 11 | F_n}')
plt.axhline(1 / rank, color='red', linestyle='--', label=f'predicted 1/{rank}')
plt.xlabel('N')
plt.ylabel('density up to N')
plt.title('Apparition density of p=11 in Fibonacci -> 1/10')
plt.legend()
plt.tight_layout()
plt.savefig('apparition_density.png', dpi=150)
print('saved apparition_density.png')
