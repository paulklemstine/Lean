/-! # CatalogBuild.Pythagorean.Core.DescentTheory

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 16
-/

import Mathlib

noncomputable section

/-- A descent datum consists of a pair of ordered types with monotone maps between them
satisfying the descent condition (Galois connection). -/
structure DescentDatum (α β : Type*) [Preorder α] [Preorder β] where
  descend : α →o β
  ascend : β →o α
  galois : ∀ a b, descend a ≤ b ↔ a ≤ ascend b

namespace DescentDatum

variable {α β : Type*} [PartialOrder α] [PartialOrder β]




/-- The descent-ascent composition is inflationary. -/
theorem ascend_descend_le (D : DescentDatum α β) (a : α) : a ≤ D.ascend (D.descend a) :=
  (D.galois _ _).1 le_rfl




/-- The ascent-descent composition is deflationary. -/
theorem descend_ascend_ge (D : DescentDatum α β) (b : β) : D.descend (D.ascend b) ≤ b :=
  (D.galois _ _).2 le_rfl




/-- Descent followed by ascent followed by descent equals descent (idempotency). -/
theorem descent_idempotent (D : DescentDatum α β) (a : α) :
    D.descend (D.ascend (D.descend a)) = D.descend a := by
  apply le_antisymm
  · exact D.descend_ascend_ge (D.descend a)
  · exact D.descend.monotone (D.ascend_descend_le a)




/-- Ascent followed by descent followed by ascent equals ascent (idempotency). -/
theorem ascent_idempotent (D : DescentDatum α β) (b : β) :
    D.ascend (D.descend (D.ascend b)) = D.ascend b := by
  apply le_antisymm
  · exact D.ascend.monotone (D.descend_ascend_ge b)
  · exact D.ascend_descend_le (D.ascend b)




/-- The rank of a matrix, defined as the rank of its column space.
This abstracts the key invariant preserved by crystallizer descent. -/
noncomputable def matrixRank (R : Type*) [CommRing R] [IsDomain R]
    (m n : ℕ) (M : Matrix (Fin m) (Fin n) R) : ℕ :=
  Module.finrank R (Submodule.span R (Set.range M.transpose))




/-- A descent chain is a sequence of descent data composable end-to-end. -/
structure DescentChain (n : ℕ) where
  level : Fin (n + 1) → Type*
  order : ∀ i, Preorder (level i)
  step : ∀ i : Fin n, @DescentDatum (level i.castSucc) (level i.succ) (order i.castSucc) (order i.succ)




/-- A quantum dimension type tracking the local Hilbert space dimension. -/
structure QDim where
  dim : ℕ
  dim_pos : 0 < dim




/-- The set of "crystalline dimensions" where the crystallizer lattice
has exceptional symmetry. -/
def isCrystalline (d : ℕ) : Prop :=
  d ∈ ({2, 3, 4, 6, 8, 12, 24} : Finset ℕ)




/-- 2 is a crystalline dimension. -/
theorem two_crystalline : isCrystalline 2 := by
  unfold isCrystalline; norm_num




/-- 24 is a crystalline dimension. -/
theorem twentyfour_crystalline : isCrystalline 24 := by
  unfold isCrystalline; norm_num




/-- 5 is not a crystalline dimension. -/
theorem five_not_crystalline : ¬ isCrystalline 5 := by
  simp +decide [isCrystalline]




/-- [Section: # CatalogBuild.Pythagorean.Core.DescentTheory
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 16] -/
theorem crystalline_sparse (n : ℕ) (hn : 24 < n) :
    (Finset.filter (fun d => d ∈ ({2, 3, 4, 6, 8, 12, 24} : Finset ℕ))
      (Finset.range (n + 1))).card = 7 := by
  rcases n with ( _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | n ) <;> simp_all +arith +decide;
  simp +arith +decide [ Finset.filter_eq', Finset.filter_or ]




/-- [Section: # CatalogBuild.Pythagorean.Core.DescentTheory
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 16] -/
theorem descent_rank_bound {α β : Type*} [Fintype α] [Fintype β]
    [Preorder α] [Preorder β] (D : DescentDatum α β)
    (hα : Fintype.card α > 0) :
    Fintype.card β > 0 := by
  by_contra h_contra;
  simp_all +decide [ Fintype.card_eq_zero_iff ];
  obtain ⟨a, ha⟩ : ∃ a : α, True := by
    exact ⟨ Classical.choose ( Finset.card_pos.mp hα ), trivial ⟩;
  exact h_contra.elim ( D.descend a )




theorem quantum_descent_pow_dvd (d₁ d₂ : ℕ) (hdvd : d₁ ∣ d₂) (n : ℕ) :
    d₁^n ∣ d₂^n := by
  exact pow_dvd_pow_of_dvd hdvd _




theorem descent_dim_dvd (d k n : ℕ) (hd : 0 < d) :
    d^n ∣ (d * k)^n := by
  exact pow_dvd_pow_of_dvd ( dvd_mul_right _ _ ) _



end
