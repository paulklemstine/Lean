/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# EML Stone–Weierstrass with Continuous Scalar Functional Calculus

This file establishes a **continuous scalar functional calculus** for sets of
continuous functions on compact Hausdorff spaces, and uses it together with the
Stone–Weierstrass theorem to derive uniform density.

## Main results

### Functional calculus

* `eml_comp_mem_closure_of_mem`: If `A ⊆ C(X, ℝ)` is closed under constants,
  addition, and multiplication, and `f ∈ A`, then for any
  continuous `φ : C(Set.Icc a b, ℝ)` with `f(X) ⊆ [a,b]`, the composition
  `φ ∘ f` lies in `closure A`.

* `eml_comp_norm_mem_closure_of_mem`: The same with the canonical `[-‖f‖, ‖f‖]` bounds.

### Stone–Weierstrass density

* `eml_stoneWeierstrass_of_lattice_mul_functionalCalculus`:
  If `A` contains constants, is closed under `+, ·, max, min`, and separates points,
  then `closure A = Set.univ`.

* `eml_uniformClosure_eq_top_of_separatesPoints_lattice_mul`:
  The same result stated as `Dense A`.

### Helper lemmas

* `polynomial_eval_mem_of_mem`: Polynomial evaluation at `f ∈ A` stays in `A`.
* `neg_mem_of_const_mul`: Negation is derivable from constants and multiplication.
* `abs_mem_closure_of_mem`: `|f| ∈ closure A` for `f ∈ A`.

## Proof strategy

The functional calculus `φ ∘ f ∈ closure A` is proved by:
1. Showing every polynomial in `f` lies in `A` (by induction on polynomial degree).
2. Invoking the Weierstrass approximation theorem on `[a,b]` to approximate `φ`
   uniformly by polynomials.
3. Composing with `f` and taking the limit.

The density result then follows by combining the functional calculus with the
classical Stone–Weierstrass theorem for subalgebras.

## Significance for EML

This theorem upgrades EML approximation from "closed under algebraic and lattice primitives"
to a genuine **continuous functional calculus principle**: any continuous scalar nonlinearity
applied nodewise to a function in the class produces a function in the uniform closure.
This is the missing bridge between existing max/product/pullback closure results and
modern neural-network universality.
-/

noncomputable section

open ContinuousMap Set Topology Polynomial

variable {X : Type*} [TopologicalSpace X] [CompactSpace X]

/-! ## Building subalgebra structure from set-level hypotheses -/

/-- From closure under constants, addition, and multiplication, build a `Subalgebra ℝ C(X, ℝ)`. -/
def EML.setToSubalgebra
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A) :
    Subalgebra ℝ C(X, ℝ) where
  carrier := A
  mul_mem' ha hb := hmul ha hb
  add_mem' ha hb := hadd ha hb
  zero_mem' := by simpa using hconst 0
  one_mem' := by simpa using hconst 1
  algebraMap_mem' r := by
    have : algebraMap ℝ C(X, ℝ) r = ContinuousMap.const X r := by
      ext x; simp [Algebra.algebraMap_eq_smul_one]
    rw [this]; exact hconst r

@[simp]
lemma EML.setToSubalgebra_coe
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A) :
    ↑(EML.setToSubalgebra A hconst hadd hmul) = A := rfl

/-! ## Derived closure properties -/

/-- Negation is derivable from constants and multiplication: `-f = (-1) * f`. -/
theorem neg_mem_of_const_mul
    {A : Set C(X, ℝ)}
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    {f : C(X, ℝ)} (hf : f ∈ A) : -f ∈ A := by
  have : -f = ContinuousMap.const X (-1) * f := by ext x; simp
  rw [this]; exact hmul (hconst (-1)) hf

/-- Subtraction is derivable from addition, constants, and multiplication. -/
theorem sub_mem_of_add_const_mul
    {A : Set C(X, ℝ)}
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    {f g : C(X, ℝ)} (hf : f ∈ A) (hg : g ∈ A) : f - g ∈ A := by
  have : f - g = f + -g := sub_eq_add_neg f g
  rw [this]; exact hadd hf (neg_mem_of_const_mul hconst hmul hg)

/-- **Polynomial evaluation at `f ∈ A` stays in `A`.** -/
theorem polynomial_eval_mem_of_mem
    {A : Set C(X, ℝ)}
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    {f : C(X, ℝ)} (hf : f ∈ A) (p : Polynomial ℝ) :
    Polynomial.aeval f p ∈ A := by
  let S := EML.setToSubalgebra A hconst hadd hmul
  have hmem : f ∈ (S : Set C(X, ℝ)) := hf
  have key : (Polynomial.aeval (⟨f, hmem⟩ : S) p : C(X, ℝ)) = Polynomial.aeval f p :=
    Polynomial.aeval_subalgebra_coe p S ⟨f, hmem⟩
  rw [← key]
  exact SetLike.coe_mem (Polynomial.aeval (⟨f, hmem⟩ : S) p)

/-! ## The functional calculus: continuous postcomposition is in the closure -/

/-- Helper: construct a continuous map `X → Icc a b` from `f : C(X, ℝ)` with bounds. -/
def ContinuousMap.toIcc (f : C(X, ℝ)) {a b : ℝ}
    (hfa : ∀ x, a ≤ f x) (hfb : ∀ x, f x ≤ b) : C(X, Icc a b) :=
  ⟨fun x => ⟨f x, hfa x, hfb x⟩,
    Continuous.subtype_mk f.continuous (fun x => ⟨hfa x, hfb x⟩)⟩

/-
**Continuous functional calculus (interval version).**
If `f ∈ A` has values in `[a, b]`, then for any `φ : C(Icc a b, ℝ)`,
the composition `φ ∘ f` lies in `closure A`.
-/
theorem eml_comp_mem_closure_of_mem
    {A : Set C(X, ℝ)}
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    {f : C(X, ℝ)} (hf : f ∈ A)
    {a b : ℝ}
    (hfa : ∀ x, a ≤ f x) (hfb : ∀ x, f x ≤ b)
    (φ : C(Icc a b, ℝ)) :
    φ.comp (f.toIcc hfa hfb) ∈ closure A := by
  -- By the Weierstrass approximation theorem, φ is the limit of polynomial functions on [a, b].
  obtain ⟨u, hu⟩ : ∃ u : ℕ → Polynomial ( ℝ ), Filter.Tendsto (fun n => (u n).toContinuousMapOn (Set.Icc a b)) Filter.atTop (nhds φ) := by
    have h_weierstrass : φ ∈ (polynomialFunctions (Set.Icc a b)).topologicalClosure := by
      exact continuousMap_mem_polynomialFunctions_closure a b φ
    have := mem_closure_iff_seq_limit.mp h_weierstrass;
    rcases this with ⟨ u, hu, hu' ⟩ ; choose p hp using hu; use fun n => p n; aesop;
  -- By the continuity of `compRightContinuousMap`, we have that `compRightContinuousMap ℝ (f.toIcc hfa hfb)` is continuous.
  have h_cont : Continuous (compRightContinuousMap ℝ (f.toIcc hfa hfb)) := by
    fun_prop;
  -- By the continuity of `compRightContinuousMap`, we have that `compRightContinuousMap ℝ (f.toIcc hfa hfb)` maps the closure of polynomial functions to the closure of their precompositions.
  have h_map_closure : ∀ n, (compRightContinuousMap ℝ (f.toIcc hfa hfb)) ((u n).toContinuousMapOn (Set.Icc a b)) ∈ A := by
    intro n
    have h_poly : (u n).toContinuousMapOn (Set.Icc a b) = (u n).toContinuousMapOn (Set.Icc a b) := by
      rfl
    have h_eval : (compRightContinuousMap ℝ (f.toIcc hfa hfb)) ((u n).toContinuousMapOn (Set.Icc a b)) = Polynomial.aeval f (u n) := by
      ext x; simp [compRightContinuousMap];
      rfl;
    exact h_eval.symm ▸ polynomial_eval_mem_of_mem hconst hadd hmul hf _;
  exact mem_closure_of_tendsto ( h_cont.continuousAt.tendsto.comp hu ) ( Filter.Eventually.of_forall h_map_closure )

/-
**Continuous functional calculus (norm-bound version).**
For `f ∈ A`, any `φ : C(Icc (-‖f‖) ‖f‖, ℝ)` composed with `f` is in `closure A`.
-/
theorem eml_comp_norm_mem_closure_of_mem
    {A : Set C(X, ℝ)}
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    {f : C(X, ℝ)} (hf : f ∈ A)
    (φ : C(Icc (-‖f‖) ‖f‖, ℝ)) :
    φ.comp (ContinuousMap.attachBound f) ∈ closure A := by
  -- Apply the lemma that states the composition of a continuous function with `f` is in the closure of `A`.
  have := comp_attachBound_mem_closure (EML.setToSubalgebra A hconst hadd hmul) ⟨f, hf⟩ φ;
  aesop;

/-! ## Absolute value and lattice operations in the closure -/

/-
`|f| ∈ closure A` for `f ∈ A`, derived from the functional calculus.
-/
theorem abs_mem_closure_of_mem
    {A : Set C(X, ℝ)}
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    {f : C(X, ℝ)} (hf : f ∈ A) : |f| ∈ closure A := by
  have := @abs_mem_subalgebra_closure;
  convert this ( EML.setToSubalgebra A hconst hadd hmul ) ⟨ f, hf ⟩

/-
`f ⊔ g ∈ closure A` for `f, g ∈ closure A` when `A` is closed under
constants, addition, and multiplication.
-/
theorem sup_mem_closure_of_mem_closure
    {A : Set C(X, ℝ)}
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    {f g : C(X, ℝ)} (hf : f ∈ closure A) (hg : g ∈ closure A) :
    (f ⊔ g : C(X, ℝ)) ∈ closure A := by
  rw [ mem_closure_iff_seq_limit ] at hf hg;
  obtain ⟨ x, hx, hx' ⟩ := hf
  obtain ⟨ y, hy, hy' ⟩ := hg
  have h_sup : Filter.Tendsto (fun n => x n ⊔ y n) Filter.atTop (𝓝 (f ⊔ g)) := by
    rw [ tendsto_iff_norm_sub_tendsto_zero ] at *;
    refine' squeeze_zero ( fun _ => norm_nonneg _ ) ( fun n => _ ) ( by simpa using hx'.add hy' );
    rw [ ContinuousMap.norm_le ];
    · intro x_1; norm_num; cases le_total ( x n x_1 ) ( y n x_1 ) <;> cases le_total ( f x_1 ) ( g x_1 ) <;> simp +decide [ * ] ;
      · exact le_trans ( by simp ) ( add_le_add ( ContinuousMap.norm_coe_le_norm ( x n - f ) x_1 ) ( ContinuousMap.norm_coe_le_norm ( y n - g ) x_1 ) );
      · rw [ abs_le ];
        constructor <;> linarith [ abs_le.mp ( show |(x n) x_1 - f x_1| ≤ ‖x n - f‖ from ContinuousMap.norm_coe_le_norm ( x n - f ) x_1 ), abs_le.mp ( show |(y n) x_1 - g x_1| ≤ ‖y n - g‖ from ContinuousMap.norm_coe_le_norm ( y n - g ) x_1 ) ];
      · rw [ abs_le ];
        constructor <;> linarith [ abs_le.mp ( show |(x n) x_1 - f x_1| ≤ ‖x n - f‖ from ContinuousMap.norm_coe_le_norm ( x n - f ) x_1 ), abs_le.mp ( show |(y n) x_1 - g x_1| ≤ ‖y n - g‖ from ContinuousMap.norm_coe_le_norm ( y n - g ) x_1 ) ];
      · exact le_trans ( by simpa using ContinuousMap.norm_coe_le_norm ( x n - f ) x_1 ) ( le_add_of_nonneg_right ( norm_nonneg _ ) );
    · positivity;
  have h_sup_in_A : ∀ n, x n ⊔ y n ∈ closure A := by
    intro n
    have h_abs : |x n - y n| ∈ closure A := by
      apply_rules [ abs_mem_closure_of_mem ];
      convert sub_mem_of_add_const_mul hconst hadd hmul ( hx n ) ( hy n ) using 1;
    have h_sup_in_A : (1 / 2 : ℝ) • (x n + y n + |x n - y n|) ∈ closure A := by
      have h_sup_in_A : ∀ c : ℝ, ∀ f ∈ closure A, c • f ∈ closure A := by
        intro c f hf
        have h_sup_in_A : ∀ f ∈ A, c • f ∈ A := by
          intro f hf
          have h_sup_in_A : (ContinuousMap.const X c) * f ∈ A := by
            exact hmul ( hconst c ) hf;
          convert h_sup_in_A using 1;
        rw [ mem_closure_iff_seq_limit ] at hf ⊢;
        exact ⟨ fun n => c • hf.choose n, fun n => h_sup_in_A _ ( hf.choose_spec.1 n ), by simpa using hf.choose_spec.2.const_smul c ⟩;
      apply h_sup_in_A;
      have h_sup_in_A : ∀ f g : C(X, ℝ), f ∈ closure A → g ∈ closure A → f + g ∈ closure A := by
        intro f g hf hg;
        rw [ mem_closure_iff_seq_limit ] at hf hg ⊢;
        exact ⟨ fun n => hf.choose n + hg.choose n, fun n => hadd ( hf.choose_spec.1 n ) ( hg.choose_spec.1 n ), Filter.Tendsto.add hf.choose_spec.2 hg.choose_spec.2 ⟩;
      exact h_sup_in_A _ _ ( h_sup_in_A _ _ ( subset_closure ( hx n ) ) ( subset_closure ( hy n ) ) ) h_abs;
    convert h_sup_in_A using 1;
    ext; simp [max_def];
    split_ifs <;> cases abs_cases ( ( x n ) ‹_› - ( y n ) ‹_› ) <;> linarith;
  exact closure_minimal ( Set.range_subset_iff.mpr h_sup_in_A ) isClosed_closure ( mem_closure_of_tendsto h_sup ( by simp +decide ) )

/-
`f ⊓ g ∈ closure A` for `f, g ∈ closure A`.
-/
theorem inf_mem_closure_of_mem_closure
    {A : Set C(X, ℝ)}
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    {f g : C(X, ℝ)} (hf : f ∈ closure A) (hg : g ∈ closure A) :
    (f ⊓ g : C(X, ℝ)) ∈ closure A := by
  have h_inf : ∀ f g : C(X, ℝ), f ∈ closure A → g ∈ closure A → f ⊔ g ∈ closure A := by
    intro f g hf hg;
    convert sup_mem_closure_of_mem_closure hconst hadd hmul hf hg using 1;
  have h_neg : ∀ f : C(X, ℝ), f ∈ closure A → -f ∈ closure A := by
    intro f hf
    have h_neg : ∀ f : C(X, ℝ), f ∈ A → -f ∈ A := by
      exact fun f hf => neg_mem_of_const_mul hconst hmul hf;
    rw [ mem_closure_iff_seq_limit ] at hf ⊢;
    exact ⟨ fun n => -hf.choose n, fun n => h_neg _ ( hf.choose_spec.1 n ), by simpa using hf.choose_spec.2.neg ⟩;
  convert h_neg _ ( h_inf _ _ ( h_neg _ hf ) ( h_neg _ hg ) ) using 1 ; ext ; simp +decide;
  rw [ min_def, max_def ] ; split_ifs <;> linarith

/-! ## Main Stone–Weierstrass density results -/

section MainResults

/-- **EML Stone–Weierstrass with functional calculus (closure = univ).**
If `A ⊆ C(X, ℝ)` contains constants, is closed under `+, ·, max, min`,
and separates points, then `closure A = Set.univ`. -/
theorem eml_stoneWeierstrass_of_lattice_mul_functionalCalculus
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, (ContinuousMap.const X c) ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    (_hmax : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → (f ⊔ g : C(X, ℝ)) ∈ A)
    (_hmin : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → (f ⊓ g : C(X, ℝ)) ∈ A)
    (hsep : ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y) :
    closure A = (Set.univ : Set C(X, ℝ)) := by
  -- Build the subalgebra `S := EML.setToSubalgebra A hconst hadd hmul`.
  set S : Subalgebra ℝ C(X, ℝ) := EML.setToSubalgebra A hconst hadd hmul;
  convert congr_arg ( fun s : Subalgebra ℝ C(X, ℝ) => ( s : Set C(X, ℝ) ) ) ( ContinuousMap.subalgebra_topologicalClosure_eq_top_of_separatesPoints S _ );
  intro x y hxy;
  obtain ⟨ f, hfA, hfx ⟩ := hsep x y hxy; use f; aesop;

/-- **EML Stone–Weierstrass with functional calculus (density version).**

Note: The hypothesis `hadd` (closure under addition) is needed to form a subalgebra
and derive two-point interpolation for the classical Stone–Weierstrass argument.
Addition cannot be derived from `const`, `mul`, `max`, `min` alone at the set level. -/
theorem eml_uniformClosure_eq_top_of_separatesPoints_lattice_mul
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, (ContinuousMap.const X c) ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    (hmax : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → (f ⊔ g : C(X, ℝ)) ∈ A)
    (hmin : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → (f ⊓ g : C(X, ℝ)) ∈ A)
    (hsep : ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y) :
    Dense (A : Set C(X, ℝ)) := by
  rw [dense_iff_closure_eq]
  exact eml_stoneWeierstrass_of_lattice_mul_functionalCalculus A hconst hadd hmul hmax hmin hsep

/-- **EML Stone–Weierstrass (ε-approximation version).** -/
theorem eml_exists_approx_of_separatesPoints_lattice_mul
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, (ContinuousMap.const X c) ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    (hmax : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → (f ⊔ g : C(X, ℝ)) ∈ A)
    (hmin : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → (f ⊓ g : C(X, ℝ)) ∈ A)
    (hsep : ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y)
    (f : C(X, ℝ)) (ε : ℝ) (hε : 0 < ε) :
    ∃ g ∈ A, ‖f - g‖ < ε := by
  have h_closure : closure A = Set.univ :=
    eml_stoneWeierstrass_of_lattice_mul_functionalCalculus A hconst hadd hmul hmax hmin hsep
  have := Metric.mem_closure_iff.mp ( h_closure.symm ▸ Set.mem_univ f ) ε hε;
  simpa only [ dist_eq_norm ] using this

end MainResults

end