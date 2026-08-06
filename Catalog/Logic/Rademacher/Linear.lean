/-
# The margin bound: Rademacher complexity of linear (and kernel) classes

For a sample `x₁, …, xₙ` of vectors of norm at most `B` in a real inner product space
and the class of linear functionals `x ↦ ⟪w, x⟫` with `‖w‖ ≤ W`, the empirical
Rademacher complexity is at most `W * B / √n`.

The bound is *dimension free*: it does not refer to the dimension of the ambient
space at all, which is exactly what makes it applicable to kernel methods, where the
feature space may be infinite dimensional.  The kernel version is recorded as
`rad_kernelClass_le`: only the diagonal `K x x = ⟪φ x, φ x⟫` of the kernel enters.

The proof is the classical one:

* for a fixed sign pattern `σ`, Cauchy–Schwarz in the feature space gives
  `sup_w (1/n) ∑ σᵢ ⟪w, xᵢ⟫ ≤ (W/n) ‖∑ σᵢ • xᵢ‖`;
* averaging over `σ` and using Cauchy–Schwarz again (in the `2ⁿ`-dimensional space of
  sign patterns) replaces the average of `‖∑ σᵢ • xᵢ‖` by the square root of its
  second moment;
* the second moment is exactly `∑ ‖xᵢ‖²`, because the off-diagonal terms
  `∑_σ σᵢσⱼ` vanish.

This file is self-contained.
-/
import Mathlib

namespace RademacherLinear

open Finset RealInnerProductSpace

variable {n : ℕ}

/-- The sign vector attached to a boolean vector: `true ↦ 1`, `false ↦ -1`. -/
def sgn (ε : Fin n → Bool) (i : Fin n) : ℝ := if ε i then 1 else -1

/-- The linear functional `v ↦ (1/n) ∑ σ i * v i` associated with a sign vector. -/
noncomputable def signAvg (ε : Fin n → Bool) (v : Fin n → ℝ) : ℝ :=
  (1 / (n : ℝ)) * ∑ i, sgn ε i * v i

/-- The empirical Rademacher complexity of a class `F` of vectors. -/
noncomputable def rad (F : Set (Fin n → ℝ)) : ℝ :=
  (∑ ε : Fin n → Bool, sSup (signAvg ε '' F)) / 2 ^ n

lemma sgn_sq (ε : Fin n → Bool) (i : Fin n) : sgn ε i * sgn ε i = 1 := by
  simp only [sgn]; rcases Bool.eq_false_or_eq_true (ε i) with h | h <;> simp [h]

/-- Flipping the `i`-th sign only is a fixed-point-free involution of sign patterns,
hence the correlation `∑_σ σᵢ σⱼ` vanishes for `i ≠ j`. -/
lemma sum_sgn_mul_sgn {i j : Fin n} (hij : i ≠ j) :
    ∑ ε : Fin n → Bool, sgn ε i * sgn ε j = 0 := by
  classical
  have hinv : Function.Involutive (fun ε : Fin n → Bool => Function.update ε i (!(ε i))) := by
    intro ε
    funext k
    by_cases hk : k = i <;> simp [hk, Function.update_apply]
  have key : ∑ ε : Fin n → Bool, sgn (Function.update ε i (!(ε i))) i *
      sgn (Function.update ε i (!(ε i))) j
      = ∑ ε : Fin n → Bool, sgn ε i * sgn ε j :=
    Equiv.sum_comp hinv.toPerm (fun ε => sgn ε i * sgn ε j)
  have hflip : ∀ ε : Fin n → Bool,
      sgn (Function.update ε i (!(ε i))) i * sgn (Function.update ε i (!(ε i))) j
        = -(sgn ε i * sgn ε j) := by
    intro ε
    have h1 : sgn (Function.update ε i (!(ε i))) i = -sgn ε i := by
      simp only [sgn, Function.update_self]
      rcases Bool.eq_false_or_eq_true (ε i) with h | h <;> simp [h]
    have h2 : sgn (Function.update ε i (!(ε i))) j = sgn ε j := by
      simp only [sgn, Function.update_of_ne (Ne.symm hij)]
    rw [h1, h2]; ring
  simp only [hflip, Finset.sum_neg_distrib] at key
  linarith

/-- The second moment of `‖∑ σᵢ • xᵢ‖` over the uniform sign pattern:
`𝔼_σ ‖∑ σᵢ • xᵢ‖² = ∑ ‖xᵢ‖²`, written without dividing by `2ⁿ`. -/
lemma sum_norm_sq_signed {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (x : Fin n → E) :
    ∑ ε : Fin n → Bool, ‖∑ i, sgn ε i • x i‖ ^ 2 = 2 ^ n * ∑ i, ‖x i‖ ^ 2 := by
  classical
  have hexp : ∀ ε : Fin n → Bool, ‖∑ i, sgn ε i • x i‖ ^ 2
      = ∑ i, ∑ j, sgn ε i * sgn ε j * ⟪x i, x j⟫ := by
    intro ε
    rw [← real_inner_self_eq_norm_sq, sum_inner]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [inner_sum]
    refine Finset.sum_congr rfl fun j _ => ?_
    rw [real_inner_smul_left, real_inner_smul_right]
    ring
  simp only [hexp]
  rw [Finset.sum_comm]
  have : ∀ i : Fin n, ∑ ε : Fin n → Bool, ∑ j, sgn ε i * sgn ε j * ⟪x i, x j⟫
      = 2 ^ n * ‖x i‖ ^ 2 := by
    intro i
    rw [Finset.sum_comm]
    have hterm : ∀ j : Fin n, ∑ ε : Fin n → Bool, sgn ε i * sgn ε j * ⟪x i, x j⟫
        = if j = i then 2 ^ n * ‖x i‖ ^ 2 else 0 := by
      intro j
      by_cases hj : j = i
      · subst hj
        have hone : ∑ ε : Fin n → Bool, sgn ε j * sgn ε j = 2 ^ n := by
          simp [sgn_sq]
        rw [if_pos rfl, ← Finset.sum_mul, hone, real_inner_self_eq_norm_sq]
      · rw [if_neg hj, ← Finset.sum_mul, sum_sgn_mul_sgn (Ne.symm hj), zero_mul]
    simp only [hterm]
    simp
  rw [Finset.sum_congr rfl fun i _ => this i, ← Finset.mul_sum]

/-- The class of linear functionals with weight norm at most `W`, restricted to the
sample `x`. -/
def linearClass {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (W : ℝ) (x : Fin n → E) : Set (Fin n → ℝ) :=
  {v | ∃ w : E, ‖w‖ ≤ W ∧ ∀ i, v i = ⟪w, x i⟫}

lemma linearClass_nonempty {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {W : ℝ} (hW : 0 ≤ W) (x : Fin n → E) : (linearClass W x).Nonempty :=
  ⟨fun _ => 0, 0, by simpa using hW, by simp⟩

/-- Cauchy–Schwarz in the feature space: for a fixed sign pattern the supremum over the
weight ball is controlled by the norm of the signed sum of the sample points. -/
lemma sSup_linearClass_le {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {W : ℝ} (hW : 0 ≤ W) (x : Fin n → E) (ε : Fin n → Bool) :
    sSup (signAvg ε '' linearClass W x) ≤ (1 / (n : ℝ)) * (W * ‖∑ i, sgn ε i • x i‖) := by
  refine Real.sSup_le ?_ (by positivity)
  rintro a ⟨v, ⟨w, hw, hv⟩, rfl⟩
  have hrw : ∑ i, sgn ε i * v i = ⟪w, ∑ i, sgn ε i • x i⟫ := by
    rw [inner_sum]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [real_inner_smul_right, hv i]
  have hcs : ⟪w, ∑ i, sgn ε i • x i⟫ ≤ W * ‖∑ i, sgn ε i • x i‖ := by
    calc ⟪w, ∑ i, sgn ε i • x i⟫ ≤ ‖w‖ * ‖∑ i, sgn ε i • x i‖ :=
          real_inner_le_norm _ _
      _ ≤ W * ‖∑ i, sgn ε i • x i‖ := by
          have : (0:ℝ) ≤ ‖∑ i, sgn ε i • x i‖ := norm_nonneg _
          nlinarith
  unfold signAvg
  rw [hrw]
  have hn : (0:ℝ) ≤ 1 / (n : ℝ) := by positivity
  exact mul_le_mul_of_nonneg_left hcs hn

/-- **Margin bound for linear classifiers.**  If all sample points have norm at most `B`
and the weight vectors have norm at most `W`, the empirical Rademacher complexity of the
linear class is at most `W * B / √n`.  No hypothesis on the dimension of `E` is made. -/
theorem rad_linearClass_le {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {W B : ℝ} (hW : 0 ≤ W) (hB : 0 ≤ B) (hn : 0 < n) (x : Fin n → E)
    (hx : ∀ i, ‖x i‖ ≤ B) :
    rad (linearClass W x) ≤ W * B / Real.sqrt n := by
  classical
  set u : (Fin n → Bool) → ℝ := fun ε => ‖∑ i, sgn ε i • x i‖ with hu
  have hn' : (0:ℝ) < n := by exact_mod_cast hn
  have hpow : (0:ℝ) < 2 ^ n := by positivity
  -- Step 1: the sum of the suprema is bounded by `(W/n) ∑_σ ‖∑ σᵢ • xᵢ‖`.
  have step1 : ∑ ε : Fin n → Bool, sSup (signAvg ε '' linearClass W x)
      ≤ (1 / (n:ℝ)) * W * ∑ ε : Fin n → Bool, u ε := by
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum fun ε _ => ?_
    have := sSup_linearClass_le hW x ε
    calc sSup (signAvg ε '' linearClass W x) ≤ (1 / (n : ℝ)) * (W * u ε) := this
      _ = (1 / (n:ℝ)) * W * u ε := by ring
  -- Step 2: second moment computation and Cauchy–Schwarz over sign patterns.
  have hsq : ∑ ε : Fin n → Bool, (u ε) ^ 2 = 2 ^ n * ∑ i, ‖x i‖ ^ 2 :=
    sum_norm_sq_signed x
  have hxB : ∑ i, ‖x i‖ ^ 2 ≤ (n:ℝ) * B ^ 2 := by
    calc ∑ i, ‖x i‖ ^ 2 ≤ ∑ _i : Fin n, B ^ 2 := by
          refine Finset.sum_le_sum fun i _ => ?_
          have := hx i
          nlinarith [norm_nonneg (x i)]
      _ = (n:ℝ) * B ^ 2 := by simp [Finset.sum_const]
  have hcs : (∑ ε : Fin n → Bool, u ε) ^ 2
      ≤ (2:ℝ) ^ n * ∑ ε : Fin n → Bool, (u ε) ^ 2 := by
    have := sq_sum_le_card_mul_sum_sq (s := (Finset.univ : Finset (Fin n → Bool))) (f := u)
    simpa using this
  have hsum_sq : (∑ ε : Fin n → Bool, u ε) ^ 2 ≤ ((2:ℝ) ^ n * (Real.sqrt n * B)) ^ 2 := by
    have h1 : (∑ ε : Fin n → Bool, u ε) ^ 2 ≤ (2:ℝ) ^ n * (2 ^ n * ((n:ℝ) * B ^ 2)) := by
      calc (∑ ε : Fin n → Bool, u ε) ^ 2 ≤ (2:ℝ) ^ n * ∑ ε : Fin n → Bool, (u ε) ^ 2 := hcs
        _ = (2:ℝ) ^ n * (2 ^ n * ∑ i, ‖x i‖ ^ 2) := by rw [hsq]
        _ ≤ (2:ℝ) ^ n * (2 ^ n * ((n:ℝ) * B ^ 2)) := by
            have : (0:ℝ) ≤ (2:ℝ) ^ n * 2 ^ n := by positivity
            nlinarith
    have h2 : ((2:ℝ) ^ n * (Real.sqrt n * B)) ^ 2 = (2:ℝ) ^ n * (2 ^ n * ((n:ℝ) * B ^ 2)) := by
      have : Real.sqrt n ^ 2 = (n:ℝ) := Real.sq_sqrt hn'.le
      ring_nf
      rw [this]
      ring
    rw [h2]; exact h1
  have hsum_nonneg : 0 ≤ ∑ ε : Fin n → Bool, u ε :=
    Finset.sum_nonneg fun ε _ => norm_nonneg _
  have hbound : ∑ ε : Fin n → Bool, u ε ≤ (2:ℝ) ^ n * (Real.sqrt n * B) := by
    have hrhs : (0:ℝ) ≤ (2:ℝ) ^ n * (Real.sqrt n * B) := by positivity
    nlinarith
  -- Step 3: combine.
  have hfinal : rad (linearClass W x) ≤ (1 / (n:ℝ)) * W * (Real.sqrt n * B) := by
    unfold rad
    rw [div_le_iff₀ hpow]
    calc ∑ ε : Fin n → Bool, sSup (signAvg ε '' linearClass W x)
        ≤ (1 / (n:ℝ)) * W * ∑ ε : Fin n → Bool, u ε := step1
      _ ≤ (1 / (n:ℝ)) * W * ((2:ℝ) ^ n * (Real.sqrt n * B)) := by
          have : (0:ℝ) ≤ (1 / (n:ℝ)) * W := by positivity
          nlinarith
      _ = (1 / (n:ℝ)) * W * (Real.sqrt n * B) * 2 ^ n := by ring
  have hsqrt : (0:ℝ) < Real.sqrt n := Real.sqrt_pos.mpr hn'
  have hrewrite : (1 / (n:ℝ)) * W * (Real.sqrt n * B) = W * B / Real.sqrt n := by
    have hns : Real.sqrt n * Real.sqrt n = (n:ℝ) := Real.mul_self_sqrt hn'.le
    rw [eq_div_iff hsqrt.ne']
    calc (1 / (n:ℝ)) * W * (Real.sqrt n * B) * Real.sqrt n
        = W * B * (Real.sqrt n * Real.sqrt n) / n := by ring
      _ = W * B * (n:ℝ) / n := by rw [hns]
      _ = W * B := by field_simp
  rwa [hrewrite] at hfinal

/-- **Kernel version of the margin bound.**  If `φ` is a feature map with kernel
`K y z = ⟪φ y, φ z⟫` whose diagonal is bounded by `B ^ 2`, then the class of kernel
predictors `y ↦ ⟪w, φ y⟫` with `‖w‖ ≤ W` has empirical Rademacher complexity at most
`W * B / √n` on any sample of size `n`.  In particular the bound depends on the kernel
only through `sup_y K y y`. -/
theorem rad_kernelClass_le {X E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {W B : ℝ} (hW : 0 ≤ W) (hB : 0 ≤ B) (hn : 0 < n) (phi : X → E) (s : Fin n → X)
    (hK : ∀ i, ⟪phi (s i), phi (s i)⟫ ≤ B ^ 2) :
    rad (linearClass W (fun i => phi (s i))) ≤ W * B / Real.sqrt n := by
  refine rad_linearClass_le hW hB hn _ fun i => ?_
  have h := hK i
  rw [real_inner_self_eq_norm_sq] at h
  nlinarith [norm_nonneg (phi (s i))]

end RademacherLinear