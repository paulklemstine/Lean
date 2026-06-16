/-
  # Functorial Edge Counts for Vietoris–Rips Graphs

  This file packages a small, finite-combinatorial API for counting the edges of the
  Vietoris–Rips 1-skeleton (`ripsGraph`) of a finite (pseudo)metric space.  It builds
  directly on `Catalog.Applications.PoincareData.MetricFiltration`, reusing the
  `ripsGraph` construction together with its filtration monotonicity lemma
  `ripsGraph_mono`.

  We count edges via the finite graph combinatorics already present in Mathlib:
  `SimpleGraph.edgeFinset` and finset cardinalities.  No `Sym2`-based hand-rolled
  counting or `Set.ncard` is introduced; the only appearance of `Sym2` is the standard
  edge-map `Sym2.map f` used to transport edges along a vertex map.

  ## Invariant

  For a finite metric space `α`, `edgeCount α r` is the number of edges of the Rips graph
  at scale `r`.  The two structural facts are:

  * **Monotonicity in the scale** — enlarging `r` only adds edges, so the count is
    nondecreasing.
  * **Domination under injective nonexpanding maps** — an injective, distance
    nonincreasing map `f : α → β` sends edges to edges injectively, so the source count
    is dominated by the target count.

  ## Main results

  * `edgeCount`                              — the number of Rips edges at scale `r`.
  * `ripsProfile`                            — the edge count as a function `ℝ → ℕ`.
  * `edgeCount_mono`                         — `r ≤ s → edgeCount α r ≤ edgeCount α s`.
  * `ripsProfile_monotone`                   — `Monotone (ripsProfile α)`.
  * `ripsGraph_adj_map`                      — edges map to edges under an injective
                                               nonexpanding map (adjacency form).
  * `edgeCount_le_of_injective_nonexpanding` — `edgeCount α r ≤ edgeCount β r`.
-/
import Catalog.Applications.PoincareData.MetricFiltration

open Finset Set

noncomputable section

/-! ## Edge counts and the Rips profile -/

/-- The number of edges of the Vietoris–Rips graph `ripsGraph α r` at scale `r`,
    counted via `SimpleGraph.edgeFinset`. -/
noncomputable def edgeCount (α : Type*) [Fintype α] [DecidableEq α] [PseudoMetricSpace α]
    (r : ℝ) : ℕ :=
  (ripsGraph α r).edgeFinset.card

/-- The **Rips edge-count profile** of a finite metric space: the edge count viewed as a
    function of the scale `r`. -/
noncomputable def ripsProfile (α : Type*) [Fintype α] [DecidableEq α] [PseudoMetricSpace α] :
    ℝ → ℕ :=
  fun r => edgeCount α r

/-! ## Monotonicity in the scale -/

/-- Enlarging the scale only adds edges, so the edge count is nondecreasing.
    The edge inclusion comes from `ripsGraph_mono` together with
    `SimpleGraph.edgeFinset_mono`. -/
theorem edgeCount_mono {α : Type*} [Fintype α] [DecidableEq α] [PseudoMetricSpace α]
    {r s : ℝ} (h : r ≤ s) : edgeCount α r ≤ edgeCount α s :=
  Finset.card_le_card (SimpleGraph.edgeFinset_mono (ripsGraph_mono h))

/-- Order-theoretic packaging of `edgeCount_mono`: the Rips profile is monotone. -/
theorem ripsProfile_monotone (α : Type*) [Fintype α] [DecidableEq α] [PseudoMetricSpace α] :
    Monotone (ripsProfile α) :=
  fun _ _ h => edgeCount_mono h

/-! ## Functoriality under injective nonexpanding maps -/

variable {α β : Type*} [Fintype α] [DecidableEq α] [PseudoMetricSpace α]
  [Fintype β] [DecidableEq β] [PseudoMetricSpace β]
  {f : α → β} {r : ℝ}

omit [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β] in
/-- An injective, distance nonincreasing map sends Rips edges to Rips edges: if
    `f` is injective and nonexpanding, then adjacency in `ripsGraph α r` is carried to
    adjacency in `ripsGraph β r`. -/
theorem ripsGraph_adj_map (hf_inj : Function.Injective f)
    (hf_nonexp : ∀ x y, dist (f x) (f y) ≤ dist x y) {x y : α}
    (h : (ripsGraph α r).Adj x y) : (ripsGraph β r).Adj (f x) (f y) :=
  ⟨fun he => h.1 (hf_inj he), le_trans (hf_nonexp x y) h.2⟩

/-- For an injective nonexpanding map `f : α → β`, the source edge count is dominated by
    the target edge count.  The induced edge map `Sym2.map f` sends edges to edges
    (`ripsGraph_adj_map`) and is injective (`Sym2.map.injective hf_inj`), so the
    cardinality comparison follows from `Finset.card_le_card_of_injOn`. -/
theorem edgeCount_le_of_injective_nonexpanding (hf_inj : Function.Injective f)
    (hf_nonexp : ∀ x y, dist (f x) (f y) ≤ dist x y) :
    edgeCount α r ≤ edgeCount β r := by
  unfold edgeCount
  apply Finset.card_le_card_of_injOn (Sym2.map f)
  · intro e he
    simp only [Finset.mem_coe, SimpleGraph.mem_edgeFinset] at he ⊢
    induction e with
    | h x y =>
      rw [Sym2.map_pair_eq, SimpleGraph.mem_edgeSet] at *
      exact ripsGraph_adj_map hf_inj hf_nonexp he
  · exact (Sym2.map.injective hf_inj).injOn

end