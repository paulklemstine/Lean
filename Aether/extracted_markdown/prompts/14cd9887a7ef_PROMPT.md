Soli Deo Gloria

## Assignment: Direction 2 — Lorentzian Minor Closure Conjecture

**Mode:** prove / discover

Prove genuinely new, non-trivial theorems around the following central conjecture, and do so in a way that opens a classification program rather than merely checking examples.

## Central Vision

The combinatorial support of a Lorentzian polynomial already remembers deep Hodge-theoretic positivity. We know from the catalog that the **exchange shadow** of Lorentzianity is minor-closed. The next leap is to determine whether the **full Lorentzian package** — including the rank-one-negative Hessian signature constraints on all iterated degree-2 derivatives — also survives passage to minors.

If true, this would elevate Lorentzian supports from an analytic curiosity to a **minor-closed combinatorial species**, placing them beside matroids, delta-matroids, and jump systems as objects admitting structural decomposition, forbidden-minor heuristics, and inductive recognition algorithms. That would create a new bridge from **Hodge theory and hyperbolic-type inequalities** to **combinatorial minor theory**.

---

## Main Conjecture

Let `S : Finset (σ →₀ ℕ)` be the support of a homogeneous Lorentzian polynomial on finitely many variables. For any deletion/contraction minor `T` of `S`, there exists a homogeneous Lorentzian polynomial whose support is exactly `T`.

In mathematical form:

> **Lorentzian Minor Closure Conjecture.**  
> For every finite variable set `σ`, every degree `d : ℕ`, every coefficient function
> `a : (σ →₀ ℕ) → ℝ`, if the homogeneous polynomial
> \[
> f = \sum_{\alpha,\ |\alpha|=d} a(\alpha)\, x^\alpha
> \]
> is Brändén–Huh Lorentzian and `S = supp(f)`, then for every minor `T` of `S` obtained by iterated deletion and contraction, there exists a coefficient function `b` such that
> \[
> g = \sum_{\beta} b(\beta)\, x^\beta
> \]
> is Brändén–Huh Lorentzian and `supp(g) = T`.

This should be attacked first for **support minors induced by coordinate deletion and degree-lowering contraction**, then generalized to iterated minors.

---

## Precise Lean 4 Formalization Targets

You should introduce at least one genuinely new definition capturing “support realizability by a Lorentzian polynomial” and then prove closure theorems for it.

### New definitions to add

A support-level realizability predicate:
```lean
def IsLorentzianSupport
    {σ : Type*} [DecidableEq σ] [Fintype σ]
    (d : ℕ) (S : Finset (σ →₀ ℕ)) : Prop :=
  ∃ a : (σ →₀ ℕ) → ℝ,
    IsBrandenHuhLorentzian d a ∧
    supportOfCoeff d a = S
```

A one-step deletion operation on supports:
```lean
def supportDelete
    {σ : Type*} [DecidableEq σ]
    (i : σ) (S : Finset (σ →₀ ℕ)) : Finset (σ →₀ ℕ) := ...
```

A one-step contraction operation on supports:
```lean
def supportContract
    {σ : Type*} [DecidableEq σ]
    (i : σ) (S : Finset (σ →₀ ℕ)) : Finset (σ →₀ ℕ) := ...
```

An inductively generated minor relation:
```lean
inductive IsSupportMinor
    {σ : Type*} [DecidableEq σ] : Finset (σ →₀ ℕ) → Finset (σ →₀ ℕ) → Prop
| refl (S) : IsSupportMinor S S
| delete_step (S T : Finset (σ →₀ ℕ)) (i : σ) :
    IsSupportMinor (supportDelete i S) T → IsSupportMinor S T
| contract_step (S T : Finset (σ →₀ ℕ)) (i : σ) :
    IsSupportMinor (supportContract i S) T → IsSupportMinor S T
```

A stronger realizability class isolating the “all positive coefficients” regime, which may be the right induction invariant:
```lean
def IsPositiveLorentzianSupport
    {σ : Type*} [DecidableEq σ] [Fintype σ]
    (d : ℕ) (S : Finset (σ →₀ ℕ)) : Prop :=
  ∃ a : (σ →₀ ℕ) → ℝ,
    IsBrandenHuhLorentzian d a ∧
    (∀ m ∈ S, 0 < a m) ∧
    supportOfCoeff d a = S
```

This strengthened notion may be more stable under perturbation and may let you use openness of strict Hessian inequalities.

---

## Required Theorems

You must prove **at least 3 nontrivial theorems**, and they should involve real proof architecture: induction on the minor relation, `rcases` decomposition of Lorentzian witnesses, contradiction arguments to show support exactness, and multi-step `calc` reasoning for derivative/support interactions.

### Theorem 1: Deletion preserves Lorentzian support realizability
This is the first decisive step and likely the easiest entry point.

```lean
theorem IsLorentzianSupport.delete
    {σ : Type*} [DecidableEq σ] [Fintype σ]
    {d : ℕ} {S : Finset (σ →₀ ℕ)} :
    IsLorentzianSupport d S →
    ∀ i : σ, IsLorentzianSupport d (supportDelete i S) := by
  ...
```

#### Intended mathematical content
If `f` is Lorentzian, then the polynomial obtained by setting `x_i = 0` is again Lorentzian; its support is exactly the deletion minor. This is the support-level shadow of coordinate restriction preserving Lorentzianity.

#### Why this matters
Deletion is the “easy” minor operation. Once formalized cleanly, it gives a reusable API for support transport through coordinate restriction and will likely feed directly into the full minor induction theorem.

---

### Theorem 2: Contraction preserves Lorentzian support realizability in the derivative-realizable regime
You may need to prove this first under a positivity/nondegeneracy hypothesis.

```lean
theorem IsPositiveLorentzianSupport.contract
    {σ : Type*} [DecidableEq σ] [Fintype σ]
    {d : ℕ} {S : Finset (σ →₀ ℕ)} (hd : 1 ≤ d) :
    IsPositiveLorentzianSupport d S →
    ∀ i : σ, IsLorentzianSupport (d - 1) (supportContract i S) := by
  ...
```

#### Intended mathematical content
Contraction should correspond to taking the partial derivative `∂ᵢ f`. For Lorentzian polynomials, directional derivatives preserve Lorentzianity. The subtle point is support exactness: if coefficients are positive on support, differentiation does not accidentally annihilate monomials that should survive.

#### Why this matters
Contraction is where the analytic strength of Lorentzianity becomes visible. Proving even a restricted contraction theorem would already be a substantial breakthrough, because it converts analytic closure of the Lorentzian cone into a **combinatorial minor operation on supports**.

---

### Theorem 3: Minor closure under iterated deletion/contraction
This should be the flagship theorem, at least in a restricted regime if the full conjecture resists completion.

```lean
theorem IsPositiveLorentzianSupport.of_minor
    {σ : Type*} [DecidableEq σ] [Fintype σ]
    {d : ℕ} {S T : Finset (σ →₀ ℕ)} :
    IsSupportMinor S T →
    IsPositiveLorentzianSupport d S →
    ∃ e ≤ d, IsLorentzianSupport e T := by
  ...
```

A sharper version, if achievable:
```lean
theorem IsPositiveLorentzianSupport.minor_closed
    {σ : Type*} [DecidableEq σ] [Fintype σ]
    {d : ℕ} {S T : Finset (σ →₀ ℕ)} :
    IsSupportMinor S T →
    IsPositiveLorentzianSupport d S →
    IsLorentzianSupport (minorDegreeShift d S T) T := by
  ...
```

#### Intended mathematical content
Iterate Theorems 1 and 2 along the inductive minor relation. This creates a true minor-closure theorem for a support-realizability class, not merely for exchange.

#### Why this matters
This is the theorem that changes the landscape: it says Lorentzian support realizability behaves structurally like a combinatorial theory, not just a property of coefficients.

---

## Cross-Domain Theorem Requirement

You must include at least one theorem explicitly connecting this theory to a different domain. The strongest natural bridge here is to **matroid/Hodge theory** or to **spectral graph theory / negative dependence**.

### Candidate cross-domain theorem A: Matroid basis supports are minor-stable Lorentzian supports
If the catalog already contains the Lorentzianity of basis generating polynomials, prove a support-level corollary.

```lean
theorem matroid_basis_support_is_lorentzian_minor_closed
    {α : Type*} [DecidableEq α] [Fintype α]
    (M : Matroid α) :
    ∀ N, N ≤m M →
      IsLorentzianSupport (Matroid.rank N) (basisSupport N) := by
  ...
```

This would connect:
- Lorentzian polynomials
- matroid minors
- Hodge-theoretic log-concavity
- combinatorial support geometry

### Candidate cross-domain theorem B: Stable/HPP polynomials induce Lorentzian-support minors
If the catalog has enough stable polynomial infrastructure, prove a transfer theorem:
```lean
theorem stable_homogeneous_support_minor_lorentzian
    {σ : Type*} [DecidableEq σ] [Fintype σ]
    {d : ℕ} {a : (σ →₀ ℕ) → ℝ} :
    IsHomogeneousStable d a →
    IsSupportMinor (supportOfCoeff d a) T →
    ∃ e, IsLorentzianSupport e T := by
  ...
```

This would bridge:
- complex stability theory
- real algebraic geometry
- combinatorial minor systems

### Candidate cross-domain theorem C: Graph reliability / spanning tree support minors
For a graph `G`, the spanning-tree generating polynomial is Lorentzian. Show support minors correspond to graph deletion/contraction minors in a support-realizable sense. This would connect:
- graph minors
- electrical network theory
- Lorentzian support geometry

If one of these is formalizable with current Mathlib + catalog assets, pursue it aggressively. This is the kind of theorem that makes people say, “I did not expect support minor theory and Hodge-Riemann geometry to lock together so cleanly.”

---

## Proof Strategy Architecture

You asked for 2–3 proof strategy steps. Here are three viable routes. You should explicitly choose one primary route and keep the others as fallback/generalization paths.

### Strategy A: Direct analytic transport via restriction and differentiation
**Best first route.**

1. **Deletion via restriction:**  
   Given a Lorentzian witness `a`, define `a_del` by zeroing monomials with positive exponent at coordinate `i`, equivalently restricting `f` to `x_i = 0`. Prove:
   - homogeneity is preserved,
   - Lorentzianity is preserved under coordinate restriction,
   - support transforms exactly to `supportDelete i S`.

2. **Contraction via derivative:**  
   Define `a_contr` from coefficients of `∂ᵢ f`. Use the catalog Lorentzian derivative preservation theorem from `Catalog/Pythagorean/LorentzianRecognitionComplete.lean`. Then prove exact support identification:
   - monomials with exponent zero at `i` vanish,
   - monomials with exponent `k+1` map to derivative monomials with coefficient `(k+1) a(m + single i 1)`,
   - positivity ensures no unexpected cancellation.

3. **Induct on `IsSupportMinor`:**  
   Use the above closure steps recursively to build a witness polynomial for every minor.

**Why this is most promising:**  
It aligns perfectly with the Brändén–Huh definition: Lorentzianity is engineered to be stable under derivatives, and deletion is an elementary specialization. It also meshes best with Lean because restriction and derivative are concrete coefficient transformations.

---

### Strategy B: Work at the support-recognition layer using exchange + local rank-two realizability
This is more speculative but could be profound.

1. Use `SupportSatisfiesExchange` and `exchange_of_minor` from the catalog to show every minor satisfies the combinatorial skeleton already known for Lorentzian supports.

2. Introduce a new local criterion: a support is **rank-two Lorentzian-locally realizable** if every degree-2 iterated derivative pattern admits a quadratic witness with the required Hessian signature.

3. Prove that exchange + local rank-two realizability is minor-closed and implies global Lorentzian realizability for some class (e.g. positive homogeneous supports, M-convex supports, sparse supports).

**Why this matters:**  
If successful, it gives a purely combinatorial recognition theorem for Lorentzian supports. That would be bigger than the original conjecture: it would replace analytic witnesses by a finite support test.

**Why it is riskier:**  
The globalization step from local rank-two realizability to full Lorentzianity may require nontrivial patching arguments not yet in the catalog.

---

### Strategy C: Deformation/openness argument in the positive cone
This is the right route if support exactness becomes the bottleneck.

1. Show strict Lorentzian inequalities are open in coefficient space on a fixed support.
2. For deletion/contraction supports, build a natural coefficient candidate by restriction/differentiation.
3. If support collapses because of zero coefficients, perturb within the positive cone while preserving Lorentzianity and support shape.

**Why this is powerful:**  
It turns exact-support realization into a robust geometric problem in a semialgebraic cone, and may allow you to prove the conjecture for all supports admitting a positive Lorentzian realization.

**Why it is subtle:**  
You will need a careful Lean formalization of “small perturbation preserves Hessian signature,” which may be heavy unless the catalog already contains enough real-analysis infrastructure.

---

## Catalog Build Instructions

You must build explicitly on:

- `Catalog/Pythagorean/LorentzianRecognitionComplete.lean`
  - especially `SupportSatisfiesExchange`
  - and the predicate/theorems around `IsBrandenHuhLorentzian`

- `Catalog/Pythagorean/SupportMinorTheory.lean`
  - especially `exchange_of_minor`

Do not merely cite them. Use them structurally:
- use `SupportSatisfiesExchange` to derive that every Lorentzian support satisfies the exchange axiom;
- use `exchange_of_minor` to show the combinatorial shadow already survives minors;
- then prove new theorems showing analytic realizability also survives, at least under positivity or derivative-nondegeneracy hypotheses.

A good theorem chain is:

1. Lorentzian support ⇒ exchange support  
2. exchange support ⇒ every minor exchange support  
3. positive Lorentzian support ⇒ deletion/contraction realizable minor  
4. therefore every minor of a positive Lorentzian support is both exchange and Lorentzian-realizable

This is not incremental; it is the first real synthesis of support minor theory with Lorentzian analytic structure.

---

## Conjecture with Testable Prediction

You must state and investigate at least one falsifiable conjecture. Use this one:

> **Conjecture (Positive Realization Minor Closure).**  
> Every minor of a positive Lorentzian support is itself a positive Lorentzian support.

Lean-facing statement:
```lean
conjecture positive_lorentzian_support_minor_closed
    {σ : Type*} [DecidableEq σ] [Fintype σ]
    {d : ℕ} {S T : Finset (σ →₀ ℕ)} :
    IsSupportMinor S T →
    IsPositiveLorentzianSupport d S →
    ∃ e ≤ d, IsPositiveLorentzianSupport e T
```

### Computational test
Implement a search that can disprove this:
1. Enumerate supports of `e_k(x₁,…,xₙ)` and their minors for `n ≤ 7`, `k ≤ 4`.
2. For each minor support, solve for positive coefficients satisfying the Lorentzian recognition inequalities from `LorentzianRecognitionComplete.lean`.
3. If infeasible, record the support as a candidate counterexample.
4. Compare with exchange-only realizability to isolate whether failure is analytic rather than combinatorial.

A stronger prediction to test:
- Every minor of a support arising from an elementary symmetric polynomial is again realizable by a **positive** Lorentzian polynomial with rational coefficients.

That is crisp, computationally testable, and genuinely falsifiable.

---

## Concrete Lean File Goals

Your Lean development should include:

- new support-level definitions (`IsLorentzianSupport`, `supportDelete`, `supportContract`, `IsSupportMinor`, possibly `IsPositiveLorentzianSupport`);
- at least 3 substantial theorems with nontrivial proofs;
- one cross-domain theorem;
- one explicitly stated conjecture in Lean comments or as a `conjecture`/`axiom` placeholder marked for future attack;
- minimal sorry usage, with every remaining sorry documented by exact obstruction.

Avoid toy lemmas whose proof is just simplification. The value here is in the transport theorems and the induction on minors.

---

## Suggested Theorem Flow in the File

1. `supportDelete_spec`  
   Characterize membership in `supportDelete i S`.

2. `supportContract_spec`  
   Characterize membership in `supportContract i S` via exponent decrement / derivative image.

3. `lorentzian_restrict_coordinate`  
   Restriction preserves Lorentzianity.

4. `lorentzian_partial_derivative`  
   Partial derivative preserves Lorentzianity.

5. `IsLorentzianSupport.delete`

6. `IsPositiveLorentzianSupport.contract`

7. `IsPositiveLorentzianSupport.of_minor`  
   By induction on `IsSupportMinor`.

8. Cross-domain theorem:
   either matroid basis supports, graph spanning tree supports, or stable polynomial supports.

This creates a clean ascent from local coefficient transport to global minor structure.

---

## Revolutionary Significance

If you can prove even a positivity-restricted version of the conjecture, you will have opened a new field:

- **Minor theory for Lorentzian supports:** the beginning of forbidden-minor classification for Hodge-theoretic combinatorial geometries.
- **Algorithmic recognition:** recursive certification of Lorentzian support realizability via minor decomposition.
- **Matroid/Hodge synthesis:** a unifying language for matroid basis supports, stable polynomials, and negative dependence.
- **Algebraic statistics / optimization:** support-level closure properties could drive new sparse log-concavity certificates and combinatorial convexity algorithms.
- **Spectral and physical interpretations:** Lorentzianity encodes one-negative-direction Hessian behavior, suggestive of energy landscapes, hyperbolicity cones, and entropy-like inequalities.

This is precisely the kind of theorem that transforms a property into a theory.

---

## Application Keywords

Lorentzian polynomials; Brändén–Huh theory; support minor theory; deletion–contraction; exchange axiom; matroid minors; Hodge theory; log-concavity; hyperbolic polynomials; stable polynomials; negative dependence; combinatorial species; semialgebraic cones; sparse polynomial optimization; spectral graph theory.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **`FUTURE_DIRECTIONS.md`**  
   Include 3–5 original research directions. Each direction must contain the exact sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   At least one direction must bridge to a different domain, such as graph minors, statistical physics, or algebraic statistics.

2. **`RESEARCH_PAPER.md`**  
   A standalone scientific paper. Someone reading only this document must understand:
   - the conjecture,
   - what was proved,
   - the proof architecture,
   - why it matters,
   - and what to investigate next.

3. **`ARTICLE.md`**  
   Scientific American style. Make it vivid and concept-driven.  
   **Taboo:** do **not** focus on formal verification machinery. Focus on the mathematics, the surprise, and the broader meaning.

4. **A verified algorithm or computational method**  
   Not just theorem statements. You must implement a method to:
   - generate support minors,
   - test exchange,
   - attempt Lorentzian realization using catalog recognition criteria,
   - and report candidate counterexamples.

5. **`demo.py`**  
   Interactive demonstration:
   - choose a seed Lorentzian support (e.g. elementary symmetric support),
   - generate minors,
   - classify each as exchange / realized / unresolved,
   - and visualize the minor lattice or dependency graph.

This is not optional. The scientific loop is:
**hypothesize → experiment → analyze → refine**.

---

## Final Charge

Do not settle for proving that exchange survives minors again. That is the shadow. Prove that **analytic positivity descends through combinatorial surgery**. Even a restricted theorem here would be the first real evidence that Lorentzian support theory has the same recursive backbone that made matroid theory so powerful. That is the breakthrough.

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
