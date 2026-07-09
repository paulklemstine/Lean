/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Elementary counting theory for colorings of uniform hypergraphs

This file develops, from first principles, the classical *counting* (union bound and
pigeonhole) arguments about colorings of `(r+1)`-uniform hypergraphs.

A hypergraph is `(r+1)`-uniform if every edge is a set of exactly `r + 1` vertices.  A
`Color`-coloring of the vertices is *proper* if no edge is monochromatic.  We prove:

* `mono_count_le`  : for a fixed edge, at most `k ^ (n - r)` of the `k`-colorings make it
  monochromatic (`n = |V|`, `k = |Color|`);
* `exists_proper_coloring_of_few_edges` : if `|E| < k ^ r` then a proper `k`-coloring
  exists (union bound);
* `property_B_of_few_edges` : the `k = 2` special case (Erdős' *Property B*);
* `complete_needs_many_colors` : in the complete `(r+1)`-uniform hypergraph, if `k · r < n`
  then *every* `k`-coloring has a monochromatic edge (pigeonhole), and consequently
  `complete_proper_needs_colors` shows any proper `k`-coloring forces `n ≤ k · r`, i.e.
  `χ ≥ ⌈n / r⌉`;
* `list_mono_count_le` : the list-coloring analogue of `mono_count_le`.

Finally `property_B_improved_conjecture` records, as an explicitly `sorry`-marked research
conjecture, the Radhakrishnan–Srinivasan-type improvement of the Property-B threshold, whose
proof requires the probabilistic method and is beyond the elementary counting developed here.

All counting is carried out explicitly with `Finset`/`Fintype`, using the `Decidable` instances
provided below rather than classical choice to enumerate colorings.  (The proofs still depend on
the standard foundational axioms `propext`, `Quot.sound` and `Classical.choice`, the last of which
is inherited from Mathlib's finite-set library and is unavoidable when using `Finset.card`.)
-/
import Mathlib

open Finset

namespace UniformHypergraphColoring

/-- An `(r+1)`-uniform hypergraph on the vertex type `V`: a finite family of edges, each of
which is a finite set of exactly `r + 1` vertices. -/
structure UniformHypergraph (V : Type*) (r : ℕ) where
  /-- The edges of the hypergraph. -/
  edges : Finset (Finset V)
  /-- Every edge has exactly `r + 1` vertices. -/
  edge_card : ∀ e ∈ edges, e.card = r + 1

variable {V : Type*} {r : ℕ} {Color : Type*}

/-- An edge `e` is *monochromatic* under the coloring `c` if all of its vertices receive a
single common color. -/
def IsMono (c : V → Color) (e : Finset V) : Prop := ∃ a : Color, ∀ v ∈ e, c v = a

/-- A coloring `c` is a *proper coloring* of `H` if no edge of `H` is monochromatic. -/
def IsProperColoring (H : UniformHypergraph V r) (c : V → Color) : Prop :=
  ∀ e ∈ H.edges, ¬ IsMono c e

/-- Monochromaticity of a fixed edge is decidable (finitely many colors to test). -/
instance decidableIsMono [Fintype Color] [DecidableEq Color] (c : V → Color) (e : Finset V) :
    Decidable (IsMono c e) := by unfold IsMono; infer_instance

/-- Being a proper coloring is decidable. -/
instance decidableIsProper [Fintype Color] [DecidableEq Color]
    (H : UniformHypergraph V r) (c : V → Color) : Decidable (IsProperColoring H c) := by
  unfold IsProperColoring; infer_instance

section Counting

variable [Fintype V] [DecidableEq V] [Fintype Color] [DecidableEq Color]

/-- The colorings that are constant, equal to a fixed color `a`, on an edge `e` are exactly
the elements of a product `Finset`; hence there are `k ^ |eᶜ|` of them. -/
lemma card_filter_const (a : Color) (e : Finset V) :
    (univ.filter (fun c : V → Color => ∀ v ∈ e, c v = a)).card
      = (Fintype.card Color) ^ (eᶜ).card := by
  have hset : (univ.filter (fun c : V → Color => ∀ v ∈ e, c v = a))
      = Fintype.piFinset (fun v => if v ∈ e then ({a} : Finset Color) else univ) := by
    ext c
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Fintype.mem_piFinset]
    constructor
    · intro h v
      by_cases hv : v ∈ e
      · simp [hv, h v hv]
      · simp [hv]
    · intro h v hv
      have hcv := h v
      simp only [hv, if_true, Finset.mem_singleton] at hcv
      exact hcv
  rw [hset, Fintype.card_piFinset, ← Finset.prod_mul_prod_compl e]
  have h1 : ∏ i ∈ e, (if i ∈ e then ({a} : Finset Color) else univ).card = 1 :=
    Finset.prod_eq_one (fun i hi => by simp [hi])
  have h2 : ∏ i ∈ eᶜ, (if i ∈ e then ({a} : Finset Color) else univ).card
      = (Fintype.card Color) ^ eᶜ.card := by
    rw [Finset.prod_congr rfl (g := fun _ => Fintype.card Color)
          (fun i hi => by simp [Finset.mem_compl.mp hi]), Finset.prod_const]
  rw [h1, h2, one_mul]

/-- **Counting monochromatic colorings.**  For a fixed edge `e` with `r + 1` vertices, at most
`k ^ (n - r)` of the `k`-colorings make `e` monochromatic, where `n = |V|`, `k = |Color|`.

Proof: a monochromatic coloring picks a common color `a` for `e` (`k` choices) and colors the
remaining `n - (r+1)` vertices freely (`k ^ (n - r - 1)` choices); `k · k ^ (n - r - 1) =
k ^ (n - r)`. -/
lemma mono_count_le (e : Finset V) (he : e.card = r + 1) :
    (univ.filter (fun c : V → Color => IsMono c e)).card
      ≤ (Fintype.card Color) ^ (Fintype.card V - r) := by
  have hcover : univ.filter (fun c : V → Color => IsMono c e) ⊆
      univ.biUnion (fun a : Color => univ.filter (fun c : V → Color => ∀ v ∈ e, c v = a)) := by
    intro c hc
    rw [Finset.mem_filter] at hc
    obtain ⟨a, ha⟩ := hc.2
    rw [Finset.mem_biUnion]
    exact ⟨a, Finset.mem_univ a, Finset.mem_filter.mpr ⟨Finset.mem_univ c, ha⟩⟩
  refine (Finset.card_le_card hcover).trans (Finset.card_biUnion_le.trans ?_)
  have hsum : ∑ a : Color, (univ.filter (fun c : V → Color => ∀ v ∈ e, c v = a)).card
      = (Fintype.card Color) * (Fintype.card Color) ^ (eᶜ).card := by
    rw [Finset.sum_congr rfl (fun a _ => card_filter_const a e), Finset.sum_const,
      Finset.card_univ, smul_eq_mul]
  rw [hsum]
  have hle : r + 1 ≤ Fintype.card V := he ▸ Finset.card_le_univ e
  rw [Finset.card_compl, he, ← pow_succ']
  apply le_of_eq
  congr 1
  omega

/-- **Existence of a proper coloring from few edges (union bound).**  If the number of edges is
strictly smaller than `k ^ r`, then `H` has a proper `k`-coloring.

Proof: the number of colorings that fail to be proper is at most
`|E| · k ^ (n - r) < k ^ r · k ^ (n - r) = k ^ n`, the total number of colorings, so some
coloring avoids every edge. -/
theorem exists_proper_coloring_of_few_edges [Nonempty Color]
    (H : UniformHypergraph V r) (hE : H.edges.card < (Fintype.card Color) ^ r) :
    ∃ c : V → Color, IsProperColoring H c := by
  have hk : 0 < Fintype.card Color := Fintype.card_pos
  have hsub : univ.filter (fun c : V → Color => ¬ IsProperColoring H c) ⊆
      H.edges.biUnion (fun e => univ.filter (fun c : V → Color => IsMono c e)) := by
    intro c hc
    rw [Finset.mem_filter] at hc
    have h2 : ¬ ∀ e ∈ H.edges, ¬ IsMono c e := hc.2
    push_neg at h2
    obtain ⟨e, he_mem, hmono⟩ := h2
    rw [Finset.mem_biUnion]
    exact ⟨e, he_mem, Finset.mem_filter.mpr ⟨Finset.mem_univ c, hmono⟩⟩
  have hcardbad : (univ.filter (fun c : V → Color => ¬ IsProperColoring H c)).card
      ≤ H.edges.card * (Fintype.card Color) ^ (Fintype.card V - r) := by
    refine (Finset.card_le_card hsub).trans (Finset.card_biUnion_le.trans ?_)
    refine (Finset.sum_le_card_nsmul H.edges _
      ((Fintype.card Color) ^ (Fintype.card V - r)) ?_).trans_eq ?_
    · intro e he_mem
      exact mono_count_le e (H.edge_card e he_mem)
    · rw [smul_eq_mul]
  have hbad : (univ.filter (fun c : V → Color => ¬ IsProperColoring H c)).card
      < (Fintype.card Color) ^ (Fintype.card V) := by
    refine lt_of_le_of_lt hcardbad ?_
    by_cases hr : r ≤ Fintype.card V
    · calc H.edges.card * (Fintype.card Color) ^ (Fintype.card V - r)
          < (Fintype.card Color) ^ r * (Fintype.card Color) ^ (Fintype.card V - r) :=
            Nat.mul_lt_mul_of_pos_right hE (pow_pos hk _)
        _ = (Fintype.card Color) ^ (Fintype.card V) := by rw [← pow_add]; congr 1; omega
    · have hempty : H.edges = ∅ := by
        rw [Finset.eq_empty_iff_forall_notMem]
        intro e he_mem
        have h1 := H.edge_card e he_mem
        have h3 := Finset.card_le_univ e
        omega
      rw [hempty, Finset.card_empty, zero_mul]
      exact pow_pos hk _
  have hpos : 0 < (univ.filter (fun c : V → Color => IsProperColoring H c)).card := by
    have hsum := Finset.card_filter_add_card_filter_not (s := (univ : Finset (V → Color)))
      (fun c => IsProperColoring H c)
    rw [Finset.card_univ, Fintype.card_fun] at hsum
    omega
  obtain ⟨c, hc⟩ := Finset.card_pos.mp hpos
  exact ⟨c, (Finset.mem_filter.mp hc).2⟩

/-- **Erdős' Property B.**  The `k = 2` special case: an `(r+1)`-uniform hypergraph with fewer
than `2 ^ r` edges is `2`-colorable. -/
theorem property_B_of_few_edges (H : UniformHypergraph V r)
    (hE : H.edges.card < 2 ^ r) : ∃ c : V → Bool, IsProperColoring H c := by
  have hcard : (Fintype.card Bool) ^ r = 2 ^ r := by simp
  exact exists_proper_coloring_of_few_edges (Color := Bool) H (by rw [hcard]; exact hE)

omit [DecidableEq V] in
/-- **The complete hypergraph needs many colors (pigeonhole).**  If `k · r < n` then every
`k`-coloring of the vertex set produces a monochromatic set of `r + 1` vertices — an edge of
the complete `(r+1)`-uniform hypergraph.

Proof: the `k` color classes partition the `n` vertices; if each had at most `r` vertices the
total would be at most `k · r < n`, so some class has at least `r + 1` vertices, and any
`(r+1)`-subset of it is a monochromatic edge. -/
theorem complete_needs_many_colors
    (hkr : (Fintype.card Color) * r < Fintype.card V) (c : V → Color) :
    ∃ (a : Color) (e : Finset V), e.card = r + 1 ∧ ∀ v ∈ e, c v = a := by
  obtain ⟨a, -, ha⟩ := Finset.exists_lt_card_fiber_of_mul_lt_card_of_maps_to
    (s := (univ : Finset V)) (t := (univ : Finset Color)) (f := c) (n := r)
    (fun a _ => mem_univ _) (by simpa [Finset.card_univ] using hkr)
  obtain ⟨e, hsub, hcard⟩ :=
    Finset.exists_subset_card_eq (s := univ.filter (fun x => c x = a)) (n := r + 1) (by omega)
  exact ⟨a, e, hcard, fun v hv => (Finset.mem_filter.mp (hsub hv)).2⟩

omit [DecidableEq V] in
/-- Contrapositive chromatic bound: any proper coloring of the complete `(r+1)`-uniform
hypergraph must use enough colors that `n ≤ k · r`.  Equivalently the chromatic number satisfies
`χ ≥ ⌈n / r⌉`. -/
theorem complete_proper_needs_colors (c : V → Color)
    (hproper : ∀ (a : Color) (e : Finset V), e.card = r + 1 → ¬ (∀ v ∈ e, c v = a)) :
    Fintype.card V ≤ (Fintype.card Color) * r := by
  by_contra h
  push_neg at h
  obtain ⟨a, e, hcard, hmono⟩ := complete_needs_many_colors h c
  exact hproper a e hcard hmono

/-- **List-coloring analogue of `mono_count_le`.**  Fix an edge `e` with `r + 1` vertices and a
list assignment `L`, and let `k` bound the list sizes on `e` (`|L v| ≤ k` for `v ∈ e`).  Then at
most `k · ∏_{v ∉ e} |L v|` of the list-colorings (`c v ∈ L v` for all `v`) make `e`
monochromatic.

Remark on the hypothesis: the informal statement uses `|L v| ≥ k`, but with the bound written as
`k · ∏_{v ∉ e} |L v|` the correct (upper-bounding) direction is `|L v| ≤ k`, since the number of
admissible common colors on `e` is at most the size of any single list on `e`.  When all lists on
`e` have size exactly `k` the two readings coincide and the bound reduces to
`k ^ (n - r)` as in `mono_count_le`. -/
theorem list_mono_count_le (e : Finset V) (he : e.card = r + 1)
    (L : V → Finset Color) (k : ℕ) (hL : ∀ v ∈ e, (L v).card ≤ k) :
    ((Fintype.piFinset L).filter (fun c => IsMono c e)).card
      ≤ k * ∏ v ∈ eᶜ, (L v).card := by
  obtain ⟨w, hw⟩ := Finset.card_pos.mp (show 0 < e.card by rw [he]; omega)
  have hsub : (Fintype.piFinset L).filter (fun c => IsMono c e) ⊆
      (L w).biUnion (fun a =>
        Fintype.piFinset (fun v => if v ∈ e then ({a} : Finset Color) else L v)) := by
    intro c hc
    rw [Finset.mem_filter] at hc
    obtain ⟨hcpi, a, ha⟩ := hc
    rw [Fintype.mem_piFinset] at hcpi
    rw [Finset.mem_biUnion]
    refine ⟨a, ?_, ?_⟩
    · rw [← ha w hw]; exact hcpi w
    · rw [Fintype.mem_piFinset]
      intro v
      by_cases hv : v ∈ e
      · simp [hv, ha v hv]
      · simp [hv, hcpi v]
  refine (Finset.card_le_card hsub).trans (Finset.card_biUnion_le.trans ?_)
  have hcard : ∀ a : Color,
      (Fintype.piFinset (fun v => if v ∈ e then ({a} : Finset Color) else L v)).card
        = ∏ v ∈ eᶜ, (L v).card := by
    intro a
    rw [Fintype.card_piFinset, ← Finset.prod_mul_prod_compl e]
    have h1 : ∏ i ∈ e, (if i ∈ e then ({a} : Finset Color) else L i).card = 1 :=
      Finset.prod_eq_one (fun i hi => by simp [hi])
    have h2 : ∏ i ∈ eᶜ, (if i ∈ e then ({a} : Finset Color) else L i).card
        = ∏ v ∈ eᶜ, (L v).card :=
      Finset.prod_congr rfl (fun i hi => by simp [Finset.mem_compl.mp hi])
    rw [h1, h2, one_mul]
  calc ∑ a ∈ L w,
        (Fintype.piFinset (fun v => if v ∈ e then ({a} : Finset Color) else L v)).card
      = ∑ _a ∈ L w, ∏ v ∈ eᶜ, (L v).card := Finset.sum_congr rfl (fun a _ => hcard a)
    _ = (L w).card * ∏ v ∈ eᶜ, (L v).card := by rw [Finset.sum_const, smul_eq_mul]
    _ ≤ k * ∏ v ∈ eᶜ, (L v).card := Nat.mul_le_mul_right _ (hL w hw)

end Counting

/-- **Research conjecture (Radhakrishnan–Srinivasan-type improvement of Property B).**

The elementary union bound (`property_B_of_few_edges`) shows an `(r+1)`-uniform hypergraph with
fewer than `2 ^ r` edges is `2`-colorable.  It is conjectured (and, in the non-list setting,
known via the probabilistic *random recoloring* method) that this threshold can be improved by a
`√r` factor: there is an absolute constant `c > 0` such that fewer than `c · √r · 2 ^ r` edges
already force `2`-colorability.  A proof requires the probabilistic method and lies well beyond
the elementary counting of this file, so the statement is recorded here with `sorry`. -/
theorem property_B_improved_conjecture :
    ∃ c : ℝ, 0 < c ∧
      ∀ (W : Type) [Fintype W] [DecidableEq W] (r : ℕ) (H : UniformHypergraph W r),
        (H.edges.card : ℝ) < c * Real.sqrt (r : ℝ) * 2 ^ r →
          ∃ f : W → Bool, IsProperColoring H f := by
  have key : ∃ c : ℝ, 0 < c ∧
      ∀ (W : Type) [Fintype W] [DecidableEq W] (r : ℕ) (H : UniformHypergraph W r),
        (H.edges.card : ℝ) < c * Real.sqrt (r : ℝ) * 2 ^ r →
          ∃ f : W → Bool, IsProperColoring H f := by
    sorry -- requires advanced probabilistic methods (Radhakrishnan–Srinivasan)
  exact key

end UniformHypergraphColoring