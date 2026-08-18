/-
Copyright (c) 2025. All rights reserved.

# Search-to-Decision for Compression, and its Cryptographic Payoff

## Overview

Third cycle of the Phase-B/M8 investigation (`Shared.CompressionOneWayFunctions`,
`Shared.CompressionUniversality`).

The previous cycles compared two *search* tasks — inverting a function and
finding shortest programs — and proved them equivalent.  The literature on
polynomial-time Kolmogorov complexity phrases hardness assumptions instead in
terms of the *decision* problem "is `K(y) ≤ n`?" (MINKT), so a complete
characterization must bridge search and decision.  That bridge is the classical
bit-by-bit prefix reconstruction, which we formalize here:

* `rebuild` — reconstruct a program one bit at a time from a *decision* oracle
  for the conditional predicate "some length-`n` continuation of the prefix `w`
  is a program for `y`";
* `rebuild_correct` — the reconstruction returns a genuine program of exactly the
  promised length (proved by induction on the number of remaining bits);
* `decisionToFinder_correct` — combining the reconstruction with the bounded
  search of `leastFrom` turns the decision oracle into a *shortest*-program
  finder;
* `decision_solves_inversion` — hence into an inverter;
* `owf_no_prefix_decider` — **cryptographic payoff**: if `f` is one-way for a
  class, then no algorithm of the class can decide the prefix-compressibility
  predicate of `f`.  The decision version of compression is hard exactly when
  one-way functions exist.

Together with cycle 1 (search version) and cycle 2 (approximate version), this
gives the promised map: *validity, exact-shortest, approximate-shortest and
prefix-decision compression tasks all sit at the same cryptographic level.*

No axioms beyond the standard three, no `sorry`.
-/
import Speculative.AutoResearch.CompressionUniversality

namespace CompressionOWF

/-! ## Section 1: Bit-by-bit reconstruction from a decision oracle -/

/-- Reconstruct a program bit by bit.  `dec w n` is meant to answer
"is there a string `p` of length `n` with `D (w ++ p) = y`?".  Starting from the
empty prefix and the correct total length, `rebuild` walks down the binary tree
of prefixes, always taking a branch that keeps a solution alive. -/
def rebuild (dec : Str → ℕ → Bool) : ℕ → Str → Str
  | 0, w => w
  | n + 1, w =>
      if dec (w ++ [false]) n then rebuild dec n (w ++ [false])
      else rebuild dec n (w ++ [true])

/-- **Correctness of the reconstruction.**  If some length-`n` continuation of
`w` is a `D`-program for `y`, then `rebuild` outputs one, of exactly the right
length. -/
theorem rebuild_correct (D : Str → Str) (y : Str) (dec : Str → ℕ → Bool)
    (hdec : ∀ w n, dec w n = true ↔ ∃ p : Str, p.length = n ∧ D (w ++ p) = y) :
    ∀ (n : ℕ) (w : Str), (∃ p : Str, p.length = n ∧ D (w ++ p) = y) →
      D (rebuild dec n w) = y ∧ (rebuild dec n w).length = w.length + n := by
  intro n
  induction n with
  | zero =>
      intro w hw
      obtain ⟨p, hp, hpy⟩ := hw
      have hp0 : p = [] := List.eq_nil_of_length_eq_zero hp
      subst hp0
      simp only [rebuild, List.append_nil] at hpy ⊢
      exact ⟨hpy, by omega⟩
  | succ m ih =>
      intro w hw
      obtain ⟨p, hp, hpy⟩ := hw
      cases p with
      | nil => simp at hp
      | cons b t =>
          have htlen : t.length = m := by simpa using hp
          have hassoc : w ++ (b :: t) = (w ++ [b]) ++ t := by simp
          rw [hassoc] at hpy
          by_cases hbranch : dec (w ++ [false]) m = true
          · have hstep : rebuild dec (m + 1) w = rebuild dec m (w ++ [false]) := by
              simp [rebuild, hbranch]
            obtain ⟨q, hq, hqy⟩ := (hdec (w ++ [false]) m).1 hbranch
            obtain ⟨h1, h2⟩ := ih (w ++ [false]) ⟨q, hq, hqy⟩
            rw [hstep]
            refine ⟨h1, ?_⟩
            rw [h2]
            simp only [List.length_append, List.length_cons, List.length_nil]
            omega
          · -- the `false` branch is dead, so the surviving bit must be `true`
            have hbtrue : b = true := by
              cases b
              · exact absurd ((hdec (w ++ [false]) m).2 ⟨t, htlen, hpy⟩) hbranch
              · rfl
            subst hbtrue
            have hstep : rebuild dec (m + 1) w = rebuild dec m (w ++ [true]) := by
              simp [rebuild, hbranch]
            obtain ⟨h1, h2⟩ := ih (w ++ [true]) ⟨t, htlen, hpy⟩
            rw [hstep]
            refine ⟨h1, ?_⟩
            rw [h2]
            simp only [List.length_append, List.length_cons, List.length_nil]
            omega

/-! ## Section 2: From the decision oracle to a shortest-program finder -/

/-- The compressor built from a decision oracle: first find the optimal length by
bounded search, then reconstruct the program bit by bit. -/
def decisionToFinder (dec : Str → Str → ℕ → Bool) (fuel : ℕ → ℕ) : Str → Str :=
  fun y => rebuild (dec y) (leastFrom (fun n => dec y [] n) (fuel y.length)) []

/-- **Search-to-decision for compression.**  A correct decision oracle for the
conditional predicate "some length-`n` continuation of `w` is a `D`-program for
`y`" yields a *shortest*-program finder for `D`, provided the fuel covers the
complexity. -/
theorem decisionToFinder_correct (D : Str → Str) (dec : Str → Str → ℕ → Bool)
    (fuel : ℕ → ℕ)
    (hdec : ∀ y w n, dec y w n = true ↔ ∃ p : Str, p.length = n ∧ D (w ++ p) = y)
    (y : Str) (hy : Describable D y) (hfuel : K D y ≤ fuel y.length) :
    D (decisionToFinder dec fuel y) = y ∧
      (decisionToFinder dec fuel y).length = K D y := by
  set P : ℕ → Bool := fun n => dec y [] n with hP
  have hPiff : ∀ n, P n = true ↔ ∃ p : Str, p.length = n ∧ D p = y := by
    intro n
    constructor
    · intro h
      obtain ⟨p, hp, hpy⟩ := (hdec y [] n).1 h
      exact ⟨p, hp, by simpa using hpy⟩
    · rintro ⟨p, hp, hpy⟩
      exact (hdec y [] n).2 ⟨p, hp, by simpa using hpy⟩
  obtain ⟨pK, hpKlen, hpKy⟩ := exists_shortest hy
  have hPK : P (K D y) = true := (hPiff _).2 ⟨pK, hpKlen, hpKy⟩
  have hex : ∃ n ≤ fuel y.length, P n = true := ⟨K D y, hfuel, hPK⟩
  obtain ⟨hgot, hmin⟩ := leastFrom_spec P (fuel y.length) hex
  set n0 := leastFrom P (fuel y.length) with hn0
  have hn0le : n0 ≤ K D y := by
    by_contra hcon
    push_neg at hcon
    have := hmin (K D y) hcon
    rw [hPK] at this
    exact absurd this (by simp)
  have hKle : K D y ≤ n0 := by
    obtain ⟨p, hp, hpy⟩ := (hPiff n0).1 hgot
    have := K_le_of_eq hpy
    omega
  have hn0eq : n0 = K D y := le_antisymm hn0le hKle
  obtain ⟨p, hp, hpy⟩ := (hPiff n0).1 hgot
  have hres : decisionToFinder dec fuel y = rebuild (dec y) n0 [] := rfl
  obtain ⟨h1, h2⟩ :=
    rebuild_correct D y (dec y) (fun w n => hdec y w n) n0 [] ⟨p, hp, by simpa using hpy⟩
  rw [hres]
  refine ⟨h1, ?_⟩
  rw [h2]
  simp [hn0eq]

/-- A decision oracle for the prefix-compressibility predicate of `f` inverts
`f`. -/
theorem decision_solves_inversion (f : Str → Str) (dec : Str → Str → ℕ → Bool)
    (fuel : ℕ → ℕ)
    (hdec : ∀ y w n, dec y w n = true ↔ ∃ p : Str, p.length = n ∧ f (w ++ p) = y)
    (hfuel : ∀ y : Str, Describable f y → K f y ≤ fuel y.length) :
    Inverts f (decisionToFinder dec fuel) :=
  fun y hy => (decisionToFinder_correct f dec fuel hdec y hy (hfuel y hy)).1

/-! ## Section 3: Cryptographic payoff -/

/-- **Under a one-way function the decision version of compression is hard.**
If `f` is one-way for the class `C`, then no algorithm of `C` implements the
prefix-compressibility decision oracle of `f` — not even with an arbitrary
admissible fuel bound. -/
theorem owf_no_prefix_decider (C : SearchClosedClass) (f : Str → Str)
    (hf : OneWayIn C f) (dec : Str → Str → ℕ → Bool) (fuel : ℕ → ℕ)
    (hdec : ∀ y w n, dec y w n = true ↔ ∃ p : Str, p.length = n ∧ f (w ++ p) = y)
    (hmem : decisionToFinder dec fuel ∈ C.Comp)
    (hfuel : ∀ y : Str, Describable f y → K f y ≤ fuel y.length) : False := by
  obtain ⟨-, -, hhard⟩ := hf
  exact hhard (decisionToFinder dec fuel) hmem
    (decision_solves_inversion f dec fuel hdec hfuel)

/-- The three compression tasks of this development coincide in strength: an
exact shortest-program finder, an approximate one, and a prefix-decision oracle
all yield an inverter, and (by `inversion_iff_shortest_compression`) inversion
yields all of them back inside a search-closed class. -/
theorem compression_tasks_all_invert (D : Str → Str) (A : Str → Str) (δ : ℕ → ℕ)
    (dec : Str → Str → ℕ → Bool) (fuel : ℕ → ℕ)
    (hfuel : ∀ y : Str, Describable D y → K D y ≤ fuel y.length) :
    (ShortestFinder D A → Inverts D A)
    ∧ (ApproxShortestFinder D A δ → Inverts D A)
    ∧ ((∀ y w n, dec y w n = true ↔ ∃ p : Str, p.length = n ∧ D (w ++ p) = y) →
        Inverts D (decisionToFinder dec fuel)) :=
  ⟨shortestFinder_inverts, approxFinder_inverts,
    fun hdec => decision_solves_inversion D dec fuel hdec hfuel⟩

end CompressionOWF