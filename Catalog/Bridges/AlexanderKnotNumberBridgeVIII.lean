/-
# The knot–number bridge VIII: the Alexander module splits into cyclotomic fields

Conjecture `C1` of `FUTURE_DIRECTIONS.md` asked for a *functorial* decomposition of the
Alexander module of `T(2,N)` along the divisor lattice of `N`.  This file proves the ring
level statement, which is the substance of that conjecture:

* `Bridges.AlexanderTorus.alexanderCRT` : for odd `N > 1` there is a ring isomorphism
  `ℚ[X] / (A_N) ≃+* ∏_{d ∣ N, d > 1} ℚ[X] / (Φ_{2d})`
  obtained from the Chinese Remainder Theorem, the factorization `A_N = ∏ Φ_{2d}` of cycle I
  and the pairwise coprimality of distinct cyclotomic polynomials.
* `Bridges.AlexanderTorus.quotient_cyclotomic_isField` : each factor is a field — namely the
  cyclotomic field `ℚ(ζ_{2d})` — of degree `φ(d)` over `ℚ`
  (`Bridges.AlexanderTorus.finrank_quotient_cyclotomic`).

Consequently the rational Alexander module of `T(2,N)` is an étale `ℚ`-algebra of dimension
`∑_{d ∣ N, d > 1} φ(d) = N - 1 = deg A_N`, whose factors are indexed by the nontrivial
divisors of `N`: the divisor lattice of `N` is visible in the ring structure alone.
-/
import Bridges.AlexanderKnotNumberBridgeIV

namespace Bridges.AlexanderTorus

open Polynomial Finset

/-- `A_N` over `ℚ` is the product of the rational cyclotomic polynomials `Φ_{2d}`,
`d ∣ N`, `d > 1`. -/
lemma alexander_map_rat_eq_prod {N : ℕ} (hN : Odd N) (h1 : 1 < N) :
    (alexander N).map (Int.castRingHom ℚ)
      = ∏ d ∈ N.divisors.erase 1, cyclotomic (2 * d) ℚ := by
  rw [alexander_eq_prod_cyclotomic hN h1, Polynomial.map_prod]
  exact Finset.prod_congr rfl fun d _ => map_cyclotomic_int (2 * d) ℚ

/-- Distinct cyclotomic polynomials `Φ_{2d}`, `Φ_{2e}` are coprime in `ℚ[X]`. -/
lemma isCoprime_cyclotomic_rat {d e : ℕ} (hd : 0 < d) (he : 0 < e) (hde : d ≠ e) :
    IsCoprime (cyclotomic (2 * d) ℚ) (cyclotomic (2 * e) ℚ) := by
  have hdi : Irreducible (cyclotomic (2 * d) ℚ) := cyclotomic.irreducible_rat (by omega)
  have hei : Irreducible (cyclotomic (2 * e) ℚ) := cyclotomic.irreducible_rat (by omega)
  rw [hdi.coprime_iff_not_dvd]
  intro hdvd
  have hassoc : Associated (cyclotomic (2 * d) ℚ) (cyclotomic (2 * e) ℚ) :=
    hdi.associated_of_dvd hei hdvd
  have heq : cyclotomic (2 * d) ℚ = cyclotomic (2 * e) ℚ :=
    eq_of_monic_of_associated (cyclotomic.monic _ _) (cyclotomic.monic _ _) hassoc
  have := cyclotomic_injective (R := ℚ) heq
  omega

/-- The ideal `(A_N)` of `ℚ[X]` is the intersection of the cyclotomic ideals `(Φ_{2d})`. -/
lemma span_alexander_eq_iInf {N : ℕ} (hN : Odd N) (h1 : 1 < N) :
    (⨅ d : ↥(N.divisors.erase 1), Ideal.span {cyclotomic (2 * (d : ℕ)) ℚ})
      = Ideal.span {(alexander N).map (Int.castRingHom ℚ)} := by
  have hcop : ∀ d e : ↥(N.divisors.erase 1), d ≠ e →
      IsCoprime (cyclotomic (2 * (d : ℕ)) ℚ) (cyclotomic (2 * (e : ℕ)) ℚ) := by
    intro d e hde
    have hd : 0 < (d : ℕ) := Nat.pos_of_mem_divisors (Finset.mem_erase.1 d.2).2
    have he : 0 < (e : ℕ) := Nat.pos_of_mem_divisors (Finset.mem_erase.1 e.2).2
    exact isCoprime_cyclotomic_rat hd he (fun h => hde (Subtype.ext h))
  have hp : ∏ i ∈ (N.divisors.erase 1).attach, cyclotomic (2 * (i : ℕ)) ℚ
      = ∏ d ∈ N.divisors.erase 1, cyclotomic (2 * d) ℚ :=
    Finset.prod_attach _ (fun d => cyclotomic (2 * d) ℚ)
  rw [Ideal.iInf_span_singleton hcop, alexander_map_rat_eq_prod hN h1,
    Finset.univ_eq_attach, hp]

/-- **Chinese Remainder decomposition of the Alexander module.** For odd `N > 1`,
`ℚ[X]/(A_N) ≃+* ∏_{d ∣ N, d > 1} ℚ[X]/(Φ_{2d})`. -/
noncomputable def alexanderCRT {N : ℕ} (hN : Odd N) (h1 : 1 < N) :
    (ℚ[X] ⧸ Ideal.span {(alexander N).map (Int.castRingHom ℚ)}) ≃+*
      (∀ d : ↥(N.divisors.erase 1), ℚ[X] ⧸ Ideal.span {cyclotomic (2 * (d : ℕ)) ℚ}) := by
  have hcop : Pairwise (Function.onFun IsCoprime
      (fun d : ↥(N.divisors.erase 1) => Ideal.span {cyclotomic (2 * (d : ℕ)) ℚ})) := by
    intro d e hde
    have hd : 0 < (d : ℕ) := Nat.pos_of_mem_divisors (Finset.mem_erase.1 d.2).2
    have he : 0 < (e : ℕ) := Nat.pos_of_mem_divisors (Finset.mem_erase.1 e.2).2
    exact (Ideal.isCoprime_span_singleton_iff _ _).2
      (isCoprime_cyclotomic_rat hd he (fun h => hde (Subtype.ext h)))
  exact (Ideal.quotientEquivAlgOfEq ℚ (span_alexander_eq_iInf hN h1)).symm.toRingEquiv.trans
    (Ideal.quotientInfRingEquivPiQuotient _ hcop)

/-! ## The factors are the cyclotomic fields -/

/-- Each factor `ℚ[X]/(Φ_{2d})` of the decomposition is a field (the cyclotomic field
`ℚ(ζ_{2d})`). -/
theorem quotient_cyclotomic_isField {d : ℕ} (hd : 0 < d) :
    IsField (ℚ[X] ⧸ Ideal.span {cyclotomic (2 * d) ℚ}) := by
  haveI : Fact (Irreducible (cyclotomic (2 * d) ℚ)) := ⟨cyclotomic.irreducible_rat (by omega)⟩
  letI : Field (ℚ[X] ⧸ Ideal.span {cyclotomic (2 * d) ℚ}) :=
    AdjoinRoot.instField (f := cyclotomic (2 * d) ℚ)
  exact Field.toIsField _

/-- The `d`-th factor has `ℚ`-dimension `φ(d)`, so the total dimension is
`∑_{d ∣ N, d > 1} φ(d) = N - 1 = deg A_N`. -/
theorem finrank_quotient_cyclotomic {d : ℕ} (hd : Odd d) :
    Module.finrank ℚ (ℚ[X] ⧸ Ideal.span {cyclotomic (2 * d) ℚ}) = Nat.totient d := by
  have hmonic : (cyclotomic (2 * d) ℚ).Monic := cyclotomic.monic _ _
  have hne : cyclotomic (2 * d) ℚ ≠ 0 := hmonic.ne_zero
  have h := (AdjoinRoot.powerBasis (f := cyclotomic (2 * d) ℚ) hne).finrank
  rw [AdjoinRoot.powerBasis_dim] at h
  have h2 : Module.finrank ℚ (ℚ[X] ⧸ Ideal.span {cyclotomic (2 * d) ℚ})
      = Module.finrank ℚ (AdjoinRoot (cyclotomic (2 * d) ℚ)) := rfl
  rw [h2, h, natDegree_cyclotomic, totient_two_mul_of_odd hd]

end Bridges.AlexanderTorus