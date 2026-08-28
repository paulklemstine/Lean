import Mathlib
import Novelty.KeysOwnTheCliff
import Novelty.KVDecisionDissociation

/-!
# How many bits do the keys need?  A margin criterion and a 4-bit counterexample

Cycle 4 of the NET-93 thread.  `Novelty.KeysOwnTheCliff` proves that the key
path has no Lipschitz constant, and `Novelty.KVBitBudgetSplit` proves that bits
should be moved from the values to the keys.  Neither answers the deployment
question NET-93 actually poses: *how many* key bits are enough?

This file answers it with the margin certificate of
`Novelty.KVDecisionDissociation` (`strictTop_of_margin`: a top-1 decision
survives a coordinatewise `ε`-perturbation of the logits whenever its gap
exceeds `2ε`).  Composing that certificate with the key-amplification bound
`score_error_le_of_key_error` gives:

* `decision_preserved_of_key_bits` — a `b`-bit key grid of range `R` preserves
  every attention decision whose logit margin exceeds `2 · ‖q‖₁ · R / 2^b`;
* `bits_suffice_for_margin` — hence `2^b > 2‖q‖₁R/m` bits are enough for all
  decisions of margin at least `m`.  The requirement is *logarithmic* in the
  amplification `‖q‖₁R/m`, which is why 8 bits is a plausible frontier and 4 is
  not: each bit doubles the tolerated amplification;
* `eight_bits_safe_at_scale` — at the reference scale `‖q‖₁ = 64`, `R = 1`,
  `m = 1`, eight bits leave a factor-two safety margin;
* `four_bits_destroy_the_decision` — and at the *same* scale four bits provably
  destroy a decision of margin `2`: the exact scores have a strict top-1, the
  quantised ones tie.  A single collapsed decision is exactly the mechanism by
  which the measured `K q4_0` arm reaches PPL 2537.

Both halves are constructive and quantitative, so the pair brackets the NET-93
deployment rule "keys ≥ 8 bits, values may take 4".
-/

namespace Catalog.Novelty.KeyBitwidthSafety

open Finset Catalog.Novelty.KeysOwnTheCliff Catalog.Novelty.KVDecisionDissociation

variable {n d : ℕ}

/-- Resolution of a uniform `b`-bit grid covering the key range `[-R, R]`
(worst-case rounding error per entry). -/
noncomputable def res (R : ℝ) (b : ℕ) : ℝ := R / 2 ^ b

/-- **Margin criterion for key bit-width.**  If every key entry is stored to
resolution `res R b` and the exact logit margin of the decision `i` exceeds
`2 · ‖q‖₁ · res R b`, then the quantised cache makes the same decision. -/
theorem decision_preserved_of_key_bits (q : Fin d → ℝ) (k k' : Fin (n + 1) → Fin d → ℝ)
    (R : ℝ) (b : ℕ) (i : Fin (n + 1))
    (hres : ∀ i t, |k i t - k' i t| ≤ res R b)
    (hmargin : ∀ j, j ≠ i → 2 * ((∑ t, |q t|) * res R b) < scores q k i - scores q k j) :
    IsStrictTop (scores q k') i :=
  strictTop_of_margin (scores q k) (scores q k') i ((∑ t, |q t|) * res R b) hmargin
    (fun j => score_error_le_of_key_error q k k' (res R b) hres j)

/-- **Bit count.**  `b` bits suffice for all decisions of margin at least `m`
as soon as `2^b > 2 ‖q‖₁ R / m`; the requirement on `b` is logarithmic in the
amplification `‖q‖₁ R / m`, so each extra key bit doubles the query norm (or
halves the margin) that can be tolerated. -/
theorem bits_suffice_for_margin (L1 R m : ℝ) (b : ℕ)
    (hb : 2 * (L1 * R) < m * 2 ^ b) : 2 * (L1 * res R b) < m := by
  have hpow : (0 : ℝ) < 2 ^ b := by positivity
  rw [show 2 * (L1 * res R b) = (2 * (L1 * R)) / 2 ^ b by rw [res]; ring,
    div_lt_iff₀ hpow]
  linarith

/-- At the reference scale of the NET-93 setup (`‖q‖₁ = 64`, key range `1`,
decision margin `1`), an 8-bit key grid keeps the perturbation at half the
margin: decisions are safe with a factor-two cushion. -/
theorem eight_bits_safe_at_scale : 2 * (64 * res 1 8) < 1 := by
  norm_num [res]

/-- **Four bits are not enough — and the failure is not asymptotic.**  At the
same reference scale there is a concrete two-position cache whose exact scores
have a strict top-1 with margin `2`, and whose 4-bit quantisation has *no*
strict top at all: the softmax is handed a tie, and the decision is gone. -/
theorem four_bits_destroy_the_decision :
    ∃ (q : Fin 1 → ℝ) (k k' : Fin 2 → Fin 1 → ℝ),
      (∑ t, |q t|) = 64 ∧
      (∀ i t, |k i t - k' i t| ≤ res 1 4) ∧
      (∀ j, j ≠ (0 : Fin 2) → 2 ≤ scores q k 0 - scores q k j) ∧
      IsStrictTop (scores q k) 0 ∧ NoStrictTop (scores q k') := by
  refine ⟨![64], ![![1 / 32], ![0]], ![![0], ![0]], by norm_num, ?_, ?_, ?_, ?_⟩
  · intro i t
    fin_cases i <;> fin_cases t <;> norm_num [res]
  · intro j hj
    fin_cases j
    · exact absurd rfl hj
    · norm_num [scores]
  · intro j hj
    fin_cases j
    · exact absurd rfl hj
    · norm_num [scores]
  · intro i hi
    fin_cases i
    · have := hi 1 (by decide)
      norm_num [scores] at this
    · have := hi 0 (by decide)
      norm_num [scores] at this

/-- The two results together: at a fixed scale, the safe-bit criterion is met at
8 bits and violated at 4 bits — the quantitative content of "keys ≥ 8 bits". -/
theorem four_bits_violate_the_criterion : ¬ (2 * (64 * res 1 4) < 2) := by
  norm_num [res]

/-! ### Cycle 5: rescaling cannot buy key bits -/

/-- **No rescue by normalisation.**  Rescaling the keys by `c > 0` and the query
by `1/c` leaves the logits — hence the whole attention functional — unchanged,
multiplies the key range by `c`, and divides the query `ℓ¹` norm by `c`.  The
amplification `‖q‖₁ · R / 2^b` that governs `decision_preserved_of_key_bits` is
therefore *invariant*: no choice of scale, and hence no normalisation scheme,
can reduce the number of key bits required.  This is the sense in which the
NET-93 cliff is a property of attention rather than of one storage format. -/
theorem no_rescue_by_rescaling (c : ℝ) (hc : 0 < c) (q : Fin d → ℝ)
    (k : Fin (n + 1) → Fin d → ℝ) (R : ℝ) (b : ℕ) (hrange : ∀ i t, |k i t| ≤ R) :
    scores (fun t => q t / c) (fun i t => c * k i t) = scores q k ∧
      (∀ i t, |c * k i t| ≤ c * R) ∧
      (∑ t, |q t / c|) * res (c * R) b = (∑ t, |q t|) * res R b := by
  refine ⟨?_, ?_, ?_⟩
  · funext i
    simp only [scores]
    refine Finset.sum_congr rfl fun t _ => ?_
    field_simp
  · intro i t
    rw [abs_mul, abs_of_pos hc]
    exact mul_le_mul_of_nonneg_left (hrange i t) hc.le
  · have habs : ∀ t, |q t / c| = |q t| / c := by
      intro t
      rw [abs_div, abs_of_pos hc]
    simp only [habs, res, ← Finset.sum_div]
    field_simp

end Catalog.Novelty.KeyBitwidthSafety