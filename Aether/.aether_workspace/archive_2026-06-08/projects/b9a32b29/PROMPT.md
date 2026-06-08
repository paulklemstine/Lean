## Assignment: Direction 5: Dynamic Lorentzian Certificates and Online Sampling

**Mode:** `prove`

You are not being asked for an incremental optimization lemma. You are being asked to create the first formal theory of **dynamic Lorentzian certification**: how a certificate for a strongly log-concave / Lorentzian generating polynomial evolves under local perturbations, and how this evolution controls **online sampling**. The target is a mathematically substantive bridge between algebraic combinatorics, dynamic algorithms, and Markov-chain stability.

Build directly on:

- `Pythagorean/CertificateSampling.lean`
  - `certificate_verification_complexity`
  - `certificateDepth`
- `Catalog/FINAL/Bridges/LorentzianRecognition.lean`
  - `pderiv_isHomogeneous_degree_pred`

The aim is to replace “recompute everything after every update” by a theorem-level understanding of **locality of certificate updates** and **stability of the induced sampling distribution**.

---

## Core Vision

A Lorentzian certificate for a homogeneous polynomial of degree `d` on `n` variables is a tree indexed by iterated partial derivatives down to quadratic forms. A rank-1 update
\[
f' = f + c \, X^\alpha
\]
should not globally disturb this tree. It should only affect those derivative nodes whose multiindex is coordinatewise dominated by `\alpha`. That support-counting principle is the algebraic engine behind a dynamic algorithm.

The breakthrough theorem is not merely “faster update time.” It is the statement that **local algebraic perturbations induce sparse certificate perturbations**, and that these sparse perturbations yield **controlled drift of sampling laws**. This opens a route to streaming matroid sampling, online negative dependence certification, and eventually dynamic high-dimensional expanders / stochastic optimization interfaces.

---

## New Definitions You Must Introduce

You must define at least one genuinely new concept, not already present in the catalog. I want the following formal notions.

### 1. Affected derivative profile
For a monomial exponent vector `α : Fin n → ℕ` and derivative order `k`, define the set of derivative multiindices of total mass `k` that can “see” the update:
\[
\mathrm{Affected}(α,k) := \{ \beta : \mathrm{Fin}\, n \to \mathbb N \mid \sum_i \beta_i = k \;\wedge\; \beta_i \le α_i \ \forall i \}.
\]

Lean target sketch:
```lean
def AffectedMultiindices {n : ℕ} (α : Fin n → ℕ) (k : ℕ) : Set (Fin n → ℕ) :=
  {β | (∑ i, β i) = k ∧ ∀ i, β i ≤ α i}
```

This is the combinatorial shadow of locality.

### 2. Rank-1 polynomial update
Formalize a one-monomial perturbation of a multivariate polynomial:
```lean
def rankOneUpdate {σ : Type*} [DecidableEq σ] [Semiring R]
    (f : MvPolynomial σ R) (c : R) (α : σ →₀ ℕ) : MvPolynomial σ R :=
  f + C c * (α.prod fun s m => X s ^ m)
```
Adapt to the actual monomial constructor already available in Mathlib if preferable.

### 3. Dynamic certificate cost
A function counting only affected nodes, not full rebuild cost:
```lean
def dynamicCertificateCost (n d : ℕ) (α : Fin n → ℕ) : ℕ := ...
```
The exact implementation can be abstract/asymptotic-friendly, but it must support upper bounds in terms of affected derivative counts.

### 4. Warm-start discrepancy
A notion quantifying distance between old and new coefficient distributions / stationary distributions:
```lean
def coeffL1Delta {σ : Type*} [Fintype σ] ...
def warmStartDistance ...
```
You may instantiate this first for finite-support coefficient vectors or for normalized weights on bases of a matroid.

---

## Precise Theorem Targets

You must prove at least **3 nontrivial theorems**, each requiring real proof structure. At least one theorem must connect to another domain.

Below are the theorem statements I want you to aim for. You may adjust hypotheses to match existing Mathlib APIs, but do not weaken the mathematical content.

---

### Theorem 1: Locality of derivative perturbation

**Mathematical statement.**  
Let `f` be homogeneous of degree `d`, and let
\[
f' = f + c X^\alpha
\]
with `|α| = d`. For every derivative multiindex `β` of order `k`, if `β \nleq α` coordinatewise, then
\[
\partial^\beta f' = \partial^\beta f.
\]
Equivalently, only derivative nodes in `Affected(α,k)` can change under the rank-1 update.

This is the foundational locality theorem.

**Lean 4 target signature sketch:**
```lean
theorem iterated_pderiv_rankOneUpdate_eq_of_not_le
    {n d k : ℕ}
    {R : Type*} [CommSemiring R]
    (f : MvPolynomial (Fin n) R)
    (c : R)
    (α β : Fin n → ℕ)
    (hαdeg : (∑ i, α i) = d)
    (hk : (∑ i, β i) = k)
    (hnot : ¬ ∀ i, β i ≤ α i) :
    iteratedPDeriv β (rankOneUpdate f c (Finsupp.ofFunction α)) =
      iteratedPDeriv β f := by
  ...
```

If `iteratedPDeriv` is not already present in the exact form above, define the needed wrapper around repeated partial derivatives. This is acceptable and desirable.

**Why this is a breakthrough.**  
This theorem turns dynamic certification into a sparse update problem. Without it, “dynamic Lorentzian certification” is hand-waving. With it, certificate trees acquire a locality structure analogous to influence cones in dynamic graph algorithms.

**Proof strategy options.**
1. **Direct monomial differentiation route**  
   - Expand `rankOneUpdate`.
   - Use linearity of iterated partial derivatives.
   - Show the iterated derivative of a monomial vanishes unless the derivative exponent is coordinatewise bounded by the monomial exponent.
   - This is likely the cleanest and most robust route in Lean.
2. **Induction on derivative order `k`**  
   - Peel off one derivative at a time.
   - At each step, show once some coordinate has been over-differentiated, the monomial contribution becomes zero permanently.
   - Good if Mathlib APIs for repeated derivatives are recursive.
3. **Finsupp combinatorics + support annihilation**  
   - Represent exponents as `σ →₀ ℕ`.
   - Use support-level lemmas for monomials and derivative coefficients.
   - Most elegant, but probably heavier than necessary.

**Most promising:** Strategy 1. It aligns best with Lean’s algebraic simplification and avoids overengineering.

---

### Theorem 2: Counting affected nodes gives a dynamic complexity upper bound

**Mathematical statement.**  
Let `f` be homogeneous of degree `d`, and let `f' = f + c X^α` be a rank-1 update. Suppose a certificate tree verifies Lorentzian-ness by recursively checking iterated derivatives down to quadratic leaves. Then the number of potentially changed nodes is bounded by
\[
\sum_{k=0}^{d-2} |\mathrm{Affected}(α,k)|.
\]
Consequently, if each affected leaf recomputation costs `O(n²)` and internal recombination cost is linear in the number of affected nodes, then
\[
T_{\mathrm{update}}(f \to f') \le C \, n^2 \sum_{k=0}^{d-2} |\mathrm{Affected}(α,k)|.
\]
For sparse/structured `α`, this improves on rebuild complexity and, in the balanced regime motivating the conjecture, yields the target `O(n^(d-3) · n²)` behavior.

**Lean 4 target signature sketch:**
```lean
theorem dynamic_certificate_cost_le
    {n d : ℕ}
    (α : Fin n → ℕ) :
    dynamicCertificateCost n d α ≤
      n^2 * ∑ k in Finset.range (d - 1), (affectedCount α k) := by
  ...
```

And a second theorem connecting to the existing catalog complexity result:
```lean
theorem dynamic_certificate_cost_le_rebuild
    {n d : ℕ}
    (α : Fin n → ℕ) :
    dynamicCertificateCost n d α ≤ certificate_verification_complexity n d := by
  ...
```

You should state this in whatever parameterization `certificate_verification_complexity` actually uses.

**Why this is a breakthrough.**  
This is the theorem that makes dynamic certification algorithmic rather than existential. It translates algebraic locality into asymptotic savings. It is the missing theorem needed for online use of Lorentzian certificates in evolving combinatorial systems.

**Proof strategy options.**
1. **Structural counting over derivative depth**
   - Use `certificateDepth`.
   - At each depth `k`, only affected multiindices matter by Theorem 1.
   - Sum the counts across depths.
2. **Injective map into full certificate tree**
   - Build an embedding of affected nodes into all certificate nodes.
   - Deduce dynamic cost is bounded by rebuild cost.
   - Strong route for the comparison theorem.
3. **Recurrence on degree**
   - Degree `d` certificate updates reduce to degree `d-1` updates after one derivative layer.
   - Useful if the certificate tree is inductively defined in the catalog.

**Most promising:** Combine 1 and 2. Use 1 for the meaningful dynamic bound and 2 to anchor it to the catalog theorem.

---

### Theorem 3: Homogeneity is preserved under compatible rank-1 updates

**Mathematical statement.**  
If `f` is homogeneous of degree `d` and `|α| = d`, then `f + cX^α` is homogeneous of degree `d`. Moreover, every iterated partial derivative of order `k ≤ d` is homogeneous of degree `d-k`.

This theorem should explicitly leverage `pderiv_isHomogeneous_degree_pred`.

**Lean 4 target signature sketch:**
```lean
theorem rankOneUpdate_isHomogeneous
    {n d : ℕ}
    {R : Type*} [CommSemiring R]
    (f : MvPolynomial (Fin n) R)
    (c : R) (α : Fin n → ℕ)
    (hf : IsHomogeneous f d)
    (hα : (∑ i, α i) = d) :
    IsHomogeneous (rankOneUpdate f c (Finsupp.ofFunction α)) d := by
  ...
```

And the iterated derivative corollary:
```lean
theorem iteratedPDeriv_rankOneUpdate_isHomogeneous
    {n d k : ℕ}
    ...
    (hk : k ≤ d) :
    IsHomogeneous (iteratedPDeriv β (rankOneUpdate f c (Finsupp.ofFunction α))) (d - k) := by
  ...
```

**Why this matters.**  
Dynamic certification only makes sense if updates preserve the class of objects being certified. This theorem ensures the algebraic universe is stable under the dynamic move.

**Proof strategy options.**
1. **Homogeneous sum theorem + monomial degree computation**
2. **Induction on `k` using `pderiv_isHomogeneous_degree_pred`**
3. **Weight grading argument on `MvPolynomial`**

**Most promising:** 1 for the base update theorem, then 2 for the derivative corollary.

---

### Theorem 4: Cross-domain bridge — dynamic updates for graphic matroid basis generating polynomials

This theorem is your required bridge to another domain: graph theory / combinatorial optimization.

**Mathematical statement.**  
Let `G` be a finite graph and let `B_G` be its basis generating polynomial (spanning tree generating polynomial for the graphic matroid). Adding a new edge `e` corresponds to a rank-1 update by summing exactly the monomials of bases newly created by `e`; in the single-basis insertion model, this is a monomial rank-1 update. Therefore the dynamic certificate locality bound applies to edge-stream updates of graphic matroids.

At minimum, prove a clean finite combinatorial special case: if one inserts a single spanning tree monomial into the basis generating polynomial, the set of affected derivative nodes is exactly the coordinatewise-dominated family from Theorem 1.

**Lean 4 target signature sketch:**
```lean
theorem graphicMatroid_singleBasisUpdate_local
    {n : ℕ}
    (α : Fin n → ℕ)
    (hbase : (∑ i, α i) = ???) :
    ∀ β,
      (¬ ∀ i, β i ≤ α i) →
      iteratedPDeriv β (rankOneUpdate graphicBasisPoly 1 (Finsupp.ofFunction α)) =
        iteratedPDeriv β graphicBasisPoly := by
  ...
```

You may need to formulate this with a simplified model of basis generating polynomials as finite sums of squarefree monomials. That is acceptable and still meaningful.

**Why this is revolutionary.**  
This is where the theory exits pure algebra and enters streaming graph algorithms. It says dynamic Lorentzian certification is not abstract ornamentation; it governs evolving network models and online combinatorial sampling.

**Proof strategy options.**
1. Reduce immediately to Theorem 1.
2. Use squarefree structure to sharpen affected-count bounds.
3. Show in the graphic case that `affectedCount` is controlled by binomial coefficients depending on tree size.

**Most promising:** 1 + 2. The reduction is conceptually clean, and squarefree structure gives a stronger application story.

---

### Theorem 5: Warm-start total variation control from coefficient perturbation

You likely will not be able to prove a full sharp mixing-time theorem in one pass without substantial probability infrastructure. But you absolutely can and should prove a rigorous finite-distribution stability theorem that supports the warm-start narrative.

**Mathematical statement.**  
For finite support probability mass functions `μ, ν` on a finite type,
\[
\|\mu - \nu\|_{\mathrm{TV}} \le \frac12 \|\mu - \nu\|_1.
\]
Then specialize to normalized coefficient distributions induced by positive coefficient vectors of homogeneous polynomials:
if coefficient vectors change by `ℓ₁` amount `Δ`, then the warm-start initial discrepancy is bounded by `Δ/(2Z)` up to normalization correction.

**Lean 4 target signature sketch:**
```lean
theorem tv_le_half_l1
    {α : Type*} [Fintype α] [DecidableEq α]
    (μ ν : α → ℝ)
    (hμ : IsProbabilityMassFunction μ)
    (hν : IsProbabilityMassFunction ν) :
    totalVariation μ ν ≤ (1 / 2 : ℝ) * ∑ a, |μ a - ν a| := by
  ...
```

Specialization:
```lean
theorem normalizedCoeffDist_tv_bound
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (w w' : σ → ℝ)
    (hw : ∀ s, 0 ≤ w s)
    (hw' : ∀ s, 0 ≤ w' s)
    (hZ : 0 < ∑ s, w s)
    (hZ' : 0 < ∑ s, w' s) :
    totalVariation (normalize w) (normalize w') ≤
      ((1 / 2 : ℝ) / min (∑ s, w s) (∑ s, w' s)) * ∑ s, |w s - w' s| := by
  ...
```

**Why this matters.**  
This theorem is the probabilistic counterpart to dynamic certificate locality. It gives a rigorous warm-start control mechanism independent of the detailed chain. Once the stationary laws are close, standard mixing inequalities can be layered on top later.

**Proof strategy options.**
1. **Finite-sum inequality route**
   - Expand TV as half of `ℓ₁` or prove the inequality directly from definitions.
   - Then prove the normalization perturbation estimate by triangle inequality and denominator control.
2. **Measure-theoretic route**
   - Overkill unless a ready-made API exists.
3. **Convexity / coupling route**
   - Conceptually nice but less Lean-friendly.

**Most promising:** 1.

---

## Conjecture with a Falsifiable Computational Test

You must state a conjecture that is bold but computationally testable.

### Conjecture: Dynamic Lorentzian warm-start principle
For squarefree homogeneous Lorentzian polynomials `f_t` arising from a stream of graphic matroid updates, if
\[
f_{t+1} = f_t + c_t X^{\alpha_t}
\]
with bounded coefficient perturbation and bounded affected-node fraction, then the natural basis-exchange Markov chain started from stationarity of `f_t` mixes to within `ε` of stationarity for `f_{t+1}` in
\[
O\!\left(\log(1/\varepsilon) + \log\!\frac{1}{1-\delta_t}\right)
\]
steps, where `\delta_t` is controlled by the normalized coefficient `ℓ₁` drift and affected certificate mass.

This is falsifiable: one can generate graphic matroids from edge streams and measure whether warm-start mixing scales asymptotically below cold-start mixing by the predicted factor.

You must include in the file or companion docs a concrete computational disproof protocol:
- graphs on `n = 10, 20, 50, 100`,
- add/delete one edge at a time,
- compare rebuild vs dynamic certificate update cost,
- compare cold-start vs warm-start empirical mixing time,
- report cases where the warm-start advantage collapses.

---

## Required Proof Architecture

Your Lean development must contain at least **3 theorems with deep proof tactics**. Specifically, ensure the proofs genuinely use some of:
- induction,
- `rcases`,
- `by_contra`,
- `field_simp`,
- multi-step `calc`,
- nontrivial case splits.

Suggested mapping:
- Theorem 1: induction on derivative order or recursive monomial argument.
- Theorem 2: `calc` chain from affected-node counting to asymptotic cost bound.
- Theorem 5: `field_simp`, triangle inequalities, normalization denominator estimates.

Do **not** waste one of the theorem slots on a trivial extensionality lemma.

---

## Recommended File Targets

Create a new file along the lines of:

- `Catalog/FINAL/Online/DynamicLorentzianCertificates.lean`

and import the relevant certificate and Lorentzian recognition files.

Potential theorem names:
- `iterated_pderiv_rankOneUpdate_eq_of_not_le`
- `rankOneUpdate_isHomogeneous`
- `dynamic_certificate_cost_le`
- `dynamic_certificate_cost_le_rebuild`
- `tv_le_half_l1`
- `normalizedCoeffDist_tv_bound`
- `graphicMatroid_singleBasisUpdate_local`

---

## Proof Strategy Blueprint

### Strategy A: Algebra-first, then algorithmics
1. Prove the monomial annihilation lemma for iterated partial derivatives.
2. Lift it to rank-1 updates and affected-node locality.
3. Define dynamic cost and derive upper bounds.
4. Add finite-probability stability theorems for warm starts.

**Why promising:** This path gives the cleanest dependency structure and directly exploits `pderiv_isHomogeneous_degree_pred`.

### Strategy B: Certificate-tree induction
1. Formalize certificate nodes by depth.
2. Prove only subtrees rooted at affected derivative nodes can change.
3. Derive cost bounds recursively from subtree sizes.
4. Connect to sampling stability afterward.

**Why promising:** Best if the certificate tree is already inductively encoded in the catalog.

### Strategy C: Graphic-matroid-first specialization
1. Work first with squarefree basis generating polynomials.
2. Prove stronger locality/counting in the squarefree case.
3. Abstract the result to general homogeneous monomial updates.
4. Then add warm-start stability.

**Why promising:** Strongest application story, but riskier if graph/matroid APIs are thin.

**Most promising overall:** Strategy A, with selected application corollaries from Strategy C.

---

## Cross-Domain Connections You Must Highlight

1. **Streaming algorithms:**  
   Dynamic certificate locality is an algebraic analogue of incremental maintenance in dynamic graph data structures.

2. **Markov-chain Monte Carlo:**  
   Warm-start total variation control translates symbolic coefficient drift into quantitative sampler stability.

3. **Matroid theory / combinatorial optimization:**  
   Basis generating polynomials of matroids are canonical Lorentzian objects; dynamic certification yields online sampling of combinatorial structures.

4. **Statistical physics:**  
   Rank-1 updates resemble local energy perturbations in Gibbs ensembles; the normalized coefficient distribution theorem is a finite-state partition-function stability result.

5. **Online learning / stochastic optimization:**  
   The evolving polynomial can be interpreted as a changing regularizer or partition function, suggesting bridges to follow-the-regularized-leader and adaptive sampling.

---

## Application Keywords

Lorentzian polynomials; strong log-concavity; dynamic algorithms; online certification; streaming matroids; graphic matroids; spanning tree sampling; warm-start MCMC; total variation bounds; coefficient stability; partition functions; combinatorial Hodge theory; negative dependence; stochastic optimization; dynamic graph algorithms; online inference.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **`FUTURE_DIRECTIONS.md`**  
   3–5 research directions, each written as original prose and each including:
   - “**The key insight is...**”
   - “**Why now?**”
   At least one direction must bridge to a different domain, such as statistical physics, online learning, or dynamic network science.

2. **`RESEARCH_PAPER.md`**  
   A standalone scientific paper explaining:
   - the dynamic locality theorem for rank-1 updates,
   - the dynamic certificate complexity theorem,
   - the finite-distribution warm-start stability theorem,
   - the graphic matroid application,
   - the conjecture and experimental protocol.

   Someone reading only this document must understand the discovery, why it matters, and what should happen next.

3. **`ARTICLE.md`**  
   Scientific American style. Explain the mathematics and significance to a broad audience.  
   **Taboo:** do **not** focus on formal verification machinery. Focus on the ideas: evolving algebraic certificates, streaming combinatorics, and warm-start sampling.

4. **A verified algorithm or computational method**  
   Implement a dynamic certificate maintenance procedure, not merely a theorem statement. The algorithm should:
   - identify affected derivative nodes from an update monomial,
   - recompute only impacted leaves,
   - compare dynamic update cost with full rebuild cost,
   - expose a warm-start discrepancy estimate from coefficient drift.

5. **`demo.py`**  
   An interactive demonstration that:
   - constructs example homogeneous polynomials / graphic matroid generating polynomials,
   - performs monomial rank-1 updates,
   - displays affected-node counts and update-vs-rebuild cost,
   - simulates warm-start vs cold-start sampling behavior,
   - reproduces the test protocol on growing graph instances.

---

## Standard of Success

Success is not “some helper lemmas about monomials.” Success is a coherent mini-theory with:
- a new dynamic notion (`AffectedMultiindices`, `dynamicCertificateCost`, warm-start discrepancy),
- a locality theorem,
- a dynamic complexity theorem tied to catalog results,
- a probabilistic stability theorem,
- a graph/matroid bridge,
- and an executable experimental story.

The field-opening idea is this:

> **Lorentzian certificates are not static objects. They admit a local update calculus, and that calculus controls online sampling.**

That is the theorem-family worth proving.

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
    "visualizations": [ { "name": "...", "code": "# matplotlib or plotly script, self-contained", "description": "What this visualizes" } ],
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
