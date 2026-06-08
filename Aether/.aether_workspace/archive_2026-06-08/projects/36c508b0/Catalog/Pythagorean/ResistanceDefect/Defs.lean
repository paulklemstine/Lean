/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Effective Resistance and Tropical Rank Defect — Definitions

This file introduces the foundational definitions for a new theory bridging
**effective resistance** (discrete potential theory), **chip-firing rank**
(tropical divisor theory), and **tropical linear algebra** on finite graphs.

## Overview

The central object is the **tropical rank defect**:
  Δ(G, q, S) := (tropRank(L_S) - 1) - r(D_S)

which measures the gap between the tropical linear-algebraic complexity of the
Laplacian principal minor L_S and the chip-firing realizability of the associated
rooted subset divisor D_S.

## Main Definitions

* `resistanceDiam` — resistance diameter of a vertex subset
* `dirichletEnergy` — discrete Dirichlet energy of a potential function
* `commuteTimeDiam` — commute time diameter via the classical 2|E|·R_eff bridge
* `tropicalRankDefect` — the gap between tropical rank and chip-firing rank
* `divDeg` — degree (total mass) of a divisor D : V → ℤ
* `divEffective` — effectiveness predicate for divisors
* `chipFireLap` — Laplacian divisor (principal divisor) of a potential
* `chipFireEquiv` — linear equivalence of divisors under chip-firing
* `cfRankAtLeast` — Baker–Norine divisor rank predicate
* `rootedDiv` — canonical degree-zero divisor from a rooted subset (q, S)

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
* Develin, Santos, Sturmfels, "On the rank of a tropical matrix" (2005)
* Lyons, R. and Peres, Y. "Probability on Trees and Networks" (2016)
-/

import Mathlib

open Finset BigOperators

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Part 1: Resistance Geometry

Effective resistance R_eff(u,v) is the voltage drop per unit current between
vertices u and v in an electrical network. It can be characterized variationally:

  R_eff(u,v) = inf { E(φ) : φ(u) - φ(v) = 1 }

where E(φ) is the Dirichlet energy. We work with an abstract resistance function
satisfying the standard axioms.
-/

/-- Axioms for an effective resistance function on a graph.

An effective resistance function assigns a nonnegative real number to each
pair of vertices, satisfying symmetry and the identity R(v,v) = 0.
The full theory requires the triangle inequality and Rayleigh monotonicity,
but these basic axioms suffice for the resistance diameter theory. -/
structure ResistanceAxioms (V : Type*) where
  /-- The resistance function -/
  R : V → V → ℝ
  /-- Resistance is nonnegative -/
  nonneg : ∀ u v, 0 ≤ R u v
  /-- Resistance is symmetric -/
  symm : ∀ u v, R u v = R v u
  /-- Self-resistance is zero -/
  self_zero : ∀ v, R v v = 0

/-- The **resistance diameter** of a vertex subset T: the maximum pairwise
effective resistance among vertices in T.

This is the central geometric observable connecting discrete potential theory
to tropical rank defect. Large resistance diameter implies that the vertices
in T are "electrically far apart," making chip transport energetically expensive.

When T is empty, the diameter is defined to be 0. -/
noncomputable def resistanceDiam (R : V → V → ℝ) (T : Finset V) : ℝ :=
  if h : T.Nonempty then
    (T ×ˢ T).sup' (Finset.Nonempty.product h h) (fun p => R p.1 p.2)
  else 0

/-- The **resistance spread** from a root q to vertices in S:
the maximum resistance from q to any vertex in S.

This captures how "far" the subset S is from the root in the
resistance metric, which governs the energy cost of chip transport. -/
noncomputable def resistanceSpread (R : V → V → ℝ) (q : V) (S : Finset V) : ℝ :=
  if h : S.Nonempty then
    S.sup' h (fun v => R q v)
  else 0

/-! ## Part 2: Dirichlet Energy

The discrete Dirichlet energy is the fundamental energy functional in
discrete potential theory. It measures the total "gradient squared" of
a potential function on the graph.
-/

/-- The **discrete Dirichlet energy** of a potential function φ on a graph G.

Defined as ∑_{i,j : V} [i ~ j] · (φ(i) - φ(j))², this counts each edge
twice (once in each direction). The energy is always nonnegative as a sum
of squares, and equals zero iff φ is constant on each connected component.

In the electrical network interpretation, this is the power dissipated
when voltage profile φ is applied to the network. -/
noncomputable def dirichletEnergy (G : SimpleGraph V) [DecidableRel G.Adj]
    (φ : V → ℝ) : ℝ :=
  ∑ i : V, ∑ j : V, if G.Adj i j then (φ i - φ j) ^ 2 else 0

/-! ## Part 3: Commute Time Bridge

The classical bridge between random walks and electrical networks:
  commute_time(u,v) = 2|E| · R_eff(u,v)

This connects the resistance diameter to dynamical properties of
random walks on the graph.
-/

/-- The **commute time diameter**: maximum expected round-trip time for
a random walk between any pair of vertices in T.

By the commute time identity C(u,v) = 2|E| · R_eff(u,v), this equals
2|E| times the resistance diameter. -/
noncomputable def commuteTimeDiam (G : SimpleGraph V) [DecidableRel G.Adj]
    (R : V → V → ℝ) (T : Finset V) : ℝ :=
  2 * (G.edgeFinset.card : ℝ) * resistanceDiam R T

/-! ## Part 4: Chip-Firing Theory (Self-contained)

We redefine the essential chip-firing theory here for self-containment,
using `V → ℤ` as divisors for simplicity.
-/

/-- The **degree** of a divisor: the total number of chips on the graph. -/
def divDeg (D : V → ℤ) : ℤ := ∑ v : V, D v

/-- A divisor is **effective** if every vertex has nonneg coefficient. -/
def divEffective (D : V → ℤ) : Prop := ∀ v : V, 0 ≤ D v

/-- The **Laplacian divisor** (principal divisor) of a potential function f.
At each vertex v, this computes ∑_{w ~ v} (f(v) - f(w)), representing
the net outflow when f encodes a chip-firing script.

This is the discrete Laplacian operator applied to f. The key property
is that it has degree zero (conservation of charge). -/
def chipFireLap (G : SimpleGraph V) [DecidableRel G.Adj] (f : V → ℤ) : V → ℤ :=
  fun v => ∑ w : V, if G.Adj v w then f v - f w else 0

/-- Two divisors are **linearly equivalent** (chip-fire equivalent) if they
differ by a Laplacian divisor. This is the fundamental equivalence relation
in tropical divisor theory. -/
def chipFireEquiv (G : SimpleGraph V) [DecidableRel G.Adj]
    (D E : V → ℤ) : Prop :=
  ∃ f : V → ℤ, ∀ v, E v = D v - chipFireLap G f v

/-- **Divisor rank** predicate: `cfRankAtLeast G D r` means that r(D) ≥ r
in the Baker–Norine sense.

When r ≤ 0, this is vacuously true.
When r ≥ 1, it asserts that for every effective divisor E of degree r,
the divisor D - E can be made effective by chip-firing. -/
def cfRankAtLeast (G : SimpleGraph V) [DecidableRel G.Adj]
    (D : V → ℤ) (r : ℤ) : Prop :=
  r ≤ 0 ∨
  (∀ E : V → ℤ, divEffective E → divDeg E = r →
    ∃ D' : V → ℤ, chipFireEquiv G (fun v => D v - E v) D' ∧ divEffective D')

/-- The **rooted subset divisor** D_S: places 1 chip on each vertex in S,
removes |S| chips from the root q, and assigns 0 elsewhere.

This is the canonical degree-zero divisor associated to a rooted subset (q, S),
bridging the combinatorial structure of subsets to tropical divisor theory. -/
def rootedDiv (q : V) (S : Finset V) : V → ℤ :=
  fun v => if v ∈ S then 1 else if v = q then -(S.card : ℤ) else 0

/-! ## Part 5: Tropical Rank Defect

The tropical rank defect is the central invariant of this theory.
It measures the gap between tropical linear-algebraic complexity
(captured by the tropical rank of the Laplacian principal minor L_S)
and chip-firing realizability (captured by the chip-firing rank r(D_S)).
-/

/-- The **tropical rank defect**: the gap between tropical rank and chip-firing rank.

  Δ = (tropRank - 1) - chipRank

When tropRank is large (the Laplacian minor has high tropical complexity)
and chipRank is small (the divisor has limited chip-firing flexibility),
the defect is large, indicating a fundamental mismatch between
linear-algebraic and divisorial structure. -/
def tropicalRankDefect (tropRank : ℕ) (chipRank : ℤ) : ℤ :=
  (tropRank : ℤ) - 1 - chipRank

/-- A **single-vertex divisor**: places k chips at vertex v₀ and 0 elsewhere.
Used to construct witnesses in the rank ≤ degree argument. -/
def singleVertexDiv (v₀ : V) (k : ℤ) : V → ℤ :=
  fun v => if v = v₀ then k else 0