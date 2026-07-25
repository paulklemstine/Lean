import Mathlib

/-!
# The `3Δ−1` tightness conjecture for SD-EF1 allocations on conflict graphs

This file formalizes the mathematical framework underlying the *tightness conjecture* for
stochastic-dominance envy-free-up-to-one-good (**SD-EF1**) allocations of indivisible goods
subject to a **conflict graph**, and records what is actually provable about it.

## Model

Goods are the vertices of a `SimpleGraph G`.  An allocation to `k` agents is a coloring
`c : V → Fin k` assigning each good to an agent.

* **Conflict-free** (`ConflictFree`): adjacent goods go to different agents, i.e. `c` is a proper
  coloring of `G`.  (Each agent's bundle is an independent set.)
* **Common preferences / balanced bundles** (`Balanced`): with identical additive valuations
  every good is worth the same, so SD-EF1 is equivalent to the agents' bundle *sizes* differing by
  at most one.  This is exactly an **equitable coloring**.
* `HasSDEF1 G k` : there is a conflict-free, balanced allocation to `k` agents.
* `minAgentsForSDEF1 G` : the least number of agents admitting such an allocation.

## What is proved

* `hasSDEF1_card` / well-definedness: the singleton allocation (one agent per good) is always
  conflict-free and balanced, so `minAgentsForSDEF1` is finite.
* `completeGraph_maxDegree`, `completeGraph_minAgents`: the complete graph `K_{Δ+1}` has maximum
  degree `Δ` and `minAgentsForSDEF1 = Δ + 1`.
* `exists_graph_maxDegree_minAgents_eq_succ` (the honest **main theorem**): for every `Δ` there is
  a graph of maximum degree `Δ` requiring exactly `Δ + 1` agents.
* `star_minAgents_lower_bound` (verified **base case**): the star `K_{1,Δ}` requires at least
  `⌈(Δ+2)/2⌉ = (Δ+3)/2` agents.

## Status of the `3Δ−1` conjecture

The conjecture as originally stated,

  `exists_graph_with_max_degree_Δ_requiring_3Δminus1_agents :`
  `  ∀ Δ, ∃ G, maxDegree G = Δ ∧ minAgentsForSDEF1 G = 3Δ - 1`,

is **false** under the balanced-bundle (identical-valuations) reading that the prompt fixes.
Indeed, in this reading a conflict-free balanced allocation is precisely an *equitable coloring*,
and the Hajnal–Szemerédi theorem states that every graph of maximum degree `Δ` admits an equitable
coloring with `Δ + 1` colors.  Hence

  `minAgentsForSDEF1 G ≤ maxDegree G + 1`  for every finite graph `G`,

so no graph of maximum degree `Δ` can require `3Δ − 1` agents once `3Δ − 1 > Δ + 1`, i.e. for all
`Δ ≥ 2`.  Numerically `3Δ − 1` equals the true extremal value `Δ + 1` only at `Δ = 1`, and at
`Δ = 0` it evaluates (in `ℕ`) to `0 ≠ 1`.  The tight extremal value is therefore `Δ + 1`, achieved
by the complete graph `K_{Δ+1}`; this is the content of `exists_graph_maxDegree_minAgents_eq_succ`.

The same obstruction defeats the proposed multiplicative "blow-up" lower bound
(`BlowUp(G,m)` requiring `n·m` agents): for the complete graph this would force
`(Δ+1)·m` agents in a graph of maximum degree `Δ·m`, again exceeding `Δ·m + 1` for `m ≥ 2`.
What *is* true is the structural direction (`blowUp_induces_coloring`): a conflict-free allocation
of a blow-up induces a proper coloring of the base graph.  It simply does not multiply the agent
count, which is exactly why the conjecture over-counts.

The user's original statement is preserved (commented out) at the end of the file together with
this explanation.
-/

namespace SDEF1

open SimpleGraph Finset

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- An allocation `c : V → Fin k` is **conflict-free** if adjacent goods (vertices) are assigned
to different agents; equivalently `c` is a proper coloring of `G`. -/
def ConflictFree (G : SimpleGraph V) {k : ℕ} (c : V → Fin k) : Prop :=
  ∀ ⦃u v⦄, G.Adj u v → c u ≠ c v

/-- Size of agent `i`'s bundle under allocation `c`. -/
def classCard {k : ℕ} (c : V → Fin k) (i : Fin k) : ℕ :=
  (Finset.univ.filter fun v => c v = i).card

/-- Under identical valuations, SD-EF1 says the agents' bundle sizes differ by at most one. -/
def Balanced {k : ℕ} (c : V → Fin k) : Prop :=
  ∀ i j : Fin k, classCard c i ≤ classCard c j + 1

/-- `G` admits a conflict-free SD-EF1 (balanced) allocation to `k` agents. -/
def HasSDEF1 (G : SimpleGraph V) (k : ℕ) : Prop :=
  ∃ c : V → Fin k, ConflictFree G c ∧ Balanced c

omit [DecidableEq V] in
/-- An injective allocation is automatically balanced: every bundle has size at most one. -/
theorem injective_balanced {k : ℕ} {c : V → Fin k} (hc : Function.Injective c) : Balanced c := by
  have h1 : ∀ i, classCard c i ≤ 1 := by
    intro i
    rw [classCard, Finset.card_le_one]
    intro a ha b hb
    simp only [Finset.mem_filter] at ha hb
    exact hc (ha.2.trans hb.2.symm)
  intro i j
  exact (h1 i).trans (by omega)

omit [DecidableEq V] in
/-- The singleton allocation (one agent per good) is conflict-free and balanced, so it witnesses
`HasSDEF1 G (Fintype.card V)`. -/
theorem hasSDEF1_card (G : SimpleGraph V) : HasSDEF1 G (Fintype.card V) := by
  refine ⟨(Fintype.equivFin V), ?_, injective_balanced (Fintype.equivFin V).injective⟩
  intro u v huv h
  exact G.ne_of_adj huv ((Fintype.equivFin V).injective h)

omit [DecidableEq V] in
theorem hasSDEF1_nonempty (G : SimpleGraph V) : {k | HasSDEF1 G k}.Nonempty :=
  ⟨Fintype.card V, hasSDEF1_card G⟩

/-- The minimum number of agents admitting a conflict-free SD-EF1 allocation of `G`. -/
noncomputable def minAgentsForSDEF1 (G : SimpleGraph V) : ℕ :=
  sInf {k | HasSDEF1 G k}

omit [DecidableEq V] in
theorem minAgentsForSDEF1_le {G : SimpleGraph V} {k : ℕ} (h : HasSDEF1 G k) :
    minAgentsForSDEF1 G ≤ k :=
  Nat.sInf_le h

omit [DecidableEq V] in
/-- The defining allocation of `minAgentsForSDEF1 G` exists. -/
theorem hasSDEF1_minAgents (G : SimpleGraph V) : HasSDEF1 G (minAgentsForSDEF1 G) :=
  Nat.sInf_mem (hasSDEF1_nonempty G)

omit [DecidableEq V] in
/-- To prove a lower bound on `minAgentsForSDEF1 G`, it suffices to bound every feasible agent
count from below. -/
theorem le_minAgentsForSDEF1 {G : SimpleGraph V} {n : ℕ}
    (h : ∀ k, HasSDEF1 G k → n ≤ k) : n ≤ minAgentsForSDEF1 G :=
  h _ (hasSDEF1_minAgents G)

/-! ## The complete graph `K_{Δ+1}` -/

section Complete

/-- Every degree of the complete graph on `Fin (n+1)` equals `n`. -/
theorem completeGraph_degree (n : ℕ) (v : Fin (n + 1)) :
    (⊤ : SimpleGraph (Fin (n + 1))).degree v = n := by
  rw [SimpleGraph.degree]
  rw [show (⊤ : SimpleGraph (Fin (n + 1))).neighborFinset v = Finset.univ.erase v from ?_]
  · rw [Finset.card_erase_of_mem (Finset.mem_univ v), Finset.card_univ, Fintype.card_fin]; omega
  · ext w; simp [SimpleGraph.mem_neighborFinset, ne_comm]

theorem completeGraph_maxDegree (n : ℕ) :
    (⊤ : SimpleGraph (Fin (n + 1))).maxDegree = n := by
  refine le_antisymm ?_ ?_
  · exact SimpleGraph.maxDegree_le_of_forall_degree_le _ n (fun v => (completeGraph_degree n v).le)
  · calc n = (⊤ : SimpleGraph (Fin (n + 1))).degree 0 := (completeGraph_degree n 0).symm
      _ ≤ _ := SimpleGraph.degree_le_maxDegree _ 0

/-- Any conflict-free allocation of the complete graph is injective. -/
theorem completeGraph_conflictFree_injective {n k : ℕ} {c : Fin (n + 1) → Fin k}
    (hc : ConflictFree (⊤ : SimpleGraph (Fin (n + 1))) c) : Function.Injective c := by
  intro a b hab
  by_contra hne
  exact hc (by simpa [SimpleGraph.top_adj] using hne) hab

/-- The complete graph `K_{n+1}` requires at least `n + 1` agents. -/
theorem completeGraph_minAgents_ge (n : ℕ) :
    n + 1 ≤ minAgentsForSDEF1 (⊤ : SimpleGraph (Fin (n + 1))) := by
  apply le_minAgentsForSDEF1
  rintro k ⟨c, hcf, _⟩
  have hinj := completeGraph_conflictFree_injective hcf
  have := Fintype.card_le_of_injective c hinj
  simpa using this

/-- The complete graph `K_{n+1}` admits a conflict-free balanced allocation to `n + 1` agents. -/
theorem completeGraph_hasSDEF1 (n : ℕ) :
    HasSDEF1 (⊤ : SimpleGraph (Fin (n + 1))) (n + 1) := by
  refine ⟨id, ?_, injective_balanced Function.injective_id⟩
  intro u v huv h
  exact (G_ne huv) h
where
  G_ne : ∀ {u v : Fin (n+1)}, (⊤ : SimpleGraph (Fin (n+1))).Adj u v → u ≠ v :=
    fun h => (SimpleGraph.top_adj _ _).1 h

/-- **The complete graph `K_{Δ+1}` requires exactly `Δ + 1` agents.** -/
theorem completeGraph_minAgents (n : ℕ) :
    minAgentsForSDEF1 (⊤ : SimpleGraph (Fin (n + 1))) = n + 1 :=
  le_antisymm (minAgentsForSDEF1_le (completeGraph_hasSDEF1 n)) (completeGraph_minAgents_ge n)

end Complete

/-! ## Honest main theorem: the tight extremal value is `Δ + 1` -/

/-- **Corrected main theorem.**  For every `Δ` there is a finite graph of maximum degree `Δ`
requiring exactly `Δ + 1` agents for a conflict-free SD-EF1 allocation.  This is the tight
extremal value (Hajnal–Szemerédi gives the matching upper bound `minAgentsForSDEF1 ≤ Δ + 1`);
see the module docstring for why the originally-conjectured value `3Δ − 1` is unattainable for
`Δ ≥ 2`. -/
theorem exists_graph_maxDegree_minAgents_eq_succ (Δ : ℕ) :
    ∃ (G : SimpleGraph (Fin (Δ + 1))) (_ : DecidableRel G.Adj),
      G.maxDegree = Δ ∧ minAgentsForSDEF1 G = Δ + 1 :=
  ⟨⊤, inferInstance, completeGraph_maxDegree Δ, completeGraph_minAgents Δ⟩

/-! ## Verified base case: the star `K_{1,Δ}` -/

section Star

/-- The star `K_{1,Δ}` on `Fin (Δ+1)`: vertex `0` is the center, adjacent to every leaf, and the
leaves are pairwise non-adjacent. -/
def star (Δ : ℕ) : SimpleGraph (Fin (Δ + 1)) where
  Adj i j := i ≠ j ∧ (i = 0 ∨ j = 0)
  symm := by rintro i j ⟨h1, h2⟩; exact ⟨h1.symm, h2.symm⟩
  loopless := ⟨fun _ h => h.1 rfl⟩

instance (Δ : ℕ) : DecidableRel (star Δ).Adj := fun i j => by
  unfold star; infer_instance

/-- The star `K_{1,Δ}` has maximum degree `Δ`. -/
theorem star_maxDegree (Δ : ℕ) : (star Δ).maxDegree = Δ := by
  refine le_antisymm (SimpleGraph.maxDegree_le_of_forall_degree_le _ Δ ?_) ?_
  · intro v; rw [SimpleGraph.degree]
    exact Finset.card_le_card (show (star Δ).neighborFinset v ⊆ Finset.univ.erase v from
        fun x _ => Finset.mem_erase_of_ne_of_mem (by aesop) (Finset.mem_univ x)) |> le_trans <| by
      simp +decide [Finset.card_erase_of_mem]
  · refine le_trans ?_ (SimpleGraph.degree_le_maxDegree _ 0)
    simp +decide [SimpleGraph.degree, SimpleGraph.neighborFinset]
    simp +decide [star]
    rw [Finset.filter_ne]; aesop

/-- **Verified base case.** The star `K_{1,Δ}` requires at least `⌈(Δ+2)/2⌉ = (Δ+3)/2` agents for a
conflict-free SD-EF1 allocation. -/
theorem star_minAgents_lower_bound (Δ : ℕ) :
    (Δ + 3) / 2 ≤ minAgentsForSDEF1 (star Δ) := by
  -- Apply `le_minAgentsForSDEF1`. We need to show that for any `k` and `c` such that `HasSDEF1 (star Δ) k`, then `(Δ + 3) / 2 ≤ k`.
  apply le_minAgentsForSDEF1
  intro k
  rintro ⟨c, hcf, hbal⟩;
  -- Step 1: Show that the center color class has size 1.
  have h_center : (Finset.univ.filter (fun v => c v = c 0)).card = 1 := by
    refine' Finset.card_eq_one.mpr ⟨ 0, _ ⟩;
    ext v; specialize @hcf 0 v; simp_all +decide [ star ] ;
    grind;
  -- Step 2: Show that every color class has size at most 2.
  have h_class_size : ∀ i : Fin k, (Finset.univ.filter (fun v => c v = i)).card ≤ 2 := by
    intro i; exact (by
    exact le_trans ( hbal i ( c 0 ) ) ( by linarith! ));
  -- Step 3: Use the total count to derive the inequality.
  have h_total_count : ∑ i : Fin k, (Finset.univ.filter (fun v => c v = i)).card = Δ + 1 := by
    simp +decide only [card_filter];
    rw [ Finset.sum_comm ] ; aesop;
  rw [ Nat.div_le_iff_le_mul_add_pred ] <;> norm_num;
  have := Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ.erase ( c 0 ) ) => h_class_size i; simp_all +decide ;
  rw [ ← Finset.sum_erase_add _ _ ( Finset.mem_univ ( c 0 ) ), h_center ] at h_total_count ; linarith [ Nat.sub_add_cancel ( show 1 ≤ k from Fin.pos ( c 0 ) ) ]

end Star

/-! ## Graph blow-up: the honest structural direction

We include the blow-up operation and prove the *induced-coloring* direction (item (4) of the
prompt): a conflict-free allocation of the blow-up restricts to a proper coloring of the base
graph.  This is the true content behind the blow-up idea; it does **not** multiply the required
agent count (see the module docstring). -/

section BlowUp

variable {W : Type*} [Fintype W] [DecidableEq W]

/-- The `m`-fold blow-up of `G`: replace each vertex by an independent set of `m` copies, joining
two copies iff their base vertices are adjacent. -/
def BlowUp (G : SimpleGraph V) (m : ℕ) : SimpleGraph (V × Fin m) where
  Adj p q := G.Adj p.1 q.1
  symm := by rintro p q h; exact G.symm h
  loopless := ⟨fun _ h => G.irrefl h⟩

instance (G : SimpleGraph V) [DecidableRel G.Adj] (m : ℕ) :
    DecidableRel (BlowUp G m).Adj := fun p q => by unfold BlowUp; infer_instance

omit [Fintype V] [DecidableEq V] in
/-- A conflict-free allocation of `BlowUp G m` induces, via any fixed copy index, a proper coloring
of the base graph `G`.  (Structural direction of the blow-up argument.) -/
theorem blowUp_induces_coloring {G : SimpleGraph V} {m k : ℕ} (hm : 0 < m)
    {c : V × Fin m → Fin k} (hc : ConflictFree (BlowUp G m) c) :
    ConflictFree G (fun v => c (v, ⟨0, hm⟩)) := by
  intro u v huv h
  exact hc (show (BlowUp G m).Adj (u, ⟨0, hm⟩) (v, ⟨0, hm⟩) from huv) h

/-- The maximum degree of `BlowUp G m` is `m` times that of `G`. -/
theorem blowUp_maxDegree (G : SimpleGraph V) [DecidableRel G.Adj] (m : ℕ) :
    (BlowUp G m).maxDegree = G.maxDegree * m := by
  refine' le_antisymm ( SimpleGraph.maxDegree_le_of_forall_degree_le _ _ _ ) ( _ );
  · intro v
    have h_card : (BlowUp G m).degree v = G.degree v.1 * m := by
      convert Finset.card_product ( G.neighborFinset v.1 ) ( Finset.univ : Finset ( Fin m ) ) using 1;
      · refine' Finset.card_bij ( fun w hw => ( w.1, w.2 ) ) _ _ _ <;> simp +decide [ BlowUp ];
      · simp +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset ];
    exact h_card.symm ▸ Nat.mul_le_mul_right _ ( SimpleGraph.degree_le_maxDegree _ _ );
  · by_cases hm : 0 < m;
    · by_cases hV : Nonempty V;
      · obtain ⟨ v, hv ⟩ := G.exists_maximal_degree_vertex;
        refine' hv.symm ▸ le_trans _ ( SimpleGraph.degree_le_maxDegree _ ( v, ⟨ 0, hm ⟩ ) );
        simp +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset ];
        rw [ show ( Finset.univ.filter fun x : V × Fin m => ( BlowUp G m ).Adj ( v, ⟨ 0, hm ⟩ ) x ) = Finset.image ( fun x : V × Fin m => x ) ( Finset.filter ( fun x : V => G.Adj v x ) Finset.univ ×ˢ Finset.univ ) from ?_ ];
        · simp +decide;
        · ext ⟨ x, y ⟩ ; aesop;
      · simp_all +decide [ SimpleGraph.maxDegree ];
    · aesop

end BlowUp

/-!
## The original conjecture (preserved, commented out)

The prompt requested a proof of

```
theorem exists_graph_with_max_degree_Δ_requiring_3Δminus1_agents :
    ∀ Δ, ∃ G, maxDegree G = Δ ∧ minAgentsForSDEF1 G = 3 * Δ - 1
```

This statement is **false** in the balanced-bundle SD-EF1 model fixed by the prompt: a conflict-free
balanced allocation is an equitable coloring, and Hajnal–Szemerédi gives
`minAgentsForSDEF1 G ≤ maxDegree G + 1`, whereas `3Δ − 1 > Δ + 1` for every `Δ ≥ 2` (and at
`Δ = 0` the ℕ-value `3·0 − 1 = 0 ≠ 1`).  It agrees with the true extremal value `Δ + 1` only at
`Δ = 1`.  The corrected, provable statement is `exists_graph_maxDegree_minAgents_eq_succ` above.
-/

end SDEF1