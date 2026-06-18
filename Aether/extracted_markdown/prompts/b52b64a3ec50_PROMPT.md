## Assignment: **prove**

### Title
**Normalizer-Invariance and Universality Classes for Proof Compression**

### Core Vision
You should not merely compare two implementations of normalization. You should formalize a theorem-schema showing that, under precise simulation hypotheses, the *asymptotic phase* of proof compression is invariant under choice of complete deterministic normalizer. If established even in a sharply delimited abstract setting, this opens a new field: **complexity-theoretic proof thermodynamics**, where proof systems exhibit universality classes analogous to renormalization classes in statistical physics.

The decisive breakthrough is to separate:
1. **syntax-dependent normalization cost**, and
2. **theory-intrinsic proof compression phase**.

If you can prove that exponential normalized blowup is preserved under polynomially bounded translation between normalizers, then “proof compression phase transitions” become mathematical invariants rather than artifacts of implementation.

---

## Precise Formal Target

Work in an abstract bounded-search proof calculus `P` with:
- a type of statements `Stmt`,
- a type of raw proofs `Proof`,
- a proof-size function `rawSize : Proof → ℕ`,
- a provability relation `proves : Proof → Stmt → Prop`,
- deterministic complete normalizers `N : Proof → Proof`,
- normalized size `normSize N p := rawSize (N p)`.

You should introduce a new structure capturing asymptotic simulation between normalizers.

### Novel definition to introduce
Define a structure such as:

```lean
structure NormalizerModel (Stmt Proof : Type _) where
  proves      : Proof → Stmt → Prop
  rawSize     : Proof → ℕ
  normalize   : Proof → Proof
  sound_norm  : ∀ {p φ}, proves p φ → proves (normalize p) φ
  det_norm    : True
```

and a cross-normalizer comparison notion:

```lean
def PolynomiallyEquivalent
    {Stmt Proof : Type _}
    (M₁ M₂ : NormalizerModel Stmt Proof) : Prop :=
  ∃ k c : ℕ,
    1 ≤ k ∧
    ∀ φ n,
      (∃ p, M₁.proves p φ ∧ M₁.rawSize p ≤ n) →
      (∃ q, M₂.proves q φ ∧ M₂.rawSize q ≤ c * n^k + c) ∧
      (∃ p, M₂.proves p φ ∧ M₂.rawSize p ≤ n) →
      (∃ q, M₁.proves q φ ∧ M₁.rawSize q ≤ c * n^k + c)
```

Also define the key asymptotic notion:

```lean
def ExponentialNormalizedBlowup
    {Stmt Proof : Type _}
    (M : NormalizerModel Stmt Proof)
    (fam : ℕ → Stmt) : Prop :=
  ∃ α : ℕ, 1 ≤ α ∧
    ∀ K : ℕ, ∃ᶠ n in Filter.atTop,
      ∀ p, M.proves p (fam n) →
        K * rawSize p ^ α < rawSize (M.normalize p)
```

You may want a more Lean-tractable lower bound than `2^(n^α)` at first, e.g. polynomial-vs-superpolynomial or stretched-exponential thresholds. The crucial point is to prove a real transfer theorem, not just define words.

---

## Main Theorem Blueprint

### Theorem 1: Polynomial transfer of normalized lower bounds
This should be your first major theorem.

#### Mathematical statement
If two complete deterministic normalizers are polynomially equivalent in raw proof search and each normal form can be simulated by the other with polynomial overhead, then any superpolynomial (or stretched-exponential) lower bound on normalized proof size for one normalizer transfers to the other, possibly with exponent degradation.

#### Lean 4 type signature sketch
```lean
theorem blowup_transfer_of_poly_equiv
    {Stmt Proof : Type _}
    (M₁ M₂ : NormalizerModel Stmt Proof)
    (fam : ℕ → Stmt)
    (hEq : PolynomiallyEquivalent M₁ M₂)
    (hSim :
      ∃ k c : ℕ, 1 ≤ k ∧
        ∀ p, M₂.rawSize (M₂.normalize p) ≤ c * (M₁.rawSize (M₁.normalize p))^k + c)
    (hBlow : ExponentialNormalizedBlowup M₁ fam) :
    ∃ β : ℕ, 1 ≤ β ∧ ExponentialNormalizedBlowup M₂ fam := by
  ...
```

If exact exponential transfer is too rigid for first formalization, prove the weaker but still powerful theorem:

```lean
theorem superpoly_transfer_of_poly_equiv
    {Stmt Proof : Type _}
    (M₁ M₂ : NormalizerModel Stmt Proof)
    (fam : ℕ → Stmt)
    (hEq : PolynomiallyEquivalent M₁ M₂)
    (hBlow : SuperPolynomialNormalizedBlowup M₁ fam) :
    SuperPolynomialNormalizedBlowup M₂ fam := by
  ...
```

This is already a major result if done cleanly.

---

### Theorem 2: Invariance of compression phase under polynomial equivalence
Define a trichotomy or dichotomy:
- polynomially bounded normalization,
- superpolynomial blowup,
- exponential/stretched-exponential blowup.

Then prove the phase is invariant under polynomially equivalent complete deterministic normalizers.

#### Lean 4 type signature sketch
```lean
inductive CompressionPhase
  | poly
  | superpoly
  | stretchedExp

def HasPhase
    {Stmt Proof : Type _}
    (M : NormalizerModel Stmt Proof)
    (fam : ℕ → Stmt) : CompressionPhase → Prop
  | CompressionPhase.poly         => PolynomiallyBoundedNormalization M fam
  | CompressionPhase.superpoly    => SuperPolynomialNormalizedBlowup M fam
  | CompressionPhase.stretchedExp => ExponentialNormalizedBlowup M fam

theorem phase_invariant_of_poly_equiv
    {Stmt Proof : Type _}
    (M₁ M₂ : NormalizerModel Stmt Proof)
    (fam : ℕ → Stmt)
    (hEq : PolynomiallyEquivalent M₁ M₂) :
    ∀ π, HasPhase M₁ fam π → HasPhase M₂ fam π := by
  ...
```

Even if you only prove this for `poly` and `superpoly`, it is substantial and nontrivial.

---

### Theorem 3: A no-go theorem for asymmetric polynomial/exponential separation
This is the conceptual crown jewel: prove that under your simulation hypotheses, one normalizer cannot have eventual polynomial normalized proofs on a family while another has infinitely-often stretched-exponential normalized proofs.

#### Lean 4 type signature sketch
```lean
theorem no_poly_vs_exp_separation
    {Stmt Proof : Type _}
    (M₁ M₂ : NormalizerModel Stmt Proof)
    (fam : ℕ → Stmt)
    (hEq : PolynomiallyEquivalent M₁ M₂)
    (hPoly : PolynomiallyBoundedNormalization M₁ fam)
    (hExp  : ExponentialNormalizedBlowup M₂ fam) :
    False := by
  ...
```

This is the theorem that makes the conjecture feel like a universality law rather than a comparison lemma.

---

## Proof Strategy Architecture

### Strategy A: Asymptotic comparison via explicit polynomial domination
**Most promising for Lean.**

1. Define lower/upper asymptotic predicates using only quantification over `ℕ`, avoiding analytic machinery beyond what Mathlib handles comfortably.
2. Prove a library of lemmas:
   - polynomial composition preserves polynomial boundedness,
   - polynomial domination converts lower bounds under simulation,
   - eventual/infinite-often formulations are stable under monotone reindexing.
3. Use `by_contra`, monotonicity, and multi-step `calc` chains to transfer lower bounds across the simulation inequalities.

Why this is best: it reduces the entire theorem to arithmetic inequalities on `ℕ`, finite quantifiers, and eventuality on `atTop`, all of which are formalization-friendly.

Core proof tactics likely needed:
- `induction` on exponents or polynomial degree,
- `field_simp` if you move to `ℚ`/`ℝ` asymptotics,
- `rcases` for unpacking simulation hypotheses,
- `by_contra` for no-go separation theorem,
- long `calc` chains for growth comparisons.

---

### Strategy B: Galois-style abstraction via preorder on normalizers
Define a preorder `M₁ ≼poly M₂` if every raw proof for `M₁` translates to one for `M₂` with polynomial overhead, and then define an equivalence relation from mutual reducibility.

1. Show `≼poly` is reflexive and transitive.
2. Show compression-phase predicates descend to equivalence classes.
3. Conclude invariance theorems abstractly from quotient-respecting predicates.

Why this matters: it transforms the problem from one theorem into a conceptual framework. This is more elegant and more revolutionary, but it requires more upfront infrastructure.

Best use: after Strategy A establishes the arithmetic lemmas, Strategy B packages the field.

---

### Strategy C: Finitary bounded-search model with explicit calculi
Instantiate the abstract framework for a toy sequent calculus with:
- formulas of bounded depth,
- finite proof objects,
- one Gentzen-style normalizer,
- one NbE-style normalizer.

1. Formalize completeness and determinism for both.
2. Prove polynomial simulation between the two on bounded-depth fragments.
3. Derive the phase invariance theorem as a corollary.

Why this is attractive: it creates a concrete computational testbed for the conjecture.  
Why it is riskier: the implementation burden is much higher.

Recommended path: **first do Strategy A abstractly, then instantiate a small fragment from Strategy C.**

---

## Required Deep Theorems in the File

Your file should contain **at least 3 nontrivial theorems**, with proofs using multi-step reasoning. A strong target set is:

1. `poly_bound_comp_of_poly_bound`
2. `superpoly_transfer_of_poly_equiv`
3. `no_poly_vs_superpoly_separation`

All three should require more than simplification; use `rcases`, induction on exponent/degree, contradiction, and `calc`.

---

## Catalog-Building Blocks to Exploit
Build on any existing catalog material concerning:
- asymptotic growth on `ℕ`,
- eventual predicates using `Filter.atTop`,
- polynomial bounds,
- relations between `Nat.pow`, multiplication, and monotonicity,
- finite encodings of syntax and proof trees.

If the catalog already contains lemmas resembling:
- polynomial domination,
- monotonicity of powers,
- eventual lower-bound transfer,
then refactor them into a reusable “proof complexity asymptotics” toolkit.

If the catalog has certified complexity or lower-bound transfer results from another domain, explicitly port the proof pattern:
- replace “network robustness margin” by “normal-form size gap,”
- replace “input perturbation radius” by “raw proof size budget,”
- replace “certificate transfer under Lipschitz map” by “blowup transfer under polynomial simulation.”

That analogy is mathematically fertile and should guide reusable abstractions.

---

## Cross-Domain Connections You Must Make

### 1. Statistical Physics
Interpret compression phase as an **order parameter**:
- polynomial normalization = low-complexity phase,
- superpolynomial/exponential normalization = high-complexity phase,
- polynomial equivalence classes = universality classes.

A theorem proving invariance under normalizer choice is analogous to proving that critical exponents do not depend on microscopic dynamics.

### 2. Category Theory / Semantics
Normalization-by-evaluation and cut-elimination are not just algorithms; they are different semantic realizations of proof reduction. Your invariance theorem says the asymptotic complexity class is a property of the **semantic content of the calculus**, not the chosen evaluator.

### 3. Computational Complexity
This suggests a new invariant of theories:
- the **normalization exponent spectrum**,
- perhaps ultimately linked to bounded arithmetic, propositional proof complexity, and search principles.

### 4. Information Theory
Normalized proof length can be viewed as a compressed description length of derivational content. Invariance under complete deterministic normalizers suggests a robustness theorem for “proof information content,” analogous to source coding universality.

---

## Application Keywords
proof complexity, cut elimination, normalization by evaluation, bounded arithmetic, universality classes, asymptotic invariants, phase transition, compression complexity, semantic normalization, sequent calculus, lower bounds, polynomial simulation, statistical physics analogy, information-theoretic proof length, formalized asymptotics

---

## Concrete Lean Engineering Guidance

You should create a file along the lines of:

```lean
/-
  ProofCompression/NormalizerInvariance.lean
-/
```

with sections:
1. `BasicDefs`
2. `PolynomialSimulation`
3. `AsymptoticBlowup`
4. `TransferTheorems`
5. `PhaseInvariance`
6. `ConcreteToyModel` (optional but highly desirable)

Prefer definitions over typeclasses at first. Keep asymptotic predicates elementary:
- quantify directly over `ℕ`,
- avoid premature abstraction over semirings,
- only move to `ℚ` or `ℝ` if essential.

Useful proof patterns:
- prove helper lemmas about `Nat.pow` monotonicity early,
- isolate all arithmetic domination statements in one section,
- use `have h1 := ...`, `have h2 := ...`, then a `calc` chain,
- for impossibility theorems, set up contradictory eventual bounds and use `by_contra`.

---

## Falsifiable Conjecture with Computational Test

### Conjecture: Bounded-calculus universality
For every bounded-depth sequent calculus `P` with two complete deterministic normalizers `N₁, N₂` satisfying polynomial mutual simulation, and every explicit family `φ : ℕ → Stmt`, the family has polynomial normalized size under `N₁` iff it has polynomial normalized size under `N₂`.

#### Clear computational refutation test
Implement:
1. Gentzen cut-elimination normalizer,
2. NbE normalizer,

for a bounded fragment with explicit proof search. Test on:
- pigeonhole-style tautology encodings,
- local-search principle encodings,
- bounded induction schemata.

Refutation criterion:
- find one family where empirical normalized size under one normalizer fits polynomial growth while the other exhibits persistent superpolynomial growth.

Support criterion:
- no such family across all tested benchmarks and size ranges.

This is falsifiable, finite, and computationally meaningful.

---

## Revolutionary Significance
If you succeed, you create the first formal infrastructure for **proof compression universality**. That would open:
- a new mathematical taxonomy of theories by normalization phase,
- a bridge between proof complexity and statistical mechanics,
- semantic invariants of proof systems independent of implementation,
- a route to theory-dependent exponents `α_T`,
- and ultimately a new language for explaining why some mathematical truths resist compression after normalization.

This is not an incremental extension. It is a claim that proof normalization has **phase structure**, and that this phase structure is an invariant of formal theories.

---

## Deliverables
1. A Lean 4 file with the new definitions and at least **3 deep theorems**.
2. Proofs avoiding trivial automation-only closure.
3. At least one theorem explicitly connecting proof normalization to another domain via a mathematically precise abstraction or analogy theorem.
4. A `FUTURE_DIRECTIONS.md` containing **3–5 falsifiable scientific hypotheses**, each with:
   - exact conjecture statement,
   - what data or formal experiment would test it,
   - what outcome would refute it.

### Required FUTURE_DIRECTIONS hypotheses
Include at least:
1. **Theory Exponent Hypothesis**: existence of a theory-specific lower-bound exponent `α_T`.
2. **Universality Class Hypothesis**: normalizers partition calculi into finitely many asymptotic universality classes.
3. **Semantic Rigidity Hypothesis**: semantic equivalence of normalization procedures implies asymptotic phase equivalence.
4. Optionally: **Entropy Law for Proofs**: normalized length behaves like a conserved information quantity up to polynomial distortion.

Be bold. Formalize the invariant before the field knows it needs one.

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

Research domain: Speculative
Research mode: prove
