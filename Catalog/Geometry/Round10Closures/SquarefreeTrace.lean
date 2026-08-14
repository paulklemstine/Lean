/-
Round-10 Closures — Part VIII (cycle 3): the trace lemma beyond semiprimes.

Cycle 3 pushes the classification off the semiprime case: the free-witness family is
multiplicative, so for every squarefree modulus `N = ∏_{r ∈ P} r` (a finite set of distinct
primes) the witness is the product of the local gcd-residue coordinates,

    R_k(N) = ∏_{r ∈ P} gcd(k, r - 1).

Two consequences are recorded:

* the population of square roots of unity is `2^ω(N)` for odd squarefree `N`, so the
  residue coordinate *counts the prime factors* — the classified coordinate already knows
  `ω(N)`, while it still cannot name a single factor without aggregation;
* the witness of the exponent `k` is still bounded by `k^{ω(N)}`, so the bounded-exponent
  barrier of `JointClosure.lean` degrades only polynomially in the number of factors.
-/
import Geometry.Round10Closures.AggregationCost

namespace Round10

/-- The trivial modulus carries the trivial witness. -/
theorem freeWitness_one (k : ℕ) : freeWitness 1 k = 1 := by
  rw [freeWitness, rootCount, Nat.card_eq_one_iff_unique]
  exact ⟨inferInstance, ⟨⟨1, one_pow k⟩⟩⟩

/-- **Multiplicativity of the free-witness family.**  Coprime moduli contribute
independently: the CRT-separability that the trace lemma formalises. -/
theorem freeWitness_mul {m n : ℕ} (h : Nat.Coprime m n) (k : ℕ) :
    freeWitness (m * n) k = freeWitness m k * freeWitness n k := by
  rw [freeWitness, rootCount_congr (unitsMulEquivProd h) k, rootCount_prod]
  rfl

/-- The local factor at a prime. -/
theorem freeWitness_prime (r k : ℕ) [Fact r.Prime] :
    freeWitness r k = (r - 1).gcd k := by
  rw [freeWitness, rootCount_of_isCyclic, card_units_zmod_prime]

/-- **Squarefree trace lemma.**  For a finite set `P` of distinct primes and
`N = ∏_{r ∈ P} r`, the number of `k`-th roots of unity modulo `N` is
`∏_{r ∈ P} gcd(r - 1, k)`. -/
theorem freeWitness_prod (k : ℕ) :
    ∀ (P : Finset ℕ), (∀ r ∈ P, r.Prime) →
      freeWitness (∏ r ∈ P, r) k = ∏ r ∈ P, (r - 1).gcd k := by
  classical
  intro P
  induction P using Finset.induction with
  | empty => intro _; simpa using freeWitness_one k
  | insert r P hr ih =>
      intro hP
      haveI : Fact (r.Prime) := ⟨hP r (Finset.mem_insert_self r P)⟩
      have hPprime : ∀ s ∈ P, s.Prime := fun s hs => hP s (Finset.mem_insert_of_mem hs)
      have hcop : Nat.Coprime r (∏ s ∈ P, s) :=
        Nat.Coprime.prod_right fun s hs =>
          (Nat.coprime_primes (Fact.out) (hPprime s hs)).mpr (by rintro rfl; exact hr hs)
      rw [Finset.prod_insert hr, Finset.prod_insert hr, freeWitness_mul hcop,
        freeWitness_prime r k, ih hPprime]

/-- **The residue coordinate counts the prime factors.**  For a squarefree odd modulus with
`n` prime factors there are exactly `2^n` square roots of unity. -/
theorem freeWitness_two_prod (P : Finset ℕ) (hP : ∀ r ∈ P, r.Prime) (hodd : ∀ r ∈ P, r ≠ 2) :
    freeWitness (∏ r ∈ P, r) 2 = 2 ^ P.card := by
  rw [freeWitness_prod 2 P hP]
  rw [Finset.prod_congr rfl (g := fun _ => 2) ?_, Finset.prod_const]
  intro r hr
  obtain ⟨m, hm⟩ := (hP r hr).odd_of_ne_two (hodd r hr)
  subst hm
  simp

/-! ### The Carmichael threshold for squarefree moduli (cycle 4)

The completeness analysis of `AggregationCost.lean` generalises verbatim: a free witness of
a squarefree modulus is maximal exactly at the multiples of `lcm_{r ∈ P} (r-1)`, the
Carmichael exponent of `N`.  So the aggregation depth of the classical channel is the
Carmichael function, for every squarefree modulus and not just for semiprimes. -/

/-- Termwise cancellation for products of naturals bounded by positive factors. -/
theorem prod_eq_prod_of_le : ∀ (P : Finset ℕ) (f g : ℕ → ℕ), (∀ i ∈ P, f i ≤ g i) →
    (∀ i ∈ P, 0 < g i) → ∏ i ∈ P, f i = ∏ i ∈ P, g i → ∀ i ∈ P, f i = g i := by
  classical
  intro P
  induction P using Finset.induction with
  | empty => intro _ _ _ _ _ i hi; exact absurd hi (Finset.notMem_empty i)
  | insert a P ha ih =>
      intro f g hle hpos hprod
      rw [Finset.prod_insert ha, Finset.prod_insert ha] at hprod
      have hlep : ∏ i ∈ P, f i ≤ ∏ i ∈ P, g i :=
        Finset.prod_le_prod' fun i hi => hle i (Finset.mem_insert_of_mem hi)
      have hposp : 0 < ∏ i ∈ P, g i :=
        Finset.prod_pos fun i hi => hpos i (Finset.mem_insert_of_mem hi)
      obtain ⟨h1, h2⟩ := eq_of_mul_eq_mul_le (hle a (Finset.mem_insert_self a P)) hlep
        (hpos a (Finset.mem_insert_self a P)) hposp hprod
      intro i hi
      rcases Finset.mem_insert.mp hi with rfl | hiP
      · exact h1
      · exact ih f g (fun j hj => hle j (Finset.mem_insert_of_mem hj))
          (fun j hj => hpos j (Finset.mem_insert_of_mem hj)) h2 i hiP

/-- **Squarefree completeness criterion.**  A free witness of `N = ∏_{r ∈ P} r` is maximal
exactly at the exponents divisible by every `r - 1`. -/
theorem freeWitness_prod_eq_totient_iff (k : ℕ) (P : Finset ℕ) (hP : ∀ r ∈ P, r.Prime) :
    freeWitness (∏ r ∈ P, r) k = ∏ r ∈ P, (r - 1) ↔ ∀ r ∈ P, (r - 1) ∣ k := by
  rw [freeWitness_prod k P hP]
  constructor
  · intro h r hr
    have hgcd : (r - 1).gcd k = r - 1 :=
      prod_eq_prod_of_le P (fun r => (r - 1).gcd k) (fun r => r - 1)
        (fun i hi => by
          have := (hP i hi).two_le
          exact Nat.gcd_le_left _ (by omega))
        (fun i hi => by
          have := (hP i hi).two_le
          show 0 < i - 1
          omega) h r hr
    rw [← hgcd]
    exact Nat.gcd_dvd_right _ _
  · intro h
    exact Finset.prod_congr rfl fun r hr => Nat.gcd_eq_left (h r hr)

/-- **The Carmichael exponent is the aggregation depth.**  For a squarefree modulus the
least positive exponent with a maximal free witness is `lcm_{r ∈ P} (r - 1)`. -/
theorem least_complete_exponent_prod (P : Finset ℕ) (hP : ∀ r ∈ P, r.Prime) :
    IsLeast {m : ℕ | 0 < m ∧ freeWitness (∏ r ∈ P, r) m = ∏ r ∈ P, (r - 1)}
      (P.lcm (fun r => r - 1)) := by
  classical
  have hpos : 0 < P.lcm (fun r => r - 1) := by
    refine Nat.pos_of_ne_zero fun h0 => ?_
    rw [Finset.lcm_eq_zero_iff] at h0
    obtain ⟨r, hr, hr0⟩ := h0
    have := (hP r hr).two_le
    omega
  refine ⟨⟨hpos, (freeWitness_prod_eq_totient_iff _ P hP).mpr fun r hr => Finset.dvd_lcm hr⟩, ?_⟩
  rintro m ⟨hm, hcomp⟩
  exact Nat.le_of_dvd hm
    (Finset.lcm_dvd fun r hr => (freeWitness_prod_eq_totient_iff m P hP).mp hcomp r hr)

/-- Bounded-exponent bookkeeping in the squarefree case: the witness of a positive exponent
`k` is at most `k^{ω(N)}`, so the information leaked by a single exponent still grows only
logarithmically in `k` and linearly in the number of prime factors. -/
theorem freeWitness_prod_le (k : ℕ) (P : Finset ℕ) (hP : ∀ r ∈ P, r.Prime) (hk : 0 < k) :
    freeWitness (∏ r ∈ P, r) k ≤ k ^ P.card := by
  rw [freeWitness_prod k P hP]
  calc ∏ r ∈ P, (r - 1).gcd k ≤ ∏ _r ∈ P, k :=
        Finset.prod_le_prod' fun r _ => Nat.le_of_dvd hk (Nat.gcd_dvd_right _ _)
    _ = k ^ P.card := by rw [Finset.prod_const]

end Round10