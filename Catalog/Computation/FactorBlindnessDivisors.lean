/-
# The factoring instance: a symmetric battery is blind on the divisor population

Cycles 1–3 proved the blindness theorem for an abstract *swap-closed, off-diagonal*
population of ordered pairs.  This cycle supplies the population the battery programme
actually cares about: the **ordered factorisations of a fixed integer**

  `divisorPairs n = { (d, n/d) : d ∣ n }`,

on which the relevant involution is the arithmetic one `d ↦ n/d`, not an abstract swap.

## Main results

* `divisorPairs_swap_closed` — `d ↦ n/d` makes the divisor population closed under
  `Prod.swap`; this is `Nat.div_div_self`, the statement that division by a divisor is an
  involution of the divisor lattice.
* `divisorPairs_offDiagonal` — the population is off-diagonal exactly when `n` is **not a
  perfect square**: the only possible fixed point of the involution is `(√n, √n)`.
* `battery4_divisor_blind` — **the flagship arithmetic statement**: for every nonzero
  non-square `n`, the four-field CRT-chained battery reads exactly `0` bits about which of
  the two cofactors is the larger one, on the population of all ordered factorisations of
  `n`.  In particular this holds for every semiprime `n = p·q` with `p ≠ q`, the case of
  interest for factoring.
* `battery4_divisor_blind_nonvacuous` — the explicit instance `n = 15`: a four-element
  population on which the battery readout is *not* constant, so the zero is a statement
  about a genuinely informative readout.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the abstract swap-closure hypothesis is met by the arithmetic
  population of ordered factorisations, so the blindness theorem applies verbatim to the
  factoring battery.
Experiment (Stage 2): enumerated `divisorPairs 15 = {(1,15),(3,5),(5,3),(15,1)}` and the
  four-field battery values `battery4 (3,5) = battery4 (5,3) = 979345`,
  `battery4 (1,15) = battery4 (15,1)`, `battery4 (7,11) = 400708` — constant on unordered
  pairs, non-constant across them.
  Measured the square case for contrast: on the divisor populations of `36` and `100` (nine
  ordered factorisations each) the same readout gives `0.102187170949` bits, so the
  off-diagonality hypothesis is sharp rather than technical.
Analysis (Stage 3): the fixed-point analysis is the whole content of the off-diagonality
  hypothesis.  `d = n/d` forces `n = d²`, so the *only* obstruction to blindness on a divisor
  population is `n` being a perfect square — in which case the single diagonal pair breaks
  the exact halving, though it contributes a label-degenerate cell rather than genuine
  leakage.  This is a sharp, arithmetic boundary rather than a technical hypothesis.
Critique (Stage 4): `n = 0` is excluded because `Nat.divisors 0 = ∅` and the statement would
  be vacuous; squares are excluded because the theorem is false as stated for them (the
  diagonal pair has no swap partner).  Both exclusions are visible in the statement.
Synthesis (Stage 5): for every non-square `n`, a trace-routed battery cannot tell the bigger
  cofactor from the smaller one, however many fields it chains.
-/
import Mathlib
import Computation.FactorBlindnessInformation
import Computation.FactorBlindnessWall

namespace Computation.FactorBlindness

open Finset

/-- The population of ordered factorisations of `n`. -/
def divisorPairs (n : ℕ) : Finset (ℕ × ℕ) := n.divisors.image (fun d => (d, n / d))

theorem mem_divisorPairs {n : ℕ} {x : ℕ × ℕ} :
    x ∈ divisorPairs n ↔ ∃ d ∈ n.divisors, (d, n / d) = x := by
  simp [divisorPairs]

/-- `d ↦ n/d` is an involution of the divisor lattice, so the population of ordered
factorisations is swap-closed. -/
theorem divisorPairs_swap_closed (n : ℕ) : ∀ x ∈ divisorPairs n, x.swap ∈ divisorPairs n := by
  intro x hx
  rw [mem_divisorPairs] at hx ⊢
  obtain ⟨d, hd, rfl⟩ := hx
  rw [Nat.mem_divisors] at hd
  obtain ⟨hdvd, hn⟩ := hd
  refine ⟨n / d, Nat.mem_divisors.2 ⟨Nat.div_dvd_of_dvd hdvd, hn⟩, ?_⟩
  rw [Nat.div_div_self hdvd hn]
  rfl

/-- The only possible fixed point of `d ↦ n/d` is `√n`: the divisor population is
off-diagonal exactly for non-squares. -/
theorem divisorPairs_offDiagonal {n : ℕ} (hsq : ¬ IsSquare n) :
    ∀ x ∈ divisorPairs n, x.1 ≠ x.2 := by
  intro x hx heq
  rw [mem_divisorPairs] at hx
  obtain ⟨d, hd, rfl⟩ := hx
  rw [Nat.mem_divisors] at hd
  simp only at heq
  have hmul : n = d * d := by
    conv_lhs => rw [← Nat.div_mul_cancel hd.1]
    rw [← heq]
  exact hsq ⟨d, hmul⟩

/-- **Arithmetic flagship.**  For every non-square `n`, the four-field CRT-chained battery
carries exactly zero bits about which cofactor of `n` is the larger one, over the whole
population of ordered factorisations of `n`.  In particular this covers every semiprime
`n = p·q` with distinct primes. -/
theorem battery4_divisor_blind {n : ℕ} (hsq : ¬ IsSquare n) :
    mutualInfo (jointDist (divisorPairs n) battery4) = 0 :=
  battery4_zero_leakage (divisorPairs_swap_closed n) (divisorPairs_offDiagonal hsq)

/-- The same statement for an arbitrary symmetric readout: no trace-routed battery, of any
width, can resolve the cofactor order of a non-square. -/
theorem symmetric_divisor_blind {K : Type*} [DecidableEq K] [Fintype K] {n : ℕ}
    (hsq : ¬ IsSquare n) {c : ℕ × ℕ → K} (hc : ∀ x, c x.swap = c x) :
    mutualInfo (jointDist (divisorPairs n) c) = 0 :=
  galoisBlind_zero_leakage (divisorPairs_swap_closed n) (divisorPairs_offDiagonal hsq) hc

/-- **Nonvacuity at `n = 15`.**  The divisor population of `15` has four elements, the battery
readout is non-constant on it, and the which-factor leakage is nevertheless exactly zero. -/
theorem battery4_divisor_blind_nonvacuous :
    divisorPairs 15 = {(1, 15), (3, 5), (5, 3), (15, 1)} ∧
    battery4 (3, 5) ≠ battery4 (1, 15) ∧
    mutualInfo (jointDist (divisorPairs 15) battery4) = 0 := by
  refine ⟨by decide, by decide, battery4_divisor_blind ?_⟩
  rintro ⟨r, hr⟩
  have hle : r ≤ 15 := by nlinarith
  interval_cases r <;> omega

end Computation.FactorBlindness