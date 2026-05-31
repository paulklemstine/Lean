/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Dependent Ultraproducts of Rings and Fields

This file constructs the dependent ultraproduct ∏_U K(i) for a family of types
`K : ι → Type*`, each equipped with algebraic structure, modulo an ultrafilter
`U` on the index set `ι`.

Unlike `Filter.Germ U K` (which handles the fixed-type case, i.e., ultrapowers),
this construction handles varying types — essential for pseudofinite fields
where we form ∏_U F_{p_i} with varying prime characteristic.

## Main Results

* `UltraProd.instCommRing` — CommRing instance on the dependent ultraproduct
* `UltraProd.instNontrivial` — nontriviality when each factor is nontrivial
* `UltraProd.instField` — Field instance when each factor is a field
* `UltraProd.diagRingHom` — the diagonal embedding is a ring homomorphism

## References

* Chang, C.C. and Keisler, H.J. (1990). Model Theory.
* Ax, J. (1968). The elementary theory of finite fields.
-/

import Mathlib

open Filter Set

universe u v

/-- The ultrafilter equivalence on dependent sections. -/
def ultraProdSetoid {ι : Type u} (U : Ultrafilter ι) (K : ι → Type v) :
    Setoid (∀ i, K i) where
  r f g := ({i | f i = g i} : Set ι) ∈ (U : Filter ι)
  iseqv := ⟨
    fun _ => Filter.univ_mem' fun _ => rfl,
    fun h => Filter.mem_of_superset h fun _ hi => hi.symm,
    fun h1 h2 => Filter.mem_of_superset (Filter.inter_mem h1 h2)
      fun _ hi => hi.1.trans hi.2⟩

/-- The dependent ultraproduct `∏_U K(i)`. -/
def UltraProd {ι : Type u} (U : Ultrafilter ι) (K : ι → Type v) :=
  Quotient (ultraProdSetoid U K)

namespace UltraProd

variable {ι : Type u} {U : Ultrafilter ι} {K : ι → Type v}

abbrev mk (f : ∀ i, K i) : UltraProd U K :=
  @Quotient.mk _ (ultraProdSetoid U K) f

theorem mk_eq {f g : ∀ i, K i} :
    @mk ι U K f = mk g ↔ ({i | f i = g i} : Set ι) ∈ (U : Filter ι) :=
  @Quotient.eq _ (ultraProdSetoid U K) f g

theorem mk_eq_of_pw {f g : ∀ i, K i} (h : ∀ i, f i = g i) :
    @mk ι U K f = mk g :=
  mk_eq.mpr (Filter.univ_mem' h)

/-- Helper for proving that pointwise operations respect the equivalence. -/
private theorem lift_eq_of_mem {f g : ∀ i, K i}
    (F : (∀ i, K i) → (∀ i, K i))
    (hF : ∀ i, f i = g i → F f i = F g i)
    (h : ({i | f i = g i} : Set ι) ∈ (U : Filter ι)) :
    @mk ι U K (F f) = mk (F g) :=
  mk_eq.mpr (Filter.mem_of_superset h fun i hi => hF i hi)

/-! ### Ring Operations -/

section RingOps
variable [∀ i, CommRing (K i)]

instance : Zero (UltraProd U K) := ⟨mk fun _ => 0⟩
instance : One (UltraProd U K) := ⟨mk fun _ => 1⟩

instance : Add (UltraProd U K) where
  add := Quotient.lift₂ (fun f g => mk (fun i => f i + g i))
    (fun _ _ _ _ h1 h2 => mk_eq.mpr (Filter.mem_of_superset (Filter.inter_mem h1 h2)
      fun i hi => by change _ + _ = _ + _; rw [hi.1, hi.2]))

instance : Mul (UltraProd U K) where
  mul := Quotient.lift₂ (fun f g => mk (fun i => f i * g i))
    (fun _ _ _ _ h1 h2 => mk_eq.mpr (Filter.mem_of_superset (Filter.inter_mem h1 h2)
      fun i hi => by change _ * _ = _ * _; rw [hi.1, hi.2]))

instance : Neg (UltraProd U K) where
  neg := Quotient.lift (fun f => mk (fun i => -(f i)))
    (fun _ _ h => mk_eq.mpr (Filter.mem_of_superset h
      fun i hi => by change -_ = -_; rw [hi]))

instance : SMul ℕ (UltraProd U K) where
  smul n := Quotient.lift (fun f => mk (fun i => n • f i))
    (fun _ _ h => mk_eq.mpr (Filter.mem_of_superset h
      fun i hi => by change n • _ = n • _; rw [hi]))

instance : SMul ℤ (UltraProd U K) where
  smul n := Quotient.lift (fun f => mk (fun i => n • f i))
    (fun _ _ h => mk_eq.mpr (Filter.mem_of_superset h
      fun i hi => by change n • _ = n • _; rw [hi]))

instance : Pow (UltraProd U K) ℕ where
  pow x n := Quotient.lift (fun f => mk (fun i => f i ^ n))
    (fun _ _ h => mk_eq.mpr (Filter.mem_of_superset h
      fun i hi => by change _ ^ n = _ ^ n; rw [hi])) x

instance : NatCast (UltraProd U K) := ⟨fun n => mk fun _ => (n : K _)⟩
instance : IntCast (UltraProd U K) := ⟨fun n => mk fun _ => (n : K _)⟩

end RingOps

/-! ### CommRing Instance -/

section CommRingInstance
variable [∀ i, CommRing (K i)]

noncomputable instance instCommRing : CommRing (UltraProd U K) where
  add_assoc a b c := by
    induction a using Quotient.ind; induction b using Quotient.ind
    induction c using Quotient.ind; exact mk_eq_of_pw fun i => add_assoc _ _ _
  zero_add a := by induction a using Quotient.ind; exact mk_eq_of_pw fun i => zero_add _
  add_zero a := by induction a using Quotient.ind; exact mk_eq_of_pw fun i => add_zero _
  add_comm a b := by
    induction a using Quotient.ind; induction b using Quotient.ind
    exact mk_eq_of_pw fun i => add_comm _ _
  mul_assoc a b c := by
    induction a using Quotient.ind; induction b using Quotient.ind
    induction c using Quotient.ind; exact mk_eq_of_pw fun i => mul_assoc _ _ _
  one_mul a := by induction a using Quotient.ind; exact mk_eq_of_pw fun i => one_mul _
  mul_one a := by induction a using Quotient.ind; exact mk_eq_of_pw fun i => mul_one _
  zero_mul a := by induction a using Quotient.ind; exact mk_eq_of_pw fun i => zero_mul _
  mul_zero a := by induction a using Quotient.ind; exact mk_eq_of_pw fun i => mul_zero _
  left_distrib a b c := by
    induction a using Quotient.ind; induction b using Quotient.ind
    induction c using Quotient.ind; exact mk_eq_of_pw fun i => left_distrib _ _ _
  right_distrib a b c := by
    induction a using Quotient.ind; induction b using Quotient.ind
    induction c using Quotient.ind; exact mk_eq_of_pw fun i => right_distrib _ _ _
  mul_comm a b := by
    induction a using Quotient.ind; induction b using Quotient.ind
    exact mk_eq_of_pw fun i => mul_comm _ _
  neg_add_cancel a := by
    induction a using Quotient.ind; exact mk_eq_of_pw fun i => neg_add_cancel _
  nsmul := (· • ·)
  nsmul_zero a := by
    induction a using Quotient.ind; exact mk_eq_of_pw fun i => zero_nsmul _
  nsmul_succ n a := by
    induction a using Quotient.ind; exact mk_eq_of_pw fun i => succ_nsmul _ _
  zsmul := (· • ·)
  zsmul_zero' a := by
    induction a using Quotient.ind; exact mk_eq_of_pw fun i => zero_zsmul _
  zsmul_succ' n a := by
    induction a using Quotient.ind
    exact mk_eq_of_pw fun i => SubNegMonoid.zsmul_succ' n _
  zsmul_neg' n a := by
    induction a using Quotient.ind
    exact mk_eq_of_pw fun i => SubNegMonoid.zsmul_neg' n _
  natCast_zero := mk_eq_of_pw fun _ => Nat.cast_zero
  natCast_succ n := mk_eq_of_pw fun _ => by push_cast; ring
  intCast_negSucc n := mk_eq_of_pw fun _ => Int.cast_negSucc n
  intCast_ofNat n := mk_eq_of_pw fun _ => Int.cast_natCast (n := n)
  npow n x := x ^ n
  npow_zero a := by
    induction a using Quotient.ind; exact mk_eq_of_pw fun _ => pow_zero _
  npow_succ n a := by
    induction a using Quotient.ind; exact mk_eq_of_pw fun _ => pow_succ _ _

end CommRingInstance

/-! ### Nontriviality -/

section Nontrivial
variable [∀ i, CommRing (K i)]

/-- **The ultraproduct of nontrivial rings is nontrivial.** -/
instance instNontrivial [∀ i, Nontrivial (K i)] :
    Nontrivial (UltraProd U K) where
  exists_pair_ne := by
    refine ⟨0, 1, ?_⟩
    intro h
    have hmem := mk_eq.mp h
    have hempty : ({i : ι | (0 : K i) = (1 : K i)} : Set ι) = ∅ := by
      ext i; simp [zero_ne_one]
    rw [hempty] at hmem; simp at hmem

end Nontrivial

/-! ### Field Instance -/

section FieldInstance
variable [∀ i, Field (K i)]

noncomputable instance : Inv (UltraProd U K) where
  inv := Quotient.lift (fun f => mk (fun i => (f i)⁻¹))
    (fun _ _ h => mk_eq.mpr (Filter.mem_of_superset h fun i hi => by
      change (_)⁻¹ = (_)⁻¹; rw [hi]))

noncomputable instance : Div (UltraProd U K) where
  div := Quotient.lift₂ (fun f g => mk (fun i => f i / g i))
    (fun _ _ _ _ h1 h2 => mk_eq.mpr (Filter.mem_of_superset (Filter.inter_mem h1 h2)
      fun i hi => by change _ / _ = _ / _; rw [hi.1, hi.2]))

noncomputable instance : Pow (UltraProd U K) ℤ where
  pow x n := Quotient.lift (fun f => mk (fun i => f i ^ n))
    (fun _ _ h => mk_eq.mpr (Filter.mem_of_superset h fun i hi => by
      change _ ^ n = _ ^ n; rw [hi])) x

/-- **The dependent ultraproduct of fields is a field.**

The key step is `mul_inv_cancel`: if `[f] ≠ 0` then `{i | f i ≠ 0} ∈ U`.
On this set, `f i * (f i)⁻¹ = 1`, so `[f] * [f]⁻¹ = 1`. -/
noncomputable instance instField : Field (UltraProd U K) where
  mul_inv_cancel := by
    intro a ha
    induction a using Quotient.ind with | _ f =>
    apply mk_eq.mpr
    have hne : ({i | f i = (0 : K i)} : Set ι) ∉ (U : Filter ι) := by
      intro heq; exact ha (mk_eq.mpr heq)
    have hcompl := (Ultrafilter.compl_mem_iff_notMem).mpr hne
    exact Filter.mem_of_superset hcompl fun i hi => by
      change f i * (f i)⁻¹ = 1
      exact mul_inv_cancel₀ hi
  inv_zero := mk_eq_of_pw fun _ => inv_zero
  div_eq_mul_inv a b := by
    induction a using Quotient.ind; induction b using Quotient.ind
    exact mk_eq_of_pw fun _ => div_eq_mul_inv _ _
  nnqsmul := _
  qsmul := _

end FieldInstance

/-! ### Diagonal Embedding -/

section Diagonal
variable [∀ i, CommRing (K i)]

/-- The diagonal embedding via a family of ring homomorphisms. -/
def diag {R : Type v} [CommRing R]
    (embed : ∀ i, R →+* K i) (r : R) : UltraProd U K :=
  mk (fun i => embed i r)

/-- **The diagonal embedding is a ring homomorphism.** -/
noncomputable def diagRingHom {R : Type v} [CommRing R]
    (embed : ∀ i, R →+* K i) : R →+* UltraProd U K where
  toFun := diag embed
  map_zero' := mk_eq_of_pw fun i => map_zero (embed i)
  map_one' := mk_eq_of_pw fun i => map_one (embed i)
  map_add' x y := mk_eq_of_pw fun i => map_add (embed i) x y
  map_mul' x y := mk_eq_of_pw fun i => map_mul (embed i) x y

/-- **The diagonal embedding is injective** when each component embedding is. -/
theorem diag_injective {R : Type v} [CommRing R]
    (embed : ∀ i, R →+* K i)
    (hembed : ∀ i, Function.Injective (embed i)) :
    Function.Injective (diag (U := U) embed) := by
  intro x y hxy
  rw [diag, diag, mk_eq] at hxy
  obtain ⟨i, hi⟩ := Filter.nonempty_of_mem hxy
  exact hembed i hi

end Diagonal

end UltraProd