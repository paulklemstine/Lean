/-
# The knot–number bridge XII: the two-parameter family `T(r,N)`

Conjecture `D4` of `FUTURE_DIRECTIONS.md` predicted that the whole bridge is a shadow of a
two-parameter statement: for coprime `r, N` the Alexander polynomial of the torus knot
`T(r,N)`, characterised by

  `(X^{rN} − 1)(X − 1) = (X^r − 1)(X^N − 1) · A_{r,N}(X)`,

should be the cyclotomic product over the divisors of `rN` that divide neither `r` nor `N`.
This file proves it, and identifies the `r = 2` case with the `alexander N` of cycle I.

* `Bridges.AlexanderTorus.torusAlexander` : `∏_{d ∣ rN, d ∤ r, d ∤ N} Φ_d`;
* `Bridges.AlexanderTorus.torusAlexander_defining_identity` : it satisfies the defining
  identity above (so it *is* the Alexander polynomial of `T(r,N)`), for coprime `r, N > 0`;
* `Bridges.AlexanderTorus.torusAlexander_natDegree` : its degree is `(r−1)(N−1)`, the
  classical genus formula `2g = (r−1)(N−1)`, obtained here purely from `∑_{d ∣ n} φ(d) = n`
  and inclusion–exclusion on the divisor lattice;
* `Bridges.AlexanderTorus.torusAlexander_two_eq_alexander` : for odd `N > 0`,
  `A_{2,N} = A_N`, so cycle I's bridge is the `r = 2` slice;
* `Bridges.AlexanderTorus.torusAlexander_semiprime_natDegree_factors` : the degrees of the
  cyclotomic factors of `A_{r,N}` again read off the arithmetic of `rN` — for distinct odd
  primes `p, q` and `r = p`, `N = q` the polynomial `A_{p,q} = Φ_{pq}` has degree
  `(p−1)(q−1) = φ(pq)`.
-/
import Bridges.AlexanderKnotNumberBridgeXI

namespace Bridges.AlexanderTorus

open Polynomial Finset

/-- The index set of `T(r,N)`: divisors of `rN` dividing neither `r` nor `N`. -/
def torusIdx (r N : ℕ) : Finset ℕ := (r * N).divisors \ (r.divisors ∪ N.divisors)

/-- The Alexander polynomial of the torus knot `T(r,N)`, as a cyclotomic product. -/
noncomputable def torusAlexander (r N : ℕ) : ℤ[X] :=
  ∏ d ∈ torusIdx r N, cyclotomic d ℤ

lemma divisors_union_subset_mul {r N : ℕ} (hr : 0 < r) (hN : 0 < N) :
    r.divisors ∪ N.divisors ⊆ (r * N).divisors := by
  intro d hd
  rw [Finset.mem_union, Nat.mem_divisors, Nat.mem_divisors] at hd
  rw [Nat.mem_divisors]
  refine ⟨?_, (Nat.mul_pos hr hN).ne'⟩
  rcases hd with ⟨h, -⟩ | ⟨h, -⟩
  · exact h.trans (Dvd.intro N rfl)
  · exact h.trans (Dvd.intro_left r rfl)

lemma divisors_inter_of_coprime {r N : ℕ} (hco : Nat.Coprime r N) (hr : 0 < r) (hN : 0 < N) :
    r.divisors ∩ N.divisors = {1} := by
  rw [← divisors_gcd hr hN, hco.gcd_eq_one]
  decide

/-- **The defining identity of the torus-knot Alexander polynomial.**  For coprime `r, N > 0`,
`(X^{rN} − 1)(X − 1) = (X^r − 1)(X^N − 1) · ∏_{d ∣ rN, d ∤ r, d ∤ N} Φ_d`. -/
theorem torusAlexander_defining_identity {r N : ℕ} (hco : Nat.Coprime r N)
    (hr : 0 < r) (hN : 0 < N) :
    ((X : ℤ[X]) ^ (r * N) - 1) * ((X : ℤ[X]) - 1)
      = ((X : ℤ[X]) ^ r - 1) * ((X : ℤ[X]) ^ N - 1) * torusAlexander r N := by
  have hsub := divisors_union_subset_mul hr hN
  have hmul : ∏ d ∈ (r * N).divisors, cyclotomic d ℤ
      = (∏ d ∈ r.divisors ∪ N.divisors, cyclotomic d ℤ) * torusAlexander r N := by
    rw [torusAlexander, torusIdx, ← Finset.prod_sdiff hsub]
    exact mul_comm _ _
  have hui : (∏ d ∈ r.divisors ∪ N.divisors, cyclotomic d ℤ) * (cyclotomic 1 ℤ)
      = (∏ d ∈ r.divisors, cyclotomic d ℤ) * ∏ d ∈ N.divisors, cyclotomic d ℤ := by
    have h := Finset.prod_union_inter (s₁ := r.divisors) (s₂ := N.divisors)
      (f := fun d => cyclotomic d ℤ)
    rwa [divisors_inter_of_coprime hco hr hN, Finset.prod_singleton] at h
  have h1 : (cyclotomic 1 ℤ) = (X : ℤ[X]) - 1 := cyclotomic_one ℤ
  calc ((X : ℤ[X]) ^ (r * N) - 1) * ((X : ℤ[X]) - 1)
      = (∏ d ∈ (r * N).divisors, cyclotomic d ℤ) * cyclotomic 1 ℤ := by
        rw [prod_cyclotomic_eq_X_pow_sub_one (Nat.mul_pos hr hN) ℤ, h1]
    _ = ((∏ d ∈ r.divisors ∪ N.divisors, cyclotomic d ℤ) * cyclotomic 1 ℤ)
          * torusAlexander r N := by rw [hmul]; ring
    _ = ((X : ℤ[X]) ^ r - 1) * ((X : ℤ[X]) ^ N - 1) * torusAlexander r N := by
        rw [hui, prod_cyclotomic_eq_X_pow_sub_one hr ℤ, prod_cyclotomic_eq_X_pow_sub_one hN ℤ]

/-! ## The genus formula as a divisor-lattice identity -/

lemma sum_totient_torusIdx {r N : ℕ} (hco : Nat.Coprime r N) (hr : 0 < r) (hN : 0 < N) :
    ∑ d ∈ torusIdx r N, Nat.totient d = (r - 1) * (N - 1) := by
  have hsub := divisors_union_subset_mul hr hN
  have hsd : ∑ d ∈ torusIdx r N, Nat.totient d
      + ∑ d ∈ r.divisors ∪ N.divisors, Nat.totient d = r * N := by
    rw [torusIdx, Finset.sum_sdiff hsub]
    exact Nat.sum_totient (r * N)
  have hui : ∑ d ∈ r.divisors ∪ N.divisors, Nat.totient d + 1 = r + N := by
    have h := Finset.sum_union_inter (s₁ := r.divisors) (s₂ := N.divisors) (f := Nat.totient)
    rw [divisors_inter_of_coprime hco hr hN, Finset.sum_singleton, Nat.totient_one,
      Nat.sum_totient, Nat.sum_totient] at h
    exact h
  obtain ⟨a, rfl⟩ : ∃ a, r = a + 1 := ⟨r - 1, by omega⟩
  obtain ⟨b, rfl⟩ : ∃ b, N = b + 1 := ⟨N - 1, by omega⟩
  have hexp : (a + 1) * (b + 1) = a * b + a + b + 1 := by ring
  simp only [Nat.add_sub_cancel]
  omega

/-- **The genus formula.**  `deg A_{r,N} = (r−1)(N−1)`. -/
theorem torusAlexander_natDegree {r N : ℕ} (hco : Nat.Coprime r N) (hr : 0 < r) (hN : 0 < N) :
    (torusAlexander r N).natDegree = (r - 1) * (N - 1) := by
  rw [torusAlexander, natDegree_prod _ _ (fun d _ => cyclotomic_ne_zero _ ℤ)]
  simp only [natDegree_cyclotomic]
  exact sum_totient_torusIdx hco hr hN

/-! ## The `r = 2` slice is the bridge of cycle I -/

lemma torusIdx_two {N : ℕ} (hN : Odd N) (hpos : 0 < N) :
    torusIdx 2 N = (N.divisors.erase 1).image (fun d => 2 * d) := by
  have h2N : 0 < 2 * N := by positivity
  ext m
  constructor
  · intro hm
    rw [torusIdx, Finset.mem_sdiff, Nat.mem_divisors] at hm
    obtain ⟨⟨hmdvd, -⟩, hnot⟩ := hm
    have hm2 : m ∈ (2 * N).divisors := Nat.mem_divisors.2 ⟨hmdvd, h2N.ne'⟩
    rw [divisors_two_mul hpos, Finset.mem_union] at hm2
    rcases hm2 with hm' | hm'
    · exact absurd (Finset.mem_union_right _ hm') hnot
    · rw [Finset.mem_image] at hm'
      obtain ⟨d, hd, rfl⟩ := hm'
      rw [Finset.mem_image]
      refine ⟨d, Finset.mem_erase.2 ⟨?_, hd⟩, rfl⟩
      rintro rfl
      exact hnot (Finset.mem_union_left _
        (Nat.mem_divisors.2 ⟨by norm_num, by norm_num⟩))
  · intro hm
    rw [Finset.mem_image] at hm
    obtain ⟨d, hd, rfl⟩ := hm
    rw [Finset.mem_erase, Nat.mem_divisors] at hd
    obtain ⟨hd1, hdN, -⟩ := hd
    have hdpos : 0 < d := Nat.pos_of_dvd_of_pos hdN hpos
    rw [torusIdx, Finset.mem_sdiff, Nat.mem_divisors]
    refine ⟨⟨Nat.mul_dvd_mul_left 2 hdN, h2N.ne'⟩, ?_⟩
    rw [Finset.mem_union, Nat.mem_divisors, Nat.mem_divisors]
    rintro (⟨h, -⟩ | ⟨h, -⟩)
    · have hle := Nat.le_of_dvd (by norm_num) h
      omega
    · have h2 : (2 : ℕ) ∣ N := dvd_trans ⟨d, rfl⟩ h
      rw [Nat.odd_iff] at hN
      omega

/-- For odd `N > 0` the two-parameter polynomial specialises to cycle I's `alexander N`. -/
theorem torusAlexander_two_eq_alexander {N : ℕ} (hN : Odd N) (hpos : 0 < N) :
    torusAlexander 2 N = alexander N := by
  rw [torusAlexander, torusIdx_two hN hpos, alexander_eq_prod_cyclotomic_of_pos hN hpos]
  exact Finset.prod_image fun a _ b _ hab => by omega

/-- The semiprime slice of the two-parameter family: for distinct primes `p ≠ q`,
`A_{p,q} = Φ_{pq}`, of degree `(p−1)(q−1) = φ(pq)`. -/
theorem torusAlexander_semiprime_natDegree_factors {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hne : p ≠ q) :
    torusAlexander p q = cyclotomic (p * q) ℤ ∧
      (torusAlexander p q).natDegree = (p - 1) * (q - 1) := by
  have hco : Nat.Coprime p q := (Nat.coprime_primes hp hq).2 hne
  have hppos : 0 < p := hp.pos
  have hqpos : 0 < q := hq.pos
  have hidx : torusIdx p q = {p * q} := by
    ext m
    constructor
    · intro hm
      rw [torusIdx, Finset.mem_sdiff, Nat.mem_divisors] at hm
      obtain ⟨⟨hmdvd, -⟩, hnot⟩ := hm
      have hmem : m ∈ (p * q).divisors := Nat.mem_divisors.2 ⟨hmdvd, by positivity⟩
      rw [divisors_semiprime hp hq] at hmem
      simp only [Finset.mem_insert, Finset.mem_singleton] at hmem
      rw [Finset.mem_singleton]
      rcases hmem with rfl | rfl | rfl | rfl
      · exact absurd (Finset.mem_union_left _
          (Nat.mem_divisors.2 ⟨one_dvd p, hppos.ne'⟩)) hnot
      · exact absurd (Finset.mem_union_left _
          (Nat.mem_divisors.2 ⟨dvd_rfl, hppos.ne'⟩)) hnot
      · exact absurd (Finset.mem_union_right _
          (Nat.mem_divisors.2 ⟨dvd_rfl, hqpos.ne'⟩)) hnot
      · rfl
    · intro hm
      rw [Finset.mem_singleton] at hm
      subst hm
      rw [torusIdx, Finset.mem_sdiff, Nat.mem_divisors]
      refine ⟨⟨dvd_rfl, by positivity⟩, ?_⟩
      rw [Finset.mem_union, Nat.mem_divisors, Nat.mem_divisors]
      rintro (⟨h, -⟩ | ⟨h, -⟩)
      · have hle := Nat.le_of_dvd hppos h
        have h2 := hq.two_le
        nlinarith
      · have hle := Nat.le_of_dvd hqpos h
        have h2 := hp.two_le
        nlinarith
  refine ⟨by rw [torusAlexander, hidx, Finset.prod_singleton], ?_⟩
  exact torusAlexander_natDegree hco hppos hqpos

end Bridges.AlexanderTorus