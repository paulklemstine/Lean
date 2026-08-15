import Mathlib
import Logic.HoTT.Foundations
import Bridges.CombinatorialBridge
/-! # The Uniform Witness Bound (corrected)

This file formalizes the *uniform witness bound* for `(d+1)`-uniform set families
classified by their *missing-trace size*, together with a combinatorial proof of the
extremal inequality and the equality characterisation in the saturated (`s = 0`) regime.

## Trace / shattering background

The relevant trace–shattering vocabulary lives in `Catalog.Bridges.Foundations`
(`ConceptFamily`, `ConceptFamily.shatters`, the Sauer–Shelah growth function).  For a
`(d+1)`-uniform family `ℱ` the natural traces of a member `F ∈ ℱ` are its `d`-element
subsets ("facets").  A facet `D ⊆ F` is *present* as a trace exactly when some **other**
member `G ∈ ℱ` realises it as an intersection `G ∩ F = D`; equivalently when `D` is
contained in at least two members of `ℱ`.  It is a *missing trace* of `F` when `D` lies in
no other member, i.e. when `D` has facet–degree `1` ("a private facet of `F`").

The binomial manipulations rely on `Catalog.Bridges.CombinatorialBridge`
(`subset_card_le`, `finset_card_le_univ`) and Mathlib's `Nat.choose`, which already obeys
the convention `Nat.choose a b = 0` for `a < b`.

## Main definitions

* `IsUniform F d` — every member of `F` has exactly `d+1` elements.
* `facetDeg F D`  — the number of members of `F` containing the `d`-set `D`.
* `privateFacets F A d` — the missing traces of `A`: its `d`-subsets of facet–degree `1`.
* `MissingTraceSize F d s` — every member has exactly `s` missing traces.
* `W d s n` — the explicit witness bound `n.choose (d+1)` when `s = 0`, and
  `n.choose d / s` (Euclidean division) when `s ≥ 1`.
* `completeFamily n d` — all `(d+1)`-subsets of `[n]`, the saturated `s = 0` extremiser.
* `trivialStar n d` — all `(d+1)`-subsets through the fixed vertex `0`.

## Main results

* `uniform_witness_bound` : `F.card ≤ W d s n` for every `(d+1)`-uniform family with
  missing-trace size `s` (with `2 ≤ d`, `s ≤ d`, `2*(d+1) ≤ n`).  The `s ≥ 1` case is the
  genuine combinatorial step: the private facets of distinct members are *disjoint* sets of
  `d`-subsets, hence `F.card * s ≤ n.choose d`.
* `uniform_witness_eq_zero` : in the saturated regime `s = 0` equality `F.card = n.choose (d+1)`
  holds **iff** `F = completeFamily n d`.
* `completeFamily_*`, `trivialStar_*` : the two named constructions (the saturated
  extremiser and the trivial star) are genuine uniform families and we compute their
  cardinalities, witnessing non-vacuity of the bound.

## Scope note

The inequality `uniform_witness_bound` and the saturated equality case
`uniform_witness_eq_zero` are proved in full.  The fine equality classification across the
full range of `s` (the Chao–Xu–Yip–Zhang construction versus the trivial star, with the
threshold `⌊(d+1)/2⌋`) is the genuinely deep extremal content; here the relevant
constructions are defined and shown to be valid uniform families with explicit
cardinalities, but only the `s = 0` end of the classification is established as an `iff`.
-/

open Finset

namespace UniformWitnessBound

variable {n : ℕ}

/-! ## I. Definitions -/

/-- A family `F` of subsets of `[n] = Fin n` is `(d+1)`-uniform when every member has
exactly `d + 1` elements. -/
def IsUniform (F : Finset (Finset (Fin n))) (d : ℕ) : Prop :=
  ∀ A ∈ F, A.card = d + 1

/-- The facet–degree of a `d`-set `D`: the number of members of `F` containing `D`. -/
def facetDeg (F : Finset (Finset (Fin n))) (D : Finset (Fin n)) : ℕ :=
  (F.filter (fun A => D ⊆ A)).card

/-- The *missing traces* (private facets) of a member `A`: those `d`-subsets of `A` that are
contained in no other member of `F`, i.e. have facet–degree exactly `1`. -/
def privateFacets (F : Finset (Finset (Fin n))) (A : Finset (Fin n)) (d : ℕ) :
    Finset (Finset (Fin n)) :=
  (A.powersetCard d).filter (fun D => facetDeg F D = 1)

/-- A family has *missing-trace size* `s` when every member has exactly `s` missing traces. -/
def MissingTraceSize (F : Finset (Finset (Fin n))) (d s : ℕ) : Prop :=
  ∀ A ∈ F, (privateFacets F A d).card = s

/-- The explicit witness bound.  In the saturated regime `s = 0` it is the total number of
`(d+1)`-subsets; for `s ≥ 1` it is the private-facet bound `⌊n.choose d / s⌋`.  Euclidean
division and `Nat.choose` together encode the convention `binomial a b = 0` for `a < b`. -/
def W (d s n : ℕ) : ℕ := if s = 0 then n.choose (d + 1) else n.choose d / s

/-- The complete family: all `(d+1)`-subsets of `[n]`. -/
def completeFamily (n d : ℕ) : Finset (Finset (Fin n)) :=
  (Finset.univ : Finset (Fin n)).powersetCard (d + 1)

/-- The trivial star through the vertex `0 : Fin n`: all `(d+1)`-subsets containing `0`. -/
def trivialStar (n d : ℕ) [NeZero n] : Finset (Finset (Fin n)) :=
  ((Finset.univ : Finset (Fin n)).powersetCard (d + 1)).filter (fun A => (0 : Fin n) ∈ A)

/-! ## II. Basic facts about uniform families -/

/-- Every `(d+1)`-uniform family is contained in the complete family. -/
theorem subset_completeFamily {F : Finset (Finset (Fin n))} {d : ℕ}
    (huni : IsUniform F d) : F ⊆ completeFamily n d := by
  exact fun x hx => Finset.mem_powersetCard.mpr ⟨ Finset.subset_univ _, huni x hx ⟩

/-- A `(d+1)`-uniform family has at most `n.choose (d+1)` members. -/
theorem card_le_choose_succ {F : Finset (Finset (Fin n))} {d : ℕ}
    (huni : IsUniform F d) : F.card ≤ n.choose (d + 1) := by
  convert Finset.card_le_card ( subset_completeFamily huni ) using 1;
  unfold completeFamily; aesop;

/-! ## III. The combinatorial core: private facets are disjoint across members -/

/-- The private facets of two distinct members are disjoint: a `d`-set of facet–degree `1`
belongs to a unique member. -/
theorem privateFacets_pairwiseDisjoint {F : Finset (Finset (Fin n))} {d : ℕ} :
    (↑F : Set (Finset (Fin n))).PairwiseDisjoint (fun A => privateFacets F A d) := by
  intros A hA B hB hAB;
  simp +decide [ privateFacets, Finset.disjoint_left ];
  intro D hDA hDd hD1 hDB hDd';
  exact ne_of_gt ( Finset.one_lt_card.mpr ⟨ A, by aesop, B, by aesop ⟩ )

/-- The union of all private facets is a set of `d`-subsets of `[n]`. -/
theorem biUnion_privateFacets_subset {F : Finset (Finset (Fin n))} {d : ℕ} :
    F.biUnion (fun A => privateFacets F A d) ⊆
      (Finset.univ : Finset (Fin n)).powersetCard d := by
  grind +locals

/-- **Combinatorial witness step.**  If every member has exactly `s` missing traces then
`F.card * s ≤ n.choose d`, because the private facets of distinct members are disjoint
`d`-subsets of `[n]`. -/
theorem card_mul_le_choose {F : Finset (Finset (Fin n))} {d s : ℕ}
    (hms : MissingTraceSize F d s) : F.card * s ≤ n.choose d := by
  have h_union_card : (Finset.biUnion F (fun A => privateFacets F A d)).card ≤ n.choose d := by
    exact le_trans ( Finset.card_le_card ( biUnion_privateFacets_subset ) ) ( by simp +decide [ Finset.card_univ ] );
  rw [ Finset.card_biUnion ] at h_union_card;
  · rw [ Finset.sum_congr rfl fun x hx => hms x hx ] at h_union_card ; aesop;
  · exact privateFacets_pairwiseDisjoint

/-! ## IV. The uniform witness bound -/

/--
**The uniform witness bound.**  Every `(d+1)`-uniform family on `[n]` of missing-trace
size `s` (with `2 ≤ d`, `s ≤ d`, `2*(d+1) ≤ n`) has at most `W d s n` members.

The hypotheses `2 ≤ d`, `s ≤ d` and `2*(d+1) ≤ n` are part of the stated problem; the proof
of the bound itself uses only uniformity (for the `s = 0` branch) and the disjointness of
private facets (for the `s ≥ 1` branch).
-/
theorem uniform_witness_bound {d s : ℕ} (F : Finset (Finset (Fin n)))
    (hd : 2 ≤ d) (hs : s ≤ d) (hn : 2 * (d + 1) ≤ n)
    (huni : IsUniform F d) (hms : MissingTraceSize F d s) :
    F.card ≤ W d s n := by
  by_cases hs0 : s = 0 <;> simp_all +decide [ W ];
  · exact card_le_choose_succ huni
  · exact Nat.le_div_iff_mul_le ( Nat.pos_of_ne_zero hs0 ) |>.2 ( by linarith [ card_mul_le_choose hms ] )

/-! ## V. The complete family and the saturated equality case -/

/-- The complete family is `(d+1)`-uniform. -/
theorem completeFamily_uniform (n d : ℕ) : IsUniform (completeFamily n d) d := by
  exact fun A hA => Finset.mem_powersetCard.mp hA |>.2

/-- The complete family has exactly `n.choose (d+1)` members. -/
theorem completeFamily_card (n d : ℕ) : (completeFamily n d).card = n.choose (d + 1) := by
  exact Finset.card_powersetCard _ _ |> Eq.trans <| by simp +decide [ Finset.card_univ ] ;

/-- When `n ≥ d + 2`, every facet of a member of the complete family lies in at least two
members, hence the complete family has missing-trace size `0`. -/
theorem completeFamily_missingTraceSize {n d : ℕ} (hn : d + 2 ≤ n) :
    MissingTraceSize (completeFamily n d) d 0 := by
  intro A hA
  simp [privateFacets];
  intro D hDA hD_card
  have h_facet_deg : facetDeg (completeFamily n d) D ≥ 2 := by
    obtain ⟨x, hx⟩ : ∃ x : Fin n, x ∉ A := by
      contrapose! hn;
      simp_all +decide [ Finset.eq_univ_of_forall hn, completeFamily ];
    refine' Finset.one_lt_card.mpr ⟨ A, _, Insert.insert x D, _, _ ⟩ <;> simp_all +decide [ completeFamily ];
    · rw [ Finset.card_insert_of_notMem ( fun h => hx <| hDA h ), hD_card ];
    · grind;
  linarith

/-- **Equality in the saturated regime.**  Among `(d+1)`-uniform families, the cardinality
bound `n.choose (d+1)` (the value `W d 0 n`) is attained exactly by the complete family. -/
theorem uniform_witness_eq_zero {d : ℕ} (F : Finset (Finset (Fin n)))
    (huni : IsUniform F d) :
    F.card = n.choose (d + 1) ↔ F = completeFamily n d := by
  constructor <;> intro h;
  · exact Finset.eq_of_subset_of_card_le ( subset_completeFamily huni ) ( by rw [ h, completeFamily_card ] );
  · rw [ h, completeFamily_card ]

/-! ## VI. The trivial star construction -/

/-- The trivial star is `(d+1)`-uniform. -/
theorem trivialStar_uniform (n d : ℕ) [NeZero n] : IsUniform (trivialStar n d) d := by
  exact fun A hA => Finset.mem_powersetCard.mp ( Finset.mem_filter.mp hA |>.1 ) |>.2

/-- The trivial star through a vertex has `(n-1).choose d` members. -/
theorem trivialStar_card (n d : ℕ) [NeZero n] :
    (trivialStar n d).card = (n - 1).choose d := by
  have h_trivial_star_card : (trivialStar n d).card = (Finset.powersetCard d (Finset.erase (Finset.univ : Finset (Fin n)) 0)).card := by
    refine' Finset.card_bij ( fun A hA => A.erase 0 ) _ _ _;
    · simp +contextual [ trivialStar ];
      exact fun a ha ha' => Finset.erase_subset_erase _ ( Finset.subset_univ _ );
    · unfold trivialStar; simp +contextual [ Finset.ext_iff ] ;
      grind;
    · simp +decide [ trivialStar ];
      exact fun b hb₁ hb₂ => ⟨ Insert.insert 0 b, ⟨ by rw [ Finset.card_insert_of_notMem ( fun h => by simpa using hb₁ h ), hb₂ ], Finset.mem_insert_self _ _ ⟩, by rw [ Finset.erase_insert ( fun h => by simpa using hb₁ h ) ] ⟩;
  simp_all +decide [ Finset.card_univ ]

end UniformWitnessBound