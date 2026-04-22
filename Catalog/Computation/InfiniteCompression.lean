import Mathlib

/-! # CatalogBuild.Computation.InfiniteCompression

Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 22
-/


noncomputable section

/-- The denominator u² + v² + 1 is never zero. -/
theorem stereo_denom_ne_zero (u v : ℝ) : u ^ 2 + v ^ 2 + 1 ≠ 0 := by
  nlinarith [sq_nonneg u, sq_nonneg v]




/-- [Section: # CatalogBuild.Computation.InfiniteCompression
Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 22] -/
theorem inverse_stereo_on_sphere (u v : ℝ) :
    (2 * u / (u ^ 2 + v ^ 2 + 1)) ^ 2 +
    (2 * v / (u ^ 2 + v ^ 2 + 1)) ^ 2 +
    ((u ^ 2 + v ^ 2 - 1) / (u ^ 2 + v ^ 2 + 1)) ^ 2 = 1 := by
  -- Combine the fractions over a common denominator.
  field_simp
  ring




/-- The 1D denominator t² + 1 is always positive. -/
theorem stereo_1d_denom_pos (t : ℝ) : 0 < t ^ 2 + 1 := by
  nlinarith [sq_nonneg t]




/-- The 1D denominator t² + 1 is never zero. -/
theorem stereo_1d_denom_ne_zero (t : ℝ) : t ^ 2 + 1 ≠ 0 := by
  nlinarith [sq_nonneg t]




/-- [Section: # CatalogBuild.Computation.InfiniteCompression
Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 22] -/
theorem inverse_stereo_on_circle (t : ℝ) :
    (2 * t / (t ^ 2 + 1)) ^ 2 +
    ((t ^ 2 - 1) / (t ^ 2 + 1)) ^ 2 = 1 := by
  -- Combine the fractions over a common denominator.
  field_simp
  ring




theorem stereo_roundtrip (t : ℝ) :
    (2 * t / (t ^ 2 + 1)) / (1 - (t ^ 2 - 1) / (t ^ 2 + 1)) = t := by
  field_simp;
  ring




theorem stereo_inverse_forward_fst (x y : ℝ) (hunit : x ^ 2 + y ^ 2 = 1)
    (hy : 1 + y ≠ 0) :
    2 * (x / (1 + y)) / ((x / (1 + y)) ^ 2 + 1) = x := by
  grind




theorem stereo_inverse_forward_snd (x y : ℝ) (hunit : x ^ 2 + y ^ 2 = 1)
    (hy : 1 - y ≠ 0) :
    ((x / (1 - y)) ^ 2 - 1) / ((x / (1 - y)) ^ 2 + 1) = y := by
  grind




theorem stereo_z_bounded (u v : ℝ) :
    -1 ≤ (u ^ 2 + v ^ 2 - 1) / (u ^ 2 + v ^ 2 + 1) ∧
    (u ^ 2 + v ^ 2 - 1) / (u ^ 2 + v ^ 2 + 1) ≤ 1 := by
  exact ⟨ by rw [ le_div_iff₀ <| by positivity ] ; nlinarith, by rw [ div_le_iff₀ <| by positivity ] ; nlinarith ⟩




/-- At the origin (u=0, v=0), Z = −1 (south pole). -/
theorem stereo_origin_south_pole :
    ((0 : ℝ) ^ 2 + (0 : ℝ) ^ 2 - 1) / ((0 : ℝ) ^ 2 + (0 : ℝ) ^ 2 + 1) = -1 := by
  norm_num




theorem solid_angle_nonneg (u v : ℝ) :
    0 ≤ 1 - (u ^ 2 + v ^ 2 - 1) / (u ^ 2 + v ^ 2 + 1) := by
  exact sub_nonneg_of_le ( div_le_one_of_le₀ ( by nlinarith ) ( by nlinarith ) )




theorem solid_angle_formula (u v : ℝ) :
    1 - (u ^ 2 + v ^ 2 - 1) / (u ^ 2 + v ^ 2 + 1) =
    2 / (u ^ 2 + v ^ 2 + 1) := by
  rw [ one_sub_div ] <;> ring ; positivity




theorem solid_angle_decreasing (r₁ r₂ : ℝ) (hr₁ : 0 ≤ r₁) (_hr₂ : 0 ≤ r₂)
    (h : r₁ ≤ r₂) :
    2 / (r₂ ^ 2 + 1) ≤ 2 / (r₁ ^ 2 + 1) := by
  gcongr




theorem compression_pigeonhole {M N : ℕ} (h : N < M) :
    ¬ ∃ f : Fin M → Fin N, Function.Injective f := by
  exact fun ⟨ f, hf ⟩ => absurd ( Nat.card_le_card_of_injective f hf ) ( by simpa )




theorem stereo_compression_impossible (n : ℕ) (hn : 1 ≤ n) :
    ¬ ∃ f : Fin (2^n) → Fin (2^(n-1)), Function.Injective f := by
  convert compression_pigeonhole _;
  exact pow_lt_pow_right₀ ( by decide ) ( Nat.pred_lt ( ne_bot_of_gt hn ) )




theorem lossless_is_injective {α β : Type*} (encode : α → β) (decode : β → α)
    (h : ∀ x, decode (encode x) = x) : Function.Injective encode := by
  exact fun x y hxy => h x ▸ h y ▸ hxy ▸ rfl




theorem infinite_compression_impossible (n : ℕ) (hn : 1 ≤ n)
    (encode : Fin (2^n) → Fin (2^(n-1)))
    (decode : Fin (2^(n-1)) → Fin (2^n))
    (h : ∀ x, decode (encode x) = x) : False := by
  exact stereo_compression_impossible n hn ⟨encode, lossless_is_injective encode decode h⟩




theorem quantization_resolution (M k : ℕ) (h : 2 ^ k < M) :
    ¬ ∃ f : Fin M → Fin (2 ^ k), Function.Injective f := by
  exact fun ⟨ f, hf ⟩ => absurd ( Fintype.card_le_of_injective f hf ) ( by simpa using h )




theorem circle_mul_on_circle (x₁ y₁ x₂ y₂ : ℝ)
    (h₁ : x₁ ^ 2 + y₁ ^ 2 = 1) (h₂ : x₂ ^ 2 + y₂ ^ 2 = 1) :
    (x₁ * x₂ - y₁ * y₂) ^ 2 + (x₁ * y₂ + y₁ * x₂) ^ 2 = 1 := by
  linear_combination' h₁ * h₂




theorem tangent_addition (a b : ℝ) (_hab : 1 - a * b ≠ 0) :
    let t := (a + b) / (1 - a * b)
    (2 * t / (t ^ 2 + 1)) ^ 2 + ((t ^ 2 - 1) / (t ^ 2 + 1)) ^ 2 = 1 := by
  exact inverse_stereo_on_circle _




theorem density_diverges (n : ℕ) (hn : 0 < n) (B : ℝ) :
    ∃ Ω : ℝ, 0 < Ω ∧ (n : ℝ) / Ω > B := by
  exact ⟨ n / ( |B| + 1 ), by positivity, by rw [ div_div_cancel₀ ( by positivity ) ] ; cases abs_cases B <;> linarith ⟩




theorem density_vs_pigeonhole (n k : ℕ) (hk : k < n) :
    ¬ ∃ f : Fin (2^n) → Fin (2^k), Function.Injective f := by
  convert compression_pigeonhole _;
  exact pow_lt_pow_right₀ ( by norm_num ) hk




end
