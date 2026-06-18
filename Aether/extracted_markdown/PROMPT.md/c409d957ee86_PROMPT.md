
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: Self-contained, sorry-free Lean 4 formalization of the
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Policy Gradient Geometry & Variance Reduction

## Synthesis

This cycle built a self-contained, sorry-free Lean 4 formalization of the
*differential geometry of softmax policy gradients* and the *variance-reduction
theory of baselines*, living in `Catalog/MachineLearning/PolicyGradient/`. The
research direction proposed combining the catalog's softmax infrastructure
(`Tropical/NeuralNetworks/SoftMaxConvergence.lean`, the scalar
`softmax_jacobian_diag` in `Tropical/TropicalMoonshots.lean`) and Bellman/MDP
machinery (`MachineLearning/FactoredBellmanResidual.lean`) into new convergence
statements. A reality check on the catalog was decisive: the lemmas the concept
note *assumed* already existed (`variance_shift_invariant`,
`baseline_objective_quadratic`) do **not** exist anywhere in the project — they
were aspirational. So rather than "extend" phantom results, we built the missing
foundation from scratch, in the same spirit (finite action set `Fin n`, real
sums, `expectVal`), so the next cycle has genuine objects to build on.

The structural insight that emerged is that the entire first-order theory of
softmax PG is *purely algebraic over a finite probability vector* and needs no
measure theory: the score `ψ_j(a) = 1_{a=j} − π_j`, the log-derivative identity
`E_π[ψ_j] = 0`, the Fisher closed form `F = diag(π) − π πᵀ`, its PSD-ness as a
genuine variance `vᵀ F v = E_π[(⟨v,ψ⟩)²]`, and the optimal-baseline quadratic
`M(b) = A b² − 2B b + C` are all finite-sum facts. The single reusable engine is
"expand the square / product, push constants through `Finset.mul_sum`, collapse
indicators with `Finset.sum_ite_eq'`, and reduce to the sum-to-one law". This is
exactly why the optimal-baseline results dropped out of one lemma
(`variance_reduction_amount`, the completed square `M(b) − M(b⋆) = A·(b − b⋆)²`):
minimization, uniqueness, and the strict inequality are corollaries, not new work.

What did *not* go through cheaply: the Fisher PSD identity required a careful
triple-sum reordering (`Finset.sum_comm` twice with explicit `f :=` annotations)
rather than a one-shot `simp` — the automation found a proof but left an `exact?`
and a redundant `∀` wrapper, which we replaced with an explicit
`E_π[(∑_j v_j ψ_j)²]` realization. That friction is the signal: the matrix-level
(as opposed to scalar) facts are where the next hard theorems live, and they
want a clean `Finset`-indexed quadratic-form API.

## Results Summary

- `softmaxPolicy_pos`: proved — the softmax policy is strictly positive, so
  `log π` and KL divergences are everywhere finite (no `log 0`).
- `softmaxPolicy_sum_one`: proved — softmax is a genuine probability distribution.
- `softmaxScore_expect_zero`: proved — the log-derivative/REINFORCE identity
  `E_π[ψ_j] = 0`; the algebraic heart of every unbiased PG estimator.
- `fisherInfo_eq`: proved — closed form `F_{jk} = π_j δ_{jk} − π_j π_k`,
  generalizing the catalog's 2-action `softmax_jacobian_diag` to all `n` and to
  off-diagonal entries.
- `fisherInfo_symm`: proved — the Fisher matrix is symmetric.
- `fisherInfo_psd`: proved — `F` is positive semidefinite, realized as the
  variance `vᵀ F v = E_π[(⟨v, ψ(·)⟩)²] ≥ 0`; the rigorous license for the
  Fisher–Rao metric of natural PG.
- `baseline_unbiased`: proved — subtracting any constant baseline preserves the
  gradient mean (`E_π[(R − b)s] = E_π[R s]`), needing only `E_π[s] = 0`.
- `secondMoment_quadratic`: proved — the estimator's second moment is exactly
  `A b² − 2B b + C` with `A = E_π[s²], B = E_π[R s²], C = E_π[R² s²]`.
- `variance_reduction_amount`: proved — the exact gain `M(b) − M(b⋆) = A·(b−b⋆)²`.
- `optimal_baseline_min`: proved — `b⋆ = E_π[R s²]/E_π[s²]` minimizes the second
  moment (hence variance, by `baseline_unbiased`).
- `optimal_baseline_strict`: proved — `b⋆` is the *unique* minimizer; any other
  baseline is strictly worse.

## Research Directions

### Direction 1: The optimal-baseline variance ratio is `1 − ρ²`
**Hypothesis**: With `A = E_π[s²]`, `B = E_π[R s²]`, `C = E_π[R² s²]` and the
centered estimator's variance `V(b) = E_π[ĝ_b²] − (E_π[R s])²`, the optimal
baseline achieves `V(b⋆) / V(0) = 1 − ρ²`, where `ρ² = B² / (A·C')` is the
squared correlation between the return `R` and `s²`-weighted score mass
(`C'` the appropriate second moment). Equivalently `V(b⋆) = C − B²/A − (E_π[Rs])²`.
**Test**: State `variance b := secondMoment ... − (E_π[R s])²` and prove
`variance b⋆ = variance 0 · (1 − ρ²)` by substituting the completed square from
`variance_reduction_amount` and dividing (guarding `V(0) ≠ 0`). A disproof would
be a finite `(p, R, s)` example where the ratio exceeds `1 − ρ²`.
**Why now**: `variance_reduction_amount` already gives the exact numerator gain
`A(b−b⋆)²`; only the normalization and a Cauchy–Schwarz bound (`B² ≤ A·C`,
provable from `fisherInfo_psd`-style sum-of-squares) remain.
**If true**: it ports the textbook control-variate bound into Lean with an exact
constant, closing the loop on "how much does a baseline help".
**If false**: the failure pinpoints exactly which independence/centering
hypothesis the `1 − ρ²` folklore silently assumes.

### Direction 2: State-dependent baselines and `b⋆(s) = V^π(s)`
**Hypothesis**: For an estimator stratified by state `s` with conditional scores
`ψ(·|s)` satisfying `E[ψ|s] = 0`, the per-state optimal baseline is independent
across states and equals the conditional second-moment ratio; under compatible
features this collapses to the value function `V^π(s)`.
**Test**: Generalize `expectVal` to a product index `State × Action`, prove a
conditional version of `baseline_unbiased` and `optimal_baseline_min` per state,
then a tensorized total-variance decomposition `Var = E[Var(·|s)] + Var(E[·|s])`.
**Why now**: `optimal_baseline_min/strict` are already stated for an *arbitrary*
distribution `p` and arbitrary `R, s`; instantiating `p` as a conditional slice
is immediate, and `FactoredBellmanResidual.finSupNorm` shows the product-index
`Finset` machinery is in hand.
**If true**: it yields the first Lean proof that the value baseline is optimal,
the cornerstone of actor-critic.
**If false**: reveals that cross-state coupling (shared parameters) breaks
separable optimality — itself a sharp, publishable boundary.

### Direction 3: Natural gradient = preconditioning, with `F⁺ F` a projection
**Hypothesis**: Using the closed form `F = diag(π) − π πᵀ`, the Moore–Penrose
pseudoinverse `F⁺` satisfies `F⁺ F = I − (1/n)·𝟙𝟙ᵀ` on the tangent space
`{v : ⟨π·,v⟩ structure}`, so the natural gradient `F⁺ ∇J` is the Euclidean
gradient projected orthogonally to the all-ones direction (softmax gauge).
**Test**: Work in `Matrix (Fin n) (Fin n) ℝ`; prove `F = diag π − π ⬝ πᵀ`,
that `𝟙` is in `ker F` (since rows sum to zero — a direct corollary of
`softmaxScore_expect_zero`), and characterize `range F = 𝟙^⊥`. Then show the
natural-gradient update is gauge-invariant under `z ↦ z + c·𝟙`.
**Why now**: `fisherInfo_eq` and `fisherInfo_psd` give the matrix and its
nullspace direction for free; Mathlib has `Matrix.PosSemidef` and pseudoinverse
support to connect to.
**If true**: it formalizes the central claim of natural PG — that it is a
reparameterization-invariant steepest descent — at the matrix level.
**If false**: the nullspace/rank computation would expose a degeneracy (e.g. a
boundary policy with a zero coordinate) that the strict-positivity
`softmaxPolicy_pos` is supposed to rule out.

### Direction 4: Bellman γ-contraction ⇒ unique fixed point, geometric rate
**Hypothesis**: The discounted Bellman operator `T` on `(Fin S → ℝ)` with the
sup norm is a `γ`-contraction (`γ < 1`), hence `Tᵏ V → V⋆` with
`‖Tᵏ V − V⋆‖∞ ≤ γᵏ ‖V − V⋆‖∞`, and `V⋆` is unique.
**Test**: Equip `Fin S → ℝ` with `Pi.normedAddCommGroup` (sup norm), package the
contraction as Mathlib `ContractingWith γ T`, and read off `efixedPoint`,
`apriori_dist_iterate_efixedPoint_le`. The catalog's `bellmanOp_monotone`
(`Tropical/TropicalMoonshots.lean`) and `FactoredBellmanResidual`'s residual
decay are the warm-up; the missing piece is the metric contraction bound.
**Why now**: finite `S` makes `Fin S → ℝ` a complete normed space off the shelf,
and `ContractingWith` exists in Mathlib — only the `dist (T u) (T v) ≤ γ dist u v`
lemma must be supplied.
**If true**: it upgrades the catalog's *residual-decay* story to a *fixed-point
uniqueness + geometric-rate* story, enabling certified value iteration.
**If false** (e.g. for a non-expansive but non-contractive averaged operator):
it sharpens exactly which discounting is needed for uniqueness.

### Direction 5: Pinsker + softmax positivity ⇒ KL trust-region monotonicity
**Hypothesis**: For two softmax policies `π_old, π_new`, the KL
`KL(π_old‖π_new) = ∑_a π_old(a)(log π_old(a) − log π_new(a))` is well-defined and
nonnegative (Gibbs' inequality), and Pinsker `‖π_old − π_new‖₁² ≤ 2·KL` gives a
total-variation bound that, combined with an advantage bound, yields monotone
improvement under a tight KL constraint `δ ≤ ε²(1−γ)³/(8γ)`.
**Test**: First prove `KL ≥ 0` and `KL = 0 ↔ π_old = π_new` from
`softmaxPolicy_pos` (finiteness) and convexity of `x log x`; then formalize
Pinsker for finite distributions (sum-of-squares / `inner_mul_le_norm_mul_norm`).
**Why now**: `softmaxPolicy_pos` already discharges the "no `log 0`"
well-definedness obligation that blocks every KL formalization; the catalog's
`klBernoulli` and `max_entropy_is_uniform` show the convexity tooling is present.
**If true**: provides the analytic backbone for a TRPO monotonic-improvement
proof.
**If false**: a counterexample to the specific `δ` threshold would calibrate the
constant in the trust-region bound.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/MatrixGroupGeneration.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Generation Certificates for Matrix Groups

This file develops a certificate-based framework for proving generation properties
of linear groups over finite fields. The central concept is that algebraic
irreducibility of the characteristic polynomial of a linear map provides a
"generation certificate" — a structural condition that feeds into probabilistic
lower bounds on random generation.

## Main definitions

* `IsInvariantSubmodule φ W`: Predicate that submodule `W` is invariant under `φ`.
* `LinearGenerationCertificate`: A bundled certificate consisting of an endomorphism
  with bijective action and irreducible characteristic polynomial.
* `certificateDensity`: The density of certified elements in a finite group.
* `GenerationCertificateSystem`: Abstract typeclass for certificate-based generation.

## Main results

* `eq_bot_or_top_of_charpoly_irreducible`: If `φ` has irreducible characteristic
  polynomial, every `φ`-invariant submodule is `⊥` or `⊤`.
* `span_orbit_eq_top_of_irreducible`: The orbit of any nonzero vector under an
  endomorphism with irreducible charpoly spans the entire space.
* `irreducible_endomorphism_has_no_fixed_proper_projective_subspace`: No proper
  nonzero invariant subspace exists — the finite-geometry bridge theorem.
* `generation_lower_bound_of_certificate_system`: Abstract generation lower bound
  from certificate density.

## Strategy

The proof of the invariant subspace theorem proceeds via minimal polynomials:
1. Cayley-Hamilton gives `aeval φ (charpoly φ) = 0`.
2. If `charpoly φ` is irreducible, then `minpoly K φ = charpoly φ`.
3. For any invariant subspace `W`, the restriction `φ|_W` also satisfies the charpoly.
4. So `minpoly K (φ|_W)` divides the irreducible `charpoly φ`.
5. Degree considerations force `dim W ≥ dim V` or `W = ⊥`.

## References

* Dixon, J.D. (1969). The probability of generating the symmetric group.
* Huppert, B. (1967). Endliche Gruppen I. Springer.
* Neumann, P.M., Praeger, C.E. (1992). A recognition algorithm for special linear groups.
-/

import Mathlib

open Polynomial Submodule LinearMap

/-! ## Core Definitions -/

/-- A submodule `W` is invariant under an endomorphism `φ` if `φ` maps every element
of `W` back into `W`. This is the fundamental stability condition that connects
linear algebra to group theory: invariant subspaces are exactly the submodules
of the `K[X]`-module structure induced by `φ`. -/
def IsInvariantSubmodule {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    (φ : Module.End K V) (W : Submodule K V) : Prop :=
  ∀ w, w ∈ W → φ w ∈ W

/-- A linear generation certificate bundles an endomorphism with proofs of
invertibility and irreducibility of its characteristic polynomial. This is
the matrix-group analogue of a symmetric-group generation certificate:
it identifies elements whose algebraic structure guarantees usefulness
for group generation. -/
structure LinearGenerationCertificate
    (K : Type*) [Field K]
    (V : Type*) [AddCommGroup V] [Module K V]
    [Module.Free K V] [Module.Finite K V] where
  /-- The certified endomorphism -/
  φ : Module.End K V
  /-- The endomorphism is bijective (invertible) -/
  invertible : Function.Bijective φ
  /-- The characteristic polynomial is irreducible -/
  charpoly_irreducible : Irreducible φ.charpoly

/-- The density of elements satisfying a certificate predicate in a finite group.
This is the key quantitative input for generation lower bounds: a higher density
of certified elements yields stronger probabilistic guarantees. -/
noncomputable def certificateDensity
    {G : Type*} [Fintype G] [DecidableEq G]
    (C : G → Prop) [DecidablePred C] : ℚ :=
  (Fintype.card {g : G // C g} : ℚ) / Fintype.card G

/-- Abstract generation certificate system. This structure captures the
common pattern shared by symmetric group certificates and linear group
certificates: a predicate `Cert` on group elements such that certified
elements generate large subgroups. -/
structure GenerationCertificateSystem (G : Type*) [Group G] where
  /-- The certificate predicate -/
  Cert : G → Prop
  /-- Certificate implies the element generates a large subgroup when paired
      with a generic second element -/
  generates_with_complement : ∀ g : G, Cert g →
    ∀ H : Subgroup G, g ∈ H → H = ⊤ ∨ H.index ≤ 2

/-! ## Key Lemmas -/

section InvariantSubmodule

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
  [FiniteDimensional K V]

set_option linter.unusedSectionVars false in
/-- The subtype inclusion intertwines the restriction with the original map. -/
theorem restrict_subtype_commute (φ : Module.End K V) (W : Submodule K V)
    (hW : IsInvariantSubmodule φ W) :
    W.subtype ∘ₗ (φ.restrict (p := W) (q := W) hW) = φ ∘ₗ W.subtype := by
  ext ⟨x, hx⟩; simp [LinearMap.restrict, Submodule.subtype]

/-
If `φ` is annihilated by polynomial `p`, then the restriction of `φ` to any
invariant subspace is also annihilated by `p`. This is the key technical lemma
that transfers the Cayley-Hamilton theorem to invariant subspaces.
-/
set_option linter.unusedSectionVars false in
theorem aeval_restrict_eq_zero (φ : Module.End K V) (W : Submodule K V)
    (hW : IsInvariantSubmodule φ W) (p : K[X])
    (hp : Polynomial.aeval φ p = 0) :
    Polynomial.aeval (φ.restrict (p := W) (q := W) hW) p = 0 := by
  convert congr_arg ( fun f => f ∘ₗ W.subtype ) hp using 1;
  simp +decide [ Polynomial.aeval_eq_sum_range, LinearMap.ext_iff ];
  -- By definition of exponentiation for linear maps, we have that $(\varphi^x)(a) = \varphi^x(a)$ for any $a \in W$.
  have h_exp : ∀ x : ℕ, ∀ a : W, (restrict φ hW ^ x) a = (φ ^ x) a := by
    intro x a; induction x <;> simp_all +decide [ pow_succ' ] ;
  constructor <;> intro h a ha <;> specialize h a <;> simp_all +decide [ Subtype.ext_iff ]

/-
The minimal polynomial of a restriction divides the minimal polynomial of
the original endomorphism.
-/
theorem minpoly_restrict_dvd (φ : Module.End K V) (W : Submodule K V)
    (hW : IsInvariantSubmodule φ W) :
    minpoly K (φ.restrict (p := W) (q := W) hW) ∣ minpoly K φ := by
  convert minpoly.dvd K ( φ.restrict hW ) _;
  convert aeval_restrict_eq_zero φ W hW ( minpoly K φ ) ( minpoly.aeval K φ )

/-
If the characteristic polynomial of `φ` is irreducible, then the minimal
polynomial of `φ` equals its characteristic polynomial.
-/
theorem minpoly_eq_charpoly_of_irreducible
    (φ : Module.End K V) (hirr : Irreducible φ.charpoly) :
    minpoly K φ = φ.charpoly := by
  by_cases hV : Nontrivial V;
  · apply minpoly.eq_of_irreducible_of_monic hirr (LinearMap.aeval_self_charpoly φ) (LinearMap.charpoly_monic φ) |> Eq.symm;
  · -- If V is not nontrivial, then V must be the zero vector space.
    have h_zero : ∀ x : V, x = 0 := by
      exact fun x => Classical.not_not.1 fun hx => hV ⟨ x, 0, hx ⟩;
    simp_all +decide [ show φ = 0 from LinearMap.ext fun x => by simp +decide [ h_zero ] ];
    rcases n : Module.finrank K V with ( _ | _ | n ) <;> simp_all +decide [ pow_succ' ];
    · exact False.elim ( hV <| by exact ( Module.nontrivial_of_finrank_pos <| by linarith ) );
    · exact absurd ( hirr.isUnit_or_isUnit rfl ) ( by simp +decide [ Polynomial.isUnit_iff_degree_eq_zero ] )

end InvariantSubmodule

/-! ## Main Theorem: Irreducible Charpoly ⟹ No Nontrivial Invariant Subspaces -/

/-
**Theorem 1 (Irreducible action theorem).**
If `φ : V →ₗ[K] V` has irreducible characteristic polynomial, then every
`φ`-invariant submodule of `V` is either `⊥` or `⊤`.

This is the structural heart of the Singer-cycle certificate framework:
irreducibility of the characteristic polynomial — an algebraic condition
that can be checked computationally — implies that the linear action is
irreducible, a group-theoretic property with deep consequences for
generation and transitivity.
-/
theorem eq_bot_or_top_of_charpoly_irreducible
    {K V : 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Policy-Gradient Geometry & Variance Reduction

## Synthesis

This cycle built a self-contained, sorry-free Lean 4 formalization of the
*differential geometry of softmax policy gradients* and the *variance-reduction
theory of baselines*, living in `Catalog/MachineLearning/PolicyGradient/`
(`Foundations.lean` and `VarianceReduction.lean`). A reality check on the catalog
was decisive: the lemmas earlier concept notes *assumed* already existed
(`variance_shift_invariant`, `baseline_objective_quadratic`) do **not** exist
anywhere in the project — they were aspirational, as was the `PolicyGradient`
directory itself. So rather than "extend" phantom results, we built the missing
foundation from scratch, in the same finite-action spirit (`Fin n`, real sums,
an `expectVal` over a probability vector), so the next cycle has genuine objects
to build on. This complements the catalog's existing softmax/KL material
(`Catalog/MachineLearning/UltrametricKLDivergence.lean`, the Gaussian PAC-Bayes
KL in `Catalog/MachineLearning/Gaussian.lean`) and its information-geometry
threads, but is deliberately measure-theory-free.

The structural insight that emerged is that the entire first-order theory of
softmax PG is *purely algebraic over a finite probability vector*: the score
`ψ_j(a) = δ_{aj} − π_j`, the log-derivative identity `E_π[ψ_j] = 0`, the Fisher
closed form `F = diag(π) − π πᵀ`, its PSD-ness as a genuine variance
`vᵀ F v = E_π[(⟨v, ψ⟩)²]`, and the optimal-baseline quadratic
`M(b) = A b² − 2B b + C` are all finite-sum facts. The single reusable engine is
"expand the square/product, push constants through `Finset.mul_sum`, collapse
indicators with `Finset.sum_ite_eq'`, and reduce to the sum-to-one law". This is
exactly why the optimal-baseline results dropped out of one lemma
(`variance_reduction_amount`, the completed square `M(b) − M(b⋆) = A·(b − b⋆)²`):
minimization, uniqueness, and the strict inequality are corollaries, not new
work. The friction signal was the Fisher PSD identity, which required an explicit
triple-sum reordering (`Finset.sum_comm`) and a realization as
`E_π[(∑_j v_j ψ_j)²]` rather than a one-shot `simp`. That is precisely where the
next hard theorems live: the matrix-level facts want a clean `Finset`-indexed
quadratic-form API.

## Results Summary

All theorems are proved with `sorry = 0` (verified via the LSP against the
project's Mathlib).

- `softmaxPolicy_pos` — the softmax policy is strictly positive, so `log π` and
  KL divergences are everywhere finite (no `log 0`).
- `softmaxPolicy_sum_one` — softmax is a genuine probability distribution (needs
  a nonempty action set `[NeZero n]`; the unguarded version is *false* at
  `n = 0` and was disproved before fixing).
- `softmaxScore_expect_zero` — the log-derivative / REINFORCE identity
  `E_π[ψ_j] = 0`; the algebraic heart of every unbiased PG estimator.
- `fisherInfo_eq` — closed form `F_{jk} = π_j δ_{jk} − π_j π_k`.
- `fisherInfo_symm` — the Fisher matrix is symmetr
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
