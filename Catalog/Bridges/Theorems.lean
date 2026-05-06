--- a/Bridges/Theorems.lean
+++ b/Bridges/Theorems.lean
@@ -1,1281 +1,307 @@
---- a/Bridges/Theorems.lean
-+++ b/Bridges/Theorems.lean
-@@ -1,972 +1,307 @@
----- a/Bridges/Theorems.lean
--+++ b/Bridges/Theorems.lean
--@@ -1,663 +1,307 @@
------ a/Bridges/Theorems.lean
---+++ b/Bridges/Theorems.lean
---@@ -1,487 +1,178 @@
--- --- a/Bridges/Theorems.lean
--- +++ b/Bridges/Theorems.lean
----@@ -1,478 +1,307 @@
-------- a/Bridges/Theorems.lean
-----+++ b/Bridges/Theorems.lean
-----@@ -1,172 +1,307 @@
----- /-
----- Copyright (c) 2025. All rights reserved.
----- Released under Apache 2.0 license as described in the file LICENSE.
------
------# Semantic Adequacy Theorems
------
------This file proves the main semantic adequacy theorem for coherent closure proof semirings:
------
------> **Theorem** (Jacobson Adequacy). For elements `x, y` of a coherent closure proof semiring,
------> `derivable x y` if and only if every admissible evaluation validates `e x → e y`.
------
------The proof has two parts:
------1. **Soundness** (`derivable_sound_for_admissible_evaluations`): monotonicity and
------   closure compatibility of admissible evaluations imply they validate all derivable pairs.
------2. **Completeness** (`derivable_of_valid_in_all_admissible_evaluations`): if every
------   admissible evaluation validates `e x → e y`, then `derivable x y`. The contrapositive
------   uses the prime ideal theorem for bounded distributive lattices to extract a
------   Jacobson prime witness, which yields an admissible counterevaluation.
------
------## Key Intermediate Results
------
------* `not_derivable_exists_prime_separation` — non-derivability implies existence of a
------  separating prime ideal (via the prime ideal theorem for distributive lattices)
------* `prime_separation_yields_admissible_evaluation` — a separating prime ideal yields
------  an admissible evaluation witnessing the failure
------* `not_derivable_exists_jacobson_counterevaluation` — the combined countermodel theorem
------* `derivable_iff_all_jacobson_evaluations_validate` — the main biconditional
------* `jacobson_proof_congruence_eq_semantic` — the proof congruence equals the
------  semantic preorder (intersection of all evaluation kernels)
-------/
------
------import Bridges.JacobsonAdequacy.Defs
------
------open Order Set CoherentClosureProofSemiring
------
------namespace CoherentClosureProofSemiring
------
------variable {S : Type*} [CoherentClosureProofSemiring S]
------
------/-! ## Soundness -/
------
------/-- **Soundness**: every derivable pair is validated by every admissible evaluation.
------
------If `derivable x y` (i.e., `cl x ≤ cl y`) and `e` is an admissible evaluation
------(monotone and closure-compatible), then `e x → e y`.
------
------*Proof.* From `e x`, closure compatibility gives `e (cl x)`. Monotonicity with
------`cl x ≤ cl y` gives `e (cl y)`. Closure compatibility again gives `e y`. -/
------theorem derivable_sound_for_admissible_evaluations {x y : S}
------    (hxy : derivable x y)
------    (e : S → Prop) (he : AdmissibleEvaluation (S := S) e) :
------    e x → e y := by
------  intro hex
------  exact (he.cl_compat y).mp (he.monotone _ _ hxy ((he.cl_compat x).mpr hex))
------
------/-! ## Prime Separation -/
------
------/-
------If `¬ derivable x y`, then there exists a prime ideal `J` of the distributive
------lattice separating `cl x` from `cl y`: specifically `cl y ∈ J` and `cl x ∉ J`.
------
------This is the core application of the **prime ideal theorem for bounded distributive
------lattices** (`DistribLattice.prime_ideal_of_disjoint_filter_ideal`). The principal
------filter of `cl x` and the principal ideal of `cl y` are disjoint precisely when
------`cl x ≰ cl y`, and the theorem upgrades this to a prime ideal.
-------/
------theorem not_derivable_exists_prime_separation {x y : S}
------    (hnd : ¬ derivable x y) :
------    ∃ J : Ideal S, J.IsPrime ∧ separates J x y := by
------  have h_disjoint : Disjoint (Order.PFilter.principal (cl' x) : Set S) (Order.Ideal.principal (cl' y) : Set S) := by
------    exact Set.disjoint_left.mpr fun z hz₁ hz₂ => hnd <| by exact le_trans hz₁ hz₂;
------  obtain ⟨ J, hJ₁, hJ₂ ⟩ := DistribLattice.prime_ideal_of_disjoint_filter_ideal h_disjoint;
------  refine' ⟨ J, hJ₁, _, _ ⟩ <;> simp_all +decide [ Set.disjoint_left ]
------
------/-
------Any prime ideal in a bounded distributive lattice naturally gives rise to a
------Jacobson prime point: since the lattice order ideal is downward-closed, the
------closure compatibility `x ∈ J → cl x ∈ J` is guaranteed by the extensiveness
------axiom combined with the ideal's upward-directed property.
------
------In our setting, we construct the admissible evaluation directly from the prime ideal
------rather than requiring an intermediate Jacobson prime point with cl-closure. The
------evaluation `e(z) = (cl z ∉ J)` automatically absorbs `cl`.
-------/
------theorem prime_separation_yields_admissible_evaluation {x y : S}
------    (h : ∃ J : Ideal S, J.IsPrime ∧ separates J x y) :
------    ∃ e, AdmissibleEvaluation (S := S) e ∧ ¬ (e x → e y) := by
------  obtain ⟨ J, hJ₁, hJ₂ ⟩ := h;
------  refine' ⟨ fun z => cl' z ∉ J, ⟨ _, _ ⟩, _ ⟩ <;> simp_all +decide [ separates ];
------  · intro x y hxy hx hy;
------    exact hx ( J.lower (cl_monotone x y hxy) hy );
------  · have := ‹CoherentClosureProofSemiring S›.cl_idempotent; aesop;
------
------/-! ## Counterevaluation -/
------
------/-- **Jacobson counterevaluation theorem**: if `x` does not derive `y`, then there
------exists an admissible evaluation `e` witnessing the failure: `e x` holds but `e y` does not.
------
------This combines prime separation (from the distributive lattice prime ideal theorem)
------with the evaluation construction from the separating ideal. -/
------theorem not_derivable_exists_jacobson_counterevaluation {x y : S}
------    (hnd : ¬ derivable x y) :
------    ∃ e, AdmissibleEvaluation (S := S) e ∧ ¬ (e x → e y) := by
------  exact prime_separation_yields_admissible_evaluation (not_derivable_exists_prime_separation hnd)
------
------/-! ## Completeness -/
------
------/-- **Completeness**: if every admissible evaluation validates `e x → e y`,
------then `derivable x y`.
------
------*Proof.* By contrapositive. If `¬ derivable x y`, the counterevaluation theorem
------produces an admissible `e` with `e x` and `¬ e y`, contradicting the hypothesis. -/
------theorem derivable_of_valid_in_all_admissible_evaluations {x y : S}
------    (hsem : ∀ e, AdmissibleEvaluation (S := S) e → (e x → e y)) :
------    derivable x y := by
------  by_contra hnd
------  obtain ⟨e, he, hne⟩ := not_derivable_exists_jacobson_counterevaluation hnd
------  exact hne (hsem e he)
------
------/-! ## Main Adequacy Theorem -/
------
------/-- **Semantic Adequacy (predicate form)**: derivability is exactly validation
------in all admissible evaluations.
------
------```
------derivable x y ↔ ∀ e, AdmissibleEvaluation e → (e x → e y)
------```
------
------The forward direction is soundness; the reverse is completeness via contrapositive
------using the Jacobson counterevaluation theorem. -/
------theorem derivable_iff_all_jacobson_evaluations_validate'
------    (x y : S) :
------    derivable x y ↔ ∀ e, AdmissibleEvaluation (S := S) e → (e x → e y) := by
------  constructor
------  · intro hxy e he
------    exact derivable_sound_for_admissible_evaluations hxy e he
------  · exact derivable_of_valid_in_all_admissible_evaluations
------
------/-- **Semantic Adequacy (set-membership form)**: equivalent formulation using
------`admissibleEvaluations S` as a set. -/
------theorem derivable_iff_all_jacobson_evaluations_validate
------    (x y : S) :
------    derivable x y ↔ ∀ e ∈ admissibleEvaluations S, (e x → e y) := by
------  rw [derivable_iff_all_jacobson_evaluations_validate']
------  simp only [admissibleEvaluations, Set.mem_setOf_eq]
------
------/-- **Kernel intersection**: the derivability relation equals the semantic preorder
------(intersection of all admissible evaluation kernels).
------
------This is the algebraic engine behind adequacy: the proof congruence is exactly
------the intersection of all evaluation kernels. -/
------theorem derivable_iff_mem_jacobson_kernel (x y : S) :
------    derivable x y ↔ ∀ e, AdmissibleEvaluation (S := S) e → e x → e y :=
------  derivable_iff_all_jacobson_evaluations_validate' x y
------
------/-- The proof congruence equals the semantic preorder. -/
------theorem proof_congruence_eq_semantic :
------    (proofCongruence : S → S → Prop) = semanticPreorder := by
------  ext x y
------  exact derivable_iff_all_jacobson_evaluations_validate' x y
------
------/-! ## Jacobson Prime Point Structure -/
------
------/-- From a prime ideal in a bounded distributive lattice, construct a Jacobson
------prime point by considering the closure-compatible variant. The evaluation
------`e(z) = (cl z ∉ J)` bypasses the need for `J` itself to be cl-closed. -/
------theorem not_derivable_exists_jacobson_prime_separator {x y : S}
------    (hnd : ¬ derivable x y) :
------    ∃ J : Ideal S, J.IsPrime ∧ separates J x y :=
------  not_derivable_exists_prime_separation hnd
------
------end CoherentClosureProofSemiring+-/
-----+import Bridges.MackeyCompletion.Defs
-----+
-----+/-!
-----+# Theorems on Functorial Mackey Completion
-----+
-----+This file contains the main theorems establishing the functorial Mackey completion
-----+for maxitive measures on finite T₀ spaces via codensity assignments.
-----+
-----+## Main results
-----+
-----+* `codensity_roundtrip` — `measureToCodensity ∘ codensityToMeasure = id`
-----+* `codensityToMeasure_maxitive` — `codensityToMeasure` produces maxitive measures
-----+* `maxitive_supportGaugeEq_implies_eq` — maxitive measures agreeing on codensities are equal
-----+* `supportGaugeEq_implies_idempotentKantorovich_zero` — the easy direction
-----+* `idempotentKantorovich_zero_implies_supportGaugeEq` — the hard direction
-----+* `toCodensityFun_surjective` — surjectivity onto `X → ℝ≥0∞` (requires T₀)
-----+* `quotient_equiv_functions` — quotient ≃ `X → ℝ≥0∞`
-----+* `pushforward_maxitive_preserves_supportGaugeEq` — functoriality for maxitive measures
-----+* `finite_support_pattern_eventually_stable` — finite stabilization
-----+* `FunctorialIdempotentMackeyCompletion` — the main theorem
-----+-/
-----+
-----+noncomputable section
-----+
-----+open scoped ENNReal
-----+open Set
-----+
-----+variable {X : Type*} [Fintype X] [Preorder X]
-----+
-----+/-! ## Basic Properties of Irreducible Closed Sets -/
-----+
-----+/-- Principal lower sets are monotone: `x ≤ y → ↓x ⊆ ↓y`. -/
-----+theorem irreducibleClosed_monotone :
-----+    Monotone (irreducibleClosed X) :=
-----+  fun _ _ hxy _ hz => le_trans hz hxy
-----+
-----+/-- In a finite T₀ space, principal lower sets are injective. -/
-----+theorem irreducibleClosed_injective [FiniteT0SupportClass X] :
-----+    Function.Injective (irreducibleClosed X) := by
-----+  intro x y h
-----+  apply FiniteT0SupportClass.antisymm_of_closure_eq
-----+  intro z
-----+  have := Set.ext_iff.mp h z
-----+  simp only [irreducibleClosed, mem_setOf_eq] at this
-----+  exact this
-----+
-----+/-- Codensity weights are monotone for monotone set functions. -/
-----+theorem irreducibleClosedWeight_monotone
-----+    (μ : Set X → ℝ≥0∞) (hμ : IsMonotoneSetFun μ) :
-----+    Monotone (irreducibleClosedWeight μ) :=
-----+  fun _ _ hxy => hμ (irreducibleClosed_monotone hxy)
-----+
-----+/-! ## Codensity To Measure Properties -/
-----+
-----+/-- The set function constructed from a codensity assignment is monotone. -/
-----+theorem codensityToMeasure_mono (c : CodensityAssignment X) :
-----+    IsMonotoneSetFun (codensityToMeasure c) := by
-----+  intro A B hAB
-----+  simp only [codensityToMeasure]
-----+  exact iSup₂_mono' (fun x hx => ⟨x, hAB hx, le_rfl⟩)
-----+
-----+/-
-----+`codensityToMeasure` produces maxitive set functions.
-----+-/
-----+theorem codensityToMeasure_maxitive (c : CodensityAssignment X) :
-----+    IsMaxitiveSetFun (codensityToMeasure c) := by
-----+  intro A;
-----+  refine' iSup_congr fun x => iSup_congr fun hx => le_antisymm _ _;
-----+  · exact le_iSup₂_of_le x ( by simp +decide [ irreducibleClosed ] ) le_rfl;
-----+  · exact iSup₂_le fun y hy => c.monotone hy
-----+
-----+/-! ## The Codensity Round-Trip -/
-----+
-----+/-- The key round-trip identity: `⨆ y ≤ x, c y = c x` by monotonicity. -/
-----+theorem codensity_roundtrip (c : CodensityAssignment X) (x : X) :
-----+    irreducibleClosedWeight (codensityToMeasure c) x = c.toFun x := by
-----+  refine le_antisymm (iSup₂_le fun y hy => ?_) ?_
-----+  · exact c.monotone' hy
-----+  · exact le_iSup₂_of_le x le_rfl le_rfl
-----+
-----+/-- `measureToCodensity ∘ codensityToMeasure = id` on codensity assignments. -/
-----+theorem measureToCodensity_codensityToMeasure (c : CodensityAssignment X) :
-----+    measureToCodensity (codensityToMeasure c) (codensityToMeasure_mono c) = c := by
-----+  ext x; exact codensity_roundtrip c x
-----+
-----+/-! ## Maxitive Measures and Support Gauge -/
-----+
-----+/-
-----+For maxitive measures, `supportGaugeEq` implies agreement on ALL sets,
-----+    not just principal lower sets. This is the key structural property.
-----+-/
-----+theorem maxitive_supportGaugeEq_implies_eq
-----+    {μ ν : Set X → ℝ≥0∞}
-----+    (hμ : IsMaxitiveSetFun μ) (hν : IsMaxitiveSetFun ν)
-----+    (h : supportGaugeEq μ ν) :
-----+    μ = ν := by
-----+  -- By definition of maxitivity, we can write μ(A) and ν(A) as suprema over the principal lower sets of elements in A.
-----+  have h_max : ∀ A : Set X, μ A = ⨆ x ∈ A, μ (irreducibleClosed X x) ∧ ν A = ⨆ x ∈ A, ν (irreducibleClosed X x) := by
-----+    exact fun A => ⟨ hμ A, hν A ⟩;
-----+  ext A; specialize h_max A; simp_all +decide [ supportGaugeEq ] ;
-----+  exact iSup_congr fun x => iSup_congr fun hx => h x
-----+
-----+/-! ## Zero-Distance Characterization -/
-----+
-----+/-- If codensity weights agree, then `idempotentKantorovich = 0`. -/
-----+theorem supportGaugeEq_implies_idempotentKantorovich_zero
-----+    (μ ν : Set X → ℝ≥0∞) (h : supportGaugeEq μ ν) :
-----+    idempotentKantorovich μ ν = 0 := by
-----+  unfold idempotentKantorovich
-----+  simp_all +decide [irreducibleClosedWeight, supportGaugeEq]
-----+
-----+/-
-----+If `idempotentKantorovich μ ν = 0` and both set functions are monotone
-----+    (so their codensity weights are monotone), then codensity weights agree.
-----+    Uses the codensity weight function itself as a monotone test function.
-----+-/
-----+theorem idempotentKantorovich_zero_implies_supportGaugeEq
-----+    (μ ν : Set X → ℝ≥0∞)
-----+    (hμm : IsMonotoneSetFun μ) (hνm : IsMonotoneSetFun ν)
-----+    (hμfin : ∀ x : X, irreducibleClosedWeight μ x ≠ ⊤)
-----+    (hνfin : ∀ x : X, irreducibleClosedWeight ν x ≠ ⊤)
-----+    (h : idempotentKantorovich μ ν = 0) :
-----+    supportGaugeEq μ ν := by
-----+  intro x;
-----+  contrapose! h;
-----+  cases lt_or_gt_of_ne h <;> simp_all +decide [ idempotentKantorovich ];
-----+  · refine' ⟨ fun y => ( irreducibleClosedWeight ν y |> ENNReal.toReal ), _, _ ⟩ <;> simp_all +decide [ IsTestFunction ];
-----+    · exact fun x y hxy => ENNReal.toReal_mono ( hνfin _ ) ( irreducibleClosedWeight_monotone ν hνm hxy );
-----+    · refine' ne_of_gt ( lt_of_lt_of_le _ ( le_ciSup _ x ) ) <;> norm_num [ hμfin, hνfin ];
-----+      assumption;
-----+  · refine' ⟨ fun y => ( irreducibleClosedWeight μ y |> ENNReal.toReal ), _, _ ⟩ <;> simp_all +decide [ IsTestFunction ];
-----+    · exact fun x y hxy => ENNReal.toReal_mono ( hμfin _ ) ( irreducibleClosedWeight_monotone μ hμm hxy );
-----+    · refine' ne_of_gt ( lt_of_lt_of_le _ ( le_ciSup _ x ) );
-----+      · exact sub_pos_of_lt ( ENNReal.toReal_strict_mono ( by aesop ) ‹_› );
-----+      · exact Set.finite_range _ |> Set.Finite.bddAbove
-----+
-----+/-- The full zero-distance characterization for monotone set functions
-----+    with finite codensity weights. -/
-----+theorem idempotentKantorovich_eq_zero_iff_supportGaugeEq
-----+    (μ ν : Set X → ℝ≥0∞)
-----+    (hμm : IsMonotoneSetFun μ) (hνm : IsMonotoneSetFun ν)
-----+    (hμfin : ∀ x : X, irreducibleClosedWeight μ x ≠ ⊤)
-----+    (hνfin : ∀ x : X, irreducibleClosedWeight ν x ≠ ⊤) :
-----+    idempotentKantorovich μ ν = 0 ↔ supportGaugeEq μ ν :=
-----+  ⟨idempotentKantorovich_zero_implies_supportGaugeEq μ ν hμm hνm hμfin hνfin,
-----+   supportGaugeEq_implies_idempotentKantorovich_zero μ ν⟩
-----+
-----+/-! ## The Quotient–Codensity Equivalence -/
-----+
-----+/-- The map from set functions to codensity weight functions. -/
-----+def toCodensityFun (μ : Set X → ℝ≥0∞) : X → ℝ≥0∞ :=
-----+  irreducibleClosedWeight μ
-----+
-----+/-- Two set functions are `supportGaugeEq` iff their codensity weight functions agree. -/
-----+theorem supportGaugeEq_iff_toCodensityFun_eq (μ ν : Set X → ℝ≥0∞) :
-----+    supportGaugeEq μ ν ↔ toCodensityFun μ = toCodensityFun ν := by
-----+  simp [supportGaugeEq, toCodensityFun, funext_iff]
-----+
-----+/-
-----+In a finite T₀ space, every function `X → ℝ≥0∞` arises as the codensity
-----+    weight function of some set function.
-----+-/
-----+theorem toCodensityFun_surjective [FiniteT0SupportClass X] :
-----+    Function.Surjective (toCodensityFun (X := X)) := by
-----+  -- For any function $g : X \to \mathbb{R}_{\geq 0}^\infty$, we can define a set function $\mu$ such that $\mu(\downarrow x) = g(x)$ for all $x \in X$.
-----+  have h_set_function : ∀ g : X → ℝ≥0∞, ∃ μ : Set X → ℝ≥0∞, ∀ x : X, μ (irreducibleClosed X x) = g x := by
-----+    intro g
-----+    obtain ⟨μ, hμ⟩ : ∃ μ : Set X → ℝ≥0∞, ∀ x : X, μ (irreducibleClosed X x) = g x := by
-----+      have h_inj : Function.Injective (irreducibleClosed X) := irreducibleClosed_injective
-----+      -- Since the irreducible closed sets are unique, we can define μ on these sets and extend it to all subsets.
-----+      have h_ext : ∃ μ : Set X → ℝ≥0∞, ∀ x : X, μ (irreducibleClosed X x) = g x := by
-----+        have h_unique : ∀ A : Set X, (∃ x : X, irreducibleClosed X x = A) → ∃! y : ℝ≥0∞, ∃ x : X, irreducibleClosed X x = A ∧ g x = y := by
-----+          exact fun A hA => by obtain ⟨ x, rfl ⟩ := hA; exact ⟨ g x, ⟨ x, rfl, rfl ⟩, fun y hy => by obtain ⟨ z, hz₁, rfl ⟩ := hy; exact congr_arg g ( h_inj hz₁ ) ⟩ ;
-----+        choose! μ hμ₁ hμ₂ using h_unique;
-----+        exact ⟨ μ, fun x => hμ₂ _ ⟨ x, rfl ⟩ _ ⟨ x, rfl, rfl ⟩ ▸ rfl ⟩;
-----+      exact h_ext;
-----+    use μ;
-----+  exact fun g => by obtain ⟨ μ, hμ ⟩ := h_set_function g; exact ⟨ μ, funext hμ ⟩ ;
-----+
-----+/-
-----+In a finite T₀ space, the quotient of set functions by `supportGaugeEq`
-----+    is equivalent to `X → ℝ≥0∞`.
-----+-/
-----+def quotient_equiv_functions [FiniteT0SupportClass X] :
-----+    Quotient (supportGaugeSetoid X) ≃ (X → ℝ≥0∞) :=
-----+  Equiv.ofBijective
-----+    (Quotient.lift toCodensityFun (fun a b h =>
-----+      (supportGaugeEq_iff_toCodensityFun_eq a b).mp h))
-----+    ⟨fun a b h => by
-----+        induction a using Quotient.ind
-----+        induction b using Quotient.ind
-----+        exact Quotient.sound ((supportGaugeEq_iff_toCodensityFun_eq _ _).mpr h),
-----+     fun g => by
-----+        obtain ⟨μ, hμ⟩ := toCodensityFun_surjective g
-----+        exact ⟨Quotient.mk _ μ, hμ⟩⟩
-----+
-----+/-- For monotone set functions, `measureToCodensity` descends to a well-defined map. -/
-----+theorem measureToCodensity_respects_supportGaugeEq
-----+    {μ ν : Set X → ℝ≥0∞}
-----+    (hμ : IsMonotoneSetFun μ) (hν : IsMonotoneSetFun ν)
-----+    (h : supportGaugeEq μ ν) :
-----+    measureToCodensity μ hμ = measureToCodensity ν hν := by
-----+  ext x; exact h x
-----+
-----+/-- For every `CodensityAssignment`, there exists a monotone set function
-----+    whose codensity weights recover it (namely `codensityToMeasure`). -/
-----+theorem codensityAssignment_surjective (c : CodensityAssignment X) :
-----+    ∃ (μ : Set X → ℝ≥0∞) (hμ : IsMonotoneSetFun μ),
-----+      measureToCodensity μ hμ = c :=
-----+  ⟨codensityToMeasure c, codensityToMeasure_mono c,
-----+   measureToCodensity_codensityToMeasure c⟩
-----+
-----+/-! ## Pushforward and Functoriality -/
-----+
-----+/-
-----+Pushforward of maxitive measures preserves `supportGaugeEq`:
-----+    if two maxitive set functions agree on all principal lower sets,
-----+    their pushforwards also agree on all principal lower sets.
-----+-/
-----+theorem pushforward_maxitive_preserves_supportGaugeEq
-----+    {Y : Type*} [Fintype Y] [Preorder Y]
-----+    (f : X → Y)
-----+    {μ ν : Set X → ℝ≥0∞}
-----+    (hμ : IsMaxitiveSetFun μ) (hν : IsMaxitiveSetFun ν)
-----+    (h : supportGaugeEq μ ν) :
-----+    supportGaugeEq (pushforward f μ) (pushforward f ν) := by
-----+  intro y;
-----+  have h_pushforward_lower_set : ∀ y : Y, ⨆ x ∈ f ⁻¹' {y' | y' ≤ y}, μ (irreducibleClosed X x) = ⨆ x ∈ f ⁻¹' {y' | y' ≤ y}, ν (irreducibleClosed X x) := by
-----+    exact fun y => iSup_congr fun x => iSup_congr fun hx => h x;
-----+  convert h_pushforward_lower_set y using 1;
-----+  · convert hμ ( f ⁻¹' { y' | y' ≤ y } ) using 1;
-----+  · convert hν ( f ⁻¹' { y' | y' ≤ y } ) using 1
-----+
-----+/-- Pushforward of codensity: given a monotone map `f : X → Y`, the induced
-----+    map on codensity assignments. -/
-----+def pushforwardCodensity
-----+    {Y : Type*} [Fintype Y] [Preorder Y]
-----+    (f : X → Y) (_hf : Monotone f)
-----+    (c : CodensityAssignment X) : CodensityAssignment Y where
-----+  toFun y := ⨆ x : {x : X // f x ≤ y}, c.toFun x.1
-----+  monotone' := by
-----+    intro y₁ y₂ hy
-----+    apply iSup_le
-----+    intro ⟨x, hx⟩
-----+    exact le_iSup_of_le ⟨x, le_trans hx hy⟩ le_rfl
-----+
-----+/-
-----+The codensity pushforward commutes with the round-trip: measuring the
-----+    pushforward at y gives the same as the pushforwardCodensity.
-----+-/
-----+theorem pushforward_codensity_commutes
-----+    {Y : Type*} [Fintype Y] [Preorder Y]
-----+    (f : X → Y) (hf : Monotone f) (c : CodensityAssignment X) (y : Y) :
-----+    irreducibleClosedWeight (pushforward f (codensityToMeasure c)) y =
-----+      (pushforwardCodensity f hf c).toFun y := by
-----+  refine' le_antisymm _ _;
-----+  · refine' iSup₂_le fun x hx => le_iSup_of_le ⟨ x, hx ⟩ le_rfl;
-----+  · refine' iSup_le _;
-----+    intro ⟨ x, hx ⟩;
-----+    refine' le_trans _ ( le_iSup _ x );
-----+    exact le_iSup_of_le ( show x ∈ f ⁻¹' irreducibleClosed Y y from hx ) le_rfl
-----+
-----+/-! ## Finite Stabilization -/
-----+
-----+/-- In a finite space, pointwise eventual constancy implies global stabilization. -/
-----+theorem finite_support_pattern_eventually_stable
-----+    (u : ℕ → Set X → ℝ≥0∞) :
-----+    (∀ x : X, ∃ N, ∀ m n, N ≤ m → N ≤ n →
-----+      irreducibleClosedWeight (u m) x = irreducibleClosedWeight (u n) x) →
-----+    ∃ (w : X → ℝ≥0∞) (N : ℕ), ∀ n, N ≤ n →
-----+      ∀ x, irreducibleClosedWeight (u n) x = w x := by
-----+  intros h_codensity
-----+  obtain ⟨N, hN⟩ : ∃ N, ∀ x : X, ∀ m ≥ N, ∀ n ≥ N,
-----+      irreducibleClosedWeight (u m) x = irreducibleClosedWeight (u n) x := by
-----+    choose! N hN using id h_codensity
-----+    exact ⟨Finset.univ.sup N, fun x m hm n hn =>
-----+      hN x m n (le_trans (Finset.le_sup (f := N) (Finset.mem_univ x)) hm)
-----+        (le_trans (Finset.le_sup (f := N) (Finset.mem_univ x)) hn)⟩
-----+  exact ⟨_, N, fun n hn x => hN x n hn N le_rfl⟩
-----+
-----+/-! ## The Functorial Mackey Completion Theorem -/
-----+
-----+/-- **Functorial Idempotent Mackey Completion.**
-----+    For maxitive measures on finite T₀ spaces, the codensity completion
-----+    is functorial: pushforward along monotone maps preserves the
-----+    codensity equivalence relation, and the completion commutes with
-----+    pushforward at the level of codensity assignments. -/
-----+theorem FunctorialIdempotentMackeyCompletion
-----+    {Y : Type*} [Fintype Y] [Preorder Y]
-----+    (f : X → Y) (hf : Monotone f) :
-----+    -- Part 1: Pushforward preserves codensity equivalence for maxitive measures
-----+    (∀ {μ ν : Set X → ℝ≥0∞},
-----+      IsMaxitiveSetFun μ → IsMaxitiveSetFun ν →
-----+      supportGaugeEq μ ν →
-----+      supportGaugeEq (pushforward f μ) (pushforward f ν)) ∧
-----+    -- Part 2: The completion commutes with pushforward
-----+    (∀ c : CodensityAssignment X, ∀ y : Y,
-----+      irreducibleClosedWeight (pushforward f (codensityToMeasure c)) y =
-----+        (pushforwardCodensity f hf c).toFun y) := by
-----+  exact ⟨fun hμ hν h => pushforward_maxitive_preserves_supportGaugeEq f hμ hν h,
-----+         fun c y => pushforward_codensity_commutes f hf c y⟩
-----+
-----+end+/-
----+Copyright (c) 2025. All rights reserved.
----+Released under Apache 2.0 license as described in the file LICENSE.
----+-/
---+@@ -1,172 +1,307 @@
---+ /-
---+ Copyright (c) 2025. All rights reserved.
---+ Released under Apache 2.0 license as described in the file LICENSE.
---+-
---+-# Semantic Adequacy Theorems
---+-
---+-This file proves the main semantic adequacy theorem for coherent closure proof semirings:
---+-
---+-> **Theorem** (Jacobson Adequacy). For elements `x, y` of a coherent closure proof semiring,
---+-> `derivable x y` if and only if every admissible evaluation validates `e x → e y`.
---+-
---+-The proof has two parts:
---+-1. **Soundness** (`derivable_sound_for_admissible_evaluations`): monotonicity and
---+-   closure compatibility of admissible evaluations imply they validate all derivable pairs.
---+-2. **Completeness** (`derivable_of_valid_in_all_admissible_evaluations`): if every
---+-   admissible evaluation validates `e x → e y`, then `derivable x y`. The contrapositive
---+-   uses the prime ideal theorem for bounded distributive lattices to extract a
---+-   Jacobson prime witness, which yields an admissible counterevaluation.
---+-
---+-## Key Intermediate Results
---+-
---+-* `not_derivable_exists_prime_separation` — non-derivability implies existence of a
---+-  separating prime ideal (via the prime ideal theorem for distributive lattices)
---+-* `prime_separation_yields_admissible_evaluation` — a separating prime ideal yields
---+-  an admissible evaluation witnessing the failure
---+-* `not_derivable_exists_jacobson_counterevaluation` — the combined countermodel theorem
---+-* `derivable_iff_all_jacobson_evaluations_validate` — the main biconditional
---+-* `jacobson_proof_congruence_eq_semantic` — the proof congruence equals the
---+-  semantic preorder (intersection of all evaluation kernels)
---+--/
---+-
---+-import Bridges.JacobsonAdequacy.Defs
---+-
---+-open Order Set CoherentClosureProofSemiring
---+-
---+-namespace CoherentClosureProofSemiring
---+-
---+-variable {S : Type*} [CoherentClosureProofSemiring S]
---+-
---+-/-! ## Soundness -/
---+-
---+-/-- **Soundness**: every derivable pair is validated by every admissible evaluation.
---+-
---+-If `derivable x y` (i.e., `cl x ≤ cl y`) and `e` is an admissible evaluation
---+-(monotone and closure-compatible), then `e x → e y`.
---+-
---+-*Proof.* From `e x`, closure compatibility gives `e (cl x)`. Monotonicity with
---+-`cl x ≤ cl y` gives `e (cl y)`. Closure compatibility again gives `e y`. -/
---+-theorem derivable_sound_for_admissible_evaluations {x y : S}
---+-    (hxy : derivable x y)
---+-    (e : S → Prop) (he : AdmissibleEvaluation (S := S) e) :
---+-    e x → e y := by
---+-  intro hex
---+-  exact (he.cl_compat y).mp (he.monotone _ _ hxy ((he.cl_compat x).mpr hex))
---+-
---+-/-! ## Prime Separation -/
---+-
---+-/-
---+-If `¬ derivable x y`, then there exists a prime ideal `J` of the distributive
---+-lattice separating `cl x` from `cl y`: specifically `cl y ∈ J` and `cl x ∉ J`.
---+-
---+-This is the core application of the **prime ideal theorem for bounded distributive
---+-lattices** (`DistribLattice.prime_ideal_of_disjoint_filter_ideal`). The principal
---+-filter of `cl x` and the principal ideal of `cl y` are disjoint precisely when
---+-`cl x ≰ cl y`, and the theorem upgrades this to a prime ideal.
---+--/
---+-theorem not_derivable_exists_prime_separation {x y : S}
---+-    (hnd : ¬ derivable x y) :
---+-    ∃ J : Ideal S, J.IsPrime ∧ separates J x y := by
---+-  have h_disjoint : Disjoint (Order.PFilter.principal (cl' x) : Set S) (Order.Ideal.principal (cl' y) : Set S) := by
---+-    exact Set.disjoint_left.mpr fun z hz₁ hz₂ => hnd <| by exact le_trans hz₁ hz₂;
---+-  obtain ⟨ J, hJ₁, hJ₂ ⟩ := DistribLattice.prime_ideal_of_disjoint_filter_ideal h_disjoint;
---+-  refine' ⟨ J, hJ₁, _, _ ⟩ <;> simp_all +decide [ Set.disjoint_left ]
---+-
---+-/-
---+-Any prime ideal in a bounded distributive lattice naturally gives rise to a
---+-Jacobson prime point: since the lattice order ideal is downward-closed, the
---+-closure compatibility `x ∈ J → cl x ∈ J` is guaranteed by the extensiveness
---+-axiom combined with the ideal's upward-directed property.
---+-
---+-In our setting, we construct the admissible evaluation directly from the prime ideal
---+-rather than requiring an intermediate Jacobson prime point with cl-closure. The
---+-evaluation `e(z) = (cl z ∉ J)` automatically absorbs `cl`.
---+--/
---+-theorem prime_separation_yields_admissible_evaluation {x y : S}
---+-    (h : ∃ J : Ideal S, J.IsPrime ∧ separates J x y) :
---+-    ∃ e, AdmissibleEvaluation (S := S) e ∧ ¬ (e x → e y) := by
---+-  obtain ⟨ J, hJ₁, hJ₂ ⟩ := h;
---+-  refine' ⟨ fun z => cl' z ∉ J, ⟨ _, _ ⟩, _ ⟩ <;> simp_all +decide [ separates ];
---+-  · intro x y hxy hx hy;
---+-    exact hx ( J.lower (cl_monotone x y hxy) hy );
---+-  · have := ‹CoherentClosureProofSemiring S›.cl_idempotent; aesop;
---+-
---+-/-! ## Counterevaluation -/
---+-
---+-/-- **Jacobson counterevaluation theorem**: if `x` does not derive `y`, then there
---+-exists an admissible evaluation `e` witnessing the failure: `e x` holds but `e y` does not.
---+-
---+-This combines prime separation (from the distributive lattice prime ideal theorem)
---+-with the evaluation construction from the separating ideal. -/
---+-theorem not_derivable_exists_jacobson_counterevaluation {x y : S}
---+-    (hnd : ¬ derivable x y) :
---+-    ∃ e, AdmissibleEvaluation (S := S) e ∧ ¬ (e x → e y) := by
---+-  exact prime_separation_yields_admissible_evaluation (not_derivable_exists_prime_separation hnd)
---+-
---+-/-! ## Completeness -/
---+-
---+-/-- **Completeness**: if every admissible evaluation validates `e x → e y`,
---+-then `derivable x y`.
---+-
---+-*Proof.* By contrapositive. If `¬ derivable x y`, the counterevaluation theorem
---+-produces an admissible `e` with `e x` and `¬ e y`, contradicting the hypothesis. -/
---+-theorem derivable_of_valid_in_all_admissible_evaluations {x y : S}
---+-    (hsem : ∀ e, AdmissibleEvaluation (S := S) e → (e x → e y)) :
---+-    derivable x y := by
---+-  by_contra hnd
---+-  obtain ⟨e, he, hne⟩ := not_derivable_exists_jacobson_counterevaluation hnd
---+-  exact hne (hsem e he)
---+-
---+-/-! ## Main Adequacy Theorem -/
---+-
---+-/-- **Semantic Adequacy (predicate form)**: derivability is exactly validation
---+-in all admissible evaluations.
---+-
---+-```
---+-derivable x y ↔ ∀ e, AdmissibleEvaluation e → (e x → e y)
---+-```
---+-
---+-The forward direction is soundness; the reverse is completeness via contrapositive
---+-using the Jacobson counterevaluation theorem. -/
---+-theorem derivable_iff_all_jacobson_evaluations_validate'
---+-    (x y : S) :
---+-    derivable x y ↔ ∀ e, AdmissibleEvaluation (S := S) e → (e x → e y) := by
---+-  constructor
---+-  · intro hxy e he
---+-    exact derivable_sound_for_admissible_evaluations hxy e he
---+-  · exact derivable_of_valid_in_all_admissible_evaluations
---+-
---+-/-- **Semantic Adequacy (set-membership form)**: equivalent formulation using
---+-`admissibleEvaluations S` as a set. -/
---+-theorem derivable_iff_all_jacobson_evaluations_validate
---+-    (x y : S) :
---+-    derivable x y ↔ ∀ e ∈ admissibleEvaluations S, (e x → e y) := by
---+-  rw [derivable_iff_all_jacobson_evaluations_validate']
---+-  simp only [admissibleEvaluations, Set.mem_setOf_eq]
---+-
---+-/-- **Kernel intersection**: the derivability relation equals the semantic preorder
---+-(intersection of all admissible evaluation kernels).
---+-
---+-This is the algebraic engine behind adequacy: the proof congruence is exactly
---+-the intersection of all evaluation kernels. -/
---+-theorem derivable_iff_mem_jacobson_kernel (x y : S) :
---+-    derivable x y ↔ ∀ e, AdmissibleEvaluation (S := S) e → e x → e y :=
---+-  derivable_iff_all_jacobson_evaluations_validate' x y
---+-
---+-/-- The proof congruence equals the semantic preorder. -/
---+-theorem proof_congruence_eq_semantic :
---+-    (proofCongruence : S → S → Prop) = semanticPreorder := by
---+-  ext x y
---+-  exact derivable_iff_all_jacobson_evaluations_validate' x y
---+-
---+-/-! ## Jacobson Prime Point Structure -/
---+-
---+-/-- From a prime ideal in a bounded distributive lattice, construct a Jacobson
---+-prime point by considering the closure-compatible variant. The evaluation
---+-`e(z) = (cl z ∉ J)` bypasses the need for `J` itself to be cl-closed. -/
---+-theorem not_derivable_exists_jacobson_prime_separator {x y : S}
---+-    (hnd : ¬ derivable x y) :
---+-    ∃ J : Ideal S, J.IsPrime ∧ separates J x y :=
---+-  not_derivable_exists_prime_separation hnd
---+-
---+-end CoherentClosureProofSemiring+-/
--- +import Bridges.MackeyCompletion.Defs
--- +
--- +/-!+/-
--+Copyright (c) 2025. All rights reserved.
--+Released under Apache 2.0 license as described in the file LICENSE.
--+-/
--+import Bridges.MackeyCompletion.Defs
--+
--+/-!
--+# Theorems on Functorial Mackey Completion
--+
--+This file contains the main theorems establishing the functorial Mackey completion
--+for maxitive measures on finite T₀ spaces via codensity assignments.
--+
--+## Main results
--+
--+* `codensity_roundtrip` — `measureToCodensity ∘ codensityToMeasure = id`
--+* `codensityToMeasure_maxitive` — `codensityToMeasure` produces maxitive measures
--+* `maxitive_supportGaugeEq_implies_eq` — maxitive measures agreeing on codensities are equal
--+* `supportGaugeEq_implies_idempotentKantorovich_zero` — the easy direction
--+* `idempotentKantorovich_zero_implies_supportGaugeEq` — the hard direction
--+* `toCodensityFun_surjective` — surjectivity onto `X → ℝ≥0∞` (requires T₀)
--+* `quotient_equiv_functions` — quotient ≃ `X → ℝ≥0∞`
--+* `pushforward_maxitive_preserves_supportGaugeEq` — functoriality for maxitive measures
--+* `finite_support_pattern_eventually_stable` — finite stabilization
--+* `FunctorialIdempotentMackeyCompletion` — the main theorem
--+-/
--+
--+noncomputable section
--+
--+open scoped ENNReal
--+open Set
--+
--+variable {X : Type*} [Fintype X] [Preorder X]
--+
--+/-! ## Basic Properties of Irreducible Closed Sets -/
--+
--+/-- Principal lower sets are monotone: `x ≤ y → ↓x ⊆ ↓y`. -/
--+theorem irreducibleClosed_monotone :
--+    Monotone (irreducibleClosed X) :=
--+  fun _ _ hxy _ hz => le_trans hz hxy
--+
--+/-- In a finite T₀ space, principal lower sets are injective. -/
--+theorem irreducibleClosed_injective [FiniteT0SupportClass X] :
--+    Function.Injective (irreducibleClosed X) := by
--+  intro x y h
--+  apply FiniteT0SupportClass.antisymm_of_closure_eq
--+  intro z
--+  have := Set.ext_iff.mp h z
--+  simp only [irreducibleClosed, mem_setOf_eq] at this
--+  exact this
--+
--+/-- Codensity weights are monotone for monotone set functions. -/
--+theorem irreducibleClosedWeight_monotone
--+    (μ : Set X → ℝ≥0∞) (hμ : IsMonotoneSetFun μ) :
--+    Monotone (irreducibleClosedWeight μ) :=
--+  fun _ _ hxy => hμ (irreducibleClosed_monotone hxy)
--+
--+/-! ## Codensity To Measure Properties -/
--+
--+/-- The set function constructed from a codensity assignment is monotone. -/
--+theorem codensityToMeasure_mono (c : CodensityAssignment X) :
--+    IsMonotoneSetFun (codensityToMeasure c) := by
--+  intro A B hAB
--+  simp only [codensityToMeasure]
--+  exact iSup₂_mono' (fun x hx => ⟨x, hAB hx, le_rfl⟩)
--+
--+/-
--+`codensityToMeasure` produces maxitive set functions.
--+-/
--+theorem codensityToMeasure_maxitive (c : CodensityAssignment X) :
--+    IsMaxitiveSetFun (codensityToMeasure c) := by
--+  intro A;
--+  refine' iSup_congr fun x => iSup_congr fun hx => le_antisymm _ _;
--+  · exact le_iSup₂_of_le x ( by simp +decide [ irreducibleClosed ] ) le_rfl;
--+  · exact iSup₂_le fun y hy => c.monotone hy
--+
--+/-! ## The Codensity Round-Trip -/
--+
--+/-- The key round-trip identity: `⨆ y ≤ x, c y = c x` by monotonicity. -/
--+theorem codensity_roundtrip (c : CodensityAssignment X) (x : X) :
--+    irreducibleClosedWeight (codensityToMeasure c) x = c.toFun x := by
--+  refine le_antisymm (iSup₂_le fun y hy => ?_) ?_
--+  · exact c.monotone' hy
--+  · exact le_iSup₂_of_le x le_rfl le_rfl
--+
--+/-- `measureToCodensity ∘ codensityToMeasure = id` on codensity assignments. -/
--+theorem measureToCodensity_codensityToMeasure (c : CodensityAssignment X) :
--+    measureToCodensity (codensityToMeasure c) (codensityToMeasure_mono c) = c := by
--+  ext x; exact codensity_roundtrip c x
--+
--+/-! ## Maxitive Measures and Support Gauge -/
--+
--+/-
--+For maxitive measures, `supportGaugeEq` implies agreement on ALL sets,
--+    not just principal lower sets. This is the key structural property.
--+-/
--+theorem maxitive_supportGaugeEq_implies_eq
--+    {μ ν : Set X → ℝ≥0∞}
--+    (hμ : IsMaxitiveSetFun μ) (hν : IsMaxitiveSetFun ν)
--+    (h : supportGaugeEq μ ν) :
--+    μ = ν := by
--+  -- By definition of maxitivity, we can write μ(A) and ν(A) as suprema over the principal lower sets of elements in A.
--+  have h_max : ∀ A : Set X, μ A = ⨆ x ∈ A, μ (irreducibleClosed X x) ∧ ν A = ⨆ x ∈ A, ν (irreducibleClosed X x) := by
--+    exact fun A => ⟨ hμ A, hν A ⟩;
--+  ext A; specialize h_max A; simp_all +decide [ supportGaugeEq ] ;
--+  exact iSup_congr fun x => iSup_congr fun hx => h x
--+
--+/-! ## Zero-Distance Characterization -/
--+
--+/-- If codensity weights agree, then `idempotentKantorovich = 0`. -/
--+theorem supportGaugeEq_implies_idempotentKantorovich_zero
--+    (μ ν : Set X → ℝ≥0∞) (h : supportGaugeEq μ ν) :
--+    idempotentKantorovich μ ν = 0 := by
--+  unfold idempotentKantorovich
--+  simp_all +decide [irreducibleClosedWeight, supportGaugeEq]
--+
--+/-
--+If `idempotentKantorovich μ ν = 0` and both set functions are monotone
--+    (so their codensity weights are monotone), then codensity weights agree.
--+    Uses the codensity weight function itself as a monotone test function.
--+-/
--+theorem idempotentKantorovich_zero_implies_supportGaugeEq
--+    (μ ν : Set X → ℝ≥0∞)
--+    (hμm : IsMonotoneSetFun μ) (hνm : IsMonotoneSetFun ν)
--+    (hμfin : ∀ x : X, irreducibleClosedWeight μ x ≠ ⊤)
--+    (hνfin : ∀ x : X, irreducibleClosedWeight ν x ≠ ⊤)
--+    (h : idempotentKantorovich μ ν = 0) :
--+    supportGaugeEq μ ν := by
--+  intro x;
--+  contrapose! h;
--+  cases lt_or_gt_of_ne h <;> simp_all +decide [ idempotentKantorovich ];
--+  · refine' ⟨ fun y => ( irreducibleClosedWeight ν y |> ENNReal.toReal ), _, _ ⟩ <;> simp_all +decide [ IsTestFunction ];
--+    · exact fun x y hxy => ENNReal.toReal_mono ( hνfin _ ) ( irreducibleClosedWeight_monotone ν hνm hxy );
--+    · refine' ne_of_gt ( lt_of_lt_of_le _ ( le_ciSup _ x ) ) <;> norm_num [ hμfin, hνfin ];
--+      assumption;
--+  · refine' ⟨ fun y => ( irreducibleClosedWeight μ y |> ENNReal.toReal ), _, _ ⟩ <;> simp_all +decide [ IsTestFunction ];
--+    · exact fun x y hxy => ENNReal.toReal_mono ( hμfin _ ) ( irreducibleClosedWeight_monotone μ hμm hxy );
--+    · refine' ne_of_gt ( lt_of_lt_of_le _ ( le_ciSup _ x ) );
--+      · exact sub_pos_of_lt ( ENNReal.toReal_strict_mono ( by aesop ) ‹_› );
--+      · exact Set.finite_range _ |> Set.Finite.bddAbove
--+
--+/-- The full zero-distance characterization for monotone set functions
--+    with finite codensity weights. -/
--+theorem idempotentKantorovich_eq_zero_iff_supportGaugeEq
--+    (μ ν : Set X → ℝ≥0∞)
--+    (hμm : IsMonotoneSetFun μ) (hνm : IsMonotoneSetFun ν)
--+    (hμfin : ∀ x : X, irreducibleClosedWeight μ x ≠ ⊤)
--+    (hνfin : ∀ x : X, irreducibleClosedWeight ν x ≠ ⊤) :
--+    idempotentKantorovich μ ν = 0 ↔ supportGaugeEq μ ν :=
--+  ⟨idempotentKantorovich_zero_implies_supportGaugeEq μ ν hμm hνm hμfin hνfin,
--+   supportGaugeEq_implies_idempotentKantorovich_zero μ ν⟩
--+
--+/-! ## The Quotient–Codensity Equivalence -/
--+
--+/-- The map from set functions to codensity weight functions. -/
--+def toCodensityFun (μ : Set X → ℝ≥0∞) : X → ℝ≥0∞ :=
--+  irreducibleClosedWeight μ
--+
--+/-- Two set functions are `supportGaugeEq` iff their codensity weight functions agree. -/
--+theorem supportGaugeEq_iff_toCodensityFun_eq (μ ν : Set X → ℝ≥0∞) :
--+    supportGaugeEq μ ν ↔ toCodensityFun μ = toCodensityFun ν := by
--+  simp [supportGaugeEq, toCodensityFun, funext_iff]
--+
--+/-
--+In a finite T₀ space, every function `X → ℝ≥0∞` arises as the codensity
--+    weight function of some set function.
--+-/
--+theorem toCodensityFun_surjective [FiniteT0SupportClass X] :
--+    Function.Surjective (toCodensityFun (X := X)) := by
--+  -- For any function $g : X \to \mathbb{R}_{\geq 0}^\infty$, we can define a set function $\mu$ such that $\mu(\downarrow x) = g(x)$ for all $x \in X$.
--+  have h_set_function : ∀ g : X → ℝ≥0∞, ∃ μ : Set X → ℝ≥0∞, ∀ x : X, μ (irreducibleClosed X x) = g x := by
--+    intro g
--+    obtain ⟨μ, hμ⟩ : ∃ μ : Set X → ℝ≥0∞, ∀ x : X, μ (irreducibleClosed X x) = g x := by
--+      have h_inj : Function.Injective (irreducibleClosed X) := irreducibleClosed_injective
--+      -- Since the irreducible closed sets are unique, we can define μ on these sets and extend it to all subsets.
--+      have h_ext : ∃ μ : Set X → ℝ≥0∞, ∀ x : X, μ (irreducibleClosed X x) = g x := by
--+        have h_unique : ∀ A : Set X, (∃ x : X, irreducibleClosed X x = A) → ∃! y : ℝ≥0∞, ∃ x : X, irreducibleClosed X x = A ∧ g x = y := by
--+          exact fun A hA => by obtain ⟨ x, rfl ⟩ := hA; exact ⟨ g x, ⟨ x, rfl, rfl ⟩, fun y hy => by obtain ⟨ z, hz₁, rfl ⟩ := hy; exact congr_arg g ( h_inj hz₁ ) ⟩ ;
--+        choose! μ hμ₁ hμ₂ using h_unique;
--+        exact ⟨ μ, fun x => hμ₂ _ ⟨ x, rfl ⟩ _ ⟨ x, rfl, rfl ⟩ ▸ rfl ⟩;
--+      exact h_ext;
--+    use μ;
--+  exact fun g => by obtain ⟨ μ, hμ ⟩ := h_set_function g; exact ⟨ μ, funext hμ ⟩ ;
--+
--+/-
--+In a finite T₀ space, the quotient of set functions by `supportGaugeEq`
--+    is equivalent to `X → ℝ≥0∞`.
--+-/
--+def quotient_equiv_functions [FiniteT0SupportClass X] :
--+    Quotient (supportGaugeSetoid X) ≃ (X → ℝ≥0∞) :=
--+  Equiv.ofBijective
--+    (Quotient.lift toCodensityFun (fun a b h =>
--+      (supportGaugeEq_iff_toCodensityFun_eq a b).mp h))
--+    ⟨fun a b h => by
--+        induction a using Quotient.ind
--+        induction b using Quotient.ind
--+        exact Quotient.sound ((supportGaugeEq_iff_toCodensityFun_eq _ _).mpr h),
--+     fun g => by
--+        obtain ⟨μ, hμ⟩ := toCodensityFun_surjective g
--+        exact ⟨Quotient.mk _ μ, hμ⟩⟩
--+
--+/-- For monotone set functions, `measureToCodensity` descends to a well-defined map. -/
--+theorem measureToCodensity_respects_supportGaugeEq
--+    {μ ν : Set X → ℝ≥0∞}
--+    (hμ : IsMonotoneSetFun μ) (hν : IsMonotoneSetFun ν)
--+    (h : supportGaugeEq μ ν) :
--+    measureToCodensity μ hμ = measureToCodensity ν hν := by
--+  ext x; exact h x
--+
--+/-- For every `CodensityAssignment`, there exists a monotone set function
--+    whose codensity weights recover it (namely `codensityToMeasure`). -/
--+theorem codensityAssignment_surjective (c : CodensityAssignment X) :
--+    ∃ (μ : Set X → ℝ≥0∞) (hμ : IsMonotoneSetFun μ),
--+      measureToCodensity μ hμ = c :=
--+  ⟨codensityToMeasure c, codensityToMeasure_mono c,
--+   measureToCodensity_codensityToMeasure c⟩
--+
--+/-! ## Pushforward and Functoriality -/
--+
--+/-
--+Pushforward of maxitive measures preserves `supportGaugeEq`:
--+    if two maxitive set functions agree on all principal lower sets,
--+    their pushforwards also agree on all principal lower sets.
--+-/
--+theorem pushforward_maxitive_preserves_supportGaugeEq
--+    {Y : Type*} [Fintype Y] [Preorder Y]
--+    (f : X → Y)
--+    {μ ν : Set X → ℝ≥0∞}
--+    (hμ : IsMaxitiveSetFun μ) (hν : IsMaxitiveSetFun ν)
--+    (h : supportGaugeEq μ ν) :
--+    supportGaugeEq (pushforward f μ) (pushforward f ν) := by
--+  intro y;
--+  have h_pushforward_lower_set : ∀ y : Y, ⨆ x ∈ f ⁻¹' {y' | y' ≤ y}, μ (irreducibleClosed X x) = ⨆ x ∈ f ⁻¹' {y' | y' ≤ y}, ν (irreducibleClosed X x) := by
--+    exact fun y => iSup_congr fun x => iSup_congr fun hx => h x;
--+  convert h_pushforward_lower_set y using 1;
--+  · convert hμ ( f ⁻¹' { y' | y' ≤ y } ) using 1;
--+  · convert hν ( f ⁻¹' { y' | y' ≤ y } ) using 1
--+
--+/-- Pushforward of codensity: given a monotone map `f : X → Y`, the induced
--+    map on codensity assignments. -/
--+def pushforwardCodensity
--+    {Y : Type*} [Fintype Y] [Preorder Y]
--+    (f : X → Y) (_hf : Monotone f)
--+    (c : CodensityAssignment X) : CodensityAssignment Y where
--+  toFun y := ⨆ x : {x : X // f x ≤ y}, c.toFun x.1
--+  monotone' := by
--+    intro y₁ y₂ hy
--+    apply iSup_le
--+    intro ⟨x, hx⟩
--+    exact le_iSup_of_le ⟨x, le_trans hx hy⟩ le_rfl
--+
--+/-
--+The codensity pushforward commutes with the round-trip: measuring the
--+    pushforward at y gives the same as the pushforwardCodensity.
--+-/
--+theorem pushforward_codensity_commutes
--+    {Y : Type*} [Fintype Y] [Preorder Y]
--+    (f : X → Y) (hf : Monotone f) (c : CodensityAssignment X) (y : Y) :
--+    irreducibleClosedWeight (pushforward f (codensityToMeasure c)) y =
--+      (pushforwardCodensity f hf c).toFun y := by
--+  refine' le_antisymm _ _;
--+  · refine' iSup₂_le fun x hx => le_iSup_of_le ⟨ x, hx ⟩ le_rfl;
--+  · refine' iSup_le _;
--+    intro ⟨ x, hx ⟩;
--+    refine' le_trans _ ( le_iSup _ x );
--+    exact le_iSup_of_le ( show x ∈ f ⁻¹' irreducibleClosed Y y from hx ) le_rfl
--+
--+/-! ## Finite Stabilization -/
--+
--+/-- In a finite space, pointwise eventual constancy implies global stabilization. -/
--+theorem finite_support_pattern_eventually_stable
--+    (u : ℕ → Set X → ℝ≥0∞) :
--+    (∀ x : X, ∃ N, ∀ m n, N ≤ m → N ≤ n →
--+      irreducibleClosedWeight (u m) x = irreducibleClosedWeight (u n) x) →
--+    ∃ (w : X → ℝ≥0∞) (N : ℕ), ∀ n, N ≤ n →
--+      ∀ x, irreducibleClosedWeight (u n) x = w x := by
--+  intros h_codensity
--+  obtain ⟨N, hN⟩ : ∃ N, ∀ x : X, ∀ m ≥ N, ∀ n ≥ N,
--+      irreducibleClosedWeight (u m) x = irreducibleClosedWeight (u n) x := by
--+    choose! N hN using id h_codensity
--+    exact ⟨Finset.univ.sup N, fun x m hm n hn =>
--+      hN x m n (le_trans (Finset.le_sup (f := N) (Finset.mem_univ x)) hm)
--+        (le_trans (Finset.le_sup (f := N) (Finset.mem_univ x)) hn)⟩
--+  exact ⟨_, N, fun n hn x => hN x n hn N le_rfl⟩
--+
--+/-! ## The Functorial Mackey Completion Theorem -/
--+
--+/-- **Functorial Idempotent Mackey Completion.**
--+    For maxitive measures on finite T₀ spaces, the codensity completion
--+    is functorial: pushforward along monotone maps preserves the
--+    codensity equivalence relation, and the completion commutes with
--+    pushforward at the level of codensity assignments. -/
--+theorem FunctorialIdempotentMackeyCompletion
--+    {Y : Type*} [Fintype Y] [Preorder Y]
--+    (f : X → Y) (hf : Monotone f) :
--+    -- Part 1: Pushforward preserves codensity equivalence for maxitive measures
--+    (∀ {μ ν : Set X → ℝ≥0∞},
--+      IsMaxitiveSetFun μ → IsMaxitiveSetFun ν →
--+      supportGaugeEq μ ν →
--+      supportGaugeEq (pushforward f μ) (pushforward f ν)) ∧
--+    -- Part 2: The completion commutes with pushforward
--+    (∀ c : CodensityAssignment X, ∀ y : Y,
--+      irreducibleClosedWeight (pushforward f (codensityToMeasure c)) y =
--+        (pushforwardCodensity f hf c).toFun y) := by
--+  exact ⟨fun hμ hν h => pushforward_maxitive_preserves_supportGaugeEq f hμ hν h,
--+         fun c y => pushforward_codensity_commutes f hf c y⟩
--+
--+end+/-
-+Copyright (c) 2025. All rights reserved.
-+Released under Apache 2.0 license as described in the file LICENSE.
-+-/
-+import Bridges.MackeyCompletion.Defs
-+
-+/-!
-+# Theorems on Functorial Mackey Completion
-+
-+This file contains the main theorems establishing the functorial Mackey completion
-+for maxitive measures on finite T₀ spaces via codensity assignments.
-+
-+## Main results
-+
-+* `codensity_roundtrip` — `measureToCodensity ∘ codensityToMeasure = id`
-+* `codensityToMeasure_maxitive` — `codensityToMeasure` produces maxitive measures
-+* `maxitive_supportGaugeEq_implies_eq` — maxitive measures agreeing on codensities are equal
-+* `supportGaugeEq_implies_idempotentKantorovich_zero` — the easy direction
-+* `idempotentKantorovich_zero_implies_supportGaugeEq` — the hard direction
-+* `toCodensityFun_surjective` — surjectivity onto `X → ℝ≥0∞` (requires T₀)
-+* `quotient_equiv_functions` — quotient ≃ `X → ℝ≥0∞`
-+* `pushforward_maxitive_preserves_supportGaugeEq` — functoriality for maxitive measures
-+* `finite_support_pattern_eventually_stable` — finite stabilization
-+* `FunctorialIdempotentMackeyCompletion` — the main theorem
-+-/
-+
-+noncomputable section
-+
-+open scoped ENNReal
-+open Set
-+
-+variable {X : Type*} [Fintype X] [Preorder X]
-+
-+/-! ## Basic Properties of Irreducible Closed Sets -/
-+
-+/-- Principal lower sets are monotone: `x ≤ y → ↓x ⊆ ↓y`. -/
-+theorem irreducibleClosed_monotone :
-+    Monotone (irreducibleClosed X) :=
-+  fun _ _ hxy _ hz => le_trans hz hxy
-+
-+/-- In a finite T₀ space, principal lower sets are injective. -/
-+theorem irreducibleClosed_injective [FiniteT0SupportClass X] :
-+    Function.Injective (irreducibleClosed X) := by
-+  intro x y h
-+  apply FiniteT0SupportClass.antisymm_of_closure_eq
-+  intro z
-+  have := Set.ext_iff.mp h z
-+  simp only [irreducibleClosed, mem_setOf_eq] at this
-+  exact this
-+
-+/-- Codensity weights are monotone for monotone set functions. -/
-+theorem irreducibleClosedWeight_monotone
-+    (μ : Set X → ℝ≥0∞) (hμ : IsMonotoneSetFun μ) :
-+    Monotone (irreducibleClosedWeight μ) :=
-+  fun _ _ hxy => hμ (irreducibleClosed_monotone hxy)
-+
-+/-! ## Codensity To Measure Properties -/
-+
-+/-- The set function constructed from a codensity assignment is monotone. -/
-+theorem codensityToMeasure_mono (c : CodensityAssignment X) :
-+    IsMonotoneSetFun (codensityToMeasure c) := by
-+  intro A B hAB
-+  simp only [codensityToMeasure]
-+  exact iSup₂_mono' (fun x hx => ⟨x, hAB hx, le_rfl⟩)
-+
-+/-
-+`codensityToMeasure` produces maxitive set functions.
-+-/
-+theorem codensityToMeasure_maxitive (c : CodensityAssignment X) :
-+    IsMaxitiveSetFun (codensityToMeasure c) := by
-+  intro A;
-+  refine' iSup_congr fun x => iSup_congr fun hx => le_antisymm _ _;
-+  · exact le_iSup₂_of_le x ( by simp +decide [ irreducibleClosed ] ) le_rfl;
-+  · exact iSup₂_le fun y hy => c.monotone hy
-+
-+/-! ## The Codensity Round-Trip -/
-+
-+/-- The key round-trip identity: `⨆ y ≤ x, c y = c x` by monotonicity. -/
-+theorem codensity_roundtrip (c : CodensityAssignment X) (x : X) :
-+    irreducibleClosedWeight (codensityToMeasure c) x = c.toFun x := by
-+  refine le_antisymm (iSup₂_le fun y hy => ?_) ?_
-+  · exact c.monotone' hy
-+  · exact le_iSup₂_of_le x le_rfl le_rfl
-+
-+/-- `measureToCodensity ∘ codensityToMeasure = id` on codensity assignments. -/
-+theorem measureToCodensity_codensityToMeasure (c : CodensityAssignment X) :
-+    measureToCodensity (codensityToMeasure c) (codensityToMeasure_mono c) = c := by
-+  ext x; exact codensity_roundtrip c x
-+
-+/-! ## Maxitive Measures and Support Gauge -/
-+
-+/-
-+For maxitive measures, `supportGaugeEq` implies agreement on ALL sets,
-+    not just principal lower sets. This is the key structural property.
-+-/
-+theorem maxitive_supportGaugeEq_implies_eq
-+    {μ ν : Set X → ℝ≥0∞}
-+    (hμ : IsMaxitiveSetFun μ) (hν : IsMaxitiveSetFun ν)
-+    (h : supportGaugeEq μ ν) :
-+    μ = ν := by
-+  -- By definition of maxitivity, we can write μ(A) and ν(A) as suprema over the principal lower sets of elements in A.
-+  have h_max : ∀ A : Set X, μ A = ⨆ x ∈ A, μ (irreducibleClosed X x) ∧ ν A = ⨆ x ∈ A, ν (irreducibleClosed X x) := by
-+    exact fun A => ⟨ hμ A, hν A ⟩;
-+  ext A; specialize h_max A; simp_all +decide [ supportGaugeEq ] ;
-+  exact iSup_congr fun x => iSup_congr fun hx => h x
-+
-+/-! ## Zero-Distance Characterization -/
-+
-+/-- If codensity weights agree, then `idempotentKantorovich = 0`. -/
-+theorem supportGaugeEq_implies_idempotentKantorovich_zero
-+    (μ ν : Set X → ℝ≥0∞) (h : supportGaugeEq μ ν) :
-+    idempotentKantorovich μ ν = 0 := by
-+  unfold idempotentKantorovich
-+  simp_all +decide [irreducibleClosedWeight, supportGaugeEq]
-+
-+/-
-+If `idempotentKantorovich μ ν = 0` and both set functions are monotone
-+    (so their codensity weights are monotone), then codensity weights agree.
-+    Uses the codensity weight function itself as a monotone test function.
-+-/
-+theorem idempotentKantorovich_zero_implies_supportGaugeEq
-+    (μ ν : Set X → ℝ≥0∞)
-+    (hμm : IsMonotoneSetFun μ) (hνm : IsMonotoneSetFun ν)
-+    (hμfin : ∀ x : X, irreducibleClosedWeight μ x ≠ ⊤)
-+    (hνfin : ∀ x : X, irreducibleClosedWeight ν x ≠ ⊤)
-+    (h : idempotentKantorovich μ ν = 0) :
-+    supportGaugeEq μ ν := by
-+  intro x;
-+  contrapose! h;
-+  cases lt_or_gt_of_ne h <;> simp_all +decide [ idempotentKantorovich ];
-+  · refine' ⟨ fun y => ( irreducibleClosedWeight ν y |> ENNReal.toReal ), _, _ ⟩ <;> simp_all +decide [ IsTestFunction ];
-+    · exact fun x y hxy => ENNReal.toReal_mono ( hνfin _ ) ( irreducibleClosedWeight_monotone ν hνm hxy );
-+    · refine' ne_of_gt ( lt_of_lt_of_le _ ( le_ciSup _ x ) ) <;> norm_num [ hμfin, hνfin ];
-+      assumption;
-+  · refine' ⟨ fun y => ( irreducibleClosedWeight μ y |> ENNReal.toReal ), _, _ ⟩ <;> simp_all +decide [ IsTestFunction ];
-+    · exact fun x y hxy => ENNReal.toReal_mono ( hμfin _ ) ( irreducibleClosedWeight_monotone μ hμm hxy );
-+    · refine' ne_of_gt ( lt_of_lt_of_le _ ( le_ciSup _ x ) );
-+      · exact sub_pos_of_lt ( ENNReal.toReal_strict_mono ( by aesop ) ‹_› );
-+      · exact Set.finite_range _ |> Set.Finite.bddAbove
-+
-+/-- The full zero-distance characterization for monotone set functions
-+    with finite codensity weights. -/
-+theorem idempotentKantorovich_eq_zero_iff_supportGaugeEq
-+    (μ ν : Set X → ℝ≥0∞)
-+    (hμm : IsMonotoneSetFun μ) (hνm : IsMonotoneSetFun ν)
-+    (hμfin : ∀ x : X, irreducibleClosedWeight μ x ≠ ⊤)
-+    (hνfin : ∀ x : X, irreducibleClosedWeight ν x ≠ ⊤) :
-+    idempotentKantorovich μ ν = 0 ↔ supportGaugeEq μ ν :=
-+  ⟨idempotentKantorovich_zero_implies_supportGaugeEq μ ν hμm hνm hμfin hνfin,
-+   supportGaugeEq_implies_idempotentKantorovich_zero μ ν⟩
-+
-+/-! ## The Quotient–Codensity Equivalence -/
-+
-+/-- The map from set functions to codensity weight functions. -/
-+def toCodensityFun (μ : Set X → ℝ≥0∞) : X → ℝ≥0∞ :=
-+  irreducibleClosedWeight μ
-+
-+/-- Two set functions are `supportGaugeEq` iff their codensity weight functions agree. -/
-+theorem supportGaugeEq_iff_toCodensityFun_eq (μ ν : Set X → ℝ≥0∞) :
-+    supportGaugeEq μ ν ↔ toCodensityFun μ = toCodensityFun ν := by
-+  simp [supportGaugeEq, toCodensityFun, funext_iff]
-+
-+/-
-+In a finite T₀ space, every function `X → ℝ≥0∞` arises as the codensity
-+    weight function of some set function.
-+-/
-+theorem toCodensityFun_surjective [FiniteT0SupportClass X] :
-+    Function.Surjective (toCodensityFun (X := X)) := by
-+  -- For any function $g : X \to \mathbb{R}_{\geq 0}^\infty$, we can define a set function $\mu$ such that $\mu(\downarrow x) = g(x)$ for all $x \in X$.
-+  have h_set_function : ∀ g : X → ℝ≥0∞, ∃ μ : Set X → ℝ≥0∞, ∀ x : X, μ (irreducibleClosed X x) = g x := by
-+    intro g
-+    obtain ⟨μ, hμ⟩ : ∃ μ : Set X → ℝ≥0∞, ∀ x : X, μ (irreducibleClosed X x) = g x := by
-+      have h_inj : Function.Injective (irreducibleClosed X) := irreducibleClosed_injective
-+      -- Since the irreducible closed sets are unique, we can define μ on these sets and extend it to all subsets.
-+      have h_ext : ∃ μ : Set X → ℝ≥0∞, ∀ x : X, μ (irreducibleClosed X x) = g x := by
-+        have h_unique : ∀ A : Set X, (∃ x : X, irreducibleClosed X x = A) → ∃! y : ℝ≥0∞, ∃ x : X, irreducibleClosed X x = A ∧ g x = y := by
-+          exact fun A hA => by obtain ⟨ x, rfl ⟩ := hA; exact ⟨ g x, ⟨ x, rfl, rfl ⟩, fun y hy => by obtain ⟨ z, hz₁, rfl ⟩ := hy; exact congr_arg g ( h_inj hz₁ ) ⟩ ;
-+        choose! μ hμ₁ hμ₂ using h_unique;
-+        exact ⟨ μ, fun x => hμ₂ _ ⟨ x, rfl ⟩ _ ⟨ x, rfl, rfl ⟩ ▸ rfl ⟩;
-+      exact h_ext;
-+    use μ;
-+  exact fun g => by obtain ⟨ μ, hμ ⟩ := h_set_function g; exact ⟨ μ, funext hμ ⟩ ;
-+
-+/-
-+In a finite T₀ space, the quotient of set functions by `supportGaugeEq`
-+    is equivalent to `X → ℝ≥0∞`.
-+-/
-+def quotient_equiv_functions [FiniteT0SupportClass X] :
-+    Quotient (supportGaugeSetoid X) ≃ (X → ℝ≥0∞) :=
-+  Equiv.ofBijective
-+    (Quotient.lift toCodensityFun (fun a b h =>
-+      (supportGaugeEq_iff_toCodensityFun_eq a b).mp h))
-+    ⟨fun a b h => by
-+        induction a using Quotient.ind
-+        induction b using Quotient.ind
-+        exact Quotient.sound ((supportGaugeEq_iff_toCodensityFun_eq _ _).mpr h),
-+     fun g => by
-+        obtain ⟨μ, hμ⟩ := toCodensityFun_surjective g
-+        exact ⟨Quotient.mk _ μ, hμ⟩⟩
-+
-+/-- For monotone set functions, `measureToCodensity` descends to a well-defined map. -/
-+theorem measureToCodensity_respects_supportGaugeEq
-+    {μ ν : Set X → ℝ≥0∞}
-+    (hμ : IsMonotoneSetFun μ) (hν : IsMonotoneSetFun ν)
-+    (h : supportGaugeEq μ ν) :
-+    measureToCodensity μ hμ = measureToCodensity ν hν := by
-+  ext x; exact h x
-+
-+/-- For every `CodensityAssignment`, there exists a monotone set function
-+    whose codensity weights recover it (namely `codensityToMeasure`). -/
-+theorem codensityAssignment_surjective (c : CodensityAssignment X) :
-+    ∃ (μ : Set X → ℝ≥0∞) (hμ : IsMonotoneSetFun μ),
-+      measureToCodensity μ hμ = c :=
-+  ⟨codensityToMeasure c, codensityToMeasure_mono c,
-+   measureToCodensity_codensityToMeasure c⟩
-+
-+/-! ## Pushforward and Functoriality -/
-+
-+/-
-+Pushforward of maxitive measures preserves `supportGaugeEq`:
-+    if two maxitive set functions agree on all principal lower sets,
-+    their pushforwards also agree on all principal lower sets.
-+-/
-+theorem pushforward_maxitive_preserves_supportGaugeEq
-+    {Y : Type*} [Fintype Y] [Preorder Y]
-+    (f : X → Y)
-+    {μ ν : Set X → ℝ≥0∞}
-+    (hμ : IsMaxitiveSetFun μ) (hν : IsMaxitiveSetFun ν)
-+    (h : supportGaugeEq μ ν) :
-+    supportGaugeEq (pushforward f μ) (pushforward f ν) := by
-+  intro y;
-+  have h_pushforward_lower_set : ∀ y : Y, ⨆ x ∈ f ⁻¹' {y' | y' ≤ y}, μ (irreducibleClosed X x) = ⨆ x ∈ f ⁻¹' {y' | y' ≤ y}, ν (irreducibleClosed X x) := by
-+    exact fun y => iSup_congr fun x => iSup_congr fun hx => h x;
-+  convert h_pushforward_lower_set y using 1;
-+  · convert hμ ( f ⁻¹' { y' | y' ≤ y } ) using 1;
-+  · convert hν ( f ⁻¹' { y' | y' ≤ y } ) using 1
-+
-+/-- Pushforward of codensity: given a monotone map `f : X → Y`, the induced
-+    map on codensity assignments. -/
-+def pushforwardCodensity
-+    {Y : Type*} [Fintype Y] [Preorder Y]
-+    (f : X → Y) (_hf : Monotone f)
-+    (c : CodensityAssignment X) : CodensityAssignment Y where
-+  toFun y := ⨆ x : {x : X // f x ≤ y}, c.toFun x.1
-+  monotone' := by
-+    intro y₁ y₂ hy
-+    apply iSup_le
-+    intro ⟨x, hx⟩
-+    exact le_iSup_of_le ⟨x, le_trans hx hy⟩ le_rfl
-+
-+/-
-+The codensity pushforward commutes with the round-trip: measuring the
-+    pushforward at y gives the same as the pushforwardCodensity.
-+-/
-+theorem pushforward_codensity_commutes
-+    {Y : Type*} [Fintype Y] [Preorder Y]
-+    (f : X → Y) (hf : Monotone f) (c : CodensityAssignment X) (y : Y) :
-+    irreducibleClosedWeight (pushforward f (codensityToMeasure c)) y =
-+      (pushforwardCodensity f hf c).toFun y := by
-+  refine' le_antisymm _ _;
-+  · refine' iSup₂_le fun x hx => le_iSup_of_le ⟨ x, hx ⟩ le_rfl;
-+  · refine' iSup_le _;
-+    intro ⟨ x, hx ⟩;
-+    refine' le_trans _ ( le_iSup _ x );
-+    exact le_iSup_of_le ( show x ∈ f ⁻¹' irreducibleClosed Y y from hx ) le_rfl
-+
-+/-! ## Finite Stabilization -/
-+
-+/-- In a finite space, pointwise eventual constancy implies global stabilization. -/
-+theorem finite_support_pattern_eventually_stable
-+    (u : ℕ → Set X → ℝ≥0∞) :
-+    (∀ x : X, ∃ N, ∀ m n, N ≤ m → N ≤ n →
-+      irreducibleClosedWeight (u m) x = irreducibleClosedWeight (u n) x) →
-+    ∃ (w : X → ℝ≥0∞) (N : ℕ), ∀ n, N ≤ n →
-+      ∀ x, irreducibleClosedWeight (u n) x = w x := by
-+  intros h_codensity
-+  obtain ⟨N, hN⟩ : ∃ N, ∀ x : X, ∀ m ≥ N, ∀ n ≥ N,
-+      irreducibleClosedWeight (u m) x = irreducibleClosedWeight (u n) x := by
-+    choose! N hN using id h_codensity
-+    exact ⟨Finset.univ.sup N, fun x m hm n hn =>
-+      hN x m n (le_trans (Finset.le_sup (f := N) (Finset.mem_univ x)) hm)
-+        (le_trans (Finset.le_sup (f := N) (Finset.mem_univ x)) hn)⟩
-+  exact ⟨_, N, fun n hn x => hN x n hn N le_rfl⟩
-+
-+/-! ## The Functorial Mackey Completion Theorem -/
-+
-+/-- **Functorial Idempotent Mackey Completion.**
-+    For maxitive measures on finite T₀ spaces, the codensity completion
-+    is functorial: pushforward along monotone maps preserves the
-+    codensity equivalence relation, and the completion commutes with
-+    pushforward at the level of codensity assignments. -/
-+theorem FunctorialIdempotentMackeyCompletion
-+    {Y : Type*} [Fintype Y] [Preorder Y]
-+    (f : X → Y) (hf : Monotone f) :
-+    -- Part 1: Pushforward preserves codensity equivalence for maxitive measures
-+    (∀ {μ ν : Set X → ℝ≥0∞},
-+      IsMaxitiveSetFun μ → IsMaxitiveSetFun ν →
-+      supportGaugeEq μ ν →
-+      supportGaugeEq (pushforward f μ) (pushforward f ν)) ∧
-+    -- Part 2: The completion commutes with pushforward
-+    (∀ c : CodensityAssignment X, ∀ y : Y,
-+      irreducibleClosedWeight (pushforward f (codensityToMeasure c)) y =
-+        (pushforwardCodensity f hf c).toFun y) := by
-+  exact ⟨fun hμ hν h => pushforward_maxitive_preserves_supportGaugeEq f hμ hν h,
-+         fun c y => pushforward_codensity_commutes f hf c y⟩
-+
-+end+/-
+Copyright (c) 2025. All rights reserved.
+Released under Apache 2.0 license as described in the file LICENSE.
+-/
+import Bridges.MackeyCompletion.Defs
+
+/-!
+# Theorems on Functorial Mackey Completion
+
+This file contains the main theorems establishing the functorial Mackey completion
+for maxitive measures on finite T₀ spaces via codensity assignments.
+
+## Main results
+
+* `codensity_roundtrip` — `measureToCodensity ∘ codensityToMeasure = id`
+* `codensityToMeasure_maxitive` — `codensityToMeasure` produces maxitive measures
+* `maxitive_supportGaugeEq_implies_eq` — maxitive measures agreeing on codensities are equal
+* `supportGaugeEq_implies_idempotentKantorovich_zero` — the easy direction
+* `idempotentKantorovich_zero_implies_supportGaugeEq` — the hard direction
+* `toCodensityFun_surjective` — surjectivity onto `X → ℝ≥0∞` (requires T₀)
+* `quotient_equiv_functions` — quotient ≃ `X → ℝ≥0∞`
+* `pushforward_maxitive_preserves_supportGaugeEq` — functoriality for maxitive measures
+* `finite_support_pattern_eventually_stable` — finite stabilization
+* `FunctorialIdempotentMackeyCompletion` — the main theorem
+-/
+
+noncomputable section
+
+open scoped ENNReal
+open Set
+
+variable {X : Type*} [Fintype X] [Preorder X]
+
+/-! ## Basic Properties of Irreducible Closed Sets -/
+
+/-- Principal lower sets are monotone: `x ≤ y → ↓x ⊆ ↓y`. -/
+theorem irreducibleClosed_monotone :
+    Monotone (irreducibleClosed X) :=
+  fun _ _ hxy _ hz => le_trans hz hxy
+
+/-- In a finite T₀ space, principal lower sets are injective. -/
+theorem irreducibleClosed_injective [FiniteT0SupportClass X] :
+    Function.Injective (irreducibleClosed X) := by
+  intro x y h
+  apply FiniteT0SupportClass.antisymm_of_closure_eq
+  intro z
+  have := Set.ext_iff.mp h z
+  simp only [irreducibleClosed, mem_setOf_eq] at this
+  exact this
+
+/-- Codensity weights are monotone for monotone set functions. -/
+theorem irreducibleClosedWeight_monotone
+    (μ : Set X → ℝ≥0∞) (hμ : IsMonotoneSetFun μ) :
+    Monotone (irreducibleClosedWeight μ) :=
+  fun _ _ hxy => hμ (irreducibleClosed_monotone hxy)
+
+/-! ## Codensity To Measure Properties -/
+
+/-- The set function constructed from a codensity assignment is monotone. -/
+theorem codensityToMeasure_mono (c : CodensityAssignment X) :
+    IsMonotoneSetFun (codensityToMeasure c) := by
+  intro A B hAB
+  simp only [codensityToMeasure]
+  exact iSup₂_mono' (fun x hx => ⟨x, hAB hx, le_rfl⟩)
+
+/-
+`codensityToMeasure` produces maxitive set functions.
+-/
+theorem codensityToMeasure_maxitive (c : CodensityAssignment X) :
+    IsMaxitiveSetFun (codensityToMeasure c) := by
+  intro A;
+  refine' iSup_congr fun x => iSup_congr fun hx => le_antisymm _ _;
+  · exact le_iSup₂_of_le x ( by simp +decide [ irreducibleClosed ] ) le_rfl;
+  · exact iSup₂_le fun y hy => c.monotone hy
+
+/-! ## The Codensity Round-Trip -/
+
+/-- The key round-trip identity: `⨆ y ≤ x, c y = c x` by monotonicity. -/
+theorem codensity_roundtrip (c : CodensityAssignment X) (x : X) :
+    irreducibleClosedWeight (codensityToMeasure c) x = c.toFun x := by
+  refine le_antisymm (iSup₂_le fun y hy => ?_) ?_
+  · exact c.monotone' hy
+  · exact le_iSup₂_of_le x le_rfl le_rfl
+
+/-- `measureToCodensity ∘ codensityToMeasure = id` on codensity assignments. -/
+theorem measureToCodensity_codensityToMeasure (c : CodensityAssignment X) :
+    measureToCodensity (codensityToMeasure c) (codensityToMeasure_mono c) = c := by
+  ext x; exact codensity_roundtrip c x
+
+/-! ## Maxitive Measures and Support Gauge -/
+
+/-
+For maxitive measures, `supportGaugeEq` implies agreement on ALL sets,
+    not just principal lower sets. This is the key structural property.
+-/
+theorem maxitive_supportGaugeEq_implies_eq
+    {μ ν : Set X → ℝ≥0∞}
+    (hμ : IsMaxitiveSetFun μ) (hν : IsMaxitiveSetFun ν)
+    (h : supportGaugeEq μ ν) :
+    μ = ν := by
+  -- By definition of maxitivity, we can write μ(A) and ν(A) as suprema over the principal lower sets of elements in A.
+  have h_max : ∀ A : Set X, μ A = ⨆ x ∈ A, μ (irreducibleClosed X x) ∧ ν A = ⨆ x ∈ A, ν (irreducibleClosed X x) := by
+    exact fun A => ⟨ hμ A, hν A ⟩;
+  ext A; specialize h_max A; simp_all +decide [ supportGaugeEq ] ;
+  exact iSup_congr fun x => iSup_congr fun hx => h x
+
+/-! ## Zero-Distance Characterization -/
+
+/-- If codensity weights agree, then `idempotentKantorovich = 0`. -/
+theorem supportGaugeEq_implies_idempotentKantorovich_zero
+    (μ ν : Set X → ℝ≥0∞) (h : supportGaugeEq μ ν) :
+    idempotentKantorovich μ ν = 0 := by
+  unfold idempotentKantorovich
+  simp_all +decide [irreducibleClosedWeight, supportGaugeEq]
+
+/-
+If `idempotentKantorovich μ ν = 0` and both set functions are monotone
+    (so their codensity weights are monotone), then codensity weights agree.
+    Uses the codensity weight function itself as a monotone test function.
+-/
+theorem idempotentKantorovich_zero_implies_supportGaugeEq
+    (μ ν : Set X → ℝ≥0∞)
+    (hμm : IsMonotoneSetFun μ) (hνm : IsMonotoneSetFun ν)
+    (hμfin : ∀ x : X, irreducibleClosedWeight μ x ≠ ⊤)
+    (hνfin : ∀ x : X, irreducibleClosedWeight ν x ≠ ⊤)
+    (h : idempotentKantorovich μ ν = 0) :
+    supportGaugeEq μ ν := by
+  intro x;
+  contrapose! h;
+  cases lt_or_gt_of_ne h <;> simp_all +decide [ idempotentKantorovich ];
+  · refine' ⟨ fun y => ( irreducibleClosedWeight ν y |> ENNReal.toReal ), _, _ ⟩ <;> simp_all +decide [ IsTestFunction ];
+    · exact fun x y hxy => ENNReal.toReal_mono ( hνfin _ ) ( irreducibleClosedWeight_monotone ν hνm hxy );
+    · refine' ne_of_gt ( lt_of_lt_of_le _ ( le_ciSup _ x ) ) <;> norm_num [ hμfin, hνfin ];
+      assumption;
+  · refine' ⟨ fun y => ( irreducibleClosedWeight μ y |> ENNReal.toReal ), _, _ ⟩ <;> simp_all +decide [ IsTestFunction ];
+    · exact fun x y hxy => ENNReal.toReal_mono ( hμfin _ ) ( irreducibleClosedWeight_monotone μ hμm hxy );
+    · refine' ne_of_gt ( lt_of_lt_of_le _ ( le_ciSup _ x ) );
+      · exact sub_pos_of_lt ( ENNReal.toReal_strict_mono ( by aesop ) ‹_› );
+      · exact Set.finite_range _ |> Set.Finite.bddAbove
+
+/-- The full zero-distance characterization for monotone set functions
+    with finite codensity weights. -/
+theorem idempotentKantorovich_eq_zero_iff_supportGaugeEq
+    (μ ν : Set X → ℝ≥0∞)
+    (hμm : IsMonotoneSetFun μ) (hνm : IsMonotoneSetFun ν)
+    (hμfin : ∀ x : X, irreducibleClosedWeight μ x ≠ ⊤)
+    (hνfin : ∀ x : X, irreducibleClosedWeight ν x ≠ ⊤) :
+    idempotentKantorovich μ ν = 0 ↔ supportGaugeEq μ ν :=
+  ⟨idempotentKantorovich_zero_implies_supportGaugeEq μ ν hμm hνm hμfin hνfin,
+   supportGaugeEq_implies_idempotentKantorovich_zero μ ν⟩
+
+/-! ## The Quotient–Codensity Equivalence -/
+
+/-- The map from set functions to codensity weight functions. -/
+def toCodensityFun (μ : Set X → ℝ≥0∞) : X → ℝ≥0∞ :=
+  irreducibleClosedWeight μ
+
+/-- Two set functions are `supportGaugeEq` iff their codensity weight functions agree. -/
+theorem supportGaugeEq_iff_toCodensityFun_eq (μ ν : Set X → ℝ≥0∞) :
+    supportGaugeEq μ ν ↔ toCodensityFun μ = toCodensityFun ν := by
+  simp [supportGaugeEq, toCodensityFun, funext_iff]
+
+/-
+In a finite T₀ space, every function `X → ℝ≥0∞` arises as the codensity
+    weight function of some set function.
+-/
+theorem toCodensityFun_surjective [FiniteT0SupportClass X] :
+    Function.Surjective (toCodensityFun (X := X)) := by
+  -- For any function $g : X \to \mathbb{R}_{\geq 0}^\infty$, we can define a set function $\mu$ such that $\mu(\downarrow x) = g(x)$ for all $x \in X$.
+  have h_set_function : ∀ g : X → ℝ≥0∞, ∃ μ : Set X → ℝ≥0∞, ∀ x : X, μ (irreducibleClosed X x) = g x := by
+    intro g
+    obtain ⟨μ, hμ⟩ : ∃ μ : Set X → ℝ≥0∞, ∀ x : X, μ (irreducibleClosed X x) = g x := by
+      have h_inj : Function.Injective (irreducibleClosed X) := irreducibleClosed_injective
+      -- Since the irreducible closed sets are unique, we can define μ on these sets and extend it to all subsets.
+      have h_ext : ∃ μ : Set X → ℝ≥0∞, ∀ x : X, μ (irreducibleClosed X x) = g x := by
+        have h_unique : ∀ A : Set X, (∃ x : X, irreducibleClosed X x = A) → ∃! y : ℝ≥0∞, ∃ x : X, irreducibleClosed X x = A ∧ g x = y := by
+          exact fun A hA => by obtain ⟨ x, rfl ⟩ := hA; exact ⟨ g x, ⟨ x, rfl, rfl ⟩, fun y hy => by obtain ⟨ z, hz₁, rfl ⟩ := hy; exact congr_arg g ( h_inj hz₁ ) ⟩ ;
+        choose! μ hμ₁ hμ₂ using h_unique;
+        exact ⟨ μ, fun x => hμ₂ _ ⟨ x, rfl ⟩ _ ⟨ x, rfl, rfl ⟩ ▸ rfl ⟩;
+      exact h_ext;
+    use μ;
+  exact fun g => by obtain ⟨ μ, hμ ⟩ := h_set_function g; exact ⟨ μ, funext hμ ⟩ ;
+
+/-
+In a finite T₀ space, the quotient of set functions by `supportGaugeEq`
+    is equivalent to `X → ℝ≥0∞`.
+-/
+def quotient_equiv_functions [FiniteT0SupportClass X] :
+    Quotient (supportGaugeSetoid X) ≃ (X → ℝ≥0∞) :=
+  Equiv.ofBijective
+    (Quotient.lift toCodensityFun (fun a b h =>
+      (supportGaugeEq_iff_toCodensityFun_eq a b).mp h))
+    ⟨fun a b h => by
+        induction a using Quotient.ind
+        induction b using Quotient.ind
+        exact Quotient.sound ((supportGaugeEq_iff_toCodensityFun_eq _ _).mpr h),
+     fun g => by
+        obtain ⟨μ, hμ⟩ := toCodensityFun_surjective g
+        exact ⟨Quotient.mk _ μ, hμ⟩⟩
+
+/-- For monotone set functions, `measureToCodensity` descends to a well-defined map. -/
+theorem measureToCodensity_respects_supportGaugeEq
+    {μ ν : Set X → ℝ≥0∞}
+    (hμ : IsMonotoneSetFun μ) (hν : IsMonotoneSetFun ν)
+    (h : supportGaugeEq μ ν) :
+    measureToCodensity μ hμ = measureToCodensity ν hν := by
+  ext x; exact h x
+
+/-- For every `CodensityAssignment`, there exists a monotone set function
+    whose codensity weights recover it (namely `codensityToMeasure`). -/
+theorem codensityAssignment_surjective (c : CodensityAssignment X) :
+    ∃ (μ : Set X → ℝ≥0∞) (hμ : IsMonotoneSetFun μ),
+      measureToCodensity μ hμ = c :=
+  ⟨codensityToMeasure c, codensityToMeasure_mono c,
+   measureToCodensity_codensityToMeasure c⟩
+
+/-! ## Pushforward and Functoriality -/
+
+/-
+Pushforward of maxitive measures preserves `supportGaugeEq`:
+    if two maxitive set functions agree on all principal lower sets,
+    their pushforwards also agree on all principal lower sets.
+-/
+theorem pushforward_maxitive_preserves_supportGaugeEq
+    {Y : Type*} [Fintype Y] [Preorder Y]
+    (f : X → Y)
+    {μ ν : Set X → ℝ≥0∞}
+    (hμ : IsMaxitiveSetFun μ) (hν : IsMaxitiveSetFun ν)
+    (h : supportGaugeEq μ ν) :
+    supportGaugeEq (pushforward f μ) (pushforward f ν) := by
+  intro y;
+  have h_pushforward_lower_set : ∀ y : Y, ⨆ x ∈ f ⁻¹' {y' | y' ≤ y}, μ (irreducibleClosed X x) = ⨆ x ∈ f ⁻¹' {y' | y' ≤ y}, ν (irreducibleClosed X x) := by
+    exact fun y => iSup_congr fun x => iSup_congr fun hx => h x;
+  convert h_pushforward_lower_set y using 1;
+  · convert hμ ( f ⁻¹' { y' | y' ≤ y } ) using 1;
+  · convert hν ( f ⁻¹' { y' | y' ≤ y } ) using 1
+
+/-- Pushforward of codensity: given a monotone map `f : X → Y`, the induced
+    map on codensity assignments. -/
+def pushforwardCodensity
+    {Y : Type*} [Fintype Y] [Preorder Y]
+    (f : X → Y) (_hf : Monotone f)
+    (c : CodensityAssignment X) : CodensityAssignment Y where
+  toFun y := ⨆ x : {x : X // f x ≤ y}, c.toFun x.1
+  monotone' := by
+    intro y₁ y₂ hy
+    apply iSup_le
+    intro ⟨x, hx⟩
+    exact le_iSup_of_le ⟨x, le_trans hx hy⟩ le_rfl
+
+/-
+The codensity pushforward commutes with the round-trip: measuring the
+    pushforward at y gives the same as the pushforwardCodensity.
+-/
+theorem pushforward_codensity_commutes
+    {Y : Type*} [Fintype Y] [Preorder Y]
+    (f : X → Y) (hf : Monotone f) (c : CodensityAssignment X) (y : Y) :
+    irreducibleClosedWeight (pushforward f (codensityToMeasure c)) y =
+      (pushforwardCodensity f hf c).toFun y := by
+  refine' le_antisymm _ _;
+  · refine' iSup₂_le fun x hx => le_iSup_of_le ⟨ x, hx ⟩ le_rfl;
+  · refine' iSup_le _;
+    intro ⟨ x, hx ⟩;
+    refine' le_trans _ ( le_iSup _ x );
+    exact le_iSup_of_le ( show x ∈ f ⁻¹' irreducibleClosed Y y from hx ) le_rfl
+
+/-! ## Finite Stabilization -/
+
+/-- In a finite space, pointwise eventual constancy implies global stabilization. -/
+theorem finite_support_pattern_eventually_stable
+    (u : ℕ → Set X → ℝ≥0∞) :
+    (∀ x : X, ∃ N, ∀ m n, N ≤ m → N ≤ n →
+      irreducibleClosedWeight (u m) x = irreducibleClosedWeight (u n) x) →
+    ∃ (w : X → ℝ≥0∞) (N : ℕ), ∀ n, N ≤ n →
+      ∀ x, irreducibleClosedWeight (u n) x = w x := by
+  intros h_codensity
+  obtain ⟨N, hN⟩ : ∃ N, ∀ x : X, ∀ m ≥ N, ∀ n ≥ N,
+      irreducibleClosedWeight (u m) x = irreducibleClosedWeight (u n) x := by
+    choose! N hN using id h_codensity
+    exact ⟨Finset.univ.sup N, fun x m hm n hn =>
+      hN x m n (le_trans (Finset.le_sup (f := N) (Finset.mem_univ x)) hm)
+        (le_trans (Finset.le_sup (f := N) (Finset.mem_univ x)) hn)⟩
+  exact ⟨_, N, fun n hn x => hN x n hn N le_rfl⟩
+
+/-! ## The Functorial Mackey Completion Theorem -/
+
+/-- **Functorial Idempotent Mackey Completion.**
+    For maxitive measures on finite T₀ spaces, the codensity completion
+    is functorial: pushforward along monotone maps preserves the
+    codensity equivalence relation, and the completion commutes with
+    pushforward at the level of codensity assignments. -/
+theorem FunctorialIdempotentMackeyCompletion
+    {Y : Type*} [Fintype Y] [Preorder Y]
+    (f : X → Y) (hf : Monotone f) :
+    -- Part 1: Pushforward preserves codensity equivalence for maxitive measures
+    (∀ {μ ν : Set X → ℝ≥0∞},
+      IsMaxitiveSetFun μ → IsMaxitiveSetFun ν →
+      supportGaugeEq μ ν →
+      supportGaugeEq (pushforward f μ) (pushforward f ν)) ∧
+    -- Part 2: The completion commutes with pushforward
+    (∀ c : CodensityAssignment X, ∀ y : Y,
+      irreducibleClosedWeight (pushforward f (codensityToMeasure c)) y =
+        (pushforwardCodensity f hf c).toFun y) := by
+  exact ⟨fun hμ hν h => pushforward_maxitive_preserves_supportGaugeEq f hμ hν h,
+         fun c y => pushforward_codensity_commutes f hf c y⟩
+
+end