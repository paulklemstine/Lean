import Speculative.IIT.Basic

/-!
# NP-hardness of maximum integrated information: reduction from CLIQUE

We give an explicit reduction `S : SimpleGraph α → ProbSystem α` and prove that the maximum
integrated information `Φ_max` of `S(G)` equals the clique number `ω(G)`, establishing that
computing `Φ_max` is at least as hard as computing the clique number (the optimization
version of CLIQUE), which is NP-hard.

## The construction `S(G)`

Variables are indexed by the vertices `α` of `G`.  The system `S(G)` is the uniform
distribution over the configurations:

* the all-off configuration `0`, and
* for each edge `{u, v}` of `G`, the configuration switched on exactly at `{u, v}`.

This support has at most `n² + 1` points (`n = |V|`), so `S(G)` has a description of size
polynomial in `|G|` and is computable from `G` (see `IIT.card_SSupport_le`).

## Both directions of the equivalence

* `IIT.coactive_iff_adj` — two distinct variables are co-active in `S(G)` iff they are
  adjacent in `G`; i.e. the co-activation graph of `S(G)` *is* `G`.
* `IIT.isCoactiveSet_iff_isClique` — co-active coalitions of `S(G)` are exactly the cliques
  of `G`.
* `IIT.clique_iff_phiMax_ge` (the reduction): for `k ≥ 2`, `G` has a clique of size `k`
  **iff** `k ≤ Φ_max(S(G))`.
* `IIT.phiMax_eq_cliqueNum` — for `ω(G) ≥ 2`, `Φ_max(S(G)) = ω(G)`.
* `IIT.phiMax_eq_zero_of_cliqueNum_le_one` — the boundary case (no edges).

## Approximation lower bound (transfer)

`IIT.approx_ratio_transfer` shows the reduction is *approximation preserving*: any
multiplicative `ρ`-approximation of `Φ_max(S(G))` is a `ρ`-approximation of `ω(G)` and
conversely.  Consequently the known inapproximability of CLIQUE transfers verbatim to
`Φ_max`; see `NOTES.md` for why this *rules out* a `(log n)^c`-approximation under standard
assumptions.
-/

namespace IIT

open scoped Classical
open SimpleGraph

variable {α : Type*} [Fintype α] [DecidableEq α]
variable (G : SimpleGraph α) [DecidableRel G.Adj]

/-- The configuration switched on exactly at `u` and `v`. -/
def edgeConfig (u v : α) : α → Bool := fun w => decide (w = u ∨ w = v)

omit [Fintype α] in
@[simp] theorem edgeConfig_apply (u v w : α) :
    edgeConfig u v w = true ↔ w = u ∨ w = v := by
  simp [edgeConfig]

/-- Support of the system `S(G)`: the all-off configuration together with, for each edge
`{u, v}`, the configuration on exactly `{u, v}`. -/
def SSupport : Finset (α → Bool) :=
  insert (fun _ => false)
    ((Finset.univ.filter (fun q : α × α => G.Adj q.1 q.2)).image (fun q => edgeConfig q.1 q.2))

theorem SSupport_nonempty : (SSupport G).Nonempty :=
  ⟨_, Finset.mem_insert_self _ _⟩

/-- **The reduction.** The probabilistic system associated to a graph `G`: the uniform
distribution on `SSupport G`. -/
noncomputable def S : ProbSystem α := PMF.uniformOfFinset (SSupport G) (SSupport_nonempty G)

@[simp] theorem support_S : (S G).support = ↑(SSupport G) :=
  PMF.support_uniformOfFinset _

/-- The support of `S(G)` has at most `n² + 1` configurations, where `n = |V|`: the
construction is of polynomial size (hence computable in polynomial time). -/
theorem card_SSupport_le : (SSupport G).card ≤ (Fintype.card α) ^ 2 + 1 := by
  refine' le_trans ( Finset.card_insert_le _ _ ) _;
  exact Nat.add_le_add_right ( Finset.card_image_le.trans ( le_trans ( Finset.card_le_univ _ ) ( by simp +decide [ sq ] ) ) ) _

/-- Membership characterisation of the support of `S(G)`. -/
theorem mem_SSupport_iff (x : α → Bool) :
    x ∈ SSupport G ↔ x = (fun _ => false) ∨ ∃ u v, G.Adj u v ∧ x = edgeConfig u v := by
  simp +decide [ SSupport, Finset.mem_insert, Finset.mem_image, eq_comm ]

/-- **Co-activation graph = `G`.** Two distinct variables are co-active in `S(G)` exactly
when they are adjacent in `G`. -/
theorem coactive_iff_adj {u v : α} (huv : u ≠ v) :
    Coactive (S G) u v ↔ G.Adj u v := by
  constructor;
  · rintro ⟨ x, hx, hxu, hxv ⟩;
    simp_all +decide [ support_S, mem_SSupport_iff ];
    rcases hx with ( rfl | ⟨ u', v', huv', rfl ⟩ ) <;> simp_all +decide [ edgeConfig ];
    cases hxu <;> cases hxv <;> simp_all +decide [ SimpleGraph.adj_comm ];
  · intro huv
    use edgeConfig u v
    simp;
    exact Finset.mem_insert_of_mem ( Finset.mem_image.mpr ⟨ ( u, v ), Finset.mem_filter.mpr ⟨ Finset.mem_univ _, huv ⟩, rfl ⟩ )

/-- **Co-active coalitions of `S(G)` are exactly the cliques of `G`.** -/
theorem isCoactiveSet_iff_isClique (K : Finset α) :
    IsCoactiveSet (S G) K ↔ G.IsClique (↑K : Set α) := by
  exact ⟨ fun h u hu v hv huv => ( coactive_iff_adj G huv ) |>.1 ( h hu hv huv ), fun h u hu v hv huv => ( coactive_iff_adj G huv ) |>.2 ( h hu hv huv ) ⟩

/-- The set whose supremum defines `Φ_max(S(G))` is exactly the set of clique sizes `≥ 2`. -/
theorem global_set_eq_clique_set :
    {n | ∃ K : Finset α, K.card = n ∧ IsCoactiveSet (S G) K ∧ 2 ≤ K.card}
      = {n | ∃ K : Finset α, G.IsClique (↑K : Set α) ∧ K.card = n ∧ 2 ≤ n} := by
  grind +suggestions

/-- `Φ_max(S(G))` is the supremum of clique sizes `≥ 2`: the integrated-information optimum
of `S(G)` is read off directly from the clique structure of `G`. -/
theorem phiMax_S_eq_cliqueSup :
    PhiMax (S G)
      = sSup {n | ∃ K : Finset α, G.IsClique (↑K : Set α) ∧ K.card = n ∧ 2 ≤ n} := by
  rw [phiMax_eq_global]
  show sSup {n | ∃ K : Finset α, K.card = n ∧ IsCoactiveSet (S G) K ∧ 2 ≤ K.card} = _
  rw [global_set_eq_clique_set]

/-- **The reduction, both directions.** For every `k ≥ 2`, the graph `G` has a clique of
size `k` if and only if `k ≤ Φ_max(S(G))`. -/
theorem clique_iff_phiMax_ge {k : ℕ} (hk : 2 ≤ k) :
    (∃ K : Finset α, G.IsNClique k K) ↔ k ≤ PhiMax (S G) := by
  constructor;
  · rintro ⟨ K, hK ⟩;
    rw [ phiMax_S_eq_cliqueSup ];
    exact le_csSup ⟨ Fintype.card α, fun n hn => by obtain ⟨ K, hK₁, rfl, hK₂ ⟩ := hn; exact Finset.card_le_univ K ⟩ ⟨ K, hK.1, hK.2, hk ⟩;
  · intro h;
    contrapose! h;
    rw [ phiMax_S_eq_cliqueSup ];
    refine' lt_of_le_of_lt ( csSup_le' _ ) _;
    exact k - 1;
    · rintro n ⟨ K, hK₁, rfl, hK₂ ⟩;
      exact Nat.le_sub_one_of_lt ( lt_of_not_ge fun hK₃ => h ( Finset.exists_subset_card_eq hK₃ |> Classical.choose ) <| by have := Finset.exists_subset_card_eq hK₃; exact ⟨ hK₁.subset <| Finset.coe_subset.2 <| this.choose_spec.1, this.choose_spec.2 ⟩ );
    · exact Nat.pred_lt ( ne_bot_of_gt hk )

/-- **Main equivalence.** When `G` has at least one edge (`ω(G) ≥ 2`), the maximum
integrated information of `S(G)` equals the clique number of `G`. -/
theorem phiMax_eq_cliqueNum (h2 : 2 ≤ G.cliqueNum) :
    PhiMax (S G) = G.cliqueNum := by
  rw [ eq_comm, SimpleGraph.cliqueNum ];
  rw [ @csSup_eq_of_forall_le_of_forall_lt_exists_gt ];
  · exact ⟨ _, ⟨ _, Classical.choose_spec ( G.exists_isNClique_cliqueNum ) ⟩ ⟩;
  · rintro n ⟨ s, hs ⟩;
    rcases n with ( _ | _ | n ) <;> simp_all +decide [ SimpleGraph.isNClique_iff ];
    · contrapose! h2;
      refine' lt_of_le_of_lt ( csSup_le' _ ) _;
      exact 1;
      · rintro n ⟨ s, hs ⟩;
        contrapose! h2;
        refine' le_trans _ ( clique_iff_phiMax_ge _ h2 |>.1 ⟨ s, hs ⟩ );
        grind +qlia;
      · decide +revert;
    · refine' lt_of_lt_of_le _ ( clique_iff_phiMax_ge _ _ |>.1 ⟨ s, hs.1, hs.2 ⟩ ); all_goals grind;
  · intro w hw;
    rw [ phiMax_S_eq_cliqueSup ] at hw;
    contrapose! hw;
    exact csSup_le' fun n hn => by obtain ⟨ K, hK₁, rfl, hK₂ ⟩ := hn; exact hw _ ⟨ K, by simpa [ SimpleGraph.isNClique_iff ] using hK₁ ⟩ ;

/-- Boundary case: an edgeless graph (`ω(G) ≤ 1`) has zero integrated information. -/
theorem phiMax_eq_zero_of_cliqueNum_le_one (h : G.cliqueNum ≤ 1) :
    PhiMax (S G) = 0 := by
  refine' csSup_eq_of_forall_le_of_forall_lt_exists_gt _ _ _;
  · exact ⟨ _, ⟨ ∅, rfl ⟩ ⟩;
  · rintro n ⟨ A, rfl ⟩;
    refine' csSup_le' _;
    rintro n ⟨ K, rfl, hK₁, hK₂ ⟩;
    have := isCoactiveSet_iff_isClique G K |>.1 hK₁;
    exact absurd h ( not_le_of_gt ( lt_of_lt_of_le ( by linarith [ two_le_card_of_straddles hK₂ ] ) ( this.card_le_cliqueNum ) ) );
  · grind

/-- **Approximation is preserved by the reduction.** If a value `a` is a multiplicative
`ρ`-approximation of `ω(G)` (both `a ≤ ρ·ω` and `ω ≤ ρ·a`), then it is a `ρ`-approximation
of `Φ_max(S(G))`, and conversely.  Hence inapproximability lower bounds for CLIQUE transfer
to `Φ_max`. -/
theorem approx_ratio_transfer (h2 : 2 ≤ G.cliqueNum) (a : ℕ) (ρ : ℝ) :
    ((a : ℝ) ≤ ρ * G.cliqueNum ∧ (G.cliqueNum : ℝ) ≤ ρ * a) ↔
      ((a : ℝ) ≤ ρ * PhiMax (S G) ∧ (PhiMax (S G) : ℝ) ≤ ρ * a) := by
  rw [phiMax_eq_cliqueNum G h2]

end IIT