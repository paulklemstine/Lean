import Mathlib
import Catalog.Novelty.Counting
import Catalog.Novelty.OrderParameter
import Catalog.Novelty.Dimension
import Catalog.Novelty.Incompleteness

/-!
# Counted Proof Spaces: Entropy, Sparsity, and Critical Indices

A proof space over a finite alphabet has `S k n` syntactic strings of length at
most `n`.  This study connects three independently meaningful observables:
combinatorial volume, the density of a distinguished derivable subfamily, and
entropy density.  Exponentially sparse derivability forces the density to zero
while the ambient entropy remains positive.  If density is also antitone, every
admissible positive level has a unique finite crossing index.

The conclusions are conditional.  In particular, no canonical encoding is
claimed for named theorems, and exponential string growth does not imply a power
law for theorem lengths.
-/

namespace CountedProofSpace

open Filter Topology

/-- Density of a counted derivable family among all words of length at most `n`. -/
noncomputable def density (prov : ℕ → ℕ) (k n : ℕ) : ℝ :=
  (prov n : ℝ) / (ProofSpace.S k n : ℝ)

/-- Entropy density of the ambient language. -/
noncomputable def entropyDensity (k n : ℕ) : ℝ :=
  Real.log (ProofSpace.S k n : ℝ) / n

/-- The two-coordinate phase observable: derivability density and ambient entropy. -/
noncomputable def phaseObservable (prov : ℕ → ℕ) (k n : ℕ) : ℝ × ℝ :=
  (density prov k n, entropyDensity k n)

/-
The ambient count is positive, including at the boundary `n = 0`.
-/
lemma statementsUpTo_pos (k n : ℕ) : 0 < ProofSpace.S k n := by
  -- The sum starts at i=0, so it includes the term 1, which is positive.
  simp [ProofSpace.S];
  norm_num [ Finset.sum_range_succ' ]

/-
A genuine counted subfamily has density in the unit interval.
-/
theorem density_mem_Icc (prov : ℕ → ℕ) (k n : ℕ)
    (hsub : prov n ≤ ProofSpace.S k n) :
    density prov k n ∈ Set.Icc (0 : ℝ) 1 := by
  exact ⟨ div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ), div_le_one_of_le₀ ( mod_cast hsub ) ( Nat.cast_nonneg _ ) ⟩

/-
Exponential sparsity of the derivable subfamily forces its density to zero.
-/
theorem density_tendsto_zero (prov : ℕ → ℕ) (k : ℕ) (a C : ℝ)
    (hk : 2 ≤ k) (ha0 : 0 ≤ a) (hak : a < k) (hC : 0 ≤ C)
    (hsparse : ∀ n, (prov n : ℝ) ≤ C * a ^ n) :
    Tendsto (density prov k) atTop (𝓝 0) := by
  refine' squeeze_zero_norm _ _;
  use fun n => C * ( a / k ) ^ n;
  · intro n; rw [ density, Real.norm_of_nonneg ( by positivity ) ] ; rw [ div_pow ] ; rw [ mul_div ] ; gcongr;
    · exact hsparse n;
    · exact_mod_cast ProofSpace.pow_le_S k n;
  · simpa using tendsto_const_nhds.mul ( tendsto_pow_atTop_nhds_zero_of_lt_one ( by positivity ) ( div_lt_one ( by positivity ) |>.2 hak ) )

/-
The ambient entropy density converges to the logarithm of alphabet size.
-/
theorem entropyDensity_tendsto_log (k : ℕ) (hk : 2 ≤ k) :
    Tendsto (entropyDensity k) atTop (𝓝 (Real.log k)) := by
  convert ProofSpace.dimension_eq_log _ _ _ _ _ using 2;
  · norm_cast;
  · exact fun n => mod_cast ProofSpace.pow_le_S k n;
  · exact fun n => mod_cast ProofSpace.S_le_pow k n hk

/-
**Entropy–sparsity separation.**  Sparse derivability and exponentially growing
syntax produce the limiting phase vector `(0, log k)`.
-/
theorem phaseObservable_tendsto (prov : ℕ → ℕ) (k : ℕ) (a C : ℝ)
    (hk : 2 ≤ k) (ha0 : 0 ≤ a) (hak : a < k) (hC : 0 ≤ C)
    (hsparse : ∀ n, (prov n : ℝ) ≤ C * a ^ n) :
    Tendsto (phaseObservable prov k) atTop (𝓝 (0, Real.log k)) := by
  refine' Filter.Tendsto.prodMk_nhds _ ( entropyDensity_tendsto_log k hk );
  convert density_tendsto_zero prov k a C hk ha0 hak hC hsparse using 1

/-
**Counted sharp-transition theorem.**  Under exponential sparsity and antitone
density, every positive level below the initial density has a unique critical
index.  The phase vector simultaneously converges to zero derivability density
and positive ambient entropy, and the density is below the chosen level exactly
after that index.
-/
theorem unique_critical_index_with_entropy
    (prov : ℕ → ℕ) (k : ℕ) (a C ε : ℝ)
    (hk : 2 ≤ k) (ha0 : 0 ≤ a) (hak : a < k) (hC : 0 ≤ C)
    (hsparse : ∀ n, (prov n : ℝ) ≤ C * a ^ n)
    (hanti : Antitone (density prov k))
    (hε : 0 < ε) (hstart : ε ≤ density prov k 0) :
    Tendsto (phaseObservable prov k) atTop (𝓝 (0, Real.log k)) ∧
      ∃! c : ℕ, ε ≤ density prov k c ∧
        density prov k (c + 1) < ε ∧
        ∀ n, (density prov k n < ε ↔ c < n) := by
  refine' And.intro _ _;
  · exact phaseObservable_tendsto prov k a C hk ha0 hak hC hsparse;
  · -- By definition of $c$, we know that $ε ≤ density prov k c$ and $density prov k (c + 1) < ε$.
    obtain ⟨c, hc⟩ : ∃ c, ε ≤ density prov k c ∧ density prov k (c + 1) < ε := by
      -- Since the density tends to zero, there exists some $N$ such that for all $n \geq N$, $density prov k n < \epsilon$.
      obtain ⟨N, hN⟩ : ∃ N, ∀ n ≥ N, density prov k n < ε := by
        simpa using ( density_tendsto_zero prov k a C hk ha0 hak hC hsparse ) |> fun h => h.eventually ( gt_mem_nhds hε );
      contrapose! hN;
      exact ⟨ N, le_rfl, Nat.recOn N hstart fun n hn => hN n hn ⟩;
    refine' ⟨ c, ⟨ hc.1, hc.2, fun n => ⟨ fun hn => _, fun hn => _ ⟩ ⟩, fun n hn => _ ⟩;
    · exact not_le.mp fun h => hn.not_ge <| hc.1.trans <| hanti h;
    · exact lt_of_le_of_lt ( hanti hn ) hc.2;
    · grind +qlia

/-
The geometric length model has a constant successive ratio determined by
entropy, rather than a power-law ratio varying with length.
-/
theorem geometric_length_ratio_is_entropy (k : ℝ) (hk : 1 < k) (n : ℕ) :
    ProofSpace.lengthDist k (n + 1) / ProofSpace.lengthDist k n =
      Real.exp (-Real.log k) := by
  unfold ProofSpace.lengthDist;
  rw [ Real.exp_neg, Real.exp_log ( by positivity ), div_eq_iff ];
  · ring;
  · exact div_ne_zero ( by linarith ) ( by positivity )

#check ProofSpace.S_closed_form
#check ProofSpace.orderParameter_tendsto_zero
#check ProofSpace.FormalSystem.godel_incompleteness

/-- Concrete binary-language instance: a uniformly bounded derivable family has
zero asymptotic density. -/
example (prov : ℕ → ℕ) (hprov : ∀ n, prov n ≤ 7) :
    Tendsto (density prov 2) atTop (𝓝 0) := by
  apply density_tendsto_zero prov 2 1 7
  · omega
  · norm_num
  · norm_num
  · norm_num
  · intro n
    norm_num
    exact_mod_cast hprov n

/-- At length at most three, the binary ambient language contains fifteen words. -/
example : ProofSpace.S 2 3 = 15 := by norm_num [ProofSpace.S]

-- !-- Lab Notes -- !--
-- Hypothesis: Seven falsifiable proposals were ranked by impact: (1) sparse
-- derivability can coexist with positive syntactic entropy; (2) antitone density
-- plus sparsity forces a unique finite crossing at every admissible level; (3)
-- this crossing is stable under replacing exact counts by exponential bounds;
-- (4) the entropy exponent controls geometric length ratios; (5) that same
-- exponent forces a power law in raw length; (6) every encoding gives the same
-- critical index; and (7) abstract incompleteness alone determines a numerical
-- threshold.  Proposals (1)–(4) survive in guarded form; (5)–(7) do not.
-- Experiment: Exact word counts were combined with exponential upper bounds on
-- a counted derivable family.  The resulting phase observable was squeezed in
-- both coordinates.  A least crossing was then classified using antitonicity,
-- and concrete binary counts checked the boundary convention at length zero.
-- Analysis: Volume growth and derivability density are independent coordinates.
-- Their separation is structural: density may vanish while entropy tends to the
-- positive value `log k`.  Monotonicity converts this asymptotic fact into an
-- exact finite partition of indices around a uniquely determined crossing.
-- Critique: The crossing depends on the chosen encoding, level, and monotonicity
-- hypothesis.  Density can oscillate without antitonicity.  The geometric model
-- has constant successive ratio, which is a counterexample to identifying it
-- with a raw-length power law.  Abstract Gödel fixed points establish semantic
-- incompleteness but provide no numerical length threshold by themselves.
-- Synthesis: The first cycle linked catalog counting and entropy laws.  The
-- second cycle strengthened the link to a unique critical-index theorem for
-- actual natural-valued counts and isolated the precise boundary between the
-- proved geometric law and the rejected power-law prediction.  A broader
-- extension should compare critical indices under explicitly bounded recodings.

end CountedProofSpace