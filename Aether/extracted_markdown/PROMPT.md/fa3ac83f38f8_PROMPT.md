
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   Reference the specific theorems proved in Phase A using @file references.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work,
   references to catalog results. Use @file references for theorems.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
  ],
  "visualizations": [
    {"name": "descriptive_name", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Interactive Widget Title", "description": "What users can explore", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
Use the @file references above to point readers to specific theorems.


## Concept

**Title**: Tropical Compactification of Moduli Spaces
**Domain**: Novelty
**Mathematical framing**: Prove that the tropical compactification of the moduli space of curves M_g is a toric variety whose boundary divisors correspond to tropical curves. Formalize the connection between the Deligne-Mumford compactification and the tropical moduli space.
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/CanonicalKernelDefs.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Canonical Tropical Kernel — Definitions

This file introduces the foundational definitions for the canonical tropical
kernel theory, connecting harmonic functions on graph subsets to chip-firing
equivalence classes and the restricted critical group.

## Main Definitions

* `IsHarmonicOn` — a function satisfies the discrete Laplace equation on a subset
* `NormalizedOn` — a function sums to zero on a subset (mean-zero normalization)
* `SeparatedOn` — the restriction-faithfulness separation hypothesis
* `FiringEquivalentOn` — two functions differ by a Laplacian image supported on a subset
* `IsTreeAttachmentAlong` — a set T is attached to S as a tree
* `RestrictedLaplacianImage` — the image of the restricted Laplacian on S
* `harmonicKernel` — the set of harmonic functions on S

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
-/

import Mathlib
import Pythagorean.TropicalBridge.Defs

open Finset BigOperators

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ### Harmonic Functions on Subsets -/

/-- A function `f : V → ℤ` is **harmonic on** a subset `S` with respect to graph `G`
    if for every vertex `v ∈ S`, the Laplacian of `f` at `v` vanishes:
    `∑ w, L(v,w) · f(w) = 0`.
    This is the discrete analogue of harmonicity in potential theory. -/
def IsHarmonicOn
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) (f : V → ℤ) : Prop :=
  ∀ v ∈ S, ∑ w : V, graphLaplacian G v w * f w = 0

/-- A function is **normalized on** `S` if its values sum to zero over `S`:
    `∑ v ∈ S, f(v) = 0`. This removes the constant-function ambiguity
    from the harmonic kernel. -/
def NormalizedOn (S : Finset V) (f : V → ℤ) : Prop :=
  ∑ v ∈ S, f v = 0

/-- The **separation hypothesis** for `S` in `G`: if two harmonic functions on `S`
    are both normalized on `S` and agree on every vertex of `S`, then they are
    equal everywhere. This ensures that harmonic extensions from `S` are unique
    and encodes the geometric idea that `S` "sees" enough of the graph. -/
def SeparatedOn
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) : Prop :=
  ∀ ⦃f g : V → ℤ⦄,
    IsHarmonicOn G S f →
    IsHarmonicOn G S g →
    NormalizedOn S f →
    NormalizedOn S g →
    (∀ v ∈ S, f v = g v) →
    f = g

/-- Two functions are **firing-equivalent on** `S` if they differ by a
    Laplacian image of a function supported on `S`. This is the algebraic
    expression of chip-firing: `g = f + L · c` where `c` is supported on `S`. -/
def FiringEquivalentOn
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) (f g : V → ℤ) : Prop :=
  ∃ c : V → ℤ, (∀ v, v ∉ S → c v = 0) ∧
    ∀ v, g v = f v + ∑ w : V, graphLaplacian G v w * c w

/-- A subset `T` is a **tree attachment along** `S` in `G` if:
    1. `S` and `T` are disjoint,
    2. Every vertex in `T` has at most one neighbor in `S`,
    3. The induced subgraph on `T` is acyclic (forest),
    4. Every vertex in `T` has a path to `S` through `T`. -/
structure IsTreeAttachmentAlong
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S T : Finset V) : Prop where
  disjoint : Disjoint S T
  single_attachment : ∀ v ∈ T,
    ((S.filter (G.Adj v)).card ≤ 1)
  acyclic : ∀ v ∈ T, ∀ w ∈ T, v ≠ w →
    G.Adj v w →
    ¬∃ p : G.Walk v w, p.support.tail.toFinset ⊆ ↑T ∧ p.support.length > 2

/-- The **restricted Laplacian image** on `S`: the set of functions that arise
    as `L · c` for some `c` supported on `S`. This is the chip-firing lattice
    restricted to `S`. -/
def RestrictedLaplacianImage
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) : Set (V → ℤ) :=
  {h | ∃ c : V → ℤ, (∀ v, v ∉ S → c v = 0) ∧
    ∀ v, h v = ∑ w : V, graphLaplacian G v w * c w}

/-- The **harmonic kernel** on `S`: the set of all functions harmonic on `S`. -/
def harmonicKernel
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) : Set (V → ℤ) :=
  {f | IsHarmonicOn G S f}

/-- A function is **constant** if it takes a single value everywhere. -/
def IsConstant (f : V → ℤ) : Prop :=
  ∀ v w : V, f v = f w

/-- Two functions are **equivalent modulo constants** if they differ by
    a constant function. -/
def EquivModConst (f g : V → ℤ) : Prop :=
  ∃ c : ℤ, ∀ v, f v = g v + c


-- DIFF: Catalog/Bridges/CanonicalKernelTheorems.lean
--- a/Bridges/CanonicalKernelTheorems.lean
+++ b/Bridges/CanonicalKernelTheorems.lean
@@ -463,49 +463,4 @@
   simp_all +decide [ SeparatedOn ];
   refine' ⟨ fun v => f v - g v - ( ∑ v ∈ S, ( f v - g v ) ) / S.card, _, fun v => 0, _, _, _, _ ⟩ <;> simp_all +decide [ IsHarmonicOn, NormalizedOn ];
   · simp_all +decide [ mul_sub ];
-  · exact fun h => hsep.elim fun v hv => hv <| by have := congr_fun h v; norm_num at this; linarith;
-
-
--- !-- Merged from CanonicalKernelDefs.lean (auto-dedup) -- !--
-
-This file introduces the foundational definitions for the canonical tropical
-kernel theory, connecting harmonic functions on graph subsets to chip-firing
-equivalence classes and the restricted critical group.
-* `IsHarmonicOn` — a function satisfies the discrete Laplace equation on a subset
-* `NormalizedOn` — a function sums to zero on a subset (mean-zero normalization)
-* `SeparatedOn` — the restriction-faithfulness separation hypothesis
-* `FiringEquivalentOn` — two functions differ by a Laplacian image supported on a subset
-* `IsTreeAttachmentAlong` — a set T is attached to S as a tree
-* `RestrictedLaplacianImage` — the image of the restricted Laplacian on S
-* `harmonicKernel` — the set of harmonic functions on S
-* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
-import Pythagorean.TropicalBridge.Defs
-/-! ### Harmonic Functions on Subsets -/
-    if for every vertex `v ∈ S`, the Laplacian of `f` at `v` vanishes:
-    `∑ w, L(v,w) · f(w) = 0`.
-    This is the discrete analogue of harmonicity in potential theory. -/
-  ∀ v ∈ S, ∑ w : V, graphLaplacian G v w * f w = 0
-/-- A function is **normalized on** `S` if its values sum to zero over `S`:
-    `∑ v ∈ S, f(v) = 0`. This removes the constant-function ambiguity
-    from the harmonic kernel. -/
-/-- The **separation hypothesis** for `S` in `G`: if two harmonic functions on `S`
-    are both normalized on `S` and agree on every vertex of `S`, then they are
-    equal everywhere. This ensures that harmonic extensions from `S` are unique
-    and encodes the geometric idea that `S` "sees" enough of the graph. -/
-    Laplacian image of a function supported on `S`. This is the algebraic
-    expression of chip-firing: `g = f + L · c` where `c` is supported on `S`. -/
-    ∀ v, g v = f v + ∑ w : V, graphLaplacian G v w * c w
-/-- A subset `T` is a **tree attachment along** `S` in `G` if:
-    1. `S` and `T` are disjoint,
-    2. Every vertex in `T` has at most one neighbor in `S`,
-    3. The induced subgraph on `T` is acyclic (forest),
-    4. Every vertex in `T` has a path to `S` through `T`. -/
-/-- The **restricted Laplacian image** on `S`: the set of functions that arise
-    as `L · c` for some `c` supported on `S`. This is the chip-firing lattice
-    restricted to `S`. -/
-    ∀ v, h v = ∑ w : V, graphLaplacian G v w * c w}
-/-- The **harmonic kernel** on `S`: the set of all functions harmonic on `S`. -/
-/-- A function is **constant** if it takes a single value everywhere. -/
-def IsConstant (f : V → ℤ) : Prop :=
-/-- Two functions are **equivalent modulo constants** if they differ by
-    a constant function. -/+  · exact fun h => hsep.elim fun v hv => hv <| by have := congr_fun h v; norm_num at this; linarith;


-- NEW_FILE: Catalog/Bridges/KTheoryNeuralAdvanced.lean
/-
  Algebraic K-Theory of Neural Architectures — Advanced Theorems

  Bridge: extends the core K-theoretic framework with deeper results on
  projective stability, Whitehead lemma analogs, spectral ce
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Tropical Compactification of Moduli Spaces

## 1. Tropical Genus Non-Negativity and the Spanning Forest Bound

The graph genus `graphGenus G = |E| - |V| + c` should always be non-negative for any finite graph. This is equivalent to proving that every connected component on k vertices has at least k-1 edges (the spanning tree bound). The key insight is that this follows from the fact that a spanning forest of a graph with c connected components has exactly |V| - c edges, and any graph has at least as many edges as its spanning forest. Why now? We have `tree_genus_zero` and `genus_connected` proven, which establish the genus formula for trees and connected graphs. Proving non-negativity would complete the foundational theory and unlock results about tropical curve degenerations (a tropical curve of genus g degenerates to trees of genus 0 by contracting cycles).

## 2. Tropical Bellman-Ford: Matrix Powers Compute k-Step Shortest Paths

We proved the 2-step and 3-step cases (`tropical_matrix_sq_interpretation`, `tropical_matrix_cube_interpretation`). The natural conjecture is the general statement: for any n×n tropical matrix A and positive integer k, the (i,j) entry of A^k equals the minimum weight of a k-step walk from i to j. The key insight is that this should follow by induction on k using the min-plus interpretation of matrix multiplication, but formalizing "k-step walk" as a function `Fin (k+1) → Fin n` with prescribed endpoints and defining its weight requires careful dependent-type management. Why now? The 2-step and 3-step cases provide the structural template, and the min-plus interpretation theorem (`tropical_matrix_mul_minPlus`) is the inductive engine. This would give a fully verified correctness proof for the Bellman-Ford shortest path algorithm.

## 3. Tropical Determinant Achieves Its Infimum (Optimal Assignment Existence)

We defined `tropicalDet A = ⨅_σ Σ_i untrop(A_{i,σ(i)})` and showed it equals the untrop of the algebraic tropical determinant. A key conjecture is that when all entries are finite (no ⊤ entries), this infimum is achieved by some permutation σ*, giving an explicit optimal assignment. The key insight is that the symmetric group S_n is finite, so the infimum over a finite set is a minimum — but formalizing this requires showing that `⨅` over a `Fintype` equals `Finset.inf'` and extracting the witness. Why now? This connects our tropical determinant to the classical Hungarian algorithm for the assignment problem, and bridges tropical algebra to combinatorial optimization. The `Finset.exists_min_image` lemma in Mathlib should provide the key tool.

## 4. Tropical Rank and Factor Rank Separation

Define the tropical rank of a matrix A as the smallest r such that A can be written as a tropical sum (min) of r tropical rank-1 matrices (outer products in the tropical sense). Conjecture: there exist n×n tropical matrices whose tropical rank is strictly larger than n, unlike classical linear algebra where
```

## Your task

Produce the deliverables listed above. Reference the specific theorems and
results in the Lean code by their @file path and statement. The Lean file is
the source of truth — your prose must accurately explain it.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
