import math

def collatz(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1

def verify_log_contraction(T, N: int, c: float) -> bool:
    for n in range(max(2, N), N + 10000):
        tn = T(n)
        if tn > 0 and n > 1:
            ratio = math.log(tn) / math.log(n)
            if ratio > c:
                print(f"Failed at n={n}: ratio={ratio:.6f} > c={c}")
                return False
    print(f"Log-contraction verified for n in [{N}, {N+10000}) with c={c}")
    return True

# The standard Collatz map does NOT satisfy log-contraction (odd steps increase log)
verify_log_contraction(collatz, 2, 0.99)
# But a toy contracting map does
verify_log_contraction(lambda n: max(1, n // 2 + 1), 3, 0.95)
