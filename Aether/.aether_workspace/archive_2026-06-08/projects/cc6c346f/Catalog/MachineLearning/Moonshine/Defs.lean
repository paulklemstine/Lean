/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Formal Spectral Moonshine: Core Definitions

This file defines the foundational structures for a formal moonshine calculus:
class functions, their inner product, moonshine packets, and graded traces.

## Main Definitions

* `ClassFn G R` — functions on a finite group `G` with values in `R`, constant on
  conjugacy classes
* `ClassFn.inner` — the canonical inner product on class functions over `ℂ`
* `MoonshinePacket G R` — graded class-function-valued formal series
* `spectralWeight` — connection to information theory

## Application Keywords

monstrous moonshine, McKay–Thompson series, class functions, irreducible characters,
Fourier inversion on finite groups, graded representations, q-series, spectral decoding,
harmonic analysis, representation theory
-/

open Finset BigOperators Complex

noncomputable section

/-! ## Class Functions -/

/-- A class function on a group `G` with values in `R` is a function that is constant
on conjugacy classes: `f(hgh⁻¹) = f(g)` for all `g, h ∈ G`. -/
structure ClassFn (G : Type*) [Group G] (R : Type*) where
  /-- The underlying function. -/
  toFun : G → R
  /-- Invariance under conjugation. -/
  conj_invariant : ∀ g h : G, toFun (h * g * h⁻¹) = toFun g

namespace ClassFn

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]
variable {R : Type*}

instance : FunLike (ClassFn G R) G R where
  coe := ClassFn.toFun
  coe_injective' f g h := by cases f; cases g; simp_all

@[ext]
theorem ext {f g : ClassFn G R} (h : ∀ x, f x = g x) : f = g :=
  DFunLike.ext f g h

@[simp]
theorem toFun_eq_coe (f : ClassFn G R) : f.toFun = f := rfl

theorem conj_eq (f : ClassFn G R) (g h : G) : f (h * g * h⁻¹) = f g :=
  f.conj_invariant g h

/-- The zero class function. -/
instance [Zero R] : Zero (ClassFn G R) :=
  ⟨⟨0, fun _ _ => rfl⟩⟩

@[simp]
theorem zero_apply [Zero R] (g : G) : (0 : ClassFn G R) g = 0 := rfl

/-- Addition of class functions. -/
instance [Add R] : Add (ClassFn G R) :=
  ⟨fun f g => ⟨fun x => f x + g x, fun a b => by simp [conj_eq]⟩⟩

@[simp]
theorem add_apply [Add R] (f g : ClassFn G R) (x : G) : (f + g) x = f x + g x := rfl

/-- Negation of class functions. -/
instance [Neg R] : Neg (ClassFn G R) :=
  ⟨fun f => ⟨fun x => -f x, fun a b => by simp [conj_eq]⟩⟩

@[simp]
theorem neg_apply [Neg R] (f : ClassFn G R) (x : G) : (-f) x = -(f x) := rfl

/-- Subtraction of class functions. -/
instance [Sub R] : Sub (ClassFn G R) :=
  ⟨fun f g => ⟨fun x => f x - g x, fun a b => by simp [conj_eq]⟩⟩

/-- Scalar multiplication of class functions. -/
instance {S : Type*} [SMul S R] : SMul S (ClassFn G R) :=
  ⟨fun c f => ⟨fun x => c • f x, fun a b => by simp [conj_eq]⟩⟩

@[simp]
theorem smul_apply {S : Type*} [SMul S R] (c : S) (f : ClassFn G R) (x : G) :
    (c • f) x = c • f x := rfl

/-- Class functions form an additive commutative group. -/
instance [AddCommGroup R] : AddCommGroup (ClassFn G R) :=
  Function.Injective.addCommGroup toFun DFunLike.coe_injective
    rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl)

/-- Class functions form a module over a commutative ring. -/
instance [CommRing S] [AddCommGroup R] [Module S R] : Module S (ClassFn G R) :=
  Function.Injective.module S
    { toFun := toFun, map_zero' := rfl, map_add' := fun _ _ => rfl }
    DFunLike.coe_injective (fun _ _ => rfl)

/-! ### Inner product on class functions -/

/-- The inner product on class functions over `ℂ`:
  `⟨f, g⟩ = (1/|G|) ∑_{x ∈ G} f(x) * conj(g(x))` -/
def cfInner (f g : ClassFn G ℂ) : ℂ :=
  (↑(Fintype.card G : ℕ) : ℂ)⁻¹ * ∑ x : G, f x * starRingEnd ℂ (g x)

theorem cfInner_def (f g : ClassFn G ℂ) :
    cfInner f g = (↑(Fintype.card G : ℕ) : ℂ)⁻¹ * ∑ x : G, f x * starRingEnd ℂ (g x) := rfl

/-
Inner product is conjugate-symmetric.
-/
theorem cfInner_comm (f g : ClassFn G ℂ) :
    cfInner f g = starRingEnd ℂ (cfInner g f) := by
      simp +decide [ cfInner_def, Finset.mul_sum _ _ _, Finset.sum_mul, mul_comm ]

/-
Inner product is linear in the first argument (additivity).
-/
theorem cfInner_add_left (f₁ f₂ g : ClassFn G ℂ) :
    cfInner (f₁ + f₂) g = cfInner f₁ g + cfInner f₂ g := by
      unfold ClassFn.cfInner;
      rw [ ← mul_add, ← Finset.sum_add_distrib ] ; congr ; ext ; simp +decide [ add_mul ] ;

/-
Inner product respects scalar multiplication in the first argument.
-/
theorem cfInner_smul_left (c : ℂ) (f g : ClassFn G ℂ) :
    cfInner (c • f) g = c * cfInner f g := by
      unfold ClassFn.cfInner;
      simp +decide [ mul_assoc, mul_left_comm, Finset.mul_sum _ _ _ ]

end ClassFn

/-! ## Moonshine Packets -/

/-- A moonshine packet for a finite group `G` over a ring `R` is a graded sequence
of class functions, representing the coefficient data of a McKay–Thompson-type series.

Mathematically, this encodes a family of formal q-series
  `T_g(q) = ∑_{n ≥ 0} aₙ(g) qⁿ`
where each `aₙ` is a class function on `G`. -/
structure MoonshinePacket (G : Type*) [Group G] [Fintype G] (R : Type*) where
  /-- The degree-n coefficient class function. -/
  coeff : ℕ → ClassFn G R

namespace MoonshinePacket

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]
variable {R : Type*}

/-- Two moonshine packets are equal iff all their coefficient class functions agree. -/
@[ext]
theorem ext {A B : MoonshinePacket G R}
    (h : ∀ n, A.coeff n = B.coeff n) :
    A = B := by
  cases A; cases B; simp only [mk.injEq]; funext n; exact h n

/-- Evaluation of a moonshine packet at a group element gives the McKay–Thompson series
coefficients for that element. -/
def eval (T : MoonshinePacket G R) (g : G) : ℕ → R :=
  fun n => T.coeff n g

/-- Two packets with equal evaluations at all group elements are equal. -/
theorem ext_of_eval {A B : MoonshinePacket G R}
    (h : ∀ g n, A.eval g n = B.eval g n) :
    A = B := by
  ext n g
  exact h g n

/-- Addition of moonshine packets (coefficientwise). -/
instance [Add R] : Add (MoonshinePacket G R) :=
  ⟨fun A B => ⟨fun n => A.coeff n + B.coeff n⟩⟩

/-- The zero moonshine packet. -/
instance [Zero R] : Zero (MoonshinePacket G R) :=
  ⟨⟨fun _ => 0⟩⟩

/-- Scalar multiplication of moonshine packets. -/
instance {S : Type*} [SMul S R] : SMul S (MoonshinePacket G R) :=
  ⟨fun c T => ⟨fun n => c • T.coeff n⟩⟩

end MoonshinePacket

/-! ## Virtual Characters and Multiplicity -/

/-- A class function is a virtual character with respect to a family of irreducible characters
if it is an integer linear combination of them. -/
def IsVirtualCharacter {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    {ι : Type*} [Fintype ι]
    (irr : ι → ClassFn G ℂ) (f : ClassFn G ℂ) : Prop :=
  ∃ m : ι → ℤ, ∀ g : G, f g = ∑ i : ι, (m i : ℂ) * (irr i) g

/-- The multiplicity of an irreducible character in a class function,
defined via the inner product: `m(f, χ) = ⟨f, χ⟩`. -/
def multiplicityOf {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (f : ClassFn G ℂ) (χ : ClassFn G ℂ) : ℂ :=
  ClassFn.cfInner f χ

/-! ## Spectral Weight (Cross-domain: Information Theory) -/

/-- The spectral weight of a class function `f` with respect to an irreducible character `χ`
is the squared norm of the Fourier coefficient `|⟨f, χ⟩|²`.

This connects representation theory to information theory: the spectral weights form
a distribution measuring how much "information content" of `f` resides in each
irreducible representation. -/
def spectralWeight {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (f χ : ClassFn G ℂ) : ℝ :=
  Complex.normSq (ClassFn.cfInner f χ)

end