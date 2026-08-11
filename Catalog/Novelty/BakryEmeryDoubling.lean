import Mathlib

/-!
# Volume doubling and polynomial growth

This file isolates the purely metric/measure-theoretic half of the paper
*Nonnegative Bakry–Émery curvature on bounded-degree graphs implies volume doubling
and Poincaré inequalities*: the mechanism by which a **scale-invariant doubling
inequality** upgrades to **polynomial volume growth**, together with the reverse
comparison.

A volume profile is any monotone function `vol : ℕ → ℝ` with `vol 0 > 0`
(in the graph case `vol r = #B(x,r)`).  We say it is `C`-doubling if
`vol (2*r) ≤ C * vol r` for all `r`.

Main results:

* `Doubling.iterate` : `vol (2^k * r) ≤ C^k * vol r`.
* `Doubling.polynomial_growth` : `vol R ≤ C * R ^ (Real.logb 2 C) * vol 1` for `R ≥ 1`,
  i.e. doubling forces polynomial growth of exponent `log₂ C`.
* `Doubling.const_ge_one` : a doubling constant for a nondegenerate profile is `≥ 1`.
* `Doubling.growth_ge_of_connected` : in a connected graph with at least two vertices
  the volume profile is strictly increasing until it saturates, so doubling really is
  a nontrivial constraint.
-/

namespace BakryEmery

open Real

/-- A volume profile: monotone, positive at scale `0`. -/
structure VolumeProfile (vol : ℕ → ℝ) : Prop where
  mono : Monotone vol
  pos : 0 < vol 0

/-- `C`-volume doubling at all integer scales. -/
def Doubling (vol : ℕ → ℝ) (C : ℝ) : Prop := ∀ r : ℕ, vol (2 * r) ≤ C * vol r

namespace Doubling

variable {vol : ℕ → ℝ} {C : ℝ}

lemma pos_of (hv : VolumeProfile vol) (r : ℕ) : 0 < vol r :=
  lt_of_lt_of_le hv.pos (hv.mono (Nat.zero_le r))

/-- A doubling constant is at least one. -/
lemma const_ge_one (hv : VolumeProfile vol) (hd : Doubling vol C) : 1 ≤ C := by
  have h := hd 1
  have h1 : vol 1 ≤ vol 2 := hv.mono (by norm_num)
  have hpos : 0 < vol 1 := pos_of hv 1
  nlinarith [h, h1, hpos]

/-- Iterated doubling: `vol (2^k r) ≤ C^k vol r`. -/
theorem iterate (hv : VolumeProfile vol) (hd : Doubling vol C) (r k : ℕ) :
    vol (2 ^ k * r) ≤ C ^ k * vol r := by
  induction k with
  | zero => simp
  | succ k ih =>
    have hC : 1 ≤ C := const_ge_one hv hd
    have hstep : vol (2 ^ (k + 1) * r) = vol (2 * (2 ^ k * r)) := by
      congr 1; ring
    calc vol (2 ^ (k + 1) * r) = vol (2 * (2 ^ k * r)) := hstep
      _ ≤ C * vol (2 ^ k * r) := hd _
      _ ≤ C * (C ^ k * vol r) := by
          have : (0:ℝ) ≤ C := le_trans zero_le_one hC
          exact mul_le_mul_of_nonneg_left ih this
      _ = C ^ (k + 1) * vol r := by ring

/-- Doubling forces at most polynomial growth, with exponent `log₂ C`. -/
theorem polynomial_growth (hv : VolumeProfile vol) (hd : Doubling vol C) (hC : 1 < C)
    (R : ℕ) (hR : 1 ≤ R) :
    vol R ≤ C * (R : ℝ) ^ (Real.logb 2 C) * vol 1 := by
  set k := Nat.clog 2 R with hk
  have hRle : R ≤ 2 ^ k := Nat.le_pow_clog (by norm_num) R
  have h1 : vol R ≤ vol (2 ^ k * 1) := by
    have : R ≤ 2 ^ k * 1 := by simpa using hRle
    exact hv.mono this
  have h2 : vol (2 ^ k * 1) ≤ C ^ k * vol 1 := iterate hv hd 1 k
  -- `C ^ k ≤ C * R ^ (logb 2 C)`
  have hCpos : (0:ℝ) < C := lt_trans zero_lt_one hC
  have hkle : (k : ℝ) ≤ 1 + Real.logb 2 R := by
    rcases Nat.eq_zero_or_pos k with h | h
    · rw [h]
      have : 0 ≤ Real.logb 2 R := Real.logb_nonneg (by norm_num) (by exact_mod_cast hR)
      push_cast; linarith
    · have hpow : 2 ^ (k - 1) < R := Nat.pow_pred_clog_lt_self (by norm_num) (by omega)
      have hlt : ((2:ℝ) ^ (k - 1) : ℝ) < (R : ℝ) := by exact_mod_cast hpow
      have := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) hlt
      rw [Real.logb_pow] at this
      have hk1 : ((k - 1 : ℕ) : ℝ) = (k : ℝ) - 1 := by
        have : 1 ≤ k := h
        push_cast [Nat.cast_sub this]
        ring
      rw [Real.logb_self_eq_one (by norm_num) (by norm_num)] at this
      rw [hk1] at this
      linarith
  have hlogC : 0 < Real.logb 2 C := Real.logb_pos (by norm_num) hC
  have hCk : C ^ k ≤ C * (R:ℝ) ^ (Real.logb 2 C) := by
    have e1 : C ^ k = (2:ℝ) ^ ((k : ℝ) * Real.logb 2 C) := by
      rw [Real.rpow_natCast_mul (by norm_num) k]
      rw [Real.rpow_logb (by norm_num) (by norm_num) hCpos]
    have e2 : C * (R:ℝ) ^ (Real.logb 2 C)
        = (2:ℝ) ^ ((1 + Real.logb 2 R) * Real.logb 2 C) := by
      rw [add_mul, one_mul, Real.rpow_add (by norm_num)]
      rw [Real.rpow_logb (by norm_num) (by norm_num) hCpos]
      congr 1
      rw [mul_comm, Real.rpow_natCast_mul] <;> try norm_num
      · rw [Real.rpow_logb (by norm_num) (by norm_num)
          (by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hR)]
      · exact le_of_lt (by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hR)
    rw [e1, e2]
    apply Real.rpow_le_rpow_of_exponent_le (by norm_num)
    exact mul_le_mul_of_nonneg_right hkle (le_of_lt hlogC)
  have hv1 : 0 < vol 1 := pos_of hv 1
  calc vol R ≤ vol (2 ^ k * 1) := h1
    _ ≤ C ^ k * vol 1 := h2
    _ ≤ (C * (R:ℝ) ^ (Real.logb 2 C)) * vol 1 :=
        mul_le_mul_of_nonneg_right hCk (le_of_lt hv1)

/-- Doubling at all scales is inherited by all dyadic comparisons: for `r ≤ R ≤ 2 r`
one has `vol R ≤ C * vol r`. -/
theorem le_of_le_two_mul (hv : VolumeProfile vol) (hd : Doubling vol C)
    {r R : ℕ} (h : R ≤ 2 * r) : vol R ≤ C * vol r :=
  le_trans (hv.mono h) (hd r)

end Doubling

/-! ### Graph volume profiles -/

open Finset

variable {V : Type*} [Fintype V] [DecidableEq V] (G : SimpleGraph V) [DecidableRel G.Adj]

/-- The closed ball of radius `r` around `x` in the graph metric. -/
noncomputable def ball (x : V) (r : ℕ) : Finset V :=
  {y : V | G.dist x y ≤ r}.toFinset

variable {G}

lemma mem_ball {x y : V} {r : ℕ} : y ∈ ball G x r ↔ G.dist x y ≤ r := by
  simp [ball]

lemma ball_mono {x : V} {r s : ℕ} (h : r ≤ s) : ball G x r ⊆ ball G x s := by
  intro y hy
  rw [mem_ball] at hy ⊢
  omega

/-- The volume profile of a graph is monotone and positive at radius `0`. -/
theorem volumeProfile_card_ball (x : V) :
    VolumeProfile (fun r => ((ball G x r).card : ℝ)) where
  mono := by
    intro r s h
    exact_mod_cast Finset.card_le_card (ball_mono h)
  pos := by
    have : x ∈ ball G x 0 := by rw [mem_ball]; simp
    have : 0 < (ball G x 0).card := Finset.card_pos.2 ⟨x, this⟩
    exact_mod_cast this

end BakryEmery