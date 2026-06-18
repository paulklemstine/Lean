Soli Deo Gloria

## Assignment: Direction 1: Primewise Completeness for Derived Persistence Invariants

**Mode:** `prove`

Prove genuinely new theorems at the frontier of integer persistence. Build directly on the catalog infrastructure in:

- `Pythagorean/PrimewiseTorsionStability.lean`
- `Pythagorean/MaxEnvelopeStability.lean`

especially the max-envelope mechanism, the primewise decomposition lemmas, and the theorem lineage around `IsMaxEnvelope` and `finite_prime_envelope_suffices'`.

This project must not stop at birth sets. The goal is to formalize a **derived primewise completeness principle**: once torsion persistence is decomposed prime-by-prime, the global derived invariants should be reconstructed by an `L∞`/max-envelope law, and the corresponding stability bounds should descend and reassemble with no loss. If true, this would amount to a formal algebraic-stability theorem for integer persistence built from prime channels.

---

## Central Vision

The breakthrough target is to show that the max-envelope phenomenon is not an accident of birth sets, but a structural law of derived persistence over `ℤ`: persistence diagrams, Betti-type counting profiles, and landscape-style invariants should all inherit a primewise `sup` aggregation rule.

This would open a new field of **prime-resolved topological data analysis over the integers**, where one studies not just rational barcodes but arithmetic decomposition laws for persistent homology. It would also create a bridge from persistence theory to:

- **homological algebra**: decomposition of finitely generated torsion modules into p-primary summands,
- **algebraic K-theory**: derived torsion signatures and prime-local classification,
- **arithmetic geometry**: local-global reconstruction from prime fibers,
- **spectral sequence methods**: filtrations whose pages split primewise,
- **applied TDA**: arithmetic-sensitive summaries robust under perturbation.

Application keywords: **persistent homology, bottleneck distance, arithmetic TDA, p-primary decomposition, derived invariants, algebraic stability, homological algebra, K-theory, spectral sequences, local-global principle**.

---

## Precise Theorem Targets

You must introduce at least one new definition and prove at least 3 nontrivial theorems with real proof structure. Avoid toy statements.

### New definitions to introduce

At minimum define a primewise derived invariant package. A suggested architecture:

```lean
/-- A prime-indexed family of diagram-like invariants with a global sup aggregation law. -/
structure PrimewiseDerivedInvariant (α : Type*) where
  obj            : α → ℕ → Type*
  aggregate      : (ℕ → ℝ≥0∞) → ℝ≥0∞
  prime_dist     : {X Y : α} → (p : ℕ) → obj X p → obj Y p → ℝ≥0∞
  global_dist    : α → α → ℝ≥0∞
  is_sup_envelope :
    ∀ X Y, global_dist X Y = ⨆ p, prime_dist p (Classical.choice (by sorry)) (Classical.choice (by sorry))
```

This is only a schematic. You should replace the placeholder design by a mathematically meaningful one. Better still: define a structure specialized to integer persistence modules and their p-primary diagram invariants.

A more realistic definition target:

```lean
/-- A finite-support primewise persistence profile valued in some diagram space. -/
structure PrimewiseDiagramProfile where
  diagAt        : ℕ → Type*
  support       : Finset ℕ
  support_spec  : ∀ p, p ∉ support → Subsingleton (diagAt p)
```

and then a derived counting invariant:

```lean
/-- Betti-style counting function extracted from a primewise diagram profile. -/
def primewiseBettiCurve (D : PrimewiseDiagramProfile) : ℕ → ℝ≥0∞ := ...
```

You may also define a `PrimewiseBottleneckComposable` predicate expressing that a global matching decomposes into primewise matchings and conversely reassembles.

---

## Primary theorem: Primewise bottleneck upper bound

Formalize a theorem of the following shape.

### Mathematical statement

Let `M, N` be integer persistence objects with finite prime support, and let `D(M), D(N)` be their global torsion persistence diagrams. For each prime `p`, let `D_p(M), D_p(N)` denote the p-primary persistence diagrams. Then

\[
d_B(D(M),D(N)) \le \sup_p d_B(D_p(M),D_p(N)).
\]

This is the derived analogue of the max-envelope theorem for birth sets.

### Lean 4 type signature target

A plausible formal target is:

```lean
theorem bottleneck_le_primewise_sup
  {C : Type*}
  [PseudoMetricSpace C]
  (M N : C)
  (D : C → Type*)
  (Dp : ℕ → C → Type*)
  (dB : {X Y : C} → D X → D Y → ℝ≥0∞)
  (dBp : (p : ℕ) → {X Y : C} → Dp p X → Dp p Y → ℝ≥0∞)
  (hdecomp : ∀ X, Nonempty (D X) → ∀ p, Nonempty (Dp p X))
  (hreassemble :
    ∀ {X Y} (DX : D X) (DY : D Y),
      dB DX DY ≤ ⨆ p, dBp p (Classical.choice (hdecomp X ⟨DX⟩ p))
                           (Classical.choice (hdecomp Y ⟨DY⟩ p)))
  :
  ∀ DX DY, dB DX DY ≤ ⨆ p, dBp p
    (Classical.choice (hdecomp M ⟨DX⟩ p))
    (Classical.choice (hdecomp N ⟨DY⟩ p))
```

But do not settle for an abstract tautology. Specialize this to your actual persistence-diagram infrastructure and prove a theorem where the hard work is in constructing `hreassemble`, not assuming it.

A stronger and more meaningful target would be:

```lean
theorem torsionDiagram_bottleneck_le_iSup_prime
  (M N : IntegerPersistenceModule)
  [FinitePrimeSupport M] [FinitePrimeSupport N] :
  bottleneckDist (torsionDiagram M) (torsionDiagram N)
    ≤ ⨆ p : ℕ, bottleneckDist (primeTorsionDiagram p M) (primeTorsionDiagram p N)
```

If the full `IntegerPersistenceModule` infrastructure is too large, define a clean intermediate model of finite primewise multidiagrams and prove the theorem there.

---

## Secondary theorem: Max-envelope law for Betti curves

### Mathematical statement

If the global torsion diagram is the disjoint primewise aggregation of p-primary diagrams, then the associated Betti/counting curve is bounded pointwise by the primewise maximum, and under a non-overlap or independent-channel hypothesis it is equal to the primewise maximum.

At minimum prove the inequality:

\[
\beta_{M}(t) \le \sup_p \beta_{M,p}(t).
\]

But the truly interesting theorem is a stability theorem:

\[
\|\beta_M - \beta_N\|_\infty \le \sup_p \|\beta_{M,p} - \beta_{N,p}\|_\infty.
\]

### Lean 4 type signature target

```lean
theorem bettiCurve_dist_le_primewise_sup
  (M N : IntegerPersistenceModule)
  [FinitePrimeSupport M] [FinitePrimeSupport N] :
  eLpNormInf (fun t => primewiseGlobalBettiCurve M t - primewiseGlobalBettiCurve N t)
    ≤ ⨆ p : ℕ, eLpNormInf (fun t => primeBettiCurve p M t - primeBettiCurve p N t)
```

If subtraction in `ℝ≥0∞` is inconvenient, formulate with pointwise distance:

```lean
theorem bettiCurve_supDist_le_primewise_sup
  (M N : IntegerPersistenceModule)
  [FinitePrimeSupport M] [FinitePrimeSupport N] :
  (⨆ t, edist (globalBettiCurve M t) (globalBettiCurve N t))
    ≤ ⨆ p : ℕ, ⨆ t, edist (primeBettiCurve p M t) (primeBettiCurve p N t)
```

This theorem is valuable because it turns prime decomposition into a directly computable certified stability bound for functional summaries, not just barcodes.

---

## Tertiary theorem: Strictness / counterexample to equality

You are explicitly asked to construct **explicit counterexamples to equality** in the derived setting. This is important: it shows the upper bound is sharp as an inequality but not an identity in full generality.

### Mathematical statement

There exist persistence objects `M, N` such that

\[
d_B(D(M),D(N)) < \sup_p d_B(D_p(M),D_p(N)).
\]

or for some derived functional summary,

\[
\|\Lambda(M)-\Lambda(N)\|_\infty < \sup_p \|\Lambda_p(M)-\Lambda_p(N)\|_\infty.
\]

This proves that recombination can create cancellations or inefficiencies absent from primewise channels.

### Lean 4 type signature target

```lean
theorem exists_strict_primewise_gap :
  ∃ M N : ToyIntegerPersistenceModule,
    bottleneckDist (torsionDiagram M) (torsionDiagram N)
      < ⨆ p : ℕ, bottleneckDist (primeTorsionDiagram p M) (primeTorsionDiagram p N)
```

If bottleneck-distance infrastructure is too heavy, prove strictness first for a derived counting invariant or landscape proxy:

```lean
theorem exists_strict_betti_gap :
  ∃ M N : ToyIntegerPersistenceModule,
    (⨆ t, edist (globalBettiCurve M t) (globalBettiCurve N t))
      < ⨆ p : ℕ, ⨆ t, edist (primeBettiCurve p M t) (primeBettiCurve p N t)
```

This theorem is not a consolation prize. It is conceptually essential: it identifies the exact limit of the local-global principle.

---

## Cross-domain theorem requirement

You must include at least one theorem that bridges persistence with another domain.

### Recommended bridge: spectral sequence or local-global arithmetic

A strong target:

### Mathematical statement

If a filtered torsion complex has pagewise p-primary splitting compatible with differentials, then the induced persistence summary at the abutment satisfies the same primewise max-envelope bound.

This would connect persistence to **spectral sequences** and derived homological algebra.

A lighter but still meaningful bridge:

```lean
theorem local_global_stability_of_arithmetic_profile
  (M N : IntegerPersistenceModule)
  [FinitePrimeSupport M] [FinitePrimeSupport N] :
  arithmeticComplexityProfileDist M N
    ≤ ⨆ p : ℕ, arithmeticComplexityProfileDist (primeLocalization p M) (primeLocalization p N)
```

Alternative bridge: algebraic K-theory language. Define a toy `K₀`-style rank/torsion profile and prove primewise control of its persistence summary.

---

## Proof Architecture: 3 Strategy Paths

You must pursue one main path, but think through all three.

### Strategy A: Matching decomposition and reassembly
1. Define a toy or genuine notion of global torsion persistence diagram as a finite aggregation of p-primary diagrams.
2. Prove that any admissible global matching induces primewise matchings by restriction.
3. Prove conversely that primewise matchings can be reassembled into a global matching with cost equal to the supremum of primewise costs.
4. Deduce the bottleneck upper bound via a multi-step `calc` argument over matching costs.

**Why promising:** This is the closest analogue of the algebraic stability theorem and gives the strongest conceptual result. It directly upgrades `finite_prime_envelope_suffices'` from set-valued births to diagram matchings.

### Strategy B: Functional reduction through envelope invariants
1. Define derived summaries (Betti curves, rank functions, landscapes, or counting measures) extracted from diagrams.
2. Show these summaries are max-envelope aggregations of p-primary summaries.
3. Transfer the primewise stability bound using the existing max-envelope lemmas from `Pythagorean/MaxEnvelopeStability.lean`.
4. Use this as a first certified theorem even if full diagram bottleneck reconstruction is not yet complete.

**Why promising:** This path is more feasible in Lean and still scientifically meaningful. It converts a difficult matching theorem into a functional-analytic stability theorem that can be tested computationally.

### Strategy C: Finite-support local-global principle
1. Introduce a finite-support class of primewise persistence objects.
2. Prove a support truncation theorem: only finitely many primes matter for the derived invariant.
3. Apply `finite_prime_envelope_suffices'` or an adapted version to derive global control from finitely many local channels.
4. Then specialize to bottleneck-like or Betti-like invariants.

**Why promising:** This is the best route if you need to control infinite `iSup` issues or if the main obstacle is formal rather than conceptual. It also aligns tightly with the catalog.

**Most promising overall:** Start with **Strategy B**, because it will produce real theorems quickly and build reusable infrastructure. Then push toward **Strategy A** for the flagship bottleneck theorem. Use **Strategy C** to manage finiteness and technical closure properties.

---

## Specific catalog leverage

You are not starting from zero. Reuse the catalog aggressively.

- From `Pythagorean/MaxEnvelopeStability.lean`, extract the exact mechanism behind `IsMaxEnvelope`.
  - Use it not merely as a black box.
  - Refactor it if needed so that diagram-derived functions fit the same interface.
  - Generalize from birth-set distance profiles to any prime-indexed family satisfying finite support and envelope compatibility.

- From `finite_prime_envelope_suffices'`:
  - identify the hypotheses that make the finite-prime reduction work,
  - package your new derived invariants so they satisfy analogous hypotheses,
  - prove a derived version, e.g. `finite_prime_diagram_envelope_suffices` or `finite_prime_betti_envelope_suffices`.

- From `Pythagorean/PrimewiseTorsionStability.lean`:
  - isolate the exact decomposition theorem already available for p-primary torsion,
  - show how the new diagram or Betti constructions commute with that decomposition,
  - use the existing primewise stability bound as the local estimate in the final `sup` theorem.

- The lemma referred to as `natDist'_inf'_le_sup'_natDist'` should be treated as a prototype:
  - identify its abstract pattern,
  - generalize from birth-set infimum distance to matching-based or summary-based distances,
  - formulate and prove a reusable analogue in the new setting.

---

## Required theorem list

Your final Lean development must contain at least 3 substantial theorems. A recommended minimal set:

1. `finite_prime_derived_envelope_suffices`
   - finite-support reduction for your new derived invariant.

2. `bettiCurve_supDist_le_primewise_sup`
   - a full max-envelope stability theorem for Betti-style summaries.

3. `exists_strict_betti_gap` or `exists_strict_primewise_gap`
   - explicit strictness counterexample to equality.

Stretch theorem:

4. `torsionDiagram_bottleneck_le_iSup_prime`
   - flagship local-global bottleneck bound.

These should involve real proof tactics: induction over finite support, `rcases` on decomposition data, `by_contra` to handle failure of a bound, `field_simp` where rational interval endpoints appear, and substantial `calc` chains.

---

## Conjecture with testable prediction

State and formalize a falsifiable conjecture.

### Conjecture
For finite-support integer persistence modules with interval-decomposable p-primary parts, the bottleneck distance is exactly the primewise supremum:

\[
d_B(D(M),D(N)) = \sup_p d_B(D_p(M),D_p(N)).
\]

### Lean sketch

```lean
conjecture primewise_bottleneck_exact
  (M N : IntegerPersistenceModule)
  [FinitePrimeSupport M] [FinitePrimeSupport N]
  [PrimewiseIntervalDecomposable M] [PrimewiseIntervalDecomposable N] :
  bottleneckDist (torsionDiagram M) (torsionDiagram N)
    = ⨆ p : ℕ, bottleneckDist (primeTorsionDiagram p M) (primeTorsionDiagram p N)
```

### Testable prediction
Implement a search over small toy persistence modules with support in `{2,3,5}` and bounded interval multiplicities. Either:
- all interval-decomposable examples satisfy equality, or
- a concrete counterexample appears and kills the conjecture.

This is scientifically excellent either way. If false, isolate the obstruction. If true in all tested cases, formulate a sharper structural criterion.

---

## Computational/algorithmic deliverable

You must produce a **verified algorithm**, not just theorem statements.

### Required algorithm
Implement a procedure that, given finite primewise summaries, computes:
- the primewise distances,
- their maximum/supremum,
- the induced certified upper bound for the global derived invariant,
- and a witness when equality fails in the toy model.

Suggested formal object:

```lean
def primewiseDerivedUpperBound :
  ToyIntegerPersistenceModule → ToyIntegerPersistenceModule → ℝ≥0∞
```

with theorem:

```lean
theorem global_dist_le_primewiseDerivedUpperBound
  (M N : ToyIntegerPersistenceModule) :
  globalDerivedDist M N ≤ primewiseDerivedUpperBound M N
```

Also prove a correctness theorem for the support-pruning optimization:
only primes in the union of supports need to be checked.

---

## demo.py requirement

Produce `demo.py` that interactively:
1. constructs small prime-supported persistence examples,
2. computes primewise Betti curves / diagram proxies,
3. displays the certified max-envelope upper bound,
4. searches for strictness examples,
5. tests the conjecture on random finite-support instances.

The demo should make the mathematics visible: plots of primewise curves, the global envelope, and a report of whether equality or strict inequality occurs.

---

## Paper-writing deliverables (MANDATORY)

You must produce all of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must include the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- spectral sequences,
- algebraic K-theory,
- arithmetic statistics,
- sheaf-theoretic persistence,
- topological signal processing.

Do not write template prose. Write as a research visionary mapping the next frontier.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper that someone can read without seeing the code. It must explain:
- the mathematical problem,
- why primewise decomposition matters,
- the new definitions,
- the main theorems,
- proof ideas,
- examples and strictness phenomena,
- the conjecture and computational evidence,
- what this opens next.

### 3. `ARTICLE.md`
Write in Scientific American style for a broad audience. Explain:
- how topology can detect shape across scales,
- why working over the integers reveals hidden arithmetic channels,
- what it means to decompose information by prime numbers,
- why the max-envelope law is surprising and useful.

**Taboo:** do not focus on formal verification machinery. Focus on the mathematical ideas and significance.

### 4. Verified algorithm / computational method
As above.

### 5. `demo.py`
As above.

---

## Technical guidance for Lean execution

- Prefer finite-support formulations early. Infinite-prime generality can come later.
- Introduce a toy but mathematically principled model if full persistence-diagram infrastructure is unavailable.
- Use `Finset` induction to prove finite-support envelope theorems.
- Use `rcases` heavily on decomposition witnesses into p-primary components.
- Use `by_contra` to convert global bound failure into a violating prime.
- Use `calc` blocks to make the max-envelope proof legible.
- If rational endpoints or interval lengths are encoded, expect `field_simp` in landscape or rank-function calculations.
- Minimize `sorry`; if one remains, it should isolate a genuinely infrastructural obstacle rather than a missing easy lemma.

---

## Standard of ambition

Do not produce a minor variation on the catalog. The aim is to make the catalog’s primewise birth-set stability theorem look like the zeroth shadow of a much larger principle: **derived local-global stability for arithmetic persistence**.

If you succeed, you will have created the first formal framework in which integer persistent invariants are reconstructed from prime channels with certified global stability bounds. That is not an extension. That is a new language for the subject.

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
