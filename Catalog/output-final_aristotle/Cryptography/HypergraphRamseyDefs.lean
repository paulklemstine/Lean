import Mathlib

/-!
# Hypergraph Ramsey Theory: Core Definitions

This module provides the basic definitions underlying the r-uniform hypergraph
Ramsey theory developed in `Cryptography.HypergraphRamseyTheorems`:

* `HyperEdge n r` — an `r`-element subset of `Fin n` (an r-uniform hyperedge);
* `HypergraphColoring n r` — a 2-coloring of the r-uniform hyperedges;
* `MonochromaticClique χ S c` — the predicate that every r-subset of `S` has colour `c`;
* `HypergraphRamseyProp n r k l` — the r-uniform Ramsey property on `Fin n`;
* `tower` / `tower_pos` — the (height-indexed) tower function `2 ↑↑ h`;
* `steppingUpBound` — the exponential bound appearing in the stepping-up lemma.
-/

open Finset Nat

/-- An `r`-uniform hyperedge on the vertex set `Fin n`: an `r`-element subset. -/
structure HyperEdge (n r : ℕ) where
  /-- The underlying set of vertices. -/
  val : Finset (Fin n)
  /-- The edge has exactly `r` vertices. -/
  card_eq : val.card = r

/-- A 2-coloring of the `r`-uniform hyperedges on `Fin n`. -/
def HypergraphColoring (n r : ℕ) : Type := HyperEdge n r → Bool

/-- `S` is a monochromatic clique of colour `c`: every `r`-subset of `S`
is coloured `c`. -/
def MonochromaticClique {n r : ℕ} (χ : HypergraphColoring n r)
    (S : Finset (Fin n)) (c : Bool) : Prop :=
  ∀ T : Finset (Fin n), T ⊆ S → ∀ (h : T.card = r), χ ⟨T, h⟩ = c

/-- The r-uniform Ramsey property: every 2-coloring of the r-subsets of `Fin n`
contains a red `k`-clique or a blue `l`-clique. -/
def HypergraphRamseyProp (n r k l : ℕ) : Prop :=
  ∀ χ : HypergraphColoring n r,
    (∃ S : Finset (Fin n), S.card = k ∧ MonochromaticClique χ S true) ∨
    (∃ S : Finset (Fin n), S.card = l ∧ MonochromaticClique χ S false)

/-- The tower function: `tower b 0 = 1` and `tower b (k+1) = b ^ tower b k`.
So `tower 2 h = 2 ↑↑ h` is a height-`h` tower of `2`s. -/
def tower (b : ℕ) : ℕ → ℕ
  | 0 => 1
  | k + 1 => b ^ tower b k

@[simp] theorem tower_zero (b : ℕ) : tower b 0 = 1 := rfl

@[simp] theorem tower_succ (b k : ℕ) : tower b (k + 1) = b ^ tower b k := rfl

/-- The tower function is positive for a positive base. -/
theorem tower_pos (b : ℕ) (hb : 0 < b) (k : ℕ) : 0 < tower b k := by
  induction k with
  | zero => simp
  | succ k ih => simpa [tower] using pow_pos hb (tower b k)

/-- The exponential bound from the Erdős–Rado stepping-up lemma:
`steppingUpBound R = 2^{R-1} + 1`. -/
def steppingUpBound (R : ℕ) : ℕ := 2 ^ (R - 1) + 1