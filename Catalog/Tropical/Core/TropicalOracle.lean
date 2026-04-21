/-! # CatalogBuild.Tropical.Core.TropicalOracle

Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 18
-/

import Mathlib

noncomputable section

/-- The truth set of an oracle is the set of its fixed points. -/
def truthSet {α : Type*} (O : α → α) : Set α :=
  {x | O x = x}




/-- [Section: # CatalogBuild.Tropical.Core.TropicalOracle
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 18] -/
theorem truthSet_eq_fixedPoints {α : Type*} (O : α → α) :
    truthSet O = fixedPoints O := by
      rfl




/-- [Section: # CatalogBuild.Tropical.Core.TropicalOracle
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 18] -/
theorem oracle_range_eq_truthSet {α : Type*} (O : α → α) (hO : IsOracle O) :
    range O = truthSet O := by
      ext x; aesop;




theorem oracle_on_truthSet {α : Type*} (O : α → α) (hO : IsOracle O)
    (x : α) (hx : x ∈ truthSet O) : O x = x := by
      exact hx




/-- The tropical gate: f(x) = -max(-x, 0) = min(x, 0).
This is the "soft min-plus" operation from tropical geometry. -/
noncomputable def tropicalGate (x : ℝ) : ℝ := min x 0




theorem tropicalGate_eq_neg_relu_neg (x : ℝ) :
    tropicalGate x = -(max (-x) 0) := by
      unfold tropicalGate; cases max_cases ( -x ) 0 <;> cases min_cases x 0 <;> linarith;




theorem tropicalGate_idempotent : IsOracle tropicalGate := by
  grind +locals




theorem tropicalGate_truthSet : truthSet tropicalGate = Set.Iic 0 := by
  -- By definition of $truthSet$, we have $truthSet tropicalGate = {x | tropicalGate x = x}$.
  ext x
  simp [truthSet, tropicalGate]




theorem tropicalGate_monotone : Monotone tropicalGate := by
  exact fun x y hxy => min_le_min hxy le_rfl;




theorem tropicalGate_le_zero (x : ℝ) : tropicalGate x ≤ 0 := by
  exact min_le_right _ _




theorem tropicalGate_le_self (x : ℝ) : tropicalGate x ≤ x := by
  exact min_le_left _ _




theorem oracle_compression {α : Type*} [Fintype α] [DecidableEq α]
    (O : α → α) (hO : IsOracle O) (hni : ¬Injective O) :
    (fixedPoints O).toFinset.card < Fintype.card α := by
      -- Since O is not injective, there exist $a \ne b$ such that $O(a) = O(b)$.
      obtain ⟨a, b, hab⟩ : ∃ a b : α, a ≠ b ∧ O a = O b := by
        simpa [ Function.Injective, and_comm ] using hni;
      refine' Finset.card_lt_card _;
      simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ];
      exact fun h => hab.1 ( by simpa [ h ] using hab.2 )

-- ============================================================================
-- SECTION 4: Geodesic Gradient Descent (Cycle 5)
-- ============================================================================




/-- The geodesic update rule: θ ← θ - η · (∇/√g).
This is equivalent to the RMSProp adaptive learning rate update. -/
noncomputable def geodesicStep (theta grad g eta epsilon : ℝ) : ℝ :=
  theta - eta * (grad / (Real.sqrt g + epsilon))




theorem geodesicStep_zero_grad (theta g eta epsilon : ℝ) :
    geodesicStep theta 0 g eta epsilon = theta := by
      unfold geodesicStep; ring;




theorem geodesicStep_descent (theta grad g eta epsilon : ℝ)
    (heta : 0 < eta) (hgrad : 0 < grad) (hg : 0 ≤ g) (heps : 0 < epsilon) :
    geodesicStep theta grad g eta epsilon < theta := by
      exact sub_lt_self _ ( mul_pos heta ( div_pos hgrad ( add_pos_of_nonneg_of_pos ( Real.sqrt_nonneg _ ) heps ) ) )




theorem strange_loop_convergence {α : Type*} (O : α → α) (hO : IsOracle O)
    (x : α) (n : ℕ) (hn : 0 < n) : O^[n] x = O x := by
      induction hn <;> simp +decide [ *, Function.iterate_succ_apply' ];
      exact hO x




theorem holographic_bottleneck_retraction {α : Type*}
    (D U : α → α) (h : IsOracle (D ∘ U)) :
    range (D ∘ U) = fixedPoints (D ∘ U) := by
      convert oracle_range_eq_truthSet ( D ∘ U ) h using 1




theorem oracle_range_subset_fixed {α : Type*} (O : α → α) (hO : IsOracle O) :
    ∀ y ∈ range O, O y = y := by
      aesop



end
