/-
# The affine Frobenius ladder: `AGL(1,7)` at degree seven

`Bridges.QuinticTypeChannelF20` evaluated the splitting-type channel of the first
non-abelian object with a `C₄` abelianization, the Frobenius group
`F₂₀ = AGL(1,5) = Gal(x⁵ - 2)`.  This file takes the next rung of the affine ladder
predicted there: the group

  `AGL(1,7) = {x ↦ a x + b : a ∈ 𝔽₇ˣ, b ∈ 𝔽₇}`

of order `42`, the Galois group of a generic radical septic `x⁷ - a`, whose abelianization
is `C₆ = Gal(ℚ(ζ₇)/ℚ)` read off by `p mod 7`.

## The model

As at degree five, Chebotarev is modelled by the uniform measure on the group, and the
element `x ↦ a x + b` with `a = 3^e` (3 generates `𝔽₇ˣ`) is encoded as `7 * e + b`.  The
cycle type of `x ↦ a x + b` on the seven roots depends only on the order `d` of `a`:

* `a = 1, b = 0`   → `[1,1,1,1,1,1,1]` (code `1`), one element;
* `a = 1, b ≠ 0`   → `[7]` (code `7`), six elements;
* `d = 2` (`e = 3`) → `[1,2,2,2]` (code `1222`), seven elements;
* `d = 3` (`e ∈ {2,4}`) → `[1,3,3]` (code `133`), fourteen elements;
* `d = 6` (`e ∈ {1,5}`) → `[1,6]` (code `16`), fourteen elements.

So **two** type values merge cosets here (each merging two of them), against exactly one at
degree five — the divisor lattice of `q - 1` is what governs the merging.

## What is proved

* `septicDialEntropy_val` — the sextic dial carries `log₂ 6 = 1 + log₂ 3` bits.
* `septicTypeEntropy_val` — `H(T) = 4/21 + (6/7) log₂ 3 + (1/6) log₂ 7 = 2.0169…`.
* `septic_merge_gap` — the merged-coset sum is exactly `2/3`.
* `abelianization_law_degree_seven` — `I(p mod 7 ; T) = 1/3 + log₂ 3 = 1.9183…`,
  again `H(dial)` minus the entropy of the merged cosets, with `log₂ 7` cancelling.
* `aglLoss` and `agl_ladder_five_seven` — the loss of `AGL(1,q)` written as the totient
  sum `∑_{d ∣ q-1, d > 1} (φ(d)/(q-1)) log₂ φ(d)`, verified to reproduce both the degree-5
  value `1/2` and the degree-7 value `2/3`, plus the degree-11 prediction `8/5`.
* `septic_beats_quintic` and `septic_loses_larger_dial_fraction` — the septic channel
  transmits strictly more information than the quintic one, yet wastes a strictly larger
  *fraction* of its dial.
-/
import Bridges.QuinticTypeChannelF20

namespace SepticAGL7

open Finset CyclicTypeChannel QuinticF20

set_option maxRecDepth 100000
set_option exponentiation.threshold 4000

/-! ## 0. Logarithm bookkeeping -/

lemma lbs_14 : Real.logb 2 (14 : ℝ) = 1 + Real.logb 2 7 := by
  rw [show (14 : ℝ) = 2 * 7 by norm_num, Real.logb_mul (by norm_num) (by norm_num),
    Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)]

lemma lbs_42 : Real.logb 2 (42 : ℝ) = 1 + Real.logb 2 3 + Real.logb 2 7 := by
  rw [show (42 : ℝ) = 2 * (3 * 7) by norm_num,
    Real.logb_mul (by norm_num) (by norm_num), Real.logb_mul (by norm_num) (by norm_num),
    Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2), add_assoc]

/-- `log₂ 7 > 14/5`, i.e. `7 ^ 5 = 16807 > 16384 = 2 ^ 14`. -/
lemma lbs_seven_gt : (14 : ℝ) / 5 < Real.logb 2 7 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log ((2 : ℝ) ^ (14 : ℕ)) < Real.log ((7 : ℝ) ^ (5 : ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, lt_div_iff₀ h2]
  push_cast at h
  linarith

/-- `log₂ 7 < 281/100`, i.e. `7 ^ 100 < 2 ^ 281`. -/
lemma lbs_seven_lt : Real.logb 2 7 < (281 : ℝ) / 100 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hnat : (7 : ℕ) ^ (100 : ℕ) < (2 : ℕ) ^ (281 : ℕ) := by decide
  have hlt : ((7 : ℝ)) ^ (100 : ℕ) < ((2 : ℝ)) ^ (281 : ℕ) := by exact_mod_cast hnat
  have h : Real.log ((7 : ℝ) ^ (100 : ℕ)) < Real.log ((2 : ℝ) ^ (281 : ℕ)) :=
    Real.log_lt_log (by positivity) hlt
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, div_lt_iff₀ h2]
  push_cast at h
  linarith

/-- `log₂ 3 > 198/125`, i.e. `3 ^ 125 > 2 ^ 198`. -/
lemma lbs_three_gt : (198 : ℝ) / 125 < Real.logb 2 3 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hnat : (2 : ℕ) ^ (198 : ℕ) < (3 : ℕ) ^ (125 : ℕ) := by decide
  have hlt : ((2 : ℝ)) ^ (198 : ℕ) < ((3 : ℝ)) ^ (125 : ℕ) := by exact_mod_cast hnat
  have h : Real.log ((2 : ℝ) ^ (198 : ℕ)) < Real.log ((3 : ℝ) ^ (125 : ℕ)) :=
    Real.log_lt_log (by positivity) hlt
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, lt_div_iff₀ h2]
  push_cast at h
  linarith

/-- `log₂ 3 < 317/200`, i.e. `3 ^ 200 < 2 ^ 317`. -/
lemma lbs_three_lt : Real.logb 2 3 < (317 : ℝ) / 200 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hnat : (3 : ℕ) ^ (200 : ℕ) < (2 : ℕ) ^ (317 : ℕ) := by decide
  have hlt : ((3 : ℝ)) ^ (200 : ℕ) < ((2 : ℝ)) ^ (317 : ℕ) := by exact_mod_cast hnat
  have h : Real.log ((3 : ℝ) ^ (200 : ℕ)) < Real.log ((2 : ℝ) ^ (317 : ℕ)) :=
    Real.log_lt_log (by positivity) hlt
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, div_lt_iff₀ h2]
  push_cast at h
  linarith

/-! ## 1. The `AGL(1,7)` Frobenius box -/

/-- The 42 Frobenius classes of a generic septic radical field, encoded as `7 * e + b`. -/
def sFrob : Finset ℕ := range 42

/-- The abelianization read-out: the `C₆` valuation `e` of the multiplier `a = 3^e`,
i.e. the residue `p mod 7` transported to `ℤ/6` by the discrete logarithm. -/
def sDial (x : ℕ) : ℕ := x / 7

/-- The septic splitting type at the Frobenius class `x`, coded by
`1 = [1,…,1]`, `7 = [7]`, `1222 = [1,2,2,2]`, `133 = [1,3,3]`, `16 = [1,6]`. -/
def sType (x : ℕ) : ℕ :=
  if x / 7 = 0 then (if x % 7 = 0 then 1 else 7)
  else if x / 7 = 3 then 1222
  else if x / 7 = 2 then 133 else if x / 7 = 4 then 133 else 16

/-- The size of the dial classes inside each type fibre.  Only `[1,3,3]` and `[1,6]` have
fibres bigger than the class size `7`: they are the two merging types. -/
def sMergeSize (t : ℕ) : ℕ := if t = 1 then 1 else if t = 7 then 6 else 7

lemma sFrob_nonempty : sFrob.Nonempty := ⟨0, by decide⟩

lemma sFrob_card : sFrob.card = 42 := by decide

/-- The five septic splitting types actually occurring. -/
lemma sType_image : sFrob.image sType = ({1, 7, 1222, 133, 16} : Finset ℕ) := by decide

/-- The Chebotarev densities `1 : 6 : 7 : 14 : 14`. -/
lemma sType_fiber_1 : #{x ∈ sFrob | sType x = 1} = 1 := by decide
lemma sType_fiber_7 : #{x ∈ sFrob | sType x = 7} = 6 := by decide
lemma sType_fiber_1222 : #{x ∈ sFrob | sType x = 1222} = 7 := by decide
lemma sType_fiber_133 : #{x ∈ sFrob | sType x = 133} = 14 := by decide
lemma sType_fiber_16 : #{x ∈ sFrob | sType x = 16} = 14 := by decide

/-- The sextic dial is equidistributed: each of the six cosets carries seven classes. -/
lemma sDial_uniform : ∀ a ∈ sFrob, #{x ∈ sFrob | sDial x = sDial a} = 7 := by decide

/-- **The merging pattern at degree seven.**  Inside every type fibre all occurring dial
classes have the same size `sMergeSize t`. -/
lemma sDial_uniform_in_type_fibers :
    ∀ t ∈ sFrob.image sType, ∀ a ∈ ({x ∈ sFrob | sType x = t} : Finset ℕ),
      #{x ∈ ({y ∈ sFrob | sType y = t} : Finset ℕ) | sDial x = sDial a} = sMergeSize t := by
  decide

/-! ## 2. The prime-level channel -/

/-- **The septic splitting entropy.**  `H(T) = 4/21 + (6/7) log₂ 3 + (1/6) log₂ 7`,
the entropy of the Chebotarev distribution `(1, 6, 7, 14, 14)/42`. -/
theorem septicTypeEntropy_val :
    uEnt sFrob sType = 4 / 21 + (6 / 7) * Real.logb 2 3 + (1 / 6) * Real.logb 2 7 := by
  have h : (sFrob.image sType).val.map (fun v => (#{x ∈ sFrob | sType x = v} : ℕ))
      = (↑[1, 6, 7, 14, 14] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h, sFrob_card]
  norm_num [lbs_42, lbs_14, lb_6]
  ring

/-- **The sextic dial carries `log₂ 6 = 1 + log₂ 3` bits.** -/
theorem septicDialEntropy_val : uEnt sFrob sDial = 1 + Real.logb 2 3 := by
  rw [uEnt_eq_logb_of_uniform_fibers sFrob_nonempty sDial_uniform, sFrob_card]
  rw [show ((42 : ℕ) : ℝ) = 42 from by norm_num, show ((7 : ℕ) : ℝ) = 7 from by norm_num,
    lbs_42]
  ring

/-- **The merged-coset sum of `AGL(1,7)` is exactly two thirds.**  Two types merge cosets:
`[1,3,3]` fuses the two order-3 cosets and `[1,6]` fuses the two order-6 cosets, each with
probability `1/3`. -/
theorem septic_merge_gap :
    ∑ t ∈ sFrob.image sType,
      ((#{x ∈ sFrob | sType x = t} : ℝ) / sFrob.card) *
        (Real.logb 2 (#{x ∈ sFrob | sType x = t} : ℝ) - Real.logb 2 (sMergeSize t : ℝ))
      = 2 / 3 := by
  rw [sType_image]
  rw [show ({1, 7, 1222, 133, 16} : Finset ℕ)
      = insert 1 (insert 7 (insert 1222 (insert 133 {16}))) from rfl]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide),
    Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_singleton]
  rw [sType_fiber_1, sType_fiber_7, sType_fiber_1222, sType_fiber_133, sType_fiber_16,
    sFrob_card]
  norm_num [sMergeSize, lbs_14]

/-- **THE ABELIANIZATION LAW AT DEGREE SEVEN.**

For the affine Frobenius group `AGL(1,7)` the septic splitting type transmits exactly

  `I(p mod 7 ; T) = log₂ 6 - 2/3 = 1/3 + log₂ 3 = 1.9183…`

bits about the abelianization class: the whole sextic dial minus the two thirds of a bit
lost to the two merging types `[1,3,3]` and `[1,6]`.  The `log₂ 7` present in `H(T)` and in
`H(T | p mod 7)` cancels exactly, as `log₂ 5` did at degree five. -/
theorem abelianization_law_degree_seven :
    mutInfo sFrob sType sDial = 1 / 3 + Real.logb 2 3 := by
  have h := dial_gap_eq_merge_entropy sFrob_nonempty sType sDial sMergeSize
    sDial_uniform_in_type_fibers
  rw [septicDialEntropy_val, septic_merge_gap] at h
  linarith

/-- The residual `H(T | p mod 7) = (1/6) log₂ 7 - 1/7 - (1/7) log₂ 3`: only the
`[1^7] / [7]` ambiguity inside the principal coset survives, weighted by `1/6`. -/
theorem septic_condEnt_type_dial :
    condEnt sFrob sType sDial
      = (1 / 6) * Real.logb 2 7 - 1 / 7 - (1 / 7) * Real.logb 2 3 := by
  have h : mutInfo sFrob sType sDial = uEnt sFrob sType - condEnt sFrob sType sDial := rfl
  rw [abelianization_law_degree_seven, septicTypeEntropy_val] at h
  linarith

/-- The two thirds of a bit the septic type cannot see: `H(p mod 7 | T) = 2/3`. -/
theorem septic_condEnt_dial_type : condEnt sFrob sDial sType = 2 / 3 := by
  have h : mutInfo sFrob sDial sType = uEnt sFrob sDial - condEnt sFrob sDial sType := rfl
  rw [← mutInfo_comm sFrob_nonempty, abelianization_law_degree_seven,
    septicDialEntropy_val] at h
  linarith

/-- The channel is not pinned: the residue leaves a strictly positive residual, because
`log₂ 7 > 14/5 > 6/7 + (6/7) log₂ 3`. -/
theorem septic_type_not_pinned : mutInfo sFrob sType sDial < uEnt sFrob sType := by
  rw [abelianization_law_degree_seven, septicTypeEntropy_val]
  have h3 := lbs_three_lt
  have h7 := lbs_seven_gt
  linarith

/-- The septic type does not determine the coset either: two types merge cosets. -/
theorem septic_dial_not_refined_by_type : mutInfo sFrob sType sDial < uEnt sFrob sDial := by
  rw [abelianization_law_degree_seven, septicDialEntropy_val]
  norm_num

/-- The `AGL(1,7)` row of the law table: splitting entropy, dial, transmitted information
and loss. -/
theorem septic_law_table :
    uEnt sFrob sType = 4 / 21 + (6 / 7) * Real.logb 2 3 + (1 / 6) * Real.logb 2 7 ∧
    uEnt sFrob sDial = 1 + Real.logb 2 3 ∧
    mutInfo sFrob sType sDial = 1 / 3 + Real.logb 2 3 ∧
    uEnt sFrob sDial - mutInfo sFrob sType sDial = 2 / 3 :=
  ⟨septicTypeEntropy_val, septicDialEntropy_val, abelianization_law_degree_seven, by
    rw [septicDialEntropy_val, abelianization_law_degree_seven]; ring⟩

/-- Numerical bracket for the septic splitting entropy: `2.0148 < H(T) < 2.0174`. -/
theorem septicTypeEntropy_bracket :
    (2.0148 : ℝ) < uEnt sFrob sType ∧ uEnt sFrob sType < 2.0174 := by
  rw [septicTypeEntropy_val]
  refine ⟨?_, ?_⟩
  · have h3 := lbs_three_gt
    have h7 := lbs_seven_gt
    linarith
  · have h3 := lbs_three_lt
    have h7 := lbs_seven_lt
    linarith

/-- Numerical bracket for the transmitted information: `1.917 < I < 1.919`. -/
theorem septic_information_bracket :
    (1.917 : ℝ) < mutInfo sFrob sType sDial ∧ mutInfo sFrob sType sDial < 1.919 := by
  rw [abelianization_law_degree_seven]
  exact ⟨by have := lbs_three_gt; linarith, by have := lbs_three_lt; linarith⟩

/-! ## 3. The affine ladder: the loss as a totient sum -/

/-- The conjectured closed form for the dial loss of the affine Frobenius group `AGL(1,q)`:
each divisor `d > 1` of `q - 1` contributes the `φ(d)` cosets whose multipliers have order
`d`, all carrying the same cycle type, with weight `φ(d)/(q-1)`. -/
noncomputable def aglLoss (q : ℕ) : ℝ :=
  ∑ d ∈ (Nat.divisors (q - 1)).erase 1,
    ((Nat.totient d : ℝ) / ((q : ℝ) - 1)) * Real.logb 2 (Nat.totient d : ℝ)

/-- The totient sum reproduces the degree-five loss `1/2` proved in
`QuinticTypeChannelF20`. -/
theorem aglLoss_five : aglLoss 5 = 1 / 2 := by
  have hd : (Nat.divisors (5 - 1)).erase 1 = ({2, 4} : Finset ℕ) := by decide
  rw [aglLoss, hd, show ({2, 4} : Finset ℕ) = insert 2 {4} from rfl,
    Finset.sum_insert (by decide), Finset.sum_singleton]
  rw [show Nat.totient 2 = 1 from rfl, show Nat.totient 4 = 2 from rfl]
  rw [show ((1 : ℕ) : ℝ) = 1 from by norm_num, show ((2 : ℕ) : ℝ) = 2 from by norm_num,
    Real.logb_one, Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)]
  norm_num

/-- The totient sum reproduces the degree-seven loss `2/3` proved above. -/
theorem aglLoss_seven : aglLoss 7 = 2 / 3 := by
  have hd : (Nat.divisors (7 - 1)).erase 1 = ({2, 3, 6} : Finset ℕ) := by decide
  rw [aglLoss, hd, show ({2, 3, 6} : Finset ℕ) = insert 2 (insert 3 {6}) from rfl,
    Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_singleton]
  rw [show Nat.totient 2 = 1 from rfl, show Nat.totient 3 = 2 from rfl,
    show Nat.totient 6 = 2 from rfl]
  rw [show ((1 : ℕ) : ℝ) = 1 from by norm_num, show ((2 : ℕ) : ℝ) = 2 from by norm_num,
    Real.logb_one, Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)]
  norm_num

/-- The next rung, as a falsifiable prediction: `AGL(1,11)` should lose `8/5` of its
`log₂ 10` dial, leaving `I(p mod 11 ; T) = log₂ 10 - 8/5 = log₂ 5 - 3/5`. -/
theorem aglLoss_eleven : aglLoss 11 = 8 / 5 := by
  have hd : (Nat.divisors (11 - 1)).erase 1 = ({2, 5, 10} : Finset ℕ) := by decide
  rw [aglLoss, hd, show ({2, 5, 10} : Finset ℕ) = insert 2 (insert 5 {10}) from rfl,
    Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_singleton]
  rw [show Nat.totient 2 = 1 from rfl, show Nat.totient 5 = 4 from rfl,
    show Nat.totient 10 = 4 from rfl]
  rw [show ((1 : ℕ) : ℝ) = 1 from by norm_num, show ((4 : ℕ) : ℝ) = 4 from by norm_num,
    Real.logb_one, lb_4]
  norm_num

/-- **The affine ladder, degrees five and seven.**  The measured loss of each channel is
the totient sum `aglLoss q`, and the transmitted information is `log₂(q-1) - aglLoss q`. -/
theorem agl_ladder_five_seven :
    uEnt qFrob qDial - mutInfo qFrob qType qDial = aglLoss 5 ∧
    uEnt sFrob sDial - mutInfo sFrob sType sDial = aglLoss 7 ∧
    mutInfo qFrob qType qDial = uEnt qFrob qDial - aglLoss 5 ∧
    mutInfo sFrob sType sDial = uEnt sFrob sDial - aglLoss 7 := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [quinticDialEntropy_val, abelianization_law_degree_five, aglLoss_five]; norm_num
  · rw [septicDialEntropy_val, abelianization_law_degree_seven, aglLoss_seven]; ring
  · rw [quinticDialEntropy_val, abelianization_law_degree_five, aglLoss_five]; norm_num
  · rw [septicDialEntropy_val, abelianization_law_degree_seven, aglLoss_seven]; ring

/-! ## 4. Comparing the two rungs -/

/-- **The septic channel transmits strictly more than the quintic one**: `1.918… > 1.5`,
because `log₂ 3 > 3/2 > 7/6`. -/
theorem septic_beats_quintic :
    mutInfo qFrob qType qDial < mutInfo sFrob sType sDial := by
  rw [abelianization_law_degree_five, abelianization_law_degree_seven]
  have := lb_three_gt
  linarith

/-- **…yet it wastes a strictly larger fraction of its dial.**  Degree five loses `1/2`
of a `2`-bit dial (a quarter); degree seven loses `2/3` of a `log₂ 6 < 8/3`-bit dial, i.e.
strictly more than a quarter.  The merging grows faster than the dial along the ladder. -/
theorem septic_loses_larger_dial_fraction :
    (uEnt qFrob qDial - mutInfo qFrob qType qDial) / uEnt qFrob qDial
      < (uEnt sFrob sDial - mutInfo sFrob sType sDial) / uEnt sFrob sDial := by
  have hq : (uEnt qFrob qDial - mutInfo qFrob qType qDial) / uEnt qFrob qDial = 1 / 4 := by
    rw [quinticDialEntropy_val, abelianization_law_degree_five]; norm_num
  have h3lt := lbs_three_lt
  have h3gt := lb_three_gt
  have hpos : (0 : ℝ) < 1 + Real.logb 2 3 := by linarith
  have hs : (uEnt sFrob sDial - mutInfo sFrob sType sDial) / uEnt sFrob sDial
      = (2 / 3) / (1 + Real.logb 2 3) := by
    rw [septicDialEntropy_val, abelianization_law_degree_seven]; ring_nf
  rw [hq, hs, lt_div_iff₀ hpos]
  linarith

end SepticAGL7