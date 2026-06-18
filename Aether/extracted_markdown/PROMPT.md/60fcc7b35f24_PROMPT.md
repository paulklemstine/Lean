## Assignment: Conjecture E: No Polynomial-Size Compilation from Full to Bounded-Depth EML

You are not being asked for a routine lower-bound toy lemma. You are being asked to carve out a genuine complexity theory for expressive mathematical languages inside Lean 4: a formal barrier theorem showing that unrestricted compositional growth in `FullExpr` cannot be uniformly compressed into bounded-depth `EMLExpr` without catastrophic size blowup. If this lands, it opens a new line of **semantic circuit complexity for exact transcendental expression languages**.

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.
2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, `rcases`, `by_contra`, `field_simp`, or multi-step `calc` reasoning.
3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog. Check the catalog references to confirm novelty.
4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain.
5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

## Research Direction

### Core conjectural program
**Conjecture:** There is no uniform polynomial-size compilation from `FullExpr` to `EMLExpr` that preserves semantics and keeps `emlDepth` bounded by any fixed constant.

This is the expression-language analogue of bounded-depth circuit lower bounds, but with a semantic target rich enough to encode iterated exponentials and logarithmic structure. The breakthrough is not merely “another lower bound”; it is the creation of a **depth hierarchy for exact symbolic-semantic models**.

---

## Precise theorem target

The fully general conjecture is probably beyond a first Lean formalization. So aim for a **layered breakthrough**: formalize and prove strong conditional and unconditional obstruction theorems that together make the conjecture scientifically sharp.

### Theorem Target A: Depth-bounded asymptotic growth obstruction
Define a semantic invariant `growthRank : EMLExpr → ℕ` for bounded-depth EML expressions, intended to upper-bound the number of iterated-exponential layers realizable at infinity.

Prove that bounded depth controls growth rank.

**Mathematical statement:**
For every fixed depth bound `D`, there exists `R(D) : ℕ` such that for every `e : EMLExpr`,
if `e.emlDepth ≤ D`, then `growthRank e ≤ R(D)`.

Then prove that the iterated exponential family has unbounded rank:

For `iterExp : ℕ → ℝ → ℝ` given by
- `iterExp 0 x = x`
- `iterExp (n+1) x = Real.exp (iterExp n x)`

and corresponding `fullExprIterExp : ℕ → FullExpr`,
one has:
for every `n`, any `EMLExpr` semantically equal to `fullExprIterExp n` on `(0, ∞)` must satisfy `growthRank e' ≥ n`.

Combining these yields:

### Breakthrough theorem
For every `D : ℕ`, there exists `N : ℕ` such that for all `n ≥ N`,
there is no `e' : EMLExpr` with
- `e'.emlDepth ≤ D`, and
- `∀ x > 0, EMLExpr.eval e' x = FullExpr.eval (fullExprIterExp n) x`.

This is already a true **non-compilability theorem**, even before quantitative size lower bounds.

---

## Lean 4 formalization target

You should state at least one theorem with an explicit Lean 4 type signature in the file. A suggested target:

```lean
def SemanticallyEquivalentOnPos (e' : EMLExpr) (e : FullExpr) : Prop :=
  ∀ x : ℝ, 0 < x → EMLExpr.eval e' x = FullExpr.eval e x

def EventuallyDominates (f g : ℝ → ℝ) : Prop :=
  ∃ X : ℝ, ∀ x ≥ X, g x ≤ f x

def IterExp : ℕ → ℝ → ℝ
| 0 => fun x => x
| n+1 => fun x => Real.exp (IterExp n x)

def HasGrowthRankAtLeast (f : ℝ → ℝ) (k : ℕ) : Prop :=
  ∃ C > 0, EventuallyDominates f (fun x => IterExp k (C * x))

theorem no_bounded_depth_exact_representation_of_iterExp
    (D : ℕ) :
    ∃ N : ℕ, ∀ n ≥ N,
      ¬ ∃ e' : EMLExpr,
          e'.emlDepth ≤ D ∧
          SemanticallyEquivalentOnPos e' (fullExprIterExp n) := by
  sorry
```

If the exact semantic libraries around `FullExpr.eval`, `EMLExpr.eval`, and `fullExprIterExp` differ, adapt the signature, but keep the theorem at this level of precision.

---

## Stronger quantitative target

If you can formalize a notion of **minimal bounded-depth representation size**, define:

```lean
def MinSizeAtDepth (D : ℕ) (e : FullExpr) : ℕ :=
  sInf {m | ∃ e' : EMLExpr, e'.emlDepth ≤ D ∧ e'.size = m ∧ SemanticallyEquivalentOnPos e' e}
```

Then prove any nontrivial lower bound of the form:

```lean
theorem minSizeAtDepth_iterExp_lower_bound
    (D : ℕ) :
    ∃ c > 1, ∃ N : ℕ, ∀ n ≥ N,
      c ^ n ≤ MinSizeAtDepth D (fullExprIterExp n) := by
  sorry
```

If this exact exponential lower bound is too ambitious, prove a weaker but still meaningful theorem:
- monotone divergence: `∀ D, Tendsto ... = ∞`,
- or “not polynomially bounded” stated via domination by every polynomial eventually.

Even a conditional theorem is valuable if the hypothesis is a clearly formalized combinatorial property of bounded-depth EML normal forms.

---

## Recommended new definitions

You must introduce at least one genuinely new concept. Here are high-value candidates.

### 1. `growthRank`
A semantic complexity invariant measuring how many nested exponentials a function asymptotically dominates or requires.

Possible design:
- syntactic upper bound on EML terms by recursion;
- semantic lower bound on functions by eventual domination;
- prove soundness: syntactic rank bounds semantic rank.

### 2. `AsymptoticProfile`
A structure packaging eventual positivity, monotonicity, and comparison class.

```lean
structure AsymptoticProfile where
  f : ℝ → ℝ
  eventually_pos : ∃ X, ∀ x ≥ X, 0 < f x
  eventually_monotone : ∃ X, MonotoneOn f (Set.Ici X)
```

Then define profile morphisms induced by `exp`, multiplication, addition, etc.

### 3. `DepthSensitiveNormalForm`
A normal form for `EMLExpr` exposing alternation of additive/multiplicative/exponential layers, designed to prove upper bounds on asymptotic rank.

This would be especially strong if catalog theorems already contain simplification/normalization lemmas for EML.

---

## 2–3 proof strategy paths

### Strategy A: Asymptotic rank invariant via eventual domination
**Most promising.**

1. **Define a semantic invariant** `growthRank` or `HasGrowthRankAtLeast`.
   Show by induction on `EMLExpr` that depth-`D` terms have rank at most `R(D)`.
   This should use structural recursion and asymptotic closure lemmas:
   - sums preserve max-rank,
   - products preserve max-rank up to additive constants in the exponent scale,
   - bounded-depth exponentiation increases rank by at most 1.

2. **Prove iterated exponentials realize exact rank.**
   Show `IterExp (n+1)` eventually dominates every scalar multiple/composition built from lower-rank classes.
   This is where `calc`, monotonicity of `Real.exp`, and contradiction arguments should appear.

3. **Conclude non-representability.**
   If a depth-`D` EML expression represented `iterExp n` for large `n`, semantic equivalence would force incompatible rank bounds.

**Why this is strongest:** it gives a conceptual obstruction, not just an ad hoc family-specific argument. It creates a reusable language for future lower bounds.

---

### Strategy B: Derivative-growth hierarchy
Connect bounded depth to bounded complexity of logarithmic derivatives or iterated logarithms.

1. Define an invariant based on repeated application of `log ∘ log ∘ ...` to the function.
2. Show bounded-depth EML expressions admit a bounded “logarithmic flattening complexity.”
3. Prove `iterExp n` requires at least `n` flattening steps.

This is more analytic and may exploit available `Real.exp`, `Real.log`, monotonicity, differentiability, and asymptotic lemmas from Mathlib.

**Why it may work:** iterated exp/log are naturally dual, and EML likely already has logarithmic semantics.  
**Risk:** derivative/asymptotic infrastructure may be heavier than needed.

---

### Strategy C: Finite-grid distinguishability + counting argument
A combinatorial surrogate for full semantic lower bounds.

1. Restrict to a finite sample set `S_n ⊂ (0,∞)`.
2. Prove the family `{fullExprIterExp n}` induces pairwise distinguishable growth patterns on `S_n`.
3. Bound the number of distinct sample behaviors realizable by depth-`D`, size-`m` EML expressions.
4. Deduce that exact representation requires `m` to grow rapidly.

**Why valuable:** even if exact asymptotic lower bounds are hard, this yields a verified algorithmic lower-bound framework and directly supports `demo.py`.
**Risk:** it may prove only sample-complexity lower bounds unless carefully lifted.

---

## Concrete theorem menu: produce at least 3 deep theorems

You must prove at least three substantial theorems. Suggested package:

### Theorem 1: Bounded depth implies bounded growth rank
```lean
theorem growthRank_le_of_emlDepth_le
    {e : EMLExpr} {D : ℕ}
    (hD : e.emlDepth ≤ D) :
    growthRank e ≤ depthRankBound D := by
  sorry
```
Expected proof style: induction on `e`, `rcases` on constructors, multi-step `calc`.

### Theorem 2: Iterated exponentials force increasing rank
```lean
theorem growthRank_fullExprIterExp_ge
    (n : ℕ) :
    HasGrowthRankAtLeast (FullExpr.eval (fullExprIterExp n)) n := by
  sorry
```
Expected proof style: induction on `n`, monotonicity of `Real.exp`, eventual domination lemmas.

### Theorem 3: No exact bounded-depth representation for sufficiently high iterated exp
```lean
theorem no_exact_eml_of_bounded_depth_for_large_iterExp
    (D : ℕ) :
    ∃ N, ∀ n ≥ N,
      ¬ ∃ e' : EMLExpr,
          e'.emlDepth ≤ D ∧
          SemanticallyEquivalentOnPos e' (fullExprIterExp n) := by
  sorry
```
Expected proof style: `by_contra`, extract rank contradiction from Theorems 1 and 2.

### Optional Theorem 4: Cross-domain theorem via circuit complexity analogy
Formalize a theorem saying that if a uniform bounded-depth exact compiler existed, then the growth-rank hierarchy would collapse. This is a semantic analogue of `AC⁰` hierarchy collapse implications.

---

## Cross-domain connections you must exploit

This project becomes field-opening only if you make the bridge explicit.

### 1. Complexity theory
Interpret `EMLExpr` as a semantic circuit class:
- `emlDepth` ↔ circuit depth,
- `size` ↔ circuit size,
- exact semantic equivalence ↔ functional equality,
- iterated exponentials ↔ hierarchy-separating hard functions.

This is the right language for the paper: **exact real-function circuit lower bounds**.

### 2. Asymptotic analysis / Hardy hierarchy
Your `growthRank` should be explicitly compared to classical growth hierarchies:
- Hardy hierarchy,
- Grzegorczyk-style growth classes,
- logarithmico-exponential comparability.

Even if not all are formalized, the conceptual bridge matters. You are effectively showing that bounded-depth EML occupies a low stratum in an asymptotic hierarchy.

### 3. Proof theory / implicit computational complexity
A bounded-depth compilation theorem would amount to a collapse in expressivity. Showing impossibility aligns with stratified systems where syntax depth controls computational power.

### 4. Dynamical systems / renormalization viewpoint
Iterated exponential is an orbit under repeated application of `exp`. Bounded-depth EML cannot encode arbitrary orbit height without size explosion. This gives a dynamical interpretation of expression complexity.

---

## Application keywords

Include these explicitly in `RESEARCH_PAPER.md`, `ARTICLE.md`, comments, and theorem discussions:

**application keywords:** exact symbolic compilation, bounded-depth circuit lower bounds, semantic complexity, asymptotic hierarchy, iterated exponentials, expression compression limits, proof-theoretic stratification, real-function complexity, Hardy hierarchy, formalized lower bounds, compiler impossibility, symbolic AI, mechanized complexity theory.

---

## Computational experiment and falsifiable conjecture

You must state a falsifiable conjecture and support it with a verified search procedure.

### Falsifiable conjecture
For fixed `D = 3`, the minimal size of an `EMLExpr` of depth at most `3` representing `fullExprIterExp n` on `(0,∞)` grows at least exponentially in `n`.

A weaker, testable finite-grid version:

```lean
def GridRepresents (S : Finset ℝ) (e' : EMLExpr) (e : FullExpr) : Prop :=
  ∀ x ∈ S, EMLExpr.eval e' x = FullExpr.eval e x

conjecture finite_grid_depth3_iterExp_size_exponential :
  ∃ c > 1, ∀ᶠ n in Filter.atTop,
    c ^ n ≤ minGridSize 3 sampleGrid (fullExprIterExp n)
```

### Computational test
For `n ∈ {1, …, 10}`:
- build `fullExprIterExp n`,
- enumerate or search depth-3 `EMLExpr` candidates up to size bound `M`,
- test equality on a positive grid,
- record minimal matching size,
- plot size vs `n`.

A disproof occurs if a low-degree polynomial fit consistently explains the observed minimal sizes and explicit candidate expressions are found.

---

## Verified algorithmic deliverable

Do not stop at theorem statements. Produce a verified algorithm or computational method.

### Required algorithm
Implement a **depth-bounded EML search / lower-bound certification engine**:
1. enumerate candidate `EMLExpr` up to depth `D` and size `m`,
2. evaluate on a certified positive grid,
3. reject candidates by mismatch,
4. return either:
   - a witness representation, or
   - a certified lower bound: no candidate up to size `m` matches on the grid.

If possible, prove a soundness theorem:

```lean
theorem search_sound
    (D m : ℕ) (S : Finset ℝ) (e : FullExpr) :
    searchEML D m S e = none →
    ∀ e' : EMLExpr, e'.emlDepth ≤ D → e'.size ≤ m → ¬ GridRepresents S e' e := by
  sorry
```

This is scientifically crucial: it turns the conjecture into an experimental mathematics pipeline.

---

## Build on catalog theorems

Use existing verified theorems aggressively, and cite them in comments/docstrings by exact file/theorem names if available from the live catalog. In particular, search the catalog for:
- evaluation correctness lemmas for `FullExpr.eval` and `EMLExpr.eval`,
- size and depth recursion lemmas,
- normalization/simplification lemmas,
- monotonicity/positivity lemmas for `Real.exp`, `Real.log`,
- eventual domination / asymptotic comparison results,
- induction principles already established for expression syntax.

Do not vaguely mention catalog support. Use exact theorem names and explain how each is leveraged:
- recursion lemmas to prove rank bounds,
- semantic preservation lemmas to transfer equality,
- positivity lemmas to justify restriction to `x > 0`,
- growth lemmas to compare iterated exponentials.

If the catalog contains prior EML expressivity results, explicitly position this work as the **first lower-bound / separation theorem**, not an incremental extension.

---

## Deliverables (ALL MANDATORY)

You must produce all of the following:

1. **Lean file(s)** with the new definitions, at least 3 substantial theorems, and minimized sorry usage.
2. **`FUTURE_DIRECTIONS.md`** with **3–5 testable scientific hypotheses**, each a falsifiable conjecture with:
   - precise statement,
   - why it matters,
   - exact computational or formal test that could disprove it.
3. **`RESEARCH_PAPER.md`** that is fully standalone:
   - problem statement,
   - mathematical setup,
   - main theorems,
   - proof ideas,
   - computational experiment,
   - significance,
   - limitations,
   - next conjectures.
4. **`ARTICLE.md`** in Scientific American style:
   - accessible narrative,
   - why expression languages have complexity barriers,
   - why bounded depth matters,
   - what the new theorem means for symbolic AI and exact compilation.
5. **A verified algorithm or computational method** as described above.
6. **`demo.py`**:
   - interactive search over depth/size bounds,
   - evaluate candidates on a grid,
   - visualize minimal discovered size vs `n`,
   - display either candidate expressions or certified lower-bound gaps.

---

## What would make this revolutionary

A successful result here would do at least one of the following:

- establish the first mechanized lower-bound framework for exact real-expression languages;
- create a semantic analogue of bounded-depth circuit complexity in Lean;
- introduce a reusable asymptotic invariant (`growthRank`) for symbolic compilation barriers;
- connect formalized asymptotic analysis with compiler impossibility theorems;
- open a program toward **formalized hierarchy theorems for symbolic mathematics systems**.

Do not frame this as “we tested a conjecture on some examples.” Frame it as the birth of a new research direction: **mechanized semantic complexity theory for exact expression languages**.

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
