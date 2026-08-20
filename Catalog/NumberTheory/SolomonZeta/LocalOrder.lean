/-
# Free lattices over a local order: the Nakayama form of the Möbius weight

This file proves the *local* effective formula that lies behind the arithmetic applications of
the paper: for a commutative local ring `R` with finite residue field `k` (`q = #k`) and a
finite `R`-module `X`, the Möbius weight of the free lattice `Rⁿ` at the quotient type `X` is

  `Σ_{Y ≤ X} μ(Y, X) · #Hom(Rⁿ, Y)  =  #(𝔪X)ⁿ · ∏_{i=0}^{d-1} (qⁿ - q^i)`,   `d = dim_k X/𝔪X`.

In other words the whole Möbius sum over the (possibly complicated) submodule poset of `X`
collapses to the Gaussian-binomial data of the single residual vector space `X/𝔪X`, rescaled by
the size of the radical submodule `𝔪X`.  This is precisely the mechanism that makes the local
Solomon zeta function of a free lattice a rational function with an explicit numerator:
the dependence on `X` enters only through `#𝔪X` and `dim_k X/𝔪X`.

Main steps:
* `SolomonZeta.span_eq_top_iff_span_resQuot` — Nakayama: an `n`-tuple generates `X` over `R`
  iff its reduction generates `X/𝔪X` over `k`;
* `SolomonZeta.quotSplitEquiv`, `SolomonZeta.card_tuples_pullback` — the fibres of
  `Xⁿ ↠ (X/𝔪X)ⁿ` all have `#(𝔪X)ⁿ` elements;
* `SolomonZeta.card_spanning_tuples_of_finiteDimensional` — the count of spanning tuples of a
  finite-dimensional vector space, from the rank duality of `Shared.SolomonZeta.SubspaceLattice`;
* `SolomonZeta.mobiusWeight_free_local` — the resulting closed formula, and
  `SolomonZeta.autCard_mul_quotIsoCount_free_local` — its Solomon-coefficient form.

Two consequences are recorded: the vanishing `quotIsoCount_free_local_eq_zero` when the residual
dimension exceeds the rank, and `autCard_mul_quotIsoCount_free_local_congr`, which says that over
a local ring the Solomon coefficient of a free lattice sees the quotient type `X` only through the
pair of invariants `(#𝔪X, dim_k X/𝔪X)`.
-/
import Catalog.Shared.SolomonZeta.SubspaceLattice

namespace SolomonZeta

open IsLocalRing Module Function

/-! ### Spanning tuples of a finite-dimensional vector space -/

/-- The number of `n`-tuples spanning a `d`-dimensional vector space over a finite field with
`q` elements is `∏_{i<d} (qⁿ - q^i)`. -/
theorem card_spanning_tuples_of_finiteDimensional (K V : Type*) [Field K] [Fintype K]
    [AddCommGroup V] [Module K V] [FiniteDimensional K V] (n : ℕ) :
    Nat.card {v : Fin n → V // Submodule.span K (Set.range v) = ⊤} =
      ∏ i : Fin (finrank K V), (Fintype.card K ^ n - Fintype.card K ^ (i : ℕ)) := by
  classical
  set d := finrank K V with hd
  let e : V ≃ₗ[K] (Fin d → K) := (Module.finBasis K V).equivFun
  have hcard : Nat.card {v : Fin n → V // Submodule.span K (Set.range v) = ⊤}
      = Nat.card {v : Fin n → (Fin d → K) // Submodule.span K (Set.range v) = ⊤} := by
    refine Nat.card_congr (Equiv.subtypeEquiv (Equiv.piCongrRight fun _ => e.toEquiv) ?_)
    intro v
    have hmap : Submodule.span K (Set.range (fun i => e (v i)))
        = (Submodule.span K (Set.range v)).map e.toLinearMap := by
      rw [Submodule.map_span, ← Set.range_comp]
      rfl
    constructor
    · intro h
      show Submodule.span K (Set.range (fun i => e (v i))) = ⊤
      rw [hmap, h, Submodule.map_top, LinearMap.range_eq_top.2 e.surjective]
    · intro h
      have h' : Submodule.span K (Set.range (fun i => e (v i))) = ⊤ := h
      rw [hmap] at h'
      have hcomap := congrArg (Submodule.comap e.toLinearMap) h'
      rwa [Submodule.comap_map_eq_of_injective e.injective, Submodule.comap_top] at hcomap
  rw [hcard, card_spanning_tuples_field]

/-! ### The residual vector space `X/𝔪X` -/

variable (R X : Type*) [CommRing R] [IsLocalRing R] [AddCommGroup X] [Module R X]

/-- The residual quotient `X/𝔪X` of a module over a local ring. -/
abbrev ResQuot := X ⧸ (maximalIdeal R) • (⊤ : Submodule R X)

instance moduleResidueFieldResQuot : Module (ResidueField R) (ResQuot R X) :=
  inferInstanceAs (Module (R ⧸ maximalIdeal R) (X ⧸ (maximalIdeal R) • (⊤ : Submodule R X)))

instance isScalarTowerResQuot : IsScalarTower R (ResidueField R) (ResQuot R X) :=
  inferInstanceAs (IsScalarTower R (R ⧸ maximalIdeal R)
    (X ⧸ (maximalIdeal R) • (⊤ : Submodule R X)))

variable {R X}

/-- **Nakayama for generating tuples.**  A tuple generates a finite `R`-module `X` over a local
ring `R` if and only if its reduction generates the residual vector space `X/𝔪X`. -/
theorem span_eq_top_iff_span_resQuot [Module.Finite R X] {n : ℕ} (v : Fin n → X) :
    Submodule.span R (Set.range v) = ⊤ ↔
      Submodule.span (ResidueField R)
        (Set.range fun i => Submodule.mkQ ((maximalIdeal R) • (⊤ : Submodule R X)) (v i)) = ⊤ := by
  rw [← IsLocalRing.map_mkQ_eq_top (N := Submodule.span R (Set.range v)),
    Submodule.map_span, ← Set.range_comp,
    ← Submodule.restrictScalars_span R (ResidueField R) Ideal.Quotient.mk_surjective,
    Submodule.restrictScalars_eq_top_iff]
  rfl

/-! ### Counting along the reduction map -/

/-- A (noncanonical) splitting of the underlying sets of an extension `N ↪ X ↠ X/N`. -/
noncomputable def quotSplitEquiv {R X : Type*} [Ring R] [AddCommGroup X] [Module R X]
    (N : Submodule R X) : X ≃ (X ⧸ N) × N where
  toFun x := (N.mkQ x, ⟨x - surjInv N.mkQ_surjective (N.mkQ x), by
    rw [← Submodule.Quotient.mk_eq_zero, ← Submodule.mkQ_apply, map_sub,
      surjInv_eq N.mkQ_surjective, sub_self]⟩)
  invFun p := surjInv N.mkQ_surjective p.1 + p.2
  left_inv x := by simp
  right_inv p := by
    obtain ⟨q, y⟩ := p
    have hy : N.mkQ (y : X) = 0 := by
      rw [Submodule.mkQ_apply, Submodule.Quotient.mk_eq_zero]; exact y.2
    have h1 : N.mkQ (surjInv N.mkQ_surjective q + y) = q := by
      rw [map_add, surjInv_eq N.mkQ_surjective, hy, add_zero]
    ext
    · exact h1
    · simp [h1]

/-- Counting tuples along a reduction map: every fibre of `Xⁿ ↠ (X/N)ⁿ` has `#Nⁿ` elements,
so a condition imposed on the reduction is satisfied by `#Nⁿ` times as many tuples. -/
theorem card_tuples_pullback {R X : Type*} [Ring R] [AddCommGroup X] [Module R X]
    (N : Submodule R X) (n : ℕ) (P : (Fin n → X ⧸ N) → Prop) :
    Nat.card {v : Fin n → X // P fun i => N.mkQ (v i)}
      = Nat.card {w : Fin n → X ⧸ N // P w} * Nat.card N ^ n := by
  have e1 : {v : Fin n → X // P fun i => N.mkQ (v i)}
      ≃ {f : Fin n → ((X ⧸ N) × N) // P fun i => (f i).1} :=
    Equiv.subtypeEquiv (Equiv.piCongrRight fun _ => quotSplitEquiv N) (fun _ => Iff.rfl)
  have e2 : {f : Fin n → ((X ⧸ N) × N) // P fun i => (f i).1}
      ≃ {p : (Fin n → (X ⧸ N)) × (Fin n → N) // P p.1} :=
    Equiv.subtypeEquiv (Equiv.arrowProdEquivProdArrow _ _ _) (fun _ => Iff.rfl)
  have e3 : {p : (Fin n → (X ⧸ N)) × (Fin n → N) // P p.1}
      ≃ {w : Fin n → X ⧸ N // P w} × (Fin n → N) :=
    Equiv.prodSubtypeFstEquivSubtypeProd
  rw [Nat.card_congr (e1.trans (e2.trans e3)), Nat.card_prod, Nat.card_fun]
  simp

/-! ### The local formula -/

variable [Finite X] [Module.Finite R X] [Fintype (ResidueField R)]

/-- **Generating tuples over a local ring.**  For a finite module `X` over a commutative local
ring with finite residue field `k` (`q = #k`), the number of `n`-tuples generating `X` is
`#(𝔪X)ⁿ · ∏_{i<d}(qⁿ - q^i)` with `d = dim_k X/𝔪X`. -/
theorem card_generating_tuples_local (n : ℕ) :
    Nat.card {v : Fin n → X // Submodule.span R (Set.range v) = ⊤}
      = (∏ i : Fin (finrank (ResidueField R) (ResQuot R X)),
          (Fintype.card (ResidueField R) ^ n - Fintype.card (ResidueField R) ^ (i : ℕ)))
        * Nat.card ↥((maximalIdeal R) • (⊤ : Submodule R X)) ^ n := by
  haveI : Finite (ResQuot R X) := Finite.of_surjective _
    (Submodule.mkQ_surjective ((maximalIdeal R) • (⊤ : Submodule R X)))
  haveI : FiniteDimensional (ResidueField R) (ResQuot R X) :=
    Module.Finite.of_finite
  have hcongr : Nat.card {v : Fin n → X // Submodule.span R (Set.range v) = ⊤}
      = Nat.card {v : Fin n → X //
          Submodule.span (ResidueField R)
            (Set.range fun i =>
              Submodule.mkQ ((maximalIdeal R) • (⊤ : Submodule R X)) (v i)) = ⊤} :=
    Nat.card_congr (Equiv.subtypeEquivRight fun v => span_eq_top_iff_span_resQuot v)
  rw [hcongr, card_tuples_pullback ((maximalIdeal R) • (⊤ : Submodule R X)) n
      (fun w => Submodule.span (ResidueField R) (Set.range w) = ⊤),
    card_spanning_tuples_of_finiteDimensional]

/-- **The local Möbius weight of a free lattice.**  The Möbius sum over the submodule poset of a
finite module `X` over a local ring collapses to residual data:

  `Σ_{Y ≤ X} μ(Y, X)·#Hom(Rⁿ, Y) = ∏_{i<d}(qⁿ - q^i) · #(𝔪X)ⁿ`. -/
theorem mobiusWeight_free_local (n : ℕ) :
    mobiusWeight R (Fin n → R) X
      = ((∏ i : Fin (finrank (ResidueField R) (ResQuot R X)),
            (Fintype.card (ResidueField R) ^ n - Fintype.card (ResidueField R) ^ (i : ℕ)))
          * Nat.card ↥((maximalIdeal R) • (⊤ : Submodule R X)) ^ n : ℕ) := by
  rw [← homEqCount_top_eq_mobiusWeight, homEqCount_top_free_eq_card_spanning,
    card_generating_tuples_local]

/-- **The local Solomon coefficient of a free lattice.**  `#Aut(X)` times the number of
sublattices `N ≤ Rⁿ` with `Rⁿ/N ≅ X` equals `#(𝔪X)ⁿ · ∏_{i<d}(qⁿ - q^i)`; in particular the
coefficient depends on `X` only through `#𝔪X` and `dim_k X/𝔪X`. -/
theorem autCard_mul_quotIsoCount_free_local (n : ℕ) :
    autCard R X * quotIsoCount R (Fin n → R) X
      = (∏ i : Fin (finrank (ResidueField R) (ResQuot R X)),
          (Fintype.card (ResidueField R) ^ n - Fintype.card (ResidueField R) ^ (i : ℕ)))
        * Nat.card ↥((maximalIdeal R) • (⊤ : Submodule R X)) ^ n := by
  rw [← homEqCount_top_eq_autCard_mul_quotIsoCount, homEqCount_top_free_eq_card_spanning,
    card_generating_tuples_local]

/-! ### Corollaries -/

/-- The automorphism group of a finite module is a finite nonempty group. -/
theorem autCard_pos {R X : Type*} [Ring R] [AddCommGroup X] [Module R X] [Finite X] :
    0 < autCard R X := by
  haveI : Finite (X ≃ₗ[R] X) :=
    Finite.of_injective (fun e : X ≃ₗ[R] X => (e : X → X))
      (fun e₁ e₂ h => by ext x; exact congrFun h x)
  exact Nat.card_pos

/-- If the residual dimension of `X` exceeds `n`, then `X` is not a quotient of `Rⁿ`. -/
theorem quotIsoCount_free_local_eq_zero (n : ℕ)
    (hn : n < finrank (ResidueField R) (ResQuot R X)) :
    quotIsoCount R (Fin n → R) X = 0 := by
  have hkey := autCard_mul_quotIsoCount_free_local (R := R) (X := X) n
  have hzero : (∏ i : Fin (finrank (ResidueField R) (ResQuot R X)),
      (Fintype.card (ResidueField R) ^ n - Fintype.card (ResidueField R) ^ (i : ℕ))) = 0 :=
    Finset.prod_eq_zero (i := ⟨n, hn⟩) (Finset.mem_univ _) (by simp)
  rw [hzero, zero_mul] at hkey
  rcases Nat.mul_eq_zero.1 hkey with h | h
  · exact absurd h autCard_pos.ne'
  · exact h

/-- **Only residual data matters.**  Over a local ring, the weighted Solomon coefficient of a
free lattice at a finite quotient type `X` depends on `X` only through the size of `𝔪X` and the
dimension of `X/𝔪X`: two quotient types sharing these invariants have equal coefficients. -/
theorem autCard_mul_quotIsoCount_free_local_congr {X' : Type*} [AddCommGroup X'] [Module R X']
    [Finite X'] [Module.Finite R X'] (n : ℕ)
    (hdim : finrank (ResidueField R) (ResQuot R X) = finrank (ResidueField R) (ResQuot R X'))
    (hrad : Nat.card ↥((maximalIdeal R) • (⊤ : Submodule R X))
      = Nat.card ↥((maximalIdeal R) • (⊤ : Submodule R X'))) :
    autCard R X * quotIsoCount R (Fin n → R) X
      = autCard R X' * quotIsoCount R (Fin n → R) X' := by
  rw [autCard_mul_quotIsoCount_free_local, autCard_mul_quotIsoCount_free_local, hdim, hrad]

end SolomonZeta