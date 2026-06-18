## Assignment: Arithmetic Universality Classes in Tropical Degenerations of Neural Loss Landscapes

**Mode: prove / discover**

Aristotle, do not treat this as a small extension of tropical optimization folklore. The target is a new mathematical principle: that neural loss landscapes, when viewed through tropical degeneration, fall into **arithmetic universality classes** whose asymptotic topology is controlled by combinatorial and valuation-theoretic data rather than analytic accident. If true even in a rigorous restricted model, this opens a new field: **tropical topological learning theory**.

Your task is to formalize and prove genuinely new theorems in Lean 4 around a mathematically clean core of this vision, using Mathlib aggressively and minimizing sorrys.

---

## Core Vision

A one-parameter family of rational polynomial or piecewise-polynomial losses
\[
L_t : \mathbb{R}^n \to \mathbb{R}
\]
should, after logarithmic/tropical rescaling, converge to a tropical object whose polyhedral combinatorics governs asymptotic topological invariants of sublevel sets
\[
\{x : L_t(x) \le \lambda_t\}.
\]
The bold thesis is not merely convergence of functions, but **stabilization of topology into arithmetic universality classes**: families with the same tropicalization and valuation profile should exhibit the same normalized Betti and critical-cell asymptotics.

You do **not** need to formalize all of persistent homology or general neural nets. Instead, isolate a powerful theorem schema for finite tropical polyhedral models and prove it completely. Then articulate the larger conjectural bridge.

---

## Precise Formal Target

Define a tropicalized model of a loss landscape as a finite family of affine forms over `ℚ` or `ℤ`,
\[
f_i(x)=a_i\cdot x + b_i,
\]
with tropical loss
\[
T(x)=\max_i f_i(x)
\quad\text{or}\quad
T(x)=\min_i f_i(x),
\]
and define the **active-index complex** on a sublevel set by recording which affine pieces are simultaneously active.

The first breakthrough theorem should show that for a broad finite class of tropical losses, sublevel sets are polyhedrally controlled and their cell structure depends only on the valuation-combinatorial data.

### Theorem 1: Tropical sublevel polyhedral invariance
For finite families of affine forms with rational coefficients, if two tropical losses have the same normal fan / active-face incidence data, then their sublevel complexes are combinatorially isomorphic for corresponding regular values.

A Lean-oriented statement can target a finite-combinatorial surrogate:

```lean
structure TropicalAffineFamily (n : ℕ) where
  ι : Type
  [finι : Fintype ι]
  coeff : ι → Fin n → ℚ
  bias : ι → ℚ

def tropMax {n : ℕ} (F : TropicalAffineFamily n) (x : Fin n → ℚ) : ℚ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun i =>
    (Finset.univ.sum fun j => F.coeff i j * x j) + F.bias i)

def SublevelSet {n : ℕ} (F : TropicalAffineFamily n) (c : ℚ) : Set (Fin n → ℚ) :=
  {x | tropMax F x ≤ c}
```

Then formulate a finite theorem on active sets:

```lean
def ActiveSet {n : ℕ} (F : TropicalAffineFamily n) (x : Fin n → ℚ) : Finset F.ι :=
  Finset.univ.filter (fun i =>
    (Finset.univ.sum fun j => F.coeff i j * x j) + F.bias i = tropMax F x)

theorem activeSet_invariance_of_same_oriented_matroid
  {n : ℕ} (F G : TropicalAffineFamily n) :
  SameOrientedMatroid F G →
  ∀ ⦃x y : Fin n → ℚ⦄, CorrespondingPointData F G x y →
    OrderIso (ActiveSetComplex F) (ActiveSetComplex G)
```

You may need to define `SameOrientedMatroid`, `CorrespondingPointData`, and `ActiveSetComplex` in a finite, formalizable way. That is encouraged: this satisfies the novelty requirement.

### Theorem 2: Contractibility / homology concentration for convex tropical sublevel sets
For tropical max of affine forms, sublevel sets are intersections of halfspaces, hence convex polyhedra. Prove a nontrivial topological consequence in a combinatorial form: if nonempty, the sublevel set has trivial reduced homology / admits a collapse to a face-poset terminal object / has Euler characteristic 1.

A formal theorem could be:

```lean
theorem tropMax_sublevel_convex
  {n : ℕ} (F : TropicalAffineFamily n) (c : ℚ) :
  Convex ℚ (SublevelSet F c)
```

and then a deeper combinatorial corollary:

```lean
theorem eulerCharacteristic_sublevel_eq_one
  {n : ℕ} (F : TropicalAffineFamily n) (c : ℚ)
  (hnonempty : (SublevelSet F c).Nonempty)
  (hbounded : IsBounded (SublevelSet F c)) :
  EulerCharacteristic (FacePoset F c) = 1
```

If full Euler characteristic machinery is too heavy, prove a collapse theorem for a custom finite face-complex object.

### Theorem 3: Arithmetic universality via valuation equivalence
Introduce a new concept: two one-parameter polynomial families are **valuation-equivalent** if corresponding monomials have the same exponent-weight asymptotics and induce the same tropical support function. Then prove that valuation-equivalent families induce identical tropical active-set complexes.

A Lean signature sketch:

```lean
structure WeightedMonomial (n : ℕ) where
  exp : Fin n → ℕ
  coeff : ℚ
  weight : ℤ

structure TropicalPolynomialFamily (n : ℕ) where
  terms : List (WeightedMonomial n)

def valuationProfile {n : ℕ} (P : TropicalPolynomialFamily n) :
    Finset (Fin n → ℕ × ℤ) := ...

def ValuationEquivalent {n : ℕ}
    (P Q : TropicalPolynomialFamily n) : Prop := ...

theorem valuationEquivalent_imp_same_active_complex
  {n : ℕ} (P Q : TropicalPolynomialFamily n) :
  ValuationEquivalent P Q →
  ActiveComplex (tropicalize P) = ActiveComplex (tropicalize Q)
```

This is the theorem that turns “analytic details do not matter” into a sharp, formal statement.

---

## New Definitions You Should Introduce

You are required to create at least one genuinely new concept. Here are the right ones.

### 1. `ValuationEquivalent`
Two parametric polynomial families lie in the same arithmetic universality class if they have the same tropical support after weight extraction.

Interpretation: same leading-order valuation geometry, possibly different lower-order analytic coefficients.

### 2. `ActiveSetComplex`
A finite simplicial / incidence object whose faces are active-index sets realizable on a sublevel region of a tropical loss.

Interpretation: a combinatorial proxy for critical-region topology.

### 3. `ArithmeticUniversalityClass`
A quotient-like structure packaging all families with the same valuation profile and active complex.

Possible Lean skeleton:

```lean
structure ArithmeticUniversalityClass (n : ℕ) where
  repr : TropicalPolynomialFamily n
  carrier :
    Set (TropicalPolynomialFamily n)
  closed_under_equiv :
    ∀ {P}, P ∈ carrier ↔ ValuationEquivalent P repr
```

Even if you do not build full quotient infrastructure, define the structure and prove nontrivial invariance theorems about it.

---

## Proof Strategy Architecture

You must include at least 3 substantial theorems with real proof tactics. Below are promising proof routes.

### Strategy A: Convex-geometric route for tropical max losses
Most promising for fully verified Lean success.

1. Show
   \[
   \max_i(a_i\cdot x+b_i)\le c
   \iff \forall i,\ a_i\cdot x+b_i\le c.
   \]
   This converts tropical sublevel sets into finite intersections of affine halfspaces.

2. Prove convexity using Mathlib’s `Convex` API and closure of convexity under intersections.

3. Build a finite face-poset / active-set incidence structure and prove that when two families have the same active incidence relation, their face-posets are order-isomorphic.

Why this is promising: it uses robust Mathlib infrastructure (`Finset`, affine sums, convexity, order isomorphisms), avoids hard analytic topology, and still yields a theorem with real conceptual force.

### Strategy B: Oriented matroid / hyperplane arrangement route
More visionary and more difficult, but potentially field-opening.

1. Encode each affine family by sign data of pairwise differences:
   \[
   (a_i-a_j)\cdot x + (b_i-b_j).
   \]
   Active-set changes occur on these equality hyperplanes.

2. Define a finite combinatorial equivalence relation asserting that the sign patterns of all differences agree between two families.

3. Prove active-set complex invariance by induction on cells of the induced arrangement, using `rcases` on sign trichotomies and `by_contra` to rule out incompatible active sets.

Why this matters: this elevates the theorem from a convexity fact to a universality principle controlled by arrangement combinatorics.

### Strategy C: Valuation-theoretic route from polynomial families to tropical complexes
Harder but most aligned with the scientific conjecture.

1. For weighted monomials, define the tropicalization map by sending each monomial \(c t^w x^\alpha\) to the affine form \( \langle \alpha, u\rangle + w \).

2. Prove that valuation-equivalent families have equal tropical support functions.

3. Deduce equality or isomorphism of active complexes and therefore equality of normalized combinatorial invariants.

Why this is transformative: it connects asymptotic algebra, tropical geometry, and loss landscape topology in one formal package.

**Recommendation:** Complete Strategy A rigorously, push Strategy B as far as possible, and formulate Strategy C with at least one proved finite theorem and one sharp conjectural extension.

---

## Cross-Domain Connections You Must Exploit

This project becomes paradigm-shifting only if you make the bridge explicit.

### Tropical geometry ↔ optimization theory
Sublevel sets of tropical losses are polyhedra; active sets are analogues of linear regions in ReLU networks. This ties tropical degeneration directly to trainability and basin structure.

### Valuation theory ↔ statistical mechanics
The tropical limit is a zero-temperature / large-deviation limit: max-plus selection of dominant terms mirrors free-energy asymptotics. Universality classes here resemble phase classes in spin systems.

### Hyperplane arrangements ↔ Morse theory
Active-set changes across arrangement walls behave like combinatorial critical events. Even if full Morse theory is not formalized, your active-complex theorems should be framed as a discrete Morse surrogate.

### Arithmetic geometry ↔ learning theory
Rational coefficients and valuation profiles introduce arithmetic structure into landscape topology. This is the “arithmetic universality” thesis: number-theoretic data constrain optimization topology.

### Combinatorics ↔ persistent homology
The active-set complex is a finite combinatorial shadow from which one can predict topological persistence of sublevel filtrations. Formalize at least the filtration monotonicity if full persistence is too large.

---

## Application Keywords

tropical geometry; neural loss landscapes; arithmetic universality; valuation theory; polyhedral topology; active-set complexes; hyperplane arrangements; discrete Morse theory; persistent homology; optimization theory; learning theory; phase transitions; large deviations; combinatorial invariants; trainability prediction

---

## Concrete Theorem Menu

You need at least 3 deep theorems. A strong file would include something like:

1. **Sublevel-as-halfspace theorem**
   ```lean
   theorem mem_sublevel_iff_forall_affine_le
   ```
   proving equivalence between tropical sublevel membership and finitely many affine inequalities.

2. **Convexity theorem**
   ```lean
   theorem tropMax_sublevel_convex
   ```
   using multi-step `calc` and convex intersection arguments.

3. **Monotonic filtration theorem**
   ```lean
   theorem sublevel_mono {c d : ℚ} (h : c ≤ d) :
     SublevelSet F c ⊆ SublevelSet F d
   ```
   then lift this to monotonicity of active complexes or face-posets.

4. **Active-set realization theorem**
   ```lean
   theorem activeSet_eq_intersection_of_equalizers_and_dominance
   ```
   characterizing active sets by equality and inequality systems.

5. **Incidence invariance theorem**
   ```lean
   theorem same_incidence_imp_isomorphic_active_complex
   ```
   this is the conceptual centerpiece.

6. **Valuation-equivalence invariance theorem**
   ```lean
   theorem valuationEquivalent_imp_same_tropical_sublevel_data
   ```
   the arithmetic bridge.

7. **Cross-domain theorem**
   For example, connect tropical sublevel sets to a statistical-mechanics partition surrogate:
   ```lean
   theorem zero_temperature_limit_selects_tropical_dominant_terms
   ```
   in a finite combinatorial form. Even a discrete version would satisfy the cross-domain requirement if done seriously.

---

## Suggested Lean 4 Type Signatures

Use these as targets, refining as needed for Mathlib compatibility.

```lean
structure TropicalAffineFamily (n : ℕ) where
  ι : Type
  instFintype : Fintype ι
  coeff : ι → Fin n → ℚ
  bias : ι → ℚ

attribute [instance] TropicalAffineFamily.instFintype

def affineEval {n : ℕ} (F : TropicalAffineFamily n) (i : F.ι) (x : Fin n → ℚ) : ℚ :=
  (Finset.univ.sum fun j => F.coeff i j * x j) + F.bias i

def tropMax {n : ℕ} (F : TropicalAffineFamily n) (x : Fin n → ℚ) : ℚ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun i => affineEval F i x)

def SublevelSet {n : ℕ} (F : TropicalAffineFamily n) (c : ℚ) : Set (Fin n → ℚ) :=
  {x | tropMax F x ≤ c}

def ActiveSet {n : ℕ} (F : TropicalAffineFamily n) (x : Fin n → ℚ) : Finset F.ι :=
  Finset.univ.filter (fun i => affineEval F i x = tropMax F x)

theorem mem_sublevel_iff_forall_le
    {n : ℕ} (F : TropicalAffineFamily n) (c : ℚ) (x : Fin n → ℚ) :
    x ∈ SublevelSet F c ↔ ∀ i : F.ι, affineEval F i x ≤ c := by
  ...

theorem sublevel_mono
    {n : ℕ} (F : TropicalAffineFamily n) {c d : ℚ}
    (hcd : c ≤ d) :
    SublevelSet F c ⊆ SublevelSet F d := by
  ...

theorem tropMax_sublevel_convex
    {n : ℕ} (F : TropicalAffineFamily n) (c : ℚ) :
    Convex ℚ (SublevelSet F c) := by
  ...

structure WeightedMonomial (n : ℕ) where
  exp : Fin n → ℕ
  coeff : ℚ
  weight : ℤ

structure TropicalPolynomialFamily (n : ℕ) where
  terms : List (WeightedMonomial n)

def ValuationEquivalent {n : ℕ}
    (P Q : TropicalPolynomialFamily n) : Prop := ...

theorem valuationEquivalent_imp_same_support
    {n : ℕ} (P Q : TropicalPolynomialFamily n) :
    ValuationEquivalent P Q →
    tropicalSupport P = tropicalSupport Q := by
  ...
```

If equality of complexes is too rigid, use `Nonempty (ActiveComplex P ≃o ActiveComplex Q)` or a bespoke isomorphism type.

---

## What Counts as Success

A successful outcome is **not** “I proved convexity of a max of affine functions.” That is only the entry ticket.

Success means you produce a Lean development where:

- a new structure like `ValuationEquivalent` or `ActiveSetComplex` is defined;
- several nontrivial theorems are proved with real tactics and argument structure;
- at least one theorem explicitly connects tropical degeneration to another domain, such as arrangement combinatorics, statistical mechanics, or arithmetic valuation theory;
- the resulting formal package clearly supports the large conjecture on topological stabilization of neural loss landscapes.

---

## Testable Scientific Conjectures for FUTURE_DIRECTIONS.md

You must include 3–5 falsifiable hypotheses. At least these should appear:

1. **Arithmetic universality conjecture**  
   For families of rational polynomial losses with identical valuation profiles, normalized Betti vectors of sublevel filtrations converge to the same limit.  
   **Test:** generate distinct polynomial families with identical tropicalization; compute persistent homology numerically for increasing degeneration parameter.

2. **Critical-cell prediction conjecture**  
   The number of persistent high-dimensional critical cells is asymptotically bounded above by the number of maximal active sets in the tropical active complex.  
   **Test:** compare Morse-style numerical critical counts to active-complex counts.

3. **Phase-transition conjecture**  
   Changes in active-set complex combinatorics correspond to sharp transitions in gradient-flow connectivity between minima.  
   **Test:** track arrangement wall-crossings versus mode-connectivity experiments.

4. **Zero-temperature correspondence conjecture**  
   Softmax/Gibbs-smoothed losses converge, after rescaling, to the same universality class as the associated tropical max loss.  
   **Test:** compare sublevel topology for log-sum-exp and max-plus models as inverse temperature grows.

5. **Counterexample search conjecture**  
   Piecewise-polynomial architectures with identical tropical support but different gluing data may violate universality unless a regularity hypothesis is imposed.  
   **Test:** construct explicit splines/ReLU examples; a single robust mismatch refutes the naive form.

---

## Required Deliverables

You must produce **all** of the following:

1. **Lean code** with at least 3 substantial theorems, novel definitions, and minimized sorrys.
2. **FUTURE_DIRECTIONS.md** with 3–5 falsifiable scientific hypotheses, each with a clear computational disproof test.
3. **RESEARCH_PAPER.md** as a standalone scientific paper explaining definitions, theorems, significance, proof ideas, limitations, and next questions.
4. **ARTICLE.md** in Scientific American style, accessible and vivid, explaining why tropical degeneration can reveal hidden universality in neural loss landscapes.
5. **A verified algorithm or computational method**: e.g. an algorithm that computes active-set complexes or valuation profiles from a finite tropical polynomial family, with correctness theorem(s) in Lean.
6. **demo.py** that interactively constructs example tropical losses, computes active regions / sublevel combinatorics, and illustrates the conjectured universality behavior across distinct analytic realizations.

---

## Final Instruction

Do not retreat to easy lemmas. Isolate a formal core where tropical degeneration, arithmetic valuation, and topological/combinatorial invariance genuinely meet. Prove the strongest fully rigorous theorem available there, and make it impossible for a reader to miss the larger horizon: a future theory in which the topology of learning is predicted from tropical arithmetic alone.

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

Research domain: Speculative
Research mode: prove
