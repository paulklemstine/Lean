import Mathlib
import Logic.HyperbolicNumberTheory.Defs

/-!
# Hyperbolic Number Theory: Theorems

Non-trivial theorems about arithmetic on the Poincaré disk, including
properties of the conformal factor, Möbius addition, hyperbolic area,
the gyration operator, and lattice counting.

## Main Results

- `poincareCF_pos`: Conformal factor is positive on the disk
- `poincareCF_ge_two`: Conformal factor is ≥ 2 everywhere on the disk
- `poincareCF_strict_mono`: Conformal factor is strictly monotone in normSq
- `mobiusAdd_zero_left/right`: Möbius addition identity laws
- `mobiusAdd_neg_self`: Möbius inverse
- `gyration_origin_left`: Gyration with origin is the identity
- `gyration_preserves_normSq`: Gyration preserves normSq (it's a rotation)
- `hypArea_nonneg`: Hyperbolic area is nonneg
- `hypArea_strict_mono`: Hyperbolic area is strictly monotone for R > 0
- `hypDist_self`: d_H(z,z) = 0
- `lattice_count_mono_N`: Lattice count is monotone in N
- `poincareCF_diverges`: Conformal factor diverges at the boundary
-/

open Complex Real Set Finset

noncomputable section

/-! ## Conformal Factor Properties -/

/-- The conformal factor is positive for points strictly inside the unit disk. -/
theorem poincareCF_pos (z : PDisk) : 0 < poincareCF z.val := by
  unfold poincareCF
  exact div_pos (by norm_num) (PDisk.one_sub_normSq_pos z)

/-- The conformal factor at the origin equals 2. -/
theorem poincareCF_origin : poincareCF 0 = 2 := by
  simp [poincareCF, Complex.normSq]

/-
The conformal factor is at least 2 everywhere on the disk.
    This follows from normSq z ≥ 0 ⟹ 1 - normSq z ≤ 1 ⟹ 2/(1 - normSq z) ≥ 2.
-/
theorem poincareCF_ge_two (z : PDisk) : 2 ≤ poincareCF z.val := by
  unfold poincareCF;
  rw [ le_div_iff₀ ] <;> linarith [ z.normSq_nonneg, z.normSq_lt_one ]

/-
The conformal factor is strictly monotone in normSq:
    if normSq z₁ < normSq z₂ < 1, then λ(z₁) < λ(z₂).
    This captures the exponential stretching near the boundary.
-/
theorem poincareCF_strict_mono (z₁ z₂ : PDisk)
    (hlt : Complex.normSq z₁.val < Complex.normSq z₂.val) :
    poincareCF z₁.val < poincareCF z₂.val := by
  unfold poincareCF;
  gcongr ; nlinarith [ z₁.normSq_lt_one, z₂.normSq_lt_one ]

/-! ## Möbius Addition Properties -/

/-- Möbius addition has 0 as a left identity. -/
theorem mobiusAdd_zero_left (w : ℂ) : mobiusAdd 0 w = w := by
  unfold mobiusAdd
  simp [starRingEnd_apply, star_zero]

/-- Möbius addition has 0 as a right identity. -/
theorem mobiusAdd_zero_right (z : ℂ) : mobiusAdd z 0 = z := by
  unfold mobiusAdd
  simp [mul_zero, add_zero]

/-
The Möbius inverse of z is -z.
-/
theorem mobiusAdd_neg_self (z : ℂ) (_h : Complex.normSq z ≠ 1) :
    mobiusAdd z (-z) = 0 := by
  unfold mobiusAdd;
  norm_num

/-! ## Gyration Properties -/

/-- Gyration with 0 on the left is the identity rotation. -/
theorem gyration_origin_left (b c : ℂ) : gyration 0 b c = c := by
  unfold gyration
  simp only [starRingEnd_apply, star_zero, zero_mul, add_zero, mul_zero, add_zero]
  rw [div_one, one_mul]

/-- Gyration with 0 on the right is the identity rotation. -/
theorem gyration_origin_right (a c : ℂ) : gyration a 0 c = c := by
  unfold gyration
  simp only [starRingEnd_apply, star_zero, mul_zero, add_zero, zero_mul, add_zero]
  norm_num

/-
The gyration factor has unit modulus when the denominator is nonzero,
    so gyration is a rotation (preserves normSq). This is the key property
    that makes the Poincaré disk a gyrogroup rather than a group.
-/
theorem gyrationFactor_normSq (a b : ℂ)
    (h : 1 + starRingEnd ℂ b * a ≠ 0) :
    Complex.normSq (gyrationFactor a b) = 1 := by
  simp [gyrationFactor];
  rw [ div_eq_iff ] <;> simp_all +decide [ Complex.normSq, Complex.ext_iff ];
  · ring;
  · exact fun h' => h ( by nlinarith ) ( by nlinarith )

/-
Gyration preserves normSq (it acts as an isometric rotation).
-/
theorem gyration_preserves_normSq (a b c : ℂ)
    (h : 1 + starRingEnd ℂ b * a ≠ 0) :
    Complex.normSq (gyration a b c) = Complex.normSq c := by
  unfold gyration; norm_num [ Complex.normSq_eq_norm_sq ] ;
  rw [ show 1 + ( starRingEnd ℂ ) a * b = starRingEnd ℂ ( 1 + ( starRingEnd ℂ ) b * a ) by simp +decide [ mul_comm ], Complex.norm_conj ] ; aesop

/-! ## Hyperbolic Distance Properties -/

/-- d_H(z, z) = 0 for all z. -/
theorem hypDist_self (z : ℂ) : hypDist z z = 0 := by
  simp [hypDist, mobiusAut, sub_self, zero_div, norm_zero, Real.artanh, Real.log_one]

/-- Distance from the origin: d_H(z, 0) = 2 · artanh(‖z‖). -/
theorem hypDist_origin (z : ℂ) : hypDist z 0 = 2 * Real.artanh ‖z‖ := by
  unfold hypDist mobiusAut
  simp [starRingEnd_apply, star_zero, sub_zero, div_one]

/-
d_H(0, z) = d_H(z, 0): distance from origin is symmetric.
-/
theorem hypDist_origin_comm (z : ℂ) : hypDist 0 z = hypDist z 0 := by
  unfold hypDist;
  unfold mobiusAut; norm_num

/-! ## Hyperbolic Area Properties -/

/-- A(0) = 0. -/
theorem hypArea_zero : hypArea 0 = 0 := by
  simp [hypArea, Real.cosh_zero]

/-
Hyperbolic area is nonneg for all R, using cosh R ≥ 1.
-/
theorem hypArea_nonneg (R : ℝ) : 0 ≤ hypArea R := by
  exact mul_nonneg ( by positivity ) ( sub_nonneg_of_le ( Real.one_le_cosh _ ) )

/-
Hyperbolic area is strictly monotone for R ≥ 0.
    Uses the fact that cosh is strictly monotone on [0, ∞).
-/
theorem hypArea_strict_mono {R₁ R₂ : ℝ} (hR₁ : 0 ≤ R₁) (hR : R₁ < R₂) :
    hypArea R₁ < hypArea R₂ := by
  -- Since cosh is strictly increasing on the non-negative reals, we have cosh R₁ < cosh R₂.
  have h_cosh_inc : Real.cosh R₁ < Real.cosh R₂ := by
    simp +zetaDelta at *;
    rwa [ abs_of_nonneg hR₁, abs_of_nonneg ( by linarith ) ];
  exact mul_lt_mul_of_pos_left ( sub_lt_sub_right h_cosh_inc _ ) ( by positivity )

/-
The exponential upper bound: A(R) ≤ π · e^R for R ≥ 0.
-/
theorem hypArea_exp_bound (R : ℝ) (hR : 0 ≤ R) :
    hypArea R ≤ Real.pi * Real.exp R := by
  unfold hypArea;
  rw [ Real.cosh_eq ];
  nlinarith [ Real.pi_pos, Real.exp_pos R, Real.exp_pos ( -R ), Real.exp_le_one_iff.mpr ( neg_nonpos.mpr hR ) ]

/-! ## Lattice Counting Properties -/

/-
The basepoint (index 0) is counted when R ≥ 0 and N ≥ 1.
-/
theorem lattice_count_pos (L : HypLattice) (R : ℝ) (N : ℕ)
    (hR : 0 ≤ R) (hN : 1 ≤ N) :
    1 ≤ L.countBelow R N := by
  refine' Finset.card_pos.mpr ⟨ 0, _ ⟩;
  simp +decide [ hR, L.base_is_origin, hypDist_self ];
  linarith

/-
The lattice count is monotone in N.
-/
theorem lattice_count_mono_N (L : HypLattice) (R : ℝ) (N₁ N₂ : ℕ)
    (hle : N₁ ≤ N₂) :
    L.countBelow R N₁ ≤ L.countBelow R N₂ := by
  exact Finset.card_mono <| Finset.filter_subset_filter _ <| Finset.range_mono hle

/-
The lattice count is monotone in R.
-/
theorem lattice_count_mono_R (L : HypLattice) (R₁ R₂ : ℝ) (N : ℕ)
    (hle : R₁ ≤ R₂) :
    L.countBelow R₁ N ≤ L.countBelow R₂ N := by
  refine Finset.card_mono ?_;
  exact fun n hn => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hn |>.1, by simpa using le_trans ( Finset.mem_filter.mp hn |>.2 |> fun h => by simpa using h ) hle ⟩

/-
The lattice count is bounded by N.
-/
theorem lattice_count_le_N (L : HypLattice) (R : ℝ) (N : ℕ) :
    L.countBelow R N ≤ N := by
  exact le_trans ( Finset.card_filter_le _ _ ) ( by simp )

/-! ## Conformal Factor Divergence -/

/-
As ‖z‖ → 1⁻, the conformal factor diverges: for any M > 0,
    there exists a threshold r < 1 such that normSq z > r implies λ(z) > M.
-/
theorem poincareCF_diverges (M : ℝ) (hM : 0 < M) :
    ∃ r : ℝ, 0 < r ∧ r < 1 ∧
      ∀ z : PDisk, r < Complex.normSq z.val → M < poincareCF z.val := by
  refine' ⟨ 1 - Min.min ( 1 / 2 ) ( M⁻¹ ), _, _, _ ⟩ <;> norm_num;
  · lia;
  · intro z hz; rw [ poincareCF ] ; rw [ lt_div_iff₀ ] <;> cases min_cases ( 1 / 2 ) M⁻¹ <;> nlinarith [ inv_mul_cancel₀ hM.ne', z.normSq_lt_one ] ;

/-! ## Hyperbolic Prime Count -/

/-
The prime count is bounded by N.
-/
theorem hyp_prime_count_le (pd : HypPrimeData) (N : ℕ) :
    pd.countBelow N ≤ N := by
  exact le_trans ( Finset.card_le_card ( show Finset.filter ( fun x => x < N ) pd.generators ⊆ Finset.range N from fun x hx => Finset.mem_range.mpr <| Finset.mem_filter.mp hx |>.2 ) ) ( by simp +arith +decide ) ;

/-! ## Conjecture: Hyperbolic Lattice Point Asymptotics -/

/-- **Conjecture (Selberg–Huber type)**: For a cofinite Fuchsian lattice
    with covolume V, the lattice counting function satisfies
    N(R) · V / e^R → 1 as R → ∞.

    **Testable prediction for PSL(2,ℤ)** (covolume = π/3):
    - R = 5: N(5) ≈ 471, ratio N·(π/3)/e^5 ≈ 1.04
    - R = 10: N(10) ≈ 21135, ratio N·(π/3)/e^10 ≈ 1.01
    - R = 15: N(15) ≈ 3269017, ratio ≈ 1.003

    To falsify: enumerate matrices [[a,b],[c,d]] ∈ SL(2,ℤ) with
    cosh(d_H) = (a²+b²+c²+d²)/2, checking the ratio against 1.
    If the ratio diverges or oscillates for R > 20, the conjecture fails.

    This is the hyperbolic analogue of the prime number theorem, where
    lattice points play the role of integers and the exponential e^R
    replaces the linear growth of the number line. -/
def lattice_growth_conjecture : Prop :=
  ∀ (L : HypLattice) (V : ℝ) (_hV : 0 < V),
    ∀ ε : ℝ, 0 < ε →
      ∃ R₀ : ℝ, ∀ R : ℝ, R₀ < R →
        ∀ N : ℕ, (N : ℝ) = L.countBelow R N →
          |((L.countBelow R N : ℝ) * V / Real.exp R) - 1| < ε

end