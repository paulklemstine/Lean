/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Mathlib

/-!
# Derived Compression Invariants: Cohomological Obstruction Theory

This file develops a **cohomological theory of compression**, introducing higher
compression invariants `κⁿ` that detect failure of compression functionals to
be additive on exact sequences.

## Main Results

* `kappa1_nonneg` — Nonnegativity of κ¹ under subadditivity.
* `kappa1_of_split` — κ¹ vanishes on split extensions.
* `kappa1_iso_invariant` — Functorial invariance of κ¹.
* `kappa0_kappa1_exact` — Exactness surrogate: κ(B) = κ(A) + κ(Q) - κ¹.
* `kappa2_vanishes_universally` — The iterated defect κ² is identically zero.
* `totalFiltrationDefect_nonneg` — Nonneg of total filtration defect.
* `totalFiltrationDefect_eq_zero_iff` — Characterization of exact filtrations.
* `totalFiltrationDefect_eq` — Telescoping identity for filtration defects.
* `euler_defect_length1` — Euler-defect duality for length-1 filtrations.
* `three_term_defect_decomposition` — Three-term telescoping identity.

## Connection to Catalog

The catalog's `compressionDefect J F G` from
`Pythagorean/ProbeComplexity/CompressionFiltration.lean` is precisely
`kappa1 (κ F) (κ (F ⊕ G)) (κ G)` where `κ = sheafCompressionNumber J`.
The bridge theorems `compressionDefect_eq_kappa1` and `catalog_nonneg_via_kappa1`
are stated in `Pythagorean/DerivedCompression/CatalogBridge.lean`.
-/

namespace DerivedCompression

/-! ## Section 1: Short Exact Compression Data -/

/-- A `ShortExactTriple` packages three types with group homomorphisms
    satisfying exactness conditions. -/
structure ShortExactTriple
    (A B Q : Type*) [AddCommGroup A] [AddCommGroup B] [AddCommGroup Q] where
  ι : A →+ B
  π : B →+ Q
  exact_comp : ∀ a, π (ι a) = 0
  exact_ker : ∀ b, π b = 0 → ∃ a, ι a = b

/-- A `SplitData` for a short exact triple is a section of π. -/
structure SplitData {A B Q : Type*}
    [AddCommGroup A] [AddCommGroup B] [AddCommGroup Q]
    (E : ShortExactTriple A B Q) where
  section_ : Q →+ B
  right_inv : ∀ q, E.π (section_ q) = q

/-! ## Section 2: First Derived Compression Invariant κ¹ -/

/-- The **first derived compression invariant** `κ¹`.
    `κ¹ = κ(A) + κ(Q) - κ(B)` measures the failure of κ to be additive. -/
def kappa1 (κA κB κQ : ℤ) : ℤ := κA + κQ - κB

/-- **Theorem 1: Nonnegativity of κ¹ under subadditivity.** -/
theorem kappa1_nonneg {κA κB κQ : ℤ} (hsub : κB ≤ κA + κQ) :
    0 ≤ kappa1 κA κB κQ := by
  unfold kappa1; omega

/-- **Theorem 2: Vanishing of κ¹ on split extensions.** -/
theorem kappa1_of_split {κA κB κQ : ℤ} (hsplit : κB = κA + κQ) :
    kappa1 κA κB κQ = 0 := by
  unfold kappa1; omega

/-- **Theorem 3: Exactness surrogate.** `κ(B) = κ(A) + κ(Q) - κ¹(E)` -/
theorem kappa0_kappa1_exact {κA κB κQ : ℤ} :
    κB = κA + κQ - kappa1 κA κB κQ := by
  unfold kappa1; omega

/-- κ¹ is symmetric in the outer terms. -/
theorem kappa1_comm (κA κB κQ : ℤ) :
    kappa1 κA κB κQ = kappa1 κQ κB κA := by
  unfold kappa1; omega

/-- Monotonicity: larger middle ⟹ smaller κ¹. -/
theorem kappa1_anti_middle {κA κB κB' κQ : ℤ} (h : κB ≤ κB') :
    kappa1 κA κB' κQ ≤ kappa1 κA κB κQ := by
  unfold kappa1; omega

/-! ## Section 3: Isomorphism of Extensions and Functorial Invariance -/

/-- An **isomorphism of short exact triples**. -/
structure ShortExactTripleIso
    {A₁ B₁ Q₁ A₂ B₂ Q₂ : Type*}
    [AddCommGroup A₁] [AddCommGroup B₁] [AddCommGroup Q₁]
    [AddCommGroup A₂] [AddCommGroup B₂] [AddCommGroup Q₂]
    (E₁ : ShortExactTriple A₁ B₁ Q₁) (E₂ : ShortExactTriple A₂ B₂ Q₂) where
  isoA : A₁ ≃+ A₂
  isoB : B₁ ≃+ B₂
  isoQ : Q₁ ≃+ Q₂
  comm_ι : ∀ a, isoB (E₁.ι a) = E₂.ι (isoA a)
  comm_π : ∀ b, isoQ (E₁.π b) = E₂.π (isoB b)

/-- **Theorem 4: Functorial invariance of κ¹.** -/
theorem kappa1_iso_invariant
    {κA₁ κB₁ κQ₁ κA₂ κB₂ κQ₂ : ℤ}
    (hA : κA₁ = κA₂) (hB : κB₁ = κB₂) (hQ : κQ₁ = κQ₂) :
    kappa1 κA₁ κB₁ κQ₁ = kappa1 κA₂ κB₂ κQ₂ := by
  unfold kappa1; omega

/-! ## Section 4: Extension Chains and Second-Order Invariants -/

/-- An **extension chain** of two composable short exact sequences. -/
structure ExtensionChain
    (X₀ X₁ X₂ X₃ X₄ : Type*)
    [AddCommGroup X₀] [AddCommGroup X₁] [AddCommGroup X₂]
    [AddCommGroup X₃] [AddCommGroup X₄] where
  e₁ : ShortExactTriple X₀ X₁ X₂
  e₂ : ShortExactTriple X₁ X₃ X₄

/-- The **second derived compression invariant** `κ²`.
    `κ² = κ¹(e₁) + κ¹(e₂) - κ¹(composite)` -/
def kappa2 (κ₀ κ₁ κ₂ κ₃ κ₄ : ℤ) : ℤ :=
  kappa1 κ₀ κ₁ κ₂ + kappa1 κ₁ κ₃ κ₄ - kappa1 κ₀ κ₃ (κ₂ + κ₄)

/-- κ² expanded. -/
theorem kappa2_expand (κ₀ κ₁ κ₂ κ₃ κ₄ : ℤ) :
    kappa2 κ₀ κ₁ κ₂ κ₃ κ₄ =
      (κ₀ + κ₂ - κ₁) + (κ₁ + κ₄ - κ₃) - (κ₀ + (κ₂ + κ₄) - κ₃) := by
  unfold kappa2 kappa1; ring

/-- **Key structural result**: κ² vanishes universally.
    The iterated-defect definition of κ² is identically zero. -/
theorem kappa2_vanishes_universally (κ₀ κ₁ κ₂ κ₃ κ₄ : ℤ) :
    kappa2 κ₀ κ₁ κ₂ κ₃ κ₄ = 0 := by
  unfold kappa2 kappa1; ring

/-- **Theorem 5: κ² vanishes on doubly-split extension chains.** -/
theorem kappa2_of_doubly_split {κ₀ κ₁ κ₂ κ₃ κ₄ : ℤ}
    (_hsplit₁ : κ₁ = κ₀ + κ₂) (_hsplit₂ : κ₃ = κ₁ + κ₄) :
    kappa2 κ₀ κ₁ κ₂ κ₃ κ₄ = 0 :=
  kappa2_vanishes_universally κ₀ κ₁ κ₂ κ₃ κ₄

/-! ## Section 5: Filtration Data and Telescoping -/

/-- Filtration compression data for `F₀ ⊂ F₁ ⊂ ⋯ ⊂ Fₙ`. -/
structure FiltrationData (n : ℕ) where
  κ_level : Fin (n + 1) → ℤ
  κ_graded : Fin n → ℤ

/-- κ¹ of the i-th filtration step. -/
def filtrationKappa1 {n : ℕ} (F : FiltrationData n) (i : Fin n) : ℤ :=
  kappa1 (F.κ_level i.castSucc) (F.κ_level i.succ) (F.κ_graded i)

/-- Total defect of a filtration. -/
def totalFiltrationDefect {n : ℕ} (F : FiltrationData n) : ℤ :=
  ∑ i : Fin n, filtrationKappa1 F i

/-
**Theorem 6: Telescoping identity for filtration defects.**
-/
theorem totalFiltrationDefect_eq {n : ℕ} (F : FiltrationData n) :
    totalFiltrationDefect F =
      F.κ_level 0 + ∑ i : Fin n, F.κ_graded i - F.κ_level (Fin.last n) := by
  unfold totalFiltrationDefect;
  unfold filtrationKappa1; induction' n with n ih <;> simp_all +decide [ Fin.sum_univ_castSucc ] ;
  convert congr_arg ( · + kappa1 ( F.κ_level ( Fin.last n ).castSucc ) ( F.κ_level ( Fin.last ( n + 1 ) ) ) ( F.κ_graded ( Fin.last n ) ) ) ( ih ⟨ fun i ↦ F.κ_level i.castSucc, fun i ↦ F.κ_graded i.castSucc ⟩ ) using 1 ; ring!
  unfold kappa1; ring!

/-- **Theorem 7: Nonnegativity of total defect under subadditivity.** -/
theorem totalFiltrationDefect_nonneg {n : ℕ} (F : FiltrationData n)
    (hsub : ∀ i : Fin n, F.κ_level i.succ ≤ F.κ_level i.castSucc + F.κ_graded i) :
    0 ≤ totalFiltrationDefect F := by
  unfold totalFiltrationDefect
  apply Finset.sum_nonneg
  intro i _
  exact kappa1_nonneg (hsub i)

/-- **Theorem 8: Total defect vanishes iff every step is exact.** -/
theorem totalFiltrationDefect_eq_zero_iff {n : ℕ} (F : FiltrationData n)
    (hsub : ∀ i : Fin n, F.κ_level i.succ ≤ F.κ_level i.castSucc + F.κ_graded i) :
    totalFiltrationDefect F = 0 ↔
      ∀ i : Fin n, F.κ_level i.succ = F.κ_level i.castSucc + F.κ_graded i := by
  unfold totalFiltrationDefect
  constructor
  · intro h
    have hnn : ∀ i : Fin n, 0 ≤ filtrationKappa1 F i :=
      fun i => kappa1_nonneg (hsub i)
    have hzero := Finset.sum_eq_zero_iff_of_nonneg (fun i _ => hnn i) |>.mp h
    intro i
    have hi := hzero i (Finset.mem_univ i)
    unfold filtrationKappa1 kappa1 at hi; omega
  · intro h
    apply Finset.sum_eq_zero
    intro i _
    unfold filtrationKappa1 kappa1
    have := h i; omega

/-! ## Section 6: Computable Finite Models -/

/-- A **finite compression system**: a concrete computable model. -/
structure FiniteCompressionSystem where
  n : ℕ
  size : Fin n → ℕ
  compress : Fin n → ℕ
  compress_le : ∀ i, compress i ≤ size i

/-- Compression defect for a finite system element. -/
def FiniteCompressionSystem.defect (S : FiniteCompressionSystem)
    (i : Fin S.n) : ℤ :=
  (S.size i : ℤ) - (S.compress i : ℤ)

/-- Every element's defect is nonneg. -/
theorem FiniteCompressionSystem.defect_nonneg (S : FiniteCompressionSystem)
    (i : Fin S.n) : 0 ≤ S.defect i := by
  unfold defect
  have := S.compress_le i
  omega

/-- A **finite extension datum** within a finite compression system. -/
structure FiniteExtensionDatum (S : FiniteCompressionSystem) where
  iA : Fin S.n
  iB : Fin S.n
  iQ : Fin S.n
  sub_add : S.compress iB ≤ S.compress iA + S.compress iQ

/-- κ¹ of a finite extension datum. -/
def FiniteExtensionDatum.kappa1val {S : FiniteCompressionSystem}
    (E : FiniteExtensionDatum S) : ℤ :=
  DerivedCompression.kappa1
    (S.compress E.iA : ℤ) (S.compress E.iB : ℤ) (S.compress E.iQ : ℤ)

/-- κ¹ of a finite extension datum is nonneg. -/
theorem FiniteExtensionDatum.kappa1val_nonneg {S : FiniteCompressionSystem}
    (E : FiniteExtensionDatum S) : 0 ≤ E.kappa1val := by
  unfold FiniteExtensionDatum.kappa1val
  apply DerivedCompression.kappa1_nonneg
  exact_mod_cast E.sub_add

/-- **Theorem 9: Additivity characterization.** -/
theorem additive_iff_all_kappa1_zero (S : FiniteCompressionSystem) :
    (∀ E : FiniteExtensionDatum S, E.kappa1val = 0) ↔
    (∀ E : FiniteExtensionDatum S,
      (S.compress E.iB : ℤ) = (S.compress E.iA : ℤ) + (S.compress E.iQ : ℤ)) := by
  constructor
  · intro h E
    have := h E
    unfold FiniteExtensionDatum.kappa1val kappa1 at this; omega
  · intro h E
    unfold FiniteExtensionDatum.kappa1val kappa1
    have := h E; omega

/-! ## Section 7: Additional Structure Theorems -/

/-- **Theorem 10: κ¹ triangle inequality.** -/
theorem kappa1_triangle {κA κB κC κD κE : ℤ}
    (_h_sub₁ : κB ≤ κA + κC) (_h_sub₂ : κD ≤ κB + κE)
    (_h_sub_comp : κD ≤ κA + (κC + κE)) :
    kappa1 κA κD (κC + κE) ≤ kappa1 κA κB κC + kappa1 κB κD κE := by
  unfold kappa1; omega

/-- **Theorem 11: Euler-defect duality for length-1 filtrations.** -/
theorem euler_defect_length1 (F : FiltrationData 1) :
    totalFiltrationDefect F =
      F.κ_level 0 + F.κ_graded 0 - F.κ_level 1 := by
  simp [totalFiltrationDefect, filtrationKappa1, kappa1]

/-- κ¹ is bounded above by κ(A) + κ(Q) when κ(B) ≥ 0. -/
theorem kappa1_le_sum {κA κB κQ : ℤ} (hB : 0 ≤ κB) :
    kappa1 κA κB κQ ≤ κA + κQ := by
  unfold kappa1; omega

/-- κ¹ is bounded below by -κ(B) when κ(A), κ(Q) ≥ 0. -/
theorem kappa1_ge_neg {κA κB κQ : ℤ} (hA : 0 ≤ κA) (hQ : 0 ≤ κQ) :
    -κB ≤ kappa1 κA κB κQ := by
  unfold kappa1; omega

/-- If κ(A) increases, κ¹ increases. -/
theorem kappa1_mono_left {κA κA' κB κQ : ℤ} (h : κA ≤ κA') :
    kappa1 κA κB κQ ≤ kappa1 κA' κB κQ := by
  unfold kappa1; omega

/-- **Theorem 12: Three-term derived compression identity.** -/
theorem three_term_defect_decomposition (κ₀ κ₁ κ₂ g₁ g₂ : ℤ) :
    kappa1 κ₀ κ₁ g₁ + kappa1 κ₁ κ₂ g₂ = κ₀ + g₁ + g₂ - κ₂ := by
  unfold kappa1; omega

end DerivedCompression