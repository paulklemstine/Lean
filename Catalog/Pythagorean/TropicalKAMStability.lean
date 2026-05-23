/-
  # Tropical KAM Stability — Main Theorems

  This file proves the core theorems of tropical KAM stability theory,
  establishing that quasi-periodic tropical structure persists because
  combinatorics forbids resonance collapse.

  ## Main Results

  1. **Resonance Rigidity** (`tropical_diophantine_implies_resonance_rigidity`):
     Tropical Diophantine frequencies have locally rigid resonance profiles
     under small perturbations.

  2. **Diophantine Perturbation Stability** (`tropical_diophantine_perturbation_stable`):
     The Diophantine property is open: nearby frequencies remain Diophantine
     with a halved constant.

  3. **Finite-Scale Tropical KAM** (`tropical_KAM_finite_scale`):
     The flagship persistence theorem combining resonance rigidity with
     Diophantine stability.

  4. **Resonance Obstruction** (`resonance_implies_not_diophantine`):
     Exact resonances are fatal obstructions to Diophantine conditions,
     connecting to number theory.

  5. **Rational Frequency Collapse** (`rational_not_diophantine_at_scale`):
     Rational frequency vectors in dimension ≥ 2 always fail Diophantine
     conditions at sufficiently large scale. Cross-domain: number theory.

  6. **Scaling Invariance** (`tropical_diophantine_scaling`):
     The Diophantine condition transforms predictably under scaling,
     connecting to tropical valuation.

  7. **Tropical Valuation Gap** (`tropical_diophantine_gap_valuation`):
     Diophantine gaps transform under tropical valuation, connecting
     the lattice-gap framework to the catalog's tropical machinery.

  ## Building on Catalog Material

  From `TropicalKeplerOrbits.lean`:
  - `tropicalVal` and `tropicalVal_mul`, `tropicalVal_pow`: used in scaling
    and valuation gap theorems
  - `tropicalVal_anti`: reversal of order under valuation
  - `keplerCoeffX_scale`, `keplerCoeffConst_scale`: motivate scaling invariance
  - `keplerSupportSize` analysis: motivates subdivision-preservation framework
-/
import Mathlib
import Pythagorean.TropicalKAMDefs

open Finset BigOperators

noncomputable section

namespace TropicalKAM

/-! ## Section 1: Basic Properties of l1Norm and latticeInner -/

/-- The zero vector has L1 norm zero. -/
theorem l1Norm_eq_zero_of_zero {n : ℕ} : l1Norm (0 : Fin n → ℤ) = 0 := by
  simp [l1Norm]

/-
If L1 norm is zero, all components are zero.
-/
theorem l1Norm_zero_imp_eq_zero {n : ℕ} {k : Fin n → ℤ} (h : l1Norm k = 0) :
    k = 0 := by
  exact funext fun i => Int.natAbs_eq_zero.mp ( by simpa [ l1Norm ] using h |> fun h => Finset.sum_eq_zero_iff_of_nonneg ( fun _ _ => by positivity ) |>.1 h i )

/-- L1 norm is zero iff the vector is zero. -/
theorem l1Norm_eq_zero_iff {n : ℕ} {k : Fin n → ℤ} :
    l1Norm k = 0 ↔ k = 0 := by
  constructor
  · exact l1Norm_zero_imp_eq_zero
  · intro h; subst h; exact l1Norm_eq_zero_of_zero

/-- Inner product with zero vector is zero. -/
theorem latticeInner_zero_left {n : ℕ} (ω : Fin n → ℝ) :
    latticeInner (0 : Fin n → ℤ) ω = 0 := by
  simp [latticeInner]

/-- The lattice inner product difference equals the inner product with the difference. -/
theorem latticeInner_sub {n : ℕ} (k : Fin n → ℤ) (ω ω' : Fin n → ℝ) :
    latticeInner k ω - latticeInner k ω' = ∑ i : Fin n, (k i : ℝ) * (ω i - ω' i) := by
  simp only [latticeInner, ← Finset.sum_sub_distrib, mul_sub]

/-
Casting identity: ↑(l1Norm k) = ∑ |(k i : ℝ)|.
-/
theorem l1Norm_cast_eq_sum_abs {n : ℕ} (k : Fin n → ℤ) :
    (l1Norm k : ℝ) = ∑ i : Fin n, |(k i : ℝ)| := by
  norm_num [ l1Norm ]

/-! ## Section 2: Inner Product Perturbation Bound -/

/-
**Key perturbation estimate**: The change in lattice inner product is bounded
    by the L1 norm times the maximum componentwise change.

    |⟨k, ω⟩ - ⟨k, ω'⟩| ≤ ‖k‖₁ · δ

    when |ω_i - ω'_i| ≤ δ for all i. This is the main technical tool for
    the resonance rigidity and perturbation stability theorems.
-/
theorem innerProdZR_perturbation_bound {n : ℕ} (k : Fin n → ℤ) (ω ω' : Fin n → ℝ) (δ : ℝ)
    (hδ : 0 ≤ δ) (hclose : ∀ i : Fin n, |ω i - ω' i| ≤ δ) :
    |latticeInner k ω - latticeInner k ω'| ≤ ↑(l1Norm k) * δ := by
  rw [ latticeInner_sub ];
  refine' le_trans ( Finset.abs_sum_le_sum_abs _ _ ) _;
  convert Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( hclose i ) ( abs_nonneg ( k i : ℝ ) ) using 1 ; norm_num [ abs_mul, l1Norm_cast_eq_sum_abs ] ; ring;
  norm_num [ ← Finset.sum_mul, l1Norm_cast_eq_sum_abs ]

/-
Strict version of the perturbation bound for strict closeness.
-/
theorem innerProdZR_perturbation_strict {n : ℕ} (k : Fin n → ℤ) (ω ω' : Fin n → ℝ) (δ : ℝ)
    (hδ : 0 < δ) (hclose : ∀ i : Fin n, |ω i - ω' i| < δ)
    (hk : 0 < l1Norm k) :
    |latticeInner k ω - latticeInner k ω'| < ↑(l1Norm k) * δ := by
  -- We have |latticeInner k ω - latticeInner k ω'| ≤ ∑ i, |(k i : ℝ)| * |ω i - ω' i| by absolute value of sum ≤ sum of absolute values, and linearity of lattice inner product gives this as ∑ i, |(k i : ℝ)| * |ω i - ω' i|.
  have h_le_sum : |latticeInner k ω - latticeInner k ω'| ≤ ∑ i : Fin n, |(k i : ℝ)| * |ω i - ω' i| := by
    convert Finset.abs_sum_le_sum_abs _ _ using 2 ; simp +decide [ latticeInner_sub, abs_mul ];
    exacts [ rfl, by rw [ ← abs_mul ], inferInstance ];
  refine' lt_of_le_of_lt h_le_sum _;
  convert Finset.sum_lt_sum ?_ ?_;
  any_goals try infer_instance;
  rotate_left;
  use fun i => |(k i : ℝ)| * δ;
  · exact fun i _ => mul_le_mul_of_nonneg_left ( le_of_lt ( hclose i ) ) ( abs_nonneg _ );
  · contrapose! hk; simp_all +decide [ l1Norm ] ;
    exact fun i => by_contra fun hi => absurd ( hk i ) ( not_le_of_gt ( mul_lt_mul_of_pos_left ( hclose i ) ( abs_pos.mpr ( Int.cast_ne_zero.mpr hi ) ) ) ) ;
  · norm_num [ ← Finset.sum_mul _ _ _, l1Norm_cast_eq_sum_abs ]

/-! ## Section 3: Diophantine Monotonicity -/

/-- Tropical Diophantine condition is monotone in K: smaller K is weaker. -/
theorem tropical_diophantine_mono {n : ℕ} {K K' : ℕ} {C : ℝ} {ω : Fin n → ℝ}
    (hle : K' ≤ K) (h : TropicalDiophantine K C ω) :
    TropicalDiophantine K' C ω :=
  fun k hk_pos hk_le => h k hk_pos (le_trans hk_le hle)

/-! ## Section 4: Resonance Rigidity (Main Theorem) -/

/-
**Resonance Rigidity Theorem**: If ω is tropical Diophantine with parameters
    (K, C) with C > 0, K > 0, and ω' is componentwise within C/(2K) of ω,
    then ω and ω' have identical resonance profiles up to scale K.

    This is the tropical replacement for classical small-divisor control.

    **Proof idea**: For k with 0 < ‖k‖₁ ≤ K, the Diophantine condition gives
    |⟨k,ω⟩| ≥ C. The perturbation bound gives |⟨k,ω⟩ - ⟨k,ω'⟩| < C/2.
    By the reverse triangle inequality, |⟨k,ω'⟩| ≥ C - C/2 = C/2 > 0.
    So neither ⟨k,ω⟩ nor ⟨k,ω'⟩ is zero, and the resonance biconditional
    (False ↔ False) holds. For ‖k‖₁ = 0, k = 0 and both inner products
    vanish, so (True ↔ True) holds.
-/
theorem tropical_diophantine_implies_resonance_rigidity
    {n : ℕ} (K : ℕ) (C : ℝ) (ω ω' : Fin n → ℝ)
    (hDio : TropicalDiophantine K C ω)
    (hC : 0 < C) (hK : 0 < K)
    (hclose : ∀ i, |ω i - ω' i| < C / (2 * ↑K)) :
    SameResonanceProfile K ω ω' := by
  intro k hk;
  by_cases h : l1Norm k = 0 <;> simp_all +decide [ TropicalDiophantine ];
  · rw [ l1Norm_eq_zero_iff.mp h ] ; norm_num [ latticeInner ];
  · -- By the reverse triangle inequality, |latticeInner k ω'| ≥ |latticeInner k ω| - |latticeInner k ω - latticeInner k ω'| ≥ C - C/2 = C/2 > 0.
    have h_reverse_triangle : |latticeInner k ω'| ≥ C - C / 2 := by
      have h_reverse_triangle : |latticeInner k ω - latticeInner k ω'| < C / 2 := by
        refine' lt_of_lt_of_le ( innerProdZR_perturbation_strict k ω ω' ( C / ( 2 * K ) ) ( by positivity ) hclose ( Nat.pos_of_ne_zero h ) ) _;
        rw [ mul_div, div_le_iff₀ ] <;> nlinarith [ show ( l1Norm k : ℝ ) ≤ K by norm_cast, show ( l1Norm k : ℝ ) ≥ 1 by exact_mod_cast Nat.one_le_iff_ne_zero.mpr h ];
      cases abs_cases ( latticeInner k ω ) <;> cases abs_cases ( latticeInner k ω' ) <;> linarith [ abs_lt.mp h_reverse_triangle, hDio k ( Nat.pos_of_ne_zero h ) hk ];
    grind

/-! ## Section 5: Diophantine Perturbation Stability -/

/-
**Perturbation Stability Theorem**: If ω is tropical Diophantine with
    constant C, then any ω' within C/(2K) is Diophantine with constant C/2.

    This proves the Diophantine condition is *open* in the sup-norm topology
    at finite scale, establishing the structural stability needed for KAM.

    **Proof idea**: For k with 0 < ‖k‖₁ ≤ K:
    |⟨k,ω'⟩| ≥ |⟨k,ω⟩| - |⟨k,ω⟩ - ⟨k,ω'⟩| ≥ C - ‖k‖₁ · C/(2K) ≥ C - C/2 = C/2.
-/
theorem tropical_diophantine_perturbation_stable
    {n : ℕ} (K : ℕ) (C : ℝ) (ω ω' : Fin n → ℝ)
    (hDio : TropicalDiophantine K C ω)
    (hC : 0 < C) (hK : 0 < K)
    (hclose : ∀ i, |ω i - ω' i| < C / (2 * ↑K)) :
    TropicalDiophantine K (C / 2) ω' := by
  intro k hk_pos hk_le_K
  have h_inner : |latticeInner k ω - latticeInner k ω'| < C / 2 := by
    refine' lt_of_lt_of_le ( innerProdZR_perturbation_strict k ω ω' ( C / ( 2 * K ) ) ( by positivity ) hclose hk_pos ) _;
    rw [ mul_div, div_le_iff₀ ] <;> nlinarith [ show ( l1Norm k : ℝ ) ≤ K by norm_cast, show ( K : ℝ ) ≥ 1 by norm_cast ];
  cases abs_cases ( latticeInner k ω ) <;> cases abs_cases ( latticeInner k ω' ) <;> linarith [ abs_lt.mp h_inner, hDio k hk_pos hk_le_K ]

/-! ## Section 6: Finite-Scale Tropical KAM Persistence -/

/-- **Tropical KAM Theorem (Finite Scale)**: The flagship persistence result.

    If ω is Diophantine at scale K with constant C, then any frequency ω'
    sufficiently close to ω (within C/(2K) componentwise):

    1. Has the same resonance profile as ω up to scale K
    2. Is itself Diophantine at scale K with constant C/2

    This is the tropical analog of the classical KAM persistence theorem:
    quasi-periodic structure, encoded in the resonance profile, survives
    perturbation when protected by a Diophantine gap.

    The proof composes the resonance rigidity theorem with the perturbation
    stability theorem. -/
theorem tropical_KAM_finite_scale
    {n : ℕ} (K : ℕ) (C : ℝ) (ω ω' : Fin n → ℝ)
    (hK : 0 < K) (hC : 0 < C)
    (hDio : TropicalDiophantine K C ω)
    (hclose : ∀ i, |ω i - ω' i| < C / (2 * ↑K)) :
    SameResonanceProfile K ω ω' ∧ TropicalDiophantine K (C / 2) ω' :=
  ⟨tropical_diophantine_implies_resonance_rigidity K C ω ω' hDio hC hK hclose,
   tropical_diophantine_perturbation_stable K C ω ω' hDio hC hK hclose⟩

/-! ## Section 7: Resonance Obstruction (Number Theory Connection) -/

/-
**Resonance Obstruction**: An exact resonance at scale K is a fatal
    obstruction to the Diophantine condition with any positive gap.

    If there exists k with 0 < ‖k‖₁ ≤ K and ⟨k,ω⟩ = 0, then ω cannot
    be (K,C)-Diophantine for any C > 0.

    This connects to number theory: rational dependencies among frequency
    components create resonances that prevent Diophantine stability.
    It is the tropical analog of the classical fact that resonant tori
    are destroyed by arbitrarily small perturbations.
-/
theorem resonance_implies_not_diophantine
    {n : ℕ} (K : ℕ) (C : ℝ) (ω : Fin n → ℝ) (hC : 0 < C)
    (k : Fin n → ℤ) (hk_pos : 0 < l1Norm k) (hk_le : l1Norm k ≤ K)
    (hres : latticeInner k ω = 0) :
    ¬TropicalDiophantine K C ω := by
  -- By definition of TropicalDiophantine, if latticeInner k ω = 0, then C ≤ 0, which contradicts hC.
  intros hDio
  have := hDio k hk_pos hk_le
  simp [hres] at this
  linarith

/-
**Rational Frequency Resonance** (Cross-domain: Number Theory):
    In dimension ≥ 2, any rational frequency vector admits a nontrivial
    integer relation. Specifically, given ω₀ = p₀/q₀ and ω₁ = p₁/q₁,
    the lattice vector k with k₀ = q₁·p₀ and k₁ = -q₀·p₁ (and zeros
    elsewhere) gives ⟨k,ω⟩ = 0.

    This means rational frequency vectors can never be tropical Diophantine
    at sufficiently large scale, aligning tropical KAM with classical results:
    Diophantine conditions naturally select irrational frequencies.
-/
theorem rational_admits_resonance
    {n : ℕ} (hn : 2 ≤ n) (ω : Fin n → ℚ)
    (h0 : ω ⟨0, by omega⟩ ≠ 0) (h1 : ω ⟨1, by omega⟩ ≠ 0) :
    ∃ k : Fin n → ℤ, 0 < l1Norm k ∧ latticeInner k (fun i => (ω i : ℝ)) = 0 := by
  refine' ⟨ fun i ↦ if i = ⟨ 0, by linarith ⟩ then ( ω ⟨ 1, by linarith ⟩ |> Rat.num ) * ( ω ⟨ 0, by linarith ⟩ |> Rat.den ) else if i = ⟨ 1, by linarith ⟩ then - ( ω ⟨ 0, by linarith ⟩ |> Rat.num ) * ( ω ⟨ 1, by linarith ⟩ |> Rat.den ) else 0, _, _ ⟩ <;> simp_all +decide [ l1Norm, latticeInner ];
  · rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ ⟨ 0, by linarith ⟩ ) ];
    exact add_pos_of_pos_of_nonneg ( Int.natAbs_pos.mpr ( mul_ne_zero ( Rat.num_ne_zero.mpr h1 ) ( Nat.cast_ne_zero.mpr ( Rat.den_nz _ ) ) ) ) ( Nat.zero_le _ );
  · simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne' ];
    simp +decide [ ← mul_assoc, ← eq_sub_iff_add_eq', Rat.cast_def ];
    field_simp

/-
**Rational frequencies are not universally Diophantine**: For C > 0
    and nonzero rational ω in dimension ≥ 2, there exists a scale K at which
    the Diophantine condition fails.
-/
theorem rational_not_diophantine_at_scale
    {n : ℕ} (hn : 2 ≤ n) (C : ℝ) (hC : 0 < C)
    (ω : Fin n → ℚ)
    (h0 : ω ⟨0, by omega⟩ ≠ 0) (h1 : ω ⟨1, by omega⟩ ≠ 0) :
    ∃ K : ℕ, ¬TropicalDiophantine K C (fun i => (ω i : ℝ)) := by
  obtain ⟨ k, hk₁, hk₂ ⟩ := rational_admits_resonance hn ω h0 h1;
  exact ⟨ l1Norm k, fun h => absurd ( h k hk₁ le_rfl ) ( by aesop ) ⟩

/-! ## Section 8: Scaling Invariance (Tropical Geometry Connection) -/

/-
**Scaling Invariance**: The Diophantine condition transforms predictably
    under frequency scaling. If ω is (K,C)-Diophantine, then λω is
    (K, |λ|·C)-Diophantine.

    In tropical coordinates (under the valuation v(x) = -log|x|),
    this becomes: the tropical Diophantine gap shifts additively
    under multiplicative scaling. This connects to the catalog's
    `tropicalVal_mul` property: v(λω) = v(λ) + v(ω).

    Combined with the catalog's `keplerCoeffX_scale` (which shows
    that Kepler conic coefficients scale polynomially), this establishes
    that tropical orbital dynamics is fundamentally scale-covariant.
-/
theorem tropical_diophantine_scaling
    {n : ℕ} (K : ℕ) (C : ℝ) (ω : Fin n → ℝ) (s : ℝ)
    (hDio : TropicalDiophantine K C ω) :
    TropicalDiophantine K (|s| * C) (fun i => s * ω i) := by
  intro k hk₁ hk₂; specialize hDio k hk₁ hk₂; simp_all +decide [ mul_assoc, mul_comm, mul_left_comm ] ;
  convert mul_le_mul_of_nonneg_right hDio ( abs_nonneg s ) using 1 ; simp +decide [ latticeInner, Finset.mul_sum _ _ _ ] ; ring;
  simp +decide only [mul_comm, mul_left_comm, ← Finset.mul_sum _ _ _, ← abs_mul]

/-! ## Section 9: Tropical Homogeneous Level Set Invariance -/

/-- For a tropically homogeneous function of degree d,
    the level set structure shifts predictably under uniform translation.
    This is the tropical analog of the classical result that homogeneous
    Hamiltonians have self-similar energy shells. -/
theorem tropical_homogeneous_level_shift
    {n : ℕ} (H : (Fin n → ℝ) → ℝ) (d : ℝ) (c s : ℝ)
    (hhom : TropicalHomogeneous H d) (x : Fin n → ℝ) :
    H x = c ↔ H (fun i => s + x i) = d * s + c := by
  constructor
  · intro h; rw [hhom s x, h]
  · intro h; have := hhom s x; linarith

/-! ## Section 10: Tropical Valuation of Diophantine Gap -/

/-- Tropical valuation on positive reals (from catalog). -/
noncomputable def tropicalVal (x : ℝ) : ℝ := -Real.log x

/-
The tropical valuation reverses the Diophantine gap inequality:
    if C ≤ |⟨k,ω⟩|, then tropicalVal |⟨k,ω⟩| ≤ tropicalVal C.

    This expresses the gap condition in tropical (logarithmic) coordinates,
    connecting the lattice-gap framework to the catalog's tropical valuation
    machinery (`tropicalVal_anti`).
-/
theorem tropical_diophantine_gap_valuation
    {n : ℕ} (k : Fin n → ℤ) (ω : Fin n → ℝ) (C : ℝ)
    (hC : 0 < C)
    (hgap : C ≤ |latticeInner k ω|) :
    tropicalVal |latticeInner k ω| ≤ tropicalVal C := by
  exact neg_le_neg ( Real.log_le_log hC hgap ) |> le_trans <| by unfold tropicalVal; ring_nf; norm_num;

/-! ## Section 11: SameResonanceProfile is an equivalence relation -/

/-- SameResonanceProfile is reflexive. -/
theorem sameResonanceProfile_refl {n : ℕ} (K : ℕ) (ω : Fin n → ℝ) :
    SameResonanceProfile K ω ω :=
  fun _ _ => Iff.rfl

/-- SameResonanceProfile is symmetric. -/
theorem sameResonanceProfile_symm {n : ℕ} {K : ℕ} {ω ω' : Fin n → ℝ}
    (h : SameResonanceProfile K ω ω') :
    SameResonanceProfile K ω' ω :=
  fun k hk => (h k hk).symm

/-- SameResonanceProfile is transitive. -/
theorem sameResonanceProfile_trans {n : ℕ} {K : ℕ} {ω₁ ω₂ ω₃ : Fin n → ℝ}
    (h₁₂ : SameResonanceProfile K ω₁ ω₂)
    (h₂₃ : SameResonanceProfile K ω₂ ω₃) :
    SameResonanceProfile K ω₁ ω₃ :=
  fun k hk => (h₁₂ k hk).trans (h₂₃ k hk)

end TropicalKAM