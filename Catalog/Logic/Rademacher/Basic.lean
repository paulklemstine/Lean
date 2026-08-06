/-
# Empirical Rademacher complexity: definitions and basic calculus

This file sets up the *empirical Rademacher complexity* of a class of real vectors
indexed by a finite sample of size `n`.  If `F : Set (Fin n → ℝ)` is the restriction
of a hypothesis class to a sample `x₁, …, xₙ`, its empirical Rademacher complexity is

  `R(F) = 𝔼_σ [ sup_{v ∈ F} (1/n) ∑ i, σ i * v i ]`,

where `σ` ranges uniformly over the `2ⁿ` sign vectors in `{-1, 1}ⁿ`.
The expectation is realised as an explicit finite average over `Fin n → Bool`.

The basic calculus proved here: the complexity of a singleton vanishes, it is
monotone in the class, nonnegative for nonempty classes, homogeneous under scaling,
invariant under translation, and bounded by any uniform bound on the coordinates.
-/
import Mathlib

namespace Rademacher

open Finset

variable {n : ℕ}

/-- The sign vector attached to a boolean vector: `true ↦ 1`, `false ↦ -1`. -/
def sgn (ε : Fin n → Bool) (i : Fin n) : ℝ := if ε i then 1 else -1

@[simp] lemma sgn_neg (ε : Fin n → Bool) (i : Fin n) :
    sgn (fun j => !(ε j)) i = -sgn ε i := by
  simp only [sgn]
  rcases Bool.eq_false_or_eq_true (ε i) with h | h <;> simp [h]

lemma abs_sgn (ε : Fin n → Bool) (i : Fin n) : |sgn ε i| = 1 := by
  simp only [sgn]; cases ε i <;> simp

lemma sgn_sq (ε : Fin n → Bool) (i : Fin n) : sgn ε i * sgn ε i = 1 := by
  simp only [sgn]; cases ε i <;> norm_num

/-- The linear functional `v ↦ (1/n) ∑ σ i * v i` associated with a sign vector. -/
noncomputable def signAvg (ε : Fin n → Bool) (v : Fin n → ℝ) : ℝ :=
  (1 / (n : ℝ)) * ∑ i, sgn ε i * v i

/-- The empirical Rademacher complexity of a class `F` of vectors:
the average over all `2ⁿ` sign patterns of the supremum of `signAvg`. -/
noncomputable def rad (F : Set (Fin n → ℝ)) : ℝ :=
  (∑ ε : Fin n → Bool, sSup (signAvg ε '' F)) / 2 ^ n

lemma card_sign : (Finset.univ : Finset (Fin n → Bool)).card = 2 ^ n := by
  simp

/-- Flipping all signs is an involution of the sign vectors, so a sum over sign
vectors is unchanged by negating the signs. -/
lemma sum_sign_neg (g : (Fin n → Bool) → ℝ) :
    ∑ ε : Fin n → Bool, g (fun j => !(ε j)) = ∑ ε : Fin n → Bool, g ε := by
  refine Finset.sum_nbij' (fun ε => fun j => !(ε j)) (fun ε => fun j => !(ε j))
    ?_ ?_ ?_ ?_ ?_ <;> intros <;> simp

lemma sum_sgn_eq_zero (i : Fin n) : ∑ ε : Fin n → Bool, sgn ε i = 0 := by
  have h := sum_sign_neg (fun ε => sgn ε i)
  simp only [sgn_neg] at h
  rw [Finset.sum_neg_distrib] at h
  linarith

lemma signAvg_singleton (ε : Fin n → Bool) (v : Fin n → ℝ) :
    sSup (signAvg ε '' ({v} : Set (Fin n → ℝ))) = signAvg ε v := by
  simp [Set.image_singleton]

/-- The Rademacher complexity of a single vector is zero. -/
theorem rad_singleton (v : Fin n → ℝ) : rad ({v} : Set (Fin n → ℝ)) = 0 := by
  unfold rad
  rw [Finset.sum_congr rfl (fun ε _ => signAvg_singleton ε v)]
  have : ∑ ε : Fin n → Bool, signAvg ε v = 0 := by
    unfold signAvg
    rw [← Finset.mul_sum, Finset.sum_comm]
    have : ∀ i : Fin n, ∑ ε : Fin n → Bool, sgn ε i * v i = 0 := by
      intro i
      rw [← Finset.sum_mul, sum_sgn_eq_zero i, zero_mul]
    simp [this]
  rw [this]
  simp

lemma bddAbove_image_of_finite {F : Set (Fin n → ℝ)} (hF : F.Finite)
    (ε : Fin n → Bool) : BddAbove (signAvg ε '' F) :=
  (hF.image _).bddAbove

/-- Monotonicity of the Rademacher complexity in the hypothesis class. -/
theorem rad_mono {F G : Set (Fin n → ℝ)} (hFG : F ⊆ G) (hF : F.Nonempty)
    (hG : ∀ ε : Fin n → Bool, BddAbove (signAvg ε '' G)) :
    rad F ≤ rad G := by
  unfold rad
  have h : ∑ ε : Fin n → Bool, sSup (signAvg ε '' F)
      ≤ ∑ ε : Fin n → Bool, sSup (signAvg ε '' G) :=
    Finset.sum_le_sum fun ε _ =>
      csSup_le_csSup (hG ε) (hF.image _) (Set.image_mono hFG)
  have hpow : (0:ℝ) < 2 ^ n := by positivity
  exact div_le_div_of_nonneg_right h hpow.le

/-- The Rademacher complexity of a nonempty class is nonnegative. -/
theorem rad_nonneg {F : Set (Fin n → ℝ)} (hF : F.Nonempty)
    (hb : ∀ ε : Fin n → Bool, BddAbove (signAvg ε '' F)) :
    0 ≤ rad F := by
  obtain ⟨v, hv⟩ := hF
  have key : ∀ ε : Fin n → Bool,
      0 ≤ sSup (signAvg ε '' F) + sSup (signAvg (fun j => !(ε j)) '' F) := by
    intro ε
    have h1 : signAvg ε v ≤ sSup (signAvg ε '' F) :=
      le_csSup (hb ε) ⟨v, hv, rfl⟩
    have h2 : signAvg (fun j => !(ε j)) v ≤ sSup (signAvg (fun j => !(ε j)) '' F) :=
      le_csSup (hb _) ⟨v, hv, rfl⟩
    have h3 : signAvg (fun j => !(ε j)) v = -signAvg ε v := by
      unfold signAvg
      simp [sgn_neg, Finset.sum_neg_distrib, mul_neg, neg_mul]
    rw [h3] at h2
    linarith
  have hsum : 0 ≤ ∑ ε : Fin n → Bool, sSup (signAvg ε '' F) := by
    have hneg : ∑ ε : Fin n → Bool, sSup (signAvg (fun j => !(ε j)) '' F)
        = ∑ ε : Fin n → Bool, sSup (signAvg ε '' F) :=
      sum_sign_neg (fun ε => sSup (signAvg ε '' F))
    have := Finset.sum_le_sum (fun ε (_ : ε ∈ (Finset.univ : Finset (Fin n → Bool))) =>
      key ε)
    simp only [Finset.sum_const, smul_zero, Finset.sum_add_distrib] at this
    rw [hneg] at this
    linarith
  unfold rad
  have hpow : (0:ℝ) < 2 ^ n := by positivity
  exact div_nonneg hsum hpow.le

/-- If every sign pattern's supremum is at most `c`, the Rademacher complexity is at most `c`. -/
theorem rad_le_of_sSup_le {F : Set (Fin n → ℝ)} {c : ℝ}
    (h : ∀ ε : Fin n → Bool, sSup (signAvg ε '' F) ≤ c) : rad F ≤ c := by
  unfold rad
  have hpow : (0:ℝ) < 2 ^ n := by positivity
  rw [div_le_iff₀ hpow]
  calc ∑ ε : Fin n → Bool, sSup (signAvg ε '' F)
      ≤ ∑ _ε : Fin n → Bool, c := Finset.sum_le_sum fun ε _ => h ε
    _ = c * 2 ^ n := by
        simp [Finset.sum_const, mul_comm]

/-- If every sign pattern's supremum is at least `c`, the Rademacher complexity is at least `c`. -/
theorem le_rad_of_le_sSup {F : Set (Fin n → ℝ)} {c : ℝ}
    (h : ∀ ε : Fin n → Bool, c ≤ sSup (signAvg ε '' F)) : c ≤ rad F := by
  unfold rad
  have hpow : (0:ℝ) < 2 ^ n := by positivity
  rw [le_div_iff₀ hpow]
  calc c * 2 ^ n = ∑ _ε : Fin n → Bool, c := by
        simp [Finset.sum_const, mul_comm]
    _ ≤ ∑ ε : Fin n → Bool, sSup (signAvg ε '' F) := Finset.sum_le_sum fun ε _ => h ε

/-- A vector with coordinates bounded by `B` has sign-average bounded by `B`. -/
lemma signAvg_le_of_bound {v : Fin n → ℝ} {B : ℝ} (hB : 0 ≤ B)
    (hv : ∀ i, |v i| ≤ B) (ε : Fin n → Bool) : signAvg ε v ≤ B := by
  rcases Nat.eq_zero_or_pos n with hn | hn
  · subst hn; simp [signAvg, hB]
  have hn' : (0:ℝ) < n := by exact_mod_cast hn
  have hterm : ∀ i : Fin n, sgn ε i * v i ≤ B := by
    intro i
    calc sgn ε i * v i ≤ |sgn ε i * v i| := le_abs_self _
      _ = |sgn ε i| * |v i| := abs_mul _ _
      _ = |v i| := by rw [abs_sgn]; ring
      _ ≤ B := hv i
  have : ∑ i, sgn ε i * v i ≤ (n : ℝ) * B := by
    calc ∑ i, sgn ε i * v i ≤ ∑ _i : Fin n, B := Finset.sum_le_sum fun i _ => hterm i
      _ = (n : ℝ) * B := by simp [Finset.sum_const, mul_comm]
  unfold signAvg
  rw [one_div, inv_mul_le_iff₀ hn']
  linarith

/-- A class of vectors with all coordinates bounded by `B` has Rademacher complexity at most `B`. -/
theorem rad_le_of_bound {F : Set (Fin n → ℝ)} {B : ℝ} (hB : 0 ≤ B)
    (hF : ∀ v ∈ F, ∀ i, |v i| ≤ B) : rad F ≤ B := by
  refine rad_le_of_sSup_le fun ε => ?_
  refine Real.sSup_le ?_ hB
  rintro x ⟨v, hv, rfl⟩
  exact signAvg_le_of_bound hB (hF v hv) ε

end Rademacher