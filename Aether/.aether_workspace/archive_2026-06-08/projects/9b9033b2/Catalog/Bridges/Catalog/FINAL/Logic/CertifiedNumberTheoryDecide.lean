import Mathlib

/-!
# Certified Bounded Number-Theoretic Reflection

This file implements reflective checkers for bounded arithmetic propositions,
including divisibility testing and bounded existential search, with full
soundness and completeness proofs.

## Main Results

* `NatCheckDivisible_sound` — boolean divisibility checker is sound
* `NatCheckExistsUpTo_sound` — bounded existential checker is sound
* `NatCheckExistsUpTo_complete` — bounded existential checker is complete
* `number_theory_decide_factorial_plus_k` — k | n! + k for 2 ≤ k ≤ n
* `NatCheckDivisible_complete` — divisibility checker is complete
-/

/-! ## Divisibility Checker -/

/-- Boolean divisibility check: returns `true` iff `a ∣ b`.
    Convention: 0 ∣ 0 is true, 0 ∣ (b+1) is false. -/
def NatCheckDivisible (a b : ℕ) : Bool :=
  if a = 0 then b = 0 else b % a = 0

/-- Soundness: if the checker returns true, then `a ∣ b`. -/
theorem NatCheckDivisible_sound {a b : ℕ} :
    NatCheckDivisible a b = true → a ∣ b := by
  simp only [NatCheckDivisible]
  split
  · intro h; have := of_decide_eq_true h; subst this; rename_i ha; subst ha; exact dvd_zero 0
  · intro h; exact Nat.dvd_of_mod_eq_zero (of_decide_eq_true h)

/-
Completeness: if `a ∣ b` then the checker returns true.
-/
theorem NatCheckDivisible_complete {a b : ℕ} :
    a ∣ b → NatCheckDivisible a b = true := by
  -- By definition of NatCheckDivisible, we consider two cases: when a = 0 and when a ≠ 0.
  by_cases ha : a = 0;
  · unfold NatCheckDivisible; aesop;
  · -- Since a ≠ 0, we use the fact that if a ∣ b, then b % a = 0.
    intro h_div
    have h_mod : b % a = 0 := by
      exact Nat.mod_eq_zero_of_dvd h_div
    simp [NatCheckDivisible, ha, h_mod]

/-! ## Bounded Existential Checker -/

/-- Check whether there exists `n ≤ N` with `p n = true`.
    Implemented as a linear scan. -/
def NatCheckExistsUpTo (N : ℕ) (p : ℕ → Bool) : Bool :=
  (List.range (N + 1)).any p

/-
Soundness: if the checker returns true, there exists a witness.
-/
theorem NatCheckExistsUpTo_sound {N : ℕ} {p : ℕ → Bool} :
    NatCheckExistsUpTo N p = true → ∃ n, n ≤ N ∧ p n = true := by
  -- By definition of `NatCheckExistsUpTo`, if `NatCheckExistsUpTo N p = true`, then there exists an `n` in the list `List.range (N + 1)` such that `p n = true`.
  simp [NatCheckExistsUpTo]

/-
Completeness: if a witness exists, the checker returns true.
-/
theorem NatCheckExistsUpTo_complete {N : ℕ} {p : ℕ → Bool} :
    (∃ n, n ≤ N ∧ p n = true) → NatCheckExistsUpTo N p = true := by
  -- By definition of `NatCheckExistsUpTo`, if there exists `n ≤ N` such that `p n = true`, then `NatCheckExistsUpTo N p = true`.
  simp [NatCheckExistsUpTo]

/-! ## Bounded Universal Checker -/

/-- Check whether `p n = true` for all `n ≤ N`. -/
def NatCheckForallUpTo (N : ℕ) (p : ℕ → Bool) : Bool :=
  (List.range (N + 1)).all p

/-
Soundness of universal checker.
-/
theorem NatCheckForallUpTo_sound {N : ℕ} {p : ℕ → Bool} :
    NatCheckForallUpTo N p = true → ∀ n, n ≤ N → p n = true := by
  -- If `NatCheckForallUpTo N p` is `true`, then `∀ n ≤ N, p n` must hold. We can use the fact that `List.all` returns `true` if and only if the predicate holds for all elements in the list.
  simp [NatCheckForallUpTo, List.all]

/-
Completeness of universal checker.
-/
theorem NatCheckForallUpTo_complete {N : ℕ} {p : ℕ → Bool} :
    (∀ n, n ≤ N → p n = true) → NatCheckForallUpTo N p = true := by
  unfold NatCheckForallUpTo;
  simp +contextual [ List.range_succ_eq_map ]

/-! ## Application: Factorial Divisibility -/

/-- Key lemma: k divides n! when 2 ≤ k ≤ n. -/
theorem factorial_dvd_of_le {n k : ℕ} (hk2 : 2 ≤ k) (hkn : k ≤ n) :
    k ∣ Nat.factorial n :=
  Nat.dvd_factorial (by omega) hkn

/-- k ∣ (n! + k) when 2 ≤ k ≤ n.
    This connects to the catalog theorem `factorial_plus_k_divisible`. -/
theorem number_theory_decide_factorial_plus_k
    (n k : ℕ) (hk2 : 2 ≤ k) (hkn : k ≤ n) :
    k ∣ Nat.factorial n + k :=
  Nat.dvd_add (factorial_dvd_of_le hk2 hkn) (dvd_refl k)

/-- The divisibility checker confirms k | n! for concrete values. -/
theorem NatCheckDivisible_factorial_window
    (n k : ℕ) (hk2 : 2 ≤ k) (hkn : k ≤ n) :
    NatCheckDivisible k (Nat.factorial n) = true :=
  NatCheckDivisible_complete (factorial_dvd_of_le hk2 hkn)

/-! ## Reified Divisibility Predicates -/

/-- Reified syntax for bounded divisibility predicates. -/
inductive DivPred where
  | dvd : ℕ → ℕ → DivPred        -- a ∣ b
  | and : DivPred → DivPred → DivPred
  | or : DivPred → DivPred → DivPred
  deriving Repr, BEq

/-- Evaluate a divisibility predicate to a Prop. -/
def DivPred.toProp : DivPred → Prop
  | .dvd a b => a ∣ b
  | .and p q => p.toProp ∧ q.toProp
  | .or p q => p.toProp ∨ q.toProp

/-- Boolean checker for divisibility predicates. -/
def DivPred.check : DivPred → Bool
  | .dvd a b => NatCheckDivisible a b
  | .and p q => p.check && q.check
  | .or p q => p.check || q.check

/-
Soundness of the divisibility predicate checker.
-/
theorem DivPred.check_sound : ∀ p : DivPred, p.check = true → p.toProp := by
  intro p hp;
  -- We'll use induction on the structure of `p`.
  induction' p with p q hpq;
  · exact NatCheckDivisible_sound hp;
  · exact ⟨ by simpa using ‹hpq.check = true → hpq.toProp› ( by rw [ DivPred.check ] at hp; aesop ), by simpa using ‹ ( _ : DivPred ).check = true → ( _ : DivPred ).toProp› ( by rw [ DivPred.check ] at hp; aesop ) ⟩;
  · simp_all +decide [ DivPred.check ];
    exact hp.elim ( fun h => Or.inl <| by solve_by_elim ) fun h => Or.inr <| by solve_by_elim;

/-
Completeness of the divisibility predicate checker.
-/
theorem DivPred.check_complete : ∀ p : DivPred, p.toProp → p.check = true := by
  -- We'll use induction on the structure of `p`. The base case is when `p` is a simple divisibility statement `a ∣ b`.
  intro p
  induction' p with a b p q hp hq;
  · exact fun h => NatCheckDivisible_complete h;
  · grind +locals;
  · grind +locals

/-! ## Tactic: number_theory_decide -/

/-- The `number_theory_decide` tactic solves bounded arithmetic goals by
    reducing them to decidable computations. -/
macro "number_theory_decide" : tactic =>
  `(tactic| first
    | decide
    | native_decide
    | (simp only [Nat.dvd_iff_mod_eq_zero]; omega)
    | omega)

/-- Demo: 6 ∣ 720. -/
example : 6 ∣ 720 := by number_theory_decide

/-- Demo: 7 ∣ 5040 + 7. -/
example : 7 ∣ 5040 + 7 := by number_theory_decide

/-- Demo: existence of a divisor. -/
example : ∃ n, n ≤ 10 ∧ 3 ∣ n ∧ n > 0 :=
  ⟨3, by omega, ⟨1, by omega⟩, by omega⟩