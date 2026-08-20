/-
# Applications of the Möbius engine: explicit Solomon zeta coefficients

Building on `Shared.SolomonZeta.Core`, this file evaluates the Möbius weight
`Σ_{Y ≤ X} μ(Y, X) · #Hom(M, Y)` in the cases where it can be written down explicitly:

* `SolomonZeta.mobiusWeight_of_isSimpleModule` — for a *simple* module `X` the weight
  collapses to `#Hom(M, X) - 1`, i.e. to the count of nonzero homomorphisms;
* `SolomonZeta.mobiusWeight_free` — for a free lattice `M = Rⁿ` the weight is the value at
  `X` of the integral polynomial `Σ_{Y ≤ X} μ(Y, X) · |Y|ⁿ`;
* `SolomonZeta.card_index_p_sublattices` — the resulting closed formula
  `(p - 1) · #{N ≤ ℤⁿ : ℤⁿ/N ≅ ℤ/p} = pⁿ - 1`, the first nontrivial coefficient of the
  Solomon zeta function of the free lattice of rank `n`, matching the cardinality of the
  projective space `ℙ^{n-1}(𝔽_p)`;
* `SolomonZeta.quotIsoCount_int_zmod` — every finite cyclic quotient of the rank one lattice
  `ℤ` is achieved exactly once, i.e. the Solomon zeta function of `ℤ` is the Riemann zeta
  function.
-/
import Catalog.Shared.SolomonZeta.Core

namespace SolomonZeta

open Finset IncidenceAlgebra

variable {R M X : Type*} [Ring R] [AddCommGroup M] [Module R M] [AddCommGroup X] [Module R X]

/-! ### Simple quotients -/

/-- In a simple (two element) bounded poset the Möbius function takes the value `-1`. -/
theorem mu_bot_top_of_isSimpleOrder {α : Type*} [PartialOrder α] [BoundedOrder α]
    [IsSimpleOrder α] [LocallyFiniteOrder α] [DecidableEq α] : mu ℤ (⊥ : α) ⊤ = -1 := by
  rw [mu_eq_neg_sum_Ico_of_ne bot_ne_top]
  have hIco : Finset.Ico (⊥ : α) ⊤ = {⊥} := by
    ext x
    simp only [Finset.mem_Ico, Finset.mem_singleton]
    constructor
    · intro h
      rcases IsSimpleOrder.eq_bot_or_eq_top x with h1 | h1
      · exact h1
      · exact absurd h1 (ne_of_lt h.2)
    · rintro rfl
      exact ⟨le_refl _, bot_lt_top⟩
  rw [hIco]
  simp

/-- The submodule poset of a simple module has exactly the two elements `⊥` and `⊤`. -/
theorem Iic_top_of_isSimpleModule [Finite X] [IsSimpleModule R X] :
    Finset.Iic (⊤ : Submodule R X) = {⊥, ⊤} := by
  ext Y
  simp only [Finset.mem_Iic, le_top, true_iff, Finset.mem_insert, Finset.mem_singleton]
  exact IsSimpleOrder.eq_bot_or_eq_top Y

theorem card_hom_bot : Nat.card (M →ₗ[R] (⊥ : Submodule R X)) = 1 := by
  have hsub : Subsingleton (M →ₗ[R] (⊥ : Submodule R X)) :=
    ⟨fun f g => LinearMap.ext fun m => Subsingleton.elim _ _⟩
  exact Nat.card_eq_one_iff_unique.2 ⟨hsub, inferInstance⟩

theorem card_hom_top : Nat.card (M →ₗ[R] (⊤ : Submodule R X)) = Nat.card (M →ₗ[R] X) :=
  Nat.card_congr
    { toFun := fun f => (Submodule.topEquiv : (⊤ : Submodule R X) ≃ₗ[R] X).toLinearMap ∘ₗ f
      invFun := fun g => (Submodule.topEquiv : (⊤ : Submodule R X) ≃ₗ[R] X).symm.toLinearMap ∘ₗ g
      left_inv := fun f => by ext m; simp
      right_inv := fun g => by ext m; simp }

/-- For a simple module `X` the Möbius weight is `#Hom(M, X) - 1`: only the zero map fails
to be surjective. -/
theorem mobiusWeight_of_isSimpleModule [Finite X] [IsSimpleModule R X] :
    mobiusWeight R M X = (Nat.card (M →ₗ[R] X) : ℤ) - 1 := by
  classical
  rw [mobiusWeight, Iic_top_of_isSimpleModule (R := R) (X := X),
    Finset.sum_insert (by simp [(bot_ne_top : (⊥ : Submodule R X) ≠ ⊤)]), Finset.sum_singleton,
    mu_bot_top_of_isSimpleOrder, mu_self, card_hom_bot, card_hom_top]
  ring

/-- **Effective formula for simple quotients.** For a finitely generated `R`-module `M` and a
finite simple `R`-module `X`, the maximal submodules of `M` with quotient `≅ X` are counted by
`(#Hom(M, X) - 1) / #Aut(X)`. -/
theorem simple_quotient_count [Finite X] [IsSimpleModule R X] [Module.Finite R M] :
    (autCard R X : ℤ) * (quotIsoCount R M X : ℤ) = (Nat.card (M →ₗ[R] X) : ℤ) - 1 := by
  rw [autCard_mul_quotIsoCount_eq_mobiusWeight, mobiusWeight_of_isSimpleModule]

/-! ### Free lattices -/

/-- For a free module of rank `n`, `Hom(Rⁿ, Y)` has `|Y|ⁿ` elements. -/
theorem card_hom_free (Y : Type*) [AddCommGroup Y] [Module R Y] (n : ℕ) :
    Nat.card ((Fin n → R) →ₗ[R] Y) = (Nat.card Y) ^ n := by
  rw [← Nat.card_congr ((Pi.basisFun R (Fin n)).constr (M' := Y) ℕ).toEquiv]
  simp [Nat.card_pi]

/-- **The Möbius polynomial of a free lattice.** For `M = Rⁿ` the Möbius weight is the value of
the integral polynomial `Σ_{Y ≤ X} μ(Y, X) · T^{...}` given by `Σ_{Y ≤ X} μ(Y, X) · |Y|ⁿ`. -/
theorem mobiusWeight_free [Finite X] (n : ℕ) :
    mobiusWeight R (Fin n → R) X
      = ∑ Y ∈ Finset.Iic (⊤ : Submodule R X), mu ℤ Y ⊤ * ((Nat.card Y : ℤ) ^ n) := by
  refine Finset.sum_congr rfl fun Y _ => ?_
  rw [card_hom_free]
  push_cast
  ring

/-! ### Elementary abelian quotients of free lattices over `ℤ` -/

lemma zmod_intCast_smul (n : ℕ) [NeZero n] (c x : ZMod n) : ((c.val : ℤ)) • x = c * x := by
  rw [zsmul_eq_mul]; congr 1; push_cast; simp

/-- A `ℤ`-linear endomorphism of `ZMod n` is multiplication by its value at `1`. -/
lemma zmod_int_linearMap_apply (n : ℕ) [NeZero n] (f : ZMod n →ₗ[ℤ] ZMod n) (x : ZMod n) :
    f x = x * f 1 := by
  have hx : ((x.val : ℤ)) • (1 : ZMod n) = x := by rw [zmod_intCast_smul, mul_one]
  calc f x = f (((x.val : ℤ)) • (1 : ZMod n)) := by rw [hx]
    _ = ((x.val : ℤ)) • f 1 := map_smul _ _ _
    _ = x * f 1 := by rw [zmod_intCast_smul]

/-- `ℤ/p` is a simple `ℤ`-module for `p` prime. -/
instance zmodPrimeIsSimpleModule (p : ℕ) [Fact p.Prime] : IsSimpleModule ℤ (ZMod p) := by
  haveI : Nontrivial (Submodule ℤ (ZMod p)) := ⟨⟨⊥, ⊤, bot_ne_top⟩⟩
  haveI : IsSimpleOrder (Submodule ℤ (ZMod p)) := IsSimpleOrder.mk (by
    intro N
    rcases eq_or_ne N ⊥ with h | h
    · exact Or.inl h
    · right
      obtain ⟨x, hxN, hx0⟩ := Submodule.exists_mem_ne_zero_of_ne_bot h
      rw [eq_top_iff]
      intro y _
      have hy : y = ((y * x⁻¹).val : ℤ) • x := by
        rw [zmod_intCast_smul, mul_assoc, inv_mul_cancel₀ hx0, mul_one]
      rw [hy]
      exact N.smul_mem _ hxN)
  exact ⟨⟩

/-- The `ℤ`-linear automorphisms of `ℤ/m` are the units of the ring `ℤ/m`. -/
noncomputable def zmodAutEquivUnits (m : ℕ) [NeZero m] :
    (ZMod m ≃ₗ[ℤ] ZMod m) ≃ (ZMod m)ˣ where
  toFun := fun e => ⟨e 1, e.symm 1, by
      have h := zmod_int_linearMap_apply m e.symm.toLinearMap (e 1)
      simp only [LinearEquiv.coe_coe, LinearEquiv.symm_apply_apply] at h
      exact h.symm, by
      have h := zmod_int_linearMap_apply m e.toLinearMap (e.symm 1)
      simp only [LinearEquiv.coe_coe, LinearEquiv.apply_symm_apply] at h
      exact h.symm⟩
  invFun := fun u =>
    { toFun := fun x => (u : ZMod m) * x
      map_add' := by intro a b; ring
      map_smul' := by intro c a; simp; ring
      invFun := fun x => ((u⁻¹ : (ZMod m)ˣ) : ZMod m) * x
      left_inv := by
        intro x
        show ((u⁻¹ : (ZMod m)ˣ) : ZMod m) * ((u : ZMod m) * x) = x
        rw [← mul_assoc, Units.inv_mul, one_mul]
      right_inv := by
        intro x
        show (u : ZMod m) * (((u⁻¹ : (ZMod m)ˣ) : ZMod m) * x) = x
        rw [← mul_assoc, Units.mul_inv, one_mul] }
  left_inv := by
    intro e
    apply LinearEquiv.toLinearMap_injective
    ext x
    simpa [mul_comm] using (zmod_int_linearMap_apply m e.toLinearMap x).symm
  right_inv := fun u => Units.ext (show (u : ZMod m) * 1 = u by rw [mul_one])

/-- The automorphism count entering the effective formula for cyclic quotient types is Euler's
totient. -/
theorem autCard_zmod (m : ℕ) [NeZero m] : autCard ℤ (ZMod m) = m.totient := by
  rw [autCard, Nat.card_congr (zmodAutEquivUnits m), Nat.card_eq_fintype_card,
    ZMod.card_units_eq_totient]

theorem autCard_zmod_prime (p : ℕ) [Fact p.Prime] : autCard ℤ (ZMod p) = p - 1 := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).pos.ne'⟩
  rw [autCard_zmod, Nat.totient_prime Fact.out]

/-- **The first nontrivial Solomon zeta coefficient of a free lattice.**  For `p` prime the
sublattices of `ℤⁿ` with quotient `ℤ/p` satisfy `(p - 1) · #ℱ = pⁿ - 1`. -/
theorem card_index_p_sublattices (p : ℕ) [Fact p.Prime] (n : ℕ) :
    ((p : ℤ) - 1) * (quotIsoCount ℤ (Fin n → ℤ) (ZMod p) : ℤ) = (p : ℤ) ^ n - 1 := by
  have hmain := simple_quotient_count (R := ℤ) (M := Fin n → ℤ) (X := ZMod p)
  rw [autCard_zmod_prime, card_hom_free] at hmain
  have hp : 1 ≤ p := (Fact.out : p.Prime).one_lt.le
  rw [Nat.cast_sub hp] at hmain
  simpa using hmain

/-- The same count in closed form: the number of index-`p` sublattices of `ℤⁿ` is
`1 + p + ⋯ + pⁿ⁻¹`, the number of points of the projective space `ℙⁿ⁻¹(𝔽_p)`. -/
theorem card_index_p_sublattices_geom (p : ℕ) [Fact p.Prime] (n : ℕ) :
    (quotIsoCount ℤ (Fin n → ℤ) (ZMod p) : ℤ) = ∑ i ∈ Finset.range n, (p : ℤ) ^ i := by
  have hgeom : (∑ i ∈ Finset.range n, (p : ℤ) ^ i) * ((p : ℤ) - 1) = (p : ℤ) ^ n - 1 :=
    geom_sum_mul _ _
  have hne : ((p : ℤ) - 1) ≠ 0 := by
    have := (Fact.out : p.Prime).one_lt
    have : (1 : ℤ) < (p : ℤ) := by exact_mod_cast this
    linarith
  have h := card_index_p_sublattices p n
  refine mul_left_cancel₀ hne ?_
  rw [h, ← hgeom]
  ring

/-! ### The rank one lattice over `ℤ`: the Riemann zeta function -/

theorem quotIsoCount_int_zmod (k : ℕ) (hk : 0 < k) : quotIsoCount ℤ ℤ (ZMod k) = 1 := by
  haveI : NeZero k := ⟨hk.ne'⟩
  have hcard : ∀ N : Submodule ℤ ℤ, Nonempty ((ℤ ⧸ N) ≃ₗ[ℤ] ZMod k) →
      N = Submodule.span ℤ {(k : ℤ)} := by
    rintro N ⟨e⟩
    obtain ⟨m, hm⟩ := IsPrincipalIdealRing.principal N
    have hm' : N = Submodule.span ℤ {m} := hm
    subst hm'
    have hiso : Nonempty ((ℤ ⧸ Ideal.span {m}) ≃+ ZMod m.natAbs) :=
      ⟨(Int.quotientSpanEquivZMod m).toAddEquiv⟩
    obtain ⟨e2⟩ := hiso
    have h1 : Nat.card (ZMod m.natAbs) = Nat.card (ZMod k) :=
      Nat.card_congr (e2.symm.trans (e.toAddEquiv)).toEquiv
    have hk' : Nat.card (ZMod k) = k := by simp
    have hm2 : Nat.card (ZMod m.natAbs) = m.natAbs := by simp
    have hnat : m.natAbs = k := by rw [← hm2, h1, hk']
    rw [← hnat]
    exact (Int.span_natAbs m).symm
  have hne : Nonempty ((ℤ ⧸ Submodule.span ℤ {(k : ℤ)}) ≃ₗ[ℤ] ZMod k) :=
    ⟨AddEquiv.toIntLinearEquiv (Int.quotientSpanEquivZMod (k : ℤ)).toAddEquiv⟩
  rw [quotIsoCount]
  have : {N : Submodule ℤ ℤ | Nonempty ((ℤ ⧸ N) ≃ₗ[ℤ] ZMod k)}
      = {Submodule.span ℤ {(k : ℤ)}} := by
    ext N
    constructor
    · intro h; exact hcard N h
    · rintro rfl; exact hne
  rw [show {N : Submodule ℤ ℤ // Nonempty ((ℤ ⧸ N) ≃ₗ[ℤ] ZMod k)}
    = ↥({N : Submodule ℤ ℤ | Nonempty ((ℤ ⧸ N) ≃ₗ[ℤ] ZMod k)}) from rfl, this]
  simp

end SolomonZeta