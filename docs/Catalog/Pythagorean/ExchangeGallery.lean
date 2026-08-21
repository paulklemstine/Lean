/-
# The exchange metric on the chamber complex, its dual graph, and its f-vector

Cycle 2 of the single-voter exchange programme.  Building on
`Tropical/SocialChoice/{Chambers, ChamberComplex, SupportMatroid}.lean` and on
`Pythagorean/ExchangeLawSharp.lean`, we turn the exchange law into a *metric*
statement and read off the combinatorial invariants of the complex.

## The exchange metric

Fix a profile `x` sitting in the *open* chamber of the incumbent `i`, i.e.
`decisiveSet x = {i}`, and consider *downward* moves `y ≤ x` (a coalition of
voters lowers its scores; the others are untouched).  Call the set `D` of voters
that actually move the *exchange support* of the move.

* `decisiveSet_subset_of_le`: after a downward move, the decisive coalition is
  contained in `D ∪ decisiveSet x` — no voter outside the moving coalition can
  become decisive out of nowhere.
* `exchange_lower_bound`: to land in the cell labelled `T`, every voter of
  `T \ {i}` must move.
* `exchange_upper_bound`: and moving exactly the voters of `T \ {i}` suffices.
* `exchange_distance`: hence the **exchange distance from the chamber of `i` to
  the cell `T` is exactly `|T \ {i}|`** — an `IsLeast` statement, i.e. a sharp
  optimum, not just a pair of inequalities.
* `exchange_distance_eq_codim`: for a face `T` of the chamber of `i` this common
  value is `|T| - 1`, which by `SupportMatroid.finrank_cellDirection` is exactly
  the *codimension* of the cell.  Combinatorial distance = geometric
  codimension.

## The dual graph

* `exchangeGraph`, `exchangeGraph_eq_top`, `exchangeGraph_connected`,
  `exchangeGraph_isClique`: the graph on the support whose edges are the pairs
  of chambers separated by a wall is the *complete* graph; the complex is
  gallery-connected of diameter one.

## The f-vector and the Euler characteristic

* `card_labels_of_card`: the cells of codimension `d` are counted by
  `choose |S| (d+1)`.
* `card_cells`: the complex has exactly `2 ^ |S| - 1` cells.
* `euler_characteristic_eq_one`: the alternating sum of the f-vector is `1`:
  the chamber complex is Euler-contractible, as it must be, being a fan.

## Boundary

* `exchange_lower_bound_fails_for_raises`: an explicit two-voter example showing
  that the lower bound of the exchange metric really needs the moves to be
  downward — an upward move of the incumbent's own score changes the winner
  without touching the winner.
-/
import Mathlib
import Tropical.SocialChoice.SupportMatroid
import Pythagorean.ExchangeLawSharp

namespace PythagoreanExchangeGallery

open Finset TropicalChambers TropicalChamberComplex TropicalSupportMatroid
open PythagoreanExchangeLaw

variable {ι : Type*}

/-! ## Downward moves and the exchange metric -/

/-- **Locality of downward moves.**  If `y` is obtained from `x` by lowering the
scores of the voters in `D` only, then every voter decisive at `y` either moved
or was already decisive at `x`. -/
theorem decisiveSet_subset_of_le [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ)
    {x y : ι → ℝ} {D : Finset ι} (hle : ∀ k, y k ≤ x k) (hoff : ∀ k ∉ D, y k = x k) :
    decisiveSet S hS δ y ⊆ D ∪ decisiveSet S hS δ x := by
  classical
  intro m hm
  by_cases hmD : m ∈ D
  · exact Finset.mem_union_left _ hmD
  refine Finset.mem_union_right _ ?_
  obtain ⟨hmS, hmval⟩ := mem_decisiveSet_iff.mp hm
  have hagg : tropAgg S hS δ y ≤ tropAgg S hS δ x := tropAgg_mono hS δ hle
  have hxm : y m = x m := hoff m hmD
  have hge : tropAgg S hS δ x ≤ x m + δ m := Finset.inf'_le (fun n => x n + δ n) hmS
  rw [hxm] at hmval
  exact mem_decisiveSet_iff.mpr ⟨hmS, le_antisymm (by linarith) hge⟩

/-- **Lower bound for the exchange metric.**  Starting from the open chamber of
`i`, any downward move landing in the cell labelled `T` must move every voter of
`T \ {i}`. -/
theorem exchange_lower_bound [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ)
    {x y : ι → ℝ} {i : ι} {D T : Finset ι} (hxi : decisiveSet S hS δ x = {i})
    (hle : ∀ k, y k ≤ x k) (hoff : ∀ k ∉ D, y k = x k) (hy : decisiveSet S hS δ y = T) :
    T.erase i ⊆ D := by
  classical
  intro m hm
  obtain ⟨hmi, hmT⟩ := Finset.mem_erase.mp hm
  have := decisiveSet_subset_of_le hS δ (D := D) hle hoff (by rw [hy]; exact hmT)
  rcases Finset.mem_union.mp this with h | h
  · exact h
  · rw [hxi, Finset.mem_singleton] at h
    exact absurd h hmi

/-- **Upper bound for the exchange metric.**  Moving exactly the voters of
`T \ {i}` downwards suffices to reach the cell labelled `T`. -/
theorem exchange_upper_bound [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ)
    {x : ι → ℝ} {i : ι} {T : Finset ι} (hxi : decisiveSet S hS δ x = {i})
    (hTS : T ⊆ S) (hT : T.Nonempty) :
    ∃ y : ι → ℝ, (∀ k, y k ≤ x k) ∧ (∀ k ∉ T.erase i, y k = x k) ∧
      decisiveSet S hS δ y = T := by
  classical
  have hi : i ∈ decisiveSet S hS δ x := by rw [hxi]; exact Finset.mem_singleton_self i
  have hx : x ∈ chamber S δ i := (mem_decisiveSet_iff_mem_chamber.mp hi).2
  by_cases hiT : i ∈ T
  · refine ⟨coalitionExchange δ x i (T.erase i) 0, ?_, ?_, ?_⟩
    · intro k
      by_cases hk : k ∈ T.erase i
      · have hmono := coalitionExchange_monomial (δ := δ) (x := x) (i := i) (T := T.erase i)
          (ε := 0) hk
        have hchamber := hx k (hTS (Finset.mem_of_mem_erase hk))
        linarith
      · rw [coalitionExchange_eq_of_notMem hk]
    · intro k hk
      exact coalitionExchange_eq_of_notMem hk
    · rw [decisiveSet_coalitionExchange_wall hS δ (hTS hiT) hx
        ((Finset.erase_subset _ _).trans hTS), hxi]
      ext k
      simp only [Finset.mem_union, Finset.mem_erase, Finset.mem_singleton]
      constructor
      · rintro (⟨-, hk⟩ | rfl) <;> [exact hk; exact hiT]
      · intro hk
        by_cases hki : k = i
        · exact Or.inr hki
        · exact Or.inl ⟨hki, hk⟩
  · refine ⟨coalitionExchange δ x i T 1, ?_, ?_, ?_⟩
    · intro k
      by_cases hk : k ∈ T
      · have hmono := coalitionExchange_monomial (δ := δ) (x := x) (i := i) (T := T)
          (ε := 1) hk
        have hchamber := hx k (hTS hk)
        linarith
      · rw [coalitionExchange_eq_of_notMem hk]
    · intro k hk
      rw [Finset.erase_eq_of_notMem hiT] at hk
      exact coalitionExchange_eq_of_notMem hk
    · exact decisiveSet_coalitionExchange hS δ hx hTS hT one_pos

/-- **The exchange distance.**  From a profile in the open chamber of `i`, the
minimal number of voters whose scores must be lowered in order to reach the cell
labelled `T` is exactly `|T \ {i}|`.  (`IsLeast`: the value is attained *and* is
a lower bound.) -/
theorem exchange_distance [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ)
    {x : ι → ℝ} {i : ι} {T : Finset ι} (hxi : decisiveSet S hS δ x = {i})
    (hTS : T ⊆ S) (hT : T.Nonempty) :
    IsLeast {n : ℕ | ∃ (D : Finset ι) (y : ι → ℝ), D.card = n ∧ (∀ k, y k ≤ x k) ∧
      (∀ k ∉ D, y k = x k) ∧ decisiveSet S hS δ y = T} (T.erase i).card := by
  classical
  constructor
  · obtain ⟨y, hle, hoff, hy⟩ := exchange_upper_bound hS δ hxi hTS hT
    exact ⟨T.erase i, y, rfl, hle, hoff, hy⟩
  · rintro n ⟨D, y, rfl, hle, hoff, hy⟩
    exact Finset.card_le_card (exchange_lower_bound hS δ hxi hle hoff hy)

/-- **Exchange distance equals codimension.**  If the cell `T` is a face of the
chamber of the incumbent `i` (that is, `i ∈ T`), the exchange distance to it is
`|T| - 1`, which by `finrank_cellDirection` is exactly the codimension of the
cell in profile space. -/
theorem exchange_distance_eq_codim [Fintype ι] [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty)
    (δ : ι → ℝ) {x : ι → ℝ} {i : ι} {T : Finset ι} (hxi : decisiveSet S hS δ x = {i})
    (hTS : T ⊆ S) (hiT : i ∈ T) :
    IsLeast {n : ℕ | ∃ (D : Finset ι) (y : ι → ℝ), D.card = n ∧ (∀ k, y k ≤ x k) ∧
      (∀ k ∉ D, y k = x k) ∧ decisiveSet S hS δ y = T}
      (Fintype.card ι - Module.finrank ℝ (cellDirection (ι := ι) T)) := by
  classical
  have hT : T.Nonempty := ⟨i, hiT⟩
  have hrank := finrank_cellDirection (ι := ι) (T := T) hT
  have hcard : (T.erase i).card = Fintype.card ι - Module.finrank ℝ (cellDirection (ι := ι) T) := by
    rw [Finset.card_erase_of_mem hiT]
    omega
  rw [← hcard]
  exact exchange_distance hS δ hxi hTS hT

/-! ## The dual graph of the complex -/

/-- The dual graph of the top-dimensional cells: two voters of the support are
adjacent when the corresponding chambers share a wall, i.e. when `{i, j}` occurs
as a cell label. -/
noncomputable def exchangeGraph [DecidableEq ι] (S : Finset ι) (hS : S.Nonempty) (δ : ι → ℝ) :
    SimpleGraph {i : ι // i ∈ S} where
  Adj u v := u ≠ v ∧ ∃ x : ι → ℝ, decisiveSet S hS δ x = {u.1, v.1}
  symm := by
    rintro u v ⟨huv, x, hx⟩
    exact ⟨huv.symm, x, by rw [hx, Finset.pair_comm]⟩
  loopless := ⟨fun _ h => h.1 rfl⟩

/-- **The dual graph is complete.**  Any two chambers of the complex are
separated by a wall, so the exchange graph is the complete graph on the
support. -/
theorem exchangeGraph_eq_top [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ) :
    exchangeGraph S hS δ = ⊤ := by
  classical
  ext u v
  rw [SimpleGraph.top_adj]
  constructor
  · rintro ⟨h, -⟩; exact h
  · intro huv
    refine ⟨huv, ?_⟩
    exact exists_decisiveSet_pair hS δ u.2 v.2

/-- The complex is gallery-connected: one can pass from any chamber to any other
through walls. -/
theorem exchangeGraph_connected [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ) :
    (exchangeGraph S hS δ).Connected := by
  have : Nonempty {i : ι // i ∈ S} := ⟨⟨hS.choose, hS.choose_spec⟩⟩
  rw [exchangeGraph_eq_top hS δ]
  exact SimpleGraph.connected_top

/-- Every set of chambers is pairwise adjacent: the dual graph is one big
clique, so the gallery diameter of the complex is one. -/
theorem exchangeGraph_isClique [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ) :
    (exchangeGraph S hS δ).IsClique Set.univ := by
  intro u _ v _ huv
  rw [exchangeGraph_eq_top hS δ, SimpleGraph.top_adj]
  exact huv

/-! ## Counting the cells: the f-vector and the Euler characteristic -/

open scoped Classical in
/-- The labels of the complex: the nonempty subcoalitions of the support. -/
noncomputable def cellLabels (S : Finset ι) : Finset (Finset ι) :=
  S.powerset.filter fun T => T.Nonempty

open scoped Classical in
lemma mem_cellLabels {S T : Finset ι} : T ∈ cellLabels S ↔ T ⊆ S ∧ T.Nonempty := by
  simp [cellLabels, Finset.mem_powerset]

/-- **The `f`-vector.**  The cells of codimension `d` — those whose label has
`d + 1` voters — are counted by the binomial coefficient `choose |S| (d+1)`. -/
theorem card_labels_of_card [DecidableEq ι] {S : Finset ι} (d : ℕ) :
    ((cellLabels S).filter fun T => T.card = d + 1).card = S.card.choose (d + 1) := by
  classical
  have : ((cellLabels S).filter fun T => T.card = d + 1) = S.powersetCard (d + 1) := by
    ext T
    simp only [Finset.mem_filter, mem_cellLabels, Finset.mem_powersetCard]
    constructor
    · rintro ⟨⟨hTS, -⟩, hcard⟩; exact ⟨hTS, hcard⟩
    · rintro ⟨hTS, hcard⟩
      exact ⟨⟨hTS, Finset.card_pos.mp (by omega)⟩, hcard⟩
  rw [this, Finset.card_powersetCard]

/-- **The number of cells.**  The complex of decisive coalitions has exactly
`2 ^ |S| - 1` cells, one for each nonempty subcoalition of the support. -/
theorem card_cellLabels [DecidableEq ι] {S : Finset ι} :
    (cellLabels S).card = 2 ^ S.card - 1 := by
  classical
  have hsplit : (cellLabels S).card + 1 = S.powerset.card := by
    have hcompl : (S.powerset.filter fun T => ¬ T.Nonempty) = {∅} := by
      ext T
      simp only [Finset.mem_filter, Finset.mem_powerset, Finset.mem_singleton,
        Finset.not_nonempty_iff_eq_empty]
      constructor
      · rintro ⟨-, h⟩; exact h
      · rintro rfl; exact ⟨Finset.empty_subset _, rfl⟩
    have := Finset.card_filter_add_card_filter_not
      (s := S.powerset) (p := fun T => T.Nonempty)
    rw [hcompl] at this
    simpa [cellLabels] using this
  rw [Finset.card_powerset] at hsplit
  omega

open scoped Classical in
/-- **The cells are in bijection with their labels**, so the geometric cells are
also `2 ^ |S| - 1` in number. -/
theorem card_cells [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ) :
    ((cellLabels S).image (closedCell S hS δ)).card = 2 ^ S.card - 1 := by
  classical
  rw [Finset.card_image_of_injOn, card_cellLabels]
  intro T hT T' hT' h
  obtain ⟨hTS, hTne⟩ := mem_cellLabels.mp hT
  obtain ⟨hT'S, hT'ne⟩ := mem_cellLabels.mp hT'
  exact closedCell_injOn hS δ hTS hTne hT'S hT'ne h

/-- **Euler contractibility.**  The alternating sum of the `f`-vector of the
chamber complex is `1`: summing `(-1)^{codim}` over all cells gives the Euler
characteristic of a point.  (Equivalently, the complex is a complete fan.) -/
theorem euler_characteristic_eq_one [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty) :
    ∑ T ∈ cellLabels S, (-1 : ℤ) ^ (T.card + 1) = 1 := by
  classical
  have hfull : ∑ T ∈ S.powerset, (-1 : ℤ) ^ T.card = 0 := by
    rw [Finset.sum_powerset_neg_one_pow_card, if_neg (Finset.nonempty_iff_ne_empty.mp hS)]
  have hsplit : ∑ T ∈ S.powerset.filter (fun T => T.Nonempty), (-1 : ℤ) ^ T.card
      + ∑ T ∈ S.powerset.filter (fun T => ¬ T.Nonempty), (-1 : ℤ) ^ T.card
      = ∑ T ∈ S.powerset, (-1 : ℤ) ^ T.card :=
    Finset.sum_filter_add_sum_filter_not _ _ _
  have hcompl : (S.powerset.filter fun T => ¬ T.Nonempty) = {∅} := by
    ext T
    simp only [Finset.mem_filter, Finset.mem_powerset, Finset.mem_singleton,
      Finset.not_nonempty_iff_eq_empty]
    constructor
    · rintro ⟨-, h⟩; exact h
    · rintro rfl; exact ⟨Finset.empty_subset _, rfl⟩
  rw [hcompl, hfull] at hsplit
  simp only [Finset.sum_singleton, Finset.card_empty, pow_zero] at hsplit
  have hneg : ∑ T ∈ cellLabels S, (-1 : ℤ) ^ (T.card + 1)
      = - ∑ T ∈ S.powerset.filter (fun T => T.Nonempty), (-1 : ℤ) ^ T.card := by
    rw [← Finset.sum_neg_distrib]
    refine Finset.sum_congr rfl ?_
    intro T _
    rw [pow_succ]
    ring
  rw [hneg]
  omega

/-! ## Boundary of the exchange metric: downwardness is essential

The lower bound `exchange_lower_bound` — every voter of `T \ {i}` must move —
uses that the move is *downward*.  The following explicit two-voter example shows
the statement is false without that hypothesis: raising the *incumbent's own*
score hands the victory to the other voter without touching it, so the moving
set `{0}` is disjoint from `T \ {i} = {1}`. -/

/-- The min-plus aggregator of two voters is the minimum of the two monomials. -/
theorem tropAgg_fin_two (δ x : Fin 2 → ℝ) :
    tropAgg (Finset.univ : Finset (Fin 2)) ⟨0, Finset.mem_univ 0⟩ δ x
      = min (x 0 + δ 0) (x 1 + δ 1) := by
  refine le_antisymm (le_min ?_ ?_) ?_
  · exact Finset.inf'_le (fun k => x k + δ k) (Finset.mem_univ 0)
  · exact Finset.inf'_le (fun k => x k + δ k) (Finset.mem_univ 1)
  · refine Finset.le_inf' _ _ ?_
    intro k _
    fin_cases k
    · exact min_le_left _ _
    · exact min_le_right _ _

/-- **The downwardness hypothesis in `exchange_lower_bound` cannot be dropped.**
With two voters of weights `0` and `1`, raising the score of the incumbent
voter `0` alone moves the profile from the cell `{0}` to the cell `{1}`, even
though voter `1` — the whole of `T \ {i}` — never moves. -/
theorem exchange_lower_bound_fails_for_raises :
    ∃ (δ x y : Fin 2 → ℝ) (D : Finset (Fin 2)),
      decisiveSet Finset.univ ⟨0, Finset.mem_univ 0⟩ δ x = {0} ∧
      decisiveSet Finset.univ ⟨0, Finset.mem_univ 0⟩ δ y = {1} ∧
      (∀ k ∉ D, y k = x k) ∧ (∀ k, x k ≤ y k) ∧
      ¬ (({1} : Finset (Fin 2)).erase 0 ⊆ D) := by
  classical
  refine ⟨![0, 1], ![0, 0], ![2, 0], {0}, ?_, ?_, ?_, ?_, ?_⟩
  · ext k
    rw [mem_decisiveSet_iff, tropAgg_fin_two]
    fin_cases k <;> norm_num
  · ext k
    rw [mem_decisiveSet_iff, tropAgg_fin_two]
    fin_cases k <;> norm_num
  · intro k hk
    fin_cases k
    · exact absurd (Finset.mem_singleton_self 0) hk
    · rfl
  · intro k
    fin_cases k <;> norm_num
  · intro hsub
    have : (1 : Fin 2) ∈ ({0} : Finset (Fin 2)) := hsub (by decide)
    exact absurd (Finset.mem_singleton.mp this) (by decide)

end PythagoreanExchangeGallery