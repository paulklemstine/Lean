
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   Reference the specific theorems proved in Phase A using @file references.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work,
   references to catalog results. Use @file references for theorems.
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
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
  ],
  "visualizations": [
    {"name": "descriptive_name", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Interactive Widget Title", "description": "What users can explore", "html": "<!DOCTYPE html><html>...</html>"}
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
Use the @file references above to point readers to specific theorems.


## Concept

**Title**: Formal obstruction theory for EML-solvability of linear
**Domain**: Bridges
**Mathematical framing**: # Future Directions: EML Differential Equations

## Synthesis

This cycle established a formal obstruction theory for EML-solvability of linear ODEs, centered on Airy's equation y″ = xy as the prototypical barrier. We proved four independent obstruction arguments (polynomial degree, Riccati degree parity, Wronskian conservation/SL₂ invariance, and growth rate analysis) and developed foundational infrastructure including ODE uniqueness for second-order equations with continuous coefficients.

The most promising cross-domain connection is between the **differential Galois group** formalized here and the **algebraic Galois theory** already present in the Catalog (`Bridges/GaloisNeuralCorrespondence.lean`, `Algebra/ProofSpectra/Core.lean`). Both theories share the same core mechanism — group-theoretic obstructions to solvability — but operate in different categories (differential fields vs. number fields). Bridging these formally would unify a substantial portion of modern algebra.

The cycle's Wronskian theory and ODE uniqueness results are independently valuable and reusable. The growth rate classification (`EMLGrowthClass`) provides a framework for distinguishing solution types that could be applied to broad classes of ODEs beyond Airy.

---

### Direction 1: Formal Stokes Phenomenon for Airy's Equation

**Conjecture**: The asymptotic expansion of Ai(x) as x → +∞ (along the positive real axis) and as x → −∞ involve different linear combinations of formal WKB solutions, and the transition matrices between these asymptotic regimes are elements of the Stokes group, which is a unipotent subgroup of SL₂(ℂ). Formally: the monodromy representation of Airy's equation factors through the wild fundamental group, and the Stokes multipliers can be computed exactly as specific constants involving Γ(1/3) and Γ(2/3).

**Test**: Compute Stokes multipliers numerically by integrating Airy's equation along paths crossing Stokes lines (at angles 0, 2π/3, 4π/3) and verify they match the predicted values. Formally, prove that the connection matrix between the sectors arg(x) ∈ (−π/3, π/3) and arg(x) ∈ (π/3, π) has the form [[1, s], [0, 1]] for a specific constant s.

**Impact**: This would be the first formalization of the Stokes phenomenon in any proof assistant. The Stokes phenomenon is fundamental to asymptotic analysis, quantum mechanics (WKB approximation), and resurgence theory. A formal treatment would open the door to verified asymptotics.

**Catalog References**: `EML/EMLDiffEq.lean` (Wronskian theory, Abel's identity), `EML/EMLDiffGalois.lean` (SL₂ Galois invariance)

**Proof Strategy**: (1) Define formal WKB solutions as asymptotic series. (2) Prove existence of actual solutions with prescribed asymptotics in each sector using Borel summation. (3) Compute the connection matrices between sectors. (4) Show these matrices are unipotent elements of SL₂.

**Domain Bridges**: Differential Galois Theory ↔ Asymptotic Analysis ↔ Quantum Mechanics

**Lineage**: Builds on this cycle's Wronskian conservation and SL₂ invariance results.

**Ambition**: grand_challenge

---

### Direction 2: Kovacic Algorithm — Full Decidability Proof

**Conjecture**: Kovacic's algorithm, when formalized as a decision procedure on rational functions r(x) = P(x)/Q(x) with integer coefficients, terminates in time polynomial in the total degree of P and Q, and correctly decides Liouvillian solvability of y″ = r(x)y.

**Test**: Implement the full three-case algorithm in Lean 4 with a verified termination proof. Test on a battery of equations: (a) y″ = x²y (Liouvillian: y = exp(x³/3)), (b) y″ = xy (not Liouvillian: Airy), (c) y″ = (1/x²)y (Euler equation: Liouvillian), (d) y″ = (x²+1)y (Parabolic cylinder: Liouvillian via Hermite functions?). Verify each decision against known results.

**Impact**: A formally verified Kovacic algorithm would be the first certified decision procedure for Liouvillian solvability. This has applications in computer algebra systems (Maple, Mathematica) where Kovacic's algorithm is implemented but not verified.

**Catalog References**: `EML/EMLDiffGalois.lean` (Riccati obstruction, polynomial derivative algebra), `EML/EMLDiffEq.lean` (no_polynomial_solves_airy)

**Proof Strategy**: (1) Formalize rational functions as a computable type. (2) Implement pole order analysis. (3) Formalize the three cases as finite searches over candidate exponents. (4) Prove termination by bounding the search space. (5) Prove soundness by showing each case correctly identifies solutions.

**Domain Bridges**: Computer Algebra ↔ Differential Galois Theory ↔ Computation

**Lineage**: Builds on this cycle's no_polynomial_solves_riccati and kovacic_case1_airy_obstruction.

**Ambition**: grand_challenge

---

### Direction 3: EML Growth Hierarchy — Fractional Exponential Orders

**Conjecture**: Define the *exponential order* of a function f at infinity as ord(f) = inf{α > 0 : f(x) = O(exp(x^α))}. Then: (a) Every EML function has rational exponential order. (b) The Airy function Bi has exponential order exactly 3/2, which is rational but cannot be realized by any EML function. (c) More generally, the exponential orders realizable by solutions of y″ = r(x)y with polynomial r of degree d are exactly {(d+2)/2}, and (d+2)/2 is realizable by an EML function iff d is even.

**Test**: Verify conjecture (c) computationally for d = 0,1,2,...,10 by computing the WKB exponent ∫√r(x)dx and checking its degree. Formally, prove (a) by structural induction on EML expressions and (b) by the growth rate analysis from this cycle.

**Impact**: This would establish a precise numerical invariant distinguishing EML-solvable from EML-unsolvable equations, providing an effective criterion independent of the full Galois group computation.

**Catalog References**: `EML/EMLDiffGalois.lean` (EMLGrowthClass, exp_not_polynomial_growth), `EML/EMLDiffEq.lean` (exp_dominates_polynomial, airy_not_tendsto_zero)

**Proof Strategy**: (1) Define exponential order formally. (2) Prove the WKB approximation: solutions of y″ = r(x)y have exponential order equal to the degree of ∫√r(x)dx. (3) Classify which exponential orders arise from EML expressions. (4) Show the parity obstruction: odd-degree r gives half-integer exponential order, incompatible with EML.

**Domain Bridges**: Asymptotic Analysis ↔ EML Theory ↔ Complex Analysis

**Lineage**: Builds on this cycle's growth rate analysis and polynomial degree obstruction.

**Ambition**: extension

---

### Direction 4: Differential Galois–Algebraic Galois Bridge

**Conjecture**: There exists a formal functor from the category of Picard-Vessiot extensions of ℂ(x) to the category of algebraic groups over ℂ, such that: (a) the image of this functor restricted to constant coefficient equations y^(n) + aₙ₋₁y^(n-1) + ... + a₀y = 0 recovers the classical Galois group of the splitting field of the characteristic polynomial t^n + aₙ₋₁t^(n-1) + ... + a₀; (b) for Fuchsian equations (regular singular points only), the differential Galois group is the Zariski closure of the monodromy group.

**Test**: Verify (a) for specific examples: the equation y″ + y = 0 (Galois group {±1} ≅ ℤ/2, matching the algebraic Galois group of t² + 1 over ℝ). Verify (b) for the Gauss hypergeometric equation with specific parameters where the monodromy group is known.

**Impact**: This would be the first formal bridge between algebraic and differential Galois theory, connecting two of the most powerful obstruction theories in mathematics. It would enable transfer of results from the well-developed algebraic theory to the less-developed differential setting.

**Catalog References**: `Bridges/GaloisNeuralCorrespondence.lean` (prime_degree_divides_galois_order), `Algebra/ProofSpectra/Core.lean` (galois_connection_theory_variety), `EML/EMLDiffGalois.lean` (galois_preserves_wronskian)

**Proof Strategy**: (1) Formalize Picard-Vessiot extensions as differential field extensions with no new constants. (2) Define the differential Galois group as the automorphism group of the extension. (3) For constant-coefficient equations, show the exponential solutions generate a splitting field isomorphic to the algebraic splitting field. (4) For Fuchsian equations, relate analytic continuation to monodromy.

**Domain Bridges**: Algebraic Galois Theory ↔ Differential Galois Theory ↔ Topology (Monodromy)

**Lineage**: Builds on this cycle's SL₂ invariance and Wronskian theory, connecting to the algebraic Galois results in the Catalog.

**Ambition**: grand_challenge

---

### Direction 5: Nonlinear EML ODEs — Painlevé Transcendents

**Conjecture**: The first Painlevé equation y″ = 6y² + x has no EML solutions, and its "nonlinear differential Galois group" (in the sense of Malgrange) is the full symplectomorphism group of the phase space, which is infinite-dimensional.

**Test**: (a) Verify the polynomial obstruction: if y is a polynomial of degree d, then d − 2 = 2d + 1 (from y″ vs 6y² + x), giving d = −3, impossible. (b) Numerically integrate Painlevé I and verify that solutions develop arrays of double poles (the Painlevé property) with specific pole patterns. (c) Check that the pole locations are not expressible as EML functions of the initial conditions.

**Impact**: Painlevé transcendents are the next level of "new transcendental functions" beyond Airy. They arise in random matrix theory, quantum gravity, and integrable systems. A formal obstruction theory would extend our results from linear to nonlinear ODEs.

**Catalog References**: `EML/EMLDiffEq.lean` (no_polynomial_solves_airy — analogous degree argument), `EML/EMLDiffGalois.lean` (no_polynomial_solves_riccati — analogous nonlinear obstruction)

**Proof Strategy**: (1) Prove the polynomial obstruction (straightforward degree argument). (2) Formalize the Painlevé property (movable poles are at worst double). (3) Show the pole distribution contradicts EML structure. (4) Connect to Malgrange's nonlinear differential Galois theory.

**Domain Bridges**: Nonlinear ODEs ↔ Random Matrix Theory ↔ EML Theory

**Lineage**: Extends this cycle's linear obstruction theory to the nonlinear setting.

**Ambition**: extension

Research domain: Bridges
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
# Future Directions: Polynomial Obstruction Theory for ODE Solvability

## What We Proved

This cycle established six formally verified results in `EML/EMLDiffObstruction.lean`:

1. **Degree mismatch lemma** (`degree_second_deriv_lt_degree_X_mul`): For any nonzero polynomial p ∈ ℝ[X], deg(p'') < deg(X·p). This is the atomic building block of all polynomial obstruction arguments.

2. **Airy polynomial obstruction** (`no_poly_solves_airy`): No nonzero polynomial satisfies y'' = X·y.

3. **General degree obstruction** (`no_poly_solves_second_order_pos_deg`): For *any* polynomial coefficient q with deg(q) ≥ 1, the equation y'' = q·y has no nonzero polynomial solution. This is a strictly stronger result than the Airy case.

4. **Wronskian constancy** (`poly_wronskian_derivative_zero`): If f'' = q·f and g'' = q·g in ℝ[X], then W(f,g)' = 0, the polynomial-ring version of Abel's identity.

5. **Riccati obstruction** (`no_poly_solves_riccati_airy`): No polynomial satisfies v' + v² = X, connecting to the Kovacic algorithm's Case 1 analysis.

6. **Generalized Airy family** (`no_poly_solves_gen_airy`): For all n ≥ 1, no nonzero polynomial satisfies y'' = Xⁿ·y.

---

## Direction 1: Rational Function Solutions and the Full Kovacic Case 1

The natural next step beyond polynomial obstruction is to show that no *rational function* r(x) = p(x)/q(x) satisfies the Riccati equation v' + v² = x either. The key insight is that poles of a rational solution of the Riccati equation must be simple (from the v² term dominating v' near a pole), and the residue at each pole must be exactly 1. But near x = ∞, the behavior of v ∼ ±√x is irrational, creating a global obstruction. This is precisely Kovacic's Case 1 obstruction applied to the Airy equation.

**Why now?** Our Riccati polynomial obstruction already handles the pole-free case. The pole analysis requires only rational function degree arithmetic and local Laurent expansion theory, both of which can be formalized using Mathlib's `RatFunc` and `LaurentSeries` types. The general degree obstruction theorem provides the structural template.

**Falsifiable test**: Formalize `RatFunc ℝ` solutions, prove no rational function satisfies v' + v² = X, and verify the result against Kovacic's algorithm output for the Airy equation.

---

## Direction 2: Polynomial Obstruction for Painlevé I

The first Painlevé transcendent y'' = 6y² + x has no polynomial solution by an analogous degree argument: if p has degree d, then deg(p'') = d - 2 but deg(6p² + X) = max(2d, 1). Setting d - 2 = 2d gives d = -2, impossible. The key insight is that the *same* degree-mismatch technique works for nonlinear ODEs, not just linear ones — the nonlinear term y² creates an even more severe degree gap than the linear term q·y.

**Why now?** Our formalization infrastructure (degree comparison, derivative bounds) transfers directly. The only new ingredient is handling the `max` in degree(f + g) for the nonlinear case. Mathlib's `Polynomial.degree_add_le` pr
```

## Your task

Produce the deliverables listed above. Reference the specific theorems and
results in the Lean code by their @file path and statement. The Lean file is
the source of truth — your prose must accurately explain it.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
