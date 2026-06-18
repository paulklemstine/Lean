Soli Deo Gloria

## Assignment: Direction 3 — Tropical Shadow and Newton Polytope Projections

**Mode:** prove

Prove genuinely new theorems around the slogan:

> **Quadratic shadow is Newton-polytope erosion by the degree-2 simplex, and tropical second differentiation detects exactly this eroded support.**

This must not be a cosmetic extension of `Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean`. The goal is to turn the existing combinatorial shadow formalism into a geometric dictionary between:
1. finite exponent supports,
2. convex-geometric Newton polytopes,
3. tropical second-derivative supports.

The breakthrough is to identify a derivative-combinatorial operation with a convex-geometry erosion operation. If successful, this opens a new program: **derivative complexity via Newton polytope geometry**, with access to Ehrhart theory, mixed volume, support functions, and tropical intersection theory.

---

## Core Vision

Let `S ⊆ ℕ^n` be a finite support set of exponent vectors. The existing quadratic shadow construction should be reinterpreted as:

\[
\mathrm{Sh}_2(S)
=
\{u \in \mathbb N^n : u + \beta \in S \text{ for some } \beta \in \Delta_2(\mathbb N)\}
\]

or, in the saturated/lattice-polytope case, as the lattice points of the **Minkowski erosion**
\[
\mathrm{Newt}(S) \ominus \Delta_2
:=
\{x \in \mathbb R^n : x + \Delta_2 \subseteq \mathrm{Newt}(S)\}.
\]

The nontrivial content is that for support sets which are lattice-saturated inside their Newton polytope, the purely discrete shadow equals the integer points of this convex erosion. Then tropicalization should preserve support under second differentiation, yielding a tropical-geometric shadow theorem.

This is not just a prettier reformulation. It would mean:
- derivative support can be read off from convex geometry,
- support loss under differentiation becomes a polytope projection/erosion phenomenon,
- tropical Hessian support becomes a geometric invariant,
- sparse vs saturated support can be sharply distinguished by failure of equality.

---

## Required New Definitions

You must define at least one genuinely new concept not already in the Catalog. Recommended definitions:

### 1. Minkowski erosion / polytope shadow
For a set `P : Set (Fin n → ℝ)` and a kernel `K : Set (Fin n → ℝ)`, define:
```lean
def minkowskiErosion (P K : Set (Fin n → ℝ)) : Set (Fin n → ℝ) :=
  {x | ∀ y ∈ K, x + y ∈ P}
```

### 2. Degree-2 simplex in exponent space
A finite/discrete simplex of quadratic exponent increments:
```lean
def quadSimplex (n : ℕ) : Set (Fin n → ℕ) :=
  {β | (∑ i, β i) = 2}
```
and its real relaxation:
```lean
def quadSimplexReal (n : ℕ) : Set (Fin n → ℝ) :=
  {β | (∀ i, 0 ≤ β i) ∧ (∑ i, β i) = 2}
```

### 3. Lattice-saturated support
A support set that contains every lattice point of its Newton polytope:
```lean
def IsLatticeSaturated (S : Finset (Fin n → ℕ)) : Prop :=
  ∀ u : Fin n → ℕ, u ∈ newtonLatticePoints S → u ∈ S
```
where `newtonLatticePoints S` should be defined from the convex hull / Newton polytope formalism you build.

### 4. Tropical second-derivative support
If full tropical polynomial infrastructure is not already available, define an abstract support-level operation:
```lean
def tropicalSecondShadow (S : Finset (Fin n → ℕ)) : Finset (Fin n → ℕ) := ...
```
and prove it agrees with quadratic shadow under suitable hypotheses. If tropical polynomial files exist in the Catalog, connect directly to them instead of building an ad hoc surrogate.

---

## Precise Theorem Targets

You must prove at least 3 substantial theorems. The following are the primary targets.

### Theorem 1: Discrete shadow is contained in Newton erosion lattice points
For arbitrary finite support sets, prove a one-sided containment.

**Mathematical statement**
\[
\forall S \subseteq \mathbb N^n \text{ finite},\quad
\mathrm{Sh}_2(S) \subseteq \bigl(\mathrm{Newt}(S)\ominus \Delta_2\bigr)\cap \mathbb Z^n
\]
provided `Sh₂` is interpreted via universal quadratic extension condition; if the catalog’s `QuadraticShadow` is existential, adjust the erosion notion accordingly and state the exact matching version.

A more robust formulation is:

> If `u` lies in the quadratic shadow of `S`, then for every real quadratic increment `β ∈ Δ₂(ℝ)`, the point `u + β` lies in `Newt(S)`.

This is the convex-geometric heart.

**Suggested Lean 4 signature**
```lean
theorem quadraticShadow_subset_latticePoints_minkowskiErosion
    {n : ℕ}
    (S : Finset (Fin n → ℕ)) :
    QuadraticShadow S ⊆
      latticePoints
        (minkowskiErosion (newtonPolytope S) (quadSimplexReal n)) := by
```

If `QuadraticShadow S` is a `Finset`, use membership form:
```lean
theorem mem_latticePoints_minkowskiErosion_of_mem_quadraticShadow
    {n : ℕ}
    {S : Finset (Fin n → ℕ)} {u : Fin n → ℕ}
    (hu : u ∈ QuadraticShadow S) :
    u ∈ latticePoints (minkowskiErosion (newtonPolytope S) (quadSimplexReal n)) := by
```

### Theorem 2: Equality for lattice-saturated supports
This is the flagship theorem.

**Mathematical statement**
\[
\forall S \subseteq \mathbb N^n \text{ finite},\quad
\mathrm{IsLatticeSaturated}(S)
\;\Longrightarrow\;
\mathrm{Sh}_2(S)
=
\bigl(\mathrm{Newt}(S)\ominus \Delta_2\bigr)\cap \mathbb Z^n.
\]

This is the precise bridge from combinatorics to convex geometry.

**Suggested Lean 4 signature**
```lean
theorem quadraticShadow_eq_latticePoints_minkowskiErosion_of_saturated
    {n : ℕ}
    {S : Finset (Fin n → ℕ)}
    (hSat : IsLatticeSaturated S) :
    QuadraticShadow S =
      latticePointsFinset
        (minkowskiErosion (newtonPolytope S) (quadSimplexReal n)) := by
```

If equality of `Finset`s is awkward, prove extensional membership equivalence:
```lean
theorem mem_quadraticShadow_iff_mem_latticePoints_erosion_of_saturated
    {n : ℕ}
    {S : Finset (Fin n → ℕ)}
    (hSat : IsLatticeSaturated S)
    {u : Fin n → ℕ} :
    u ∈ QuadraticShadow S ↔
    u ∈ latticePointsFinset
      (minkowskiErosion (newtonPolytope S) (quadSimplexReal n)) := by
```

### Theorem 3: Sparse support obstruction / strictness criterion
You need a theorem explaining when equality fails.

**Mathematical statement**
If `S` is not lattice-saturated, then there exists a finite support where
\[
\mathrm{Sh}_2(S) \subsetneq \bigl(\mathrm{Newt}(S)\ominus \Delta_2\bigr)\cap \mathbb Z^n.
\]
Better: give a structural criterion in terms of a missing lattice point `v ∈ Newt(S) ∩ ℤ^n \setminus S` that obstructs equality.

**Suggested Lean 4 signature**
```lean
theorem exists_strict_gap_of_not_latticeSaturated
    {n : ℕ}
    {S : Finset (Fin n → ℕ)}
    (hNot : ¬ IsLatticeSaturated S) :
    ∃ u : Fin n → ℕ,
      u ∈ latticePointsFinset
            (minkowskiErosion (newtonPolytope S) (quadSimplexReal n)) ∧
      u ∉ QuadraticShadow S := by
```
If this is too strong globally, prove a conditional strictness theorem under a clean additional hypothesis, e.g. existence of a missing point with all quadratic translates still inside the polytope.

### Theorem 4: Tropical support theorem
This is the field-opening theorem. Even if full tropical differentiation is not available, formalize the support-level statement rigorously.

**Mathematical statement**
For a tropical polynomial with support `S`, the support of its tropical second derivative equals the quadratic shadow, hence in the lattice-saturated case equals the lattice points of the Newton erosion.

\[
\mathrm{Supp}\bigl(D^{\mathrm{trop}}_2(f)\bigr)
=
\mathrm{Sh}_2(\mathrm{Supp}(f)).
\]

And if `Supp(f)` is lattice-saturated:
\[
\mathrm{Supp}\bigl(D^{\mathrm{trop}}_2(f)\bigr)
=
\bigl(\mathrm{Newt}(\mathrm{Supp}(f))\ominus \Delta_2\bigr)\cap \mathbb Z^n.
\]

**Suggested Lean 4 signature**
```lean
theorem tropicalSecondDerivative_support_eq_quadraticShadow
    {n : ℕ}
    (f : TropicalPolynomial n) :
    support (tropicalSecondDerivative f) =
      QuadraticShadow (support f) := by
```

and the corollary:
```lean
theorem tropicalSecondDerivative_support_eq_latticePoints_erosion_of_saturated
    {n : ℕ}
    (f : TropicalPolynomial n)
    (hSat : IsLatticeSaturated (support f)) :
    support (tropicalSecondDerivative f) =
      latticePointsFinset
        (minkowskiErosion (newtonPolytope (support f)) (quadSimplexReal n)) := by
```

If `TropicalPolynomial` is absent from Mathlib/Catalog, define a lightweight support-based model and state explicitly that this theorem is a support theorem for tropical second differentiation.

---

## Cross-Domain Theorem Requirement

You must include at least one theorem connecting tropical shadow geometry to a different domain.

### Recommended cross-domain bridge: Ehrhart-theoretic derivative complexity
Show that for lattice-saturated families `S_m = mP ∩ ℤ^n`,
\[
|\mathrm{Sh}_2(S_m)| = |(mP \ominus \Delta_2)\cap \mathbb Z^n|
\]
is eventually a polynomial/quasi-polynomial in `m`, provided `P` is a rational polytope.

This ties derivative-support complexity to Ehrhart theory.

**Suggested Lean-style target**
```lean
theorem eventual_quasipolynomial_card_quadraticShadow_of_rational_polytope
    {n : ℕ}
    (P : RationalPolytope n) :
    ∃ Q : ℕ → ℕ,
      EventualQuasiPolynomial Q ∧
      ∀ᶠ m in Filter.atTop,
        card (QuadraticShadow (polytopeDilateLatticePoints P m)) = Q m := by
```

If this exact theorem is too ambitious for current libraries, prove a finite-dimensional precursor:
- monotonicity under dilation,
- asymptotic upper/lower bounds by volume,
- exact cardinality in the simplex or box case.

Alternative cross-domain bridges:
- **algebraic statistics:** support erosion corresponds to loss of interaction terms in log-linear models;
- **mathematical physics:** tropical second derivative support as a combinatorial shadow of zero-temperature free energy;
- **optimization:** shadow equals feasible right-hand sides of a degree-2 resource allocation relaxation.

Include one theorem and explain it mathematically, not rhetorically.

---

## Proof Architecture: 3 Strategic Paths

You asked for deeper proof insight. Here are the proof routes. Use at least one primary route and one backup route.

### Strategy A: Convex-combination lifting from vertices to simplex points
Most promising for Theorems 1 and 2.

1. **Embed exponent vectors into `Fin n → ℝ`.**
   Define the Newton polytope as the convex hull of `S`.
2. **Show quadratic shadow implies containment under extreme quadratic increments.**
   It is enough to verify `u + β ∈ Newt(S)` on extreme points of `Δ₂`, then extend to all `β ∈ Δ₂(ℝ)` by convexity.
3. **Use lattice saturation for the reverse direction.**
   If `u` is an integer point in the erosion, then all required quadratic translates lie in `Newt(S)`. Under saturation, these translates are actual support elements of `S`, hence `u ∈ Sh₂(S)`.

Why this is promising: it converts the combinatorics of degree-2 exponent shifts into convexity plus lattice-point saturation, which is exactly the correct language for Newton polytopes.

### Strategy B: Support-function / half-space characterization
Best for stronger geometric theorems.

1. Characterize erosion by support functions:
   \[
   h_{P \ominus K}(c) = h_P(c) - h_K(c)
   \]
   when erosion is nonempty and appropriately defined.
2. Compute `h_{Δ₂}` explicitly:
   \[
   h_{\Delta_2}(c) = 2 \max_i c_i.
   \]
3. Translate membership `u ∈ P ⊖ Δ₂` into linear inequalities:
   \[
   \langle c, u\rangle + 2\max_i c_i \le h_P(c)
   \]
   for all `c`.
   Then compare this directly to shadow inequalities.

Why this matters: it reframes derivative support as a support-function subtraction law. That is a conceptual advance and could generalize to `k`th shadows immediately.

### Strategy C: Induction on dimension / degree with explicit sparse obstruction
Best for the strictness theorem and computational algorithm.

1. Prove base cases in 1D and low-dimensional simplices explicitly.
2. Use induction on `n` by slicing supports on a coordinate hyperplane.
3. Construct explicit missing-lattice-point obstructions to show strict containment in the sparse case.

Why this helps: sparse counterstructure is easier to see combinatorially than via full convex geometry. It also gives computationally checkable witnesses.

---

## Catalog Build-On Instructions

You must explicitly build on:
- `Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean`
  - reuse `QuadraticShadow`, `computeQuadShadow`, and any lemmas already established;
  - identify whether `QuadraticShadow` is existential or universal in its current definition, and adapt the erosion theorem to the exact semantics.
- Any available tropical geometry files in the Catalog
  - if there are support lemmas for tropical polynomials, use them to avoid reinventing support theory;
  - if there are Newton polytope or convex hull lemmas, cite them and connect them explicitly.

Do not merely mention these files. In `RESEARCH_PAPER.md`, explain exactly which prior certified results were the launchpad and what conceptual leap your work adds.

---

## Algorithmic Deliverable

You must produce a **verified computational method**, not just existence theorems.

### Required algorithm
Implement an algorithm computing both:
1. `QuadraticShadow S`,
2. lattice points of `newtonPolytope S ⊖ Δ₂`.

Then prove a correctness theorem relating the implementation to the mathematical definitions.

Suggested theorem:
```lean
theorem computeQuadShadow_correct
    {n : ℕ} (S : Finset (Fin n → ℕ)) :
    computeQuadShadow S = QuadraticShadow S := by
```

and a new one:
```lean
theorem computeErodedNewtonLatticePoints_correct
    {n : ℕ} (S : Finset (Fin n → ℕ)) :
    computeErodedNewtonLatticePoints S =
      latticePointsFinset
        (minkowskiErosion (newtonPolytope S) (quadSimplexReal n)) := by
```

Then create a comparison procedure:
```lean
def compareShadowAndErosion (S : Finset (Fin n → ℕ)) : Bool := ...
```
with a theorem characterizing `true` in terms of equality.

This is essential because the conjecture includes a falsifiable computational test.

---

## Conjecture with Testable Prediction

You must state at least one falsifiable conjecture and make it computationally testable.

### Primary conjecture
For every finite lattice-saturated support `S ⊆ ℕ^n`,
\[
\mathrm{Sh}_2(S)
=
(\mathrm{Newt}(S)\ominus \Delta_2)\cap \mathbb Z^n.
\]

### Stronger asymptotic conjecture
For rational lattice polytopes `P`,
\[
m \mapsto |\mathrm{Sh}_2(mP \cap \mathbb Z^n)|
\]
agrees for all sufficiently large `m` with the Ehrhart polynomial of the eroded body `P ⊖ \frac{1}{m}\Delta_2`, hence has leading term
\[
\mathrm{Vol}(P)\,m^n - 2\,\mathrm{Surf}_{\mathrm{trop}}(P)\,m^{n-1} + O(m^{n-2}).
\]

This is bold and testable: compute cardinalities for simplices, cubes, and random lattice polytopes in dimensions 2 and 3.

### Explicit computational test
For `n = 3`, degree bound `≤ 8`:
- enumerate supports `S`,
- compute `QuadraticShadow S`,
- compute `latticePoints(Newt(S) ⊖ Δ₂)`,
- classify when equality holds,
- detect minimal sparse counterexamples.

Your `demo.py` must visualize at least one equality case and one strict-containment case.

---

## Lean Proof Expectations

Your file must contain at least 3 nontrivial theorem proofs using techniques such as:
- induction,
- `rcases`,
- `by_contra`,
- `field_simp` where affine coordinates appear,
- multi-step `calc`,
- convexity arguments,
- extensionality on finite sets.

Do **not** satisfy the theorem count with trivial decidable equalities. The core proofs should involve actual mathematical structure.

Recommended proof ingredients:
- finite support embeddings `ℕ → ℝ`,
- convex hull membership,
- simplex extreme-point decomposition,
- lattice-point coercion lemmas,
- subset/extensionality arguments,
- witness extraction from `¬ IsLatticeSaturated S`.

---

## Revolutionary Significance

If you succeed, you will have created a new interface:

> **Derivative support theory = convex erosion of Newton polytopes = tropical support dynamics.**

That opens:
- **Ehrhart-theoretic derivative complexity:** asymptotics of support loss under repeated differentiation;
- **mixed-volume bounds:** geometric control of higher-order derivative richness;
- **tropical Hessian geometry:** singularity detection via support erosion;
- **sparse elimination theory:** characterize when sparse supports behave like saturated polytopes;
- **algorithmic algebraic geometry:** fast support prediction from convex data.

This is the kind of result that changes the questions people ask. Instead of “what monomials survive differentiation?”, one asks “what erosion geometry governs derivative survival?”

---

## Application Keywords

tropical geometry; Newton polytope; Minkowski erosion; convex geometry; Ehrhart theory; lattice points; support functions; tropical Hessian; sparse polynomials; derivative complexity; mixed volume; polyhedral combinatorics; algebraic statistics; zero-temperature limits; discrete convex analysis

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean file(s)** with the new definitions, algorithms, and at least 3 substantial theorem proofs.
2. **FUTURE_DIRECTIONS.md** with 3–5 research directions. Each direction must include the exact sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   At least one direction must bridge to a different domain.
3. **RESEARCH_PAPER.md** as a standalone scientific document explaining:
   - the main definitions and theorems,
   - why the shadow/erosion identification is a breakthrough,
   - proof ideas,
   - computational evidence,
   - conjectures and next steps.
4. **ARTICLE.md** in Scientific American style:
   - vivid and accessible,
   - focused on the mathematics and its significance,
   - **do not** focus on formal verification machinery.
5. **A verified algorithm or computational method** for computing shadow and eroded Newton lattice points.
6. **demo.py** that interactively:
   - inputs finite supports in 2D or 3D,
   - computes `QuadraticShadow`,
   - computes eroded Newton lattice points,
   - compares them,
   - visualizes equality and failure cases.

Minimize sorry. If a theorem is too ambitious in full generality, prove the strongest clean version the library supports, and state the sharper conjectural form explicitly. The target is not incremental completion — it is a new geometric theory of shadows.

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
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses, including 1-2 grand_challenge paradigm-shifting conjectures
and 2-3 solid extensions building directly on Catalog theorems.
MUST begin with a ## Synthesis section tying all directions together.
Each direction must use the structured format with explicit fields:
**Conjecture**, **Test**, **Impact**, **Catalog References**,
**Proof Strategy**, **Domain Bridges**, **Lineage**, **Ambition**.
Reference specific Catalog theorems by file path. Every hypothesis
must be daring enough to matter and specific enough to fail.


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
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
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

Research domain: Pythagorean
Research mode: prove
