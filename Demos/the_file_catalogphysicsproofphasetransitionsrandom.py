"""Assemble PACKAGE.json from the deliverables in this directory."""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))


def rd(name: str) -> str:
    with open(os.path.join(HERE, name), encoding="utf-8") as f:
        return f.read()


article = rd("ARTICLE.md")
paper = rd("RESEARCH_PAPER.md")
demo_src = rd("demo.py")
viz_src = rd("viz_threshold.py")
interactive_html = rd("interactive.html")
lean_src = rd("lean_source.txt")

# ---------------------------------------------------------------- demos -----
demo_verify = '''"""Demo: brute-force verification of the exact first-moment identity."""
from __future__ import annotations
import itertools
from typing import List, Tuple

Assign = Tuple[int, ...]
Lit = Tuple[int, int]
Clause = Tuple[Lit, ...]
Formula = Tuple[Clause, ...]


def sat_clause(a: Assign, clause: Clause) -> bool:
    return any(a[v] == val for (v, val) in clause)


def models(a: Assign, formula: Formula) -> bool:
    return all(sat_clause(a, c) for c in formula)


def first_moment_formula(n: int, k: int, m: int) -> int:
    return (2 ** n) * ((2 * n) ** k - n ** k) ** m


def brute_first_moment(n: int, k: int, m: int) -> int:
    asgns: List[Assign] = [tuple(a) for a in itertools.product((0, 1), repeat=n)]
    lits: List[Lit] = [(v, s) for v in range(n) for s in (0, 1)]
    clauses: List[Clause] = [tuple(c) for c in itertools.product(lits, repeat=k)]
    total = 0
    for f in itertools.product(clauses, repeat=m):
        total += sum(1 for a in asgns if models(a, tuple(f)))
    return total


if __name__ == "__main__":
    for n, k, m in [(2, 2, 1), (2, 2, 2), (3, 2, 1), (2, 3, 1)]:
        p, b = first_moment_formula(n, k, m), brute_first_moment(n, k, m)
        print(f"n={n} k={k} m={m}: predicted={p} brute={b} ok={p == b}")
'''

demo_threshold = '''"""Demo: locate the first-moment freezing point and compare to alpha_c."""
from __future__ import annotations
import math


def annealed(n: int, k: int, m: int) -> float:
    return (2 ** n) * (1.0 - 2.0 ** (-k)) ** m


def first_unsat_m(n: int, k: int) -> int:
    m = 0
    while annealed(n, k, m) >= 1.0:
        m += 1
    return m


def alpha1(k: int) -> float:
    return -math.log(2) / math.log(1.0 - 2.0 ** (-k))


if __name__ == "__main__":
    for k in (3, 4, 5):
        n = 50
        m = first_unsat_m(n, k)
        print(f"k={k}: first forced-UNSAT m={m} (density {m / n:.2f}), "
              f"alpha_1(k)={alpha1(k):.3f}")
'''

# ----------------------------------------------------------- algorithms -----
algo_first_moment = '''from __future__ import annotations


def first_moment(n: int, k: int, m: int, q: int = 2) -> int:
    """Exact annealed first moment q^n * ((nq)^k - (n(q-1))^k)^m.

    Uses Python big integers, so the result is exact for all inputs.
    """
    s: int = (n * q) ** k - (n * (q - 1)) ** k
    return (q ** n) * s ** m
'''

algo_certificate = '''from __future__ import annotations


def unsat_certificate(n: int, k: int, m: int, q: int = 2) -> str:
    """Return 'UNSAT-FORCED' iff q^n*S^m < |C|^m, else 'INCONCLUSIVE'.

    Exact integer comparison; never errs in the forced direction.
    """
    s: int = (n * q) ** k - (n * (q - 1)) ** k
    first_moment: int = (q ** n) * s ** m
    num_formulas: int = ((n * q) ** k) ** m
    return "UNSAT-FORCED" if first_moment < num_formulas else "INCONCLUSIVE"
'''

algo_critical = '''from __future__ import annotations
import math


def critical_density(k: int, q: int = 2) -> float:
    """First-moment density bound alpha_1 = -ln q / log(1 - ((q-1)/q)^k)."""
    return -math.log(q) / math.log(1.0 - ((q - 1) / q) ** k)


def smallest_forced_m(n: int, k: int, q: int = 2) -> int:
    """Smallest m with q^n*(1-((q-1)/q)^k)^m < 1, via monotone binarysearch."""
    frac: float = (1.0 - ((q - 1) / q) ** k)
    log_entropy: float = n * math.log(q)
    log_frac: float = math.log(frac)
    # ln E[Z] = log_entropy + m*log_frac < 0  <=>  m > -log_entropy/log_frac
    lo: int = 0
    hi: int = 1
    while log_entropy + hi * log_frac >= 0.0:
        hi *= 2
    while lo < hi:
        mid: int = (lo + hi) // 2
        if log_entropy + mid * log_frac < 0.0:
            hi = mid
        else:
            lo = mid + 1
    return lo
'''

# ----------------------------------------------------------------------------
future_directions = rd_fd = '''# Future Directions — Proof Phase Transitions in Random k-SAT

The file `Physics/ProofPhaseTransitions/RandomKSAT.lean` establishes, fully formally
and `sorry`-free (only `propext`, `Classical.choice`, `Quot.sound`):

* an **abstract partition-function first-moment law** `first_moment_general`: for any finite
  CSP whose every assignment satisfies a *constant* number `S` of constraints,
  `∑_F #{a : a ⊨ F} = |A| · S^m`, with the pigeonhole corollary `exists_unsat_general`
  (`|A|·S^m < |C|^m ⟹ ∃` unsatisfiable formula);
* the **Boolean k-SAT** instantiation `first_moment` (`= 2^n·((2n)^k − n^k)^m`),
  `exists_unsat`, and the density form `exists_unsat_of_real_density`
  (`2^n·(1 − 2^{−k})^m < 1 ⟹ ∃` unsat);
* **threshold monotonicity** `exists_unsat_of_density_mono`: the unsatisfiable region is an
  up-set in the clause count `m`;
* the **q-ary CSP generalization** `Qary.first_moment`
  (`= q^n·((nq)^k − (n(q−1))^k)^m`), `Qary.exists_unsat`, and
  `Qary.exists_unsat_of_real_density` with the model-independent density factor
  `1 − ((q−1)/q)^k` reducing to `1 − 2^{−k}` at `q = 2`.

These are the rigorous "upper half" (annealed/first-moment) of the satisfiability phase
transition, plus its monotonicity and its alphabet-independence.

## Direction 1 — A second-moment satisfiability lower bound
Prove the complementary "lower half": if the clause density is below the first-moment
threshold by a constant factor, a uniformly random formula is satisfiable with probability
bounded away from `0`. Formalize the Paley–Zygmund / Cauchy–Schwarz inequality
`(E[X])^2 ≤ P(X > 0)·E[X^2]` for `X = #{a : a ⊨ F}`, and compute `E[X^2]` as the exact
two-assignment correlation sum. The second moment factorizes over clauses exactly as the
first moment does, so `E[X^2] = ∑_{a,b} ((2n)^k − 2·n^k + u(a,b))^m / (2n)^{km}`, where
`u(a,b)` counts clauses falsified by both `a` and `b` and depends only on the Hamming
distance `|a Δ b|`; this collapses the estimate to a one-dimensional sum over Hamming
distance evaluable by the same `Equiv.subtypePiEquivPi`/`Fintype.card_pi` toolkit already
used for `card_unsat_clause`. No measure theory is needed — only one more application of
the proved tools.

## Direction 2 — Exact integer crossing point of the threshold window
Strengthen `exists_unsat_of_density_mono` to a sharp window: an explicit width `w(n,k)`
with every formula in a positive fraction satisfiable for `m` below `m*(n,k) − w` and the
first moment forcing unsatisfiability for `m` above `m*(n,k) + w`, with `w = O(1)` in `n`
for fixed `k`. The map `m ↦ 2^n(1 − 2^{−k})^m` is strictly log-linear, so the crossing of
the value `1` happens within a single unit interval of `m`; bounding the integer crossing
point is a monotonicity argument on a concrete real sequence, within reach of Mathlib's
`StrictMono`/`Real.log` API.

## Direction 3 — The "without replacement" model and an exact binomial identity
Re-derive the first moment for combinatorial random `k`-SAT (each clause on `k` distinct
variables with independent signs), conjecturally
`∑_F #{a : a ⊨ F} = 2^n · (C(n,k)·2^k − C(n,k))^m = 2^n · (C(n,k)·(2^k − 1))^m`, with the
identical density threshold `2^n·(1 − 2^{−k})^m < 1`. Switching models replaces the
per-clause base count `(2n)^k` by `C(n,k)·2^k` while the falsified fraction stays exactly
`2^{−k}`, so the density threshold is model-independent; the proof reuses
`subtypePiEquivPi` after replacing literal tuples by injective ones, using
`Finset.card_powersetCard`.

## Direction 4 — General finite-domain CSP and a product partition function
Generalize to variables over a domain of size `q` and constraints forbidding `r` of the
`q^k` local patterns: `∑_F #{a : a ⊨ F} = q^n · (q^k − r)^m` with threshold
`q^n · (1 − r·q^{−k})^m < 1`, recovering the Boolean case at `q = 2, r = 1`. The whole
argument is a statement about the partition function `Z = ∑_a ∏_clauses [a sat clause]`;
the annealed average factorizes as `q^n · (allowed-pattern fraction)^m` regardless of
alphabet — the threshold is a sign change of `log E[Z]`, an annealed free energy. This
reframes `Shared/EntropyAlgebra.lean`'s partition-function results as the q-ary free
energy of a random CSP (Physics ↔ Algebra/Entropy bridge).

## Direction 5 — Tropical (min-plus) free energy and a zero-temperature transition
Lift the partition function `Z = ∑_a w(a)` to the tropical semiring (addition `min`,
multiplication `+`), so `Z_trop(F) = min_a (#clauses falsified by a)` is the MAX-SAT
optimum. Conjecture a tropical first-moment law and a zero-temperature threshold: above the
density where `2^n(1 − 2^{−k})^m < 1`, almost every formula has `Z_trop ≥ 1`. The ordinary
first moment counts zero-temperature ground states, so existence of an unsatisfiable
formula is exactly the statement that the tropical optimum jumps off `0` — a discontinuity
in a min-plus free energy, connecting to the project's tropical/min-plus corpus
(`Tropical/`, `Tropical/FiberEntropy.lean`).
'''

package = {
    "title": "Proof Phase Transitions in Random k-SAT: The First-Moment Law",
    "domain": "Novelty",
    "description": (
        "An exact partition-function first-moment counting identity for random "
        "constraint satisfaction problems and the sharp existence (freezing) "
        "threshold it forces for random k-SAT, with a q-ary generalization and "
        "monotonicity of the unsatisfiable phase."
    ),
    "authors": ["Aristotle (Harmonic)"],
    "date": "2026-06-11",
    "key_results": [
        "Abstract first-moment law: if every assignment satisfies exactly S of "
        "the constraints, then summing satisfying assignments over all m-constraint "
        "formulas equals |A|*S^m.",
        "Boolean k-SAT first moment: sum_F #{a : a |= F} = 2^n*((2n)^k - n^k)^m.",
        "Existence threshold: 2^n*(1 - 2^-k)^m < 1 forces an unsatisfiable formula "
        "to exist (statistical-physics density form).",
        "Monotonicity: the unsatisfiable phase is an up-set in the clause count m.",
        "q-ary generalization q^n*((nq)^k - (n(q-1))^k)^m with model-independent "
        "density factor 1 - ((q-1)/q)^k reducing to 1 - 2^-k at q=2.",
    ],
    "keywords": [
        "random k-SAT", "satisfiability threshold", "first-moment method",
        "annealed average", "partition function", "phase transition",
        "constraint satisfaction", "probabilistic method",
    ],
    "article": "ARTICLE.md",
    "research_paper": "RESEARCH_PAPER.md",
    "demo": "demo.py",
    "demos": [
        {
            "name": "brute_force_first_moment_identity",
            "description": "Verifies the exact first-moment identity "
                           "sum_F #{a : a |= F} = 2^n*((2n)^k - n^k)^m by full "
                           "enumeration of assignments, clauses, and formulas on "
                           "small instances.",
            "code": demo_verify,
        },
        {
            "name": "freezing_point_locator",
            "description": "Locates the smallest clause count m at which the "
                           "annealed first moment 2^n(1-2^-k)^m drops below 1 "
                           "(unsatisfiability forced) and compares the resulting "
                           "density bound alpha_1(k) to the empirical threshold.",
            "code": demo_threshold,
        },
        {
            "name": "full_demo",
            "description": "Complete demonstration suite: identity verification, "
                           "constant-S check, integer threshold vs brute UNSAT, "
                           "density form + monotonicity, and the q-ary case.",
            "code": demo_src,
        },
    ],
    "algorithms": [
        {
            "name": "annealed_first_moment",
            "description": "Computes the exact annealed first moment "
                           "q^n*((nq)^k - (n(q-1))^k)^m (Boolean: 2^n*((2n)^k - "
                           "n^k)^m) using arbitrary-precision integers, so the "
                           "result is exact for all inputs. This is the partition "
                           "function E[Z]*|C|^m and the central quantity of the "
                           "pipeline. Complexity: O(log(km)) big-integer "
                           "multiplications via fast exponentiation on numbers of "
                           "O(n + km*k*log(nq)) bits.",
            "pseudocode": (
                "function FIRST_MOMENT(n, k, m, q):\n"
                "    total_clauses   <- (n*q)^k\n"
                "    falsified_clauses <- (n*(q-1))^k\n"
                "    S <- total_clauses - falsified_clauses   # satisfied per assignment\n"
                "    return q^n * S^m"
            ),
            "code": algo_first_moment,
        },
        {
            "name": "unsat_existence_certificate",
            "description": "Decides the exact integer existence threshold: returns "
                           "'UNSAT-FORCED' iff q^n*S^m < |C|^m = (nq)^(km), in which "
                           "case the pigeonhole on the first-moment identity "
                           "guarantees some formula is unsatisfiable. Sound (never "
                           "errs in the forced direction) but one-directional. "
                           "Complexity: two fast-exponentiation evaluations.",
            "pseudocode": (
                "function UNSAT_CERTIFICATE(n, k, m, q):\n"
                "    S <- (n*q)^k - (n*(q-1))^k\n"
                "    first_moment <- q^n * S^m\n"
                "    num_formulas <- ((n*q)^k)^m\n"
                "    if first_moment < num_formulas:\n"
                "        return 'UNSAT-FORCED'\n"
                "    else:\n"
                "        return 'INCONCLUSIVE'"
            ),
            "code": algo_certificate,
        },
        {
            "name": "critical_density_solver",
            "description": "Solves log E[Z] = 0 for the first-moment density bound "
                           "alpha_1(k,q) = -ln q / log(1 - ((q-1)/q)^k) and finds the "
                           "smallest forced-UNSAT clause count m for given n by "
                           "exploiting monotonicity of m -> log E[Z] with binary "
                           "search in log-space (overflow-safe). Complexity: "
                           "O(log m*) evaluations.",
            "pseudocode": (
                "function CRITICAL_DENSITY(k, q):\n"
                "    return -ln(q) / log(1 - ((q-1)/q)^k)\n"
                "\n"
                "function SMALLEST_FORCED_M(n, k, q):\n"
                "    log_entropy <- n*ln(q);  log_frac <- log(1 - ((q-1)/q)^k)\n"
                "    hi <- 1\n"
                "    while log_entropy + hi*log_frac >= 0: hi <- 2*hi\n"
                "    lo <- 0\n"
                "    while lo < hi:\n"
                "        mid <- (lo+hi)//2\n"
                "        if log_entropy + mid*log_frac < 0: hi <- mid\n"
                "        else: lo <- mid+1\n"
                "    return lo"
            ),
            "code": algo_critical,
        },
    ],
    "visualizations": [
        {
            "name": "threshold_crossing_plot",
            "description": "Plots the annealed first moment E[Z] = 2^n(1-2^-k)^m on "
                           "a log scale against clause density alpha = m/n for "
                           "k = 2,3,4,5, marking the freezing line E[Z] = 1 where an "
                           "unsatisfiable formula becomes forced.",
            "code": viz_src,
        },
    ],
    "interactive_demos": [
        {
            "title": "Random k-SAT First-Moment Threshold Explorer",
            "description": "Interactive widget: drag sliders for variables n, clause "
                           "width k, clause count m, and alphabet size q to watch the "
                           "annealed first moment E[Z] = q^n(1-((q-1)/q)^k)^m cross "
                           "the freezing line E[Z] = 1, with live UNSAT-forced "
                           "diagnosis and the density bound alpha_1.",
            "html": interactive_html,
        },
    ],
    "lean_proofs": lean_src,
    "future_directions": future_directions,
    "modules": {"demo": demo_src},
    "lean_files": ["Catalog/Physics/ProofPhaseTransitions/RandomKSAT.lean"],
}

with open(os.path.join(HERE, "PACKAGE.json"), "w", encoding="utf-8") as f:
    json.dump(package, f, indent=2, ensure_ascii=False)
print("Wrote PACKAGE.json")


"""
Numerical demonstrations for:

    A Partition-Function First-Moment Law for Random Constraint Satisfaction,
    with the Sharp Existence Threshold for Random k-SAT.

This script is fully self-contained (standard library only). It verifies the
exact counting identities by brute force on small instances and then exhibits
the statistical-physics density threshold, monotonicity, and the q-ary
generalization.

Key results demonstrated
------------------------
1. first_moment (Boolean):
       sum_F #{a : a |= F}  =  2^n * ((2n)^k - n^k)^m
2. exists_unsat (integer threshold):
       2^n * ((2n)^k - n^k)^m < (2n)^(k*m)  ==>  some F is unsatisfiable
3. density form:
       2^n * (1 - 2^-k)^m < 1               ==>  some F is unsatisfiable
4. monotonicity of the unsatisfiable phase in m
5. q-ary first moment:
       sum_F #{a : a |= F}  =  q^n * ((n*q)^k - (n*(q-1))^k)^m
"""

from __future__ import annotations

import itertools
import math
from typing import Iterable, List, Tuple

# An assignment is a tuple of q-ary values (Booleans are q = 2: 0/1).
Assign = Tuple[int, ...]
# A literal is (variable_index, target_value).
Lit = Tuple[int, int]
# A clause is a tuple of k literals.
Clause = Tuple[Lit, ...]
# A formula is a tuple of m clauses.
Formula = Tuple[Clause, ...]


# --------------------------------------------------------------------------- #
# Semantics                                                                    #
# --------------------------------------------------------------------------- #
def sat_lit(a: Assign, lit: Lit) -> bool:
    """A literal (v, val) is satisfied by a iff a[v] == val."""
    v, val = lit
    return a[v] == val


def sat_clause(a: Assign, clause: Clause) -> bool:
    """A clause is satisfied iff at least one of its literals is."""
    return any(sat_lit(a, lit) for lit in clause)


def models(a: Assign, formula: Formula) -> bool:
    """An assignment models a formula iff it satisfies every clause."""
    return all(sat_clause(a, clause) for clause in formula)


# --------------------------------------------------------------------------- #
# Enumerators (with-replacement model)                                         #
# --------------------------------------------------------------------------- #
def all_assignments(n: int, q: int = 2) -> List[Assign]:
    """All q^n assignments of n variables over a domain of size q."""
    return [tuple(a) for a in itertools.product(range(q), repeat=n)]


def all_literals(n: int, q: int = 2) -> List[Lit]:
    """All n*q literals (variable, value)."""
    return [(v, val) for v in range(n) for val in range(q)]


def all_clauses(n: int, k: int, q: int = 2) -> List[Clause]:
    """All (n*q)^k clauses: k-tuples of literals, with replacement."""
    lits = all_literals(n, q)
    return [tuple(c) for c in itertools.product(lits, repeat=k)]


def all_formulas(n: int, k: int, m: int, q: int = 2) -> Iterable[Formula]:
    """All ((n*q)^k)^m formulas (lazy: this set is huge)."""
    clauses = all_clauses(n, k, q)
    return (tuple(f) for f in itertools.product(clauses, repeat=m))


# --------------------------------------------------------------------------- #
# Closed-form predictions                                                      #
# --------------------------------------------------------------------------- #
def first_moment_formula(n: int, k: int, m: int, q: int = 2) -> int:
    """Exact integer q^n * ((n*q)^k - (n*(q-1))^k)^m  (Theorem 4.4 / 5.2)."""
    sat_per_assignment = (n * q) ** k - (n * (q - 1)) ** k
    return (q ** n) * sat_per_assignment ** m


def num_formulas(n: int, k: int, m: int, q: int = 2) -> int:
    """|C|^m = (n*q)^(k*m)."""
    return ((n * q) ** k) ** m


def annealed_density_value(n: int, k: int, m: int, q: int = 2) -> float:
    """E[Z] = q^n * (1 - ((q-1)/q)^k)^m  (Theorem 4.6 / 5.3)."""
    return (q ** n) * (1.0 - ((q - 1) / q) ** k) ** m


def forced_unsat(n: int, k: int, m: int, q: int = 2) -> bool:
    """Exact integer certificate: q^n*S^m < |C|^m  ==>  some F unsat."""
    return first_moment_formula(n, k, m, q) < num_formulas(n, k, m, q)


def first_moment_threshold_density(k: int, q: int = 2) -> float:
    """alpha_1 = -ln q / log(1 - ((q-1)/q)^k): first-moment density bound."""
    return -math.log(q) / math.log(1.0 - ((q - 1) / q) ** k)


# --------------------------------------------------------------------------- #
# Brute-force verifications                                                    #
# --------------------------------------------------------------------------- #
def brute_first_moment(n: int, k: int, m: int, q: int = 2) -> int:
    """Sum over ALL formulas of the number of satisfying assignments."""
    asgns = all_assignments(n, q)
    total = 0
    for formula in all_formulas(n, k, m, q):
        total += sum(1 for a in asgns if models(a, formula))
    return total


def brute_exists_unsat(n: int, k: int, m: int, q: int = 2) -> bool:
    """True iff some formula has zero satisfying assignments."""
    asgns = all_assignments(n, q)
    for formula in all_formulas(n, k, m, q):
        if not any(models(a, formula) for a in asgns):
            return True
    return False


def brute_sat_clause_count(n: int, k: int, q: int = 2) -> List[int]:
    """For each assignment, count clauses it satisfies (should be constant)."""
    asgns = all_assignments(n, q)
    clauses = all_clauses(n, k, q)
    return [sum(1 for c in clauses if sat_clause(a, c)) for a in asgns]


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #
def demo_first_moment_identity() -> None:
    print("=" * 70)
    print("1. First-moment identity  sum_F #{a : a |= F} = 2^n*((2n)^k - n^k)^m")
    print("=" * 70)
    for n, k, m in [(2, 2, 1), (2, 2, 2), (3, 2, 1), (2, 3, 1), (1, 2, 3)]:
        predicted = first_moment_formula(n, k, m)
        actual = brute_first_moment(n, k, m)
        ok = "OK" if predicted == actual else "MISMATCH"
        print(f"  n={n} k={k} m={m}: predicted={predicted:>10}  "
              f"brute={actual:>10}  [{ok}]")
    print()


def demo_constant_S() -> None:
    print("=" * 70)
    print("2. Every assignment satisfies the SAME number S = (2n)^k - n^k")
    print("=" * 70)
    for n, k in [(2, 2), (3, 2), (2, 3)]:
        counts = brute_sat_clause_count(n, k)
        predicted = (n * 2) ** k - n ** k
        ok = "OK" if set(counts) == {predicted} else "MISMATCH"
        print(f"  n={n} k={k}: counts={counts}  predicted S={predicted} [{ok}]")
    print()


def demo_existence_threshold() -> None:
    print("=" * 70)
    print("3. Integer threshold  2^n*S^m < (2n)^(km)  matches brute UNSAT")
    print("=" * 70)
    for n, k in [(2, 2), (2, 3)]:
        for m in range(1, 8):
            forced = forced_unsat(n, k, m)
            actual = brute_exists_unsat(n, k, m)
            # 'forced' is one-directional: forced ==> actual. Both shown.
            ok = "OK" if (not forced or actual) else "VIOLATION"
            print(f"  n={n} k={k} m={m}: forced_by_first_moment={forced!s:>5}  "
                  f"actually_has_unsat={actual!s:>5}  [{ok}]")
        print()


def demo_density_and_monotonicity() -> None:
    print("=" * 70)
    print("4. Density form 2^n*(1-2^-k)^m < 1 and monotonicity in m")
    print("=" * 70)
    n, k = 20, 3
    print(f"  n={n}, k={k}:  E[Z] = 2^n (1 - 2^-k)^m")
    prev = math.inf
    crossed_at = None
    for m in range(0, 200, 10):
        ez = annealed_density_value(n, k, m)
        mono = "non-increasing" if ez <= prev else "INCREASED!"
        if ez < 1.0 and crossed_at is None:
            crossed_at = m
        print(f"    m={m:>3}: E[Z]={ez:14.4f}   ({mono})")
        prev = ez
    print(f"  First m with E[Z] < 1 (UNSAT forced): m ~ {crossed_at}")
    print(f"  First-moment density bound alpha_1(3) = "
          f"{first_moment_threshold_density(3):.4f} clauses/variable")
    print(f"  (empirical 3-SAT threshold alpha_c(3) ~ 4.267; "
          f"first moment is an upper bound)")
    print()


def demo_qary() -> None:
    print("=" * 70)
    print("5. q-ary first moment  q^n*((nq)^k - (n(q-1))^k)^m")
    print("=" * 70)
    for n, k, m, q in [(2, 2, 1, 3), (1, 2, 2, 3), (2, 2, 1, 2)]:
        predicted = first_moment_formula(n, k, m, q)
        actual = brute_first_moment(n, k, m, q)
        ok = "OK" if predicted == actual else "MISMATCH"
        print(f"  q={q} n={n} k={k} m={m}: predicted={predicted:>10}  "
              f"brute={actual:>10}  [{ok}]")
    print("  Density factor 1 - ((q-1)/q)^k reduces to 1 - 2^-k at q=2:")
    for k in [2, 3, 4]:
        b = 1.0 - (1 / 2) ** k
        q3 = 1.0 - (2 / 3) ** k
        print(f"    k={k}: Boolean(q=2)={b:.4f},  q=3 factor={q3:.4f}")
    print()


def main() -> None:
    demo_first_moment_identity()
    demo_constant_S()
    demo_existence_threshold()
    demo_density_and_monotonicity()
    demo_qary()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()


"""Visualization: the annealed free energy crossing for random k-SAT.

Plots E[Z] = 2^n (1 - 2^-k)^m on a log scale against the clause count m, for
several clause widths k, marking the freezing point E[Z] = 1 where an
unsatisfiable formula becomes forced. Requires matplotlib.
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt


def annealed(n: int, k: int, m: int) -> float:
    """E[Z] = 2^n (1 - 2^-k)^m."""
    return (2 ** n) * (1.0 - 2.0 ** (-k)) ** m


def main() -> None:
    n: int = 50
    ks: List[int] = [2, 3, 4, 5]
    fig, ax = plt.subplots(figsize=(8, 5))
    for k in ks:
        ms = list(range(0, int(3 * n * (2 ** k) * math.log(2)) + 1,
                         max(1, n // 25)))
        ez = [annealed(n, k, m) for m in ms]
        alphas = [m / n for m in ms]
        ax.plot(alphas, ez, label=f"k = {k}")
    ax.axhline(1.0, color="black", linestyle="--", linewidth=1,
               label="freezing point  E[Z] = 1")
    ax.set_yscale("log")
    ax.set_xlabel("clause density  alpha = m / n")
    ax.set_ylabel("annealed first moment  E[Z]")
    ax.set_title(f"First-moment freezing of random k-SAT  (n = {n})")
    ax.legend()
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    fig.savefig("threshold_crossing.png", dpi=150)
    print("Wrote threshold_crossing.png")


if __name__ == "__main__":
    main()
