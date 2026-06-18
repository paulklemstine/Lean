Soli Deo Gloria

## Assignment: Direction 1 — Tropical Leaf Witnesses and Valuative Invariants

**Mode:** `prove` + `discover`

Build a genuinely new bridge between **Lorentzian/strongly log-concave polynomial theory**, **valued-field tropicalization**, and **spectral witnesses inspired by multipartite quantum correlations**. The target is not a minor variant of existing catalog work: it is to create the first formal theory in Lean 4 showing that a derivative-leaf construction over a valued field admits a **tropical polyhedral shadow** whose combinatorics provably controls a spectral witness.

You should treat the catalog files

- `Catalog/Speculative/AutoResearch/MultiModeLorentzianWitnesses.lean`
- `Catalog/Speculative/AutoResearch/DPPLorentzian.lean`

as the base layer, and then define the missing tropical/valuative layer above them.

---

## Core Vision

For a Lorentzian polynomial \(p\) over a valued field \(K\), and a subsystem \(A\subseteq \{1,\dots,n\}\), the derivative leaf \(L_A\) should admit a tropicalization whose Newton polytope and tropical Hessian define a **tropical leaf witness**. This witness is expected to be a finite polyhedral invariant that upper-bounds the logarithm of the positive spectral witness attached to \(L_A\).

This would be a breakthrough because it replaces an analytic/spectral certification problem by a **finite polyhedral computation**. In effect, it would say:

> complicated positivity data of a derivative leaf can be compressed into a tropical object whose facets remember enough curvature to certify a nontrivial spectral obstruction.

That is not an incremental extension. It opens a new program: **tropical entanglement certificates**, **valuative Lorentzian geometry**, and algorithmic witness extraction from Newton polytopes.

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems**. At least one should be a cross-domain theorem. At least one should involve a genuinely new definition introduced by you.

### New definitions you should introduce

You should define, at minimum, the following new concepts unless equivalent notions already exist in the catalog:

1. `TropicalLeafWitness`
   - a tropical/polyhedral invariant extracted from the tropicalization of a derivative leaf.
2. `tropicalMixedHessian`
   - a tropical analogue of the mixed Hessian, preferably as a max-plus/min-plus second-difference operator on valuations of coefficients.
3. `ValuativeLeafUpperBound`
   - a proposition formalizing that the tropical leaf witness bounds a logarithmic spectral witness.

These are not cosmetic definitions; they should support the theorem statements below.

---

## Theorem 1 — Tropicalization respects derivative leaves

### Mathematical statement
Let \(K\) be a valued field with valuation \(v : K \to \Gamma \cup \{\infty\}\), let \(p\) be a multivariate polynomial over \(K\), and let \(A\) be a subsystem index set. If \(L_A\) is the derivative leaf obtained by differentiating \(p\) in the variables indexed by \(A\), then tropicalization commutes with derivative-leaf formation at the level of coefficient valuations:

\[
\operatorname{Trop}(L_A)(\alpha)
=
\operatorname{TropCoeffDeriv}_A(p,\alpha),
\]
for every exponent vector \(\alpha\) in the support of the derived polynomial.

Interpret this as: the tropical support and coefficient weights of the derivative leaf are determined functorially by the valuation profile of the original polynomial.

### Suggested Lean 4 signature
Use this as a model, adapting names to actual catalog definitions:

```lean
theorem tropicalize_derivativeLeaf_coeff
  {K Γ : Type*} [Field K] [LinearOrderedCommGroupWithZero Γ]
  (v : K → Γ)
  (hv : IsKrullValuation v)
  {σ : Type*} [Fintype σ] [DecidableEq σ]
  (p : MvPolynomial σ K)
  (A : Finset σ)
  (d : σ →₀ ℕ) :
  tropicalCoeff v (derivativeLeaf A p) d =
    tropicalDerivativeCoeff v A p d
```

If the exact derivative leaf in the catalog is not literally `MvPolynomial`-based, adapt the statement to the actual object. But keep the theorem at this level of precision.

### Why this matters
Without this theorem, tropical leaf witnesses are not mathematically anchored. This is the functoriality theorem that makes the whole program legitimate.

---

## Theorem 2 — Newton polytope monotonicity for derivative leaves

### Mathematical statement
Let \(p\) be a Lorentzian polynomial over a valued field and \(A \subseteq B\). Then the Newton polytope of the tropicalized derivative leaf satisfies a monotonicity/face relation of the form

\[
\mathrm{Newt}(\operatorname{Trop}(L_B))
\subseteq
\mathrm{Face}_A\big(\mathrm{Newt}(\operatorname{Trop}(L_A))\big)
\]

or another precise monotonicity relation naturally induced by repeated differentiation.

If a face formulation is too strong in full generality, prove a weaker but still nontrivial statement:

\[
\mathrm{Newt}(\operatorname{Trop}(L_B))
\subseteq
\mathrm{Newt}(\operatorname{Trop}(L_A)) - \chi_{B\setminus A},
\]

where subtraction is exponent translation.

### Suggested Lean 4 signature

```lean
theorem newtonPolytope_tropical_derivativeLeaf_mono
  {K Γ : Type*} [Field K] [LinearOrderedCommGroupWithZero Γ]
  (v : K → Γ) (hv : IsKrullValuation v)
  {σ : Type*} [Fintype σ] [DecidableEq σ]
  (p : MvPolynomial σ K)
  (A B : Finset σ)
  (hAB : A ⊆ B) :
  newtonPolytope (tropicalize v (derivativeLeaf B p)) ⊆
    derivativeFace A B (newtonPolytope (tropicalize v (derivativeLeaf A p)))
```

If `derivativeFace` is your new definition, that is good: this satisfies the novelty requirement.

### Why this matters
This theorem turns leaf witnesses into **polyhedral dynamics** under subsystem restriction. It says that deleting degrees of freedom leaves a geometric trace on Newton polytopes. That is the exact kind of structural theorem that can support algorithms.

---

## Theorem 3 — Tropical Hessian upper bound for spectral witness

### Mathematical statement
Let \(p\) be a Lorentzian polynomial over a valued field \(K\), and let \(A\) be a subsystem. Let \(W_{\mathrm{spec}}(A)\) denote the positive spectral witness of the derivative leaf \(L_A\), and let \(W_{\mathrm{trop}}(A)\) be the tropical leaf witness extracted from the tropical mixed Hessian or Newton polytope. Then under explicit hypotheses ensuring positivity/nondegeneracy,

\[
\log W_{\mathrm{spec}}(A) \le W_{\mathrm{trop}}(A).
\]

A more formal version may involve a constant \(C(A,p)\) or a normalization term:
\[
\log W_{\mathrm{spec}}(A) \le W_{\mathrm{trop}}(A) + C,
\]
but your goal should be the cleanest exact inequality you can prove.

### Suggested Lean 4 signature

```lean
theorem log_spectralWitness_le_tropicalLeafWitness
  {K Γ : Type*} [LinearOrderedField K] [LinearOrderedCommGroupWithZero Γ]
  (v : K → Γ)
  {σ : Type*} [Fintype σ] [DecidableEq σ]
  (p : MvPolynomial σ K)
  (A : Finset σ)
  (hpLor : IsLorentzian p)
  (hpos : 0 < leafWitness A p) :
  Real.log (leafWitness A p) ≤
    tropicalLeafWitness v A p
```

If `leafWitness` from the catalog is not real-valued, formulate the appropriately coerced inequality. If `Real.log` is too rigid for the formal setting, define a logarithmic upper-bound surrogate and prove the bridge theorem to `Real.log` separately.

### Why this matters
This is the flagship theorem. If formalized, it creates the first rigorous passage from spectral positivity to tropical polyhedral control in this setting. It is the theorem that makes the phrase **“tropical entanglement witness”** mathematically meaningful.

---

## Theorem 4 — DPP specialization gives computable witness bounds

### Mathematical statement
For DPP-generated Lorentzian polynomials from `DPPLorentzian.lean`, the tropical leaf witness is algorithmically computable from principal minor valuations, and the spectral bound specializes to a finite combinatorial optimization problem.

A precise theorem could say: for a DPP polynomial \(p_M\) attached to a matrix \(M\) over a valued field,

\[
W_{\mathrm{trop}}(A)
=
\max_{F \in \mathcal{F}_A} \Phi_v(F,M),
\]

for some explicitly defined finite family \(\mathcal{F}_A\) of faces or minors.

### Suggested Lean 4 signature

```lean
theorem tropicalLeafWitness_dpp_eq_max_minor_valuation
  {K Γ : Type*} [Field K] [LinearOrderedCommGroupWithZero Γ]
  (v : K → Γ) (hv : IsKrullValuation v)
  (n : ℕ)
  (M : Matrix (Fin n) (Fin n) K)
  (A : Finset (Fin n)) :
  tropicalLeafWitness v A (dppPolynomial M) =
    Finset.sup (relevantMinorFamily A n) (minorValuationScore v M)
```

### Why this matters
This is the algorithmic theorem. It translates the abstract tropical witness into something you can actually compute for \(n=6,8\), exactly as the conjecture demands.

---

## Cross-Domain Connection Theorem

You are required to include at least one theorem explicitly connecting this program to another domain.

### Recommended choice: matroid/submodularity connection
For DPP polynomials, valuations of principal minors often induce valuated matroid structure. Prove a theorem showing that the tropical leaf witness is controlled by a submodular rank-type functional.

### Mathematical statement
For a DPP polynomial \(p_M\), the tropical leaf witness restricted to subsets defines or is bounded by a submodular set function:

\[
W_{\mathrm{trop}}(A) + W_{\mathrm{trop}}(B)
\ge
W_{\mathrm{trop}}(A\cap B) + W_{\mathrm{trop}}(A\cup B).
\]

### Suggested Lean 4 signature

```lean
theorem tropicalLeafWitness_submodular
  {K Γ : Type*} [Field K] [LinearOrderedCommGroupWithZero Γ]
  (v : K → Γ) (hv : IsKrullValuation v)
  (n : ℕ)
  (M : Matrix (Fin n) (Fin n) K) :
  Submodular (fun A : Finset (Fin n) => tropicalLeafWitness v A (dppPolynomial M))
```

### Why this matters
This is the cross-domain portal:
- **tropical geometry** ↔ **matroid theory**
- **Lorentzian polynomials** ↔ **combinatorial optimization**
- **spectral witness theory** ↔ **discrete convex analysis**

If this lands, it suggests witness certification via greedy/discrete optimization, not continuous diagonalization.

---

## Proof Architecture: 3 possible routes

You must not merely “try something.” Pursue one main strategy and keep two backups.

### Strategy A — Coefficient valuation calculus via derivative support
1. Expand `derivativeLeaf` at the coefficient level.
2. Prove a lemma identifying the support shift under differentiation.
3. Show tropicalization converts multiplication/addition of coefficients into additive/min-plus structure on valuations.
4. Build the tropical witness from these coefficient valuations and derive the upper bound by comparing tropical maxima with classical sums/eigenvalue surrogates.

**Why promising:** This is the most Lean-friendly route. It reduces the main theorems to finite-support combinatorics and `Finsupp` identities.

### Strategy B — Newton polytope / convex-geometric route
1. Define tropicalization via lower hull / weighted support.
2. Show differentiation corresponds to exponent translation plus support truncation.
3. Prove Newton polytope monotonicity and face behavior under derivative leaves.
4. Define the tropical witness as a polyhedral functional and compare it to the spectral witness using Lorentzian concavity inequalities.

**Why promising:** This best captures the conceptual geometry and may produce the strongest theorems. It is likely harder in Lean but gives the deepest payoff.

### Strategy C — DPP-first route via principal minors
1. Specialize immediately to DPP polynomials from `DPPLorentzian.lean`.
2. Express derivative leaves in terms of minors of the kernel matrix.
3. Tropicalize by applying the valuation to minors.
4. Show the witness becomes a finite optimization over valuations of minors; derive the spectral upper bound using determinant/eigenvalue comparison inequalities.

**Why promising:** Best route for executable algorithms and `demo.py`. If the fully general Lorentzian theorem is too ambitious, this route still yields a field-opening result with concrete computational content.

### Recommended order
Start with **Strategy C** for traction and executable mathematics, then abstract the lemmas into **Strategy A**, and only then extract the polyhedral statement of **Strategy B**. This staged approach maximizes the chance of obtaining both theorem-level depth and an actual working computational pipeline.

---

## Required deep proof tactics

Your file must contain at least 3 nontrivial theorems proved with substantial reasoning. You must visibly use several of:

- induction
- `rcases`
- `by_contra`
- `field_simp`
- multi-step `calc`
- decomposition of finite supports
- nontrivial inequalities over `Finset.sup` / maxima
- coercion control between coefficient rings, valuations, and reals

Do **not** satisfy the theorem count with tautologies or finite brute-force decidability.

---

## Conjecture with testable prediction

State and implement the following or a closely related falsifiable conjecture.

### Conjecture
For every DPP Lorentzian polynomial \(p_M\) over \(\mathbb{Q}\) equipped with the \(p\)-adic valuation \(v_p\), and every subset \(A\) of size \(3\) or \(4\), one has

\[
\log W_{\mathrm{spec}}(A) \le W_{\mathrm{trop}}^{(p)}(A),
\]

where \(W_{\mathrm{trop}}^{(p)}(A)\) is the tropical leaf witness computed from the valuation profile of the derivative leaf.

### Computational falsifiability
For \(n=6,8\), enumerate all subsets \(A\) of sizes \(3,4\), compute:
1. the real spectral witness,
2. the \(p\)-adic tropical leaf witness for \(p=2,3,5\),
3. the difference
   \[
   \Delta(A) := W_{\mathrm{trop}}^{(p)}(A) - \log W_{\mathrm{spec}}(A).
   \]

A single subset with \(\Delta(A) < 0\) is a counterexample.

This is an ideal scientific conjecture because it is bold, structural, and easily refutable by experiment.

---

## Implementation targets

You must produce a verified computational method, not just abstract theorems.

### Lean-side algorithm
Implement a function that:
- constructs derivative leaves,
- tropicalizes coefficients using a valuation,
- computes Newton support / polytope surrogate,
- extracts a tropical witness score.

Suggested signatures:

```lean
def tropicalDerivativeLeafData
  {K Γ σ : Type*} [Field K] [LinearOrderedCommGroupWithZero Γ]
  [Fintype σ] [DecidableEq σ]
  (v : K → Γ) (A : Finset σ) (p : MvPolynomial σ K) : TropicalLeafData σ Γ := ...

def tropicalLeafWitness
  {K Γ σ : Type*} [Field K] [LinearOrderedCommGroupWithZero Γ]
  [Fintype σ] [DecidableEq σ]
  (v : K → Γ) (A : Finset σ) (p : MvPolynomial σ K) : ℝ := ...
```

If exact Newton polytopes are too heavy, define a finite combinatorial surrogate first, prove its correctness relative to coefficient data, and explain the upgrade path.

### `demo.py`
Your demo must:
- generate DPP examples over rational matrices,
- compute \(p\)-adic valuations of relevant minors,
- build the tropical leaf witness,
- compare against spectral witness values,
- display counterexamples if found,
- include at least one interactive visualization:
  - subset lattice colored by witness gap, or
  - tropical support points / Newton diagram.

---

## Deliverables (ALL mandatory)

You must produce all of the following:

1. **Lean file(s)** with the new definitions and at least 3 substantial theorems.
2. **A verified algorithm or computational method**, not merely theorem statements.
3. **`demo.py`** demonstrating the witness computation interactively.
4. **`RESEARCH_PAPER.md`** — standalone scientific paper explaining:
   - the definitions,
   - the main theorem(s),
   - why the result matters,
   - the computational experiments,
   - limitations and next steps.
5. **`ARTICLE.md`** — Scientific American style, broad-audience, idea-centered.
   Do **not** focus on formal verification machinery.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original directions.
   Each direction must include:
   - “The key insight is...”
   - “Why now?”
   At least one direction must bridge to a different domain.

---

## Revolutionary significance

If successful, this project opens a new field:

- **tropical witness theory** for Lorentzian polynomials,
- **valuative certificates** for spectral positivity,
- **polyhedral surrogates** for quantum-style witness detection,
- **matroidal optimization methods** for analytic inequalities.

This could trigger follow-on work in:
- tropical Hodge theory,
- discrete convex analysis,
- determinantal processes,
- entanglement-inspired invariants,
- algorithmic certification of strongly log-concave structures.

The truly important possibility is this: one may be able to certify subtle positivity/spectral phenomena **without diagonalizing anything**, using only valuations and polyhedral combinatorics. That is a paradigm shift.

---

## Application keywords

Tropical geometry; Lorentzian polynomials; valued fields; Newton polytopes; determinantal point processes; principal minors; submodularity; valuated matroids; discrete convex analysis; spectral witnesses; multipartite entanglement analogies; polyhedral certification; combinatorial optimization; \(p\)-adic valuation; strong log-concavity; tropical Hessian; mixed discriminants; convex-geometric invariants.

---

## Final directive

Be bold. Do not retreat to toy lemmas. If the fully general theorem is too hard, land the DPP case with enough strength that it is unmistakably a new theory. The standard to aim for is: a mathematician reading only the paper should say, “I did not know tropicalization could control leaf spectral witnesses at all.”

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
