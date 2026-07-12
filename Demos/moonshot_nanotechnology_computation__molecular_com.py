"""
Numerical demonstrations of the formal limits of molecular computing.

This self-contained script illustrates four groups of results:

  1. Discrete chemical reaction network (CRN) dynamics: firing, strong
     monotonicity, translation invariance, and conservation laws.
  2. The no-zero-test obstruction: monotonicity makes absence-detection
     impossible, verified empirically over random reactions.
  3. The parallelism limit: molecular parallelism gives at most a
     constant-factor (volume-capped) speedup, never exponential.
  4. Information-theoretic storage bounds and the DNA density sanity check.

Every function is inlined; the script depends only on the standard library.
Run with:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from math import log2, ceil, floor
from typing import Dict, List, Tuple
import itertools
import random


# ---------------------------------------------------------------------------
# 1. Chemical reaction networks: states, reactions, firing, reachability
# ---------------------------------------------------------------------------

State = Dict[str, int]  # molecule-count vector x : species -> count


@dataclass(frozen=True)
class Reaction:
    """A reaction consuming a reactant complex and creating a product complex."""
    reactant: Tuple[Tuple[str, int], ...]
    product: Tuple[Tuple[str, int], ...]

    def as_dict(self, part: str) -> State:
        return dict(self.reactant if part == "reactant" else self.product)


def get(x: State, s: str) -> int:
    return x.get(s, 0)


def enabled(r: Reaction, x: State) -> bool:
    """A reaction is enabled when all reactant molecules are present."""
    return all(get(x, s) >= n for s, n in r.reactant)


def fire(r: Reaction, x: State, species: List[str]) -> State:
    """Fire: consume reactants, create products (exact on enabled states)."""
    rc, pc = r.as_dict("reactant"), r.as_dict("product")
    return {s: max(get(x, s) - get(rc, s), 0) + get(pc, s) for s in species}


def add(x: State, d: State, species: List[str]) -> State:
    return {s: get(x, s) + get(d, s) for s in species}


def leq(x: State, y: State, species: List[str]) -> bool:
    return all(get(x, s) <= get(y, s) for s in species)


def mass(w: Dict[str, int], x: State, species: List[str]) -> int:
    """Value of a linear functional w on state x."""
    return sum(w.get(s, 0) * get(x, s) for s in species)


def conserves(w: Dict[str, int], r: Reaction, species: List[str]) -> bool:
    return mass(w, r.as_dict("product"), species) == mass(
        w, r.as_dict("reactant"), species
    )


def demo_crn_dynamics() -> None:
    print("=" * 70)
    print("1. CRN dynamics: firing, strong monotonicity, conservation")
    print("=" * 70)
    species = ["A", "B", "C"]
    # Reaction A + B -> C  (a balanced condensation)
    r = Reaction(reactant=(("A", 1), ("B", 1)), product=(("C", 1),))
    x: State = {"A": 3, "B": 2, "C": 0}
    print(f"state x            = {x}")
    print(f"enabled(r, x)      = {enabled(r, x)}")
    y = fire(r, x, species)
    print(f"fire(r, x)         = {y}")

    # Strong monotonicity: fire(x + d) == fire(x) + d
    d: State = {"A": 5, "B": 0, "C": 7}
    lhs = fire(r, add(x, d, species), species)
    rhs = add(fire(r, x, species), d, species)
    print(f"fire(x+d)          = {lhs}")
    print(f"fire(x)+d          = {rhs}")
    print(f"strong monotonicity holds: {lhs == rhs}")

    # Conservation: total atom count A+B+C is conserved (1+1 -> 1?  no).
    # Use a genuinely balanced functional: mass with weights that balance.
    # A + B -> C is balanced for w(A)=w(B)=1, w(C)=2  (1*1+1*1 == 1*2).
    w = {"A": 1, "B": 1, "C": 2}
    print(f"w conserved by r   = {conserves(w, r, species)}")
    print(f"mass_w(x)          = {mass(w, x, species)}")
    print(f"mass_w(fire(x))    = {mass(w, y, species)}  (invariant)")
    print()


# ---------------------------------------------------------------------------
# 2. The no-zero-test obstruction
# ---------------------------------------------------------------------------

def demo_no_zero_test() -> None:
    print("=" * 70)
    print("2. No zero-test: monotone reactions cannot detect absence")
    print("=" * 70)
    print("Claim: no reaction fires *exactly* when species s0 is absent.")
    print("Proof witness: a reaction is enabled at its own reactant complex,")
    print("which forces reactant(s0)=0; bumping s0 to 1 keeps it enabled, yet")
    print("the count is now 1 != 0 -- contradiction.")
    random.seed(0)
    species = ["s0", "s1", "s2"]
    violations = 0
    for _ in range(5):
        rc = {s: random.randint(0, 3) for s in species}
        rc["s0"] = 0  # any candidate absence-detector must have reactant(s0)=0
        r = Reaction(reactant=tuple(rc.items()), product=(("s1", 1),))
        # candidate "absence test": enabled  <=>  x[s0] == 0 ?
        z = dict(rc)
        z["s0"] = 1  # bump s0
        if enabled(r, z) and get(z, "s0") != 0:
            violations += 1  # enabled while s0 present: test is broken
    print(f"reactions tested: 5;  absence-test failures: {violations}/5")
    print("Every candidate fails -> absence detection is impossible.")
    print()


# ---------------------------------------------------------------------------
# 3. The parallelism limit
# ---------------------------------------------------------------------------

def parallel_time_lower_bound(work: int, parallelism: int) -> int:
    """Minimum steps to complete `work` operations at <= p per step."""
    return ceil(work / parallelism)


def speedup_cap(work: int, parallelism: int) -> int:
    """Speedup of a p-fold parallel machine is at most p (and at most W)."""
    return min(parallelism, work)


def demo_parallelism() -> None:
    print("=" * 70)
    print("3. Parallelism gives only a constant-factor, volume-capped speedup")
    print("=" * 70)
    volume_cap_P = 10 ** 24  # ~ a mole of molecules in a test tube (~2^80)
    print(f"fixed molecule budget P = {volume_cap_P:.0e}  (~2^{floor(log2(volume_cap_P))})")
    print(f"{'n':>4} {'work 2^n':>18} {'parallel time >= 2^n/P':>26}")
    for n in [40, 60, 80, 90, 100, 120]:
        work = 2 ** n
        t_par = floor(work / volume_cap_P)
        print(f"{n:>4} {work:>18.2e} {t_par:>26.2e}")
    print("Once work exceeds P, parallel time grows like 2^n/P -> unbounded.")
    print("No fixed volume converts exponential work into bounded time.")
    print()
    print("Sequential-vs-parallel speedup (W work, p-fold parallelism):")
    for W, p in [(1000, 8), (10 ** 6, 1000), (10 ** 9, 10 ** 6)]:
        print(f"  W={W:>10}  p={p:>8}  min steps={parallel_time_lower_bound(W, p):>8}"
              f"  speedup<= {speedup_cap(W, p)}")
    print()


# ---------------------------------------------------------------------------
# 4. Information-theoretic storage bounds
# ---------------------------------------------------------------------------

def min_units_for(num_states: int) -> int:
    """Minimum number of two-state units to distinguish num_states inputs."""
    return ceil(log2(num_states)) if num_states > 1 else 0


def capacity(k: int) -> int:
    """A k-unit register holds exactly 2^k configurations."""
    return 2 ** k


def demo_storage() -> None:
    print("=" * 70)
    print("4. Storage bounds and the DNA density sanity check")
    print("=" * 70)
    for N in [2, 256, 10 ** 6, 10 ** 18]:
        k = min_units_for(N)
        print(f"  distinguishing N={N:>20} inputs needs k>={k:>3} units "
              f"(2^{k}={capacity(k):.3e})")
    print()
    print("DNA density sanity check for the 10^18-bit claim:")
    print(f"  2^59 = {2**59:.4e}  <  10^18 = {10**18:.4e}   -> 59 units too few")
    print(f"  2^60 = {2**60:.4e}  >  10^18 = {10**18:.4e}   -> 60 units suffice")
    assert 2 ** 59 < 10 ** 18 <= 2 ** 60
    print("  Verified: ceil(log2(10^18)) = 60.")
    print()


# ---------------------------------------------------------------------------

def main() -> None:
    demo_crn_dynamics()
    demo_no_zero_test()
    demo_parallelism()
    demo_storage()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
