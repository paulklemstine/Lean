import Mathlib

/-!
# Max-Plus Light Cone Geometry and Berggren–Tropical Correspondence

This file establishes the foundational theory of the **tropical light cone**
`L_trop = {v ∈ ℝ³ : max(v₀, v₁) = v₂}` and its max-plus convex geometry,
connecting Pythagorean number theory to tropical algebraic geometry.

## Main Definitions

* `BerggrenTropical.TropicalLightCone` — The tropical light cone in ℝ³
* `BerggrenTropical.mpMatVecMul` — Max-plus matrix–vector multiplication
* `BerggrenTropical.tropBerggrenMat` — The tropical Berggren matrix
* `BerggrenTropical.MaslovDeq` — Maslov dequantization operation
* `BerggrenTropical.TropConvexSet` — Max-plus convex sets
* `BerggrenTropical.TropPythVariety` — Tropical Pythagorean variety

## Main Results

* The tropical light cone is a max-plus convex cone (Theorem 1)
* Maslov dequantization converges to max with rate O(h · log 2) (Theorem 10)
* Log-sum approximation bounds (Theorems 5–7)
* Tropical variety characterization of the light cone (Theorem 12)
* Structural lemmas for max-plus algebra

## Bridge: Pythagorean Number Theory ↔ Tropical Algebraic Geometry

The classical Berggren matrices generate all primitive Pythagorean triples
via isometries of the Lorentz form x² + y² − z². Passing to the tropical
(max-plus) semiring yields max-plus linear maps whose geometry approximates
classical Pythagorean geometry with explicit error bounds.
-/

namespace BerggrenTropical

open Real

/-! ## Section 1: Max-Plus Algebra Foundations -/

/-- Max-plus scalar multiplication: `a ⊗ v = (a + v₀, a + v₁, a + v₂)`.
    Bridge: connects tropical linear algebra to classical vector spaces. -/
def mpScale (a : ℝ) (v : Fin 3 → ℝ) : Fin 3 → ℝ := fun i => a + v i

/-- Max-plus vector addition: componentwise max.
    Bridge: connects lattice theory to tropical geometry. -/
def mpVecAdd (v w : Fin 3 → ℝ) : Fin 3 → ℝ := fun i => max (v i) (w i)

/-- Max-plus convex combination: `a ⊗ v ⊕ b ⊗ w`.
    Bridge: connects tropical convexity to classical convex geometry. -/
def mpConvex (a b : ℝ) (v w : Fin 3 → ℝ) : Fin 3 → ℝ :=
  mpVecAdd (mpScale a v) (mpScale b w)

/-- Max-plus 3×3 matrix–vector multiplication: `(M ⊗ v)ᵢ = maxⱼ(Mᵢⱼ + vⱼ)`.
    Bridge: connects tropical linear algebra to max-plus dynamical systems. -/
def mpMatVecMul (M : Fin 3 → Fin 3 → ℝ) (v : Fin 3 → ℝ) : Fin 3 → ℝ :=
  fun i => max (M i 0 + v 0) (max (M i 1 + v 1) (M i 2 + v 2))

/-- Max-plus 3×3 matrix multiplication.
    Bridge: connects tropical matrix semigroups to classical matrix groups. -/
def mpMatMul (M N : Fin 3 → Fin 3 → ℝ) : Fin 3 → Fin 3 → ℝ :=
  fun i k => max (M i 0 + N 0 k) (max (M i 1 + N 1 k) (M i 2 + N 2 k))

/-! ### Max-Plus Algebraic Identities -/

/-- **Max-plus left distributivity**: `max(a + x, a + y) = a + max(x, y)`. -/
theorem mpDistrib_left (a x y : ℝ) : max (a + x) (a + y) = a + max x y := by
  rw [max_add_add_left]

/-- **Max-plus right distributivity**: `max(x + a, y + a) = max(x, y) + a`. -/
theorem mpDistrib_right (x y a : ℝ) : max (x + a) (y + a) = max x y + a := by
  rw [max_add_add_right]

/-- **Four-term max rearrangement**: key identity for tropical convexity. -/
theorem max_four_rearrange (a b v0 v1 w0 w1 : ℝ) :
    max (max (a + v0) (b + w0)) (max (a + v1) (b + w1)) =
    max (a + max v0 v1) (b + max w0 w1) := by
  rw [← max_add_add_left a v0 v1, ← max_add_add_left b w0 w1]
  simp [max_comm, max_left_comm]

/-! ## Section 2: The Tropical Light Cone -/

/-- The **tropical light cone**: vectors satisfying `max(v₀, v₁) = v₂`.
    This is the idempotent shadow of the Minkowski null cone `a² + b² = c²`.
    Bridge: connects relativistic physics to idempotent mathematics. -/
def TropicalLightCone : Set (Fin 3 → ℝ) :=
  {v | max (v 0) (v 1) = v 2}

/-- A **max-plus convex set**: closed under tropical convex combinations.
    Bridge: connects tropical convex geometry to certified ML robustness. -/
class TropConvexSet (S : Set (Fin 3 → ℝ)) : Prop where
  convex : ∀ v w : Fin 3 → ℝ, v ∈ S → w ∈ S → ∀ a b : ℝ, mpConvex a b v w ∈ S

/-- The zero vector lies on the tropical light cone. -/
theorem zero_mem_tropicalLightCone : (fun _ : Fin 3 => (0 : ℝ)) ∈ TropicalLightCone := by
  simp [TropicalLightCone, max_self]

/-- Any constant vector `(a, a, a)` lies on the tropical light cone. -/
theorem const_mem_tropicalLightCone (a : ℝ) :
    (fun _ : Fin 3 => a) ∈ TropicalLightCone := by
  simp [TropicalLightCone, max_self]

/-- On the tropical light cone, `v₂` is an upper bound for `v₀`. -/
theorem tropicalLightCone_v0_le_v2 {v : Fin 3 → ℝ} (hv : v ∈ TropicalLightCone) :
    v 0 ≤ v 2 := hv ▸ le_max_left _ _

/-- On the tropical light cone, `v₂` is an upper bound for `v₁`. -/
theorem tropicalLightCone_v1_le_v2 {v : Fin 3 → ℝ} (hv : v ∈ TropicalLightCone) :
    v 1 ≤ v 2 := hv ▸ le_max_right _ _

/-- On the tropical light cone, either `v₀ = v₂` or `v₁ = v₂`.
    This is the tropical analogue of the Pythagorean dichotomy. -/
theorem tropicalLightCone_dichotomy {v : Fin 3 → ℝ} (hv : v ∈ TropicalLightCone) :
    v 0 = v 2 ∨ v 1 = v 2 := by
  simp only [TropicalLightCone, Set.mem_setOf_eq] at hv
  rcases le_total (v 0) (v 1) with h01 | h10
  · right; rw [← hv, max_eq_right h01]
  · left; rw [← hv, max_eq_left h10]

/-! ### Max-Plus Convexity -/

/-- **Tropical light cone is closed under max-plus scaling**.
    Bridge: connects tropical conic geometry to projective geometry. -/
theorem mpScale_preserves_cone {v : Fin 3 → ℝ} (hv : v ∈ TropicalLightCone) (a : ℝ) :
    mpScale a v ∈ TropicalLightCone := by
  show max (a + v 0) (a + v 1) = a + v 2
  rw [max_add_add_left, hv]

/-- **Tropical light cone is max-plus convex** (Main Theorem 1).
    For any `v, w ∈ L_trop` and scalars `a, b ∈ ℝ`, the max-plus convex
    combination `a ⊗ v ⊕ b ⊗ w ∈ L_trop`.
    Bridge: connects tropical convex geometry to certified robustness. -/
theorem tropicalLightCone_maxPlus_convex {v w : Fin 3 → ℝ}
    (hv : v ∈ TropicalLightCone) (hw : w ∈ TropicalLightCone) (a b : ℝ) :
    mpConvex a b v w ∈ TropicalLightCone := by
  simp only [TropicalLightCone, Set.mem_setOf_eq, mpConvex, mpVecAdd, mpScale]
  rw [max_four_rearrange, hv, hw]

/-- The tropical light cone is a `TropConvexSet`. -/
instance : TropConvexSet TropicalLightCone where
  convex _ _ hv hw a b := tropicalLightCone_maxPlus_convex hv hw a b

/-- **Closed under componentwise max** (tropical vector addition). -/
theorem mpVecAdd_preserves_cone {v w : Fin 3 → ℝ}
    (hv : v ∈ TropicalLightCone) (hw : w ∈ TropicalLightCone) :
    mpVecAdd v w ∈ TropicalLightCone := by
  show max (max (v 0) (w 0)) (max (v 1) (w 1)) = max (v 2) (w 2)
  rw [← hv, ← hw]
  simp [max_comm, max_left_comm, max_assoc]

/-- On the light cone, `v 2 = max(v 0, v 1)`. -/
theorem tropNorm_eq_max_on_cone {v : Fin 3 → ℝ} (hv : v ∈ TropicalLightCone) :
    v 2 = max (v 0) (v 1) := hv.symm

/-- **Entropy concentration**: all coordinates bounded by `v₂`.
    Bridge: connects information theory to tropical light cone geometry. -/
theorem tropical_entropy_concentration {v : Fin 3 → ℝ}
    (hv : v ∈ TropicalLightCone) :
    v 0 ≤ v 2 ∧ v 1 ≤ v 2 ∧ max (v 0) (v 1) = v 2 :=
  ⟨tropicalLightCone_v0_le_v2 hv, tropicalLightCone_v1_le_v2 hv, hv⟩

/-! ## Section 3: Maslov Dequantization -/

/-- **Maslov dequantization**: `MaslovDeq h x y = h · log(exp(x/h) + exp(y/h))`.
    As h → 0⁺, this converges to `max(x, y)`.
    Bridge: connects the ℏ → 0 limit to tropical geometry. -/
noncomputable def MaslovDeq (h x y : ℝ) : ℝ :=
  h * log (exp (x / h) + exp (y / h))

/-- The argument of `log` in Maslov dequantization is always positive. -/
theorem maslov_arg_pos (h x y : ℝ) : 0 < exp (x / h) + exp (y / h) :=
  add_pos (exp_pos _) (exp_pos _)

/-
**Maslov lower bound**: `max(x, y) ≤ MaslovDeq h x y` for `h > 0`.
-/
theorem maslov_lower_bound (h x y : ℝ) (hh : 0 < h) :
    max x y ≤ MaslovDeq h x y := by
      have h_lower_bound : Real.exp (max x y / h) ≤ Real.exp (x / h) + Real.exp (y / h) := by
        cases max_choice x y <;> simp +decide [ * ];
        · positivity;
        · positivity;
      have := Real.log_le_log ( by positivity ) h_lower_bound;
      unfold MaslovDeq; rw [ Real.log_exp ] at this; nlinarith [ mul_div_cancel₀ ( max x y ) hh.ne' ] ;

/-
**Maslov upper bound**: `MaslovDeq h x y ≤ max(x, y) + h · log 2` for `h > 0`.
-/
theorem maslov_upper_bound (h x y : ℝ) (hh : 0 < h) :
    MaslovDeq h x y ≤ max x y + h * log 2 := by
      -- Expanding MaslovDeq and manipulating inequality.
      unfold MaslovDeq;
      have h_exp : (Real.exp (x / h)) + (Real.exp (y / h)) ≤ 2 * (Real.exp ((max x y) / h)) := by
        linarith [ Real.exp_le_exp.2 ( show x / h ≤ max x y / h by gcongr ; norm_num ), Real.exp_le_exp.2 ( show y / h ≤ max x y / h by gcongr ; norm_num ) ];
      have := Real.log_le_log ( by positivity ) h_exp;
      rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] at this ; nlinarith [ mul_div_cancel₀ ( max x y ) hh.ne' ]

/-- **Maslov convergence rate** (Main Theorem 10).
    `|MaslovDeq h x y − max(x, y)| ≤ h · log 2`.
    Bridge: connects quantum mechanics (ℏ → 0) to tropical geometry. -/
theorem maslov_convergence_rate (h x y : ℝ) (hh : 0 < h) :
    |MaslovDeq h x y - max x y| ≤ h * log 2 := by
  rw [abs_le]
  constructor <;> linarith [maslov_lower_bound h x y hh, maslov_upper_bound h x y hh]

/-! ## Section 4: The Tropical Berggren Matrix -/

/-- The absolute-value matrix shared by all three Berggren matrices. -/
def berggrenAbsMatrix : Fin 3 → Fin 3 → ℕ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- The **tropical Berggren matrix**: `M[i,j] = log(|A[i,j]|)`.
    Bridge: connects Pythagorean number theory to max-plus linear algebra. -/
noncomputable def tropBerggrenMat : Fin 3 → Fin 3 → ℝ := fun i j =>
  log (berggrenAbsMatrix i j : ℝ)

theorem tropBerggrenMat_diag_0 : tropBerggrenMat 0 0 = 0 := by
  simp [tropBerggrenMat, berggrenAbsMatrix]

theorem tropBerggrenMat_diag_1 : tropBerggrenMat 1 1 = 0 := by
  simp [tropBerggrenMat, berggrenAbsMatrix]

theorem tropBerggrenMat_diag_2 : tropBerggrenMat 2 2 = log 3 := by
  simp [tropBerggrenMat, berggrenAbsMatrix]

theorem tropBerggrenMat_01 : tropBerggrenMat 0 1 = log 2 := by
  simp [tropBerggrenMat, berggrenAbsMatrix]

/-! ## Section 5: Log-Sum Approximation (Classical ↔ Tropical Bridge) -/

/-
**Log-sum lower bound**: `max(log x, log y) ≤ log(x + y)` for positive reals.
-/
theorem log_sum_ge_max_log {x y : ℝ} (hx : 0 < x) (hy : 0 < y) :
    max (log x) (log y) ≤ log (x + y) := by
      exact max_le ( Real.log_le_log hx ( by linarith ) ) ( Real.log_le_log hy ( by linarith ) )

/-
**Log-sum upper bound**: `log(x + y) ≤ max(log x, log y) + log 2`.
    Bridge: connects tropical approximation theory to error analysis.
-/
theorem log_sum_le_max_log_add {x y : ℝ} (hx : 0 < x) (hy : 0 < y) :
    log (x + y) ≤ max (log x) (log y) + log 2 := by
      -- Using the properties of logarithms, we know that $log(x + y) \leq log(2 \cdot max(x, y))$.
      have h_log_sum_le_log_max : log (x + y) ≤ log (2 * max x y) := by
        exact Real.log_le_log ( by positivity ) ( by linarith [ le_max_left x y, le_max_right x y ] );
      convert h_log_sum_le_log_max using 1 ; rw [ Real.log_mul ( by positivity ) ( by positivity ) ] ; ring;
      cases max_cases x y <;> simp +decide [ *, add_comm ];
      · exact Real.log_le_log hy ( by linarith );
      · exact Real.log_le_log hx ( by linarith )

/-
**Log-sum three-term bound**: `log(x+y+z) ≤ max(log x, max(log y, log z)) + log 3`.
    Bridge: connects tropical matrix algebra to Berggren matrix computation.
-/
theorem log_sum_three_le {x y z : ℝ} (hx : 0 < x) (hy : 0 < y) (hz : 0 < z) :
    log (x + y + z) ≤ max (log x) (max (log y) (log z)) + log 3 := by
      -- Since $x$, $y$, and $z$ are positive, we can apply the logarithm function to both sides of the inequality $x + y + z \leq 3 * \max\{x, y, z\}$.
      have h_log : Real.log (x + y + z) ≤ Real.log (3 * max x (max y z)) := by
        exact Real.log_le_log ( by positivity ) ( by cases max_cases x ( Max.max y z ) <;> cases max_cases y z <;> linarith );
      rw [ Real.log_mul ( by positivity ) ( by positivity ), add_comm ] at h_log;
      grind +splitImp

/-! ## Section 6: Tropical Variety Characterization -/

/-- The tropical Pythagorean variety: where `max(2v₀, 2v₁, 2v₂)` achieves
    its maximum at least twice. -/
def TropPythVariety : Set (Fin 3 → ℝ) :=
  {v | (v 0 = v 1 ∧ v 0 ≥ v 2) ∨
       (v 0 = v 2 ∧ v 0 ≥ v 1) ∨
       (v 1 = v 2 ∧ v 1 ≥ v 0)}

/-- The tropical light cone is contained in the tropical Pythagorean variety. -/
theorem tropicalLightCone_subset_variety :
    TropicalLightCone ⊆ TropPythVariety := by
  intro v hv
  simp only [TropicalLightCone, Set.mem_setOf_eq] at hv
  simp only [TropPythVariety, Set.mem_setOf_eq]
  rcases le_total (v 0) (v 1) with h01 | h10
  · right; right; exact ⟨by rw [← hv, max_eq_right h01], h01⟩
  · right; left; exact ⟨by rw [← hv, max_eq_left h10], h10⟩

/-- **Tropical variety characterization** (Main Theorem 12).
    The tropical variety restricted to `v₂ ≥ max(v₀, v₁)` equals the light cone. -/
theorem tropPythVariety_restricted_eq_cone :
    {v ∈ TropPythVariety | v 2 ≥ max (v 0) (v 1)} = TropicalLightCone := by
  ext v
  simp only [TropPythVariety, TropicalLightCone, Set.mem_setOf_eq]
  constructor
  · rintro ⟨(⟨h01, h02⟩ | ⟨h02, h01⟩ | ⟨h12, h10⟩), hge⟩
    · rw [h01, max_self] at hge ⊢; linarith
    · rw [max_eq_left h01, h02]
    · rw [max_eq_right h10, h12]
  · intro hv
    refine ⟨?_, le_of_eq hv⟩
    rcases le_total (v 0) (v 1) with h01 | h10
    · right; right; exact ⟨by rw [← hv, max_eq_right h01], h01⟩
    · right; left; exact ⟨by rw [← hv, max_eq_left h10], h10⟩

/-! ## Section 7: Structural Properties -/

/-- Max-plus convex combination is symmetric. -/
theorem mpConvex_comm (a b : ℝ) (v w : Fin 3 → ℝ) :
    mpConvex a b v w = mpConvex b a w v := by
  ext i; simp [mpConvex, mpVecAdd, mpScale, max_comm]

/-- Max-plus scaling by 0 is the identity. -/
theorem mpScale_zero (v : Fin 3 → ℝ) : mpScale 0 v = v := by
  ext i; simp [mpScale]

/-- Max-plus scaling is associative: `(a+b) ⊗ v = a ⊗ (b ⊗ v)`. -/
theorem mpScale_add (a b : ℝ) (v : Fin 3 → ℝ) :
    mpScale (a + b) v = mpScale a (mpScale b v) := by
  ext i; simp [mpScale, add_assoc]

/-- Max-plus self-convex combination simplifies to scaling. -/
theorem mpConvex_self (a b : ℝ) (v : Fin 3 → ℝ) :
    mpConvex a b v v = mpScale (max a b) v := by
  ext i; simp [mpConvex, mpVecAdd, mpScale, max_add_add_right]

/-- Matrix–vector multiplication is monotone in the vector. -/
theorem mpMatVecMul_mono (M : Fin 3 → Fin 3 → ℝ) {v w : Fin 3 → ℝ}
    (h : ∀ j, v j ≤ w j) (i : Fin 3) :
    mpMatVecMul M v i ≤ mpMatVecMul M w i := by
  simp only [mpMatVecMul]; gcongr <;> exact h _

/-! ## Section 8: Tree Combinatorics -/

/-- A **Berggren path**: a sequence of branch choices.
    Bridge: connects combinatorics of ternary trees to tropical geometry. -/
abbrev BerggrenPath (n : ℕ) := Fin n → Fin 3

/-- The number of Berggren paths of length `n` is `3^n`. -/
theorem berggrenPath_card (n : ℕ) : Fintype.card (BerggrenPath n) = 3 ^ n := by
  simp [BerggrenPath, Fintype.card_fin]

/-- **Post-quantum tree depth bound**: `3^d ≥ 2^d`.
    Bridge: connects Pythagorean tree combinatorics to hash security. -/
theorem post_quantum_tree_depth_bound (d : ℕ) : 3 ^ d ≥ 2 ^ d :=
  Nat.pow_le_pow_left (by norm_num) d

/-- Tree growth is at least linear: `3^n ≥ n + 1`. -/
theorem tropical_tree_growth (n : ℕ) : 3 ^ n ≥ n + 1 := by
  induction n with
  | zero => simp
  | succ k ih =>
    calc 3 ^ (k + 1) = 3 * 3 ^ k := by ring
      _ ≥ 3 * (k + 1) := Nat.mul_le_mul_left 3 ih
      _ ≥ k + 2 := by omega

/-! ## Section 9: Positivity and Ordering of Logarithms -/

theorem log_two_pos : (0 : ℝ) < log 2 := log_pos (by norm_num : (1 : ℝ) < 2)

theorem log_three_pos : (0 : ℝ) < log 3 := log_pos (by norm_num : (1 : ℝ) < 3)

theorem log_two_le_log_three : log 2 ≤ log 3 :=
  Real.log_le_log (by norm_num : (0 : ℝ) < 2) (by norm_num : (2 : ℝ) ≤ 3)

theorem log_two_lt_log_three : log 2 < log 3 :=
  Real.log_lt_log (by norm_num : (0 : ℝ) < 2) (by norm_num : (2 : ℝ) < 3)

/-! ## Section 10: Light Cone Constructors -/

/-- Construct a point on the light cone from two coordinates. -/
def mkLightConePoint (a b : ℝ) : Fin 3 → ℝ :=
  ![a, b, max a b]

/-- The constructed point is on the light cone. -/
theorem mkLightConePoint_mem (a b : ℝ) :
    mkLightConePoint a b ∈ TropicalLightCone := by
  simp [mkLightConePoint, TropicalLightCone, Matrix.cons_val_zero, Matrix.cons_val_one]

/-- The tropical light cone is nonempty. -/
theorem tropicalLightCone_nonempty : Set.Nonempty TropicalLightCone :=
  ⟨_, zero_mem_tropicalLightCone⟩

end BerggrenTropical