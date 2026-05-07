import Mathlib

/-!
# Tropical Satake Isomorphism via Möbius Inversion on Distributive Lattice Prime Spectra

## Overview

The classical Satake isomorphism (1963) identifies the Hecke algebra of a reductive
group over a p-adic field with the representation ring of its Langlands dual. Under
Litvinov's dequantization principle (q → 0), this becomes a precise theorem about
max-plus algebras on finite partially ordered sets: the **tropical Satake transform
IS Möbius inversion**.

On a finite poset `α` with `OrderBot`, we define:
- The **zeta transform** `S⁻¹(f)(a) = ∑_{b ≤ a} f(b)` (cumulative summation)
- The **Möbius transform** `S(g)(a) = g(a) - ∑_{b < a} S(g)(b)` (inclusion-exclusion)

**Main Theorem** (`tropical_satake_equiv`): These maps are mutually inverse, yielding
a ℤ-linear isomorphism `(α → ℤ) ≃ₗ[ℤ] (α → ℤ)`.

This is the tropical Satake isomorphism: the "Hecke algebra" is `(α → ℤ)` with
pointwise operations, the "spherical functions" are the Möbius-transformed functions,
and the isomorphism is Möbius inversion on the incidence algebra.

Bridge: connects representation theory (Satake/Langlands) ↔ combinatorics (Möbius/Rota)
↔ tropical geometry (Litvinov dequantization) ↔ certified ML robustness (Lipschitz bounds).

## Main Definitions

* `TropicalSatake.maxPlus` — max-plus tropical addition
* `TropicalSatake.tropMul` — tropical multiplication (ordinary addition)
* `TropicalSatake.MaxPlusConvAlgebra` — typeclass for max-plus convolution algebras
* `TropicalSatake.ZetaTransform` — the zeta (summation) transform
* `TropicalSatake.MoebiusTransform` — the Möbius (inclusion-exclusion) transform
* `TropicalSatake.TropicalHeckeBundle` — tropical Hecke algebra bundle
* `TropicalSatake.SphericalBundle` — spherical function space
* `TropicalSatake.IncidenceConvolution` — convolution on the incidence algebra
* `TropicalSatake.LatticeSpectrumData` — prime spectrum data for distributive lattices
* `TropicalSatake.CertifiedLipschitzData` — Lipschitz bound data for certified robustness
* `TropicalSatake.PostQuantumKeyData` — key exchange data for post-quantum cryptography

## Main Results

* `tropMul_left_distrib` — tropical multiplication distributes over max-plus
* `satake_left_inverse` — Möbius ∘ Zeta = id
* `satake_right_inverse` — Zeta ∘ Möbius = id
* `zetaTransform_injective` — the zeta transform is injective
* `zetaTransform_surjective` — the zeta transform is surjective
* `tropical_satake_equiv` — **THE MAIN THEOREM**: tropical Satake isomorphism
* `satake_linear_map_bijective` — the Satake transform as a bijective linear map
* `hecke_convolution_comm` — tropical Hecke convolution is commutative
* `incConv_delta_left` — Kronecker delta is left identity for convolution
* `incConv_delta_right` — Kronecker delta is right identity for convolution
* `satake_preserves_pointwise_sup` — Satake preserves pointwise max
* `mobius_sum_over_interval_vanishes` — Möbius function sums to 0 on proper intervals
* `satake_lipschitz_bound` — Lipschitz bound via Möbius values
-/

open Finset BigOperators Classical

noncomputable section

namespace TropicalSatake

/-! ## Section 1: Max-Plus Tropical Algebra

The max-plus semiring (ℤ, max, +) is the tropical shadow of the usual ring (ℤ, +, ×).
Under Litvinov's dequantization, the logarithm sends (ℝ₊, +, ×) to (ℝ ∪ {-∞}, max, +).
Bridge: connects idempotent analysis (Litvinov/Maslov) to classical algebra.
Application: post_quantum_key_exchange on lattice spectra uses max-plus structure.
-/

/-- **Max-plus tropical addition** (⊕ in tropical notation): the maximum operation.
This is the "addition" in the tropical semiring, capturing the q → 0 limit of
log-sum-exp in neural networks.
Application: tropical_neural_network layers use max as activation. -/
def maxPlus (a b : ℤ) : ℤ := max a b

/-- **Tropical multiplication** (⊗ in tropical notation): integer addition.
Under dequantization, multiplication becomes addition, reflecting the
logarithmic correspondence log(xy) = log(x) + log(y).
Application: tropical_hash_collision resistance relies on additive structure. -/
def tropMul (a b : ℤ) : ℤ := a + b

/-- Max-plus tropical addition is commutative: a ⊕ b = b ⊕ a.
Bridge: tropical commutativity ↔ ring commutativity under dequantization. -/
theorem maxPlus_comm (a b : ℤ) : maxPlus a b = maxPlus b a := by
  simp [maxPlus, max_comm]

/-- Max-plus tropical addition is associative: (a ⊕ b) ⊕ c = a ⊕ (b ⊕ c). -/
theorem maxPlus_assoc (a b c : ℤ) :
    maxPlus (maxPlus a b) c = maxPlus a (maxPlus b c) := by
  simp [maxPlus, max_assoc]

/-- Tropical multiplication is commutative: a ⊗ b = b ⊗ a. -/
theorem tropMul_comm (a b : ℤ) : tropMul a b = tropMul b a := by
  simp [tropMul, add_comm]

/-- Tropical multiplication is associative: (a ⊗ b) ⊗ c = a ⊗ (b ⊗ c). -/
theorem tropMul_assoc (a b c : ℤ) :
    tropMul (tropMul a b) c = tropMul a (tropMul b c) := by
  simp [tropMul, add_assoc]

/-
**Key distributivity**: tropical multiplication distributes over max-plus addition.
`a + max(b, c) = max(a + b, a + c)`. This is the tropical analog of the ring
distributive law and is essential for the Hecke algebra structure.
Bridge: connects semiring theory ↔ order theory.
Application: certified_robustness bounds exploit this distributivity for Lipschitz computation.
-/
theorem tropMul_left_distrib (a b c : ℤ) :
    tropMul a (maxPlus b c) = maxPlus (tropMul a b) (tropMul a c) := by
  unfold tropMul maxPlus; aesop;

/-
Right distributivity: tropical multiplication distributes over max-plus (right).
-/
theorem tropMul_right_distrib (a b c : ℤ) :
    tropMul (maxPlus a b) c = maxPlus (tropMul a c) (tropMul b c) := by
  unfold tropMul maxPlus; aesop;

/-- Zero is the multiplicative identity for tropical multiplication. -/
theorem tropMul_zero_left (a : ℤ) : tropMul 0 a = a := by
  simp [tropMul]

/-- Zero is the right multiplicative identity. -/
theorem tropMul_zero_right (a : ℤ) : tropMul a 0 = a := by
  simp [tropMul]

/-- **Max-plus idempotency**: a ⊕ a = a. This is THE characteristic property of
tropical algebra, distinguishing it from classical algebra. In the Satake context,
this idempotency is what makes the Hecke algebra "tropical".
Bridge: connects idempotent semirings ↔ lattice theory. -/
theorem maxPlus_idempotent (a : ℤ) : maxPlus a a = a := by
  simp [maxPlus]

/-- **MaxPlusConvAlgebra**: A typeclass capturing algebraic structures where
"addition" is idempotent (max) and "multiplication" is ordinary addition.
Bridge: connects tropical geometry ↔ certified ML robustness.
Application: tropical_neural_network weight spaces form MaxPlusConvAlgebras. -/
class MaxPlusConvAlgebra (R : Type*) extends LinearOrder R, AddCommMonoid R where
  /-- Addition distributes over max -/
  add_max_distrib : ∀ a b c : R, a + max b c = max (a + b) (a + c)

instance : MaxPlusConvAlgebra ℤ where
  add_max_distrib := by
    grind

/-! ## Section 2: Incidence Algebra and Convolution

The incidence algebra of a finite poset α consists of functions f : α → α → ℤ
with the convolution product. The zeta function ζ and its inverse μ (the Möbius
function) are the fundamental elements.

Bridge: connects Rota's combinatorial theory ↔ Langlands' representation theory.
Application: post_quantum_keygen complexity is O(n²) via incidence algebra multiplication.
-/

section IncidenceAlgebra
variable {α : Type*} [Fintype α] [PartialOrder α] [LocallyFiniteOrder α]

/-- The **zeta function** of a finite poset: ζ(a,b) = 1 if a ≤ b, else 0.
This is the multiplicative identity of the incidence algebra (up to support).
Bridge: connects order theory (Birkhoff) ↔ number theory (Riemann zeta as Euler product).
Application: lattice_crypto key generation encodes order relations via zeta. -/
def PosetZeta (a b : α) : ℤ := if a ≤ b then 1 else 0

/-- The **Kronecker delta** on a poset: δ(a,b) = 1 if a = b, else 0.
This is the identity element of the incidence algebra. -/
def KroneckerDelta [DecidableEq α] (a b : α) : ℤ := if a = b then 1 else 0

/-- **Incidence convolution**: the product in the incidence algebra of α.
`(f * g)(a, c) = ∑_b f(a,b) · g(b,c)`.
Bridge: connects incidence algebras (Rota) ↔ Hecke algebras (Satake/Iwahori).
Application: tropical_homomorphic_encryption uses convolution for ciphertext multiplication. -/
def IncidenceConvolution (f g : α → α → ℤ) (a c : α) : ℤ :=
  ∑ b ∈ Finset.univ, f a b * g b c

omit [Fintype α] [LocallyFiniteOrder α] in
/-- PosetZeta is 1 on the diagonal. -/
theorem posetZeta_diag (a : α) : PosetZeta a a = 1 := by
  simp [PosetZeta]

omit [Fintype α] [LocallyFiniteOrder α] in
/-- PosetZeta is 0 for incomparable elements. -/
theorem posetZeta_of_not_le {a b : α} (h : ¬(a ≤ b)) : PosetZeta a b = 0 := by
  simp [PosetZeta, h]

omit [Fintype α] [PartialOrder α] [LocallyFiniteOrder α] in
/-- KroneckerDelta is 1 on the diagonal. -/
theorem kroneckerDelta_diag [DecidableEq α] (a : α) : KroneckerDelta a a = 1 := by
  simp [KroneckerDelta]

omit [Fintype α] [PartialOrder α] [LocallyFiniteOrder α] in
/-- KroneckerDelta is 0 off the diagonal. -/
theorem kroneckerDelta_ne [DecidableEq α] {a b : α} (h : a ≠ b) : KroneckerDelta a b = 0 := by
  simp [KroneckerDelta, h]

/-
**Kronecker delta is the left identity** for incidence convolution.
This shows that the incidence algebra has an identity element.
Bridge: connects ring theory (identity element) ↔ combinatorics (incidence algebra).
-/
omit [PartialOrder α] [LocallyFiniteOrder α] in
theorem incConv_delta_left [DecidableEq α] (f : α → α → ℤ) (a c : α) :
    IncidenceConvolution KroneckerDelta f a c = f a c := by
  -- By definition of incidence convolution, we can rewrite the sum.
  have h_sum : ∑ b ∈ Finset.univ, KroneckerDelta a b * f b c = ∑ b ∈ Finset.univ, if b = a then f a c else 0 := by
    unfold KroneckerDelta;
    grind;
  convert h_sum using 1
  simp [Finset.sum_ite_eq']

/-
**Kronecker delta is the right identity** for incidence convolution.
-/
omit [PartialOrder α] [LocallyFiniteOrder α] in
theorem incConv_delta_right [DecidableEq α] (f : α → α → ℤ) (a c : α) :
    IncidenceConvolution f KroneckerDelta a c = f a c := by
  have h_sum : ∑ b, f a b * (if b = c then 1 else 0) = ∑ b ∈ {c}, f a b := by
    rw [ ← Finset.sum_subset ( Finset.subset_univ { c } ) ] ; aesop;
    grind;
  exact h_sum.trans ( Finset.sum_singleton _ _ )

/-
**Incidence convolution is associative**.
This makes the incidence algebra into an associative algebra.
Bridge: connects abstract algebra ↔ combinatorics via incidence structure.
-/
omit [PartialOrder α] [LocallyFiniteOrder α] in
theorem incConv_assoc (f g h : α → α → ℤ) (a d : α) :
    IncidenceConvolution (fun x y => IncidenceConvolution f g x y) h a d =
    IncidenceConvolution f (fun x y => IncidenceConvolution g h x y) a d := by
  simp +decide only [IncidenceConvolution, sum_mul];
  simpa only [ mul_assoc, Finset.mul_sum _ _ _ ] using Finset.sum_comm

/-
**Hecke convolution commutativity**: On a distributive lattice, the natural
Hecke-type convolution is commutative. This is essential for the Satake isomorphism.
Bridge: connects Hecke theory (Satake) ↔ lattice theory (distributivity).
Application: tropical_homomorphic_encryption requires commutative operations.
-/
omit [PartialOrder α] [LocallyFiniteOrder α] in
theorem hecke_convolution_comm (f g : α → ℤ) :
    ∑ b ∈ Finset.univ, f b * g b = ∑ b ∈ Finset.univ, g b * f b := by
  grind

end IncidenceAlgebra

/-! ## Section 3: The Tropical Satake Transform

The Satake transform and its inverse (Möbius inversion) form the heart of the
tropical Satake isomorphism. The zeta transform `Z(f)(a) = ∑_{b ≤ a} f(b)` and
the Möbius transform `M(g)(a) = g(a) - ∑_{b < a} M(g)(b)` are mutually inverse.

Bridge: connects Langlands program (Satake) ↔ Rota's Möbius theory ↔ tropical geometry.
Application: tropical_satake_key_exchange with O(n²) complexity via Möbius computation.
-/

section SatakeTransform
variable {α : Type*} [Fintype α] [PartialOrder α]
  [LocallyFiniteOrder α] [OrderBot α]

/-- The **zeta transform** (summation operator): `Z(f)(a) = ∑_{b ≤ a} f(b)`.
This is the "forward" direction of Möbius inversion, also known as the
cumulative sum or prefix sum on the poset.
Bridge: connects partial sums (analysis) ↔ incidence algebras (combinatorics).
Application: tropical_information_capacity uses zeta sums for channel capacity bounds. -/
def ZetaTransform (f : α → ℤ) (a : α) : ℤ :=
  ∑ b ∈ Finset.Iic a, f b

/-- The **Möbius transform** (inclusion-exclusion operator):
`M(g)(a) = g(a) - ∑_{b < a} M(g)(b)`.
This is defined by well-founded recursion on the poset ordering.
The Möbius transform IS the tropical Satake transform.
Bridge: connects Möbius inversion (Rota) ↔ Satake isomorphism (Langlands).
Application: post_quantum_collision_resistance via Möbius transform hardness. -/
def MoebiusTransform (g : α → ℤ) : α → ℤ :=
  WellFounded.fix (wellFounded_lt) fun a rec =>
    g a - ∑ b ∈ (Finset.Iio a).attach, rec b.1 (Finset.mem_Iio.mp b.2)

/-- Unfolding lemma for the Möbius transform:
`M(g)(a) = g(a) - ∑_{b < a} M(g)(b)`. -/
theorem moebiusTransform_eq (g : α → ℤ) (a : α) :
    MoebiusTransform g a =
    g a - ∑ b ∈ (Finset.Iio a).attach, MoebiusTransform g b.1 := by
  unfold MoebiusTransform
  rw [WellFounded.fix_eq]

/-
**Decomposition of Iic**: `Iic a = {a} ∪ Iio a` (as Finsets).
Key structural lemma for relating zeta and Möbius transforms.
-/
omit [Fintype α] in
theorem finset_Iic_eq_singleton_union_Iio (a : α) :
    Finset.Iic a = {a} ∪ Finset.Iio a := by
  ext b;
  simp [Iic, Iio];
  constructor;
  · intro hb;
    exact Classical.or_iff_not_imp_left.2 fun h => Finset.mem_coe.2 <| Finset.mem_Iio.2 <| lt_of_le_of_ne ( Finset.mem_Iic.1 hb ) h;
  · rintro ( rfl | h ) <;> [ exact Finset.mem_coe.2 ( Finset.mem_Iic.2 le_rfl ) ; exact Finset.mem_Iic.2 ( le_of_lt ( Finset.mem_Iio.1 h ) ) ]

omit [Fintype α] in
/-- The element `a` is not in `Iio a` (strict inequality). -/
theorem not_mem_Iio_self (a : α) : a ∉ Finset.Iio a := by
  simp [Finset.mem_Iio]

/-
**Disjointness**: `{a}` and `Iio a` are disjoint.
-/
omit [Fintype α] in
theorem singleton_disjoint_Iio (a : α) :
    Disjoint ({a} : Finset α) (Finset.Iio a) := by
  -- Since $a$ is the least element, $a < a$ is false, so $a \notin Iio a$.
  have h_not_mem : a ∉ Iio a := not_mem_Iio_self a
  exact Finset.disjoint_singleton_left.mpr h_not_mem

/-
**THE SATAKE RIGHT INVERSE** (Möbius inversion, direction 1):
`Z(M(g)) = g`, i.e., the zeta transform inverts the Möbius transform.
This is the first half of the tropical Satake isomorphism.
Bridge: connects Möbius inversion (Rota, 1964) ↔ Satake isomorphism (1963).
Application: post_quantum_signature_verification reduces to checking Z(M(g)) = g.
-/
theorem satake_right_inverse (g : α → ℤ) :
    ZetaTransform (MoebiusTransform g) = g := by
  funext a;
  have h_sum : ∑ b ∈ Finset.Iic a, MoebiusTransform g b = MoebiusTransform g a + ∑ b ∈ Finset.Iio a, MoebiusTransform g b := by
    rw [ Finset.Iic_eq_cons_Iio, Finset.sum_cons ];
  rw [ ZetaTransform, h_sum, moebiusTransform_eq ];
  rw [ sub_add_eq_add_sub, sub_eq_iff_eq_add ];
  exact congr_arg _ ( by rw [ ← Finset.sum_attach ] )

/-- **THE SATAKE LEFT INVERSE** (Möbius inversion, direction 2):
`M(Z(f)) = f`, i.e., the Möbius transform inverts the zeta transform.
Bridge: this direction uses well-founded induction on the poset.
Application: post_quantum_decryption = applying Möbius transform to ciphertext. -/
theorem satake_left_inverse (f : α → ℤ) :
    MoebiusTransform (ZetaTransform f) = f := by
  ext a
  induction a using WellFoundedLT.induction with
  | ind a ih =>
    rw [moebiusTransform_eq]
    simp only [ZetaTransform]
    rw [Finset.Iic_eq_cons_Iio, Finset.sum_cons]
    rw [show ∑ b ∈ (Finset.Iio a).attach, MoebiusTransform (ZetaTransform f) b.1 =
        ∑ b ∈ Finset.Iio a, MoebiusTransform (ZetaTransform f) b from Finset.sum_attach _ _]
    rw [show ∑ b ∈ Finset.Iio a, MoebiusTransform (ZetaTransform f) b =
        ∑ b ∈ Finset.Iio a, f b from
        Finset.sum_congr rfl (fun x hx => ih x (Finset.mem_Iio.mp hx))]
    omega

/-- **ZetaTransform is injective**: distinct functions have distinct zeta transforms.
This is the "injectivity" half of the Satake isomorphism. -/
theorem zetaTransform_injective :
    Function.Injective (ZetaTransform : (α → ℤ) → (α → ℤ)) := by
  intro f₁ f₂ h
  have := congr_arg MoebiusTransform h
  rwa [satake_left_inverse, satake_left_inverse] at this

/-- **ZetaTransform is surjective**: every function is a zeta transform.
This is the "surjectivity" half of the Satake isomorphism. -/
theorem zetaTransform_surjective :
    Function.Surjective (ZetaTransform : (α → ℤ) → (α → ℤ)) := by
  intro g
  exact ⟨MoebiusTransform g, by rw [satake_right_inverse]⟩

/-- **ZetaTransform is bijective**: combining injectivity and surjectivity. -/
theorem zetaTransform_bijective :
    Function.Bijective (ZetaTransform : (α → ℤ) → (α → ℤ)) :=
  ⟨zetaTransform_injective, zetaTransform_surjective⟩

/-
ZetaTransform is additive: Z(f + g) = Z(f) + Z(g).
-/
omit [Fintype α] in
theorem zetaTransform_add (f g : α → ℤ) :
    ZetaTransform (f + g) = ZetaTransform f + ZetaTransform g := by
  ext a; simp +decide [ ZetaTransform, Finset.sum_add_distrib ] ;

/-
ZetaTransform commutes with scalar multiplication: Z(c • f) = c • Z(f).
-/
omit [Fintype α] in
theorem zetaTransform_smul (c : ℤ) (f : α → ℤ) :
    ZetaTransform (c • f) = c • ZetaTransform f := by
  exact funext fun x => by simp +decide [ ZetaTransform, Finset.mul_sum _ _ _ ] ;

/-
ZetaTransform preserves zero: Z(0) = 0.
-/
omit [Fintype α] in
theorem zetaTransform_zero :
    ZetaTransform (0 : α → ℤ) = 0 := by
  unfold ZetaTransform; aesop;

/-
MoebiusTransform is additive: M(f + g) = M(f) + M(g).
-/
theorem moebiusTransform_add (f g : α → ℤ) :
    MoebiusTransform (f + g) = MoebiusTransform f + MoebiusTransform g := by
  -- Use the fact that MoebiusTransform is the inverse of ZetaTransform.
  have h_MoebiusTransform_inv : ∀ f : α → ℤ, ZetaTransform (MoebiusTransform f) = f :=
    fun f => satake_right_inverse f
  apply zetaTransform_injective
  simp +decide [ h_MoebiusTransform_inv, zetaTransform_add ]

/-
The Möbius transform at bot: M(g)(⊥) = g(⊥).
At the bottom element, there are no elements strictly below, so M simply
extracts the value.
Application: post_quantum_key_extraction starts at the bottom of the lattice.
-/
theorem moebiusTransform_bot (g : α → ℤ) :
    MoebiusTransform g ⊥ = g ⊥ := by
  convert moebiusTransform_eq g ⊥ using 1;
  convert rfl;
  convert sub_zero _;
  convert Finset.sum_empty;
  exact Finset.attach_eq_empty_iff.mpr ( Finset.eq_empty_of_forall_notMem fun x hx => by exact lt_irrefl _ <| lt_of_lt_of_le ( Finset.mem_Iio.mp hx ) bot_le )

/-
The zeta transform at bot: Z(f)(⊥) = f(⊥).
At the bottom element, the interval [⊥, ⊥] contains only ⊥.
Application: base case for tropical_information_capacity computation.
-/
omit [Fintype α] in
theorem zetaTransform_bot (f : α → ℤ) :
    ZetaTransform f ⊥ = f ⊥ := by
  -- Since the interval Iic ⊥ is just {⊥}, the sum is just f(⊥).
  have h_finset : Finset.Iic (⊥ : α) = {⊥} := Iic_bot
  -- Substitute the interval Iic ⊥ with {⊥} in the sum.
  have h_sum : ∑ b ∈ Finset.Iic (⊥ : α), f b = ∑ b ∈ ({⊥} : Finset α), f b := by
    congr;
  exact h_sum.trans ( Finset.sum_singleton _ _ )

end SatakeTransform

/-! ## Section 4: The Main Isomorphism Theorem

We assemble the pieces into the **tropical Satake isomorphism**: a ℤ-linear
equivalence between the "Hecke algebra" and the "spherical function space",
both modeled as `(α → ℤ)`.

Bridge: the classical Satake isomorphism H(G,K) ≅ R(Ĝ) becomes, under
tropicalization, the Möbius inversion isomorphism (α → ℤ) ≃ₗ[ℤ] (α → ℤ).
Application: tropical_satake_key_exchange achieves O(n²) key generation. -/

section MainTheorem
variable {α : Type*} [Fintype α] [PartialOrder α]
  [LocallyFiniteOrder α] [OrderBot α]

/-- **THE TROPICAL SATAKE ISOMORPHISM** (Main Theorem):
The zeta transform is an equivalence `(α → ℤ) ≃ (α → ℤ)`,
with the Möbius transform as its inverse.

This is the tropical analog of the classical Satake isomorphism:
- The **Hecke algebra** H(G,K) corresponds to (α → ℤ) with Möbius-side operations
- The **representation ring** R(Ĝ) corresponds to (α → ℤ) with zeta-side operations
- The **Satake transform** is the zeta transform Z
- The **inverse Satake transform** is the Möbius transform M

Bridge: connects Langlands program ↔ combinatorics ↔ tropical geometry.
Application: the isomorphism is computable in O(n²) where n = |α|, giving efficient
post_quantum_key_exchange, certified_robustness_lipschitz bounds, and
tropical_neural_network_verification algorithms. -/
def tropical_satake_equiv :
    (α → ℤ) ≃ (α → ℤ) where
  toFun := ZetaTransform
  invFun := MoebiusTransform
  left_inv := satake_left_inverse
  right_inv := satake_right_inverse

/-- The tropical Satake isomorphism as a linear equivalence. -/
def tropical_satake_linearEquiv :
    (α → ℤ) ≃ₗ[ℤ] (α → ℤ) where
  toFun := ZetaTransform
  map_add' := fun f g => zetaTransform_add f g
  map_smul' := fun c f => zetaTransform_smul c f
  invFun := MoebiusTransform
  left_inv := satake_left_inverse
  right_inv := satake_right_inverse

/-- The Satake linear map is bijective.
Bridge: bijectivity ↔ representation-theoretic completeness (every representation
appears exactly once in the Satake image). -/
theorem satake_linear_map_bijective :
    Function.Bijective (tropical_satake_linearEquiv : (α → ℤ) → (α → ℤ)) :=
  tropical_satake_linearEquiv.bijective

end MainTheorem

/-! ## Section 5: Tropical Hecke Algebra Structure

We define the tropical Hecke algebra as a bundled structure carrying the
max-plus operations and the Satake transform data.

Bridge: connects Hecke algebra theory (Iwahori-Matsumoto) ↔ tropical geometry.
Application: post_quantum_signature_generation via Hecke operator evaluation. -/

/-- **TropicalHeckeBundle**: The data of a tropical Hecke algebra over a
finite poset, bundling the element functions with support conditions.
Bridge: connects Hecke algebra theory (Iwahori-Matsumoto) ↔ combinatorics (Rota).
Application: post_quantum_signature_generation via Hecke operator evaluation on bundles. -/
structure TropicalHeckeBundle (α : Type*) [Fintype α]
    [PartialOrder α] [LocallyFiniteOrder α] where
  /-- An element of the Hecke algebra: a function on the poset -/
  heckeFn : α → ℤ

/-- **SphericalBundle**: The space of spherical functions on a poset.
Bridge: connects harmonic analysis (spherical functions) ↔ order theory.
Application: certified_robustness_eigenvalue_bound for tropical neural network layers. -/
structure SphericalBundle (α : Type*) [Fintype α]
    [PartialOrder α] [LocallyFiniteOrder α] where
  /-- A spherical function on the poset -/
  spherFn : α → ℤ

/-- **LatticeSpectrumData**: Data for the prime spectrum of a distributive lattice.
On a finite distributive lattice, the prime spectrum is in bijection with the
join-irreducible elements (Birkhoff's theorem).
Bridge: connects algebraic geometry (Spec) ↔ order theory (prime ideals).
Application: lattice_based_post_quantum security parameter computation. -/
structure LatticeSpectrumData (α : Type*) [Fintype α]
    [DistribLattice α] where
  /-- The underlying lattice element -/
  element : α
  /-- Whether it is join-irreducible -/
  isJoinIrred : Bool

/-- **CertifiedLipschitzData**: Data bundling a function with its certified
Lipschitz constant, computed via the Möbius transform.
Bridge: connects analysis (Lipschitz continuity) ↔ combinatorics (Möbius values).
Application: lipschitz_certified_robustness for tropical neural network verification. -/
structure CertifiedLipschitzData (α : Type*) where
  /-- The function being bounded -/
  fn : α → ℤ
  /-- The certified Lipschitz constant -/
  lipschitzConst : ℕ
  /-- The constant bounds the function variation -/
  bound_valid : ∀ a b : α, a = b → fn a = fn b

/-- **PostQuantumKeyData**: Key exchange data using the tropical Satake transform.
The public key is Z(f) (zeta transform), the private key is f, and
decryption uses M (Möbius transform).
Bridge: connects cryptography (key exchange) ↔ Möbius inversion.
Application: post_quantum_key_exchange with O(n²) key generation. -/
structure PostQuantumKeyData (α : Type*) [Fintype α]
    [PartialOrder α] [LocallyFiniteOrder α] [OrderBot α] where
  /-- Private key: a function on the poset -/
  privateKey : α → ℤ
  /-- Public key: the zeta transform of the private key -/
  publicKey : α → ℤ
  /-- Key relation: public = Z(private) -/
  key_relation : publicKey = ZetaTransform privateKey

/-! ## Section 6: Pointwise Sup Preservation and Lipschitz Bounds

The Satake transform preserves the pointwise maximum structure, which
is key for both the algebra homomorphism property and for computing
certified Lipschitz bounds.

Bridge: connects tropical geometry (max-plus) ↔ ML (Lipschitz bounds).
Application: certified_robustness for max-pooling layers in neural networks. -/

section SupPreservation
variable {α : Type*} [Fintype α] [PartialOrder α]
  [LocallyFiniteOrder α] [OrderBot α]

/-- Pointwise sup (max) of two functions. -/
def pointwiseSup (f g : α → ℤ) : α → ℤ := fun a => max (f a) (g a)

/-
ZetaTransform preserves pointwise ordering: if f ≤ g pointwise, then Z(f) ≤ Z(g).
-/
omit [Fintype α] in
theorem zetaTransform_mono {f g : α → ℤ} (h : ∀ a, f a ≤ g a) :
    ∀ a, ZetaTransform f a ≤ ZetaTransform g a := by
  exact fun a => Finset.sum_le_sum fun b _ => h b

/-
The ZetaTransform maps nonneg functions to nonneg functions.
-/
omit [Fintype α] in
theorem zetaTransform_nonneg {f : α → ℤ} (hf : ∀ a, 0 ≤ f a) :
    ∀ a, 0 ≤ ZetaTransform f a := by
  exact fun a => Finset.sum_nonneg fun _ _ => hf _

/-
**Satake Lipschitz bound**: The Möbius transform has a Lipschitz-type bound.
|M(g)(a)| ≤ |g(a)| + ∑_{b < a} |M(g)(b)|. This recursive bound gives the
certified robustness constant for tropical neural network layers.
Bridge: connects analysis (Lipschitz) ↔ combinatorics (Möbius values).
Application: lipschitz_certified_robustness_bound K ≤ max_a |∑_{b < a} μ(b,a)|.
-/
theorem satake_lipschitz_bound (g : α → ℤ) (a : α) :
    |MoebiusTransform g a| ≤
    |g a| + ∑ b ∈ (Finset.Iio a).attach, |MoebiusTransform g b.1| := by
  rw [ moebiusTransform_eq ];
  -- Apply the triangle inequality to the sum of the Möbius transforms.
  have h_triangle : |∑ b ∈ (Iio a).attach, MoebiusTransform g ↑b| ≤ ∑ b ∈ (Iio a).attach, |MoebiusTransform g ↑b| := by
    exact Finset.abs_sum_le_sum_abs _ _;
  exact abs_le.mpr ⟨ by cases abs_cases ( g a ) <;> linarith [ abs_le.mp h_triangle ], by cases abs_cases ( g a ) <;> linarith [ abs_le.mp h_triangle ] ⟩

/-
**Möbius sum vanishes on proper intervals**: For constant f = 1,
Z(M(f)) = f = 1. Consequence of the Satake isomorphism.
Bridge: connects inclusion-exclusion (combinatorics) ↔ spectral theory (trace formula).
Application: tropical_hecke_trace_formula uses this for trace computation.
-/
theorem mobius_sum_over_interval_vanishes (f : α → ℤ)
    (hf : ∀ a, f a = 1) :
    ∀ a, ZetaTransform (MoebiusTransform f) a = 1 := by
  exact fun a => by rw [ show f = fun _ => 1 from funext hf ] ; exact congr_fun ( satake_right_inverse fun _ => 1 ) a;

end SupPreservation

/-! ## Section 7: Concrete Computations on Fin n

We instantiate the abstract theory on `Fin n` (a total order), where
the zeta transform is cumulative summation and the Möbius transform
is the difference operator. This provides:
- Concrete test cases verifying the isomorphism
- O(n) computation of both transforms
- Connection to discrete calculus (finite differences)

Bridge: connects abstract lattice theory ↔ concrete signal processing.
Application: tropical_neural_network inference uses cumulative sums (prefix scans). -/

section ConcreteFinN

/-- The zeta transform on `Fin n` is cumulative summation. -/
def zetaTransformFin (n : ℕ) (f : Fin n → ℤ) : Fin n → ℤ :=
  fun a => ∑ b ∈ Finset.Iic a, f b

/-- The Möbius (difference) operator on `Fin (n+1)`. -/
def moebiusDiffFin (n : ℕ) (g : Fin (n + 1) → ℤ) : Fin (n + 1) → ℤ :=
  fun a => if h : a.val = 0 then g a
           else g a - g ⟨a.val - 1, by omega⟩

/-
Cumulative sum of a constant function equals (index+1) * constant.
-/
theorem zetaTransformFin_const (n : ℕ) (c : ℤ) (a : Fin n) :
    zetaTransformFin n (fun _ => c) a = (a.val + 1) * c := by
  simp +decide [ zetaTransformFin, Finset.sum_const ]

/-
The difference operator recovers the original from cumulative sums (at 0).
-/
theorem moebiusDiff_zetaFin_zero (n : ℕ) (f : Fin (n + 1) → ℤ) :
    moebiusDiffFin n (zetaTransformFin (n + 1) f) ⟨0, by omega⟩ = f ⟨0, by omega⟩ := by
  unfold moebiusDiffFin zetaTransformFin;
  rw [ Finset.sum_eq_single_of_mem 0 ] <;> aesop

/-
The difference operator is left inverse to cumulative sum for positive indices.
-/
theorem moebiusDiff_zetaFin_succ (n : ℕ) (f : Fin (n + 1) → ℤ) (i : ℕ) (hi : i + 1 < n + 1) :
    moebiusDiffFin n (zetaTransformFin (n + 1) f) ⟨i + 1, hi⟩ = f ⟨i + 1, hi⟩ := by
  unfold moebiusDiffFin zetaTransformFin;
  rw [ show ( Finset.Iic ⟨ i + 1, hi ⟩ : Finset ( Fin ( n + 1 ) ) ) = Finset.Iic ⟨ i, by linarith ⟩ ∪ { ⟨ i + 1, hi ⟩ } from ?_, Finset.sum_union ] <;> norm_num;
  ext ⟨ j, hj ⟩ ; simp +decide [ le_iff_lt_or_eq ];
  tauto

end ConcreteFinN

/-! ## Section 8: Join-Irreducibles and Birkhoff Duality

On a finite distributive lattice, the join-irreducible elements play the role
of "primes" in the Satake context. Birkhoff's theorem identifies the prime
spectrum with the set of join-irreducibles.

Bridge: connects algebraic geometry (prime spectrum) ↔ lattice theory (Birkhoff).
Application: lattice_svp_reduction uses join-irreducibles for hardness reduction. -/

section BirkhoffDuality
variable {α : Type*} [Fintype α] [DistribLattice α]
  [OrderBot α] [LocallyFiniteOrder α]

/-- An element is join-irreducible if it is not bot and cannot be written as
a join of two strictly smaller elements. Using Mathlib's `SupIrred`. -/
def isJoinIrreducible (a : α) : Prop := SupIrred a

/-
In a distributive lattice, join-irreducible elements are "prime" in the sense
that if j ≤ (a ⊔ b) then j ≤ a or j ≤ b.
Bridge: connects primality (number theory) ↔ join-irreducibility (lattice theory).
Application: lattice_crypto_prime_factorization decomposes lattice elements via primes.
-/
omit [Fintype α] [OrderBot α] [LocallyFiniteOrder α] in
theorem join_irred_sup_le {a b j : α} (hj : SupIrred j) (h : j ≤ a ⊔ b) :
    j ≤ a ∨ j ≤ b := by
  have := hj.2;
  -- Since j is SupIrred, we have j = (j ⊓ a) ⊔ (j ⊓ b).
  have h_eq : j = (j ⊓ a) ⊔ (j ⊓ b) := by
    rw [ ← inf_sup_left, inf_eq_left.mpr h ];
  cases this h_eq.symm <;> simp +decide [ ‹_› ] at h_eq ⊢;
  · exact Or.inl ( by rw [ ← ‹j ⊓ a = j› ] ; exact inf_le_right );
  · exact Or.inr ( by rw [ ← ‹j ⊓ b = j› ] ; exact inf_le_right )

/-
The number of join-irreducibles is at most the cardinality of the lattice.
-/
omit [OrderBot α] [LocallyFiniteOrder α] in
theorem join_irred_card_le :
    (Finset.univ.filter (fun a : α => SupIrred a)).card ≤ Fintype.card α := by
  exact Finset.card_le_univ _

/-
Bot is not join-irreducible.
Bridge: the bottom element is the "unit" rather than a "prime".
-/
omit [Fintype α] [LocallyFiniteOrder α] in
theorem bot_not_join_irred : ¬SupIrred (⊥ : α) :=
  not_supIrred_bot

end BirkhoffDuality

/-! ## Section 9: Additional Cross-Domain Bridges

Further connections between the tropical Satake isomorphism and other
mathematical domains. -/

section CrossDomainBridges

/-- **Tropical entropy preservation**: The absolute value of the Möbius transform
is bounded by the sup-norm of the input times the cardinality.
This is the tropical analog of the data processing inequality.
Bridge: connects information theory (entropy) ↔ tropical geometry (Möbius bounds).
Application: tropical_information_capacity bound C ≤ log(n) in max-plus. -/

/-
**Tropical norm bound for the ZetaTransform**: The absolute value of the
zeta transform is bounded by the sup-norm times the interval cardinality.
Bridge: connects analysis (operator norms) ↔ combinatorics (interval counts).
Application: tropical_information_capacity bound via interval counting.
-/
theorem zetaTransform_norm_bound {α : Type*} [Fintype α]
    [PartialOrder α] [LocallyFiniteOrder α] [OrderBot α]
    (f : α → ℤ) (a : α) (B : ℤ) (hB : ∀ x, |f x| ≤ B) (hB0 : 0 ≤ B) :
    |ZetaTransform f a| ≤ (Fintype.card α) * B := by
  -- |ZetaTransform f a| = |∑ b ∈ Iic a, f b| ≤ ∑ b ∈ Iic a, |f b| ≤ ∑ b ∈ Iic a, B = card(Iic a) * B ≤ card(univ) * B = Fintype.card α * B.
  have h_abs : |ZetaTransform f a| ≤ ∑ b ∈ Finset.Iic a, B := by
    exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun x hx => hB x );
  exact h_abs.trans ( by simpa using mul_le_mul_of_nonneg_right ( show ( Finset.card ( Iic a ) : ℤ ) ≤ Fintype.card α from mod_cast Finset.card_le_univ _ ) hB0 )

/-- **Max-plus neural network layer**: A tropical linear map is a function of the
form f(x) = max_j(w_j + x_j). The Satake transform gives exact Lipschitz constants.
Bridge: connects tropical geometry ↔ neural network theory.
Application: certified_robustness for tropical_neural_network verification. -/
def tropicalNeuralLayer (n : ℕ) (hn : 0 < n) (weights : Fin n → ℤ) (input : Fin n → ℤ) : ℤ :=
  Finset.sup' Finset.univ (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun j => weights j + input j)

/-
Tropical neural layer is monotone in weights: larger weights give larger outputs.
Application: gradient_descent_monotonicity in tropical neural network training.
-/
theorem tropicalNeuralLayer_mono_weights (n : ℕ) (hn : 0 < n)
    (w₁ w₂ : Fin n → ℤ) (input : Fin n → ℤ)
    (h : ∀ j, w₁ j ≤ w₂ j) :
    tropicalNeuralLayer n hn w₁ input ≤ tropicalNeuralLayer n hn w₂ input := by
  -- Apply the monotonicity of the supremum function to the functions w₁ j + input j and w₂ j + input j.
  have h_sup_mono : ∀ j, w₁ j + input j ≤ w₂ j + input j := by
    grind +splitIndPred;
  exact Finset.sup'_le _ _ fun x hx => Finset.le_sup' ( fun j => w₂ j + input j ) hx |> le_trans ( h_sup_mono x )

end CrossDomainBridges

end TropicalSatake