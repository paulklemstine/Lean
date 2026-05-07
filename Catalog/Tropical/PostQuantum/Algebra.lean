/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Post-Quantum Cryptography: Algebraic Foundations

## Overview

We prove the core algebraic properties of min-plus matrix multiplication that
underpin the Stickel post-quantum key exchange protocol:

1. **Associativity** of tropical matrix multiplication
2. **Distributivity** of `⊗` over `⊕`
3. **Commutativity of powers** when base matrices commute
4. **Key agreement** for the Stickel protocol

## Bridge: Commutative Algebra ↔ Post-Quantum Cryptography ↔ Neural Networks
-/
import Mathlib
import Tropical.PostQuantum.Defs

noncomputable section
set_option linter.unusedVariables false
set_option linter.unusedSectionVars false
set_option maxHeartbeats 800000

open Finset

namespace TropicalMatrix

variable {n : ℕ} [NeZero n]

/-! ## §1. Foundational `inf'` Lemmas -/

/-- Adding a constant on the right commutes with `inf'`. -/
theorem inf'_add_const_right
    {ι : Type*} (s : Finset ι) (hs : s.Nonempty) (f : ι → ℝ) (c : ℝ) :
    s.inf' hs (fun k => f k + c) = s.inf' hs f + c := by
  apply le_antisymm
  · obtain ⟨k, hk, hmin⟩ := exists_mem_eq_inf' hs f
    exact le_trans (inf'_le _ hk) (by linarith)
  · exact le_inf' hs _ fun k hk => by linarith [inf'_le f hk]

/-- Adding a constant on the left commutes with `inf'`. -/
theorem inf'_add_const_left
    {ι : Type*} (s : Finset ι) (hs : s.Nonempty) (f : ι → ℝ) (c : ℝ) :
    s.inf' hs (fun k => c + f k) = c + s.inf' hs f := by
  simp_rw [add_comm c]; exact inf'_add_const_right s hs f c

/-- `inf'` distributes over `min`. -/
theorem inf'_min_distrib
    {ι : Type*} (s : Finset ι) (hs : s.Nonempty) (f g : ι → ℝ) :
    s.inf' hs (fun k => min (f k) (g k)) = min (s.inf' hs f) (s.inf' hs g) := by
  apply le_antisymm
  · apply le_min
    · exact le_inf' hs _ fun k hk => le_trans (inf'_le _ hk) (min_le_left _ _)
    · exact le_inf' hs _ fun k hk => le_trans (inf'_le _ hk) (min_le_right _ _)
  · apply le_inf'; intro k hk
    exact le_min (le_trans (min_le_left _ _) (inf'_le f hk))
                  (le_trans (min_le_right _ _) (inf'_le g hk))

/-! ## §2. Associativity -/

/-- **Tropical matrix multiplication is associative.** `(A ⊗ B) ⊗ C = A ⊗ (B ⊗ C)`.
Bridge: path concatenation in weighted digraphs is associative. -/
theorem tropMul_assoc (A B C : Matrix (Fin n) (Fin n) ℝ) :
    tropMul (tropMul A B) C = tropMul A (tropMul B C) := by
  ext i j; simp only [tropMul]
  apply le_antisymm
  · apply le_inf'; intro l _
    have step : ∀ k, k ∈ univ →
        (univ.inf' univ_nonempty fun x =>
          (univ.inf' univ_nonempty fun l => A i l + B l x) + C x j) ≤
        A i l + (B l k + C k j) := fun k _ => by
      have h1 := inf'_le (fun x => (univ.inf' univ_nonempty fun l => A i l + B l x) + C x j)
        (mem_univ k)
      have h2 := inf'_le (fun l' => A i l' + B l' k) (mem_univ l)
      linarith
    calc _ ≤ univ.inf' univ_nonempty (fun k => A i l + (B l k + C k j)) :=
          le_inf' _ _ step
      _ = A i l + univ.inf' univ_nonempty (fun k => B l k + C k j) :=
          inf'_add_const_left univ univ_nonempty _ (A i l)
  · apply le_inf'; intro k _
    have step : ∀ l, l ∈ univ →
        (univ.inf' univ_nonempty fun x =>
          A i x + (univ.inf' univ_nonempty fun k => B x k + C k j)) ≤
        (A i l + B l k) + C k j := fun l _ => by
      have h1 := inf'_le (fun x => A i x + (univ.inf' univ_nonempty fun k => B x k + C k j))
        (mem_univ l)
      have h2 := inf'_le (fun k => B l k + C k j) (mem_univ k)
      linarith
    calc _ ≤ univ.inf' univ_nonempty (fun l => (A i l + B l k) + C k j) :=
          le_inf' _ _ step
      _ = (univ.inf' univ_nonempty (fun l => A i l + B l k)) + C k j :=
          inf'_add_const_right univ univ_nonempty _ (C k j)

/-! ## §3. Distributivity -/

/-- **Left distributivity**: `A ⊗ (B ⊕ C) = (A ⊗ B) ⊕ (A ⊗ C)`.
Bridge: ReLU layer applied to min-pooling = min-pooling of layer outputs. -/
theorem tropMul_tropAdd_left_distrib (A B C : Matrix (Fin n) (Fin n) ℝ) :
    tropMul A (tropAdd B C) = tropAdd (tropMul A B) (tropMul A C) := by
  ext i j; simp only [tropMul, tropAdd]
  simp_rw [add_min]; exact inf'_min_distrib univ univ_nonempty _ _

/-- **Right distributivity**: `(A ⊕ B) ⊗ C = (A ⊗ C) ⊕ (B ⊗ C)`. -/
theorem tropMul_tropAdd_right_distrib (A B C : Matrix (Fin n) (Fin n) ℝ) :
    tropMul (tropAdd A B) C = tropAdd (tropMul A C) (tropMul B C) := by
  ext i j; simp only [tropMul, tropAdd]
  simp_rw [min_add]; exact inf'_min_distrib univ univ_nonempty _ _

/-! ## §4. Tropical Scalar Laws -/

/-- `(c ⊗ A) ⊗ B = c ⊗ (A ⊗ B)`. Bridge: bias shifts commute with composition. -/
theorem tropScalar_tropMul_left (c : ℝ) (A B : Matrix (Fin n) (Fin n) ℝ) :
    tropMul (tropScalar c A) B = tropScalar c (tropMul A B) := by
  ext i j; simp only [tropMul, tropScalar]
  conv_lhs => arg 3; ext k; rw [add_assoc]
  exact inf'_add_const_left univ univ_nonempty _ c

/-- `A ⊗ (c ⊗ B) = c ⊗ (A ⊗ B)`. -/
theorem tropScalar_tropMul_right (c : ℝ) (A B : Matrix (Fin n) (Fin n) ℝ) :
    tropMul A (tropScalar c B) = tropScalar c (tropMul A B) := by
  ext i j; simp only [tropMul, tropScalar]
  have : (fun k => A i k + (c + B k j)) = (fun k => c + (A i k + B k j)) := by
    ext k; ring
  rw [this]
  exact inf'_add_const_left univ univ_nonempty _ c

/-- Tropical scalar composition: `(c₁ + c₂) ⊗ A = c₁ ⊗ (c₂ ⊗ A)`. -/
theorem tropScalar_compose (c₁ c₂ : ℝ) (A : Matrix (Fin n) (Fin n) ℝ) :
    tropScalar (c₁ + c₂) A = tropScalar c₁ (tropScalar c₂ A) := by
  ext i j; simp [tropScalar, add_assoc]

/-- `0 ⊗ A = A`. -/
theorem tropScalar_zero_identity (A : Matrix (Fin n) (Fin n) ℝ) :
    tropScalar 0 A = A := by ext i j; simp [tropScalar]

/-- `c ⊗ (A ⊕ B) = (c ⊗ A) ⊕ (c ⊗ B)`. -/
theorem tropScalar_tropAdd_distrib (c : ℝ) (A B : Matrix (Fin n) (Fin n) ℝ) :
    tropScalar c (tropAdd A B) = tropAdd (tropScalar c A) (tropScalar c B) := by
  ext i j; simp [tropScalar, tropAdd, add_min]

/-! ## §5. Tropical Addition Properties -/

/-- `A ⊕ B = B ⊕ A`. -/
theorem tropAdd_comm (A B : Matrix (Fin n) (Fin n) ℝ) :
    tropAdd A B = tropAdd B A := by ext i j; simp [tropAdd, min_comm]

/-- `(A ⊕ B) ⊕ C = A ⊕ (B ⊕ C)`. -/
theorem tropAdd_assoc (A B C : Matrix (Fin n) (Fin n) ℝ) :
    tropAdd (tropAdd A B) C = tropAdd A (tropAdd B C) := by
  ext i j; simp [tropAdd, min_assoc]

/-- `A ⊕ A = A` (idempotent). -/
theorem tropAdd_idem (A : Matrix (Fin n) (Fin n) ℝ) :
    tropAdd A A = A := by ext i j; simp [tropAdd]

/-! ## §6. Tropical Power Laws -/

@[simp] theorem tropPow_zero (A : Matrix (Fin n) (Fin n) ℝ) :
    tropPow A 0 = A := rfl

@[simp] theorem tropPow_succ (A : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) :
    tropPow A (k + 1) = tropMul A (tropPow A k) := rfl

/-- `(A^k) ⊗ A = A^{k+1}`. Bridge: appending an edge to shortest path. -/
theorem tropPow_right_mul (A : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) :
    tropMul (tropPow A k) A = tropPow A (k + 1) := by
  induction k with
  | zero => rfl
  | succ k ih =>
    show tropMul (tropMul A (tropPow A k)) A = tropMul A (tropPow A (k + 1))
    rw [tropMul_assoc, ih]

/-! ## §7. Commutativity of Powers — Engine of Key Exchange -/

/-- **Powers of commuting matrices commute.**
`A ⊗ B = B ⊗ A ⟹ ∀ k, A^k ⊗ B = B ⊗ A^k`.
Bridge: commuting Hamiltonians have commuting time-evolution operators. -/
theorem tropPow_comm_of_tropMul_comm (A B : Matrix (Fin n) (Fin n) ℝ)
    (hcomm : tropMul A B = tropMul B A) (k : ℕ) :
    tropMul (tropPow A k) B = tropMul B (tropPow A k) := by
  induction k with
  | zero => exact hcomm
  | succ k ih =>
    show tropMul (tropMul A (tropPow A k)) B = tropMul B (tropMul A (tropPow A k))
    rw [tropMul_assoc, ih, ← tropMul_assoc, hcomm, tropMul_assoc]

/-- **Double power commutativity: A^i and B^j commute when A, B commute.**
`A ⊗ B = B ⊗ A ⟹ ∀ i j, A^i ⊗ B^j = B^j ⊗ A^i`.
Bridge: the FUNDAMENTAL theorem enabling the Stickel protocol. -/
theorem tropPow_tropPow_comm_of_comm (A B : Matrix (Fin n) (Fin n) ℝ)
    (hcomm : tropMul A B = tropMul B A) (i j : ℕ) :
    tropMul (tropPow A i) (tropPow B j) = tropMul (tropPow B j) (tropPow A i) := by
  induction j with
  | zero => exact tropPow_comm_of_tropMul_comm A B hcomm i
  | succ j ih =>
    show tropMul (tropPow A i) (tropMul B (tropPow B j)) =
         tropMul (tropMul B (tropPow B j)) (tropPow A i)
    rw [← tropMul_assoc, tropPow_comm_of_tropMul_comm A B hcomm i,
        tropMul_assoc, ih, ← tropMul_assoc]

/-! ## §8. Stickel Protocol Key Agreement -/

/-- **STICKEL KEY AGREEMENT (bilateral form).**
`U ⊗ V = V ⊗ U` where `U = A^a ⊗ B^b` and `V = A^c ⊗ B^d`.
Bridge: post-quantum key exchange correctness. -/
theorem stickel_bilateral_key_agreement
    (A B : Matrix (Fin n) (Fin n) ℝ)
    (hcomm : tropMul A B = tropMul B A) (a b c d : ℕ) :
    tropMul (tropMul (tropPow A a) (tropPow B b))
            (tropMul (tropPow A c) (tropPow B d)) =
    tropMul (tropMul (tropPow A c) (tropPow B d))
            (tropMul (tropPow A a) (tropPow B b)) := by
  conv_lhs => rw [tropMul_assoc, ← tropMul_assoc (tropPow B b),
    tropPow_tropPow_comm_of_comm B A hcomm.symm b c, tropMul_assoc (tropPow A c),
    ← tropMul_assoc]
  conv_rhs => rw [tropMul_assoc, ← tropMul_assoc (tropPow B d),
    tropPow_tropPow_comm_of_comm B A hcomm.symm d a, tropMul_assoc (tropPow A a),
    ← tropMul_assoc]
  rw [tropPow_tropPow_comm_of_comm A A rfl a c,
      tropPow_tropPow_comm_of_comm B B rfl b d]

/-
**STICKEL KEY AGREEMENT (explicit computation form).**
Alice computes `K_A = A^a ⊗ V ⊗ B^b` and Bob computes `K_B = A^c ⊗ U ⊗ B^d`.
These produce the same shared key.
Bridge: post-quantum key exchange correctness via tropical commutativity.
-/
theorem stickel_key_agreement_explicit
    (A B : Matrix (Fin n) (Fin n) ℝ)
    (hcomm : tropMul A B = tropMul B A) (a b c d : ℕ) :
    -- Alice: A^a ⊗ (A^c ⊗ B^d) ⊗ B^b
    tropMul (tropMul (tropPow A a) (tropMul (tropPow A c) (tropPow B d))) (tropPow B b) =
    -- Bob: A^c ⊗ (A^a ⊗ B^b) ⊗ B^d
    tropMul (tropMul (tropPow A c) (tropMul (tropPow A a) (tropPow B b))) (tropPow B d) := by
  simp_all +decide [ ← tropMul_assoc, tropPow_tropPow_comm_of_comm ];
  -- By the associativity of tropMul and the commutativity of tropPow B d and tropPow B b, we can rearrange the terms to show the equality.
  simp [tropMul_assoc, hcomm];
  have h_comm : ∀ i j : ℕ, tropMul (tropPow B i) (tropPow B j) = tropMul (tropPow B j) (tropPow B i) := by
    intros i j
    apply tropPow_tropPow_comm_of_comm B B (by
    rfl) i j;
  rw [ h_comm ]

/-! ## §9. ReLU and Lipschitz Bounds -/

/-- `0 ≤ relu(x)`. -/
theorem relu_nonneg (x : ℝ) : 0 ≤ relu x := le_max_left 0 x

/-
**ReLU is 1-Lipschitz**: `|relu(x) - relu(y)| ≤ |x - y|`.
Bridge: certified robustness for neural networks. Explicit K = 1.
-/
theorem relu_one_lipschitz (x y : ℝ) :
    |relu x - relu y| ≤ |x - y| := by
  cases max_cases ( 0 : ℝ ) x <;> cases max_cases ( 0 : ℝ ) y <;> cases abs_cases ( x - y ) <;> cases abs_cases ( Max.max ( 0 : ℝ ) x - Max.max ( 0 : ℝ ) y ) <;> linarith!

/-- `relu(x) = -min(0, -x)`. Bridge: ReLU = tropical polynomial. -/
theorem relu_tropical_decomposition (x : ℝ) :
    relu x = -min 0 (-x) := by
  simp [relu, max_def, min_def]; split_ifs <;> linarith

/-
**Tropical affine Lipschitz bound**: K = max(|a₁|, |a₂|).
Bridge: certified adversarial robustness for single tropical neuron.
-/
theorem tropical_affine_lipschitz_certified_robustness
    (f : TropicalAffineMap) (x y : ℝ) :
    |f.eval x - f.eval y| ≤ max (|f.a₁|) (|f.a₂|) * |x - y| := by
  by_contra h;
  unfold TropicalAffineMap.eval at h;
  exact h ( by rw [ abs_le ] ; constructor <;> cases max_cases |f.a₁| |f.a₂| <;> cases abs_cases ( x - y ) <;> cases min_cases ( f.a₁ * x + f.b₁ ) ( f.a₂ * x + f.b₂ ) <;> cases min_cases ( f.a₁ * y + f.b₁ ) ( f.a₂ * y + f.b₂ ) <;> nlinarith [ abs_le.mp ( le_max_left |f.a₁| |f.a₂| ), abs_le.mp ( le_max_right |f.a₁| |f.a₂| ) ] )

/-
**Tropical polynomial Lipschitz bound**: K = max_i |dᵢ|.
Bridge: CERTIFIED ROBUSTNESS for tropical neural networks.
-/
theorem tropPolyEval_lipschitz_certified_robustness
    {m : ℕ} [NeZero m] (c d : Fin m → ℝ) (x y : ℝ) :
    |tropPolyEval c d x - tropPolyEval c d y| ≤
    Finset.sup' univ univ_nonempty (fun i => |d i|) * |x - y| := by
  -- Prove that |inf' f - inf' g| ≤ sup' |f - g| for any functions f, g.
  have h_inf_diff_le_sup (f g : Fin m → ℝ) : abs ((Finset.univ.inf' Finset.univ_nonempty f) - (Finset.univ.inf' Finset.univ_nonempty g)) ≤ (Finset.univ.sup' Finset.univ_nonempty (fun i => abs (f i - g i))) := by
    rw [ abs_sub_le_iff ];
    constructor <;> rw [ sub_le_iff_le_add' ];
    · rw [ Finset.inf'_le_iff ];
      obtain ⟨ i, hi ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty g;
      exact ⟨ i, hi.1, by linarith [ abs_le.mp ( Finset.le_sup' ( fun i => |f i - g i| ) hi.1 ) ] ⟩;
    · rw [ ← sub_le_iff_le_add ];
      simp +decide [ Finset.inf'_le, Finset.le_sup' ];
      exact fun i => ⟨ i, by linarith [ abs_le.mp ( Finset.le_sup' ( fun i => |f i - g i| ) ( Finset.mem_univ i ) ) ] ⟩;
  refine le_trans ( h_inf_diff_le_sup _ _ ) ?_;
  simp +decide [ mul_sub, abs_mul ];
  exact fun i => by rw [ ← mul_sub, abs_mul ] ; exact mul_le_mul_of_nonneg_right ( Finset.le_sup' ( fun i => |d i| ) ( Finset.mem_univ i ) ) ( abs_nonneg _ ) ;

/-- Certified robustness radius is positive. -/
theorem certified_robustness_radius_pos {K m : ℝ} (hK : 0 < K) (hm : 0 < m) :
    0 < certifiedRobustnessRadius K m := by
  simp [certifiedRobustnessRadius, not_le.mpr hK]; exact div_pos hm hK

/-- **Lipschitz preservation under perturbation.**
Bridge: `‖δ‖ < margin/K ⟹ classifier(x + δ) > 0`. -/
theorem lipschitz_post_quantum_security_preservation
    (f : TropicalLipschitzFn) (x₀ x : ℝ)
    (hmargin : 0 < f.f x₀) (hK : 0 < f.K)
    (hpert : |x - x₀| < f.f x₀ / f.K) :
    0 < f.f x := by
  have h1 := f.lipschitz x x₀
  have h2 : f.K * |x - x₀| < f.f x₀ := by
    calc f.K * |x - x₀| < f.K * (f.f x₀ / f.K) :=
          mul_lt_mul_of_pos_left hpert hK
      _ = f.f x₀ := by field_simp
  linarith [abs_sub_lt_iff.mp (lt_of_le_of_lt h1 h2)]

/-- **Composition of Lipschitz functions**: K(f ∘ g) ≤ K(f) · K(g).
Bridge: deep ReLU network Lipschitz analysis. Explicit: total K = ∏ Kᵢ. -/
theorem tropicalLipschitz_composition
    (f g : TropicalLipschitzFn) :
    ∀ x y : ℝ, |f.f (g.f x) - f.f (g.f y)| ≤ (f.K * g.K) * |x - y| := by
  intro x y
  calc |f.f (g.f x) - f.f (g.f y)|
      ≤ f.K * |g.f x - g.f y| := f.lipschitz _ _
    _ ≤ f.K * (g.K * |x - y|) :=
        mul_le_mul_of_nonneg_left (g.lipschitz x y) f.K_nonneg
    _ = (f.K * g.K) * |x - y| := by ring

/-! ## §10. Distance and Norm -/

/-- `tropDist A B = tropDist B A`. -/
theorem tropDist_symm (A B : Matrix (Fin n) (Fin n) ℝ) :
    tropDist A B = tropDist B A := by
  simp only [tropDist, abs_sub_comm]

/-
Post-quantum security grows with dimension.
Explicit: security ≥ n · log₂(Δ) bits.
-/
theorem post_quantum_nist_security_dimension_bound
    (n_dim : ℕ) (gap : ℝ) (hgap : 2 ≤ gap) (hn : 128 ≤ n_dim) :
    128 ≤ postQuantumSecurityBits n_dim gap := by
  exact le_trans ( by norm_num ) ( mul_le_mul_of_nonneg_right ( mul_le_mul_of_nonneg_right ( Nat.cast_le.mpr hn ) ( Real.log_nonneg ( by linarith ) ) ) ( by positivity ) ) |> le_trans <| mul_le_mul_of_nonneg_right ( mul_le_mul_of_nonneg_left ( Real.log_le_log ( by linarith ) hgap ) <| by positivity ) ( by positivity )

end TropicalMatrix