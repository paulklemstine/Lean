import Mathlib

/-!
# The L-function universe, part II: the periodic/arithmetic universe is countable

The Dirichlet L-functions — the L-functions attached to Dirichlet characters — have
coefficient sequences `a(k) = χ(k)` that are **periodic** (period dividing the
conductor) and take values in a **countable** set (roots of unity, together with
`0`).  This is the arithmetic constraint that tames the otherwise uncountable
universe of Dirichlet series studied in `NaiveUniverse.lean`.

The main abstract result of this file is:

* `periodicSeq_countable`: for any *countable* value type `V`, the set of periodic
  sequences `ℕ → V` is countable.

The intuition ("a periodic sequence is determined by a finite block of data") is
made precise via the surjection sending the finite data `(period, one full block of
values)` to the corresponding periodic sequence.

We then apply the countable-value idea to the genuine number-theoretic object: the
family of all Dirichlet characters (over all moduli) is countable, so there are only
countably many Dirichlet L-functions.
-/

open scoped Classical

namespace LFunctionUniverse

/-- A sequence `a : ℕ → V` is *periodic* if it has some strictly positive period. -/
def IsPeriodicSeq {V : Type*} (a : ℕ → V) : Prop :=
  ∃ n : ℕ, 0 < n ∧ Function.Periodic a n

/-- **Periodic sequences over a countable alphabet form a countable set.**

A periodic sequence is determined by its period `n` and the finite block of values
`Fin n → V`; there are only countably many such finite data, so only countably many
periodic sequences.  This is the mechanism by which the arithmetic constraint of
periodicity collapses an *a priori* continuum-sized family of Dirichlet series to a
countable one. -/
theorem periodicSeq_countable {V : Type*} [Countable V] :
    {a : ℕ → V | IsPeriodicSeq a}.Countable := by
  -- the "finite data" `(period − 1, one block of values)` lives in a countable type
  let g : (Σ n : ℕ, Fin (n + 1) → V) → (ℕ → V) :=
    fun p k => p.2 ⟨k % (p.1 + 1), Nat.mod_lt _ (Nat.succ_pos _)⟩
  have hsub : {a : ℕ → V | IsPeriodicSeq a} ⊆ Set.range g := by
    rintro a ⟨n, hn, hper⟩
    obtain ⟨m, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hn.ne'
    refine ⟨⟨m, fun i => a i⟩, ?_⟩
    funext k
    simp only [g]
    rw [hper.map_mod_nat k]
  exact (Set.countable_range g).mono hsub

/-- Instantiation: rational-valued periodic sequences form a countable set.
(These model, e.g., the coefficient sequences of real Dirichlet characters and of
`ζ`, whose coefficients are the constant sequence `1`.) -/
theorem periodicSeq_rat_countable :
    {a : ℕ → ℚ | IsPeriodicSeq a}.Countable :=
  periodicSeq_countable

/-- Instantiation: integer-valued periodic sequences form a countable set. -/
theorem periodicSeq_int_countable :
    {a : ℕ → ℤ | IsPeriodicSeq a}.Countable :=
  periodicSeq_countable

/-- The coefficient sequence `k ↦ χ(k)` of a Dirichlet character `χ` modulo `n`. -/
noncomputable def charCoeff {n : ℕ} (χ : DirichletCharacter ℂ n) : ℕ → ℂ :=
  fun k => χ (k : ZMod n)

/-- The coefficient sequence of a Dirichlet character modulo `n` is periodic with
period `n` (this is the multiplicative periodicity `χ(k + n) = χ(k)`). -/
theorem charCoeff_periodic {n : ℕ} (χ : DirichletCharacter ℂ n) :
    Function.Periodic (charCoeff χ) n := by
  intro k
  simp only [charCoeff]
  push_cast
  rw [ZMod.natCast_self, add_zero]

/-- For a positive modulus, the coefficient sequence of a Dirichlet character is a
genuinely periodic sequence in the sense of `IsPeriodicSeq`. -/
theorem charCoeff_isPeriodic {n : ℕ} (hn : 0 < n) (χ : DirichletCharacter ℂ n) :
    IsPeriodicSeq (charCoeff χ) :=
  ⟨n, hn, charCoeff_periodic χ⟩

/-- **The family of all Dirichlet characters (over all moduli) is countable.**

For each fixed modulus `n` there are only finitely many Dirichlet characters
modulo `n`, and the moduli are indexed by `ℕ`; a countable union of finite sets is
countable. -/
theorem dirichletCharFamily_countable :
    Countable (Σ n : ℕ, DirichletCharacter ℂ n) := inferInstance

/-- **There are only countably many Dirichlet L-functions.**

The coefficient sequences of Dirichlet characters form a countable subset of the
(uncountable) space of all Dirichlet series `ℕ → ℂ`: they are the image of the
countable family of all Dirichlet characters. -/
theorem dirichletLCoeff_countable :
    {a : ℕ → ℂ | ∃ (n : ℕ) (χ : DirichletCharacter ℂ n), a = charCoeff χ}.Countable := by
  have h : {a : ℕ → ℂ | ∃ (n : ℕ) (χ : DirichletCharacter ℂ n), a = charCoeff χ}
      = Set.range (fun p : Σ n : ℕ, DirichletCharacter ℂ n => charCoeff p.2) := by
    ext a
    constructor
    · rintro ⟨n, χ, rfl⟩; exact ⟨⟨n, χ⟩, rfl⟩
    · rintro ⟨⟨n, χ⟩, rfl⟩; exact ⟨n, χ, rfl⟩
  rw [h]
  exact Set.countable_range _

end LFunctionUniverse