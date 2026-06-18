Soli Deo Gloria

## Assignment: Direction 4 — Multi-Variable Tower Functions

**Mode:** prove

Build a genuinely new multivariate complexity theory for exponential-measure-logic expressions by extending the single-variable EML depth hierarchy to functions on `Fin k → ℝ`. Do not merely port definitions: identify the structural invariant showing that **tower height is controlled by compositional nesting, not ambient dimension**. The goal is to prove a multivariable depth-separation theorem that would make the existing single-variable hierarchy look like the rank-1 shadow of a richer tensorial phenomenon.

This is not an incremental variant. If successful, this opens a formal theory of **dimension-robust expression complexity** for symbolic regression, tensorized circuit lower bounds, and multivariate approximation barriers for inverse-free analytic models.

---

## Core Vision

The single-variable result says that `iterExp n x` has intrinsic depth `n`. Your task is to show that replacing `x` by a genuinely multivariate linear form such as `x₁ + ⋯ + x_k` does **not** reduce the required depth, while size must increase to account for the number of variables. The breakthrough is the principle:

> **Dimension does not compress tower height.**

In other words, adding variables can enlarge the input geometry, but cannot flatten the nested exponential architecture needed to realize an iterated tower.

This is a structural theorem about expression languages, not just a function identity. It belongs simultaneously to:
- **proof complexity / circuit complexity**: depth lower bounds,
- **multivariate approximation theory**: obstruction to shallow exact representation,
- **tensor complexity**: the sum map `x ↦ ∑ i, x i` is the simplest rank-1 contraction, and iterated exponentials amplify its compositional complexity,
- **real algebraic / o-minimal geometry**: definable stratification of expression classes by nesting depth,
- **symbolic regression**: certifying impossibility of shallow exact fits in multi-feature settings.

**Application keywords:** symbolic regression, expression complexity, circuit lower bounds, tensor complexity, multivariate approximation, definability, exact representability, compositional depth, formal verification, analytic complexity.

---

## New Mathematical Objects You Should Introduce

You must define at least one genuinely new concept not already present in the catalog. The most promising choices are:

1. **Multivariate EML expressions**
   ```lean
   -- schematic target only; adapt to catalog style
   inductive MVEMLExpr (k : ℕ)
   | var   : Fin k → MVEMLExpr k
   | const : ℝ → MVEMLExpr k
   | add   : MVEMLExpr k → MVEMLExpr k → MVEMLExpr k
   | mul   : MVEMLExpr k → MVEMLExpr k → MVEMLExpr k
   | exp   : MVEMLExpr k → MVEMLExpr k
   ```
   together with `eval : MVEMLExpr k → (Fin k → ℝ) → ℝ`, `depth`, `size`, and an inverse-free predicate if the catalog distinguishes this.

2. **Coordinate-collapse / diagonalization operator**
   ```lean
   def diagonalize {k : ℕ} (f : (Fin k → ℝ) → ℝ) : ℝ → ℝ :=
     fun t => f (fun _ => t)
   ```
   or the stronger linear-form restriction
   ```lean
   def alongSumRay {k : ℕ} (f : (Fin k → ℝ) → ℝ) : ℝ → ℝ :=
     fun t => f (fun _ => t / k)
   ```
   This is likely the key bridge back to the single-variable theory.

3. **Essential variable support**
   ```lean
   def varSupport {k : ℕ} (e : MVEMLExpr k) : Finset (Fin k)
   ```
   and prove lower bounds relating `size e` to `varSupport.card`.

4. **Tower-majorant rank**
   A depth-sensitive invariant measuring how many nested exponentials can appear after restriction to a one-dimensional ray. This could be the right abstraction if direct syntactic induction becomes messy.

At least one of these should be formalized as a reusable structure with lemmas.

---

## Precise Theorem Targets

You must prove at least 3 substantial theorems with nontrivial tactics. The following are the primary targets.

### Theorem 1: Restriction preserves or lowers depth
This is the reduction engine from multivariate to single-variable complexity.

**Mathematical statement.**  
For every multivariate inverse-free expression `e` and every affine specialization `σ : Fin k → MVEMLExpr 1` of depth `≤ 0` (e.g. constants and the single variable), substituting `σ` into `e` yields a one-variable expression whose depth is at most the depth of `e`.

A more concrete special case is enough if substitution infrastructure is difficult:

> If `diagExpr e` is obtained by replacing every variable `x_i` in `e` by the same variable `X`, then  
> `depth (diagExpr e) ≤ depth e` and  
> `eval (diagExpr e) x = eval e (fun _ => x)`.

**Lean 4 type signature (schematic):**
```lean
theorem depth_diag_le
    {k : ℕ} (e : MVEMLExpr k) :
    depth (diagExpr e) ≤ depth e

theorem eval_diagExpr
    {k : ℕ} (e : MVEMLExpr k) (x : ℝ) :
    eval (diagExpr e) x = eval e (fun _ => x)
```

**Why this matters.**  
This theorem turns every multivariate exact representation into a univariate one without increasing depth. It is the formal mechanism behind “dimension does not compress tower height.”

---

### Theorem 2: Multivariable depth lower bound for tower functions
This is the flagship theorem.

Let
```lean
def sumVars {k : ℕ} (x : Fin k → ℝ) : ℝ := ∑ i, x i
def towerOnSum (n k : ℕ) (x : Fin k → ℝ) : ℝ := iterExp n (sumVars x)
```

**Mathematical statement.**  
For every `n ≥ 1` and every `k ≥ 1`, if an inverse-free multivariate EML expression `e : MVEMLExpr k` computes `towerOnSum n k` exactly on all positive inputs, then `depth e ≥ n`.

A robust version is:

> For all `n k`, if  
> `∀ x, 0 < x i for all i → eval e x = iterExp n (∑ i, x i)`,  
> then `depth e ≥ n`.

**Lean 4 type signature (schematic):**
```lean
theorem depth_lower_bound_iterExp_sum
    {k n : ℕ} (hk : 0 < k) :
    ∀ e : MVEMLExpr k,
      (∀ x : Fin k → ℝ,
        (∀ i, 0 < x i) →
        eval e x = iterExp n (∑ i, x i)) →
      n ≤ depth e
```

If the catalog’s single-variable theorem already gives a lower bound for exact equality on all reals or all positive reals, use the diagonal restriction:
- evaluate on the ray `x_i = t/k`, so `∑ i x_i = t`,
- derive `eval e (fun _ => t/k) = iterExp n t`,
- convert to a one-variable contradiction if `depth e < n`.

**Why this is a breakthrough.**  
It proves that multivariate input richness does not bypass the tower-depth barrier. This is a true lower-bound theorem for an analytic expression language, with direct relevance to interpretable ML and symbolic regression.

---

### Theorem 3: Variable-support/size lower bound
You need a theorem showing that using many variables costs syntax, even when depth is fixed.

**Mathematical statement.**  
If `e : MVEMLExpr k` depends essentially on all `k` variables, then `size e ≥ k`. A stronger target is `size e ≥ card(varSupport e)` and, for representing `iterExp n (∑ i, x_i)`, conclude `size e ≥ n + k` or at least `size e ≥ max n k`.

**Lean 4 type signature (schematic):**
```lean
theorem varSupport_card_le_size
    {k : ℕ} (e : MVEMLExpr k) :
    e.varSupport.card ≤ size e

theorem size_lower_bound_iterExp_sum
    {k n : ℕ} (hk : 0 < k) :
    ∀ e : MVEMLExpr k,
      (∀ x : Fin k → ℝ,
        (∀ i, 0 < x i) →
        eval e x = iterExp n (∑ i, x i)) →
      n + k ≤ C * size e
```
for some explicit constant `C`, or a weaker but provable statement such as
```lean
n ≤ depth e ∧ k ≤ size e
```
and then derive
```lean
n + k ≤ depth e + size e
```
or
```lean
max n k ≤ size e
```
if that is what the syntax supports.

**Why this matters.**  
Depth captures compositional hardness; size captures dimensional load. Their coexistence is the beginning of a multivariate complexity landscape.

---

## Strong Optional Theorem: Cross-domain bridge via convexity or tensor restriction

To satisfy the cross-domain requirement in a substantial way, prove one theorem that links EML complexity to another domain.

### Option A: Convex analysis bridge
Show that on the positive orthant, `x ↦ iterExp n (∑ i, x i)` is coordinatewise increasing and convex, and that these properties are inherited by inverse-free expressions under suitable syntactic positivity assumptions.

**Lean target (schematic):**
```lean
theorem convexOn_towerOnSum
    {k n : ℕ} :
    ConvexOn ℝ (Set.univ : Set (Fin k → ℝ))
      (fun x => iterExp n (∑ i, x i))
```
This connects formal expression complexity with **convex geometry** and optimization.

### Option B: Tensor-complexity bridge
Define the diagonal restriction / sum-ray restriction as a rank-1 tensor slice and prove that exact representability on the full space implies exact representability on every slice. This is simple mathematically but conceptually powerful: it imports the logic of **tensor restrictions** into expression lower bounds.

### Option C: Algebraic-geometry bridge
Prove that if two multivariate EML expressions agree on all points of a nonempty open box, then their diagonal restrictions agree on an interval; combine this with univariate depth separation. This frames the lower bound as a rigidity statement on definable functions.

Any one of these, properly formalized, satisfies the cross-domain condition.

---

## Proof Strategy Architecture

You must present and then execute 2–3 proof paths. At least one should be fully implemented.

### Strategy A: Diagonal reduction to the univariate catalog theorem
**Most promising.**

1. Define `diagExpr : MVEMLExpr k → EMLExpr` by collapsing every variable to the same single variable.
2. Prove by induction:
   - `eval (diagExpr e) t = eval e (fun _ => t)`,
   - `depth (diagExpr e) ≤ depth e`,
   - optionally `size (diagExpr e) ≤ size e`.
3. If `e` computes `iterExp n (∑ i, x_i)`, then along the ray `x_i = t / k` one gets
   ```lean
   eval e (fun _ => t / k) = iterExp n t.
   ```
4. Build a univariate expression from `e` by composing the variable with scaling `t ↦ t/k` if needed, or choose a normalization already expressible in your syntax.
5. Invoke the catalog theorem `size_lower_bound_iterExp` or the depth-hierarchy theorem from `Algebra/TightDepthHierarchy/Defs.lean`.

**Why best:** It leverages existing certified lower bounds and reduces the genuinely new work to a robust substitution formalism.

---

### Strategy B: Majorant-growth induction in the multivariate setting
1. Generalize the single-variable majorant invariant from `x ↦ eval e x` to `x ↦ eval e (t·1)` or to `x ↦ eval e x` on the positive orthant with `m = ∑ i, x_i`.
2. Prove that any depth-`d` expression is eventually dominated by a `d`-level iterated-exp majorant in the scalar variable `m`.
3. Show `iterExp (d+1) m` escapes that majorant, yielding contradiction if `d < n`.

**Why useful:** This avoids dependence on a sophisticated substitution API and may give stronger asymptotic statements. It is conceptually deeper, but likely more labor-intensive in Lean.

---

### Strategy C: Essential-variable induction for size lower bounds
1. Define `varSupport`.
2. Prove by structural induction:
   - variables contribute singleton support,
   - constants contribute empty support,
   - support under `add`, `mul`, `exp` behaves by union or preservation.
3. Show `varSupport.card ≤ size`.
4. Prove that if `eval e = iterExp n (sumVars)` on all positive inputs, then every variable is essential:
   for each `j`, changing only coordinate `j` changes the value.
5. Conclude `k ≤ size e`, and combine with the depth lower bound to obtain a joint lower bound.

**Why important:** This theorem is independent of the tower-depth argument and gives a true multivariate complexity invariant.

---

## Lean 4 Formalization Targets

You should aim for theorem statements close to the following. Adapt names to the catalog.

```lean
def sumVars {k : ℕ} (x : Fin k → ℝ) : ℝ := ∑ i, x i

def towerOnSum (n : ℕ) {k : ℕ} (x : Fin k → ℝ) : ℝ :=
  iterExp n (sumVars x)

def diagInput {k : ℕ} (t : ℝ) : Fin k → ℝ := fun _ => t

def avgInput {k : ℕ} [NeZero k] (t : ℝ) : Fin k → ℝ := fun _ => t / k

def diagExpr {k : ℕ} : MVEMLExpr k → EMLExpr
-- replace each variable by the unique univariate variable

theorem eval_diagExpr
    {k : ℕ} (e : MVEMLExpr k) (t : ℝ) :
    EMLExpr.eval (diagExpr e) t = MVEMLExpr.eval e (diagInput t)

theorem depth_diagExpr_le
    {k : ℕ} (e : MVEMLExpr k) :
    EMLExpr.depth (diagExpr e) ≤ MVEMLExpr.depth e

theorem varSupport_card_le_size
    {k : ℕ} (e : MVEMLExpr k) :
    e.varSupport.card ≤ e.size

theorem essential_all_vars_of_eq_towerOnSum
    {k n : ℕ} (hk : 0 < k) (e : MVEMLExpr k)
    (h :
      ∀ x : Fin k → ℝ, (∀ i, 0 < x i) →
        e.eval x = iterExp n (sumVars x)) :
    ∀ i, i ∈ e.varSupport

theorem depth_lower_bound_iterExp_sum
    {k n : ℕ} (hk : 0 < k) (e : MVEMLExpr k)
    (h :
      ∀ x : Fin k → ℝ, (∀ i, 0 < x i) →
        e.eval x = iterExp n (sumVars x)) :
    n ≤ e.depth

theorem size_lower_bound_from_support
    {k n : ℕ} (hk : 0 < k) (e : MVEMLExpr k)
    (h :
      ∀ x : Fin k → ℝ, (∀ i, 0 < x i) →
        e.eval x = iterExp n (sumVars x)) :
    k ≤ e.size
```

If a clean exact `n + k ≤ size e` is too ambitious, prove the pair
```lean
n ≤ e.depth
k ≤ e.size
```
and state the stronger additive bound as a conjecture.

---

## Catalog Building Blocks

You must explicitly build on:

- `SizeDepthTradeoff.lean`: `size_lower_bound_iterExp`
  - Use this as the univariate lower-bound engine after diagonal/sum-ray restriction.
  - If it gives size rather than depth, derive a depth contradiction through known inequalities between depth and representability, or combine it with a catalog depth-hierarchy theorem.

- `Algebra/TightDepthHierarchy/Defs.lean`: `EMLExpr`
  - Mirror its syntax and semantics carefully so the univariate reduction is definitionally natural.
  - If possible, define a coercion or translation `diagExpr : MVEMLExpr k → EMLExpr`.

Also inspect whether there is already:
- evaluation compositionality,
- substitution lemmas,
- positivity lemmas for `iterExp`,
- monotonicity or growth lemmas.

If a needed bridge theorem is missing, prove it cleanly rather than introducing ad hoc rewrites.

---

## Nontrivial Proof Expectations

At least 3 theorems must involve real proof architecture, using some of:
- induction on expressions,
- `rcases` for syntax cases,
- `by_contra` for lower-bound contradiction,
- `field_simp` for the `t / k` normalization on rays,
- multi-step `calc`,
- `Finset` cardinality arguments for support,
- positivity side conditions on the positive orthant.

Avoid toy lemmas whose proof is one line of simplification unless they are indispensable sublemmas.

---

## Concrete Computational Program

You must also produce a **verified algorithm or computational method**, not just theorem statements.

### Required algorithm
Implement an enumerator for inverse-free two-variable expressions up to bounded depth/size, together with grid evaluation.

Suggested components:
- `enumerateExprs : ℕ → ℕ → List (MVEMLExpr 2)` for depth/size-bounded expressions,
- `gridPoints : List (ℝ × ℝ)` for a finite positive grid,
- `matchesTowerOnGrid : MVEMLExpr 2 → Bool`,
- theorem(s) showing evaluator correctness with respect to `eval`.

### Required testable conjecture
State and computationally test:

> **Conjecture (Depth rigidity on the 2-variable grid).**  
> No inverse-free `MVEMLExpr 2` of depth `≤ 2` computes `iterExp 3 (x₁ + x₂)` on the 10×10 grid `{1/10, 2/10, ..., 1}²`.

This is falsifiable: one counterexample disproves it.

If exhaustive enumeration is too expensive, bound size as well and report the exact search frontier reached.

---

## Deliverables (ALL MANDATORY)

You must produce all of the following:

1. **Lean code** with the new multivariate definitions and at least 3 substantial theorems proved with nontrivial tactics.
2. **FUTURE_DIRECTIONS.md** containing **3–5 falsifiable scientific hypotheses**, each with:
   - precise conjecture,
   - why it matters,
   - explicit computational or formal test that could refute it.
3. **RESEARCH_PAPER.md** as a **standalone scientific paper**:
   - motivation,
   - formal definitions,
   - theorem statements,
   - proof ideas,
   - significance,
   - limitations,
   - next-step conjectures.
   Someone reading only this document must understand the discovery.
4. **ARTICLE.md** in **Scientific American style**:
   accessible, vivid, and accurate.
5. **A verified algorithm or computational method**:
   the bounded expression enumerator / matcher.
6. **demo.py**:
   - constructs sample multivariate expressions,
   - evaluates them on grids,
   - demonstrates the failure of shallow expressions to match the target tower function at the tested frontier,
   - prints or visualizes search statistics.

---

## Revolutionary Significance

If you prove the flagship theorem, you establish the first formally verified instance of a broad meta-principle:

> **Compositional analytic depth is invariant under harmless increases in ambient dimension.**

That principle is bigger than this problem. It suggests:
- lower bounds for multifeature symbolic regression models,
- certified impossibility results for shallow interpretable architectures,
- tensor-slicing methods for transferring 1D lower bounds to high-dimensional settings,
- a future formal complexity theory of analytic expression languages analogous to arithmetic circuit complexity.

This is the right scale of result: not “single-variable, but with more variables,” but a theorem explaining **why variables and depth are different currencies of complexity**.

Be bold. Formalize the right abstraction so that later work can replace `sumVars` by general linear forms, sparse forms, or tensor contractions. The first theorem should already point beyond itself.

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
