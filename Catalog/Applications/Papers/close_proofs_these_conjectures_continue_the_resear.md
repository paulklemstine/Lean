# Computational Evidence — Transition-Rank Stabilization

## Object
For a stream `f : ℕ → V →ₗ[K] V`, `transEndo f i j = f(j-1) ∘ … ∘ f(i)` over the
window `[i, j)`, and `rankSeq f 0 m = (transEndo f 0 m).rank.toNat`.

## Small-case landscape (constant stream `f ≡ g`, so `transEndo f 0 m = g^m`)
Take `V = K^d` and `g` a single Jordan block (nilpotent shift), `d = 4`:

| m | g^m            | rank(g^m) = rankSeq |
|---|----------------|---------------------|
| 0 | id             | 4                   |
| 1 | shift          | 3                   |
| 2 | shift^2        | 2                   |
| 3 | shift^3        | 1                   |
| 4 | shift^4 = 0    | 0                   |
| 5 | 0              | 0  (stabilized)     |

This matches the proved facts: the sequence is bounded by `finrank K V = 4`,
antitone, and eventually constant (here at `N = 4`, value `0`).

For a projection `p` (idempotent, `p^2 = p`) of rank `r`: `rankSeq` is `r` for all
`m ≥ 1` and `d` at `m = 0` — antitone and immediately constant from `m = 1`.

## Why a heavy computational stage is unnecessary here
The result is structural/algebraic rather than numerical: it asserts that a
bounded antitone `ℕ → ℕ` sequence stabilizes. The table above already exhibits the
generic descending-then-flat behaviour, and the two extreme regimes (nilpotent →
reaches 0; idempotent → flat) bracket the phenomenon. No counterexample is
expected or found in finite dimension; conjecture 3 in `FUTURE_DIRECTIONS.md`
records the (separate) infinite-dimensional failure mode.

## Verdict
Computational landscape is consistent with the formal claims; proceeded to the
fully verified Lean proofs in `Catalog/Algebra/TransEndo.lean` and
`Catalog/Algebra/TransEndoStabilization.lean` (0 sorries, standard axioms only).
