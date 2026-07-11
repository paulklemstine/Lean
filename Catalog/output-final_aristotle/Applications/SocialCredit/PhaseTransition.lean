import Mathlib

/-!
# Phase Transitions in Credit Tiers

A credit system rarely reports a raw score; it reports a **tier** (e.g.
"trusted" vs. "restricted") obtained by thresholding the score.  We model the
simplest such classifier, `tier t`, which flags a score `x` as `true`
(at or above the cutoff) exactly when `t ≤ x`, and study its topological
behaviour as a map into the *discrete* two-point value space `Bool`.

* **Phase transition at the cutoff.**  `tier t` is discontinuous precisely at
  the threshold `t` (`tier_discontinuousAt`), and continuous everywhere else
  (`tier_continuousAt_of_ne`).  Thus there is a single critical score.

* **Sensitivity.**  At the threshold, arbitrarily small perturbations flip the
  tier (`tier_sensitive`): a member sitting exactly on the cutoff is maximally
  unstable.

* **Inevitability of phase transitions.**  These jumps are not an artefact of
  our particular classifier.  *Any* continuous binary classification of the
  (connected) score line is constant (`continuous_binary_classification_constant`).
  Consequently every classifier that actually separates two members must be
  discontinuous somewhere — a phase transition is unavoidable
  (`phase_transition_of_separating`).
-/

open Filter Topology Set

namespace SocialCredit

/-- Tier of a score `x` relative to threshold `t`: `true` (at/above cutoff)
iff `t ≤ x`. -/
noncomputable def tier (t x : ℝ) : Bool := decide (t ≤ x)

@[simp] theorem tier_self (t : ℝ) : tier t t = true := by
  simp [tier]

theorem tier_eq_true_iff (t x : ℝ) : tier t x = true ↔ t ≤ x := by
  simp [tier]

theorem tier_eq_false_iff (t x : ℝ) : tier t x = false ↔ x < t := by
  simp [tier]

/-
**Phase transition.**  The tier classifier jumps at the threshold: it is not
continuous at `t`.
-/
theorem tier_discontinuousAt (t : ℝ) : ¬ ContinuousAt (tier t) t := by
  -- By definition of $tier$, we know that for $x < t$, $tier t x = false$.
  have h_left : ∀ᶠ x in nhdsWithin t (Set.Iio t), tier t x = false := by
    exact Filter.eventually_of_mem self_mem_nhdsWithin fun x hx => by simp +decide [ hx.out, tier_eq_false_iff ] ;
  intro h; have := h_left.self_of_nhdsWithin; simp_all +decide [ ContinuousAt ] ;
  exact absurd ( h_left.and ( h.filter_mono nhdsWithin_le_nhds ) ) fun H => by obtain ⟨ x, hx₁, hx₂ ⟩ := H.exists; aesop;

/-
Away from the threshold the classifier is locally constant, hence continuous:
no phase transition occurs there.
-/
theorem tier_continuousAt_of_ne (t x : ℝ) (h : x ≠ t) :
    ContinuousAt (tier t) x := by
  by_cases h' : x < t;
  · convert Filter.EventuallyEq.continuousAt _;
    exacts [ Bool.false, Filter.eventuallyEq_of_mem ( Iio_mem_nhds h' ) fun y hy => by simp +decide [ tier, hy.out.not_ge ] ];
  · refine' Filter.EventuallyEq.continuousAt _;
    exacts [ Bool.true, Filter.eventuallyEq_of_mem ( Ioi_mem_nhds ( lt_of_le_of_ne ( le_of_not_gt h' ) h.symm ) ) fun y hy => by unfold tier; simp +decide [ hy.out.le ] ]

/-
**Sensitivity at the cutoff.**  For every perturbation radius `δ > 0` there is
a score within `δ` of the threshold whose tier differs from the threshold's.
-/
theorem tier_sensitive (t : ℝ) {δ : ℝ} (hδ : 0 < δ) :
    ∃ x, |x - t| < δ ∧ tier t x ≠ tier t t := by
  exact ⟨ t - δ / 2, abs_lt.mpr ⟨ by linarith, by linarith ⟩, by simp +decide [ tier ] ; linarith ⟩

/-
**Inevitability.**  Any continuous binary classification of the connected
score line is constant.
-/
theorem continuous_binary_classification_constant (c : ℝ → Bool)
    (hc : Continuous c) : ∀ x y, c x = c y := by
  exact fun x y => by have := isPreconnected_range hc; exact this.subsingleton ⟨ x, rfl ⟩ ⟨ y, rfl ⟩ ;

/-
Hence any classifier that distinguishes two members must have a phase
transition: it cannot be continuous.
-/
theorem phase_transition_of_separating (c : ℝ → Bool)
    (h : ∃ x y, c x ≠ c y) : ¬ Continuous c := by
  exact fun hc => h.choose_spec.choose_spec <| continuous_binary_classification_constant c hc _ _

end SocialCredit