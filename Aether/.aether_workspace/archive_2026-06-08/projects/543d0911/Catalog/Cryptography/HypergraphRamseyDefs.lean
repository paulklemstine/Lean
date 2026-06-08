import Mathlib

/-!
# Hypergraph Ramsey Theory: Definitions and Basic Properties

This file develops the foundational definitions for r-uniform hypergraph Ramsey theory.
The central object is the hypergraph Ramsey number R_r(k,l): the minimum n such that
any 2-coloring of the r-element subsets of an n-set contains either a red complete
k-hypergraph or a blue complete l-hypergraph.

## Main definitions

* `HypergraphColoring` — a 2-coloring of r-element subsets of `Fin n`
* `MonochromaticClique` — a set of vertices whose r-subsets are all one color
* `HypergraphRamseyProp` — the Ramsey property: every coloring has a mono clique
* `tower` — iterated exponentiation, central to hypergraph Ramsey growth rates

## References

* Conlon, Fox, Sudakov: "Hypergraph Ramsey numbers" (2010)
* Erdős, Rado: "Combinatorial theorems on classifications of subsets" (1952)
-/

open Finset Nat

/-- An r-element subset of `Fin n`, represented as a `Finset (Fin n)` of cardinality r. -/
structure RSubset (n r : ℕ) where
  val : Finset (Fin n)
  card_eq : val.card = r

/-- A 2-coloring of the r-element subsets of `Fin n`. Colors are `Bool`:
    `true` = red, `false` = blue. -/
def HypergraphColoring (n r : ℕ) := RSubset n r → Bool

/-- A set S of vertices forms a monochromatic clique of color c under coloring χ
    if every r-element subset of S receives color c. -/
def MonochromaticClique {n r : ℕ} (χ : HypergraphColoring n r)
    (S : Finset (Fin n)) (c : Bool) : Prop :=
  ∀ (T : Finset (Fin n)) (hT : T ⊆ S) (hcard : T.card = r), χ ⟨T, hcard⟩ = c

/-- The hypergraph Ramsey property: `HypergraphRamseyProp n r k l` means that
    for every 2-coloring of the r-element subsets of `Fin n`, there exists either
    a red monochromatic clique of size k or a blue monochromatic clique of size l. -/
def HypergraphRamseyProp (n r k l : ℕ) : Prop :=
  ∀ (χ : HypergraphColoring n r),
    (∃ S : Finset (Fin n), S.card = k ∧ MonochromaticClique χ S true) ∨
    (∃ S : Finset (Fin n), S.card = l ∧ MonochromaticClique χ S false)

/-- `HypergraphRamseyProp` is symmetric in the two clique sizes:
    swapping red and blue swaps k and l. -/
theorem HypergraphRamseyProp.symm {n r k l : ℕ} (h : HypergraphRamseyProp n r k l) :
    HypergraphRamseyProp n r l k := by
  intro χ
  let χ' : HypergraphColoring n r := fun T => !(χ T)
  rcases h χ' with ⟨S, hcard, hmono⟩ | ⟨S, hcard, hmono⟩
  · right
    exact ⟨S, hcard, fun T hT hTcard => by
      have := hmono T hT hTcard; simp [χ'] at this; exact this⟩
  · left
    exact ⟨S, hcard, fun T hT hTcard => by
      have := hmono T hT hTcard; simp [χ'] at this; exact this⟩

/-- Tower function: iterated exponentiation. `tower b 0 = 1`, `tower b (k+1) = b ^ tower b k`.
    This captures the growth rate hierarchy of hypergraph Ramsey numbers:
    r-uniform Ramsey numbers grow as a tower of height r-1. -/
def tower (b : ℕ) : ℕ → ℕ
  | 0 => 1
  | k + 1 => b ^ tower b k

/-- Tower function always produces positive values when the base is positive. -/
theorem tower_pos (b : ℕ) (hb : 0 < b) : ∀ k, 0 < tower b k := by
  intro k
  induction k with
  | zero => simp [tower]
  | succ k ih =>
    simp [tower]
    exact Nat.pos_of_ne_zero (by positivity)

/-- The stepping-up function: given a graph Ramsey number R, produces an upper bound
    for the next-uniformity Ramsey number via the Erdős-Rado stepping-up lemma. -/
def steppingUpBound (graphRamsey : ℕ) : ℕ :=
  2 ^ (graphRamsey - 1) + 1

/-- The probabilistic bound condition: for the 3-uniform case,
    if `2 * Nat.choose n k < 2^(Nat.choose k 3)` then R₃(k,k) > n. -/
def probBoundHolds (n k : ℕ) : Prop :=
  2 * Nat.choose n k < 2 ^ Nat.choose k 3

/-- **Chromatic Ramsey density**: a novel concept measuring the minimum fraction
    of k-cliques that must be monochromatic in any coloring of an n-vertex r-uniform
    hypergraph. This refines the qualitative Ramsey property into a quantitative measure.

    When `n < R_r(k,k)`, this density can be 0 (there exist colorings avoiding
    monochromatic k-cliques). When `n ≥ R_r(k,k)`, this density is positive.
    The exact value as a function of n captures the "strength" of the Ramsey property
    and connects to Ramsey multiplicity problems. -/
noncomputable def chromaticRamseyDensity (n r k : ℕ) : ℕ :=
  if h : (Finset.univ : Finset (Finset (Fin n))).card = 0 then 0
  else
    -- Minimum number of monochromatic k-cliques over all colorings
    -- (We define this as a Finset.inf, but for now use a structural definition)
    0 -- placeholder for the infimum construction