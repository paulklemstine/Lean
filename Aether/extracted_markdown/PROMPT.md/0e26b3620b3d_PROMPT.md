## Assignment: Jacobian Conjecture, Cubic Reduction, and Weyl-Algebra Bridge

Mode: `formalize` + `prove`

Prove new, non-trivial theorems that push the formal frontier around the Jacobian Conjecture. Do **not** merely restate the full conjecture in Lean and stop. The decisive target is to formalize rigorous **reduction theorems** and **bridge principles** that turn the infinite-dimensional conjectural landscape into finitely checkable, structurally meaningful Lean objects.

Minimize sorry. Build on catalog theorems where they genuinely help, especially as algebraic-complexity scaffolding:
- `jacobian_conjecture_dim2_quadratic_homogeneous`
- `depth_zero_degree_le_one`
- `bounded_circuit_degree_bound`
- `field_has_krull_dim_zero`

The first is a local foothold in low-dimensional Jacobian theory. The circuit-complexity results should be used to formulate and control polynomial-map representations, degree growth, and potential reduction pipelines.

---

## Research Direction

Formalize the Jacobian condition for polynomial endomorphisms of affine space over a characteristic-zero field, then prove a chain of **reduction and equivalence theorems** strong enough to support future attacks on the full Jacobian Conjecture.

The central vision is this:

1. Define polynomial maps `k^n → k^n` in Lean as tuples of multivariate polynomials.
2. Define their Jacobian matrix and constant-Jacobian condition.
3. Formalize invertibility as existence of a polynomial inverse.
4. Prove **stable reduction principles**: adding dummy variables preserves the Jacobian property and polynomial invertibility.
5. Prove **triangular and affine cases** completely.
6. Formalize a precise **cubic-homogeneous reduction interface**: if every Keller map of cubic homogeneous Drużkowski type is invertible, then every Keller map is invertible.
7. Formalize at least one clean theorem expressing the **Jacobian ⇒ Dixmier** implication as a Lean-ready target, even if the full proof requires additional Weyl-algebra infrastructure.

This is revolutionary because the Jacobian Conjecture is not just a hard algebra problem: it is a nexus between
- affine algebraic geometry,
- differential algebra,
- automorphism groups of polynomial rings,
- noncommutative algebra via the Dixmier conjecture,
- and algebraic complexity through degree blowup and circuit representations.

A successful Lean formalization of the reduction architecture would create a machine-checked platform for attacking one of the deepest open problems in mathematics and would open a new field of **formal reduction theory for major conjectures**.

---

## Precise Theorem Targets

You should aim to prove several theorems, not one monolith. At minimum, target the following family.

### 1. Stable invertibility under adjoining variables

Mathematical statement:

For any field `k`, any polynomial map `F : k^n → k^n`, and any `m ≥ 0`, define
\[
F^{\uparrow m}(x,y) = (F(x), y).
\]
Then `F` is polynomially invertible iff `F^{\uparrow m}` is polynomially invertible. Moreover, the Jacobian determinant of `F^{\uparrow m}` equals the Jacobian determinant of `F`.

This is not the full Jacobian Conjecture, but it is a foundational reduction theorem that every serious formal development needs.

A Lean 4 target signature could look like:

```lean
theorem polyMap_invertible_iff_stableLift_invertible
  {k : Type*} [Field k]
  {n m : ℕ}
  (F : Fin n → MvPolynomial (Fin n) k) :
  PolynomialAutomorphism F ↔
    PolynomialAutomorphism (stableLift F m)
```

and

```lean
theorem jacobianDet_stableLift
  {k : Type*} [Field k]
  {n m : ℕ}
  (F : Fin n → MvPolynomial (Fin n) k) :
  jacobianDet (stableLift F m) = jacobianDet F
```

If determinant dimensions force a different formulation, use block-matrix language:

```lean
theorem jacobianMatrix_stableLift
  {k : Type*} [CommSemiring k]
  {n m : ℕ}
  (F : Fin n → MvPolynomial (Fin n) k) :
  jacobianMatrix (stableLift F m) =
    Matrix.fromBlocks (jacobianMatrix F) 0 0 1
```

This theorem is the right place to exploit Mathlib matrix/block determinant lemmas.

---

### 2. Triangular Keller maps are polynomial automorphisms

Mathematical statement:

Let `k` be a characteristic-zero field. If
\[
F_i = a_i X_i + P_i(X_1,\dots,X_{i-1})
\]
with each `a_i ≠ 0`, then `F` is a polynomial automorphism. Its Jacobian determinant is the nonzero constant `∏ a_i`.

Lean-style target:

```lean
theorem triangular_polynomialMap_is_automorphism
  {k : Type*} [Field k]
  {n : ℕ}
  (F : Fin n → MvPolynomial (Fin n) k)
  (htri : TriangularPolynomialMap F)
  (hunit : ∀ i, leadingCoeffDiag F i ≠ 0) :
  PolynomialAutomorphism F
```

and

```lean
theorem triangular_jacobianDet_constant
  {k : Type*} [Field k]
  {n : ℕ}
  (F : Fin n → MvPolynomial (Fin n) k)
  (htri : TriangularPolynomialMap F) :
  ∃ c : k, c ≠ 0 ∧ jacobianDet F = C c
```

This gives a certified class of Jacobian-conjecture-positive maps and provides the model for more difficult tame automorphism arguments.

---

### 3. Affine maps with nonzero determinant are polynomial automorphisms

Mathematical statement:

If
\[
F(x)=Ax+b
\]
for `A ∈ GL_n(k)`, then `F` is a polynomial automorphism, with inverse `x ↦ A^{-1}(x-b)`.

Lean target:

```lean
theorem affine_polynomialMap_is_automorphism
  {k : Type*} [Field k]
  {n : ℕ}
  (A : Matrix (Fin n) (Fin n) k)
  (b : Fin n → k)
  (hA : IsUnit A.det) :
  PolynomialAutomorphism (affinePolyMap A b)
```

This theorem should be easy enough to complete and will validate your foundational definitions.

---

### 4. Formal reduction interface to cubic homogeneous type

You likely cannot formalize the full Bass–Connell–Wright/Yagzhev reduction in one cycle unless the required commutative algebra infrastructure is already mature. But you **can** formalize the exact interface theorem that isolates what remains to be proved.

Mathematical statement:

Assume a theorem `CubicReductionHypothesis(k)` asserting that every Keller map of cubic homogeneous type over `k` is a polynomial automorphism. Then every Keller map over `k` is a polynomial automorphism.

Lean target:

```lean
def CubicHomogeneousKellerHolds (k : Type*) [Field k] : Prop :=
  ∀ {n : ℕ} (F : Fin n → MvPolynomial (Fin n) k),
    IsCubicHomogeneousMap F →
    IsKellerMap F →
    PolynomialAutomorphism F

theorem jacobian_conjecture_of_cubic_homogeneous
  {k : Type*} [Field k] [CharZero k]
  (hred : CubicHomogeneousKellerHolds k) :
  ∀ {n : ℕ} (F : Fin n → MvPolynomial (Fin n) k),
    IsKellerMap F →
    PolynomialAutomorphism F
```

If proving this full theorem is too ambitious, split it into formally meaningful subtargets:
- stable equivalence preserves Keller-ness,
- stable equivalence preserves automorphism,
- a definition of `DruzkowskiMap`,
- reduction theorem from general Keller maps to a stable-equivalent Drużkowski map as an axiomatically packaged interface.

Even a carefully designed interface here would be major progress.

---

### 5. Jacobian-to-Dixmier bridge: a formal theorem schema

The classical theorem is that the Jacobian conjecture in dimension `2n` implies the Dixmier conjecture in dimension `n`. You may not have enough Weyl algebra infrastructure yet, but you should at least create the formal bridge statement and prove whatever preliminary algebraic lemmas are feasible.

Lean-ready schema:

```lean
def JacobianConjectureHolds (k : Type*) [Field k] [CharZero k] : Prop :=
  ∀ {n : ℕ} (F : Fin n → MvPolynomial (Fin n) k),
    IsKellerMap F → PolynomialAutomorphism F

def DixmierConjectureHolds (k : Type*) [Field k] [CharZero k] : Prop :=
  ∀ {n : ℕ}, EveryWeylEndomorphismBijective k n

theorem dixmier_of_jacobian
  {k : Type*} [Field k] [CharZero k]
  (hJC : JacobianConjectureHolds k) :
  DixmierConjectureHolds k
```

If the Weyl algebra is not yet available in Mathlib, define a placeholder structure:
- generators `x_i, ∂_i`,
- canonical commutation relations,
- endomorphisms preserving relations.

Then prove support lemmas about filtration and associated graded objects, since the conceptual bridge runs through **passing from a noncommutative filtered algebra to a commutative polynomial algebra via principal symbols**. That alone is deep and worthwhile.

---

## Lean 4 Mathematical Framing

Use concrete formal objects. A recommended core setup:

- Polynomial maps:
```lean
abbrev PolyMap (k : Type*) (n : ℕ) := Fin n → MvPolynomial (Fin n) k
```

- Evaluation:
```lean
def PolyMap.eval {k : Type*} [CommSemiring k] {n : ℕ}
  (F : PolyMap k n) (x : Fin n → k) : Fin n → k := ...
```

- Jacobian entry:
```lean
def jacobianEntry
  {k : Type*} [CommSemiring k] {n : ℕ}
  (F : PolyMap k n) (i j : Fin n) : MvPolynomial (Fin n) k :=
  MvPolynomial.pderiv j (F i)
```

- Jacobian matrix:
```lean
def jacobianMatrix
  {k : Type*} [CommSemiring k] {n : ℕ}
  (F : PolyMap k n) : Matrix (Fin n) (Fin n) (MvPolynomial (Fin n) k) := ...
```

- Keller condition:
```lean
def IsKellerMap
  {k : Type*} [CommRing k] {n : ℕ}
  (F : PolyMap k n) : Prop :=
  ∃ c : k, c ≠ 0 ∧ (jacobianMatrix F).det = MvPolynomial.C c
```

- Polynomial automorphism:
```lean
def PolynomialAutomorphism
  {k : Type*} [CommSemiring k] {n : ℕ}
  (F : PolyMap k n) : Prop :=
  ∃ G : PolyMap k n,
    (compPolyMap F G = idPolyMap) ∧
    (compPolyMap G F = idPolyMap)
```

This foundation is itself valuable. It converts a famous informal conjecture into machine-checkable algebra.

---

## Proof Strategy Architecture

### Strategy A: Build a robust formal category of polynomial maps first
1. Define `PolyMap`, composition, identity, evaluation, Jacobian matrix, and automorphism.
2. Prove easy structural theorems: associativity of composition, identity laws, affine invertibility, triangular invertibility.
3. Use these to prove stable equivalence results and preservation of Jacobian determinant under block extension.

Why this is promising:
- It is highly Lean-compatible.
- It yields many publishable formal theorems even before the full conjecture.
- It creates reusable infrastructure for automorphism groups of affine space.

### Strategy B: Use algebraic complexity as the reduction engine
1. Represent polynomial maps by bounded circuits and use `bounded_circuit_degree_bound` to control degree growth under composition.
2. Define a translation from circuit representations to `PolyMap`.
3. Formalize that reduction operations (stabilization, affine conjugation, triangular shears) preserve bounded complexity and Keller-ness.

Why this is promising:
- It connects the Jacobian problem to complexity theory, a genuinely cross-domain move.
- It can produce new quantitative statements: degree bounds for inverses in special classes.
- It leverages catalog theorems nontrivially rather than decoratively.

Potential theorem:
```lean
theorem automorphism_inverse_degree_bound_of_circuit_bound
  ...
```
for triangular/tame subclasses.

### Strategy C: Filtered/noncommutative route toward Dixmier
1. Define a minimal Weyl-algebra-like structure or filtered algebra interface.
2. Formalize principal symbol maps and associated graded commutative algebras.
3. Show that endomorphism-invertibility questions descend to polynomial Poisson/Jacobian-type conditions.

Why this is promising:
- It opens the Jacobian–Dixmier bridge.
- It creates a path toward deformation-quantization formalization.
- It cross-pollinates commutative and noncommutative geometry.

Most promising immediate route:
**Strategy A first**, then augment with **Strategy B** for degree/control theorems. Strategy C is the visionary frontier and should be scaffolded now even if not completed.

---

## How to Build on Existing Verified Theorems

1. `jacobian_conjecture_dim2_quadratic_homogeneous`
   - Use it as the first certified nontrivial instance of your new `IsKellerMap → PolynomialAutomorphism` framework.
   - Refactor it into the new abstractions if possible.
   - Show your definitions are not vacuous by deriving this theorem as a corollary or compatibility theorem.

2. `bounded_circuit_degree_bound`
   - Use it to control degree explosion under polynomial-map composition.
   - This is especially relevant for proving that explicit inverse constructions in triangular/tame cases stay polynomial and have bounded degree.

3. `depth_zero_degree_le_one`
   - If depth-zero circuits correspond to affine/constant fragments, use this to characterize a base class of polynomial maps where Jacobian invertibility is decidable by linear algebra.
   - This can seed a theorem relating low circuit depth to tame automorphisms.

4. `field_has_krull_dim_zero`
   - Likely auxiliary, but it may help discharge commutative algebra side conditions when reasoning about polynomial rings over fields and spectra-free simplifications.

Do not force these theorems into the proof if they are irrelevant; but if used, use them structurally.

---

## Cross-Domain Connections You Must Exploit

### 1. Algebraic geometry × algebraic complexity
The Jacobian conjecture can be reframed as a rigidity statement about polynomial circuits with constant Jacobian determinant. This suggests new invariants:
- circuit depth under stable equivalence,
- degree growth of inverse candidates,
- tame/wild complexity classes of automorphisms.

Application keywords:
`algebraic complexity`, `circuit lower bounds`, `degree growth`, `symbolic computation`

### 2. Commutative algebra × noncommutative geometry
The Jacobian–Dixmier bridge is a prototype of a commutative-to-quantum transfer principle. Formalizing even the filtration layer would open Lean developments in:
- Weyl algebras,
- D-modules,
- deformation quantization,
- Poisson geometry.

Application keywords:
`Weyl algebra`, `D-modules`, `deformation quantization`, `Poisson brackets`

### 3. Dynamical systems × polynomial automorphisms
Polynomial automorphisms are discrete dynamical systems. Triangular/tame classes admit explicit iteration laws and inverse formulas. This may lead to:
- entropy-like invariants,
- degree-growth dichotomies,
- symbolic dynamics for automorphism groups.

Application keywords:
`polynomial dynamics`, `entropy`, `automorphism groups`, `degree complexity`

### 4. Formal verification × reduction theory
The real breakthrough is methodological: machine-checking the reduction architecture of a legendary open problem. This creates a new paradigm for formalizing “if-and-only-if reduction webs” around major conjectures.

Application keywords:
`formal verification`, `proof assistants`, `reduction theory`, `certified algebra`

---

## Concrete Milestones

1. Create a new file hierarchy such as:
   - `Algebra/Jacobian/Basic.lean`
   - `Algebra/Jacobian/Triangular.lean`
   - `Algebra/Jacobian/StableReduction.lean`
   - `Algebra/Jacobian/CubicReduction.lean`
   - `Algebra/Jacobian/DixmierBridge.lean`

2. In `Basic.lean`:
   - define `PolyMap`, composition, identity, Jacobian matrix, Keller map, automorphism.

3. In `Triangular.lean`:
   - prove triangular maps are automorphisms,
   - prove explicit Jacobian determinant formula.

4. In `StableReduction.lean`:
   - define `stableLift`,
   - prove Jacobian and invertibility preservation.

5. In `CubicReduction.lean`:
   - define `IsCubicHomogeneousMap`, `DruzkowskiMap`,
   - state and prove whatever reduction interface is feasible.

6. In `DixmierBridge.lean`:
   - define conjecture schemas,
   - formalize filtration/symbol infrastructure if full Weyl algebra is premature.

---

## Nontrivial Theorem Candidates Beyond the Core

If the main reduction theorem is out of reach, prove one of these strong intermediate results.

### Tame closure theorem
```lean
theorem tame_automorphism_closed_under_comp
  {k : Type*} [Field k] {n : ℕ} :
  ∀ {F G : PolyMap k n},
    IsTameAutomorphism F →
    IsTameAutomorphism G →
    IsTameAutomorphism (compPolyMap F G)
```

### Keller property under affine conjugation
```lean
theorem isKeller_affine_conjugate_iff
  {k : Type*} [Field k] {n : ℕ}
  (A B : Matrix (Fin n) (Fin n) k) (a b : Fin n → k)
  (hA : IsUnit A.det) (hB : IsUnit B.det)
  (F : PolyMap k n) :
  IsKellerMap (affineConjugate A a B b F) ↔ IsKellerMap F
```

### Jacobian determinant of composition
```lean
theorem jacobianDet_comp
  {k : Type*} [Field k] {n : ℕ}
  (F G : PolyMap k n) :
  jacobianDet (compPolyMap F G) =
    substitutePolyMap G (jacobianDet F) * jacobianDet G
```

This is a profound and reusable theorem. If you can formalize a chain rule at the polynomial-map level, you create a major algebraic engine.

---

## What Would Count as a Breakthrough

A breakthrough this cycle is **not** “formalized the statement of the Jacobian conjecture.” A breakthrough is one of:

- a machine-checked chain rule and Jacobian determinant composition theorem for multivariate polynomial maps;
- a stable-reduction theorem showing invertibility and Keller-ness are preserved under variable adjunction;
- a complete formal treatment of triangular/tame automorphisms with explicit inverses;
- a precise Lean theorem schema for `Jacobian ⇒ Dixmier`, supported by filtration lemmas;
- a formal cubic-homogeneous reduction interface that isolates the true remaining obstacle.

Any one of these would materially change the formal mathematics landscape.

---

## Required Deliverables

### Lean 4 proofs
Provide complete theorem statements and proofs wherever feasible. Prefer smaller composable lemmas over one giant theorem with many sorrys.

### FUTURE_DIRECTIONS.md
This is mandatory and critical. Include **3–5 testable scientific hypotheses**, each a precise falsifiable conjecture with a clear test.

Your hypotheses must be of the form “if we compute/prove X on class Y, then Z should hold,” with explicit confirmation/refutation criteria.

Include hypotheses such as:

### Degree-growth rigidity for tame Keller maps
Conjecture: For every tame Keller map `F : k^n → k^n` represented by a circuit of size `s` and degree `d`, the inverse map has degree bounded by a polynomial in `d` and `n`.
Test: Formalize tame generators, compute inverse degree formulas on generated examples, and search for superpolynomial counterexamples.

### Stable-equivalence complexity collapse
Conjecture: Every formally reduced cubic homogeneous Keller map is stably equivalent to one with strictly smaller circuit depth.
Test: Define stable equivalence and circuit depth for `PolyMap`; verify on generated families from known reductions.

### Symbolic Jacobian–Dixmier transfer
Conjecture: For filtered Weyl-type endomorphisms preserving standard filtration, invertibility of the associated graded symbol map implies invertibility of the endomorphism on a broad finitely generated subclass.
Test: Implement filtered endomorphism examples and check whether inverse lifting can be constructed uniformly.

### Triangularization detection heuristic
Conjecture: A large subclass of low-depth Keller maps over characteristic zero is affine-conjugate to triangular maps.
Test: Use circuit-depth bounds and explicit search in low dimensions to attempt conjugation normal forms.

### Dimension-2 cubic-homogeneous completeness
Conjecture: The existing theorem `jacobian_conjecture_dim2_quadratic_homogeneous` extends to a fully classified dimension-2 cubic homogeneous Keller family in the current library.
Test: Enumerate normal forms in `n = 2`, prove or refute invertibility case-by-case.

Also update the knowledge base with what definitions were missing, which reduction steps failed, and exactly what algebraic infrastructure is now available for the next cycle.

---

## Final Directive

Think like a field-founder, not a problem-set solver. The full Jacobian Conjecture may remain open, but the **formal reduction theory around it is absolutely attackable now**. Build the language, prove the transfer theorems, certify the tame world, and lay the Jacobian–Dixmier bridge. If a direct attack stalls, pivot immediately to proving theorems that make future attacks inevitable.

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
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

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

Research domain: Algebra
Research mode: prove
