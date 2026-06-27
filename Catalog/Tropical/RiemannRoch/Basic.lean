/-
Copyright (c) 2025. Released under Apache 2.0 license.

# Chip-firing and Baker–Norine divisor theory on a finite graph

This file develops the combinatorial ("tropical") theory of divisors on a finite
graph, the foundation of the Baker–Norine Riemann–Roch theorem.

## Main definitions

* `FinGraph`        — a finite loopless graph given by an integer-valued symmetric
                      adjacency (edge multiplicity) function.
* `Divisor G`       — an element of `G.V → ℤ` (a chip configuration).
* `deg D`           — the total number of chips.
* `prin f`          — the principal divisor obtained by firing with the integer
                      "firing vector" `f` (the image of the graph Laplacian).
* `LinEquiv D D'`   — linear equivalence: `D' = D + prin f` for some `f`.
* `canonical G`     — the canonical divisor `K(v) = deg(v) - 2`.
* `genus G`         — the (first Betti number) genus `|E| - |V| + 1`.

## Main results

* `deg_prin`               — every principal divisor has degree `0`
                             (chip-firing preserves the number of chips).
* `LinEquiv.deg_eq`        — linearly equivalent divisors have equal degree.
* `linEquiv_equivalence`   — `LinEquiv` is an equivalence relation.
* `even_totalEdges`        — the total degree `∑ deg(v)` is even.
* `deg_canonical`          — `deg K = 2 * genus - 2`  (the Riemann–Roch numeric shape).

-- !-- Lab Notes -- !--
Hypothesis: chip-firing is degree preserving and the canonical divisor of any
finite graph has degree `2g-2`.  Experiment: formalize firing as the Laplacian
image `prin f w = ∑ v adj(v,w)(f w - f v)` and compute degrees.  Analysis: the
degree-invariance proof is a single `Finset.sum_comm` once symmetry of `adj` is
used; the canonical-degree proof needs evenness of `∑ deg(v)`, which itself is a
symmetry/`sum_comm` fact.  Critique: definitions must be loopless and symmetric or
`deg_prin` fails; we enforce both in `FinGraph`.
-/

import Mathlib

open Finset BigOperators

namespace BakerNorine

/-- A finite loopless graph: `adj v w` is the number of edges between `v` and `w`. -/
structure FinGraph where
  V : Type
  [finV : Fintype V]
  [decV : DecidableEq V]
  adj : V → V → ℕ
  adj_symm : ∀ v w, adj v w = adj w v
  adj_loopless : ∀ v, adj v v = 0

attribute [instance] FinGraph.finV FinGraph.decV

variable (G : FinGraph)

/-- A divisor (chip configuration) on `G`. -/
abbrev Divisor : Type := G.V → ℤ

variable {G}

/-- The degree of a divisor: the total number of chips. -/
def deg (D : Divisor G) : ℤ := ∑ v, D v

/-- The (integer) vertex degree of `v`: the number of edges incident to `v`. -/
def vertexDeg (G : FinGraph) (v : G.V) : ℤ := ∑ w, (G.adj v w : ℤ)

/-- The principal divisor obtained from the firing vector `f`.  Firing vertex `v`
with multiplicity `f v` sends `adj(v,w)` chips to each neighbour `w`. -/
def prin (f : G.V → ℤ) : Divisor G := fun w => ∑ v, (G.adj v w : ℤ) * (f w - f v)

/-- Linear equivalence of divisors: `D'` is reachable from `D` by chip-firing. -/
def LinEquiv (D D' : Divisor G) : Prop := ∃ f : G.V → ℤ, D' = fun w => D w + prin f w

/-- A divisor is effective if it is everywhere non-negative. -/
def Effective (D : Divisor G) : Prop := ∀ v, 0 ≤ D v

/-- The canonical divisor `K(v) = deg(v) - 2`. -/
def canonical (G : FinGraph) : Divisor G := fun v => vertexDeg G v - 2

/-- The total degree `∑_v deg(v) = 2|E|`. -/
def totalEdges (G : FinGraph) : ℤ := ∑ v, vertexDeg G v

/-- The genus (first Betti number) `g = |E| - |V| + 1`. -/
def genus (G : FinGraph) : ℤ := totalEdges G / 2 - (Fintype.card G.V : ℤ) + 1

@[simp] lemma deg_add (D D' : Divisor G) : deg (fun v => D v + D' v) = deg D + deg D' := by
  unfold deg; rw [← Finset.sum_add_distrib]

/-
Chip-firing preserves the total number of chips: principal divisors have degree 0.
-/
theorem deg_prin (f : G.V → ℤ) : deg (prin f) = 0 := by
  unfold deg prin; simp +decide [ mul_sub ] ;
  rw [ sub_eq_zero, Finset.sum_comm ];
  exact Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by rw [ G.adj_symm ] ;

theorem LinEquiv.deg_eq {D D' : Divisor G} (h : LinEquiv D D') : deg D = deg D' := by
  obtain ⟨f, rfl⟩ := h
  simp only [deg_add, deg_prin]
  rw [ add_zero ]

/-
`prin` is additive in the firing vector.
-/
theorem prin_add (f g : G.V → ℤ) :
    prin (fun v => f v + g v) = fun w => prin f w + prin g w := by
  funext w; unfold prin; rw [← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun _ _ => by ring

theorem prin_zero : prin (0 : G.V → ℤ) = (fun _ => 0) := by
  funext w; unfold prin; simp

theorem prin_neg (f : G.V → ℤ) : prin (fun v => - f v) = fun w => - prin f w := by
  funext w; unfold prin; rw [← Finset.sum_neg_distrib]
  exact Finset.sum_congr rfl fun _ _ => by ring

theorem linEquiv_refl (D : Divisor G) : LinEquiv D D := by
  refine ⟨0, ?_⟩
  funext w; simp [prin_zero]

theorem linEquiv_symm {D D' : Divisor G} (h : LinEquiv D D') : LinEquiv D' D := by
  obtain ⟨f, rfl⟩ := h
  refine ⟨fun v => - f v, ?_⟩
  funext w
  have := congrFun (prin_neg f) w
  simp only [this]
  ring

theorem linEquiv_trans {D D' D'' : Divisor G}
    (h : LinEquiv D D') (h' : LinEquiv D' D'') : LinEquiv D D'' := by
  obtain ⟨f, rfl⟩ := h
  obtain ⟨g, rfl⟩ := h'
  refine ⟨fun v => f v + g v, ?_⟩
  funext w
  have := congrFun (prin_add f g) w
  simp only [this]
  ring

theorem linEquiv_equivalence : Equivalence (@LinEquiv G) :=
  ⟨linEquiv_refl, linEquiv_symm, linEquiv_trans⟩

/-
The total degree of a graph is even (each edge is counted twice).
-/
theorem even_totalEdges : Even (totalEdges G) := by
  obtain ⟨V, _⟩ := G;
  unfold totalEdges;
  unfold vertexDeg; simp +decide [ * ] ;
  induction' ( Finset.univ : Finset V ) using Finset.induction <;> simp_all +decide [ Finset.sum_add_distrib, parity_simps ]

/-
**Canonical degree (Riemann–Roch numeric shape).**
The canonical divisor has degree `2g - 2`.
-/
theorem deg_canonical : deg (canonical G) = 2 * genus G - 2 := by
  unfold deg genus canonical;
  simp +decide [ totalEdges, vertexDeg ];
  linarith [ Int.ediv_mul_cancel ( show 2 ∣ ∑ x : G.V, ∑ w : G.V, ( G.adj x w : ℤ ) from even_iff_two_dvd.mp ( by
                                    -- By definition of even, we need to show that there exists an integer $k$ such that $\sum_{x} \sum_{w} G.adj x w = 2k$.
                                    apply even_totalEdges ) ) ]

end BakerNorine