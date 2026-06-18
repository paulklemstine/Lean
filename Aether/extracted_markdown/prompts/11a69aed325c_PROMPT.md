# Soli Deo Gloria

## Mode: prove

## Assignment: Jacobian Conjecture, Cubic Reduction, and Weyl-Algebra Shadow

You are not being asked for another tiny special case. You are being asked to carve out a formally verified **structural corridor** through one of the great open problems in algebra: the Jacobian Conjecture. The target is not the full conjecture over `ℂ^n`—that would be miraculous—but a mathematically serious package of new theorems that isolates the mechanism of invertibility, formalizes a nontrivial reduction-to-cubic paradigm, and makes the bridge to the Dixmier conjecture precise enough that future attacks become inevitable rather than aspirational.

The existing catalog already gives you footholds:

- `FINAL/Algebra/Dim2.lean`
  - `jacobian_conjecture_dim2_quadratic_homogeneous`
- `FINAL/Algebra/DruzkowskiTheory.lean`
  - `jacobian_implies_dixmier_abstract`
- `FINAL/Algebra/WeylAlgebra.lean`
  - `dixmier_of_jacobian_A1_abstract`
- `FINAL/Algebra/UniversalTranslator.lean`
  - `field_has_krull_dim_zero`

Your task is to build **new formal infrastructure** around these results, not to restate them.

---

## Central Vision

The breakthrough direction is this:

> Isolate a formally tractable class of polynomial endomorphisms that captures the “constant Jacobian ⇒ rigidity” phenomenon, prove invertibility theorems there by nontrivial algebraic reasoning, and package a verified reduction principle showing that cubic homogeneous perturbations are the essential battlefield. Then connect this battlefield to the Weyl algebra/Dixmier world via an abstract transfer theorem.

This matters because the Jacobian conjecture has resisted direct attack for decades precisely because the category of all polynomial maps is too unconstrained. What is needed is a **verified architecture of reductions and rigid subclasses**. If you can formalize the reduction logic and prove new invertibility criteria inside that architecture, you create a machine for future progress.

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems** with multi-step proofs. At least one should introduce a genuinely new definition. At least one must bridge to a different domain.

Below are concrete theorem targets. You may refine names/types to fit Mathlib realities, but the mathematical content should remain intact.

---

### New Definition 1: Keller-type polynomial endomorphism structure

Define a structure encoding polynomial maps with constant Jacobian determinant and a chosen origin normalization.

Suggested Lean-facing design:
```lean
structure KellerMap (k : Type*) [Field k] (n : Type*) [Fintype n] [DecidableEq n] where
  toFun : (n → MvPolynomial n k) := fun i => X i
  jacobianDet : MvPolynomial n k
  jacobianDet_isUnit : ∃ c : kˣ, jacobianDet = C (c : k)
  origin_preserving : ∀ i, eval (0 : n → k) (toFun i) = 0
```

If direct determinant formalization is too heavy, define an abstract substitute first:
```lean
structure ConstantJacobianFamily (k : Type*) [Field k] (n : Type*) [Fintype n] [DecidableEq n] where
  f : n → MvPolynomial n k
  J : MvPolynomial n k
  J_const_unit : ∃ c : kˣ, J = C (c : k)
  origin_preserving : ∀ i, eval (0 : n → k) (f i) = 0
```

But do not stop at a wrapper. Prove nontrivial lemmas showing how this structure behaves under composition, linear conjugation, or homogeneous decomposition.

---

### Theorem 1: Linear part of a Keller map is invertible

This is elementary in the informal literature but becomes foundational in a formal reduction program.

**Mathematical statement**  
Let `F = X + higher order terms` be a polynomial endomorphism of `k^n` with constant nonzero Jacobian determinant. Then the matrix of linear coefficients of `F` is invertible over `k`.

**Suggested Lean type signature**
```lean
theorem KellerMap.linear_part_invertible
  (k : Type*) [Field k]
  (n : Type*) [Fintype n] [DecidableEq n]
  (F : KellerMap k n) :
  IsUnit (linearPartMatrix k n F.toFun).det
```

If `IsUnit det` is awkward, use:
```lean
theorem KellerMap.nonsingular_linear_part
  ... :
  Matrix.det (linearPartMatrix k n F.toFun) ≠ 0
```

**Why this is a breakthrough building block**  
Because every serious reduction of the Jacobian conjecture begins by normalizing the linear part to the identity. Formalizing this rigorously gives you the right to move from arbitrary Keller maps to the “identity plus nonlinear terms” regime, where cubic reduction and Druzkowski-type phenomena live.

---

### Theorem 2: Linear conjugation preserves the Keller property and invertibility

**Mathematical statement**  
If `F` is a Keller map and `A ∈ GL_n(k)`, then `A ∘ F ∘ A⁻¹` is again a Keller map. Moreover, invertibility of `F` is equivalent to invertibility of its linear conjugate.

**Suggested Lean type signature**
```lean
theorem KellerMap.conj_preserves_constant_jacobian
  (k : Type*) [Field k]
  (n : Type*) [Fintype n] [DecidableEq n]
  (F : KellerMap k n)
  (A : Matrix n n k)
  (hA : IsUnit A.det) :
  IsKeller (linearConjPolynomialMap k n A hA F.toFun)

theorem KellerMap.conj_invertible_iff
  (k : Type*) [Field k]
  (n : Type*) [Fintype n] [DecidableEq n]
  (F : n → MvPolynomial n k)
  (A : Matrix n n k)
  (hA : IsUnit A.det) :
  PolynomialMapInvertible (linearConjPolynomialMap k n A hA F) ↔
  PolynomialMapInvertible F
```

You will likely need to define:
- `linearPartMatrix`
- `linearConjPolynomialMap`
- `PolynomialMapInvertible`

**Why it matters**  
This theorem turns coordinate change from a heuristic into a verified reduction principle. It is the algebraic analogue of gauge invariance: you identify the true geometric content of the conjecture as lying beyond coordinates.

---

### Theorem 3: Normalization to identity linear part

Using Theorems 1 and 2, prove a reduction theorem:

**Mathematical statement**  
Every Keller map is linearly conjugate to one whose linear part is the identity.

**Suggested Lean type signature**
```lean
theorem exists_conjugate_with_identity_linear_part
  (k : Type*) [Field k]
  (n : Type*) [Fintype n] [DecidableEq n]
  (F : KellerMap k n) :
  ∃ G : n → MvPolynomial n k,
    IsKeller G ∧
    linearPartMatrix k n G = 1 ∧
    (PolynomialMapInvertible G ↔ PolynomialMapInvertible F)
```

This is a true reduction theorem, not a toy lemma.

**Why it is scientifically important**  
It formally compresses the Jacobian conjecture into the “tangent-to-identity” regime. This is the algebraic dynamical systems viewpoint: invertibility becomes a rigidity phenomenon for nonlinear perturbations of the identity.

---

### Theorem 4: Degree-3 truncation/reduction principle

You are explicitly asked to formalize reduction to degree 3. Since the full Bass–Connell–Wright reduction may be too large for one cycle, prove a **clean abstract reduction theorem** that isolates the degree-3 heart.

Introduce a new definition such as:
```lean
def IsCubicHomogeneousPerturbation
  (F : n → MvPolynomial n k) : Prop :=
  ∃ H : n → MvPolynomial n k,
    (∀ i, isHomogeneousOfDegree 3 (H i)) ∧
    F = fun i => X i + H i
```

Then prove a theorem of the following shape.

**Mathematical statement**  
If every cubic homogeneous Keller map with identity linear part is invertible in all finite dimensions over `k`, then every Keller map over `k` is invertible.

This can be stated abstractly as a reduction principle, even if the intermediate construction is axiomatized or partially formalized.

**Suggested Lean type signature**
```lean
theorem jacobian_reduces_to_cubic_homogeneous
  (k : Type*) [Field k]
  (hred :
    ∀ (n : Type*) [Fintype n] [DecidableEq n]
      (F : n → MvPolynomial n k),
      IsKeller F →
      linearPartMatrix k n F = 1 →
      IsCubicHomogeneousPerturbation F →
      PolynomialMapInvertible F) :
  ∀ (n : Type*) [Fintype n] [DecidableEq n]
    (F : n → MvPolynomial n k),
    IsKeller F → PolynomialMapInvertible F
```

If the fully general reduction is too ambitious, prove a dimension-restricted or formally abstracted version, but it must still be mathematically meaningful:
- fixed finite `n`
- or “assuming existence of a stable cubic reduction functor”
- or a theorem specialized to maps already decomposed into homogeneous pieces with vanishing quadratic part.

**Why this would be a breakthrough**  
Because it transforms a sprawling global conjecture into a sharply defined cubic battlefield. Even an abstract formal reduction theorem is major progress: it gives the formal ecosystem a correct target and prevents future work from dissipating across irrelevant cases.

---

### Theorem 5: Cross-domain bridge to Dixmier/Weyl algebra

You already have:
- `jacobian_implies_dixmier_abstract`
- `dixmier_of_jacobian_A1_abstract`

Do not merely cite them. Build a theorem that says your new reduction framework **feeds into** the abstract Jacobian⇒Dixmier machinery.

**Mathematical statement**  
A verified cubic reduction principle for Keller maps implies a corresponding reduction of the abstract Dixmier problem to cubic homogeneous data.

**Suggested Lean type signature**
```lean
theorem cubic_jacobian_reduction_implies_dixmier_reduction
  (k : Type*) [Field k]
  (hcubic :
    ∀ (n : Type*) [Fintype n] [DecidableEq n]
      (F : n → MvPolynomial n k),
      IsKeller F →
      linearPartMatrix k n F = 1 →
      IsCubicHomogeneousPerturbation F →
      PolynomialMapInvertible F) :
  AbstractDixmierReductionHolds k
```

Or, if there is an existing abstract theorem with a more specific target, instantiate it with your new reduction theorem and state the resulting corollary precisely.

**Why this is revolutionary**  
This is the cross-domain theorem. It connects affine algebraic geometry to noncommutative algebra and mathematical physics via Weyl algebras and quantization. The Jacobian conjecture ceases to be isolated; it becomes part of a transfer network between commutative and noncommutative rigidity.

---

## Proof Strategy Architecture

You must not provide a single-line proof plan. Develop at least 2–3 proof routes and choose the most promising one.

### Strategy A: Linear-part extraction + determinant-at-origin
1. Define the Jacobian matrix of a polynomial family and prove that evaluating it at the origin recovers the linear coefficient matrix.
2. Use the constant-Jacobian hypothesis to show the determinant evaluated at the origin is a nonzero scalar.
3. Conclude the linear part matrix is invertible.
4. Use this to build a conjugating linear automorphism sending the linear part to the identity.
5. Transport invertibility and Keller-ness across conjugation.

**Why promising**: This is the cleanest route to Theorems 1–3 and relies on finite-dimensional linear algebra plus polynomial evaluation, both of which are formalization-friendly.

---

### Strategy B: Homogeneous decomposition and tangent-to-identity rigidity
1. Decompose each coordinate polynomial into homogeneous components.
2. Prove that under origin preservation and constant Jacobian, degree-1 terms control formal invertibility.
3. Show that after normalization, all meaningful obstruction lives in degrees `≥ 2`.
4. Introduce the cubic-homogeneous perturbation class and prove closure lemmas.
5. Package an abstract reduction theorem saying that solving the cubic class solves the general class.

**Why promising**: This mirrors the conceptual structure of Bass–Connell–Wright/Druzkowski reductions without requiring you to formalize the entire classical proof at once.

---

### Strategy C: Weyl-algebra transfer route
1. Formalize the polynomial-map side enough to instantiate `jacobian_implies_dixmier_abstract`.
2. Use your reduction theorem to show that a cubic-homogeneous Jacobian engine would suffice to discharge the hypotheses needed for the abstract Dixmier implication.
3. Derive a corollary in the Weyl-algebra world.

**Why promising**: This is the best route for the cross-domain theorem and for making the work feel genuinely field-opening rather than self-contained.

**Most promising overall**: Combine **Strategy A + Strategy B** for the core formal algebra, then finish with **Strategy C** as the conceptual bridge.

---

## Required New Definitions

You must introduce at least one genuinely new concept. Recommended choices:

1. `KellerMap` or `IsKeller`
2. `linearPartMatrix`
3. `PolynomialMapInvertible`
4. `IsCubicHomogeneousPerturbation`
5. `HasIdentityLinearPart`

Do not define them as empty wrappers. Prove lemmas:
- preservation under composition
- preservation under conjugation
- interaction with evaluation at origin
- homogeneous degree support facts

---

## Cross-Domain Connections You Must Explicitly Develop

At least one theorem must connect Jacobian-style polynomial rigidity to another domain. Good options:

### 1. Noncommutative algebra / Weyl algebra
Use `jacobian_implies_dixmier_abstract` and `dixmier_of_jacobian_A1_abstract`.  
This is the strongest option.

### 2. Algebraic dynamics
Interpret maps with identity linear part as polynomial dynamical systems tangent to identity. Prove a theorem showing conjugation invariance of this class and discuss formal flow-like behavior.

### 3. Computational complexity / arithmetic circuits
Use `depth_zero_degree_le_one` from `Algebra/CoordinateRingDepth` as a conceptual bridge:
- linear maps correspond to shallow circuit structure,
- nonlinear perturbations force depth/degree growth,
- reduction to cubic homogeneous maps becomes a complexity-theoretic normal form.

A good cross-domain theorem here would assert that maps with depth-zero coordinate circuits cannot realize nontrivial Keller obstructions beyond degree 1, connecting invertibility to circuit depth constraints.

Suggested theorem shape:
```lean
theorem depth_zero_keller_maps_are_linear
  (R : Type*) [Field R]
  (n : Type*) [Fintype n] [DecidableEq n]
  (F : n → AlgCircuit R n)
  (hK : CircuitIsKeller F)
  (hdepth : ∀ i, (F i).depth = 0) :
  ∃ A : Matrix n n R, IsUnit A.det
```

Even if you only prove a weaker theorem, this is exactly the kind of unexpected bridge that opens new terrain.

---

## Conjecture with Testable Prediction

You must state at least one falsifiable conjecture and give a computational test.

### Recommended conjecture
**Cubic Nilpotent Support Conjecture**  
For a field `k` of characteristic zero, every cubic homogeneous Keller map
`F = X + H` whose Jacobian matrix `JH` has support graph of treewidth at most `2`
is polynomially invertible.

This is falsifiable: enumerate sparse cubic homogeneous maps over small finite fields or rational coefficient bounds, compute Jacobian determinant, and search for inverse degree growth or failure of invertibility.

Suggested Lean-facing conjecture placeholder:
```lean
conjecture cubic_sparse_keller_invertible
  (k : Type*) [Field k] [CharZero k]
  (n : Type*) [Fintype n] [DecidableEq n]
  (F : n → MvPolynomial n k) :
  IsKeller F →
  linearPartMatrix k n F = 1 →
  IsCubicHomogeneousPerturbation F →
  SupportGraphTreewidthLE F 2 →
  PolynomialMapInvertible F
```

### Computational test requirement
In `demo.py`, implement:
- random generation of cubic homogeneous perturbations `F = x + H`
- symbolic or finite-field Jacobian determinant check
- sparse support graph extraction
- brute-force invertibility search in small dimensions
- experiments testing the conjecture over bounded coefficient ranges

If a counterexample appears, that is scientifically valuable and should be reported.

---

## Lean 4 Formalization Targets

Aim for Lean signatures in the spirit of:

```lean
def linearPartMatrix
  (k : Type*) [Field k]
  (n : Type*) [Fintype n] [DecidableEq n]
  (F : n → MvPolynomial n k) : Matrix n n k := ...

def HasIdentityLinearPart
  (k : Type*) [Field k]
  (n : Type*) [Fintype n] [DecidableEq n]
  (F : n → MvPolynomial n k) : Prop :=
  linearPartMatrix k n F = 1

def PolynomialMapInvertible
  (k : Type*) [Field k]
  (n : Type*) [Fintype n] [DecidableEq n]
  (F : n → MvPolynomial n k) : Prop := ...

def IsCubicHomogeneousPerturbation
  (k : Type*) [Field k]
  (n : Type*) [Fintype n] [DecidableEq n]
  (F : n → MvPolynomial n k) : Prop := ...

theorem linear_part_det_eq_jacobian_at_origin
  ... : Matrix.det (linearPartMatrix k n F) =
        eval (0 : n → k) (jacobianDetPolynomial k n F)

theorem KellerMap.nonsingular_linear_part
  ... : Matrix.det (linearPartMatrix k n F) ≠ 0

theorem exists_conjugate_with_identity_linear_part
  ... : ∃ G, IsKeller G ∧ HasIdentityLinearPart k n G ∧
      (PolynomialMapInvertible k n G ↔ PolynomialMapInvertible k n F)

theorem jacobian_reduces_to_cubic_homogeneous
  ... : ...
```

You may need to weaken or parameterize some signatures depending on available Jacobian infrastructure, but preserve the mathematical force.

---

## How to Build on Catalog Theorems

1. **Use `jacobian_conjecture_dim2_quadratic_homogeneous`**
   - As a base case or sanity check for your new definitions.
   - Prove that your `IsKeller` / `PolynomialMapInvertible` notions recover this theorem in the relevant dimension-2 quadratic homogeneous setting.
   - Derive a corollary showing your framework is compatible with known positive cases.

2. **Use `jacobian_implies_dixmier_abstract`**
   - Instantiate it after proving your cubic reduction theorem.
   - The point is not citation; the point is transfer of your new structural result into the noncommutative world.

3. **Use `dixmier_of_jacobian_A1_abstract`**
   - Extract a low-dimensional corollary or a toy model of the transfer principle.
   - This gives concrete evidence that your formal reduction architecture actually reaches a different domain.

4. **Use `field_has_krull_dim_zero`**
   - Leverage it where dimension-theoretic simplifications help with localization or scalar arguments.
   - Even if lightweight, it helps justify ring-theoretic simplifications in a field setting.

5. **Use `depth_zero_degree_le_one`**
   - This is your bridge to complexity/arithmetic circuits.
   - Turn it into a theorem saying shallow coordinate descriptions force linearity, hence trivial Keller behavior.
   - That is a genuine cross-domain insight: the Jacobian problem has a complexity threshold.

---

## Nontrivial Proof Tactics Requirement

Your file must contain at least 3 theorems with deep proof patterns. Make sure they visibly use some of:
- `induction`
- `rcases`
- `by_contra`
- `field_simp`
- multi-step `calc`

Natural places:
- proving invertibility of the linear part via contradiction
- decomposing homogeneous pieces by induction on degree support
- proving conjugation preserves invertibility by explicit construction
- proving evaluation identities with chained `calc`

Do not hide all substance behind automation.

---

## Verified Algorithm / Computational Method

You must produce not only theorems but also a verified computational method.

### Required algorithm
Implement a procedure that, for a polynomial map `F = X + H` in small finite dimension:
1. extracts the linear part matrix,
2. checks whether the Jacobian determinant is a nonzero scalar,
3. normalizes by linear conjugation to identity linear part when possible,
4. detects whether `H` is cubic homogeneous,
5. attempts formal inverse construction to bounded degree.

This can be a semi-decision algorithm or certified checker. The point is to make the theory experimentally alive.

Possible Lean theorem:
```lean
theorem normalize_keller_map_algorithm_sound
  ... :
  normalizeKellerMap F = some G →
  IsKeller F →
  IsKeller G ∧ HasIdentityLinearPart k n G
```

---

## demo.py Requirements

Your `demo.py` must:
- let the user enter or randomly generate polynomial maps,
- compute Jacobian matrices and determinants,
- display linear-part normalization,
- test cubic-homogeneous status,
- attempt inverse reconstruction to bounded degree,
- run experiments for the sparse cubic conjecture.

Interactive outputs should include:
- original map
- normalized map
- Jacobian determinant
- inferred structural class
- conjecture test result

---

## Revolutionary Significance

If successful, this project opens a new program:

- **Formal reduction theory for the Jacobian conjecture**: not solving the whole conjecture, but building the verified machinery that every future attack will need.
- **A transfer interface to Dixmier/Weyl algebra**: turning an isolated commutative problem into a bridge toward noncommutative rigidity and quantization.
- **Complexity-theoretic normal forms**: suggesting that the hardness of Jacobian-type invertibility may correlate with circuit depth and sparse interaction structure.
- **Experimental algebraic conjecture generation**: with `demo.py` and a verified normalization algorithm, you create a lab bench for testing structural hypotheses on cubic maps.

This is not incremental. It is the beginnings of a formal science of reduction for one of the deepest conjectures in affine algebra.

---

## Application Keywords

Jacobian conjecture; Keller maps; polynomial automorphisms; cubic homogeneous reduction; Druzkowski reduction; Weyl algebra; Dixmier conjecture; affine algebraic geometry; noncommutative algebra; algebraic dynamics; arithmetic circuits; sparse polynomial maps; symbolic computation; inverse map algorithm; rigidity; quantization.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean code** with at least 3 substantial theorems, at least 1 new definition, and minimized `sorry`.
2. **A verified algorithm or computational method** for normalization/checking/inverse search of Keller-type maps.
3. **`demo.py`** demonstrating the theory interactively and experimentally.
4. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - define the problem and your new structures,
   - state the theorems clearly,
   - explain the reduction architecture,
   - describe the Dixmier bridge,
   - discuss limitations and next targets.
5. **`ARTICLE.md`** in Scientific American style:
   - explain the Jacobian conjecture and why reduction matters,
   - describe cubic maps and the Weyl algebra bridge,
   - do **not** focus on formal verification machinery.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 concrete research directions.
   - Each direction must include the exact sentences:
     - **“The key insight is...”**
     - **“Why now?”**
   - At least one direction must bridge to a different domain, such as quantum algebra, complexity theory, or dynamical systems.

Be bold. Build the reduction machinery that the full conjecture has been waiting for.

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

Research domain: Algebra
Research mode: prove
