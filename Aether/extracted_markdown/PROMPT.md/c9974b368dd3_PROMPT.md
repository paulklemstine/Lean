Soli Deo Gloria

## Assignment: Higher-Order Anti-Cancellation and k-Shadows

**Mode:** `prove`

You are to push the current anti-cancellation theory from pairwise derivative shadows to a full higher-order calculus of supports. The target is not a routine generalization: it is a structural theorem saying that **positivity plus Lorentzian rigidity prevents all support-level cancellation throughout the entire derivative tower**. If true, this opens a new support-theoretic interface between combinatorial Hodge theory and arithmetic complexity: higher derivatives become combinatorial objects with exact, computable support geometry.

Build explicitly on:

- `Pythagorean/LorentzianAggregateAntiCancel.lean` (Theorem A / aggregate anti-cancellation for lower order)
- `Catalog/Bridges/Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` (weighted support shadow / per-pair exactness)

Do not merely restate the known `k = 2` phenomenon. The goal is a genuine **order-k theorem**, with new definitions, nontrivial lemmas, and an executable method for computing and testing `k`-shadows.

---

## Central Mathematical Vision

For a multivariate polynomial with nonnegative coefficients, every coefficient appearing in a mixed partial derivative is obtained by multiplying an original coefficient by a product of natural-number multiplicities. That means every individual contribution to every coefficient of every weighted derivative aggregate is nonnegative. The breakthrough question is whether this naive positivity survives the combinatorics of overlaps at arbitrary order.

Your assignment is to formalize and prove that, in the positive regime, it does: **the support of a positive weighted sum of order-`k` derivatives is exactly the union of the order-`k` derivative shadows of the active derivative indices.**

If successful, this yields a hierarchy of anti-cancellation theorems:
- order 1: support shadow under first derivatives,
- order 2: known pairwise aggregate anti-cancellation,
- order `k`: full exact support formula,
- asymptotically: support lower bounds for derivative circuits and polarization operators.

This is the right theorem because it turns an analytic positivity condition into an exact combinatorial support law.

---

## Precise Target Theorems

You should introduce a new concept of **order-`k` derivative shadow** for finitely supported multivariate polynomials. Work in the most natural Mathlib-compatible setting available for finitely supported exponent vectors and multivariate polynomials.

A good formalization target is:

- index variables by a finite type `σ`
- exponents by `σ →₀ ℕ`
- polynomials by `MvPolynomial σ R` or by an explicit finitely supported coefficient model if support-level reasoning is cleaner
- derivative multi-indices by `σ →₀ ℕ` with total weight `k`

You may need a new structure to package active weighted derivative data.

### New definitions to introduce

At minimum define something morally equivalent to:

```lean
def derivMultiShadow
  {σ : Type*} [DecidableEq σ]
  (S : Finset (σ →₀ ℕ)) (m : σ →₀ ℕ) : Finset (σ →₀ ℕ)
```

where `derivMultiShadow S m` is the set of exponent vectors `e - m` such that `e ∈ S` and `m ≤ e` coordinatewise.

Also define an aggregate active shadow:

```lean
def weightedKShadow
  {σ : Type*} [DecidableEq σ]
  (S : Finset (σ →₀ ℕ))
  (T : Finset (σ →₀ ℕ)) : Finset (σ →₀ ℕ)
```

where `T` is the finite set of active order-`k` derivative multi-indices, and
`weightedKShadow S T = ⋃ m ∈ T, derivMultiShadow S m`.

If existing catalog files use a different support representation, adapt to that representation, but preserve the theorem content.

---

## The Main Theorem: Exact Higher-Order Anti-Cancellation

### Mathematical statement

Let `p` be a multivariate polynomial with nonnegative coefficients. Let `A : (σ →₀ ℕ) → R` be a finitely supported weight function supported only on multi-indices of total degree `k`, and assume all active weights are strictly positive. Define

\[
D_A^{(k)}(p) := \sum_{m : |m| = k} A(m)\,\partial^m p.
\]

Then:

\[
\operatorname{supp}(D_A^{(k)}(p))
=
\bigcup_{m \in \operatorname{supp}(A)} \operatorname{shadow}_m(\operatorname{supp}(p)).
\]

This should be stated with exact quantifiers and no ambiguity about finiteness assumptions.

### Lean-style theorem target

A plausible target signature is:

```lean
theorem support_weighted_orderDeriv_eq_kShadow
  {σ : Type*} [Fintype σ] [DecidableEq σ]
  (p : MvPolynomial σ ℝ)
  (k : ℕ)
  (A : (σ →₀ ℕ) →₀ ℝ)
  (hp_nonneg :
    ∀ d : σ →₀ ℕ, MvPolynomial.coeff d p ≥ 0)
  (hA_pos :
    ∀ m, m ∈ A.support → 0 < A m)
  (hA_order :
    ∀ m, m ∈ A.support → m.sum (fun _ n => n) = k) :
  supportOrderDerivAggregate p A
    = weightedKShadow (p.support) A.support
```

You may need to replace `p.support` by a custom finite support object if Mathlib’s native support API is not directly suitable for the derivative aggregate you define.

### Breakthrough significance

This is not just a support lemma. It says that **positive higher-order differential operators act on support exactly by combinatorial erosion, with no hidden cancellation whatsoever**. That is the kind of statement that can feed directly into:
- support lower bounds in arithmetic circuit complexity,
- combinatorial Hodge theoretic invariants of Lorentzian polynomials,
- sparse symbolic differentiation algorithms,
- tropical and Newton-polytope interpretations of derivative operators.

---

## Stronger Corollary Specialized to Lorentzian Polynomials

The Lorentzian hypothesis may not be needed for the bare positivity theorem, but it is essential for the conceptual bridge and for future consequences. You should therefore prove a corollary in the Lorentzian regime, phrased as an extension of the catalog theorem.

### Corollary target

```lean
theorem lorentzian_support_weighted_orderDeriv_eq_kShadow
  {σ : Type*} [Fintype σ] [DecidableEq σ]
  (p : MvPolynomial σ ℝ)
  (k : ℕ)
  (A : (σ →₀ ℕ) →₀ ℝ)
  (hp_lorentzian : IsLorentzian p)
  (hp_nonneg :
    ∀ d : σ →₀ ℕ, MvPolynomial.coeff d p ≥ 0)
  (hA_pos :
    ∀ m, m ∈ A.support → 0 < A m)
  (hA_order :
    ∀ m, m ∈ A.support → m.sum (fun _ n => n) = k) :
  supportOrderDerivAggregate p A
    = weightedKShadow (p.support) A.support
```

If `IsLorentzian` is not yet in the exact required form, define an intermediate predicate tied to the catalog’s Lorentzian infrastructure and prove the corollary through that interface.

### Why this matters

This elevates Theorem A from a second-order curiosity to a **hierarchical principle**: Lorentzian structure rigidifies supports at every level of differentiation. That is the kind of theorem people can build a field on.

---

## A Cross-Domain Theorem: Arithmetic Complexity Lower Bound via k-Shadows

You must include at least one theorem that bridges to another domain. The strongest bridge here is to arithmetic circuit complexity.

### Mathematical idea

If the support of `D_A^{(k)}(p)` is exactly the union of `k`-shadows, then any arithmetic representation of this derivative aggregate must realize at least that many monomials unless additional algebraic structure is present. At a minimum, prove a support-cardinality lower bound.

### Theorem target

Prove a theorem of the form:

```lean
theorem card_support_orderDerivAggregate_ge_card_kShadow
  {σ : Type*} [Fintype σ] [DecidableEq σ]
  (p : MvPolynomial σ ℝ)
  (k : ℕ)
  (A : (σ →₀ ℕ) →₀ ℝ)
  (hp_nonneg :
    ∀ d : σ →₀ ℕ, MvPolynomial.coeff d p ≥ 0)
  (hA_pos :
    ∀ m, m ∈ A.support → 0 < A m)
  (hA_order :
    ∀ m, m ∈ A.support → m.sum (fun _ n => n) = k) :
  (weightedKShadow p.support A.support).card
    ≤ (supportOrderDerivAggregate p A).card
```

and then sharpen it to equality using the main theorem. If possible, add a corollary translating this to a lower bound on the number of monomials in the aggregate derivative.

### Cross-domain significance

This is the seed of a new program:
- combinatorial Hodge theory gives support exactness,
- support exactness yields symbolic sparsity invariants,
- symbolic sparsity invariants feed arithmetic complexity lower bounds.

This is exactly the kind of “I did not expect those fields to meet there” result we want.

---

## A Structural Theorem About Monotonicity of Shadows

To avoid the project collapsing into one isolated equality theorem, prove a genuinely structural theorem about `k`-shadows themselves.

### Candidate theorem

If `T₁ ⊆ T₂`, then `weightedKShadow S T₁ ⊆ weightedKShadow S T₂`.

And more deeply: if `m ≤ n` coordinatewise, then for any support `S`,
\[
\operatorname{shadow}_n(S) \subseteq \operatorname{shadow}_m(S')
\]
for a suitable derived support `S'`, or formulate a precise antitonicity statement in derivative order.

A practical Lean target:

```lean
theorem weightedKShadow_mono
  {σ : Type*} [DecidableEq σ]
  {S : Finset (σ →₀ ℕ)} {T₁ T₂ : Finset (σ →₀ ℕ)}
  (h : T₁ ⊆ T₂) :
  weightedKShadow S T₁ ⊆ weightedKShadow S T₂
```

and at least one nontrivial theorem relating iteration of shadows to addition of derivative multi-indices, e.g.

```lean
theorem derivMultiShadow_add
  {σ : Type*} [DecidableEq σ]
  (S : Finset (σ →₀ ℕ)) (m n : σ →₀ ℕ) :
  derivMultiShadow (derivMultiShadow S m) n
    = derivMultiShadow S (m + n)
```

provided your definition makes this exactly true. This is mathematically important: it says higher-order shadows form a semigroup action of `σ →₀ ℕ` on supports.

### Why it matters

This upgrades the story from one theorem to a calculus. Once shadows compose additively, one can study differential semigroups combinatorially, and that has tropical, polyhedral, and algorithmic consequences.

---

## Proof Architecture: 3 Viable Strategies

You must pursue a serious proof, not a one-line positivity observation. Use at least 2–3 substantial proof components.

### Strategy A: Coefficientwise expansion of iterated partials
Most direct and likely the best formal path.

1. Prove a coefficient formula for multi-derivatives:
   \[
   [x^d](\partial^m p) = c(d,m)\,[x^{d+m}]p
   \]
   where `c(d,m)` is an explicit positive natural-number factor when `m ≤ d+m`.
2. Prove `c(d,m) > 0`, so if `A(m) > 0` and `[x^{d+m}]p > 0`, then the contribution to `[x^d](D_A^{(k)}p)` is positive.
3. Show:
   - if `d` lies in some shadow, then one summand contributes positively, hence `d` is in support;
   - if `d` lies in no shadow, every summand coefficient vanishes, hence `d` is absent from support.

**Why most promising:** It reduces everything to finite support arithmetic and positivity of explicit multiplicity factors. It should interface well with `field_simp`, `calc`, and induction on `k` or on the support of `A`.

### Strategy B: Induction on derivative order using shadow semigroup law
Conceptually elegant and likely useful for future extensions.

1. Prove the first-order support-shadow theorem.
2. Prove composition law:
   `shadow_m (shadow_n S) = shadow_{m+n} S`.
3. Express any active order-`k` derivative as a composition of first-order derivatives and induct on `k`.

**Why attractive:** This gives the right structural explanation and may produce stronger reusable lemmas.  
**Risk:** Aggregating over all multi-indices with weights may force additional bookkeeping.

### Strategy C: Newton polytope / support erosion viewpoint
Best for the paper and future generalization, even if formal proof uses A.

1. Interpret support as a discrete subset of exponent lattice.
2. Derivatives act by coordinatewise erosion by multi-indices.
3. Positive weighted aggregation is then a union of erosions because cancellation is impossible.

**Why valuable:** This gives the right geometric narrative and suggests extensions to tropicalization, Minkowski subtraction, and entropy-like invariants of supports.

Use Strategy A for the main formal theorem, Strategy B for structural lemmas, and Strategy C in `RESEARCH_PAPER.md` and `ARTICLE.md` to explain the conceptual leap.

---

## Required Deep Theorems

Your Lean development must contain **at least 3 substantial theorems** proved by nontrivial tactics. A recommended set is:

1. `derivMultiShadow_add`  
   Proof likely by extensionality on membership, unpacking coordinatewise subtraction/addition, and induction on finitely supported exponents.

2. `support_orderDeriv_subset_weightedKShadow`  
   The “only if” direction: if a monomial survives in the aggregate derivative, it must come from some active derivative shadow.

3. `weightedKShadow_subset_support_orderDeriv`  
   The “if” direction: positivity prevents cancellation, so any point in an active shadow survives.

4. `support_weighted_orderDeriv_eq_kShadow`  
   Main equality by antisymmetry of subsets.

5. `lorentzian_support_weighted_orderDeriv_eq_kShadow`  
   Corollary specialized to Lorentzian polynomials.

6. `card_support_orderDerivAggregate_eq_card_weightedKShadow`  
   Complexity-flavored corollary.

At least 3 of these should use induction / `rcases` / `by_contra` / `field_simp` / multi-step `calc`.

---

## Conjecture and Computational Program

### Falsifiable conjecture
For every Lorentzian polynomial `p` with nonnegative coefficients, every `k ≥ 1`, and every finitely supported positive weight tensor `A` on order-`k` multi-indices,
\[
\operatorname{supp}\!\left(\sum_m A(m)\partial^m p\right)
=
\bigcup_{m \in \operatorname{supp}(A)} \operatorname{shadow}_m(\operatorname{supp}(p)).
\]
For mixed-sign tensors, exactness can fail, and the failure rate increases with overlap complexity of the active shadows.

### Testable prediction
For uniform matroid basis polynomials `U(r,n)` with `n ≤ 7` and `k = 3,4`:
- all-positive weight tensors exhibit **zero** support cancellation,
- mixed-sign weight tensors exhibit **nonzero** cancellation frequency,
- cancellation frequency correlates with the average overlap multiplicity of the active `k`-shadows.

A single positive-regime counterexample falsifies the conjecture.

---

## Computational Deliverable

You must produce a verified algorithm for computing `k`-shadows and aggregate derivative supports.

### Algorithm target
Implement a function that:
1. extracts polynomial support,
2. enumerates active order-`k` multi-indices from the tensor support,
3. computes the union of derivative shadows,
4. computes the actual support of the weighted derivative aggregate,
5. checks equality and reports overlap/cancellation statistics.

A plausible Lean-facing specification:

```lean
def computeKShadow
  {σ : Type*} [Fintype σ] [DecidableEq σ]
  (S : Finset (σ →₀ ℕ))
  (T : Finset (σ →₀ ℕ)) :
  Finset (σ →₀ ℕ)
```

with a correctness theorem:

```lean
theorem computeKShadow_correct
  {σ : Type*} [Fintype σ] [DecidableEq σ]
  (S : Finset (σ →₀ ℕ))
  (T : Finset (σ →₀ ℕ)) :
  computeKShadow S T = weightedKShadow S T
```

And similarly, if feasible, a verified evaluator for the support of the weighted derivative aggregate.

---

## Demo Requirements

Create `demo.py` that:
- constructs uniform matroid basis polynomials `U(r,n)` for small `n`,
- enumerates order-`k` derivative multi-indices for `k = 3,4`,
- samples all-positive and mixed-sign weight tensors,
- computes predicted `k`-shadow support and actual derivative support,
- reports exactness/cancellation statistics,
- visualizes overlap multiplicities of shadows.

The demo should make it easy to search for counterexamples and to observe the positive/mixed-sign dichotomy empirically.

---

## Cross-Domain Connections to Emphasize

1. **Combinatorial Hodge theory ↔ Arithmetic circuit complexity**  
   Lorentzian structure controls support behavior of derivatives, suggesting support-based lower bounds for derivative computations.

2. **Sparse symbolic computation ↔ Polyhedral geometry**  
   `k`-shadows are discrete erosions of support sets, closely related to Newton polytope truncation and Minkowski subtraction.

3. **Tropical geometry ↔ Differential algebra**  
   Support evolution under positive derivative aggregates should admit a tropical interpretation as deterministic support transport without cancellation.

4. **Matroid theory ↔ Higher-order differential operators**  
   Uniform matroid basis polynomials provide a canonical testing ground where support geometry is highly structured but nontrivial.

---

## Application Keywords

Lorentzian polynomials; combinatorial Hodge theory; higher-order partial derivatives; anti-cancellation; support exactness; derivative shadows; arithmetic circuit complexity; sparse symbolic differentiation; Newton polytopes; tropicalization; matroid basis polynomials; positive operators; combinatorial semigroups; support lower bounds.

---

## Concrete Deliverables

You must produce **all** of the following:

1. **Lean file(s)** containing:
   - at least one genuinely new definition,
   - at least 3 nontrivial theorems,
   - the main higher-order anti-cancellation theorem,
   - at least one cross-domain theorem,
   - a stated falsifiable conjecture in comments/docstring form.

2. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions.  
   Each direction must include the exact sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   At least one direction must bridge to a different domain, such as tropical geometry, complexity, statistical physics, or information theory.

3. **`RESEARCH_PAPER.md`** as a standalone scientific paper.  
   It must explain:
   - the theorem statements,
   - why higher-order anti-cancellation is conceptually new,
   - how the proofs work,
   - what the computational experiments show,
   - what open problems come next.

4. **`ARTICLE.md`** in Scientific American style.  
   It must be engaging and broadly accessible.  
   **Taboo:** do not focus on formal verification machinery; focus on the mathematical discovery and why it matters.

5. **A verified algorithm or computational method** for `k`-shadow computation and support checking.

6. **`demo.py`** demonstrating the theorem and conjecture experimentally.

---

## Final Standard

Do not settle for “a generalization of Theorem A.” The ambition is to create the first **support calculus for higher-order positive differential aggregates**. If you succeed, you will have turned Lorentzian positivity into an exact law of combinatorial support transport — a result with immediate consequences for symbolic computation and long-range implications for complexity theory.

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
