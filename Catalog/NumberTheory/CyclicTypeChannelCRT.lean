/-
# CRT additivity of the cyclic type-pair channel

This file extends the exact-value catalogue of the cyclic type-pair channel to
the orders `n ∈ {3, 5, 8, 9, 15}` and proves the two structural laws that the
extended table makes visible.

* **CRT additivity.**  For coprime cyclic orders the type-pair information is
  *exactly additive*:
  `Ipair (n₁ * n₂) = Ipair n₁ + Ipair n₂` whenever `gcd n₁ n₂ = 1`
  (verified here for the pairs `(2,3)`, `(2,5)`, `(4,3)`, `(3,5)`).
  This is the information-theoretic shadow of the CRT decomposition of a cyclic
  group into its primary components.

* **Evenness, not compositeness, breaks the one-bit cap.**  The order `8` is a
  further above-cap example (`21/16 > 1`), while *every* odd order computed here
  (`3, 5, 9, 15`) sits strictly *below* one bit.  So the mechanism which pushes
  the multi-state type channel above the binary-fork cap is the presence of the
  order-two element (the quadratic character), amplified by the remaining
  divisor structure.
-/
import Catalog.Shared.CyclicTypeChannelValues
import Catalog.Shared.CyclicTypeChannelCRTLaw

namespace CyclicTypeChannel

open Finset

set_option maxRecDepth 100000

/-! ### The abstract cyclic order `C3` -/

/-- Exact type entropy of the `C3` channel. -/
theorem typeEntropy_val_3 : typeEntropy 3 = (-2/3 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
  have h : ((range 3).image (ordType 3)).val.map
      (fun v => (#{x ∈ range 3 | ordType 3 x = v} : ℕ)) = (↑[1, 2] : Multiset ℕ) := by decide
  rw [typeEntropy, uEnt_eq_countSum _ _ _ h, show (range 3).card = 3 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
  ring

/-- Exact entropy of the unordered type pair of a `C3` semiprime. -/
theorem pairEntropy_val_3 : pairEntropy 3 = (-16/9 : ℝ) + (2 : ℝ) * Real.logb 2 3 := by
  have h : ((box 3).image (typePair 3)).val.map
      (fun v => (#{q ∈ box 3 | typePair 3 q = v} : ℕ)) = (↑[1, 4, 4] : Multiset ℕ) := by decide
  rw [pairEntropy, uEnt_eq_countSum _ _ _ h, show (box 3).card = 9 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
  ring

/-- Exact conditional entropy of the type pair given the residue of the product. -/
theorem condPairEntropy_val_3 : condPairEntropy 3 = (-2/3 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
  have himg : (box 3).image (prodRes 3) = range 3 := by decide
  have e0 : uEnt {x ∈ box 3 | prodRes 3 x = 0} (typePair 3) = (-2/3 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 3 | prodRes 3 x = 0}).image (typePair 3)).val.map
        (fun v => (#{q ∈ {x ∈ box 3 | prodRes 3 x = 0} | typePair 3 q = v} : ℕ))
        = (↑[1, 2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 3 | prodRes 3 x = 0}) = 3 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e1 : uEnt {x ∈ box 3 | prodRes 3 x = 1} (typePair 3) = (-2/3 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 3 | prodRes 3 x = 1}).image (typePair 3)).val.map
        (fun v => (#{q ∈ {x ∈ box 3 | prodRes 3 x = 1} | typePair 3 q = v} : ℕ))
        = (↑[1, 2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 3 | prodRes 3 x = 1}) = 3 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e2 : uEnt {x ∈ box 3 | prodRes 3 x = 2} (typePair 3) = (-2/3 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 3 | prodRes 3 x = 2}).image (typePair 3)).val.map
        (fun v => (#{q ∈ {x ∈ box 3 | prodRes 3 x = 2} | typePair 3 q = v} : ℕ))
        = (↑[1, 2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 3 | prodRes 3 x = 2}) = 3 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  rw [condPairEntropy, condEnt, himg, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one,
    e0, e1, e2]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256, show (box 3).card = 9 from by decide,
    show (#{x ∈ box 3 | prodRes 3 x = 0}) = 3 from by decide,
    show (#{x ∈ box 3 | prodRes 3 x = 1}) = 3 from by decide,
    show (#{x ∈ box 3 | prodRes 3 x = 2}) = 3 from by decide]
  ring

/-- **The `C3` type-pair channel.** -/
theorem Ipair_val_3 : Ipair 3 = (-10/9 : ℝ) + (1 : ℝ) * Real.logb 2 3 := by
  rw [Ipair_eq, pairEntropy_val_3, condPairEntropy_val_3]
  ring

/-! ### The abstract cyclic order `C5` -/

/-- Exact type entropy of the `C5` channel. -/
theorem typeEntropy_val_5 : typeEntropy 5 = (-8/5 : ℝ) + (1 : ℝ) * Real.logb 2 5 := by
  have h : ((range 5).image (ordType 5)).val.map
      (fun v => (#{x ∈ range 5 | ordType 5 x = v} : ℕ)) = (↑[1, 4] : Multiset ℕ) := by decide
  rw [typeEntropy, uEnt_eq_countSum _ _ _ h, show (range 5).card = 5 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
  ring

/-- Exact entropy of the unordered type pair of a `C5` semiprime. -/
theorem pairEntropy_val_5 : pairEntropy 5 = (-88/25 : ℝ) + (2 : ℝ) * Real.logb 2 5 := by
  have h : ((box 5).image (typePair 5)).val.map
      (fun v => (#{q ∈ box 5 | typePair 5 q = v} : ℕ)) = (↑[1, 8, 16] : Multiset ℕ) := by decide
  rw [pairEntropy, uEnt_eq_countSum _ _ _ h, show (box 5).card = 25 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
  ring

/-- Exact conditional entropy of the type pair given the residue of the product. -/
theorem condPairEntropy_val_5 : condPairEntropy 5 = (-16/25 : ℝ) + (-12/25 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
  have himg : (box 5).image (prodRes 5) = range 5 := by decide
  have e0 : uEnt {x ∈ box 5 | prodRes 5 x = 0} (typePair 5) = (-8/5 : ℝ) + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 5 | prodRes 5 x = 0}).image (typePair 5)).val.map
        (fun v => (#{q ∈ {x ∈ box 5 | prodRes 5 x = 0} | typePair 5 q = v} : ℕ))
        = (↑[1, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 5 | prodRes 5 x = 0}) = 5 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e1 : uEnt {x ∈ box 5 | prodRes 5 x = 1} (typePair 5) = (-2/5 : ℝ) + (-3/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 5 | prodRes 5 x = 1}).image (typePair 5)).val.map
        (fun v => (#{q ∈ {x ∈ box 5 | prodRes 5 x = 1} | typePair 5 q = v} : ℕ))
        = (↑[2, 3] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 5 | prodRes 5 x = 1}) = 5 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e2 : uEnt {x ∈ box 5 | prodRes 5 x = 2} (typePair 5) = (-2/5 : ℝ) + (-3/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 5 | prodRes 5 x = 2}).image (typePair 5)).val.map
        (fun v => (#{q ∈ {x ∈ box 5 | prodRes 5 x = 2} | typePair 5 q = v} : ℕ))
        = (↑[2, 3] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 5 | prodRes 5 x = 2}) = 5 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e3 : uEnt {x ∈ box 5 | prodRes 5 x = 3} (typePair 5) = (-2/5 : ℝ) + (-3/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 5 | prodRes 5 x = 3}).image (typePair 5)).val.map
        (fun v => (#{q ∈ {x ∈ box 5 | prodRes 5 x = 3} | typePair 5 q = v} : ℕ))
        = (↑[2, 3] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 5 | prodRes 5 x = 3}) = 5 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e4 : uEnt {x ∈ box 5 | prodRes 5 x = 4} (typePair 5) = (-2/5 : ℝ) + (-3/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 5 | prodRes 5 x = 4}).image (typePair 5)).val.map
        (fun v => (#{q ∈ {x ∈ box 5 | prodRes 5 x = 4} | typePair 5 q = v} : ℕ))
        = (↑[2, 3] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 5 | prodRes 5 x = 4}) = 5 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  rw [condPairEntropy, condEnt, himg, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one,
    e0, e1, e2, e3, e4]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256, show (box 5).card = 25 from by decide,
    show (#{x ∈ box 5 | prodRes 5 x = 0}) = 5 from by decide,
    show (#{x ∈ box 5 | prodRes 5 x = 1}) = 5 from by decide,
    show (#{x ∈ box 5 | prodRes 5 x = 2}) = 5 from by decide,
    show (#{x ∈ box 5 | prodRes 5 x = 3}) = 5 from by decide,
    show (#{x ∈ box 5 | prodRes 5 x = 4}) = 5 from by decide]
  ring

/-- **The `C5` type-pair channel.** -/
theorem Ipair_val_5 : Ipair 5 = (-72/25 : ℝ) + (12/25 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
  rw [Ipair_eq, pairEntropy_val_5, condPairEntropy_val_5]
  ring

/-! ### The abstract cyclic order `C8` -/

/-- Exact type entropy of the `C8` channel. -/
theorem typeEntropy_val_8 : typeEntropy 8 = (7/4 : ℝ) := by
  have h : ((range 8).image (ordType 8)).val.map
      (fun v => (#{x ∈ range 8 | ordType 8 x = v} : ℕ)) = (↑[1, 1, 2, 4] : Multiset ℕ) := by decide
  rw [typeEntropy, uEnt_eq_countSum _ _ _ h, show (range 8).card = 8 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]

/-- Exact entropy of the unordered type pair of a `C8` semiprime. -/
theorem pairEntropy_val_8 : pairEntropy 8 = (91/32 : ℝ) := by
  have h : ((box 8).image (typePair 8)).val.map
      (fun v => (#{q ∈ box 8 | typePair 8 q = v} : ℕ)) = (↑[1, 1, 2, 4, 4, 4, 8, 8, 16, 16] : Multiset ℕ) := by decide
  rw [pairEntropy, uEnt_eq_countSum _ _ _ h, show (box 8).card = 64 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]

/-- Exact conditional entropy of the type pair given the residue of the product. -/
theorem condPairEntropy_val_8 : condPairEntropy 8 = (49/32 : ℝ) := by
  have himg : (box 8).image (prodRes 8) = range 8 := by decide
  have e0 : uEnt {x ∈ box 8 | prodRes 8 x = 0} (typePair 8) = (7/4 : ℝ) := by
    have h : (({x ∈ box 8 | prodRes 8 x = 0}).image (typePair 8)).val.map
        (fun v => (#{q ∈ {x ∈ box 8 | prodRes 8 x = 0} | typePair 8 q = v} : ℕ))
        = (↑[1, 1, 2, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 8 | prodRes 8 x = 0}) = 8 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
  have e1 : uEnt {x ∈ box 8 | prodRes 8 x = 1} (typePair 8) = (3/2 : ℝ) := by
    have h : (({x ∈ box 8 | prodRes 8 x = 1}).image (typePair 8)).val.map
        (fun v => (#{q ∈ {x ∈ box 8 | prodRes 8 x = 1} | typePair 8 q = v} : ℕ))
        = (↑[2, 2, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 8 | prodRes 8 x = 1}) = 8 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
  have e2 : uEnt {x ∈ box 8 | prodRes 8 x = 2} (typePair 8) = (3/2 : ℝ) := by
    have h : (({x ∈ box 8 | prodRes 8 x = 2}).image (typePair 8)).val.map
        (fun v => (#{q ∈ {x ∈ box 8 | prodRes 8 x = 2} | typePair 8 q = v} : ℕ))
        = (↑[2, 2, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 8 | prodRes 8 x = 2}) = 8 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
  have e3 : uEnt {x ∈ box 8 | prodRes 8 x = 3} (typePair 8) = (3/2 : ℝ) := by
    have h : (({x ∈ box 8 | prodRes 8 x = 3}).image (typePair 8)).val.map
        (fun v => (#{q ∈ {x ∈ box 8 | prodRes 8 x = 3} | typePair 8 q = v} : ℕ))
        = (↑[2, 2, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 8 | prodRes 8 x = 3}) = 8 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
  have e4 : uEnt {x ∈ box 8 | prodRes 8 x = 4} (typePair 8) = (3/2 : ℝ) := by
    have h : (({x ∈ box 8 | prodRes 8 x = 4}).image (typePair 8)).val.map
        (fun v => (#{q ∈ {x ∈ box 8 | prodRes 8 x = 4} | typePair 8 q = v} : ℕ))
        = (↑[2, 2, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 8 | prodRes 8 x = 4}) = 8 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
  have e5 : uEnt {x ∈ box 8 | prodRes 8 x = 5} (typePair 8) = (3/2 : ℝ) := by
    have h : (({x ∈ box 8 | prodRes 8 x = 5}).image (typePair 8)).val.map
        (fun v => (#{q ∈ {x ∈ box 8 | prodRes 8 x = 5} | typePair 8 q = v} : ℕ))
        = (↑[2, 2, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 8 | prodRes 8 x = 5}) = 8 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
  have e6 : uEnt {x ∈ box 8 | prodRes 8 x = 6} (typePair 8) = (3/2 : ℝ) := by
    have h : (({x ∈ box 8 | prodRes 8 x = 6}).image (typePair 8)).val.map
        (fun v => (#{q ∈ {x ∈ box 8 | prodRes 8 x = 6} | typePair 8 q = v} : ℕ))
        = (↑[2, 2, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 8 | prodRes 8 x = 6}) = 8 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
  have e7 : uEnt {x ∈ box 8 | prodRes 8 x = 7} (typePair 8) = (3/2 : ℝ) := by
    have h : (({x ∈ box 8 | prodRes 8 x = 7}).image (typePair 8)).val.map
        (fun v => (#{q ∈ {x ∈ box 8 | prodRes 8 x = 7} | typePair 8 q = v} : ℕ))
        = (↑[2, 2, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 8 | prodRes 8 x = 7}) = 8 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
  rw [condPairEntropy, condEnt, himg, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one,
    e0, e1, e2, e3, e4, e5, e6, e7]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256, show (box 8).card = 64 from by decide,
    show (#{x ∈ box 8 | prodRes 8 x = 0}) = 8 from by decide,
    show (#{x ∈ box 8 | prodRes 8 x = 1}) = 8 from by decide,
    show (#{x ∈ box 8 | prodRes 8 x = 2}) = 8 from by decide,
    show (#{x ∈ box 8 | prodRes 8 x = 3}) = 8 from by decide,
    show (#{x ∈ box 8 | prodRes 8 x = 4}) = 8 from by decide,
    show (#{x ∈ box 8 | prodRes 8 x = 5}) = 8 from by decide,
    show (#{x ∈ box 8 | prodRes 8 x = 6}) = 8 from by decide,
    show (#{x ∈ box 8 | prodRes 8 x = 7}) = 8 from by decide]

/-- **The `C8` type-pair channel.** -/
theorem Ipair_val_8 : Ipair 8 = (21/16 : ℝ) := by
  rw [Ipair_eq, pairEntropy_val_8, condPairEntropy_val_8]
  ring

/-! ### The abstract cyclic order `C9` -/

/-- Exact type entropy of the `C9` channel. -/
theorem typeEntropy_val_9 : typeEntropy 9 = (-8/9 : ℝ) + (4/3 : ℝ) * Real.logb 2 3 := by
  have h : ((range 9).image (ordType 9)).val.map
      (fun v => (#{x ∈ range 9 | ordType 9 x = v} : ℕ)) = (↑[1, 2, 6] : Multiset ℕ) := by decide
  rw [typeEntropy, uEnt_eq_countSum _ _ _ h, show (range 9).card = 9 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
  ring

/-- Exact entropy of the unordered type pair of a `C9` semiprime. -/
theorem pairEntropy_val_9 : pairEntropy 9 = (-184/81 : ℝ) + (8/3 : ℝ) * Real.logb 2 3 := by
  have h : ((box 9).image (typePair 9)).val.map
      (fun v => (#{q ∈ box 9 | typePair 9 q = v} : ℕ)) = (↑[1, 4, 4, 12, 24, 36] : Multiset ℕ) := by decide
  rw [pairEntropy, uEnt_eq_countSum _ _ _ h, show (box 9).card = 81 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
  ring

/-- Exact conditional entropy of the type pair given the residue of the product. -/
theorem condPairEntropy_val_9 : condPairEntropy 9 = (-28/27 : ℝ) + (14/9 : ℝ) * Real.logb 2 3 := by
  have himg : (box 9).image (prodRes 9) = range 9 := by decide
  have e0 : uEnt {x ∈ box 9 | prodRes 9 x = 0} (typePair 9) = (-8/9 : ℝ) + (4/3 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 9 | prodRes 9 x = 0}).image (typePair 9)).val.map
        (fun v => (#{q ∈ {x ∈ box 9 | prodRes 9 x = 0} | typePair 9 q = v} : ℕ))
        = (↑[1, 2, 6] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 9 | prodRes 9 x = 0}) = 9 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e1 : uEnt {x ∈ box 9 | prodRes 9 x = 1} (typePair 9) = (-10/9 : ℝ) + (5/3 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 9 | prodRes 9 x = 1}).image (typePair 9)).val.map
        (fun v => (#{q ∈ {x ∈ box 9 | prodRes 9 x = 1} | typePair 9 q = v} : ℕ))
        = (↑[2, 3, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 9 | prodRes 9 x = 1}) = 9 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e2 : uEnt {x ∈ box 9 | prodRes 9 x = 2} (typePair 9) = (-10/9 : ℝ) + (5/3 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 9 | prodRes 9 x = 2}).image (typePair 9)).val.map
        (fun v => (#{q ∈ {x ∈ box 9 | prodRes 9 x = 2} | typePair 9 q = v} : ℕ))
        = (↑[2, 3, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 9 | prodRes 9 x = 2}) = 9 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e3 : uEnt {x ∈ box 9 | prodRes 9 x = 3} (typePair 9) = (-8/9 : ℝ) + (4/3 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 9 | prodRes 9 x = 3}).image (typePair 9)).val.map
        (fun v => (#{q ∈ {x ∈ box 9 | prodRes 9 x = 3} | typePair 9 q = v} : ℕ))
        = (↑[1, 2, 6] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 9 | prodRes 9 x = 3}) = 9 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e4 : uEnt {x ∈ box 9 | prodRes 9 x = 4} (typePair 9) = (-10/9 : ℝ) + (5/3 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 9 | prodRes 9 x = 4}).image (typePair 9)).val.map
        (fun v => (#{q ∈ {x ∈ box 9 | prodRes 9 x = 4} | typePair 9 q = v} : ℕ))
        = (↑[2, 3, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 9 | prodRes 9 x = 4}) = 9 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e5 : uEnt {x ∈ box 9 | prodRes 9 x = 5} (typePair 9) = (-10/9 : ℝ) + (5/3 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 9 | prodRes 9 x = 5}).image (typePair 9)).val.map
        (fun v => (#{q ∈ {x ∈ box 9 | prodRes 9 x = 5} | typePair 9 q = v} : ℕ))
        = (↑[2, 3, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 9 | prodRes 9 x = 5}) = 9 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e6 : uEnt {x ∈ box 9 | prodRes 9 x = 6} (typePair 9) = (-8/9 : ℝ) + (4/3 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 9 | prodRes 9 x = 6}).image (typePair 9)).val.map
        (fun v => (#{q ∈ {x ∈ box 9 | prodRes 9 x = 6} | typePair 9 q = v} : ℕ))
        = (↑[1, 2, 6] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 9 | prodRes 9 x = 6}) = 9 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e7 : uEnt {x ∈ box 9 | prodRes 9 x = 7} (typePair 9) = (-10/9 : ℝ) + (5/3 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 9 | prodRes 9 x = 7}).image (typePair 9)).val.map
        (fun v => (#{q ∈ {x ∈ box 9 | prodRes 9 x = 7} | typePair 9 q = v} : ℕ))
        = (↑[2, 3, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 9 | prodRes 9 x = 7}) = 9 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e8 : uEnt {x ∈ box 9 | prodRes 9 x = 8} (typePair 9) = (-10/9 : ℝ) + (5/3 : ℝ) * Real.logb 2 3 := by
    have h : (({x ∈ box 9 | prodRes 9 x = 8}).image (typePair 9)).val.map
        (fun v => (#{q ∈ {x ∈ box 9 | prodRes 9 x = 8} | typePair 9 q = v} : ℕ))
        = (↑[2, 3, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 9 | prodRes 9 x = 8}) = 9 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  rw [condPairEntropy, condEnt, himg, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one,
    e0, e1, e2, e3, e4, e5, e6, e7, e8]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256, show (box 9).card = 81 from by decide,
    show (#{x ∈ box 9 | prodRes 9 x = 0}) = 9 from by decide,
    show (#{x ∈ box 9 | prodRes 9 x = 1}) = 9 from by decide,
    show (#{x ∈ box 9 | prodRes 9 x = 2}) = 9 from by decide,
    show (#{x ∈ box 9 | prodRes 9 x = 3}) = 9 from by decide,
    show (#{x ∈ box 9 | prodRes 9 x = 4}) = 9 from by decide,
    show (#{x ∈ box 9 | prodRes 9 x = 5}) = 9 from by decide,
    show (#{x ∈ box 9 | prodRes 9 x = 6}) = 9 from by decide,
    show (#{x ∈ box 9 | prodRes 9 x = 7}) = 9 from by decide,
    show (#{x ∈ box 9 | prodRes 9 x = 8}) = 9 from by decide]
  ring

/-- **The `C9` type-pair channel.** -/
theorem Ipair_val_9 : Ipair 9 = (-100/81 : ℝ) + (10/9 : ℝ) * Real.logb 2 3 := by
  rw [Ipair_eq, pairEntropy_val_9, condPairEntropy_val_9]
  ring

/-! ### The abstract cyclic order `C15` -/

/-- Exact type entropy of the `C15` channel. -/
theorem typeEntropy_val_15 : typeEntropy 15 = (-34/15 : ℝ) + (1 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
  have h : ((range 15).image (ordType 15)).val.map
      (fun v => (#{x ∈ range 15 | ordType 15 x = v} : ℕ)) = (↑[1, 2, 4, 8] : Multiset ℕ) := by decide
  rw [typeEntropy, uEnt_eq_countSum _ _ _ h, show (range 15).card = 15 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
  ring

/-- Exact entropy of the unordered type pair of a `C15` semiprime. -/
theorem pairEntropy_val_15 : pairEntropy 15 = (-232/45 : ℝ) + (2 : ℝ) * Real.logb 2 3 + (2 : ℝ) * Real.logb 2 5 := by
  have h : ((box 15).image (typePair 15)).val.map
      (fun v => (#{q ∈ box 15 | typePair 15 q = v} : ℕ)) = (↑[1, 4, 4, 8, 16, 16, 16, 32, 64, 64] : Multiset ℕ) := by decide
  rw [pairEntropy, uEnt_eq_countSum _ _ _ h, show (box 15).card = 225 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
  ring

/-- Exact conditional entropy of the type pair given the residue of the product. -/
theorem condPairEntropy_val_15 : condPairEntropy 15 = (-262/225 : ℝ) + (13/25 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
  have himg : (box 15).image (prodRes 15) = range 15 := by decide
  have e0 : uEnt {x ∈ box 15 | prodRes 15 x = 0} (typePair 15) = (-34/15 : ℝ) + (1 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 15 | prodRes 15 x = 0}).image (typePair 15)).val.map
        (fun v => (#{q ∈ {x ∈ box 15 | prodRes 15 x = 0} | typePair 15 q = v} : ℕ))
        = (↑[1, 2, 4, 8] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 15 | prodRes 15 x = 0}) = 15 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e1 : uEnt {x ∈ box 15 | prodRes 15 x = 1} (typePair 15) = (-4/5 : ℝ) + (2/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 15 | prodRes 15 x = 1}).image (typePair 15)).val.map
        (fun v => (#{q ∈ {x ∈ box 15 | prodRes 15 x = 1} | typePair 15 q = v} : ℕ))
        = (↑[2, 2, 2, 3, 6] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 15 | prodRes 15 x = 1}) = 15 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e2 : uEnt {x ∈ box 15 | prodRes 15 x = 2} (typePair 15) = (-4/5 : ℝ) + (2/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 15 | prodRes 15 x = 2}).image (typePair 15)).val.map
        (fun v => (#{q ∈ {x ∈ box 15 | prodRes 15 x = 2} | typePair 15 q = v} : ℕ))
        = (↑[2, 2, 2, 3, 6] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 15 | prodRes 15 x = 2}) = 15 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e3 : uEnt {x ∈ box 15 | prodRes 15 x = 3} (typePair 15) = (-16/15 : ℝ) + (2/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 15 | prodRes 15 x = 3}).image (typePair 15)).val.map
        (fun v => (#{q ∈ {x ∈ box 15 | prodRes 15 x = 3} | typePair 15 q = v} : ℕ))
        = (↑[2, 3, 4, 6] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 15 | prodRes 15 x = 3}) = 15 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e4 : uEnt {x ∈ box 15 | prodRes 15 x = 4} (typePair 15) = (-4/5 : ℝ) + (2/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 15 | prodRes 15 x = 4}).image (typePair 15)).val.map
        (fun v => (#{q ∈ {x ∈ box 15 | prodRes 15 x = 4} | typePair 15 q = v} : ℕ))
        = (↑[2, 2, 2, 3, 6] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 15 | prodRes 15 x = 4}) = 15 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e5 : uEnt {x ∈ box 15 | prodRes 15 x = 5} (typePair 15) = (-34/15 : ℝ) + (1 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 15 | prodRes 15 x = 5}).image (typePair 15)).val.map
        (fun v => (#{q ∈ {x ∈ box 15 | prodRes 15 x = 5} | typePair 15 q = v} : ℕ))
        = (↑[1, 2, 4, 8] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 15 | prodRes 15 x = 5}) = 15 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e6 : uEnt {x ∈ box 15 | prodRes 15 x = 6} (typePair 15) = (-16/15 : ℝ) + (2/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 15 | prodRes 15 x = 6}).image (typePair 15)).val.map
        (fun v => (#{q ∈ {x ∈ box 15 | prodRes 15 x = 6} | typePair 15 q = v} : ℕ))
        = (↑[2, 3, 4, 6] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 15 | prodRes 15 x = 6}) = 15 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e7 : uEnt {x ∈ box 15 | prodRes 15 x = 7} (typePair 15) = (-4/5 : ℝ) + (2/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 15 | prodRes 15 x = 7}).image (typePair 15)).val.map
        (fun v => (#{q ∈ {x ∈ box 15 | prodRes 15 x = 7} | typePair 15 q = v} : ℕ))
        = (↑[2, 2, 2, 3, 6] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 15 | prodRes 15 x = 7}) = 15 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e8 : uEnt {x ∈ box 15 | prodRes 15 x = 8} (typePair 15) = (-4/5 : ℝ) + (2/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 15 | prodRes 15 x = 8}).image (typePair 15)).val.map
        (fun v => (#{q ∈ {x ∈ box 15 | prodRes 15 x = 8} | typePair 15 q = v} : ℕ))
        = (↑[2, 2, 2, 3, 6] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 15 | prodRes 15 x = 8}) = 15 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e9 : uEnt {x ∈ box 15 | prodRes 15 x = 9} (typePair 15) = (-16/15 : ℝ) + (2/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 15 | prodRes 15 x = 9}).image (typePair 15)).val.map
        (fun v => (#{q ∈ {x ∈ box 15 | prodRes 15 x = 9} | typePair 15 q = v} : ℕ))
        = (↑[2, 3, 4, 6] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 15 | prodRes 15 x = 9}) = 15 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e10 : uEnt {x ∈ box 15 | prodRes 15 x = 10} (typePair 15) = (-34/15 : ℝ) + (1 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 15 | prodRes 15 x = 10}).image (typePair 15)).val.map
        (fun v => (#{q ∈ {x ∈ box 15 | prodRes 15 x = 10} | typePair 15 q = v} : ℕ))
        = (↑[1, 2, 4, 8] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 15 | prodRes 15 x = 10}) = 15 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e11 : uEnt {x ∈ box 15 | prodRes 15 x = 11} (typePair 15) = (-4/5 : ℝ) + (2/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 15 | prodRes 15 x = 11}).image (typePair 15)).val.map
        (fun v => (#{q ∈ {x ∈ box 15 | prodRes 15 x = 11} | typePair 15 q = v} : ℕ))
        = (↑[2, 2, 2, 3, 6] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 15 | prodRes 15 x = 11}) = 15 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e12 : uEnt {x ∈ box 15 | prodRes 15 x = 12} (typePair 15) = (-16/15 : ℝ) + (2/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 15 | prodRes 15 x = 12}).image (typePair 15)).val.map
        (fun v => (#{q ∈ {x ∈ box 15 | prodRes 15 x = 12} | typePair 15 q = v} : ℕ))
        = (↑[2, 3, 4, 6] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 15 | prodRes 15 x = 12}) = 15 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e13 : uEnt {x ∈ box 15 | prodRes 15 x = 13} (typePair 15) = (-4/5 : ℝ) + (2/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 15 | prodRes 15 x = 13}).image (typePair 15)).val.map
        (fun v => (#{q ∈ {x ∈ box 15 | prodRes 15 x = 13} | typePair 15 q = v} : ℕ))
        = (↑[2, 2, 2, 3, 6] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 15 | prodRes 15 x = 13}) = 15 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  have e14 : uEnt {x ∈ box 15 | prodRes 15 x = 14} (typePair 15) = (-4/5 : ℝ) + (2/5 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
    have h : (({x ∈ box 15 | prodRes 15 x = 14}).image (typePair 15)).val.map
        (fun v => (#{q ∈ {x ∈ box 15 | prodRes 15 x = 14} | typePair 15 q = v} : ℕ))
        = (↑[2, 2, 2, 3, 6] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ box 15 | prodRes 15 x = 14}) = 15 from by decide]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256]
    ring
  rw [condPairEntropy, condEnt, himg, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one,
    e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12, e13, e14]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_10, lb_12, lb_15, lb_16, lb_24, lb_25, lb_32, lb_36, lb_64, lb_81, lb_100, lb_144, lb_225, lb_256, show (box 15).card = 225 from by decide,
    show (#{x ∈ box 15 | prodRes 15 x = 0}) = 15 from by decide,
    show (#{x ∈ box 15 | prodRes 15 x = 1}) = 15 from by decide,
    show (#{x ∈ box 15 | prodRes 15 x = 2}) = 15 from by decide,
    show (#{x ∈ box 15 | prodRes 15 x = 3}) = 15 from by decide,
    show (#{x ∈ box 15 | prodRes 15 x = 4}) = 15 from by decide,
    show (#{x ∈ box 15 | prodRes 15 x = 5}) = 15 from by decide,
    show (#{x ∈ box 15 | prodRes 15 x = 6}) = 15 from by decide,
    show (#{x ∈ box 15 | prodRes 15 x = 7}) = 15 from by decide,
    show (#{x ∈ box 15 | prodRes 15 x = 8}) = 15 from by decide,
    show (#{x ∈ box 15 | prodRes 15 x = 9}) = 15 from by decide,
    show (#{x ∈ box 15 | prodRes 15 x = 10}) = 15 from by decide,
    show (#{x ∈ box 15 | prodRes 15 x = 11}) = 15 from by decide,
    show (#{x ∈ box 15 | prodRes 15 x = 12}) = 15 from by decide,
    show (#{x ∈ box 15 | prodRes 15 x = 13}) = 15 from by decide,
    show (#{x ∈ box 15 | prodRes 15 x = 14}) = 15 from by decide]
  ring

/-- **The `C15` type-pair channel.** -/
theorem Ipair_val_15 : Ipair 15 = (-898/225 : ℝ) + (37/25 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
  rw [Ipair_eq, pairEntropy_val_15, condPairEntropy_val_15]
  ring

/-! ### CRT additivity of the type-pair information

For coprime cyclic orders the information carried by the unordered type pair of
a semiprime splits as a sum over the primary components. -/

/-- `I_pair(6) = I_pair(2) + I_pair(3)`. -/
theorem Ipair_crt_two_three : Ipair 6 = Ipair 2 + Ipair 3 := by
  rw [Ipair_val_6, Ipair_val_2, Ipair_val_3]; ring

/-- `I_pair(10) = I_pair(2) + I_pair(5)`. -/
theorem Ipair_crt_two_five : Ipair 10 = Ipair 2 + Ipair 5 := by
  rw [Ipair_val_10, Ipair_val_2, Ipair_val_5]; ring

/-- `I_pair(12) = I_pair(4) + I_pair(3)`. -/
theorem Ipair_crt_four_three : Ipair 12 = Ipair 4 + Ipair 3 := by
  rw [Ipair_val_12, Ipair_val_4, Ipair_val_3]; ring

/-- `I_pair(15) = I_pair(3) + I_pair(5)`. -/
theorem Ipair_crt_three_five : Ipair 15 = Ipair 3 + Ipair 5 := by
  rw [Ipair_val_15, Ipair_val_3, Ipair_val_5]; ring

/-! ### Evenness, not compositeness, is what breaks the cap -/

/-- The purely `2`-primary order `8` is above the binary-fork cap. -/
theorem one_lt_Ipair_eight : 1 < Ipair 8 := by
  rw [Ipair_val_8]; norm_num

/-- The odd order `3` is strictly below the binary-fork cap. -/
theorem Ipair_three_lt_one : Ipair 3 < 1 := by
  have h3 := lb_three_lt
  rw [Ipair_val_3]; linarith

/-- The odd order `5` is strictly below the binary-fork cap. -/
theorem Ipair_five_lt_one : Ipair 5 < 1 := by
  have h3 := lb_three_lt
  have h5 := lb_five_lt
  rw [Ipair_val_5]; linarith

/-- The odd (composite, non-squarefree) order `9` is strictly below the cap. -/
theorem Ipair_nine_lt_one : Ipair 9 < 1 := by
  have h3 := lb_three_lt
  rw [Ipair_val_9]; linarith

/-- The odd (composite, squarefree) order `15` is strictly below the cap. -/
theorem Ipair_fifteen_lt_one : Ipair 15 < 1 := by
  have h3 := lb_three_lt
  have h5 := lb_five_lt
  rw [Ipair_val_15]; linarith

/-- **Compositeness is not the trigger.**  The order `15` is composite with two
distinct prime factors, yet its type-pair channel stays below one bit, whereas
the prime-power order `8` exceeds it.  Hence no monotone function of the number
of divisors can govern the cap. -/
theorem cap_not_governed_by_compositeness :
    Ipair 15 < 1 ∧ 1 < Ipair 8 :=
  ⟨Ipair_fifteen_lt_one, one_lt_Ipair_eight⟩

/-- **All odd orders computed here are below the cap, all even ones above (or at)
it.**  This suggests that the order-two element is the source of the above-cap
behaviour — a reading that is *refuted* in `Shared.CyclicTypeChannelOdd`, where
an explicit odd order with `Ipair > 1` is produced by accumulating sixteen odd
primary parts. -/
theorem odd_orders_below_cap :
    Ipair 3 < 1 ∧ Ipair 5 < 1 ∧ Ipair 9 < 1 ∧ Ipair 15 < 1 :=
  ⟨Ipair_three_lt_one, Ipair_five_lt_one, Ipair_nine_lt_one, Ipair_fifteen_lt_one⟩

/-! ### A value beyond the reach of enumeration

`n = 60` has a sample box of `3600` pairs, out of reach of direct kernel
enumeration; the CRT law computes it from the primary parts `4` and `15`. -/

/-- Exact value of the three-primary order `60`, obtained from the CRT law. -/
theorem Ipair_val_60 :
    Ipair 60 = (-2467/900 : ℝ) + (37/25 : ℝ) * Real.logb 2 3 + (1 : ℝ) * Real.logb 2 5 := by
  have h : Ipair (4 * 15) = Ipair 4 + Ipair 15 :=
    Ipair_mul_of_coprime (by norm_num) (by norm_num) (by decide)
  rw [show (60 : ℕ) = 4 * 15 from by norm_num, h, Ipair_val_4, Ipair_val_15]
  ring

/-- The three-primary order `60` carries more than `7/4` bits — far above the
binary-fork cap, and beyond every value in the enumerated table. -/
theorem Ipair_sixty_gt : (7 : ℝ) / 4 < Ipair 60 := by
  have h3 := lb_three_gt
  have h5 := lb_five_gt
  rw [Ipair_val_60]
  linarith

end CyclicTypeChannel