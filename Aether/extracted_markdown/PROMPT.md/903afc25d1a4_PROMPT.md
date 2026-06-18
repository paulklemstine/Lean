Soli Deo Gloria

## Assignment: Direction 3: Completeness of Recursive Spectral Certificates

**Mode:** prove

You are not extending a toy certificate. You are attempting to collapse a conceptual gap in Lorentzian geometry: to show that a *finite recursive spectral predicate* exactly captures the full Brändén–Huh notion of Lorentzianity for homogeneous polynomials with nonnegative coefficients. If successful, this turns a one-sided certification method into a complete recognition principle, and it opens a new interface between algebraic combinatorics, hyperbolic/spectral theory, and verified computation.

Build directly on:

- `Pythagorean/LorentzianRecognition.lean`
  - `IsRecursivelyLorentzian`
  - `RecursiveLorentzianCertificate`
  - `recursive_certificate_sound`

Your goal is to formalize a mathematically serious completeness theorem, not a syntactic closure lemma. Minimize `sorry`. Every nontrivial lemma should advance the main equivalence.

---

## Core Breakthrough Target

### Main theorem vision

Let `p` be a homogeneous polynomial with nonnegative coefficients. The recursive spectral predicate says that every quadratic leaf obtained by iterated partial differentiation has the Lorentzian Hessian signature `(+, -, -, ..., -)` on its support subspace. The Brändén–Huh notion of Lorentzianity additionally packages this with the global approximation/closure condition: `p` is a limit of products of linear forms with nonnegative coefficients, or equivalently satisfies one of the standard structural characterizations available in the degree/support setting.

The breakthrough theorem is:

> **Recursive spectral completeness:** for homogeneous polynomials with nonnegative coefficients, recursive spectral certification is not merely sound but complete; it is equivalent to Lorentzianity.

This would make the recursive certificate the first exact finite recognition mechanism for Lorentzianity formalized in Lean.

---

## Precise theorem statements to target

You should introduce a precise formal bridge between the existing recursive predicate and a new formalization of Brändén–Huh Lorentzianity.

### New definition required

Define a new concept not already in the catalog, for example:

- `IsBrandenHuhLorentzian`
- or `IsLorentzianViaQuadraticLeaves`
- or a structure bundling homogeneity, nonnegativity, M-convex/exchange support, and spectral quadratic-leaf conditions.

A strong option is:

```lean
structure LorentzianData (σ : Type*) [Fintype σ] [DecidableEq σ] where
  p : MvPolynomial σ ℝ
  degree : ℕ
  homogeneous : p.IsHomogeneousOfDegree degree
  coeff_nonneg : ∀ d, 0 ≤ MvPolynomial.coeff d p
```

and then define:

```lean
def IsBrandenHuhLorentzian
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℝ) : Prop := ...
```

where the definition should be mathematically faithful but chosen to be formalizable. If the limit-of-products formulation is too analytically heavy, formalize an equivalent theorem-ready characterization via closure under derivatives + quadratic Hessian signature + support exchange property, and clearly mark the equivalence layer as a separate theorem target.

### Main equivalence theorem

A canonical target statement is:

```lean
theorem recursivelyLorentzian_iff_brandenHuh
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    {p : MvPolynomial σ ℝ} {d : ℕ}
    (hhom : p.IsHomogeneousOfDegree d)
    (hcoeff : ∀ m, 0 ≤ MvPolynomial.coeff m p) :
    IsRecursivelyLorentzian p ↔ IsBrandenHuhLorentzian p := ...
```

If the existing recursive predicate is degree-sensitive, adapt the signature accordingly.

### Structural theorem: closure under partial differentiation

This theorem is likely the hinge for the reverse implication:

```lean
theorem IsBrandenHuhLorentzian.pderiv
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    {p : MvPolynomial σ ℝ} {i : σ} :
    IsBrandenHuhLorentzian p →
    IsBrandenHuhLorentzian (MvPolynomial.pderiv i p) := ...
```

or for iterated derivatives:

```lean
theorem IsBrandenHuhLorentzian.iteratedPDeriv
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    {p : MvPolynomial σ ℝ} :
    IsBrandenHuhLorentzian p →
    ∀ D, IsBrandenHuhLorentzian (iteratedPDeriv D p) := ...
```

You may need to define `iteratedPDeriv` if not already present in the catalog.

### Quadratic-leaf extraction theorem

Formalize the idea that recursive leaves are exactly the degree-2 iterated partial derivatives:

```lean
def IsQuadraticLeaf
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (p q : MvPolynomial σ ℝ) : Prop := ∃ D, q = iteratedPDeriv D p ∧ q.totalDegree = 2
```

Then prove a theorem of the shape:

```lean
theorem lorentzian_quadratic_leaves_have_signature
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    {p q : MvPolynomial σ ℝ} :
    IsBrandenHuhLorentzian p →
    IsQuadraticLeaf p q →
    QuadraticHasLorentzianSignature q := ...
```

where `QuadraticHasLorentzianSignature` is another new formal definition, likely expressed in terms of the Hessian matrix or associated symmetric bilinear form.

### Completeness via quadratic leaves

A second-stage theorem, if the full Brändén–Huh equivalence is too ambitious in one shot:

```lean
theorem recursive_complete_of_exchange
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    {p : MvPolynomial σ ℝ} {d : ℕ}
    (hhom : p.IsHomogeneousOfDegree d)
    (hcoeff : ∀ m, 0 ≤ MvPolynomial.coeff m p)
    (hexch : SupportSatisfiesExchange p) :
    IsRecursivelyLorentzian p ↔ IsBrandenHuhLorentzian p := ...
```

This is still a genuine theorem, and likely the most realistic formal breakthrough because the exchange/M-convex support condition is a standard combinatorial gateway in Brändén–Huh theory.

---

## Minimum theorem package: at least 3 deep theorems

Your file must contain at least 3 substantial theorems, all with real proof structure. Suggested package:

1. **Derivative closure theorem**
   ```lean
   theorem IsBrandenHuhLorentzian.pderiv ...
   ```
   Expected proof ingredients: induction on degree / rcases on the Lorentzian witness / multi-step transport of homogeneity and coefficient nonnegativity.

2. **Quadratic leaf signature theorem**
   ```lean
   theorem lorentzian_quadratic_leaves_have_signature ...
   ```
   Expected proof ingredients: induction on derivative depth, `calc` chains for degree bookkeeping, Hessian compatibility under differentiation.

3. **Main completeness theorem**
   ```lean
   theorem recursivelyLorentzian_iff_brandenHuh ...
   ```
   Expected proof ingredients: one direction from `recursive_certificate_sound` + imported/new characterization theorem; converse by recursive descent using derivative closure and degree-2 leaf extraction.

A fourth, strongly recommended cross-domain theorem:

4. **Spectral linear algebra bridge**
   ```lean
   theorem quadratic_signature_iff_one_pos_eigenvalue
       {σ : Type*} [Fintype σ] [DecidableEq σ]
       {q : MvPolynomial σ ℝ} :
       IsHomogeneousQuadratic q →
       QuadraticHasLorentzianSignature q ↔
       SymmetricMatrixHasInertiaOnePos (hessianMatrix q) := ...
   ```
   This is the algebraic-combinatorial ↔ spectral-linear-algebra bridge. It upgrades the recursive predicate from a combinatorial recursion to a theorem about matrix inertia.

This bridge theorem is important because it turns the certificate into a finite spectral algorithm.

---

## Proof architecture: 3 viable strategies

### Strategy A: Characterization-first approach
**Most promising if you can formalize enough of Brändén–Huh cleanly.**

1. Define `IsBrandenHuhLorentzian` using a theorem-ready characterization:
   - homogeneity,
   - nonnegative coefficients,
   - support exchange/M-convexity,
   - every degree-2 iterated derivative has Lorentzian Hessian signature.

2. Prove:
   - recursive predicate implies the characterization directly, by unpacking the recursive leaves;
   - characterization implies recursive predicate by closure under partial differentiation and degree descent.

3. Then separately prove this characterization is equivalent to the classical Brändén–Huh notion.

**Why promising:** it isolates the analytically delicate “limit of products of linear forms” aspect into an equivalence theorem, so the main recursive completeness statement can proceed in a structurally combinatorial-algebraic setting.

### Strategy B: Derivative-induction approach
**Most canonical if the recursive predicate already mirrors the degree filtration.**

1. Prove Lorentzianity is preserved by partial differentiation.
2. Show every recursive branch lands in a quadratic leaf that is Lorentzian.
3. For the converse, induct on degree:
   - base case `d = 2`: recursive predicate reduces to the quadratic spectral condition;
   - inductive step: if all first partial derivatives are recursively Lorentzian and the support/nonnegativity data descend, rebuild recursive Lorentzianity of `p`.

**Why promising:** this uses the exact recursive shape already present in the catalog. It is likely the best route to leverage `recursive_certificate_sound`.

### Strategy C: Spectral-Hessian approach
**Best for the cross-domain theorem and algorithmic payoff.**

1. Formalize the Hessian matrix of a homogeneous quadratic polynomial.
2. Prove the recursive quadratic condition is equivalent to a matrix inertia condition.
3. Lift this spectral statement through differentiation trees, showing that recursive certification is exactly a finite spectral test for Lorentzianity.

**Why promising:** this is the route to a verified algorithm. Even if the full Brändén–Huh equivalence remains conditional on an exchange-property theorem, the spectral infrastructure itself is a field-opening contribution.

**Recommendation:** Pursue **B + C first**, then layer in **A**. In Lean, derivative closure and quadratic spectral equivalence are more likely to stabilize than a direct formalization of the closure/limit definition.

---

## Required new concepts and formal objects

You must define at least one genuinely new concept not already in the catalog. Strong candidates:

- `IsBrandenHuhLorentzian`
- `SupportSatisfiesExchange`
- `IsQuadraticLeaf`
- `QuadraticHasLorentzianSignature`
- `SymmetricMatrixHasInertiaOnePos`
- `iteratedPDeriv`

A particularly valuable definition package is:

```lean
def SupportSatisfiesExchange
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℝ) : Prop := ...
```

formalizing the exchange/M-convex support axiom on exponent vectors with nonzero coefficients.

This is mathematically deep and creates a bridge to matroid theory, discrete convex analysis, and Hodge-theoretic combinatorics.

---

## Cross-domain connection requirement

You must include at least one theorem explicitly connecting algebraic combinatorics to another domain.

### Preferred bridge: spectral linear algebra
The Hessian signature condition is a statement about the inertia of a symmetric matrix. This lets you connect:

- Lorentzian polynomials
- hyperbolicity-like cones
- matrix eigenvalue interlacing
- optimization and stability theory

A target theorem:

```lean
theorem recursive_certificate_equiv_spectral_check
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    {p : MvPolynomial σ ℝ} :
    IsRecursivelyLorentzian p ↔
    ∀ q, IsQuadraticLeaf p q → SymmetricMatrixHasInertiaOnePos (hessianMatrix q) := ...
```

This theorem is the conceptual hinge between combinatorial recursion and finite-dimensional spectral computation.

### Optional second bridge: matroid/discrete convexity
If feasible, formalize that support exchange is inherited by partial differentiation:

```lean
theorem SupportSatisfiesExchange.pderiv
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    {p : MvPolynomial σ ℝ} {i : σ} :
    SupportSatisfiesExchange p →
    SupportSatisfiesExchange (MvPolynomial.pderiv i p) := ...
```

This connects Lorentzianity to M-convexity and valuated matroids.

---

## Conjecture with testable prediction

State at least one falsifiable conjecture, together with a computational disproof protocol.

### Primary conjecture
```lean
/-- Conjecture: recursive spectral certification is complete for homogeneous
polynomials with nonnegative coefficients. -/
conjecture recursive_spectral_complete
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    {p : MvPolynomial σ ℝ} {d : ℕ}
    (hhom : p.IsHomogeneousOfDegree d)
    (hcoeff : ∀ m, 0 ≤ MvPolynomial.coeff m p) :
    IsRecursivelyLorentzian p ↔ IsBrandenHuhLorentzian p
```

### Testable prediction
For all homogeneous polynomials of degree `≤ 5` in `≤ 4` variables with integer coefficients in a bounded box (e.g. coefficients in `{0,1,2}`), exhaustive search should find no counterexample to equivalence between:
- recursive spectral predicate;
- direct quadratic-leaf Hessian test plus exchange support;
- approximation-based numerical Lorentzian witness test.

A counterexample must be reported as:
1. polynomial data,
2. recursive certificate trace,
3. failed Brändén–Huh witness or failed exchange property,
4. Hessian spectra of all quadratic leaves.

This is falsifiable and computationally meaningful.

---

## Verified algorithm/computational method

You must produce not only theorems but a verified recognition procedure.

### Algorithm target
Define and verify an algorithm that:
1. enumerates all iterated partial derivatives of `p` down to degree 2;
2. extracts each quadratic leaf;
3. computes its Hessian matrix;
4. checks the “one positive eigenvalue” / Lorentzian signature condition;
5. returns either:
   - a recursive Lorentzian certificate, or
   - a concrete failing leaf.

Suggested theorem:

```lean
theorem spectralRecognizer_correct
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (p : MvPolynomial σ ℝ) :
    spectralRecognizer p = true → IsRecursivelyLorentzian p
```

and ideally a completeness theorem relative to your formalized characterization:

```lean
theorem spectralRecognizer_complete
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    {p : MvPolynomial σ ℝ} :
    IsBrandenHuhLorentzian p → spectralRecognizer p = true
```

Even if exact real-eigenvalue computation is too hard, you may certify inertia through principal minors, Sylvester-style criteria, or rational exact arithmetic on quadratic forms.

---

## Demo and computational experiment

Produce `demo.py` that:

1. generates homogeneous polynomials in `n ≤ 4`, `d ≤ 5`,
2. computes all quadratic leaves,
3. forms Hessians,
4. checks recursive spectral predicate numerically/symbolically,
5. compares against a direct Brändén–Huh-inspired test where feasible,
6. searches for counterexamples.

The demo should include:
- at least one known Lorentzian example,
- at least one non-Lorentzian example,
- one family where the recursive certificate visibly propagates through derivatives.

Good example families:
- elementary symmetric polynomials,
- basis generating polynomials of small matroids,
- products of positive linear forms,
- perturbations with sparse nonnegative support.

---

## Application keywords

Use and emphasize these throughout the work:

- Lorentzian polynomials
- Brändén–Huh theory
- recursive certification
- Hessian signature
- matrix inertia
- hyperbolicity
- algebraic combinatorics
- spectral linear algebra
- matroid theory
- discrete convex analysis
- Hodge theory
- verified recognition algorithm
- exact certification
- combinatorial optimization

---

## Why this is revolutionary

If you prove completeness, you transform recursive Lorentzian certification from a sufficient test into an exact recognition theorem. That changes the status of the whole framework:

- **In algebraic combinatorics:** it gives a finite spectral recognition principle for Lorentzianity, potentially making the theory computable on concrete families.
- **In spectral linear algebra:** it identifies Lorentzianity with a recursively structured inertia phenomenon.
- **In matroid/Hodge theory:** it offers a route to certified testing of log-concavity and negative dependence phenomena via quadratic leaves.
- **In algorithms:** it enables exact or semi-exact recognizers for classes of generating polynomials arising in optimization, probability, and statistical physics.

This is not an incremental extension of `recursive_certificate_sound`. It is the theorem that decides whether the recursive paradigm is merely a conservative shadow of Lorentzianity, or its exact finite skeleton.

---

## Concrete file-level expectations

Create a new Lean file extending the catalog result, for example near:

- `Pythagorean/LorentzianRecognitionComplete.lean`

and import the existing recognition file.

The file must contain:
- at least one new definition,
- at least 3 deep theorems,
- at least one cross-domain theorem,
- at least one explicit conjecture,
- a verified algorithmic component.

Use induction, `rcases`, `by_contra`, `field_simp`, and nontrivial `calc` blocks where naturally required. Do not pad with trivial decidable lemmas.

---

## Mandatory deliverables

You must produce **all** of the following:

1. **`FUTURE_DIRECTIONS.md`**
   - 3–5 original research directions.
   - Each direction must include the exact sentences:
     - **“The key insight is...”**
     - **“Why now?”**
   - At least one direction must bridge to a different domain, such as optimization, probability, or physics.

2. **`RESEARCH_PAPER.md`**
   - A standalone scientific paper.
   - It must explain the main theorem, the new definitions, proof architecture, computational experiments, and significance.
   - A reader with no access to the code must still understand the discovery and its mathematical meaning.

3. **`ARTICLE.md`**
   - Scientific American style.
   - Explain the ideas and significance for a broad audience.
   - Do **not** focus on formal verification machinery; focus on Lorentzian geometry, recursive structure, and why finite spectral tests matter.

4. **A verified algorithm or computational method**
   - Not just theorem statements.
   - It must actually recognize or test the recursive spectral condition and be proved correct at least in one direction.

5. **`demo.py`**
   - Interactive or script-based demonstration of the recognition method.
   - Include exhaustive search for low-degree counterexamples to the conjecture.

The system does science by cycling:
**conjecture → certify → compute → search for failure → refine theory**.
Your work here should make that cycle real for Lorentzianity.

---

## Final tactical guidance

Be ambitious but stage the formalization intelligently:

1. First stabilize the derivative-recursion infrastructure.
2. Then formalize quadratic Hessian signature as a spectral statement.
3. Then prove the recursive ↔ spectral quadratic-leaf equivalence.
4. Then attack the Brändén–Huh bridge, possibly first under an exchange-property hypothesis.
5. Run exhaustive computations in parallel to guide the formal conjecture boundary.

If full equivalence to the closure/limit definition proves too heavy in one pass, prove the strongest exact characterization you can under explicit combinatorial hypotheses and make the remaining gap mathematically precise. A sharply formulated conditional completeness theorem is still valuable — but the north star remains unconditional recursive spectral completeness.

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
