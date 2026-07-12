# Computational Evidence — Betti–Rank Formula and Width Calculus

This note records small-case checks supporting the results proved in
`RankFormula.lean`.

## 1. The exact homology dimension `dim H = dim C₁ − rank d₁ − rank d₂`

We test the identity on explicit three-term complexes `C₂ →[d₂] C₁ →[d₁] C₀`
over a field, choosing `dₖ` as coordinate matrices and requiring `d₁ ∘ d₂ = 0`.

| `dim C₂` | `dim C₁` | `dim C₀` | `rank d₂` | `rank d₁` | predicted `dim H` | direct `dim(ker d₁ / im d₂)` |
|---------:|---------:|---------:|----------:|----------:|------------------:|-----------------------------:|
| 0 | 3 | 0 | 0 | 0 | 3 | 3 |
| 2 | 4 | 2 | 2 | 2 | 0 | 0 |
| 3 | 5 | 2 | 2 | 2 | 1 | 1 |
| 1 | 4 | 3 | 1 | 3 | 0 | 0 |
| 2 | 6 | 2 | 2 | 2 | 2 | 2 |

In every case the formula `dim C₁ − rank d₁ − rank d₂` matches the directly
computed subquotient dimension. The two boundary cases — a zero differential in
each slot — reproduce the expected extremes (`dim H = dim C₁` when both
differentials vanish; `dim H = 0` when the ranks saturate `dim C₁`).

## 2. The activation-pattern count `P(w) = ∏ᵢ 2^{wᵢ}`

For a network with hidden widths `w = (w₁, …, w_L)`:

| widths `w`      | `∏ᵢ 2^{wᵢ}` | `2^{Σ wᵢ}` |
|-----------------|------------:|-----------:|
| `(1)`           | 2           | 2          |
| `(2, 3)`        | 32          | 32         |
| `(1, 1, 1)`     | 8           | 8          |
| `(4, 2)`        | 64          | 64         |
| `(3, 3, 2)`     | 256         | 256        |

The product form and the total-neuron form agree throughout, confirming
`activationPattern_eq_two_pow_sum`.

**Monotonicity.** Widening any coordinate never decreases the count, e.g.
`(2,3) ↦ 32` while `(2,4) ↦ 64` and `(3,3) ↦ 64`; every widening in the samples
above is monotone, supporting `card_activationPattern_mono`.

**Multiplicativity under concatenation.** Stacking `(2,3)` next to `(4)` gives the
profile `(2,3,4)` with count `2^{2+3+4} = 512 = 32 · 16`, matching
`P(2,3) · P(4)`; this is `card_activationPattern_append`.

## 3. Counterexample hunt

We searched random rank profiles `(rank d₁, rank d₂)` with `rank d₁ + rank d₂ ≤
dim C₁` and `d₁ ∘ d₂ = 0` for a mismatch between the predicted and actual
homology dimension; none was found. The identity is a two-sided equality, so no
counterexample is expected, and none arose.

## Conclusion

The finite computations are fully consistent with all six headline results. The
formal development promotes these observations to theorems that hold for every
field and every finite-dimensional chain group, with no dependence on the
specific dimensions sampled here.
