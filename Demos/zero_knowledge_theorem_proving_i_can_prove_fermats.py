"""
Numerical demonstrations for:

    Zero-Knowledge Certification of Proofs:
    Independence, Soundness Amplification, and Perfect Hiding

This self-contained script illustrates the three probabilistic pillars of the
zero-knowledge proof-checking protocol:

  1. Independence identity and soundness amplification:
        #(survive all k rounds) = prod_i |A_i|,
        Pr[survive all k] <= (e/n)^k,  and  <= 2^{-k} when 2e <= n.

  2. Single-round soundness of the graph-3-colouring protocol:
        an improper committed colouring is caught with probability >= 1/|E|,
        and the k-round cheating probability is <= ((m-1)/m)^k -> 0.

  3. Perfect honest-verifier zero knowledge:
        the view map  pi |-> (pi(a), pi(b))  is a bijection  S_3 -> distinct pairs,
        so the real transcript distribution equals the simulator's exactly,
        each distinct pair appearing with probability 1/6.

Run:  python demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import permutations, product
from typing import Callable, Dict, List, Sequence, Tuple

Colour = int
Pair = Tuple[Colour, Colour]
Perm = Tuple[Colour, Colour, Colour]  # perm[c] is the image of colour c


# --------------------------------------------------------------------------
# 1. Independence identity and soundness amplification
# --------------------------------------------------------------------------

def survivors_product(accepting_sizes: Sequence[int]) -> int:
    """Number of k-round challenge sequences surviving every round.

    By the independence identity this is exactly the product of the per-round
    accepting-set sizes: #(A_1 x ... x A_k) = prod_i |A_i|.
    """
    total = 1
    for s in accepting_sizes:
        total *= s
    return total


def brute_force_survivors(accepting_sets: Sequence[Sequence[int]]) -> int:
    """Directly enumerate the product set to confirm the independence identity."""
    count = 0
    for seq in product(*accepting_sets):
        # every coordinate lies in its accepting set by construction of product
        count += 1
    return count


def amplified_probability(n: int, e: int, k: int) -> Fraction:
    """Uniform probability of surviving all k rounds, exact rational.

    Upper-bounded by (e/n)^k; here every round accepts exactly e of n challenges,
    so the true survival probability equals (e/n)^k.
    """
    return Fraction(e, n) ** k


def rounds_for_target_error(n: int, e: int, target: Fraction) -> int:
    """Smallest k with (e/n)^k <= target, assuming e < n."""
    assert e < n, "need per-round acceptance < 1 to amplify"
    k = 0
    prob = Fraction(1)
    while prob > target:
        prob *= Fraction(e, n)
        k += 1
    return k


def demo_amplification() -> None:
    print("=" * 70)
    print("1. INDEPENDENCE IDENTITY AND SOUNDNESS AMPLIFICATION")
    print("=" * 70)

    accepting_sets = [[0, 1, 2], [0, 3], [1, 2, 4, 5]]  # sizes 3, 2, 4
    sizes = [len(a) for a in accepting_sets]
    via_formula = survivors_product(sizes)
    via_enum = brute_force_survivors(accepting_sets)
    print(f"per-round accepting sizes : {sizes}")
    print(f"prod of sizes (formula)   : {via_formula}")
    print(f"enumerated product set    : {via_enum}")
    print(f"independence identity holds: {via_formula == via_enum}")

    print("\n2^{-k} soundness with n = 6, e = 3 (each round catches w.p. 1/2):")
    n, e = 6, 3
    for k in range(1, 8):
        p = amplified_probability(n, e, k)
        bound = Fraction(1, 2) ** k
        print(f"  k={k}: survival = {p}  (= 2^-{k} = {bound}) "
              f"[<= 2^-k: {p <= bound}]")

    target = Fraction(1, 10 ** 6)
    k_needed = rounds_for_target_error(n, e, target)
    print(f"\nrounds to reach error <= 1e-6 (n=6,e=3): k = {k_needed}")


# --------------------------------------------------------------------------
# 2. Single-round soundness of graph 3-colouring
# --------------------------------------------------------------------------

def is_proper(edges: Sequence[Pair], colouring: Dict[int, Colour]) -> bool:
    """A colouring is proper iff every edge has distinct endpoint colours."""
    return all(colouring[u] != colouring[v] for (u, v) in edges)


def catching_edges(edges: Sequence[Pair],
                   colouring: Dict[int, Colour]) -> List[Pair]:
    """Edges whose endpoints share a colour: the verifier catches the prover here."""
    return [(u, v) for (u, v) in edges if colouring[u] == colouring[v]]


def single_round_catch_probability(edges: Sequence[Pair],
                                    colouring: Dict[int, Colour]) -> Fraction:
    """Probability a uniformly random edge catches the prover."""
    m = len(edges)
    assert m > 0
    return Fraction(len(catching_edges(edges, colouring)), m)


def kround_cheat_bound(m: int, k: int) -> Fraction:
    """Worst-case k-round cheating probability for a single bad edge: ((m-1)/m)^k."""
    return Fraction(m - 1, m) ** k


def demo_soundness() -> None:
    print("\n" + "=" * 70)
    print("2. SINGLE-ROUND SOUNDNESS OF GRAPH 3-COLOURING")
    print("=" * 70)

    # A triangle (K3): 3 edges, needs all three colours to be proper.
    edges: List[Pair] = [(0, 1), (1, 2), (2, 0)]

    proper = {0: 0, 1: 1, 2: 2}
    bad_one = {0: 0, 1: 0, 2: 1}      # exactly one bad edge (0,1)

    print(f"triangle edges: {edges}")
    print(f"proper colouring {proper}: is_proper = {is_proper(edges, proper)}, "
          f"catch prob = {single_round_catch_probability(edges, proper)}")
    print(f"bad colouring   {bad_one}: is_proper = {is_proper(edges, bad_one)}, "
          f"catch prob = {single_round_catch_probability(edges, bad_one)} "
          f"(>= 1/|E| = 1/{len(edges)})")

    m = len(edges)
    print(f"\nk-round cheating probability bound ((m-1)/m)^k with m={m}:")
    for k in [1, 5, 10, 20, 40]:
        b = kround_cheat_bound(m, k)
        print(f"  k={k:2d}: <= {float(b):.6e}")


# --------------------------------------------------------------------------
# 3. Perfect honest-verifier zero knowledge
# --------------------------------------------------------------------------

def all_perms() -> List[Perm]:
    """The six permutations of the three colours {0,1,2} (the group S_3)."""
    return [perm for perm in permutations(range(3))]  # type: ignore[misc]


def view(perm: Perm, a: Colour, b: Colour) -> Pair:
    """The verifier's opened pair on an edge with endpoint colours (a, b)."""
    return (perm[a], perm[b])


def distinct_pairs() -> List[Pair]:
    """The six ordered pairs of distinct colours."""
    return [(x, y) for (x, y) in product(range(3), range(3)) if x != y]


def real_transcript_distribution(a: Colour, b: Colour) -> Dict[Pair, Fraction]:
    """Pushforward of uniform S_3 under the view map, for endpoint colours a != b."""
    assert a != b
    perms = all_perms()
    dist: Dict[Pair, Fraction] = {}
    for perm in perms:
        p = view(perm, a, b)
        dist[p] = dist.get(p, Fraction(0)) + Fraction(1, len(perms))
    return dist


def simulator_distribution() -> Dict[Pair, Fraction]:
    """Uniform distribution over the six distinct ordered pairs, no colouring used."""
    pairs = distinct_pairs()
    return {p: Fraction(1, len(pairs)) for p in pairs}


def demo_zero_knowledge() -> None:
    print("\n" + "=" * 70)
    print("3. PERFECT HONEST-VERIFIER ZERO KNOWLEDGE")
    print("=" * 70)

    perms = all_perms()
    pairs = distinct_pairs()
    print(f"|S_3| = {len(perms)},  #distinct ordered pairs = {len(pairs)}")

    # View map is a bijection S_3 -> distinct pairs for any fixed a != b.
    a, b = 0, 1
    images = sorted(view(perm, a, b) for perm in perms)
    print(f"view images for (a,b)=({a},{b}): {images}")
    print(f"view map is a bijection onto distinct pairs: "
          f"{images == sorted(pairs)}")

    sim = simulator_distribution()
    print("\nreal vs simulated distributions (should be identical, all = 1/6):")
    all_equal = True
    for (a, b) in [(0, 1), (1, 2), (0, 2)]:
        real = real_transcript_distribution(a, b)
        equal = real == sim
        all_equal &= equal
        print(f"  edge colours ({a},{b}): real == simulator ? {equal}")
    print(f"\nperfect ZK (real == simulator for every edge): {all_equal}")
    some_pair = pairs[0]
    print(f"probability of pair {some_pair}: "
          f"{real_transcript_distribution(0, 1)[some_pair]} (= 1/6)")

    # Colour-independence: the distribution never depends on the true colours.
    d01 = real_transcript_distribution(0, 1)
    d12 = real_transcript_distribution(1, 2)
    print(f"colour-independence (R_{{0,1}} == R_{{1,2}}): {d01 == d12}")


def main() -> None:
    demo_amplification()
    demo_soundness()
    demo_zero_knowledge()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
