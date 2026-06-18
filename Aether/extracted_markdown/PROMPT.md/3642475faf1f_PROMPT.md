
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: Close Proofs: Close Proofs: Formalized bridge between ReLU neural network decision
**Domain**: Applications
**Mathematical framing**: Cycle 15a7bd19 (Q=0.510) proved 2153 theorems in Applications but left 3 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Cycle 15e5810c (Q=0.451) proved 861 theorems in MachineLearning but left 3 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directio
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/Homological/CSSCohomology.lean
/-
# CSS Codes as Cohomology: Quantum Error Correction from Homological Algebra

This file formalizes the connection between Calderbank-Shor-Steane (CSS) quantum
error-correcting codes and cohomology of chain complexes. The main results are:

1. A CSS code is a pair of subspaces C_Z ≤ C_X of F^n, encoding k = dim(C_X/C_Z) logical qubits.
2. Any chain complex ∂₂ : V₂ → V₁ → V₀ with ∂₁ ∘ ∂₂ = 0 yields a CSS code where
   C_X = ker(∂₁) and C_Z = range(∂₂).
3. The number of logical qubits equals the first Betti number β₁ = dim(H₁).
4. CSS code duality corresponds to Poincaré duality on the chain complex.
5. The Hamming distance of the CSS code is bounded below by the systolic distance.
-/
import Mathlib

open scoped BigOperators
open LinearMap Submodule Module

noncomputable section

/-! ## CSS Code Definition -/

/-- A CSS (Calderbank-Shor-Steane) quantum error-correcting code over a field `𝔽`
    with ambient dimension `n`. It consists of two subspaces `C_Z ≤ C_X ≤ 𝔽^n`,
    corresponding to the Z-stabilizer and X-stabilizer codes respectively. -/
structure CSSCode (𝔽 : Type*) [Field 𝔽] (n : ℕ) where
  /-- The X-stabilizer code (kernel of parity checks) -/
  C_X : Submodule 𝔽 (Fin n → 𝔽)
  /-- The Z-stabilizer code (image of generating matrix) -/
  C_Z : Submodule 𝔽 (Fin n → 𝔽)
  /-- The orthogonality/containment condition -/
  contains : C_Z ≤ C_X

/-- The number of logical qubits encoded by a CSS code, equal to dim(C_X / C_Z). -/
def CSSCode.logicalQubits {𝔽 : Type*} [Field 𝔽] {n : ℕ} (C : CSSCode 𝔽 n) : ℕ :=
  finrank 𝔽 (C.C_X ⧸ C.C_Z.comap C.C_X.subtype)

/-! ## Chain Complex CSS Construction -/

/-- Data for a 3-term chain complex V₂ →[∂₂] V₁ →[∂₁] V₀ over a field 𝔽,
    where the chain condition ∂₁ ∘ ∂₂ = 0 holds. -/
structure ChainComplex3 (𝔽 : Type*) [Field 𝔽] where
  n : ℕ
  m : ℕ
  p : ℕ
  d2 : (Fin m → 𝔽) →ₗ[𝔽] (Fin n → 𝔽)
  d1 : (Fin n → 𝔽) →ₗ[𝔽] (Fin p → 𝔽)
  chain_condition : d1.comp d2 = 0

/-- The space of 1-cycles: ker(∂₁) -/
def ChainComplex3.cycles {𝔽 : Type*} [Field 𝔽] (K : ChainComplex3 𝔽) :
    Submodule 𝔽 (Fin K.n → 𝔽) :=
  LinearMap.ker K.d1

/-- The space of 1-boundaries: range(∂₂) -/
def ChainComplex3.boundaries {𝔽 : Type*} [Field 𝔽] (K : ChainComplex3 𝔽) :
    Submodule 𝔽 (Fin K.n → 𝔽) :=
  LinearMap.range K.d2

/-
**Fundamental lemma**: In a chain complex, boundaries are contained in cycles.
    This is the algebraic consequence of ∂₁ ∘ ∂₂ = 0.
-/
theorem ChainComplex3.boundaries_le_cycles {𝔽 : Type*} [Field 𝔽]
    (K : ChainComplex3 𝔽) : K.boundaries ≤ K.cycles := by
  intro x;
  rintro ⟨ y, rfl ⟩ ; exact LinearMap.congr_fun K.chain_condition y

/-- Construct a CSS code from a 3-term chain complex.
    C_X = ker(∂₁) and C_Z = range(∂₂). -/
def ChainComplex3.toCSSCode {𝔽 : Type*} [Field 𝔽] (K : ChainComplex3 𝔽) :
    CSSCode 𝔽 K.n where
  C_X := K.cycles
  C_Z := K.boundaries
  contains := K.boundaries_le_cycles

/-- The first homology H₁ = ker(∂₁)/im(∂₂). -/
abbrev ChainComplex3.H1 {𝔽 : Type*} [Field 𝔽] (K : ChainComplex3 𝔽) :=
  K.cycles ⧸ K.boundaries.comap K.cycles.subtype

/-- The first Betti number β₁ = dim(H₁). -/
def ChainComplex3.betti1 {𝔽 : Type*} [Field 𝔽] (K : ChainComplex3 𝔽) : ℕ :=
  finrank 𝔽 K.H1

/-! ## Main Theorems -/

/-
**Theorem 1 (Homological Dimension Theorem)**: The number of logical qubits
    encoded by the CSS code derived from a chain complex equals the first Betti
    number β₁ = dim(H₁). This is the fundamental bridge between quantum error
    correction and algebraic topology.
-/
theorem css_logical_qubits_eq_betti {𝔽 : Type*} [Field 𝔽]
    (K : ChainComplex3 𝔽) :
    K.toCSSCode.logicalQubits = K.betti1 := by
  rfl

/-
**Theorem 2 (CSS Dimension Formula)**: For a CSS code arising from a chain complex,
    the Betti number satisfies β₁ + dim(boundaries) = dim(cycles).
    This is the quantum rank-nullity theorem.
-/
theorem css_dimension_formula {𝔽 : Type*} [Field 𝔽]
    (K : ChainComplex3 𝔽) [FiniteDimensional 𝔽 (Fin K.n → 𝔽)] :
    K.betti1 + finrank 𝔽 (K.boundaries.comap K.cycles.subtype) = finrank 𝔽 K.cycles := by
  convert Submodule.finrank_quotient_add_finrank ( comap K.cycles.subtype K.boundaries ) using 1

/-
**Theorem 3 (Rank-Nullity for Chain Complex)**: dim(cycles) + dim(im ∂₁) = n.
-/
theorem rank_nullity_chain {𝔽 : Type*} [Field 𝔽]
    (K : ChainComplex3 𝔽) [FiniteDimensional 𝔽 (Fin K.n → 𝔽)] :
    finrank 𝔽 K.cycles + finrank 𝔽 (LinearMap.range K.d1) = finrank 𝔽 (Fin K.n → 𝔽) := by
  rw [ ← LinearMap.finrank_range_add_finrank_ker K.d1 ];
  exact add_comm _ _

/-! ## Hamming Weight and CSS Distance -/

/-- The Hamming weight of a vector in 𝔽^n: the number of nonzero coordinates. -/
def hammingWeight {𝔽 : Type*} [DecidableEq 𝔽] [Zero 𝔽] {n : ℕ}
    (v : Fin n → 𝔽) : ℕ :=
  Finset.card (Finset.filter (fun i => v i ≠ 0) Finset.univ)

/-
Hamming weight is zero iff the vector is zero.
-/
theorem hammingWeight_eq_zero_iff {𝔽 : Type*} [DecidableEq 𝔽] [Zero 𝔽]
    {n : ℕ} (v : Fin n → 𝔽) :
    hammingWeight v = 0 ↔ v = 0 := by
  unfold hammingWeight;
  simp +decide [ funext_iff ]

/-
Hamming weight satisfies the triangle inequality.
-/
theorem hammingWeight_add_le {𝔽 : Type*} [DecidableEq 𝔽] [AddGroup 𝔽]
    {n : ℕ} (v w : Fin n → 𝔽) :
    hammingWeight (v + w) ≤ hammingWeight v + hammingWeight w := by
  unfold hammingWeight;
  rw [ ← Finset.card_union_add_card_inter ];
  exact le_add_right ( Finset.card_mono fun i hi => by by_cases hi' : v i = 0 <;> aesop )

/-! ## CSS Duality -/

/-
When C_X = C_Z (a self-dual CSS code), the code encodes 0 logical qubits.
-/
theorem css_self_dual_zero_qubits {𝔽 : Type*} [Field 𝔽] {n : ℕ}
    (C : CSSCode 𝔽 n) (h : C.C_X = C.C_Z) :
    C.logicalQubits = 0 := by
  unfold CSSCode.logicalQubits;
  rw [ show comap C.C_X.subtype C.C_Z = ⊤ from _ ];
  · simp +decide [ finrank_eq_zero_iff ];
    exact fun x => ⟨ 1, one_ne_zero, Or.inr <| Subsingleton.elim _ _ ⟩;
  · aesop

/-! ## CSS Code from Submodule Pair -/

/-
**Theorem 4 (Logical Qubit Additivity)**: For nested CSS codes
    C_Z ≤ C_mid ≤ C_X, the logical qubits decompose:
    dim(C_X/C_Z) = dim(C_X/C_mid) + dim(C_mid/C_Z).
    This is the quantum analogue of the third isomorphism theorem.
-/
theorem css_logical_qubit_additivity {𝔽 : Type*} [Field 𝔽] {n : ℕ}
    (C_X C_mid C_Z : Submodule 𝔽 (Fin n → 𝔽))
    (h1 : C_Z ≤ C_mid) (h2 : C_mid ≤ C_X)
    [FiniteDimensional 𝔽 (Fin n → 𝔽)] :
    finrank 𝔽 (C_X ⧸ C_Z.comap C_X.subtype) =
    finrank 𝔽 (C_X ⧸ C_mid.comap C_X.subtype) +
    finrank 𝔽 (C_mid ⧸ C_Z.comap C_mid.subtype) := by
  -- Apply the rank-nullity theorem to the quotient spaces.
  have h_rank_nullity : ∀ (V : Submodule 𝔽 (Fin n → 𝔽)) (W : Submodule 𝔽 V), (Module.finrank 𝔽 (V ⧸ W)) = (Module.finrank 𝔽 V) - (Module.finrank 𝔽 W) := by
    intro V W; rw [ Nat.sub_eq_of_eq_add ] ; have := Submodule.finrank_quotient_add_finrank W; aesop;
  rw [ h_rank_nullity, h_rank_nullity, h_rank_nullity, tsub_add_tsub_comm ];
  · rw [ ← Submodule.finrank_map_subtype_eq, ← Submodule.finrank_map_subtype_eq ];
    rw [ show map C_X.subtype ( comap C_X.subtype C_Z ) = C_Z from ?_, show map C_X.subtype ( comap C_X.subtype C_mid ) = C_mid from ?_ ];
    · rw [ show finrank 𝔽 ( comap C_mid.subtype C_Z ) = finrank 𝔽 C_Z from ?_ ];
      · rw [ Nat.add_comm, Nat.add_sub_add_left ];
      · rw [ ← Submodule.finrank_map_subtype_eq ];
        rw [ Submodule.map_comap_subtype ];
        rw [ inf_eq_right.mpr h1 ];
    · simp +decide [ Submodule.map_comap_eq, h2 ];
    · rw [ Submodule.map_comap_subtype ];
      exact inf_eq_right.mpr ( h1.trans h2 );
  · exact Submodule.finrank_le _;
  · exact Submodule.finrank_le _

/-! ## HQECC Structure -/

/-- A Homological Quantum Error-Correcting Code (HQECC) packages a chain complex
    with its derived CSS code and records that the logical dimension equals β₁. -/
structure HQECC (𝔽 : Type*) [Field 𝔽] where
  complex : ChainComplex3 𝔽
  code : CSSCode 𝔽 complex.n
  code_eq : code = complex.toCSSCode

/-- Construct an HQECC fro
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Close Proofs: ReLU decision boundaries via tropical geometry

## Synthesis

The catalog already contained the *algebraic* half of the Zhang–Naitzat–Lim
correspondence in `MachineLearning.TropicalReLUBridge`: every one-hidden-layer
ReLU network output is a **tropical rational function** `f = p − q` (a difference
of two tropical/max-plus polynomials), and every tropical polynomial is convex.

This cycle adds the **analytic and convex-geometric** half in the new file
`MachineLearning.TropicalReLUBoundary`, which `import`s and builds directly on
the bridge file (reusing `affEval`, `IsTropPoly`, `IsTropRational`, `relu`,
`reluNet`, `decisionBoundary`, and the closure lemmas `IsTropPoly.add`,
`IsTropPoly.relu`, `IsTropPoly.convexOn`, and `reluNet_isTropRational`). The new
results are:

* **Continuity**: `affEval_continuous → IsTropPoly.continuous →
  IsTropRational.continuous`. The whole tropical-rational class is continuous.
* **Closed decision boundaries**: `IsTropRational.isClosed_decisionBoundary` —
  for *any* ReLU classifier the locus `{x | f x = 0}` is topologically closed,
  because it is `f ⁻¹' {0}` for a continuous `f`.
* **DC structure**: `IsTropRational.differenceOfConvex` and its specialization
  `reluNet_differenceOfConvex` show every ReLU network is a *difference of
  convex functions*, the exact object class of DC programming.
* **Vector-space closure**: `IsTropRational.neg`, `IsTropRational.add` show the
  DC/tropical-rational class is closed under negation and addition.
* **Adversarial frontier**: `exists_tropRational_not_convexOn` exhibits the
  explicit ReLU rational map `x ↦ −ReLU(x)` that is tropical rational but *not*
  convex, pinning down exactly where the base file's convexity theorem stops:
  convexity survives the polynomial level but is destroyed at the rational
  (network) level, while continuity and boundary-closedness survive.

## Results summary

| Theorem | Statement |
|---|---|
| `affEval_continuous` | affine functionals are continuous |
| `IsTropPoly.continuous` | tropical polynomials are continuous |
| `IsTropRational.continuous` | ReLU-network functions are continuous |
| `IsTropRational.isClosed_decisionBoundary` | ReLU decision boundaries are closed |
| `IsTropRational.neg`, `IsTropRational.add` | DC class is a sub-vector-space |
| `IsTropRational.differenceOfConvex`, `reluNet_differenceOfConvex` | ReLU = difference of convex |
| `exists_tropRational_not_convexOn` | convexity is lost at the rational level |

All main results compile with `sorry = 0` and depend only on
`propext`, `Classical.choice`, `Quot.sound`.

## Falsifiable research directions

### 1. The decision boundary has Lebesgue measure zero (it is a tropical hypersurface)

We proved the decision boundary `{x | f x = 0}` of a ReLU classifier is closed.
The natural strengthening is that, for a *generic* tropical-rational `f` (one
whose two polynomial parts are not identically equal on any open set), the
boundary has **Lebesgue meas
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
