## Assignment: Direction 3: Differential Closure Under Quotients

**Mode:** prove

Build the missing quotient theory for the PosEML/Hardy hierarchy interface, and do it in a way that upgrades the fragment from a merely differential-ring-like object into the first certified step toward a **formal Hardy differential field**. This is not a local patch. If you succeed, you create the algebraic doorway from expression-level asymptotics to the transseries worldview of Aschenbrenner–van den Dries–van der Hoeven.

## Core Vision

The present catalog already controls differentiation and Hardy-level growth for the additive/multiplicative/exponential-logarithmic fragment. What is missing is the theorem that asymptotically nonvanishing denominators do not destroy the hierarchy under differentiation. In classical Hardy-field theory this is routine in prose; in Lean, this is the structural theorem that turns a syntactic fragment into a mathematically serious asymptotic field.

You should aim to prove a theorem of the following shape:

> If `a` and `b` are eventually positive PosEML expressions of depth at most `d`, and `b` is eventually nonzero, then the derivative of the quotient `a / b` has Hardy level at most `d + 1`.

But do not stop at the headline. Package the result as a small theory of **asymptotically admissible quotients**, with at least one new definition and at least three nontrivial theorems.

---

## Precise Theorem Targets

### New definition
Introduce a notion capturing when a denominator is asymptotically legal for quotient differentiation.

Suggested definition:
```lean
def EventuallyNonzero (f : ℝ → ℝ) : Prop :=
  ∃ X : ℝ, ∀ x ≥ X, f x ≠ 0
```

If you work syntactically with expressions:
```lean
def PosEMLExpr.EventuallyNonzero (e : PosEMLExpr) : Prop :=
  ∃ X : ℝ, ∀ x ≥ X, eval e x ≠ 0
```

Even better, define a quotient-admissibility structure:
```lean
structure QuotientAdmissible (a b : PosEMLExpr) : Prop where
  eventuallyPos_a : ∃ X, ∀ x ≥ X, 0 < eval a x
  eventuallyPos_b : ∃ X, ∀ x ≥ X, 0 < eval b x
  eventuallyNonzero_b : ∃ X, ∀ x ≥ X, eval b x ≠ 0
```

This is mathematically meaningful and genuinely new relative to the current catalog.

---

### Theorem 1: denominator powers preserve Hardy level
This is the technical lemma that makes the quotient rule usable.

```lean
theorem hardyLevel_pow_two
    (b : PosEMLExpr) (d : ℕ)
    (hb : hardyLevel b ≤ d) :
    hardyLevel (b * b) ≤ d := by
  ...
```

If multiplication only gives a weaker bound already in the catalog, formulate the exact strongest theorem available for `b²`, possibly as `≤ d` or `≤ max d d`, then simplify with arithmetic. This should not be trivial: use catalog closure results and a real proof chain.

A semantic version may also be needed:
```lean
theorem HardyLevel.closed_under_square
    {f : ℝ → ℝ} {d : ℕ}
    (hf : HardyLevel f d) :
    HardyLevel (fun x => f x ^ 2) d := by
  ...
```

---

### Theorem 2: quotient-rule numerator stays within level `d + 1`
Formalize the numerator control:
\[
a'b - ab'
\]
has level at most `d + 1` if `a,b` have level at most `d`.

```lean
theorem hardyLevel_quotient_numerator_le
    (a b : PosEMLExpr) (d : ℕ)
    (ha : hardyLevel a ≤ d)
    (hb : hardyLevel b ≤ d) :
    hardyLevel (derivExpr a * b - a * derivExpr b) ≤ d + 1 := by
  ...
```

This theorem should explicitly use:
- derivative bound from `Speculative/HardyHierarchy/DiffClosure.lean`
- closure under multiplication/addition from the current Hardy hierarchy library
- monotonicity from `Speculative/HardyHierarchy/Theorems.lean`

This is already mathematically nontrivial and should require multi-step `calc`, monotonicity, and closure chaining.

---

### Theorem 3: differential closure under asymptotically admissible quotients
This is the flagship theorem.

A semantic version is likely the most robust:
```lean
theorem hardyLevel_deriv_div_le_succ
    {f g : ℝ → ℝ} {d : ℕ}
    (hf : HardyLevel f d)
    (hg : HardyLevel g d)
    (hgz : EventuallyNonzero g)
    (hderiv : deriv (fun x => f x / g x) =
      fun x => (deriv f x * g x - f x * deriv g x) / (g x)^2) :
    HardyLevel (deriv (fun x => f x / g x)) (d + 1) := by
  ...
```

If the quotient rule is already available analytically in Mathlib, use it instead of assuming `hderiv`. If not, prove a local theorem with sufficient differentiability hypotheses.

A syntactic version is even more ambitious:
```lean
theorem PosEMLExpr.hardyLevel_deriv_div_le_succ
    (a b : PosEMLExpr) (d : ℕ)
    (ha : hardyLevel a ≤ d)
    (hb : hardyLevel b ≤ d)
    (hbnz : b.EventuallyNonzero) :
    hardyLevelOfFun (fun x => deriv (fun y => eval a y / eval b y) x) ≤ d + 1 := by
  ...
```

If a direct expression constructor `div` is introduced, target:
```lean
theorem hardyLevel_deriv_divExpr_le_succ
    (a b : PosEMLExpr) (d : ℕ)
    (ha : hardyLevel a ≤ d)
    (hb : hardyLevel b ≤ d)
    (hbnz : b.EventuallyNonzero) :
    hardyLevel (derivExpr (divExpr a b)) ≤ d + 1 := by
  ...
```

This is the theorem that matters. State it with the strongest hypotheses you can actually discharge.

---

## Lean 4 File/Placement Target

Primary file to extend:
- `Speculative/HardyHierarchy/DiffClosure.lean`

Likely supporting lemmas in:
- `Speculative/HardyHierarchy/Theorems.lean`

Use and explicitly cite:
- `DiffClosedFragment`
- `hardyLevel_deriv_le_succ`
- `hardyLevel_closed_under_eml`
- `hardyLevel_mono`

If there are existing multiplication/addition closure lemmas, thread them into the proof architecture rather than reproving them.

---

## Proof Architecture: 3 viable strategies

### Strategy A: Syntactic quotient extension of `PosEMLExpr`
Add a `div` constructor or `inv` constructor, define evaluation and derivative syntactically, then prove level bounds by structural recursion.

**Steps**
1. Extend the syntax with `inv` or `div`, together with an eventual-nonzero side condition.
2. Prove `hardyLevel_inv_le` or at least `hardyLevel_div_le` under eventual nonvanishing.
3. Deduce the derivative theorem by the quotient rule at the syntax level.

**Why this is revolutionary**
This gives a true expression language for asymptotic differential algebra, not just a semantic afterthought. It is the strongest long-term foundation.

**Risk**
This may require redesigning existing positivity and closure lemmas.

---

### Strategy B: Semantic domination argument via eventual comparability
Do not add division to the syntax immediately. Instead prove a semantic theorem:

> If `g` has level `≤ d` and is eventually nonzero/positive, then multiplication by `1/g` does not increase Hardy level.

**Steps**
1. Define `EventuallyNonzero` and prove eventual positivity implies eventual nonzero.
2. Prove a semantic lemma that `x ↦ 1 / g x` is controlled at level `d` or at worst does not raise the level when multiplied into a level-`d+1` numerator.
3. Combine with the quotient-rule numerator theorem.

**Why this is most promising**
It minimizes changes to the syntax, uses existing catalog theorems directly, and isolates the genuinely hard issue in one semantic domination lemma. This is the best route if you want a breakthrough theorem quickly with minimal infrastructure debt.

---

### Strategy C: Differential-field fragment via localization
Reinterpret the construction categorically/algebraically: localize the differential ring at the multiplicative set of eventually positive expressions.

**Steps**
1. Define the multiplicative set of eventually nonzero expressions.
2. Show the derivative respects equivalence classes in the localization.
3. Prove the localized object inherits the Hardy-level filtration with derivative raising degree by at most one.

**Why this matters**
This is the conceptually deepest route. It identifies the right algebraic object: a filtered differential localization of the PosEML fragment.

**Risk**
Heavier formal overhead; likely harder in Lean unless quotient/localization infrastructure is already nearby.

**Recommendation**
Start with **Strategy B**, then, if the semantic theorem stabilizes, refactor toward **Strategy C** in a second pass.

---

## Required Deep Proof Tactics

Your file must contain at least 3 substantial theorems whose proofs genuinely use nontrivial Lean reasoning, not automation-only closure. Specifically aim to use:

- `induction` for structural recursion on expressions if you add syntax
- `rcases` to unpack eventual positivity/nonvanishing witnesses
- `by_contra` to prove impossibility of asymptotic vanishing under positivity assumptions
- `field_simp` in quotient-rule algebraic normalization
- multi-step `calc` blocks to chain Hardy-level bounds and monotonicity

A good flagship proof should visibly combine at least three of these.

---

## Cross-Domain Connections

Do not leave this as a narrow asymptotics result. Include at least one theorem or discussion node connecting to another domain.

### Bridge 1: Differential algebra
This result is the formal precursor to constructing a **Hardy differential field**. Once quotients are controlled, you can ask for logarithmic derivatives, Riccati equations, and Liouville-style closure phenomena.

### Bridge 2: Padé approximation / asymptotic numerics
Rational combinations of asymptotic germs are the native language of Padé approximants. A certified theorem that quotient differentiation preserves Hardy level is exactly the structural invariant needed to reason about symbolic asymptotic compression.

Possible theorem/discussion target:
```lean
-- schematic
theorem logarithmicDerivative_level_bound
    (b : PosEMLExpr) (d : ℕ)
    (hb : hardyLevel b ≤ d)
    (hbnz : b.EventuallyNonzero) :
    hardyLevelOfFun (fun x => deriv (eval b) x / eval b x) ≤ d + 1 := by
  ...
```
This connects quotient closure to logarithmic derivatives, a central object in differential algebra and asymptotic analysis.

### Bridge 3: Mathematical physics / WKB analysis
Quotients and logarithmic derivatives encode phase-amplitude reductions in WKB and semiclassical ODEs. Formal Hardy control of `b'/b` is the first step toward certifying asymptotic expansions of Schrödinger-type equations.

### Bridge 4: Transseries
This is the direct formal precursor to filtered differential-field embeddings into transseries-like structures. Mention Aschenbrenner–van den Dries–van der Hoeven explicitly in the paper.

---

## Concrete Build on Catalog Theorems

You must explicitly leverage:

- `Speculative/HardyHierarchy/DiffClosure.lean`
  - `DiffClosedFragment`
  - `hardyLevel_deriv_le_succ`

Use `hardyLevel_deriv_le_succ` on both `a` and `b` to control `a'` and `b'`, then use multiplication closure to place `a'b` and `ab'` in level `d+1`.

- `Speculative/HardyHierarchy/Theorems.lean`
  - `hardyLevel_closed_under_eml`
  - `hardyLevel_mono`

Use `hardyLevel_mono` to lift lower-level factors into a common ambient level `d+1` before applying additive closure. Use `hardyLevel_closed_under_eml` to avoid reproving closure facts for composed EML fragments.

The critical missing lemma is not the numerator bound; it is the denominator-inversion/division control. Isolate that lemma cleanly.

---

## Suggested Theorem Sequence

1. `eventuallyPos_imp_eventuallyNonzero`
2. `hardyLevel_quotient_numerator_le`
3. `hardyLevel_div_by_square_preserves`
4. `hardyLevel_deriv_div_le_succ`

If possible, add a fifth theorem:
5. `hardyLevel_logDeriv_le_succ`

This fifth theorem would be a striking cross-domain bridge.

---

## Falsifiable Conjecture with Computational Test

### Conjecture
For every pair of PosEML expressions `a, b` of depth at most `d ≤ 3` such that `b` is eventually positive, the quotient-rule derivative
\[
\frac{a'b - ab'}{b^2}
\]
admits a Hardy-level certificate at level at most `d + 1`, and this bound is sharp for a family involving nested exponentials/logarithms.

### Clear computational test
Extend the expression enumerator to generate all `a, b` up to depth 3, filter by numerical eventual positivity/nonvanishing on a large grid, compute:
- `a'`
- `b'`
- `(a'b - ab') / b^2`

Then attempt to fit or certify each result against the library’s Hardy-level predicates/bounds. A counterexample is any pair where numerical growth eventually dominates every candidate level-`d+1` comparator from the fragment.

This conjecture is falsifiable: one explicit enumerated pair with persistent super-`d+1` growth disproves it.

---

## Deliverables You MUST produce

1. **Lean implementation**
   - At least 3 nontrivial theorems
   - At least 1 genuinely new definition
   - Minimal `sorry`
   - Proofs using deep tactics, not trivial automation

2. **FUTURE_DIRECTIONS.md**
   Include 3–5 falsifiable scientific hypotheses. Examples:
   - Hypothesis 1: logarithmic derivatives of eventually positive depth-`d` expressions always have Hardy level `≤ d+1`.
   - Hypothesis 2: localization of `DiffClosedFragment` at eventually nonzero elements yields a filtered differential field.
   - Hypothesis 3: the `d+1` bound is sharp on an infinite family built from iterated exponentials/logarithms.
   - Hypothesis 4: every quotient of same-level expressions has an asymptotic normal form representable by an extended PosEML syntax with `inv`.
   Each must include a computational or formal test that could fail.

3. **RESEARCH_PAPER.md**
   A standalone scientific paper explaining:
   - the problem,
   - exact formal statements,
   - proof ideas,
   - relation to Hardy fields and transseries,
   - what the new quotient theorem unlocks.

4. **ARTICLE.md**
   Scientific American style. Explain why “division is the missing law of asymptotic calculus” and why formalizing it matters for symbolic science.

5. **Verified algorithm / computational method**
   Implement an algorithm that:
   - enumerates quotient candidates,
   - checks eventual nonvanishing numerically,
   - computes quotient-rule derivatives,
   - attempts Hardy-level certification.

6. **demo.py**
   Interactive script showing sampled pairs `(a, b)`, their quotient derivatives, estimated growth level, and any candidate counterexamples.

---

## Application Keywords

Hardy fields; differential algebra; filtered differential fields; asymptotic analysis; transseries; logarithmic derivative; Padé approximation; symbolic asymptotics; localization; quotient rule certification; WKB analysis; formal verification; Lean 4; Mathlib.

---

## Standard of Success

Success is not “we proved a quotient lemma.” Success is:

- the fragment now behaves like a **localized differential asymptotic algebra**,
- the derivative of quotients is formally controlled,
- logarithmic derivatives become accessible,
- and the door opens to formal transseries-style mathematics in Lean.

That is a field-opening result, not an incremental patch.

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
