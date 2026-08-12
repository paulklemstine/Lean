/-
# The Alexander polynomial of a general torus knot `T(a,b)` as a cyclotomic divisor spectrum

The catalog file `Bridges.AlexanderKnotNumberBridge` studies the `(2,N)` torus knot,
whose Alexander polynomial is `A_N(X) = (X^N+1)/(X+1)`, and shows that its irreducible
factorization over `ℤ` is `∏_{d ∣ N, d > 1} Φ_{2d}`, so that the *degree spectrum* of the
knot invariant encodes the divisors of `N`.

This file lifts the bridge from the pencil `T(2,N)` to **all** torus knots `T(a,b)`
(`gcd(a,b) = 1`), where the Alexander polynomial is

  `Δ_{a,b}(X) = (X^{ab} - 1)(X - 1) / ((X^a - 1)(X^b - 1))`.

We *define* `Δ_{a,b}` as the cyclotomic product over the divisor set

  `S(a,b) = {d : d ∣ ab, d ∤ a, d ∤ b}`

and then *prove* the classical rational expression, so that no division is ever needed.

Main results (all for coprime `a, b`):

* `torusAlexander_spec` : `(X^{ab} - 1) * (X - 1) = Δ_{a,b} * ((X^a - 1) * (X^b - 1))`
  — the defining identity of the torus-knot Alexander polynomial.
* `torusAlexander_natDegree` : `deg Δ_{a,b} = (a-1)(b-1)`, twice the Seifert genus.
* `torusAlexander_card_factors` : `Δ_{a,b}` is a product of `(τ(a) - 1) * (τ(b) - 1)`
  irreducible cyclotomic factors, where `τ` counts divisors: the *number* of factors is a
  divisor-counting invariant of the pair `(a,b)`.
* `torusAlexander_eval_one` : `Δ_{a,b}(1) = 1` — the classical normalization condition
  satisfied by the Alexander polynomial of a knot; here it comes out of the fact that no
  element of `S(a,b)` is a prime power.
* `torusAlexander_two_eq_alexander` : for odd `N`, `Δ_{2,N}` is exactly the catalog's
  `Bridges.AlexanderTorus.alexander N`, so the general theory specializes to the
  knot–number bridge of the catalog.
* `torusAlexander_semiprime_degrees` : for distinct odd primes `p ≠ q`, the degree
  multiset of the irreducible factors of `Δ_{2,pq}` is `{p-1, q-1, (p-1)(q-1)}`.
-/
import Bridges.AlexanderKnotNumberBridgeV

namespace Computation.AlexanderTorusKnot

open Polynomial Finset

/-! ## The divisor spectrum of a torus knot -/

/-- The *divisor spectrum* of the torus knot `T(a,b)`: the divisors of `ab` that divide
neither `a` nor `b`. These index the irreducible (cyclotomic) factors of the Alexander
polynomial of `T(a,b)`. -/
def spectrum (a b : ℕ) : Finset ℕ :=
  (a * b).divisors.filter (fun d => ¬ d ∣ a ∧ ¬ d ∣ b)

/-- The Alexander polynomial of the torus knot `T(a,b)`, defined as the product of the
cyclotomic polynomials indexed by the divisor spectrum. -/
noncomputable def torusAlexander (a b : ℕ) : ℤ[X] :=
  ∏ d ∈ spectrum a b, cyclotomic d ℤ

lemma mem_spectrum {a b d : ℕ} :
    d ∈ spectrum a b ↔ d ∣ a * b ∧ a * b ≠ 0 ∧ ¬ d ∣ a ∧ ¬ d ∣ b := by
  simp [spectrum, Nat.mem_divisors, and_assoc]

/-- The divisors of `a` together with the divisors of `b` are exactly the divisors of `ab`
that are *not* in the spectrum. -/
lemma divisors_union_eq_filter {a b : ℕ} (ha : a ≠ 0) (hb : b ≠ 0) :
    a.divisors ∪ b.divisors
      = (a * b).divisors.filter (fun d => ¬ (¬ d ∣ a ∧ ¬ d ∣ b)) := by
  ext d
  simp only [Finset.mem_union, Nat.mem_divisors, Finset.mem_filter, not_and_or, not_not]
  constructor
  · rintro (⟨hd, -⟩ | ⟨hd, -⟩)
    · exact ⟨⟨hd.mul_right b, mul_ne_zero ha hb⟩, Or.inl hd⟩
    · exact ⟨⟨hd.mul_left a, mul_ne_zero ha hb⟩, Or.inr hd⟩
  · rintro ⟨⟨hd, -⟩, h | h⟩
    · exact Or.inl ⟨h, ha⟩
    · exact Or.inr ⟨h, hb⟩

/-- For coprime `a, b` the divisor sets of `a` and `b` meet only in `1`. -/
lemma divisors_inter {a b : ℕ} (hab : Nat.Coprime a b) (ha : a ≠ 0) (hb : b ≠ 0) :
    a.divisors ∩ b.divisors = {1} := by
  ext d
  simp only [Finset.mem_inter, Nat.mem_divisors, Finset.mem_singleton]
  constructor
  · rintro ⟨⟨hda, -⟩, ⟨hdb, -⟩⟩
    exact Nat.eq_one_of_dvd_coprimes hab hda hdb
  · rintro rfl
    exact ⟨⟨one_dvd _, ha⟩, ⟨one_dvd _, hb⟩⟩

/-! ## The defining identity -/

/-- The complementary product: over the divisors of `ab` that *are* accounted for by `a`
or by `b`. -/
lemma prod_compl_mul_X_sub_one {a b : ℕ} (hab : Nat.Coprime a b) (ha : 0 < a) (hb : 0 < b) :
    (∏ d ∈ (a * b).divisors.filter (fun d => ¬ (¬ d ∣ a ∧ ¬ d ∣ b)), cyclotomic d ℤ) * (X - 1)
      = (X ^ a - 1) * (X ^ b - 1) := by
  have hunion := Finset.prod_union_inter (s₁ := a.divisors) (s₂ := b.divisors)
    (f := fun d => cyclotomic d ℤ)
  rw [divisors_inter hab ha.ne' hb.ne', Finset.prod_singleton, cyclotomic_one,
    prod_cyclotomic_eq_X_pow_sub_one ha ℤ, prod_cyclotomic_eq_X_pow_sub_one hb ℤ,
    divisors_union_eq_filter ha.ne' hb.ne'] at hunion
  exact hunion

/-- **The Alexander polynomial of `T(a,b)`.** For coprime positive `a, b`,
`(X^{ab} - 1)(X - 1) = Δ_{a,b} · (X^a - 1)(X^b - 1)`, i.e. `Δ_{a,b}` is the usual
rational expression, realised as an honest polynomial. -/
theorem torusAlexander_spec {a b : ℕ} (hab : Nat.Coprime a b) (ha : 0 < a) (hb : 0 < b) :
    (X ^ (a * b) - 1 : ℤ[X]) * (X - 1)
      = torusAlexander a b * ((X ^ a - 1) * (X ^ b - 1)) := by
  have hsplit :
      torusAlexander a b *
          (∏ d ∈ (a * b).divisors.filter (fun d => ¬ (¬ d ∣ a ∧ ¬ d ∣ b)), cyclotomic d ℤ)
        = X ^ (a * b) - 1 := by
    rw [torusAlexander, spectrum,
      Finset.prod_filter_mul_prod_filter_not (a * b).divisors _ (fun d => cyclotomic d ℤ),
      prod_cyclotomic_eq_X_pow_sub_one (Nat.mul_pos ha hb) ℤ]
  rw [← hsplit, ← prod_compl_mul_X_sub_one hab ha hb]
  ring

/-! ## Degree, number of factors, normalization -/

lemma torusAlexander_monic (a b : ℕ) : (torusAlexander a b).Monic :=
  monic_prod_of_monic _ _ fun d _ => cyclotomic.monic d ℤ

/-- The totient sum over the divisor spectrum: `∑_{d ∈ S(a,b)} φ(d) + (a + b - 1) = ab`. -/
lemma sum_totient_spectrum {a b : ℕ} (hab : Nat.Coprime a b) (ha : 0 < a) (hb : 0 < b) :
    ∑ d ∈ spectrum a b, Nat.totient d = (a - 1) * (b - 1) := by
  have hsplit :
      (∑ d ∈ spectrum a b, Nat.totient d)
        + ∑ d ∈ (a * b).divisors.filter (fun d => ¬ (¬ d ∣ a ∧ ¬ d ∣ b)), Nat.totient d
          = a * b := by
    rw [spectrum, Finset.sum_filter_add_sum_filter_not (a * b).divisors _ Nat.totient]
    exact Nat.sum_totient (a * b)
  have hcompl := Finset.sum_union_inter (s₁ := a.divisors) (s₂ := b.divisors) (f := Nat.totient)
  rw [divisors_inter hab ha.ne' hb.ne', Finset.sum_singleton, Nat.totient_one,
    Nat.sum_totient a, Nat.sum_totient b, divisors_union_eq_filter ha.ne' hb.ne'] at hcompl
  obtain ⟨a', rfl⟩ : ∃ a', a = a' + 1 := ⟨a - 1, by omega⟩
  obtain ⟨b', rfl⟩ : ∃ b', b = b' + 1 := ⟨b - 1, by omega⟩
  have hmul : (a' + 1) * (b' + 1) = a' * b' + a' + b' + 1 := by ring
  simp only [Nat.add_sub_cancel]
  omega

/-- The degree of `Δ_{a,b}` is `(a-1)(b-1)`, i.e. twice the Seifert genus of `T(a,b)`. -/
theorem torusAlexander_natDegree {a b : ℕ} (hab : Nat.Coprime a b) (ha : 0 < a) (hb : 0 < b) :
    (torusAlexander a b).natDegree = (a - 1) * (b - 1) := by
  rw [torusAlexander, natDegree_prod _ _ (fun d _ => (cyclotomic.monic d ℤ).ne_zero)]
  simp only [natDegree_cyclotomic]
  exact sum_totient_spectrum hab ha hb

/-- The number of irreducible cyclotomic factors of `Δ_{a,b}` is `(τ a - 1)(τ b - 1)`,
where `τ` is the number-of-divisors function. -/
theorem torusAlexander_card_factors {a b : ℕ} (hab : Nat.Coprime a b) (ha : 0 < a) (hb : 0 < b) :
    (spectrum a b).card = (a.divisors.card - 1) * (b.divisors.card - 1) := by
  have hsplit :
      (spectrum a b).card
        + ((a * b).divisors.filter (fun d => ¬ (¬ d ∣ a ∧ ¬ d ∣ b))).card
          = (a * b).divisors.card := by
    rw [spectrum, Finset.card_filter_add_card_filter_not]
  have hcompl := Finset.card_union_add_card_inter a.divisors b.divisors
  rw [divisors_inter hab ha.ne' hb.ne', Finset.card_singleton,
    divisors_union_eq_filter ha.ne' hb.ne'] at hcompl
  have hmulcard : (a * b).divisors.card = a.divisors.card * b.divisors.card :=
    Nat.Coprime.card_divisors_mul hab
  have hpa : 0 < a.divisors.card :=
    Finset.card_pos.2 ⟨1, Nat.one_mem_divisors.2 ha.ne'⟩
  have hpb : 0 < b.divisors.card :=
    Finset.card_pos.2 ⟨1, Nat.one_mem_divisors.2 hb.ne'⟩
  obtain ⟨x, hx⟩ : ∃ x, a.divisors.card = x + 1 := ⟨a.divisors.card - 1, by omega⟩
  obtain ⟨y, hy⟩ : ∃ y, b.divisors.card = y + 1 := ⟨b.divisors.card - 1, by omega⟩
  have hxy : (x + 1) * (y + 1) = x * y + x + y + 1 := by ring
  rw [hx, hy] at hmulcard hcompl ⊢
  simp only [Nat.add_sub_cancel]
  omega

/-- No element of the divisor spectrum is a prime power. -/
lemma not_isPrimePow_of_mem_spectrum {a b d : ℕ} (hab : Nat.Coprime a b)
    (hd : d ∈ spectrum a b) : ¬ IsPrimePow d := by
  rw [mem_spectrum] at hd
  obtain ⟨hdvd, -, hna, hnb⟩ := hd
  rintro ⟨p, k, hp, hk, rfl⟩
  have hpn : Nat.Prime p := Nat.prime_iff.2 hp
  by_cases hpb : p ∣ b
  · have hpa : ¬ p ∣ a := fun h => hpn.one_lt.ne' (Nat.eq_one_of_dvd_coprimes hab h hpb)
    have hcop : Nat.Coprime (p ^ k) a :=
      Nat.Coprime.pow_left k ((Nat.Prime.coprime_iff_not_dvd hpn).2 hpa)
    exact hnb (hcop.dvd_of_dvd_mul_left hdvd)
  · have hcop : Nat.Coprime (p ^ k) b :=
      Nat.Coprime.pow_left k ((Nat.Prime.coprime_iff_not_dvd hpn).2 hpb)
    exact hna (hcop.dvd_of_dvd_mul_right hdvd)

/-- Pointwise form of the previous lemma, in the shape required by
`Polynomial.eval_one_cyclotomic_not_prime_pow`. -/
lemma spectrum_ne_prime_pow {a b d : ℕ} (hab : Nat.Coprime a b) (hd : d ∈ spectrum a b)
    {p : ℕ} (hp : p.Prime) (k : ℕ) : p ^ k ≠ d := by
  rintro rfl
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · rw [mem_spectrum] at hd
    exact hd.2.2.1 (by simp)
  · exact not_isPrimePow_of_mem_spectrum hab hd ⟨p, k, Nat.prime_iff.1 hp, hk, rfl⟩

/-- **Normalization.** `Δ_{a,b}(1) = 1`: the Alexander polynomial of a torus *knot*
evaluates to `1` at `1`, as any knot's Alexander polynomial must. -/
theorem torusAlexander_eval_one {a b : ℕ} (hab : Nat.Coprime a b) :
    (torusAlexander a b).eval 1 = 1 := by
  rw [torusAlexander, eval_prod]
  refine Finset.prod_eq_one fun d hd => ?_
  exact eval_one_cyclotomic_not_prime_pow (fun hp k => spectrum_ne_prime_pow hab hd hp k)

/-! ## Specialization to the catalog's `T(2,N)` bridge -/

/-- For odd `N`, the divisor spectrum of `T(2,N)` consists exactly of the doubles `2d` of
the divisors `d > 1` of `N`. -/
lemma spectrum_two {N : ℕ} (hN : Odd N) (h1 : 1 < N) :
    spectrum 2 N = (N.divisors.erase 1).image (fun d => 2 * d) := by
  have hpos : 0 < N := by omega
  ext d
  simp only [mem_spectrum, Finset.mem_image, Finset.mem_erase, Nat.mem_divisors]
  constructor
  · rintro ⟨hdvd, -, hna, hnb⟩
    rcases Nat.even_or_odd d with he | ho
    · obtain ⟨e, rfl⟩ := he
      have hde : (2 : ℕ) * e ∣ 2 * N := by simpa [two_mul] using hdvd
      have heN : e ∣ N := (mul_dvd_mul_iff_left (by norm_num : (2 : ℕ) ≠ 0)).1 hde
      refine ⟨e, ⟨?_, heN, hpos.ne'⟩, by ring⟩
      rintro rfl
      exact hna (by simp)
    · exact absurd (Nat.Coprime.dvd_of_dvd_mul_left (Nat.coprime_two_right.2 ho) hdvd) hnb
  · rintro ⟨e, ⟨he1, heN, -⟩, rfl⟩
    have he2 : 2 ≤ e := by
      rcases Nat.eq_zero_or_pos e with rfl | hpe
      · exact absurd (Nat.eq_zero_of_zero_dvd heN) hpos.ne'
      · omega
    refine ⟨mul_dvd_mul_left 2 heN, by positivity, ?_, ?_⟩
    · intro h
      have := Nat.le_of_dvd (by norm_num) h
      omega
    · intro h
      have h2 : (2 : ℕ) ∣ N := dvd_trans (dvd_mul_right 2 e) h
      rw [Nat.odd_iff] at hN
      omega

open Bridges.AlexanderTorus in
/-- For odd `N`, the general construction reproduces the catalog's Alexander polynomial
of `T(2,N)`. -/
theorem torusAlexander_two_eq_alexander {N : ℕ} (hN : Odd N) (h1 : 1 < N) :
    torusAlexander 2 N = alexander N := by
  rw [torusAlexander, spectrum_two hN h1,
    Finset.prod_image (fun a _ b _ h => Nat.eq_of_mul_eq_mul_left (by norm_num) h),
    alexander_eq_prod_cyclotomic hN h1]

open Bridges.AlexanderTorus in
/-- For a semiprime `N = pq` the degree multiset of the irreducible factors of `Δ_{2,N}`
is `{p-1, q-1, (p-1)(q-1)}`. -/
theorem torusAlexander_semiprime_degrees {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpo : Odd p) (hqo : Odd q) (hne : p ≠ q) :
    torusAlexander 2 (p * q)
        = cyclotomic (2 * p) ℤ * cyclotomic (2 * q) ℤ * cyclotomic (2 * (p * q)) ℤ ∧
      (cyclotomic (2 * p) ℤ).natDegree = p - 1 ∧
      (cyclotomic (2 * q) ℤ).natDegree = q - 1 ∧
      (cyclotomic (2 * (p * q)) ℤ).natDegree = (p - 1) * (q - 1) := by
  have h1 : 1 < p * q := by nlinarith [hp.one_lt, hq.one_lt]
  refine ⟨?_, natDegree_cyclotomic_two_mul_prime hp hpo,
    natDegree_cyclotomic_two_mul_prime hq hqo,
    natDegree_cyclotomic_two_mul_semiprime hp hq hpo hqo hne⟩
  rw [torusAlexander_two_eq_alexander (hpo.mul hqo) h1,
    alexander_semiprime_factorization hp hq hpo hqo hne]

/-! ## Lab notes: computed divisor spectra

The following spectra are computed by kernel evaluation. They are the data behind the
worked examples: e.g. `T(2,143)` has spectrum `{22, 26, 286}`, whose totients
`{10, 12, 120}` are the degrees of the three irreducible factors of `A_143`, giving
`φ(143) = 120`, `p + q = 143 + 1 - 120 = 24` and hence `{11, 13}`. -/

set_option maxRecDepth 8000 in
example : spectrum 2 3 = {6} := by decide
set_option maxRecDepth 8000 in
example : spectrum 3 5 = {15} := by decide
set_option maxRecDepth 8000 in
example : spectrum 2 15 = {6, 10, 30} := by decide
set_option maxRecDepth 8000 in
example : spectrum 4 9 = {6, 12, 18, 36} := by decide
set_option maxRecDepth 8000 in
example : spectrum 2 143 = {22, 26, 286} := by decide
set_option maxRecDepth 8000 in
example : spectrum 11 13 = {143} := by decide
set_option maxRecDepth 40000 in
example : (Nat.totient 22, Nat.totient 26, Nat.totient 286) = (10, 12, 120) := by decide

end Computation.AlexanderTorusKnot