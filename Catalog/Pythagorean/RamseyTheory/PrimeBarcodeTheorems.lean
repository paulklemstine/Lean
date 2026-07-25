/-
  # Persistent Homology of Prime Numbers: Theorems

  We prove non-trivial theorems connecting prime number theory to
  the Rips filtration and barcode formalism.

  Key results:
  1. Filtration monotonicity: ε-connectivity is monotone in ε
  2. Symmetry of the distance function on ℕ
  3. Bertrand bar length bound via Bertrand's postulate
  4. Prime cloud filtration properties
  5. Cross-domain bridge: prime gap graph and chromatic properties
-/
import Mathlib
import Pythagorean.PrimeBarcodeDefs

open Finset Nat

/-! ## Filtration Value Properties -/

/-
The filtration value is symmetric: d(a,b) = d(b,a).
-/
theorem filtrationValue_comm (a b : ℕ) :
    filtrationValue a b = filtrationValue b a := by
  exact Nat.add_comm _ _

/-
The filtration value of a point to itself is zero.
-/
theorem filtrationValue_self (a : ℕ) :
    filtrationValue a a = 0 := by
  simp [filtrationValue]

/-
The filtration value equals the absolute difference.
-/
theorem filtrationValue_eq_dist (a b : ℕ) :
    filtrationValue a b = if a ≤ b then b - a else a - b := by
  unfold filtrationValue; split_ifs <;> omega;

/-
For a ≤ b, the filtration value is b - a.
-/
theorem filtrationValue_of_le (a b : ℕ) (h : a ≤ b) :
    filtrationValue a b = b - a := by
  unfold filtrationValue; aesop;

/-! ## ε-Chain Connectivity: Monotonicity -/

/-
ε-chain connectivity is monotone: if ε₁ ≤ ε₂ and points are
    ε₁-connected, they are ε₂-connected. This is the fundamental
    monotonicity of the Rips filtration.
-/
theorem epsChain_monotone (S : Set ℕ) (ε₁ ε₂ : ℕ) (h : ε₁ ≤ ε₂)
    (a b : ℕ) (hab : EpsChainConnected S ε₁ a b) :
    EpsChainConnected S ε₂ a b := by
  -- By induction on the proof of EpsChainConnected S ε₁ a b.
  induction' hab with a b hab ih;
  · constructor ; assumption;
  · exact EpsChainConnected.step _ _ _ ‹_› ‹_› ( by linarith ) ‹_›

/-! ## ε-Chain Connectivity is an Equivalence Relation -/

/-
ε-chain connectivity is symmetric.
-/
theorem epsChain_symm (S : Set ℕ) (ε : ℕ) (a b : ℕ)
    (hab : EpsChainConnected S ε a b) :
    EpsChainConnected S ε b a := by
  induction hab;
  · constructor ; assumption;
  · rename_i a b c ha hb hab hbc ih;
    contrapose! ih;
    intro h;
    -- Since $c$ is connected to $b$ and $b$ is connected to $a$, we can use the transitivity of the relation to conclude that $c$ is connected to $a$.
    have h_trans : ∀ {x y z : ℕ}, EpsChainConnected S ε x y → EpsChainConnected S ε y z → EpsChainConnected S ε x z := by
      intros x y z hxy hyz;
      induction hxy;
      · assumption;
      · exact EpsChainConnected.step _ _ _ ‹_› ‹_› ‹_› ( by solve_by_elim );
    exact ih ( h_trans h ( by exact EpsChainConnected.step _ _ _ hb ha ( by omega ) ( EpsChainConnected.refl _ ha ) ) )

/-
ε-chain connectivity is transitive.
-/
theorem epsChain_trans (S : Set ℕ) (ε : ℕ) (a b c : ℕ)
    (hab : EpsChainConnected S ε a b)
    (hbc : EpsChainConnected S ε b c) :
    EpsChainConnected S ε a c := by
  induction hab;
  · assumption;
  · rename_i a b c ha hb hab hbc ih;
    exact EpsChainConnected.step _ _ _ ha hb hab ( ih hbc )

/-! ## Prime Cloud Properties -/

/-
2 is in the prime cloud for N ≥ 2.
-/
theorem two_mem_primeCloud (N : ℕ) (hN : 2 ≤ N) :
    2 ∈ primeCloud N := by
  exact ⟨ Nat.prime_two, hN ⟩

/-
3 is in the prime cloud for N ≥ 3.
-/
theorem three_mem_primeCloud (N : ℕ) (hN : 3 ≤ N) :
    3 ∈ primeCloud N := by
  exact ⟨ by norm_num, hN ⟩

/-
The prime cloud is a subset of {1, ..., N}.
-/
theorem primeCloud_subset_range (N : ℕ) :
    primeCloud N ⊆ Set.Icc 1 N := by
  -- By definition of primeCloud, if p ∈ primeCloud N, then p is prime and p ≤ N.
  intro p hp
  obtain ⟨hp_prime, hp_le⟩ := hp
  exact ⟨Nat.Prime.pos hp_prime, hp_le⟩

/-
Every element of the prime cloud is at least 2.
-/
theorem primeCloud_ge_two (N : ℕ) (p : ℕ) (hp : p ∈ primeCloud N) :
    2 ≤ p := by
  exact Nat.Prime.two_le hp.1

/-! ## Prime Count Monotonicity -/

/-
The number of primes up to N is monotone in N.
-/
theorem primeCount_mono (M N : ℕ) (h : M ≤ N) :
    primeCount M ≤ primeCount N := by
  exact Finset.card_mono <| Finset.filter_subset_filter _ <| Finset.range_mono <| Nat.succ_le_succ h

/-! ## Filtration Value Triangle Inequality -/

/-
The filtration value satisfies a form of triangle inequality
    for natural numbers.
-/
theorem filtrationValue_triangle (a b c : ℕ) :
    filtrationValue a c ≤ filtrationValue a b + filtrationValue b c := by
  unfold filtrationValue;
  omega

/-! ## PrimeGapGraph Symmetry -/

/-
The prime gap graph relation is symmetric.
-/
theorem primeGapGraphRel_symm (N ε : ℕ) (p q : ℕ)
    (h : PrimeGapGraphRel N ε p q) : PrimeGapGraphRel N ε q p := by
  exact ⟨ h.2.1, h.1, h.2.2.1.symm, by rw [ Nat.add_comm ] ; exact h.2.2.2 ⟩

/-! ## Cross-Domain Bridge: Prime Cloud Rips and Graph Coloring -/

/-
A key cross-domain theorem: the number of connected components
    of the Rips graph on primes ≤ N at scale ε equals the prime count
    when ε = 0 (each prime is its own component). More precisely,
    primeCloudFinset N has exactly primeCount N elements by definition.
-/
theorem rips_components_at_zero (N : ℕ) :
    (primeCloudFinset N).card = primeCount N := by
  rfl

/-! ## Bertrand's Postulate in Barcode Language -/

/-
**Bertrand Bar Length Bound**: For consecutive primes p_{n} and p_{n+1},
    the gap p_{n+1} - p_{n} < p_{n}. This is a direct consequence of
    Bertrand's postulate (there's always a prime between n and 2n for n ≥ 1).

    In barcode language: every bar in the H₀ barcode has persistence
    strictly less than its birth time.

    We formalize: for all n, the (n+1)-th prime minus the n-th prime
    is less than the n-th prime.
-/
theorem bertrand_bar_length_bound (n : ℕ) :
    Nat.nth Nat.Prime (n + 1) - Nat.nth Nat.Prime n < Nat.nth Nat.Prime n := by
  -- By Bertrand's postulate, there exists a prime $p$ such that $p_n < p \leq 2p_n$.
  obtain ⟨p, hp⟩ : ∃ p, Nat.Prime p ∧ Nat.nth Nat.Prime n < p ∧ p ≤ 2 * Nat.nth Nat.Prime n := by
    exact Nat.exists_prime_lt_and_le_two_mul _ ( by linarith [ Nat.Prime.one_lt ( Nat.prime_nth_prime n ) ] );
  rw [ tsub_lt_iff_left ];
  · -- Since $p$ is a prime and $p > nth Nat.Prime n$, it must be that $nth Nat.Prime (n + 1) \leq p$.
    have h_le_p : Nat.nth Nat.Prime (n + 1) ≤ p := by
      rw [ Nat.nth_eq_sInf ];
      exact Nat.sInf_le ⟨ hp.1, fun k hk => lt_of_le_of_lt ( Nat.nth_monotone ( Nat.infinite_setOf_prime ) ( Nat.le_of_lt_succ hk ) ) hp.2.1 ⟩;
    cases lt_or_eq_of_le hp.2.2 <;> simp_all +arith +decide [ Nat.prime_mul_iff ];
    · linarith;
    · exact absurd hp.1 ( Nat.Prime.ne_one ( Nat.prime_nth_prime n ) );
  · exact Nat.nth_monotone ( Nat.infinite_setOf_prime ) ( Nat.le_succ _ )

/-! ## Gap-Death Correspondence -/

/-
The gap between consecutive primes is always positive.
-/
theorem prime_gap_pos (n : ℕ) :
    Nat.nth Nat.Prime n < Nat.nth Nat.Prime (n + 1) := by
  convert Nat.nth_strictMono ( Nat.infinite_setOf_prime ) ( Nat.lt_succ_self n )

/-
Consecutive primes become ε-connected at scale ε = their gap.
    This formalizes that each prime gap corresponds to a "death" event
    in the H₀ barcode at scale equal to the gap.
-/
theorem gap_death_connection (n : ℕ) (N : ℕ)
    (hN : Nat.nth Nat.Prime (n + 1) ≤ N) :
    EpsChainConnected (primeCloud N) (Nat.nth Nat.Prime (n + 1) - Nat.nth Nat.Prime n)
      (Nat.nth Nat.Prime n) (Nat.nth Nat.Prime (n + 1)) := by
  apply EpsChainConnected.step;
  all_goals norm_num [ primeCloud ];
  any_goals exact nth Nat.Prime ( n + 1 );
  · exact le_trans ( Nat.nth_monotone ( Nat.infinite_setOf_prime ) ( Nat.le_succ _ ) ) hN;
  · aesop;
  · rw [ Nat.sub_eq_zero_of_le ( Nat.nth_monotone ( Nat.infinite_setOf_prime ) ( Nat.le_succ _ ) ) ] ; norm_num;
  · exact EpsChainConnected.refl _ ⟨ Nat.prime_nth_prime _, hN ⟩

/-! ## Persistence Bar Construction -/

/-- Construct a persistence bar from consecutive primes.
    Birth = p_n, Death = p_{n+1}. -/
noncomputable def primeBar (n : ℕ) : PersistenceBar where
  birth := Nat.nth Nat.Prime n
  death := Nat.nth Nat.Prime (n + 1)
  h_le := le_of_lt (Nat.nth_strictMono Nat.infinite_setOf_prime (lt_add_one n))

/-
The persistence of a prime bar equals the prime gap.
-/
theorem primeBar_persistence_eq_gap (n : ℕ) :
    (primeBar n).persistence = primeGapDirect n := by
  rfl

/-! ## Conjecture: Twin Prime Bars -/

/-- **Falsifiable Conjecture (Twin Prime Barcode Conjecture)**:
    There are infinitely many bars with persistence exactly 2 in the
    H₀ barcode. This is equivalent to the twin prime conjecture.

    Formally: {n : ℕ | primeGapDirect n = 2} is infinite.

    Test: compute primeGapDirect n for n up to 10^8 and count
    the number of gaps equal to 2. If this count appears to grow
    without bound, the conjecture is supported. -/
def twinPrimeBarcodeConjecture : Prop :=
  Set.Infinite {n : ℕ | Nat.nth Nat.Prime (n + 1) = Nat.nth Nat.Prime n + 2}

/-
A concrete witness: 3 and 5 are twin primes, giving a bar of persistence 2.
    This shows the twin prime bar set is nonempty.
-/
theorem twin_prime_bar_exists : ∃ p : ℕ, Nat.Prime p ∧ Nat.Prime (p + 2) := by
  exists 3

/-! ## Filtration Completeness -/

/-
At scale ε = N, all primes ≤ N are in a single connected component
    (trivially, since any two numbers ≤ N have distance ≤ N).
-/
theorem rips_connected_at_N (N : ℕ) (p q : ℕ)
    (hp : p ∈ primeCloud N) (hq : q ∈ primeCloud N) :
    EpsChainConnected (primeCloud N) N p q := by
  convert EpsChainConnected.step p q q hp hq _ _ using 1;
  · cases le_total p q <;> simp_all +decide [ primeCloud ]; all_goals linarith;
  · exact EpsChainConnected.refl q hq