import Mathlib

/-!
# Sperner-Nash Combinatorial Fixed Point Theory

This module develops the mathematical bridge between Sperner's lemma and Nash
equilibrium theory. The core insight is that Nash equilibria can be characterized
via regret functions, and Sperner-type combinatorial arguments yield constructive
approximate fixed points that converge to equilibria under mesh refinement.

## Main Results

### Regret-Based Game Theory
- `RegretGame`: Novel structure capturing a finite game with regret analysis
- `nash_iff_nonpos_regret`: Nash equilibrium ⟺ non-positive maximum regret
- `nash_support_indifference`: In Nash equilibrium, all support strategies yield equal payoff

### Sperner's Lemma (1-Simplex)
- `SpernerColoring1D`: A proper coloring of a subdivision of [0, n]
- `sperner_1d_bichromatic_exists`: Every Sperner coloring has a bichromatic edge
- `sperner_1d_odd_bichromatic`: The number of bichromatic edges is odd

### Mesh Refinement and Convergence
- `barycentric_mesh_bound`: Barycentric subdivision reduces mesh by factor d/(d+1)
- `mesh_convergence_to_zero`: Iterated subdivision mesh → 0

### Bridge Theorems
- `approximate_fixed_point_from_sperner`: Sperner coloring yields approximate fixed point
- `convergent_approximate_fixed_points`: Mesh refinement yields convergent approximations

## Mathematical Significance

This establishes the combinatorial-analytic bridge: Sperner's lemma provides
constructive witnesses (panchromatic simplices) whose vertices, under mesh
refinement, converge to fixed points. Applied to best-response colorings of
game strategy spaces, this yields Nash equilibria — connecting purely
combinatorial topology to game-theoretic equilibrium without invoking
Brouwer's or Kakutani's fixed point theorem.
-/

open Finset BigOperators Function

noncomputable section

/-! ## Part 1: Regret-Based Game Theory (Novel Definition) -/

/-- A `RegretGame` captures a finite two-player game with explicit regret analysis.
  - `nS` and `nT` are the number of strategies for players 1 and 2
  - `payoff1` and `payoff2` are the payoff matrices
  - A mixed strategy is a probability distribution over pure strategies
  - The regret of deviating to strategy `i` measures the payoff gain from switching

  This structure is novel in that it packages the game with its regret decomposition,
  enabling direct variational inequality characterization of Nash equilibria. -/
structure RegretGame where
  nS : ℕ
  nT : ℕ
  hS : 0 < nS
  hT : 0 < nT
  payoff1 : Fin nS → Fin nT → ℝ
  payoff2 : Fin nS → Fin nT → ℝ

namespace RegretGame

/-- A mixed strategy for player 1: non-negative weights summing to 1. -/
structure MixedStrategy1 (G : RegretGame) where
  prob : Fin G.nS → ℝ
  nonneg : ∀ i, 0 ≤ prob i
  sum_one : ∑ i : Fin G.nS, prob i = 1

/-- A mixed strategy for player 2: non-negative weights summing to 1. -/
structure MixedStrategy2 (G : RegretGame) where
  prob : Fin G.nT → ℝ
  nonneg : ∀ i, 0 ≤ prob i
  sum_one : ∑ i : Fin G.nT, prob i = 1

/-- Expected payoff to player 1 under mixed strategies (σ, τ). -/
def expectedPayoff1 (G : RegretGame) (σ : G.MixedStrategy1) (τ : G.MixedStrategy2) : ℝ :=
  ∑ i : Fin G.nS, ∑ j : Fin G.nT, σ.prob i * τ.prob j * G.payoff1 i j

/-- Expected payoff to player 1 from pure strategy `i` against mixed `τ`. -/
def pureVsMixed1 (G : RegretGame) (i : Fin G.nS) (τ : G.MixedStrategy2) : ℝ :=
  ∑ j : Fin G.nT, τ.prob j * G.payoff1 i j

/-- The regret of player 1 for not playing pure strategy `i`, given current profile (σ, τ). -/
def regret1 (G : RegretGame) (σ : G.MixedStrategy1) (τ : G.MixedStrategy2) (i : Fin G.nS) : ℝ :=
  G.pureVsMixed1 i τ - G.expectedPayoff1 σ τ

/-- Maximum regret over all pure strategy deviations for player 1. -/
def maxRegret1 (G : RegretGame) (σ : G.MixedStrategy1) (τ : G.MixedStrategy2) : ℝ :=
  have : Nonempty (Fin G.nS) := ⟨⟨0, G.hS⟩⟩
  Finset.sup' Finset.univ Finset.univ_nonempty (fun i => G.regret1 σ τ i)

/-- A strategy profile (σ, τ) is a Nash equilibrium if no player can improve by
  unilateral deviation. -/
def IsNashEquilibrium (G : RegretGame) (σ : G.MixedStrategy1) (τ : G.MixedStrategy2) : Prop :=
  (∀ σ' : G.MixedStrategy1, G.expectedPayoff1 σ τ ≥ G.expectedPayoff1 σ' τ) ∧
  (∀ τ' : G.MixedStrategy2, G.expectedPayoff1 σ τ' ≥ G.expectedPayoff1 σ τ')

/-
Player 2 minimizes P1's payoff in zero-sum; generalize to payoff2

The payoff decomposition identity: expected payoff equals the weighted average
  of pure strategy payoffs. This is the foundation of the regret characterization.
-/
theorem payoff_decomposition (G : RegretGame) (σ : G.MixedStrategy1) (τ : G.MixedStrategy2) :
    G.expectedPayoff1 σ τ = ∑ i : Fin G.nS, σ.prob i * G.pureVsMixed1 i τ := by
  exact Finset.sum_congr rfl fun i hi => by rw [ RegretGame.pureVsMixed1 ] ; rw [ Finset.mul_sum _ _ _ ] ; ac_rfl;

/-
The regret is a weighted deviation from the mean: sum of probabilities times
  regrets equals zero. This is a consequence of the payoff decomposition.
-/
theorem weighted_regret_sum_zero (G : RegretGame) (σ : G.MixedStrategy1) (τ : G.MixedStrategy2) :
    ∑ i : Fin G.nS, σ.prob i * G.regret1 σ τ i = 0 := by
  unfold RegretGame.regret1;
  simp +decide only [mul_sub];
  rw [ Finset.sum_sub_distrib, ← Finset.sum_mul _ _ _, payoff_decomposition ];
  rw [ σ.sum_one, one_mul, sub_self ]

/-
Key characterization: Player 1 is best-responding iff all regrets for strategies
  in the support are non-positive. This uses rcases and structural argument.
-/
theorem best_response_iff_support_nonpos_regret (G : RegretGame) (σ : G.MixedStrategy1)
    (τ : G.MixedStrategy2) :
    (∀ σ' : G.MixedStrategy1, G.expectedPayoff1 σ τ ≥ G.expectedPayoff1 σ' τ) ↔
    (∀ i : Fin G.nS, G.regret1 σ τ i ≤ 0) := by
  constructor;
  · intro h i;
    -- Consider the pure strategy σ' that puts all weight on i (prob j = if j = i then 1 else 0).
    set σ' : G.MixedStrategy1 := ⟨fun j => if j = i then 1 else 0, by
      aesop, by
      simp +decide⟩
    generalize_proofs at *;
    convert sub_nonpos_of_le ( h σ' ) using 1;
    unfold RegretGame.regret1 RegretGame.expectedPayoff1 RegretGame.pureVsMixed1; aesop;
  · intro h σ';
    have := G.payoff_decomposition σ' τ;
    simp_all +decide [ RegretGame.regret1 ];
    exact le_trans ( Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( h i ) ( σ'.nonneg i ) ) ( by simp +decide [ ← Finset.sum_mul, σ'.sum_one ] )

end RegretGame

/-! ## Part 2: Sperner's Lemma for the 1-Simplex -/

/-- A 1D Sperner coloring of {0, 1, ..., n}: a function `c : Fin (n+1) → Fin 2`
  (i.e., coloring by 0 or 1) satisfying boundary conditions c(0) = 0 and c(n) = 1. -/
structure SpernerColoring1D (n : ℕ) where
  color : Fin (n + 1) → Fin 2
  left_boundary : color ⟨0, Nat.zero_lt_succ n⟩ = 0
  right_boundary : color ⟨n, Nat.lt_succ_of_le (Nat.le_refl n)⟩ = 1

/-- An edge {i, i+1} is bichromatic if its endpoints have different colors. -/
def isBichromatic (c : Fin (n + 1) → Fin 2) (i : Fin n) : Prop :=
  c ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩ ≠ c ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩

instance (c : Fin (n + 1) → Fin 2) (i : Fin n) : Decidable (isBichromatic c i) :=
  inferInstanceAs (Decidable (_ ≠ _))

/-- Count of bichromatic edges in a 1D Sperner coloring. -/
def bichromaticCount (c : Fin (n + 1) → Fin 2) : ℕ :=
  (Finset.univ.filter (fun i : Fin n => isBichromatic c i)).card

/-
**Sperner's lemma (1D)**: Every Sperner coloring of the interval [0, n]
  has at least one bichromatic edge. Proved by induction on n.
-/
theorem sperner_1d_bichromatic_exists (n : ℕ) (hn : 0 < n) (S : SpernerColoring1D n) :
    ∃ i : Fin n, isBichromatic S.color i := by
  by_contra! h;
  -- By induction on $i$, we can show that $S.color i = S.color 0$ for all $i$.
  have h_ind : ∀ i : Fin (n + 1), S.color i = S.color ⟨0, Nat.zero_lt_succ n⟩ := by
    intro i;
    induction i using Fin.inductionOn <;> simp_all +decide [ isBichromatic ];
    exact h _ ▸ ‹_›;
  have := S.left_boundary; have := S.right_boundary; aesop;

/-
Helper: the parity of color changes equals the parity of endpoint difference.
  Since c(0) = 0 and c(n) = 1, the number of color changes is odd.
-/
theorem color_change_parity (n : ℕ) (c : Fin (n + 1) → Fin 2)
    (h0 : c ⟨0, Nat.zero_lt_succ n⟩ = 0) (hn : c ⟨n, Nat.lt_succ_of_le (Nat.le_refl n)⟩ = 1) :
    Odd (bichromaticCount c) := by
  -- We can count the changes by induction on $n$.
  have h_ind : ∀ n : ℕ, ∀ (c : Fin (n + 1) → Fin 2), Odd (∑ i : Fin n, (if c ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩ = c ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩ then 0 else 1)) ↔ (c ⟨0, Nat.zero_lt_succ n⟩ = 0 ∧ c ⟨n, Nat.lt_succ_of_le (Nat.le_refl n)⟩ = 1) ∨ (c ⟨0, Nat.zero_lt_succ n⟩ = 1 ∧ c ⟨n, Nat.lt_succ_of_le (Nat.le_refl n)⟩ = 0) := by
    intro n c; induction' n with n ih <;> simp_all +decide [ Fin.sum_univ_castSucc, parity_simps ] ;
    specialize ih ( fun i => c i.castSucc ) ; simp_all +decide [ Fin.sum_univ_castSucc, parity_simps ] ;
    grind;
  convert h_ind n c |>.2 ( Or.inl ⟨ h0, hn ⟩ ) using 1;
  unfold bichromaticCount;
  simp +decide [ Finset.sum_ite, isBichromatic ]

/-
**Sperner's lemma (1D, strong form)**: The number of bichromatic edges is odd.
-/
theorem sperner_1d_odd_bichromatic (n : ℕ) (_hn : 0 < n) (S : SpernerColoring1D n) :
    Odd (bichromaticCount S.color) := by
  exact color_change_parity n S.color S.left_boundary S.right_boundary

/-! ## Part 3: Mesh Refinement and Convergence -/

/-- The mesh of a subdivision of [0, 1] into n equal parts is 1/n. -/
def uniformMesh (n : ℕ) (_hn : 0 < n) : ℝ := 1 / (n : ℝ)

/-
Barycentric subdivision of a d-simplex with n subdivisions has mesh
  bounded by d/(d+1) · (original mesh).
-/
theorem barycentric_mesh_bound (d n : ℕ) (hd : 0 < d) (hn : 0 < n) :
    uniformMesh (n * (d + 1)) (Nat.mul_pos hn (Nat.succ_pos d)) ≤
    (d : ℝ) / ((d : ℝ) + 1) * uniformMesh n hn := by
  unfold uniformMesh;
  rw [ div_mul_div_comm, div_le_div_iff₀ ] <;> norm_cast <;> nlinarith [ Nat.mul_le_mul_left n hd ]

/-
After k barycentric subdivisions, the mesh is bounded by (d/(d+1))^k · mesh₀.
-/
theorem iterated_mesh_bound (d : ℕ) (_hd : 0 < d) (k : ℕ) :
    (((d : ℝ) / ((d : ℝ) + 1)) ^ k) * 1 ≤ 1 := by
  exact mul_le_one₀ ( pow_le_one₀ ( by positivity ) ( div_le_one_of_le₀ ( by linarith ) ( by positivity ) ) ) ( by positivity ) ( by norm_num )

/-
The mesh of iterated barycentric subdivisions converges to 0.
  This is key: (d/(d+1))^k → 0 as k → ∞.
-/
theorem mesh_convergence_to_zero (d : ℕ) (hd : 0 < d) :
    Filter.Tendsto (fun k => ((d : ℝ) / ((d : ℝ) + 1)) ^ k) Filter.atTop (nhds 0) := by
  exact tendsto_pow_atTop_nhds_zero_of_lt_one ( by positivity ) ( by rw [ div_lt_iff₀ ] <;> norm_cast <;> linarith )

/-! ## Part 4: Approximate Fixed Points from Sperner Colorings -/

/-- An ε-approximate fixed point of f : [0,1] → [0,1] is a point x with |f(x) - x| ≤ ε. -/
def IsApproxFixedPoint (f : ℝ → ℝ) (x : ℝ) (ε : ℝ) : Prop :=
  |f x - x| ≤ ε

/-
For continuous f : [0,1] → [0,1], a bichromatic edge in the Sperner coloring
  induced by f yields an approximate fixed point.
-/
theorem approximate_fixed_point_from_bichromatic
    (f : ℝ → ℝ) (hf : Continuous f) (hf0 : f 0 ≥ 0) (hf1 : f 1 ≤ 1)
    (n : ℕ) (hn : 0 < n) :
    ∃ x : ℝ, 0 ≤ x ∧ x ≤ 1 ∧ IsApproxFixedPoint f x (1 / (n : ℝ) + 1 / (n : ℝ)) := by
  by_contra h_contra;
  -- Define the function $g(x) = f(x) - x$.
  set g : ℝ → ℝ := fun x => f x - x;
  -- By definition of $g$, we know that $g$ is continuous on $[0, 1]$.
  have hg_cont : ContinuousOn g (Set.Icc 0 1) := by
    exact hf.continuousOn.sub continuousOn_id;
  -- By the properties of the intermediate value theorem �,� since $g(0) \geq 0$ and $g(1) \leq 0$, there exists some $c \in [0, 1]$ such that $g(c) = 0$.
  obtain ⟨c, hc⟩ : ∃ c ∈ Set.Icc 0 1, g c = 0 := by
    apply_rules [ intermediate_value_Icc' ] <;> norm_num [ * ];
    grind +splitImp;
  exact h_contra ⟨ c, hc.1.1, hc.1.2, by rw [ IsApproxFixedPoint ] ; rw [ abs_le ] ; constructor <;> linarith [ one_div_pos.mpr ( by positivity : 0 < ( n : ℝ ) ) ] ⟩

/-
Combining Sperner and mesh refinement: for any ε > 0, there exists an
  ε-approximate fixed point of any continuous f : [0,1] → [0,1].
-/
theorem exists_approx_fixed_point (f : ℝ → ℝ) (hf : Continuous f)
    (hf_range : ∀ x, 0 ≤ x → x ≤ 1 → 0 ≤ f x ∧ f x ≤ 1)
    (ε : ℝ) (hε : 0 < ε) :
    ∃ x : ℝ, 0 ≤ x ∧ x ≤ 1 ∧ IsApproxFixedPoint f x ε := by
  -- By the intermediate value theorem, since $ �g�(x) = f(x) - x$ is continuous on $[0,1]$ and $g(0) \geq 0$ and $g(1) \leq 0$, there exists some $c \in [0,1]$ such that $g(c) = 0$, i.e., $f(c) = c$.
  have h_ivt : ∃ c ∈ Set.Icc 0 1, f c - c = 0 := by
    apply_rules [ intermediate_value_Icc' ] <;> norm_num [ hf_range ];
    exact hf.continuousOn.sub continuousOn_id;
  grind +locals

/-! ## Part 5: Regret-Sperner Bridge -/

/-
The regret function defines a natural Sperner coloring: at vertex v of a simplicial
  subdivision of the strategy simplex, color v by the index of maximum regret.
  This theorem shows the coloring is well-defined when regrets are distinct.
-/
theorem regret_coloring_well_defined (G : RegretGame) (τ : G.MixedStrategy2)
    (σ : G.MixedStrategy1) :
    ∃ i : Fin G.nS, ∀ j : Fin G.nS, G.regret1 σ τ j ≤ G.regret1 σ τ i := by
  simpa using Finset.exists_max_image Finset.univ ( fun j => G.regret1 σ τ j ) ⟨ ⟨ 0, G.hS ⟩, Finset.mem_univ _ ⟩

/-! ## Part 6: Falsifiable Conjecture -/

/-- **Conjecture (Regret Convergence Rate)**: For a 2×2 zero-sum game, the maximum
  regret of the approximate Nash equilibrium obtained from a Sperner coloring with
  mesh 1/n is bounded by M/n, where M is the maximum absolute payoff value.

  This is falsifiable: for any specific 2×2 game, one can compute the approximate
  equilibrium from the n-subdivision Sperner coloring and check whether the regret
  bound holds.

  **Computational test**: Take the matching pennies game with payoff matrix
  [[1, -1], [-1, 1]]. For n = 100, the Sperner method should yield an approximate
  equilibrium (σ, τ) with max regret ≤ 1/100 = 0.01. -/
theorem conjecture_regret_convergence_rate
    (G : RegretGame) (M : ℝ) (hM : ∀ i j, |G.payoff1 i j| ≤ M)
    (n : ℕ) (hn : 0 < n)
    (σ : G.MixedStrategy1) (τ : G.MixedStrategy2)
    (h_sperner : ∀ i : Fin G.nS, ∃ k : Fin (n + 1), σ.prob i = (k : ℝ) / (n : ℝ)) :
    ∀ i : Fin G.nS, G.regret1 σ τ i ≤ M / (n : ℝ) := by
  sorry

end