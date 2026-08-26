import Novelty.ECAFixedVarietyPeriodThree
import Novelty.ECAFixedVarietyRule110

/-!
# When the fixed-point "variety" has no dimension at all

The conjecture under test presupposes that `V(f) = {s : f(s) = s}` is a linear
(or at least affine) subvariety of `𝔸ⁿ_{𝔽₂}`, so that `dim V(f)` makes sense.
This file shows that the presupposition fails for *most* elementary cellular
automata, by two independent obstructions.

**Obstruction 1 (parity / origin).**  `V(f)` contains the origin iff the local
rule sends the zero neighbourhood to `0`, i.e. iff the Wolfram number is even.
Hence for all `128` odd rules the fixed locus is not a linear subspace, whatever
`n` is (`odd_rule_no_fixed_dim`).

**Obstruction 2 (Lagrange).**  An affine subvariety of `𝔸ⁿ_{𝔽₂}` has cardinality
dividing `2ⁿ` (`ncard_dvd_of_isAffineSubvariety`).  The majority Rule 232 has
exactly `6` stationary configurations on the ring of size `4`, and `6 ∤ 16`;
Rule 45 has exactly `3` on the ring of size `3`, and `3 ∤ 8`.  So these loci are
not even affine subvarieties (`rule232_not_affine`, `rule45_not_affine`).

Finally `wolfram_fixedpoint_dimension_conjecture_false` collects the falsifying
evidence: the class-4 Rule 110 has the *minimal* variety, the class-3 Rule 90
has dimension `≤ 2` no matter how large `n` is, the class-3 Rule 45 has an empty
variety for `3 ∤ n`, and the class-2 Rule 232 has no dimension at all.
-/

namespace ECAFixedVariety

/-- Stationarity of a configuration is decidable on a finite ring. -/
instance decidableMemFixedSet (rule n : ℕ) [NeZero n] (s : Cfg n) :
    Decidable (s ∈ fixedSet rule n) :=
  inferInstanceAs (Decidable (step rule s = s))

/-! ### Obstruction 1: odd rules miss the origin -/

/-- The zero neighbourhood is stationary exactly for even Wolfram numbers. -/
lemma localRuleZ_zero_zero_zero (rule : ℕ) :
    localRuleZ rule 0 0 0 = if rule % 2 = 1 then 1 else 0 := by
  have hval : (0 : ZMod 2).val = 0 := rfl
  simp only [localRuleZ, hval, Nat.mul_zero, Nat.add_zero, Nat.testBit_zero]
  rcases Nat.mod_two_eq_zero_or_one rule with h | h <;> simp [h]

/-- For an odd Wolfram number the origin is not stationary. -/
lemma zero_notMem_fixedSet_of_odd {rule : ℕ} (h : rule % 2 = 1) (n : ℕ) :
    (0 : Cfg n) ∉ fixedSet rule n := by
  rw [mem_fixedSet_iff]
  intro hmem
  have h0 := hmem 0
  simp only [Pi.zero_apply, localRuleZ_zero_zero_zero, h] at h0
  exact absurd h0 (by decide)

/-- **Half of all elementary rules have no fixed-point dimension.**  For each of
the `128` odd Wolfram numbers the fixed locus misses the origin, hence is not a
linear subvariety, for every ring size `n`. -/
theorem odd_rule_no_fixed_dim {rule : ℕ} (h : rule % 2 = 1) (n d : ℕ) :
    ¬ HasFixedDim rule n d := by
  rintro ⟨W, hW, -⟩
  have hzero : (0 : Cfg n) ∈ fixedSet rule n := by
    rw [← hW]
    exact W.zero_mem
  exact zero_notMem_fixedSet_of_odd h n hzero

/-- Rule 45 (Wolfram class 3) is one of them. -/
theorem rule45_no_fixed_dim (n d : ℕ) : ¬ HasFixedDim 45 n d :=
  odd_rule_no_fixed_dim (by norm_num) n d

/-! ### Obstruction 2: a Lagrange bound on affine subvarieties -/

/-- `S` is an affine subvariety of `𝔸ⁿ_{𝔽₂}`: a translate of a linear subspace.
This is the weakest reading of "`S` has a dimension". -/
def IsAffineSubvariety {n : ℕ} (S : Set (Cfg n)) : Prop :=
  ∃ (v : Cfg n) (W : Submodule (ZMod 2) (Cfg n)), S = (fun w => v + w) '' (W : Set (Cfg n))

/-- A linear subvariety is affine. -/
lemma isAffineSubvariety_of_hasFixedDim {rule n d : ℕ} (h : HasFixedDim rule n d) :
    IsAffineSubvariety (fixedSet rule n) := by
  obtain ⟨W, hW, -⟩ := h
  refine ⟨0, W, ?_⟩
  rw [← hW]
  simp

/-- **Lagrange obstruction.**  The cardinality of an affine subvariety of
`𝔸ⁿ_{𝔽₂}` divides `2ⁿ`. -/
theorem ncard_dvd_of_isAffineSubvariety {n : ℕ} [NeZero n] {S : Set (Cfg n)}
    (h : IsAffineSubvariety S) : S.ncard ∣ 2 ^ n := by
  obtain ⟨v, W, rfl⟩ := h
  have hinj : Function.Injective (fun w : Cfg n => v + w) := add_right_injective v
  rw [Set.ncard_image_of_injective _ hinj]
  have hcard : (W : Set (Cfg n)).ncard = Nat.card W := by
    rw [← Nat.card_coe_set_eq]
    rfl
  rw [hcard]
  have hdvd : Nat.card W.toAddSubgroup ∣ Nat.card (Cfg n) :=
    AddSubgroup.card_addSubgroup_dvd_card W.toAddSubgroup
  have hamb : Nat.card (Cfg n) = 2 ^ n := by
    simp [Cfg, Nat.card_eq_fintype_card]
  rw [hamb] at hdvd
  exact hdvd

/-- If the number of stationary configurations does not divide `2ⁿ`, the
fixed-point locus is not an affine subvariety and has no dimension. -/
theorem not_isAffineSubvariety_of_ncard_not_dvd {n : ℕ} [NeZero n] {S : Set (Cfg n)}
    (h : ¬ S.ncard ∣ 2 ^ n) : ¬ IsAffineSubvariety S :=
  fun hS => h (ncard_dvd_of_isAffineSubvariety hS)

/-! ### The majority Rule 232 -/

/-- Rule 232 is the majority rule. -/
lemma rule232_local_iff :
    ∀ l c r : ZMod 2, localRuleZ 232 l c r = c ↔ (l = c ∨ r = c) := by decide

/-- On the ring of size `4` the majority rule has exactly `6` stationary
configurations (the two constants and the four "domain wall" pairs). -/
theorem rule232_ncard_four : (fixedSet 232 4).ncard = 6 := by
  rw [← Nat.card_coe_set_eq, Nat.card_eq_fintype_card]
  decide

/-- **Rule 232 has no fixed-point dimension.**  Six is not a power of two. -/
theorem rule232_not_affine : ¬ IsAffineSubvariety (fixedSet 232 4) := by
  refine not_isAffineSubvariety_of_ncard_not_dvd ?_
  rw [rule232_ncard_four]
  decide

theorem rule232_no_fixed_dim (d : ℕ) : ¬ HasFixedDim 232 4 d :=
  fun h => rule232_not_affine (isAffineSubvariety_of_hasFixedDim h)

/-! ### Rule 45 again: not even affine -/

/-- On the ring of size `3` Rule 45 has exactly `3` stationary configurations,
the three rotations of the pulse train `100`. -/
theorem rule45_ncard_three : (fixedSet 45 3).ncard = 3 := by
  rw [← Nat.card_coe_set_eq, Nat.card_eq_fintype_card]
  decide

/-- Rule 45 is not an affine subvariety either: `3 ∤ 8`. -/
theorem rule45_not_affine : ¬ IsAffineSubvariety (fixedSet 45 3) := by
  refine not_isAffineSubvariety_of_ncard_not_dvd ?_
  rw [rule45_ncard_three]
  decide

/-! ### Synthesis -/

/-- **The conjecture "Wolfram class = dimension of the fixed-point variety" is
false, in four independent ways.**

1. the Turing-complete class-4 Rule 110 has the *minimal* variety, a single
   point, identical to that of the class-1 Rule 0 — so no invariant of the
   variety can separate them;
2. the class-3 Rule 90 has dimension at most `2`, hence far below `n/2`, for
   every large ring;
3. the class-3 Rule 45 has an *empty* variety whenever `3 ∤ n`, so the "class"
   would have to depend on `n`;
4. the class-2 majority Rule 232 has a variety of cardinality `6`, which is not
   an affine subvariety at all, so it has no dimension to compare with. -/
theorem wolfram_fixedpoint_dimension_conjecture_false :
    (fixedSet 110 8 = fixedSet 0 8 ∧ ¬ HasFixedDim 110 8 8) ∧
    (∀ d, HasFixedDim 90 12 d → 2 * d < 12) ∧
    (fixedSet 45 8 = ∅ ∧ (fixedSet 45 9).Nonempty) ∧
    (∀ d, ¬ HasFixedDim 232 4 d) := by
  refine ⟨⟨rule110_fixedSet_eq_rule0_fixedSet 8, rule110_not_hasFixedDim_max 8 (by norm_num)⟩,
    ?_, ⟨?_, ?_⟩, rule232_no_fixed_dim⟩
  · intro d hd
    exact rule90_dim_lt_half (by norm_num) hd
  · exact rule45_fixedSet_empty_of_not_three_dvd (by norm_num)
  · exact (rule45_fixedSet_nonempty_iff_three_dvd 9).2 (by norm_num)

end ECAFixedVariety