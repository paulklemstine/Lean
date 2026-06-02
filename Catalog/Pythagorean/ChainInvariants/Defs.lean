import Mathlib

/-!
# Chain Invariants in Divisibility Lattices

## Overview

This file develops a theory connecting the combinatorial structure of divisibility
chains with classical arithmetic functions. A **divisibility chain** from 1 to n
is a sequence 1 = a₀ | a₁ | ... | aₖ = n where each element strictly divides
the next. We establish three main results:

1. **Chain Rank Theorem**: The maximum length of a divisibility chain from 1 to n
   equals Ω(n), the number of prime factors of n counted with multiplicity.

2. **Spectrum Rigidity**: In any maximal-length chain, each quotient aᵢ₊₁/aᵢ is
   prime, and the multiset of these quotients is exactly the prime factorization
   of n. Consequently, the sum of quotients (the "spectrum sum") equals sopfr(n).

3. **Exponential Growth**: Elements in a divisibility chain grow at least as fast
   as 2^k, giving a logarithmic bound on chain length.

## Novel Concepts

- **Chain Spectrum**: The list of consecutive quotients along a divisibility chain.
- **Sum of Prime Factors with Repetition** (sopfr): The sum of the
  prime factorization list.
- **Chain Defect**: The gap between Ω(n) and the length of a given chain.

## Key Insight

The Chain Rank Theorem transforms the arithmetic function Ω from a purely
number-theoretic object into a lattice-theoretic invariant: it measures
the "depth" of n in the divisibility lattice of ℕ. The Spectrum Rigidity
theorem then shows that this depth has a unique "cost structure" — every
path from 1 to n of maximum length pays the same toll at each step (a prime),
and the total cost is always sopfr(n).
-/

open Finset BigOperators List Nat

noncomputable section

/-! ## Part I: Arithmetic Functions -/

/-- The **big omega function** Ω(n): total number of prime factors of n counted
with multiplicity. Equivalently, the length of the prime factorization list. -/
def Omega (n : ℕ) : ℕ := n.primeFactorsList.length

/-- The **sum of prime factors with repetition** sopfr(n): the sum of all prime
factors of n counted with multiplicity. -/
def sopfr (n : ℕ) : ℕ := n.primeFactorsList.sum

/-- Ω(1) = 0: the unit has no prime factors. -/
@[simp] theorem Omega_one : Omega 1 = 0 := by
  simp [Omega, Nat.primeFactorsList]

/-- sopfr(1) = 0. -/
@[simp] theorem sopfr_one : sopfr 1 = 0 := by
  simp [sopfr, Nat.primeFactorsList]

/-- Ω(p) = 1 for prime p. -/
theorem Omega_prime {p : ℕ} (hp : p.Prime) : Omega p = 1 := by
  simp [Omega, Nat.primeFactorsList_prime hp]

/-- sopfr(p) = p for prime p. -/
theorem sopfr_prime {p : ℕ} (hp : p.Prime) : sopfr p = p := by
  simp [sopfr, Nat.primeFactorsList_prime hp]

/-- Ω(n) > 0 for n ≥ 2. -/
theorem Omega_pos {n : ℕ} (hn : 2 ≤ n) : 0 < Omega n := by
  unfold Omega
  exact List.length_pos_of_ne_nil ((Nat.primeFactorsList_ne_nil n).mpr (by omega))

/-! ## Part II: Complete Additivity of Ω -/

/-
Ω is completely additive: Ω(a·b) = Ω(a) + Ω(b) for positive a, b.
This is the key property that connects Ω to chain combinatorics.
-/
theorem Omega_mul {a b : ℕ} (ha : a ≠ 0) (hb : b ≠ 0) :
    Omega (a * b) = Omega a + Omega b := by
  have h_conv : a.primeFactorsList ++ b.primeFactorsList ~ (a * b).primeFactorsList := by
    rw [ List.perm_iff_count ];
    intro p; by_cases hp : p.Prime <;> simp_all +decide [ Nat.primeFactorsList_count_eq ] ;
  simpa [ Omega ] using h_conv.length_eq.symm

/-
If a | b with both positive, then Ω(a) ≤ Ω(b).
-/
theorem Omega_le_of_dvd {a b : ℕ} (ha : a ≠ 0) (hb : b ≠ 0) (h : a ∣ b) :
    Omega a ≤ Omega b := by
  obtain ⟨ k, rfl ⟩ := h;
  rw [ Omega_mul ha ( by aesop ) ] ; simp +arith +decide

/-
If a strictly divides b (i.e., a | b and a ≠ b, both positive),
then Ω(a) < Ω(b). This is the engine of the Chain Rank Theorem.
-/
theorem Omega_lt_of_strict_dvd {a b : ℕ} (ha : 0 < a) (hb : 0 < b)
    (hdvd : a ∣ b) (hne : a ≠ b) : Omega a < Omega b := by
  obtain ⟨ k, hk ⟩ := hdvd;
  rcases k with ( _ | _ | k ) <;> simp_all +decide;
  rw [ Omega_mul ] <;> norm_num [ ha.ne' ];
  exact Omega_pos ( by linarith )

/-! ## Part III: Divisibility Chains -/

/-- A **strict divisibility chain** is a list of positive natural numbers where
each element strictly divides the next. The **length** of the chain is
`chain.length - 1` (the number of divisibility steps). -/
structure StrictDivChain where
  /-- The elements of the chain. -/
  chain : List ℕ
  /-- The chain is nonempty. -/
  nonempty : chain ≠ []
  /-- All elements are positive. -/
  all_pos : ∀ x ∈ chain, 0 < x
  /-- Each element strictly divides the next. -/
  strict_dvd : chain.IsChain (fun a b => a ∣ b ∧ a ≠ b)

/-- The length of a strict divisibility chain (number of steps). -/
def StrictDivChain.len (c : StrictDivChain) : ℕ := c.chain.length - 1

/-- The first element of a chain. -/
def StrictDivChain.first (c : StrictDivChain) : ℕ :=
  c.chain.head c.nonempty

/-- The last element of a chain. -/
def StrictDivChain.last (c : StrictDivChain) : ℕ :=
  c.chain.getLast c.nonempty

/-- A divisibility chain from 1 to n. -/
structure DivChainFromTo (n : ℕ) extends StrictDivChain where
  /-- The chain starts at 1. -/
  start_one : chain.head toStrictDivChain.nonempty = 1
  /-- The chain ends at n. -/
  end_n : chain.getLast toStrictDivChain.nonempty = n

/-! ## Part IV: Chain Rank Theorem -/

/-
**Chain Rank Theorem (upper bound)**: Any strict divisibility chain from 1 to n
has length at most Ω(n). This follows from the strict monotonicity of Ω along
divisibility chains: each step increases Ω by at least 1.
-/
theorem chain_length_le_Omega (n : ℕ) (hn : 0 < n)
    (c : DivChainFromTo n) : c.len ≤ Omega n := by
  -- By induction on the length of the chain, we can show that the length of the chain is at most `Omega n`.
  have h_ind : ∀ (k : ℕ), (∀ (c : StrictDivChain), c.chain.length = k + 1 → c.first = 1 → c.chain.getLast c.nonempty = n → c.len ≤ Omega n) := by
    intros k c hc_chain hc_first hc_last
    have h_ind_step : ∀ (i : ℕ) (hi : i < k + 1), Omega (c.chain[i]!) ≥ i := by
      intro i hi
      induction' i with i ih
      generalize_proofs at *; (
      exact Nat.zero_le _);
      have h_step : c.chain[i]! ∣ c.chain[i + 1]! ∧ c.chain[i]! ≠ c.chain[i + 1]! := by
        have := c.strict_dvd; simp_all +decide [ List.isChain_iff_get ] ;
        convert this ⟨ i, by omega ⟩ using 1 <;> simp +decide [ List.getElem?_eq_getElem, hc_chain ];
        · grind;
        · grind +suggestions
      generalize_proofs at *; (
      exact Nat.succ_le_of_lt ( lt_of_le_of_lt ( ih ( Nat.lt_of_succ_lt hi ) ) ( Omega_lt_of_strict_dvd ( c.all_pos _ ( by
        grind ) ) ( c.all_pos _ ( by
        grind +ring ) ) h_step.1 h_step.2 ) ))
    generalize_proofs at *; (
    specialize h_ind_step k ; simp_all +decide [ StrictDivChain.len ] ;
    grind +ring);
  convert h_ind _ c.toStrictDivChain _ _ _;
  exacts [ List.length c.chain - 1, by rw [ Nat.sub_add_cancel ( List.length_pos_iff.mpr c.nonempty ) ], c.start_one, c.end_n ]

/-
**Chain Rank Theorem (lower bound)**: There exists a divisibility chain from
1 to n of length exactly Ω(n). The chain is constructed by peeling off one prime
factor at a time from the prime factorization list.
-/
theorem exists_chain_of_length_Omega (n : ℕ) (hn : 0 < n) :
    ∃ c : DivChainFromTo n, c.len = Omega n := by
  -- Let $l = n.primeFactorsList$. Define the chain as the list of partial products: $[1, l[0], l[0]*l[1], ..., l[0]*...*l[k-1]] = [1, ..., n]$.
  use DivChainFromTo.mk (StrictDivChain.mk (List.scanl (· * ·) 1 n.primeFactorsList) (by
  cases n <;> aesop) (by
  intro x hx;
  rw [ List.mem_iff_get ] at hx;
  obtain ⟨ i, rfl ⟩ := hx; induction i ; simp_all +decide [ List.get ] ;
  induction' ‹ℕ› with k ih <;> simp_all +decide [ List.take ];
  rw [ List.take_add_one ];
  cases h : n.primeFactorsList[k]? <;> simp_all +decide [ List.getElem?_eq_none ];
  exact ⟨ ih ( Nat.le_of_lt ‹_› ), h ▸ Nat.pos_of_mem_primeFactorsList ( List.getElem_mem _ ) ⟩) (by
  rw [ List.isChain_iff_get ];
  intro i; rcases i with ⟨ i, hi ⟩ ; simp_all +decide [ Fin.cast, List.get ] ;
  cases h : n.primeFactorsList[i]? <;> simp_all +decide [ List.take_add_one ];
  have h_prime : Nat.Prime (n.primeFactorsList[i]) := by
    exact Nat.prime_of_mem_primeFactorsList ( List.getElem_mem _ );
  by_cases h : foldl ( fun x1 x2 => x1 * x2 ) 1 ( take i n.primeFactorsList ) = 0 <;> simp_all +decide [ Nat.Prime.ne_zero ];
  · have h_contra : ∀ {l : List ℕ}, (∀ x ∈ l, Nat.Prime x) → foldl (fun x1 x2 => x1 * x2) 1 l = 0 → False := by
      intros l hl hfold; induction' l using List.reverseRecOn with l ih <;> simp_all +decide [ Nat.Prime.ne_zero ] ;
    exact h_contra ( fun x hx => Nat.prime_of_mem_primeFactorsList <| List.mem_of_mem_take hx ) h;
  · exact h_prime.ne_one)) (by
  grind) (by
  convert Nat.prod_primeFactorsList hn.ne' using 1;
  -- By definition of `scanl`, the last element of the list is the product of all elements in the list.
  have h_scanl_last : ∀ (l : List ℕ) (x : ℕ), (List.scanl (fun x1 x2 => x1 * x2) x l).getLast (by
  cases l <;> simp +decide [ List.scanl ]) = x * l.prod := by
    intro l x; induction l generalizing x <;> simp_all +decide [ List.scanl ] ;
    grind +revert
  generalize_proofs at *;
  aesop)
  generalize_proofs at *;
  unfold StrictDivChain.len Omega; aesop;

/-- **Chain Rank Theorem**: The maximum length of a divisibility chain from 1 to n
equals Ω(n), the number of prime factors with multiplicity.

This transforms the arithmetic function Ω from a number-theoretic quantity
into a lattice-theoretic invariant measuring the "depth" of n in the
divisibility lattice. -/
theorem chain_rank_eq_Omega (n : ℕ) (hn : 0 < n) :
    IsGreatest {k | ∃ c : DivChainFromTo n, c.len = k} (Omega n) := by
  refine ⟨?_, ?_⟩
  · exact exists_chain_of_length_Omega n hn
  · intro k ⟨c, hc⟩
    rw [← hc]
    exact chain_length_le_Omega n hn c

/-! ## Part V: Chain Spectrum -/

/-- The **spectrum** of a strict divisibility chain: the list of consecutive
quotients aᵢ₊₁/aᵢ along the chain. Since each aᵢ divides aᵢ₊₁, these quotients
are always natural numbers ≥ 2. -/
def StrictDivChain.spectrum (c : StrictDivChain) : List ℕ :=
  (c.chain.zip c.chain.tail).map (fun ⟨a, b⟩ => b / a)

/-- The **spectrum sum** of a chain: the sum of all quotients. -/
def StrictDivChain.spectrumSum (c : StrictDivChain) : ℕ :=
  c.spectrum.sum

/-
**Product of spectrum equals endpoint ratio**: The product of all quotients
in a chain from 1 to n equals n. This is the telescoping identity.
-/
theorem spectrum_prod_eq (n : ℕ) (hn : 0 < n) (c : DivChainFromTo n) :
    c.spectrum.prod = n := by
  have h_prod : ∀ {l : List ℕ}, l ≠ [] → (∀ x ∈ l, 0 < x) → (∀ p ∈ l.zip l.tail, p.1 ∣ p.2) → List.prod (List.map (fun p => p.2 / p.1) (l.zip l.tail)) = l.getLast! / l.head! := by
    intros l hl hpos hdiv
    induction' l with a l ih;
    · contradiction;
    · rcases l with ( _ | ⟨ b, l ⟩ ) <;> simp_all +decide;
      rw [ Nat.div_mul_div_comm hdiv.1 ];
      · rw [ Nat.mul_comm, Nat.mul_div_mul_right _ _ hpos.2.1 ];
      · have h_ind : ∀ {l : List ℕ}, l ≠ [] → (∀ x ∈ l, 0 < x) → (∀ p ∈ l.zip l.tail, p.1 ∣ p.2) → l.head! ∣ l.getLast! := by
          intros l hl hpos hdiv; induction' l with a l ih <;> simp_all +decide [ List.zip ] ;
          rcases l with ( _ | ⟨ b, l ⟩ ) <;> simp_all +decide [ List.getLast? ];
          exact dvd_trans ( hdiv _ _ ( Or.inl ⟨ rfl, rfl ⟩ ) ) ih;
        specialize @h_ind ( b :: l ) ; aesop;
  convert h_prod c.nonempty c.all_pos _ using 1;
  · rw [ Nat.div_eq_of_eq_mul_left ];
    · have := c.all_pos ( c.chain.head! ) ( List.head!_mem_self c.nonempty ) ; aesop;
    · have := c.start_one; have := c.end_n; cases h : c.chain <;> aesop;
  · have := c.toStrictDivChain.strict_dvd;
    rw [ List.isChain_iff_get ] at this;
    intro p hp; rw [ List.mem_iff_get ] at hp; obtain ⟨ i, hi ⟩ := hp; simp_all +decide [ Fin.castSucc, Fin.succ ] ;
    grind +revert

/-
In a maximal chain (length = Ω(n)), each quotient in the spectrum is prime.
-/
theorem maximal_chain_spectrum_all_prime (n : ℕ) (hn : 2 ≤ n)
    (c : DivChainFromTo n) (hmax : c.len = Omega n) :
    ∀ q ∈ c.spectrum, Nat.Prime q := by
  -- By definition of `StrictDivChain`, each quotient in the spectrum is at least 2.
  have h_quotient_ge_two : ∀ q ∈ c.spectrum, 2 ≤ q := by
    intro q hq
    obtain ⟨a, b, hab⟩ : ∃ a b, a ∈ c.chain ∧ b ∈ c.chain ∧ b / a = q ∧ a ∣ b ∧ a ≠ b := by
      unfold StrictDivChain.spectrum at hq; simp_all +decide [ List.mem_map ] ;
      rcases hq with ⟨ a, b, h₁, rfl ⟩ ; rcases List.mem_iff_get.1 h₁ with ⟨ i, hi ⟩ ; simp_all +decide [ List.get ] ;
      have := c.toStrictDivChain.strict_dvd; simp_all +decide [ List.IsChain ] ;
      have := List.isChain_iff_get.mp this; simp_all +decide [ Fin.add_def, Nat.mod_eq_of_lt ] ;
      grind;
    nlinarith [ Nat.div_mul_cancel hab.2.2.2.1, Nat.pos_of_ne_zero ( show a ≠ 0 from Nat.ne_of_gt ( c.toStrictDivChain.all_pos a hab.1 ) ), show b > a from lt_of_le_of_ne ( Nat.le_of_dvd ( Nat.pos_of_ne_zero ( show b ≠ 0 from Nat.ne_of_gt ( c.toStrictDivChain.all_pos b hab.2.1 ) ) ) hab.2.2.2.1 ) hab.2.2.2.2 ];
  -- Since the chain has length c.len = Omega n, and each step increases Omega by at least 1, each step must increase Omega by exactly 1.
  have h_step_incr : ∀ i < c.chain.length - 1, Omega (c.chain[i+1]!) = Omega (c.chain[i]!) + 1 := by
    have h_step_incr : ∀ i < c.chain.length - 1, Omega (c.chain[i+1]!) ≥ Omega (c.chain[i]!) + 1 := by
      intros i hi
      have h_div : c.chain[i]! ∣ c.chain[i+1]! ∧ c.chain[i]! ≠ c.chain[i+1]! := by
        have h_div : ∀ i < c.chain.length - 1, c.chain[i]! ∣ c.chain[i + 1]! ∧ c.chain[i]! ≠ c.chain[i + 1]! := by
          intro i hi
          have h_chain : c.chain.IsChain (fun a b => a ∣ b ∧ a ≠ b) := by
            exact c.toStrictDivChain.strict_dvd
          have := List.isChain_iff_get.mp h_chain;
          convert this ⟨ i, hi ⟩; all_goals grind;
        exact h_div i hi;
      apply Omega_lt_of_strict_dvd;
      · have := c.all_pos ( c.chain[i]! ) ?_;
        · exact this;
        · grind;
      · have := c.toStrictDivChain.all_pos ( c.chain[i + 1]! ) ?_;
        · linarith;
        · grind;
      · exact h_div.1;
      · exact h_div.2;
    have h_step_incr_sum : ∑ i ∈ Finset.range (c.chain.length - 1), (Omega (c.chain[i+1]!) - Omega (c.chain[i]!)) = Omega n := by
      have h_step_incr_sum : ∑ i ∈ Finset.range (c.chain.length - 1), (Omega (c.chain[i+1]!) - Omega (c.chain[i]!)) = Omega (c.chain.getLast c.nonempty) - Omega (c.chain.head c.nonempty) := by
        have h_step_incr_sum : ∀ k ≤ c.chain.length - 1, ∑ i ∈ Finset.range k, (Omega (c.chain[i+1]!) - Omega (c.chain[i]!)) = Omega (c.chain[k]!) - Omega (c.chain.head c.nonempty) := by
          intro k hk; induction' k with k ih <;> simp_all +decide [ Finset.sum_range_succ ] ;
          · grind;
          · grind +suggestions;
        grind;
      have := c.end_n; have := c.start_one; aesop;
    contrapose! h_step_incr_sum;
    obtain ⟨ i, hi, hi' ⟩ := h_step_incr_sum;
    have h_step_incr_sum : ∑ i ∈ Finset.range (c.chain.length - 1), (Omega (c.chain[i+1]!) - Omega (c.chain[i]!)) > ∑ i ∈ Finset.range (c.chain.length - 1), 1 := by
      exact Finset.sum_lt_sum ( fun i hi => by linarith [ h_step_incr i ( Finset.mem_range.mp hi ), Nat.sub_add_cancel ( show Omega c.chain[i + 1]! ≥ Omega c.chain[i]! from by linarith [ h_step_incr i ( Finset.mem_range.mp hi ) ] ) ] ) ⟨ i, Finset.mem_range.mpr hi, by have := h_step_incr i hi; have := Nat.lt_of_le_of_ne this ( Ne.symm hi' ) ; omega ⟩;
    unfold StrictDivChain.len at hmax; aesop;
  -- By definition of `StrictDivChain`, each quotient in the spectrum is a prime number.
  intros q hq
  obtain ⟨i, hi⟩ : ∃ i < c.chain.length - 1, q = c.chain[i+1]! / c.chain[i]! := by
    unfold StrictDivChain.spectrum at hq;
    rw [ List.mem_map ] at hq;
    rcases hq with ⟨ ⟨ a, b ⟩, h₁, rfl ⟩ ; rw [ List.mem_iff_get ] at h₁; obtain ⟨ i, hi ⟩ := h₁; use i; simp_all +decide [ List.get ] ;
    grind;
  -- By definition of `StrictDivChain`, we know that `c.chain[i+1]! = c.chain[i]! * q`.
  have h_chain_step : c.chain[i+1]! = c.chain[i]! * q := by
    rw [ hi.2, Nat.mul_div_cancel' ];
    have := c.toStrictDivChain.strict_dvd;
    have := List.isChain_iff_get.mp this;
    specialize this ⟨ i, by
      exact hi.1 ⟩
    generalize_proofs at *;
    grind;
  -- By definition of `Omega`, we know that `Omega (c.chain[i]! * q) = Omega (c.chain[i]!) + Omega q`.
  have h_omega_mul : Omega (c.chain[i]! * q) = Omega (c.chain[i]!) + Omega q := by
    apply Omega_mul;
    · grind;
    · linarith [ h_quotient_ge_two q hq ];
  -- Since `Omega q = 1`, we know that `q` is a prime number.
  have h_omega_q_one : Omega q = 1 := by
    grind;
  unfold Omega at h_omega_q_one;
  rw [ List.length_eq_one_iff ] at h_omega_q_one;
  obtain ⟨ a, ha ⟩ := h_omega_q_one; rw [ ← Nat.prod_primeFactorsList ( by linarith [ h_quotient_ge_two q hq ] : q ≠ 0 ) ] ; simp +decide [ ha ] ;
  exact Nat.prime_of_mem_primeFactorsList ( ha.symm ▸ List.mem_singleton_self _ )

/-
**Spectrum Sum Rigidity**: In any maximal-length divisibility chain from 1 to n,
the sum of consecutive quotients equals sopfr(n), the sum of prime factors
with repetition.

This is a surprising rigidity result: while different maximal chains through the
divisibility lattice can take very different paths (e.g., from 1 to 12 via
1→2→4→12 or 1→3→6→12), they all have the same spectrum sum.

The proof uses the fact that in a maximal chain, each quotient is prime, and
the product of quotients is n. By unique factorization, the multiset of
quotients must equal the prime factorization of n, so their sum is sopfr(n).
-/
theorem spectrum_sum_eq_sopfr (n : ℕ) (hn : 2 ≤ n)
    (c : DivChainFromTo n) (hmax : c.len = Omega n) :
    c.spectrumSum = sopfr n := by
  -- By maximal_chain_spectrum_all_prime, every element q of c.spectrum is prime.
  have h_prime : ∀ q ∈ c.spectrum, Nat.Prime q := by
    exact?;
  -- By spectrum_prod_eq, the product of c.spectrum equals n.
  have h_prod : c.spectrum.prod = n := by
    exact spectrum_prod_eq n ( pos_of_gt hn ) c;
  -- By the fundamental theorem of arithmetic (unique factorization), the multiset underlying c.spectrum must be the same as the multiset underlying n.primeFactorsList (both are lists of primes with product n).
  have h_multiset : c.spectrum.Perm n.primeFactorsList := by
    exact?;
  exact List.Perm.sum_eq h_multiset

/-! ## Part VI: Chain Defect -/

/-- The **chain defect** of a divisibility chain from 1 to n: the difference
between the maximum possible length Ω(n) and the actual length. A chain
has defect 0 if and only if it is maximally refined. -/
def chainDefect (n : ℕ) (c : DivChainFromTo n) : ℕ :=
  Omega n - c.len

/-- A chain is maximal (defect 0) iff its length equals Ω(n). -/
theorem maximal_iff_defect_zero (n : ℕ) (hn : 0 < n) (c : DivChainFromTo n) :
    chainDefect n c = 0 ↔ c.len = Omega n := by
  constructor
  · intro h
    have hle := chain_length_le_Omega n hn c
    unfold chainDefect at h
    omega
  · intro h
    simp [chainDefect, h]

/-! ## Part VII: Exponential Growth Lemma -/

/-
Elements in a strict divisibility chain grow at least exponentially:
the k-th element is at least 2^k. This is because each strict divisibility
step at least doubles the value (since b/a ≥ 2 when a | b and a ≠ b with a > 0).
-/
theorem chain_exponential_growth (c : StrictDivChain) (k : ℕ) (hk : k < c.chain.length) :
    2 ^ k ≤ c.chain.get ⟨k, hk⟩ := by
  induction' k with k ih;
  · exact c.all_pos _ ( by simp );
  · convert Nat.mul_le_mul ( ih <| Nat.lt_of_succ_lt hk ) ( show 2 ≤ c.chain.get ⟨ k + 1, hk ⟩ / c.chain.get ⟨ k, Nat.lt_of_succ_lt hk ⟩ from ?_ ) using 1;
    · rw [ Nat.mul_div_cancel' ];
      have := c.strict_dvd;
      have := List.isChain_iff_get.mp this;
      exact this ⟨ k, Nat.lt_pred_iff.mpr hk ⟩ |>.1;
    · have := c.strict_dvd; simp_all +decide [ List.isChain_iff_get ] ;
      exact Nat.lt_of_le_of_ne ( Nat.div_pos ( Nat.le_of_dvd ( c.all_pos _ ( by simp ) ) ( this ⟨ k, Nat.lt_pred_iff.mpr hk ⟩ |>.1 ) ) ( c.all_pos _ ( by simp ) ) ) ( Ne.symm <| by intro t; have := this ⟨ k, Nat.lt_pred_iff.mpr hk ⟩ ; have := Nat.div_mul_cancel this.1; aesop )

/-
**Chain length is logarithmically bounded**: Any strict divisibility chain
ending at n has length at most log₂(n). Combined with the Chain Rank Theorem,
this gives Ω(n) ≤ log₂(n).
-/
theorem chain_length_le_log2 (n : ℕ) (hn : 0 < n) (c : DivChainFromTo n) :
    c.len ≤ Nat.log 2 n := by
  refine Nat.le_log_of_pow_le ( by decide ) ?_;
  -- By the properties of the chain, we know that $2^{\text{len}(c)} \leq c.last$.
  have h_chain_length : 2 ^ c.len ≤ c.chain.getLast c.toStrictDivChain.nonempty := by
    convert chain_exponential_growth c.toStrictDivChain ( c.chain.length - 1 ) _ using 1;
    grind;
    exact Nat.pred_lt ( ne_bot_of_gt ( List.length_pos_iff.mpr c.nonempty ) );
  exact h_chain_length.trans ( by rw [ c.end_n ] )

/-! ## Part VIII: Conjectures -/

/-- **Chain Spectrum Refinement Conjecture**: For any n with at least two distinct
prime factors, the number of distinct maximal chains from 1 to n equals the
multinomial coefficient Ω(n)! / ∏ᵢ eᵢ!, where eᵢ are the exponents in
the prime factorization.

Computational test: For n = 12 = 2²·3, we expect 3!/(2!·1!) = 3 maximal chains,
which matches: {1→2→4→12, 1→2→6→12, 1→3→6→12}. For n = 30 = 2·3·5, we expect
3!/1!1!1! = 6 chains. -/
def ChainCountConjecture : Prop :=
  ∀ n : ℕ, 2 ≤ n → ∀ (chains : Finset (DivChainFromTo n)),
    (∀ c ∈ chains, c.len = Omega n) →
    (∀ c₁ ∈ chains, ∀ c₂ ∈ chains, c₁.chain = c₂.chain → c₁ = c₂) →
    chains.card ≤ n.primeFactorsList.length.factorial /
      (n.primeFactors.prod fun p => (n.factorization p).factorial)

end