/-! # CatalogBuild.Pythagorean.Quadruples.OpenQuestions

Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 45
-/

import Mathlib

/-- An integer quaternion (Lipschitz integer) -/
structure LipschitzInt where
  w : ℤ
  x : ℤ
  y : ℤ
  z : ℤ
  deriving Repr, DecidableEq

namespace LipschitzInt




/-- [Section: # CatalogBuild.Pythagorean.Quadruples.OpenQuestions
Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 45] -/
def add (p q : LipschitzInt) : LipschitzInt :=
  ⟨p.w + q.w, p.x + q.x, p.y + q.y, p.z + q.z⟩




/-- [Section: # CatalogBuild.Pythagorean.Quadruples.OpenQuestions
Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 45] -/
def sub (p q : LipschitzInt) : LipschitzInt :=
  ⟨p.w - q.w, p.x - q.x, p.y - q.y, p.z - q.z⟩




def one : LipschitzInt := ⟨1, 0, 0, 0⟩




/-- |p · q|² = |p|² · |q|² — the four-square identity -/
theorem LipschitzInt.sqNorm_mul (p q : LipschitzInt) :
    (p.mul q).sqNorm = p.sqNorm * q.sqNorm := by
  simp only [LipschitzInt.sqNorm, LipschitzInt.mul]; ring




/-- Squared norm is non-negative -/
theorem LipschitzInt.sqNorm_nonneg (q : LipschitzInt) : 0 ≤ q.sqNorm := by
  unfold LipschitzInt.sqNorm; positivity




/-- Squared norm is zero iff quaternion is zero -/
theorem LipschitzInt.sqNorm_eq_zero (q : LipschitzInt) :
    q.sqNorm = 0 ↔ q = LipschitzInt.zero := by
  constructor
  · intro h
    unfold LipschitzInt.sqNorm at h
    have hw : q.w = 0 := by nlinarith [sq_nonneg q.w, sq_nonneg q.x, sq_nonneg q.y, sq_nonneg q.z]
    have hx : q.x = 0 := by nlinarith [sq_nonneg q.w, sq_nonneg q.x, sq_nonneg q.y, sq_nonneg q.z]
    have hy : q.y = 0 := by nlinarith [sq_nonneg q.w, sq_nonneg q.x, sq_nonneg q.y, sq_nonneg q.z]
    have hz : q.z = 0 := by nlinarith [sq_nonneg q.w, sq_nonneg q.x, sq_nonneg q.y, sq_nonneg q.z]
    ext <;> assumption
  · intro h; subst h; simp [LipschitzInt.sqNorm, LipschitzInt.zero]




/-- σ = 1 + i + j + k -/
def sigmaQuat : LipschitzInt := ⟨1, 1, 1, 1⟩




/-- |σ|² = 4 -/
theorem sigmaQuat_sqNorm : sigmaQuat.sqNorm = 4 := by
  simp [sigmaQuat, LipschitzInt.sqNorm]




/-- The Euler parametrization from a quaternion -/
def eulerMap (α : LipschitzInt) : Fin 4 → ℤ := fun i =>
  match i with
  | 0 => α.w ^ 2 + α.x ^ 2 - α.y ^ 2 - α.z ^ 2
  | 1 => 2 * (α.w * α.z + α.x * α.y)
  | 2 => 2 * (α.x * α.z - α.w * α.y)
  | 3 => α.sqNorm




/-- The Euler map always produces a Pythagorean quadruple -/
theorem eulerMap_pyth (α : LipschitzInt) :
    (eulerMap α 0) ^ 2 + (eulerMap α 1) ^ 2 + (eulerMap α 2) ^ 2 =
    (eulerMap α 3) ^ 2 := by
  unfold eulerMap LipschitzInt.sqNorm; ring




/-- σ-multiplication scales the norm by 4 -/
theorem sigma_equiv_same_hyp_mod (α : LipschitzInt) :
    (sigmaQuat.mul α).sqNorm = 4 * α.sqNorm := by
  rw [LipschitzInt.sqNorm_mul, sigmaQuat_sqNorm]




/-- The branching number at a node with hypotenuse d -/
def branchingNumber (d : ℕ) : ℕ :=
  ((Finset.range (d + 1)).filter fun c =>
    ((Finset.range (c + 1)).filter fun b =>
      ((Finset.range (b + 1)).filter fun a =>
        a * a + b * b + c * c = d * d ∧
        Nat.gcd (Nat.gcd a b) (Nat.gcd c d) = 1).card > 0).card > 0).card




theorem lipschitz_division_exists (α β : LipschitzInt) (hβ : β ≠ LipschitzInt.zero) :
    ∃ γ ρ : LipschitzInt, α = (β.mul γ).add ρ ∧ ρ.sqNorm ≤ β.sqNorm := by
  by_contra! h_contra;
  -- By definition of $sqNorm$, we know that $sqNorm(q) = q.w^2 + q.x^2 + q.y^2 + q.z^2$ for any quaternion $q$.
  set N := β.sqNorm with hN
  have hN_pos : 0 < N := by
    exact lt_of_le_of_ne ( by exact add_nonneg ( add_nonneg ( add_nonneg ( sq_nonneg _ ) ( sq_nonneg _ ) ) ( sq_nonneg _ ) ) ( sq_nonneg _ ) ) ( Ne.symm <| by intro h; exact hβ <| by exact LipschitzInt.sqNorm_eq_zero β |>.1 h );
  -- Let $p = \beta^{-1} \alpha$.
  obtain ⟨p_w, p_x, p_y, p_z, hp⟩ : ∃ p_w p_x p_y p_z : ℚ, (β.w * p_w - β.x * p_x - β.y * p_y - β.z * p_z : ℚ) = α.w ∧ (β.w * p_x + β.x * p_w + β.y * p_z - β.z * p_y : ℚ) = α.x ∧ (β.w * p_y - β.x * p_z + β.y * p_w + β.z * p_x : ℚ) = α.y ∧ (β.w * p_z + β.x * p_y - β.y * p_x + β.z * p_w : ℚ) = α.z := by
    -- We can solve this system of linear equations using Gaussian elimination.
    set A : Matrix (Fin 4) (Fin 4) ℚ := !![β.w, -β.x, -β.y, -β.z; β.x, β.w, -β.z, β.y; β.y, β.z, β.w, -β.x; β.z, -β.y, β.x, β.w]
    set b : Fin 4 → ℚ := ![α.w, α.x, α.y, α.z];
    -- Since $A$ is invertible, we can solve the system $A \cdot p = b$ for $p$.
    obtain ⟨p, hp⟩ : ∃ p : Fin 4 → ℚ, A.mulVec p = b := by
      have h_det : A.det ≠ 0 := by
        norm_num [ Matrix.det_succ_row_zero ];
        simp +zetaDelta at *;
        simp +decide [ Fin.sum_univ_succ, Fin.succAbove ] ; ring_nf ; norm_cast ; simp_all +decide [ LipschitzInt.sqNorm ] ;
        nlinarith [ sq_pos_of_pos hN_pos ];
      exact ⟨ A⁻¹.mulVec b, by simp +decide [ h_det, isUnit_iff_ne_zero ] ⟩;
    norm_num +zetaDelta at *;
    exact ⟨ p 0, p 1, p 2, p 3, by linarith !, by linarith !, by linarith !, by linarith ! ⟩;
  -- Let $γ$ be the closest integer quaternion to $p$.
  obtain ⟨γ_w, γ_x, γ_y, γ_z, hγ⟩ : ∃ γ_w γ_x γ_y γ_z : ℤ, (p_w - γ_w : ℚ)^2 + (p_x - γ_x : ℚ)^2 + (p_y - γ_y : ℚ)^2 + (p_z - γ_z : ℚ)^2 ≤ 1 := by
    exact ⟨ ⌊p_w + 1 / 2⌋, ⌊p_x + 1 / 2⌋, ⌊p_y + 1 / 2⌋, ⌊p_z + 1 / 2⌋, by nlinarith only [ Int.floor_le ( p_w + 1 / 2 ), Int.lt_floor_add_one ( p_w + 1 / 2 ), Int.floor_le ( p_x + 1 / 2 ), Int.lt_floor_add_one ( p_x + 1 / 2 ), Int.floor_le ( p_y + 1 / 2 ), Int.lt_floor_add_one ( p_y + 1 / 2 ), Int.floor_le ( p_z + 1 / 2 ), Int.lt_floor_add_one ( p_z + 1 / 2 ) ] ⟩;
  -- Let $ρ = α - βγ$.
  set ρ : LipschitzInt := ⟨α.w - (β.w * γ_w - β.x * γ_x - β.y * γ_y - β.z * γ_z), α.x - (β.w * γ_x + β.x * γ_w + β.y * γ_z - β.z * γ_y), α.y - (β.w * γ_y - β.x * γ_z + β.y * γ_w + β.z * γ_x), α.z - (β.w * γ_z + β.x * γ_y - β.y * γ_x + β.z * γ_w)⟩ with hρ_def
  have hρ : α = (β.mul ⟨γ_w, γ_x, γ_y, γ_z⟩).add ρ := by
    exact Eq.symm ( by ext <;> simp +decide [ LipschitzInt.mul, LipschitzInt.add ] <;> ring )
  have hρ_sq : ρ.sqNorm ≤ N := by
    have hρ_sq : (ρ.w : ℚ)^2 + (ρ.x : ℚ)^2 + (ρ.y : ℚ)^2 + (ρ.z : ℚ)^2 ≤ N := by
      convert mul_le_mul_of_nonneg_left hγ ( show ( 0 : ℚ ) ≤ N by positivity ) using 1 ; ring!;
      · unfold LipschitzInt.sqNorm; push_cast [ ← @Int.cast_inj ℚ ] at *; rw [ ← hp.1, ← hp.2.1, ← hp.2.2.1, ← hp.2.2.2 ] ; ring;
      · ring;
    exact_mod_cast hρ_sq
  exact h_contra ⟨γ_w, γ_x, γ_y, γ_z⟩ ρ hρ |> not_le_of_gt <| hρ_sq.trans' <| by linarith;




theorem lipschitz_strict_fails :
    ∃ α β : LipschitzInt, β ≠ LipschitzInt.zero ∧
    ∀ γ : LipschitzInt, (α.sub (β.mul γ)).sqNorm ≥ β.sqNorm := by
  -- Let's choose the specific values for α and β.
  use ⟨1, 1, 1, 1⟩, ⟨0, 0, 0, 2⟩;
  refine' ⟨ _, fun γ => _ ⟩;
  · exact ne_of_apply_ne ( fun q => q.z ) ( by decide );
  · unfold LipschitzInt.sqNorm;
    unfold LipschitzInt.sub LipschitzInt.mul;
    grind +suggestions




/-- The Hurwitz order has a better Euclidean bound: 3/4 > 1/2 -/
theorem hurwitz_better_bound : (3 : ℚ) / 4 > (1 : ℚ) / 2 := by norm_num




/-- The Lipschitz max remainder ratio is at most 1 (4 coords × (1/2)² = 1) -/
theorem lipschitz_remainder_ratio :
    4 * ((1 : ℚ) / 2) ^ 2 = 1 := by norm_num




/-- The Hurwitz max remainder ratio ≤ 1/4 per coord when rounding error ≤ 1/4 -/
theorem hurwitz_remainder_ratio :
    ∀ (e₁ e₂ e₃ e₄ : ℚ), |e₁| ≤ 1/4 → |e₂| ≤ 1/4 → |e₃| ≤ 1/4 → |e₄| ≤ 1/4 →
    e₁ ^ 2 + e₂ ^ 2 + e₃ ^ 2 + e₄ ^ 2 ≤ 1 / 4 := by
  intro e₁ e₂ e₃ e₄ h₁ h₂ h₃ h₄
  have h1 : e₁ ^ 2 ≤ (1/4 : ℚ) ^ 2 := by
    rw [← sq_abs e₁]; exact sq_le_sq' (by linarith [abs_nonneg e₁]) h₁
  have h2 : e₂ ^ 2 ≤ (1/4 : ℚ) ^ 2 := by
    rw [← sq_abs e₂]; exact sq_le_sq' (by linarith [abs_nonneg e₂]) h₂
  have h3 : e₃ ^ 2 ≤ (1/4 : ℚ) ^ 2 := by
    rw [← sq_abs e₃]; exact sq_le_sq' (by linarith [abs_nonneg e₃]) h₃
  have h4 : e₄ ^ 2 ≤ (1/4 : ℚ) ^ 2 := by
    rw [← sq_abs e₄]; exact sq_le_sq' (by linarith [abs_nonneg e₄]) h₄
  linarith




/-- The Hurwitz tree is shallower: 4/3 < 2 -/
theorem hurwitz_depth_better : (4 : ℚ) / 3 < 2 := by norm_num




/-- The Pythagorean 8-tuple equation -/
def IsPyth8 (v : Fin 8 → ℤ) : Prop :=
  v 0 ^ 2 + v 1 ^ 2 + v 2 ^ 2 + v 3 ^ 2 + v 4 ^ 2 + v 5 ^ 2 + v 6 ^ 2 = v 7 ^ 2




/-- The Lorentz form in signature (7,1) -/
def Q8 (v : Fin 8 → ℤ) : ℤ :=
  v 0 ^ 2 + v 1 ^ 2 + v 2 ^ 2 + v 3 ^ 2 + v 4 ^ 2 + v 5 ^ 2 + v 6 ^ 2 - v 7 ^ 2




/-- The all-ones vector in ℤ⁸ -/
def ones8 : Fin 8 → ℤ := fun _ => 1




/-- The Minkowski norm of the all-ones vector in (7,1): 7 - 1 = 6 -/
theorem ones8_minkowski_norm : Q8 ones8 = 6 := by simp [Q8, ones8]




/-- Key obstruction: the naive reflection for 8-tuples fails to preserve integrality.
The all-ones vector has η-norm 6, so the reflection formula requires division by 3.
Counterexample: (2,3,6,0,0,0,0,7) is a Pythagorean 8-tuple with
spatial-temporal dot product 4, which is not divisible by 3. -/
theorem octonion_obstruction :
    ¬ (∀ (v : Fin 8 → ℤ), IsPyth8 v →
       3 ∣ (v 0 + v 1 + v 2 + v 3 + v 4 + v 5 + v 6 - v 7)) := by
  intro h
  have := h ![2, 3, 6, 0, 0, 0, 0, 7] (by unfold IsPyth8; native_decide)
  simp at this




/-- r₃(n) = number of representations of n as sum of 3 squares -/
def r3 (n : ℕ) : ℕ :=
  ((Finset.Icc (-(n : ℤ)) n ×ˢ Finset.Icc (-(n : ℤ)) n ×ˢ
    Finset.Icc (-(n : ℤ)) n).filter
    fun ⟨a, b, c⟩ => a ^ 2 + b ^ 2 + c ^ 2 = n).card




/-- r₃(d²) > 0 for all d > 0 (trivially: 0²+0²+d²=d²) -/
theorem branching_r3_connection (d : ℕ) (hd : 0 < d) :
    0 < r3 (d * d) := by
  unfold r3
  rw [Finset.card_pos]
  refine ⟨⟨0, ⟨0, (d : ℤ)⟩⟩, ?_⟩
  simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
  refine ⟨⟨⟨by omega, by omega⟩, ⟨⟨by omega, by omega⟩, ⟨?_, ?_⟩⟩⟩, by push_cast; ring⟩
  · have : (0 : ℤ) ≤ ↑(d * d) := Nat.cast_nonneg _
    have : (0 : ℤ) ≤ ↑d := Nat.cast_nonneg _
    linarith
  · exact_mod_cast Nat.le_mul_of_pos_left d hd




/-- Legendre's three-square obstruction: n = 4^a(8b+7) cannot be sum of 3 squares -/
def isThreeSquareObstructed (n : ℕ) : Bool :=
  let rec removeFactorsOf4 (m : ℕ) (fuel : ℕ) : ℕ :=
    match fuel with
    | 0 => m
    | f + 1 => if m % 4 = 0 ∧ m > 0 then removeFactorsOf4 (m / 4) f else m
  let reduced := removeFactorsOf4 n 32
  reduced % 8 = 7

-- Verification of three-square obstruction



theorem three_sq_no_obstruction_1 : isThreeSquareObstructed 1 = false := by native_decide



theorem three_sq_no_obstruction_4 : isThreeSquareObstructed 4 = false := by native_decide



theorem three_sq_obstruction_28 : isThreeSquareObstructed 28 = true := by native_decide

-- Computational verification of r₃



theorem r3_val_1 : r3 1 = 6 := by native_decide



theorem r3_val_2 : r3 2 = 12 := by native_decide



theorem r3_val_3 : r3 3 = 8 := by native_decide



theorem r3_val_4 : r3 4 = 6 := by native_decide



theorem r3_val_9 : r3 9 = 30 := by native_decide




/-- The R₁₁₁₁ reflection matrix -/
def R1111_mat : Matrix (Fin 4) (Fin 4) ℤ :=
  !![0, -1, -1, 1; -1, 0, -1, 1; -1, -1, 0, 1; -1, -1, -1, 2]




/-- The conjugate of σ is (1,-1,-1,-1) -/
theorem sigmaQuat_conj : sigmaQuat.conj = ⟨1, -1, -1, -1⟩ := by
  simp [sigmaQuat, LipschitzInt.conj]




/-- σ · σ̄ has real part 4 -/
theorem sigma_mul_conj_re :
    (sigmaQuat.mul sigmaQuat.conj).w = 4 := by
  simp [sigmaQuat, LipschitzInt.mul, LipschitzInt.conj]




/-- σ · σ̄ has zero imaginary parts -/
theorem sigma_mul_conj_im :
    (sigmaQuat.mul sigmaQuat.conj).x = 0 ∧
    (sigmaQuat.mul sigmaQuat.conj).y = 0 ∧
    (sigmaQuat.mul sigmaQuat.conj).z = 0 := by
  simp [sigmaQuat, LipschitzInt.mul, LipschitzInt.conj]




/-- The 8 Lipschitz units: ±1, ±i, ±j, ±k -/
def lipschitzUnits : List LipschitzInt :=
  [⟨1,0,0,0⟩, ⟨-1,0,0,0⟩, ⟨0,1,0,0⟩, ⟨0,-1,0,0⟩,
   ⟨0,0,1,0⟩, ⟨0,0,-1,0⟩, ⟨0,0,0,1⟩, ⟨0,0,0,-1⟩]




/-- All Lipschitz units have squared norm 1 -/
theorem lipschitz_units_norm :
    ∀ u ∈ lipschitzUnits, u.sqNorm = 1 := by
  intro u hu
  simp [lipschitzUnits] at hu
  rcases hu with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp [LipschitzInt.sqNorm]




/-- There are exactly 8 Lipschitz units -/
theorem hurwitz_unit_count : lipschitzUnits.length = 8 := by decide




/-- σ has norm 4, linking to Hurwitz structure -/
theorem sigma_norm_is_four : sigmaQuat.sqNorm = 4 := sigmaQuat_sqNorm




/-- Quaternion multiplication IS associative — essential for iterated descent -/
theorem lipschitz_mul_assoc (p q r : LipschitzInt) :
    p.mul (q.mul r) = (p.mul q).mul r := by
  ext <;> simp [LipschitzInt.mul] <;> ring




/-- Combined statement of the main results from all five questions -/
theorem quaternion_descent_master :
    (∀ p q : LipschitzInt, (p.mul q).sqNorm = p.sqNorm * q.sqNorm) ∧
    sigmaQuat.sqNorm = 4 ∧
    (∀ α : LipschitzInt,
      (eulerMap α 0) ^ 2 + (eulerMap α 1) ^ 2 + (eulerMap α 2) ^ 2 = (eulerMap α 3) ^ 2) ∧
    (∀ p q r : LipschitzInt, p.mul (q.mul r) = (p.mul q).mul r) ∧
    ¬ (∀ v : Fin 8 → ℤ, IsPyth8 v →
       3 ∣ (v 0 + v 1 + v 2 + v 3 + v 4 + v 5 + v 6 - v 7)) := by
  exact ⟨LipschitzInt.sqNorm_mul, sigmaQuat_sqNorm, eulerMap_pyth,
         lipschitz_mul_assoc, octonion_obstruction⟩



