/-
# The cyclic cubic field of conductor 13 is fully pinned

Let `f = 13` and let `K ⊂ Q(ζ₁₃)` be the unique cubic subfield (`Gal(K/Q) ≅ C₃`,
conductor `13`).  An unramified prime `p ≠ 13` has a splitting type in `K`, namely
its residue degree, and there are **only two** possible types: `T(p) = 1` (`p`
splits completely, which happens exactly when `p` is a cubic residue mod `13`,
i.e. `p mod 13 ∈ {1,5,8,12}`) and `T(p) = 3` (`p` is inert).

This file proves, with no numerics left implicit:

* `residue_quartic_iff_cube`, `cubicResidues_13`, `card_cubicResidues_13` — the
  arithmetic grounding: `x^4 = 1` characterises the cubic residues mod `13`, they
  are `{1,5,8,12}`, and there are exactly `4` of them out of `12` units.
* `two_pow_eq_one_iff`, `cubic_splits_iff`, `cubicSplitType_eq_ordType` — the
  bridge from arithmetic to the exponent model: `2` is a generator of `(ZMod 13)ˣ`,
  `p = 2^a` splits completely in `K` iff `3 ∣ a`, and the arithmetic type agrees
  with the group-theoretic `ordType 3 a` used by the catalog channel.
* `conductor13_two_types`, `conductor13_type_counts` — exactly two types, with
  fibre sizes `4` and `8`.
* `conductor13_entropy`, `conductor13_full_pinning` — the headline:
  `H(T) = log₂ 3 - 2/3` and `I(p mod 13 ; T) = H(T)` exactly (full pinning), and
  it survives any thickening of the residue.
* `cubic_subfield_pinned_all_conductors` — full pinning of the cubic channel is
  *not* special to `13`: it holds verbatim for every prime conductor `f` with
  `3 ∣ f - 1`, always with the same entropy `log₂ 3 - 2/3`.
* `entropy_lt_reported`, `Ipair_three_gt_reported` — sharp rational bounds that
  *correct* the reported experimental constants: the true `H(T)` is
  `0.91829…< 0.9192` and the true semiprime pair channel is
  `0.47385… > 0.4702`.
* `Ipair_three_eq`, `conductor13_pairing_defect` — the semiprime channel
  `Ipair 3 = log₂ 3 - 10/9` and the exact rational pairing defect `4/9`.
-/
import Bridges.CyclicSubfieldTypeChannel

namespace CyclicCubic13

open Finset CyclicTypeChannel CyclicSubfield

/-! ## 1. Arithmetic grounding: cubic residues mod 13 -/

/-- **Cubic residues are detected by the fourth power.**  For a nonzero residue
`x` mod `13`, `x` is a cube iff `x^4 = 1`; the cubes form the index-`3` subgroup
of `(ZMod 13)ˣ` fixing the cubic subfield. -/
theorem residue_quartic_iff_cube (x : ZMod 13) (hx : x ≠ 0) :
    x ^ 4 = 1 ↔ ∃ y : ZMod 13, y ≠ 0 ∧ y ^ 3 = x := by
  revert hx
  revert x
  decide

/-- The cubic residues mod `13` are exactly `{1, 5, 8, 12}`. -/
theorem cubicResidues_13 : {x : ZMod 13 | x ≠ 0 ∧ x ^ 4 = 1} = {1, 5, 8, 12} := by
  ext x
  simp only [Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
  revert x
  decide

/-- Exactly `4` of the `12` units mod `13` are cubic residues: the splitting-type
`1` fibre has density `1/3`. -/
theorem card_cubicResidues_13 :
    #{x : ZMod 13 | x ≠ 0 ∧ x ^ 4 = 1} = 4 := by decide

/-- Every unit mod `13` becomes a cubic residue after cubing: the quotient group
`(ZMod 13)ˣ / (cubes)` is killed by `3`, so the splitting type divides `3`. -/
theorem cube_is_cubicResidue (x : ZMod 13) (hx : x ≠ 0) : (x ^ 3) ^ 4 = 1 := by
  revert hx; revert x; decide

/-! ## 2. The exponent model: `2` is a generator mod `13` -/

/-- The multiplicative order of `2` mod `13` is `12`: `2^a = 1` exactly when
`12 ∣ a`. -/
theorem two_pow_eq_one_iff (a : ℕ) : (2 : ZMod 13) ^ a = 1 ↔ 12 ∣ a := by
  have h12 : (2 : ZMod 13) ^ 12 = 1 := by decide
  constructor
  · intro h
    have hred : (2 : ZMod 13) ^ (a % 12) = 1 := by
      have hsplit : 12 * (a / 12) + a % 12 = a := Nat.div_add_mod a 12
      calc (2 : ZMod 13) ^ (a % 12)
          = (2 : ZMod 13) ^ (12 * (a / 12)) * (2 : ZMod 13) ^ (a % 12) := by
            rw [pow_mul, h12, one_pow, one_mul]
        _ = (2 : ZMod 13) ^ a := by rw [← pow_add, hsplit]
        _ = 1 := h
    have key : ∀ r ∈ Finset.range 12, (2 : ZMod 13) ^ r = 1 → r = 0 := by decide
    have := key (a % 12) (mem_range.2 (Nat.mod_lt _ (by norm_num))) hred
    omega
  · rintro ⟨k, rfl⟩
    rw [pow_mul, h12, one_pow]

/-- Every nonzero residue mod `13` is a power of `2` with exponent `< 12`: the
exponent model of the catalog channel is faithful at conductor `13`. -/
theorem exists_exponent (x : ZMod 13) (hx : x ≠ 0) :
    ∃ a ∈ Finset.range 12, (2 : ZMod 13) ^ a = x := by
  revert hx; revert x; decide

/-- **The splitting law in the cubic subfield.** The prime with Frobenius exponent
`a` splits completely in the cubic subfield of `Q(ζ₁₃)` iff `3 ∣ a`. -/
theorem cubic_splits_iff (a : ℕ) : ((2 : ZMod 13) ^ a) ^ 4 = 1 ↔ 3 ∣ a := by
  rw [← pow_mul, two_pow_eq_one_iff]
  omega

/-- The `C₃` splitting type is binary in the arithmetic sense: `1` on multiples of
`3`, `3` elsewhere. -/
theorem ordType_three (a : ℕ) : ordType 3 a = if 3 ∣ a then 1 else 3 := by
  by_cases h : 3 ∣ a
  · obtain ⟨k, rfl⟩ := h
    have hg : Nat.gcd (3 * k) 3 = 3 :=
      Nat.gcd_eq_right (⟨k, by ring⟩ : (3 : ℕ) ∣ 3 * k)
    simp [ordType, hg]
  · have hco : Nat.gcd a 3 = 1 :=
      Nat.Coprime.symm ((Nat.Prime.coprime_iff_not_dvd (by norm_num)).2 h)
    simp [ordType, hco, h]

/-- **Arithmetic = group theory at conductor 13.**  The arithmetically defined
splitting type of the prime with exponent `a` — `1` if `p` is a cubic residue mod
`13`, else `3` — is exactly the catalog's `ordType 3 a`, the order of the Frobenius
in the quotient `C₁₂ / C₄ ≅ C₃`. -/
theorem cubicSplitType_eq_ordType (a : ℕ) :
    (if ((2 : ZMod 13) ^ a) ^ 4 = 1 then 1 else 3) = ordType 3 a := by
  simp only [ordType_three, cubic_splits_iff]

/-- The same statement read off an arbitrary unramified residue class. -/
theorem cubicSplitType_of_residue (x : ZMod 13) (hx : x ≠ 0) :
    ∃ a ∈ Finset.range 12,
      (2 : ZMod 13) ^ a = x ∧ (if x ^ 4 = 1 then 1 else 3) = ordType 3 a := by
  obtain ⟨a, ha, rfl⟩ := exists_exponent x hx
  exact ⟨a, ha, rfl, cubicSplitType_eq_ordType a⟩

/-! ## 3. Only two types, with densities `1/3` and `2/3` -/

/-- **Exactly two splitting types at conductor 13.** -/
theorem conductor13_two_types : (range 12).image (ordType 3) = {1, 3} := by decide

/-- The two type fibres have sizes `4` and `8`. -/
theorem conductor13_type_counts :
    #{a ∈ range 12 | ordType 3 a = 1} = 4 ∧ #{a ∈ range 12 | ordType 3 a = 3} = 8 := by
  constructor <;> decide

/-- The type channel of the cubic subfield of `Q(ζ₁₃)` really is binary: the number
of distinct types is `2`, and this happens because the degree `3` is prime. -/
theorem conductor13_binary_channel : ((range 12).image (ordType 3)).card = 2 := by
  rw [subfield_two_types_iff_prime (m := 3) (n := 12) (by norm_num) (by norm_num) (by norm_num)]
  norm_num

/-! ## 4. The headline: exact entropy and full pinning -/

/-- **`H(T) = log₂ 3 - 2/3` at conductor 13.**  The entropy is computed over the
full set of `12` Frobenius exponents of `Q(ζ₁₃)`, yet equals the intrinsic `C₃`
value: subfield entropy does not see the conductor. -/
theorem conductor13_entropy : uEnt (range 12) (ordType 3) = Real.logb 2 3 - 2 / 3 := by
  have h : uEnt (range (3 * 4)) (ordType 3) = typeEntropy 3 :=
    subfield_typeEntropy (by norm_num) (by norm_num)
  rw [show (12 : ℕ) = 3 * 4 by norm_num, h, typeEntropy_three]

/-- **Full pinning at conductor 13.**  `I(p mod 13 ; T) = H(T)`: the residue class
of `p` determines its splitting type in the cubic field, so the channel transmits
its entire entropy — nothing is lost. -/
theorem conductor13_full_pinning :
    mutInfo (range 12) (ordType 3) id = uEnt (range 12) (ordType 3) := by
  rw [mutInfo, condEnt_eq_zero_of_injOn _ (Set.injOn_id _), sub_zero]

/-- The pinned value in closed form. -/
theorem conductor13_full_pinning_value :
    mutInfo (range 12) (ordType 3) id = Real.logb 2 3 - 2 / 3 := by
  rw [conductor13_full_pinning, conductor13_entropy]

/-- **Thickening zero at conductor 13.**  Refining `p mod 13` to any finer
invariant (`p mod 169`, `p mod 13·f'`, the Frobenius element itself, …) adds
nothing: the channel is already saturated. -/
theorem conductor13_thickening_zero {γ : Type*} [DecidableEq γ] (w : ℕ → γ)
    (hw : Set.InjOn w (range 12)) :
    mutInfo (range 12) (ordType 3) w = Real.logb 2 3 - 2 / 3 := by
  rw [mutInfo, condEnt_eq_zero_of_injOn _ hw, sub_zero, conductor13_entropy]

/-- **Pinning is a positive amount of information**, not a vacuous identity: the
pinned entropy is strictly between `0` and `1` bit. -/
theorem conductor13_entropy_pos_lt_one :
    0 < uEnt (range 12) (ordType 3) ∧ uEnt (range 12) (ordType 3) < 1 := by
  rw [conductor13_entropy]
  constructor
  · have := lb_three_gt
    linarith
  · have := lb_three_lt
    linarith

/-! ## 5. Full pinning extends across conductors -/

/-- **The cubic channel is fully pinned at every conductor.**  For any prime
conductor `f` with `3 ∣ f - 1`, the cyclic cubic subfield of `Q(ζ_f)` has the same
two splitting types, the same entropy `log₂ 3 - 2/3`, and the same exact pinning
`I(p mod f ; T) = H(T)`.  Conductor `13` is the second instance (`f = 7` is the
first); nothing about it is special. -/
theorem cubic_subfield_pinned_all_conductors {f : ℕ} (hf : f.Prime) (h3 : 3 ∣ f - 1) :
    mutInfo (range (f - 1)) (ordType 3) id = Real.logb 2 3 - 2 / 3 := by
  have hpos : 0 < f - 1 := by
    have := hf.two_le
    rcases Nat.eq_zero_or_pos (f - 1) with h | h
    · omega
    · exact h
  rw [subfield_full_pinning (m := 3) (n := f - 1) (by norm_num) hpos h3, typeEntropy_three]

/-- Conductor `13` is an instance of the general law. -/
theorem conductor13_is_an_instance :
    mutInfo (range (13 - 1)) (ordType 3) id = Real.logb 2 3 - 2 / 3 :=
  cubic_subfield_pinned_all_conductors (by norm_num) (by norm_num)

/-- Conductor `7`, `19`, `31`: the same pinned value, showing conductor
independence concretely. -/
theorem cubic_pinning_seven_nineteen_thirtyone :
    mutInfo (range 6) (ordType 3) id = Real.logb 2 3 - 2 / 3 ∧
    mutInfo (range 18) (ordType 3) id = Real.logb 2 3 - 2 / 3 ∧
    mutInfo (range 30) (ordType 3) id = Real.logb 2 3 - 2 / 3 := by
  refine ⟨?_, ?_, ?_⟩
  · simpa using cubic_subfield_pinned_all_conductors (f := 7) (by norm_num) (by norm_num)
  · simpa using cubic_subfield_pinned_all_conductors (f := 19) (by norm_num) (by norm_num)
  · simpa using cubic_subfield_pinned_all_conductors (f := 31) (by norm_num) (by norm_num)

/-! ## 6. Sharp numerics: correcting the reported constants -/

/-- `log₂ 3 > 84/53`, from `3^53 > 2^84`. -/
theorem logb_three_gt_84_53 : (84 : ℝ) / 53 < Real.logb 2 3 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log ((2 : ℝ) ^ (84 : ℕ)) < Real.log ((3 : ℝ) ^ (53 : ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, lt_div_iff₀ h2]
  push_cast at h
  linarith

/-- `log₂ 3 < 65/41`, from `3^41 < 2^65`. -/
theorem logb_three_lt_65_41 : Real.logb 2 3 < (65 : ℝ) / 41 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log ((3 : ℝ) ^ (41 : ℕ)) < Real.log ((2 : ℝ) ^ (65 : ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, div_lt_iff₀ h2]
  push_cast at h
  linarith

/-- Sharp two-sided bounds for the conductor-13 type entropy:
`0.9182 < H(T) < 0.9187`. -/
theorem conductor13_entropy_bounds :
    (0.9182 : ℝ) < uEnt (range 12) (ordType 3) ∧
      uEnt (range 12) (ordType 3) < 0.9187 := by
  rw [conductor13_entropy]
  constructor
  · have := logb_three_gt_84_53
    linarith
  · have := logb_three_lt_65_41
    linarith

/-- **Correction of the reported value.**  The experimentally reported
`H(T) = 0.9192` bits is too large: the exact value `log₂ 3 - 2/3 = 0.918295…`
is strictly below it. -/
theorem entropy_lt_reported : uEnt (range 12) (ordType 3) < 0.9192 := by
  have := (conductor13_entropy_bounds).2
  linarith

/-! ## 7. The semiprime pair channel and the exact `4/9` defect -/

/-- The semiprime type-pair channel of the cubic degree: `Ipair 3 = log₂ 3 - 10/9`. -/
theorem Ipair_three_eq : Ipair 3 = Real.logb 2 3 - 10 / 9 := by
  rw [Ipair_prime_three]; ring

/-- **The pairing defect at conductor 13 is exactly `4/9` bits.**  Knowing only the
semiprime `N = p q` mod `13` (rather than `p` itself) costs the channel the
rational amount `4/9`, even though both quantities separately involve `log₂ 3`. -/
theorem conductor13_pairing_defect : uEnt (range 12) (ordType 3) - Ipair 3 = 4 / 9 := by
  rw [conductor13_entropy, Ipair_three_eq]
  ring

/-- Sharp bounds for the semiprime pair channel: `0.4737 < Ipair 3 < 0.4743`. -/
theorem Ipair_three_bounds : (0.4737 : ℝ) < Ipair 3 ∧ Ipair 3 < 0.4743 := by
  rw [Ipair_three_eq]
  constructor
  · have := logb_three_gt_84_53
    linarith
  · have := logb_three_lt_65_41
    linarith

/-- **Correction of the reported pair value.**  The reported `0.4702` for the
semiprime pair channel is too small: the exact value is `log₂ 3 - 10/9 = 0.473851…`. -/
theorem Ipair_three_gt_reported : (0.4702 : ℝ) < Ipair 3 := by
  have := Ipair_three_bounds.1
  linarith

/-- **Halving law.** The semiprime pair channel of the cubic degree carries more
than half, but less than two thirds, of the fully pinned single-prime entropy. -/
theorem Ipair_three_fraction :
    uEnt (range 12) (ordType 3) / 2 < Ipair 3 ∧
      Ipair 3 < 2 / 3 * uEnt (range 12) (ordType 3) := by
  have hb := conductor13_entropy_bounds
  have hp := Ipair_three_bounds
  constructor
  · linarith [hb.2, hp.1]
  · linarith [hb.1, hp.2]

end CyclicCubic13