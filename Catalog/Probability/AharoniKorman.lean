/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The Aharoni–Korman Theorem for Well-Founded FAC Posets

This file formalizes the statement of the Aharoni–Korman theorem in the setting of
well-founded posets with the *Finite Antichain Condition* (FAC): every antichain is finite.

The Aharoni–Korman theorem (also known as the "fishbone conjecture" in one of its forms)
concerns partitions of posets into chains and antichains. In the well-founded FAC setting
considered here we produce a single chain that meets every nonempty level set of the poset,
where the levels are indexed by the ordinal-valued *height* (well-founded rank) function.

## Main definitions

* `FAC P` : the finite antichain condition on a preorder `P`.
* `height x` : the ordinal well-founded rank of `x` with respect to `(· < ·)`.
* `levelSet α` : the set of elements of a given height `α`.

## Main statements

* `height_strict_mono` : the height is strictly monotone.
* `level_is_antichain`, `level_finite` : each level set is a finite antichain.
* `levels_disjoint`, `levels_cover` : the level sets partition the poset.
* `height_down_realize` : downward realizability of heights below a given element.
* `finite_chain_hits` : a finite family of nonempty levels can be met by a single chain.
* `wellFoundedFAC_aharoni_korman` : the main theorem — a single chain meets every
  nonempty level.
-/

/-- The Finite Antichain Condition: every antichain (with respect to the strict order `<`)
is finite. -/
class FAC (P : Type*) [Preorder P] : Prop where
  finite_antichain : ∀ s : Set P, IsAntichain (· < ·) s → s.Finite

variable {P : Type*} [Preorder P] [IsWellFounded P (· < ·)]

/-- The height of an element is its well-founded rank with respect to the strict order. -/
noncomputable def height (x : P) : Ordinal := IsWellFounded.rank (· < ·) x

/-- The set of elements of a given height `α`. -/
def levelSet (α : Ordinal) : Set P := {x : P | height x = α}

/-- The height is strictly monotone: `x < y` implies `height x < height y`. -/
theorem height_strict_mono {x y : P} (h : x < y) : height x < height y := by
  convert IsWellFounded.rank_lt_of_rel h using 1

/-- Two distinct elements of the same height cannot be strictly comparable, so each
level set is an antichain. -/
theorem level_is_antichain (α : Ordinal) : IsAntichain (· < ·) (levelSet (P := P) α) := by
  intro x hx y hy hxy
  exact fun h => ne_of_lt (height_strict_mono h) (hx.trans hy.symm)

/-- Each level set is finite, by the finite antichain condition. -/
theorem level_finite [FAC P] (α : Ordinal) : (levelSet (P := P) α).Finite :=
  FAC.finite_antichain _ (level_is_antichain α)

/-- Distinct levels are disjoint. -/
theorem levels_disjoint {α β : Ordinal} (h : α ≠ β) :
    levelSet (P := P) α ∩ levelSet β = ∅ := by
  exact Set.eq_empty_of_forall_notMem fun x hx => h <| hx.1.symm.trans hx.2

/-- The level sets cover the whole poset: every element has a height. -/
theorem levels_cover : (⋃ α, levelSet (P := P) α) = Set.univ :=
  Set.eq_univ_of_forall fun x => Set.mem_iUnion.2 ⟨height x, rfl⟩

/-- Downward realizability of heights: if `α ≤ height w`, then some element `u ≤ w`
has height exactly `α`. -/
theorem height_down_realize (w : P) (α : Ordinal) (h : α ≤ height w) :
    ∃ u, u ≤ w ∧ height u = α := by
  induction' h : height w using Ordinal.induction with β ih generalizing w;
  by_cases hαβ : α < β;
  · -- Since α < β, there exists some b < w such that α ≤ height b.
    obtain ⟨b, hb₁, hb₂⟩ : ∃ b < w, α ≤ height b := by
      contrapose! hαβ;
      convert IsWellFounded.rank_eq ( · < · ) w |> le_of_eq |> le_trans <| ?_;
      · exact h.symm;
      · refine' ciSup_le' _;
        exact fun i => Order.succ_le_of_lt ( hαβ _ i.2 );
    exact Exists.elim (ih _ (height_strict_mono hb₁ |> lt_of_lt_of_le <| h.le) _ hb₂ rfl)
      fun u hu => ⟨u, hu.1.trans hb₁.le, hu.2⟩
  · grind +splitIndPred

/-
Helper for `finite_chain_hits`: given a finite set `S` of ordinals all bounded by
`height w`, there is a chain lying entirely below `w` that meets every level in `S`.

The chain is built top-down: pick the largest ordinal `M` in `S`, realize it by some
`u ≤ w` (via `height_down_realize`), and recurse on `S.erase M` with the smaller element
`u`. Since heights are strictly monotone, the resulting elements form a descending chain.
-/
lemma chain_below [FAC P] (S : Finset Ordinal) (w : P) (hw : ∀ α ∈ S, α ≤ height w) :
    ∃ C : Set P, IsChain (· ≤ ·) C ∧ (∀ x ∈ C, x ≤ w) ∧
      ∀ α ∈ S, (C ∩ levelSet α).Nonempty := by
  induction' S using Finset.strongInduction with S ih generalizing w;
  by_cases hS : S.Nonempty;
  · obtain ⟨M, hM⟩ : ∃ M ∈ S, ∀ α ∈ S, α ≤ M := by
      exact ⟨ Finset.max' S hS, Finset.max'_mem _ _, fun α hα => Finset.le_max' _ _ hα ⟩;
    obtain ⟨u, hu⟩ : ∃ u, u ≤ w ∧ height u = M := by
      exact height_down_realize w M ( hw M hM.1 );
    obtain ⟨C', hC'⟩ := ih (S.erase M) (by
    exact Finset.erase_ssubset hM.1) u (by
    grind);
    refine' ⟨ Insert.insert u C', _, _, _ ⟩ <;> simp_all +decide [ IsChain.insert ];
    · exact fun x hx => le_trans ( hC'.2.1 x hx ) hu.1;
    · intro α hα; by_cases hαM : α = M <;> simp_all +decide [ Set.Nonempty ] ;
      exact Or.inl hu.2;
  · exact ⟨ ∅, by simp +decide [ Finset.not_nonempty_iff_eq_empty.mp hS ] ⟩

/-- **Key combinatorial lemma.** For any finite set `S` of ordinals such that each level
`levelSet α` (`α ∈ S`) is nonempty, there is a single chain `C` meeting every such level.

This is the finitary core of the Aharoni–Korman theorem; the infinite version is obtained
from it by a compactness argument (see `wellFoundedFAC_aharoni_korman`). -/
lemma finite_chain_hits [FAC P] (S : Finset Ordinal)
    (hS : ∀ α ∈ S, (levelSet (P := P) α).Nonempty) :
    ∃ C : Set P, IsChain (· ≤ ·) C ∧ ∀ α ∈ S, (C ∩ levelSet α).Nonempty := by
  rcases S.eq_empty_or_nonempty with hSe | hSne
  · exact ⟨∅, by simp [IsChain, Set.Pairwise], by simp [hSe]⟩
  · set M := S.max' hSne with hM
    obtain ⟨w, hw⟩ := hS M (S.max'_mem hSne)
    have hwh : height w = M := hw
    obtain ⟨C, hchain, _, hhits⟩ := chain_below S w (fun α hα => by
      rw [hwh]; exact S.le_max' α hα)
    exact ⟨C, hchain, hhits⟩

/-- **A König/compactness lemma.** Given a family of nonempty finite "fibers" `V i` and an
arbitrary binary relation `R` between fibers, if *every finite set* `T` of indices admits a
choice `f` making all pairs in `T` related, then there is a single global choice `f` making
*all* pairs related.

Proof: put the discrete topology on each finite `V i`; the product `∀ i, V i` is compact
(Tychonoff). For a finite `T`, the set `K T` of choices satisfying `R` on all pairs in `T`
constrains finitely many coordinates, hence is closed, and is nonempty by hypothesis. The
family `{K T}` is directed downward (`K (T₁ ∪ T₂) ⊆ K T₁ ∩ K T₂`), so Cantor's intersection
theorem gives a point in every `K T`; in particular it satisfies `R` on `{i, j}` for all
`i, j`. -/
lemma exists_global_compatible_of_finset {ι : Type*} (V : ι → Type*)
    [∀ i, Finite (V i)] [∀ i, Nonempty (V i)] (R : ∀ i j, V i → V j → Prop)
    (Hfin : ∀ T : Finset ι, ∃ f : ∀ i, V i, ∀ i ∈ T, ∀ j ∈ T, R i j (f i) (f j)) :
    ∃ f : ∀ i, V i, ∀ i j, R i j (f i) (f j) := by
  classical
  letI : ∀ i, TopologicalSpace (V i) := fun _ => ⊥
  haveI : ∀ i, DiscreteTopology (V i) := fun _ => ⟨rfl⟩
  haveI : ∀ i, CompactSpace (V i) := fun _ => Finite.compactSpace
  set K : Finset ι → Set (∀ i, V i) := fun T => {f | ∀ i ∈ T, ∀ j ∈ T, R i j (f i) (f j)} with hK
  have hclosed : ∀ T, IsClosed (K T) := by
    intro T
    rw [hK]
    simp only [Set.setOf_forall]
    apply isClosed_iInter; intro i
    apply isClosed_iInter; intro hi
    apply isClosed_iInter; intro j
    apply isClosed_iInter; intro hj
    have hcont : Continuous (fun f : (∀ i, V i) => (f i, f j)) :=
      (continuous_apply i).prodMk (continuous_apply j)
    exact (isClosed_discrete {p : V i × V j | R i j p.1 p.2}).preimage hcont
  have hne : ∀ T, (K T).Nonempty := by
    intro T
    obtain ⟨f, hf⟩ := Hfin T
    exact ⟨f, hf⟩
  have hInter : (⋂ T : Finset ι, K T).Nonempty := by
    apply IsCompact.nonempty_iInter_of_directed_nonempty_isCompact_isClosed K
    · intro T₁ T₂
      exact ⟨T₁ ∪ T₂,
        fun f hf i hi j hj => hf i (Finset.mem_union_left _ hi) j (Finset.mem_union_left _ hj),
        fun f hf i hi j hj => hf i (Finset.mem_union_right _ hi) j (Finset.mem_union_right _ hj)⟩
    · exact hne
    · exact fun T => (hclosed T).isCompact
    · exact hclosed
  obtain ⟨f, hf⟩ := hInter
  rw [Set.mem_iInter] at hf
  refine ⟨f, fun i j => ?_⟩
  exact hf {i, j} i (Finset.mem_insert_self _ _) j
    (Finset.mem_insert_of_mem (Finset.mem_singleton_self _))

/-- **Compactness step.** If every *finite* family of nonempty levels can be met by a single
chain, then a single chain meets *every* nonempty level simultaneously.

This is a König/compactness argument. Each level is finite (`level_finite`), so we place the
discrete topology on the (finite, nonempty) subtype of each occupied level, forming a compact
product space `X` by Tychonoff. For a finite set `T` of occupied levels, the set `K T` of
points of `X` whose `T`-coordinates are pairwise comparable is closed (it constrains finitely
many coordinates) and nonempty (by the finite hypothesis `H`). The family `{K T}` is directed
under reverse inclusion since `K (T₁ ∪ T₂) ⊆ K T₁ ∩ K T₂`, so Cantor's intersection theorem
(`IsCompact.nonempty_iInter_of_directed_nonempty_isCompact_isClosed`) yields a point in every
`K T`. Its coordinates are pairwise comparable across all levels, so their range is the desired
global chain. -/
lemma chain_hits_all [FAC P]
    (H : ∀ (S : Finset Ordinal), (∀ α ∈ S, (levelSet (P := P) α).Nonempty) →
        ∃ C : Set P, IsChain (· ≤ ·) C ∧ ∀ α ∈ S, (C ∩ levelSet α).Nonempty) :
    ∃ C : Set P, IsChain (· ≤ ·) C ∧
      ∀ α, (levelSet (P := P) α).Nonempty → (C ∩ levelSet α).Nonempty := by
  classical
  let ι := {α : Ordinal // (levelSet (P := P) α).Nonempty}
  let V : ι → Type _ := fun i => ↥(levelSet (P := P) i.val)
  haveI : ∀ i : ι, Finite (V i) := fun i => (level_finite i.val).to_subtype
  haveI : ∀ i : ι, Nonempty (V i) := fun i => i.2.to_subtype
  let R : ∀ i j : ι, V i → V j → Prop :=
    fun i j a b => ((a : P) ≤ (b : P)) ∨ ((b : P) ≤ (a : P))
  have Hfin : ∀ T : Finset ι, ∃ f : ∀ i, V i, ∀ i ∈ T, ∀ j ∈ T, R i j (f i) (f j) := by
    intro T
    obtain ⟨C, hCchain, hChits⟩ := H (T.image (fun i => i.val)) (by
      intro α hα
      rw [Finset.mem_image] at hα
      obtain ⟨i, _, rfl⟩ := hα
      exact i.2)
    have hpick : ∀ i : ι, i ∈ T → ∃ c : V i, (c : P) ∈ C := by
      intro i hi
      have hmem : i.val ∈ T.image (fun i => i.val) := Finset.mem_image_of_mem _ hi
      obtain ⟨c, hcC, hcL⟩ := hChits i.val hmem
      exact ⟨⟨c, hcL⟩, hcC⟩
    refine ⟨fun i => if hi : i ∈ T then (hpick i hi).choose else Classical.arbitrary _, ?_⟩
    intro i hi j hj
    simp only [dif_pos hi, dif_pos hj]
    have hCi : ((hpick i hi).choose : P) ∈ C := (hpick i hi).choose_spec
    have hCj : ((hpick j hj).choose : P) ∈ C := (hpick j hj).choose_spec
    rcases eq_or_ne ((hpick i hi).choose : P) ((hpick j hj).choose : P) with heq | hne
    · exact Or.inl (le_of_eq heq)
    · exact hCchain hCi hCj hne
  obtain ⟨f, hf⟩ := exists_global_compatible_of_finset V R Hfin
  refine ⟨Set.range (fun i : ι => ((f i : P))), ?_, ?_⟩
  · rintro x ⟨i, rfl⟩ y ⟨j, rfl⟩ hxy
    exact hf i j
  · intro α hα
    exact ⟨((f ⟨α, hα⟩ : P)), Set.mem_range_self _, (f ⟨α, hα⟩).2⟩

/-- **The Aharoni–Korman theorem for well-founded FAC posets.**

There is a single chain `C` meeting every nonempty level set of `P`.

## Proof outline (compactness argument)

The proof upgrades the finitary `finite_chain_hits` to the infinite statement using
Tychonoff's theorem (compactness of a product of compact spaces):

* Each level `levelSet α` is a finite set (`level_finite`), hence compact in the discrete
  topology; when a level is empty we adjoin a one-point space so that every factor is a
  nonempty compact space.
* The product space `X = Π α, (levelSet α)` is compact by Tychonoff.
* For each finite set `S` of ordinals, let `F_S ⊆ X` be the set of choice functions whose
  restriction to the coordinates in `S` is a chain (pairwise `≤`-comparable). Because this
  condition only constrains finitely many coordinates, `F_S` is closed in `X`.
* Each `F_S` is nonempty: apply `finite_chain_hits` to `S` to obtain a chain meeting every
  level in `S`, and read off a point of `F_S` from it (using arbitrary values elsewhere).
* The family `{F_S}` is closed under finite intersections (`F_S ∩ F_T ⊆ F_{S ∪ T}`), so it
  has the finite intersection property.
* By compactness the total intersection `⋂ S, F_S` is nonempty. Any point of it is a global
  choice function that is a chain on all coordinates simultaneously; its image is the desired
  chain meeting every nonempty level.
-/
theorem wellFoundedFAC_aharoni_korman [FAC P] :
    ∃ C : Set P, IsChain (· ≤ ·) C ∧
      ∀ α, (levelSet (P := P) α).Nonempty → (C ∩ levelSet α).Nonempty :=
  chain_hits_all finite_chain_hits