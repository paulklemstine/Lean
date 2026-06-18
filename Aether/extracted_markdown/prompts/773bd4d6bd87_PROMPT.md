Soli Deo Gloria

## Assignment: Direction 5: Shadow Structure of Partition Functions and Phase Transitions

**Mode:** prove

You are not being asked for an incremental lemma. You are being asked to create a new geometric thermodynamics: a theory in which phase-transition signatures are detected through the combinatorics of support shadows of partition functions. The ambition is to extract a mathematically precise bridge between:

- **statistical mechanics**: partition functions, susceptibilities, response modes,
- **combinatorial geometry**: support sets and their second shadows,
- **analysis/convexity**: Hessians of log-partition functions,
- **discrete probability / information theory**: covariance structure of Gibbs observables.

Build on the catalog theorem from `Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean`, especially any result of the form `nonzeroQuadLeafSet_eq ...`, as the certified combinatorial mechanism identifying when second-order interaction modes are present. Your goal is to turn that mechanism into theorems about partition functions and response geometry.

## Central Vision

Let a finite family of states `ι` carry energies and observable vectors `a : ι → Fin n → ℕ`. Consider the multivariate partition function
\[
Z_\beta(x) \;=\; \sum_{s : ι} w_\beta(s)\, x^{a(s)},
\qquad w_\beta(s) = e^{-\beta E(s)} > 0.
\]
Its support
\[
S := \{ a(s) \mid s \in ι,\; w_\beta(s)\neq 0\}
\]
is independent of `β` in the strictly positive finite setting, so if a genuine phase-transition story is to emerge in finite volume, it cannot come merely from support size. The breakthrough move is to study not only support, but the **active second shadow relative to a thermodynamic point**: the set of quadratic response directions actually activated by the Gibbs state after logarithmic differentiation. This is where the catalog’s shadow machinery becomes physically meaningful.

You should therefore introduce a new notion — not present in the catalog — capturing the **thermodynamic active shadow** of a weighted support.

## Novel Definitions Required

Define at least one genuinely new concept. Recommended core definition:

### 1. Active pair shadow / thermodynamic second shadow
For a finite weighted support `(S, w)` with `w : S → ℝ≥0∞` or `ℝ`, define the set of coordinate pairs `(i,j)` whose second logarithmic response is nonzero:
\[
\mathrm{ActSh}_2(Z,y) := \{(i,j) \mid \partial_i\partial_j \log Z(e^y) \neq 0\}.
\]
Equivalent finite combinatorial reformulations should be proved when possible.

A more Lean-friendly algebraic proxy is:

- define the first moment vector under Gibbs weights at `y`,
- define the covariance matrix of the exponent vectors,
- define the active shadow as the support of that covariance matrix.

This is the right object because
\[
\partial_i \partial_j \log Z(e^y) = \mathrm{Cov}_{\mu_y}(a_i,a_j),
\]
a theorem that would itself be field-opening in this formal context.

Possible Lean structure names:
- `activeShadow2`
- `logPartitionCovSupport`
- `WeightedSupportModel`
- `PartitionModel`

## Precise Theorem Targets

You must prove **at least 3 substantial theorems**. Below are the target statements; prove as many of them as possible, and at minimum prove three with real proof architecture.

---

### Theorem 1: Hessian–covariance identity for multivariate partition functions

**Mathematical statement.**  
Let `ι` be finite, let `a : ι → Fin n → ℕ`, let `w : ι → ℝ` with `0 < w s` for all `s`, and define
\[
Z(y) = \sum_{s:ι} w(s)\exp\!\Big(\sum_i y_i\, a(s)_i\Big).
\]
Then for all `i,j`,
\[
\partial_i\partial_j \log Z(y)
=
\mathbb E_{\mu_y}[a_i a_j] - \mathbb E_{\mu_y}[a_i]\mathbb E_{\mu_y}[a_j]
=
\mathrm{Cov}_{\mu_y}(a_i,a_j),
\]
where
\[
\mu_y(s)=\frac{w(s)e^{\langle y,a(s)\rangle}}{Z(y)}.
\]

**Why this is a breakthrough.**  
This theorem converts a geometric/combinatorial support problem into a thermodynamic response theorem. It says the second shadow is not merely combinatorial decoration: it is exactly the support pattern of the susceptibility matrix.

**Lean 4 target signature (suggested).**
```lean
theorem d2_logPartition_eq_covariance
  {ι : Type*} [Fintype ι] [DecidableEq ι]
  {n : ℕ}
  (w : ι → ℝ) (a : ι → Fin n → ℕ)
  (hw : ∀ s, 0 < w s) :
  ∀ y : Fin n → ℝ, ∀ i j : Fin n,
    secondLogPartition w a y i j
      = covarianceEntry w a y i j
```

If full Fréchet derivative machinery is too heavy, define `secondLogPartition` directly by the explicit finite-sum formula and prove equality to covariance algebraically. The theorem is still deep if the proof requires several transformations and nontrivial normalization identities.

---

### Theorem 2: Zero covariance iff coordinate factor is constant on support

**Mathematical statement.**  
Assume all Gibbs weights are strictly positive. For a fixed coordinate `i`,
\[
\mathrm{Var}_{\mu_y}(a_i)=0
\quad\Longleftrightarrow\quad
a_i \text{ is constant on } \mathrm{Supp}(Z).
\]
More generally, for `i,j`, if every state has positive Gibbs weight at `y`, then
\[
\mathrm{Cov}_{\mu_y}(a_i,a_j)=0
\]
whenever one of the coordinates is constant on support; and under an appropriate nondegeneracy hypothesis, non-constancy forces existence of an active shadow direction.

**Why this matters.**  
This is the rigorous bridge from support geometry to response activation. It tells you exactly when a direction is thermodynamically silent: only when the support has collapsed along that coordinate.

**Lean 4 target signature (suggested).**
```lean
theorem variance_zero_iff_constant_on_support
  {ι : Type*} [Fintype ι] [DecidableEq ι]
  {n : ℕ}
  (w : ι → ℝ) (a : ι → Fin n → ℕ)
  (hw : ∀ s, 0 < w s) :
  ∀ y : Fin n → ℝ, ∀ i : Fin n,
    varianceEntry w a y i = 0 ↔
      ∃ c : ℕ, ∀ s : ι, a s i = c
```

A more flexible statement replacing “all `s`” with “all `s` in weighted support” is also excellent.

---

### Theorem 3: Active shadow is exactly covariance support

**Mathematical statement.**  
Define the active second shadow of the partition model at `y` by
\[
\mathrm{ActSh}_2(Z,y)=\{(i,j)\mid \partial_i\partial_j\log Z(e^y)\neq 0\}.
\]
Then
\[
(i,j)\in \mathrm{ActSh}_2(Z,y)
\quad\Longleftrightarrow\quad
\mathrm{Cov}_{\mu_y}(a_i,a_j)\neq 0.
\]
Further, using the catalog shadow theorem, prove a combinatorial criterion implying membership in the active shadow whenever the weighted support contains a certified quadratic leaf/pair pattern.

**Why this matters.**  
This theorem identifies the physically measurable response modes with a combinatorial shadow object. This is the exact conceptual core of the project.

**Lean 4 target signature (suggested).**
```lean
theorem mem_activeShadow2_iff_covariance_ne_zero
  {ι : Type*} [Fintype ι] [DecidableEq ι]
  {n : ℕ}
  (w : ι → ℝ) (a : ι → Fin n → ℕ)
  (hw : ∀ s, 0 < w s) :
  ∀ y : Fin n → ℝ, ∀ ij : Fin n × Fin n,
    ij ∈ activeShadow2 w a y ↔
      covarianceEntry w a y ij.1 ij.2 ≠ 0
```

---

### Theorem 4: Monotonic lower bound from support shadow to response rank

**Mathematical statement.**  
Using the catalog theorem(s) about weighted quadratic leaf sets/shadows, prove a theorem of the form:
\[
|\mathrm{ActSh}_2(Z,y)| \ge C(S)
\]
for some purely combinatorial lower bound `C(S)` extracted from the weighted support shadow structure. Even a weaker theorem of the form
\[
\text{if a certified quadratic leaf pattern exists, then } |\mathrm{ActSh}_2(Z,y)|\ge 1
\]
is already meaningful if done cleanly and generally.

A stronger matrix version:
\[
\operatorname{rank}(\nabla^2 \log Z(y)) \ge \dim \operatorname{span}(S-S)
\]
or a formally manageable lower bound thereof.

**Why this is revolutionary.**  
This is where combinatorics begins to predict thermodynamic complexity. It is the seed of a geometric theory of phase transitions.

**Lean 4 target signature (suggested).**
```lean
theorem activeShadow2_card_pos_of_nontrivial_weightedSupportShadow
  {ι : Type*} [Fintype ι] [DecidableEq ι]
  {n : ℕ}
  (w : ι → ℝ) (a : ι → Fin n → ℕ)
  (hw : ∀ s, 0 < w s) :
  hasNontrivialQuadLeafPattern w a →
    0 < Fintype.card (activeShadow2 w a y)
```

Adjust codomain/set representation as needed.

---

### Theorem 5: Cross-domain theorem — positive semidefiniteness and information geometry

**Mathematical statement.**  
The Hessian of `log Z` is positive semidefinite:
\[
v^\top \nabla^2 \log Z(y)\, v = \mathrm{Var}_{\mu_y}(\langle v,a\rangle)\ge 0.
\]
Hence `log Z` is convex, and the active shadow detects exactly which coordinate directions contribute to Fisher-information-like curvature.

This is the required **cross-domain connection**: statistical physics ↔ convex analysis ↔ information geometry.

**Lean 4 target signature (suggested).**
```lean
theorem logPartition_hessian_posSemidef
  {ι : Type*} [Fintype ι] [DecidableEq ι]
  {n : ℕ}
  (w : ι → ℝ) (a : ι → Fin n → ℕ)
  (hw : ∀ s, 0 < w s) :
  ∀ y : Fin n → ℝ, ∀ v : Fin n → ℝ,
    0 ≤ quadFormCovariance w a y v
```

If matrix formalization is too expensive, prove the scalar variance identity directly.

---

## Lean Formalization Guidance

### Recommended file
Create a new file, for example:
`Blueprints/PhaseTransitions/PartitionShadow.lean`

If you directly import and extend the catalog result, explicitly cite:
`Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean`

### Suggested definitions
Use finite sums over `Fintype ι`. Avoid analytic overreach if unnecessary; define the partition function in log-coordinates:
\[
Z(y)=\sum_s w(s)\exp(\sum_i y_i a(s,i)).
\]
This avoids monomial evaluation issues over nonnegative exponents and makes derivative/covariance identities natural.

Possible definitions:
```lean
def energyWeight (β : ℝ) (E : ι → ℝ) (s : ι) : ℝ := Real.exp (-β * E s)

def logLinear (a : ι → Fin n → ℕ) (y : Fin n → ℝ) (s : ι) : ℝ :=
  ∑ i, y i * (a s i : ℝ)

def partitionFun (w : ι → ℝ) (a : ι → Fin n → ℕ) (y : Fin n → ℝ) : ℝ :=
  ∑ s, w s * Real.exp (logLinear a y s)

def gibbsProb (w : ι → ℝ) (a : ι → Fin n → ℕ) (y : Fin n → ℝ) (s : ι) : ℝ :=
  (w s * Real.exp (logLinear a y s)) / partitionFun w a y

def observableMean ...
def covarianceEntry ...
def activeShadow2 ...
```

## Proof Strategy Architecture

You must provide 2–3 viable proof routes in the code comments or paper, and pursue the most promising one.

### Strategy A: Algebraic finite-sum thermodynamics (most promising)
1. Define normalized Gibbs weights from finite positive sums.
2. Expand first derivatives of `log Z` as normalized first moments.
3. Differentiate again, or algebraically derive the explicit second derivative formula, to obtain covariance.
4. Use positivity of weights to prove variance-zero iff constancy on support.
5. Transfer nonzero covariance statements into active-shadow membership.

**Why most promising:** it avoids hard measure theory and uses only finite sums, positivity, and algebraic identities. This is ideal for Lean 4 + Mathlib.

### Strategy B: Convex-analytic / cumulant-generating-function route
1. Recognize `log Z` as the log-sum-exp of affine forms.
2. Invoke or prove convexity of log-sum-exp.
3. Identify gradient as expectation and Hessian as covariance by a cumulant argument.
4. Deduce active-shadow criteria from strict convexity along coordinate directions.

**Why powerful:** conceptually elegant and opens direct links to information geometry and large deviations. Use this if Mathlib support for derivatives of finite sums and `Real.exp` is adequate.

### Strategy C: Catalog-shadow-first route
1. Start from `WeightedSupportShadow.lean` and the theorem `nonzeroQuadLeafSet_eq ...` or related certified support-shadow statements.
2. Show that each certified quadratic leaf pattern induces a nonconstant quadratic observable under Gibbs weighting.
3. Translate that into a nonzero covariance/Hessian entry via positivity.
4. Conclude lower bounds on active shadow size from combinatorial shadow size.

**Why important:** this is the route that genuinely leverages the catalog and turns an existing combinatorial theorem into new thermodynamic mathematics.

## Deep Proof Tactics Requirement

Your file must include at least 3 theorems whose proofs genuinely use multi-step reasoning. In particular, aim to use:

- `induction` over finite sums or support cardinality,
- `rcases` for extracting witnesses from non-constancy / support-shadow hypotheses,
- `by_contra` for variance-zero/non-constancy contradictions,
- `field_simp` when normalizing by partition functions,
- multi-step `calc` blocks for moment identities.

Do **not** hide everything behind automation. The proofs should teach the mathematics.

## Cross-Domain Connections You Must Explicitly Develop

At least one theorem and accompanying exposition must connect this direction to another domain. Strong candidates:

1. **Information geometry**  
   The Hessian of `log Z` is a Fisher-information-type matrix for the exponential family generated by exponent vectors `a(s)`.  
   **Connection:** active shadow = support of information curvature.

2. **Convex geometry / Newton polytopes**  
   The support `S` determines a polytope; covariance detects which face directions remain thermodynamically active under Gibbs weighting.  
   **Connection:** phase structure as a shadow/face activation phenomenon.

3. **Combinatorics + physics**  
   The weighted support shadow predicts the number of second-order response channels.  
   **Connection:** susceptibility complexity from support combinatorics.

4. **Large deviations / cumulants**  
   `log Z` is a cumulant generating function.  
   **Connection:** the second shadow measures nontrivial second cumulants.

## Falsifiable Conjecture with Computational Test

You must state a clear conjecture, and the conjecture must be computationally testable.

### Recommended sharpened conjecture
For finite-volume lattice models with external field variables encoded in exponent vectors, define the thermodynamic active shadow
\[
A_\beta(y) := \mathrm{ActSh}_2(Z_\beta,y).
\]
Then there exists a model-dependent finite-size scaling window around `β_c` such that the normalized active-shadow density
\[
\rho_\beta := \frac{|A_\beta(0)|}{n^2}
\]
shows maximal discrete derivative near `β_c`, and for sequences of increasing lattices this peak converges to the known critical inverse temperature.

This is falsifiable: if for a known critical model (e.g. 2D Ising on toroidal `L×L` grids for increasing `L`) the maximal jump/peak in `ρ_β` fails to drift toward `β_c`, the conjecture is false.

A second, more combinatorial conjecture:
\[
|\mathrm{ActSh}_2(Z_\beta,0)| \ge c \cdot |\mathrm{Sh}_2(\mathrm{Supp}(Z_\beta))|
\]
for all strictly positive finite Gibbs models, for some model-class constant `c>0`.  
This too is falsifiable by exhaustive small-lattice computation.

## Computational / Algorithmic Deliverable

You must produce a **verified algorithm**, not just theorems.

### Required algorithm
Implement an algorithm that, given:
- a finite state space `ι`,
- positive weights `w`,
- exponent vectors `a : ι → Fin n → ℕ`,
- a point `y`,

computes:
1. `partitionFun w a y`,
2. the Gibbs means,
3. the covariance matrix,
4. `activeShadow2 w a y`,
5. its cardinality and density.

Then prove a correctness theorem connecting the algorithmic output to the mathematical definitions.

Suggested theorem:
```lean
theorem computeActiveShadow2_correct
  ... :
  computeActiveShadow2 w a y = activeShadow2 w a y
```

If exact floating-point verification is awkward, separate:
- exact combinatorial support computation in Lean,
- numerical exploration in `demo.py`.

## demo.py Requirements

Write `demo.py` to experimentally explore the conjecture on:
- 2D Ising model on small `L × L` grids (`L = 2,3,4` at minimum),
- optionally Potts and dimer models.

The script should:
1. enumerate states for small lattices,
2. construct exponent vectors for chosen observables,
3. compute partition weights at varying `β`,
4. compute covariance matrices / active shadows,
5. plot `|ActSh₂|` or its density versus `β`,
6. compare peak locations with known critical values.

This is not decorative: it is how you test whether the formal theorems are glimpsing a real finite-size precursor of phase transition.

## Application Keywords

Use and foreground these:
- partition function
- Gibbs measure
- susceptibility
- covariance
- Hessian of log-partition
- active shadow
- support geometry
- weighted support shadow
- phase transition
- critical temperature
- information geometry
- convexity
- cumulants
- lattice models
- Ising model
- Potts model
- finite-size scaling

## Mandatory Deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions** growing out of this work. Each direction must include the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- tropical geometry,
- information theory,
- computational complexity,
- quantum many-body systems,
- matroid theory.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper that explains:
- the new definitions,
- the main theorems,
- why the active shadow is a geometric response invariant,
- how the catalog shadow theorem is used,
- what the computational evidence suggests,
- what the next conjectures are.

A reader with no access to the code must still understand the mathematics and significance.

### 3. `ARTICLE.md`
Write this in **Scientific American style**:
- vivid,
- concept-driven,
- broad-audience accessible,
- focused on the mathematics and physics ideas.

**Taboo:** do **not** make the story about formal verification. Make it about a new geometric lens on phase transitions.

### 4. Verified algorithm / computational method
As above: exact or certifiably correct computation of active second shadow data.

### 5. `demo.py`
Interactive or script-based exploration of the active shadow in small lattice models.

## Final Charge

Do not merely formalize a known covariance identity. Build a new language in which **support shadows become thermodynamic observables**. The decisive outcome is not one isolated theorem; it is a coherent theory showing that the combinatorics of weighted support governs the geometry of response.

The field-opening target is this:

> A finite partition model has a mathematically definable active second shadow, this shadow is exactly the support of the covariance/Hessian response tensor, and certified weighted support-shadow patterns force nontrivial thermodynamic response modes.

If you can make that precise and prove it cleanly in Lean, you will have created a new bridge between combinatorial geometry and statistical physics.

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
