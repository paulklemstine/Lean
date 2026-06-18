
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **RESEARCH_PAPER.tex** (NEW) — A clean, compilable LaTeX version of
   the paper that mirrors the content of RESEARCH_PAPER.md. Use standard
   amsmath/amsart or article class, define all theorems inline, and make
   it suitable for direct PDF compilation with `pdflatex`. This is the
   publishable artifact.
4. **demo.py** — Numerical examples demonstrating the key results.
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
  "research_paper_tex": "RESEARCH_PAPER.tex",
  "demo": "demo.py",
  "demos": [
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
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
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: Diophantine Approximation on Neural Networks: How Well Can ReLU Approximate Pi?
**Domain**: Tropical
**Mathematical framing**: A ReLU network f: R -> R with L layers of width w is a piecewise linear function with at most w^L pieces. By the universal approximation theorem, such networks can approximate any continuous function. But HOW WELL can they approximate specific constants? Conjecture: a ReLU network with L layers of width w can approximate pi to within epsilon using O(w * L * log(1/epsilon)) parameters. More precisely, there exists a ReLU network f with L = O(log(log(1/epsilon))) layers and w = O(log(1/epsilon)) width such that |f(1) - pi| < epsilon. This is because pi can be computed by the Leibniz formula pi/4 = 1 - 1/3 + 1/5 - ..., and a ReLU network can implement the partial sums. The number of terms needed is O(1/epsilon), and each term can be computed by a constant-depth ReLU subnetwork. The depth needed is O(log(1/epsilon)) for the sum and O(log(log(1/epsilon))) for the individual terms. Conjecture: the approximation rate for rational numbers by ReLU networks is O(1/(w^L)), matching the piecewise linear structure. For irrational numbers like pi, the rate is O(1/(w * L * 2^L)), which is slower but still exponential in depth. Test: construct ReLU networks that approximate pi, e, and sqrt(2) and measure the approximation error as a function of network size. Impact: ReLU networks approximate constants at a rate determined by their depth and width. Pi requires O(log(log(1/epsilon))) depth.
Research domain: Tropical
Research mode: formalize


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: 0d42792c_retry3_aristotle/Catalog/Bridges/EulerianTrailParity.lean
import Mathlib

/-!
# Eulerian trails imply at most two odd-degree vertices

This file is a minimal, self-contained formalization of the classical parity
theorem for Eulerian trails on finite multigraphs.

A finite multigraph is encoded by an endpoint map `ends : Fin nE → Fin nV × Fin nV`,
sending each edge index to an *ordered* pair of vertices.  The `degree` of a vertex
is the number of edge endpoints incident to it: each edge contributes `1` for each
of its two endpoints equal to `v`, so a loop at `v` contributes `2`.

An `EulerianTrail` is a walk that uses every edge exactly once: a vertex sequence
`walk : Fin (nE+1) → Fin nV` together with a permutation `edgeAt` of the edges such
that the `i`-th step of the walk traverses edge `edgeAt i` (in either orientation).

The main results are:

* `degree_eq_walk_sum` — the degree of `v` is the sum over walk steps of the number
  of the two consecutive walk positions equal to `v`;
* `degree_add_endpoints` — a telescoping/endpoint-correction identity:
  `degree v + (start-indicator + end-indicator) = 2 * (number of walk positions = v)`;
* `even_degree_of_internal` — a vertex that is neither the start nor the end of the
  trail has even degree;
* `odd_degree_mem_endpoints` — an odd-degree vertex must be the start or the end;
* `odd_degree_vertices_le_two` — there are at most two odd-degree vertices.
-/

namespace EulerianTrailParity

open Finset

/-- A finite multigraph on `nV` vertices and `nE` edges, encoded by an endpoint map
sending each edge to an ordered pair of vertices. -/
structure Multigraph (nV nE : ℕ) where
  /-- The ordered pair of endpoints of each edge. -/
  ends : Fin nE → Fin nV × Fin nV

variable {nV nE : ℕ}

/-- The degree of a vertex `v`: the number of edge endpoints equal to `v`.
Each edge contributes the sum of two indicators (one per endpoint), so a loop at `v`
contributes `2`. -/
def degree (G : Multigraph nV nE) (v : Fin nV) : ℕ :=
  ∑ e : Fin nE,
    ((if (G.ends e).1 = v then 1 else 0) + (if (G.ends e).2 = v then 1 else 0))

/-- An Eulerian trail of `G`: a vertex sequence `walk` together with a permutation
`edgeAt` of the edges, such that the `i`-th step traverses edge `edgeAt i` between the
consecutive walk vertices (in either orientation). -/
structure EulerianTrail (G : Multigraph nV nE) where
  /-- The sequence of `nE + 1` vertices visited by the trail. -/
  walk : Fin (nE + 1) → Fin nV
  /-- The order in which the edges are traversed. -/
  edgeAt : Equiv.Perm (Fin nE)
  /-- The `i`-th step traverses edge `edgeAt i` between `walk i` and `walk (i+1)`. -/
  compat : ∀ i : Fin nE,
    G.ends (edgeAt i) = (walk i.castSucc, walk i.succ) ∨
    G.ends (edgeAt i) = (walk i.succ, walk i.castSucc)

/-
**Degree/incidence identity (A).** The degree of `v` equals the sum, over walk
steps, of the number of the two consecutive walk positions equal to `v`.
-/
theorem degree_eq_walk_sum (G : Multigraph nV nE) (et : EulerianTrail G) (v : Fin nV) :
    degree G v =
      ∑ i : Fin nE,
        ((if et.walk i.castSucc = v then 1 else 0) +
         (if et.walk i.succ = v then 1 else 0)) := by
  unfold degree;
  rw [ ← Equiv.sum_comp et.edgeAt ];
  grind +suggestions

/-
**Endpoint-correction identity.** Adding the start and end indicators to the degree
yields twice the number of walk positions equal to `v`.
-/
theorem degree_add_endpoints (G : Multigraph nV nE) (et : EulerianTrail G) (v : Fin nV) :
    degree G v +
        ((if et.walk 0 = v then 1 else 0) +
         (if et.walk (Fin.last nE) = v then 1 else 0))
      = 2 * ∑ j : Fin (nE + 1), (if et.walk j = v then 1 else 0) := by
  convert congr_arg₂ ( · + · ) ( degree_eq_walk_sum G et v ) rfl using 1;
  have := Fin.sum_univ_castSucc ( fun j => if et.walk j = v then 1 else 0 ) ; have := Fin.sum_univ_succ ( fun j => if et.walk j = v then 1 else 0 ) ; simp_all +decide [ two_mul, Finset.sum_add_distrib ] ;
  grind

/-
**(B)** A vertex that is neither the start nor the end of the trail has even degree.
-/
theorem even_degree_of_internal (G : Multigraph nV nE) (et : EulerianTrail G) (v : Fin nV)
    (h0 : v ≠ et.walk 0) (hlast : v ≠ et.walk (Fin.last nE)) : Even (degree G v) := by
  have := degree_add_endpoints G et v;
  grind

/-
**(C)** Any odd-degree vertex must be the start or the end of the trail.
-/
theorem odd_degree_mem_endpoints (G : Multigraph nV nE) (et : EulerianTrail G) (v : Fin nV)
    (h : Odd (degree G v)) : v = et.walk 0 ∨ v = et.walk (Fin.last nE) := by
  grind +suggestions

/-
**(D)** The set of odd-degree vertices has cardinality at most `2`.
-/
theorem odd_degree_vertices_le_two (G : Multigraph nV nE) (et : EulerianTrail G) :
    (Finset.univ.filter (fun v => Odd (degree G v))).card ≤ 2 := by
  exact le_trans ( Finset.card_le_card fun x hx => show x ∈ { et.walk 0, et.walk ( Fin.last nE ) } from by have := odd_degree_mem_endpoints G et x ( by aesop ) ; aesop ) ( Finset.card_insert_le _ _ ) |> le_trans <| by norm_num;

end EulerianTrailParity
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Diophantine Approximation on ReLU / Tropical Networks

Derived from this cycle's findings in
`Tropical/NeuralNetworks/DiophantineReLUPi.lean` and
`Tropical/NeuralNetworks/ReLURepresentableConstants.lean`.

This cycle established a sharp Diophantine dichotomy: a ReLU network (= tropical
rational function, via `MachineLearning.TropicalReLUBridge`) with **rational
parameters** at a **rational input** outputs exactly the rational numbers, and
nothing else; every irrational/transcendental constant (π, √2, …) is only ever a
*limit* of network values, never a value. The explicit Leibniz network reaches π
at rate `Θ(1/n)` in width.

The following conjectures are bold, falsifiable refinements.

## 1. The Leibniz rate `Θ(1/n)` is essentially optimal for *bias-only / width-linear* ReLU encodings of π.
**Statement.** For the family of width-`n` ReLU networks whose hidden units have
zero input weight (constant networks), the best achievable error
`inf |f(1) - π|` over rational parameters with total bit-complexity `B` is
`Θ(1/2^B)` but `Ω(1/poly(n))` when restricted to "small-integer" weights of size
`O(n)`; i.e. the linear-in-width Leibniz construction cannot be polynomially
beaten without large weights.
**The key insight is** that constant ReLU networks with bounded-height rational
weights can only land on rationals with bounded denominator, and the irrationality
measure of π lower-bounds how close such rationals get.
**Why now?** We already have `reLURepresentable_iff_rational` pinning the exact
image to ℚ; quantifying the *denominator* of the reachable rationals as a function
of network size is the natural next theorem, and Mathlib now has enough
continued-fraction / irrationality-measure API to attempt it.

## 2. Depth buys a doubly-exponential speedup: π to accuracy ε with depth `O(log log(1/ε))`.
**Statement.** There is a family of ReLU networks of depth `L` and width `w` with
`L = O(log log(1/ε))`, `w = O(log(1/ε))` and `|f(1) - π| < ε`, obtained by
implementing a quadratically-convergent (e.g. Gauss–Legendre / AGM) iteration
rather than the linear Leibniz sum.
**The key insight is** that ReLU layers can implement one Newton/AGM step (a few
multiplications and a square root, themselves approximable by piecewise-linear
units) per `O(1)` layers, so doubling of correct digits per constant depth gives
the `log log` depth bound.
**Why now?** This cycle proved the *linear* (`Θ(1/n)`-width) construction
rigorously; the AGM upgrade is the precise mechanism behind the concept's
"`O(log log(1/ε))` depth" claim and is the next milestone, requiring only a
formal piecewise-linear square-root gadget.

## 3. The "tropical degree" (number of linear pieces) of the best ε-approximant of π grows like `Θ(1/ε)`.
**Statement.** Any convex piecewise-linear (tropical-polynomial) `f` with
`|f - π|_{∞} < ε` on `[0,1]` (a fixed nonconstant target slope normalisation) needs
`Ω(1/√ε)` pieces, while ReLU *rational* functions need only `O(log(1/ε))`; the gap
qu
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
