/-
# Exact values of the cyclic splitting-type channel

Exact, closed-form evaluations of the type channel `H(T)`, the semiprime
type-pair entropy `H(Π)`, the conditional entropy `H(Π | N mod f)` and the
type-pair channel `I_pair = H(Π) - (1/φ(f)) ∑_c H(Π_c)` for the cyclic groups
`C₂, C₄, C₆, C₁₀, C₁₂, C₁₆`, i.e. for the cyclotomic fields
`Q(ζ₃), Q(ζ₅), Q(ζ₇), Q(ζ₁₁), Q(ζ₁₃), Q(ζ₁₇)`.

Every value is obtained from the count form `uEnt_eq_countSum` of the entropy
together with a kernel-checked enumeration of the fibre cardinalities over the
unit group.
-/
import Catalog.Shared.CyclicTypeChannel

namespace CyclicTypeChannel

open Finset

set_option maxRecDepth 100000

/-! ### The `C2` channel: `Q(ζ_3)` -/

/-- Exact type entropy of the `C2` channel. -/
theorem typeEntropy_val_2 : typeEntropy 2 = (1 : ℝ) := by
  have h : ((range 2).image (ordType 2)).val.map
      (fun v => (#{x ∈ range 2 | ordType 2 x = v} : ℕ)) = (↑[1, 1] : Multiset ℕ) := by decide
  rw [typeEntropy, uEnt_eq_countSum _ _ _ h, show (range 2).card = 2 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]

/-- Exact entropy of the unordered type pair of a `C2` semiprime. -/
theorem pairEntropy_val_2 : pairEntropy 2 = (3/2 : ℝ) := by
  have h : ((box 2).image (typePair 2)).val.map
      (fun v => (#{q ∈ box 2 | typePair 2 q = v} : ℕ)) = (↑[1, 1, 2] : Multiset ℕ) := by decide
  rw [pairEntropy, uEnt_eq_countSum _ _ _ h, show (box 2).card = 4 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]

/-- Exact conditional entropy of the type pair given the residue of the product. -/
theorem condPairEntropy_val_2 : condPairEntropy 2 = (1/2 : ℝ) := by
  have himg : (box 2).image (prodRes 2) = range 2 := by decide
  have e0 : uEnt {x ∈ box 2 | prodRes 2 x = 0} (typePair 2) = (1 : ℝ) := by
    have h : (({x ∈ box 2 | prodRes 2 x = 0}).image (typePair 2)).val.map
        (fun v => (#{q ∈ {x ∈ box 2 | prodRes 2 x = 0} | typePair 2 q = v} : ℕ))
        = (↑[1, 1] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 2 | prodRes 2 x = 0}) = 2 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  have e1 : uEnt {x ∈ box 2 | prodRes 2 x = 1} (typePair 2) = (0 : ℝ) := by
    have h : (({x ∈ box 2 | prodRes 2 x = 1}).image (typePair 2)).val.map
        (fun v => (#{q ∈ {x ∈ box 2 | prodRes 2 x = 1} | typePair 2 q = v} : ℕ))
        = (↑[2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 2 | prodRes 2 x = 1}) = 2 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  rw [condPairEntropy, condEnt, himg, Finset.sum_range_succ, Finset.sum_range_one,
    e0, e1]
  norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256, show (box 2).card = 4 from by decide,
    show (#{x ∈ box 2 | prodRes 2 x = 0}) = 2 from by decide,
    show (#{x ∈ box 2 | prodRes 2 x = 1}) = 2 from by decide]

/-- **The `C2` type-pair channel.** -/
theorem Ipair_val_2 : Ipair 2 = (1 : ℝ) := by
  rw [Ipair_eq, pairEntropy_val_2, condPairEntropy_val_2]
  ring

/-! ### The `C4` channel: `Q(ζ_5)` -/

/-- Exact type entropy of the `C4` channel. -/
theorem typeEntropy_val_4 : typeEntropy 4 = (3/2 : ℝ) := by
  have h : ((range 4).image (ordType 4)).val.map
      (fun v => (#{x ∈ range 4 | ordType 4 x = v} : ℕ)) = (↑[1, 1, 2] : Multiset ℕ) := by decide
  rw [typeEntropy, uEnt_eq_countSum _ _ _ h, show (range 4).card = 4 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]

/-- Exact entropy of the unordered type pair of a `C4` semiprime. -/
theorem pairEntropy_val_4 : pairEntropy 4 = (19/8 : ℝ) := by
  have h : ((box 4).image (typePair 4)).val.map
      (fun v => (#{q ∈ box 4 | typePair 4 q = v} : ℕ)) = (↑[1, 1, 2, 4, 4, 4] : Multiset ℕ) := by decide
  rw [pairEntropy, uEnt_eq_countSum _ _ _ h, show (box 4).card = 16 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]

/-- Exact conditional entropy of the type pair given the residue of the product. -/
theorem condPairEntropy_val_4 : condPairEntropy 4 = (9/8 : ℝ) := by
  have himg : (box 4).image (prodRes 4) = range 4 := by decide
  have e0 : uEnt {x ∈ box 4 | prodRes 4 x = 0} (typePair 4) = (3/2 : ℝ) := by
    have h : (({x ∈ box 4 | prodRes 4 x = 0}).image (typePair 4)).val.map
        (fun v => (#{q ∈ {x ∈ box 4 | prodRes 4 x = 0} | typePair 4 q = v} : ℕ))
        = (↑[1, 1, 2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 4 | prodRes 4 x = 0}) = 4 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  have e1 : uEnt {x ∈ box 4 | prodRes 4 x = 1} (typePair 4) = (1 : ℝ) := by
    have h : (({x ∈ box 4 | prodRes 4 x = 1}).image (typePair 4)).val.map
        (fun v => (#{q ∈ {x ∈ box 4 | prodRes 4 x = 1} | typePair 4 q = v} : ℕ))
        = (↑[2, 2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 4 | prodRes 4 x = 1}) = 4 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  have e2 : uEnt {x ∈ box 4 | prodRes 4 x = 2} (typePair 4) = (1 : ℝ) := by
    have h : (({x ∈ box 4 | prodRes 4 x = 2}).image (typePair 4)).val.map
        (fun v => (#{q ∈ {x ∈ box 4 | prodRes 4 x = 2} | typePair 4 q = v} : ℕ))
        = (↑[2, 2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 4 | prodRes 4 x = 2}) = 4 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  have e3 : uEnt {x ∈ box 4 | prodRes 4 x = 3} (typePair 4) = (1 : ℝ) := by
    have h : (({x ∈ box 4 | prodRes 4 x = 3}).image (typePair 4)).val.map
        (fun v => (#{q ∈ {x ∈ box 4 | prodRes 4 x = 3} | typePair 4 q = v} : ℕ))
        = (↑[2, 2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 4 | prodRes 4 x = 3}) = 4 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  rw [condPairEntropy, condEnt, himg, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one,
    e0, e1, e2, e3]
  norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256, show (box 4).card = 16 from by decide,
    show (#{x ∈ box 4 | prodRes 4 x = 0}) = 4 from by decide,
    show (#{x ∈ box 4 | prodRes 4 x = 1}) = 4 from by decide,
    show (#{x ∈ box 4 | prodRes 4 x = 2}) = 4 from by decide,
    show (#{x ∈ box 4 | prodRes 4 x = 3}) = 4 from by decide]

/-- **The `C4` type-pair channel.** -/
theorem Ipair_val_4 : Ipair 4 = (5/4 : ℝ) := by
  rw [Ipair_eq, pairEntropy_val_4, condPairEntropy_val_4]
  ring

/-! ### The `C6` channel: `Q(ζ_7)` -/

/-- Exact type entropy of the `C6` channel. -/
theorem typeEntropy_val_6 : typeEntropy 6 = (1/3 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
  have h : ((range 6).image (ordType 6)).val.map
      (fun v => (#{x ∈ range 6 | ordType 6 x = v} : ℕ)) = (↑[1, 1, 2, 2] : Multiset ℕ) := by decide
  rw [typeEntropy, uEnt_eq_countSum _ _ _ h, show (range 6).card = 6 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  ring

/-- Exact entropy of the unordered type pair of a `C6` semiprime. -/
theorem pairEntropy_val_6 : pairEntropy 6 = (-1/18 : ℝ) + (2 : ℝ) * Real.logb 2 3 := by
  have h : ((box 6).image (typePair 6)).val.map
      (fun v => (#{q ∈ box 6 | typePair 6 q = v} : ℕ)) = (↑[1, 1, 2, 4, 4, 4, 4, 4, 4, 8] : Multiset ℕ) := by decide
  rw [pairEntropy, uEnt_eq_countSum _ _ _ h, show (box 6).card = 36 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  ring

/-- Exact conditional entropy of the type pair given the residue of the product. -/
theorem condPairEntropy_val_6 : condPairEntropy 6 = (1/18 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
  have himg : (box 6).image (prodRes 6) = range 6 := by decide
  have e0 : uEnt {x ∈ box 6 | prodRes 6 x = 0} (typePair 6) = (1/3 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 6 | prodRes 6 x = 0}).image (typePair 6)).val.map
        (fun v => (#{q ∈ {x ∈ box 6 | prodRes 6 x = 0} | typePair 6 q = v} : ℕ))
        = (↑[1, 1, 2, 2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 6 | prodRes 6 x = 0}) = 6 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e1 : uEnt {x ∈ box 6 | prodRes 6 x = 1} (typePair 6) = (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 6 | prodRes 6 x = 1}).image (typePair 6)).val.map
        (fun v => (#{q ∈ {x ∈ box 6 | prodRes 6 x = 1} | typePair 6 q = v} : ℕ))
        = (↑[2, 2, 2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 6 | prodRes 6 x = 1}) = 6 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  have e2 : uEnt {x ∈ box 6 | prodRes 6 x = 2} (typePair 6) = (1/3 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 6 | prodRes 6 x = 2}).image (typePair 6)).val.map
        (fun v => (#{q ∈ {x ∈ box 6 | prodRes 6 x = 2} | typePair 6 q = v} : ℕ))
        = (↑[1, 1, 2, 2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 6 | prodRes 6 x = 2}) = 6 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e3 : uEnt {x ∈ box 6 | prodRes 6 x = 3} (typePair 6) = (-2/3 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 6 | prodRes 6 x = 3}).image (typePair 6)).val.map
        (fun v => (#{q ∈ {x ∈ box 6 | prodRes 6 x = 3} | typePair 6 q = v} : ℕ))
        = (↑[2, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 6 | prodRes 6 x = 3}) = 6 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e4 : uEnt {x ∈ box 6 | prodRes 6 x = 4} (typePair 6) = (1/3 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 6 | prodRes 6 x = 4}).image (typePair 6)).val.map
        (fun v => (#{q ∈ {x ∈ box 6 | prodRes 6 x = 4} | typePair 6 q = v} : ℕ))
        = (↑[1, 1, 2, 2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 6 | prodRes 6 x = 4}) = 6 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e5 : uEnt {x ∈ box 6 | prodRes 6 x = 5} (typePair 6) = (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 6 | prodRes 6 x = 5}).image (typePair 6)).val.map
        (fun v => (#{q ∈ {x ∈ box 6 | prodRes 6 x = 5} | typePair 6 q = v} : ℕ))
        = (↑[2, 2, 2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 6 | prodRes 6 x = 5}) = 6 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  rw [condPairEntropy, condEnt, himg, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one,
    e0, e1, e2, e3, e4, e5]
  norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256, show (box 6).card = 36 from by decide,
    show (#{x ∈ box 6 | prodRes 6 x = 0}) = 6 from by decide,
    show (#{x ∈ box 6 | prodRes 6 x = 1}) = 6 from by decide,
    show (#{x ∈ box 6 | prodRes 6 x = 2}) = 6 from by decide,
    show (#{x ∈ box 6 | prodRes 6 x = 3}) = 6 from by decide,
    show (#{x ∈ box 6 | prodRes 6 x = 4}) = 6 from by decide,
    show (#{x ∈ box 6 | prodRes 6 x = 5}) = 6 from by decide]
  ring

/-- **The `C6` type-pair channel.** -/
theorem Ipair_val_6 : Ipair 6 = (-1/9 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
  rw [Ipair_eq, pairEntropy_val_6, condPairEntropy_val_6]
  ring

/-! ### The `C10` channel: `Q(ζ_11)` -/

/-- Exact type entropy of the `C10` channel. -/
theorem typeEntropy_val_10 : typeEntropy 10 = (-3/5 : ℝ) + (1 : ℝ) * Real.logb 2 5 := by
  have h : ((range 10).image (ordType 10)).val.map
      (fun v => (#{x ∈ range 10 | ordType 10 x = v} : ℕ)) = (↑[1, 1, 4, 4] : Multiset ℕ) := by decide
  rw [typeEntropy, uEnt_eq_countSum _ _ _ h, show (range 10).card = 10 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  ring

/-- Exact entropy of the unordered type pair of a `C10` semiprime. -/
theorem pairEntropy_val_10 : pairEntropy 10 = (-93/50 : ℝ) + (2 : ℝ) * Real.logb 2 5 := by
  have h : ((box 10).image (typePair 10)).val.map
      (fun v => (#{q ∈ box 10 | typePair 10 q = v} : ℕ)) = (↑[1, 1, 2, 8, 8, 8, 8, 16, 16, 32] : Multiset ℕ) := by decide
  rw [pairEntropy, uEnt_eq_countSum _ _ _ h, show (box 10).card = 100 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  ring

/-- Exact conditional entropy of the type pair given the residue of the product. -/
theorem condPairEntropy_val_10 : condPairEntropy 10 = (1/50 : ℝ) + (-12/25 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
  have himg : (box 10).image (prodRes 10) = range 10 := by decide
  have e0 : uEnt {x ∈ box 10 | prodRes 10 x = 0} (typePair 10) = (-3/5 : ℝ) + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 10 | prodRes 10 x = 0}).image (typePair 10)).val.map
        (fun v => (#{q ∈ {x ∈ box 10 | prodRes 10 x = 0} | typePair 10 q = v} : ℕ))
        = (↑[1, 1, 4, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 10 | prodRes 10 x = 0}) = 10 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e1 : uEnt {x ∈ box 10 | prodRes 10 x = 1} (typePair 10) = (-3/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 10 | prodRes 10 x = 1}).image (typePair 10)).val.map
        (fun v => (#{q ∈ {x ∈ box 10 | prodRes 10 x = 1} | typePair 10 q = v} : ℕ))
        = (↑[2, 2, 6] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 10 | prodRes 10 x = 1}) = 10 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e2 : uEnt {x ∈ box 10 | prodRes 10 x = 2} (typePair 10) = (3/5 : ℝ) + (-3/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 10 | prodRes 10 x = 2}).image (typePair 10)).val.map
        (fun v => (#{q ∈ {x ∈ box 10 | prodRes 10 x = 2} | typePair 10 q = v} : ℕ))
        = (↑[2, 2, 3, 3] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 10 | prodRes 10 x = 2}) = 10 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e3 : uEnt {x ∈ box 10 | prodRes 10 x = 3} (typePair 10) = (-3/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 10 | prodRes 10 x = 3}).image (typePair 10)).val.map
        (fun v => (#{q ∈ {x ∈ box 10 | prodRes 10 x = 3} | typePair 10 q = v} : ℕ))
        = (↑[2, 2, 6] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 10 | prodRes 10 x = 3}) = 10 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e4 : uEnt {x ∈ box 10 | prodRes 10 x = 4} (typePair 10) = (3/5 : ℝ) + (-3/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 10 | prodRes 10 x = 4}).image (typePair 10)).val.map
        (fun v => (#{q ∈ {x ∈ box 10 | prodRes 10 x = 4} | typePair 10 q = v} : ℕ))
        = (↑[2, 2, 3, 3] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 10 | prodRes 10 x = 4}) = 10 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e5 : uEnt {x ∈ box 10 | prodRes 10 x = 5} (typePair 10) = (-8/5 : ℝ) + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 10 | prodRes 10 x = 5}).image (typePair 10)).val.map
        (fun v => (#{q ∈ {x ∈ box 10 | prodRes 10 x = 5} | typePair 10 q = v} : ℕ))
        = (↑[2, 8] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 10 | prodRes 10 x = 5}) = 10 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e6 : uEnt {x ∈ box 10 | prodRes 10 x = 6} (typePair 10) = (3/5 : ℝ) + (-3/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 10 | prodRes 10 x = 6}).image (typePair 10)).val.map
        (fun v => (#{q ∈ {x ∈ box 10 | prodRes 10 x = 6} | typePair 10 q = v} : ℕ))
        = (↑[2, 2, 3, 3] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 10 | prodRes 10 x = 6}) = 10 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e7 : uEnt {x ∈ box 10 | prodRes 10 x = 7} (typePair 10) = (-3/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 10 | prodRes 10 x = 7}).image (typePair 10)).val.map
        (fun v => (#{q ∈ {x ∈ box 10 | prodRes 10 x = 7} | typePair 10 q = v} : ℕ))
        = (↑[2, 2, 6] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 10 | prodRes 10 x = 7}) = 10 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e8 : uEnt {x ∈ box 10 | prodRes 10 x = 8} (typePair 10) = (3/5 : ℝ) + (-3/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 10 | prodRes 10 x = 8}).image (typePair 10)).val.map
        (fun v => (#{q ∈ {x ∈ box 10 | prodRes 10 x = 8} | typePair 10 q = v} : ℕ))
        = (↑[2, 2, 3, 3] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 10 | prodRes 10 x = 8}) = 10 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e9 : uEnt {x ∈ box 10 | prodRes 10 x = 9} (typePair 10) = (-3/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 10 | prodRes 10 x = 9}).image (typePair 10)).val.map
        (fun v => (#{q ∈ {x ∈ box 10 | prodRes 10 x = 9} | typePair 10 q = v} : ℕ))
        = (↑[2, 2, 6] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 10 | prodRes 10 x = 9}) = 10 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  rw [condPairEntropy, condEnt, himg, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one,
    e0, e1, e2, e3, e4, e5, e6, e7, e8, e9]
  norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256, show (box 10).card = 100 from by decide,
    show (#{x ∈ box 10 | prodRes 10 x = 0}) = 10 from by decide,
    show (#{x ∈ box 10 | prodRes 10 x = 1}) = 10 from by decide,
    show (#{x ∈ box 10 | prodRes 10 x = 2}) = 10 from by decide,
    show (#{x ∈ box 10 | prodRes 10 x = 3}) = 10 from by decide,
    show (#{x ∈ box 10 | prodRes 10 x = 4}) = 10 from by decide,
    show (#{x ∈ box 10 | prodRes 10 x = 5}) = 10 from by decide,
    show (#{x ∈ box 10 | prodRes 10 x = 6}) = 10 from by decide,
    show (#{x ∈ box 10 | prodRes 10 x = 7}) = 10 from by decide,
    show (#{x ∈ box 10 | prodRes 10 x = 8}) = 10 from by decide,
    show (#{x ∈ box 10 | prodRes 10 x = 9}) = 10 from by decide]
  ring

/-- **The `C10` type-pair channel.** -/
theorem Ipair_val_10 : Ipair 10 = (-47/25 : ℝ) + (12/25 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
  rw [Ipair_eq, pairEntropy_val_10, condPairEntropy_val_10]
  ring

/-! ### The `C12` channel: `Q(ζ_13)` -/

/-- Exact type entropy of the `C12` channel. -/
theorem typeEntropy_val_12 : typeEntropy 12 = (5/6 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
  have h : ((range 12).image (ordType 12)).val.map
      (fun v => (#{x ∈ range 12 | ordType 12 x = v} : ℕ)) = (↑[1, 1, 2, 2, 2, 4] : Multiset ℕ) := by decide
  rw [typeEntropy, uEnt_eq_countSum _ _ _ h, show (range 12).card = 12 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  ring

/-- Exact entropy of the unordered type pair of a `C12` semiprime. -/
theorem pairEntropy_val_12 : pairEntropy 12 = (7/8 : ℝ) + (2 : ℝ) * Real.logb 2 3 := by
  have h : ((box 12).image (typePair 12)).val.map
      (fun v => (#{q ∈ box 12 | typePair 12 q = v} : ℕ)) = (↑[1, 1, 2, 4, 4, 4, 4, 4, 4, 4, 4, 4, 8, 8, 8, 8, 8, 16, 16, 16, 16] : Multiset ℕ) := by decide
  rw [pairEntropy, uEnt_eq_countSum _ _ _ h, show (box 12).card = 144 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  ring

/-- Exact conditional entropy of the type pair given the residue of the product. -/
theorem condPairEntropy_val_12 : condPairEntropy 12 = (53/72 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
  have himg : (box 12).image (prodRes 12) = range 12 := by decide
  have e0 : uEnt {x ∈ box 12 | prodRes 12 x = 0} (typePair 12) = (5/6 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 0}).image (typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 0} | typePair 12 q = v} : ℕ))
        = (↑[1, 1, 2, 2, 2, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 0}) = 12 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e1 : uEnt {x ∈ box 12 | prodRes 12 x = 1} (typePair 12) = (1 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 1}).image (typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 1} | typePair 12 q = v} : ℕ))
        = (↑[2, 2, 2, 2, 2, 2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 1}) = 12 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e2 : uEnt {x ∈ box 12 | prodRes 12 x = 2} (typePair 12) = (2/3 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 2}).image (typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 2} | typePair 12 q = v} : ℕ))
        = (↑[2, 2, 2, 2, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 2}) = 12 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e3 : uEnt {x ∈ box 12 | prodRes 12 x = 3} (typePair 12) = (1/3 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 3}).image (typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 3} | typePair 12 q = v} : ℕ))
        = (↑[2, 2, 4, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 3}) = 12 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e4 : uEnt {x ∈ box 12 | prodRes 12 x = 4} (typePair 12) = (5/6 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 4}).image (typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 4} | typePair 12 q = v} : ℕ))
        = (↑[1, 1, 2, 2, 2, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 4}) = 12 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e5 : uEnt {x ∈ box 12 | prodRes 12 x = 5} (typePair 12) = (1 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 5}).image (typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 5} | typePair 12 q = v} : ℕ))
        = (↑[2, 2, 2, 2, 2, 2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 5}) = 12 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e6 : uEnt {x ∈ box 12 | prodRes 12 x = 6} (typePair 12) = (1/3 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 6}).image (typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 6} | typePair 12 q = v} : ℕ))
        = (↑[2, 2, 4, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 6}) = 12 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e7 : uEnt {x ∈ box 12 | prodRes 12 x = 7} (typePair 12) = (1 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 7}).image (typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 7} | typePair 12 q = v} : ℕ))
        = (↑[2, 2, 2, 2, 2, 2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 7}) = 12 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e8 : uEnt {x ∈ box 12 | prodRes 12 x = 8} (typePair 12) = (5/6 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 8}).image (typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 8} | typePair 12 q = v} : ℕ))
        = (↑[1, 1, 2, 2, 2, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 8}) = 12 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e9 : uEnt {x ∈ box 12 | prodRes 12 x = 9} (typePair 12) = (1/3 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 9}).image (typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 9} | typePair 12 q = v} : ℕ))
        = (↑[2, 2, 4, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 9}) = 12 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e10 : uEnt {x ∈ box 12 | prodRes 12 x = 10} (typePair 12) = (2/3 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 10}).image (typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 10} | typePair 12 q = v} : ℕ))
        = (↑[2, 2, 2, 2, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 10}) = 12 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  have e11 : uEnt {x ∈ box 12 | prodRes 12 x = 11} (typePair 12) = (1 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 12 | prodRes 12 x = 11}).image (typePair 12)).val.map
        (fun v => (#{q ∈ {x ∈ box 12 | prodRes 12 x = 11} | typePair 12 q = v} : ℕ))
        = (↑[2, 2, 2, 2, 2, 2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 12 | prodRes 12 x = 11}) = 12 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
    ring
  rw [condPairEntropy, condEnt, himg, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one,
    e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11]
  norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256, show (box 12).card = 144 from by decide,
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

/-- **The `C12` type-pair channel.** -/
theorem Ipair_val_12 : Ipair 12 = (5/36 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
  rw [Ipair_eq, pairEntropy_val_12, condPairEntropy_val_12]
  ring

/-! ### The `C16` channel: `Q(ζ_17)` -/

/-- Exact type entropy of the `C16` channel. -/
theorem typeEntropy_val_16 : typeEntropy 16 = (15/8 : ℝ) := by
  have h : ((range 16).image (ordType 16)).val.map
      (fun v => (#{x ∈ range 16 | ordType 16 x = v} : ℕ)) = (↑[1, 1, 2, 4, 8] : Multiset ℕ) := by decide
  rw [typeEntropy, uEnt_eq_countSum _ _ _ h, show (range 16).card = 16 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]

/-- Exact entropy of the unordered type pair of a `C16` semiprime. -/
theorem pairEntropy_val_16 : pairEntropy 16 = (395/128 : ℝ) := by
  have h : ((box 16).image (typePair 16)).val.map
      (fun v => (#{q ∈ box 16 | typePair 16 q = v} : ℕ)) = (↑[1, 1, 2, 4, 4, 4, 8, 8, 16, 16, 16, 16, 32, 64, 64] : Multiset ℕ) := by decide
  rw [pairEntropy, uEnt_eq_countSum _ _ _ h, show (box 16).card = 256 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]

/-- Exact conditional entropy of the type pair given the residue of the product. -/
theorem condPairEntropy_val_16 : condPairEntropy 16 = (225/128 : ℝ) := by
  have himg : (box 16).image (prodRes 16) = range 16 := by decide
  have e0 : uEnt {x ∈ box 16 | prodRes 16 x = 0} (typePair 16) = (15/8 : ℝ) := by
    have h : (({x ∈ box 16 | prodRes 16 x = 0}).image (typePair 16)).val.map
        (fun v => (#{q ∈ {x ∈ box 16 | prodRes 16 x = 0} | typePair 16 q = v} : ℕ))
        = (↑[1, 1, 2, 4, 8] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 16 | prodRes 16 x = 0}) = 16 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  have e1 : uEnt {x ∈ box 16 | prodRes 16 x = 1} (typePair 16) = (7/4 : ℝ) := by
    have h : (({x ∈ box 16 | prodRes 16 x = 1}).image (typePair 16)).val.map
        (fun v => (#{q ∈ {x ∈ box 16 | prodRes 16 x = 1} | typePair 16 q = v} : ℕ))
        = (↑[2, 2, 4, 8] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 16 | prodRes 16 x = 1}) = 16 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  have e2 : uEnt {x ∈ box 16 | prodRes 16 x = 2} (typePair 16) = (7/4 : ℝ) := by
    have h : (({x ∈ box 16 | prodRes 16 x = 2}).image (typePair 16)).val.map
        (fun v => (#{q ∈ {x ∈ box 16 | prodRes 16 x = 2} | typePair 16 q = v} : ℕ))
        = (↑[2, 2, 4, 8] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 16 | prodRes 16 x = 2}) = 16 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  have e3 : uEnt {x ∈ box 16 | prodRes 16 x = 3} (typePair 16) = (7/4 : ℝ) := by
    have h : (({x ∈ box 16 | prodRes 16 x = 3}).image (typePair 16)).val.map
        (fun v => (#{q ∈ {x ∈ box 16 | prodRes 16 x = 3} | typePair 16 q = v} : ℕ))
        = (↑[2, 2, 4, 8] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 16 | prodRes 16 x = 3}) = 16 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  have e4 : uEnt {x ∈ box 16 | prodRes 16 x = 4} (typePair 16) = (7/4 : ℝ) := by
    have h : (({x ∈ box 16 | prodRes 16 x = 4}).image (typePair 16)).val.map
        (fun v => (#{q ∈ {x ∈ box 16 | prodRes 16 x = 4} | typePair 16 q = v} : ℕ))
        = (↑[2, 2, 4, 8] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 16 | prodRes 16 x = 4}) = 16 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  have e5 : uEnt {x ∈ box 16 | prodRes 16 x = 5} (typePair 16) = (7/4 : ℝ) := by
    have h : (({x ∈ box 16 | prodRes 16 x = 5}).image (typePair 16)).val.map
        (fun v => (#{q ∈ {x ∈ box 16 | prodRes 16 x = 5} | typePair 16 q = v} : ℕ))
        = (↑[2, 2, 4, 8] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 16 | prodRes 16 x = 5}) = 16 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  have e6 : uEnt {x ∈ box 16 | prodRes 16 x = 6} (typePair 16) = (7/4 : ℝ) := by
    have h : (({x ∈ box 16 | prodRes 16 x = 6}).image (typePair 16)).val.map
        (fun v => (#{q ∈ {x ∈ box 16 | prodRes 16 x = 6} | typePair 16 q = v} : ℕ))
        = (↑[2, 2, 4, 8] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 16 | prodRes 16 x = 6}) = 16 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  have e7 : uEnt {x ∈ box 16 | prodRes 16 x = 7} (typePair 16) = (7/4 : ℝ) := by
    have h : (({x ∈ box 16 | prodRes 16 x = 7}).image (typePair 16)).val.map
        (fun v => (#{q ∈ {x ∈ box 16 | prodRes 16 x = 7} | typePair 16 q = v} : ℕ))
        = (↑[2, 2, 4, 8] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 16 | prodRes 16 x = 7}) = 16 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  have e8 : uEnt {x ∈ box 16 | prodRes 16 x = 8} (typePair 16) = (7/4 : ℝ) := by
    have h : (({x ∈ box 16 | prodRes 16 x = 8}).image (typePair 16)).val.map
        (fun v => (#{q ∈ {x ∈ box 16 | prodRes 16 x = 8} | typePair 16 q = v} : ℕ))
        = (↑[2, 2, 4, 8] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 16 | prodRes 16 x = 8}) = 16 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  have e9 : uEnt {x ∈ box 16 | prodRes 16 x = 9} (typePair 16) = (7/4 : ℝ) := by
    have h : (({x ∈ box 16 | prodRes 16 x = 9}).image (typePair 16)).val.map
        (fun v => (#{q ∈ {x ∈ box 16 | prodRes 16 x = 9} | typePair 16 q = v} : ℕ))
        = (↑[2, 2, 4, 8] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 16 | prodRes 16 x = 9}) = 16 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  have e10 : uEnt {x ∈ box 16 | prodRes 16 x = 10} (typePair 16) = (7/4 : ℝ) := by
    have h : (({x ∈ box 16 | prodRes 16 x = 10}).image (typePair 16)).val.map
        (fun v => (#{q ∈ {x ∈ box 16 | prodRes 16 x = 10} | typePair 16 q = v} : ℕ))
        = (↑[2, 2, 4, 8] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 16 | prodRes 16 x = 10}) = 16 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  have e11 : uEnt {x ∈ box 16 | prodRes 16 x = 11} (typePair 16) = (7/4 : ℝ) := by
    have h : (({x ∈ box 16 | prodRes 16 x = 11}).image (typePair 16)).val.map
        (fun v => (#{q ∈ {x ∈ box 16 | prodRes 16 x = 11} | typePair 16 q = v} : ℕ))
        = (↑[2, 2, 4, 8] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 16 | prodRes 16 x = 11}) = 16 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  have e12 : uEnt {x ∈ box 16 | prodRes 16 x = 12} (typePair 16) = (7/4 : ℝ) := by
    have h : (({x ∈ box 16 | prodRes 16 x = 12}).image (typePair 16)).val.map
        (fun v => (#{q ∈ {x ∈ box 16 | prodRes 16 x = 12} | typePair 16 q = v} : ℕ))
        = (↑[2, 2, 4, 8] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 16 | prodRes 16 x = 12}) = 16 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  have e13 : uEnt {x ∈ box 16 | prodRes 16 x = 13} (typePair 16) = (7/4 : ℝ) := by
    have h : (({x ∈ box 16 | prodRes 16 x = 13}).image (typePair 16)).val.map
        (fun v => (#{q ∈ {x ∈ box 16 | prodRes 16 x = 13} | typePair 16 q = v} : ℕ))
        = (↑[2, 2, 4, 8] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 16 | prodRes 16 x = 13}) = 16 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  have e14 : uEnt {x ∈ box 16 | prodRes 16 x = 14} (typePair 16) = (7/4 : ℝ) := by
    have h : (({x ∈ box 16 | prodRes 16 x = 14}).image (typePair 16)).val.map
        (fun v => (#{q ∈ {x ∈ box 16 | prodRes 16 x = 14} | typePair 16 q = v} : ℕ))
        = (↑[2, 2, 4, 8] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 16 | prodRes 16 x = 14}) = 16 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  have e15 : uEnt {x ∈ box 16 | prodRes 16 x = 15} (typePair 16) = (7/4 : ℝ) := by
    have h : (({x ∈ box 16 | prodRes 16 x = 15}).image (typePair 16)).val.map
        (fun v => (#{q ∈ {x ∈ box 16 | prodRes 16 x = 15} | typePair 16 q = v} : ℕ))
        = (↑[2, 2, 4, 8] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 16 | prodRes 16 x = 15}) = 16 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256]
  rw [condPairEntropy, condEnt, himg, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one,
    e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12, e13, e14, e15]
  norm_num [lb_4, lb_6, lb_8, lb_10, lb_12, lb_16, lb_32, lb_36, lb_64, lb_100, lb_144, lb_256, show (box 16).card = 256 from by decide,
    show (#{x ∈ box 16 | prodRes 16 x = 0}) = 16 from by decide,
    show (#{x ∈ box 16 | prodRes 16 x = 1}) = 16 from by decide,
    show (#{x ∈ box 16 | prodRes 16 x = 2}) = 16 from by decide,
    show (#{x ∈ box 16 | prodRes 16 x = 3}) = 16 from by decide,
    show (#{x ∈ box 16 | prodRes 16 x = 4}) = 16 from by decide,
    show (#{x ∈ box 16 | prodRes 16 x = 5}) = 16 from by decide,
    show (#{x ∈ box 16 | prodRes 16 x = 6}) = 16 from by decide,
    show (#{x ∈ box 16 | prodRes 16 x = 7}) = 16 from by decide,
    show (#{x ∈ box 16 | prodRes 16 x = 8}) = 16 from by decide,
    show (#{x ∈ box 16 | prodRes 16 x = 9}) = 16 from by decide,
    show (#{x ∈ box 16 | prodRes 16 x = 10}) = 16 from by decide,
    show (#{x ∈ box 16 | prodRes 16 x = 11}) = 16 from by decide,
    show (#{x ∈ box 16 | prodRes 16 x = 12}) = 16 from by decide,
    show (#{x ∈ box 16 | prodRes 16 x = 13}) = 16 from by decide,
    show (#{x ∈ box 16 | prodRes 16 x = 14}) = 16 from by decide,
    show (#{x ∈ box 16 | prodRes 16 x = 15}) = 16 from by decide]

/-- **The `C16` type-pair channel.** -/
theorem Ipair_val_16 : Ipair 16 = (85/64 : ℝ) := by
  rw [Ipair_eq, pairEntropy_val_16, condPairEntropy_val_16]
  ring

end CyclicTypeChannel