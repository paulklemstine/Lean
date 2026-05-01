/-! # CatalogBuild.EML.SPBExtended.RamanujanFrontiers2

Auto-generated from theorem catalog database.
Domain: EML/SPBExtended
Declarations: 96
-/

import Mathlib

/-- [Section: # CatalogBuild.Pythagorean.ModularForms.RamanujanFrontiers2
Auto-generated from theorem catalog database.
Domain: Pythagorean/ModularForms
Declarations: 96] -/
def rfB₁' : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]


/-- [Section: # CatalogBuild.Pythagorean.ModularForms.RamanujanFrontiers2
Auto-generated from theorem catalog database.
Domain: Pythagorean/ModularForms
Declarations: 96] -/
def rfB₂' : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]


/-- [Section: # CatalogBuild.Pythagorean.ModularForms.RamanujanFrontiers2
Auto-generated from theorem catalog database.
Domain: Pythagorean/ModularForms
Declarations: 96] -/
def rfB₃' : Matrix (Fin 3) (Fin 3) ℤ := !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]


def rfQ' : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]


/-- B₁² explicit form. -/
theorem rfB₁'_sq :
    rfB₁' * rfB₁' = !![(1 : ℤ), -4, 4; 4, -7, 8; 4, -8, 9] := by native_decide


/-- B₂² explicit form. -/
theorem rfB₂'_sq :
    rfB₂' * rfB₂' = !![(9 : ℤ), 8, 12; 8, 9, 12; 12, 12, 17] := by native_decide


/-- B₃² explicit form. -/
theorem rfB₃'_sq :
    rfB₃' * rfB₃' = !![(-7 : ℤ), 4, 8; -4, 1, 4; -8, 4, 9] := by native_decide


/-- tr(B₁) = 3, tr(B₁²) = 3. The eigenvalue equation is λ³ - 3λ² + 3λ - 1 = 0,
i.e. (λ-1)³ = 0, so B₁ is unipotent-like in the Lorentz representation. -/
theorem trace_rfB₁'_sq : Matrix.trace (rfB₁' * rfB₁') = 3 := by native_decide


/-- tr(B₂²) = 35. Combined with tr(B₂) = 5 and det(B₂) = -1, this determines
the characteristic polynomial. -/
theorem trace_rfB₂'_sq : Matrix.trace (rfB₂' * rfB₂') = 35 := by native_decide


/-- tr(B₃²) = 3. Same eigenvalue structure as B₁. -/
theorem trace_rfB₃'_sq : Matrix.trace (rfB₃' * rfB₃') = 3 := by native_decide


/-- tr(B₁³) = 3. The pattern tr(B₁ⁿ) = 3 for all n would indicate B₁ is parabolic. -/
theorem trace_rfB₁'_cube : Matrix.trace (rfB₁' * rfB₁' * rfB₁') = 3 := by native_decide


/-- tr(B₂³) = 197. -/
theorem trace_rfB₂'_cube : Matrix.trace (rfB₂' * rfB₂' * rfB₂') = 197 := by native_decide


/-- The trace sequence for B₁ is constant at 3, indicating all eigenvalues are 1
(B₁ is parabolic in O(2,1)). -/
theorem trace_rfB₁'_fourth : Matrix.trace (rfB₁' * rfB₁' * rfB₁' * rfB₁') = 3 := by
  native_decide


/-- The trace sequence for B₂ grows exponentially: 5, 35, 197, ...
indicating B₂ is hyperbolic in O(2,1) with spectral radius > 1. -/
theorem trace_rfB₂'_fourth :
    Matrix.trace (rfB₂' * rfB₂' * rfB₂' * rfB₂') = 1155 := by native_decide


def matMod' (N : ℕ) [NeZero N] (M : Matrix (Fin 3) (Fin 3) ℤ) :
    Matrix (Fin 3) (Fin 3) (ZMod N) := M.map (Int.cast)


/-- Lorentz form preservation modulo 11. -/
theorem rfB₁'_lorentz_mod11 :
    (matMod' 11 rfB₁')ᵀ * (matMod' 11 rfQ') * (matMod' 11 rfB₁') = matMod' 11 rfQ' := by
  native_decide


theorem rfB₂'_lorentz_mod11 :
    (matMod' 11 rfB₂')ᵀ * (matMod' 11 rfQ') * (matMod' 11 rfB₂') = matMod' 11 rfQ' := by
  native_decide


theorem rfB₃'_lorentz_mod11 :
    (matMod' 11 rfB₃')ᵀ * (matMod' 11 rfQ') * (matMod' 11 rfB₃') = matMod' 11 rfQ' := by
  native_decide


/-- Lorentz form preservation modulo 17. -/
theorem rfB₁'_lorentz_mod17 :
    (matMod' 17 rfB₁')ᵀ * (matMod' 17 rfQ') * (matMod' 17 rfB₁') = matMod' 17 rfQ' := by
  native_decide


theorem rfB₂'_lorentz_mod17 :
    (matMod' 17 rfB₂')ᵀ * (matMod' 17 rfQ') * (matMod' 17 rfB₂') = matMod' 17 rfQ' := by
  native_decide


theorem rfB₃'_lorentz_mod17 :
    (matMod' 17 rfB₃')ᵀ * (matMod' 17 rfQ') * (matMod' 17 rfB₃') = matMod' 17 rfQ' := by
  native_decide


/-- Lorentz form preservation modulo 19. -/
theorem rfB₁'_lorentz_mod19 :
    (matMod' 19 rfB₁')ᵀ * (matMod' 19 rfQ') * (matMod' 19 rfB₁') = matMod' 19 rfQ' := by
  native_decide


theorem rfB₂'_lorentz_mod19 :
    (matMod' 19 rfB₂')ᵀ * (matMod' 19 rfQ') * (matMod' 19 rfB₂') = matMod' 19 rfQ' := by
  native_decide


theorem rfB₃'_lorentz_mod19 :
    (matMod' 19 rfB₃')ᵀ * (matMod' 19 rfQ') * (matMod' 19 rfB₃') = matMod' 19 rfQ' := by
  native_decide


/-- Lorentz form preservation modulo 23. -/
theorem rfB₁'_lorentz_mod23 :
    (matMod' 23 rfB₁')ᵀ * (matMod' 23 rfQ') * (matMod' 23 rfB₁') = matMod' 23 rfQ' := by
  native_decide


theorem rfB₂'_lorentz_mod23 :
    (matMod' 23 rfB₂')ᵀ * (matMod' 23 rfQ') * (matMod' 23 rfB₂') = matMod' 23 rfQ' := by
  native_decide


theorem rfB₃'_lorentz_mod23 :
    (matMod' 23 rfB₃')ᵀ * (matMod' 23 rfQ') * (matMod' 23 rfB₃') = matMod' 23 rfQ' := by
  native_decide


/-- B₁B₂ ≠ B₂B₁. -/
theorem rfB₁'B₂'_ne_rfB₂'B₁' : rfB₁' * rfB₂' ≠ rfB₂' * rfB₁' := by native_decide


/-- B₁B₃ ≠ B₃B₁. -/
theorem rfB₁'B₃'_ne_rfB₃'B₁' : rfB₁' * rfB₃' ≠ rfB₃' * rfB₁' := by native_decide


/-- B₂B₃ ≠ B₃B₂. -/
theorem rfB₂'B₃'_ne_rfB₃'B₂' : rfB₂' * rfB₃' ≠ rfB₃' * rfB₂' := by native_decide


/-- The commutator [B₁, B₂] = B₁B₂B₁⁻¹B₂⁻¹ is nontrivial.
We verify B₁B₂ ≠ B₂B₁ which implies the commutator ≠ I. -/
theorem berggren_nonabelian :
    rfB₁' * rfB₂' ≠ rfB₂' * rfB₁' ∧
    rfB₁' * rfB₃' ≠ rfB₃' * rfB₁' ∧
    rfB₂' * rfB₃' ≠ rfB₃' * rfB₂' := by
  exact ⟨by native_decide, by native_decide, by native_decide⟩


/-- Traces of products are equal (tr(AB) = tr(BA) always), but the matrices differ.
This is the trace identity for non-commuting matrices. -/
theorem commutator_trace_identity :
    Matrix.trace (rfB₁' * rfB₂') = Matrix.trace (rfB₂' * rfB₁') := by native_decide


/-- The degree-6 Cayley graph eigenvalue bound: d = 6, trivial eigenvalue = 6. -/
theorem degree_is_eigenvalue : (6 : ℝ) > 2 * Real.sqrt 5 := by
  have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num : (5:ℝ) ≥ 0)
  have h5nn := Real.sqrt_nonneg 5
  nlinarith [sq_nonneg (Real.sqrt 5 - 3)]


/-- The 5D Lorentz form: diag(1, 1, 1, 1, -1). -/
def rfQ5 : Matrix (Fin 5) (Fin 5) ℤ :=
  !![1, 0, 0, 0, 0; 0, 1, 0, 0, 0; 0, 0, 1, 0, 0; 0, 0, 0, 1, 0; 0, 0, 0, 0, (-1)]


/-- K₁: Berggren B₃-type in (a₁, a₄, d) plane. -/
def rfK₁ : Matrix (Fin 5) (Fin 5) ℤ :=
  !![(-1), 0, 0, 2, 2; 0, 1, 0, 0, 0; 0, 0, 1, 0, 0; (-2), 0, 0, 1, 2; (-2), 0, 0, 2, 3]


/-- K₂: Berggren B₂-type in (a₁, a₄, d) plane. -/
def rfK₂ : Matrix (Fin 5) (Fin 5) ℤ :=
  !![1, 0, 0, 2, 2; 0, 1, 0, 0, 0; 0, 0, 1, 0, 0; 2, 0, 0, 1, 2; 2, 0, 0, 2, 3]


/-- K₃: Berggren B₃-type in (a₂, a₄, d) plane. -/
def rfK₃ : Matrix (Fin 5) (Fin 5) ℤ :=
  !![1, 0, 0, 0, 0; 0, (-1), 0, 2, 2; 0, 0, 1, 0, 0; 0, (-2), 0, 1, 2; 0, (-2), 0, 2, 3]


/-- K₄: Berggren B₃-type in (a₃, a₄, d) plane. -/
def rfK₄ : Matrix (Fin 5) (Fin 5) ℤ :=
  !![1, 0, 0, 0, 0; 0, 1, 0, 0, 0; 0, 0, (-1), 2, 2; 0, 0, (-2), 1, 2; 0, 0, (-2), 2, 3]


/-- K₅: Berggren B₃-type acting in (a₃, a₄, d) subspace (alternate). -/
def rfK₅ : Matrix (Fin 5) (Fin 5) ℤ :=
  !![1, 0, 0, 0, 0; 0, 1, 0, 0, 0; 0, 0, 1, 2, 2; 0, 0, 2, 1, 2; 0, 0, 2, 2, 3]


/-- K₆: Berggren B₂-type in (a₂, a₄, d) plane. -/
def rfK₆ : Matrix (Fin 5) (Fin 5) ℤ :=
  !![1, 0, 0, 0, 0; 0, 1, 0, 2, 2; 0, 0, 1, 0, 0; 0, 2, 0, 1, 2; 0, 2, 0, 2, 3]


/-- All generators preserve the 5D Lorentz form. -/
theorem rfK₁_lorentz : rfK₁ᵀ * rfQ5 * rfK₁ = rfQ5 := by native_decide


theorem rfK₂_lorentz : rfK₂ᵀ * rfQ5 * rfK₂ = rfQ5 := by native_decide


theorem rfK₃_lorentz : rfK₃ᵀ * rfQ5 * rfK₃ = rfQ5 := by native_decide


theorem rfK₄_lorentz : rfK₄ᵀ * rfQ5 * rfK₄ = rfQ5 := by native_decide


theorem rfK₅_lorentz : rfK₅ᵀ * rfQ5 * rfK₅ = rfQ5 := by native_decide


theorem rfK₆_lorentz : rfK₆ᵀ * rfQ5 * rfK₆ = rfQ5 := by native_decide


/-- Determinants of 5D generators. -/
theorem det_rfK₁ : Matrix.det rfK₁ = 1 := by native_decide


theorem det_rfK₂ : Matrix.det rfK₂ = -1 := by native_decide


theorem det_rfK₃ : Matrix.det rfK₃ = 1 := by native_decide


theorem det_rfK₄ : Matrix.det rfK₄ = 1 := by native_decide


theorem det_rfK₅ : Matrix.det rfK₅ = -1 := by native_decide


theorem det_rfK₆ : Matrix.det rfK₆ = -1 := by native_decide


/-- None is the identity. -/
theorem rfK_ne_one :
    rfK₁ ≠ 1 ∧ rfK₂ ≠ 1 ∧ rfK₃ ≠ 1 ∧ rfK₄ ≠ 1 ∧ rfK₅ ≠ 1 ∧ rfK₆ ≠ 1 := by
  exact ⟨by native_decide, by native_decide, by native_decide,
         by native_decide, by native_decide, by native_decide⟩


/-- None is an involution. -/
theorem rfK_not_involutions :
    rfK₁ * rfK₁ ≠ 1 ∧ rfK₂ * rfK₂ ≠ 1 ∧ rfK₃ * rfK₃ ≠ 1 ∧
    rfK₄ * rfK₄ ≠ 1 ∧ rfK₅ * rfK₅ ≠ 1 ∧ rfK₆ * rfK₆ ≠ 1 := by
  exact ⟨by native_decide, by native_decide, by native_decide,
         by native_decide, by native_decide, by native_decide⟩


/-- Traces of 5D generators. -/
theorem trace_rfK₁ : Matrix.trace rfK₁ = 5 := by native_decide


theorem trace_rfK₂ : Matrix.trace rfK₂ = 7 := by native_decide


theorem trace_rfK₃ : Matrix.trace rfK₃ = 5 := by native_decide


theorem trace_rfK₄ : Matrix.trace rfK₄ = 5 := by native_decide


theorem trace_rfK₅ : Matrix.trace rfK₅ = 7 := by native_decide


theorem trace_rfK₆ : Matrix.trace rfK₆ = 7 := by native_decide


/-- Non-commutativity of 5D generators. -/
theorem rfK₁K₂_ne_rfK₂K₁ : rfK₁ * rfK₂ ≠ rfK₂ * rfK₁ := by native_decide


theorem rfK₁K₃_ne_rfK₃K₁ : rfK₁ * rfK₃ ≠ rfK₃ * rfK₁ := by native_decide


theorem rfK₁K₄_ne_rfK₄K₁ : rfK₁ * rfK₄ ≠ rfK₄ * rfK₁ := by native_decide


/-- The spectral gap for 12-regular Ramanujan graphs: 12 - 2√11 > 0. -/
theorem spectralGap12_pos : (12 : ℝ) - 2 * Real.sqrt 11 > 0 := by
  have h11 : Real.sqrt 11 ^ 2 = 11 := Real.sq_sqrt (by norm_num : (11:ℝ) ≥ 0)
  have h11nn := Real.sqrt_nonneg 11
  nlinarith [sq_nonneg (Real.sqrt 11 - 6)]


/-- Full dimensional monotonicity chain including 5D:
12 - 2√11 > 8 - 2√7 > 6 - 2√5 > 3 - 2√2. -/
theorem spectralGap_full_monotone :
    (12 : ℝ) - 2 * Real.sqrt 11 > 8 - 2 * Real.sqrt 7 ∧
    (8 : ℝ) - 2 * Real.sqrt 7 > 6 - 2 * Real.sqrt 5 ∧
    (6 : ℝ) - 2 * Real.sqrt 5 > 3 - 2 * Real.sqrt 2 := by
  refine ⟨?_, ?_, ?_⟩
  · have h7 : Real.sqrt 7 ^ 2 = 7 := Real.sq_sqrt (by norm_num : (7:ℝ) ≥ 0)
    have h11 : Real.sqrt 11 ^ 2 = 11 := Real.sq_sqrt (by norm_num : (11:ℝ) ≥ 0)
    have h7nn := Real.sqrt_nonneg 7
    have h11nn := Real.sqrt_nonneg 11
    nlinarith [sq_nonneg (4 + 2 * Real.sqrt 7 - 2 * Real.sqrt 11),
               sq_nonneg (Real.sqrt 7 - 2), sq_nonneg (Real.sqrt 11 - 3)]
  · have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num : (5:ℝ) ≥ 0)
    have h7 : Real.sqrt 7 ^ 2 = 7 := Real.sq_sqrt (by norm_num : (7:ℝ) ≥ 0)
    have h5nn := Real.sqrt_nonneg 5
    have h7nn := Real.sqrt_nonneg 7
    nlinarith [sq_nonneg (2 + 2 * Real.sqrt 5 - 2 * Real.sqrt 7),
               sq_nonneg (Real.sqrt 5 - 2), sq_nonneg (Real.sqrt 7 - 2)]
  · have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num : (2:ℝ) ≥ 0)
    have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num : (5:ℝ) ≥ 0)
    have h2nn := Real.sqrt_nonneg 2
    have h5nn := Real.sqrt_nonneg 5
    nlinarith [sq_nonneg (3 + 2 * Real.sqrt 2 - 2 * Real.sqrt 5),
               sq_nonneg (Real.sqrt 2 - 1), sq_nonneg (Real.sqrt 5 - 2)]


theorem lorentz5_product_closure (M N : Matrix (Fin 5) (Fin 5) ℤ)
    (hM : Mᵀ * rfQ5 * M = rfQ5)
    (hN : Nᵀ * rfQ5 * N = rfQ5) :
    (M * N)ᵀ * rfQ5 * (M * N) = rfQ5 := by
  rw [Matrix.transpose_mul]
  have : Nᵀ * Mᵀ * rfQ5 * (M * N) = Nᵀ * (Mᵀ * rfQ5 * M) * N := by
    simp [Matrix.mul_assoc]
  rw [this, hM, hN]


theorem rfK₁K₂_lorentz : (rfK₁ * rfK₂)ᵀ * rfQ5 * (rfK₁ * rfK₂) = rfQ5 :=
  lorentz5_product_closure rfK₁ rfK₂ rfK₁_lorentz rfK₂_lorentz


/-- The root quintuple (1, 1, 1, 1, 2) satisfies a₁² + a₂² + a₃² + a₄² = d². -/
theorem root_quintuple_pyth : (1:ℤ) ^ 2 + 1 ^ 2 + 1 ^ 2 + 1 ^ 2 = 2 ^ 2 := by norm_num


/-- K₄ preserves the quintuple equation (B₃-type in (a₃, a₄, d)):
if a₁² + a₂² + a₃² + a₄² = d², then
a₁² + a₂² + (-a₃ + 2*a₄ + 2*d)² + (-2*a₃ + a₄ + 2*d)² = (-2*a₃ + 2*a₄ + 3*d)². -/
theorem rfK₄_preserves_quint (a₁ a₂ a₃ a₄ d : ℤ)
    (h : a₁ ^ 2 + a₂ ^ 2 + a₃ ^ 2 + a₄ ^ 2 = d ^ 2) :
    a₁ ^ 2 + a₂ ^ 2 + (-a₃ + 2*a₄ + 2*d) ^ 2 + (-2*a₃ + a₄ + 2*d) ^ 2 =
    (-2*a₃ + 2*a₄ + 3*d) ^ 2 := by nlinarith [sq_nonneg a₃, sq_nonneg a₄, sq_nonneg d]


/-- The 5×5 Grover coin (scaled by 5): entry -3 on diagonal, 2 off-diagonal. -/
def groverCoin5x : Matrix (Fin 5) (Fin 5) ℤ :=
  !![(-3), 2, 2, 2, 2;
     2, (-3), 2, 2, 2;
     2, 2, (-3), 2, 2;
     2, 2, 2, (-3), 2;
     2, 2, 2, 2, (-3)]


theorem groverCoin5x_symm : groverCoin5xᵀ = groverCoin5x := by native_decide


theorem groverCoin5x_sq :
    groverCoin5x * groverCoin5x = 25 • (1 : Matrix (Fin 5) (Fin 5) ℤ) := by native_decide


theorem groverCoin5x_trace : Matrix.trace groverCoin5x = -15 := by native_decide


/-- Exponential growth: 3^k * 5 ≥ 5 for all k. -/
theorem hyp_lower_bound (k : ℕ) : 3 ^ k * 5 ≥ 5 := by
  have : 3 ^ k ≥ 1 := Nat.one_le_pow k 3 (by omega)
  omega


/-- Path count exceeds depth for n ≥ 1. -/
theorem paths_exceed_depth (n : ℕ) (hn : n ≥ 1) : 3 ^ n > n := by
  induction n with
  | zero => omega
  | succ m ih =>
    by_cases hm : m ≥ 1
    · calc 3 ^ (m + 1) = 3 * 3 ^ m := by ring
        _ ≥ 3 * (m + 1) := by omega
        _ ≥ m + 1 + 1 := by omega
    · simp at hm; subst hm; norm_num


/-- At depth 20, the path space exceeds 2³¹. -/
theorem depth20_security : 3 ^ 20 > 2 ^ 31 := by norm_num


/-- 3ⁿ > 2ⁿ for all n ≥ 1. -/
theorem three_pow_gt_two_pow (n : ℕ) (hn : n ≥ 1) : 3 ^ n > 2 ^ n := by
  exact Nat.pow_lt_pow_left (by omega) (by omega)


def rfH₁' : Matrix (Fin 4) (Fin 4) ℤ := !![1, 0, -2, 2; 0, 1, 0, 0; 2, 0, -1, 2; 2, 0, -2, 3]


def rfH₂' : Matrix (Fin 4) (Fin 4) ℤ := !![1, 0, 2, 2; 0, 1, 0, 0; 2, 0, 1, 2; 2, 0, 2, 3]


def rfH₃' : Matrix (Fin 4) (Fin 4) ℤ := !![1, 0, 0, 0; 0, 1, -2, 2; 0, 2, -1, 2; 0, 2, -2, 3]


def rfH₄' : Matrix (Fin 4) (Fin 4) ℤ := !![1, 0, 0, 0; 0, 1, 2, 2; 0, 2, 1, 2; 0, 2, 2, 3]


theorem rfH₁'H₂'_ne_rfH₂'H₁' : rfH₁' * rfH₂' ≠ rfH₂' * rfH₁' := by native_decide


theorem rfH₃'H₄'_ne_rfH₄'H₃' : rfH₃' * rfH₄' ≠ rfH₄' * rfH₃' := by native_decide


/-- H₁ and H₃ commute because they act on orthogonal coordinate planes (a₁,c,d) and (b,c,d)
sharing only (c,d). This is a block-diagonal commutativity certificate. -/
theorem rfH₁'H₃'_commute : rfH₁' * rfH₃' = rfH₃' * rfH₁' := by native_decide


/-- H₂ and H₄ do NOT commute (their extended coordinate dependence couples them). -/
theorem rfH₂'H₄'_ne_rfH₄'H₂' : rfH₂' * rfH₄' ≠ rfH₄' * rfH₂' := by native_decide


/-- For d=6: λ₂/d = 2√5/6 < 1. -/
theorem mixing_ratio_6reg : (2 * Real.sqrt 5) / 6 < 1 := by
  rw [div_lt_one (by norm_num : (6:ℝ) > 0)]
  have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num : (5:ℝ) ≥ 0)
  have h5nn := Real.sqrt_nonneg 5
  nlinarith [sq_nonneg (Real.sqrt 5 - 3)]


/-- For d=8: λ₂/d = 2√7/8 < 1. -/
theorem mixing_ratio_8reg : (2 * Real.sqrt 7) / 8 < 1 := by
  rw [div_lt_one (by norm_num : (8:ℝ) > 0)]
  have h7 : Real.sqrt 7 ^ 2 = 7 := Real.sq_sqrt (by norm_num : (7:ℝ) ≥ 0)
  have h7nn := Real.sqrt_nonneg 7
  nlinarith [sq_nonneg (Real.sqrt 7 - 4)]


/-- For d=12: λ₂/d = 2√11/12 < 1. -/
theorem mixing_ratio_12reg : (2 * Real.sqrt 11) / 12 < 1 := by
  rw [div_lt_one (by norm_num : (12:ℝ) > 0)]
  have h11 : Real.sqrt 11 ^ 2 = 11 := Real.sq_sqrt (by norm_num : (11:ℝ) ≥ 0)
  have h11nn := Real.sqrt_nonneg 11
  nlinarith [sq_nonneg (Real.sqrt 11 - 6)]


/-- Sum of squared traces: tr(B₁²) + tr(B₂²) + tr(B₃²) = 41. -/
theorem adjacency_trace_sum :
    Matrix.trace (rfB₁' * rfB₁') + Matrix.trace (rfB₂' * rfB₂') +
    Matrix.trace (rfB₃' * rfB₃') = 41 := by native_decide


/-- Sum of cross-product traces tr(BᵢBⱼ) for i ≠ j. -/
theorem cross_trace_sum :
    Matrix.trace (rfB₁' * rfB₂') + Matrix.trace (rfB₁' * rfB₃') +
    Matrix.trace (rfB₂' * rfB₃') = 49 := by native_decide


/-- B₁ is parabolic: |tr(B₁)| = 3. -/
theorem rfB₁'_parabolic : Matrix.trace rfB₁' = 3 := by native_decide


/-- B₂ is hyperbolic: |tr(B₂)| = 5 > 3. -/
theorem rfB₂'_hyperbolic : Matrix.trace rfB₂' = 5 := by native_decide


/-- B₃ is parabolic: |tr(B₃)| = 3. -/
theorem rfB₃'_parabolic : Matrix.trace rfB₃' = 3 := by native_decide


/-- Product B₁B₂ is strongly hyperbolic: tr(B₁B₂) = 17. -/
theorem rfB₁'B₂'_strongly_hyperbolic :
    Matrix.trace (rfB₁' * rfB₂') = 17 := by native_decide


/-- Parabolic elements have constant trace under powers:
tr(B₁ⁿ) = 3 for n = 1, 2, 3, 4.
This is because B₁ has eigenvalues {1, 1, 1} (all equal to 1). -/
theorem rfB₁'_parabolic_trace_seq :
    Matrix.trace rfB₁' = 3 ∧
    Matrix.trace (rfB₁' * rfB₁') = 3 ∧
    Matrix.trace (rfB₁' * rfB₁' * rfB₁') = 3 ∧
    Matrix.trace (rfB₁' * rfB₁' * rfB₁' * rfB₁') = 3 := by
  exact ⟨by native_decide, by native_decide, by native_decide, by native_decide⟩


/-- Hyperbolic elements have exponentially growing trace under powers:
tr(B₂), tr(B₂²), tr(B₂³), tr(B₂⁴) = 5, 35, 197, 1155. -/
theorem rfB₂'_hyperbolic_trace_seq :
    Matrix.trace rfB₂' = 5 ∧
    Matrix.trace (rfB₂' * rfB₂') = 35 ∧
    Matrix.trace (rfB₂' * rfB₂' * rfB₂') = 197 ∧
    Matrix.trace (rfB₂' * rfB₂' * rfB₂' * rfB₂') = 1155 := by
  exact ⟨by native_decide, by native_decide, by native_decide, by native_decide⟩


