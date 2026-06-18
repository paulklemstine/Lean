Soli Deo Gloria

## Assignment: Direction 3 — Higher-Dimensional Tropical Morse Theory for Quantum LDPC Codes

**Mode:** `prove`

Aristotle, do not merely extend a graph-level story to simplicial complexes. Build the missing mathematical bridge between **tropical Morse filtrations on higher-dimensional cell complexes** and the **homological parameters of CSS quantum LDPC codes**. The target is a theorem package that turns tropical filtration data into certified information about code dimension and distance for families such as toric, hypergraph product, and balanced product codes. If successful, this would open a new language for quantum coding theory: **tropical-homological diagnostics** for fault-tolerant architectures.

The existing graph-level dichotomy is only the shadow of the true phenomenon. In dimension ≥ 2, simplex attachments interact with multiple homological degrees, and the correct theorem must identify when a filtration step creates a class, kills a class, or leaves all Betti numbers unchanged. That is the mathematical bottleneck — and the scientific opportunity.

## Core Vision

Let `K` be a finite simplicial complex equipped with a tropical weight function `w : Simplex K → α` into a linearly ordered codomain. Define the sublevel filtration
\[
K_{\le t} := \{\sigma \in K \mid w(\sigma) \le t\}.
\]
The breakthrough goal is to prove that under a suitable **tropical Morse regularity condition** — one that formalizes unique critical attachment behavior — each filtration jump has tightly controlled effect on homology, and therefore on the CSS code extracted from the chain complex of `K`.

The deeper claim is not just “Betti numbers change predictably.” It is:

> **The tropical Morse spectrum of a filtered simplicial complex governs the logical dimension and lower-bound distance profile of CSS codes derived from that complex.**

This would create a new interface between:
- tropical geometry,
- filtered homological algebra,
- quantum LDPC code design,
- and expander-based code constructions.

## Precise Formal Targets

You should introduce at least one genuinely new definition absent from the catalog, for example a notion like:

- `TropicalMorseRegularFiltration`
- `CriticalSimplexStep`
- `HomologyJumpProfile`
- `CSSDistanceWitness`

These must not be cosmetic wrappers. They should package the exact hypotheses needed for the main theorems.

### Proposed new definitions

1. **Critical simplex attachment**
   A filtration step from `K≤a` to `K≤b` is *critical in degree n* if exactly one new `n`-simplex is attached together with all its faces already present, and the connecting map in the relative homology long exact sequence is concentrated in degree `n`.

2. **Higher tropical Morse regularity**
   A weighted simplicial complex is *higher tropical Morse regular* if every strict filtration jump decomposes into finitely many critical simplex attachments with no simultaneous interaction among incomparable simplices.

3. **Homology jump profile**
   A function assigning to each threshold `t` and degree `n` the signed change
   \[
   \Delta_n(t) = \beta_n(K_{\le t^+}) - \beta_n(K_{\le t^-}).
   \]
   The theorem should show these values lie in a constrained set under regularity assumptions.

These definitions should be implemented in Lean in a way that allows theorem reuse.

## Theorem Package to Prove

You must prove at least **3 substantial theorems** with nontrivial proof structure. Below are the target statements, including suggested Lean 4 type signatures. Adapt names and exact imports to Mathlib realities, but preserve the mathematical content.

---

### Theorem 1: Higher-dimensional exclusive jump dichotomy/trichotomy

This is the central theorem. The graph-level “exclusive dichotomy” must become a higher-dimensional homological jump law.

#### Mathematical statement
Let `K` be a finite simplicial complex with a higher tropical Morse regular filtration. Suppose a filtration step attaches exactly one critical `n`-simplex `σ`. Then exactly one of the following occurs:

1. `β_n` increases by 1 and all other Betti numbers remain unchanged;
2. `β_{n-1}` decreases by 1 and all other Betti numbers remain unchanged;
3. in degenerate non-regular cases, no Betti number changes.

Under the regularity hypothesis, case (3) is excluded. Hence each critical simplex contributes a **unit homological event** in exactly one adjacent degree.

This is the higher-dimensional analogue of the exclusive dichotomy, but now derived from the long exact sequence of the pair.

#### Suggested Lean type signature
```lean
theorem critical_simplex_homology_jump
  {K : FiniteSimplicialComplex α}
  {w : Simplex K → ℤ}
  (hreg : TropicalMorseRegularFiltration K w)
  {a b : ℤ} (hlt : a < b)
  (hstep : CriticalSimplexStep K w a b n) :
  ((betti K w b n = betti K w a n + 1) ∧
    ∀ m, m ≠ n → betti K w b m = betti K w a m)
  ∨
  ((n ≠ 0) ∧ (betti K w b (n-1) + 1 = betti K w a (n-1)) ∧
    ∀ m, m ≠ n-1 → betti K w b m = betti K w a m)
```

If the exact `betti` API is unavailable, formalize a finite-rank homology dimension function first, perhaps over `ℚ`:
```lean
def bettiQ (...) : ℕ := FiniteDimensional.finrank ℚ (...)
```

#### Why this is a breakthrough
This theorem converts tropical filtration data into a **local calculus of homological events** in higher dimensions. That is the missing mechanism needed to reason about quantum LDPC code parameters from geometric filtrations.

#### Proof strategy options

**Strategy A: Long exact sequence of a pair**
1. Express the filtration step as a pair `(K≤b, K≤a)` with relative homology supported in exactly one degree.
2. Use the long exact sequence to show only `H_n` or `H_{n-1}` can change.
3. Use rank-nullity / finite-dimensionality to show the change is by exactly one.

This is the most promising route because it matches the intended mathematics and should scale to later CSS applications.

**Strategy B: Cellular attachment model**
1. Replace the simplicial step by an equivalent single-cell attachment.
2. Compute the chain-level effect on boundary matrices.
3. Deduce the Betti jump from the rank change of the boundary operator.

This may be easier computationally and may connect more directly to `demo.py`.

**Strategy C: Persistent homology viewpoint**
1. Interpret the filtration step as a barcode event.
2. Show a single critical simplex yields exactly one birth or one death in adjacent degrees.
3. Translate barcode events into Betti changes.

This is conceptually powerful and opens later links to TDA, but may require more infrastructure than is immediately available.

---

### Theorem 2: Tropical Morse spectrum determines CSS logical dimension

For a CSS code extracted from a chain complex of a 2-dimensional simplicial complex, the logical qubit count is homological, and the tropical Morse spectrum should recover it.

#### Mathematical statement
Let `K` be a finite 2-dimensional simplicial complex and let the associated CSS code be defined from the boundary maps
\[
C_2(K;\mathbb{F}_2) \xrightarrow{\partial_2} C_1(K;\mathbb{F}_2) \xrightarrow{\partial_1} C_0(K;\mathbb{F}_2).
\]
Then the logical dimension satisfies
\[
k = \dim H_1(K;\mathbb{F}_2).
\]
Moreover, if the tropical Morse filtration is exhaustive and regular, then
\[
k = \sum_t \max(\Delta_1(t),0) - \sum_t \max(-\Delta_1(t),0),
\]
so the logical dimension is recovered from the degree-1 tropical Morse spectrum.

#### Suggested Lean type signature
```lean
theorem css_logical_dim_eq_betti_one
  {K : FiniteSimplicialComplex α}
  (h2 : K.dim ≤ 2)
  (hexh : ExhaustiveFiltration K w)
  (hreg : TropicalMorseRegularFiltration K w) :
  cssLogicalQubits K = bettiF2 K 1
```

and a spectrum version:
```lean
theorem css_logical_dim_eq_spectrum_sum
  {K : FiniteSimplicialComplex α}
  (h2 : K.dim ≤ 2)
  (hexh : ExhaustiveFiltration K w)
  (hreg : TropicalMorseRegularFiltration K w) :
  cssLogicalQubits K =
    ∑ t in criticalValues K w, homologyJumpProfile K w t 1
```

You may need a signed integer-valued jump profile rather than `ℕ`.

#### Why this is a breakthrough
This theorem says the logical information content of a quantum code can be read off from a tropical filtration spectrum. That is not an incremental coding-theory lemma; it is a new geometric diagnostic for code architecture.

#### Proof strategy options

**Strategy A: Homology = CSS kernel/image identity**
1. Expand `cssLogicalQubits` as `dim ker ∂₁ - dim im ∂₂`.
2. identify this with `dim H₁(K; 𝔽₂)`.
3. Use telescoping of jump contributions over the filtration to recover the spectral formula.

This is the cleanest and should formalize well.

**Strategy B: Euler-characteristic control**
1. Use filtration changes in `β₀, β₁, β₂`.
2. Combine with Euler characteristic and attachment counts.
3. Isolate `β₁` and therefore `k`.

This is useful if direct homology APIs are awkward.

---

### Theorem 3: Tropical lower bound on CSS distance via filtration barriers

This theorem should connect the tropical filtration to code distance, not just code dimension.

#### Mathematical statement
Define a **degree-1 tropical barrier** to be a threshold interval in the filtration such that every representative of a nontrivial class in `H₁` must intersect simplices of weight at least `λ`. Then the CSS `Z`-distance is bounded below by the minimal support size of any cycle crossing such a barrier. More concretely, prove a theorem of the shape:

If every nontrivial 1-cycle in `K` requires at least `N` simplices of weight ≥ `λ`, then
\[
d_Z \ge N.
\]

Likewise, by dualizing or using cochains, obtain an analogous lower bound for `d_X`.

#### Suggested Lean type signature
```lean
theorem css_distance_lower_bound_of_tropical_barrier
  {K : FiniteSimplicialComplex α}
  {w : Simplex K → ℤ}
  (hbar : TropicalBarrier K w λ N) :
  N ≤ cssZDistance K
```

Potential dual theorem:
```lean
theorem css_xdistance_lower_bound_of_dual_barrier
  {K : FiniteSimplicialComplex α}
  {w : Simplex K → ℤ}
  (hbar : DualTropicalBarrier K w λ N) :
  N ≤ cssXDistance K
```

#### Why this is a breakthrough
This turns tropical geometry into a **distance certification tool** for quantum LDPC codes. If successful, it offers a new route to provable lower bounds on code distance, potentially useful for hypergraph product and balanced product constructions where direct combinatorial distance analysis is hard.

#### Proof strategy options

**Strategy A: Minimal-support cycle contradiction**
1. Assume a nontrivial logical operator has support size `< N`.
2. Show it cannot cross the barrier.
3. Conclude it lies in a lower filtration region where homology is trivial, contradiction.

This is likely the best first theorem.

**Strategy B: Persistent class lifetime argument**
1. Show any nontrivial class born before `λ` and surviving globally must accumulate support.
2. Translate persistence length into support lower bound.
3. Deduce distance estimate.

This is more visionary and could lead toward persistence-based code diagnostics.

---

### Theorem 4: Cross-domain theorem linking expansion to tropical Morse concentration

You are required to include at least one theorem that genuinely bridges domains. Here the natural bridge is:

**expander theory ↔ tropical Morse concentration ↔ quantum LDPC robustness**

#### Mathematical statement
For a family of bounded-degree simplicial complexes with coboundary expansion, the number of critical filtration values contributing to `β₁` or `β₂` is constrained; equivalently, homological events cannot be arbitrarily diffuse across the tropical spectrum.

At a minimum, prove a finite version:

If `K` satisfies a coboundary expansion inequality in degree 1, then any nontrivial degree-1 tropical homology class must be born at a filtration value whose support intersects an expanding set of simplices. Consequently, the number of low-weight critical degree-1 births is bounded above by a function of the expansion constant.

#### Suggested Lean type signature
```lean
theorem expander_controls_tropical_births
  {K : FiniteSimplicialComplex α}
  (hexp : CoboundaryExpander K ε)
  (hreg : TropicalMorseRegularFiltration K w) :
  ∃ C : ℕ, ∀ T : ℤ,
    countLowWeightBirths K w T 1 ≤ C
```

If this exact theorem is too infrastructure-heavy, prove a specialized finite combinatorial lemma for 2-complexes associated to hypergraph product codes.

#### Why this matters
This is the bridge from pure topology to the modern theory of asymptotically good quantum LDPC codes. It suggests that expansion forces tropical homological events into structured patterns, potentially giving new diagnostics for code families built from expanders.

## Concrete Lean Architecture

Build directly on catalog material, especially:

- `Bridges/Catalog/Pythagorean/TropicalMorse/HigherSimplicial.lean`
  - Use this as the seed for higher-dimensional filtration definitions and any existing simplicial infrastructure.
- `Pythagorean/TropicalMorse/QuantumGraphCodes.lean`
  - In particular, extract and generalize `filtration_exclusive_dichotomy` from graph codes to higher-dimensional complexes.

Do not merely import and restate. Generalize the mechanism.

### Suggested file path
A strong target would be something like:
- `Bridges/QuantumLDPC/TropicalMorse/HigherLDPC.lean`

or, if aligning with catalog structure:
- `Bridges/Catalog/Pythagorean/TropicalMorse/HigherQuantumLDPC.lean`

## Proof Tactics Requirements

Your theorems must use real mathematics and nontrivial proof structure. Across the file, ensure proofs substantially use:
- induction,
- `rcases`,
- `by_contra`,
- multi-step `calc`,
- and where appropriate `field_simp` or rank arithmetic over fields.

In particular:
- use induction over ordered critical values in the filtration;
- use `rcases` on relative homology cases / critical simplex structure;
- use `by_contra` in the distance lower bound theorem;
- use `calc` chains for dimension identities in CSS homology formulas.

Avoid toy theorems that collapse to definitional equality.

## Conjecture With Computational Test

State and formalize a falsifiable conjecture, for example:

> **Conjecture (Higher tropical Morse prediction for quantum LDPC codes).**  
> For every finite 2-dimensional simplicial complex `K` giving a CSS code and every higher tropical Morse regular weight function `w`, the degree-1 and degree-2 tropical Morse spectra determine the logical dimension exactly and determine lower bounds on `X`- and `Z`-distance within a universal multiplicative constant for hypergraph product and balanced product families.

A Lean-friendly declaration might be:
```lean
def HigherTropicalLDPCConjecture : Prop :=
  ∀ (K : FiniteSimplicialComplex α) (w : Simplex K → ℤ),
    TropicalMorseRegularFiltration K w →
    PredictsLogicalDimAndDistanceUpToUniversalConstant K w
```

### Required computational test
Implement and run a test in `demo.py` for:
- the 2D toric code as a simplicial torus,
- hypergraph product codes `HP(H₁, H₂)` for random `10 × 20` LDPC matrices,
- balanced product codes for small group algebras.

For each example:
1. construct the filtration from simplex weights,
2. compute estimated `β₁`, `β₂`, and jump profiles,
3. compare predicted `k` and distance lower bounds with known or directly computed code parameters,
4. report whether at least 90% of sampled cases satisfy the prediction.

This test must be capable of falsifying the conjecture.

## Application Keywords

Include these explicitly in the paper and code comments:

**Application keywords:** tropical Morse theory, simplicial homology, CSS codes, quantum LDPC, hypergraph product codes, balanced product codes, toric code, persistent homology, expander complexes, fault-tolerant quantum computing, homological distance bounds, tropical filtration spectrum.

## Cross-Domain Connections to Emphasize

You must explicitly develop at least one theorem or section around each of the following bridges:

1. **Tropical geometry ↔ homological algebra**  
   Filtration spectra encode chain-complex invariants.

2. **Homological algebra ↔ quantum information**  
   Betti numbers and boundary maps determine CSS logical qubits.

3. **Expander theory ↔ quantum LDPC**  
   Expansion constrains low-weight logical operators and therefore interacts with tropical barrier bounds.

4. **Persistent homology ↔ fault tolerance**  
   Long-lived homology classes correspond to robust encoded information.

The most revolutionary narrative is this: **fault-tolerant quantum information may be organized by tropical criticality.**

## Deliverables — Mandatory

You must produce **all** of the following:

### 1. Lean file with substantial new theorems
- At least 3 deep theorems as above.
- At least 1 new definition not present in the catalog.
- Minimize `sorry`; if any remain, isolate them and explain the exact obstruction.

### 2. `FUTURE_DIRECTIONS.md`
Write 3–5 original research directions. Each direction must include:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**
At least one direction must bridge to a different domain, such as:
- statistical mechanics,
- topological phases of matter,
- or tropical optimization for decoder design.

### 3. `RESEARCH_PAPER.md`
A standalone scientific document explaining:
- the theorem statements,
- why higher-dimensional tropical Morse theory is the right language,
- how the CSS code connection works,
- what was computationally tested,
- what new research program this opens.

Someone reading only this document, with no code access, must understand the discovery.

### 4. `ARTICLE.md`
Write this in **Scientific American style**:
- vivid,
- accessible,
- concept-first,
- broad audience.

Do **not** focus on formal verification machinery. Focus on the ideas: tropical landscapes, homological events, and robust quantum memories.

### 5. Verified algorithm / computational method
Provide a verified or at least formally specified algorithm for:
- constructing the filtration,
- computing the homology jump profile,
- extracting predicted CSS parameters.

This must be more than a theorem statement.

### 6. `demo.py`
An interactive demonstration that:
- builds example filtrations,
- computes jump profiles,
- estimates `k`, `d_X`, `d_Z`,
- visualizes filtration events if possible,
- and prints agreement statistics for the conjectural test suite.

## Final Call

Do not settle for a local lemma. The target is a new synthesis: **tropical criticality as a structural theory of quantum LDPC codes**. If you can prove even the first three theorems in a reusable Lean architecture, you will have created a framework others can build on for toric codes, hypergraph product codes, balanced product codes, and perhaps eventually asymptotically good qLDPC families. This is not an extension. It is the beginning of a field.

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
