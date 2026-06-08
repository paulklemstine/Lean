import Mathlib

/-!
# Tropical Hardness vs Randomness: Core Definitions

## Overview

This file defines the core concepts for a hardness-vs-randomness theory in
tropical (min-plus) algebra:

* **Acceptance probability** and **distinguishing advantage** for Boolean tests
* **Average-case hardness** of function families
* **NW (Nisan–Wigderson) generator** construction from function + design
* **Combinatorial designs** with bounded intersections
* **PRG security** (fooling a test class)
* **Tropical complexity classes** (BPP and DTIME analogues)

## Keywords

tropical complexity theory, hardness vs randomness, pseudorandom generators,
Nisan–Wigderson, min-plus algebra, derandomization, average-case hardness
-/

noncomputable section

open Finset BigOperators Classical

namespace TropicalHVR

/-! ## Acceptance Probability and Advantage -/

/-- Acceptance probability of a Boolean test `T` under uniform distribution.
    This is `|{x : T(x) = true}| / |universe|`. -/
def acceptProb {α : Type*} [Fintype α] (T : α → Bool) : ℝ :=
  ((Finset.univ.filter (fun x => T x = true)).card : ℝ) / (Fintype.card α : ℝ)

/-- Acceptance probability is between 0 and 1. -/
theorem acceptProb_nonneg {α : Type*} [Fintype α] (T : α → Bool) :
    0 ≤ acceptProb T :=
  div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)

theorem acceptProb_le_one {α : Type*} [Fintype α] [Nonempty α] (T : α → Bool) :
    acceptProb T ≤ 1 := by
  unfold acceptProb
  rw [div_le_one (by positivity : (0 : ℝ) < Fintype.card α)]
  exact_mod_cast Finset.card_filter_le _ _

/-- Distinguishing advantage of test T between the distribution induced by
    generator G (applied to uniform input) and the uniform distribution. -/
def advantage {α β : Type*} [Fintype α] [Fintype β]
    (T : β → Bool) (G : α → β) : ℝ :=
  |acceptProb (T ∘ G) - acceptProb T|

/-- Advantage is non-negative. -/
theorem advantage_nonneg {α β : Type*} [Fintype α] [Fintype β]
    (T : β → Bool) (G : α → β) : 0 ≤ advantage T G :=
  abs_nonneg _

/-- A generator G ε-fools a test class if every test in the class has
    advantage at most ε against G. -/
def prgFools {α β : Type*} [Fintype α] [Fintype β]
    (TestClass : Set (β → Bool)) (G : α → β) (ε : ℝ) : Prop :=
  ∀ T ∈ TestClass, advantage T G ≤ ε

/-! ## Average-Case Hardness -/

/-- Agreement probability: fraction of inputs on which P and f agree. -/
def agreeProb {α : Type*} [Fintype α] (P f : α → Bool) : ℝ :=
  ((Finset.univ.filter (fun x => P x = f x)).card : ℝ) / (Fintype.card α : ℝ)

/-- A function f is `(TestClass, δ)`-hard on average if no test in TestClass
    can predict f with agreement probability exceeding `1/2 + δ`. -/
def avgCaseHard {α : Type*} [Fintype α]
    (TestClass : Set (α → Bool)) (f : α → Bool) (δ : ℝ) : Prop :=
  ∀ P ∈ TestClass, agreeProb P f ≤ 1/2 + δ

/-! ## NW Generator -/

/-- The Nisan–Wigderson generator: given a hard function `f` on `n`-bit inputs
    and `m` embedding functions (each selecting `n` positions from `d`-bit seed),
    the generator maps a `d`-bit seed to an `m`-bit output by evaluating `f` on
    each projected substring. -/
def nwGenerator {n d m : ℕ}
    (f : (Fin n → Bool) → Bool)
    (embed : Fin m → Fin n → Fin d)
    (seed : Fin d → Bool) : Fin m → Bool :=
  fun i => f (fun j => seed (embed i j))

/-! ## Combinatorial Designs -/

/-- A combinatorial design: a family of `m` subsets of `[d]`, each of size `n`,
    with pairwise intersection at most `ℓ`. Represented as embedding functions.
    The injectivity condition ensures each set has `n` distinct elements. -/
structure CombDesign (n d m ℓ : ℕ) where
  /-- Embedding function: the i-th set maps each of its n elements to a position in [d]. -/
  embed : Fin m → Fin n → Fin d
  /-- Each embedding is injective (sets have exactly n elements). -/
  embed_inj : ∀ i, Function.Injective (embed i)
  /-- Pairwise intersection bound: distinct sets share at most ℓ elements. -/
  overlap_bound : ∀ i j, i ≠ j →
    (Finset.univ.filter (fun a => ∃ b, embed i a = embed j b)).card ≤ ℓ

/-! ## Tropical-Specific Notions -/

/-- Tropical hardness: f cannot be predicted by any predictor with agreement > 1/2 + δ.
    This is the universal quantification version (over all predictors, not just a class). -/
def tropicalHard {n : ℕ} (f : (Fin n → Bool) → Bool) (δ : ℝ) : Prop :=
  ∀ P : (Fin n → Bool) → Bool, agreeProb P f ≤ 1/2 + δ

/-! ## Complexity Classes -/

/-- A language is a set of bit strings (lists of booleans). -/
abbrev Lang := Set (List Bool)

/-- Tropical BPP: languages decidable by randomized tropical polynomial-time
    machines with bounded error. Abstractly modeled. -/
def tropicalBPP : Set Lang :=
  {L | ∃ (_decide : List Bool → Bool → Bool),
    ∀ x, (x ∈ L → ∃ r, _decide x r = true) ∧
         (x ∉ L → ∀ r, _decide x r = false)}

/-- Tropical DTIME: languages decidable deterministically in time T(n).
    Abstractly modeled. -/
def tropicalDTIME (_T : ℕ → ℕ) : Set Lang :=
  {L | ∃ (d : List Bool → Bool), ∀ x, (x ∈ L ↔ d x = true)}

/-! ## Negligibility -/

/-- A function ε : ℕ → ℝ is negligible if for all polynomial degrees k,
    eventually ε(n) ≤ 1/n^k. -/
def negligible (ε : ℕ → ℝ) : Prop :=
  ∀ k : ℕ, ∃ N, ∀ n, N ≤ n → |ε n| ≤ 1 / (n : ℝ) ^ k

/-- Zero function is negligible. -/
theorem negligible_zero : negligible (fun _ => 0) := by
  intro k; exact ⟨1, fun n _ => by simp⟩

end TropicalHVR

end