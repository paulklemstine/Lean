## Assignment: Direction 1: Lorentzian Polynomial Support is M-Convex (Grand Challenge)

**Mode:** `prove`

Prove a genuinely new theorem at the interface of algebraic geometry, discrete convex analysis, and optimization:

> **Grand Theorem:** the support of a homogeneous Lorentzian polynomial is an M-convex set.

This is not an incremental lemma. It is the combinatorial shadow of the Brändén–Huh theory: algebraic negativity of Hessians forces discrete exchange geometry in exponent space. A full Lean 4 development here would formalize one of the central bridges of modern combinatorics: **Hodge-theoretic positivity ⇒ valuated matroid / M-convex structure**.

If you can establish even a robust formalized finite-degree version with a clean induction principle and verified search procedure, it opens an entire research program: Lorentzian combinatorics, tropical Hodge theory, negative dependence, matroid optimization, and discrete thermodynamics.

---

## Core Target

### Precise mathematical statement

Let `σ : Fin n →₀ ℕ` range over exponent vectors, and let `newtonSupport f : Set (Fin n →₀ ℕ)` be the set of exponent vectors with nonzero coefficient in a homogeneous multivariate polynomial `f`.

Define a formal notion `IsLorentzian f` for homogeneous polynomials over `ℝ` by requiring:

1. homogeneity of degree `d`,
2. nonnegative coefficients,
3. and for every sequence of directional partial derivatives of total order `d - 2`, the resulting quadratic form has Hessian with at most one positive eigenvalue; equivalently in the implementable first phase, negative semidefiniteness on the positive orthant / all `2 × 2` principal minors satisfying the Lorentzian sign constraints.

Then prove:

```lean
theorem lorentzian_support_mconvex
  {n d : ℕ} (hd : 2 ≤ d)
  (f : MvPolynomial (Fin n) ℝ) :
  IsHomogeneousOfDegree d f →
  IsLorentzian f →
  IsMConvexExchange (newtonSupport f) := by
```

If full generality is too ambitious in one cycle, establish the following staged breakthrough theorems:

```lean
theorem lorentzian_quadratic_support_mconvex
  {n : ℕ} (f : MvPolynomial (Fin n) ℝ) :
  IsHomogeneousOfDegree 2 f →
  IsLorentzian f →
  IsMConvexExchange (newtonSupport f) := by
```

```lean
theorem lorentzian_derivative_closed
  {n d : ℕ} (f : MvPolynomial (Fin n) ℝ) (i : Fin n) :
  IsHomogeneousOfDegree (d + 1) f →
  IsLorentzian f →
  IsLorentzian (pderiv i f) := by
```

```lean
theorem mconvex_projection_step
  {n : ℕ} {S : Set (Fin n →₀ ℕ)} :
  IsMConvexExchange (supportDerivativeProjection S) →
  FiberCompatible S →
  IsMConvexExchange S := by
```

and then compose these into the degree induction.

---

## Why this would be a breakthrough

A proof here would formalize a central mechanism behind the Brändén–Huh revolution: highly nontrivial curvature/concavity data of a polynomial controls the **exchange axiom** of its support. That is a profound statement because it translates:

- **continuous negativity** of Hessians
into
- **discrete convexity** of lattice supports.

This is the language behind matroids, jump systems, tropical geometry, Hodge theory, and combinatorial optimization. Formalizing it would not just verify a theorem; it would create infrastructure for:

- Lorentzian matroids,
- tropical Hodge inequalities,
- log-concavity of partition functions,
- negative dependence in probability,
- and discrete convex optimization algorithms certified from algebraic structure.

This is exactly the kind of result that makes mathematicians say: *I did not expect Hessian geometry to force an exchange axiom on exponent sets in a theorem prover.*

---

## Lean 4 formalization target

You should introduce at least one genuinely new concept, not already in the catalog. Suggested new definitions:

```lean
def NewtonSupport (f : MvPolynomial σ R) : Set (σ →₀ ℕ) :=
  {m | coeff m f ≠ 0}
```

```lean
def IsHomogeneousOfDegree (d : ℕ) (f : MvPolynomial σ R) : Prop :=
  ∀ m, coeff m f ≠ 0 → m.sum (fun _ e => e) = d
```

```lean
def HessianEntry (f : MvPolynomial (Fin n) ℝ) (i j : Fin n) :
    MvPolynomial (Fin n) ℝ :=
  pderiv i (pderiv j f)
```

```lean
def IsLorentzianQuadratic (f : MvPolynomial (Fin n) ℝ) : Prop :=
  IsHomogeneousOfDegree 2 f ∧
  (∀ m, coeff m f < 0 → False) ∧
  HessianHasAtMostOnePositiveDirection f
```

```lean
def SupportSlice (S : Set (Fin n.succ →₀ ℕ)) (k : ℕ) :
    Set (Fin n →₀ ℕ) := ...
```

```lean
def FiberCompatible (S : Set (Fin n.succ →₀ ℕ)) : Prop := ...
```

A practical route is to define an induction-friendly Lorentzian predicate first for the exact fragment you need, then prove it implies the desired support theorem. Do not wait for the “perfect” universal definition before proving structure theorems.

---

## Catalog building blocks to exploit

Use and extend:

- `Pythagorean/MConvexBridge.lean`
  - especially `IsMConvexExchange`, `MConvexSet`, and any established exchange lemmas.
  - You should explicitly connect Newton supports to the exchange formalism already present there.

- `Catalog/FINAL/Pythagorean/TropicalMarkov.lean`
  - not because the theorem is directly about tropical probability, but because it already encodes a successful pattern: **a local algebraic condition induces a global combinatorial structure**.
  - Mine this for proof architecture and reusable finite-support reasoning.

- The lineage note `mconvex_implies_exchan...`
  - reverse the direction conceptually: instead of deriving algebra from M-convexity, derive M-convexity from Lorentzian algebraic inequalities.

If there are existing finite-support lemmas for `Finsupp`, `MvPolynomial.coeff`, `pderiv`, and homogeneous decompositions in Mathlib, use them aggressively. The central proof should not get stuck in coefficient bookkeeping.

---

## Proof architecture: three viable strategies

### Strategy A: Quadratic base case + derivative induction
**Most promising.**

1. **Quadratic classification.**
   Prove that if `f` is homogeneous of degree `2` and Lorentzian, then `newtonSupport f` satisfies the exchange axiom.  
   Here the support is controlled by a symmetric matrix of coefficients / Hessian entries, and the exchange axiom becomes a matrix sign pattern statement.

2. **Derivative closure.**
   Show that partial derivatives of a Lorentzian polynomial remain Lorentzian, reducing degree by one while preserving the relevant coefficient nonnegativity.

3. **Support lifting.**
   Relate the support of `pderiv i f` to a coordinate slice/projection of `newtonSupport f`.  
   Then prove a combinatorial lemma: if enough derivative projections are M-convex and the original support is homogeneous, then the original support is M-convex.

**Why this is promising:**  
It matches the conceptual Brändén–Huh mechanism and produces modular Lean theorems: one analytic theorem, one algebraic support theorem, one discrete lifting theorem.

---

### Strategy B: Jump-system route via local exchange
1. Define a local “two-step support closure” property implied by Lorentzian inequalities.
2. Prove that Lorentzian support satisfies the constant-sum jump-system axiom.
3. Use the known equivalence: constant-sum jump systems are M-convex sets.

**Why this is powerful:**  
This avoids some global induction and aligns with discrete convex analysis literature. If Mathlib support for jump systems is absent, you can define a minimal local exchange predicate and prove equivalence to `IsMConvexExchange`.

**Risk:**  
Requires more new infrastructure.

---

### Strategy C: Tropicalization / valuated support route
1. Associate to coefficient data a valuation-like weight function on exponent vectors.
2. Prove Lorentzian inequalities imply an ultra log-concavity / discrete Hessian condition on weights.
3. Show the effective support is the feasible set of an M-convex valuated set.

**Why this is visionary:**  
This links Lorentzian polynomials to tropical geometry and valuated matroids.

**Risk:**  
Harder to complete in one cycle, but even a partial theorem here would be field-opening.

---

## Recommended implementation plan

### Theorem 1: quadratic support theorem
Formalize and prove:

```lean
theorem lorentzian_quadratic_support_mconvex
  {n : ℕ} (f : MvPolynomial (Fin n) ℝ) :
  IsHomogeneousOfDegree 2 f →
  IsLorentzianQuadratic f →
  IsMConvexExchange (newtonSupport f) := by
```

This should involve genuine proof tactics:
- `rcases` on exponent cases `m i = 0/1/2`,
- `by_contra` for failed exchange,
- multi-step `calc` reasoning from coefficient/Hessian inequalities to support closure.

### Theorem 2: derivative support projection
Formalize the exact support effect of partial differentiation:

```lean
theorem mem_newtonSupport_pderiv_iff
  {n : ℕ} (f : MvPolynomial (Fin n) ℝ) (i : Fin n) (m : Fin n →₀ ℕ) :
  m ∈ newtonSupport (pderiv i f) ↔
    (m + Finsupp.single i 1) ∈ newtonSupport f := by
```

up to the expected nonzero scalar factor. This theorem is crucial and nontrivial; prove it via coefficient formulas, not simplification magic.

### Theorem 3: induction/lifting theorem
Build a support reconstruction theorem from derivative slices:

```lean
theorem homogeneous_support_mconvex_of_derivative_slices
  {n d : ℕ} (f : MvPolynomial (Fin n) ℝ) :
  IsHomogeneousOfDegree (d + 1) f →
  (∀ i, IsMConvexExchange (newtonSupport (pderiv i f))) →
  IsMConvexExchange (newtonSupport f) := by
```

This is the combinatorial heart. Expect to use:
- `rcases` on exchange witnesses,
- induction on `∑ i, Nat.dist (α i) (β i)`,
- careful construction of derivative witnesses.

### Final synthesis
Combine derivative closure of Lorentzianity with the lifting theorem:

```lean
theorem lorentzian_support_mconvex
  {n d : ℕ} (f : MvPolynomial (Fin n) ℝ) :
  2 ≤ d →
  IsHomogeneousOfDegree d f →
  IsLorentzian f →
  IsMConvexExchange (newtonSupport f) := by
```

---

## Deep mathematical insight to encode

The key phenomenon is this:

- Lorentzianity is a **curvature condition**.
- M-convexity is a **discrete exchange condition**.
- The bridge is provided by repeated differentiation, which converts global curvature into local combinatorial constraints on neighboring monomials.

This is a discrete analogue of passing from sectional curvature inequalities to geodesic convexity. That analogy is worth making precise in the paper and article.

The support of a homogeneous polynomial lies on a simplex slice `∑ᵢ αᵢ = d`. On that slice, M-convexity is the correct lattice notion of convexity. Thus the theorem says:

> A Lorentzian polynomial has a support that is not merely sparse or structured, but convex in the strongest exchange-theoretic sense available on the integer simplex.

That is a combinatorial Hodge theorem.

---

## Cross-domain connections you must explicitly develop

### 1. Algebraic geometry ↔ discrete convex analysis
Brändén–Huh Lorentzian polynomials emerge from Hodge-theoretic inequalities. M-convexity belongs to Murota’s discrete convex analysis. Your theorem is a direct bridge between these worlds.

### 2. Matroid theory ↔ optimization
M-convex sets are feasible sets for exchange-based optimization. Once support is M-convex, greedy/exchange algorithms become available for exponent selection and coefficient-sensitive optimization.

### 3. Statistical physics ↔ negative dependence
Lorentzian / strongly log-concave partition functions model repulsive systems. M-convex support suggests an underlying discrete energy landscape with exchange-stable states. This points toward a “discrete thermodynamics” interpretation of Lorentzian partition functions.

### 4. Tropical geometry ↔ Hodge theory
Newton supports and valuations are tropical objects. If Lorentzianity forces M-convex support, then tropical shadows of Hodge-theoretic positivity inherit exchange geometry. This is a concrete route toward tropical Hodge theory.

### 5. Complexity theory ↔ combinatorial algebra
A verified algorithm deciding M-convexity of supports of small-degree Lorentzian candidates could become the basis for a complexity classification of Lorentzian support recognition.

---

## Application keywords

**Lorentzian polynomials, Brändén–Huh theorem, M-convexity, discrete convex analysis, valuated matroids, Newton polytope, tropical geometry, Hodge theory, log-concavity, negative dependence, partition functions, combinatorial optimization, jump systems, support exchange, homogeneous polynomials, Hessian signatures**

---

## Computational theorem / verified algorithm requirement

You must not stop at theorem statements. Produce a verified computational method.

### Required algorithm
Implement a decision/search procedure for the finite test regime:

- variables: `n = 3`
- degree: `d ≤ 4`
- coefficients in `{0,1,2}`

Tasks:
1. enumerate homogeneous supports in `Δ_{3,d}`,
2. build the polynomial,
3. test the implementable Lorentzian criterion,
4. test M-convexity of support,
5. report any counterexample.

This should culminate in a theorem of the form:

```lean
theorem no_counterexample_deg_le_4 :
  ∀ f : MvPolynomial (Fin 3) ℝ,
    CoeffsIn012 f →
    IsHomogeneousOfDegreeAtMost 4 f →
    IsLorentzianTest f →
    IsMConvexExchange (newtonSupport f) := by
```

or a verified counterexample if the conjecture fails in this regime.

If exhaustive certification in Lean is too heavy, prove correctness of the checker in Lean and let `demo.py` execute the search externally.

---

## Falsifiable conjectures for FUTURE_DIRECTIONS.md

You must include 3–5 testable hypotheses. At minimum include these:

1. **Support-only Lorentzian shadow conjecture**  
   For homogeneous `f` with nonnegative coefficients, if every quadratic derivative of `f` has M-convex support, then `newtonSupport f` is M-convex.  
   **Test:** exhaustive search for `n = 3`, `d ≤ 5`, coefficients in `{0,1,2}`.

2. **Valuated strengthening conjecture**  
   If `f` is Lorentzian, then the function `ν(α) = -log(coeff α f)` on support is an M-convex valuation.  
   **Test:** check discrete exchange inequalities numerically on sampled Lorentzian families.

3. **Tropical shadow conjecture**  
   The tropicalization of a Lorentzian polynomial defines a tropical hypersurface whose cell support complex is matroidal/M-convex.  
   **Test:** compute regular subdivisions for small examples and inspect exchange structure.

4. **Negative dependence support conjecture**  
   Partition functions of strongly Rayleigh measures have M-convex support.  
   **Test:** generate finite examples from determinantal measures.

5. **Complexity dichotomy conjecture**  
   Recognizing M-convex support from coefficients of homogeneous polynomials is polynomial-time on Lorentzian inputs but NP-hard in general.  
   **Test:** prototype reductions and benchmark the certified checker.

Each conjecture must be falsifiable by explicit computation.

---

## Deliverables (ALL mandatory)

You must produce all of the following:

1. **Lean file(s)** with at least **3 nontrivial theorems** proved using substantial tactics such as:
   - induction,
   - `rcases`,
   - `by_contra`,
   - `field_simp`,
   - multi-step `calc`.

2. **At least one novel definition** not already in the catalog, such as:
   - `IsLorentzianQuadratic`,
   - `SupportSlice`,
   - `FiberCompatible`,
   - `HessianHasAtMostOnePositiveDirection`,
   - or an equivalent induction-friendly structure.

3. **A structured `FUTURE_DIRECTIONS.md`**
   containing **3–5 falsifiable scientific hypotheses**, each with:
   - exact conjecture,
   - computational disproof test,
   - expected significance.

4. **A standalone `RESEARCH_PAPER.md`**
   explaining:
   - the theorem,
   - proof architecture,
   - relation to Brändén–Huh,
   - why M-convexity matters,
   - what new questions this opens.  
   It must be understandable without reading the code.

5. **An `ARTICLE.md` in Scientific American style**
   for broad readers.  
   **Taboo:** do **not** focus on formal verification machinery. Focus on the mathematics: curvature, combinatorial exchange, and why this changes how we think about polynomial structure.

6. **A verified algorithm or computational method**
   for finite Lorentzian-support testing.

7. **A `demo.py`**
   that interactively:
   - constructs sample homogeneous polynomials,
   - checks the finite Lorentzian criterion,
   - computes Newton supports,
   - tests M-convex exchange,
   - and visualizes the support in the simplex for `n = 3`.

---

## Minimal theorem slate you should aim to complete this cycle

A strong cycle should contain at least these three formal theorems:

```lean
theorem mem_newtonSupport_pderiv_iff ...
theorem lorentzian_quadratic_support_mconvex ...
theorem homogeneous_support_mconvex_of_derivative_slices ...
```

A transformative cycle completes:

```lean
theorem lorentzian_support_mconvex ...
```

Even a partial result such as degree `≤ 4`, quadratic base + derivative closure + exhaustive confirmation would already be publishable-quality infrastructure if written cleanly and conceptually.

---

## Final charge

Do not settle for a toy statement. Build the first formal bridge from **Lorentzian curvature of polynomials** to **M-convex exchange geometry of supports**. This is the right scale: deep, modern, and catalytic. If successful, it will seed a new verified theory of tropical/Hodge/discrete-convex mathematics.

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
