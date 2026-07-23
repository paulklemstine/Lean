"""Numerical demonstrations for
"Finite Truth Tables and the Boundary of Diagonal Arguments".

This self-contained script illustrates four results:

  1. Perfect Finite Oracle: for a fixed semantics on a finite bounded
     language, the exact oracle answers every statement correctly, clearing
     any accuracy benchmark (100% >= 95%).
  2. Finite Tabulation: every oracle on a finite domain is a finite lookup
     table of (statement, answer) pairs.
  3. No Universal Oracle: for any fixed oracle, the adversarial semantics
     defined in response drives the oracle's accuracy to exactly 0%.
  4. Diagonal Escape: the diagonal-complement sequence differs from every
     row of an indexed Boolean table, so no enumeration is complete.

Run with:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Tuple

# --------------------------------------------------------------------------- #
# Core model
# --------------------------------------------------------------------------- #

Statement = Tuple[int, ...]          # a length-`length` word over {0,...,a-1}
Answer = str                         # "yes" | "no" | "unknown"
Semantics = Callable[[Statement], bool]
Oracle = Callable[[Statement], Answer]


def all_statements(alphabet: int, length: int) -> List[Statement]:
    """Enumerate every word of the given length over an `alphabet`-symbol set.

    The number of results is exactly ``alphabet ** length`` (Proposition 2.2).
    """
    return [tuple(w) for w in product(range(alphabet), repeat=length)]


def answer_of_bool(b: bool) -> Answer:
    """Embed a Boolean truth value into a definite answer (the map beta)."""
    return "yes" if b else "no"


def correct(truth: Semantics, oracle: Oracle, x: Statement) -> bool:
    """Correctness counts abstention ("unknown") as failure (Definition 2.5)."""
    return oracle(x) == answer_of_bool(truth(x))


def correct_count(
    truth: Semantics, oracle: Oracle, domain: List[Statement]
) -> int:
    """Number of statements answered correctly on a finite domain."""
    return sum(1 for x in domain if correct(truth, oracle, x))


def meets_benchmark(
    truth: Semantics, oracle: Oracle, domain: List[Statement], pct: int = 95
) -> bool:
    """Integer accuracy test: pct * |domain| <= 100 * correct_count."""
    return pct * len(domain) <= 100 * correct_count(truth, oracle, domain)


# --------------------------------------------------------------------------- #
# 1 & 2. Perfect finite oracle and its finite table
# --------------------------------------------------------------------------- #

def exact_oracle(truth: Semantics) -> Oracle:
    """The exact oracle for a fixed semantics (Definition 3.1)."""
    return lambda x: answer_of_bool(truth(x))


def oracle_table(
    oracle: Oracle, domain: List[Statement]
) -> Dict[Statement, Answer]:
    """The complete finite graph of an oracle (Theorem 3.5)."""
    return {x: oracle(x) for x in domain}


def demo_perfect_oracle() -> None:
    print("=" * 68)
    print("1 & 2.  Perfect Finite Oracle and Finite Tabulation")
    print("=" * 68)
    alphabet, length = 2, 4
    domain = all_statements(alphabet, length)
    print(f"alphabet={alphabet}, length={length}")
    print(f"|statements| = {alphabet}^{length} = {alphabet ** length} "
          f"(actual: {len(domain)})")

    # An arbitrary but fixed semantics: "true iff the word has odd parity".
    truth: Semantics = lambda x: (sum(x) % 2 == 1)

    orc = exact_oracle(truth)
    c = correct_count(truth, orc, domain)
    print(f"exact oracle correct count = {c} / {len(domain)} "
          f"({100 * c // len(domain)}% accuracy)")
    print(f"meets 95% benchmark? {meets_benchmark(truth, orc, domain)}")

    table = oracle_table(orc, domain)
    print("first 4 rows of the finite lookup table:")
    for x in domain[:4]:
        print(f"    {x} -> {table[x]}")
    print()


# --------------------------------------------------------------------------- #
# 3. No universal oracle: the adversarial semantics
# --------------------------------------------------------------------------- #

def adversarial_truth(oracle: Oracle) -> Semantics:
    """Semantics chosen in response to an oracle to falsify it (Definition 4.1)."""
    def tau(x: Statement) -> bool:
        a = oracle(x)
        if a == "yes":
            return False       # oracle said yes -> make it false
        # oracle said "no" or "unknown" -> make it true
        return True
    return tau


def demo_no_universal_oracle() -> None:
    print("=" * 68)
    print("3.  No Universal Oracle (adversarial quantifier reversal)")
    print("=" * 68)
    alphabet, length = 2, 3
    domain = all_statements(alphabet, length)

    # Try several candidate oracles; the adversary defeats each one entirely.
    candidates: Dict[str, Oracle] = {
        "always yes":     lambda x: "yes",
        "always no":      lambda x: "no",
        "always unknown": lambda x: "unknown",
        "parity guess":   lambda x: answer_of_bool(sum(x) % 2 == 1),
    }
    for name, orc in candidates.items():
        adv = adversarial_truth(orc)
        c = correct_count(adv, orc, domain)
        print(f"  oracle '{name:14s}': accuracy vs adversary = "
              f"{100 * c // len(domain)}%  (correct {c}/{len(domain)})")
    print("  => no fixed oracle survives its own adversary: all score 0%.")
    print()


# --------------------------------------------------------------------------- #
# 4. Diagonal escape (finite and infinite echoes)
# --------------------------------------------------------------------------- #

def finite_diagonal(rows: List[List[bool]]) -> List[bool]:
    """Complement the diagonal of an n x n Boolean table (Definition 5.1)."""
    n = len(rows)
    return [not rows[i][i] for i in range(n)]


def diagonal_jump(row: Callable[[int, int], bool], k_max: int) -> List[bool]:
    """First k_max entries of the diagonal-complement sequence (Definition 5.4)."""
    return [not row(k, k) for k in range(k_max)]


def demo_diagonal() -> None:
    print("=" * 68)
    print("4.  Diagonal Escape (Cantor)")
    print("=" * 68)

    # Finite square table.
    rows = [
        [True,  False, True,  False],
        [True,  True,  False, False],
        [False, False, True,  True],
        [True,  True,  True,  True],
    ]
    diag = finite_diagonal(rows)
    print("finite 4x4 table diagonal complement:", diag)
    for i, r in enumerate(rows):
        print(f"    differs from row {i}? {diag != r}  (at coord {i}: "
              f"{diag[i]} vs {r[i]})")

    # Infinite family, sampled: row k is the binary expansion bit of k+j.
    row_fn: Callable[[int, int], bool] = lambda k, j: ((k * 2 + j) % 3 == 0)
    k_max = 8
    jump = diagonal_jump(row_fn, k_max)
    print(f"\ndiagonal jump (first {k_max}): {jump}")
    for k in range(k_max):
        rk = [row_fn(k, j) for j in range(k_max)]
        print(f"    row {k}: differs at coord {k}? {jump[k] != rk[k]}")
    print("  => the jump differs from every listed row at its own index.")
    print()


# --------------------------------------------------------------------------- #

def main() -> None:
    demo_perfect_oracle()
    demo_no_universal_oracle()
    demo_diagonal()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
