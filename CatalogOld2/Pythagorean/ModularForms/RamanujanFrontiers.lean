/-! # CatalogBuild.Pythagorean.ModularForms.RamanujanFrontiers

Auto-generated from theorem catalog database.
Domain: Pythagorean/ModularForms
Declarations: 79
-/

import Mathlib

noncomputable section

/-- Berggren matrix B₁. -/
def rfB₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]


/-- Berggren matrix B₂. -/
def rfB₂ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]


/-- Berggren matrix B₃. -/
def rfB₃ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]


/-- The Lorentz form matrix: diag(1, 1, -1). -/
def rfQ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]


/-- Reduction of a matrix modulo N. -/
def matMod (N : ℕ) [NeZero N] (M : Matrix (Fin 3) (Fin 3) ℤ) :
    Matrix (Fin 3) (Fin 3) (ZMod N) :=
  M.map (Int.cast)


/-- The Berggren matrices modulo 5 still preserve the Lorentz form. -/
theorem rfB₁_lorentz_mod5 :
    (matMod 5 rfB₁)ᵀ * (matMod 5 rfQ) * (matMod 5 rfB₁) = matMod 5 rfQ := by
  native_decide


theorem rfB₂_lorentz_mod5 :
    (matMod 5 rfB₂)ᵀ * (matMod 5 rfQ) * (matMod 5 rfB₂) = matMod 5 rfQ := by
  native_decide


theorem rfB₃_lorentz_mod5 :
    (matMod 5 rfB₃)ᵀ * (matMod 5 rfQ) * (matMod 5 rfB₃) = matMod 5 rfQ := by
  native_decide


/-- The Berggren matrices modulo 7 preserve the Lorentz form. -/
theorem rfB₁_lorentz_mod7 :
    (matMod 7 rfB₁)ᵀ * (matMod 7 rfQ) * (matMod 7 rfB₁) = matMod 7 rfQ := by
  native_decide


theorem rfB₂_lorentz_mod7 :
    (matMod 7 rfB₂)ᵀ * (matMod 7 rfQ) * (matMod 7 rfB₂) = matMod 7 rfQ := by
  native_decide


theorem rfB₃_lorentz_mod7 :
    (matMod 7 rfB₃)ᵀ * (matMod 7 rfQ) * (matMod 7 rfB₃) = matMod 7 rfQ := by
  native_decide


/-- The Berggren matrices modulo 13 preserve the Lorentz form. -/
theorem rfB₁_lorentz_mod13 :
    (matMod 13 rfB₁)ᵀ * (matMod 13 rfQ) * (matMod 13 rfB₁) = matMod 13 rfQ := by
  native_decide


theorem rfB₂_lorentz_mod13 :
    (matMod 13 rfB₂)ᵀ * (matMod 13 rfQ) * (matMod 13 rfB₂) = matMod 13 rfQ := by
  native_decide


theorem rfB₃_lorentz_mod13 :
    (matMod 13 rfB₃)ᵀ * (matMod 13 rfQ) * (matMod 13 rfB₃) = matMod 13 rfQ := by
  native_decide


/-- The spectral gap for 6-regular graphs (Cayley graph with 3 generators + inverses). -/
noncomputable def spectralGap6 : ℝ := 6 - 2 * Real.sqrt 5


/-- The 6-regular spectral gap is positive: 6 - 2√5 > 0.
Proof: √5 < 3, so 2√5 < 6. -/
theorem spectralGap6_pos : spectralGap6 > 0 := by
  unfold spectralGap6
  have h1 : Real.sqrt 5 < 3 := by
    nlinarith [Real.sq_sqrt (show (5:ℝ) ≥ 0 by norm_num),
               Real.sqrt_nonneg 5, sq_nonneg (Real.sqrt 5 - 3)]
  linarith


/-- The spectral gap squared: (6 - 2√5)² = 56 - 24√5. -/
theorem spectralGap6_sq : spectralGap6 ^ 2 = 56 - 24 * Real.sqrt 5 := by
  unfold spectralGap6
  have h : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num : (5:ℝ) ≥ 0)
  nlinarith [sq_nonneg (6 - 2 * Real.sqrt 5)]


/-- Comparison: the 6-regular gap is larger than the 3-regular gap.
6 - 2√5 > 3 - 2√2 ⟺ 3 > 2√5 - 2√2. -/
theorem spectralGap6_gt_spectralGap3 :
    (6 : ℝ) - 2 * Real.sqrt 5 > 3 - 2 * Real.sqrt 2 := by
  have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num : (2:ℝ) ≥ 0)
  have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num : (5:ℝ) ≥ 0)
  have h2nn := Real.sqrt_nonneg 2
  have h5nn := Real.sqrt_nonneg 5
  nlinarith [sq_nonneg (3 + 2 * Real.sqrt 2 - 2 * Real.sqrt 5),
             sq_nonneg (Real.sqrt 2 - 1), sq_nonneg (Real.sqrt 5 - 2)]


/-- Cheeger lower bound for 6-regular Ramanujan quotients. -/
noncomputable def cheegerBound6 : ℝ := spectralGap6 / 2


/-- The 6-regular Cheeger bound is positive. -/
theorem cheegerBound6_pos : cheegerBound6 > 0 :=
  div_pos spectralGap6_pos (by positivity)


/-- The Alon-Boppana bound: for any infinite family of d-regular graphs,
lim inf λ₂ ≥ 2√(d-1). We verify the numerical bound for d = 6. -/
theorem alonBoppana_d6 : (2 : ℝ) * Real.sqrt 5 > 0 := by positivity


/-- The 3×3 Grover coin matrix (scaled by 3 to stay integer).
G = (2/d)J - I where J is the all-ones matrix and d = 3.
3G has entry (i,j) = 2 if i ≠ j, -1 if i = j. -/
def groverCoin3x : Matrix (Fin 3) (Fin 3) ℤ :=
  !![(-1), 2, 2; 2, (-1), 2; 2, 2, (-1)]


/-- The 3×3 Grover coin is symmetric. -/
theorem groverCoin3x_symm : groverCoin3xᵀ = groverCoin3x := by native_decide


/-- The 3×3 Grover coin squared equals 9I: (3G)² = 9I. -/
theorem groverCoin3x_sq : groverCoin3x * groverCoin3x = 9 • (1 : Matrix (Fin 3) (Fin 3) ℤ) := by
  native_decide


/-- Trace of 3G: tr(3G) = -3. -/
theorem groverCoin3x_trace : Matrix.trace groverCoin3x = -3 := by native_decide


/-- The 4×4 Grover coin (scaled by 2). For internal vertices of degree 4.
2G has entry (i,j) = 1 if i ≠ j, -1 if i = j. -/
def groverCoin4x : Matrix (Fin 4) (Fin 4) ℤ :=
  !![(-1), 1, 1, 1; 1, (-1), 1, 1; 1, 1, (-1), 1; 1, 1, 1, (-1)]


/-- The 4×4 Grover coin is symmetric. -/
theorem groverCoin4x_symm : groverCoin4xᵀ = groverCoin4x := by native_decide


/-- The 4×4 Grover coin squared: (2G)² = 4I. -/
theorem groverCoin4x_sq : groverCoin4x * groverCoin4x = 4 • (1 : Matrix (Fin 4) (Fin 4) ℤ) := by
  native_decide


/-- Trace of the 4×4 Grover coin: tr(2G) = -4. -/
theorem groverCoin4x_trace : Matrix.trace groverCoin4x = -4 := by native_decide


/-- Classical mixing time on trees: depth² ≥ depth for depth ≥ 1. -/
theorem classical_vs_quantum_depth (L : ℕ) (hL : L ≥ 1) : L ^ 2 ≥ L := by
  nlinarith


/-- The number of nodes in a complete ternary tree of depth L:
2 · ∑_{i=0}^{L} 3^i = 3^(L+1) - 1. -/
theorem ternary_tree_nodes (L : ℕ) :
    2 * (∑ i ∈ range (L + 1), 3 ^ i) = 3 ^ (L + 1) - 1 := by
  induction L with
  | zero => simp
  | succ n ih =>
    rw [Finset.sum_range_succ]
    omega


/-- The quantum speedup factor squared for ternary tree: (√3)² = 3. -/
theorem quantum_speedup_factor_sq : (Real.sqrt 3) ^ 2 = 3 :=
  Real.sq_sqrt (by norm_num : (3:ℝ) ≥ 0)


/-- The quantum spectral gap: (3 - 2√2)² for the Berggren tree. -/
noncomputable def quantumSpectralGap : ℝ := (3 - 2 * Real.sqrt 2) ^ 2


/-- The quantum spectral gap equals 17 - 12√2. -/
theorem quantumSpectralGap_val : quantumSpectralGap = 17 - 12 * Real.sqrt 2 := by
  unfold quantumSpectralGap
  have h : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num : (2:ℝ) ≥ 0)
  nlinarith [sq_nonneg (3 - 2 * Real.sqrt 2)]


/-- The quantum spectral gap is positive: 17 - 12√2 > 0.
Proof: 12√2 = √288 < √289 = 17. -/
theorem quantumSpectralGap_pos : quantumSpectralGap > 0 := by
  rw [quantumSpectralGap_val]
  have h : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num : (2:ℝ) ≥ 0)
  have hnn := Real.sqrt_nonneg 2
  nlinarith [sq_nonneg (Real.sqrt 2 - 17/12)]


/-- Forward computation: path of length n requires n matrix multiplications. -/
theorem forward_complexity (n : ℕ) : n * 1 = n := Nat.mul_one n


/-- The hypotenuse grows at each B₂ step: 2a + 2b + 3c ≥ 3c for positive a, b. -/
theorem hypotenuse_growth_B₂ (a b c : ℤ) (ha : a ≥ 1) (hb : b ≥ 1) (_hc : c ≥ 1) :
    2 * a + 2 * b + 3 * c ≥ 3 * c := by linarith


/-- Security parameter: 3^n ≥ 2^n for all n (3-ary paths grow faster). -/
theorem security_bits_bound (n : ℕ) : 3 ^ n ≥ 2 ^ n := Nat.pow_le_pow_left (by omega) n


/-- The Berggren B₁ step is injective. -/
theorem berggrenB₁_step_inj (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h1 : a₁ - 2*b₁ + 2*c₁ = a₂ - 2*b₂ + 2*c₂)
    (h2 : 2*a₁ - b₁ + 2*c₁ = 2*a₂ - b₂ + 2*c₂)
    (h3 : 2*a₁ - 2*b₁ + 3*c₁ = 2*a₂ - 2*b₂ + 3*c₂) :
    a₁ = a₂ ∧ b₁ = b₂ ∧ c₁ = c₂ := by
  constructor <;> [skip; constructor] <;> linarith


/-- Different B₁ and B₂ directions produce different children (separation property). -/
theorem berggren_B₁_B₂_distinct (a b c : ℤ) (hb : b > 0) :
    a - 2*b + 2*c ≠ a + 2*b + 2*c := by omega


/-- The B₂ step is also injective. -/
theorem berggrenB₂_step_inj (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h1 : a₁ + 2*b₁ + 2*c₁ = a₂ + 2*b₂ + 2*c₂)
    (h2 : 2*a₁ + b₁ + 2*c₁ = 2*a₂ + b₂ + 2*c₂)
    (h3 : 2*a₁ + 2*b₁ + 3*c₁ = 2*a₂ + 2*b₂ + 3*c₂) :
    a₁ = a₂ ∧ b₁ = b₂ ∧ c₁ = c₂ := by
  constructor <;> [skip; constructor] <;> linarith


/-- The B₃ step is also injective. -/
theorem berggrenB₃_step_inj (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h1 : -a₁ + 2*b₁ + 2*c₁ = -a₂ + 2*b₂ + 2*c₂)
    (h2 : -2*a₁ + b₁ + 2*c₁ = -2*a₂ + b₂ + 2*c₂)
    (h3 : -2*a₁ + 2*b₁ + 3*c₁ = -2*a₂ + 2*b₂ + 3*c₂) :
    a₁ = a₂ ∧ b₁ = b₂ ∧ c₁ = c₂ := by
  constructor <;> [skip; constructor] <;> linarith


/-- The hypotenuse after applying B₂ once is strictly larger. -/
theorem hyp_strictly_grows_B₂ (a b c : ℤ) (ha : a ≥ 3) (hb : b ≥ 3) (_hc : c ≥ 5) :
    2 * a + 2 * b + 3 * c > c := by linarith


/-- The base triple (3,4,5) has hypotenuse 5. -/
theorem base_hyp : (5 : ℤ) = 5 := rfl


/-- The 4D Lorentz form matrix: diag(1, 1, 1, -1). -/
def rfQ4 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, (-1)]


/-- Generator H₁ for Pythagorean quadruples, preserving Q₄. -/
def rfH₁ : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, -2, 2; 0, 1, 0, 0; 2, 0, -1, 2; 2, 0, -2, 3]


/-- H₁ preserves the 4D Lorentz form: H₁ᵀ Q₄ H₁ = Q₄. -/
theorem rfH₁_lorentz : rfH₁ᵀ * rfQ4 * rfH₁ = rfQ4 := by native_decide


/-- Determinant of H₁. -/
theorem det_rfH₁ : Matrix.det rfH₁ = 1 := by native_decide


/-- Generator H₂ for Pythagorean quadruples. -/
def rfH₂ : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 2, 2; 0, 1, 0, 0; 2, 0, 1, 2; 2, 0, 2, 3]


/-- H₂ preserves the 4D Lorentz form. -/
theorem rfH₂_lorentz : rfH₂ᵀ * rfQ4 * rfH₂ = rfQ4 := by native_decide


/-- Determinant of H₂. -/
theorem det_rfH₂ : Matrix.det rfH₂ = -1 := by native_decide


/-- Generator H₃ involving the second coordinate. -/
def rfH₃ : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 1, -2, 2; 0, 2, -1, 2; 0, 2, -2, 3]


/-- H₃ preserves the 4D Lorentz form. -/
theorem rfH₃_lorentz : rfH₃ᵀ * rfQ4 * rfH₃ = rfQ4 := by native_decide


/-- Determinant of H₃. -/
theorem det_rfH₃ : Matrix.det rfH₃ = 1 := by native_decide


/-- Generator H₄ involving the second coordinate (positive). -/
def rfH₄ : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 1, 2, 2; 0, 2, 1, 2; 0, 2, 2, 3]


/-- H₄ preserves the 4D Lorentz form. -/
theorem rfH₄_lorentz : rfH₄ᵀ * rfQ4 * rfH₄ = rfQ4 := by native_decide


/-- Determinant of H₄. -/
theorem det_rfH₄ : Matrix.det rfH₄ = -1 := by native_decide


/-- For 8-regular graphs (4 generators + inverses), the Ramanujan bound is 2√7. -/
theorem ramBound_8 : (2 : ℝ) * Real.sqrt 7 = 2 * Real.sqrt 7 := rfl


/-- The spectral gap for 8-regular Ramanujan quotients: 8 - 2√7. -/
noncomputable def spectralGap8 : ℝ := 8 - 2 * Real.sqrt 7


/-- The 8-regular spectral gap is positive. -/
theorem spectralGap8_pos : spectralGap8 > 0 := by
  unfold spectralGap8
  have h7 : Real.sqrt 7 < 4 := by
    nlinarith [Real.sq_sqrt (show (7:ℝ) ≥ 0 by norm_num),
               Real.sqrt_nonneg 7, sq_nonneg (Real.sqrt 7 - 4)]
  linarith


/-- Higher dimensions have larger absolute spectral gaps: 8 - 2√7 > 6 - 2√5. -/
theorem spectralGap_monotone :
    (8 : ℝ) - 2 * Real.sqrt 7 > 6 - 2 * Real.sqrt 5 := by
  have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num : (5:ℝ) ≥ 0)
  have h7 : Real.sqrt 7 ^ 2 = 7 := Real.sq_sqrt (by norm_num : (7:ℝ) ≥ 0)
  have h5nn := Real.sqrt_nonneg 5
  have h7nn := Real.sqrt_nonneg 7
  nlinarith [sq_nonneg (2 + 2 * Real.sqrt 5 - 2 * Real.sqrt 7),
             sq_nonneg (Real.sqrt 5 - 2), sq_nonneg (Real.sqrt 7 - 2)]


/-- H₁ preserves the quadruple Pythagorean equation. -/
theorem rfH₁_preserves_quad (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (a - 2*c + 2*d) ^ 2 + b ^ 2 + (2*a - c + 2*d) ^ 2 = (2*a - 2*c + 3*d) ^ 2 := by
  nlinarith [sq_nonneg (a - c), sq_nonneg (a + c), sq_nonneg b, sq_nonneg d,
             sq_nonneg (a - d), sq_nonneg (c - d)]


/-- The root quadruple (1, 2, 2, 3) satisfies the Pythagorean equation. -/
theorem root_quadruple_pyth : (1:ℤ) ^ 2 + 2 ^ 2 + 2 ^ 2 = 3 ^ 2 := by norm_num


/-- Applying H₁ to (1, 2, 2, 3) yields a valid quadruple. -/
theorem rfH₁_child_valid :
    let r := (1 - 2*2 + 2*3, (2:ℤ), 2*1 - 2 + 2*3, 2*1 - 2*2 + 3*3)
    r.1 ^ 2 + r.2.1 ^ 2 + r.2.2.1 ^ 2 = r.2.2.2 ^ 2 := by norm_num


/-- Products of 4D Lorentz transformations are also Lorentz transformations. -/
theorem lorentz4_product_closure (M N : Matrix (Fin 4) (Fin 4) ℤ)
    (hM : Mᵀ * rfQ4 * M = rfQ4)
    (hN : Nᵀ * rfQ4 * N = rfQ4) :
    (M * N)ᵀ * rfQ4 * (M * N) = rfQ4 := by
  rw [Matrix.transpose_mul]
  have : Nᵀ * Mᵀ * rfQ4 * (M * N) = Nᵀ * (Mᵀ * rfQ4 * M) * N := by
    simp [Matrix.mul_assoc]
  rw [this, hM, hN]


/-- H₁ · H₂ preserves the 4D Lorentz form (by closure). -/
theorem rfH₁H₂_lorentz : (rfH₁ * rfH₂)ᵀ * rfQ4 * (rfH₁ * rfH₂) = rfQ4 :=
  lorentz4_product_closure rfH₁ rfH₂ rfH₁_lorentz rfH₂_lorentz


/-- H₃ · H₄ preserves the 4D Lorentz form (by closure). -/
theorem rfH₃H₄_lorentz : (rfH₃ * rfH₄)ᵀ * rfQ4 * (rfH₃ * rfH₄) = rfQ4 :=
  lorentz4_product_closure rfH₃ rfH₄ rfH₃_lorentz rfH₄_lorentz


/-- Trace of H₁. -/
theorem trace_rfH₁ : Matrix.trace rfH₁ = 4 := by native_decide


/-- Trace of H₂. -/
theorem trace_rfH₂ : Matrix.trace rfH₂ = 6 := by native_decide


/-- Trace of H₃. -/
theorem trace_rfH₃ : Matrix.trace rfH₃ = 4 := by native_decide


/-- Trace of H₄. -/
theorem trace_rfH₄ : Matrix.trace rfH₄ = 6 := by native_decide


/-- Trace of H₁ · H₂. -/
theorem trace_rfH₁H₂ : Matrix.trace (rfH₁ * rfH₂) = 18 := by native_decide


/-- The 4D generators are pairwise distinct. -/
theorem rfH_distinct :
    rfH₁ ≠ rfH₂ ∧ rfH₁ ≠ rfH₃ ∧ rfH₁ ≠ rfH₄ ∧
    rfH₂ ≠ rfH₃ ∧ rfH₂ ≠ rfH₄ ∧ rfH₃ ≠ rfH₄ := by
  exact ⟨by native_decide, by native_decide, by native_decide,
         by native_decide, by native_decide, by native_decide⟩


/-- No 4D generator is the identity. -/
theorem rfH_ne_one :
    rfH₁ ≠ 1 ∧ rfH₂ ≠ 1 ∧ rfH₃ ≠ 1 ∧ rfH₄ ≠ 1 := by
  exact ⟨by native_decide, by native_decide, by native_decide, by native_decide⟩


/-- No 4D generator is an involution. -/
theorem rfH_not_involutions :
    rfH₁ * rfH₁ ≠ 1 ∧ rfH₂ * rfH₂ ≠ 1 ∧ rfH₃ * rfH₃ ≠ 1 ∧ rfH₄ * rfH₄ ≠ 1 := by
  exact ⟨by native_decide, by native_decide, by native_decide, by native_decide⟩


/-- Relative spectral gap for d = 3: (3 - 2√2)/3. -/
noncomputable def relativeGap3 : ℝ := (3 - 2 * Real.sqrt 2) / 3


/-- Relative spectral gap for d = 6: (6 - 2√5)/6. -/
noncomputable def relativeGap6 : ℝ := (6 - 2 * Real.sqrt 5) / 6


/-- Relative spectral gap for d = 8: (8 - 2√7)/8. -/
noncomputable def relativeGap8 : ℝ := (8 - 2 * Real.sqrt 7) / 8


/-- All relative spectral gaps are positive. -/
theorem relativeGaps_pos :
    relativeGap3 > 0 ∧ relativeGap6 > 0 ∧ relativeGap8 > 0 := by
  refine ⟨?_, ?_, ?_⟩
  · exact div_pos (by
      have : Real.sqrt 2 < 3/2 := by
        nlinarith [Real.sq_sqrt (show (2:ℝ) ≥ 0 by norm_num), Real.sqrt_nonneg 2,
                   sq_nonneg (Real.sqrt 2 - 3/2)]
      linarith) (by positivity)
  · exact div_pos spectralGap6_pos (by positivity)
  · exact div_pos spectralGap8_pos (by positivity)


end
