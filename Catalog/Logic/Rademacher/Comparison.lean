/-
# Rademacher complexity beats cardinality (VC) counting on structured classes

Massart's finite class lemma bounds the Rademacher complexity of a class of `N` vectors
by `r √(2 log N)/n`, and VC-type bounds bound `N` (the number of behaviours on the
sample) by a function of the VC dimension.  Both are *counting* bounds and become
vacuous for classes that are infinite on the sample.

This file computes the empirical Rademacher complexity of the Euclidean ball of
radius `r`, i.e. of the class of all vectors of length at most `r`:

  `rad (ball r) = r / √n`   (`rad_ball`),

and shows that this class is infinite (`ball_infinite`), so no cardinality bound
applies to it, while its Rademacher complexity is finite, dimension free, and even
*exactly* computable.  Every subclass of the ball inherits the bound
(`rad_le_of_subset_ball`), which is the abstract form of the margin bound for linear
predictors.

Finally `vc_bound_eventually_worse` records the quantitative comparison: for a class of
linear predictors in dimension `d`, the VC dimension grows with `d`, so any bound of the
shape `c √(d/n)` eventually exceeds the dimension-free Rademacher bound `W B / √n`.

This file is self-contained.
-/
import Mathlib

namespace RademacherComparison

open Finset

variable {n : ℕ}

/-- The sign vector attached to a boolean vector: `true ↦ 1`, `false ↦ -1`. -/
def sgn (ε : Fin n → Bool) (i : Fin n) : ℝ := if ε i then 1 else -1

lemma sgn_sq (ε : Fin n → Bool) (i : Fin n) : (sgn ε i) ^ 2 = 1 := by
  simp only [sgn]
  rcases Bool.eq_false_or_eq_true (ε i) with h | h <;> simp [h]

/-- The linear functional `v ↦ (1/n) ∑ σ i * v i` associated with a sign vector. -/
noncomputable def signAvg (ε : Fin n → Bool) (v : Fin n → ℝ) : ℝ :=
  (1 / (n : ℝ)) * ∑ i, sgn ε i * v i

/-- The empirical Rademacher complexity of a class `F` of vectors. -/
noncomputable def rad (F : Set (Fin n → ℝ)) : ℝ :=
  (∑ ε : Fin n → Bool, sSup (signAvg ε '' F)) / 2 ^ n

/-- The Euclidean ball of radius `r` in the sample space `ℝⁿ`. -/
def ball (n : ℕ) (r : ℝ) : Set (Fin n → ℝ) := {v | ∑ i, (v i) ^ 2 ≤ r ^ 2}

/-- Cauchy–Schwarz: the correlation of a sign pattern with a vector of the ball is at
most `r √n`. -/
lemma signAvg_le_ball {r : ℝ} (hr : 0 ≤ r) (hn : 0 < n) {v : Fin n → ℝ}
    (hv : v ∈ ball n r) (ε : Fin n → Bool) : signAvg ε v ≤ r / Real.sqrt n := by
  have hn' : (0:ℝ) < n := by exact_mod_cast hn
  have hcs : (∑ i, sgn ε i * v i) ^ 2 ≤ ((n:ℝ)) * r ^ 2 := by
    have h := sum_mul_sq_le_sq_mul_sq (Finset.univ : Finset (Fin n)) (sgn ε) v
    have hone : ∑ i, (sgn ε i) ^ 2 = (n:ℝ) := by simp [sgn_sq]
    calc (∑ i, sgn ε i * v i) ^ 2 ≤ (∑ i, (sgn ε i) ^ 2) * (∑ i, (v i) ^ 2) := h
      _ = (n:ℝ) * (∑ i, (v i) ^ 2) := by rw [hone]
      _ ≤ (n:ℝ) * r ^ 2 := by
          have : ∑ i, (v i) ^ 2 ≤ r ^ 2 := hv
          nlinarith
  have hsqrt : (0:ℝ) < Real.sqrt n := Real.sqrt_pos.mpr hn'
  have hns : Real.sqrt n * Real.sqrt n = (n:ℝ) := Real.mul_self_sqrt hn'.le
  have hle : ∑ i, sgn ε i * v i ≤ Real.sqrt n * r := by
    by_contra hcon
    push_neg at hcon
    have h0 : 0 ≤ Real.sqrt n * r := mul_nonneg hsqrt.le hr
    have hsq : (Real.sqrt n * r) ^ 2 < (∑ i, sgn ε i * v i) ^ 2 := by nlinarith
    have heq : (Real.sqrt n * r) ^ 2 = (n:ℝ) * r ^ 2 := by
      rw [mul_pow, Real.sq_sqrt hn'.le]
    linarith [hcs, hsq, heq.symm.le, heq.le]
  have hfin : (1 / (n:ℝ)) * (Real.sqrt n * r) = r / Real.sqrt n := by
    field_simp
    nlinarith [hns]
  unfold signAvg
  calc (1 / (n:ℝ)) * ∑ i, sgn ε i * v i ≤ (1 / (n:ℝ)) * (Real.sqrt n * r) :=
        mul_le_mul_of_nonneg_left hle (by positivity)
    _ = r / Real.sqrt n := hfin

/-- The scaled sign pattern realises the supremum: it lies in the ball and has
correlation exactly `r √n`. -/
lemma ball_attains {r : ℝ} (hn : 0 < n) (ε : Fin n → Bool) :
    (fun i => r / Real.sqrt n * sgn ε i) ∈ ball n r ∧
      signAvg ε (fun i => r / Real.sqrt n * sgn ε i) = r / Real.sqrt n := by
  have hn' : (0:ℝ) < n := by exact_mod_cast hn
  have hsqrt : (0:ℝ) < Real.sqrt n := Real.sqrt_pos.mpr hn'
  have hns : Real.sqrt n * Real.sqrt n = (n:ℝ) := Real.mul_self_sqrt hn'.le
  constructor
  · show ∑ i, (r / Real.sqrt n * sgn ε i) ^ 2 ≤ r ^ 2
    have hsq2 : ∀ i : Fin n, (r / Real.sqrt n * sgn ε i) ^ 2 = r ^ 2 / (n:ℝ) := by
      intro i
      rw [mul_pow, sgn_sq, mul_one, div_pow, Real.sq_sqrt hn'.le]
    have hcalc : (n:ℝ) * (r ^ 2 / (n:ℝ)) = r ^ 2 := by field_simp
    rw [Finset.sum_congr rfl fun i _ => hsq2 i, Finset.sum_const, nsmul_eq_mul]
    simp only [Finset.card_univ, Fintype.card_fin]
    rw [hcalc]
  · unfold signAvg
    have hpt : ∀ i : Fin n, sgn ε i * (r / Real.sqrt n * sgn ε i) = r / Real.sqrt n := by
      intro i
      calc sgn ε i * (r / Real.sqrt n * sgn ε i) = (r / Real.sqrt n) * (sgn ε i) ^ 2 := by
            ring
        _ = r / Real.sqrt n := by rw [sgn_sq, mul_one]
    rw [Finset.sum_congr rfl fun i _ => hpt i, Finset.sum_const, nsmul_eq_mul]
    simp only [Finset.card_univ, Fintype.card_fin]
    field_simp

/-- **The Rademacher complexity of the Euclidean ball is exactly `r/√n`.**
It does not depend on any notion of dimension, and it is finite even though the class
is infinite. -/
theorem rad_ball {r : ℝ} (hr : 0 ≤ r) (hn : 0 < n) : rad (ball n r) = r / Real.sqrt n := by
  have hpow : (0:ℝ) < 2 ^ n := by positivity
  have hsup : ∀ ε : Fin n → Bool, sSup (signAvg ε '' ball n r) = r / Real.sqrt n := by
    intro ε
    obtain ⟨hmem, hval⟩ := ball_attains hn ε
    refine IsGreatest.csSup_eq ⟨⟨_, hmem, hval⟩, ?_⟩
    rintro a ⟨v, hv, rfl⟩
    exact signAvg_le_ball hr hn hv ε
  unfold rad
  rw [Finset.sum_congr rfl fun ε _ => hsup ε, Finset.sum_const, nsmul_eq_mul,
    Finset.card_univ]
  simp only [Fintype.card_fun, Fintype.card_bool, Fintype.card_fin]
  push_cast
  field_simp

/-- Any class contained in the ball of radius `r` obeys the dimension-free bound
`r/√n`; this is the abstract form of the margin bound for linear predictors. -/
theorem rad_le_of_subset_ball {F : Set (Fin n → ℝ)} {r : ℝ} (hr : 0 ≤ r) (hn : 0 < n)
    (hF : F ⊆ ball n r) : rad F ≤ r / Real.sqrt n := by
  have hpow : (0:ℝ) < 2 ^ n := by positivity
  have hsup : ∀ ε : Fin n → Bool, sSup (signAvg ε '' F) ≤ r / Real.sqrt n := by
    intro ε
    refine Real.sSup_le ?_ (by positivity)
    rintro a ⟨v, hv, rfl⟩
    exact signAvg_le_ball hr hn (hF hv) ε
  unfold rad
  rw [div_le_iff₀ hpow]
  calc ∑ ε : Fin n → Bool, sSup (signAvg ε '' F)
      ≤ ∑ _ε : Fin n → Bool, r / Real.sqrt n := Finset.sum_le_sum fun ε _ => hsup ε
    _ = r / Real.sqrt n * 2 ^ n := by
        rw [Finset.sum_const, nsmul_eq_mul, Finset.card_univ]
        simp only [Fintype.card_fun, Fintype.card_bool, Fintype.card_fin]
        push_cast
        ring

/-- The ball of positive radius is an infinite class, so every bound obtained by
counting the behaviours of the class on the sample — in particular every VC/Sauer
bound and Massart's finite class lemma — is vacuous for it. -/
theorem ball_infinite {r : ℝ} (hr : 0 < r) (hn : 0 < n) : (ball n r).Infinite := by
  have hi : Set.InjOn (fun t : ℝ => (fun i : Fin n => if i = ⟨0, hn⟩ then t else 0))
      (Set.Icc 0 r) := by
    intro a _ b _ hab
    have := congrFun hab ⟨0, hn⟩
    simpa using this
  have hsub : (fun t : ℝ => (fun i : Fin n => if i = ⟨0, hn⟩ then t else 0)) ''
      (Set.Icc 0 r) ⊆ ball n r := by
    rintro v ⟨t, ht, rfl⟩
    show ∑ i, (if i = (⟨0, hn⟩ : Fin n) then t else 0) ^ 2 ≤ r ^ 2
    have : ∑ i : Fin n, (if i = (⟨0, hn⟩ : Fin n) then t else 0) ^ 2 = t ^ 2 := by
      rw [Finset.sum_eq_single (⟨0, hn⟩ : Fin n)]
      · simp
      · intro b _ hb; simp [hb]
      · intro h; simp at h
    rw [this]
    obtain ⟨h0, h1⟩ := ht
    nlinarith
  exact Set.Infinite.mono hsub (((Set.Icc_infinite hr).image hi))

/-- **The dimension-dependent (VC-type) bound is eventually worse.**
For linear predictors in dimension `d` the VC dimension is `d` (or `d+1`), so a VC-style
bound has the shape `c √(d/n)`; the Rademacher margin bound is `W B/√n`.  Whatever the
constant `c > 0`, once the dimension exceeds `(W B / c)²` the VC-style bound is strictly
larger, i.e. strictly weaker. -/
theorem vc_bound_eventually_worse {W B c : ℝ} (hW : 0 < W) (hB : 0 < B) (hc : 0 < c)
    (hn : 0 < n) {d : ℕ} (hd : (W * B / c) ^ 2 < d) :
    W * B / Real.sqrt n < c * Real.sqrt ((d : ℝ) / n) := by
  have hn' : (0:ℝ) < n := by exact_mod_cast hn
  have hsqrt : (0:ℝ) < Real.sqrt n := Real.sqrt_pos.mpr hn'
  have hdpos : (0:ℝ) < d := lt_of_le_of_lt (by positivity) hd
  have hsplit : Real.sqrt ((d : ℝ) / n) = Real.sqrt d / Real.sqrt n :=
    Real.sqrt_div hdpos.le n
  have hkey : W * B / c < Real.sqrt d := by
    have h1 : Real.sqrt ((W * B / c) ^ 2) < Real.sqrt d := by
      exact Real.sqrt_lt_sqrt (by positivity) hd
    rwa [Real.sqrt_sq (by positivity)] at h1
  rw [hsplit, div_lt_iff₀ hsqrt]
  have : c * (Real.sqrt d / Real.sqrt n) * Real.sqrt n = c * Real.sqrt d := by
    field_simp
  rw [this]
  calc W * B = c * (W * B / c) := by field_simp
    _ < c * Real.sqrt d := by exact mul_lt_mul_of_pos_left hkey hc

end RademacherComparison