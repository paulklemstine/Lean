## Soli Deo Gloria

## Assignment: Jacobian Conjecture — Degree 2, Drużkowski Reduction, and the Dixmier Bridge

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

---

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog.

4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain (e.g., Weyl algebra automorphisms ↔ polynomial automorphisms, or graph-theoretic Keller maps).

5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

## Research Direction

The Jacobian Conjecture (JC) is among the deepest open problems in commutative algebra: *if F : Kⁿ → Kⁿ is a polynomial map over a field K of characteristic zero, and det(JF) ∈ K*, then F is invertible with polynomial inverse.* This brief targets three breakthrough axes:

**(A)** Prove JC for **quadratic (degree 2) polynomial maps in all dimensions n ≥ 1**, building on the existing `jacobian_conjecture_dim2_quadratic_homogeneous` and generalizing via the structure theory of quadratic Keller maps.

**(B)** Formalize **Drużkowski's reduction (2003)**: JC for all polynomial maps is equivalent to JC for *cubic linear maps* of the form Φ(x) = x + A·(x^[3]), where A is an n×n matrix and (x^[3])_i = x_i³. This reduces the full conjecture to a single, highly structured class.

**(C)** Establish the **Jacobian–Dixmier bridge**: prove that JC_n implies DC_n (the Dixmier conjecture for the Weyl algebra W_n), following Tsuchimoto's differential-ideals argument. This connects polynomial automorphisms to noncommutative algebra.

---

## Mathematical Framing

### Axis A: Quadratic JC in All Dimensions

**Key Theorem (Wang 1980, generalized):** Every quadratic Keller map is a triangular automorphism up to a linear change of coordinates.

```lean
/-- A quadratic polynomial map from K^n to K^n -/
structure QuadraticPolyMap (K : Type*) [Field K] [CharZero K] (n : ℕ) where
  linear_part : Matrix (Fin n) (Fin n) K
  quadratic_part : Fin n → Fin n → Fin n → K  -- symmetric 3-tensor
  -- F_i(x) = Σ_j a_{ij} x_j + Σ_{j,k} b_{ijk} x_j x_k

/-- The Jacobian determinant of a quadratic polynomial map -/
def QuadraticPolyMap.jacobianDet {K n} [Field K] [CharZero K] (F : QuadraticPolyMap K n) : K :=
  (F.jacobianMatrix).det

/-- A Keller map: polynomial map with constant nonzero Jacobian determinant -/
def IsKellerMap {K n} [Field K] [CharZero K] (F : QuadraticPolyMap K n) : Prop :=
  ∃ c : K, c ≠ 0 ∧ F.jacobianDet = c

/-- A quadratic Keller map is invertible (Jacobian Conjecture for degree 2) -/
theorem jacobian_conjecture_quadratic_all_dim {K : Type*} [Field K] [CharZero K]
    {n : ℕ} (F : QuadraticPolyMap K n) (hK : IsKellerMap F) :
    ∃ (G : QuadraticPolyMap K n), F ∘ G = id ∧ G ∘ F = id := by
  sorry
```

**Proof Strategy A (Most Promising — Triangularization via Hessian):**
1. Show that a quadratic Keller map F has a *constant Hessian tensor* H(F) (the quadratic part is the same everywhere, since second derivatives are constant for degree 2).
2. Prove that the Hessian matrix H_i = [∂²F_i/∂x_j∂x_k] is nilpotent for each i: if det(JF) = const ≠ 0, then the symmetric part of H_i vanishes after a linear coordinate change. This uses the *Keller nilpotency condition*: for quadratic maps, det(JF) = det(A + B(x)) where B(x) is linear in x, and constancy forces B(x)² = 0 in a precise sense.
3. Apply *triangular decomposition*: nilpotency of the Hessian implies F is linearly conjugate to a triangular map (each F_i depends only on x_1, ..., x_i), and triangular maps with constant nonzero Jacobian are manifestly invertible by back-substitution.

**Proof Strategy B (Reduction to dim 2 via fiber argument):**
1. Prove the base case dim n = 2 (already in catalog as `jacobian_conjecture_dim2_quadratic_homogeneous`).
2. For general n, use the *fiber dimension theorem*: if F : Kⁿ → Kⁿ is quadratic with det(JF) = c ≠ 0, then every fiber F⁻¹(y) is either empty or a single point (by the Ax-Grothendieck theorem specialized to degree 2).
3. Injectivity + polynomial map over characteristic zero field implies surjectivity (by dimension counting), and the inverse is polynomial by the Jacobian condition and the effective Nullstellensatz.

**Proof Strategy C (Drużkowski's direct argument for degree 2):**
1. Any degree 2 map F with det(JF) = 1 can be written as F(x) = x + Q(x) where Q is homogeneous of degree 2.
2. The condition det(I + DQ(x)) = 1 forces DQ(x) to be nilpotent for all x.
3. A nilpotent homogeneous quadratic map is a *Keller map of the first kind*, and these were classified by Drużkowski: they are triangular after coordinate change.

**Strategy A is most promising** because the Hessian approach gives a clean inductive structure and the nilpotency condition is the key algebraic lever.

---

### Axis B: Drużkowski's Cubic Linear Reduction

```lean
/-- A cubic linear map: Φ_i(x) = x_i + Σ_j a_{ij} x_j³ -/
structure CubicLinearMap (K : Type*) [Field K] [CharZero K] (n : ℕ) where
  matrix : Matrix (Fin n) (Fin n) K
  -- Φ(x) = x + A · (x₁³, ..., x_n³)

/-- The Jacobian of a cubic linear map is I + 3·A·diag(x₁²,...,x_n²) -/
def CubicLinearMap.jacobianMatrix {K n} [Field K] [CharZero K]
    (Φ : CubicLinearMap K n) : MvPolynomial (Fin n) K →ₗ[K] MvPolynomial (Fin n) K :=
  Matrix.toLin (Matrix.diagonal (fun i => 1) +
    3 • (Φ.matrix * Matrix.diagonal (fun i => MvPolynomial.X i ^ 2)))

/-- Drużkowski's theorem: JC for all polynomial maps is equivalent to
    JC for cubic linear maps -/
theorem druzkowski_reduction {K : Type*} [Field K] [CharZero K] {n : ℕ} :
    (∀ (F : PolynomialMap K n), IsKellerMap F → IsPolyAutomorphism F) ↔
    (∀ (Φ : CubicLinearMap K n), IsKellerMap Φ.toPolyMap → IsPolyAutomorphism Φ.toPolyMap) := by
  sorry
```

**Proof Strategy for Drużkowski Reduction:**
1. (←) Trivial: cubic linear maps are a special case.
2. (→) Given any polynomial map F with det(JF) = 1, construct the *cubic linearization*:
   - First reduce to the case where F(0) = 0 and JF(0) = I (affine change).
   - Apply the *Yagzhev transformation*: replace F(x) = x + H(x) where H has no constant or linear terms, with the map Φ(x) = x + A·x^[3] where A encodes the cubic structure of H after a sequence of blow-ups and specializations.
   - The key lemma: det(JΦ) = 1 ⟺ det(JF) = 1, and Φ is invertible ⟹ F is invertible (by a deformation/retraction argument).
3. The formalization challenge is constructing the explicit transformation F ↦ Φ and proving it preserves both the Keller property and invertibility.

---

### Axis C: The Jacobian–Dixmier Bridge

```lean
/-- The Weyl algebra W_n(K) = K⟨x₁,...,x_n,∂₁,...,∂_n⟩ / (∂_i x_j - x_j ∂_i = δ_{ij}) -/
-- (Use existing Mathlib Weyl algebra if available, otherwise define)

/-- Dixmier conjecture for W_n: every endomorphism of W_n is an automorphism -/
def DixmierConjecture (K : Type*) [Field K] [CharZero K] (n : ℕ) : Prop :=
  ∀ (φ : WeylAlgebra K n →ₐ[K] WeylAlgebra K n), Function.Bijective φ

/-- JC_n implies DC_n (Tsuchimoto 2003, Adjamagbo-van den Essen 2003) -/
theorem jc_implies_dixmier {K : Type*} [Field K] [CharZero K] {n : ℕ}
    (hJC : ∀ (F : PolynomialMap K n), IsKellerMap F → IsPolyAutomorphism F) :
    DixmierConjectory K n := by
  sorry
```

**Proof Strategy (Tsuchimoto's Differential Ideals):**
1. Given an endomorphism φ : W_n → W_n, construct the *commuting variety* V(φ) ⊆ K^{2n} defined by the equations [φ(x_i), φ(∂_j)] = δ_{ij}.
2. Show that φ being an endomorphism implies the map F_φ : K^{2n} → K^{2n} defined by the "symbol map" of φ is a polynomial map with det(JF_φ) = 1 (using the filtration on W_n and the associated graded algebra).
3. Apply JC_{2n} to conclude F_φ is invertible, hence φ is injective.
4. Injectivity of endomorphisms of W_n implies bijectivity (by the Gelfand-Kirillov dimension argument: W_n is a simple ring of GK-dimension 2n, and any injective endomorphism preserves GK-dimension, forcing surjectivity).

**Cross-domain connection:** This theorem bridges **commutative algebra** (polynomial automorphisms) and **noncommutative algebra** (Weyl algebra endomorphisms), with the bridge built from **differential calculus** (symbol calculus) and **algebraic geometry** (commuting varieties). It also connects to **representation theory** (simple rings of infinite GK dimension).

---

## Novel Definitions Required

```lean
/-- The nilpotency index of a quadratic map's Hessian --
    measures how "triangular" the map is -/
def QuadraticPolyMap.hessianNilpotencyIndex {K n} [Field K] [CharZero K]
    (F : QuadraticPolyMap K n) : ℕ :=
  Inf { k | ∀ (x : Fin n → K), (F.hessianMatrix x) ^ (k + 1) = 0 }

/-- The Drużkowski transform: converts a general Keller map into a cubic linear map -/
def DruzkowskiTransform {K n} [Field K] [CharZero K]
    (F : PolynomialMap K n) : CubicLinearMap K (2 * n) :=
  -- Explicit construction via the Yagzhev substitution

/-- The symbol map from Weyl algebra endomorphisms to polynomial maps -/
def WeylEndomorphism.symbolMap {K n} [Field K] [CharZero K]
    (φ : WeylAlgebra K n →ₐ[K] WeylAlgebra K n) : PolynomialMap K (2 * n) :=
  -- Extract the leading symbol of φ(x_i) and φ(∂_i) under the order filtration
```

---

## Cross-Domain Theorem

```lean
/-- A quadratic Keller map defines a graph whose adjacency encodes the
    Hessian structure. The map is triangular iff this graph is acyclic.
    This connects the Jacobian conjecture to graph theory (DAGs). -/
theorem keller_map_acyclic_hessian_graph {K n} [Field K] [CharZero K]
    (F : QuadraticPolyMap K n) (hK : IsKellerMap F) :
    F.hessianGraph.IsAcyclic ↔ ∃ (P : Matrix (Fin n) (Fin n) K),
      P.det ≠ 0 ∧ (P • F).IsTriangular := by
  sorry
```

This connects the Jacobian conjecture to **extremal graph theory** (compare `mantel_theorem` in the catalog) — the Hessian graph of a Keller map must avoid certain cycle structures, analogous to Turán-type conditions.

---

## Conjecture with Testable Prediction

```lean
/-- CONJECTURE (Falsifiable): For every cubic linear Keller map Φ in dim n ≤ 5,
    the matrix A in Φ(x) = x + A·x^[3] has rank at most n - 1.
    Equivalently: no cubic linear Keller map has full-rank A.
    TEST: Enumerate all 2×2 matrices A over F_3, check which give det(JΦ) = 1,
    verify that all have rank ≤ 1. Then test 3×3 over F_3, etc. -/
conjecture cubic_linear_keller_rank_bound (n : ℕ) (hn : n ≤ 5) :
    ∀ (Φ : CubicLinearMap ℚ n), IsKellerMap Φ.toPolyMap →
    Φ.matrix.rank ≤ n - 1
```

**Computational test in demo.py:** Enumerate matrices A ∈ M_n(F_p) for small n and p, compute det(I + 3A·diag(x_i²)) as a polynomial, check if it equals 1, and verify the rank condition. A single counterexample over any F_p would disprove the conjecture.

---

## Application Keywords

`polynomial_automorphism`, `Keller_map`, `Drużkowski_reduction`, `cubic_linear_map`, `Weyl_algebra`, `Dixmier_conjecture`, `noncommutative_algebra`, `symbol_calculus`, `hessian_nilpotency`, `triangular_automorphism`, `commuting_variety`, `GK_dimension`, `Yagzhev_transform`, `graph_theoretic_Jacobian`

---

## Revolutionary Significance

Proving the quadratic JC in all dimensions would be the **first complete dimensional generalization** of the Jacobian conjecture for any fixed degree class. Formalizing Drużkowski's reduction would establish that the **entire Jacobian conjecture lives or dies on a single, highly structured family** (cubic linear maps) — a dramatic complexity collapse. The Jacobian–Dixmier bridge would open a **noncommutative frontier**: tools from commutative algebra could be imported into the study of Weyl algebras, with implications for quantum mechanics (Weyl algebras model canonical commutation relations), deformation quantization, and D-module theory. The graph-theoretic reformulation connects to **structural combinatorics**, opening the possibility of applying expander methods, spectral graph theory, and extremal combinatorics to one of algebra's hardest problems.

---

## MANDATORY DELIVERABLES

You MUST produce ALL of:

**(a)** `FUTURE_DIRECTIONS.md` with 3-5 testable scientific hypotheses — each a falsifiable conjecture with a clear computational test.

**(b)** `RESEARCH_PAPER.md` — a STANDALONE scientific document that someone reading ONLY this paper (no access to code) can understand: what was discovered, why it matters, what to investigate next.

**(c)** `ARTICLE.md` — Scientific American style, engaging and accessible, explaining the discovery to a broad audience.

**(d)** A verified algorithm or computational method (not just a theorem statement) — e.g., an algorithm that takes a quadratic polynomial map and certifies it is a Keller map by computing its Jacobian determinant, or an algorithm that performs the Drużkowski transform.

**(e)** `demo.py` that demonstrates the result interactively — enumerate cubic linear maps over finite fields, test the rank conjecture, visualize the Hessian graph structure.

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

Research domain: Algebra
Research mode: prove
