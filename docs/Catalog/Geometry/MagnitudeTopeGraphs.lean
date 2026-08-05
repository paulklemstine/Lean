/-
# Magnitude homology of tope graphs

This file develops, from scratch, a chain of results around the magnitude homology of
*tope graphs* of real hyperplane arrangements, following the theme of the paper
"Magnitude homology of tope graphs".

The development is organised as a strictly increasing chain of results, each one using
the previous ones:

1. **The coordinate (Boolean) arrangement.** For the real arrangement of the `n`
   coordinate hyperplanes `{x : xᵢ = 0}` in `ℝⁿ`, the chambers (topes) are indexed by
   subsets `s ⊆ Fin n` (the set of coordinates that are positive). We prove that these
   chambers are nonempty, convex, pairwise disjoint, avoid all hyperplanes, and — the key
   combinatorial fact — that the set of hyperplanes *separating* two chambers is exactly
   the symmetric difference of the indexing sets.

2. **The tope graph.** Two topes are adjacent when exactly one hyperplane separates them.
   We prove that the graph distance of the resulting tope graph is exactly the number of
   separating hyperplanes, `dist s t = |s Δ t|`, and deduce connectivity.

3. **Magnitude chains in low degree.** For an arbitrary connected simple graph `G` we
   introduce the magnitude chain generators in degrees 1 and 2 and the magnitude
   differential `δ₂`, and prove:
   * `Gen2` is empty in lengths `< 2` (chains are "long"),
   * hence `MH_{1,1}(G)` is the free abelian group on the ordered edges of `G`,
   * `δ₂` is surjective in every length `ℓ ≥ 2`, hence `MH_{1,ℓ}(G) = 0`.
   The last statement is the degree-1 case of *diagonality*, which the paper establishes
   in all degrees for tope graphs.

4. **Diagonal cycles in bidegree (2,2).** The ordered edges of `G` embed into the cycles
   `ker δ₂` in length 2 via `(x,y) ↦ (x,y,x)`.

5. **Application to the tope graph.** Combining everything: for the coordinate
   arrangement in `ℝⁿ` the tope graph is connected, `MH_{1,1}` is free of rank `2ⁿ · n`,
   `MH_{1,ℓ} = 0` for `ℓ ≥ 2`, and the group of `(2,2)`-cycles is nontrivial for `n ≥ 1`.
   We also count the chain groups: `MC_{1,ℓ}` has rank `2ⁿ · C(n,ℓ)` and `MC_{2,2}` has
   rank `2ⁿ · n²`, and we exhibit the splitting
   `MH_{2,2} ⊕ ℤ^{2ⁿ·C(n,2)} ≅ ℤ^{2ⁿ·n²}` — i.e. `MH_{2,2}` has rank `2ⁿ · n(n+1)/2`,
   which is `2ⁿ` times the value at `2` of the Hilbert function of a polynomial ring in
   `n` variables, as predicted by the Stanley–Reisner description.

6. **The Coxeter picture.** The coordinate arrangement is the reflection arrangement of
   the Coxeter group `(ℤ/2)ⁿ` (type `A₁ⁿ`). We prove that graph isomorphisms are
   isometries, that the tope graph is isomorphic to the Cayley graph of `(ℤ/2)ⁿ` with
   respect to its Coxeter generators, and transport all the magnitude homology
   computations of stage 5 to that Cayley graph.

Everything below is self-contained (only `Mathlib` is imported).
-/

import Mathlib

namespace MagnitudeTope

open scoped Classical

/-! ## 1. Chambers of the coordinate arrangement in `ℝⁿ` -/

section Chambers

variable {n : ℕ}

/-- The chamber (tope) of the coordinate hyperplane arrangement `{xᵢ = 0}` in `ℝⁿ`
associated with the sign vector encoded by `s`: the coordinates in `s` are positive and
the coordinates outside `s` are negative. -/
def chamber (s : Finset (Fin n)) : Set (Fin n → ℝ) :=
  {x | (∀ i ∈ s, 0 < x i) ∧ ∀ i ∉ s, x i < 0}

private lemma comb_pos {a b x y : ℝ} (ha : 0 ≤ a) (hb : 0 ≤ b) (hab : a + b = 1)
    (hx : 0 < x) (hy : 0 < y) : 0 < a * x + b * y := by
  rcases ha.eq_or_lt with h | h
  · rw [← h]; simp; nlinarith
  · nlinarith

/-- Every chamber is nonempty: the sign vector itself lies in it. -/
lemma chamber_nonempty (s : Finset (Fin n)) : (chamber s).Nonempty := by
  refine ⟨fun i => if i ∈ s then 1 else -1, ?_, ?_⟩ <;> intro i hi <;> simp [hi]

/-- Every chamber is convex. -/
lemma chamber_convex (s : Finset (Fin n)) : Convex ℝ (chamber s) := by
  intro x hx y hy a b ha hb hab
  simp only [chamber, Set.mem_setOf_eq, Pi.add_apply, Pi.smul_apply, smul_eq_mul]
  refine ⟨fun i hi => comb_pos ha hb hab (hx.1 i hi) (hy.1 i hi), fun i hi => ?_⟩
  have := comb_pos ha hb hab (neg_pos.mpr (hx.2 i hi)) (neg_pos.mpr (hy.2 i hi))
  nlinarith

/-- Points of a chamber avoid all the hyperplanes of the arrangement. -/
lemma chamber_avoids_hyperplanes {s : Finset (Fin n)} {x : Fin n → ℝ} (hx : x ∈ chamber s)
    (i : Fin n) : x i ≠ 0 := by
  by_cases hi : i ∈ s
  · exact (hx.1 i hi).ne'
  · exact (hx.2 i hi).ne

/-- **Separation set = symmetric difference.** For points `x`, `y` of the chambers indexed
by `s` and `t`, the `i`-th coordinate hyperplane separates `x` from `y` (i.e. `xᵢ` and `yᵢ`
have opposite signs) precisely when `i` lies in the symmetric difference `s Δ t`. -/
lemma mem_symmDiff_iff_separated {s t : Finset (Fin n)} {x y : Fin n → ℝ}
    (hx : x ∈ chamber s) (hy : y ∈ chamber t) (i : Fin n) :
    i ∈ symmDiff s t ↔ x i * y i < 0 := by
  rw [Finset.mem_symmDiff]
  by_cases his : i ∈ s <;> by_cases hit : i ∈ t
  · have h1 := hx.1 i his
    have h2 := hy.1 i hit
    constructor
    · rintro (⟨_, h⟩ | ⟨_, h⟩)
      · exact absurd hit h
      · exact absurd his h
    · intro h; exact absurd h (by nlinarith)
  · have h1 := hx.1 i his
    have h2 := hy.2 i hit
    exact ⟨fun _ => by nlinarith, fun _ => Or.inl ⟨his, hit⟩⟩
  · have h1 := hx.2 i his
    have h2 := hy.1 i hit
    exact ⟨fun _ => by nlinarith, fun _ => Or.inr ⟨hit, his⟩⟩
  · have h1 := hx.2 i his
    have h2 := hy.2 i hit
    constructor
    · rintro (⟨h, _⟩ | ⟨h, _⟩)
      · exact absurd h his
      · exact absurd h hit
    · intro h; exact absurd h (by nlinarith)

/-- Distinct chambers are disjoint. -/
lemma chamber_disjoint {s t : Finset (Fin n)} (h : s ≠ t) :
    Disjoint (chamber s) (chamber t) := by
  rw [Set.disjoint_left]
  intro x hxs hxt
  have hne : symmDiff s t ≠ ∅ := by
    simpa [symmDiff_eq_bot] using h
  obtain ⟨i, hi⟩ := Finset.nonempty_iff_ne_empty.mpr hne
  have := (mem_symmDiff_iff_separated hxs hxt i).mp hi
  nlinarith [sq_nonneg (x i)]

end Chambers

/-! ## 2. The tope graph and its distance function -/

section TopeGraph

variable {n : ℕ}

/-- The **tope graph** of the coordinate arrangement in `ℝⁿ`: two topes are adjacent when
exactly one hyperplane of the arrangement separates them. By
`mem_symmDiff_iff_separated`, the separating set of the topes `s` and `t` is `s Δ t`. -/
def topeGraph (n : ℕ) : SimpleGraph (Finset (Fin n)) where
  Adj s t := (symmDiff s t).card = 1
  symm := by intro s t h; rwa [symmDiff_comm]
  loopless := by constructor; intro s h; simp at h

lemma topeGraph_adj_iff {s t : Finset (Fin n)} :
    (topeGraph n).Adj s t ↔ (symmDiff s t).card = 1 := Iff.rfl

/-- Flipping the `i`-th sign of a tope produces an adjacent tope. -/
lemma tope_adj_flip (s : Finset (Fin n)) (i : Fin n) :
    (topeGraph n).Adj s (symmDiff s {i}) := by
  show (symmDiff s (symmDiff s {i})).card = 1
  simp [symmDiff_symmDiff_cancel_left]

/-- Flipping a coordinate in the separating set decreases the separation number by one. -/
lemma sd_step (s t : Finset (Fin n)) (i : Fin n) (hi : i ∈ symmDiff s t) :
    (symmDiff (symmDiff s {i}) t).card + 1 = (symmDiff s t).card := by
  have hi' := Finset.mem_symmDiff.mp hi
  have h1 : symmDiff (symmDiff s ({i} : Finset (Fin n))) t = symmDiff (symmDiff s t) {i} := by
    rw [symmDiff_assoc, symmDiff_assoc, symmDiff_comm ({i} : Finset (Fin n)) t]
  have h2 : symmDiff (symmDiff s t) ({i} : Finset (Fin n)) = (symmDiff s t).erase i := by
    ext j
    by_cases hj : j = i <;> simp [hj, Finset.mem_erase, Finset.mem_symmDiff]
    tauto
  have h3 := Finset.card_pos.mpr ⟨i, hi⟩
  rw [h1, h2, Finset.card_erase_of_mem hi]
  omega

/-- There is a walk between two topes of length at most their separation number. -/
lemma exists_walk_card (s t : Finset (Fin n)) :
    ∃ p : (topeGraph n).Walk s t, p.length ≤ (symmDiff s t).card := by
  generalize hm : (symmDiff s t).card = m
  induction m using Nat.strong_induction_on generalizing s with
  | _ m ih =>
    rcases Nat.eq_zero_or_pos m with h | h
    · subst h
      have hst : s = t := by
        have : symmDiff s t = ∅ := Finset.card_eq_zero.mp hm
        simpa [symmDiff_eq_bot] using this
      subst hst
      exact ⟨SimpleGraph.Walk.nil, by simp⟩
    · obtain ⟨i, hi⟩ := Finset.card_pos.mp (hm ▸ h)
      have key := sd_step s t i hi
      obtain ⟨p, hp⟩ := ih ((symmDiff (symmDiff s {i}) t).card) (by omega) (symmDiff s {i}) rfl
      exact ⟨SimpleGraph.Walk.cons (tope_adj_flip s i) p, by
        simp only [SimpleGraph.Walk.length_cons]; omega⟩

/-- Any walk between two topes has length at least their separation number. -/
lemma card_le_walk_length {s t : Finset (Fin n)} (p : (topeGraph n).Walk s t) :
    (symmDiff s t).card ≤ p.length := by
  induction p with
  | nil => simp
  | cons h q ih =>
    rename_i a b c
    have htri : (symmDiff a c).card ≤ (symmDiff a b).card + (symmDiff b c).card :=
      calc (symmDiff a c).card ≤ (symmDiff a b ∪ symmDiff b c).card :=
            Finset.card_le_card (by simpa using symmDiff_triangle a b c)
        _ ≤ _ := Finset.card_union_le _ _
    have hab : (symmDiff a b).card = 1 := h
    simp only [SimpleGraph.Walk.length_cons]
    omega

/-- **The tope graph is an isometric model of the separation metric**: the graph distance
between two topes equals the number of hyperplanes separating them. -/
theorem topeGraph_dist (s t : Finset (Fin n)) :
    (topeGraph n).dist s t = (symmDiff s t).card := by
  obtain ⟨p, hp⟩ := exists_walk_card s t
  refine le_antisymm ((SimpleGraph.dist_le p).trans hp) ?_
  have hr : (topeGraph n).Reachable s t := ⟨p⟩
  obtain ⟨q, hq⟩ := hr.exists_walk_length_eq_dist
  exact hq ▸ card_le_walk_length q

/-- The tope graph is connected. -/
theorem topeGraph_connected (n : ℕ) : (topeGraph n).Connected := by
  rw [SimpleGraph.connected_iff]
  refine ⟨fun s t => ?_, ⟨∅⟩⟩
  obtain ⟨p, -⟩ := exists_walk_card s t
  exact ⟨p⟩

end TopeGraph

/-! ## 3. Magnitude chains and magnitude homology in degree 1 -/

section Magnitude

variable {V : Type*} {G : SimpleGraph V}

/-- Generators of the magnitude chain group `MC_{1,ℓ}(G)`: ordered pairs of distinct
vertices at distance `ℓ`. -/
def Gen1 (G : SimpleGraph V) (ℓ : ℕ) : Type _ :=
  {p : V × V // p.1 ≠ p.2 ∧ G.dist p.1 p.2 = ℓ}

/-- Generators of the magnitude chain group `MC_{2,ℓ}(G)`: triples of vertices with
consecutive entries distinct and total length `ℓ`. -/
def Gen2 (G : SimpleGraph V) (ℓ : ℕ) : Type _ :=
  {p : V × V × V // p.1 ≠ p.2.1 ∧ p.2.1 ≠ p.2.2 ∧
      G.dist p.1 p.2.1 + G.dist p.2.1 p.2.2 = ℓ}

lemma dist_pos_of_ne (hG : G.Connected) {x y : V} (h : x ≠ y) : 0 < G.dist x y := by
  rcases Nat.eq_zero_or_pos (G.dist x y) with h0 | h0
  · rcases SimpleGraph.dist_eq_zero_iff_eq_or_not_reachable.mp h0 with h1 | h1
    · exact absurd h1 h
    · exact absurd (hG.preconnected x y) h1
  · exact h0

/-- A geodesic of length `≥ 2` can be cut after its first step: there is a neighbour `z`
of `x` lying strictly between `x` and `y`. -/
lemma exists_geodesic_step (hG : G.Connected) {x y : V} (h : 2 ≤ G.dist x y) :
    ∃ z, G.Adj x z ∧ G.dist x z + G.dist z y = G.dist x y ∧ z ≠ y := by
  obtain ⟨p, hp⟩ := (hG.preconnected x y).exists_walk_length_eq_dist
  cases p with
  | nil => simp at h
  | cons hadj q =>
    rename_i z
    have h1 : G.dist x z = 1 := SimpleGraph.dist_eq_one_iff_adj.mpr hadj
    refine ⟨z, hadj, ?_, ?_⟩
    · have h2 : G.dist z y ≤ q.length := SimpleGraph.dist_le q
      have h3 : G.dist x y ≤ G.dist x z + G.dist z y := hG.dist_triangle
      simp only [SimpleGraph.Walk.length_cons] at hp
      omega
    · rintro rfl
      omega

/-- Magnitude chains in degree 1 vanish in length 0. -/
lemma Gen1_isEmpty_zero (hG : G.Connected) : IsEmpty (Gen1 G 0) := by
  constructor
  rintro ⟨⟨x, y⟩, hne, hd⟩
  exact absurd hd (by simpa using (dist_pos_of_ne hG hne).ne')

/-- Magnitude chains in degree 2 vanish in lengths `< 2`. -/
lemma Gen2_isEmpty_of_lt (hG : G.Connected) {ℓ : ℕ} (h : ℓ < 2) : IsEmpty (Gen2 G ℓ) := by
  constructor
  rintro ⟨⟨x, y, z⟩, h1, h2, h3⟩
  have := dist_pos_of_ne hG h1
  have := dist_pos_of_ne hG h2
  omega

/-- The magnitude differential on a degree-2 generator: delete the middle vertex, keeping
the result only if the total length is preserved. -/
noncomputable def delta2gen (hG : G.Connected) (ℓ : ℕ) (g : Gen2 G ℓ) : Gen1 G ℓ →₀ ℤ :=
  if h : G.dist g.1.1 g.1.2.2 = G.dist g.1.1 g.1.2.1 + G.dist g.1.2.1 g.1.2.2 then
    Finsupp.single ⟨(g.1.1, g.1.2.2), by
      refine ⟨?_, by rw [h]; exact g.2.2.2⟩
      rintro he
      have h0 : G.dist g.1.1 g.1.2.2 = 0 := by rw [he]; simp
      have := dist_pos_of_ne hG g.2.1
      omega⟩ 1
  else 0

/-- The magnitude differential `δ₂ : MC_{2,ℓ}(G) → MC_{1,ℓ}(G)`. -/
noncomputable def delta2 (hG : G.Connected) (ℓ : ℕ) :
    (Gen2 G ℓ →₀ ℤ) →ₗ[ℤ] (Gen1 G ℓ →₀ ℤ) :=
  Finsupp.linearCombination ℤ (delta2gen hG ℓ)

/-- Magnitude homology `MH_{1,ℓ}(G)`. Since the differential out of degree 1 is zero,
this is the cokernel of `δ₂`. -/
noncomputable abbrev MH1 (hG : G.Connected) (ℓ : ℕ) : Type _ :=
  (Gen1 G ℓ →₀ ℤ) ⧸ LinearMap.range (delta2 hG ℓ)

/-- In lengths `< 2` the differential vanishes, because there are no degree-2 chains. -/
theorem delta2_range_eq_bot_of_lt (hG : G.Connected) {ℓ : ℕ} (h : ℓ < 2) :
    LinearMap.range (delta2 hG ℓ) = ⊥ := by
  rw [Submodule.eq_bot_iff]
  rintro x ⟨y, rfl⟩
  have hy : y = 0 := by ext a; exact ((Gen2_isEmpty_of_lt hG h).false a).elim
  simp [hy]

/-- **`MH_{1,1}(G)` is free on the ordered edges of `G`.** -/
noncomputable def MH1_one_equiv (hG : G.Connected) :
    MH1 hG 1 ≃ₗ[ℤ] (Gen1 G 1 →₀ ℤ) :=
  Submodule.quotEquivOfEqBot _ (delta2_range_eq_bot_of_lt hG (by norm_num))

/-- The degree-1 magnitude generators of length 1 are exactly the ordered edges. -/
def Gen1_one_equiv (G : SimpleGraph V) : Gen1 G 1 ≃ {p : V × V // G.Adj p.1 p.2} where
  toFun g := ⟨g.1, SimpleGraph.dist_eq_one_iff_adj.mp g.2.2⟩
  invFun p := ⟨p.1, p.2.ne, SimpleGraph.dist_eq_one_iff_adj.mpr p.2⟩
  left_inv _ := rfl
  right_inv _ := rfl

/-- **Surjectivity of `δ₂` in lengths `≥ 2`**: every pair of vertices at distance `≥ 2`
is the boundary of a length-preserving triple, by cutting a geodesic. -/
theorem delta2_range_eq_top (hG : G.Connected) {ℓ : ℕ} (h : 2 ≤ ℓ) :
    LinearMap.range (delta2 hG ℓ) = ⊤ := by
  rw [Submodule.eq_top_iff']
  intro f
  induction f using Finsupp.induction_linear with
  | zero => exact Submodule.zero_mem _
  | add f g hf hg => exact Submodule.add_mem _ hf hg
  | single a c =>
    obtain ⟨⟨x, y⟩, hne, hd⟩ := a
    have hd' : G.dist x y = ℓ := hd
    obtain ⟨z, hadj, hsum, hzy⟩ := exists_geodesic_step hG (by omega : 2 ≤ G.dist x y)
    refine ⟨Finsupp.single ⟨(x, z, y), hadj.ne, hzy, by rw [hsum, hd']⟩ c, ?_⟩
    rw [delta2, Finsupp.linearCombination_single, delta2gen]
    rw [dif_pos (by simpa using hsum.symm)]
    simp

/-- **Degree-1 diagonality**: `MH_{1,ℓ}(G) = 0` for all `ℓ ≥ 2`. -/
theorem MH1_subsingleton_of_two_le (hG : G.Connected) {ℓ : ℕ} (h : 2 ≤ ℓ) :
    Subsingleton (MH1 hG ℓ) := by
  have htop := delta2_range_eq_top hG h
  rw [MH1, htop]
  infer_instance

/-- A surjection onto a projective module splits. -/
private theorem split_of_surjective {R M N : Type*} [CommRing R] [AddCommGroup M] [Module R M]
    [AddCommGroup N] [Module R N] [Module.Projective R N]
    (f : M →ₗ[R] N) (hf : LinearMap.range f = ⊤) :
    Nonempty ((LinearMap.ker f × N) ≃ₗ[R] M) := by
  obtain ⟨g, hg⟩ := LinearMap.exists_rightInverse_of_surjective f hf
  have hfg : ∀ x, f (g x) = x := fun x => congrArg (fun (h : N →ₗ[R] N) => h x) hg
  refine ⟨LinearEquiv.ofLinear ((LinearMap.ker f).subtype.coprod g)
    (LinearMap.prod (LinearMap.codRestrict (LinearMap.ker f) (LinearMap.id - g.comp f) (by
      intro m
      simp [LinearMap.mem_ker, hfg])) f) ?_ ?_⟩
  · ext m
    simp
  · ext x <;> simp [hfg]

/-- **Splitting of the magnitude chain complex in length `ℓ ≥ 2`.** Since `δ₂` is onto a
free abelian group, the group of degree-2 chains splits as the cycles plus the degree-1
chains. -/
theorem chain_split (hG : G.Connected) {ℓ : ℕ} (h : 2 ≤ ℓ) :
    Nonempty ((LinearMap.ker (delta2 hG ℓ) × (Gen1 G ℓ →₀ ℤ)) ≃ₗ[ℤ] (Gen2 G ℓ →₀ ℤ)) :=
  split_of_surjective _ (delta2_range_eq_top hG h)

end Magnitude

/-! ## 4. Diagonal cycles in bidegree `(2,2)` -/

section Diagonal

variable {V : Type*} {G : SimpleGraph V}

/-- The map sending an ordered edge `(x,y)` to the degree-2 chain `(x,y,x)`. -/
def diagGen (g : Gen1 G 1) : Gen2 G 2 :=
  ⟨(g.1.1, g.1.2, g.1.1), g.2.1, (g.2.1).symm, by
    have h1 : G.dist g.1.1 g.1.2 = 1 := g.2.2
    have h2 : G.dist g.1.2 g.1.1 = 1 := by rw [SimpleGraph.dist_comm]; exact h1
    show G.dist g.1.1 g.1.2 + G.dist g.1.2 g.1.1 = 2
    omega⟩

lemma diagGen_injective : Function.Injective (diagGen (G := G)) := by
  rintro ⟨⟨x, y⟩, hx⟩ ⟨⟨x', y'⟩, hx'⟩ h
  have h' : ((x, y, x) : V × V × V) = (x', y', x') := congrArg Subtype.val h
  simp only [Prod.mk.injEq] at h'
  simp [h'.1, h'.2.1]

/-- The induced embedding of the free abelian group on ordered edges into the degree-2
magnitude chains of length 2. -/
noncomputable def diagIncl (G : SimpleGraph V) :
    (Gen1 G 1 →₀ ℤ) →ₗ[ℤ] (Gen2 G 2 →₀ ℤ) :=
  Finsupp.lmapDomain ℤ ℤ diagGen

lemma diagIncl_injective (G : SimpleGraph V) : Function.Injective (diagIncl G) :=
  Finsupp.mapDomain_injective diagGen_injective

/-- The chains `(x,y,x)` are cycles: the middle vertex cannot be deleted without changing
the length, since `d(x,x) = 0 ≠ 2`. -/
theorem diagIncl_range_le_ker (hG : G.Connected) :
    LinearMap.range (diagIncl G) ≤ LinearMap.ker (delta2 hG 2) := by
  rintro f ⟨g, rfl⟩
  simp only [LinearMap.mem_ker]
  induction g using Finsupp.induction_linear with
  | zero => simp
  | add u v hu hv => simp [map_add, hu, hv]
  | single a c =>
    obtain ⟨⟨x, y⟩, hne, hd⟩ := a
    have h1 : G.dist x y = 1 := hd
    have h2 : G.dist y x = 1 := by rw [SimpleGraph.dist_comm]; exact h1
    rw [diagIncl, Finsupp.lmapDomain_apply, Finsupp.mapDomain_single, delta2,
      Finsupp.linearCombination_single]
    simp only [delta2gen, diagGen]
    rw [dif_neg (show ¬G.dist x x = G.dist x y + G.dist y x by
      rw [SimpleGraph.dist_self]; omega)]
    simp

/-- **Diagonal cycles in bidegree (2,2).** The ordered edges of a connected graph give a
free subgroup of the group of `(2,2)`-cycles. -/
theorem exists_free_subgroup_of_cycles (hG : G.Connected) :
    ∃ φ : (Gen1 G 1 →₀ ℤ) →ₗ[ℤ] (Gen2 G 2 →₀ ℤ),
      Function.Injective φ ∧ LinearMap.range φ ≤ LinearMap.ker (delta2 hG 2) :=
  ⟨diagIncl G, diagIncl_injective G, diagIncl_range_le_ker hG⟩

end Diagonal

/-! ## 5. Application: magnitude homology of the tope graph -/

section Application

variable {n : ℕ}

/-- Ordered edges of the tope graph are pairs (tope, flipped coordinate). -/
noncomputable def topeEdgeEquiv (n : ℕ) :
    Finset (Fin n) × Fin n ≃
      {p : Finset (Fin n) × Finset (Fin n) // (topeGraph n).Adj p.1 p.2} := by
  apply Equiv.ofBijective (fun si => ⟨(si.1, symmDiff si.1 {si.2}), by
    show (symmDiff si.1 (symmDiff si.1 {si.2})).card = 1
    simp [symmDiff_symmDiff_cancel_left]⟩)
  constructor
  · rintro ⟨s, i⟩ ⟨s', i'⟩ h
    simp only [Subtype.mk.injEq, Prod.mk.injEq] at h
    obtain ⟨h1, h2⟩ := h
    subst h1
    have : ({i} : Finset (Fin n)) = {i'} := by
      have := congrArg (fun t => symmDiff s t) h2
      simpa [symmDiff_symmDiff_cancel_left] using this
    simp_all
  · rintro ⟨⟨s, t⟩, h⟩
    obtain ⟨i, hi⟩ := Finset.card_eq_one.mp h
    refine ⟨(s, i), ?_⟩
    have : t = symmDiff s {i} := by rw [← hi, symmDiff_symmDiff_cancel_left]
    simp [this]

/-- The tope graph of the coordinate arrangement in `ℝⁿ` has exactly `2ⁿ · n` ordered
edges. -/
theorem card_tope_edges (n : ℕ) :
    Nat.card (Gen1 (topeGraph n) 1) = 2 ^ n * n := by
  rw [Nat.card_congr (Gen1_one_equiv (topeGraph n)), ← Nat.card_congr (topeEdgeEquiv n)]
  simp [Nat.card_eq_fintype_card]

/-- Pairs of topes at distance `ℓ` are pairs (tope, `ℓ`-element set of hyperplanes). -/
def topeGen1Equiv (n ℓ : ℕ) (hl : 0 < ℓ) :
    Gen1 (topeGraph n) ℓ ≃ Finset (Fin n) × {e : Finset (Fin n) // e.card = ℓ} where
  toFun g := (g.1.1, ⟨symmDiff g.1.1 g.1.2, by rw [← topeGraph_dist]; exact g.2.2⟩)
  invFun p := ⟨(p.1, symmDiff p.1 p.2.1), by
      intro h
      have h2 := congrArg (fun t => symmDiff p.1 t) h
      simp only [symmDiff_self, symmDiff_symmDiff_cancel_left] at h2
      have hc := p.2.2
      rw [← h2] at hc
      simp at hc
      omega, by
      rw [topeGraph_dist, symmDiff_symmDiff_cancel_left]; exact p.2.2⟩
  left_inv g := by
    apply Subtype.ext
    simp [symmDiff_symmDiff_cancel_left]
  right_inv p := by
    ext
    · simp
    · simp [symmDiff_symmDiff_cancel_left]

/-- **The rank of `MC_{1,ℓ}` of the tope graph is `2ⁿ · C(n,ℓ)`.** -/
theorem card_tope_gen1 (n ℓ : ℕ) (hl : 0 < ℓ) :
    Nat.card (Gen1 (topeGraph n) ℓ) = 2 ^ n * n.choose ℓ := by
  rw [Nat.card_congr (topeGen1Equiv n ℓ hl)]
  simp [Nat.card_eq_fintype_card, Fintype.card_finset_len]

/-- Degree-2 magnitude chains of length 2 of the tope graph are triples (tope, two
hyperplanes). -/
noncomputable def topeGen2Equiv (n : ℕ) :
    Finset (Fin n) × Fin n × Fin n ≃ Gen2 (topeGraph n) 2 := by
  apply Equiv.ofBijective (fun q =>
    (⟨(symmDiff q.1 {q.2.1}, q.1, symmDiff q.1 {q.2.2}), ?_, ?_, ?_⟩ : Gen2 (topeGraph n) 2))
  rotate_left
  · intro h
    have hc : (symmDiff (symmDiff q.1 {q.2.1}) q.1).card = 1 := by
      rw [symmDiff_comm, symmDiff_symmDiff_cancel_left]; simp
    rw [show (symmDiff q.1 {q.2.1}) = q.1 from h] at hc
    simp at hc
  · intro h
    have hc : (symmDiff q.1 (symmDiff q.1 {q.2.2})).card = 1 := by
      rw [symmDiff_symmDiff_cancel_left]; simp
    rw [show (symmDiff q.1 {q.2.2}) = q.1 from h.symm] at hc
    simp at hc
  · rw [topeGraph_dist, topeGraph_dist, symmDiff_comm (symmDiff q.1 {q.2.1}) q.1,
      symmDiff_symmDiff_cancel_left, symmDiff_symmDiff_cancel_left]
    simp
  constructor
  · rintro ⟨s, i, j⟩ ⟨s', i', j'⟩ h
    simp only [Subtype.mk.injEq, Prod.mk.injEq] at h
    obtain ⟨h1, h2, h3⟩ := h
    subst h2
    have hi : ({i} : Finset (Fin n)) = {i'} := by
      have := congrArg (fun t => symmDiff s t) h1
      simpa [symmDiff_symmDiff_cancel_left] using this
    have hj : ({j} : Finset (Fin n)) = {j'} := by
      have := congrArg (fun t => symmDiff s t) h3
      simpa [symmDiff_symmDiff_cancel_left] using this
    simp_all
  · rintro ⟨⟨x, y, z⟩, hxy, hyz, hsum⟩
    dsimp only at hxy hyz hsum
    rw [topeGraph_dist, topeGraph_dist] at hsum
    have h1 : (symmDiff x y).card = 1 := by
      rcases Nat.eq_zero_or_pos (symmDiff x y).card with h | h
      · exact absurd (by simpa [symmDiff_eq_bot] using Finset.card_eq_zero.mp h) hxy
      · rcases Nat.eq_zero_or_pos (symmDiff y z).card with h' | h'
        · exact absurd (by simpa [symmDiff_eq_bot] using Finset.card_eq_zero.mp h') hyz
        · omega
    have h2 : (symmDiff y z).card = 1 := by
      rcases Nat.eq_zero_or_pos (symmDiff x y).card with h | h
      · exact absurd (by simpa [symmDiff_eq_bot] using Finset.card_eq_zero.mp h) hxy
      · omega
    obtain ⟨i, hi⟩ := Finset.card_eq_one.mp h1
    obtain ⟨j, hj⟩ := Finset.card_eq_one.mp h2
    refine ⟨(y, i, j), ?_⟩
    have hx : x = symmDiff y {i} := by
      rw [← hi, symmDiff_comm x y, symmDiff_symmDiff_cancel_left]
    have hz : z = symmDiff y {j} := by rw [← hj, symmDiff_symmDiff_cancel_left]
    simp [hx, hz]

/-- **The rank of `MC_{2,2}` of the tope graph is `2ⁿ · n²`.** -/
theorem card_tope_gen2 (n : ℕ) : Nat.card (Gen2 (topeGraph n) 2) = 2 ^ n * (n * n) := by
  rw [← Nat.card_congr (topeGen2Equiv n)]
  simp [Nat.card_eq_fintype_card]

/-- **The bidegree `(2,2)` computation for the tope graph.** The group of `(2,2)`-cycles
`Z` — which is `MH_{2,2}` of the tope graph, since there are no `(3,2)`-chains — satisfies
`Z ⊕ ℤ^{2ⁿ·C(n,2)} ≅ ℤ^{2ⁿ·n²}`; so `Z` is free of rank
`2ⁿ·n² - 2ⁿ·C(n,2) = 2ⁿ·n(n+1)/2`. -/
theorem tope_cycles22_split (n : ℕ) :
    Nonempty ((LinearMap.ker (delta2 (topeGraph_connected n) 2) ×
        (Gen1 (topeGraph n) 2 →₀ ℤ)) ≃ₗ[ℤ] (Gen2 (topeGraph n) 2 →₀ ℤ)) :=
  chain_split (topeGraph_connected n) le_rfl

/-- **`MH_{1,1}` of the tope graph** is free abelian on its `2ⁿ · n` ordered edges. -/
noncomputable def topeMH1_one_equiv (n : ℕ) :
    MH1 (topeGraph_connected n) 1 ≃ₗ[ℤ] (Gen1 (topeGraph n) 1 →₀ ℤ) :=
  MH1_one_equiv (topeGraph_connected n)

/-- **Diagonality of the tope graph in degree 1**: `MH_{1,ℓ} = 0` for `ℓ ≥ 2`. -/
theorem topeMH1_vanishing (n : ℕ) {ℓ : ℕ} (h : 2 ≤ ℓ) :
    Subsingleton (MH1 (topeGraph_connected n) ℓ) :=
  MH1_subsingleton_of_two_le (topeGraph_connected n) h

/-- **Nonvanishing on the diagonal.** For `n ≥ 1` the group of `(2,2)`-cycles of the tope
graph is nontrivial. -/
theorem topeCycles22_nontrivial (n : ℕ) (hn : 0 < n) :
    LinearMap.ker (delta2 (topeGraph_connected n) 2) ≠ ⊥ := by
  obtain ⟨φ, hinj, hle⟩ := exists_free_subgroup_of_cycles (topeGraph_connected n)
  set a : Gen1 (topeGraph n) 1 :=
    (Gen1_one_equiv (topeGraph n)).symm ⟨(∅, symmDiff ∅ {(⟨0, hn⟩ : Fin n)}),
      tope_adj_flip ∅ ⟨0, hn⟩⟩ with ha
  intro hbot
  have h0 : φ (Finsupp.single a 1) = 0 := by
    have hmem : φ (Finsupp.single a 1) ∈ LinearMap.ker (delta2 (topeGraph_connected n) 2) :=
      hle ⟨_, rfl⟩
    rw [hbot] at hmem
    simpa using hmem
  have hz : Finsupp.single a (1 : ℤ) = 0 := hinj (by simpa using h0)
  simp [Finsupp.single_eq_zero] at hz

end Application

/-! ## 6. The Coxeter group `(ℤ/2)ⁿ` and its Cayley graph -/

section Coxeter

/-- A graph isomorphism does not increase distances. -/
private lemma iso_dist_le {V W : Type*} {G : SimpleGraph V} {H : SimpleGraph W}
    (e : G ≃g H) (u v : V) : H.dist (e u) (e v) ≤ G.dist u v := by
  by_cases hr : G.Reachable u v
  · obtain ⟨p, hp⟩ := hr.exists_walk_length_eq_dist
    have := SimpleGraph.dist_le (p.map e.toHom)
    simpa [hp] using this
  · have h0 : G.dist u v = 0 := SimpleGraph.dist_eq_zero_iff_eq_or_not_reachable.mpr (Or.inr hr)
    have hr' : ¬ H.Reachable (e u) (e v) := fun h => hr (by
      have := h.map e.symm.toHom
      simpa using this)
    rw [h0, SimpleGraph.dist_eq_zero_iff_eq_or_not_reachable.mpr (Or.inr hr')]

/-- **Graph isomorphisms are isometries.** -/
theorem iso_dist_eq {V W : Type*} {G : SimpleGraph V} {H : SimpleGraph W}
    (e : G ≃g H) (u v : V) : H.dist (e u) (e v) = G.dist u v := by
  refine le_antisymm (iso_dist_le e u v) ?_
  have := iso_dist_le e.symm (e u) (e v)
  simpa using this

/-- Magnitude chain generators are transported along a graph isomorphism. -/
def genEquiv1 {V W : Type*} {G : SimpleGraph V} {H : SimpleGraph W} (e : G ≃g H) (ℓ : ℕ) :
    Gen1 G ℓ ≃ Gen1 H ℓ where
  toFun g := ⟨(e g.1.1, e g.1.2), by
      simpa using (e.toEquiv.injective.ne_iff).mpr g.2.1, by
      rw [iso_dist_eq]; exact g.2.2⟩
  invFun g := ⟨(e.symm g.1.1, e.symm g.1.2), by
      simpa using (e.symm.toEquiv.injective.ne_iff).mpr g.2.1, by
      rw [iso_dist_eq]; exact g.2.2⟩
  left_inv g := by
    apply Subtype.ext
    simp
  right_inv g := by
    apply Subtype.ext
    simp

variable {n : ℕ}

/-- The indicator function of a subset, viewed as an element of the Coxeter group
`(ℤ/2)ⁿ`. -/
def ind (s : Finset (Fin n)) : Fin n → ZMod 2 := fun j => if j ∈ s then 1 else 0

lemma ind_injective : Function.Injective (ind (n := n)) := by
  intro s t h
  ext j
  have hj := congrFun h j
  simp only [ind] at hj
  by_cases hs : j ∈ s <;> by_cases ht : j ∈ t <;> simp_all

lemma ind_surjective : Function.Surjective (ind (n := n)) := by
  have key : ∀ a : ZMod 2, a ≠ 1 → (0 : ZMod 2) = a := by decide
  intro f
  refine ⟨Finset.univ.filter (fun j => f j = 1), ?_⟩
  ext j
  simp only [ind, Finset.mem_filter, Finset.mem_univ, true_and]
  by_cases h : f j = 1
  · simp [h]
  · simp only [h, if_false]
    exact key _ h

/-- The indicator map turns symmetric difference into addition in `(ℤ/2)ⁿ`. -/
lemma ind_symmDiff (s t : Finset (Fin n)) : ind (symmDiff s t) = ind s + ind t := by
  ext j
  simp only [ind, Pi.add_apply, Finset.mem_symmDiff]
  by_cases hs : j ∈ s <;> by_cases ht : j ∈ t <;> simp [hs, ht]
  decide

lemma ind_singleton (i : Fin n) : ind ({i} : Finset (Fin n)) = Pi.single i 1 := by
  ext j
  simp only [ind, Finset.mem_singleton]
  by_cases h : j = i <;> simp [h, Pi.single_apply]

private lemma single_add_single (i : Fin n) :
    (Pi.single i 1 : Fin n → ZMod 2) + Pi.single i 1 = 0 := by
  ext j
  simp only [Pi.add_apply, Pi.single_apply, Pi.zero_apply]
  split_ifs with h <;> decide

/-- The **Cayley graph of the Coxeter group `(ℤ/2)ⁿ`** with respect to its `n` standard
Coxeter generators. -/
def cayleyGraph (n : ℕ) : SimpleGraph (Fin n → ZMod 2) where
  Adj u v := ∃ i, v = u + Pi.single i 1
  symm := by
    rintro u v ⟨i, rfl⟩
    exact ⟨i, by rw [add_assoc, single_add_single, add_zero]⟩
  loopless := by
    constructor
    rintro u ⟨i, hi⟩
    have := congrFun hi i
    simp only [Pi.add_apply, Pi.single_eq_same] at this
    exact absurd (left_eq_add.mp this) (by decide)

/-- **The tope graph of the coordinate arrangement is the Cayley graph of `(ℤ/2)ⁿ`.** -/
noncomputable def topeIsoCayley (n : ℕ) : topeGraph n ≃g cayleyGraph n where
  toEquiv := Equiv.ofBijective ind ⟨ind_injective, ind_surjective⟩
  map_rel_iff' := by
    intro s t
    show (∃ i, ind t = ind s + Pi.single i 1) ↔ (symmDiff s t).card = 1
    constructor
    · rintro ⟨i, hi⟩
      have ht : t = symmDiff s {i} := by
        apply ind_injective
        rw [ind_symmDiff, ind_singleton, hi]
      rw [ht, symmDiff_symmDiff_cancel_left]
      simp
    · intro h
      obtain ⟨i, hi⟩ := Finset.card_eq_one.mp h
      refine ⟨i, ?_⟩
      have ht : t = symmDiff s {i} := by rw [← hi, symmDiff_symmDiff_cancel_left]
      rw [ht, ind_symmDiff, ind_singleton]

/-- The Cayley graph of `(ℤ/2)ⁿ` is connected. -/
theorem cayleyGraph_connected (n : ℕ) : (cayleyGraph n).Connected :=
  (topeIsoCayley n).connected_iff.mp (topeGraph_connected n)

/-- The Cayley graph distance is the number of separating hyperplanes of the corresponding
topes, i.e. the Hamming distance. -/
theorem cayleyGraph_dist (s t : Finset (Fin n)) :
    (cayleyGraph n).dist (ind s) (ind t) = (symmDiff s t).card := by
  have := iso_dist_eq (topeIsoCayley n) s t
  rw [show ((topeIsoCayley n) s) = ind s from rfl, show ((topeIsoCayley n) t) = ind t from rfl]
    at this
  rw [this, topeGraph_dist]

/-- The rank of `MC_{1,ℓ}` of the Coxeter Cayley graph is `2ⁿ · C(n,ℓ)`. -/
theorem card_cayley_gen1 (n ℓ : ℕ) (hl : 0 < ℓ) :
    Nat.card (Gen1 (cayleyGraph n) ℓ) = 2 ^ n * n.choose ℓ := by
  rw [← Nat.card_congr (genEquiv1 (topeIsoCayley n) ℓ)]
  exact card_tope_gen1 n ℓ hl

/-- **`MH_{1,1}` of the Cayley graph of `(ℤ/2)ⁿ`** is free abelian of rank `2ⁿ · n`. -/
theorem card_cayley_edges (n : ℕ) :
    Nat.card (Gen1 (cayleyGraph n) 1) = 2 ^ n * n := by
  rw [← Nat.card_congr (genEquiv1 (topeIsoCayley n) 1)]
  exact card_tope_edges n

/-- **`MH_{1,1}` of the Cayley graph of the Coxeter group `(ℤ/2)ⁿ`** is the free abelian
group on its ordered edges. -/
noncomputable def cayleyMH1_one_equiv (n : ℕ) :
    MH1 (cayleyGraph_connected n) 1 ≃ₗ[ℤ] (Gen1 (cayleyGraph n) 1 →₀ ℤ) :=
  MH1_one_equiv (cayleyGraph_connected n)

/-- **Diagonality in degree 1 for the Coxeter Cayley graph.** -/
theorem cayleyMH1_vanishing (n : ℕ) {ℓ : ℕ} (h : 2 ≤ ℓ) :
    Subsingleton (MH1 (cayleyGraph_connected n) ℓ) :=
  MH1_subsingleton_of_two_le (cayleyGraph_connected n) h

/-- **Nonvanishing on the diagonal** for the Coxeter Cayley graph. -/
theorem cayleyCycles22_nontrivial (n : ℕ) (hn : 0 < n) :
    LinearMap.ker (delta2 (cayleyGraph_connected n) 2) ≠ ⊥ := by
  obtain ⟨φ, hinj, hle⟩ := exists_free_subgroup_of_cycles (cayleyGraph_connected n)
  set a : Gen1 (cayleyGraph n) 1 :=
    genEquiv1 (topeIsoCayley n) 1
      ((Gen1_one_equiv (topeGraph n)).symm ⟨(∅, symmDiff ∅ {(⟨0, hn⟩ : Fin n)}),
        tope_adj_flip ∅ ⟨0, hn⟩⟩) with ha
  intro hbot
  have h0 : φ (Finsupp.single a 1) = 0 := by
    have hmem : φ (Finsupp.single a 1) ∈ LinearMap.ker (delta2 (cayleyGraph_connected n) 2) :=
      hle ⟨_, rfl⟩
    rw [hbot] at hmem
    simpa using hmem
  have hz : Finsupp.single a (1 : ℤ) = 0 := hinj (by simpa using h0)
  simp [Finsupp.single_eq_zero] at hz

end Coxeter

end MagnitudeTope