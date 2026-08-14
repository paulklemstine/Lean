import Tropical.SmoothSelfHintInvisibleTargets

/-!
# Positive information, zero prediction advantage

The previous files measure the leak in *bits*: the asymmetric statistic has mutual
information exactly `0` (`miF_asym_zero`), the symmetric one is strictly positive
(`miF_symJointG_pos_of_nontrivial`).  Mutual information is, however, not the quantity an
attacker cares about: what matters operationally is whether reading the residue lets one
**predict** the secret event better than by guessing the majority answer.

This file computes that.  A *residue-reading predictor* is a function `f : G → Bool`; its
score is the number of ordered pairs `(a, b)` on which its guess about the event is
correct (`predCount`).  The results:

* `SmoothSelfHint.predCount_asym_le_best_constant` — for the asymmetric event and **any**
  target `A`, no predictor beats the better of the two constant predictors.  This is the
  algorithmic form of `miF_asym_zero`: advantage exactly `0`.
* `SmoothSelfHint.predCount_sym_singleton_le_constant` — for the symmetric event with the
  arithmetic target `A = {1}` in a group with `4 ≤ |G|`, no predictor beats the constant
  `false` predictor either, **even though the mutual information is strictly positive**
  (`sym_singleton_positive_information_zero_advantage`).  Bits leak, but they are not
  actionable bits.
* `SmoothSelfHint.predCount_sym_beats_constants_of_card_three` — the hypothesis
  `4 ≤ |G|` is sharp: in a group of order `3` the Bayes predictor `n ↦ (n ≠ 1)` scores
  `6`, strictly more than either constant predictor (`5` and `4`).
* `SmoothSelfHint.units_positive_information_zero_advantage` — the arithmetic conclusion
  for `(ZMod l)ˣ`, `l ≥ 5`: the symmetric divisibility event leaks a strictly positive
  number of bits about `N mod l`, and yet no function of `N mod l` predicts it better
  than the trivial guess.
-/

open Finset

namespace SmoothSelfHint

section Group

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- The score of a residue-reading predictor `f`: the number of ordered pairs `(a, b)`
whose event value is guessed correctly, when the fibre over `n` contains `s n` pairs on
which the event holds. -/
def predCount (s : G → ℕ) (f : G → Bool) : ℕ :=
  ∑ n : G, (if f n then s n else Fintype.card G - s n)

omit [Group G] [DecidableEq G] in
@[simp]
theorem predCount_true (s : G → ℕ) : predCount s (fun _ => true) = ∑ n : G, s n := by
  simp [predCount]

omit [Group G] [DecidableEq G] in
@[simp]
theorem predCount_false (s : G → ℕ) :
    predCount s (fun _ => false) = ∑ n : G, (Fintype.card G - s n) := by
  simp [predCount]

omit [Group G] [DecidableEq G] in
/-- A predictor never beats the pointwise Bayes rule. -/
theorem predCount_le_bayes (s : G → ℕ) (f : G → Bool) :
    predCount s f ≤ ∑ n : G, max (s n) (Fintype.card G - s n) := by
  refine Finset.sum_le_sum fun n _ => ?_
  by_cases h : f n = true
  · simp [h]
  · simp only [Bool.not_eq_true] at h
    simp [h]

/-- **No advantage for the asymmetric event.**  Because the asymmetric fibre count is
`|A|` for every `n` (`asym_fiber_card`), every residue-reading predictor scores at most
as much as the better of the two constant predictors: the advantage of reading `N mod l`
is exactly zero. -/
theorem predCount_asym_le_best_constant (A : Finset G) (f : G → Bool) :
    predCount (fun n => (asymFiber A n).card) f
      ≤ max (predCount (fun n => (asymFiber A n).card) (fun _ => true))
          (predCount (fun n => (asymFiber A n).card) (fun _ => false)) := by
  have hs : ∀ n : G, (asymFiber A n).card = A.card := fun n => asym_fiber_card A n
  have hbound : predCount (fun n => (asymFiber A n).card) f
      ≤ Fintype.card G * max A.card (Fintype.card G - A.card) := by
    have := predCount_le_bayes (fun n => (asymFiber A n).card) f
    refine this.trans ?_
    have : ∀ n : G, max ((asymFiber A n).card) (Fintype.card G - (asymFiber A n).card)
        = max A.card (Fintype.card G - A.card) := by
      intro n; rw [hs n]
    rw [Finset.sum_congr rfl (fun n _ => this n), Finset.sum_const, Finset.card_univ,
      smul_eq_mul]
  refine hbound.trans ?_
  have htrue : predCount (fun n => (asymFiber A n).card) (fun _ => true)
      = Fintype.card G * A.card := by
    rw [predCount_true, Finset.sum_congr rfl (fun n _ => hs n), Finset.sum_const,
      Finset.card_univ, smul_eq_mul]
  have hfalse : predCount (fun n => (asymFiber A n).card) (fun _ => false)
      = Fintype.card G * (Fintype.card G - A.card) := by
    rw [predCount_false, Finset.sum_congr rfl (fun n _ => by rw [hs n]), Finset.sum_const,
      Finset.card_univ, smul_eq_mul]
  rw [htrue, hfalse]
  rcases le_total A.card (Fintype.card G - A.card) with h | h
  · rw [max_eq_right h, max_eq_right (Nat.mul_le_mul_left _ h)]
  · rw [max_eq_left h, max_eq_left (Nat.mul_le_mul_left _ h)]

/-- **No advantage for the symmetric event either, once `|G| ≥ 4`.**  The symmetric fibre
count of the singleton target is `1` or `2`, both at most `|G| - 2`, so guessing "the
event fails" is optimal for every residue: the strictly positive mutual information of
`miF_symJointG_pos_singleton` buys the attacker nothing. -/
theorem predCount_sym_singleton_le_constant (hg : 4 ≤ Fintype.card G) (f : G → Bool) :
    predCount (fun n => (symFiber ({1} : Finset G) n).card) f
      ≤ predCount (fun n => (symFiber ({1} : Finset G) n).card) (fun _ => false) := by
  rw [predCount_false]
  refine Finset.sum_le_sum fun n _ => ?_
  have hle : (symFiber ({1} : Finset G) n).card ≤ 2 := by
    rw [sym_fiber_card_one n]
    split <;> omega
  by_cases h : f n = true
  · rw [if_pos h]
    show (symFiber ({1} : Finset G) n).card
      ≤ Fintype.card G - (symFiber ({1} : Finset G) n).card
    omega
  · simp only [Bool.not_eq_true] at h
    simp [h]

/-- The **sharp contrast**: positive information, zero actionable advantage.  For the
singleton target in a group with at least four elements the symmetric statistic leaks a
strictly positive number of bits, and yet no residue-reading predictor beats the constant
one. -/
theorem sym_singleton_positive_information_zero_advantage (hg : 4 ≤ Fintype.card G) :
    0 < miF (symJointG ({1} : Finset G)) ∧
      ∀ f : G → Bool,
        predCount (fun n => (symFiber ({1} : Finset G) n).card) f
          ≤ predCount (fun n => (symFiber ({1} : Finset G) n).card) (fun _ => false) :=
  ⟨miF_symJointG_pos_singleton (by omega), fun f => predCount_sym_singleton_le_constant hg f⟩

/-! ### Sharpness of the hypothesis `4 ≤ |G|` -/

/-- A two-valued sum over a finite group: `a` at the identity, `b` elsewhere. -/
theorem sum_ite_one_eq (a b : ℕ) :
    ∑ n : G, (if n = 1 then a else b) = a + (Fintype.card G - 1) * b := by
  rw [← Finset.add_sum_erase _ _ (Finset.mem_univ (1 : G))]
  congr 1
  · simp
  · rw [Finset.sum_congr rfl (fun x hx => if_neg (Finset.ne_of_mem_erase hx)), Finset.sum_const,
    Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ, smul_eq_mul]

/-- **The hypothesis `4 ≤ |G|` is sharp.**  In a group of order three the Bayes predictor
`n ↦ (n ≠ 1)` scores `6`, strictly better than the constant predictors, which score `5`
and `4`: there — and only there — the symmetric leak *is* actionable. -/
theorem predCount_sym_beats_constants_of_card_three (h3 : Fintype.card G = 3) :
    max (predCount (fun n => (symFiber ({1} : Finset G) n).card) (fun _ => true))
        (predCount (fun n => (symFiber ({1} : Finset G) n).card) (fun _ => false))
      < predCount (fun n => (symFiber ({1} : Finset G) n).card)
          (fun n => decide (n ≠ 1)) := by
  have hs : ∀ n : G, (symFiber ({1} : Finset G) n).card = if n = 1 then 1 else 2 :=
    sym_fiber_card_one
  have htrue : predCount (fun n => (symFiber ({1} : Finset G) n).card) (fun _ => true) = 5 := by
    rw [predCount_true, Finset.sum_congr rfl (fun n _ => hs n), sum_ite_one_eq, h3]
  have hfalse : predCount (fun n => (symFiber ({1} : Finset G) n).card) (fun _ => false) = 4 := by
    have hterm : ∀ n : G, Fintype.card G - (symFiber ({1} : Finset G) n).card
        = if n = 1 then 2 else 1 := by
      intro n
      rw [hs n, h3]
      split <;> rfl
    rw [predCount_false, Finset.sum_congr rfl (fun n _ => hterm n), sum_ite_one_eq, h3]
  have hbayes : predCount (fun n => (symFiber ({1} : Finset G) n).card)
      (fun n => decide (n ≠ 1)) = 6 := by
    have hterm : ∀ n : G,
        (if (decide (n ≠ 1) = true) then (symFiber ({1} : Finset G) n).card
          else Fintype.card G - (symFiber ({1} : Finset G) n).card) = (if n = 1 then 2 else 2) := by
      intro n
      by_cases hn : n = 1
      · rw [if_neg (by simp [hn]), hs n, h3, if_pos hn, if_pos hn]
      · rw [if_pos (by simp [hn]), hs n, if_neg hn, if_neg hn]
    simp only [predCount]
    rw [Finset.sum_congr rfl (fun n _ => hterm n), sum_ite_one_eq, h3]
  rw [htrue, hfalse, hbayes]
  norm_num

end Group

/-- Non-vacuity of the sharpness example: groups of order three exist. -/
theorem card_multiplicative_zmod_three : Fintype.card (Multiplicative (ZMod 3)) = 3 := by
  simp

/-- The sharpness example, instantiated: in the cyclic group of order three the Bayes
predictor strictly beats both constants. -/
theorem predCount_sym_beats_constants_zmod_three :
    max (predCount (fun n => (symFiber ({1} : Finset (Multiplicative (ZMod 3))) n).card)
          (fun _ => true))
        (predCount (fun n => (symFiber ({1} : Finset (Multiplicative (ZMod 3))) n).card)
          (fun _ => false))
      < predCount (fun n => (symFiber ({1} : Finset (Multiplicative (ZMod 3))) n).card)
          (fun n => decide (n ≠ 1)) :=
  predCount_sym_beats_constants_of_card_three card_multiplicative_zmod_three

/-- **The arithmetic conclusion.**  For every prime `l ≥ 5` the symmetric divisibility
event leaks strictly positive information about `N mod l` and yet no function of
`N mod l` predicts it better than the constant guess: the leak is real but inert. -/
theorem units_positive_information_zero_advantage (l : ℕ) [Fact (Nat.Prime l)] (hl : 5 ≤ l) :
    0 < miF (symJointG ({1} : Finset (ZMod l)ˣ)) ∧
      ∀ f : (ZMod l)ˣ → Bool,
        predCount (fun n => (symFiber ({1} : Finset (ZMod l)ˣ) n).card) f
          ≤ predCount (fun n => (symFiber ({1} : Finset (ZMod l)ˣ) n).card)
              (fun _ => false) := by
  have hcard : Fintype.card (ZMod l)ˣ = l - 1 := card_units_zmod l
  refine sym_singleton_positive_information_zero_advantage ?_
  omega

end SmoothSelfHint