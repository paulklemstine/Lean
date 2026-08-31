import Mathlib
import Combinatorics.EnergyAscentBerggrenLetters

/-!
# Energy-Ascent II: the branch letter is sealed against residues

Companion to `Combinatorics.EnergyAscentBerggrenLetters`.  There we proved that
the first Berggren branch letter `b₁` of a primitive Pythagorean triple is an
*exact* function of the leg ratio (a positional statistic).  Here we prove the
complementary negative half of the ENERGY-ASCENT dichotomy, replicating in
closed form the empirical "residue seal" (`N mod 3^k` null, worst `z = +1.97`):

> **No congruence datum of any modulus carries any information about `b₁`.**

Formally, for every modulus `M ≥ 1` there are two primitive Pythagorean triples
that are componentwise congruent mod `M` yet have different branch letters
(`EnergyAscent.residue_seal`); consequently the branch letter is *not* a
function of the residues `(a mod M, b mod M, c mod M)`
(`EnergyAscent.branchLetter_not_residue_function`), and the failure is not a
small-number accident: the seal persists arbitrarily high up the tree
(`EnergyAscent.residue_seal_unbounded`).

Together with `EnergyAscent.branchLetter_ratio_invariant` this is the formal
version of the round-70 slogan: *the tree letters are sealed against residues,
open to position.*
-/

namespace EnergyAscent

/-- The one-parameter family `(m² − 1, 2m, m² + 1)` of Pythagorean triples,
which is primitive exactly when `m` is even.  For `m = 2` it is the root
`(3, 4, 5)`; for `m ≥ 4` it lies deep in the third ratio band. -/
def fam (m : ℤ) : ℤ × ℤ × ℤ := (m ^ 2 - 1, 2 * m, m ^ 2 + 1)

theorem fam_isPT (m : ℤ) : IsPT (fam m).1 (fam m).2.1 (fam m).2.2 := by
  unfold IsPT fam; simp only; ring

theorem fam_pos {m : ℤ} (hm : 2 ≤ m) :
    0 < (fam m).1 ∧ 0 < (fam m).2.1 ∧ 0 < (fam m).2.2 := by
  refine ⟨?_, by simp only [fam]; omega, ?_⟩ <;> · simp only [fam]; nlinarith

/-- For even `m` the family member is primitive: an explicit Bézout relation
`k·(2m) − (m² − 1) = 1` with `m = 2k`. -/
theorem fam_coprime {k : ℤ} : Int.gcd (fam (2 * k)).1 (fam (2 * k)).2.1 = 1 := by
  have h : IsCoprime ((fam (2 * k)).1) ((fam (2 * k)).2.1) := by
    refine ⟨-1, k, ?_⟩
    simp only [fam]
    ring
  exact Int.isCoprime_iff_gcd_eq_one.mp h

/-- Deep in the family the leg ratio is large, so the branch letter is `2`. -/
theorem fam_letter_two {m : ℤ} (hm : 4 ≤ m) : branchLetter (fam m).1 (fam m).2.1 = 2 := by
  have hpos : 0 < (fam m).1 := by simp only [fam]; nlinarith
  rw [branchLetter_eq_two_iff hpos]
  simp only [fam]
  nlinarith

/-- The root of the Berggren tree carries the middle letter. -/
theorem root_letter_one : branchLetter 3 4 = 1 := by
  rw [branchLetter_eq_one_iff]; omega

/-- **Residue seal.**  For every modulus `M ≥ 1` there exist two primitive
Pythagorean triples with positive entries which are componentwise congruent
modulo `M` but whose Berggren branch letters differ. -/
theorem residue_seal (M : ℤ) (hM : 0 < M) :
    ∃ a b c a' b' c' : ℤ,
      (0 < a ∧ 0 < b ∧ 0 < c ∧ IsPT a b c ∧ Int.gcd a b = 1) ∧
      (0 < a' ∧ 0 < b' ∧ 0 < c' ∧ IsPT a' b' c' ∧ Int.gcd a' b' = 1) ∧
      (a ≡ a' [ZMOD M] ∧ b ≡ b' [ZMOD M] ∧ c ≡ c' [ZMOD M]) ∧
      branchLetter a b ≠ branchLetter a' b' := by
  set m : ℤ := 2 + 2 * M with hmdef
  have hm4 : 4 ≤ m := by omega
  obtain ⟨p1, p2, p3⟩ := fam_pos (show (2 : ℤ) ≤ m by omega)
  have hcop : Int.gcd (fam m).1 (fam m).2.1 = 1 := by
    have : m = 2 * (1 + M) := by omega
    rw [this]; exact fam_coprime
  refine ⟨3, 4, 5, (fam m).1, (fam m).2.1, (fam m).2.2,
    ⟨by norm_num, by norm_num, by norm_num, by unfold IsPT; norm_num, by decide⟩,
    ⟨p1, p2, p3, fam_isPT m, hcop⟩, ⟨?_, ?_, ?_⟩, ?_⟩
  · -- `m² − 1 ≡ 3 (mod M)` since `m ≡ 2 (mod M)`
    have : M ∣ (fam m).1 - 3 := ⟨4 * M + 8, by simp only [fam, hmdef]; ring⟩
    exact (Int.modEq_iff_dvd.mpr (by simpa using this)).symm.symm
  · have : M ∣ (fam m).2.1 - 4 := ⟨4, by simp only [fam, hmdef]; ring⟩
    exact (Int.modEq_iff_dvd.mpr (by simpa using this)).symm.symm
  · have : M ∣ (fam m).2.2 - 5 := ⟨4 * M + 8, by simp only [fam, hmdef]; ring⟩
    exact (Int.modEq_iff_dvd.mpr (by simpa using this)).symm.symm
  · rw [root_letter_one, fam_letter_two hm4]
    decide

/-- **No residue oracle.**  For every modulus `M ≥ 1`, the Berggren branch
letter of a primitive Pythagorean triple is not a function of the residues of
its entries modulo `M`. -/
theorem branchLetter_not_residue_function (M : ℤ) (hM : 0 < M) :
    ¬ ∃ f : ℤ → ℤ → ℤ → Fin 3,
        ∀ a b c : ℤ, 0 < a → 0 < b → 0 < c → IsPT a b c → Int.gcd a b = 1 →
          branchLetter a b = f (a % M) (b % M) (c % M) := by
  rintro ⟨f, hf⟩
  obtain ⟨a, b, c, a', b', c', ⟨ha, hb, hc, hpt, hg⟩, ⟨ha', hb', hc', hpt', hg'⟩,
    ⟨e1, e2, e3⟩, hne⟩ := residue_seal M hM
  apply hne
  rw [hf a b c ha hb hc hpt hg, hf a' b' c' ha' hb' hc' hpt' hg']
  rw [Int.ModEq] at e1 e2 e3
  rw [e1, e2, e3]

/-- The seal is not a small-number accident: for every modulus `M` and every
height bound `B` there is a triple *above* that height, congruent to the root
`(3, 4, 5)` modulo `M`, whose letter differs from the root's. -/
theorem residue_seal_unbounded (M : ℤ) (hM : 0 < M) (B : ℤ) :
    ∃ a b c : ℤ, B < c ∧
      (0 < a ∧ 0 < b ∧ 0 < c ∧ IsPT a b c ∧ Int.gcd a b = 1) ∧
      (3 ≡ a [ZMOD M] ∧ 4 ≡ b [ZMOD M] ∧ 5 ≡ c [ZMOD M]) ∧
      branchLetter a b ≠ branchLetter 3 4 := by
  obtain ⟨t, htpos, htB⟩ : ∃ t : ℤ, 0 < t ∧ B < (2 + 2 * M * t) ^ 2 + 1 := by
    refine ⟨max 1 B, lt_of_lt_of_le zero_lt_one (le_max_left _ _), ?_⟩
    have h1 : (1 : ℤ) ≤ max 1 B := le_max_left _ _
    have h2 : B ≤ max 1 B := le_max_right _ _
    have h3 : max 1 B ≤ M * max 1 B :=
      le_mul_of_one_le_left (by linarith) (by linarith)
    nlinarith
  set m : ℤ := 2 + 2 * M * t with hmdef
  have hMt : 0 < M * t := mul_pos hM htpos
  have hm4 : 4 ≤ m := by rw [hmdef]; linarith
  obtain ⟨p1, p2, p3⟩ := fam_pos (show (2 : ℤ) ≤ m by omega)
  have hcop : Int.gcd (fam m).1 (fam m).2.1 = 1 := by
    have hm2 : m = 2 * (1 + M * t) := by rw [hmdef]; ring
    rw [hm2]; exact fam_coprime
  refine ⟨(fam m).1, (fam m).2.1, (fam m).2.2, ?_,
    ⟨p1, p2, p3, fam_isPT m, hcop⟩, ⟨?_, ?_, ?_⟩, ?_⟩
  · simpa [fam, hmdef] using htB
  · exact Int.modEq_iff_dvd.mpr ⟨4 * M * t ^ 2 + 8 * t, by simp only [fam, hmdef]; ring⟩
  · exact Int.modEq_iff_dvd.mpr ⟨4 * t, by simp only [fam, hmdef]; ring⟩
  · exact Int.modEq_iff_dvd.mpr ⟨4 * M * t ^ 2 + 8 * t, by simp only [fam, hmdef]; ring⟩
  · rw [root_letter_one, fam_letter_two hm4]
    decide

/-- **The ENERGY-ASCENT dichotomy.**  In one statement: the branch letter is a
function of position (the leg ratio) but of no residue datum.  The positive half
is `branchLetter_ratio_invariant`; the negative half is `residue_seal`. -/
theorem energy_ascent_dichotomy (M : ℤ) (hM : 0 < M) :
    (∀ a b a' b' : ℤ, 0 < b → 0 < b' → a * b' = a' * b →
        branchLetter a b = branchLetter a' b') ∧
    (∃ a b c a' b' c' : ℤ,
      (0 < a ∧ 0 < b ∧ 0 < c ∧ IsPT a b c ∧ Int.gcd a b = 1) ∧
      (0 < a' ∧ 0 < b' ∧ 0 < c' ∧ IsPT a' b' c' ∧ Int.gcd a' b' = 1) ∧
      (a ≡ a' [ZMOD M] ∧ b ≡ b' [ZMOD M] ∧ c ≡ c' [ZMOD M]) ∧
      branchLetter a b ≠ branchLetter a' b') :=
  ⟨fun _ _ _ _ hb hb' h => branchLetter_ratio_invariant hb hb' h, residue_seal M hM⟩

end EnergyAscent