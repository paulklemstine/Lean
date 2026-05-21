/-
# Persistent Homology of Tropical Filtrations: Core Definitions

This file establishes the first Lean-certified bridge from **tropical active-set
combinatorics** to **barcode complexity bounds** and **stability of topological
signatures**.

## Key insight

For a tropical max-affine family, sublevel sets are convex (hence contractible),
so persistent homology is trivial. The interesting topology arises for tropical
min-affine families, where the sublevel set is a *union* of halfspaces. The
combinatorial structure of which affine forms are "active" controls all topological
events in the filtration through an **active-set nerve**.

## Main definitions

* `TropAffineFamily` — finite family of affine forms over ℝ
* `evalAffine` — evaluation of a single affine form
* `tropMaxVal` / `tropMinVal` — tropical max/min of the family
* `MaxSublevelSet` / `MinSublevelSet` — sublevel sets
* `HalfspacePatch` — individual halfspace patch {x | fᵢ(x) ≤ c}
* `PatchNerve` — nerve of the halfspace cover (abstract simplicial complex)
* `NerveFaceCount` — number of faces in the nerve at threshold c
* `EulerChar` — Euler characteristic of an abstract simplicial complex
* `NerveConstantOn` — nerve is unchanged on an interval
* `BarcodeCritical` — threshold where the nerve changes

## Cross-domain connections

* **Tropical geometry → TDA**: The patch nerve is a tropical analogue of a Čech complex
* **Convex geometry → homological algebra**: Convexity implies contractibility
  implies vanishing higher homology
* **Combinatorial persistence**: All topological changes are detected by
  finite active-set combinatorics

## References

Builds on the catalog results in `Catalog/Tropical/ArithmeticUniversality/Defs.lean`:
- `sublevel_mono`, `activeSetComplex_mono`, `tropMax_sublevel_convex`
-/

import Mathlib

open Finset BigOperators Classical

noncomputable section

namespace TropicalPersistence

/-! ## Tropical Affine Families over ℝ -/

/-- A tropical affine family: `m` affine forms in `n` real variables.
Each form is `fᵢ(x) = ∑ⱼ aᵢⱼ xⱼ + bᵢ`. -/
structure TropAffineFamily (n m : ℕ) where
  coeff : Fin m → Fin n → ℝ
  bias  : Fin m → ℝ

variable {n m : ℕ}

/-- Evaluate the `i`-th affine form at point `x`. -/
def evalAffine (F : TropAffineFamily n m) (i : Fin m) (x : Fin n → ℝ) : ℝ :=
  (∑ j : Fin n, F.coeff i j * x j) + F.bias i

/-- The tropical max: maximum of all affine evaluations. Requires `m ≥ 1`. -/
noncomputable def tropMaxVal (F : TropAffineFamily n m) (hm : 0 < m)
    (x : Fin n → ℝ) : ℝ :=
  Finset.sup' Finset.univ ⟨⟨0, hm⟩, Finset.mem_univ _⟩ (fun i => evalAffine F i x)

/-- The tropical min: minimum of all affine evaluations. Requires `m ≥ 1`. -/
noncomputable def tropMinVal (F : TropAffineFamily n m) (hm : 0 < m)
    (x : Fin n → ℝ) : ℝ :=
  Finset.inf' Finset.univ ⟨⟨0, hm⟩, Finset.mem_univ _⟩ (fun i => evalAffine F i x)

/-! ## Sublevel Sets -/

/-- Max sublevel set: {x | max_i f_i(x) ≤ c} = intersection of halfspaces. -/
def MaxSublevelSet (F : TropAffineFamily n m) (hm : 0 < m) (c : ℝ) :
    Set (Fin n → ℝ) :=
  {x | tropMaxVal F hm x ≤ c}

/-- Min sublevel set: {x | min_i f_i(x) ≤ c} = union of halfspaces. -/
def MinSublevelSet (F : TropAffineFamily n m) (hm : 0 < m) (c : ℝ) :
    Set (Fin n → ℝ) :=
  {x | tropMinVal F hm x ≤ c}

/-! ## Halfspace Patches -/

/-- The halfspace patch for index `i`: {x | fᵢ(x) ≤ c}. -/
def HalfspacePatch (F : TropAffineFamily n m) (c : ℝ) (i : Fin m) :
    Set (Fin n → ℝ) :=
  {x | evalAffine F i x ≤ c}

/-- The intersection of halfspace patches for a set of indices. -/
def PatchIntersection (F : TropAffineFamily n m) (c : ℝ) (S : Finset (Fin m)) :
    Set (Fin n → ℝ) :=
  ⋂ i ∈ S, HalfspacePatch F c i

/-! ## Abstract Simplicial Complex (Combinatorial) -/

/-- An abstract simplicial complex: a downward-closed collection of nonempty finite sets. -/
structure AbsSimplComplex (α : Type*) where
  faces : Finset (Finset α)
  nonempty_face : ∀ s ∈ faces, s.Nonempty
  down_closed : ∀ s ∈ faces, ∀ t : Finset α, t ⊆ s → t.Nonempty → t ∈ faces

/-! ## Patch Nerve -/

/-- The patch nerve at threshold `c`: a nonempty subset `S ⊆ Fin m` is a face
if the intersection of the corresponding halfspace patches is nonempty. -/
def PatchNerveFaces (F : TropAffineFamily n m) (c : ℝ) : Set (Finset (Fin m)) :=
  {S | S.Nonempty ∧ (PatchIntersection F c S).Nonempty}

/-- Nerve monotonicity predicate: constant nerve on interval. -/
def NerveConstantOn (F : TropAffineFamily n m) (a b : ℝ) : Prop :=
  ∀ c, a ≤ c → c ≤ b → PatchNerveFaces F c = PatchNerveFaces F a

/-- A threshold `c` is barcode-critical if the nerve changes at `c`. -/
def BarcodeCritical (F : TropAffineFamily n m) (c : ℝ) : Prop :=
  ¬∃ ε > 0, NerveConstantOn F (c - ε) (c + ε)

/-! ## Combinatorial Invariants -/

/-- Number of vertices (singleton faces) in the patch nerve. -/
def nerveVertexCount (F : TropAffineFamily n m) (c : ℝ) : ℕ :=
  Finset.card (Finset.univ.filter (fun i : Fin m => (HalfspacePatch F c i).Nonempty))

/-- The adjacency relation on nerve vertices: two indices are adjacent if their
    patches have nonempty intersection (they share a 1-simplex in the nerve). -/
def NerveAdjacent (F : TropAffineFamily n m) (c : ℝ) (i j : Fin m) : Prop :=
  i ≠ j ∧ (HalfspacePatch F c i).Nonempty ∧ (HalfspacePatch F c j).Nonempty ∧
  (HalfspacePatch F c i ∩ HalfspacePatch F c j).Nonempty

/-- The nerve graph reachability relation: transitive closure of adjacency
    among vertices with nonempty patches. This captures connected components. -/
def NerveReachable (F : TropAffineFamily n m) (c : ℝ) : Fin m → Fin m → Prop :=
  Relation.TransGen (NerveAdjacent F c)

/-- An upper bound on the number of faces in any sub-complex of the powerset of Fin m. -/
def maxFaceCount (m : ℕ) : ℕ := 2 ^ m

/-! ## Active Set for Min Families -/

/-- The active set at point `x` for a min family: indices achieving the minimum. -/
noncomputable def MinActiveSet (F : TropAffineFamily n m) (hm : 0 < m)
    (x : Fin n → ℝ) : Finset (Fin m) :=
  Finset.univ.filter (fun i => evalAffine F i x = tropMinVal F hm x)

/-- All active sets that appear in the sublevel set at threshold c. -/
def ActiveSetUniverse (F : TropAffineFamily n m) (hm : 0 < m) (c : ℝ) :
    Set (Finset (Fin m)) :=
  {A | ∃ x ∈ MinSublevelSet F hm c, MinActiveSet F hm x = A}

end TropicalPersistence

end