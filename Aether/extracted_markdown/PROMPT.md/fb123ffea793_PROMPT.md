## Assignment: Algebra–MachineLearning–Speculative Prime-Congruence Rate–Distortion Duality via Neural Operad Spectra and Canonical Observer Codes

**Mode:** `prove`

Prove genuinely new theorems that open a coding-theoretic branch of algebraic ML: an internal rate–distortion theory for finitely generated neural operads, where “distortion” is not Euclidean error but failure of a finite proof-observer family to distinguish models through prime-congruence spectral predicates. This should not be a variant of existing PAC–Bayes/generalization results; it should be a new duality principle.

Build aggressively on the catalog around:
- `OperadicDeepLearning/Foundations`
- `PrimeCongruenceNeuralCompression`
- declarations involving `NeuralOperad`, `NeuralLayer`, `generatorCount`, `depth`
- observer predicates such as `CodeEq`, `DiagonalAvoidsOn`, `FiniteProofObserverFamily`
- spectral declarations such as `SpectralSeparator`
- any existing finite minimization / argmin lemmas in Mathlib over `Finset`, `Fintype`, bounded naturals, and finite search spaces.

Minimize sorry. If a key definition is absent, introduce the smallest correct abstraction that supports the theorem architecture below.

---

## Vision

Create the first **observer-relative algebraic rate–distortion theory** for neural operads:

> A finitely generated neural operad model carries an intrinsic compression law relative to a finite family of proof-observers, and the optimal code length is governed by a prime-congruence spectral variational principle.

This is the right theorem because it fuses:
- **rate–distortion theory** from information theory,
- **prime spectra / congruence geometry** from semiring-style algebra,
- **observer semantics / proof witnesses** from logic,
- **operadic compositionality** from deep learning architectures.

If formalized cleanly, this opens an entirely new research lane: **algebraic lossy compression of compositional models under semantic observers**.

---

## Core Definitions to Introduce Precisely

You should define, or adapt from catalog material, the following objects.

### 1. Observer distortion
For a finite observer family `O`, define a weighted or unweighted observer distortion between models `M N`:
- either as the normalized number of observers that distinguish them,
- or as a finite weighted sum if weights already exist in the catalog.

The key design choice is that distortion is **semantic and spectral**, not parameter-space based:
an observer distinguishes `M` and `N` if some `SpectralSeparator`/`CodeEq`/`DiagonalAvoidsOn` witness fires.

A robust formal shape is:

```lean
def ObserverDistinguishes
  (O : FiniteProofObserverFamily α)
  (M N : NeuralOperad σ) : Prop := ...
```

```lean
def observerDistortion
  (O : FiniteProofObserverFamily α)
  (M N : NeuralOperad σ) : Rat := ...
```

If normalized rational values are awkward, use `ℕ` first and derive the normalized version later.

### 2. Observer-stable code complexity
Define a code complexity / description length on models, ideally from existing `generatorCount`, optionally paired lexicographically with `depth`:

```lean
def modelCodeLength (M : NeuralOperad σ) : ℕ :=
  generatorCount M
```

or

```lean
def modelComplexity (M : NeuralOperad σ) : ℕ × ℕ :=
  (generatorCount M, depth M)
```

If needed, define the scalarized complexity `generatorCount + depth`.

### 3. Operadic rate–distortion function
For fixed target `M` and observer family `O`, define:

```lean
def operadicRateDistortion
  (O : FiniteProofObserverFamily α)
  (M : NeuralOperad σ)
  (ε : Rat) : ℕ :=
  sInf {k | ∃ N, modelCodeLength N ≤ k ∧ observerDistortion O M N ≤ ε}
```

If `sInf` over naturals is inconvenient, define via finite minimization over a bounded search space.

### 4. Prime-congruence variational functional
Define a finite variational object built from observer-separating spectral data. The exact representation can be adapted to the catalog, but the theorem should identify `operadicRateDistortion` with a minimization over spectral separators / congruence certificates.

A workable abstraction is to define a finite family of admissible spectral certificates `C` and a cost:

```lean
structure PrimeCongruenceCertificate (σ α : Type _) where
  codeBudget : ℕ
  separates : ...
  stable : ...
```

```lean
def primeCongruenceFunctional
  (O : FiniteProofObserverFamily α)
  (M : NeuralOperad σ)
  (ε : Rat)
  (c : PrimeCongruenceCertificate σ α) : ℕ := ...
```

Then define the variational optimum:

```lean
def primeCongruenceRate
  (O : FiniteProofObserverFamily α)
  (M : NeuralOperad σ)
  (ε : Rat) : ℕ := ...
```

The bridge theorem should prove equality with `operadicRateDistortion`.

---

## Precise Theorem Targets

You should aim for a theorem package with three flagship results and one foundational lemma.

---

### Theorem 1: observer distortion is a pseudometric modulo observer equivalence

This gives the semantic geometry needed for everything else.

#### Mathematical statement
Let `O` be a finite observer family. Define `d_O(M,N)` as the fraction of observers in `O` that distinguish `M` and `N` through the available spectral/code predicates. Then:
1. `d_O(M,M)=0`
2. `d_O(M,N)=d_O(N,M)`
3. `d_O(M,P) ≤ d_O(M,N)+d_O(N,P)` provided the observer-separation predicate is compositional/subadditive under the catalog’s separator logic.
Hence `d_O` is a pseudometric, and it descends to a metric on observer-equivalence classes.

#### Lean 4 target signature
Use the strongest signature supported by your definitions; for example:

```lean
theorem observer_distortion_pseudometric
  (O : FiniteProofObserverFamily α) :
  PseudoMetricSpace (ObserverQuotient O (NeuralOperad σ))
```

If introducing a full `PseudoMetricSpace` is too heavy, first prove the component lemmas:

```lean
theorem observerDistortion_self
  (O : FiniteProofObserverFamily α)
  (M : NeuralOperad σ) :
  observerDistortion O M M = 0
```

```lean
theorem observerDistortion_symm
  (O : FiniteProofObserverFamily α)
  (M N : NeuralOperad σ) :
  observerDistortion O M N = observerDistortion O N M
```

```lean
theorem observerDistortion_triangle
  (O : FiniteProofObserverFamily α)
  (M N P : NeuralOperad σ) :
  observerDistortion O M P ≤
    observerDistortion O M N + observerDistortion O N P
```

#### Why this matters
This is the semantic replacement for norm geometry. Without it, compression remains ad hoc. With it, one can speak rigorously about covering numbers, compactness-by-finiteness, and observer-stable lossy coding.

---

### Theorem 2: finite attainment of operadic rate–distortion minimizers

This is the first true existence theorem: lossy operadic compression admits canonical optimal representatives when the observer family is finite and the search space is bounded by algebraic generation data.

#### Mathematical statement
Fix:
- a finitely generated model `M`,
- a finite observer family `O`,
- a distortion threshold `ε`,
- and a finite search bound induced by `generatorCount` and optionally `depth`.

Assume diagonal stability / observer admissibility sufficient to ensure that observer equivalence classes within the bound are finite and separator predicates are decidable. Then there exists a model `N*` such that:
- `d_O(M,N*) ≤ ε`,
- `modelCodeLength N* = R_O(ε)`,
- and among all minimizers it is canonical under a tie-breaker such as lexicographic `(generatorCount, depth)`.

#### Lean 4 target signature
A practical theorem shape:

```lean
theorem rate_distortion_operad_exists_minimizer
  (O : FiniteProofObserverFamily α)
  (M : NeuralOperad σ)
  (ε : Rat)
  (B : ℕ)
  (hfin : Finite {N : NeuralOperad σ // generatorCount N ≤ B})
  (hadm : ObserverAdmissible O)
  (hfeas : ∃ N : NeuralOperad σ, generatorCount N ≤ B ∧ observerDistortion O M N ≤ ε) :
  ∃ N : NeuralOperad σ,
    generatorCount N ≤ B ∧
    observerDistortion O M N ≤ ε ∧
    (∀ N' : NeuralOperad σ,
      generatorCount N' ≤ B →
      observerDistortion O M N' ≤ ε →
      modelCodeLength N ≤ modelCodeLength N')
```

Canonical version:

```lean
theorem rate_distortion_operad_exists_canonical_minimizer
  (O : FiniteProofObserverFamily α)
  (M : NeuralOperad σ)
  (ε : Rat)
  (B : ℕ)
  ... :
  ∃ N : NeuralOperad σ, IsCanonicalMinimizer O M ε B N
```

#### Why this matters
This turns “compression up to semantic observers” into a theorem rather than a heuristic. It is the algebraic analogue of finite rate–distortion codebook attainment, but in an operadic and proof-observer setting.

---

### Theorem 3: prime-congruence rate–distortion duality

This is the breakthrough theorem. The first two theorems prepare the finite geometry; this one identifies optimal code length with a spectral variational principle.

#### Mathematical statement
For a finitely generated neural operad model `M`, finite observer family `O`, and threshold `ε`, define:
- `R_O(M, ε)` = minimal code length among models `N` with observer distortion at most `ε`,
- `PC_O(M, ε)` = minimal prime-congruence spectral certificate cost among certificates that stabilize all but `ε` observer mass.

Then, under finite admissibility and diagonal stability hypotheses,

\[
R_O(M,\varepsilon) = PC_O(M,\varepsilon).
\]

This should be formulated as an exact equality of natural-number optimization problems, not just an inequality, if at all possible. If exact equality is too ambitious on the first pass, prove the two inequalities separately:
1. every admissible compressed model induces a spectral certificate of no greater cost;
2. every admissible spectral certificate reconstructs an observer-stable model of no greater cost.

#### Lean 4 target signature
Ideal:

```lean
theorem prime_congruence_rate_duality
  (O : FiniteProofObserverFamily α)
  (M : NeuralOperad σ)
  (ε : Rat)
  (B : ℕ)
  (hadm : ObserverAdmissible O)
  (hdiag : DiagonallyStable O)
  (hfin : FiniteSpectralSearchSpace O M B) :
  operadicRateDistortion O M ε =
    primeCongruenceRate O M ε
```

If exact equality requires intermediate abstractions, split into:

```lean
theorem operadicRateDistortion_le_primeCongruenceRate ...
```

```lean
theorem primeCongruenceRate_le_operadicRateDistortion ...
```

#### Why this is revolutionary
This would be a new duality principle: **semantic compression equals spectral congruence complexity**. It is a cousin of Shannon rate–distortion, but internal to algebraic model semantics. It suggests that prime spectra can serve as “semantic latent variables” for neural compression.

---

### Theorem 4: constructive canonical observer code with certified distortion

This is the algorithmic theorem that makes the theory computational.

#### Mathematical statement
Given:
- a finitely generated neural operad model `M`,
- finite observer family `O`,
- distortion threshold `ε`,
- search bound `B` from `generatorCount` / `depth`,

construct an explicit code `c` and decoded model `decode c` such that:
- `codeLength c = R_O(M,ε)` or at least `≤ R_O(M,ε) + δ` for a formalized approximation slack,
- `observerDistortion O M (decode c) ≤ ε`,
- the decoded model is observer-stable / canonical in its equivalence class.

This theorem should expose an actual finite search algorithm, not just existence.

#### Lean 4 target signature
For a deterministic constructor:

```lean
def canonicalObserverCode
  (O : FiniteProofObserverFamily α)
  (M : NeuralOperad σ)
  (ε : Rat)
  (B : ℕ) : Code
```

```lean
def decodeObserverCode : Code → NeuralOperad σ
```

Correctness theorem:

```lean
theorem canonical_observer_code_certified
  (O : FiniteProofObserverFamily α)
  (M : NeuralOperad σ)
  (ε : Rat)
  (B : ℕ)
  (hadm : ObserverAdmissible O)
  (hfin : FiniteSearchableModels σ B) :
  let c := canonicalObserverCode O M ε B
  observerDistortion O M (decodeObserverCode c) ≤ ε ∧
  codeLength c = operadicRateDistortion O M ε
```

If exact optimality is too difficult for the first implementation, prove:

```lean
theorem canonical_observer_code_certified_near_optimal ...
```

with a precise additive gap.

#### Why this matters
This is where the theory stops being philosophical and becomes executable mathematics. It produces certified semantic compression for compositional models.

---

## Most Promising Proof Architecture

You asked for 2–3 proof strategy steps; here are three serious pathways.

---

### Strategy A: finite-search argmin architecture
**Most promising for Lean implementation.**

1. **Bounded search space**
   Use `generatorCount ≤ B` and optional `depth ≤ D` to define a finite subtype of candidate models. If `NeuralOperad σ` is not globally finite, prove finiteness of the bounded subtype from the finite signature and finite generation assumptions.

2. **Distortion as finite counting functional**
   Realize `observerDistortion O M N` as a finite sum over observers in `O`, using decidable separator predicates. This makes all optimization problems computable over `Finset`.

3. **Duality by explicit correspondence**
   Define a finite type of prime-congruence certificates and prove a cost-preserving bijection:
   - model `N` with `d_O(M,N) ≤ ε`
   - ↔ spectral certificate `c` admissible at threshold `ε`.
   
   Then equality of minima follows by transport across the bijection.

**Why this is best:** Lean loves finite combinatorics, `Finset.argmin`, bounded subtypes, and decidable predicates. This route turns a profound theorem into a finite optimization equivalence, which is exactly where formalization is strongest.

---

### Strategy B: quotient-by-observer-equivalence and canonical representatives
**Conceptually cleaner, slightly more abstract.**

1. Define observer equivalence:
   \[
   M \sim_O N \iff d_O(M,N)=0.
   \]
   Show this is an equivalence relation.

2. Work on the quotient of models by observer equivalence. The rate–distortion problem becomes:
   choose the least-complexity representative inside the `ε`-ball around `[M]`.

3. Show prime-congruence certificates classify quotient classes under diagonal stability. Then the duality is an isomorphism between:
   - quotient classes with bounded complexity,
   - spectral certificate classes.

**Why it’s powerful:** It exposes the true semantics: coding is about equivalence classes, not raw models. This is mathematically elegant and future-proof for later categorical formulations.

---

### Strategy C: Galois connection / variational duality
**Most ambitious and field-opening, but may require more abstraction.**

1. Define a map from models to observer-visible spectral signatures, and a reconstruction map from spectral signatures to observer-stable model classes.

2. Prove a Galois connection or adjunction:
   - models induce spectral data,
   - spectral data determines minimal model complexity under observer constraints.

3. Deduce duality of minima as an order-theoretic consequence.

**Why it’s visionary:** If this works, you do not merely prove one finite theorem; you uncover an adjoint backbone for semantic compression. This could evolve into an operadic-Langlands-for-learning style program. But it may be too large for one cycle unless the catalog already contains the right abstractions.

---

## Concrete Build-on-Catalog Guidance

Use existing declarations as actual proof scaffolding, not decoration.

- If `SpectralSeparator` already certifies distinguishability, define observer distinction directly through it rather than inventing a new primitive.
- If `CodeEq` expresses code-level equivalence, use it to define zero-distortion / observer equivalence.
- If `DiagonalAvoidsOn` gives a stability condition against degeneracy or observer collision, use it as the exact hypothesis for triangle inequality and minimizer uniqueness/canonicity.
- If `generatorCount` and `depth` already exist, define complexity from them rather than introducing bespoke size notions.
- If `PrimeCongruenceNeuralCompression` has any lemmas relating spectral separators to compression or code extraction, those should become the left-to-right inequality in the duality theorem.
- If the catalog contains finite proof-observer families with decidable membership/evaluation, exploit `Fintype` / `Finset.univ` immediately.

You are not being asked to merely “connect” these areas rhetorically. You are being asked to prove that the catalog’s spectral and observer primitives already want to be a rate–distortion theory.

---

## Cross-Domain Connections You Should Make Explicit in the development

1. **Information Theory**
   - `operadicRateDistortion` is the semantic analogue of Shannon’s `R(D)`.
   - Finite observer families play the role of test channels / distortion observables.
   - Canonical minimizers are algebraic codebooks.

2. **Algebraic Geometry / Semiring Spectra**
   - Prime congruence spectra replace Euclidean latent coordinates.
   - `SpectralSeparator` acts like a geometric observable that cuts the model space into semantically relevant regions.
   - Duality says compression is controlled by spectral complexity.

3. **Operad Theory / Compositional ML**
   - `generatorCount` and `depth` are not arbitrary complexity measures; they are compositional resources.
   - Compression means reducing operadic presentation while preserving observer semantics.
   - This is architecture compression at the level of compositional algebra, not merely weight pruning.

4. **Logic / Proof Theory**
   - Observers are proof-level distinguishers.
   - Distortion is semantic disagreement over proofs/observations, not numerical output mismatch.
   - Canonical codes become proof-stable normal forms.

5. **Computational Complexity**
   - The finite-search theorem suggests a complexity theory of semantic compression.
   - Future work could classify when exact minimization is tractable, NP-hard, or fixed-parameter tractable in observer family size or depth.

6. **Statistical Mechanics / Renormalization**
   - Observer-relative compression resembles coarse-graining.
   - Prime-congruence certificates act like algebraic macrostates.
   - This suggests a future “renormalization by observer quotient” program for deep architectures.

---

## Formalization Priorities

1. First get a minimal but correct `observerDistortion`.
2. Prove the easy pseudometric lemmas.
3. Define bounded candidate spaces and prove finite attainment.
4. Only then define the prime-congruence functional carefully enough to prove the duality.
5. Finally extract the canonical code and prove correctness.

Do not try to start with the grand duality theorem if the bounded finite minimization lemmas are not in place.

---

## Suggested Lean file structure

A plausible decomposition:

- `OperadicDeepLearning/ObserverDistortion.lean`
  - `ObserverDistinguishes`
  - `observerDistortion`
  - pseudometric lemmas

- `OperadicDeepLearning/RateDistortion.lean`
  - `modelCodeLength`
  - `operadicRateDistortion`
  - finite minimizer existence

- `PrimeCongruenceNeuralCompression/RateDuality.lean`
  - prime-congruence certificates
  - `primeCongruenceRate`
  - duality theorem

- `PrimeCongruenceNeuralCompression/CanonicalObserverCode.lean`
  - code constructor
  - decoder
  - certified distortion theorem

If the repository structure differs, adapt, but keep the conceptual split.

---

## High-value intermediate lemmas

You will likely need some or all of these:

```lean
theorem observerDistortion_nonneg ...
theorem observerDistortion_le_one ...
theorem observerEquiv_iff_zeroDistortion ...
theorem bounded_model_search_finite ...
theorem exists_argmin_modelCodeLength_under_distortion ...
theorem spectral_certificate_of_model ...
theorem model_of_spectral_certificate ...
theorem spectral_certificate_cost_le_modelCodeLength ...
theorem modelCodeLength_le_spectral_certificate_cost ...
theorem canonical_minimizer_unique_under_tiebreak ...
```

If exact normalization by fractions becomes painful, prove everything first over natural counts of distinguishing observers:
`observerDisagreementCount : ℕ`,
then normalize later.

---

## What would count as a breakthrough here

A result counts as breakthrough-level if it proves an exact theorem of the form:

> For every finitely generated neural operad model and finite proof-observer family, the least operadic description complexity needed to preserve observer semantics up to distortion `ε` is exactly the least prime-congruence spectral certificate cost.

That is a new field statement. It would create:
- semantic compression theory for algebraic ML,
- a spectral notion of lossy coding,
- a proof-observer semantics for model equivalence,
- and a constructive route to certified compressed representations.

This is the sort of theorem that can seed an entire program of algebraic information theory.

---

## Deliverables

1. Formalized definitions and theorem statements in Lean 4.
2. Proofs of as many of the four theorems above as possible, prioritizing exact statements over vague generality.
3. Minimal sorry count, with each remaining sorry isolated behind a mathematically essential gap rather than a routine lemma.
4. A short note in comments identifying which assumptions are truly necessary versus proof artifacts.
5. **A structured `FUTURE_DIRECTIONS.md` with 3–5 concrete breakthrough next steps**, for example:
   - infinite-observer compactness / lower semicontinuity,
   - a Blahut–Arimoto-style algorithm for prime-congruence rate computation,
   - observer-quotient entropy and mutual information,
   - complexity classification of exact operadic compression,
   - categorical/Galois duality between model presentations and spectral observer codes.

---

## Application keywords

`rate-distortion`, `semantic compression`, `neural operads`, `prime congruence spectra`, `observer semantics`, `proof-theoretic ML`, `algebraic information theory`, `spectral certificates`, `canonical codes`, `formal verification`, `model compression`, `operadic complexity`, `finite optimization`, `semantic pseudometric`, `quotient geometry`

Make this feel inevitable in hindsight: as though prime congruence geometry had always been waiting to become the rate–distortion theory of compositional learning.

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
