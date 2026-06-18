Soli Deo Gloria

## Assignment: Direction 3: Shadow Isoperimetry for Newton Polytopes

**Mode:** `prove`

Prove genuinely new, non-trivial theorems at the interface of **extremal combinatorics, lattice-point geometry, Ehrhart theory, and algebraic complexity**. The central ambition is to turn the shadow operator on finite subsets of `ℕ^n` into a geometric invariant controlled by the Newton polytope, and to show that **combinatorial compression phenomena are governed by discrete surface area**.

This is not a request for a routine bound. The target is a field-opening bridge: a formal theory in which the one-step shadow behaves like a **discrete inner parallel body** of a lattice polytope, yielding lower bounds that depend simultaneously on cardinality and convex-geometric data. If successful, this opens a new geometric language for shadow complexity, monomial support growth, sparse elimination, and combinatorial lower bounds.

Build explicitly on:

- `Catalog/Bridges/Catalog/Pythagorean/CircuitLowerBounds/ShadowDecay.lean`
  - `kthShadow_subset_degreeSimplex`
  - `degreeSimplex_card`

Use these not as endpoints but as scaffolding: they show how shadows sit inside degree simplices; your job is to **replace simplex-only control by polytope-sensitive control**.

---

## Core Vision

Given a finite set `S ⊆ ℕ^n`, define its one-step shadow `Sh₁(S)` by decrementing one positive coordinate by `1`. The guiding principle is:

> **Shadow = discrete inward boundary flow of exponent sets.**

If `S` is thought of as a monomial support, then `conv(S)` is its Newton polytope. The theorem we want is a genuine discrete isoperimetric statement: **large volume and fixed cardinality force many shadow points**, just as Euclidean bodies with fixed volume force large surface area.

The breakthrough is to show that shadows are not merely degree artifacts. They are **geometric boundary invariants**.

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems**. At least one should introduce a new definition that does not already exist in the catalog.

### New Definitions to Introduce

You should define a polytope-sensitive boundary notion for finite subsets of `ℕ^n`. For example:

- `oneShadow : Finset (Fin n → ℕ) → Finset (Fin n → ℕ)`
- `shadowDefect : Finset (Fin n → ℕ) → ℕ := |S| - |oneShadow S|`
- `lowerClosed : Finset (Fin n → ℕ) → Prop`
- `axisFiber (S) (i : Fin n) (u : Fin n → ℕ) : Finset ℕ`
- `compressedInDir (S) (i : Fin n) : Prop`

and, if feasible, a new geometric invariant such as

- `latticeInnerBoundary : Finset (Fin n → ℕ) → ℕ`

measuring the number of points of `S` with at least one positive coordinate decrement leaving `S`.

This is mathematically important: it makes the shadow operator legible as a discrete boundary operator.

---

## Theorem 1: Compression-to-Lower-Set Shadow Minimization

The first theorem should isolate the correct extremizers.

### Mathematical statement
For finite sets of lattice points in `ℕ^n` with fixed cardinality, coordinate compressions do not increase one-step shadow size. Consequently, among all sets of cardinality `m`, the minimum shadow is attained by a lower set.

This is the discrete analogue of Steiner symmetrization: before proving geometric lower bounds, first prove that extremizers may be taken monotone.

### Lean 4 target signature
A representative target is:

```lean
theorem exists_lowerClosed_minimizer_shadow
    (n m : ℕ) :
    ∃ S : Finset (Fin n → ℕ),
      S.card = m ∧
      lowerClosed S ∧
      (∀ T : Finset (Fin n → ℕ), T.card = m → (oneShadow S).card ≤ (oneShadow T).card)
```

If the full minimizer existence is too technically heavy at first, first prove the directional compression step:

```lean
theorem compressDir_shadow_card_le
    (n : ℕ) (i : Fin n) (S : Finset (Fin n → ℕ)) :
    (oneShadow (compressInDir i S)).card ≤ (oneShadow S).card
```

and then iterate compression.

### Why this is a breakthrough
This theorem identifies the correct variational class. It says shadow minimization is not a chaotic problem over arbitrary supports; it collapses to the structured world of lower ideals in `ℕ^n`. That is the essential gateway to all polyhedral and asymptotic arguments.

---

## Theorem 2: Degree-Simplex Isoperimetric Lower Bound

Use the catalog simplex theorems to obtain the first genuine nontrivial lower bound.

### Mathematical statement
If `S ⊆ ℕ^n` is finite and contained in a degree simplex of radius `d`, then
`|Sh₁(S)|` is bounded below in terms of `|S|` and `d`; in the extremal full-simplex case, the shadow is exactly the previous degree simplex. More ambitiously, show that if `S` is large inside a degree simplex, then the shadow cannot be too small.

A concrete theorem to target:

> If `S ⊆ Δ(n,d)` and `|S| > |Δ(n,d-1)|`, then `Sh₁(S)` intersects the top layer nontrivially and in particular
> `|Sh₁(S)| ≥ |S| - C(n,d)` for an explicit combinatorial defect term.

Or derive a cardinality lower bound using the exact simplex counts.

### Lean 4 target signature
For example:

```lean
theorem shadow_card_lower_of_subset_degreeSimplex
    (n d : ℕ) (S : Finset (Fin n → ℕ))
    (hS : S ⊆ degreeSimplex n d) :
    ∃ c : ℕ,
      c ≤ (degreeSimplex n d).card ∧
      c ≤ (oneShadow S).card
```

But this is too weak by itself; strengthen toward a concrete lower bound:

```lean
theorem shadow_card_ge_of_large_in_degreeSimplex
    (n d : ℕ) (S : Finset (Fin n → ℕ))
    (hS : S ⊆ degreeSimplex n d)
    (hlarge : (degreeSimplex n (d - 1)).card < S.card) :
    (degreeSimplex n (d - 1)).card ≤ (oneShadow S).card
```

This should explicitly exploit:

- `kthShadow_subset_degreeSimplex`
- `degreeSimplex_card`

### Why this is a breakthrough
This gives the first certified isoperimetric statement in the formal system: the shadow is forced by ambient Newton geometry, not just by raw cardinality. It turns the catalog’s simplex containment lemmas into an actual extremal principle.

---

## Theorem 3: Box / Product-Set Boundary Formula

Prove an exact theorem for rectangular Newton polytopes. This is the cleanest entry point to “surface area controls shadow.”

### Mathematical statement
Let
`B(a) = ∏_{i=1}^n {0,1,...,a_i}`.
Then the one-step shadow of the full box is exactly the union of the coordinate lower facets, hence has cardinality

\[
|\mathrm{Sh}_1(B(a))|
= \prod_i (a_i+1) - \prod_i a_i
\]

with the convention that the second product uses `a_i` as the number of strictly positive levels surviving simultaneous positivity. Equivalently, the complement inside the box consists exactly of points with all coordinates positive.

This is a perfect discrete boundary formula: shadow size = box volume − shifted interior volume.

### Lean 4 target signature
For a suitable definition `box n a : Finset (Fin n → ℕ)`:

```lean
theorem card_oneShadow_box
    (n : ℕ) (a : Fin n → ℕ) :
    (oneShadow (box n a)).card =
      (∏ i, (a i + 1)) - (∏ i, a i)
```

You may also need a structural theorem:

```lean
theorem mem_oneShadow_box_iff
    (n : ℕ) (a x : Fin n → ℕ) :
    x ∈ oneShadow (box n a) ↔
      (∀ i, x i ≤ a i) ∧ ∃ i, x i < a i
```

### Why this is a breakthrough
This theorem is the exact model case for the philosophy “shadow = discrete surface area.” Once established, it gives a rigorous testing ground for asymptotic inequalities and suggests the right constants in the general polytope case.

---

## Theorem 4: Loomis–Whitney Type Shadow Lower Bound

This is the cross-domain flagship theorem: it ties shadows to geometric inequalities from analysis and convexity.

### Mathematical statement
For a finite lower set `S ⊆ ℕ^n`, prove a shadow lower bound in terms of coordinate projections, inspired by Loomis–Whitney:

\[
|S|^{n-1} \le \prod_{i=1}^n |\pi_i(S)|
\quad\Longrightarrow\quad
|\mathrm{Sh}_1(S)| \ge \max_i |\pi_i(S)| \ge |S|^{(n-1)/n}.
\]

The exact inequality may need adaptation, but the target is clear: use projection geometry to deduce a universal lower bound of order `|S|^{(n-1)/n}` for structured sets.

### Lean 4 target signature
A realistic formal target could be:

```lean
theorem shadow_card_ge_geomMean_proj_of_lowerClosed
    (n : ℕ) (S : Finset (Fin n → ℕ))
    (hdown : lowerClosed S) :
    S.card ^ (n - 1) ≤ ∏ i : Fin n, (coordProjection i S).card
```

together with

```lean
theorem shadow_card_ge_max_projection_of_lowerClosed
    (n : ℕ) (S : Finset (Fin n → ℕ))
    (hdown : lowerClosed S) :
    (Finset.univ.sup fun i : Fin n => (coordProjection i S).card) ≤ (oneShadow S).card
```

and then a corollary:

```lean
theorem shadow_card_ge_card_pow
    (n : ℕ) (S : Finset (Fin n → ℕ))
    (hn : 1 ≤ n)
    (hdown : lowerClosed S) :
    ∃ c : ℕ, c^n ≤ S.card^(n-1) ∧ c ≤ (oneShadow S).card
```

If full exponent management over `ℕ` is cumbersome, formulate the asymptotic lower bound over `ℝ` using coercions.

### Why this is a breakthrough
This would be the first formal theorem placing the shadow operator inside the ecosystem of **geometric-functional inequalities**. It connects combinatorial shadows to Loomis–Whitney, Brunn–Minkowski heuristics, and entropy-style projection bounds. This is exactly the kind of unexpected bridge that creates a new subfield.

---

## Theorem 5: Polytope-Sensitive Shadow Bound via Box Containment or Inner Parallel Bodies

This theorem should move toward the stated conjecture with an explicit dependence on Newton polytope geometry.

### Mathematical statement
For finite lower sets `S ⊆ ℕ^n` whose Newton polytope is contained in an axis-aligned box with side lengths `a_i`, prove

\[
|\mathrm{Sh}_1(S)| \ge |S| \cdot \left(1 - \prod_i \frac{a_i}{a_i+1}\right)
\]

or a weaker but rigorous bound derived from comparison with the full box.

Alternatively, if you define an inner lattice erosion `E(P)`, prove that for full lattice boxes or simplices, the shadow cardinality equals the number of lattice points in `P \setminus E(P)`.

### Lean 4 target signature
For example:

```lean
theorem shadow_card_ge_box_boundary
    (n : ℕ) (a : Fin n → ℕ) (S : Finset (Fin n → ℕ))
    (hS : S ⊆ box n a)
    (hdown : lowerClosed S) :
    S.card - (interiorShiftBox n a).card ≤ (oneShadow S).card
```

or a more directly computable form:

```lean
theorem shadow_card_ge_relative_box_defect
    (n : ℕ) (a : Fin n → ℕ) (S : Finset (Fin n → ℕ))
    (hS : S ⊆ box n a)
    (hdown : lowerClosed S) :
    S.card ≤ (oneShadow S).card + ∏ i, a i
```

### Why this is a breakthrough
This is the first step from exact model families to general Newton polytope control. Even a box-based theorem is scientifically valuable because it supplies a formal bridge to **mixed volume heuristics, sparse polynomial complexity, and Ehrhart asymptotics**.

---

## Proof Strategy Architecture

You must present and execute **2–3 proof routes**, not a single hint.

### Strategy A: Compression → Structured Extremizers → Projection Bound
1. Define coordinate compression on fibers parallel to each axis.
2. Prove compression preserves cardinality and does not increase `oneShadow.card`.
3. Reduce to lower sets.
4. For lower sets, show each coordinate projection injects into the shadow or is controlled by it.
5. Combine with a Loomis–Whitney style inequality to obtain `|Sh₁(S)| ≳ |S|^{(n-1)/n}`.

**Why promising:** This route is the most conceptually powerful. It transforms an arbitrary support into a monotone one where shadow geometry becomes transparent. It is the strongest path toward the conjectural exponent `(n-1)/n`.

### Strategy B: Exact Model Families → Comparison Principle
1. Prove exact formulas for boxes and degree simplices.
2. Show that among lower sets with fixed ambient box or simplex data, initial segments minimize the shadow.
3. Derive explicit lower bounds by comparison with full boxes/simplexes.
4. Use catalog simplex cardinality formulas to get closed forms.

**Why promising:** This is the most Lean-friendly path. It replaces global convex geometry by exact combinatorial identities on tractable families. It should produce the first complete formal breakthrough quickly.

### Strategy C: Discrete Boundary as Erosion Defect
1. Define the shifted interior `S⁺ := {x : x + e_i ∈ S for all i}` or a one-step erosion.
2. Prove `|Sh₁(S)| = |S| - |S⁺|` for lower sets or boxes.
3. Compare `S⁺` to lattice points in an inner parallel body of `conv(S)`.
4. Import Ehrhart-style intuition: boundary lattice-point growth is one order lower than volume growth.

**Why promising:** This is the most visionary route. It directly links shadow to inner parallel bodies, making the connection to convex geometry explicit. Even partial formalization here would open a completely new program.

**Recommended order:** Start with **Strategy B** to secure exact theorems and infrastructure; then use **Strategy A** for the cardinality exponent; reserve **Strategy C** for the conceptual paper and future directions if full formalization becomes technically intense.

---

## Cross-Domain Connections You Must Exploit

At least one theorem must explicitly bridge to another domain.

### 1. Algebraic complexity
Interpret `S` as monomial support of a sparse polynomial. Then `Sh₁(S)` measures the support generated by partial differentiation or monomial division. A shadow lower bound implies:
- unavoidable support spread under derivative operations,
- constraints on sparse circuit compression,
- lower bounds for support-preserving algebraic computation.

### 2. Ehrhart theory / convex geometry
`conv(S)` is the Newton polytope. The shadow is a discrete analogue of removing one lattice layer from the polytope. This ties:
- shadow size to discrete surface area,
- box and simplex formulas to Ehrhart first differences,
- asymptotic shadow growth to boundary-volume phenomena.

### 3. Information theory / entropy
A Loomis–Whitney style proof can be read as an entropy inequality for coordinate marginals. This suggests:
- shadow lower bounds as discrete data-processing inequalities for monotone supports,
- projection cardinalities as combinatorial entropy proxies.

### 4. Statistical physics / lattice gases
Lower sets model occupation constraints in monotone lattice gases. The shadow counts sites reachable by one-particle deletion, analogous to boundary activity. This gives a conceptual bridge to:
- surface free energy,
- erosion dynamics,
- metastable boundary effects.

You do not need to formalize all of these, but at least one must appear in a theorem statement, corollary, or substantial discussion.

---

## Conjecture with Testable Prediction

State at least one falsifiable conjecture and provide a computational test that could disprove it.

### Main conjecture
For every `n ≥ 2`, there exists `c(n) > 0` such that for every finite lower set `S ⊆ ℕ^n`,

\[
|\mathrm{Sh}_1(S)| \ge c(n)\, |S|^{(n-1)/n}.
\]

Stronger polytope-sensitive version:

\[
|\mathrm{Sh}_1(S)| \ge c(n,\operatorname{Vol}(\operatorname{conv}(S)))\, |S|^{(n-1)/n}.
\]

### Testable prediction
For `n = 2,3`, among all lower sets of fixed cardinality `m ≤ 50`, the minimizers of `|Sh₁(S)|` are initial segments in a simplicial or box-compatible order; in particular the ratio

\[
\frac{|\mathrm{Sh}_1(S)|}{|S|^{(n-1)/n}}
\]

is minimized by near-simplex configurations.

This is falsifiable: exhaustive search can find a counterexample.

### Lean-adjacent computable conjecture
You may also formulate:

```lean
conjecture lowerClosed_shadow_minimized_by_degreeInitialSegment
    (n m : ℕ) :
    ∃ S : Finset (Fin n → ℕ),
      lowerClosed S ∧
      S.card = m ∧
      (∀ T : Finset (Fin n → ℕ), lowerClosed T → T.card = m →
        (oneShadow S).card ≤ (oneShadow T).card)
```

---

## Computational / Algorithmic Deliverable

You must produce a **verified algorithm or computational method**, not just theorem statements.

### Required algorithm
Implement an algorithm that:
1. enumerates finite lower sets in `ℕ^2` and `ℕ^3` up to cardinality `m ≤ 50`,
2. computes:
   - `|S|`,
   - `|oneShadow S|`,
   - bounding box dimensions,
   - an approximation or exact computation of `conv(S)` volume when feasible,
3. tests the conjectural lower bounds,
4. searches for extremizers.

This should be accompanied by correctness lemmas for the shadow computation and at least one theorem linking the implementation to the mathematical definition.

### `demo.py`
The demo should:
- let the user choose `n = 2` or `3`,
- generate sample families: simplex slices, boxes, random lower sets,
- compute and display `|S|`, `|Sh₁(S)|`, volume proxy, projection sizes,
- plot `|Sh₁(S)|` versus `|S|^{(n-1)/n}`,
- highlight candidate extremizers.

---

## Lean Tactics / Depth Requirements

These are mandatory and should shape theorem selection.

1. **No trivial proofs.**
   Avoid statements whose only content is decidable computation. Do not spend theorem budget on `native_decide` facts unless they support a genuinely deep result.

2. **At least 3 deep theorems.**
   Ensure at least 3 theorems use substantial proof structure with combinations of:
   - induction,
   - `rcases`,
   - `by_contra`,
   - `field_simp`,
   - multi-step `calc`,
   - nontrivial cardinality arguments,
   - monotonicity and subset reasoning.

3. **Novel definitions.**
   Introduce at least one genuinely new concept such as `lowerClosed`, `compressInDir`, `latticeInnerBoundary`, or `shadowDefect`.

4. **Cross-domain theorem.**
   Include at least one theorem or corollary explicitly linking shadow bounds to algebraic complexity, projection inequalities, or lattice-geometric boundary.

---

## Application Keywords

**Newton polytope, discrete isoperimetry, lattice-point geometry, Ehrhart theory, monomial supports, algebraic complexity, sparse elimination, compression, lower ideals, Loomis–Whitney, entropy inequalities, inner parallel body, surface area, extremal combinatorics, shadow minimization**

---

## Mandatory Deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions**, each written as real prose, each containing:
- the sentence **“The key insight is...”**
- the sentence **“Why now?”**

At least one direction must bridge to a different domain, such as information theory, statistical physics, or algebraic complexity.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper that explains:
- the definitions,
- the main theorems,
- proof ideas,
- why shadow isoperimetry for Newton polytopes matters,
- how this changes the landscape,
- what should be done next.

A reader with no access to the code must still understand the discovery.

### 3. `ARTICLE.md`
Write this in **Scientific American style**:
- vivid,
- concept-driven,
- broad-audience accessible,
- focused on the mathematics and its significance.

**Taboo:** do **not** focus on formal verification or proof assistant mechanics.

### 4. Verified algorithm / computational method
Provide an implemented and mathematically justified method for enumerating lower sets, computing shadows, and testing the conjecture.

### 5. `demo.py`
An interactive demo showing the theorem and conjecture numerically and visually.

---

## Final Call

The real target is not merely a lower bound. It is the birth of a new doctrine:

> **Shadows of exponent sets are boundary operators of discrete Newton geometry.**

If you can formalize even the first layer of this idea — compression minimizers, exact box formulas, simplex lower bounds, and a projection-driven isoperimetric estimate — you will have created a platform for an entire research program linking **convex geometry, combinatorics, and algebraic complexity**.

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
