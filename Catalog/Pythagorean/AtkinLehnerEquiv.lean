import Mathlib

/-!
# The Atkin–Lehner group as an explicit divisor–subset bijection

This file upgrades the *realization theorem* of `Pythagorean/AtkinLehnerGroup.lean`
(`AtkinLehner.alMul_prod`) to a bundled bijection.

For a squarefree integer `N`, the Atkin–Lehner involutions `w_d` are indexed by the
divisors `d ∣ N`, which — by unique factorization — are in canonical bijection with the
subsets of the set of prime factors of `N`:

* forward: a divisor `d ∣ N` maps to its set of prime factors `d.primeFactors`;
* backward: a subset `A ⊆ primeFactors N` maps to the product `∏ p ∈ A, p`.

We prove:

* `AtkinLehner.divisorsEquivPowerset` : this is a genuine `Equiv` between
  `{d // d ∈ N.divisors}` and `{A // A ∈ N.primeFactors.powerset}`.
* `AtkinLehner.card_divisors_eq` : consequently the number of divisors of a squarefree
  `N` is `2 ^ ω(N)` (the order of the Atkin–Lehner group), reproved via the bijection.
* `AtkinLehner.alMul_dvd` : the Atkin–Lehner composition law `⋆` is closed on the
  divisors of a squarefree `N`.
* `AtkinLehner.alMul_realizes_symmDiff` : under the bijection, the arithmetic law
  `d ⋆ e = d·e / gcd(d,e)²` corresponds exactly to symmetric difference of prime
  supports. This is the group-isomorphism content of the Atkin–Lehner group.
-/

namespace AtkinLehner
open Nat Finset

/-- The Atkin–Lehner composition law on natural numbers:
`d ⋆ e = d * e / gcd (d, e) ^ 2`. -/
def alMul (d e : ℕ) : ℕ := d * e / (Nat.gcd d e) ^ 2

/-- **Key gcd computation.** For finsets `A`, `B` of primes, the gcd of the products of
their elements is the product over the intersection. -/
lemma gcd_prod_primes (A B : Finset ℕ)
    (hA : ∀ p ∈ A, p.Prime) (hB : ∀ p ∈ B, p.Prime) :
    Nat.gcd (∏ p ∈ A, p) (∏ p ∈ B, p) = ∏ p ∈ (A ∩ B), p := by
  refine Nat.dvd_antisymm ?_ ?_
  · rw [← Finset.prod_inter_mul_prod_diff A B]
    refine Nat.Coprime.dvd_of_dvd_mul_right ?_ (Nat.gcd_dvd_left _ _)
    refine Nat.Coprime.coprime_dvd_left (Nat.gcd_dvd_right _ _) ?_
    exact Nat.Coprime.prod_left fun p hp => Nat.Coprime.prod_right fun q hq => by
      have := Nat.coprime_primes (hB p hp) (hA q (Finset.mem_sdiff.mp hq |>.1)); aesop
  · exact Nat.dvd_gcd
      (by apply_rules [Finset.prod_dvd_prod_of_subset, Finset.inter_subset_left])
      (by apply_rules [Finset.prod_dvd_prod_of_subset, Finset.inter_subset_right])

/-- **Realization theorem.** The concrete Atkin–Lehner operation `⋆` on products of
distinct primes realizes the symmetric difference of the prime supports. -/
theorem alMul_prod (A B : Finset ℕ)
    (hA : ∀ p ∈ A, p.Prime) (hB : ∀ p ∈ B, p.Prime) :
    alMul (∏ p ∈ A, p) (∏ p ∈ B, p) = ∏ p ∈ (symmDiff A B), p := by
  refine Nat.div_eq_of_eq_mul_left ?_ ?_
  · exact pow_pos (Nat.gcd_pos_of_pos_left _
      (Finset.prod_pos fun p hp => Nat.Prime.pos (hA p hp))) _
  · rw [gcd_prod_primes A B hA hB]
    rw [show symmDiff A B = (A \ B) ∪ (B \ A) from rfl, Finset.prod_union]
    · rw [← Finset.prod_inter_mul_prod_diff A B, ← Finset.prod_inter_mul_prod_diff B A]
      rw [Finset.inter_comm]; ring
    · exact disjoint_sdiff_sdiff

/-- The canonical bijection between the divisors of a squarefree `N` and the subsets of
its set of prime factors: a divisor `d` maps to `d.primeFactors`, and a subset `A` maps
to `∏ p ∈ A, p`. -/
def divisorsEquivPowerset {N : ℕ} (hN : Squarefree N) :
    {d // d ∈ N.divisors} ≃ {A // A ∈ N.primeFactors.powerset} where
  toFun d := ⟨d.1.primeFactors, by
    rw [Finset.mem_powerset]
    exact Nat.primeFactors_mono (Nat.dvd_of_mem_divisors d.2) hN.ne_zero⟩
  invFun A := ⟨∏ p ∈ A.1, p, by
    rw [Nat.mem_divisors]
    refine ⟨?_, hN.ne_zero⟩
    have hsub : A.1 ⊆ N.primeFactors := Finset.mem_powerset.mp A.2
    calc ∏ p ∈ A.1, p ∣ ∏ p ∈ N.primeFactors, p :=
          Finset.prod_dvd_prod_of_subset _ _ _ hsub
      _ = N := Nat.prod_primeFactors_of_squarefree hN⟩
  left_inv d := by
    apply Subtype.ext
    have hd : Squarefree d.1 := hN.squarefree_of_dvd (Nat.dvd_of_mem_divisors d.2)
    simp only
    exact Nat.prod_primeFactors_of_squarefree hd
  right_inv A := by
    apply Subtype.ext
    have hsub : A.1 ⊆ N.primeFactors := Finset.mem_powerset.mp A.2
    simp only
    exact Nat.primeFactors_prod fun p hp => Nat.prime_of_mem_primeFactors (hsub hp)

/-- The number of divisors of a squarefree `N` — equivalently the order of the
Atkin–Lehner group of `N` — is `2 ^ ω(N)`, reproved via the divisor–subset bijection. -/
theorem card_divisors_eq {N : ℕ} (hN : Squarefree N) :
    N.divisors.card = 2 ^ N.primeFactors.card := by
  have hcard : Fintype.card {d // d ∈ N.divisors}
      = Fintype.card {A // A ∈ N.primeFactors.powerset} :=
    Fintype.card_congr (divisorsEquivPowerset hN)
  simp only [Fintype.card_coe, Finset.card_powerset] at hcard
  exact hcard

/-- The Atkin–Lehner composition law `⋆` is closed on the divisors of a squarefree
`N`. -/
theorem alMul_dvd {N d e : ℕ} (hN : Squarefree N) (hd : d ∣ N) (he : e ∣ N) :
    alMul d e ∣ N := by
  have hd0 : d ≠ 0 := fun h => by simp [h] at hd; exact hN.ne_zero (by simpa using hd)
  have he0 : e ≠ 0 := fun h => by simp [h] at he; exact hN.ne_zero (by simpa using he)
  have hdsf : Squarefree d := hN.squarefree_of_dvd hd
  have hesf : Squarefree e := hN.squarefree_of_dvd he
  -- Write `d` and `e` as products over their prime supports.
  have hdp : ∏ p ∈ d.primeFactors, p = d := Nat.prod_primeFactors_of_squarefree hdsf
  have hep : ∏ p ∈ e.primeFactors, p = e := Nat.prod_primeFactors_of_squarefree hesf
  have hAprime : ∀ p ∈ d.primeFactors, p.Prime := fun p hp => Nat.prime_of_mem_primeFactors hp
  have hBprime : ∀ p ∈ e.primeFactors, p.Prime := fun p hp => Nat.prime_of_mem_primeFactors hp
  have hrewrite : alMul d e = ∏ p ∈ symmDiff d.primeFactors e.primeFactors, p := by
    conv_lhs => rw [← hdp, ← hep]
    exact alMul_prod _ _ hAprime hBprime
  rw [hrewrite]
  have hsub : symmDiff d.primeFactors e.primeFactors ⊆ N.primeFactors := by
    intro p hp
    rcases (Finset.mem_symmDiff.mp hp) with ⟨hpd, _⟩ | ⟨hpe, _⟩
    · exact Nat.primeFactors_mono hd hN.ne_zero hpd
    · exact Nat.primeFactors_mono he hN.ne_zero hpe
  calc ∏ p ∈ symmDiff d.primeFactors e.primeFactors, p
        ∣ ∏ p ∈ N.primeFactors, p := Finset.prod_dvd_prod_of_subset _ _ _ hsub
    _ = N := Nat.prod_primeFactors_of_squarefree hN

/-- **The group-isomorphism content.** Under the divisor–subset bijection, the
Atkin–Lehner composition law `d ⋆ e` corresponds to the symmetric difference of the
prime supports of `d` and `e`. -/
theorem alMul_realizes_symmDiff {N d e : ℕ} (hN : Squarefree N)
    (hd : d ∣ N) (he : e ∣ N) :
    (alMul d e).primeFactors = symmDiff d.primeFactors e.primeFactors := by
  have hdsf : Squarefree d := hN.squarefree_of_dvd hd
  have hesf : Squarefree e := hN.squarefree_of_dvd he
  have hdp : ∏ p ∈ d.primeFactors, p = d := Nat.prod_primeFactors_of_squarefree hdsf
  have hep : ∏ p ∈ e.primeFactors, p = e := Nat.prod_primeFactors_of_squarefree hesf
  have hAprime : ∀ p ∈ d.primeFactors, p.Prime := fun p hp => Nat.prime_of_mem_primeFactors hp
  have hBprime : ∀ p ∈ e.primeFactors, p.Prime := fun p hp => Nat.prime_of_mem_primeFactors hp
  have hrewrite : alMul d e = ∏ p ∈ symmDiff d.primeFactors e.primeFactors, p := by
    conv_lhs => rw [← hdp, ← hep]
    exact alMul_prod _ _ hAprime hBprime
  rw [hrewrite]
  apply Nat.primeFactors_prod
  intro p hp
  rcases (Finset.mem_symmDiff.mp hp) with ⟨hpd, _⟩ | ⟨hpe, _⟩
  · exact hAprime p hpd
  · exact hBprime p hpe

end AtkinLehner