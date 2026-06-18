Soli Deo Gloria

## Assignment: Direction 5: Complexity of Lorentzian Recognition

**Mode:** `prove` with an auxiliary `discover` component

Aristotle, do not treat this as a routine complexity note. The real target is to found a **formal complexity theory of Lorentzianity**: a bridge from Hodge-theoretic positivity to certified algorithms, spectral tests, and complexity barriers. The catalog already contains the quadratic entry point in `Pythagorean/LorentzianMConvex.lean` via `IsLorentzianQuadratic`. Your task is to turn that isolated definition into the first mathematically serious recognition theory.

The breakthrough is not merely “an algorithm exists.” The breakthrough is to prove that **Lorentzian recognition has a recursive spectral core**: for fixed degree, Lorentzianity collapses to a finite tower of Hessian-signature tests whose size grows polynomially in the number of variables, while for unrestricted degree the same recursion strongly suggests intractability. This creates a new formal interface between:

- **algebraic combinatorics** (Lorentzian / strongly log-concave polynomials),
- **spectral linear algebra** (negative eigenspaces of Hessians),
- **optimization** (concavity certificates, barrier-type tests),
- **complexity theory** (fixed-parameter tractability versus hardness),
- **statistical physics / matroid partition functions** (stability, correlation inequalities).

You should aim for a Lean development that proves nontrivial structural theorems and certifies an actual recognition algorithm for low/fixed degree.

---

## Core theorem targets

You must prove at least **3 substantial theorems** with genuinely mathematical proofs, not decidability gimmicks. At least one theorem should connect Lorentzian recognition to another domain.

### New formal objects to define

You should introduce at least one genuinely new definition, for example:

1. `HomogeneousMonomialSupport`
   - a finite support representation of a homogeneous polynomial in `n` variables of total degree `d`;

2. `RecursiveLorentzianCertificate`
   - a finite tree of derivative/Hessian signature certificates witnessing Lorentzianity;

3. `FixedDegreeLorentzianRecognizer`
   - a structure containing:
   - degree bound `d`,
   - recursive derivative-generation procedure,
   - spectral test on quadratic leaves,
   - proof of soundness.

A promising Lean-facing abstraction is:

```lean
structure RecursiveLorentzianCertificate (n d : ℕ) where
  poly : MvPolynomial (Fin n) ℝ
  homogeneous : poly.IsHomogeneousOfDegree d
  nonneg_coeff : ∀ m, 0 ≤ poly.coeff m
  certifies : Prop
```

and a degree-2 spectral predicate extending the catalog quadratic notion:

```lean
def HasAtMostOnePositiveEigenvalue (A : Matrix (Fin n) (Fin n) ℝ) : Prop := ...
```

Then define a recursive predicate:

```lean
def IsRecursivelyLorentzian :
    ∀ {n d : ℕ}, MvPolynomial (Fin n) ℝ → Prop
| n, 0, f => ...
| n, 1, f => ...
| n, d+2, f =>
    f.IsHomogeneousOfDegree (d+2) ∧
    (∀ i, IsRecursivelyLorentzian (pderiv (fun j => if j = i then 1 else 0) f)) ∧
    QuadraticLeafCondition ...
```

You may need to adapt to available Mathlib APIs for `MvPolynomial`, partial derivatives, and matrices.

---

## Precise theorem statements to target

The exact final formulations may need slight adaptation to existing APIs, but aim to stay mathematically equivalent.

### Theorem 1: Degree-2 equivalence between Lorentzianity and spectral signature
This should extend/build directly on `Pythagorean/LorentzianMConvex.lean`.

**Mathematical statement.**  
Let `f` be a homogeneous quadratic polynomial in `n` variables with nonnegative coefficients. Then `f` is Lorentzian if and only if the symmetric Hessian matrix of `f` has at most one positive eigenvalue.

This is the gateway theorem that turns the abstract notion into a concrete recognition criterion.

**Lean target sketch**
```lean
theorem isLorentzianQuadratic_iff_hessian_signature
    {n : ℕ} (f : MvPolynomial (Fin n) ℝ)
    (hhom : f.IsHomogeneousOfDegree 2)
    (hcoeff : ∀ m, 0 ≤ f.coeff m) :
    IsLorentzianQuadratic f ↔
      HasAtMostOnePositiveEigenvalue (quadraticHessian f) := ...
```

If the catalog already encodes one direction, prove the converse and package the equivalence.

**Why this matters.**  
This is the formal spectralization of Lorentzianity. It says Lorentzian recognition at degree 2 is not mysterious—it is a matrix inertia problem.

---

### Theorem 2: Fixed-degree recursive recognition has polynomial-size certificate
**Mathematical statement.**  
Fix `d : ℕ`. For homogeneous degree-`d` polynomials in `n` variables with nonnegative coefficients, the recursive derivative characterization of Lorentzianity requires checking only polynomially many quadratic leaves; specifically, the number of derivative branches is `O(n^(d-2))`. Consequently, assuming exact spectral testing for quadratic leaves, recognition is polynomial-time in the input size for fixed `d`.

This theorem should be formalized as a rigorous counting/result-size theorem, not necessarily a bit-complexity theorem in the Turing model. A clean formal result is to count the number of derivative multi-indices.

**Lean target sketch**
```lean
theorem card_multiindices_degree_fixed
    {n d : ℕ} :
    Fintype.card {α : Fin n → ℕ // ∑ i, α i = d} ≤ n^d := ...
```

and then the recognition bound:

```lean
theorem fixed_degree_recognition_bound
    {n d : ℕ} (hd : 2 ≤ d) :
    ∃ C : ℕ,
      numberOfQuadraticLeaves n d ≤ C * n^(d-2) := ...
```

followed by a soundness theorem:

```lean
theorem recursive_certificate_sound
    {n d : ℕ} {f : MvPolynomial (Fin n) ℝ}
    (hcert : HasRecursiveLorentzianCertificate d f) :
    IsLorentzian f := ...
```

and, if feasible, a completeness theorem for the chosen recursive notion:

```lean
theorem recursive_certificate_complete
    {n d : ℕ} {f : MvPolynomial (Fin n) ℝ}
    (hhom : f.IsHomogeneousOfDegree d)
    (hcoeff : ∀ m, 0 ≤ f.coeff m) :
    IsLorentzian f → HasRecursiveLorentzianCertificate d f := ...
```

**Why this matters.**  
This is the first formal statement that Lorentzianity is **fixed-parameter tractable in degree**. That is a real complexity-theoretic insight, not a coding convenience.

---

### Theorem 3: Derivative closure gives a monotone recognition hierarchy
**Mathematical statement.**  
If `f` is Lorentzian of degree `d ≥ 2`, then every nonzero partial derivative `∂^α f` of degree at least `2` is Lorentzian, and every quadratic derivative leaf satisfies the spectral signature condition. Conversely, if all degree-`2` derivative leaves satisfy the signature condition in a recursive certificate system, then `f` is Lorentzian.

This theorem turns the recursive test from a heuristic into a theorem.

**Lean target sketch**
```lean
theorem lorentzian_under_iterated_pderiv
    {n d : ℕ} {f : MvPolynomial (Fin n) ℝ} {α : Fin n → ℕ}
    (hL : IsLorentzian f)
    (hdeg : f.IsHomogeneousOfDegree d)
    (hα : ∑ i, α i ≤ d - 2) :
    IsLorentzian (iteratedPDeriv α f) := ...
```

and the quadratic leaf extraction:

```lean
theorem quadratic_leaf_signature_of_lorentzian
    {n d : ℕ} {f : MvPolynomial (Fin n) ℝ} {α : Fin n → ℕ}
    (hL : IsLorentzian f)
    (hdeg : f.IsHomogeneousOfDegree d)
    (hα : ∑ i, α i = d - 2) :
    HasAtMostOnePositiveEigenvalue (quadraticHessian (iteratedPDeriv α f)) := ...
```

**Why this matters.**  
This reveals Lorentzianity as a **hierarchical spectral phenomenon**. It is exactly the kind of theorem that lets complexity theory interact with deep positivity.

---

### Theorem 4: Cross-domain theorem — Lorentzian quadratics imply a concavity/optimization principle
You are required to include a domain bridge. Here is the most promising one.

**Mathematical statement.**  
Let `f` be a homogeneous quadratic polynomial with nonnegative coefficients. If `f` is Lorentzian, then `log (f x)` is concave on the positive orthant restricted to any affine slice where `f > 0` (or, more formally in a manageable algebraic form, the Hessian of `f` has Lorentzian signature implying the Hessian of `log f` is negative semidefinite on the codimension-1 tangent space orthogonal to `∇f(x)` for `x > 0`).

If full analytic formalization is too heavy, prove an algebraic surrogate:

> For a positive vector `x`, the quadratic form induced by `∇²f` is nonpositive on the subspace orthogonal to `∇f(x)`.

**Lean target sketch**
```lean
theorem lorentzian_quadratic_tangent_neg_semidef
    {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ}
    (hA : Symmetric A)
    (hL : HasAtMostOnePositiveEigenvalue A) :
    ∀ x v : (Fin n → ℝ),
      0 < quadraticForm A x →
      inner ((A.mulVec x)) v = 0 →
      quadraticForm A v ≤ 0 := ...
```

Or phrased directly for `f`:

```lean
theorem lorentzian_quadratic_induces_tangent_concavity
    {n : ℕ} (f : MvPolynomial (Fin n) ℝ)
    (hhom : f.IsHomogeneousOfDegree 2)
    (hcoeff : ∀ m, 0 ≤ f.coeff m)
    (hL : IsLorentzianQuadratic f) :
    TangentNegativeSemidefinite f := ...
```

**Why this matters.**  
This is the bridge to **convex optimization, entropy inequalities, and statistical physics**. It says Lorentzianity is not just combinatorial positivity; it is a curvature constraint.

---

## Proof architecture: 3 viable strategies

You must not give Aristotle a single narrow route. Here are three proof pathways.

### Strategy A: Spectral recursion via derivative leaves
**Most promising.**

1. Prove the degree-2 spectral equivalence using the catalog’s `IsLorentzianQuadratic` and a carefully defined Hessian matrix.
2. Define iterated partial derivatives indexed by finite multi-indices `α : Fin n → ℕ`.
3. Count the number of degree-`d-2` derivative leaves by bounding the number of compositions of `d-2` into `n` parts.
4. Package the recursion as a certificate tree and prove soundness/completeness relative to your recursive definition.

**Why it is promising.**  
It aligns tightly with the known mathematical characterization of Lorentzian polynomials and keeps the formal burden finite: finite derivatives, finite trees, finite matrix tests.

---

### Strategy B: Combinatorial support route through M-convexity / jump systems
1. Use the catalog’s Lorentzian–M-convex support philosophy from `Pythagorean/LorentzianMConvex.lean`.
2. Prove that for homogeneous degree-`d` polynomials with nonnegative coefficients, the support structure constrains which derivative leaves can be nonzero.
3. Derive a sharpened complexity bound depending on support size rather than ambient `n^d`.
4. Show sparse support yields sparse recursive certificates.

**Why it matters.**  
This is deeper scientifically: complexity becomes sensitive to **combinatorial geometry of support**, not just degree. That would open the door to practical algorithms for sparse partition functions and matroid-type generating polynomials.

---

### Strategy C: Optimization/physics route through Hessian cone geometry
1. View quadratic Lorentzianity as membership in a cone of symmetric matrices with at most one positive eigenvalue.
2. Prove closure properties of this cone under derivative operations or principal compressions arising from specialization.
3. Transfer these spectral facts to tangent-space concavity or negative dependence inequalities.
4. Use this to derive a recognition surrogate: if every quadratic leaf lies in the cone, then the original polynomial lies in the recursive Lorentzian class.

**Why it is powerful.**  
This route creates the strongest cross-domain impact: Lorentzianity becomes a curvature certificate akin to hyperbolicity cones and barrier functions.

---

## Building blocks from the catalog

You explicitly cited:

- `Pythagorean/LorentzianMConvex.lean`
  - especially `IsLorentzianQuadratic`

Use it as the certified base case. Do not merely import it; explain how it enters the recursion.

Likely formal building blocks from Mathlib that should be exploited:

- `MvPolynomial`
  - coefficients, support, homogeneity, derivatives if available;
- `Matrix`
  - symmetric matrices, quadratic forms, eigenvalue/inertia statements if available;
- `Finset`
  - finite counting over multi-indices;
- multiset/compositions APIs
  - for derivative indexing;
- linear algebra on bilinear forms
  - for tangent-space negativity statements.

If eigenvalue APIs are too analytic/heavy, replace “eigenvalue count” with an algebraically formalizable equivalent such as:
- existence of a codimension-`≤ 1` subspace on which the quadratic form is nonnegative,
- or nonpositivity on every vector orthogonal to one distinguished positive direction.

This replacement is mathematically legitimate and often easier to formalize.

---

## Lean 4 theorem signature suggestions

These are not mandatory exact syntax, but they should guide precision.

```lean
def iteratedPDeriv {n : ℕ} (α : Fin n → ℕ) :
    MvPolynomial (Fin n) ℝ → MvPolynomial (Fin n) ℝ := ...

def numberOfQuadraticLeaves (n d : ℕ) : ℕ := ...

def quadraticHessian {n : ℕ} :
    MvPolynomial (Fin n) ℝ → Matrix (Fin n) (Fin n) ℝ := ...

def HasAtMostOnePositiveEigenvalue {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) : Prop := ...

def HasRecursiveLorentzianCertificate :
    ℕ → MvPolynomial (Fin n) ℝ → Prop := ...

theorem pderiv_homogeneous_degree_drop
    {n d : ℕ} {f : MvPolynomial (Fin n) ℝ} {i : Fin n}
    (h : f.IsHomogeneousOfDegree d) :
    (pderiv i f).IsHomogeneousOfDegree (d - 1) := ...

theorem iteratedPDeriv_homogeneous_degree_drop
    {n d : ℕ} {f : MvPolynomial (Fin n) ℝ} {α : Fin n → ℕ}
    (h : f.IsHomogeneousOfDegree d)
    (hα : ∑ i, α i ≤ d) :
    (iteratedPDeriv α f).IsHomogeneousOfDegree (d - ∑ i, α i) := ...

theorem quadratic_leaf_count_le
    {n d : ℕ} :
    numberOfQuadraticLeaves n d ≤ n^(d-2) := ...

theorem recursive_certificate_sound
    {n d : ℕ} {f : MvPolynomial (Fin n) ℝ} :
    HasRecursiveLorentzianCertificate d f → IsLorentzian f := ...

theorem quadratic_lorentzian_iff_signature
    {n : ℕ} {f : MvPolynomial (Fin n) ℝ}
    (hhom : f.IsHomogeneousOfDegree 2)
    (hcoeff : ∀ m, 0 ≤ f.coeff m) :
    IsLorentzianQuadratic f ↔
      HasAtMostOnePositiveEigenvalue (quadraticHessian f) := ...
```

If full `IsLorentzian` is not yet in the catalog, define a new recursive notion and prove:
- equivalence with existing quadratic notion at degree 2,
- closure under derivatives,
- algorithmic soundness.

---

## What counts as a genuine breakthrough here

A weak result would be: “quadratic recognition is cubic time.” That is standard spectral folklore.

A strong result is:

1. a **formal recursive recognition theorem** for fixed degree;
2. a **certificate complexity theorem** showing polynomial-size witness trees;
3. a **cross-domain curvature theorem** linking Lorentzianity to optimization/physics;
4. a plausible hardness frontier stated precisely enough to drive the next cycle.

That combination would create a new research program: **certified Hodge-theoretic complexity**.

---

## Hardness frontier: formulate carefully, do not overclaim

The coNP-hardness statement is likely too ambitious to fully prove in this cycle unless you can encode a known hard spectral/combinatorial problem into recursive Lorentzian failure. So you should be scientifically bold but mathematically disciplined.

### What you should prove now
Prove the fixed-degree tractability theorem rigorously.

### What you should state as a falsifiable conjecture
A good conjecture is:

> **Conjecture (Uniform-degree hardness).** There is no polynomial-time algorithm, in the standard Turing model, that decides Lorentzianity of a homogeneous polynomial with nonnegative integer coefficients when the degree is part of the input, unless `P = NP` (or stronger: the complement problem is NP-hard).

A sharper, testable structural conjecture:

> **Conjecture (Leaf explosion lower bound).** For every recursive derivative-based recognition algorithm that decides Lorentzianity exactly on homogeneous nonnegative-coefficient polynomials, there exists a family `f_{n,d}` for which any exact certificate requires examining at least `n^{Ω(d)}` quadratic leaves.

This is falsifiable computationally: search for compressed certificates on random/special families.

---

## Testable prediction and computational experiment

You are required to include a falsifiable conjecture with a clear disproof mechanism.

### Conjecture A
For homogeneous cubic polynomials with nonnegative coefficients, the derivative-to-quadratic recognition procedure is asymptotically optimal up to polynomial factors among exact algorithms that only inspect derivative leaves.

**Test:**  
Generate random sparse cubic polynomials in `n` variables, enumerate all first derivatives, reduce to quadratic Hessian tests, and compare runtime and certificate size to any support-pruned algorithm. A disproof would exhibit a family where dramatically fewer than all derivative leaves suffice uniformly.

### Conjecture B
For sparse supports arising from matroid basis generating polynomials, the number of nonzero quadratic leaves is controlled by a low-degree polynomial in support size rather than ambient `n^(d-2)`.

**Test:**  
Benchmark on uniform matroids, graphic matroids, and transversal matroids. A disproof would show support-sparse families with near-worst-case derivative-leaf growth.

### Conjecture C
The tangent-space negativity theorem predicts numerically stronger log-concavity constants for Lorentzian quadratics than for generic strongly log-concave forms.

**Test:**  
Sample positive vectors `x`, compute the restricted Hessian of `log f`, and compare extremal eigenvalues across Lorentzian versus non-Lorentzian quadratics.

---

## Required deliverables

You must produce **all** of the following:

### 1. Lean file with at least 3 deep theorems
Requirements:
- no trivial enumeration proofs unless the statement is intrinsically deep;
- use substantial tactics/arguments such as:
  - induction on degree,
  - `rcases` on support/derivative structure,
  - `by_contra` for spectral impossibility,
  - `field_simp` where rational identities appear,
  - multi-step `calc` chains for degree and counting arguments.

### 2. `FUTURE_DIRECTIONS.md`
Include **3–5 falsifiable scientific hypotheses**, each with:
- precise statement,
- why it might be true,
- exact computational or theoretical test,
- what evidence would refute it.

Not vague “explore X.” Actual hypotheses.

### 3. `RESEARCH_PAPER.md`
A standalone scientific paper containing:
- introduction and motivation,
- formal statements of theorems,
- proof ideas,
- algorithmic implications,
- complexity interpretation,
- limitations,
- next-step conjectures.

A reader with no code access must understand the discovery.

### 4. `ARTICLE.md`
Write this in a **Scientific American** style:
- vivid, broad-audience, concept-driven;
- explain Lorentzian polynomials as hidden curvature/geometry in combinatorial data;
- explain why recognition complexity matters;
- explain the optimization/physics connection;
- **do not** focus on proof assistant mechanics or formal verification.

### 5. Verified algorithm / computational method
Implement a certified method for:
- degree-2 Lorentzian recognition via Hessian/signature criterion;
- degree-3 recursive reduction to quadratics;
- a generic fixed-degree leaf-count estimator.

Even if exact numerical eigenvalue computation is external, the mathematical reduction and certificate logic should be verified.

### 6. `demo.py`
Provide an interactive/demo script that:
- constructs sample homogeneous polynomials,
- computes derivative leaves,
- forms quadratic Hessians,
- runs a numerical signature test,
- displays certificate-tree size and timing,
- compares sparse vs dense families,
- includes examples from matroids or partition-function-inspired polynomials.

---

## Cross-domain connections to emphasize

You must explicitly connect the development to at least one of these:

- **Optimization:** Lorentzian recognition as a concavity certificate for objective/barrier functions.
- **Statistical physics:** partition functions with negative dependence / correlation inequalities.
- **Matroid theory:** basis generating polynomials and combinatorial Hodge theory.
- **Complexity theory:** fixed-parameter tractability in degree versus likely hardness when degree varies.
- **Hyperbolic programming:** comparison between hyperbolicity cones and Lorentzian cones.

A particularly powerful narrative is:

> Hyperbolic polynomials give global convex cones; Lorentzian polynomials give recursive local spectral shadows. Recognition complexity measures how expensive it is to certify that a combinatorial partition function has hidden negative curvature.

That is a field-opening sentence. Build the project around it.

---

## Application keywords

Use these throughout the paper and article:

- Lorentzian polynomials
- fixed-parameter tractability
- recursive spectral certificates
- Hessian signature
- combinatorial Hodge theory
- strong log-concavity
- matroid generating polynomials
- negative dependence
- concavity certificates
- hyperbolicity and optimization
- certificate complexity
- sparse support algorithms
- spectral recognition
- algebraic complexity

---

## Minimum success criterion

At a minimum, this cycle should deliver:

1. a precise recursive certificate definition;
2. a formal degree-2 spectral equivalence theorem;
3. a formal polynomial-size bound for fixed-degree derivative leaves;
4. a soundness theorem for the fixed-degree recognizer;
5. one cross-domain theorem linking Lorentzianity to tangent-space concavity or another optimization/physics statement.

If you achieve that, you will not merely extend the catalog—you will establish the first formal theory of the **algorithmic geometry of Lorentzianity**.

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
