Soli Deo Gloria

## Assignment: Direction 1: Higher-Order Shadow Certificates and Iterated Differentiation

**Mode:** `prove`

Build a genuinely new higher-order support theory for multivariate polynomials over characteristic-zero semirings/fields, centered on the principle that **iterated differentiation is combinatorially controlled by iterated shadows of support**. This should not be a minor extension of the second-order catalog facts: the target is a reusable formal theory of higher-order derivative support, non-cancellation certificates, and computable prediction algorithms.

You should work in Lean 4 with Mathlib and explicitly build on:

- `Pythagorean/NonCancellationCertificate.lean`
  - especially `coeff_pderiv_eq`
  - and any theorem of the form `coeff_pderiv_pderiv_ne_zero_iff` or its nearby support-characterization lemmas
- `Catalog/Bridges/Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean`
  - especially `nonzeroQuadLeafSet_eq_shadow`

The conceptual leap is this:

> For a polynomial `p : MvPolynomial σ ℚ`, the support of every order-`k` partial derivative should be determined purely by the order-`k` shadow of `p.support`, provided one imposes an explicit higher-order non-cancellation certificate. In generic regimes, this certificate should hold automatically on shadow-closed supports.

This is a combinatorial Taylor theory. If true and formalized cleanly, it says that large parts of the higher differential profile of a polynomial are not analytic accidents but **support-theoretic inevitabilities**.

---

## Core New Definitions You Must Introduce

You must define at least one genuinely new concept not already in the catalog. The following package is strongly recommended.

### 1. Iterated shadow along a multi-index
For a finite support set `S : Finset (σ →₀ ℕ)` and a multi-index `γ : σ →₀ ℕ`, define the set of exponents reachable by subtracting `γ` coordinatewise where possible.

Suggested Lean target:
```lean
def subMultiIndex? {σ : Type*} [DecidableEq σ] :
    (σ →₀ ℕ) → (σ →₀ ℕ) → Option (σ →₀ ℕ)
```
or directly
```lean
def shadowAlong {σ : Type*} [DecidableEq σ] :
    Finset (σ →₀ ℕ) → (σ →₀ ℕ) → Finset (σ →₀ ℕ)
```

Mathematically:
\[
\operatorname{Shadow}_\gamma(S)
:= \{\, \alpha - \gamma \mid \alpha \in S,\ \gamma \le \alpha \,\}.
\]

### 2. k-th total shadow
Define the union over all multi-indices of total weight `k`:
\[
\operatorname{Shadow}^{(k)}(S)
:= \bigcup_{|\gamma|=k} \operatorname{Shadow}_\gamma(S).
\]

Suggested Lean target:
```lean
def totalShadowOrder {σ : Type*} [Fintype σ] [DecidableEq σ] :
    ℕ → Finset (σ →₀ ℕ) → Finset (σ →₀ ℕ)
```

### 3. Higher-order non-cancellation certificate
Define a property asserting that whenever two support exponents contribute to the same derivative monomial at order `k`, the resulting coefficient sum is nonzero.

Suggested Lean target:
```lean
def HigherOrderNonCancelCert
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (k : ℕ) (p : MvPolynomial σ ℚ) : Prop := ...
```

A more refined and better formulation is indexed by the derivative multi-index `γ`:

```lean
def NonCancelAlong
    {σ : Type*} [DecidableEq σ]
    (γ : σ →₀ ℕ) (p : MvPolynomial σ ℚ) : Prop := ...
```

where `NonCancelAlong γ p` asserts that for each exponent `β`, the coefficient of `X^β` in the iterated derivative corresponding to `γ` is nonzero iff there exists a support ancestor at `β + γ` with nonzero falling-factorial scalar.

### 4. Shadow-closed support family
Define a structural class of supports on which generic coefficients should force the certificate.

Suggested Lean target:
```lean
def ShadowClosedOrder
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (k : ℕ) (S : Finset (σ →₀ ℕ)) : Prop := ...
```

This should encode a one-ancestor or controlled-ancestor condition at depth `k`.

---

## Precise Theorem Targets

You must prove at least 3 substantial theorems. The following are the recommended flagship statements.

### Theorem 1: Coefficient formula for arbitrary iterated partial derivatives
Formalize the exact coefficient transformation under a derivative multi-index `γ`.

Mathematical statement:
For any polynomial `p : MvPolynomial σ ℚ`, any `β γ : σ →₀ ℕ`,
\[
\operatorname{coeff}\big((\partial^\gamma p),\beta\big)
=
\operatorname{coeff}(p,\beta+\gamma)\cdot
\prod_{i\in \mathrm{supp}(\gamma)} (\beta(i)+\gamma(i))_{\,\gamma(i)},
\]
where \((n)_m\) is the falling factorial.

Suggested Lean 4 type signature:
```lean
theorem coeff_iteratedPDeriv_eq
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℚ) (β γ : σ →₀ ℕ) :
    coeff β (iteratedPDeriv γ p) =
      coeff (β + γ) p * fallingFactorialMulti β γ
```

You may need to define:
```lean
def iteratedPDeriv {σ : Type*} [DecidableEq σ] :
    (σ →₀ ℕ) → MvPolynomial σ ℚ → MvPolynomial σ ℚ

def fallingFactorialMulti {σ : Type*} [DecidableEq σ] :
    (σ →₀ ℕ) → (σ →₀ ℕ) → ℚ
```

A more canonical scalar is
\[
\prod_i \frac{(\beta(i)+\gamma(i))!}{\beta(i)!}.
\]

This theorem is the engine behind everything else.

---

### Theorem 2: Support containment in the higher-order shadow
Mathematical statement:
For every `k`, every order-`k` derivative support lies inside the `k`-th shadow of the original support.

\[
\mathrm{supp}(\partial^\gamma p)
\subseteq \operatorname{Shadow}_\gamma(\mathrm{supp}(p))
\quad\text{for all }\ |\gamma|=k.
\]

Suggested Lean 4 type signature:
```lean
theorem support_iteratedPDeriv_subset_shadowAlong
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℚ) (γ : σ →₀ ℕ) :
    (pderivSupportAlong γ p) ⊆ shadowAlong p.support γ
```

Or if you formalize support as a `Finset`:
```lean
theorem mem_support_iteratedPDeriv_imp_mem_shadow
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    {p : MvPolynomial σ ℚ} {β γ : σ →₀ ℕ} :
    β ∈ (iteratedPDeriv γ p).support →
    β ∈ shadowAlong p.support γ
```

This should use Theorem 1 plus the fact that nonzero coefficient at `β` forces nonzero original coefficient at `β + γ`.

---

### Theorem 3: Exact support recovery under a higher-order non-cancellation certificate
This is the breakthrough theorem.

Mathematical statement:
If `NonCancelAlong γ p` holds, then
\[
\mathrm{supp}(\partial^\gamma p)=\operatorname{Shadow}_\gamma(\mathrm{supp}(p)).
\]

Suggested Lean 4 type signature:
```lean
theorem support_iteratedPDeriv_eq_shadowAlong
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℚ) (γ : σ →₀ ℕ)
    (hcert : NonCancelAlong γ p) :
    (iteratedPDeriv γ p).support = shadowAlong p.support γ
```

This is the exact higher-order analog of the existing second-order result and should explicitly cite the catalog theorem as the `k = 2` precursor.

---

### Theorem 4: Order-k total support recovery
Union over all derivative multi-indices of total degree `k`.

Mathematical statement:
If `HigherOrderNonCancelCert k p` holds, then
\[
\bigcup_{|\gamma|=k} \mathrm{supp}(\partial^\gamma p)
=
\operatorname{Shadow}^{(k)}(\mathrm{supp}(p)).
\]

Suggested Lean 4 type signature:
```lean
theorem total_order_k_derivative_support_eq_totalShadow
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (k : ℕ) (p : MvPolynomial σ ℚ)
    (hcert : HigherOrderNonCancelCert k p) :
    totalDerivativeSupport k p = totalShadowOrder k p.support
```

This is the theorem that upgrades local derivative combinatorics into a global structural invariant.

---

### Theorem 5: Genericity on one-ancestor supports
This theorem creates the bridge from exact algebra to combinatorics.

Mathematical statement:
If every `β` in `Shadow_γ(S)` has at most one ancestor `α ∈ S` with `α - γ = β`, then for every polynomial `p` with support exactly `S`, `NonCancelAlong γ p` holds automatically.

Suggested Lean 4 type signature:
```lean
theorem oneAncestor_implies_NonCancelAlong
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (γ : σ →₀ ℕ) (S : Finset (σ →₀ ℕ))
    (huniq : OneAncestorAlong γ S) :
    ∀ {p : MvPolynomial σ ℚ},
      p.support = S →
      NonCancelAlong γ p
```

This is likely the most elegant route to a strong exact-support theorem without needing measure-theoretic genericity.

---

## Conjecture With Testable Prediction

You must state and computationally investigate the following falsifiable conjecture.

### Conjecture: Generic higher-order exactness on shadow-closed supports
Let `σ` be finite and `S : Finset (σ →₀ ℕ)` be shadow-closed of order `k`. Then for Zariski-generic coefficients on support exactly `S`, the equality
\[
\mathrm{supp}(\partial^\gamma p)=\operatorname{Shadow}_\gamma(S)
\quad\text{for all } |\gamma|=k
\]
holds simultaneously.

Suggested formal conjecture comment/documentation:
```lean
/--
Conjecture: If `S` is shadow-closed of order `k`, then for generic rational
coefficients supported on `S`, every order-`k` partial derivative has support
exactly predicted by the order-`k` shadow.
-/
```

### Computational test
Implement search for `k = 3, 4` on random sparse polynomials in `3–5` variables:
1. sample support sets `S`,
2. sample rational coefficients,
3. enumerate all derivative multi-indices `γ` with total weight `k`,
4. compare actual support of `iteratedPDeriv γ p` against `shadowAlong S γ`,
5. log any failure and analyze whether it comes from genuine cancellation or a bug.

A counterexample must be saved in machine-readable form if found.

---

## Lean 4 Formalization Targets

Use precise, theorem-oriented APIs. A good target namespace would be:
```lean
namespace MvPolynomial
namespace Shadow
```

Potential signatures:
```lean
def iteratedPDeriv {σ : Type*} [DecidableEq σ] :
    (σ →₀ ℕ) → MvPolynomial σ ℚ → MvPolynomial σ ℚ

def fallingFactorialMulti {σ : Type*} [DecidableEq σ] :
    (σ →₀ ℕ) → (σ →₀ ℕ) → ℚ

def shadowAlong {σ : Type*} [DecidableEq σ] :
    Finset (σ →₀ ℕ) → (σ →₀ ℕ) → Finset (σ →₀ ℕ)

def totalShadowOrder {σ : Type*} [Fintype σ] [DecidableEq σ] :
    ℕ → Finset (σ →₀ ℕ) → Finset (σ →₀ ℕ)

def NonCancelAlong {σ : Type*} [Fintype σ] [DecidableEq σ] :
    (σ →₀ ℕ) → MvPolynomial σ ℚ → Prop

def HigherOrderNonCancelCert {σ : Type*} [Fintype σ] [DecidableEq σ] :
    ℕ → MvPolynomial σ ℚ → Prop

def OneAncestorAlong {σ : Type*} [Fintype σ] [DecidableEq σ] :
    (σ →₀ ℕ) → Finset (σ →₀ ℕ) → Prop
```

If Mathlib already has a suitable iterated mixed derivative operator, use it. Otherwise define it recursively on finitely supported multi-indices.

---

## Proof Strategy Architecture

You must present and pursue at least 2–3 proof paths, not a single hint.

### Strategy A: Induction on the derivative multi-index `γ` via single-step coefficient formulas
Most promising.

1. Prove the coefficient identity for one derivative using the catalog theorem `coeff_pderiv_eq`.
2. Define `iteratedPDeriv γ` recursively by peeling off one basis vector from `γ.support`.
3. Induct on `γ.sum (fun _ n => n)` or a well-founded measure on `γ`; at each step, apply `coeff_pderiv_eq` and simplify the scalar factor into the multi falling factorial.
4. Deduce support containment and then exactness under `NonCancelAlong γ p`.

Why promising: it directly reuses certified catalog infrastructure and mirrors the combinatorial meaning of shadows as repeated basis-vector subtraction.

### Strategy B: Monomial-basis expansion and coefficient transport
Conceptually clean, possibly more algebraically robust.

1. Expand `p` as a finite sum over support monomials.
2. Compute `iteratedPDeriv γ` on each monomial `X^(β+γ)` explicitly.
3. Show only monomials with `γ ≤ α` survive, each contributing to exponent `α - γ`.
4. Repackage the surviving terms as the shadow image of support.

Why useful: it may make the exact support theorem more transparent and can isolate cancellation phenomena cleanly.

### Strategy C: Combinatorial ancestor graph
Best for the certificate and genericity layer.

1. Build a bipartite graph from ancestors `α ∈ support p` to descendant exponents `β` with edge `α ↦ β` iff `β + γ = α`.
2. Show derivative coefficients are weighted sums over incoming edges.
3. Prove that if every descendant has in-degree `≤ 1`, then cancellation is impossible.
4. Generalize to bounded in-degree and formulate stronger certificates in terms of nonvanishing weighted path sums.

Why important: this opens the door to combinatorial optimization, random support models, and complexity-theoretic interpretations.

---

## Required Deep Proof Tactics

Your file must contain at least 3 nontrivial theorem proofs using some combination of:
- induction on `k` or on `γ.sum`
- `rcases` on support-membership witnesses
- `by_contra` to prove support exactness or impossibility of cancellation
- `field_simp` for rational coefficient scalar factors
- multi-step `calc` chains to transform coefficient expressions

Do not trivialize the project with finite enumeration. The heart of the work is symbolic structure.

---

## Cross-Domain Connections You Must Include

At least one theorem and the surrounding exposition must explicitly bridge to another domain.

### Bridge 1: Combinatorics of shadows / Kruskal–Katona style growth
Interpret `totalShadowOrder k S` as a higher-order combinatorial shadow operator. Ask whether support-size inequalities analogous to shadow-minimization theorems hold for polynomial derivative complexity.

Possible theorem direction:
- monotonicity of shadow size under inclusion,
- or a lower bound relating number of surviving order-`k` derivatives to combinatorial compression data of the support.

### Bridge 2: Analysis / Taylor expansion geometry
The order-`k` shadow predicts which monomials can appear in the degree-`(d-k)` part of the Taylor jet. This is a discrete model of higher-order local behavior.

Possible theorem direction:
```lean
theorem taylorJetSupport_controlled_by_totalShadow ...
```
Even a formal support-level statement would be meaningful.

### Bridge 3: Complexity theory / arithmetic circuits
Support exactness for all derivatives suggests a combinatorial invariant for sparse polynomial identity testing and lower bounds for depth-restricted arithmetic circuits.

A theorem here could be modest but real:
- if `totalShadowOrder k p.support` is large, then there are many distinct nonzero order-`k` derivatives,
- giving a formal lower bound on derivative space dimension under a uniqueness hypothesis.

Suggested keyword theorem:
```lean
theorem card_totalShadow_le_derivativeFamily_complexity ...
```

This is the strongest cross-domain opportunity: derivative spaces are central in arithmetic complexity.

---

## Why This Would Be a Breakthrough

If you succeed, you will have formalized a new principle:

> **Higher differential structure of sparse multivariate polynomials is, under explicit combinatorial certificates, determined by support alone.**

That is not a routine extension. It opens at least four directions:

1. **Combinatorial Taylor theory:** jets and derivative profiles become shadow-combinatorial objects.
2. **Sparse algebraic complexity:** derivative-space lower bounds can be extracted from support geometry.
3. **Generic algebraic geometry:** support stratifies coefficient space by cancellation behavior.
4. **Algorithmic symbolic computation:** support prediction can avoid full derivative expansion, enabling faster sparse differentiation pipelines.

This is exactly the sort of result that changes what one even tries to measure about a polynomial.

---

## Verified Algorithm / Computational Method

You must produce a verified algorithm, not merely theorem statements.

### Required algorithm
Implement a function that, given:
- a finite variable set,
- a sparse polynomial `p : MvPolynomial σ ℚ`,
- an order `k`,

computes:
1. all derivative multi-indices `γ` with `|γ| = k`,
2. the predicted support `shadowAlong p.support γ`,
3. the actual support `(iteratedPDeriv γ p).support`,
4. a boolean/report certifying equality or identifying the first discrepancy.

Suggested computational interface:
```lean
def auditHigherOrderShadow
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (k : ℕ) (p : MvPolynomial σ ℚ) :
    List ((σ →₀ ℕ) × Finset (σ →₀ ℕ) × Finset (σ →₀ ℕ))
```

Then expose this in `demo.py`.

---

## demo.py Requirements

Your `demo.py` must:
1. generate random sparse polynomials in `3–5` variables,
2. compute order-`3` and order-`4` shadows,
3. compare predicted vs actual derivative supports,
4. display ancestor collisions causing possible cancellation,
5. attempt to search for counterexamples to the genericity conjecture,
6. print a concise scientific summary.

The demo should feel like an experimental mathematics lab, not a unit test.

---

## Mandatory Deliverables

You must produce **all** of the following.

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**
At least one direction must bridge to a different domain such as arithmetic complexity, combinatorial commutative algebra, or local analytic geometry.

### 2. `RESEARCH_PAPER.md`
A standalone scientific document. Someone reading only this file must understand:
- the new definitions,
- the main theorems,
- proof architecture,
- computational experiments,
- why the results matter,
- what the next conjectures are.

Do not assume access to Lean code.

### 3. `ARTICLE.md`
Write in Scientific American style:
- engaging,
- concept-driven,
- broad-audience accessible,
- focused on the mathematical ideas and significance.

**Taboo:** do **not** focus on formal verification machinery. The story is about higher-order shadows controlling differentiation.

### 4. Verified algorithm / computational method
As above: a support-prediction and audit procedure for higher-order derivatives.

### 5. `demo.py`
Interactive experimental demonstration of the theory.

---

## Application Keywords

Use and emphasize these keywords in exposition, naming, and paper metadata:

- higher-order shadows
- iterated differentiation
- sparse polynomials
- multivariate support theory
- non-cancellation certificates
- combinatorial Taylor theory
- derivative support exactness
- arithmetic complexity
- shadow-closed supports
- generic coefficient regimes
- sparse symbolic computation
- mixed partial derivatives
- finite-support combinatorics
- Taylor jet geometry
- support-driven algorithms

---

## Final Call

Do not settle for “the `k`-th derivative support is contained in a shadow.” That is only the entry point. The real target is a new support calculus for higher derivatives, with exactness criteria, genericity principles, and an executable audit algorithm. Prove the coefficient transport law. Prove exact support recovery under a higher-order certificate. Build the ancestor-graph viewpoint. Then use computation to test the frontier at `k = 3, 4`.

If you can make higher-order differentiation combinatorial in this precise sense, you will have created a new invariant language for sparse polynomials.

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
