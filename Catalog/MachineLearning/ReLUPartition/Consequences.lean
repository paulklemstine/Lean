import Mathlib
import MachineLearning.ReLUPartition.MomentSharp

/-!
# Consequences of the exact region formula

Three exact corollaries of `maximum_regionCount`:

* the **deletion–restriction (Zaslavsky) recurrence** holds *exactly* for the
  maximum region counts: one extra neuron contributes the maximum region count
  of the same width in one dimension less;
* the maximum region count is **strictly increasing in the width** as soon as
  the input dimension is positive — every added neuron really does buy new
  cells;
* the family of activation patterns of the optimal layer has **VC dimension
  exactly `min n d`**, so the Sauer–Shelah step in the proof of the upper bound
  is tight, and the exponent `d` in `∑_{k ≤ d} C(n,k)` cannot be lowered.
-/

open Finset

namespace ReLUPartition

variable {n d : ℕ}

/-- **Exact deletion–restriction recurrence.**  Adding one neuron to an optimal
width-`n` layer on `ℝ^{d+1}` adds exactly the maximum number of regions of a
width-`n` layer on `ℝ^d`. -/
theorem regionCount_recurrence (n d : ℕ) :
    (momentFamily (n + 1) (d + 1)).regionCount
      = (momentFamily n (d + 1)).regionCount + (momentFamily n d).regionCount := by
  rw [regionCount_momentFamily, regionCount_momentFamily, regionCount_momentFamily]
  exact schlafli_succ_succ n d

/-- **Every neuron counts.**  In positive input dimension the maximum region
count is strictly increasing in the width. -/
theorem regionCount_strictMono_width (n : ℕ) {d : ℕ} (hd : 1 ≤ d) :
    (momentFamily n d).regionCount < (momentFamily (n + 1) d).regionCount := by
  obtain ⟨e, rfl⟩ : ∃ e, d = e + 1 := ⟨d - 1, by omega⟩
  rw [regionCount_momentFamily, regionCount_momentFamily, schlafli_succ_succ]
  have := schlafli_pos n e
  omega

/-- The initial segment of the first `k` neurons has exactly `k` elements. -/
lemma card_initSeg {n k : ℕ} (hk : k ≤ n) : (AffineFamily.initSeg n k).card = k := by
  classical
  have himg : AffineFamily.initSeg n k
      = (univ : Finset (Fin k)).image (fun j : Fin k => (⟨j, lt_of_lt_of_le j.isLt hk⟩ : Fin n)) := by
    ext i
    simp only [AffineFamily.mem_initSeg, Finset.mem_image, Finset.mem_univ, true_and]
    constructor
    · intro hi
      exact ⟨⟨i, hi⟩, Fin.ext rfl⟩
    · rintro ⟨j, rfl⟩
      exact j.isLt
  rw [himg, Finset.card_image_of_injective _ (fun a b hab => Fin.ext (by
    simpa using congrArg Fin.val hab)), Finset.card_univ, Fintype.card_fin]

/-- **The Sauer–Shelah step is tight.**  The activation patterns of the optimal
width-`n` layer on `ℝ^d` shatter every set of size `min n d`; combined with the
Radon obstruction this pins the VC dimension at exactly `min n d`. -/
theorem vcDim_regions_momentFamily (n d : ℕ) :
    (momentFamily n d).regions.vcDim = min n d := by
  classical
  refine le_antisymm ?_ ?_
  · refine Finset.sup_le fun s hs => ?_
    have h1 : s.card ≤ d := (momentFamily n d).card_le_of_shatters (mem_shatterer.mp hs)
    have h2 : s.card ≤ n := by
      simpa using Finset.card_le_univ s
    omega
  · -- the first `min n d` neurons are shattered
    set k : ℕ := min n d with hk
    have hkn : k ≤ n := by omega
    have hkd : k ≤ d := by omega
    have hshat : (momentFamily n d).regions.Shatters (AffineFamily.initSeg n k) := by
      intro u hu
      refine ⟨u ∪ (univ.filter (fun i : Fin n => k ≤ (i : ℕ))), ?_, ?_⟩
      · -- realizability: the change set is contained in the initial segment
        refine mem_regions_of_changeSet_card_le ?_
        have hsub : changeSet (u ∪ (univ.filter (fun i : Fin n => k ≤ (i : ℕ))))
            ⊆ AffineFamily.initSeg n k := by
          intro j hj
          rw [AffineFamily.mem_initSeg]
          by_contra hjk
          push_neg at hjk
          have h1 : ind (u ∪ (univ.filter (fun i : Fin n => k ≤ (i : ℕ)))) (j : ℕ) = true := by
            have : j ∈ u ∪ (univ.filter (fun i : Fin n => k ≤ (i : ℕ))) := by
              refine Finset.mem_union_right _ ?_
              simp [hjk]
            simpa using this
          have h2 : ind (u ∪ (univ.filter (fun i : Fin n => k ≤ (i : ℕ)))) ((j : ℕ) + 1) = true := by
            by_cases hlt : (j : ℕ) + 1 < n
            · have hmem : (⟨(j : ℕ) + 1, hlt⟩ : Fin n)
                  ∈ u ∪ (univ.filter (fun i : Fin n => k ≤ (i : ℕ))) := by
                refine Finset.mem_union_right _ ?_
                simp only [Finset.mem_filter, Finset.mem_univ, true_and]
                omega
              simpa [ind, hlt] using hmem
            · exact ind_of_ge _ (by omega)
          exact (mem_changeSet.mp hj) (h1.trans h2.symm)
        calc (changeSet (u ∪ (univ.filter (fun i : Fin n => k ≤ (i : ℕ))))).card
            ≤ (AffineFamily.initSeg n k).card := Finset.card_le_card hsub
          _ = k := card_initSeg hkn
          _ ≤ d := hkd
      · -- the trace on the initial segment is exactly `u`
        ext i
        simp only [Finset.mem_inter, Finset.mem_union, Finset.mem_filter, Finset.mem_univ,
          true_and, AffineFamily.mem_initSeg]
        constructor
        · rintro ⟨hi, hu' | hu'⟩
          · exact hu'
          · omega
        · intro hiu
          have hit : i ∈ AffineFamily.initSeg n k := hu hiu
          rw [AffineFamily.mem_initSeg] at hit
          exact ⟨hit, Or.inl hiu⟩
    have := hshat.card_le_vcDim
    rwa [card_initSeg hkn] at this

end ReLUPartition