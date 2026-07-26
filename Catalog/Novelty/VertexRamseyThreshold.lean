/-
# The exact vertex-Ramsey threshold for complete host graphs

This file develops the deterministic combinatorial core underlying the
*vertex-Ramsey property* studied in the random-perturbation model of
Łuczak–Ruciński–Voigt (1993), Kreuter (1996) and Das–Morris–Treglown (2020).

Given a finite palette of colours `κ` and target clique sizes `s : κ → ℕ`, we
say a graph `G` **vertex-arrows** `s`, written `G →_v (K_{s i})_{i}`, if every
`κ`-colouring of `V(G)` produces some colour `i` together with a `G`-clique on
`s i` vertices, all coloured `i`.  (Taking `s i = ω(H i)` recovers the
clique-based reduction of the general `(H₁,…,H_r)_v`-Ramsey property, since a
monochromatic `H i` forces a monochromatic clique of size `ω(H i)` and, for the
complete host, conversely.)

## Main results

* `VertexRamsey.vertexArrows_of_isClique` — a purely combinatorial sufficient
  condition: if `G` contains a clique on more than `∑ i, (s i - 1)` vertices
  then `G →_v (K_{s i})_i`.
* `VertexRamsey.completeGraph_vertexArrows` /
  `VertexRamsey.completeGraph_not_vertexArrows` — the two directions of the
  **exact threshold** on the complete graph `Kₙ`.
* `VertexRamsey.completeGraph_vertexArrows_iff` — the sharp characterisation
  `Kₙ →_v (K_{s i})_i  ↔  ∑ i, (s i - 1) < n` (for `s i ≥ 1`).  Equivalently the
  vertex-Ramsey number of the clique family is `1 + ∑ i (s i - 1)`.
* `VertexRamsey.VertexArrows.mono_graph`, `VertexRamsey.VertexArrows.mono_size`
  — monotonicity in the host graph and in the target sizes.
* `VertexRamsey.exists_bounded_coloring` — the extremal colouring used for the
  lower bound (a capacity-respecting colouring exists whenever the total
  capacity is large enough), proved via an embedding into a sigma type.
* `VertexRamsey.edge_ramsey_iff` and the concrete instances afterwards — the
  `r`-colour "monochromatic edge" specialisation `s ≡ 2`, whose threshold
  `Kₙ →_v (K₂,…,K₂)  ↔  r < n` is the classical pigeonhole statement.

## A remark on the conjectured density threshold

The random-perturbation conjecture is phrased with the *product*
`ψ = ∏_j (ω(H j) - 1)` and density `1 - 1/ψ` (a Turán / edge-density parameter).
The results here isolate the *vertex* side, where the governing quantity is the
**sum** `∑_j (ω(H j) - 1)`: the vertex-Ramsey number of a clique family is
`1 + ∑_j (ω(H j) - 1)`.  This sum-versus-product distinction is recorded in
`FUTURE_DIRECTIONS.md`.
-/
import Mathlib

open Finset

namespace VertexRamsey

variable {V : Type*} {κ : Type*}

/-- `VertexArrows G s` is the vertex-Ramsey property `G →_v (K_{s i})_i`: every
`κ`-colouring `c` of the vertices of `G` admits a colour `i` and a `G`-clique
`S` of exactly `s i` vertices, all coloured `i`. -/
def VertexArrows (G : SimpleGraph V) (s : κ → ℕ) : Prop :=
  ∀ c : V → κ, ∃ (i : κ) (S : Finset V),
    (∀ v ∈ S, c v = i) ∧ S.card = s i ∧ G.IsClique (S : Set V)

/-- Monotonicity in the host graph: adding edges preserves the vertex-Ramsey
property. -/
theorem VertexArrows.mono_graph {G G' : SimpleGraph V} {s : κ → ℕ}
    (h : VertexArrows G s) (hGG' : G ≤ G') : VertexArrows G' s := by
  intro c
  obtain ⟨i, S, hS, hcard, hclique⟩ := h c
  exact ⟨i, S, hS, hcard, hclique.mono hGG'⟩

/-- Monotonicity in the target sizes: shrinking the required cliques preserves
the vertex-Ramsey property. -/
theorem VertexArrows.mono_size {G : SimpleGraph V} {s t : κ → ℕ}
    (h : VertexArrows G s) (hts : ∀ i, t i ≤ s i) : VertexArrows G t := by
  intro c
  obtain ⟨i, S, hS, hcard, hclique⟩ := h c
  obtain ⟨T, hTS, hTcard⟩ :=
    Finset.exists_subset_card_eq (n := t i) (by rw [hcard]; exact hts i)
  exact ⟨i, T, fun v hv => hS v (hTS hv), hTcard,
    hclique.subset (Finset.coe_subset.mpr hTS)⟩

/-- **Generalised pigeonhole.** If a finset `A` has more than `∑ i, (s i - 1)`
elements then any colouring `c` has a colour class inside `A` of size at least
`s i`. -/
theorem exists_large_fiber_finset [Fintype κ] [DecidableEq κ] [DecidableEq V]
    {s : κ → ℕ} {A : Finset V} (h : ∑ i, (s i - 1) < A.card) (c : V → κ) :
    ∃ i, s i ≤ (A.filter (fun v => c v = i)).card := by
  by_contra hcon
  push_neg at hcon
  have hcard : A.card = ∑ i, (A.filter (fun v => c v = i)).card :=
    Finset.card_eq_sum_card_fiberwise (fun v _ => mem_univ (c v))
  have : A.card ≤ ∑ i, (s i - 1) := by
    rw [hcard]; apply Finset.sum_le_sum; intro i _; have := hcon i; omega
  omega

/-- **Clique sufficient condition.** If `G` contains a clique on more than
`∑ i, (s i - 1)` vertices, then `G →_v (K_{s i})_i`.  This is the general
positive direction: everything else in the file specialises it. -/
theorem vertexArrows_of_isClique [Fintype κ] [DecidableEq κ] [DecidableEq V]
    {G : SimpleGraph V} {s : κ → ℕ} {K : Finset V}
    (hK : G.IsClique (K : Set V)) (hcard : ∑ i, (s i - 1) < K.card) :
    VertexArrows G s := by
  intro c
  obtain ⟨i, hi⟩ := exists_large_fiber_finset hcard c
  obtain ⟨S, hSsub, hScard⟩ := Finset.exists_subset_card_eq hi
  refine ⟨i, S, ?_, hScard, ?_⟩
  · intro v hv; have := hSsub hv; simp only [mem_filter] at this; exact this.2
  · have hSK : S ⊆ K := Finset.Subset.trans hSsub (Finset.filter_subset _ _)
    exact hK.subset (Finset.coe_subset.mpr hSK)

/-- Positive threshold on the complete graph: `Kₙ →_v (K_{s i})_i` whenever
`∑ i, (s i - 1) < n`. -/
theorem completeGraph_vertexArrows [Fintype V] [Fintype κ] [DecidableEq κ]
    [DecidableEq V] {s : κ → ℕ} (h : ∑ i, (s i - 1) < Fintype.card V) :
    VertexArrows (⊤ : SimpleGraph V) s := by
  apply vertexArrows_of_isClique (K := (univ : Finset V))
  · intro a _ b _ hab; exact hab
  · rwa [Finset.card_univ]

/-- **Capacity-respecting colouring.** If the total capacity `∑ i, cap i` is at
least `|V|`, there is a colouring with every colour class `i` of size at most
`cap i`.  Proved by embedding `V` into the disjoint union `Σ i, Fin (cap i)` and
reading off the first coordinate. -/
theorem exists_bounded_coloring [Fintype V] [Fintype κ] [DecidableEq κ]
    {cap : κ → ℕ} (h : Fintype.card V ≤ ∑ i, cap i) :
    ∃ c : V → κ, ∀ i, (univ.filter (fun v => c v = i)).card ≤ cap i := by
  have hcard : Fintype.card V ≤ Fintype.card ((i : κ) × Fin (cap i)) := by
    rw [Fintype.card_sigma]; simpa using h
  obtain ⟨f⟩ := Function.Embedding.nonempty_of_card_le hcard
  refine ⟨fun v => (f v).1, fun i => ?_⟩
  have hcapcard :
      (univ.filter (fun p : (j : κ) × Fin (cap j) => p.1 = i)).card = cap i := by
    have hset : (univ.filter (fun p : (j : κ) × Fin (cap j) => p.1 = i))
        = (univ : Finset (Fin (cap i))).map ⟨Sigma.mk i, sigma_mk_injective⟩ := by
      ext p
      simp only [mem_filter, mem_univ, true_and, mem_map, Function.Embedding.coeFn_mk]
      constructor
      · intro hp; subst hp; exact ⟨p.2, rfl⟩
      · rintro ⟨k, _, rfl⟩; rfl
    rw [hset, Finset.card_map, Finset.card_univ, Fintype.card_fin]
  calc (univ.filter (fun v => (f v).1 = i)).card
      ≤ (univ.filter (fun p : (j : κ) × Fin (cap j) => p.1 = i)).card := by
        apply Finset.card_le_card_of_injOn f
        · intro v hv
          simp only [coe_filter, mem_univ, true_and, Set.mem_setOf_eq] at hv ⊢
          exact hv
        · intro a _ b _ hab; exact f.injective hab
    _ = cap i := hcapcard

/-- Sharpness / lower bound on the complete graph: if `∑ i, (s i - 1) ≥ n`
(and each `s i ≥ 1`), then `Kₙ` does **not** vertex-arrow `(K_{s i})_i`; the
extremal colouring keeps every colour class below its target size. -/
theorem completeGraph_not_vertexArrows [Fintype V] [Fintype κ] [DecidableEq κ]
    [DecidableEq V] {s : κ → ℕ} (hs : ∀ i, 1 ≤ s i)
    (h : Fintype.card V ≤ ∑ i, (s i - 1)) :
    ¬ VertexArrows (⊤ : SimpleGraph V) s := by
  intro hV
  obtain ⟨c, hc⟩ := exists_bounded_coloring (cap := fun i => s i - 1) h
  obtain ⟨i, S, hS, hScard, _⟩ := hV c
  have hSsub : S ⊆ univ.filter (fun v => c v = i) := by
    intro v hv; simp only [mem_filter, mem_univ, true_and]; exact hS v hv
  have h1 := Finset.card_le_card hSsub
  have h2 := hc i
  have h3 := hs i
  omega

/-- **Exact vertex-Ramsey threshold on `Kₙ`.**  For target clique sizes with
`s i ≥ 1`, the complete graph vertex-arrows `(K_{s i})_i` iff
`∑ i, (s i - 1) < n`.  Equivalently, the vertex-Ramsey number of the clique
family is `1 + ∑ i, (s i - 1)`. -/
theorem completeGraph_vertexArrows_iff [Fintype V] [Fintype κ] [DecidableEq κ]
    [DecidableEq V] {s : κ → ℕ} (hs : ∀ i, 1 ≤ s i) :
    VertexArrows (⊤ : SimpleGraph V) s ↔ ∑ i, (s i - 1) < Fintype.card V := by
  constructor
  · intro hV
    by_contra hcon
    push_neg at hcon
    exact completeGraph_not_vertexArrows hs hcon hV
  · exact completeGraph_vertexArrows

/-- Restatement of the threshold as a lower bound on `|V|`: the vertex-Ramsey
number is `1 + ∑ i, (s i - 1)`. -/
theorem completeGraph_vertexArrows_iff_card_ge [Fintype V] [Fintype κ]
    [DecidableEq κ] [DecidableEq V] {s : κ → ℕ} (hs : ∀ i, 1 ≤ s i) :
    VertexArrows (⊤ : SimpleGraph V) s ↔ (∑ i, (s i - 1)) + 1 ≤ Fintype.card V := by
  rw [completeGraph_vertexArrows_iff hs]; omega

/-! ## General target graphs (beyond cliques)

We now allow arbitrary target graphs `H i` on finite vertex types `β i` instead
of cliques `K_{s i}`.  A *monochromatic copy* of `H i` is an injection
`f : β i → V` that preserves adjacency (`H i`-edges map to `G`-edges) with
monochromatic image.  On the complete host, a monochromatic clique of size
`|β i|` already contains such a copy, so the exact clique threshold transfers:
`Kₙ` vertex-arrows the family `(H i)` as soon as `∑ i, (|β i| − 1) < n`. -/

/-- `GraphVertexArrows G H`: every colouring of the vertices of `G` yields a
colour `i` and a monochromatic copy of `H i` in `G` — an injective
adjacency-preserving map `f : β i → V` with `c (f w) = i` for all `w`. -/
def GraphVertexArrows {β : κ → Type*} (G : SimpleGraph V)
    (H : ∀ i, SimpleGraph (β i)) : Prop :=
  ∀ c : V → κ, ∃ (i : κ) (f : β i → V), Function.Injective f ∧
    (∀ w w', (H i).Adj w w' → G.Adj (f w) (f w')) ∧ (∀ w, c (f w) = i)

/-
**General target graphs on the complete host.** If
`∑ i, (Fintype.card (β i) − 1) < n` then `Kₙ` vertex-arrows the family of
arbitrary target graphs `(H i)`: every colouring contains a monochromatic copy
of some `H i`.  This reduces the general vertex-Ramsey property to the clique
threshold `completeGraph_vertexArrows`.
-/
theorem completeGraph_graphVertexArrows {β : κ → Type*} [∀ i, Fintype (β i)]
    [Fintype V] [Fintype κ] [DecidableEq κ] [DecidableEq V]
    {H : ∀ i, SimpleGraph (β i)}
    (h : ∑ i, (Fintype.card (β i) - 1) < Fintype.card V) :
    GraphVertexArrows (⊤ : SimpleGraph V) H := by
  -- Reduce to the clique threshold with target sizes `s i := Fintype.card (β i)`.
  have h_vertex_arrows : VertexArrows (⊤ : SimpleGraph V) (fun i => Fintype.card (β i)) :=
    completeGraph_vertexArrows h
  intro c;
  obtain ⟨ i, S, hS₁, hS₂, hS₃ ⟩ := h_vertex_arrows c;
  -- Since $Fintype.card (β i) = S.card = Fintype.card ↥S$, there is an equivalence $e : β i ≃ ↥S$ via `Fintype.equivOfCardEq`.
  obtain ⟨ e, he ⟩ : ∃ e : β i ≃ { x // x ∈ S }, True := by
    exact ⟨ Fintype.equivOfCardEq ( by simp +decide [ hS₂ ] ), trivial ⟩;
  refine' ⟨ i, fun w => e w, _, _, _ ⟩ <;> simp_all +decide [ Function.Injective ];
  exact fun w w' h => h.ne

/-! ## The `r`-colour "monochromatic edge" specialisation

Taking every target to be `K₂` (a single edge) recovers the classical
pigeonhole: `Kₙ` with `r` colours has two equally-coloured adjacent vertices iff
`n > r`. -/

theorem sum_edge (r : ℕ) : ∑ _i : Fin r, ((fun _ => 2) _i - 1) = r := by simp

/-- The monochromatic-edge threshold: `Kₙ →_v (K₂,…,K₂)` (r copies) iff
`r < n`. -/
theorem edge_ramsey_iff (r : ℕ) [Fintype V] [DecidableEq V] :
    VertexArrows (⊤ : SimpleGraph V) (fun _ : Fin r => 2) ↔ r < Fintype.card V := by
  rw [completeGraph_vertexArrows_iff (fun _ => by norm_num), sum_edge]

/-- Concrete instance: any `2`-colouring of the triangle `K₃` has a
monochromatic edge. -/
theorem triangle_two_colour_edge :
    VertexArrows (⊤ : SimpleGraph (Fin 3)) (fun _ : Fin 2 => 2) := by
  rw [edge_ramsey_iff]; decide

/-- Concrete sharpness: `K₂` with `2` colours can avoid a monochromatic edge
(colour the two vertices differently). -/
theorem edge_two_colour_no_edge :
    ¬ VertexArrows (⊤ : SimpleGraph (Fin 2)) (fun _ : Fin 2 => 2) := by
  rw [edge_ramsey_iff]; decide

end VertexRamsey