import Bridges.DominationPackingRatio

/-!
# An extremal family with `γ = 3ρ` and arbitrarily large packing number

`Bridges.DominationPackingRatio` shows that the Wagner graph `V₈` has `γ = 3` and `ρ = 1`, so
the constant in any Erdős–Pósa bound `γ ≤ c·ρ` is at least `3`.  A single small graph leaves
open the possibility that the ratio `3` is an artefact of a bounded-size example, i.e. that
`γ ≤ ρ + O(1)` or `γ ≤ c·ρ` with `c < 3` for large `ρ`.  This file rules that out.

For every `k` we consider `k` disjoint copies of the Wagner graph, realized on the vertex set
`Fin k × Fin 8` with `(i,a) ∼ (j,b)` iff `i = j` and `a ∼ b` in `V₈`, and prove

* `wagnerCopies_packingNumber : ρ = k` — at most one packing vertex per copy (all radius-`1`
  balls of `V₈` pairwise meet), and exactly one is achievable;
* `wagnerCopies_dominationNumber : γ = 3k` — the fibrewise decomposition of a dominating set
  restricts to a dominating set of each copy, and `γ(V₈) = 3`;
* `wagnerCopies_ratio : γ = 3·ρ` with `ρ = k` arbitrarily large.

The fibrewise counting argument (`Finset.card_eq_sum_card_fiberwise`) is the combinatorial
engine here; it is exactly the additivity of `γ` and `ρ` over connected components, specialized
to a concrete extremal family.
-/

namespace DominationPacking

open Finset

set_option maxRecDepth 100000

/-! ## Two decidable facts about the Wagner graph -/

lemma three_le_card_of_dominating_wagner :
    ∀ D : Finset (Fin 8), IsDominatingSet wagner D → 3 ≤ D.card := by decide

lemma isDominatingSet_wagner_zero_one_two : IsDominatingSet wagner {0, 1, 2} := by decide

lemma wagner_balls_meet : ∀ u v : Fin 8, u ≠ v → ¬ Disjoint (ball wagner u) (ball wagner v) := by
  decide

/-! ## `k` disjoint copies of the Wagner graph -/

/-- `k` disjoint copies of the Wagner graph `V₈`. -/
def wagnerCopies (k : ℕ) : SimpleGraph (Fin k × Fin 8) where
  Adj x y := x.1 = y.1 ∧ wagnerAdj x.2 y.2
  symm := by
    intro x y h
    exact ⟨h.1.symm, wagnerAdj_symm _ _ h.2⟩
  loopless := ⟨fun x h => wagnerAdj_irrefl x.2 h.2⟩

instance (k : ℕ) : DecidableRel (wagnerCopies k).Adj := fun x y =>
  inferInstanceAs (Decidable (x.1 = y.1 ∧ wagnerAdj x.2 y.2))

lemma wagnerCopies_adj_iff {k : ℕ} {x y : Fin k × Fin 8} :
    (wagnerCopies k).Adj x y ↔ x.1 = y.1 ∧ wagner.Adj x.2 y.2 := Iff.rfl

/-- A vertex of a ball in `wagnerCopies k` lies in the same copy. -/
lemma fst_eq_of_mem_ball {k : ℕ} {x y : Fin k × Fin 8} (h : y ∈ ball (wagnerCopies k) x) :
    y.1 = x.1 := by
  rcases h with rfl | hadj
  · rfl
  · exact hadj.1.symm

/-! ## The packing number is `k` -/

theorem wagnerCopies_packingNumber (k : ℕ) : packingNumber (wagnerCopies k) = k := by
  classical
  refine le_antisymm ?_ ?_
  · refine csSup_le (packingSet_nonempty _) ?_
    rintro m ⟨P, hP, rfl⟩
    have hinj : Set.InjOn Prod.fst (P : Set (Fin k × Fin 8)) := by
      intro x hx y hy hxy
      rw [Finset.mem_coe] at hx hy
      by_contra hne
      have hdisj := hP x hx y hy hne
      rw [Set.disjoint_left] at hdisj
      have hsnd : x.2 ≠ y.2 := by
        intro h
        exact hne (Prod.ext hxy h)
      obtain ⟨w, hwx, hwy⟩ := Set.not_disjoint_iff.mp (wagner_balls_meet x.2 y.2 hsnd)
      refine hdisj (a := (x.1, w)) ?_ ?_
      · rcases hwx with rfl | hadj
        · exact Or.inl rfl
        · exact Or.inr ⟨rfl, hadj⟩
      · rcases hwy with rfl | hadj
        · exact Or.inl (by rw [hxy])
        · exact Or.inr ⟨hxy.symm, hadj⟩
    calc P.card ≤ (Finset.univ : Finset (Fin k)).card :=
          Finset.card_le_card_of_injOn Prod.fst (fun a _ => by simp) hinj
      _ = k := by simp
  · have hP : IsPacking (wagnerCopies k) (Finset.univ.image (fun i : Fin k => (i, (0 : Fin 8)))) := by
      intro x hx y hy hxy
      obtain ⟨i, -, rfl⟩ := Finset.mem_image.mp hx
      obtain ⟨j, -, rfl⟩ := Finset.mem_image.mp hy
      have hij : i ≠ j := fun h => hxy (by rw [h])
      rw [Set.disjoint_left]
      intro w hwx hwy
      exact hij ((fst_eq_of_mem_ball hwx).symm.trans (fst_eq_of_mem_ball hwy))
    have hcard : (Finset.univ.image (fun i : Fin k => (i, (0 : Fin 8)))).card = k := by
      rw [Finset.card_image_of_injective _ (fun a b h => (Prod.mk.injEq _ _ _ _ ▸ h).1)]
      simp
    calc k = (Finset.univ.image (fun i : Fin k => (i, (0 : Fin 8)))).card := hcard.symm
      _ ≤ packingNumber (wagnerCopies k) := card_le_packingNumber hP

/-! ## The domination number is `3k` -/

theorem wagnerCopies_dominationNumber (k : ℕ) : dominationNumber (wagnerCopies k) = 3 * k := by
  classical
  refine le_antisymm ?_ ?_
  · -- three vertices per copy dominate
    have hdom : IsDominatingSet (wagnerCopies k)
        ((Finset.univ : Finset (Fin k)) ×ˢ ({0, 1, 2} : Finset (Fin 8))) := by
      rintro ⟨i, a⟩
      rcases isDominatingSet_wagner_zero_one_two a with h | ⟨d, hd, hadj⟩
      · exact Or.inl (Finset.mem_product.mpr ⟨Finset.mem_univ i, h⟩)
      · exact Or.inr ⟨(i, d), Finset.mem_product.mpr ⟨Finset.mem_univ i, hd⟩, ⟨rfl, hadj⟩⟩
    have hcard : ((Finset.univ : Finset (Fin k)) ×ˢ ({0, 1, 2} : Finset (Fin 8))).card = 3 * k := by
      rw [Finset.card_product]
      simp [Nat.mul_comm]
    exact le_trans (Nat.sInf_le ⟨_, hdom, rfl⟩) hcard.le
  · refine le_dominationNumber_of_forall ?_
    intro D hD
    have hfib : D.card = ∑ i : Fin k, (D.filter (fun x => x.1 = i)).card :=
      Finset.card_eq_sum_card_fiberwise (fun x _ => Finset.mem_univ x.1)
    have hge : ∀ i : Fin k, 3 ≤ (D.filter (fun x => x.1 = i)).card := by
      intro i
      have hdomi : IsDominatingSet wagner ((D.filter (fun x => x.1 = i)).image Prod.snd) := by
        intro a
        rcases hD (i, a) with h | ⟨d, hd, hadj⟩
        · exact Or.inl (Finset.mem_image.mpr ⟨(i, a), Finset.mem_filter.mpr ⟨h, rfl⟩, rfl⟩)
        · exact Or.inr ⟨d.2, Finset.mem_image.mpr
            ⟨d, Finset.mem_filter.mpr ⟨hd, hadj.1⟩, rfl⟩, hadj.2⟩
      exact le_trans (three_le_card_of_dominating_wagner _ hdomi) Finset.card_image_le
    calc 3 * k = ∑ _i : Fin k, 3 := by simp [Nat.mul_comm]
      _ ≤ ∑ i : Fin k, (D.filter (fun x => x.1 = i)).card :=
          Finset.sum_le_sum (fun i _ => hge i)
      _ = D.card := hfib.symm

/-- **The extremal ratio `3` persists for arbitrarily large packing numbers.**  For every `k`,
the disjoint union of `k` Wagner graphs has `ρ = k` and `γ = 3k`. -/
theorem wagnerCopies_ratio (k : ℕ) :
    packingNumber (wagnerCopies k) = k ∧
      dominationNumber (wagnerCopies k) = 3 * packingNumber (wagnerCopies k) := by
  refine ⟨wagnerCopies_packingNumber k, ?_⟩
  rw [wagnerCopies_dominationNumber, wagnerCopies_packingNumber]

/-- No Erdős–Pósa bound of the form `γ ≤ c·ρ + b` can hold for general graphs with `c < 3`:
the family `wagnerCopies k` forces `3k ≤ c·k + b` for every `k`. -/
theorem no_bound_below_three (c b : ℕ) (h : ∀ (k : ℕ), dominationNumber (wagnerCopies k)
    ≤ c * packingNumber (wagnerCopies k) + b) : 3 ≤ c := by
  by_contra hc
  push_neg at hc
  have h1 := h (b + 1)
  rw [wagnerCopies_dominationNumber, wagnerCopies_packingNumber] at h1
  have h2 : c * (b + 1) ≤ 2 * (b + 1) := Nat.mul_le_mul_right _ (by omega)
  omega

end DominationPacking