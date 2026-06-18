## Assignment: Jacobian Conjecture: Quadratic Rigidity, Cubic Reduction, and Noncommutative Horizons

**Mode:** `prove` + `formalize` + `counterexample`

You are not being asked for a routine extension. You are being asked to formalize one of the great fault lines in affine algebraic geometry and to carve out a Lean-certified corridor through it. The immediate target is not the full Jacobian Conjecture over characteristic zero — that remains open — but the **sharpest formally reachable frontier**: the complete quadratic case, the structural reduction to cubic homogeneous / Drużkowski form, systematic elimination of plausible counterexample templates, and a formal bridge toward noncommutative algebra via the Jacobian ⇒ Dixmier implication.

This is field-opening because a robust Lean development here would create the first reusable formal infrastructure for:
- polynomial automorphisms in several variables,
- Jacobian matrices and determinant constraints,
- nilpotent Jacobian phenomena,
- cubic homogeneous reductions,
- and eventually Weyl algebra / Dixmier interfaces.

That infrastructure is bigger than this problem. It is the skeleton for future formal affine algebraic geometry.

---

## Core Theorem Targets

### Target 1: Quadratic Jacobian Conjecture in all dimensions
Over a characteristic-zero field \(K\), every polynomial map \(F : K^n \to K^n\) of total degree at most 2 with constant nonzero Jacobian determinant is a polynomial automorphism.

A mathematically precise formulation to aim for:

> **Theorem (Quadratic Jacobian Rigidity).**  
> Let \(K\) be a field of characteristic zero, \(n \in \mathbb{N}\), and let
> \[
> F(x) = x + H(x)
> \]
> where each coordinate of \(H\) has total degree exactly 2 or less and zero constant and linear terms, so \(H\) is homogeneous quadratic (after affine-linear normalization).  
> If \(\det(JF)\) is a nonzero constant, then \(F\) admits a polynomial inverse.

The key hidden structure is that for quadratic maps, the Jacobian matrix of the nonlinear part is **linear in the variables**. Constancy of \(\det(I + JH(x))\) forces strong nilpotence constraints on \(JH(x)\), and in characteristic zero this collapses the problem to a triangularizable/nilpotent regime where explicit inversion is possible.

### Lean 4 formalization target
You will likely need an incremental Lean statement, because full polynomial-map infrastructure may need to be built. A plausible endpoint signature is:

```lean
theorem quadratic_jacobian_conjecture
  (K : Type*) [Field K] [CharZero K]
  (n : ℕ)
  (F : Fin n → MvPolynomial (Fin n) K)
  (hdeg : ∀ i, (F i).totalDegree ≤ 2)
  (hlin : ∀ i, constantCoeff (F i) = 0)
  (hjac :
    isUnit
      (mvPolynomialJacobianDet
        (fun i => F i)))
  :
  ∃ G : Fin n → MvPolynomial (Fin n) K,
    leftRightPolynomialInverse F G
```

If `mvPolynomialJacobianDet` and `leftRightPolynomialInverse` do not exist, define them cleanly and locally. A more workable normalized version is:

```lean
theorem quadratic_map_with_constant_jacobian_is_automorphism
  (K : Type*) [Field K] [CharZero K]
  (n : ℕ)
  (H : Fin n → MvPolynomial (Fin n) K)
  (h_hom_deg2 : ∀ i, isHomogeneous (H i) 2)
  (hjac_const :
    jacobianDet (fun i => X i + H i) ∈
      Submodule.span K ({1} : Set (MvPolynomial (Fin n) K)))
  :
  ∃ G : Fin n → MvPolynomial (Fin n) K,
    isPolynomialInverse (fun i => X i + H i) G
```

Even if you must weaken the conclusion first to a triangularizable or nilpotent-Jacobian intermediate theorem, do so. The infrastructure is part of the contribution.

---

### Target 2: Formalize the Bass–Connell–Wright / Drużkowski reduction to cubic form
You should not claim a complete formal proof of the full reduction unless you can genuinely support it, but you should aim to formalize a substantial certified fragment.

> **Theorem (Reduction Blueprint).**  
> The Jacobian Conjecture over characteristic zero reduces to the case of maps of the form
> \[
> F(x) = x + H(x)
> \]
> with \(H\) cubic homogeneous; moreover one can further reduce to Drużkowski maps
> \[
> F(x) = x + (Ax)^{[3]}
> \]
> under appropriate rank/nilpotence constraints.

This is revolutionary in Lean because it transforms an intractable infinite class into a rigid normal form. Even a partial formalization of the reduction machinery — homogenization, linear normalization, stable equivalence, cubic reduction, rank-one cubic decomposition — would become a launchpad for future attacks.

### Lean 4 target signature
A realistic formal target is a **reduction theorem schema** rather than the whole conjecture:

```lean
theorem jacobian_conjecture_reduces_to_cubic_homogeneous
  (K : Type*) [Field K] [CharZero K] :
  (∀ n : ℕ,
    ∀ F : Fin n → MvPolynomial (Fin n) K,
      cubicHomogeneousJacobianCondition F →
      polynomialAutomorphism F) →
  (∀ n : ℕ,
    ∀ F : Fin n → MvPolynomial (Fin n) K,
      generalJacobianCondition F →
      polynomialAutomorphism F)
```

And then a sharper normal-form theorem:

```lean
theorem cubic_homogeneous_reduces_to_druzkowski_form
  (K : Type*) [Field K] [CharZero K]
  (n : ℕ)
  (F : Fin n → MvPolynomial (Fin n) K)
  (hcubic : cubicHomogeneousJacobianCondition F) :
  ∃ m : ℕ, ∃ G : Fin m → MvPolynomial (Fin m) K,
    isDruzkowskiMap G ∧
    stablyEquivalent F G
```

You may need to define `stablyEquivalent`, `isDruzkowskiMap`, and the Jacobian conditions.

---

### Target 3: Counterexample candidate elimination
The prompt asks for “construct explicit counterexample candidates and verify they fail.” This is excellent: formalized negative evidence is valuable and honest.

Concrete target:

> **Theorem (No low-dimensional quadratic/cubic candidate survives Jacobian test).**  
> For explicit families \(F = x + H\) in dimensions 2, 3, 4 with prescribed sparse monomial patterns, if \(\det JF\) is constant then \(F\) is triangular or explicitly invertible.

This should be done computationally but formally for small dimensions and sparse templates.

### Lean 4 target examples
For dimension 2:

```lean
theorem quadratic_plane_jacobian_candidate_is_invertible
  (K : Type*) [Field K] [CharZero K]
  (a b c d e f : K) :
  let F₁ : MvPolynomial (Fin 2) K :=
    X 0 + C a * X 0^2 + C b * X 0 * X 1 + C c * X 1^2
  let F₂ : MvPolynomial (Fin 2) K :=
    X 1 + C d * X 0^2 + C e * X 0 * X 1 + C f * X 1^2
  isConstant (jacobianDet ![F₁, F₂]) →
  ∃ G : Fin 2 → MvPolynomial (Fin 2) K,
    isPolynomialInverse (fun i => (![F₁, F₂] i)) G
```

For a Drużkowski-style family in dimension 3:

```lean
theorem druzkowski_3d_sparse_candidate_fails_as_counterexample
  (K : Type*) [Field K] [CharZero K]
  (A : Matrix (Fin 3) (Fin 3) K)
  (hjac : isConstant (jacobianDet (druzkowskiMap A))) :
  ¬ isCounterexampleToJacobianConjecture (druzkowskiMap A)
```

This theorem can be proved by showing invertibility, triangularizability, or incompatibility of the Jacobian constraints with the coefficient pattern.

---

### Target 4: Jacobian conjecture implies Dixmier conjecture — formal bridge skeleton
This is an ambitious formalization target. Do not fake the full proof if the Weyl algebra infrastructure is absent. But do build the bridge theorem at the level the library can sustain.

> **Theorem (Formal Bridge Schema).**  
> Assuming the Jacobian Conjecture over characteristic zero, every endomorphism of the Weyl algebra \(A_n(K)\) is an automorphism.

This is historically profound: it links affine algebraic geometry to noncommutative ring theory and mathematical physics. A formal bridge theorem, even if partially axiomatized, would be a major conceptual contribution.

### Lean 4 target signature
At minimum:

```lean
theorem jacobian_implies_dixmier
  (K : Type*) [Field K] [CharZero K]
  (hJC :
    ∀ n : ℕ, jacobianConjectureHolds (K := K) n) :
  ∀ n : ℕ, dixmierConjectureHolds (K := K) n
```

If the Weyl algebra is not in Mathlib, define an abstract interface:

```lean
class WeylLikeAlgebra (K : Type*) [Field K] (n : ℕ) where
  carrier : Type*
  -- generators, commutation relations, endomorphisms, automorphisms, etc.
```

Then prove a reduction theorem conditional on the standard transfer machinery. The value is not only the final theorem but the formal architecture.

---

## Why this would be a breakthrough

A Lean development of these targets would create the first serious formal ecosystem for the Jacobian Conjecture’s reduction theory. That ecosystem would immediately support:
- polynomial automorphism groups,
- tame vs wild automorphisms,
- nilpotent Jacobian criteria,
- algorithmic inversion of polynomial maps,
- and transfer principles to noncommutative algebra.

This is not “formalizing a famous theorem.” It is building the machine that can attack families of open problems.

---

## Proof Strategy Architecture

### Strategy A: Nilpotent Jacobian route for the quadratic case
This is the most promising path for a genuine theorem.

1. **Normalize to identity linear part.**  
   Show any quadratic map with invertible constant Jacobian can be conjugated by affine-linear automorphisms into
   \[
   F = I + H, \quad H \text{ homogeneous quadratic}.
   \]
   In Lean, formalize affine changes of coordinates and preservation of polynomial invertibility.

2. **Exploit determinant constancy.**  
   Since \(JH(x)\) is linear in \(x\), the identity
   \[
   \det(I + JH(x)) = 1
   \]
   for all \(x\) should force vanishing of traces of powers and hence nilpotence of \(JH(x)\).  
   Formal route: use the characteristic polynomial / Newton identities if available, or prove a specialized matrix lemma for linear-matrix families.

3. **Derive explicit inverse by finite series / triangularization.**  
   Once nilpotence is established, show \(F\) is injective or triangularizable, or directly construct the inverse recursively by degree.  
   For quadratic homogeneous perturbations with nilpotent Jacobian, the inverse often truncates because degree growth is controlled.

**Why most promising:** it isolates the truly quadratic phenomenon and avoids the full BCW machinery.

---

### Strategy B: Bass–Connell–Wright style degree reduction
This is structurally deeper and better for future work.

1. **Formalize stable equivalence and suspension variables.**  
   Add auxiliary variables to transform general polynomial maps into maps with controlled degree profile while preserving invertibility/Jacobian condition.

2. **Build cubic homogeneous normal form.**  
   Use homogenization, elimination of lower-degree terms, and polarization-style constructions to show reduction to \(x + H\) with \(H\) cubic homogeneous.

3. **Refine toward Drużkowski maps.**  
   Express cubic maps as sums of cubes of linear forms; encode rank constraints through matrices and formalize the \((Ax)^{[3]}\) normal form.

**Why valuable:** even partial success yields reusable formal infrastructure of lasting significance.

---

### Strategy C: Exhaustive low-dimensional candidate elimination
This is the best route for counterexample analysis and for reducing sorry count quickly.

1. **Parameterize sparse families.**  
   Choose dimensions 2 and 3 and monomial support sets with enough flexibility to look nontrivial.

2. **Compute Jacobian determinant symbolically.**  
   Equate nonconstant coefficients to zero and solve the resulting algebraic constraints in Lean.

3. **Classify surviving cases as invertible.**  
   Show they are triangular, linearly conjugate to triangular, or admit explicit inverse formulas.

**Why useful:** it produces concrete verified theorems now, while stress-testing the infrastructure needed for the bigger targets.

---

## Cross-domain connections you must exploit

### 1. Algebraic complexity theory
Use the catalog’s circuit-complexity theorems not as decoration but as a conceptual bridge:
- `bounded_circuit_degree_bound`
- `mulGates_lower_bound_from_degree`

A polynomial automorphism with low degree but constrained inverse degree can be interpreted as a structured algebraic circuit phenomenon. If you formalize explicit inverse degree bounds for quadratic Jacobian maps, connect them to circuit complexity lower/upper bounds. This opens a surprising direction: **invertibility constraints as circuit rigidity**.

Possible theorem direction:
- prove that the inverse of a quadratic Jacobian map admits a bounded algebraic circuit whose multiplication-gate complexity is controlled by nilpotence index or dimension.

This would connect affine algebraic geometry to arithmetic complexity in a way that feels genuinely new.

### 2. Noncommutative algebra / mathematical physics
The Jacobian ⇒ Dixmier bridge ties polynomial automorphisms to endomorphisms of Weyl algebras, i.e. canonical commutation relations. This is the algebraic shadow of quantum mechanics. Frame this explicitly:
- Jacobian side: symmetries of affine space,
- Dixmier side: rigidity of quantized phase space.

Even a partial formalization here opens a path toward certified deformation quantization interfaces.

### 3. Dynamical systems and symbolic inversion
Polynomial maps \(F = I + H\) with nilpotent Jacobian behave like finitely renormalizable dynamical systems. Recursive inversion resembles normal-form methods in dynamics. This perspective may guide degree-by-degree inverse construction in Lean.

### 4. Computational algebra / certified search
Counterexample-template elimination can be organized as a certified symbolic search problem. If you construct a small engine for sparse polynomial families, that engine can later be reused for other open conjectures.

---

## Concrete subtheorems to prioritize

### A. Matrix-theoretic Jacobian lemmas
You likely need these before the main theorem.

```lean
theorem constant_det_I_add_linear_matrix_implies_nilpotent
  (K : Type*) [Field K] [CharZero K]
  (n m : ℕ)
  (A : Fin m → Matrix (Fin n) (Fin n) K)
  (hdet :
    ∀ x : Fin m → K,
      det (1 + ∑ i, x i • A i) = 1) :
  ∀ x : Fin m → K,
    IsNilpotent (∑ i, x i • A i)
```

This is a high-value bridge theorem. It isolates the linear algebra heart of the quadratic case.

### B. Quadratic homogeneous map inverse construction
```lean
theorem inverse_of_identity_plus_quadratic_nilpotent
  (K : Type*) [Field K] [CharZero K]
  (n : ℕ)
  (H : Fin n → MvPolynomial (Fin n) K)
  (hdeg : ∀ i, isHomogeneous (H i) 2)
  (hnil : jacobianFamilyNilpotent H) :
  ∃ G : Fin n → MvPolynomial (Fin n) K,
    isPolynomialInverse (fun i => X i + H i) G
```

### C. Plane case as a base theorem
Even though the 2D case is classical and easier, it is an excellent proving ground.

```lean
theorem jacobian_conjecture_degree_two_dim_two
  (K : Type*) [Field K] [CharZero K]
  (F : Fin 2 → MvPolynomial (Fin 2) K)
  (hdeg : ∀ i, (F i).totalDegree ≤ 2)
  (hjac : isUnit (jacobianDet F)) :
  ∃ G : Fin 2 → MvPolynomial (Fin 2) K,
    isPolynomialInverse F G
```

### D. Stable equivalence preserves invertibility
```lean
theorem stable_equivalence_preserves_polynomial_automorphism
  (K : Type*) [Field K]
  {n m : ℕ}
  (F : Fin n → MvPolynomial (Fin n) K)
  (G : Fin m → MvPolynomial (Fin m) K)
  (h : stablyEquivalent F G) :
  polynomialAutomorphism F ↔ polynomialAutomorphism G
```

This is foundational for BCW / Drużkowski reduction.

---

## Implementation guidance in Lean 4

Use concrete, finite-variable polynomial maps:
- `Fin n → MvPolynomial (Fin n) K`
- Jacobian as a matrix `Matrix (Fin n) (Fin n) (MvPolynomial (Fin n) K)`

You will probably need to define:
- partial derivative matrix,
- Jacobian determinant,
- polynomial map composition,
- inverse relation,
- homogeneous degree predicates,
- stable equivalence,
- Drużkowski map schema.

Prefer a layered architecture:
1. `Jacobian/Basic.lean`
2. `Jacobian/PolynomialMap.lean`
3. `Jacobian/QuadraticCase.lean`
4. `Jacobian/CubicReduction.lean`
5. `Jacobian/Druzkowski.lean`
6. `Jacobian/DixmierBridge.lean`

Minimize sorry by first proving **small exact lemmas**:
- derivative of `X i`,
- derivative of monomials,
- chain rule for polynomial maps,
- determinant invariance under affine conjugation,
- degree bounds under composition.

The catalog theorem `bounded_circuit_degree_bound` may help formalize inverse degree growth bounds once you encode polynomial maps as circuits; `mulGates_lower_bound_from_degree` may support a complexity corollary distinguishing candidate inverses from impossible sparse forms.

---

## Counterexample program: explicit families to kill

Do not search randomly. Choose families whose Jacobian determinant can be fully expanded.

### Family 1: 2D quadratic homogeneous
\[
F(x,y)=\bigl(x+ax^2+bxy+cy^2,\; y+dx^2+exy+fy^2\bigr).
\]
Compute \(\det JF\), equate coefficients of \(x,y,x^2,xy,y^2\) appropriately, solve constraints, classify the surviving maps.

### Family 2: 3D triangular-perturbed cubic
\[
F_i = x_i + \ell_i(x)^3
\]
with sparse linear forms \(\ell_i\). Check whether constancy of Jacobian determinant forces linear dependence patterns implying triangularity.

### Family 3: rank-one / rank-two Drużkowski matrices
For \(F(x)=x+(Ax)^{[3]}\), prove:
- rank \(A = 1\) cannot yield a counterexample,
- rank \(A = 2\) in small dimensions collapses to an explicitly invertible case.

These are excellent theorem-sized targets.

---

## Application keywords
Use these explicitly in your writeup and theorem comments:

**Jacobian conjecture, polynomial automorphism, affine algebraic geometry, nilpotent Jacobian, Drużkowski reduction, cubic homogeneous maps, stable equivalence, Weyl algebra, Dixmier conjecture, arithmetic circuit complexity, symbolic inversion, algebraic dynamics, formal verification, noncommutative geometry, quantization rigidity**

---

## Deliverables

1. **Lean 4 code** proving at least one nontrivial theorem from the targets above, ideally the quadratic case in dimension 2 first and then the all-dimensional quadratic theorem or a substantial nilpotence lemma.
2. **Definitions and infrastructure** for Jacobian matrices, polynomial map composition, and invertibility.
3. **A certified counterexample-elimination file** for explicit low-dimensional families.
4. **A serious partial formalization of cubic / Drużkowski reduction**, even if only via reduction schemas and preserved properties.
5. **A bridge theorem skeleton for Jacobian ⇒ Dixmier**, with honest axiomatization where needed.
6. **FUTURE_DIRECTIONS.md** — mandatory.

---

## Required FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md` with **3–5 concrete next steps**, each including:
- an exact theorem statement,
- a Lean type signature sketch,
- 2 proof strategies,
- why it would be breakthrough-level,
- and at least one cross-domain connection.

The next-step suggestions should be of the following caliber:
- formal tame/wild dichotomy in low dimensions,
- inverse degree bounds from nilpotence index,
- certified equivalence between Drużkowski maps and rank-constrained tensor cubes,
- Jacobian-to-Weyl transfer through deformation quantization interfaces,
- complexity lower bounds for candidate inverse circuits.

This is the beginning of a formal theory, not a one-off proof. Build the machine.

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

Research domain: Algebra
Research mode: prove
