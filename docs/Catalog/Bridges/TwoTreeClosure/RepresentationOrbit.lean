import Mathlib
import Bridges.TwoTreeClosure.TreeCore

/-!
# Magnitude collisions need not split the ascent letter — the orbit conjecture is false

`Bridges.TwoTreeClosure.TreeCore` proves *magnitude blindness* by exhibiting a family
of hypotenuse collisions whose two nodes carry **different** ascent letters
(`letterOf_blind_of_magnitude`).  The natural strengthening — proposed as direction 1
of the previous cycle's `FUTURE_DIRECTIONS.md` — was the *orbit conjecture*:

> whenever `N` has two essentially distinct primitive representations as a sum of two
> coprime squares, the two corresponding tree nodes carry **different** ascent letters,

which would have turned magnitude blindness into a structure theorem and, read the
other way round, would have given a genuine one-bit signal ("the letters of a
collision are never equal").

This file **refutes** that conjecture with an explicit infinite family coming from the
Sophie Germain identity `u⁴ + 4 = (u² - 2u + 2)(u² + 2u + 2)`.  Writing `u = 2s + 7`,

* `sgN s = (4s² + 28s + 49)² + 4 = (4s² + 24s + 37)(4s² + 32s + 65)` is composite;
* it is the hypotenuse of the two distinct primitive nodes
  `sgP s = (4s² + 28s + 47, 4s + 14)` (the `(u² - 2, 2u)` representation) and
  `sgQ s = (4s² + 28s + 49, 2)` (the `(u², 2)` representation);
* and **both** nodes have ascent letter `C`, because `u² - 2 > 3 · 2u` for `u ≥ 7`.

Consequences.

* `orbit_letter_separation_false` : the orbit conjecture is false.
* `collision_letter_dichotomy` : *both* phenomena occur above every bound — there are
  hypotenuse collisions with equal letters and hypotenuse collisions with distinct
  letters.  So "does `N` admit a collision?" carries no letter information at all: the
  letter multiset of the representations of `N` is not a function of the collision
  pattern, and the residual positional content of the tree is not addressable by
  counting representations.

The smallest member (`s = 0`) is `2405 = 5 · 13 · 37 = 47² + 14² = 49² + 2²`, with
`47 > 3 · 14` and `49 > 3 · 2`: two `C`'s.
-/

namespace TwoTreeClosure

/-! ### The Sophie Germain collision family -/

/-- First node of the collision family: the `(u² - 2, 2u)` representation, `u = 2s+7`. -/
def sgP (s : ℕ) : ℕ × ℕ := (4 * s ^ 2 + 28 * s + 47, 4 * s + 14)

/-- Second node of the collision family: the `(u², 2)` representation, `u = 2s+7`. -/
def sgQ (s : ℕ) : ℕ × ℕ := (4 * s ^ 2 + 28 * s + 49, 2)

/-- The common hypotenuse of the two nodes, `u⁴ + 4` for `u = 2s + 7`. -/
def sgN (s : ℕ) : ℕ := (4 * s ^ 2 + 28 * s + 49) ^ 2 + 4

/-- **Sophie Germain factorisation.**  `u⁴ + 4 = (u² - 2u + 2)(u² + 2u + 2)`, in the
shifted form used by the family. -/
theorem sgN_factorisation (s : ℕ) :
    sgN s = (4 * s ^ 2 + 24 * s + 37) * (4 * s ^ 2 + 32 * s + 65) := by
  simp only [sgN]
  ring

/-- Both factors exceed `1`, so every member of the family is composite. -/
theorem sgN_composite (s : ℕ) :
    ∃ a b : ℕ, 1 < a ∧ 1 < b ∧ sgN s = a * b :=
  ⟨4 * s ^ 2 + 24 * s + 37, 4 * s ^ 2 + 32 * s + 65,
    by nlinarith [Nat.zero_le (s ^ 2), Nat.zero_le s],
    by nlinarith [Nat.zero_le (s ^ 2), Nat.zero_le s], sgN_factorisation s⟩

/-- The two nodes are two representations of the same number. -/
theorem hyp_sgP (s : ℕ) : hyp (sgP s).1 (sgP s).2 = sgN s := by
  simp only [hyp, sgP, sgN]
  ring

theorem hyp_sgQ (s : ℕ) : hyp (sgQ s).1 (sgQ s).2 = sgN s := by
  simp only [hyp, sgQ, sgN]
  norm_num

/-! ### Both members are genuine primitive nodes -/

/-- Coprimality for the first node: `gcd(u² - 2, 2u) = 1` for odd `u`, because
`u · 2u = 2(u² - 2) + 4` forces the gcd to divide `4` while `u² - 2` is odd. -/
theorem sgP_coprime (s : ℕ) : Nat.Coprime (4 * s ^ 2 + 28 * s + 47) (4 * s + 14) := by
  obtain ⟨g, hg⟩ : ∃ g, Nat.gcd (4 * s ^ 2 + 28 * s + 47) (4 * s + 14) = g := ⟨_, rfl⟩
  have hdP : g ∣ 4 * s ^ 2 + 28 * s + 47 := hg ▸ Nat.gcd_dvd_left _ _
  have hdn : g ∣ 4 * s + 14 := hg ▸ Nat.gcd_dvd_right _ _
  have key : (2 * s + 7) * (4 * s + 14) = 2 * (4 * s ^ 2 + 28 * s + 47) + 4 := by ring
  have hd4 : g ∣ 4 := by
    have h1 : g ∣ (2 * s + 7) * (4 * s + 14) := Dvd.dvd.mul_left hdn _
    have h2 : g ∣ 2 * (4 * s ^ 2 + 28 * s + 47) := Dvd.dvd.mul_left hdP _
    have h3 : g ∣ (2 * s + 7) * (4 * s + 14) - 2 * (4 * s ^ 2 + 28 * s + 47) :=
      Nat.dvd_sub h1 h2
    rwa [key, Nat.add_sub_cancel_left] at h3
  have hle : g ≤ 4 := Nat.le_of_dvd (by norm_num) hd4
  show Nat.gcd (4 * s ^ 2 + 28 * s + 47) (4 * s + 14) = 1
  rw [hg]
  obtain ⟨k, hk⟩ := hdP
  interval_cases g
  · omega
  · rfl
  · omega
  · omega
  · omega

theorem isNode_sgP (s : ℕ) : IsNode (sgP s).1 (sgP s).2 := by
  refine ⟨by simp only [sgP]; omega, ?_, sgP_coprime s, ?_⟩
  · simp only [sgP]
    nlinarith [Nat.zero_le (s ^ 2), Nat.zero_le s]
  · simp only [sgP]
    omega

theorem isNode_sgQ (s : ℕ) : IsNode (sgQ s).1 (sgQ s).2 := by
  refine ⟨by norm_num [sgQ], ?_, ?_, ?_⟩
  · simp only [sgQ]
    nlinarith [Nat.zero_le (s ^ 2), Nat.zero_le s]
  · show Nat.gcd (4 * s ^ 2 + 28 * s + 49) 2 = 1
    obtain ⟨g, hg⟩ : ∃ g, Nat.gcd (4 * s ^ 2 + 28 * s + 49) 2 = g := ⟨_, rfl⟩
    have hdP : g ∣ 4 * s ^ 2 + 28 * s + 49 := hg ▸ Nat.gcd_dvd_left _ _
    have hd2 : g ∣ 2 := hg ▸ Nat.gcd_dvd_right _ _
    have hle : g ≤ 2 := Nat.le_of_dvd (by norm_num) hd2
    rw [hg]
    obtain ⟨k, hk⟩ := hdP
    interval_cases g
    · omega
    · rfl
    · omega
  · simp only [sgQ]
    omega

/-! ### Both members carry the same ascent letter -/

theorem letterOf_sgP (s : ℕ) : letterOf (sgP s).1 (sgP s).2 = Letter.C := by
  apply letterOf_eq_C
  simp only [sgP]
  nlinarith [Nat.zero_le (s ^ 2), Nat.zero_le s]

theorem letterOf_sgQ (s : ℕ) : letterOf (sgQ s).1 (sgQ s).2 = Letter.C := by
  apply letterOf_eq_C
  simp only [sgQ]
  nlinarith [Nat.zero_le (s ^ 2), Nat.zero_le s]

/-- The two nodes are distinct: their small coordinates differ. -/
theorem sgP_ne_sgQ (s : ℕ) : sgP s ≠ sgQ s := by
  intro h
  have h2 : (sgP s).2 = (sgQ s).2 := by rw [h]
  simp only [sgP, sgQ] at h2
  omega

/-! ### The refutation -/

/-- **The orbit conjecture is false.**  There are two distinct primitive nodes with the
same composite hypotenuse and the *same* ascent letter, so a magnitude collision does
not force a letter split. -/
theorem orbit_letter_separation_false :
    ¬ (∀ m n m' n' : ℕ, IsNode m n → IsNode m' n' → hyp m n = hyp m' n' →
        (m, n) ≠ (m', n') → letterOf m n ≠ letterOf m' n') := by
  intro hcon
  exact hcon (sgP 0).1 (sgP 0).2 (sgQ 0).1 (sgQ 0).2 (isNode_sgP 0) (isNode_sgQ 0)
    (by rw [hyp_sgP, hyp_sgQ]) (by simpa using sgP_ne_sgQ 0)
    (by rw [letterOf_sgP, letterOf_sgQ])

/-- The smallest witness in explicit numbers:
`2405 = 5 · 13 · 37 = 47² + 14² = 49² + 2²`, and both representations are `C`-nodes. -/
theorem smallest_same_letter_collision :
    sgN 0 = 2405 ∧ (2405 : ℕ) = 5 * 13 * 37 ∧
      hyp 47 14 = 2405 ∧ hyp 49 2 = 2405 ∧
      IsNode 47 14 ∧ IsNode 49 2 ∧
      letterOf 47 14 = Letter.C ∧ letterOf 49 2 = Letter.C := by
  refine ⟨by norm_num [sgN], by norm_num, by norm_num [hyp], by norm_num [hyp], ?_, ?_,
    letterOf_eq_C (by norm_num), letterOf_eq_C (by norm_num)⟩
  · exact ⟨by norm_num, by norm_num, by decide, by norm_num⟩
  · exact ⟨by norm_num, by norm_num, by decide, by norm_num⟩

/-- A **semiprime** witness, the case `s = 4`: `50629 = 197 · 257` is a product of two
primes and equals `223² + 30² = 225² + 2²`, both of which are `C`-nodes.  So the
refutation is not an artefact of highly composite hypotenuses: it already happens for
the semiprimes that the ascent question is about. -/
theorem semiprime_same_letter_collision :
    Nat.Prime 197 ∧ Nat.Prime 257 ∧ sgN 4 = 197 * 257 ∧
      hyp 223 30 = 197 * 257 ∧ hyp 225 2 = 197 * 257 ∧
      IsNode 223 30 ∧ IsNode 225 2 ∧
      letterOf 223 30 = Letter.C ∧ letterOf 225 2 = Letter.C := by
  refine ⟨by norm_num, by norm_num, by norm_num [sgN], by norm_num [hyp],
    by norm_num [hyp], ?_, ?_, letterOf_eq_C (by norm_num), letterOf_eq_C (by norm_num)⟩
  · exact ⟨by norm_num, by norm_num, by decide, by norm_num⟩
  · exact ⟨by norm_num, by norm_num, by decide, by norm_num⟩

/-- The family is unbounded: `sgN s ≥ s`, so same-letter collisions occur at every
scale. -/
theorem sgN_ge (s : ℕ) : s ≤ sgN s := by
  simp only [sgN]
  nlinarith [Nat.zero_le (s ^ 2), Nat.zero_le s]

/-- **Dichotomy at every scale.**  Above every bound `T` there is a hypotenuse carrying
two distinct primitive nodes with *equal* letters, and a hypotenuse carrying two
distinct primitive nodes with *different* letters.  Hence neither "collisions split the
letter" nor "collisions preserve the letter" is a law. -/
theorem collision_letter_dichotomy (T : ℕ) :
    (∃ m n m' n' : ℕ, T ≤ hyp m n ∧ IsNode m n ∧ IsNode m' n' ∧ hyp m n = hyp m' n' ∧
        (m, n) ≠ (m', n') ∧ letterOf m n = letterOf m' n') ∧
    (∃ m n m' n' : ℕ, T ≤ hyp m n ∧ IsNode m n ∧ IsNode m' n' ∧ hyp m n = hyp m' n' ∧
        (m, n) ≠ (m', n') ∧ letterOf m n ≠ letterOf m' n') := by
  constructor
  · refine ⟨(sgP T).1, (sgP T).2, (sgQ T).1, (sgQ T).2, ?_, isNode_sgP T, isNode_sgQ T,
      by rw [hyp_sgP, hyp_sgQ], by simpa using sgP_ne_sgQ T, ?_⟩
    · rw [hyp_sgP]; exact sgN_ge T
    · rw [letterOf_sgP, letterOf_sgQ]
  · obtain ⟨hnA, hnB, hhyp, hA, hB⟩ := letterOf_blind_of_magnitude (T + 1) (by omega)
    refine ⟨20 * (T + 1) - 1, 10 * (T + 1) + 2, 20 * (T + 1) + 1, 10 * (T + 1) - 2,
      ?_, hnA, hnB, hhyp, ?_, ?_⟩
    · simp only [hyp]
      have e : 20 * (T + 1) - 1 = 20 * T + 19 := by omega
      rw [e]
      nlinarith [Nat.zero_le (T ^ 2), Nat.zero_le T]
    · intro h
      have h1 : (20 * (T + 1) - 1 : ℕ) = 20 * (T + 1) + 1 := congrArg Prod.fst h
      omega
    · rw [hA, hB]
      exact Letter.noConfusion

end TwoTreeClosure