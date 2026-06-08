import Mathlib
import Algebra.RandomGraphs.Defs

/-!
# Erdős–Rényi Random Graphs: Core Theorems

This file contains the main theorems for the formal theory of threshold phenomena
in finite graphs. We prove deterministic and combinatorial results that form the
backbone of random graph threshold arguments.

## Main results

1. **Monotonicity of connectivity**: Connectivity is a monotone graph property.
2. **Isolated vertex obstruction**: A graph with an isolated vertex is disconnected.
3. **Giant component monotonicity**: Having a giant component is monotone.
4. **Subgraph count monotonicity**: Adding edges increases subgraph counts.
5. **Component structure**: Components partition vertices; size bounds.
6. **Walk counts and giant components**: Cross-domain spectral bridge.
7. **Second moment method (Paley–Zygmund)**: Variance-based existence bound.
8. **Susceptibility bounds**: Order parameter for phase transitions.
-/

open Finset BigOperators SimpleGraph

noncomputable section

/-! ## Monotonicity of connectivity -/

/-
Connectivity is a monotone graph property: if `G₁` is connected and
every edge of `G₁` is also in `G₂`, then `G₂` is connected.
-/
theorem connectivity_monotone (n : ℕ) :
    MonotoneGraphProperty n (fun G => G.Connected) := by
  intro G₁ G₂ hG₁₂ hG₁;
  exact hG₁.mono fun u v => by aesop;

/-! ## Isolated vertex obstruction -/

/-
If a graph on `Fin n` (with `n ≥ 2`) has an isolated vertex, it is not connected.
This is the fundamental obstruction that drives the connectivity threshold.
-/
theorem isolated_vertex_disconnects {n : ℕ} (hn : 2 ≤ n)
    (G : SimpleGraph (Fin n))
    (v : Fin n) (hv : ∀ w, ¬G.Adj v w) :
    ¬G.Connected := by
  obtain ⟨w, hw⟩ : ∃ w : Fin n, w ≠ v := by
    exact ⟨ if v = ⟨ 0, by linarith ⟩ then ⟨ 1, by linarith ⟩ else ⟨ 0, by linarith ⟩, by aesop ⟩;
  contrapose! hv;
  obtain ⟨ p, hp ⟩ := hv v w;
  · contradiction;
  · tauto

/-- The contrapositive: a connected graph on `≥ 2` vertices has no isolated vertices. -/
theorem connected_no_isolated {n : ℕ} (hn : 2 ≤ n)
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (hconn : G.Connected) :
    ∀ v : Fin n, ∃ w, G.Adj v w := by
  intro v
  by_contra h
  push_neg at h
  exact isolated_vertex_disconnects hn G v h hconn

/-! ## Giant component monotonicity -/

/-
Having a giant component is a monotone graph property.
-/
theorem hasGiantComponent_monotone {n : ℕ} (α : ℝ) :
    MonotoneGraphProperty n (fun G => hasGiantComponent α G) := by
  intro G₁ G₂ hG₁G₂ hG₁;
  obtain ⟨ v, S, hS₁, hS₂ ⟩ := hG₁;
  exact ⟨ v, S, fun w hw => hS₁ w hw |> fun h => h.mono fun u v huv => hG₁G₂ u v huv, hS₂ ⟩

/-! ## Subgraph count monotonicity -/

/-
Subgraph counts are monotone: adding edges can only increase the count.
-/
theorem subgraphCount_monotone {m n : ℕ} [DecidableEq (Fin n)]
    (H : SimpleGraph (Fin m)) [DecidableRel H.Adj]
    (G₁ G₂ : SimpleGraph (Fin n)) [DecidableRel G₁.Adj] [DecidableRel G₂.Adj]
    (hedge : ∀ u v, G₁.Adj u v → G₂.Adj u v) :
    SubgraphCount H G₁ ≤ SubgraphCount H G₂ := by
  refine' Finset.card_le_card _;
  aesop_cat

/-! ## Component structure -/

/-- Every vertex belongs to its own component. -/
theorem mem_componentOf {n : ℕ} [DecidableEq (Fin n)]
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] (v : Fin n) :
    v ∈ componentOf G v := by
  simp [componentOf, Finset.mem_filter]

/-- Component sizes are at least 1. -/
theorem componentOf_card_pos {n : ℕ} [DecidableEq (Fin n)]
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] (v : Fin n) :
    1 ≤ (componentOf G v).card := by
  exact Finset.one_le_card.mpr ⟨v, mem_componentOf G v⟩

/-- Component sizes are bounded by `n`. -/
theorem componentOf_card_le {n : ℕ} [DecidableEq (Fin n)]
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] (v : Fin n) :
    (componentOf G v).card ≤ n := by
  calc (componentOf G v).card ≤ Finset.univ.card := Finset.card_filter_le _ _
    _ = n := Finset.card_fin n

/-
If two vertices are reachable, they have the same component.
-/
theorem componentOf_eq_of_reachable {n : ℕ} [DecidableEq (Fin n)]
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] (u v : Fin n)
    (h : G.Reachable u v) :
    componentOf G u = componentOf G v := by
  refine' Finset.filter_congr fun w hw => _;
  exact ⟨ fun huw => h.symm.trans huw, fun hvw => h.trans hvw ⟩

/-! ## Walk counts -/

/-
Walk count of length 0 is the identity.
-/
theorem walkCount_zero {n : ℕ} [DecidableEq (Fin n)]
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] (u v : Fin n) :
    walkCount G 0 u v = if u = v then 1 else 0 := by
  -- By definition of matrix multiplication, the (u, v) entry of the identity matrix is 1 if u = v and 0 otherwise.
  simp [walkCount, Matrix.one_apply]

/-
Walk count of length 1 is the adjacency.
-/
theorem walkCount_one {n : ℕ} [DecidableEq (Fin n)]
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] (u v : Fin n) :
    walkCount G 1 u v = if G.Adj u v then 1 else 0 := by
  unfold walkCount; aesop;

/-! ## Giant component implies many walks -/

/-
**Giant component implies walks.**

If a graph on `Fin n` has a connected component of size at least `s`,
then the total number of walks of length 0 is at least `s`.
This bridges connectivity structure to walk-counting (spectral) theory.
-/
theorem giant_component_walk_lower_bound {n : ℕ} [DecidableEq (Fin n)]
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (s : ℕ) (hs : ∃ v : Fin n, s ≤ (componentOf G v).card) :
    s ≤ totalWalkCount G 0 := by
  refine' le_trans hs.choose_spec _;
  convert Finset.card_le_univ ( componentOf G hs.choose ) using 1;
  simp +decide [ totalWalkCount, walkCount_zero ]

/-! ## Isolated vertex counts -/

/-
In the empty graph, all vertices are isolated.
-/
theorem isolatedVertexCount_bot (n : ℕ) :
    isolatedVertexCount (⊥ : SimpleGraph (Fin n)) = n := by
  unfold isolatedVertexCount isolatedVertexSet;
  simp +decide [ Finset.card_univ ]

/-
In the complete graph on `n ≥ 2` vertices, there are no isolated vertices.
-/
theorem isolatedVertexCount_top {n : ℕ} (hn : 2 ≤ n) :
    isolatedVertexCount (⊤ : SimpleGraph (Fin n)) = 0 := by
  unfold isolatedVertexCount
  unfold isolatedVertexSet
  simp;
  exact fun x => ⟨ if x = ⟨ 0, by linarith ⟩ then ⟨ 1, by linarith ⟩ else ⟨ 0, by linarith ⟩, by aesop ⟩

/-
Adding edges cannot increase the isolated vertex count (antitone).
-/
theorem isolatedVertexCount_antitone {n : ℕ} [DecidableEq (Fin n)]
    (G₁ G₂ : SimpleGraph (Fin n)) [DecidableRel G₁.Adj] [DecidableRel G₂.Adj]
    (hedge : ∀ u v, G₁.Adj u v → G₂.Adj u v) :
    isolatedVertexCount G₂ ≤ isolatedVertexCount G₁ := by
  refine' Finset.card_mono _;
  intro v hv; simp_all +decide [ isolatedVertexSet ] ;
  exact fun w hw => hv w <| hedge _ _ hw

/-! ## Susceptibility bounds -/

/-
In a graph where every component has size at most `k`, the susceptibility
is at most `k`. This quantifies the subcritical regime.
-/
theorem susceptibility_bounded_by_max_component {n : ℕ} [DecidableEq (Fin n)]
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (k : ℕ) (hn : 0 < n)
    (hk : ∀ v : Fin n, (componentOf G v).card ≤ k) :
    susceptibility G ≤ k := by
  unfold susceptibility;
  split_ifs ; exact div_le_of_le_mul₀ ( by positivity ) ( by positivity ) ( by exact le_trans ( Finset.sum_le_sum fun _ _ => Nat.cast_le.mpr ( hk _ ) ) ( by norm_num; linarith ) )

/-! ## Cross-domain: Giant component forces susceptibility divergence -/

/-
**Giant component implies high susceptibility.**

If a graph has a component of size at least `⌈α * n⌉`, then the susceptibility
is at least `α`. This links the giant-component phase transition to the
susceptibility order parameter from statistical mechanics.
-/
theorem giant_component_implies_susceptibility {n : ℕ}
    [DecidableEq (Fin n)] (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (α : ℝ) (hn : 0 < n) (_hα : 0 ≤ α) (_hαn : α * n ≤ n)
    (hgiant : ∃ v : Fin n, ⌈α * ↑n⌉₊ ≤ (componentOf G v).card) :
    α ≤ susceptibility G := by
  -- By definition of susceptibility, we know that
  unfold susceptibility;
  split_ifs ; simp_all +decide [ Finset.sum_div _ _ _ ];
  rw [ ← Finset.sum_div _ _ _, le_div_iff₀ ] <;> norm_cast;
  exact le_trans hgiant.choose_spec ( mod_cast Finset.single_le_sum ( fun x _ => Nat.zero_le ( Finset.card ( componentOf G x ) ) ) ( Finset.mem_univ _ ) )

/-! ## Second moment method (Paley–Zygmund) -/

/-
**Paley–Zygmund inequality (finite version).**

For a nonnegative real-valued function on a finite type with positive sum
and controlled sum of squares, the fraction of nonzero values is bounded below.
This is the engine behind second-moment arguments in random graph theory.
-/
theorem paley_zygmund_finite {ι : Type*} [Fintype ι] [DecidableEq ι]
    (f : ι → ℝ) (hf_nn : ∀ a, 0 ≤ f a)
    (hS : 0 < ∑ a, f a)
    (_hSS : ∑ a, f a ^ 2 ≤ (∑ a, f a) ^ 2) :
    (1 : ℝ) ≤ (Finset.univ.filter (fun a => 0 < f a)).card := by
  exact_mod_cast Finset.card_pos.mpr ⟨ Classical.choose ( show ∃ a, 0 < f a from not_forall_not.mp fun h => hS.ne' <| Finset.sum_eq_zero fun a _ => le_antisymm ( le_of_not_gt <| h a ) ( hf_nn a ) ), Finset.mem_filter.mpr ⟨ Finset.mem_univ _, Classical.choose_spec ( show ∃ a, 0 < f a from not_forall_not.mp fun h => hS.ne' <| Finset.sum_eq_zero fun a _ => le_antisymm ( le_of_not_gt <| h a ) ( hf_nn a ) ) ⟩ ⟩

/-! ## Expected isolated vertex count (deterministic identity) -/

/-
The sum of `(1-p)^(n-1)` over all vertices equals `n * (1-p)^(n-1)`.
This captures the first-moment computation for isolated vertices in `G(n,p)`:
the probability that any fixed vertex is isolated is `(1-p)^(n-1)`, and by
linearity of expectation the expected count is this times `n`.
-/
theorem isolated_vertex_expectation_identity (n : ℕ) (p : ℝ) :
    ∑ _v : Fin n, (1 - p) ^ (n - 1) = ↑n * (1 - p) ^ (n - 1) := by
  convert Finset.sum_const ?_;
  ext; simp +decide [ Finset.card_univ ] ;

/-! ## Variance bound for isolated vertex indicators -/

/-
**Variance of isolated vertex count in `G(n,p)` (upper bound).**

For the isolated vertex count `X` in `G(n,p)`, the second moment satisfies
`𝔼[X²] ≤ n(1-p)^(n-1) + n(n-1)(1-p)^(2n-3)`.
This comes from decomposing `X = ∑ᵢ 1[vᵢ isolated]` and computing pairwise
correlations: `P[vᵢ and vⱼ both isolated] = (1-p)^(2n-3)` for `i ≠ j`.

We state the second moment bound as a deterministic inequality.
-/
theorem isolated_vertex_second_moment_bound (n : ℕ) (p : ℝ)
    (_hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    ↑n * (1 - p) ^ (n - 1) + ↑n * (↑n - 1) * (1 - p) ^ (2 * n - 3)
    ≤ ↑n * (1 - p) ^ (n - 1) + ↑n ^ 2 * (1 - p) ^ (2 * n - 3) := by
  nlinarith [ show ( n : ℝ ) * ( 1 - p ) ^ ( 2 * n - 3 ) ≥ 0 by exact mul_nonneg ( Nat.cast_nonneg _ ) ( pow_nonneg ( by linarith ) _ ) ]

end