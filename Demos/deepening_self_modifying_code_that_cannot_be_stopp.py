"""
Numerical demonstrations for:

    A Fixed-Point Bridge: Self-Modifying Halting and Lawvere-Cantor Diagonalization

This self-contained script illustrates, with small executable models, the core
results of the paper:

  1. Lawvere's fixed-point theorem and its contrapositive, Cantor's theorem
     (Boolean form), over finite types.
  2. The self-modifying machine model, its run/halts semantics, and the
     Simulation Theorem: a self-modifying machine halts iff its fixed-program
     ("code as data") simulation halts.
  3. A concrete "diagonal machine" whose halting predicate equals a bounded
     universal evaluator's halting behaviour -- the Bridge Lemma -- illustrating
     that self-modifying halting reduces to classical halting.
  4. A behavioral fixed point (Kleene recursion theorem) illustrated on a finite
     universe of programs closed under a rewriting rule.

Everything is finite/bounded so it runs instantly and deterministically. No
external dependencies.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Optional, Tuple


# ---------------------------------------------------------------------------
# 1. Lawvere / Cantor over finite types
# ---------------------------------------------------------------------------

def all_predicates(domain: List[int]) -> List[Tuple[bool, ...]]:
    """Enumerate every Boolean predicate on `domain` as a truth-value tuple."""
    return list(product([False, True], repeat=len(domain)))


def is_point_surjective(
    g: Callable[[int], Tuple[bool, ...]], domain: List[int]
) -> bool:
    """Check whether g : A -> (A -> Bool) reaches every predicate on `domain`."""
    reached = {g(a) for a in domain}
    return reached == set(all_predicates(domain))


def diagonal_predicate_missing(
    g: Callable[[int], Tuple[bool, ...]], domain: List[int]
) -> Tuple[bool, ...]:
    """
    Cantor's diagonal: the predicate d(a) = NOT g(a)(a).
    By construction d differs from every g(a) at input a, so it is never reached.
    """
    return tuple((not g(idx_a)[idx_a]) for idx_a, _ in enumerate(domain))


def demo_cantor() -> None:
    print("=" * 70)
    print("1. Lawvere / Cantor (Boolean form) over a finite type")
    print("=" * 70)
    for n in (1, 2, 3):
        domain = list(range(n))
        num_preds = 2 ** n
        # There are n^(2^n) functions g : A -> (A -> Bool); we brute-force check
        # that NONE of them is point-surjective, confirming Cantor's theorem.
        preds = all_predicates(domain)
        found_surjective = False
        for assignment in product(preds, repeat=n):
            g = lambda a, _asg=assignment: _asg[a]
            if is_point_surjective(g, domain):
                found_surjective = True
                break
        print(
            f"  |A| = {n}: {num_preds} predicates, "
            f"any g : A -> (A -> Bool) surjective? {found_surjective}"
        )
    # Show the diagonal witness for one explicit (non-surjective) g.
    domain = [0, 1, 2]
    g = lambda a: {0: (True, False, True),
                   1: (False, False, True),
                   2: (True, True, True)}[a]
    missing = diagonal_predicate_missing(g, domain)
    print(f"  Explicit g on |A|=3; diagonal predicate never in image: {missing}")
    print()


# ---------------------------------------------------------------------------
# 2. Self-modifying machines and the Simulation Theorem
# ---------------------------------------------------------------------------

Config = Tuple[object, object]  # (program, state)
Step = Callable[[object, object], Optional[Config]]


def selfmod_run(step: Step, config: Config, n: int) -> Optional[Config]:
    """Run a self-modifying machine for n steps; None means it halted."""
    cur: Optional[Config] = config
    for _ in range(n):
        assert cur is not None
        nxt = step(cur[0], cur[1])
        if nxt is None:
            return None
        cur = nxt
    return cur


def selfmod_halts(step: Step, config: Config, bound: int) -> bool:
    """Does the machine halt within `bound` steps?"""
    return any(selfmod_run(step, config, n) is None for n in range(bound + 1))


def to_std_step(step: Step) -> Callable[[Config], Optional[Config]]:
    """
    Standard simulation: absorb the program into the combined state (P x S).
    The returned step takes and returns a single Config value.
    """
    def std(ps: Config) -> Optional[Config]:
        return step(ps[0], ps[1])
    return std


def std_run(
    step: Callable[[Config], Optional[Config]], config: Config, n: int
) -> Optional[Config]:
    cur: Optional[Config] = config
    for _ in range(n):
        assert cur is not None
        cur = step(cur)
        if cur is None:
            return None
    return cur


def std_halts(
    step: Callable[[Config], Optional[Config]], config: Config, bound: int
) -> bool:
    return any(std_run(step, config, n) is None for n in range(bound + 1))


def demo_simulation() -> None:
    print("=" * 70)
    print("2. Simulation Theorem: self-modifying halts iff fixed-program halts")
    print("=" * 70)

    # A genuinely self-modifying machine over programs {"inc", "dec"} and an
    # integer state. "inc" adds 1 and flips to "dec"; "dec" subtracts 1 and
    # flips to "inc"; the machine halts when the state hits 0.
    def step(prog: object, state: object) -> Optional[Config]:
        s = int(state)  # type: ignore[arg-type]
        if s == 0:
            return None
        if prog == "inc":
            return ("dec", s + 1)
        return ("inc", s - 1)

    std = to_std_step(step)
    bound = 50
    print(f"  {'start':>16} | self-mod halts | std-sim halts | agree")
    print("  " + "-" * 60)
    for start in [("inc", 0), ("inc", 1), ("dec", 1), ("inc", 3), ("dec", 5)]:
        a = selfmod_halts(step, start, bound)
        b = std_halts(std, start, bound)
        print(f"  {str(start):>16} | {str(a):>13} | {str(b):>12} | {a == b}")
    print()


# ---------------------------------------------------------------------------
# 3. The diagonal machine and the Bridge Lemma
# ---------------------------------------------------------------------------
#
# We model a tiny "universal evaluator" evaln(budget, code, input): a program is
# a Python callable that, on input n, either converges to a value (returning it)
# or diverges. We simulate a step budget by capping an internal loop counter.

Program = Callable[[int, int], Optional[int]]
# signature: prog(n, budget) -> output or None if not yet converged in `budget`


def evaln(budget: int, prog: Program, n: int) -> Optional[int]:
    """Bounded universal evaluator: run `prog` on `n` with the given budget."""
    return prog(n, budget)


def diag_step(prog_code: Program, input_n: int) -> Step:
    """
    Build the self-modifying diagonal machine's step. State is the budget s.
    step(c, s) = halt if evaln(s, c, n) converged, else (c, s+1).
    The program component (the code c) never changes -- a fixed program is a
    special self-modifying one -- yet halting is exactly classical halting.
    """
    def step(_c: object, s: object) -> Optional[Config]:
        budget = int(s)  # type: ignore[arg-type]
        if evaln(budget, prog_code, input_n) is not None:
            return None
        return (prog_code, budget + 1)
    return step


def classical_halts(prog: Program, n: int, bound: int) -> bool:
    """Does prog on input n converge within some budget <= bound?"""
    return any(evaln(b, prog, n) is not None for b in range(bound + 1))


def demo_bridge() -> None:
    print("=" * 70)
    print("3. Bridge Lemma: diagonal machine halts iff the program halts")
    print("=" * 70)

    # Program A: converges on input n after exactly n internal steps.
    def prog_converges_at_n(n: int, budget: int) -> Optional[int]:
        return 42 if budget >= n else None

    # Program B: converges only on even inputs (after 2 steps); diverges on odd.
    def prog_even_only(n: int, budget: int) -> Optional[int]:
        if n % 2 == 0:
            return 7 if budget >= 2 else None
        return None

    bound = 30
    print(f"  {'program':>22} | input | diag halts | classical halts | agree")
    print("  " + "-" * 74)
    cases: List[Tuple[str, Program, int]] = [
        ("converges_at_n", prog_converges_at_n, 5),
        ("converges_at_n", prog_converges_at_n, 20),
        ("even_only", prog_even_only, 4),
        ("even_only", prog_even_only, 7),
    ]
    for name, prog, n in cases:
        step = diag_step(prog, n)
        dm = selfmod_halts(step, (prog, 0), bound)
        ch = classical_halts(prog, n, bound)
        print(f"  {name:>22} | {n:>5} | {str(dm):>10} | {str(ch):>15} | {dm == ch}")
    print()


# ---------------------------------------------------------------------------
# 4. Behavioral fixed point (Kleene recursion) on a finite program universe
# ---------------------------------------------------------------------------

def demo_kleene() -> None:
    print("=" * 70)
    print("4. Behavioral fixed point: a rewrite that cannot change every program")
    print("=" * 70)

    # Finite universe of programs, each denoting a function on {0,1,2}.
    # "behavior" maps a code to its input->output table (a tuple).
    behavior: Dict[str, Tuple[int, ...]] = {
        "id":     (0, 1, 2),
        "shift":  (1, 2, 0),
        "zero":   (0, 0, 0),
        "id2":    (0, 1, 2),   # a DIFFERENT code with the SAME behavior as "id"
    }

    # A computable rewrite rule on codes.
    modify: Dict[str, str] = {
        "id": "id2",       # changes the text (id -> id2)
        "id2": "id",       # ... and back
        "shift": "zero",
        "zero": "shift",
    }

    print("  code   behavior      modify(code)  behavior      same behavior?")
    print("  " + "-" * 62)
    fixed_points: List[str] = []
    for code, beh in behavior.items():
        m = modify[code]
        same = behavior[m] == beh
        if same:
            fixed_points.append(code)
        print(f"  {code:<6} {str(beh):<13} {m:<13} {str(behavior[m]):<13} {same}")
    print(f"\n  Behavioral fixed point(s) modify cannot change: {fixed_points}")
    print("  (e.g. 'id' -> 'id2': text differs, behavior is identical.)")
    print()


# ---------------------------------------------------------------------------

def main() -> None:
    demo_cantor()
    demo_simulation()
    demo_bridge()
    demo_kleene()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
