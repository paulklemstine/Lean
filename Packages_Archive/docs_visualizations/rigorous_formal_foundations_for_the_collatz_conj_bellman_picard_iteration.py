import math

def bellman_operator(gamma: float, a: float, b: float, f: dict, domain: int) -> dict:
    f_new = {}
    for n in range(domain):
        even_val = f.get(n // 2, 0.0) + a
        odd_val = f.get((3 * n + 1) // 2, 0.0) + b
        f_new[n] = gamma * min(even_val, odd_val)
    return f_new

def picard_iterate(gamma=0.9, domain=50, iterations=40):
    a, b = -math.log(2), math.log(1.5)
    f = {n: 0.0 for n in range(domain)}
    for k in range(iterations):
        f = bellman_operator(gamma, a, b, f, domain)
    return f

result = picard_iterate()
for n in [0, 1, 2, 3, 5, 10, 27]:
    print(f"f*({n}) = {result[n]:.8f}")
