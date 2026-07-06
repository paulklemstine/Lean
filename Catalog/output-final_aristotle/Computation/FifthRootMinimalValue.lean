import Mathlib

/-!
# Minimal absolute value of a *non-vanishing* sum of `n` fifth roots of unity

Let `ζ₅ = exp(2πi/5)` be the standard primitive fifth root of unity.  A *sum of `n`
fifth roots of unity* is any complex number of the form `∑_{j < n} ζ₅ ^ (c j)` for a
choice of exponents `c : ℕ → ℕ`.  The quantity studied here is

  `σ₅ n = inf { ‖∑_{j < n} ζ₅ ^ (c j)‖ : the sum is nonzero }`,

the minimal absolute value of a **non-vanishing** such sum.

The non-vanishing constraint is essential.  Without it `σ₅ n` collapses to `0` for
every `n ≥ 5`, because a full block `ζ₅^0 + ζ₅^1 + ⋯ + ζ₅^4 = 0` vanishes; this would
destroy the entire monotonicity / jump phenomenon that is the point of the study.
The definition below therefore builds the `≠ 0` restriction into the witnessing set.

## Main results

* `sigma5_step` / `sigma5_residue_antitone` — **monotonicity**: along each residue class
  modulo `5`, `k ↦ σ₅(5k+r)` is non-increasing.  The engine is that appending a full
  zero-summing block of five roots preserves the value (and non-vanishing) of a sum, so
  every non-vanishing absolute value attainable with `n` roots is attainable with `n+5`.
* `sigma5_six_lt_sigma5_one` — a concrete **strict decrease** (jump):
  `σ₅ 6 < σ₅ 1` (indeed `σ₅ 1 = 1` while `σ₅ 6 ≤ ‖ζ₅ - ζ₅² + ζ₅³‖ = √((7-3√5)/2) < 1`).
  The position `6 = 2·L₂` is a Lucas-type jump position (see `FifthRootLucasJumps.lean`).

## Method for the jump

The 6-root arrangement `ζ₅⁰ + 2ζ₅¹ + 2ζ₅³ + ζ₅⁴` reduces, via `1+ζ+ζ²+ζ³+ζ⁴ = 0`, to
`ζ₅ - ζ₅² + ζ₅³ = ζ₅·(1 - ζ₅ + ζ₅²)`, of squared modulus `2 - 3w` where
`w = ζ₅ + ζ₅⁴ = 2cos(2π/5) = (√5-1)/2 ∈ (1/3, 2/3)`.  Hence `0 < 2-3w < 1`, i.e. the
value is nonzero and `< 1 = σ₅ 1`.

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): `σ₅` (with the non-vanishing constraint) is non-increasing
--   along residue classes mod 5, and strictly decreases exactly at `n = 5Fₘ, Lₘ, 2Lₘ`.
-- Experiment (Experimenter): brute enumeration of all compositions `(a₀,…,a₄)`,
--   `∑aᵣ=n`, for `n ≤ 40` (see `ComputationalEvidence.md`) produced the sequence
--   1, φ⁻¹, φ⁻¹, φ⁻², 0.726…, φ⁻², … The strict-decrease positions were
--   {10,15,25,40} = {5F₃,5F₄,5F₅,5F₆} (residue 0) and {6,7,8,11,14,18,22,29,36,…}
--   = {2L₂,L₄,2L₃,L₅,2L₄,L₆,2L₅,L₇,2L₆,…}, confirming the characterization.
-- Analysis (Analyst): monotonicity is the robust, fully-formalizable half (zero-block
--   insertion).  The exact jump *value* uses the quadratic `w²+w=1` for `w=ζ+ζ⁴`,
--   avoiding any explicit √5 in the modulus bound.
-- Critique (Critic): `sInf ∅ = 0`, so every monotonicity statement is guarded by `n ≥ 1`;
--   the pre-existing catalog draft `Novelty/FifthRootSumMonotonicity.lean` *omitted* the
--   non-vanishing constraint (making σ₅ ≡ 0 for n ≥ 5) and had broken imports — corrected
--   here.
-- !-- End Lab Notes -- !--
-/

open scoped BigOperators

namespace FifthRootMin

/-- The standard primitive fifth root of unity `ζ₅ = exp(2πi/5)`. -/
noncomputable def zeta5 : ℂ := Complex.exp (2 * Real.pi * Complex.I / (5 : ℕ))

/-- `ζ₅` is a primitive fifth root of unity. -/
theorem zeta5_primRoot : IsPrimitiveRoot zeta5 5 :=
  Complex.isPrimitiveRoot_exp 5 (by norm_num)

/-- `ζ₅ ^ 5 = 1`. -/
theorem zeta5_pow_five : zeta5 ^ 5 = 1 := zeta5_primRoot.pow_eq_one

/-- The five distinct powers of `ζ₅` sum to zero. -/
theorem zeta5_geom_sum : ∑ i ∈ Finset.range 5, zeta5 ^ i = 0 :=
  zeta5_primRoot.geom_sum_eq_zero (by norm_num)

/-- Since `ζ₅` has order `5`, exponents reduce modulo `5`. -/
theorem zeta5_pow_mod (n : ℕ) : zeta5 ^ n = zeta5 ^ (n % 5) := by
  conv_lhs => rw [← Nat.div_add_mod n 5, pow_add, pow_mul, zeta5_pow_five, one_pow, one_mul]

/-- Every power of `ζ₅` has absolute value `1`. -/
theorem norm_zeta5_pow (k : ℕ) : ‖zeta5 ^ k‖ = 1 := by
  rw [norm_pow]
  have : ‖zeta5‖ = 1 := by
    unfold zeta5
    rw [show (2 * Real.pi * Complex.I / (5 : ℕ)) = ((2 * Real.pi / 5 : ℝ) : ℂ) * Complex.I by
      push_cast; ring]
    rw [Complex.norm_exp_ofReal_mul_I]
  rw [this, one_pow]

/-- The set of absolute values of all *non-vanishing* sums of `n` powers of `ζ₅`. -/
noncomputable def sumAbsSet (n : ℕ) : Set ℝ :=
  { x | ∃ c : ℕ → ℕ, (∑ j ∈ Finset.range n, zeta5 ^ c j) ≠ 0 ∧
                      x = ‖∑ j ∈ Finset.range n, zeta5 ^ c j‖ }

/-- `σ₅ n`: the minimal absolute value of a non-vanishing sum of `n` powers of `ζ₅`. -/
noncomputable def sigma5 (n : ℕ) : ℝ := sInf (sumAbsSet n)

/-- Every element of `sumAbsSet n` is nonnegative. -/
theorem sumAbsSet_nonneg {n : ℕ} {x : ℝ} (hx : x ∈ sumAbsSet n) : 0 ≤ x := by
  obtain ⟨c, _, rfl⟩ := hx; positivity

/-- `sumAbsSet n` is bounded below (by `0`). -/
theorem sigma5_bddBelow (n : ℕ) : BddBelow (sumAbsSet n) :=
  ⟨0, fun _ hx => sumAbsSet_nonneg hx⟩

/-- For `n ≥ 1` the constant-zero exponent choice yields a non-vanishing sum of value `n`,
so `sumAbsSet n` is nonempty. -/
theorem sumAbsSet_nonempty {n : ℕ} (hn : 1 ≤ n) : (sumAbsSet n).Nonempty := by
  refine ⟨n, fun _ => 0, ?_, ?_⟩
  · simp only [pow_zero, Finset.sum_const, Finset.card_range, nsmul_eq_mul, mul_one]
    exact_mod_cast Nat.cast_ne_zero.mpr (by omega : n ≠ 0)
  · simp

/-- `σ₅ n` is nonnegative. -/
theorem sigma5_nonneg (n : ℕ) : 0 ≤ sigma5 n := by
  by_cases h : (sumAbsSet n).Nonempty
  · exact le_csInf h (fun _ hx => sumAbsSet_nonneg hx)
  · rw [Set.not_nonempty_iff_eq_empty] at h
    simp [sigma5, h, Real.sInf_empty]

/-- `σ₅ 1 = 1`: a sum of a single root is a root of unity, of absolute value one. -/
theorem sigma5_one : sigma5 1 = 1 := by
  have hset : sumAbsSet 1 = {1} := by
    ext x
    simp only [sumAbsSet, Finset.range_one, Finset.sum_singleton, Set.mem_setOf_eq,
      Set.mem_singleton_iff]
    constructor
    · rintro ⟨c, _, rfl⟩; exact norm_zeta5_pow (c 0)
    · rintro rfl; exact ⟨fun _ => 0, by simp, (norm_zeta5_pow 0).symm⟩
  rw [sigma5, hset, csInf_singleton]

/-! ## Monotonicity along residue classes -/

/-- Appending a full zero-summing block of five roots preserves the value of a sum, so any
non-vanishing absolute value attainable with `n` roots is attainable with `n+5`. -/
theorem sumAbsSet_subset (n : ℕ) : sumAbsSet n ⊆ sumAbsSet (n + 5) := by
  rintro x ⟨c, hne, rfl⟩
  have key : ∑ j ∈ Finset.range (n + 5), zeta5 ^ (if j < n then c j else j - n)
      = ∑ j ∈ Finset.range n, zeta5 ^ c j := by
    rw [Finset.sum_range_add]
    have h1 : ∑ i ∈ Finset.range n, zeta5 ^ (if i < n then c i else i - n)
            = ∑ i ∈ Finset.range n, zeta5 ^ c i :=
      Finset.sum_congr rfl (fun i hi => by rw [Finset.mem_range] at hi; simp [hi])
    have h2 : ∑ i ∈ Finset.range 5, zeta5 ^ (if n + i < n then c (n + i) else (n + i) - n) = 0 := by
      have hcongr : ∀ i ∈ Finset.range 5,
          zeta5 ^ (if n + i < n then c (n + i) else (n + i) - n) = zeta5 ^ i := by
        intro i _
        have hlt : ¬ (n + i < n) := by omega
        simp [hlt]
      rw [Finset.sum_congr rfl hcongr, zeta5_geom_sum]
    rw [h1, h2, add_zero]
  exact ⟨fun i => if i < n then c i else i - n, by rw [key]; exact hne, by rw [key]⟩

/-- **One-step monotonicity** (for `n ≥ 1`): `σ₅ (n + 5) ≤ σ₅ n`. -/
theorem sigma5_step {n : ℕ} (hn : 1 ≤ n) : sigma5 (n + 5) ≤ sigma5 n :=
  csInf_le_csInf (sigma5_bddBelow (n + 5)) (sumAbsSet_nonempty hn) (sumAbsSet_subset n)

/-- **Residue-wise monotonicity.**  For a residue `r ≥ 1`, the sequence `k ↦ σ₅(5k+r)` is
non-increasing. -/
theorem sigma5_residue_antitone {r : ℕ} (hr : 1 ≤ r) :
    Antitone (fun k => sigma5 (5 * k + r)) := by
  refine antitone_nat_of_succ_le (fun k => ?_)
  have h : 5 * (k + 1) + r = (5 * k + r) + 5 := by ring
  rw [h]
  exact sigma5_step (by omega)

/-- Non-increasing under adding any multiple of `5` (for `n ≥ 1`). -/
theorem sigma5_add_mul_five_le {n : ℕ} (hn : 1 ≤ n) (m : ℕ) : sigma5 (n + 5 * m) ≤ sigma5 n := by
  induction m with
  | zero => simp
  | succ t ih =>
      have h : n + 5 * (t + 1) = (n + 5 * t) + 5 := by ring
      rw [h]
      exact (sigma5_step (by omega)).trans ih

/-! ## A concrete strict decrease (jump) at `n = 6` -/

/-- The explicit exponent multiset `[0,1,1,3,3,4]` realising the minimal 6-root sum. -/
def jumpExp : ℕ → ℕ := fun j => [0, 1, 1, 3, 3, 4].getD j 0

/--
The 6-root arrangement reduces to `ζ₅ - ζ₅² + ζ₅³`.
-/
theorem jump_sum_eq :
    (∑ j ∈ Finset.range 6, zeta5 ^ jumpExp j) = zeta5 - zeta5 ^ 2 + zeta5 ^ 3 := by
  norm_num [ Finset.sum_range_succ, jumpExp ];
  have := zeta5_geom_sum; norm_num [ Finset.sum_range_succ ] at this; linear_combination this;

/--
`w := ζ₅ + ζ₅⁴ = 2cos(2π/5) = (√5-1)/2` lies strictly between `1/3` and `2/3`.
-/
theorem w_between : 1 / 3 < (zeta5 + zeta5 ^ 4).re ∧ (zeta5 + zeta5 ^ 4).re < 2 / 3 := by
  unfold zeta5; norm_num [ ← Complex.exp_nat_mul, Complex.exp_re, mul_div_cancel₀ ] ; ring ; norm_num;
  rw [ show Real.pi * ( 8 / 5 ) = 2 * Real.pi - Real.pi * ( 2 / 5 ) by ring, Real.cos_two_pi_sub ] ; ring_nf ; norm_num [ mul_div ] ;
  rw [ show Real.pi * 2 / 5 = 2 * ( Real.pi / 5 ) by ring, Real.cos_two_mul ] ; norm_num [ mul_div ] ; ring_nf ; norm_num [ Real.cos_pi_div_five ] ;
  constructor <;> nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ]

/--
The squared modulus of the jump arrangement equals `2 - 3w`.
-/
theorem jump_normSq :
    Complex.normSq (zeta5 - zeta5 ^ 2 + zeta5 ^ 3) = 2 - 3 * (zeta5 + zeta5 ^ 4).re := by
  -- Now use the fact that `zeta5^5 = 1` and `1 + zeta5 + zeta5^2 + zeta5^3 + zeta5^4 = 0` to simplify the expression.
  have h_simp : (zeta5 - zeta5^2 + zeta5^3) * (zeta5^4 - zeta5^3 + zeta5^2) = 2 - 3 * (zeta5 + zeta5^4) := by
    ring_nf;
    rw [ show zeta5 ^ 7 = zeta5 ^ 5 * zeta5 ^ 2 by ring, show zeta5 ^ 6 = zeta5 ^ 5 * zeta5 by ring, show zeta5 ^ 5 = 1 by exact zeta5_pow_five ] ; ring;
    have := zeta5_geom_sum; norm_num [ Finset.sum_range_succ ] at this; linear_combination' this;
  convert congr_arg Complex.re h_simp using 1;
  · rw [ Complex.normSq_apply, Complex.mul_re ];
    norm_num [ zeta5, ← Complex.exp_nat_mul, Complex.exp_re, Complex.exp_im, mul_div_cancel₀ ] ; ring;
    rw [ show Real.pi * ( 8 / 5 ) = Real.pi + Real.pi * ( 3 / 5 ) by ring, show Real.pi * ( 6 / 5 ) = Real.pi + Real.pi * ( 1 / 5 ) by ring, show Real.pi * ( 4 / 5 ) = Real.pi - Real.pi * ( 1 / 5 ) by ring, show Real.pi * ( 2 / 5 ) = Real.pi - Real.pi * ( 3 / 5 ) by ring ] ; norm_num [ Real.sin_add, Real.sin_sub, Real.cos_add, Real.cos_sub ] ; ring;
  · norm_num

/-- The jump arrangement is non-vanishing (its squared modulus `2-3w > 0`). -/
theorem jump_ne_zero : zeta5 - zeta5 ^ 2 + zeta5 ^ 3 ≠ 0 := by
  have h := jump_normSq
  have hw := w_between.2
  intro hz
  rw [hz, Complex.normSq_zero] at h
  nlinarith [w_between.1, w_between.2]

/-- The jump arrangement has modulus `< 1`. -/
theorem jump_norm_lt_one : ‖zeta5 - zeta5 ^ 2 + zeta5 ^ 3‖ < 1 := by
  have h := jump_normSq
  have hsq : ‖zeta5 - zeta5 ^ 2 + zeta5 ^ 3‖ ^ 2 < 1 := by
    rw [← Complex.normSq_eq_norm_sq]
    nlinarith [w_between.1, w_between.2, h]
  nlinarith [norm_nonneg (zeta5 - zeta5 ^ 2 + zeta5 ^ 3), hsq]

/-- **Strict decrease at `n = 6`:** `σ₅ 6 < 1`. -/
theorem sigma5_six_lt_one : sigma5 6 < 1 := by
  have hmem : ‖zeta5 - zeta5 ^ 2 + zeta5 ^ 3‖ ∈ sumAbsSet 6 :=
    ⟨jumpExp, by rw [jump_sum_eq]; exact jump_ne_zero, by rw [jump_sum_eq]⟩
  have hle : sigma5 6 ≤ ‖zeta5 - zeta5 ^ 2 + zeta5 ^ 3‖ := csInf_le (sigma5_bddBelow 6) hmem
  exact lt_of_le_of_lt hle jump_norm_lt_one

/-- **The jump `σ₅ 6 < σ₅ 1`.**  Both `1` and `6` lie in the residue class `1 (mod 5)`; the
value strictly decreases at the Lucas-type position `6 = 2·L₂`. -/
theorem sigma5_six_lt_sigma5_one : sigma5 6 < sigma5 1 := by
  rw [sigma5_one]; exact sigma5_six_lt_one

end FifthRootMin