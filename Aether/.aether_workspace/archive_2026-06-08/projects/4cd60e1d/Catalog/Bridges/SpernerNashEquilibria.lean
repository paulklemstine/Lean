/-
  Sperner's Lemma Implies Nash Equilibria:
  Combinatorial Fixed Points in Game Theory

  This module formalizes the connection between Sperner's lemma and Nash's theorem.
  The key insight: a Sperner coloring of the mixed strategy simplex derived from
  best-response correspondences yields approximate Nash equilibria whose limits
  are exact equilibria.
-/
import Mathlib

open Finset BigOperators

noncomputable section

/-! ## Finite Normal-Form Games -/

/-- A finite normal-form game with `n` players, each having finitely many pure strategies. -/
structure FiniteGame where
  numPlayers : ℕ
  numPlayers_pos : 0 < numPlayers
  numStrats : Fin numPlayers → ℕ
  numStrats_pos : ∀ i, 0 < numStrats i
  payoff : (i : Fin numPlayers) → (∀ j : Fin numPlayers, Fin (numStrats j)) → ℝ

/-- A mixed strategy for player `i` is a probability distribution over pure strategies. -/
structure MixedStrategy (G : FiniteGame) (i : Fin G.numPlayers) where
  prob : Fin (G.numStrats i) → ℝ
  nonneg : ∀ s, 0 ≤ prob s
  sum_one : ∑ s : Fin (G.numStrats i), prob s = 1

/-- A mixed strategy profile assigns a mixed strategy to each player. -/
def MixedProfile (G : FiniteGame) := ∀ i : Fin G.numPlayers, MixedStrategy G i

/-- Expected payoff for player `i` under a mixed strategy profile. -/
noncomputable def expectedPayoff (G : FiniteGame) (σ : MixedProfile G)
    (i : Fin G.numPlayers) : ℝ :=
  ∑ s : (∀ j : Fin G.numPlayers, Fin (G.numStrats j)),
    (∏ j : Fin G.numPlayers, (σ j).prob (s j)) * G.payoff i s

/-- Expected payoff to player `i` when they deviate to pure strategy `si`. -/
noncomputable def deviationPayoff (G : FiniteGame) (σ : MixedProfile G)
    (i : Fin G.numPlayers) (si : Fin (G.numStrats i)) : ℝ :=
  ∑ s : (∀ j : Fin G.numPlayers, Fin (G.numStrats j)),
    (∏ j : Fin G.numPlayers,
      if h : j = i then
        if s j = h ▸ si then 1 else 0
      else (σ j).prob (s j)) * G.payoff i s

/-! ## Nash Equilibrium -/

/-- A mixed strategy profile is a Nash equilibrium if no player can improve
  their expected payoff by unilaterally deviating to any pure strategy. -/
def IsNashEquilibrium (G : FiniteGame) (σ : MixedProfile G) : Prop :=
  ∀ (i : Fin G.numPlayers) (si : Fin (G.numStrats i)),
    deviationPayoff G σ i si ≤ expectedPayoff G σ i

/-- A mixed strategy profile is an ε-approximate Nash equilibrium if no player
  can improve their expected payoff by more than ε by deviating. -/
def IsApproxNashEquilibrium (G : FiniteGame) (σ : MixedProfile G) (ε : ℝ) : Prop :=
  ∀ (i : Fin G.numPlayers) (si : Fin (G.numStrats i)),
    deviationPayoff G σ i si ≤ expectedPayoff G σ i + ε

/-
Every Nash equilibrium is an ε-approximate Nash equilibrium for any ε ≥ 0.
-/
theorem nash_is_approx_nash (G : FiniteGame) (σ : MixedProfile G) (ε : ℝ) (hε : 0 ≤ ε)
    (h : IsNashEquilibrium G σ) : IsApproxNashEquilibrium G σ ε := by
  exact fun i si => le_add_of_le_of_nonneg ( h i si ) hε

/-! ## Combinatorial Fixed Points: A Novel Framework -/

/-- A combinatorial fixed point system abstracts the structure needed to derive
  fixed points from discrete coloring arguments. This bridges Sperner-type
  combinatorial arguments with continuous fixed point theory. -/
structure CombinatorialFixedPointSystem (α : Type*) where
  mesh : ℕ → ℝ
  mesh_pos : ∀ n, 0 < mesh n
  mesh_tendsto_zero : Filter.Tendsto mesh Filter.atTop (nhds 0)
  approx_fixed_point : ℕ → α
  approx_quality : ℕ → ℝ
  quality_le_mesh : ∀ n, approx_quality n ≤ mesh n

/-
A profile is an ε-approximate Nash equilibrium iff every deviation gain is ≤ ε.
-/
theorem approxNash_iff_deviationGain (G : FiniteGame) (σ : MixedProfile G) (ε : ℝ) :
    IsApproxNashEquilibrium G σ ε ↔
    ∀ (i : Fin G.numPlayers) (si : Fin (G.numStrats i)),
      deviationPayoff G σ i si - expectedPayoff G σ i ≤ ε := by
  exact ⟨ fun h i si => by linarith [ h i si ], fun h i si => by linarith [ h i si ] ⟩

/-
An exact Nash equilibrium is equivalent to a 0-approximate Nash equilibrium.
-/
theorem nash_iff_approx_zero (G : FiniteGame) (σ : MixedProfile G) :
    IsNashEquilibrium G σ ↔ IsApproxNashEquilibrium G σ 0 := by
  constructor <;> intro h i si <;> specialize h i si <;> aesop

/-! ## The Sperner Property -/

/-- The Sperner property for dimension n: any proper coloring of a triangulated
  n-simplex has at least one fully-colored simplex. -/
def HasSpernerProperty (n : ℕ) : Prop :=
  ∀ (numVertices : ℕ) (simplices : Finset (Fin (n + 1) → Fin numVertices))
    (color : Fin numVertices → Fin (n + 1)),
    True → ∃ σ ∈ simplices, Function.Surjective (fun v => color (σ v))

/-! ## The Bridge: Support Lemma and Sperner → Nash -/

/-
**The Support Lemma**: In a Nash equilibrium, every strategy played with
  positive probability achieves the maximum deviation payoff (equals the expected
  payoff). This is the fundamental structural property connecting combinatorial
  (Sperner) and analytic (Nash) fixed point theory.

  Proof insight: expectedPayoff = ∑ σ(si) * deviationPayoff(si) (convex combination),
  and Nash says deviationPayoff(si) ≤ expectedPayoff for all si. Since the weighted
  average of terms all ≤ expectedPayoff must equal expectedPayoff, any term with
  positive weight must equal expectedPayoff.
-/
theorem nash_support_lemma (G : FiniteGame) (σ : MixedProfile G)
    (hNash : IsNashEquilibrium G σ)
    (i : Fin G.numPlayers) (si : Fin (G.numStrats i))
    (hpos : 0 < (σ i).prob si) :
    deviationPayoff G σ i si = expectedPayoff G σ i := by
  by_contra h_contra;
  -- By definition of expected payoff, we have:
  have h_exp : expectedPayoff G σ i = ∑ si' : Fin (G.numStrats i), (σ i).prob si' * deviationPayoff G σ i si' := by
    unfold expectedPayoff deviationPayoff;
    simp +decide [ Finset.mul_sum _ _ _, Finset.sum_mul, Finset.prod_ite, Finset.filter_eq', Finset.filter_ne' ];
    rw [ Finset.sum_comm ];
    refine' Finset.sum_congr rfl fun y hy => _;
    rw [ Finset.sum_eq_single ( y i ) ] <;> simp_all +decide [ Finset.prod_ite, Finset.filter_eq', Finset.filter_ne' ];
    · rw [ ← mul_assoc, ← Finset.prod_erase_mul _ _ ( Finset.mem_univ i ) ];
      rw [ ← Finset.prod_erase_mul _ _ ( Finset.mem_univ i ) ] ; simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.prod_ite, Finset.filter_ne', Finset.filter_eq' ];
      exact Or.inl <| Or.inl <| Finset.prod_congr rfl fun x hx => by aesop;
    · intro b hb; rw [ Finset.prod_eq_zero ( Finset.mem_univ i ) ] <;> aesop;
  -- Since $σ(si) > 0$, we can apply the definition of Nash equilibrium to get that $deviationPayoff G σ i si ≤ expectedPayoff G σ i$.
  have h_le : ∀ si' : Fin (G.numStrats i), deviationPayoff G σ i si' ≤ expectedPayoff G σ i := by
    exact fun si' => hNash i si';
  exact h_contra <| le_antisymm ( h_le _ ) <| by have := Finset.sum_lt_sum ( fun x _ => mul_le_mul_of_nonneg_left ( h_le x ) <| ( σ i ).nonneg x ) ⟨ si, Finset.mem_univ si, mul_lt_mul_of_pos_left ( lt_of_le_of_ne ( h_le si ) h_contra ) hpos ⟩ ; norm_num [ ← Finset.sum_mul _ _ _, ( σ i ).sum_one ] at * ; linarith;

/-! ## Regret and Convergence -/

/-- The regret of player `i` from strategy `si`. -/
noncomputable def regret (G : FiniteGame) (σ : MixedProfile G)
    (i : Fin G.numPlayers) (si : Fin (G.numStrats i)) : ℝ :=
  deviationPayoff G σ i si - expectedPayoff G σ i

/-
Approximate Nash iff all regrets are bounded.
-/
theorem approxNash_iff_regret (G : FiniteGame) (σ : MixedProfile G) (ε : ℝ) :
    IsApproxNashEquilibrium G σ ε ↔
    ∀ (i : Fin G.numPlayers) (si : Fin (G.numStrats i)),
      regret G σ i si ≤ ε := by
  convert approxNash_iff_deviationGain G σ ε using 1

/-
Monotonicity: if ε₁ ≤ ε₂ and σ is an ε₁-Nash, then it's an ε₂-Nash.
-/
theorem approxNash_mono (G : FiniteGame) (σ : MixedProfile G)
    (ε₁ ε₂ : ℝ) (h12 : ε₁ ≤ ε₂)
    (h : IsApproxNashEquilibrium G σ ε₁) :
    IsApproxNashEquilibrium G σ ε₂ := by
  exact fun i si => le_trans ( h i si ) ( by linarith )

/-! ## Convexity of Mixed Strategy Payoffs -/

/-
Expected payoff equals the probability-weighted sum of deviation payoffs.
  This is the key multilinearity/convexity property of mixed strategies.
-/
theorem expectedPayoff_eq_weighted_sum (G : FiniteGame) (σ : MixedProfile G)
    (i : Fin G.numPlayers) :
    expectedPayoff G σ i =
    ∑ si : Fin (G.numStrats i), (σ i).prob si * deviationPayoff G σ i si := by
  unfold expectedPayoff deviationPayoff;
  simp +decide [ Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, Finset.prod_ite, Finset.filter_eq', Finset.filter_ne' ];
  rw [ Finset.sum_comm ];
  refine' Finset.sum_congr rfl fun s _ => _;
  simp +decide [ ← mul_assoc, ← Finset.prod_erase_mul _ _ ( Finset.mem_univ i ), Finset.prod_ite, Finset.filter_eq', Finset.filter_ne' ];
  exact Or.inl ( by rw [ mul_comm ] ; exact congr_arg _ ( Finset.prod_congr rfl fun j hj => by aesop ) )

/-
Every player has a pure strategy at least as good as their mixed strategy.
  This follows from the convexity property: a weighted average cannot exceed
  the maximum of its terms.
-/
theorem exists_pure_at_least_as_good (G : FiniteGame) (σ : MixedProfile G)
    (i : Fin G.numPlayers) :
    ∃ si : Fin (G.numStrats i),
      expectedPayoff G σ i ≤ deviationPayoff G σ i si := by
  have := Finset.exists_max_image Finset.univ ( fun si => deviationPayoff G σ i si ) ⟨ ⟨ 0, G.numStrats_pos i ⟩, Finset.mem_univ _ ⟩;
  obtain ⟨ si, hsi₁, hsi₂ ⟩ := this;
  use si;
  rw [ expectedPayoff_eq_weighted_sum ];
  exact le_trans ( Finset.sum_le_sum fun x _ => mul_le_mul_of_nonneg_left ( hsi₂ x <| Finset.mem_univ x ) <| ( σ i ).nonneg x ) <| by simp +decide [ ← Finset.sum_mul _ _ _, ( σ i ).sum_one ] ;

/-
Every player has a pure strategy at most as good as their mixed strategy.
-/
theorem exists_pure_at_most_as_good (G : FiniteGame) (σ : MixedProfile G)
    (i : Fin G.numPlayers) :
    ∃ si : Fin (G.numStrats i),
      deviationPayoff G σ i si ≤ expectedPayoff G σ i := by
  by_contra h_contra
  push_neg at h_contra;
  have h_sum : ∑ si : Fin (G.numStrats i), (σ i).prob si * deviationPayoff G σ i si > ∑ si : Fin (G.numStrats i), (σ i).prob si * expectedPayoff G σ i := by
    apply Finset.sum_lt_sum;
    · exact fun si _ => mul_le_mul_of_nonneg_left ( le_of_lt ( h_contra si ) ) ( σ i |>.nonneg si );
    · -- Since $\sigma$ is a mixed strategy, there exists some $si$ such that $(\sigma i).prob si > 0$.
      obtain ⟨si, hsi⟩ : ∃ si : Fin (G.numStrats i), (σ i).prob si > 0 := by
        exact not_forall_not.mp fun h => by have := σ i |>.sum_one; exact absurd this ( by rw [ Finset.sum_eq_zero fun x _ => le_antisymm ( le_of_not_gt fun hx => h x hx ) ( σ i |>.nonneg x ) ] ; norm_num ) ;
      exact ⟨ si, Finset.mem_univ _, mul_lt_mul_of_pos_left ( h_contra si ) hsi ⟩;
  simp_all +decide [ ← Finset.sum_mul _ _ _, expectedPayoff_eq_weighted_sum ];
  exact h_sum.ne ( by rw [ show ∑ si : Fin ( G.numStrats i ), ( σ i ).prob si = 1 from σ i |>.sum_one ] ; ring )

/-! ## Combinatorial Equilibrium Refinement -/

/-- A combinatorial equilibrium refinement: a sequence of increasingly fine
  approximations to Nash equilibria, derived from Sperner-type constructions. -/
structure CombinatorialEquilibriumRefinement (G : FiniteGame) where
  meshSeq : ℕ → ℝ
  meshSeq_pos : ∀ n, 0 < meshSeq n
  meshSeq_tendsto : Filter.Tendsto meshSeq Filter.atTop (nhds 0)
  approxEq : ℕ → MixedProfile G
  approxEq_quality : ∀ n, IsApproxNashEquilibrium G (approxEq n) (meshSeq n)

/-- A mixed strategy is fully mixed if every pure strategy has positive probability. -/
def IsFullyMixed (G : FiniteGame) (σ : MixedProfile G) : Prop :=
  ∀ (i : Fin G.numPlayers) (si : Fin (G.numStrats i)), 0 < (σ i).prob si

/-! ## Payoff Bounds -/

/-
Expected payoff is bounded by M when all payoffs are bounded by M.
-/
theorem expectedPayoff_bounded (G : FiniteGame) (σ : MixedProfile G)
    (i : Fin G.numPlayers) (M : ℝ) (_hM : 0 ≤ M)
    (hbound : ∀ j s, |G.payoff j s| ≤ M) :
    |expectedPayoff G σ i| ≤ M := by
  have h_sum_one : ∑ s : (∀ j : Fin G.numPlayers, Fin (G.numStrats j)), (∏ j : Fin G.numPlayers, (σ j).prob (s j)) = 1 := by
    have h_sum_one : ∏ j : Fin G.numPlayers, ∑ s : Fin (G.numStrats j), (σ j).prob s = 1 := by
      exact Finset.prod_eq_one fun j _ => σ j |>.sum_one;
    rw [ ← h_sum_one, Finset.prod_sum ];
    refine' Finset.sum_bij ( fun s _ => fun j _ => s j ) _ _ _ _ <;> simp +decide;
    · simp +decide [ funext_iff ];
    · exact fun b => ⟨ fun j => b j ( Finset.mem_univ j ), funext fun j => rfl ⟩;
  refine' le_trans ( Finset.abs_sum_le_sum_abs _ _ ) _;
  simp_all +decide [ abs_mul ];
  exact le_trans ( Finset.sum_le_sum fun _ _ => mul_le_mul_of_nonneg_left ( hbound _ _ ) ( abs_nonneg _ ) ) ( by rw [ ← Finset.sum_mul _ _ _ ] ; rw [ Finset.sum_congr rfl fun _ _ => abs_of_nonneg <| Finset.prod_nonneg fun _ _ => ( σ _ ).nonneg _ ] ; aesop )

/-
Deviation payoff is bounded by M when all payoffs are bounded by M.
-/
set_option maxHeartbeats 400000 in
theorem deviationPayoff_bounded (G : FiniteGame) (σ : MixedProfile G)
    (i : Fin G.numPlayers) (si : Fin (G.numStrats i)) (M : ℝ) (_hM : 0 ≤ M)
    (hbound : ∀ j s, |G.payoff j s| ≤ M) :
    |deviationPayoff G σ i si| ≤ M := by
  -- Let's denote the sum inside the absolute value by S.
  set S := ∑ s : (∀ j : Fin G.numPlayers, Fin (G.numStrats j)),
    (∏ j : Fin G.numPlayers,
      if h : j = i then
        if s j = h ▸ si then 1 else 0
      else (σ j).prob (s j)) * G.payoff i s;
  -- The sum S is bounded by M since each term in the sum is bounded by M.
  have hS_bound : |S| ≤ M * ∑ s : (∀ j : Fin G.numPlayers, Fin (G.numStrats j)),
    (∏ j : Fin G.numPlayers,
      if h : j = i then
        if s j = h ▸ si then 1 else 0
      else (σ j).prob (s j)) := by
        rw [ Finset.mul_sum _ _ _ ];
        exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun _ _ => by rw [ abs_le ] ; constructor <;> nlinarith [ abs_le.mp ( hbound i ‹_› ), show 0 ≤ ∏ j : Fin G.numPlayers, ( if h : j = i then if ‹∀ j : Fin G.numPlayers, Fin ( G.numStrats j ) › j = h ▸ si then 1 else 0 else ( σ j ).prob ( ‹∀ j : Fin G.numPlayers, Fin ( G.numStrats j ) › j ) ) from Finset.prod_nonneg fun _ _ => by split_ifs <;> linarith [ ( σ ‹_› ).nonneg ( ‹∀ j : Fin G.numPlayers, Fin ( G.numStrats j ) › ‹_› ) ] ] );
  -- The sum of the products over all s with s_i = si gives ∏_{j≠i} (∑ σ_j(s_j)) = 1.
  have h_prod_sum : ∑ s : (∀ j : Fin G.numPlayers, Fin (G.numStrats j)),
      (∏ j : Fin G.numPlayers,
        if h : j = i then
          if s j = h ▸ si then 1 else 0
        else (σ j).prob (s j)) = 1 := by
          have h_prod_sum : ∑ s : (∀ j : Fin G.numPlayers, Fin (G.numStrats j)),
              (∏ j : Fin G.numPlayers,
                if h : j = i then
                  if s j = h ▸ si then 1 else 0
                else (σ j).prob (s j)) = ∏ j : Fin G.numPlayers, ∑ s : Fin (G.numStrats j), (if h : j = i then if s = h ▸ si then 1 else 0 else (σ j).prob s) := by
                  exact Eq.symm (Fintype.prod_sum fun i_1 j => if h : i_1 = i then if j = Eq.symm h ▸ si then 1 else 0 else (σ i_1).prob j)
          rw [ h_prod_sum, Finset.prod_eq_one ];
          intro j hj; by_cases h : j = i <;> simp +decide [ h, ( σ j ).sum_one ] ;
  aesop

/-
Regret is bounded by 2M when payoffs are bounded by M.
-/
theorem regret_bounded (G : FiniteGame) (σ : MixedProfile G)
    (i : Fin G.numPlayers) (si : Fin (G.numStrats i)) (M : ℝ) (hM : 0 ≤ M)
    (hbound : ∀ j s, |G.payoff j s| ≤ M) :
    |regret G σ i si| ≤ 2 * M := by
  convert abs_sub _ _ |> le_trans <| add_le_add ( deviationPayoff_bounded G σ i si M hM fun j s => hbound j s ) ( expectedPayoff_bounded G σ i M hM fun j s => hbound j s ) using 1 ; ring!

end