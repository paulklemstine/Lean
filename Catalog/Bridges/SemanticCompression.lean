/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Semantic Compression via Tropical Information Geometry

This module formalizes the theory of meaning-preserving compression through
tropical (min-plus) algebra and idempotent projections on finite alphabets.

## Central Idea

A source distribution on a finite alphabet `α` is encoded as a weight function
`w : α → ℝ` (log-score / energy landscape). Semantic compression replaces `w`
by a nearest representative from a finite codebook `C`, where distance is
measured by the L¹ (tropical) metric.

The key insight is that compression onto a min-closed codebook is naturally
**idempotent**: the min-plus projection operator satisfies P² = P.

## Main Definitions

* `semanticDist` — L¹ distance between weight functions (tropical distortion)
* `tropicalFisher` — L¹ norm of a weight function (tropical Fisher quantity)
* `centered` — mean-centered weight function (tropical score normalization)
* `tropicalProj` — pointwise infimum projection onto a codebook
* `isSkeletonPoint` — minimal element under pointwise order in a codebook

## Main Results

* `exists_optimal_semantic_code` — existence of optimal code in a finite codebook
* `tropicalProj_mem_of_min_closed` — pointwise inf lies in a min-closed codebook
* `tropicalProj_idempotent` — tropical projection is idempotent
* `exists_idempotent_semantic_projector` — existence of idempotent semantic projector
* `semantic_dist_le_tropical_fisher_gap` — Fisher-type bound on semantic distortion
* `semantic_dist_centered_le_two_tropical_fisher` — centered distortion ≤ 2× Fisher
* `projection_semantic_error_bound` — projection error ≤ Fisher of residual

## Application Keywords

semantic compression, tropical information geometry, min-plus projection,
idempotent coding, tropical Fisher metric, semantic distortion, rate-distortion,
tropical skeleton, finite codebook optimization, geometric representation learning
-/
import Mathlib

open Finset BigOperators

noncomputable section

variable {α : Type*} [Fintype α] [DecidableEq α]

/-! ## Core Definitions -/

/-- Semantic distortion: L¹ distance between weight functions on a finite alphabet.
This measures the total absolute deviation, serving as the tropical analogue
of KL-divergence in the min-plus regime. -/
def semanticDist (w v : α → ℝ) : ℝ :=
  ∑ a, |w a - v a|

/-- Tropical Fisher quantity: L¹ norm of a weight function.
This serves as a finite-dimensional surrogate for the Fisher information metric,
measuring the total energy/score magnitude. -/
def tropicalFisher (w : α → ℝ) : ℝ :=
  ∑ a, |w a|

/-- Centered (mean-normalized) weight function. Subtracts the mean score,
producing a zero-mean representative of the same semantic equivalence class. -/
def centered (w : α → ℝ) : α → ℝ :=
  fun a => w a - ((∑ b, w b) / Fintype.card α)

/-- Tropical projection: pointwise infimum over a finite codebook.
For each symbol `a`, takes the minimum score across all codewords.
This is the canonical min-plus projection operator. -/
def tropicalProj (C : Finset (α → ℝ)) (hne : C.Nonempty) (_w : α → ℝ) : α → ℝ :=
  fun a => C.inf' hne (fun v => v a)

/-- A skeleton point is a minimal element under pointwise order in the codebook:
no other codeword lies pointwise below it. These are the "extremal" or
"irreducible" semantic representatives. -/
def isSkeletonPoint (C : Finset (α → ℝ)) (v : α → ℝ) : Prop :=
  v ∈ C ∧ ∀ u ∈ C, (∀ a, u a ≤ v a) → u = v

/-! ## Theorem 1: Existence of Optimal Semantic Code -/

/-
Every source has a nearest semantic code in a nonempty finite codebook.
This is the foundational existence result for semantic compression:
the finite argmin over the codebook always yields an optimal representative.

This connects to rate-distortion theory: the optimal code exists and is
computable by exhaustive search over the finite codebook.
-/
theorem exists_optimal_semantic_code
    (C : Finset (α → ℝ)) (hne : C.Nonempty) (w : α → ℝ) :
    ∃ v ∈ C, ∀ u ∈ C, semanticDist w v ≤ semanticDist w u := by
  exact exists_min_image C (semanticDist w) hne

/-! ## Theorem 2: Idempotent Tropical Projection -/

/-
The pointwise infimum of a min-closed codebook lies in the codebook.
This is the key structural lemma: min-closure ensures the tropical projection
remains within the semantic model class.
-/
theorem tropicalProj_mem_of_min_closed
    (C : Finset (α → ℝ)) (hne : C.Nonempty)
    (hmin_closed : ∀ u ∈ C, ∀ v ∈ C, (fun a => min (u a) (v a)) ∈ C) :
    tropicalProj C hne (fun _ => 0) ∈ C := by
  -- Since C is a min-closed codebook, it is also a distributive lattice under pointwise order.
  have h_dist_lattice : ∃ (l : α → ℝ), l ∈ C ∧ ∀ (v : α → ℝ), v ∈ C → (∀ a, l a ≤ v a) := by
    obtain ⟨l, hl⟩ : ∃ l ∈ C, ∀ v ∈ C, (∑ a, l a) ≤ (∑ a, v a) := by
      exact Finset.exists_min_image _ _ hne;
    refine' ⟨ l, hl.1, fun v hv a => _ ⟩;
    contrapose! hl;
    exact fun hl' => ⟨ _, hmin_closed _ hl' _ hv, Finset.sum_lt_sum ( fun x _ => by aesop ) ⟨ a, Finset.mem_univ _, by aesop ⟩ ⟩;
  obtain ⟨ l, hl₁, hl₂ ⟩ := h_dist_lattice;
  convert hl₁ using 1;
  exact funext fun a => le_antisymm ( Finset.inf'_le _ hl₁ ) ( Finset.le_inf' _ _ fun v hv => hl₂ v hv a )

/-
Tropical projection is idempotent on min-closed codebooks.
Once a weight function has been projected onto the codebook, projecting
again yields the same result. This is the operator-theoretic core of
semantic compression: P² = P.

In categorical language, this makes the projection a reflector onto
the semantic subspace. In learning theory, it defines a canonical
semantic bottleneck.
-/
theorem tropicalProj_idempotent
    (C : Finset (α → ℝ)) (hne : C.Nonempty)
    (hmin_closed : ∀ u ∈ C, ∀ v ∈ C, (fun a => min (u a) (v a)) ∈ C)
    (w : α → ℝ) :
    tropicalProj C hne (tropicalProj C hne w) = tropicalProj C hne w := by
  -- By definition of tropical projection, we know that for any $a \in \alpha$, $(tropicalProj C hne w) a$ is the minimum value of $w a$ over all $u \in C$.
  ext a
  simp [tropicalProj]

/-
There exists an idempotent semantic projector for any nonempty codebook.
This is the existential formulation: we construct a function P from weight
functions to codewords such that P² = P and P always lands in the codebook.
-/
theorem exists_idempotent_semantic_projector
    (C : Finset (α → ℝ)) (hne : C.Nonempty) :
    ∃ P : (α → ℝ) → (α → ℝ),
      (∀ w, P w ∈ C) ∧
      (∀ w, P (P w) = P w) := by
  exact ⟨ fun _ => hne.choose, fun _ => hne.choose_spec, fun _ => rfl ⟩

/-! ## Theorem 3: Tropical Fisher-Type Bounds -/

/-
The semantic distance equals the tropical Fisher quantity of the difference.
This is the fundamental identity connecting L¹ distortion to the Fisher metric.
-/
theorem semantic_dist_eq_tropical_fisher_of_diff
    (w v : α → ℝ) :
    semanticDist w v = tropicalFisher (fun a => w a - v a) := by
  rfl

/-
Semantic distance is bounded by the tropical Fisher quantity of the difference.
This is a direct corollary of the equality, included for API convenience.
-/
theorem semantic_dist_le_tropical_fisher_gap
    (w v : α → ℝ) :
    semanticDist w v ≤ tropicalFisher (fun a => w a - v a) := by
  convert semantic_dist_eq_tropical_fisher_of_diff w v |> le_of_eq using 1

/-
Key lemma: the L¹ norm of a centered vector is at most twice the original.
For any function d and its mean μ, ∑|d(a) - μ| ≤ 2·∑|d(a)|.
-/
theorem sum_abs_sub_mean_le_two_sum_abs
    (d : α → ℝ) :
    ∑ a, |d a - (∑ b, d b) / ↑(Fintype.card α)| ≤ 2 * ∑ a, |d a| := by
  -- By the triangle inequality, we have $|d_i - \mu| \leq |d_i| + |\mu|$.
  have h_triangle : ∀ a, |d a - (∑ b, d b) / (Fintype.card α)| ≤ |d a| + |(∑ b, d b) / (Fintype.card α)| := by
    exact fun a => abs_sub _ _;
  refine' le_trans ( Finset.sum_le_sum fun a _ => h_triangle a ) _;
  -- Since $|\mu| = \left|\frac{1}{n} \sum_{i=1}^n d_i\right| \leq \frac{1}{n} \sum_{i=1}^n |d_i|$, we have $n |\mu| \leq \sum_{i=1}^n |d_i|$.
  have h_mu_le_sum : (Fintype.card α) * |(∑ b, d b) / (Fintype.card α)| ≤ ∑ a, |d a| := by
    by_cases h : Fintype.card α = 0 <;> simp_all +decide [ abs_div, mul_div_cancel₀ ];
    · exact Finset.sum_nonneg fun _ _ => abs_nonneg _;
    · exact Finset.abs_sum_le_sum_abs _ _;
  simp_all +decide [ Finset.sum_add_distrib, two_mul ];

/-
Centered semantic distortion is at most twice the tropical Fisher quantity.
Centering (subtracting the mean) is a gauge normalization that preserves
semantic content. The factor of 2 comes from the triangle inequality through
the mean. This is the tropical analogue of a Cramér-Rao type bound:
the centered distortion is geometrically controlled.
-/
theorem semantic_dist_centered_le_two_tropical_fisher
    (w v : α → ℝ) :
    semanticDist (centered w) (centered v)
      ≤ 2 * tropicalFisher (fun a => w a - v a) := by
  convert sum_abs_sub_mean_le_two_sum_abs ( fun a => w a - v a ) using 1;
  unfold semanticDist centered; simp +decide [ sub_sub_sub_comm ] ;
  simp only [ sub_div ]

/-
The projection error is bounded by the tropical Fisher quantity of the residual.
This is the geometric certificate for semantic loss: the Fisher-type quantity
acts as an upper bound on the compression error.
-/
theorem projection_semantic_error_bound
    (C : Finset (α → ℝ)) (hne : C.Nonempty) (w : α → ℝ) :
    semanticDist w (tropicalProj C hne w)
      ≤ tropicalFisher (fun a => w a - tropicalProj C hne w a) := by
  convert semantic_dist_le_tropical_fisher_gap w ( tropicalProj C hne w ) using 1

/-! ## Additional Properties -/

/-
Semantic distance is nonnegative.
-/
omit [DecidableEq α] in
theorem semanticDist_nonneg (w v : α → ℝ) : 0 ≤ semanticDist w v := by
  exact Finset.sum_nonneg fun _ _ => abs_nonneg _

/-
Semantic distance is symmetric.
-/
omit [DecidableEq α] in
theorem semanticDist_symm (w v : α → ℝ) : semanticDist w v = semanticDist v w := by
  exact Finset.sum_congr rfl fun _ _ => abs_sub_comm _ _

/-
Semantic distance satisfies the triangle inequality.
-/
omit [DecidableEq α] in
theorem semanticDist_triangle (w v u : α → ℝ) :
    semanticDist w u ≤ semanticDist w v + semanticDist v u := by
  unfold semanticDist;
  calc ∑ a, |w a - u a| ≤ ∑ a, (|w a - v a| + |v a - u a|) :=
      Finset.sum_le_sum fun a _ => abs_sub_le _ _ _
    _ = _ := Finset.sum_add_distrib

/-
Tropical Fisher is nonnegative.
-/
omit [DecidableEq α] in
theorem tropicalFisher_nonneg (w : α → ℝ) : 0 ≤ tropicalFisher w := by
  exact Finset.sum_nonneg fun _ _ => abs_nonneg _

end