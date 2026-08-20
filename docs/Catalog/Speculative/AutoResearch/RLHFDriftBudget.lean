/-
# Multi-round RLHF: metric axioms and a drift budget

Fourth file of the neurosymbolic RLHF thread.  The catalog already knows that
exponential tilting is a transitive group action of the reward space on the
open simplex, and `MachineLearning/RLHFHilbertIsometry.lean` shows that this
action is by *isometries* of the Hilbert projective metric with scale `1/β`.

Here we complete the metric picture and cash it out for *iterated* alignment
(RLHF round after RLHF round, as in real alignment pipelines):

* **Level 0 — seminorm axioms** for `oscil` (subadditivity, symmetry under
  negation) and the resulting **pseudometric axioms** for `hilbertDist`
  (symmetry and the triangle inequality on positive vectors).
* **Level 1 — one round is a translation**
  (`hilbertDist_gibbs_add_left`): applying an extra reward `s` moves the policy
  by exactly `oscil s / β`, independently of the reward accumulated so far.
* **Level 2 — the drift budget** (`hilbertDist_gibbs_sum_le`,
  `tvDist_gibbs_sum_le`): after `n` alignment rounds with rewards
  `r 0, …, r (n-1)` the total drift from the SFT model obeys
  `d_H(π_n, ref) ≤ (∑_k oscil (r k)) / β`, and hence
  `‖π_n - ref‖_TV ≤ exp((∑_k oscil (r k))/β) - 1`.
  The proof is by induction on the number of rounds, using the isometry to
  convert each round into a translation.
* **Level 3 — sharpness** (`hilbertDist_gibbs_sum_eq_of_aligned`): the budget
  is attained exactly when the successive rewards never cancel, i.e. when the
  oscillation is additive along the round sequence; a concrete two-round
  cancellation example (`drift_cancellation`) shows the inequality is strict in
  general, so no "drift accounting" scheme can do better than this bound
  without looking at the rewards jointly.

No `sorry`, no `native_decide`.
-/
import MachineLearning.RLHFSymbolicConstraintLattice

open Finset Real BigOperators

noncomputable section

namespace NeuroSymbolicRLHF

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-! ## Level 0: seminorm and pseudometric axioms -/

/-- The oscillation seminorm is subadditive. -/
theorem oscil_add_le (f g : ι → ℝ) : oscil (fun i => f i + g i) ≤ oscil f + oscil g := by
  have hs : univ.sup' univ_nonempty (fun i => f i + g i)
      ≤ univ.sup' univ_nonempty f + univ.sup' univ_nonempty g :=
    Finset.sup'_le _ _ fun i _ => add_le_add (le_sup'_univ f i) (le_sup'_univ g i)
  have hi : univ.inf' univ_nonempty f + univ.inf' univ_nonempty g
      ≤ univ.inf' univ_nonempty (fun i => f i + g i) :=
    Finset.le_inf' _ _ fun i _ => add_le_add (inf'_univ_le f i) (inf'_univ_le g i)
  simp only [oscil]
  linarith

/-- The oscillation seminorm is invariant under negation. -/
theorem oscil_neg (f : ι → ℝ) : oscil (fun i => -f i) = oscil f := by
  have hs : univ.sup' univ_nonempty (fun i => -f i) = -univ.inf' univ_nonempty f := by
    refine le_antisymm (Finset.sup'_le _ _ fun i _ => neg_le_neg (inf'_univ_le f i)) ?_
    rw [neg_le]
    refine Finset.le_inf' _ _ fun i _ => ?_
    have := le_sup'_univ (fun i => -f i) i
    simp only at this
    linarith
  have hi : univ.inf' univ_nonempty (fun i => -f i) = -univ.sup' univ_nonempty f := by
    refine le_antisymm ?_ (Finset.le_inf' _ _ fun i _ => neg_le_neg (le_sup'_univ f i))
    rw [le_neg]
    refine Finset.sup'_le _ _ fun i _ => ?_
    have := inf'_univ_le (fun i => -f i) i
    simp only at this
    linarith
  simp only [oscil, hs, hi]
  ring

/-- The Hilbert projective distance is symmetric. -/
theorem hilbertDist_comm (p q : ι → ℝ) :
    hilbertDist p q = hilbertDist q p := by
  have hfun : (fun i => Real.log (q i / p i)) = fun i => -Real.log (p i / q i) := by
    funext i
    rw [← Real.log_inv]
    congr 1
    rw [inv_div]
  simp only [hilbertDist, hfun]
  exact (oscil_neg _).symm

/-- The Hilbert projective distance satisfies the triangle inequality. -/
theorem hilbertDist_triangle {p q t : ι → ℝ} (hp : IsPosProb p) (hq : IsPosProb q)
    (ht : IsPosProb t) : hilbertDist p q ≤ hilbertDist p t + hilbertDist t q := by
  have hfun : (fun i => Real.log (p i / q i))
      = fun i => Real.log (p i / t i) + Real.log (t i / q i) := by
    funext i
    rw [← Real.log_mul (div_pos (hp.pos i) (ht.pos i)).ne' (div_pos (ht.pos i) (hq.pos i)).ne']
    rw [div_mul_div_comm, mul_comm (t i) (q i), mul_div_mul_right _ _ (ht.pos i).ne']
  rw [hilbertDist, hfun]
  exact oscil_add_le _ _

/-! ## Level 1: one alignment round is a metric translation -/

/-- **Each RLHF round is a translation of size `oscil s / β`.**  Adding a new
reward `s` on top of an accumulated reward `r` moves the policy by exactly
`oscil s / β` in the Hilbert metric — independently of `r`. -/
theorem hilbertDist_gibbs_add_left {β : ℝ} (hβ : 0 < β) {ref r s : ι → ℝ}
    (href : IsPosProb ref) :
    hilbertDist (gibbs β ref (fun i => r i + s i)) (gibbs β ref r) = oscil s / β := by
  have h := hilbertDist_gibbs (r₁ := fun i => r i + s i) (r₂ := r) hβ href
  have hfun : (fun i => (r i + s i) - r i) = s := by
    funext i; ring
  rwa [hfun] at h

/-! ## Level 2: the multi-round drift budget -/

/-- Subadditivity of `oscil` along a finite family, by induction on the family. -/
theorem oscil_sum_le (r : ℕ → ι → ℝ) (n : ℕ) :
    oscil (fun i => ∑ k ∈ Finset.range n, r k i) ≤ ∑ k ∈ Finset.range n, oscil (r k) := by
  induction n with
  | zero =>
      simp only [Finset.range_zero, Finset.sum_empty, oscil]
      simp
  | succ n ih =>
      have hfun : (fun i => ∑ k ∈ Finset.range (n + 1), r k i)
          = fun i => (∑ k ∈ Finset.range n, r k i) + r n i := by
        funext i
        rw [Finset.sum_range_succ]
      rw [hfun, Finset.sum_range_succ]
      exact le_trans (oscil_add_le _ _) (by linarith)

/-- **Drift budget for iterated RLHF.**  After `n` alignment rounds with
rewards `r 0, …, r (n-1)`, the aligned policy has drifted from the SFT model by
at most `(∑_k oscil (r k)) / β` in the Hilbert projective metric. -/
theorem hilbertDist_gibbs_sum_le {β : ℝ} (hβ : 0 < β) {ref : ι → ℝ} (href : IsPosProb ref)
    (r : ℕ → ι → ℝ) (n : ℕ) :
    hilbertDist (gibbs β ref (fun i => ∑ k ∈ Finset.range n, r k i)) ref
      ≤ (∑ k ∈ Finset.range n, oscil (r k)) / β := by
  rw [hilbertDist_gibbs_ref hβ href]
  gcongr
  exact oscil_sum_le r n

/-- The same budget in total variation: the aligned model after `n` rounds is
within `exp((∑_k oscil (r k))/β) - 1` of the SFT model. -/
theorem tvDist_gibbs_sum_le {β : ℝ} (hβ : 0 < β) {ref : ι → ℝ} (href : IsPosProb ref)
    (r : ℕ → ι → ℝ) (n : ℕ) :
    tvDist (gibbs β ref (fun i => ∑ k ∈ Finset.range n, r k i)) ref
      ≤ Real.exp ((∑ k ∈ Finset.range n, oscil (r k)) / β) - 1 := by
  have hTV := tvDist_le_expm1_hilbertDist
    (gibbs_isPosProb (β := β) (r := fun i => ∑ k ∈ Finset.range n, r k i) href) href
  have hle := hilbertDist_gibbs_sum_le hβ href r n
  exact le_trans hTV (by
    have := Real.exp_le_exp.mpr hle
    linarith)

/-! ## Level 3: sharpness of the budget -/

/-- **Sharpness.**  If the accumulated reward has oscillation equal to the sum
of the per-round oscillations (no cancellation between rounds), the budget is
attained with equality. -/
theorem hilbertDist_gibbs_sum_eq_of_aligned {β : ℝ} (hβ : 0 < β) {ref : ι → ℝ}
    (href : IsPosProb ref) (r : ℕ → ι → ℝ) (n : ℕ)
    (hadd : oscil (fun i => ∑ k ∈ Finset.range n, r k i) = ∑ k ∈ Finset.range n, oscil (r k)) :
    hilbertDist (gibbs β ref (fun i => ∑ k ∈ Finset.range n, r k i)) ref
      = (∑ k ∈ Finset.range n, oscil (r k)) / β := by
  rw [hilbertDist_gibbs_ref hβ href, hadd]

/-- **Strictness in general.**  Two rounds whose rewards cancel leave the policy
at the SFT model although the budget is positive: the drift bound cannot be
improved to an equality without looking at the rewards jointly. -/
theorem drift_cancellation {β : ℝ} (hβ : 0 < β) {ref : ι → ℝ} (href : IsPosProb ref)
    (s : ι → ℝ) (hs : 0 < oscil s) :
    hilbertDist (gibbs β ref (fun i => s i + (-s i))) ref = 0
      ∧ 0 < (oscil s + oscil (fun i => -s i)) / β := by
  constructor
  · have hfun : (fun i => s i + (-s i)) = fun _ : ι => (0 : ℝ) := by
      funext i; ring
    rw [hfun, hilbertDist_gibbs_ref hβ href]
    simp only [oscil]
    simp
  · rw [oscil_neg]
    positivity

end NeuroSymbolicRLHF