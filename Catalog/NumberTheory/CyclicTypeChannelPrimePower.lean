/-
# Prime-power values of the cyclic splitting-type channel

The CRT law `Ipair (m * n) = Ipair m + Ipair n` for coprime `m, n` reduces the
whole channel to its **prime-power** values.  This file pushes the two
prime-power ladders one step further than the previously evaluated orders,
adding the exact values at `n = 32 = 2^5` and `n = 27 = 3^3`, and records the
resulting geometric structure of the increments:

* `Ipair (2^(k+1)) - Ipair (2^k) = (1/4)^k`  for `k = 1, 2, 3, 4`;
* `Ipair (3^(k+1)) - Ipair (3^k) = (1/9)^k * Ipair 3`  for `k = 1, 2`;

which is exactly the local ("geometric increment") form of the conjectured
prime-power closed form
`Ipair (p^k) = (1 - p^(-2k)) * p^2/(p^2-1) * Ipair p`,
here verified at `p = 2, k ≤ 5` and `p = 3, k ≤ 3`.

Every value is obtained from the count form `uEnt_eq_countSum` of the entropy
together with a kernel-checked enumeration of the fibre cardinalities.
-/
import Catalog.Shared.CyclicTypeChannel
import Catalog.Shared.CyclicTypeChannelValues
import Catalog.Shared.CyclicTypeChannelCRT

namespace CyclicTypeChannel

open Finset

set_option maxRecDepth 1000000
set_option maxHeartbeats 4000000

/-! ### Base-two logarithms of the numerals that occur -/


lemma lb_128 : Real.logb 2 (128 : ℝ) = 7 := by
  rw [show (128 : ℝ) = 2 ^ (7 : ℕ) by norm_num, lb_pow]; norm_num

lemma lb_1024 : Real.logb 2 (1024 : ℝ) = 10 := by
  rw [show (1024 : ℝ) = 2 ^ (10 : ℕ) by norm_num, lb_pow]; norm_num

lemma lb_18 : Real.logb 2 (18 : ℝ) = 1 + 2 * Real.logb 2 3 := by
  rw [show (18 : ℝ) = 2 * (3 * 3) by norm_num, Real.logb_mul (by norm_num) (by norm_num),
    Real.logb_mul (by norm_num) (by norm_num)]
  simp; ring

lemma lb_27 : Real.logb 2 (27 : ℝ) = 3 * Real.logb 2 3 := by
  rw [show (27 : ℝ) = 3 ^ (3 : ℕ) by norm_num, Real.logb_pow]
  norm_num

lemma lb_72 : Real.logb 2 (72 : ℝ) = 3 + 2 * Real.logb 2 3 := by
  rw [show (72 : ℝ) = 8 * (3 * 3) by norm_num, Real.logb_mul (by norm_num) (by norm_num),
    Real.logb_mul (by norm_num) (by norm_num), lb_8]
  ring

lemma lb_216 : Real.logb 2 (216 : ℝ) = 3 + 3 * Real.logb 2 3 := by
  rw [show (216 : ℝ) = 8 * 27 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_8, lb_27]

lemma lb_324 : Real.logb 2 (324 : ℝ) = 2 + 4 * Real.logb 2 3 := by
  rw [show (324 : ℝ) = 4 * 81 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_4, lb_81]

lemma lb_729 : Real.logb 2 (729 : ℝ) = 6 * Real.logb 2 3 := by
  rw [show (729 : ℝ) = 3 ^ (6 : ℕ) by norm_num, Real.logb_pow]
  norm_num

/-! ### The prime-power order `n = 32` -/

/-- Exact type entropy at order `32`. -/
theorem typeEntropy_val_32 : typeEntropy 32 = (31/16 : ℝ) := by
  have h : ((range 32).image (ordType 32)).val.map
      (fun v => (#{x ∈ range 32 | ordType 32 x = v} : ℕ)) = (↑[1, 1, 2, 4, 8, 16] : Multiset ℕ) := by decide
  rw [typeEntropy, uEnt_eq_countSum _ _ _ h, show (range 32).card = 32 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]

/-- Exact type-pair entropy at order `32`. -/
theorem pairEntropy_val_32 : pairEntropy 32 = (1643/512 : ℝ) := by
  have h : ((box 32).image (typePair 32)).val.map
      (fun v => (#{q ∈ box 32 | typePair 32 q = v} : ℕ)) = (↑[1, 1, 2, 4, 4, 4, 8, 8, 16, 16, 16, 16, 32, 32, 32, 64, 64, 64, 128, 256, 256] : Multiset ℕ) := by decide
  rw [pairEntropy, uEnt_eq_countSum _ _ _ h, show (box 32).card = 1024 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]

/-- Exact conditional type-pair entropy at order `32`. -/
theorem condPairEntropy_val_32 : condPairEntropy 32 = (961/512 : ℝ) := by
  have himg : (box 32).image (prodRes 32) = range 32 := by decide
  have hc0 : (#{x ∈ box 32 | prodRes 32 x = 0}) = 32 := by decide
  have hc1 : (#{x ∈ box 32 | prodRes 32 x = 1}) = 32 := by decide
  have hc2 : (#{x ∈ box 32 | prodRes 32 x = 2}) = 32 := by decide
  have hc3 : (#{x ∈ box 32 | prodRes 32 x = 3}) = 32 := by decide
  have hc4 : (#{x ∈ box 32 | prodRes 32 x = 4}) = 32 := by decide
  have hc5 : (#{x ∈ box 32 | prodRes 32 x = 5}) = 32 := by decide
  have hc6 : (#{x ∈ box 32 | prodRes 32 x = 6}) = 32 := by decide
  have hc7 : (#{x ∈ box 32 | prodRes 32 x = 7}) = 32 := by decide
  have hc8 : (#{x ∈ box 32 | prodRes 32 x = 8}) = 32 := by decide
  have hc9 : (#{x ∈ box 32 | prodRes 32 x = 9}) = 32 := by decide
  have hc10 : (#{x ∈ box 32 | prodRes 32 x = 10}) = 32 := by decide
  have hc11 : (#{x ∈ box 32 | prodRes 32 x = 11}) = 32 := by decide
  have hc12 : (#{x ∈ box 32 | prodRes 32 x = 12}) = 32 := by decide
  have hc13 : (#{x ∈ box 32 | prodRes 32 x = 13}) = 32 := by decide
  have hc14 : (#{x ∈ box 32 | prodRes 32 x = 14}) = 32 := by decide
  have hc15 : (#{x ∈ box 32 | prodRes 32 x = 15}) = 32 := by decide
  have hc16 : (#{x ∈ box 32 | prodRes 32 x = 16}) = 32 := by decide
  have hc17 : (#{x ∈ box 32 | prodRes 32 x = 17}) = 32 := by decide
  have hc18 : (#{x ∈ box 32 | prodRes 32 x = 18}) = 32 := by decide
  have hc19 : (#{x ∈ box 32 | prodRes 32 x = 19}) = 32 := by decide
  have hc20 : (#{x ∈ box 32 | prodRes 32 x = 20}) = 32 := by decide
  have hc21 : (#{x ∈ box 32 | prodRes 32 x = 21}) = 32 := by decide
  have hc22 : (#{x ∈ box 32 | prodRes 32 x = 22}) = 32 := by decide
  have hc23 : (#{x ∈ box 32 | prodRes 32 x = 23}) = 32 := by decide
  have hc24 : (#{x ∈ box 32 | prodRes 32 x = 24}) = 32 := by decide
  have hc25 : (#{x ∈ box 32 | prodRes 32 x = 25}) = 32 := by decide
  have hc26 : (#{x ∈ box 32 | prodRes 32 x = 26}) = 32 := by decide
  have hc27 : (#{x ∈ box 32 | prodRes 32 x = 27}) = 32 := by decide
  have hc28 : (#{x ∈ box 32 | prodRes 32 x = 28}) = 32 := by decide
  have hc29 : (#{x ∈ box 32 | prodRes 32 x = 29}) = 32 := by decide
  have hc30 : (#{x ∈ box 32 | prodRes 32 x = 30}) = 32 := by decide
  have hc31 : (#{x ∈ box 32 | prodRes 32 x = 31}) = 32 := by decide
  have e0 : uEnt {x ∈ box 32 | prodRes 32 x = 0} (typePair 32) = (31/16 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 0}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 0} | typePair 32 q = v} : ℕ)))
        = (↑[1, 1, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc0]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e1 : uEnt {x ∈ box 32 | prodRes 32 x = 1} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 1}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 1} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc1]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e2 : uEnt {x ∈ box 32 | prodRes 32 x = 2} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 2}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 2} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc2]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e3 : uEnt {x ∈ box 32 | prodRes 32 x = 3} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 3}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 3} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc3]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e4 : uEnt {x ∈ box 32 | prodRes 32 x = 4} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 4}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 4} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc4]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e5 : uEnt {x ∈ box 32 | prodRes 32 x = 5} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 5}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 5} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc5]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e6 : uEnt {x ∈ box 32 | prodRes 32 x = 6} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 6}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 6} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc6]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e7 : uEnt {x ∈ box 32 | prodRes 32 x = 7} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 7}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 7} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc7]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e8 : uEnt {x ∈ box 32 | prodRes 32 x = 8} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 8}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 8} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc8]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e9 : uEnt {x ∈ box 32 | prodRes 32 x = 9} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 9}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 9} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc9]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e10 : uEnt {x ∈ box 32 | prodRes 32 x = 10} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 10}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 10} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc10]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e11 : uEnt {x ∈ box 32 | prodRes 32 x = 11} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 11}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 11} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc11]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e12 : uEnt {x ∈ box 32 | prodRes 32 x = 12} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 12}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 12} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc12]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e13 : uEnt {x ∈ box 32 | prodRes 32 x = 13} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 13}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 13} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc13]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e14 : uEnt {x ∈ box 32 | prodRes 32 x = 14} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 14}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 14} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc14]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e15 : uEnt {x ∈ box 32 | prodRes 32 x = 15} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 15}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 15} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc15]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e16 : uEnt {x ∈ box 32 | prodRes 32 x = 16} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 16}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 16} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc16]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e17 : uEnt {x ∈ box 32 | prodRes 32 x = 17} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 17}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 17} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc17]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e18 : uEnt {x ∈ box 32 | prodRes 32 x = 18} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 18}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 18} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc18]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e19 : uEnt {x ∈ box 32 | prodRes 32 x = 19} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 19}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 19} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc19]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e20 : uEnt {x ∈ box 32 | prodRes 32 x = 20} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 20}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 20} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc20]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e21 : uEnt {x ∈ box 32 | prodRes 32 x = 21} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 21}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 21} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc21]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e22 : uEnt {x ∈ box 32 | prodRes 32 x = 22} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 22}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 22} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc22]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e23 : uEnt {x ∈ box 32 | prodRes 32 x = 23} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 23}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 23} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc23]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e24 : uEnt {x ∈ box 32 | prodRes 32 x = 24} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 24}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 24} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc24]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e25 : uEnt {x ∈ box 32 | prodRes 32 x = 25} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 25}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 25} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc25]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e26 : uEnt {x ∈ box 32 | prodRes 32 x = 26} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 26}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 26} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc26]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e27 : uEnt {x ∈ box 32 | prodRes 32 x = 27} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 27}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 27} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc27]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e28 : uEnt {x ∈ box 32 | prodRes 32 x = 28} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 28}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 28} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc28]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e29 : uEnt {x ∈ box 32 | prodRes 32 x = 29} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 29}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 29} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc29]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e30 : uEnt {x ∈ box 32 | prodRes 32 x = 30} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 30}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 30} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc30]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  have e31 : uEnt {x ∈ box 32 | prodRes 32 x = 31} (typePair 32) = (15/8 : ℝ) := by
    have h : ((({x ∈ box 32 | prodRes 32 x = 31}).image (typePair 32)).val.map
        (fun v => (#{q ∈ {x ∈ box 32 | prodRes 32 x = 31} | typePair 32 q = v} : ℕ)))
        = (↑[2, 2, 4, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc31]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  rw [condPairEntropy, condEnt, himg, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one,
    e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12, e13, e14, e15, e16, e17, e18, e19, e20, e21, e22, e23, e24, e25, e26, e27, e28, e29, e30, e31]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024, show (box 32).card = 1024 from by decide,
    hc0, hc1, hc2, hc3, hc4, hc5, hc6, hc7, hc8, hc9, hc10, hc11, hc12, hc13, hc14, hc15, hc16, hc17, hc18, hc19, hc20, hc21, hc22, hc23, hc24, hc25, hc26, hc27, hc28, hc29, hc30, hc31]

/-- **The type-pair channel at the prime-power order `32`.** -/
theorem Ipair_val_32 : Ipair 32 = (341/256 : ℝ) := by
  rw [Ipair_eq, pairEntropy_val_32, condPairEntropy_val_32]
  ring

/-! ### The prime-power order `n = 27` -/

/-- Exact type entropy at order `27`. -/
theorem typeEntropy_val_27 : typeEntropy 27 = (-26/27 : ℝ) + (13/9 : ℝ) * Real.logb 2 3 := by
  have h : ((range 27).image (ordType 27)).val.map
      (fun v => (#{x ∈ range 27 | ordType 27 x = v} : ℕ)) = (↑[1, 2, 6, 18] : Multiset ℕ) := by decide
  rw [typeEntropy, uEnt_eq_countSum _ _ _ h, show (range 27).card = 27 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  ring

/-- Exact type-pair entropy at order `27`. -/
theorem pairEntropy_val_27 : pairEntropy 27 = (-1768/729 : ℝ) + (26/9 : ℝ) * Real.logb 2 3 := by
  have h : ((box 27).image (typePair 27)).val.map
      (fun v => (#{q ∈ box 27 | typePair 27 q = v} : ℕ)) = (↑[1, 4, 4, 12, 24, 36, 36, 72, 216, 324] : Multiset ℕ) := by decide
  rw [pairEntropy, uEnt_eq_countSum _ _ _ h, show (box 27).card = 729 from by decide]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
  ring

/-- Exact conditional type-pair entropy at order `27`. -/
theorem condPairEntropy_val_27 : condPairEntropy 27 = (-286/243 : ℝ) + (143/81 : ℝ) * Real.logb 2 3 := by
  have himg : (box 27).image (prodRes 27) = range 27 := by decide
  have hc0 : (#{x ∈ box 27 | prodRes 27 x = 0}) = 27 := by decide
  have hc1 : (#{x ∈ box 27 | prodRes 27 x = 1}) = 27 := by decide
  have hc2 : (#{x ∈ box 27 | prodRes 27 x = 2}) = 27 := by decide
  have hc3 : (#{x ∈ box 27 | prodRes 27 x = 3}) = 27 := by decide
  have hc4 : (#{x ∈ box 27 | prodRes 27 x = 4}) = 27 := by decide
  have hc5 : (#{x ∈ box 27 | prodRes 27 x = 5}) = 27 := by decide
  have hc6 : (#{x ∈ box 27 | prodRes 27 x = 6}) = 27 := by decide
  have hc7 : (#{x ∈ box 27 | prodRes 27 x = 7}) = 27 := by decide
  have hc8 : (#{x ∈ box 27 | prodRes 27 x = 8}) = 27 := by decide
  have hc9 : (#{x ∈ box 27 | prodRes 27 x = 9}) = 27 := by decide
  have hc10 : (#{x ∈ box 27 | prodRes 27 x = 10}) = 27 := by decide
  have hc11 : (#{x ∈ box 27 | prodRes 27 x = 11}) = 27 := by decide
  have hc12 : (#{x ∈ box 27 | prodRes 27 x = 12}) = 27 := by decide
  have hc13 : (#{x ∈ box 27 | prodRes 27 x = 13}) = 27 := by decide
  have hc14 : (#{x ∈ box 27 | prodRes 27 x = 14}) = 27 := by decide
  have hc15 : (#{x ∈ box 27 | prodRes 27 x = 15}) = 27 := by decide
  have hc16 : (#{x ∈ box 27 | prodRes 27 x = 16}) = 27 := by decide
  have hc17 : (#{x ∈ box 27 | prodRes 27 x = 17}) = 27 := by decide
  have hc18 : (#{x ∈ box 27 | prodRes 27 x = 18}) = 27 := by decide
  have hc19 : (#{x ∈ box 27 | prodRes 27 x = 19}) = 27 := by decide
  have hc20 : (#{x ∈ box 27 | prodRes 27 x = 20}) = 27 := by decide
  have hc21 : (#{x ∈ box 27 | prodRes 27 x = 21}) = 27 := by decide
  have hc22 : (#{x ∈ box 27 | prodRes 27 x = 22}) = 27 := by decide
  have hc23 : (#{x ∈ box 27 | prodRes 27 x = 23}) = 27 := by decide
  have hc24 : (#{x ∈ box 27 | prodRes 27 x = 24}) = 27 := by decide
  have hc25 : (#{x ∈ box 27 | prodRes 27 x = 25}) = 27 := by decide
  have hc26 : (#{x ∈ box 27 | prodRes 27 x = 26}) = 27 := by decide
  have e0 : uEnt {x ∈ box 27 | prodRes 27 x = 0} (typePair 27) = (-26/27 : ℝ) + (13/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 0}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 0} | typePair 27 q = v} : ℕ)))
        = (↑[1, 2, 6, 18] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc0]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e1 : uEnt {x ∈ box 27 | prodRes 27 x = 1} (typePair 27) = (-34/27 : ℝ) + (17/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 1}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 1} | typePair 27 q = v} : ℕ)))
        = (↑[2, 4, 9, 12] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc1]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e2 : uEnt {x ∈ box 27 | prodRes 27 x = 2} (typePair 27) = (-34/27 : ℝ) + (17/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 2}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 2} | typePair 27 q = v} : ℕ)))
        = (↑[2, 4, 9, 12] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc2]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e3 : uEnt {x ∈ box 27 | prodRes 27 x = 3} (typePair 27) = (-28/27 : ℝ) + (14/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 3}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 3} | typePair 27 q = v} : ℕ)))
        = (↑[2, 3, 4, 18] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc3]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e4 : uEnt {x ∈ box 27 | prodRes 27 x = 4} (typePair 27) = (-34/27 : ℝ) + (17/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 4}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 4} | typePair 27 q = v} : ℕ)))
        = (↑[2, 4, 9, 12] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc4]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e5 : uEnt {x ∈ box 27 | prodRes 27 x = 5} (typePair 27) = (-34/27 : ℝ) + (17/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 5}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 5} | typePair 27 q = v} : ℕ)))
        = (↑[2, 4, 9, 12] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc5]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e6 : uEnt {x ∈ box 27 | prodRes 27 x = 6} (typePair 27) = (-28/27 : ℝ) + (14/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 6}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 6} | typePair 27 q = v} : ℕ)))
        = (↑[2, 3, 4, 18] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc6]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e7 : uEnt {x ∈ box 27 | prodRes 27 x = 7} (typePair 27) = (-34/27 : ℝ) + (17/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 7}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 7} | typePair 27 q = v} : ℕ)))
        = (↑[2, 4, 9, 12] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc7]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e8 : uEnt {x ∈ box 27 | prodRes 27 x = 8} (typePair 27) = (-34/27 : ℝ) + (17/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 8}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 8} | typePair 27 q = v} : ℕ)))
        = (↑[2, 4, 9, 12] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc8]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e9 : uEnt {x ∈ box 27 | prodRes 27 x = 9} (typePair 27) = (-26/27 : ℝ) + (13/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 9}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 9} | typePair 27 q = v} : ℕ)))
        = (↑[1, 2, 6, 18] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc9]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e10 : uEnt {x ∈ box 27 | prodRes 27 x = 10} (typePair 27) = (-34/27 : ℝ) + (17/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 10}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 10} | typePair 27 q = v} : ℕ)))
        = (↑[2, 4, 9, 12] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc10]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e11 : uEnt {x ∈ box 27 | prodRes 27 x = 11} (typePair 27) = (-34/27 : ℝ) + (17/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 11}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 11} | typePair 27 q = v} : ℕ)))
        = (↑[2, 4, 9, 12] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc11]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e12 : uEnt {x ∈ box 27 | prodRes 27 x = 12} (typePair 27) = (-28/27 : ℝ) + (14/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 12}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 12} | typePair 27 q = v} : ℕ)))
        = (↑[2, 3, 4, 18] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc12]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e13 : uEnt {x ∈ box 27 | prodRes 27 x = 13} (typePair 27) = (-34/27 : ℝ) + (17/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 13}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 13} | typePair 27 q = v} : ℕ)))
        = (↑[2, 4, 9, 12] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc13]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e14 : uEnt {x ∈ box 27 | prodRes 27 x = 14} (typePair 27) = (-34/27 : ℝ) + (17/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 14}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 14} | typePair 27 q = v} : ℕ)))
        = (↑[2, 4, 9, 12] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc14]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e15 : uEnt {x ∈ box 27 | prodRes 27 x = 15} (typePair 27) = (-28/27 : ℝ) + (14/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 15}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 15} | typePair 27 q = v} : ℕ)))
        = (↑[2, 3, 4, 18] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc15]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e16 : uEnt {x ∈ box 27 | prodRes 27 x = 16} (typePair 27) = (-34/27 : ℝ) + (17/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 16}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 16} | typePair 27 q = v} : ℕ)))
        = (↑[2, 4, 9, 12] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc16]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e17 : uEnt {x ∈ box 27 | prodRes 27 x = 17} (typePair 27) = (-34/27 : ℝ) + (17/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 17}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 17} | typePair 27 q = v} : ℕ)))
        = (↑[2, 4, 9, 12] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc17]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e18 : uEnt {x ∈ box 27 | prodRes 27 x = 18} (typePair 27) = (-26/27 : ℝ) + (13/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 18}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 18} | typePair 27 q = v} : ℕ)))
        = (↑[1, 2, 6, 18] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc18]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e19 : uEnt {x ∈ box 27 | prodRes 27 x = 19} (typePair 27) = (-34/27 : ℝ) + (17/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 19}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 19} | typePair 27 q = v} : ℕ)))
        = (↑[2, 4, 9, 12] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc19]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e20 : uEnt {x ∈ box 27 | prodRes 27 x = 20} (typePair 27) = (-34/27 : ℝ) + (17/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 20}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 20} | typePair 27 q = v} : ℕ)))
        = (↑[2, 4, 9, 12] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc20]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e21 : uEnt {x ∈ box 27 | prodRes 27 x = 21} (typePair 27) = (-28/27 : ℝ) + (14/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 21}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 21} | typePair 27 q = v} : ℕ)))
        = (↑[2, 3, 4, 18] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc21]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e22 : uEnt {x ∈ box 27 | prodRes 27 x = 22} (typePair 27) = (-34/27 : ℝ) + (17/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 22}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 22} | typePair 27 q = v} : ℕ)))
        = (↑[2, 4, 9, 12] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc22]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e23 : uEnt {x ∈ box 27 | prodRes 27 x = 23} (typePair 27) = (-34/27 : ℝ) + (17/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 23}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 23} | typePair 27 q = v} : ℕ)))
        = (↑[2, 4, 9, 12] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc23]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e24 : uEnt {x ∈ box 27 | prodRes 27 x = 24} (typePair 27) = (-28/27 : ℝ) + (14/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 24}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 24} | typePair 27 q = v} : ℕ)))
        = (↑[2, 3, 4, 18] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc24]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e25 : uEnt {x ∈ box 27 | prodRes 27 x = 25} (typePair 27) = (-34/27 : ℝ) + (17/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 25}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 25} | typePair 27 q = v} : ℕ)))
        = (↑[2, 4, 9, 12] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc25]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  have e26 : uEnt {x ∈ box 27 | prodRes 27 x = 26} (typePair 27) = (-34/27 : ℝ) + (17/9 : ℝ) * Real.logb 2 3 := by
    have h : ((({x ∈ box 27 | prodRes 27 x = 26}).image (typePair 27)).val.map
        (fun v => (#{q ∈ {x ∈ box 27 | prodRes 27 x = 26} | typePair 27 q = v} : ℕ)))
        = (↑[2, 4, 9, 12] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, hc26]
    norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024]
    ring
  rw [condPairEntropy, condEnt, himg, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one,
    e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12, e13, e14, e15, e16, e17, e18, e19, e20, e21, e22, e23, e24, e25, e26]
  norm_num [lb_4, lb_6, lb_8, lb_9, lb_12, lb_16, lb_18, lb_24, lb_27, lb_32, lb_36, lb_64, lb_72, lb_81, lb_128, lb_216, lb_256, lb_324, lb_729, lb_1024, show (box 27).card = 729 from by decide,
    hc0, hc1, hc2, hc3, hc4, hc5, hc6, hc7, hc8, hc9, hc10, hc11, hc12, hc13, hc14, hc15, hc16, hc17, hc18, hc19, hc20, hc21, hc22, hc23, hc24, hc25, hc26]
  ring

/-- **The type-pair channel at the prime-power order `27`.** -/
theorem Ipair_val_27 : Ipair 27 = (-910/729 : ℝ) + (91/81 : ℝ) * Real.logb 2 3 := by
  rw [Ipair_eq, pairEntropy_val_27, condPairEntropy_val_27]
  ring


/-! ### The geometric increment law along the prime-power ladders -/

/-- **The 2-power ladder.** For `1 ≤ k ≤ 5` the channel of the cyclic order
`2^k` is the closed form `(4^k - 1) / (3 * 4^(k-1))`, i.e. `(4/3)(1 - 4^(-k))`. -/
theorem Ipair_two_pow_closed_form {k : ℕ} (hk : 1 ≤ k) (hk5 : k ≤ 5) :
    Ipair (2 ^ k) = ((4 : ℝ) ^ k - 1) / (3 * 4 ^ (k - 1)) := by
  interval_cases k
  · norm_num [Ipair_val_2]
  · norm_num [Ipair_val_4]
  · norm_num [Ipair_val_8]
  · norm_num [Ipair_val_16]
  · norm_num [Ipair_val_32]

/-- **Geometric increments along the 2-power ladder**: the gain in channel
capacity obtained by passing from `2^k` to `2^(k+1)` is exactly `4^(-k)`. -/
theorem Ipair_two_pow_increment {k : ℕ} (hk : 1 ≤ k) (hk4 : k ≤ 4) :
    Ipair (2 ^ (k + 1)) - Ipair (2 ^ k) = (1 / 4 : ℝ) ^ k := by
  interval_cases k
  · norm_num [Ipair_val_2, Ipair_val_4]
  · norm_num [Ipair_val_4, Ipair_val_8]
  · norm_num [Ipair_val_8, Ipair_val_16]
  · norm_num [Ipair_val_16, Ipair_val_32]

/-- **Geometric increments along the 3-power ladder**: passing from `3^k` to
`3^(k+1)` gains exactly `9^(-k)` times the prime value `Ipair 3`. -/
theorem Ipair_three_pow_increment {k : ℕ} (hk : 1 ≤ k) (hk2 : k ≤ 2) :
    Ipair (3 ^ (k + 1)) - Ipair (3 ^ k) = (1 / 9 : ℝ) ^ k * Ipair 3 := by
  interval_cases k
  · rw [show (3:ℕ) ^ (1 + 1) = 9 from by norm_num, show (3:ℕ) ^ 1 = 3 from by norm_num,
      Ipair_val_9, Ipair_val_3]
    norm_num; ring
  · rw [show (3:ℕ) ^ (2 + 1) = 27 from by norm_num, show (3:ℕ) ^ 2 = 9 from by norm_num,
      Ipair_val_27, Ipair_val_9, Ipair_val_3]
    norm_num; ring

/-- **The 3-power ladder against the conjectured closed form**
`Ipair (p^k) = (1 - p^(-2k)) * p^2/(p^2-1) * Ipair p`, verified at `p = 3`,
`k ≤ 3`. -/
theorem Ipair_three_pow_closed_form {k : ℕ} (hk : 1 ≤ k) (hk3 : k ≤ 3) :
    Ipair (3 ^ k) = (1 - (9 : ℝ) ^ (-(k : ℤ))) * (9 / 8) * Ipair 3 := by
  interval_cases k
  · rw [show (3:ℕ) ^ 1 = 3 from by norm_num]
    norm_num
  · rw [show (3:ℕ) ^ 2 = 9 from by norm_num, Ipair_val_9, Ipair_val_3]
    norm_num; ring
  · rw [show (3:ℕ) ^ 3 = 27 from by norm_num, Ipair_val_27, Ipair_val_3]
    norm_num; ring

/-- The 2-power ladder stays strictly below its limit `4/3`, but every step
after the first is above the one-bit binary-fork cap. -/
theorem Ipair_thirtytwo_above_cap : 1 < Ipair 32 ∧ Ipair 32 < 4 / 3 := by
  rw [Ipair_val_32]; constructor <;> norm_num

/-- The odd prime-power orders stay below the cap: `Ipair 27 < 1`. -/
theorem Ipair_twentyseven_below_cap : Ipair 27 < 1 := by
  rw [Ipair_val_27]
  have h := lb_three_lt
  linarith

/-- The 2-power ladder is strictly increasing on the evaluated range. -/
theorem Ipair_two_pow_strictly_increasing :
    Ipair 2 < Ipair 4 ∧ Ipair 4 < Ipair 8 ∧ Ipair 8 < Ipair 16 ∧ Ipair 16 < Ipair 32 := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [Ipair_val_2, Ipair_val_4]; norm_num
  · rw [Ipair_val_4, Ipair_val_8]; norm_num
  · rw [Ipair_val_8, Ipair_val_16]; norm_num
  · rw [Ipair_val_16, Ipair_val_32]; norm_num

end CyclicTypeChannel