/-
# Destructive verification: verdicts with a residual dish

A *verification* is usually modelled as a predicate: you hand a checker an object
and it says `true` or `false`.  That model silently assumes the object survives
the check.  Many real verification procedures do not have this property — a
destructive material test, a measurement that collapses the state, a one-shot
consumable certificate.

This file formalises verification as a **state transition**

  `t : D → Bool × D`,

a *test* on a type `D` of **dishes**, returning both a **verdict** `verdict t d`
and a **residual dish** `residue t d`.  The point of the model is that it lets
one *separate*, by theorems rather than by decree, three notions that the
predicate model conflates:

* `Nondestructive t` — the dish comes back untouched (`residue t d = d`);
* `Reversible t`     — the dish is transformed but nothing is lost
                       (`residue t` is a bijection);
* `Repeatable t`     — re-running the test on the residue gives the same verdict.

The main results are:

* `DestructiveVerification.Nondestructive.reversible`,
  `DestructiveVerification.Nondestructive.repeatable_iterate` — nondestructive
  tests sit at the bottom of the hierarchy: they are reversible and their
  verdict is invariant under arbitrarily many re-runs.
* `DestructiveVerification.reversible_not_nondestructive`,
  `DestructiveVerification.repeatable_not_reversible`,
  `DestructiveVerification.reversible_not_repeatable` — all three inclusions
  are **strict**, witnessed by explicit two-dish counterexamples.  So no
  implication beyond the proved ones holds.
* `DestructiveVerification.seq_assoc`, `seq_one`, `one_seq` — sequential
  composition (run one test, then the other on the residue, and conjoin the
  verdicts) is a monoid, and `nondestructive_seq` shows the nondestructive
  tests form a submonoid.
* `DestructiveVerification.seq_comm_of_nondestructive` versus
  `DestructiveVerification.seq_not_comm` — **certificates commute, destructive
  tests do not**.  This is the sharpest form of the separation: with
  nondestructive tests the order of a verification battery is irrelevant, and
  that fails as soon as one test is destructive.
* `DestructiveVerification.Repeatable.detects_invariant` — a repeatable test
  that decides a property `P` necessarily *preserves* `P`; destruction is
  constrained by repeatability even though it is not forbidden by it.
* `DestructiveVerification.card_tests`, `card_nondestructive`,
  `card_nondestructive_lt_card_tests` — a counting separation:
  there are `(2n)^n` tests on an `n`-dish type but only `2^n` certificates, so
  for `n ≥ 2` certificates are a strictly (indeed exponentially) small minority.

Nothing here assigns a hardness label to any of the three classes; the content
is purely the structural taxonomy and its strictness.
-/
import Mathlib

namespace DestructiveVerification

open Finset

variable {D : Type*}

/-! ## 1. Tests, verdicts, residues -/

/-- A **test** on a type of dishes `D`: it consumes a dish and returns a verdict
together with the residual dish. -/
abbrev Test (D : Type*) := D → Bool × D

/-- The verdict returned by a test. -/
def verdict (t : Test D) (d : D) : Bool := (t d).1

/-- The residual dish left over by a test. -/
def residue (t : Test D) (d : D) : D := (t d).2

lemma verdict_apply (t : Test D) (d : D) : verdict t d = (t d).1 := rfl
lemma residue_apply (t : Test D) (d : D) : residue t d = (t d).2 := rfl

lemma test_eq (t : Test D) (d : D) : t d = (verdict t d, residue t d) := rfl

/-- Two tests are equal exactly when they agree on verdicts and on residues. -/
lemma ext_test {t₁ t₂ : Test D} (hv : ∀ d, verdict t₁ d = verdict t₂ d)
    (hr : ∀ d, residue t₁ d = residue t₂ d) : t₁ = t₂ := by
  funext d
  rw [test_eq t₁ d, test_eq t₂ d, hv d, hr d]

/-! ## 2. The three classes -/

/-- A **nondestructive** test (a *certificate check*): the dish is returned
unchanged. -/
def Nondestructive (t : Test D) : Prop := ∀ d, residue t d = d

/-- A **reversible** test: the dish is transformed, but no information about it
is lost — the residue map is a bijection. -/
def Reversible (t : Test D) : Prop := Function.Bijective (residue t)

/-- A **repeatable** test: re-running the test on the residual dish reproduces
the verdict. -/
def Repeatable (t : Test D) : Prop := ∀ d, verdict t (residue t d) = verdict t d

/-- A **destructive** test is one that is not nondestructive. -/
def Destructive (t : Test D) : Prop := ¬ Nondestructive t

/-- `t` **decides** the property `P` on dishes: its verdict is `true` exactly on
dishes satisfying `P`. -/
def Detects (t : Test D) (P : D → Prop) : Prop := ∀ d, verdict t d = true ↔ P d

/-! ## 3. The proved implications -/

theorem Nondestructive.reversible {t : Test D} (h : Nondestructive t) :
    Reversible t := by
  have hid : residue t = id := funext h
  show Function.Bijective (residue t)
  rw [hid]
  exact Function.bijective_id

theorem Nondestructive.repeatable {t : Test D} (h : Nondestructive t) :
    Repeatable t := by
  intro d; rw [h d]

/-- The genuinely stronger statement for certificates: the verdict survives
*any* number of re-runs, not just one. -/
theorem Nondestructive.repeatable_iterate {t : Test D} (h : Nondestructive t)
    (k : ℕ) (d : D) : verdict t ((residue t)^[k] d) = verdict t d := by
  induction k with
  | zero => rfl
  | succ n ih =>
      rw [Function.iterate_succ_apply, h d]
      exact ih

/-- Under repeatability, the whole verdict stream is constant along the orbit. -/
theorem Repeatable.iterate {t : Test D} (h : Repeatable t) (k : ℕ) (d : D) :
    verdict t ((residue t)^[k] d) = verdict t d := by
  induction k generalizing d with
  | zero => rfl
  | succ n ih =>
      rw [Function.iterate_succ_apply']
      exact (h _).trans (ih d)

/-- A repeatable test that decides `P` cannot destroy `P`: the property it
checks is invariant along the residue map.  Destruction is thus *constrained*
by repeatability, even though repeatability does not forbid it. -/
theorem Repeatable.detects_invariant {t : Test D} {P : D → Prop}
    (hrep : Repeatable t) (hdet : Detects t P) (d : D) :
    P (residue t d) ↔ P d := by
  rw [← hdet, ← hdet, hrep d]

/-- Nondestructive tests preserve *every* property, not just the one they
decide. -/
theorem Nondestructive.preserves {t : Test D} (h : Nondestructive t)
    (P : D → Prop) (d : D) : P (residue t d) ↔ P d := by rw [h d]

/-! ## 4. Strictness of the hierarchy: two-dish counterexamples -/

/-- The **flip** test on `Bool`-dishes: always accepts, but swaps the dish.
Reversible and repeatable, yet destructive. -/
def flipTest : Test Bool := fun d => (true, !d)

/-- The **read-and-flip** test: reports the dish and swaps it.  Reversible,
destructive, and *not* repeatable — the second run contradicts the first. -/
def readFlipTest : Test Bool := fun d => (d, !d)

/-- The **burn** test: always accepts and reduces every dish to `false`.
Repeatable and destructive, but not reversible: the dish is irrecoverable. -/
def burnTest : Test Bool := fun _ => (true, false)

theorem flipTest_destructive : Destructive flipTest := by
  intro h; simpa [flipTest, residue] using h true

theorem flipTest_reversible : Reversible flipTest := by
  constructor
  · intro a b hab; simpa [flipTest, residue] using hab
  · intro b; exact ⟨!b, by simp [flipTest, residue]⟩

theorem flipTest_repeatable : Repeatable flipTest := by
  intro d; rfl

/-- Reversibility does **not** imply nondestructiveness. -/
theorem reversible_not_nondestructive :
    ∃ t : Test Bool, Reversible t ∧ Destructive t :=
  ⟨flipTest, flipTest_reversible, flipTest_destructive⟩

theorem burnTest_repeatable : Repeatable burnTest := by intro d; rfl

theorem burnTest_not_reversible : ¬ Reversible burnTest := by
  intro h
  have := h.1 (a₁ := true) (a₂ := false) (by simp [burnTest, residue])
  simp at this

/-- Repeatability does **not** imply reversibility: a test may be repeatable
precisely because it always destroys the dish in the same way. -/
theorem repeatable_not_reversible :
    ∃ t : Test Bool, Repeatable t ∧ ¬ Reversible t ∧ Destructive t := by
  refine ⟨burnTest, burnTest_repeatable, burnTest_not_reversible, ?_⟩
  intro h; simpa [burnTest, residue] using h true

/-- Reversibility does **not** imply repeatability: no information is lost, yet
the verdict is not reproducible. -/
theorem reversible_not_repeatable :
    ∃ t : Test Bool, Reversible t ∧ ¬ Repeatable t := by
  refine ⟨readFlipTest, ⟨?_, ?_⟩, ?_⟩
  · intro a b hab; simpa [readFlipTest, residue] using hab
  · intro b; exact ⟨!b, by simp [readFlipTest, residue]⟩
  · intro h; simpa [readFlipTest, verdict, residue] using h true

/-- Summary of the taxonomy on a two-element dish type: the three classes are
pairwise distinct, and neither `Reversible` nor `Repeatable` implies the other
or is implied by the other. -/
theorem taxonomy_strict :
    (∃ t : Test Bool, Reversible t ∧ ¬ Repeatable t) ∧
    (∃ t : Test Bool, Repeatable t ∧ ¬ Reversible t) ∧
    (∃ t : Test Bool, Reversible t ∧ Repeatable t ∧ ¬ Nondestructive t) :=
  ⟨reversible_not_repeatable,
   ⟨burnTest, burnTest_repeatable, burnTest_not_reversible⟩,
   ⟨flipTest, flipTest_reversible, flipTest_repeatable, flipTest_destructive⟩⟩

/-! ## 5. Sequential composition: the verification monoid -/

/-- Run `t₁`, then run `t₂` on the residual dish; the verdict is the conjunction
of the two verdicts. -/
def seq (t₁ t₂ : Test D) : Test D :=
  fun d => (verdict t₁ d && verdict t₂ (residue t₁ d), residue t₂ (residue t₁ d))

/-- The trivial certificate: accepts everything and touches nothing. -/
def one (D : Type*) : Test D := fun d => (true, d)

@[simp] lemma verdict_seq (t₁ t₂ : Test D) (d : D) :
    verdict (seq t₁ t₂) d = (verdict t₁ d && verdict t₂ (residue t₁ d)) := rfl

@[simp] lemma residue_seq (t₁ t₂ : Test D) (d : D) :
    residue (seq t₁ t₂) d = residue t₂ (residue t₁ d) := rfl

@[simp] lemma verdict_one (d : D) : verdict (one D) d = true := rfl
@[simp] lemma residue_one (d : D) : residue (one D) d = d := rfl

theorem one_nondestructive : Nondestructive (one D) := fun _ => rfl

theorem seq_assoc (t₁ t₂ t₃ : Test D) : seq (seq t₁ t₂) t₃ = seq t₁ (seq t₂ t₃) := by
  refine ext_test (fun d => ?_) (fun d => ?_)
  · simp [Bool.and_assoc]
  · simp

theorem one_seq (t : Test D) : seq (one D) t = t :=
  ext_test (fun d => by simp) (fun d => by simp)

theorem seq_one (t : Test D) : seq t (one D) = t :=
  ext_test (fun d => by simp) (fun d => by simp)

/-- Certificates are closed under composition: they form a submonoid of the
verification monoid. -/
theorem nondestructive_seq {t₁ t₂ : Test D} (h₁ : Nondestructive t₁)
    (h₂ : Nondestructive t₂) : Nondestructive (seq t₁ t₂) := by
  intro d; simp [h₁ d, h₂ d]

/-- Reversible tests are closed under composition as well. -/
theorem reversible_seq {t₁ t₂ : Test D} (h₁ : Reversible t₁) (h₂ : Reversible t₂) :
    Reversible (seq t₁ t₂) := by
  have hcomp : residue (seq t₁ t₂) = residue t₂ ∘ residue t₁ := funext fun _ => rfl
  show Function.Bijective (residue (seq t₁ t₂))
  rw [hcomp]
  exact h₂.comp h₁

/-- **Certificates commute.**  A battery of nondestructive tests may be run in
any order: both the verdict and the residual dish are order-independent. -/
theorem seq_comm_of_nondestructive {t₁ t₂ : Test D} (h₁ : Nondestructive t₁)
    (h₂ : Nondestructive t₂) : seq t₁ t₂ = seq t₂ t₁ := by
  refine ext_test (fun d => ?_) (fun d => ?_)
  · simp [h₁ d, h₂ d, Bool.and_comm]
  · simp [h₁ d, h₂ d]

/-- **Destructive tests do not commute.**  One destructive participant is enough
to make the order of a two-test battery observable in the verdict. -/
theorem seq_not_comm :
    ∃ t₁ t₂ : Test Bool, Nondestructive t₁ ∧ Destructive t₂ ∧ seq t₁ t₂ ≠ seq t₂ t₁ := by
  refine ⟨fun d => (d, d), burnTest, fun d => rfl, ?_, ?_⟩
  · intro h; simpa [burnTest, residue] using h true
  · intro h
    have := congrArg (fun t => verdict t true) h
    simp [seq, burnTest, verdict, residue] at this

/-- A quantitative face of the same phenomenon: with a destructive test in the
battery, the verdict genuinely depends on the ordering, so a battery of `n`
tests can have up to `n!` distinct behaviours; with certificates it has one.
Here is the two-test instance stated as an inequality of verdict functions. -/
theorem verdict_order_dependent :
    verdict (seq (fun d : Bool => (d, d)) burnTest) ≠
      verdict (seq burnTest (fun d : Bool => (d, d))) := by
  intro h
  have := congrFun h true
  simp [seq, burnTest, verdict, residue] at this

/-! ## 6. Counting: certificates are exponentially rare -/

variable (D)

/-- There are `(2n)^n` tests on an `n`-element type of dishes. -/
theorem card_tests [Fintype D] [DecidableEq D] :
    Fintype.card (Test D) = (2 * Fintype.card D) ^ Fintype.card D := by
  simp

/-- Certificates are exactly the `2^n` verdict functions: a nondestructive test
is precisely a predicate on dishes. -/
def nondestructiveEquiv : {t : Test D // Nondestructive t} ≃ (D → Bool) where
  toFun t := fun d => verdict t.1 d
  invFun f := ⟨fun d => (f d, d), fun _ => rfl⟩
  left_inv := by
    rintro ⟨t, ht⟩
    apply Subtype.ext
    exact ext_test (fun d => rfl) (fun d => (ht d).symm)
  right_inv := by intro f; rfl

theorem card_nondestructive [Finite D] :
    Nat.card {t : Test D // Nondestructive t} = 2 ^ Nat.card D := by
  rw [Nat.card_congr (nondestructiveEquiv D)]
  simp [Nat.card_fun]

/-- Reversible tests are exactly a verdict function together with a permutation
of the dishes. -/
noncomputable def reversibleEquiv : {t : Test D // Reversible t} ≃ (D → Bool) × Equiv.Perm D where
  toFun t := (fun d => verdict t.1 d, Equiv.ofBijective (residue t.1) t.2)
  invFun fs := ⟨fun d => (fs.1 d, fs.2 d), fs.2.bijective⟩
  left_inv := by
    rintro ⟨t, ht⟩
    exact Subtype.ext (ext_test (fun d => rfl) (fun d => rfl))
  right_inv := by
    rintro ⟨f, σ⟩
    exact Prod.ext rfl (Equiv.ext fun d => rfl)

/-- There are `2^n * n!` reversible tests on `n` dishes: a verdict pattern and a
permutation.  Compare `card_nondestructive`: the certificates are the `n! = 1`
slice where the permutation is trivial. -/
theorem card_reversible [Fintype D] [DecidableEq D] :
    Nat.card {t : Test D // Reversible t} = 2 ^ Fintype.card D * Nat.factorial (Fintype.card D) := by
  rw [Nat.card_congr (reversibleEquiv D)]
  simp [Nat.card_eq_fintype_card, Fintype.card_perm]

/-- From two dishes on, certificates are a strict minority — indeed the ratio
`(2n)^n / 2^n = n^n` blows up. -/
theorem card_nondestructive_lt_card_tests [Fintype D] (h : 2 ≤ Fintype.card D) :
    2 ^ Fintype.card D < (2 * Fintype.card D) ^ Fintype.card D := by
  exact Nat.pow_lt_pow_left (by omega) (by omega)

end DestructiveVerification