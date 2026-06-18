                # MATHEMATICAL RESEARCH MISSION: Berggren Lattice Orbit Classification for Post-Quantum Key Exchange

                ## Objective / Task Brief:
                Create a team to research this mathematical direction. Brainstorm new hypotheses, run experiments, analyze results, take notes, iterate. Combine all the researchers' findings into clean, verified Lean 4 files, and then brainstorm a list of the next research directions.

                ## Deliverables & Acceptance Criteria:
                1. **Lean 4 Proofs**: Fully verified, compiling Lean 4 files under the appropriate Catalog directory. Main theorems must be fully proved (0 sorries).
                2. **Lab Notes**: Include inline comment blocks (`-- !-- Lab Notes -- !--`) in the Lean files detailing your hypotheses, experimental outcomes, insights, and failure analysis.
                3. **FUTURE_DIRECTIONS.md**: Outlining 3-5 bold, testable mathematical conjectures for follow-up cycles based on your combined findings.

                ## Constraints (Strictly Enforced):
                - **NO prose or documentation articles**: Do NOT output ARTICLE.md, RESEARCH_PAPER.md, python algorithms, HTML widgets, or PACKAGE.json. Focus 100% of your compute on standard Lean 4 code and proofs.

                ## Context & Resources:
                - Domain: Cryptography
                - Existing Catalog References: Algebra/BerggrenLorentz/Core.lean, Cryptography/CSIFiShAdvanced.lean, EML/LatticeTreeCorrespondence.lean, Pythagorean/BerggrenTree.lean

### Catalog Context
@Algebra/BerggrenLorentz/Core.lean
```lean
import Mathlib

/-!
# Berggren-Lorentz Monoid: Discrete Lorentz Symmetry of Pythagorean Triples

This file develops the theory of the **Berggren monoid** — the three-generator
submonoid of GL₃(ℤ) that acts on primitive Pythagorean triples via the
Berggren tree. We establish:

1. All three generators preserve the Lorentzian quadratic form Q(a,b,c) = a²+b²-c²,
   placing them in the integer orthogonal group O(2,1;ℤ).
2. Determinant computations showing orientation structure (two proper, one improper).
3. Pythagorean preservation: children of Pythagorean triples are Pythagorean.
4. Hypotenuse growth bounds giving O(log c) tree depth.
5. Trace structure, inverse matrices, and non-commutativity of generators.
6. Quadratic form identities and bilinear form theory.

## Bridge: Number Theory (Pythagorean triples) ↔ Physics (Lorentz group O(2,1;ℤ))
↔ Cryptography (monoid action hardness) ↔ ML (Lipschitz bounds via matrix norms)
-/

set_option maxHeartbeats 1600000

namespace BerggrenLorentz

/-! ## Section 1: Core Definitions -/

/-- The Lorentzian quadratic form Q(a,b,c) = a² + b² - c² on ℤ³.
    The light cone Q = 0 parametrizes Pythagorean triples.
    Bridge: connects number theory to physics (Minkowski metric). -/
def lorentzForm (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- Scalar version of the Lorentz form for convenience. -/
def lorentzQ (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2

/-- A triple (a,b,c) is Pythagorean iff it lies on the light cone Q = 0. -/
def IsPythag (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- The Berggren matrix A (first generator). -/
def matA : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- The Berggren matrix B (second generator). -/
def matB : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- The Berggren matrix C (third generator). -/
def matC : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The Lorentz metric matrix Q_L = diag(1, 1, -1). -/
def metricQ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- Berggren child A: explicit coordinate formulas. -/
def childA (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- Berggren child B: explicit coordinate formulas. -/
def childB (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Berggren child C: explicit coordinate formulas. -/
def childC (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- A word in the Berggren monoid: a finite sequence of generator indices. -/
-- ... (truncated, full file has 505 lines)
```

@Cryptography/CSIFiShAdvanced.lean
```lean
/-
  # Advanced CSI-FiSh: Class Group Actions, Security Reductions, and Isogeny Graphs

  This module formalizes:
  1. **IsogenyDegreeMap**: Novel structure for isogeny degree multiplicativity
  2. **Multi-Party CSIDH**: n-party key exchange with permutation invariance
  3. **Security Reductions**: Collision resistance, GAIP ↔ one-wayness
  4. **Orbit-Stabilizer**: Free action ↔ trivial stabilizer
  5. **CSI-FiSh**: 2-special soundness and completeness
  6. **Cayley Graph**: Regularity of isogeny graphs

  ## Catalog References
  - `Catalog/Cryptography/CSIFiSh.lean`: Base formalization
  - `Catalog/Cryptography/EllipticCurve/Basic.lean`: Elliptic curve arithmetic
-/
import Mathlib

open Finset Function BigOperators

namespace Cryptography.CSIFiShAdvanced

/-! ## Abstract Group Action -/

structure CryptoGroupAction (G : Type*) (X : Type*) [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X] where
  act : G → X → X
  act_one : ∀ x : X, act 1 x = x
  act_mul : ∀ (g h : G) (x : X), act (g * h) x = act g (act h x)

structure FreeTrans (G : Type*) (X : Type*) [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X] extends CryptoGroupAction G X where
  transitive : ∀ x y : X, ∃ g : G, act g x = y
  free : ∀ (g : G) (x : X), act g x = x → g = 1

namespace CryptoGroupAction

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (A : CryptoGroupAction G X)

theorem act_inv_cancel (g : G) (x : X) : A.act g⁻¹ (A.act g x) = x := by
  have h := A.act_mul g⁻¹ g x; rw [inv_mul_cancel, A.act_one] at h; exact h.symm

theorem act_inv_cancel' (g : G) (x : X) : A.act g (A.act g⁻¹ x) = x := by
  have h := A.act_mul g g⁻¹ x; rw [mul_inv_cancel, A.act_one] at h; exact h.symm

def actEquiv (g : G) : X ≃ X where
  toFun := A.act g
  invFun := A.act g⁻¹
  left_inv := A.act_inv_cancel g
  right_inv := A.act_inv_cancel' g

theorem act_injective (g : G) : Injective (A.act g) := (A.actEquiv g).injective
theorem act_surjective (g : G) : Surjective (A.act g) := (A.actEquiv g).surjective

end CryptoGroupAction

namespace FreeTrans

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
-- ... (truncated, full file has 662 lines)
```

@EML/LatticeTreeCorrespondence.lean
```lean
import Mathlib

/-! # CatalogBuild.Pythagorean.TreeFactoring.LatticeTreeCorrespondence

Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 48
-/

/-- Berggren 2×2 matrix M₁ ∈ SL(2,ℤ) -/
def berggren_M₁' : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]

/-- Berggren 2×2 matrix M₃ ∈ SL(2,ℤ) -/
def berggren_M₃' : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]

/-- M₁ inverse -/
def berggren_M₁_inv' : Matrix (Fin 2) (Fin 2) ℤ := !![0, 1; -1, 2]

/-- M₃ inverse -/
def berggren_M₃_inv' : Matrix (Fin 2) (Fin 2) ℤ := !![1, -2; 0, 1]

/-- [Section: # CatalogBuild.Pythagorean.TreeFactoring.LatticeTreeCorrespondence
Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 48] -/
theorem berggren_M₁'_det : Matrix.det berggren_M₁' = 1 := by
  simp [berggren_M₁', Matrix.det_fin_two]

/-- [Section: # CatalogBuild.Pythagorean.TreeFactoring.LatticeTreeCorrespondence
Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 48] -/
theorem berggren_M₃'_det : Matrix.det berggren_M₃' = 1 := by
  simp [berggren_M₃', Matrix.det_fin_two]

theorem berggren_M₁'_mul_inv :
    berggren_M₁' * berggren_M₁_inv' = (1 : Matrix (Fin 2) (Fin 2) ℤ) := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [berggren_M₁', berggren_M₁_inv', Matrix.mul_apply, Fin.sum_univ_two]

theorem berggren_M₃'_mul_inv :
    berggren_M₃' * berggren_M₃_inv' = (1 : Matrix (Fin 2) (Fin 2) ℤ) := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [berggren_M₃', berggren_M₃_inv', Matrix.mul_apply, Fin.sum_univ_two]

/-- **Lattice-Tree Correspondence, Part 1**: M₃⁻¹ is the subtraction step.
M₃⁻¹ · (m, n) = (m - 2n, n), corresponding to the continued fraction
quotient step in Gauss's algorithm. -/
theorem lattice_tree_correspondence_M₃ (m n : ℤ) :
    berggren_M₃_inv'.mulVec ![m, n] = ![m - 2 * n, n] := by
  ext i; fin_cases i <;>
    simp [berggren_M₃_inv', Matrix.mulVec, dotProduct, Fin.sum_univ_two] <;> ring

/-- **Lattice-Tree Correspondence, Part 2**: M₁⁻¹ is the swap step.
M₁⁻¹ · (m, n) = (n, 2n - m), corresponding to the basis exchange
step in Gauss's algorithm. -/
theorem lattice_tree_correspondence_M₁ (m n : ℤ) :
    berggren_M₁_inv'.mulVec ![m, n] = ![n, 2 * n - m] := by
  ext i; fin_cases i <;>
    simp [berggren_M₁_inv', Matrix.mulVec, dotProduct, Fin.sum_univ_two] <;> ring
-- ... (truncated, full file has 289 lines)
```


### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


                ## RESEARCH CORE METHODOLOGY:
1. **Catalog Leverage**: Examine existing catalog theorems carefully. Your theorems should extend, generalize, or connect catalog results.
2. **Pure Math Focus**: Focus 100% of your compute on standard Lean 4 definitions, lemmas, and theorems. Prove non-trivial math that represents genuine progress.
3. **Falsifiable Conjectures**: Formulate precise conjectures in FUTURE_DIRECTIONS.md to guide future research cycles.

### Perpetual Scientific Iteration (do not stop at first synthesis)
When the research team comes together with results, do not stop. Treat the synthesized findings as the next problem statement and immediately run the full scientific-method loop again: hypothesize, experiment, review, synthesize, critique. Repeat this cycle continuously within the available context window, refining, deepening, and cross-checking until forced to emit output. Use Aristotle to its fullest.

