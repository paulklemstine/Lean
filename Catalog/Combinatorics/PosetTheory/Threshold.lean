import Mathlib
import Novelty.PosetTheory.OrderParameter
import Novelty.NeuralCoding.Dimension

/-!
# Threshold laws in counted proof spaces

A finite alphabet supplies an exponentially growing ambient space of statements.
This study separates two mathematically distinct phenomena.  First, exponential
sparsity of derivable statements forces their density to vanish while the ambient
entropy remains positive.  Second, an antitone order parameter with a strict
one-step crossing has an exact and unique critical index.

The results are conditional counting laws.  They do not identify famous named
theorems with a critical length, and they do not infer a power law from geometric
growth.
-/

namespace ProofSpacePhaseTransitions

open Filter Topology

/-- The joint observable records derivability density and ambient entropy density. -/
noncomputable def phaseVector (prov tot : ℕ → ℝ) (n : ℕ) : ℝ × ℝ :=
  (ProofSpace.orderParameter prov tot n, Real.log (tot n) / n)

/-
**Entropy-density separation.** If the ambient language grows with base `k`,
while derivable statements grow with a strictly smaller base `a`, then the joint
observable converges to `(0, log k)`.  Thus density vanishes despite positive
ambient entropy.
-/
theorem phaseVector_tendsto_sparse_entropy (prov tot : ℕ → ℝ) (k a C : ℝ)
    (hk : 1 < k) (ha0 : 0 ≤ a) (hak : a < k) (hC : 0 ≤ C)
    (hprov0 : ∀ n, 0 ≤ prov n)
    (hlower : ∀ n, k ^ n ≤ tot n)
    (hupper : ∀ n, tot n ≤ k ^ (n + 1))
    (hsparse : ∀ n, prov n ≤ C * a ^ n) :
    Tendsto (phaseVector prov tot) atTop (𝓝 (0, Real.log k)) := by
  convert Tendsto.prodMk_nhds _ _ using 1;
  · convert ProofSpace.orderParameter_tendsto_zero prov tot k a C hk ha0 hak hC hprov0 hlower hsparse using 1;
  · convert ProofSpace.dimension_eq_log tot k hk hlower hupper using 1

/-
**Exact critical-index law.** For an antitone order parameter, if level `ε`
lies strictly between the values at `c` and `c+1`, then crossing below `ε`
occurs exactly at indices greater than `c`.
-/
theorem exact_critical_index (r : ℕ → ℝ) (ε : ℝ) (c n : ℕ)
    (hanti : Antitone r) (hbelow : r (c + 1) < ε) (habove : ε ≤ r c) :
    r n < ε ↔ c < n := by
  exact ⟨ fun h => Nat.lt_of_not_ge fun h' => by linarith [ hanti h' ], fun h => lt_of_le_of_lt ( hanti ( by linarith ) ) hbelow ⟩

/-
**Existence of a sharp finite threshold.** A nonnegative antitone observable
converging to zero has a finite critical index for every positive level not
exceeding its initial value. Beyond that index, and only beyond it, the observable
lies strictly below the level.
-/
theorem exists_exact_critical_index (r : ℕ → ℝ) (ε : ℝ)
    (hanti : Antitone r) (hlim : Tendsto r atTop (𝓝 0))
    (hε : 0 < ε) (hstart : ε ≤ r 0) :
    ∃ c : ℕ, ε ≤ r c ∧ r (c + 1) < ε ∧ ∀ n, (r n < ε ↔ c < n) := by
  obtain ⟨c, hc⟩ : ∃ c, r c < ε ∧ ∀ m < c, r m ≥ ε := by
    exact ⟨ Nat.find ( Filter.Eventually.exists ( hlim.eventually ( gt_mem_nhds hε ) ) ), Nat.find_spec ( Filter.Eventually.exists ( hlim.eventually ( gt_mem_nhds hε ) ) ), fun m mn => not_lt.1 fun contra => Nat.find_min ( Filter.Eventually.exists ( hlim.eventually ( gt_mem_nhds hε ) ) ) mn contra ⟩;
  refine' ⟨ c - 1, _, _, _ ⟩ <;> rcases c with ( _ | c ) <;> simp_all +decide;
  · linarith;
  · linarith;
  · exact fun n => ⟨ fun hn => not_le.1 fun h => hn.not_ge <| hc.2 _ h, fun hn => lt_of_le_of_lt ( hanti hn ) hc.1 ⟩ ;

/-- A strict one-step crossing determines at most one critical index. -/
theorem critical_index_unique (r : ℕ → ℝ) (ε : ℝ) (c d : ℕ)
    (hanti : Antitone r)
    (hcBelow : r (c + 1) < ε) (hcAbove : ε ≤ r c)
    (hdBelow : r (d + 1) < ε) (hdAbove : ε ≤ r d) :
    c = d := by
  exact le_antisymm ( Nat.le_of_lt_succ <| lt_of_not_ge fun h => by linarith [ hanti <| Nat.succ_le_of_lt h ] ) ( Nat.le_of_lt_succ <| lt_of_not_ge fun h => by linarith [ hanti <| Nat.succ_le_of_lt h ] )

/-
The geometric length law is controlled exactly by entropy: its ratio at
successive lengths is `exp (-log k) = 1/k`.  This is exponential decay, not a
power law in the length variable.
-/
theorem lengthDist_successor_entropy_ratio (k : ℝ) (hk : 1 < k) (n : ℕ) :
    ProofSpace.lengthDist k (n + 1) =
      Real.exp (-Real.log k) * ProofSpace.lengthDist k n := by
  unfold ProofSpace.lengthDist; ring_nf;
  rw [ Real.exp_neg, Real.exp_log ] <;> norm_num [ sq, mul_assoc, ne_of_gt ( zero_lt_one.trans hk ) ];
  · ring;
  · positivity

-- !-- Lab Notes -- !--
-- Hypothesis: Six ranked, falsifiable possibilities were considered: (1) sparse
-- derivability coexists with positive entropy; (2) convergence plus monotonicity
-- forces a finite threshold at every positive level; (3) that threshold is unique;
-- (4) geometric length weights encode entropy in their successive ratio; (5) the
-- same weights form a power law in length; and (6) monotonicity alone selects a
-- canonical critical index.  The first four survived; the last two failed.
-- Experiment: Exponential upper and lower bounds were combined with the catalog's
-- independent density and dimension laws.  For the finite transition, the least
-- index below a prescribed level was extracted and tested against every index by
-- antitonicity.  The exact symbolic ratio of consecutive length weights was also
-- calculated.
-- Analysis: Exponential sparsity gives a robust two-coordinate limit `(0, log k)`.
-- Convergence to zero and antitonicity upgrade this asymptotic law to an exact
-- finite crossing theorem for each admissible positive level.
-- Critique: A sharp threshold is level-dependent and requires monotonicity;
-- arbitrary density sequences may oscillate.  The geometric distribution has a
-- constant successive ratio and therefore is not a power law in length.  No
-- unconditional claim about Gödel sentences, Fermat's Last Theorem, or the ABC
-- conjecture follows from counting.
-- Synthesis: The first cycle produced entropy-density separation and a guarded
-- crossing law.  A second cycle strengthened the latter from conditional
-- uniqueness to existence, exact classification of all post-critical indices,
-- and uniqueness.  The remaining research problem is to derive the counting and
-- monotonicity hypotheses from natural classes of deductive systems.

end ProofSpacePhaseTransitions