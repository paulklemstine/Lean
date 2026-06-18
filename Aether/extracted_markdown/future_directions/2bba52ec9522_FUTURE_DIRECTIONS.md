# Future Directions: Arithmetic Mirror Symmetry for Calabi–Yau Manifolds

The file `ArithmeticMirrorSymmetry.lean` formalizes the *numerical and arithmetic
shadows* of mirror symmetry: the Hodge-number exchange `h¹¹ ↔ h²¹` (with its
consequences `arithmetic_mirror`, `euler_mirror`, `mirror_involutive`,
`hodge_sum_invariant`, `self_mirror_euler_zero`) and the arithmetic counterpart —
the zeta functional equation `zeta_functional_equation` driven by the Poincaré
duality `α ↦ q/α` on Frobenius eigenvalues, together with the constant identity
`zeta_constant_sq`. The following conjectures push this frontier forward.

## 1. Hodge-polynomial mirror duality

Extend `CalabiYau` from a pair `(h11, h21)` to the full Hodge diamond of an
`n`-fold (a function `Fin (n+1) × Fin (n+1) → ℕ` subject to Hodge symmetry and
Serre duality), define the Hodge polynomial `E(u,v) = Σ h^{p,q} u^p v^q`, and prove
that mirroring induces the substitution `E_Y(u,v) = (-u)^n E_X(u^{-1}, v)` on the
*virtual* (signed) Hodge polynomial, recovering `euler_mirror` as the specialization
`u = v = 1`.

The key insight is that `euler_mirror` is the `u=v=1` slice of a polynomial identity,
so the entire mirror exchange is governed by *one* substitution rule on `E(u,v)`
rather than a separate statement per Hodge number — making the whole diamond fall
out of a single algebraic lemma. Why now? The two-number case is already proved and
`Multiset`/`Finsupp` polynomial machinery in Mathlib makes the bookkeeping for the
full diamond a finite, mechanical extension rather than new mathematics.

## 2. Modularity of rigid Calabi–Yau zeta factors (weight-4 forms)

For a *rigid* threefold (`h²¹ = 0`, i.e. `curveModuli X = 0`), the interesting
middle-cohomology zeta factor has degree 2, so its eigenvalue multiset is a single
dual pair `{α, q/α}`. Conjecture: under the rigidity hypothesis the functional
equation produced by `zeta_functional_equation` matches *exactly* the functional
equation of a weight-4 Hecke eigenform's `L`-factor, with `zeta_constant_sq` forcing
`α · (q/α) = q = p` (so `|α| = p^{3/2}`, the Ramanujan/Hasse–Weil weight-4 bound).

The key insight is that `zeta_constant_sq` already pins the *constant* of the
functional equation to `q^{#E}`, which is precisely the data that distinguishes
weight `k = (#E)/(#pairs) + 1`; rigidity collapses `#E` to 2 and hence selects
weight 4 with no further input. Why now? The general functional equation is proved
`sorry`-free, so the modularity statement reduces to identifying the degree-2 case
with Mathlib's emerging modular-forms `L`-function API rather than re-deriving the
Weil bounds.

## 3. SYZ torus-fibration Euler-number sum rule

Formalize the Strominger–Yau–Zaslow picture combinatorially: model a special
Lagrangian `T³`-fibration `X → B` by a base poset of singular fibers, and prove a
sum rule expressing `euler X` as a signed count over singular fibers, with the
*dual* fibration (fiberwise `Hom(T³, U(1))`) realizing `mirror X` and reversing
every local contribution sign — a structural refinement of `euler_mirror`.

The key insight is that `euler_mirror`'s global sign flip should be the sum of
*local* sign flips at singular fibers, so SYZ duality becomes a fiber-local
involution whose global shadow we have already proved. Why now? With the global
identity in hand, the remaining content is a finite combinatorial accounting of
fiber types, which is exactly the kind of discrete structure that is tractable to
formalize without analytic special-Lagrangian geometry.

## 4. Frobenius-pairing rigidity: invariance forces a pairing

In `zeta_functional_equation` the hypothesis `E.map (q/·) = E` is *assumed*.
Conjecture: any finite multiset `E ⊆ ℂˣ` whose attached zeta polynomial satisfies
the functional-equation conclusion for all `T` must already be `(q/·)`-invariant,
i.e. the functional equation is *equivalent* to Poincaré duality of eigenvalues, not
merely implied by it.

The key insight is that the functional equation is a polynomial identity in `T`, so
comparing roots on both sides turns the analytic symmetry back into the set-theoretic
involution `α ↦ q/α` — duality and the functional equation are the same fact viewed
two ways. Why now? `zeta_functional_equation` gives the forward direction
constructively; the converse is a root-counting argument over `ℂ[T]`, for which
Mathlib's `Polynomial.roots` / multiset-of-roots theory is fully developed.

## 5. Cross-domain bridge: intersection forms ↔ zeta duality

The catalog's `SmoothPoincare.IntersectionForms` encodes Poincaré duality as a
unimodular symmetric bilinear form. Conjecture: for a Calabi–Yau realized as (the
total space governed by) a 4-manifold, the eigenvalue involution `α ↦ q/α` of
`zeta_functional_equation` is conjugate to the adjoint involution of the
intersection form, so the *signature* of the intersection form equals the sign
`(-1)^{#E}` appearing in the zeta functional equation.

The key insight is that both objects are incarnations of one duality pairing — a
symmetric form on cohomology — so the topological invariant (signature) and the
arithmetic invariant (functional-equation sign) must agree. Why now? Both endpoints
are already formalized in this project (`IntersectionForms` and
`zeta_functional_equation`), so the bridge is a matching theorem between two existing
`sorry`-free developments rather than new foundational work — the highest-leverage
novelty available.
