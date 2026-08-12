/-
# The knot–number bridge VII: the divisor lattice, gcd's and the failure of lcm's

Cycle III proved the *poset* statement `A_d ∣ A_M ↔ d ∣ M` and cycle IV the coprimality
statement "all common divisors of `A_M`, `A_N` are units iff `gcd(M,N) = 1`".  Conjecture `C4`
of `FUTURE_DIRECTIONS.md` asked whether `N ↦ A_N` is a lattice map, i.e. whether
`gcd(A_M, A_N) ≐ A_{gcd(M,N)}` **and** `lcm(A_M, A_N) ≐ A_{lcm(M,N)}`.

This file settles both halves:

* `Bridges.AlexanderTorus.alexander_gcd` : the gcd half is **true** — for odd `M, N > 0`,
  `gcd(A_M, A_N)` is associated to `A_{gcd(M,N)}` in `ℤ[X]`, with the universal-property
  form `alexander_dvd_gcd_of_dvd_of_dvd`.
* `Bridges.AlexanderTorus.alexander_lcm_not_associated` : the lcm half is **false** — already
  `lcm(A_3, A_5)` has degree `6` while `A_{15}` has degree `14`, so the map `N ↦ A_N` is a
  meet-morphism but not a join-morphism of the divisor lattice.

The mechanism behind the gcd half is that `A_M` is a product of *distinct* cyclotomic primes
`Φ_{2d}`, `d ∣ M`, `d > 1`, so the "excess" parts of `A_M` and `A_N` over `A_{gcd(M,N)}`
share no irreducible factor; the mechanism behind the failure of the lcm half is that
`A_{lcm(M,N)}` also contains the factors `Φ_{2d}` for divisors `d` of `lcm(M,N)` that divide
neither `M` nor `N`.
-/
import Bridges.AlexanderKnotNumberBridgeIV

namespace Bridges.AlexanderTorus

open Polynomial Finset

/-! ## The divisor-product formula, including `N = 1` -/

/-- `A_N = ∏_{d ∣ N, d > 1} Φ_{2d}` for every odd `N > 0` (the case `N = 1` reads `1 = 1`). -/
lemma alexander_eq_prod_cyclotomic_of_pos {N : ℕ} (hN : Odd N) (hpos : 0 < N) :
    alexander N = ∏ d ∈ N.divisors.erase 1, cyclotomic (2 * d) ℤ := by
  rcases eq_or_lt_of_le (Nat.one_le_iff_ne_zero.2 hpos.ne') with h1 | h1
  · rw [← h1]
    simp [alexander]
  · exact alexander_eq_prod_cyclotomic hN h1

lemma divisors_erase_one_subset {G M : ℕ} (hGM : G ∣ M) (hM : 0 < M) :
    G.divisors.erase 1 ⊆ M.divisors.erase 1 := by
  intro d hd
  rw [Finset.mem_erase, Nat.mem_divisors] at hd ⊢
  exact ⟨hd.1, hd.2.1.trans hGM, hM.ne'⟩

/-- The "excess" factor of `A_M` over `A_G` for a divisor `G ∣ M`. -/
noncomputable def excess (G M : ℕ) : ℤ[X] :=
  ∏ d ∈ (M.divisors.erase 1) \ (G.divisors.erase 1), cyclotomic (2 * d) ℤ

/-- `A_M = A_G · (excess G M)` whenever `G ∣ M`. -/
lemma alexander_eq_mul_excess {G M : ℕ} (hM : Odd M) (hMpos : 0 < M) (hGM : G ∣ M)
    (hGpos : 0 < G) : alexander M = alexander G * excess G M := by
  have hG : Odd G := odd_of_dvd_odd hM hGM
  rw [alexander_eq_prod_cyclotomic_of_pos hM hMpos,
    alexander_eq_prod_cyclotomic_of_pos hG hGpos, excess,
    mul_comm, Finset.prod_sdiff (divisors_erase_one_subset hGM hMpos)]

lemma excess_ne_zero (G M : ℕ) : excess G M ≠ 0 := by
  rw [excess]
  refine Finset.prod_ne_zero_iff.2 ?_
  intro d _
  exact cyclotomic_ne_zero _ ℤ

/-! ## The two excesses share no irreducible factor -/

/-- The excess of `A_M` and the excess of `A_N` over `A_{gcd(M,N)}` are relatively prime:
any common divisor is a unit. -/
theorem isRelPrime_excess {M N : ℕ} (hMpos : 0 < M) (hNpos : 0 < N) :
    IsRelPrime (excess (Nat.gcd M N) M) (excess (Nat.gcd M N) N) := by
  set G := Nat.gcd M N with hG
  intro c hcM hcN
  by_contra hnu
  have hc0 : c ≠ 0 := by
    rintro rfl
    exact excess_ne_zero G M (zero_dvd_iff.1 hcM)
  obtain ⟨p, hp, hpc⟩ := WfDvdMonoid.exists_irreducible_factor hnu hc0
  have hprime : Prime p := irreducible_iff_prime.1 hp
  have hpM : p ∣ excess G M := hpc.trans hcM
  have hpN : p ∣ excess G N := hpc.trans hcN
  rw [excess] at hpM hpN
  obtain ⟨d, hdmem, hpd⟩ := hprime.exists_mem_finset_dvd hpM
  obtain ⟨e, hemem, hpe⟩ := hprime.exists_mem_finset_dvd hpN
  rw [Finset.mem_sdiff, Finset.mem_erase, Nat.mem_divisors] at hdmem hemem
  obtain ⟨⟨hd1, hdM, -⟩, hdG⟩ := hdmem
  obtain ⟨⟨he1, heN, -⟩, -⟩ := hemem
  have hdpos : 0 < d := Nat.pos_of_dvd_of_pos hdM hMpos
  have hepos : 0 < e := Nat.pos_of_dvd_of_pos heN hNpos
  -- `p` is associated to both `Φ_{2d}` and `Φ_{2e}`, hence `d = e`
  have hassoc : Associated p (cyclotomic (2 * d) ℤ) :=
    hp.associated_of_dvd (cyclotomic.irreducible (by omega)) hpd
  have hdvd : cyclotomic (2 * d) ℤ ∣ cyclotomic (2 * e) ℤ := hassoc.symm.dvd.trans hpe
  have heq : cyclotomic (2 * d) ℤ = cyclotomic (2 * e) ℤ :=
    eq_of_monic_irreducible_dvd (cyclotomic.monic _ _) (cyclotomic.monic _ _)
      (cyclotomic.irreducible (by omega)) (cyclotomic.irreducible (by omega)) hdvd
  have h2 : 2 * d = 2 * e := cyclotomic_injective (R := ℤ) heq
  have hde : d = e := by omega
  -- but then `d` divides both `M` and `N`, so `d ∈ G.divisors.erase 1`: contradiction
  refine hdG ?_
  rw [Finset.mem_erase, Nat.mem_divisors]
  exact ⟨hd1, Nat.dvd_gcd hdM (hde ▸ heN), Nat.gcd_pos_of_pos_left N hMpos |>.ne'⟩

/-! ## The gcd half of the lattice conjecture: true -/

/-- **Meet morphism.** For odd `M, N > 0`, `gcd(A_M, A_N)` is associated to `A_{gcd(M,N)}`. -/
theorem alexander_gcd {M N : ℕ} (hM : Odd M) (hN : Odd N) (hMpos : 0 < M) (hNpos : 0 < N) :
    Associated (gcd (alexander M) (alexander N)) (alexander (Nat.gcd M N)) := by
  set G := Nat.gcd M N with hG
  have hGpos : 0 < G := Nat.gcd_pos_of_pos_left N hMpos
  have hGM : G ∣ M := Nat.gcd_dvd_left M N
  have hGN : G ∣ N := Nat.gcd_dvd_right M N
  have hu : IsUnit (gcd (excess G M) (excess G N)) :=
    isRelPrime_excess hMpos hNpos (gcd_dvd_left _ _) (gcd_dvd_right _ _)
  rw [alexander_eq_mul_excess hM hMpos hGM hGpos, alexander_eq_mul_excess hN hNpos hGN hGpos,
    _root_.gcd_mul_left]
  exact (associated_mul_unit_left _ _ hu).trans (normalize_associated _)

/-- Universal-property form of the meet morphism: every common divisor of `A_M` and `A_N`
divides `A_{gcd(M,N)}`. -/
theorem alexander_dvd_gcd_of_dvd_of_dvd {M N : ℕ} (hM : Odd M) (hN : Odd N)
    (hMpos : 0 < M) (hNpos : 0 < N) {c : ℤ[X]} (hcM : c ∣ alexander M) (hcN : c ∣ alexander N) :
    c ∣ alexander (Nat.gcd M N) :=
  (dvd_gcd hcM hcN).trans (alexander_gcd hM hN hMpos hNpos).dvd

/-! ## The lcm half of the lattice conjecture: false -/

lemma natDegree_eq_of_associated {f g : ℤ[X]} (hf : f ≠ 0) (hg : g ≠ 0)
    (h : Associated f g) : f.natDegree = g.natDegree :=
  le_antisymm (natDegree_le_of_dvd h.dvd hg) (natDegree_le_of_dvd h.symm.dvd hf)

lemma associated_lcm_three_five :
    Associated (lcm (alexander 3) (alexander 5)) (alexander 3 * alexander 5) := by
  have hu : IsUnit (gcd (alexander 3) (alexander 5)) := by
    refine (alexander_common_divisors_unit_iff_coprime (by decide) (by decide)
      (by norm_num) (by norm_num)).2 (by decide) _ (gcd_dvd_left _ _) (gcd_dvd_right _ _)
  refine ((associated_unit_mul_left (lcm (alexander 3) (alexander 5)) _ hu).symm.trans ?_)
  exact gcd_mul_lcm _ _

/-- **No join morphism.** `lcm(A_3, A_5)` is *not* associated to `A_{lcm(3,5)} = A_{15}`:
the former has degree `6` (it is `Φ_6 · Φ_10`), the latter degree `14` (it also contains
the factor `Φ_30`).  This refutes the lcm half of the lattice conjecture. -/
theorem alexander_lcm_not_associated :
    ¬ Associated (lcm (alexander 3) (alexander 5)) (alexander (Nat.lcm 3 5)) := by
  have h3 : (alexander 3).natDegree = 2 := alexander_natDegree (by decide)
  have h5 : (alexander 5).natDegree = 4 := alexander_natDegree (by decide)
  have h15 : (alexander 15).natDegree = 14 := alexander_natDegree (by decide)
  have h3ne : alexander 3 ≠ 0 := alexander_ne_zero (by decide)
  have h5ne : alexander 5 ≠ 0 := alexander_ne_zero (by decide)
  have h15ne : alexander 15 ≠ 0 := alexander_ne_zero (by decide)
  have hprodne : alexander 3 * alexander 5 ≠ 0 := mul_ne_zero h3ne h5ne
  have hlcmne : lcm (alexander 3) (alexander 5) ≠ 0 := by
    intro h
    have hass := associated_lcm_three_five
    rw [h] at hass
    exact hprodne (hass.eq_zero_iff.1 rfl)
  have hdeg : (lcm (alexander 3) (alexander 5)).natDegree = 6 := by
    rw [natDegree_eq_of_associated hlcmne hprodne associated_lcm_three_five,
      natDegree_mul h3ne h5ne, h3, h5]
  intro hassoc
  have hlcm : Nat.lcm 3 5 = 15 := by decide
  rw [hlcm] at hassoc
  have := natDegree_eq_of_associated hlcmne h15ne hassoc
  rw [hdeg, h15] at this
  exact absurd this (by norm_num)

end Bridges.AlexanderTorus