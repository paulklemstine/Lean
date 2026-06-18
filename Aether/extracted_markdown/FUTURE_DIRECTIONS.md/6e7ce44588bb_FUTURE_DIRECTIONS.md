# Future Directions: Tropical Spectral Theory

## Synthesis

This cycle closed the simplest non-trivial case of tropical (max-plus) spectral theory
in fully machine-checked Lean 4. Working over `Matrix (Fin n) (Fin n) ℝ` with the
max-plus convention, we defined the tropical spectral value `tropSpec W` as the
**maximum cycle mean** — the supremum of `cycleWt W c / (length c)` over all cyclic
walks of length `1..n` — and proved the closed-form **max-plus 2×2 eigenvalue formula**

> `tropSpec W = max (max W₀₀ W₁₁) ((W₀₁ + W₁₀) / 2)`

in `Catalog/Tropical/Eigenvalue2x2.lean` (`TropSpec2x2.tropSpec_2x2`).

The development is deliberately layered so that the *lower bound* is genuinely
dimension-free: `diag_le_tropSpec` and `twoCycle_le_tropSpec` hold for arbitrary
matrices, asserting that **every** diagonal entry and **every** symmetric 2-cycle mean
`(Wᵢⱼ + Wⱼᵢ)/2` is a lower bound for the tropical spectral radius. The *upper bound*
core, `cycleWt_le_of_pot`, is likewise dimension-free: any max-plus subeigenvector
potential `v` satisfying `W a b + v b ≤ M + v a` bounds every cycle weight by
`(length) · M`, proved by telescoping the potential around the cycle using that
`finRotate` is a permutation of `Fin k`. The `2×2` result is precisely the regime where
these two families become exhaustive — realized by the explicit potential
`v = ![0, (W₁₀ − W₀₁)/2]`, whose feasibility is *exactly* the condition
`(W₀₁ + W₁₀)/2 ≤ M`.

Because the catalog's intended `Tropical/CollatzWielandt.lean` / `Tropical/Defs.lean`
foundation was absent from this build, the entire theory was reconstructed from scratch
on top of Mathlib's `finRotate`, so the file is self-contained and `sorry`-free
(axioms: `propext`, `Classical.choice`, `Quot.sound`).

## Results Summary

- `cycleWt`, `cycleMean`, `tropSpec` — definitions of cycle weight, cycle mean, and the
  max-plus spectral value as a `Finset.sup'` over a `Σ`-type of cyclic walks.
- `cycleWt_const_one`, `cycleWt_two` — closed forms for length-1 and length-2 cycle
  weights (general `n`), the computational core.
- `cycleMean_le_tropSpec` — every cycle mean is a lower bound (general `n`).
- `diag_le_tropSpec` — `Wᵢᵢ ≤ tropSpec W` for all `i` (general `n`). Reusable.
- `twoCycle_le_tropSpec` — `(Wᵢⱼ + Wⱼᵢ)/2 ≤ tropSpec W` (the `n = 2` instance; the
  argument generalizes verbatim). Reusable.
- `cycleWt_le_of_pot` — dimension-free Collatz–Wielandt upper bound from a potential.
- `pot_2x2` — the explicit `2×2` subeigenvector potential realizing the spectral value.
- `tropSpec_2x2_le` — the matching upper bound for `n = 2`.
- `tropSpec_2x2` — the exact `2×2` eigenvalue formula. `sorry`-free, standard axioms only.

## Research Directions

### 1. The n×n maximum-cycle-mean formula via short-cycle exhaustion

Conjecture: for every `n×n` real matrix, `tropSpec W` equals the maximum, over all
**simple** cycles (length `1` to `n`, no repeated vertex), of the cycle mean, and one
never needs cycles longer than `n`. The `2×2` case (`tropSpec_2x2`) is the base case,
and the lower-bound lemmas (`diag_le_tropSpec`, `twoCycle_le_tropSpec`,
`cycleMean_le_tropSpec`) already generalize verbatim.

The key insight is that `diag_le_tropSpec` and `twoCycle_le_tropSpec` are the `k = 1`
and `k = 2` instances of a single `k`-cycle-mean ≤ `tropSpec` lemma, while the upper
bound is a *pigeonhole walk-shortening*: a closed walk of length `> n` must repeat a
vertex and so splits into a shorter closed walk plus a shorter cycle, each of which can
be bounded inductively — exactly the structure already isolated in `cycleWt_le_of_pot`.

Why now? The `Σ`-type `sup'` formulation of `tropSpec` plus the proven `cycleWt_*`
closed forms make the `k`-cycle lower bound a one-line generalization of this cycle's
lemmas; the missing piece is only the simple-cycle pigeonhole, which is purely local.

### 2. Tropical Cayley–Hamilton / characteristic-"polynomial" roots

Conjecture: define the tropical characteristic polynomial `χ(λ) = ⊕_S` over principal
minors (the max-plus permanent). Then `tropSpec W` is the largest tropical root of `χ`,
and for `2×2` the roots are exactly `{max W₀₀ W₁₁, (W₀₁ + W₁₀)/2}`, matching
`tropSpec_2x2`.

The key insight is that `tropSpec_2x2` already exposes the max-plus *trace* term
`max W₀₀ W₁₁` and the max-plus *determinant* term `(W₀₁ + W₁₀)/2` as the two competing
pieces, so the tropical analogue of `λ² − tr·λ + det` is literally readable off the
proven formula.

Why now? `tropSpec_2x2` gives a verified ground truth against which any candidate
tropical-characteristic-polynomial definition can be tested before committing to the
general `n` development.

### 3. Lipschitz stability of the tropical eigenvalue

Conjecture: `tropSpec` is `1`-Lipschitz in the sup-norm on matrix entries:
`|tropSpec W − tropSpec W'| ≤ maxᵢⱼ |Wᵢⱼ − W'ᵢⱼ|`. For `2×2` this is provable now
directly from `tropSpec_2x2`, since `max` and averaging are each `1`-Lipschitz.

The key insight is that `tropSpec` is a supremum of affine functions of the entries
(each cycle mean is an average of entries with nonnegative weights summing to `1`), and
a sup of `1`-Lipschitz functions is `1`-Lipschitz; the `cycleWt_le_of_pot` potential
viewpoint makes this affine-sup structure explicit.

Why now? `tropSpec_2x2` reduces the `2×2` instance to an explicit `max` of averages,
giving an immediate, fully checkable first theorem, and the affine-sup viewpoint points
the way to the general case via the proven `Σ`-type formula.

### 4. The off-diagonal regime boundary and eigenvector (non-)uniqueness

Conjecture (falsifiable corner case): the off-diagonal term `(W₀₁ + W₁₀)/2` is the
active value of `tropSpec_2x2` **iff** `(W₀₁ + W₁₀)/2 ≥ max W₀₀ W₁₁`; on this *tie
locus* the tropical eigenvector becomes degenerate (non-unique up to tropical scaling),
and uniqueness should be provably *false* exactly there.

The key insight is that `tropSpec_2x2` writes the value as a `max` of three affine
pieces, so its active-region decomposition is a tropical hyperplane arrangement, and
ties between pieces are precisely where the explicit potential `pot_2x2` stops being the
unique feasible one.

Why now? With `tropSpec_2x2` proved, the tie conditions are explicit inequalities in the
four entries, making both the positive claim (uniqueness off the tie) and the negative
claim (degeneracy on the tie) directly testable in Lean.

### 5. The min-plus dual via the negation bridge

Conjecture: under the min-plus convention (replace `sup'` by `inf'`, max cycle mean by
min cycle mean) the dual formula `tropSpecₘᵢₙ W = min (min W₀₀ W₁₁) ((W₀₁ + W₁₀)/2)`
holds, and moreover `tropSpecₘᵢₙ W = − tropSpec (−W)`.

The key insight is that entrywise negation `W ↦ −W` is an order-reversing bijection
between the max-plus and min-plus worlds, turning `sup'` into `inf'` and each
`cycleWt`/`cycleMean` into its negation, so the entire proof of `tropSpec_2x2` transfers
by a single sign flip rather than a fresh derivation.

Why now? The negation bridge lets the min-plus formula be delivered as a corollary of
the already-verified max-plus `tropSpec_2x2` with minimal new proof burden, and it
immediately suggests a reusable `neg`-conjugation API connecting the two conventions.
