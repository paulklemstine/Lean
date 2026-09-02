"""
The Multinomial Erasure Ledger — numerical demonstrations.

Sorting a multiset of n items whose key multiplicities are m_1, ..., m_r collapses

    n! / (m_1! * ... * m_r!)

distinguishable inputs onto one output, so it erases E = log2(n!/prod m_i!) bits and
dissipates at least W = kT * ln(n!/prod m_i!) joules (Landauer).

This script verifies, by brute force on small instances and by exact integer arithmetic
on large ones:

  1. Orbit-stabiliser:      |Rearr(w)| * prod_i m_i! = n!
  2. Multinomial count:     |Rearr(w)| = n! / prod_i m_i!
  3. Conservation law:      log2(n!) = E + sum_i log2(m_i!)
  4. Shannon ceiling:       E <= n*H(p), strictly when two distinct keys occur
  5. Alphabet ceiling:      E <= n*log2(r)
  6. Coarsening law:        merging keys can only decrease E
  7. Merge ledger:          E(A|B) = E(A) + E(B) + log2(C(n+n', n))
  8. Query complexity:      d >= ceil(log_q(n!/prod m_i!)), attained
  9. Landauer heat at room temperature.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
from collections import Counter
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

# Boltzmann constant (J/K) and room temperature (K).
K_B: float = 1.380649e-23
T_ROOM: float = 300.0


# ----------------------------------------------------------------------------
# Core quantities
# ----------------------------------------------------------------------------
def multiplicities(word: Sequence[object]) -> Dict[object, int]:
    """Multiplicity vector m_i = number of slots carrying key i."""
    return dict(Counter(word))


def multinomial(mults: Iterable[int]) -> int:
    """Exact multinomial coefficient n!/prod m_i! where n = sum m_i."""
    ms: List[int] = list(mults)
    total: int = sum(ms)
    result: int = math.factorial(total)
    for m in ms:
        result //= math.factorial(m)
    return result


def rearrangements(word: Sequence[object]) -> List[Tuple[object, ...]]:
    """All distinguishable inputs: the orbit of the key word under slot permutations."""
    return sorted(set(itertools.permutations(word)), key=repr)


def info_erased(word: Sequence[object]) -> float:
    """Erased information E = log2(n!/prod m_i!) in bits."""
    return math.log2(multinomial(multiplicities(word).values()))


def shannon_entropy(mults: Iterable[int]) -> float:
    """Shannon entropy H(p) of the empirical key distribution p_i = m_i/n, in bits."""
    ms: List[int] = [m for m in mults if m > 0]
    n: int = sum(ms)
    return -sum((m / n) * math.log2(m / n) for m in ms)


def entropy_budget(word: Sequence[object]) -> float:
    """The Shannon ceiling n*H(p) = sum_i m_i log2(n/m_i), in bits."""
    ms: List[int] = list(multiplicities(word).values())
    n: int = sum(ms)
    return sum(m * math.log2(n / m) for m in ms)


def landauer_work(word: Sequence[object], kT: float = K_B * T_ROOM) -> float:
    """Minimum dissipated heat W = kT * ln(n!/prod m_i!) in joules."""
    return kT * math.log(multinomial(multiplicities(word).values()))


def query_lower_bound(word: Sequence[object], q: int = 2) -> int:
    """Exact radix-q query complexity ceil(log_q(n!/prod m_i!))."""
    count: int = multinomial(multiplicities(word).values())
    d: int = 0
    while q**d < count:
        d += 1
    return d


def coarsen(word: Sequence[object], g: Callable[[object], object]) -> List[object]:
    """Merge keys along the map g (post-composition of the key word)."""
    return [g(k) for k in word]


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------
def demo_orbit_stabiliser() -> None:
    print("=" * 78)
    print("1-3.  ORBIT-STABILISER, MULTINOMIAL COUNT, CONSERVATION LAW")
    print("=" * 78)
    words: List[str] = ["AABB", "AAAB", "ABCD", "AAAA", "AABBC", "AABBBCC"]
    header = f"{'word':<9}{'n':>3}{'|Rearr|':>9}{'n!/prod':>10}{'orbit*stab':>12}{'n!':>9}"
    print(header)
    print("-" * 78)
    for w in words:
        ms = multiplicities(w)
        n = len(w)
        brute = len(rearrangements(w)) if n <= 8 else multinomial(ms.values())
        closed = multinomial(ms.values())
        stab = math.prod(math.factorial(m) for m in ms.values())
        assert brute == closed, "multinomial count failed"
        assert closed * stab == math.factorial(n), "orbit-stabiliser failed"
        print(f"{w:<9}{n:>3}{brute:>9}{closed:>10}{closed * stab:>12}{math.factorial(n):>9}")

    print()
    print("Conservation:  log2(n!) = E + sum_i log2(m_i!)")
    print(f"{'word':<9}{'log2(n!)':>11}{'E':>10}{'sum log2(m!)':>15}{'residual':>12}")
    print("-" * 78)
    for w in words:
        ms = multiplicities(w)
        base = math.log2(math.factorial(len(w)))
        e = info_erased(w)
        inner = sum(math.log2(math.factorial(m)) for m in ms.values())
        assert abs(base - (e + inner)) < 1e-9, "conservation law failed"
        print(f"{w:<9}{base:>11.4f}{e:>10.4f}{inner:>15.4f}{base - e - inner:>12.1e}")
    print()


def demo_shannon_ceiling() -> None:
    print("=" * 78)
    print("4-5.  SHANNON CEILING  E <= n*H(p)  (strict when mixed)  AND ALPHABET CEILING")
    print("=" * 78)
    words: List[str] = ["AABB", "AAAB", "ABCD", "AAAA", "AABBC", "AABBBCC", "A" * 10 + "B" * 2]
    print(f"{'word':<14}{'n':>3}{'r':>3}{'H(p)':>8}{'E':>10}{'n*H(p)':>10}{'gap':>9}{'n log2 r':>10}")
    print("-" * 78)
    for w in words:
        ms = list(multiplicities(w).values())
        n, r = len(w), len(ms)
        e = info_erased(w)
        ceil_shannon = entropy_budget(w)
        ceil_alpha = n * math.log2(r)
        assert e <= ceil_shannon + 1e-9, "Shannon ceiling violated"
        assert e <= ceil_alpha + 1e-9, "alphabet ceiling violated"
        if sum(1 for m in ms if m > 0) >= 2:
            assert e < ceil_shannon - 1e-9, "strictness failed"
        print(
            f"{w:<14}{n:>3}{r:>3}{shannon_entropy(ms):>8.4f}{e:>10.4f}"
            f"{ceil_shannon:>10.4f}{ceil_shannon - e:>9.4f}{ceil_alpha:>10.4f}"
        )
    print()
    print("Binary corollary  log2 C(a+b,a) <= a log2((a+b)/a) + b log2((a+b)/b):")
    print(f"{'(a,b)':<12}{'log2 C':>12}{'binary bound':>15}{'gap':>10}")
    print("-" * 78)
    for a, b in [(1, 1), (2, 2), (3, 7), (10, 10), (50, 950), (500, 500)]:
        lhs = math.log2(math.comb(a + b, a))
        rhs = a * math.log2((a + b) / a) + b * math.log2((a + b) / b)
        assert lhs <= rhs + 1e-9
        print(f"{str((a, b)):<12}{lhs:>12.4f}{rhs:>15.4f}{rhs - lhs:>10.4f}")
    print()


def demo_coarsening() -> None:
    print("=" * 78)
    print("6.  DATA-PROCESSING LAW: MERGING KEYS CAN ONLY DECREASE ERASURE")
    print("=" * 78)
    word: str = "AABBC"
    merges: List[Tuple[str, Callable[[object], object]]] = [
        ("identity", lambda k: k),
        ("C -> B", lambda k: "B" if k == "C" else k),
        ("B,C -> A", lambda k: "A"),
    ]
    print(f"{'coarsening':<12}{'image word':<12}{'|Rearr|':>9}{'E (bits)':>11}{'monotone':>10}")
    print("-" * 78)
    previous: float = math.inf
    for name, g in merges:
        image = coarsen(word, g)
        e = info_erased(image)
        count = len(rearrangements(image))
        assert e <= previous + 1e-9, "data-processing inequality violated"
        previous = e
        print(f"{name:<12}{''.join(map(str, image)):<12}{count:>9}{e:>11.4f}{'yes':>10}")
    print()


def demo_merge_ledger() -> None:
    print("=" * 78)
    print("7.  MERGE LEDGER:  E(A|B) = E(A) + E(B) + log2 C(n+n', n)")
    print("=" * 78)
    pairs: List[Tuple[str, str]] = [("AA", "xyz"), ("AABB", "xxy"), ("ABC", "xxxx")]
    print(
        f"{'A':<8}{'B':<8}{'E(A)':>9}{'E(B)':>9}{'merge':>9}{'sum':>10}{'E(A|B)':>10}{'ok':>5}"
    )
    print("-" * 78)
    for a, b in pairs:
        joint = list(a) + [s.upper() + "'" for s in b]  # disjoint key alphabets
        ea, eb, ej = info_erased(a), info_erased(b), info_erased(joint)
        merge_term = math.log2(math.comb(len(a) + len(b), len(a)))
        assert abs(ej - (ea + eb + merge_term)) < 1e-9, "merge ledger failed"
        assert merge_term >= 0.0
        print(
            f"{a:<8}{b:<8}{ea:>9.4f}{eb:>9.4f}{merge_term:>9.4f}"
            f"{ea + eb + merge_term:>10.4f}{ej:>10.4f}{'yes':>5}"
        )
    print()


def demo_complexity_and_heat() -> None:
    print("=" * 78)
    print("8-9.  QUERY COMPLEXITY AND LANDAUER HEAT AT ROOM TEMPERATURE (kT, T = 300 K)")
    print("=" * 78)
    words: List[str] = ["AABB", "ABCD", "AABBC", "A" * 8 + "B" * 8, "ABCDEFGH"]
    print(
        f"{'word':<18}{'|Rearr|':>10}{'d (binary)':>12}{'d baseline':>12}"
        f"{'E (bits)':>10}{'W (J)':>13}"
    )
    print("-" * 78)
    for w in words:
        count = multinomial(multiplicities(w).values())
        d = query_lower_bound(w, 2)
        d_base = math.ceil(math.log2(math.factorial(len(w))))
        assert 2**d >= count and (d == 0 or 2 ** (d - 1) < count), "query bound failed"
        assert d <= d_base
        print(
            f"{w:<18}{count:>10}{d:>12}{d_base:>12}{info_erased(w):>10.4f}"
            f"{landauer_work(w):>13.3e}"
        )
    print()
    print("Sorting one billion 4-key (DNA-like) records versus distinct records:")
    n_big: int = 10**9
    ms_big: List[int] = [n_big // 4] * 4
    e_multiset: float = (
        sum(math.lgamma(n_big + 1) for _ in [0])
        - sum(math.lgamma(m + 1) for m in ms_big)
    ) / math.log(2)
    e_distinct: float = math.lgamma(n_big + 1) / math.log(2)
    budget: float = n_big * shannon_entropy(ms_big)
    print(f"  distinct-key baseline log2(n!)  : {e_distinct:.4e} bits")
    print(f"  multiset erasure  log2(n!/prod) : {e_multiset:.4e} bits")
    print(f"  Shannon ceiling n*H(p)          : {budget:.4e} bits  (= 2n, uniform on 4 keys)")
    print(f"  ratio multiset/baseline         : {e_multiset / e_distinct:.6f}")
    print(f"  heat saved at 300 K             : "
          f"{K_B * T_ROOM * math.log(2) * (e_distinct - e_multiset):.4e} J")
    assert e_multiset <= budget + 1e-3 * budget
    print()


def main() -> None:
    print()
    print("THE MULTINOMIAL ERASURE LEDGER — numerical demonstrations")
    print()
    demo_orbit_stabiliser()
    demo_shannon_ceiling()
    demo_coarsening()
    demo_merge_ledger()
    demo_complexity_and_heat()
    print("All identities and inequalities verified.")


if __name__ == "__main__":
    main()
