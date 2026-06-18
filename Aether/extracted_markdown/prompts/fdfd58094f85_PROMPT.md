## Assignment: Conjecture 1: EML Elementary Completeness with Polynomial Size

**Mode:** prove

You are not being asked for a cosmetic extension of a compiler bound. You are being asked to formalize the first serious structural complexity theory of unary elementary real functions through a single primitive
\[
\mathrm{eml}(x,y) := \exp(x) - \log(y),
\]
with constants and field operations. The breakthrough is not merely that EML is expressive; it is that **elementary analysis may admit a canonical low-complexity basis** analogous to circuit normal forms, straight-line complexity, and proof complexity. If established cleanly in Lean, this opens a new field: **analytic expression complexity**.

Your task is to push beyond the current syntactic linear compilation bound and extract theorem-level structure that makes the polynomial-size conjecture scientifically meaningful, formally testable, and algorithmically actionable.

---

## Core Mathematical Goal

### Central Conjecture
Every unary elementary real function on its natural domain, represented by a finite expression tree over a fixed grammar of elementary operations, admits an EML-normal-form representation of size bounded by a polynomial in the original expression size.

This should be studied at three levels:

1. **Syntactic compilation:** verified translation from a source grammar into EML-only expressions.
2. **Semantic equivalence:** correctness on the natural domain.
3. **Complexity control:** explicit size bounds, ideally polynomial and not merely existential.

The current linear bound for a restricted syntactic compiler is the launchpad, not the destination. The true objective is to identify structural invariants under which semantic normalization remains polynomial.

---

## Precise Formal Targets

You should define a source grammar of unary elementary expressions and an EML target grammar. Then prove at least **3 substantial theorems** with nontrivial proof structure.

### Suggested new definitions

Define a new structure measuring analytic expression complexity and domain validity.

```lean
inductive UExpr where
  | var : UExpr
  | const : ℝ → UExpr
  | add : UExpr → UExpr → UExpr
  | sub : UExpr → UExpr → UExpr
  | mul : UExpr → UExpr → UExpr
  | div : UExpr → UExpr → UExpr
  | exp : UExpr → UExpr
  | log : UExpr → UExpr
deriving Repr, DecidableEq

inductive EMLExpr where
  | var : EMLExpr
  | const : ℝ → EMLExpr
  | add : EMLExpr → EMLExpr → EMLExpr
  | sub : EMLExpr → EMLExpr → EMLExpr
  | mul : EMLExpr → EMLExpr → EMLExpr
  | div : EMLExpr → EMLExpr → EMLExpr
  | eml : EMLExpr → EMLExpr → EMLExpr
deriving Repr, DecidableEq
```

Define:
- `size : UExpr → ℕ`, `esize : EMLExpr → ℕ`
- denotational semantics `eval : UExpr → ℝ → Option ℝ`, `eeval : EMLExpr → ℝ → Option ℝ`
- a predicate `NaturalDomain : UExpr → Set ℝ`
- a new notion of **EML-normalizability with polynomial overhead**:

```lean
def PolyBoundedEML (e : UExpr) : Prop :=
  ∃ (k C : ℕ) (t : EMLExpr),
    (∀ x y, eeval t x = some y ↔ eval e x = some y) ∧
    esize t ≤ C * (size e + 1)^k
```

Also define a structurally meaningful subclass, for example:

```lean
def LogPositiveInvariant : UExpr → Prop := ...
```

or

```lean
def EMLSafe : UExpr → Prop := ...
```

This subclass should encode expressions whose logarithmic side conditions are preserved compositionally. This is likely the right abstraction for proving nontrivial polynomial bounds.

---

## Exact Theorem Statements to Target

### Theorem 1: Verified compilation correctness
Prove a structurally recursive compiler from a source fragment into EML-only form and establish semantic correctness.

```lean
def compile : UExpr → EMLExpr := ...

theorem compile_correct
    (e : UExpr) :
    ∀ x y, eeval (compile e) x = some y ↔ eval e x = some y
```

This theorem matters because it elevates EML from an ad hoc operator to a **complete basis** for unary elementary semantics on the chosen grammar.

---

### Theorem 2: Explicit size bound for the compiler
Strengthen the current informal linear-size fact into a formal theorem with an exact constant and a proof by induction with arithmetic bookkeeping.

```lean
theorem compile_size_linear
    (e : UExpr) :
    esize (compile e) ≤ 5 * size e + 7
```

If your exact constants differ, that is fine; what matters is an explicit affine bound proved in Lean by a genuine structural argument. This theorem is the formal complexity backbone.

---

### Theorem 3: Polynomial closure under semantic normalization on a stable subclass
This is the first truly new theorem. You likely cannot prove the full conjecture in one cycle, but you can prove it on a mathematically meaningful subclass.

```lean
def normalize : EMLExpr → EMLExpr := ...

theorem normalize_correct
    (t : EMLExpr) :
    ∀ x y, eeval (normalize t) x = some y ↔ eeval t x = some y

theorem normalize_size_poly
    (t : EMLExpr) :
    EMLSafe t →
    ∃ k C : ℕ, esize (normalize t) ≤ C * (esize t + 1)^k
```

If normalization is defined on `UExpr` rather than `EMLExpr`, that is also acceptable. The point is to isolate a semantic simplifier whose blowup is provably polynomial on a nontrivial class.

---

### Theorem 4: Cross-domain theorem connecting analytic expression complexity to algebraic/circuit complexity
You must include at least one theorem that links this subject to another domain. A strong option is a straight-line/circuit interpretation.

Define a count of nonlinear transcendental gates and prove preservation or bounded distortion under compilation:

```lean
def transcendenceRank : UExpr → ℕ := ...
def emlRank : EMLExpr → ℕ := ...

theorem compile_rank_control
    (e : UExpr) :
    emlRank (compile e) ≤ transcendenceRank e + size e
```

Interpretation: EML compilation does not merely preserve semantics; it controls the **transcendental circuit complexity** of the expression. This creates a bridge to computational complexity and symbolic computation.

Alternative cross-domain theorem: relate domain predicates to semialgebraic/log-exp definability, or prove a monotonicity theorem connecting expression complexity to proof certificates in real closed/exponential fields.

---

## Lean 4 Type Signature Suggestions

You should aim for theorem signatures of roughly the following shape:

```lean
theorem compile_correct
    (e : UExpr) :
    ∀ x y : ℝ, eeval (compile e) x = some y ↔ eval e x = some y

theorem compile_size_linear
    (e : UExpr) :
    esize (compile e) ≤ 5 * size e + 7

theorem compile_preserves_domain
    (e : UExpr) :
    ∀ x, x ∈ NaturalDomain e ↔ x ∈ EMLDomain (compile e)

theorem normalize_correct
    (t : EMLExpr) :
    ∀ x y : ℝ, eeval (normalize t) x = some y ↔ eeval t x = some y

theorem normalize_size_poly
    (t : EMLExpr) :
    EMLSafe t → ∃ k C : ℕ, esize (normalize t) ≤ C * (esize t + 1)^k

theorem compile_rank_control
    (e : UExpr) :
    emlRank (compile e) ≤ transcendenceRank e + size e
```

If partial semantics via `Option ℝ` becomes cumbersome, you may instead use predicates:
```lean
def Represents (e : UExpr) (f : ℝ → ℝ) : Prop := ...
```
But partial semantics are preferable because they make domain restrictions explicit and computational.

---

## Proof Strategy Architecture

You must pursue at least 2–3 genuine proof strategies, not a single linear route.

### Strategy A: Structural recursion + domain-aware semantics
1. Define semantics via `Option ℝ`, so `log` and division failures are explicit.
2. Prove `compile_correct` by induction on expressions, with careful `rcases` on recursive hypotheses and domain side conditions.
3. Derive `compile_size_linear` by induction using `calc` chains and arithmetic lemmas.

**Why promising:** This is the most robust path in Lean. It gives exact control over syntax, semantics, and complexity simultaneously.

---

### Strategy B: Invariant-based polynomial normalization
1. Introduce a compositional safety predicate such as `EMLSafe` or `LogPositiveInvariant`.
2. Design `normalize` to share/reassociate repeated subterms or collapse obvious EML patterns.
3. Prove polynomial size bounds only on the invariant class, not globally.

**Why promising:** The full conjecture is likely false without a stability condition or DAG-sharing model. This strategy isolates the mathematically correct subclass where polynomial bounds are believable and formally provable.

---

### Strategy C: Complexity-theoretic reinterpretation
1. Define a circuit-like complexity measure: node count, transcendental depth, or transcendence rank.
2. Show that compilation to EML preserves semantics while controlling this measure.
3. Use the measure to formulate falsifiable hypotheses about when semantic simplification can or cannot remain polynomial.

**Why promising:** Even if the strongest polynomial-size theorem resists proof, this strategy yields a field-opening reframing: EML normal forms become a new complexity model for elementary analysis.

---

## Most Promising Route

The best route is **A + B together**:
- Use **Strategy A** to secure a watertight formal base: correctness, domains, explicit affine bounds.
- Then use **Strategy B** to prove the first genuinely new polynomial theorem on a stable subclass.
- Use **Strategy C** to formulate the broader conjecture in a scientifically serious way and derive computational predictions.

This layered architecture gives you theorem-level certainty now, while opening the door to a larger complexity theory later.

---

## Required Nontrivial Proof Features

Your Lean development must include at least 3 theorems proved with deep tactics such as:
- induction on syntax
- `rcases` on partial evaluation cases
- `by_contra` for domain impossibility or positivity side conditions
- `field_simp` for division semantics
- multi-step `calc` chains for size bounds
- explicit positivity/log-domain lemmas using inequalities

Do not waste theorem budget on trivial identities. Every theorem should carry conceptual weight.

---

## Cross-Domain Connections You Must Surface

This project should not remain trapped inside symbolic compilation. Explicitly connect it to at least one of the following:

1. **Computational complexity:** EML normal forms as an analytic analogue of circuit normal forms or straight-line programs.
2. **Model theory / o-minimality:** elementary real functions generated by `exp`, `log`, and field operations sit near the boundary of log-exp definability.
3. **Proof complexity / formal verification:** low-complexity normal forms create machine-checkable certificates for transcendental identities.
4. **Computer algebra:** verified expression simplification with guaranteed complexity overhead.
5. **Mathematical physics / information geometry:** `exp` and `log` are the primitive operations of entropy, partition functions, and free energy; EML may serve as a canonical language for thermodynamic observables.

A particularly bold theorem statement in prose: **EML is to unary elementary analysis what NAND is to Boolean computation, but with semantics sensitive to analytic domain geometry.**

---

## Falsifiable Conjectures for FUTURE_DIRECTIONS.md

You must include 3–5 testable scientific hypotheses. At minimum include one of the following, stated precisely.

### Hypothesis 1: Polynomial semantic normalization on positive-log-safe expressions
For every `EMLSafe` unary expression `e`, there exist universal constants `k, C` such that the verified simplifier outputs an equivalent EML expression of size at most `C (size e + 1)^k`.

**Test:** enumerate all safe expressions up to depth 10, normalize, and fit the growth of output size versus input size.

### Hypothesis 2: Necessity of sharing
Tree-based semantic normalization exhibits superpolynomial blowup on a family of iterated log-exp cancellation expressions, but DAG-based normalization restores polynomial growth.

**Test:** compare tree-size and DAG-size on recursively defined benchmark families.

### Hypothesis 3: Transcendence rank predicts simplifiability
Expressions of bounded `transcendenceRank` admit lower-degree polynomial EML normal forms than generic expressions of the same tree size.

**Test:** stratify enumerated expressions by rank and measure normalized-size exponents.

### Hypothesis 4: Domain complexity is the true obstruction
The dominant source of blowup is not the transcendental syntax itself but the complexity of positivity side conditions induced by nested logs and divisions.

**Test:** compare normalization growth with and without explicit domain guards.

These are scientifically meaningful because they can be disproven by finite experiments and guide theorem discovery.

---

## Algorithmic Deliverable

You must produce a **verified algorithm**, not just a theorem:
- a compiler `compile : UExpr → EMLExpr`
- a simplifier/normalizer `normalize`
- size-analysis functions
- an evaluator for finite testing on sampled reals or rationals where defined
- experimental infrastructure for enumerating expressions up to depth `d = 10`

The algorithm should support empirical study of the conjecture, not merely formal existence.

---

## demo.py Requirements

Your `demo.py` must:
1. Generate unary source expressions up to bounded depth.
2. Compile them to EML-only form.
3. Normalize them.
4. Compare original size, compiled size, normalized size.
5. Report candidate polynomial exponents or regressions.
6. Display explicit examples of:
   - exact cancellation
   - domain-sensitive simplification
   - cases where tree blowup appears
   - cases where sharing helps

The demo should make the conjecture experimentally alive.

---

## RESEARCH_PAPER.md Requirements

Your paper must be standalone and explain:
- the source grammar and target EML language
- semantics and natural domains
- the verified compiler
- the exact size theorems
- the invariant class where polynomial normalization is proved
- the complexity-theoretic interpretation
- experiments and the status of the global conjecture
- follow-on questions

A reader with no access to the code must still understand the mathematical discovery.

---

## ARTICLE.md Requirements

Write this in Scientific American style. The article should explain the audacious idea that **all ordinary unary formulas built from exponentials and logarithms might collapse into one primitive analytic gate without catastrophic complexity growth**. Make clear why this matters for symbolic AI, formal verification, and the future of computer algebra.

---

## Application Keywords

analytic expression complexity; elementary real functions; exp-log algebra; normal forms; formal verification; Lean 4; Mathlib; symbolic computation; transcendental circuit complexity; o-minimality; proof certificates; verified compilation; complexity-preserving normalization; expression DAGs; computational real algebra; information geometry; thermodynamic observables.

---

## Final Call to Action

Do not settle for “EML can express everything.” That is a curiosity. Prove that EML supports a **structured complexity theory**:
- exact semantic completeness,
- explicit formal size control,
- polynomial normalization on a mathematically meaningful subclass,
- and experimentally falsifiable hypotheses about the full conjecture.

Produce **all mandatory deliverables**:
1. `FUTURE_DIRECTIONS.md` with 3–5 falsifiable hypotheses and computational tests.
2. `RESEARCH_PAPER.md` as a standalone scientific document.
3. `ARTICLE.md` in accessible Scientific American style.
4. A verified algorithm/computational method.
5. `demo.py` demonstrating the result interactively.

This is the moment to turn a compiler lemma into a new research program: **the complexity theory of elementary analysis in EML normal form**.

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
