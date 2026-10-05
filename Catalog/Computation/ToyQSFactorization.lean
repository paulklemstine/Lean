import Mathlib
import Shared.QSFactorBaseDimension

/-!
# From relations to a factor: congruence of squares, the CRT coin flip, and `N = 103764863`

Context (experiment 470, stretch goal).  The toy sieve's relations were pushed
through `𝔽₂` elimination and actually factored `N = 103764863 = 9127 × 11369`.
The dependency search itself is `QSDimension.qs_congruence_of_squares`.  This file
supplies the remaining links of the chain, and the CRT fact governing how often a
dependency is useful.

* `prod_relations_congr` — the product of the relation values `xᵢ² - N` over any
  subset is congruent to `(∏ xᵢ)²` modulo `N`;
* `gcd_nontrivial_of_sq_congr` — a congruence of squares `X² ≡ Y²` with
  `X ≢ ±Y (mod N)` yields a proper divisor `gcd(X - Y, N)`;
* `qs_factor_of_dependency` — end-to-end: a square dependency among relations
  that is not of the trivial form `X ≡ ±Y` factors `N`;
* `card_sqrt_sq_semiprime` / `card_nontrivial_sqrt_semiprime` — **the CRT coin
  flip**: for `N = p q` (distinct odd primes) a unit square has exactly `4` square
  roots modulo `N`, exactly `2` of which are non-trivial.  This explains the toy
  run's observation that the 3-relation dependencies were trivial while the
  4-relation ones factored `N`;
* Lab notes: the actual certificate for `N = 103764863` from the toy run, checked
  through the theorems above.
-/

namespace ToyQSFactor

open Finset

/-- **Relations multiply to a congruence of squares.**  For any finite family of
sieve abscissae `xᵢ`, `N ∣ (∏ xᵢ)² - ∏ (xᵢ² - N)`. -/
theorem prod_relations_congr {ι : Type*} (T : Finset ι) (X : ι → ℤ) (N : ℤ) :
    N ∣ (∏ i ∈ T, X i) ^ 2 - ∏ i ∈ T, (X i ^ 2 - N) := by
  classical
  induction T using Finset.induction_on with
  | empty => simp
  | insert j T hj ih =>
    rw [Finset.prod_insert hj, Finset.prod_insert hj]
    obtain ⟨c, hc⟩ := ih
    refine ⟨X j ^ 2 * c + ∏ i ∈ T, (X i ^ 2 - N), ?_⟩
    have e : (X j * ∏ i ∈ T, X i) ^ 2 - (X j ^ 2 - N) * ∏ i ∈ T, (X i ^ 2 - N)
        = X j ^ 2 * ((∏ i ∈ T, X i) ^ 2 - ∏ i ∈ T, (X i ^ 2 - N))
          + N * ∏ i ∈ T, (X i ^ 2 - N) := by ring
    rw [e, hc]; ring

/-- **Factor extraction.**  If `N ∣ X² - Y²` but `N ∤ X - Y` and `N ∤ X + Y`, then
`gcd(X - Y, N)` is a proper divisor of `N`. -/
theorem gcd_nontrivial_of_sq_congr {N X Y : ℤ} (h : N ∣ X ^ 2 - Y ^ 2)
    (h1 : ¬ N ∣ X - Y) (h2 : ¬ N ∣ X + Y) :
    1 < Int.gcd (X - Y) N ∧ Int.gcd (X - Y) N < N.natAbs := by
  have hprod : N ∣ (X - Y) * (X + Y) := by
    have e : X ^ 2 - Y ^ 2 = (X - Y) * (X + Y) := by ring
    rwa [← e]
  have hN : N ≠ 0 := by
    rintro rfl
    rw [zero_dvd_iff, mul_eq_zero] at hprod
    rcases hprod with h' | h' <;> simp_all
  set g := Int.gcd (X - Y) N with hg
  have hgdvd : (g : ℤ) ∣ N := Int.gcd_dvd_right _ _
  have hgle : g ≤ N.natAbs := Nat.le_of_dvd (Int.natAbs_pos.2 hN) (by
    have := Int.natAbs_dvd_natAbs.2 hgdvd; simpa using this)
  refine ⟨?_, lt_of_le_of_ne hgle ?_⟩
  · by_contra hlt
    push_neg at hlt
    have hg0 : g ≠ 0 := by
      intro h0
      exact hN (Int.gcd_eq_zero_iff.1 h0).2
    have hg1 : g = 1 := by omega
    have hcop : IsCoprime N (X - Y) := by
      rw [Int.isCoprime_iff_gcd_eq_one, Int.gcd_comm]; exact hg1
    exact h2 (hcop.dvd_of_dvd_mul_left hprod)
  · intro heq
    apply h1
    have : (N.natAbs : ℤ) ∣ X - Y := by
      rw [← heq]; exact Int.gcd_dvd_left _ _
    exact (Int.natAbs_dvd.1 this)

/-- **End-to-end factoring from a square dependency.**  Let `xᵢ` (`i ∈ T`) be sieve
abscissae whose relation values multiply to a square `Y²`.  If the dependency is
not trivial (`∏ xᵢ ≢ ±Y mod N`), then `gcd(∏ xᵢ - Y, N)` is a proper factor. -/
theorem qs_factor_of_dependency {ι : Type*} (T : Finset ι) (X : ι → ℤ) {N Y : ℤ}
    (hsq : ∏ i ∈ T, (X i ^ 2 - N) = Y ^ 2)
    (h1 : ¬ N ∣ (∏ i ∈ T, X i) - Y) (h2 : ¬ N ∣ (∏ i ∈ T, X i) + Y) :
    1 < Int.gcd ((∏ i ∈ T, X i) - Y) N ∧ Int.gcd ((∏ i ∈ T, X i) - Y) N < N.natAbs := by
  have := prod_relations_congr T X N
  rw [hsq] at this
  exact gcd_nontrivial_of_sq_congr this h1 h2

/-- **Existence of a dependency from enough relations** (re-export of the catalog
dimension bound in the form used here): more `B`-smooth relations than admissible
primes always contain a nonempty sub-family with square product. -/
theorem exists_square_dependency {B : ℕ} {N : ℤ} {n : ℕ} (X : Fin n → ℤ) (V : Fin n → ℕ)
    (hV0 : ∀ i, V i ≠ 0) (hval : ∀ i, (V i : ℤ) = (X i) ^ 2 - N)
    (hsm : ∀ i, ∀ p ∈ (V i).primeFactors, p ≤ B)
    (hcard : (QSDimension.admissiblePrimes N B).card < n) :
    ∃ T : Finset (Fin n), T.Nonempty ∧ ∃ Y : ℤ, ∏ i ∈ T, (X i ^ 2 - N) = Y ^ 2 ∧
      N ∣ (∏ i ∈ T, X i) ^ 2 - Y ^ 2 := by
  obtain ⟨T, hT, ⟨m, hm⟩⟩ := QSDimension.qs_congruence_of_squares X V hV0 hval hsm hcard
  have e : ∏ i ∈ T, (X i ^ 2 - N) = (m : ℤ) ^ 2 := by
    rw [← Finset.prod_congr rfl (fun i _ => hval i), ← Nat.cast_prod, hm]
    push_cast; ring
  refine ⟨T, hT, m, e, ?_⟩
  have h := prod_relations_congr T X N
  rwa [e] at h

/-! ## The CRT coin flip for `N = p q` -/

section CRT

variable {p q : ℕ} [Fact p.Prime] [Fact q.Prime]

/-- In `ZMod p` (`p` odd prime) a nonzero element differs from its negative. -/
lemma ne_neg_of_ne_zero (hp : p ≠ 2) {a : ZMod p} (ha : a ≠ 0) : a ≠ -a := by
  intro h
  have h2 : (2 : ZMod p) * a = 0 := by linear_combination h
  rcases mul_eq_zero.1 h2 with h2 | h2
  · have : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast h2
    rw [ZMod.natCast_eq_zero_iff] at this
    exact hp ((Nat.prime_dvd_prime_iff_eq Fact.out Nat.prime_two).1 this)
  · exact ha h2

/-- Square roots of `w²` in a product of two fields: the four sign patterns. -/
lemma sqrt_set_prod (w : ZMod p × ZMod q) :
    {z : ZMod p × ZMod q | z ^ 2 = w ^ 2} = ({w.1, -w.1} : Set (ZMod p)) ×ˢ {w.2, -w.2} := by
  ext ⟨a, b⟩
  simp only [Set.mem_setOf_eq, Set.mem_prod, Set.mem_insert_iff, Set.mem_singleton_iff,
    Prod.ext_iff, Prod.pow_fst, Prod.pow_snd, sq_eq_sq_iff_eq_or_eq_neg]

/-- **Four square roots.**  For distinct odd primes `p ≠ q` and a unit `y` modulo
`N = p q`, the congruence `x² ≡ y² (mod N)` has exactly `4` solutions. -/
theorem card_sqrt_sq_semiprime (hp : p ≠ 2) (hq : q ≠ 2) (hpq : p ≠ q)
    {y : ZMod (p * q)} (hy : IsUnit y) :
    {x : ZMod (p * q) | x ^ 2 = y ^ 2}.ncard = 4 := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes Fact.out Fact.out).2 hpq
  set e := ZMod.chineseRemainder hcop
  have hey : IsUnit (e y) := hy.map e
  have h1 : (e y).1 ≠ 0 := (Prod.isUnit_iff.1 hey).1.ne_zero
  have h2 : (e y).2 ≠ 0 := (Prod.isUnit_iff.1 hey).2.ne_zero
  have himg : e.toEquiv '' {x : ZMod (p * q) | x ^ 2 = y ^ 2}
      = {z : ZMod p × ZMod q | z ^ 2 = (e y) ^ 2} := by
    ext z
    simp only [Set.mem_image, Set.mem_setOf_eq]
    constructor
    · rintro ⟨x, hx, rfl⟩
      change e x ^ 2 = e y ^ 2
      rw [← map_pow, ← map_pow, hx]
    · intro hz
      refine ⟨e.symm z, ?_, by simp⟩
      apply e.injective
      rw [map_pow, map_pow, RingEquiv.apply_symm_apply, hz]
  rw [← Set.ncard_image_of_injective _ e.toEquiv.injective, himg, sqrt_set_prod,
    Set.ncard_prod, Set.ncard_pair (ne_neg_of_ne_zero hp h1),
    Set.ncard_pair (ne_neg_of_ne_zero hq h2)]

/-- **Exactly half the square roots are useful.**  Of the four roots of
`x² ≡ y² (mod p q)`, exactly two are different from `±y`; each of those yields a
proper factor via `gcd_nontrivial_of_sq_congr`.  Heuristically each independent
dependency therefore factors `N` with probability `1/2`. -/
theorem card_nontrivial_sqrt_semiprime (hp : p ≠ 2) (hq : q ≠ 2) (hpq : p ≠ q)
    {y : ZMod (p * q)} (hy : IsUnit y) :
    {x : ZMod (p * q) | x ^ 2 = y ^ 2 ∧ x ≠ y ∧ x ≠ -y}.ncard = 2 := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes Fact.out Fact.out).2 hpq
  set e := ZMod.chineseRemainder hcop
  have hey : IsUnit (e y) := hy.map e
  have h1 : (e y).1 ≠ 0 := (Prod.isUnit_iff.1 hey).1.ne_zero
  have h2 : (e y).2 ≠ 0 := (Prod.isUnit_iff.1 hey).2.ne_zero
  have hn1 := ne_neg_of_ne_zero hp h1
  have hn2 := ne_neg_of_ne_zero hq h2
  have himg : e.toEquiv '' {x : ZMod (p * q) | x ^ 2 = y ^ 2 ∧ x ≠ y ∧ x ≠ -y}
      = {((e y).1, -(e y).2), (-(e y).1, (e y).2)} := by
    have key : ∀ z : ZMod p × ZMod q,
        (e.symm z ^ 2 = y ^ 2 ∧ e.symm z ≠ y ∧ e.symm z ≠ -y) ↔
          (z ^ 2 = (e y) ^ 2 ∧ z ≠ e y ∧ z ≠ -(e y)) := by
      intro z
      have hs : e.symm z ^ 2 = y ^ 2 ↔ z ^ 2 = (e y) ^ 2 := by
        constructor
        · intro h; rw [← RingEquiv.apply_symm_apply e z, ← map_pow, h, map_pow]
        · intro h; apply e.injective; rw [map_pow, map_pow, RingEquiv.apply_symm_apply, h]
      have hy1 : e.symm z ≠ y ↔ z ≠ e y := by
        constructor
        · intro h h'; apply h; rw [h']; simp
        · intro h h'; apply h; rw [← h']; simp
      have hy2 : e.symm z ≠ -y ↔ z ≠ -(e y) := by
        constructor
        · intro h h'; apply h; rw [h', ← map_neg]; simp
        · intro h h'; apply h; rw [← RingEquiv.apply_symm_apply e z, h', map_neg]
      rw [hs, hy1, hy2]
    ext ⟨a, b⟩
    rw [Equiv.image_eq_preimage_symm]
    simp only [Set.mem_preimage, Set.mem_setOf_eq]
    change (e.symm (a, b) ^ 2 = y ^ 2 ∧ e.symm (a, b) ≠ y ∧ e.symm (a, b) ≠ -y) ↔ _
    rw [key]
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff, Prod.ext_iff, Prod.pow_fst,
      Prod.pow_snd, Prod.fst_neg, Prod.snd_neg, ne_eq, sq_eq_sq_iff_eq_or_eq_neg, not_and]
    constructor
    · rintro ⟨⟨ha | ha, hb | hb⟩, hne1, hne2⟩
      · exact absurd hb (hne1 ha)
      · exact Or.inl ⟨ha, hb⟩
      · exact Or.inr ⟨ha, hb⟩
      · exact absurd hb (hne2 ha)
    · rintro (⟨ha, hb⟩ | ⟨ha, hb⟩)
      · refine ⟨⟨Or.inl ha, Or.inr hb⟩, fun _ h => hn2 (h.symm.trans hb), fun h _ => ?_⟩
        exact hn1 (ha.symm.trans h)
      · refine ⟨⟨Or.inr ha, Or.inl hb⟩, fun h _ => hn1 (h.symm.trans ha), fun _ h => ?_⟩
        exact hn2 (hb.symm.trans h)
  rw [← Set.ncard_image_of_injective _ e.toEquiv.injective, himg, Set.ncard_pair]
  intro h
  exact hn1 (Prod.ext_iff.1 h).1

end CRT

/-! ## Lab notes: the toy run's certificate for `N = 103764863`

The abscissae `10248, 10342, 10749, 18185` (found by sieving above `⌈√N⌉` with the
admissible factor base `{2,11,17,19,23,31,37,43,47,59}`) have relation values
`19²·59², 11²·23·31·37, 2·11·17·23·37², 2·11·17·23²·31·37`; their product is
the square `103535840624414²`.  **Every one of the four relation values has a
repeated prime factor**, so a sieve without the Hensel prime-power lines
(`ToyQSSieve.first_power_sieve_misses`) would have collected none of them.  The dependency is non-trivial and yields `9127`.
The 3-relation dependency `10342, 10749, 18185` is trivial (`X ≡ Y mod N`) —
one of the two useless roots of `card_nontrivial_sqrt_semiprime`. -/

section LabNotes

/-- The factorisation found by the toy run. -/
theorem toy_N_factorization : (103764863 : ℕ) = 9127 * 11369 ∧ Nat.Prime 9127 ∧
    Nat.Prime 11369 := by
  refine ⟨by norm_num, by norm_num, by norm_num⟩

/-- The four relation values of the useful dependency, fully factored over the
admissible factor base (each has a square factor). -/
theorem dep_factorizations :
    (10248 : ℤ) ^ 2 - 103764863 = 19 ^ 2 * 59 ^ 2 ∧
    (10342 : ℤ) ^ 2 - 103764863 = 11 ^ 2 * 23 * 31 * 37 ∧
    (10749 : ℤ) ^ 2 - 103764863 = 2 * 11 * 17 * 23 * 37 ^ 2 ∧
    (18185 : ℤ) ^ 2 - 103764863 = 2 * 11 * 17 * 23 ^ 2 * 31 * 37 := by
  refine ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩

/-- The relation abscissae of the useful dependency. -/
def depX : Fin 4 → ℤ := ![10248, 10342, 10749, 18185]

/-- The relation values of the dependency multiply to `103535840624414²`. -/
theorem dep_is_square :
    ∏ i, (depX i ^ 2 - 103764863) = (103535840624414 : ℤ) ^ 2 := by
  simp [depX, Fin.prod_univ_four]

/-- **The toy run's factor, re-derived from the theorems.**  The dependency is
non-trivial and `gcd(X - Y, N) = 9127`. -/
theorem toy_qs_factor :
    1 < Int.gcd ((∏ i, depX i) - 103535840624414) 103764863 ∧
    Int.gcd ((∏ i, depX i) - 103535840624414) 103764863 < 103764863 ∧
    Int.gcd ((∏ i, depX i) - 103535840624414) 103764863 = 9127 := by
  have hX : ∏ i, depX i = 20716911864941040 := by
    simp [depX, Fin.prod_univ_four]
  have h := qs_factor_of_dependency Finset.univ depX dep_is_square
    (by rw [hX]; norm_num) (by rw [hX]; norm_num)
  refine ⟨h.1, by simpa using h.2, by rw [hX]; norm_num⟩

/-- The 3-relation dependency found first is a **trivial** root: `X ≡ Y (mod N)`. -/
theorem toy_trivial_dependency :
    (10342 ^ 2 - 103764863) * (10749 ^ 2 - 103764863) * (18185 ^ 2 - 103764863)
      = (92360250334 : ℤ) ^ 2 ∧
    (103764863 : ℤ) ∣ 10342 * 10749 * 18185 - 92360250334 := by
  refine ⟨by norm_num, by norm_num⟩

end LabNotes

end ToyQSFactor