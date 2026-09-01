/-
# The spine *is* the unit group: complete solution of `x² - 2y² = ±1`

`Novelty.PellSpinePythagorean` classified the *negative* Pell equation `x² + 1 = 2y²`
(odd indices).  This file does the *positive* one, `x² = 2y² + 1` (even indices), and glues
the two into a single statement:

> the pairs `(x, y)` of naturals with `|x² - 2y²| = 1` are **exactly** the points
> `(Q n, P n)` of the Pell spine — i.e. the totally positive units of `ℤ[√2]`.

## Proved

* `posPell_iff` — `x² = 2y² + 1 ↔ (x,y) = (Q (2k), P (2k))` for some `k`, by the same Vieta
  descent `(x,y) ↦ (3x - 4y, 3y - 2x)`, now with the *even* base point `(1,0)`;
* `pell_unit_classification` — the capstone: `x² = 2y² + 1 ∨ x² + 1 = 2y²` iff `(x,y)` is on
  the spine.  Parity of the index is exactly the sign of the norm;
* `norm_three_impossible` — no unit-like solution of `x² = 2y² + 3`: a genuine local
  obstruction, visible modulo `8`.

## Refuted

* `not_only_norm_one` — the guess "the form `x² - 2y²` takes no value other than `±1` on the
  spine's neighbourhood" is false: `3² - 2·1² = 7`.  Together with `norm_three_impossible`
  this shows the represented norms are governed by *quadratic residues mod 8*, not by size.
-/
import Novelty.PellSpinePythagorean

namespace Catalog.Novelty.PellSpine

/-! ## The positive Pell equation -/

/-- Even-index spine points solve `x² = 2y² + 1`. -/
theorem posPell_of_even_index (k : ℕ) :
    pellQ (2 * k) ^ 2 = 2 * pellP (2 * k) ^ 2 + 1 := by
  have h := pell_equation (2 * k)
  have heven : ((-1 : ℤ)) ^ (2 * k) = 1 := by
    rw [pow_mul]; norm_num
  rw [heven] at h
  have : ((pellQ (2 * k) ^ 2 : ℕ) : ℤ) = ((2 * pellP (2 * k) ^ 2 + 1 : ℕ) : ℤ) := by
    push_cast
    linarith
  exact_mod_cast this

/-- **Vieta descent for the positive Pell equation.** -/
theorem posPell_descent : ∀ y x : ℕ, x ^ 2 = 2 * y ^ 2 + 1 →
    ∃ k, x = pellQ (2 * k) ∧ y = pellP (2 * k) := by
  intro y
  induction y using Nat.strong_induction_on with
  | _ y ih =>
    intro x hxy
    match y, hxy with
    | 0, hxy =>
        have hx : x ≤ 1 := by nlinarith
        interval_cases x
        · simp at hxy
        · exact ⟨0, by norm_num, by norm_num⟩
    | 1, hxy =>
        exfalso
        have hx : x ≤ 1 := by nlinarith
        interval_cases x <;> omega
    | (y + 2), hxy =>
        set Y := y + 2 with hY
        have hy2 : 2 ≤ Y := by omega
        have hxgt : Y < x := by nlinarith
        have h4 : 4 * Y ≤ 3 * x := by nlinarith
        have h2 : 2 * x ≤ 3 * Y := by nlinarith
        obtain ⟨x', hx'⟩ : ∃ x', 3 * x = 4 * Y + x' := ⟨3 * x - 4 * Y, by omega⟩
        obtain ⟨y', hy'⟩ : ∃ y', 3 * Y = 2 * x + y' := ⟨3 * Y - 2 * x, by omega⟩
        have hZ : (x' : ℤ) ^ 2 = 2 * (y' : ℤ) ^ 2 + 1 := by
          have e1' : (3 : ℤ) * (x : ℤ) = 4 * (Y : ℤ) + (x' : ℤ) := by exact_mod_cast hx'
          have e2' : (3 : ℤ) * (Y : ℤ) = 2 * (x : ℤ) + (y' : ℤ) := by exact_mod_cast hy'
          have e3 : (x : ℤ) ^ 2 = 2 * (Y : ℤ) ^ 2 + 1 := by exact_mod_cast hxy
          have e1 : (x' : ℤ) = 3 * (x : ℤ) - 4 * (Y : ℤ) := by linarith
          have e2 : (y' : ℤ) = 3 * (Y : ℤ) - 2 * (x : ℤ) := by linarith
          rw [e1, e2]; linear_combination e3
        have hN : x' ^ 2 = 2 * y' ^ 2 + 1 := by exact_mod_cast hZ
        have hlt : y' < Y := by omega
        obtain ⟨k, hk1, hk2⟩ := ih y' hlt x' hN
        refine ⟨k + 1, ?_, ?_⟩
        · have hq : pellQ (2 * (k + 1)) = 3 * pellQ (2 * k) + 4 * pellP (2 * k) := by
            have h : 2 * (k + 1) = 2 * k + 2 := by ring
            rw [h, pellQ_add_two']
          rw [hq, ← hk1, ← hk2]
          omega
        · have hp : pellP (2 * (k + 1)) = 2 * pellQ (2 * k) + 3 * pellP (2 * k) := by
            have h : 2 * (k + 1) = 2 * k + 2 := by ring
            rw [h, pellP_add_two']
          rw [hp, ← hk1, ← hk2]
          omega

/-- **Classification of the positive Pell equation over `ℕ`.** -/
theorem posPell_iff (x y : ℕ) :
    x ^ 2 = 2 * y ^ 2 + 1 ↔ ∃ k, x = pellQ (2 * k) ∧ y = pellP (2 * k) := by
  refine ⟨posPell_descent y x, ?_⟩
  rintro ⟨k, rfl, rfl⟩
  exact posPell_of_even_index k

/-! ## The capstone: the spine is the positive unit group -/

/-- **The Pell spine is exactly the set of totally positive units of `ℤ[√2]`.**
Sign of the norm = parity of the index. -/
theorem pell_unit_classification (x y : ℕ) :
    (x ^ 2 = 2 * y ^ 2 + 1 ∨ x ^ 2 + 1 = 2 * y ^ 2) ↔ ∃ n, x = pellQ n ∧ y = pellP n := by
  constructor
  · rintro (h | h)
    · obtain ⟨k, hk1, hk2⟩ := (posPell_iff x y).mp h
      exact ⟨2 * k, hk1, hk2⟩
    · obtain ⟨k, hk1, hk2⟩ := (negPell_iff x y).mp h
      exact ⟨2 * k + 1, hk1, hk2⟩
  · rintro ⟨n, rfl, rfl⟩
    rcases Nat.even_or_odd n with ⟨k, hk⟩ | ⟨k, hk⟩
    · left
      have : n = 2 * k := by omega
      subst this
      exact posPell_of_even_index k
    · right
      have : n = 2 * k + 1 := by omega
      subst this
      exact negPell_of_odd_index k

/-! ## Which norms occur: a local obstruction and its failure -/

/-- `x² = 2y² + 3` has no solutions: modulo `8` the form `x² - 2y²` misses the class `3`. -/
theorem norm_three_impossible : ¬ ∃ x y : ℕ, x ^ 2 = 2 * y ^ 2 + 3 := by
  rintro ⟨x, y, h⟩
  have h8 : ((x : ZMod 8)) ^ 2 = 2 * ((y : ZMod 8)) ^ 2 + 3 := by
    have := congrArg (Nat.cast : ℕ → ZMod 8) h
    push_cast at this
    exact this
  revert h8
  generalize ((x : ZMod 8)) = a
  generalize ((y : ZMod 8)) = b
  revert a b
  decide

/-- **Refutation.**  "Only `±1` is represented by `x² - 2y²` near the spine" is false:
`3² - 2·1² = 7`.  So the represented norms are cut out by congruence conditions
(`norm_three_impossible`), not by an inequality. -/
theorem not_only_norm_one :
    ¬ ∀ c : ℕ, (∃ x y : ℕ, x ^ 2 = 2 * y ^ 2 + c) → c = 1 := by
  intro h
  have := h 7 ⟨3, 1, by norm_num⟩
  norm_num at this

end Catalog.Novelty.PellSpine