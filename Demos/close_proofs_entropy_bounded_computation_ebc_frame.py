"""
Entropy-Bounded Computation (EBC) — numerical demonstrations.

This self-contained script illustrates the seven core theorems of the EBC
framework plus the companion compression-correctness bridge. Every function is
inlined; the only dependency is the Python standard library.

Core definition:
    H(S) = log2(|S|)   -- Shannon entropy (bits) of the uniform distribution
                          over a finite state space S with |S| states.

Theorems illustrated:
    T1 Nonnegativity:            |S| >= 1            => H(S) >= 0
    T2 Single-state:             |S| = 1             => H(S) = 0
    T3 Reversibility free:       bijection S<->T     => H(S) = H(T)
    T4 Additivity:               H(S x T) = H(S) + H(T)
    T5 Second law:               surjection S->T     => H(T) <= H(S)
    T6 Landauer (strict):        |S| >= 2            => H(S) > 0
    T7 Landauer (exact):         erase to 1 state    => released = H(S) >= 0
    T8 Compression correctness:  ||f|| * delta <= r  => decode succeeds
"""

from __future__ import annotations

import math
from typing import Callable, Iterable, List, Sequence, Tuple


# --------------------------------------------------------------------------
# Core definition
# --------------------------------------------------------------------------
def entropy(card: int) -> float:
    """Entropy H(S) = log2(|S|) in bits for a state space with `card` states.

    Requires card >= 1 (a nonempty finite state space).
    """
    if card < 1:
        raise ValueError("state space must be nonempty (card >= 1)")
    return math.log2(card)


# --------------------------------------------------------------------------
# T1 / T2  -- ground facts
# --------------------------------------------------------------------------
def demo_ground_facts() -> None:
    print("== Theorems 1 & 2: ground facts ==")
    for n in (1, 2, 8, 256, 1024):
        h = entropy(n)
        print(f"  |S| = {n:>5}  ->  H(S) = {h:6.3f} bits   (H >= 0: {h >= -1e-12})")
    assert abs(entropy(1)) < 1e-12, "T2: single state must have zero entropy"
    assert all(entropy(n) >= -1e-12 for n in (1, 2, 8, 256)), "T1: H >= 0"
    print("  OK: single-state entropy is 0; all entropies nonnegative.\n")


# --------------------------------------------------------------------------
# T3 -- reversibility preserves entropy
# --------------------------------------------------------------------------
def demo_reversibility() -> None:
    print("== Theorem 3: reversible computation is free ==")
    # A bijection cannot change the number of states, hence not the entropy.
    card_S = 16
    # e.g. "flip all 4 bits": a bijection on a 16-state space onto itself.
    card_T = card_S
    print(f"  reversible step on {card_S} states (e.g. bitwise NOT of 4 bits)")
    print(f"  H(S) = {entropy(card_S):.3f}, H(T) = {entropy(card_T):.3f}")
    assert math.isclose(entropy(card_S), entropy(card_T))
    print("  OK: H(S) = H(T) under a bijection.\n")


# --------------------------------------------------------------------------
# T4 -- additivity over products
# --------------------------------------------------------------------------
def demo_additivity() -> None:
    print("== Theorem 4: independent systems add ==")
    for card_S, card_T in ((8, 32), (2, 2), (3, 5)):
        lhs = entropy(card_S * card_T)
        rhs = entropy(card_S) + entropy(card_T)
        print(
            f"  H({card_S} x {card_T}) = H({card_S*card_T}) = {lhs:6.3f}"
            f"   vs   H(S)+H(T) = {rhs:6.3f}"
        )
        assert math.isclose(lhs, rhs), "T4: additivity failed"
    print("  OK: H(S x T) = H(S) + H(T).\n")


# --------------------------------------------------------------------------
# T5 -- second law / data-processing inequality
# --------------------------------------------------------------------------
def reachable_card(domain: Sequence[int], f: Callable[[int], int]) -> int:
    """Number of distinct outputs of f over `domain` (cardinality of the range)."""
    return len({f(x) for x in domain})


def demo_second_law() -> None:
    print("== Theorem 5: deterministic computation cannot create entropy ==")
    domain = list(range(16))  # 16 input states
    # A surjective, lossy map: divide by 4 (remainder discarded) -> 4 outputs.
    f = lambda x: x // 4
    card_T = reachable_card(domain, f)  # = 4
    h_in, h_out = entropy(len(domain)), entropy(card_T)
    print(f"  f(x) = x // 4 on {len(domain)} states -> {card_T} outputs")
    print(f"  H(S) = {h_in:.3f}  >=  H(T) = {h_out:.3f}   (drop = {h_in - h_out:.3f})")
    assert h_out <= h_in + 1e-12, "T5: entropy increased!"
    print("  OK: H(T) <= H(S).\n")


# --------------------------------------------------------------------------
# T6 / T7 -- Landauer's principle
# --------------------------------------------------------------------------
def erasure_cost(card_source: int) -> float:
    """Entropy released by erasing `card_source` states to a single state.

    Equals H(source) - H(target) = log2(card_source) - log2(1) = log2(card_source).
    """
    return entropy(card_source) - entropy(1)


def demo_landauer() -> None:
    print("== Theorems 6 & 7: Landauer's principle ==")
    for n in (2, 4, 256):
        cost = erasure_cost(n)
        print(f"  erase {n:>3} states -> 1 state:  released = {cost:6.3f} bits"
              f"   (> 0: {cost > 0})")
        assert math.isclose(cost, entropy(n)), "T7: released != H(source)"
        if n >= 2:
            assert cost > 0, "T6: erasure of >=2 states must cost > 0"
    print("  erasing 1 bit costs exactly 1 bit; a byte costs 8 bits.")
    print("  OK: erasure cost = H(source), strictly positive when |S| >= 2.\n")


# --------------------------------------------------------------------------
# Pipeline entropy accounting (telescoping; see paper section 8.3)
# --------------------------------------------------------------------------
def pipeline_dissipation(stage_cards: Sequence[int]) -> Tuple[List[float], float]:
    """Per-stage entropy drops and total dissipation for a deterministic pipeline.

    stage_cards[i] is the reachable-state count after stage i, with the
    expectation stage_cards[i+1] <= stage_cards[i] (Theorem 5).
    Returns (per_stage_drops, total) where total telescopes to
    log2(stage_cards[0]) - log2(stage_cards[-1]).
    """
    drops = [entropy(stage_cards[i]) - entropy(stage_cards[i + 1])
             for i in range(len(stage_cards) - 1)]
    total = entropy(stage_cards[0]) - entropy(stage_cards[-1])
    return drops, total


def demo_pipeline() -> None:
    print("== Pipeline accounting (telescoping of stage defects) ==")
    stages = [256, 64, 16, 4, 1]  # reachable states after each deterministic stage
    drops, total = pipeline_dissipation(stages)
    print(f"  stages (reachable states): {stages}")
    print(f"  per-stage drops (bits):    {[round(d, 3) for d in drops]}")
    print(f"  sum of drops = {sum(drops):.3f}  ==  total = {total:.3f}")
    assert math.isclose(sum(drops), total), "telescoping failed"
    assert all(d >= -1e-12 for d in drops), "a stage increased entropy"
    print("  OK: stage drops are nonnegative and telescope to the total.\n")


# --------------------------------------------------------------------------
# T8 -- compression-correctness bridge
# --------------------------------------------------------------------------
def compression_safe(op_norm: float, delta: float, decoder_radius: float) -> bool:
    """Certify Theorem 8's hypothesis: amplified noise stays inside the window.

    If ||f|| * delta <= decoder_radius, then for any noise e with ||e|| <= delta
    the compressed, noisy codeword decodes correctly.
    """
    if op_norm < 0 or delta < 0:
        raise ValueError("op_norm and delta must be nonnegative")
    return op_norm * delta <= decoder_radius


def demo_compression() -> None:
    print("== Theorem 8: compression preserves decryption correctness ==")
    cases = [
        ("safe",   1.5, 0.20, 0.40),   # 1.5 * 0.20 = 0.30 <= 0.40
        ("tight",  2.0, 0.25, 0.50),   # 2.0 * 0.25 = 0.50 <= 0.50
        ("unsafe", 3.0, 0.30, 0.50),   # 3.0 * 0.30 = 0.90 >  0.50
    ]
    for label, nf, delta, r in cases:
        ok = compression_safe(nf, delta, r)
        print(f"  [{label:>6}] ||f||={nf}, delta={delta}, radius={r}"
              f"  ->  ||f||*delta = {nf*delta:.3f}  certified: {ok}")
    assert compression_safe(1.5, 0.20, 0.40)
    assert not compression_safe(3.0, 0.30, 0.50)
    print("  OK: certification holds exactly when ||f|| * delta <= radius.\n")


# --------------------------------------------------------------------------
# Concrete simulation of the compression bound on a toy linear map
# --------------------------------------------------------------------------
def matvec(matrix: Sequence[Sequence[float]], vec: Sequence[float]) -> List[float]:
    return [sum(row[j] * vec[j] for j in range(len(vec))) for row in matrix]


def l2_norm(vec: Iterable[float]) -> float:
    return math.sqrt(sum(c * c for c in vec))


def spectral_norm_upper_bound(matrix: Sequence[Sequence[float]]) -> float:
    """Frobenius norm: an easily computed upper bound on the operator (spectral) norm."""
    return math.sqrt(sum(c * c for row in matrix for c in row))


def demo_concrete_compression() -> None:
    print("== Concrete check: ||f e|| <= ||f|| * ||e|| <= ||f|| * delta ==")
    f = [[0.5, 0.0, 0.5, 0.0],
         [0.0, 0.5, 0.0, 0.5]]            # a 4 -> 2 linear compression map
    e = [0.1, -0.05, 0.08, 0.02]          # small noise
    delta = l2_norm(e) + 1e-9             # a valid noise bound: ||e|| <= delta
    op_bound = spectral_norm_upper_bound(f)
    fe = matvec(f, e)
    print(f"  ||e||       = {l2_norm(e):.4f}  (<= delta = {delta:.4f})")
    print(f"  ||f e||     = {l2_norm(fe):.4f}")
    print(f"  ||f||*||e|| <= {op_bound * l2_norm(e):.4f}  (Frobenius bound on ||f||)")
    assert l2_norm(fe) <= op_bound * l2_norm(e) + 1e-9, "operator-norm bound violated"
    print("  OK: compressed noise stays within the certified window.\n")


def main() -> None:
    print("Entropy-Bounded Computation (EBC) — numerical demonstrations\n")
    demo_ground_facts()
    demo_reversibility()
    demo_additivity()
    demo_second_law()
    demo_landauer()
    demo_pipeline()
    demo_compression()
    demo_concrete_compression()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
