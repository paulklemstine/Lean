import Mathlib

/-!
# The one–dimensional Sperner lemma and discrete fixed points

Sperner's lemma is the combinatorial heart of the Brouwer fixed point theorem, and
Brouwer's theorem is, via Kakutani, the engine behind Nash's existence theorem for
equilibria of finite games.  This file develops the *one dimensional* case of
Sperner's lemma completely and constructively, and extracts from it a genuine
discrete "intermediate value" / Brouwer fixed point statement.

A colouring of the path `0, 1, …, n` is a function `c : ℕ → Bool`.  An edge
`(i, i+1)` is *fully coloured* (a "1-dimensional fully labelled simplex") when its
two endpoints get different colours, `c i ≠ c (i+1)`.

## Main results

* `Sperner1D.parity` — the number of fully coloured edges on `0, …, n` has the same
  parity as the indicator of `c 0 ≠ c n`.  This is the exact 1-dimensional Sperner
  lemma: with Sperner boundary conditions the number of fully labelled simplices is
  **odd**, hence positive.
* `Sperner1D.exists_fully_coloured` — Sperner's existence statement: a Sperner
  colouring (`c 0 = false`, `c n = true`) has an *oriented* fully coloured edge
  `c i = false`, `c (i+1) = true`.
* `Sperner1D.discrete_ivt` — a discrete intermediate value theorem: a function
  `f : ℕ → ℤ` with `f 0 ≤ 0 ≤ f n` has a sign change `f i ≤ 0 ≤ f (i+1)`.
* `Sperner1D.discrete_brouwer` — a discrete Brouwer fixed point: any self-map `g` of
  `{0, …, n}` has an approximate fixed point `g i ≥ i` and `g (i+1) ≤ i+1`.
-/

namespace Sperner1D

open Finset

/-- The set of *fully coloured* edges `(i, i+1)` with `i < n`, i.e. edges whose two
endpoints receive different Boolean colours.  In dimension one these are exactly the
"fully labelled simplices" of Sperner's lemma. -/
def fullyColoured (c : ℕ → Bool) (n : ℕ) : Finset ℕ :=
  (Finset.range n).filter (fun i => c i ≠ c (i + 1))

/-
**One–dimensional Sperner lemma (parity form).**  The number of fully coloured
edges along the path `0, 1, …, n` is odd exactly when the endpoints differ.  This is
the precise statement that a Sperner colouring has an *odd* number of fully labelled
simplices.
-/
theorem parity (c : ℕ → Bool) (n : ℕ) :
    (fullyColoured c n).card % 2 = (if c 0 = c n then 0 else 1) := by
  induction' n with n ih;
  · aesop;
  · unfold fullyColoured at *;
    by_cases h : c n = c ( n + 1 ) <;> simp_all +decide [ Finset.filter ];
    cases h' : c 0 <;> cases h'' : c n <;> cases h''' : c ( n + 1 ) <;> simp_all +decide [ Nat.add_mod ]

/-
**Sperner existence (parity corollary).**  If the endpoints receive different
colours then some edge is fully coloured.
-/
theorem exists_fullyColoured_of_ne (c : ℕ → Bool) (n : ℕ) (h : c 0 ≠ c n) :
    ∃ i < n, c i ≠ c (i + 1) := by
  contrapose! h;
  induction' n with n ih;
  · rfl;
  · grind

/-
**Oriented Sperner existence in 1D.**  A Sperner colouring of `0, …, n`
(left endpoint `false`, right endpoint `true`) has an oriented fully coloured edge:
some `i < n` with `c i = false` and `c (i+1) = true`.
-/
theorem exists_fully_coloured (c : ℕ → Bool) (n : ℕ)
    (h0 : c 0 = false) (hn : c n = true) :
    ∃ i < n, c i = false ∧ c (i + 1) = true := by
  induction' n with n ih;
  · aesop;
  · grind +locals

/-
**Discrete intermediate value theorem.**  If `f 0 ≤ 0 ≤ f n` then `f` changes
sign across some edge: there is `i < n` with `f i ≤ 0 ≤ f (i+1)`.  This is the
order-theoretic content of Sperner's lemma in one dimension, and the discrete
analogue of the intermediate value theorem.
-/
theorem discrete_ivt (f : ℕ → ℤ) (n : ℕ) (hn1 : 0 < n) (h0 : f 0 ≤ 0) (hn : 0 ≤ f n) :
    ∃ i < n, f i ≤ 0 ∧ 0 ≤ f (i + 1) := by
  induction hn1 <;> simp_all +decide;
  grind

/-
**Discrete Brouwer fixed point.**  Any self-map `g` of `{0, …, n}` has an
approximate fixed point: some `i < n` with `g i ≥ i` and `g (i+1) ≤ i+1`.  This is
the combinatorial fixed point that, in higher dimensions and in the limit, yields
Brouwer's theorem and hence Nash equilibria.
-/
theorem discrete_brouwer (g : ℕ → ℕ) (n : ℕ) (hn1 : 0 < n) (hg : ∀ i ≤ n, g i ≤ n) :
    ∃ i < n, i ≤ g i ∧ g (i + 1) ≤ i + 1 := by
  convert discrete_ivt ( fun j => j - g j ) n hn1 ?_ ?_ using 1;
  · grind;
  · norm_num;
  · grind

end Sperner1D