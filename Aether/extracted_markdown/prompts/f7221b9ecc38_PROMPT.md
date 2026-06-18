
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

**Title**: Close Proofs: This cycle's artifact is `Catalog/MachineLearning/NTKSpectral.lean`. I
**Domain**: Novelty
**Mathematical framing**: Cycle ee125918 (Q=0.424) proved 1280 theorems in Novelty but left 3 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions: NTK Spectral Convergence

This cycle's artifact is `Catalog/MachineLearning/NTKSpectral.lean`. It is self-contained:
because this was a cold start (no prior `NTKCore` existed in t
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
# Future Directions: NTK Spectral Convergence

## Synthesis

This cycle delivered `Catalog/MachineLearning/NTKSpectral.lean` from a cold start
(no prior `NTKCore` existed in the catalog). The file builds the spectral theory
of the Neural Tangent Kernel (NTK) that controls gradient-descent training in the
lazy / infinite-width regime, and it does so as a *single coherent chain*:

1. **Spectrum exists and is nonnegative.** The NTK Gram matrix `Θ = Jᵀ J` is
   positive semidefinite (`ntkGram_posSemidef`), and its quadratic form is exactly
   the squared feature-space norm `xᵀ Θ x = ‖J x‖²` (`ntk_quadratic_form`,
   `ntk_quadratic_form_nonneg`). No training mode is ever amplified.
2. **Dynamics diagonalize into scalar modes.** In the eigenbasis, the residual
   decouples into modes `c_{k+1} = (1 - η λ) c_k` with closed form
   `c k = (1 - η λ)ᵏ c₀` (`ntk_mode_decay`).
3. **Condition number sets the rate.** At the optimal learning rate
   `η* = 2/(λ_min+λ_max)`, every mode contracts by the condition-number factor
   `(λ_max - λ_min)/(λ_max + λ_min) = (κ-1)/(κ+1)` (`optimal_lr_contraction`).
4. **Convergence follows.** Contraction yields the explicit bound
   `|c k| ≤ ρᵏ |c₀|` (`geometric_convergence`) and, for `ρ < 1`, convergence to
   zero (`contraction_tendsto_zero`), assembled into the capstone
   `ntk_optimal_tendsto_zero`: a positive-definite NTK spectrum trained at the
   optimal rate drives every residual mode to `0`.

This connects two catalog domains that previously sat apart: the *linear-algebra*
machinery of positive-semidefinite Gram matrices (cf. spectral / self-adjoint
work such as `SpectralSelfAdjoint`) and the *optimization-dynamics* results on
network training (cf. `ResNetLipschitz`, `Accelerated`, `AsymptoticRate`). The
bridge is the observation that the convergence rate is a purely spectral
quantity — the kernel's condition number.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `ntkGram_posSemidef` | `Jᵀ J` is PSD | proved |
| `ntk_quadratic_form` | `xᵀ(JᵀJ)x = (Jx)·(Jx)` | proved |
| `ntk_quadratic_form_nonneg` | `0 ≤ xᵀ(JᵀJ)x` | proved |
| `ntk_mode_decay` | `c k = (1-ηλ)ᵏ c₀` | proved |
| `optimal_lr_contraction` | `|1-η*λ| ≤ (κ-1)/(κ+1)` | proved |
| `geometric_convergence` | `|c k| ≤ ρᵏ|c₀|` | proved |
| `contraction_tendsto_zero` | `ρ<1 ⇒ c→0` | proved |
| `ntk_optimal_tendsto_zero` | PD spectrum + optimal LR ⇒ `c→0` | proved |

All results are `sorry`-free and depend only on `propext`, `Classical.choice`,
and `Quot.sound`.

## Bold, Falsifiable Research Directions

### 1. Full matrix recurrence convergence (not just per-mode)

Lift the scalar capstone to the genuine matrix update
`r_{k+1} = (I - η Θ) r_k` and prove `‖r_k‖ ≤ ρᵏ ‖r_0‖` directly from the
operator norm of `I - η Θ`, where `ρ = (κ-1)/(κ+1)`. The key insight is that
`optimal_lr_contraction` is exactly the eigenvalue-wise bound on the symmetric
operator `I - η* Θ`, so its operator norm equals the per-mode contraction —
spectral-radius equals 
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
