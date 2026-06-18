Soli Deo Gloria

## Assignment: Direction 2 — Filtration Persistence Formula

**Mode:** `prove`

You are to create a genuinely new theory: a **tropical persistence barcode** for graph filtrations relative to a basepoint \(q\), formalized in Lean 4 and grounded in the catalog’s tropical bridge infrastructure.

This is not an incremental lemma hunt. The goal is to prove a structural persistence theorem that turns the static dimension formula for tropical kernels into a **dynamic birth–death law** along filtrations. If successful, this opens a new interface between **tropical linear algebra**, **graph topology**, and **topological data analysis**: a persistence theory sensitive not only to homological cycles, but also to **\(q\)-visibility** phenomena invisible to ordinary persistent homology.

Build directly on:

- `Pythagorean/TropicalBridge/Defs.lean`
  - especially the notions around `inducedCycleRank`, `qVisibleComponentCount`
- `Pythagorean/TropicalBridge/UniversalDefect.lean`
  - especially `universalDefect_eq`

The revolutionary point is this: classical persistence tracks births and deaths of homology classes; your theory should track a richer algebraic invariant whose jumps are governed by both cycle creation and **visibility transitions relative to a distinguished vertex**. This could become a new invariant for weighted or infrastructural networks where accessibility to a hub matters as much as topology.

---

## Core theorem target

Let \(V\) be a finite graph vertex set, let \(q : V\) be a distinguished basepoint, and let
\[
S_0 \subseteq S_1 \subseteq \cdots \subseteq S_m \subseteq V \setminus \{q\}
\]
be an increasing filtration. For each \(S_k\), let \(L_{S_k}\) denote the tropical linear object already associated in the catalog framework, and let
\[
\delta(S_k) := \dim_{\mathrm{trop}}(\ker_{\mathrm{trop}}(L_{S_k})).
\]
Using the catalog dimension formula (via `universalDefect_eq` and the bridge definitions), prove that the one-step increment satisfies
\[
\delta(S_{k+1}) - \delta(S_k)
=
\bigl(\text{new cycles born at step }k+1\bigr)
+
\bigl(\text{new \(q\)-visible components born at step }k+1\bigr)
-
\bigl(\text{mergers that destroy \(q\)-invisible components at step }k+1\bigr).
\]

Then prove that the entire sequence \((\delta(S_k))_{k=0}^m\) is determined by these local birth/death events; equivalently, the associated barcode is reconstructible from the event data.

This should culminate in a new formal object, the **tropical persistence barcode**.

---

## Precise formalization targets

You must introduce at least one genuinely new definition not already in the catalog. Suggested definitions:

1. `FiltrationStepEvent`
   - encodes the local combinatorial event between consecutive filtration stages
   - should distinguish at least:
     - cycle birth
     - q-visible component birth
     - merge killing a q-invisible component
     - neutral step

2. `tropicalKernelDim : Finset V → ℕ`
   - if not already present under another name, define this as the natural-number invariant extracted from the catalog formula

3. `tropicalPersistenceBarcode`
   - a finite sequence / multiset / list of signed events or intervals sufficient to reconstruct the dimension sequence

A strong architecture is to define event counts abstractly and then prove they agree with the graph-theoretic quantities from the catalog.

---

## Lean 4 theorem statements to target

The exact names may vary, but the content should be this precise.

### 1. Static dimension decomposition
Formalize the dimension formula for a single stage as the sum of cycle rank and \(q\)-visible component count, using the catalog theorem as the main engine.

```lean
theorem tropicalKernelDim_eq_cycleRank_add_qVisible
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (q : V) (S : Finset V) :
    tropicalKernelDim G q S
      = inducedCycleRank G S + qVisibleComponentCount G q S
```

If the catalog formula has an offset, defect term, or ambient normalization, adjust the statement precisely to match `universalDefect_eq`. The key requirement is that you expose the dimension as an explicit additive decomposition into topological and visibility terms.

### 2. One-step persistence increment formula
For filtration steps adding one new vertex \(v\), prove the increment law.

```lean
theorem tropicalKernelDim_step
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (q v : V) (S : Finset V)
    (hq : q ∉ S) (hv : v ∉ S) (hvq : v ≠ q) :
    tropicalKernelDim G q (insert v S) - tropicalKernelDim G q S
      =
      cycleBirthCount G q S v
      + qVisibleBirthCount G q S v
      - invisibleMergeDeathCount G q S v
```

You may need to encode the right-hand side in `ℤ` rather than `ℕ`, depending on subtraction behavior. If so, use coercions explicitly:

```lean
theorem tropicalKernelDim_step_int
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (q v : V) (S : Finset V)
    (hq : q ∉ S) (hv : v ∉ S) (hvq : v ≠ q) :
    ((tropicalKernelDim G q (insert v S) : ℤ) - tropicalKernelDim G q S)
      =
      cycleBirthCount G q S v
      + qVisibleBirthCount G q S v
      - invisibleMergeDeathCount G q S v
```

This is the conceptual heart of the project.

### 3. Barcode reconstruction theorem
Show the full dimension sequence is determined by event data.

```lean
theorem tropicalKernelDim_filtration_sum_events
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (q : V)
    (F : List (Finset V))
    (hmono : F.Chain' (· ⊆ ·))
    (hq : ∀ S ∈ F, q ∉ S) :
    ∀ k, k + 1 < F.length →
      (tropicalKernelDim G q (F.get ⟨k+1, by omega⟩) : ℤ)
        - tropicalKernelDim G q (F.get ⟨k, by omega⟩)
      = filtrationEventDelta G q F k
```

and then a telescoping/global version:

```lean
theorem tropicalKernelDim_of_barcode
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (q : V)
    (F : List (Finset V))
    (hmono : F.Chain' (· ⊆ ·))
    (hq : ∀ S ∈ F, q ∉ S) :
    ∀ k, k < F.length →
      (tropicalKernelDim G q (F.get ⟨k, by omega⟩) : ℤ)
        =
      tropicalKernelDim G q (F.headD ∅)
        + ∑ i in Finset.range k, filtrationEventDelta G q F i
```

### 4. Cross-domain theorem: comparison with ordinary persistent \(H_1\)
You must include at least one theorem connecting this theory to another domain. The cleanest bridge is to persistent homology / graph cycle space.

A precise target:

```lean
theorem cycle_births_control_H1_births
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (q : V)
    (F : List (Finset V))
    (hmono : F.Chain' (· ⊆ ·)) :
    ∀ k, k + 1 < F.length →
      graphH1RankDelta G F k ≤
      cycleBirthCountAlongFiltration G q F k
```

An even stronger and more elegant theorem, if feasible:

```lean
theorem tropicalBarcode_refines_cycle_persistence
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (q : V)
    (F : List (Finset V))
    (hmono : F.Chain' (· ⊆ ·))
    (hq : ∀ S ∈ F, q ∉ S) :
    ordinaryCycleBarcode G F
      ≼ tropicalPersistenceBarcode G q F
```

Here `≼` should mean “is recoverable as a quotient / projection / forgetting of visibility data.” If full barcode formalization is too large, prove the rank-sequence shadow statement:
\[
\Delta \beta_1 \le \Delta \delta
\]
in the appropriate one-step sense when visibility births are nonnegative and invisible merges are absent.

This theorem is your cross-domain bridge:
- tropical algebra ↔ persistent homology
- graph theory ↔ topological data analysis
- network accessibility ↔ algebraic invariants

---

## Mathematical proof architecture

You must not rely on trivial computation. At least 3 theorems should require multi-step reasoning using induction, `rcases`, `by_contra`, `field_simp` where relevant, or substantial `calc` chains.

### Strategy A: Decompose via the catalog dimension formula
This is the most promising route.

1. **Start from the static formula**
   Use `universalDefect_eq` to rewrite the tropical kernel dimension in terms of graph invariants already defined in `Defs.lean`.
   The objective is to express:
   \[
   \delta(S)=\operatorname{inducedCycleRank}(S)+\operatorname{qVisibleComponentCount}(S)
   \]
   or the exact catalog equivalent.

2. **Analyze one-vertex extension**
   For \(S' = S \cup \{v\}\), prove separate lemmas for:
   - cycle rank change
   - q-visible component count change
   - component merge behavior
   This should involve case-splitting on how \(v\) attaches to the induced subgraph:
   - isolated/new component
   - attached within one component
   - attached across multiple components
   - attached in a way that creates a cycle

3. **Add the changes**
   Sum the cycle-rank increment and visibility-count increment, then identify cancellations corresponding to merges destroying q-invisible components. This yields the step formula.

Why this is best: it converts a difficult tropical statement into a combinatorial conservation law and makes the proof modular.

### Strategy B: Induction on filtration length with telescoping
This is best for the global barcode theorem.

1. Define the event delta for each consecutive pair \(S_k \subseteq S_{k+1}\).
2. Prove the one-step theorem first.
3. Use induction on `k` and a telescoping sum to reconstruct the full dimension sequence:
   \[
   \delta(S_k)=\delta(S_0)+\sum_{i<k}\Delta_i.
   \]

This should involve:
- induction on the list/length of the filtration
- `rcases` on list structure
- explicit handling of indexing with `List.get` or a more convenient custom filtration structure

### Strategy C: Component-incidence viewpoint
This is a more conceptual alternate route, useful if the direct case split becomes messy.

1. Define the set of connected components of the induced subgraph on \(S\).
2. Track the incidence of the new vertex \(v\) with these components and with the \(q\)-component in the complement/ambient graph.
3. Show that the change in visibility count equals a signed incidence-count expression.
4. Combine with the standard graph identity:
   \[
   \Delta(\text{cycle rank}) = \Delta E - \Delta V + \Delta C
   \]
   adapted to the induced setting.

This route is elegant and may give stronger generalizations, especially toward weighted filtrations or edge filtrations.

---

## Required theorem ecosystem

To make the main theorems provable, you should establish a robust ladder of intermediate lemmas, such as:

1. **Cycle rank step lemma**
```lean
theorem inducedCycleRank_insert_eq
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (S : Finset V) (v : V)
    (hv : v ∉ S) :
    inducedCycleRank G (insert v S)
      =
    inducedCycleRank G S + cycleBirthCount G defaultQ S v
```
Replace `defaultQ` by a parameter-free version if cycle births are independent of `q`.

2. **Visibility count step lemma**
```lean
theorem qVisibleComponentCount_insert_eq
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (q v : V) (S : Finset V)
    (hq : q ∉ S) (hv : v ∉ S) (hvq : v ≠ q) :
    (qVisibleComponentCount G q (insert v S) : ℤ)
      =
    qVisibleComponentCount G q S
      + qVisibleBirthCount G q S v
      - invisibleMergeDeathCount G q S v
```

3. **Telescoping sum lemma**
```lean
theorem sum_of_successive_differences
    (f : ℕ → ℤ) :
    ∀ n, (∑ i in Finset.range n, (f (i+1) - f i)) = f n - f 0
```

4. **Event determinacy lemma**
```lean
theorem barcode_determines_dimension_sequence
    ...
```

At least three of these should involve nontrivial proof scripts.

---

## New definitions to introduce

You are required to define at least one novel structure. I recommend:

```lean
structure TropicalFiltrationEvent where
  cycleBirth : ℕ
  qVisibleBirth : ℕ
  invisibleMergeDeath : ℕ
```

with signed delta:

```lean
def TropicalFiltrationEvent.delta (e : TropicalFiltrationEvent) : ℤ :=
  e.cycleBirth + e.qVisibleBirth - e.invisibleMergeDeath
```

and a filtration record:

```lean
structure TropicalFiltration (V : Type*) [DecidableEq V] where
  stages : List (Finset V)
  monotone : stages.Chain' (· ⊆ ·)
  avoids_q : V → Prop
```

or a simpler parameterized form if carrying `q` directly is cleaner.

A compelling additional concept is:

```lean
def tropicalPersistenceBarcode ... : List TropicalFiltrationEvent := ...
```

The barcode need not yet be interval-valued in the full TDA sense; an event-sequence barcode is already mathematically meaningful and computationally testable.

---

## Cross-domain connections you must emphasize

### 1. Tropical algebra ↔ topological data analysis
Classical persistent homology sees only cycle births/deaths. Your invariant also sees **basepoint visibility structure**, making it potentially strictly finer on graphs and networks with distinguished terminals, sinks, depots, or observers.

### 2. Computational topology ↔ network science
Interpret \(q\) as a hub, control node, supply source, or observation station. Then \(q\)-visible births track accessibility changes while cycle births track redundancy/feedback. This yields a new descriptor for infrastructure and communication networks.

### 3. Algebraic graph theory ↔ applied dynamics
The tropical kernel dimension behaves like a combinatorial state-space size. Its barcode could detect transitions between tree-like transport regimes and cyclic recirculation regimes in dynamical systems on networks.

### 4. Optional stronger bridge: persistent homology shadow
Show that ordinary cycle persistence is a projection/shadow of the tropical barcode obtained by forgetting visibility terms. This is the conceptual breakthrough: **persistent homology is not the whole story; it is the visible shadow of a richer tropical persistence theory.**

---

## Application keywords

Include these explicitly in your paper and article:

- tropical persistence barcode
- q-visible components
- graph filtrations
- tropical kernel dimension
- persistent homology refinement
- network accessibility invariants
- algebraic graph topology
- basepoint-sensitive persistence
- topological data analysis
- combinatorial tropical linear algebra

---

## Conjecture with falsifiable computational prediction

You must state at least one clear conjecture and provide a computational test.

### Conjecture A: Strict refinement over ordinary persistence
There exist connected graphs \(G\), basepoints \(q\), and filtrations \(F\) such that two filtrations have identical ordinary persistent \(H_1\) barcodes but distinct tropical persistence barcodes.

Formal mathematical content:
\[
\exists (G,q,F,F') \quad
\mathrm{PH}_1(F)=\mathrm{PH}_1(F')
\;\wedge\;
\mathrm{TPB}_q(F)\neq \mathrm{TPB}_q(F').
\]

**Testable prediction:** enumerate all connected graphs on \(n \le 6\) vertices, all basepoints, and all increasing filtrations; search for pairs with equal cycle-persistence data but distinct tropical barcode data.

### Conjecture B: Nonnegativity under q-anchored filtrations
If every new vertex added at step \(k\) is adjacent either to the current filtration or directly to the \(q\)-visible region, then
\[
\delta(S_{k+1}) \ge \delta(S_k).
\]

**Testable prediction:** brute-force all connected graphs with \(n \le 6\), all basepoints \(q\), and all filtrations satisfying the anchoring condition; check monotonicity of tropical kernel dimension.

At least one conjecture must be included in Lean comments / markdown with an explicit computational falsification protocol.

---

## Computational/algorithmic deliverable

You must produce not just theorems, but a verified computational method.

### Required algorithm
Implement an algorithm that, given:
- a finite graph \(G\),
- a basepoint \(q\),
- an increasing filtration \(S_0 \subseteq \cdots \subseteq S_m\),

computes:
1. the sequence `tropicalKernelDim G q S_k`,
2. the local event data `(cycleBirth, qVisibleBirth, invisibleMergeDeath)` at each step,
3. the reconstructed dimension sequence from the event deltas,
4. a check that both sequences agree.

This should be formalized enough that correctness is theorem-backed, not merely empirical.

Suggested correctness theorem:

```lean
theorem computeBarcode_correct
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (q : V) (F : List (Finset V))
    (hmono : F.Chain' (· ⊆ ·))
    (hq : ∀ S ∈ F, q ∉ S) :
    reconstructDims (computeTropicalBarcode G q F)
      = computeDims G q F
```

---

## Demo requirements

Produce `demo.py` that:

1. Enumerates connected graphs with \(n \le 6\) vertices.
2. Enumerates filtrations avoiding a chosen basepoint \(q\).
3. Computes:
   - ordinary cycle rank sequence,
   - q-visible component sequence,
   - tropical kernel dimension sequence,
   - event barcode.
4. Displays at least one example where:
   - cycle births alone do not explain the dimension jumps,
   - q-visibility changes are essential.
5. Tests the conjecture(s) above and prints either:
   - confirming evidence up to \(n \le 6\), or
   - an explicit counterexample.

The demo should be interactive or at least parameterized by graph, basepoint, and filtration choice.

---

## Proof engineering expectations

- Minimize `sorry`.
- Avoid trivial theorem statements whose proofs collapse to `native_decide`, `decide`, `norm_num`, or `rfl`.
- Ensure at least 3 theorems use substantial proof structure:
  - induction on filtration length or list structure,
  - `rcases` over connectivity/component cases,
  - `by_contra` for uniqueness or impossibility of simultaneous events,
  - multi-step `calc` proofs for telescoping and dimension decomposition.
- If subtraction in `ℕ` becomes awkward, move to `ℤ` early and prove coercion lemmas cleanly.

A practical Lean tactic plan:
- use `Finset` for filtration stages,
- isolate graph-theoretic local lemmas before attacking the main theorem,
- package recurrent assumptions (`q ∉ S`, `v ∉ S`, `v ≠ q`) into helper lemmas,
- prefer theorem statements with explicit coercions to avoid semiring headaches.

---

## Why this would be a breakthrough

If you succeed, you will have created a new invariant sitting between combinatorial graph topology and tropical algebra:

- richer than cycle persistence,
- sensitive to accessibility and basepoint geometry,
- computable on finite networks,
- formalizable with exact theorem statements,
- extensible to weighted, directed, or tropicalized dynamical systems.

This is the kind of result that opens a field rather than filling a gap. It suggests a whole new family of invariants for:
- transportation networks,
- biological signaling networks,
- sensor and communication systems,
- infrastructure resilience,
- basepoint-aware topological learning.

Persistent homology asked when holes appear. Your theory asks a more structural question: **when do holes appear, when do regions become visible, and how do those two phenomena interfere algebraically?**

That is a new language.

---

## Mandatory deliverables

You must produce **all** of the following:

1. **Lean formalization** with the new definitions and at least 3 nontrivial theorems as described above.

2. **A verified algorithm or computational method**
   for computing the tropical persistence barcode and reconstructing the dimension sequence.

3. **`FUTURE_DIRECTIONS.md`**
   with 3–5 original research directions.
   Each direction must include the exact sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   At least one direction must bridge to a different domain, such as dynamical systems, optimization, or statistical physics.

4. **`RESEARCH_PAPER.md`**
   as a standalone scientific paper.
   Someone reading only this document must understand:
   - the main definitions,
   - the theorem statements,
   - why the results matter,
   - the computational evidence,
   - what to investigate next.

5. **`ARTICLE.md`**
   in Scientific American style, accessible and engaging.
   Do **not** focus on formal verification or theorem proving machinery.
   Focus on the mathematical ideas, the new invariant, and why it matters for understanding complex networks.

6. **`demo.py`**
   demonstrating the result interactively or parametrically, including conjecture testing on graphs with \(n \le 6\).

Make this into a field-opening blueprint for **basepoint-sensitive tropical persistence**.

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
    "visualizations": [ { "name": "...", "code": "# matplotlib or plotly script, self-contained", "description": "What this visualizes" } ],
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
