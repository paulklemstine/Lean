Soli Deo Gloria

## Assignment: Direction 2: Spectral Decoding via Tropical Morse Barcodes

**Mode:** prove

You are not being asked for an incremental coding exercise. You are being asked to found a new decoding paradigm: a mathematically principled bridge from tropical Morse spectra and persistence-style barcodes to quantum error correction for graph-CSS codes. The central scientific claim is that *global spectral-topological information* can guide local correction decisions as effectively as, or better than, purely combinatorial decoders.

The breakthrough is not “yet another heuristic decoder.” The breakthrough is to prove that barcode geometry extracts a *decoding potential* from the syndrome graph: persistent cycle events identify windows where homologically nontrivial errors are likely to nucleate, and this can be converted into a certified edge-weighting scheme for minimum-weight correction. If successful, this opens a new field: **tropical-topological decoding theory**.

Build directly on the catalog:
- `Pythagorean/TropicalMorse/Defs.lean`
  - `TMSpectrum`
  - `tropicalMorseComplexity`
- `Pythagorean/TropicalMorse/Theorems.lean`
  - `spectral_gap_distinguishes`

Your goal is to define a mathematically precise barcode-derived decoder weight and prove nontrivial structural theorems about it. Minimize sorry. Do not hide behind computation-only statements.

---

## Core Vision

For a graph-CSS code built from a finite graph `G`, let a tropical Morse spectrum assign critical cycle-event data to weighted subgraphs or edge filtrations. The full barcode — not merely first birth time — should determine a *vulnerability profile* on edges or paths. This profile should be monotone with respect to persistent cycle activation and should distinguish corrections that approach logical operators from those that remain homologically harmless.

The revolutionary claim is:

> **Persistent tropical cycle data can be converted into a syndrome-aware weight function whose minimizers avoid logical error corridors.**

This is a conceptual inversion of standard decoding: instead of only asking “what is the shortest correction consistent with the syndrome?”, ask “what is the shortest correction after penalizing routes that lie in spectrally persistent logical channels?”

That is the field-opening idea.

---

## New Definitions You Should Introduce

You must define at least one genuinely new structure, and preferably several. Suggested definitions:

1. **Tropical Morse Barcode**
   A finite list of intervals `(birth, death)` extracted from `TMSpectrum`, representing persistence of cycle events.

2. **Edge Vulnerability Profile**
   A function assigning each edge a nonnegative penalty derived from the barcode contribution of cycle events incident to, supported on, or activated through that edge.

3. **Barcode-Weighted Decoder Metric**
   A path or chain weight equal to Hamming weight plus a tropical vulnerability penalty.

4. **Logical Corridor**
   A subgraph/path class whose barcode persistence exceeds a threshold and which intersects a nontrivial homology class.

5. **Decoding Admissibility**
   A property saying that the barcode-weighted correction does not increase logical risk relative to ordinary weight minimization.

These should not be cosmetic wrappers. They should support theorem statements with actual mathematical force.

---

## Precise Theorem Targets

You must prove at least 3 substantial theorems. Below are candidate flagship statements. You may adjust hypotheses to match what is formalizable in Lean and what the catalog supports, but preserve the conceptual content.

### Theorem 1: Spectral persistence induces a monotone vulnerability functional

**Mathematical statement.**  
Given a finite graph with a tropical Morse barcode, define the cumulative persistence above threshold `τ` by
\[
V_\tau(e) = \sum_{I \in \mathcal B(e),\ \tau \le \mathrm{birth}(I)} (\mathrm{death}(I)-\mathrm{birth}(I)),
\]
or an appropriate finite tropical variant. Then if one barcode dominates another intervalwise, the induced vulnerability is pointwise larger.

This is the first theorem that turns barcode data into an order-theoretic decoding observable.

### Suggested Lean 4 type signature
```lean
theorem vulnerability_monotone
  {α : Type*} [LinearOrderedRing α]
  {E : Type*} [Fintype E] [DecidableEq E]
  (B₁ B₂ : E → Finset (α × α))
  (V : (E → Finset (α × α)) → E → α)
  (hmono :
    ∀ e, (∀ I ∈ B₁ e, I ∈ B₂ e) → V B₁ e ≤ V B₂ e) :
  ∀ e, (∀ I ∈ B₁ e, I ∈ B₂ e) → V B₁ e ≤ V B₂ e
```

A more refined version, closer to the intended mathematics:
```lean
def intervalPersistence {α : Type*} [OrderedRing α] : α × α → α
| (b,d) => d - b

def edgeVulnerability
  {α E : Type*} [LinearOrderedRing α] [Fintype E] [DecidableEq E]
  (B : E → Finset (α × α)) (e : E) : α :=
  ∑ I in B e, intervalPersistence I

theorem edgeVulnerability_mono
  {α E : Type*} [LinearOrderedRing α] [Fintype E] [DecidableEq E]
  (B₁ B₂ : E → Finset (α × α))
  (hsub : ∀ e, B₁ e ⊆ B₂ e) :
  ∀ e, edgeVulnerability B₁ e ≤ edgeVulnerability B₂ e
```

**Why this matters.**  
It proves that richer persistent cycle structure cannot reduce inferred risk. This is the monotonicity backbone of the decoder.

---

### Theorem 2: Spectral gaps force separation between benign and logical corridors

Use `spectral_gap_distinguishes` as a certified building block. The point is not merely to restate it, but to transport its distinguishing power into the decoding setting.

**Mathematical statement.**  
If two candidate correction chains have distinct tropical Morse spectral gaps, and one intersects a logical corridor while the other remains in a contractible region, then the barcode-weighted metric strictly separates them whenever the vulnerability penalty exceeds the base weight discrepancy.

Formally, if
\[
w(C_1) \le w(C_2), \quad \Delta_{\mathrm{spec}}(C_1) < \Delta_{\mathrm{spec}}(C_2),
\]
and the vulnerability contribution from the second chain dominates the ordinary weight advantage of the first, then
\[
W_{\mathrm{barcode}}(C_1) < W_{\mathrm{barcode}}(C_2).
\]

### Suggested Lean 4 type signature
```lean
def barcodeWeight
  {α C : Type*} [LinearOrderedRing α]
  (base vuln : C → α) (c : C) : α :=
  base c + vuln c

theorem barcodeWeight_strict_sep
  {α C : Type*} [LinearOrderedRing α]
  (base vuln gap : C → α)
  (c₁ c₂ : C)
  (hbase : base c₁ ≤ base c₂)
  (hgap : gap c₁ < gap c₂)
  (hvuln : vuln c₁ + base c₁ < vuln c₂ + base c₂) :
  barcodeWeight base vuln c₁ < barcodeWeight base vuln c₂
```

A more ambitious transport theorem, if you can align the imported theorem:
```lean
theorem spectral_gap_induces_decoder_separation
  {α C : Type*} [LinearOrderedRing α]
  (base vuln gap : C → α)
  (c₁ c₂ : C)
  (hdist : gap c₁ < gap c₂)
  (hpen : base c₁ - base c₂ < vuln c₂ - vuln c₁) :
  barcodeWeight base vuln c₁ < barcodeWeight base vuln c₂
```

**Why this matters.**  
This is the conceptual hinge of the project: spectral classification becomes dynamic correction. It says barcode penalties are not decorative statistics; they alter optimization in a mathematically controlled way.

---

### Theorem 3: Decoder stability under barcode refinement

**Mathematical statement.**  
Suppose a barcode is refined by splitting intervals without changing total persistence on each edge. Then the barcode-weighted decoder metric is invariant. If total persistence increases only on edges inside a logical corridor, then every minimizer under the refined metric is at least as far from that corridor as before.

This theorem is essential because it shows the decoder depends on robust aggregate information, not arbitrary presentation of intervals.

### Suggested Lean 4 type signature
```lean
theorem barcode_refinement_invariant
  {α E : Type*} [LinearOrderedRing α] [Fintype E] [DecidableEq E]
  (B₁ B₂ : E → Finset (α × α))
  (hpres :
    ∀ e, edgeVulnerability B₁ e = edgeVulnerability B₂ e) :
  ∀ e, edgeVulnerability B₁ e = edgeVulnerability B₂ e
```

And at path level:
```lean
def pathWeight
  {α E P : Type*} [LinearOrderedRing α]
  (edgesOf : P → Finset E) (base : P → α)
  (B : E → Finset (α × α)) (p : P) : α :=
  base p + ∑ e in edgesOf p, edgeVulnerability B e

theorem pathWeight_refinement_invariant
  {α E P : Type*} [LinearOrderedRing α] [Fintype E] [DecidableEq E]
  (edgesOf : P → Finset E) (base : P → α)
  (B₁ B₂ : E → Finset (α × α))
  (hpres : ∀ e, edgeVulnerability B₁ e = edgeVulnerability B₂ e) :
  ∀ p, pathWeight edgesOf base B₁ p = pathWeight edgesOf base B₂ p
```

**Why this matters.**  
It gives a universality principle: the decoder sees persistent geometry, not bookkeeping artifacts. That is exactly the kind of theorem a new theory needs.

---

### Theorem 4: Cross-domain theorem — persistent penalties define a discrete free-energy functional

You are required to include a cross-domain connection. Here is the strongest one available:

Interpret the barcode-weighted path cost as a discrete free energy
\[
F(C)=E(C)+\lambda \Phi(C),
\]
where `E` is ordinary chain weight and `Φ` is barcode-derived vulnerability. Then minimizers satisfy a variational principle analogous to zero-temperature statistical mechanics.

### Suggested Lean 4 type signature
```lean
def freeEnergy
  {α C : Type*} [LinearOrderedRing α]
  (energy entropyLike : C → α) (λ : α) (c : C) : α :=
  energy c + λ * entropyLike c

theorem zero_temperature_selection
  {α C : Type*} [LinearOrderedLinearOrderedField α]
  (energy entropyLike : C → α) (λ : α) (hλ : 0 ≤ λ)
  (c₁ c₂ : C)
  (hE : energy c₁ < energy c₂)
  (hS : entropyLike c₁ ≤ entropyLike c₂) :
  freeEnergy energy entropyLike λ c₁ < freeEnergy energy entropyLike λ c₂
```

This is a rigorous bridge:
- tropical persistence ↔ energy landscape
- decoding ↔ variational optimization
- graph-CSS correction ↔ statistical mechanics

**Why this matters.**  
This is how you make the work feel inevitable to multiple communities. The decoder is not just a coding trick; it is a free-energy minimizer over homological error channels.

---

## Stronger Global Conjecture

State and test a falsifiable conjecture that goes beyond theorems you can immediately prove.

### Conjecture: Tropical Barcode Threshold Advantage
For families of planar graph-CSS codes `G_n` with increasing distance, there exists a barcode-derived penalty parameter `λ > 0` and a persistence threshold rule `τ = τ(n,p)` such that for depolarizing noise rates in a nontrivial interval `p ∈ (0,p₀)`, the barcode-weighted decoder has asymptotic logical error rate no worse than MWPM and strictly better than union-find on infinitely many code sizes.

A more formal asymptotic version:
\[
\exists p_0>0,\ \exists \lambda>0,\ \forall p\in(0,p_0),\ \exists^\infty n,\ 
L_{\mathrm{Trop}}(n,p,\lambda)\le L_{\mathrm{MWPM}}(n,p)
\quad\text{and}\quad
L_{\mathrm{Trop}}(n,p,\lambda)<L_{\mathrm{UF}}(n,p).
\]

### Computational falsification protocol
Implement a tropical decoder using TMS barcode penalties and test on surface codes:
- sizes: `3×3`, `5×5`, `7×7`
- depolarizing noise: `p = 0.01, 0.05, 0.10`
- baselines: MWPM, union-find

The conjecture is falsified if, across all tested sizes and rates, the tropical decoder is uniformly worse than both baselines under any reasonable calibration of `λ` and thresholding.

This is a real scientific conjecture because it can fail.

---

## Proof Architecture: 3 Possible Strategies

You must not rely on one proof path. Explore at least 2–3 approaches and indicate which is most promising.

### Strategy A: Order-theoretic persistence aggregation
1. Define barcode intervals and edge vulnerability as finite sums over persistence lengths.
2. Prove monotonicity under interval inclusion/refinement using `Finset.sum_le_sum`, subset arguments, and multi-step `calc`.
3. Lift edgewise inequalities to pathwise or chainwise inequalities by summing over support.

**Why promising:**  
This is the most Lean-friendly route. It produces robust structural theorems quickly and gives a clean algebraic foundation for the decoder.

### Strategy B: Spectral-gap transport from catalog theorem
1. Import and specialize `spectral_gap_distinguishes`.
2. Define a map from candidate corrections to a spectral observable.
3. Prove that larger spectral gaps imply larger barcode penalties on logical corridors.
4. Deduce strict separation of decoder scores.

**Why promising:**  
This is the most scientifically important route because it directly extends the catalog’s spectral classification theorem into decoding. It gives lineage and conceptual force.

### Strategy C: Variational/free-energy interpretation
1. Package barcode penalties as a nonnegative potential term.
2. Prove comparison lemmas showing minimizers prefer lower-energy and lower-vulnerability paths.
3. Connect to statistical mechanics language: zero-temperature selection, metastable channels, barrier crossing.

**Why promising:**  
This is the best cross-domain route. It can produce the “I never thought of that connection” effect and makes the work legible to mathematical physicists.

**Recommended order:** A → B → C.  
A establishes the formal infrastructure, B delivers the flagship theorem, C broadens the conceptual scope and applications.

---

## Required Deep Proof Tactics

Your file must contain at least 3 theorems whose proofs genuinely use nontrivial reasoning such as:
- induction over finite supports or barcode lists
- `rcases` on interval and path structure
- `by_contra` for strict separation / minimality arguments
- `field_simp` if rational penalties or normalized weights are introduced
- multi-step `calc` chains with monotonicity and algebraic inequalities

Avoid proofs that collapse to definitional equality or enumeration.

Good theorem styles:
- induction over `Finset`
- contradiction from assumed minimizer violating vulnerability ordering
- decomposition of refined barcodes into split intervals
- chainwise inequality from edgewise inequalities

---

## Concrete Lean Formalization Targets

You should aim to create a new file in a plausible location such as:

`Pythagorean/TropicalMorse/SpectralDecoding.lean`

with content along these lines:

- `structure BarcodeInterval (α : Type*) where`
  - `birth : α`
  - `death : α`
  - `valid : birth ≤ death`

- `def persistence ...`
- `def edgeVulnerability ...`
- `def barcodeWeight ...`
- `def logicalCorridor ...`
- `def decoderAdmissible ...`

And then prove theorems analogous to:
- `edgeVulnerability_mono`
- `pathWeight_refinement_invariant`
- `spectral_gap_induces_decoder_separation`
- `zero_temperature_selection`

If useful, parameterize over abstract correction objects rather than full graph machinery at first. Then instantiate for graph-supported paths/chains.

---

## Cross-Domain Connections You Must Explicitly Develop

At least one theorem and one discussion section must connect this work to another domain.

### 1. Persistent homology ↔ quantum error correction
The barcode is the topological memory of cycle births/deaths; the syndrome graph is the combinatorial footprint of quantum noise. Your decoder turns one into guidance for the other.

### 2. Statistical mechanics ↔ decoding
The barcode penalty acts like an energy barrier or free-energy correction. Logical operators become metastable channels; decoding becomes barrier-aware minimization.

### 3. Algorithmic graph theory ↔ tropical geometry
Edge reweighting induced by tropical persistence yields a new shortest-path / min-correction objective. This may lead to near-linear heuristic algorithms if vulnerability can be precomputed efficiently.

### 4. Optional bold bridge: Morse theory ↔ fault-tolerant phase transitions
If persistence spectra sharpen near threshold phenomena, this suggests a geometric precursor to decoder threshold transitions.

---

## Verified Algorithmic Deliverable

You must produce not just theorems but a verified computational method:

### Tropical Barcode Decoder
Input:
- graph-CSS code graph
- syndrome
- tropical Morse barcode data
- penalty parameter `λ`

Output:
- candidate correction chain minimizing
  \[
  \text{base weight} + \lambda \cdot \text{barcode vulnerability}.
  \]

At minimum, formalize and verify:
- nonnegativity of the decoder weight
- monotonicity under increased vulnerability
- invariance under barcode refinement preserving total persistence
- strict preference theorem under spectral-gap separation assumptions

If full optimality is too large for one cycle, prove correctness of the scoring function and stability properties, then implement the search algorithm in `demo.py`.

---

## Experimental Program for `demo.py`

Your `demo.py` must:
1. Generate or load surface-code graphs for `3×3`, `5×5`, `7×7`.
2. Simulate depolarizing noise at `p = 0.01, 0.05, 0.10`.
3. Compute a surrogate tropical Morse barcode or use catalog-derived spectrum data.
4. Construct barcode edge penalties.
5. Decode using:
   - tropical barcode decoder
   - MWPM baseline
   - union-find baseline
6. Plot or print logical error rate comparison.

Even if the theorem is abstract, the demo must make the scientific claim testable.

---

## Why This Would Be a Breakthrough

If you succeed, you will have shown that:
- topological persistence data can drive quantum decoding;
- tropical Morse invariants are not merely descriptive but algorithmically actionable;
- spectral classification theorems can be upgraded into correction procedures;
- decoding can be reframed as geometry-aware variational optimization.

This opens:
- new decoder architectures for surface and hypergraph-product codes,
- a theory of persistence-guided fault tolerance,
- bridges to topological data analysis and statistical mechanics,
- possible low-complexity alternatives to MWPM with geometric intelligence.

This is exactly the kind of result that creates a new research lane rather than extending an old one.

---

## Mandatory Deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**
At least one direction must bridge to a different domain.

Possible future directions include:
- barcode-guided decoding for hypergraph-product codes,
- persistence threshold phenomena and code capacity,
- tropical free-energy decoding and renormalization,
- analogies with energy landscapes in spin glasses.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper that explains:
- the new definitions,
- the main theorems,
- why spectral decoding via tropical Morse barcodes matters,
- the algorithmic decoder,
- experiments and conjectures,
- what should be investigated next.

A reader with no access to the code must still understand the discovery.

### 3. `ARTICLE.md`
Write this in Scientific American style:
- vivid, accessible, idea-centered,
- explain barcodes, persistent cycles, and quantum decoding intuitively,
- emphasize the mathematical discovery and its significance,
- do **not** focus on formal verification machinery.

### 4. Verified algorithm or computational method
You must produce a verified scoring rule or decoder component, not just theorem statements.

### 5. `demo.py`
Interactive or script-based demonstration comparing the tropical decoder with MWPM and union-find.

---

## Application Keywords

Use and develop these keywords in the paper and code comments:

- tropical Morse spectrum
- persistence barcode
- graph-CSS code
- surface code decoder
- logical corridor
- vulnerability profile
- spectral-gap separation
- barcode-weighted decoding
- persistent homology
- variational decoding
- free-energy functional
- metastable error channel
- tropical topological decoding
- syndrome graph optimization
- quantum fault tolerance

---

## Final Charge

Do not settle for “we defined a weight and proved it is nonnegative.” That is not the assignment. The assignment is to prove that barcode-derived spectral information creates a *mathematically justified decoding geometry*. Build the theory so that a future researcher can ask not whether tropical barcodes are relevant to decoding, but how far the new paradigm extends.

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
