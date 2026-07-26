/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib

/-!
# Non-circular lists

A **non-circular list** is simply a list with no repeated elements (`List.Nodup`).
The terminology emphasises the use we make of it: when we enumerate the elements
of a finite set as a non-circular list `v₀ :: v₁ :: …`, the head `v₀` is distinct
from every later element, so a "star" of merge operations `(v₀, vᵢ)` never pairs a
vertex with itself — there is no self-reference / cycle of length one.

This file provides:

* `Combinatorics.NonCircular.order` — a canonical non-circular enumeration of a `Finset`.
* `order_nodup`, `mem_order`, `order_length` — its basic properties.
* `head_not_mem_tail` — the key "non-circular" fact: the head is not among the tail.
-/

namespace Combinatorics.NonCircular

variable {α : Type*}

/-- A list is **non-circular** when it has no repeated elements. -/
def IsNonCircular (l : List α) : Prop := l.Nodup

theorem isNonCircular_iff_nodup (l : List α) : IsNonCircular l ↔ l.Nodup := Iff.rfl

/-- The key non-circular fact: in a non-circular list `v₀ :: rest`, the head `v₀`
does not occur in `rest`.  Hence pairing `v₀` with elements of `rest` never produces
a self-reference. -/
theorem head_not_mem_tail {v₀ : α} {rest : List α} (h : IsNonCircular (v₀ :: rest)) :
    v₀ ∉ rest := (List.nodup_cons.mp h).1

/-- A canonical non-circular enumeration of a `Finset`. -/
noncomputable def order [DecidableEq α] (s : Finset α) : List α := s.toList

@[simp] theorem order_nodup [DecidableEq α] (s : Finset α) : IsNonCircular (order s) :=
  s.nodup_toList

@[simp] theorem mem_order [DecidableEq α] (s : Finset α) (a : α) :
    a ∈ order s ↔ a ∈ s := Finset.mem_toList

@[simp] theorem order_toFinset [DecidableEq α] (s : Finset α) :
    (order s).toFinset = s := s.toList_toFinset

@[simp] theorem order_length [DecidableEq α] (s : Finset α) :
    (order s).length = s.card := Finset.length_toList s

end Combinatorics.NonCircular