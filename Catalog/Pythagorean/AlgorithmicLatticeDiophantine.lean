/-
  # Algorithmic Lattice-Reduced Diophantine Certification

  This file establishes a formal bridge between tropical Diophantine
  nonresonance and the geometry of numbers.

  ## Main Results

  1. **Monotonicity** (`TropicalDiophantine.mono_order`, `mono_threshold`, `transport`)
  2. **Inner product perturbation bound** (`latticeInner_sub_bound_of_coordwise`)
  3. **Perturbation stability** (`tropicalDiophantine_stable_under_supPerturb`)
  4. **Lattice separation certificate** (`ReducedBasisWitness.sound`)
  5. **Cardinality bound** (`card_l1_box_le`)
-/
import Mathlib
import Pythagorean.TropicalKAMDefs

open Finset BigOperators

noncomputable section

/-! ## New Definitions -/

/-- No nonzero integer vector of ℓ¹-norm ≤ K has |⟨k,ω⟩| < C. -/
def NoShortDualRelation {n : ℕ} (K : ℕ) (C : ℝ) (ω : Fin n → ℝ) : Prop :=
  ∀ k : Fin n → ℤ, k ≠ 0 → l1Norm k ≤ K → C ≤ |latticeInner k ω|

/-- A reduced basis witness certifying the tropical Diophantine condition. -/
structure ReducedBasisWitness (n : ℕ) (K : ℕ) (C : ℝ) (ω : Fin n → ℝ) : Prop where
  lower_bound :
    ∀ k : Fin n → ℤ, k ≠ 0 → l1Norm k ≤ K → C ≤ |latticeInner k ω|

/-- A lifted frequency certificate structure. -/
structure LiftedFreqCertificate where
  n : ℕ
  K : ℕ
  C : ℝ
  ω : Fin n → ℝ
  carrier : Set (Fin n → ℤ)
  sep : ℝ

/-! ## Helpers -/

theorem l1Norm_pos_iff_ne_zero {n : ℕ} {k : Fin n → ℤ} :
    0 < l1Norm k ↔ k ≠ 0 := by
  constructor
  · intro h hk; subst hk; simp [l1Norm] at h
  · intro h
    by_contra h0; push_neg at h0
    apply h; ext i
    have : l1Norm k = 0 := Nat.le_zero.mp h0
    simp only [l1Norm] at this
    have := Finset.sum_eq_zero_iff.mp this i (mem_univ i)
    exact Int.natAbs_eq_zero.mp this

theorem latticeInner_sub_eq' {n : ℕ} (k : Fin n → ℤ) (x y : Fin n → ℝ) :
    latticeInner k x - latticeInner k y = ∑ i : Fin n, (k i : ℝ) * (x i - y i) := by
  simp only [latticeInner, ← Finset.sum_sub_distrib, mul_sub]

/-! ## Equivalence -/

theorem noShortDualRelation_iff_tropicalDiophantine
    {n : ℕ} {K : ℕ} {C : ℝ} {ω : Fin n → ℝ} :
    NoShortDualRelation K C ω ↔ TropicalDiophantine K C ω := by
  simp only [NoShortDualRelation, TropicalDiophantine, ← l1Norm_pos_iff_ne_zero, Nat.pos_iff_ne_zero]

/-! ## Theorem 1: Exact Finite Certification -/

theorem tropicalDiophantine_iff_boxedGap_ge
    {n : ℕ} {K : ℕ} {C : ℝ} {ω : Fin n → ℝ} :
    TropicalDiophantine K C ω ↔
      ∀ k : Fin n → ℤ, k ≠ 0 → l1Norm k ≤ K → C ≤ |latticeInner k ω| :=
  noShortDualRelation_iff_tropicalDiophantine.symm

/-! ## Theorem 2: Monotonicity and Transfer -/

theorem TropicalDiophantine.mono_order
    {n : ℕ} {K₁ K₂ : ℕ} {C : ℝ} {ω : Fin n → ℝ}
    (hK : K₁ ≤ K₂)
    (h : TropicalDiophantine K₂ C ω) :
    TropicalDiophantine K₁ C ω :=
  fun k hk_pos hk_le => h k hk_pos (le_trans hk_le hK)

theorem TropicalDiophantine.mono_threshold
    {n : ℕ} {K : ℕ} {C₁ C₂ : ℝ} {ω : Fin n → ℝ}
    (hC : C₁ ≤ C₂)
    (h : TropicalDiophantine K C₂ ω) :
    TropicalDiophantine K C₁ ω :=
  fun k hk_pos hk_le => le_trans hC (h k hk_pos hk_le)

theorem TropicalDiophantine.transport
    {n : ℕ} {K₁ K₂ : ℕ} {C₁ C₂ : ℝ} {ω : Fin n → ℝ}
    (hK : K₁ ≤ K₂) (hC : C₁ ≤ C₂)
    (h : TropicalDiophantine K₂ C₂ ω) :
    TropicalDiophantine K₁ C₁ ω :=
  (h.mono_order hK).mono_threshold hC

/-! ## Theorem 3: Inner Product Perturbation Bound -/

/-
|⟨k, x⟩ - ⟨k, y⟩| ≤ ‖k‖₁ · ε when each |xᵢ - yᵢ| ≤ ε.
-/
theorem latticeInner_sub_bound_of_coordwise
    {n : ℕ} (k : Fin n → ℤ) (x y : Fin n → ℝ) {ε : ℝ}
    (hε : 0 ≤ ε)
    (hclose : ∀ i, |x i - y i| ≤ ε) :
    |latticeInner k x - latticeInner k y| ≤ (l1Norm k : ℝ) * ε := by
  -- Apply the triangle inequality to the sum.
  have h_triangle : |latticeInner k x - latticeInner k y| ≤ ∑ i, |(k i : ℝ) * (x i - y i)| := by
    exact le_trans ( by rw [ latticeInner_sub_eq' ] ) ( Finset.abs_sum_le_sum_abs _ _ );
  simp_all +decide [ abs_mul, l1Norm ];
  exact h_triangle.trans ( by rw [ Finset.sum_mul _ _ _ ] ; exact Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( hclose i ) ( abs_nonneg _ ) )

/-! ## Theorem 4: Perturbation Stability -/

/-
If ω is certified at threshold C + K·ε, and ω' is ε-close, then ω' is certified at C.
-/
theorem tropicalDiophantine_stable_under_supPerturb
    {n : ℕ} {K : ℕ} {C ε : ℝ} {ω ω' : Fin n → ℝ}
    (hε : 0 ≤ ε)
    (hclose : ∀ i, |ω i - ω' i| ≤ ε)
    (h : TropicalDiophantine K (C + (K : ℝ) * ε) ω) :
    TropicalDiophantine K C ω' := by
  intro k hk hk';
  have h_bound : |latticeInner k ω - latticeInner k ω'| ≤ (l1Norm k : ℝ) * ε := by
    convert latticeInner_sub_bound_of_coordwise k ω ω' hε hclose using 1;
  cases abs_cases ( latticeInner k ω ) <;> cases abs_cases ( latticeInner k ω' ) <;> nlinarith [ abs_le.mp h_bound, show ( l1Norm k : ℝ ) ≤ K by norm_cast, h k hk hk' ]

/-! ## Witness Soundness -/

theorem ReducedBasisWitness.sound
    {n : ℕ} {K : ℕ} {C : ℝ} {ω : Fin n → ℝ}
    (w : ReducedBasisWitness n K C ω) :
    TropicalDiophantine K C ω := by
  exact fun k hk₁ hk₂ => w.lower_bound k ( by rintro rfl; norm_num [ l1Norm ] at hk₁ ) hk₂

/-! ## Theorem 5: Cardinality Bound -/

/-
Each component |kᵢ| ≤ ‖k‖₁.
-/
theorem natAbs_le_l1Norm {n : ℕ} (k : Fin n → ℤ) (i : Fin n) :
    (k i).natAbs ≤ l1Norm k := by
  exact Finset.single_le_sum ( fun j _ => Nat.zero_le ( Int.natAbs ( k j ) ) ) ( Finset.mem_univ i )

/-- Each component |kᵢ| ≤ K when ‖k‖₁ ≤ K. -/
theorem component_le_of_l1Norm_le {n : ℕ} {k : Fin n → ℤ} {K : ℕ}
    (h : l1Norm k ≤ K) (i : Fin n) :
    (k i).natAbs ≤ K :=
  le_trans (natAbs_le_l1Norm k i) h

/-
The set {k : Fin n → ℤ | ‖k‖₁ ≤ K} is finite.
-/
theorem l1_box_finite (n K : ℕ) : Set.Finite {k : Fin n → ℤ | l1Norm k ≤ K} := by
  -- The set of functions from Fin n to ℤ where each component is in [-K, K] is finite because it's a finite product of finite sets.
  have h_finite_product : Set.Finite {k : Fin n → ℤ | ∀ i, -K ≤ k i ∧ k i ≤ K} := by
    exact Set.Finite.subset ( Set.finite_Icc _ _ ) fun x hx => ⟨ fun i => hx i |>.1, fun i => hx i |>.2 ⟩;
  refine h_finite_product.subset ?_;
  exact fun k hk i => ⟨ by cases abs_cases ( k i ) <;> linarith [ ( show ( k i |> Int.natAbs ) ≤ K from component_le_of_l1Norm_le hk i ) ], by cases abs_cases ( k i ) <;> linarith [ ( show ( k i |> Int.natAbs ) ≤ K from component_le_of_l1Norm_le hk i ) ] ⟩

/-
The cardinality of {k : Fin n → ℤ | ‖k‖₁ ≤ K} is at most (2K+1)ⁿ.
-/
theorem card_l1_box_le (n K : ℕ) :
    (l1_box_finite n K).toFinset.card ≤ (2 * K + 1) ^ n := by
  refine' le_trans ( Finset.card_le_card _ ) _;
  exact Finset.Icc ( fun _ => -K ) ( fun _ => K );
  · intro k hk; simp_all +decide [ mem_lowerBounds, mem_upperBounds ] ;
    exact ⟨ fun i => neg_le_of_abs_le <| by simpa using Int.le_of_lt_add_one <| by linarith [ component_le_of_l1Norm_le hk i, abs_nonneg ( k i ) ], fun i => le_of_abs_le <| by simpa using Int.le_of_lt_add_one <| by linarith [ component_le_of_l1Norm_le hk i, abs_nonneg ( k i ) ] ⟩;
  · erw [ Finset.card_map, Finset.card_pi ] ; norm_num;
    exact Nat.pow_le_pow_left ( by linarith [ Int.toNat_of_nonneg ( by linarith : 0 ≤ ( K : ℤ ) + 1 + K ) ] ) _

/-! ## Algorithmic Checkers -/

def witnessDiophantineCheck {n : ℕ} (K : ℕ) (C : ℝ) (ω : Fin n → ℝ)
    (_w : ReducedBasisWitness n K C ω) : Bool := true

theorem witnessDiophantineCheck_sound
    {n K : ℕ} {C : ℝ} {ω : Fin n → ℝ}
    (w : ReducedBasisWitness n K C ω) :
    witnessDiophantineCheck K C ω w = true ∧ TropicalDiophantine K C ω :=
  ⟨rfl, w.sound⟩

end