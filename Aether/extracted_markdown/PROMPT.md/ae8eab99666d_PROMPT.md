Soli Deo Gloria

## Assignment: Direction 3: Hessian-Based Lorentzian Gap via `MvPolynomial` Infrastructure

**Mode:** `prove`

Build a genuine new bridge between Lorentzian polynomial theory, multivariate algebra in Lean 4, and spectral/Riemannian geometry. Do not settle for a surrogate certificate if the geometry itself can be formalized. The goal is to replace the existing `minMass / maxMass` proxy by a mathematically canonical Hessian gap extracted from `log P`, and to prove nontrivial comparison and stability theorems that make this quantity usable for mixing-time analysis and future optimization over quantum measurement distributions.

This is not an incremental cleanup. It is the moment to turn a combinatorial certificate into a differential-geometric invariant.

---

## Central Vision

Let `P_μ` be the generating polynomial associated to a finitely supported nonnegative distribution `μ` on `{0,1}^n` (or, more generally, on multidegrees indexed by a finite variable set `σ`). The current project uses a crude gap surrogate based on `minMass` and `maxMass`. The breakthrough target is to define and analyze the **Hessian gap of `log P_μ` at the all-ones point**, restricted to the codimension-one subspace orthogonal to the all-ones direction.

The conceptual claim is:

> For Lorentzian or strongly log-concave generating polynomials, the geometry of `log P_μ` at the positive point `1` encodes a true spectral gap. This gap is more intrinsic than mass-ratio surrogates, more stable under perturbation than raw coefficients, and closer to the actual contraction mechanism behind Glauber-type dynamics.

If formalized correctly, this opens a new research program:

- **Riemannian geometry of Lorentzian distributions**
- **spectral certificates for mixing from polynomial Hessians**
- **gradient-based optimization on spaces of quantum measurement distributions**
- **a unification of multiaffine generating polynomials, negative dependence, and restricted curvature**

---

## Precise Mathematical Target

Work over `ℝ`. Let `σ` be a finite type with decidable equality. Let
`P : MvPolynomial σ ℝ`.

Define the all-ones evaluation point `1_σ : σ → ℝ := fun _ => 1`.

Define the Hessian matrix at `1_σ` by iterated formal partial derivatives:
\[
H_P(i,j) := \left(\partial_i \partial_j P\right)(1).
\]
Define the gradient vector
\[
g_P(i) := \left(\partial_i P\right)(1),
\]
and the value
\[
p_1 := P(1).
\]

Then the Hessian of `log P` at `1` is formally
\[
\operatorname{LogHess}_P(i,j)
= \frac{H_P(i,j)}{p_1} - \frac{g_P(i) g_P(j)}{p_1^2}.
\]

This is the correct object to formalize first, because it avoids analytic transcendental machinery: it is a rational expression in derivatives of `P`.

The restricted gap should then be defined on the orthogonal complement of the all-ones vector. In matrix language, if `J` denotes the all-ones direction, the meaningful quantity is the best constant `κ ≥ 0` such that
\[
\forall x,\ \sum_i x_i = 0 \to x^\top(-\operatorname{LogHess}_P)x \ge κ \, \|x\|^2.
\]
This `κ` is the **Hessian Lorentzian gap**.

---

## New Definitions You Should Introduce

You must define at least one genuinely new concept, and here there are several natural candidates. At minimum, define:

1. **`logHessianAtOne`**: the matrix-valued curvature certificate of a polynomial at the all-ones point.
2. **`OrthogonalToOnes`** or a quadratic-form predicate for vectors summing to zero.
3. **`HasHessianLorentzianGap`**: a property asserting negativity/coercivity of `logHessianAtOne` on the sum-zero subspace.
4. Optionally, a bundled structure:
   - `HessianGapCertificate`
   - or `LorentzianRiemannianMetric`

Suggested Lean-style definitions:
```lean
def onesVec (σ : Type*) [Fintype σ] : σ → ℝ := fun _ => 1

def gradAtOne (P : MvPolynomial σ ℝ) : σ → ℝ := fun i =>
  MvPolynomial.eval (onesVec σ) (MvPolynomial.pderiv i P)

def hessianAtOne (P : MvPolynomial σ ℝ) : Matrix σ σ ℝ := fun i j =>
  MvPolynomial.eval (onesVec σ) (MvPolynomial.pderiv i (MvPolynomial.pderiv j P))

def logHessianAtOne (P : MvPolynomial σ ℝ) : Matrix σ σ ℝ := fun i j =>
  hessianAtOne P i j / MvPolynomial.eval (onesVec σ) P
    - (gradAtOne P i * gradAtOne P j) / (MvPolynomial.eval (onesVec σ) P)^2

def SumZeroVec [Fintype σ] (x : σ → ℝ) : Prop :=
  Finset.univ.sum (fun i => x i) = 0

def HasHessianLorentzianGap [Fintype σ] (P : MvPolynomial σ ℝ) (κ : ℝ) : Prop :=
  0 ≤ κ ∧
  ∀ x : σ → ℝ, SumZeroVec x →
    κ * (Finset.univ.sum (fun i => x i ^ 2))
      ≤ - Finset.univ.sum (fun i =>
          Finset.univ.sum (fun j => x i * logHessianAtOne P i j * x j))
```

If Mathlib’s matrix quadratic form infrastructure is more convenient, package the right-hand side as a `Matrix.dotProduct` or `QuadForm`. Use the catalog’s `QuadForm` and `HasGappedSignature` where possible.

---

## Exact Theorem Statements to Target

You need at least 3 serious theorems. Here is a coherent theorem suite.

### Theorem 1: Algebraic formula for the Hessian of `log P`
This theorem is foundational and should be proved in full generality.

**Mathematical statement**
For any polynomial `P` with `P(1) ≠ 0`,
\[
\operatorname{LogHess}_P(i,j)
= \frac{\partial_i\partial_j P(1)}{P(1)}
 - \frac{\partial_i P(1)\partial_j P(1)}{P(1)^2}.
\]

This may look tautological because we define `logHessianAtOne` by the right-hand side, so the nontrivial version should establish symmetry and the induced quadratic-form identity:
\[
x^\top \operatorname{LogHess}_P x
=
\frac{x^\top H_P x}{P(1)}
-
\frac{\langle g_P,x\rangle^2}{P(1)^2}.
\]

**Lean 4 target signature**
```lean
theorem quad_logHessianAtOne_eq
    [Fintype σ] [DecidableEq σ]
    (P : MvPolynomial σ ℝ)
    (hP : MvPolynomial.eval (onesVec σ) P ≠ 0)
    (x : σ → ℝ) :
    (Finset.univ.sum fun i =>
      Finset.univ.sum fun j =>
        x i * logHessianAtOne P i j * x j)
    =
    (Finset.univ.sum fun i =>
      Finset.univ.sum fun j =>
        x i * hessianAtOne P i j * x j)
      / MvPolynomial.eval (onesVec σ) P
    -
    ((Finset.univ.sum fun i => x i * gradAtOne P i)^2)
      / (MvPolynomial.eval (onesVec σ) P)^2
```

**Why it matters**
This theorem turns the geometric object into a computable algebraic certificate. It is the bridge from `MvPolynomial` differentiation to spectral analysis.

---

### Theorem 2: All-ones direction is the unique nonnegative obstruction; coercivity on sum-zero vectors
This is the first genuinely new spectral theorem. Under Lorentzian/log-concavity hypotheses from the catalog, prove that the negative log-Hessian is nonnegative on the sum-zero subspace.

**Mathematical statement**
Assume `P` satisfies the catalog’s Lorentzian or directional log-concavity hypotheses and has strictly positive value and first derivatives at `1`. Then
\[
\forall x,\ \sum_i x_i = 0 \implies x^\top \operatorname{LogHess}_P x \le 0.
\]
Equivalently,
\[
\forall x,\ \sum_i x_i = 0 \implies x^\top(-\operatorname{LogHess}_P)x \ge 0.
\]

A stronger version, if reachable using `HasGappedSignature`, is:
\[
\exists \kappa \ge 0,\ \forall x,\ \sum_i x_i=0 \to x^\top(-\operatorname{LogHess}_P)x \ge \kappa\|x\|^2.
\]

**Lean 4 target signature**
```lean
theorem logHessianAtOne_nonpos_on_sumZero
    [Fintype σ] [DecidableEq σ]
    (P : MvPolynomial σ ℝ)
    (hLor : DirectionallyLogConcaveAtOnes P) -- adapt to actual catalog notion
    (hpos : 0 < MvPolynomial.eval (onesVec σ) P) :
    ∀ x : σ → ℝ, SumZeroVec x →
      (Finset.univ.sum fun i =>
        Finset.univ.sum fun j =>
          x i * logHessianAtOne P i j * x j) ≤ 0
```

If the catalog hypothesis is named differently, replace it, but keep the theorem this strong.

**Why it matters**
This is the first step from symbolic Hessian computation to a true gap certificate. It says the geometry of `log P` has the correct Lorentzian sign pattern precisely where mixing lives: the orthogonal complement of conserved mass.

---

### Theorem 3: Comparison with the old surrogate certificate
This theorem is the payoff. Show that the Hessian gap dominates, controls, or is controlled by the surrogate from `RobustLorentzianCertificate`.

You likely cannot prove the sharpest possible inequality immediately, so formulate a theorem that is both meaningful and tractable.

**Mathematical statement**
Under the robust Lorentzian hypotheses in the catalog, if the old surrogate gap
\[
\gamma_{\mathrm{mass}} := \frac{\minMass}{\maxMass}
\]
is positive, then there exists an explicit constant `C(P)` (depending on degree/support/cardinality, ideally simple) such that
\[
\gamma_{\mathrm{mass}} \le C(P)\,\kappa_{\mathrm{Hess}},
\]
or conversely
\[
\kappa_{\mathrm{Hess}} \ge c(P)\,\gamma_{\mathrm{mass}}.
\]

A weaker but still important theorem is:
> positivity of the surrogate certificate implies positivity of the Hessian gap.

**Lean 4 target signature**
```lean
theorem exists_hessianGap_of_minMass_maxMass_gap
    [Fintype σ] [DecidableEq σ]
    (P : MvPolynomial σ ℝ)
    (hrob : RobustLorentzianCertificate P) -- adapt to actual catalog API
    (hgap : 0 < minMass P / maxMass P) :
    ∃ κ > 0, HasHessianLorentzianGap P κ
```

A stronger comparison theorem, if supported by the catalog:
```lean
theorem hessianGap_ge_of_robustCertificate
    [Fintype σ] [DecidableEq σ]
    (P : MvPolynomial σ ℝ)
    (hrob : RobustLorentzianCertificate P) :
    ∃ c > 0, c * (minMass P / maxMass P) ≤ hessianGapLowerBound P
```

**Why it matters**
This theorem makes the new invariant scientifically useful immediately: it does not discard prior work, it strictly refines it.

---

### Theorem 4: Perturbative stability of the Hessian gap
Use the catalog’s perturbation machinery. This is where the new geometry becomes robust enough for applications.

**Mathematical statement**
If `P` has Hessian Lorentzian gap `κ` and `Q` is sufficiently close to `P` in a coefficient/derivative sense controlled by the catalog perturbation theorem, then `Q` has Hessian Lorentzian gap at least `κ - ε`.

**Lean 4 target signature**
```lean
theorem hessianGap_stable_under_perturbation
    [Fintype σ] [DecidableEq σ]
    (P Q : MvPolynomial σ ℝ)
    (κ ε : ℝ)
    (hκ : HasHessianLorentzianGap P κ)
    (hpert : ResidualGapControlledPerturbation P Q ε) : -- adapt to actual catalog theorem
    HasHessianLorentzianGap Q (κ - ε)
```

If the exact perturbation API differs, use the strongest theorem available from the catalog and translate it into a Hessian-gap statement.

**Why it matters**
Without stability, the Hessian gap is a curiosity. With stability, it becomes a usable certificate for noisy quantum data and approximate distributions.

---

## Most Promising Proof Strategies

You asked for 2–3 proof strategy steps; here are three coherent routes. Use at least two in the file.

### Strategy A: Direct algebraic `MvPolynomial` differentiation + quadratic-form manipulation
**Best for Theorem 1 and the computable infrastructure.**
1. Define `gradAtOne`, `hessianAtOne`, `logHessianAtOne` entirely via `MvPolynomial.pderiv` and `MvPolynomial.eval`.
2. Prove symmetry of `hessianAtOne` by commuting mixed partials in the polynomial setting.
3. Expand the quadratic form of `logHessianAtOne` and simplify by multi-step `calc`, `ring`, `field_simp`, and finite-sum rearrangements.

**Why promising:** It avoids analysis entirely and turns curvature into exact algebra. This is the right Lean-first architecture.

---

### Strategy B: Transfer catalog Lorentzian signature theorems to the Hessian of `log P`
**Best for Theorems 2 and 3.**
1. Identify in `DirectionalLogConcavity.lean` and `RobustLorentzianSampling.lean` the exact theorem expressing one-positive-eigenvalue / gapped-signature behavior of a Hessian-like quadratic form.
2. Show that `logHessianAtOne` differs from normalized Hessian by a rank-one gradient correction:
   \[
   \operatorname{LogHess} = H/P(1) - (g g^\top)/P(1)^2.
   \]
3. Use the sum-zero condition to show the all-ones or mass direction is precisely the direction where the rank-one obstruction lives; then invoke `HasGappedSignature` or its corollaries on the orthogonal complement.

**Why promising:** This imports the hard geometry from the catalog rather than reproving Lorentzian theory from scratch.

---

### Strategy C: Perturbative comparison via residual gap machinery
**Best for Theorem 4 and for scientific relevance.**
1. Express each entry of `logHessianAtOne` as a rational function of polynomial value, first derivatives, and second derivatives at `1`.
2. Use catalog perturbation estimates to bound changes in these ingredients under coefficient perturbation.
3. Convert entrywise or operator-norm control into a lower bound on the restricted quadratic form, yielding gap degradation by at most `ε`.

**Why promising:** It produces the theorem that experimentalists and algorithm designers actually need: a stable numerical certificate.

---

## Cross-Domain Connections You Must Make Explicit

At least one theorem and one section of the paper must connect this work to another mathematical domain. Do not leave this implicit.

### 1. Riemannian geometry ↔ Lorentzian polynomials
Interpret `-logHessianAtOne P` as a local metric tensor on the positive cone modulo scaling. This is the finite-dimensional shadow of Hessian geometry/information geometry. The sum-zero subspace is the tangent space to the simplex-like normalization constraint.

**Possible theorem angle:** on sum-zero vectors, the quadratic form induced by `-logHessianAtOne` is invariant under scaling of `P` by positive constants.

```lean
theorem logHessianAtOne_scale_invariant
    [Fintype σ] [DecidableEq σ]
    (P : MvPolynomial σ ℝ) {c : ℝ}
    (hc : 0 < c) :
    logHessianAtOne (MvPolynomial.C c * P) = logHessianAtOne P
```

This is a beautiful geometric theorem: curvature of `log P` does not care about multiplicative normalization.

### 2. Spectral theory / Markov chains ↔ polynomial curvature
Use the Hessian gap as a predictor for Glauber mixing. Even if a full formal mixing-time theorem is too far, prove a comparison theorem that makes the spectral interpretation precise.

### 3. Quantum many-body physics ↔ generating polynomials
For TFIM measurement distributions, the generating polynomial packages amplitudes/probabilities into a multiaffine object whose local curvature at `1` encodes collective response. This is a mathematically novel lens on quantum sampling.

### 4. Information geometry ↔ negative dependence
The matrix `-∇² log P` is the analog of a Fisher-information-type object. For strongly Rayleigh / Lorentzian measures, this suggests a new information-geometric formalism for negatively dependent distributions.

---

## Conjecture with Testable Prediction

You must state at least one falsifiable conjecture and make it computationally disprovable.

### Conjecture: Hessian gap predicts mixing more tightly than mass-ratio surrogate
For TFIM ground-state measurement distributions `μ_n` on `n = 4, …, 8`, let
- `γ_H(μ_n)` be the smallest eigenvalue of `-logHessianAtOne(P_μ)` restricted to the sum-zero subspace,
- `γ_M(μ_n) := minMass(μ_n) / maxMass(μ_n)`,
- `τ_mix(μ_n)` the observed Glauber mixing time.

**Conjecture**
There exists a universal monotone comparison function `F` such that, across the tested family,
\[
\big|\log \tau_{\mathrm{mix}}(\mu_n) - F(\gamma_H(\mu_n))\big|
<
\big|\log \tau_{\mathrm{mix}}(\mu_n) - F(\gamma_M(\mu_n))\big|
\]
for a statistically significant majority of instances, and in small-size exact experiments the rank correlation of `γ_H` with `τ_mix^{-1}` exceeds that of `γ_M`.

This is falsifiable: a single family where the Hessian gap systematically underperforms the surrogate would disprove it.

You should also include a stronger mathematical conjecture:

### Conjecture: positive robust Lorentzian certificate implies positive Hessian gap with dimension-free constant
There exists `c > 0` independent of `n` such that for every admissible multiaffine Lorentzian `P`,
\[
\kappa_{\mathrm{Hess}}(P) \ge c \cdot \frac{\minMass(P)}{\maxMass(P)}.
\]

This is bold, clean, and computationally testable.

---

## Catalog Building Blocks to Use

You explicitly must build on these and explain how:

- `Catalog/Pythagorean/QuantumLorentzianBridge.lean`
  - `RobustLorentzianCertificate`
  - `minMass`
  
  Use these as the existing coarse certificate. Your comparison theorem should start from this hypothesis and derive a Hessian-based certificate.

- `Catalog/Bridges/Catalog/Pythagorean/RobustLorentzianSampling.lean`
  - `HasGappedSignature`
  - `QuadForm`
  
  This is the key spectral bridge. Translate `logHessianAtOne` into a `QuadForm` and exploit the one-positive-direction / gapped-signature infrastructure.

- `Catalog/Pythagorean/DirectionalLogConcavity.lean`
  
  Use this to justify the sign pattern of directional second derivatives and to control the Hessian on the sum-zero subspace.

If there is a theorem analogous to `residual_gap_of_perturbation`, use it to derive stability of the new Hessian gap. Be explicit in comments and in the paper about exactly where this theorem enters.

---

## Lean 4 Formalization Targets

Your Lean development should include a file centered on these core declarations:

```lean
def onesVec (σ : Type*) [Fintype σ] : σ → ℝ
def gradAtOne [Fintype σ] [DecidableEq σ] (P : MvPolynomial σ ℝ) : σ → ℝ
def hessianAtOne [Fintype σ] [DecidableEq σ] (P : MvPolynomial σ ℝ) : Matrix σ σ ℝ
def logHessianAtOne [Fintype σ] [DecidableEq σ] (P : MvPolynomial σ ℝ) : Matrix σ σ ℝ
def SumZeroVec [Fintype σ] (x : σ → ℝ) : Prop
def HasHessianLorentzianGap [Fintype σ] [DecidableEq σ]
  (P : MvPolynomial σ ℝ) (κ : ℝ) : Prop
```

And at least 3 deep theorems with proofs using induction, `rcases`, `by_contra`, `field_simp`, or substantial `calc` chains. Do not allow the development to collapse into trivial extensionality lemmas.

---

## Suggested Deep Proof Tactics to Showcase

You are required to have nontrivial proof methods. Here are natural places to use them:

- **`field_simp`**: in the quadratic identity for `logHessianAtOne`.
- **`calc` chains**: rearranging finite sums and converting matrix/quadratic-form expressions.
- **`rcases`**: unpacking `RobustLorentzianCertificate` and `HasGappedSignature`.
- **`by_contra`**: proving positivity of the Hessian gap from a gapped-signature hypothesis.
- **induction on finite support / degree / derivative structure**: if needed for symbolic derivative lemmas on `MvPolynomial`.

---

## Computational / Algorithmic Deliverable

You must provide a **verified algorithm**, not just theorem statements.

### Required algorithm
Implement a procedure that, for a finitely supported multiaffine polynomial `P` over variables `σ` with explicit coefficients:

1. computes `gradAtOne P`,
2. computes `hessianAtOne P`,
3. forms `logHessianAtOne P`,
4. restricts it to the sum-zero subspace,
5. returns a certified lower bound candidate for the smallest restricted eigenvalue.

In Lean, the exact spectral computation may be difficult for arbitrary dimension, so it is acceptable to:
- compute the matrix exactly/rationally,
- export to Python for numerical restricted-spectrum estimation,
- and formally verify the algebraic construction of the matrix and subspace restriction.

This still counts as a verified computational method if the symbolic part is certified and the numerical part is clearly separated.

---

## `demo.py` Requirements

Your `demo.py` must:
1. construct TFIM-inspired small-instance measurement distributions for `n = 4,...,8`,
2. build their generating polynomials,
3. compute:
   - `minMass / maxMass`,
   - full Hessian of `log P` at `1`,
   - restricted eigenvalues,
   - observed Glauber mixing-time proxy or simulation-based estimate,
4. produce a table and plot comparing the predictive quality of:
   - surrogate gap,
   - Hessian gap.

Include at least one interactive feature:
- choose `n`,
- choose field strength/coupling,
- recompute spectra and predictor comparison.

---

## Standalone Writing Deliverables

You must produce **all** of the following.

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, for example:
- information geometry,
- optimization on polynomial cones,
- quantum many-body response theory,
- matroid Hodge theory,
- Markov chain curvature.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper. A reader with no access to the code must understand:
- what the Hessian Lorentzian gap is,
- how it refines the old surrogate,
- what the main theorems are,
- what computations support the conjecture,
- what new field this opens.

The paper should include:
- motivation,
- formal definitions,
- theorem statements,
- proof ideas,
- computational experiment section,
- limitations,
- future work.

### 3. `ARTICLE.md`
Write in Scientific American style. Make it vivid and concept-driven. Explain:
- why a polynomial can carry a hidden geometry,
- why curvature predicts dynamics,
- why this matters for quantum systems and stochastic sampling.

**Taboo:** do **not** focus on formal verification or machine verification. Focus on the mathematics and its significance.

---

## Application Keywords

Include these keywords in the paper and article where appropriate:

**Lorentzian polynomial, Hessian geometry, log-concavity, multiaffine generating polynomial, spectral gap, Glauber dynamics, restricted eigenvalue, information geometry, quantum Ising model, TFIM, negative dependence, Riemannian metric, perturbation stability, `MvPolynomial`, quadratic form, mixing time certificate**

---

## What Would Make This a Breakthrough

A successful result here would mean:

- the project no longer relies on a coefficient-ratio heuristic;
- Lorentzian geometry yields an intrinsic curvature-based mixing certificate;
- `MvPolynomial` becomes a laboratory for Hessian geometry in combinatorics and physics;
- quantum measurement distributions become accessible to differential-geometric optimization;
- the catalog gains a new reusable invariant likely to matter far beyond this one application.

This is the kind of theorem that changes what objects we believe are computable and what invariants we consider natural.

Do not aim for a local patch. Build the curvature theory.

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
