#!/usr/bin/env python3
"""
Algorithms for Theory Adjunction Discovery and Verification.

Implements computational tools for:
1. Verifying Galois connections between research theories
2. Searching for adjoint pairs given a left adjoint
3. Computing unit/counit inequalities
4. Detecting impossibility obstructions
"""

from typing import Callable, Optional, Tuple, List
from dataclasses import dataclass


@dataclass
class FiniteTheory:
    """A research theory with finite carrier (represented as list of elements).

    Args:
        name: Human-readable name
        carrier: List of carrier elements
        inv: Invariant function mapping elements to natural numbers
    """
    name: str
    carrier: list
    inv: Callable

    def theory_le(self, x, y) -> bool:
        """Invariant preorder: x ≤_T y iff Inv(x) ≤ Inv(y)."""
        return self.inv(x) <= self.inv(y)


@dataclass
class FiniteMorphism:
    """A theory morphism between finite theories.

    Time complexity: O(|carrier|) to verify monotonicity.
    Space complexity: O(1) beyond the function itself.
    """
    name: str
    source: FiniteTheory
    target: FiniteTheory
    to_fun: Callable

    def verify_monotonicity(self) -> Tuple[bool, Optional[object]]:
        """Verify that Inv_T(x) ≤ Inv_U(F(x)) for all x.

        Returns:
            (True, None) if monotone, (False, counterexample) otherwise.

        Time: O(|source.carrier|)
        """
        for x in self.source.carrier:
            if self.source.inv(x) > self.target.inv(self.to_fun(x)):
                return False, x
        return True, None


def verify_galois_connection(
    F: FiniteMorphism,
    G: FiniteMorphism
) -> Tuple[bool, Optional[Tuple]]:
    """Verify the Galois connection: Inv_U(F(x)) ≤ Inv_U(y) ↔ Inv_T(x) ≤ Inv_T(G(y)).

    Time: O(|source| × |target|)
    Space: O(1)

    Args:
        F: Left adjoint candidate (source → target)
        G: Right adjoint candidate (target → source)

    Returns:
        (True, None) if Galois connection holds, (False, (x, y)) otherwise.
    """
    T, U = F.source, G.source
    for x in T.carrier:
        for y in U.carrier:
            lhs = U.inv(F.to_fun(x)) <= U.inv(y)
            rhs = T.inv(x) <= T.inv(G.to_fun(y))
            if lhs != rhs:
                return False, (x, y)
    return True, None


def compute_unit_counit(
    F: FiniteMorphism,
    G: FiniteMorphism
) -> Tuple[List[Tuple], List[Tuple]]:
    """Compute unit and counit values for all carrier elements.

    Unit: (x, Inv(x), Inv(G(F(x)))) for each x in source
    Counit: (y, Inv(F(G(y))), Inv(y)) for each y in target

    Time: O(|source| + |target|)

    Returns:
        (unit_data, counit_data) where each is a list of tuples.
    """
    T, U = F.source, G.source

    unit_data = []
    for x in T.carrier:
        gfx = G.to_fun(F.to_fun(x))
        unit_data.append((x, T.inv(x), T.inv(gfx)))

    counit_data = []
    for y in U.carrier:
        fgy = F.to_fun(G.to_fun(y))
        counit_data.append((y, U.inv(fgy), U.inv(y)))

    return unit_data, counit_data


def search_right_adjoint(
    F: FiniteMorphism,
    target_carrier: list,
    source_carrier: list
) -> Optional[Callable]:
    """Search for a right adjoint G to F by brute force over all possible maps.

    For each candidate G: target → source, checks the Galois connection.
    Exponential in general but feasible for small finite carriers.

    Time: O(|source|^|target| × |source| × |target|) — exponential!
    Space: O(|target|) for storing the candidate map.

    Args:
        F: The left adjoint
        target_carrier: Carrier of the target theory (domain of G)
        source_carrier: Carrier of the source theory (codomain of G)

    Returns:
        A function G if found, None otherwise.
    """
    import itertools

    T, U = F.source, F.target

    # Generate all possible maps target → source
    for combo in itertools.product(source_carrier, repeat=len(target_carrier)):
        g_map = dict(zip(target_carrier, combo))
        g_fun = lambda y, m=g_map: m[y]

        # Check monotonicity of G
        mono_ok = all(
            U.inv(y) <= T.inv(g_fun(y))
            for y in target_carrier
        )
        if not mono_ok:
            continue

        # Check Galois connection
        gc_ok = True
        for x in source_carrier:
            for y in target_carrier:
                lhs = U.inv(F.to_fun(x)) <= U.inv(y)
                rhs = T.inv(x) <= T.inv(g_fun(y))
                if lhs != rhs:
                    gc_ok = False
                    break
            if not gc_ok:
                break

        if gc_ok:
            return g_fun

    return None


def detect_impossibility(
    F: FiniteMorphism,
    target_carrier: list,
    source_carrier: list
) -> Optional[Tuple[object, str]]:
    """Detect if a right adjoint to F is provably impossible.

    Strategy: For each y in target, compute the constraints on G(y):
    - Monotonicity: U.Inv(y) ≤ T.Inv(G(y))
    - Counit: U.Inv(F(G(y))) ≤ U.Inv(y)

    If no element of source satisfies both constraints for some y,
    return (y, explanation).

    Time: O(|target| × |source|)
    Space: O(1)
    """
    T, U = F.source, F.target

    for y in target_carrier:
        feasible = False
        for g_y in source_carrier:
            mono_ok = U.inv(y) <= T.inv(g_y)
            counit_ok = U.inv(F.to_fun(g_y)) <= U.inv(y)
            if mono_ok and counit_ok:
                feasible = True
                break

        if not feasible:
            return (y, f"No g_val in source satisfies both "
                      f"U.Inv({y}) = {U.inv(y)} ≤ T.Inv(g_val) AND "
                      f"U.Inv(F(g_val)) ≤ U.Inv({y}) = {U.inv(y)}")

    return None


# ── Demonstrations ──────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("ALGORITHM DEMO: Adjunction Search and Impossibility Detection")
    print("=" * 70)

    # Small example: search for right adjoint to projection
    N = 4
    pair_carrier = [(a, b) for a in range(N) for b in range(N)]
    nat_carrier = list(range(N))

    PT = FiniteTheory("PairTheory", pair_carrier, lambda p: p[0])
    NT = FiniteTheory("NatIdTheory", nat_carrier, lambda n: n)

    proj = FiniteMorphism("proj", PT, NT, lambda p: p[0])

    print("\n1. Searching for right adjoint to projection (small carrier)...")
    g = search_right_adjoint(proj, nat_carrier, pair_carrier)
    if g:
        print("   Found right adjoint G:")
        for y in nat_carrier:
            print(f"     G({y}) = {g(y)}")
    else:
        print("   No right adjoint found.")

    # Height-Cell impossibility
    print("\n2. Detecting impossibility for Height → Cell adjunction...")
    HT = FiniteTheory("Height", list(range(8)), lambda n: n)
    CT = FiniteTheory("Cell", list(range(8)), lambda n: n * (n + 1))

    htc = FiniteMorphism("htc", HT, CT, lambda n: n)

    result = detect_impossibility(htc, list(range(8)), list(range(8)))
    if result:
        y, reason = result
        print(f"   IMPOSSIBLE at y = {y}:")
        print(f"   {reason}")
    else:
        print("   No obstruction found in this range.")

    # Verify the projection-section adjunction
    print("\n3. Verifying projection-section adjunction...")
    sect = FiniteMorphism("sect", NT, PT, lambda n: (n, 0))
    ok, cex = verify_galois_connection(proj, sect)
    print(f"   Galois connection: {'✓ Verified' if ok else f'✗ Failed at {cex}'}")

    unit_data, counit_data = compute_unit_counit(proj, sect)
    print("   Unit inequalities:")
    for x, inv_x, inv_gfx in unit_data[:6]:
        print(f"     {x}: {inv_x} ≤ {inv_gfx}  {'✓' if inv_x <= inv_gfx else '✗'}")
    print("   Counit inequalities:")
    for y, inv_fgy, inv_y in counit_data:
        print(f"     {y}: {inv_fgy} ≤ {inv_y}  {'✓' if inv_fgy <= inv_y else '✗'}")

    print("\n4. Composition verification...")
    triple_carrier = [(a, b, c) for a in range(N) for b in range(N) for c in range(N)]
    TT = FiniteTheory("Triple", triple_carrier, lambda p: p[0])
    n2t = FiniteMorphism("n2t", NT, TT, lambda n: (n, 0, 0))
    t2n = FiniteMorphism("t2n", TT, NT, lambda p: p[0])
    ok2, _ = verify_galois_connection(n2t, t2n)
    print(f"   natToTriple ⊣ tripleToNat: {'✓' if ok2 else '✗'}")

    print("\nDone.")
