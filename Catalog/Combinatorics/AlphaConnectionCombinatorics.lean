import Mathlib
import Combinatorics.AlphaConnectionCanonical

/-!
# Combinatorics of the Amari–Chentsov tensor

Building on `Combinatorics/AlphaConnectionCanonical.lean` (where the
Amari–Chentsov cubic tensor of a finite exponential family is identified with the
derivative of the Fisher metric) and on the catalog's α-connection coefficients,
this file computes and constrains the cubic tensor by *combinatorial* means:

* `mean_odd_eq_zero`, `amariCubic_eq_zero_of_involution` — a sign-reversing
  involution of the sample space forces every third cumulant to vanish, so at the
  symmetric point the whole α-pencil collapses: every α-connection is flat there.
* `cum3_binary_feature` — the **skewness law of a binary feature**:
  `C(f,f,f) = p (1 - p) (1 - 2 p)`, with `p` the feature's mean.  Hence in a
  two-valued (Bernoulli-type) model the α-connection coefficient vanishes exactly
  when `α = 1` or the feature is unbiased.
* `mean_mul_of_product`, `cum3_mixed_product_eq_zero` — **independence
  annihilates mixed cumulants**: for a product model the Amari–Chentsov tensor is
  block diagonal, so the α-connections of independent models split.
* exact small-case computations for the symmetric two-point (Rademacher) family.
-/

noncomputable section

open Finset BigOperators AlphaConnectionCanonical

namespace AlphaConnectionCombinatorics

variable {S : Type*} [Fintype S] {d : ℕ}

/-! ## 1. Sign-reversing involutions kill the cubic tensor -/

section Involution

variable [Nonempty S] {w : S → ℝ} {T : S → Fin d → ℝ}

omit [Nonempty S] in
/-- Under a weight-preserving symmetry of the sample space, the expectation at the
origin of natural coordinates of any odd observable vanishes. -/
lemma mean_odd_eq_zero (σ : Equiv.Perm S)
    (hσw : ∀ x, w (σ x) = w x) {f : S → ℝ} (hf : ∀ x, f (σ x) = - f x) :
    mean w T (0 : Fin d → ℝ) f = 0 := by
  have hscore : ∀ x : S, score (0 : Fin d → ℝ) T x = 0 := by
    intro x; simp [score]
  have hA : unnorm w T (0 : Fin d → ℝ) f = ∑ x, w x * f x := by
    unfold unnorm
    exact Finset.sum_congr rfl fun x _ => by rw [hscore x]; simp
  have hswap : ∑ x, w x * f x = ∑ x, w (σ x) * f (σ x) :=
    (Equiv.sum_comp σ (fun x => w x * f x)).symm
  have hneg : ∑ x, w (σ x) * f (σ x) = -∑ x, w x * f x := by
    rw [← Finset.sum_neg_distrib]
    exact Finset.sum_congr rfl fun x _ => by rw [hσw x, hf x]; ring
  have : ∑ x, w x * f x = 0 := by
    have := hswap.trans hneg
    linarith
  unfold mean
  rw [hA, this, zero_div]

/-- **Symmetry collapses the α-pencil.**  If a sign-reversing involution preserves
the weights, then at the origin of natural coordinates the Amari–Chentsov tensor
vanishes identically. -/
theorem amariCubic_eq_zero_of_involution (hw : ∀ x, 0 < w x) (σ : Equiv.Perm S)
    (hσw : ∀ x, w (σ x) = w x) (hσT : ∀ x i, T (σ x) i = - T x i) (i j k : Fin d) :
    amariCubic w T (0 : Fin d → ℝ) i j k = 0 := by
  have hmean : ∀ l : Fin d, mean w T (0 : Fin d → ℝ) (fun x => T x l) = 0 := by
    intro l
    exact mean_odd_eq_zero σ hσw (fun x => hσT x l)
  have htriple : mean w T (0 : Fin d → ℝ) (fun x => T x i * T x j * T x k) = 0 := by
    refine mean_odd_eq_zero σ hσw ?_
    intro x
    rw [hσT x i, hσT x j, hσT x k]; ring
  unfold amariCubic
  rw [cum3_expand hw]
  rw [hmean i, hmean j, hmean k, htriple]
  ring

open InformationGeometryContrarian in
/-- At a symmetric point every canonical α-connection is e-flat simultaneously:
the Levi–Civita, exponential and mixture connections all coincide there. -/
theorem all_alpha_flat_of_involution (hw : ∀ x, 0 < w x) (σ : Equiv.Perm S)
    (hσw : ∀ x, w (σ x) = w x) (hσT : ∀ x i, T (σ x) i = - T x i)
    (α : ℝ) (i j k : Fin d) :
    naturalAlphaChristoffel α (amariCubic w T (0 : Fin d → ℝ)) i j k = 0 := by
  unfold naturalAlphaChristoffel
  rw [amariCubic_eq_zero_of_involution hw σ hσw hσT i j k, mul_zero]

end Involution

/-! ## 2. The skewness law of a binary feature -/

section Binary

variable [Nonempty S] {w : S → ℝ} {T : S → Fin d → ℝ}

omit [Nonempty S] in
/-- Variance of a `{0,1}`-valued feature. -/
lemma covar_binary_feature (θ : Fin d → ℝ) {f : S → ℝ}
    (hf : ∀ x, f x * f x = f x) :
    covar w T θ f f
      = mean w T θ f * (1 - mean w T θ f) := by
  have hfun : (fun x => f x * f x) = f := funext hf
  unfold covar
  rw [hfun]
  ring

/-- **Skewness law.**  The third cumulant of a `{0,1}`-valued feature is
`p (1 - p) (1 - 2 p)`, where `p` is its mean.  This is the exact combinatorial
content of the Amari–Chentsov tensor of a Bernoulli-type family. -/
theorem cum3_binary_feature (hw : ∀ x, 0 < w x) (θ : Fin d → ℝ) {f : S → ℝ}
    (hf : ∀ x, f x * f x = f x) :
    cum3 w T θ f f f
      = mean w T θ f * (1 - mean w T θ f) * (1 - 2 * mean w T θ f) := by
  have hfun2 : (fun x => f x * f x) = f := funext hf
  have hfun3 : (fun x => f x * f x * f x) = f := by
    funext x; rw [hf x, hf x]
  rw [cum3_expand hw, hfun2, hfun3]
  ring

/-- In a Bernoulli-type family with a nondegenerate binary feature the cubic
tensor vanishes exactly at the unbiased point `p = 1/2`. -/
theorem cum3_binary_eq_zero_iff (hw : ∀ x, 0 < w x) (θ : Fin d → ℝ) {f : S → ℝ}
    (hf : ∀ x, f x * f x = f x) (h0 : mean w T θ f ≠ 0)
    (h1 : mean w T θ f ≠ 1) :
    cum3 w T θ f f f = 0 ↔ mean w T θ f = 1 / 2 := by
  rw [cum3_binary_feature hw θ hf]
  constructor
  · intro h
    rcases mul_eq_zero.mp h with h' | h'
    · rcases mul_eq_zero.mp h' with h'' | h''
      · exact absurd h'' h0
      · exact absurd (by linarith : mean w T θ f = 1) h1
    · linarith
  · intro h; rw [h]; ring

open InformationGeometryContrarian in
/-- For a binary feature, the natural α-coefficient vanishes precisely at the
e-connection or at the unbiased point — a sharp dichotomy between the
*geometric* degeneracy `α = 1` and the *statistical* degeneracy `p = 1/2`. -/
theorem binary_alpha_coefficient_zero_iff (hw : ∀ x, 0 < w x) (θ : Fin d → ℝ)
    {f : S → ℝ} (hf : ∀ x, f x * f x = f x) (h0 : mean w T θ f ≠ 0)
    (h1 : mean w T θ f ≠ 1) (α : ℝ) :
    ((1 - α) / 2) * cum3 w T θ f f f = 0 ↔ α = 1 ∨ mean w T θ f = 1 / 2 := by
  constructor
  · intro h
    rcases mul_eq_zero.mp h with h' | h'
    · left
      have := (div_eq_zero_iff.mp h').resolve_right (by norm_num : (2:ℝ) ≠ 0)
      linarith [sub_eq_zero.mp this]
    · right
      exact (cum3_binary_eq_zero_iff hw θ hf h0 h1).mp h'
  · rintro (rfl | h)
    · norm_num
    · rw [(cum3_binary_eq_zero_iff hw θ hf h0 h1).mpr h, mul_zero]

end Binary

/-! ## 3. Independence annihilates mixed cumulants -/

section Product

variable {S₁ S₂ : Type*} [Fintype S₁] [Fintype S₂] [Nonempty S₁] [Nonempty S₂]
variable {w : S₁ × S₂ → ℝ} {T : S₁ × S₂ → Fin d → ℝ} {θ : Fin d → ℝ}
variable {W₁ : S₁ → ℝ} {W₂ : S₂ → ℝ}

omit [Nonempty S₁] [Nonempty S₂] in
/-- Unnormalised expectations factorise over a product family. -/
lemma unnorm_product (hfac : ∀ z : S₁ × S₂,
      w z * Real.exp (score θ T z) = W₁ z.1 * W₂ z.2)
    (f : S₁ → ℝ) (g : S₂ → ℝ) :
    unnorm w T θ (fun z => f z.1 * g z.2)
      = (∑ x, W₁ x * f x) * (∑ y, W₂ y * g y) := by
  unfold unnorm
  rw [Fintype.sum_prod_type, Finset.sum_mul_sum]
  refine Finset.sum_congr rfl fun x _ => Finset.sum_congr rfl fun y _ => ?_
  rw [hfac (x, y)]
  ring

/-- Expectations of product observables factorise: this is independence. -/
theorem mean_mul_of_product (hw : ∀ z, 0 < w z)
    (hfac : ∀ z : S₁ × S₂, w z * Real.exp (score θ T z) = W₁ z.1 * W₂ z.2)
    (f : S₁ → ℝ) (g : S₂ → ℝ) :
    mean w T θ (fun z => f z.1 * g z.2)
      = mean w T θ (fun z => f z.1) * mean w T θ (fun z => g z.2) := by
  have hZ : partitionFn w T θ ≠ 0 := partitionFn_ne_zero hw T θ
  have hZfac : partitionFn w T θ = (∑ x, W₁ x) * (∑ y, W₂ y) := by
    have := unnorm_product hfac (fun _ => 1) (fun _ => 1)
    simpa [partitionFn] using this
  have hA1 : (∑ x, W₁ x) ≠ 0 := by
    intro h; apply hZ; rw [hZfac, h, zero_mul]
  have hA2 : (∑ y, W₂ y) ≠ 0 := by
    intro h; apply hZ; rw [hZfac, h, mul_zero]
  have hfg : unnorm w T θ (fun z => f z.1 * g z.2)
      = (∑ x, W₁ x * f x) * (∑ y, W₂ y * g y) := unnorm_product hfac f g
  have hf : unnorm w T θ (fun z => f z.1)
      = (∑ x, W₁ x * f x) * (∑ y, W₂ y) := by
    have := unnorm_product hfac f (fun _ => 1)
    simpa using this
  have hg : unnorm w T θ (fun z => g z.2)
      = (∑ x, W₁ x) * (∑ y, W₂ y * g y) := by
    have := unnorm_product hfac (fun _ => 1) g
    simpa using this
  unfold mean
  rw [hfg, hf, hg, hZfac]
  field_simp

/-- **Block diagonality of the Amari–Chentsov tensor.**  In a product model, any
third cumulant mixing the two independent factors vanishes.  Consequently the
α-connections of a product of statistical models are the direct sums of the
factor connections. -/
theorem cum3_mixed_product_eq_zero (hw : ∀ z, 0 < w z)
    (hfac : ∀ z : S₁ × S₂, w z * Real.exp (score θ T z) = W₁ z.1 * W₂ z.2)
    (f g : S₁ → ℝ) (h : S₂ → ℝ) :
    cum3 w T θ (fun z => f z.1) (fun z => g z.1) (fun z => h z.2) = 0 := by
  have hfg : mean w T θ (fun z => f z.1 * g z.1 * h z.2)
      = mean w T θ (fun z => f z.1 * g z.1) * mean w T θ (fun z => h z.2) := by
    have := mean_mul_of_product hw hfac (fun x => f x * g x) h
    simpa using this
  have hfh : mean w T θ (fun z => f z.1 * h z.2)
      = mean w T θ (fun z => f z.1) * mean w T θ (fun z => h z.2) :=
    mean_mul_of_product hw hfac f h
  have hgh : mean w T θ (fun z => g z.1 * h z.2)
      = mean w T θ (fun z => g z.1) * mean w T θ (fun z => h z.2) :=
    mean_mul_of_product hw hfac g h
  rw [cum3_expand hw, hfg, hfh, hgh]
  ring

end Product

/-! ## 4. Exact computations: the symmetric two-point family -/

/-- The Rademacher feature `T(0) = -1`, `T(1) = +1` on a two-point sample space. -/
def rademacherFeature : Fin 2 → Fin 1 → ℝ
  | 0, _ => -1
  | 1, _ => 1

/-- Uniform base weights. -/
def uniformWeight : Fin 2 → ℝ := fun _ => 1

lemma uniformWeight_pos : ∀ x, 0 < uniformWeight x := by
  intro x; norm_num [uniformWeight]

/-- The sign-flip involution of the two-point space. -/
def flip : Equiv.Perm (Fin 2) := Equiv.swap 0 1

lemma flip_weight : ∀ x, uniformWeight (flip x) = uniformWeight x := by
  intro x; rfl

lemma flip_feature : ∀ x i, rademacherFeature (flip x) i = - rademacherFeature x i := by
  intro x i
  fin_cases x <;>
    simp [flip, rademacherFeature, Equiv.swap_apply_left, Equiv.swap_apply_right]

/-- Exact computation: the symmetric two-point family has unit Fisher
information at the origin. -/
theorem rademacher_fisher_at_zero :
    fisher uniformWeight rademacherFeature (0 : Fin 1 → ℝ) 0 0 = 1 := by
  norm_num [fisher, covar, mean, unnorm, partitionFn, score, uniformWeight,
    rademacherFeature, Fin.sum_univ_two, Fin.sum_univ_one]

/-- Exact computation: its Amari–Chentsov tensor vanishes at the origin, so the
entire α-pencil is flat there. -/
theorem rademacher_cubic_at_zero :
    amariCubic uniformWeight rademacherFeature (0 : Fin 1 → ℝ) 0 0 0 = 0 :=
  amariCubic_eq_zero_of_involution uniformWeight_pos flip flip_weight
    flip_feature 0 0 0

open InformationGeometryContrarian in
/-- Consequently, in the symmetric two-point family *every* α-connection is flat
at the origin — in sharp contrast with the asymmetric Bernoulli family of the
catalog, where flatness happens only at `α = 1`. -/
theorem rademacher_all_alpha_flat (α : ℝ) :
    naturalAlphaChristoffel α
      (amariCubic uniformWeight rademacherFeature (0 : Fin 1 → ℝ)) 0 0 0 = 0 :=
  all_alpha_flat_of_involution uniformWeight_pos flip flip_weight flip_feature α 0 0 0

end AlphaConnectionCombinatorics