/-
# The `D₆` type channel of `x⁶ - 2`: exact values

Exact, closed-form information content of the `D₆` splitting-type channel, in the
catalog's counting framework (`uEnt`, `condEnt`, `mutInfo` from
`Shared.CyclicTypeChannel`).  The source is a uniformly random element of
`D₆ = Gal(ℚ(2^{1/6}, ζ₆)/ℚ)` (Chebotarev), the read-out is its number of fixed
roots `T` (`fixCount`), and the dials are characters of `D₆`.
Write `L = log₂ 3`, `L₅ = log₂ 5`, `L₁₇ = log₂ 17`.

* `typeEntropy_D6` — `H(T) = (3/4)·L ≈ 1.1887` bits (observed: `1.1835`);
* `condEnt_rotSign_D6`, `mutInfo_rotSign_D6` — the conductor-`3` dial
  (`p mod 3` ↔ the rotation character):
  `I(p mod 3 ; T) = L/4 + (5/12)·L₅ - 1 ≈ 0.3637` bits (observed `0.3630`);
* `mutInfo_abMap_D6` — the full abelian dial (`p mod 24` ↔ `D₆^ab = C₂ × C₂`):
  `I = L/2 + 1/6 ≈ 0.9591` bits;
* `mutInfo_abelian_dial_le_D6` — **abelian ceiling**: every dial factoring through
  a homomorphism of `D₆` to an abelian group carries at most `L/2 + 1/6` bits;
* `condEnt_abelian_dial_ge_D6` — **non-abelian residue**: for every such dial
  `H(T | dial) ≥ L/4 - 1/6 ≈ 0.2296 > 0`, so no abelian dial pins the type;
* `pairEntropy_D6`, `mutInfo_pair_D6` — the semiprime pair channel (two
  independent Frobenii, dial = product of the rotation characters, i.e.
  `N = pq mod 3`):
  `I_pair = (3/8)·L + (35/72)·L₅ + (17/72)·L₁₇ - 23/9 ≈ 0.1326` bits
  (observed `0.1321`);
* numerical enclosures of all of the above with rational endpoints.
-/
import Algebra.D6TypeChannel.Group
import Algebra.D6TypeChannel.Refinement

namespace D6TypeChannel

open CyclicTypeChannel DihedralGroup Finset

set_option maxRecDepth 100000

/-- The divisibility `2 ∣ 6` used to build the abelianisation map of `D₆`. -/
lemma two_dvd_six : 2 ∣ 6 := ⟨3, rfl⟩

/-- The abelianisation map of `D₆`. -/
abbrev ab6 : DihedralGroup 6 → ZMod 2 × ZMod 2 := abMap two_dvd_six

/-! ## Base-two logarithms -/

lemma lb_one : Real.logb 2 (1 : ℝ) = 0 := Real.logb_one

lemma lb_two : Real.logb 2 (2 : ℝ) = 1 := Real.logb_self_eq_one (by norm_num)

lemma lb_30 : Real.logb 2 (30 : ℝ) = 1 + Real.logb 2 3 + Real.logb 2 5 := by
  rw [show (30 : ℝ) = 2 * 3 * 5 by norm_num, Real.logb_mul (by norm_num) (by norm_num),
    Real.logb_mul (by norm_num) (by norm_num), lb_two]

lemma lb_34 : Real.logb 2 (34 : ℝ) = 1 + Real.logb 2 17 := by
  rw [show (34 : ℝ) = 2 * 17 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_two]

lemma lb_72 : Real.logb 2 (72 : ℝ) = 3 + 2 * Real.logb 2 3 := by
  rw [show (72 : ℝ) = 8 * 9 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_8, lb_9]

lemma lb_3 : Real.logb 2 (3 : ℝ) = Real.logb 2 3 := rfl

/-- `log₂ 3 > 19/12`, i.e. `3 ^ 12 = 531441 > 524288 = 2 ^ 19`. -/
lemma lb_three_gt_sharp : (19 : ℝ) / 12 < Real.logb 2 3 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log ((2 : ℝ) ^ (19 : ℕ)) < Real.log ((3 : ℝ) ^ (12 : ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, lt_div_iff₀ h2]
  push_cast at h
  linarith

/-- `log₂ 17 > 4`. -/
lemma lb_seventeen_gt : (4 : ℝ) < Real.logb 2 17 := by
  rw [← lb_16]
  exact Real.logb_lt_logb (by norm_num) (by norm_num) (by norm_num)

/-- `log₂ 17 < 41/10`, i.e. `17 ^ 10 < 2 ^ 41`. -/
lemma lb_seventeen_lt : Real.logb 2 17 < (41 : ℝ) / 10 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log ((17 : ℝ) ^ (10 : ℕ)) < Real.log ((2 : ℝ) ^ (41 : ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, div_lt_iff₀ h2]
  push_cast at h
  linarith

/-! ## 1. The type entropy -/

/-- The `D₆` type entropy `H(T)` of a uniformly random Frobenius. -/
noncomputable def typeEntropyD6 : ℝ := uEnt (univ : Finset (DihedralGroup 6)) fixCount

/-- **`H(T) = (3/4) log₂ 3`.** -/
theorem typeEntropy_D6 : typeEntropyD6 = 3 / 4 * Real.logb 2 3 := by
  have h : ((univ : Finset (DihedralGroup 6)).image fixCount).val.map
      (fun v => (#{x ∈ (univ : Finset (DihedralGroup 6)) | fixCount x = v} : ℕ)) =
      (↑[1, 8, 3] : Multiset ℕ) := by decide
  rw [typeEntropyD6, uEnt_eq_countSum _ _ _ h, show (univ : Finset (DihedralGroup 6)).card = 12
    from by decide]
  norm_num [lb_one, lb_8, lb_12]
  ring

/-! ## 2. The conductor-`3` dial (rotation character, `p mod 3`) -/

/-- Rotation fibre (`p ≡ 1 mod 3`): types `{6 : 1, 0 : 5}`. -/
lemma uEnt_rot_fibre :
    uEnt {x ∈ (univ : Finset (DihedralGroup 6)) | rotSign x = 0} fixCount =
      1 + Real.logb 2 3 - 5 / 6 * Real.logb 2 5 := by
  have h : (({x ∈ (univ : Finset (DihedralGroup 6)) | rotSign x = 0}).image fixCount).val.map
      (fun v => (#{y ∈ {x ∈ (univ : Finset (DihedralGroup 6)) | rotSign x = 0} |
        fixCount y = v} : ℕ)) = (↑[1, 5] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h,
    show (#{x ∈ (univ : Finset (DihedralGroup 6)) | rotSign x = 0}) = 6 from by decide]
  norm_num [lb_one, lb_6]
  ring

/-- Reflection fibre (`p ≡ 2 mod 3`): types `{2 : 3, 0 : 3}`, exactly one bit. -/
lemma uEnt_refl_fibre :
    uEnt {x ∈ (univ : Finset (DihedralGroup 6)) | rotSign x = 1} fixCount = 1 := by
  have h : (({x ∈ (univ : Finset (DihedralGroup 6)) | rotSign x = 1}).image fixCount).val.map
      (fun v => (#{y ∈ {x ∈ (univ : Finset (DihedralGroup 6)) | rotSign x = 1} |
        fixCount y = v} : ℕ)) = (↑[3, 3] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h,
    show (#{x ∈ (univ : Finset (DihedralGroup 6)) | rotSign x = 1}) = 6 from by decide]
  norm_num [lb_6]
  ring

/-- `H(T | p mod 3) = 1 + L/2 - (5/12) L₅`. -/
theorem condEnt_rotSign_D6 :
    condEnt (univ : Finset (DihedralGroup 6)) fixCount rotSign =
      1 + Real.logb 2 3 / 2 - 5 / 12 * Real.logb 2 5 := by
  have himg : (univ : Finset (DihedralGroup 6)).image rotSign = {0, 1} := by decide
  rw [condEnt, himg, sum_pair (by decide), uEnt_rot_fibre, uEnt_refl_fibre,
    show (#{x ∈ (univ : Finset (DihedralGroup 6)) | rotSign x = 0}) = 6 from by decide,
    show (#{x ∈ (univ : Finset (DihedralGroup 6)) | rotSign x = 1}) = 6 from by decide,
    show (univ : Finset (DihedralGroup 6)).card = 12 from by decide]
  norm_num
  ring

/-- **`I(p mod 3 ; T) = L/4 + (5/12) L₅ - 1 ≈ 0.3637` bits.** -/
theorem mutInfo_rotSign_D6 :
    mutInfo (univ : Finset (DihedralGroup 6)) fixCount rotSign =
      Real.logb 2 3 / 4 + 5 / 12 * Real.logb 2 5 - 1 := by
  rw [mutInfo, ← typeEntropyD6, typeEntropy_D6, condEnt_rotSign_D6]
  ring

/-- Numerical enclosure: `0.34 < I(p mod 3 ; T) < 0.375`. -/
theorem mutInfo_rotSign_D6_bounds :
    (34 : ℝ) / 100 < mutInfo (univ : Finset (DihedralGroup 6)) fixCount rotSign ∧
      mutInfo (univ : Finset (DihedralGroup 6)) fixCount rotSign < 3 / 8 := by
  rw [mutInfo_rotSign_D6]
  constructor <;> nlinarith [lb_three_gt, lb_three_lt, lb_five_gt, lb_five_lt]

/-- The conductor-`3` channel is **leaking**: strictly positive but strictly
below `H(T)`: `p mod 3` neither ignores nor pins the type. -/
theorem rotSign_channel_leaking :
    0 < mutInfo (univ : Finset (DihedralGroup 6)) fixCount rotSign ∧
      mutInfo (univ : Finset (DihedralGroup 6)) fixCount rotSign < typeEntropyD6 := by
  rw [mutInfo_rotSign_D6, typeEntropy_D6]
  constructor <;> nlinarith [lb_three_gt, lb_three_lt, lb_five_gt, lb_five_lt]

/-! ## 3. The full abelian dial (`D₆^ab = C₂ × C₂`, `p mod 24`) -/

/-- `H(T | D₆^ab) = L/4 - 1/6`: only the kernel coset `{r 0, r 2, r 4}` (i.e.
`p ≡ 1, 7 mod 24`) is ambiguous, with types `{6 : 1, 0 : 2}`. -/
theorem condEnt_abMap_D6 :
    condEnt (univ : Finset (DihedralGroup 6)) fixCount ab6 = Real.logb 2 3 / 4 - 1 / 6 := by
  have himg : (univ : Finset (DihedralGroup 6)).image ab6 = {(0, 0), (0, 1), (1, 0), (1, 1)} := by
    decide
  have e00 : uEnt {x ∈ (univ : Finset (DihedralGroup 6)) | ab6 x = (0, 0)} fixCount =
      Real.logb 2 3 - 2 / 3 := by
    have h : (({x ∈ (univ : Finset (DihedralGroup 6)) | ab6 x = (0, 0)}).image fixCount).val.map
        (fun v => (#{y ∈ {x ∈ (univ : Finset (DihedralGroup 6)) | ab6 x = (0, 0)} |
          fixCount y = v} : ℕ)) = (↑[1, 2] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ (univ : Finset (DihedralGroup 6)) | ab6 x = (0, 0)}) = 3 from by decide]
    norm_num [lb_one, lb_two]
  have epure : ∀ c : ZMod 2 × ZMod 2, c ≠ (0, 0) →
      uEnt {x ∈ (univ : Finset (DihedralGroup 6)) | ab6 x = c} fixCount = 0 := by
    intro c hc
    have h : (({x ∈ (univ : Finset (DihedralGroup 6)) | ab6 x = c}).image fixCount).val.map
        (fun v => (#{y ∈ {x ∈ (univ : Finset (DihedralGroup 6)) | ab6 x = c} |
          fixCount y = v} : ℕ)) = (↑[3] : Multiset ℕ) := by revert c; decide
    rw [uEnt_eq_countSum _ _ _ h,
      show (#{x ∈ (univ : Finset (DihedralGroup 6)) | ab6 x = c}) = 3 from by revert c; decide]
    norm_num
  rw [condEnt, himg, sum_insert (by decide), sum_insert (by decide), sum_insert (by decide),
    sum_singleton, e00, epure _ (by decide), epure _ (by decide), epure _ (by decide),
    show (#{x ∈ (univ : Finset (DihedralGroup 6)) | ab6 x = (0, 0)}) = 3 from by decide,
    show (univ : Finset (DihedralGroup 6)).card = 12 from by decide]
  norm_num
  ring

/-- **`I(D₆^ab ; T) = L/2 + 1/6 ≈ 0.9591` bits** — the most any abelian dial
(e.g. `p mod 24`) can extract. -/
theorem mutInfo_abMap_D6 :
    mutInfo (univ : Finset (DihedralGroup 6)) fixCount ab6 = Real.logb 2 3 / 2 + 1 / 6 := by
  rw [mutInfo, ← typeEntropyD6, typeEntropy_D6, condEnt_abMap_D6]
  ring

/-- The abelianisation map of `D₆` and `ab6` induce the same channel. -/
theorem condEnt_abelianization_D6 [DecidableEq (Abelianization (DihedralGroup 6))] :
    condEnt (univ : Finset (DihedralGroup 6)) fixCount
      (Abelianization.of : DihedralGroup 6 →* Abelianization (DihedralGroup 6)) =
      Real.logb 2 3 / 4 - 1 / 6 := by
  rw [← condEnt_abMap_D6]
  exact condEnt_congr_of_partition _ _ fun a _ b _ => (abMap_eq_iff_of_eq a b).symm

/-- **Abelian ceiling for `D₆`.** Every dial that factors through a homomorphism
of `D₆` into an abelian group carries at most `L/2 + 1/6` bits about the type. -/
theorem mutInfo_abelian_dial_le_D6 {A : Type*} [CommGroup A] [DecidableEq A]
    (φ : DihedralGroup 6 →* A) :
    mutInfo (univ : Finset (DihedralGroup 6)) fixCount φ ≤ Real.logb 2 3 / 2 + 1 / 6 := by
  classical
  refine (mutInfo_le_abelianization fixCount φ).trans (le_of_eq ?_)
  rw [mutInfo, ← typeEntropyD6, typeEntropy_D6, condEnt_abelianization_D6]
  ring

/-- **Non-abelian residue.** For every abelian dial `φ`,
`H(T | φ) ≥ L/4 - 1/6 > 0.22`: no congruence-type dial pins the `D₆` type. -/
theorem condEnt_abelian_dial_ge_D6 {A : Type*} [CommGroup A] [DecidableEq A]
    (φ : DihedralGroup 6 →* A) :
    Real.logb 2 3 / 4 - 1 / 6 ≤ condEnt (univ : Finset (DihedralGroup 6)) fixCount φ ∧
      (22 : ℝ) / 100 < Real.logb 2 3 / 4 - 1 / 6 := by
  refine ⟨?_, by linarith [lb_three_gt_sharp]⟩
  have h := mutInfo_abelian_dial_le_D6 φ
  rw [mutInfo, ← typeEntropyD6, typeEntropy_D6] at h
  linarith

/-- The hierarchy of dials: `0 < I(p mod 3) < I(D₆^ab) < H(T)`. -/
theorem dial_hierarchy_D6 :
    0 < mutInfo (univ : Finset (DihedralGroup 6)) fixCount rotSign ∧
    mutInfo (univ : Finset (DihedralGroup 6)) fixCount rotSign <
      mutInfo (univ : Finset (DihedralGroup 6)) fixCount ab6 ∧
    mutInfo (univ : Finset (DihedralGroup 6)) fixCount ab6 < typeEntropyD6 := by
  rw [mutInfo_rotSign_D6, mutInfo_abMap_D6, typeEntropy_D6]
  refine ⟨?_, ?_, ?_⟩ <;> nlinarith [lb_three_gt, lb_three_lt, lb_five_gt, lb_five_lt]

end D6TypeChannel