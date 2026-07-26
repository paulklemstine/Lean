import Mathlib

/-!
# Domination in Cartesian (box) products of graphs

This file develops a small, self-contained theory of the **domination number** of a
finite simple graph and proves the two basic inequalities that bracket the
domination number of a Cartesian (box) product `G □ H`:

* an **upper bound** `γ(G □ H) ≤ γ(G) · |V(H)|`, obtained by "cylindrifying" a
  minimum dominating set of `G`;
* a **projection lower bound** `γ(G) ≤ γ(G □ H)` and `γ(H) ≤ γ(G □ H)`, obtained
  by projecting a minimum dominating set of the product onto a single coordinate.

The projection lower bound is the combinatorial engine behind Vizing-type results
(Clark–Suen, Suen–Tarr) on `γ(G □ H)`; see
`Catalog/Combinatorics/DominationProductConstant.lean` for the arithmetic of the
improved constant `(19 - √73)/18`.

Everything is stated over `Fintype`/`DecidableEq` vertex types, and the box product
is Mathlib's `SimpleGraph.boxProd` (notation `G □ H`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The domination number of `G □ H` is squeezed between
`max(γ G, γ H)` and `γ G · |V H|`. The lower squeeze is coordinate-projection;
the upper squeeze is cylindrification. Both should be fully formalizable, unlike
the deep Vizing / Clark–Suen constant bounds.

Experiment (Experimenter): For `G = H = K₂` (a single edge), γ = 1 and
`K₂ □ K₂ = C₄`, whose domination number is 2. Indeed `max(1,1)=1 ≤ 2 ≤ 1·2`.
For a path `P₃` (γ = 1) and `K₂` (γ = 1), `P₃ □ K₂` (the 2×3 grid) has γ = 2,
again inside `[1, 1·2]`. The bounds held on every small case checked.

Analysis (Analyst): The upper bound is a clean cylindrification argument. The
lower bound needs the crucial observation that a box-product edge always keeps at
least one coordinate fixed, so the first-coordinate image of a dominating set of
`G □ H` dominates `G` (and symmetrically). This is the only place where the
adjacency structure of `□` is used, and it is exactly the fact used in Clark–Suen.

Critique (Critic): The lower-bound proof requires `Nonempty β` (resp. `Nonempty α`)
to pick a fibre; without it the projection is vacuous and the statement can fail
for the empty graph. The hypotheses are recorded explicitly. No theorem here is a
definitional `rfl`: each uses `sInf`, image cardinalities, and the `boxProd_adj`
case split.
-/

open SimpleGraph Finset

namespace GraphDom

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- `S` is a dominating set of `G`: every vertex is either in `S` or adjacent to a
member of `S`. -/
def IsDominating (G : SimpleGraph V) (S : Finset V) : Prop :=
  ∀ v : V, v ∈ S ∨ ∃ w ∈ S, G.Adj w v

/-- The domination number of `G`: the least cardinality of a dominating set. -/
noncomputable def dominationNumber (G : SimpleGraph V) : ℕ :=
  sInf { n | ∃ S : Finset V, IsDominating G S ∧ S.card = n }

omit [DecidableEq V] in
/-- The whole vertex set dominates. -/
lemma univ_isDominating (G : SimpleGraph V) : IsDominating G Finset.univ :=
  fun v => Or.inl (Finset.mem_univ v)

omit [DecidableEq V] in
/-- The set of achievable dominating-set cardinalities is nonempty. -/
lemma domSet_nonempty (G : SimpleGraph V) :
    { n | ∃ S : Finset V, IsDominating G S ∧ S.card = n }.Nonempty :=
  ⟨Finset.univ.card, Finset.univ, univ_isDominating G, rfl⟩

omit [Fintype V] [DecidableEq V] in
/-- Any dominating set bounds the domination number from above. -/
lemma dominationNumber_le {G : SimpleGraph V} {S : Finset V}
    (h : IsDominating G S) : dominationNumber G ≤ S.card :=
  Nat.sInf_le ⟨S, h, rfl⟩

omit [DecidableEq V] in
/-- The domination number is achieved by some dominating set. -/
lemma exists_min_dominating (G : SimpleGraph V) :
    ∃ S : Finset V, IsDominating G S ∧ S.card = dominationNumber G := by
  obtain ⟨S, hS, hcard⟩ := Nat.sInf_mem (domSet_nonempty G)
  exact ⟨S, hS, hcard⟩

variable {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]

omit [DecidableEq α] [DecidableEq β] in
/-- **Cylindrification upper bound.** A minimum dominating set `S` of `G`, taken
across every fibre of `H`, dominates `G □ H`; hence
`γ(G □ H) ≤ γ(G) · |V(H)|`. -/
theorem boxProd_dominationNumber_le (G : SimpleGraph α) (H : SimpleGraph β) :
    dominationNumber (G □ H) ≤ dominationNumber G * Fintype.card β := by
  obtain ⟨S, hS, hcard⟩ := exists_min_dominating G
  have hdom : IsDominating (G □ H) (S ×ˢ Finset.univ) := by
    rintro ⟨g, h⟩
    rcases hS g with hg | ⟨w, hw, hadj⟩
    · exact Or.inl (by simp [Finset.mem_product, hg])
    · refine Or.inr ⟨(w, h), by simp [Finset.mem_product, hw], ?_⟩
      rw [boxProd_adj]; exact Or.inl ⟨hadj, rfl⟩
  calc dominationNumber (G □ H) ≤ (S ×ˢ Finset.univ).card := dominationNumber_le hdom
    _ = S.card * Fintype.card β := by rw [Finset.card_product]; simp [hcard]
    _ = dominationNumber G * Fintype.card β := by rw [hcard]

omit [DecidableEq β] in
/-- **Projection lower bound (first coordinate).** The image under the first
projection of a dominating set of `G □ H` dominates `G`; hence
`γ(G) ≤ γ(G □ H)`. -/
theorem le_boxProd_dominationNumber_left (G : SimpleGraph α) (H : SimpleGraph β)
    [Nonempty β] :
    dominationNumber G ≤ dominationNumber (G □ H) := by
  obtain ⟨D, hD, hcard⟩ := exists_min_dominating (G □ H)
  have hproj : IsDominating G (D.image Prod.fst) := by
    intro g
    obtain ⟨h⟩ := (inferInstance : Nonempty β)
    rcases hD (g, h) with hin | ⟨⟨a, b⟩, hab, hadj⟩
    · exact Or.inl (by
        simp only [Finset.mem_image]
        exact ⟨(g, h), hin, rfl⟩)
    · rw [boxProd_adj] at hadj
      rcases hadj with ⟨hga, hbh⟩ | ⟨hbh, hag⟩
      · refine Or.inr ⟨a, ?_, hga⟩
        simp only [Finset.mem_image]; exact ⟨(a, b), hab, rfl⟩
      · refine Or.inl ?_
        simp only [Finset.mem_image]
        exact ⟨(a, b), hab, hag⟩
  calc dominationNumber G ≤ (D.image Prod.fst).card := dominationNumber_le hproj
    _ ≤ D.card := Finset.card_image_le
    _ = dominationNumber (G □ H) := hcard

omit [DecidableEq α] in
/-- **Projection lower bound (second coordinate).** The image under the second
projection of a dominating set of `G □ H` dominates `H`; hence
`γ(H) ≤ γ(G □ H)`. -/
theorem le_boxProd_dominationNumber_right (G : SimpleGraph α) (H : SimpleGraph β)
    [Nonempty α] :
    dominationNumber H ≤ dominationNumber (G □ H) := by
  obtain ⟨D, hD, hcard⟩ := exists_min_dominating (G □ H)
  have hproj : IsDominating H (D.image Prod.snd) := by
    intro k
    obtain ⟨g⟩ := (inferInstance : Nonempty α)
    rcases hD (g, k) with hin | ⟨⟨a, b⟩, hab, hadj⟩
    · exact Or.inl (by simp only [Finset.mem_image]; exact ⟨(g, k), hin, rfl⟩)
    · rw [boxProd_adj] at hadj
      rcases hadj with ⟨hga, hbh⟩ | ⟨hbh, hag⟩
      · refine Or.inl ?_
        simp only [Finset.mem_image]; exact ⟨(a, b), hab, hbh⟩
      · refine Or.inr ⟨b, ?_, hbh⟩
        simp only [Finset.mem_image]; exact ⟨(a, b), hab, rfl⟩
  calc dominationNumber H ≤ (D.image Prod.snd).card := dominationNumber_le hproj
    _ ≤ D.card := Finset.card_image_le
    _ = dominationNumber (G □ H) := hcard

/-- Combined `max` lower bound: `max (γ G) (γ H) ≤ γ (G □ H)`. -/
theorem max_le_boxProd_dominationNumber (G : SimpleGraph α) (H : SimpleGraph β)
    [Nonempty α] [Nonempty β] :
    max (dominationNumber G) (dominationNumber H) ≤ dominationNumber (G □ H) :=
  max_le (le_boxProd_dominationNumber_left G H) (le_boxProd_dominationNumber_right G H)

end GraphDom