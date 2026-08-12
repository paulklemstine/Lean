/-
# The knot–number bridge XI: the join defect

Cycle VII proved that `N ↦ A_N` is a **meet**-morphism of the divisor lattice
(`alexander_gcd`) but *not* a join-morphism (`alexander_lcm_not_associated`).  Conjecture
`D1` of `FUTURE_DIRECTIONS.md` asked for the exact size of the failure.  This file closes it.

* `Bridges.AlexanderTorus.alexander_lcm_eq_joinProd` : for odd `M, N > 0`,
  `lcm(A_M, A_N)` is associated to `∏_{d ∣ M or d ∣ N, d > 1} Φ_{2d}` — the join on the
  polynomial side is the product over the *union* of the two divisor sets, whereas
  `A_{lcm(M,N)}` is the product over the divisor set of `lcm(M,N)`, which is generally larger.
* `Bridges.AlexanderTorus.alexander_lcm_mul_joinDefect` : the missing factor is exactly
  `∏_{d ∣ lcm(M,N), d ∤ M, d ∤ N, d > 1} Φ_{2d}`, and
  `Bridges.AlexanderTorus.alexander_lcm_natDegree_add_defect` measures it:
  `deg A_{lcm(M,N)} = deg lcm(A_M, A_N) + ∑_{d} φ(d)` over that same index set.
* `Bridges.AlexanderTorus.joinDefect_isUnit_iff` : the join morphism property holds at
  `(M, N)` precisely when `lcm(M,N)` has no divisor `> 1` outside `divisors M ∪ divisors N`.
* `Bridges.AlexanderTorus.joinDefect_three_five_natDegree` : the numerical instance behind
  cycle VII's counterexample — the defect for `(3,5)` is `Φ_30`, of degree `φ(15) = 8`,
  and indeed `14 = 6 + 8`.

Everything reduces, as predicted, to the Finset identity
`(∏_{s ∪ t}) · (∏_{s ∩ t}) = (∏_s) · (∏_t)` together with `divisors (gcd M N) =
divisors M ∩ divisors N`.
-/
import Bridges.AlexanderKnotNumberBridgeVII

namespace Bridges.AlexanderTorus

open Polynomial Finset

/-! ## Divisor sets of gcd's and lcm's -/

/-- The divisors of `gcd M N` are exactly the common divisors of `M` and `N`. -/
lemma divisors_gcd {M N : ℕ} (hM : 0 < M) (hN : 0 < N) :
    (Nat.gcd M N).divisors = M.divisors ∩ N.divisors := by
  ext d
  simp only [Finset.mem_inter, Nat.mem_divisors]
  constructor
  · rintro ⟨hd, -⟩
    exact ⟨⟨hd.trans (Nat.gcd_dvd_left M N), hM.ne'⟩,
      ⟨hd.trans (Nat.gcd_dvd_right M N), hN.ne'⟩⟩
  · rintro ⟨⟨h1, -⟩, h2, -⟩
    exact ⟨Nat.dvd_gcd h1 h2, (Nat.gcd_pos_of_pos_left N hM).ne'⟩

/-- The index set of the join: the nontrivial divisors of `M` together with those of `N`. -/
def unionIdx (M N : ℕ) : Finset ℕ := (M.divisors ∪ N.divisors).erase 1

lemma mem_unionIdx {M N d : ℕ} :
    d ∈ unionIdx M N ↔ d ≠ 1 ∧ (d ∣ M ∧ M ≠ 0 ∨ d ∣ N ∧ N ≠ 0) := by
  simp [unionIdx, Finset.mem_erase, Nat.mem_divisors]

/-- The cyclotomic product over the union of the two divisor sets. -/
noncomputable def joinProd (M N : ℕ) : ℤ[X] :=
  ∏ d ∈ unionIdx M N, cyclotomic (2 * d) ℤ

lemma joinProd_ne_zero (M N : ℕ) : joinProd M N ≠ 0 :=
  Finset.prod_ne_zero_iff.2 fun _ _ => cyclotomic_ne_zero _ ℤ

/-- The multiplicative form of inclusion–exclusion on the divisor lattice:
`(join) · A_{gcd(M,N)} = A_M · A_N`. -/
lemma joinProd_mul_alexander_gcd {M N : ℕ} (hM : Odd M) (hN : Odd N)
    (hMpos : 0 < M) (hNpos : 0 < N) :
    joinProd M N * alexander (Nat.gcd M N) = alexander M * alexander N := by
  have hGpos : 0 < Nat.gcd M N := Nat.gcd_pos_of_pos_left N hMpos
  have hG : Odd (Nat.gcd M N) := odd_of_dvd_odd hM (Nat.gcd_dvd_left M N)
  have hinter : (Nat.gcd M N).divisors.erase 1
      = (M.divisors.erase 1) ∩ (N.divisors.erase 1) := by
    rw [divisors_gcd hMpos hNpos]
    ext x
    simp only [Finset.mem_erase, Finset.mem_inter]
    tauto
  rw [alexander_eq_prod_cyclotomic_of_pos hM hMpos,
    alexander_eq_prod_cyclotomic_of_pos hN hNpos,
    alexander_eq_prod_cyclotomic_of_pos hG hGpos, hinter, joinProd, unionIdx,
    Finset.erase_union_distrib]
  exact Finset.prod_union_inter (f := fun d => cyclotomic (2 * d) ℤ)

/-! ## The join on the polynomial side -/

/-- **The join is the product over the union of the divisor sets.**  For odd `M, N > 0`,
`lcm(A_M, A_N) ≐ ∏_{d ∣ M or d ∣ N, d > 1} Φ_{2d}`. -/
theorem alexander_lcm_eq_joinProd {M N : ℕ} (hM : Odd M) (hN : Odd N)
    (hMpos : 0 < M) (hNpos : 0 < N) :
    Associated (lcm (alexander M) (alexander N)) (joinProd M N) := by
  set G := Nat.gcd M N with hGdef
  have hGpos : 0 < G := Nat.gcd_pos_of_pos_left N hMpos
  have hG : Odd G := odd_of_dvd_odd hM (Nat.gcd_dvd_left M N)
  have hGne : alexander G ≠ 0 := alexander_ne_zero hG
  -- `gcd · lcm ≐ A_M · A_N = joinProd · A_G`
  have h1 : Associated (gcd (alexander M) (alexander N) * lcm (alexander M) (alexander N))
      (alexander M * alexander N) := gcd_mul_lcm _ _
  have hassocG : Associated (alexander G) (gcd (alexander M) (alexander N)) :=
    (alexander_gcd hM hN hMpos hNpos).symm
  have h2 : Associated (alexander G * lcm (alexander M) (alexander N))
      (joinProd M N * alexander G) := by
    have h := (hassocG.mul_right (lcm (alexander M) (alexander N))).trans h1
    rwa [← joinProd_mul_alexander_gcd hM hN hMpos hNpos] at h
  -- cancel the nonzero factor `A_G`
  have h3 : Associated (lcm (alexander M) (alexander N) * alexander G)
      (joinProd M N * alexander G) := by
    rwa [mul_comm (alexander G)] at h2
  exact h3.of_mul_right (Associated.refl _) hGne

/-! ## The join defect -/

/-- The join defect: the cyclotomic factors of `A_{lcm(M,N)}` that are visible at neither
`M` nor `N`. -/
noncomputable def joinDefect (M N : ℕ) : ℤ[X] :=
  ∏ d ∈ ((Nat.lcm M N).divisors.erase 1) \ unionIdx M N, cyclotomic (2 * d) ℤ

lemma unionIdx_subset_lcm {M N : ℕ} (hMpos : 0 < M) (hNpos : 0 < N) :
    unionIdx M N ⊆ (Nat.lcm M N).divisors.erase 1 := by
  intro d hd
  rw [mem_unionIdx] at hd
  have hlcm : Nat.lcm M N ≠ 0 := Nat.pos_of_ne_zero (fun h => by
    simp [Nat.lcm_eq_zero_iff, hMpos.ne', hNpos.ne'] at h) |>.ne'
  rw [Finset.mem_erase, Nat.mem_divisors]
  refine ⟨hd.1, ?_, hlcm⟩
  rcases hd.2 with ⟨h, -⟩ | ⟨h, -⟩
  · exact h.trans (Nat.dvd_lcm_left M N)
  · exact h.trans (Nat.dvd_lcm_right M N)

/-- **The exact join defect.**  `A_{lcm(M,N)} = (join) · (defect)`, where the defect is the
product of the `Φ_{2d}` over the divisors `d > 1` of `lcm(M,N)` dividing neither `M` nor `N`. -/
theorem alexander_lcm_mul_joinDefect {M N : ℕ} (hM : Odd M) (hN : Odd N)
    (hMpos : 0 < M) (hNpos : 0 < N) :
    alexander (Nat.lcm M N) = joinProd M N * joinDefect M N := by
  have hLpos : 0 < Nat.lcm M N := Nat.pos_of_ne_zero (fun h => by
    simp [Nat.lcm_eq_zero_iff, hMpos.ne', hNpos.ne'] at h)
  have hL : Odd (Nat.lcm M N) := by
    rcases hM with ⟨a, ha⟩
    rcases hN with ⟨b, hb⟩
    refine Nat.odd_iff.2 ?_
    have h2 : ¬ (2 ∣ Nat.lcm M N) := by
      intro h2
      rcases (Nat.Prime.dvd_mul Nat.prime_two).1 (h2.trans (Nat.lcm_dvd_mul M N)) with h | h
      · omega
      · omega
    omega
  rw [alexander_eq_prod_cyclotomic_of_pos hL hLpos, joinProd, joinDefect,
    ← Finset.prod_sdiff (unionIdx_subset_lcm hMpos hNpos)]
  exact mul_comm _ _

/-- Corollary: the polynomial join always divides the Alexander polynomial of the lattice
join, but (cycle VII) need not equal it. -/
theorem lcm_alexander_dvd_alexander_lcm {M N : ℕ} (hM : Odd M) (hN : Odd N)
    (hMpos : 0 < M) (hNpos : 0 < N) :
    lcm (alexander M) (alexander N) ∣ alexander (Nat.lcm M N) := by
  refine (alexander_lcm_eq_joinProd hM hN hMpos hNpos).dvd.trans ?_
  exact ⟨joinDefect M N, alexander_lcm_mul_joinDefect hM hN hMpos hNpos⟩

/-! ## Degrees -/

lemma natDegree_prod_cyclotomic_two_mul {s : Finset ℕ} (hodd : ∀ d ∈ s, Odd d) :
    (∏ d ∈ s, cyclotomic (2 * d) ℤ).natDegree = ∑ d ∈ s, Nat.totient d := by
  rw [natDegree_prod _ _ (fun d _ => cyclotomic_ne_zero _ ℤ)]
  refine Finset.sum_congr rfl fun d hd => ?_
  rw [natDegree_cyclotomic, totient_two_mul_of_odd (hodd d hd)]

lemma joinProd_natDegree {M N : ℕ} (hM : Odd M) (hN : Odd N) :
    (joinProd M N).natDegree = ∑ d ∈ unionIdx M N, Nat.totient d := by
  refine natDegree_prod_cyclotomic_two_mul fun d hd => ?_
  rw [mem_unionIdx] at hd
  rcases hd.2 with ⟨h, -⟩ | ⟨h, -⟩
  · exact odd_of_dvd_odd hM h
  · exact odd_of_dvd_odd hN h

lemma joinDefect_natDegree {M N : ℕ} (hM : Odd M) (hN : Odd N) :
    (joinDefect M N).natDegree
      = ∑ d ∈ ((Nat.lcm M N).divisors.erase 1) \ unionIdx M N, Nat.totient d := by
  have hL : Odd (Nat.lcm M N) := by
    rcases hM with ⟨a, ha⟩
    rcases hN with ⟨b, hb⟩
    refine Nat.odd_iff.2 ?_
    have h2 : ¬ (2 ∣ Nat.lcm M N) := by
      intro h2
      rcases (Nat.Prime.dvd_mul Nat.prime_two).1 (h2.trans (Nat.lcm_dvd_mul M N)) with h | h
      · omega
      · omega
    omega
  refine natDegree_prod_cyclotomic_two_mul fun d hd => ?_
  rw [Finset.mem_sdiff, Finset.mem_erase, Nat.mem_divisors] at hd
  exact odd_of_dvd_odd hL hd.1.2.1

/-- **Quantitative failure of the join morphism.**  The degree gap between `A_{lcm(M,N)}` and
`lcm(A_M, A_N)` is exactly `∑ φ(d)` over the divisors `d > 1` of `lcm(M,N)` that divide
neither `M` nor `N`. -/
theorem alexander_lcm_natDegree_add_defect {M N : ℕ} (hM : Odd M) (hN : Odd N)
    (hMpos : 0 < M) (hNpos : 0 < N) :
    (alexander (Nat.lcm M N)).natDegree
      = (lcm (alexander M) (alexander N)).natDegree
        + ∑ d ∈ ((Nat.lcm M N).divisors.erase 1) \ unionIdx M N, Nat.totient d := by
  have hlcmne : lcm (alexander M) (alexander N) ≠ 0 := by
    intro h
    have := (alexander_lcm_eq_joinProd hM hN hMpos hNpos)
    rw [h] at this
    exact joinProd_ne_zero M N (this.eq_zero_iff.1 rfl)
  have hdeg : (lcm (alexander M) (alexander N)).natDegree = (joinProd M N).natDegree :=
    natDegree_eq_of_associated hlcmne (joinProd_ne_zero M N)
      (alexander_lcm_eq_joinProd hM hN hMpos hNpos)
  rw [hdeg, alexander_lcm_mul_joinDefect hM hN hMpos hNpos,
    natDegree_mul (joinProd_ne_zero M N) (by
      exact Finset.prod_ne_zero_iff.2 fun d _ => cyclotomic_ne_zero _ ℤ),
    joinDefect_natDegree hM hN]

/-- The join morphism property holds at `(M,N)` **iff** `lcm(M,N)` has no divisor `> 1`
beyond those of `M` and of `N`. -/
theorem joinDefect_isUnit_iff {M N : ℕ} (hM : Odd M) (hN : Odd N)
    (hMpos : 0 < M) (hNpos : 0 < N) :
    IsUnit (joinDefect M N)
      ↔ ∀ d, d ∣ Nat.lcm M N → d ≠ 1 → d ∣ M ∨ d ∣ N := by
  have hL : Odd (Nat.lcm M N) := by
    rcases hM with ⟨a, ha⟩
    rcases hN with ⟨b, hb⟩
    refine Nat.odd_iff.2 ?_
    have h2 : ¬ (2 ∣ Nat.lcm M N) := by
      intro h2
      rcases (Nat.Prime.dvd_mul Nat.prime_two).1 (h2.trans (Nat.lcm_dvd_mul M N)) with h | h
      · omega
      · omega
    omega
  have hLpos : 0 < Nat.lcm M N := Nat.pos_of_ne_zero (fun h => by
    simp [Nat.lcm_eq_zero_iff, hMpos.ne', hNpos.ne'] at h)
  constructor
  · intro hu d hdL hd1
    by_contra hcon
    push_neg at hcon
    have hnotmem : d ∉ unionIdx M N := by
      rw [mem_unionIdx]
      rintro ⟨-, ⟨hdm, -⟩ | ⟨hdn, -⟩⟩
      · exact hcon.1 hdm
      · exact hcon.2 hdn
    have hmem : d ∈ ((Nat.lcm M N).divisors.erase 1) \ unionIdx M N :=
      Finset.mem_sdiff.2 ⟨Finset.mem_erase.2 ⟨hd1, Nat.mem_divisors.2 ⟨hdL, hLpos.ne'⟩⟩, hnotmem⟩
    -- a cyclotomic factor of the defect is not a unit
    have hdvd : cyclotomic (2 * d) ℤ ∣ joinDefect M N := Finset.dvd_prod_of_mem _ hmem
    have hdpos : 0 < d := Nat.pos_of_dvd_of_pos hdL hLpos
    have : IsUnit (cyclotomic (2 * d) ℤ) := isUnit_of_dvd_unit hdvd hu
    exact (cyclotomic.irreducible (n := 2 * d) (by omega)).not_isUnit this
  · intro h
    have hempty : ((Nat.lcm M N).divisors.erase 1) \ unionIdx M N = ∅ := by
      refine Finset.eq_empty_of_forall_notMem fun d hd => ?_
      rw [Finset.mem_sdiff, Finset.mem_erase, Nat.mem_divisors, mem_unionIdx] at hd
      obtain ⟨⟨hd1, hdL, -⟩, hnot⟩ := hd
      refine hnot ⟨hd1, ?_⟩
      rcases h d hdL hd1 with hdm | hdn
      · exact Or.inl ⟨hdm, hMpos.ne'⟩
      · exact Or.inr ⟨hdn, hNpos.ne'⟩
    rw [joinDefect, hempty, Finset.prod_empty]
    exact isUnit_one

/-! ## The numerical instance behind cycle VII's counterexample -/

/-- For `(M,N) = (3,5)` the defect is `Φ_30`, of degree `φ(15) = 8`; together with
`deg lcm(A_3,A_5) = 6` this reproves `14 = 6 + 8`, i.e. cycle VII's
`alexander_lcm_not_associated`, now with the exact size of the gap. -/
theorem joinDefect_three_five_natDegree : (joinDefect 3 5).natDegree = 8 := by
  have h : (joinDefect 3 5).natDegree
      = ∑ d ∈ ((Nat.lcm 3 5).divisors.erase 1) \ unionIdx 3 5, Nat.totient d :=
    joinDefect_natDegree (by decide) (by decide)
  rw [h]
  decide

end Bridges.AlexanderTorus