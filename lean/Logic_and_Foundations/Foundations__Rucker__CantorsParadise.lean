/-
# Cantor's Paradise: Formalizing the Hierarchy of Infinities

Rudy Rucker's "Infinity and the Mind" (1982) is a landmark exploration of
transfinite mathematics. Rucker, a mathematician and novelist, brought Cantor's
paradise to life for a broad audience. This module formalizes key results from
Cantor's theory of transfinite numbers that form the backbone of Rucker's
mathematical philosophy.

## Key Themes from Rucker:
- "The Absolute Infinite is unknowable" — but we can still reason about
  ever-larger infinities.
- The diagonal argument is "the most beautiful proof in mathematics."
- There is no "biggest" infinity — the power set always produces something larger.
-/

import Mathlib

open Cardinal

namespace CantorsParadise

/-! ## Cantor's Theorem: The Power Set is Always Strictly Larger

Rucker emphasizes that Cantor's 1891 diagonal argument is one of the most
profound discoveries in mathematics. It shows that for ANY set S, the collection
of all subsets of S (its power set) is strictly larger than S itself.

This is the engine that generates the infinite hierarchy of infinities:
ℵ₀ < 2^ℵ₀ < 2^(2^ℵ₀) < ...
-/

/-- Cantor's theorem: there is no surjection from a type to its power set.
This is the formal core of Rucker's "ever-ascending tower of infinities." -/
theorem cantor_no_surjection (α : Type*) :
    ¬ ∃ f : α → Set α, Function.Surjective f := by
  intro ⟨f, hf⟩
  set D := {x : α | x ∉ f x} with hD_def
  obtain ⟨a, ha⟩ := hf D
  replace ha := Set.ext_iff.mp ha a
  aesop

/-- The diagonal set used in Cantor's proof: the set of all elements
that are NOT in their own image. This is the formal "Cantorian diagonal"
that Rucker describes as the key to understanding infinity. -/
def cantor_diagonal (f : α → Set α) : Set α :=
  {x | x ∉ f x}

/-- The diagonal set is never in the range of f. -/
theorem cantor_diagonal_not_in_range (f : α → Set α) :
    ∀ a : α, f a ≠ cantor_diagonal f := by
  intro a ha
  have := congr_arg (fun s => a ∈ s) ha
  simp +decide at this
  unfold cantor_diagonal at this
  tauto

/-! ## The Hierarchy of Cardinals

Rucker describes how Cantor discovered an endless ascending chain of
infinities. We formalize this using Mathlib's cardinal arithmetic. -/

/-- The natural numbers are countably infinite. -/
theorem nat_is_aleph_zero : Cardinal.mk ℕ = ℵ₀ :=
  Cardinal.mk_nat

/-- The power set of the naturals is strictly larger than the naturals.
This is the formal statement of the uncountability of the continuum,
which Rucker calls "Cantor's most stunning result." -/
theorem power_set_nat_gt_nat :
    Cardinal.mk ℕ < Cardinal.mk (Set ℕ) := by
  simp +zetaDelta at *
  exact Cardinal.aleph0_lt_continuum

/-- For any cardinal κ, we have κ < 2^κ.
The engine of Rucker's "endless tower of infinities." -/
theorem cardinal_lt_power (κ : Cardinal) : κ < 2 ^ κ :=
  Cardinal.cantor κ

/-! ## The Schröder–Bernstein Theorem

Rucker discusses how comparing infinite sets requires care. The
Schröder–Bernstein theorem tells us that if A injects into B and
B injects into A, then A and B have the same cardinality. -/

/-- Schröder–Bernstein: mutual injection implies bijection. -/
theorem schroder_bernstein {α β : Type*}
    (f : α → β) (g : β → α)
    (hf : Function.Injective f) (hg : Function.Injective g) :
    ∃ h : α → β, Function.Bijective h :=
  Function.Embedding.schroeder_bernstein hf hg

/-! ## Countability and Uncountability

Central to Rucker's exposition is the distinction between countable and
uncountable infinities. -/

/-- The integers are countable (same size as the naturals). -/
theorem int_countable : Cardinal.mk ℤ = ℵ₀ :=
  Cardinal.mk_int

/-- The rationals are countable — one of Cantor's surprising results
that Rucker emphasizes as deeply counterintuitive. -/
theorem rat_countable : Cardinal.mk ℚ = ℵ₀ :=
  Cardinal.mkRat

/-- The reals are uncountable — Cantor's most famous theorem,
and the centerpiece of Rucker's Chapter 2. -/
theorem real_uncountable : ℵ₀ < Cardinal.mk ℝ := by
  rw [Cardinal.mk_real]; exact Cardinal.cantor _

end CantorsParadise
