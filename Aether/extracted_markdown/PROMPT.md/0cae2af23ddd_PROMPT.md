# Mode: prove

## Soli Deo Gloria

## Assignment: Direction 5 — Ehrhart Theory of Lorentzian Permutohedra

You are to attack a genuinely field-opening problem at the interface of discrete convex analysis, Ehrhart theory, and Hodge-theoretic combinatorics. The target is not a cosmetic extension of existing catalog results: it is to build the first formal bridge from Lorentzian polynomial geometry to arithmetic positivity phenomena of lattice-point enumeration.

The governing vision is this:

> **Lorentzian structure should force arithmetic positivity on Newton polytopes.**
> If true, this opens a new program: using negative dependence / Hodge-theoretic input from Lorentzian polynomials to derive positivity, real-rootedness, and shape constraints on Ehrhart invariants of generalized permutohedra.

This would connect:
- **combinatorial geometry**: generalized permutohedra, lattice polytopes, IDP,
- **discrete convex analysis**: M-convexity and exchange axioms,
- **algebraic/combinatorial Hodge theory**: Lorentzian and log-concavity phenomena,
- **number theory / enumerative arithmetic**: Ehrhart coefficients and \(h^*\)-vectors,
- **algorithmics**: certified lattice-point counting and hypothesis generation from explicit Newton polytopes.

Catalog anchors you should build on:
- `Pythagorean/MConvexBridge.lean`
  - especially the infrastructure around `MConvexSet`, exchange connectivity, and generalized permutohedron lattice structure
  - especially any theorem in the lineage of `mconvex_implies_exchange_connected`
  - especially `IsGenPermutohedronLattice` if already present or derivable
- `Catalog/FINAL/Pythagorean/EulerFactor.lean`
  - not for direct polytope geometry, but as a model for how arithmetic generating functions should be packaged and manipulated in Lean
  - use its generating-series discipline to architect Ehrhart-series statements

Your job is to prove **new, non-trivial theorems** and define the missing infrastructure needed to make the conjectural program mathematically operational.

---

## Core Breakthrough Target

Formalize and prove the first layer of the following program:

### Breakthrough Thesis
For lattice generalized permutohedra arising from Lorentzian support data, the associated Ehrhart counting function exhibits positivity and shape constraints stronger than those known for arbitrary lattice polytopes.

You likely will not finish the full Hodge–Riemann-level unimodality theorem in one cycle. That is acceptable. But you must prove substantial theorems that make the conjecture mathematically testable and structurally inevitable.

---

## Precise theorem targets

You must prove at least **3 deep theorems**. At least one should be a bridge theorem across domains.

Below are candidate theorem statements. You should aim to prove as many as possible, prioritizing the first three.

### Theorem 1: IDP from M-convex/Lorentzian generalized permutohedral structure
If \(P \subset \mathbb{R}^n\) is a lattice generalized permutohedron whose lattice points form an M-convex set, then \(P\) has the integer decomposition property.

Informal statement:
\[
\forall t \ge 1,\ \forall x \in tP \cap \mathbb{Z}^n,\ \exists x_1,\dots,x_t \in P \cap \mathbb{Z}^n,\ x=x_1+\cdots+x_t.
\]

Suggested Lean target signature, to be adapted to the actual polytope model available in Mathlib/catalog:
```lean
theorem isGenPermutohedron_idp
    {n : ℕ}
    (P : Set (Fin n → ℤ))
    (hP_gen : IsGenPermutohedronLattice P)
    (hP_mconv : MConvexSet P) :
    ∀ t : ℕ, 1 ≤ t →
      ∀ x : Fin n → ℤ,
        x ∈ dilateLatticeSet t P →
        ∃ xs : Fin t → (Fin n → ℤ),
          (∀ i, xs i ∈ P) ∧
          x = ∑ i, xs i
```

If `dilateLatticeSet` does not exist, define it carefully:
```lean
def dilateLatticeSet {n : ℕ} (t : ℕ) (P : Set (Fin n → ℤ)) : Set (Fin n → ℤ) :=
  {x | ∃ y ∈ P, x = fun i => t * y i}
```
But ideally you should define a more mathematically correct notion corresponding to lattice points in \(t \cdot \mathrm{conv}(P)\), not just pointwise scaling of lattice sets. If convex hull infrastructure is too heavy, define a discrete IDP surrogate and prove it first.

### Theorem 2: Ehrhart semiring / generating-function positivity
Define a discrete Ehrhart counting function for a finite lattice set model of a generalized permutohedron and prove nonnegativity of the coefficients of the binomial-basis expansion under IDP.

Mathematical goal:
For an IDP lattice polytope \(P\), its Ehrhart series
\[
\mathrm{Ehr}_P(z)=\sum_{t\ge0} L(P,t)z^t
\]
admits
\[
\mathrm{Ehr}_P(z)=\frac{h^*_0+h^*_1 z+\cdots + h^*_d z^d}{(1-z)^{d+1}}
\]
with \(h^*_i \ge 0\).

Suggested Lean target signature:
```lean
def ehrhartCount {n : ℕ} (P : Set (Fin n → ℤ)) (t : ℕ) : ℕ := ...

def hStarVector {n : ℕ} (P : Set (Fin n → ℤ)) : List ℕ := ...

theorem hStar_nonneg_of_idp
    {n : ℕ}
    (P : Set (Fin n → ℤ))
    (hfin : P.Finite)
    (hidp : IntegerDecompositionProperty P) :
    ∀ k, k < (hStarVector P).length →
      0 ≤ (hStarVector P).get ⟨k, by simpa using ‹_›⟩
```

If full `hStarVector` infrastructure is too ambitious, prove a rigorously useful weaker theorem:
- existence of a nonnegative numerator in a truncated rational generating series,
- or monotonicity / superadditivity statements for `ehrhartCount`,
- or positivity of the first two Ehrhart coefficients.

### Theorem 3: Exchange-connectedness implies decomposability of lattice points
This is the key structural theorem that should power Theorem 1. Use exchange connectivity from the catalog to recursively peel off one lattice point from a lattice point in a dilation.

Informal statement:
If \(x \in tP \cap \mathbb Z^n\) and \(P\cap \mathbb Z^n\) is exchange-connected/M-convex, then there exists \(y \in P\cap\mathbb Z^n\) such that \(x-y \in (t-1)P \cap \mathbb Z^n\).

Suggested Lean target:
```lean
theorem exists_peeloff_of_mconvex
    {n t : ℕ}
    (ht : 1 ≤ t)
    {P : Set (Fin n → ℤ)}
    (hP : MConvexSet P)
    {x : Fin n → ℤ}
    (hx : x ∈ dilateHullLattice t P) :
    ∃ y ∈ P, x - y ∈ dilateHullLattice (t - 1) P
```

This theorem is likely the true engine. It is deep, recursive, and should require induction, `rcases`, and multi-step algebraic reasoning.

### Theorem 4: Cross-domain bridge to arithmetic generating functions
Show that the Ehrhart series of a generalized permutohedron behaves like an Euler-type product or satisfies a coefficientwise domination by a product of geometric series arising from edge directions.

This is a speculative but powerful bridge theorem:
```lean
theorem ehrhartSeries_coeff_le_edgeEulerProduct
    {n : ℕ}
    (P : Set (Fin n → ℤ))
    (hP_gen : IsGenPermutohedronLattice P) :
    coeffwiseLE (ehrhartSeries P) (edgeEulerProductSeries P)
```

This theorem links the polyhedral side to the arithmetic generating-function architecture exemplified in `EulerFactor.lean`. Even a weaker formalized domination theorem would be an important cross-domain result.

### Theorem 5: Verified small-dimensional positivity theorem
Prove a nontrivial certified theorem for dimensions \(3\) or \(4\) in a family where explicit formulas can be derived.

For example:
- hypersimplices,
- permutohedra of small rank,
- Minkowski sums of coordinate simplices,
- Newton polytopes of explicit Lorentzian quadratics/cubics.

Suggested Lean target:
```lean
theorem ehrhartCoeff_nonneg_small_family
    (P : SmallLorentzianPermutohedronFamily)
    :
    ∀ c ∈ ehrhartCoeffs P, 0 ≤ c
```

This gives you a foothold if the full abstract theory is too large.

---

## New definitions you should introduce

You must define at least one genuinely new concept absent from the catalog. Recommended options:

### Option A: `IntegerDecompositionProperty`
```lean
def IntegerDecompositionProperty {n : ℕ} (P : Set (Fin n → ℤ)) : Prop :=
  ∀ t : ℕ, 1 ≤ t →
    ∀ x, x ∈ dilateHullLattice t P →
      ∃ xs : Fin t → (Fin n → ℤ),
        (∀ i, xs i ∈ P) ∧ x = ∑ i, xs i
```

### Option B: `LorentzianSupportSet`
A discrete support-level object capturing the support of a Lorentzian polynomial without formalizing the full analytic theory.
```lean
def LorentzianSupportSet {n : ℕ} (S : Set (Fin n → ℕ)) : Prop := ...
```
This can encode:
- constant total degree,
- M-convex support exchange axioms,
- nonempty finite support.

This is likely the most practical formal proxy for Lorentzian geometry in Lean right now.

### Option C: `DiscreteEhrhartPolynomial`
A structure bundling a counting function with polynomiality data on a certified family.
```lean
structure DiscreteEhrhartPolynomial {n : ℕ} (P : Set (Fin n → ℤ)) where
  coeffs : List ℤ
  eval_eq : ∀ t : ℕ, ehrhartCount P t = ...
```

### Option D: `hStarUnimodal`
```lean
def IsUnimodal (a : List ℕ) : Prop := ...
```
This is useful both for conjectures and verified computational experiments.

---

## Most promising proof architectures

You must not merely state theorems. You must pursue one of the following proof programs in detail.

### Strategy A: Exchange-peeling induction via M-convexity
**Most promising.**

1. **Build a discrete dilation model** for lattice points in \(tP\), ideally via sums of \(t\) points in \(P\), or via a hull-based lattice-point set if available.
2. Use `MConvexSet` and exchange lemmas from `Pythagorean/MConvexBridge.lean` to prove a **peel-off lemma**:
   from a point in the \(t\)-dilation, extract one point of \(P\) while staying in the \((t-1)\)-dilation.
3. Conclude IDP by induction on \(t\).
4. Package the decomposition into a generating-function statement; derive nonnegativity of the \(h^*\)-numerator coefficients or an equivalent semigroup-positivity theorem.

Why this is strongest:
- It uses the catalog’s actual structural assets.
- It avoids needing the full Hodge package immediately.
- It produces an algorithm, not just an existence theorem.

### Strategy B: Semigroup algebra / Hilbert basis route
1. Define the affine semigroup
   \[
   S_P = \{(x,t) : x \in tP \cap \mathbb Z^n\}.
   \]
2. Show that for generalized permutohedra with M-convex lattice points, \(S_P\) is generated in degree \(1\).
3. Deduce IDP and nonnegative \(h^*\)-coefficients from semigroup normality / standard gradedness.
4. Translate the resulting Hilbert-series statement into Ehrhart language.

Why this is elegant:
- It gives the cleanest explanation of \(h^*\)-nonnegativity.
- It aligns naturally with rational generating function methods and the style of `EulerFactor.lean`.

Why it is harder:
- It requires more algebraic infrastructure and careful handling of graded semigroups in Lean.

### Strategy C: Verified low-dimensional Lorentzian family + abstraction extraction
1. Define an explicit family of Lorentzian-support generalized permutohedra in dimensions \(3\)–\(4\).
2. Compute / prove exact Ehrhart formulas for these families.
3. Identify the common combinatorial invariant behind the formulas.
4. Generalize the invariant into an abstract theorem.

Why this matters:
- It gives certified evidence for the grand conjecture.
- It may reveal the correct abstract statement if the original conjecture is too optimistic.

This is an excellent fallback or companion strategy, but by itself it is less revolutionary than Strategy A or B.

---

## Cross-domain bridge theorems you should aim for

At least one theorem must connect this area to a distinct domain.

### Bridge 1: Combinatorial Hodge theory ↔ arithmetic positivity
Show that a Lorentzian-support condition implies log-concavity or ultra log-concavity for a slice of Ehrhart data:
```lean
theorem lorentzian_support_implies_logConcave_slice
    {n : ℕ}
    (S : Set (Fin n → ℕ))
    (hS : LorentzianSupportSet S) :
    LogConcave (sliceCountSequence S)
```
Even if you cannot yet connect directly to full Ehrhart coefficients, proving log-concavity for a related counting sequence would be a major conceptual bridge.

### Bridge 2: Ehrhart theory ↔ number-theoretic generating functions
Construct an Euler-product-style majorant/minorant for the Ehrhart series of a generalized permutohedron, inspired by `EulerFactor.lean`.

### Bridge 3: Discrete convex geometry ↔ statistical physics
Interpret the Ehrhart series as a partition function of an exchange gas on a finite lattice support, and prove monotonicity / convexity of free energy analogues. A formal theorem here could be surprisingly impactful:
```lean
theorem log_ehrhartSeries_convex_in_temperature
    ...
```
If too ambitious analytically, prove a discrete convexity statement for coefficient growth.

---

## Concrete conjecture with computational test

You must state at least one falsifiable conjecture with an explicit computational protocol.

### Main conjecture
For every finite Lorentzian support set \(S \subset \mathbb{N}^n\) of fixed degree, if \(P = \mathrm{NewtonPolytope}(S)\) is a lattice generalized permutohedron, then:
1. all Ehrhart coefficients of \(P\) are nonnegative, and
2. the \(h^*\)-vector of \(P\) is unimodal.

Lean-friendly packaging:
```lean
conjecture lorentzianPermutohedron_ehrhartPositivity
    {n : ℕ}
    (S : Set (Fin n → ℕ))
    (hS : LorentzianSupportSet S)
    (hP : IsGenPermutohedronLattice (newtonLatticePolytope S)) :
    EhrhartCoeffNonnegative (newtonLatticePolytope S) ∧
    IsUnimodal (hStarVector (newtonLatticePolytope S))
```

### Explicit computational falsification test
For all supports \(S\) in:
- \(n = 3,4\),
- degree \(d = 2,3\),
- support size bounded by a practical threshold,

perform:
1. verify `LorentzianSupportSet S` or its discrete proxy,
2. construct the Newton polytope,
3. compute `ehrhartCount P t` for \(t = 0,\dots,10\),
4. interpolate the Ehrhart polynomial,
5. extract candidate \(h^*\)-vector,
6. test coefficientwise nonnegativity and unimodality.

A single counterexample invalidates the conjecture. That makes this scientifically sharp.

---

## Lean 4 formalization targets

You should include precise type signatures in the code for the central objects. Adapt as needed to actual available Mathlib APIs, but preserve the mathematical intent.

Recommended targets:
```lean
def IntegerDecompositionProperty {n : ℕ} (P : Set (Fin n → ℤ)) : Prop := ...

def ehrhartCount {n : ℕ} (P : Set (Fin n → ℤ)) (t : ℕ) : ℕ := ...

def ehrhartSeries {n : ℕ} (P : Set (Fin n → ℤ)) : FormalPowerSeries ℕ := ...

def hStarVector {n : ℕ} (P : Set (Fin n → ℤ)) : List ℕ := ...

def LorentzianSupportSet {n : ℕ} (S : Set (Fin n → ℕ)) : Prop := ...

def IsUnimodal (a : List ℕ) : Prop := ...
```

And theorem targets:
```lean
theorem exists_peeloff_of_mconvex
    {n t : ℕ}
    (ht : 1 ≤ t)
    {P : Set (Fin n → ℤ)}
    (hP : MConvexSet P)
    {x : Fin n → ℤ} :
    x ∈ dilateHullLattice t P →
    ∃ y ∈ P, x - y ∈ dilateHullLattice (t - 1) P := ...

theorem isGenPermutohedron_idp
    {n : ℕ}
    {P : Set (Fin n → ℤ)}
    (hP_gen : IsGenPermutohedronLattice P)
    (hP_mconv : MConvexSet P) :
    IntegerDecompositionProperty P := ...

theorem hStar_nonneg_of_idp
    {n : ℕ}
    {P : Set (Fin n → ℤ)}
    (hfin : P.Finite)
    (hidp : IntegerDecompositionProperty P) :
    HStarNonnegative P := ...
```

If some signatures need to use `Finset` instead of `Set`, do so. In fact, finite support models may be easier to control in Lean:
```lean
def ehrhartCountFinset {n : ℕ} (P : Finset (Fin n → ℤ)) (t : ℕ) : ℕ := ...
```

---

## Required proof-tactic depth

The file must include at least 3 theorems whose proofs genuinely use:
- induction,
- `rcases`,
- `by_contra`,
- `field_simp` where rational generating functions appear,
- multi-step `calc`,
- decomposition of finite sums,
- nontrivial coercion control between `ℕ`, `ℤ`, and possibly `ℚ`.

Do **not** hide triviality behind brute-force decision procedures.

Good candidates for deep proofs:
- induction on dilation parameter \(t\),
- contradiction-based proof of peel-off impossibility,
- generating series algebra with `field_simp`,
- coefficient extraction via `calc`,
- transfer from exchange axioms to decomposition statements.

---

## Suggested file architecture

Create a focused development, for example:

- `LorentzianPermutohedra/EhrhartIDP.lean`
  - new definitions: `IntegerDecompositionProperty`, `LorentzianSupportSet`
  - peel-off lemma
  - IDP theorem
- `LorentzianPermutohedra/EhrhartSeries.lean`
  - `ehrhartCount`, `ehrhartSeries`, numerator / `hStarVector`
  - nonnegativity theorem under IDP or semigroup generation hypotheses
- `LorentzianPermutohedra/Examples.lean`
  - explicit low-dimensional Lorentzian-support families
  - certified examples
- `demo.py`
  - enumerates supports, builds Newton polytopes, counts lattice points, fits polynomials, checks conjectures

---

## Algorithmic deliverable

You must produce a verified computational method, not just theorem statements.

### Required algorithm
Implement a certified or semi-certified decomposition/counting routine:

**Algorithm A: IDP decomposition**
Input:
- finite lattice generalized permutohedron support,
- integer \(t \ge 1\),
- lattice point \(x \in tP\).

Output:
- a tuple \(x_1,\dots,x_t \in P\cap \mathbb Z^n\) with sum \(x\).

This should mirror the inductive proof of IDP and be connected to a theorem of correctness.

Or:

**Algorithm B: Ehrhart tester**
Input:
- finite support \(S\subset \mathbb N^n\).

Output:
- Newton polytope data,
- counts \(L(P,t)\) for \(t=0,\dots,T\),
- interpolated Ehrhart polynomial,
- candidate \(h^*\)-vector,
- positivity/unimodality diagnostics.

The ideal outcome is both: a theorem-backed decomposition algorithm and a computational conjecture-testing pipeline.

---

## Why this would be a breakthrough

If you can prove even the first serious layer of this program, you create a new formalized research corridor:

1. **Lorentzian polynomials gain arithmetic shadows.**
   Their support geometry would control lattice-point enumeration, not just log-concavity of coefficients.

2. **Generalized permutohedra become a testbed for Hodge-theoretic Ehrhart positivity.**
   This could lead to new positivity theorems beyond zonotopes and classical matroid polytopes.

3. **A new formal bridge emerges between discrete convex analysis and algebraic combinatorics.**
   M-convex exchange axioms would become tools for proving normality/IDP and \(h^*\)-positivity.

4. **Follow-on work becomes possible immediately.**
   - real-rootedness or interlacing of Ehrhart numerators,
   - tropical/Hodge avatars of Ehrhart theory,
   - arithmetic partition functions for Lorentzian support semigroups,
   - refined conjectures for matroid base polytopes and valuated matroids.

This is exactly the kind of result that would make a researcher say: “I had not thought to derive Ehrhart positivity from Lorentzian support geometry.”

---

## Application keywords

Ehrhart positivity; generalized permutohedra; Lorentzian polynomials; M-convexity; integer decomposition property; \(h^*\)-vector; unimodality; log-concavity; combinatorial Hodge theory; Newton polytopes; lattice-point enumeration; affine semigroups; Hilbert series; Euler products; discrete convex analysis; arithmetic combinatorics; matroid polytopes; partition functions; statistical mechanics analogy.

---

## Mandatory deliverables

You must produce **all** of the following:

1. **Lean development** with at least 3 deep theorems, minimal sorrys, and at least one novel definition.
2. **A structured `FUTURE_DIRECTIONS.md`** containing **3–5 falsifiable scientific hypotheses**, each with:
   - precise conjectural statement,
   - explicit computational test,
   - what outcome would refute it.
3. **A standalone `RESEARCH_PAPER.md`** explaining:
   - the theorem statements,
   - proof architecture,
   - why the results matter mathematically,
   - what broader program they initiate.
   It must be intelligible without reading the code.
4. **An `ARTICLE.md`** in Scientific American style:
   - vivid, accessible, idea-centered,
   - focused on the mathematics and significance,
   - **do not focus on formal verification machinery**.
5. **A verified algorithm or computational method**, ideally the IDP decomposition algorithm and/or Ehrhart testing pipeline.
6. **A `demo.py`** that interactively demonstrates:
   - construction of sample Lorentzian-support Newton polytopes,
   - lattice-point counts under dilation,
   - fitted Ehrhart data,
   - positivity/unimodality checks,
   - and any discovered counterexample if the conjecture fails.

Be bold. If the full conjecture resists proof, isolate the strongest true theorem, prove it cleanly, and sharpen the conjecture rather than softening the ambition.

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
