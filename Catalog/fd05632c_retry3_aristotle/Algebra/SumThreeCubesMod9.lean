import Mathlib

/-!
# The mod-9 characterization for sums of three cubes

An integer `n` can only be a sum of three integer cubes if `n` is not congruent to
`4` or `5` modulo `9` (equivalently, `n ≢ ±4 (mod 9)`).  This file establishes that
**obstruction** completely and rigorously.

The converse — that *every* integer `n` with `n ≢ ±4 (mod 9)` is a sum of three cubes —
is the famous open conjecture of Heath-Brown.  It is **not** a theorem (it is unproven in
mathematics), and in particular it cannot be obtained from finitely many explicit witnesses:
each residue class contains integers (e.g. `0, 9, 18, …` in the class of `0`) that require
genuinely different representations.  See `mod9_complete` below for a precise discussion.
-/

namespace SumThreeCubesMod9

/-- `n` is a sum of three integer cubes. -/
def IsSumThreeCubes (n : ℤ) : Prop := ∃ x y z : ℤ, x^3 + y^3 + z^3 = n

/-- Every integer cube is `0`, `1`, or `8` modulo `9`. -/
theorem cube_zmod9 (x : ℤ) :
    ((x^3 : ℤ) : ZMod 9) ∈ ({0, 1, 8} : Set (ZMod 9)) := by
  norm_num [pow_three]
  revert x
  -- It suffices to check all 9 residues mod 9.
  have h_cases : ∀ x : ZMod 9, x * (x * x) = 0 ∨ x * (x * x) = 1 ∨ x * (x * x) = 8 := by
    decide
  exact fun x => h_cases x

/-- No sum of three elements of `{0,1,8}` in `ZMod 9` equals `4` or `5`
(finite check over `9³ = 729` cases). -/
theorem zmod9_sum_not_4_or_5 :
    ∀ a b c : ZMod 9, a ∈ ({0, 1, 8} : Set (ZMod 9)) → b ∈ ({0, 1, 8} : Set (ZMod 9)) →
      c ∈ ({0, 1, 8} : Set (ZMod 9)) → a + b + c ≠ 4 ∧ a + b + c ≠ 5 := by
  decide

/-- If `n ≡ 4` or `n ≡ 5 (mod 9)` then `n` is not a sum of three cubes. -/
theorem mod9_obstruction (n : ℤ) (h : (n : ZMod 9) = 4 ∨ (n : ZMod 9) = 5) :
    ¬ IsSumThreeCubes n := by
  rintro ⟨x, y, z, rfl⟩
  convert zmod9_sum_not_4_or_5 _ _ _ (cube_zmod9 x) (cube_zmod9 y) (cube_zmod9 z) using 1
  aesop

/-- `n` is a sum of three cubes iff `-n` is (negate each coordinate). -/
theorem neg_iff (n : ℤ) : IsSumThreeCubes n ↔ IsSumThreeCubes (-n) := by
  constructor <;> rintro ⟨x, y, z, h⟩ <;> exact ⟨-x, -y, -z, by linarith⟩

/-! ### Explicit witnesses for the representable residue classes -/

theorem residue_zero : IsSumThreeCubes 0 := ⟨0, 0, 0, by ring⟩
theorem residue_one : IsSumThreeCubes 1 := ⟨1, 0, 0, by ring⟩
theorem residue_two : IsSumThreeCubes 2 := ⟨1, 1, 0, by ring⟩
theorem residue_three : IsSumThreeCubes 3 := ⟨1, 1, 1, by ring⟩
theorem residue_six : IsSumThreeCubes 6 := ⟨2, -1, -1, by ring⟩
theorem residue_seven : IsSumThreeCubes 7 := ⟨2, 0, -1, by ring⟩
theorem residue_eight : IsSumThreeCubes 8 := ⟨2, 0, 0, by ring⟩

/-! ### The characterization theorem

The genuinely provable content is the obstruction direction.  We package it together with
the (open) converse, isolating the unproven implication into the lemma
`heath_brown_conjecture` so that the status of every statement is explicit. -/

/-- **Provable, complete obstruction direction.**
If `n ≡ 4` or `5 (mod 9)` then `n` is not a sum of three cubes; equivalently, every sum of
three cubes is `≢ ±4 (mod 9)`.  This is the half of the characterization that is a theorem. -/
theorem mod9_complete_mpr (n : ℤ) (h : (n : ZMod 9) ∈ ({4, 5} : Set (ZMod 9))) :
    ¬ IsSumThreeCubes n := by
  apply mod9_obstruction
  rcases h with h | h
  · exact Or.inl h
  · exact Or.inr (by simpa using h)

/-- **Heath-Brown's conjecture (OPEN — not a theorem).**
Every integer `n` with `n ≢ ±4 (mod 9)` is a sum of three integer cubes.  This is a famous
unsolved problem in number theory; it is *not* provable from the finitely many explicit
witnesses above, since each residue class contains infinitely many integers requiring
different representations (and it is not known to follow from any currently available
mathematics).  It is recorded here as a hypothesis, with an honest `sorry`, and is used only
to state the full biconditional `mod9_complete`. -/
theorem heath_brown_conjecture (n : ℤ) (h : (n : ZMod 9) ∉ ({4, 5} : Set (ZMod 9))) :
    IsSumThreeCubes n := by
  sorry

/-- **Complete characterization** (one direction is the open Heath-Brown conjecture).
`n` is *not* a sum of three cubes iff `n ≡ 4` or `5 (mod 9)`.

* The `mpr` direction (`n ≡ 4,5 (mod 9) → ¬ representable`) is fully proven via
  `mod9_complete_mpr` / `mod9_obstruction`.
* The `mp` direction (`¬ representable → n ≡ 4,5 (mod 9)`) is, by contraposition, exactly
  the assertion that every `n ≢ ±4 (mod 9)` is a sum of three cubes — Heath-Brown's open
  conjecture (`heath_brown_conjecture`). It is therefore not a theorem. -/
theorem mod9_complete (n : ℤ) :
    ¬ IsSumThreeCubes n ↔ (n : ZMod 9) ∈ ({4, 5} : Set (ZMod 9)) := by
  constructor
  · intro hn
    by_contra hres
    exact hn (heath_brown_conjecture n hres)
  · exact mod9_complete_mpr n

end SumThreeCubesMod9