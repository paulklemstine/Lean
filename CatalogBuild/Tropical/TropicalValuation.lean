/-! # CatalogBuild.Tropical.TropicalValuation

Auto-generated from theorem catalog database.
Domain: Tropical
Declarations: 8
-/

import Mathlib

/-- The tropical valuation of 0 is the tropical zero (= ⊤ = infinity).
This corresponds to the convention that v(0) = ∞. -/
theorem tropVal_zero (p : ℕ) : tropVal p 0 = 0 := by
  simp [tropVal, emultiplicity_zero]


/-- The tropical valuation of 1 is the tropical one (= 0).
This corresponds to v(1) = 0 for any valuation. -/
theorem tropVal_one {p : ℕ} (hp : Nat.Prime p) : tropVal p 1 = 1 := by
  simp [tropVal, hp.emultiplicity_one]


/-- [Section: ## Section 1: The p-adic Valuation as a Tropical Morphism] -/
theorem tropVal_mul {p : ℕ} (hp : Nat.Prime p) (a b : ℕ) :
    tropVal p (a * b) = tropVal p a * tropVal p b := by
      -- By definition of emultiplicity, we know that emultiplicity p (a * b) = emultiplicity p a + emultiplicity p b.
      have h_emultiplicity : emultiplicity p (a * b) = emultiplicity p a + emultiplicity p b := by
        exact?;
      exact congr_arg _ h_emultiplicity


theorem tropVal_add_le {p : ℕ} (hp : Nat.Prime p) (a b : ℕ)
    (ha : a ≠ 0) (hb : b ≠ 0) :
    min (emultiplicity p a) (emultiplicity p b) ≤ emultiplicity p (a + b) := by
      exact?


/-- [Section: ## Section 2: Tropicalization of Integer Sequences
The tropical valuation can be applied to sequences of integers,
giving tropical sequences. The behavior of these tropical sequences
encodes the p-adic analytic properties of the original sequences.] -/
theorem tropVal_prime_pow {p : ℕ} (hp : Nat.Prime p) (k : ℕ) :
    tropVal p (p ^ k) = Tropical.trop (k : WithTop ℕ) := by
      unfold tropVal;
      simp +decide [ hp.prime, hp.emultiplicity_pow_self ]


theorem tropVal_prime {p : ℕ} (hp : Nat.Prime p) :
    tropVal p p = Tropical.trop (1 : WithTop ℕ) := by
      convert tropVal_prime_pow hp 1 ; aesop


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


/-- [Section: ## Section 3: Tropical Valuation and the Weyl Group
For GL_n, the Weyl group is the symmetric group S_n, which acts on
n-tuples of valuations by permutation. The Satake parameters of an
unramified representation are (up to Weyl group action) the tropical
valuations of the eigenvalues of the Frobenius.
We formalize the S_2 case (for GL_2) explicitly.] -/
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

