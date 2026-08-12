/-
# A Knot–Number Theory Bridge: the Alexander polynomial of the torus knot `T(2,N)`

The Alexander polynomial of the `(2,N)` torus knot is (up to normalization)

  `A_N(X) = (X^N + 1) / (X + 1) = ∑_{i < N} (-1)^i X^i`   (`N` odd).

This file proves that `A_N` is, over `ℤ`, the product of the cyclotomic polynomials
`Φ_{2d}` for the divisors `d > 1` of `N`; in particular the *multiset of degrees of
its irreducible factors* is `{φ(d) : d ∣ N, d > 1}`, which for a semiprime `N = pq`
is `{p-1, q-1, (p-1)(q-1)}`, from which `φ(N)`, `p+q` and finally `p, q` are recovered.

Main results:

* `Bridges.AlexanderTorus.prod_cyclotomic_two_mul_divisors` :
  `∏_{d ∣ N} Φ_{2d} = X^N + 1` for odd `N > 0`.
* `Bridges.AlexanderTorus.alexander_eq_prod_cyclotomic` :
  `A_N = ∏_{d ∣ N, d ≠ 1} Φ_{2d}`.
* `Bridges.AlexanderTorus.alexander_semiprime_factorization` :
  `A_{pq} = Φ_{2p} · Φ_{2q} · Φ_{2pq}` for distinct odd primes `p ≠ q`, together with
  `alexander_semiprime_factor_data`: irreducibility of the three factors and their
  degrees `p-1`, `q-1`, `(p-1)(q-1)`.
* `Bridges.AlexanderTorus.alexander_irreducible_iff_prime` :
  for odd `N > 1`, `A_N` is irreducible over `ℤ` **iff** `N` is prime.
* `Bridges.AlexanderTorus.recover_factors_from_degrees` :
  the two primes are recovered from the degree data by
  `p = (s - √(s² - 4N))/2`, `q = (s + √(s² - 4N))/2` with `s = N + 1 - φ(N)`.
* `Bridges.AlexanderTorus.knot_determinant` : `A_N(-1) = N`
  (the determinant of the torus knot `T(2,N)`), and
  `alexander_natDegree` : `deg A_N = N - 1` (the "catch": exponential size in `log N`).
-/
import Mathlib

namespace Bridges.AlexanderTorus

open Polynomial Finset

/-! ## The Alexander polynomial of `T(2,N)` -/

/-- The (normalized) Alexander polynomial of the torus knot `T(2,N)`:
`A_N(X) = 1 - X + X² - ⋯ ± X^{N-1}`. For odd `N` it satisfies
`(X+1) · A_N = X^N + 1`. -/
noncomputable def alexander (N : ℕ) : ℤ[X] := ∑ i ∈ range N, (-1) ^ i * X ^ i

@[simp] lemma alexander_zero : alexander 0 = 0 := by simp [alexander]

lemma alexander_succ (N : ℕ) :
    alexander (N + 1) = alexander N + (-1) ^ N * X ^ N := by
  simp [alexander, Finset.sum_range_succ]

/-- The defining relation: `(X+1) · A_N = 1 - (-1)^N X^N`. -/
lemma X_add_one_mul_alexander (N : ℕ) :
    (X + 1) * alexander N = 1 - (-1) ^ N * X ^ N := by
  induction N with
  | zero => simp
  | succ n ih =>
      rw [alexander_succ, mul_add, ih, pow_succ (-1 : ℤ[X]) n, pow_succ X n]
      ring

/-- For odd `N`, `(X+1) · A_N = X^N + 1`. -/
lemma X_add_one_mul_alexander_odd {N : ℕ} (hN : Odd N) :
    (X + 1) * alexander N = X ^ N + 1 := by
  rw [X_add_one_mul_alexander, hN.neg_one_pow]
  ring

lemma alexander_ne_zero {N : ℕ} (hN : Odd N) : alexander N ≠ 0 := by
  intro h
  have hkey := X_add_one_mul_alexander_odd hN
  rw [h, mul_zero] at hkey
  have h0 := congrArg (Polynomial.eval 1) hkey
  simp at h0

/-! ## Elementary divisor combinatorics -/

lemma odd_of_dvd_odd {N d : ℕ} (hN : Odd N) (hd : d ∣ N) : Odd d := by
  rcases Nat.even_or_odd d with he | ho
  · exfalso
    obtain ⟨k, hk⟩ := (he.two_dvd).trans hd
    rw [Nat.odd_iff] at hN
    omega
  · exact ho

/-- The divisors of `2N` are the divisors of `N` together with their doubles. -/
lemma divisors_two_mul {N : ℕ} (hpos : 0 < N) :
    (2 * N).divisors = N.divisors ∪ (N.divisors.image (fun d => 2 * d)) := by
  ext d
  simp only [Nat.mem_divisors, Finset.mem_union, Finset.mem_image]
  constructor
  · rintro ⟨hdvd, -⟩
    rcases Nat.even_or_odd d with he | ho
    · obtain ⟨e, rfl⟩ := he
      refine Or.inr ⟨e, ⟨?_, hpos.ne'⟩, by ring⟩
      have h : (2 : ℕ) * e ∣ 2 * N := by simpa [two_mul] using hdvd
      exact (mul_dvd_mul_iff_left (by norm_num : (2 : ℕ) ≠ 0)).1 h
    · exact Or.inl ⟨Nat.Coprime.dvd_of_dvd_mul_left (Nat.coprime_two_right.2 ho) hdvd,
        hpos.ne'⟩
  · rintro (⟨hdvd, -⟩ | ⟨e, ⟨he, -⟩, rfl⟩)
    · exact ⟨hdvd.mul_left 2, by positivity⟩
    · exact ⟨mul_dvd_mul_left 2 he, by positivity⟩

/-- For odd `N`, the divisors of `N` and their doubles are disjoint families. -/
lemma disjoint_divisors_image_two_mul {N : ℕ} (hN : Odd N) :
    Disjoint N.divisors (N.divisors.image (fun d => 2 * d)) := by
  rw [Finset.disjoint_right]
  rintro a ha ha'
  simp only [Finset.mem_image, Nat.mem_divisors] at ha ha'
  obtain ⟨e, -, rfl⟩ := ha
  obtain ⟨hdvd, -⟩ := ha'
  obtain ⟨k, hk⟩ := (dvd_mul_right 2 e).trans hdvd
  rw [Nat.odd_iff] at hN
  omega

/-! ## The cyclotomic factorization -/

/-- **Key identity.** For odd `N > 0`, `X^N + 1 = ∏_{d ∣ N} Φ_{2d}(X)` in `ℤ[X]`. -/
theorem prod_cyclotomic_two_mul_divisors {N : ℕ} (hN : Odd N) (hpos : 0 < N) :
    ∏ d ∈ N.divisors, cyclotomic (2 * d) ℤ = X ^ N + 1 := by
  have key : (∏ d ∈ N.divisors, cyclotomic d ℤ) * (∏ d ∈ N.divisors, cyclotomic (2 * d) ℤ)
      = X ^ (2 * N) - 1 := by
    rw [← prod_cyclotomic_eq_X_pow_sub_one (by omega) ℤ, divisors_two_mul hpos,
      Finset.prod_union (disjoint_divisors_image_two_mul hN),
      Finset.prod_image (fun a _ b _ h => Nat.eq_of_mul_eq_mul_left (by norm_num) h)]
  rw [prod_cyclotomic_eq_X_pow_sub_one hpos ℤ] at key
  have hne : (X ^ N - 1 : ℤ[X]) ≠ 0 := by
    intro h
    have h0 := congrArg (Polynomial.eval 0) h
    simp [zero_pow hpos.ne'] at h0
  refine mul_left_cancel₀ hne ?_
  rw [key, two_mul, pow_add]
  ring

/-- **The bridge.** For odd `N > 1` the Alexander polynomial of `T(2,N)` is the product of
the cyclotomic polynomials `Φ_{2d}` over the divisors `d > 1` of `N`. -/
theorem alexander_eq_prod_cyclotomic {N : ℕ} (hN : Odd N) (h1 : 1 < N) :
    alexander N = ∏ d ∈ N.divisors.erase 1, cyclotomic (2 * d) ℤ := by
  have hpos : 0 < N := by omega
  have hmem : (1 : ℕ) ∈ N.divisors := Nat.one_mem_divisors.2 hpos.ne'
  have hsplit := Finset.mul_prod_erase _ (fun d => cyclotomic (2 * d) ℤ) hmem
  rw [prod_cyclotomic_two_mul_divisors hN hpos] at hsplit
  simp only [mul_one, cyclotomic_two] at hsplit
  have hne : (X + 1 : ℤ[X]) ≠ 0 := by
    intro h
    have h0 := congrArg (Polynomial.eval 0) h
    simp at h0
  refine mul_left_cancel₀ hne ?_
  rw [X_add_one_mul_alexander_odd hN, ← hsplit]

/-! ## Degree of `A_N` (the "catch": exponential in `log N`) -/

theorem alexander_natDegree {N : ℕ} (hN : Odd N) : (alexander N).natDegree = N - 1 := by
  have hpos : 0 < N := hN.pos
  have h := X_add_one_mul_alexander_odd hN
  have hX1 : (X + 1 : ℤ[X]) ≠ 0 := fun hc => by
    simpa using congrArg (Polynomial.eval 0) hc
  have hdeg : ((X + 1 : ℤ[X]) * alexander N).natDegree
      = (X + 1 : ℤ[X]).natDegree + (alexander N).natDegree :=
    natDegree_mul hX1 (alexander_ne_zero hN)
  have hXd : (X + 1 : ℤ[X]).natDegree = 1 := by
    simpa using natDegree_X_add_C (1 : ℤ)
  have hR : ((X : ℤ[X]) ^ N + 1).natDegree = N := by
    have hC : ((X : ℤ[X]) ^ N + 1) = (X ^ N + C 1) := by simp
    rw [hC, natDegree_X_pow_add_C]
  rw [h, hR, hXd] at hdeg
  omega

/-! ## Knot determinant -/

/-- The determinant of the torus knot `T(2,N)` is `N`: `A_N(-1) = N`. -/
theorem knot_determinant (N : ℕ) : (alexander N).eval (-1) = (N : ℤ) := by
  simp [alexander, eval_finset_sum, ← mul_pow]

/-- Alexander polynomials are normalized: `A_N(1) = 1` for odd `N`. -/
theorem alexander_eval_one {N : ℕ} (hN : Odd N) : (alexander N).eval 1 = 1 := by
  have h := congrArg (Polynomial.eval (1 : ℤ)) (X_add_one_mul_alexander_odd hN)
  simp at h
  omega

/-! ## Semiprimes -/

lemma divisors_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) :
    (p * q).divisors = {1, p, q, p * q} := by
  have hpq : p * q ≠ 0 := Nat.mul_ne_zero hp.pos.ne' hq.pos.ne'
  ext d
  simp only [Nat.mem_divisors, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · rintro ⟨hdvd, -⟩
    obtain ⟨a, b, ha, hb, rfl⟩ := Nat.dvd_mul.1 hdvd
    rcases (Nat.Prime.eq_one_or_self_of_dvd hp a ha) with rfl | rfl <;>
      rcases (Nat.Prime.eq_one_or_self_of_dvd hq b hb) with rfl | rfl <;> simp
  · rintro (rfl | rfl | rfl | rfl)
    · exact ⟨one_dvd _, hpq⟩
    · exact ⟨dvd_mul_right _ _, hpq⟩
    · exact ⟨dvd_mul_left _ _, hpq⟩
    · exact ⟨dvd_rfl, hpq⟩

/-- **Semiprime factorization.** For distinct odd primes `p ≠ q` and `N = pq`,
`A_N = Φ_{2p} · Φ_{2q} · Φ_{2N}`. -/
theorem alexander_semiprime_factorization {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpo : Odd p) (hqo : Odd q) (hne : p ≠ q) :
    alexander (p * q)
      = cyclotomic (2 * p) ℤ * cyclotomic (2 * q) ℤ * cyclotomic (2 * (p * q)) ℤ := by
  have hp1 : 1 < p := hp.one_lt
  have hq1 : 1 < q := hq.one_lt
  have hN : Odd (p * q) := hpo.mul hqo
  have h1 : 1 < p * q := by nlinarith
  rw [alexander_eq_prod_cyclotomic hN h1, divisors_semiprime hp hq]
  have hpq : p ≠ p * q := by nlinarith
  have hqq : q ≠ p * q := by nlinarith
  have herase : ({1, p, q, p * q} : Finset ℕ).erase 1 = {p, q, p * q} := by
    ext d
    simp only [Finset.mem_erase, Finset.mem_insert, Finset.mem_singleton]
    constructor
    · rintro ⟨h, rfl | rfl | rfl | rfl⟩ <;> simp_all
    · rintro (rfl | rfl | rfl) <;> exact ⟨by omega, by simp⟩
  rw [herase, Finset.prod_insert (by simp [hne, hpq]), Finset.prod_insert (by simp [hqq]),
    Finset.prod_singleton, mul_assoc]

/-! ## Degrees of the irreducible factors -/

lemma totient_two_mul_of_odd {n : ℕ} (hn : Odd n) : Nat.totient (2 * n) = Nat.totient n := by
  rw [Nat.totient_mul (Nat.coprime_two_left.2 hn), Nat.totient_two, one_mul]

lemma natDegree_cyclotomic_two_mul_prime {p : ℕ} (hp : p.Prime) (hpo : Odd p) :
    (cyclotomic (2 * p) ℤ).natDegree = p - 1 := by
  rw [natDegree_cyclotomic, totient_two_mul_of_odd hpo, Nat.totient_prime hp]

lemma natDegree_cyclotomic_two_mul_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpo : Odd p) (hqo : Odd q) (hne : p ≠ q) :
    (cyclotomic (2 * (p * q)) ℤ).natDegree = (p - 1) * (q - 1) := by
  rw [natDegree_cyclotomic, totient_two_mul_of_odd (hpo.mul hqo),
    Nat.totient_mul ((Nat.coprime_primes hp hq).2 hne), Nat.totient_prime hp,
    Nat.totient_prime hq]

/-- The three factors of `A_{pq}` have degrees `p-1`, `q-1`, `(p-1)(q-1)`,
and each is irreducible over `ℤ`. -/
theorem alexander_semiprime_factor_data {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpo : Odd p) (hqo : Odd q) (hne : p ≠ q) :
    (cyclotomic (2 * p) ℤ).natDegree = p - 1 ∧
    (cyclotomic (2 * q) ℤ).natDegree = q - 1 ∧
    (cyclotomic (2 * (p * q)) ℤ).natDegree = (p - 1) * (q - 1) ∧
    Irreducible (cyclotomic (2 * p) ℤ) ∧ Irreducible (cyclotomic (2 * q) ℤ) ∧
    Irreducible (cyclotomic (2 * (p * q)) ℤ) := by
  have hpp := hp.pos
  have hqp := hq.pos
  refine ⟨natDegree_cyclotomic_two_mul_prime hp hpo,
    natDegree_cyclotomic_two_mul_prime hq hqo,
    natDegree_cyclotomic_two_mul_semiprime hp hq hpo hqo hne,
    cyclotomic.irreducible (by omega), cyclotomic.irreducible (by omega),
    cyclotomic.irreducible (by positivity)⟩

/-- The degrees of the three factors sum to `deg A_{pq} = pq - 1`. -/
theorem alexander_semiprime_degree_sum {p q : ℕ} (hp : p.Prime) (hq : q.Prime) :
    (p - 1) + (q - 1) + (p - 1) * (q - 1) = p * q - 1 := by
  obtain ⟨a, rfl⟩ := Nat.exists_eq_add_of_le hp.one_lt.le
  obtain ⟨b, rfl⟩ := Nat.exists_eq_add_of_le hq.one_lt.le
  have h : (1 + a) * (1 + b) = 1 + (a + b + a * b) := by ring
  simp only [Nat.add_sub_cancel_left, h]

/-! ## Recovering the factorization from the degree data -/

/-- `φ(pq) = (p-1)(q-1)` and `p + q = pq + 1 - φ(pq)`. -/
theorem totient_semiprime_and_sum {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) :
    Nat.totient (p * q) = (p - 1) * (q - 1) ∧
    p + q = p * q + 1 - Nat.totient (p * q) := by
  have ht : Nat.totient (p * q) = (p - 1) * (q - 1) := by
    rw [Nat.totient_mul ((Nat.coprime_primes hp hq).2 hne), Nat.totient_prime hp,
      Nat.totient_prime hq]
  refine ⟨ht, ?_⟩
  rw [ht]
  obtain ⟨a, rfl⟩ := Nat.exists_eq_add_of_le hp.one_lt.le
  obtain ⟨b, rfl⟩ := Nat.exists_eq_add_of_le hq.one_lt.le
  have h : (1 + a) * (1 + b) = 1 + (a + b + a * b) := by ring
  simp only [Nat.add_sub_cancel_left, h]
  omega

/-- **Recovery.** From `N = pq` and the degree data (equivalently `φ(N)`), the primes are
recovered as the roots of `t² - s t + N` with `s = N + 1 - φ(N)`:
`p = (s - √(s²-4N))/2`, `q = (s + √(s²-4N))/2`. -/
theorem recover_factors_from_degrees {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hlt : p < q)
    (s : ℕ) (hs : s = p * q + 1 - Nat.totient (p * q)) :
    (s - Nat.sqrt (s ^ 2 - 4 * (p * q))) / 2 = p ∧
    (s + Nat.sqrt (s ^ 2 - 4 * (p * q))) / 2 = q := by
  obtain ⟨-, hsum⟩ := totient_semiprime_and_sum hp hq hlt.ne
  have hspq : s = p + q := by omega
  have hdisc : s ^ 2 - 4 * (p * q) = (q - p) ^ 2 := by
    rw [hspq]
    obtain ⟨c, rfl⟩ := Nat.exists_eq_add_of_le hlt.le
    have h : (p + (p + c)) ^ 2 = c ^ 2 + 4 * (p * (p + c)) := by ring
    simp only [Nat.add_sub_cancel_left]
    omega
  rw [hdisc, Nat.sqrt_eq']
  omega

/-! ## Irreducibility of `A_N` characterizes primality of `N` -/

lemma alexander_prime {N : ℕ} (hN : Odd N) (hprime : N.Prime) :
    alexander N = cyclotomic (2 * N) ℤ := by
  have h1 : 1 < N := hprime.one_lt
  rw [alexander_eq_prod_cyclotomic hN h1, hprime.divisors]
  have herase : ({1, N} : Finset ℕ).erase 1 = {N} := by
    ext d
    simp only [Finset.mem_erase, Finset.mem_insert, Finset.mem_singleton]
    constructor
    · rintro ⟨h, rfl | rfl⟩ <;> simp_all
    · rintro rfl; exact ⟨by omega, by simp⟩
  rw [herase, Finset.prod_singleton]

/-- If `N` is odd, `> 1` and composite, then `A_N` factors as `Φ_{2d} · (rest)` with both
factors of positive degree, hence is reducible. -/
lemma alexander_not_irreducible_of_not_prime {N : ℕ} (hN : Odd N) (h1 : 1 < N)
    (hnp : ¬ N.Prime) : ¬ Irreducible (alexander N) := by
  obtain ⟨d, hdvd, hd1, hdN⟩ : ∃ d, d ∣ N ∧ d ≠ 1 ∧ d ≠ N := by
    obtain ⟨m, hm, hm1, hmN⟩ := Nat.exists_dvd_of_not_prime2 h1 hnp
    exact ⟨m, hm, by omega, by omega⟩
  have hpos : 0 < N := by omega
  have hdpos : 0 < d := Nat.pos_of_dvd_of_pos hdvd hpos
  have hdmem : d ∈ N.divisors.erase 1 :=
    Finset.mem_erase.2 ⟨hd1, Nat.mem_divisors.2 ⟨hdvd, hpos.ne'⟩⟩
  have hfac : alexander N =
      cyclotomic (2 * d) ℤ * ∏ e ∈ (N.divisors.erase 1).erase d, cyclotomic (2 * e) ℤ := by
    rw [alexander_eq_prod_cyclotomic hN h1,
      ← Finset.mul_prod_erase _ (fun e => cyclotomic (2 * e) ℤ) hdmem]
  intro hirr
  have hdodd : Odd d := odd_of_dvd_odd hN hdvd
  have hdlt : d < N := lt_of_le_of_ne (Nat.le_of_dvd hpos hdvd) hdN
  set Q : ℤ[X] := ∏ e ∈ (N.divisors.erase 1).erase d, cyclotomic (2 * e) ℤ with hQ
  have hAne : alexander N ≠ 0 := alexander_ne_zero hN
  have hCne : cyclotomic (2 * d) ℤ ≠ 0 := fun h => hAne (by rw [hfac, h, zero_mul])
  have hQne : Q ≠ 0 := fun h => hAne (by rw [hfac, h, mul_zero])
  have hdegC : (cyclotomic (2 * d) ℤ).natDegree = Nat.totient d := by
    rw [natDegree_cyclotomic, totient_two_mul_of_odd hdodd]
  have hsum : (alexander N).natDegree = Nat.totient d + Q.natDegree := by
    rw [hfac, natDegree_mul hCne hQne, hdegC]
  have htot : Nat.totient d < d := Nat.totient_lt d (by omega)
  have hdegQ : 0 < Q.natDegree := by
    have hA := alexander_natDegree hN
    omega
  have hCpos : 0 < (cyclotomic (2 * d) ℤ).natDegree := by
    rw [hdegC]; exact Nat.totient_pos.2 hdpos
  rcases hirr.isUnit_or_isUnit hfac with hu | hu
  · exact (Polynomial.not_isUnit_of_natDegree_pos _ hCpos) hu
  · exact (Polynomial.not_isUnit_of_natDegree_pos _ hdegQ) hu

/-- **Primality detector.** For odd `N > 1`, the Alexander polynomial of `T(2,N)` is
irreducible over `ℤ` if and only if `N` is prime. -/
theorem alexander_irreducible_iff_prime {N : ℕ} (hN : Odd N) (h1 : 1 < N) :
    Irreducible (alexander N) ↔ N.Prime := by
  constructor
  · intro h
    by_contra hnp
    exact alexander_not_irreducible_of_not_prime hN h1 hnp h
  · intro hp
    rw [alexander_prime hN hp]
    exact cyclotomic.irreducible (by omega)

end Bridges.AlexanderTorus