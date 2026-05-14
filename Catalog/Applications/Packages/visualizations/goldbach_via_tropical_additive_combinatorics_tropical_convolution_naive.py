def tropical_convolution(f, g, n):
    """Min-plus convolution: inf_{a+b=n} (f(a) + g(b)). None = infinity."""
    result = None
    for a in range(n + 1):
        fa, gb = f(a), g(n - a)
        if fa is not None and gb is not None:
            val = fa + gb
            if result is None or val < result:
                result = val
    return result

# Example: prime indicator self-convolution (Goldbach)
def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0: return False
    return all(n % i != 0 for i in range(3, int(n**0.5)+1, 2))

prime_cost = lambda n: 0 if is_prime(n) else None

for n in range(4, 51, 2):
    gt = tropical_convolution(prime_cost, prime_cost, n)
    print(f"goldbachTrop({n}) = {gt if gt is not None else '⊤'}")
