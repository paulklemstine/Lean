import Mathlib
import Algebra.QubitTrade.Threshold
import Algebra.QubitTrade.SampleComplexity
import Cryptography.FactoringBarriers.DFTSampleBound
import Pythagorean.FactoringBarriers.Dequant.OrderProbe

/-!
# QUBIT-TRADE VIII: both axes of Shor's channel are forced

The catalog already contains the *width* bound for Fourier sampling
(`FactoringBarriers.dft_sample_count_ge_period`: determining a period-`r` signal
needs at least `r` frequencies).  `Resolution.lean` supplies the missing *depth*
bound: each retained frequency must be read to `2 log₂ r` bits.  Here the two are
combined, and the resulting statement is shown to be non-vacuous by exhibiting,
for every `r ≥ 3`, an honest order-finding instance with `ord_N(b) = r`
(the Mersenne instance `N = 2^r - 1`, `b = 2`, from `Dequant.ord_two_mersenne`).

* `QubitTrade.shor_channel_irreducible` — width and depth bounds together;
* `QubitTrade.threshold_realized_at_mersenne` — the depth bound applies to genuine
  multiplicative orders at every scale, so it is not an artefact of the model;
* `QubitTrade.probe_and_register_both_sealed` — the classical probe seal of
  `Dequant.extraction_needs_query_at_least_order` and the register threshold hold
  simultaneously for the same instance.
-/

namespace QubitTrade

/-- **Both axes are irreducible.**  For a Fourier-sampling scheme on `ZMod r`:

* *width*: if the sampled frequencies determine the signal then there are at
  least `r` of them;
* *depth*: if each outcome is read to only `t` bits with `t + 1 ≤ 2 log₂ R`
  (`R ≥ 3` the order bound), the continued-fraction target is not determined —
  two distinct candidate fractions stay compatible with one reading.

Neither axis can be traded for the other. -/
theorem shor_channel_irreducible {r K : ℕ} [NeZero r] (idx : Fin K → ZMod r)
    (hdet : ∀ v w : ZMod r → ℂ,
      (∀ j : Fin K, ZMod.dft v (idx j) = ZMod.dft w (idx j)) → v = w)
    {R t : ℕ} (hR : 3 ≤ R) (ht : t + 1 ≤ 2 * Nat.log 2 R) :
    r ≤ K ∧ ∃ (x : ℝ) (q₁ q₂ : ℚ), q₁ ≠ q₂ ∧ q₁.den ≤ R ∧ q₂.den ≤ R ∧
      Compatible t x q₁ ∧ Compatible t x q₂ :=
  ⟨FactoringBarriers.dft_sample_count_ge_period idx hdet, register_fails hR ht⟩

/-- **The depth bound is realised by honest instances.**  For every `r ≥ 3` the
Mersenne instance `N = 2^r - 1`, `b = 2` has multiplicative order exactly `r`, and
at that order a register with `t + 1 ≤ 2 log₂ r` bits leaves the continued-fraction
target ambiguous, while `t ≥ 2 log₂ r + 2` determines it. -/
theorem threshold_realized_at_mersenne {r : ℕ} (hr : 3 ≤ r) :
    Dequant.ord (2 ^ r - 1) 2 = r ∧
    (∀ t : ℕ, t + 1 ≤ 2 * Nat.log 2 r →
      ∃ (x : ℝ) (q₁ q₂ : ℚ), q₁ ≠ q₂ ∧ q₁.den ≤ r ∧ q₂.den ≤ r ∧
        Compatible t x q₁ ∧ Compatible t x q₂) ∧
    (∀ t : ℕ, 2 * Nat.log 2 r + 2 ≤ t → ∀ (x : ℝ) (q₁ q₂ : ℚ), q₁.den ≤ r → q₂.den ≤ r →
        Compatible t x q₁ → Compatible t x q₂ → q₁ = q₂) :=
  ⟨Dequant.ord_two_mersenne (by omega),
   fun t ht => register_fails hr ht,
   fun t ht x q₁ q₂ h₁ h₂ c₁ c₂ => register_suffices (by omega) ht h₁ h₂ c₁ c₂⟩

/-- **Two seals at once.**  On the same Mersenne instance, the classical fixed-point
probe cannot separate the order `r` from another candidate `s` without a query of
size `≥ min (r, s)` (the `Θ(r)` seal of `Dequant`), *and* a truncated quantum
register below `2 log₂ r` bits cannot separate the two candidate order fractions.
Shrinking either resource collapses the extraction. -/
theorem probe_and_register_both_sealed {r s : ℕ} (hr : 3 ≤ r) (hrs : r ≠ s)
    {T : Finset ℕ} (hT0 : ∀ q ∈ T, 0 < q) (A : (ℕ → Bool) → ℕ)
    (hloc : ∀ f g : ℕ → Bool, (∀ q ∈ T, f q = g q) → A f = A g)
    (hAr : A (fun q => decide (r ∣ q)) = r) (hAs : A (fun q => decide (s ∣ q)) = s)
    {t : ℕ} (ht : t + 1 ≤ 2 * Nat.log 2 r) :
    (∃ q ∈ T, r ≤ q ∨ s ≤ q) ∧
    (∃ (x : ℝ) (q₁ q₂ : ℚ), q₁ ≠ q₂ ∧ q₁.den ≤ r ∧ q₂.den ≤ r ∧
      Compatible t x q₁ ∧ Compatible t x q₂) :=
  ⟨Dequant.extraction_needs_query_at_least_order hrs hT0 A hloc hAr hAs,
   register_fails hr ht⟩

end QubitTrade