/-! # CatalogBuild.Speculative.Other.CrossDomainSynthesis

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 28
-/

import Mathlib

noncomputable section

theorem minkQ_homogeneous (t : ℝ) (v : ℝ × ℝ × ℝ) :
    minkQ (t * v.1, t * v.2.1, t * v.2.2) = t ^ 2 * minkQ v := by
  unfold minkQ; ring

/-- The sign of Q classifies vectors. -/

theorem signOracle_values (x : ℝ) :
    signOracle x = -1 ∨ signOracle x = 0 ∨ signOracle x = 1 := by
  unfold signOracle; split_ifs <;> simp

/-- The "oracle discriminant" classifies a Minkowski vector's causal type. -/

def causalOracle (v : ℝ × ℝ × ℝ) : ℤ := signOracle (minkQ v)

-- ============================================================================
-- SECTION 2: Agent β — Tropical Oracles and Factoring
-- ============================================================================

/-- Tropical addition (= min on ℤ). -/

def tropGCDOracle (a : ℤ) : ℤ → ℤ := fun x => min a x

/-- The tropical GCD oracle is idempotent. -/

theorem tropGCDOracle_idem (a : ℤ) :
    ∀ x, tropGCDOracle a (tropGCDOracle a x) = tropGCDOracle a x := by
  intro x; simp [tropGCDOracle, min_def]; split_ifs <;> omega

/-- The truth set of the tropical GCD oracle is {x | x ≤ a}. -/

theorem tropGCDOracle_truthSet (a x : ℤ) :
    tropGCDOracle a x = x ↔ x ≤ a := by
  constructor <;> intro h
  · simp [tropGCDOracle, min_def] at h ⊢; omega
  · simp [tropGCDOracle, min_def]; omega

/-- Classical GCD is idempotent. -/

theorem gcd_self_idem (n : ℕ) : Nat.gcd n n = n := Nat.gcd_self n

/-- The factoring oracle principle. -/

theorem factoring_oracle_principle (a N g : ℕ) (hg : g = Nat.gcd a N)
    (h1 : 1 < g) (hN : g < N) :
    g ∣ N ∧ 1 < g ∧ g < N := by
  subst hg; exact ⟨Nat.gcd_dvd_right a N, h1, hN⟩

-- ============================================================================
-- SECTION 3: Agent γ — ReLU as Oracle, Neural Band Theory
-- ============================================================================

/-- The ReLU activation function. -/

theorem relu_truthSet (x : ℝ) : relu x = x ↔ 0 ≤ x := by
  -- By definition of max, if max 0 x = x, then x must be greater than or equal to 0.
  apply Iff.intro (fun h => by
    exact le_trans ( le_max_left _ _ ) h.le) (fun h => by
    exact max_eq_right h)

/-- ReLU is non-negative. -/

theorem relu_comp_relu : relu ∘ relu = relu := by
  ext x; exact relu_idempotent x

/-- Special case: affine ReLU with w=1, b=0 is relu. -/

def affineRelu (w b : ℝ) (x : ℝ) : ℝ := relu (w * x + b)


theorem affineRelu_identity : affineRelu 1 0 = relu := by
  ext x; simp [affineRelu]

-- ============================================================================
-- SECTION 4: Agent δ — Algebraic Light: Null Vector Algebra
-- ============================================================================

/-- The Minkowski bilinear form. -/

def minkBilinear (u v : ℝ × ℝ × ℝ) : ℝ :=
  u.1 * v.1 + u.2.1 * v.2.1 - u.2.2 * v.2.2

/-- Polarization identity: Q(u+v) = Q(u) + Q(v) + 2η(u,v). -/

theorem minkQ_sum (u v : ℝ × ℝ × ℝ) :
    minkQ (u.1 + v.1, u.2.1 + v.2.1, u.2.2 + v.2.2) =
      minkQ u + minkQ v + 2 * minkBilinear u v := by
  unfold minkQ minkBilinear; ring

/-- A null vector is self-orthogonal. -/

theorem sum_null_iff_ortho (u v : ℝ × ℝ × ℝ)
    (hu : isNull u) (hv : isNull v) :
    isNull (u.1 + v.1, u.2.1 + v.2.1, u.2.2 + v.2.2) ↔
      minkBilinear u v = 0 := by
  -- By definition of $minkQ$, we can expand $minkQ (u.1 + v.1, u.2.1 + v.2.1, u.2.2 + v.2.2)$ using the bilinear form.
  have h_expand : minkQ (u.1 + v.1, u.2.1 + v.2.1, u.2.2 + v.2.2) = minkQ u + minkQ v + 2 * minkBilinear u v := by
    exact?;
  unfold isNull at *; aesop;

/-
PROBLEM
Every Pythagorean triple is a null vector.

PROVIDED SOLUTION
Unfold isNull and minkQ. We need (a:ℝ)^2 + (b:ℝ)^2 - (c:ℝ)^2 = 0. Since a^2+b^2=c^2 in ℤ, push_cast and linarith.
-/

theorem pyth_triple_null (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    isNull ((a : ℝ), (b : ℝ), (c : ℝ)) := by
  -- By definition of isNull, we need to show that minkQ (a, b, c) = 0.
  unfold isNull minkQ;
  -- Substitute h into the expression to get a^2 + b^2 - c^2 = 0.
  simp [h];
  exact sub_eq_zero_of_eq <| mod_cast h

-- ============================================================================
-- SECTION 5: Agent ε — Factoring Through the Light Cone Lattice
-- ============================================================================

/-- Brahmagupta-Fibonacci identity. -/

theorem brahmagupta_light_cone (a b c d : ℤ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c - b*d)^2 + (a*d + b*c)^2 := by ring

/-- Two sum-of-squares representations enable factoring. -/

theorem two_reps_factor_principle (a b c d : ℤ) :
    (a*c + b*d) * (a*c - b*d) = a^2 * c^2 - b^2 * d^2 := by ring

-- ============================================================================
-- SECTION 6: Agent ζ — Strange Loop AI: Neural Fixed Points
-- ============================================================================

/-- An oracle on a type is an idempotent function. -/

theorem idempotent_fixedPt_eq_range {α : Type*} (f : α → α) (hf : IsIdempotent f) :
    fixedPoints f = range f := by
  exact Set.ext fun x => ⟨ fun hx => ⟨ x, by tauto ⟩, fun hx => by cases hx; aesop ⟩

/-
PROBLEM
Iterating an idempotent map n ≥ 1 times gives the same map.

PROVIDED SOLUTION
Induction on n. Base n=1: f^[1] = f. Step: f^[n+1] = f ∘ f^[n] = f ∘ f = f by IH and funext hf.
-/

theorem neural_convergence {α : Type*} (f : α → α) (hf : IsIdempotent f) (x : α) :
    f (f x) = f x := hf x

/-
PROBLEM
Composing two commuting idempotent maps gives an idempotent map.

PROVIDED SOLUTION
We need f(g(f(g(x)))) = f(g(x)). By commutativity f∘g = g∘f, f(g(y)) = g(f(y)). So f(g(f(g(x)))) = f(g(f(g(x)))). Rewrite: g(f(g(x))) = g(g(f(x))) using comm, = g(f(x)) by hg. Then f(g(f(x))) = f(f(g(x))) by comm again = f(g(x)) by hf.
-/

theorem compose_commuting_idempotents {α : Type*} (f g : α → α)
    (hf : IsIdempotent f) (hg : IsIdempotent g) (hfg : f ∘ g = g ∘ f) :
    IsIdempotent (f ∘ g) := by
  simp_all +decide [ funext_iff, IsIdempotent ]

-- ============================================================================
-- SECTION 7: Grand Synthesis — The Oracle-Light-Tropical Triangle
-- ============================================================================

/-- Every idempotent endomorphism is a retraction onto its image. -/

theorem idempotent_is_retraction {α : Type*} (f : α → α) (hf : IsIdempotent f) :
    ∀ y ∈ range f, f y = y := by
  rintro y ⟨x, rfl⟩; exact hf x

-- ============================================================================
-- SECTION 8: Experimental Verification
-- ============================================================================

/-- The (3,4,5) triple is null. -/

theorem experiment_345_null : isNull ((3 : ℝ), (4 : ℝ), (5 : ℝ)) := by
  simp [isNull, minkQ]; norm_num

/-- Tropical GCD oracle clamps above. -/

theorem experiment_tropGCD : tropGCDOracle 5 7 = 5 := by
  simp [tropGCDOracle]

/-- The 65 = 4² + 7² = 1² + 8² double representation. -/

theorem experiment_65_reps : (4 : ℤ)^2 + 7^2 = 65 ∧ (1 : ℤ)^2 + 8^2 = 65 := by
  constructor <;> norm_num

/-- gcd(15, 65) = 5, revealing the factor 5. -/

theorem experiment_gcd_factor : Nat.gcd 15 65 = 5 := by native_decide

/-
PROBLEM
Projection matrices are idempotent on vectors.

PROVIDED SOLUTION
P.mulVec (P.mulVec v) = (P*P).mulVec v by Matrix.mulVec_mulVec. Then hP : P*P = P gives result.
-/

theorem projection_matrix_oracle (n : ℕ) (P : Matrix (Fin n) (Fin n) ℝ)
    (hP : P * P = P) :
    ∀ v : Fin n → ℝ, P.mulVec (P.mulVec v) = P.mulVec v := by
  simp +decide [hP]

/-
PROBLEM
The product of two commuting projections is a projection.

PROVIDED SOLUTION
(P*Q)*(P*Q) = P*(Q*P)*Q = P*(P*Q)*Q (by hPQ) = (P*P)*(Q*Q) (by assoc) = P*Q. Use mul_assoc.
-/

theorem meet_projections (n : ℕ) (P Q : Matrix (Fin n) (Fin n) ℝ)
    (hP : P * P = P) (hQ : Q * Q = Q) (hPQ : P * Q = Q * P) :
    (P * Q) * (P * Q) = P * Q := by
  grind


end
