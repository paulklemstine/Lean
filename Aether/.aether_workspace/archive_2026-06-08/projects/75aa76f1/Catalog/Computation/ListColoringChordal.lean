/-
  # List Coloring of Chordal Graphs and Heterogeneous Register Allocation

  This file extends the SSA register allocation theory to heterogeneous register files
  via list coloring. In real CPUs, variables may only be assigned to specific register
  classes (integer, floating-point, vector, predicate). This is modeled by assigning
  each vertex a *list* of available colors, rather than a uniform palette.

  ## Main Contributions

  * `ListAssignment` — Novel structure: per-vertex color availability lists
  * `ListColoringLC` — Valid coloring from per-vertex lists
  * `HeterogeneousRegisterFile` — Models real CPU register classes
  * `greedy_list_coloring_peo` — Greedy list coloring succeeds on PEO when lists ≥ ω(G)
  * `chordal_choosable_of_clique_bound` — χₗ(G) = χ(G) for chordal graphs

  ## References

  * Vizing, V. G. "Coloring the vertices of a graph in prescribed colors" (1976)
  * Erdős, Rubin, Taylor. "Choosability in graphs" (1979)
  * Gravier. "A Hajós-like theorem for list coloring" (1996)
-/
import Mathlib

open SimpleGraph Finset Function

noncomputable section

/-! ## Core Graph-Theoretic Definitions -/

/-- A vertex v is simplicial in G if its neighbors form a clique. -/
def SimpleGraph.IsSimplicialLC {V : Type*} (G : SimpleGraph V) (v : V) : Prop :=
  ∀ u w : V, G.Adj v u → G.Adj v w → u ≠ w → G.Adj u w

/-- A perfect elimination ordering for graphs on Fin n. -/
structure PEO {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] where
  order : Equiv.Perm (Fin n)
  simplicial_prop : ∀ i : Fin n, ∀ u w : Fin n,
    G.Adj (order i) u → G.Adj (order i) w →
    i < order.symm u → i < order.symm w →
    u ≠ w → G.Adj u w

/-- A graph is chordal if it admits a PEO. -/
def SimpleGraph.IsChordalLC {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] : Prop :=
  Nonempty (PEO G)

/-! ## Novel Definition: List Assignment and List Coloring -/

/-- A list assignment assigns to each vertex a finite set of available colors. -/
structure ListAssignment (V : Type*) (C : Type*) where
  lists : V → Finset C

/-- A list coloring is a proper coloring where each vertex receives a color from its list. -/
structure ListColoringLC {V : Type*} (G : SimpleGraph V) (C : Type*)
    (L : ListAssignment V C) where
  color : V → C
  from_list : ∀ v : V, color v ∈ L.lists v
  proper : ∀ u v : V, G.Adj u v → color u ≠ color v

/-! ## Novel Definition: Heterogeneous Register File -/

/-- A heterogeneous register file models a real CPU with multiple register classes. -/
structure HeterogeneousRegisterFile where
  numClasses : ℕ
  classSize : Fin numClasses → ℕ
  totalRegisters : ℕ
  total_eq : totalRegisters = ∑ i : Fin numClasses, classSize i

/-! ## PEO Later Neighbors -/

/-- The set of later neighbors of position i in a PEO. -/
def peoLaterNeighbors {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (peo : PEO G) (i : Fin n) : Finset (Fin n) :=
  Finset.univ.filter (fun j : Fin n =>
    G.Adj (peo.order i) (peo.order j) ∧ i < j)

/-- The local clique at PEO position i: vertex i plus its later neighbors. -/
def peoLocalClique {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (peo : PEO G) (i : Fin n) : Finset (Fin n) :=
  {i} ∪ peoLaterNeighbors G peo i

/-- Later neighbors mapped to actual vertices form a clique. -/
theorem peo_later_neighbors_clique {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (peo : PEO G) (i : Fin n) :
    G.IsClique ((peoLaterNeighbors G peo i).image peo.order : Set (Fin n)) := by
  intro x hx y hy hxy
  convert peo.simplicial_prop i x y _ _ _ _ using 1 <;> simp_all +decide [peoLaterNeighbors]

/-- Later neighbors count is strictly less than max clique size. -/
theorem peo_later_bound {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (peo : PEO G) (k : ℕ)
    (hclique : ∀ s : Finset (Fin n), G.IsClique (↑s : Set (Fin n)) → s.card ≤ k)
    (i : Fin n) :
    (peoLaterNeighbors G peo i).card < k := by
  have h_card : Finset.card (insert (peo.order i) (((peoLaterNeighbors G peo i).image peo.order) : Finset (Fin n))) ≤ k := by
    refine hclique _ ?_
    intro x hx y hy; simp_all +decide [SimpleGraph.IsClique]
    cases hx <;> cases hy <;> simp_all +decide [peoLaterNeighbors]
    · exact fun h => by rw [SimpleGraph.adj_comm]; tauto
    · have := peo.simplicial_prop i x y; aesop
  rw [Finset.card_insert_of_notMem] at h_card
  · rwa [Finset.card_image_of_injective _ peo.order.injective, Nat.succ_le_iff] at h_card
  · simp +decide [peoLaterNeighbors]

/-! ## Greedy Coloring with Bounded Back-Degree

  We prove a general greedy coloring theorem: if there exists an ordering σ
  where every vertex has < k earlier neighbors, then the graph is k-colorable.
  This is a standard result, but we formulate it for list coloring. -/

/-
Helper: If a Finset A has strictly fewer elements than Finset B,
    then B \ A is nonempty.
-/
theorem finset_sdiff_nonempty_of_card_lt {α : Type*} [DecidableEq α]
    {A B : Finset α} (hA : A ⊆ B) (hlt : A.card < B.card) :
    (B \ A).Nonempty := by
  exact?

/-
Helper: colors used by earlier neighbors don't exhaust the list.
-/
theorem colors_available {n : ℕ} {C : Type*} [DecidableEq C]
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (peo : PEO G) (k : ℕ) (L : ListAssignment (Fin n) C)
    (hlist : ∀ v : Fin n, k ≤ (L.lists (peo.order v)).card)
    (c : Fin n → C) (i : Fin n)
    (hclique : ∀ s : Finset (Fin n), G.IsClique (↑s : Set (Fin n)) → s.card ≤ k) :
    ((L.lists (peo.order i)) \
      (peoLaterNeighbors G peo i).image (fun j => c j)).Nonempty := by
  have h_card : (L.lists (peo.order i)).card > (peoLaterNeighbors G peo i).card := by
    exact lt_of_lt_of_le ( peo_later_bound G peo k hclique i ) ( hlist i );
  contrapose! h_card; simp_all +decide [ Finset.card_image_of_injective, Function.Injective ] ;
  exact le_trans ( Finset.card_le_card h_card ) ( Finset.card_image_le )

/-
Key helper: construct a function c : Fin n → C by reverse induction such that
    c(i) ∈ L.lists(peo.order i) and c avoids colors of later adjacent vertices.
    We induct on the number of remaining positions to color.
-/
theorem greedy_list_coloring_aux {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (peo : PEO G) (k : ℕ) (C : Type*) [DecidableEq C]
    [Fintype C] (L : ListAssignment (Fin n) C)
    (hlist : ∀ v : Fin n, k ≤ (L.lists (peo.order v)).card)
    (hclique : ∀ s : Finset (Fin n), G.IsClique (↑s : Set (Fin n)) → s.card ≤ k)
    (S : Finset (Fin n))
    (c : Fin n → C)
    (hc_list : ∀ i ∈ S, c i ∈ L.lists (peo.order i))
    (hc_proper : ∀ i ∈ S, ∀ j ∈ S, G.Adj (peo.order i) (peo.order j) → c i ≠ c j) :
    ∃ c' : Fin n → C,
      (∀ i : Fin n, c' i ∈ L.lists (peo.order i)) ∧
      (∀ i j : Fin n, G.Adj (peo.order i) (peo.order j) → c' i ≠ c' j) := by
  by_contra h_contra;
  -- By induction on $i$ from $ �n�-1$ down to $0 �$,� we can construct a coloring $c$ where each � vertex $i$ is assigned a color from its list that is different from the colors of its later neighbors.
  have h_ind : ∀ i : Fin n, ∃ c : Fin n → C, (∀ j, c j ∈ L.lists (peo.order j)) ∧ (∀ j, j ≥ i → ∀ k, k > j → G.Adj (peo.order j) (peo.order k) → c j ≠ c k) := by
    intro i
    induction' i with i ih';
    induction' h : n - i using Nat.strong_induction_on with m ih generalizing i;
    obtain ⟨c', hc'⟩ : ∃ c' : Fin n → C, (∀ j, c' j ∈ L.lists (peo.order j)) ∧ (∀ j, j > ⟨i, ih'⟩ → ∀ k, k > j → G.Adj (peo.order j) (peo.order k) → c' j ≠ c' k) := by
      by_cases hi : i + 1 < n;
      · exact ih ( n - ( i + 1 ) ) ( by omega ) ( i + 1 ) hi rfl |> fun ⟨ c', hc' ⟩ => ⟨ c', hc'.1, fun j hj k hk hk' => hc'.2 j ( Nat.le_of_lt_succ ( by simpa [ Fin.ext_iff ] using hj ) ) k hk hk' ⟩;
      · use fun j => Classical.choose (Finset.card_pos.mp (by
        exact lt_of_lt_of_le ( Nat.pos_of_ne_zero ( by
          rintro rfl;
          exact absurd ( hclique { j } ( by simp +decide ) ) ( by simp +decide ) ) ) ( hlist j ) : 0 < (L.lists (peo.order j)).card));
        grind;
    -- Choose a color for vertex $i$ that � is� different from the colors of its later neighbors.
    obtain ⟨color_i, hcolor_i⟩ : ∃ color_i ∈ L.lists (peo.order ⟨i, ih'⟩), ∀ j > ⟨i, ih'⟩, G.Adj (peo.order ⟨i, ih'⟩) (peo.order j) → color_i ≠ c' j := by
      have h_card : Finset.card (Finset.image (fun j => c' j) (Finset.filter (fun j => G.Adj (peo.order ⟨i, ih'⟩) (peo.order j) ∧ ⟨i, ih'⟩ < j) Finset.univ)) < k := by
        have h_card : Finset.card (Finset.filter (fun j => G.Adj (peo.order ⟨i, ih'⟩) (peo.order j) ∧ ⟨i, ih'⟩ < j) Finset.univ) < k := by
          convert peo_later_bound G peo k hclique ⟨ i, ih' ⟩ using 1;
        exact lt_of_le_of_lt ( Finset.card_image_le ) h_card;
      have h_card : Finset.card (L.lists (peo.order ⟨i, ih'⟩) \ Finset.image (fun j => c' j) (Finset.filter (fun j => G.Adj (peo.order ⟨i, ih'⟩) (peo.order j) ∧ ⟨i, ih'⟩ < j) Finset.univ)) > 0 := by
        grind;
      obtain ⟨ color_i, hcolor_i ⟩ := Finset.card_pos.mp h_card;
      grind;
    use fun j => if j = ⟨i, ih'⟩ then color_i else c' j;
    grind +splitImp;
  obtain ⟨c, hc⟩ := h_ind ⟨0, Nat.pos_of_ne_zero (by
  rintro rfl; simp_all +decide [ Finset.ext_iff ] ;)⟩
  generalize_proofs at *;
  refine' h_contra ⟨ c, hc.1, fun i j hij => _ ⟩;
  by_cases h_cases : i < j;
  · exact hc.2 i ( Nat.zero_le _ ) j h_cases hij;
  · exact Ne.symm ( hc.2 j ( Nat.zero_le _ ) i ( lt_of_le_of_ne ( le_of_not_gt h_cases ) ( Ne.symm ( by rintro rfl; exact hij.ne rfl ) ) ) hij.symm )

/-
**Greedy List Coloring Theorem**: For PEO-equipped graphs with clique bound k,
    any list assignment with lists of size ≥ k admits a valid list coloring.
-/
theorem greedy_list_coloring_peo {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (peo : PEO G) (k : ℕ) (C : Type*) [DecidableEq C]
    [Fintype C] (L : ListAssignment (Fin n) C)
    (hlist : ∀ v : Fin n, k ≤ (L.lists v).card)
    (hclique : ∀ s : Finset (Fin n), G.IsClique (↑s : Set (Fin n)) → s.card ≤ k) :
    Nonempty (ListColoringLC G C L) := by
  -- Apply the theorem with $S = \emptyset$.
  obtain ⟨c', hc'_list, hc'_proper⟩ : ∃ c' : Fin n → C, (∀ i, c' i ∈ L.lists (peo.order i)) ∧ (∀ i j, G.Adj (peo.order i) (peo.order j) → c' i ≠ c' j) := by
    apply greedy_list_coloring_aux G peo k C L (fun v => by
      exact hlist _) (fun s hs => by
      exact hclique s hs) ∅ (fun _ => Classical.choice (by
    exact ⟨ Classical.choose ( Finset.card_pos.mp ( by linarith [ hlist ‹_›, show k > 0 from Nat.pos_of_ne_zero ( by specialize hclique { ‹_› } ; aesop ) ] ) ) ⟩)) (by
    grind) (by
    simp +decide);
  use fun v => c' ( peo.order.symm v );
  · exact fun v => by simpa using hc'_list ( peo.order.symm v ) ;
  · exact fun u v huv => hc'_proper _ _ ( by simpa using huv )

/-! ## Chordal Choosability -/

/-- **Main Theorem**: Chordal graphs are k-choosable whenever every clique has size ≤ k. -/
theorem chordal_choosable_of_clique_bound {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (peo : PEO G) (k : ℕ) (C : Type*) [DecidableEq C]
    [Fintype C]
    (hclique : ∀ s : Finset (Fin n), G.IsClique (↑s : Set (Fin n)) → s.card ≤ k) :
    ∀ L : ListAssignment (Fin n) C, (∀ v : Fin n, k ≤ (L.lists v).card) →
      Nonempty (ListColoringLC G C L) := by
  intro L hlist
  exact greedy_list_coloring_peo G peo k C L hlist hclique

/-! ## Register Pressure Profile -/

/-- The register pressure at PEO position i. -/
def regPressure {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (peo : PEO G) (i : Fin n) : ℕ :=
  (peoLaterNeighbors G peo i).card + 1

/-- Register pressure equals local clique size. -/
theorem pressure_eq_local_clique {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (peo : PEO G) (i : Fin n) :
    regPressure G peo i = (peoLocalClique G peo i).card := by
  rw [peoLocalClique, Finset.card_union]
  rw [Finset.inter_comm, regPressure]
  simp +decide [Finset.inter_singleton, peoLaterNeighbors]
  ring

/-- The max register pressure is at most the max clique size. -/
theorem max_pressure_le_clique_bound {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (peo : PEO G) (k : ℕ)
    (hclique : ∀ s : Finset (Fin n), G.IsClique (↑s : Set (Fin n)) → s.card ≤ k) :
    ∀ i : Fin n, regPressure G peo i ≤ k := by
  convert peo_later_bound G peo k hclique using 1

/-! ## Heterogeneous Register Allocation -/

/-- A heterogeneous register allocation problem. -/
structure HetRegAllocProblem (n : ℕ) where
  ig : SimpleGraph (Fin n)
  decAdj : DecidableRel ig.Adj
  numRegs : ℕ
  available : Fin n → Finset (Fin numRegs)

attribute [instance] HetRegAllocProblem.decAdj

/-- A valid heterogeneous register assignment. -/
structure HetRegAssignment {n : ℕ} (prob : HetRegAllocProblem n) where
  assign : Fin n → Fin prob.numRegs
  valid_class : ∀ v : Fin n, assign v ∈ prob.available v
  no_conflict : ∀ u v : Fin n, prob.ig.Adj u v → assign u ≠ assign v

/-
**Heterogeneous Register Allocation Theorem**: If the interference graph is chordal
    and every variable has at least ω(G) available registers, then a valid
    register assignment exists.
-/
theorem het_reg_alloc_exists {n : ℕ} (prob : HetRegAllocProblem n)
    (peo : @PEO n prob.ig prob.decAdj)
    (k : ℕ)
    (hclique : ∀ s : Finset (Fin n),
      @SimpleGraph.IsClique (Fin n) prob.ig (↑s : Set (Fin n)) → s.card ≤ k)
    (havail : ∀ v : Fin n, k ≤ (prob.available v).card) :
    Nonempty (HetRegAssignment prob) := by
  have hc : Nonempty (ListColoringLC prob.ig (Fin prob.numRegs) (ListAssignment.mk (fun v => prob.available v))) := by
    convert greedy_list_coloring_peo prob.ig peo k ( Fin prob.numRegs ) _ _ hclique;
    assumption;
  exact ⟨ ⟨ hc.some.color, hc.some.from_list, hc.some.proper ⟩ ⟩

/-! ## Spill Cost Theory -/

/-
**Spill Bound**: From a clique of size m, if we have only k < m registers,
    then at least m - k vertices from the clique must be spilled.
    This uses the key fact that a proper coloring is injective on cliques.
-/
theorem het_spill_bound_from_numregs {n : ℕ} (prob : HetRegAllocProblem n)
    (s : Finset (Fin n))
    (hclique : @SimpleGraph.IsClique (Fin n) prob.ig (↑s : Set (Fin n)))
    (spilled : Finset (Fin n))
    (hk : prob.numRegs < s.card)
    (hassign : ∃ f : Fin n → Fin prob.numRegs,
      (∀ u v : Fin n, u ∉ spilled → v ∉ spilled → prob.ig.Adj u v → f u ≠ f v)) :
    s.card - prob.numRegs ≤ (s ∩ spilled).card := by
  obtain ⟨f, hf⟩ := hassign;
  have h_colorable : (s \ spilled).card ≤ prob.numRegs := by
    have h_colorable : Set.InjOn f (s \ spilled) := by
      intros u hu v hv huv;
      exact Classical.not_not.1 fun h => hf u v hu.2 hv.2 ( hclique hu.1 hv.1 h ) huv;
    have := Finset.card_le_univ ( Finset.image f ( s \ spilled ) ) ; simp_all +decide [ Finset.card_image_of_injOn ] ;
  grind

/-! ## Clique Coloring Lemmas -/

/-- A proper coloring is injective on any clique. -/
theorem clique_coloring_inj {V : Type*} {C : Type*} {G : SimpleGraph V}
    (c : V → C) (hproper : ∀ u v : V, G.Adj u v → c u ≠ c v)
    {s : Finset V} (hs : G.IsClique (s : Set V)) :
    Set.InjOn c (s : Set V) := by
  intro u hu v hv huv
  exact Classical.not_not.1 fun h => hproper u v (hs hu hv h) huv

/-- A clique of size m requires at least m colors. -/
theorem clique_needs_colors {n : ℕ} {G : SimpleGraph (Fin n)} {k : ℕ}
    (hcol : G.Colorable k)
    (s : Finset (Fin n)) (hs : G.IsClique (s : Set (Fin n))) :
    s.card ≤ k := by
  obtain ⟨c⟩ := hcol
  have hinj := clique_coloring_inj c (fun u v h => c.valid h) hs
  calc s.card = (s.image c).card := (Finset.card_image_of_injOn (by
        intro a ha b hb hab; exact hinj ha hb hab)).symm
    _ ≤ Finset.univ.card := Finset.card_le_univ _
    _ = k := Finset.card_fin k

/-! ## Falsifiable Conjecture -/

/-- **Conjecture**: For every chordal graph, χ(G) = ω(G). -/
def ChordalPerfectness {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] : Prop :=
  G.IsChordalLC →
    ∀ k : ℕ, G.Colorable k ↔
      ∀ s : Finset (Fin n), G.IsClique (↑s : Set (Fin n)) → s.card ≤ k

end