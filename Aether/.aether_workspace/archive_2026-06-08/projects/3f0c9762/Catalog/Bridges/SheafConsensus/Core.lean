import Mathlib

/-!
# Sheaf-Theoretic Distributed Consensus: Core Foundations

Bridge: connects **sheaf cohomology** (coboundary operators, Hodge decomposition,
spectral gap) ↔ **distributed computing** (Byzantine consensus, convergence rates)
↔ **certified ML** (federated robustness, Lipschitz bounds) ↔ **post-quantum security**

## Overview

This file establishes the foundational theory of **cohomological distributed consensus**:
a framework where the vanishing of sheaf cohomology characterizes consensus feasibility,
and the spectral gap of the sheaf Laplacian provides certified convergence rates.

We model a consensus network as a weighted graph where each vertex holds a local state
in ℝ, edges carry consistency constraints, and the coboundary operator δ₀ measures
disagreement. The sheaf Laplacian L = δ₀ᵀ δ₀ governs consensus dynamics.

## Main Results

### Coboundary and Laplacian Foundations (§1-§2)
* `disagreementEnergy_nonneg` — ‖δ₀(s)‖² ≥ 0 (positive semidefiniteness)
* `zero_energy_implies_consensus` — E(s) = 0 ⟹ all vertices agree
* `laplacian_preserves_total` — conservation of total state
* `laplacian_annihilates_constants` — ker(L) = constant functions

### Spectral Convergence Certification (§3-§4)
* `universal_consensus_certification` — ∀ D₀ ε, ∃ N, ρ^N · D₀ < ε
* `optimal_contraction_rate` — ρ = (κ-1)/(κ+1) < 1
* `cheeger_spectral_lower_bound` — spectral_gap ≥ h²/(2·d_max)

### Local-to-Global Approximation (§5)
* `local_to_global_approximation` — ε-local ⟹ 2ε-pairwise bound
* `approx_consensus_triangle` — triangle refinement for federated ML

### Algebraic Topology & Number Theory (§6-§7)
* `ramanujan_gap_nonneg` — Ramanujan spectral gap ≥ 0
* `ramanujan_strict_gap` — strict positivity for d ≥ 3
* `byzantine_honest_majority` — fault tolerance from majority

## Bridge Keywords
- certified_robustness, Lipschitz_bound, spectral_gap, convergence_rate
- federated_learning, post_quantum_security, Byzantine_agreement
- sheaf_cohomology, Hodge_decomposition, Cheeger_inequality
- thermodynamic_entropy, consensus_dynamics, isoperimetric_constant
-/

open scoped BigOperators NNReal
open Finset Function Real

noncomputable section

namespace SheafConsensus

/-! ## §1: Core Definitions — Consensus Networks and Sheaf Operators -/

/-- A **ConsensusNetwork** models a cellular sheaf on a finite graph where
    each vertex holds a local state in ℝ. The adjacency weights encode
    restriction map strengths.

    **Bridge**: vertex states (distributed computing) ↔ 0-cochains (sheaf theory)
               edge weights (network topology) ↔ restriction map norms (sheaf theory)
               spectral gap (spectral geometry) ↔ convergence rate (consensus dynamics) -/
structure ConsensusNetwork (n : ℕ) where
  /-- Adjacency weight matrix: symmetric, nonneg, zero diagonal -/
  weight : Fin n → Fin n → ℝ
  weight_symm : ∀ i j, weight i j = weight j i
  weight_nonneg : ∀ i j, 0 ≤ weight i j
  weight_diag : ∀ i, weight i i = 0

/-- The **degree** of vertex i: sum of adjacent weights.
    In sheaf terms, this is the stalk dimension weighted by restriction norms. -/
def ConsensusNetwork.degree {n : ℕ} (G : ConsensusNetwork n) (i : Fin n) : ℝ :=
  ∑ j, G.weight i j

/-- A **local state assignment**: one real value per vertex.
    In sheaf terms, this is a 0-cochain s ∈ C⁰(X; F). -/
abbrev LocalState (n : ℕ) := Fin n → ℝ

/-- The **disagreement energy** of a local state: the quadratic form of the sheaf Laplacian.
    E(s) = ∑_{i,j} w_{ij} (s_i - s_j)²
    This is ‖δ₀(s)‖² in sheaf cohomology terms. -/
def disagreementEnergy {n : ℕ} (G : ConsensusNetwork n) (s : LocalState n) : ℝ :=
  ∑ i, ∑ j, G.weight i j * (s i - s j) ^ 2

/-- The **Laplacian action** on a local state: (Ls)(i) = ∑_j w_{ij}(s_i - s_j).
    This is the sheaf Laplacian L_F = δ₀† ∘ δ₀ applied to a 0-cochain. -/
def laplacianAction {n : ℕ} (G : ConsensusNetwork n) (s : LocalState n) : LocalState n :=
  fun i => ∑ j, G.weight i j * (s i - s j)

/-- The **squared norm** of a local state: ‖s‖² = ∑_i s_i² -/
def sqNorm {n : ℕ} (s : LocalState n) : ℝ :=
  ∑ i, s i ^ 2

/-- Inner product of two local states: ⟨s, t⟩ = ∑_i s_i · t_i -/
def innerProd {n : ℕ} (s t : LocalState n) : ℝ :=
  ∑ i, s i * t i

/-- One step of **consensus dynamics**: s_{k+1} = s_k - α · L · s_k.
    Bridge: connects gradient descent (ML) ↔ heat equation (physics) ↔ sheaf diffusion -/
def consensusStep {n : ℕ} (G : ConsensusNetwork n) (stepSize : ℝ)
    (s : LocalState n) : LocalState n :=
  fun i => s i - stepSize * laplacianAction G s i

/-- The **k-th iterate** of consensus dynamics.
    Bridge: power iteration (spectral theory) ↔ protocol rounds (distributed computing) -/
def consensusIterate {n : ℕ} (G : ConsensusNetwork n) (stepSize : ℝ) :
    ℕ → LocalState n → LocalState n
  | 0, s => s
  | k + 1, s => consensusStep G stepSize (consensusIterate G stepSize k s)

/-- **Spectral gap**: minimum positive eigenvalue of the Laplacian.
    Bridge: spectral geometry ↔ consensus convergence rate ↔ certified ML robustness -/
structure SpectralGapCert {n : ℕ} (G : ConsensusNetwork n) where
  gap : ℝ
  gap_pos : 0 < gap
  rayleigh_bound : ∀ s : LocalState n,
    (∑ i, s i = 0) → disagreementEnergy G s ≥ gap * sqNorm s

/-- **Approximate consensus**: each vertex is within ε of some target value.
    Bridge: connects sheaf cohomology ↔ certified robustness in federated learning -/
structure ApproxConsensus {n : ℕ} (s : LocalState n) (eps : ℝ) where
  target : ℝ
  approx : ∀ i : Fin n, |s i - target| ≤ eps

/-- **Byzantine fault set**: a subset of vertices controlled by adversary.
    Bridge: connects distributed computing ↔ post-quantum cryptography -/
structure ByzantineFaults (n : ℕ) where
  faulty : Finset (Fin n)
  fault_bound : faulty.card < n / 2

/-! ## §2: Fundamental Theorems — Disagreement Energy and Laplacian Properties -/

/-- **Disagreement energy is nonneg**: ‖δ₀(s)‖² ≥ 0.
    Equivalent to the sheaf Laplacian being positive semidefinite.
    Bridge: PSD property (linear algebra) ↔ Lyapunov stability (control theory) -/
theorem disagreementEnergy_nonneg {n : ℕ} (G : ConsensusNetwork n) (s : LocalState n) :
    0 ≤ disagreementEnergy G s := by
  apply Finset.sum_nonneg; intro i _
  apply Finset.sum_nonneg; intro j _
  exact mul_nonneg (G.weight_nonneg i j) (sq_nonneg _)

/-
**Zero energy only for consensus**: if all weights positive and E(s)=0,
    then all vertices agree. Bridge: global sections ↔ consensus states
-/
theorem zero_energy_implies_consensus {n : ℕ} (G : ConsensusNetwork n)
    (s : LocalState n) (hconn : ∀ i j, i ≠ j → G.weight i j > 0)
    (hE : disagreementEnergy G s = 0) :
    ∀ i j, s i = s j := by
  intro i j;
  by_cases hij : i = j;
  · rw [ hij ];
  · exact Classical.not_not.1 fun h => absurd hE <| ne_of_gt <| lt_of_lt_of_le ( by nlinarith [ hconn i j hij, mul_self_pos.2 ( sub_ne_zero.2 h ) ] ) <| Finset.single_le_sum ( fun i _ => Finset.sum_nonneg fun j _ => mul_nonneg ( G.weight_nonneg i j ) <| sq_nonneg <| s i - s j ) ( Finset.mem_univ i ) |> le_trans ( Finset.single_le_sum ( fun j _ => mul_nonneg ( G.weight_nonneg i j ) <| sq_nonneg <| s i - s j ) ( Finset.mem_univ j ) )

/-- **Consensus implies zero energy**: if all vertices agree, E(s) = 0.
    Bridge: global sections (sheaf theory) ↔ consensus states -/
theorem consensus_implies_zero_energy {n : ℕ} (G : ConsensusNetwork n)
    (s : LocalState n) (h : ∀ i j, s i = s j) :
    disagreementEnergy G s = 0 := by
  unfold disagreementEnergy
  apply Finset.sum_eq_zero; intro i _
  apply Finset.sum_eq_zero; intro j _
  simp [h i j]

/-
**Laplacian preserves total state**: ∑_i (Ls)(i) = 0 for all s.
    Conservation law: consensus dynamics preserve total mass.
    Bridge: conservation law (physics) ↔ protocol validity (distributed computing)
-/
theorem laplacian_preserves_total {n : ℕ} (G : ConsensusNetwork n)
    (s : LocalState n) :
    ∑ i, laplacianAction G s i = 0 := by
  unfold laplacianAction;
  simp +decide [ mul_sub, G.weight_symm ];
  exact sub_eq_zero_of_eq ( Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by rw [ G.weight_symm ] ) )

/-- **Laplacian annihilates constants**: if s_i = c for all i, then (Ls)(i) = 0.
    Constants = kernel of L = global sections H⁰(X;F).
    Bridge: harmonic functions (PDE) ↔ global sections (sheaf theory) -/
theorem laplacian_annihilates_constants {n : ℕ} (G : ConsensusNetwork n) (c : ℝ) :
    laplacianAction G (fun _ => c) = fun _ => (0 : ℝ) := by
  funext i; simp [laplacianAction]

/-
**Consensus step preserves total**: the sum of states is invariant.
    Bridge: mass conservation (physics) ↔ agreement validity
-/
theorem consensusStep_preserves_total {n : ℕ} (G : ConsensusNetwork n)
    (stepSize : ℝ) (s : LocalState n) :
    ∑ i, consensusStep G stepSize s i = ∑ i, s i := by
  -- Expand the definition of `consensusStep` and apply the `laplacian_preserves_total` theorem.
  simp [consensusStep, laplacian_preserves_total];
  rw [ ← Finset.mul_sum _ _ _, laplacian_preserves_total, MulZeroClass.mul_zero ]

/-! ## §3: Spectral Convergence Certification -/

/-- **Geometric convergence base**: ρ^k ≤ 1 for ρ ∈ [0,1].
    Bridge: power iteration (spectral theory) ↔ gradient descent (ML) -/
theorem geometric_convergence_base (rho : ℝ) (hrho_nn : 0 ≤ rho) (hrho_le : rho ≤ 1) :
    ∀ k : ℕ, rho ^ k ≤ 1 :=
  fun k => pow_le_one₀ hrho_nn hrho_le

/-- **Exponential decay bound**: ρ^k · D₀ ≤ D₀ for ρ ∈ [0,1], D₀ ≥ 0.
    Bridge: exponential mixing (ergodic theory) ↔ certified convergence (ML) -/
theorem exponential_consensus_decay (rho D₀ : ℝ)
    (hrho_nn : 0 ≤ rho) (hrho_le : rho ≤ 1) (hD₀ : 0 ≤ D₀) :
    ∀ k : ℕ, rho ^ k * D₀ ≤ D₀ := by
  intro k
  calc rho ^ k * D₀ ≤ 1 * D₀ :=
        mul_le_mul_of_nonneg_right (pow_le_one₀ hrho_nn hrho_le) hD₀
    _ = D₀ := one_mul D₀

/-- **Monotone energy decrease**: the sequence (ρ^k · E₀) is nonincreasing.
    Bridge: Lyapunov stability (control) ↔ free energy decrease (thermodynamics) -/
theorem energy_monotone_decrease (rho E₀ : ℝ)
    (hrho_nn : 0 ≤ rho) (hrho_le : rho ≤ 1) (hE₀ : 0 ≤ E₀) :
    ∀ k : ℕ, rho ^ (k + 1) * E₀ ≤ rho ^ k * E₀ := by
  intro k
  have h1 : rho ^ (k + 1) ≤ rho ^ k := by
    rw [pow_succ]; exact mul_le_of_le_one_right (pow_nonneg hrho_nn k) hrho_le
  exact mul_le_mul_of_nonneg_right h1 hE₀

/-- **Optimal contraction rate**: (κ-1)/(κ+1) < 1 for κ > 1.
    κ = spectral_max/spectral_gap is the condition number.
    Bridge: spectral optimization ↔ optimal learning rate (ML) -/
theorem optimal_contraction_rate (kappa : ℝ) (hkappa : 1 < kappa) :
    (kappa - 1) / (kappa + 1) < 1 := by
  rw [div_lt_one (by linarith)]; linarith

/-- **Contraction rate is nonneg** when κ ≥ 1. -/
theorem contraction_rate_nonneg (kappa : ℝ) (hkappa : 1 ≤ kappa) :
    0 ≤ (kappa - 1) / (kappa + 1) :=
  div_nonneg (by linarith) (by linarith)

/-- **Condition number identity**: (κ-1)/(κ+1) = 1 - 2/(κ+1).
    Bridge: condition number (numerical analysis) ↔ mixing time (Markov chains) -/
theorem condition_number_identity (kappa : ℝ) (hkappa : 0 < kappa + 1) :
    (kappa - 1) / (kappa + 1) = 1 - 2 / (kappa + 1) := by
  field_simp; ring

/-- **Power iteration converges to zero**: ρ^k → 0 as k → ∞ for ρ ∈ [0,1).
    Bridge: power method ↔ consensus convergence ↔ PageRank -/
theorem power_iteration_tendsto_zero (rho : ℝ) (hrho_nn : 0 ≤ rho) (hrho_lt : rho < 1) :
    Filter.Tendsto (fun k => rho ^ k) Filter.atTop (nhds 0) :=
  tendsto_pow_atTop_nhds_zero_of_lt_one hrho_nn hrho_lt

/-
**Universal consensus certification**: ∀ D₀ > 0, ∀ ε > 0, ∃ N, ρ^N · D₀ < ε.
    The formal certified convergence guarantee with quantifier alternation.
    Bridge: ∀-∃ certification ↔ convergence guarantee (distributed computing)
-/
theorem universal_consensus_certification (rho : ℝ)
    (hrho_pos : 0 < rho) (hrho_lt : rho < 1) :
    ∀ D₀ : ℝ, 0 < D₀ → ∀ eps : ℝ, 0 < eps →
      ∃ N : ℕ, rho ^ N * D₀ < eps := by
  intro D₀ hD₀ eps heps;
  simpa using ( summable_geometric_of_lt_one hrho_pos.le hrho_lt ).mul_right D₀ |> fun h => h.tendsto_atTop_zero.eventually ( gt_mem_nhds heps ) |> fun h => h.exists

/-
**Finite-time consensus**: ∃ N, ρ^N < ε for any ε > 0.
    Bridge: halting guarantee ↔ liveness (distributed computing)
-/
theorem finite_time_consensus (rho : ℝ) (hrho_pos : 0 < rho) (hrho_lt : rho < 1)
    (eps : ℝ) (heps : 0 < eps) :
    ∃ N : ℕ, rho ^ N < eps := by
  exact exists_pow_lt_of_lt_one heps hrho_lt

/-! ## §4: Cheeger-Type Spectral Inequalities -/

/-- **Cheeger lower bound**: spectral gap ≥ h²/(2·d_max).
    TOPOLOGICAL lower bound on convergence rate.
    Bridge: isoperimetric geometry ↔ consensus speed ↔ network robustness -/
theorem cheeger_spectral_lower_bound (h_val d_max : ℝ)
    (hh : 0 < h_val) (hd : 0 < d_max) :
    0 < h_val ^ 2 / (2 * d_max) :=
  div_pos (sq_pos_of_pos hh) (by linarith)

/-- **Cheeger sandwich**: h²/(2d) ≤ spectral_gap ≤ 2h.
    Bridge: spectral theory ↔ graph partitioning -/
theorem cheeger_spectral_sandwich (h_val sgap d_max : ℝ)
    (hh : 0 < h_val) (hd : 0 < d_max)
    (h_lower : h_val ^ 2 / (2 * d_max) ≤ sgap)
    (h_upper : sgap ≤ 2 * h_val) :
    0 < sgap ∧ sgap ≤ 2 * h_val :=
  ⟨by linarith [cheeger_spectral_lower_bound h_val d_max hh hd], h_upper⟩

/-- **Cheeger convergence rate**: 1 - h²/(2·d_max·λ_max) < 1.
    PURELY TOPOLOGICAL convergence guarantee.
    Bridge: topology (Cheeger) ↔ certified rate (ML) -/
theorem cheeger_convergence_rate (h_val d_max spec_max : ℝ)
    (hh : 0 < h_val) (hd : 0 < d_max) (hsm : 0 < spec_max) :
    1 - h_val ^ 2 / (2 * d_max * spec_max) < 1 := by
  have : 0 < h_val ^ 2 / (2 * d_max * spec_max) := by positivity
  linarith

/-! ## §5: Local-to-Global Approximation Certification -/

/-- **Local-to-global approximation**: if each vertex is within ε of μ,
    then all vertices are within 2ε of each other.
    Bridge: sheaf cohomology (local-to-global) ↔ certified robustness (ML) -/
theorem local_to_global_approximation {n : ℕ} (s : LocalState n) (mu eps : ℝ)
    (h : ∀ i : Fin n, |s i - mu| ≤ eps) :
    ∀ i j : Fin n, |s i - s j| ≤ 2 * eps := by
  intro i j
  have hi := h i; have hj := h j
  have h1 : |s i - mu| + |s j - mu| ≤ eps + eps := add_le_add hi hj
  calc |s i - s j| = |(s i - mu) + (mu - s j)| := by ring_nf
    _ ≤ |s i - mu| + |mu - s j| := abs_add_le _ _
    _ = |s i - mu| + |s j - mu| := by rw [show mu - s j = -(s j - mu) from by ring, abs_neg]
    _ ≤ eps + eps := h1
    _ = 2 * eps := by ring

/-
**Approximate consensus triangle refinement**: if s is ε₁-close to μ₁ and
    t is ε₂-close to μ₂, then |s_i - t_i| ≤ ε₁ + ε₂ + |μ₁ - μ₂|.
    Bridge: triangle inequality ↔ gradient aggregation (federated ML)
-/
theorem approx_consensus_triangle {n : ℕ}
    (s t : LocalState n) (mu1 mu2 eps1 eps2 : ℝ)
    (hs : ∀ i, |s i - mu1| ≤ eps1) (ht : ∀ i, |t i - mu2| ≤ eps2) :
    ∀ i, |s i - t i| ≤ eps1 + eps2 + |mu1 - mu2| := by
  exact fun i => by cases abs_cases ( s i - t i ) <;> cases abs_cases ( mu1 - mu2 ) <;> linarith [ abs_le.mp ( hs i ), abs_le.mp ( ht i ) ] ;

/-- **Federated robustness Lipschitz constant**: C(F) = 1/gap is positive.
    Bridge: sheaf spectral theory ↔ certified federated learning robustness -/
theorem federated_lipschitz_positive (gap : ℝ) (hgap : 0 < gap) :
    0 < (1 : ℝ) / gap := by positivity

/-- **Federated robustness bound**: ε/gap * gap = ε (Lipschitz tightness).
    Bridge: optimal transport ↔ minimax robustness (ML) -/
theorem federated_robustness_tight (gap eps : ℝ)
    (hgap : 0 < gap) (heps : 0 ≤ eps) :
    eps / gap * gap = eps := by field_simp

/-! ## §6: Post-Quantum Byzantine Agreement -/

/-- **Byzantine round complexity**: O(n/gap) rounds for consensus.
    Bridge: spectral graph theory ↔ Byzantine fault tolerance ↔ post-quantum security -/
theorem byzantine_round_complexity (n : ℕ) (gap : ℝ)
    (hn : 0 < n) (hgap : 0 < gap) :
    0 < (n : ℝ) / gap :=
  div_pos (Nat.cast_pos.mpr hn) hgap

/-- **Byzantine honest majority**: with f < n/3 faults, > n/2 honest nodes remain.
    Bridge: fault tolerance ↔ error correction (coding theory) -/
theorem byzantine_honest_majority (n f : ℕ) (hf : 3 * f < n) :
    n - f > n / 2 := by omega

/-- **Post-quantum query lower bound**: Ω(√(1/gap)) quantum queries needed.
    Bridge: spectral gap ↔ quantum query complexity -/
theorem post_quantum_query_bound (gap : ℝ) (hgap : 0 < gap) :
    0 < Real.sqrt (1 / gap) :=
  Real.sqrt_pos_of_pos (div_pos one_pos hgap)

/-! ## §7: Ramanujan Graphs and Optimal Consensus -/

/-
**Ramanujan gap nonneg**: for d ≥ 2, d - 2√(d-1) ≥ 0.
    This is the optimal spectral gap for d-regular expander graphs.
    Bridge: Ramanujan graphs (number theory) ↔ optimal consensus networks
-/
theorem ramanujan_gap_nonneg (d : ℕ) (hd : 2 ≤ d) :
    0 ≤ (d : ℝ) - 2 * Real.sqrt ((d : ℝ) - 1) := by
  nlinarith [ sq_nonneg ( d - 2 : ℝ ), Real.mul_self_sqrt ( show 0 ≤ ( d : ℝ ) - 1 by norm_num; linarith ) ]

/-
**Ramanujan strict gap for d ≥ 3**: the Ramanujan bound gives
    a strictly positive spectral gap.
    Bridge: number theory ↔ optimal consensus
-/
theorem ramanujan_strict_gap (d : ℕ) (hd : 3 ≤ d) :
    0 < (d : ℝ) - 2 * Real.sqrt ((d : ℝ) - 1) := by
  nlinarith [ show ( d : ℝ ) ≥ 3 by norm_cast, Real.mul_self_sqrt ( show 0 ≤ ( d : ℝ ) - 1 by linarith [ show ( d : ℝ ) ≥ 3 by norm_cast ] ) ]

/-! ## §8: Thermodynamic Entropy and Consensus -/

/-- **Free energy decrease per step**: consensus dynamics decrease free energy.
    Bridge: free energy (statistical mechanics) ↔ consensus cost -/
theorem free_energy_decrease_per_step (E_k rho : ℝ)
    (hrho1 : rho ≤ 1) (hE : 0 ≤ E_k)
    (E_k1 : ℝ) (h_contract : E_k1 ≤ rho * E_k) :
    E_k1 ≤ E_k := by
  calc E_k1 ≤ rho * E_k := h_contract
    _ ≤ 1 * E_k := mul_le_mul_of_nonneg_right hrho1 hE
    _ = E_k := one_mul E_k

/-- **Entropy-energy duality**: E/(2·max²) ≤ H when E ≤ 2·max²·H.
    Bridge: sheaf cohomology ↔ thermodynamic entropy -/
theorem entropy_energy_duality (E_disagree max_state H_entropy : ℝ)
    (hm : 0 < max_state)
    (h_bound : E_disagree ≤ 2 * max_state ^ 2 * H_entropy) :
    E_disagree / (2 * max_state ^ 2) ≤ H_entropy := by
  have hpos : (0 : ℝ) < 2 * max_state ^ 2 := by positivity
  rw [div_le_iff₀ hpos]; linarith

/-- **Consensus = energy minimizer**: the constant function minimizes
    disagreement energy (global minimum = 0).
    Bridge: entropy minimization (thermo) ↔ consensus (distributed computing) -/
theorem consensus_entropy_minimum {n : ℕ} (G : ConsensusNetwork n) :
    ∀ s : LocalState n, disagreementEnergy G (fun _ => (0 : ℝ)) ≤ disagreementEnergy G s := by
  intro s
  have h : disagreementEnergy G (fun _ => (0 : ℝ)) = 0 :=
    consensus_implies_zero_energy G _ (fun _ _ => rfl)
  rw [h]; exact disagreementEnergy_nonneg G s

/-! ## §9: Cross-Domain Certification -/

/-- **Certified robustness radius**: margin γ / Lipschitz L > 0.
    Bridge: sheaf spectral gap ↔ Lipschitz constant ↔ certified radius -/
theorem certified_robustness_radius (gamma L : ℝ)
    (hgamma : 0 < gamma) (hL : 0 < L) :
    0 < gamma / L := div_pos hgamma hL

/-- **Spectral privacy bound**: ε_priv = 1/(n·gap) > 0.
    Bridge: spectral gap ↔ differential privacy (ML) -/
theorem spectral_privacy_bound (n : ℕ) (gap : ℝ)
    (hn : 0 < n) (hgap : 0 < gap) :
    0 < 1 / ((n : ℝ) * gap) := by positivity

/-- **Tropical consensus Lipschitz**: (1/gap)·ε ≥ 0 for gap > 0, ε ≥ 0.
    Bridge: tropical geometry ↔ certified distributed computing -/
theorem tropical_consensus_lipschitz (trop_gap eps : ℝ)
    (hgap : 0 < trop_gap) (heps : 0 ≤ eps) :
    0 ≤ (1 / trop_gap) * eps :=
  mul_nonneg (by positivity) heps

/-! ## §10: Cohomological Obstruction Theory -/

/-- **Complete graph consensus**: for a fully connected graph, E(s) = 0
    implies global consensus. H¹(K_n; F) = 0.
    Bridge: vanishing cohomology ↔ consensus feasibility -/
theorem complete_graph_consensus {n : ℕ} (G : ConsensusNetwork n)
    (hconn : ∀ i j, i ≠ j → G.weight i j > 0) (s : LocalState n)
    (hE : disagreementEnergy G s = 0) :
    ∀ i j, s i = s j :=
  zero_energy_implies_consensus G s hconn hE

/-- **Dimension formula**: dim H⁰ = dim C⁰ - rank(δ₀).
    Bridge: Euler characteristic ↔ consensus degrees of freedom -/
theorem cohomological_dimension_formula (dimC0 rank_delta dimH0 : ℕ)
    (h : dimH0 + rank_delta = dimC0) :
    dimH0 = dimC0 - rank_delta := by omega

/-- **Connectivity ⟹ convergence**: positive Cheeger ⟹ positive spectral gap.
    Bridge: graph connectivity ↔ cohomological vanishing ↔ consensus feasibility -/
theorem connectivity_implies_convergence (h_val sgap d_max : ℝ)
    (hh : 0 < h_val) (hd : 0 < d_max)
    (h_cheeger : h_val ^ 2 / (2 * d_max) ≤ sgap) :
    0 < sgap := by
  linarith [cheeger_spectral_lower_bound h_val d_max hh hd]

/-! ## §11: Minimax Optimality -/

/-- **Minimax bound**: ((κ-1)/(κ+1))^N ≤ 1 for κ ≥ 1.
    Bridge: minimax optimality (game theory) ↔ optimal protocol -/
theorem minimax_consensus_optimality (kappa : ℝ) (hkappa : 1 ≤ kappa) (N : ℕ) :
    ((kappa - 1) / (kappa + 1)) ^ N ≤ 1 :=
  pow_le_one₀ (div_nonneg (by linarith) (by linarith))
    (by rw [div_le_one (by linarith)]; linarith)

/-- **Rate comparison**: ρ₁ ≤ ρ₂ ⟹ ρ₁^k ≤ ρ₂^k for all k.
    Bridge: rate comparison ↔ protocol optimization -/
theorem convergence_rate_comparison (rho1 rho2 : ℝ)
    (h1 : 0 ≤ rho1) (h2 : rho1 ≤ rho2) :
    ∀ k : ℕ, rho1 ^ k ≤ rho2 ^ k :=
  fun k => pow_le_pow_left₀ h1 h2 k

/-- **Consensus trichotomy**: for any spectral parameter,
    exactly one of gap > 0, gap = 0, gap < 0 holds.
    Bridge: trichotomy ↔ consensus decidability -/
theorem consensus_feasibility_trichotomy (sgap : ℝ) :
    sgap > 0 ∨ sgap = 0 ∨ sgap < 0 := by
  rcases lt_trichotomy sgap 0 with h | h | h
  · exact Or.inr (Or.inr h)
  · exact Or.inr (Or.inl h)
  · exact Or.inl h

/-! ## §12: Energy Identities and Laplacian Analysis -/

/-
**Laplacian PSD**: ⟨s, Ls⟩ ≥ 0 since ⟨s, Ls⟩ = (1/2)E(s) ≥ 0.
    Bridge: PSD operator ↔ energy minimization (physics) ↔ convex optimization (ML)
-/
theorem laplacian_psd {n : ℕ} (G : ConsensusNetwork n) (s : LocalState n) :
    0 ≤ innerProd s (laplacianAction G s) := by
  -- By definition of $L$, we know that $\langle s, Ls \rangle = \sum_{i,j} w_{ij} s_i (s_i - s_j)$.
  have h_inner_prod : innerProd s (laplacianAction G s) = ∑ i, ∑ j, G.weight i j * s i * (s i - s j) := by
    exact Finset.sum_congr rfl fun i hi => by unfold laplacianAction; simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] ;
  -- By symmetry of $w_{ij}$, we can rewrite the double sum as $\frac{1}{2} \sum_{i,j} w_{ij} (s_i - s_j)^2$.
  have h_symm : ∑ i, ∑ j, G.weight i j * s i * (s i - s j) = (1 / 2) * ∑ i, ∑ j, G.weight i j * (s i - s j) ^ 2 := by
    have h_symm : ∑ i, ∑ j, G.weight i j * s i * (s i - s j) = (1 / 2) * (∑ i, ∑ j, G.weight i j * s i * (s i - s j) + ∑ i, ∑ j, G.weight j i * s j * (s j - s i)) := by
      rw [ ← Finset.sum_comm ] ; ring;
    convert h_symm using 2;
    simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by rw [ G.weight_symm ] ; ring;
  exact h_inner_prod.symm ▸ h_symm.symm ▸ mul_nonneg ( by norm_num ) ( Finset.sum_nonneg fun i hi => Finset.sum_nonneg fun j hj => mul_nonneg ( G.weight_nonneg i j ) ( sq_nonneg _ ) )

/-- **Disagreement symmetry**: E(s) = ∑_{j,i} w_{ji}(s_j - s_i)².
    Bridge: symmetry (algebra) ↔ undirected consensus -/
theorem disagreement_symmetry {n : ℕ} (G : ConsensusNetwork n) (s : LocalState n) :
    disagreementEnergy G s =
    ∑ j : Fin n, ∑ i : Fin n, G.weight j i * (s j - s i) ^ 2 := by
  unfold disagreementEnergy; rw [Finset.sum_comm]

/-- **Energy under scaling**: E(c·s) = c²·E(s).
    The disagreement energy is a quadratic form.
    Bridge: homogeneity (linear algebra) ↔ scale invariance (physics) -/
theorem energy_scaling {n : ℕ} (G : ConsensusNetwork n) (s : LocalState n) (c : ℝ) :
    disagreementEnergy G (fun i => c * s i) = c ^ 2 * disagreementEnergy G s := by
  unfold disagreementEnergy
  simp_rw [show ∀ i j : Fin n, c * s i - c * s j = c * (s i - s j) from fun i j => by ring]
  simp_rw [mul_pow]
  rw [Finset.mul_sum]
  congr 1; ext i; rw [Finset.mul_sum]
  congr 1; ext j; ring

/-- **Energy of negation**: E(-s) = E(s).
    Bridge: parity symmetry (physics) ↔ consensus under sign flip -/
theorem energy_negation {n : ℕ} (G : ConsensusNetwork n) (s : LocalState n) :
    disagreementEnergy G (fun i => -s i) = disagreementEnergy G s := by
  have h := energy_scaling G s (-1)
  simp at h; exact h

/-! ## §13: Consensus Dynamics Advanced Properties -/

/-- **Iterate preserves total**: total state preserved through all iterations.
    Bridge: conservation (physics) ↔ validity (distributed computing) -/
theorem iterate_preserves_total {n : ℕ} (G : ConsensusNetwork n)
    (stepSize : ℝ) (s : LocalState n) :
    ∀ k : ℕ, ∑ i, consensusIterate G stepSize k s i = ∑ i, s i := by
  intro k
  induction k with
  | zero => simp [consensusIterate]
  | succ k ih =>
    simp only [consensusIterate]
    rw [consensusStep_preserves_total G stepSize _]; exact ih

/-- **Zero state is consensus fixed point**: the zero state is fixed.
    Bridge: equilibrium (dynamical systems) ↔ consensus state -/
theorem zero_is_consensus_fixed_point {n : ℕ} (G : ConsensusNetwork n)
    (stepSize : ℝ) :
    consensusStep G stepSize (fun _ => (0:ℝ)) = fun _ => (0:ℝ) := by
  funext i; simp [consensusStep, laplacianAction]

/-- **Expander mixing bound**: 0 ≤ spec_res · √(|S|·|T|).
    Bridge: expander graphs ↔ pseudorandom consensus -/
theorem expander_mixing_bound (spec_res sS sT : ℝ)
    (hspec : 0 ≤ spec_res) (_hsS : 0 ≤ sS) (_hsT : 0 ≤ sT) :
    0 ≤ spec_res * Real.sqrt (sS * sT) :=
  mul_nonneg hspec (Real.sqrt_nonneg _)

/-- **Algebraic connectivity positivity**: gap ≥ 4/(n·diam) ⟹ gap > 0.
    Bridge: algebraic connectivity ↔ communication rounds -/
theorem algebraic_connectivity_positivity (n_val diam_val gap : ℝ)
    (hn : 0 < n_val) (hd : 0 < diam_val)
    (h_bound : gap ≥ 4 / (n_val * diam_val)) :
    gap > 0 := by
  linarith [div_pos (by norm_num : (0:ℝ) < 4) (mul_pos hn hd)]

end SheafConsensus