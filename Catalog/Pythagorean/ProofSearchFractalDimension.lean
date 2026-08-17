import Catalog.Algebra.Analysis.TruthFractalDimensionDeepening

/-!
# Fractal Dimension of Proof Search

A bounded-branching proof search can be encoded by finite words: at depth `n`, a
successful-prefix theory records those words which can still extend to a proof.
For binary branching, the natural entropy dimension is the logarithmic growth
rate already developed for theories of binary strings.

The central conclusion is a boundary theorem: under this normalization every
successful-path set has dimension at most `1`. Thus a proposed distinction
between easy searches (`D < 1`) and hard searches (`D > 1`) cannot hold for
subsets of a fixed bounded-branching path space. Periodic pruning nevertheless
produces every rational dimension in `[0,1]`, and exact estimates at period
boundaries make the model directly testable.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer), ranked by expected impact:
1. A normalized successful-path dimension can never exceed the ambient value `1`.
2. Every rational dimension in `[0,1]` occurs for a periodically pruned search.
3. At complete periods, finite-depth estimates equal the limiting dimension exactly.
4. Positive codimension is the asymptotic density of forbidden decision levels.
5. Dimension alone determines shortest-proof length up to reciprocal codimension.
6. Finite-depth Monte Carlo estimates can distinguish all periodically pruned models.

Experiment (Experimenter): boundedness follows from the ambient binary counting
law. Periodic models were instantiated by allowing free choices at selected
residue classes. Their dimensions and complete-period estimates were computed
exactly. The fifth hypothesis was challenged by attaching arbitrary terminal
proof lengths to the same successful-prefix theory.

Analysis (Analyst): hypotheses 1--4 survive. Hypothesis 5 fails without an
additional semantic relation between terminal proofs and successful prefixes:
the same path set, hence the same dimension, can carry any designated shortest
length. Hypothesis 6 needs statistical confidence bounds beyond the exact
period-boundary calculation established here.

Critique (Critic): the ambient upper bound exposes a definition-level flaw in the
suggested `D > 1` hard regime, rather than merely a difficult conjecture. The
periodic realization theorem is nontrivial, resting on exact combinatorial counts
and an analytic limit. The arbitrary-length countermodel is deliberately marked
as a boundary of what dimension alone can imply. No external arXiv, OEIS, or
LMFDB signal was supplied, so no unsupported external attribution was introduced.

Synthesis (Principal Investigator): normalized dimension measures exponential
abundance of successful prefixes, not search cost by itself. A cost theory must
add a search policy, failure distribution, or terminal-depth law. Periodic
pruning supplies a controlled benchmark family for such an extension.
-/

open Filter Topology
open TruthFractalDimensionDeepening

namespace PeriodicProofSearchFractalDimension

/-- A binary proof-search profile records successful derivation prefixes at each depth. -/
abbrev SearchProfile := Theory

/-- An abstract search instance separates its successful-prefix geometry from a
chosen shortest terminal proof length. This separation is useful for identifying
what cannot follow from geometry alone. -/
structure SearchInstance where
  profile : SearchProfile
  shortestProof : ℕ

/-- The normalized fractal dimension of successful derivation prefixes. -/
noncomputable def searchDim (S : SearchProfile) : ℝ := boxDim S

/-- The finite-depth Monte Carlo target: logarithmic successful-prefix density. -/
noncomputable def finiteEstimate (S : SearchProfile) (n : ℕ) : ℝ := dimEstimate S n

/-
Every binary successful-path set has dimension at most that of the ambient
binary tree. In particular, a super-unit regime is unavailable.
-/
theorem searchDim_le_one (S : SearchProfile) : searchDim S ≤ 1 := by
  apply TruthFractalDimensionDeepening.boxDim_le_one

/-
A positive excess above one is impossible for normalized binary proof search.
-/
theorem no_superunit_hard_regime (S : SearchProfile) {ε : ℝ} (hε : 0 < ε) :
    searchDim S ≠ 1 + ε := by
  linarith [ searchDim_le_one S ]

/-
Periodic pruning realizes the dimension equal to the density of decision
levels at which both binary branches remain available.
-/
theorem periodic_search_dimension (m : ℕ) (R : Finset ℕ)
    (hR : R ⊆ Finset.range m) (hm : 1 ≤ m) :
    searchDim (densityTheory m R) = (R.card : ℝ) / m := by
  convert boxDim_densityTheory m R hR hm using 1

/-
Every rational normalized dimension in the unit interval is realized by a
concrete periodically pruned proof search.
-/
theorem every_rational_search_dimension (p q : ℕ) (hpq : p ≤ q) (hq : 1 ≤ q) :
    ∃ S : SearchProfile, searchDim S = (p : ℝ) / q := by
  convert TruthFractalDimensionDeepening.rational_dimension_realized p q hpq hq using 1

/-
At a complete number of periods, the finite-depth estimate already equals the
limiting dimension exactly; no asymptotic approximation error remains.
-/
theorem finiteEstimate_at_periods (m : ℕ) (R : Finset ℕ)
    (hR : R ⊆ Finset.range m) (k : ℕ) (hk : 1 ≤ k) :
    finiteEstimate (densityTheory m R) (m * k) = (R.card : ℝ) / m := by
  unfold finiteEstimate;
  rw [ dimEstimate_densityTheory, freeCount_mul m R hR k ];
  rw [ Nat.cast_mul, Nat.cast_mul, mul_div_mul_right _ _ ( by positivity ) ]

/-
For periodic pruning, codimension is exactly the density of forbidden levels.
-/
theorem periodic_codimension (p q : ℕ) (hpq : p ≤ q) (hq : 1 ≤ q) :
    ∃ S : SearchProfile,
      searchDim S = (p : ℝ) / q ∧ 1 - searchDim S = ((q - p : ℕ) : ℝ) / q := by
  obtain ⟨ S, hS ⟩ := every_rational_search_dimension p q hpq hq; use S; simp_all +decide [ Nat.cast_sub hpq ] ;
  rw [ sub_div, div_self ( by positivity ) ]

/-
Dimension alone places no constraint on a separately designated shortest
proof length: every rational dimension can coexist with every natural length.
-/
theorem dimension_does_not_determine_length
    (p q L : ℕ) (hpq : p ≤ q) (hq : 1 ≤ q) :
    ∃ I : SearchInstance,
      searchDim I.profile = (p : ℝ) / q ∧ I.shortestProof = L := by
  obtain ⟨ S, hS ⟩ := every_rational_search_dimension p q hpq hq;
  exact ⟨ ⟨ S, L ⟩, hS, rfl ⟩

#check @searchDim_le_one
#check @finiteEstimate_at_periods
#check @dimension_does_not_determine_length

example : searchDim (densityTheory 3 {0, 1}) = 2 / 3 := by
  apply periodic_search_dimension
  · decide
  · norm_num

example : finiteEstimate (densityTheory 3 {0, 1}) 12 = 2 / 3 := by
  convert finiteEstimate_at_periods 3 {0, 1} (by decide) 4 (by norm_num) using 1

example : ∃ I : SearchInstance, searchDim I.profile = (1 : ℝ) / 2 ∧ I.shortestProof = 1000 := by
  convert dimension_does_not_determine_length 1 2 1000 (by norm_num) (by norm_num) using 1
  norm_num

/-!
**Generalization.** The periodic family extends to `b`-ary search by normalizing
with logarithm base `b`; the same free-level density should be recovered. More
broadly, stationary ergodic pruning suggests an entropy-rate interpretation,
linking symbolic dynamics, information theory, and search complexity.

**Boundaries.** Empty successful sets, oscillating aperiodic pruning, and
unbounded branching require separate treatment. Most importantly, dimension
counts successful prefixes but does not specify the order in which a procedure
visits them. Search time therefore cannot be inferred without a policy and a
model of failed branches. The super-unit boundary is absolute for this normalized
binary model: any claim using `D > 1` must change either the metric, normalization,
or ambient search space.
-/

end PeriodicProofSearchFractalDimension