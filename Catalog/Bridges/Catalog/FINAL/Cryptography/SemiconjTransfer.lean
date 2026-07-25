/-
# Eventual Periodicity Transfer via Semiconjugacy

This module formalizes the principle that semiconjugacies transport orbit structure
between dynamical systems. The central theorem `semiconj_iterate_eq` states that
every orbit collision in the source system pushes forward through a semiconjugacy
to an orbit collision in the target system.

## Main Results

* `semiconj_iterate_eq` — if `h` semiconjugates `f` to `g` and `f^[i] x = f^[j] x`,
  then `g^[i] (h x) = g^[j] (h x)`.
* `semiconj_eventually_periodic` — eventual periodicity transfers through semiconjugacy.
* `Function.Semiconj.isFixedPt_image` — fixed points transfer through semiconjugacy.
* `Function.Semiconj.isPeriodicPt_image` — periodic points transfer through semiconjugacy.
* `semiconj_eventually_periodic_of_fintype` — in a finite source system, every orbit
  in the target system (under semiconjugacy) is eventually periodic.

## Applications

These results form the infrastructure for transporting recurrence theorems across
representations in symbolic dynamics, automata theory, coding theory, finite-state
verification, and cryptographic analysis of iterated maps.
-/

import Mathlib

/-- Semiconjugacy transports iterate equalities exactly: every orbit collision
in the source system pushes forward through a semiconjugacy to an orbit collision
in the target system.

This is the fundamental transfer principle: if `h ∘ f = g ∘ h` and the `f`-orbit
of `x` has a collision at iterates `i` and `j`, then the `g`-orbit of `h x`
has a collision at the same iterates. -/
theorem semiconj_iterate_eq
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g)
    {x : α} {i j : ℕ}
    (hij : f^[i] x = f^[j] x) :
    g^[i] (h x) = g^[j] (h x) := by
  have h_eq : h (f^[i] x) = h (f^[j] x) := congrArg h hij
  exact hsemi.iterate_right i x ▸ hsemi.iterate_right j x ▸ h_eq

/-- If `f` has an eventually periodic orbit at `x`, and `h` semiconjugates `f` to `g`,
then `g` has an eventually periodic orbit at `h x`.

This is a direct corollary of `semiconj_iterate_eq`. The hypothesis `hn : 0 < n`
is included for the mathematical narrative of eventual periodicity (the period must
be positive) but is not logically required. -/
theorem semiconj_eventually_periodic
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g)
    {x : α} {m n : ℕ}
    (_hn : 0 < n)
    (hev : f^[m + n] x = f^[m] x) :
    g^[m + n] (h x) = g^[m] (h x) :=
  semiconj_iterate_eq hsemi hev

/-- Fixed points transfer through semiconjugacy: if `f x = x` and `h` semiconjugates
`f` to `g`, then `g (h x) = h x`. -/
theorem Function.Semiconj.isFixedPt_image
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g) {x : α}
    (hx : Function.IsFixedPt f x) :
    Function.IsFixedPt g (h x) := by
  simp only [Function.IsFixedPt, Function.Semiconj] at *
  rw [← hsemi, hx]

/-- Periodic points transfer through semiconjugacy: if `f^[n] x = x` and `h`
semiconjugates `f` to `g`, then `g^[n] (h x) = h x`. -/
theorem Function.Semiconj.isPeriodicPt_image
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g) {x : α} {n : ℕ}
    (_hn : 0 < n)
    (hx : Function.IsPeriodicPt f n x) :
    Function.IsPeriodicPt g n (h x) :=
  hx.map hsemi

/-- In a finite dynamical system, every orbit is eventually periodic. Combined with
semiconjugacy transfer, this yields: every deterministic image of a finite dynamical
system has eventually periodic observed orbits.

This fuses the pigeonhole principle (giving orbit collisions in finite systems) with
`semiconj_iterate_eq` (transporting collisions through semiconjugacy). -/
theorem semiconj_eventually_periodic_of_fintype
    {α β : Type*} [Fintype α] [DecidableEq α]
    {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g) (x : α) :
    ∃ m n : ℕ, 0 < n ∧ g^[m + n] (h x) = g^[m] (h x) := by
  obtain ⟨i, j, hij, hf⟩ : ∃ i j : ℕ, i < j ∧ f^[i] x = f^[j] x := by
    by_contra h_no
    exact absurd
      (Set.infinite_range_of_injective (fun i j hij => le_antisymm
        (not_lt.1 fun hi => h_no ⟨j, i, hi, hij.symm⟩)
        (not_lt.1 fun hj => h_no ⟨i, j, hj, hij⟩)))
      (Set.not_infinite.mpr <| Set.toFinite _)
  exact ⟨i, j - i, Nat.sub_pos_of_lt hij, by
    rw [add_tsub_cancel_of_le hij.le, semiconj_iterate_eq hsemi hf]⟩