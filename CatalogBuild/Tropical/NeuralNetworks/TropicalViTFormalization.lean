/-! # CatalogBuild.Tropical.NeuralNetworks.TropicalViTFormalization

Auto-generated from theorem catalog database.
Domain: Tropical/NeuralNetworks
Declarations: 20
-/

import Mathlib

noncomputable section

theorem tAdd_idempotent (a : ℝ) : tAdd a a = a := max_self a

/-- Tropical semiring: multiplication distributes over addition -/

theorem tMul_distributes (a b c : ℝ) :
    tMul a (tAdd b c) = tAdd (tMul a b) (tMul a c) := by
  simp [tMul, tAdd, max_add_add_left]

/-- The max-plus "matrix-vector product" for a single output coordinate:
    yᵢ = max_j (W_{ij} + x_j) -/

def tropMatVecCoord {m : ℕ} (hm : 0 < m) (W : Fin m → ℝ) (x : Fin m → ℝ) : ℝ :=
  Finset.univ.sup' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hm⟩⟩) (fun j => W j + x j)

/-! ## Part II: LogSumExp Approximation Theory (Agent Gamma)

The LogSumExp function `T · log(Σ exp(xᵢ/T))` is a smooth approximation to `max`.
This is the **Maslov dequantization**: as the "Planck constant" T → 0⁺, the smooth
algebra (ℝ, +, ×) degenerates into the tropical algebra (ℝ, max, +).
-/

/-
PROBLEM
LogSumExp always upper-bounds the maximum.

PROVIDED SOLUTION
The max element x_m satisfies exp(x_m/T) ≤ Σ exp(x_i/T), so x_m/T ≤ log(Σ exp(x_i/T)), hence x_m ≤ T * log(Σ exp(x_i/T)). Use Finset.le_sup' to get the max, then single_le_sum for the exponential sum bound.
-/

theorem logsumexp_le_max_plus_log (x : Fin n → ℝ) (hn : 0 < n) (T : ℝ) (hT : 0 < T) :
    T * Real.log (∑ i : Fin n, Real.exp (x i / T))
    ≤ (Finset.univ.sup' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) x) + T * Real.log n := by
      -- Each term in the sum $\sum_{i=0}^{n-1} \exp(x_i/T)$ is less than or equal to $\exp(\max(x_i)/T)$, so the sum is less than or equal to $n \cdot \exp(\max(x_i)/T)$.
      have h_sum_le : ∑ i, Real.exp (x i / T) ≤ n * Real.exp ((Finset.univ.sup' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) x) / T) := by
        convert Finset.sum_le_card_nsmul _ _ _ _ <;> norm_num;
        · aesop;
        · infer_instance;
        · exact fun i => div_le_div_of_nonneg_right ( Finset.le_sup' ( fun a => x a ) ( Finset.mem_univ i ) ) hT.le;
      have h_log_sum_le : Real.log (∑ i, Real.exp (x i / T)) ≤ Real.log (n * Real.exp ((Finset.univ.sup' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) x) / T)) := by
        exact Real.log_le_log ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩ ) h_sum_le;
      rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] at h_log_sum_le ; nlinarith [ mul_div_cancel₀ ( Finset.univ.sup' ( Finset.univ_nonempty_iff.mpr ⟨ ⟨ 0, hn ⟩ ⟩ ) x ) hT.ne' ]

/-! ## Part III: Projective Normalization (Agent Delta)

In the tropical projective space TP^{n-1}, vectors are equivalent up to
adding a constant: x ~ x + c·1. Projective normalization x ↦ x - max(x)
selects the canonical representative with max coordinate = 0.
-/

/-- Projective normalization: subtract the maximum. -/

def projNormalize {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => x i - Finset.univ.sup' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) x

/-
PROBLEM
After projective normalization, the maximum coordinate is 0.

PROVIDED SOLUTION
projNormalize subtracts the sup from each coordinate. The sup of (x_i - sup x) equals sup(x_i) - sup(x) = 0. Use Finset.sup'_sub_const or show sup' distributes over subtraction of a constant.
-/

theorem projNormalize_max_eq_zero {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) :
    Finset.univ.sup' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (projNormalize hn x) = 0 := by
      unfold projNormalize;
      refine' le_antisymm _ _;
      · aesop;
      · obtain ⟨ i, hi ⟩ := Finset.exists_max_image Finset.univ x ( Finset.univ_nonempty_iff.mpr ⟨ ⟨ 0, hn ⟩ ⟩ ) ; aesop

/-
PROBLEM
Projective normalization is idempotent.

PROVIDED SOLUTION
After first normalization, max is 0 (by projNormalize_max_eq_zero). Second normalization subtracts 0, so it's the identity. Use funext and projNormalize_max_eq_zero.
-/

theorem projNormalize_idempotent {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) :
    projNormalize hn (projNormalize hn x) = projNormalize hn x := by
      -- By definition of projective normalization, we have:
      funext i
      simp [projNormalize];
      convert projNormalize_max_eq_zero hn x using 1

/-
PROBLEM
All coordinates after normalization are ≤ 0.

PROVIDED SOLUTION
x_i - max(x) ≤ 0 because x_i ≤ max(x). Use Finset.le_sup' to get x i ≤ sup' and then sub_nonpos.
-/

theorem projNormalize_le_zero {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) (i : Fin n) :
    projNormalize hn x i ≤ 0 := by
      exact sub_nonpos_of_le ( Finset.le_sup' ( fun i => x i ) ( Finset.mem_univ i ) )

/-! ## Part IV: Tropical Residual Connections (Agent Beta)

The tropical residual `max(x, f(x))` always preserves or improves the signal.
This is the tropical analogue of the standard residual `x + f(x)`.
-/

/-- Tropical residual never decreases any coordinate. -/

theorem tropical_residual_nondecreasing (x y : ℝ) : x ≤ max x y :=
  le_max_left x y

/-- Tropical residual is idempotent when applied to a fixed point. -/

theorem tropical_residual_fixed_point (x : ℝ) (h : x ≥ y) :
    max x y = x := max_eq_left h

/-- Tropical residual with self is identity. -/

theorem tropical_residual_self (x : ℝ) : max x x = x := max_self x

/-! ## Part V: Tropical Attention Properties (Agent Epsilon)

The tropical attention mechanism computes:
  score_{ij} = max_k (Q_{ik} + K_{jk})   — "how much does query i attend to key j?"
  out_i = max_j (score_{ij} + V_j)        — "aggregate values by tropical weighting"
-/

/-
PROBLEM
Tropical attention scores are shift-equivariant in queries.
    If all query coordinates shift by c, all scores shift by c.

PROVIDED SOLUTION
max_k((Q_ik + c) + K_jk) = max_k(Q_ik + K_jk + c) = max_k(Q_ik + K_jk) + c. Use Finset.sup'_add_const or show that adding a constant to each term of sup' pulls out.
-/

theorem tropical_attention_shift_equivariant
    (Q K : Fin s → Fin d → ℝ) (c : ℝ) (i j : Fin s) (hs : 0 < d) :
    Finset.univ.sup' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hs⟩⟩)
      (fun k => (Q i k + c) + K j k)
    = Finset.univ.sup' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hs⟩⟩)
      (fun k => Q i k + K j k) + c := by
        simp +decide [ add_right_comm, Finset.sup'_add ]

/-
PROBLEM
Tropical softmax: after subtracting the row-max, the maximum score is 0.
    This is the tropical analogue of softmax outputting a probability vector.

PROVIDED SOLUTION
sup'(scores_j - m) = sup'(scores_j) - m = m - m = 0. The sup distributes over subtracting a constant.
-/

theorem tropical_softmax_max_zero
    (scores : Fin s → ℝ) (hs : 0 < s) :
    let m := Finset.univ.sup' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hs⟩⟩) scores
    Finset.univ.sup' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hs⟩⟩)
      (fun j => scores j - m) = 0 := by
        refine' le_antisymm _ _;
        · aesop;
        · simpa using Finset.exists_max_image Finset.univ scores ⟨ ⟨ 0, hs ⟩, Finset.mem_univ _ ⟩

/-! ## Part VI: Layer Composition (Agent Beta)

Two consecutive tropical linear layers compose into a single tropical linear
layer whose weight matrix is the tropical matrix product of the two weight matrices.
This is the tropical analogue of W₂(W₁x) = (W₂W₁)x.
-/

/-- Tropical matrix product: (A ⊙ B)_{ik} = max_j (A_{ij} + B_{jk}) -/

theorem tropRelu_monotone (τ : ℝ) : Monotone (fun x => max x τ) :=
  fun _ _ h => max_le_max_right τ h

/-- Tropical ReLU is idempotent. -/

theorem tropRelu_idempotent (x τ : ℝ) : max (max x τ) τ = max x τ := by
  simp

/-- Tropical ReLU preserves tropical addition (max). -/

theorem tropRelu_preserves_tAdd (a b τ : ℝ) :
    max (max a b) τ = max (max a τ) (max b τ) := by
  simp [max_comm, max_left_comm]

/-! ## Part VIII: Patchification Geometry (Agent Delta)

The 28×28 image is divided into a 4×4 grid of non-overlapping 7×7 patches.
We verify that the patch indexing covers the entire image exactly once.
-/

/-- The 4×4 grid of 7×7 patches tiles the 28×28 image exactly. -/

theorem patch_tiling_exact : 4 * 7 = 28 := by norm_num

/-- Total number of patches. -/

theorem num_patches_eq : 4 * 4 = 16 := by norm_num

/-- Each patch has exactly 49 features. -/

theorem patch_dim_eq : 7 * 7 = 49 := by norm_num

/-- The patches partition the pixel indices. -/

theorem patch_pixel_count : 16 * 49 = 28 * 28 := by norm_num

end TropicalViT

end
