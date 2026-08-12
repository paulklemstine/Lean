/-
# The knot–number bridge XIII: reduction mod `ℓ`

Conjecture `D2` of `FUTURE_DIRECTIONS.md` proposes that the mod-`ℓ` factorisation of `A_N`
is the classical Frobenius-orbit count applied blockwise to the divisor product of cycle I.
This file proves the structural half of that conjecture — everything except the orbit count
itself, which is a statement about `Φ_m` over `𝔽_ℓ` alone and involves no knot theory:

* `Bridges.AlexanderTorus.alexander_map_eq_prod_cyclotomic` : the divisor product survives any
  base change, `A_N` maps to `∏_{d ∣ N, d > 1} Φ_{2d}` over every commutative ring;
* `Bridges.AlexanderTorus.alexander_separable_zmod` and
  `Bridges.AlexanderTorus.alexander_squarefree_zmod` : for a prime `ℓ ∤ 2N` the reduction
  `A_N mod ℓ` is separable, hence squarefree — no cyclotomic block collapses;
* `Bridges.AlexanderTorus.alexander_natDegree_map_zmod` : the reduction still has degree
  `N − 1`, i.e. no leading coefficient is lost;
* `Bridges.AlexanderTorus.isRelPrime_cyclotomic_zmod_of_ne` : distinct blocks `Φ_{2d}`,
  `Φ_{2e}` (`d ≠ e` nontrivial divisors of `N`) stay relatively prime mod `ℓ`.

Together these say: for `ℓ ∤ 2N` the mod-`ℓ` picture is still indexed by the divisor lattice
of `N`, with `τ(N) − 1` pairwise coprime squarefree blocks of degrees `φ(d)`; only the
*internal* splitting of each block depends on `ℓ`.
-/
import Bridges.AlexanderKnotNumberBridgeXII

namespace Bridges.AlexanderTorus

open Polynomial Finset

/-- The divisor product of cycle I is stable under base change: over any commutative ring,
`A_N = ∏_{d ∣ N, d > 1} Φ_{2d}`. -/
theorem alexander_map_eq_prod_cyclotomic (R : Type*) [CommRing R] {N : ℕ} (hN : Odd N)
    (hpos : 0 < N) :
    (alexander N).map (Int.castRingHom R) = ∏ d ∈ N.divisors.erase 1, cyclotomic (2 * d) R := by
  rw [alexander_eq_prod_cyclotomic_of_pos hN hpos, Polynomial.map_prod]
  exact Finset.prod_congr rfl fun d _ => map_cyclotomic_int (2 * d) R

section ZMod

variable {ℓ : ℕ} [Fact (Nat.Prime ℓ)]

/-- For a prime `ℓ` not dividing `2N`, the reduction of `A_N` mod `ℓ` is separable: the
`N − 1` roots of `A_N` remain distinct in the algebraic closure of `𝔽_ℓ`. -/
theorem alexander_separable_zmod {N : ℕ} (hN : Odd N) (hl : ¬ ℓ ∣ 2 * N) :
    ((alexander N).map (Int.castRingHom (ZMod ℓ))).Separable := by
  have hpos : 0 < N := hN.pos
  have hne : ((2 * N : ℕ) : ZMod ℓ) ≠ 0 := by
    rw [Ne, ZMod.natCast_eq_zero_iff]
    exact hl
  have hsep : ((X : (ZMod ℓ)[X]) ^ (2 * N) - C 1).Separable :=
    separable_X_pow_sub_C (1 : ZMod ℓ) hne one_ne_zero
  refine hsep.of_dvd ?_
  have hdvd := Polynomial.map_dvd (Int.castRingHom (ZMod ℓ)) (alexander_dvd_X_pow_sub_one hN)
  simpa using hdvd

/-- Consequently `A_N mod ℓ` is squarefree for every prime `ℓ ∤ 2N`. -/
theorem alexander_squarefree_zmod {N : ℕ} (hN : Odd N) (hl : ¬ ℓ ∣ 2 * N) :
    Squarefree ((alexander N).map (Int.castRingHom (ZMod ℓ))) :=
  (alexander_separable_zmod hN hl).squarefree

/-- No degree is lost in the reduction: `A_N mod ℓ` still has degree `N − 1`. -/
theorem alexander_natDegree_map_zmod {N : ℕ} (hN : Odd N) :
    ((alexander N).map (Int.castRingHom (ZMod ℓ))).natDegree = N - 1 := by
  have hpos : 0 < N := hN.pos
  have hmonic : (∏ d ∈ N.divisors.erase 1, cyclotomic (2 * d) (ZMod ℓ)).Monic :=
    monic_prod_of_monic _ _ fun d _ => cyclotomic.monic (2 * d) (ZMod ℓ)
  have hZ : (∏ d ∈ N.divisors.erase 1, cyclotomic (2 * d) ℤ).Monic :=
    monic_prod_of_monic _ _ fun d _ => cyclotomic.monic (2 * d) ℤ
  have hdeg : (∏ d ∈ N.divisors.erase 1, cyclotomic (2 * d) (ZMod ℓ)).natDegree
      = (∏ d ∈ N.divisors.erase 1, cyclotomic (2 * d) ℤ).natDegree := by
    rw [natDegree_prod _ _ (fun d _ => (cyclotomic.monic (2 * d) (ZMod ℓ)).ne_zero),
      natDegree_prod _ _ (fun d _ => cyclotomic_ne_zero _ ℤ)]
    simp [natDegree_cyclotomic]
  rw [alexander_map_eq_prod_cyclotomic (ZMod ℓ) hN hpos, hdeg,
    ← alexander_eq_prod_cyclotomic_of_pos hN hpos, alexander_natDegree hN]

/-- Distinct cyclotomic blocks stay relatively prime after reduction: for `ℓ ∤ 2N` and
distinct nontrivial divisors `d ≠ e` of `N`, `Φ_{2d}` and `Φ_{2e}` have no common
nonunit factor over `𝔽_ℓ`.  This is the input needed for a blockwise Frobenius count. -/
theorem isRelPrime_cyclotomic_zmod_of_ne {N : ℕ} (hN : Odd N) (hl : ¬ ℓ ∣ 2 * N)
    {d e : ℕ} (hd : d ∈ N.divisors.erase 1) (he : e ∈ N.divisors.erase 1) (hde : d ≠ e) :
    IsRelPrime (cyclotomic (2 * d) (ZMod ℓ)) (cyclotomic (2 * e) (ZMod ℓ)) := by
  have hpos : 0 < N := hN.pos
  have hsq := alexander_squarefree_zmod (ℓ := ℓ) hN hl
  rw [alexander_map_eq_prod_cyclotomic (ZMod ℓ) hN hpos] at hsq
  intro c hcd hce
  have hpair : cyclotomic (2 * d) (ZMod ℓ) * cyclotomic (2 * e) (ZMod ℓ)
      ∣ ∏ x ∈ N.divisors.erase 1, cyclotomic (2 * x) (ZMod ℓ) := by
    have hsub : ({d, e} : Finset ℕ) ⊆ N.divisors.erase 1 := by
      intro x hx
      rcases Finset.mem_insert.1 hx with rfl | hx'
      · exact hd
      · rw [Finset.mem_singleton] at hx'
        exact hx' ▸ he
    have := Finset.prod_dvd_prod_of_subset _ _ (fun x => cyclotomic (2 * x) (ZMod ℓ)) hsub
    rwa [Finset.prod_pair hde] at this
  exact hsq c ((mul_dvd_mul hcd hce).trans hpair)

end ZMod

end Bridges.AlexanderTorus