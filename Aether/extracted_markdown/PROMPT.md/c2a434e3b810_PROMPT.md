## Assignment: Conjecture 5: EML Circuit Depth Separation

**Mode:** `prove`

You are not being asked for an incremental encoding result. You are being asked to formalize the first genuine **complexity-theoretic obstruction** for EML syntax: a theorem showing that expressivity equivalence does **not** imply efficient representability. The target is a lower-bound phenomenon inside a formally verified semantics of elementary expressions.

The breakthrough is to separate:

- **full elementary syntax** with primitive `exp` and `log`,
from
- **EML-only syntax** where transcendence is mediated through `eml`

at the level of **depth complexity**, not mere definability.

This would open a new field: **formal transcendence-aware circuit complexity in Lean**, linking symbolic computation, elementary function theory, and lower bounds for restricted expression languages.

---

## Core theorem target

You should define a formal expression language with two variants:

1. `FullExpr`: constants, variable, field operations, and primitive `exp`, `log`.
2. `EMLExpr`: constants, variable, field operations, and primitive `eml`.

Then define semantics over `ℝ` on the natural domain where all terms are well-defined.

The central family is the iterated exponential:
\[
E_0(x) = x,\qquad E_{n+1}(x) = \exp(E_n(x)).
\]

In full syntax, `E_n` has linear-size and linear-depth representations trivially. The nontrivial goal is to prove that in the **EML-only tree model**, every representation of `E_n` has depth bounded below by a quantity growing with `n`, ideally linearly, and at minimum logarithmically.

### Precise theorem statement

A strong theorem to aim for is:

\[
\forall n \ge 0,\ \forall e : \mathrm{EMLExpr},\ 
\big(\forall x \in D_n,\ \llbracket e \rrbracket(x)=E_n(x)\big)
\to n \le \mathrm{emlDepth}(e),
\]
for a suitable domain \(D_n\) on which all iterates are defined and all logarithmic side-conditions are discharged.

This is the cleanest “one EML layer can create at most one new exponential nest” statement.

If the full linear lower bound is too ambitious in the first pass, prove the weaker but still meaningful separation:

\[
\forall n \ge 1,\ \forall e,\ 
\big(\forall x \in D_n,\ \llbracket e \rrbracket(x)=E_n(x)\big)
\to \lceil \log_2(n+1)\rceil \le \mathrm{depth}(e).
\]

This already establishes a **depth hierarchy**.

---

## Lean 4 formalization target

You should expose the target in Lean with signatures close to the following.

```lean
inductive FullExpr where
  | var : FullExpr
  | const : ℝ → FullExpr
  | add : FullExpr → FullExpr → FullExpr
  | mul : FullExpr → FullExpr → FullExpr
  | neg : FullExpr → FullExpr
  | inv : FullExpr → FullExpr
  | exp : FullExpr → FullExpr
  | log : FullExpr → FullExpr
deriving Repr

inductive EMLExpr where
  | var : EMLExpr
  | const : ℝ → EMLExpr
  | add : EMLExpr → EMLExpr → EMLExpr
  | mul : EMLExpr → EMLExpr → EMLExpr
  | neg : EMLExpr → EMLExpr
  | inv : EMLExpr → EMLExpr
  | eml : EMLExpr → EMLExpr → EMLExpr
deriving Repr
```

Semantics should be partial or domain-indexed. If you want to avoid `Option ℝ`, use a predicate of well-formedness/domain admissibility:

```lean
def FullExpr.DefinedAt : FullExpr → ℝ → Prop := ...
def EMLExpr.DefinedAt : EMLExpr → ℝ → Prop := ...

def FullExpr.eval : FullExpr → ℝ → ℝ := ...
def EMLExpr.eval : EMLExpr → ℝ → ℝ := ...
```

Depth measures:

```lean
def EMLExpr.depth : EMLExpr → ℕ := ...
def EMLExpr.emlDepth : EMLExpr → ℕ := ...
def FullExpr.size : FullExpr → ℕ := ...
def EMLExpr.size : EMLExpr → ℕ := ...
```

Iterated exponential:

```lean
def iterExp : ℕ → ℝ → ℝ
  | 0, x => x
  | n+1, x => Real.exp (iterExp n x)
```

A candidate main theorem:

```lean
theorem emlDepth_lower_bound_iterExp
    (n : ℕ) (e : EMLExpr)
    (hrep : ∀ x > 0, EMLExpr.DefinedAt e x ∧ EMLExpr.eval e x = iterExp n x) :
    n ≤ EMLExpr.emlDepth e := by
  ...
```

If the exact semantic domain is cumbersome, use a simpler positivity domain such as `x > 0`, together with a carefully designed semantics for `eml` ensuring all intermediate terms stay positive.

A second theorem should compare the two languages:

```lean
theorem fullExpr_iterExp_has_small_depth
    (n : ℕ) :
    ∃ e : FullExpr,
      (∀ x > 0, FullExpr.DefinedAt e x ∧ FullExpr.eval e x = iterExp n x) ∧
      FullExpr.depth e ≤ n + 1 ∧
      FullExpr.size e ≤ C * n + C := by
  ...
```

Then the formal separation theorem:

```lean
theorem depth_separation_exists :
    ∃ c > 0, ∀ n : ℕ,
      ∃ fFull : FullExpr, ∀ fEML : EMLExpr,
        (represents_same_function_on_pos fFull fEML) →
        c * n ≤ EMLExpr.emlDepth fEML := by
  ...
```

If constants over `ℝ` make the statement too loose, replace `∃ c > 0` with an explicit lower bound for the family `iterExp`.

---

## New definitions you must introduce

You are required to define at least one genuinely new concept. Here are the right ones:

### 1. Exponential nesting rank
Define a semantic or syntactic invariant measuring the maximal number of iterated exponentials a term can generate.

```lean
def EMLExpr.expRank : EMLExpr → ℕ := ...
```

The intended theorem is:
- field operations do not increase `expRank` by more than `max`
- each `eml` node increases rank by at most `1`
- `iterExp n` has rank exactly `n`

This is the likely key lower-bound invariant.

### 2. Positive-domain representability
Define:
```lean
def RepresentsOnPos (e : EMLExpr) (f : ℝ → ℝ) : Prop := ...
```
and analogously for `FullExpr`. This avoids global-domain pathology from `log`.

### 3. Depth-normal EML trees
Define a predicate capturing “tree syntax without DAG sharing.” This matters because the motivating question mentions clever sharing. If your syntax is a tree, say so explicitly and prove the lower bound in the tree model. Then state a falsifiable conjecture for DAGs.

```lean
def IsTreeModel (e : EMLExpr) : Prop := True
```

Better: define a separate DAG language later, but for now clearly isolate the theorem to trees.

---

## Three theorem package you should deliver

At minimum, your Lean file must contain **at least 3 serious theorems** with nontrivial proofs.

### Theorem 1: Upper bound in full language
Formalize that `iterExp n` is representable efficiently in `FullExpr`.

Suggested statement:
```lean
theorem exists_fullExpr_iterExp
    (n : ℕ) :
    ∃ e : FullExpr,
      (∀ x > 0, FullExpr.DefinedAt e x ∧ FullExpr.eval e x = iterExp n x) ∧
      FullExpr.depth e = n ∨ FullExpr.depth e = n + 1 := by
  ...
```

This should use induction.

### Theorem 2: Structural upper bound on semantic rank
Prove a compositional theorem:
```lean
theorem expRank_le_emlDepth (e : EMLExpr) :
    e.expRank ≤ e.emlDepth := by
  ...
```

This is a deep structural induction theorem and should not collapse to simplification.

### Theorem 3: Lower bound for iterated exponentials
Prove:
```lean
theorem iterExp_requires_emlDepth
    (n : ℕ) (e : EMLExpr)
    (h : RepresentsOnPos e (iterExp n)) :
    n ≤ e.emlDepth := by
  ...
```

This is the conceptual core. It should combine a semantic characterization of `iterExp n` with Theorem 2.

### Optional Theorem 4: Cross-domain monotonicity/growth theorem
Connect to asymptotic analysis or dynamical systems:
```lean
theorem iterExp_strictMono_in_x (n : ℕ) :
    StrictMono (iterExp n) := by
  ...
```
or
```lean
theorem iterExp_eventually_dominates_polynomial
    (k : ℕ) :
    ∃ R, ∀ x ≥ R, x^k ≤ iterExp 1 x := by
  ...
```

Then use this to support a semantic invariant based on growth classes. This is your cross-domain bridge to **real asymptotic analysis / dynamical systems**.

---

## Proof strategy architecture

You must not rely on brute-force evaluation. Use one of these substantive proof paths.

### Strategy A: Syntactic rank invariant via structural induction
This is the most promising.

1. Define `expRank : EMLExpr → ℕ` so that algebraic operations combine by `max`, while `eml a b` contributes at most `max a.expRank (b.expRank + 1)` or a similarly justified rule depending on your semantic definition of `eml`.
2. Prove by induction on expressions that `expRank e ≤ emlDepth e`.
3. Prove separately that any EML term representing `iterExp n` must have `expRank ≥ n`.
4. Conclude `n ≤ emlDepth e`.

Why this is promising: lower bounds in restricted circuit classes almost always come from monotone structural invariants. This route is robust, modular, and likely formalizable in Lean without measure-theoretic overhead.

### Strategy B: Growth hierarchy / Hardy-style asymptotics
Potentially revolutionary if you can make it work.

1. Define a preorder on positive functions by eventual domination.
2. Show that field operations preserve a bounded growth class, while each `eml` layer raises the growth class by at most one.
3. Show `iterExp n` occupies exactly level `n` of this hierarchy.
4. Infer a depth lower bound from eventual-growth complexity.

Why this is exciting: it connects EML complexity to **asymptotic differential algebra** and **Hardy-field ideas**. Even a partial formalization here would be field-opening.

### Strategy C: Derivative-chain or logarithmic derivative invariant
A more analytic route.

1. Define an invariant on positive functions based on how many iterations of `log ∘ f` are needed to reduce growth to algebraic scale.
2. Prove that one `eml` node can increase this “logarithmic height” by at most one.
3. Show `iterExp n` has logarithmic height exactly `n`.
4. Deduce the lower bound.

Why this is valuable: it connects circuit depth to **analytic complexity** and may generalize beyond iterated exponentials.

**Recommendation:** Start with Strategy A, then formulate B or C as future hypotheses if full formalization is too heavy.

---

## Cross-domain connections you must make explicit

This project becomes paradigm-shifting only if you position it beyond syntax engineering.

### 1. Algebraic circuit complexity
Your theorem is an analogue of restricted-basis depth lower bounds. The EML basis is not merely another function set: it is a **transcendence-generating gate basis**. A lower bound here is a new kind of circuit complexity theorem.

### 2. Hardy fields / asymptotic analysis
Iterated exponentials form a canonical growth hierarchy. If EML-depth corresponds to growth rank, you are building a bridge between **symbolic expression complexity** and **asymptotic differential algebra**.

### 3. Dynamical systems / iterated maps
The family `iterExp n` is an orbit under the dynamical system \(T(f)=\exp \circ f\). Depth lower bounds become orbit-complexity lower bounds.

### 4. Theoretical computer science / proof complexity
Formal lower bounds inside Lean are rare and valuable. This would be a machine-checked example of a nontrivial restricted-model lower bound for transcendental computation.

### 5. Mathematical physics keyword bridge
Nested exponentials govern partition functions, renormalization ansätze, and tower-scale phenomena. An EML-depth hierarchy suggests a complexity stratification for symbolic models of multiscale systems.

---

## Application keywords

Include these explicitly in your paper and article:

**algebraic circuit complexity, transcendence complexity, iterated exponentials, Hardy hierarchy, symbolic computation, proof assistant verification, restricted-basis lower bounds, asymptotic growth classes, dynamical systems, formalized complexity theory**

---

## Falsifiable conjectures and computational tests

You must include at least one explicit falsifiable conjecture with a test. Better: include 3–5 in `FUTURE_DIRECTIONS.md`.

### Conjecture A: Linear lower bound in the tree model
For every `n`, every EML tree representing `iterExp n` has `emlDepth ≥ n`.

**Test:** exhaustive generation of all EML trees up to depth `d < n` over a bounded constant set; reject the conjecture if any term matches `iterExp n` numerically on a sufficiently rich sample grid and then symbolically on derivative signatures.

### Conjecture B: Logarithmic lower bound in the DAG model
If sharing is allowed, the minimum DAG-depth for `iterExp n` is still `Ω(log n)`.

**Test:** implement DAG search with common-subexpression sharing and compare empirical minimum depth for small `n`.

### Conjecture C: Growth-rank completeness
`expRank` exactly characterizes eventual-growth level of positive EML-definable functions.

**Test:** enumerate small expressions, estimate asymptotic class numerically, compare with computed `expRank`.

### Conjecture D: No polynomial-size collapse from full syntax to bounded-depth EML
There is no uniform compilation from `FullExpr` to bounded-depth `EMLExpr` preserving semantics and polynomial size.

**Test:** compile benchmark families (`iterExp`, mixed `log-exp` towers, inverse towers), fit empirical lower bounds.

---

## Deliverables you must produce

You must produce **all** of the following:

1. **Lean file(s)** with:
   - the new syntax definitions,
   - semantics,
   - size/depth measures,
   - at least 3 nontrivial theorem proofs using induction / `rcases` / `by_contra` / `field_simp` / multi-step `calc`,
   - minimized `sorry`.

2. **`FUTURE_DIRECTIONS.md`**
   - 3–5 falsifiable scientific hypotheses,
   - each with a clear computational or formal test.

3. **`RESEARCH_PAPER.md`**
   - standalone scientific exposition,
   - precise theorem statements,
   - proof ideas,
   - significance,
   - limitations,
   - next-step program.

4. **`ARTICLE.md`**
   - Scientific American style,
   - explain why “equal expressive power” can hide deep complexity gaps.

5. **A verified algorithm or computational method**
   - e.g. a certified `expRank` calculator, a depth lower-bound checker, or a representation search procedure with proved soundness.

6. **`demo.py`**
   - interactively constructs `iterExp n`,
   - compares full-expression depth vs EML depth lower bound,
   - optionally searches small EML trees/DAGs and visualizes the gap.

---

## Suggested file architecture

A clean organization would be:

- `EML/Complexity/Syntax.lean`
- `EML/Complexity/Semantics.lean`
- `EML/Complexity/Depth.lean`
- `EML/Complexity/IterExp.lean`
- `EML/Complexity/LowerBound.lean`

If there are relevant catalog files about EML semantics, expression evaluation, or equivalence to `exp/log`, build directly on them rather than redefining semantic facts from scratch. In particular, if the catalog already proves the semantic identity expressing `exp` or `log` through `eml`, import that result and use it to justify the representability comparison theorem. If the theorem list is truncated in the prompt, inspect the catalog and cite exact theorem names in comments and the paper.

---

## What would count as a breakthrough

A mere encoding of `exp` by `eml` is not enough. A true success is one of:

1. A formal theorem that `iterExp n` requires EML depth at least `n`.
2. A weaker but rigorous lower bound `Ω(log n)` together with a principled invariant.
3. A new invariant (`expRank`, logarithmic height, growth level) that is proved sound and appears capable of generating many future lower bounds.

If you achieve (1), you have created a new formalized lower-bound theory for transcendental expression languages. If you achieve (2) plus a compelling invariant and computational evidence, you have opened the program. If you achieve (3), you have supplied the conceptual machine that future cycles can weaponize.

Do not aim small. Formalize the obstruction, not just the syntax.

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
