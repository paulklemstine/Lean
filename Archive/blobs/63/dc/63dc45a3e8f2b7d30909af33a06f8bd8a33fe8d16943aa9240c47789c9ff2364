                # MATHEMATICAL RESEARCH MISSION: Berggren–Lorentz certificates for lattice reduction in Pythagorean cryptography

                ## Objective / Task Brief:
                Create a team to research this mathematical direction. Brainstorm new hypotheses, run experiments, analyze results, take notes, iterate. Combine all the researchers' findings into clean, verified Lean 4 files, and then brainstorm a list of the next research directions.

                ## Deliverables & Acceptance Criteria:
                1. **Lean 4 Proofs**: Fully verified, compiling Lean 4 files under the appropriate Catalog directory. Main theorems must be fully proved (0 sorries).
                2. **Lab Notes**: Include inline comment blocks (`-- !-- Lab Notes -- !--`) in the Lean files detailing your hypotheses, experimental outcomes, insights, and failure analysis.
                3. **FUTURE_DIRECTIONS.md**: Outlining 3-5 bold, testable mathematical conjectures for follow-up cycles based on your combined findings.

                ## Constraints (Strictly Enforced):
                - **NO prose or documentation articles**: Do NOT output ARTICLE.md, RESEARCH_PAPER.md, python algorithms, HTML widgets, or PACKAGE.json. Focus 100% of your compute on standard Lean 4 code and proofs.

                ## Context & Resources:
                - Domain: Bridges
                - Existing Catalog References: Algebra/BerggrenLorentz/Core.lean, Cryptography/NoetherianCertification.lean, Cryptography/CSIFiShAdvanced.lean

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

@Cryptography/NoetherianCertification.lean
```lean
/-
  # Noetherian Cryptographic Certification

  This file establishes a formal bridge between Noetherian ring theory
  (commutative algebra) and cryptographic protocol certification.

  ## Main Results

  1. **ACC Protocol Termination**: Ascending chains of ideals in Noetherian
     rings stabilize, providing certified termination for key refinement protocols.
  2. **Finitely Generated Key Certification**: Every ideal in a Noetherian ring
     admits a finite generating set, enabling bounded-size key certificates.
  3. **Quotient Homomorphic Correctness**: The quotient map R → R/I preserves
     ring operations, certifying homomorphic encryption correctness.
  4. **Noetherian Quotient Inheritance**: Quotients of Noetherian rings remain
     Noetherian, enabling recursive protocol composition.
  5. **Kernel-Ideal Correspondence**: The kernel of the quotient map equals
     the defining ideal, establishing perfect decryption.

  Bridge: connects commutative algebra (Noetherian rings, ACC, ideal theory)
  to post-quantum cryptography (lattice key generation, FHE correctness,
  protocol termination guarantees).
-/

import Mathlib

/-! ## Section 1: Core Structures for Cryptographic Certification -/

namespace NoetherianCrypto

/-- A Noetherian certification protocol: an ascending chain of ideals
    modeling iterative key refinement in lattice-based cryptography.
    The ACC guarantees termination of such protocols.

    Bridge: connects ascending chain conditions to post-quantum
    protocol termination guarantees. -/
structure NoetherianCertProtocol (R : Type*) [CommRing R] where
  /-- The ascending chain of ideals representing refinement stages -/
  chain : ℕ →o Submodule R R
  /-- Protocol identifier for certification tracking -/
  protocol_id : ℕ

/-- A homomorphic encryption certificate: witnesses that the quotient map
    R → R/I preserves ring operations, enabling verified computation
    on encrypted data. Critical for FHE (fully homomorphic encryption)
    schemes where I is the noise ideal.

    Bridge: connects ring quotients to homomorphic encryption correctness. -/
structure HomomorphicCertificate (R : Type*) [CommRing R] (I : Ideal R) where
  /-- The quotient map preserves addition -/
  preserves_add : ∀ x y : R,
    Ideal.Quotient.mk I (x + y) = Ideal.Quotient.mk I x + Ideal.Quotient.mk I y
  /-- The quotient map preserves multiplication -/
  preserves_mul : ∀ x y : R,
    Ideal.Quotient.mk I (x * y) = Ideal.Quotient.mk I x * Ideal.Quotient.mk I y
  /-- The quotient map preserves the multiplicative identity -/
  preserves_one : Ideal.Quotient.mk I (1 : R) = 1

/-- A certified key ideal with an explicit finite generating set.
    This is the algebraic certificate for post-quantum key generation
-- ... (truncated, full file has 703 lines)
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


### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


                ## RESEARCH CORE METHODOLOGY:
1. **Catalog Leverage**: Examine existing catalog theorems carefully. Your theorems should extend, generalize, or connect catalog results.
2. **Pure Math Focus**: Focus 100% of your compute on standard Lean 4 definitions, lemmas, and theorems. Prove non-trivial math that represents genuine progress.
3. **Falsifiable Conjectures**: Formulate precise conjectures in FUTURE_DIRECTIONS.md to guide future research cycles.

