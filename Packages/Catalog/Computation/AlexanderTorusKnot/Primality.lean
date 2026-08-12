/-
# Knot-level irreducibility ⇔ primality of both torus parameters

Third cycle of the knot–number bridge. The catalog proves, for the pencil `T(2,N)`, that
`A_N` is irreducible over `ℤ` iff `N` is prime
(`Bridges.AlexanderTorus.alexander_irreducible_iff_prime`). Cycle 1 of this project
constructed the Alexander polynomial `Δ_{a,b}` of a general torus knot `T(a,b)`.

Here we prove the two-parameter generalization:

* `torusAlexander_irreducible_iff` : for coprime `a, b > 1`, `Δ_{a,b}` is **irreducible over
  `ℤ` iff both `a` and `b` are prime**. (Taking `a = 2` recovers the catalog statement.)
* `spectrum_eq_singleton_of_primes` / `torusAlexander_eq_cyclotomic_of_primes` :
  for distinct primes `p ≠ q`, `Δ_{p,q} = Φ_{pq}`, a single irreducible factor.
* `torusAlexander_natDegree_eq_totient` : `deg Δ_{p,q} = φ(pq)` — so for the semiprime
  `N = pq` the *degree of the Alexander polynomial of `T(p,q)`* is Euler's totient of `N`.
* `torus_semiprime_pipeline` : consequently `p` and `q` are recovered from
  `s = N + 1 - deg Δ_{p,q}` by the quadratic formula, an alternative to the `T(2,N)`
  pipeline of the catalog and equally obstructed: writing `Δ_{p,q}` down costs
  `φ(N) ≈ N` coefficients.
-/
import Computation.AlexanderTorusKnot.GeneralTorus

namespace Computation.AlexanderTorusKnot

open Polynomial Finset

/-! ## Two divisors means prime -/

lemma prime_of_card_divisors_eq_two {a : ℕ} (ha : 1 < a) (h : a.divisors.card = 2) :
    a.Prime := by
  have hsub : ({1, a} : Finset ℕ) ⊆ a.divisors := by
    intro d hd
    simp only [Finset.mem_insert, Finset.mem_singleton] at hd
    rcases hd with rfl | rfl
    · exact Nat.one_mem_divisors.2 (by omega)
    · exact Nat.mem_divisors_self _ (by omega)
  have hcard : ({1, a} : Finset ℕ).card = 2 := by
    rw [Finset.card_insert_of_notMem (by simp; omega), Finset.card_singleton]
  have heq : ({1, a} : Finset ℕ) = a.divisors :=
    Finset.eq_of_subset_of_card_le hsub (by omega)
  rw [Nat.prime_def]
  refine ⟨ha, fun m hm => ?_⟩
  have : m ∈ a.divisors := Nat.mem_divisors.2 ⟨hm, by omega⟩
  rw [← heq] at this
  simpa using this

/-! ## The spectrum of a product of two primes -/

/-- For distinct primes `p, q` the divisor spectrum of `T(p,q)` is the singleton `{pq}`. -/
theorem spectrum_eq_singleton_of_primes {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) :
    spectrum p q = {p * q} := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).2 hne
  ext d
  simp only [mem_spectrum, Finset.mem_singleton]
  constructor
  · rintro ⟨hdvd, -, hna, hnb⟩
    have hmem : d ∈ (p * q).divisors :=
      Nat.mem_divisors.2 ⟨hdvd, Nat.mul_ne_zero hp.pos.ne' hq.pos.ne'⟩
    rw [Nat.divisors_mul, hp.divisors, hq.divisors] at hmem
    obtain ⟨d₁, hd₁, d₂, hd₂, rfl⟩ := Finset.mem_mul.1 hmem
    simp only [Finset.mem_insert, Finset.mem_singleton] at hd₁ hd₂
    rcases hd₁ with rfl | rfl <;> rcases hd₂ with rfl | rfl <;> simp_all
  · rintro rfl
    refine ⟨dvd_rfl, Nat.mul_ne_zero hp.pos.ne' hq.pos.ne', ?_, ?_⟩
    · intro h
      have := Nat.le_of_dvd hp.pos h
      nlinarith [hq.one_lt, hp.one_lt]
    · intro h
      have := Nat.le_of_dvd hq.pos h
      nlinarith [hq.one_lt, hp.one_lt]

/-- For distinct primes `p ≠ q`, the Alexander polynomial of `T(p,q)` is the single
cyclotomic polynomial `Φ_{pq}`. -/
theorem torusAlexander_eq_cyclotomic_of_primes {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hne : p ≠ q) : torusAlexander p q = cyclotomic (p * q) ℤ := by
  rw [torusAlexander, spectrum_eq_singleton_of_primes hp hq hne, Finset.prod_singleton]

/-- Its degree is Euler's totient of the semiprime `N = pq`. -/
theorem torusAlexander_natDegree_eq_totient {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hne : p ≠ q) : (torusAlexander p q).natDegree = Nat.totient (p * q) := by
  rw [torusAlexander_eq_cyclotomic_of_primes hp hq hne, natDegree_cyclotomic]

/-! ## Irreducibility over `ℤ` characterizes primality of both parameters -/

lemma natDegree_cyclotomic_pos {d : ℕ} (hd : 0 < d) : 0 < (cyclotomic d ℤ).natDegree := by
  rw [natDegree_cyclotomic]
  exact Nat.totient_pos.2 hd

lemma pos_of_mem_spectrum {a b d : ℕ} (hd : d ∈ spectrum a b) : 0 < d := by
  rcases Nat.eq_zero_or_pos d with rfl | h
  · exact absurd (mem_spectrum.1 hd).1 (by simp [(mem_spectrum.1 hd).2.1])
  · exact h

/-- **Knot irreducibility = double primality.** For coprime `a, b > 1`, the Alexander
polynomial of the torus knot `T(a,b)` is irreducible over `ℤ` exactly when both `a` and `b`
are prime. -/
theorem torusAlexander_irreducible_iff {a b : ℕ} (hab : Nat.Coprime a b) (ha : 1 < a)
    (hb : 1 < b) : Irreducible (torusAlexander a b) ↔ a.Prime ∧ b.Prime := by
  have hapos : 0 < a := by omega
  have hbpos : 0 < b := by omega
  constructor
  · intro hirr
    -- irreducibility forces the spectrum to be a singleton, hence `(τa-1)(τb-1) = 1`
    have hmem : a * b ∈ spectrum a b := by
      refine mem_spectrum.2 ⟨dvd_rfl, by positivity, ?_, ?_⟩
      · intro h; nlinarith [Nat.le_of_dvd hapos h]
      · intro h; nlinarith [Nat.le_of_dvd hbpos h]
    have hcard1 : (spectrum a b).card = 1 := by
      by_contra hne
      have hge : 2 ≤ (spectrum a b).card := by
        have : 1 ≤ (spectrum a b).card := Finset.card_pos.2 ⟨_, hmem⟩
        omega
      -- split off one cyclotomic factor
      obtain ⟨d, hd⟩ : ∃ d, d ∈ spectrum a b := ⟨_, hmem⟩
      have hsplit : torusAlexander a b
          = cyclotomic d ℤ * ∏ e ∈ (spectrum a b).erase d, cyclotomic e ℤ := by
        rw [torusAlexander, ← Finset.mul_prod_erase _ _ hd]
      have hleft : ¬ IsUnit (cyclotomic d ℤ) := by
        intro hu
        have := Polynomial.natDegree_eq_zero_of_isUnit hu
        have := natDegree_cyclotomic_pos (pos_of_mem_spectrum hd)
        omega
      have hright : ¬ IsUnit (∏ e ∈ (spectrum a b).erase d, cyclotomic e ℤ) := by
        intro hu
        have hdeg := Polynomial.natDegree_eq_zero_of_isUnit hu
        rw [natDegree_prod _ _ (fun e _ => (cyclotomic.monic e ℤ).ne_zero)] at hdeg
        obtain ⟨e, he⟩ : ∃ e, e ∈ (spectrum a b).erase d := by
          have : 0 < ((spectrum a b).erase d).card := by
            rw [Finset.card_erase_of_mem hd]; omega
          exact Finset.card_pos.1 this
        have hpos : 0 < (cyclotomic e ℤ).natDegree :=
          natDegree_cyclotomic_pos (pos_of_mem_spectrum (Finset.mem_of_mem_erase he))
        have hle : (cyclotomic e ℤ).natDegree
            ≤ ∑ x ∈ (spectrum a b).erase d, (cyclotomic x ℤ).natDegree :=
          Finset.single_le_sum (f := fun x => (cyclotomic x ℤ).natDegree)
            (fun _ _ => Nat.zero_le _) he
        omega
      rcases hirr.isUnit_or_isUnit hsplit with hu | hu
      · exact hleft hu
      · exact hright hu
    rw [torusAlexander_card_factors hab hapos hbpos] at hcard1
    have hda : 0 < a.divisors.card := Finset.card_pos.2 ⟨1, Nat.one_mem_divisors.2 (by omega)⟩
    have hdb : 0 < b.divisors.card := Finset.card_pos.2 ⟨1, Nat.one_mem_divisors.2 (by omega)⟩
    obtain ⟨hx, hy⟩ := mul_eq_one.1 hcard1
    exact ⟨prime_of_card_divisors_eq_two ha (by omega),
      prime_of_card_divisors_eq_two hb (by omega)⟩
  · rintro ⟨hpa, hpb⟩
    have hne : a ≠ b := by
      rintro rfl
      rw [Nat.Coprime, Nat.gcd_self] at hab
      omega
    rw [torusAlexander_eq_cyclotomic_of_primes hpa hpb hne]
    exact cyclotomic.irreducible (by positivity)

/-! ## The `T(p,q)` factoring pipeline (and its cost) -/

open Bridges.AlexanderTorus in
/-- **The semiprime pipeline through `T(p,q)`.** For odd primes `p < q` and `N = pq`, the
degree `m` of the Alexander polynomial of `T(p,q)` equals `φ(N)`, and the two primes are
recovered from `s = N + 1 - m` by the quadratic formula. -/
theorem torus_semiprime_pipeline {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hlt : p < q)
    (m : ℕ) (hm : m = (torusAlexander p q).natDegree) (s : ℕ) (hs : s = p * q + 1 - m) :
    m = Nat.totient (p * q) ∧
      (s - Nat.sqrt (s ^ 2 - 4 * (p * q))) / 2 = p ∧
      (s + Nat.sqrt (s ^ 2 - 4 * (p * q))) / 2 = q := by
  have hmt : m = Nat.totient (p * q) := by
    rw [hm, torusAlexander_natDegree_eq_totient hp hq (by omega)]
  exact ⟨hmt, recover_factors_from_degrees hp hq hlt s (by rw [hs, hmt])⟩

/-- The cost of the pipeline: the polynomial one must write down has degree `φ(N)`, which
for a semiprime `N = pq` is at least `(N - 1) / 2` — exponential in the bit length of `N`. -/
theorem torus_semiprime_pipeline_cost {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hp2 : 2 < p)
    (hlt : p < q) : 2 * (torusAlexander p q).natDegree + 1 ≥ p * q := by
  rw [torusAlexander_natDegree_eq_totient hp hq (by omega),
    Nat.totient_mul ((Nat.coprime_primes hp hq).2 (by omega)),
    Nat.totient_prime hp, Nat.totient_prime hq]
  obtain ⟨p', rfl⟩ : ∃ p', p = p' + 3 := ⟨p - 3, by omega⟩
  obtain ⟨r, rfl⟩ : ∃ r, q = p' + 4 + r := ⟨q - p' - 4, by omega⟩
  have e1 : p' + 3 - 1 = p' + 2 := by omega
  have e2 : p' + 4 + r - 1 = p' + 3 + r := by omega
  rw [e1, e2]
  nlinarith

end Computation.AlexanderTorusKnot