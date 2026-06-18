## Assignment: Direction 1: Envelope Canonicalization and Exact Minimization

**Mode:** prove

Prove a genuinely new theorem establishing that the lower-envelope support of a tropical polynomial is not merely a language-preserving normalization, but the exact semantic core governing minimal weighted automaton realization over `ℕ`.

This direction has the right kind of explosiveness: it upgrades a syntactic pruning procedure into a **representation theorem**. If successful, it would connect tropical lower convex hull geometry, Myhill–Nerode-style minimality, and weighted automaton state complexity in a way that feels inevitable only after it exists.

---

## Research Direction

### Central Hypothesis
The **envelope-canonical form** — the subfamily of monomials that actually attain the pointwise minimum somewhere on `ℕ` — gives an exact characterization of semantically essential components, and therefore computes the true minimal state support for the corresponding weighted automaton / tropical series realization.

The point is subtle and important: `NatCanonical` removes pairwise dominated monomials, but that is only a first-order Pareto test. A monomial can survive Pareto pruning and still never lie on the lower envelope because it is globally hidden by a coalition of competitors. Proving exact minimization requires passing from domination to **envelope visibility**.

This is the tropical analogue of the passage from:
- local irredundancy to global extremality in polyhedral geometry,
- generating sets to circuits in matroid theory,
- syntactic minimization to semantic minimality in automata theory.

---

## Precise Theorem Targets

You should define and prove an exact package of results, ideally in a new file near the existing tropical/automata infrastructure.

### Core definition
Assuming a polynomial-like object `p` represented as a finite list / finset of monomials, define:

```lean
def EnvelopeEssential (p : List Monomial) (m : Monomial) : Prop :=
  m ∈ p ∧ ∃ n : ℕ, ∀ m' ∈ p, monoEval m n ≤ monoEval m' n

def EnvelopeCanonical (p : List Monomial) : List Monomial :=
  p.filter (fun m => ∃ n : ℕ, ∀ m' ∈ p, monoEval m n ≤ monoEval m' n)
```

If the catalog uses `Finset` rather than `List`, prefer the extensional version:

```lean
def EnvelopeEssential (p : Finset Monomial) (m : Monomial) : Prop :=
  m ∈ p ∧ ∃ n : ℕ, ∀ m' ∈ p, monoEval m n ≤ monoEval m' n

def EnvelopeCanonical (p : Finset Monomial) : Finset Monomial :=
  p.filter (fun m => ∃ n : ℕ, ∀ m' ∈ p, monoEval m n ≤ monoEval m' n)
```

Use whatever ambient type already exists in the catalog for tropical polynomials / affine monomials.

---

### Theorem 1: Envelope essentiality implies Pareto essentiality
This should be the entry theorem.

```lean
theorem envelopeCanonical_subset_natCanonical
  (p : Finset Monomial) :
  EnvelopeCanonical p ⊆ NatCanonical p
```

Or, elementwise:

```lean
theorem envelope_essential_implies_nat_essential
  {p : Finset Monomial} {m : Monomial}
  (h : EnvelopeEssential p m) :
  m ∈ NatCanonical p
```

### Exact mathematical statement
For every monomial `m` in `p`, if there exists `n : ℕ` such that `m` attains the minimum of `monoEval · n` over all monomials in `p`, then `m` is not pointwise dominated on `ℕ` by any competitor. Hence every envelope-visible monomial survives Pareto canonicalization.

This theorem is necessary but not sufficient; it is the doorway, not the destination.

---

### Theorem 2: Envelope canonicalization preserves semantics exactly
Let `polyEval p n := infᵢ monoEval mᵢ n` in the min-plus sense. Prove:

```lean
theorem envelopeCanonical_eval_eq
  (p : Finset Monomial) :
  ∀ n : ℕ, polyEval (EnvelopeCanonical p) n = polyEval p n
```

This is the semantic heart: deleting non-envelope monomials changes nothing because they never contribute to the minimum.

A list-based variant:

```lean
theorem eval_envelopeCanonical
  (p : List Monomial) :
  ∀ n : ℕ, polyEval (EnvelopeCanonical p) n = polyEval p n
```

### Exact mathematical statement
The lower-envelope support is a complete semantic support: every value of the tropical polynomial is realized by a monomial in `EnvelopeCanonical p`, and every monomial outside it is semantically silent.

---

### Theorem 3: Exact minimal-support characterization
This is the breakthrough theorem. Formulate it in the language already used by the weighted automaton development.

A generic form:

```lean
theorem envelopeCanonical_exact_minimal_support
  (p : Finset Monomial) :
  minimalStateCount (seriesOfPolynomial p) = (EnvelopeCanonical p).card
```

If the library has realizations rather than a direct `minimalStateCount`, use the strongest available replacement, e.g.

```lean
theorem envelopeCanonical_card_eq_minimal_states
  (p : Finset Monomial) :
  (EnvelopeCanonical p).card = minimalStatesOfSeries (polySeries p)
```

or a two-part theorem:

```lean
theorem envelopeCanonical_realizes
  (p : Finset Monomial) :
  RealizesWithStates (polySeries p) (EnvelopeCanonical p).card

theorem envelopeCanonical_minimal
  (p : Finset Monomial) :
  ∀ k < (EnvelopeCanonical p).card, ¬ RealizableWithStates (polySeries p) k
```

### Exact mathematical statement
The number of monomials that appear on the lower envelope is exactly the minimal number of states required to realize the associated tropical/weighted language. Not an upper bound. Not a pruning heuristic. An exact equality.

This is the theorem that opens a field.

---

### Theorem 4: Uniqueness-of-witness under slope separation
Your sketch suggests using distinct slopes. Make this precise as a structural theorem.

If monomials are affine functions `a*n + b`, define:

```lean
def distinctSlopes (p : Finset Monomial) : Prop :=
  ∀ {m₁ m₂}, m₁ ∈ p → m₂ ∈ p → slope m₁ = slope m₂ → m₁ = m₂
```

Then prove a sharpened witness theorem:

```lean
theorem envelope_essential_has_unique_minimizer
  {p : Finset Monomial}
  (hsep : distinctSlopes p)
  {m : Monomial}
  (hm : m ∈ EnvelopeCanonical p) :
  ∃ n : ℕ, ∀ m' ∈ p, m' ≠ m → monoEval m n < monoEval m' n
```

This strict version is powerful because it converts weak envelope visibility into a uniqueness witness, which is exactly the kind of object that can feed existing minimality theorems.

Be careful: this theorem may require a strengthened genericity hypothesis beyond distinct slopes alone, depending on intercept collisions and finite-domain pathologies. If distinct slopes is insufficient, refine the hypothesis to something like “pairwise distinct affine functions” or “no two monomials coincide on all witness points.”

A safer variant:

```lean
def pairwiseDistinctFunctions (p : Finset Monomial) : Prop :=
  ∀ {m₁ m₂}, m₁ ∈ p → m₂ ∈ p →
    (∀ n : ℕ, monoEval m₁ n = monoEval m₂ n) → m₁ = m₂
```

Then prove uniqueness at some witness point under an additional finite-exception argument.

---

## Lean 4 Formalization Targets

You should aim to expose the theorem in a form reusable by the automata/minimal-realization side of the library. That means proving both:
1. **pointwise evaluation equalities**, and
2. **cardinality/minimal-state equalities**.

A strong target API would include:

```lean
def EnvelopeEssential ...
def EnvelopeCanonical ...

theorem mem_EnvelopeCanonical_iff ...
theorem envelopeCanonical_subset_natCanonical ...
theorem eval_EnvelopeCanonical_eq_eval ...
theorem not_mem_EnvelopeCanonical_iff_never_minimizes ...
theorem envelopeCanonical_card_le_natCanonical_card ...
theorem envelope_unique_witness_of_separated ...
theorem envelopeCanonical_exact_minimal_support ...
```

If there is already a theorem relating unique realizers to minimality, the bridge theorem should explicitly route through it.

---

## How to Build on Existing Verified Theorems

### 1. `canonical_minimal_skeleton_unique`
**File:** `Bridges/AlgebraMachineLearning/OperadicTropicalization.lean`

Use this as a uniqueness/normal-form paradigm. The lesson is not the exact object but the certified mechanism:
- identify a canonical semantic skeleton,
- prove semantic invariance,
- prove uniqueness of that skeleton under suitable equivalence.

Your envelope-canonical form should be treated as the lower-envelope skeleton of the tropical series. If possible, derive a theorem of the form:
```lean
EnvelopeCanonical p = EnvelopeCanonical q ↔ polyEval p = polyEval q
```
under a suitable canonicality hypothesis. Even if full iff is too ambitious, a one-way uniqueness theorem would be significant.

### 2. `realizes_unique_implies_minimal`
**File:** `Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean`

This is likely the most promising bridge to the exact minimal-state theorem.
The strategic idea:
- prove every `m ∈ EnvelopeCanonical p` has a witness input `n` where it is the unique minimizer,
- package those witnesses into a “uniquely realized behavior” certificate,
- invoke `realizes_unique_implies_minimal` to conclude minimality.

This theorem may be the shortest path from geometric visibility to automata minimality.

### 3. `essential_not_dominated`
**File:** `Bridges/AlgebraTropicalMachineLearning/TropicalAttentionRealizationDuality.lean`

This is a conceptual cousin of your first theorem. Study how “essential” is encoded there and mirror the proof architecture:
- witness essentiality,
- derive non-domination,
- conclude irredundancy.

If the theorem is abstract enough, instantiate it directly; otherwise, port its proof pattern.

### 4. `hankel_distinct_rows_eq_minimal_states`
**File:** `Bridges/AlgebraTropicalRepresentationTheory/TropicalHeckeCrystalDuality.lean`

This suggests a second route to exact minimality:
- show each envelope monomial induces a distinct row in the Hankel-like semantics,
- prove non-envelope monomials induce no new rows,
- apply the theorem equating distinct semantic rows with minimal states.

This route is more algebraic and may yield the strongest conceptual result.

### 5. `minimal_states_bound`
**File:** `Bridges/EMLComputation/ClosureKolmogorovRealization.lean`

Use this as a sanity-check upper/lower bound tool while assembling the exact equality:
- upper bound via realization by envelope support,
- lower bound via unique witnesses or distinct rows,
- collapse bounds to equality.

---

## Proof Strategy Architecture

## Strategy A: Direct lower-envelope semantics → exact support
**Most geometric, probably best for semantic preservation**

1. Define `EnvelopeCanonical` and prove:
   ```lean
   m ∉ EnvelopeCanonical p ↔ ∀ n, ∃ m' ∈ p, monoEval m' n < monoEval m n
   ```
   or at least the weak non-attainment form.

2. Show deleting a non-envelope monomial preserves `polyEval`.
   Then iterate deletion over all non-envelope monomials to get:
   ```lean
   polyEval (EnvelopeCanonical p) = polyEval p
   ```

3. Prove every envelope monomial is semantically indispensable by choosing a witness `n` where it attains the minimum, and under separation assumptions, attains it uniquely. Then derive exact minimality.

**Why promising:** this is the cleanest route to a canonical semantic support theorem, independent of any specific automaton encoding.

---

## Strategy B: Unique-witness realization → minimal states
**Most likely shortest path to the flagship theorem**

1. For each `m ∈ EnvelopeCanonical p`, produce a witness `n_m` such that `m` is the unique minimizer at `n_m` under suitable separation assumptions.

2. Build a realization certificate saying the family of envelope monomials is uniquely observable / uniquely realizable.

3. Apply `realizes_unique_implies_minimal` to conclude:
   ```lean
   minimalStateCount (seriesOfPolynomial p) = (EnvelopeCanonical p).card
   ```

**Why promising:** it directly leverages an existing theorem with exactly the right flavor. If the witness theorem goes through, this route could be surprisingly short.

---

## Strategy C: Hankel row separation / tropical Myhill–Nerode
**Most revolutionary, potentially strongest final statement**

1. Associate to each monomial `m` the semantic row/function it induces in the weighted Hankel matrix.

2. Prove:
   - envelope monomials induce pairwise distinct rows,
   - non-envelope monomials induce no extremal row not already represented by the envelope.

3. Invoke `hankel_distinct_rows_eq_minimal_states` to identify envelope cardinality with minimal state count.

**Why promising:** this reframes envelope-canonicalization as a tropical Myhill–Nerode theorem. If formalized, it opens a reusable theory of semantic extremals for weighted automata far beyond this one problem.

**Recommendation:** pursue Strategy B first for a fast exact theorem, while designing the definitions so Strategy C can later generalize the result.

---

## Cross-Domain Connections

This is not “just” tropical simplification. It is a nexus theorem.

### 1. Polyhedral / tropical geometry
`EnvelopeCanonical` is the discrete lower-envelope support, analogous to vertices on the lower convex hull of affine forms. Proving exact minimality says:
> automaton state complexity is a polyhedral extremal invariant.

That is a startling bridge: minimal realization becomes visible as lower-hull combinatorics.

### 2. Automata theory / Myhill–Nerode
Classical minimization counts distinct residual languages. Here the envelope monomials play the role of tropical residual extremals. This suggests a tropical Myhill–Nerode theory where equivalence classes are replaced by lower-envelope regions or extremal Hankel rows.

### 3. Optimization / operations research
Envelope support is exactly the set of active constraints in a parametric linear optimization problem. Your theorem would say:
> active constraints of the tropical value function are precisely the minimal memory states of the semantic machine.

This could export automata methods into parametric shortest-path and control settings.

### 4. Machine learning / mixture-of-experts / attention
A monomial that never wins the minimum is like an expert that is never selected by a hard gating mechanism. Proving exact envelope minimality formalizes when a component is semantically dead even if not pairwise dominated. This has direct analogies to pruning latent experts, tropical attention heads, and min-plus inference circuits.

### 5. Representation theory / persistence
The existing catalog already hints that minimality and uniqueness principles recur in persistence and Hecke/crystal contexts. Envelope-canonicalization may be the common extremal mechanism behind all of them.

---

## Why This Would Be a Breakthrough

If you prove the exact minimal-support theorem, you have not merely improved a canonicalization routine. You have shown that a tropical semantic object carries its own minimal automaton directly in its lower envelope.

That would mean:
- exact minimization can be computed geometrically,
- semantic redundancy is characterized by envelope invisibility,
- minimal weighted automata can be read off from tropical convex structure.

This is the kind of theorem that generates a new vocabulary:
**envelope semantics**, **tropical extremal states**, **lower-hull realization theory**.

It would immediately suggest generalizations to:
- multivariate tropical series,
- min-plus rational functions,
- weighted transducers,
- tropical neural architectures,
- persistence/barcode realization,
- tropical Hankel factorization.

---

## Technical Cautions

1. **Unique minimizer may fail without genericity.**
   Weak envelope visibility only gives `≤`, not strict `<`. If strict uniqueness is false in general, do not force it. Instead:
   - prove weak envelope visibility unconditionally,
   - prove strict uniqueness under a clean separation hypothesis.

2. **List vs Finset duplicates.**
   If monomial multiplicity is irrelevant semantically, prefer `Finset` or quotient away duplicates. Otherwise exact cardinality theorems may become false for syntactic reasons.

3. **Domain `ℕ` may be too rigid for some envelope arguments.**
   If a witness exists over `ℤ` or `ℚ` but not obviously over `ℕ`, prove the theorem carefully in the discrete setting actually used by the semantics. Do not silently import continuous convexity arguments.

4. **Lower bounds need semantic distinguishability.**
   Exact minimal-state equality requires not just irredundancy but a theorem that distinct envelope monomials force distinct semantic behaviors. This is where the unique witness or Hankel route matters.

---

## Concrete Deliverables

1. Define `EnvelopeEssential` and `EnvelopeCanonical`.
2. Prove semantic preservation:
   ```lean
   polyEval (EnvelopeCanonical p) = polyEval p
   ```
3. Prove inclusion:
   ```lean
   EnvelopeCanonical p ⊆ NatCanonical p
   ```
4. Prove a strict witness theorem under genericity/separation.
5. Prove the flagship exact equality between envelope support cardinality and minimal state count.
6. Minimize sorry aggressively, especially in the bridge from witness uniqueness to minimality.

---

## Application Keywords
tropical geometry, weighted automata, min-plus algebra, Myhill–Nerode, Hankel rank, canonicalization, lower envelope, convex hull, semantic pruning, exact minimization, realizability, state complexity, tropical machine learning, mixture-of-experts pruning, parametric optimization, persistence realization

---

## Request for FUTURE_DIRECTIONS.md

After completing the theorem(s), you must produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, each with:
- a precise conjecture or theorem statement,
- why it is nontrivial,
- what existing theorem from this cycle it builds on,
- what new field-level connection it opens.

Strong candidate next directions include:
1. multivariate envelope-canonicalization and Newton polytope faces,
2. tropical Myhill–Nerode equivalence via envelope regions,
3. Hankel-rank = lower-envelope cardinality theorems,
4. envelope minimality for weighted transducers / rational series,
5. tropical pruning theory for attention or min-plus neural circuits.

Do not treat this as optional. The point of this cycle is to found a program, not merely solve a lemma.

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

**Team Directive**: Create a team to conduct research, brainstorm hypotheses,
run experiments, validate data, update knowledge base and iterate forever.
Each future direction should be specific enough for a team to pick up and
pursue with clear hypotheses, proof strategies, and cross-domain connections.

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
