/-
# Tropical Valuations: The Bridge Between Number Theory and Tropical Geometry

This file establishes the fundamental connection between discrete valuations
(especially the p-adic valuation) and the tropical semiring. This bridge is
the foundation of the tropical approach to the Langlands program.

The key insight: a discrete valuation v on a ring R naturally gives a
semiring homomorphism from R to the tropical semiring Tropical(ℕ∞).
Under this map:
- Classical multiplication → tropical multiplication (= classical addition of valuations)
- The ultrametric inequality v(x+y) ≥ min(v(x), v(y)) becomes tropical super-additivity

This valuation-tropicalization bridge is what allows p-adic representation theory
to be studied through tropical and combinatorial methods.

## Main Results

- `multiplicity_tropical_mul`: v_p(ab) = v_p(a) ⊙ v_p(b) (multiplicativity)
- `multiplicity_tropical_add_le`: v_p(a+b) ≥ v_p(a) ⊕ v_p(b) (ultrametric)
- `tropical_valuation_preserves_one`: v_p(1) = 1 in tropical
- `tropical_valuation_zero`: v_p(0) = 0 in tropical (= ∞)
-/

import Mathlib

set_option maxHeartbeats 800000

namespace TropicalLanglands

/-! ## Section 1: The p-adic Valuation as a Tropical Morphism -/

/-- The tropical valuation map: sends a natural number to its p-adic
multiplicity, viewed as an element of the tropical semiring.
This is the fundamental bridge between number theory and tropical geometry. -/
noncomputable def tropVal (p : ℕ) (n : ℕ) : Tropical (WithTop ℕ) :=
  Tropical.trop (emultiplicity p n)

/-- The tropical valuation of 0 is the tropical zero (= ⊤ = infinity).
This corresponds to the convention that v(0) = ∞. -/
theorem tropVal_zero (p : ℕ) : tropVal p 0 = 0 := by
  simp [tropVal, emultiplicity_zero]

/-- The tropical valuation of 1 is the tropical one (= 0).
This corresponds to v(1) = 0 for any valuation. -/
theorem tropVal_one {p : ℕ} (hp : Nat.Prime p) : tropVal p 1 = 1 := by
  simp [tropVal, hp.emultiplicity_one]

/-
**Multiplicativity of the tropical valuation**:
`v_p(a * b) = v_p(a) ⊙ v_p(b)` in the tropical semiring.

Since tropical multiplication is classical addition, this says
`emultiplicity p (a * b) = emultiplicity p a + emultiplicity p b`,
which is the fundamental property of the p-adic valuation.

This is the key property that makes the valuation a "semiring homomorphism"
to the tropical semiring — it converts multiplicative structure to
tropical-multiplicative (= classically additive) structure.
-/
theorem tropVal_mul {p : ℕ} (hp : Nat.Prime p) (a b : ℕ) :
    tropVal p (a * b) = tropVal p a * tropVal p b := by
      -- By definition of emultiplicity, we know that emultiplicity p (a * b) = emultiplicity p a + emultiplicity p b.
      have h_emultiplicity : emultiplicity p (a * b) = emultiplicity p a + emultiplicity p b := by
        exact?;
      exact congr_arg _ h_emultiplicity

/-
**Ultrametric inequality in tropical form**:
For prime p and nonzero a, b with a + b ≠ 0:
`v_p(a + b) ≥ min(v_p(a), v_p(b))` in the underlying order.

In tropical terms, this means `v_p(a+b) ≤ v_p(a) ⊕ v_p(b)` in the
tropical order (where ≤ in tropical = ≥ in underlying, since tropical
addition = min). This is the ultrametric property.

This property is what makes p-adic analysis "non-archimedean" and is
the source of the rigid/combinatorial geometry of p-adic spaces.
-/
theorem tropVal_add_le {p : ℕ} (hp : Nat.Prime p) (a b : ℕ)
    (ha : a ≠ 0) (hb : b ≠ 0) :
    min (emultiplicity p a) (emultiplicity p b) ≤ emultiplicity p (a + b) := by
      exact?

/-! ## Section 2: Tropicalization of Integer Sequences

The tropical valuation can be applied to sequences of integers,
giving tropical sequences. The behavior of these tropical sequences
encodes the p-adic analytic properties of the original sequences.
-/

/-
The tropical valuation of a prime power p^k is k.
This is the simplest non-trivial case.
-/
theorem tropVal_prime_pow {p : ℕ} (hp : Nat.Prime p) (k : ℕ) :
    tropVal p (p ^ k) = Tropical.trop (k : WithTop ℕ) := by
      unfold tropVal;
      simp +decide [ hp.prime, hp.emultiplicity_pow_self ]

/-
The tropical valuation of a prime is 1 (= tropical trop 1).
-/
theorem tropVal_prime {p : ℕ} (hp : Nat.Prime p) :
    tropVal p p = Tropical.trop (1 : WithTop ℕ) := by
      convert tropVal_prime_pow hp 1 ; aesop

/-! ## Section 3: Tropical Valuation and the Weyl Group

For GL_n, the Weyl group is the symmetric group S_n, which acts on
n-tuples of valuations by permutation. The Satake parameters of an
unramified representation are (up to Weyl group action) the tropical
valuations of the eigenvalues of the Frobenius.

We formalize the S_2 case (for GL_2) explicitly.
-/

/-- The Weyl group for GL_2 is S_2 = ℤ/2ℤ, acting by swapping
the two Satake parameters. The tropical Satake parameters are
a pair (v₁, v₂) of elements of the tropical semiring.

The key invariants under this swap are:
- The tropical sum: v₁ ⊕ v₂ = min(v₁, v₂)
- The tropical product: v₁ ⊙ v₂ = v₁ + v₂ (in underlying order) -/
theorem tropical_weyl_gl2_invariants {R : Type*} [LinearOrder R] [AddCommMonoid R]
    [CovariantClass R R (· + ·) (· ≤ ·)]
    [CovariantClass R R (Function.swap (· + ·)) (· ≤ ·)]
    (v₁ v₂ : Tropical R) :
    -- Tropical sum is Weyl-invariant
    v₁ + v₂ = v₂ + v₁ ∧
    -- Tropical product is Weyl-invariant
    v₁ * v₂ = v₂ * v₁ := by
  exact ⟨add_comm v₁ v₂, mul_comm v₁ v₂⟩

/-
The tropical Satake parameters (tropical sum and product) determine
the unordered pair {v₁, v₂}. This is the tropical analog of the
fact that symmetric polynomials determine roots up to permutation.
-/
theorem tropical_satake_determines_pair {R : Type*} [LinearOrder R]
    [AddCommMonoid R]
    [CovariantClass R R (· + ·) (· ≤ ·)]
    [CovariantClass R R (Function.swap (· + ·)) (· ≤ ·)]
    [CovariantClass R R (· + ·) (· < ·)]
    (v₁ v₂ w₁ w₂ : Tropical R)
    (hsum : v₁ + v₂ = w₁ + w₂)
    (hprod : v₁ * v₂ = w₁ * w₂)
    (hle1 : Tropical.untrop v₁ ≤ Tropical.untrop v₂)
    (hle2 : Tropical.untrop w₁ ≤ Tropical.untrop w₂) :
    v₁ = w₁ ∧ v₂ = w₂ := by
      -- From hsum: min(untrop v₁, untrop v₂) = min(untrop w₁, untrop w₂). Since untrop v₁ ≤ untrop v₂ and untrop w₁ ≤ untrop w₂, we have untrop v₁ = untrop w₁.
      have h_untrop_eq : Tropical.untrop v₁ = Tropical.untrop w₁ := by
        simp_all +decide [ Tropical.trop_add_def ];
      rw [ ← Tropical.untrop_inj_iff ] at *;
      -- Since $v₁ = w₁$, we can substitute $w₁$ for $v₁$ in the equation $v₁ + v₂ = w₁ + w₂$.
      have h_subst : Tropical.untrop v₂ = Tropical.untrop w₂ := by
        by_contra h_contra;
        cases lt_or_gt_of_ne h_contra <;> simp_all +decide [ add_comm ];
        · exact absurd hprod ( ne_of_lt ( by simpa [ add_comm ] using add_lt_add_right ( show Tropical.untrop v₂ < Tropical.untrop w₂ from by assumption ) ( Tropical.untrop w₁ ) ) );
        · rename_i h;
          exact absurd hprod ( ne_of_gt ( by simpa [ add_comm ] using add_lt_add_right ( show Tropical.untrop w₂ < Tropical.untrop v₂ from h ) ( Tropical.untrop w₁ ) ) );
      exact ⟨ h_untrop_eq, by rw [ ← Tropical.untrop_inj_iff, h_subst ] ⟩

end TropicalLanglands