import Novelty.ECAPeriodicPointLattice

/-!
# Cycle 3: maximal dimension forces the identity automaton

The conjecture predicts that the Turing-complete class-4 rules have fixed-point
variety of maximal dimension `n`.  Cycles 1–2 showed Rule 110 has dimension `0`.
Here we close the question completely by classifying *which* elementary rules can
have a maximal-dimensional fixed-point variety: **exactly one, the identity Rule
204**, whose dynamics is trivial.

## Main results

* `exists_cfg_window` — on a ring of size `n ≥ 3` every `3`-cell window can be
  prescribed independently: the fixed-point equations really are `n` independent
  cubic equations.
* `fixedSet_eq_univ_iff` — the variety is all of `𝔸ⁿ` iff the local rule is the
  centre projection.
* `localRuleZ_eq_id_iff_eq_204` — for a genuine Wolfram number (`rule < 256`)
  that happens iff the rule is `204`.
* `hasFixedDim_max_iff` / `hasFixedDim_max_iff_eq_204` — **maximal dimension
  characterises the identity automaton**.  In particular the `255`
  non-identity rules, Rule 110 included, all fail the conjecture's class-4
  prediction, while the unique rule that satisfies it is the most trivial one in
  the whole family.
-/

namespace ECAFixedVariety

/-- On a ring of size at least `3` the cells `0, 1, 2` are distinct. -/
lemma zmod_zero_one_two_distinct {n : ℕ} (hn : 3 ≤ n) :
    (0 : ZMod n) ≠ 1 ∧ (1 : ZMod n) ≠ 2 ∧ (0 : ZMod n) ≠ 2 := by
  haveI : NeZero n := ⟨by omega⟩
  have e1 : ((1 : ℕ) : ZMod n) = 1 := by push_cast; ring
  have e2 : ((2 : ℕ) : ZMod n) = 2 := by push_cast; ring
  have v0 : (0 : ZMod n).val = 0 := ZMod.val_zero
  have v1 : (1 : ZMod n).val = 1 := by rw [← e1, ZMod.val_natCast_of_lt (by omega)]
  have v2 : (2 : ZMod n).val = 2 := by rw [← e2, ZMod.val_natCast_of_lt (by omega)]
  refine ⟨?_, ?_, ?_⟩ <;> intro h <;> [rw [h] at v0; rw [h] at v1; rw [h] at v0] <;> omega

/-- **Independence of the local windows.**  For `n ≥ 3` every prescribed
neighbourhood `(l, c, r)` occurs as the window around the cell `1`. -/
theorem exists_cfg_window {n : ℕ} (hn : 3 ≤ n) (l c r : ZMod 2) :
    ∃ s : Cfg n, s (1 - 1) = l ∧ s 1 = c ∧ s (1 + 1) = r := by
  obtain ⟨h01, h12, h02⟩ := zmod_zero_one_two_distinct hn
  refine ⟨fun i => if i = 0 then l else if i = 1 then c else if i = 2 then r else 0, ?_, ?_, ?_⟩
  · simp
  · simp [h01.symm]
  · have e : (1 : ZMod n) + 1 = 2 := by ring
    rw [e]
    simp [h02.symm, h12.symm]

/-- The fixed-point variety fills affine space exactly when the local rule is the
centre projection. -/
theorem fixedSet_eq_univ_iff {rule n : ℕ} (hn : 3 ≤ n) :
    fixedSet rule n = Set.univ ↔ ∀ l c r : ZMod 2, localRuleZ rule l c r = c := by
  constructor
  · intro h l c r
    obtain ⟨s, hl, hc, hr⟩ := exists_cfg_window (n := n) hn l c r
    have hs : s ∈ fixedSet rule n := by rw [h]; trivial
    rw [mem_fixedSet_iff] at hs
    have := hs 1
    rwa [hl, hc, hr] at this
  · intro h
    ext s
    simp only [Set.mem_univ, iff_true, mem_fixedSet_iff]
    intro i
    exact h _ _ _

/-- A Wolfram number below `256` acts as the identity precisely when it is `204`. -/
theorem localRuleZ_eq_id_iff_eq_204 {rule : ℕ} (hrule : rule < 256) :
    (∀ l c r : ZMod 2, localRuleZ rule l c r = c) ↔ rule = 204 := by
  constructor
  · intro h
    -- read off the eight bits of the truth table
    have bit : ∀ l c r : ZMod 2,
        rule.testBit (4 * l.val + 2 * c.val + r.val) = decide (c = 1) := by
      intro l c r
      have hlc := h l c r
      rw [localRuleZ] at hlc
      by_cases hbit : rule.testBit (4 * l.val + 2 * c.val + r.val) = true
      · rw [if_pos hbit] at hlc
        rw [hbit, ← hlc]
        decide
      · rw [if_neg hbit] at hlc
        rw [Bool.not_eq_true] at hbit
        rw [hbit, ← hlc]
        decide
    refine Nat.eq_of_testBit_eq (fun j => ?_)
    rcases lt_or_ge j 8 with hj | hj
    · interval_cases j
      · simpa using bit 0 0 0
      · simpa using bit 0 0 1
      · simpa using bit 0 1 0
      · simpa using bit 0 1 1
      · simpa using bit 1 0 0
      · simpa using bit 1 0 1
      · simpa using bit 1 1 0
      · simpa using bit 1 1 1
    · have h1 : rule.testBit j = false := by
        apply Nat.testBit_lt_two_pow
        calc rule < 256 := hrule
          _ = 2 ^ 8 := by norm_num
          _ ≤ 2 ^ j := Nat.pow_le_pow_right (by norm_num) hj
      have h2 : (204 : ℕ).testBit j = false := by
        apply Nat.testBit_lt_two_pow
        calc (204 : ℕ) < 2 ^ 8 := by norm_num
          _ ≤ 2 ^ j := Nat.pow_le_pow_right (by norm_num) hj
      rw [h1, h2]
  · rintro rfl
    exact rule204_localRuleZ

/-- **Maximal dimension characterises the identity automaton.** -/
theorem hasFixedDim_max_iff {rule n : ℕ} (hn : 3 ≤ n) :
    HasFixedDim rule n n ↔ ∀ l c r : ZMod 2, localRuleZ rule l c r = c := by
  haveI : NeZero n := ⟨by omega⟩
  constructor
  · intro h
    obtain ⟨W, hW, hd⟩ := h
    have hdim : Module.finrank (ZMod 2) (Cfg n) = n := by simp [Cfg]
    have htop : W = ⊤ := Submodule.eq_top_of_finrank_eq (by rw [hd, hdim])
    rw [htop] at hW
    have : fixedSet rule n = Set.univ := by
      rw [← hW]
      simp
    exact (fixedSet_eq_univ_iff hn).1 this
  · intro h
    have huniv : fixedSet rule n = Set.univ := (fixedSet_eq_univ_iff hn).2 h
    refine ⟨⊤, by simp [huniv], ?_⟩
    rw [finrank_top]
    simp [Cfg]

/-- **Final classification.**  Among the `256` elementary cellular automata,
exactly one — the identity Rule 204 — has a fixed-point variety of maximal
dimension.  Every other rule, in particular the Turing-complete Rule 110, fails
the conjecture's class-4 prediction. -/
theorem hasFixedDim_max_iff_eq_204 {rule n : ℕ} (hrule : rule < 256) (hn : 3 ≤ n) :
    HasFixedDim rule n n ↔ rule = 204 :=
  (hasFixedDim_max_iff hn).trans (localRuleZ_eq_id_iff_eq_204 hrule)

/-- The Turing-complete Rule 110 is not the identity, hence never maximal. -/
theorem rule110_not_max {n : ℕ} (hn : 3 ≤ n) : ¬ HasFixedDim 110 n n := by
  rw [hasFixedDim_max_iff_eq_204 (by norm_num) hn]
  norm_num

end ECAFixedVariety