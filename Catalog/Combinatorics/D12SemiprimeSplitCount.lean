/-
# The degree-12 semiprime split-count channel

This file completes the *semiprime* arm of the degree-12 (`C₁₂ = Gal(Q(ζ₁₃)/Q)`)
splitting-type analysis started in `Shared.CyclicTypeChannelValues` and
`Shared.CyclicTypeChannelCap`.

There the exact type-pair channel of a `C₁₂` semiprime was computed,

  `I_pair(12) = 5/36 + log₂ 3 ≈ 1.7239` bits,

and the split-count (`s`-projection) channel was evaluated only at `n = 4` and
`n = 6`.  Here we close the `n = 12` case:

  `I_split(12) = 199/72 + log₂ 3 + (55/72) log₂ 5 - (253/144) log₂ 11 ≈ 0.0445` bits.

The three headline consequences are

* `Isplit_pos_twelve`   : the split-count read-out is *not* a wall — it leaks a
  strictly positive amount of information;
* `Isplit_lt_eighth_twelve` : but it leaks less than an eighth of a bit;
* `Isplit_lt_tenth_Ipair_twelve` : it retains less than one tenth of the
  information carried by the full type pair.

The arithmetic input is the fibre profile of the split count over the residue
classes of `N = p q` mod 13, which is remarkably rigid: the class `N ≡ 1`
(residue `0` in exponent coordinates) has profile `(1, 11)` while all eleven
other classes have the identical profile `(2, 10)`.  This rigidity is what makes
the `log₂ 11` term appear with the isolated coefficient `-253/144`.
-/
import Shared.CyclicTypeChannelCap

namespace CyclicTypeChannel

open Finset

set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000

/-! ## 1. The base-two logarithms of the numerals that occur -/

lemma lb_22 : Real.logb 2 (22 : ℝ) = 1 + Real.logb 2 11 := by
  rw [show (22 : ℝ) = 2 * 11 by norm_num, Real.logb_mul (by norm_num) (by norm_num)]
  simp

lemma lb_121 : Real.logb 2 (121 : ℝ) = 2 * Real.logb 2 11 := by
  rw [show (121 : ℝ) = 11 ^ (2 : ℕ) by norm_num, Real.logb_pow]
  norm_num

/-- `log₂ 3 > 19/12`, i.e. `3 ^ 12 = 531441 > 524288 = 2 ^ 19`.  This sharpens
`lb_three_gt` (which only gives `3/2`) and is needed for the positivity of the
split-count channel. -/
lemma lb_three_gt' : (19 : ℝ) / 12 < Real.logb 2 3 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log ((2 : ℝ) ^ (19 : ℕ)) < Real.log ((3 : ℝ) ^ (12 : ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, lt_div_iff₀ h2]
  push_cast at h
  linarith

/-- `log₂ 3 < 27/17`, i.e. `3 ^ 17 = 129140163 < 134217728 = 2 ^ 27`. -/
lemma lb_three_lt' : Real.logb 2 3 < (27 : ℝ) / 17 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log ((3 : ℝ) ^ (17 : ℕ)) < Real.log ((2 : ℝ) ^ (27 : ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, div_lt_iff₀ h2]
  push_cast at h
  linarith

/-- `log₂ 11 > 24/7`, i.e. `11 ^ 7 = 19487171 > 16777216 = 2 ^ 24`. -/
lemma lb_eleven_gt : (24 : ℝ) / 7 < Real.logb 2 11 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log ((2 : ℝ) ^ (24 : ℕ)) < Real.log ((11 : ℝ) ^ (7 : ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, lt_div_iff₀ h2]
  push_cast at h
  linarith

/-- `log₂ 11 < 45/13`, i.e. `11 ^ 13 = 34522712143931 < 35184372088832 = 2 ^ 45`. -/
lemma lb_eleven_lt : Real.logb 2 11 < (45 : ℝ) / 13 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log ((11 : ℝ) ^ (13 : ℕ)) < Real.log ((2 : ℝ) ^ (45 : ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, div_lt_iff₀ h2]
  push_cast at h
  linarith

/-! ## 2. The unconditional split-count entropy at `n = 12`

Over the `144` exponent pairs the split count `s ∈ {0,1,2}` has the profile
`(121, 22, 1)`: exactly one pair of primes both split completely, `22` pairs
have exactly one completely split factor, and the remaining `121` have none. -/

theorem sProjEntropy_val_12 :
    uEnt (box 12) (sProj ∘ typePair 12)
      = (277 / 72 : ℝ) + 2 * Real.logb 2 3 - (11 / 6 : ℝ) * Real.logb 2 11 := by
  have h : ((box 12).image (sProj ∘ typePair 12)).val.map
      (fun v => (#{q ∈ box 12 | (sProj ∘ typePair 12) q = v} : ℕ))
      = (↑[1, 22, 121] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h, show (box 12).card = 144 from by decide]
  norm_num [lb_144, lb_22, lb_121]
  ring

/-! ## 3. The conditional split-count entropy given `N mod 13` -/

theorem condSProjEntropy_val_12 :
    condEnt (box 12) (sProj ∘ typePair 12) (prodRes 12)
      = (13 / 12 : ℝ) + Real.logb 2 3 - (11 / 144 : ℝ) * Real.logb 2 11
        - (55 / 72 : ℝ) * Real.logb 2 5 := by
  have himg : (box 12).image (prodRes 12) = range 12 := by decide
  have e0 : uEnt {x ∈ box 12 | prodRes 12 x = 0} (sProj ∘ typePair 12)
      = 2 + Real.logb 2 3 - (11 / 12 : ℝ) * Real.logb 2 11 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 0}).image (sProj ∘ typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 0} | (sProj ∘ typePair 12) q = v} : ℕ))
        = (↑[1, 11] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 0}) = 12 from by decide]
    norm_num [lb_12]
    ring
  have e1 : uEnt {x ∈ box 12 | prodRes 12 x = 1} (sProj ∘ typePair 12)
      = 1 + Real.logb 2 3 - (5 / 6 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 1}).image (sProj ∘ typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 1} | (sProj ∘ typePair 12) q = v} : ℕ))
        = (↑[2, 10] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 1}) = 12 from by decide]
    norm_num [lb_12, lb_10]
    ring
  have e2 : uEnt {x ∈ box 12 | prodRes 12 x = 2} (sProj ∘ typePair 12)
      = 1 + Real.logb 2 3 - (5 / 6 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 2}).image (sProj ∘ typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 2} | (sProj ∘ typePair 12) q = v} : ℕ))
        = (↑[2, 10] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 2}) = 12 from by decide]
    norm_num [lb_12, lb_10]
    ring
  have e3 : uEnt {x ∈ box 12 | prodRes 12 x = 3} (sProj ∘ typePair 12)
      = 1 + Real.logb 2 3 - (5 / 6 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 3}).image (sProj ∘ typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 3} | (sProj ∘ typePair 12) q = v} : ℕ))
        = (↑[2, 10] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 3}) = 12 from by decide]
    norm_num [lb_12, lb_10]
    ring
  have e4 : uEnt {x ∈ box 12 | prodRes 12 x = 4} (sProj ∘ typePair 12)
      = 1 + Real.logb 2 3 - (5 / 6 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 4}).image (sProj ∘ typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 4} | (sProj ∘ typePair 12) q = v} : ℕ))
        = (↑[2, 10] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 4}) = 12 from by decide]
    norm_num [lb_12, lb_10]
    ring
  have e5 : uEnt {x ∈ box 12 | prodRes 12 x = 5} (sProj ∘ typePair 12)
      = 1 + Real.logb 2 3 - (5 / 6 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 5}).image (sProj ∘ typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 5} | (sProj ∘ typePair 12) q = v} : ℕ))
        = (↑[2, 10] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 5}) = 12 from by decide]
    norm_num [lb_12, lb_10]
    ring
  have e6 : uEnt {x ∈ box 12 | prodRes 12 x = 6} (sProj ∘ typePair 12)
      = 1 + Real.logb 2 3 - (5 / 6 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 6}).image (sProj ∘ typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 6} | (sProj ∘ typePair 12) q = v} : ℕ))
        = (↑[2, 10] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 6}) = 12 from by decide]
    norm_num [lb_12, lb_10]
    ring
  have e7 : uEnt {x ∈ box 12 | prodRes 12 x = 7} (sProj ∘ typePair 12)
      = 1 + Real.logb 2 3 - (5 / 6 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 7}).image (sProj ∘ typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 7} | (sProj ∘ typePair 12) q = v} : ℕ))
        = (↑[2, 10] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 7}) = 12 from by decide]
    norm_num [lb_12, lb_10]
    ring
  have e8 : uEnt {x ∈ box 12 | prodRes 12 x = 8} (sProj ∘ typePair 12)
      = 1 + Real.logb 2 3 - (5 / 6 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 8}).image (sProj ∘ typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 8} | (sProj ∘ typePair 12) q = v} : ℕ))
        = (↑[2, 10] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 8}) = 12 from by decide]
    norm_num [lb_12, lb_10]
    ring
  have e9 : uEnt {x ∈ box 12 | prodRes 12 x = 9} (sProj ∘ typePair 12)
      = 1 + Real.logb 2 3 - (5 / 6 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 9}).image (sProj ∘ typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 9} | (sProj ∘ typePair 12) q = v} : ℕ))
        = (↑[2, 10] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 9}) = 12 from by decide]
    norm_num [lb_12, lb_10]
    ring
  have e10 : uEnt {x ∈ box 12 | prodRes 12 x = 10} (sProj ∘ typePair 12)
      = 1 + Real.logb 2 3 - (5 / 6 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 10}).image (sProj ∘ typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 10} | (sProj ∘ typePair 12) q = v} : ℕ))
        = (↑[2, 10] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 10}) = 12 from by decide]
    norm_num [lb_12, lb_10]
    ring
  have e11 : uEnt {x ∈ box 12 | prodRes 12 x = 11} (sProj ∘ typePair 12)
      = 1 + Real.logb 2 3 - (5 / 6 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 11}).image (sProj ∘ typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 11} | (sProj ∘ typePair 12) q = v} : ℕ))
        = (↑[2, 10] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 11}) = 12 from by decide]
    norm_num [lb_12, lb_10]
    ring
  rw [condEnt, himg, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_one, e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11]
  norm_num [show (box 12).card = 144 from by decide,
    show (#{x ∈ box 12 | prodRes 12 x = 0}) = 12 from by decide,
    show (#{x ∈ box 12 | prodRes 12 x = 1}) = 12 from by decide,
    show (#{x ∈ box 12 | prodRes 12 x = 2}) = 12 from by decide,
    show (#{x ∈ box 12 | prodRes 12 x = 3}) = 12 from by decide,
    show (#{x ∈ box 12 | prodRes 12 x = 4}) = 12 from by decide,
    show (#{x ∈ box 12 | prodRes 12 x = 5}) = 12 from by decide,
    show (#{x ∈ box 12 | prodRes 12 x = 6}) = 12 from by decide,
    show (#{x ∈ box 12 | prodRes 12 x = 7}) = 12 from by decide,
    show (#{x ∈ box 12 | prodRes 12 x = 8}) = 12 from by decide,
    show (#{x ∈ box 12 | prodRes 12 x = 9}) = 12 from by decide,
    show (#{x ∈ box 12 | prodRes 12 x = 10}) = 12 from by decide,
    show (#{x ∈ box 12 | prodRes 12 x = 11}) = 12 from by decide]
  ring

/-! ## 4. The degree-12 split-count channel -/

/-- **The exact split-count channel of a `C₁₂` semiprime.**
`I_split(12) = 199/72 + log₂ 3 + (55/72) log₂ 5 - (253/144) log₂ 11 ≈ 0.0445` bits. -/
theorem Isplit_val_12 :
    Isplit 12 = (199 / 72 : ℝ) + Real.logb 2 3 + (55 / 72 : ℝ) * Real.logb 2 5
      - (253 / 144 : ℝ) * Real.logb 2 11 := by
  rw [Isplit_eq, sProjEntropy_val_12, condSProjEntropy_val_12]
  ring

/-- **The split count is not a wall at degree 12**: it leaks a strictly positive
amount of information about `N mod 13`. -/
theorem Isplit_pos_twelve : 0 < Isplit 12 := by
  have h3 := lb_three_gt'
  have h5 := lb_five_gt
  have h11 := lb_eleven_lt
  rw [Isplit_val_12]
  nlinarith [h3, h5, h11]

/-- **But the leak is tiny**: the degree-12 split count carries less than one
eighth of a bit. -/
theorem Isplit_lt_eighth_twelve : Isplit 12 < 1 / 8 := by
  have h3 := lb_three_lt'
  have h5 := lb_five_lt
  have h11 := lb_eleven_gt
  rw [Isplit_val_12]
  nlinarith [h3, h5, h11]

/-- **Split-count lossiness at `C₁₂`**: the `s`-projection is a strictly coarser
channel than the full type pair. -/
theorem Isplit_lt_Ipair_12 : Isplit 12 < Ipair 12 := by
  have h3 := lb_three_gt'
  have h5 := lb_five_lt
  have h11 := lb_eleven_gt
  rw [Isplit_val_12, Ipair_val_12]
  nlinarith [h3, h5, h11]

/-- **Quantitative lossiness**: the split count retains less than one tenth of
the information carried by the full degree-12 type pair. -/
theorem Isplit_lt_tenth_Ipair_twelve : Isplit 12 < Ipair 12 / 10 := by
  have hs := Isplit_lt_eighth_twelve
  have h3 := lb_three_gt'
  rw [Ipair_val_12]
  nlinarith [hs, h3]

/-- **The degree-12 split-count profile is rigid.**  Eleven of the twelve
residue classes of `N` mod 13 have the *identical* split-count profile
`(2, 10)`; only the class of `N ≡ 1` differs, with profile `(1, 11)`.  This is
the combinatorial reason the channel is so thin. -/
theorem splitProfile_rigid_12 :
    ∀ r ∈ Finset.Ico 1 12,
      (({x ∈ box 12 | prodRes 12 x = r}).image (sProj ∘ typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = r} | (sProj ∘ typePair 12) q = v} : ℕ))
        = (↑[2, 10] : Multiset ℕ) := by decide

end CyclicTypeChannel