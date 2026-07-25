/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Periodicity of tensor powers in a monoidal category

This file develops the *core* theory of periodic tensor powers in an arbitrary
monoidal category `C`.  The treatment is deliberately restricted to the results
that can be proved cleanly from a concrete, witness-based definition of
periodicity.  In particular we do **not** treat braided tensor products, finite
skeletal categories, or delooping equivalences here; those stronger consequences
are deferred to later developments.

## Main definitions

* `mpow X n` : the right-associated `n`-fold tensor power of an object `X`,
  defined by `mpow X 0 = 𝟙_ C` and `mpow X (n+1) = X ⊗ mpow X n`.
* `HasPeriodAt X m d` : there is an isomorphism `mpow X m ≅ mpow X (m+d)`
  (a concrete periodicity witness "starting at `m`").
* `HasPeriod X d` : `0 < d` together with a witness `HasPeriodAt X m d` for some `m`.
* `IsPeriodic X` : `X` has some positive period.
* `PeriodSet X` : the set of all periods of `X`.
* `minPeriod h` : the least positive period, defined via `Nat.find` from a proof
  `h : IsPeriodic X`.

## Main results

* `mpow_add_iso` : the additive comparison isomorphism
  `mpow X (m + n) ≅ mpow X m ⊗ mpow X n`.
* `HasPeriodAt.shift` : shift invariance of witnesses, the central theorem:
  a witness starting at `m` can be transported to one starting at `m + k`.
* `isPeriodic_of_iso_lt` : a witness pair `m < n` with `mpow X m ≅ mpow X n`
  yields `IsPeriodic X` (with period `n - m`).
* `minPeriod_spec`, `minPeriod_le`, `minPeriod_pos` : basic facts about the
  least positive period.

The divisibility theory of the least period (which would require closure under
modular reduction of periods) is intentionally omitted; only the minimality
inequality `minPeriod_le` is provided in this cycle.
-/

import Mathlib

open CategoryTheory MonoidalCategory

namespace MonoidalPeriodicity

variable {C : Type*} [Category C] [MonoidalCategory C]

/-- The right-associated `n`-fold tensor power of `X`. -/
def mpow (X : C) : ℕ → C
  | 0 => 𝟙_ C
  | (n + 1) => X ⊗ mpow X n

@[simp]
theorem mpow_zero (X : C) : mpow X 0 = 𝟙_ C := rfl

@[simp]
theorem mpow_succ (X : C) (n : ℕ) : mpow X (n + 1) = X ⊗ mpow X n := rfl

/-- The first tensor power is isomorphic to `X` itself (via the right unitor). -/
def mpowOneIso (X : C) : mpow X 1 ≅ X := ρ_ X

/-- Index equalities induce isomorphisms of tensor powers. -/
def mpowCongr (X : C) {m n : ℕ} (h : m = n) : mpow X m ≅ mpow X n :=
  eqToIso (by rw [h])

/-- The additive comparison isomorphism for tensor powers:
`mpow X (m + n) ≅ mpow X m ⊗ mpow X n`.  Proved by induction on `m`, transporting
along the right unitor and the associator (right-associated recursion). -/
def mpow_add_iso (X : C) (m n : ℕ) : mpow X (m + n) ≅ mpow X m ⊗ mpow X n := by
  induction m with
  | zero => exact mpowCongr X (Nat.zero_add n) ≪≫ (λ_ (mpow X n)).symm
  | succ m ih =>
      exact mpowCongr X (Nat.succ_add m n) ≪≫ whiskerLeftIso X ih ≪≫
        (α_ X (mpow X m) (mpow X n)).symm

/-- A concrete periodicity witness "starting at `m`": an isomorphism
`mpow X m ≅ mpow X (m + d)`. -/
def HasPeriodAt (X : C) (m d : ℕ) : Prop := Nonempty (mpow X m ≅ mpow X (m + d))

/-- `X` has period `d` if `d` is positive and some witness `HasPeriodAt X m d` exists. -/
def HasPeriod (X : C) (d : ℕ) : Prop := 0 < d ∧ ∃ m, HasPeriodAt X m d

/-- `X` is periodic if it has some positive period. -/
def IsPeriodic (X : C) : Prop := ∃ d, HasPeriod X d

/-- **Shift invariance of witnesses** (central theorem).  A periodicity witness
starting at `m` transports to a witness starting at `m + k`, by repeatedly
tensoring the isomorphism on the left by `X`. -/
theorem HasPeriodAt.shift (X : C) {m d : ℕ} (h : HasPeriodAt X m d) (k : ℕ) :
    HasPeriodAt X (m + k) d := by
  induction k with
  | zero => exact h
  | succ k ih =>
      obtain ⟨e⟩ := ih
      exact ⟨whiskerLeftIso X e ≪≫
        mpowCongr X (by omega : (m + k + d) + 1 = m + (k + 1) + d)⟩

/-- Closure of periods under additive shifting: a witness pair persists at every
later starting index. -/
theorem HasPeriod.exists_witness_ge (X : C) {d : ℕ} (h : HasPeriod X d) (k : ℕ) :
    ∃ m, k ≤ m ∧ HasPeriodAt X m d := by
  obtain ⟨_, m, hm⟩ := h
  exact ⟨m + k, by omega, hm.shift X k⟩

/-- Any isomorphism `mpow X m ≅ mpow X n` with `m < n` makes `X` periodic, with
period `n - m`. -/
theorem isPeriodic_of_iso_lt (X : C) {m n : ℕ} (hmn : m < n)
    (e : mpow X m ≅ mpow X n) : IsPeriodic X :=
  ⟨n - m, by omega, m, ⟨e ≪≫ mpowCongr X (by omega : n = m + (n - m))⟩⟩

/-- The set of all periods of `X`. -/
def PeriodSet (X : C) : Set ℕ := {d | HasPeriod X d}

open Classical in
/-- The least positive period of a periodic object, defined via `Nat.find`. -/
noncomputable def minPeriod {X : C} (h : IsPeriodic X) : ℕ := Nat.find h

open Classical in
/-- The least period is indeed a period. -/
theorem minPeriod_spec {X : C} (h : IsPeriodic X) : HasPeriod X (minPeriod h) :=
  Nat.find_spec h

open Classical in
/-- The least period is `≤` every period (minimality). -/
theorem minPeriod_le {X : C} (h : IsPeriodic X) {d : ℕ} (hd : d ∈ PeriodSet X) :
    minPeriod h ≤ d :=
  Nat.find_min' h hd

/-- The least period is positive. -/
theorem minPeriod_pos {X : C} (h : IsPeriodic X) : 0 < minPeriod h :=
  (minPeriod_spec h).1

end MonoidalPeriodicity