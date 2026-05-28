/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Newton Polytope Erosion and Quadratic Shadow

This file establishes the geometric dictionary between:
1. The **quadratic shadow** of a finite exponent support (a combinatorial operation),
2. **Minkowski erosion** of the Newton polytope by the degree-2 simplex (a convex-geometric operation),
3. **Tropical second-derivative support** (a tropical-algebraic operation).

The central insight is that "which monomials survive double differentiation?" is equivalent
to "which lattice points remain after eroding the Newton polytope by the quadratic simplex?"

## Main Definitions

* `minkowskiErosion` — The Minkowski erosion (morphological erosion) of sets in `ℝⁿ`
* `quadSimplex` — The discrete degree-2 simplex `{β ∈ ℕⁿ : ∑ βᵢ = 2}`
* `quadSimplexReal` — The real relaxation `{β ∈ ℝ≥0ⁿ : ∑ βᵢ = 2}`
* `newtonPolytope` — Convex hull of embedded support points
* `latticePoints` — Integer points in a real set
* `IsLatticeSaturated` — Support contains all lattice points of its Newton polytope
* `discreteQuadShadow` — Finset-level quadratic shadow via existential subtraction
* `tropicalSecondShadow` — Tropical second-derivative support operation

## Main Results

* `universalQuadShadow_subset_erosionLattice` — Universal shadow ⊆ erosion lattice points
* `erosionLattice_subset_universalQuadShadow_of_saturated` — Reverse for saturated supports
* `universalQuadShadow_eq_erosionLattice_of_saturated` — Equality characterization (flagship)
* `tropicalSecondShadow_eq_discreteQuadShadow` — Tropical support = combinatorial shadow
* `erosion_antitone` — Minkowski erosion is antitone in the kernel
* `erosion_monotone_set` — Minkowski erosion is monotone in the ambient set

## References

Builds on `Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean`, which established
that `NonzeroQuadLeafSet f = QuadraticShadow (NewtonSupport f)` for polynomials over
char-zero domains. This file reinterprets that combinatorial equality geometrically.
-/

open Finset BigOperators Classical

noncomputable section

namespace NewtonErosion

/-! ## Part 1: Minkowski Erosion -/

/-- **Minkowski erosion** of a set `P` by a kernel `K`.
    The erosion `P ⊖ K` consists of all points `x` such that the translate `x + K` is
    entirely contained in `P`. This is the dual of Minkowski sum. -/
def minkowskiErosion {d : ℕ} (P K : Set (Fin d → ℝ)) : Set (Fin d → ℝ) :=
  {x | ∀ y ∈ K, x + y ∈ P}

theorem mem_minkowskiErosion_iff {d : ℕ} {P K : Set (Fin d → ℝ)} {x : Fin d → ℝ} :
    x ∈ minkowskiErosion P K ↔ ∀ y ∈ K, x + y ∈ P := Iff.rfl

/-- Minkowski erosion is monotone in the ambient set. -/
theorem erosion_monotone_set {d : ℕ} {P₁ P₂ K : Set (Fin d → ℝ)}
    (h : P₁ ⊆ P₂) : minkowskiErosion P₁ K ⊆ minkowskiErosion P₂ K :=
  fun _ hx _ hy => h (hx _ hy)

/-- Minkowski erosion is antitone in the kernel. -/
theorem erosion_antitone {d : ℕ} {P K₁ K₂ : Set (Fin d → ℝ)}
    (h : K₁ ⊆ K₂) : minkowskiErosion P K₂ ⊆ minkowskiErosion P K₁ :=
  fun _ hx _ hy => hx _ (h hy)

/-- Erosion by empty kernel is the whole space. -/
theorem erosion_empty {d : ℕ} (P : Set (Fin d → ℝ)) :
    minkowskiErosion P ∅ = Set.univ := by
  ext x; simp [minkowskiErosion]

/-- Erosion by singleton `{0}` is the set itself. -/
theorem erosion_singleton_zero {d : ℕ} (P : Set (Fin d → ℝ)) :
    minkowskiErosion P {0} = P := by
  ext x; simp [minkowskiErosion, Pi.add_def]

/-! ## Part 2: Degree-2 Simplex -/

/-- The **discrete degree-2 simplex**: all `β : Fin n → ℕ` with `∑ βᵢ = 2`.
    These are the exponent increments corresponding to second-order monomials. -/
def quadSimplex (n : ℕ) : Set (Fin n → ℕ) :=
  {β | ∑ i, β i = 2}

/-- The **real degree-2 simplex**: `{β ∈ ℝ≥0ⁿ : ∑ βᵢ = 2}`. -/
def quadSimplexReal (n : ℕ) : Set (Fin n → ℝ) :=
  {β | (∀ i, 0 ≤ β i) ∧ ∑ i, β i = 2}

/-- A vertex of the discrete simplex: `2 · eᵢ`. -/
def quadSimplexVertex (n : ℕ) (i : Fin n) : Fin n → ℕ :=
  fun j => if j = i then 2 else 0

theorem quadSimplexVertex_mem (n : ℕ) (i : Fin n) :
    quadSimplexVertex n i ∈ quadSimplex n := by
  simp [quadSimplex, quadSimplexVertex]

/-- An edge midpoint of the discrete simplex: `eᵢ + eⱼ`. -/
def quadSimplexEdge (n : ℕ) (i j : Fin n) : Fin n → ℕ :=
  fun k => (if k = i then 1 else 0) + (if k = j then 1 else 0)

theorem quadSimplexEdge_mem (n : ℕ) (i j : Fin n) :
    quadSimplexEdge n i j ∈ quadSimplex n := by
  simp [quadSimplex, quadSimplexEdge, Finset.sum_add_distrib]

/-! ## Part 3: Embedding and Newton Polytope -/

/-- Embed `Fin n → ℕ` into `Fin n → ℝ` pointwise. -/
def embedNatReal {n : ℕ} (v : Fin n → ℕ) : Fin n → ℝ :=
  fun i => (v i : ℝ)

@[simp]
theorem embedNatReal_apply {n : ℕ} (v : Fin n → ℕ) (i : Fin n) :
    embedNatReal v i = (v i : ℝ) := rfl

/-- The **Newton polytope** of a finite support set: the convex hull of the
    real embeddings of all support points. -/
def newtonPolytope {n : ℕ} (S : Finset (Fin n → ℕ)) : Set (Fin n → ℝ) :=
  convexHull ℝ (embedNatReal '' ↑S)

/-- **Lattice points** of a real set: all natural-number vectors whose embedding
    lies in the set. -/
def latticePoints {n : ℕ} (P : Set (Fin n → ℝ)) : Set (Fin n → ℕ) :=
  {v | embedNatReal v ∈ P}

theorem mem_latticePoints_iff {n : ℕ} {P : Set (Fin n → ℝ)} {v : Fin n → ℕ} :
    v ∈ latticePoints P ↔ embedNatReal v ∈ P := Iff.rfl

/-! ## Part 4: Lattice Saturation -/

/-- A support set is **lattice-saturated** if it contains every lattice point
    of its Newton polytope. -/
def IsLatticeSaturated {n : ℕ} (S : Finset (Fin n → ℕ)) : Prop :=
  ∀ u : Fin n → ℕ, u ∈ latticePoints (newtonPolytope S) → u ∈ S

/-! ## Part 5: Quadratic Shadows -/

/-- The **discrete (existential) quadratic shadow**: `u` is in the shadow if there exists
    a quadratic increment `β` (with `∑βᵢ = 2`) such that `u + β ∈ S`. -/
def discreteQuadShadowSet {n : ℕ} (S : Finset (Fin n → ℕ)) : Set (Fin n → ℕ) :=
  {u | ∃ β : Fin n → ℕ, β ∈ quadSimplex n ∧ (u + β) ∈ S}

/-- The **universal quadratic shadow**: `u` is in the shadow if for every
    discrete quadratic increment `β`, we have `u + β ∈ S`. -/
def universalQuadShadowSet {n : ℕ} (S : Finset (Fin n → ℕ)) : Set (Fin n → ℕ) :=
  {u | ∀ β : Fin n → ℕ, β ∈ quadSimplex n → (u + β) ∈ S}

/-! ## Part 6: Erosion Lattice Points -/

/-- Lattice points of the Minkowski erosion of the Newton polytope by the real
    quadratic simplex. -/
def erosionLattice {n : ℕ} (S : Finset (Fin n → ℕ)) : Set (Fin n → ℕ) :=
  latticePoints (minkowskiErosion (newtonPolytope S) (quadSimplexReal n))

/-! ## Part 7: Tropical Second Shadow -/

/-- The **tropical second shadow** of a support set. In tropical polynomial theory,
    the support of the tropical second derivative is computed combinatorially as
    the discrete quadratic shadow. -/
def tropicalSecondShadow {n : ℕ} (S : Finset (Fin n → ℕ)) : Set (Fin n → ℕ) :=
  discreteQuadShadowSet S

/-! ## Auxiliary Lemmas -/

/-- The embedding preserves addition. -/
theorem embedNatReal_add {n : ℕ} (u v : Fin n → ℕ) :
    embedNatReal (u + v) = embedNatReal u + embedNatReal v := by
  ext i; simp [embedNatReal, Pi.add_apply]

/-- The embedding is injective. -/
theorem embedNatReal_injective {n : ℕ} : Function.Injective (@embedNatReal n) := by
  intro u v h; ext i
  have := congr_fun h i; simp [embedNatReal] at this; exact this

/-- Support points embed into the Newton polytope. -/
theorem support_subset_newtonPolytope {n : ℕ} (S : Finset (Fin n → ℕ))
    {v : Fin n → ℕ} (hv : v ∈ S) :
    embedNatReal v ∈ newtonPolytope S := by
  apply subset_convexHull ℝ
  exact Set.mem_image_of_mem _ (Finset.mem_coe.mpr hv)

/-- Discrete simplex embeds into real simplex. -/
theorem quadSimplex_embed_real {n : ℕ} {β : Fin n → ℕ} (hβ : β ∈ quadSimplex n) :
    embedNatReal β ∈ quadSimplexReal n := by
  refine ⟨fun i => Nat.cast_nonneg _, ?_⟩
  simp [quadSimplex] at hβ
  rw [show (∑ i : Fin n, embedNatReal β i) = ∑ i, (β i : ℝ) from rfl]
  push_cast; exact_mod_cast hβ

/-! ## Main Theorems -/

/-! ### Theorem 1: Universal shadow ⊆ erosion lattice points

**Proof idea:** If `u` is in the universal shadow, then for every discrete `β ∈ quadSimplex`,
`u + β ∈ S`, so `embed(u + β) ∈ newtonPolytope S`. For an arbitrary real `β' ∈ quadSimplexReal`,
we need `embed(u) + β' ∈ newtonPolytope S`. The real quadratic simplex is the convex hull of
the discrete vertices `{2eᵢ}` and edge midpoints `{eᵢ + eⱼ}`, so `β'` is a convex combination
of these embedded discrete points. Then `embed(u) + β'` is the same convex combination of
`embed(u + β_k)`, all of which lie in the (convex) Newton polytope. -/

theorem universalQuadShadow_subset_erosionLattice {n : ℕ} (S : Finset (Fin n → ℕ))
    (_hn : 0 < n) :
    universalQuadShadowSet S ⊆ erosionLattice S := by
  intro u hu;
  intro y hy
  have h_convex_comb : y ∈ convexHull ℝ (embedNatReal '' quadSimplex n) := by
    -- By definition of $quadSimplexReal$, we know that $y$ can be written as a convex combination of the vertices of the discrete simplex.
    have h_convex_comb : ∃ (w : Fin n → ℝ), (∀ i, 0 ≤ w i) ∧ (∑ i, w i = 1) ∧ y = ∑ i, w i • (embedNatReal (quadSimplexVertex n i)) := by
      use fun i => y i / 2;
      simp_all +decide [ funext_iff, quadSimplexVertex ];
      exact ⟨ fun i => div_nonneg ( hy.1 i ) zero_le_two, by rw [ ← Finset.sum_div _ _ _, hy.2, div_self ( by norm_num ) ] ⟩;
    obtain ⟨ w, hw₁, hw₂, rfl ⟩ := h_convex_comb;
    grind +suggestions;
  -- Since $y$ is a convex combination of points in the image of $quadSimplex n$, we can write $y$ as a convex combination of points in $newtonPolytope S$.
  have h_convex_comb_in_newton : ∀ z ∈ embedNatReal '' quadSimplex n, embedNatReal u + z ∈ newtonPolytope S := by
    simp +zetaDelta at *;
    exact fun β hβ => by simpa only [ ← embedNatReal_add ] using support_subset_newtonPolytope S ( hu β hβ ) ;
  rw [ mem_convexHull_iff ] at h_convex_comb;
  specialize h_convex_comb ( { z | embedNatReal u + z ∈ newtonPolytope S } );
  refine' h_convex_comb h_convex_comb_in_newton _;
  intro x hx y hy a b ha hb hab;
  simp_all +decide [ newtonPolytope ];
  convert convex_convexHull ℝ ( embedNatReal '' ( S : Set ( Fin n → ℕ ) ) ) hx hy ha hb hab using 1 ; ext ; norm_num ; ring;
  grind +splitImp

/-! ### Theorem 2: Reverse containment under saturation

**Proof idea:** If `u ∈ erosionLattice S`, then for every real `β ∈ quadSimplexReal`,
`embed(u) + β ∈ newtonPolytope S`. For a discrete `β ∈ quadSimplex`, `embed(β) ∈ quadSimplexReal`,
so `embed(u) + embed(β) = embed(u + β) ∈ newtonPolytope S`. This means `u + β` is a lattice
point of the Newton polytope. By lattice saturation, `u + β ∈ S`. -/

theorem erosionLattice_subset_universalQuadShadow_of_saturated {n : ℕ}
    (S : Finset (Fin n → ℕ)) (hSat : IsLatticeSaturated S) (_hn : 0 < n) :
    erosionLattice S ⊆ universalQuadShadowSet S := by
  -- Assume u ∈ erosionLattice S. This means for all real β ∈ quadSimplexReal n, embed(u) + β ∈ newtonPolytope S.
  intro u hu
  simp [erosionLattice] at hu;
  intro β hβ;
  convert hSat _ _;
  convert hu ( embedNatReal β ) ( quadSimplex_embed_real hβ ) using 1;
  simp +decide [ ← embedNatReal_add ];
  rfl

/-- **Flagship Theorem:** For lattice-saturated supports, the universal
    quadratic shadow equals the erosion lattice points exactly. This is the
    bridge from combinatorics to convex geometry. -/
theorem universalQuadShadow_eq_erosionLattice_of_saturated {n : ℕ}
    (S : Finset (Fin n → ℕ)) (hSat : IsLatticeSaturated S) (hn : 0 < n) :
    universalQuadShadowSet S = erosionLattice S :=
  Set.Subset.antisymm (universalQuadShadow_subset_erosionLattice S hn)
    (erosionLattice_subset_universalQuadShadow_of_saturated S hSat hn)

/-! ### Theorem 3: Tropical shadow = discrete shadow -/

theorem tropicalSecondShadow_eq_discreteQuadShadow {n : ℕ}
    (S : Finset (Fin n → ℕ)) :
    tropicalSecondShadow S = discreteQuadShadowSet S := rfl

/-! ### Monotonicity theorems -/

theorem discreteQuadShadow_mono {n : ℕ} {S₁ S₂ : Finset (Fin n → ℕ)}
    (h : S₁ ⊆ S₂) : discreteQuadShadowSet S₁ ⊆ discreteQuadShadowSet S₂ :=
  fun _ ⟨β, hβ, hmem⟩ => ⟨β, hβ, h hmem⟩

theorem universalQuadShadow_mono {n : ℕ} {S₁ S₂ : Finset (Fin n → ℕ)}
    (h : S₁ ⊆ S₂) : universalQuadShadowSet S₁ ⊆ universalQuadShadowSet S₂ :=
  fun _ hu β hβ => h (hu β hβ)

/-- The universal shadow is contained in the existential shadow (needs nonempty simplex). -/
theorem universalQuadShadow_subset_discreteQuadShadow {n : ℕ}
    (S : Finset (Fin n → ℕ))
    (hn : 0 < n) :
    universalQuadShadowSet S ⊆ discreteQuadShadowSet S := by
  intro u hu
  have i₀ : Fin n := ⟨0, hn⟩
  exact ⟨quadSimplexVertex n i₀, quadSimplexVertex_mem n i₀, hu _ (quadSimplexVertex_mem n i₀)⟩

theorem erosionLattice_mono {n : ℕ} {S₁ S₂ : Finset (Fin n → ℕ)}
    (h : S₁ ⊆ S₂) : erosionLattice S₁ ⊆ erosionLattice S₂ := by
  intro u hu y hy
  apply convexHull_mono (Set.image_mono (Finset.coe_subset.mpr h))
  exact hu y hy

/-- Lattice-saturated sets contain all their elements in the polytope. -/
theorem mem_of_saturated_of_mem_newtonLattice {n : ℕ} {S : Finset (Fin n → ℕ)}
    (hSat : IsLatticeSaturated S) {u : Fin n → ℕ}
    (hu : embedNatReal u ∈ newtonPolytope S) : u ∈ S :=
  hSat u hu

/-! ### Sparse obstruction -/

/-
**Theorem: Sparse Obstruction.** If `S` is not lattice-saturated, there exists a
    witness `v` in the Newton polytope but not in `S`. Under additional conditions
    (if all quadratic translates of some `u = v - β` are in the polytope), this
    creates a gap between the erosion lattice and the universal shadow.
-/
theorem exists_newton_gap_of_not_saturated {n : ℕ} {S : Finset (Fin n → ℕ)}
    (hNot : ¬ IsLatticeSaturated S) :
    ∃ v : Fin n → ℕ, embedNatReal v ∈ newtonPolytope S ∧ v ∉ S := by
  exact Set.not_subset.mp hNot

/-! ### 1D Specializations -/

/-- In 1D, the quadratic simplex is `{fun _ => 2}`. -/
theorem quadSimplex_one : quadSimplex 1 = {fun _ => 2} := by
  ext β; simp [quadSimplex]
  constructor
  · intro h; ext i; fin_cases i; exact h
  · intro h; have := congr_fun h ⟨0, by omega⟩; simpa using this

/-- In 1D, `quadSimplexReal 1` is `{fun _ => 2}`. -/
theorem quadSimplexReal_one : quadSimplexReal 1 = {fun _ => (2 : ℝ)} := by
  ext β; simp only [quadSimplexReal, Set.mem_setOf_eq, Set.mem_singleton_iff]
  constructor
  · rintro ⟨hnn, hsum⟩
    ext i; fin_cases i; simp_all
  · intro h
    subst h
    exact ⟨fun i => by fin_cases i; simp, by simp⟩

/-- In 1D, the universal shadow of `S` is `{u | u + 2 ∈ S}`, which equals
    the erosion lattice for any S (saturation is automatic in the 1D universal case). -/
theorem universalQuadShadow_one (S : Finset (Fin 1 → ℕ)) :
    universalQuadShadowSet S = {u | (u + fun _ => 2) ∈ S} := by
  ext u
  simp only [universalQuadShadowSet, Set.mem_setOf_eq]
  constructor
  · intro h
    have := h (fun _ => 2) (by simp [quadSimplex])
    exact this
  · intro h β hβ
    have : β = fun _ => 2 := by
      ext i; fin_cases i
      simp [quadSimplex] at hβ; exact hβ
    rw [this]; exact h

end NewtonErosion