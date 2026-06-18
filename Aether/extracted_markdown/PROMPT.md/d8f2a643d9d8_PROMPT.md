Soli Deo Gloria

## Assignment: Direction 4 — Tropical Persistence Stability and Network Robustness

**Mode:** prove

Build a field-opening bridge between tropical graph filtrations, persistent topology, and certified robustness. Do not merely restate classical bottleneck stability in tropical language: isolate the exact tropical mechanism, formalize a new stability interface for weighted graphs, and extract an algorithmic robustness certificate for noisy network data.

The central scientific claim is that **tropical Morse data on graphs is not just computable, but metrically well-conditioned**. If this is established in a structurally clean way, it opens a new program: tropical topological statistics for noisy infrastructure networks, biological interaction graphs, and learned weighted architectures.

Your task is to prove precise, nontrivial theorems in Lean 4, building explicitly on:

- `Catalog/Pythagorean/TropicalBridge/TropicalMorseGraphs.lean`
- theorem: `tropical_persistence_eq_classical`

and any available Mathlib material on finite sets, order structures, extended reals, Lipschitz maps, and graph-like finite combinatorial structures.

---

## Core Breakthrough Goal

Formalize and prove a **tropical bottleneck stability theorem for graph filtrations**, together with a computable robustness bound and at least one cross-domain theorem linking tropical persistence stability to another domain.

This should not be treated as an isolated lemma. The aim is to create a reusable framework:

1. a notion of weighted tropical filtration on a fixed finite graph,
2. a notion of tropical barcode/rank invariant induced by weights,
3. a sup-norm metric on weight functions,
4. a theorem showing 1-Lipschitz stability of the associated persistence data,
5. a verified computational method that turns edge-weight uncertainty into a certified topological uncertainty bound.

---

## Precise Theorem Targets

You should introduce at least one genuinely new definition not already present in the catalog. A promising candidate is a structure encoding a weighted tropical filtration on a fixed graph.

### Suggested new definition

Define a structure along the lines of:

```lean
structure TropicalGraphFiltration (V E : Type _) [Fintype V] where
  edgeWeight : E → ℝ
  incidence : E → V × V
```

or, if the catalog already fixes a graph object, define instead a perturbation/stability wrapper:

```lean
structure TropicalWeightPerturbation (E : Type _) where
  w₀ : E → ℝ
  w₁ : E → ℝ
  eps : ℝ
  bound : ∀ e, |w₀ e - w₁ e| ≤ eps
```

Also define a sup-distance on edge weights:

```lean
def weightSupDist {E : Type _} [Fintype E] (w w' : E → ℝ) : ℝ :=
  Finset.sup Finset.univ (fun e => |w e - w' e|)
```

or, if more convenient in Mathlib, an equivalent bounded-above formulation.

Define a tropical rank/profile/barcode proxy if the full barcode type is not already formalized. If barcodes are unavailable as a native structure, use a persistence rank function or interval decomposition surrogate that still supports a meaningful stability theorem.

---

## Theorem 1 — Tropical Rank 1-Lipschitz Stability

This theorem should be the formal engine. State it with full quantifiers.

### Mathematical statement
Let \(G\) be a fixed finite graph and let \(w,w' : E(G)\to\mathbb R\) be edge weights. Assume
\[
\|w-w'\|_\infty \le \varepsilon.
\]
Then for every filtration threshold \(t\), the sublevel graph induced by \(w\) at level \(t\) is contained in the sublevel graph induced by \(w'\) at level \(t+\varepsilon\), and conversely with \(w,w'\) exchanged. Consequently, the tropical persistent rank function is \(\varepsilon\)-interleaved, hence 1-Lipschitz in the sup norm.

### Lean 4 type signature target
A possible formulation:

```lean
theorem tropical_rank_interleaving_of_sup_bound
    {E : Type _} [Fintype E]
    (w w' : E → ℝ) (ε : ℝ)
    (hε : 0 ≤ ε)
    (hbound : ∀ e, |w e - w' e| ≤ ε) :
    ∀ t : ℝ, tropicalSublevelSet w t ⊆ tropicalSublevelSet w' (t + ε)
```

and the converse:

```lean
theorem tropical_rank_interleaving_of_sup_bound_symm
    {E : Type _} [Fintype E]
    (w w' : E → ℝ) (ε : ℝ)
    (hε : 0 ≤ ε)
    (hbound : ∀ e, |w e - w' e| ≤ ε) :
    ∀ t : ℝ, tropicalSublevelSet w' t ⊆ tropicalSublevelSet w (t + ε)
```

Then package this into a rank-function inequality, for example:

```lean
theorem tropical_rank_lipschitz
    {E : Type _} [Fintype E]
    (w w' : E → ℝ) (ε : ℝ)
    (hε : 0 ≤ ε)
    (hbound : ∀ e, |w e - w' e| ≤ ε) :
    tropicalInterleavedBy ε w w'
```

If the barcode object exists in the catalog, strengthen this directly to bottleneck distance. Otherwise, prove the interleaving/rank-function form first and derive the bottleneck statement through the catalog equivalence.

### Why this is a breakthrough
This is the theorem that turns tropical persistence from a symbolic invariant into a physically meaningful observable. It says that tropical topological phase signatures survive bounded measurement error. That is the mathematical threshold between “interesting formal gadget” and “deployable scientific invariant.”

---

## Theorem 2 — Tropical Bottleneck Stability via Classical Transfer

Exploit the catalog theorem `tropical_persistence_eq_classical` to transfer the classical bottleneck stability theorem into the tropical setting.

### Mathematical statement
For a fixed finite graph \(G\), if \(w,w' : E(G)\to \mathbb R\) satisfy
\[
\|w-w'\|_\infty \le \varepsilon,
\]
then the bottleneck distance between the corresponding tropical persistence barcodes is at most \(\varepsilon\):
\[
d_B(\mathrm{Bar}_\mathrm{trop}(w), \mathrm{Bar}_\mathrm{trop}(w')) \le \varepsilon.
\]

### Lean 4 type signature target
Something like:

```lean
theorem tropical_bottleneck_stability
    {E : Type _} [Fintype E]
    (w w' : E → ℝ) (ε : ℝ)
    (hε : 0 ≤ ε)
    (hbound : ∀ e, |w e - w' e| ≤ ε) :
    bottleneckDist (tropicalBarcode w) (tropicalBarcode w') ≤ ε
```

If `bottleneckDist` and `tropicalBarcode` are not yet formalized, state and prove the strongest available equivalent form, explicitly documenting the reduction through `tropical_persistence_eq_classical`.

### Required use of catalog theorem
You must explicitly build the proof around:

```lean
tropical_persistence_eq_classical
```

The ideal structure is:

1. show the tropical object equals or is canonically equivalent to the classical persistent object associated to the same weighted filtration,
2. invoke classical stability on the classical side,
3. transport the metric inequality back to the tropical side.

### Why this is a breakthrough
This establishes a rigorous transfer principle: tropical filtrations inherit the deep metric stability architecture of persistent homology. Once formalized, the same transfer pattern may apply to multidimensional persistence, sheaf persistence, tropical Laplacians, and tropical spectral signatures.

---

## Theorem 3 — Certified Robustness Radius for Tropical Topological Events

Move beyond pure existence and produce a verified computational certificate.

### Mathematical statement
Fix a graph \(G\), a weight function \(w\), and a topological event \(P\) determined by the barcode, such as:
- “there exists a bar of lifetime at least \(L\)”,
- “the number of connected components changes before threshold \(T\)”,
- “the first critical tropical cycle appears by time \(T\)”.

Suppose the barcode of \(w\) is separated from violation of \(P\) by margin \(\delta > 0\). Then any perturbation \(w'\) with
\[
\|w-w'\|_\infty < \delta/2
\]
preserves \(P\).

### Lean 4 type signature target
Abstractly:

```lean
theorem tropical_event_robust_of_margin
    {E : Type _} [Fintype E]
    (w w' : E → ℝ) (δ : ℝ)
    (hδ : 0 < δ)
    (hmargin : tropicalEventMargin w ≥ δ)
    (hpert : ∀ e, |w e - w' e| < δ / 2) :
    tropicalEventHolds w → tropicalEventHolds w'
```

Or for a specific event such as a long bar:

```lean
theorem long_bar_robust_under_weight_perturbation
    {E : Type _} [Fintype E]
    (w w' : E → ℝ) (L δ : ℝ)
    (hδ : 0 < δ)
    (hsep : hasBarLongerThan w (L + δ))
    (hpert : ∀ e, |w e - w' e| < δ / 2) :
    hasBarLongerThan w' L
```

### Why this is a breakthrough
This is the theorem that converts stability into **actionable certification**. It says not just that barcodes move little, but that scientifically meaningful conclusions are preserved under quantified uncertainty. This is the bridge to robust data analysis and network science.

---

## Cross-Domain Theorem Requirement

You must include at least one theorem that genuinely connects tropical persistence stability to a different mathematical domain.

### Recommended bridge: robustness in network science / reliability theory
Interpret edge weights as uncertain transmission costs, conductances, or delays. Prove that a tropical topological phase transition threshold is stable under bounded sensor noise.

A formal statement could be:

```lean
theorem component_merge_time_lipschitz
    {E : Type _} [Fintype E]
    (w w' : E → ℝ) :
    |mergeTime w - mergeTime w'| ≤ weightSupDist w w'
```

This connects tropical topology to optimization/network reliability because merge times correspond to thresholded connectivity transitions.

### Alternative bridge: metric geometry
Show that a tropical critical value functional is 1-Lipschitz as a map from the sup-norm space of weights to ℝ:

```lean
theorem tropical_critical_value_lipschitz
    {E : Type _} [Fintype E]
    (c : TropicalCriticalObservable E)
    (hmono : MonotoneObservable c) :
    LipschitzWith 1 (fun w => c.eval w)
```

This creates a direct bridge to analysis and metric geometry.

### Application keywords
Include these explicitly in your writeup and code comments:

**Application keywords:** topological data analysis, network robustness, uncertainty quantification, interleavings, bottleneck distance, tropical geometry, noisy measurements, certified inference, graph filtrations, phase transitions.

---

## Proof Architecture: 3 Strategy Paths

You must present and evaluate multiple proof routes, not just one.

### Strategy A — Direct ε-shift interleaving on sublevel filtrations
1. Define the tropical sublevel filtration \(F_w(t)\) by selecting edges with weight \(\le t\).
2. From the hypothesis \(|w(e)-w'(e)| \le \varepsilon\), prove
   \[
   e \in F_w(t) \Rightarrow e \in F_{w'}(t+\varepsilon)
   \]
   and symmetrically.
3. Upgrade these inclusions to an \(\varepsilon\)-interleaving of persistence modules/rank functions, then conclude stability.

**Why promising:** This is the cleanest proof if barcode machinery is partial. It uses order-theoretic monotonicity and elementary inequalities, making it robust in Lean.

### Strategy B — Transfer through `tropical_persistence_eq_classical`
1. Use the catalog theorem to identify tropical persistence with the classical persistence of the same filtration.
2. Invoke classical bottleneck/interleaving stability.
3. Transport the inequality back via the equivalence.

**Why promising:** This is the conceptually strongest path and should be the flagship theorem, because it shows tropical persistence is not merely analogous to classical persistence but canonically inherits its metric geometry.

### Strategy C — Rank invariant as a Lipschitz observable
1. Define the persistent rank function as an integer-valued observable on pairs \((a,b)\) with \(a \le b\).
2. Prove monotonicity under threshold shifts using explicit inclusions.
3. Derive barcode stability from rank-function stability if the barcode formalization is difficult.

**Why promising:** This is ideal if barcode interval decomposition is technically heavy in Lean. It still yields a deep theorem and a reusable API.

**Recommended order:** Prove Strategy A first as the engine, then implement Strategy B as the conceptual crown, and use Strategy C as fallback infrastructure if the barcode layer is incomplete.

---

## Required Deep Tactics

Your file must contain at least 3 substantial theorems proved using real mathematical reasoning. In particular, ensure the proof scripts genuinely use techniques such as:

- `rcases` to unpack graph/filtration/event hypotheses,
- `by_contra` for sharp stability-margin arguments,
- `field_simp` if rational threshold comparisons arise,
- induction if you define filtration accumulation over finite threshold sets,
- multi-step `calc` chains for absolute-value and order inequalities.

Do not allow the development to collapse into finite-case brute force.

---

## Suggested Supporting Lemmas

These should likely appear as intermediate results.

```lean
lemma mem_sublevel_of_mem_sublevel_of_close
    {E : Type _} [Fintype E]
    (w w' : E → ℝ) (ε t : ℝ)
    (hclose : ∀ e, |w e - w' e| ≤ ε)
    (he : e ∈ tropicalSublevelSet w t) :
    e ∈ tropicalSublevelSet w' (t + ε)
```

```lean
lemma sup_bound_of_weightSupDist_le
    {E : Type _} [Fintype E]
    (w w' : E → ℝ) (ε : ℝ)
    (h : weightSupDist w w' ≤ ε) :
    ∀ e, |w e - w' e| ≤ ε
```

```lean
lemma interleaving_symm_of_abs_bound
    {E : Type _} [Fintype E]
    (w w' : E → ℝ) (ε : ℝ)
    (hε : 0 ≤ ε)
    (hclose : ∀ e, |w e - w' e| ≤ ε) :
    tropicalInterleavedBy ε w w' ∧ tropicalInterleavedBy ε w' w
```

```lean
lemma event_preserved_under_bottleneck_small
    (B B' : TropicalBarcode)
    (ε δ : ℝ)
    (hε : bottleneckDist B B' < ε)
    (hmargin : barcodeEventMargin B > 2 * ε) :
    barcodeEventHolds B → barcodeEventHolds B'
```

---

## Falsifiable Conjecture With Computational Test

You must state at least one explicit conjecture and one clear test that could refute it.

### Conjecture
For every finite connected graph \(G\), the map
\[
w \mapsto \mathrm{Bar}_\mathrm{trop}(w)
\]
from edge weights with the sup norm to tropical barcodes with bottleneck distance is not only 1-Lipschitz, but **locally isometric on generic chambers** of weight space away from tropical critical collisions.

In other words, for generic weight functions \(w,w'\) lying in the same combinatorial chamber,
\[
d_B(\mathrm{Bar}_\mathrm{trop}(w), \mathrm{Bar}_\mathrm{trop}(w')) = \|w-w'\|_\infty
\]
for sufficiently small perturbations.

### Testable prediction
Sample random graphs and random weight vectors. Restrict to perturbations that preserve strict ordering of all relevant tropical critical values. Numerically compare bottleneck distance to sup-distance. If systematic strict inequality persists in generic chambers, the conjecture is false.

This is falsifiable and scientifically useful: if true, tropical persistence is not merely stable but metrically sharp.

---

## Implementation Targets in Lean

You should aim for a new file with a name in the spirit of:

- `Catalog/Pythagorean/TropicalBridge/TropicalPersistenceStability.lean`

and structure it so that later work can extend to higher-dimensional or multidimensional persistence.

Your Lean development should include:

1. **New definitions**
   - `weightSupDist`
   - `tropicalSublevelSet` or graph-filtration equivalent
   - `tropicalInterleavedBy`
   - `tropicalEventMargin` or a concrete robust event predicate

2. **At least 3 deep theorems**
   - sublevel-set inclusion under perturbation,
   - interleaving/rank stability,
   - bottleneck stability or certified event robustness,
   - plus one cross-domain theorem.

3. **A verified algorithm**
   - Given a graph, base weights, and perturbation budget `ε`, compute a certified upper bound on barcode displacement or certify preservation of a topological event.

A possible API:

```lean
def certifiedBarcodeShiftBound
    {E : Type _} [Fintype E] (w w' : E → ℝ) : ℝ := weightSupDist w w'
```

with theorem:

```lean
theorem certifiedBarcodeShiftBound_correct
    {E : Type _} [Fintype E]
    (w w' : E → ℝ) :
    bottleneckDist (tropicalBarcode w) (tropicalBarcode w')
      ≤ certifiedBarcodeShiftBound w w'
```

This is simple but scientifically meaningful: a verified certificate from raw perturbation data.

---

## demo.py Requirement

Provide `demo.py` that:

1. builds several finite weighted graphs,
2. computes original and perturbed tropical filtrations/barcode proxies,
3. estimates or computes bottleneck/rank-function displacement,
4. plots displacement versus perturbation magnitude,
5. highlights the certified upper bound \(d_B \le \|w-w'\|_\infty\),
6. tests the “local isometry on generic chambers” conjecture numerically.

The demo should be interactive enough to vary:
- graph family,
- number of vertices,
- noise level,
- perturbation distribution,
- chosen event threshold.

---

## Scientific Significance

If you succeed, you will have established the first robust-operational foundation for tropical persistence on weighted graphs. That changes the status of the subject.

It opens:
- tropical topological statistics under measurement uncertainty,
- certified phase-transition detection in noisy networked systems,
- tropical analogues of stability theory for learned or physical weighted architectures,
- future transfer to multiparameter tropical persistence and tropical sheaf invariants.

It also creates a deep methodological bridge:
**tropical geometry → persistent topology → uncertainty quantification → network science**.

That bridge is exactly the kind of unexpected synthesis that can seed a new subfield.

---

## Mandatory Deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain the exact phrases:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- stochastic processes,
- statistical mechanics,
- optimization,
- biological networks,
- materials science.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the definitions,
- the main theorems,
- why tropical stability is nontrivial,
- how the classical transfer works,
- the certified robustness interpretation,
- computational evidence and open problems.

A reader with no code access must be able to understand the discovery completely.

### 3. `ARTICLE.md`
Write in Scientific American style. Explain:
- what tropical persistence is,
- why stability matters,
- how small noise can or cannot change topological phase portraits,
- what applications become possible.

Do **not** focus on verification machinery. Focus on ideas and significance.

### 4. Verified algorithm / computational method
Not just theorem statements: provide an implemented, formally justified method computing a certified perturbation bound or event-preservation certificate.

### 5. `demo.py`
Interactive demonstration as described above.

---

## Final Emphasis

Do not settle for a cosmetic translation of a known theorem. The true target is a new theorem schema:

> **Tropical invariants on graphs are metrically stable observables with certifiable robustness margins.**

That schema can power an entire research program.

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
