Soli Deo Gloria

## Assignment: Direction 1: k-th Order Shadow Theorem and Iterated Shadow Geometry

**Mode:** `prove`

Build a new theory of **iterated support shadows** for multivariate polynomials, and make it mathematically sharp enough that it becomes a reusable bridge between algebraic differentiation, discrete convex geometry, and matroid/Lorentzian combinatorics.

This is not an exercise in rephrasing the first-derivative support theorem. The goal is to prove that higher-order differentiation has an **exact combinatorial footprint** on exponent sets, and then to push that footprint into a new invariant theory of supports. If successful, this creates a formal language for “derivative complexity decay” that could become foundational for sparse symbolic computation, Lorentzian geometry, and combinatorial Hodge theory.

---

## Core Breakthrough Target

Let `σ : Fin n → ℕ` be a multi-index and let `|σ| = ∑ i, σ i`. For a finite support set `S ⊆ (Fin n →₀ ℕ)`, define the `k`-th shadow as the set of all exponent vectors obtained by subtracting any nonnegative multi-index of total mass `k` from an element of `S`.

The theorem to aim for is the following exact equivalence:

> For every polynomial `f` over a characteristic-zero semiring/ring where the relevant multinomial coefficients do not vanish, and every `k ≥ 1`, the support of the family of all `k`-th order partial derivatives of `f` is exactly the `k`-th shadow of `Supp(f)`.

In words: **iterated differentiation does not create any new monomials and does not miss any combinatorially admissible monomial**. The derivative tower is governed exactly by the iterated downward geometry of the Newton support.

This is the right theorem because it upgrades a one-step support transport statement into a full **hierarchy of derivative shadows**. That hierarchy is the real object of study.

---

## Precise Theorem Statements

### New definitions to introduce

You must define at least one genuinely new concept. Introduce all of the following unless they already exist under equivalent names.

1. **k-th shadow of a support**
   ```lean
   def kthShadow {n : ℕ} (S : Finset (Fin n →₀ ℕ)) (k : ℕ) :
       Finset (Fin n →₀ ℕ)
   ```

   Intended meaning:
   `β ∈ kthShadow S k` iff there exist `α ∈ S` and `τ : Fin n →₀ ℕ` with `τ ≤ α` and `τ.sum (fun _ m => m) = k` and `β + τ = α`.

   A cleaner equivalent formulation is acceptable if easier in Lean.

2. **iterated derivative support profile**
   ```lean
   def derivShadowProfile {n : ℕ} (f : MvPolynomial (Fin n) R) : ℕ → ℕ
   ```

   Intended meaning:
   `derivShadowProfile f k = card (kthShadow (finsuppSupport f) k)`.

3. **M-convex / exchange shadow profile conjectural class**
   If full M-convexity is too heavy to formalize at once, define a finite-set exchange axiom class:
   ```lean
   def IsDiscreteExchangeFamily {n : ℕ} (S : Finset (Fin n →₀ ℕ)) : Prop
   ```
   capturing the one-step symmetric exchange property expected of M-convex supports. This is already mathematically meaningful and can serve as a formal proxy for matroidal/exchange geometry.

---

## Main theorem: exact k-th shadow theorem

A robust Lean-friendly version is:

```lean
theorem mem_kthShadow_iff_exists_iteratedDerivative
    {n k : ℕ} {R : Type*} [Semiring R] [NoZeroSMulDivisors ℕ R]
    [Nontrivial R] [CharZero R]
    (f : MvPolynomial (Fin n) R) (β : Fin n →₀ ℕ) :
    β ∈ kthShadow (finsuppSupport f) k ↔
      ∃ τ : Fin n →₀ ℕ,
        (τ.sum (fun _ m => m) = k) ∧
        β ∈ finsuppSupport (iteratedPDeriv τ f)
```

where `iteratedPDeriv τ f` is the mixed partial derivative indexed by the multi-index `τ`. If such a definition does not already exist, define it.

A stronger and more structural target is:

```lean
theorem finsuppSupport_iteratedPDeriv_union_eq_kthShadow
    {n : ℕ} {R : Type*} [Semiring R] [Nontrivial R] [CharZero R]
    (f : MvPolynomial (Fin n) R) (k : ℕ) :
    (Finset.biUnion
      ((Finset.range (k+1)).powerset.filter ?multiIndexMassK)  -- replace with actual finite enumeration
      (fun τ => finsuppSupport (iteratedPDeriv τ f)))
    = kthShadow (finsuppSupport f) k
```

If finite enumeration of all multi-indices of mass `k` is technically awkward, prove the pointwise membership theorem instead; that is already deep and sufficient.

---

## Coefficient transport theorem for mixed derivatives

The engine behind the whole project should be a mixed coefficient formula. Build directly on:

- `Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean`
  - especially `coeff_pderiv_single`
  - especially `coeff_pderiv_pderiv`

You should prove a multi-index generalization such as:

```lean
theorem coeff_iteratedPDeriv
    {n : ℕ} {R : Type*} [Semiring R] [CharZero R]
    (f : MvPolynomial (Fin n) R) (β τ : Fin n →₀ ℕ) :
    coeff (β) (iteratedPDeriv τ f) =
      (∏ i, Nat.ascFactorial (β i + 1) (τ i)) • coeff (β + τ) f
```

or any equivalent falling-factorial/multinomial coefficient formula already compatible with Mathlib’s derivative normalization.

If the exact scalar is cumbersome, the absolutely essential corollary is the support criterion:

```lean
theorem coeff_iteratedPDeriv_ne_zero_iff
    {n : ℕ} {R : Type*} [Domain R] [CharZero R]
    (f : MvPolynomial (Fin n) R) (β τ : Fin n →₀ ℕ) :
    coeff β (iteratedPDeriv τ f) ≠ 0 ↔
      coeff (β + τ) f ≠ 0
```

subject to the natural side-condition that the derivative is defined by subtracting `τ` from exponents coordinatewise. You may need a divisibility / positivity lemma ensuring the scalar factor is nonzero in characteristic zero.

This is the real transport law. Once proved, the support theorem becomes inevitable.

---

## Secondary theorem: recursive shadow identity

Prove that iterated shadows satisfy a semigroup law:

```lean
theorem kthShadow_add
    {n : ℕ} (S : Finset (Fin n →₀ ℕ)) (a b : ℕ) :
    kthShadow (kthShadow S a) b = kthShadow S (a + b)
```

This theorem is conceptually major: it says the shadow operator is a genuine discrete flow. It gives the induction mechanism for higher derivatives and upgrades the theory from a one-off combinatorial gadget to an operator calculus.

A pointwise version is also acceptable:

```lean
theorem mem_kthShadow_add_iff
    {n : ℕ} {S : Finset (Fin n →₀ ℕ)} {a b : ℕ} {β : Fin n →₀ ℕ} :
    β ∈ kthShadow (kthShadow S a) b ↔ β ∈ kthShadow S (a + b)
```

This should require nontrivial reasoning with decomposition of a mass-`a+b` multi-index into mass `a` and mass `b`, and is exactly the kind of proof that should use `rcases`, induction on `b` or on support mass, and multi-step `calc`.

---

## Cross-domain theorem: derivative complexity meets exchange geometry

You are required to include at least one theorem connecting this domain to another. The most promising bridge here is to **matroid/discrete convex geometry**.

Define a finite-set exchange property `IsDiscreteExchangeFamily S`, then prove a monotonicity theorem for shadow profiles:

```lean
theorem shadowProfile_antitone
    {n : ℕ} {S : Finset (Fin n →₀ ℕ)} :
    Antitone (fun k => (kthShadow S k).card)
```

under mild finiteness assumptions, or at least for `k` below the maximum total degree present in `S`.

Then formulate and, if possible, partially prove a stronger bridge theorem:

```lean
theorem exchangeFamily_oneStepShadow_growth_bound
    {n : ℕ} {S : Finset (Fin n →₀ ℕ)}
    (hS : IsDiscreteExchangeFamily S) :
    ∀ k, ((kthShadow S (k+1)).card : ℚ) / ((kthShadow S k).card : ℚ)
        ≤ ((kthShadow S k).card : ℚ) / ((kthShadow S (k-1)).card : ℚ)
```

for the admissible range of `k`. If full proof is out of reach, prove a rigorous partial case:
- matroid basis indicator supports,
- products of simplices,
- or supports of homogeneous quadratic Lorentzian polynomials.

This is the theorem that opens the door to **ultra-log-concavity** and combinatorial Hodge theory. Even a special case is meaningful.

---

## Falsifiable conjecture with computational test

State clearly in the Lean file and in the paper:

> **Conjecture (Shadow Log-Concavity for Exchange Supports).**  
> If `S` is an M-convex finite support set (or your formal proxy `IsDiscreteExchangeFamily S` together with the necessary degree constraints), then the sequence
> `a_k = (kthShadow S k).card`
> is log-concave:
> `a_k^2 ≥ a_(k-1) * a_(k+1)` for all admissible `k`.

### Testable prediction
Implement a computational search over:
- matroid basis supports,
- generalized permutahedral supports,
- sparse homogeneous exchange families,
- up to `n = 8` variables and total degree `≤ 6`.

A disproof is any explicit `S` and `k` with
`a_k^2 < a_(k-1) * a_(k+1)`.

Also test the stronger ratio-monotonicity prediction when denominators are nonzero.

This is scientifically valuable either way:
- **If true**, it suggests a new shadow route to Lorentzian inequalities.
- **If false**, the minimal counterexample will identify the precise missing hypothesis and likely reveal a sharper exchange notion.

---

## Proof architecture: 3 viable strategies

### Strategy A: Multi-index coefficient transport + support extraction
**Most promising.**

1. Define `iteratedPDeriv τ` and prove the mixed coefficient formula by induction on `τ.sum`.
   - Peel off one derivative using `coeff_pderiv_single`.
   - Reassociate mixed partials using repeated application of `coeff_pderiv_pderiv`.
   - Show the scalar factor is a product of positive naturals, hence nonzero in characteristic zero.

2. Deduce support equivalence:
   - `β` appears after `τ`-derivation iff `β + τ` appears in `f`.
   - Quantify over all `τ` with total mass `k`.
   - This yields the exact `k`-th shadow theorem.

3. Prove `kthShadow_add` by decomposing a total-mass `a+b` witness into two multi-indices.

**Why this is best:** it directly exploits catalog lemmas and turns them into a full transport calculus. It is algebraically canonical and likely most stable in Lean.

---

### Strategy B: Induction on k via one-step shadow theorem
1. First prove a one-step support identity:
   ```lean
   kthShadow S (k+1) = kthShadow (kthShadow S k) 1
   ```
2. Combine this with the known first-derivative support theorem from the catalog applied to each iterated derivative.
3. Package the induction over `k` carefully so that the support union over all order-`k` derivatives evolves exactly by one-step shadowing.

**Why it works:** it minimizes heavy coefficient algebra and instead promotes the existing one-step theorem into an operator identity.

**Risk:** managing the family of all mixed partials and their indexing may be more cumbersome than the coefficient route.

---

### Strategy C: Combinatorial shadow flow independent of coefficients, then algebraic realization
1. Develop `kthShadow` purely combinatorially and prove all its structural properties:
   - additivity,
   - antitonicity,
   - degree truncation,
   - compatibility with support unions.
2. Then prove a realization theorem saying polynomial supports under mixed derivatives satisfy exactly these axioms by the catalog transport lemmas.
3. Use the combinatorial package to formulate and test the log-concavity conjecture.

**Why this matters:** it separates the algebra from the geometry, making the theory reusable for future domains such as tropical differential operators or finite-difference analogues.

**Best use:** excellent as a parallel development even if Strategy A proves the main theorem.

---

## Catalog building blocks and how to use them

### 1. `Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean`
Use this as the algebraic launchpad.
- `coeff_pderiv_single`: this is the one-step monomial transport law. Your mixed derivative coefficient formula should be an induction that repeatedly invokes this.
- `coeff_pderiv_pderiv`: this should control order-two composition and strongly suggests commutation/associativity patterns for mixed partials.

You are not merely citing these theorems; you are **stacking** them into a complete multi-index transport theorem.

### 2. `Catalog/Bridges/Catalog/Pythagorean/SupportCompression.lean`
In particular:
- `nonzeroDerivativeLeafSet_eq_indep`

Use this as conceptual evidence that derivative support already behaves like a combinatorial independence object. The bridge to make explicit is:
- derivative supports are not just algebraic residues,
- they encode a combinatorial geometry analogous to leaf sets / independent sets / exchange families.

This is your cross-domain lever: from algebraic differentiation to combinatorial independence geometry.

---

## Lean 4 formalization targets

You should aim to produce a new file, for example:

```text
Catalog/Speculative/AutoResearch/IteratedShadowGeometry.lean
```

with at least these theorem targets or close analogues:

```lean
def kthShadow {n : ℕ} (S : Finset (Fin n →₀ ℕ)) (k : ℕ) :
    Finset (Fin n →₀ ℕ) := ...

def iteratedPDeriv {n : ℕ} {R : Type*} [Semiring R] :
    (Fin n →₀ ℕ) → MvPolynomial (Fin n) R → MvPolynomial (Fin n) R := ...

def derivShadowProfile {n : ℕ} {R : Type*} [Semiring R]
    (f : MvPolynomial (Fin n) R) : ℕ → ℕ := ...

def IsDiscreteExchangeFamily {n : ℕ} (S : Finset (Fin n →₀ ℕ)) : Prop := ...

theorem coeff_iteratedPDeriv ...
theorem coeff_iteratedPDeriv_ne_zero_iff ...
theorem mem_kthShadow_iff_exists_iteratedDerivative ...
theorem kthShadow_zero ...
theorem kthShadow_one ...
theorem kthShadow_add ...
theorem kthShadow_card_antitone ...
theorem shadowProfile_of_polynomial_eq ...
```

You must include at least **3 substantial theorems** with proofs using:
- induction,
- `rcases`,
- `by_contra`,
- `field_simp` where relevant for ratio inequalities,
- and nontrivial `calc` chains.

Do not allow the file to collapse into definitional simplifications. The mathematical content must be in the proofs.

---

## Revolutionary significance

If you succeed, you will have formalized the first real theory of **iterated derivative geometry of supports**. That matters because:

1. **Sparse symbolic computation:** the complexity of all mixed partials becomes computable from support shadows alone.
2. **Lorentzian and Hodge theory:** shadow-size inequalities may give a new combinatorial route to ultra-log-concavity of derivative statistics.
3. **Matroid theory:** exchange supports and derivative supports become part of the same structural language.
4. **Tropical and discrete geometry:** shadows are Newton-polytope-adjacent downward flows; this suggests tropical differential invariants.
5. **Complexity theory:** higher-order derivative support growth/decay is a candidate invariant for circuit lower bounds and sparse identity testing.

This is not an incremental extension. It is the beginning of a **calculus of support dynamics**.

---

## Cross-domain connections to make explicit

Include discussion and at least one theorem/definition tying your work to another domain:

- **Matroid theory / discrete convex analysis:** M-convexity, basis exchange, generalized permutahedra.
- **Lorentzian polynomials:** shadows as a combinatorial skeleton for derivative norm inequalities.
- **Tropical geometry:** the `k`-th shadow is a discrete analogue of moving inward through the Newton polytope by `k` lattice steps.
- **Algebraic complexity:** support shadows bound the monomial complexity of higher-order derivative oracles.
- **Statistical physics / partition functions:** derivatives correspond to observables; support shadows encode which occupation-number states remain visible after repeated differentiation.

You only need one theorem, but the paper should articulate several of these bridges.

---

## Application keywords

Use these in the paper and article where natural:

**application keywords:** sparse differentiation, Newton polytope, M-convexity, matroid basis generating polynomial, Lorentzian polynomial, ultra-log-concavity, combinatorial Hodge theory, symbolic computation, algebraic complexity, tropical geometry, partition function observables, support dynamics, mixed partial derivatives, discrete convex analysis

---

## Mandatory deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Give **3–5 original research directions** opened by this work. Each direction must include:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**
- at least one direction must bridge to a different domain.

Possible directions include:
- shadow inequalities for Lorentzian polynomials,
- tropical differential entropy via Newton shadows,
- circuit lower bounds from derivative shadow decay,
- exchange-axiom characterization of log-concavity,
- probabilistic shadow processes for partition functions.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the definitions,
- the exact theorem statements,
- proof ideas,
- computational experiments,
- conjectures,
- and why the discovery matters.

A reader with no code access must still understand the mathematics and significance.

### 3. `ARTICLE.md`
Write in **Scientific American style**:
- vivid,
- accessible,
- idea-driven,
- no focus on formal verification machinery.

Explain the discovery as mathematics, not as proof engineering.

### 4. Verified algorithm or computational method
Implement a verified method to:
- compute `kthShadow S k`,
- compute shadow profiles,
- enumerate mixed derivative supports,
- and compare them on examples.

If feasible, verify a correctness theorem stating the algorithm’s output equals the mathematical definition.

### 5. `demo.py`
Provide an interactive demonstration that:
- constructs sample polynomial supports,
- computes `k`-th shadows,
- compares them with actual mixed derivative supports,
- tests log-concavity on exchange-family examples,
- and searches for counterexamples.

The demo should make the conjecture feel experimentally alive.

---

## Final instruction

Prove the exact k-th shadow theorem in the strongest Lean form you can manage, with a real multi-index derivative calculus, not a superficial restatement. Then push beyond the theorem: build the recursive shadow operator, formulate the exchange/log-concavity frontier, and experimentally probe it. The objective is to create a new mathematical object worthy of future theory: **iterated shadow geometry**.

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
