# Future Directions: An Abstract, Conformally-Invariant Yamabe Framework

## Synthesis

This cycle built, from a cold start, a small but load-bearing piece of formal Riemannian
geometry: an **abstract variational skeleton of the Yamabe problem** together with its
**first concrete instance** on the finite "manifold" `Fin n`. The unifying move is to
strip the Yamabe quotient `Q(u) = E(u) / V(u)^{2/p}` of all geometric scaffolding and
expose it as a purely structural object built from two positively-homogeneous functionals
on a vector space of "functions" `ι → ℝ`. Three facts then turn out to be geometry-free:

* **Conformal invariance** (`yamQ_scale_inv`) is the algebraic cancellation
  `(c^p · V)^{2/p} = c^2 · V^{2/p}` against the degree-2 energy. The critical exponent
  `p` is *forced* by demanding this cancellation — the "2" of the energy and the "2/p" of
  the normalization are conjugate by design.
* **Finiteness of the Yamabe constant** (`discrete_yamConst_lower`) is, on `Fin n`, exactly
  a **power-mean / Hölder inequality** `∑ uᵢ² ≤ n^{1-2/p}(∑|uᵢ|^p)^{2/p}` (the discrete
  Sobolev inequality, `l2_le_card_rpow_mul_lp`) combined with a lower bound `Sᵢ ≥ -C` on
  the scalar curvature. The Dirichlet (gradient) energy enters only through its
  non-negativity — the single place geometry shows up.
* **Aubin-type monotonicity** (`yamConst_mono`) — `E₁ ≤ E₂ ⟹ Y₁ ≤ Y₂` — is just
  monotonicity of a conditional infimum once finiteness furnishes the `BddBelow` witness.

## Results Summary (all proved, `sorry`-free, standard axioms only)

* `yamQ_scale_inv` — conformal (scale) invariance of the Yamabe quotient from
  `PosHomog E 2` and `PosHomog V p`.
* `yamConst_le_yamQ` — the Yamabe constant is a genuine lower bound (via `ciInf_le`).
* `yamConst_mono` — Aubin monotonicity of the Yamabe constant under energy domination.
* `l2_le_card_rpow_mul_lp` — the sharp discrete Sobolev / power-mean inequality.
* `Edisc_lower`, `discrete_yamQ_lower`, `discrete_yamQ_bddBelow`,
  `discrete_yamConst_lower` — finiteness of the discrete Yamabe constant:
  `Y ≥ -C · n^{1-2/p}`.

A correction worth recording: the curvature-bound conjecture circulating as
`yamConst ≥ -C·n^{2/p}` has the **wrong exponent**; the sharp constant is `n^{1-2/p}`,
i.e. `1/q` for `q` the Hölder conjugate of `p/2`. The formalization makes this precise.

---

## Direction 1 — Sharpness of the discrete Sobolev constant

We proved `∑ uᵢ² ≤ n^{1-2/p}(∑|uᵢ|^p)^{2/p}`. The constant `n^{1-2/p}` should be
**optimal**, attained exactly at the constant vector `uᵢ ≡ 1` (the discrete analogue of
the round, constant-curvature metric). Conjecture: `yamConst (Edisc 0) (Vdisc p) p` for
the zero potential equals `0` and is attained, and for `Sᵢ ≡ s` constant the minimizer of
the quotient is the constant vector with value `s · n^{1-2/p}`.

The key insight is that equality in Hölder forces the two functions to be proportional in
the `Lᵖ`/`Lq` sense, which on a finite set collapses to "`|uᵢ|` is constant"; the gradient
term then vanishes exactly on constants, so the constant vector is simultaneously optimal
for *both* halves of the energy.

**Why now?** `l2_le_card_rpow_mul_lp` is in hand; proving attainment is a finite
optimization (evaluate the quotient at `u ≡ 1`) plus the equality case of `Finset`-Hölder,
both fully formalizable with current Mathlib, and it upgrades the lower bound from an
inequality to the *exact* discrete Yamabe constant.

## Direction 2 — Aubin comparison as a genuine two-manifold statement

`yamConst_mono` already gives the abstract half of Aubin's inequality
`Y(M,[g]) ≤ Y(Sⁿ,[g₀])`. The missing half is a **test-function (bubble) construction**:
exhibit, for the discrete model, a one-parameter family `u_t` concentrating at a single
site whose quotient converges to the "sphere" value, certifying that the comparison energy
`E₂` is actually achieved in the limit.

The key insight is that on `Fin n` a "bubble concentrating at a point" is simply a spike
`u_t = δ_{i₀} + t·(rest)`; as `t → 0` its `ℓ²`/`ℓᵖ` ratio tends to `1` (a single nonzero
coordinate makes `n^{1-2/p}` irrelevant), isolating the *local* model that the continuous
bubble blows up.

**Why now?** With finiteness and monotonicity proved, the only new ingredient is an
explicit sequence and a limit computation — pure sequence analysis, no differential
geometry — making this the cheapest path to a formalized Aubin-type upper bound.

## Direction 3 — Compact vs. non-compact dichotomy (concentration–compactness)

On `Fin n` every minimizing sequence sub-converges (finite-dimensional compactness), so the
infimum `yamConst` is attained; on `ℕ` it need not be. Conjecture: build an explicit
minimizing sequence on `ℕ → ℝ` for an analogous quotient that **vanishes** (mass escaping to
infinity), so the infimum is *not* attained — the formal shadow of why the Yamabe problem
is hard on non-compact manifolds.

The key insight is that concentration–compactness is fundamentally the dichotomy between a
compact index (`Fin n`, where `iInf` over a continuous coercive functional is attained) and
a non-compact one (`ℕ`, where translation `uᵢ ↦ u_{i+k}` produces an energy-preserving,
non-convergent sequence) — translation invariance is the precise obstruction.

**Why now?** Both endpoints are reachable: attainment on `Fin n` follows from
`discrete_yamQ_bddBelow` plus continuity/compactness, and the vanishing sequence on `ℕ` is
an explicit translated bump requiring only elementary analysis.

## Direction 4 — The conformal Laplacian as a cocycle

Conformal invariance was proved here at the level of the *quotient*. The deeper statement
is **operator covariance**: a conformal Laplacian `L` should satisfy
`L(φ · u) = φ^{-(n+2)/(n-2)} L̃(u)` so that the quadratic form `⟨u, Lu⟩` reproduces the
energy `E`. Conjecture: model `L` abstractly as a linear map with this transformation law
and recover `yamQ_scale_inv` as a *corollary* of a one-line cocycle identity.

The key insight is that the scaling exponents `2` and `p` of our `PosHomog` data are the
shadow of a **1-cocycle of the conformal group acting on densities**; promoting the scalar
homogeneity to an operator-level cocycle condition unifies the algebraic (group action) and
analytic (PDE) faces of conformal invariance in a single statement.

**Why now?** `PosHomog` and `yamQ` are in place; introducing `L` as a `LinearMap` with a
prescribed conjugation law and deriving the energy's transformation is a self-contained
algebra problem that categorifies the result we already have.

## Direction 5 — Uniqueness in the negative case via strict convexity

When `yamConst < 0` the constant-scalar-curvature representative is unique up to scaling.
Conjecture (abstract form): if `yamConst E V p < 0` and `E` is strictly convex and coercive
(`E(u) ≥ c‖u‖²`), then any two unit-volume critical points of `yamQ` coincide.

The key insight is that negativity flips the Euler–Lagrange multiplier `λ < 0`, making the
constrained Lagrangian `E - λV` strictly convex on the constraint surface `V(u) = 1`, so a
critical point is the *unique* global minimizer — uniqueness reduces entirely to convexity,
no maximum principle required.

**Why now?** The Yamabe constant and its sign are formalized; adding a `ConvexOn`
hypothesis to `E` and invoking strict-convexity uniqueness from Mathlib's convexity library
gives the first formal treatment of the "easy" (negative) case of the Yamabe problem, the
one most relevant to hyperbolic 3-manifold topology.
