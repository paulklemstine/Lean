Soli Deo Gloria

## Assignment: Direction 4 — Multi-Variable Tower Functions

**Mode:** prove

Prove genuinely new theorems about **multi-variable EML tower complexity**. Do not merely port the single-variable library. The target is to show that adding variables enriches representational size but does **not** collapse tower-depth barriers. This is the first step toward a structural complexity theory of symbolic expressions on multivariate positive domains.

The scientific point is sharp: if iterated exponentials of linear forms preserve their intrinsic depth even in many variables, then **nesting complexity is a geometric invariant**, not an artifact of one-dimensional syntax. That would open a bridge from expression complexity to multivariate approximation theory, tensor complexity, and real algebraic geometry.

You should build on the catalog results around:
- `SizeDepthTradeoff.lean`: especially `size_lower_bound_iterExp`
- `Algebra/TightDepthHierarchy/Defs.lean`: especially `EMLExpr` and associated evaluation/depth/size notions in the single-variable setting

But do **not** stop at “the same theorem with `Fin k → ℝ` instead of `ℝ`.” Introduce at least one genuinely new definition and prove structural theorems that only make sense in the multivariate setting.

---

## Core Vision

Define a multivariate inverse-free EML language whose atoms include coordinates `x_i`, positive constants, addition, multiplication, and exponentiation by `Real.exp` (or the catalog’s exponential constructor, matching existing semantics). Then isolate a canonical family
\[
T_{n,k}(x) := \operatorname{iterExp}(n,\; \sum_{i=0}^{k-1} x_i),
\]
and prove that the **minimum depth needed to represent** `T_{n,k}` is still exactly `n`, independent of `k`, while the size lower bound reflects both tower height and arity.

The breakthrough theorem is not just a generalization: it says that the obstruction is **compositional** rather than **coordinate-dependent**. In complexity language, tower height is a stratified resource robust under multivariate linear aggregation.

---

## Precise Formal Targets

You should introduce a new multivariate syntax/semantics layer, for example:

```lean
def FinSum {k : ℕ} (x : Fin k → ℝ) : ℝ := ∑ i, x i

def iterExp : ℕ → ℝ → ℝ
| 0, t => t
| n+1, t => Real.exp (iterExp n t)

inductive MVEMLExpr (k : ℕ) : Type
| const : ℝ → MVEMLExpr k
| var   : Fin k → MVEMLExpr k
| add   : MVEMLExpr k → MVEMLExpr k → MVEMLExpr k
| mul   : MVEMLExpr k → MVEMLExpr k → MVEMLExpr k
| exp   : MVEMLExpr k → MVEMLExpr k
```

with evaluation, depth, and size:

```lean
def MVEMLExpr.eval {k : ℕ} : MVEMLExpr k → (Fin k → ℝ) → ℝ
def MVEMLExpr.depth {k : ℕ} : MVEMLExpr k → ℕ
def MVEMLExpr.size  {k : ℕ} : MVEMLExpr k → ℕ
```

Introduce a new multivariate notion that is not in the catalog, e.g. the **support rank** / **variable support** of an expression:

```lean
def MVEMLExpr.varSupport {k : ℕ} : MVEMLExpr k → Finset (Fin k)
```

or a semantic linear-form recognizer:

```lean
def IsCoordinateSum {k : ℕ} (f : (Fin k → ℝ) → ℝ) : Prop :=
  ∀ x, f x = ∑ i, x i
```

A stronger and more novel definition would be a **tower profile** capturing the maximal exponential nesting encountered on any root-to-leaf path:

```lean
def MVEMLExpr.towerRank {k : ℕ} : MVEMLExpr k → ℕ
```

with the goal of proving that for inverse-free expressions this coincides with or lower-bounds semantic tower complexity on positive inputs.

---

## Main Theorems to Prove

You must prove at least 3 substantial theorems. The following are the right targets.

### Theorem 1: Exact multivariate depth lower bound for towered coordinate sum
This is the central theorem.

**Mathematical statement.**  
For every `k ≥ 1` and every `n`, any multivariate inverse-free EML expression computing
\[
x \mapsto \operatorname{iterExp}(n,\sum_i x_i)
\]
on all positive inputs must have depth at least `n`. Moreover there exists an expression of depth exactly `n` computing it. Hence the minimum depth is exactly `n`.

**Lean-style target signature:**
```lean
theorem mv_minDepth_iterExp_sum_eq
    {k n : ℕ} (hk : 0 < k) :
    mvMinDepth k (fun x : Fin k → ℝ => iterExp n (FinSum x)) = n
```

If `mvMinDepth` is too heavy to define abstractly, split into upper/lower bounds:

```lean
theorem mv_depth_lower_bound_iterExp_sum
    {k n : ℕ} (hk : 0 < k) :
    ∀ e : MVEMLExpr k,
      (∀ x : Fin k → ℝ, (∀ i, 0 < x i) →
        e.eval x = iterExp n (FinSum x)) →
      n ≤ e.depth

theorem mv_depth_upper_bound_iterExp_sum
    {k n : ℕ} :
    ∃ e : MVEMLExpr k,
      e.depth = n ∧
      ∀ x : Fin k → ℝ, e.eval x = iterExp n (FinSum x)
```

**Why this is a breakthrough.**  
This would establish a **dimension-invariant depth hierarchy** for EML tower functions. It says the depth barrier survives aggregation across arbitrarily many coordinates. That is the multivariate analog of a circuit lower bound with a semantic geometric input family.

---

### Theorem 2: Size lower bound with arity contribution
You are asked only for Ω(`n + k`), but formulate and prove the strongest clean theorem you can.

**Mathematical statement.**  
Any inverse-free multivariate EML expression computing `iterExp n (∑ i, x_i)` must have size at least `n + k` up to explicit constants/conventions of syntax.

**Lean-style target signature:**
```lean
theorem mv_size_lower_bound_iterExp_sum
    {k n : ℕ} (hk : 0 < k) :
    ∀ e : MVEMLExpr k,
      (∀ x : Fin k → ℝ, (∀ i, 0 < x i) →
        e.eval x = iterExp n (FinSum x)) →
      n + k ≤ e.size
```

If exact `n + k` is false under your constructor accounting, prove an explicit theorem of the form:
```lean
theorem mv_size_lower_bound_iterExp_sum'
    {k n C : ℕ} ...
```
with a concrete lower bound such as `n + k - 1 ≤ e.size` or `n + 2*k ≤ e.size + 3`. The point is to prove a **real structural lower bound**, not asymptotic prose.

**Why this matters.**  
This is the first theorem in the project that simultaneously tracks **tower height** and **variable arity**. It moves the theory from pure depth hierarchy toward a bona fide multivariate resource theory.

---

### Theorem 3: Support theorem connecting syntax and semantics
This is the place for a new multivariate concept.

**Mathematical statement.**  
If an expression computes `x ↦ ∑ i x_i` on all inputs, then every variable must appear in its support. Consequently any expression computing `iterExp n (∑ i x_i)` must have support all of `Fin k`.

**Lean-style target signature:**
```lean
theorem varSupport_eq_univ_of_eval_eq_sum
    {k : ℕ} :
    ∀ e : MVEMLExpr k,
      (∀ x : Fin k → ℝ, e.eval x = FinSum x) →
      e.varSupport = Finset.univ

theorem support_univ_of_eval_eq_iterExp_sum
    {k n : ℕ} :
    ∀ e : MVEMLExpr k,
      (∀ x : Fin k → ℝ, (∀ i, 0 < x i) →
        e.eval x = iterExp n (FinSum x)) →
      e.varSupport = Finset.univ
```

A weaker but still valuable theorem is:
```lean
theorem mem_varSupport_of_semantic_dependence
    {k : ℕ} {e : MVEMLExpr k} {i : Fin k} :
    (∃ x y : Fin k → ℝ,
      (∀ j, j ≠ i → x j = y j) ∧
      e.eval x ≠ e.eval y) →
    i ∈ e.varSupport
```

**Why this matters.**  
This creates a bridge from syntax to semantic dependence, i.e. a rudimentary **influence theory** for symbolic expressions. That is a cross-domain opening toward learning theory and sensitivity analysis.

---

## Strong Optional Theorem 4: Monotonicity and injectivity on the positive cone
This is a cross-domain theorem connecting symbolic complexity to analysis.

**Mathematical statement.**  
For positive-domain inverse-free expressions, evaluation is coordinatewise monotone. Therefore the map
\[
x \mapsto \operatorname{iterExp}(n,\sum_i x_i)
\]
is strictly increasing in each coordinate.

**Lean-style target signature:**
```lean
theorem eval_monotone_on_pos
    {k : ℕ} :
    ∀ e : MVEMLExpr k,
      InverseFree e →
      MonotoneOn e.eval {x | ∀ i, 0 < x i}
```

or a coordinatewise version:
```lean
theorem eval_le_eval_of_le
    {k : ℕ} :
    ∀ e : MVEMLExpr k,
      InverseFree e →
      ∀ {x y : Fin k → ℝ},
        (∀ i, 0 < x i) →
        (∀ i, 0 < y i) →
        (∀ i, x i ≤ y i) →
        e.eval x ≤ e.eval y
```

This can be used as a lemma inside lower-bound arguments and also serves as an analytical bridge.

---

## Proof Architecture: 3 Viable Strategies

### Strategy A: Restriction-to-diagonal reduction from multivariate to single-variable
**Most promising.**

1. Define the diagonal embedding:
   ```lean
   def diagPt {k : ℕ} (t : ℝ) : Fin k → ℝ := fun _ => t
   ```
   Then prove:
   \[
   \sum_i \mathrm{diagPt}(t)_i = k t.
   \]
2. More powerfully, choose a one-parameter slice such as
   \[
   x(t) = (t, c_2,\dots,c_k)
   \]
   with fixed positive constants, so that `FinSum (x(t)) = t + C`. Restrict any multivariate expression `e` along this slice to obtain a single-variable expression `e_restrict`.
3. Show depth does not increase under restriction:
   ```lean
   depth (restrict e) ≤ depth e
   ```
   and similarly for size.
4. Apply the existing single-variable lower bound (`size_lower_bound_iterExp` and depth hierarchy results) to the restricted function
   \[
   t \mapsto \operatorname{iterExp}(n, t + C).
   \]
   Then transfer the contradiction back to `e`.

**Why best:** it leverages the catalog directly and converts the multivariate theorem into a robust semantic corollary of the single-variable theory. It is also likely the shortest route to a formally verified proof.

---

### Strategy B: Structural tower-rank invariant
1. Define `towerRank` recursively by:
   - constants/variables have rank `0`
   - `add`/`mul` take `max`
   - `exp` adds `1`
2. Prove:
   ```lean
   theorem towerRank_le_depth : e.towerRank ≤ e.depth
   ```
3. Establish a semantic theorem that if `towerRank e < n`, then `e.eval` cannot equal `iterExp n (FinSum x)` on all positive inputs. This may proceed by repeated logarithmic peeling on the positive cone, showing one can eliminate at most one exponential layer per `exp` node along a branch.
4. Conclude `n ≤ towerRank e ≤ depth e`.

**Why interesting:** this is conceptually stronger than a reduction argument. It isolates the **true invariant** responsible for the lower bound and may scale to future theories with more operators.

---

### Strategy C: Variable-support plus monotonicity plus induction on syntax
1. Prove every expression depends only on variables in `varSupport`.
2. Show computing `FinSum` forces full support, hence at least `k` variable occurrences or at least support cardinality `k`.
3. Prove every `exp` layer can increase tower height by at most one, via induction on syntax and repeated use of positivity/monotonicity.
4. Combine support lower bound and tower lower bound to derive size ≥ `n + k` (up to syntax constants).

**Why valuable:** this yields the cleanest multivariate statement and creates tools reusable for symbolic regression complexity.

---

## Recommended Implementation Order

1. **Define `MVEMLExpr`**, evaluation, depth, size, positivity/inverse-free predicate.
2. **Define `varSupport`** and prove basic recursion lemmas.
3. **Construct explicit upper-bound expression** for `iterExp n (FinSum x)`.
4. **Implement restriction of a multivariate expression to a one-variable slice**:
   ```lean
   def restrictAffine {k : ℕ} (e : MVEMLExpr k)
       (a : Fin k → ℝ) (b : Fin k → ℝ) : EMLExpr
   ```
   satisfying
   \[
   \text{eval}(restrictAffine\ e\ a\ b)\ t = e.eval(\lambda i, a_i t + b_i).
   \]
   This is a genuinely useful algorithmic construction.
5. Use the restriction machinery to prove the **depth lower bound**.
6. Prove the **support theorem**.
7. Use support cardinality plus depth/tower arguments to prove the **size lower bound**.

---

## Cross-Domain Connections You Must Surface

This project is not just about expression trees.

### 1. Multivariate approximation theory
The family `iterExp n (∑ x_i)` is a highly anisotropic but symmetric target. Proving depth rigidity shows that some multivariate functions resist low-composition approximation even when they depend only on a single linear statistic.

### 2. Tensor complexity / arithmetic circuits
The sum `∑ x_i` is a rank-1 linear statistic in dual form, but applying an exponential tower yields extreme compositional complexity. This is a symbolic analog of low-rank input paired with high nonlinear depth.

### 3. Real algebraic / o-minimal geometry
Expressions built from `+`, `*`, and `exp` live naturally in the structure of the real exponential field. Tower-rank lower bounds hint at stratifications of definable functions by compositional complexity.

### 4. Learning theory / symbolic regression
If the true target is `iterExp n (∑ x_i)`, then no shallow inverse-free symbolic model can represent it exactly, regardless of variable count. This provides a formal obstruction result for model class selection.

### 5. Statistical physics / mean-field observables
`∑ x_i` is a collective observable; exponentiating it repeatedly resembles partition-function amplification. The theorem says collective observables can still encode irreducible compositional depth.

---

## Application Keywords

Use these explicitly in your paper and article:

**application keywords:** symbolic regression, compositional complexity, arithmetic circuits, tensor complexity, multivariate approximation, real exponential geometry, monotone computation, mean-field observables, depth hierarchy, expressive efficiency

---

## Concrete Lean 4 Deliverables

You must produce **all** of the following:

### 1. Verified theorem file
A Lean file containing:
- the new multivariate definitions
- at least **3 nontrivial theorems** proved with deep tactics
- minimal `sorry`
- at least one theorem using induction
- at least one theorem using `rcases`
- at least one theorem using `by_contra` or multi-step `calc`
- if denominators arise in affine restriction or positivity lemmas, use `field_simp` meaningfully

### 2. Verified algorithm / computational method
Not just theorems. Implement at least one certified procedure, for example:
- `restrictAffine` transforming multivariate expressions to single-variable ones
- an enumerator for bounded-depth/bounded-size `MVEMLExpr k`
- a support-extraction algorithm with proof of correctness
- a positive-grid evaluator for falsifying candidate representations

This algorithm must be used in the experimental section.

### 3. `demo.py`
An interactive Python demo that:
- constructs candidate two-variable expressions of depth ≤ 2
- evaluates them on a positive grid
- compares against `iterExp(3, x+y)`
- reports that no candidate matches, if your search space is exhaustive under the chosen syntax bounds
- visualizes growth or mismatch statistics

### 4. `FUTURE_DIRECTIONS.md`
Include **3–5 falsifiable scientific hypotheses**, each with a clear computational test. Examples of the right flavor:

- **Hypothesis 1.** For every fixed `k`, the minimum depth for `iterExp n (FinSum x)` is exactly `n`.  
  **Test:** exhaustive search for `k = 2,3` and `n = 2,3` over bounded syntax classes.

- **Hypothesis 2.** The minimum size of an inverse-free expression for `iterExp n (FinSum x)` is at least `n + k - 1` under the chosen node-count convention.  
  **Test:** exact enumeration for small `(n,k)` and comparison with constructed upper bounds.

- **Hypothesis 3.** Any multivariate inverse-free expression with support size `s` can depend semantically on at most `s` coordinates.  
  **Test:** random expression generation plus coordinate perturbation experiments.

- **Hypothesis 4.** Tower-rank equals minimum depth on the subclass generated from affine forms by repeated exponentiation and multiplication.  
  **Test:** compute both invariants for all expressions up to size bound `N`.

- **Hypothesis 5.** Shallow multivariate EML expressions approximate `iterExp n (FinSum x)` poorly on positive boxes even when exact representation is impossible.  
  **Test:** numerical optimization of shallow candidates on bounded domains.

### 5. `RESEARCH_PAPER.md`
A standalone paper containing:
- problem statement
- formal definitions
- theorem statements
- proof ideas
- significance
- computational experiments
- limitations
- next conjectures

Someone reading only this document must understand the mathematics and why it matters.

### 6. `ARTICLE.md`
Write this in **Scientific American style** for a broad audience. Do **not** focus on formal verification machinery. Explain the ideas: why repeated exponentials are structurally deep, why adding variables does not trivialize them, and why this matters for symbolic models and complexity.

---

## A Strong Conjecture to Include

State clearly:

\[
\textbf{Conjecture.}\quad
\forall k\ge 1,\ \forall n\ge 0,\ 
\minDepth_k\!\left(x \mapsto \operatorname{iterExp}(n,\sum_i x_i)\right)=n,
\]
and under natural node-count conventions,
\[
\minSize_k\!\left(x \mapsto \operatorname{iterExp}(n,\sum_i x_i)\right)\ge n+k-1.
\]

Also include the concrete falsification test:

- For `k = 2`, `n = 3`, enumerate all two-variable inverse-free expressions of depth ≤ 2 within a reasonable size bound.
- Evaluate on a `10 × 10` grid of positive rational or floating points.
- No candidate should agree everywhere with `iterExp 3 (x + y)`.

If a counterexample appears, that is scientifically valuable: it would mean multivariate sharing can compress tower depth in a way the single-variable theory does not predict.

---

## Nontrivial Proof Expectations

Avoid toy statements. Do **not** spend the budget on lemmas solvable by reflexive simplification alone. At least three proofs should visibly involve real mathematical structure:
- induction on expression syntax
- restriction arguments
- semantic dependence via variable perturbation
- positivity and monotonicity on cones
- cardinality arguments on support
- transfer of single-variable lower bounds to multivariate slices

The ideal outcome is a file that future work can cite as the foundation of a **multivariate EML complexity theory**.

Be bold: if the exact size lower bound `n + k` resists proof, prove a weaker explicit lower bound and isolate the obstruction. The important thing is to create new invariants and a proof architecture that can scale.

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
