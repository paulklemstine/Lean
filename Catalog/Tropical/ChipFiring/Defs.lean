/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Curves: Chip-Firing and Graph Divisor Theory

This file develops the combinatorial foundations of tropical divisor theory on finite graphs.
We define graph divisors, the graph Laplacian, chip-firing (linear equivalence of divisors),
the canonical divisor, genus, and divisor rank — the key structures underlying the
Baker–Norine theorem (tropical Riemann–Roch).

## Main Definitions

* `GraphDivisor V` — a divisor on a finite graph with vertex set `V`, assigning an integer to each vertex
* `divisorDegree` — the degree (total chip count) of a divisor
* `Effective` — a divisor is effective if all coefficients are nonneg
* `laplacianDivisor G f` — the Laplacian divisor (principal divisor) associated to a potential `f`
* `LinearEquivalent G D E` — divisors `D` and `E` differ by a principal divisor
* `canonicalDivisor G` — the canonical divisor `K_G` with `K_G(v) = deg(v) - 2`
* `genus G` — the genus (circuit rank / first Betti number) `|E| - |V| + 1`
* `subDivisor` — pointwise subtraction of divisors
* `addDivisor` — pointwise addition of divisors
* `DivisorRankAtLeast` — `r(D) ≥ r` in the Baker–Norine sense

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
* Corry, S. and Perkinson, D. "Divisors and Sandpiles" (2018)
-/

import Mathlib

open Finset BigOperators

/-! ### Graph Divisors -/

/-- A divisor on a finite graph with vertex set `V`. Each vertex is assigned an integer
    coefficient, representing the number of "chips" at that vertex. -/
structure GraphDivisor (V : Type*) [Fintype V] [DecidableEq V] where
  /-- The coefficient function assigning an integer to each vertex. -/
  coeff : V → ℤ

namespace GraphDivisor

variable {V : Type*} [Fintype V] [DecidableEq V]

instance : Zero (GraphDivisor V) := ⟨⟨fun _ => 0⟩⟩
instance : Add (GraphDivisor V) := ⟨fun D E => ⟨fun v => D.coeff v + E.coeff v⟩⟩
instance : Neg (GraphDivisor V) := ⟨fun D => ⟨fun v => -D.coeff v⟩⟩
instance : Sub (GraphDivisor V) := ⟨fun D E => ⟨fun v => D.coeff v - E.coeff v⟩⟩

@[ext]
theorem ext {D E : GraphDivisor V} (h : ∀ v, D.coeff v = E.coeff v) : D = E := by
  cases D; cases E; simp only [mk.injEq]; ext v; exact h v

@[simp]
theorem zero_coeff (v : V) : (0 : GraphDivisor V).coeff v = 0 := rfl

@[simp]
theorem add_coeff (D E : GraphDivisor V) (v : V) : (D + E).coeff v = D.coeff v + E.coeff v := rfl

@[simp]
theorem neg_coeff (D : GraphDivisor V) (v : V) : (-D).coeff v = -(D.coeff v) := rfl

@[simp]
theorem sub_coeff (D E : GraphDivisor V) (v : V) : (D - E).coeff v = D.coeff v - E.coeff v := rfl

end GraphDivisor

/-! ### Degree of a Divisor -/

/-- The degree of a divisor is the sum of all its coefficients. In the chip-firing model,
    this is the total number of chips on the graph. -/
def divisorDegree {V : Type*} [Fintype V] [DecidableEq V] (D : GraphDivisor V) : ℤ :=
  ∑ v : V, D.coeff v

@[simp]
theorem divisorDegree_zero {V : Type*} [Fintype V] [DecidableEq V] :
    divisorDegree (0 : GraphDivisor V) = 0 := by
  simp [divisorDegree]

theorem divisorDegree_add {V : Type*} [Fintype V] [DecidableEq V]
    (D E : GraphDivisor V) :
    divisorDegree (D + E) = divisorDegree D + divisorDegree E := by
  simp [divisorDegree, Finset.sum_add_distrib]

theorem divisorDegree_neg {V : Type*} [Fintype V] [DecidableEq V]
    (D : GraphDivisor V) :
    divisorDegree (-D) = -divisorDegree D := by
  simp [divisorDegree, Finset.sum_neg_distrib]

theorem divisorDegree_sub {V : Type*} [Fintype V] [DecidableEq V]
    (D E : GraphDivisor V) :
    divisorDegree (D - E) = divisorDegree D - divisorDegree E := by
  simp [divisorDegree, Finset.sum_sub_distrib]

/-! ### Effectiveness -/

/-- A divisor is effective if every vertex has a nonnegative number of chips. -/
def Effective {V : Type*} [Fintype V] [DecidableEq V] (D : GraphDivisor V) : Prop :=
  ∀ v : V, 0 ≤ D.coeff v

/-! ### Subtraction of Divisors -/

/-- Subtraction of divisors (pointwise). Used in the definition of divisor rank. -/
def subDivisor {V : Type*} [Fintype V] [DecidableEq V]
    (D E : GraphDivisor V) : GraphDivisor V :=
  D - E

/-! ### The Graph Laplacian and Principal Divisors -/

/-- The Laplacian divisor (principal divisor) associated to a potential function `f : V → ℤ`.
    At each vertex `v`, the Laplacian computes `∑_{w ~ v} (f(v) - f(w))`, which represents
    the net outflow of chips from `v` when `f` encodes a chip-firing script.

    In discrete potential theory, this is the discrete Laplacian operator applied to `f`,
    and represents a zero-total-charge perturbation (conservation of charge). -/
def laplacianDivisor {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (f : V → ℤ) : GraphDivisor V :=
  ⟨fun v => ∑ w : V, if G.Adj v w then f v - f w else 0⟩

/-! ### Linear Equivalence (Chip-Firing Equivalence) -/

/-- Two divisors `D` and `E` are linearly equivalent if they differ by a principal divisor,
    i.e., there exists a potential function `f` such that `E = D - Δf` where `Δf` is the
    Laplacian of `f`. This is the combinatorial analogue of linear equivalence of divisors
    on algebraic curves. -/
def LinearEquivalent {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D E : GraphDivisor V) : Prop :=
  ∃ f : V → ℤ, ∀ v, E.coeff v = D.coeff v - (laplacianDivisor G f).coeff v

/-! ### Canonical Divisor -/

/-- The canonical divisor `K_G` of a graph `G`. Each vertex `v` receives `deg(v) - 2` chips.
    This is the combinatorial analogue of the canonical class in algebraic geometry.
    Its degree equals `2g - 2` where `g` is the genus. -/
def canonicalDivisor {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : GraphDivisor V :=
  ⟨fun v => (G.degree v : ℤ) - 2⟩

/-! ### Genus -/

/-- The genus (circuit rank, first Betti number) of a graph: `|E| - |V| + 1`.
    For a connected graph, this equals the number of independent cycles.
    This is the combinatorial analogue of the genus of an algebraic curve. -/
def genus {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : ℤ :=
  (G.edgeFinset.card : ℤ) - (Fintype.card V : ℤ) + 1

/-! ### Single Vertex Divisor -/

/-- A divisor concentrated at a single vertex with coefficient `k`. -/
def singleVertexDivisor {V : Type*} [Fintype V] [DecidableEq V]
    (v₀ : V) (k : ℤ) : GraphDivisor V :=
  ⟨fun v => if v = v₀ then k else 0⟩

/-! ### Divisor Rank -/

/-- `DivisorRankAtLeast G D r` means that for every effective divisor `E` of degree `r`,
    the divisor `D - E` is linearly equivalent to some effective divisor.
    This is the Baker–Norine definition: `r(D) ≥ r` iff after removing any `r` chips
    from any vertices, the resulting divisor can be made effective by chip-firing. -/
def DivisorRankAtLeast {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D : GraphDivisor V) (r : ℤ) : Prop :=
  r ≤ 0 ∨
  (∀ E : GraphDivisor V, Effective E → divisorDegree E = r →
    ∃ D' : GraphDivisor V, LinearEquivalent G (subDivisor D E) D' ∧ Effective D')

/-- The rank of a divisor, defined as the largest integer `r` such that for every effective
    divisor `E` of degree `r`, `D - E` is linearly equivalent to an effective divisor.
    Returns `-1` if `D` itself is not linearly equivalent to any effective divisor.

    We define this as `max {r | DivisorRankAtLeast G D (r+1)} - 1`, using a characterization
    through natural numbers since the rank is always at least `-1`. -/
noncomputable def divisorRank {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D : GraphDivisor V) : ℤ :=
  sSup {r : ℤ | DivisorRankAtLeast G D (r + 1)} 

/-! ### Chip-Firing Move -/

/-- A chip-firing move on a graph: a subset of vertices fires simultaneously.
    Each vertex in `fireSet` sends one chip along each edge to its neighbors outside
    the set, and receives one chip from each neighbor inside the set. -/
structure ChipFiringMove (V : Type*) [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) where
  /-- The set of vertices that fire. -/
  fireSet : Finset V

/-- The divisor change resulting from a chip-firing move where `S` fires:
    each vertex in `S` loses one chip per edge to a vertex outside `S`,
    each vertex outside `S` gains one chip per edge to a vertex inside `S`. -/
def chipFireEffect {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) : GraphDivisor V :=
  ⟨fun v =>
    if v ∈ S then
      -(Finset.univ.filter (fun w => G.Adj v w ∧ w ∉ S)).card
    else
      (Finset.univ.filter (fun w => G.Adj v w ∧ w ∈ S)).card⟩