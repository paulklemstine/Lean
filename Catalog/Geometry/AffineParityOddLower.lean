/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.AffineParityBent
import Geometry.AffineParityOdd

/-!
# Affine subspace statistics in `𝔽₂ⁿ`: the parity maximum in odd dimension, from below

For affine `2`-cubes the refined parity bound of `Catalog/Geometry/AffineParityGap.lean` reads
`P[|F ∩ A| odd] ≤ 1/2 - 2^{-(n+1)}`.  It is attained exactly when every "derivative set"
`Δ_w = {c : c ∈ A ↮ c + w ∈ A}` (`w ≠ 0`) is balanced, i.e. `|Δ_w| = 2^{n-1}`; this happens
for bent sets in even ambient dimension (`Catalog/Geometry/AffineParityBent.lean`) and is
*impossible* in odd ambient dimension (`Catalog/Geometry/AffineParityOdd.lean`).

This file supplies the matching lower bound in odd dimension.  The construction is the
pullback of a bent set along the projection `𝔽₂^{2m+1} → 𝔽₂^{2m}` that forgets the first
coordinate: exactly one nonzero direction (the forgotten coordinate direction `e₀`) has an
*empty* derivative set, and all the remaining `2^n - 2` nonzero directions are balanced.

## Main results

* `AffineParityOddLower.oddProb_eq_of_balanced_except` : if `Δ_e = ∅` for one nonzero `e`
  and `Δ_w` is balanced for every `w ∉ {0, e}`, then `P[|F ∩ A| odd] = 1/2 - 2^{-n}` exactly.
* `AffineParityOddLower.oddProb_liftSet` : the pullback of the standard bent set to
  `𝔽₂^{2m+1}` realises this value.
* `AffineParityOddLower.maxOddProb_two_ge_of_odd` : hence `maxOddProb n 2 ≥ 1/2 - 2^{-n}`
  for every odd `n`.
* `AffineParityOddLower.maxOddProb_two_odd_bounds` : combining with
  `AffineParityOdd.maxOddProb_two_lt_of_odd`, for odd `n`
  `1/2 - 2^{-n} ≤ maxOddProb n 2 < 1/2 - 2^{-(n+1)}`,
  which localises the odd-dimensional maximum inside an interval of length `2^{-(n+1)}` and
  in particular shows that it is *not* the even-dimensional value.
-/

namespace AffineParityOddLower

open Finset AffineStats AffineParityGap AffineParityBent

section OneDegenerate

variable {n : ℕ}

/-- **The exact odd-intersection probability of an "almost perfectly balanced" set.**
Suppose one nonzero direction `e` is a period of `A` (so its derivative set is empty) while
every other nonzero direction has a balanced derivative set.  Then a random affine `2`-cube
meets `A` in an odd number of points with probability exactly `1/2 - 2^{-n}`, one notch
below the absolute bound `1/2 - 2^{-(n+1)}`. -/
theorem oddProb_eq_of_balanced_except (A : Finset (Vec n)) (e : Vec n) (he : e ≠ 0)
    (hdeg : ∀ c : Vec n, (c ∈ A) ↔ (c + e ∈ A))
    (hbal : ∀ w : Vec n, w ≠ 0 → w ≠ e →
      2 * (univ.filter fun c : Vec n => ¬ ((c ∈ A) ↔ (c + w ∈ A))).card = 2 ^ n) :
    oddProb n 2 A = 1 / 2 - 1 / 2 ^ n := by
  classical
  -- the ambient dimension is positive
  have hn : 1 ≤ n := by
    rcases Nat.eq_zero_or_pos n with h | h
    · subst h; exact absurd (funext fun i => i.elim0) he
    · exact h
  have h2n : (2 : ℕ) ≤ 2 ^ n := by
    calc (2 : ℕ) = 2 ^ 1 := (pow_one 2).symm
      _ ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
  -- the contribution of a single direction
  have hterm : ∀ w : Fin 1 → Vec n,
      ((univ.filter fun p : Vec n × Vec n =>
        ¬ (2 ∣ (cnt A p.1 w + cnt A (p.1 + p.2) w))).card : ℚ)
        = if w 0 = 0 ∨ w 0 = e then 0 else 2 ^ (2 * n) / 2 := by
    intro w
    have hw : w = fun _ : Fin 1 => w 0 := by funext i; rw [Subsingleton.elim i 0]
    rw [card_pairs_eq]
    by_cases h0 : w 0 = 0 ∨ w 0 = e
    · rw [if_pos h0]
      have hempty : oddBase A w = ∅ := by
        rcases h0 with h0 | h0
        · have : ¬ Indep w := by
            rw [hw, h0]
            exact not_indep_zero (n := n) (d := 1) one_pos
          exact oddBase_eq_empty_of_not_indep A this
        · rw [hw, h0, oddBase_one_dir, Finset.filter_eq_empty_iff]
          intro c _
          simpa using hdeg c
      rw [hempty]
      simp
    · rw [if_neg h0]
      push_neg at h0
      have hcard : 2 * (oddBase A w).card = 2 ^ n := by
        rw [hw, oddBase_one_dir]
        exact hbal (w 0) h0.1 h0.2
      have hk : ((oddBase A w).card : ℚ) = 2 ^ n / 2 := by
        have : (2 : ℚ) * (oddBase A w).card = 2 ^ n := by exact_mod_cast hcard
        linarith
      have hle : (oddBase A w).card ≤ 2 ^ n := by omega
      have hcast : ((2 * ((oddBase A w).card * (2 ^ n - (oddBase A w).card)) : ℕ) : ℚ)
          = 2 * (((oddBase A w).card : ℚ) * ((2 : ℚ) ^ n - (oddBase A w).card)) := by
        push_cast [Nat.cast_sub hle]
        ring
      rw [hcast, hk, two_mul n, pow_add]
      ring
  -- sum over the single direction
  have hsum : ((oddSet n 2 A).card : ℚ)
      = ∑ w : Fin 1 → Vec n, (if w 0 = 0 ∨ w 0 = e then 0 else (2 : ℚ) ^ (2 * n) / 2) := by
    have key : (oddSet n 2 A).card = ∑ w : Fin 1 → Vec n,
        (univ.filter fun p : Vec n × Vec n =>
          ¬ (2 ∣ (cnt A p.1 w + cnt A (p.1 + p.2) w))).card := oddSet_card_eq_sum A
    rw [key]
    push_cast
    exact Finset.sum_congr rfl fun w _ => hterm w
  have hcount : ∑ w : Fin 1 → Vec n, (if w 0 = 0 ∨ w 0 = e then 0 else (2 : ℚ) ^ (2 * n) / 2)
      = ((2 : ℚ) ^ n - 2) * ((2 : ℚ) ^ (2 * n) / 2) := by
    rw [Fintype.sum_equiv (Equiv.funUnique (Fin 1) (Vec n))
      (fun w : Fin 1 → Vec n => if w 0 = 0 ∨ w 0 = e then 0 else (2 : ℚ) ^ (2 * n) / 2)
      (fun v : Vec n => if v = 0 ∨ v = e then 0 else (2 : ℚ) ^ (2 * n) / 2) (fun w => rfl)]
    rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const]
    have hpair : (univ.filter fun v : Vec n => v = 0 ∨ v = e) = ({0, e} : Finset (Vec n)) := by
      ext v
      simp [Finset.mem_insert]
    have h1 : (univ.filter fun v : Vec n => v = 0 ∨ v = e).card = 2 := by
      rw [hpair]
      exact Finset.card_pair (Ne.symm he)
    have h2 : (univ.filter fun v : Vec n => ¬ (v = 0 ∨ v = e)).card = 2 ^ n - 2 := by
      have := Finset.card_filter_add_card_filter_not (s := (univ : Finset (Vec n)))
        (p := fun v : Vec n => v = 0 ∨ v = e)
      rw [h1, Finset.card_univ, card_Vec] at this
      omega
    have hc : ((2 ^ n - 2 : ℕ) : ℚ) = (2 : ℚ) ^ n - 2 := by
      rw [Nat.cast_sub h2n]; push_cast; ring
    rw [h1, h2]
    simp only [nsmul_eq_mul, hc]
    ring
  rw [oddProb, hsum, hcount]
  rw [show n * (2 + 1) = n + (2 * n) from by ring, pow_add]
  have hne : ((2 : ℚ) ^ n) ≠ 0 := by positivity
  have hne' : ((2 : ℚ) ^ (2 * n)) ≠ 0 := by positivity
  field_simp

end OneDegenerate

section Pullback

/-- Counting membership of the tail in `𝔽₂^{k+1}`: each value of the tail is hit by exactly
two vectors. -/
lemma card_tail_mem {k : ℕ} (S : Finset (Vec k)) :
    (univ.filter fun x : Vec (k + 1) => Fin.tail x ∈ S).card = 2 * S.card := by
  classical
  have hbij : (univ.filter fun x : Vec (k + 1) => Fin.tail x ∈ S).card
      = ((univ : Finset (ZMod 2)) ×ˢ S).card := by
    refine Finset.card_nbij' (fun x => (x 0, Fin.tail x)) (fun p => Fin.cons p.1 p.2) ?_ ?_ ?_ ?_
    · intro x hx
      simpa using hx
    · intro p hp
      simpa [Fin.tail_cons] using hp
    · intro x _
      exact Fin.cons_self_tail x
    · intro p _
      exact Prod.ext (by simp) (by simp [Fin.tail_cons])
  rw [hbij, Finset.card_product]
  simp

variable {m : ℕ}

/-- The pullback of the standard bent set of `𝔽₂^{2m}` to `𝔽₂^{2m+1}` along the projection
that forgets the first coordinate. -/
def liftSet (m : ℕ) : Finset (Vec (m + m + 1)) :=
  univ.filter fun x => bentFun (Fin.tail x) = 1

lemma mem_liftSet {x : Vec (m + m + 1)} : x ∈ liftSet m ↔ bentFun (Fin.tail x) = 1 := by
  simp [liftSet]

lemma tail_add (x y : Vec (m + m + 1)) : Fin.tail (x + y) = Fin.tail x + Fin.tail y := rfl

/-- The direction forgotten by the projection. -/
def e₀ (m : ℕ) : Vec (m + m + 1) := fun i => if i = 0 then 1 else 0

lemma e₀_ne_zero : e₀ m ≠ 0 := by
  intro h
  have := congrFun h 0
  simp [e₀] at this

lemma tail_e₀ : Fin.tail (e₀ m) = 0 := by
  funext i
  simp [Fin.tail, e₀, Fin.succ_ne_zero]

/-- `e₀` is a period of the pullback set. -/
lemma liftSet_period (c : Vec (m + m + 1)) : (c ∈ liftSet m) ↔ (c + e₀ m ∈ liftSet m) := by
  rw [mem_liftSet, mem_liftSet, tail_add, tail_e₀, add_zero]

/-- A vector of `𝔽₂^{k+1}` with vanishing tail is `0` or the first basis vector. -/
lemma eq_zero_or_e₀ {w : Vec (m + m + 1)} (hw : Fin.tail w = 0) : w = 0 ∨ w = e₀ m := by
  have hcoord : ∀ i : Fin (m + m), w i.succ = 0 := fun i => congrFun hw i
  have h0 : w 0 = 0 ∨ w 0 = 1 := by
    generalize w 0 = t
    revert t
    decide
  rcases h0 with h0 | h0
  · left
    funext j
    refine Fin.cases ?_ ?_ j
    · exact h0
    · intro i; exact hcoord i
  · right
    funext j
    refine Fin.cases ?_ ?_ j
    · simpa [e₀] using h0
    · intro i
      rw [hcoord i]
      simp [e₀, Fin.succ_ne_zero]

/-- Every direction other than `0` and `e₀` has a balanced derivative set. -/
lemma liftSet_balanced (w : Vec (m + m + 1)) (hw0 : w ≠ 0) (hwe : w ≠ e₀ m) :
    2 * (univ.filter fun c : Vec (m + m + 1) =>
      ¬ ((c ∈ liftSet m) ↔ (c + w ∈ liftSet m))).card = 2 ^ (m + m + 1) := by
  have htail : Fin.tail w ≠ 0 := by
    intro h
    rcases eq_zero_or_e₀ h with h' | h'
    · exact hw0 h'
    · exact hwe h'
  have hset : (univ.filter fun c : Vec (m + m + 1) =>
      ¬ ((c ∈ liftSet m) ↔ (c + w ∈ liftSet m)))
      = univ.filter fun c : Vec (m + m + 1) => Fin.tail c ∈
          (univ.filter fun y : Vec (m + m) =>
            ¬ ((y ∈ bentSet m) ↔ (y + Fin.tail w ∈ bentSet m))) := by
    refine Finset.filter_congr fun c _ => ?_
    simp only [mem_liftSet, bentSet, Finset.mem_filter, Finset.mem_univ, true_and, tail_add]
  rw [hset, card_tail_mem]
  have hbal := bentSet_balanced (m := m) (Fin.tail w) htail
  rw [show (2 : ℕ) ^ (m + m + 1) = 2 * 2 ^ (m + m) from by ring]
  omega

/-- **The pullback of a bent set attains `1/2 - 2^{-n}` in odd dimension `n = 2m+1`.** -/
theorem oddProb_liftSet (m : ℕ) :
    oddProb (m + m + 1) 2 (liftSet m) = 1 / 2 - 1 / 2 ^ (m + m + 1) :=
  oddProb_eq_of_balanced_except (liftSet m) (e₀ m) e₀_ne_zero liftSet_period liftSet_balanced

/-- The maximum for affine `2`-cubes in dimension `2m+1` is at least `1/2 - 2^{-(2m+1)}`. -/
theorem maxOddProb_two_ge (m : ℕ) :
    1 / 2 - 1 / 2 ^ (m + m + 1) ≤ maxOddProb (m + m + 1) 2 := by
  rw [← oddProb_liftSet m]
  exact Finset.le_sup' (fun A => oddProb (m + m + 1) 2 A) (mem_univ _)

/-- **The odd-dimensional lower bound.** For every odd `n`, `maxOddProb n 2 ≥ 1/2 - 2^{-n}`. -/
theorem maxOddProb_two_ge_of_odd {n : ℕ} (hodd : ¬ Even n) :
    1 / 2 - 1 / 2 ^ n ≤ maxOddProb n 2 := by
  obtain ⟨m, hm⟩ : ∃ m, n = m + m + 1 := by
    rcases Nat.even_or_odd n with h | h
    · exact absurd h hodd
    · obtain ⟨k, hk⟩ := h
      exact ⟨k, by omega⟩
  subst hm
  exact maxOddProb_two_ge m

/-- **The odd-dimensional maximum, localised.** For odd `n`,
`1/2 - 2^{-n} ≤ maxOddProb n 2 < 1/2 - 2^{-(n+1)}`: the even-dimensional value
`1/2 - 2^{-(n+1)}` is not attained, but the pullback construction comes within `2^{-(n+1)}`
of it. -/
theorem maxOddProb_two_odd_bounds {n : ℕ} (hodd : ¬ Even n) :
    1 / 2 - 1 / 2 ^ n ≤ maxOddProb n 2 ∧ maxOddProb n 2 < 1 / 2 - 1 / 2 ^ (n + 1) :=
  ⟨maxOddProb_two_ge_of_odd hodd, AffineParityOdd.maxOddProb_two_lt_of_odd hodd⟩

/-- **A uniform lower bound in every dimension.** For every `n ≥ 1`,
`maxOddProb n 2 ≥ 1/2 - 2^{-n}`: bent sets do it in even dimension, their pullbacks in odd
dimension. -/
theorem maxOddProb_two_ge_general {n : ℕ} (hn : 1 ≤ n) :
    1 / 2 - 1 / 2 ^ n ≤ maxOddProb n 2 := by
  rcases Nat.even_or_odd n with h | h
  · obtain ⟨m, hm⟩ := h
    have hm' : n = m + m := hm
    subst hm'
    rw [maxOddProb_two_eq m]
    have h1 : (1 : ℚ) / 2 ^ (m + m + 1) ≤ 1 / 2 ^ (m + m) := by
      apply one_div_le_one_div_of_le (by positivity)
      exact pow_le_pow_right₀ (by norm_num) (Nat.le_succ _)
    linarith
  · exact maxOddProb_two_ge_of_odd (by simpa [Nat.not_even_iff_odd] using h)

/-- **The size of the gap for affine `2`-cubes.** For every `n ≥ 1`,
`2^{-(n+1)} ≤ 1/2 - maxOddProb n 2 ≤ 2^{-n}`, so the deficiency from the parity bound `1/2`
is exactly of order `2^{-n}`. -/
theorem gap_two_bounds {n : ℕ} (hn : 1 ≤ n) :
    1 / 2 ^ (n + 1) ≤ 1 / 2 - maxOddProb n 2 ∧ 1 / 2 - maxOddProb n 2 ≤ 1 / 2 ^ n := by
  constructor
  · have hup : maxOddProb n 2 ≤ 1 / 2 - 1 / 2 ^ (n + 1) := by
      refine Finset.sup'_le _ _ fun A _ => ?_
      simpa using oddProb_le_half_sub (n := n) (d := 1) A one_pos
    linarith
  · have := maxOddProb_two_ge_general hn
    linarith

/-- For `n = 3` the two bounds read `3/8 ≤ maxOddProb 3 2 < 7/16`. -/
theorem maxOddProb_three_bounds :
    3 / 8 ≤ maxOddProb 3 2 ∧ maxOddProb 3 2 < 7 / 16 := by
  have h := maxOddProb_two_odd_bounds (n := 3) (by decide)
  norm_num at h
  exact h

end Pullback

end AffineParityOddLower