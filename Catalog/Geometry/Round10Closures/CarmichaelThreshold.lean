/-
Round-10 Closures — Part IX (cycle 5): the aggregation depth of an arbitrary odd modulus.

Cycle 4 identified the exact aggregation depth of the free-witness channel for semiprimes
and for squarefree moduli: the least exponent with a maximal witness is `lcm_{r ∣ N}(r-1)`.
Cycle 5 removes the squarefree hypothesis on the odd part: for *every* odd `N`,

    R_k(N) = ∏_{p ∣ N} gcd(φ(p^{v_p(N)}), k),

and the least positive exponent with `R_k(N) = φ(N)` is the Carmichael exponent
`λ(N) = lcm_{p ∣ N} φ(p^{v_p(N)})`.

The only input beyond the previous cycles is the cyclicity of `(ZMod (p^e))ˣ` for odd
primes; the `2`-adic case is genuinely different (the local group is not cyclic for
`8 ∣ N`) and is left open.
-/
import Geometry.Round10Closures.SquarefreeTrace

namespace Round10

/-- **Free witnesses decompose over any coprime factorisation.** -/
theorem freeWitness_prod_coprime (k : ℕ) :
    ∀ (P : Finset ℕ) (f : ℕ → ℕ), (∀ a ∈ P, ∀ b ∈ P, a ≠ b → Nat.Coprime (f a) (f b)) →
      freeWitness (∏ i ∈ P, f i) k = ∏ i ∈ P, freeWitness (f i) k := by
  classical
  intro P
  induction P using Finset.induction with
  | empty => intro f _; simpa using freeWitness_one k
  | insert a P ha ih =>
      intro f hcop
      have hcop' : Nat.Coprime (f a) (∏ i ∈ P, f i) :=
        Nat.Coprime.prod_right fun i hi =>
          hcop a (Finset.mem_insert_self a P) i (Finset.mem_insert_of_mem hi)
            (by rintro rfl; exact ha hi)
      rw [Finset.prod_insert ha, Finset.prod_insert ha, freeWitness_mul hcop',
        ih f fun x hx y hy hxy =>
          hcop x (Finset.mem_insert_of_mem hx) y (Finset.mem_insert_of_mem hy) hxy]

/-- The local witness at an odd prime power: the unit group is cyclic, so the count is the
gcd of the exponent with `φ(p^n)`. -/
theorem freeWitness_prime_pow_odd {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) (n k : ℕ) :
    freeWitness (p ^ n) k = (Nat.totient (p ^ n)).gcd k := by
  haveI : NeZero (p ^ n) := ⟨pow_ne_zero n hp.ne_zero⟩
  haveI : IsCyclic (ZMod (p ^ n))ˣ := ZMod.isCyclic_units_of_prime_pow p hp hp2 n
  rw [freeWitness, rootCount_of_isCyclic, Nat.card_eq_fintype_card,
    ZMod.card_units_eq_totient]

/-- Every prime factor of an odd number is odd. -/
theorem ne_two_of_mem_primeFactors_odd {N p : ℕ} (hodd : Odd N) (hp : p ∈ N.primeFactors) :
    p ≠ 2 := by
  rintro rfl
  have h2 : (2 : ℕ) ∣ N := Nat.dvd_of_mem_primeFactors hp
  rw [Nat.odd_iff] at hodd
  omega

/-- **The trace lemma for an arbitrary odd modulus.** -/
theorem freeWitness_odd {N : ℕ} (hodd : Odd N) (hN : N ≠ 0) (k : ℕ) :
    freeWitness N k = ∏ p ∈ N.primeFactors, (Nat.totient (p ^ N.factorization p)).gcd k := by
  classical
  have hdecomp : ∏ p ∈ N.primeFactors, p ^ N.factorization p = N := by
    have := Nat.factorization_prod_pow_eq_self hN
    rwa [Finsupp.prod, Nat.support_factorization] at this
  calc freeWitness N k
      = freeWitness (∏ p ∈ N.primeFactors, p ^ N.factorization p) k := by rw [hdecomp]
    _ = ∏ p ∈ N.primeFactors, freeWitness (p ^ N.factorization p) k := by
        refine freeWitness_prod_coprime k _ _ fun a ha b hb hab => ?_
        exact Nat.Coprime.pow _ _
          ((Nat.coprime_primes (Nat.prime_of_mem_primeFactors ha)
            (Nat.prime_of_mem_primeFactors hb)).mpr hab)
    _ = ∏ p ∈ N.primeFactors, (Nat.totient (p ^ N.factorization p)).gcd k :=
        Finset.prod_congr rfl fun p hp =>
          freeWitness_prime_pow_odd (Nat.prime_of_mem_primeFactors hp)
            (ne_two_of_mem_primeFactors_odd hodd hp) _ k

/-- The local totients multiply to `φ(N)`. -/
theorem prod_totient_prime_pow {N : ℕ} (hN : N ≠ 0) :
    ∏ p ∈ N.primeFactors, Nat.totient (p ^ N.factorization p) = Nat.totient N := by
  rw [Nat.totient_eq_prod_factorization hN, Finsupp.prod, Nat.support_factorization]
  refine Finset.prod_congr rfl fun p hp => ?_
  have hpp : p.Prime := Nat.prime_of_mem_primeFactors hp
  exact Nat.totient_prime_pow hpp
    (hpp.factorization_pos_of_dvd hN (Nat.dvd_of_mem_primeFactors hp))

/-- **Completeness criterion for odd moduli.**  `R_k(N) = φ(N)` exactly when every local
totient `φ(p^{v_p(N)})` divides `k`. -/
theorem freeWitness_odd_eq_totient_iff {N : ℕ} (hodd : Odd N) (hN : N ≠ 0) (k : ℕ) :
    freeWitness N k = Nat.totient N ↔
      ∀ p ∈ N.primeFactors, Nat.totient (p ^ N.factorization p) ∣ k := by
  classical
  rw [freeWitness_odd hodd hN k, ← prod_totient_prime_pow hN]
  constructor
  · intro h p hp
    have hpos : ∀ i ∈ N.primeFactors, 0 < Nat.totient (i ^ N.factorization i) := fun i hi =>
      Nat.totient_pos.mpr (pow_pos (Nat.prime_of_mem_primeFactors hi).pos _)
    have hgcd : (Nat.totient (p ^ N.factorization p)).gcd k
        = Nat.totient (p ^ N.factorization p) :=
      prod_eq_prod_of_le N.primeFactors
        (fun i => (Nat.totient (i ^ N.factorization i)).gcd k)
        (fun i => Nat.totient (i ^ N.factorization i))
        (fun i hi => Nat.gcd_le_left _ (hpos i hi)) hpos h p hp
    rw [← hgcd]
    exact Nat.gcd_dvd_right _ _
  · intro h
    exact Finset.prod_congr rfl fun p hp => Nat.gcd_eq_left (h p hp)

/-- **The aggregation depth of an odd modulus is its Carmichael exponent.**  The least
positive exponent whose free witness is complete is `λ(N) = lcm_{p ∣ N} φ(p^{v_p(N)})`. -/
theorem least_complete_exponent_odd {N : ℕ} (hodd : Odd N) (hN : N ≠ 0) :
    IsLeast {m : ℕ | 0 < m ∧ freeWitness N m = Nat.totient N}
      (N.primeFactors.lcm fun p => Nat.totient (p ^ N.factorization p)) := by
  classical
  have hpos : 0 < N.primeFactors.lcm fun p => Nat.totient (p ^ N.factorization p) := by
    refine Nat.pos_of_ne_zero fun h0 => ?_
    rw [Finset.lcm_eq_zero_iff] at h0
    obtain ⟨p, hp, hp0⟩ := h0
    have : 0 < Nat.totient (p ^ N.factorization p) :=
      Nat.totient_pos.mpr (pow_pos (Nat.prime_of_mem_primeFactors hp).pos _)
    omega
  refine ⟨⟨hpos, (freeWitness_odd_eq_totient_iff hodd hN _).mpr fun p hp => Finset.dvd_lcm hp⟩, ?_⟩
  rintro m ⟨hm, hcomp⟩
  exact Nat.le_of_dvd hm
    (Finset.lcm_dvd fun p hp => (freeWitness_odd_eq_totient_iff hodd hN m).mp hcomp p hp)

end Round10