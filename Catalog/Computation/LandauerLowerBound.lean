import Mathlib
import Computation.ReversibleTropicalThermodynamics

/-!
# Landauer's Lower Bound from the Deterministic Data-Processing Inequality

The catalog file `Computation.ReversibleTropicalThermodynamics` proves the **exact**
Landauer cost for *uniform n-bit erasure* (`entropy_drop_uniform_erasure`,
`landauer_cost_exact`) and characterizes reversibility as *zero* entropy loss
(`zero_entropy_loss_iff_bijective`). Those results are equalities about one very
special map (uniform erasure) and about bijections.

This file proves the **general inequality** underlying *all* of Landauer's principle:

> A deterministic computation can never *increase* Shannon entropy.

Equivalently, the Shannon entropy of the pushforward of any distribution along an
arbitrary function `f : α → β` is at most the entropy of the original distribution,
with **equality** exactly when `f` is injective on the support (reversible).

From this we read off Landauer's bound as a genuine *lower bound* on dissipated heat:
the thermodynamic work `k·T·(H(p) − H(f∗p))` of running `f` is always nonnegative, and
the only free computations are the reversible ones. The exact erasure cost of the
catalog is the extremal case where `f` collapses everything to a point.

The proof avoids the heavy concavity / grouping machinery usually invoked for the
data-processing inequality. The key observation is purely pointwise:
`f∗p (f x) ≥ p x` (the fiber sum dominates a single term), so `log (f∗p (f x)) ≥ log (p x)`,
and the entropy gap is a sum of nonnegative terms.

## Main results

* `pushforwardFun_isDistribution` — `f∗p` is a probability distribution when `p` is.
* `shannonEntropy_pushforward_le` — **data-processing inequality**:
  `H(f∗p) ≤ H(p)` for every function `f` and nonnegative weights `p`.
* `shannonEntropy_pushforward_of_injective` — **reversible ⇒ free**: injective maps
  preserve entropy exactly, `H(f∗p) = H(p)`.
* `landauer_lower_bound` — dissipated heat `k·T·(H(p) − H(f∗p)) ≥ 0`.
* `landauer_lower_bound_zero_of_injective` — reversible computations dissipate no heat.

## References
- Landauer, R. (1961). Irreversibility and heat generation in the computing process.
- Bennett, C.H. (1973). Logical reversibility of computation.
- Cover, T. & Thomas, J. (2006). Elements of Information Theory (data-processing).
-/

noncomputable section

open Finset Function Real BigOperators

namespace LandauerLowerBound

-- !-- Lab Notebook --!--
-- Hypothesis: The catalog only had the *exact* Landauer cost for uniform erasure and a
--   *zero*-loss characterization of bijections. We conjectured the unifying principle is
--   the deterministic data-processing inequality H(f∗p) ≤ H(p) for ARBITRARY f, with
--   erasure (collapse to a point) the extremal case and bijections the equality case.
-- Result: Proved H(f∗p) ≤ H(p) for all f and all nonnegative weight functions, plus the
--   exact equality H(f∗p) = H(p) for injective f, and the heat corollaries.
-- Insight: The usual DPI proof routes through concavity of entropy / grouping axioms.
--   Here the entire content collapses to the pointwise domination f∗p(f x) ≥ p x (a fiber
--   sum dominates one of its terms). The entropy gap H(p) − H(f∗p) telescopes to
--   ∑ₓ p x · (log(f∗p(f x)) − log(p x)), a sum of nonnegative terms.
-- Failure analysis: A first attempt tried to prove concavity of x ↦ −x log x and apply
--   Jensen per fiber; this dragged in `inner_le_nnorm`-style machinery and convexity API
--   mismatches. Switching to the pointwise log-monotonicity argument removed all analysis
--   beyond `Real.log_le_log` and `Finset.single_le_sum`.
-- !-- end Lab Notebook --!--

variable {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]

/-- Pushforward (image measure) of a weight function `p : α → ℝ` along `f : α → β`:
the weight of `y` is the total weight of its fiber `f⁻¹{y}`. -/
def pushforwardFun (f : α → β) (p : α → ℝ) : β → ℝ :=
  fun y => ∑ x ∈ univ.filter (fun x => f x = y), p x

-- !-- comment -- !--
-- The fiber-sum dominates any single term: `p x ≤ f∗p (f x)` for nonnegative `p`.
-- !-- comment -- !--
omit [Fintype β] in
/-- For nonnegative weights, the pushforward value at `f x` dominates `p x`,
since `x` lies in its own fiber and the other terms are nonnegative. -/
theorem pushforwardFun_apply_ge (f : α → β) (p : α → ℝ)
    (hp : ∀ x, 0 ≤ p x) (x : α) :
    p x ≤ pushforwardFun f p (f x) := by
  apply Finset.single_le_sum (f := p) (fun i _ => hp i)
  simp

omit [Fintype β] in
/-- The pushforward of a nonnegative weight function is nonnegative. -/
theorem pushforwardFun_nonneg (f : α → β) (p : α → ℝ)
    (hp : ∀ x, 0 ≤ p x) (y : β) :
    0 ≤ pushforwardFun f p y :=
  Finset.sum_nonneg fun i _ => hp i

-- !-- comment -- !--
-- Total mass is preserved: summing fiber weights over all `y` re-sums `p` over `α`.
-- !-- comment -- !--
/-- The pushforward preserves total mass: `∑ y, f∗p y = ∑ x, p x`. -/
theorem pushforwardFun_total (f : α → β) (p : α → ℝ) :
    ∑ y : β, pushforwardFun f p y = ∑ x : α, p x := by
  simpa [pushforwardFun] using Finset.sum_fiberwise (Finset.univ) f p

/-- The pushforward of a distribution is a distribution. -/
theorem pushforwardFun_isDistribution (f : α → β) (p : α → ℝ)
    (hp : IsDistribution p) :
    IsDistribution (pushforwardFun f p) :=
  ⟨fun y => pushforwardFun_nonneg f p hp.1 y,
   (pushforwardFun_total f p).trans hp.2⟩

-- !-- comment -- !--
-- Reindex H(f∗p) as a sum over the domain: regroup the entropy of the image measure
-- fiber-by-fiber, replacing `log (f∗p y)` by `log (f∗p (f x))` inside each fiber.
-- !-- comment -- !--
/-- Reindexing the entropy of the pushforward as a sum over the domain `α`. -/
theorem shannonEntropy_pushforward_eq (f : α → β) (p : α → ℝ) :
    shannonEntropy (pushforwardFun f p) =
      -∑ x : α, p x * Real.log (pushforwardFun f p (f x)) := by
  unfold shannonEntropy
  congr 1
  rw [← Finset.sum_fiberwise (Finset.univ) f
        (fun x => p x * Real.log (pushforwardFun f p (f x)))]
  refine Finset.sum_congr rfl ?_
  intro y _
  rw [show pushforwardFun f p y = ∑ x ∈ univ.filter (fun x => f x = y), p x from rfl,
      Finset.sum_mul]
  refine Finset.sum_congr rfl ?_
  intro x hx
  simp only [Finset.mem_filter] at hx
  rw [hx.2]
  rfl

-- !-- comment -- !--
-- Data-processing inequality: H(p) − H(f∗p) = ∑ₓ p x · (log(f∗p(f x)) − log(p x)) ≥ 0,
-- each term nonnegative because f∗p(f x) ≥ p x ≥ 0 and log is monotone.
-- !-- comment -- !--
/-- **Deterministic data-processing inequality.** A deterministic map never increases
Shannon entropy: the entropy of the pushforward distribution is at most that of the
original. This is the general principle underlying Landauer's bound. -/
theorem shannonEntropy_pushforward_le (f : α → β) (p : α → ℝ)
    (hp : ∀ x, 0 ≤ p x) :
    shannonEntropy (pushforwardFun f p) ≤ shannonEntropy p := by
  rw [shannonEntropy_pushforward_eq]
  have hterm : ∀ x ∈ (Finset.univ : Finset α),
      p x * Real.log (p x) ≤ p x * Real.log (pushforwardFun f p (f x)) := by
    intro x _
    rcases eq_or_lt_of_le (hp x) with h | h
    · simp [← h]
    · exact mul_le_mul_of_nonneg_left
        (Real.log_le_log h (pushforwardFun_apply_ge f p hp x)) (le_of_lt h)
  have hsum : ∑ x : α, p x * Real.log (p x)
      ≤ ∑ x : α, p x * Real.log (pushforwardFun f p (f x)) :=
    Finset.sum_le_sum hterm
  unfold shannonEntropy
  linarith [hsum]

-- !-- comment -- !--
-- Reversible ⇒ free: when f is injective every fiber is a singleton, so f∗p(f x) = p x
-- and the entropy gap vanishes term by term.
-- !-- comment -- !--
/-- **Reversible computations preserve entropy.** If `f` is injective then the pushforward
has exactly the same Shannon entropy: no information (and hence no heat) is lost. -/
theorem shannonEntropy_pushforward_of_injective (f : α → β) (p : α → ℝ)
    (hf : Function.Injective f) :
    shannonEntropy (pushforwardFun f p) = shannonEntropy p := by
  have hval : ∀ x, pushforwardFun f p (f x) = p x := by
    intro x
    have : (univ.filter (fun z => f z = f x)) = {x} := by
      ext z
      simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton]
      exact ⟨fun h => hf h, fun h => by rw [h]⟩
    simp [pushforwardFun, this]
  rw [shannonEntropy_pushforward_eq]
  unfold shannonEntropy
  congr 1
  refine Finset.sum_congr rfl ?_
  intro x _
  rw [hval x]

/-! ### Thermodynamic corollaries -/

/-- **Landauer's lower bound.** The thermodynamic work dissipated by running a
deterministic computation `f` on a distribution `p`, namely `k·T·(H(p) − H(f∗p))`,
is always nonnegative when `k, T ≥ 0`. Reversible (injective) computations are the
boundary case of zero dissipation. -/
theorem landauer_lower_bound (f : α → β) (p : α → ℝ)
    (hp : ∀ x, 0 ≤ p x) (k T : ℝ) (hk : 0 ≤ k) (hT : 0 ≤ T) :
    0 ≤ k * T * (shannonEntropy p - shannonEntropy (pushforwardFun f p)) := by
  have h := shannonEntropy_pushforward_le f p hp
  have : 0 ≤ shannonEntropy p - shannonEntropy (pushforwardFun f p) := by linarith
  positivity

/-- Reversible computations dissipate no heat: the Landauer cost of an injective map
is exactly zero. -/
theorem landauer_lower_bound_zero_of_injective (f : α → β) (p : α → ℝ)
    (hf : Function.Injective f) (k T : ℝ) :
    k * T * (shannonEntropy p - shannonEntropy (pushforwardFun f p)) = 0 := by
  rw [shannonEntropy_pushforward_of_injective f p hf]
  ring

end LandauerLowerBound

end