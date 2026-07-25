import Combinatorics.PosetTheory.QuantumWalkPeriodicityMixing

/-!
# Cesàro mixing for periodic quantum walks

Periodic unitary dynamics cannot converge pointwise from a localized state, but its empirical
probabilities can stabilize after averaging.  This chapter proves an exact finite-time theorem:
every complete collection of periods has precisely the same empirical distribution as one
period.  Thus the one-period Born average is the canonical time-averaged equilibrium, with no
asymptotic error along complete-period observation windows.
-/

open Filter Topology
open scoped BigOperators

namespace QuantumWalkCesaroDeepening

open QuantumWalkPeriodicityMixing

/-- The empirical mean of a real sequence over its first `N` observations. -/
noncomputable def cesaroMean (f : ℕ → ℝ) (N : ℕ) : ℝ :=
  (∑ n ∈ Finset.range N, f n) / (N : ℝ)

/-- A periodic additive sequence sums over `q` complete periods to `q` copies of its
one-period sum.  This block decomposition is the algebraic engine of the averaging theory. -/
theorem periodic_sum_complete_blocks {E : Type*} [AddCommMonoid E]
    (f : ℕ → E) (k q : ℕ) (hperiodic : Function.Periodic f k) :
    (∑ n ∈ Finset.range (q * k), f n) = q • (∑ n ∈ Finset.range k, f n) := by
  induction' q with q ih;
  · simp +decide;
  · rw [ Nat.succ_mul, Finset.sum_range_add, ih ];
    simp +decide [add_smul];
    exact congr_arg _ ( Finset.sum_congr rfl fun n hn => by exact Nat.recOn q ( by simp +decide ) fun n ihn => by rw [ Nat.succ_mul, ← add_right_comm, hperiodic, ihn ] )

/-- Every positive complete-period Cesàro mean is exactly the one-period mean. -/
theorem periodic_cesaro_complete_blocks
    (f : ℕ → ℝ) (k q : ℕ) (hq : 0 < q)
    (hperiodic : Function.Periodic f k) :
    cesaroMean f (q * k) = cesaroMean f k := by
  by_cases hk : k = 0 <;> simp_all +decide [ cesaroMean ];
  rw [ periodic_sum_complete_blocks f k q hperiodic, nsmul_eq_mul, div_eq_div_iff ] <;> first | positivity | ring;

/-- For finite-order quantum evolution, every complete-period observation window has exactly
its one-period averaged Born probability at each state. -/
theorem bornProbability_cesaro_complete_blocks {G : Type*}
    (U : State G → State G) (ψ : State G) (k q : ℕ)
    (hq : 0 < q) (hU : U^[k] = id) (x : G) :
    cesaroMean (fun n => bornProbability U ψ n x) (q * k) =
      cesaroMean (fun n => bornProbability U ψ n x) k := by
  exact periodic_cesaro_complete_blocks _ _ _ hq (bornProbability_periodic U ψ k hU x)

/-- A periodic walk mixes uniformly along all complete-period windows precisely when its
single-period empirical Born distribution is uniform. -/
theorem complete_block_uniform_mixing_iff {G : Type*} [Fintype G]
    (U : State G → State G) (ψ : State G) (k : ℕ)
    (hU : U^[k] = id) :
    (∀ q, 0 < q → ∀ x,
      cesaroMean (fun n => bornProbability U ψ n x) (q * k) = uniformProbability G) ↔
    (∀ x, cesaroMean (fun n => bornProbability U ψ n x) k = uniformProbability G) := by
  apply Iff.intro;
  · exact fun h x => by simpa using h 1 zero_lt_one x;
  · intro hq q hq_pos x;
    rw [ ← hq x, bornProbability_cesaro_complete_blocks U ψ k q hq_pos hU x ]

/-- If the one-period Born average is uniform, then the complete-block empirical
probabilities converge pointwise to uniform.  In fact, the preceding theorem shows that the
sequence is already constant, a stronger finite-time conclusion. -/
theorem complete_block_uniform_tendsto {G : Type*} [Fintype G]
    (U : State G → State G) (ψ : State G) (k : ℕ)
    (hU : U^[k] = id)
    (hone : ∀ x, cesaroMean (fun n => bornProbability U ψ n x) k = uniformProbability G) :
    ∀ x, Tendsto
      (fun q => cesaroMean (fun n => bornProbability U ψ n x) ((q + 1) * k))
      atTop (𝓝 (uniformProbability G)) := by
  intro x;
  convert tendsto_const_nhds.congr' _;
  filter_upwards [ Filter.eventually_gt_atTop 0 ] with q hq using Eq.symm ( by simpa [ hone ] using bornProbability_cesaro_complete_blocks U ψ k (q + 1) (Nat.succ_pos q) hU x )

-- !-- Lab Notes -- !--
-- Hypothesis: periodic quantum dynamics should admit a canonical equilibrium after Cesàro
-- averaging even though instantaneous probabilities generally fail to converge.
-- Experiment: complete blocks of periods were expanded and compared with one period; the
-- identity survives for arbitrary additive codomains, not merely probabilities.
-- Analysis: all complete-block averages are exactly stationary.  Uniform time-averaged mixing
-- is therefore characterized by one finite period rather than by an infinite limiting process.
-- Critique: this does not assert instantaneous mixing, and it does not claim uniformity without
-- the explicit one-period criterion.  The positive-block hypothesis controls cancellation;
-- the zero-period boundary is handled directly.  No unitarity assumption is needed beyond the
-- stated finite-order identity.
-- Synthesis: the no-go theorem for pointwise mixing and the exact Cesàro theorem together isolate
-- the sharp distinction between instantaneous and time-averaged mixing for periodic walks.
-- !-- End Lab Notes -- !--

end QuantumWalkCesaroDeepening