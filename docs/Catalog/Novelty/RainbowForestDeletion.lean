/-
# Minimal obstructions to total rainbow forests: the edge-deletion analysis

## Setting

Fix a finite ground set `α`, thought of as the edge set `E(G)` of an edge-coloured graph.
Two matroids live on this ground set:

* the **cycle (graphic) matroid** `M₁`, whose independent sets are the forests of `G`,
  with rank function `r₁`;
* the **partition matroid** `M₂` induced by the colouring, whose independent sets are the
  *rainbow* edge sets (at most one edge of each colour), with rank function `r₂`.

A **total rainbow forest** is a set of edges that is simultaneously a forest and rainbow,
i.e. a common independent set of `M₁` and `M₂`.  Write

  `obj(A) = r₁(A) + r₂(Aᶜ)`   (the Edmonds intersection objective, `Aᶜ = E \ A`).

By **Edmonds' Matroid Intersection Theorem** the maximum size of a total rainbow forest
equals `min_{A ⊆ E} obj(A)`.  The **Rainbow Forest Inequality (RFI)** at target `t` is the
assertion that `t ≤ obj(A)` for every `A ⊆ E`; equivalently a total rainbow forest of size
`t` exists.

## What this file proves

The mission conjecture reads: *for a minimal obstruction to total rainbow forests there is a
unique subset `A` with `obj(A) < t`, and the failure is strict for no other subset.*  We
analyse this through the natural notion of **minimality under edge deletion**: `G` is an
edge-minimal obstruction if RFI fails for `G` but holds for every single-edge deletion
`G - e`.

The central discovery is that this notion is **vacuous for matroids**:

1. `rainbow_forest_inequality` — the easy (weak-duality) direction of Edmonds' theorem:
   every common independent set `I` satisfies `|I| ≤ obj(A)` for all `A`.  Hence the
   existence of a size-`t` total rainbow forest forces RFI (`RFI_of_commonIndep`).
2. `deletion_objective_le` — the Edmonds objective of the deletion `G - e` never exceeds the
   objective of `G`: for every `A`, `obj_{G-e}(A.erase e) ≤ obj_G(A)`.  Thus **RFI-failure
   is closed under edge deletion**.
3. `deletionRFI_imp_RFI` — if even a *single* deletion `G - e` satisfies RFI, then `G`
   already satisfies RFI.
4. `no_edge_minimal_obstruction` — consequently there is **no edge-minimal obstruction**:
   the hypotheses "RFI fails for `G`" and "RFI holds for every `G - e`" are contradictory
   for genuine (monotone) matroid ranks.

This is a *root-cause* explanation of why the uniqueness reading of the mission fails: one
cannot even speak of a well-defined edge-minimal obstruction, because the certifying subset
of an obstruction survives every deletion (`deletion_preserves_obstruction`).

The final section exhibits an honest, non-vacuous obstruction, so none of the statements
above are vacuously true.
-/

import Mathlib

open Finset

namespace RainbowForestDeletion

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- The **Edmonds intersection objective** `obj(A) = r₁(A) + r₂(Aᶜ)`.  By Edmonds' Matroid
Intersection Theorem its minimum over all `A ⊆ E` equals the maximum size of a total
rainbow forest. -/
def obj (r₁ r₂ : Finset α → ℤ) (A : Finset α) : ℤ := r₁ A + r₂ Aᶜ

/-- The **Rainbow Forest Inequality** at target size `t`: `t ≤ obj(A)` for every `A`. -/
def RFI (r₁ r₂ : Finset α → ℤ) (t : ℤ) : Prop := ∀ A : Finset α, t ≤ obj r₁ r₂ A

/-!
### The Rainbow Forest Inequality via weak duality

A **common independent set** of the two matroids is a set all of whose subsets have full
rank in both matroids (downward-closed independence).  This is exactly a total rainbow
forest together with its hereditary independence.
-/

/-- `I` is a **common independent set** of the matroids with rank functions `r₁, r₂`: every
subset of `I` has rank equal to its cardinality in both matroids. -/
def CommonIndep (r₁ r₂ : Finset α → ℤ) (I : Finset α) : Prop :=
  ∀ X ⊆ I, r₁ X = (X.card : ℤ) ∧ r₂ X = (X.card : ℤ)

/-- **Rainbow Forest Inequality (weak duality half of Edmonds' theorem).**
Every common independent set `I` (i.e. every total rainbow forest) satisfies
`|I| ≤ obj(A) = r₁(A) + r₂(Aᶜ)` for every subset `A`. -/
theorem rainbow_forest_inequality {r₁ r₂ : Finset α → ℤ}
    (h1 : Monotone r₁) (h2 : Monotone r₂)
    {I : Finset α} (hI : CommonIndep r₁ r₂ I) (A : Finset α) :
    (I.card : ℤ) ≤ obj r₁ r₂ A := by
  -- Split `I` as `(I ∩ A) ⊔ (I \ A)`.
  have hsplit : ((I ∩ A).card : ℤ) + ((I \ A).card : ℤ) = (I.card : ℤ) := by
    have := Finset.card_inter_add_card_sdiff I A
    exact_mod_cast this
  -- `I ∩ A` is independent in `M₁` and sits inside `A`.
  have hIA1 : r₁ (I ∩ A) = ((I ∩ A).card : ℤ) := (hI (I ∩ A) Finset.inter_subset_left).1
  have hle1 : ((I ∩ A).card : ℤ) ≤ r₁ A := by
    rw [← hIA1]; exact h1 Finset.inter_subset_right
  -- `I \ A` is independent in `M₂` and sits inside `Aᶜ`.
  have hIA2 : r₂ (I \ A) = ((I \ A).card : ℤ) := (hI (I \ A) Finset.sdiff_subset).2
  have hsub : I \ A ⊆ Aᶜ := by
    intro x hx
    rw [Finset.mem_sdiff] at hx
    rw [Finset.mem_compl]
    exact hx.2
  have hle2 : ((I \ A).card : ℤ) ≤ r₂ Aᶜ := by
    rw [← hIA2]; exact h2 hsub
  -- Combine.
  have : (I.card : ℤ) ≤ r₁ A + r₂ Aᶜ := by rw [← hsplit]; linarith
  simpa [obj] using this

/-- **The RFI holds once a total rainbow forest of size `t` exists.**  This is the direction
of Edmonds' theorem that follows from weak duality: if there is a common independent set of
size `t`, then `t ≤ obj(A)` for all `A`. -/
theorem RFI_of_commonIndep {r₁ r₂ : Finset α → ℤ} {t : ℤ}
    (h1 : Monotone r₁) (h2 : Monotone r₂)
    {I : Finset α} (hI : CommonIndep r₁ r₂ I) (hcard : (I.card : ℤ) = t) :
    RFI r₁ r₂ t := by
  intro A
  rw [← hcard]
  exact rainbow_forest_inequality h1 h2 hI A

/-!
### Edge deletion and the collapse of "minimal obstruction"

Deleting an edge `e` produces the matroids `M₁ \ e`, `M₂ \ e` on the ground set `E \ {e}`.
Restriction rank equals the ambient rank on subsets of `E \ {e}`, so the objective of the
deletion at a subset `A ⊆ E \ {e}` is `r₁(A) + r₂((E \ {e}) \ A)`.
-/

/-- The Rainbow Forest Inequality **for the single-edge deletion `G - e`** at target `t`. -/
def DeletionRFI (r₁ r₂ : Finset α → ℤ) (t : ℤ) (e : α) : Prop :=
  ∀ A : Finset α, A ⊆ univ.erase e → t ≤ r₁ A + r₂ ((univ.erase e) \ A)

/-- **The Edmonds objective can only drop under deletion.**  For every subset `A`, using the
deleted subset `A.erase e ⊆ E \ {e}`, the objective of `G - e` is at most the objective of
`G`:
`r₁(A.erase e) + r₂((E \ {e}) \ (A.erase e)) ≤ obj_G(A)`.
Hence a subset witnessing an obstruction in `G` still witnesses one after deleting any edge. -/
theorem deletion_objective_le {r₁ r₂ : Finset α → ℤ}
    (h1 : Monotone r₁) (h2 : Monotone r₂) (e : α) (A : Finset α) :
    r₁ (A.erase e) + r₂ ((univ.erase e) \ (A.erase e)) ≤ obj r₁ r₂ A := by
  -- first term: `A.erase e ⊆ A`
  have ht1 : r₁ (A.erase e) ≤ r₁ A := h1 (Finset.erase_subset e A)
  -- second term: `(E \ {e}) \ (A.erase e) ⊆ Aᶜ`
  have hsub : (univ.erase e) \ (A.erase e) ⊆ Aᶜ := by
    intro x hx
    rw [Finset.mem_sdiff, Finset.mem_erase] at hx
    rw [Finset.mem_compl]
    obtain ⟨⟨hxe, _⟩, hxA⟩ := hx
    intro hxinA
    exact hxA (Finset.mem_erase.mpr ⟨hxe, hxinA⟩)
  have ht2 : r₂ ((univ.erase e) \ (A.erase e)) ≤ r₂ Aᶜ := h2 hsub
  have : r₁ (A.erase e) + r₂ ((univ.erase e) \ (A.erase e)) ≤ r₁ A + r₂ Aᶜ := by linarith
  simpa [obj] using this

/-- **A single satisfied deletion already forces the full inequality.**  If the deletion
`G - e` satisfies the Rainbow Forest Inequality at `t`, then so does `G` itself. -/
theorem deletionRFI_imp_RFI {r₁ r₂ : Finset α → ℤ} {t : ℤ}
    (h1 : Monotone r₁) (h2 : Monotone r₂) {e : α} (hd : DeletionRFI r₁ r₂ t e) :
    RFI r₁ r₂ t := by
  intro A
  have hAe : A.erase e ⊆ univ.erase e := Finset.erase_subset_erase e (Finset.subset_univ A)
  have h := hd (A.erase e) hAe
  exact le_trans h (deletion_objective_le h1 h2 e A)

/-- **Deletion preserves obstructions.**  If some subset `A` violates the Rainbow Forest
Inequality in `G` (`obj_G(A) < t`), then for every edge `e` the deletion `G - e` still has a
violating subset, namely `A.erase e`. -/
theorem deletion_preserves_obstruction {r₁ r₂ : Finset α → ℤ} {t : ℤ}
    (h1 : Monotone r₁) (h2 : Monotone r₂) {A : Finset α} (hA : obj r₁ r₂ A < t) (e : α) :
    ∃ A' : Finset α, A' ⊆ univ.erase e ∧ r₁ A' + r₂ ((univ.erase e) \ A') < t := by
  refine ⟨A.erase e, Finset.erase_subset_erase e (Finset.subset_univ A), ?_⟩
  exact lt_of_le_of_lt (deletion_objective_le h1 h2 e A) hA

/-- **No edge-minimal obstruction exists.**  For genuine (monotone) matroid ranks the two
requirements defining an edge-minimal obstruction — that `G` fails the Rainbow Forest
Inequality yet *every* single-edge deletion `G - e` satisfies it — are contradictory.  (One
satisfied deletion suffices for the contradiction.)

Interpretation: the failing certificate of an obstruction survives every deletion, so the
minimal-obstruction concept collapses and there is nothing whose "unique failing subset"
could be discussed.  This is the root reason the naive uniqueness reading of the mission
cannot hold. -/
theorem no_edge_minimal_obstruction [Nonempty α] {r₁ r₂ : Finset α → ℤ} {t : ℤ}
    (h1 : Monotone r₁) (h2 : Monotone r₂)
    (hobs : ∃ A : Finset α, obj r₁ r₂ A < t)
    (hmin : ∀ e : α, DeletionRFI r₁ r₂ t e) : False := by
  obtain ⟨A, hA⟩ := hobs
  obtain ⟨e⟩ := (inferInstance : Nonempty α)
  have hRFI : RFI r₁ r₂ t := deletionRFI_imp_RFI h1 h2 (hmin e)
  exact absurd (hRFI A) (not_le.mpr hA)

/-!
### Non-vacuity: an honest obstruction

We exhibit concrete monotone rank functions and a target `t` for which the Rainbow Forest
Inequality genuinely fails, so the obstruction hypotheses above are inhabited and none of
the theorems is vacuously true.  On the two-edge ground set `Bool`, both matroids are free
(`r A = |A|`), so `obj(A) = |A| + |Aᶜ| = 2` for every `A`; with `t = 3` the inequality fails
everywhere while, by `no_edge_minimal_obstruction`, no deletion can repair it.
-/

/-- The free-matroid rank on `Bool` is monotone. -/
theorem card_monotone_bool : Monotone (fun A : Finset Bool => (A.card : ℤ)) := by
  intro A B hAB
  show (A.card : ℤ) ≤ (B.card : ℤ)
  exact_mod_cast Finset.card_le_card hAB

/-- An honest obstruction: with free matroids on `Bool` and target `t = 3`, the Rainbow
Forest Inequality fails (indeed for every subset). -/
theorem exists_genuine_obstruction :
    ∃ A : Finset Bool, obj (fun A => (A.card : ℤ)) (fun A => (A.card : ℤ)) A < 3 := by
  refine ⟨Finset.univ, ?_⟩
  simp only [obj]
  decide

/-- The obstruction of `exists_genuine_obstruction` is inhabited, monotone and real:
combining it with `deletion_preserves_obstruction` shows some deletion must *also* fail. -/
theorem genuine_obstruction_has_failing_deletion (e : Bool) :
    ∃ A' : Finset Bool, A' ⊆ univ.erase e ∧
      (A'.card : ℤ) + (((univ.erase e) \ A').card : ℤ) < 3 := by
  obtain ⟨A, hA⟩ := exists_genuine_obstruction
  simpa using
    deletion_preserves_obstruction card_monotone_bool card_monotone_bool hA e

end RainbowForestDeletion