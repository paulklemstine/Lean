/-
# The semiprime pair channel of `x⁶ - 2`

For a semiprime `N = pq` the experiment records the *type pair*
`(T(p), T(q))` and the dial `N mod 3`.  Under Chebotarev the two Frobenii are
independent uniform elements of `D₆`, the type pair is
`(fixCount g₁, fixCount g₂)` and the dial `N mod 3` is the product of the two
rotation characters, i.e. `rotSign g₁ + rotSign g₂ ∈ ZMod 2`.

* `pairEntropy_D6` — `H(T₁, T₂) = (3/2)·log₂ 3 = 2·H(T)` (independence);
* `condEnt_pair_D6` — the exact conditional entropy given `N mod 3`;
* `mutInfo_pair_D6` — **`I_pair = (3/8)·L + (35/72)·L₅ + (17/72)·L₁₇ - 23/9`**
  `≈ 0.1326` bits (observed: `0.1321`), where `L = log₂ 3`, `L₅ = log₂ 5`,
  `L₁₇ = log₂ 17`;
* `mutInfo_pair_D6_bounds` — `0.07 < I_pair < 0.15`: genuine but sub-linear
  structure: the semiprime channel is strictly weaker than the prime channel.
-/
import Algebra.D6TypeChannel.Channel

namespace D6TypeChannel

open CyclicTypeChannel DihedralGroup Finset

set_option maxRecDepth 100000

/-- The type pair of two Frobenii. -/
def pairType (q : DihedralGroup 6 × DihedralGroup 6) : ℕ × ℕ := (fixCount q.1, fixCount q.2)

/-- The semiprime dial `N mod 3 = (p mod 3)(q mod 3)`, written additively. -/
def pairDial (q : DihedralGroup 6 × DihedralGroup 6) : ZMod 2 := rotSign q.1 + rotSign q.2

/-- The type-pair entropy. -/
noncomputable def pairEntropyD6 : ℝ :=
  uEnt (univ : Finset (DihedralGroup 6 × DihedralGroup 6)) pairType

/-- The semiprime pair channel `I(N mod 3 ; (T₁, T₂))`. -/
noncomputable def IpairD6 : ℝ :=
  mutInfo (univ : Finset (DihedralGroup 6 × DihedralGroup 6)) pairType pairDial

theorem pairEntropy_D6 : pairEntropyD6 = 3 / 2 * Real.logb 2 3 := by
  have h : ((univ : Finset (DihedralGroup 6 × DihedralGroup 6)).image pairType).val.map
      (fun v => (#{x ∈ (univ : Finset (DihedralGroup 6 × DihedralGroup 6)) | pairType x = v} : ℕ)) =
      (↑[1, 8, 3, 8, 64, 24, 3, 24, 9] : Multiset ℕ) := by decide
  rw [pairEntropyD6, uEnt_eq_countSum _ _ _ h,
    show (univ : Finset (DihedralGroup 6 × DihedralGroup 6)).card = 144 from by decide]
  norm_num [lb_one, lb_8, lb_64, lb_24, lb_9, lb_144]
  ring

/-- Conditional entropy of the type pair on the fibre `N ≡ 1 (mod 3)`:
counts `{1, 5, 5, 34, 9, 9, 9}` out of `72`. -/
lemma uEnt_pair_fibre0 :
    uEnt {x ∈ (univ : Finset (DihedralGroup 6 × DihedralGroup 6)) | pairDial x = 0} pairType =
      91 / 36 + 5 / 4 * Real.logb 2 3 - 5 / 36 * Real.logb 2 5 - 17 / 36 * Real.logb 2 17 := by
  have h : (({x ∈ (univ : Finset (DihedralGroup 6 × DihedralGroup 6)) | pairDial x = 0}).image
      pairType).val.map
      (fun v => (#{y ∈ {x ∈ (univ : Finset (DihedralGroup 6 × DihedralGroup 6)) | pairDial x = 0} |
        pairType y = v} : ℕ)) = (↑[1, 5, 5, 34, 9, 9, 9] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h,
    show (#{x ∈ (univ : Finset (DihedralGroup 6 × DihedralGroup 6)) | pairDial x = 0}) = 72
      from by decide]
  norm_num [lb_one, lb_34, lb_9, lb_72]
  ring

/-- Conditional entropy of the type pair on the fibre `N ≡ 2 (mod 3)`:
counts `{3, 3, 3, 3, 15, 15, 30}` out of `72`. -/
lemma uEnt_pair_fibre1 :
    uEnt {x ∈ (univ : Finset (DihedralGroup 6 × DihedralGroup 6)) | pairDial x = 1} pairType =
      31 / 12 + Real.logb 2 3 - 5 / 6 * Real.logb 2 5 := by
  have h : (({x ∈ (univ : Finset (DihedralGroup 6 × DihedralGroup 6)) | pairDial x = 1}).image
      pairType).val.map
      (fun v => (#{y ∈ {x ∈ (univ : Finset (DihedralGroup 6 × DihedralGroup 6)) | pairDial x = 1} |
        pairType y = v} : ℕ)) = (↑[3, 3, 3, 3, 15, 15, 30] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h,
    show (#{x ∈ (univ : Finset (DihedralGroup 6 × DihedralGroup 6)) | pairDial x = 1}) = 72
      from by decide]
  norm_num [lb_15, lb_30, lb_72]
  ring

/-- `H(T₁, T₂ | N mod 3) = 23/9 + (9/8) L - (35/72) L₅ - (17/72) L₁₇`. -/
theorem condEnt_pair_D6 :
    condEnt (univ : Finset (DihedralGroup 6 × DihedralGroup 6)) pairType pairDial =
      23 / 9 + 9 / 8 * Real.logb 2 3 - 35 / 72 * Real.logb 2 5 - 17 / 72 * Real.logb 2 17 := by
  have himg : (univ : Finset (DihedralGroup 6 × DihedralGroup 6)).image pairDial = {0, 1} := by
    decide
  rw [condEnt, himg, sum_pair (by decide), uEnt_pair_fibre0, uEnt_pair_fibre1,
    show (#{x ∈ (univ : Finset (DihedralGroup 6 × DihedralGroup 6)) | pairDial x = 0}) = 72
      from by decide,
    show (#{x ∈ (univ : Finset (DihedralGroup 6 × DihedralGroup 6)) | pairDial x = 1}) = 72
      from by decide,
    show (univ : Finset (DihedralGroup 6 × DihedralGroup 6)).card = 144 from by decide]
  norm_num
  ring

/-- **The semiprime pair channel of `x⁶ - 2`:**
`I_pair = (3/8) L + (35/72) L₅ + (17/72) L₁₇ - 23/9 ≈ 0.1326` bits. -/
theorem mutInfo_pair_D6 :
    IpairD6 = 3 / 8 * Real.logb 2 3 + 35 / 72 * Real.logb 2 5 + 17 / 72 * Real.logb 2 17
      - 23 / 9 := by
  rw [IpairD6, mutInfo, ← pairEntropyD6, pairEntropy_D6, condEnt_pair_D6]
  ring

/-- Numerical enclosure `0.07 < I_pair < 0.15`. -/
theorem mutInfo_pair_D6_bounds : (7 : ℝ) / 100 < IpairD6 ∧ IpairD6 < 15 / 100 := by
  rw [mutInfo_pair_D6]
  constructor <;>
    linarith [lb_three_gt, lb_three_lt, lb_five_gt, lb_five_lt, lb_seventeen_gt, lb_seventeen_lt]

/-- The semiprime channel is genuine (`> 0`) but strictly weaker than the prime
channel `I(p mod 3 ; T)`: pairing dilutes the conductor signal. -/
theorem pair_channel_diluted :
    0 < IpairD6 ∧ IpairD6 < mutInfo (univ : Finset (DihedralGroup 6)) fixCount rotSign := by
  have h1 := mutInfo_pair_D6_bounds
  have h2 := mutInfo_rotSign_D6_bounds
  constructor <;> linarith [h1.1, h1.2, h2.1]

end D6TypeChannel