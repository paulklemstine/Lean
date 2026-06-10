#!/usr/bin/env python3
"""
Algorithms for Idempotent Stone Completeness

Implements the key algorithms from the research paper:
1. Prime closure-congruence enumeration
2. Formula validity decision procedure
3. Separation verification
4. Spectral embedding computation
"""

from demo import (
    IdempotentSemiring, ClosureNucleus, Formula,
    Var, Top, Bot, Conj, Disj, Box,
    eval_formula, boolean_semiring, three_chain, tropical_mod,
    identity_nucleus, top_nucleus,
    enumerate_prime_congruences, check_semantic_le,
    check_stalk_validity
)
from itertools import product as cartesian_product
from typing import Dict, List, Optional, Set, Tuple


def decide_formula_le(S: IdempotentSemiring, cn: ClosureNucleus,
                      phi: Formula, psi: Formula,
                      variables: List[str]) -> Tuple[bool, str]:
    """
    Decision procedure for phi ≤ psi in the positive modal logic.

    Algorithm:
    1. Enumerate all prime closure-congruences (Theorem 3)
    2. Check validity in each stalk
    3. Return result with certificate

    Complexity: O(B(|S|) * |S|^|vars| * |phi|)
    where B(n) = Bell number (number of partitions of n elements)

    Args:
        S: Finite idempotent commutative semiring
        cn: Closure nucleus on S
        phi, psi: Formulas to compare
        variables: List of variable names appearing in formulas

    Returns:
        (valid, certificate): Whether phi ≤ psi, with explanation
    """
    # Step 1: Enumerate prime congruences
    primes = enumerate_prime_congruences(S, cn)

    # Step 2: Check in each stalk
    for i, P in enumerate(primes):
        for vals in cartesian_product(S.elements, repeat=len(variables)):
            v = dict(zip(variables, vals))
            lhs = eval_formula(S, cn, v, phi)
            rhs = eval_formula(S, cn, v, psi)
            sum_val = S.add(lhs, rhs)
            if (sum_val, rhs) not in P:
                return (False,
                        f"Counterexample: P{i}, valuation {v}, "
                        f"eval(phi)={lhs}, eval(psi)={rhs}, "
                        f"sum={sum_val} ≁_P {rhs}")

    return (True,
            f"Valid in all {len(primes)} prime closure-congruences")


def verify_separation(S: IdempotentSemiring, cn: ClosureNucleus) -> Tuple[bool, str]:
    """
    Verify the prime separation property for (S, cn).

    Checks: for all distinct elements a, b in S,
    there exists a prime congruence P with a ≁_P b.

    Returns:
        (holds, report): Whether separation holds, with details
    """
    primes = enumerate_prime_congruences(S, cn)
    failures = []

    for a in S.elements:
        for b in S.elements:
            if a != b:
                separated = any((a, b) not in P for P in primes)
                if not separated:
                    failures.append((a, b))

    if failures:
        return (False,
                f"Separation fails for pairs: {failures}")
    else:
        return (True,
                f"Strong separation holds. {len(primes)} primes "
                f"separate all {S.n * (S.n - 1)} distinct pairs.")


def compute_spectral_embedding(S: IdempotentSemiring,
                                cn: ClosureNucleus) -> Dict[int, List[Set[int]]]:
    """
    Compute the spectral embedding of closed elements.

    Maps each closed element x to ([x]_P1, [x]_P2, ..., [x]_Pk)
    where Pi are the prime closure-congruences.

    Returns:
        Dictionary mapping elements to their spectral images
    """
    primes = enumerate_prime_congruences(S, cn)
    embedding = {}

    for x in S.elements:
        if cn.is_closed(x):
            image = []
            for P in primes:
                equiv_class = {y for y in S.elements if (x, y) in P}
                image.append(equiv_class)
            embedding[x] = image

    return embedding


def spectral_analysis(S: IdempotentSemiring, cn: ClosureNucleus) -> None:
    """
    Full spectral analysis of (S, cn): enumeration, separation,
    embedding, and formula checking.
    """
    print(f"\n{'='*60}")
    print(f"SPECTRAL ANALYSIS")
    print(f"{'='*60}")
    print(f"Semiring: {S.n} elements")
    print(f"Closed elements: {cn.closed_elements()}")

    # Enumerate primes
    primes = enumerate_prime_congruences(S, cn)
    print(f"Prime closure-congruences: {len(primes)}")

    # Check separation
    sep_holds, sep_report = verify_separation(S, cn)
    print(f"Separation: {'✓' if sep_holds else '✗'} — {sep_report}")

    # Compute embedding
    embedding = compute_spectral_embedding(S, cn)
    print(f"\nSpectral embedding of closed elements:")
    for x, image in embedding.items():
        classes = [sorted(c) for c in image]
        print(f"  {x} ↦ {classes}")

    # Check injectivity
    images = {}
    injective = True
    for x, img in embedding.items():
        key = tuple(frozenset(c) for c in img)
        if key in images:
            print(f"  WARNING: {x} and {images[key]} have same image!")
            injective = False
        images[key] = x
    print(f"\nEmbedding injective: {'✓' if injective else '✗'}")

    # Test standard formulas
    x_var, y_var = Var("x"), Var("y")
    test_cases = [
        ("x ∨ x ≤ x", Disj(x_var, x_var), x_var),
        ("x ≤ □x", x_var, Box(x_var)),
        ("□□x ≤ □x", Box(Box(x_var)), Box(x_var)),
        ("□(x∨y) ≤ □x∨□y", Box(Disj(x_var, y_var)),
         Disj(Box(x_var), Box(y_var))),
        ("□x∧□y ≤ □(x∧y)", Conj(Box(x_var), Box(y_var)),
         Box(Conj(x_var, y_var))),
    ]

    print(f"\nFormula validity:")
    for name, phi, psi in test_cases:
        valid, cert = decide_formula_le(S, cn, phi, psi, ["x", "y"])
        print(f"  {name}: {'✓' if valid else '✗'} ({cert})")


if __name__ == "__main__":
    print("Boolean Semiring:")
    spectral_analysis(boolean_semiring(), identity_nucleus(boolean_semiring()))

    print("\n\nThree-Element Chain:")
    spectral_analysis(three_chain(), identity_nucleus(three_chain()))

    S3 = three_chain()
    cn_nt = ClosureNucleus(S3, lambda x: 0 if x == 0 else 2)
    print("\n\nThree-Chain with Non-Trivial Nucleus:")
    spectral_analysis(S3, cn_nt)

    print("\n\nFour-Element Chain:")
    spectral_analysis(tropical_mod(4), identity_nucleus(tropical_mod(4)))
