/-! # CatalogBuild.Computation.Oracles.OracleInformation

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 14
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Computation.Oracles.OracleInformation
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 14] -/
theorem oracle_range_card_le (n : ℕ) (O : Fin n → Fin n) :
    Finset.card (Finset.image O Finset.univ) ≤ n := by
      exact le_trans ( Finset.card_image_le ) ( by simpa )



theorem non_injective_smaller_range {n : ℕ} (O : Fin n → Fin n) (hni : ¬Injective O) :
    Finset.card (Finset.image O Finset.univ) < n := by
      refine' lt_of_le_of_ne ( Finset.card_image_le.trans ( by simpa ) ) fun con => hni _;
      exact ( Fintype.bijective_iff_injective_and_card O ).mpr ⟨ fun a b h => by have := Finset.card_image_iff.mp ( by aesop : Finset.card ( Finset.image O Finset.univ ) = Finset.card Finset.univ ) ; aesop, by aesop ⟩ |>.1



theorem nontrivial_oracle_compresses {n : ℕ} (O : Fin (n + 2) → Fin (n + 2))
    (hO : ∀ x, O (O x) = O x) (hne : O ≠ id) :
    Finset.card (Finset.image O Finset.univ) < n + 2 := by
      convert non_injective_smaller_range O _ using 1;
      exact fun h => hne <| funext fun x => by have := @h ( O x ) x; aesop;



theorem fixedPoint_mem_range {X : Type*} (O : X → X) (x : X) (hx : O x = x) :
    x ∈ range O := by
      use x



theorem range_mem_fixedPoint {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (y : X) (hy : y ∈ range O) : O y = y := by
      cases hy ; aesop



theorem fixedPoint_card_eq_range {n : ℕ} (O : Fin n → Fin n) (hO : ∀ x, O (O x) = O x) :
    Finset.card (Finset.filter (fun x => O x = x) Finset.univ) =
    Finset.card (Finset.image O Finset.univ) := by
      refine' congr_arg Finset.card ( Finset.ext fun x => _ );
      aesop



/-- The "information destroyed" by the oracle is the number of non-fixed points -/
def infoLoss {n : ℕ} (O : Fin n → Fin n) : ℕ :=
  n - Finset.card (Finset.filter (fun x => O x = x) Finset.univ)



theorem oracle_accounting {n : ℕ} (O : Fin n → Fin n) :
    Finset.card (Finset.filter (fun x => O x = x) Finset.univ) + infoLoss O = n := by
      exact Nat.add_sub_of_le ( by exact le_trans ( Finset.card_filter_le _ _ ) ( by simpa ) )



theorem id_zero_loss (n : ℕ) : infoLoss (id : Fin n → Fin n) = 0 := by
  unfold infoLoss; aesop;



theorem oracle_image_nonempty {n : ℕ} (hn : 0 < n) (O : Fin n → Fin n) :
    (Finset.image O Finset.univ).Nonempty := by
      exact ⟨ O ⟨ 0, hn ⟩, Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ⟩



theorem constant_oracle_range {n : ℕ} (c : Fin (n + 1)) :
    Finset.card (Finset.image (fun _ : Fin (n + 1) => c) Finset.univ) = 1 := by
      simp +decide [ Finset.image_const ]



theorem semantic_compression_bound {n k : ℕ} (hk : k ≤ n) :
    k ≤ n := by
      assumption



theorem log_compression {k n : ℕ} (hk : 0 < k) (hn : k ≤ n) :
    Nat.log 2 k ≤ Nat.log 2 n := by
      exact Nat.log_mono_right hn



theorem compression_ratio_le_one (n : ℕ) (hn : 0 < n) (O : Fin n → Fin n) :
    Finset.card (Finset.image O Finset.univ) ≤ n := by
      exact Finset.card_image_le.trans_eq ( Finset.card_fin _ )



end
