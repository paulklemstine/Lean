import Algebra.ReciprocalZeroHarmonics.Core

/-!
# Reciprocal-Zero Harmonics VI: the window dichotomy

Direction 4 of the programme couples a certified zero-exclusion window to the finite-window
harmonic definition: *every cutoff below the first zero must have harmonic value zero*.  Proving
that `ζ` has no zero with `|Im ρ| ≤ 14` is an analytic problem outside the scope of this file;
what is proved here is the exact logical coupling, in a sharp *iff* form, so that any certified
exclusion window immediately determines the harmonic value — and, conversely, a nonzero harmonic
value certifies the presence of a zero in the window.

## Main results

* `windowSum_pairedOrdinates` — the cutoff commutes with the conjugate pairing: the window
  `|Im ρ| ≤ T` of a paired critical-line family is the paired family of the ordinates with
  `|t| ≤ T`.
* `windowSum_pairedOrdinates_eq_zero_iff` — **the window dichotomy.**  For a conjugate-paired
  family of critical-line zeros, `H(T) = 0` **iff** no ordinate satisfies `|t| ≤ T`.  Thus an
  exclusion window `|Im ρ| ≤ T₀` forces `H(T) = 0` for every `T < T₀`, and any nonzero value of
  `H` is a certificate that the window contains a zero.
* `windowSum_pairedOrdinates_pos_of_mem` — the quantitative form: a single ordinate inside the
  window already forces `Re H(T) ≥ 1/(1/4 + T²) > 0`, an explicit lower bound depending only on
  the cutoff.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** The vanishing of the finite-window harmonic sum should be
  equivalent to the emptiness of the window, not merely implied by it.
* **Experiment (Experimenter).** The nontrivial direction uses positivity: every conjugate pair
  contributes `1/(1/4 + t²) > 0`, so no cancellation is possible and the sum vanishes only for an
  empty window.  The cutoff/pairing commutation is a `Multiset.filter_map` computation together
  with `|-t| = |t|`.
* **Analysis (Analyst).** This upgrades the "small-cutoff counterexample" of the previous cycle
  from an observation to a theorem: on the critical line the harmonic statistic is *monotone* in
  the window and vanishes exactly below the first ordinate, with the explicit lower bound
  `1/(1/4 + T²)` once a zero enters.
* **Critique (Critic).** The theorem is stated for critical-line zeros; for hypothetical
  off-line zeros conjugate pairs contribute `2σ/|ρ|²`, still positive for `σ > 0`, but the
  present statement does not claim that case.
-/

namespace ReciprocalZeroHarmonics

open Classical

/-- The cutoff commutes with conjugate pairing. -/
theorem windowSum_pairedOrdinates (S : Multiset ℝ) (T : ℝ) :
    windowSum (pairedOrdinates S) T
      = harmonicSum (pairedOrdinates (S.filter fun t => |t| ≤ T)) := by
  unfold windowSum pairedOrdinates
  congr 1
  rw [Multiset.filter_add, Multiset.filter_map, Multiset.filter_map]
  congr 1
  congr 1
  exact Multiset.filter_congr fun t _ => by simp [Function.comp, abs_neg]

/-- **Quantitative detection.**  One ordinate inside the window forces the harmonic statistic to
exceed the explicit bound `1/(1/4 + T²)`. -/
theorem windowSum_pairedOrdinates_pos_of_mem (S : Multiset ℝ) (T : ℝ) (t : ℝ) (ht : t ∈ S)
    (htT : |t| ≤ T) : 1 / (1 / 4 + T ^ 2) ≤ (windowSum (pairedOrdinates S) T).re := by
  rw [windowSum_pairedOrdinates, harmonicSum_pairedOrdinates, Complex.ofReal_re]
  set F : Multiset ℝ := (S.filter fun t => |t| ≤ T).map fun t => 1 / (1 / 4 + t ^ 2) with hF
  have hmem : (1 : ℝ) / (1 / 4 + t ^ 2) ∈ F :=
    Multiset.mem_map_of_mem _ (Multiset.mem_filter.mpr ⟨ht, htT⟩)
  have hnn : ∀ x ∈ F, 0 ≤ x := by
    intro x hx
    obtain ⟨u, _, rfl⟩ := Multiset.mem_map.mp hx
    positivity
  have h1 : 1 / (1 / 4 + T ^ 2) ≤ 1 / (1 / 4 + t ^ 2) := by
    have habs : t ^ 2 ≤ T ^ 2 := by
      have h0 : |t| ≤ |T| := le_trans htT (le_abs_self T)
      nlinarith [abs_nonneg t, abs_nonneg T, sq_abs t, sq_abs T]
    exact one_div_le_one_div_of_le (by positivity) (by linarith)
  exact le_trans h1 (Multiset.single_le_sum hnn _ hmem)

/-- **The window dichotomy.**  For conjugate-paired critical-line zeros the finite-window
harmonic sum vanishes exactly when the window is empty of zeros.  A certified exclusion window
therefore determines the harmonic value on the whole interval below it, and conversely a nonzero
harmonic value certifies a zero inside the window. -/
theorem windowSum_pairedOrdinates_eq_zero_iff (S : Multiset ℝ) (T : ℝ) :
    windowSum (pairedOrdinates S) T = 0 ↔ ∀ t ∈ S, T < |t| := by
  constructor
  · intro h t ht
    by_contra hle
    push_neg at hle
    have hpos := windowSum_pairedOrdinates_pos_of_mem S T t ht hle
    rw [h] at hpos
    simp only [Complex.zero_re] at hpos
    have : (0 : ℝ) < 1 / (1 / 4 + T ^ 2) := by positivity
    linarith
  · intro h
    rw [windowSum_pairedOrdinates]
    have hempty : (S.filter fun t => |t| ≤ T) = 0 := by
      rw [Multiset.filter_eq_nil]
      intro t ht
      exact not_le.mpr (h t ht)
    rw [hempty]
    simp [pairedOrdinates]

end ReciprocalZeroHarmonics