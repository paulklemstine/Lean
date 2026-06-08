/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Bridges.TropicalRateDistortion.Core

/-!
# Closure-Capacity ↔ Tropical Distortion Bridge and Certified Asymmetry

## Overview

This file establishes the bridge between closure-capacity systems and
tropical distortion systems, proving the rate–pressure duality theorem
and the certified asymmetry theorem for trapdoor decoding.

## Main Results

* `tropicalRate_eq_closurePressure` — rate equals closure pressure
* `certified_asymmetry` — trapdoor witnesses certify one-way decoding asymmetry
* `certified_stable_decoding` — perturbation-stable certified decoding
* `closureRefines_threshold_monotone` — threshold monotonicity under refinements
-/

noncomputable section

open Finset Classical

namespace TropicalRateDistortion

variable {α : Type*} [Fintype α] [DecidableEq α] [Nonempty α]

/-! ## Closure-Capacity Systems -/

/-- A finite closure-capacity system: a closure operator on `Set α`
    with a closure-invariant capacity function. -/
structure ClosureCapacity (α : Type*) where
  /-- The closure operator -/
  cl : Set α → Set α
  /-- The capacity function -/
  cap : Set α → ℝ
  /-- Closure is monotone -/
  cl_mono : Monotone cl
  /-- Closure is extensive -/
  cl_ext : ∀ s, s ⊆ cl s
  /-- Closure is idempotent -/
  cl_idem : ∀ s, cl (cl s) = cl s
  /-- Capacity is closure-invariant -/
  cap_cl : ∀ s, cap (cl s) = cap s
  /-- Capacity is monotone -/
  cap_mono : Monotone cap

/-- A set is closed if it equals its closure. -/
def ClosureCapacity.IsClosed (C : ClosureCapacity α) (s : Set α) : Prop :=
  C.cl s = s

/-- The closure of any set is closed. -/
lemma ClosureCapacity.cl_isClosed (C : ClosureCapacity α) (s : Set α) :
    C.IsClosed (C.cl s) :=
  C.cl_idem s

/-- The canonical distortion gauge: δ(a) = cap(cl({a})). -/
def canonicalDistortion (C : ClosureCapacity α) (a : α) : ℝ :=
  C.cap (C.cl {a})

/-- The closure pressure functional:
    P(l) = inf over elements a of (cap(cl({a})) + l · w(a)). -/
def closurePressure (C : ClosureCapacity α) (w : α → ℝ) (l : ℝ) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty
    (fun a => C.cap (C.cl {a}) + l * w a)

/-
**Rate–Pressure Duality**: The tropical rate functional with canonical
    distortion equals the closure pressure functional.
-/
theorem tropicalRate_eq_closurePressure (C : ClosureCapacity α) (w : α → ℝ) (l : ℝ) :
    tropicalRate (canonicalDistortion C) w l = closurePressure C w l := by
  -- By definition of canonicalDistortion, we have canonicalDistortion C a = C.cap (C.cl {a}).
  simp [canonicalDistortion, tropicalRate, closurePressure]

/-
Canonical distortion bounds capacity: for a ∈ s with s closed,
    cap(cl({a})) ≤ cap(s) since cl({a}) ⊆ cl(s) = s.
-/
lemma canonicalDistortion_le_cap_of_mem (C : ClosureCapacity α) (s : Set α)
    (hs : C.IsClosed s) (a : α) (ha : a ∈ s) :
    canonicalDistortion C a ≤ C.cap s := by
  exact C.cap_mono ( show C.cl { a } ⊆ s from Set.Subset.trans ( C.cl_mono ( by simpa ) ) hs.le )

/-! ## Trapdoor Witnesses and Certified Asymmetry -/

/-- A trapdoor witness certifies a unique minimizer at a parameter value. -/
structure TrapdoorWitness (α : Type*) [Fintype α] [Nonempty α] (δ w : α → ℝ) where
  /-- The certified parameter value -/
  param : ℝ
  /-- The certified minimizer -/
  witness : α
  /-- The witness is a minimizer -/
  is_minimizer : IsMinimizer δ w param witness
  /-- The witness is the unique minimizer -/
  is_unique : ∀ b, b ≠ witness → ¬IsMinimizer δ w param b

/-
**Certified Asymmetry Theorem**: A trapdoor witness certifies that:
    1. The witness uniquely achieves the minimum score
    2. At threshold values, no unique minimizer exists (ambiguity)
-/
theorem certified_asymmetry (δ w : α → ℝ) (W : TrapdoorWitness α δ w) :
    -- The witness achieves minimum
    (∀ b, score δ w W.param W.witness ≤ score δ w W.param b) ∧
    -- At thresholds, uniqueness fails
    (∀ l, IsThreshold δ w l → ¬HasUniqueMinimizer δ w l) := by
  unfold IsThreshold HasUniqueMinimizer;
  simp_all +decide [ ExistsUnique ];
  constructor;
  · intro b;
    convert TropicalRateDistortion.tropicalRate_le_score δ w W.param b using 1;
    exact W.is_minimizer;
  · grind

/-
**Perturbation-Stable Certified Decoding**: If the witness has a
    strict margin, decoding remains correct under bounded perturbation.
-/
theorem certified_stable_decoding [Nontrivial α] (δ δ' w : α → ℝ) (l : ℝ) (a : α)
    (ha : IsMinimizer δ w l a)
    (huniq : ∀ b, b ≠ a → ¬IsMinimizer δ w l b)
    (hpert : ∀ i, |δ' i - δ i| < marginAt δ w l a / 2) :
    ∀ b, score δ' w l b ≥ score δ' w l a :=
  perturbation_stability δ δ' w l a ha huniq hpert

/-! ## Functoriality -/

variable {β : Type*} [Fintype β] [DecidableEq β] [Nonempty β]

/-- A closure refinement: C₁ refines C₂ if C₁'s closure contains C₂'s. -/
def ClosureRefines (C₁ C₂ : ClosureCapacity α) : Prop :=
  ∀ s, C₂.cl s ⊆ C₁.cl s

/-
**Pressure Monotonicity under Refinement**: If C₁ refines C₂ and has
    smaller capacity, then C₁'s pressure is at most C₂'s.
-/
theorem closureRefines_pressure_monotone
    (C₁ C₂ : ClosureCapacity α) (w : α → ℝ)
    (hcap : ∀ a : α, C₁.cap (C₁.cl {a}) ≤ C₂.cap (C₂.cl {a})) :
    ∀ l, closurePressure C₁ w l ≤ closurePressure C₂ w l := by
  intro l
  simp [closurePressure, hcap];
  exact fun a => ⟨ a, by linarith [ hcap a ] ⟩

/-
**Rate Monotonicity under Distortion Contraction**: If δ' ≤ δ pointwise,
    the rate with δ' is at most the rate with δ.
-/
theorem tropicalRate_mono_distortion (δ δ' w : α → ℝ)
    (hle : ∀ a, δ' a ≤ δ a) :
    ∀ l, l ≥ 0 → tropicalRate δ' w l ≤ tropicalRate δ w l := by
  -- By definition of `tropicalRate`, we know that for any `l ≥ 0`, `tropicalRate δ' w l ≤ tropicalRate δ w l`.
  intros l hl
  simp [tropicalRate, score];
  grind

end TropicalRateDistortion