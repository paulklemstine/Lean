import Mathlib

/-!
# Reversible Thermodynamics of Computation: Shannon Entropy, Erasure, and Reversibility

This file provides the information-theoretic foundation for the *thermodynamics of
computation* used throughout the catalog's Landauer development
(`Computation.LandauerLowerBound`).

We work with finite probability distributions on a `Fintype`. The two physically
meaningful operations are:

* **Erasure** — collapsing a uniform distribution over `n` microstates to a single
  deterministic outcome (a Dirac mass). By Landauer's principle this *must* dissipate
  heat `k·T·log n`; for `n = 2^b` distinguishable states this is exactly `b` bits,
  i.e. `k·T·b·log 2` — the famous `k·T·log 2` *per erased bit*.
* **Reversible relabelling** — applying a bijection of the state space. This is the
  *free* operation: it preserves Shannon entropy exactly and so dissipates no heat.

## Main results

* `shannonEntropy_dirac` — a deterministic outcome has zero entropy.
* `shannonEntropy_uniform` — the uniform distribution on a type of cardinality `n`
  has entropy `log n`.
* `entropy_drop_uniform_erasure` — erasing uniform → Dirac drops entropy by exactly `log n`.
* `landauer_cost_exact` — the dissipated heat of uniform erasure is `k·T·log n`.
* `landauer_cost_per_bit` — for `2^b` states the cost is exactly `k·T·b·log 2`
  (Landauer's `k·T·log 2` per bit).
* `shannonEntropy_comp_equiv` — reversible relabelling (a bijection) preserves entropy:
  reversible computation is thermodynamically free.

## References
- Landauer, R. (1961). Irreversibility and heat generation in the computing process.
- Bennett, C.H. (1973). Logical reversibility of computation.
-/

noncomputable section

open Finset Function Real BigOperators

-- !-- Lab Notebook --!--
-- Hypothesis: All of Landauer's principle for *finite* computation can be founded on two
--   extremal facts about Shannon entropy on a `Fintype`: erasure (uniform → Dirac) costs
--   exactly `log n`, and bijective relabelling costs nothing.
-- Result: Both proved with no analysis machinery beyond `Real.log_inv` / `Real.log_pow`
--   and `Equiv.sum_comp`. The "per bit" law `k·T·b·log 2` falls out by specialising to
--   `n = 2^b` via `Real.log_pow`.
-- Insight: Entropy is invariant under reversible relabelling because the defining sum
--   `∑ p·log p` is reindexed by the bijection (`Equiv.sum_comp`); no probabilistic content
--   is needed. The erasure cost is a one-line `Finset.sum_const` computation.
-- Failure analysis: An initial attempt phrased erasure as a pushforward and tried to reuse
--   the data-processing inequality; that is circular here (DPI is downstream). Computing the
--   uniform and Dirac entropies directly is far cleaner and gives an *equality*, not a bound.
-- !-- end Lab Notebook --!--

/-- A finite probability distribution: nonnegative weights summing to one. -/
def IsDistribution {α : Type*} [Fintype α] (p : α → ℝ) : Prop :=
  (∀ x, 0 ≤ p x) ∧ ∑ x, p x = 1

/-- Shannon entropy `H(p) = -∑ₓ p x · log (p x)` of a finite weight function. -/
noncomputable def shannonEntropy {α : Type*} [Fintype α] (p : α → ℝ) : ℝ :=
  -∑ x : α, p x * Real.log (p x)

/-- The deterministic (Dirac) distribution concentrated at `x0`. -/
def diracDist {α : Type*} [Fintype α] [DecidableEq α] (x0 : α) : α → ℝ :=
  fun x => if x = x0 then 1 else 0

/-- The uniform distribution on a finite type of cardinality `n`. -/
noncomputable def uniformDist (α : Type*) [Fintype α] : α → ℝ :=
  fun _ => (Fintype.card α : ℝ)⁻¹

/-- The Dirac distribution is a genuine probability distribution. -/
theorem diracDist_isDistribution {α : Type*} [Fintype α] [DecidableEq α] (x0 : α) :
    IsDistribution (diracDist x0) := by
  refine ⟨fun x => ?_, ?_⟩
  · unfold diracDist; split <;> norm_num
  · unfold diracDist; rw [Finset.sum_ite_eq' Finset.univ x0]; simp

/-- The uniform distribution is a genuine probability distribution (for a nonempty type). -/
theorem uniformDist_isDistribution {α : Type*} [Fintype α] (h : 0 < Fintype.card α) :
    IsDistribution (uniformDist α) := by
  refine ⟨fun x => ?_, ?_⟩
  · unfold uniformDist; positivity
  · unfold uniformDist
    rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    field_simp

-- !-- comment -- !--
-- A deterministic outcome carries no information: the only nonzero term is `1·log 1 = 0`.
-- !-- comment -- !--
/-- **Erasure target has zero entropy.** A deterministic (Dirac) outcome carries no
information, so its Shannon entropy is `0`. -/
theorem shannonEntropy_dirac {α : Type*} [Fintype α] [DecidableEq α] (x0 : α) :
    shannonEntropy (diracDist x0) = 0 := by
  unfold shannonEntropy diracDist
  rw [Finset.sum_eq_single x0]
  · simp
  · intro b _ hb; simp [hb]
  · intro h; simp at h

-- !-- comment -- !--
-- The uniform entropy `∑ (1/n)·log(1/n) = log n` collapses via `Finset.sum_const`.
-- !-- comment -- !--
/-- **Maximum entropy of `n` states.** The uniform distribution on a type of cardinality
`n > 0` has Shannon entropy exactly `log n`. -/
theorem shannonEntropy_uniform {α : Type*} [Fintype α] (h : 0 < Fintype.card α) :
    shannonEntropy (uniformDist α) = Real.log (Fintype.card α) := by
  unfold shannonEntropy uniformDist
  rw [Finset.sum_const]
  simp only [Finset.card_univ, nsmul_eq_mul]
  have hn : (Fintype.card α : ℝ) ≠ 0 := by exact_mod_cast h.ne'
  rw [Real.log_inv]
  field_simp

-- !-- comment -- !--
-- Entropy drop of erasure = (log n) − 0 = log n, by the two computations above.
-- !-- comment -- !--
/-- **Entropy drop of erasure.** Collapsing the uniform distribution over `n` states to a
single deterministic outcome reduces Shannon entropy by exactly `log n`. -/
theorem entropy_drop_uniform_erasure {α : Type*} [Fintype α] [DecidableEq α] (x0 : α)
    (h : 0 < Fintype.card α) :
    shannonEntropy (uniformDist α) - shannonEntropy (diracDist x0)
      = Real.log (Fintype.card α) := by
  rw [shannonEntropy_uniform h, shannonEntropy_dirac]; ring

/-- **Landauer cost of erasure (exact).** The heat dissipated by erasing a uniform
distribution over `n` states is exactly `k·T·log n`. -/
theorem landauer_cost_exact {α : Type*} [Fintype α] [DecidableEq α] (x0 : α)
    (h : 0 < Fintype.card α) (k T : ℝ) :
    k * T * (shannonEntropy (uniformDist α) - shannonEntropy (diracDist x0))
      = k * T * Real.log (Fintype.card α) := by
  rw [entropy_drop_uniform_erasure x0 h]

-- !-- comment -- !--
-- Landauer per bit: specialise to `Fin (2^b)`; `log (2^b) = b·log 2` by `Real.log_pow`.
-- !-- comment -- !--
/-- **Landauer's `k·T·log 2` per bit.** Erasing a uniform distribution over `2^b`
microstates (i.e. `b` bits of information) dissipates exactly `k·T·b·log 2`. -/
theorem landauer_cost_per_bit (b : ℕ) (x0 : Fin (2^b)) (k T : ℝ) :
    k * T * (shannonEntropy (uniformDist (Fin (2^b))) - shannonEntropy (diracDist x0))
      = k * T * (b * Real.log 2) := by
  have hcard : (0 : ℕ) < Fintype.card (Fin (2^b)) := by
    rw [Fintype.card_fin]; exact Nat.two_pow_pos b
  rw [entropy_drop_uniform_erasure x0 hcard, Fintype.card_fin]
  rw [show ((2^b : ℕ) : ℝ) = (2:ℝ)^b by push_cast; ring, Real.log_pow]

-- !-- comment -- !--
-- Reversible relabelling is free: entropy is invariant under the bijection `e` because the
-- defining sum is reindexed by `Equiv.sum_comp`.
-- !-- comment -- !--
/-- **Reversible computation is free.** A bijective relabelling `e : α ≃ β` of the state
space preserves Shannon entropy exactly, so it dissipates no heat. This is the equality
case of Landauer's principle. -/
theorem shannonEntropy_comp_equiv {α β : Type*} [Fintype α] [Fintype β]
    (e : α ≃ β) (p : β → ℝ) :
    shannonEntropy (p ∘ e) = shannonEntropy p := by
  unfold shannonEntropy
  congr 1
  exact Equiv.sum_comp e (fun y => p y * Real.log (p y))

end