import Mathlib
import Combinatorics.BerggrenTrees.Parent_hyp_lt

/-!
# Energy-Ascent I: the Berggren branch letter is exactly a ratio band

This file formalises the *control* experiment of the ENERGY-ASCENT round
(`ratio-band → b₁ exact 3000/3000`): the first Berggren / Barning–Hall branch
letter of a primitive Pythagorean triple is a **deterministic function of the
leg ratio `a / b` alone** — a purely positional (order-theoretic, magnitude)
quantity — and conversely the leg ratio band recovers the last generator used
to produce the triple.

We build directly on the catalog module
`Combinatorics.BerggrenTrees.Parent_hyp_lt`, reusing `IsPT`, `invB1`, `invB2`,
`invB3`, `parent_hyp_pos`, `parent_hyp_lt`.

## Main results

* `EnergyAscent.branch_one_iff`, `branch_two_iff`, `branch_three_iff`:
  positivity of the three inverse Barning–Hall parents is *equivalent* to an
  explicit band for the leg ratio, namely `4a < 3b`, `3b < 4a ∧ 3a < 4b`,
  `4b < 3a`.
* `EnergyAscent.branchLetter_eq_descent`: the band-defined letter agrees with
  the descent branch for every non-root primitive triple.
* `EnergyAscent.branchLetter_B1/B2/B3`: applying the `i`-th forward generator
  produces a triple whose ratio band is exactly `i` — the ratio band recovers
  the last letter, for *all* triples (not merely on a sample of 3000).
* `EnergyAscent.branchLetter_ratio_invariant`: the letter is a function of the
  ratio: two triples with `a * b' = a' * b` have the same letter.  This is the
  formal content of "the mechanism is positional".
-/

namespace EnergyAscent

open scoped Classical

/-! ## Elementary Pythagorean estimates -/

/-- In a Pythagorean triple with positive legs the hypotenuse dominates each leg. -/
theorem leg_lt_hyp {a b c : ℤ} (hb : 0 < b) (hc : 0 < c) (hpt : IsPT a b c) : a < c := by
  unfold IsPT at hpt
  nlinarith [sq_nonneg (a - c), sq_nonneg (a + c)]

/-- The hypotenuse is strictly smaller than the sum of the legs. -/
theorem hyp_lt_sum {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) : c < a + b := by
  unfold IsPT at hpt
  nlinarith [mul_pos ha hb]

/-! ## The three branch conditions are ratio bands -/

/-- `a + 2b > 2c` is *exactly* the ratio condition `3a < 4b`. -/
theorem cond_left_iff {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) : 2 * c < a + 2 * b ↔ 3 * a < 4 * b := by
  unfold IsPT at hpt
  constructor
  · intro h
    nlinarith [sq_nonneg (a + 2 * b - 2 * c)]
  · intro h
    nlinarith [sq_nonneg (a + 2 * b - 2 * c), sq_nonneg (a + 2 * b + 2 * c)]

/-- `2a + b > 2c` is *exactly* the ratio condition `3b < 4a`. -/
theorem cond_right_iff {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) : 2 * c < 2 * a + b ↔ 3 * b < 4 * a := by
  unfold IsPT at hpt
  constructor
  · intro h
    nlinarith [sq_nonneg (2 * a + b - 2 * c)]
  · intro h
    nlinarith [sq_nonneg (2 * a + b - 2 * c), sq_nonneg (2 * a + b + 2 * c)]

/-- The non-strict form of `cond_left_iff`. -/
theorem cond_left_le_iff {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) : 2 * c ≤ a + 2 * b ↔ 3 * a ≤ 4 * b := by
  unfold IsPT at hpt
  constructor
  · intro h
    nlinarith [sq_nonneg (a + 2 * b - 2 * c)]
  · intro h
    nlinarith [sq_nonneg (a + 2 * b - 2 * c), sq_nonneg (a + 2 * b + 2 * c)]

/-- The non-strict form of `cond_right_iff`. -/
theorem cond_right_le_iff {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) : 2 * c ≤ 2 * a + b ↔ 3 * b ≤ 4 * a := by
  unfold IsPT at hpt
  constructor
  · intro h
    nlinarith [sq_nonneg (2 * a + b - 2 * c)]
  · intro h
    nlinarith [sq_nonneg (2 * a + b - 2 * c), sq_nonneg (2 * a + b + 2 * c)]

/-- Positivity of the `invB1` parent is equivalent to the ratio band `4a < 3b`. -/
theorem branch_one_iff {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) :
    (0 < (invB1 a b c).1 ∧ 0 < (invB1 a b c).2.1 ∧ 0 < (invB1 a b c).2.2) ↔
      4 * a < 3 * b := by
  have hL := cond_left_iff ha hb hc hpt
  have hRle := cond_right_le_iff ha hb hc hpt
  have hpos := parent_hyp_pos a b c ha hb hc hpt
  constructor
  · rintro ⟨-, h2, -⟩
    simp only [invB1] at h2
    have hnot : ¬ (3 * b ≤ 4 * a) := fun hcon => by have := hRle.mpr hcon; omega
    omega
  · intro h
    have h' : 3 * a < 4 * b := by omega
    have e1 : 2 * c < a + 2 * b := hL.mpr h'
    have e2 : ¬ (2 * c ≤ 2 * a + b) := fun hcon => by have := hRle.mp hcon; omega
    exact ⟨by simp only [invB1]; omega, by simp only [invB1]; omega,
      by simpa [invB1] using hpos⟩

/-- Positivity of the `invB2` parent is equivalent to the middle ratio band. -/
theorem branch_two_iff {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) :
    (0 < (invB2 a b c).1 ∧ 0 < (invB2 a b c).2.1 ∧ 0 < (invB2 a b c).2.2) ↔
      (3 * b < 4 * a ∧ 3 * a < 4 * b) := by
  have hL := cond_left_iff ha hb hc hpt
  have hR := cond_right_iff ha hb hc hpt
  have hpos := parent_hyp_pos a b c ha hb hc hpt
  constructor
  · rintro ⟨h1, h2, -⟩
    simp only [invB2] at h1 h2
    exact ⟨hR.mp (by omega), hL.mp (by omega)⟩
  · rintro ⟨h1, h2⟩
    have e1 := hL.mpr h2
    have e2 := hR.mpr h1
    refine ⟨by simp only [invB2]; omega, by simp only [invB2]; omega, ?_⟩
    simpa [invB2] using hpos

/-- Positivity of the `invB3` parent is equivalent to the ratio band `4b < 3a`. -/
theorem branch_three_iff {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) :
    (0 < (invB3 a b c).1 ∧ 0 < (invB3 a b c).2.1 ∧ 0 < (invB3 a b c).2.2) ↔
      4 * b < 3 * a := by
  have hR := cond_right_iff ha hb hc hpt
  have hLle := cond_left_le_iff ha hb hc hpt
  have hpos := parent_hyp_pos a b c ha hb hc hpt
  constructor
  · rintro ⟨h1, -, -⟩
    simp only [invB3] at h1
    have hnot : ¬ (3 * a ≤ 4 * b) := fun hcon => by have := hLle.mpr hcon; omega
    omega
  · intro h
    have h' : 3 * b < 4 * a := by omega
    have e1 : 2 * c < 2 * a + b := hR.mpr h'
    have e2 : ¬ (2 * c ≤ a + 2 * b) := fun hcon => by have := hLle.mp hcon; omega
    exact ⟨by simp only [invB3]; omega, by simp only [invB3]; omega,
      by simpa [invB3] using hpos⟩

/-! ## The branch letter -/

/-- The **branch letter** of a triple, read off from the leg ratio alone:
`0` when `a/b < 3/4`, `2` when `a/b > 4/3`, and `1` in the middle band.
This is a purely positional (magnitude) statistic — no residue information is
used. -/
def branchLetter (a b : ℤ) : Fin 3 :=
  if 4 * a < 3 * b then 0 else if 4 * b < 3 * a then 2 else 1

theorem branchLetter_eq_zero_iff (a b : ℤ) :
    branchLetter a b = 0 ↔ 4 * a < 3 * b := by
  unfold branchLetter
  split_ifs with h1 h2
  · exact ⟨fun _ => h1, fun _ => rfl⟩
  · exact ⟨fun h => absurd h (by decide), fun h => absurd h h1⟩
  · exact ⟨fun h => absurd h (by decide), fun h => absurd h h1⟩

theorem branchLetter_eq_two_iff {a b : ℤ} (ha : 0 < a) :
    branchLetter a b = 2 ↔ 4 * b < 3 * a := by
  unfold branchLetter
  split_ifs with h1 h2
  · exact ⟨fun h => absurd h (by decide), fun h => absurd h (by omega)⟩
  · exact ⟨fun _ => h2, fun _ => rfl⟩
  · exact ⟨fun h => absurd h (by decide), fun h => absurd h h2⟩

theorem branchLetter_eq_one_iff (a b : ℤ) :
    branchLetter a b = 1 ↔ (3 * b ≤ 4 * a ∧ 3 * a ≤ 4 * b) := by
  unfold branchLetter
  split_ifs with h1 h2
  · exact ⟨fun h => absurd h (by decide), fun h => absurd h.1 (by omega)⟩
  · exact ⟨fun h => absurd h (by decide), fun h => absurd h.2 (by omega)⟩
  · exact ⟨fun _ => ⟨by omega, by omega⟩, fun _ => rfl⟩

/-- **Positional sufficiency.**  The branch letter depends only on the ratio
`a : b`: any two triples with proportional legs carry the same letter.  This is
the formal statement that the letter channel is a function of position, not of
the individual magnitudes. -/
theorem branchLetter_ratio_invariant {a b a' b' : ℤ} (hb : 0 < b) (hb' : 0 < b')
    (h : a * b' = a' * b) : branchLetter a b = branchLetter a' b' := by
  have h1 : 4 * a < 3 * b ↔ 4 * a' < 3 * b' := by
    constructor <;> intro hlt
    · nlinarith
    · nlinarith
  have h2 : 4 * b < 3 * a ↔ 4 * b' < 3 * a' := by
    constructor <;> intro hlt
    · nlinarith
    · nlinarith
  unfold branchLetter
  by_cases hA : 4 * a < 3 * b
  · simp [hA, h1.mp hA]
  · have hA' : ¬ (4 * a' < 3 * b') := fun hc => hA (h1.mpr hc)
    by_cases hB : 4 * b < 3 * a
    · simp [hA, hA', hB, h2.mp hB]
    · have hB' : ¬ (4 * b' < 3 * a') := fun hc => hB (h2.mpr hc)
      simp [hA, hA', hB, hB']

/-! ## Forward Barning–Hall generators -/

/-- First forward Barning–Hall generator. -/
def B1 (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)

/-- Second forward Barning–Hall generator. -/
def B2 (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)

/-- Third forward Barning–Hall generator. -/
def B3 (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)

theorem B1_isPT {a b c : ℤ} (hpt : IsPT a b c) :
    IsPT (B1 a b c).1 (B1 a b c).2.1 (B1 a b c).2.2 := by
  unfold IsPT B1 at *; simp only; linear_combination hpt

theorem B2_isPT {a b c : ℤ} (hpt : IsPT a b c) :
    IsPT (B2 a b c).1 (B2 a b c).2.1 (B2 a b c).2.2 := by
  unfold IsPT B2 at *; simp only; linear_combination hpt

theorem B3_isPT {a b c : ℤ} (hpt : IsPT a b c) :
    IsPT (B3 a b c).1 (B3 a b c).2.1 (B3 a b c).2.2 := by
  unfold IsPT B3 at *; simp only; linear_combination hpt

/-- The three generators are inverted by the catalog's descent maps. -/
theorem invB1_B1 (a b c : ℤ) :
    invB1 (B1 a b c).1 (B1 a b c).2.1 (B1 a b c).2.2 = (a, b, c) := by
  simp only [invB1, B1, Prod.mk.injEq]; refine ⟨by ring, by ring, by ring⟩

theorem invB2_B2 (a b c : ℤ) :
    invB2 (B2 a b c).1 (B2 a b c).2.1 (B2 a b c).2.2 = (a, b, c) := by
  simp only [invB2, B2, Prod.mk.injEq]; refine ⟨by ring, by ring, by ring⟩

theorem invB3_B3 (a b c : ℤ) :
    invB3 (B3 a b c).1 (B3 a b c).2.1 (B3 a b c).2.2 = (a, b, c) := by
  simp only [invB3, B3, Prod.mk.injEq]; refine ⟨by ring, by ring, by ring⟩

/-! ## The ratio band recovers the last generator -/

/-- The child under the first generator lands in the first ratio band. -/
theorem branchLetter_B1 {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) : branchLetter (B1 a b c).1 (B1 a b c).2.1 = 0 := by
  have hlt := hyp_lt_sum ha hb hc hpt
  rw [branchLetter_eq_zero_iff]
  simp only [B1]
  omega

/-- The child under the second generator lands in the middle ratio band. -/
theorem branchLetter_B2 {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) : branchLetter (B2 a b c).1 (B2 a b c).2.1 = 1 := by
  have h1 : a < c := leg_lt_hyp hb hc hpt
  have h2 : b < c := leg_lt_hyp ha hc (by unfold IsPT at *; linarith [hpt])
  rw [branchLetter_eq_one_iff]
  simp only [B2]
  omega

/-- The child under the third generator lands in the third ratio band. -/
theorem branchLetter_B3 {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) : branchLetter (B3 a b c).1 (B3 a b c).2.1 = 2 := by
  have hlt := hyp_lt_sum ha hb hc hpt
  have hac : a < c := leg_lt_hyp hb hc hpt
  have hA : 0 < (B3 a b c).1 := by simp only [B3]; omega
  rw [branchLetter_eq_two_iff hA]
  simp only [B3]
  omega

/-! ## Descent: the letter names the parent -/

/-- For a primitive triple other than the root the two ratio-band boundaries are
never attained. -/
theorem no_boundary {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (hc5 : 5 < c) (hprim : Int.gcd a b = 1) :
    4 * a ≠ 3 * b ∧ 4 * b ≠ 3 * a := by
  have hcop : IsCoprime a b := Int.isCoprime_iff_gcd_eq_one.mpr hprim
  constructor
  · intro h
    have hda : a ∣ 3 := hcop.dvd_of_dvd_mul_right ⟨4, by linarith⟩
    have hdb : b ∣ 4 := hcop.symm.dvd_of_dvd_mul_right ⟨3, by linarith⟩
    have ha3 : a ≤ 3 := Int.le_of_dvd (by norm_num) hda
    have hb4 : b ≤ 4 := Int.le_of_dvd (by norm_num) hdb
    unfold IsPT at hpt
    nlinarith
  · intro h
    have hdb : b ∣ 3 := hcop.symm.dvd_of_dvd_mul_right ⟨4, by linarith⟩
    have hda : a ∣ 4 := hcop.dvd_of_dvd_mul_right ⟨3, by linarith⟩
    have hb3 : b ≤ 3 := Int.le_of_dvd (by norm_num) hdb
    have ha4 : a ≤ 4 := Int.le_of_dvd (by norm_num) hda
    unfold IsPT at hpt
    nlinarith

/-- **Main structural theorem (descent = ratio band).**  For every primitive
Pythagorean triple below the root, the branch letter read off from the leg ratio
names exactly the inverse Barning–Hall matrix that produces a positive parent. -/
theorem branchLetter_eq_descent {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (hc5 : 5 < c) (hprim : Int.gcd a b = 1) :
    (branchLetter a b = 0 ↔
        (0 < (invB1 a b c).1 ∧ 0 < (invB1 a b c).2.1 ∧ 0 < (invB1 a b c).2.2)) ∧
    (branchLetter a b = 1 ↔
        (0 < (invB2 a b c).1 ∧ 0 < (invB2 a b c).2.1 ∧ 0 < (invB2 a b c).2.2)) ∧
    (branchLetter a b = 2 ↔
        (0 < (invB3 a b c).1 ∧ 0 < (invB3 a b c).2.1 ∧ 0 < (invB3 a b c).2.2)) := by
  obtain ⟨hn1, hn2⟩ := no_boundary ha hb hc hpt hc5 hprim
  refine ⟨?_, ?_, ?_⟩
  · rw [branch_one_iff ha hb hc hpt, branchLetter_eq_zero_iff]
  · rw [branch_two_iff ha hb hc hpt, branchLetter_eq_one_iff]
    omega
  · rw [branch_three_iff ha hb hc hpt, branchLetter_eq_two_iff ha]

/-- **Exactly one** of the three parents is positive: the letter is well defined
and the three ratio bands partition the positive quadrant. -/
theorem branch_trichotomy {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (hc5 : 5 < c) (hprim : Int.gcd a b = 1) :
    (4 * a < 3 * b ∧ ¬(3 * b < 4 * a ∧ 3 * a < 4 * b) ∧ ¬(4 * b < 3 * a)) ∨
    (¬(4 * a < 3 * b) ∧ (3 * b < 4 * a ∧ 3 * a < 4 * b) ∧ ¬(4 * b < 3 * a)) ∨
    (¬(4 * a < 3 * b) ∧ ¬(3 * b < 4 * a ∧ 3 * a < 4 * b) ∧ 4 * b < 3 * a) := by
  obtain ⟨hn1, hn2⟩ := no_boundary ha hb hc hpt hc5 hprim
  omega

end EnergyAscent