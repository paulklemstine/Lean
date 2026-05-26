/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Abelian Sandpile Criticality via Laplacian Energy Minimization — Definitions

This file introduces the core definitions for a variational theory of
abelian sandpile criticality. The central insight is that critical/q-reduced
configurations are uniquely characterized as **energy minimizers** in their
chip-firing equivalence classes, where energy is the discrete electrostatic
energy induced by the Laplacian.

## Main Definitions

* `graphLaplacian` — the combinatorial Laplacian matrix
* `reducedLaplacianMatrix` — the Laplacian with sink row/column deleted
* `laplacianDiv` — the Laplacian action on a firing vector (principal divisor)
* `ChipFireEquivSink` — chip-firing equivalence preserving sink value
* `laplacianRealQuadratic` — the Laplacian quadratic form x^T L x on ℝ-valued vectors
* `laplacianQuadraticInt` — the Laplacian quadratic form on ℤ-valued vectors
* `greenPairing` — the bilinear pairing f^T L^{-1} D (inner product via Green operator)
* `IsQReduced` — q-reduced divisor predicate
* `IsCriticalConfig` — critical/recurrent stable configuration predicate
* `IsVariationallyCritical` — energy-minimizer characterization of criticality

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
* Corry, S. and Perkinson, D. "Divisors and Sandpiles" (2018)
* Biggs, N. "Chip-firing and the critical group of a graph" (1999)
-/

import Mathlib

open Finset BigOperators Matrix SimpleGraph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Graph Laplacian -/

/-- The combinatorial graph Laplacian matrix.
    `L(v,v) = deg(v)`, `L(v,w) = -1` if `v ~ w`, `L(v,w) = 0` otherwise. -/
noncomputable def graphLaplacian (G : SimpleGraph V) [DecidableRel G.Adj] :
    Matrix V V ℤ :=
  fun i j =>
    if i = j then (G.degree i : ℤ)
    else if G.Adj i j then -1
    else 0

/-- The reduced Laplacian matrix: delete the row and column of the sink vertex q.
    This is an `(V \ {q}) × (V \ {q})` integer matrix. -/
noncomputable def reducedLaplacianMatrix (G : SimpleGraph V) [DecidableRel G.Adj]
    (q : V) : Matrix {v : V // v ≠ q} {v : V // v ≠ q} ℤ :=
  fun i j => graphLaplacian G i.val j.val

/-! ## Chip-Firing with Sink -/

/-- The Laplacian action on a firing vector f: computes the principal divisor (Lf).
    At each vertex v, this is `∑_w L(v,w) * f(w)`. -/
noncomputable def laplacianDiv (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : V → ℤ) : V → ℤ :=
  fun v => ∑ w : V, graphLaplacian G v w * f w

/-- Two sink-normalized divisors are chip-fire equivalent (relative to sink q)
    if they differ by a principal divisor whose firing vector vanishes at q.
    That is, D₂ = D₁ + L·f where f(q) = 0. -/
def ChipFireEquivSink (G : SimpleGraph V) [DecidableRel G.Adj]
    (q : V) (D₁ D₂ : V → ℤ) : Prop :=
  ∃ f : V → ℤ, f q = 0 ∧ ∀ v, D₂ v = D₁ v + laplacianDiv G f v

/-! ## Laplacian Quadratic Forms -/

/-- The Laplacian quadratic form on ℝ-valued vectors:
    `Q(x) = ∑_{v ~ w} (x(v) - x(w))²`
    Equivalently, `x^T L x`. This is always nonneg and zero iff x is constant
    on connected components. -/
noncomputable def laplacianRealQuadratic (G : SimpleGraph V) [DecidableRel G.Adj]
    (x : V → ℝ) : ℝ :=
  ∑ v : V, ∑ w : V, if G.Adj v w then (x v - x w) ^ 2 else 0

/-- The Laplacian quadratic form on ℤ-valued vectors:
    `Q(f) = ∑_{v ~ w} (f(v) - f(w))²`. -/
noncomputable def laplacianQuadraticInt (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : V → ℤ) : ℤ :=
  ∑ v : V, ∑ w : V, if G.Adj v w then (f v - f w) ^ 2 else 0

/-- The bilinear form associated to the Laplacian:
    `B(f, D) = ∑_v f(v) * (L·D)(v) = ∑_{v ~ w} f(v) * (D(v) - D(w))`.
    This is the "Green pairing" used in energy computations. -/
noncomputable def greenPairing (G : SimpleGraph V) [DecidableRel G.Adj]
    (f D : V → ℤ) : ℤ :=
  ∑ v : V, f v * laplacianDiv G D v

/-! ## Euclidean Norm -/

/-- The squared Euclidean norm of a real-valued vector: ∑_v x(v)². -/
noncomputable def euclideanNormSq (x : V → ℝ) : ℝ :=
  ∑ v : V, x v ^ 2

/-! ## Spectral Definitions -/

/-- Orthogonality to constants: x is orthogonal to the all-ones vector. -/
def orthogonalToConstants (x : V → ℝ) : Prop :=
  ∑ v : V, x v = 0

/-- The Fiedler value (algebraic connectivity) of a graph: the smallest eigenvalue
    of the Laplacian restricted to the orthogonal complement of constants.
    For connected graphs, this is positive and equals the second-smallest
    eigenvalue of the full Laplacian.

    We define it as an infimum over the Rayleigh quotient. -/
noncomputable def fiedlerValue (G : SimpleGraph V) [DecidableRel G.Adj] : ℝ :=
  ⨅ (x : V → ℝ) (_ : orthogonalToConstants x) (_ : euclideanNormSq x = 1),
    laplacianRealQuadratic G x

/-! ## Q-Reduced and Critical Configurations -/

/-- A divisor D is **q-reduced** if:
    1. D(q) = 0 (sink-normalized)
    2. For every nonempty subset S ⊆ V \ {q}, there exists a vertex v ∈ S
       such that D(v) < #{neighbors of v in S^c} (i.e., the number of edges
       from v leaving S). This is Dhar's burning criterion.

    Q-reduced divisors are the canonical representatives in their chip-firing class. -/
def IsQReduced (G : SimpleGraph V) [DecidableRel G.Adj] (q : V) (D : V → ℤ) : Prop :=
  D q = 0 ∧
  ∀ S : Finset V, q ∉ S → S.Nonempty →
    ∃ v ∈ S, D v < ↑((Finset.univ.filter (fun w => w ∉ S ∧ G.Adj v w)).card)

/-- A configuration c is **critical** (recurrent stable) if:
    1. c(q) = 0 (sink-normalized)
    2. For all v ≠ q: 0 ≤ c(v) < deg(v) (stable)
    3. c is q-reduced. -/
def IsCriticalConfig (G : SimpleGraph V) [DecidableRel G.Adj]
    (q : V) (D : V → ℤ) : Prop :=
  D q = 0 ∧
  (∀ v : V, v ≠ q → 0 ≤ D v ∧ D v < G.degree v) ∧
  IsQReduced G q D

/-- A sink-normalized divisor is **variationally critical** if it minimizes the
    Laplacian quadratic form in its chip-firing equivalence class.

    This is the central new concept: it characterizes criticality as an
    energy-minimization principle rather than a combinatorial burning criterion. -/
def IsVariationallyCritical (G : SimpleGraph V) [DecidableRel G.Adj]
    (q : V) (D : V → ℤ) : Prop :=
  D q = 0 ∧
  ∀ D' : V → ℤ, D' q = 0 → ChipFireEquivSink G q D D' →
    laplacianQuadraticInt G D ≤ laplacianQuadraticInt G D'

/-! ## Legal Firing -/

/-- A firing vector f is a **legal firing away from sink** for divisor D if:
    1. f(q) = 0 (sink doesn't fire)
    2. For each v: f(v) ≥ 0 (we only fire, not un-fire)
    3. After firing, each vertex that fired has enough chips. -/
def IsLegalFiringAwayFromSink (G : SimpleGraph V) [DecidableRel G.Adj]
    (q : V) (D f : V → ℤ) : Prop :=
  f q = 0 ∧
  (∀ v, 0 ≤ f v) ∧
  (∀ v, v ≠ q → f v > 0 → D v ≥ f v * G.degree v)

/-! ## Two-Point Divisor -/

/-- The two-point divisor δ_v - δ_w: places +1 at v and -1 at w. -/
def twoPointDivisor (v w : V) : V → ℤ :=
  fun u => if u = v then 1 else if u = w then -1 else 0