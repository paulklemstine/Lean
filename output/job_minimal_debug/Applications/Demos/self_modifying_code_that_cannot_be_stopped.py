#!/usr/bin/env python3
"""
Self-Modifying Computation: Numerical Demonstrations
=====================================================

Demonstrates the key results from the formalization of self-modifying
machines and the halting problem:

1. The diagonal argument: constructing a function that escapes any enumeration.
2. Self-modifying machine simulation: showing behavioral equivalence.
3. Pigeonhole bound on self-modification depth.
4. Adaptive adversary defeating any classifier.
5. Fixed-point delay in finite self-modifying systems.
"""

from __future__ import annotations
from typing import Callable, Optional


# ===========================================================================
# Demo 1: The Diagonal Argument
# ===========================================================================

def demo_diagonal_argument() -> None:
    """
    Demonstrate the diagonal argument: given any enumeration of Boolean
    predicates on {0,...,n-1}, the anti-diagonal predicate disagrees with
    every enumerated predicate on its own index.

    This is the engine behind all halting-problem impossibility results.
    """
    print("=" * 70)
    print("DEMO 1: The Diagonal Argument")
    print("=" * 70)

    # An enumeration of 5 Boolean predicates on {0,1,2,3,4}
    enum: list[list[bool]] = [
        [True,  False, True,  False, True ],  # predicate 0
        [False, True,  False, True,  False],  # predicate 1
        [True,  True,  False, False, True ],  # predicate 2
        [False, False, True,  True,  True ],  # predicate 3
        [True,  False, False, True,  False],  # predicate 4
    ]
    n = len(enum)

    print(f"\nEnumeration of {n} predicates on {{0,...,{n-1}}}:")
    for i, pred in enumerate(enum):
        diag_marker = " <-- diagonal" if i < n else ""
        vals = ", ".join(
            f"*{str(v):>5}*" if j == i else f" {str(v):>5} "
            for j, v in enumerate(pred)
        )
        print(f"  enum[{i}] = [{vals}]{diag_marker}")

    # Extract diagonal
    diagonal = [enum[i][i] for i in range(n)]
    anti_diagonal = [not enum[i][i] for i in range(n)]

    print(f"\nDiagonal entries:      {diagonal}")
    print(f"Anti-diagonal (flipped): {anti_diagonal}")

    # Verify anti-diagonal differs from every row at its index
    print("\nVerification: anti-diagonal ≠ enum[i] at position i:")
    for i in range(n):
        assert anti_diagonal[i] != enum[i][i], "Diagonal argument failed!"
        print(f"  anti_diagonal[{i}] = {anti_diagonal[i]} ≠ enum[{i}][{i}] = {enum[i][i]}  ✓")

    print("\n→ The anti-diagonal cannot appear in any enumeration.")
    print("  This is why the halting problem is undecidable.\n")


# ===========================================================================
# Demo 2: Self-Modifying Machine Simulation
# ===========================================================================

def demo_selfmod_simulation() -> None:
    """
    Demonstrate that a self-modifying machine can be perfectly simulated
    by a standard (fixed-program) machine.

    We build a self-modifying machine where the "program" is an integer
    that gets modified at each step, and show the standard simulation
    produces identical behavior.
    """
    print("=" * 70)
    print("DEMO 2: Self-Modifying Machine ↔ Standard Simulation")
    print("=" * 70)

    # Self-modifying machine: program is an int, state is an int.
    # step(p, s) = Some(p + 1, s * p) if s < 1000, else None (halt)
    def selfmod_step(prog: int, state: int) -> Optional[tuple[int, int]]:
        if state >= 1000:
            return None  # halt
        return (prog + 1, state + prog)

    # Run self-modifying machine
    def run_selfmod(
        prog: int, state: int, max_steps: int
    ) -> list[tuple[int, int, str]]:
        trace: list[tuple[int, int, str]] = []
        for step in range(max_steps):
            result = selfmod_step(prog, state)
            if result is None:
                trace.append((prog, state, "HALT"))
                return trace
            trace.append((prog, state, "→"))
            prog, state = result
        trace.append((prog, state, "..."))
        return trace

    # Standard simulation: state = (prog, data), fixed step function
    def std_step(combined: tuple[int, int]) -> Optional[tuple[int, int]]:
        prog, state = combined
        result = selfmod_step(prog, state)
        if result is None:
            return None
        return result

    def run_std(
        prog: int, state: int, max_steps: int
    ) -> list[tuple[int, int, str]]:
        trace: list[tuple[int, int, str]] = []
        combined = (prog, state)
        for step in range(max_steps):
            result = std_step(combined)
            if result is None:
                trace.append((combined[0], combined[1], "HALT"))
                return trace
            trace.append((combined[0], combined[1], "→"))
            combined = result
        trace.append((combined[0], combined[1], "..."))
        return trace

    init_prog, init_state = 1, 0
    max_steps = 100

    sm_trace = run_selfmod(init_prog, init_state, max_steps)
    std_trace = run_std(init_prog, init_state, max_steps)

    print(f"\nInitial: prog={init_prog}, state={init_state}")
    print(f"\nSelf-modifying machine trace (first 10 steps + last):")
    for i, (p, s, status) in enumerate(sm_trace[:10]):
        print(f"  Step {i:3d}: prog={p:4d}, state={s:6d} {status}")
    if len(sm_trace) > 10:
        p, s, status = sm_trace[-1]
        print(f"  ...{len(sm_trace) - 11} steps omitted...")
        print(f"  Step {len(sm_trace)-1:3d}: prog={p:4d}, state={s:6d} {status}")

    # Verify equivalence
    match = all(
        sm_trace[i] == std_trace[i] for i in range(len(sm_trace))
    )
    print(f"\nStandard simulation produces identical trace: {match}  ✓")
    print(f"Both machines halt at step {len(sm_trace) - 1}.")
    print("\n→ Self-modification adds no computational power.\n")


# ===========================================================================
# Demo 3: Pigeonhole Bound on Self-Modification Depth
# ===========================================================================

def demo_pigeonhole_bound() -> None:
    """
    Demonstrate the pigeonhole principle for finite self-modifying systems:
    in a system with n possible states, the orbit of self-modification
    must cycle within at most n steps.
    """
    print("=" * 70)
    print("DEMO 3: Pigeonhole Bound on Self-Modification Depth")
    print("=" * 70)

    def iterate_and_find_cycle(
        f: Callable[[int], int], start: int, n: int
    ) -> tuple[list[int], int, int]:
        """Return orbit, first repeated index i, and matching index j (i < j)."""
        orbit: list[int] = [start]
        seen: dict[int, int] = {start: 0}
        x = start
        for step in range(1, n + 2):
            x = f(x)
            orbit.append(x)
            if x in seen:
                return orbit, seen[x], step
            seen[x] = step
        return orbit, -1, -1  # should not happen for finite types

    # Example 1: permutation on {0,...,5} (n=6)
    n = 6
    perm = [2, 4, 0, 5, 3, 1]  # a permutation of {0,...,5}
    f1: Callable[[int], int] = lambda x: perm[x]

    orbit, i, j = iterate_and_find_cycle(f1, 0, n)

    print(f"\nExample 1: Permutation on {{0,...,{n-1}}}")
    print(f"  f = {perm}")
    print(f"  Orbit from 0: {' → '.join(map(str, orbit))}")
    print(f"  Collision: f^{i}(0) = f^{j}(0) = {orbit[i]}")
    print(f"  j = {j} ≤ n = {n}  ✓ (pigeonhole bound)")

    # Example 2: self-modification on {0,...,9} (n=10)
    n2 = 10
    selfmod = [3, 7, 5, 1, 9, 2, 8, 4, 0, 6]
    f2: Callable[[int], int] = lambda x: selfmod[x]

    orbit2, i2, j2 = iterate_and_find_cycle(f2, 0, n2)

    print(f"\nExample 2: Self-modification on {{0,...,{n2-1}}}")
    print(f"  f = {selfmod}")
    print(f"  Orbit from 0: {' → '.join(map(str, orbit2))}")
    print(f"  Collision: f^{i2}(0) = f^{j2}(0) = {orbit2[i2]}")
    print(f"  j = {j2} ≤ n = {n2}  ✓")

    # Example 3: worst case — cycle of length n
    n3 = 8
    cycle_n = [(i + 1) % n3 for i in range(n3)]
    f3: Callable[[int], int] = lambda x: cycle_n[x]

    orbit3, i3, j3 = iterate_and_find_cycle(f3, 0, n3)

    print(f"\nExample 3: Full cycle on {{0,...,{n3-1}}} (worst case)")
    print(f"  f = {cycle_n}")
    print(f"  Orbit from 0: {' → '.join(map(str, orbit3))}")
    print(f"  Collision: f^{i3}(0) = f^{j3}(0) = {orbit3[i3]}")
    print(f"  j = {j3} = n = {n3}  ✓ (bound is tight!)")
    print("\n→ Any orbit in a finite type cycles within n steps.\n")


# ===========================================================================
# Demo 4: Adaptive Adversary Defeating Classifiers
# ===========================================================================

def demo_adaptive_adversary() -> None:
    """
    Demonstrate the adaptive adversary theorem: for ANY classifier
    of adaptive programs, the contrarian program defeats it.
    """
    print("=" * 70)
    print("DEMO 4: Adaptive Adversary (Virus Detection Paradox)")
    print("=" * 70)

    # An adaptive program: given a classifier's output, it reacts
    class AdaptiveProgram:
        def __init__(self, name: str, react: Callable[[bool], bool]) -> None:
            self.name = name
            self.react = react

        def actual_behavior(self, classifier_output: bool) -> bool:
            return self.react(classifier_output)

    # The contrarian: always does the opposite of the classifier's prediction
    contrarian = AdaptiveProgram("contrarian", lambda pred: not pred)

    # Some other programs for context
    always_safe = AdaptiveProgram("always_safe", lambda _: True)
    always_malicious = AdaptiveProgram("always_malicious", lambda _: False)
    copycat = AdaptiveProgram("copycat", lambda pred: pred)

    programs = [always_safe, always_malicious, copycat, contrarian]

    # Try several classifiers
    classifiers: list[tuple[str, Callable[[AdaptiveProgram], bool]]] = [
        ("optimist (always says safe)", lambda p: True),
        ("pessimist (always says malicious)", lambda p: False),
        ("name-based (safe if name contains 'safe')", lambda p: "safe" in p.name),
        ("smart heuristic", lambda p: p.name != "contrarian"),
    ]

    for clf_name, classifier in classifiers:
        print(f"\nClassifier: {clf_name}")
        all_correct = True
        for prog in programs:
            prediction = classifier(prog)
            actual = prog.actual_behavior(prediction)
            correct = prediction == actual
            if not correct:
                all_correct = False
            status = "✓" if correct else "✗ WRONG"
            print(
                f"  {prog.name:20s}: "
                f"predicted={'safe' if prediction else 'malicious':10s}, "
                f"actual={'safe' if actual else 'malicious':10s}  {status}"
            )
        if not all_correct:
            print(f"  → Classifier '{clf_name}' is defeated!")

    print(
        "\n→ No classifier is correct on the contrarian."
        "\n  This is the virus detection paradox: self-modifying malware"
        "\n  that reacts to the scanner cannot be perfectly detected.\n"
    )


# ===========================================================================
# Demo 5: Fixed-Point Delay in Finite Systems
# ===========================================================================

def demo_fixpoint_delay() -> None:
    """
    Demonstrate the tight upper bound on fixed-point delay:
    for n ≥ 2, the maximum number of steps to reach a fixed point
    of f : {0,...,n-1} → {0,...,n-1} is exactly n - 1.
    """
    print("=" * 70)
    print("DEMO 5: Fixed-Point Delay (Tight Bound: n - 1)")
    print("=" * 70)

    def find_fixpoint_delay(f: list[int], start: int) -> Optional[int]:
        """Find minimum k such that f^k(start) = f^{k+1}(start), or None."""
        x = start
        for k in range(len(f) + 1):
            if f[x] == x:
                return k
            x = f[x]
        return None

    def max_fixpoint_delay(n: int) -> tuple[int, list[int], int]:
        """Find the maximum fixed-point delay over all f and starting points."""
        max_delay = 0
        best_f: list[int] = []
        best_start = 0
        # Enumerate all functions f : {0,...,n-1} → {0,...,n-1}
        # with at least one fixed point
        from itertools import product
        for f_tuple in product(range(n), repeat=n):
            f = list(f_tuple)
            # Check if f has a reachable fixed point from each starting point
            for start in range(n):
                delay = find_fixpoint_delay(f, start)
                if delay is not None and delay > max_delay:
                    max_delay = delay
                    best_f = f
                    best_start = start
        return max_delay, best_f, best_start

    print("\nComputing maximum fixed-point delay for small n:")
    print(f"  {'n':>3s} | {'max delay':>10s} | {'bound (n-1)':>11s} | {'tight?':>7s}")
    print(f"  {'-'*3}-+-{'-'*10}-+-{'-'*11}-+-{'-'*7}")

    for n in range(2, 7):
        delay, best_f, best_start = max_fixpoint_delay(n)
        bound = n - 1
        tight = "YES" if delay == bound else "no"
        print(f"  {n:3d} | {delay:10d} | {bound:11d} | {tight:>7s}")

    # Show a concrete worst-case example
    n_ex = 5
    delay_ex, f_ex, start_ex = max_fixpoint_delay(n_ex)
    print(f"\nWorst case for n = {n_ex}:")
    print(f"  f = {f_ex}")
    print(f"  Starting from {start_ex}:")
    x = start_ex
    steps: list[str] = [str(x)]
    for k in range(delay_ex + 1):
        x = f_ex[x]
        steps.append(str(x))
    print(f"  Orbit: {' → '.join(steps)}")
    print(f"  Fixed point reached at step {delay_ex} = n - 1 = {n_ex - 1}  ✓")
    print("\n→ The bound n - 1 is tight for all n ≥ 2.\n")


# ===========================================================================
# Demo 6: Lawvere's Fixed-Point Theorem
# ===========================================================================

def demo_lawvere() -> None:
    """
    Demonstrate Lawvere's fixed-point theorem: if e : A → (A → B) is
    surjective, every endomorphism t : B → B has a fixed point.
    Contrapositive: if t has no fixed point, e cannot be surjective.
    """
    print("=" * 70)
    print("DEMO 6: Lawvere's Fixed-Point Theorem")
    print("=" * 70)

    # Bool with negation: no fixed point
    print("\nBool with negation (t = not):")
    print("  not(True)  = False ≠ True")
    print("  not(False) = True  ≠ False")
    print("  → no fixed point of 'not'")
    print("  → by Lawvere's theorem, no surjection ℕ → (ℕ → Bool) exists")

    # Integers mod 3 with +1: no fixed point
    print("\nℤ/3ℤ with t(x) = x + 1 mod 3:")
    for x in range(3):
        tx = (x + 1) % 3
        print(f"  t({x}) = {tx} {'= ' if tx == x else '≠ '}{x}")
    print("  → no fixed point")
    print("  → no surjection α → (α → ℤ/3ℤ) exists")

    # Positive example: t(x) = x² mod 5 has fixed points 0, 1
    print("\nℤ/5ℤ with t(x) = x² mod 5 (has fixed points):")
    for x in range(5):
        tx = (x * x) % 5
        fp = " ← FIXED POINT" if tx == x else ""
        print(f"  t({x}) = {tx}{fp}")
    print("  → fixed points exist, so Lawvere's theorem is consistent")
    print("    (but does NOT require a surjection to exist)\n")


# ===========================================================================
# Main
# ===========================================================================

def main() -> None:
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Self-Modifying Computation: Numerical Demonstrations              ║")
    print("║  Companion to the machine-verified proofs in Lean 4                ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_diagonal_argument()
    demo_selfmod_simulation()
    demo_pigeonhole_bound()
    demo_adaptive_adversary()
    demo_fixpoint_delay()
    demo_lawvere()

    print("=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()
