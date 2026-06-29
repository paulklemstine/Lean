import matplotlib.pyplot as plt

def is_prime(p: int) -> bool:
    if p < 2: return False
    for d in range(2, int(p**0.5) + 1):
        if p % d == 0: return False
    return True

def order(b: int, p: int) -> int:
    val, k = b % p, 1
    while val != 1:
        val = (val * b) % p; k += 1
    return k

def fermat_descent_plot(b: int = 2, p_max: int = 500) -> None:
    primes = [p for p in range(3, p_max) if is_prime(p) and b % p != 0]
    xs = [p - 1 for p in primes]
    ys = [order(b, p) for p in primes]
    fig, ax = plt.subplots(figsize=(10, 8))
    ax.scatter(xs, ys, s=14, alpha=0.7, label='entryPoint(p)')
    lim = max(xs)
    ax.plot([0, lim], [0, lim], 'r--', label='entryPoint = p-1 (primitive root)')
    ax.set_xlabel('p - 1')
    ax.set_ylabel('entryPoint(p) = order(b mod p)')
    ax.set_title(f'Fermat descent for {b}^n - 1: entryPoint(p) divides p - 1')
    ax.legend()
    plt.tight_layout()
    plt.savefig('fermat_descent.png', dpi=150)
    print('saved fermat_descent.png')

if __name__ == '__main__':
    fermat_descent_plot()
