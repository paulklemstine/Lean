Soli Deo Gloria

## Assignment: Direction 2 — Logarithmic Derivative Level Bound for Pure Exponentials

**Mode:** `prove`

You are to attack a structural theorem that, if true, changes the way the Hardy/EML hierarchy interacts with asymptotic analysis:

> **Vision:** logarithmic differentiation of a *pure exponential* should be complexity-neutral.  
> If `e = exp(b)`, then passing from `e` to `logDeriv(e)` should not increase Hardy level at all.  
> This is the asymptotic analogue of a conservation law: exponentiation raises transcendence complexity, but logarithmic differentiation exactly cancels that increase.

This is not a cosmetic sharpening of an existing bound. It is a conceptual statement about **how asymptotic complexity propagates through the WKB/Riccati transform**, and it would create a bridge between the formal Hardy hierarchy and the actual analytic workflows used in semiclassical analysis, steepest descent, and transseries.

---

## Core Theorem Target

Build on:

- `Speculative/HardyHierarchy/DiffClosure.lean`
  - `logDeriv_mul_exp`
  - `depth_deriv_le`
- `Speculative/HardyHierarchy/Theorems.lean`
  - `hardyLevel_closed_under_eml`

The present catalog apparently gives a general derivative bound of the form
`depth(deriv b) ≤ depth b + 1`. Your task is to prove that for **pure exponentials** the logarithmic derivative lands back at the original level.

### Precise mathematical target

Let `b` be a positive EML expression of depth `d`. Let `e := exp(b)`. Since
\[
\frac{(e^b)'}{e^b} = b',
\]
the target statement is morally equivalent to showing that the derivative of the exponent does not exceed the original depth.

But do not leave this as a slogan. Prove explicit theorems.

---

## Required Theorems

You must prove **at least 3 nontrivial theorems**, with genuine multi-step arguments. At least one should use induction on expressions, at least one should use contradiction or case analysis (`by_contra`, `rcases`), and at least one should use a serious `calc` chain and/or algebraic simplification such as `field_simp`.

### Theorem 1: Depth-neutral logarithmic derivative for pure exponentials

A precise Lean target should look approximately like:

```lean
theorem hardyLevel_logDeriv_exp_le
  (b : PosEMLExpr) :
  hardyLevel (logDeriv (eval (PosEMLExpr.exp b))) ≤ PosEMLExpr.depth b
```

or, if the library phrases Hardy level as an existential closure property:

```lean
theorem logDeriv_exp_hardyLevel_le_depth
  (b : PosEMLExpr) :
  HardyLevelLE (logDeriv (eval (PosEMLExpr.exp b))) (PosEMLExpr.depth b)
```

If positivity/eventual nonvanishing hypotheses are required by the current API, state them explicitly:

```lean
theorem hardyLevel_logDeriv_exp_le
  (b : PosEMLExpr)
  (hpos : EventuallyPositive (eval (PosEMLExpr.exp b))) :
  hardyLevel (logDeriv (eval (PosEMLExpr.exp b))) ≤ PosEMLExpr.depth b
```

**Mathematical content:** this is the flagship theorem. It formalizes that the logarithmic derivative cancels the complexity increase from exponentiation.

### Theorem 2: Derivative does not increase depth on an exponential-safe fragment

If the full conjecture is currently too hard, carve out a **new fragment** and prove the exact depth preservation there. This is mandatory even if Theorem 1 succeeds, because it gives a reusable internal mechanism.

Define a new syntactic class, for example:

```lean
inductive ExpSafe : PosEMLExpr → Prop
| const ...
| var ...
| add ...
| sub ...
| exp ...
-- but exclude or control multiplication/division nodes if these are the true source of +1
```

or a computable predicate:

```lean
def PosEMLExpr.ExpNeutral : PosEMLExpr → Prop
```

Then prove:

```lean
theorem depth_deriv_le_of_expNeutral
  {b : PosEMLExpr} (h : b.ExpNeutral) :
  PosEMLExpr.depth (PosEMLExpr.deriv b) ≤ PosEMLExpr.depth b
```

This is an excellent induction theorem and likely the technical heart of the project.

### Theorem 3: WKB/Riccati bridge theorem

Introduce a theorem connecting the formal result to asymptotic differential equations. For instance, define a notion of a *formal Riccati transform*:

```lean
def riccatiExpr (y : PosEMLExpr) : PosEMLExpr :=
  PosEMLExpr.deriv y  -- placeholder; adapt to actual syntax/API
```

Better: define a logarithmic-derivative operator at the expression or function level and prove a complexity statement for Schrödinger/WKB ansätze of the form `y = exp b`.

A target theorem could be:

```lean
theorem hardyLevel_riccati_ansatz_le
  (b : PosEMLExpr) :
  hardyLevel ((logDeriv (eval (PosEMLExpr.exp b)))) ≤ PosEMLExpr.depth b
```

If this duplicates Theorem 1 too closely, strengthen it by showing closure under one Riccati step or by relating it to a differential identity:

```lean
theorem riccati_identity_exp
  (b : PosEMLExpr) :
  logDeriv (eval (PosEMLExpr.exp b)) = eval (PosEMLExpr.deriv b)
```

paired with

```lean
theorem hardyLevel_eval_deriv_le_depth_of_expNeutral
  {b : PosEMLExpr} (h : b.ExpNeutral) :
  hardyLevel (eval (PosEMLExpr.deriv b)) ≤ PosEMLExpr.depth b
```

This creates the explicit bridge to Riccati equations and WKB transport hierarchies.

---

## New Definition Requirement

You must introduce **at least one genuinely new concept** not already in the catalog. Recommended options:

### Option A: Exponential-neutral expressions
A syntactic fragment on which differentiation is depth-nonincreasing.

```lean
def PosEMLExpr.ExpNeutral : PosEMLExpr → Prop := ...
```

Interpretation: these are expressions whose derivative does not create new dominant asymptotic strata.

### Option B: Logarithmic-derivative stable level
A semantic property of functions/expressions:

```lean
def LogDerivLevelStable (f : ℝ → ℝ) (n : ℕ) : Prop :=
  hardyLevel f ≤ n ∧ hardyLevel (logDeriv f) ≤ n
```

Then prove that pure exponentials generated from `PosEMLExpr` satisfy this stability at the exponent depth.

### Option C: WKB-safe ansatz
A structure encapsulating expressions suitable for semiclassical exponential ansätze:

```lean
structure WKBSafe where
  phase : PosEMLExpr
  neutral_deriv : PosEMLExpr.depth (PosEMLExpr.deriv phase) ≤ PosEMLExpr.depth phase
```

This is attractive if you want the codebase to support future Riccati/WKB developments.

---

## Proof Strategy Architecture

You must not rely on a single proof path. Develop at least 2–3 proof routes and choose one as primary.

### Strategy A: Direct semantic cancellation via `logDeriv_mul_exp`
1. Use the existing theorem `logDeriv_mul_exp` to specialize to the case where the multiplicative prefactor is `1`.
2. Derive the identity
   \[
   \logDeriv(\exp(b)) = b'
   \]
   in the library’s exact function model.
3. Apply `hardyLevel_closed_under_eml` to `deriv b`, then sharpen the level bound by proving
   \[
   \mathrm{depth}(\mathrm{deriv}\, b) \le \mathrm{depth}(b)
   \]
   on the relevant fragment, or in full if possible.

**Why promising:** It maximally exploits catalog infrastructure and turns the hard analytic statement into a syntactic depth theorem.

### Strategy B: Structural induction on expressions
1. Define `ExpNeutral` (or analogous) recursively.
2. Prove by induction on `b` that if `b` is `ExpNeutral`, then `depth (deriv b) ≤ depth b`.
3. Instantiate on exponents appearing in `exp b`, obtaining the desired Hardy-level statement after evaluation.

**Why promising:** This isolates the exact combinatorial obstruction. If multiplication is the only problematic constructor, the theorem will reveal that fact sharply.

### Strategy C: Minimal-counterexample / obstruction analysis
1. Assume there exists `b` with `depth (deriv b) > depth b`.
2. Choose a minimal-depth counterexample.
3. `rcases` on the top constructor of `b`; use induction/minimality to eliminate all cases except potentially a specific obstruction (`mul`, `div`, nested exponentials, etc.).
4. Either derive a contradiction or prove a classification theorem of all obstructions.

**Why promising:** Even if the full conjecture fails, this yields a **counterexample theorem or exact obstruction theorem**, which is scientifically valuable and may be more revolutionary than a positive result.

**Most promising route:** Start with **A + B**. Use A to reduce the semantic theorem to syntax, and B to prove the syntax theorem on a maximal fragment. If B stalls, pivot to C and classify the failure mechanism. A sharp obstruction theorem is absolutely acceptable if the universal conjecture is false.

---

## Cross-Domain Connections You Must Surface

This project matters because it is not “just” a closure property.

### 1. WKB approximation
For a WKB ansatz `y = exp(S)`, one works with
\[
\frac{y'}{y} = S'.
\]
If the Hardy level of `S'` is bounded by the level of `S`, then **passing to logarithmic derivatives does not increase asymptotic complexity**. This is exactly the kind of invariant needed to formalize phase-amplitude hierarchies.

### 2. Riccati equation theory
The substitution `u = y'/y` converts linear second-order ODEs into Riccati equations. Your theorem says that the Riccati transform of a pure exponential ansatz remains within the same asymptotic complexity class. This suggests a formal complexity theory for Riccati flows.

### 3. Steepest descent / semiclassical analysis
Exponential phases dominate asymptotics. Showing that logarithmic differentiation is level-neutral means that the **phase complexity**, not the full exponential complexity, governs derivative observables. This is exactly the phenomenon behind stationary phase and steepest descent expansions.

### 4. Differential algebra / transseries
This theorem resembles a conservation principle in differential fields: exponentiation may raise rank, but logarithmic differentiation recovers the underlying differential-algebraic layer. Formalizing this in Lean could open a route toward a certified transseries complexity calculus.

Include at least one theorem statement or discussion that explicitly mentions one of these bridges.

---

## Stronger Conjectures and Falsifiable Predictions

You must include a **FUTURE_DIRECTIONS.md** with 3–5 testable hypotheses. At least one should be:

### Conjecture A (main falsifiable prediction)
For every `b : PosEMLExpr`,
```lean
PosEMLExpr.depth (PosEMLExpr.deriv b) ≤ PosEMLExpr.depth b
```
or else there exists a **minimal syntactic obstruction** characterizable by a finite set of constructors.

**Computational test:** exhaustively enumerate `PosEMLExpr` up to depth 4 or 5, compute `deriv`, and compare depths.

### Conjecture B (Riccati stability)
For every pure exponential ansatz `y = exp(b)`, repeated logarithmic differentiation does not increase Hardy level beyond `depth b`:
\[
\mathrm{hardyLevel}\big((\logDeriv)^k(\exp(b))\big) \le \mathrm{depth}(b)
\]
for all `k` for which the expression is defined.

**Test:** symbolic iteration on enumerated expressions up to depth 4.

### Conjecture C (sharp obstruction classification)
If `depth (deriv b) = depth b + 1`, then `b` must contain a specific obstruction pattern (e.g. multiplicative interaction of equal-depth dominant subexpressions).

**Test:** search for all counterexamples up to bounded depth and infer the common grammar pattern.

### Conjecture D (WKB complexity invariance)
For formal Schrödinger-type ansätze, the phase hierarchy controls all logarithmic derivative observables.

**Test:** instantiate symbolic phases `S` up to depth 4 and verify derived Riccati terms stay within predicted bounds.

---

## Lean 4 Formalization Targets

Adapt to the actual API, but aim for theorem signatures of this flavor:

```lean
theorem logDeriv_eval_exp_eq_eval_deriv
  (b : PosEMLExpr) :
  logDeriv (eval (PosEMLExpr.exp b)) = eval (PosEMLExpr.deriv b)
```

```lean
theorem depth_deriv_le_self_of_expNeutral
  {b : PosEMLExpr} (h : b.ExpNeutral) :
  PosEMLExpr.depth (PosEMLExpr.deriv b) ≤ PosEMLExpr.depth b
```

```lean
theorem hardyLevel_logDeriv_exp_le_depth
  (b : PosEMLExpr) :
  hardyLevel (logDeriv (eval (PosEMLExpr.exp b))) ≤ PosEMLExpr.depth b
```

```lean
theorem logDerivLevelStable_exp
  (b : PosEMLExpr) :
  LogDerivLevelStable (eval (PosEMLExpr.exp b)) (PosEMLExpr.depth b)
```

If exact names/types differ, preserve the mathematical quantifiers and prove the strongest faithful version available.

---

## Implementation Guidance

- Inspect the exact statement of `logDeriv_mul_exp`. There is likely a one-line specialization hidden there, but the resulting theorem should then be used in a nontrivial chain to derive the Hardy-level bound.
- Inspect how `depth_deriv_le` is proved. The place where `+1` appears may be localized to a specific constructor; isolate it.
- If multiplication is the sole obstruction, define a fragment excluding it and prove a **sharp theorem** there rather than a weak theorem everywhere.
- Prefer induction on the syntax tree over brute-force simplification.
- Use `calc` blocks to make the semantic identity legible.
- If nonvanishing/eventual positivity hypotheses are needed for `logDeriv`, prove them for `eval (exp b)` using positivity of exponentials rather than assuming them globally.

---

## Deliverables (ALL mandatory)

You must produce all of the following:

1. **Lean file(s)** with:
   - at least 3 deep theorems,
   - at least one novel definition,
   - minimized `sorry`,
   - no trivial enumeration proofs.

2. **`FUTURE_DIRECTIONS.md`**
   - 3–5 falsifiable hypotheses,
   - each with a concrete computational or formal test.

3. **`RESEARCH_PAPER.md`**
   - standalone scientific exposition,
   - explain theorem statements, proof ideas, significance, and next questions,
   - readable without access to the code.

4. **`ARTICLE.md`**
   - Scientific American style,
   - explain the ideas, why logarithmic differentiation matters, and what new science this opens,
   - do **not** focus on formal verification machinery.

5. **A verified algorithm/computational method**
   - e.g. a depth analyzer for `deriv`, an obstruction detector, or a classifier for `ExpNeutral` expressions,
   - with correctness theorem(s).

6. **`demo.py`**
   - interactively enumerate/sample `PosEMLExpr`,
   - compute depth and derivative depth,
   - test the conjectures up to user-chosen depth,
   - display whether the log-derivative bound is exact, strict, or violated.

---

## Application Keywords

Hardy hierarchy; logarithmic derivative; exponential asymptotics; WKB approximation; Riccati transform; steepest descent; semiclassical analysis; differential algebra; transseries; asymptotic complexity; symbolic differentiation; phase-amplitude decomposition; closure under differentiation; formal asymptotics; computational conjecture mining.

---

## Success Criterion

A successful outcome is not merely “another closure lemma.” It is one of the following:

- a proof that pure exponentials are **log-derivatively level-neutral**;
- or a sharp theorem identifying the maximal fragment where this neutrality holds;
- or a classification of the exact obstruction preventing it.

Any of these would be a real conceptual advance. The ideal result is a new principle:

> **Exponential complexity is not intrinsic to logarithmic observables.**

That principle would open a formal theory of asymptotic invariants for WKB, Riccati dynamics, and transseries-style differential analysis.

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
