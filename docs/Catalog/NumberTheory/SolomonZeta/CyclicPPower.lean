/-
# Prime-power cyclic quotients of a free lattice

This file computes, in closed form, the Solomon zeta coefficient attached to a *cyclic*
finite module `X = ℤ/pᵉ` and a free lattice `M = ℤⁿ`:

  `φ(pᵉ) · #{N ≤ ℤⁿ : ℤⁿ/N ≅ ℤ/pᵉ}  =  (pᵉ)ⁿ - (p^{e-1})ⁿ`.

This is the arithmetic content of the "chain collapse" phenomenon for the local
Solomon zeta function of the free lattice over `ℤ_p`: only the top layer of the
submodule chain of `ℤ/pᵉ` contributes, and the Möbius-weighted polynomial
`Σ_{Y ≤ X} μ(Y, X) |Y|ⁿ` collapses to the two-term expression `|X|ⁿ - |pX|ⁿ`.

The proof is via the orbit theorem of `Shared.SolomonZeta.Core`:

* surjections `ℤⁿ ↠ X` correspond to generating tuples `v : Fin n → X`
  (`SolomonZeta.surjEquivSpanning`);
* over the local ring `ℤ/pᵉ`, a tuple generates iff one of its entries is a unit
  (`SolomonZeta.span_eq_top_iff_exists_isUnit`);
* the number of such tuples is `(pᵉ)ⁿ - (p^{e-1})ⁿ`
  (`SolomonZeta.card_spanning_tuples_zmod_prime_pow`);
* dividing by `#Aut(ℤ/pᵉ) = φ(pᵉ)` gives the result.
-/
import Catalog.Shared.SolomonZeta.Applications

namespace SolomonZeta

open Finset Submodule

/-! ### Surjections out of a free module are generating tuples -/

/-- A surjection from the free module `Rⁿ` onto `X` is the same thing as a tuple of
`n` elements of `X` generating `X`. -/
noncomputable def surjEquivSpanning (R X : Type*) [CommRing R] [AddCommGroup X] [Module R X]
    (n : ℕ) :
    {f : (Fin n → R) →ₗ[R] X // LinearMap.range f = ⊤} ≃
      {v : Fin n → X // Submodule.span R (Set.range v) = ⊤} :=
  Equiv.subtypeEquiv ((Pi.basisFun R (Fin n)).constr (M' := X) ℕ).toEquiv.symm (by
    intro f
    have h : ((Pi.basisFun R (Fin n)).constr (M' := X) ℕ)
        (((Pi.basisFun R (Fin n)).constr (M' := X) ℕ).symm f) = f := by simp
    conv_lhs => rw [← h]
    rw [Module.Basis.constr_range]
    rfl)

/-- The number of surjections `Rⁿ ↠ X` is the number of generating `n`-tuples of `X`. -/
theorem homEqCount_top_free_eq_card_spanning (R X : Type*) [CommRing R] [AddCommGroup X]
    [Module R X] (n : ℕ) :
    homEqCount R (Fin n → R) X ⊤ = Nat.card {v : Fin n → X // Submodule.span R (Set.range v) = ⊤} :=
  Nat.card_congr (surjEquivSpanning R X n)

/-! ### Generating tuples over `ℤ/pᵉ` -/

lemma zmod_zsmul (m : ℕ) (c : ℤ) (x : ZMod m) : c • x = (c : ZMod m) * x := by
  simp [zsmul_eq_mul]

lemma intCast_val_self (m : ℕ) [NeZero m] (y : ZMod m) : (((y.val : ℤ)) : ZMod m) = y := by
  push_cast [ZMod.natCast_val, ZMod.cast_id]; ring

/-- If one entry of a tuple in `ℤ/m` is a unit, the tuple generates `ℤ/m` as a `ℤ`-module. -/
lemma span_top_of_isUnit (m : ℕ) [NeZero m] {n : ℕ} (v : Fin n → ZMod m) {i : Fin n}
    (h : IsUnit (v i)) : Submodule.span ℤ (Set.range v) = ⊤ := by
  rw [eq_top_iff]
  intro x _
  obtain ⟨u, hu⟩ := h
  have hmem : v i ∈ Submodule.span ℤ (Set.range v) := Submodule.subset_span ⟨i, rfl⟩
  have hx : x = ((x * (u⁻¹ : (ZMod m)ˣ)).val : ℤ) • (v i) := by
    rw [zmod_zsmul, intCast_val_self, ← hu, mul_assoc, Units.inv_mul, mul_one]
  rw [hx]
  exact Submodule.smul_mem _ _ hmem

/-- A non-unit of `ℤ/pᵉ` reduces to `0` in `ℤ/p`. -/
lemma cast_eq_zero_of_not_isUnit (p e : ℕ) [hp : Fact (Nat.Prime p)] (he : 0 < e)
    {x : ZMod (p ^ e)} (hx : ¬ IsUnit x) :
    ZMod.castHom (dvd_pow_self p he.ne') (ZMod p) x = 0 := by
  haveI : NeZero (p ^ e) := ⟨(Nat.pow_pos hp.out.pos).ne'⟩
  have hv : ((x.val : ℕ) : ZMod (p ^ e)) = x := ZMod.natCast_zmod_val x
  have hnc : ¬ Nat.Coprime x.val (p ^ e) := by
    intro hc
    exact hx (by rw [← hv]; exact (ZMod.isUnit_iff_coprime _ _).2 hc)
  have hd : p ∣ x.val := by
    by_contra hd
    exact hnc (Nat.Coprime.pow_right _ (Nat.coprime_comm.mp ((hp.out.coprime_iff_not_dvd).2 hd)))
  rw [← hv, map_natCast]
  exact (ZMod.natCast_eq_zero_iff _ _).2 hd

/-- If every entry of a tuple in `ℤ/pᵉ` is a non-unit then the tuple lies in the maximal
ideal and cannot generate. -/
lemma span_ne_top_of_forall_not_isUnit (p e : ℕ) [hp : Fact (Nat.Prime p)] (he : 0 < e) {n : ℕ}
    (v : Fin n → ZMod (p ^ e)) (h : ∀ i, ¬ IsUnit (v i)) :
    Submodule.span ℤ (Set.range v) ≠ ⊤ := by
  haveI hpf : Fact (1 < p) := ⟨hp.out.one_lt⟩
  set F : ZMod (p ^ e) →ₗ[ℤ] ZMod p :=
    (ZMod.castHom (dvd_pow_self p he.ne') (ZMod p)).toIntAlgHom.toLinearMap with hF
  intro hspan
  have hle : Submodule.span ℤ (Set.range v) ≤ LinearMap.ker F := by
    rw [Submodule.span_le]
    rintro _ ⟨i, rfl⟩
    exact cast_eq_zero_of_not_isUnit p e he (h i)
  rw [hspan, top_le_iff] at hle
  have h1 : F 1 = 0 := by rw [← LinearMap.mem_ker, hle]; trivial
  rw [hF] at h1
  have hone : (1 : ZMod p) = 0 := by
    rw [← h1]; exact ((ZMod.castHom (dvd_pow_self p he.ne') (ZMod p)).map_one).symm
  exact one_ne_zero hone

/-- **Generation criterion over the local ring `ℤ/pᵉ`.** -/
theorem span_eq_top_iff_exists_isUnit (p e : ℕ) [hp : Fact (Nat.Prime p)] (he : 0 < e) {n : ℕ}
    (v : Fin n → ZMod (p ^ e)) :
    Submodule.span ℤ (Set.range v) = ⊤ ↔ ∃ i, IsUnit (v i) := by
  haveI : NeZero (p ^ e) := ⟨(Nat.pow_pos hp.out.pos).ne'⟩
  constructor
  · intro hspan
    by_contra hno
    exact span_ne_top_of_forall_not_isUnit p e he v (not_exists.mp hno) hspan
  · rintro ⟨i, hi⟩
    exact span_top_of_isUnit _ v hi

/-! ### Counting -/

/-- There are exactly `p^{e-1}` non-units in `ℤ/pᵉ`. -/
theorem card_nonunits_zmod_prime_pow (p e : ℕ) [hp : Fact (Nat.Prime p)] (he : 0 < e) :
    Nat.card {x : ZMod (p ^ e) // ¬ IsUnit x} = p ^ (e - 1) := by
  haveI : NeZero (p ^ e) := ⟨(Nat.pow_pos hp.out.pos).ne'⟩
  have hpp := hp.out.pos
  have hu : Fintype.card {x : ZMod (p ^ e) // IsUnit x} = Nat.totient (p ^ e) := by
    rw [Fintype.card_congr (⟨fun x => x.2.unit, fun u => ⟨(u : ZMod (p ^ e)), u.isUnit⟩,
      fun x => Subtype.ext (by simp), fun u => by ext; simp⟩ :
      {x : ZMod (p ^ e) // IsUnit x} ≃ (ZMod (p ^ e))ˣ)]
    exact ZMod.card_units_eq_totient _
  have hcard : Fintype.card (ZMod (p ^ e)) = p ^ e := ZMod.card _
  have hc : Nat.card {x : ZMod (p ^ e) // ¬ IsUnit x} = p ^ e - Nat.totient (p ^ e) := by
    rw [Nat.card_eq_fintype_card, Fintype.card_subtype_compl, hu, hcard]
  rw [hc, Nat.totient_prime_pow hp.out he]
  obtain ⟨k, rfl⟩ : ∃ k, e = k + 1 := ⟨e - 1, by omega⟩
  simp only [Nat.add_sub_cancel]
  have h1 : p ^ (k + 1) = p ^ k * p := pow_succ p k
  have h2 : p ^ k * (p - 1) = p ^ k * p - p ^ k := by rw [Nat.mul_sub, mul_one]
  have h3 : p ^ k ≤ p ^ k * p := Nat.le_mul_of_pos_right _ hpp
  rw [h1, h2]
  omega

/-- There are exactly `(p^{e-1})ⁿ` tuples in `(ℤ/pᵉ)ⁿ` all of whose entries are non-units. -/
theorem card_nonunit_tuples (p e n : ℕ) [hp : Fact (Nat.Prime p)] (he : 0 < e) :
    Nat.card {v : Fin n → ZMod (p ^ e) // ∀ i, ¬ IsUnit (v i)} = (p ^ (e - 1)) ^ n := by
  haveI : NeZero (p ^ e) := ⟨(Nat.pow_pos hp.out.pos).ne'⟩
  have h1 : Nat.card {v : Fin n → ZMod (p ^ e) // ∀ i, ¬ IsUnit (v i)}
      = Nat.card ((_i : Fin n) → {x : ZMod (p ^ e) // ¬ IsUnit x}) :=
    Nat.card_congr (Equiv.subtypePiEquivPi (β := fun _ : Fin n => ZMod (p ^ e))
      (p := fun _ x => ¬ IsUnit x))
  rw [h1, Nat.card_pi,
    Finset.prod_congr rfl (fun i _ => card_nonunits_zmod_prime_pow p e he)]
  simp

/-- The number of generating `n`-tuples of `ℤ/pᵉ` is `(pᵉ)ⁿ - (p^{e-1})ⁿ`. -/
theorem card_spanning_tuples_zmod_prime_pow (p e n : ℕ) [hp : Fact (Nat.Prime p)] (he : 0 < e) :
    Nat.card {v : Fin n → ZMod (p ^ e) // Submodule.span ℤ (Set.range v) = ⊤}
      = (p ^ e) ^ n - (p ^ (e - 1)) ^ n := by
  classical
  haveI : NeZero (p ^ e) := ⟨(Nat.pow_pos hp.out.pos).ne'⟩
  have hiff : Nat.card {v : Fin n → ZMod (p ^ e) // Submodule.span ℤ (Set.range v) = ⊤}
      = Nat.card {v : Fin n → ZMod (p ^ e) // ∃ i, IsUnit (v i)} :=
    Nat.card_congr (Equiv.subtypeEquivRight (span_eq_top_iff_exists_isUnit p e he))
  have hcompl : Nat.card {v : Fin n → ZMod (p ^ e) // ¬ ∃ i, IsUnit (v i)}
      = (p ^ e) ^ n - Nat.card {v : Fin n → ZMod (p ^ e) // ∃ i, IsUnit (v i)} := by
    rw [Nat.card_eq_fintype_card, Nat.card_eq_fintype_card, Fintype.card_subtype_compl]
    congr 1
    simp [ZMod.card]
  have hall : Nat.card {v : Fin n → ZMod (p ^ e) // ¬ ∃ i, IsUnit (v i)} = (p ^ (e - 1)) ^ n := by
    rw [← card_nonunit_tuples p e n he]
    exact Nat.card_congr (Equiv.subtypeEquivRight (fun v => not_exists))
  have hle : Nat.card {v : Fin n → ZMod (p ^ e) // ∃ i, IsUnit (v i)} ≤ (p ^ e) ^ n := by
    rw [Nat.card_eq_fintype_card]
    calc Fintype.card {v : Fin n → ZMod (p ^ e) // ∃ i, IsUnit (v i)}
        ≤ Fintype.card (Fin n → ZMod (p ^ e)) := Fintype.card_subtype_le _
      _ = (p ^ e) ^ n := by simp [ZMod.card]
  omega

/-! ### The prime-power Solomon coefficient -/

/-- **Prime-power chain collapse.**  For the free lattice `ℤⁿ` and the cyclic module
`ℤ/pᵉ`, the Solomon zeta coefficient satisfies

  `φ(pᵉ) · #{N ≤ ℤⁿ : ℤⁿ/N ≅ ℤ/pᵉ} = (pᵉ)ⁿ - (p^{e-1})ⁿ`.

Equivalently, the Möbius-weighted polynomial `Σ_{Y ≤ ℤ/pᵉ} μ(Y, ℤ/pᵉ)·|Y|ⁿ` collapses to
the two-term expression `|X|ⁿ - |pX|ⁿ`. -/
theorem totient_mul_quotIsoCount_zmod_prime_pow (p e n : ℕ) [hp : Fact (Nat.Prime p)]
    (he : 0 < e) :
    Nat.totient (p ^ e) * quotIsoCount ℤ (Fin n → ℤ) (ZMod (p ^ e))
      = (p ^ e) ^ n - (p ^ (e - 1)) ^ n := by
  haveI : NeZero (p ^ e) := ⟨(Nat.pow_pos hp.out.pos).ne'⟩
  rw [← autCard_zmod (p ^ e), ← homEqCount_top_eq_autCard_mul_quotIsoCount,
    homEqCount_top_free_eq_card_spanning, card_spanning_tuples_zmod_prime_pow p e n he]

/-- The Möbius weight of `(ℤⁿ, ℤ/pᵉ)` collapses to `(pᵉ)ⁿ - (p^{e-1})ⁿ`; in particular the
Möbius-weighted polynomial of the submodule chain of `ℤ/pᵉ` has only two nonzero terms. -/
theorem mobiusWeight_zmod_prime_pow (p e n : ℕ) [hp : Fact (Nat.Prime p)] (he : 0 < e) :
    mobiusWeight ℤ (Fin n → ℤ) (ZMod (p ^ e))
      = ((p : ℤ) ^ e) ^ n - ((p : ℤ) ^ (e - 1)) ^ n := by
  haveI : NeZero (p ^ e) := ⟨(Nat.pow_pos hp.out.pos).ne'⟩
  have hkey := totient_mul_quotIsoCount_zmod_prime_pow p e n he
  have hle : (p ^ (e - 1)) ^ n ≤ (p ^ e) ^ n :=
    Nat.pow_le_pow_left (Nat.pow_le_pow_right hp.out.pos (by omega)) n
  have hcast : ((Nat.totient (p ^ e) * quotIsoCount ℤ (Fin n → ℤ) (ZMod (p ^ e)) : ℕ) : ℤ)
      = (((p ^ e) ^ n - (p ^ (e - 1)) ^ n : ℕ) : ℤ) := by rw [hkey]
  rw [← autCard_zmod (p ^ e)] at hcast
  rw [← autCard_mul_quotIsoCount_eq_mobiusWeight]
  push_cast [Nat.cast_sub hle] at hcast ⊢
  linarith

/-- Sanity check: for `e = 1` the formula recovers the count of index-`p` sublattices. -/
theorem totient_mul_quotIsoCount_zmod_prime (p n : ℕ) [hp : Fact (Nat.Prime p)] :
    (p - 1) * quotIsoCount ℤ (Fin n → ℤ) (ZMod p) = p ^ n - 1 := by
  have h := totient_mul_quotIsoCount_zmod_prime_pow p 1 n one_pos
  rw [pow_one] at h
  simpa [Nat.totient_prime hp.out] using h

end SolomonZeta