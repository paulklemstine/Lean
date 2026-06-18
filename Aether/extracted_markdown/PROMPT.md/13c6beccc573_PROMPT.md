Soli Deo Gloria

## Assignment: Direction 3 — Tropical Morse Spectra as Quantum Graph State Classifiers

**Mode:** prove

You are not being asked for an incremental lemma. You are being asked to forge a mathematically precise bridge between **tropical Morse theory**, **graph-theoretic models of CSS quantum codes**, and **topological quantum information**. The goal is to extract code-theoretic invariants from a tropical filtration on interaction graphs, in a way that is both formally robust and computationally testable.

This direction is revolutionary because it proposes that a spectral object from tropical geometry — a **tropical Morse spectrum** attached to a weighted interaction graph — can recover the two central parameters of a quantum code:

- the number of logical qubits, and
- the code distance.

If correct even in a carefully delimited regime, this opens an entirely new program: **optimize quantum codes by tropical topological methods**. It would create a vocabulary in which logical operators become tropical critical events, code distance becomes a Morse gap, and homological redundancy becomes a classifier for encoded information. That is not a variant of existing work. That is a new research interface.

## Core mathematical mission

Formalize and prove the strongest correct theorems you can around the following principle:

> For graph-derived CSS codes, the tropical Morse spectrum of the interaction graph detects homological logical content, and under explicit hypotheses the first nontrivial tropical cycle event controls or equals the code distance.

You must be bold but mathematically honest: if equality is too strong in full generality, prove sharp inequalities, characterize the exact regime of equality, and isolate a falsifiable conjecture beyond the proven range.

---

## New formal objects to introduce

You must define at least one genuinely new concept not already present in the catalog. The most promising definitions are:

1. **Tropical Morse Spectrum** of a weighted graph:
   - a finite set or ordered list of critical filtration values at which the cycle rank changes;
   - or a multiset of such values if multiplicities matter.

2. **Minimum tropical cycle gap**:
   - the least positive critical value associated to the birth of a nontrivial 1-cycle in the filtration.

3. **Graph-CSS realizability structure**:
   - a structure encoding the hypotheses under which a weighted graph models a CSS code and the graph-theoretic cycle space corresponds to logical \(X\)-operators.

A possible Lean-facing structure:

```lean
structure GraphCSSModel (V : Type _) [Fintype V] [DecidableEq V] where
  G : SimpleGraph V
  w : Sym2 V → ℕ
  xCycleRealizesLogical : Prop
  zCocycleRealizesLogical : Prop
  finiteCriticalSet : Prop
```

or a lighter-weight version if catalog constraints suggest using predicates instead of structures.

---

## Precise theorem targets

You must prove at least 3 nontrivial theorems. At least one must connect tropical Morse theory to a different domain, namely quantum information / coding theory.

Below are theorem targets with mathematically precise statements and suggested Lean 4 signatures. Adapt the exact signatures to the existing catalog APIs, but keep the semantic content.

### Theorem 1: Tropical Morse logical-qubit correspondence

This is the foundational bridge theorem. Build directly on:

- `Pythagorean/TropicalMorse/Theorems.lean`
  - `redundant_edges_eq_cycle_rank`
  - `morse_betti_correspondence`

**Mathematical statement.**  
Let \(G\) be a finite connected interaction graph of a graph-derived CSS code, in a regime where logical \(X\)-operators are identified with nontrivial graph cycles. Then the number of logical qubits equals the first Betti number of \(G\), hence equals the tropical Morse 1-dimensional Betti count extracted from the spectrum.

A Lean-facing version:

```lean
theorem logicalQubits_eq_beta1_of_graphCSS
    {V : Type _} [Fintype V] [DecidableEq V]
    (M : GraphCSSModel V)
    (hconn : M.G.Connected)
    (hX : M.xCycleRealizesLogical) :
    logicalQubits M = M.G.cycleRank
```

If `cycleRank` is not the existing name, phrase it using the catalog theorem reducing to redundant edges or β₁:

```lean
theorem logicalQubits_eq_beta1_of_graphCSS
    {V : Type _} [Fintype V] [DecidableEq V]
    (M : GraphCSSModel V)
    (hconn : M.G.Connected)
    (hX : M.xCycleRealizesLogical) :
    logicalQubits M = firstBettiNumber M.G
```

And then derive:

```lean
theorem logicalQubits_eq_tropicalBetti1_of_graphCSS
    {V : Type _} [Fintype V] [DecidableEq V]
    (M : GraphCSSModel V)
    (hconn : M.G.Connected)
    (hX : M.xCycleRealizesLogical) :
    logicalQubits M = tropicalBetti1 M.G M.w
```

**Why this matters.**  
This is the cleanest certified statement that tropical Morse data can recover encoded quantum information. It transforms a coding-theoretic invariant into a topological spectral invariant.

---

### Theorem 2: Code distance is bounded below by the first tropical cycle critical value

This is likely the first universally provable distance theorem.

**Mathematical statement.**  
For a graph-CSS model in which every logical \(X\)-operator contains a nontrivial cycle born at a tropical critical value, the minimum distance is at least the minimum critical value at which a nontrivial 1-cycle appears in the tropical filtration.

```lean
theorem firstCycleCriticalValue_le_codeDistance
    {V : Type _} [Fintype V] [DecidableEq V]
    (M : GraphCSSModel V)
    (hconn : M.G.Connected)
    (hreal : M.xCycleRealizesLogical) :
    minTropicalCycleGap M.G M.w ≤ codeDistance M
```

Depending on the filtration convention, the inequality may reverse. What matters is to make the semantics exact:

- if filtration value equals support size / weight threshold, then first cycle birth should be a lower bound on distance;
- if “gap” measures jump size rather than level, then distance may equal a transformed quantity.

Do not force equality unless the formal model truly supports it.

**Why this matters.**  
Even a lower bound is important: it gives a new **certified spectral estimator** for code distance, potentially easier to compute than exhaustive logical-operator search.

---

### Theorem 3: Equality under girth-realization / unweighted CSS cycle hypothesis

Now isolate the regime in which the lower bound becomes exact.

**Mathematical statement.**  
Suppose the graph-derived CSS code is such that every minimum-weight logical \(X\)-operator is represented by a simple cycle and the filtration weight is edge-count filtration. Then the code distance equals the girth, which equals the first nonzero tropical cycle critical value.

```lean
theorem codeDistance_eq_minTropicalCycleGap_of_cycleModel
    {V : Type _} [Fintype V] [DecidableEq V]
    (M : GraphCSSModel V)
    (hconn : M.G.Connected)
    (hreal : M.xCycleRealizesLogical)
    (hmin : minimumLogicalsAreSimpleCycles M)
    (hunif : isUnitEdgeWeight M.w) :
    codeDistance M = minTropicalCycleGap M.G M.w
```

An intermediate theorem may be easier and more honest:

```lean
theorem codeDistance_eq_girth_of_cycleModel
    {V : Type _} [Fintype V] [DecidableEq V]
    (M : GraphCSSModel V)
    (hconn : M.G.Connected)
    (hreal : M.xCycleRealizesLogical)
    (hmin : minimumLogicalsAreSimpleCycles M)
    (hunif : isUnitEdgeWeight M.w) :
    codeDistance M = graphGirth M.G
```

followed by

```lean
theorem minTropicalCycleGap_eq_girth_of_unitWeights
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (w : Sym2 V → ℕ)
    (hunif : isUnitEdgeWeight w) :
    minTropicalCycleGap G w = graphGirth G
```

Then combine by transitivity.

**Why this matters.**  
This theorem would identify a natural exact regime where tropical Morse theory computes a central quantum coding invariant without approximation. That is a genuine field-opening theorem.

---

## Stronger optional theorem if feasible

If the catalog already supports sufficient graph homology and filtration machinery, aim for:

### Theorem 4: Tropical Morse spectrum determines logical rank and detects distance for planar surface-code graphs

```lean
theorem surfaceCode_parameters_from_TMS
    (n : ℕ) (hn : 2 ≤ n) :
    let M := surfaceCodeModel n
    logicalQubits M = 1 ∧
    codeDistance M = minTropicalCycleGap M.G M.w
```

This would be spectacular, especially if instantiated for odd \(n = 3,5,7\) and generalized thereafter.

---

## Proof architecture: multiple strategies

You must not give a one-line proof hint. You must pursue 2–3 plausible proof routes and choose the most promising.

### Strategy A: Direct Morse-to-Betti-to-logical chain
1. Use `morse_betti_correspondence` to identify 1-dimensional tropical Morse events with β₁ information.
2. Use `redundant_edges_eq_cycle_rank` to compute β₁ graph-theoretically.
3. Prove that in a graph-CSS model, independent logical \(X\)-operators correspond to independent cycle classes.
4. Conclude `logicalQubits = β₁ = tropicalBetti1`.

**Why promising:** This directly exploits the catalog and turns existing theorems into a new coding-theoretic interpretation.

### Strategy B: Minimal logical operator as minimal nontrivial cycle
1. Define logical \(X\)-operator support size as a graph weight.
2. Show any nontrivial logical operator induces a cycle in the interaction graph.
3. Prove by contradiction that a smaller tropical cycle event would produce a smaller logical operator, violating minimality.
4. Deduce lower bound or equality with the first cycle critical value.

**Why promising:** This is the cleanest route to the distance theorem, especially in the unit-weight simple-cycle regime.

### Strategy C: Filtration and persistent-homology viewpoint
1. Define the edge-threshold filtration \(G_{\le t}\).
2. Track the first \(t\) for which \(H_1(G_{\le t})\) is nontrivial.
3. Identify this threshold with the first tropical cycle critical value.
4. Show that in graph-derived CSS models, logical \(X\)-operators appear exactly when \(H_1\) becomes nontrivial.

**Why promising:** Conceptually deepest and best for future generalization to persistent invariants and nonbinary codes.

**Recommended priority:**  
Start with **Strategy A** for the logical-qubit theorem and **Strategy B** for the distance theorem. Use **Strategy C** to organize definitions and future directions, even if some persistent-homology formalization remains partial.

---

## Required deep proof tactics

At least 3 theorems must require real reasoning, not computation. Use:
- induction on filtration levels or edge insertions,
- `rcases` decompositions of cycle/noncycle cases,
- `by_contra` to rule out smaller logical operators,
- `field_simp` if rational filtration values arise,
- multi-step `calc` proofs chaining catalog theorems and your new lemmas.

Examples of proof shapes you should aim for:
- induction on the number of edges in a spanning forest plus redundant edges;
- contradiction from a hypothetical smaller critical gap;
- `rcases` on whether an added edge closes a cycle in the filtration.

Do **not** trivialize theorem statements so they can be discharged by `native_decide`, `decide`, `norm_num`, or `rfl`.

---

## Cross-domain connections you must explicitly develop

This project lives at a three-way interface:

### 1. Quantum information theory ↔ Tropical geometry
Interpret code parameters through tropical critical values and spectra.

### 2. Algebraic topology ↔ Quantum error correction
Logical qubits as first homology / cycle-rank data.

### 3. Spectral graph theory / combinatorics ↔ Fault-tolerant quantum architecture
Use graph filtrations to estimate or optimize code distance.

If possible, include one theorem or definition that points toward:
- **persistent homology**, or
- **statistical mechanics of decoding**, or
- **Hamiltonian complexity / graph states**.

A particularly compelling bridge would be a theorem showing that monotone increases in certain edge weights cannot decrease the tropical lower bound on code distance.

For example:

```lean
theorem monotone_weights_monotone_distanceBound
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) {w₁ w₂ : Sym2 V → ℕ}
    (hmono : ∀ e, w₁ e ≤ w₂ e) :
    minTropicalCycleGap G w₁ ≤ minTropicalCycleGap G w₂
```

This would connect optimization and robustness.

---

## Computational and experimental component

You must produce a **verified algorithm or computational method**, not just theorem statements.

### Required algorithm
Implement a certified or semi-certified procedure that:
1. takes a finite weighted graph,
2. computes the tropical Morse spectrum or at least the first cycle critical value,
3. computes β₁ / cycle rank,
4. compares these with graph-CSS code parameters when a code model is supplied.

Potential algorithm names:
- `computeTMS`
- `firstCycleBirth`
- `estimateCodeDistanceFromTMS`

A Lean-facing spec sketch:

```lean
def firstCycleBirth
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (w : Sym2 V → ℕ) : ℕ := ...
```

with correctness theorem:

```lean
theorem firstCycleBirth_spec
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (w : Sym2 V → ℕ) :
    isFirstCycleCriticalValue G w (firstCycleBirth G w)
```

Then connect algorithm to code bounds:

```lean
theorem firstCycleBirth_certifies_distance_bound
    {V : Type _} [Fintype V] [DecidableEq V]
    (M : GraphCSSModel V)
    (h : M.xCycleRealizesLogical) :
    firstCycleBirth M.G M.w ≤ codeDistance M
```

### Required `demo.py`
Your demo must:
- build explicit interaction graphs for:
  - the Steane-like graph model,
  - the Shor-like graph model,
  - surface-code grid graphs for \(n=3,5,7\),
- compute the tropical Morse spectrum or first cycle birth,
- print predicted logical qubits and predicted distance,
- compare against known or model-assigned parameters.

The demo should allow a user to perturb edge weights and observe how the tropical estimate changes. This is where the research becomes exploratory science rather than static theorem proving.

---

## Falsifiable conjectures with computational tests

You must state at least one conjecture that could be disproved by computation.

### Main conjecture
For graph-derived CSS codes in the simple-cycle unit-weight regime:
\[
d(M) = \min \operatorname{TMS}(M.G, M.w),
\qquad
k(M) = \beta_1(M.G).
\]

Lean-facing conjecture placeholder:

```lean
conjecture graphCSS_distance_eq_firstCycleBirth
    {V : Type _} [Fintype V] [DecidableEq V]
    (M : GraphCSSModel V)
    (hconn : M.G.Connected)
    (hreal : M.xCycleRealizesLogical)
    (hmin : minimumLogicalsAreSimpleCycles M)
    (hunif : isUnitEdgeWeight M.w) :
    codeDistance M = firstCycleBirth M.G M.w
```

### Test protocol
1. Construct graph models for:
   - `[[7,1,3]]` Steane,
   - `[[9,1,3]]` Shor,
   - surface-code families on \(n \times n\) grids for \(n=3,5,7\).
2. Compute:
   - `β₁`,
   - first cycle birth,
   - minimum tropical cycle gap,
   - assigned / known code distance.
3. Falsify the conjecture if any tested graph-CSS model violates the predicted equality.

### Stronger speculative conjecture
For planar surface-code interaction graphs with uniform weights, the full tropical Morse spectrum determines not only \(k\) and \(d\) but also the hierarchy of low-weight logical operators.

This is ambitious and likely beyond the first cycle, but it points toward a future “spectral decoding” theory.

---

## Building explicitly on catalog theorems

Do not merely cite the catalog. Use it as a scaffold.

### `redundant_edges_eq_cycle_rank`
Use this to convert graph combinatorics into a computable homological invariant:
- redundant edges beyond a spanning forest = cycle rank = β₁.
- This is the natural quantity for logical qubit count in graph-CSS models.

### `morse_betti_correspondence`
Use this to justify that tropical Morse critical events recover the same β₁ data from the filtration:
- once β₁ is encoded in the Morse data, logical qubits become a tropical spectral invariant.

This is the exact lineage of the project:
\[
\text{Tropical Morse data} \to \beta_1 \to \text{logical qubits},
\]
and, under stronger hypotheses,
\[
\text{first cycle birth} \to \text{minimum logical support} \to \text{distance}.
\]

---

## Suggested file and theorem organization

Create a focused Lean file, for example:

- `Pythagorean/TropicalMorse/QuantumGraphCodes.lean`

Possible theorem names:
- `logicalQubits_eq_beta1_of_graphCSS`
- `logicalQubits_eq_tropicalBetti1_of_graphCSS`
- `firstCycleCriticalValue_le_codeDistance`
- `codeDistance_eq_girth_of_cycleModel`
- `codeDistance_eq_minTropicalCycleGap_of_cycleModel`
- `monotone_weights_monotone_distanceBound`

---

## Application keywords

Include these explicitly in your paper and metadata-style summaries:

- tropical Morse spectrum
- CSS quantum code
- code distance
- logical qubits
- graph state classifier
- Betti number
- cycle rank
- tropical filtration
- persistent homology
- topological quantum error correction
- surface code
- spectral invariant
- graph-state optimization
- homological decoding
- fault-tolerant quantum computing

---

## What breakthrough this would open

If you can prove even the bounded version cleanly and the exact version under a natural hypothesis, you create a new toolkit:

- **Spectral certification of quantum code quality** without exhaustive logical search.
- **Topological optimization of code architectures** by modifying graph weights to enlarge tropical cycle gaps.
- A pathway toward **persistent-homological decoding heuristics**.
- A conceptual bridge between tropical geometry and quantum information that others can extend to:
  - hypergraph product codes,
  - subsystem codes,
  - LDPC quantum codes,
  - Hamiltonian graph states.

This is exactly the kind of result that can seed an entire research area.

---

## Mandatory deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must include the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- persistent homology,
- statistical mechanics of decoding,
- Hamiltonian complexity,
- tropical optimization for quantum hardware layouts.

### 2. `RESEARCH_PAPER.md`
A standalone scientific document. A reader with no access to the code must understand:
- the definitions,
- the main theorems,
- what was proved versus conjectured,
- why it matters,
- what to investigate next.

Write it like a real paper, not notes.

### 3. `ARTICLE.md`
Scientific American style. Engaging and accessible. Explain the mathematical and physical ideas.  
**Taboo:** do **not** focus on formal verification or theorem proving infrastructure. Focus on the science.

### 4. Verified algorithm or computational method
Implement and verify a procedure computing the tropical spectral quantity relevant to the theorem.

### 5. `demo.py`
Interactive demonstration of the theorem/conjecture on the specified code families and graph examples.

---

## Final directive

Do not retreat to toy lemmas. If full equality is too strong, prove the exact frontier:
- unconditional β₁/logical-qubit correspondence,
- rigorous distance lower bound from tropical cycle birth,
- exact equality in the simple-cycle unit-weight regime.

That triad alone would already be a genuine breakthrough: it would establish that tropical Morse spectra are not decorative invariants, but **operational classifiers of quantum graph codes**.

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
