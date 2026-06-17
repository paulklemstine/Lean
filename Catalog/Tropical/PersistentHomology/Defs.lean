/-
# Persistent Homology of Tropical Filtrations: Core Definitions

This file collects the basic objects used in the tropical sublevel-filtration
development:

* `TropAffineFamily` — a finite family of affine forms `fᵢ(x) = ⟨aᵢ, x⟩ + bᵢ`
  (the "tropical monomials");
* `evalAffine` — evaluation of a single affine form (an affine, hence convex
  and concave, function of `x`);
* `tropMaxVal` / `tropMinVal` — the tropical (max-plus / min-plus) polynomial
  obtained as the finite supremum / infimum of the affine forms;
* `MaxSublevelSet` / `MinSublevelSet` — the sublevel sets of these polynomials;
* `HalfspacePatch` / `PatchIntersection` — the individual halfspaces and their
  intersections that decompose the sublevel sets;
* `PatchNerveFaces`, `nerveVertexCount`, `NerveConstantOn`, `BarcodeCritical` —
  the combinatorial nerve data of the filtration.

The theorems about these objects (convexity, contractibility, monotonicity,
finiteness) live in `Tropical.PersistentHomology.Theorems`.
-/

import Mathlib

open Finset BigOperators Classical Set

noncomputable section

namespace TropicalPersistence

variable {n m : ℕ}

/-- A finite family of `m` affine forms on `ℝⁿ`.  Form `i` is
`fᵢ(x) = (∑ j, coeff i j * x j) + bias i`. -/
structure TropAffineFamily (n m : ℕ) where
  /-- Linear coefficients of each affine form. -/
  coeff : Fin m → Fin n → ℝ
  /-- Constant (bias) term of each affine form. -/
  bias : Fin m → ℝ

/-- Evaluation of the `i`-th affine form at a point `x`. -/
def evalAffine (F : TropAffineFamily n m) (i : Fin m) (x : Fin n → ℝ) : ℝ :=
  (∑ j, F.coeff i j * x j) + F.bias i

/-- Nonemptiness of the index `Finset` when there is at least one form. -/
theorem univ_fin_nonempty (hm : 0 < m) : (Finset.univ : Finset (Fin m)).Nonempty :=
  haveI : Nonempty (Fin m) := ⟨⟨0, hm⟩⟩
  Finset.univ_nonempty

/-- The tropical (max-plus) polynomial: the pointwise maximum of the affine
forms in the family. -/
def tropMaxVal (F : TropAffineFamily n m) (hm : 0 < m) (x : Fin n → ℝ) : ℝ :=
  (Finset.univ : Finset (Fin m)).sup' (univ_fin_nonempty hm) (fun i => evalAffine F i x)

/-- The tropical (min-plus) polynomial: the pointwise minimum of the affine
forms in the family. -/
def tropMinVal (F : TropAffineFamily n m) (hm : 0 < m) (x : Fin n → ℝ) : ℝ :=
  (Finset.univ : Finset (Fin m)).inf' (univ_fin_nonempty hm) (fun i => evalAffine F i x)

/-- The sublevel set of the tropical max polynomial at threshold `c`. -/
def MaxSublevelSet (F : TropAffineFamily n m) (hm : 0 < m) (c : ℝ) : Set (Fin n → ℝ) :=
  {x | tropMaxVal F hm x ≤ c}

/-- The sublevel set of the tropical min polynomial at threshold `c`. -/
def MinSublevelSet (F : TropAffineFamily n m) (hm : 0 < m) (c : ℝ) : Set (Fin n → ℝ) :=
  {x | tropMinVal F hm x ≤ c}

/-- The halfspace `{x | fᵢ(x) ≤ c}` cut out by the `i`-th affine form. -/
def HalfspacePatch (F : TropAffineFamily n m) (c : ℝ) (i : Fin m) : Set (Fin n → ℝ) :=
  {x | evalAffine F i x ≤ c}

/-- The intersection of the halfspace patches indexed by `S`. -/
def PatchIntersection (F : TropAffineFamily n m) (c : ℝ) (S : Finset (Fin m)) :
    Set (Fin n → ℝ) :=
  ⋂ i ∈ S, HalfspacePatch F c i

/-- The faces of the patch nerve at threshold `c`: the nonempty index sets `S`
whose patch intersection is nonempty. -/
def PatchNerveFaces (F : TropAffineFamily n m) (c : ℝ) : Set (Finset (Fin m)) :=
  {S | S.Nonempty ∧ (PatchIntersection F c S).Nonempty}

/-- The number of vertices (singleton faces) of the patch nerve at threshold
`c`: the number of forms whose halfspace patch is nonempty. -/
def nerveVertexCount (F : TropAffineFamily n m) (c : ℝ) : ℕ :=
  (Finset.univ.filter (fun i => (HalfspacePatch F c i).Nonempty)).card

/-- The nerve is constant on `[a, b]` if its faces agree with those at `a`
throughout the interval. -/
def NerveConstantOn (F : TropAffineFamily n m) (a b : ℝ) : Prop :=
  ∀ c, a ≤ c → c ≤ b → PatchNerveFaces F c = PatchNerveFaces F a

/-- A threshold `c` is barcode-critical if the nerve is not constant on any
symmetric neighborhood of `c`. -/
def BarcodeCritical (F : TropAffineFamily n m) (c : ℝ) : Prop :=
  ¬ ∃ ε > 0, NerveConstantOn F (c - ε) (c + ε)

end TropicalPersistence

end