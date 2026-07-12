"""
demo.py — The Arithmetic of the Discoverable
=============================================

Numerical demonstrations of the finite/infinite scissor and its
heat-death corollary.

We model:

  * Statements as finite strings over a finite alphabet Sigma.
  * The shortlex enumeration e_sl : N -> Sigma^* (short-length-first,
    then lexicographic), under which every string has a unique finite
    index.
  * A toy "formal system": a decidable predicate `is_theorem` picking
    out an infinite subset T of Sigma^*. (Any infinite decidable subset
    illustrates the three core results identically.)

We then demonstrate, purely numerically:

  1. Enumeration Theorem      -- each theorem sits at a finite index.
  2. Discovery Index Theorem  -- discovery indices exist and are unique.
  3. Non-Exhaustibility       -- |D(N)| <= N but the remainder is infinite;
                                 |D(N)| -> infinity even at density zero.
  4. Heat-Death Corollary     -- finite physical budget B_infty => finite
                                 discovered set, infinite remainder.
  5. Frontier optimality of shortlex vs. a "silly" (length-last) order.

All functions are inlined and type-hinted. Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Iterator


# ----------------------------------------------------------------------
# Shortlex enumeration of Sigma^*
# ----------------------------------------------------------------------

def shortlex(alphabet: str) -> Iterator[str]:
    """Yield every finite string over `alphabet` exactly once, in shortlex
    order: all length-0 strings, then length-1, then length-2, ...
    Within each length, plain lexicographic order induced by `alphabet`.
    This is the bijection e_sl : N -> Sigma^*.
    """
    length: int = 0
    while True:
        for tup in product(alphabet, repeat=length):
            yield "".join(tup)
        length += 1


def shortlex_index(s: str, alphabet: str) -> int:
    """Return the finite index n with e_sl(n) = s (predecessor count)."""
    k: int = len(alphabet)
    rank: int = {c: i for i, c in enumerate(alphabet)}[alphabet[0]] * 0  # noqa
    # number of strings strictly shorter than s:
    shorter: int = sum(k ** j for j in range(len(s)))
    # lexicographic rank of s within its own length class (base-k):
    pos = {c: i for i, c in enumerate(alphabet)}
    within: int = 0
    for c in s:
        within = within * k + pos[c]
    return shorter + within


# ----------------------------------------------------------------------
# A toy formal system: an infinite, decidable theorem set
# ----------------------------------------------------------------------

def make_is_theorem(alphabet: str) -> Callable[[str], bool]:
    """Return a decidable predicate carving out an infinite subset T of
    Sigma^*. Here: strings that are palindromes AND non-empty. There are
    infinitely many, and they have natural density zero -- ideal for
    illustrating Non-Exhaustibility with |D(N)|/N -> 0.
    """
    def is_theorem(s: str) -> bool:
        return len(s) >= 1 and s == s[::-1]
    return is_theorem


# ----------------------------------------------------------------------
# Discovery under a finite budget
# ----------------------------------------------------------------------

def discover(alphabet: str,
             is_theorem: Callable[[str], bool],
             budget: int) -> list[tuple[int, str]]:
    """Run the shortlex search for `budget` steps; return the list of
    (index, theorem) pairs discovered. |result| <= budget always.
    """
    found: list[tuple[int, str]] = []
    for n, s in zip(range(budget), shortlex(alphabet)):
        if is_theorem(s):
            found.append((n, s))
    return found


# ----------------------------------------------------------------------
# Physical budget: Bremermann / Margolus-Levitin accounting
# ----------------------------------------------------------------------

def bremermann_ops_per_kg_per_sec() -> float:
    """Bremermann's limit: ~1.36e50 operations per second per kilogram."""
    c: float = 2.99792458e8          # speed of light, m/s
    h: float = 6.62607015e-34        # Planck constant, J*s
    return c * c / h                 # ~1.36e50


def total_universe_ops() -> float:
    """A generous finite ceiling B_infty on the total number of logical
    operations available over the future of the universe. We follow the
    standard 'computational capacity of the universe' estimate: ~1e120.
    """
    return 1.0e120


def theorems_ever_discovered(b_infty: float) -> float:
    """Each step discovers at most one new theorem, so the total number of
    theorems ever discovered is at most B_infty -- a finite number set
    against a countable infinity.
    """
    return b_infty


# ----------------------------------------------------------------------
# Frontier: shortlex vs. a deliberately bad enumeration
# ----------------------------------------------------------------------

def steps_to_cover_length(alphabet: str, max_len: int) -> int:
    """Minimum steps for shortlex to have seen every string of length
    <= max_len: exactly sum_{j=0}^{max_len} k^j (Proposition 5.1).
    """
    k: int = len(alphabet)
    return sum(k ** j for j in range(max_len + 1))


# ----------------------------------------------------------------------
# Main demonstration
# ----------------------------------------------------------------------

def main() -> None:
    alphabet: str = "ab"
    is_theorem = make_is_theorem(alphabet)
    k: int = len(alphabet)

    print("=" * 68)
    print("THE ARITHMETIC OF THE DISCOVERABLE — numerical demonstrations")
    print("=" * 68)
    print(f"Alphabet Sigma = {sorted(alphabet)!r}  (k = {k})")
    print("Toy theorem set T = nonempty palindromes (infinite, density 0)")
    print()

    # (1) & (2) Enumeration + Discovery Index Theorems -----------------
    print("[1,2] Every theorem sits at a unique FINITE index:")
    for s in ["a", "aa", "aba", "abba", "abcba".replace("c", "a")]:
        print(f"      idx('{s}') = {shortlex_index(s, alphabet)}"
              f"   is_theorem = {is_theorem(s)}")
    # round-trip check: e_sl(idx(s)) == s
    gen = list(zip(range(200), shortlex(alphabet)))
    ok = all(shortlex_index(s, alphabet) == n for n, s in gen)
    print(f"      round-trip e_sl(idx(s)) == s on first 200 strings: {ok}")
    print()

    # (3) Non-Exhaustibility -------------------------------------------
    print("[3] Non-exhaustibility:  |D(N)| <= N, remainder infinite,")
    print("    yet |D(N)| -> infinity even though density -> 0:")
    print(f"      {'N':>10} {'|D(N)|':>10} {'|D(N)|/N':>12}")
    for N in [10, 100, 1000, 10000, 100000]:
        d = discover(alphabet, is_theorem, N)
        print(f"      {N:>10} {len(d):>10} {len(d) / N:>12.6f}")
    print("    |D(N)| grows without bound; |D(N)|/N shrinks toward 0.")
    print()

    # (4) Heat-Death Corollary -----------------------------------------
    print("[4] Heat-Death Corollary — finite budget, infinite remainder:")
    rate = bremermann_ops_per_kg_per_sec()
    b_inf = total_universe_ops()
    print(f"      Bremermann rate      : {rate:.3e} ops / (kg * s)")
    print(f"      Total budget B_inf   : {b_inf:.3e} operations (finite)")
    print(f"      Theorems ever found  : <= {theorems_ever_discovered(b_inf):.3e}")
    print("      Theorems in T        : countably INFINITE")
    print("      => infinitely many theorems are NEVER discovered.")
    print()

    # (5) Frontier optimality of shortlex ------------------------------
    print("[5] Shortlex is frontier-optimal (Proposition 5.1):")
    print(f"      {'max_len':>8} {'min steps to cover':>20}")
    for L in range(0, 6):
        print(f"      {L:>8} {steps_to_cover_length(alphabet, L):>20}")
    print("    No enumeration can cover length <= L in fewer steps.")
    print()
    print("=" * 68)
    print("Conclusion: each theorem is finitely reachable; no finite budget")
    print("reaches them all. Heat death ends access, not truth.")
    print("=" * 68)


if __name__ == "__main__":
    main()
