import Physics.WeakD6Core

/-!
# Maximality of the three-middle-layer baseline

The three-consecutive-layer family is the standard weakly `D₆`-free family of
size `≈ 3·C(n, ⌊n/2⌋)`.  This file shows that it is *saturated*: **no** set of
the Boolean lattice can be added to it without creating a weak copy of `D₆`,
provided the ground set is large enough for a distance-`3` interval to fit.

* `WeakD6.not_weaklyD6Free_of_interval_subset` — the basic obstruction: a full
  distance-`3` interval inside a family is a weak `D₆`.
* `WeakD6.fourLayerFamily_not_weaklyD6Free` — four consecutive full layers are
  **not** weakly `D₆`-free, so any four-layer construction must delete sets.
* `WeakD6.threeLayerFamily_insert_above_not_free`,
  `WeakD6.threeLayerFamily_insert_below_not_free` — adding a single set from the
  layer just above (resp. just below) the baseline destroys freeness.
* `WeakD6.threeLayerFamily_saturated` — the baseline is a maximal weakly
  `D₆`-free family inside the four-layer window.

Combined with `Physics.WeakD6AbelianNoGo` this delimits the search space for a
constant-factor improvement `c > 3`: one must delete from the *interior* layers,
and the deletion pattern cannot come from an abelian sum-labelling.
-/

namespace WeakD6

open Finset

/-- A family containing an entire distance-`3` interval weakly contains `D₆`. -/
theorem not_weaklyD6Free_of_interval_subset {F : Finset (Finset ℕ)} {A C : Finset ℕ}
    (hA : A ∈ F) (hC : C ∈ F) (hAC : A ⊆ C) (hcard : C.card = A.card + 3)
    (hint : openInterval A C ⊆ F) : ¬ WeaklyDiamondFree 6 F := by
  intro hfree
  obtain ⟨B, hAB, hBC, hBF⟩ := exclusion_of_weaklyD6Free hfree hA hC hAC hcard
  exact hBF (hint (mem_openInterval.2 ⟨hAB, hBC⟩))

/-- The four-layer window `k, k+1, k+2, k+3`. -/
def fourLayerFamily (n k : ℕ) : Finset (Finset ℕ) :=
  threeLayerFamily n k ∪ layer n (k + 3)

lemma mem_threeLayerFamily {n k : ℕ} {S : Finset ℕ} :
    S ∈ threeLayerFamily n k ↔
      S ⊆ Finset.range n ∧ (S.card = k ∨ S.card = k + 1 ∨ S.card = k + 2) := by
  simp only [threeLayerFamily, Finset.mem_union, mem_layer]
  constructor
  · rintro ((⟨h, hc⟩ | ⟨h, hc⟩) | ⟨h, hc⟩) <;> exact ⟨h, by omega⟩
  · rintro ⟨h, hc | hc | hc⟩
    · exact Or.inl (Or.inl ⟨h, hc⟩)
    · exact Or.inl (Or.inr ⟨h, hc⟩)
    · exact Or.inr ⟨h, hc⟩

/-- Every set strictly between a `k`-set and a `(k+3)`-set has size `k+1` or `k+2`. -/
lemma card_mem_openInterval {A C B : Finset ℕ} (hcard : C.card = A.card + 3)
    (hB : B ∈ openInterval A C) : B.card = A.card + 1 ∨ B.card = A.card + 2 := by
  rw [mem_openInterval] at hB
  have h1 := Finset.card_lt_card hB.1
  have h2 := Finset.card_lt_card hB.2
  omega

/-- **The four-layer window is not free.**  Four consecutive full layers of
`2^[n]` always contain a weak copy of `D₆` (as soon as `k + 3 ≤ n`), so every
attempt to beat the three-layer baseline inside four layers must delete sets. -/
theorem fourLayerFamily_not_weaklyD6Free (n k : ℕ) (hn : k + 3 ≤ n) :
    ¬ WeaklyDiamondFree 6 (fourLayerFamily n k) := by
  classical
  obtain ⟨A, hAsub, hAcard⟩ :=
    Finset.exists_subset_card_eq (show k ≤ (Finset.range n).card by simpa using by omega)
  obtain ⟨C, hAC, hCsub, hCcard⟩ :=
    Finset.exists_subsuperset_card_eq hAsub (by omega : A.card ≤ k + 3)
      (by simpa using (by omega : k + 3 ≤ n))
  refine not_weaklyD6Free_of_interval_subset (A := A) (C := C) ?_ ?_ hAC (by omega) ?_
  · exact Finset.mem_union_left _ (mem_threeLayerFamily.2 ⟨hAsub, Or.inl hAcard⟩)
  · exact Finset.mem_union_right _ (mem_layer.2 ⟨hCsub, hCcard⟩)
  · intro B hB
    have hBsub : B ⊆ Finset.range n := (mem_openInterval.1 hB).2.1.trans hCsub
    rcases card_mem_openInterval (by omega) hB with hb | hb
    · exact Finset.mem_union_left _ (mem_threeLayerFamily.2 ⟨hBsub, Or.inr (Or.inl (by omega))⟩)
    · exact Finset.mem_union_left _ (mem_threeLayerFamily.2 ⟨hBsub, Or.inr (Or.inr (by omega))⟩)

/-- **Saturation from above.**  Adding any set of the next layer up to the
three-layer baseline creates a weak `D₆`. -/
theorem threeLayerFamily_insert_above_not_free (n k : ℕ) {X : Finset ℕ}
    (hXsub : X ⊆ Finset.range n) (hXcard : X.card = k + 3) :
    ¬ WeaklyDiamondFree 6 (insert X (threeLayerFamily n k)) := by
  classical
  obtain ⟨A, hAX, hAcard⟩ := Finset.exists_subset_card_eq (show k ≤ X.card by omega)
  refine not_weaklyD6Free_of_interval_subset (A := A) (C := X) ?_ (Finset.mem_insert_self _ _)
    hAX (by omega) ?_
  · exact Finset.mem_insert_of_mem
      (mem_threeLayerFamily.2 ⟨hAX.trans hXsub, Or.inl hAcard⟩)
  · intro B hB
    have hBsub : B ⊆ Finset.range n := (mem_openInterval.1 hB).2.1.trans hXsub
    rcases card_mem_openInterval (by omega) hB with hb | hb
    · exact Finset.mem_insert_of_mem
        (mem_threeLayerFamily.2 ⟨hBsub, Or.inr (Or.inl (by omega))⟩)
    · exact Finset.mem_insert_of_mem
        (mem_threeLayerFamily.2 ⟨hBsub, Or.inr (Or.inr (by omega))⟩)

/-- **Saturation from below.**  Adding any set of the next layer down to the
three-layer baseline (here the layers `k+1, k+2, k+3`) creates a weak `D₆`. -/
theorem threeLayerFamily_insert_below_not_free (n k : ℕ) (hn : k + 3 ≤ n) {X : Finset ℕ}
    (hXsub : X ⊆ Finset.range n) (hXcard : X.card = k) :
    ¬ WeaklyDiamondFree 6 (insert X (threeLayerFamily n (k + 1))) := by
  classical
  obtain ⟨C, hXC, hCsub, hCcard⟩ :=
    Finset.exists_subsuperset_card_eq hXsub (by omega : X.card ≤ k + 3)
      (by simpa using (by omega : k + 3 ≤ n))
  refine not_weaklyD6Free_of_interval_subset (A := X) (C := C) (Finset.mem_insert_self _ _) ?_
    hXC (by omega) ?_
  · exact Finset.mem_insert_of_mem
      (mem_threeLayerFamily.2 ⟨hCsub, Or.inr (Or.inr (by omega))⟩)
  · intro B hB
    have hBsub : B ⊆ Finset.range n := (mem_openInterval.1 hB).2.1.trans hCsub
    rcases card_mem_openInterval (by omega) hB with hb | hb
    · exact Finset.mem_insert_of_mem
        (mem_threeLayerFamily.2 ⟨hBsub, Or.inl (by omega)⟩)
    · exact Finset.mem_insert_of_mem
        (mem_threeLayerFamily.2 ⟨hBsub, Or.inr (Or.inl (by omega))⟩)

/-- **The baseline is saturated inside its four-layer window.**  Every set of
the window that is not already in the three-layer family destroys freeness when
added. -/
theorem threeLayerFamily_saturated (n k : ℕ) {X : Finset ℕ}
    (hX : X ∈ fourLayerFamily n k) (hXnew : X ∉ threeLayerFamily n k) :
    ¬ WeaklyDiamondFree 6 (insert X (threeLayerFamily n k)) := by
  have hXlayer : X ∈ layer n (k + 3) := by
    rcases Finset.mem_union.1 hX with h | h
    · exact absurd h hXnew
    · exact h
  rw [mem_layer] at hXlayer
  exact threeLayerFamily_insert_above_not_free n k hXlayer.1 hXlayer.2

end WeakD6