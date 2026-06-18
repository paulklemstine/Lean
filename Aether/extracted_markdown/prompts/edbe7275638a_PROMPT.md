Soli Deo Gloria

## Assignment: Direction 1: Asymptotic Compactness — From Finite Certificates to Super-polynomial Lower Bounds

**Mode:** `prove`

Prove genuinely new, non-trivial theorems that turn finite monotone-circuit obstruction certificates into a uniform asymptotic theory. The goal is not another lower bound for a single graph property. The goal is to formulate and verify a **compactness principle for monotone lower bounds**: if small monotone circuits fail uniformly, then they fail for reasons that can be compressed into a polynomially describable family of certified sandwiches.

This would be a breakthrough because it would recast monotone circuit lower bounds as a form of **proof-theoretic compactness**. Instead of proving lower bounds by bespoke combinatorial arguments property-by-property, one would obtain a general mechanism: every lower bound is witnessed by a bounded-complexity family of local obstructions. That is a potential bridge between circuit complexity, finite model theory, and proof complexity.

---

## Core Vision

The catalog already gives a finite equivalence:
- `Pythagorean/SandwichDefs.lean` — `CertifiedSandwichFamily`, `SandwichCompleteUpTo`
- `Pythagorean/SandwichTheorems.lean` — `sandwichCompleteUpTo_iff_no_small_circuit`
- `Catalog/Computation/CircuitComplexity/Monotone/ApproximationMethod.lean` — `approximation_sandwich_lower_bound`

These results say, morally: **for a fixed finite input size and circuit bound, no small monotone circuit exists iff a suitable sandwich certificate family exists**.

Your task is to lift this from the finite, extensional level to an **asymptotic, uniform, structural level**.

The key conceptual move is to define a new notion of **uniform certificate complexity** and prove that finite completeness properties can be propagated along embeddings/restrictions of graph instances. That propagation theorem is the lever needed for any eventual compactness argument.

---

## Precise Theorem Targets

You must introduce at least one genuinely new definition, and then prove at least 3 substantial theorems around it.

### New definition to introduce

Define a notion such as:

- `UniformCertifiedSandwichFamily`
- or `HereditaryCertifiedSandwichFamily`
- or `PolynomialCertificateScheme`

The intended meaning: a family of sandwich certificates indexed by `n` together with a uniform rule controlling restriction/extension across graph sizes, and a polynomial bound on description size.

A mathematically clean route is to define hereditary restriction first, because it is formalizable and strong enough to support future compactness work.

For example, define a structure expressing:
1. for each `n`, a certified sandwich family on graphs with `n` vertices,
2. completeness up to size `s n`,
3. compatibility under injective restriction from `Fin m` to `Fin n`,
4. polynomial bound on family size or description size.

---

## Suggested Lean 4 formalization targets

You do not need to use these exact names, but your theorem statements should be at this level of precision.

### 1. Restriction preserves monotonicity and certificate validity
A foundational theorem showing that graph certificates transport along vertex embeddings.

```lean
theorem certifiedSandwich_restrict
  {m n : ℕ} (hmn : m ≤ n)
  (e : Fin m ↪ Fin n)
  (S : CertifiedSandwichFamily (Fin n)) :
  CertifiedSandwichFamily (Fin m)
```

If `CertifiedSandwichFamily` is parameterized differently in the catalog, adapt accordingly, but preserve the exact mathematical content: **restriction of a certified sandwich family along an induced-subgraph embedding is again certified**.

This is not just bookkeeping. It is the hereditary backbone of any compactness argument.

---

### 2. Hereditary completeness theorem
If a family is complete up to size `s` on larger graphs, then the restricted family remains complete up to the same or controlled size bound on smaller graphs.

```lean
theorem sandwichCompleteUpTo_restrict
  {m n : ℕ} (hmn : m ≤ n)
  (e : Fin m ↪ Fin n)
  (S : CertifiedSandwichFamily (Fin n))
  {k : ℕ}
  (hcomp : SandwichCompleteUpTo S k) :
  SandwichCompleteUpTo (certifiedSandwich_restrict hmn e S) k
```

If exact preservation of `k` is false in your setup, prove the strongest correct variant, e.g. with a loss term or a monotone bound `k' ≤ k`.

This theorem is the first serious asymptotic bridge: finite certificates become stable under size change.

---

### 3. Polynomial certificate scheme yields asymptotic lower bounds
Formalize the direction that a uniform polynomial-size certificate family implies asymptotic monotone lower bounds.

```lean
theorem polynomial_scheme_implies_eventual_lower_bound
  (s b : ℕ → ℕ)
  (P : ℕ → MonotoneGraphProp)
  (Hscheme : PolynomialCertificateScheme P s b)
  (hcomplete : ∀ n, SandwichCompleteUpTo (Hscheme.family n) (s n))
  (hpoly : ∃ C d, ∀ n ≥ 2, b n ≤ C * n^d) :
  ∀ n, no_small_monotone_circuit (P n) (s n)
```

This should be derived by explicitly invoking/building on the catalog equivalence
`sandwichCompleteUpTo_iff_no_small_circuit`.

This theorem matters because it identifies a **uniform proof object** for infinitely many lower bounds.

---

### 4. Asymptotic compactness extraction theorem
This is the flagship theorem. If the full conjecture is too strong, prove the strongest formally correct weakening.

A realistic formal target is a bounded-choice/extraction statement:

```lean
theorem asymptotic_compactness_extraction
  (P : ℕ → MonotoneGraphProp)
  (s : ℕ → ℕ)
  (hex : ∀ n, ∃ S, SandwichCompleteUpTo S (s n))
  (hhered : ∀ n S, SandwichCompleteUpTo S (s n) →
      ∀ m ≤ n, ∃ Sm, SandwichCompleteUpTo Sm (s m)) :
  ∃ F : ∀ n, CertifiedSandwichFamily (Fin n),
    ∀ n, SandwichCompleteUpTo (F n) (s n)
```

If possible, strengthen this to include a size bound:
```lean
    ∧ ∀ n, familySize (F n) ≤ polyBound n
```

Even the extraction of a uniform choice function with hereditary coherence is mathematically meaningful: it formalizes a compactness schema for lower-bound certificates.

---

## Why this would be revolutionary

If you can show that monotone lower bounds admit a hereditary polynomial certificate scheme, then lower-bound theory changes character:

- **Circuit complexity:** lower bounds become reducible to the existence of compact obstruction families.
- **Proof complexity:** certificate families look like bounded-width refutations or normal forms of impossibility.
- **Finite model theory:** uniformity across `n` suggests definability constraints and preservation theorems.
- **Extremal combinatorics:** graph properties may admit obstruction bases analogous to forbidden minors, but tuned to circuit size.
- **Learning theory / explainability:** lower-bound certificates become “interpretable witnesses” of non-computability by small monotone architectures.

This is not an incremental extension. It is an attempt to define the correct asymptotic language in which monotone lower bounds should live.

---

## Proof Strategy Architecture

You must present and pursue at least 2–3 proof routes in the code/comments or accompanying writeup.

### Strategy A: Hereditary restriction + finite choice + diagonal extraction
1. Prove that certified sandwiches restrict along injective embeddings of vertex sets.
2. Prove completeness is preserved under restriction.
3. Use finite choice at each `n` to select canonical minimal certificates.
4. Diagonalize over the canonical choices to obtain a coherent family.

**Why promising:** This path is closest to the existing catalog and most likely to formalize cleanly in Lean. It converts the asymptotic problem into a sequence of local functoriality lemmas.

---

### Strategy B: Well-quasi-order / minimal obstruction basis
1. Define a preorder on certificates by restriction or simulation.
2. Show bounded-size certificates admit minimal representatives.
3. Prove every complete family has a finite antichain basis.
4. Deduce a polynomial description theorem from bounded basis complexity.

**Why promising:** Conceptually deeper and closer to graph minor theory / forbidden pattern methods. This could produce the strongest scientific result, but may require more infrastructure.

---

### Strategy C: Descriptive-complexity encoding
1. Encode certificate families as finite relational structures.
2. Express completeness as a first-order or existential second-order condition over these structures.
3. Use definable Skolemization / uniformization to extract a uniform family.
4. Relate polynomial description size to logical definability.

**Why promising:** This is the strongest cross-domain route. It could connect monotone lower bounds to finite model theory in a novel way. Even partial formalization would be field-opening.

**Recommended order:** Start with Strategy A for formal traction, then push toward B or C in the writeup and future directions.

---

## Concrete theorem package to deliver

Your Lean development must contain at least 3 nontrivial theorems with real proofs, not decision procedures. A strong package would be:

1. **Restriction theorem**
   - Restriction of certified sandwiches along graph embeddings preserves certification.

2. **Hereditary completeness theorem**
   - Completeness up to size `k` is preserved under restriction.

3. **Monotonicity in size bound**
   - If a family is complete up to `k₂`, then it is complete up to `k₁ ≤ k₂`.

   Example target:
   ```lean
   theorem SandwichCompleteUpTo.mono
     {S : CertifiedSandwichFamily α} {k₁ k₂ : ℕ}
     (h : k₁ ≤ k₂) :
     SandwichCompleteUpTo S k₂ → SandwichCompleteUpTo S k₁
   ```

4. **Uniform scheme ⇒ lower bound**
   - Via the catalog equivalence.

5. **Triangle-property instantiation or finite test theorem**
   - Formalize at least one concrete graph property, such as triangle containment, and prove that your framework specializes correctly.

This fifth theorem gives the project experimental teeth.

---

## Cross-domain connections you must explicitly exploit

At least one theorem or definition must connect monotone circuit certificates to another domain.

### Option 1: Finite model theory
Interpret hereditary certificate schemes as definable obstruction families. Show that restriction along embeddings behaves like preservation under substructures.

### Option 2: Proof complexity
Interpret complete sandwich families as monotone refutations. Prove a theorem showing that certificate composition mirrors proof composition or bounded-width derivation.

### Option 3: Order theory / compactness
Formalize a poset of certificates under simulation/restriction and prove existence of minimal complete witnesses under bounded size assumptions.

### Option 4: Extremal graph theory
Use induced-subgraph closure or forbidden configurations to show that graph-property certificates behave like obstruction sets.

A particularly compelling theorem would be:

```lean
theorem hereditary_scheme_gives_obstruction_basis
  (H : HereditaryCertifiedSandwichFamily P s) :
  ∀ n, ∃ B, Finite B ∧
    ∀ G, ¬ P n G ↔ ∃ b ∈ B, embeds b G
```

Even if only a weakened finite version is provable, this is exactly the kind of theorem that creates a new vocabulary.

---

## Computational experiment and falsifiable conjecture

### Main conjecture
For every monotone graph property family `P : ℕ → MonotoneGraphProp`, if every monotone circuit computing `P n` has size `> s n`, then there exists a hereditary polynomial certificate scheme complete up to `s n`.

### Clear computational test
Test the triangle property on `n = 5,6,7,8` with `s(n) = ⌈n^(3/2)⌉`:
- enumerate candidate sandwich certificates up to an explicit bounded description size,
- test completeness against all monotone circuits up to size `s(n)` or against the catalog’s equivalent characterization,
- measure growth of the smallest complete family.

### Falsification criterion
If for some tested `n`, every complete certified sandwich family has size exceeding every tested polynomial threshold, the conjecture fails in its current form.

### Stronger conjecture to include in `FUTURE_DIRECTIONS.md`
A testable refinement:
> There exists a universal polynomial `p` such that for triangle detection, the minimum hereditary complete sandwich family at size threshold `n^(3/2)` has cardinality at most `p(n)`.

This is sharp, falsifiable, and computationally attackable.

---

## Catalog building instructions

You must explicitly build on the catalog theorems, not merely cite them.

- Use `sandwichCompleteUpTo_iff_no_small_circuit` as the transfer principle between certificates and lower bounds.
- Use `approximation_sandwich_lower_bound` to derive lower-bound consequences once completeness is established.
- Reuse `CertifiedSandwichFamily` and `SandwichCompleteUpTo` rather than inventing parallel notions unless absolutely necessary.
- Your new definitions should extend the catalog language upward to asymptotic uniformity, not sideways into redundant abstractions.

If exact reuse is blocked by type signatures, create thin wrapper definitions and prove equivalence lemmas immediately.

---

## Lean-specific expectations

Your proofs must involve real mathematical structure:
- induction on `n`, `k`, or certificate complexity;
- `rcases` decomposition of certificate data;
- `by_contra` for minimal-counterexample or obstruction arguments;
- `field_simp` only if a polynomial bound or asymptotic estimate genuinely requires it;
- multi-step `calc` chains for monotonicity and transport lemmas.

Avoid superficial theorem count inflation. The file should read like the first chapter of a new theory.

---

## Deliverables — ALL MANDATORY

Produce all of the following:

1. **Lean file(s)** with the new definitions and at least 3 substantial theorems, minimizing `sorry`.
2. **A verified algorithm or computational method** for searching or constructing candidate sandwich families.
3. **`demo.py`** that interactively demonstrates the result on the triangle property for `n = 5,6,7,8`, including certificate-size growth plots or textual summaries.
4. **`FUTURE_DIRECTIONS.md`** with 3–5 testable scientific hypotheses. Each must be falsifiable and include an explicit computational or mathematical test.
5. **`RESEARCH_PAPER.md`** as a standalone scientific paper: problem statement, definitions, theorems, proof ideas, significance, limitations, and next questions. A reader with no code access must still understand the discovery.
6. **`ARTICLE.md`** in Scientific American style, explaining the ideas and why they matter to a broad audience. Do **not** focus on formal verification machinery; focus on asymptotic compactness, lower bounds, and why certificate normal forms could change complexity theory.

---

## Application keywords

Monotone circuit complexity; approximation method; compactness; hereditary certificates; finite model theory; proof complexity; obstruction bases; descriptive complexity; graph properties; triangle detection; asymptotic lower bounds; uniformity; canonical witnesses; combinatorial normal forms; algorithmic certificate search.

---

## Standard of success

A successful outcome is not merely “some theorem about sandwiches.” It is the birth of a new organizing principle:

> **Monotone lower bounds are compact, hereditary, and certifiable by polynomially describable obstruction families.**

Even a rigorous partial version — restriction stability, hereditary completeness, uniform extraction under bounded hypotheses — would already open a new research program.

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
