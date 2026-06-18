# FUTURE DIRECTIONS — Tropical Persistent Topology

Research cycle: *Topological Data Analysis of Theorem Networks* (Domain: Tropical).
Foundation laid in `Catalog/Tropical/Persistence/SublevelFiltration.lean`:
tropical polynomials are convex, their sublevel filtrations have a single-bar
degree-0 persistence, and the tropical semiring operations `⊕ = max`, `⊗ = +`
act on value functions and on the filtration in a controlled way.

Below are bold, **testable** conjectures for follow-up cycles. Each is stated so
that it can be formalized as a Lean theorem (or refuted by a Lean
counterexample).

## C1 — Degree-`k` persistence collapse (k ≥ 1)
**Conjecture.** For every tropical polynomial `p : TropPoly n` and every threshold
`c`, the sublevel set `sublevel p c` is contractible whenever it is nonempty;
hence *all* reduced persistent homology vanishes and the full persistence diagram
is the single H₀ bar already established.
*Test.* Strengthen `convex_sublevel` to `Contractible`/`StarConvex` (a convex set
in `ℝⁿ` is contractible). Formalize via `Convex.contractibleSpace` or by
exhibiting a star-center. Falsifiable: produce a `p`, `c` with disconnected or
holey sublevel set (impossible if convexity is unconditional — so the conjecture
predicts no such example exists).

## C2 — Tropical hypersurfaces are the true carriers of topology
**Conjecture.** Replace the *sublevel* set by the **tropical hypersurface**
(the non-differentiability locus `V(p) = { x | the max in p.toFun x is attained
≥ twice }`). Then the filtration of `ℝⁿ \ V(p)` by connected components is
governed by `card p.ι`: the number of top-dimensional regions equals the number
of monomials that are "essential" (achieve the max somewhere), and this count is
*sub-additive* under `⊕` and *multiplicative-with-defect* under `⊗`.
*Test.* Define `essential p = { i | ∃ x, p.toFun x = monomial (coeff i) (slope i) x }`
and prove `essential (tropAdd p q) ⊆ image essential p ∪ image essential q`.

## C3 — Persistence stability for tropical polynomials  *(pointwise core: PROVED)*
**Status.** The pointwise, dimension-free part is established as `toFun_stable`
in `SublevelFiltration.lean`: `|p.toFun x − (p.recoeff a').toFun x| ≤
⨆ᵢ |coeffᵢ − a'ᵢ|`, uniformly in `x`, with the generic `sup'`-Lipschitz lemma
`abs_sup'_sub_sup'_le`.
**Remaining conjecture.** Lift this to *barcode* stability: the degree-0 birth
value `b(p)` (see C4) is `1`-Lipschitz in the coefficients, and more generally the
bottleneck distance of persistence diagrams is bounded by the sup-distance of
coefficients.
*Test.* Combine `toFun_stable` with the existence of a minimizer (C4) to bound
`|b(p) − b(q)|`. Falsifiable by any coefficient perturbation producing a
birth-value jump exceeding the perturbation.

## C4 — Newton-polytope ↔ persistence dictionary
**Conjecture.** The birth value `b(p) = inf { c | sublevel p c ≠ ∅ }` of the
single H₀ bar equals the value of the tropical polynomial at the *tropical
minimum*, and is determined entirely by the lower hull of the lifted Newton
polytope `{ (slope i, coeff i) }`. In particular `b(tropMul p q) = b(p) + b(q)`
and `b(tropAdd p q) = min (b(p)) (b(q))` whenever the relevant infima are
attained (e.g. all slopes nonzero / coercive case).
*Test.* Introduce a coercivity hypothesis guaranteeing attainment, prove
existence of a global minimizer (`IsCompact` sublevel sets), then the additive
and min laws for `b` follow from `toFun_tropMul` and `toFun_tropAdd`.

## C5 — Theorem-network functoriality (the meta-TDA layer)
**Conjecture.** Assigning to each tropical polynomial its persistence barcode is
*functorial* over the tropical semiring: there is a barcode-valued semiring
homomorphism sending `⊕` to barcode-min and `⊗` to barcode-sum, extending the
catalog's `TropicalSemiringHom`. Formally, the assignment
`p ↦ b(p) ∈ (ℝ, min, +)` is a semiring homomorphism into the tropical semiring
itself — i.e. tropical persistence is a *self-map of the tropical line*.
*Test.* Once C4 supplies `b`, prove `b` is a `min`-`+` homomorphism, closing the
loop with `Tropical/NeuralNetworks/TropicalSemiringHom.lean`. Falsifiable if any
`p, q` violate `b(p ⊕ q) = min (b p) (b q)`.
