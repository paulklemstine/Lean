/-! # CatalogBuild.Speculative.Other.DickianMath

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 11
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.Other.DickianMath
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 11] -/
theorem dickian_fixed_point_exists
    {L : Type*} [CompleteLattice L] (Φ : L →o L) :
    ∃ x : L, Φ x = x := by
  -- Apply the Knaster-Tarski theorem, which states that every monotone function on a complete lattice has a fixed point.
  apply Classical.byContradiction
  intro h_no_fixed_point;
  -- Consider the set S of elements in L that are less than or equal to their image under Φ.
  set S := {x : L | x ≤ Φ x} with hS_def;
  -- Since S is nonempty (it contains the bottom element of the lattice), it must have a supremum.
  obtain ⟨x, hx⟩ : ∃ x : L, x = sSup S ∧ x ∈ S := by
    simp [hS_def];
    exact fun x hx => le_trans hx ( Φ.monotone ( le_sSup hx ) );
  refine' h_no_fixed_point ⟨ x, le_antisymm _ _ ⟩ <;> simp_all +singlePass;
  · exact le_sSup ( by simpa [ ← hx.1 ] using Φ.monotone hx.2 );
  · exact fun y hy => le_trans hy ( Φ.monotone ( le_sSup hy ) )



theorem black_iron_prison_unique
    {L : Type*} [CompleteLattice L] (Φ : L →o L)
    (h_deflate : ∀ x : L, x ≠ ⊥ → Φ x < x) :
    ∀ x : L, Φ x = x → x = ⊥ := by
  exact fun x hx => Classical.not_not.1 fun hx' => ne_of_lt ( h_deflate x hx' ) hx



theorem ubik_collapse_time_formula :
    (1 : ℝ) ^ ((1 : ℝ) - 2) / (1 * (2 - 1)) = 1 := by
  norm_num +zetaDelta at *



theorem ubik_stabilizer_formula (a C_target b : ℝ) (ha : 0 < a) (hC : 0 < C_target)
    (hb : 1 < b) :
    -a * C_target ^ b + (a * C_target ^ b) = 0 := by
  ring



theorem connected_image_connected
    {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]
    [ConnectedSpace X] (f : X → Y) (hf : Continuous f) (hfs : Function.Surjective f) :
    ConnectedSpace Y := by
  grind +suggestions



theorem no_retraction_to_disconnected
    {X : Type*} [TopologicalSpace X] [ConnectedSpace X]
    {A B : Set X} (hA : IsOpen A) (hB : IsOpen B)
    (hAB : A ∪ B = univ) (hAne : A.Nonempty) (hBne : B.Nonempty) (hAB_disj : A ∩ B = ∅)
    (r : X → X) (hr : Continuous r) (hr_range : ∀ x, r x ∈ A ∨ r x ∈ B)
    (hr_retract_A : ∀ x ∈ A, r x = x) (hr_retract_B : ∀ x ∈ B, r x = x) :
    False := by
  simp_all +decide [ Set.ext_iff ];
  have h_connected : IsConnected (Set.range r) := by
    exact isConnected_range hr;
  obtain ⟨ x, hx ⟩ := hAne; obtain ⟨ y, hy ⟩ := hBne; have := h_connected.isPreconnected; simp_all +decide [ IsPreconnected ] ;
  specialize this A B hA hB ( by rintro _ ⟨ z, rfl ⟩ ; cases hAB ( r z ) <;> aesop ) ⟨ _, Set.mem_range_self x, by aesop ⟩ ⟨ _, Set.mem_range_self y, by aesop ⟩ ; simp_all +decide [ Set.Nonempty ] ;
  grind +qlia



theorem perfect_precog_no_free_will
    {X Y : Type*} (act predict : X → Y)
    (h_perfect : ∀ x, predict x = act x) :
    ∀ x, act x = predict x := by
  exact fun x => h_perfect x ▸ rfl



theorem minority_report_paradox
    {X : Type*} (predict : X → Bool) (intervene : X → Bool)
    (h_prevent : ∀ x, predict x = true → intervene x = false)
    (h_accurate : ∀ x, predict x = intervene x) :
    ∀ x, predict x = false := by
  grind +ring



theorem mercerism_instability_condition
    (decay spec_rad coupling : ℝ) (hd : 0 < decay) (hs : 0 < spec_rad)
    (hw : decay / spec_rad < coupling) :
    0 < coupling * spec_rad - decay := by
  nlinarith [ div_mul_cancel₀ decay hs.ne' ]



theorem below_critical_stable
    (decay spec_rad coupling : ℝ) (hd : 0 < decay) (hs : 0 < spec_rad)
    (hw : coupling < decay / spec_rad) (hw0 : 0 < coupling) :
    coupling * spec_rad - decay < 0 := by
  nlinarith [ mul_div_cancel₀ decay hs.ne' ]



theorem self_reference_bound
    {α : Type*} [Fintype α] [DecidableEq α] (f : α → α)
    (h_not_id : f ≠ id) :
    (Finset.univ.filter (fun x => f x = x)).card < Fintype.card α := by
  exact Finset.card_lt_card ( Finset.ssubset_iff_subset_ne.mpr ⟨ Finset.filter_subset _ _, by intro h; exact h_not_id ( funext fun x => by simpa using Finset.ext_iff.mp h x ) ⟩ )


