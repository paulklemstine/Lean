import Cryptography.SingularModuli.RootCount

/-!
# Singular Moduli Factoring, Step 7: the circularity bottleneck, made a theorem

The useful evaluation points for `H_D` are the roots of `H_D` mod `p` — a set
*defined in terms of the unknown factor* `p`.  The natural way to try to escape
the `√N` search is precomputation: fix once and for all a table `T` of
evaluation points (and a family of discriminants), and hope that some entry of
the table hits a root modulo one of the factors of whatever `N` arrives.

This file proves that this is impossible, in the strongest form:

* `card_catchable_le_sum_log` — a table of `k` evaluation points can ever be
  useful for at most `∑_{t ∈ T} log₂ |H(t)|` primes.  That is a bound depending
  only on the *bit size of the table*, not on `N`;
* `infinite_uncaught_primes` — hence infinitely many primes are invisible to any
  fixed table;
* `precomputed_table_fails` — for every fixed table `T` and every bound `M`
  there are distinct primes `p, q > M` such that **every** entry of the table
  returns `gcd = 1` on `N = pq`: the precomputed attack learns nothing at all;
* `finite_family_table_fails` — the same for a finite family of discriminants
  used simultaneously.

Interpretation: the structured set cannot be enumerated in advance, only
searched, and `SqrtBarrier.lean` prices that search at `√N/(4h)`.  This is the
formal content of "barrier 6" for singular moduli factoring.
-/

namespace SingularModuli

open Polynomial Finset FactoringBarriers

/-! ## A table catches only logarithmically many primes -/

/-- A positive integer `n` has at most `log₂ n` distinct prime factors. -/
theorem card_primeFactors_le_log2 {n : ℕ} (hn : n ≠ 0) :
    n.primeFactors.card ≤ Nat.log 2 n := by
  have hprod : 2 ^ n.primeFactors.card ≤ ∏ r ∈ n.primeFactors, r := by
    calc 2 ^ n.primeFactors.card = ∏ _r ∈ n.primeFactors, 2 := by
          rw [Finset.prod_const]
      _ ≤ ∏ r ∈ n.primeFactors, r := by
          refine Finset.prod_le_prod' (fun r hr => ?_)
          exact (Nat.prime_of_mem_primeFactors hr).two_le
  have hdvd : (∏ r ∈ n.primeFactors, r) ≤ n :=
    Nat.le_of_dvd (Nat.pos_of_ne_zero hn) (Nat.prod_primeFactors_dvd n)
  have h2 : 2 ^ n.primeFactors.card ≤ n := le_trans hprod hdvd
  exact (Nat.le_log_iff_pow_le (by norm_num) hn).mpr h2

/-- The set of primes that a fixed table `T` of evaluation points can ever
detect, for the polynomial `H`: the primes dividing one of the values `H(t)`. -/
noncomputable def catchable (H : Polynomial ℤ) (T : Finset ℤ) : Finset ℕ :=
  T.biUnion (fun t => (H.eval t).natAbs.primeFactors)

theorem mem_catchable {H : Polynomial ℤ} {T : Finset ℤ} {r : ℕ} :
    r ∈ catchable H T ↔ ∃ t ∈ T, r.Prime ∧ (r : ℤ) ∣ H.eval t ∧ H.eval t ≠ 0 := by
  simp only [catchable, Finset.mem_biUnion, Nat.mem_primeFactors, Int.natAbs_ne_zero,
    Int.ofNat_dvd_left]

/-- **The precomputation bound.** A table of evaluation points can be useful for
at most `∑_{t ∈ T} log₂ |H(t)|` primes — a quantity determined by the *bit size
of the table itself*, with no dependence on the modulus `N` under attack. -/
theorem card_catchable_le_sum_log (H : Polynomial ℤ) (T : Finset ℤ) :
    (catchable H T).card ≤ ∑ t ∈ T, Nat.log 2 (H.eval t).natAbs := by
  classical
  calc (catchable H T).card
      ≤ ∑ t ∈ T, ((H.eval t).natAbs.primeFactors).card := Finset.card_biUnion_le
    _ ≤ ∑ t ∈ T, Nat.log 2 (H.eval t).natAbs := by
        refine Finset.sum_le_sum (fun t _ => ?_)
        rcases eq_or_ne (H.eval t).natAbs 0 with h0 | h0
        · simp [h0]
        · exact card_primeFactors_le_log2 h0

/-- Infinitely many primes are invisible to any fixed table. -/
theorem infinite_uncaught_primes (H : Polynomial ℤ) (T : Finset ℤ) :
    {r : ℕ | r.Prime ∧ r ∉ catchable H T}.Infinite := by
  have hdiff : {r : ℕ | r.Prime} \ (catchable H T : Set ℕ) =
      {r : ℕ | r.Prime ∧ r ∉ catchable H T} := by
    ext r
    simp [Set.mem_diff]
  have := Nat.infinite_setOf_prime.diff (catchable H T).finite_toSet
  rwa [hdiff] at this

/-! ## No precomputed table factors anything -/

/-- Auxiliary: there is a prime larger than any given bound and outside any given
finite set of naturals. -/
theorem exists_large_prime_notMem (S : Finset ℕ) (M : ℕ) :
    ∃ r : ℕ, r.Prime ∧ M < r ∧ r ∉ S := by
  obtain ⟨r, hrM, hr⟩ := Nat.exists_infinite_primes (max (M + 1) (S.sup id + 1))
  refine ⟨r, hr, ?_, ?_⟩
  · have : M + 1 ≤ r := le_trans (le_max_left _ _) hrM
    omega
  · intro hmem
    have hle : r ≤ S.sup id := Finset.le_sup (f := id) hmem
    have : S.sup id + 1 ≤ r := le_trans (le_max_right _ _) hrM
    omega

/-- Auxiliary: there is a prime larger than any given bound and outside the
catchable set. -/
theorem exists_large_uncaught_prime (H : Polynomial ℤ) (T : Finset ℤ) (M : ℕ) :
    ∃ r : ℕ, r.Prime ∧ M < r ∧ r ∉ catchable H T :=
  exists_large_prime_notMem (catchable H T) M

/-- **Precomputation is useless.** For every fixed table `T` of evaluation points
at which `H` does not vanish, and every bound `M`, there are distinct primes
`p, q > M` such that every single entry of the table returns `gcd = 1` on the
semiprime `N = pq`.  A table computed before seeing `N` therefore cannot factor
`N`; the only way to use the structured set is to search it, at the `√N` price
of `SqrtBarrier.lean`. -/
theorem precomputed_table_fails (H : Polynomial ℤ) (T : Finset ℤ) (M : ℕ) :
    ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ p ≠ q ∧ M < p ∧ M < q ∧
      ∀ t ∈ T, ¬ NontrivialDivisor (p * q) (evalGcd H t (p * q)) := by
  obtain ⟨p, hp, hpM, hpc⟩ := exists_large_uncaught_prime H T M
  obtain ⟨q, hq, hqM, hqc⟩ := exists_large_uncaught_prime H T p
  have hne : p ≠ q := by omega
  refine ⟨p, q, hp, hq, hne, hpM, by omega, ?_⟩
  intro t ht hcon
  rcases eq_or_ne (H.eval t) 0 with h0 | h0
  · -- a root of `H` itself: the gcd is the whole modulus, still no factor
    have : evalGcd H t (p * q) = p * q := by
      rw [evalGcd, h0]
      simp [Int.gcd, Int.natAbs_mul]
    rw [this] at hcon
    exact absurd hcon.2.2 (lt_irrefl _)
  · have hpd : ¬ (p : ℤ) ∣ H.eval t := fun hdvd =>
      hpc (mem_catchable.mpr ⟨t, ht, hp, hdvd, h0⟩)
    have hqd : ¬ (q : ℤ) ∣ H.eval t := fun hdvd =>
      hqc (mem_catchable.mpr ⟨t, ht, hq, hdvd, h0⟩)
    rw [evalGcd_eq_one_of_no_root hp hq hpd hqd] at hcon
    exact absurd hcon.2.1 (lt_irrefl _)

/-- The same statement in the form actually used by an attacker: on those
semiprimes every table entry returns the useless value `1` (when `H` does not
vanish at the entry). -/
theorem precomputed_table_returns_one (H : Polynomial ℤ) (T : Finset ℤ) (M : ℕ)
    (hT : ∀ t ∈ T, H.eval t ≠ 0) :
    ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ p ≠ q ∧ M < p ∧ M < q ∧
      ∀ t ∈ T, evalGcd H t (p * q) = 1 := by
  obtain ⟨p, hp, hpM, hpc⟩ := exists_large_uncaught_prime H T M
  obtain ⟨q, hq, hqM, hqc⟩ := exists_large_uncaught_prime H T p
  have hne : p ≠ q := by omega
  refine ⟨p, q, hp, hq, hne, hpM, by omega, ?_⟩
  intro t ht
  have h0 := hT t ht
  have hpd : ¬ (p : ℤ) ∣ H.eval t := fun hdvd =>
    hpc (mem_catchable.mpr ⟨t, ht, hp, hdvd, h0⟩)
  have hqd : ¬ (q : ℤ) ∣ H.eval t := fun hdvd =>
    hqc (mem_catchable.mpr ⟨t, ht, hq, hdvd, h0⟩)
  exact evalGcd_eq_one_of_no_root hp hq hpd hqd

/-- **Many discriminants do not rescue precomputation either.** For any finite
family `F` of class polynomials and any finite table `T` of evaluation points,
there are arbitrarily large distinct primes `p, q` such that no pair
`(H_D, j₀) ∈ F × T` produces a factor of `N = pq`. -/
theorem finite_family_table_fails (F : Finset (Polynomial ℤ)) (T : Finset ℤ) (M : ℕ) :
    ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ p ≠ q ∧ M < p ∧ M < q ∧
      ∀ G ∈ F, ∀ t ∈ T, ¬ NontrivialDivisor (p * q) (evalGcd G t (p * q)) := by
  classical
  set S : Finset ℕ := F.biUnion (fun G => catchable G T) with hS
  obtain ⟨p, hp, hpM, hpc⟩ := exists_large_prime_notMem S M
  obtain ⟨q, hq, hqM, hqc⟩ := exists_large_prime_notMem S p
  have hne : p ≠ q := by omega
  refine ⟨p, q, hp, hq, hne, hpM, by omega, ?_⟩
  intro G hG t ht hcon
  have hpc' : p ∉ catchable G T := fun hmem =>
    hpc (by rw [hS]; exact Finset.mem_biUnion.mpr ⟨G, hG, hmem⟩)
  have hqc' : q ∉ catchable G T := fun hmem =>
    hqc (by rw [hS]; exact Finset.mem_biUnion.mpr ⟨G, hG, hmem⟩)
  rcases eq_or_ne (G.eval t) 0 with h0 | h0
  · have hgcd : evalGcd G t (p * q) = p * q := by
      rw [evalGcd, h0]
      simp [Int.gcd, Int.natAbs_mul]
    rw [hgcd] at hcon
    exact absurd hcon.2.2 (lt_irrefl _)
  · have hpd : ¬ (p : ℤ) ∣ G.eval t := fun hdvd =>
      hpc' (mem_catchable.mpr ⟨t, ht, hp, hdvd, h0⟩)
    have hqd : ¬ (q : ℤ) ∣ G.eval t := fun hdvd =>
      hqc' (mem_catchable.mpr ⟨t, ht, hq, hdvd, h0⟩)
    rw [evalGcd_eq_one_of_no_root hp hq hpd hqd] at hcon
    exact absurd hcon.2.1 (lt_irrefl _)

end SingularModuli