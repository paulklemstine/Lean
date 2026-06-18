## Assignment: **Hypothesis:** The planar tropical Bézout formalization can be extended to a certified tropical Bernstein theorem where stable intersection multiplicity equals mixed area of Newton polygons for all generic bivariate tropical polynomials, including sparse systems.

Prove new, non-trivial theorems in Lean 4. Build directly on the existing planar tropical Bézout / stable intersection infrastructure in the catalog rather than re-formalizing basic tropical plane-curve facts. Minimize `sorry` by isolating the genuinely new convex-geometric core into reusable lemmas.

This is not an incremental extension. A successful formalization would create the first machine-checked bridge between tropical intersection theory and lattice mixed-volume geometry in dimension 2. That bridge is the gateway to certified sparse elimination, tropical root counting, and eventually a formal tropical proof skeleton for BKK theory over valued fields.

---

# Research Direction: Tropical Bernstein Theorem in Lean

## Breakthrough target

Formalize and prove a certified **2-dimensional tropical Bernstein theorem**:

> For generic bivariate tropical polynomials `f, g`, the total stable intersection multiplicity of their tropical plane curves equals the mixed area of their Newton polygons.

This is the theorem that turns tropical geometry from a local balancing calculus into a global sparse-counting machine. In formal terms, it upgrades planar tropical Bézout from the homogeneous / degree-only regime to the sparse regime where the combinatorics of supports matter.

The revolutionary significance is immediate:

- it opens a formal path to **sparse algebraic root counting** via tropicalization,
- it provides a certified interface between **convex lattice geometry** and **tropical intersection theory**,
- it creates reusable infrastructure for future formalizations of **BKK theory**, **secondary polytopes**, and **valuated matroids**,
- it enables algorithmic certification for sparse systems where classical degree bounds are wildly non-sharp.

Application keywords: `tropical geometry`, `Bernstein-Kushnirenko-Khovanskii`, `mixed area`, `Newton polygon`, `stable intersection`, `sparse elimination`, `lattice polygons`, `Pick theorem`, `p-adic root counting`, `valuated matroids`, `certified computation`.

---

## Precise theorem statement

Work first in the planar, finite-support, generic case.

Let:
- `A B : Finset (ℤ × ℤ)` be finite supports,
- `P := latticeConvexHull A`, `Q := latticeConvexHull B`,
- `f g` be tropical polynomials with supports exactly `A` and `B`,
- `TropCurve f`, `TropCurve g` be their tropical hypersurfaces in `ℝ²`,
- `stableIntersectionMultiplicity f g` be the total multiplicity of the stable intersection,
- `mixedArea P Q` be the normalized mixed area of the convex lattice polygons.

Then the target theorem should read mathematically as:

\[
\forall A\,B\,f\,g,\;
\mathrm{GenericSupports}(f,g,A,B)
\to
\mathrm{Supp}(f)=A
\to
\mathrm{Supp}(g)=B
\to
\mathrm{TotalStableIntersectionMultiplicity}(\mathrm{TropCurve}(f),\mathrm{TropCurve}(g))
=
\mathrm{MixedArea}(\mathrm{ConvHull}(A),\mathrm{ConvHull}(B)).
\]

A more implementation-friendly equivalent statement is:

\[
\sum_{p \in \mathrm{StableIntersections}(f,g)}
m_p(f,g)
=
\operatorname{Area}(P+Q)-\operatorname{Area}(P)-\operatorname{Area}(Q),
\]
with normalized lattice area conventions chosen so the RHS is integral.

### Lean 4 target signature

You will likely need an incremental hierarchy, but the flagship theorem should look approximately like:

```lean
theorem tropical_bernstein_planar
    (A B : Finset (ℤ × ℤ))
    (f g : TropicalPolynomial2 ℤ)
    (hA : f.support = A)
    (hB : g.support = B)
    (hgen : GenericPair f g) :
    totalStableIntersectionMultiplicity (tropCurve f) (tropCurve g)
      =
    mixedArea
      (latticeConvexHull (A : Set (ℤ × ℤ)))
      (latticeConvexHull (B : Set (ℤ × ℤ))) := by
```

If the current library prefers finite polygon data structures over `Set`, an even better computable formulation is:

```lean
theorem tropical_bernstein_planar_polygon
    (P Q : LatticePolygon)
    (f g : TropicalPolynomial2 ℤ)
    (hP : newtonPolygon f = P)
    (hQ : newtonPolygon g = Q)
    (hgen : GenericPair f g) :
    totalStableIntersectionMultiplicity (tropCurve f) (tropCurve g)
      = mixedArea P Q := by
```

You should also aim to prove the structural identity behind the theorem:

```lean
theorem mixedArea_eq_area_minkowski
    (P Q : LatticePolygon) :
    mixedArea P Q
      = normalizedArea (minkowskiSum P Q)
        - normalizedArea P
        - normalizedArea Q := by
```

and, if possible, the lattice form:

```lean
theorem mixedArea_eq_mixedLatticeIndex
    (P Q : LatticePolygon) :
    mixedArea P Q = mixedLatticeIndex P Q := by
```

This last theorem is strategically important because it connects geometric area to combinatorial multiplicity data and could become the hinge for later valuated-matroid formulations.

---

## Core subtheorems to target

### 1. Mixed area from normalized area of Minkowski sums
This is the convex-geometric engine.

```lean
theorem normalizedArea_minkowski_bilinear
    (P Q : LatticePolygon) :
    normalizedArea (minkowskiSum P Q)
      = normalizedArea P + normalizedArea Q + mixedArea P Q := by
```

### 2. Stable intersection multiplicity as dual cell area sum
This is the tropical-geometric engine.

```lean
theorem totalStableIntersectionMultiplicity_eq_dual_subdivision_sum
    (f g : TropicalPolynomial2 ℤ)
    (hgen : GenericPair f g) :
    totalStableIntersectionMultiplicity (tropCurve f) (tropCurve g)
      =
    ∑ c in dualMixedCells f g, normalizedArea c := by
```

### 3. Dual mixed-cell sum equals mixed area of Newton polygons
This is the bridge theorem.

```lean
theorem dualMixedCellSum_eq_mixedArea
    (f g : TropicalPolynomial2 ℤ)
    (hgen : GenericPair f g) :
    (∑ c in dualMixedCells f g, normalizedArea c)
      =
    mixedArea (newtonPolygon f) (newtonPolygon g) := by
```

Composing 2 and 3 yields the main theorem.

---

## Proof strategy architecture

## Strategy A: Dual subdivision route via mixed cells
**Most promising.** It matches the tropical geometry already likely present in the catalog and isolates the new work in combinatorial convex geometry.

### Step A1: Formalize regular subdivisions and dual mixed cells
Use the coefficient-induced lower hull / Newton subdivision correspondence for tropical polynomials in two variables. For a generic pair, each stable intersection point should correspond to a mixed cell in the common refinement of dual subdivisions.

Goal:
- define `dualMixedCells f g : Finset LatticePolygon`,
- show each local stable intersection multiplicity equals the normalized area of its dual mixed cell.

### Step A2: Sum local multiplicities over all stable intersection points
Prove that in the generic transverse case the total multiplicity is exactly the sum of the mixed-cell areas.

This should build on any catalog theorem already expressing local multiplicity by determinant / primitive direction vectors. The key identity is that the determinant multiplicity at a vertex equals the area of the dual parallelogram or mixed cell.

### Step A3: Identify the mixed-cell area sum with the mixed area of `Newt(f), Newt(g)`
This is the genuinely new theorem. Show that the mixed cells partition the mixed part of the Minkowski subdivision of `P + Q`, so the total normalized area equals `mixedArea P Q`.

Why this strategy is best:
- it mirrors standard tropical proofs,
- it uses local multiplicity formulas already likely formalized,
- it keeps genericity assumptions explicit and manageable,
- it yields computational corollaries immediately.

---

## Strategy B: Pick-theorem reduction and edge-length formula
This is more arithmetic and may be easier if polygon infrastructure is stronger than subdivision infrastructure.

### Step B1: Prove a lattice mixed-area formula from Pick’s theorem
Using
\[
\operatorname{Area}(R)=I(R)+\frac{B(R)}{2}-1,
\]
derive a computable formula for mixed area in terms of lattice boundary contributions and interior-point counts of `P`, `Q`, and `P+Q`.

### Step B2: Express tropical stable intersection multiplicity through edge-direction combinatorics
For generic curves, total multiplicity can often be rewritten as a sum over pairs of edges:
\[
\sum | \det(u_i,v_j) | \cdot w_i \cdot w_j
\]
with primitive directions `u_i, v_j` and edge weights. Prove this equals the same combinatorial quantity as the mixed-area formula.

### Step B3: Match both sides via balancing and Newton boundary duality
Use the correspondence between tropical edge weights/directions and Newton polygon edge lengths / outer normals.

Why this is valuable:
- it may avoid heavy regular-subdivision formalization,
- it yields explicit algorithms,
- it naturally supports testing on rectangles, trapezoids, and non-simplex sparse supports.

Risk:
- bookkeeping with cyclic edge orderings, primitive normals, and gcd-normalized boundary lengths may become technically painful.

---

## Strategy C: Valuated matroid shadow of the planar theorem
This is the boldest path and could create a new formal abstraction layer.

### Step C1: Encode tropical curves via valuated matroid data of regular subdivisions
For rank-2 / rank-3 cases, represent the combinatorics of tropical line/conic intersections through valuated matroid intersection data.

### Step C2: Prove that local multiplicity is the weight of a matroid intersection cell
This reframes multiplicity as an algebraic-combinatorial invariant rather than a geometric determinant.

### Step C3: Show that the total weight equals mixed area in the planar polygon case
This would produce a theorem connecting mixed area, tropical intersection, and valuated matroid intersection.

Why it matters:
- if successful, this is not just a proof but a conceptual unification,
- it opens a route to higher-dimensional and non-complete-intersection tropical intersection theory.

Risk:
- likely too ambitious for the first full Lean proof unless the catalog already contains matroid infrastructure close to tropical use.

Recommendation:
- pursue Strategy A as the main line,
- use Strategy B to derive computable corollaries,
- keep Strategy C as a parallel conceptual layer for FUTURE_DIRECTIONS.

---

## Specific mathematical building blocks to extract from the catalog

You should explicitly reuse any existing theorems in the catalog about:

- planar tropical Bézout,
- local stable intersection multiplicity via determinant of primitive direction vectors,
- balancing condition for tropical plane curves,
- Newton polygon duality,
- lattice polygon area / Pick’s theorem,
- convex hulls or polygon triangulations,
- Minkowski sums of finite sets / polygons.

Do not merely cite them; make them serve the proof:

- If the catalog has a theorem computing local multiplicity as `NatAbs (det u v) * w₁ * w₂`, use it to identify local multiplicity with normalized area of the dual mixed cell.
- If there is already a certified Bézout theorem for degree `d₁,d₂`, recover it as the special case where `P = d₁·Δ₂` and `Q = d₂·Δ₂`, so that `mixedArea P Q = d₁ d₂`.
- If a Pick-style theorem exists, use it to make `mixedArea` computable on arbitrary lattice polygons and to prove integrality automatically.

This recovery of classical Bézout as the simplex-specialization is essential: it demonstrates that Bernstein is the sparse master theorem and Bézout is merely its homogeneous shadow.

---

## Concrete formalization milestones

### Milestone 1: Computable lattice polygons
Define or strengthen:
- `LatticePoint := ℤ × ℤ`
- `LatticePolygon`
- `normalizedArea : LatticePolygon → ℤ`
- `minkowskiSum : LatticePolygon → LatticePolygon → LatticePolygon`
- `latticeConvexHull : Set LatticePoint → LatticePolygon`

Need canonical theorems:
```lean
theorem normalizedArea_nonneg (P : LatticePolygon) : 0 ≤ normalizedArea P
theorem minkowskiSum_comm (P Q : LatticePolygon) : minkowskiSum P Q = minkowskiSum Q P
theorem minkowskiSum_assoc (P Q R : LatticePolygon) :
  minkowskiSum (minkowskiSum P Q) R = minkowskiSum P (minkowskiSum Q R)
```

### Milestone 2: Mixed area as an integer-valued invariant
Define:
```lean
def mixedArea (P Q : LatticePolygon) : ℤ :=
  normalizedArea (minkowskiSum P Q) - normalizedArea P - normalizedArea Q
```
Then prove symmetry, nonnegativity, and integrality under convex lattice hypotheses.

### Milestone 3: Generic tropical pair interface
You need a usable genericity predicate:
```lean
def GenericPair (f g : TropicalPolynomial2 ℤ) : Prop := ...
```
It should ensure:
- finite stable intersection,
- transverse intersections,
- no higher-dimensional overlap,
- mixed cells are 2-dimensional.

### Milestone 4: Dual cell correspondence
Formalize the bijection:
```lean
def stableIntersectionPointDualCell
  (f g : TropicalPolynomial2 ℤ) :
  StableIntersectionPoint f g → LatticePolygon
```
and prove multiplicity = normalized area.

### Milestone 5: Global summation theorem
Finish the bridge:
```lean
theorem tropical_bernstein_planar ...
```

---

## Cross-domain connections you should exploit

### 1. Sparse algebraic geometry / BKK theory
This theorem is the tropical-combinatorial front end of the Bernstein–Kushnirenko–Khovanskii theorem. Once formalized, it becomes plausible to prove restricted algebraic root-counting results for sparse systems over valued fields.

### 2. Convex geometry / discrete geometry
Mixed area is the 2D shadow of mixed volume. A machine-checked proof in dimension 2 would establish reusable infrastructure for Minkowski theory, Ehrhart theory, and polyhedral algorithms.

### 3. p-adic geometry / tropicalization
For sparse systems over `ℚ_p`, tropical intersection counts often predict algebraic root counts. Your theorem would become the certified tropical side of that correspondence.

### 4. Matroid theory / valuated matroids
The dual subdivisions and support combinatorics are not accidental; they are the low-dimensional manifestation of valuated matroid geometry. Even partial formalization here could open a route to tropical linear spaces.

### 5. Algorithmic certification
A Lean-certified mixed-area computation gives a formally verified sparse root-counting primitive. This has downstream relevance to symbolic computation, theorem proving, and certified nonlinear solving.

---

## Required test suite

You must verify the theorem computationally and formally on at least five non-simplex Newton polygon pairs:

1. rectangle × rectangle,
2. rectangle × trapezoid,
3. triangle × L-shape convex hull,
4. two non-congruent quadrilaterals,
5. a degenerate-near-boundary generic pair where one polygon has collinear boundary lattice points with nontrivial gcd edge lengths.

For each pair:
- compute `mixedArea`,
- compute tropical stable intersection multiplicity from the formalized curves,
- prove equality.

Also explicitly recover:
- `mixedArea (d₁ • Δ) (d₂ • Δ) = d₁ * d₂`,
- hence the existing planar tropical Bézout theorem as a corollary.

---

## Potential falsifiers to investigate honestly

A theorem this ambitious needs serious obstruction checks.

1. **Encoding obstruction:** convex hulls of arbitrary finite lattice supports may be difficult to compute canonically in Lean without substantial polygon infrastructure.
2. **Genericity obstruction:** existing tropical curve definitions may not package a sufficiently strong genericity predicate to avoid pathological intersections.
3. **Degeneracy obstruction:** if normalized area conventions and determinant multiplicity conventions are misaligned, the theorem may fail by a factor of 2 unless lattice normalization is handled perfectly.
4. **Subdivision obstruction:** proving that mixed cells partition the mixed Minkowski region may require a significant amount of polyhedral-combinatorial infrastructure not yet in the catalog.

If one of these blocks the full theorem, do not retreat to trivialities. Instead prove the strongest certified partial result:
- convex lattice polygons with triangulated subdivisions,
- or generic curves whose Newton subdivisions are unimodular,
- or support sets whose convex hulls are rectangles / triangles / trapezoids.

But keep the statement aimed at the full sparse planar theorem.

---

## Secondary direction: Valuated Matroid Intersection Shadow

If progress on the polygonal side is rapid, pursue the conceptual theorem:

> For generic planar tropical hypersurfaces arising from finite supports, local stable intersection multiplicity can be expressed as the weight of a corresponding valuated matroid intersection cell, and in the rank-2/rank-3 planar cases this agrees with the determinant / dual-area formula.

Possible Lean target:
```lean
theorem valuatedMatroidIntersectionMultiplicity_eq_tropicalMultiplicity
    (f g : TropicalPolynomial2 ℤ)
    (hgen : GenericPair f g)
    (p : StableIntersectionPoint f g) :
    valuatedMatroidLocalWeight f g p = localIntersectionMultiplicity f g p := by
```

This would be field-opening because it suggests tropical intersection multiplicities can be formalized algebraically before full polyhedral geometry is available.

---

## Secondary direction: Certified root counting via tropicalization

Once the planar Bernstein theorem is in place, target a restricted comparison theorem over valued fields:

> For a class of generic sparse bivariate systems over `ℚ` equipped with the `p`-adic valuation, the tropical stable intersection count equals the number of isolated algebraic solutions in the torus, counted with multiplicity.

Possible Lean-facing statement skeleton:
```lean
theorem padic_sparse_root_count_eq_tropical_intersection
    (p : ℕ) [Fact (Nat.Prime p)]
    (F G : LaurentPolynomial2 ℚ)
    (hgen : PadicGenericPair p F G) :
    torusRootCountPadic p F G
      =
    totalStableIntersectionMultiplicity
      (tropCurve (tropicalize p F))
      (tropCurve (tropicalize p G)) := by
```

Even one explicit certified example here would be a major proof-of-concept.

---

## Deliverables

1. A main Lean theorem formalizing the planar tropical Bernstein theorem, or the strongest nontrivial generic sparse partial theorem if a foundational obstruction appears.
2. Reusable definitions for lattice polygons, mixed area, and Minkowski sums.
3. At least one theorem connecting local tropical multiplicity to dual cell normalized area.
4. At least five certified examples on non-simplex Newton polygon pairs.
5. A corollary recovering planar tropical Bézout from Bernstein.
6. Minimal `sorry`, with any remaining gaps isolated in clearly named convex-geometric lemmas.

---

## Required FUTURE_DIRECTIONS.md

Produce a structured `FUTURE_DIRECTIONS.md` containing 3–5 falsifiable scientific hypotheses, each with:
- precise conjecture statement,
- why it should be true,
- what theorem / computation would test it,
- what result would falsify it.

Include at least these hypothesis directions:

1. **Unimodular-subdivision BKK lift:**  
   Conjecture that the planar Bernstein theorem extends to a certified toric root-counting theorem for sparse systems with unimodular Newton subdivisions.

2. **Valuated matroid multiplicity principle:**  
   Conjecture that tropical local intersection multiplicities in rank-2 complete intersections are definable purely via valuated matroid intersection weights.

3. **Higher-dimensional mixed-volume shadow:**  
   Conjecture that a 3D tropical hypersurface intersection theorem can be reduced to a formal mixed-cell decomposition theorem for lattice polytopes in `ℤ³`.

4. **Algorithmic complexity hypothesis:**  
   Conjecture that normalized mixed area for lattice polygons admits a formally verified polynomial-time computation via edge-normal convolution, outperforming triangulation-based proofs in Lean.

5. **p-adic certification bridge:**  
   Conjecture that for generic sparse systems over `ℚ_p`, tropical intersection counts certify exact torus root counts on a formally checkable class broader than currently known examples.

Be bold. If this succeeds, it will not just formalize a theorem; it will install the sparse tropical interface between certified geometry and certified algebraic counting.

### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  Show the math working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Speculative
Research mode: prove
