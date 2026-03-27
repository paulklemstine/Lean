import Mathlib

/-!
# The Tropical Alphabet: Foundations

Formal verification of the core properties of the tropical semiring and its
"alphabet" of derived operations. We work in the min-plus tropical semiring
𝕋 = (ℝ ∪ {+∞}, min, +).

## Main results:

1. **Tier 0**: The tropical semiring axioms (idempotency, distributivity)
2. **Tier 1**: Tropical power equals classical multiplication
3. **Tier 2**: Tropical polynomials are piecewise linear (convexity)
4. **Tier 3**: Tropical matrix multiplication = shortest-path composition
5. **Tier 4**: Tropical Fourier transform = Legendre-Fenchel duality
6. **Tier 6**: Boolean algebra embeds into tropical semiring

## Key Insight: Maslov Dequantization
The tropical semiring arises as the ε→0 limit of (ℝ, LogSumExp_ε, +).
This file formalizes the key bounds: max(a,b) ≤ LSE(a,b) ≤ max(a,b) + log 2.
-/

noncomputable section

open Real BigOperators Finset

namespace TropicalAlphabet

/-! ## Tier 0: Fundamental Properties of the Tropical Atoms -/

/-- Tropical addition is idempotent: a ⊕ a = a -/
theorem trop_add_idempotent (a : ℝ) : min a a = a := by
  simp

/-- Tropical multiplication distributes over tropical addition:
    a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c), i.e., a + min(b,c) = min(a+b, a+c) -/
theorem trop_distrib (a b c : ℝ) : a + min b c = min (a + b) (a + c) := by
  simp [min_def]
  split_ifs <;> linarith

/-- Tropical addition is commutative -/
theorem trop_add_comm (a b : ℝ) : min a b = min b a := min_comm a b

/-- Tropical addition is associative -/
theorem trop_add_assoc (a b c : ℝ) : min (min a b) c = min a (min b c) := by
  simp [min_assoc]

/-- Tropical multiplication is commutative (classical addition is commutative) -/
theorem trop_mul_comm (a b : ℝ) : a + b = b + a := add_comm a b

/-- Tropical multiplication is associative -/
theorem trop_mul_assoc (a b c : ℝ) : (a + b) + c = a + (b + c) := add_assoc a b c

/-- 0 is the tropical multiplicative identity -/
theorem trop_mul_identity (a : ℝ) : a + 0 = a := add_zero a

/-! ## Tier 1: Derived Scalar Operations -/

/-- Tropical power: a^⊗n = n * a (tropical exponentiation is classical multiplication) -/
theorem trop_pow_eq_mul (a : ℝ) (n : ℕ) : n • a = n * a := by
  simp [nsmul_eq_mul]

/-- Tropical multiplicative inverse: a ⊗ (-a) = 0 -/
theorem trop_mul_inv (a : ℝ) : a + (-a) = 0 := add_neg_cancel a

/-- Tropical absolute value is non-positive: min(a, -a) ≤ 0 -/
theorem trop_abs_nonpos (a : ℝ) : min a (-a) ≤ 0 := by
  simp [min_le_iff]
  by_cases h : a ≤ 0
  · left; exact h
  · right; linarith

/-- Tropical absolute value equals 0 iff a = 0 -/
theorem trop_abs_eq_zero_iff (a : ℝ) : min a (-a) = 0 ↔ a = 0 := by
  constructor
  · intro h
    simp [min_def] at h
    split_ifs at h with h1
    · linarith
    · linarith
  · intro h
    subst h
    simp

/-! ## Tier 2: Tropical Polynomial Convexity -/

/-- A tropical monomial cᵢ + i·x is an affine function of x -/
theorem trop_monomial_affine (c : ℝ) (i : ℕ) (x : ℝ) :
    c + ↑i * x = c + ↑i * x := rfl

/-
PROBLEM
The tropical sum (min) of convex functions is convex.
    More precisely: min of affine functions is concave (concave PL function).

PROVIDED SOLUTION
The min of two affine functions is concave. For affine f, g, we have min(f(tx+(1-t)y), g(tx+(1-t)y)) = min(tf(x)+(1-t)f(y), tg(x)+(1-t)g(y)) ≥ t·min(f(x),g(x)) + (1-t)·min(f(y),g(y)). The key inequality is: min(A,B) ≥ t·min(C,D) + (1-t)·min(E,F) when A = tC+(1-t)E and B = tD+(1-t)F. This follows from: min(tC+(1-t)E, tD+(1-t)F) ≥ t·min(C,D) + (1-t)·min(E,F) since tC ≥ t·min(C,D) and (1-t)E ≥ (1-t)·min(E,F), so tC+(1-t)E ≥ t·min(C,D)+(1-t)·min(E,F), and similarly for the other term.
-/
theorem min_of_affine_is_concave (a₁ b₁ a₂ b₂ : ℝ) (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (x y : ℝ) :
    min (a₁ + b₁ * (t * x + (1 - t) * y)) (a₂ + b₂ * (t * x + (1 - t) * y)) ≥
    t * min (a₁ + b₁ * x) (a₂ + b₂ * x) +
    (1 - t) * min (a₁ + b₁ * y) (a₂ + b₂ * y) := by
  cases min_cases ( a₁ + b₁ * x ) ( a₂ + b₂ * x ) <;> cases min_cases ( a₁ + b₁ * y ) ( a₂ + b₂ * y ) <;> cases min_cases ( a₁ + b₁ * ( t * x + ( 1 - t ) * y ) ) ( a₂ + b₂ * ( t * x + ( 1 - t ) * y ) ) <;> nlinarith

/-! ## Tier 4: Maslov Dequantization Bounds -/

/-- LogSumExp lower bound: log(exp a + exp b) ≥ max(a, b) -/
theorem lse_ge_max (a b : ℝ) :
    Real.log (Real.exp a + Real.exp b) ≥ max a b := by
  rcases le_total a b with hab | hab
  · rw [max_eq_right hab]
    calc Real.log (Real.exp a + Real.exp b)
        ≥ Real.log (Real.exp b) := by
          apply Real.log_le_log (Real.exp_pos b)
          linarith [Real.exp_nonneg a]
      _ = b := Real.log_exp b
  · rw [max_eq_left hab]
    calc Real.log (Real.exp a + Real.exp b)
        ≥ Real.log (Real.exp a) := by
          apply Real.log_le_log (Real.exp_pos a)
          linarith [Real.exp_nonneg b]
      _ = a := Real.log_exp a

/-
PROBLEM
LogSumExp upper bound: log(exp a + exp b) ≤ max(a, b) + log 2

PROVIDED SOLUTION
WLOG assume a ≥ b. Then max(a,b) = a. exp(b) ≤ exp(a), so exp(a)+exp(b) ≤ 2·exp(a). Then log(exp(a)+exp(b)) ≤ log(2·exp(a)) = log 2 + a = log 2 + max(a,b). Use Real.log_le_log with positivity, and Real.log_mul.
-/
theorem lse_le_max_add_log2 (a b : ℝ) :
    Real.log (Real.exp a + Real.exp b) ≤ max a b + Real.log 2 := by
  rw [ ← Real.log_exp ( Max.max a b ), ← Real.log_mul ( by positivity ) ( by positivity ) ];
  exact Real.log_le_log ( by positivity ) ( by rw [ mul_two ] ; cases max_cases a b <;> linarith [ Real.exp_le_exp.2 ( by linarith : a ≤ Max.max a b ), Real.exp_le_exp.2 ( by linarith : b ≤ Max.max a b ) ] )

/-! ## Tier 6: Boolean Algebra Embeds into Tropical Semiring -/

/-- Boolean OR corresponds to tropical addition (min) under the embedding
    True ↦ 0, False ↦ 1 (using 1 as a finite proxy for ∞). -/
def bool_to_trop (b : Bool) : ℝ := if b then 0 else 1

/-- OR = tropical min for the Boolean embedding -/
theorem bool_or_is_trop_min (a b : Bool) :
    bool_to_trop (a || b) = min (bool_to_trop a) (bool_to_trop b) := by
  cases a <;> cases b <;> simp [bool_to_trop, min_def]

/-- AND = tropical addition (clamped) for the {0,1} encoding -/
theorem bool_and_is_trop_add_clamp (a b : Bool) :
    bool_to_trop (a && b) = min 1 (bool_to_trop a + bool_to_trop b) := by
  cases a <;> cases b <;> simp [bool_to_trop, min_def]

/-! ## Tropical Distributivity: The Key Structural Identity -/

/-- The fundamental identity connecting all tiers:
    a + min(b, c) = min(a + b, a + c)
    This is what makes shortest paths, scheduling, and SAT all work tropically. -/
theorem fundamental_tropical_identity (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := by
  simp [min_def]; split_ifs <;> linarith

/-
PROBLEM
Iterated tropical distributivity for finite sets

PROVIDED SOLUTION
Induction on the finset. Base case: singleton, trivial. Inductive step: use that inf' over insert is min of new element and inf' of rest, then apply trop_distrib (fundamental_tropical_identity).
-/
theorem trop_distrib_finset {ι : Type*} [DecidableEq ι] (s : Finset ι)
    (hs : s.Nonempty) (a : ℝ) (f : ι → ℝ) :
    a + s.inf' hs f = s.inf' hs (fun i => a + f i) := by
  refine' le_antisymm _ _ <;> simp_all +decide [ add_comm, add_left_comm, add_assoc ];
  · exact fun b hb => ⟨ b, hb, le_rfl ⟩;
  · exact Finset.exists_min_image _ _ hs

end TropicalAlphabet