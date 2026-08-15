/-
# Breaking the one-bit binary-fork cap

The symmetric semiprime forks previously studied are *binary* read-outs, and a
binary symmetric fork carries at most one bit.  The splitting type of a cyclic
field is **multi-state**, and this file proves that its type-pair channel
strictly exceeds the one-bit cap for every cyclic order `n ∈ {4,6,10,12,16}`,
while the quadratic case `n = 2` sits exactly at the cap.

It also proves the two *lossiness* statements that isolate the type as the
complete object:

* the root-count read-out (`splits completely?`) is a strictly coarser channel
  than the full type, already at `n = 4` and `n = 6`;
* the split-count `s`-projection of a semiprime type pair carries strictly less
  than the full type pair.
-/
import Shared.CyclicTypeChannelValues

namespace CyclicTypeChannel

open Finset

set_option maxRecDepth 100000

/-! ## 1. The type-pair channel exceeds one bit -/

/-- `C₂` (the quadratic case) sits exactly at the binary-fork cap. -/
theorem Ipair_two_eq_cap : Ipair 2 = 1 := Ipair_val_2

/-- **`C₄ = Q(ζ₅)` carries `5/4 > 1` bits.** -/
theorem one_lt_Ipair_four : 1 < Ipair 4 := by
  rw [Ipair_val_4]; norm_num

/-- **`C₆ = Q(ζ₇)` carries `log₂ 3 - 1/9 > 1` bits.** -/
theorem one_lt_Ipair_six : 1 < Ipair 6 := by
  rw [Ipair_val_6]
  have := lb_three_gt
  linarith

/-- **`C₁₀ = Q(ζ₁₁)` carries more than one bit.** -/
theorem one_lt_Ipair_ten : 1 < Ipair 10 := by
  rw [Ipair_val_10]
  have h3 := lb_three_gt
  have h5 := lb_five_gt
  linarith

/-- **`C₁₂ = Q(ζ₁₃)` carries more than one bit.** -/
theorem one_lt_Ipair_twelve : 1 < Ipair 12 := by
  rw [Ipair_val_12]
  have := lb_three_gt
  linarith

/-- **`C₁₆ = Q(ζ₁₇)` carries `85/64 > 1` bits.** -/
theorem one_lt_Ipair_sixteen : 1 < Ipair 16 := by
  rw [Ipair_val_16]; norm_num

/-- **No one-bit cap.** Every cyclic order in the computed range beyond the
quadratic case breaks the binary-fork cap. -/
theorem above_binary_cap : ∀ n ∈ ({4, 6, 10, 12, 16} : Finset ℕ), 1 < Ipair n := by
  intro n hn
  fin_cases hn
  · exact one_lt_Ipair_four
  · exact one_lt_Ipair_six
  · exact one_lt_Ipair_ten
  · exact one_lt_Ipair_twelve
  · exact one_lt_Ipair_sixteen

/-- **Divisor richness, not size, governs the channel.** Among the computed
cyclic orders, `n = 12` (six splitting types) is strictly the richest — it beats
`n = 16`, which has a larger group but only five types. -/
theorem Ipair_twelve_max :
    Ipair 2 < Ipair 12 ∧ Ipair 4 < Ipair 12 ∧ Ipair 6 < Ipair 12 ∧
      Ipair 10 < Ipair 12 ∧ Ipair 16 < Ipair 12 := by
  have h3 := lb_three_gt
  have h5 := lb_five_gt
  have h5' := lb_five_lt
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · rw [Ipair_val_2, Ipair_val_12]; linarith
  · rw [Ipair_val_4, Ipair_val_12]; linarith
  · rw [Ipair_val_6, Ipair_val_12]; linarith
  · rw [Ipair_val_10, Ipair_val_12]; linarith
  · rw [Ipair_val_16, Ipair_val_12]; linarith

/-! ## 2. The root-count read-out is strictly lossy -/

/-- The root-count channel of `C₄`: the binary entropy `H(1/4)`. -/
theorem rootCountEntropy_val_4 :
    uEnt (range 4) (rootCount 4 ∘ ordType 4) = 2 - (3 / 4 : ℝ) * Real.logb 2 3 := by
  have h : ((range 4).image (rootCount 4 ∘ ordType 4)).val.map
      (fun v => (#{x ∈ range 4 | (rootCount 4 ∘ ordType 4) x = v} : ℕ))
      = (↑[1, 3] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h, show (range 4).card = 4 from by decide]
  norm_num [lb_4]
  ring

/-- The root-count channel of `C₆`: the binary entropy `H(1/6)`. -/
theorem rootCountEntropy_val_6 :
    uEnt (range 6) (rootCount 6 ∘ ordType 6)
      = 1 + Real.logb 2 3 - (5 / 6 : ℝ) * Real.logb 2 5 := by
  have h : ((range 6).image (rootCount 6 ∘ ordType 6)).val.map
      (fun v => (#{x ∈ range 6 | (rootCount 6 ∘ ordType 6) x = v} : ℕ))
      = (↑[1, 5] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h, show (range 6).card = 6 from by decide]
  norm_num [lb_6]
  ring

/-- **Root-count lossiness at `C₄`:** the binary read-out `H(1/4) ≈ 0.811`
is strictly below the three-state type entropy `3/2`. -/
theorem rootCount_lossy_4 : uEnt (range 4) (rootCount 4 ∘ ordType 4) < typeEntropy 4 := by
  rw [rootCountEntropy_val_4, typeEntropy_val_4]
  have := lb_three_gt
  linarith

/-- **Root-count lossiness at `C₆`:** `H(1/6) ≈ 0.650` is strictly below the
four-state type entropy `1/3 + log₂ 3 ≈ 1.918`. -/
theorem rootCount_lossy_6 : uEnt (range 6) (rootCount 6 ∘ ordType 6) < typeEntropy 6 := by
  rw [rootCountEntropy_val_6, typeEntropy_val_6]
  have := lb_five_gt
  linarith

/-! ## 3. The split-count `s`-projection is strictly lossy -/

theorem sProjEntropy_val_4 :
    uEnt (box 4) (sProj ∘ typePair 4) = (29 / 8 : ℝ) - (3 / 2 : ℝ) * Real.logb 2 3 := by
  have h : ((box 4).image (sProj ∘ typePair 4)).val.map
      (fun v => (#{q ∈ box 4 | (sProj ∘ typePair 4) q = v} : ℕ))
      = (↑[1, 6, 9] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h, show (box 4).card = 16 from by decide]
  norm_num [lb_6, lb_9, lb_16]
  ring

theorem condSProjEntropy_val_4 :
    condEnt (box 4) (sProj ∘ typePair 4) (prodRes 4)
      = (5 / 4 : ℝ) - (3 / 16 : ℝ) * Real.logb 2 3 := by
  have himg : (box 4).image (prodRes 4) = range 4 := by decide
  have e0 : uEnt {x ∈ box 4 | prodRes 4 x = 0} (sProj ∘ typePair 4)
      = 2 - (3 / 4 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 4 | prodRes 4 x = 0}).image (sProj ∘ typePair 4)).val.map
        (fun v => (#{q ∈ {x ∈ box 4 | prodRes 4 x = 0} | (sProj ∘ typePair 4) q = v} : ℕ))
        = (↑[1, 3] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, show (#{x ∈ box 4 | prodRes 4 x = 0}) = 4 from by decide]
    norm_num [lb_4]
    ring
  have e1 : uEnt {x ∈ box 4 | prodRes 4 x = 1} (sProj ∘ typePair 4) = 1 := by
    have h : (({x ∈ box 4 | prodRes 4 x = 1}).image (sProj ∘ typePair 4)).val.map
        (fun v => (#{q ∈ {x ∈ box 4 | prodRes 4 x = 1} | (sProj ∘ typePair 4) q = v} : ℕ))
        = (↑[2, 2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, show (#{x ∈ box 4 | prodRes 4 x = 1}) = 4 from by decide]
    norm_num [lb_4]
  have e2 : uEnt {x ∈ box 4 | prodRes 4 x = 2} (sProj ∘ typePair 4) = 1 := by
    have h : (({x ∈ box 4 | prodRes 4 x = 2}).image (sProj ∘ typePair 4)).val.map
        (fun v => (#{q ∈ {x ∈ box 4 | prodRes 4 x = 2} | (sProj ∘ typePair 4) q = v} : ℕ))
        = (↑[2, 2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, show (#{x ∈ box 4 | prodRes 4 x = 2}) = 4 from by decide]
    norm_num [lb_4]
  have e3 : uEnt {x ∈ box 4 | prodRes 4 x = 3} (sProj ∘ typePair 4) = 1 := by
    have h : (({x ∈ box 4 | prodRes 4 x = 3}).image (sProj ∘ typePair 4)).val.map
        (fun v => (#{q ∈ {x ∈ box 4 | prodRes 4 x = 3} | (sProj ∘ typePair 4) q = v} : ℕ))
        = (↑[2, 2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, show (#{x ∈ box 4 | prodRes 4 x = 3}) = 4 from by decide]
    norm_num [lb_4]
  rw [condEnt, himg, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_one, e0, e1, e2, e3]
  norm_num [show (box 4).card = 16 from by decide,
    show (#{x ∈ box 4 | prodRes 4 x = 0}) = 4 from by decide,
    show (#{x ∈ box 4 | prodRes 4 x = 1}) = 4 from by decide,
    show (#{x ∈ box 4 | prodRes 4 x = 2}) = 4 from by decide,
    show (#{x ∈ box 4 | prodRes 4 x = 3}) = 4 from by decide]
  ring

/-- The exact split-count channel of a `C₄` semiprime: `Is(4) = 19/8 - (21/16) log₂ 3
≈ 0.2947`, exactly the value measured for the split-count fork. -/
theorem Isplit_val_4 : Isplit 4 = (19 / 8 : ℝ) - (21 / 16 : ℝ) * Real.logb 2 3 := by
  rw [Isplit_eq, sProjEntropy_val_4, condSProjEntropy_val_4]
  ring

/-- **The split count is only one face of the type channel**: at `C₄` the
`s`-projection retains `0.29` of the `1.25` bits carried by the full type pair. -/
theorem Isplit_lt_Ipair_4 : Isplit 4 < Ipair 4 := by
  rw [Isplit_val_4, Ipair_val_4]
  have := lb_three_gt
  linarith

theorem sProjEntropy_val_6 :
    uEnt (box 6) (sProj ∘ typePair 6)
      = (31 / 18 : ℝ) + 2 * Real.logb 2 3 - (5 / 3 : ℝ) * Real.logb 2 5 := by
  have h : ((box 6).image (sProj ∘ typePair 6)).val.map
      (fun v => (#{q ∈ box 6 | (sProj ∘ typePair 6) q = v} : ℕ))
      = (↑[1, 10, 25] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h, show (box 6).card = 36 from by decide]
  norm_num [lb_36, lb_10, lb_25]
  ring

theorem condSProjEntropy_val_6 :
    condEnt (box 6) (sProj ∘ typePair 6) (prodRes 6)
      = -(7 / 18 : ℝ) + Real.logb 2 3 - (5 / 36 : ℝ) * Real.logb 2 5 := by
  have himg : (box 6).image (prodRes 6) = range 6 := by decide
  have e0 : uEnt {x ∈ box 6 | prodRes 6 x = 0} (sProj ∘ typePair 6)
      = 1 + Real.logb 2 3 - (5 / 6 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 6 | prodRes 6 x = 0}).image (sProj ∘ typePair 6)).val.map
        (fun v => (#{q ∈ {x ∈ box 6 | prodRes 6 x = 0} | (sProj ∘ typePair 6) q = v} : ℕ))
        = (↑[1, 5] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, show (#{x ∈ box 6 | prodRes 6 x = 0}) = 6 from by decide]
    norm_num [lb_6]
    ring
  have e1 : uEnt {x ∈ box 6 | prodRes 6 x = 1} (sProj ∘ typePair 6)
      = -(2 / 3 : ℝ) + Real.logb 2 3 := by
    have h : (({x ∈ box 6 | prodRes 6 x = 1}).image (sProj ∘ typePair 6)).val.map
        (fun v => (#{q ∈ {x ∈ box 6 | prodRes 6 x = 1} | (sProj ∘ typePair 6) q = v} : ℕ))
        = (↑[2, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, show (#{x ∈ box 6 | prodRes 6 x = 1}) = 6 from by decide]
    norm_num [lb_6, lb_4]
    ring
  have e2 : uEnt {x ∈ box 6 | prodRes 6 x = 2} (sProj ∘ typePair 6)
      = -(2 / 3 : ℝ) + Real.logb 2 3 := by
    have h : (({x ∈ box 6 | prodRes 6 x = 2}).image (sProj ∘ typePair 6)).val.map
        (fun v => (#{q ∈ {x ∈ box 6 | prodRes 6 x = 2} | (sProj ∘ typePair 6) q = v} : ℕ))
        = (↑[2, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, show (#{x ∈ box 6 | prodRes 6 x = 2}) = 6 from by decide]
    norm_num [lb_6, lb_4]
    ring
  have e3 : uEnt {x ∈ box 6 | prodRes 6 x = 3} (sProj ∘ typePair 6)
      = -(2 / 3 : ℝ) + Real.logb 2 3 := by
    have h : (({x ∈ box 6 | prodRes 6 x = 3}).image (sProj ∘ typePair 6)).val.map
        (fun v => (#{q ∈ {x ∈ box 6 | prodRes 6 x = 3} | (sProj ∘ typePair 6) q = v} : ℕ))
        = (↑[2, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, show (#{x ∈ box 6 | prodRes 6 x = 3}) = 6 from by decide]
    norm_num [lb_6, lb_4]
    ring
  have e4 : uEnt {x ∈ box 6 | prodRes 6 x = 4} (sProj ∘ typePair 6)
      = -(2 / 3 : ℝ) + Real.logb 2 3 := by
    have h : (({x ∈ box 6 | prodRes 6 x = 4}).image (sProj ∘ typePair 6)).val.map
        (fun v => (#{q ∈ {x ∈ box 6 | prodRes 6 x = 4} | (sProj ∘ typePair 6) q = v} : ℕ))
        = (↑[2, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, show (#{x ∈ box 6 | prodRes 6 x = 4}) = 6 from by decide]
    norm_num [lb_6, lb_4]
    ring
  have e5 : uEnt {x ∈ box 6 | prodRes 6 x = 5} (sProj ∘ typePair 6)
      = -(2 / 3 : ℝ) + Real.logb 2 3 := by
    have h : (({x ∈ box 6 | prodRes 6 x = 5}).image (sProj ∘ typePair 6)).val.map
        (fun v => (#{q ∈ {x ∈ box 6 | prodRes 6 x = 5} | (sProj ∘ typePair 6) q = v} : ℕ))
        = (↑[2, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, show (#{x ∈ box 6 | prodRes 6 x = 5}) = 6 from by decide]
    norm_num [lb_6, lb_4]
    ring
  rw [condEnt, himg, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one, e0, e1, e2, e3, e4, e5]
  norm_num [show (box 6).card = 36 from by decide,
    show (#{x ∈ box 6 | prodRes 6 x = 0}) = 6 from by decide,
    show (#{x ∈ box 6 | prodRes 6 x = 1}) = 6 from by decide,
    show (#{x ∈ box 6 | prodRes 6 x = 2}) = 6 from by decide,
    show (#{x ∈ box 6 | prodRes 6 x = 3}) = 6 from by decide,
    show (#{x ∈ box 6 | prodRes 6 x = 4}) = 6 from by decide,
    show (#{x ∈ box 6 | prodRes 6 x = 5}) = 6 from by decide]
  ring

/-- The exact split-count channel of a `C₆` semiprime: `Is(6) ≈ 0.1487`. -/
theorem Isplit_val_6 :
    Isplit 6 = (19 / 9 : ℝ) + Real.logb 2 3 - (55 / 36 : ℝ) * Real.logb 2 5 := by
  rw [Isplit_eq, sProjEntropy_val_6, condSProjEntropy_val_6]
  ring

/-- At `C₆` the split-count projection retains only `0.15` of the `1.47` bits of
the type-pair channel. -/
theorem Isplit_lt_Ipair_6 : Isplit 6 < Ipair 6 := by
  rw [Isplit_val_6, Ipair_val_6]
  have := lb_five_gt
  linarith

/-- **The one-bit cap is a feature of binary read-outs, not of symmetry.** Both
lossy binary read-outs of the `C₄` channel stay below one bit, while the full
multi-state type pair carries `5/4`. -/
theorem binary_readouts_below_cap_four :
    uEnt (range 4) (rootCount 4 ∘ ordType 4) < 1 ∧ Isplit 4 < 1 ∧ 1 < Ipair 4 := by
  have h3 := lb_three_gt
  refine ⟨?_, ?_, one_lt_Ipair_four⟩
  · rw [rootCountEntropy_val_4]; linarith
  · rw [Isplit_val_4]; linarith

end CyclicTypeChannel