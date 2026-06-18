# Future Directions — Tropicalization of Valuation Depth

## Synthesis

This cycle built the missing **Bridges ↔ Tropical** connection flagged in the catalog
analysis. The file `Bridges/ValuationDepthTropicalization.lean` constructs a canonical
map `tropDepth` from `ValuationDepthMeasure` data (the p-adic / non-Archimedean
computational valuation calculus of `Computation/PadicValuationDepth.lean`) into the
max-plus tropical object `maxPlusTrop` on `WithBot ℕ`, which lives inside the categorical
framework of `Bridges/CategoricalTropicalUltrametric.lean`.

The decisive realization is *negative and clarifying*: valuation depth is **not** an
`UltraNormObj.norm`. Its triangle law carries a `+1` defect (`vdepth_sum_le` gives
`≤ max + 1`, not `≤ max`), and `vdepth_mul` is an inequality, not the multiplicative
equality an ultranorm demands. The honest home for depth is therefore the tropical
**order** object, where the `+1` defect is realized exactly as tropical multiplication by
the unit shift `1`. With that correction the bridge becomes clean and total:

* `tropDepth_const_eq_one` — zero-depth constants ↦ the tropical unit.
* `tropDepth_sum_le`, `tropDepth_mul_le` — the tropical triangle law
  `tropDepth(f ⋆ g) ≤ (tropDepth f ⊕ tropDepth g) ⊗ 1`, `⋆ ∈ {+, ·}`.
* `DepthNonincreasing` with `id`/`comp`, `tropMonotone`, `tropMonotone_comp` —
  depth-nonincreasing maps form a category and `tropDepth` is nonexpansive along them,
  preserved under composition. This is the *functorial* content: a quantitative passage
  from ultrametric computational data to tropical weight data.

## Results Summary

| Result | Statement | Source lemma reused |
|---|---|---|
| `maxPlusTrop` | `WithBot ℕ` with `(max,+)` is a `TropicalValuationObject` | (new construction) |
| `tropDepth_const_eq_one` | constant `0` ↦ tropical unit | `vdepth_const_eq_zero` |
| `tropDepth_sum_le` | tropical triangle law for `+` | `vdepth_sum_le` |
| `tropDepth_mul_le` | tropical triangle law for `·` | `vdepth_prod_le` |
| `tropMonotone` / `tropMonotone_comp` | functorial nonexpansiveness | `DepthNonincreasing.depth_le` |

All main results are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

## Research Directions

### 1. The `+1` defect is a genuine grading, not slack — a strict tropical valuation
**Conjecture.** Define the *defect-graded* weight `tropDepth` and prove the converse
direction is sharp: there exists a `ValuationDepthMeasure` instance and functions `f, g`
for which `tropDepth(f+g) = (tropDepth f ⊕ tropDepth g) ⊗ 1` with strict inequality
against the un-shifted tropical sum `tropDepth f ⊕ tropDepth g`. Hence the unit shift `1`
cannot be removed for any nontrivial instance.
*The key insight is* that the `+1` is the **cost of one valuation query**, so it is a
structural grading carried by the tropical *multiplication*, and a no-shift tropical
triangle law would force every binary operation to be free — provably false. *Why now?*
The shift already appears explicitly as `oneShift` in the current file, so the falsifiable
extremal instance is a small finite construction over `ZMod p` away.

### 2. `tropDepth` is a lax monoidal / colax semiring functor into `TropObj`
**Conjecture.** Equipping the source `(α → β)` with pointwise `(+, ·)` and the target with
`maxPlusTrop`, the assignment `f ↦ tropDepth f` extends to a **colax** morphism: it sends
`+` and `·` to `≤`-bounded tropical sums (already proven) and respects units, making
`(DepthNonincreasing, comp, id) → TropObj` a functor that is *lax monoidal* with structure
maps given by `tropDepth_sum_le`/`tropDepth_mul_le`.
*The key insight is* that nonexpansiveness (`tropMonotone`) plus the two triangle laws are
exactly the coherence data of a colax semiring functor — the inequalities are the lax
structure 2-cells. *Why now?* The category of depth-nonincreasing maps and the bundled
`maxPlusTropObj` are both already defined; only the coherence square (compatibility of
`tropMonotone` with `tropDepth_sum_le`) remains to formalize.

### 3. Hensel/Newton iteration tropicalizes to a contraction with explicit rate
**Conjecture.** For the `HenselIterationComplexity` data in `PadicValuationDepth.lean`,
the tropicalized depth of the `n`-th Newton iterate satisfies a strict tropical
contraction `tropDepth(xₙ₊₁) ≤ tropDepth(xₙ) ⊗ (−1)` in `WithBot ℤ` (i.e. depth *drops*
by one query class per doubling step), yielding an `O(log n)` certified bound purely in
tropical arithmetic.
*The key insight is* that exponential `p`-adic convergence becomes **linear descent** in
the tropical (logarithmic) coordinate, so Newton's quadratic convergence is a tropical
*line* of slope `−1`. *Why now?* `HenselConvergenceData` already certifies the exponential
rate; reading it through `tropDepth` converts a transcendental estimate into a finite
tropical recurrence that the depth calculus can discharge by induction.

### 4. A tropical Galois/adjunction between depth classes and tropical sublevel sets
**Conjecture.** The complexity classes `ValDepthClassSet α β k` correspond exactly to
tropical sublevel sets `{f | tropDepth f ≤ (k : WithBot ℕ)}`, and the pair
(class inclusion, tropical truncation) forms a **Galois connection**; the hierarchy
`VAL_k ⊆ VAL_{k+1}` is the tropical statement `(k:WithBot ℕ) ≤ k+1` transported across it.
*The key insight is* that the order-theoretic hierarchy of computation classes is literally
the order of the tropical object — depth separation theorems become tropical
*non-collapse* statements. *Why now?* `ValDepthClassSet.subset_succ` and `subset_of_le`
are already proven in ℕ; lifting them to the `WithBot ℕ` order via `tropDepth` is
mechanical and would unify the two hierarchies into one adjunction.

### 5. Min-plus dual and a tropical Legendre duality of computational cost
**Conjecture.** Replacing `max` by `min` (and `WithBot` by `WithTop`) yields a *min-plus*
weight `cotropDepth` measuring the **cheapest** valuation route, and `tropDepth`/
`cotropDepth` are exchanged by a tropical Legendre/Fenchel duality; depth-nonincreasing
maps that are nonexpansive for one are expansive-bounded for the other.
*The key insight is* that worst-case and best-case computational depth are the two
tropical semiring structures on the same ordered group, dual under negation — so a single
construction yields both an upper-bound and a lower-bound certificate. *Why now?* The
catalog already contains min-plus machinery (`Bridges/MinPlusHarmonicAnalysis.lean`,
`Bridges/MinPlusVerificationCore.lean`); pairing it with `tropDepth` is the natural,
immediately testable cross-domain merge.
