import Mathlib
import Logic.JarzynskiLandauer

/-!
# Proof Complexity and Thermodynamic Cost

This study separates three quantities that are often conflated: the written length of a
proof, its shortest-description complexity, and the heat assigned to that description.
For a proof `p` at temperature `T`, the model uses

`proofCost K T p = K(p) · T · log 2`.

The finite ensemble at size `n` contains `2^n` proof objects.  Its description complexity
obeys the standard counting condition: fewer than `k` bits can describe at most `2^k - 1`
objects.  This hypothesis is independent of any particular programming language and isolates
the combinatorial content of incompressibility.

The principal results are:

* thermodynamic cost is monotone in description complexity at nonnegative temperature;
* written length alone does not order thermodynamic cost, even when complexity never exceeds
  written length;
* at least half of an `n`-bit ensemble has complexity at least `n-1`;
* consequently the aggregate complexity is bounded below by
  `(n-1)2^(n-1)` and above by `n2^n`;
* the same two-sided bounds transfer exactly to aggregate thermodynamic cost;
* every fixed positive temperature admits proofs of arbitrarily large cost whenever the
  complexity spectrum is unbounded.

Thus the natural counting law is linear average complexity and order `n·2^n` aggregate
complexity.  A bare assertion of exponential *average* cost requires a different probability
model or a cost not linear in description complexity.

-- !-- Lab Notes -- !--

Hypothesis: Seven falsifiable targets were considered, ranked by expected impact:
(1) shortest-proof complexity eventually escapes every computable bound in a fixed sound
arithmetic theory [famous-open-problem analogue: Chaitin incompleteness]; (2) constrained
irreversible verification turns propositional proof-size lower bounds into heat lower bounds
[famous-open-problem analogue: proof complexity and P versus NP]; (3) uniform binary
ensembles have exponential mean description cost; (4) at least half of an `n`-bit ensemble
requires `n-1` description bits [coding–thermodynamics bridge]; (5) aggregate cost is of order
`n·2^n` [combinatorics–thermodynamics bridge]; (6) written proof length orders thermodynamic
cost [syntax–information bridge]; and (7) unbounded description complexity yields unbounded
cost at positive temperature [computability–thermodynamics bridge].

Experiment: Targets (4), (5), and (7) survive under explicit hypotheses.  Target (6) is
refuted by two proof objects whose written lengths are `2 < 3` but whose description
complexities are `1 > 0`.  Target (3) is incompatible with the uniform model: its mean lies
between `(n-1)/2` and `n`.  Target (1) requires a concrete universal description language,
and target (2) additionally requires a verifier and a memory-sensitive dissipation model.

Analysis: Binary description scarcity is the common structural mechanism.  It forces a large
high-complexity fiber, which gives an aggregate lower bound; multiplication by the positive
one-bit Landauer factor then transfers the order relation and both finite-size bounds to heat.
Description length and proof-search work must remain distinct: only the latter can naturally
support exponential average growth in this model.

Critique: No conclusion identifies written length with shortest-description complexity.
Temperature is nonnegative for monotonicity and strictly positive for strict or unbounded
conclusions.  The counting theorem assumes a finite ensemble and an explicit scarcity axiom;
it does not claim a universal-machine construction.  The computable-bound and
memory-constrained claims therefore remain conjectures rather than being hidden assumptions.

Synthesis: The surviving results form a hierarchy from one-bit entropy loss, through finite
incompressibility and aggregate bounds, to unbounded cost spectra.  The failed exponential
mean and surface-length claims delimit the model and motivate search-time and reversible-memory
extensions.

-- !-- End Lab Notes -- !--
-/

noncomputable section

open Finset Real BigOperators

namespace ProofThermodynamics

/-- Thermodynamic cost assigned to a proof by a description-complexity function. -/
def proofCost {P : Type*} (K : P → ℕ) (T : ℝ) (p : P) : ℝ :=
  K p * T * Real.log 2

/-- The one-bit cost is temperature times the entropy lost by uniform Boolean erasure,
linking description cost to the finite Landauer entropy identity. -/
theorem oneBitCost_eq_temperature_mul_entropyLoss (T : ℝ) (p : Unit) :
    proofCost (fun _ : Unit => 1) T p =
      T * (JarzynskiLandauer.shannonEntropy JarzynskiLandauer.uniformBool -
        JarzynskiLandauer.shannonEntropy JarzynskiLandauer.erasedBool) := by
  rw [JarzynskiLandauer.entropy_loss]
  simp [proofCost]

/-
At nonnegative temperature, lower description complexity gives no greater cost.
-/
theorem proofCost_mono {P : Type*} {K : P → ℕ} {T : ℝ} (hT : 0 ≤ T)
    {p q : P} (hK : K p ≤ K q) : proofCost K T p ≤ proofCost K T q := by
  exact mul_le_mul_of_nonneg_right ( mul_le_mul_of_nonneg_right ( Nat.cast_le.mpr hK ) hT ) ( Real.log_nonneg one_le_two )

/-
At positive temperature, thermodynamic cost strictly reflects description complexity.
-/
theorem proofCost_strictMono {P : Type*} {K : P → ℕ} {T : ℝ} (hT : 0 < T)
    {p q : P} (hK : K p < K q) : proofCost K T p < proofCost K T q := by
  exact mul_lt_mul_of_pos_right ( mul_lt_mul_of_pos_right ( Nat.cast_lt.mpr hK ) hT ) ( Real.log_pos one_lt_two )

/-
Written length need not order thermodynamic cost, even when every complexity is bounded
by the corresponding written length.
-/
theorem shorter_written_proof_can_cost_more :
    ∃ (length complexity : Fin 2 → ℕ) (T : ℝ) (p q : Fin 2),
      (∀ r, complexity r ≤ length r) ∧ length p < length q ∧
      proofCost complexity T q < proofCost complexity T p := by
  -- Define the length and complexity functions on `Fin 2`.
  use ![2, 3], ![1, 0];
  norm_num [ Fin.forall_fin_two, proofCost ];
  exact ⟨ 1, by positivity ⟩

/-- A finite `n`-bit proof ensemble equipped with an abstract description complexity.
The scarcity axiom is the usual binary counting bound for descriptions shorter than `k`. -/
structure BinaryComplexityEnsemble (n : ℕ) where
  complexity : Fin (2 ^ n) → ℕ
  complexity_le : ∀ p, complexity p ≤ n
  short_count : ∀ k, k ≤ n →
    ((Finset.univ.filter fun p => complexity p < k).card) ≤ 2 ^ k - 1

/-- Proofs whose description complexity is at least `k`. -/
def BinaryComplexityEnsemble.high {n : ℕ} (E : BinaryComplexityEnsemble n) (k : ℕ) :
    Finset (Fin (2 ^ n)) := Finset.univ.filter fun p => k ≤ E.complexity p

/-
The short and high-complexity portions partition the ensemble.
-/
lemma short_card_add_high_card {n k : ℕ} (E : BinaryComplexityEnsemble n) :
    (Finset.univ.filter fun p => E.complexity p < k).card + (E.high k).card = 2 ^ n := by
  convert Finset.card_add_card_compl ( Finset.filter ( fun p => E.complexity p < k ) Finset.univ ) using 1;
  · unfold BinaryComplexityEnsemble.high; aesop;
  · norm_num

/-
At least half of all `n`-bit proof objects require `n-1` bits of description.
-/
theorem half_incompressible {n : ℕ} (hn : 1 ≤ n) (E : BinaryComplexityEnsemble n) :
    2 ^ (n - 1) ≤ (E.high (n - 1)).card := by
  have := E.short_count ( n - 1 );
  rcases n with ( _ | _ | n ) <;> simp_all +decide [pow_succ'];
  · exact ⟨ 0, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, Nat.zero_le _ ⟩ ⟩;
  · have := short_card_add_high_card E ( k := n + 1 );
    grind +qlia

/-- Aggregate description complexity of an ensemble. -/
def BinaryComplexityEnsemble.totalComplexity {n : ℕ} (E : BinaryComplexityEnsemble n) : ℕ :=
  ∑ p, E.complexity p

/-
The incompressible half supplies a lower bound on aggregate complexity.
-/
theorem totalComplexity_lower {n : ℕ} (hn : 1 ≤ n) (E : BinaryComplexityEnsemble n) :
    (n - 1) * 2 ^ (n - 1) ≤ E.totalComplexity := by
  -- Let $H=E.high(n-1)$.
  set H := E.high (n - 1) with hH
  have h_card_H : H.card ≥ 2 ^ (n - 1) := by
    convert half_incompressible hn E;
  -- Since $H \subseteq \text{univ}$, we have $\sum_{p \in H} \text{complexity}(p) \leq \sum_{p \in \text{univ}} \text{complexity}(p)$.
  have h_sum_H_le_sum_univ : ∑ p ∈ H, E.complexity p ≤ E.totalComplexity := by
    exact Finset.sum_le_sum_of_subset ( Finset.subset_univ _ );
  exact le_trans ( by simpa [ mul_comm ] using Nat.mul_le_mul_left ( n - 1 ) h_card_H ) ( h_sum_H_le_sum_univ.trans' ( Finset.sum_le_sum fun x hx => Finset.mem_filter.mp hx |>.2 ) )

/-
The length cap supplies the matching upper scale `n·2^n`.
-/
theorem totalComplexity_upper {n : ℕ} (E : BinaryComplexityEnsemble n) :
    E.totalComplexity ≤ n * 2 ^ n := by
  exact le_trans ( Finset.sum_le_sum fun _ _ => E.complexity_le _ ) ( by simp +decide [ mul_comm ] )

/-- Aggregate thermodynamic cost of the whole proof ensemble. -/
def BinaryComplexityEnsemble.totalCost {n : ℕ} (E : BinaryComplexityEnsemble n)
    (T : ℝ) : ℝ := ∑ p, proofCost E.complexity T p

/-
Aggregate heat factors as aggregate complexity times the one-bit Landauer factor.
-/
theorem totalCost_factor {n : ℕ} (E : BinaryComplexityEnsemble n) (T : ℝ) :
    E.totalCost T = E.totalComplexity * (T * Real.log 2) := by
  unfold BinaryComplexityEnsemble.totalCost BinaryComplexityEnsemble.totalComplexity proofCost
  simp +decide [Finset.sum_mul]
  ac_rfl

/-
Two-sided finite-size thermodynamic bounds.  The lower and upper scales differ only by
constant factors and the harmless shift from `n` to `n-1`.
-/
theorem totalCost_bounds {n : ℕ} (hn : 1 ≤ n) (E : BinaryComplexityEnsemble n)
    {T : ℝ} (hT : 0 ≤ T) :
    ((n - 1) * 2 ^ (n - 1) : ℕ) * (T * Real.log 2) ≤ E.totalCost T ∧
      E.totalCost T ≤ (n * 2 ^ n : ℕ) * (T * Real.log 2) := by
  -- Rewrite E.totalCost T using totalCost_factor.
  rw [totalCost_factor] at *; norm_cast at *; (
  exact ⟨ mul_le_mul_of_nonneg_right ( mod_cast totalComplexity_lower hn E ) ( by positivity ), mul_le_mul_of_nonneg_right ( mod_cast totalComplexity_upper E ) ( by positivity ) ⟩);

/-
An unbounded complexity spectrum has unbounded thermodynamic cost at every fixed positive
temperature.  This is the precise unconditional core of the proposed Chaitin-style claim;
 domination of computable bounds needs an explicit proof system and computability predicate.
-/
theorem unbounded_cost_of_unbounded_complexity {P : Type*} (K : P → ℕ)
    (hK : ∀ b : ℕ, ∃ p, b < K p) {T : ℝ} (hT : 0 < T) :
    ∀ C : ℝ, ∃ p, C < proofCost K T p := by
  intro C
  obtain ⟨b, hb⟩ : ∃ b : ℕ, C < b * T * Real.log 2 := by
    obtain ⟨ b, hb ⟩ := exists_nat_gt ( C / ( T * Real.log 2 ) );
    exact ⟨ b, by rw [ div_lt_iff₀ ( mul_pos hT ( Real.log_pos one_lt_two ) ) ] at hb; linarith ⟩;
  obtain ⟨ p, hp ⟩ := hK b; exact ⟨ p, hb.trans_le <| mul_le_mul_of_nonneg_right ( mul_le_mul_of_nonneg_right ( Nat.cast_le.2 hp.le ) hT.le ) ( Real.log_nonneg one_le_two ) ⟩ ;

end ProofThermodynamics