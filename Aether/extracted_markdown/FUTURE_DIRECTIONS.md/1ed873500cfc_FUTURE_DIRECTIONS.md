# Future Directions — Definable Ricci-Flow Renormalization Fixed Points on Simplicial Hodge Laplacians

## Synthesis

This cycle formalized the **fixed-point and energy-dissipation skeleton** of a discrete
Ricci-flow / renormalization-group (RG) step on the cochain space of a simplicial
complex, modeled as one gradient step
`T = ricciStep L α = 1 - α·L`
of the Dirichlet energy of a symmetric positive-semidefinite Hodge Laplacian
`L : E →ₗ[ℝ] E`. The new file `RicciFlowHodgeFixedPoints.lean` deliberately *extends*
the catalog's `HodgeMessagePassingConvergence.lean`: where that file proved one-sided
facts about iterating `T` (harmonics are *a* fixed point, residual energy contracts),
this cycle pins down the **exact structure** of the flow's fixed-point set and the
**monotone variational principle** that drives it.

The conceptual payload is the chain of identifications

> renormalization fixed points  =  harmonic cochains `ker L`  =  CSS-code / cohomology space,

made rigorous as a biconditional (`ricciStep_fixed_iff_harmonic`), as an equality of
submodules (`ricciStep_fixedSubmodule_eq_ker`), and as a dimension equality bridging to
quantum codes (`ricciFlow_logicalDim_eq_kerDim`). The Dirichlet energy is shown to be a
strict Lyapunov function off the fixed-point set (`ricciStep_dirichlet_dissipation`,
`ricciStep_dirichlet_strict`) and monotone along the entire flow
(`ricciFlow_dirichlet_antitone`) — the discrete analogue of total-curvature decrease
under continuous Ricci flow.

## Results Summary

All theorems are proved `sorry`-free over an arbitrary real inner-product space `E`,
depending only on the standard axioms `propext, Classical.choice, Quot.sound`.

1. `ricciStep_harmonic_fixed` — harmonic cochains are fixed by every step.
2. `ricciStep_fixed_iff_harmonic` — for `α ≠ 0`, `T x = x ⇔ L x = 0` (the *exact*
   characterisation; upgrades the catalog's one-directional lemma).
3. `ricciStep_fixedSubmodule_eq_ker` — the fixed-point set is the submodule `ker L`.
4. `ricciStep_dirichlet_dissipation` — one step drops the energy by `α(2-αλ)‖L x‖²`.
5. `ricciStep_dirichlet_strict` — strict energy decrease away from harmonics.
6. `ricciFlow_dirichlet_antitone` — energy non-increasing along the whole flow.
7. `ricciFlow_logicalDim_eq_kerDim` — `dim(fixed points) = dim(ker L)` = number of
   logical degrees of freedom (Betti number / logical qubits) of the CSS code.

---

## Bold, falsifiable research directions

### Direction 1 — The fixed-point projector is the harmonic (cohomology) projection

**Conjecture.** On a finite-dimensional `E` with `L` symmetric PSD and spectral gap
`0 < μ ≤ λ`, for any spectrally admissible step `0 < α < 2/λ`, the iterates `Tᵏ`
converge in operator norm to the **orthogonal projection** `P_{ker L}` onto the
harmonic subspace; equivalently `lim_k Tᵏ` is idempotent with range `ker L` and kernel
`(ker L)ᗮ`. Falsifiable: exhibit a PSD `L` and admissible `α` for which `Tᵏ` does *not*
converge to the orthogonal (rather than merely some) projector.

*The key insight is* that `ricciStep_fixedSubmodule_eq_ker` already identifies the
range of the limit with `ker L`; combining it with the residual contraction of
`HodgeMessagePassingConvergence` on `(ker L)ᗮ` and self-adjointness of `T` forces the
limit to be the *orthogonal* projector, not just any projection onto the harmonics.

*Why now?* This cycle proved both halves separately (fixed set = `ker L`; residual
energy `→ 0`). The only missing rigidity is that the complementary decay happens along
`(ker L)ᗮ`, which `RealInnerProductSpace`/`OrthogonalProjection` API in Mathlib now
supports directly — so the operator-norm limit statement is within one cycle's reach.

### Direction 2 — A discrete Bonnet–Myers / spectral-gap lower bound from Ricci curvature

**Conjecture.** If the 1-skeleton carries a definable discrete Ollivier/Forman–Ricci
curvature bounded below by `κ > 0` on every edge, then the smallest nonzero eigenvalue
of the graph Hodge Laplacian satisfies `μ ≥ κ`, hence the Ricci-flow step with
`α = 1/λ` contracts the residual energy at rate `1 - κ/λ`. Falsifiable: a bounded-degree
complex with edge curvature `≥ κ` but spectral gap `< κ`.

*The key insight is* that the contraction factor `1 - μ/λ` proved optimal in the
catalog (`contraction_factor_at_optimal`) is governed entirely by the spectral gap `μ`;
a curvature lower bound `κ ≤ μ` therefore converts geometry directly into a *certified
convergence rate* for the renormalization flow.

*Why now?* The variational machinery (Rayleigh bounds feeding `nlinarith`) used in
`ricciStep_dirichlet_dissipation` is exactly the bilinear-form calculus needed to
encode a discrete Bochner formula `⟪Lx,x⟫ ≥ κ‖x‖²` on the orthogonal complement; the
curvature → gap implication then becomes a finite linear-algebra inequality.

### Direction 3 — Renormalization preserves CSS code distance below a curvature threshold

**Conjecture.** There is a nontrivial family of bounded-degree simplicial CSS codes and
a step `α` for which the Ricci-flow RG map, restricted to the syndrome (non-harmonic)
sector, *strictly* decreases the Dirichlet energy at every step while the logical
dimension `dim(ker L)` is invariant — so the flow is a distance-non-decreasing,
dimension-preserving RG coarse-graining. Falsifiable: a code in the family where one RG
step lowers `dim(ker L)` (logical information is lost).

*The key insight is* that `ricciFlow_logicalDim_eq_kerDim` makes the logical dimension a
*topological invariant of the flow's fixed-point set*, decoupled from the energy that
`ricciFlow_dirichlet_antitone` dissipates: logical content lives in `ker L`, errors live
in `(ker L)ᗮ` and are precisely what the flow damps.

*Why now?* With the fixed-point/energy split formalized over an abstract `L`, one can
now instantiate `L` as the concrete `BᵀB` boundary Laplacian of a CSS chain complex and
inherit every theorem; the remaining work is the combinatorial construction of the code
family, not the flow analysis.

### Direction 4 — Definability (model-theoretic tameness) of the fixed-point set

**Conjecture.** For the family of Laplacians arising from o-minimally definable
weightings on a fixed simplicial complex, the assignment `(weights) ↦ dim(ker L)` is
definable and takes finitely many values; i.e. the logical dimension is a *constructible*
(piecewise-constant) function of the geometric data. Falsifiable: a definable weight
family along which `dim(ker L)` varies non-constructibly.

*The key insight is* that `dim(ker L)` jumps only on the (definable) locus where `L`
drops rank, and `ricciFlow_logicalDim_eq_kerDim` ties this jump locus to the fixed-point
set of the flow — turning a spectral-stability question into a tame-geometry statement.

*Why now?* This cycle isolated `dim(ker L)` as the single invariant of interest; the
catalog already contains definability/o-minimality and ultraproduct infrastructure
(`Algebra/DependentUltraproduct`, logic files), so cross-pollinating the linear-algebra
invariant with that tameness toolkit is a natural, well-supported next step.

### Direction 5 — Quantitative metastability of the discrete Ricci flow

**Conjecture.** Define the energy gap `G_k = dirichlet L (Tᵏ x) - dirichlet L (P_{ker L} x)`.
Then `G_k ≤ (1 - μ/λ)^k G_0` and, conversely, `G_k ≥ c·(1 - μ/λ)^k` for generic `x`, so
the flow exhibits a *sharp* exponential metastability rate set by the spectral gap, with
no algebraic slowdown. Falsifiable: an input `x` (with nonzero `(ker L)ᗮ`-component) for
which the energy gap decays strictly faster than `(1-μ/λ)^k`.

*The key insight is* that `ricciFlow_dirichlet_antitone` already gives the upper
envelope; the matching lower bound follows because, on the slowest eigenmode, the energy
drop in `ricciStep_dirichlet_dissipation` is an *equality*, pinning the rate exactly.

*Why now?* The explicit per-step drop `α(2-αλ)‖Lx‖²` proved this cycle is precisely the
quantity needed to convert the qualitative `antitone` statement into a two-sided
geometric rate; eigenmode decomposition is the only added ingredient, and it is standard
finite-dimensional spectral theory already in Mathlib.
