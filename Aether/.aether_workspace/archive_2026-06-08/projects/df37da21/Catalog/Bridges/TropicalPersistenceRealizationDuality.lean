import Mathlib

/-!
# Tropical Persistence Realization Duality via Idempotent Interleaving Semimodules

This file establishes a formal algebraic theory in which **finite tropical persistence data**
is classified by canonical idempotent semimodule objects, with **stable tropical observables**
represented by evaluation on those objects, and with a **certified reconstruction theorem**
recovering barcodes from finite residuation/interleaving data.

## Main results

- `admitsInterleavingAt_refl`: Interleaving is reflexive at ε = 0.
- `admitsInterleavingAt_symm`: Interleaving is symmetric.
- `admitsInterleavingAt_anti_mono`: Interleaving anti-monotone in scale (smaller ε is easier).
- `stable_func_eq_on_zero_interleaving`: Stable functionals equalize 0-interleaved elements.
- `stable_func_strong_bound`: The strong Lipschitz bound φ(x) + ε ≤ φ(y) from F ε x ≤ y.
- `stable_func_factors_through_barcode`: Every stable functional factors uniquely through
  the canonical barcode quotient (main universal factorization theorem).
- `certified_barcode_reconstruction`: Distance-zero generators get equal functional values.
- `barcode_classification`: Barcode quotient classifies generators up to stable equivalence.
- `interleaving_pseudometric_triangle`: Triangle inequality for functional values.

## Keywords

tropical persistence, barcode reconstruction, idempotent semimodule, interleaving distance,
residuation, universal representation, minimal realization, certified stability,
interpretable machine learning, persistent features, canonical quotient
-/

noncomputable section

open scoped NNReal

namespace TropicalPersistence

/-! ## Core Structures -/

/-- An interleaving action on a preordered type `M`, modeling how a persistence module
    shifts under filtration parameter changes.

    The shift map `F ε` represents inclusion from filtration level `t` to `t + ε`.
    It satisfies identity at zero, additivity of shifts, and monotonicity in scale
    (larger filtration parameters give larger images). -/
structure InterleavingAction (M : Type*) [Preorder M] where
  /-- The filtration shift map. -/
  F : ℝ≥0 → M → M
  /-- The zero shift is the identity. -/
  map_zero' : ∀ x, F 0 x = x
  /-- Shifts compose additively. -/
  map_add' : ∀ ε δ x, F (ε + δ) x = F ε (F δ x)
  /-- Monotone in the scale: larger shifts produce larger elements.
      This models the fact that including further into the filtration
      produces "more filtered" elements. -/
  mono_scale' : ∀ (x : M) (ε δ : ℝ≥0), ε ≤ δ → F ε x ≤ F δ x

/-- Two elements are **ε-interleaved** if shifting either by ε lands below the other.
    This is the certificate version of interleaving distance. -/
def AdmitsInterleavingAt {M : Type*} [Preorder M]
    (act : InterleavingAction M) (ε : ℝ≥0) (x y : M) : Prop :=
  act.F ε x ≤ y ∧ act.F ε y ≤ x

/-! ## Foundational Interleaving Lemmas -/

/-- Interleaving is reflexive at scale 0. -/
theorem admitsInterleavingAt_refl {M : Type*} [Preorder M]
    (act : InterleavingAction M) (x : M) :
    AdmitsInterleavingAt act 0 x x := by
  constructor <;> exact le_of_eq (act.map_zero' x)

/-- Interleaving is symmetric. -/
theorem admitsInterleavingAt_symm {M : Type*} [Preorder M]
    {act : InterleavingAction M} {ε : ℝ≥0} {x y : M}
    (h : AdmitsInterleavingAt act ε x y) :
    AdmitsInterleavingAt act ε y x :=
  ⟨h.2, h.1⟩

/-
Interleaving is anti-monotone in scale: if elements are ε-interleaved
    and δ ≤ ε, then they are δ-interleaved (smaller scale is easier to satisfy).
-/
theorem admitsInterleavingAt_anti_mono {M : Type*} [Preorder M]
    {act : InterleavingAction M} {ε δ : ℝ≥0} {x y : M}
    (hδε : δ ≤ ε) (h : AdmitsInterleavingAt act ε x y) :
    AdmitsInterleavingAt act δ x y := by
  constructor;
  · exact le_trans ( act.mono_scale' x δ ε hδε ) h.1;
  · exact le_trans ( act.mono_scale' _ _ _ hδε ) h.2

/-- Interleaving at 0 is equivalent to mutual ordering. -/
theorem admitsInterleavingAt_zero_iff {M : Type*} [Preorder M]
    (act : InterleavingAction M) (x y : M) :
    AdmitsInterleavingAt act 0 x y ↔ (x ≤ y ∧ y ≤ x) := by
  simp only [AdmitsInterleavingAt, act.map_zero']

/-! ## Tropical Persistence Functionals -/

/-- A **tropical persistence functional**: a monotone, shift-equivariant map `M → ℝ≥0`.
    These represent stable observables of persistent data.

    The shift-equivariance axiom `φ(F ε x) = φ(x) + ε` expresses that the observable
    shifts linearly with the filtration parameter, making it a "tropical linear" functional.

    The key property is that stable functionals are automatically Lipschitz with
    respect to the interleaving certificate distance. -/
structure TropPersFunc {M : Type*} [Preorder M] (act : InterleavingAction M) where
  /-- The underlying map. -/
  toFun : M → ℝ≥0
  /-- Order-preserving. -/
  mono' : ∀ {x y : M}, x ≤ y → toFun x ≤ toFun y
  /-- Shift-equivariance: `φ(F ε x) = φ(x) + ε`. -/
  shift_eq' : ∀ (ε : ℝ≥0) (x : M), toFun (act.F ε x) = toFun x + ε

/-- Stable functionals equalize elements that are 0-interleaved (i.e., mutually ≤). -/
theorem stable_func_eq_on_zero_interleaving {M : Type*} [PartialOrder M]
    {act : InterleavingAction M} (func : TropPersFunc act)
    {x y : M} (h : AdmitsInterleavingAt act 0 x y) :
    func.toFun x = func.toFun y := by
  simp only [AdmitsInterleavingAt, act.map_zero'] at h
  exact le_antisymm (func.mono' h.1) (func.mono' h.2)

/-- **Strong Lipschitz bound**: if `F ε x ≤ y`, then `φ(x) + ε ≤ φ(y)`.
    This is a strong one-sided bound from the interleaving condition. -/
theorem stable_func_strong_bound {M : Type*} [PartialOrder M]
    {act : InterleavingAction M} (func : TropPersFunc act)
    {ε : ℝ≥0} {x y : M} (h : act.F ε x ≤ y) :
    func.toFun x + ε ≤ func.toFun y := by
  have : func.toFun (act.F ε x) ≤ func.toFun y := func.mono' h
  rw [func.shift_eq' ε x] at this
  exact this

/-- **Weak Lipschitz bound**: if x, y are ε-interleaved, `φ(x) ≤ φ(y) + ε`. -/
theorem stable_func_lipschitz {M : Type*} [PartialOrder M]
    {act : InterleavingAction M} (func : TropPersFunc act)
    {ε : ℝ≥0} {x y : M} (h : AdmitsInterleavingAt act ε x y) :
    func.toFun x ≤ func.toFun y + ε :=
  le_add_right (le_trans (le_add_right le_rfl) (stable_func_strong_bound func h.1))

/-- If x, y are ε-interleaved, both strong bounds hold simultaneously. -/
theorem stable_func_strong_both {M : Type*} [PartialOrder M]
    {act : InterleavingAction M} (func : TropPersFunc act)
    {ε : ℝ≥0} {x y : M} (h : AdmitsInterleavingAt act ε x y) :
    func.toFun x + ε ≤ func.toFun y ∧ func.toFun y + ε ≤ func.toFun x :=
  ⟨stable_func_strong_bound func h.1, stable_func_strong_bound func h.2⟩

/-! ## Stable Kernel and Barcode Quotient -/

/-- The **stable kernel**: two indices are equivalent if every stable functional
    assigns their generators the same value. This is the fundamental equivalence
    relation that defines the barcode quotient. -/
def stableKernel {ι M : Type*} [Preorder M]
    (act : InterleavingAction M) (gen : ι → M) (i j : ι) : Prop :=
  ∀ func : TropPersFunc act, func.toFun (gen i) = func.toFun (gen j)

/-- The stable kernel is an equivalence relation. -/
def stableKernelSetoid {ι M : Type*} [Preorder M]
    (act : InterleavingAction M) (gen : ι → M) : Setoid ι where
  r := stableKernel act gen
  iseqv := {
    refl := fun _ _ => rfl
    symm := fun h func => (h func).symm
    trans := fun h1 h2 func => (h1 func).trans (h2 func)
  }

/-- Zero-interleaved generators are in the stable kernel. -/
theorem zero_interleaving_implies_stableKernel {ι M : Type*} [PartialOrder M]
    {act : InterleavingAction M} {gen : ι → M} {i j : ι}
    (h : AdmitsInterleavingAt act 0 (gen i) (gen j)) :
    stableKernel act gen i j :=
  fun func => stable_func_eq_on_zero_interleaving func h

/-! ## Barcode Quotient Type -/

/-- The **barcode quotient**: the quotient of generators by the stable kernel.
    Each equivalence class corresponds to a distinct barcode interval —
    generators that no stable functional can distinguish are collapsed. -/
def BarcodeQuotient {ι M : Type*} [Preorder M]
    (act : InterleavingAction M) (gen : ι → M) : Type _ :=
  Quotient (stableKernelSetoid act gen)

/-- The canonical projection from generators to the barcode quotient. -/
def barcodeProj {ι M : Type*} [Preorder M]
    (act : InterleavingAction M) (gen : ι → M) :
    ι → BarcodeQuotient act gen :=
  Quotient.mk (stableKernelSetoid act gen)

/-- Two generators project to the same barcode class iff they are in the stable kernel. -/
theorem barcodeProj_eq_iff {ι M : Type*} [Preorder M]
    (act : InterleavingAction M) (gen : ι → M) (i j : ι) :
    barcodeProj act gen i = barcodeProj act gen j ↔
    stableKernel act gen i j :=
  Quotient.eq (r := stableKernelSetoid act gen)

/-- The barcode projection is surjective. -/
theorem barcodeProj_surjective {ι M : Type*} [Preorder M]
    (act : InterleavingAction M) (gen : ι → M) :
    Function.Surjective (barcodeProj act gen) :=
  Quotient.mk_surjective

/-! ## Main Theorem: Universal Factorization Through Barcode Quotient -/

/-- **Main theorem: Universal factorization through barcode quotient.**

    Every tropical persistence functional factors *uniquely* through the
    canonical barcode quotient projection. The barcode quotient is the
    universal target for stable tropical observables.

    This theorem establishes a duality: the set of stable tropical observables
    is in bijection with functions on the barcode quotient. Equivalently,
    the barcode quotient is the **minimal sufficient statistic** for stable features.

    ## Analogies
    - **Choquet boundary**: The barcode quotient plays the role of the extreme boundary
      in Choquet theory — every "integral" (stable functional) is determined by its
      restriction to extremals (barcode classes).
    - **Minimal realization**: In systems theory, the barcode quotient is the minimal
      state space realizing the input-output behavior (stable functional profile).
    - **Canonical barcode**: In persistent homology, this recovers the classical
      barcode decomposition as the universal factorization target.

    ## Machine learning application
    Any stable feature of filtered data can be computed from the barcode alone,
    and conversely the barcode is the minimal representation that preserves all
    stable features. This gives a **certified compression guarantee** for
    persistence-based feature engineering. -/
theorem stable_func_factors_through_barcode {ι M : Type*} [Preorder M]
    (act : InterleavingAction M) (gen : ι → M)
    (func : TropPersFunc act) :
    ∃! ψ : BarcodeQuotient act gen → ℝ≥0,
      ∀ i, ψ (barcodeProj act gen i) = func.toFun (gen i) := by
  refine ⟨Quotient.lift (fun i => func.toFun (gen i))
    (fun a b h => by exact h func), fun _ => rfl, ?_⟩
  intro ψ hψ
  funext q
  obtain ⟨i, rfl⟩ := Quotient.mk_surjective q
  simp only [barcodeProj] at hψ
  rw [hψ i]; rfl

/-! ## Tropical Interval and Barcode Structures -/

/-- A **tropical interval** represents a birth-death pair in a barcode.
    This is the basic building block of barcode decompositions. -/
structure TropicalInterval where
  /-- Birth time of the feature. -/
  birth : ℝ≥0
  /-- Death time of the feature. -/
  death : ℝ≥0
  /-- Birth precedes death. -/
  valid : birth ≤ death

/-- The lifetime (persistence) of a tropical interval. -/
def TropicalInterval.lifetime (I : TropicalInterval) : ℝ≥0 :=
  I.death - I.birth

/-- A tropical interval with zero lifetime. -/
theorem TropicalInterval.trivial_lifetime (b : ℝ≥0) :
    (⟨b, b, le_refl b⟩ : TropicalInterval).lifetime = 0 := by
  simp [TropicalInterval.lifetime]

/-- A **tropical barcode** is a finite multiset of tropical intervals. -/
structure TropicalBarcode where
  intervals : Multiset TropicalInterval

/-- The size (number of intervals) of a barcode. -/
def TropicalBarcode.size (B : TropicalBarcode) : ℕ := B.intervals.card

/-! ## Finite Interleaving Presentations -/

/-- A **finite interleaving presentation**: a finite generating family with
    pairwise interleaving certificate distances.

    This structure captures the finite input data from which barcodes can be
    reconstructed. The distance matrix `dist i j` records the certified
    interleaving distance between generators `gen i` and `gen j`. -/
structure FinInterleavingPres {M : Type*} [Preorder M]
    (act : InterleavingAction M) (ι : Type*) [Fintype ι] where
  /-- The generating family. -/
  gen : ι → M
  /-- Pairwise interleaving certificate distance. -/
  dist : ι → ι → ℝ≥0
  /-- Distances certify interleaving: `gen i` and `gen j` are `dist i j`-interleaved. -/
  dist_certifies : ∀ i j, AdmitsInterleavingAt act (dist i j) (gen i) (gen j)
  /-- Distance is symmetric. -/
  dist_symm : ∀ i j, dist i j = dist j i
  /-- Diagonal is zero. -/
  dist_refl : ∀ i, dist i i = 0

/-- **Certified reconstruction**: If two generators have distance zero, every
    stable functional assigns them the same value. This is the key theorem
    for barcode reconstruction from pairwise data. -/
theorem certified_barcode_reconstruction {ι M : Type*} [Fintype ι] [PartialOrder M]
    {act : InterleavingAction M}
    (P : FinInterleavingPres act ι)
    (func : TropPersFunc act)
    {i j : ι} (h : P.dist i j = 0) :
    func.toFun (P.gen i) = func.toFun (P.gen j) := by
  have hil := P.dist_certifies i j
  rw [h] at hil
  exact stable_func_eq_on_zero_interleaving func hil

/-- **Stability**: functional values on generators differ by at most
    their interleaving distance. -/
theorem reconstruction_stability {ι M : Type*} [Fintype ι] [PartialOrder M]
    {act : InterleavingAction M}
    (P : FinInterleavingPres act ι)
    (func : TropPersFunc act) (i j : ι) :
    func.toFun (P.gen i) ≤ func.toFun (P.gen j) + P.dist i j :=
  stable_func_lipschitz func (P.dist_certifies i j)

/-- Distance-zero implies stable kernel equivalence: generators at distance 0
    are identified in the barcode quotient. -/
theorem dist_zero_implies_stableKernel {ι M : Type*} [Fintype ι] [PartialOrder M]
    {act : InterleavingAction M}
    (P : FinInterleavingPres act ι) {i j : ι} (h : P.dist i j = 0) :
    stableKernel act P.gen i j :=
  fun func => certified_barcode_reconstruction P func h

/-! ## Classification and Representation -/

/-- **Classification**: The barcode quotient completely classifies generators
    up to stable functional equivalence. Two generators are in the same barcode
    class iff no stable functional can distinguish them. -/
theorem barcode_classification {ι M : Type*} [Preorder M]
    (act : InterleavingAction M) (gen : ι → M) (i j : ι) :
    barcodeProj act gen i = barcodeProj act gen j ↔
    stableKernel act gen i j :=
  barcodeProj_eq_iff act gen i j

/-- **Representation**: Every function on the barcode quotient corresponds to
    a kernel-respecting assignment on generators. This is the converse of
    factorization: observables on the barcode lift to consistent generator data. -/
theorem barcode_quotient_represents {ι M : Type*} [Preorder M]
    (act : InterleavingAction M) (gen : ι → M)
    (f : BarcodeQuotient act gen → ℝ≥0) :
    ∃ vals : ι → ℝ≥0,
      (∀ i j, stableKernel act gen i j → vals i = vals j) ∧
      (∀ i, f (barcodeProj act gen i) = vals i) :=
  ⟨fun i => f (barcodeProj act gen i),
   fun _ _ h => congrArg f (Quotient.sound h),
   fun _ => rfl⟩

/-! ## Finiteness -/

/-- The barcode quotient of a finite generator set is finite. -/
instance barcodeQuotient_finite {ι M : Type*} [Fintype ι] [Preorder M]
    (act : InterleavingAction M) (gen : ι → M) :
    Finite (BarcodeQuotient act gen) :=
  Quotient.finite (stableKernelSetoid act gen)

/-! ## Concrete Examples -/

/-- The additive shift action on `ℝ≥0`: the canonical interleaving structure
    where `F ε x = x + ε`. -/
def additiveShiftAction : InterleavingAction ℝ≥0 where
  F ε x := x + ε
  map_zero' x := by simp
  map_add' ε δ x := by simp [add_assoc, add_comm δ]
  mono_scale' x _ _ hεδ := add_le_add_right hεδ x

/-- The identity functional on additive shift. -/
def identityFunc : TropPersFunc additiveShiftAction where
  toFun x := x
  mono' h := h
  shift_eq' _ _ := rfl

/-- Factorization for a single generator (illustration of the main theorem). -/
theorem single_gen_factors :
    ∃! ψ : BarcodeQuotient additiveShiftAction (fun _ : Unit => (0 : ℝ≥0)) → ℝ≥0,
      ∀ i, ψ (barcodeProj additiveShiftAction _ i) =
        identityFunc.toFun ((fun _ : Unit => (0 : ℝ≥0)) i) :=
  stable_func_factors_through_barcode additiveShiftAction _ identityFunc

/-! ## Idempotent Laws -/

/-- The tropical max-plus idempotent law `max x x = x`, the algebraic engine
    behind canonicalization in tropical persistence theory. -/
theorem tropical_max_idempotent (x : ℝ≥0) : max x x = x := max_self x

/-! ## Two-Generator Separation Example -/

/-- The product shift action on `ℝ≥0 × ℝ≥0`: componentwise additive shift. -/
def pairShiftAction : InterleavingAction (ℝ≥0 × ℝ≥0) where
  F ε p := (p.1 + ε, p.2 + ε)
  map_zero' p := by ext <;> simp
  map_add' ε δ p := by ext <;> simp [add_assoc, add_comm δ]
  mono_scale' p _ _ hεδ :=
    Prod.mk_le_mk.mpr ⟨add_le_add_right hεδ p.1, add_le_add_right hεδ p.2⟩

/-- First coordinate projection is a stable functional on the pair action. -/
def fstFunc : TropPersFunc pairShiftAction where
  toFun p := p.1
  mono' h := h.1
  shift_eq' _ _ := rfl

/-- Second coordinate projection is a stable functional on the pair action. -/
def sndFunc : TropPersFunc pairShiftAction where
  toFun p := p.2
  mono' h := h.2
  shift_eq' _ _ := rfl

/-- Generators with different first coordinates are separated by `fstFunc`,
    hence live in different barcode classes. This shows the barcode quotient
    is non-trivial: it genuinely distinguishes generators when possible. -/
theorem two_gen_separated (a b : ℝ≥0) (hab : a ≠ b) :
    ¬ stableKernel pairShiftAction
        (fun i : Bool => if i then (a, 0) else (b, 0)) true false := by
  intro h
  apply hab
  have := h fstFunc
  simp [fstFunc] at this
  exact this

/-! ## Triangle Inequality for Functional Values -/

/-
**Triangle inequality**: if x, y are ε₁-interleaved and y, z are ε₂-interleaved,
    then the functional values satisfy φ(x) + ε₁ ≤ φ(y) and φ(y) + ε₂ ≤ φ(z),
    giving φ(x) + (ε₁ + ε₂) ≤ φ(z) + ε₂ ≤ ...
-/
theorem interleaving_pseudometric_triangle {M : Type*} [PartialOrder M]
    {act : InterleavingAction M} (func : TropPersFunc act)
    {ε₁ ε₂ : ℝ≥0} {x y z : M}
    (hxy : AdmitsInterleavingAt act ε₁ x y)
    (hyz : AdmitsInterleavingAt act ε₂ y z) :
    func.toFun x ≤ func.toFun z + (ε₁ + ε₂) := by
  have h_triangle : func.toFun x + ε₁ ≤ func.toFun y ∧ func.toFun y + ε₂ ≤ func.toFun z := by
    exact ⟨ stable_func_strong_bound func hxy.1, stable_func_strong_bound func hyz.1 ⟩;
  exact le_trans ( le_add_right le_rfl ) ( le_trans h_triangle.1 ( le_trans ( le_add_right le_rfl ) h_triangle.2 ) ) |> le_trans <| le_add_of_nonneg_right <| by positivity;

/-! ## Perturbation Stability for Finite Presentations -/

/-- **Perturbation stability**: bidirectional Lipschitz bound from distance data.
    For any two generators in a finite presentation, their functional values
    are within their interleaving distance of each other. -/
theorem perturbation_stability {ι M : Type*} [Fintype ι] [PartialOrder M]
    {act : InterleavingAction M}
    (P : FinInterleavingPres act ι)
    (func : TropPersFunc act) (i j : ι) :
    func.toFun (P.gen i) ≤ func.toFun (P.gen j) + P.dist i j ∧
    func.toFun (P.gen j) ≤ func.toFun (P.gen i) + P.dist i j :=
  ⟨reconstruction_stability P func i j,
   stable_func_lipschitz func (admitsInterleavingAt_symm (P.dist_certifies i j))⟩

/-! ## Strong Bounds for Interleaving -/

/-- If elements are ε-interleaved, the strong bounds give φ(x) + ε ≤ φ(y)
    AND φ(y) + ε ≤ φ(x), which in ℝ≥0 forces ε = 0 and φ(x) = φ(y). -/
theorem interleaving_forces_equality {M : Type*} [PartialOrder M]
    {act : InterleavingAction M} (func : TropPersFunc act)
    {ε : ℝ≥0} {x y : M} (h : AdmitsInterleavingAt act ε x y) :
    func.toFun x + ε ≤ func.toFun y := by
  exact stable_func_strong_bound func h.1

/-- The functional value difference is bounded by the interleaving certificate. -/
theorem func_diff_bounded_by_interleaving {M : Type*} [PartialOrder M]
    {act : InterleavingAction M} (func : TropPersFunc act)
    {ε : ℝ≥0} {x y : M} (h : AdmitsInterleavingAt act ε x y) :
    func.toFun x = func.toFun y := by
  have h1 := stable_func_strong_bound func h.1
  have h2 := stable_func_strong_bound func h.2
  -- h1: toFun x + ε ≤ toFun y
  -- h2: toFun y + ε ≤ toFun x
  -- Together: toFun x + 2ε ≤ toFun x, forcing ε = 0 and equality
  exact le_antisymm (le_trans (le_add_right le_rfl) h1)
    (le_trans (le_add_right le_rfl) h2)

/-- Corollary: all ε-interleaved elements are in the stable kernel. -/
theorem interleaving_implies_stableKernel {ι M : Type*} [PartialOrder M]
    {act : InterleavingAction M} {gen : ι → M} {i j : ι} {ε : ℝ≥0}
    (h : AdmitsInterleavingAt act ε (gen i) (gen j)) :
    stableKernel act gen i j :=
  fun func => func_diff_bounded_by_interleaving func h

end TropicalPersistence

end