Soli Deo Gloria

## Assignment: Direction 2 — Higher-Order Critical Pairs and Knuth–Bendix Completion Modulo β

**Mode:** prove

Prove genuinely new, non-trivial theorems at the frontier of rewriting theory and typed λ-calculus. Build directly on the catalog foundations

- `Pythagorean/HigherOrderCompletion.lean`
- `Pythagorean/ConcreteTermAlgebra.lean`

and use them not as decorative citations, but as structural load-bearing lemmas in a bounded higher-order completion theorem. Minimize `sorry`. The goal is not a small variant of first-order completion, but a mathematically sharp, mechanized bridge between **higher-order pattern rewriting**, **β-normalized overlap analysis**, and **decidable local confluence certificates** for functional program equations.

This direction is potentially field-opening: a verified bounded Knuth–Bendix completion modulo β for simply typed higher-order systems would create a new foundation for certifying rewrite-based optimization passes in compilers, symbolic execution engines, proof-producing supercompilers, and normalization-by-rewriting frameworks. If successful, it opens a route from abstract rewriting theory to certified equational reasoning for real functional programs.

---

## Core Vision

Establish a **bounded higher-order critical pair theorem modulo β** for finite left-linear simply typed rewrite systems whose left-hand sides are Miller patterns. The first breakthrough target is:

> **If all β-normalized higher-order critical pairs of a finite left-linear pattern system are absent or joinable up to a fixed size bound, then the induced β-aware one-step rewrite relation is locally confluent on closed terms up to that same size bound.**

This is not a routine adaptation of first-order rewriting. The hard mathematical point is that overlap formation now depends on **β-normalized pattern matching**, substitution stability must be tracked through typed λ-structure, and local peaks must be classified into:
1. disjoint redex peaks,
2. nested peaks,
3. genuine higher-order overlap peaks modulo β.

The decisive insight is that for **Miller-pattern left sides**, overlap detection should become decidable and structurally tame enough to support a certified completion procedure.

---

## Precise Theorem Targets

You should introduce a bounded infrastructure if the catalog does not already expose one. In particular, define a new notion such as:

- `betaNormal : HoTerm α → Prop`
- `isMillerPattern : HoTerm α → Prop`
- `boundedClosed : Nat → HoTerm α → Prop`
- `betaCriticalPairsUpTo : Nat → HoSystem α → Finset (HoTerm α × HoTerm α)`
- `locallyConfluentOnClosedUpTo : Nat → HoSystem α → Prop`

The novelty requirement is mandatory: at least one of these must be a genuinely new concept not already present in the catalog.

### Theorem 1: Decidability of bounded higher-order pattern critical-pair absence

Formal target shape:

```lean
theorem decidable_no_betaCriticalPairsUpTo_of_pattern
  (N : Nat) (E : HoSystem α) :
  (∀ r ∈ E.rules, isMillerPattern r.lhs) →
  Finite E.rules →
  Decidable (betaCriticalPairsUpTo N E = ∅)
```

If exact `HoSystem` field names differ, adapt accordingly, but keep the mathematical statement intact.

A more computationally useful variant is also welcome:

```lean
theorem betaCriticalPairsUpTo_computable_of_pattern
  (N : Nat) (E : HoSystem α) :
  (∀ r ∈ E.rules, isMillerPattern r.lhs) →
  ∃ cps : Finset (HoTerm α × HoTerm α), cps = betaCriticalPairsUpTo N E
```

This theorem matters because it converts an abstract confluence obstruction into a finite, checkable object. That is the hinge needed for completion.

---

### Theorem 2: Bounded critical pair theorem modulo β

Formal target shape:

```lean
theorem localConfluenceOnClosedUpTo_of_no_betaCriticalPairs
  (N : Nat) (E : HoSystem α) :
  finite E.rules →
  leftLinear E →
  simplyTyped E →
  (∀ r ∈ E.rules, isMillerPattern r.lhs) →
  betaCriticalPairsUpTo N E = ∅ →
  locallyConfluentOnClosedUpTo N E
```

This is the flagship theorem. It should be a true higher-order analogue of the first-order critical pair criterion, but only under a bounded closed-term regime, which makes the theorem both realistic and algorithmically actionable.

An even stronger and likely more robust variant is:

```lean
theorem localConfluenceOnClosedUpTo_of_joinable_betaCriticalPairs
  (N : Nat) (E : HoSystem α) :
  finite E.rules →
  leftLinear E →
  simplyTyped E →
  (∀ r ∈ E.rules, isMillerPattern r.lhs) →
  (∀ p ∈ betaCriticalPairsUpTo N E, joinableUpTo N E p.1 p.2) →
  locallyConfluentOnClosedUpTo N E
```

This version is mathematically superior: emptiness of critical pairs is only a special case, while joinability is the true Newman/Knuth–Bendix-style hypothesis.

---

### Theorem 3: Substitution/β-stability of higher-order overlap peaks

This theorem should explicitly leverage the catalog closure theorem from `Pythagorean/HigherOrderCompletion.lean`.

Formal target shape:

```lean
theorem betaOverlap_peak_stable_under_closed_subst
  (E : HoSystem α) (σ : Subst α) (s t u : HoTerm α) :
  closedSubst σ →
  betaOverlapPeak E s t u →
  betaOverlapPeak E (subst σ s) (subst σ t) (subst σ u)
```

or, if the catalog relation is phrased in one-step rewriting:

```lean
theorem hoRewrite_beta_closed_under_pattern_subst
  (E : HoSystem α) (σ : Subst α) (s t : HoTerm α) :
  closedSubst σ →
  HoRewriteβ E s t →
  HoRewriteβ E (subst σ s) (subst σ t)
```

This theorem is not merely technical. It is the engine that allows local peak classification to descend from schematic overlaps to concrete reductions on closed terms. You should build it from `hoRewrites_closed_under_subst`, extending the closure argument through β-normalization or β-aware matching.

---

### Theorem 4: Cross-domain theorem — rewrite confluence as functional program optimization coherence

You must include at least one theorem connecting this domain to a different mathematical or semantic domain. The strongest option here is semantics/program transformation.

For example, define a simple denotational or extensional equivalence on closed simply typed terms, and prove:

```lean
theorem locallyConfluentOnClosedUpTo_implies_unique_nf_on_programs
  (N : Nat) (E : HoSystem α) :
  terminatingOnClosedUpTo N E →
  locallyConfluentOnClosedUpTo N E →
  ∀ t, boundedClosed N t →
    ∃! n, normalForm E n ∧ rewritesStarβ E t n
```

Cross-domain connection: this links **rewriting theory** with **program semantics** and compiler correctness. If exact uniqueness is too ambitious, prove semantic invariance of normal forms under a denotational interpretation.

Alternative cross-domain theorem if semantics infrastructure is easier:

```lean
theorem joinable_peaks_yield_coherent_equational_reasoning
  (N : Nat) (E : HoSystem α) :
  locallyConfluentOnClosedUpTo N E →
  ∀ t u v, boundedClosed N t →
    rewritesStarβ E t u →
    rewritesStarβ E t v →
    ∃ w, rewritesStarβ E u w ∧ rewritesStarβ E v w
```

and interpret this as **coherence of optimization pipelines** in functional programming.

---

## Lean 4 Formalization Guidance

Use the exact catalog theorem names when available, especially:

- `hoRewrites_closed_under_subst`
- `concrete_completion_correct`

You should explain in comments and in the paper exactly how they are used:

- `hoRewrites_closed_under_subst` is the bridge from schematic higher-order rewrite steps to instantiated overlap peaks.
- `concrete_completion_correct` is the first-order prototype whose proof architecture should be lifted: overlap enumeration, critical-pair generation, and joinability-to-local-confluence transfer.

If the first-order theorem is stated in a completion-oriented way, mirror its decomposition:
1. define bounded critical pairs,
2. prove every non-parallel local peak arises from one,
3. discharge all such peaks under the no-critical-pair or joinable-critical-pair assumption.

---

## Proof Strategy Architecture

You must give Aristotle multiple proof routes and choose the most promising one.

### Strategy A: Peak classification + bounded overlap analysis
1. Define a β-aware local peak relation on closed terms of size `≤ N`.
2. Prove every such peak is either:
   - parallel/disjoint and trivially joinable,
   - nested and joinable by left-linearity plus substitution closure,
   - or induced by a β-critical overlap.
3. Conclude local confluence from absence or joinability of `betaCriticalPairsUpTo N E`.

**Why promising:** This most directly generalizes the first-order critical pair theorem and aligns with `concrete_completion_correct`. It is conceptually clean and likely the best mainline proof.

---

### Strategy B: β-normalization reduction to a first-order spine encoding
1. Encode β-normal Miller patterns into a first-order spine algebra.
2. Show bounded overlap computation in the higher-order system corresponds to ordinary critical pair computation in the encoded algebra.
3. Transfer local confluence back to the original system.

**Why promising:** This could yield a surprisingly powerful bridge to first-order completion machinery. If successful, it opens a route to reusing a large body of first-order theory. But it is riskier because encoding adequacy and substitution compatibility may be technically heavy.

---

### Strategy C: Parallel reduction / diamond-style proof
1. Define a parallel β-aware rewrite relation.
2. Prove a bounded diamond property under pattern-critical-pair assumptions.
3. Derive local confluence of one-step rewriting from parallel confluence.

**Why promising:** Parallel methods often simplify overlap bookkeeping.  
**Why less promising for the first milestone:** It may require more infrastructure than Strategy A and could obscure the algorithmic content needed for completion.

**Recommended primary route:** Strategy A.  
**Recommended secondary route:** Strategy B as a follow-on if the spine encoding becomes elegant enough.

---

## Required Deep Proof Tactics

Your file must contain at least 3 substantial theorems proved using real mathematics, not automation-only closure. Concretely, include proofs using several of:

- induction on term structure or derivation height,
- `rcases` on overlap/peak cases,
- `by_contra` to eliminate impossible overlap forms,
- `field_simp` only if you create a semantic invariant with rational weights,
- multi-step `calc` chains for rewrite closure or β-normalization transport.

Do not hide the argument behind brute-force decision procedures. If a theorem is only true because a finite search succeeds, the theorem is too weak.

---

## New Definitions You Should Introduce

At least one must be genuinely novel relative to the catalog. Good candidates:

1. `isMillerPattern`  
   A typed syntactic predicate identifying left-hand sides whose free variables appear only in Miller-pattern positions.

2. `betaCriticalPairsUpTo`  
   A bounded finite set of critical pairs generated from β-normalized overlaps on closed terms of size ≤ `N`.

3. `joinableUpTo`  
   Joinability restricted to closed terms bounded by size, suitable for certified search.

4. `locallyConfluentOnClosedUpTo`  
   The exact property needed for bounded completion.

5. `completionCertificateβ`  
   A structure bundling:
   - candidate oriented rules,
   - proof of pattern restriction,
   - finite critical-pair report,
   - bounded local confluence guarantee.

That last option is especially valuable because it turns theory into a reusable artifact.

---

## Algorithmic Deliverable

You must produce a verified computational method, not only theorem statements.

### Required algorithm
Implement a bounded higher-order critical pair enumerator for Miller-pattern systems:

```lean
def enumerateBetaCriticalPairsUpTo :
  Nat → HoSystem α → Finset (HoTerm α × HoTerm α)
```

and prove a soundness theorem of the shape:

```lean
theorem enumerateBetaCriticalPairsUpTo_sound
  (N : Nat) (E : HoSystem α) :
  ∀ p ∈ enumerateBetaCriticalPairsUpTo N E,
    p ∈ betaCriticalPairsUpTo N E
```

If possible, also prove completeness for pattern systems:

```lean
theorem enumerateBetaCriticalPairsUpTo_complete_of_pattern
  (N : Nat) (E : HoSystem α) :
  (∀ r ∈ E.rules, isMillerPattern r.lhs) →
  ∀ p ∈ betaCriticalPairsUpTo N E,
    p ∈ enumerateBetaCriticalPairsUpTo N E
```

This is the computational heart of the project. It should be paired with a bounded joinability checker, even if semidecisive:

```lean
def tryJoinCriticalPairUpTo :
  Nat → HoSystem α → (HoTerm α × HoTerm α) → Bool
```

with a correctness theorem saying `true` implies actual joinability within the search bound.

---

## Benchmark and Demo Expectations

Test on benchmark systems inspired by functional programming transformations:

- map fusion
- fold/build fusion
- CPS transformation rules
- β-like administrative reduction schemas
- simple deforestation systems

The `demo.py` should:
1. load or encode small benchmark rewrite systems,
2. enumerate β-critical pairs up to a user-specified bound,
3. attempt bounded joining,
4. report whether the system satisfies the bounded local confluence criterion,
5. display the first detected non-joinable pair if any.

The point of the demo is to make the theorem experimentally alive.

---

## Conjecture with Falsifiable Prediction

You must include at least one explicit conjecture with a computational disproof protocol.

### Recommended conjecture
> **Conjecture.** For every finite left-linear simply typed Miller-pattern rewrite system `E`, there exists a monotone function `f_E : Nat → Nat` such that if all β-critical pairs generated from overlaps of size `≤ f_E(N)` are joinable within size `≤ f_E(N)`, then `HoRewriteβ E` is locally confluent on all closed terms of size `≤ N`.

This is falsifiable: search for a counterexample system where all small overlaps join, but a larger hidden overlap induces a non-joinable local peak below the target term bound.

A sharper computational prediction:
> For the benchmark families above, the first non-joinable β-critical pair, if it exists, appears at overlap size at most quadratic in the largest rule size.

This is experimentally testable and could be false. Good — that makes it scientific.

---

## Cross-Domain Connections You Must Emphasize

This project should not remain trapped inside rewriting theory. Explicitly connect it to at least one external domain:

1. **Programming language semantics**  
   Local confluence + termination gives unique normal forms, hence coherent optimization pipelines for functional programs.

2. **Automated theorem proving**  
   A higher-order completion procedure modulo β would strengthen equational reasoning in proof assistants and superposition-like engines.

3. **Category theory / coherence**  
   Joinability of rewrite peaks can be read as a coherence principle: different syntactic optimization paths represent the same morphism/computation.

4. **Type theory / normalization**  
   Pattern rewriting modulo β is adjacent to definitional equality extensions in typed calculi.

5. **Compiler verification**  
   Certified fusion and CPS transformation rely on exactly the kind of overlap control this project studies.

### Application keywords
higher-order rewriting, Knuth–Bendix completion, Miller patterns, β-normalization, local confluence, critical pairs, typed λ-calculus, compiler optimization, equational reasoning, denotational semantics, coherence, automated deduction

---

## Concrete Build Plan

1. Inspect `Pythagorean/HigherOrderCompletion.lean` and identify the exact definitions of:
   - higher-order terms,
   - substitutions,
   - one-step rewrite,
   - closure under substitution.
2. Inspect `Pythagorean/ConcreteTermAlgebra.lean` and map the first-order completion proof into reusable lemmas:
   - overlap decomposition,
   - critical-pair generation,
   - local confluence criterion.
3. Introduce bounded predicates and finite enumerators.
4. Prove substitution and β-normalization stability lemmas.
5. Prove peak classification.
6. Derive bounded local confluence theorem.
7. Implement certified overlap enumeration and bounded joinability search.
8. Run benchmarks and formulate/refine the conjecture from data.

---

## Nontrivial Theorem Checklist

Your final Lean development must contain at least 3 deep theorems, for example:

- bounded pattern critical-pair decidability,
- substitution stability of β-aware rewriting,
- peak classification for bounded local peaks,
- local confluence from joinable β-critical pairs,
- uniqueness of normal forms on terminating bounded closed terms.

At least 3 of these must require actual proof architecture with induction / case splits / contradiction / structured calculations.

---

## Mandatory Deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as compiler correctness, category-theoretic coherence, or higher-order automated deduction.

### 2. `RESEARCH_PAPER.md`
A standalone scientific document. Someone reading only this file must understand:
- the problem,
- the new definitions,
- the main theorems,
- the proof architecture,
- the computational method,
- the benchmark findings,
- why the result matters,
- what comes next.

Do not assume access to the Lean code.

### 3. `ARTICLE.md`
Write in Scientific American style. It must be engaging and broadly accessible.  
Taboo: do **not** focus on formal verification machinery. Focus on the mathematical ideas, the dream of making higher-order equational reasoning algorithmic, and why confluence modulo β matters for the logic of computation.

### 4. Verified algorithm / computational method
Implement and verify:
- bounded β-critical pair enumeration,
- bounded joinability checking or certification,
- a decision/certification pipeline for bounded local confluence in pattern systems.

### 5. `demo.py`
An interactive demonstration that:
- constructs benchmark higher-order rewrite systems,
- enumerates overlaps,
- computes critical pairs,
- attempts joins,
- reports bounded local confluence status,
- visualizes at least one peak/join diagram.

---

## Final Charge

Do not settle for a weak “toy” result. The theorem should feel like the first real stone in a future higher-order completion theory:

- first-order completion, lifted through typed λ-structure,
- β-normalized overlap analysis, made decidable on pattern systems,
- bounded local confluence, turned into a certificate-producing algorithm.

If you can make this work cleanly, you are not just extending a library. You are creating a new language for certifying the algebra of functional programs.

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
