"""
Scan schemes: honest uniqueness decoding, exact cost accounting,
the pigeonhole optimum, rigidity, and the 1/(2*eps) compression barrier.

Everything in this file is self-contained (standard library only) and mirrors,
numerically, the theorems of the accompanying paper:

  * triangle(k) = k(k+1)/2 is the cost of scanning every key of a bucket of size k;
  * total cost of a scheme = sum over buckets of triangle(bucket size)  (exact);
  * min over all schemes = triangleOpt(N, m)
        = r * triangle(q+1) + (m-r) * triangle(q),   q = N // m, r = N % m;
  * the residue scheme x |-> x mod m attains it;
  * a scheme is optimal iff every bucket has size q or q+1 (rigidity);
  * max over all schemes = triangle(N), attained by the one-bucket scheme;
  * mean cost >= (N/m + 1)/2, hence >= 1/(2*eps) whenever m <= eps*N.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from math import comb, factorial
from typing import Dict, Iterable, Iterator, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# 1. Triangular cost and the exact optimum
# ---------------------------------------------------------------------------


def triangle(k: int) -> int:
    """triangle(k) = 1 + 2 + ... + k = k(k+1)/2, the cost of scanning a bucket of size k."""
    return k * (k + 1) // 2


def triangle_opt(n: int, m: int) -> int:
    """The exact minimal total decoding cost of n keys in m buckets."""
    if m <= 0:
        raise ValueError("m must be positive")
    q, r = divmod(n, m)
    return r * triangle(q + 1) + (m - r) * triangle(q)


def balanced_profile(n: int, m: int) -> List[int]:
    """The balanced bucket-size profile: r buckets of size q+1, m-r of size q."""
    q, r = divmod(n, m)
    return [q + 1 if i < r else q for i in range(m)]


def tangent_slack(k: int, q: int) -> int:
    """triangle(k) - [triangle(q) + (q+1)(k-q)] = (k-q)(k-q-1)/2 >= 0."""
    d = k - q
    return d * (d - 1) // 2


# ---------------------------------------------------------------------------
# 2. Scan schemes: encoding, decoding, exact cost
# ---------------------------------------------------------------------------


class ScanScheme:
    """A scan scheme on keys 0..n-1 with m buckets, given by a bucket map."""

    def __init__(self, n: int, m: int, bucket_map: Sequence[int]) -> None:
        if len(bucket_map) != n:
            raise ValueError("bucket_map must have one entry per key")
        if any(not (0 <= b < m) for b in bucket_map):
            raise ValueError("bucket labels out of range")
        self.n: int = n
        self.m: int = m
        self.bucket: List[int] = list(bucket_map)

    def fiber(self, b: int) -> List[int]:
        """The keys stored in bucket b, in the order in which a scan visits them."""
        return [x for x in range(self.n) if self.bucket[x] == b]

    def scan_list(self, b: int) -> List[int]:
        """Alias for the fiber, emphasising that it is an ordered scan sequence."""
        return self.fiber(b)

    def idx(self, x: int) -> int:
        """The intra-bucket index of key x: its 0-based position in its own bucket."""
        return self.scan_list(self.bucket[x]).index(x)

    def decode_cost(self, x: int) -> int:
        """1-based number of comparisons a scan performs to find x."""
        return self.idx(x) + 1

    def encode(self, x: int) -> Tuple[int, int]:
        """The scan code of x: (bucket label, intra-bucket index)."""
        return (self.bucket[x], self.idx(x))

    def decode(self, code: Tuple[int, int]) -> int | None:
        """Read off the entry at the given index of the given bucket, if any."""
        b, i = code
        lst = self.scan_list(b)
        return lst[i] if 0 <= i < len(lst) else None

    def profile(self) -> List[int]:
        """The bucket-size profile of the scheme."""
        return [len(self.fiber(b)) for b in range(self.m)]

    def total_cost(self) -> int:
        """Total decoding cost, summed over all keys."""
        return sum(self.decode_cost(x) for x in range(self.n))

    def mean_cost(self) -> float:
        return self.total_cost() / self.n if self.n else 0.0


def mod_scheme(n: int, m: int) -> ScanScheme:
    """The residue scheme: key x is stored in bucket x mod m."""
    return ScanScheme(n, m, [x % m for x in range(n)])


def const_scheme(n: int, m: int) -> ScanScheme:
    """The degenerate scheme: every key in bucket 0."""
    return ScanScheme(n, m, [0] * n)


def all_schemes(n: int, m: int) -> Iterator[ScanScheme]:
    """Enumerate all m^n scan schemes (only for tiny n, m)."""
    for bm in product(range(m), repeat=n):
        yield ScanScheme(n, m, bm)


# ---------------------------------------------------------------------------
# 3. Checks corresponding to the theorems
# ---------------------------------------------------------------------------


def check_honest_decoding(scheme: ScanScheme) -> bool:
    """decode(encode(x)) = x, and (b,i) decodes to x iff (b,i) = encode(x)."""
    for x in range(scheme.n):
        if scheme.decode(scheme.encode(x)) != x:
            return False
    for b in range(scheme.m):
        for i in range(scheme.n + 1):
            y = scheme.decode((b, i))
            if y is not None and (b, i) != scheme.encode(y):
                return False
    return True


def check_cost_accounting(scheme: ScanScheme) -> bool:
    """Total cost equals the sum of triangular numbers of the bucket sizes."""
    return scheme.total_cost() == sum(triangle(k) for k in scheme.profile())


def is_balanced(scheme: ScanScheme) -> bool:
    q = scheme.n // scheme.m
    return all(q <= k <= q + 1 for k in scheme.profile())


def brute_force_extremes(n: int, m: int) -> Tuple[int, int]:
    costs = [s.total_cost() for s in all_schemes(n, m)]
    return min(costs), max(costs)


def achievable_costs(n: int, m: int) -> List[int]:
    return sorted({s.total_cost() for s in all_schemes(n, m)})


def partitions_into_at_most(n: int, m: int, cap: int | None = None) -> Iterator[List[int]]:
    """All multisets of at most m positive parts summing to n, in weakly decreasing order."""
    if cap is None:
        cap = n
    if n == 0:
        yield []
        return
    if m == 0:
        return
    for part in range(min(n, cap), 0, -1):
        for rest in partitions_into_at_most(n - part, m - 1, part):
            yield [part] + rest


def partition_costs(n: int, m: int) -> List[int]:
    """The predicted achievable cost set: sums of triangular numbers over size profiles."""
    return sorted({sum(triangle(k) for k in p) for p in partitions_into_at_most(n, m)})


def count_optimal_schemes(n: int, m: int) -> int:
    opt = triangle_opt(n, m)
    return sum(1 for s in all_schemes(n, m) if s.total_cost() == opt)


def predicted_optimal_count(n: int, m: int) -> int:
    """C(m, r) * multinomial(n; q+1 repeated r times, q repeated m-r times)."""
    q, r = divmod(n, m)
    multinomial = factorial(n) // (factorial(q + 1) ** r * factorial(q) ** (m - r))
    return comb(m, r) * multinomial


# ---------------------------------------------------------------------------
# 4. Reporting
# ---------------------------------------------------------------------------


def section(title: str) -> None:
    print()
    print("=" * 72)
    print(title)
    print("=" * 72)


def demo_honest_decoding() -> None:
    section("1. Honest uniqueness decoding and exact cost accounting")
    n, m = 12, 5
    s = mod_scheme(n, m)
    print(f"keys N = {n}, buckets m = {m}, scheme: x -> x mod {m}")
    print("bucket profile:", s.profile())
    print()
    print(" key | bucket | index | code    | decode(code) | cost")
    print("-----+--------+-------+---------+--------------+-----")
    for x in range(n):
        b, i = s.encode(x)
        print(f" {x:3d} | {b:6d} | {i:5d} | ({b},{i})   | {s.decode((b, i)):12d} | {s.decode_cost(x):4d}")
    print()
    print("every code decodes back to its own key, uniquely:", check_honest_decoding(s))
    print("total cost              :", s.total_cost())
    print("sum of triangle(sizes)  :", sum(triangle(k) for k in s.profile()))
    print("exact accounting holds  :", check_cost_accounting(s))


def demo_optimum() -> None:
    section("2. The exact pigeonhole optimum, verified by brute force")
    print(" N   m | triangleOpt | brute-force min | triangle(N) | brute-force max")
    print("-------+-------------+-----------------+-------------+----------------")
    for n, m in [(4, 2), (5, 3), (6, 3), (7, 3), (6, 4), (8, 3)]:
        lo, hi = brute_force_extremes(n, m)
        print(f"{n:3d} {m:3d} | {triangle_opt(n, m):11d} | {lo:15d} | {triangle(n):11d} | {hi:15d}")
    print()
    print("The residue scheme attains the optimum on the nose:")
    for n, m in [(10, 3), (17, 5), (100, 7), (1000, 32)]:
        s = mod_scheme(n, m)
        print(f"  N={n:5d} m={m:3d}: cost {s.total_cost():7d} = triangleOpt {triangle_opt(n, m):7d}"
              f"  ({s.total_cost() == triangle_opt(n, m)})")


def demo_tangent() -> None:
    section("3. Where the lower bound comes from: the integral tangent line")
    q = 4
    print(f"tangent to triangle at q = {q}:  triangle(q) + (q+1)(k-q) = {triangle(q)} + {q+1}(k-{q})")
    print()
    print("  k | triangle(k) | tangent value | slack (k-q)(k-q-1)/2")
    print("----+-------------+---------------+---------------------")
    for k in range(0, 10):
        tangent = triangle(q) + (q + 1) * (k - q)
        print(f" {k:2d} | {triangle(k):11d} | {tangent:13d} | {tangent_slack(k, q):19d}")
    print()
    print("slack vanishes exactly at k = q and k = q+1 -- this is the source of rigidity.")


def demo_rigidity() -> None:
    section("4. Rigidity: the optimal schemes are exactly the balanced ones")
    for n, m in [(5, 3), (6, 3), (7, 4)]:
        opt = triangle_opt(n, m)
        agree = all((s.total_cost() == opt) == is_balanced(s) for s in all_schemes(n, m))
        cnt = count_optimal_schemes(n, m)
        pred = predicted_optimal_count(n, m)
        print(f"N={n} m={m}: optimum {opt};  'optimal <=> balanced' holds: {agree};"
              f"  #optimal = {cnt}, formula C(m,r)*multinomial = {pred}"
              f"  ({'match' if cnt == pred else 'MISMATCH'})")
    print()
    print("(The counting formula is a conjecture; here it is confirmed by exhaustive search.)")


def demo_spectrum() -> None:
    section("5. The cost spectrum: every scheme lies in [triangleOpt(N,m), triangle(N)]")
    print("The window is correct and both endpoints are attained; but the achievable")
    print("set inside the window is NOT the full integer interval -- it is exactly the")
    print("set of sums of triangular numbers over partitions of N into at most m parts.")
    print()
    for n, m in [(5, 3), (6, 3), (6, 2), (7, 3)]:
        costs = achievable_costs(n, m)
        lo, hi = triangle_opt(n, m), triangle(n)
        inside = costs[0] == lo and costs[-1] == hi
        print(f"N={n} m={m}: achievable costs {costs}")
        print(f"          window [{lo}, {hi}] with both endpoints attained: {inside}")
        print(f"          gapless: {costs == list(range(lo, hi + 1))};"
              f"  equals partition prediction: {costs == partition_costs(n, m)}")


def demo_perfect_hashing() -> None:
    section("6. Perfect hashing and the failure analysis")
    n, m = 6, 6
    s = ScanScheme(n, m, list(range(n)))
    print(f"N={n}, m={m}, identity bucket map: all costs = 1?",
          all(s.decode_cost(x) == 1 for x in range(n)))
    print("bucket map injective?", len(set(s.bucket)) == n)
    print()
    n, m = 6, 4
    s = mod_scheme(n, m)
    print(f"N={n} > m={m}: some key must cost at least 2 ->",
          max(s.decode_cost(x) for x in range(n)) >= 2)
    print("a key whose cost is at least N/m (rounded up):")
    for x in range(n):
        if m * s.decode_cost(x) >= n:
            print(f"  key {x}: m * cost = {m * s.decode_cost(x)} >= N = {n}")
            break


def demo_epsilon_barrier() -> None:
    section("7. The 1/(2*eps) compression barrier")
    n = 4096
    print(f"N = {n} keys.  m <= eps*N buckets forces mean cost >= 1/(2*eps).")
    print()
    print("   eps |    m | 1/(2eps) | (N/m+1)/2 | residue-scheme mean cost")
    print("-------+------+----------+-----------+-------------------------")
    for eps in [1 / 2, 1 / 4, 1 / 8, 1 / 16, 1 / 32, 1 / 64]:
        m = int(eps * n)
        s = mod_scheme(n, m)
        print(f" {eps:6.4f} | {m:4d} | {1/(2*eps):8.3f} | {(n/m + 1)/2:9.3f} | {s.mean_cost():23.3f}")
    print()
    print("When m divides N the residue scheme meets the bound exactly:")
    for m in [2, 4, 8, 16]:
        s = mod_scheme(n, m)
        lhs = 2 * m * s.total_cost()
        rhs = n * (n + m)
        print(f"  m={m:3d}: 2*m*cost = {lhs} , N*(N+m) = {rhs}  ({lhs == rhs})")


def demo_symmetry() -> None:
    section("8. The cost depends only on the bucket-size partition")
    n, m = 8, 3
    base = ScanScheme(n, m, [0, 0, 0, 1, 1, 2, 2, 2])
    perm = [3, 1, 7, 0, 5, 2, 6, 4]  # a permutation of the keys
    relabel = {0: 2, 1: 0, 2: 1}  # a permutation of the bucket labels
    permuted = ScanScheme(n, m, [base.bucket[perm[x]] for x in range(n)])
    relabelled = ScanScheme(n, m, [relabel[b] for b in base.bucket])
    print("base profile      :", base.profile(), "cost", base.total_cost())
    print("key-permuted      :", permuted.profile(), "cost", permuted.total_cost())
    print("bucket-relabelled :", relabelled.profile(), "cost", relabelled.total_cost())
    print("all three equal   :",
          base.total_cost() == permuted.total_cost() == relabelled.total_cost())


def main() -> None:
    print("Scan schemes: honest decoding, exact costs, and the compression barrier")
    demo_honest_decoding()
    demo_optimum()
    demo_tangent()
    demo_rigidity()
    demo_spectrum()
    demo_perfect_hashing()
    demo_epsilon_barrier()
    demo_symmetry()
    print()
    print("All numerical checks completed.")


if __name__ == "__main__":
    main()
