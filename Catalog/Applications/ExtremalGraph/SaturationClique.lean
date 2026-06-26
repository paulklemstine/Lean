/-
# Saturation, the matching family, and the Turán / Erdős–Hajnal–Moon bridge

Building on `Applications.ExtremalGraph.Saturation`, this file pins down the **edge counts of the
mission's graph families** and bridges the saturation parameter to the classical **extremal (Turán)
number**, the setting of the Erdős–Hajnal–Moon theorem on clique saturation.

* `edgeCount_matchingPlusIsolated`: the graph `F = tK₂ ∪ qK₁` has exactly `t` edges.
* `edgeCount_cone_matchingPlusIsolated`: hence the apex join `K₁ ∨ F` has exactly `(2t+q) + t`
  edges — the explicit edge count of the Cameron–Puleo extremal construction.
* `satNum_clique_le_turan`: for `r ≥ 1`, the clique saturation number is bounded by the number of
  edges of the Turán graph, `sat(n, K_{r+1}) ≤ e(T(n, r))`.  This combines the foundation's
  `satNum ≤ exNum` with Mathlib's Turán edge bound `CliqueFree.card_edgeFinset_le`, linking the
  *saturation* world to the *extremal* world.
-/
import Applications.ExtremalGraph.Saturation

open Finset SimpleGraph

namespace Saturation

/-! ## Edge counts of the mission's graph families -/

/-- **`F = tK₂ ∪ qK₁` has exactly `t` edges.** -/
theorem edgeCount_matchingPlusIsolated (t q : ℕ) :
    edgeCount (matchingPlusIsolated t q) = t := by
  -- The image of Fin t under the given function is exactly the edge set of matchingPlusIsolated t q.
  have h_image : (Finset.univ.image (fun k : Fin t => Sym2.mk (⟨2 * k, by omega⟩, ⟨2 * k + 1, by omega⟩))) = (matchingPlusIsolated t q).edgeFinset := by
    ext ⟨x, y⟩; simp [matchingPlusIsolated];
    constructor <;> intro h;
    · lia;
    · cases lt_or_gt_of_ne ( show ( x : ℕ ) ≠ y from by simpa [ Fin.ext_iff ] using h.2.2.2 ) <;> [ refine' ⟨ ⟨ x / 2, by omega ⟩, Or.inl ⟨ _, _ ⟩ ⟩ ; refine' ⟨ ⟨ y / 2, by omega ⟩, Or.inr ⟨ _, _ ⟩ ⟩ ] <;> simp_all +decide [ Fin.ext_iff ];
      · omega;
      · omega;
      · omega;
      · omega;
  convert congr_arg Finset.card h_image.symm using 1;
  · rw [ ← Set.ncard_coe_finset ] ; aesop;
  · rw [ Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
    exact fun a₁ a₂ h => Fin.ext <| by omega;

/-- **The apex join `K₁ ∨ F` has exactly `(2t+q) + t` edges.** This is the explicit edge count of the
Cameron–Puleo extremal construction for `F = tK₂ ∪ qK₁`: the `2t+q` apex edges plus the `t` edges of
`F`. -/
theorem edgeCount_cone_matchingPlusIsolated (t q : ℕ) :
    edgeCount (cone (matchingPlusIsolated t q)) = (2 * t + q) + t := by
  rw [edgeCount_cone, edgeCount_matchingPlusIsolated]
  simp

/-! ## Bridge to the extremal / Turán world (Erdős–Hajnal–Moon setting) -/

/-- `edgeCount` agrees with the cardinality of the edge `Finset` on a finite vertex type. -/
theorem edgeCount_eq_card_edgeFinset {V : Type*} [Fintype V] [DecidableEq V] (G : SimpleGraph V) :
    edgeCount G = G.edgeFinset.card := by
  classical
  rw [edgeCount, Set.ncard_eq_toFinset_card']
  congr 1
  ext e
  simp [Set.mem_toFinset, SimpleGraph.mem_edgeFinset]

/-- **Clique saturation is bounded by the Turán number.** For `r ≥ 1` and every `n`, the saturation
number of the clique `K_{r+1}` is at most the number of edges of the Turán graph `T(n, r)`:
`sat(n, K_{r+1}) ≤ e(T(n, r))`.  This is the bridge `sat ≤ ex` (from the foundation) composed with
Mathlib's Turán edge bound; the exact value of the left side is the content of the Erdős–Hajnal–Moon
theorem. -/
theorem satNum_clique_le_turan (r n : ℕ) (hr : 1 ≤ r) :
    satNum (⊤ : SimpleGraph (Fin (r + 1))) n ≤ (turanGraph n r).edgeFinset.card := by
  classical
  have hab : (⊤ : SimpleGraph (Fin (r + 1))).Adj ⟨0, by omega⟩ ⟨1, by omega⟩ := by
    rw [SimpleGraph.top_adj]
    exact Fin.ne_of_val_ne (by simp)
  refine (satNum_le_exNum _ hab n).trans ?_
  rw [exNum]
  refine Finset.sup_le ?_
  intro G hG
  rw [Finset.mem_filter] at hG
  have hcf : G.CliqueFree (r + 1) := by
    have h := SimpleGraph.cliqueFree_iff_top_free (G := G) (β := Fin (r + 1))
    rw [Fintype.card_fin] at h
    exact h.mpr hG.2
  rw [edgeCount_eq_card_edgeFinset, card_edgeFinset_turanGraph]
  have h := hcf.card_edgeFinset_le
  rw [Fintype.card_fin] at h
  convert h using 2
  ext e
  simp [SimpleGraph.mem_edgeFinset]

end Saturation