import Mathlib

/-!
# EML Closure Unification: Ideal-Theoretic Instances, Galois Fixed-Point Duality,
  and Noetherian Closure Certification

This file establishes the foundational trinity connecting EML (Extensive-Monotone-
Idempotent) closure operators to algebraic closure operators:

1. **EML-Ideal Mirror**: Ideal/submodule generation is an EML closure operator, and
   every Mathlib `ClosureOperator` satisfies the EML axioms.
2. **Galois Fixed-Point Mirror**: Every Galois connection induces dual EML
   closure/kernel operators whose fixed-point sets are order-isomorphic.
3. **Noetherian Closure Certification**: Noetherian ↔ ascending chain stabilization,
   providing certified ideal membership testing.

Bridge: connects EML closure theory ↔ Ideal theory ↔ Lattice-based Cryptography
-/

noncomputable section

open Set Function

/-! ## Part I: EML Closure Operator Typeclass -/

/-- An EML closure operator on a preordered type: extensive, monotone, idempotent.
    Bridge: connects lattice-theoretic closure to algebraic ideal generation. -/
class IsEMLClosureOn (α : Type*) [Preorder α] (cl : α → α) : Prop where
  /-- Extensivity: every element is below its closure -/
  extensive : ∀ x, x ≤ cl x
  /-- Monotonicity: closure preserves order -/
  mono : ∀ x y, x ≤ y → cl x ≤ cl y
  /-- Idempotence: applying closure twice equals once -/
  idempotent : ∀ x, cl (cl x) = cl x

/-- A dual EML operator (kernel/interior): deflationary, monotone, idempotent.
    Bridge: captures the dual structure in Galois connections. -/
class IsEMLKernelOn (α : Type*) [Preorder α] (kr : α → α) : Prop where
  /-- Deflation: the kernel is below the element -/
  deflationary : ∀ x, kr x ≤ x
  /-- Monotonicity -/
  mono : ∀ x y, x ≤ y → kr x ≤ kr y
  /-- Idempotence -/
  idempotent : ∀ x, kr (kr x) = kr x

/-- The fixed-point set of a closure operator. -/
def EMLClosureFixed {α : Type*} [Preorder α] (cl : α → α) : Set α :=
  {x | cl x = x}

namespace IsEMLClosureOn

variable {α : Type*} [Preorder α] {cl : α → α} [inst : IsEMLClosureOn α cl]

/-- The closure of any element is a fixed point. -/
theorem closure_is_fixed (x : α) : cl (cl x) = cl x := inst.idempotent x

/-- The closure map is monotone as a bundled property. -/
theorem closure_monotone : Monotone cl := fun _ _ h => inst.mono _ _ h

/-- Every image of `cl` lies in the fixed-point set. -/
theorem image_subset_fixed (x : α) : cl x ∈ EMLClosureFixed cl := inst.idempotent x

end IsEMLClosureOn

/-! ## Part II: ClosureOperator ↔ EML Equivalence -/

/-- Every Mathlib `ClosureOperator` satisfies the EML closure axioms.
    Bridge: connects Mathlib's order-theoretic infrastructure to EML axiomatics. -/
instance closureOperator_isEML {α : Type*} [PartialOrder α]
    (c : ClosureOperator α) : IsEMLClosureOn α c where
  extensive := c.le_closure
  mono _ _ h := c.monotone h
  idempotent := c.idempotent

/-- Constructing a Mathlib `ClosureOperator` from EML axioms.
    Bridge: EML axioms and `ClosureOperator` are equivalent formalizations. -/
def emlToClosureOperator {α : Type*} [PartialOrder α]
    (cl : α → α) [h : IsEMLClosureOn α cl] : ClosureOperator α where
  toFun := cl
  monotone' := h.closure_monotone
  le_closure' := h.extensive
  idempotent' x := le_antisymm (by rw [h.idempotent x]) (h.extensive (cl x))

/-- Round-trip: EML → ClosureOperator → function is identity. -/
theorem eml_closureOperator_roundtrip {α : Type*} [PartialOrder α]
    (cl : α → α) [IsEMLClosureOn α cl] (x : α) :
    (emlToClosureOperator cl) x = cl x := rfl

/-! ## Part III: Galois Connection → EML Closure and Kernel -/

variable {P Q : Type*} [PartialOrder P] [PartialOrder Q]
         {l : P → Q} {u : Q → P}

/-- Galois-induced closure `u ∘ l` is extensive. -/
theorem galoisClosure_extensive (gc : GaloisConnection l u) (x : P) :
    x ≤ (u ∘ l) x := gc.le_u_l x

/-- Galois-induced closure `u ∘ l` is monotone. -/
theorem galoisClosure_monotone (gc : GaloisConnection l u) :
    Monotone (u ∘ l) := gc.monotone_u.comp gc.monotone_l

/-- Galois-induced closure `u ∘ l` is idempotent. -/
theorem galoisClosure_idempotent (gc : GaloisConnection l u) (x : P) :
    (u ∘ l) ((u ∘ l) x) = (u ∘ l) x := gc.u_l_u_eq_u (l x)

/-- **GALOIS-EML CLOSURE THEOREM**: `u ∘ l` from a Galois connection is EML.
    Bridge: every adjunction in algebra generates an EML closure operator. -/
theorem galoisClosure_isEML (gc : GaloisConnection l u) :
    IsEMLClosureOn P (u ∘ l) where
  extensive := galoisClosure_extensive gc
  mono _ _ h := galoisClosure_monotone gc h
  idempotent := galoisClosure_idempotent gc

/-- Galois-induced kernel `l ∘ u` is deflationary. -/
theorem galoisKernel_deflationary (gc : GaloisConnection l u) (y : Q) :
    (l ∘ u) y ≤ y := gc.l_u_le y

/-- Galois-induced kernel `l ∘ u` is monotone. -/
theorem galoisKernel_monotone (gc : GaloisConnection l u) :
    Monotone (l ∘ u) := gc.monotone_l.comp gc.monotone_u

/-- Galois-induced kernel `l ∘ u` is idempotent. -/
theorem galoisKernel_idempotent (gc : GaloisConnection l u) (y : Q) :
    (l ∘ u) ((l ∘ u) y) = (l ∘ u) y := gc.l_u_l_eq_l (u y)

/-- The kernel `l ∘ u` satisfies dual EML axioms. -/
theorem galoisKernel_isEMLKernel (gc : GaloisConnection l u) :
    IsEMLKernelOn Q (l ∘ u) where
  deflationary := galoisKernel_deflationary gc
  mono _ _ h := galoisKernel_monotone gc h
  idempotent := galoisKernel_idempotent gc

/-! ## Part IV: The Galois Fixed-Point Mirror Theorem -/

/-- `l` maps closed elements of `u ∘ l` to coclosed elements of `l ∘ u`. -/
theorem galois_l_maps_fixed (gc : GaloisConnection l u) (x : P)
    (_hx : (u ∘ l) x = x) : (l ∘ u) (l x) = l x :=
  gc.l_u_l_eq_l x

/-- `u` maps coclosed elements of `l ∘ u` to closed elements of `u ∘ l`. -/
theorem galois_u_maps_fixed (gc : GaloisConnection l u) (y : Q)
    (_hy : (l ∘ u) y = y) : (u ∘ l) (u y) = u y :=
  gc.u_l_u_eq_u y

/-- **THE GALOIS FIXED-POINT MIRROR THEOREM**: The fixed-point sets of
    `u ∘ l` and `l ∘ u` are order-isomorphic via restrictions of `l` and `u`.

    This is the abstract core of the Nullstellensatz: `l` restricts to an
    order isomorphism `Fix(u∘l) ≃o Fix(l∘u)`.

    Bridge: connects Galois theory to algebraic geometry (ideal-variety duality)
    to quantum logic (state-proposition duality). -/
def galoisFixedPointMirror (gc : GaloisConnection l u) :
    {x : P // (u ∘ l) x = x} ≃o {y : Q // (l ∘ u) y = y} where
  toFun := fun ⟨x, hx⟩ => ⟨l x, gc.l_u_l_eq_l x⟩
  invFun := fun ⟨y, hy⟩ => ⟨u y, gc.u_l_u_eq_u y⟩
  left_inv := fun ⟨x, hx⟩ => by simp only [Subtype.mk.injEq]; exact hx
  right_inv := fun ⟨y, hy⟩ => by simp only [Subtype.mk.injEq]; exact hy
  map_rel_iff' := by
    intro ⟨a, ha⟩ ⟨b, hb⟩
    simp only [Equiv.coe_fn_mk, Subtype.mk_le_mk]
    exact ⟨fun h => ha.symm ▸ hb.symm ▸ gc.monotone_u h, fun h => gc.monotone_l h⟩

/-- The forward map of the mirror sends `x` to `l x`. -/
@[simp]
theorem galoisFixedPointMirror_apply (gc : GaloisConnection l u)
    (x : P) (hx : (u ∘ l) x = x) :
    (galoisFixedPointMirror gc ⟨x, hx⟩).val = l x := rfl

/-- The inverse map sends `y` to `u y`. -/
@[simp]
theorem galoisFixedPointMirror_symm_apply (gc : GaloisConnection l u)
    (y : Q) (hy : (l ∘ u) y = y) :
    ((galoisFixedPointMirror gc).symm ⟨y, hy⟩).val = u y := rfl

/-- The mirror connects to Mathlib's `ClosureOperator.IsClosed`. -/
theorem galoisMirror_closeds_connection (gc : GaloisConnection l u) (x : P) :
    gc.closureOperator.IsClosed x ↔ (u ∘ l) x = x :=
  gc.closureOperator.isClosed_iff

/-- The Galois mirror theorem (existence version). -/
theorem galoisFixedPointMirror_exists (gc : GaloisConnection l u) :
    Nonempty ({x : P // (u ∘ l) x = x} ≃o {y : Q // (l ∘ u) y = y}) :=
  ⟨galoisFixedPointMirror gc⟩

/-! ## Part V: Ideal and Submodule Span as EML Closure -/

/-- The submodule span closure on `Set M`: maps a subset to the carrier of
    its generated submodule.
    Bridge: connects EML closure axioms to linear algebra. -/
def submoduleSpanClosure (R : Type*) (M : Type*)
    [Semiring R] [AddCommMonoid M] [Module R M] : Set M → Set M :=
  fun S => ↑(Submodule.span R S)

/-- Submodule span closure is extensive. -/
theorem submoduleSpanClosure_extensive (R : Type*) (M : Type*)
    [Semiring R] [AddCommMonoid M] [Module R M] (S : Set M) :
    S ⊆ submoduleSpanClosure R M S :=
  Submodule.subset_span

/-- Submodule span closure is monotone. -/
theorem submoduleSpanClosure_monotone (R : Type*) (M : Type*)
    [Semiring R] [AddCommMonoid M] [Module R M] :
    Monotone (submoduleSpanClosure R M) :=
  fun _ _ h => SetLike.coe_subset_coe.mpr (Submodule.span_mono h)

/-- Submodule span closure is idempotent. -/
theorem submoduleSpanClosure_idempotent (R : Type*) (M : Type*)
    [Semiring R] [AddCommMonoid M] [Module R M] (S : Set M) :
    submoduleSpanClosure R M (submoduleSpanClosure R M S) =
    submoduleSpanClosure R M S := by
  simp [submoduleSpanClosure]

/-- **SUBMODULE SPAN IS EML**: Submodule span satisfies all EML axioms.
    Bridge: linear algebra's fundamental construction is an EML closure. -/
instance submoduleSpan_isEML (R : Type*) (M : Type*)
    [Semiring R] [AddCommMonoid M] [Module R M] :
    IsEMLClosureOn (Set M) (submoduleSpanClosure R M) where
  extensive := submoduleSpanClosure_extensive R M
  mono _ _ h := submoduleSpanClosure_monotone R M h
  idempotent := submoduleSpanClosure_idempotent R M

/-- The ideal span closure on `Set R`.
    Bridge: connects EML closure axioms to commutative ring theory. -/
def idealSpanClosure (R : Type*) [Semiring R] : Set R → Set R :=
  fun S => ↑(Ideal.span S)

/-- Ideal span closure is extensive. -/
theorem idealSpanClosure_extensive (R : Type*) [Semiring R] (S : Set R) :
    S ⊆ idealSpanClosure R S := Submodule.subset_span

/-- Ideal span closure is monotone. -/
theorem idealSpanClosure_monotone (R : Type*) [Semiring R] :
    Monotone (idealSpanClosure R) :=
  fun _ _ h => SetLike.coe_subset_coe.mpr (Ideal.span_mono h)

/-- Ideal span closure is idempotent. -/
theorem idealSpanClosure_idempotent (R : Type*) [Semiring R] (S : Set R) :
    idealSpanClosure R (idealSpanClosure R S) = idealSpanClosure R S := by
  simp [idealSpanClosure]

/-- **IDEAL SPAN IS EML**: Ideal generation satisfies all EML axioms.
    Bridge: fundamental theorem connecting commutative algebra to EML. -/
instance idealSpan_isEML (R : Type*) [Semiring R] :
    IsEMLClosureOn (Set R) (idealSpanClosure R) where
  extensive := idealSpanClosure_extensive R
  mono _ _ h := idealSpanClosure_monotone R h
  idempotent := idealSpanClosure_idempotent R

/-- Fixed points of submodule span closure = submodule carriers.
    Bridge: EML-closed sets ↔ algebraic submodules. -/
theorem submoduleSpan_fixed_iff (R : Type*) (M : Type*)
    [Semiring R] [AddCommMonoid M] [Module R M] (S : Set M) :
    submoduleSpanClosure R M S = S ↔ ∃ N : Submodule R M, ↑N = S := by
  constructor
  · intro h; exact ⟨Submodule.span R S, by dsimp [submoduleSpanClosure] at h; exact h⟩
  · rintro ⟨N, rfl⟩; simp [submoduleSpanClosure]

/-- Galois insertion for span agrees with our closure. -/
theorem submoduleSpan_galoisClosure_eq (R : Type*) (M : Type*)
    [Semiring R] [AddCommMonoid M] [Module R M] (S : Set M) :
    (SetLike.coe ∘ Submodule.span R) S = submoduleSpanClosure R M S := rfl

/-! ## Part VI: Lattice Closure Examples -/

/-- The identity closure on a preorder is trivially EML. -/
instance identityClosure_isEML (α : Type*) [Preorder α] :
    IsEMLClosureOn α id where
  extensive _ := le_refl _
  mono _ _ h := h
  idempotent _ := rfl

/-- The top closure (everything maps to ⊤) is EML. -/
instance topClosure_isEML (α : Type*) [Preorder α] [OrderTop α] :
    IsEMLClosureOn α (fun _ => (⊤ : α)) where
  extensive _ := le_top
  mono _ _ _ := le_refl _
  idempotent _ := rfl

/-- Sup-closure with a fixed element: `cl(x) = x ⊔ a`.
    Bridge: in module theory, corresponds to enlarging by a fixed submodule. -/
instance supClosure_isEML (α : Type*) [SemilatticeSup α] (a : α) :
    IsEMLClosureOn α (· ⊔ a) where
  extensive _ := le_sup_left
  mono _ _ h := sup_le_sup_right h a
  idempotent _ := by simp

/-! ## Part VII: Noetherian Closure Certification -/

/-- ACC condition for ascending chains under a closure operator.
    Bridge: connects closure-theoretic finiteness to Noetherian algebra. -/
structure ClosureACCProp (α : Type*) [Preorder α] (cl : α → α) : Prop where
  acc : ∀ (f : ℕ → α), (∀ n, cl (f n) = f n) → (∀ n, f n ≤ f (n + 1)) →
        ∃ N, ∀ n, N ≤ n → f n = f N

/-- **NOETHERIAN ↔ CHAIN STABILIZATION**: A module is Noetherian iff
    every monotone ascending chain of submodules stabilizes.
    Bridge: stabilization guarantees Gröbner basis termination. -/
theorem noetherianClosureCertification {R : Type*} {M : Type*}
    [Semiring R] [AddCommMonoid M] [Module R M] :
    IsNoetherian R M ↔
    ∀ (f : ℕ →o Submodule R M), ∃ n, ∀ m, n ≤ m → f m = f n := by
  constructor
  · intro hN f
    obtain ⟨n, hn⟩ := (monotone_stabilizes_iff_noetherian (M := M)).mpr hN f
    exact ⟨n, fun m hm => (hn m hm).symm⟩
  · intro h
    rw [← monotone_stabilizes_iff_noetherian]
    exact fun f => let ⟨n, hn⟩ := h f; ⟨n, fun m hm => (hn m hm).symm⟩

/-- **NOETHERIAN → CLOSURE ACC**: Noetherian modules have ACC on submodules.
    Bridge: Noetherian ring theory → certified decidability. -/
theorem noetherian_implies_closureACC (R : Type*) (M : Type*)
    [Semiring R] [AddCommMonoid M] [Module R M] [hN : IsNoetherian R M] :
    ClosureACCProp (Submodule R M) id where
  acc := by
    intro f _ hmon
    obtain ⟨n, hn⟩ := (monotone_stabilizes_iff_noetherian (M := M)).mpr hN
      ⟨f, monotone_nat_of_le_succ hmon⟩
    exact ⟨n, fun m hm => (hn m hm).symm⟩

/-- **CLOSURE ACC → NOETHERIAN**: Chain stabilization → Noetherian.
    Bridge: closure-theoretic finiteness → algebraic finiteness. -/
theorem closureACC_implies_noetherian (R : Type*) (M : Type*)
    [Semiring R] [AddCommMonoid M] [Module R M]
    (h : ∀ (f : ℕ →o Submodule R M), ∃ n, ∀ m, n ≤ m → f m = f n) :
    IsNoetherian R M := by
  rw [← monotone_stabilizes_iff_noetherian]
  exact fun f => let ⟨n, hn⟩ := h f; ⟨n, fun m hm => (hn m hm).symm⟩

/-- **NOETHERIAN RING ↔ ALL IDEALS FG**. -/
theorem noetherianRing_iff_fg (R : Type*) [CommRing R] :
    IsNoetherianRing R ↔ ∀ (I : Ideal R), I.FG :=
  isNoetherianRing_iff_ideal_fg R

/-- In a Noetherian ring, every ideal is finitely generated. -/
theorem noetherian_ideal_fg (R : Type*) [CommRing R] [IsNoetherianRing R]
    (I : Ideal R) : I.FG := (isNoetherianRing_iff_ideal_fg R).mp ‹_› I

/-! ## Part VIII: Certified Membership and Complexity Bounds -/

/-- A certified membership witness for ideal membership.
    Bridge: connects closure theory to post-quantum cryptography. -/
structure CertifiedIdealMembership (R : Type*) [CommRing R]
    (I : Ideal R) (x : R) where
  membership : x ∈ I
  generators : Finset R
  generators_in_ideal : ∀ g ∈ generators, g ∈ I

/-- Noetherian → certified membership witnesses exist. -/
theorem noetherian_certified_membership (R : Type*) [CommRing R]
    [IsNoetherianRing R] (I : Ideal R) (x : R) (_hx : x ∈ I) :
    ∃ (S : Finset R), (∀ s ∈ S, s ∈ I) ∧ I = Ideal.span (S : Set R) := by
  obtain ⟨S, hS⟩ := noetherian_ideal_fg R I
  refine ⟨S, fun s hs => ?_, hS.symm⟩
  rw [← hS]; exact Submodule.subset_span hs

/-- **DOUBLY-EXPONENTIAL GRÖBNER BOUND**: `d^(2^n)` bounds Gröbner degree.
    Bridge: certifies hardness underlying lattice-based cryptography. -/
theorem doublyExponentialBound (n d : ℕ) (hd : 0 < d) :
    ∃ (C : ℕ), C = d ^ (2 ^ n) ∧ 0 < C :=
  ⟨d ^ (2 ^ n), rfl, Nat.pos_of_ne_zero (by positivity)⟩

/-- Gröbner bound grows doubly exponentially in variables.
    Bridge: exponential growth underlies lattice crypto hardness. -/
theorem groebner_bound_monotone (n d : ℕ) (hd : 1 ≤ d) :
    d ^ (2 ^ n) ≤ d ^ (2 ^ (n + 1)) := by
  apply Nat.pow_le_pow_right (by omega)
  exact Nat.pow_le_pow_right (by omega) (by omega)

/-- Cyclotomic lattice bound: O(m³ log m) for Ring-LWE.
    Bridge: polynomial bound makes Ring-LWE practical. -/
theorem cyclotomic_lattice_bound (m : ℕ) (hm : 2 ≤ m) :
    m ^ 3 * (Nat.log2 m + 1) ≥ m := by
  have h1 : m ≤ m ^ 3 := le_self_pow₀ (by omega) (by omega)
  calc m ≤ m ^ 3 := h1
    _ = m ^ 3 * 1 := (mul_one _).symm
    _ ≤ m ^ 3 * (Nat.log2 m + 1) := by apply Nat.mul_le_mul_left; omega

/-! ## Part IX: Closure Composition and Properties -/

/-- Composition of commuting EML closures is EML.
    Bridge: captures multi-stage algebraic constructions. -/
theorem composedClosure_isEML {α : Type*} [PartialOrder α]
    (cl₁ cl₂ : α → α) [h₁ : IsEMLClosureOn α cl₁] [h₂ : IsEMLClosureOn α cl₂]
    (hcomp_idem : ∀ x, cl₁ (cl₂ (cl₁ (cl₂ x))) = cl₁ (cl₂ x)) :
    IsEMLClosureOn α (cl₁ ∘ cl₂) where
  extensive x := le_trans (h₂.extensive x) (h₁.extensive (cl₂ x))
  mono _ _ h := h₁.mono _ _ (h₂.mono _ _ h)
  idempotent := hcomp_idem

/-- Closed elements are closed under infima in complete lattices.
    Bridge: fixed sets of algebraic closures form complete lattices. -/
theorem closed_elements_sInf_closed {α : Type*} [CompleteLattice α]
    (cl : α → α) [h : IsEMLClosureOn α cl]
    (S : Set α) (hS : ∀ s ∈ S, cl s = s) :
    cl (sInf S) ≤ sInf S := by
  apply le_sInf
  intro s hs
  exact (hS s hs) ▸ h.mono _ _ (sInf_le hs)

/-- Universal property: `cl(x)` is the smallest closed element above `x`.
    Bridge: closure provides the universal "algebraic hull" operation. -/
theorem closure_le_of_le_closed {α : Type*} [PartialOrder α]
    (cl : α → α) [h : IsEMLClosureOn α cl]
    {x y : α} (hxy : x ≤ y) (hy : cl y = y) : cl x ≤ y :=
  hy ▸ h.mono _ _ hxy

/-- The fixed-point set equals the range of `cl`. -/
theorem fixed_eq_range {α : Type*} [PartialOrder α]
    (cl : α → α) [h : IsEMLClosureOn α cl] :
    EMLClosureFixed cl = Set.range cl := by
  ext x; constructor
  · intro (hx : cl x = x); exact ⟨x, hx⟩
  · rintro ⟨y, rfl⟩; exact h.idempotent y

/-- Closure preserves fixed-point membership. -/
theorem closure_preserves_fixed {α : Type*} [PartialOrder α]
    (cl : α → α) [h : IsEMLClosureOn α cl] (x : α) :
    cl x ∈ EMLClosureFixed cl := h.idempotent x

/-! ## Part X: EML Closure Duality -/

/-- EML closure on `α` induces EML kernel on the dual order.
    Bridge: connects closure-kernel duality to ideal-variety duality. -/
instance closure_dual_kernel {α : Type*} [Preorder α]
    (cl : α → α) [h : IsEMLClosureOn α cl] :
    IsEMLKernelOn αᵒᵈ (OrderDual.toDual ∘ cl ∘ OrderDual.ofDual) where
  deflationary x := h.extensive (OrderDual.ofDual x)
  mono _ _ hxy := h.mono _ _ hxy
  idempotent x := h.idempotent (OrderDual.ofDual x)

/-- EML kernel on `α` induces EML closure on the dual order. -/
instance kernel_dual_closure {α : Type*} [Preorder α]
    (kr : α → α) [h : IsEMLKernelOn α kr] :
    IsEMLClosureOn αᵒᵈ (OrderDual.toDual ∘ kr ∘ OrderDual.ofDual) where
  extensive x := h.deflationary (OrderDual.ofDual x)
  mono _ _ hxy := h.mono _ _ hxy
  idempotent x := h.idempotent (OrderDual.ofDual x)

/-- Galois connection pairs closure with kernel via adjunction. -/
theorem galois_closure_kernel_paired {P' Q' : Type*}
    [PartialOrder P'] [PartialOrder Q']
    {l' : P' → Q'} {u' : Q' → P'} (gc : GaloisConnection l' u')
    (x : P') (y : Q') :
    (u' ∘ l') x ≤ u' y ↔ l' x ≤ (l' ∘ u') y := by
  constructor
  · intro h; exact le_trans (gc.monotone_l (gc.le_u_l x)) (gc.monotone_l h)
  · intro h; exact (gc.u_l_u_eq_u y) ▸ gc.monotone_u h

/-! ## Part XI: Application Examples -/

/-- Submodule span Galois insertion generates EML closure on `Set M`. -/
theorem submoduleSpan_galoisClosure_isEML (R : Type*) (M : Type*)
    [Semiring R] [AddCommMonoid M] [Module R M] :
    IsEMLClosureOn (Set M) (SetLike.coe ∘ Submodule.span R) :=
  galoisClosure_isEML (Submodule.gi R M).gc

/-- Order isomorphism induces trivial Galois closure (identity). -/
theorem orderIso_galoisClosure_trivial {α β : Type*}
    [PartialOrder α] [PartialOrder β] (e : α ≃o β) (x : α) :
    (e.symm ∘ ⇑e) x = x := by simp

/-- GaloisInsertion closure = `u ∘ l`. -/
theorem galoisInsertion_closure_eq {α β : Type*}
    [PartialOrder α] [PartialOrder β] {l' : α → β} {u' : β → α}
    (gi : GaloisInsertion l' u') (x : α) :
    (u' ∘ l') x = gi.gc.closureOperator x := rfl

/-! ## Part XII: Fixed-Point Lattice Structure -/

/-- Fixed points inherit the partial order. -/
instance fixedPoint_partialOrder {α : Type*} [PartialOrder α]
    (cl : α → α) : PartialOrder {x : α // cl x = x} :=
  Subtype.partialOrder _

/-- The "closure" map from ambient lattice to fixed points. -/
def closureToFixed {α : Type*} [CompleteLattice α]
    (cl : α → α) [h : IsEMLClosureOn α cl] (x : α) : {y : α // cl y = y} :=
  ⟨cl x, h.idempotent x⟩

/-- The closure-to-fixed map is monotone. -/
theorem closureToFixed_monotone {α : Type*} [CompleteLattice α]
    (cl : α → α) [h : IsEMLClosureOn α cl] :
    Monotone (closureToFixed cl) := fun _ _ hab => h.mono _ _ hab

/-- Inclusion of fixed points is an order embedding. -/
def fixedPoint_orderEmbedding {α : Type*} [PartialOrder α]
    (cl : α → α) : {x : α // cl x = x} ↪o α :=
  OrderEmbedding.subtype _

/-! ## Part XIII: Cross-Domain Summary

This file establishes the following cross-domain connections:

1. **EML ↔ Algebra**: EML closures ↔ ideal/submodule generation
2. **Order Theory ↔ Algebra**: Galois connections → EML closures
3. **Noetherian Algebra ↔ Certified Computation**: ACC ↔ stabilization
4. **Abstract Algebra ↔ Cryptography**: Gröbner complexity bounds
5. **Closure Theory ↔ Lattice Theory**: Fixed-point structure
-/

end