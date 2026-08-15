import Novelty.PowerSumGCDCarmichael

/-!
# The power-sum gcd for arbitrary squarefree moduli, and the first-hit exponent

The semiprime analysis of `Novelty.PowerSumGCDFactoring` and
`Novelty.PowerSumGCDCarmichael` is a shadow of a statement about *every* squarefree
modulus: for `k > 0`,

  `gcd(F(N,k), N) = ∏ { r prime, r ∣ N, (r-1) ∤ k }`.

So the power-sum gcd is a *spectral read-out* of the multiplicative orders in `N`:
it deletes exactly those primes `r` for which `k` is a multiple of `r - 1`.  Its trivial
locus is the multiples of the Carmichael exponent `λ(N) = lcm_{r ∣ N} (r-1)`, and the
power sum itself is periodic mod `N` with that period (Korselt's criterion in disguise).

## Main results

* `gcd_eq_prod_primeFactors_filter` : for squarefree `N`, `gcd(a,N)` is the product of the
  primes of `N` that divide `a`;
* `gcd_powerSum_squarefree` : the product formula displayed above;
* `carmichaelSF` and `gcd_powerSum_eq_one_iff_squarefree` : the trivial locus of the gcd
  is exactly the set of multiples of the Carmichael exponent;
* `modEq_of_forall_prime_modEq` and `powerSum_modEq_add_period_squarefree` : Korselt-type
  periodicity of the power sum for arbitrary squarefree moduli;
* `gcd_powerSum_eq_self_iff`, `gcd_powerSum_eq_self_of_lt_min`,
  `gcd_powerSum_lt_self_at_min` : the *first hit* of the semiprime search happens exactly
  at `k = min(p-1, q-1)`, which is the source of the `O(N^{3/2})` cost of the method.
-/

open Finset

namespace PowerSumGCD

/-- For a squarefree modulus, the gcd with `a` is the product of the prime factors that
divide `a`. -/
theorem gcd_eq_prod_primeFactors_filter (a N : ℕ) (hN : Squarefree N) :
    Nat.gcd a N = ∏ r ∈ N.primeFactors.filter (fun r => r ∣ a), r := by
  classical
  have hprod : ∏ r ∈ N.primeFactors, r = N := Nat.prod_primeFactors_of_squarefree hN
  have key : ∀ s : Finset ℕ, s ⊆ N.primeFactors →
      Nat.gcd a (∏ r ∈ s, r) = ∏ r ∈ s, Nat.gcd a r := by
    intro s
    induction s using Finset.induction with
    | empty => simp
    | insert r s hrs ih =>
      intro hsub
      have hr : r.Prime := Nat.prime_of_mem_primeFactors (hsub (Finset.mem_insert_self r s))
      have hsub' : s ⊆ N.primeFactors := fun x hx => hsub (Finset.mem_insert_of_mem hx)
      have hcop : Nat.Coprime r (∏ x ∈ s, x) := by
        refine Nat.Coprime.prod_right fun x hx => ?_
        have hx' : x.Prime := Nat.prime_of_mem_primeFactors (hsub' hx)
        exact (Nat.coprime_primes hr hx').mpr (by rintro rfl; exact hrs hx)
      rw [Finset.prod_insert hrs, hcop.gcd_mul a, Finset.prod_insert hrs, ih hsub']
  have hkey := key N.primeFactors (Finset.Subset.refl _)
  rw [hprod] at hkey
  rw [hkey, Finset.prod_filter]
  exact Finset.prod_congr rfl fun r hr => gcd_prime_eq (Nat.prime_of_mem_primeFactors hr)

/-- **The general power-sum gcd formula.**  For squarefree `N` and `k > 0`,
`gcd(F(N,k), N)` is the product of those primes `r ∣ N` with `(r-1) ∤ k`. -/
theorem gcd_powerSum_squarefree {N k : ℕ} (hN : Squarefree N) (hk : 0 < k) :
    Nat.gcd (powerSum N k) N
      = ∏ r ∈ N.primeFactors.filter (fun r => ¬ (r - 1) ∣ k), r := by
  classical
  rw [gcd_eq_prod_primeFactors_filter _ _ hN]
  refine Finset.prod_congr (Finset.filter_congr fun r hr => ?_) fun _ _ => rfl
  have hrp : r.Prime := Nat.prime_of_mem_primeFactors hr
  have hrN : r ∣ N := Nat.dvd_of_mem_primeFactors hr
  obtain ⟨m, hm, hrm⟩ := exists_cofactor_of_squarefree hN hrp hrN
  subst hm
  simpa using prime_dvd_powerSum_iff hrp hrm hk

/-- The Carmichael exponent of a squarefree modulus: `lcm` of `r - 1` over the primes
`r ∣ N`. -/
def carmichaelSF (N : ℕ) : ℕ := N.primeFactors.lcm (fun r => r - 1)

/-- The Carmichael exponent of a semiprime agrees with the general definition. -/
lemma carmichaelSF_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) :
    carmichaelSF (p * q) = carmichael p q := by
  classical
  have hprimes : (p * q).primeFactors = {p, q} := by
    rw [Nat.primeFactors_mul hp.ne_zero hq.ne_zero, hp.primeFactors, hq.primeFactors]
    rfl
  rw [carmichaelSF, hprimes, carmichael]
  rw [Finset.lcm_insert, Finset.lcm_singleton]
  simp [lcm_eq_nat_lcm]

/-- **Carmichael criterion, general form.**  For squarefree `N` and `k > 0`, the gcd is
trivial exactly on the multiples of `λ(N)`. -/
theorem gcd_powerSum_eq_one_iff_squarefree {N k : ℕ} (hN : Squarefree N) (hk : 0 < k) :
    Nat.gcd (powerSum N k) N = 1 ↔ carmichaelSF N ∣ k := by
  rw [show Nat.gcd (powerSum N k) N = 1 ↔ Nat.Coprime (powerSum N k) N from Iff.rfl,
    powerSum_coprime_iff_squarefree hN hk, carmichaelSF, Finset.lcm_dvd_iff]
  constructor
  · intro h r hr
    exact h r (Nat.prime_of_mem_primeFactors hr) (Nat.dvd_of_mem_primeFactors hr)
  · intro h r hr hrN
    exact h r (Nat.mem_primeFactors.mpr ⟨hr, hrN, hN.ne_zero⟩)

/-- For a squarefree modulus, a congruence holds mod `N` as soon as it holds modulo every
prime factor. -/
theorem modEq_of_forall_prime_modEq {N x y : ℕ} (hN : Squarefree N)
    (h : ∀ r : ℕ, r.Prime → r ∣ N → x ≡ y [MOD r]) : x ≡ y [MOD N] := by
  classical
  have hprod : ∏ r ∈ N.primeFactors, r = N := Nat.prod_primeFactors_of_squarefree hN
  have key : ∀ s : Finset ℕ, s ⊆ N.primeFactors → x ≡ y [MOD ∏ r ∈ s, r] := by
    intro s
    induction s using Finset.induction with
    | empty => simp [Nat.ModEq, Nat.mod_one]
    | insert r s hrs ih =>
      intro hsub
      have hr : r.Prime := Nat.prime_of_mem_primeFactors (hsub (Finset.mem_insert_self r s))
      have hsub' : s ⊆ N.primeFactors := fun z hz => hsub (Finset.mem_insert_of_mem hz)
      have hcop : Nat.Coprime r (∏ z ∈ s, z) := by
        refine Nat.Coprime.prod_right fun z hz => ?_
        have hz' : z.Prime := Nat.prime_of_mem_primeFactors (hsub' hz)
        exact (Nat.coprime_primes hr hz').mpr (by rintro rfl; exact hrs hz)
      rw [Finset.prod_insert hrs]
      exact (Nat.modEq_and_modEq_iff_modEq_mul hcop).mp
        ⟨h r hr (Nat.dvd_of_mem_primeFactors (hsub (Finset.mem_insert_self r s))), ih hsub'⟩
  have := key N.primeFactors (Finset.Subset.refl _)
  rwa [hprod] at this

/-- **Korselt periodicity, general form.**  If `(r-1) ∣ L` for every prime `r ∣ N` and `N`
is squarefree, then `F(N, k+L) ≡ F(N, k) (mod N)` for every `k > 0`. -/
theorem powerSum_modEq_add_period_squarefree {N L k : ℕ} (hN : Squarefree N) (hk : 0 < k)
    (hL : ∀ r : ℕ, r.Prime → r ∣ N → (r - 1) ∣ L) :
    powerSum N (k + L) ≡ powerSum N k [MOD N] := by
  refine Nat.ModEq.sum fun a _ => ?_
  exact modEq_of_forall_prime_modEq hN fun r hr hrN =>
    pow_add_modEq_prime hr hk (hL r hr hrN)

/-- The gcd is the whole modulus exactly when neither order condition holds. -/
theorem gcd_powerSum_eq_self_iff {p q k : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hk : 0 < k) :
    Nat.gcd (powerSum (p * q) k) (p * q) = p * q ↔ (¬ (p - 1) ∣ k ∧ ¬ (q - 1) ∣ k) := by
  rw [gcd_powerSum_semiprime hp hq hpq hk]
  constructor
  · intro h
    by_cases h1 : (p - 1) ∣ k <;> by_cases h2 : (q - 1) ∣ k
    · rw [if_pos h1, if_pos h2, one_mul] at h
      exact absurd h.symm (by
        have := hp.one_lt; have := hq.one_lt; nlinarith)
    · rw [if_pos h1, if_neg h2, one_mul] at h
      exact absurd h (by have := hp.one_lt; have := hq.pos; nlinarith)
    · rw [if_neg h1, if_pos h2, mul_one] at h
      exact absurd h (by have := hq.one_lt; have := hp.pos; nlinarith)
    · exact ⟨h1, h2⟩
  · rintro ⟨h1, h2⟩
    rw [if_neg h1, if_neg h2]

/-- **Before the first hit.**  For `0 < k < min(p-1, q-1)` the gcd carries no information:
it is the whole modulus. -/
theorem gcd_powerSum_eq_self_of_lt_min {p q k : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hk : 0 < k) (hlt : k < min (p - 1) (q - 1)) :
    Nat.gcd (powerSum (p * q) k) (p * q) = p * q := by
  refine (gcd_powerSum_eq_self_iff hp hq hpq hk).mpr ⟨fun hd => ?_, fun hd => ?_⟩
  · have := Nat.le_of_dvd hk hd
    have := min_le_left (p - 1) (q - 1)
    omega
  · have := Nat.le_of_dvd hk hd
    have := min_le_right (p - 1) (q - 1)
    omega

/-- **The first hit.**  At `k = min(p-1, q-1)` the gcd drops below the modulus, so the
smallest informative exponent is exactly `min(p-1, q-1) ≈ √N` for balanced semiprimes. -/
theorem gcd_powerSum_lt_self_at_min {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    Nat.gcd (powerSum (p * q) (min (p - 1) (q - 1))) (p * q) ≠ p * q := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  have hk : 0 < min (p - 1) (q - 1) := by omega
  intro h
  obtain ⟨h1, h2⟩ := (gcd_powerSum_eq_self_iff hp hq hpq hk).mp h
  rcases Nat.le_total (p - 1) (q - 1) with hle | hle
  · exact h1 (by rw [min_eq_left hle])
  · exact h2 (by rw [min_eq_right hle])

end PowerSumGCD