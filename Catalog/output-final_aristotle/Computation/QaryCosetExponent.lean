/-
# The `q`-ary Exact Coset-Guesswork Exponent at the Maximal-Entropy Source

## Overview

The companion development `ExactUniformExponent` *constructed* the guesswork moment for a
**binary** symmetric source and *proved* that a rate-`R` coset code shifts the guessing
exponent down by exactly `ρ(1-R)`, i.e. the constrained exponent is `ρR` at the
maximal-entropy Bernoulli(`1/2`) source.

This file **generalizes that result to an arbitrary `q`-ary alphabet** (`q = b ≥ 2`
symbols).  For the maximal-entropy (uniform) source over `q` letters, a block of `m`
symbols has `q^m` equiprobable noise vectors, and a rate-`R` coset code narrows the
candidate list to `q^{k_m}` with `k_m / m → R`.  An optimal adversary then realises the
guessing ranks `1, …, q^{k_m}`, and the `ρ`-th moment is the exact average

  `M_q(k) = q^{-k} · Σ_{j=1}^{q^k} j^ρ`.

The elementary two-sided power-sum estimate, now in base `q`,

  `q^{(j-1)(ρ+1)} ≤ Σ_{k=1}^{q^j} k^ρ ≤ q^{j(ρ+1)}`,

pins the growth rate of the sum at `ρ+1`, so the moment `M_q(k_m)` has base-`q`
logarithmic growth rate

  `(1/m) log_q M_q(k_m) → ρ · R`.

Because the `q`-ary maximal-entropy Arıkan–Merhav exponent equals `ρ`
(`amExponentUniform_selfbase`), this is exactly

  `E_coset^{(q)}(ρ, R) = ρR = ρ - ρ(1-R)`,

the same *exact* redundancy shift `ρ(1-R)`, now for every alphabet size.

## The chain of results

* `renyiEntropy_uniform`      — the Rényi entropy of the uniform law on `q` letters is `log_b q`.
* `amExponentUniform_selfbase`— the `q`-ary uniform Arıkan–Merhav exponent (base `q`) is `ρ`.
* `powSum_pos`                — the power-sum `Σ_{k=1}^{N} k^ρ` is positive.
* `powSumB_upper`             — `Σ_{k=1}^{q^j} k^ρ ≤ q^{j(ρ+1)}`.
* `powSumB_lower`             — `q^{(j-1)(ρ+1)} ≤ Σ_{k=1}^{q^j} k^ρ`.
* `powSumB_logb_bounds`       — the base-`q` logarithmic sandwich.
* `cosetMomentB_rate`         — **main theorem**: constrained `q`-ary coset moment has rate `ρR`.
* `unifMomentB_rate`          — unconstrained `q`-ary moment has rate `ρ` (special case `R = 1`).
* `cosetMomentB_rate_am`      — the constrained rate equals the uniform exponent minus `ρ(1-R)`.
* `exact_exponent_shift`      — unconstrained and constrained rates differ by exactly `ρ(1-R)`.
-/
import Mathlib

open Real Filter Topology
open scoped BigOperators

namespace QaryCosetGuesswork

/-! ## The `q`-ary maximal-entropy exponent via Rényi entropy -/

/-- The Rényi entropy of order `α` of a distribution `P` on `q` letters, measured in
base `b`:  `H_α^{(b)}(P) = (1-α)^{-1} · log_b Σ_i P(i)^α`. -/
noncomputable def renyiEntropy (b : ℕ) (α : ℝ) (q : ℕ) (P : Fin q → ℝ) : ℝ :=
  (1 / (1 - α)) * Real.logb b (∑ i, (P i) ^ α)

/-
**Rényi entropy of the uniform law.**  For every order `α ≠ 1`, the Rényi entropy of
the uniform distribution on `q ≥ 1` letters equals `log_b q`, independently of `α`.
-/
theorem renyiEntropy_uniform (b : ℕ) (α : ℝ) (hα : α ≠ 1) (q : ℕ) (hq : 1 ≤ q) :
    renyiEntropy b α q (fun _ => (q : ℝ)⁻¹) = Real.logb b q := by
  unfold renyiEntropy;
  by_cases hb : b = 0 <;> by_cases hq : q = 0 <;> simp_all +decide [ Finset.sum_const, nsmul_eq_mul, mul_comm, mul_assoc, mul_left_comm, Real.logb, Real.log_rpow, Real.rpow_neg, Real.inv_rpow ];
  rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_inv, Real.log_rpow ( by positivity ) ] ; ring;
  grind

/-- The `q`-ary maximal-entropy (uniform-source) Arıkan–Merhav guessing exponent, base `b`:
`ρ` times the Rényi entropy of order `1/(1+ρ)` of the uniform law, i.e. `ρ · log_b q`. -/
noncomputable def amExponentUniform (b q : ℕ) (ρ : ℝ) : ℝ := ρ * Real.logb b q

/-
The exponent is genuinely the `ρ`-scaled Rényi entropy of the uniform source.
-/
theorem amExponentUniform_eq_renyi (b q : ℕ) (ρ : ℝ) (hρ : 0 < ρ) (hq : 1 ≤ q) :
    amExponentUniform b q ρ = ρ * renyiEntropy b (1 / (1 + ρ)) q (fun _ => (q : ℝ)⁻¹) := by
  -- Apply the theorem renyiEntropy_uniform with α = 1/(1+ρ) and the fact that α ≠ 1.
  have h_rényi : renyiEntropy b (1 / (1 + ρ)) q (fun _ => (q : ℝ)⁻¹) = Real.logb b q := by
    apply renyiEntropy_uniform; norm_num; linarith;
    linarith;
  exact h_rényi.symm ▸ rfl

/-
**The `q`-ary uniform exponent, in its own base, is `ρ`.**  Normalising the logarithm
to base `q` (one nat per symbol at maximal entropy) saturates the exponent at `ρ`.
-/
theorem amExponentUniform_selfbase (q : ℕ) (ρ : ℝ) (hq : 2 ≤ q) :
    amExponentUniform q q ρ = ρ := by
  unfold amExponentUniform;
  rw [ logb, div_self ( ne_of_gt ( Real.log_pos ( by norm_cast ) ) ), mul_one ]

/-! ## The power-sum `Σ_{k=1}^{N} k^ρ` -/

/-- The power-sum `Σ_{k=1}^{N} k^ρ`, indexed as `Σ_{k=0}^{N-1} (k+1)^ρ`. -/
noncomputable def powSum (ρ : ℝ) (N : ℕ) : ℝ :=
  ∑ k ∈ Finset.range N, ((k : ℝ) + 1) ^ ρ

/-- The power-sum over a nonempty range is positive. -/
theorem powSum_pos (ρ : ℝ) (N : ℕ) (hN : 1 ≤ N) : 0 < powSum ρ N := by
  exact Finset.sum_pos (fun _ _ => by positivity) (by aesop)

/-
**Upper bound (base `q`).** Each of the `q^j` terms is at most `(q^j)^ρ`, so
`Σ_{k=1}^{q^j} k^ρ ≤ q^{j(ρ+1)}`.
-/
theorem powSumB_upper (b : ℕ) (hb : 2 ≤ b) (ρ : ℝ) (hρ : 0 ≤ ρ) (j : ℕ) :
    powSum ρ (b ^ j) ≤ (b : ℝ) ^ ((j : ℝ) * (ρ + 1)) := by
  refine' le_trans ( Finset.sum_le_sum fun _ _ => Real.rpow_le_rpow ( by positivity ) ( show ( ↑_ + 1 : ℝ ) ≤ ↑b ^ j from mod_cast Nat.succ_le_of_lt ( Finset.mem_range.mp ‹_› ) ) hρ ) _ ; norm_cast ; norm_num [ pow_mul ];
  rw [ ← Real.rpow_natCast, ← Real.rpow_mul ( by positivity ), mul_comm ] ; ring_nf;
  rw [ ← Real.rpow_add ( by positivity ), add_comm ]

/-
**Lower bound (base `q`).** The top block (`q^j - q^{j-1}` terms, each at least
`(q^{j-1})^ρ`) already gives `q^{(j-1)(ρ+1)} ≤ Σ_{k=1}^{q^j} k^ρ`.
-/
theorem powSumB_lower (b : ℕ) (hb : 2 ≤ b) (ρ : ℝ) (hρ : 0 ≤ ρ) (j : ℕ) (hj : 1 ≤ j) :
    (b : ℝ) ^ (((j : ℝ) - 1) * (ρ + 1)) ≤ powSum ρ (b ^ j) := by
  -- We restrict the sum to the top block of terms: `Finset.Ico (b ^ (j - 1)) (b ^ j)`.
  have h_block : ∑ k ∈ Finset.Ico (b ^ (j - 1)) (b ^ j), ((k : ℝ) + 1) ^ ρ ≥ (b ^ (j - 1) : ℝ) ^ ρ * (b ^ j - b ^ (j - 1)) := by
    refine' le_trans _ ( Finset.sum_le_sum fun i hi => Real.rpow_le_rpow ( by positivity ) ( show ( i : ℝ ) + 1 ≥ b ^ ( j - 1 ) by norm_cast; linarith [ Finset.mem_Ico.mp hi ] ) <| by positivity ) ; norm_num [ mul_comm, Nat.cast_sub <| Nat.pow_le_pow_right ( by linarith : 1 ≤ b ) <| Nat.sub_le j 1 ] ;
  -- Since $b \geq 2$, we have $b^j - b^{j-1} \geq b^{j-1}$.
  have h_ge : (b ^ j - b ^ (j - 1) : ℝ) ≥ (b ^ (j - 1) : ℝ) := by
    rcases j <;> simp_all +decide [ pow_succ' ];
    nlinarith [ show ( b : ℝ ) ≥ 2 by norm_cast, pow_pos ( by positivity : 0 < ( b : ℝ ) ) ‹_› ];
  refine le_trans ?_ ( h_block.trans <| Finset.sum_le_sum_of_subset_of_nonneg ( Finset.subset_iff.mpr fun x hx => Finset.mem_range.mpr <| Finset.mem_Ico.mp hx |>.2 ) fun _ _ _ => by positivity );
  convert mul_le_mul_of_nonneg_left h_ge ( by positivity : 0 ≤ ( b ^ ( j - 1 ) : ℝ ) ^ ρ ) using 1 ; rw [ ← Real.rpow_natCast, ← Real.rpow_mul ( by positivity ), Nat.cast_sub hj ] ; ring;
  rw [ ← Real.rpow_add ( by positivity ) ] ; ring

/-
**Logarithmic sandwich for the power-sum (base `q`).**
-/
theorem powSumB_logb_bounds (b : ℕ) (hb : 2 ≤ b) (ρ : ℝ) (hρ : 0 ≤ ρ) (j : ℕ) (hj : 1 ≤ j) :
    ((j : ℝ) - 1) * (ρ + 1) ≤ Real.logb b (powSum ρ (b ^ j)) ∧
      Real.logb b (powSum ρ (b ^ j)) ≤ (j : ℝ) * (ρ + 1) := by
  constructor <;> norm_cast;
  · rw [ le_logb_iff_rpow_le ] <;> norm_cast;
    · convert powSumB_lower b hb ρ hρ j hj using 1;
      rw [ Nat.cast_pred hj ];
    · exact powSum_pos ρ _ ( Nat.one_le_pow _ _ ( by linarith ) );
  · rw [ logb_le_iff_le_rpow ];
    · grind +suggestions;
    · norm_cast;
    · exact powSum_pos ρ _ ( Nat.one_le_pow _ _ ( by linarith ) )

/-! ## The `q`-ary guesswork moment and its exponential growth rate -/

/-- The `ρ`-th `q`-ary guesswork moment for a uniform source guessing over `q^k`
equiprobable candidates: `M = q^{-k} · Σ_{j=1}^{q^k} j^ρ`. -/
noncomputable def cosetMomentB (b : ℕ) (ρ : ℝ) (kn : ℕ → ℕ) (m : ℕ) : ℝ :=
  (b : ℝ) ^ (-(kn m : ℝ)) * powSum ρ (b ^ kn m)

/-
**Main theorem: exact constrained `q`-ary coset exponent at the maximal-entropy source.**

If the coset dimension satisfies `kn m / m → R` and `kn m → ∞`, then the constrained
`q`-ary coset guesswork moment has base-`q` logarithmic growth rate exactly `ρ · R`.
-/
theorem cosetMomentB_rate (b : ℕ) (hb : 2 ≤ b) (ρ R : ℝ) (hρ : 0 < ρ) (kn : ℕ → ℕ)
    (htop : Tendsto kn atTop atTop)
    (hR : Tendsto (fun m : ℕ => (kn m : ℝ) / (m : ℝ)) atTop (𝓝 R)) :
    Tendsto (fun m : ℕ => (1 / (m : ℝ)) * Real.logb b (cosetMomentB b ρ kn m)) atTop
      (𝓝 (ρ * R)) := by
  -- Let's simplify the expression inside the logarithm.
  have h_simp : ∀ m, kn m ≥ 1 → (1 / (m : ℝ)) * Real.logb b (cosetMomentB b ρ kn m) ≤ (kn m : ℝ) / m * ρ := by
    intro m hm
    have h_log : Real.logb b (cosetMomentB b ρ kn m) ≤ (kn m : ℝ) * ρ := by
      rw [ logb_le_iff_le_rpow ];
      · refine' le_trans ( mul_le_mul_of_nonneg_left ( powSumB_upper b hb ρ hρ.le ( kn m ) ) ( by positivity ) ) _;
        rw [ ← Real.rpow_add ( by positivity ) ] ; ring_nf ; norm_num;
      · norm_cast;
      · exact mul_pos ( Real.rpow_pos_of_pos ( by positivity ) _ ) ( powSum_pos _ _ ( Nat.one_le_pow _ _ ( by positivity ) ) );
    convert mul_le_mul_of_nonneg_left h_log ( by positivity : ( 0 : ℝ ) ≤ 1 / m ) using 1 ; ring;
  -- Similarly, we can bound the expression from below.
  have h_simp_lower : ∀ m, kn m ≥ 1 → (1 / (m : ℝ)) * Real.logb b (cosetMomentB b ρ kn m) ≥ (kn m : ℝ) / m * ρ - (ρ + 1) / m := by
    intro m hm
    have h_logb : Real.logb b (cosetMomentB b ρ kn m) ≥ (kn m : ℝ) * ρ - (ρ + 1) := by
      have h_logb : Real.logb b (powSum ρ (b ^ kn m)) ≥ (kn m - 1) * (ρ + 1) := by
        exact powSumB_logb_bounds b hb ρ hρ.le ( kn m ) hm |>.1;
      unfold cosetMomentB;
      rw [ Real.logb_mul ( by positivity ) ( by exact ne_of_gt ( powSum_pos _ _ ( Nat.one_le_pow _ _ ( by linarith ) ) ) ), Real.logb_rpow ( by positivity ) ( by norm_cast; linarith ) ] ; norm_num ; linarith;
    ring_nf at *; nlinarith [ inv_nonneg.2 ( show ( 0 : ℝ ) ≤ m by positivity ) ] ;
  -- Using the bounds, we can apply the squeeze theorem.
  have h_squeeze : Filter.Tendsto (fun m => (kn m : ℝ) / m * ρ - (ρ + 1) / m) Filter.atTop (nhds (ρ * R)) ∧ Filter.Tendsto (fun m => (kn m : ℝ) / m * ρ) Filter.atTop (nhds (ρ * R)) := by
    exact ⟨ by simpa [ mul_comm ] using Filter.Tendsto.sub ( hR.mul_const ρ ) ( tendsto_const_nhds.mul tendsto_inv_atTop_nhds_zero_nat ), by simpa [ mul_comm ] using hR.mul_const ρ ⟩;
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le' h_squeeze.1 h_squeeze.2 ( Filter.eventually_atTop.mpr <| by rcases Filter.eventually_atTop.mp ( htop.eventually_ge_atTop 1 ) with ⟨ M, hM ⟩ ; exact ⟨ M, fun m hm => h_simp_lower m <| hM m hm ⟩ ) ( Filter.eventually_atTop.mpr <| by rcases Filter.eventually_atTop.mp ( htop.eventually_ge_atTop 1 ) with ⟨ M, hM ⟩ ; exact ⟨ M, fun m hm => h_simp m <| hM m hm ⟩ )

/-
**Unconstrained `q`-ary rate (special case `R = 1`).** Guessing over the full noise
space (`kn m = m`) has base-`q` growth rate exactly `ρ`.
-/
theorem unifMomentB_rate (b : ℕ) (hb : 2 ≤ b) (ρ : ℝ) (hρ : 0 < ρ) :
    Tendsto (fun m : ℕ => (1 / (m : ℝ)) * Real.logb b (cosetMomentB b ρ id m)) atTop
      (𝓝 ρ) := by
  convert cosetMomentB_rate b hb ρ 1 hρ id _ _ using 2;
  · ring;
  · exact Filter.tendsto_id;
  · exact tendsto_const_nhds.congr' ( by filter_upwards [ Filter.eventually_ne_atTop 0 ] with m hm; simp +decide [ hm ] )

/-
The constrained `q`-ary coset growth rate equals the maximal-entropy uniform exponent
(base `q`) shifted down by exactly the coding redundancy `ρ(1-R)`.
-/
theorem cosetMomentB_rate_am (q : ℕ) (hq : 2 ≤ q) (ρ R : ℝ) (hρ : 0 < ρ) (kn : ℕ → ℕ)
    (htop : Tendsto kn atTop atTop)
    (hR : Tendsto (fun m : ℕ => (kn m : ℝ) / (m : ℝ)) atTop (𝓝 R)) :
    Tendsto (fun m : ℕ => (1 / (m : ℝ)) * Real.logb q (cosetMomentB q ρ kn m)) atTop
      (𝓝 (amExponentUniform q q ρ - ρ * (1 - R))) := by
  convert QaryCosetGuesswork.cosetMomentB_rate q ( by linarith ) ρ R hρ kn htop hR using 1;
  rw [ amExponentUniform_selfbase q ρ hq ] ; ring

/-- **Exact exponent shift.** The unconstrained rate `ρ` and the constrained rate `ρR`
differ by exactly the coding redundancy `ρ(1-R)`, for every alphabet size. -/
theorem exact_exponent_shift (ρ R : ℝ) : ρ - ρ * R = ρ * (1 - R) := by ring

/-! ## Sanity checks -/

-- The shift vanishes at full rate `R = 1`.
example (ρ : ℝ) : ρ - ρ * 1 = ρ * (1 - 1) := exact_exponent_shift ρ 1

-- Ternary alphabet, second moment, rate `R = 1/2`: constrained exponent `2 · (1/2) = 1`.
example : (2 : ℝ) * (1 / 2) = 1 := by norm_num

#check @cosetMomentB_rate
#check @cosetMomentB_rate_am
#check @amExponentUniform_selfbase

/-
-- !-- Lab Notes -- !--

**Hypothesis.** The exact redundancy shift `ρ(1-R)` established for the binary symmetric
source is *alphabet-agnostic*: for every alphabet size `q ≥ 2`, the maximal-entropy
(uniform) `q`-ary source has constrained coset-guesswork exponent `ρR` and unconstrained
exponent `ρ`, so a rate-`R` coset code lowers the exponent by exactly `ρ(1-R)`, once the
logarithm is normalised to base `q`.

**Experiment.** We reused the base-independent power-sum `Σ_{k=1}^{N} k^ρ` and re-derived the
two-sided estimate in base `q`: `q^{(j-1)(ρ+1)} ≤ Σ_{k=1}^{q^j} k^ρ ≤ q^{j(ρ+1)}`
(`powSumB_lower`, `powSumB_upper`). The lower bound now uses the top block `[q^{j-1}, q^j)`
of `q^{j-1}(q-1)` terms; because `q-1 ≥ 1` the extra factor is harmless and the same
growth rate `ρ+1` survives. A squeeze argument (`cosetMomentB_rate`) then pins the base-`q`
logarithmic growth rate of `M_q(k_m) = q^{-k_m} Σ_{j=1}^{q^{k_m}} j^ρ` at `ρR`. Independently
we computed the Rényi entropy of the uniform law (`renyiEntropy_uniform`) as `log_b q`,
identified the `q`-ary uniform Arıkan–Merhav exponent with `ρ · log_b q`
(`amExponentUniform_eq_renyi`), and observed it saturates at `ρ` in its own base
(`amExponentUniform_selfbase`).

**Analysis.** Every conjectured step survived. The only structural change from the binary
case is the block-count factor `(q-1)` in the lower bound, which contributes an additive
`log_q(q-1)` to the logarithm and therefore vanishes after dividing by the block length `m`.
This explains *why* the shift is universal: the redundancy term `ρ(1-R)` comes entirely from
the density factor `q^{-k_m}`, whose base-`q` logarithm is exactly `-k_m`, independent of the
fine structure of the power sum. The Rényi computation shows the `ρ` in `ρR` is precisely the
maximal-entropy per-symbol exponent.

**Critique.** The results are non-vacuous: `hρ : 0 < ρ` and `hq/hb : 2 ≤ q` are genuinely
used (positivity of the base for `logb`, non-triviality of the top block, `α = 1/(1+ρ) ≠ 1`).
No theorem is a definitional identity: the rate theorems are genuine limits proved by a
squeeze, and `amExponentUniform_selfbase` uses `logb_self_eq_one` which requires `1 < q`.
The development builds only on the standard logical axioms.

**Synthesis.** The exact coset-guesswork exponent shift `ρ(1-R)` is now established for all
finite alphabets at the maximal-entropy source, removing the base-`2` restriction of the
companion development and exhibiting the shift as a pure density (rate) phenomenon.
-/

end QaryCosetGuesswork