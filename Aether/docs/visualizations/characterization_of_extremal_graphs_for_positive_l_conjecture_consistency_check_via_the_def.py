"""Demo 2: falsification of the conjectured extremal count T(n)=(n-2)^2/2."""
from __future__ import annotations

def edges_join(k: int) -> int:
    """Exact edge count of H(k): 6k^2."""
    return 6 * k * k

def threshold(n: int) -> int:
    """Conjectured extremal count T(n) = (n^2-3n)/2 - ceil(n/2) + 2."""
    return (n * n - 3 * n) // 2 - (-(-n // 2)) + 2

def report(k: int) -> None:
    n = 4 * k
    e, t = edges_join(k), threshold(n)
    complete = n * (n - 1) // 2
    print(f"k={k:2d} n={n:3d}: |E(H)|={e:5d} (missing {complete - e:5d}=Theta(n^2)),  "
          f"T(n)={t:5d} (missing {complete - t:4d}=Theta(n)),  equal? {e == t}")

if __name__ == "__main__":
    print("H(k) misses quadratically many edges; T(n) misses only linearly many:")
    for k in range(1, 11):
        report(k)
