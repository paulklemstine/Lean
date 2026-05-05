--- a/Logic/Core.lean
+++ b/Logic/Core.lean
@@ -1,196 +1,218 @@
 import Mathlib
 
-/-! # Guarded Order-Theoretic Fixed-Point Theory
-
-This file develops the order-theoretic core for guarded fixed-point semantics.
-We define a `GuardedOrder` class capturing ω-chain complete partial orders with
-bottom, prove that monotone ω-continuous endomorphisms have least fixed points
-via Kleene iteration, and establish uniqueness of such fixed points.
-
-## Main definitions
-
-* `GuardedOrder` — an ω-chain complete partial order with bottom element and
-  explicit ω-supremum operation
-* `DelayOperator` — a monotone "delay" / "guard" endomorphism modeling the
-  productive guard in temporal feedback
-* `guardedIterate` — the Kleene iteration chain F^n(⊥)
-* `guardedLfp` — the least fixed point as the ω-supremum of the iteration chain
-* `OmegaContinuous` — ω-continuity of an endomorphism
-
-## Main results
-
-* `guardedIterate_mono` — the iteration chain is monotone
-* `guardedLfp_fixed` — the ω-sup is a fixed point under monotonicity + ω-continuity
-* `guardedLfp_least_fixed` — it is the least fixed point
-* `guarded_fixedpoint_unique` — uniqueness among least fixed points
-* `omegaSup_iterate_succ` — shifted-supremum invariance
+/-! # CatalogBuild.Logic.Core
+
+Auto-generated from theorem catalog database.
+Domain: Logic
+Declarations: 32
 -/
 
-universe u v
-
-/-! ## Guarded Order Structure -/
-
-/-- An ω-chain complete partial order with bottom and explicit ω-supremum.
-This provides the semantic domain for guarded fixed-point iteration. -/
-class GuardedOrder (α : Type u) extends PartialOrder α, OrderBot α where
-  /-- The supremum of an ω-chain (monotone sequence indexed by ℕ). -/
-  omegaSup : (ℕ → α) → α
-  /-- Every element of the chain is below the supremum. -/
-  le_omegaSup : ∀ (s : ℕ → α), ∀ n, s n ≤ omegaSup s
-  /-- The supremum is the least upper bound. -/
-  omegaSup_le : ∀ (s : ℕ → α) (a : α), (∀ n, s n ≤ a) → omegaSup s ≤ a
-
-/-- A delay (guard) operator modeling the productive delay in temporal feedback loops. -/
-class DelayOperator (α : Type u) [PartialOrder α] where
-  /-- The delay map. -/
-  delay : α → α
-  /-- Delay is monotone. -/
-  monotone_delay : Monotone delay
-
-/-! ## Guarded Iteration -/
-
-/-- The Kleene iteration chain: `guardedIterate F n = F^n(⊥)`. -/
-def guardedIterate {α : Type u} [PartialOrder α] [OrderBot α] (F : α → α) : ℕ → α
-  | 0 => ⊥
-  | n + 1 => F (guardedIterate F n)
-
-/-- The candidate least fixed point: the ω-supremum of the iteration chain. -/
-noncomputable def guardedLfp {α : Type u} [GuardedOrder α] (F : α → α) : α :=
-  GuardedOrder.omegaSup (guardedIterate F)
-
-/-! ## ω-Continuity -/
-
-/-- An endomorphism is ω-continuous if it preserves ω-suprema of monotone chains,
-in the sense that `F(sup s) ≤ sup (F ∘ s)`. Combined with monotonicity this
-gives equality. -/
-def OmegaContinuous {α : Type u} [GuardedOrder α] (F : α → α) : Prop :=
-  ∀ s : ℕ → α, Monotone s →
-    F (GuardedOrder.omegaSup s) ≤ GuardedOrder.omegaSup (fun n => F (s n))
-
-/-! ## Core Lemmas -/
-
-/-
-The iteration chain is monotone for monotone F.
--/
-theorem guardedIterate_mono
-    {α : Type u} [GuardedOrder α]
-    {F : α → α} (hF : Monotone F) :
-    Monotone (guardedIterate F) := by
-  apply_rules [ monotone_nat_of_le_succ ];
-  intro n;
-  induction' n with n ih;
-  · convert bot_le;
-  · exact hF ih
-
-/-- Each iterate is below the ω-supremum. -/
-theorem guardedIterate_le_omegaSup
-    {α : Type u} [GuardedOrder α]
-    {F : α → α} (n : ℕ) :
-    guardedIterate F n ≤ guardedLfp F :=
-  GuardedOrder.le_omegaSup _ n
-
-/-
-Shifted-supremum invariance: `sup_{n} F^{n+1}(⊥) = sup_{n} F^n(⊥)`.
--/
-theorem omegaSup_iterate_succ
-    {α : Type u} [GuardedOrder α]
-    {F : α → α} (hmono : Monotone F) :
-    GuardedOrder.omegaSup (fun n => guardedIterate F (n + 1)) =
-    GuardedOrder.omegaSup (guardedIterate F) := by
-  cases' ‹GuardedOrder α› with _ _ omegaSup le_omegaSup omegaSup_le;
-  refine' le_antisymm ( omegaSup_le _ _ fun n => _ ) ( omegaSup_le _ _ fun n => _ );
-  · exact le_omegaSup _ _;
-  · induction' n with n ih;
-    · exact bot_le;
-    · exact le_of_le_of_eq'' (le_omegaSup (fun n => guardedIterate F (n + 1)) n) rfl
-
-/-
-Every approximant is below any fixed point.
--/
-theorem guardedIterate_le_fixed
-    {α : Type u} [GuardedOrder α]
-    {F : α → α} (hmono : Monotone F)
-    {x : α} (hx : F x = x) :
-    ∀ n, guardedIterate F n ≤ x := by
-  -- By induction on n, we can show that guardedIterate F n ≤ x for all n.
-  intro n
-  induction' n with n ih;
-  · exact ( ‹GuardedOrder α› ).bot_le x;
-  · exact hx ▸ hmono ih
-
-/-! ## Main Fixed-Point Theorems -/
-
-/-
-**Kleene Fixed-Point Theorem (Guarded).** Under monotonicity and ω-continuity,
-the ω-supremum of the iteration chain is a fixed point of F.
--/
-theorem guardedLfp_fixed
-    {α : Type u} [GuardedOrder α]
-    {F : α → α}
-    (hmono : Monotone F)
-    (hω : OmegaContinuous F) :
-    F (guardedLfp F) = guardedLfp F := by
-  rename_i h;
-  obtain ⟨ _, _, _ ⟩ := h;
-  rename_i h₁ h₂ h₃;
-  refine' le_antisymm _ _;
-  · refine' le_trans ( hω _ _ ) _;
-    · intro m n hmn;
-      induction hmn <;> simp_all +decide [ guardedIterate ];
-      refine' le_trans ‹_› _;
-      rename_i k hk ih;
-      exact Nat.recOn k ( by exact bot_le ) fun n ihn => by exact hmono ihn;
-    · convert h₃ _ _ _;
-      intro n;
-      refine' le_trans _ ( h₂ _ _ );
-      swap;
-      exacts [ n + 1, rfl.le ];
-  · refine' h₃ _ _ _;
-    intro n;
-    induction' n with n ih;
-    · exact bot_le;
-    · exact le_of_eq_of_le rfl (hmono (h₂ (guardedIterate F) n))
-
-/-
-The guarded least fixed point is below every fixed point.
--/
-theorem guardedLfp_least_fixed
-    {α : Type u} [GuardedOrder α]
-    {F : α → α}
-    (hmono : Monotone F)
-    {x : α} (hx : F x = x) :
-    guardedLfp F ≤ x := by
-  rename_i h;
-  cases h;
-  rename_i h₁ h₂ h₃ h₄;
-  have h_le : ∀ n, guardedIterate F n ≤ x := by
-    intro n
-    induction' n with n ih;
-    · exact bot_le;
-    · exact hx ▸ hmono ih;
-  exact h₄ _ _ h_le
-
-/-
-Uniqueness of least fixed points: any two fixed points that are each
-least among all fixed points must be equal.
--/
-theorem guarded_fixedpoint_unique
-    {α : Type u} [GuardedOrder α]
-    {F : α → α}
-    {x y : α}
-    (hx : F x = x) (hy : F y = y)
-    (hleastx : ∀ z, F z = z → x ≤ z)
-    (hleasty : ∀ z, F z = z → y ≤ z) :
-    x = y := by
-  -- Since x ≤ y and y ≤ x, we have x = y by the antisymmetry of the partial order.
-  apply (‹GuardedOrder α›.le_antisymm x y (hleastx y hy) (hleasty x hx))
-
-/-! ## Instances for Function Spaces -/
-
-/-- Pointwise `GuardedOrder` instance for function spaces `ι → β`.
-When `β` has a `GuardedOrder`, functions into `β` inherit it pointwise. -/
-noncomputable instance GuardedOrder.pi {ι : Type u} {β : Type v} [GuardedOrder β] :
-    GuardedOrder (ι → β) where
-  omegaSup s := fun i => GuardedOrder.omegaSup (fun n => s n i)
-  le_omegaSup s n := fun i => GuardedOrder.le_omegaSup (fun n => s n i) n
-  omegaSup_le _s _a h := fun i => GuardedOrder.omegaSup_le _ _ (fun n => h n i)+noncomputable section
+
+/-- A collection of fundamental physical constants. -/
+structure PhysicalConstants where
+  c : ℝ       -- speed of light
+  G : ℝ       -- gravitational constant
+  hbar : ℝ    -- reduced Planck constant
+  kB : ℝ      -- Boltzmann constant
+  hc_pos : 0 < c
+  hG_pos : 0 < G
+  hbar_pos : 0 < hbar
+  kB_pos : 0 < kB
+
+variable (κ : PhysicalConstants)
+
+/-- Planck length: ℓ_P = √(ħG/c³) -/
+def planckLength : ℝ := Real.sqrt (κ.hbar * κ.G / κ.c ^ 3)
+
+/-- Planck mass: m_P = √(ħc/G) -/
+def planckMass : ℝ := Real.sqrt (κ.hbar * κ.c / κ.G)
+
+/-- Planck energy: E_P = √(ħc⁵/G) -/
+def planckEnergy : ℝ := Real.sqrt (κ.hbar * κ.c ^ 5 / κ.G)
+
+/-- Schwarzschild radius as a function of energy: r_s = 2GE/c⁴ -/
+def schwarzschildRadiusEnergy (E : ℝ) : ℝ := 2 * κ.G * E / κ.c ^ 4
+
+/-- Schwarzschild radius as a function of mass: r_s = 2GM/c² -/
+def schwarzschildRadius (M : ℝ) : ℝ := 2 * κ.G * M / κ.c ^ 2
+
+/-- Event horizon area: A = 4π r_s² -/
+def horizonArea (M : ℝ) : ℝ := 4 * π * (schwarzschildRadius κ M) ^ 2
+
+/-- Bekenstein-Hawking entropy: S_BH = kc³A/(4Għ) -/
+def bekensteinHawkingEntropy (M : ℝ) : ℝ :=
+  κ.kB * κ.c ^ 3 * horizonArea κ M / (4 * κ.G * κ.hbar)
+
+/-- Information content in bits: I = S/(kB · ln 2) -/
+def blackHoleInformation (M : ℝ) : ℝ :=
+  bekensteinHawkingEntropy κ M / (κ.kB * Real.log 2)
+
+/-- Photon wavelength from energy: λ = 2πħc/E -/
+def photonWavelength (E : ℝ) : ℝ := 2 * π * κ.hbar * κ.c / E
+
+/-- Reduced Compton wavelength: λ̄ = ħc/E -/
+def comptonWavelength (E : ℝ) : ℝ := κ.hbar * κ.c / E
+
+/-- The Schwarzschild radius is proportional to energy. -/
+theorem schwarzschild_linear (E : ℝ) :
+    schwarzschildRadiusEnergy κ E = (2 * κ.G / κ.c ^ 4) * E := by
+  unfold schwarzschildRadiusEnergy; ring
+
+/-- The Schwarzschild radius grows with energy. -/
+theorem schwarzschild_monotone :
+    Monotone (schwarzschildRadiusEnergy κ) := by
+  exact fun x y hxy => div_le_div_of_nonneg_right
+    (mul_le_mul_of_nonneg_left hxy <| mul_nonneg zero_le_two <| le_of_lt κ.hG_pos)
+    (pow_nonneg (le_of_lt κ.hc_pos) 4)
+
+/-- **KEY THEOREM**: At the crossing energy E² = ħc⁵/(2G), the Schwarzschild
+radius equals the reduced Compton wavelength. -/
+theorem planck_crossing (E : ℝ) (hE : 0 < E)
+    (hcross : E ^ 2 = κ.hbar * κ.c ^ 5 / (2 * κ.G)) :
+    schwarzschildRadiusEnergy κ E = comptonWavelength κ E := by
+  unfold schwarzschildRadiusEnergy comptonWavelength
+  rw [div_eq_div_iff] <;>
+    try nlinarith [κ.hc_pos, κ.hG_pos, κ.hbar_pos, pow_pos κ.hc_pos 4]
+  rw [eq_div_iff] at hcross <;> nlinarith [κ.hG_pos]
+
+/-- The Bekenstein-Hawking entropy simplifies to S = 4πk_B GM²/(ħc).
+This is the standard physics formula. -/
+theorem bekenstein_hawking_simplified (M : ℝ) :
+    bekensteinHawkingEntropy κ M =
+    4 * π * κ.kB * κ.G * M ^ 2 / (κ.hbar * κ.c) := by
+  unfold bekensteinHawkingEntropy horizonArea schwarzschildRadius
+  have hG := κ.hG_pos
+  have hc := κ.hc_pos
+  have hbar := κ.hbar_pos
+  have hkB := κ.kB_pos
+  field_simp
+  ring
+
+/-- [Section: # CatalogBuild.Logic.Core
+Auto-generated from theorem catalog database.
+Domain: Logic
+Declarations: 32] -/
+theorem entropy_quadratic (M₁ M₂ : ℝ) (hM : 0 ≤ M₁) (hM2 : M₁ ≤ M₂) :
+    bekensteinHawkingEntropy κ M₁ ≤ bekensteinHawkingEntropy κ M₂ := by
+  rw [ bekenstein_hawking_simplified, bekenstein_hawking_simplified ];
+  gcongr;
+  · exact mul_nonneg κ.hbar_pos.le κ.hc_pos.le;
+  · exact mul_nonneg ( mul_nonneg ( mul_nonneg zero_le_four Real.pi_pos.le ) κ.kB_pos.le ) κ.hG_pos.le
+
+/-- [Section: # CatalogBuild.Logic.Core
+Auto-generated from theorem catalog database.
+Domain: Logic
+Declarations: 32] -/
+theorem information_content_formula (M : ℝ) :
+    blackHoleInformation κ M =
+    4 * π * κ.G * M ^ 2 / (κ.hbar * κ.c * Real.log 2) := by
+  convert congr_arg ( fun x : ℝ => x / ( κ.kB * Real.log 2 ) ) ( bekenstein_hawking_simplified κ M ) using 1 ; ring;
+  norm_num [ κ.kB_pos.ne' ]
+
+theorem entropy_area_planck (M : ℝ) :
+    bekensteinHawkingEntropy κ M =
+    κ.kB * horizonArea κ M / (4 * (planckLength κ) ^ 2) := by
+  unfold bekensteinHawkingEntropy planckLength horizonArea; ring;
+  field_simp;
+  rw [ Real.sq_sqrt ( by exact div_nonneg ( mul_nonneg κ.hG_pos.le κ.hbar_pos.le ) ( pow_nonneg κ.hc_pos.le _ ) ), div_div_eq_mul_div ] ; ring
+
+/-- Each Planck area contributes one nat of entropy. -/
+def planckAreasOnHorizon (M : ℝ) : ℝ :=
+  horizonArea κ M / (4 * (planckLength κ) ^ 2)
+
+theorem holographic_principle (M : ℝ) :
+    bekensteinHawkingEntropy κ M = κ.kB * planckAreasOnHorizon κ M := by
+  unfold planckAreasOnHorizon
+  rw [entropy_area_planck, mul_div_assoc]
+
+/-- Ratio of Schwarzschild radius to Compton wavelength. -/
+def isomorphismParameter (E : ℝ) : ℝ :=
+  schwarzschildRadiusEnergy κ E / comptonWavelength κ E
+
+/-- The isomorphism parameter = 2GE²/(ħc⁵). -/
+theorem isomorphism_parameter_formula (E : ℝ) (hE : 0 < E) :
+    isomorphismParameter κ E = 2 * κ.G * E ^ 2 / (κ.hbar * κ.c ^ 5) := by
+  unfold isomorphismParameter schwarzschildRadiusEnergy comptonWavelength
+  field_simp
+
+theorem isomorphism_at_crossing (E : ℝ) (hE : 0 < E)
+    (hcross : E ^ 2 = κ.hbar * κ.c ^ 5 / (2 * κ.G)) :
+    isomorphismParameter κ E = 1 := by
+  rw [isomorphismParameter]
+  unfold schwarzschildRadiusEnergy comptonWavelength
+  grind +revert
+
+theorem subplanckian_photon_dominates (E : ℝ) (hE : 0 < E)
+    (hsub : E ^ 2 < κ.hbar * κ.c ^ 5 / (2 * κ.G)) :
+    isomorphismParameter κ E < 1 := by
+  rw [ lt_div_iff₀ ( mul_pos two_pos ( by linarith [ κ.hG_pos ] ) ) ] at hsub;
+  convert div_lt_one ?_ |>.2 hsub using 1;
+  · convert isomorphism_parameter_formula κ E hE using 1 ; ring;
+  · exact mul_pos κ.hbar_pos ( pow_pos κ.hc_pos _ )
+
+theorem superplanckian_bh_dominates (E : ℝ) (hE : 0 < E)
+    (hsup : κ.hbar * κ.c ^ 5 / (2 * κ.G) < E ^ 2) :
+    1 < isomorphismParameter κ E := by
+  rw [ isomorphismParameter, lt_div_iff₀ ];
+  · rw [ div_lt_iff₀ ( by linarith [ κ.hG_pos ] ) ] at hsup;
+    rw [ one_mul, schwarzschildRadiusEnergy, comptonWavelength ];
+    rw [ div_lt_div_iff₀ ] <;> nlinarith [ pow_pos κ.hc_pos 4 ];
+  · exact div_pos ( mul_pos ( κ.hbar_pos ) ( κ.hc_pos ) ) hE
+
+theorem planck_bh_entropy_simplified
+    (h : 0 < κ.hbar * κ.c / κ.G) :
+    bekensteinHawkingEntropy κ (planckMass κ) = 4 * π * κ.kB := by
+  rw [ @bekenstein_hawking_simplified ];
+  unfold planckMass;
+  grind
+
+/-- Black hole entropy is positive for positive mass. -/
+theorem bh_entropy_pos (M : ℝ) (hM : 0 < M) :
+    0 < bekensteinHawkingEntropy κ M := by
+  rw [bekenstein_hawking_simplified]
+  exact div_pos
+    (by have := κ.hG_pos; have := κ.kB_pos; have := κ.hc_pos; have := κ.hbar_pos; positivity)
+    (by have := κ.hc_pos; have := κ.hbar_pos; positivity)
+
+/-- Schwarzschild radius is positive for positive mass. -/
+theorem schwarzschild_pos (M : ℝ) (hM : 0 < M) :
+    0 < schwarzschildRadius κ M := by
+  exact div_pos (mul_pos (mul_pos two_pos κ.hG_pos) hM) (sq_pos_of_pos κ.hc_pos)
+
+/-- Photon energy → BH mass with matching wavelength/radius: M = ħc³/(4πGE) -/
+def photonToBHMass (E : ℝ) : ℝ :=
+  κ.hbar * κ.c ^ 3 / (4 * π * κ.G * E)
+
+/-- BH mass → photon energy with matching radius/wavelength: E = πħc³/(GM) -/
+def bhToPhotonEnergy (M : ℝ) : ℝ :=
+  π * κ.hbar * κ.c ^ 3 / (κ.G * M)
+
+/-- The round trip photon→BH→photon scales energy by 4π². NOT an isomorphism! -/
+theorem round_trip_scaling (E : ℝ) (hE : 0 < E) :
+    bhToPhotonEnergy κ (photonToBHMass κ E) = 4 * π ^ 2 * E := by
+  unfold photonToBHMass bhToPhotonEnergy
+  field_simp
+  exact div_self <| mul_ne_zero
+    (mul_ne_zero (ne_of_gt κ.hbar_pos) (ne_of_gt κ.hc_pos))
+    (ne_of_gt κ.hG_pos)
+
+/-- **MAIN THEOREM**: At the Planck crossing energy:
+1. Geometric convergence (r_s = λ_compton)
+2. Isomorphism parameter = 1
+3. Planck-mass BH still has 4π·kB entropy (not zero like a photon)
+Conclusion: Black holes and photons are geometrically isomorphic at the
+Planck scale but thermodynamically distinct. The "isomorphism" is a
+quasi-isomorphism — exact in geometry, broken by entropy. -/
+theorem black_hole_photon_quasi_isomorphism
+    (E : ℝ) (hE : 0 < E)
+    (hcross : E ^ 2 = κ.hbar * κ.c ^ 5 / (2 * κ.G))
+    (hconst : 0 < κ.hbar * κ.c / κ.G) :
+    schwarzschildRadiusEnergy κ E = comptonWavelength κ E ∧
+    isomorphismParameter κ E = 1 ∧
+    bekensteinHawkingEntropy κ (planckMass κ) = 4 * π * κ.kB := by
+  exact ⟨planck_crossing κ E hE hcross,
+         isomorphism_at_crossing κ E hE hcross,
+         planck_bh_entropy_simplified κ hconst⟩
+
+end