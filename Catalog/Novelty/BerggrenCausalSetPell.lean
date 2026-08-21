import Novelty.BerggrenCausalSetBoundary

/-!
# The Berggren causal set V: Pell cosmic time versus causal proper time

Fifth cycle.  The moonshot hypothesis proposed that the *silver-ratio growth* of the
Berggren tree "reproduces the dimension" of `2+1`-dimensional Minkowski space.  Cycles
I–IV showed the causal-set axioms hold, that intervals are chains of exactly `k+1` events,
and that the ambient separations are all spacelike.  This file isolates precisely *where*
the exponential growth lives: in the ambient time coordinate, never in the causal order.

## Main results

* `spine_hyp_rec` — along the Pell spine the hypotenuse obeys the Pell recurrence
  `c_{k+2} = 6 c_{k+1} − c_k`, derived from the exact two-dimensional linear system
  satisfied by `(a + b, c)` under the middle Berggren move.
* `spine_hyp_eq_bHyp` — the spine hypotenuse *is* the catalog sequence `bHyp`
  (`5, 29, 169, 985, 5741, …`), tying this development to
  `Bridges.BerggrenTrees.BerggrenPythagoreanCore`.
* `spine_hyp_ge_pow` — `5^{k+1} ≤ c_k`: the ambient ("cosmic") time coordinate grows
  exponentially, at the Pell rate `3 + 2√2 = (1+√2)²`, the square of the silver ratio.
* `cosmic_exponential_proper_linear` — the verdict of the cycle: along the same chain the
  *causal* proper time is exactly `k` while the ambient time coordinate is at least
  `5^{k+1}`.  Exponential growth is a statement about the embedding coordinates, not about
  the causal order, and therefore carries no spacetime dimension: the interval volumes stay
  linear (cycle II, `not_myrheim_meyer_dim_two`).
-/

namespace BerggrenCausalSet

/-! ## Part A. The Pell recurrence of the spine -/

theorem step_B_sum (t : Event) :
    (applyStep BerggrenStep.B t).1 + (applyStep BerggrenStep.B t).2.1
      = 3 * (t.1 + t.2.1) + 4 * t.2.2 := by
  obtain ⟨a, b, c⟩ := t
  simp only [applyStep_B, bergB]
  ring

theorem step_B_hyp (t : Event) :
    (applyStep BerggrenStep.B t).2.2 = 2 * (t.1 + t.2.1) + 3 * t.2.2 := by
  obtain ⟨a, b, c⟩ := t
  simp only [applyStep_B, bergB]
  ring

/-- **The Pell recurrence of the spine's cosmic time.** -/
theorem spine_hyp_rec (k : ℕ) :
    (spine (k + 2)).2.2 = 6 * (spine (k + 1)).2.2 - (spine k).2.2 := by
  have h1 : (spine (k + 1)).2.2 = 2 * ((spine k).1 + (spine k).2.1) + 3 * (spine k).2.2 := by
    rw [spine_succ, step_B_hyp]
  have h2 : (spine (k + 2)).2.2
      = 2 * ((spine (k + 1)).1 + (spine (k + 1)).2.1) + 3 * (spine (k + 1)).2.2 := by
    rw [spine_succ (k + 1), step_B_hyp]
  have h3 : (spine (k + 1)).1 + (spine (k + 1)).2.1
      = 3 * ((spine k).1 + (spine k).2.1) + 4 * (spine k).2.2 := by
    rw [spine_succ, step_B_sum]
  rw [h2, h3]
  linarith [h1]

theorem spine_hyp_zero : (spine 0).2.2 = 5 := rfl

theorem spine_hyp_one : (spine 1).2.2 = 29 := by decide

/-- The spine's hypotenuse is exactly the catalog Pell sequence `bHyp`. -/
theorem spine_hyp_eq_bHyp (k : ℕ) : (spine k).2.2 = bHyp k := by
  have H : ∀ n : ℕ, (spine n).2.2 = bHyp n ∧ (spine (n + 1)).2.2 = bHyp (n + 1) := by
    intro n
    induction n with
    | zero => exact ⟨spine_hyp_zero, spine_hyp_one⟩
    | succ m ih =>
        refine ⟨ih.2, ?_⟩
        rw [spine_hyp_rec, bHyp_recurrence, ih.1, ih.2]
  exact (H k).1

/-- **Cosmic time grows exponentially** along the Pell spine. -/
theorem spine_hyp_ge_pow (k : ℕ) : (5 : ℤ) ^ (k + 1) ≤ (spine k).2.2 := by
  have H : ∀ n : ℕ, (5 : ℤ) ^ (n + 1) ≤ (spine n).2.2 ∧
      (5 : ℤ) ^ (n + 2) ≤ (spine (n + 1)).2.2 := by
    intro n
    induction n with
    | zero =>
        refine ⟨by rw [spine_hyp_zero]; norm_num, by rw [spine_hyp_one]; norm_num⟩
    | succ m ih =>
        refine ⟨ih.2, ?_⟩
        have hmono : (spine m).2.2 ≤ (spine (m + 1)).2.2 :=
          le_of_lt (by rw [spine_succ]; exact step_hyp_lt _ (spine_isEvent m))
        have hrec := spine_hyp_rec m
        have : (5 : ℤ) * (spine (m + 1)).2.2 ≤ (spine (m + 2)).2.2 := by
          rw [hrec]; linarith
        calc (5 : ℤ) ^ (m + 1 + 2) = 5 * 5 ^ (m + 2) := by ring
          _ ≤ 5 * (spine (m + 1)).2.2 := by linarith [ih.2]
          _ ≤ (spine (m + 1 + 1)).2.2 := this
  exact (H k).1

/-! ## Part B. Cosmic time versus proper time -/

theorem spine_properTime (k : ℕ) : properTime root (spine k) = k := by
  unfold spine
  rw [properTime_eq root_isEvent (w := List.replicate k BerggrenStep.B) rfl]
  simp

/-- **The verdict of cycle V.**  Along one and the same causal chain, the *causal* proper
time is exactly `k`, while the ambient Minkowski time coordinate is at least `5^{k+1}`: the
Pell/silver exponential growth of the Berggren tree is a property of the embedding
coordinates, not of the causal order, and hence cannot supply a spacetime dimension. -/
theorem cosmic_exponential_proper_linear (k : ℕ) :
    properTime root (spine k) = k ∧ (5 : ℤ) ^ (k + 1) ≤ (spine k).2.2 ∧
      (causalInterval root (spine k)).ncard = k + 1 :=
  ⟨spine_properTime k, spine_hyp_ge_pow k, interval_growth_linear k⟩

end BerggrenCausalSet