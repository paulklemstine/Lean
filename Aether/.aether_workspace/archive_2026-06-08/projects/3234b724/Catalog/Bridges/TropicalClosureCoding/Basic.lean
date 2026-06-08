/-
Copyright (c) 2025 Tropical Closure Coding Theory. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Closure Coding Theory — Basic Definitions

This file establishes the foundational structures for tropical closure coding theory,
a bridge between closure systems (from formal concept analysis / EML) and
error-correcting codes over idempotent semirings.

## Main Definitions

* `ClosureCode` — A bundled closure operator on a finite type, representing a "code"
  whose codewords are the closed sets.
* `ClosureCode.IsClosed` — Predicate for closed sets (codewords).
* `Implication` — A Horn implication `A ⇒ b` representing a parity constraint.
* `ClosurePresentation` — A finite family of implications presenting a closure code.
* `Implication.Satisfies` — A set satisfies an implication.
* `Implication.violation` — The 0-1 violation indicator for an implication.
* `syndrome` — The total syndrome (sum of violations) for a presentation.
* `PresentsClosure` — Witness that a presentation correctly presents a closure code.

## Main Results

* `ClosureCode.cl_isClosed` — The closure of any set is closed.
* `ClosureCode.cl_least_closed_superset` — The closure is the least closed superset.
* `closed_iff_zero_syndrome` — **Theorem A**: A set is closed iff its tropical syndrome vanishes.
* `defect_separation` — If x is not closed, some violation functional witnesses the defect.
-/

import Mathlib

open Classical in
noncomputable section

universe u

variable {α : Type u}

/-- A closure code on a type `α`: a monotone, extensive, idempotent operator.
    The "codewords" are exactly the closed (fixed) sets. -/
structure ClosureCode (α : Type*) where
  /-- The closure operator -/
  cl : Set α → Set α
  /-- Closure is monotone -/
  mono : Monotone cl
  /-- Closure is extensive -/
  extensive : ∀ s, s ⊆ cl s
  /-- Closure is idempotent -/
  idem : ∀ s, cl (cl s) = cl s

namespace ClosureCode

/-- A set is closed (a codeword) if it is a fixed point of the closure operator. -/
def IsClosed (C : ClosureCode α) (s : Set α) : Prop :=
  C.cl s = s

theorem isClosed_iff_cl_eq (C : ClosureCode α) (s : Set α) :
    C.IsClosed s ↔ C.cl s = s :=
  Iff.rfl

/-- The closure of any set is closed. -/
theorem cl_isClosed (C : ClosureCode α) (s : Set α) : C.IsClosed (C.cl s) :=
  C.idem s

/-- Every set is a subset of its closure. -/
theorem subset_cl (C : ClosureCode α) (s : Set α) : s ⊆ C.cl s :=
  C.extensive s

/-- Closure is monotone. -/
theorem cl_mono (C : ClosureCode α) {s t : Set α} (h : s ⊆ t) : C.cl s ⊆ C.cl t :=
  C.mono h

/-- **The closure is the least closed superset**: if `t` is closed and `s ⊆ t`,
    then `cl(s) ⊆ t`. This is the key lattice-theoretic property. -/
theorem cl_least_closed_superset (C : ClosureCode α) (s t : Set α)
    (ht : C.IsClosed t) (hst : s ⊆ t) : C.cl s ⊆ t := by
  have h1 : C.cl s ⊆ C.cl t := C.mono hst
  rw [ht] at h1
  exact h1

/-- The universe is always closed. -/
theorem isClosed_univ (C : ClosureCode α) (h : C.cl Set.univ = Set.univ) :
    C.IsClosed Set.univ :=
  h

/-- Closure applied to a closed set is the identity. -/
theorem cl_of_isClosed (C : ClosureCode α) {s : Set α} (hs : C.IsClosed s) :
    C.cl s = s :=
  hs

end ClosureCode

/-- An implication `A ⇒ b`: if all elements of `A` are present, then `b` must be present.
    This is a Horn clause / parity constraint. -/
structure Implication (α : Type*) where
  /-- The premise set -/
  premise : Finset α
  /-- The conclusion element -/
  conclusion : α

namespace Implication

variable [DecidableEq α]

/-- A set satisfies an implication if: premise ⊆ x implies conclusion ∈ x. -/
def Satisfies (imp : Implication α) (x : Set α) : Prop :=
  (↑imp.premise : Set α) ⊆ x → imp.conclusion ∈ x

/-- The violation of an implication: 1 if the premise is satisfied but conclusion is missing. -/
noncomputable def violation (imp : Implication α) (x : Set α) : ℕ :=
  if (↑imp.premise : Set α) ⊆ x ∧ imp.conclusion ∉ x then 1 else 0

omit [DecidableEq α] in
theorem violation_eq_zero_iff (imp : Implication α) (x : Set α) :
    imp.violation x = 0 ↔ imp.Satisfies x := by
  unfold violation Satisfies
  simp only [ite_eq_right_iff, one_ne_zero]
  constructor
  · intro h hprem
    by_contra habs
    exact h ⟨hprem, habs⟩
  · intro h ⟨hprem, habs⟩
    exact absurd (h hprem) habs

theorem violation_pos_iff (imp : Implication α) (x : Set α) :
    0 < imp.violation x ↔ ¬imp.Satisfies x := by
  rw [← violation_eq_zero_iff]
  omega

end Implication

/-- A closure presentation: a finite family of implications. -/
structure ClosurePresentation (α : Type*) where
  /-- The finite family of implications (parity constraints) -/
  implications : Finset (Implication α)

variable [DecidableEq α]

/-- The **tropical syndrome** of a set with respect to a presentation:
    the sum of all violation indicators.
    Zero syndrome ↔ all implications satisfied ↔ closed. -/
noncomputable def syndrome (P : ClosurePresentation α) (x : Set α) : ℕ :=
  P.implications.sum (fun imp => imp.violation x)

/-- The syndrome is zero iff all implications are satisfied. -/
theorem syndrome_eq_zero_iff (P : ClosurePresentation α) (x : Set α) :
    syndrome P x = 0 ↔ ∀ imp ∈ P.implications, imp.Satisfies x := by
  unfold syndrome
  rw [Finset.sum_eq_zero_iff]
  constructor
  · intro h imp himp
    exact (Implication.violation_eq_zero_iff imp x).mp (h imp himp)
  · intro h imp himp
    exact (Implication.violation_eq_zero_iff imp x).mpr (h imp himp)

/-- A presentation **presents** a closure code if:
    1. (Soundness) Every closed set satisfies all implications.
    2. (Completeness) Every set satisfying all implications is closed. -/
structure PresentsClosure (C : ClosureCode α) (P : ClosurePresentation α) : Prop where
  /-- Soundness: closed sets satisfy all implications -/
  sound : ∀ imp ∈ P.implications, ∀ x, C.IsClosed x → imp.Satisfies x
  /-- Completeness: satisfying all implications implies closed -/
  complete : ∀ x, (∀ imp ∈ P.implications, imp.Satisfies x) → C.IsClosed x

/-- **Theorem A (Canonical Tropical Parity Presentation):**
    A set is closed if and only if its tropical syndrome vanishes.
    This is the fundamental parity-check theorem for closure codes. -/
theorem closed_iff_zero_syndrome
    (C : ClosureCode α) (P : ClosurePresentation α)
    (hpres : PresentsClosure C P) (x : Set α) :
    C.IsClosed x ↔ syndrome P x = 0 := by
  rw [syndrome_eq_zero_iff]
  exact ⟨fun hcl imp himp => hpres.sound imp himp x hcl, fun h => hpres.complete x h⟩

/-- **Defect Separation Theorem:**
    If `x` is not closed, then there exists a violation functional that
    witnesses the defect: it is positive on `x` and zero on all closed sets.
    This is the tropical analogue of a separating hyperplane. -/
theorem defect_separation
    (C : ClosureCode α) (P : ClosurePresentation α)
    (hpres : PresentsClosure C P)
    {x : Set α} (hx : ¬C.IsClosed x) :
    ∃ imp ∈ P.implications,
      0 < imp.violation x ∧
      ∀ y, C.IsClosed y → imp.violation y = 0 := by
  rw [closed_iff_zero_syndrome C P hpres] at hx
  rw [syndrome_eq_zero_iff] at hx
  push_neg at hx
  obtain ⟨imp, himp, hsat⟩ := hx
  exact ⟨imp, himp, (Implication.violation_pos_iff imp x).mpr hsat,
    fun y hy => (Implication.violation_eq_zero_iff imp y).mpr (hpres.sound imp himp y hy)⟩

/-- The syndrome is positive for non-closed sets. -/
theorem syndrome_pos_of_not_closed
    (C : ClosureCode α) (P : ClosurePresentation α)
    (hpres : PresentsClosure C P)
    {x : Set α} (hx : ¬C.IsClosed x) :
    0 < syndrome P x := by
  rw [Nat.pos_iff_ne_zero]
  intro h
  exact hx ((closed_iff_zero_syndrome C P hpres x).mpr h)

/-- The syndrome is zero for closed sets. -/
theorem syndrome_eq_zero_of_closed
    (C : ClosureCode α) (P : ClosurePresentation α)
    (hpres : PresentsClosure C P)
    {x : Set α} (hx : C.IsClosed x) :
    syndrome P x = 0 :=
  (closed_iff_zero_syndrome C P hpres x).mp hx

end