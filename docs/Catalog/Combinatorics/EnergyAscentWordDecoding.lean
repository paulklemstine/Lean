import Mathlib
import Combinatorics.EnergyAscentBerggrenLetters

/-!
# Energy-Ascent VI: the whole branch word is positional

Energy-Ascent I proved that the *first* Berggren letter is exactly a leg-ratio
band.  The experimental round also measured a joint signal on `(b₁, b₂)`.  Here
we settle the general case: **the entire branch word of a Berggren triple is
decodable from ratio bands alone**, by iterating the band-selected descent.

The decoder `readWord` never inspects a residue, a factorisation, or the
hypotenuse's arithmetic — only three linear comparisons per step.  The main
theorem `EnergyAscent.readWord_applyWord` says it inverts the generator word
exactly, for every word and every admissible starting triple.

## Main results

* `EnergyAscent.descend`: the descent selected by the ratio band.
* `EnergyAscent.descend_Bapply`: the band-selected descent inverts the
  band-named generator.
* `EnergyAscent.readWord_applyWord`: reading `|w|` letters off
  `applyWord w T` returns `w`.
* `EnergyAscent.secondLetter_Bapply`: the specialisation to depth two, the
  formal counterpart of the measured joint `(b₁, b₂)` signal.
-/

namespace EnergyAscent

/-- A triple that is Pythagorean with strictly positive entries. -/
def Good (T : ℤ × ℤ × ℤ) : Prop :=
  0 < T.1 ∧ 0 < T.2.1 ∧ 0 < T.2.2 ∧ IsPT T.1 T.2.1 T.2.2

/-- The Barning–Hall generator named by a letter. -/
def Bapply : Fin 3 → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | 0, T => B1 T.1 T.2.1 T.2.2
  | 1, T => B2 T.1 T.2.1 T.2.2
  | 2, T => B3 T.1 T.2.1 T.2.2

/-- The descent selected by the ratio band of the legs. -/
def descend (T : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  if 4 * T.1 < 3 * T.2.1 then invB1 T.1 T.2.1 T.2.2
  else if 4 * T.2.1 < 3 * T.1 then invB3 T.1 T.2.1 T.2.2
  else invB2 T.1 T.2.1 T.2.2

theorem Good.Bapply_good {T : ℤ × ℤ × ℤ} (hT : Good T) (i : Fin 3) :
    Good (Bapply i T) := by
  obtain ⟨ha, hb, hc, hpt⟩ := hT
  have hlt := hyp_lt_sum ha hb hc hpt
  have hac : T.1 < T.2.2 := leg_lt_hyp hb hc hpt
  have hbc : T.2.1 < T.2.2 := by unfold IsPT at hpt; nlinarith
  fin_cases i
  · exact ⟨by simp only [Bapply, B1]; omega, by simp only [Bapply, B1]; omega,
      by simp only [Bapply, B1]; omega, B1_isPT hpt⟩
  · exact ⟨by simp only [Bapply, B2]; omega, by simp only [Bapply, B2]; omega,
      by simp only [Bapply, B2]; omega, B2_isPT hpt⟩
  · exact ⟨by simp only [Bapply, B3]; omega, by simp only [Bapply, B3]; omega,
      by simp only [Bapply, B3]; omega, B3_isPT hpt⟩

/-- The band of the child names the generator that produced it. -/
theorem branchLetter_Bapply {T : ℤ × ℤ × ℤ} (hT : Good T) (i : Fin 3) :
    branchLetter (Bapply i T).1 (Bapply i T).2.1 = i := by
  obtain ⟨ha, hb, hc, hpt⟩ := hT
  fin_cases i
  · exact branchLetter_B1 ha hb hc hpt
  · exact branchLetter_B2 ha hb hc hpt
  · exact branchLetter_B3 ha hb hc hpt

/-- The band-selected descent inverts the band-named generator: one step of the
decoder undoes one step of the tree. -/
theorem descend_Bapply {T : ℤ × ℤ × ℤ} (hT : Good T) (i : Fin 3) :
    descend (Bapply i T) = T := by
  obtain ⟨ha, hb, hc, hpt⟩ := hT
  have hlt := hyp_lt_sum ha hb hc hpt
  have hac : T.1 < T.2.2 := leg_lt_hyp hb hc hpt
  have hbc : T.2.1 < T.2.2 := by unfold IsPT at hpt; nlinarith
  fin_cases i
  · simp only [descend, Bapply, B1]
    rw [if_pos (show 4 * (T.1 - 2 * T.2.1 + 2 * T.2.2) <
      3 * (2 * T.1 - T.2.1 + 2 * T.2.2) by omega)]
    simpa [B1] using invB1_B1 T.1 T.2.1 T.2.2
  · simp only [descend, Bapply, B2]
    rw [if_neg (show ¬ (4 * (T.1 + 2 * T.2.1 + 2 * T.2.2) <
        3 * (2 * T.1 + T.2.1 + 2 * T.2.2)) by omega),
      if_neg (show ¬ (4 * (2 * T.1 + T.2.1 + 2 * T.2.2) <
        3 * (T.1 + 2 * T.2.1 + 2 * T.2.2)) by omega)]
    simpa [B2] using invB2_B2 T.1 T.2.1 T.2.2
  · simp only [descend, Bapply, B3]
    rw [if_neg (show ¬ (4 * (-T.1 + 2 * T.2.1 + 2 * T.2.2) <
        3 * (-2 * T.1 + T.2.1 + 2 * T.2.2)) by omega),
      if_pos (show 4 * (-2 * T.1 + T.2.1 + 2 * T.2.2) <
        3 * (-T.1 + 2 * T.2.1 + 2 * T.2.2) by omega)]
    simpa [B3] using invB3_B3 T.1 T.2.1 T.2.2

/-- Apply a word of generators, leftmost letter last. -/
def applyWord : List (Fin 3) → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | [], T => T
  | i :: w, T => Bapply i (applyWord w T)

/-- The positional decoder: read `n` letters by iterating the band-selected
descent. -/
def readWord : ℕ → ℤ × ℤ × ℤ → List (Fin 3)
  | 0, _ => []
  | n + 1, T => branchLetter T.1 T.2.1 :: readWord n (descend T)

theorem applyWord_good {T : ℤ × ℤ × ℤ} (hT : Good T) :
    ∀ w : List (Fin 3), Good (applyWord w T) := by
  intro w
  induction w with
  | nil => exact hT
  | cons i w ih => exact ih.Bapply_good i

/-- **Full positional decoding.**  The ratio-band decoder recovers the entire
Berggren generator word: no arithmetic beyond three linear comparisons per
level is needed, and no residue information is used anywhere. -/
theorem readWord_applyWord {T : ℤ × ℤ × ℤ} (hT : Good T) :
    ∀ w : List (Fin 3), readWord w.length (applyWord w T) = w := by
  intro w
  induction w with
  | nil => rfl
  | cons i w ih =>
    have hS : Good (applyWord w T) := applyWord_good hT w
    simp only [List.length_cons, readWord, applyWord]
    rw [branchLetter_Bapply hS i, descend_Bapply hS i, ih]

/-- The second letter of a triple, read positionally. -/
def secondLetter (T : ℤ × ℤ × ℤ) : Fin 3 :=
  branchLetter (descend T).1 (descend T).2.1

/-- **Depth-two decoding**, the formal counterpart of the measured joint
`(b₁, b₂)` signal: the first two letters of a triple are exactly the last two
generators applied. -/
theorem secondLetter_Bapply {T : ℤ × ℤ × ℤ} (hT : Good T) (i j : Fin 3) :
    branchLetter (Bapply i (Bapply j T)).1 (Bapply i (Bapply j T)).2.1 = i ∧
      secondLetter (Bapply i (Bapply j T)) = j := by
  have hj : Good (Bapply j T) := hT.Bapply_good j
  refine ⟨branchLetter_Bapply hj i, ?_⟩
  unfold secondLetter
  rw [descend_Bapply hj i]
  exact branchLetter_Bapply hT j

end EnergyAscent