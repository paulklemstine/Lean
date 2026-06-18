## Assignment: Direction 4: Normalizing Derivative Compiler with Improved Bounds

**Mode:** prove

Build a genuine derivative-normalization theory for the positive EML fragment, not a cosmetic simplifier. The goal is to show that differentiation is not merely *closed* in the Hardy-style expression language, but is *structurally stable after compilation*: the derivative can be normalized back into a form whose complexity does not exceed the original expression on a mathematically meaningful fragment. This is the difference between “differentiation is allowed” and “differentiation is computationally tame.”

The catalog already gives the raw closure theorem:
- `Speculative/HardyHierarchy/DiffClosure.lean`
  - `PosEMLExpr.deriv`
  - `depth_deriv_le`

Your task is to turn this into a compiler theorem: **the derivative followed by normalization has no depth blowup on a restricted but expressive fragment**.

---

## Core Breakthrough Target

Define a normalization procedure
```lean
normalize : PosEMLExpr → PosEMLExpr
```
together with a syntactic fragment predicate
```lean
Good : PosEMLExpr → Prop
```
such that:

1. **Semantic preservation**
   ```lean
   ∀ e x, PosEMLExpr.eval (normalize e) x = PosEMLExpr.eval e x
   ```

2. **Fragment stability under normalization**
   ```lean
   ∀ e, Good e → Good (normalize e)
   ```

3. **Zero-overhead differentiation on the fragment**
   ```lean
   ∀ e, Good e → PosEMLExpr.depth (normalize (PosEMLExpr.deriv e)) ≤ PosEMLExpr.depth e
   ```

This is a nontrivial strengthening of `depth_deriv_le`, which only gives a derivative-depth control before compilation. If successful, this says the symbolic derivative compiler is **complexity-nonexpansive** on a mathematically identifiable class of eventually positive expressions.

---

## Precise Theorem Statements

You should aim to formalize at least the following three theorem-level results.

### Theorem 1: Semantic correctness of normalization
Define a recursive normalizer with algebraic simplification rules, and prove:
```lean
theorem eval_normalize
    (e : PosEMLExpr) (x : ℝ) :
    PosEMLExpr.eval (normalize e) x = PosEMLExpr.eval e x
```

This theorem must not be a trivial rewrite lemma. The proof should require structural induction over `e`, with nontrivial subcases for multiplication, exponentiation, and any newly introduced smart constructors.

---

### Theorem 2: Depth nonincrease under normalization
Design `normalize` so that it is not merely semantics-preserving, but complexity-reducing:
```lean
theorem depth_normalize_le
    (e : PosEMLExpr) :
    PosEMLExpr.depth (normalize e) ≤ PosEMLExpr.depth e
```

This is the compiler invariant. If your chosen normalization rules are carefully oriented, this should be provable by induction plus local arithmetic estimates on `Nat.max`/successor structure.

---

### Theorem 3: Zero-overhead derivative theorem on a restricted fragment
Define a novel fragment predicate, for example:
- forbidding “bad” occurrences of `mul` inside the argument of `exp`,
- or requiring derivatives of exponent arguments to normalize to depth zero,
- or a recursively defined **derivative-balanced** fragment.

A possible Lean target:
```lean
def Good : PosEMLExpr → Prop := ...

theorem depth_normalize_deriv_le
    (e : PosEMLExpr) :
    Good e →
    PosEMLExpr.depth (normalize (PosEMLExpr.deriv e)) ≤ PosEMLExpr.depth e
```

This is the flagship result. It should be proved by induction on `e`, with the `exp` case using the fragment invariant to show that the derivative-produced multiplicative overhead is exactly neutralized by normalization.

---

## Strongly Recommended New Definition

You are required to introduce at least one genuinely new concept. The right one here is a syntactic invariant tailored to differentiation.

### Candidate new concept: derivative-balanced expressions
Introduce a predicate or structure expressing that exponential nodes are only allowed when their derivative normalizes to a depth-bounded form.

For example:
```lean
def DerivBalanced : PosEMLExpr → Prop
```
with recursive clauses such as:
- constants/variables are balanced,
- sums/products are balanced if components are,
- `exp a` is balanced if `a` is balanced and `depth (normalize (deriv a)) ≤ depth a - 1` or some equivalent local criterion.

Or package it as a structure:
```lean
structure NormalFormCert where
  expr : PosEMLExpr
  nf : PosEMLExpr
  sem_eq : ∀ x, PosEMLExpr.eval nf x = PosEMLExpr.eval expr x
  depth_le : PosEMLExpr.depth nf ≤ PosEMLExpr.depth expr
```

This would connect normalization with proof-carrying symbolic compilation.

---

## Lean 4 Formalization Targets

You should state the intended signatures as close as possible to the following.

```lean
def normalize : PosEMLExpr → PosEMLExpr

def Good : PosEMLExpr → Prop

theorem eval_normalize
    (e : PosEMLExpr) (x : ℝ) :
    PosEMLExpr.eval (normalize e) x = PosEMLExpr.eval e x

theorem depth_normalize_le
    (e : PosEMLExpr) :
    PosEMLExpr.depth (normalize e) ≤ PosEMLExpr.depth e

theorem good_normalize
    (e : PosEMLExpr) :
    Good e → Good (normalize e)

theorem depth_normalize_deriv_le
    (e : PosEMLExpr) :
    Good e →
    PosEMLExpr.depth (normalize (PosEMLExpr.deriv e)) ≤ PosEMLExpr.depth e
```

If the library setup permits executable reflection on expressions, also target a certified optimizer theorem:
```lean
theorem normalize_sound_complete_for_depth
    (e : PosEMLExpr) :
    PosEMLExpr.eval (normalize e) = PosEMLExpr.eval e ∧
    PosEMLExpr.depth (normalize e) ≤ PosEMLExpr.depth e
```

---

## Suggested Normalization Rules

Do not stop at constant folding. Build a principled rewrite system. At minimum consider:

1. **Multiplicative annihilation/unit**
   - `mul (const 0) e ↦ const 0`
   - `mul e (const 0) ↦ const 0`
   - `mul (const 1) e ↦ e`
   - `mul e (const 1) ↦ e`

2. **Additive simplification**
   - `add (const 0) e ↦ e`
   - `add e (const 0) ↦ e`

3. **Recursive smart constructors**
   - normalize children first, then rebuild through `mkAdd`, `mkMul`, `mkExp`

4. **Derivative-aware exp/product contraction**
   If the expression language contains enough constructors, identify the derivative pattern generated by
   `deriv (exp a) = mul (deriv a) (exp a)`
   and compile it back into a controlled form.

Even if a full logarithmic contraction is not available in the current language, you can still win by proving the theorem on a fragment where `deriv a` is shallow enough that the product node does not increase overall depth after normalization.

---

## Proof Strategy Architecture

### Strategy A: Structural compiler proof via smart constructors
**Most promising.**

1. Define normalization through smart constructors `mkAdd`, `mkMul`, maybe `mkExp`, each carrying built-in simplification.
2. Prove local lemmas:
   - semantics of each smart constructor,
   - depth bound of each smart constructor.
3. Prove global theorems by induction on `e`.

Why this is best: it modularizes the proof and avoids brittle global case explosions. It also matches how verified compilers are usually formalized.

---

### Strategy B: Relational normalization semantics
1. Define an inductive relation `NormStep : PosEMLExpr → PosEMLExpr → Prop`.
2. Prove each rewrite preserves evaluation and does not increase depth.
3. Define `normalize` as a recursively chosen normal form and lift local invariants to the final result.

Why it may help: this is stronger conceptually and can support future confluence/canonical-form theorems. But it is heavier in Lean and may slow progress.

---

### Strategy C: Local derivative-shape analysis on a fragment
1. Define `Good` so that the only potentially dangerous derivative case is `exp`.
2. Prove a local lemma for balanced exponent arguments:
   ```lean
   Good a → depth (normalize (deriv a)) ≤ depth a - 1
   ```
   or a variant sufficient to control the `mul` with `exp a`.
3. Use this local estimate inside the induction for `depth_normalize_deriv_le`.

Why this is useful: it transforms the global theorem into one sharp local combinatorial estimate. This is the right route if the unrestricted theorem is false.

---

## Deep Proof Tactics Requirement

Your file must contain at least 3 substantial theorems using real proof structure. Suitable places:

- `eval_normalize`: induction + `rcases` on normalized children + `calc`
- `depth_normalize_le`: induction + arithmetic on depth expressions + `omega`/manual `Nat` inequalities
- `depth_normalize_deriv_le`: induction, fragment inversion with `rcases`, local contradiction arguments via `by_contra` if needed
- any theorem about fragment closure under constructors
- a theorem relating normal-form shape to evaluation positivity

Use multi-step reasoning. Avoid vacuous automation.

---

## Cross-Domain Connections

This project is more than a syntax cleanup. Make the bridges explicit in the formal development and the written deliverables.

### 1. Compiler verification
`normalize` is a certified optimization pass. The theorem
```lean
eval (normalize e) = eval e
```
is a standard compiler correctness theorem, while
```lean
depth (normalize e) ≤ depth e
```
is a resource bound. This puts symbolic differentiation into the language of verified compilation and complexity-preserving program transformation.

### 2. Computer algebra / symbolic computation
The derivative compiler is a normalization engine for symbolic expressions. A successful zero-overhead theorem says that the expression swell phenomenon can be eliminated on a mathematically natural fragment.

### 3. Proof-carrying complexity
The pair “semantic preservation + structural bound” is analogous to certified cost semantics. This suggests future extraction of verified symbolic optimizers.

### 4. Dynamical systems / Hardy hierarchy
Since the underlying expressions are tied to eventually positive growth behavior, depth acts like a rank in a growth hierarchy. Showing depth stability under differentiation means the hierarchy is operationally robust under a core analytic operator.

### 5. Mathematical logic / term rewriting
A normalization system with depth monotonicity invites confluence, canonical forms, and normalization-complexity questions. This opens a route from asymptotic analysis into rewriting theory.

**Application keywords:** verified symbolic differentiation, compiler optimization, term rewriting systems, canonical forms, complexity-preserving normalization, Hardy hierarchy, proof-carrying code, computer algebra, certified simplification, asymptotic growth analysis.

---

## Falsifiable Conjecture and Computational Test

State at least one explicit conjecture with a disproof protocol.

### Conjecture A: universal zero-overhead on a balanced fragment
There exists a recursively defined fragment `Good` such that
```lean
∀ e, Good e → depth (normalize (deriv e)) ≤ depth e
```
and `Good` contains every expression up to depth 4 generated from constants, variable, `add`, `mul`, `exp`, excluding only exponent arguments containing a multiplicative node.

**Test:** enumerate all expressions up to depth 4 in the fragment; compute
```python
gap(e) = depth(normalize(deriv(e))) - depth(e)
```
and search for `gap(e) > 0`. Any counterexample refutes the chosen fragment definition.

### Conjecture B: asymptotic rarity of bad expressions
Among all expressions of depth ≤ `n`, the proportion violating
```lean
depth (normalize (deriv e)) ≤ depth e
```
tends to `0` under a natural random grammar measure.

**Test:** Monte Carlo generation by grammar depth, estimate violation frequency for `n = 2,3,4,5,6`.

This second conjecture is scientifically valuable even if the full universal theorem fails.

---

## Concrete Deliverables in Lean

You should produce a new file extending:
- `Speculative/HardyHierarchy/DiffClosure.lean`

A plausible target file:
- `Speculative/HardyHierarchy/DerivativeNormalizer.lean`

Minimum expected contents:

1. `normalize`
2. one novel structure/predicate (`Good`, `DerivBalanced`, or `NormalFormCert`)
3. at least 3 nontrivial theorem proofs
4. one cross-domain theorem or definition explicitly framed as certified optimization / complexity control
5. one executable decision or search procedure supporting the conjecture test, if feasible

---

## Research Paper Vision

If you pull this off, the result is not “we simplified some expressions.” It is:

> **Differentiation admits a certified normalization compiler that preserves semantics and eliminates structural complexity growth on a nontrivial analytic fragment.**

That is a field-opening statement because it links:
- Hardy-style growth hierarchies,
- symbolic differentiation,
- verified compilation,
- and normalization complexity.

The next step after this would be canonical forms, repeated derivative stability, and eventually a certified symbolic engine where asymptotic rank is a maintained invariant rather than an after-the-fact theorem.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **`FUTURE_DIRECTIONS.md`**
   - Include **3–5 falsifiable scientific hypotheses**
   - Each must have a clear computational or formal test that could fail

2. **`RESEARCH_PAPER.md`**
   - Standalone scientific paper
   - Must explain the theorem, proof architecture, significance, limitations, and next questions without requiring code access

3. **`ARTICLE.md`**
   - Scientific American style
   - Explain why derivative explosion is a real problem and how certified normalization changes the picture

4. **A verified algorithm or computational method**
   - Not just theorem statements
   - This should be the normalizer plus its certified invariants, or an enumerator/testing engine for the fragment

5. **`demo.py`**
   - Interactive demonstration
   - Suggested features:
     - generate expressions up to a chosen depth
     - display `e`, `deriv(e)`, `normalize(deriv(e))`
     - compute depth gaps
     - search for counterexamples to the conjectured fragment theorem

The scientific loop must be explicit: **hypothesize → enumerate/test → formalize → analyze failures → refine fragment**.

---

## Final Ambition

Do not settle for a weak theorem of the form “sometimes normalization helps.” Prove a theorem that says a carefully designed symbolic compiler enforces a complexity invariant under differentiation. That is the right level of boldness: a certified bridge between asymptotic analysis and compiler theory.

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
