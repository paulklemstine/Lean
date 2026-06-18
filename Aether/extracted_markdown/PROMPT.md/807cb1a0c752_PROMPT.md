Soli Deo Gloria

## Assignment: Formal Spectral Moonshine Beyond Orthogonality — Build a Harmonic-Representation-Theoretic Engine

The formal spectral moonshine framework established here — class function inner products, moonshine packets, Fourier inversion, and multiplicity decoding — is not merely a bookkeeping device for finite-group characters. It is the seed of a new spectral interface between representation theory, arithmetic signal decomposition, and operator-theoretic ideas that resemble quantum spectral measurement. Your task is to push this framework into genuinely new territory: prove nontrivial theorems that turn “moonshine packets” from static data into a mathematically robust spectral calculus.

Build on the catalog files around:

- `Speculative/Moonshine/Defs.lean`
- `Speculative/Moonshine/Theorems.lean`

and any existing catalog lemmas on class functions, inner products, finite sums, orthonormality hypotheses, and multiplicity extraction.

You must minimize `sorry`, and any remaining `sorry` must isolate only infrastructure gaps rather than the conceptual core.

---

## Mode: `prove`

## Central Vision

The breakthrough target is to show that the current moonshine formalism already supports a **spectral reconstruction theory**: packets behave like finite spectral measures, decoding behaves like a Fourier coefficient extractor, and orthonormal character data induces a Parseval/Plancherel-style energy law and uniqueness principle. This is important because it opens a route from finite-group moonshine to:

- spectral statistics,
- automorphic-style decomposition heuristics,
- finite quantum measurement analogies,
- and eventually arithmetic packet dynamics.

The right theorem is not “another decoding identity.” The right theorem says that once a packet satisfies a spectral compatibility condition, the entire packet is uniquely determined by its multiplicity profile and admits an exact energy decomposition. That is the beginning of a field.

---

## Required New Definitions

You must introduce at least one genuinely new concept not already present in the catalog. Recommended definitions:

### 1. Spectrally faithful packet
A moonshine packet whose decoded multiplicities vanish only when the underlying class function is zero.

Suggested mathematical content:
- this should formalize injectivity of the decoding map under completeness/orthonormality assumptions;
- it packages uniqueness of spectral coordinates into a reusable structure.

Possible Lean-style skeleton:
```lean
structure SpectrallyFaithfulPacket
    (G : Type*) [Finite G] [Fintype G] [DecidableEq G] :=
  (χs : Finset (ClassFn G ℂ))
  (orthonormal : IsOrthonormal χs)
  (complete :
    ∀ f : ClassFn G ℂ,
      f ∈ span ℂ (↑χs : Set (ClassFn G ℂ)) )
  (decode_faithful :
    ∀ f : ClassFn G ℂ,
      (∀ χ ∈ χs, inner f χ = 0) → f = 0)
```

### 2. Spectral energy of a class function
Define the packet energy as the sum of squared norms of spectral coefficients.
```lean
def spectralEnergy
    {G : Type*} [Finite G] [Fintype G] [DecidableEq G]
    (χs : Finset (ClassFn G ℂ)) (f : ClassFn G ℂ) : ℝ :=
  ∑ χ in χs, Complex.normSq (inner f χ)
```

### 3. Spectral projector associated to a packet
A partial reconstruction operator:
```lean
def packetProjector
    {G : Type*} [Finite G] [Fintype G] [DecidableEq G]
    (χs : Finset (ClassFn G ℂ)) (f : ClassFn G ℂ) : ClassFn G ℂ :=
  ∑ χ in χs, (inner f χ) • χ
```

This definition is the conceptual hinge: it turns packet decoding into an operator, enabling idempotence, self-adjointness heuristics, exact reconstruction, and energy conservation.

---

## Precise Theorem Targets

You must prove at least 3 deep theorems. The following three are the recommended core.

---

### Theorem 1: Exact spectral reconstruction from complete orthonormal packets

**Mathematical statement**

Let `χs` be a finite orthonormal family of class functions on a finite group `G`. Assume it is complete in the sense that every class function lies in the span of `χs`. Then for every class function `f`, the packet projector reconstructs `f` exactly:
\[
\forall f,\quad \operatorname{packetProjector}(\chi_s,f)=f.
\]

This upgrades Fourier inversion from a coefficient formula to an operator identity.

**Lean 4 type signature (target form)**
```lean
theorem packetProjector_eq_self_of_complete_orthonormal
    {G : Type*} [Finite G] [Fintype G] [DecidableEq G]
    (χs : Finset (ClassFn G ℂ))
    (horth : IsOrthonormal χs)
    (hcomplete : ∀ f : ClassFn G ℂ,
      f ∈ Submodule.span ℂ ((↑χs : Set (ClassFn G ℂ))))
    (f : ClassFn G ℂ) :
    packetProjector χs f = f
```

**Why this is a breakthrough**

This theorem converts moonshine packets into bona fide spectral bases. It says the framework is not just decoding multiplicities but implementing exact finite harmonic analysis. Once formalized, every packet becomes a computationally usable spectral transform.

**Proof strategies**

- **Strategy A: expansion via span membership + coefficient uniqueness**
  1. Use `hcomplete f` to obtain an expansion of `f` in the span of `χs`.
  2. Compare coefficients by taking inner products against each `χ ∈ χs`.
  3. Use orthonormality to force the coefficient of `χ` to be exactly `inner f χ`, then conclude by extensionality.
  This is likely the most promising route if the current catalog already contains Fourier inversion lemmas.

- **Strategy B: prove `packetProjector` acts as identity on basis vectors**
  1. Show `packetProjector χs χ = χ` for each `χ ∈ χs`.
  2. Prove linearity of `packetProjector`.
  3. Extend from basis elements to the entire span, then use completeness.
  This route is structurally elegant and gives reusable lemmas about projector linearity.

- **Strategy C: by_contra using orthogonality of the error**
  1. Let `e = f - packetProjector χs f`.
  2. Show `inner e χ = 0` for every `χ ∈ χs`.
  3. Use completeness to deduce `e = 0`.
  This route is especially good if you define `SpectrallyFaithfulPacket`.

---

### Theorem 2: Parseval/Plancherel identity for moonshine packets

**Mathematical statement**

Under the same completeness and orthonormality hypotheses,
\[
\|f\|^2 = \sum_{\chi \in \chi_s} |\langle f,\chi\rangle|^2.
\]
Equivalently, packet spectral energy equals the class-function norm squared.

**Lean 4 type signature (target form)**
```lean
theorem spectralEnergy_eq_normSq_of_complete_orthonormal
    {G : Type*} [Finite G] [Fintype G] [DecidableEq G]
    (χs : Finset (ClassFn G ℂ))
    (horth : IsOrthonormal χs)
    (hcomplete : ∀ f : ClassFn G ℂ,
      f ∈ Submodule.span ℂ ((↑χs : Set (ClassFn G ℂ))))
    (f : ClassFn G ℂ) :
    spectralEnergy χs f = Complex.normSq (inner f f)
```

If the inner product codomain or norm formalization differs in the catalog, adapt the RHS accordingly, e.g. to `‖f‖^2` or `re (inner f f)`.

**Why this is a breakthrough**

This is the energy law of spectral moonshine. It promotes the framework from exact reconstruction to quantitative analysis. Once this exists, one can discuss concentration of spectral mass, entropy-like invariants, sparsity of packets, and spectral statistics across families.

**Proof strategies**

- **Strategy A: derive from reconstruction**
  1. First prove Theorem 1.
  2. Substitute the expansion \(f = \sum_\chi \langle f,\chi\rangle \chi\).
  3. Compute `inner f f` and collapse cross-terms using orthonormality.
  This is conceptually the cleanest route.

- **Strategy B: compute the norm of the projector**
  1. Prove `packetProjector χs f = f`.
  2. Expand `inner (packetProjector χs f) (packetProjector χs f)`.
  3. Use `Finset` algebra and orthonormality to reduce the double sum to a single sum.
  This route requires stronger sum manipulation but yields good reusable lemmas.

- **Strategy C: induction over `Finset`**
  1. Prove the formula for the empty family and insert one orthonormal vector at a time.
  2. Maintain orthogonality of the partial sum and the residual.
  3. Conclude for the full packet.
  This is technically deeper and may satisfy the “deep proof tactics” requirement with explicit induction.

---

### Theorem 3: Uniqueness of multiplicity decoding / spectral faithfulness

**Mathematical statement**

If two class functions have identical decoded multiplicities against every packet element in a complete orthonormal packet, then the class functions are equal:
\[
\bigl(\forall \chi\in\chi_s,\ \langle f,\chi\rangle=\langle g,\chi\rangle\bigr)\implies f=g.
\]

**Lean 4 type signature (target form)**
```lean
theorem eq_of_inner_eq_on_complete_orthonormal
    {G : Type*} [Finite G] [Fintype G] [DecidableEq G]
    (χs : Finset (ClassFn G ℂ))
    (horth : IsOrthonormal χs)
    (hcomplete : ∀ f : ClassFn G ℂ,
      f ∈ Submodule.span ℂ ((↑χs : Set (ClassFn G ℂ))))
    {f g : ClassFn G ℂ}
    (hcoeff : ∀ χ, χ ∈ χs → inner f χ = inner g χ) :
    f = g
```

**Why this is a breakthrough**

This theorem says moonshine packet data is complete observable data. In physics language, the packet is an informationally complete measurement. In harmonic analysis language, it is a coordinate chart. In arithmetic applications, it means multiplicity tables determine the object uniquely.

**Proof strategies**

- **Strategy A: reduce to zero by subtraction**
  1. Set `h := f - g`.
  2. Show `inner h χ = 0` on all packet elements using `hcoeff`.
  3. Apply completeness/faithfulness to conclude `h = 0`.
  This is the most direct route.

- **Strategy B: use projector equality**
  1. By coefficient equality, prove `packetProjector χs f = packetProjector χs g`.
  2. Use Theorem 1 on both sides.
  3. Conclude `f = g`.
  This route makes the operator formalism central.

- **Strategy C: by_contra with positive norm**
  1. Assume `f ≠ g`, so `f-g ≠ 0`.
  2. Use Parseval to show spectral energy of `f-g` is positive.
  3. But the coefficient hypothesis forces that energy to be zero, contradiction.
  This is especially compelling because it fuses Theorems 2 and 3 into a spectral rigidity package.

---

## Strongly Recommended Fourth Theorem: Idempotence of the packet projector

This theorem gives the operator-theoretic backbone.

**Statement**
\[
\operatorname{packetProjector}(\chi_s,\operatorname{packetProjector}(\chi_s,f))
=
\operatorname{packetProjector}(\chi_s,f).
\]

**Lean target**
```lean
theorem packetProjector_idempotent
    {G : Type*} [Finite G] [Fintype G] [DecidableEq G]
    (χs : Finset (ClassFn G ℂ))
    (horth : IsOrthonormal χs)
    (f : ClassFn G ℂ) :
    packetProjector χs (packetProjector χs f) = packetProjector χs f
```

This theorem remains meaningful even without completeness: it identifies the projector as projection onto the packet span. That is a major conceptual step.

---

## Cross-Domain Connection Theorem (MANDATORY)

You must include at least one theorem connecting spectral moonshine to another domain. The most promising bridge is to finite-dimensional quantum mechanics / operator theory.

### Recommended bridge: informational completeness analogy

Interpret `inner f χ` as a measurement amplitude and `spectralEnergy χs f` as total measured intensity. Then prove a mathematically clean analog:

If `χs` is complete orthonormal, then zero measured intensity implies zero state:
\[
\operatorname{spectralEnergy}(\chi_s,f)=0 \implies f=0.
\]

**Lean target**
```lean
theorem spectralEnergy_zero_iff
    {G : Type*} [Finite G] [Fintype G] [DecidableEq G]
    (χs : Finset (ClassFn G ℂ))
    (horth : IsOrthonormal χs)
    (hcomplete : ∀ f : ClassFn G ℂ,
      f ∈ Submodule.span ℂ ((↑χs : Set (ClassFn G ℂ))))
    (f : ClassFn G ℂ) :
    spectralEnergy χs f = 0 ↔ f = 0
```

**Cross-domain significance**

This is a finite harmonic-analysis analog of “informationally complete measurements” in quantum information. It creates a rigorous bridge from moonshine packets to:
- quantum tomography,
- signal reconstruction,
- compressed sensing heuristics,
- spectral inverse problems.

If feasible, explicitly mention in comments or paper prose that this is a finite-group class-function incarnation of a completeness-of-observables principle.

---

## Conjecture with Testable Prediction (MANDATORY)

State at least one falsifiable conjecture with a computational test.

### Recommended conjecture: spectral sparsity rigidity

For a finite group `G` with a complete orthonormal irreducible character packet `χs`, any integer-valued class function `f` with nonnegative decoded multiplicities and
\[
\sum_{\chi \in \chi_s} |\langle f,\chi\rangle|^2 = 1
\]
must equal a single packet element.

Informally: unit spectral energy plus nonnegative integral multiplicities forces atomicity.

Possible Lean-friendly conjecture statement in comments or as `axiom`/`conjecture` section:
```lean
/--
Conjecture (spectral sparsity rigidity):
If a class function has nonnegative integral spectral multiplicities and total
spectral energy 1 with respect to a complete orthonormal packet, then it is
equal to one packet basis element.
-/
```

**Computational test**
- For small groups (`C_n`, `S_3`, `D_8`, `Q_8` if available), enumerate integer-valued class functions with bounded values.
- Compute decoded multiplicities.
- Search for counterexamples to atomicity under the energy-1 condition.

This is falsifiable and can be explored in `demo.py`.

---

## Proof Architecture Requirements

Your file must contain at least 3 theorems whose proofs genuinely use deep tactics or multi-step reasoning. Specifically, ensure that at least three proofs visibly use some of:

- `induction` on `Finset`
- `rcases` to unpack span membership / linear combinations
- `by_contra`
- `field_simp` if denominator normalization appears in inner-product formulas
- multi-step `calc`
- extensionality on class functions
- sum rearrangement with orthogonality cancellation

Do not rely on `native_decide`, `decide`, `norm_num`, or `rfl` except for trivial helper lemmas.

---

## Suggested Implementation Order

### Step 1: Operator infrastructure
Prove linearity-style lemmas for `packetProjector`:
```lean
theorem packetProjector_add ...
theorem packetProjector_smul ...
```
These are likely easy but not trivial; they set up everything else.

### Step 2: Basis-vector action
Show projector fixes packet elements:
```lean
theorem packetProjector_eq_of_mem
    ...
    (hχ : χ ∈ χs) :
    packetProjector χs χ = χ
```
Use orthonormality and collapse the sum.

### Step 3: Span action
Show projector acts as identity on the span of `χs`.

### Step 4: Complete reconstruction
Deduce Theorem 1.

### Step 5: Parseval
Use reconstruction and orthogonality to prove Theorem 2.

### Step 6: Faithfulness and zero-energy criterion
Derive Theorem 3 and the cross-domain theorem.

---

## Catalog Building Blocks to Exploit

Use the already verified moonshine machinery in `Speculative/Moonshine/Defs.lean` and `Speculative/Moonshine/Theorems.lean`, especially:

- class function inner product definitions,
- moonshine packet structures,
- Fourier inversion lemmas already present,
- multiplicity decoding identities,
- any orthonormality/completeness predicates,
- extensionality lemmas for class functions,
- `Finset` sum lemmas over class functions and complex scalars.

If a theorem currently assumes `IsOrthonormal` or `IsCompleteOrthonormal`, build the new results on top of that first rather than immediately trying to derive orthogonality from Schur’s lemma. The goal of this cycle is to create the **spectral operator calculus**. Full derivation of orthogonality can be a next-cycle escalation.

---

## Why This Opens a New Field

This program creates a finite, exact, formal analog of spectral analysis where moonshine packets play the role of spectral bases and multiplicity decoding plays the role of observable extraction. That opens several follow-on directions:

- **Arithmetic harmonic analysis**: study packet energy distributions across natural families of class functions.
- **Quantum information analogs**: informational completeness, reconstruction, and entropy-like packet invariants.
- **Automorphic heuristics**: treat packets as toy models for spectral decomposition of automorphic forms.
- **Computational moonshine**: fast verified decomposition algorithms for class-function data.

The shift is from “formalizing character identities” to “building a rigorous spectral science of moonshine.”

---

## Application Keywords

spectral moonshine, finite harmonic analysis, Parseval identity, Plancherel theorem, class functions, representation theory, spectral reconstruction, orthonormal packets, projector formalism, informational completeness, quantum tomography, inverse problems, signal decomposition, multiplicity decoding, character theory, finite groups, operator theory, spectral statistics

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean development** with the new definitions and at least 3 deep theorems as above.
2. **A verified algorithm or computational method**:
   - implement a procedure that, given a packet `χs` and a class function `f`, computes decoded coefficients and reconstructs `packetProjector χs f`;
   - verify at least one correctness theorem relating the algorithmic output to the mathematical definition.
3. **`demo.py`**:
   - interactively demonstrate spectral decoding and reconstruction on at least one small finite group example or a mock finite packet model;
   - include a computational search for the conjecture above and report whether any counterexample is found in the tested range.
4. **`RESEARCH_PAPER.md`**:
   - a standalone scientific document explaining the new spectral moonshine theorems, precise statements, proof ideas, significance, and next questions;
   - must be readable with no access to code.
5. **`ARTICLE.md`**:
   - Scientific American style;
   - explain the ideas, not the verification machinery;
   - taboo: do not focus on formal verification itself.
6. **`FUTURE_DIRECTIONS.md`**:
   - 3–5 original research directions;
   - each direction must contain the exact sentences:
     - “The key insight is ...”
     - “Why now?”
   - at least one direction must bridge to a different domain such as quantum information, automorphic forms, or signal processing.

---

## Final Standard

Do not settle for a minor lemma. Produce a spectral reconstruction package that makes it impossible to think of moonshine packets as mere notation. The goal is to make `Speculative/Moonshine` look like the first chapter of a new subject: finite spectral moonshine.

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
