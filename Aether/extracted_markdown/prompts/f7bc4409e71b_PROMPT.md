## Assignment: Rate-distortion theory

Mode: **prove**

You are not being asked for a routine coding-theory formalization. You are being asked to carve out a **Lean-native rate-distortion and packing/covering theory for finite metric spaces**, in a form strong enough to become a reusable bridge between information theory, metric geometry, and learning-theoretic capacity bounds.

The existing catalog hints at the right axis:
- `capacity_bounds_convergence` suggests a fixed-point/capacity perspective.
- `boundary_separating_implies_metric_separated` gives a geometric route from separation data to metric separation.
- `height_bounds_sup_norm` suggests quantitative control tools in finite-dimensional normed settings.
- `nontrivial_cocycle_lower_bounds_instability` hints that obstruction/instability phenomena can force lower bounds.
- `tropical_profile_complete_for_bounded_architecture_congruence` suggests a possible tropical/combinatorial encoding of distortion profiles.

Your goal is to **formalize and prove nontrivial finite-metric coding bounds** that can serve as a seed crystal for genuine rate-distortion theory in Lean.

---

## Core Vision

For a finite metric space `(α, d)` and distortion threshold `D : ℝ`, define the smallest codebook size needed to represent every point within distortion `D`. This is the metric covering number at radius `D`. Dually, define the largest `D`-separated subset size, i.e. the packing number. Then prove **sharp finite inequalities** connecting these quantities.

This is the right breakthrough because it creates:
1. a formal bridge between **rate-distortion** and **metric entropy**,
2. a reusable toolkit for **learning theory**, **quantization**, **compression**, and **geometric approximation**,
3. a platform for later probabilistic Shannon-style formalizations.

Do not settle for isolated lemmas. Build a coherent mini-theory.

---

## Primary Theorem Targets

Work with concrete finite types and `PseudoMetricSpace` / `MetricSpace` assumptions as needed. Favor statements over `Fintype α` with codebooks represented by `Finset α` first; this keeps the formalization executable and combinatorial.

### 1. Packing-covering comparison theorem

Define:
- `isSeparated (C : Finset α) (r : ℝ) : Prop := ∀ ⦃x⦄, x ∈ C → ∀ ⦃y⦄, y ∈ C → x ≠ y → r ≤ dist x y`
- `isCovering (C : Finset α) (R : ℝ) : Prop := ∀ x : α, ∃ y ∈ C, dist x y ≤ R`
- `packingNumber (r : ℝ) : ℕ := Nat.sSup {n | ∃ C : Finset α, C.card = n ∧ isSeparated C r}`
- `coveringNumber (R : ℝ) : ℕ := Nat.sInf {n | ∃ C : Finset α, C.card = n ∧ isCovering C R}`

You may need a more Lean-friendly formulation using `Finset.sup'`, `sInf` over a nonempty bounded set, or explicit existence statements rather than global definitions at first.

### Precise theorem statement
For every finite metric space `α` and every `r > 0`:

> **Theorem (packing_covering_sandwich)**  
> If `α` is finite and nonempty, then
> \[
> M(2r) \le N(r) \le M(r),
> \]
> where `M(s)` is the maximum cardinality of an `s`-separated subset and `N(s)` is the minimum cardinality of an `s`-covering subset.

This is the finite-metric heart of coding bounds: packing lower-bounds codebook size, while maximal separated sets produce coverings.

### Lean 4 type signature target
A realistic first target is existence-form rather than `sSup/sInf`:

```lean
theorem exists_cover_of_maximal_separated
    {α : Type*} [Fintype α] [DecidableEq α] [PseudoMetricSpace α]
    (r : ℝ) :
    ∃ C : Finset α,
      isSeparated C (2 * r) ∧
      isCovering C r := ...
```

Then derive cardinality inequalities via extremal definitions:

```lean
theorem packing_le_covering
    {α : Type*} [Fintype α] [DecidableEq α] [PseudoMetricSpace α]
    {r : ℝ} (hr : 0 < r) :
    packingNumber (2 * r) ≤ coveringNumber r := ...
```

```lean
theorem covering_le_packing
    {α : Type*} [Fintype α] [DecidableEq α] [PseudoMetricSpace α]
    {r : ℝ} (hr : 0 < r) :
    coveringNumber r ≤ packingNumber r := ...
```

If the exact `packingNumber/coveringNumber` definitions are too heavy initially, prove the equivalent extremal form:

```lean
theorem card_le_of_separated_and_covering
    {α : Type*} [Fintype α] [DecidableEq α] [PseudoMetricSpace α]
    {S C : Finset α} {r : ℝ}
    (hS : isSeparated S (2 * r))
    (hC : isCovering C r) :
    S.card ≤ C.card := ...
```

This theorem alone is already nontrivial and powerful.

---

### 2. Greedy maximal-separated-set implies covering

This is the engine theorem. It is algorithmic and foundational.

> **Theorem (maximal separated implies covering)**  
> Let `C` be inclusion-maximal among `2r`-separated finite subsets. Then every point lies within distance `r` of some point of `C`.

This should be proved constructively using finiteness and insertion contradiction.

### Lean 4 type signature target

```lean
theorem maximal_separated_implies_covering
    {α : Type*} [Fintype α] [DecidableEq α] [PseudoMetricSpace α]
    {C : Finset α} {r : ℝ}
    (hsep : isSeparated C (2 * r))
    (hmax : ∀ x : α, x ∉ C → ¬ isSeparated (insert x C) (2 * r)) :
    isCovering C r := ...
```

This theorem is excellent because it is:
- constructive,
- combinatorial,
- reusable in all later metric entropy developments,
- close to actual greedy coding algorithms.

---

### 3. Diameter bound on codebook size

Push beyond the classical sandwich inequality. Prove a quantitative upper bound in terms of diameter and separation, at least for concrete spaces such as intervals, grids, or finite subsets of `ℚ^n` / `ℝ^n` with sup norm.

A good formal target is for finite subsets of `ℚ^n` with sup metric.

Let `α := Fin n → ℚ`, with `dist x y := ‖x - y‖∞` induced from the sup norm if convenient via existing instances, or define a finite grid subset.

> **Theorem (sup-norm packing bound on bounded boxes)**  
> If all coordinates lie in `[−B, B]` and a finite set `S` is `r`-separated in sup norm with `r > 0`, then
> \[
> |S| \le \left(\left\lfloor \frac{2B}{r} \right\rfloor + 1\right)^n.
> \]

This becomes a concrete rate upper bound for bounded sources and is a major bridge to quantization.

### Lean 4 type signature target
You may first prove a weaker but clean discrete version on integer or rational grids:

```lean
theorem card_le_grid_boxes_of_sup_separated
    {n : ℕ} {S : Finset (Fin n → ℚ)} {B r : ℚ}
    (hr : 0 < r)
    (hsep : ∀ ⦃x⦄, x ∈ S → ∀ ⦃y⦄, y ∈ S → x ≠ y →
      r ≤ Finset.univ.sup (fun i => |x i - y i|))
    (hbounded : ∀ x ∈ S, ∀ i, |x i| ≤ B) :
    S.card ≤ ((Nat.floor (2 * B / r)) + 1) ^ n := ...
```

If this exact statement is cumbersome, prove the 1-dimensional version first:

```lean
theorem card_le_of_separated_subset_interval
    {S : Finset ℚ} {B r : ℚ}
    (hr : 0 < r)
    (hsep : ∀ ⦃x⦄, x ∈ S → ∀ ⦃y⦄, y ∈ S → x ≠ y → r ≤ |x - y|)
    (hbounded : ∀ x ∈ S, |x| ≤ B) :
    S.card ≤ Nat.floor (2 * B / r) + 1 := ...
```

This is already a serious theorem and can be lifted later.

---

## Why this is a breakthrough

A verified finite-metric rate-distortion toolkit would open:
- **formal quantization theory** for approximation algorithms,
- **learning-theoretic capacity control** via covering numbers,
- **geometric compression** of finite datasets and latent spaces,
- **bridges to tropical and sheaf-theoretic complexity measures** already hinted at in the catalog.

This is not “coding bounds for metric spaces” as a slogan. It is the beginning of a **machine-checkable metric information theory**.

---

## Proof Strategy Architecture

### Strategy A: Extremal combinatorics via maximal separated sets
Most promising for the core theorems.

1. Define `isSeparated` and `isCovering` cleanly on `Finset α`.
2. Prove that any inclusion-maximal `2r`-separated `C` is an `r`-cover.
   - Suppose not: there exists `x` with `∀ y ∈ C, r < dist x y`.
   - Show `insert x C` remains `2r`-separated or adjust constants carefully depending on your chosen definition.
   - Contradict maximality.
3. Use nearest-center uniqueness/pigeonhole logic to show every `2r`-separated set injects into any `r`-cover, giving cardinality bounds.

Why this is strongest: it is fully finite, constructive, and independent of measure-theoretic machinery.

---

### Strategy B: Graph-theoretic reformulation
Potentially cleaner for cardinality inequalities.

Build the graph on `α` with edges `dist x y < r`.
- `r`-coverings correspond to dominating sets in the proximity graph.
- `r`-separated sets correspond to independent sets.
- Then prove inequalities using finite graph extremality.

This could be elegant if Mathlib graph support is convenient enough, but it risks overhead. Use only if direct metric-Finset proofs become messy.

---

### Strategy C: Quantization via bounded coordinate discretization
Best for the box-packing theorem.

1. Partition each coordinate interval into bins of width `< r`.
2. Map each point to its bin index tuple.
3. Show two distinct points in an `r`-separated sup-norm set must have different tuples.
4. Conclude by injectivity into a finite grid of size `((⌊2B/r⌋)+1)^n`.

Why this matters: this turns abstract covering theory into explicit finite-rate compression bounds.

---

## Catalog-building connections

You are required to build on the catalog theorems, even if only conceptually at first.

### Connection to `boundary_separating_implies_metric_separated`
Use this theorem as a geometric bridge: if a boundary-separation condition can be instantiated on a family of code regions/Voronoi-like cells, it should imply metric separation of codewords. This suggests a second theorem:

> If code cells are boundary-separated in the sense of the tropical lens rigidity file, then their representatives form a metric-separated code.

Even a specialized corollary would be valuable.

### Connection to `capacity_bounds_convergence`
Interpret covering numbers or inverse-distortion code sizes as a finite-step capacity approximation. Seek a monotonicity/convergence lemma:
- as distortion decreases, covering number is monotone nondecreasing,
- as radius increases, packing number is monotone nonincreasing.

These can later feed capacity-limit statements.

### Connection to `height_bounds_sup_norm`
This is especially relevant for bounded rational vectors. Use it to control coordinate magnitudes and convert arithmetic height bounds into explicit coding bounds in sup norm. This is a real cross-bridge from arithmetic learning theory to rate-distortion geometry.

### Connection to `nontrivial_cocycle_lower_bounds_instability`
Speculative but exciting: instability obstructions can force large covering numbers. If a family has a nontrivial cocycle obstruction, then no small codebook can stably represent it below some distortion threshold. Even a toy finite theorem here would be field-opening.

### Connection to `tropical_profile_complete_for_bounded_architecture_congruence`
This suggests a tropical encoding of distortion profiles. Long-term, codebooks may correspond to tropical prototypes and distortion classes to tropical cells. At minimum, mention this in FUTURE_DIRECTIONS as a route to tropical rate-distortion.

---

## Cross-domain connections you should actively exploit

1. **Information theory × metric geometry**  
   Covering numbers are finite analogues of rate-distortion functions.

2. **Learning theory × approximation theory**  
   Metric coverings quantify model capacity and compression tradeoffs.

3. **Arithmetic geometry × quantization**  
   Height/sup-norm bounds give explicit finite codebook bounds for rational data.

4. **Tropical geometry × coding regions**  
   Voronoi-like or polyhedral distortion cells may admit tropical descriptions.

5. **Graph theory × coding**  
   Separated sets and coverings become independence and domination problems.

Application keywords:
**rate-distortion, covering number, packing number, metric entropy, quantization, lossy compression, finite metric spaces, sup norm, bounded height, learning theory, capacity bounds, tropical coding, graph domination, independent sets**

---

## Concrete Lean deliverables

1. A file introducing finite-metric coding definitions:
   - `isSeparated`
   - `isCovering`
   - `packingNumber`
   - `coveringNumber`
   - monotonicity lemmas

2. At least one major proved theorem from the core targets:
   - preferably `card_le_of_separated_and_covering`
   - plus `maximal_separated_implies_covering`

3. One concrete quantitative theorem on bounded subsets of `ℚ` or `Fin n → ℚ`.

4. Minimize `sorry`. If one theorem is too ambitious, prove the strongest special case fully.

5. Create `FUTURE_DIRECTIONS.md` with 3–5 specific next steps.

---

## Recommended theorem order

1. Define `isSeparated` and prove basic lemmas:
   - monotonicity under subset,
   - singleton separation,
   - empty/singleton covering edge cases.

2. Prove:
```lean
theorem card_le_of_separated_and_covering ...
```

3. Prove:
```lean
theorem maximal_separated_implies_covering ...
```

4. Package extremal definitions and derive:
```lean
theorem packing_le_covering ...
theorem covering_le_packing ...
```

5. Prove a concrete interval or sup-norm box bound.

---

## Stretch theorem: finite metric rate upper bound

If the core development succeeds, define:
```lean
def minCodeSize (D : ℝ) : ℕ := coveringNumber D
def rateUpperBound (D : ℝ) : ℝ := Real.log (minCodeSize D) / Real.log 2
```
and prove monotonicity:
```lean
theorem minCodeSize_monotone {D₁ D₂ : ℝ} (h : D₁ ≤ D₂) :
    minCodeSize D₂ ≤ minCodeSize D₁ := ...
```

This begins a Lean-native finite rate-distortion function.

---

## Required FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md` with **3–5 concrete next theorems**, each including:
- precise theorem statement,
- likely Lean type signature,
- proof strategy,
- cross-domain significance.

It must include at least:
1. a probabilistic extension toward Shannon rate-distortion on finite source distributions,
2. a tropical/polyhedral coding-region theorem,
3. a learning-theoretic application using covering numbers as capacity measures.

Be bold: the point is not merely to formalize old coding theory, but to create a new verified language in which compression, geometry, and learning become the same theorem seen from three angles.

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
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

**Team Directive**: Create a team to conduct research, brainstorm hypotheses,
run experiments, validate data, update knowledge base and iterate forever.
Each future direction should be specific enough for a team to pick up and
pursue with clear hypotheses, proof strategies, and cross-domain connections.

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
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: prove
