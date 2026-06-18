# Future Directions: Maslov Dequantization and Tropical Limits

The file `MaslovDequantization.lean` proves the analytic core of "tropicalization as a
limit": under the deformation `x ⊕ₜ y = (1/t)·log(eᵗˣ + eᵗʸ)`, classical addition of
exponentials degenerates to the tropical operations `max` (and dually `min`) as `t → ∞`,
both in the binary case (`maslov_max`, `maslov_min`) and over arbitrary nonempty finite
families (`maslov_max_finset`). This sits alongside the catalog's existing min-plus/idempotent
infrastructure (`Tropical/MinPlusAlgebra.lean`, `Tropical/Basic.lean`,
`Tropical/SemiclassicalLimit.lean`, `Tropical/AmoebaRonkin.lean`) and provides the rigorous
`t → ∞` bridge those files describe combinatorially. The following directions extend it.

## 1. Tropicalization of a polynomial as a uniform limit of its log-deformation

Define, for a real polynomial `p(x) = Σⱼ cⱼ x^{aⱼ}` with positive coefficients, the family
`Pₜ(ξ) = (1/t)·log p(e^{t ξ})` and show it converges, **locally uniformly in `ξ`**, to the
tropical polynomial `trop p (ξ) = maxⱼ ( (1/t)·log cⱼ + aⱼ·ξ )` as `t → ∞`. The pointwise
statement is an immediate corollary of `maslov_max_finset` applied to `fⱼ(ξ) = log cⱼ / t +
aⱼ ξ`; the new content is the **uniformity** and the consequent convergence of the corner
loci (the non-differentiability set of `Pₜ` to that of `trop p`).
The key insight is that `maslov_max_finset` already controls the error by the *coefficient-
independent* term `(log card)/t`, so the convergence is automatically uniform on compact sets
once the exponents `aⱼ` are fixed — the bound never sees `ξ`.
Why now? The squeeze bound with an explicit `(log k)/t` error term is exactly the modulus of
uniform convergence; with it proved, the uniform statement is a packaging exercise rather than
a new analytic estimate.

## 2. Hausdorff convergence of amoebas to their tropical skeleton

For a Laurent polynomial in two variables, the amoeba is `A(p) = { log|z| : p(z)=0 }`, and its
"spine"/tropical limit is the corner locus of `trop p`. Conjecture: the rescaled amoebas
`(1/t)·A(p_t)`, for the valuation-deformed family `p_t`, converge in the Hausdorff metric to
the tropical curve, with rate `O((log k)/t)` inherited from the soft-max bound.
The key insight is that membership in an amoeba is governed by which monomial dominates, and
the soft-max bounds of this file quantify *exactly* the width of the transition region where no
single monomial dominates — that width is the Hausdorff defect.
Why now? Mathlib lacks any amoeba theory, but the catalog already has `Tropical/AmoebaRonkin.lean`;
the missing quantitative ingredient is the dominance estimate, which `logSumExp_ge`/`logSumExp_le`
now supply in closed form.

## 3. Dequantization is a semiring homomorphism in the limit

Show that the maps `⊕ₜ` and ordinary `+` make `(ℝ, ⊕ₜ, +)` into a family of semirings
deforming continuously to the tropical semiring `(ℝ ∪ {-∞}, max, +)`, by proving the limiting
distributivity and associativity *as limits of the deformed operations* (not merely as
identities in the target). Concretely: `lim_t ( (x ⊕ₜ y) + z ) = (lim_t x⊕ₜy) + z` and
associativity of `⊕ₜ` holds for each finite `t` up to an error `→ 0`.
The key insight is that associativity of `⊕ₜ` is exact for every `t` (since
`log(eᵃ+eᵇ+eᶜ)` is symmetric), so only the *interchange with `+`* needs the limit — and that
follows by applying `maslov_max` to translated families `f i + z`.
Why now? `maslov_max_finset`'s arbitrary-index form lets us treat reassociation as a single
finite-family limit rather than a tower of binary limits, removing the usual epsilon-management.

## 4. Quantitative central-limit / large-deviations refinement

Strengthen `maslov_max` to a full asymptotic expansion: with `m = max x y` and `g = |x - y|`,
`(1/t)·log(eᵗˣ+eᵗʸ) = m + (1/t)·log(1 + e^{-t g}) = m + O(e^{-t g}/t)` when `x ≠ y`, and
`= m + (log 2)/t` exactly when `x = y`. This identifies the *second-order* dequantization
correction and connects it to the free-energy / log-partition function of a two-state system at
inverse temperature `t`.
The key insight is that the error term in the current squeeze is not just `O(1/t)` but
exponentially small in the *tropical gap* `g`, so the convergence is dramatically faster away
from the corner locus — making the corner locus the only place the limit is "slow".
Why now? The exact bounds `logSumExp_ge`/`logSumExp_le` already bracket the partition function;
extracting the exponential tail only requires replacing the `≤ log 2` step with
`log(1 + e^{-tg})`, a one-line strengthening of an already-proved lemma.

## 5. Non-Archimedean valuation form: the tropical fundamental theorem

Replace the real parameter `t` by a non-Archimedean valuation `v : K → ℝ ∪ {∞}` on a field `K`
and prove the order-theoretic shadow of `maslov_max`: for the coordinatewise valuation of a
point on `V(p)`, the minimum defining the tropical variety is attained at least twice (Kapranov's
theorem / the tropical fundamental theorem), recovered here as the statement that the *limit*
operation `max` (resp. `min`) loses strict dominance exactly on the corner locus identified in
Direction 1.
The key insight is that "attained twice" is the discrete avatar of "the soft-max error
`(log 2)/t` stops vanishing": ties in the valuation are precisely where the analytic limit is
non-smooth.
Why now? The catalog already contains `Tropical/PAdicTropical.lean` and Satake/valuation
machinery; bridging it to the analytic limit proved here would unify the project's two existing
treatments of tropicalization (combinatorial and valuation-theoretic) under one quantitative
roof.
