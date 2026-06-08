import Mathlib
import Speculative.ProofCompression.Defs

/-!
# Proof Compression Phase Transitions: Main Theorems

This module proves the central theorems of the proof compression theory:

1. **Abstract gap theorem**: Linear human cost + exponential auto cost ⟹ unbounded gap
2. **Subset expansion gap**: The powerset expansion family has unbounded compression ratio
3. **Lemma basis collapse**: Adding an inductive lemma makes automation cost linear
4. **Threshold existence**: The subset expansion instance has a formal phase transition
5. **Phase prediction monotonicity**: The algorithmic predictor is well-behaved
6. **Cross-domain comparison**: Both powerset and telescoping families exhibit gaps

## Key mathematical insight

The exponential-vs-linear gap is not an artifact of poor automation — it is a
mathematical necessity. Any proof system that cannot introduce shared intermediate
results (lemmas) must re-derive common subexpressions, leading to tree-shaped
proof terms whose size grows exponentially in the DAG width of the conceptual proof.
-/

/-! ### Helper lemmas for exponential-vs-linear arithmetic -/

/-
For any base b > 1 and constants A, B, there exists n where b^n exceeds A*n + B.
This is the core arithmetic fact underlying the phase transition: exponential
functions eventually dominate any linear function.
-/
lemma exists_exp_gt_linear (b : ℕ) (hb : 1 < b) (A B : ℕ) :
    ∃ n, A * n + B < b ^ n := by
  induction' A with A ih generalizing B;
  · exact ⟨ _, by simpa using Nat.lt_pow_self hb ⟩;
  · -- By induction on $A$, we can show that there exists an $n$ such that $b^n > (A+1)n + B$.
    have h_ind : ∀ A B : ℕ, ∃ n, b ^ n > (A + 1) * n + B := by
      intro A B;
      induction' A with A ih generalizing B <;> simp_all +decide;
      · exact ⟨ B + 1, by induction' B with B ih <;> norm_num [ Nat.pow_succ' ] at * <;> nlinarith ⟩;
      · obtain ⟨ n, hn ⟩ := ih ( B + ( A + 1 ) );
        exact ⟨ n + 1, by rw [ pow_succ' ] ; nlinarith [ Nat.mul_le_mul_left n hb ] ⟩;
    exact h_ind A B

/-
Strengthened version: for any starting point n₀, we can find n ≥ n₀
where the exponential dominates.
-/
lemma exists_exp_gt_linear_ge (b : ℕ) (hb : 1 < b) (A B n0 : ℕ) :
    ∃ n, n0 ≤ n ∧ A * n + B < b ^ n := by
  -- We can use the fact that exponential functions grow faster than linear functions. Specifically, for any base $b > 1$, there exists an $n$ such that $b^n > A*n + B$.
  have h_exp_growth : ∀ b > 1, ∀ A B : ℕ, ∃ n, A*n + B < b^n := by
    exact fun b a A B => exists_exp_gt_linear b a A B;
  obtain ⟨ n, hn ⟩ := h_exp_growth b hb A ( B + A * n0 + n0 );
  exact ⟨ n + n0, by linarith, by nlinarith [ pow_le_pow_right₀ hb.le ( by linarith : n + n0 ≥ n ) ] ⟩

/-! ### Theorem 1: Abstract asymptotic gap -/

/-
**Main abstract theorem.** If human proof cost grows linearly and automation cost
grows at least exponentially, then the compression ratio is unbounded.

This turns the philosophical claim "lemma invention is necessary" into a
mathematically checkable criterion: verify linear structured proof growth and
exponential automation lower bound on a theorem family, and the phase
transition follows as a theorem.
-/
theorem gap_of_linear_vs_exponential
    (I : CompressionInstance)
    (T : ℕ → I.theorem_id)
    (h_human : ∃ C : ℕ, ∀ n, I.humanCost (T n) ≤ C * n + C)
    (h_auto : ∃ b : ℕ, 1 < b ∧ ∃ n0 : ℕ, ∀ n ≥ n0, b ^ n ≤ I.autoCost (T n)) :
    HasAsymptoticGap I T := by
  intro K
  obtain ⟨C, hC⟩ := h_human
  obtain ⟨b, hb, n0, hn0⟩ := h_auto
  have h_exp_gt_linear : ∃ n, n0 ≤ n ∧ (K * C) * n + (K * C) < b^n := by
    exact exists_exp_gt_linear_ge b hb ( K * C ) ( K * C ) n0;
  exact h_exp_gt_linear.imp fun n hn => by nlinarith [ hC n, hn0 n hn.1 ] ;

/-! ### Theorem 2: Subset expansion has unbounded gap -/

/-
The powerset expansion instance `∏ (1 + f_i) = ∑_{S ⊆ [n]} ∏_{i∈S} f_i`
exhibits unbounded compression ratio. For any constant K, there exists n where
the automation cost 2^n exceeds K times the human cost n+1.

This is the canonical example of the proof compression phase transition.
-/
theorem subsetExpansion_unbounded_gap :
    HasAsymptoticGap subsetExpansionInstance id := by
  convert gap_of_linear_vs_exponential subsetExpansionInstance id _ _ using 1;
  · exact ⟨ 1, fun n => by simp +arith +decide [ subsetExpansionInstance ] ⟩;
  · exact ⟨ 2, by decide, 0, fun n hn => by rfl ⟩

/-! ### Theorem 3: Lemma basis collapse -/

/-
After adding the inductive basis lemma, automation cost becomes linear.
This formalizes the key scientific thesis: intermediate lemma invention
changes the asymptotic proof complexity class.
-/
theorem augmented_basis_linear_cost :
    ∃ C : ℕ, ∀ n : ℕ, augmentedSubsetExpansion.autoCost n ≤ C * n + C := by
  exact ⟨ 1, fun n => by unfold augmentedSubsetExpansion; norm_num ⟩

/-
The augmented instance has **no** asymptotic gap. Adding a single reusable lemma
collapses the exponential blowup to a constant-factor relationship.
-/
theorem augmented_no_gap :
    ¬ HasAsymptoticGap augmentedSubsetExpansion id := by
  -- By definition of `HasAsymptoticGap`, we need to show that for any $K$, there exists an $n$ such that $K * (n + 1) < n + 1$.
  unfold HasAsymptoticGap;
  simp +zetaDelta at *;
  exact ⟨ 1, fun n => by simp +decide [ augmentedSubsetExpansion ] ⟩

/-! ### Theorem 4: Threshold existence -/

/-
The subset expansion instance has a formal phase transition at threshold c = 0.
Below this threshold, automation is within constant factor of human cost;
above it, no constant factor suffices.
-/
theorem subsetExpansion_has_threshold :
    HasThreshold subsetExpansionInstance 0 := by
  constructor;
  · exact ⟨ 1, fun t ht => by rcases t with ( _ | _ | t ) <;> trivial ⟩;
  · intro K;
    -- By definition of exponentiation, we know that for any $K$, there exists an $n$ such that $2^n > K(n + 1)$.
    obtain ⟨n, hn⟩ : ∃ n, 2 ^ n > K * (n + 1) := by
      exact exists_exp_gt_linear 2 ( by decide ) K K;
    exact ⟨ n + 1, by exact Nat.succ_pos _, by simpa [ subsetExpansionInstance ] using by nlinarith [ pow_succ' 2 n ] ⟩

/-! ### Theorem 5: Phase prediction monotonicity -/

/-
The phase predictor is monotone: higher complexity scores yield
phases with higher or equal index. This validates the algorithmic
component of the theory.
-/
theorem predictedPhase_monotone (threshold : ℕ) (a b : ℕ) (h : a ≤ b) :
    (predictedPhase threshold a).index ≤ (predictedPhase threshold b).index := by
  unfold predictedPhase;
  split_ifs <;> simp_all +arith +decide;
  · grind;
  · linarith;
  · grind

/-! ### Theorem 6: Cross-domain — telescoping identities also exhibit a gap -/

/-
The telescoping identity family also has unbounded compression ratio,
demonstrating that the phase transition is not specific to combinatorics.
The family `(x-1) · ∑ x^i = x^n - 1` has quadratic automation cost
(modeling naive polynomial multiplication expansion) but linear human cost.
-/
theorem telescoping_unbounded_gap :
    HasAsymptoticGap telescopingInstance id := by
  intro K; use K + 2; norm_num [ telescopingInstance ] ; ring_nf ;
  exact show K * ( 2 + K + 1 ) < ( 2 + K ) * ( 2 + K ) + 1 from by nlinarith;

/-! ### Theorem 7: Augmented telescoping also collapses -/

/-
After adding the telescoping lemma as a basis, the cost becomes linear,
paralleling the subset expansion collapse.
-/
theorem augmented_telescoping_no_gap :
    ¬ HasAsymptoticGap augmentedTelescopingInstance id := by
  intro h
  unfold HasAsymptoticGap at h
  simp at h;
  exact absurd ( h 1 ) ( by rintro ⟨ n, hn ⟩ ; exact not_lt_of_ge ( by simp +decide [ augmentedTelescopingInstance ] ) hn )

/-! ### Connecting to Mathlib: the powerset expansion identity -/

/-- The algebraic identity underlying the subset expansion family.
This is `Finset.prod_one_add` from Mathlib, restated for clarity:
`∏ x ∈ s, (1 + f x) = ∑ t ∈ s.powerset, ∏ x ∈ t, f x` -/
theorem prod_one_add_eq_sum_powerset
    {α R : Type*} [DecidableEq α] [CommSemiring R]
    (s : Finset α) (f : α → R) :
    ∏ x ∈ s, (1 + f x) = ∑ t ∈ s.powerset, ∏ x ∈ t, f x :=
  Finset.prod_one_add s

/-- The number of terms in the powerset expansion equals 2^|s|.
This establishes the exact branching count underlying the exponential cost model. -/
theorem powerset_card_eq_two_pow {α : Type*} [DecidableEq α] (s : Finset α) :
    s.powerset.card = 2 ^ s.card :=
  Finset.card_powerset s

/-- The automation cost in the subset expansion instance equals 2 raised to the
semantic complexity, connecting the abstract cost model to the concrete
combinatorial branching factor. -/
theorem autoCost_eq_pow_complexity (n : ℕ) :
    subsetExpansionInstance.autoCost n =
    2 ^ subsetExpansionInstance.semanticComplexity n := rfl

/-- The compression ratio of the subset expansion instance at n equals 2^n / (n+1).
This demonstrates the exponential growth of the ratio. -/
theorem subset_compressionRatio_eq (n : ℕ) :
    compressionRatio subsetExpansionInstance n = (2 ^ n : ℚ) / max 1 ((n + 1 : ℕ) : ℚ) := by
  simp [compressionRatio, subsetExpansionInstance]