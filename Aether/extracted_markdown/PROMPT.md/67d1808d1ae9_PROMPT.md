Soli Deo Gloria

## Assignment: Direction 1: Full k-WL Separation via Non-Uniform CFI Weights

**Mode:** `prove`

Prove a genuinely new theorem family showing that **tropical Morse spectra (TMS) escape every fixed level of the Weisfeiler–Leman hierarchy on weighted graphs**. This must not be a cosmetic extension of the catalog’s `tms_strictly_expressive_over_WL1`; the target is a field-opening separation result linking **descriptive complexity**, **persistent homology**, and **tropical filtrations**.

The vision is this: the Cai–Fürer–Immerman phenomenon says that for each fixed `k`, there are graph pairs invisible to `k`-WL. Your task is to show that once one equips those gadgets with carefully chosen **non-uniform edge or gadget weights**, a tropical/persistent invariant detects a topological asymmetry that `k`-WL still cannot see. If achieved, this would be the first theorem-level bridge from **finite model theoretic indistinguishability** to **barcode-level topological separation**.

---

## Core Breakthrough Goal

### Precise Mathematical Theorem Statement

Let `CFI k n` denote a weighted Cai–Fürer–Immerman pair built over the base cycle `C_n` with `n > k`, with gadget weights
\[
w(i)=\frac{1}{2i+1}
\]
assigned to the `i`-th gadget (or to the canonical gadget-edge family attached to vertex `i`), and let `TMSpectrum` be the tropical Morse spectrum already defined in the catalog.

You should formalize and prove a theorem of the following shape:

> **Theorem (Fixed-k WL blind, TMS visible).**  
> For every `k : ℕ`, there exists `n > k` and weighted graphs `G₁, G₂` such that:
> 1. `G₁` and `G₂` are `k`-WL equivalent;
> 2. `TMSpectrum G₁ ≠ TMSpectrum G₂`;
> 3. more sharply, the persistence barcode in homological degree `1` differs by at least one endpoint determined by the parity-twist gadget.

A more quantitative strengthening, if you can make it work:

> **Quantitative separation theorem.**  
> For every `k`, there exist `n > k`, weighted CFI graphs `G₁, G₂`, and a real number `τ` such that
> - `G₁ ≡ₖWL G₂`,
> - the filtered complexes induced by the tropical Morse filtration satisfy
>   \[
>   \beta_1^{G₁}(t)=\beta_1^{G₂}(t)\ \text{for all } t<τ,
>   \]
>   but
>   \[
>   \beta_1^{G₁}(τ)\neq \beta_1^{G₂}(τ),
>   \]
> - hence the `H₁` barcode has a distinguished interval endpoint in exactly one graph.

This is the mathematically meaningful target: **`k`-WL equivalence but a filtration-critical homology jump mismatch**.

---

## Lean 4 Formalization Target

You must introduce the missing `k`-WL abstraction in a way compatible with the catalog’s existing `WL1Equiv` and `TMSpectrum`.

A suggested Lean signature scaffold:

```lean
/-- k-dimensional Weisfeiler–Leman equivalence on weighted graphs. -/
def WLKEquiv (k : ℕ) (G H : WeightedGraph V) : Prop := ...

/-- A weighted CFI instance over a base graph with a parity twist and gadget weights. -/
structure WeightedCFIInstance (V : Type _) where
  base        : SimpleGraph V
  twistParity : Finset V
  gadgetWeight : V → ℚ
  -- additional fields specifying the CFI expansion

/-- The weighted graph extracted from a CFI instance. -/
def WeightedCFIInstance.toWeightedGraph
    (I : WeightedCFIInstance V) : WeightedGraph (CFIVertexType I) := ...

/-- Tropical Morse separation in degree 1. -/
def H1BarcodeSeparates (G H : WeightedGraph V) : Prop :=
  ∃ t, Betti1At G t ≠ Betti1At H t

/-- Main theorem: for every k there exists a k-WL-equivalent pair separated by TMS. -/
theorem exists_wlk_equiv_but_tms_separates :
    ∀ k : ℕ, ∃ (V : Type) [Fintype V] [DecidableEq V]
      (G H : WeightedGraph V),
      WLKEquiv k G H ∧ TMSpectrum G ≠ TMSpectrum H := by
  ...

/-- Stronger barcode-level version. -/
theorem exists_cfi_cycle_pair_h1_barcode_separation :
    ∀ k : ℕ, ∃ n : ℕ, n > k ∧
      ∃ (G H : WeightedGraph (Fin (someVertexCount n))),
        IsWeightedCFICyclePair n G H ∧
        WLKEquiv k G H ∧
        H1BarcodeSeparates G H := by
  ...
```

If the full generality above is too heavy for one cycle, prove a theorem specialized to base cycles first:

```lean
theorem cfi_cycle_nonuniform_weights_separate_tms_beyond_wlk :
    ∀ k : ℕ, ∃ n > k,
      let G := weightedCFIcycleLeft n (fun i => (1 : ℚ) / (2 * i.1 + 1))
      let H := weightedCFIcycleRight n (fun i => (1 : ℚ) / (2 * i.1 + 1))
      WLKEquiv k G H ∧ TMSpectrum G ≠ TMSpectrum H := by
  ...
```

If `TMSpectrum` is defined over `ℝ`, use `ℝ` instead of `ℚ`; if filtration values are ordered only abstractly, adapt accordingly. But the theorem statement must be exact and executable in Lean.

---

## New Definitions Required

You must define at least one genuinely new concept absent from the catalog. Recommended candidates:

1. **`WLKEquiv`**  
   A weighted `k`-WL equivalence notion, either via:
   - color refinement on `k`-tuples,
   - counting logic `C^k`,
   - or a finite pebble-game characterization.

2. **`ParityCriticalValue`**  
   The filtration threshold at which the parity cycle appears/disappears:
   ```lean
   def ParityCriticalValue (G : WeightedGraph V) : ℝ := ...
   ```

3. **`H1BarcodeSeparates`**  
   A proposition saying the degree-1 persistence barcodes differ at some endpoint.

4. **`NonUniformCFIWeight`**  
   A weight profile class with strict monotonicity and parity-breaking:
   ```lean
   structure NonUniformCFIWeight (V : Type _) where
     w : V → ℝ
     strict_anti_collision : ∀ ⦃a b⦄, a ≠ b → w a ≠ w b
     positive : ∀ a, 0 < w a
   ```

These definitions are not bookkeeping: they are the conceptual interface through which finite model theory talks to topological persistence.

---

## Build Directly on Catalog Results

Use the catalog aggressively and explicitly.

### Primary building blocks
- `Pythagorean/TropicalMorse/Theorems.lean`
  - `tms_strictly_expressive_over_WL1`
  - `spectral_gap_contrapositive`
- `Pythagorean/TropicalMorse/Defs.lean`
  - `TMSpectrum`
  - `WL1Equiv`

### How to build on them
1. **Upgrade the expressiveness theorem from `WL1Equiv` to `WLKEquiv k`.**  
   The prior theorem provides the pattern: identify a graph invariant invisible to a WL notion but visible to TMS. Your job is to replace degree-based color refinement by tuple-based equivalence.

2. **Use `spectral_gap_contrapositive` as a template for filtration sensitivity.**  
   Even if the final proof does not literally invoke spectral gap language, its logic is valuable: if a topological/spectral critical value differs, then TMS differs. Adapt this to the parity-critical `H₁` threshold.

3. **Preserve compatibility with `TMSpectrum`.**  
   Do not define a disconnected alternative invariant unless absolutely necessary. The point is to show that the catalog’s existing tropical Morse object already has unforeseen descriptive-complexity power.

---

## Proof Architecture: 3 Viable Strategies

You must pursue at least one strategy fully, but think through all three.

### Strategy A: Pebble-game invisibility + explicit filtration asymmetry
**Most promising.**

1. Formalize `WLKEquiv k G H` via the `k`-pebble counting game or tuple color refinement.
2. Import or reconstruct the classical CFI fact: for cycle base graphs with `n > k`, the twisted and untwisted CFI structures are `k`-WL equivalent.
3. Show that the non-uniform weight function destroys the cancellation symmetry in the parity cycle, producing a unique filtration value where one graph acquires an `H₁` class and the other does not.
4. Deduce `TMSpectrum G ≠ TMSpectrum H`.

**Why this is best:** it cleanly separates the proof into a **logic-indistinguishability lemma** and a **topological detection lemma**, which matches the conceptual breakthrough.

---

### Strategy B: Counting-logic invariance + barcode stability/instability dichotomy
1. Define `WLKEquiv` by equivalence in `C^k` counting logic.
2. Show the weighted CFI pair remains `C^k`-equivalent because the weights are assigned externally in a way not definable within `k` variables at the relevant scale.
3. Prove a barcode endpoint theorem: under strictly decreasing gadget weights, the parity-twist class contributes a unique endpoint equal to a min-plus or tropical aggregate of selected gadget weights.
4. Since that aggregate differs between the two parity types, the barcodes differ.

**Why it is powerful:** it frames the result as a theorem in **descriptive complexity with metric/topological semantics**.

---

### Strategy C: Tropical linearization of the parity cycle
1. Express the TMS critical values as tropical sums/minima over weighted cycle constraints.
2. Identify the CFI parity obstruction as a tropical linear relation that flips sign or feasibility between the two graph variants.
3. Prove that non-uniform weights force a unique minimizer, making the parity obstruction visible as a distinct tropical critical value.
4. Conclude barcode and spectrum separation.

**Why it matters:** this would reveal the separation as a theorem in **tropical geometry**, not only in graph topology. If successful, it opens an entirely new language for lower bounds in finite model theory.

---

## Minimal Theorem Package: At Least 3 Deep Theorems

Your file must contain at least three substantial theorems, proved with real mathematics. Suggested theorem suite:

### Theorem 1: Weighted CFI k-WL indistinguishability
```lean
theorem weighted_cfi_cycle_wlk_equiv
    (k n : ℕ) (hk : k < n)
    (w : Fin n → ℝ)
    (hw_pos : ∀ i, 0 < w i) :
    WLKEquiv k (weightedCFIcycleLeft n w) (weightedCFIcycleRight n w) := by
  ...
```
This should use induction on refinement rounds, `rcases` on tuple orbits, and nontrivial symmetry arguments.

### Theorem 2: Non-uniform weights create a parity-critical value split
```lean
theorem nonuniform_weights_force_h1_split
    (n : ℕ) (hn : 3 ≤ n)
    (w : Fin n → ℝ)
    (hstrict : StrictAnti w)
    (hpos : ∀ i, 0 < w i) :
    H1BarcodeSeparates (weightedCFIcycleLeft n w) (weightedCFIcycleRight n w) := by
  ...
```
This should involve multi-step `calc`, contradiction arguments, and explicit analysis of the filtration.

### Theorem 3: Full separation beyond fixed k
```lean
theorem exists_wlk_equiv_but_tms_separates
    (k : ℕ) :
    ∃ n > k,
      let w : Fin n → ℝ := fun i => 1 / (2 * (i.1 : ℝ) + 1)
      WLKEquiv k (weightedCFIcycleLeft n w) (weightedCFIcycleRight n w) ∧
      TMSpectrum (weightedCFIcycleLeft n w) ≠
      TMSpectrum (weightedCFIcycleRight n w) := by
  ...
```

### Recommended cross-domain theorem
Connect descriptive complexity to topology or tropical optimization:

```lean
theorem wlk_equiv_implies_counting_logic_agreement_but_not_tropical_h1
    (k : ℕ) :
    ∃ (G H : WeightedGraph V),
      WLKEquiv k G H ∧
      CountingLogicAgree k G H ∧
      H1BarcodeSeparates G H := by
  ...
```

This theorem is the bridge: **same finite-model-theoretic observables, different topological phase transition**.

---

## Mathematical Insight You Must Capture

The decisive phenomenon is not merely “weights differ.” It is:

- CFI parity gadgets encode a **global mod-2 obstruction** invisible to bounded-variable counting logic.
- Non-uniform weights convert that hidden obstruction into a **filtration ordering event**.
- Persistent `H₁` detects the moment when the parity cycle becomes realizable.
- Thus a bounded logical observer cannot distinguish the pair, but a topological observer tracking weighted critical values can.

That is the scientific narrative. Make the proof embody it.

---

## Cross-Domain Connections You Must Exploit

### 1. Descriptive complexity ↔ Persistent homology
Show that `k`-WL / `C^k` equivalence can fail to determine even low-dimensional persistence data.

### 2. Finite model theory ↔ Tropical geometry
Interpret filtration thresholds as tropical minima or piecewise-linear critical values. The parity twist becomes a tropical obstruction.

### 3. Graph isomorphism lower bounds ↔ Topological data analysis
This is potentially a new method for constructing graph invariants stronger than WL-type heuristics while remaining efficiently computable.

### 4. Logic ↔ Statistical physics
Optional but exciting: interpret the parity-critical threshold as a phase transition in a weighted constraint system. This could seed future work on energy landscapes and topological order parameters.

---

## Application Keywords

Use these throughout the paper and artifact descriptions:

**descriptive complexity, Weisfeiler–Leman hierarchy, Cai–Fürer–Immerman graphs, persistent homology, tropical Morse spectrum, weighted graph invariants, graph isomorphism, finite model theory, counting logic, pebble games, tropical geometry, barcode separation, topological phase transition, parity obstruction, algorithmic graph invariants**

---

## Computational Deliverable: Verified Algorithm

You must produce not just theorem statements, but a certified computational method.

### Required algorithmic artifact
Implement an algorithm that:
1. constructs weighted CFI cycle pairs for input `k, n`;
2. runs a `k`-WL or pebble-game equivalence checker;
3. computes the tropical Morse filtration / relevant `H₁` barcode summary;
4. reports a separating threshold if one exists.

A Lean-facing specification could be:

```lean
def detectCFISeparation (k n : ℕ) :
    Option (WeightedGraph V × WeightedGraph V × ℝ) := ...
```

with a correctness theorem of the form:

```lean
theorem detectCFISeparation_sound :
    ∀ {k n G H τ},
      detectCFISeparation k n = some (G, H, τ) →
      WLKEquiv k G H ∧ Betti1At G τ ≠ Betti1At H τ := by
  ...
```

This is crucial: the project should not only assert existence, but **compute witnesses**.

---

## Demo Requirement

Produce `demo.py` that:
- generates weighted CFI pairs for `k = 2, 3, 4`;
- visualizes the weight profile `w(i)=1/(2i+1)`;
- runs the WL-equivalence test;
- computes and plots the relevant `H₁` barcode summaries;
- highlights the unique differing endpoint or threshold.

The demo should make the theorem feel inevitable.

---

## Conjecture with Testable Prediction

You must state and computationally probe at least one falsifiable conjecture. Recommended:

> **Conjecture (Generic non-uniformity suffices).**  
> For every fixed `k`, for all sufficiently large cycle lengths `n > k`, and for a Zariski-open / full-measure set of positive gadget weight assignments `w : Fin n → ℝ_{>0}`, the weighted CFI pair over `C_n` is `k`-WL equivalent but TMS-separated in degree `1`.

### Clear falsification test
For each `k ∈ {2,3,4}`, sample many strictly positive distinct weight profiles. If a family of profiles yields identical TMS for all tested `n > k`, the conjecture is weakened or false.

A second sharper conjecture if you have time:

> **Conjecture (Single-endpoint rigidity).**  
> In the weighted CFI cycle pair with strictly monotone weights, exactly one `H₁` barcode endpoint differs between the twisted and untwisted graph.

This is excellent because it is precise, surprising, and computationally testable.

---

## What Would Make This Revolutionary

If you succeed, you will have shown that **topological weighted invariants can outrun the entire fixed-dimensional WL hierarchy**. That is not a local improvement; it changes the map.

It would suggest:
- a new class of graph invariants beyond color refinement;
- a topological route to lower bounds in finite model theory;
- a tropical reinterpretation of CFI obstructions;
- practical graph comparison tools informed by persistent homology rather than purely combinatorial refinement.

This could seed a new research program: **topological descriptive complexity**.

---

## Mandatory Deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 concrete research directions. Each direction must contain:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**
At least one direction must bridge to a different domain, such as statistical physics, optimization, or quantum information.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the exact theorem,
- why `k`-WL fails,
- why TMS succeeds,
- the role of weighted CFI constructions,
- algorithmic implications,
- and what to investigate next.

It must be readable without access to the code.

### 3. `ARTICLE.md`
Write in Scientific American style. Make it vivid and concept-driven.  
**Taboo:** do **not** focus on formal verification or machine verification. Focus on the mathematics and why it matters.

### 4. Verified algorithm / computational method
Not optional. Provide a soundness theorem for the separation detector or barcode witness extractor.

### 5. `demo.py`
Interactive or script-based demonstration of the result on small `k`.

---

## Final Standard

Do not settle for “there exists some weighted pair.” Force the theorem to explain **why parity becomes visible exactly through non-uniform tropical filtration**. The ideal result is:

- universal in fixed `k`,
- explicit in the witness family,
- barcode-level rather than merely scalar,
- algorithmically testable,
- and conceptually unifying across logic, topology, and tropical geometry.

This is how you turn a known lower-bound gadget into a new mathematical language.

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
