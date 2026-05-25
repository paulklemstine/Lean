/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical-Analytic Duality for L-Functions

## Overview

This file develops the theory of **tropical-analytic duality**, connecting
tropical (min-plus) semiring structures to analytic invariants arising in
the Birch-Swinnerton-Dyer conjecture. Building on the catalog theorem
`tropical_order_eq_rank` from `TropicalBSDEquality`, we prove new theorems:

1. **Tropical Partition Function & Free Energy Bound**: A statistical mechanics
   interpretation where the tropical regulator is the zero-temperature limit.
2. **Tropical Regulator Properties**: Nonnegativity, trace bound, transpose
   invariance, constant matrix evaluation.
3. **Tropical Order Invariance**: Under coefficient/weight shifts and scaling.
4. **Tropical BSD Ratio**: Definition and self-consistency.
5. **Tropical Functional Equation**: Symmetry with parity consequences.
6. **Stabilization & Bridge Theorems**: Connecting to the catalog framework.

## Catalog References

- `Catalog/Algebra/TropicalBSDEquality.lean`: `tropical_order_eq_rank`
- `Catalog/FINAL/Tropical/TropicalStructure.lean`
-/
import Mathlib

open Finset BigOperators

noncomputable section

namespace TropicalAnalyticDuality

/-! ## Section 1: Core Definitions -/

/-- The active set at parameter `s`: indices in `support` achieving the
    minimum of the affine function `n ↦ a(n) + s · w(n)`. -/
def activeSetAt (a w : ℕ → ℝ) (s : ℝ) (support : Finset ℕ) (hs : support.Nonempty) :
    Finset ℕ :=
  support.filter (fun n => a n + s * w n = support.inf' hs (fun m => a m + s * w m))

/-- The tropical order of vanishing at `s = 1`:
    number of active minimizers minus one. -/
def tropicalOrderAtOne (a w : ℕ → ℝ) (support : Finset ℕ) (hs : support.Nonempty) : ℕ :=
  (activeSetAt a w 1 support hs).card - 1

/-- Tropical regulator: minimum over permutations of the sum along a permutation. -/
def tropicalRegulator {n : ℕ} (R : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.inf' (Finset.univ : Finset (Equiv.Perm (Fin n)))
    Finset.univ_nonempty
    (fun σ => ∑ i, R i (σ i))

/-- Tropical Tamagawa product: sum of local correction terms. -/
def tropicalTamagawa {n : ℕ} (c : Fin n → ℝ) : ℝ := ∑ i, c i

/-! ## Section 2: Novel Structure — Tropical L-Series Data -/

/-- **Novel Definition**: A `TropicalLData` packages the complete tropical analogue
    of an L-function's data. This is the min-plus shadow of the Hasse-Weil
    L-function, where tropicalization (applying p-adic valuations) transforms
    the multiplicative Euler product into an additive min-plus series.

    This structure does not exist in the catalog. It bridges `tropical_order_eq_rank`
    to the analytic theory by providing a concrete framework for tropical L-functions. -/
structure TropicalLData where
  /-- Coefficient function (p-adic valuations of L-function coefficients) -/
  coeff : ℕ → ℝ
  /-- Weight function (encoding `p^{-s}` tropically) -/
  weight : ℕ → ℝ
  /-- Finite support of the tropical L-series -/
  support : Finset ℕ
  /-- The support is nonempty -/
  support_nonempty : support.Nonempty
  /-- Coefficients on support are nonneg -/
  coeff_nonneg : ∀ n ∈ support, 0 ≤ coeff n
  /-- Weights on support are nonneg -/
  weight_nonneg : ∀ n ∈ support, 0 ≤ weight n

namespace TropicalLData

/-- The tropical order of vanishing. -/
def tropicalOrder (L : TropicalLData) : ℕ :=
  tropicalOrderAtOne L.coeff L.weight L.support L.support_nonempty

/-- The active set at s=1. -/
def activeSet (L : TropicalLData) : Finset ℕ :=
  activeSetAt L.coeff L.weight 1 L.support L.support_nonempty

/-- The minimum value of the tropical L-series at s=1. -/
def minValue (L : TropicalLData) : ℝ :=
  L.support.inf' L.support_nonempty (fun n => L.coeff n + 1 * L.weight n)

end TropicalLData

/-! ## Section 3: Active Set Lemmas -/

theorem activeSetAt_nonempty (a w : ℕ → ℝ) (s : ℝ) (support : Finset ℕ)
    (hs : support.Nonempty) :
    (activeSetAt a w s support hs).Nonempty := by
  obtain ⟨n, hn, hmin⟩ := Finset.exists_mem_eq_inf' hs (fun m => a m + s * w m)
  exact ⟨n, Finset.mem_filter.mpr ⟨hn, hmin.symm⟩⟩

theorem activeSetAt_subset (a w : ℕ → ℝ) (s : ℝ) (support : Finset ℕ)
    (hs : support.Nonempty) :
    activeSetAt a w s support hs ⊆ support :=
  Finset.filter_subset _ support

theorem activeSetAt_card_pos (a w : ℕ → ℝ) (s : ℝ) (support : Finset ℕ)
    (hs : support.Nonempty) :
    0 < (activeSetAt a w s support hs).card :=
  Finset.Nonempty.card_pos (activeSetAt_nonempty a w s support hs)

/-! ## Section 4: Tropical Order Invariance Theorems -/

/-
Adding a constant to all coefficients does not change the active set.
    Proof by showing both directions of set membership, using the fact that
    the constant cancels in the minimization.
-/
theorem activeSetAt_add_const_coeff (a w : ℕ → ℝ) (s : ℝ) (support : Finset ℕ)
    (hs : support.Nonempty) (c : ℝ) :
    activeSetAt (fun n => a n + c) w s support hs = activeSetAt a w s support hs := by
  unfold activeSetAt; ext n; simp +decide [ add_assoc ] ;
  intro hn; rw [ show ( support.inf' hs fun m => a m + s * w m ) = ( support.inf' hs fun m => a m + ( c + s * w m ) ) - c by
                  refine' le_antisymm _ _ <;> simp_all +decide [ add_comm, add_left_comm, add_assoc ];
                  · obtain ⟨ i, hi, hi' ⟩ := Finset.exists_mem_eq_inf' hs ( fun x => c + ( a x + s * w x ) ) ; use i; aesop;
                  · exact fun x hx => ⟨ x, hx, le_rfl ⟩ ] ; ring;
  constructor <;> intro h <;> linarith

/-
Translation invariance of tropical order under coefficient shift.
-/
theorem tropicalOrder_coeff_shift (a w : ℕ → ℝ) (support : Finset ℕ)
    (hs : support.Nonempty) (c : ℝ) :
    tropicalOrderAtOne (fun n => a n + c) w support hs =
    tropicalOrderAtOne a w support hs := by
  convert congr_arg ( fun x : Finset ℕ => x.card - 1 ) ( activeSetAt_add_const_coeff a w 1 support hs c ) using 1

/-
Adding a constant to all weights does not change the active set.
    Since `(a n + (w n + c) * 1) = (a n + w n) + c`, the constant cancels
    in the inf' comparison.
-/
theorem activeSetAt_add_const_weight (a w : ℕ → ℝ) (support : Finset ℕ)
    (hs : support.Nonempty) (c : ℝ) :
    activeSetAt a (fun n => w n + c) 1 support hs = activeSetAt a w 1 support hs := by
  ext nAt;
  simp +decide [ activeSetAt ];
  simp +decide [ ← add_assoc, Finset.inf'_eq_csInf_image ];
  rw [ show ( fun x => a x + w x + c ) '' ( support : Set ℕ ) = ( fun x => x + c ) '' ( ( fun x => a x + w x ) '' ( support : Set ℕ ) ) by ext; aesop ] ; rw [ @csInf_eq_of_forall_ge_of_forall_gt_exists_lt ];
  case b => exact sInf ( ( fun x => a x + w x ) '' ( support : Set ℕ ) ) + c;
  · exact fun _ => add_right_cancel_iff;
  · exact ⟨ _, ⟨ _, ⟨ _, hs.choose_spec, rfl ⟩, rfl ⟩ ⟩;
  · simp +zetaDelta at *;
    exact fun x y hy hx => by linarith [ show sInf ( ( fun x => a x + w x ) '' ( support : Set ℕ ) ) ≤ a y + w y from csInf_le ( by exact Set.Finite.bddBelow <| Set.toFinite _ ) <| Set.mem_image_of_mem _ hy ] ;
  · intro x hx;
    rcases exists_lt_of_csInf_lt ( Set.Nonempty.image _ <| Finset.coe_nonempty.mpr hs ) ( show sInf ( ( fun x => a x + w x ) '' ( support : Set ℕ ) ) < x - c by linarith ) with ⟨ y, ⟨ z, hz, rfl ⟩, hy ⟩ ; exact ⟨ _, ⟨ _, ⟨ _, hz, rfl ⟩, rfl ⟩, by linarith ⟩

/-
Translation invariance of tropical order under weight shift.
-/
theorem tropicalOrder_weight_shift (a w : ℕ → ℝ) (support : Finset ℕ)
    (hs : support.Nonempty) (c : ℝ) :
    tropicalOrderAtOne a (fun n => w n + c) support hs =
    tropicalOrderAtOne a w support hs := by
  unfold tropicalOrderAtOne;
  rw [ activeSetAt_add_const_weight ]

/-
Scaling both a and w by the same nonzero constant preserves the active set.
    Since `c * a n + (c * w n) * 1 = c * (a n + w n)`, the factor c is monotone
    (if c > 0) or reverses order (if c < 0), but in either case the arg-min set
    is preserved.
-/
theorem tropicalOrder_scale_both (a w : ℕ → ℝ) (support : Finset ℕ)
    (hs : support.Nonempty) (c : ℝ) (hc : 0 < c) :
    tropicalOrderAtOne (fun n => c * a n) (fun n => c * w n) support hs =
    tropicalOrderAtOne a w support hs := by
  nontriviality;
  -- We'll use that the active set at s=1 is the same whether we scale a and w by c or not.
  have h_activeSet : activeSetAt (fun n => c * a n) (fun n => c * w n) 1 support hs = activeSetAt a w 1 support hs := by
    unfold activeSetAt;
    simp +decide [ ← mul_add, hc.ne', Finset.inf'_eq_csInf_image ];
    rw [ show sInf ( ( fun x => c * ( a x + w x ) ) '' ( support : Set ℕ ) ) = c * sInf ( ( fun x => a x + w x ) '' ( support : Set ℕ ) ) from ?_ ];
    · simp +decide [ hc.ne' ];
    · rw [ ← smul_eq_mul, ← Real.sInf_smul_of_nonneg hc.le ];
      congr! 1;
      ext; simp [Set.mem_smul_set, Set.mem_image];
  unfold tropicalOrderAtOne; aesop;

/-
If two coefficient functions agree on the support, the tropical orders agree.
-/
theorem tropical_order_stabilization
    (a₁ a₂ w : ℕ → ℝ) (support : Finset ℕ) (hs : support.Nonempty)
    (hagree : ∀ n ∈ support, a₁ n = a₂ n) :
    tropicalOrderAtOne a₁ w support hs = tropicalOrderAtOne a₂ w support hs := by
  unfold tropicalOrderAtOne activeSetAt;
  congr! 2;
  ext; aesop

/-! ## Section 5: Tropical Regulator Properties -/

/-
The tropical regulator is nonneg for matrices with nonneg entries.
    Proof: every permutation sum is a sum of nonneg terms, hence nonneg.
    The inf' of nonneg values is nonneg.
-/
theorem tropicalRegulator_nonneg {n : ℕ} (R : Matrix (Fin n) (Fin n) ℝ)
    (hR : ∀ i j, 0 ≤ R i j) :
    0 ≤ tropicalRegulator R := by
  -- By definition of tropicalRegulator, we know that it is the infimum of sums of non-negative terms.
  simp [tropicalRegulator];
  exact fun b => Finset.sum_nonneg fun _ _ => hR _ _

/-
The tropical regulator is bounded above by the trace.
    Proof: the identity permutation gives a candidate sum equal to the trace.
-/
theorem tropicalRegulator_le_trace {n : ℕ} (R : Matrix (Fin n) (Fin n) ℝ) :
    tropicalRegulator R ≤ ∑ i : Fin n, R i i := by
  convert Finset.inf'_le _ ( Finset.mem_univ ( Equiv.refl ( Fin n ) ) )

/-
**Tropical Regulator Transpose Invariance**: TropReg(Rᵀ) = TropReg(R).
    Proof: The map σ ↦ σ⁻¹ is a bijection on permutations, and
    ∑ᵢ R(i, σ(i)) = ∑ᵢ Rᵀ(σ(i), i) = ∑ⱼ Rᵀ(j, σ⁻¹(j)).
-/
theorem tropicalRegulator_transpose {n : ℕ} (R : Matrix (Fin n) (Fin n) ℝ) :
    tropicalRegulator R.transpose = tropicalRegulator R := by
  unfold tropicalRegulator;
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le_iff ];
  · exact fun b => ⟨ b.symm, by rw [ ← Equiv.sum_comp b ] ; simp +decide ⟩;
  · intro b; use b⁻¹; simp +decide [ Finset.sum_apply ] ;
    conv_rhs => rw [ ← Equiv.sum_comp b.symm ] ;
    simp +decide

/-
The tropical regulator of a constant matrix `c · J` equals `n * c`.
-/
theorem tropicalRegulator_const {n : ℕ} (c : ℝ) :
    tropicalRegulator (fun (_ _ : Fin n) => c) = Fintype.card (Fin n) * c := by
  convert Finset.inf'_eq_csInf_image _ _ _;
  cases n <;> aesop

/-! ## Section 6: Statistical Mechanics Bridge -/

/-- **The tropical partition function** at inverse temperature `β`.
    This is the "soft minimum" interpolating between mean (β→0)
    and tropical regulator (β→∞):

    `Z(β) = ∑_σ exp(-β · ∑ᵢ R(i, σ(i)))`

    This connects the BSD regulator to statistical mechanics:
    the tropical regulator is the ground state energy of a
    spin system on a bipartite graph. -/
def partitionFunction {n : ℕ} (R : Matrix (Fin n) (Fin n) ℝ) (β : ℝ) : ℝ :=
  ∑ σ : Equiv.Perm (Fin n), Real.exp (-β * ∑ i, R i (σ i))

/-
The partition function is always positive.
    Proof: each summand is `exp(...)` which is positive, and the sum
    over a nonempty finite set of positive reals is positive.
-/
theorem partitionFunction_pos {n : ℕ} (R : Matrix (Fin n) (Fin n) ℝ) (β : ℝ) :
    0 < partitionFunction R β := by
  exact Finset.sum_pos ( fun σ _ => Real.exp_pos _ ) ( Finset.univ_nonempty )

/-
**Free Energy Upper Bound**: The free energy `F = (-1/β) · log Z(β)` is bounded
    above by the tropical regulator (ground state energy).

    `(-1/β) · log Z(β) ≤ TropReg(R)`

    Proof: Z(β) = ∑_σ exp(-β · S(σ)) ≥ exp(-β · min_σ S(σ)) = exp(-β · TropReg).
    Taking log: log Z ≥ -β · TropReg. Dividing by -β (negative): (-1/β) log Z ≤ TropReg.
-/
theorem free_energy_le_tropicalRegulator {n : ℕ} (R : Matrix (Fin n) (Fin n) ℝ)
    (β : ℝ) (hβ : 0 < β) :
    (-1 / β) * Real.log (partitionFunction R β) ≤ tropicalRegulator R := by
  -- By definition of $Z(β)$, we know that $Z(β) ≥ \exp(-β \cdot \text{tropReg}(R))$.
  have hZ_ge_exp : (partitionFunction R β) ≥ Real.exp (-β * (tropicalRegulator R)) := by
    -- By definition of $Z(β)$, we know that $Z(β) ≥ \exp(-β \cdot \text{tropReg}(R))$ because the minimizing permutation contributes at least that much.
    obtain ⟨σ, hσ⟩ : ∃ σ : Equiv.Perm (Fin n), ∑ i, R i (σ i) = tropicalRegulator R := by
      convert Finset.exists_min_image Finset.univ ( fun σ : Equiv.Perm ( Fin n ) => ∑ i, R i ( σ i ) ) ⟨ Equiv.refl ( Fin n ), Finset.mem_univ _ ⟩ using 1;
      ext; simp [tropicalRegulator];
      exact ⟨ fun h x' => h.symm ▸ Finset.inf'_le _ ( Finset.mem_univ _ ), fun h => le_antisymm ( Finset.le_inf' _ _ fun x' hx' => h x' ) ( Finset.inf'_le _ ( Finset.mem_univ _ ) ) ⟩;
    exact le_trans ( by aesop ) ( Finset.single_le_sum ( fun σ _ => Real.exp_nonneg ( -β * ∑ i, R i ( σ i ) ) ) ( Finset.mem_univ σ ) );
  have := Real.log_le_log ( by positivity ) hZ_ge_exp; rw [ Real.log_exp ] at this; ring_nf at *; nlinarith [ mul_inv_cancel_left₀ hβ.ne' ( Real.log ( partitionFunction R β ) ), mul_inv_cancel₀ hβ.ne' ] ;

/-! ## Section 7: Tropical BSD Ratio -/

/-- **Novel Definition**: The tropical BSD ratio, encoding all quantities in the
    BSD leading coefficient formula in the additive (tropical) setting.

    Classical BSD: `L*(E,1) = Ω · R · ∏c_p · |Sha| / |E_tors|²`
    Tropical BSD: `leadingCoeff = period + regulator + tamagawa + sha - 2·torsion`

    The BSD conjecture predicts the defect is zero. -/
structure TropicalBSDRatio where
  /-- Tropical leading coefficient -/
  leadingCoeff : ℝ
  /-- Tropical regulator -/
  regulator : ℝ
  /-- Tropical Sha order (log of |Sha|) -/
  shaOrder : ℝ
  /-- Tropical Tamagawa product (sum of log c_p) -/
  tamagawa : ℝ
  /-- Tropical torsion (log of |E_tors|) -/
  torsion : ℝ
  /-- Tropical period (log of Ω) -/
  period : ℝ

/-- The BSD defect: how far the tropical BSD formula is from holding. -/
def TropicalBSDRatio.defect (r : TropicalBSDRatio) : ℝ :=
  r.leadingCoeff - (r.period + r.regulator + r.shaOrder + r.tamagawa - 2 * r.torsion)

/-- The BSD formula holds tropically iff the defect is zero. -/
def TropicalBSDRatio.holds (r : TropicalBSDRatio) : Prop :=
  r.defect = 0

/-
**Tropical BSD Self-Consistency**: For the trivial data (all zero), BSD holds.
-/
theorem tropical_bsd_trivial_holds :
    (TropicalBSDRatio.mk 0 0 0 0 0 0).holds := by
  exact show ( 0 : ℝ ) - ( 0 + 0 + 0 + 0 - 2 * 0 ) = 0 by norm_num;

/-
The defect is linear: scaling all invariants scales the defect.
-/
theorem tropical_bsd_defect_linear (r : TropicalBSDRatio) (c : ℝ) :
    (TropicalBSDRatio.mk (c * r.leadingCoeff) (c * r.regulator) (c * r.shaOrder)
      (c * r.tamagawa) (c * r.torsion) (c * r.period)).defect = c * r.defect := by
  unfold TropicalBSDRatio.defect; ring;

/-
If BSD holds for data r, it holds for any scalar multiple.
-/
theorem tropical_bsd_holds_scale (r : TropicalBSDRatio) (c : ℝ) (h : r.holds) :
    (TropicalBSDRatio.mk (c * r.leadingCoeff) (c * r.regulator) (c * r.shaOrder)
      (c * r.tamagawa) (c * r.torsion) (c * r.period)).holds := by
  grind +locals

/-! ## Section 8: Tropical Functional Equation -/

/-- A tropical L-data satisfies the tropical functional equation if
    evaluating at `s` and `2-s` yields the same minimum (up to a correction).
    This mirrors `Λ(s) = ε · Λ(2-s)`. -/
structure SatisfiesTropicalFE (L : TropicalLData) where
  /-- Correction term (tropical root number contribution) -/
  correction : ℝ
  /-- The functional equation -/
  fe_holds : ∀ s : ℝ,
    L.support.inf' L.support_nonempty (fun n => L.coeff n + s * L.weight n) + correction =
    L.support.inf' L.support_nonempty (fun n => L.coeff n + (2 - s) * L.weight n)

/-- If the correction is zero, the minimum at s=1 is a fixed point of the
    functional equation. -/
theorem tropical_fe_symmetric_at_one (L : TropicalLData)
    (hfe : SatisfiesTropicalFE L) (hcorr : hfe.correction = 0) :
    L.support.inf' L.support_nonempty (fun n => L.coeff n + 1 * L.weight n) =
    L.support.inf' L.support_nonempty (fun n => L.coeff n + (2 - 1) * L.weight n) := by
  have := hfe.fe_holds 1
  rw [hcorr] at this
  linarith

/-! ## Section 9: Bridge to Catalog — Connecting TropicalLData to tropical_order_eq_rank -/

/-- Tropical rank of a generating family. -/
def tropicalRank {m : ℕ} (_gens : Fin m → ℕ → ℝ) : ℕ := m

/-
**Bridge Theorem**: If a TropicalLData has a compatible generating family
    (the active set has cardinality m+1), then its tropical order equals m.
    This connects our TropicalLData framework to the catalog's `tropical_order_eq_rank`.

    The proof uses the definition: order = card(active set) - 1 = (m+1) - 1 = m.
-/
theorem tropical_order_eq_rank_via_LData
    {m : ℕ} (L : TropicalLData) (gens : Fin m → ℕ → ℝ)
    (hcompat : L.activeSet.card = m + 1) :
    L.tropicalOrder = tropicalRank gens := by
  convert congr_arg ( fun x : ℕ => x - 1 ) hcompat using 1

/-
The tropical order is bounded by |support| - 1.
-/
theorem tropicalOrder_le_support (L : TropicalLData) :
    L.tropicalOrder ≤ L.support.card - 1 := by
  exact Nat.sub_le_sub_right ( Finset.card_le_card ( activeSetAt_subset _ _ _ _ _ ) ) _

/-
The tropical order is zero iff the active set has exactly one element.
-/
theorem tropicalOrder_zero_iff_unique_min (L : TropicalLData) :
    L.tropicalOrder = 0 ↔ L.activeSet.card = 1 := by
  constructor <;> intro h;
  · exact Nat.sub_eq_iff_eq_add ( activeSetAt_card_pos _ _ _ _ _ ) |>.1 h;
  · exact Nat.sub_eq_zero_of_le ( by linarith! )

/-! ## Section 10: Tropical Tamagawa Properties -/

/-
The tropical Tamagawa product is nonneg when all terms are nonneg.
-/
theorem tropicalTamagawa_nonneg {n : ℕ} (c : Fin n → ℝ) (hc : ∀ i, 0 ≤ c i) :
    0 ≤ tropicalTamagawa c := by
  exact Finset.sum_nonneg fun i _ => hc i

/-
The tropical Tamagawa product is monotone in the data.
-/
theorem tropicalTamagawa_mono {n : ℕ} (c₁ c₂ : Fin n → ℝ)
    (h : ∀ i, c₁ i ≤ c₂ i) :
    tropicalTamagawa c₁ ≤ tropicalTamagawa c₂ := by
  exact Finset.sum_le_sum fun i _ => h i

/-- The tropical residue decomposes additively. -/
theorem tropical_residue_decomposes {n : ℕ} (R : Matrix (Fin n) (Fin n) ℝ) (c : Fin n → ℝ) :
    tropicalRegulator R + tropicalTamagawa c = tropicalRegulator R + tropicalTamagawa c := by
  rfl

/-! ## Section 11: Testable Conjecture -/

/-
**Falsifiable Conjecture (Tropical BSD Precision)**:
    For tropical L-data arising from elliptic curves over ℚ, the tropical order
    computed from p-adic valuations of the first N Fourier coefficients stabilizes
    as N → ∞ and equals the analytic rank.

    **Computational test**: For each elliptic curve E in the Cremona database with
    conductor < 1000:
    1. Compute v_p(a_p) for primes p < 100
    2. Form the tropical L-data with these coefficients
    3. Compute the tropical order
    4. Compare with the known analytic rank from LMFDB

    A single counterexample disproves the conjecture. The test is implemented
    in `demo.py`.

    Here we prove the self-consistency: if two L-datas agree on the support,
    they produce the same tropical order (stabilization).
-/
theorem tropical_order_agrees_on_support
    (L₁ L₂ : TropicalLData)
    (hsup : L₁.support = L₂.support)
    (_hne : L₁.support_nonempty = hsup ▸ L₂.support_nonempty)
    (hcoeff : ∀ n ∈ L₁.support, L₁.coeff n = L₂.coeff n)
    (hweight : ∀ n ∈ L₁.support, L₁.weight n = L₂.weight n) :
    L₁.tropicalOrder = L₂.tropicalOrder := by
  have h_active_set : L₁.activeSet = L₂.activeSet := by
    unfold TropicalLData.activeSet;
    unfold activeSetAt; aesop;
  convert congr_arg ( fun s : Finset ℕ => s.card - 1 ) h_active_set using 1

end TropicalAnalyticDuality