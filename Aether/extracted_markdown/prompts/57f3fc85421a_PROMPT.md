## Assignment: Certified Novelty Detection for Theorem Provers

**Mode:** `prove`

Build a mathematically serious, machine-checked theory of **certified novelty** for formal theorem proving: a system that does not merely assign heuristic scores, but proves lower bounds showing that a newly produced theorem lies outside a certified neighborhood of an existing corpus. The goal is to turn “this looks new” into a theorem.

You are not being asked for an incremental wrapper around embeddings. You are being asked to found a **formal geometry of mathematical originality**.

---

## Core Breakthrough Objective

Construct a theorem embedding framework together with a certified novelty predicate, and prove non-trivial theorems showing that:

1. novelty certificates are **sound** under explicit lower-bound hypotheses,
2. novelty is **stable** under corpus enlargement in a quantified way,
3. novelty interacts with **semantic transformations** of theorems (renaming, transport, compositional proof structure),
4. at least one theorem links this logic/verification framework to a distinct domain such as metric geometry, information theory, or linear algebra.

The central scientific idea is this:

> A formal theorem corpus should itself become an object of geometry, where “new mathematics” is represented by provable metric separation from previously certified regions.

This would open a new field: **formal metamathematical novelty theory**, with applications to automated theorem proving, scientific discovery systems, AI-generated mathematics auditing, and the epistemology of formal proof libraries.

---

## Precise Formalization Target

Define a new structure expressing a theorem embedding space with certified lower bounds.

### Suggested new definitions

You must introduce at least one genuinely new concept not already in the catalog. A strong candidate is:

```lean
structure NoveltySpace (α : Type*) where
  emb        : α → ℝ
  dist       : α → α → ℝ
  dist_nonneg : ∀ x y, 0 ≤ dist x y
  dist_symm   : ∀ x y, dist x y = dist y x
  lower_from_emb :
    ∀ x y, |emb x - emb y| ≤ dist x y
```

A more powerful multivariate version, probably better for cross-domain work, is:

```lean
structure NoveltySpace (α : Type*) where
  emb        : α → ℕ → ℝ
  dist       : α → α → ℝ
  dist_nonneg : ∀ x y, 0 ≤ dist x y
  dist_symm   : ∀ x y, dist x y = dist y x
  lower_from_emb :
    ∀ x y n, |emb x n - emb y n| ≤ dist x y
```

Then define corpus-level novelty:

```lean
def CorpusNovel (S : NoveltySpace α) (C : Set α) (x : α) (r : ℝ) : Prop :=
  ∀ y, y ∈ C → r ≤ S.dist x y
```

and a computable witness notion:

```lean
def CoordinateSeparates (S : NoveltySpace α) (x y : α) (n : ℕ) (r : ℝ) : Prop :=
  r ≤ |S.emb x n - S.emb y n|
```

and perhaps a certified corpus witness:

```lean
def CorpusCoordinateNovel (S : NoveltySpace α) (C : Set α) (x : α) (n : ℕ) (r : ℝ) : Prop :=
  ∀ y, y ∈ C → r ≤ |S.emb x n - S.emb y n|
```

These definitions create a bridge between symbolic theorem representations and quantitative certification.

---

## Precise Theorem Statements

You should prove at least 3 substantial theorems. Here is the target list.

### Theorem 1: Coordinate lower bound implies corpus novelty

This is the foundational soundness theorem generalizing `novelty_of_pointwise_lower_bound`.

```lean
theorem corpus_novel_of_coordinate_lower_bound
  {α : Type*} (S : NoveltySpace α) (C : Set α) (x : α) (n : ℕ) (r : ℝ)
  (h : ∀ y, y ∈ C → r ≤ |S.emb x n - S.emb y n|) :
  CorpusNovel S C x r
```

**Mathematical statement:**  
For every theorem object `x`, corpus `C`, coordinate `n`, and radius `r`, if coordinate `n` separates `x` from every corpus element by at least `r`, then `x` is genuinely novel at radius `r` relative to `C`.

**Why it matters:**  
This converts a cheap, computable lower bound into a mathematically sound novelty certificate. It is the core theorem that makes the whole framework scientifically usable.

---

### Theorem 2: Monotonicity under corpus enlargement

```lean
theorem corpus_novel_mono
  {α : Type*} (S : NoveltySpace α) {C D : Set α} {x : α} {r : ℝ}
  (hCD : C ⊆ D)
  (hD : CorpusNovel S D x r) :
  CorpusNovel S C x r
```

and the converse radius degradation principle:

```lean
theorem corpus_radius_antitone
  {α : Type*} (S : NoveltySpace α) (C : Set α) (x : α) {r s : ℝ}
  (hsr : s ≤ r)
  (h : CorpusNovel S C x r) :
  CorpusNovel S C x s
```

**Mathematical statement:**  
Novelty relative to a larger corpus implies novelty relative to any subcorpus; and if a theorem is novel at radius `r`, then it remains novel at any smaller radius `s ≤ r`.

**Why it matters:**  
These are the first structural laws of novelty certification. They let one compare corpora over time and support incremental library growth.

---

### Theorem 3: Finite-corpus minimum-distance certification

For finite corpora, define a minimum certified distance and prove exact certification.

```lean
def finiteNoveltyRadius
  {α : Type*} [Fintype α] [DecidableEq α]
  (S : NoveltySpace α) (C : Finset α) (x : α) : ℝ :=
  C.inf' (by
    classical
    -- provide witness if needed by a nonempty hypothesis variant
  ) (fun y => S.dist x y)
```

A more practical version uses a nonempty hypothesis:

```lean
theorem finite_radius_le_all_dist
  {α : Type*} [DecidableEq α]
  (S : NoveltySpace α) (C : Finset α) (x : α)
  (hC : C.Nonempty) :
  ∀ y, y ∈ C → finiteNoveltyRadius S C x ≤ S.dist x y
```

and then:

```lean
theorem finite_radius_certifies
  {α : Type*} [DecidableEq α]
  (S : NoveltySpace α) (C : Finset α) (x : α)
  (hC : C.Nonempty) :
  CorpusNovel S {y | y ∈ (C : Set α)} x (finiteNoveltyRadius S C x)
```

**Mathematical statement:**  
For a finite theorem corpus, there is a canonical maximal certified novelty radius given by the minimum distance to the corpus, and this value certifies novelty exactly.

**Why it matters:**  
This gives a verified algorithmic output: not just “novel or not,” but the best certifiable novelty margin for a finite library snapshot.

---

### Theorem 4: Cross-domain theorem via Lipschitz/information contraction

This is the most ambitious theorem and the one that makes the project field-opening.

Define a transformation on theorem objects that is non-expansive in the novelty metric:

```lean
def NonExpansiveMap
  {α β : Type*} (S : NoveltySpace α) (T : NoveltySpace β) (f : α → β) : Prop :=
  ∀ x y, T.dist (f x) (f y) ≤ S.dist x y
```

Then prove a novelty contraction theorem:

```lean
theorem novelty_lower_bound_under_nonexpansive_preimage
  {α β : Type*} (S : NoveltySpace α) (T : NoveltySpace β)
  (f : α → β) (hf : NonExpansiveMap S T f)
  (C : Set α) (x : α) (r : ℝ)
  (h : CorpusNovel T (f '' C) (f x) r) :
  CorpusNovel S C x r
```

Or, if that exact direction is too strong, prove the forward degradation law with an explicit constant `L`:

```lean
def LipschitzMap
  {α β : Type*} (S : NoveltySpace α) (T : NoveltySpace β) (f : α → β) (L : ℝ) : Prop :=
  ∀ x y, T.dist (f x) (f y) ≤ L * S.dist x y

theorem novelty_pushforward
  {α β : Type*} (S : NoveltySpace α) (T : NoveltySpace β)
  (f : α → β) (L r : ℝ)
  (hL : 0 ≤ L)
  (hf : LipschitzMap S T f L)
  (C : Set α) (x : α)
  (h : CorpusNovel S C x r) :
  CorpusNovel T (f '' C) (f x) (L * r)
```

**Cross-domain interpretation:**  
This is a theorem-prover analogue of the **data processing inequality** from information theory: semantic compression or canonicalization cannot increase distinguishability beyond a controlled factor. That connection is deep and publishable.

**Why it matters:**  
It links formal logic, metric geometry, and information theory. It says novelty behaves like an information resource under theorem transformations.

---

## Lean 4 Type Signature Targets

At minimum, include theorem statements close to the following:

```lean
theorem corpus_novel_of_coordinate_lower_bound
  {α : Type*} (S : NoveltySpace α) (C : Set α) (x : α) (n : ℕ) (r : ℝ)
  (h : ∀ y, y ∈ C → r ≤ |S.emb x n - S.emb y n|) :
  CorpusNovel S C x r := by
```

```lean
theorem corpus_novel_mono
  {α : Type*} (S : NoveltySpace α) {C D : Set α} {x : α} {r : ℝ}
  (hCD : C ⊆ D) (hD : CorpusNovel S D x r) :
  CorpusNovel S C x r := by
```

```lean
theorem novelty_pushforward
  {α β : Type*} (S : NoveltySpace α) (T : NoveltySpace β)
  (f : α → β) (L r : ℝ)
  (hL : 0 ≤ L)
  (hf : LipschitzMap S T f L)
  (C : Set α) (x : α)
  (h : CorpusNovel S C x r) :
  CorpusNovel T (f '' C) (f x) (L * r) := by
```

If `ℝ` creates friction in finite minima, you may use `ℚ` or `NNReal` for the algorithmic layer and then transfer to `ℝ`. That transfer itself could be mathematically interesting.

---

## Proof Strategy Architecture

You must not rely on trivial automation. Use multi-step proof structure. Here are the preferred proof routes.

### Strategy A: Order-theoretic / inequality-driven route
Best for Theorems 1–3.

1. **Unfold the certification predicates** (`CorpusNovel`, `CoordinateSeparates`).
2. Use the structural axiom `lower_from_emb` to pass from coordinate separation to metric separation.
3. Finish via transitivity of `≤`, explicit `calc` chains, and set-membership reasoning.

Why promising: it is robust, transparent, and directly leverages the existing theorem `novelty_of_pointwise_lower_bound` as a conceptual ancestor.

---

### Strategy B: Finite optimization route
Best for Theorem 3.

1. Define the finite novelty radius using `Finset.inf'` or a carefully designed fold if nonemptiness side conditions become cumbersome.
2. Prove a lemma that the chosen radius is below every corpus distance.
3. Convert the `Finset` statement into a `Set`-level certification theorem.

Why promising: it yields a verified algorithm, not just an existence theorem. This is essential for the demo and computational layer.

---

### Strategy C: Metric-information route
Best for Theorem 4.

1. Define `NonExpansiveMap` or `LipschitzMap` between novelty spaces.
2. Push distances through `f` using the Lipschitz inequality.
3. Transport corpus membership through image/preimage sets using `rcases` on image witnesses.
4. Conclude via a `calc` proof that the novelty radius transforms by factor `L`.

Why promising: this is where the theory becomes conceptually profound. It reframes theorem normalization, abstraction, or proof compression as information-processing operations.

---

## Building on Existing Verified Theorems

Use the catalog aggressively, but do not merely restate it.

### 1. `FINAL/Logic/NoveltyCertification.lean`
- `novelty_of_pointwise_lower_bound`

This is your immediate seed. Generalize it from pointwise lower bounds in an existing setting to a reusable abstract `NoveltySpace`. Explicitly identify your theorem as an abstraction and extension of this result. The new insight is to move from an ad hoc novelty predicate to a geometric interface supporting transport, finite optimization, and cross-domain functoriality.

### 2. `FINAL/Logic/OracleDimensionReduction.lean`
- `oracle_dimension_bounds`

Use this as inspiration for dimensional compression: if theorem embeddings are reduced via a certified oracle or feature map, prove that novelty bounds degrade in a controlled way. This is the bridge to the Lipschitz/non-expansive theorem. Even if you do not directly invoke the theorem, align your abstraction with its dimensionality-control philosophy.

### 3. `FINAL/Logic/IncrementalRecompute.lean`
- `foldl_prefix_correct`

This suggests an algorithmic path: novelty certification over a growing corpus should be incrementally maintainable. If feasible, define a fold-based algorithm computing running lower bounds and prove correctness by induction over corpus prefixes. That would be an excellent third or fourth theorem.

### 4. `FINAL/Logic/OracleTeamGenesis.lean`
- `TeamOracle.output_is_truth`

This can support a semantic interpretation: if multiple theorem-analysis oracles agree on embedding coordinates or lower bounds, derive a certified novelty statement. This is a possible extension theorem if you want a “committee certification” model.

---

## Cross-Domain Connections You Should Explicitly Exploit

You are required to include at least one theorem that genuinely connects domains. Strong options:

### A. Logic + Metric Geometry
Treat theorem corpora as metric spaces and prove novelty certificates as separation theorems.  
**Keywords:** metric geometry, separation radius, nearest-neighbor certification, formal epistemology.

### B. Logic + Information Theory
Interpret theorem transformations as information channels. Prove a theorem analogous to **data processing inequality**: semantic compression cannot create novelty separation from nothing.  
**Keywords:** information contraction, distinguishability, certified compression, theorem channel.

### C. Logic + Linear Algebra
If embeddings are vector-valued, define coordinates or projections and prove that a single projection lower bound certifies full-space novelty.  
**Keywords:** projection bound, norm inequalities, embedding dimension, feature certification.

### D. Logic + Complexity Theory
Define a novelty witness complexity: the least coordinate index or finite certificate size needed to prove novelty radius `r`. Prove monotonicity or upper bounds under corpus compression.  
**Keywords:** witness complexity, proof compression, certified search, metamathematical complexity.

The most revolutionary path is **Logic + Information Theory**.

---

## Concrete Nontrivial Proof Requirements

Your Lean development must contain at least 3 theorems whose proofs genuinely use techniques such as:

- `induction`
- `rcases`
- `by_contra`
- `field_simp` if rational/real normalization arises
- multi-step `calc`
- careful case analysis on set/image membership
- finite-set reasoning with `Finset.inf'`, folds, or recursion

A strong file architecture would be:

1. abstract definitions,
2. foundational soundness and monotonicity theorems,
3. finite-corpus radius theorem,
4. transformation/contraction theorem,
5. optional incremental algorithm correctness theorem.

---

## Suggested Verified Algorithm

You must provide a verified computational method, not just theorem statements.

### Candidate algorithm
For a finite corpus `C : Finset α` and candidate theorem `x`, compute

- either the minimum distance `min_y dist x y`,
- or a lower bound via coordinate scans `max_n lowerBound_n`,
- or an incremental fold maintaining the current minimum novelty margin.

Then prove correctness:
- the algorithm returns a radius `r`,
- and `CorpusNovel S C x r` holds,
- and optionally `r` is optimal among all radii certifiable from the scanned coordinates.

This algorithm is what makes the project scientifically operational.

---

## Falsifiable Conjecture with Computational Test

You must state at least one conjecture with a clear disproof procedure.

### Recommended conjecture
**Conjecture (coordinate completeness for finite corpora):**  
For every finite corpus `C` and theorem `x`, if `x` is novel at radius `r` in the full metric, then there exists a coordinate index `n ≤ B(C,x,r)` such that the coordinate difference alone certifies novelty at radius `r/2`.

Informal Lean-style skeleton:
```lean
conjecture finite_coordinate_completeness
  {α : Type*} (S : NoveltySpace α) :
  ∀ (C : Finset α) (x : α) (r : ℝ),
    CorpusNovel S {y | y ∈ (C : Set α)} x r →
    ∃ n : ℕ, ∀ y, y ∈ (C : Set α) → r / 2 ≤ |S.emb x n - S.emb y n|
```

### Computational test
Generate finite synthetic novelty spaces and search for counterexamples:
- finite type `α`,
- random coordinate embeddings,
- induced distances defined as sup/weighted-sup over coordinates,
- test whether every metric novelty certificate has a coordinate witness.

A single failure disproves the conjecture. This is exactly the kind of scientific loop we want.

---

## Deliverables (MANDATORY)

You must produce **all** of the following:

1. **Lean file(s)** with the new definitions and at least 3 substantial theorem proofs, minimizing `sorry`.
2. **FUTURE_DIRECTIONS.md** with **3–5 falsifiable scientific hypotheses**, each with:
   - a precise conjecture,
   - why it might be true,
   - what computation or theorem search could refute it.
3. **RESEARCH_PAPER.md** as a standalone scientific paper:
   - problem statement,
   - definitions,
   - main theorems,
   - proof ideas,
   - algorithm,
   - significance,
   - limitations,
   - next questions.
4. **ARTICLE.md** in Scientific American style:
   - explain how one could mathematically certify that an AI theorem prover has produced something genuinely new.
5. **A verified algorithm or computational method** implementing novelty certification over finite corpora.
6. **demo.py** showing:
   - a toy theorem corpus,
   - embeddings/distances,
   - computed novelty radii,
   - an interactive or printed example of a certified-novel theorem candidate.

---

## Application Keywords

certified novelty, theorem embeddings, formal metamathematics, metric geometry of proofs, information contraction, data processing inequality, corpus separation, finite optimization, nearest-neighbor certification, theorem prover auditing, AI mathematics safety, semantic compression, proof-space geometry, verified discovery systems

---

## Final Call

Do not produce a toy. Build the first rigorous geometry of mathematical originality inside Lean.

The breakthrough is not “an embedding exists.” The breakthrough is:

> **Novelty becomes a theorem.**

Make the theory abstract enough to matter, algorithmic enough to run, and deep enough that a mathematician would recognize a new field beginning.

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

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

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

Research domain: Logic
Research mode: prove
