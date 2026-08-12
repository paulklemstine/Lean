/-
# The Knot–Number bridge, second cycle: factor counts, roots, and local determinants

Building on `Bridges.AlexanderKnotNumberBridge`, this file pushes the bridge between the
Alexander polynomial `A_N` of the torus knot `T(2,N)` and the arithmetic of `N` further:

* `alexander_factorization_multiset` : the full factorization of `A_N` into irreducibles
  over `ℤ`, as a multiset of cardinality `τ(N) - 1` whose degree multiset is
  `{φ(d) : d ∣ N, d > 1}`;
* `sum_totient_erase_one` : those degrees sum to `deg A_N = N - 1`;
* `alexander_roots` : the complex roots of `A_N` are exactly the `z` with `z^N = -1`,
  `z ≠ -1` (the `2N`-th roots of unity that are not `N`-th roots of unity);
* `cyclotomic_two_mul_prime_eval_neg_one` and
  `cyclotomic_two_mul_semiprime_eval_neg_one` : the *local determinants*
  `Φ_{2p}(-1) = p` and `Φ_{2pq}(-1) = 1`, obtained **from the knot side**
  (from `A_N(-1) = N`, the determinant of `T(2,N)`);
* `alexander_prime_sq` : the `N = p²` case, `A_{p²} = Φ_{2p} · Φ_{2p²}`;
* `card_factors_eq_two_iff_prime_sq` : `A_N` has exactly two irreducible factors iff
  `N` is the square of a prime — the next case of the "factor count detects the
  divisor lattice" phenomenon after `alexander_irreducible_iff_prime`.
-/
import Bridges.AlexanderKnotNumberBridge

namespace Bridges.AlexanderTorus

open Polynomial Finset

/-! ## Counting the irreducible factors -/

/-- The number of irreducible factors of `A_N` is `τ(N) - 1`. -/
lemma card_divisors_erase_one {N : ℕ} (hpos : 0 < N) :
    (N.divisors.erase 1).card = N.divisors.card - 1 := by
  rw [Finset.card_erase_of_mem (Nat.one_mem_divisors.2 hpos.ne')]

/-- Gauss' identity, restricted to the nontrivial divisors: `∑_{d ∣ N, d>1} φ(d) = N - 1`.
This is exactly the statement that the degrees of the irreducible factors of `A_N`
add up to `deg A_N`. -/
theorem sum_totient_erase_one {N : ℕ} (hpos : 0 < N) :
    ∑ d ∈ N.divisors.erase 1, Nat.totient d = N - 1 := by
  have h := Nat.sum_totient N
  have hmem : (1 : ℕ) ∈ N.divisors := Nat.one_mem_divisors.2 hpos.ne'
  rw [← Finset.add_sum_erase _ _ hmem, Nat.totient_one] at h
  omega

/-- **Full factorization.** For odd `N > 1`, `A_N` is a product of exactly `τ(N) - 1`
irreducible polynomials over `ℤ`, whose degree multiset is `{φ(d) : d ∣ N, d > 1}`. -/
theorem alexander_factorization_multiset {N : ℕ} (hN : Odd N) (h1 : 1 < N) :
    ∃ s : Multiset ℤ[X],
      (∀ f ∈ s, Irreducible f) ∧
      s.prod = alexander N ∧
      Multiset.card s = N.divisors.card - 1 ∧
      s.map Polynomial.natDegree = (N.divisors.erase 1).val.map Nat.totient := by
  have hpos : 0 < N := by omega
  refine ⟨(N.divisors.erase 1).val.map (fun d => cyclotomic (2 * d) ℤ), ?_, ?_, ?_, ?_⟩
  · intro f hf
    obtain ⟨d, hd, rfl⟩ := Multiset.mem_map.1 hf
    have hdpos : 0 < d :=
      Nat.pos_of_mem_divisors (Finset.mem_erase.1 hd).2
    exact cyclotomic.irreducible (by omega)
  · rw [← Finset.prod_eq_multiset_prod, ← alexander_eq_prod_cyclotomic hN h1]
  · rw [Multiset.card_map]
    exact card_divisors_erase_one hpos
  · rw [Multiset.map_map]
    refine Multiset.map_congr rfl ?_
    intro d hd
    have hdmem := Finset.mem_erase.1 hd
    have hdvd : d ∣ N := (Nat.mem_divisors.1 hdmem.2).1
    have hdodd : Odd d := odd_of_dvd_odd hN hdvd
    simp only [Function.comp_apply]
    rw [natDegree_cyclotomic, totient_two_mul_of_odd hdodd]

/-! ## The complex roots of `A_N` -/

/-- The complex roots of the Alexander polynomial of `T(2,N)` (`N` odd) are exactly the
`2N`-th roots of unity that are not `N`-th roots of unity: `z^N = -1`, `z ≠ -1`. -/
theorem alexander_roots {N : ℕ} (hN : Odd N) (z : ℂ) :
    Polynomial.aeval z (alexander N) = 0 ↔ z ^ N = -1 ∧ z ≠ -1 := by
  have hkey := congrArg (Polynomial.aeval z) (X_add_one_mul_alexander_odd hN)
  simp only [map_mul, map_add, map_one, map_pow, aeval_X] at hkey
  have hdet : Polynomial.aeval (-1 : ℂ) (alexander N) = (N : ℂ) := by
    simp [alexander, map_sum, ← mul_pow]
  constructor
  · intro h
    rw [h, mul_zero] at hkey
    have hzN : z ^ N = -1 := by linear_combination -hkey
    refine ⟨hzN, ?_⟩
    rintro rfl
    rw [hdet] at h
    exact absurd h (by exact_mod_cast Nat.cast_ne_zero.2 hN.pos.ne')
  · rintro ⟨hzN, hz⟩
    have hz1 : z + 1 ≠ 0 := fun hc => hz (by linear_combination hc)
    have : (z + 1) * Polynomial.aeval z (alexander N) = 0 := by
      rw [hkey, hzN]; ring
    rcases mul_eq_zero.1 this with h | h
    · exact absurd h hz1
    · exact h

/-! ## Local determinants, read off from the knot determinant -/

/-- `Φ_{2p}(-1) = p` for an odd prime `p`: the determinant of the prime torus knot. -/
theorem cyclotomic_two_mul_prime_eval_neg_one {p : ℕ} (hp : p.Prime) (hpo : Odd p) :
    (cyclotomic (2 * p) ℤ).eval (-1) = (p : ℤ) := by
  rw [← alexander_prime hpo hp, knot_determinant]

/-- `Φ_{2pq}(-1) = 1` for distinct odd primes: the "top" cyclotomic factor of the
semiprime torus knot has trivial determinant. Proved from `A_{pq}(-1) = pq`. -/
theorem cyclotomic_two_mul_semiprime_eval_neg_one {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpo : Odd p) (hqo : Odd q) (hne : p ≠ q) :
    (cyclotomic (2 * (p * q)) ℤ).eval (-1) = 1 := by
  have hfac := congrArg (Polynomial.eval (-1 : ℤ))
    (alexander_semiprime_factorization hp hq hpo hqo hne)
  rw [knot_determinant, eval_mul, eval_mul, cyclotomic_two_mul_prime_eval_neg_one hp hpo,
    cyclotomic_two_mul_prime_eval_neg_one hq hqo] at hfac
  have hpq : ((p : ℤ) * q) ≠ 0 := by
    have := hp.pos; have := hq.pos
    positivity
  have hcast : ((p * q : ℕ) : ℤ) = (p : ℤ) * q := by push_cast; ring
  rw [hcast] at hfac
  exact mul_left_cancel₀ hpq (hfac.symm.trans (mul_one _).symm)

/-! ## The prime-square case -/

lemma divisors_prime_sq {p : ℕ} (hp : p.Prime) :
    (p * p).divisors = {1, p, p * p} := by
  have hpq : p * p ≠ 0 := Nat.mul_ne_zero hp.pos.ne' hp.pos.ne'
  ext d
  simp only [Nat.mem_divisors, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · rintro ⟨hdvd, -⟩
    obtain ⟨a, b, ha, hb, rfl⟩ := Nat.dvd_mul.1 hdvd
    rcases (Nat.Prime.eq_one_or_self_of_dvd hp a ha) with rfl | rfl <;>
      rcases (Nat.Prime.eq_one_or_self_of_dvd hp b hb) with rfl | rfl <;> simp
  · rintro (rfl | rfl | rfl)
    · exact ⟨one_dvd _, hpq⟩
    · exact ⟨dvd_mul_right _ _, hpq⟩
    · exact ⟨dvd_rfl, hpq⟩

/-- `A_{p²} = Φ_{2p} · Φ_{2p²}` for an odd prime `p`, with factor degrees
`p - 1` and `p(p-1)`. -/
theorem alexander_prime_sq {p : ℕ} (hp : p.Prime) (hpo : Odd p) :
    alexander (p * p) = cyclotomic (2 * p) ℤ * cyclotomic (2 * (p * p)) ℤ ∧
    (cyclotomic (2 * p) ℤ).natDegree = p - 1 ∧
    (cyclotomic (2 * (p * p)) ℤ).natDegree = p * (p - 1) := by
  have hp1 : 1 < p := hp.one_lt
  have h1 : 1 < p * p := by nlinarith
  have hne : p ≠ p * p := by nlinarith
  refine ⟨?_, natDegree_cyclotomic_two_mul_prime hp hpo, ?_⟩
  · rw [alexander_eq_prod_cyclotomic (hpo.mul hpo) h1, divisors_prime_sq hp]
    have herase : ({1, p, p * p} : Finset ℕ).erase 1 = {p, p * p} := by
      ext d
      simp only [Finset.mem_erase, Finset.mem_insert, Finset.mem_singleton]
      constructor
      · rintro ⟨h, rfl | rfl | rfl⟩ <;> simp_all
      · rintro (rfl | rfl) <;> exact ⟨by omega, by simp⟩
    rw [herase, Finset.prod_insert (by simp [hne]), Finset.prod_singleton]
  · rw [natDegree_cyclotomic, totient_two_mul_of_odd (hpo.mul hpo), ← pow_two,
      Nat.totient_prime_pow hp (by norm_num)]
    simp

/-! ## The factor count detects `p²` -/

/-- **Two irreducible factors ⟺ `N` is a prime square.** Together with
`alexander_irreducible_iff_prime` (one factor ⟺ `N` prime) this shows the factor count
`τ(N) - 1` of the Alexander polynomial reads off the shape of the divisor lattice
of `N`. -/
theorem card_factors_eq_two_iff_prime_sq {N : ℕ} (h1 : 1 < N) :
    (N.divisors.erase 1).card = 2 ↔ ∃ p : ℕ, p.Prime ∧ N = p * p := by
  have hpos : 0 < N := by omega
  constructor
  · intro hcard
    obtain ⟨p, hpdef⟩ : ∃ p, p = N.minFac := ⟨N.minFac, rfl⟩
    have hpp : p.Prime := hpdef ▸ Nat.minFac_prime (by omega)
    have hpdvd : p ∣ N := hpdef ▸ Nat.minFac_dvd N
    refine ⟨p, hpp, ?_⟩
    by_contra hcon
    -- the three divisors `p`, `N / p`, `N` would be distinct
    have hpN : p ≠ N := by
      intro hEq
      have hNp : N.Prime := hEq ▸ hpp
      have hdiv : N.divisors.erase 1 = {N} := by
        ext d
        simp only [Finset.mem_erase, Nat.mem_divisors, Finset.mem_singleton]
        constructor
        · rintro ⟨hd1, hdvd, -⟩
          rcases (Nat.Prime.eq_one_or_self_of_dvd hNp d hdvd) with rfl | rfl
          · exact absurd rfl hd1
          · rfl
        · rintro rfl
          exact ⟨by omega, dvd_rfl, by omega⟩
      rw [hdiv] at hcard
      simp at hcard
    have hqdvd : N / p ∣ N := Nat.div_dvd_of_dvd hpdvd
    have hq1 : N / p ≠ 1 := by
      intro hc
      have : N = p := by
        have := Nat.div_mul_cancel hpdvd
        rw [hc, one_mul] at this
        omega
      exact hpN this.symm
    have hqp : N / p ≠ p := by
      intro hc
      have hmul := Nat.div_mul_cancel hpdvd
      rw [hc] at hmul
      exact hcon hmul.symm
    have hqN : N / p ≠ N := by
      intro hc
      have hmul := Nat.div_mul_cancel hpdvd
      rw [hc] at hmul
      nlinarith [hpp.two_le, hpos]
    have hsub : ({p, N / p, N} : Finset ℕ) ⊆ N.divisors.erase 1 := by
      intro d hd
      simp only [Finset.mem_insert, Finset.mem_singleton] at hd
      rcases hd with rfl | rfl | rfl
      · exact Finset.mem_erase.2 ⟨hpp.one_lt.ne', Nat.mem_divisors.2 ⟨hpdvd, hpos.ne'⟩⟩
      · exact Finset.mem_erase.2 ⟨hq1, Nat.mem_divisors.2 ⟨hqdvd, hpos.ne'⟩⟩
      · exact Finset.mem_erase.2 ⟨by omega, Nat.mem_divisors.2 ⟨dvd_rfl, hpos.ne'⟩⟩
    have hcard3 : ({p, N / p, N} : Finset ℕ).card = 3 := by
      rw [Finset.card_insert_of_notMem (by simp [hqp.symm, hpN]),
        Finset.card_insert_of_notMem (by simp [hqN]), Finset.card_singleton]
    have := Finset.card_le_card hsub
    omega
  · rintro ⟨p, hp, rfl⟩
    have hne : p ≠ p * p := by nlinarith [hp.one_lt]
    rw [divisors_prime_sq hp]
    have herase : ({1, p, p * p} : Finset ℕ).erase 1 = {p, p * p} := by
      ext d
      simp only [Finset.mem_erase, Finset.mem_insert, Finset.mem_singleton]
      constructor
      · rintro ⟨h, rfl | rfl | rfl⟩ <;> simp_all
      · rintro (rfl | rfl) <;> exact ⟨by nlinarith [hp.one_lt], by simp⟩
    rw [herase, Finset.card_insert_of_notMem (by simp [hne]), Finset.card_singleton]

end Bridges.AlexanderTorus