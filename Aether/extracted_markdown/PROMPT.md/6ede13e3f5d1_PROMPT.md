Soli Deo Gloria

## Assignment: The Monster Group's Secret Message: Moonshine Beyond the j-Function

**Mode:** prove / formalize / counterexample-aware

Aristotle, the raw prompt is too optimistic in one crucial place: the statement “the product over all conjugacy classes of Monster McKay–Thompson series equals a modular form of weight \(|M|/24\) encoding the complete character table” is not currently a mathematically responsible theorem target in a Lean-first setting. The right breakthrough is to formalize a **structural moonshine calculus**: prove rigorous theorems about coefficient extraction, class-function reconstruction, and multiplicative/Dirichlet-type packaging of replicable series that make the “Monster is a modular object” slogan precise in a form we can actually certify.

Your mission is therefore to build a new formal bridge:

- from **graded \(G\)-modules and class functions**
- to **\(q\)-series packages of moonshine type**
- to **reconstruction theorems** showing how enough \(q\)-expansion data determines representation-theoretic information.

The revolutionary point is not to reprove all of Conway–Norton in Lean. It is to create the first **formal infrastructure for moonshine as an information-theoretic transform from finite group theory to modular-style generating series**. If successful, this opens a field: machine-checkable moonshine, replicability as algebra, and spectral fingerprints of sporadic groups.

---

## Core Research Objective

Replace the overreaching conjecture by a precise formal program:

1. **Define a new mathematical structure** capturing moonshine data for a finite group \(G\):
   a family of class functions \(a_n : G \to \mathbb{C}\) assembled into formal \(q\)-series
   \[
   T_g(q) = \sum_{n \ge n_0} a_n(g) q^n.
   \]
2. **Prove reconstruction theorems**: if the coefficient class functions \(a_n\) are virtual characters, then the family \(\{T_g\}_{g \in G}\) determines the graded virtual \(G\)-module up to isomorphism.
3. **Prove multiplicative packaging theorems** for finite products and logarithmic derivatives of these series under hypotheses guaranteeing coefficient-wise well-definedness.
4. **Connect to another domain**: interpret the reconstruction map as a finite-dimensional harmonic/Fourier transform on class functions, and prove an inversion theorem using character orthogonality.
5. **State a falsifiable computational conjecture** about replicability-type identities or coefficient growth patterns for a finite toy moonshine package (e.g. for cyclic groups, \(S_3\), \(A_5\), or a catalog-available finite group).

This is already field-opening: a verified moonshine transform, not just isolated coefficient identities.

---

## Precise Theorem Targets

You must prove **at least 3 substantial theorems**. Here are the primary targets.

### Theorem 1: Character-coefficient reconstruction of graded multiplicities

Let \(G\) be a finite group, let \(V_n\) be finite-dimensional complex \(G\)-representations, and define
\[
a_n(g) := \mathrm{Tr}(g \mid V_n).
\]
Then irreducible multiplicities are recovered from the coefficient class functions by the standard inner product:
\[
m_{n,\chi} = \frac{1}{|G|}\sum_{g \in G} a_n(g)\,\overline{\chi(g)}\,|C_g|,
\]
equivalently via summation over all group elements.

This is the rigorous core of “the \(q\)-series remembers the representation theory.”

**Lean 4 type signature target** (adapt to Mathlib’s exact APIs for `MonoidAlgebra`, `ClassFunction`, `Character`, and `LaurentSeries`/formal power series as needed):
```lean
theorem multiplicity_eq_classFunction_inner
  {G : Type*} [Finite G] [Group G]
  (V : ℕ → Rep ℂ G) (χ : IrrRep ℂ G) (n : ℕ) :
  multiplicity χ (V n) =
    classFunctionInner
      (character (V n))
      (irreducibleCharacter χ)
```
or, if the representation API is not mature enough, formulate at the level of class functions:
```lean
theorem multiplicity_eq_inner_of_virtual_character
  {G : Type*} [Finite G] [Group G]
  (a : ℕ → ClassFunction G ℂ)
  (ha : ∀ n, IsVirtualCharacter (a n))
  (χ : IrrChar G ℂ) (n : ℕ) :
  multiplicityOf (a n) χ =
    classFunctionInner (a n) χ
```

**Why this matters:** it turns moonshine coefficients into a recoverable data structure, not just an observed coincidence.

---

### Theorem 2: Equality of moonshine packages from equality of coefficient class functions

Define a new structure `MoonshinePacket G R` consisting of a lower truncation index and coefficient class functions \(a_n : \mathrm{Cl}(G)\to R\). Prove extensionality: two packets are equal if all coefficient class functions agree.

**New definition requirement**:
```lean
structure MoonshinePacket (G : Type*) [Finite G] [Group G] (R : Type*) [Semiring R] where
  lowerBound : ℤ
  coeff : ℤ → ClassFunction G R
  support_condition : ∀ n < lowerBound, coeff n = 0
```
You may instead use `LaurentSeries (ClassFunction G R)` if more natural, but you must introduce at least one genuinely new definition beyond existing catalog objects.

**Extensionality theorem target**:
```lean
theorem MoonshinePacket.ext
  {G : Type*} [Finite G] [Group G]
  {R : Type*} [Semiring R]
  {A B : MoonshinePacket G R}
  (h : ∀ n, A.coeff n = B.coeff n) :
  A = B
```

This seems simple, but do not stop there. Use it as the engine for the deeper theorem:

### Theorem 2b: Reconstruction uniqueness
If two graded virtual \(G\)-modules have identical graded trace class functions in every degree, then they have equal irreducible multiplicity profiles in every degree.

```lean
theorem graded_module_determined_by_traces
  {G : Type*} [Finite G] [Group G]
  (A B : ℕ → ClassFunction G ℂ)
  (hA : ∀ n, IsVirtualCharacter (A n))
  (hB : ∀ n, IsVirtualCharacter (B n))
  (hEq : ∀ n g, A n g = B n g) :
  ∀ n χ, multiplicityOf (A n) χ = multiplicityOf (B n) χ
```

**Why this matters:** this is the exact formal content of “the McKay–Thompson data determines the representation data.”

---

### Theorem 3: Fourier inversion on class functions as moonshine decoding

For finite \(G\), prove that class functions are reconstructed from their inner products with irreducible characters. This is the cross-domain theorem: moonshine becomes **harmonic analysis on finite groups**.

A precise statement:
\[
f = \sum_{\chi \in \mathrm{Irr}(G)} \langle f,\chi\rangle \chi.
\]

**Lean 4 type signature target**:
```lean
theorem classFunction_fourier_expansion
  {G : Type*} [Finite G] [Group G] :
  ∀ f : ClassFunction G ℂ,
    f = ∑ χ in Finset.univ, (classFunctionInner f χ) • χ
```
If `Finset.univ` over irreducible characters is unavailable, build a finite indexing type of irreducible characters or prove a version with an explicit finite family satisfying orthonormal basis hypotheses.

**Why this is a breakthrough:** it recasts moonshine as spectral decoding. This creates a bridge to signal processing, quantum symmetry, and data compression: a sporadic group becomes a frequency basis.

---

### Theorem 4: Coefficient-wise well-defined finite product of moonshine packets

Do **not** attempt an infinite product over 194 classes unless you can rigorously control convergence in a formal topology already in Mathlib. Instead prove a finite product theorem:

For a finite index set \(I\) and packets \(T_i(q) = \sum_n a_{i,n} q^n\) with lower bounds, the product
\[
\prod_{i \in I} T_i(q)
\]
has well-defined coefficients given by finite convolution sums, and the coefficient at degree \(N\) depends only on finitely many tuples summing to \(N\).

**Lean 4 type signature target**:
```lean
theorem coeff_finset_prod_moonshinePacket
  {ι G : Type*} [Fintype ι]
  [Finite G] [Group G]
  {R : Type*} [Semiring R]
  (S : Finset ι) (T : ι → MoonshinePacket G R) (N : ℤ) :
  ∃ F : Finset (ι → ℤ),
    coeff (Finset.prod S T) N =
      ∑ f in F, ∏ i in S, (T i).coeff (f i)
```
You may need to reformulate using `AddMonoidAlgebra`, `LaurentSeries`, or finitely supported functions to make the statement natural.

**Why this matters:** it gives a rigorous version of “package all McKay–Thompson series together.” Even finite products are nontrivial and foundational.

---

## Cross-Domain Connection Theorem

You are required to include at least one theorem connecting moonshine to another domain.

### Recommended connection: finite-group harmonic analysis / information theory

Define the **moonshine spectral entropy** of a normalized class function \(f\) by taking squared Fourier coefficients against irreducible characters as a probability distribution (when normalized appropriately). Prove a basic invariance theorem under conjugation/class-function equality.

Possible formal statement:
```lean
def spectralWeight
  {G : Type*} [Finite G] [Group G]
  (f : ClassFunction G ℂ) (χ : IrrChar G ℂ) : ℝ := ...

theorem spectralWeight_invariant_of_eq
  {G : Type*} [Finite G] [Group G]
  {f g : ClassFunction G ℂ}
  (h : f = g) :
  spectralWeight f = spectralWeight g
```
That is too easy alone, so strengthen it:

### Better theorem:
If \(f\) and \(g\) are orthogonal class functions, then their Fourier coefficient vectors are orthogonal in character space.

This turns moonshine data into a Parseval/Fourier geometry statement.

**Application keywords:** harmonic analysis, representation learning, symmetry fingerprints, spectral decoding, information compression.

Alternative cross-domain bridge: statistical mechanics. Interpret graded traces as partition functions and prove multiplicativity under direct sums/tensor products:
\[
Z_{V \oplus W}(g,q)=Z_V(g,q)+Z_W(g,q),\qquad
Z_{V \otimes W}(g,q)=Z_V(g,q)\,Z_W(g,q)
\]
with suitable grading conventions.

---

## Falsifiable Conjecture With Computational Test

You must state at least one conjecture that can fail by explicit computation.

### Suggested conjecture: spectral sparsity for toy moonshine packets
For a chosen nonabelian finite group \(G\) with manageable character table (e.g. \(A_5\) or \(S_4\)), define a natural graded packet from symmetric powers of a faithful representation:
\[
T_g(q)=\sum_{n\ge0}\mathrm{Tr}(g\mid \mathrm{Sym}^n(V))q^n.
\]
Conjecture: after normalization, the first \(N\) Fourier-character coefficients of \(T_g\) satisfy a monotonic concentration property or eventual log-concavity.

Example:

```text
Conjecture (testable): For G = A₅ and V its 3-dimensional irreducible representation,
the multiplicity sequence of each irreducible character inside Symⁿ(V) is eventually
log-concave in n.
```

This is excellent because:
- it is representation-theoretic,
- it is experimentally testable,
- it could be false,
- it gestures toward moonshine-style hidden regularity.

You must implement a computational test in `demo.py` to search for counterexamples for \(n \le 100\) or another justified cutoff.

---

## Proof Strategy Architecture

You must not give only one route. Develop at least 2–3 strategy paths and choose the most promising.

### Strategy A: Character orthogonality first
1. Formalize class functions and irreducible characters as a finite-dimensional inner product space.
2. Prove orthogonality/projector lemmas.
3. Deduce reconstruction and multiplicity formulas by expanding coefficient class functions in the irreducible basis.

**Why promising:** this is the mathematically canonical route and likely aligns best with Mathlib’s existing finite-group and linear-algebra infrastructure.

---

### Strategy B: Burnside ring / representation ring packaging
1. Work in the Grothendieck group of finite-dimensional representations.
2. Define graded virtual modules as functions \(\mathbb{Z}\to R(G)\).
3. Push the character map degreewise into class functions, then prove injectivity via character theory.

**Why promising:** cleaner conceptual algebra; especially good if Mathlib’s representation ring support is sufficient.

**Risk:** representation-ring APIs may be thinner than class-function APIs.

---

### Strategy C: Formal power series first, then representation theory
1. Define moonshine packets as Laurent/formal power series with coefficients in class functions.
2. Prove extensionality and coefficient formulas for products and logarithmic derivatives.
3. Recover representation data coefficientwise using character inner products.

**Why promising:** best for the “package all \(T_g\)” narrative and for computational methods.

**Risk:** series-over-class-functions APIs may require more infrastructure work.

---

### Recommended route
Use **Strategy A + C**:
- A for the deep theorems,
- C for the novel structure and algorithmic packaging.

This yields genuine mathematics, not just API wrestling.

---

## Suggested Catalog Building Blocks

Use live catalog results aggressively. In particular, search for and build on:
- finite group character orthogonality lemmas,
- class function algebra structures,
- finite-dimensional inner product space facts,
- formal power series / Laurent series coefficient lemmas,
- finite support convolution lemmas,
- `Matrix`, `LinearAlgebra`, and `BigOperators` tools for expansion arguments.

If the catalog contains any of the following, exploit them explicitly:
- orthonormal basis theorems for finite-dimensional complex inner product spaces,
- finite Fourier inversion templates,
- coefficient extraction lemmas for products of power series,
- existing `Rep ℂ G` or character-map constructions.

In the final writeup, cite the exact theorem names and file paths you used from Mathlib or the project catalog.

---

## Required New Definitions

At least one of the following must be introduced:

1. `MoonshinePacket G R`
2. `IsVirtualCharacter` for class functions presented as integer combinations of irreducibles
3. `gradedTraceSeries`
4. `spectralWeight` / `spectralEntropy` for class functions
5. `ReplicableLike` for coefficient recursion patterns in toy moonshine models

You need at least one genuinely novel definition; two would be better.

---

## Verified Algorithm / Computational Method

You must provide a verified computational method, not merely theorem statements.

### Recommended algorithm
Implement an algorithm that, given:
- a finite group \(G\),
- its irreducible characters \(\chi_i\),
- a degreewise class function \(a_n\),

computes the multiplicity vector
\[
m_{n,i} = \langle a_n,\chi_i\rangle.
\]

Then prove correctness:
```lean
theorem decodeMultiplicities_correct
  {G : Type*} [Finite G] [Group G]
  (a : ClassFunction G ℂ) :
  decodeMultiplicities a = fourierCoefficients a
```
or a more concrete equivalent theorem tied to your implementation.

This is the formal decoder from moonshine series to representation content.

### demo.py
Your `demo.py` must:
- construct a toy moonshine packet for a manageable finite group,
- compute first coefficients,
- decode multiplicities using the verified formula,
- test the stated conjecture,
- visualize at least one coefficient or multiplicity sequence.

Do not fake Monster data. Be honest: use a finite group with accessible character table unless actual Monster-related coefficient tables are already in the repository.

---

## Important Counterexample Discipline

If the original “product over all Monster classes converges to a modular form encoding the whole character table” cannot be responsibly formalized with available infrastructure, you must explicitly say so and either:

- prove a **finite-product analogue**, or
- provide a **counterexample/obstruction theorem** showing why naïve coefficientwise products do not automatically define modular forms.

A valuable obstruction theorem would be:

```lean
theorem finite_product_of_qseries_need_not_be_modular
  ...
```

or a weaker rigorously formalizable statement showing that coefficientwise algebra alone does not imply modularity. This is scientifically important: it separates what is representation-theoretic from what is genuinely modular-analytic.

---

## What Would Count as a Breakthrough Here?

Not “formalized a definition of McKay–Thompson series.”

A breakthrough is:

- a **general reconstruction theorem** for moonshine packets,
- a **formal Fourier inversion framework** for class-function-valued \(q\)-series,
- a **new algorithm** decoding graded representation content from trace data,
- a **cross-domain theorem** linking moonshine to harmonic analysis / statistical mechanics,
- and a **testable conjecture** generating new experiments.

That creates a new subject: **formal spectral moonshine**.

---

## Application Keywords

Include these explicitly in your writeup and metadata:

`monstrous moonshine`, `McKay–Thompson series`, `class functions`, `irreducible characters`, `Fourier inversion on finite groups`, `graded representations`, `q-series`, `spectral decoding`, `harmonic analysis`, `representation theory`, `partition functions`, `information compression`, `toy moonshine models`, `replicability`, `formal power series`

---

## Mandatory Deliverables

You must produce **ALL** of the following:

1. **Lean development** with at least 3 substantial theorems, satisfying the depth requirements:
   - no trivial `native_decide`/`decide`/`norm_num`/`rfl` filler unless mathematically central,
   - at least 3 proofs using genuine multi-step reasoning (`induction`, `rcases`, `by_contra`, `field_simp`, `calc`, etc.),
   - at least one new definition,
   - at least one cross-domain theorem,
   - at least one falsifiable conjecture with computational test.

2. **FUTURE_DIRECTIONS.md**
   - 3–5 original research directions,
   - each direction must include the exact phrases:
     - **“The key insight is...”**
     - **“Why now?”**
   - at least one direction must bridge moonshine to a different domain.

3. **RESEARCH_PAPER.md**
   - standalone scientific document,
   - must explain the problem, precise results, proof ideas, significance, and next questions,
   - readable without access to the code.

4. **ARTICLE.md**
   - Scientific American style,
   - engaging and accessible,
   - focus on the mathematics and significance,
   - **do not** focus on formal verification machinery.

5. **Verified algorithm**
   - multiplicity decoding, packet product coefficients, or equivalent computational core,
   - with a correctness theorem in Lean.

6. **demo.py**
   - interactive or script-based demonstration,
   - computes example moonshine packets for a finite group,
   - tests the conjecture,
   - displays/prints interpretable output.

---

## Final Directive

Be bold but mathematically honest. Do not pretend we can certify the full analytic modularity of Monster McKay–Thompson products if the infrastructure is not there. Instead, build the missing cathedral: the algebraic and spectral language in which moonshine becomes a rigorously manipulable object. If you succeed, the slogan

> “the Monster is a modular form”

will no longer be mystical rhetoric; it will become the shadow of a precise theorem schema about how finite symmetry is encoded, decoded, and compressed into \(q\)-expansions.

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

Research domain: Speculative
Research mode: prove
