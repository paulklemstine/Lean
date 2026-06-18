## Assignment: Coefficient extraction as a formal Combinatorial Nullstellensatz engine

Mode: **prove**

Prove a genuinely new theorem package that turns the “nonzero top coefficient forces a nonvanishing evaluation on a grid” principle into a reusable Lean 4 coefficient-extraction framework. Do not stop at the classical statement: formalize the mechanism that makes it work, so it becomes a bridge theorem usable in combinatorics, arithmetic visibility, sparse interpolation, and tropical/discrete analysis.

Minimize `sorry`. If a full strongest theorem is too costly, prove the strongest clean special case over a field first, then generalize.

---

## Research Direction

The decisive idea is that the Combinatorial Nullstellensatz is not merely an existence theorem: it is a **coefficient extraction identity**. For finite sets `S i`, the coefficient of the monomial `∏ i, X_i^(|S i|-1)` is recoverable from evaluations of `f` on the Cartesian grid `∏ i, S i`, weighted by inverse derivatives of the vanishing polynomial
\[
g_i(T) := \prod_{s \in S_i} (T - s).
\]
This is the hidden interpolation operator behind Alon’s theorem.

Your goal is to formalize this operator and derive nonvanishing as a corollary. This would be a breakthrough because it upgrades a famous combinatorial existence principle into an explicit algebraic transform in Lean, opening a path to certified finite-field incidence bounds, additive combinatorics, sparse polynomial recovery, and even tropicalized analogues.

---

## Primary Theorem Targets

Work over a field `K`, finite index type `ι`, and multivariate polynomials `MvPolynomial ι K`.

Let `S : ι → Finset K`, assume each `S i` is nonempty and has pairwise distinct elements automatically via `Finset`. Define the target multi-index
\[
d(i) := |S_i| - 1.
\]

### Theorem A: Weighted coefficient extraction on a grid

Formal target mathematical statement:

For every polynomial `f : MvPolynomial ι K` such that for all `i`,
\[
\deg_{X_i}(f) \le |S_i|-1,
\]
the coefficient of the monomial `∏ i X_i^{|S_i|-1}` equals
\[
\sum_{x \in \prod_i S_i} \frac{f(x)}{\prod_i g_i'(x_i)},
\]
where `g_i(T) = ∏_{s ∈ S_i} (T - s)` and `g_i'(x_i) = ∏_{t ∈ S_i,\, t \ne x_i} (x_i - t)`.

This is the real engine. It is stronger and more reusable than the usual Nullstellensatz consequence.

### Suggested Lean 4 type signature for Theorem A

You may need to introduce auxiliary definitions for grid enumeration and Lagrange denominators.

A plausible target shape is:

```lean
theorem coeff_eq_sum_eval_div_lagrangeDen
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {K : Type*} [Field K]
    (S : ι → Finset K)
    (hS : ∀ i, S i.Nonempty)
    (f : MvPolynomial ι K)
    (hdeg : ∀ i, f.degrees i ≤ S i.card - 1) :
    MvPolynomial.coeff (Pi.single fun i => S i.card - 1) f
      =
    ∑ x in (univ.pi S).toFinset,
      eval x f / ∏ i, ∏ y in (S i).erase (x i), (x i - y)
```

This signature will almost certainly need adjustment because:
- `f.degrees i` may not be the exact Mathlib API you want; `finDegree` or a coefficient-vanishing formulation may be easier.
- `univ.pi S` and conversion to a `Finset` of functions may require a concrete helper.
- the monomial exponent should be represented by a finitely supported function, likely
  `Finsupp.single`/`Pi`-style construction over `ι →₀ ℕ`.

If the exact coefficient-extraction identity is too ambitious initially, first prove the univariate version in `Polynomial K`, then the finite-product multivariate version by iterated extraction.

---

### Theorem B: Combinatorial Nullstellensatz as a corollary

Formal statement:

If `coeff d f ≠ 0`, where `d i = |S i| - 1`, and
\[
\sum_i d(i) = \deg(f),
\]
or more generally every variable degree is bounded by `d(i)`,
then there exists `x ∈ ∏ i, S i` such that `eval x f ≠ 0`.

### Suggested Lean 4 type signature for Theorem B

```lean
theorem exists_eval_ne_zero_of_coeff_ne_zero
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {K : Type*} [Field K]
    (S : ι → Finset K)
    (hS : ∀ i, S i.Nonempty)
    (f : MvPolynomial ι K)
    (hdeg : ∀ i, f.degrees i ≤ S i.card - 1)
    (hcoeff :
      MvPolynomial.coeff (Pi.single fun i => S i.card - 1) f ≠ 0) :
    ∃ x ∈ (univ.pi S).toFinset, eval x f ≠ 0
```

Again, adapt exponent encoding and grid finset representation to Mathlib reality.

This theorem is already nontrivial and valuable if fully formalized.

---

### Theorem C: Vanishing criterion on a grid implies divisibility by grid polynomials

This is the structural converse that makes the coefficient theorem feel inevitable.

For one distinguished variable `i₀`, if `f` vanishes for all substitutions of `X_{i₀}` by elements of `S i₀` while the other coordinates are arbitrary, then
\[
\prod_{s \in S_{i₀}} (X_{i₀} - s)
\]
divides `f` in `MvPolynomial ι K`.

This is the algebraic heart of the induction proof and gives a reusable divisibility API.

### Suggested Lean 4 type signature for Theorem C

```lean
theorem prod_X_sub_C_dvd_of_eval_eq_zero
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {K : Type*} [Field K]
    (i : ι) (S : Finset K) (f : MvPolynomial ι K)
    (hvanish :
      ∀ x : ι → K, ∀ s ∈ S,
        eval (Function.update x i s) f = 0) :
    (∏ s in S, (X i - C s)) ∣ f
```

This theorem may require proving a univariate divisibility statement after viewing `f` as a polynomial in `X i` with coefficients in the subring generated by other variables.

---

## Why this is a breakthrough

Formalizing coefficient extraction at this level does more than reprove a classical theorem.

1. **It creates a certified interpolation transform** for multivariate polynomials on finite grids.
2. **It opens formal additive combinatorics**: sumset lower bounds, polynomial method incidence results, restricted sum problems.
3. **It connects algebra to computation**: sparse recovery and finite-grid identifiability become formal consequences.
4. **It invites tropicalization**: replacing additive/multiplicative structures with min-plus analogues suggests a future “tropical Nullstellensatz as support extraction.”
5. **It bridges to the catalog**: coefficient extraction is a hidden common language for arithmetic visibility, proof mining bounds, and cryptographic extraction.

---

## Proof Strategy Architecture

### Strategy A: Iterated univariate Lagrange extraction
Most promising.

1. Prove the univariate identity:
   for `p : Polynomial K` with `natDegree p < S.card`,
   \[
   [X^{|S|-1}]p = \sum_{s\in S} \frac{p(s)}{\prod_{t\in S, t\ne s}(s-t)}.
   \]
2. Lift to multivariate polynomials by freezing all but one variable and applying the univariate identity iteratively over the finite index set.
3. Deduce nonvanishing: if all evaluations on the grid were zero, the weighted sum would be zero, contradicting the nonzero coefficient.

Why most promising:
- Mathlib already has strong polynomial interpolation tools.
- Iterated univariate reasoning avoids difficult one-shot multivariate basis manipulations.
- This path aligns directly with the induction-on-variables framing in the assignment.

### Strategy B: Remainder/divisibility induction via variable elimination
Classical and robust.

1. Fix a variable `i₀`. Divide `f` by `∏_{s∈S i₀}(X i₀ - s)` as a polynomial in `X i₀`.
2. Show the remainder has degree `< |S i₀|` in `X i₀` and agrees with `f` on all substitutions `X i₀ = s`.
3. Use induction on the number of variables and coefficient tracking to show the top coefficient survives into the remainder unless some evaluation is nonzero.

Why it is useful:
- Produces Theorem C naturally.
- Gives a structural theorem about vanishing ideals of finite grids.
- More algebraic, less dependent on interpolation APIs.

Potential difficulty:
- Representing `MvPolynomial` as a univariate polynomial in one variable with coefficients in another polynomial ring may require more setup.

### Strategy C: Basis expansion in the Lagrange tensor-product basis
Conceptually strongest, perhaps hardest formally.

1. Define basis polynomials
   \[
   \ell_{i,s}(T)=\prod_{t\in S_i,\,t\ne s}\frac{T-t}{s-t}.
   \]
2. Show the tensor products
   \[
   L_x := \prod_i \ell_{i,x_i}(X_i)
   \]
   form an interpolation basis for polynomials with coordinatewise degree bounds.
3. Compute the coefficient of the top monomial in each `L_x`, obtaining the extraction formula.

Why it matters:
- Gives the cleanest conceptual theorem.
- Sets up future linear-algebraic generalizations over finite-dimensional evaluation spaces.

Potential difficulty:
- Requires more finite-dimensional basis infrastructure and bookkeeping.

---

## Build explicitly on catalog theorems

The listed catalog theorems are not direct Nullstellensatz lemmas, so use them as bridge motifs rather than superficial citations.

1. **`key_extraction_bound`** from `Bridges/CupProductCryptography.lean`  
   Treat coefficient extraction as an algebraic analogue of key extraction: a global invariant recovered from local observations. If the theorem gives a bound comparing two extraction parameters, mirror its proof architecture when bounding support sizes or controlling which coefficients can contribute.

2. **`prime_forces_product_visibility`** from `Bridges/ProofSpectrumDuality.lean`  
   Use this as a conceptual bridge: prime/product visibility is analogous to a nonzero coefficient forcing visibility on a Cartesian product. Consider proving a corollary over `ZMod p` where nonzero coefficient visibility becomes finite-field product visibility.

3. **`lipschitz_product_bound`** from `Bridges/NeuralProofMining.lean`  
   There is a cross-domain analogy: Cartesian grid evaluation propagates through products much like Lipschitz constants do. If there is an existing product-structured induction lemma, repurpose its decomposition style for `Finset.pi` summation and product denominators.

4. **`tropical_and_bound`** from `Bridges/IdempotentInfoTheory/TropicalArithmeticCoding.lean`  
   This is the seed for a future tropical analogue: coefficient extraction in ordinary algebra corresponds to support extraction in idempotent semirings. Mention this in `FUTURE_DIRECTIONS.md` and, if feasible, define the support-level version of the theorem.

5. **`height_product_bound`** from `Bridges/ArithmeticLearningTheory/Core.lean`  
   This suggests an arithmetic-complexity corollary: when coefficients/heights are controlled, nonvanishing on a grid can be certified quantitatively. Even if not proved now, formulate a bounded-height corollary over `ℚ`.

Do not force irrelevant dependencies into proofs. Use them to shape theorems and future bridges.

---

## Lean 4 formalization guidance

You will likely need the following definitions/helpers.

### Helper 1: target exponent vector
Define
```lean
def gridExp {ι : Type*} [DecidableEq ι] (S : ι → Finset α) : ι →₀ ℕ := ...
```
with `gridExp S i = S i.card - 1`.

### Helper 2: grid finset of assignments
Define a finset of functions `ι → K` corresponding to the Cartesian product:
```lean
def grid (S : ι → Finset K) : Finset (ι → K) := ...
```
Most likely via `Finset.pi`.

### Helper 3: Lagrange denominator
```lean
def lagrangeDen (S : Finset K) (x : K) : K :=
  ∏ y in S.erase x, (x - y)
```
Then prove:
```lean
lemma lagrangeDen_ne_zero
    {K : Type*} [Field K] {S : Finset K} {x : K}
    (hx : x ∈ S) : lagrangeDen S x ≠ 0 := ...
```

### Helper 4: univariate extraction lemma
Prove first in `Polynomial K`:
```lean
theorem coeff_card_sub_one_eq_sum_eval_div_lagrangeDen
    {K : Type*} [Field K]
    (S : Finset K) (hS : S.Nonempty)
    (p : Polynomial K)
    (hdeg : p.natDegree < S.card) :
    p.coeff (S.card - 1)
      =
    ∑ x in S, p.eval x / lagrangeDen S x
```

This theorem alone would already be a substantial formal contribution.

---

## Cross-domain connections to emphasize

### 1. Additive combinatorics
The polynomial method derives Cauchy–Davenport, restricted sumset bounds, Erdős–Heilbronn-type statements, and incidence theorems. Once coefficient extraction is formalized, these become realistic next targets.

### 2. Cryptography and extraction
A coefficient is hidden global information reconstructed from structured local samples. This is mathematically analogous to extractor design and algebraic secret recovery. The theorem package could support formal proofs about interpolation-based coding/decoding.

### 3. Learning theory and sparse interpolation
Evaluation on grids determines key coefficients under degree constraints. This is exactly the algebraic core of sparse model identification and low-degree learning over finite fields or rationals.

### 4. Tropical/idempotent mathematics
Classical coefficient extraction suggests a tropical support extraction principle: extremal support terms should force extremal evaluations on product sets. Even a conjectural formulation here would be visionary.

### 5. Arithmetic geometry over finite fields
For `K = ZMod p`, nonzero coefficient forcing a nonzero grid point can be used to certify rational points on structured finite schemes. This is a gateway to formal finite-field incidence geometry.

---

## Application keywords

Combinatorial Nullstellensatz; coefficient extraction; Lagrange interpolation; polynomial method; finite-field combinatorics; additive combinatorics; sparse interpolation; algebraic extraction; vanishing ideals; grid evaluation; certified nonvanishing; arithmetic visibility; tropicalization; proof mining; formal algebraic combinatorics.

---

## Concrete deliverables

1. A Lean file proving at least:
   - the univariate extraction theorem, and
   - one multivariate nonvanishing corollary.
2. If possible, also prove the divisibility/vanishing theorem for one variable.
3. Add a short `ARTICLE.md` or `RESEARCH_PAPER.md` explaining the interpolation operator viewpoint.
4. **Required:** produce `FUTURE_DIRECTIONS.md`.

---

## Required FUTURE_DIRECTIONS.md

This is critical. Include 3–5 concrete next steps, each with:
- a precise theorem statement,
- a plausible Lean strategy,
- a cross-domain payoff.

At least include candidates of the following form:

1. **Finite-field sumset theorem via coefficient extraction**  
   Formalize a polynomial-method proof of a Cauchy–Davenport-style bound.

2. **Vanishing ideal of a finite grid**  
   Prove that the ideal of polynomials vanishing on `∏ i S i` is generated by the univariate grid polynomials `∏_{s∈S_i}(X_i-s)`.

3. **Tropical support extraction conjecture**  
   Formulate an idempotent-semiring analogue where extremal monomial support forces extremal evaluation on a product set.

4. **Quantitative rational-height nonvanishing**  
   Over `ℚ`, combine coefficient extraction with `height_product_bound` to derive a bounded-height witness theorem.

5. **Interpolation-as-extraction bridge to cryptography**  
   Connect the coefficient extraction operator to `key_extraction_bound`-style statements for algebraic secret recovery.

---

## Standard of ambition

Do not settle for a restatement of a textbook theorem with missing infrastructure. Build a reusable formal engine. The ideal outcome is a small algebraic-combinatorics library in Lean where “nonzero coefficient implies nonzero grid evaluation” is just the first corollary of a deeper extraction identity. This is the sort of result that changes what can be formalized next.

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
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

**Team Directive**: Create a team to conduct research, brainstorm hypotheses,
run experiments, validate data, update knowledge base and iterate forever.
Each future direction should be specific enough for a team to pick up and
pursue with clear hypotheses, proof strategies, and cross-domain connections.

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
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: prove
