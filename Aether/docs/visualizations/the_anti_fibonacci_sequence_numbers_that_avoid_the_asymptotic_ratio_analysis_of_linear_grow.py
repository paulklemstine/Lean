from typing import List, Tuple


def anti_fib(k: int) -> int:
    return (3 * k + 2) // 2


def growth_table(indices: List[int]) -> List[Tuple[int, int, float, float]]:
    """Return (n, A(n), A(n)/n, A(n+1)/A(n)) for each requested index n."""
    rows: List[Tuple[int, int, float, float]] = []
    for n in indices:
        a_n = anti_fib(n)
        rows.append((n, a_n, a_n / n, anti_fib(n + 1) / a_n))
    return rows


if __name__ == "__main__":
    phi = (1 + 5 ** 0.5) / 2
    print(f"golden ratio phi = {phi:.6f} (Fibonacci limit, for contrast)")
    print(f"{'n':>9} {'A(n)':>10} {'A(n)/n':>10} {'A(n+1)/A(n)':>13}")
    for n, a_n, lin, con in growth_table([10, 100, 1000, 10000, 100000, 1000000]):
        print(f"{n:>9} {a_n:>10} {lin:>10.6f} {con:>13.6f}")
    print("A(n)/n -> 3/2 (linear growth); A(n+1)/A(n) -> 1 (avoids the golden ratio)")
