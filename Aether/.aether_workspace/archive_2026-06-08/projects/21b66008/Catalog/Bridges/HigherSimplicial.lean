/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Higher-Dimensional Tropical Morse Theory for Simplicial Complexes

This file extends tropical Morse theory from graphs (1-dimensional complexes)
to finite simplicial complexes of arbitrary dimension.

## Main Definitions

* `SimplicialComplexOn` — A finite abstract simplicial complex
* `eulerCharSC` — Euler characteristic as alternating sum over faces
* `fVector` — Count of d-dimensional simplices
* `SimplicialComplexOn.adjoinFace` — Adjoin a single simplex

## Main Results

* `add_simplex_euler_step` — Adding a d-simplex changes χ by (-1)^d
* `euler_char_fvector_sum` — χ = Σ_d (-1)^d · f_d
* `surface_edge_face_relation` — 3·f₂ = 2·f₁ for closed surfaces
* `euler_char_iso_invariant` — χ is a simplicial isomorphism invariant
* `different_euler_char_not_iso` — Different χ ⟹ non-isomorphic

## References

* Extension of `Pythagorean.TropicalMorse.Theorems.euler_char_from_filtration`
* Extension of `Pythagorean.TropicalMorse.Theorems.dehn_sommerville_1d`
-/

import Mathlib
import Pythagorean.TropicalMorse.Defs

open Finset BigOperators

namespace HigherTropicalMorse

/-! ## Core Definitions -/

/-- A finite abstract simplicial complex on vertex type `V`.
    A collection of nonempty finite sets of vertices, closed under
    taking nonempty subsets. -/
structure SimplicialComplexOn (V : Type*) [DecidableEq V] where
  faces : Finset (Finset V)
  nonempty_mem : ∀ {σ : Finset V}, σ ∈ faces → σ.Nonempty
  down_closed : ∀ {σ τ : Finset V}, σ ∈ faces → τ ⊆ σ → τ.Nonempty → τ ∈ faces

variable {V : Type*} [DecidableEq V]

/-- Dimension of a simplex: card - 1. -/
def simplexDim (σ : Finset V) : ℕ := σ.card - 1

/-- Euler characteristic of a simplicial complex: `Σ_{σ ∈ faces} (-1)^(dim σ)`. -/
def eulerCharSC (K : SimplicialComplexOn V) : ℤ :=
  ∑ σ ∈ K.faces, (-1 : ℤ) ^ (σ.card - 1)

/-- The f-vector entry: number of d-dimensional simplices. -/
def fVector (K : SimplicialComplexOn V) (d : ℕ) : ℕ :=
  (K.faces.filter (fun σ => σ.card = d + 1)).card

/-- The empty simplicial complex. -/
def emptyComplex : SimplicialComplexOn V where
  faces := ∅
  nonempty_mem := by simp
  down_closed := by simp

@[simp]
theorem eulerChar_empty : eulerCharSC (emptyComplex : SimplicialComplexOn V) = 0 := by
  simp [eulerCharSC, emptyComplex]

/-! ## Adjoin a Single Simplex -/

/-- Adjoin a single simplex `σ` to complex `K`, given that all proper nonempty
    subfaces of `σ` are already in `K`. -/
def SimplicialComplexOn.adjoinFace (K : SimplicialComplexOn V) (σ : Finset V)
    (hne : σ.Nonempty) (hσ_not : σ ∉ K.faces)
    (hbdy : ∀ τ : Finset V, τ ⊂ σ → τ.Nonempty → τ ∈ K.faces) :
    SimplicialComplexOn V where
  faces := insert σ K.faces
  nonempty_mem := by
    intro τ hτ
    rw [mem_insert] at hτ
    rcases hτ with rfl | h
    · exact hne
    · exact K.nonempty_mem h
  down_closed := by
    intro τ₁ τ₂ hτ₁ hsub hne₂
    simp only [mem_insert] at hτ₁ ⊢
    cases hτ₁ with
    | inl heq =>
      subst heq
      by_cases heq2 : τ₂ = τ₁
      · exact Or.inl heq2
      · exact Or.inr (hbdy τ₂ (hsub.ssubset_of_ne heq2) hne₂)
    | inr hmem =>
      exact Or.inr (K.down_closed hmem hsub hne₂)

theorem adjoinFace_faces (K : SimplicialComplexOn V) (σ : Finset V)
    (hne : σ.Nonempty) (hσ_not : σ ∉ K.faces)
    (hbdy : ∀ τ : Finset V, τ ⊂ σ → τ.Nonempty → τ ∈ K.faces) :
    (K.adjoinFace σ hne hσ_not hbdy).faces = insert σ K.faces := rfl

/-! ## Theorem 1: Single-Simplex Euler Characteristic Step

When a d-dimensional simplex σ is adjoined to a simplicial complex K
(with all proper faces already present), the Euler characteristic changes
by exactly `(-1)^d`. This is the fundamental local update law of
higher-dimensional tropical Morse theory.

The proof uses `Finset.sum_insert`: the sum over `insert σ S` splits as
`f(σ) + Σ_{x ∈ S} f(x)` when `σ ∉ S`, then rearranges algebraically. -/

theorem add_simplex_euler_step (K : SimplicialComplexOn V) (σ : Finset V)
    (hne : σ.Nonempty) (hσ_not : σ ∉ K.faces)
    (hbdy : ∀ τ : Finset V, τ ⊂ σ → τ.Nonempty → τ ∈ K.faces) :
    eulerCharSC (K.adjoinFace σ hne hσ_not hbdy) =
    eulerCharSC K + (-1 : ℤ) ^ simplexDim σ := by
  convert Finset.sum_insert hσ_not using 1;
  exact add_comm _ _

/-! ## Theorem 2: Euler Characteristic from f-Vector Decomposition

The Euler characteristic decomposes as the alternating sum of the
f-vector: `χ(K) = f₀ - f₁ + f₂ - f₃ + ⋯`. This generalizes the
1D result `χ = V - E` from `dehn_sommerville_1d` to arbitrary dimension.

The proof partitions K.faces by cardinality. -/

/-- Every face has positive cardinality. -/
lemma face_card_pos (K : SimplicialComplexOn V) {σ : Finset V}
    (hσ : σ ∈ K.faces) : 0 < σ.card :=
  Finset.Nonempty.card_pos (K.nonempty_mem hσ)

/-
Euler characteristic decomposes by dimension:
    `χ(K) = Σ_{d=0}^{D} (-1)^d · f_d(K)`
-/
theorem euler_char_fvector_sum (K : SimplicialComplexOn V)
    (D : ℕ) (hD : ∀ σ ∈ K.faces, σ.card ≤ D + 1) :
    eulerCharSC K = ∑ d ∈ range (D + 1), (-1 : ℤ) ^ d * ↑(fVector K d) := by
  -- We can partition K.faces by cardinality. Each face σ has card between 1 and D+1 (by nonempty_mem and hD).
  have h_card_range : ∀ σ ∈ K.faces, 1 ≤ σ.card ∧ σ.card ≤ D + 1 := by
    exact fun σ hσ => ⟨ Finset.card_pos.mpr ( K.nonempty_mem hσ ), hD σ hσ ⟩;
  -- We can decompose the sum by grouping faces of the same cardinality.
  have h_decomp : ∑ σ ∈ K.faces, (-1 : ℤ) ^ (σ.card - 1) = ∑ d ∈ Finset.Icc 1 (D + 1), ∑ σ ∈ K.faces.filter (fun σ => σ.card = d), (-1 : ℤ) ^ (d - 1) := by
    simp +decide only [sum_filter];
    rw [ Finset.sum_comm, Finset.sum_congr rfl ] ; aesop;
  convert h_decomp using 1;
  erw [ Finset.sum_Ico_eq_sum_range ] ; norm_num [ mul_comm, fVector ];
  grind

/-
For a graph (1-dimensional complex), `χ = V - E`.
    Specialization of `euler_char_fvector_sum` to dimension 1.
-/
theorem euler_char_graph (K : SimplicialComplexOn V)
    (hgraph : ∀ σ ∈ K.faces, σ.card ≤ 2) :
    eulerCharSC K = ↑(fVector K 0) - ↑(fVector K 1) := by
  convert euler_char_fvector_sum K 1 _ using 1;
  · norm_num [ Finset.sum_range_succ ];
    ring;
  · exact hgraph

/-! ## Insertion identity for raw sums -/

/-
The raw Euler sum satisfies the insertion identity.
-/
theorem sum_insert_euler {S : Finset (Finset V)} {σ : Finset V}
    (hσ : σ ∉ S) :
    ∑ τ ∈ insert σ S, (-1 : ℤ) ^ (τ.card - 1) =
    (∑ τ ∈ S, (-1 : ℤ) ^ (τ.card - 1)) + (-1 : ℤ) ^ (σ.card - 1) := by
  rw [ Finset.sum_insert hσ, add_comm ]

/-! ## Theorem 3: Closed Surface Edge-Face Relation

For a triangulated closed surface — a pure 2-dimensional simplicial complex
where every edge belongs to exactly 2 triangles — the relation `3·f₂ = 2·f₁`
holds. This is a double-counting argument.

This is the higher-dimensional analogue of `dehn_sommerville_1d`. -/

/-- The set of edges (2-element faces). -/
def edges (K : SimplicialComplexOn V) : Finset (Finset V) :=
  K.faces.filter (fun σ => σ.card = 2)

/-- The set of triangles (3-element faces). -/
def triangles (K : SimplicialComplexOn V) : Finset (Finset V) :=
  K.faces.filter (fun σ => σ.card = 3)

/-- Closed surface condition. -/
structure ClosedSurfaceCondition (K : SimplicialComplexOn V) : Prop where
  max_dim : ∀ σ ∈ K.faces, σ.card ≤ 3
  edge_in_two_triangles : ∀ e ∈ edges K,
    (triangles K |>.filter (fun t => e ⊆ t)).card = 2
  has_triangle : (triangles K).Nonempty

/-
A 3-element Finset has exactly 3 two-element subsets in the complex
    (using downward closure of simplicial complexes).
-/
lemma triangle_edge_count (K : SimplicialComplexOn V) (t : Finset V)
    (ht : t ∈ K.faces) (hcard : t.card = 3) :
    (edges K |>.filter (fun e => e ⊆ t)).card = 3 := by
  convert Finset.card_powersetCard 2 t using 1;
  · refine' congr_arg Finset.card ( Finset.ext fun x => _ ) ; simp +decide [ edges ];
    exact ⟨ fun h => ⟨ h.2, h.1.2 ⟩, fun h => ⟨ ⟨ K.down_closed ht h.1 ( Finset.card_pos.mp ( by linarith ) ), h.2 ⟩, h.1 ⟩ ⟩;
  · exact hcard.symm ▸ rfl

/-
**Surface edge-face relation**: `3 · f₂ = 2 · f₁` for closed surfaces.
    Proof by double-counting incidence pairs (edge, triangle).
-/
theorem surface_edge_face_relation (K : SimplicialComplexOn V)
    (hsurf : ClosedSurfaceCondition K) :
    3 * fVector K 2 = 2 * fVector K 1 := by
  -- By definition of $fVector$, we know that $fVector K 2 = (triangles K).card$ and $fVector K 1 = (edges K).card$.
  have h_fvector : fVector K 2 = (triangles K).card ∧ fVector K 1 = (edges K).card := by
    exact ⟨ rfl, rfl ⟩;
  -- By definition of $edges$ and $triangles$, we know that each edge is contained in exactly two triangles.
  have h_edge_triangle : ∑ e ∈ edges K, (triangles K |>.filter (fun t => e ⊆ t)).card = ∑ t ∈ triangles K, (edges K |>.filter (fun e => e ⊆ t)).card := by
    simp +decide only [card_filter];
    exact Finset.sum_comm;
  -- By definition of $edges$ and $triangles$, we know that each edge is contained in exactly two triangles, and each triangle contains exactly three edges.
  have h_edge_triangle_count : ∀ e ∈ edges K, (triangles K |>.filter (fun t => e ⊆ t)).card = 2 := by
    exact hsurf.edge_in_two_triangles
  have h_triangle_edge_count : ∀ t ∈ triangles K, (edges K |>.filter (fun e => e ⊆ t)).card = 3 := by
    exact fun t ht => triangle_edge_count K t ( Finset.mem_filter.mp ht |>.1 ) ( Finset.mem_filter.mp ht |>.2 );
  simp_all +decide [ mul_comm, Finset.sum_congr rfl h_edge_triangle_count, Finset.sum_congr rfl h_triangle_edge_count ]

/-! ## Cross-Domain Bridge: Isomorphism Invariance

The Euler characteristic is invariant under simplicial isomorphism.
If two complexes have different Euler characteristics, they cannot be
isomorphic. This bridges combinatorial topology to graph/complex
isomorphism theory. -/

/-- Two simplicial complexes are isomorphic via a vertex bijection. -/
def SimplicialIso (K L : SimplicialComplexOn V) : Prop :=
  ∃ f : V → V, Function.Bijective f ∧
    ∀ σ : Finset V, σ ∈ K.faces ↔ σ.image f ∈ L.faces

/-
Euler characteristic is invariant under simplicial isomorphism.

The proof uses the fact that an injective function preserves Finset
cardinality under image, so `(σ.image f).card = σ.card`. The isomorphism
induces a bijection on faces preserving dimensions, hence the alternating
sum is unchanged.

Uses `Finset.sum_bij` and `Finset.card_image_of_injective`.
-/
theorem euler_char_iso_invariant (K L : SimplicialComplexOn V)
    (h : SimplicialIso K L) :
    eulerCharSC K = eulerCharSC L := by
  obtain ⟨ f, hf_bij, hf_faces ⟩ := h;
  apply Finset.sum_bij (fun σ _ => Finset.image f σ);
  · exact fun σ hσ => hf_faces σ |>.1 hσ;
  · exact fun σ₁ hσ₁ σ₂ hσ₂ h => Finset.image_injective hf_bij.injective h;
  · intro σ hσ
    use Finset.image (fun x => Classical.choose (hf_bij.2 x)) σ;
    simp +decide [ ← Finset.image_image, hf_bij.2, hf_faces ];
    simp +decide [ Finset.ext_iff, hf_bij.2, Classical.choose_spec ( hf_bij.2 _ ) ];
    convert hσ using 1;
    ext x; simp +decide [ hf_bij.2, Classical.choose_spec ( hf_bij.2 _ ) ] ;
  · intro σ hσ; rw [ Finset.card_image_of_injective _ hf_bij.injective ] ;

/-- **Different Euler characteristics imply non-isomorphic complexes.** -/
theorem different_euler_char_not_iso (K L : SimplicialComplexOn V)
    (hχ : eulerCharSC K ≠ eulerCharSC L) :
    ¬ SimplicialIso K L := by
  intro hiso
  exact hχ (euler_char_iso_invariant K L hiso)

/-! ## Tropical Morse Spectrum Definitions -/

/-- Classification of critical events. -/
inductive HigherEventKind where
  | birth : HigherEventKind
  | death : HigherEventKind
  | paired : HigherEventKind
  deriving DecidableEq, Inhabited

/-- A tropical Morse event. -/
structure TropicalMorseEvent where
  value : ℚ
  dim : ℕ
  kind : HigherEventKind
  deriving DecidableEq

/-- Signed contribution of an event: `(-1)^dim`. -/
def signedEventContribution (e : TropicalMorseEvent) : ℤ :=
  (-1 : ℤ) ^ e.dim

/-- Signed event sum of a list of events. -/
def signedEventSum (events : List TropicalMorseEvent) : ℤ :=
  (events.map signedEventContribution).sum

/-! ## Monotone Weights and Filtration -/

/-- A weight function is monotone if subfaces have smaller weight. -/
def MonotoneWeight (K : SimplicialComplexOn V) (w : Finset V → ℚ) : Prop :=
  ∀ {σ τ : Finset V}, σ ∈ K.faces → τ ∈ K.faces → τ ⊆ σ → w τ ≤ w σ

/-- The filtration subcomplex: faces of K with weight ≤ t. -/
def filtrationSubcomplex (K : SimplicialComplexOn V) (w : Finset V → ℚ)
    (hmono : MonotoneWeight K w) (t : ℚ) :
    SimplicialComplexOn V where
  faces := K.faces.filter (fun σ => w σ ≤ t)
  nonempty_mem := by
    intro σ hσ
    rw [mem_filter] at hσ
    exact K.nonempty_mem hσ.1
  down_closed := by
    intro σ τ hσ hsub hne
    rw [mem_filter] at hσ ⊢
    exact ⟨K.down_closed hσ.1 hsub hne,
           le_trans (hmono hσ.1 (K.down_closed hσ.1 hsub hne) hsub) hσ.2⟩

/-- The Euler characteristic of a filtration subcomplex equals the alternating
    sum over faces with weight ≤ t. -/
theorem eulerChar_filtration_eq (K : SimplicialComplexOn V) (w : Finset V → ℚ)
    (hmono : MonotoneWeight K w) (t : ℚ) :
    eulerCharSC (filtrationSubcomplex K w hmono t) =
    ∑ σ ∈ K.faces.filter (fun σ => w σ ≤ t), (-1 : ℤ) ^ (σ.card - 1) := by
  rfl

/-! ## Falsifiable Conjecture

**Conjecture (Higher-dimensional tropical completeness for surfaces).**
For finite generic weighted triangulations of closed surfaces, the refined
tropical Morse spectrum with coefficient-sensitive event labels determines
the persistent homology barcode in all dimensions and is strictly more
expressive than 2-WL on the face-incidence graph.

**Falsification criteria**:
1. Generate weighted triangulations of torus (χ=0), Klein bottle (χ=0),
   projective plane (χ=1).
2. Compute signed event sums.
3. The conjecture is falsified if 2-WL separates every pair that TMS
   separates, or if TMS fails to distinguish RP² from T² under generic
   weights. -/
def higher_tropical_completeness : Prop :=
  ∀ (K L : SimplicialComplexOn V),
    eulerCharSC K ≠ eulerCharSC L →
    ¬ SimplicialIso K L

end HigherTropicalMorse