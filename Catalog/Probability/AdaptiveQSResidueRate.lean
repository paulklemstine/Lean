/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The exact per-period rate of a factor-base prime, and the QR dial it induces

Third cycle on experiment 559.  `Probability.AdaptiveQSSkipFlip` shows that a prime for
which `N` is a quadratic **non**-residue divides no sieve value at all
(`nonresidue_not_dvd_qsValue`).  That is only the null half of the mechanism.  This file
proves the *live* half exactly, and thereby computes the dial the experiment used.

For an odd prime `p` with `N ≢ 0`, the congruence `x² ≡ N (mod p)` has

* exactly `2` solutions per period when `N` is a quadratic residue
  (`card_sq_eq_two_of_isSquare`), and
* exactly `0` otherwise (`card_sq_eq_zero_of_not_isSquare`).

So the per-period hit rate of a factor-base prime is exactly `2/p` or `0`
(`periodRate_eq_two_div`, `periodRate_eq_zero`) — the `QR(≤100)` dial is not a heuristic
proxy for the rate, it *is* the rate, up to the deterministic factor `2/p`.  Three
consequences are then formalised.

* `periodRate_antitone_on_admissible` — among admissible primes the rate is decreasing in
  `p`: small admissible primes carry the yield.  This is the structural reason the
  rate-concentrator gains and inverse-rate spreading loses.
* `factorBase_skip_throughput_ge` — the end-to-end deployment statement: skipping a
  factor base by the rate dial never lowers the throughput, and
  `factorBase_skip_throughput_gt` gives the strict gain as soon as one genuinely worse
  prime is deferred.
* `nullPrime_transfer_gain` — moving budget off an inadmissible prime onto an admissible
  one strictly increases the yield, which is the "defer, don't sieve deeper" instrument in
  its exact arithmetic form.
-/
import Mathlib
import Probability.AdaptiveQSAllocation
import Probability.AdaptiveQSSkipFlip

namespace Probability.AdaptiveQS

open Finset

/-! ## Exact solution counts -/

/-- **Two solutions per period.**  For an odd prime `p` and a nonzero quadratic residue
`N`, the congruence `x² ≡ N` has exactly two solutions mod `p`. -/
theorem card_sq_eq_two_of_isSquare {p : ℕ} [Fact p.Prime] (hp : p ≠ 2) {N : ZMod p}
    (hN : N ≠ 0) (h : IsSquare N) :
    (Finset.univ.filter (fun x : ZMod p => x ^ 2 = N)).card = 2 := by
  obtain ⟨b, hb⟩ := h
  have hb0 : b ≠ 0 := by
    intro h0
    exact hN (by rw [hb, h0, mul_zero])
  have h2 : (2 : ZMod p) ≠ 0 := by
    intro h2
    have hcast : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast h2
    rw [ZMod.natCast_eq_zero_iff] at hcast
    exact hp ((Nat.prime_dvd_prime_iff_eq Fact.out Nat.prime_two).mp hcast)
  have hne : b ≠ -b := by
    intro hbb
    apply hb0
    have h2b : (2 : ZMod p) * b = 0 := by linear_combination hbb
    rcases mul_eq_zero.mp h2b with h' | h'
    · exact absurd h' h2
    · exact h'
  have hset : (Finset.univ.filter (fun x : ZMod p => x ^ 2 = N)) = {b, -b} := by
    ext x
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_insert,
      Finset.mem_singleton]
    constructor
    · intro hx
      have hfac : (x - b) * (x + b) = 0 := by rw [hb] at hx; linear_combination hx
      rcases mul_eq_zero.mp hfac with h' | h'
      · exact Or.inl (sub_eq_zero.mp h')
      · exact Or.inr (eq_neg_of_add_eq_zero_left h')
    · rintro (rfl | rfl) <;> rw [hb] <;> ring
  rw [hset, Finset.card_pair hne]

/-- **No solutions.**  If `N` is a quadratic non-residue mod `p` the congruence has no
solution: the exact null half of the mechanism. -/
theorem card_sq_eq_zero_of_not_isSquare {p : ℕ} [Fact p.Prime] {N : ZMod p}
    (h : ¬ IsSquare N) :
    (Finset.univ.filter (fun x : ZMod p => x ^ 2 = N)).card = 0 := by
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro x _ hx
  exact h ⟨x, by rw [← hx]; ring⟩

/-! ## The rate dial -/

/-- The solutions in one period `{0, …, p-1}` are in bijection with the roots of
`x² = N` in `ZMod p`. -/
theorem card_window_eq_card_zmod (p : ℕ) [Fact p.Prime] (N : ℤ) :
    ((Finset.range p).filter (fun x : ℕ => (p : ℤ) ∣ ((x : ℤ) ^ 2 - N))).card
      = (Finset.univ.filter (fun y : ZMod p => y ^ 2 = (N : ZMod p))).card := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  refine Finset.card_bij (fun (x : ℕ) _ => ((x : ZMod p))) ?_ ?_ ?_
  · intro a ha
    rw [Finset.mem_filter, Finset.mem_range] at ha
    have h0 : (((a : ℤ) ^ 2 - N : ℤ) : ZMod p) = 0 :=
      (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mpr ha.2
    push_cast at h0
    simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    linear_combination h0
  · intro a ha b hb hab
    rw [Finset.mem_filter, Finset.mem_range] at ha hb
    have hval := congrArg ZMod.val hab
    rwa [ZMod.val_cast_of_lt ha.1, ZMod.val_cast_of_lt hb.1] at hval
  · intro y hy
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hy
    refine ⟨y.val, ?_, ?_⟩
    · rw [Finset.mem_filter, Finset.mem_range]
      refine ⟨ZMod.val_lt y, ?_⟩
      rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
      push_cast
      rw [ZMod.natCast_val, ZMod.cast_id]
      linear_combination hy
    · show ((y.val : ℕ) : ZMod p) = y
      exact ZMod.natCast_rightInverse y

/-- The exact per-period hit rate of the factor-base prime `p` for the target `N`:
the number of `x` in one period with `p ∣ x² - N`, divided by the period. -/
noncomputable def periodRate (N : ℤ) (p : ℕ) : ℝ :=
  (((Finset.range p).filter (fun x : ℕ => (p : ℤ) ∣ ((x : ℤ) ^ 2 - N))).card : ℝ) / p

/-- An admissible odd prime has rate exactly `2 / p`. -/
theorem periodRate_eq_two_div {p : ℕ} [Fact p.Prime] (hp : p ≠ 2) {N : ℤ}
    (hN : ((N : ZMod p)) ≠ 0) (h : IsSquare ((N : ZMod p))) :
    periodRate N p = 2 / p := by
  rw [periodRate, card_window_eq_card_zmod p N, card_sq_eq_two_of_isSquare hp hN h]
  norm_num

/-- An inadmissible prime has rate exactly `0`: the null equaliser at the level of rates. -/
theorem periodRate_eq_zero {p : ℕ} [Fact p.Prime] {N : ℤ}
    (h : ¬ IsSquare ((N : ZMod p))) : periodRate N p = 0 := by
  rw [periodRate, card_window_eq_card_zmod p N, card_sq_eq_zero_of_not_isSquare h]
  simp

/-- Rates are never negative. -/
theorem periodRate_nonneg (N : ℤ) (p : ℕ) : 0 ≤ periodRate N p := by
  rw [periodRate]
  positivity

/-- **Small admissible primes carry the yield.**  Among admissible odd primes the exact
rate `2/p` is decreasing in `p`. -/
theorem periodRate_antitone_on_admissible {p q : ℕ} [Fact p.Prime] [Fact q.Prime]
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) {N : ℤ}
    (hpN : (N : ZMod p) ≠ 0) (hqN : (N : ZMod q) ≠ 0)
    (hpsq : IsSquare ((N : ZMod p))) (hqsq : IsSquare ((N : ZMod q)))
    (hpq : p ≤ q) : periodRate N q ≤ periodRate N p := by
  have hppos : (0:ℝ) < p := by
    exact_mod_cast (Fact.out : p.Prime).pos
  have hqpos : (0:ℝ) < q := by
    exact_mod_cast (Fact.out : q.Prime).pos
  rw [periodRate_eq_two_div hp2 hpN hpsq, periodRate_eq_two_div hq2 hqN hqsq]
  rw [div_le_div_iff₀ hqpos hppos]
  have : (p:ℝ) ≤ q := by exact_mod_cast hpq
  linarith

/-- An admissible prime has a strictly positive rate, an inadmissible one exactly zero:
the rate dial separates the factor base exactly. -/
theorem periodRate_pos_of_isSquare {p : ℕ} [Fact p.Prime] (hp : p ≠ 2) {N : ℤ}
    (hN : (N : ZMod p) ≠ 0) (h : IsSquare ((N : ZMod p))) : 0 < periodRate N p := by
  have hppos : (0:ℝ) < p := by exact_mod_cast (Fact.out : p.Prime).pos
  rw [periodRate_eq_two_div hp hN h]
  positivity

/-! ## End-to-end deployment on a factor base -/

/-- **The deployment statement.**  Skipping a factor base at any threshold of the exact
rate dial never lowers the throughput. -/
theorem factorBase_skip_throughput_ge (FB : Finset ℕ) (N : ℤ) (θ : ℝ)
    (hK : (keepSet FB (periodRate N) θ).Nonempty) :
    throughput FB (periodRate N) ≤ throughput (keepSet FB (periodRate N) θ) (periodRate N) :=
  skip_throughput_ge (concordant_self FB (periodRate N)) θ hK

/-- **Strict gain.**  If the threshold defers at least one prime that is genuinely worse
than a retained one — in particular any inadmissible prime, whose rate is `0` — the
throughput strictly increases. -/
theorem factorBase_skip_throughput_gt (FB : Finset ℕ) (N : ℤ) (θ : ℝ)
    {p q : ℕ} (hp : p ∈ keepSet FB (periodRate N) θ) (hq : q ∈ skipSet FB (periodRate N) θ)
    (hlt : periodRate N q < periodRate N p) :
    throughput FB (periodRate N) < throughput (keepSet FB (periodRate N) θ) (periodRate N) :=
  skip_throughput_gt (concordant_self FB (periodRate N)) θ hp hq hlt

/-- **Deferral is the instrument, in arithmetic form.**  Moving any positive amount of
sieve length off an inadmissible prime onto an admissible one strictly increases the
total yield — no schedule can extract anything from the inadmissible prime itself. -/
theorem nullPrime_transfer_gain {FB : Finset ℕ} {ℓ : ℕ → ℝ} {p q : ℕ}
    [Fact p.Prime] [Fact q.Prime] {N : ℤ}
    (hpFB : p ∈ FB) (hqFB : q ∈ FB) (hpq : p ≠ q)
    (hnull : ¬ IsSquare ((N : ZMod p)))
    (hq2 : q ≠ 2) (hqN : (N : ZMod q) ≠ 0) (hqsq : IsSquare ((N : ZMod q)))
    {δ : ℝ} (hδ : 0 < δ) :
    yieldOf FB (periodRate N) ℓ < yieldOf FB (periodRate N) (transfer ℓ p q δ) :=
  transfer_from_null_lt hpFB hqFB hpq (periodRate_eq_zero hnull)
    (periodRate_pos_of_isSquare hq2 hqN hqsq) hδ

end Probability.AdaptiveQS