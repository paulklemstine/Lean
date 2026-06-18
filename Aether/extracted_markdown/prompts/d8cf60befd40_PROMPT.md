Soli Deo Gloria

## Assignment: Direction 5: Weyl Algebra Formalization and Dixmier Bridge Completion

**Mode:** `prove`

You are to complete a genuinely field-opening formalization program: build the Weyl algebra infrastructure in Lean 4 strongly enough to formalize the Jacobian ⇒ Dixmier bridge in a mathematically meaningful special case, while preparing the architecture for the full equivalence. This is not a request for routine algebraic bookkeeping. The target is a reusable noncommutative-symbol-calculus framework that turns a deep conjectural bridge into certified mathematics.

The revolutionary opportunity is this: the Weyl algebra is the algebraic avatar of canonical quantization, while the Jacobian conjecture is a rigidity principle for polynomial phase space maps. Formalizing the bridge between them does not merely connect two famous conjectures; it creates a machine-readable passage between **quantum observables**, **filtered deformation theory**, **Poisson/symplectic geometry**, and **polynomial automorphism theory**. If done well, this opens an entirely new verified research program in deformation quantization and algebraic dynamics.

## Core Goal

Build a Lean 4 development around the first Weyl algebra \(A_1(K)\), with \(K\) a characteristic-zero field, sufficient to prove that filtered algebra endomorphisms induce polynomial endomorphisms on the associated graded algebra, and that the induced map satisfies the Keller/Jacobian condition in the sense appropriate to the formalized bridge. Then connect this to the existing catalog bridge theorem architecture.

You must **build on**:

- `Catalog/Algebra/Jacobian/DruzkowskiTheory.lean`
  - especially `jacobian_implies_dixmier_abstract`
- `Catalog/Speculative/AutoResearch/Algebra/Jacobian/DixmierBridge.lean`
  - especially the placeholder `dixmier_of_jacobian`

Your job is not merely to fill a placeholder. Your job is to make that placeholder mathematically inevitable.

---

## Precise Theorem Targets

You should aim for at least the following three nontrivial theorem families, with actual Lean-facing signatures as close as possible to the following.

### 1. Weyl algebra relation and normal form infrastructure

Define a new structure formalizing a filtered Weyl-type algebra, at minimum for \(A_1(K)\). A good first new definition would be something like:

```lean
class IsWeylPair (K A : Type*) [Field K] [Ring A] [Algebra K A]
    (x d : A) : Prop where
  comm : d * x - x * d = 1
```

Then define the subalgebra / quotient model of the first Weyl algebra and prove nontrivial commutation formulas, e.g. the Leibniz-type relation:

```lean
theorem deriv_comm_pow
    {K A : Type*} [Field K] [CharZero K] [Ring A] [Algebra K A]
    {x d : A} (hwd : IsWeylPair K A x d) :
    ∀ n : ℕ, d * x^n = x^n * d + (n : K) • x^(n-1)
```

You may need a more algebraically correct codomain than `•` depending on the ambient structure; adjust the statement accordingly. The key point is: prove a genuine noncommutative binomial/Leibniz identity by induction, not by simplification.

A second deep theorem in this family:

```lean
theorem normal_order_exists_A1
    {K : Type*} [Field K] [CharZero K] :
    ∀ z : WeylAlgebra K, ∃ p : Finset (ℕ × ℕ) →₀ K,
      z = ∑ ij in p.support, C (p ij) * X^(ij.1) * D^(ij.2)
```

The exact signature will depend on your representation. The important mathematical content is a **normal-ordering theorem**: every element can be written in ordered \(x^i d^j\) form. This is the first real bridge to PBW-type reasoning and filtration.

### 2. Filtration and associated graded commutativity

Introduce a filtration by operator order, likely by total degree in \(x,d\) or order in \(d\) depending on the bridge architecture. Define a new concept if needed, e.g.

```lean
def WeylOrderFiltration (K : Type*) [Field K] [CharZero K] :
    ℕ → Submodule K (WeylAlgebra K)
```

Then prove that multiplication respects the filtration:

```lean
theorem mul_mem_orderFiltration
    {K : Type*} [Field K] [CharZero K]
    {i j : ℕ} {a b : WeylAlgebra K} :
    a ∈ WeylOrderFiltration K i →
    b ∈ WeylOrderFiltration K j →
    a * b ∈ WeylOrderFiltration K (i + j)
```

And then the decisive structural theorem:

```lean
theorem associatedGraded_commutative
    {K : Type*} [Field K] [CharZero K] :
    CommRing (AssociatedGraded (WeylOrderFiltration K))
```

More concretely, if Mathlib’s `AssociatedGraded` API is not yet sufficient, formalize and prove an explicit surrogate theorem:

```lean
theorem commutator_lowers_degree
    {K : Type*} [Field K] [CharZero K]
    {i j : ℕ} {a b : WeylAlgebra K} :
    a ∈ WeylOrderFiltration K i →
    b ∈ WeylOrderFiltration K j →
    ⁅a, b⁆ ∈ WeylOrderFiltration K (i + j - 1)
```

This is the true engine: the commutator lowers filtration degree, so the associated graded becomes commutative. This is the formal shadow of semiclassical limit / symbol calculus.

### 3. Endomorphisms induce graded polynomial maps satisfying the Jacobian condition

Define filtered endomorphisms:

```lean
structure FilteredAlgEnd (K A : Type*) [Field K] [Semiring A] [Algebra K A] where
  toAlgEnd : A →ₐ[K] A
  preserves_filtration :
    ∀ n, Map.map _ (WeylOrderFiltration K n) ≤ WeylOrderFiltration K n
```

Then prove that every filtered Weyl endomorphism induces an algebra endomorphism on the associated graded:

```lean
theorem filtered_endomorphism_induces_gr
    {K : Type*} [Field K] [CharZero K] :
    FilteredAlgEnd K (WeylAlgebra K) →
    (AssociatedGraded (WeylOrderFiltration K) →ₐ[K]
      AssociatedGraded (WeylOrderFiltration K))
```

Then identify the associated graded with a polynomial algebra in two variables, at least abstractly:

```lean
theorem gr_weyl_equiv_polynomial
    {K : Type*} [Field K] [CharZero K] :
    AssociatedGraded (WeylOrderFiltration K) ≃ₐ[K] MvPolynomial (Fin 2) K
```

If the full isomorphism is too large for one cycle, prove a weaker but still profound theorem that the degree-1 symbols of `x` and `d` generate a commutative polynomial subalgebra and that the induced endomorphism is determined by their images.

Finally, the bridge theorem in a formalizable special case:

```lean
theorem filtered_weyl_end_has_keller_symbol
    {K : Type*} [Field K] [CharZero K]
    (σ : FilteredAlgEnd K (WeylAlgebra K)) :
    IsKellerMap K (inducedPolynomialMap σ)
```

The exact notion `IsKellerMap` should match or extend the one already present in the Jacobian catalog. If necessary, define an intermediate notion such as constant-unit Jacobian determinant for the induced graded map and prove compatibility with the catalog theorem.

And then the capstone theorem linking to the catalog:

```lean
theorem dixmier_of_jacobian_A1
    {K : Type*} [Field K] [CharZero K]
    (HJC : JacobianConjectureHolds K 2) :
    ∀ σ : FilteredAlgEnd K (WeylAlgebra K), Function.Bijective σ.toAlgEnd
```

or, better, an `AlgEquiv` conclusion if your infrastructure supports it.

This should explicitly consume `jacobian_implies_dixmier_abstract` where possible, so that your work is not parallel folklore but an actual completion of the certified bridge.

---

## Why This Is a Breakthrough

A formalized proof that filtered endomorphisms of \(A_1(K)\) induce Keller maps on the symbol side is already a major result. It creates the first reusable certified infrastructure for:

- noncommutative Gröbner/PBW-style normal forms,
- associated graded transfer principles,
- semiclassical limits of operator algebras,
- algebraic encodings of canonical commutation relations,
- formal bridges between polynomial rigidity and quantized dynamics.

This is not “Weyl algebra basics.” This is the seed crystal for a formal theory of **deformation quantization in Lean**.

---

## Proof Architecture: 3 Viable Strategies

You must include at least 2–3 serious proof avenues in your development notes and choose one as primary.

### Strategy A: Quotient-of-free-algebra + rewriting + filtration by word length
1. Define \(A_1(K)\) as a quotient of the free associative algebra on generators \(X,D\) by the ideal generated by \(DX - XD - 1\).
2. Prove rewriting lemmas moving every `D` past every `X`, producing lower-order correction terms.
3. Use these lemmas to establish normal ordering and filtration compatibility, then pass to the associated graded.

**Why promising:** This is closest to the mathematical definition and makes the symbol map conceptually transparent. It also gives the strongest future infrastructure for higher \(A_n\).

**Risk:** Quotients of noncommutative free algebras may require substantial infrastructure if Mathlib support is thin.

### Strategy B: Abstract Weyl-pair axiomatization + representation into endomorphisms
1. Define `IsWeylPair K A x d`.
2. Develop the commutation calculus abstractly: powers, normal ordering, degree estimates for commutators.
3. Instantiate the theory in a concrete operator algebra acting on `Polynomial K`, where `x` acts by multiplication and `d` by formal differentiation.
4. Use faithfulness or explicit normal forms to transfer results back into the abstract Weyl algebra.

**Why promising:** This avoids immediate dependence on a heavy quotient construction and lets you prove substantial theorems quickly. It also exposes the physics/differential-operator interpretation naturally.

**Risk:** You may need careful handling of faithfulness and image characterization to avoid proving only representation-specific facts.

### Strategy C: PBW/deformation route via Ore extension heuristics
1. Realize \(A_1(K)\) as an Ore extension \(K[x][d; \delta]\) with \(\delta = d/dx\).
2. Use the Ore-extension multiplication rule to derive normal forms and filtration properties.
3. Prove that the associated graded forgets the derivation term, yielding a polynomial ring.

**Why promising:** This is algebraically elegant and may align best with proving `gr(A_1) ≅ K[x, ξ]`.
  
**Risk:** Ore extensions may not already exist in Mathlib, so you may need to define too much infrastructure.

### Recommendation
**Primary route: Strategy B**, with selective borrowing from Strategy C.

Reason: it maximizes theorem density per unit infrastructure and naturally supports deep proofs using induction and multi-step algebraic reasoning. You can still define the abstract Weyl algebra later, but the `IsWeylPair` layer lets you prove the commutation, filtration, and symbol theorems in a reusable way immediately. Then instantiate it in differential operators on `Polynomial K` and connect to the catalog bridge.

---

## Required Deep Theorems

Your file must contain **at least 3 theorems** whose proofs genuinely require multi-step reasoning. Good candidates:

1. **Power commutation formula**
   - induction on `n`
   - nontrivial use of distributivity and the Weyl relation

2. **Commutator lowers filtration degree**
   - induction / structural decomposition into normal forms
   - repeated use of `calc`, `rcases`, and additive closure of filtration pieces

3. **Filtered endomorphism induces graded endomorphism**
   - quotient-lift or associated graded universal property
   - proving well-definedness is nontrivial

4. **Jacobian/Keller condition for induced map**
   - identify the symbol map on generators
   - compute determinant via preservation of commutator / Poisson bracket shadow

At least one proof should involve `by_contra`, at least one should use induction, and at least one should require a substantial `calc` chain or `field_simp` if denominators arise in characteristic-zero arguments.

---

## New Definitions You Should Introduce

You must define at least one genuinely new concept absent from the catalog. Strong candidates:

1. `IsWeylPair`
   - abstract CCR pair inside a `K`-algebra

2. `WeylOrderFiltration`
   - filtration on the Weyl algebra by operator/order degree

3. `FilteredAlgEnd`
   - algebra endomorphisms preserving a filtration

4. `PrincipalSymbol`
   - top-degree symbol of a filtered Weyl element

5. `HasKellerSymbol`
   - endomorphism whose induced graded map has unit Jacobian determinant

These are not bureaucratic wrappers. They are the conceptual vocabulary needed to turn the JC–DC bridge into a composable theorem ecosystem.

---

## Cross-Domain Connections You Must Make Explicit

Include at least one theorem or definition that explicitly links Weyl algebra theory to another domain.

### Bridge 1: Algebra ↔ Quantum mechanics
The relation \(dx - xd = 1\) is the algebraic form of canonical commutation relations. Formalize a theorem stating that the commutator descends in the associated graded to a Poisson-like first-order operation. Even a weak version is profound:

```lean
theorem principalSymbol_commutator_eq_poisson
    {K : Type*} [Field K] [CharZero K] :
    principalSymbol (⁅a, b⁆) = poissonBracket (principalSymbol a) (principalSymbol b)
```

If the full Poisson bracket is too ambitious, prove a degree-drop theorem and state the stronger relation as a conjectural next step.

### Bridge 2: Noncommutative algebra ↔ Differential geometry
Interpret the associated graded algebra as the coordinate ring of cotangent space \(T^*\mathbb A^1\), with `x` and `ξ` as position/momentum coordinates. Then show induced endomorphisms act as polynomial phase-space maps.

### Bridge 3: Algebra ↔ Dynamical systems / symplectic geometry
The Keller condition is a polynomial rigidity condition; in the symbol picture, it corresponds to preserving infinitesimal volume/symplectic structure. Even if full symplecticity is not formalized, state and partially prove the preservation of the bracket on degree-1 symbols.

**Application keywords:** deformation quantization, canonical commutation relations, symbol calculus, polynomial automorphisms, symplectic rigidity, algebraic dynamics, semiclassical limit, Poisson geometry, Ore extensions, PBW normal forms.

---

## Concrete Build on Catalog Results

You must explicitly inspect and reuse:

- `jacobian_implies_dixmier_abstract`
  - Determine its hypotheses precisely.
  - Refactor your new definitions so that the theorem can be applied with minimal glue.
  - If the theorem expects an abstract graded/Keller package, instantiate that package for your Weyl filtration.

- `dixmier_of_jacobian`
  - Replace the placeholder with a theorem that is genuinely stronger than a stub:
    either a complete \(A_1\) formalization, or a clean reduction theorem showing that once `gr_weyl_equiv_polynomial` is available, the full bridge follows.

A good architectural theorem would be:

```lean
theorem dixmier_of_jacobian_via_symbol
    {K : Type*} [Field K] [CharZero K]
    (Hsym : ∀ σ : FilteredAlgEnd K (WeylAlgebra K), IsKellerMap K (inducedPolynomialMap σ))
    (HJC : JacobianConjectureHolds K 2) :
    ∀ σ : FilteredAlgEnd K (WeylAlgebra K), IsAutomorphism σ.toAlgEnd
```

This theorem isolates the hard symbolic step from the catalog’s abstract Jacobian machinery.

---

## Falsifiable Conjecture with Computational Test

You must include at least one explicit conjecture with a concrete disproof procedure.

### Conjecture A: Degree-preserving Weyl endomorphisms in \(A_1\) have affine-linear principal symbols
**Statement:** Any filtered endomorphism of \(A_1(K)\) preserving the standard order filtration and sending degree-1 generators to degree-1 elements induces an affine symplectic automorphism of `gr(A_1)`.

**Test:** Enumerate degree-1 candidate images
\[
x \mapsto ax + b\xi + c,\quad d \mapsto a'x + b'\xi + c'
\]
over small finite characteristic-zero surrogates / rational coefficient bounds, enforce the commutator relation, and test whether the induced matrix has determinant 1. Search for a counterexample with bounded coefficients.

### Conjecture B: Symbolic Jacobian rigidity for low-degree Weyl endomorphisms
**Statement:** Every filtered endomorphism of \(A_1(\mathbb Q)\) whose generator images have order \(\le 2\) induces a polynomial automorphism of the associated graded algebra.

**Test:** Implement bounded search over quadratic normal forms, compute induced graded map and Jacobian determinant, and test invertibility by symbolic elimination.

A counterexample would immediately falsify the conjecture. That is what makes it scientific.

---

## Verified Algorithm / Computational Method

You must deliver a verified computational component, not just theorem statements.

### Minimum algorithm target
Implement a **normal-ordering algorithm** for words in the generators \(X,D\) of the Weyl algebra.

Suggested spec:

```lean
def normalOrder : FreeWordXD → List ((ℕ × ℕ) × K)
```

or a more suitable finitely-supported map representation, together with a theorem of correctness:

```lean
theorem normalOrder_correct
    {K : Type*} [Field K] [CharZero K] :
    ∀ w, evalWordInWeyl w = evalNormalForm (normalOrder w)
```

This is mathematically meaningful and computationally useful. It can drive your demo and support experiments around low-degree endomorphisms.

### Stronger algorithm target
Add a procedure that, given candidate images of `x` and `d`, computes the induced principal symbol map and checks the Keller condition.

---

## Demo Requirement

Provide a `demo.py` that interactively demonstrates:
1. normal-ordering of sample Weyl words,
2. construction of the induced symbol map from sample endomorphisms,
3. Jacobian determinant computation for the symbol map,
4. experiments testing the conjecture on bounded-degree examples.

This is essential: theorem → algorithm → experiment.

---

## Deliverables You MUST Produce

You must produce all of the following:

1. **Lean file(s)** with the new definitions and at least 3 nontrivial theorems, minimizing `sorry`.
2. **`FUTURE_DIRECTIONS.md`**
   - 3–5 falsifiable scientific hypotheses
   - each with a clear computational or theoretical test that could fail
3. **`RESEARCH_PAPER.md`**
   - standalone scientific paper
   - explains Weyl algebra, filtration, symbol map, JC–DC bridge, what was proved, what remains
   - readable without code access
4. **`ARTICLE.md`**
   - Scientific American style
   - focus on the mathematics and its significance
   - do **not** focus on formal verification machinery
5. **Verified algorithm**
   - at minimum, normal-ordering correctness
6. **`demo.py`**
   - interactive demonstration of the mathematics

---

## Standards and Tactics

- No trivial theorem farming.
- Do not rely on `native_decide`, `decide`, `norm_num`, or `rfl` except where the statement itself is genuinely substantial.
- Prefer proofs using:
  - induction on words or degree,
  - `rcases` decomposition of filtered pieces / normal forms,
  - `by_contra` for uniqueness or nontriviality arguments,
  - `field_simp` if rational-function Jacobian computations arise,
  - long `calc` chains for commutator identities.
- Every theorem should visibly advance the bridge architecture.

---

## A Suggested Minimal-Grand-Slam Sequence

1. Define `IsWeylPair`.
2. Prove the commutation calculus for powers and monomials.
3. Define normal forms and prove a normal-ordering theorem.
4. Define `WeylOrderFiltration`.
5. Prove multiplication compatibility and commutator degree drop.
6. Define principal symbol / associated graded surrogate.
7. Show filtered endomorphisms induce graded endomorphisms.
8. Identify the induced map on generators as a polynomial map.
9. Prove the Keller condition in the formalized special case.
10. Invoke `jacobian_implies_dixmier_abstract` to obtain the automorphism conclusion.
11. Package the result into `dixmier_of_jacobian` or a precise \(A_1\) variant that cleanly completes the current cycle’s bridge.

---

## Final Vision

Do not think of this as “formalizing a famous conjecture.” Think of it as constructing the first verified corridor between:

- **quantum operator algebras** and
- **classical polynomial phase-space dynamics**.

If you succeed, the immediate follow-on program includes higher Weyl algebras \(A_n\), Poisson brackets on associated graded algebras, symplectic automorphism formalization, Ore extension infrastructure for Mathlib, and eventually a formal deformation-quantization stack. That is a new field of work, not a patch.

Build the bridge so that future mathematics can march across it.

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
