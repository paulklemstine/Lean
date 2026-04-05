import Mathlib

/-!
# 👽 Area 51 Theorems

## Hidden Structure in the Primes, Secret Patterns, and Number-Theoretic Conspiracies

The primes hide secrets in plain sight. These "Area 51" theorems reveal
classified structure that most mathematicians walk past every day.

## The Prime Conspiracy (Lemke Oliver & Soundararajan, 2016)

Consecutive primes exhibit surprising biases in their last digits.
Among primes ending in 1, the next prime is *least likely* to also end in 1.
This violates the naive expectation of independence.

## The Benford Anomaly

The leading digits of many mathematical sequences follow Benford's law
(logarithmic distribution), but primes do NOT — they are "too uniform."
This is itself a deep structural fact.

## Key Results Formalized

1. Infinitude of primes (Euclid's secret, declassified 300 BCE)
2. The prime gap conspiracy: p_{n+1} - p_n can be arbitrarily large
3. Wilson's theorem: (p-1)! ≡ -1 (mod p) — the prime detector
4. Fermat's little theorem: the modular fingerprint
5. √2 is irrational — the first forbidden truth
-/

open Nat BigOperators

noncomputable section

/-! ## §1: The Infinitude Conspiracy -/

/-
PROBLEM
Euclid's theorem: there are infinitely many primes.
    The oldest "classified" result in mathematics, declassified c. 300 BCE.

PROVIDED SOLUTION
Use Nat.exists_infinite_primes from Mathlib.
-/
theorem euclid_infinitude : ∀ n : ℕ, ∃ p, p > n ∧ Nat.Prime p := by
  exact fun n => Nat.exists_infinite_primes ( n + 1 ) |> Exists.imp fun p => by aesop;

/-! ## §2: The Gap Conspiracy -/

/-
PROBLEM
For any gap size, there exist consecutive integers that are all composite.
    The primes leave arbitrarily large "dead zones" — classified regions with no primes.

PROVIDED SOLUTION
For gap size k, take n = (k+1)!. Then for each i < k, n + i + 2 = (k+1)! + i + 2. Since 2 ≤ i+2 ≤ k+1, we have (i+2) | (k+1)!, so (i+2) | (k+1)! + (i+2), meaning (i+2) divides n+i+2 and n+i+2 > i+2, so it's composite.
-/
theorem prime_gap_arbitrarily_large :
    ∀ k : ℕ, ∃ n : ℕ, ∀ i : ℕ, i < k → ¬ Nat.Prime (n + i + 2) := by
  intro k; use Nat.factorial ( k + 2 ) !; intro i hi; have := Nat.dvd_factorial ( by linarith ) ( show i + 2 ≤ ( k + 2 ) ! from by linarith [ Nat.self_le_factorial ( k + 2 ) ] ) ; simp_all +decide [ Nat.factorial_succ ] ;
  rw [ show ( ( k + 1 + 1 ) * ( ( k + 1 ) * k ! ) ) ! + i + 2 = ( i + 2 ) * ( ( ( k + 1 + 1 ) * ( ( k + 1 ) * k ! ) ) ! / ( i + 2 ) + 1 ) by linarith [ Nat.div_mul_cancel this ] ] ; exact Nat.not_prime_mul ( by linarith ) ( by linarith [ Nat.div_pos ( Nat.le_of_dvd ( by positivity ) this ) ( by linarith : 0 < i + 2 ) ] ) ;

/-! ## §3: The Prime Detector (Wilson's Theorem) -/

/-
PROBLEM
Wilson's theorem forward: if p is prime then (p-1)! ≡ -1 (mod p).

PROVIDED SOLUTION
Use Nat.Prime.factorial_mulInv_atFin or look for Wilson's theorem in Mathlib. The key result might be ZMod.wilsons_lemma or Nat.Prime.factorial_mod.
-/
theorem wilson_forward (p : ℕ) (hp : Nat.Prime p) :
    (p - 1).factorial % p = p - 1 := by
  haveI := Fact.mk hp; simp +decide [ ← ZMod.val_natCast, Nat.cast_sub hp.pos ] ; (
  rcases p with ( _ | _ | p ) <;> norm_num at *);

/-! ## §4: Fermat's Little Theorem — The Modular Fingerprint -/

/-
PROBLEM
Fermat's little theorem: a^p ≡ a (mod p) for prime p.
    Every number carries a "fingerprint" modulo each prime.

PROVIDED SOLUTION
Use ZMod.pow_card from Mathlib, or Nat.Prime.pow_mod. The key Mathlib result is probably ZMod.natCast_zmod_eq_zero_iff_dvd or similar. Actually try using Nat.Prime.eq_one_or_self_of_dvd and induction, or look for a direct Mathlib lemma.
-/
theorem fermat_little (p : ℕ) (hp : Nat.Prime p) (a : ℕ) :
    a ^ p % p = a % p := by
  haveI := Fact.mk hp; norm_num [ ← ZMod.natCast_eq_natCast_iff' ] ;

/-! ## §5: The Digit Sum Conspiracy -/

/-
PROBLEM
A number is divisible by 3 iff its digit sum is (single step).

PROVIDED SOLUTION
n = 10*(n/10) + n%10. So n mod 3 = (10*(n/10) + n%10) mod 3 = (n/10 + n%10) mod 3 since 10 ≡ 1 (mod 3). Use omega.
-/
theorem div3_digit_sum (n : ℕ) : n % 3 = (n % 10 + n / 10) % 3 := by
  omega

/-
PROBLEM
A number is divisible by 9 iff its digit sum is (single step).

PROVIDED SOLUTION
Same as div3: n = 10*(n/10) + n%10, and 10 ≡ 1 (mod 9). Use omega.
-/
theorem div9_digit_sum (n : ℕ) : n % 9 = (n % 10 + n / 10) % 9 := by
  omega

/-! ## §6: The Square Root of 2 is Irrational -/

/-
PROBLEM
√2 is irrational — perhaps the first "forbidden" mathematical truth,
    allegedly causing the death of Hippasus of Metapontum.

PROVIDED SOLUTION
Use irrational_sqrt_two from Mathlib, or Nat.Prime.irrational_sqrt and the fact that 2 is prime.
-/
theorem sqrt2_irrational : Irrational (Real.sqrt 2) := by
  exact irrational_sqrt_two

/-! ## §7: The Pigeonhole Conspiracy -/

/-
PROBLEM
Among any n+1 numbers from {1,...,2n}, some two are coprime.
    You can't hide — structure always emerges.

PROVIDED SOLUTION
Among n+1 numbers from {1,...,2n}, by pigeonhole two must be consecutive (their difference is 1, hence coprime). Map each x to ⌈x/2⌉ (or (x+1)/2). This maps {1,...,2n} to {1,...,n}. With n+1 numbers mapping to n values, two share a value, meaning they map to the same ⌈x/2⌉. But consecutive numbers 2k-1, 2k both map to k. If we get such a pair they are coprime since gcd(2k-1, 2k) = 1. But the two numbers mapping to the same value might not be 2k-1 and 2k specifically. Actually the map x ↦ ⌈x/2⌉ partitions {1,...,2n} into pairs {1,2}, {3,4}, ..., {2n-1,2n}. With n+1 numbers, by pigeonhole two land in the same pair. So we get two consecutive numbers, which are always coprime.
-/
theorem pigeonhole_coprime (n : ℕ) (hn : 0 < n)
    (S : Finset ℕ) (hS : S.card = n + 1)
    (hrange : ∀ x ∈ S, 1 ≤ x ∧ x ≤ 2 * n) :
    ∃ a ∈ S, ∃ b ∈ S, a ≠ b ∧ Nat.Coprime a b := by
  -- By the pigeonhole principle, among any $n+1$ numbers from $\{1, \ldots, 2n\}$, there must be two consecutive numbers.
  obtain ⟨a, ha, b, hb, hab⟩ : ∃ a ∈ S, ∃ b ∈ S, a ≠ b ∧ b = a + 1 := by
    by_contra h;
    -- Let's consider the set $T = \{a + 1 \mid a \in S\}$. Since $S$ contains no consecutive integers, $T$ is disjoint from $S$.
    set T := Finset.image (fun a => a + 1) S with hT
    have h_disjoint : Disjoint S T := by
      exact Finset.disjoint_left.mpr fun x hx hx' => by obtain ⟨ y, hy, hy' ⟩ := Finset.mem_image.mp hx'; specialize h; aesop;
    -- Since $S$ and $T$ are disjoint subsets of $\{1, \ldots, 2n+1\}$, their union has size at most $2n+1$.
    have h_union_size : (S ∪ T).card ≤ 2 * n + 1 := by
      exact le_trans ( Finset.card_le_card ( show S ∪ T ⊆ Finset.Icc 1 ( 2 * n + 1 ) from Finset.union_subset ( fun x hx => Finset.mem_Icc.mpr ⟨ by linarith [ hrange x hx ], by linarith [ hrange x hx ] ⟩ ) ( Finset.image_subset_iff.mpr fun x hx => Finset.mem_Icc.mpr ⟨ by linarith [ hrange x hx ], by linarith [ hrange x hx ] ⟩ ) ) ) ( by simp +arith +decide );
    rw [ Finset.card_union_of_disjoint h_disjoint, Finset.card_image_of_injective _ ( add_left_injective _ ) ] at h_union_size ; linarith;
  exact ⟨ a, ha, b, hb, hab.1, by simp +decide [ hab.2 ] ⟩

/-! ## §8: The Sum of Reciprocals of Primes Diverges -/

/-
PROBLEM
The primes are dense enough that their reciprocal sum diverges.
    We prove a weaker statement: there are at least log-many primes up to n.
    Specifically, there is always a prime ≤ n for n ≥ 2.

PROVIDED SOLUTION
2 is prime and 2 ≤ n.
-/
theorem exists_prime_le (n : ℕ) (hn : 2 ≤ n) : ∃ p, Nat.Prime p ∧ p ≤ n := by
  exact ⟨ 2, Nat.prime_two, hn ⟩

end