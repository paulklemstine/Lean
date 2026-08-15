import Mathlib
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Logic.GraphTheory.Defs

/-! # Basic Open Laws for the Spectrum of a Frame

We prove the fundamental laws governing basic open sets `D(k)` in the spectrum
of a frame:

* `basicOpen_bot` : `D(⊥) = ∅`
* `basicOpen_top` : `D(⊤) = Set.univ`
* `basicOpen_inf` : `D(a ⊓ b) = D(a) ∩ D(b)` (uses primality)
* `basicOpen_sup` : `D(a ⊔ b) = D(a) ∪ D(b)`
* `basicOpen_anti` : `a ≤ b → D(b) ⊆ D(a)`
-/

open Set Order

universe u

variable {L : Type u} [Order.Frame L]

/-- `D(⊥) = ∅`: since `⊥ ≤ p` for all `p`, no prime excludes `⊥`. -/
theorem basicOpen_bot : basicOpen L ⊥ = (∅ : Set (PrimeElement L)) := by
  ext p; simp [basicOpen, bot_le]

/-- `D(⊤) = Set.univ`: since primes are proper, every prime excludes `⊤`. -/
theorem basicOpen_top : basicOpen L ⊤ = (Set.univ : Set (PrimeElement L)) := by
  ext p; simp [basicOpen, top_le_iff, p.ne_top]

/-- `D(a ⊓ b) = D(a) ∩ D(b)`.

Forward: if `¬(a ⊓ b ≤ p)`, then `¬(a ≤ p)` (since `a ⊓ b ≤ a`, if `a ≤ p`
then `a ⊓ b ≤ p`) and similarly `¬(b ≤ p)`.

Reverse: if `¬(a ≤ p)` and `¬(b ≤ p)`, then by contrapositive of primality,
`¬(a ⊓ b ≤ p)`. -/
theorem basicOpen_inf (a b : L) :
    basicOpen L (a ⊓ b) = basicOpen L a ∩ basicOpen L b := by
  ext p
  simp only [basicOpen, mem_setOf_eq, mem_inter_iff]
  constructor
  · intro h
    exact ⟨fun ha => h (inf_le_left.trans ha), fun hb => h (inf_le_right.trans hb)⟩
  · intro ⟨ha, hb⟩ hab
    exact (p.prime hab).elim ha hb

/-- `D(a ⊔ b) = D(a) ∪ D(b)`. -/
theorem basicOpen_sup (a b : L) :
    basicOpen L (a ⊔ b) = basicOpen L a ∪ basicOpen L b := by
  ext p
  simp only [basicOpen, mem_setOf_eq, mem_union, sup_le_iff, not_and_or]

/-- Basic opens are monotone: `a ≤ b → D(a) ⊆ D(b)`.
If `a ≤ b` and `p` excludes `a`, then `p` also excludes `b`
(since `b ≤ p` would force `a ≤ p`). -/
theorem basicOpen_mono {a b : L} (h : a ≤ b) :
    basicOpen L a ⊆ basicOpen L b := by
  intro p hp hbp
  exact hp (h.trans hbp)

/-- A prime element belongs to `D(k)` iff `k` is not below it. -/
theorem mem_basicOpen_iff (k : L) (p : PrimeElement L) :
    p ∈ basicOpen L k ↔ ¬(k ≤ p.val) :=
  Iff.rfl

/-- Meet membership for primes, restated from `basicOpen_inf`. -/
theorem prime_mem_basicOpen_inf_iff (p : PrimeElement L) (a b : L) :
    p ∈ basicOpen L (a ⊓ b) ↔ p ∈ basicOpen L a ∧ p ∈ basicOpen L b := by
  rw [basicOpen_inf]; rfl

/-- Specialization is characterized by basic-open inclusion. -/
theorem specializes_iff_basicOpen (p q : PrimeElement L) :
    PrimeElement.specializes p q ↔
      ∀ k : L, p ∈ basicOpen L k → q ∈ basicOpen L k := by
  constructor
  · intro hspec k hp hkq
    exact hp (hkq.trans hspec)
  · intro h
    simp only [PrimeElement.specializes]
    by_contra hle
    have hp_in : p ∈ basicOpen L q.val := hle
    have hq_in : q ∈ basicOpen L q.val := h q.val hp_in
    exact hq_in (le_refl _)

/-- **T₀ separation**: prime elements are distinguished by basic opens.
If two primes lie in exactly the same basic opens, they are equal. -/
theorem t0_primeElement
    {p q : PrimeElement L}
    (h : ∀ k : L, p ∈ basicOpen L k ↔ q ∈ basicOpen L k) :
    p = q := by
  have hpq : PrimeElement.specializes p q :=
    (specializes_iff_basicOpen p q).mpr (fun k hk => (h k).mp hk)
  have hqp : PrimeElement.specializes q p :=
    (specializes_iff_basicOpen q p).mpr (fun k hk => (h k).mpr hk)
  cases p; cases q
  simp only [PrimeElement.mk.injEq]
  exact le_antisymm hqp hpq