import Cryptography.TypeChannelMilestone.Sextic
import Cryptography.TypeChannelMilestone.FieldAudit

/-!
# Paper 134 — Chebotarev precision II: the master table, fresh constants, the catches

Experiment 463 recomputed every law value of the type-channel master table from explicit
permutation groups and compared it with the hand-derived constants to six decimals.  This
file is the formal counterpart.

* `logb2_three_gt_conv`, `logb2_three_lt_conv` — a rigorous two-sided enclosure
  `1054/665 < log₂ 3 < 3647/2301` (width `6.5·10⁻⁷`), from the integer inequalities
  `2¹⁰⁵⁴ < 3⁶⁶⁵` and `3²³⁰¹ < 2³⁶⁴⁷` (continued-fraction convergents of `log₂ 3`).
* `F20_channel` — **a new row**: the Frobenius group `F₂₀ = AGL(1,5)` (Galois group of
  e.g. `x⁵ − 2`), with derived subgroup `C₅` and abelianization `C₄`, has channel exactly
  `3/2` bits.
* `F20_C4_collision` — **law collision**: the nonabelian `F₂₀` and the abelian `C₄` have
  the *same* law value `3/2`; a single scalar channel cannot tell them apart.
* `F20_seeded_as_C5_detected` — the ledger catch "F20 seeded as C5": the `C₅` law
  `log₂ 5 − 8/5 < 3/4` differs from the `F₂₀` law by more than `3/4` bit, so the hand
  constant exposes the seeding error immediately.
* `D4_generator_closes_to_S4` — the ledger catch "D4 generator → S4 closure": the 4-cycle
  together with an *adjacent* transposition generates all of `S₄` (law `1`), while the
  true `D₄` contains the 4-cycle and the *diagonal* transposition (law `1.655639`).
* `master_table_precision` — **the master table to six decimals**: all ten law constants
  (`S₃, S₄, A₄, D₄, V₄, C₄, D₆, D₆` with quartic readout, regular `S₃`, `F₂₀`) lie within
  `5·10⁻⁷` of their recorded six-decimal values `1, 1, 0.918296, 1.655639, 0.811278, 1.5,
  1.729574, 1.396241, 1, 1.5`.
-/

namespace TypeChannel

open Finset Real

set_option maxRecDepth 4000000

/-! ### A rigorous enclosure of `log₂ 3` -/

set_option exponentiation.threshold 4000 in
/-- Lower convergent bound: `2¹⁰⁵⁴ < 3⁶⁶⁵`. -/
theorem logb2_three_gt_conv : (1054:ℝ)/665 < logb 2 3 := by
  rw [Real.lt_logb_iff_rpow_lt (by norm_num) (by norm_num)]
  have h : ((2:ℝ) ^ ((1054:ℝ)/665)) ^ (665:ℕ) < (3:ℝ) ^ (665:ℕ) := by
    rw [← Real.rpow_natCast, ← Real.rpow_mul (by norm_num)]
    norm_num
  exact lt_of_pow_lt_pow_left₀ 665 (by norm_num) h

set_option exponentiation.threshold 4000 in
/-- Upper semiconvergent bound: `3²³⁰¹ < 2³⁶⁴⁷`. -/
theorem logb2_three_lt_conv : logb 2 3 < (3647:ℝ)/2301 := by
  rw [Real.logb_lt_iff_lt_rpow (by norm_num) (by norm_num)]
  have h : (3:ℝ) ^ (2301:ℕ) < ((2:ℝ) ^ ((3647:ℝ)/2301)) ^ (2301:ℕ) := by
    rw [← Real.rpow_natCast ((2:ℝ) ^ ((3647:ℝ)/2301)), ← Real.rpow_mul (by norm_num)]
    norm_num
  exact lt_of_pow_lt_pow_left₀ 2301 (by positivity) h

/-- `log₂ 5 < 7/3`, from `5³ < 2⁷`. -/
theorem logb2_five_lt : logb 2 5 < 7/3 := by
  rw [Real.logb_lt_iff_lt_rpow (by norm_num) (by norm_num)]
  have h : (5:ℝ) ^ (3:ℕ) < ((2:ℝ) ^ ((7:ℝ)/3)) ^ (3:ℕ) := by
    rw [← Real.rpow_natCast ((2:ℝ) ^ ((7:ℝ)/3)), ← Real.rpow_mul (by norm_num)]
    norm_num
  exact lt_of_pow_lt_pow_left₀ 3 (by positivity) h

lemma logb2_twenty : logb 2 (20:ℝ) = 2 + logb 2 5 := by
  rw [show (20:ℝ) = 4 * 5 by norm_num, Real.logb_mul (by norm_num) (by norm_num), logb2_four]

lemma logb2_ten : logb 2 (10:ℝ) = 1 + logb 2 5 := by
  rw [show (10:ℝ) = 2 * 5 by norm_num, Real.logb_mul (by norm_num) (by norm_num), logb2_two]

/-! ### The Frobenius group `F₂₀ = AGL(1, 5)` -/

/-- The inverse of the multiplier `i + 1` modulo `5`. -/
def inv5 : Fin 4 → Fin 5 := ![1, 3, 2, 4]

lemma inv5_spec : ∀ i : Fin 4, ∀ b x : Fin 5, inv5 i * (i.succ * x + b - b) = x := by decide

lemma inv5_spec' : ∀ i : Fin 4, ∀ b y : Fin 5, i.succ * (inv5 i * (y - b)) + b = y := by decide

/-- The affine permutation `x ↦ (i + 1)·x + b` of `ℤ/5`. -/
def affPerm (p : Fin 4 × Fin 5) : Equiv.Perm (Fin 5) where
  toFun x := p.1.succ * x + p.2
  invFun y := inv5 p.1 * (y - p.2)
  left_inv x := inv5_spec p.1 p.2 x
  right_inv y := inv5_spec' p.1 p.2 y

/-- `F₂₀`, the Galois group of `x⁵ − 2`: all affine maps of the five roots `α ζ₅^k`. -/
def F20 : Finset (Equiv.Perm (Fin 5)) := univ.image affPerm

/-- Its derived subgroup `C₅`, the translations. -/
def C5t : Finset (Equiv.Perm (Fin 5)) := (univ : Finset (Fin 5)).image (fun b => affPerm (0, b))

/-- The trivial subgroup of `S₅`. -/
def One5 : Finset (Equiv.Perm (Fin 5)) := {1}

/-- The `C₄` coset readout of `F₂₀ / C₅`: the multiplier. -/
def f20Idx (g : Equiv.Perm (Fin 5)) : ℕ := ((g 1 - g 0 : Fin 5) : ℕ)

/-- The regular readout of the abelian `C₅` (image of one root). -/
def root5Idx (g : Equiv.Perm (Fin 5)) : ℕ := (g 0 : ℕ)

set_option maxHeartbeats 4000000 in
lemma F20_isSubgroup : IsSubgroupFinset F20 := ⟨by decide, by decide, by decide⟩
lemma C5t_isSubgroup : IsSubgroupFinset C5t := ⟨by decide, by decide, by decide⟩
lemma One5_isSubgroup : IsSubgroupFinset One5 := ⟨by decide, by decide, by decide⟩
set_option maxHeartbeats 4000000 in
lemma F20_derived : IsDerivedFinset F20 C5t := ⟨by decide, by decide, by decide⟩
lemma C5t_derived : IsDerivedFinset C5t One5 := ⟨by decide, by decide, by decide⟩
set_option maxHeartbeats 4000000 in
lemma F20_coset : IsCosetReadout F20 C5t f20Idx := by unfold IsCosetReadout; decide
lemma C5t_coset : IsCosetReadout C5t One5 root5Idx := by unfold IsCosetReadout; decide

theorem F20_card : F20.card = 20 := by decide

/-- `F₂₀` is nonabelian. -/
theorem F20_nonabelian : ¬ ∀ a ∈ F20, ∀ b ∈ F20, a * b = b * a := by decide

set_option maxHeartbeats 4000000 in
theorem F20_entropy_type : entropy F20 splitType = 11/10 + 1/4 * logb 2 5 := by
  rw [entropy_eq_sumList (A := [(5,0),(0,0),(1,4),(1,0)]) (L := [1,4,5,10])
      (by decide) (by decide) (by decide), F20_card]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 1 20 (by norm_num) (by norm_num),
      neg_prob_logb_real 4 20 (by norm_num) (by norm_num),
      neg_prob_logb_real 5 20 (by norm_num) (by norm_num),
      neg_prob_logb_real 10 20 (by norm_num) (by norm_num)]
  rw [logb2_twenty, logb2_ten, logb2_four]
  simp only [Real.logb_one]
  ring

theorem F20_entropy_coset : entropy F20 f20Idx = 2 := by
  have himg : (F20.image f20Idx).card = 4 := by decide
  rw [entropy_cosetReadout F20_isSubgroup C5t_isSubgroup F20_derived.subset F20_coset, himg]
  simpa using logb2_four

set_option maxHeartbeats 4000000 in
theorem F20_entropy_joint : entropy F20 (pairObs f20Idx splitType) = 8/5 + 1/4 * logb 2 5 := by
  rw [entropy_eq_sumList (A := [(1,(5,0)),(1,(0,0)),(4,(1,4)),(2,(1,0)),(3,(1,0))])
      (L := [1,4,5,5,5]) (by decide) (by decide) (by decide), F20_card]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 1 20 (by norm_num) (by norm_num),
      neg_prob_logb_real 4 20 (by norm_num) (by norm_num),
      neg_prob_logb_real 5 20 (by norm_num) (by norm_num)]
  rw [logb2_twenty, logb2_four]
  simp only [Real.logb_one]
  ring

/-- **The `F₂₀` row of the master table**: exactly `3/2` bits. -/
theorem F20_channel : mutualInfo F20 f20Idx splitType = 3/2 := by
  rw [mutualInfo, F20_entropy_coset, F20_entropy_type, F20_entropy_joint]
  ring

/-- The `F₂₀` loss is exactly half a bit: only the two order-4 cosets are confused. -/
theorem F20_loss : logb 2 (F20.image f20Idx).card - mutualInfo F20 f20Idx splitType = 1/2 := by
  have himg : (F20.image f20Idx).card = 4 := by decide
  rw [himg, F20_channel]
  have : logb 2 ((4:ℕ) : ℝ) = 2 := by simpa using logb2_four
  rw [this]
  norm_num

/-- **Law collision.**  The nonabelian `F₂₀` and the abelian `C₄` (`Φ₅`) have the same
channel, although `F₂₀` has five times as many elements. -/
theorem F20_C4_collision :
    mutualInfo F20 f20Idx splitType = mutualInfo C4 rootIdx splitType ∧
      F20.card = 5 * C4.card := by
  refine ⟨by rw [F20_channel, C4_channel], ?_⟩
  rw [F20_card]; decide

/-! ### The cyclic quintic `C₅` and the "F20 seeded as C5" catch -/

theorem C5t_entropy_type : entropy C5t splitType = logb 2 5 - 8/5 := by
  have hcard : C5t.card = 5 := by decide
  rw [entropy_eq_sumList (A := [(5,0),(0,0)]) (L := [1,4])
      (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 1 5 (by norm_num) (by norm_num),
      neg_prob_logb_real 4 5 (by norm_num) (by norm_num)]
  rw [logb2_four]
  simp only [Real.logb_one]
  ring

/-- The `C₅` law: the abelian channel is the whole type entropy, `log₂ 5 − 8/5`. -/
theorem C5t_channel : mutualInfo C5t root5Idx splitType = logb 2 5 - 8/5 := by
  rw [typeChannel_abelian_eq_entropy C5t_isSubgroup (by decide) C5t_derived C5t_coset, C5t_entropy_type]

/-- **Catch: "F20 seeded as C5".**  Seeding the `F₂₀` field with the `C₅` group moves the
law by more than three quarters of a bit — 75 times the pre-stated `0.01` budget. -/
theorem F20_seeded_as_C5_detected :
    mutualInfo C5t root5Idx splitType < 3/4 ∧
      3/4 < mutualInfo F20 f20Idx splitType - mutualInfo C5t root5Idx splitType := by
  rw [C5t_channel, F20_channel]
  have := logb2_five_lt
  constructor <;> linarith

/-! ### The "D4 generator → S4 closure" catch -/

/-- **Catch: "D4 generator → S4 closure".**  The 4-cycle `x ↦ x + 1` lies in `D₄` together
with the diagonal transposition `(0 2)`, but the *adjacent* transposition `(0 1)` does not
lie in `D₄`, and the 4-cycle with `(0 1)` generates the whole of `S₄`.  The resulting
law `1` is off the `D₄` law by more than half a bit. -/
theorem D4_generator_closes_to_S4 :
    finRotate 4 ∈ D4 ∧ Equiv.swap (0 : Fin 4) 2 ∈ D4 ∧ Equiv.swap (0 : Fin 4) 1 ∉ D4 ∧
      Subgroup.closure ({finRotate 4, Equiv.swap (0 : Fin 4) 1} : Set (Equiv.Perm (Fin 4))) = ⊤ ∧
      1/2 < mutualInfo D4 d4Idx splitType - mutualInfo S4 signIdx splitType := by
  refine ⟨by decide, by decide, by decide, ?_, ?_⟩
  · have h := Equiv.Perm.closure_cycle_adjacent_swap (σ := finRotate 4)
      (isCycle_finRotate) (by rw [support_finRotate]) 0
    simpa using h
  · rw [D4_channel, S4_channel]
    have := logb2_three_lt_two
    linarith

/-! ### The master table to six decimals -/

/-- **The master table reproduces to six decimals.**  Every law constant computed from an
explicit permutation group lies within `5·10⁻⁷` of its recorded six-decimal value. -/
theorem master_table_precision :
    mutualInfo S3 signIdx splitType = 1 ∧
    mutualInfo S4 signIdx splitType = 1 ∧
    |mutualInfo A4 pairIdx splitType - 0.918296| < 5e-7 ∧
    |mutualInfo D4 d4Idx splitType - 1.655639| < 5e-7 ∧
    |mutualInfo V4 rootIdx splitType - 0.811278| < 5e-7 ∧
    mutualInfo C4 rootIdx splitType = 1.5 ∧
    |mutualInfo D6 d6Idx cycleType6 - 1.729574| < 5e-7 ∧
    |mutualInfo D6 d6Idx splitType - 1.396241| < 5e-7 ∧
    mutualInfo S3reg signIdx cycleType6 = 1 ∧
    mutualInfo F20 f20Idx splitType = 1.5 := by
  have hl := logb2_three_gt_conv
  have hu := logb2_three_lt_conv
  refine ⟨S3_channel, S4_channel, ?_, ?_, ?_, ?_, ?_, ?_, S3reg_channel, ?_⟩
  · rw [A4_channel, abs_lt]; constructor <;> norm_num at hl hu ⊢ <;> linarith
  · rw [D4_channel, abs_lt]; constructor <;> norm_num at hl hu ⊢ <;> linarith
  · rw [V4_channel, abs_lt]; constructor <;> norm_num at hl hu ⊢ <;> linarith
  · rw [C4_channel]; norm_num
  · rw [D6_channel, abs_lt]; constructor <;> norm_num at hl hu ⊢ <;> linarith
  · rw [D6_coarse_channel, abs_lt]; constructor <;> norm_num at hl hu ⊢ <;> linarith
  · rw [F20_channel]; norm_num

/-- **Global precision of the fresh constants**: the largest deviation between a law
constant and its six-decimal record is below `5·10⁻⁷` — four orders of magnitude inside
the measured simultaneous deviation `4.8·10⁻⁴`, so the measured deviation is attributable
to the prime sample, not to the constants. -/
theorem master_table_max_deviation :
    max (max |mutualInfo A4 pairIdx splitType - 0.918296|
          |mutualInfo D4 d4Idx splitType - 1.655639|)
        (max (max |mutualInfo V4 rootIdx splitType - 0.811278|
          |mutualInfo D6 d6Idx cycleType6 - 1.729574|)
          |mutualInfo D6 d6Idx splitType - 1.396241|) < 5e-7 := by
  obtain ⟨-, -, h1, h2, h3, -, h4, h5, -, -⟩ := master_table_precision
  exact max_lt (max_lt h1 h2) (max_lt (max_lt h3 h4) h5)

end TypeChannel