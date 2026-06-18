# Future Directions — Spectral Gap Rigidity for Hodge Laplacians

## Synthesis

This cycle built a self-contained, `sorry`-free local-to-global theory for abstract
Hodge Laplacians and its consequences for spectral-gap message passing, in
`Catalog/MachineLearning/SpectralGapRigidity.lean`. The architecture deliberately
mirrors the sheaf-theoretic playbook used elsewhere in the catalog (compare the Čech
machinery of `Catalog/MachineLearning/CechComplex.lean` and the message-passing line of
`Catalog/Speculative/AutoResearch/HodgeMessagePassingConvergence.lean`): a
**stalk-level** rigidity fact is proved first, glued into a **global** harmonicity
criterion, made **functorial** under coarse-graining, and finally turned into
**quantitative dynamics**.

The conceptual spine is a single pointwise identity,
`psd_operator_inner_self_eq_zero`: for a symmetric positive–semidefinite operator,
the scalar energy equation `⟪x, L x⟫ = 0` *forces* the vector equation `L x = 0`. The
decisive point is that this is proved purely algebraically, via Cauchy–Schwarz for the
positive–semidefinite bilinear form `B(x,y) = ⟪x, L y⟫` — **no spectral theorem and no
finite-dimensionality is assumed**, so the whole theory runs over an arbitrary real
inner-product space. Everything else is `inner_add_right` bookkeeping plus this stalk
fact. From it we obtain:

* `harmonic_iff` — the Hodge harmonicity criterion: a cochain is globally harmonic
  (`Δ x = 0`) iff it is locally closed and coclosed (`up x = 0 ∧ down x = 0`). This is
  the algebraic heart of `ker Δ ≅ H*`, the local-to-global gluing of cohomology.
* `harmonic_pushforward` + `gap_transfer_isometry` — cohomology is functorial under any
  intertwiner, and an *isometric* intertwiner transfers the spectral gap exactly. This
  is the rigidity statement: coarse-graining an expanding complex into an isometric
  intertwined model preserves the gap.
* `gap_implies_vanishing` — a positive spectral gap kills all harmonics (an expander
  has no nontrivial cohomology), and the message-passing engine (`mpStep_contraction`,
  `mpStep_iterate_contraction`, `gap_mpStep_converges`, `gap_optimal_mpStep_converges`)
  drives every signal to the trivial cohomology at the spectral rate `1 - μ/λ`, with
  `α = 1/λ` optimal (`contraction_factor_optimal`).

This connects three catalog domains: the local-to-global sheaf/Čech engine, the
abstract Hodge line, and the `MachineLearning` message-passing line, in a
dependency-free form (only `import Mathlib`) that any later cycle can build on without
inheriting fragile imports.

## Results Summary

Fifteen named results, all proved with `sorry = 0` (the string "`sorry`-free" appears
only in docstrings):

1. `psd_operator_inner_self_eq_zero` — stalk rigidity of the energy form.
2. `hodgeLaplacian_symm`, `hodgeLaplacian_psd` — `Δ = up + down` is symmetric PSD.
3. `harmonic_iff` — global harmonic ⇔ local closed + coclosed.
4. `harmonic_pushforward` — functoriality of cohomology under intertwiners.
5. `gap_transfer_isometry` — isometric intertwiners transfer the spectral gap.
6. `gap_implies_vanishing` — positive gap ⇒ trivial harmonic space.
7. `mpStep_apply`, `mpStep_harmonic_fixed`, `mpStep_iterate_harmonic_fixed` — the
   message-passing layer and exact transport of harmonics.
8. `mpStep_contraction`, `mpStep_iterate_contraction`, `gap_mpStep_converges` —
   per-layer and geometric energy contraction, convergence to tolerance.
9. `contraction_factor_optimal`, `contraction_factor_at_optimal`,
   `gap_optimal_mpStep_converges` — the spectral step `α = 1/λ` is optimal with rate
   `1 - μ/λ`, and deep optimal message passing collapses every signal.

All theorems depend only on the standard axioms `propext`, `Classical.choice`,
`Quot.sound`.

## Research Directions

**Direction 1 — Two-sided gap rigidity (a quantitative inverse).**
We proved that an *isometric* intertwiner pushes the gap *down* from the ambient space
to the coarse model (`gap_transfer_isometry`). Conjecture: a *co-isometric*
coarse-graining `P : E → F` with `P ∘ ι = 1_F` and `‖P‖ ≤ 1` produces a *two-sided*
sandwich `c·μ_E ≤ μ_F ≤ μ_E` for an explicit `c = c(P)` depending only on the operator
norm of `P` restricted to `(ker L_E)ᗮ`. This is falsifiable: a single finite example
with `μ_F > μ_E` or `μ_F < c·μ_E` refutes it. The key insight is that the gap is *not*
merely inherited but quantitatively *controlled* by the distortion of the
coarse-graining, so the Rayleigh quotient behaves like a Lipschitz functor of the
intertwiner rather than just a monotone one. Why now? We already have the one-sided
transfer and the isometry bookkeeping formalized; the missing piece is purely the
norm-of-`P` estimate, a routine `nlinarith`/Cauchy–Schwarz argument on top of the
existing scalar Rayleigh-gap API.

**Direction 2 — Obstruction cocycle for global harmonic extension.**
`harmonic_iff` says global harmonicity is detected by two local conditions. On a
*family* of overlapping local patches `{U_i}` of a complex, locally harmonic data need
not glue. Conjecture: the obstruction to extending locally harmonic cochains to a
global harmonic cochain is a single Čech 1-cocycle valued in `ker Δ`, and it vanishes
iff the patch nerve is acyclic in degree 1. Falsifiable on any explicit 2-patch cover
whose nerve has a 1-cycle. The key insight is that `harmonic_iff` already turns
"harmonic" into an equalizer of two linear maps, so the gluing problem is literally the
kernel of a Čech differential — no analysis required, only linear algebra over the
patch poset, which can reuse `Catalog/MachineLearning/CechComplex.lean`. Why now? The
stalk lemma and harmonicity criterion are in place; building the Čech complex of
finitely many subspaces and proving exactness in degree 0 is a direct `Finset`/
`LinearMap` development with no new mathematical input.

**Direction 3 — Sharp depth threshold for message passing from the gap.**
`gap_optimal_mpStep_converges` gives existence of a convergence depth `K`. Conjecture:
the *minimal* depth to reach energy tolerance `ε` is exactly
`K*(ε) = ⌈log(ε / ⟪r,r⟫) / log(1 - μ/λ)⌉`, and this is attained, not merely bounded.
Falsifiable: any operator/signal pair converging strictly faster than this rate (for
the optimal step) refutes the sharpness. The key insight is that the contraction factor
`1 - μ/λ` is achieved *exactly* on the bottom eigenvector of `(ker L)ᗮ`, so the
worst-case signal saturates the geometric bound and the `log/log` formula is tight
rather than an over-estimate. Why now? We have the optimal rate and the geometric decay
(`mpStep_iterate_contraction`); turning the `∃ K` into an explicit `⌈·⌉` formula needs
only `Nat.ceil` arithmetic plus a tightness witness, both within reach of the current
`tendsto_pow_atTop` machinery.

**Direction 4 — Gap stability under bounded-norm perturbations.**
Hypergraph Laplacians from bounded-degree complexes differ from their coarse models by
a low-rank or bounded-norm perturbation `Δ' = Δ + B`. Conjecture: if `‖B‖ ≤ δ < μ`
(operator-norm form of the Rayleigh perturbation), then `Δ'` retains a gap
`μ' ≥ μ - δ`, so the vanishing theorem (`gap_implies_vanishing`) is *robust*: small
bounded-norm edits cannot create spurious harmonics. Falsifiable by exhibiting a
perturbation with `‖B‖ < μ` that nonetheless produces a nonzero harmonic. The key
insight is that the whole theory runs on the *scalar* Rayleigh inequality, so a
perturbation enters additively as `⟪x, B x⟫ ≥ -δ⟪x,x⟫` and the gap bound degrades by
exactly `δ` — Weyl-type stability without any spectral-theorem import. Why now? Our gap
is stated as a clean `∀ x` scalar bound, so additive perturbation is a one-line
`linarith`; the only new ingredient is phrasing `‖B‖ ≤ δ` as a Rayleigh two-sided
bound, which the inner-product API already supports.

**Direction 5 — Functorial Hodge decomposition diagram for a coarse-graining tower.**
A scale tower `E_0 → E_1 → ⋯ → E_n` of coarse-grainings should induce a commuting
diagram of harmonic subspaces with `harmonic_pushforward` as the arrows. Conjecture:
the induced maps on harmonic spaces form an inverse system whose limit is the *global*
(finest-scale) cohomology, i.e. cohomology is computed by the tower in the sense that
`lim_k ker Δ_k ≅ ker Δ_0`. Falsifiable on any explicit 3-level tower where the limit
drops or gains a dimension. The key insight is that `harmonic_pushforward` is *already*
functorial (it is just `map_zero` after intertwining), so a tower of intertwiners
automatically yields a diagram of harmonic spaces — the content is only that the system
is *exact*, reducing a global cohomology computation to a sequence of local
coarse-graining steps. Why now? Functoriality is proven; assembling intertwiners into a
tower and taking the linear-algebra inverse limit is standard `Mathlib` `LinearMap`/
`Submodule` plumbing with no analytic obstruction.
