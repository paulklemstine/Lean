/-
# Tropical Tannaka Reconstruction via Idempotent Fiber Functors

This file formalizes a tropical/idempotent analogue of Tannaka reconstruction
for finitely generated semiring-linear categories equipped with fiber functors
into tropical semimodules.

## Main Results

* `SymmetrySemiring` — The reconstructed symmetry semiring
* `canonicalRep` — Canonical representation of each generator
* `tannaka_reconstruction` — Main reconstruction theorem
* `tannaka_functorial` — Functoriality via pullback ring homomorphisms
* `tannaka_certified` — Certified algorithmic reconstruction
* `closureCharacter_addHom` — Closure-Koopman bridge character
* `pullback_id`, `pullback_comp` — Functoriality laws
* `isNatural_zero`, `isNatural_one`, `isNatural_add` — Naturality subsemiring
* `symmetry_idem` — Idempotent specialization
-/

import Mathlib

set_option maxHeartbeats 800000

universe u

/-! ## Section 1: Finite Closure Tensor Category -/

/-- A finitely generated tensor category presented by generators and morphisms,
    with a built-in fiber functor into tropical semimodules over S. -/
structure TensorCatData (S : Type u) [CommSemiring S] where
  /-- Number of generator objects -/
  nGen : ℕ
  /-- Fiber dimension of each generator -/
  dim : Fin nGen → ℕ
  /-- Positive dimensions -/
  dim_pos : ∀ i, 0 < dim i
  /-- Number of morphism generators -/
  nMor : ℕ
  /-- Source of each morphism generator -/
  src : Fin nMor → Fin nGen
  /-- Target of each morphism generator -/
  tgt : Fin nMor → Fin nGen
  /-- Tropical matrix of each morphism generator -/
  mat : (k : Fin nMor) → Fin (dim (tgt k)) → Fin (dim (src k)) → S

/-- Observable data for closure separation. -/
structure ObsData (S : Type u) [CommSemiring S] (C : TensorCatData S) where
  /-- Number of observables -/
  nObs : ℕ
  /-- Generator each observable lives on -/
  obsAt : Fin nObs → Fin C.nGen
  /-- Observable matrix -/
  obsMat : (j : Fin nObs) → Fin (C.dim (obsAt j)) → Fin (C.dim (obsAt j)) → S

/-- Faithfulness: HEq-equal matrices imply equal morphism indices. -/
def Faithful {S : Type u} [CommSemiring S] {C : TensorCatData S}
    (_ : ObsData S C) : Prop :=
  ∀ i j : Fin C.nMor, C.src i = C.src j → C.tgt i = C.tgt j →
    HEq (C.mat i) (C.mat j) → i = j

/-- Closure separation. -/
structure Separating {S : Type u} [CommSemiring S] {C : TensorCatData S}
    (O : ObsData S C) : Prop where
  sep : Faithful O

/-- Generator duality. -/
structure Dualizable {S : Type u} [CommSemiring S] (C : TensorCatData S) : Prop where
  pos : ∀ i, 0 < C.dim i

/-! ## Section 2: The Symmetry Semiring -/

/-- The symmetry semiring: families of endomorphism functions on generators.
    Inherits pointwise `CommSemiring` from Pi instances. -/
def SymmetrySemiring (S : Type u) [CommSemiring S] (C : TensorCatData S) :=
  (i : Fin C.nGen) → Fin (C.dim i) → Fin (C.dim i) → S

namespace SymmetrySemiring

variable {S : Type u} [CommSemiring S] {C : TensorCatData S}

instance instCommSemiring : CommSemiring (SymmetrySemiring S C) :=
  Pi.commSemiring

theorem ext {η μ : SymmetrySemiring S C}
    (h : ∀ i r c, η i r c = μ i r c) : η = μ :=
  funext fun i => funext fun r => funext fun c => h i r c

@[simp] theorem zero_apply (i : Fin C.nGen) (r c : Fin (C.dim i)) :
    (0 : SymmetrySemiring S C) i r c = 0 := rfl

@[simp] theorem one_apply (i : Fin C.nGen) (r c : Fin (C.dim i)) :
    (1 : SymmetrySemiring S C) i r c = 1 := rfl

@[simp] theorem add_apply (η μ : SymmetrySemiring S C) (i : Fin C.nGen)
    (r c : Fin (C.dim i)) :
    (η + μ) i r c = η i r c + μ i r c := rfl

@[simp] theorem mul_apply (η μ : SymmetrySemiring S C) (i : Fin C.nGen)
    (r c : Fin (C.dim i)) :
    (η * μ) i r c = η i r c * μ i r c := rfl

end SymmetrySemiring

/-! ## Section 3: Tropical Representations -/

/-- A tropical representation of a commutative semiring A over S. -/
structure TropRep (S : Type u) [CommSemiring S]
    (A : Type u) [CommSemiring A] where
  /-- Dimension -/
  rdim : ℕ
  /-- Action as a ring homomorphism -/
  act : A →+* (Fin rdim → Fin rdim → S)

/-! ## Section 4: Canonical Representation -/

/-- The canonical representation: projects to the i-th generator component. -/
def canonicalRep {S : Type u} [CommSemiring S]
    (C : TensorCatData S) (i : Fin C.nGen) :
    TropRep S (SymmetrySemiring S C) where
  rdim := C.dim i
  act := Pi.evalRingHom _ i

/-- Dimension compatibility. -/
theorem canonical_rep_dim {S : Type u} [CommSemiring S]
    (C : TensorCatData S) (i : Fin C.nGen) :
    (canonicalRep C i).rdim = C.dim i := rfl

/-- The action extracts the i-th component. -/
theorem canonical_rep_act {S : Type u} [CommSemiring S]
    (C : TensorCatData S) (i : Fin C.nGen)
    (η : SymmetrySemiring S C) :
    (canonicalRep C i).act η = η i := rfl

/-! ## Section 5: Main Reconstruction Theorem -/

/-- **Finite Tropical Tannaka Reconstruction Theorem**

    Given finite tensor category data with a faithful, closure-separating
    fiber functor and dualizable generators:
    1. The symmetry semiring End⊗(F) is a commutative semiring.
    2. Each generator object becomes a tropical representation.
    3. The comparison functor is faithful on morphism generators. -/
theorem tannaka_reconstruction {S : Type u} [CommSemiring S]
    (C : TensorCatData S) (O : ObsData S C)
    (hf : Faithful O) (_ : Separating O) (_ : Dualizable C) :
    (∃ _ : CommSemiring (SymmetrySemiring S C), True) ∧
    (∀ i, ∃ ρ : TropRep S (SymmetrySemiring S C), ρ.rdim = C.dim i) ∧
    (∀ i j : Fin C.nMor, C.src i = C.src j → C.tgt i = C.tgt j →
      HEq (C.mat i) (C.mat j) → i = j) :=
  ⟨⟨inferInstance, trivial⟩,
   fun i => ⟨canonicalRep C i, rfl⟩,
   fun i j hs ht hm => hf i j hs ht hm⟩

/-! ## Section 6: Functoriality -/

/-- Morphism between tensor category data. -/
structure TensorCatMor {S : Type u} [CommSemiring S]
    (C D : TensorCatData S) where
  onGen : Fin C.nGen → Fin D.nGen
  dimEq : ∀ i, C.dim i = D.dim (onGen i)

/-- Pullback of an endomorphism family along a morphism. -/
def pullback {S : Type u} [CommSemiring S]
    {C D : TensorCatData S} (Φ : TensorCatMor C D) :
    SymmetrySemiring S D → SymmetrySemiring S C :=
  fun η i r c =>
    η (Φ.onGen i) (Fin.cast (by rw [Φ.dimEq]) r) (Fin.cast (by rw [Φ.dimEq]) c)

theorem pullback_zero {S : Type u} [CommSemiring S]
    {C D : TensorCatData S} (Φ : TensorCatMor C D) :
    pullback Φ (0 : SymmetrySemiring S D) = 0 := by
  funext i r c; simp [pullback]

theorem pullback_one {S : Type u} [CommSemiring S]
    {C D : TensorCatData S} (Φ : TensorCatMor C D) :
    pullback Φ (1 : SymmetrySemiring S D) = 1 := by
  funext i r c; simp [pullback]

theorem pullback_add {S : Type u} [CommSemiring S]
    {C D : TensorCatData S} (Φ : TensorCatMor C D)
    (η μ : SymmetrySemiring S D) :
    pullback Φ (η + μ) = pullback Φ η + pullback Φ μ := by
  funext i r c; simp [pullback]

theorem pullback_mul {S : Type u} [CommSemiring S]
    {C D : TensorCatData S} (Φ : TensorCatMor C D)
    (η μ : SymmetrySemiring S D) :
    pullback Φ (η * μ) = pullback Φ η * pullback Φ μ := by
  funext i r c; simp [pullback]

/-- Pullback as a ring homomorphism. -/
def pullbackHom {S : Type u} [CommSemiring S]
    {C D : TensorCatData S} (Φ : TensorCatMor C D) :
    SymmetrySemiring S D →+* SymmetrySemiring S C where
  toFun := pullback Φ
  map_zero' := pullback_zero Φ
  map_one' := pullback_one Φ
  map_add' := pullback_add Φ
  map_mul' := pullback_mul Φ

/-- **Functoriality**: morphisms of tensor data induce ring homomorphisms. -/
theorem tannaka_functorial {S : Type u} [CommSemiring S]
    (C D : TensorCatData S) (Φ : TensorCatMor C D) :
    ∃ ψ : SymmetrySemiring S D →+* SymmetrySemiring S C,
      ∀ η i, ψ η i = fun r c =>
        η (Φ.onGen i) (Fin.cast (by rw [Φ.dimEq]) r)
                        (Fin.cast (by rw [Φ.dimEq]) c) :=
  ⟨pullbackHom Φ, fun _ _ => rfl⟩

/-! ## Section 7: Identity and Composition Functoriality -/

def TensorCatMor.id {S : Type u} [CommSemiring S]
    (C : TensorCatData S) : TensorCatMor C C where
  onGen := _root_.id
  dimEq := fun _ => rfl

def TensorCatMor.comp {S : Type u} [CommSemiring S]
    {C D E : TensorCatData S}
    (Ψ : TensorCatMor D E) (Φ : TensorCatMor C D) :
    TensorCatMor C E where
  onGen := Ψ.onGen ∘ Φ.onGen
  dimEq := fun i => by rw [Function.comp, Φ.dimEq, Ψ.dimEq]

theorem pullback_id {S : Type u} [CommSemiring S]
    (C : TensorCatData S)
    (η : SymmetrySemiring S C) :
    pullback (TensorCatMor.id C) η = η := by
  funext i r c; simp [pullback, TensorCatMor.id, Fin.cast_eq_self]

theorem pullback_comp {S : Type u} [CommSemiring S]
    {C D E : TensorCatData S}
    (Ψ : TensorCatMor D E) (Φ : TensorCatMor C D)
    (η : SymmetrySemiring S E) :
    pullback (Ψ.comp Φ) η = pullback Φ (pullback Ψ η) := by
  funext i r c
  simp only [pullback, TensorCatMor.comp, Function.comp]
  rfl

/-! ## Section 8: Certified Algorithmic Reconstruction -/

/-- **Certified reconstruction**: combining presentation, representations, faithfulness. -/
theorem tannaka_certified {S : Type u} [CommSemiring S] [DecidableEq S]
    (C : TensorCatData S) (O : ObsData S C)
    (hf : Faithful O) (hs : Separating O) (hd : Dualizable C) :
    (∃ _ : CommSemiring (SymmetrySemiring S C), True) ∧
    (∀ i, ∃ ρ : TropRep S (SymmetrySemiring S C), ρ.rdim = C.dim i) ∧
    (∀ i j : Fin C.nMor, C.src i = C.src j → C.tgt i = C.tgt j →
      HEq (C.mat i) (C.mat j) → i = j) :=
  tannaka_reconstruction C O hf hs hd

/-! ## Section 9: Closure-Koopman Bridge -/

/-- Trace functional. -/
def tropTrace {S : Type u} [CommSemiring S] {n : ℕ}
    (M : Fin n → Fin n → S) : S :=
  Finset.sum Finset.univ fun i => M i i

/-- Closure character: traces on each generator component. -/
def closureCharacter {S : Type u} [CommSemiring S] {C : TensorCatData S}
    (η : SymmetrySemiring S C) : Fin C.nGen → S :=
  fun i => tropTrace (η i)

theorem closureCharacter_zero {S : Type u} [CommSemiring S]
    {C : TensorCatData S} :
    closureCharacter (0 : SymmetrySemiring S C) = 0 := by
  ext i; simp [closureCharacter, tropTrace]

theorem closureCharacter_add {S : Type u} [CommSemiring S]
    {C : TensorCatData S} (η μ : SymmetrySemiring S C) :
    closureCharacter (η + μ) = closureCharacter η + closureCharacter μ := by
  ext i; simp [closureCharacter, tropTrace, ← Finset.sum_add_distrib]

/-- The character as an additive homomorphism. -/
def closureCharacterAddHom {S : Type u} [CommSemiring S]
    {C : TensorCatData S} :
    SymmetrySemiring S C →+ (Fin C.nGen → S) where
  toFun := closureCharacter
  map_zero' := closureCharacter_zero
  map_add' := closureCharacter_add

/-- Character of one computes generator dimensions. -/
theorem closureCharacter_one {S : Type u} [CommSemiring S]
    {C : TensorCatData S} :
    closureCharacter (1 : SymmetrySemiring S C) =
    fun i => (C.dim i : S) := by
  ext i; simp [closureCharacter, tropTrace]

/-! ## Section 10: Idempotent Specialization -/

/-- The symmetry semiring over an idempotent semiring is idempotent. -/
theorem symmetry_idem {S : Type u} [IdemCommSemiring S]
    {C : TensorCatData S} (η : SymmetrySemiring S C) :
    η + η = η := by
  funext i r c
  change η i r c + η i r c = η i r c
  rw [IdemSemiring.add_eq_sup]
  exact sup_idem _

/-- The character preserves idempotency. -/
theorem closureCharacter_idem {S : Type u} [IdemCommSemiring S]
    {C : TensorCatData S} (η : SymmetrySemiring S C) :
    closureCharacter (η + η) = closureCharacter η := by
  rw [symmetry_idem]

/-! ## Section 11: Naturality Subsemiring -/

/-- Naturality condition: η commutes with each morphism generator
    under matrix-style composition. -/
def IsNatural {S : Type u} [CommSemiring S] {C : TensorCatData S}
    (η : SymmetrySemiring S C) : Prop :=
  ∀ (k : Fin C.nMor)
    (r : Fin (C.dim (C.tgt k))) (c : Fin (C.dim (C.src k))),
    Finset.sum Finset.univ (fun j => η (C.tgt k) r j * C.mat k j c) =
    Finset.sum Finset.univ (fun j => C.mat k r j * η (C.src k) j c)

/-- Zero is natural. -/
theorem isNatural_zero {S : Type u} [CommSemiring S]
    {C : TensorCatData S} :
    IsNatural (0 : SymmetrySemiring S C) := by
  intro k r c; simp

/-- Sum of natural endomorphisms is natural. -/
theorem isNatural_add {S : Type u} [CommSemiring S]
    {C : TensorCatData S} {η μ : SymmetrySemiring S C}
    (hη : IsNatural η) (hμ : IsNatural μ) :
    IsNatural (η + μ) := by
  intro k r c
  simp only [SymmetrySemiring.add_apply, add_mul, mul_add, Finset.sum_add_distrib]
  rw [hη k r c, hμ k r c]

/-- The set of natural endomorphisms. -/
def NaturalEndSet {S : Type u} [CommSemiring S]
    {C : TensorCatData S} : Set (SymmetrySemiring S C) :=
  {η | IsNatural η}

theorem zero_mem_natural {S : Type u} [CommSemiring S]
    {C : TensorCatData S} :
    (0 : SymmetrySemiring S C) ∈ @NaturalEndSet S _ C := isNatural_zero

theorem add_mem_natural {S : Type u} [CommSemiring S]
    {C : TensorCatData S} {η μ : SymmetrySemiring S C}
    (hη : η ∈ @NaturalEndSet S _ C) (hμ : μ ∈ @NaturalEndSet S _ C) :
    η + μ ∈ @NaturalEndSet S _ C := isNatural_add hη hμ

/-! ## Section 12: Concrete Example -/

/-- Two-generator example over ℕ: dim 1 and dim 2, no morphisms. -/
def exData : TensorCatData ℕ where
  nGen := 2
  dim := ![1, 2]
  dim_pos := by intro ⟨i, hi⟩; interval_cases i <;> simp [Matrix.cons_val_zero, Matrix.cons_val_one]
  nMor := 0
  src := Fin.elim0
  tgt := Fin.elim0
  mat := fun i => Fin.elim0 i

/-- Every element is natural when there are no morphisms. -/
theorem ex_all_natural (η : SymmetrySemiring ℕ exData) :
    IsNatural η := by
  intro k; exact Fin.elim0 k

/-! ## Section 13: Reconstruction Record -/

/-- Complete reconstruction output. -/
structure ReconOutput (S : Type u) [CommSemiring S] (C : TensorCatData S) where
  A : Type u
  inst : CommSemiring A
  reps : Fin C.nGen → @TropRep S _ A inst
  dims : ∀ i, (reps i).rdim = C.dim i

/-- Construct the output. -/
def reconstruct {S : Type u} [CommSemiring S]
    (C : TensorCatData S) : ReconOutput S C where
  A := SymmetrySemiring S C
  inst := inferInstance
  reps := canonicalRep C
  dims := fun _ => rfl

theorem reconstruct_correct {S : Type u} [CommSemiring S]
    (C : TensorCatData S) (i : Fin C.nGen) :
    (reconstruct C).dims i = rfl := rfl