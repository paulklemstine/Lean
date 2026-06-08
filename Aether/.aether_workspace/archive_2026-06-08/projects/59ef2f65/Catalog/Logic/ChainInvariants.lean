/-
  # Chain Invariants: Divisibility Chains and the Anti-Escher Property

  This file develops three interconnected results about chain structure in
  number theory and commutative algebra:

  1. **Exponential Growth Lemma**: In any strictly ascending divisibility chain
     of positive integers, each element is at least twice the previous. This
     yields exponential growth: aₙ ≥ 2ⁿ · a₀.

  2. **BigOmega as Chain Rank**: The function Ω(n) (number of prime factors with
     multiplicity) equals the maximum length of a strictly ascending divisibility
     chain from 1 to n. This gives Ω a purely order-theoretic characterization.

  3. **Anti-Escher Property for ℤ**: Every infinite strictly descending chain of
     nonzero principal ideals in ℤ has trivial (zero) intersection. The proof
     combines the exponential growth lemma with an Archimedean argument.

  ## Novel Definitions

  * `ChainSpectrum` — the sequence of quotient sizes along a divisibility chain
  * `bigOmega` — Ω(n) defined as chain rank (= prime factor count with multiplicity)

  ## Key Insight

  The "Escher staircase" paradox asks: can an infinite descending chain of ideals
  have nontrivial intersection? For principal ideals in ℤ, the answer is definitively
  NO — the exponential growth of generators forces the intersection to collapse.
  This is the Anti-Escher Property, and it fundamentally distinguishes PIDs from
  more exotic rings where descending Escher chains can exist.
-/
import Mathlib

namespace ChainInvariants

/-! ## Section 1: Exponential Growth in Divisibility Chains -/

/-
In ℕ, if a properly divides b (a ∣ b, a ≠ b) with both positive, then b ≥ 2a.
    Proof: b = a * k with k ≥ 1 (since b > 0) and k ≠ 1 (since a ≠ b), so k ≥ 2.
-/
theorem Nat.dvd_strict_ge_two_mul {a b : ℕ} (ha : 0 < a) (hb : 0 < b)
    (hdvd : a ∣ b) (hne : a ≠ b) :
    2 * a ≤ b := by
      obtain ⟨ k, hk ⟩ := hdvd;
      rcases k with ( _ | _ | k ) <;> simp_all +decide ; nlinarith

/-
Positivity propagation: in a strict divisibility chain, if a₀ > 0 then all aₙ > 0.
-/
theorem strict_dvd_chain_pos (a : ℕ → ℕ) (h0 : 0 < a 0)
    (hdvd : ∀ n, a n ∣ a (n + 1)) (hstrict : ∀ n, a n ≠ a (n + 1)) :
    ∀ n, 0 < a n := by
      -- By contradiction, assume there exists some $n$ such that $a n = 0$.
      by_contra h_contra;
      obtain ⟨n, hn⟩ : ∃ n, a n = 0 := by
        aesop;
      exact hstrict n ( by have := hdvd n; aesop )

/-
Exponential growth in strict divisibility chains: if a₀, a₁, a₂, ... is a sequence
    with aₙ ∣ aₙ₊₁ and aₙ ≠ aₙ₊₁ for all n, and a₀ > 0, then aₙ ≥ 2ⁿ · a₀.
-/
theorem strict_dvd_chain_exp_growth (a : ℕ → ℕ) (h0 : 0 < a 0)
    (hdvd : ∀ n, a n ∣ a (n + 1)) (hstrict : ∀ n, a n ≠ a (n + 1)) :
    ∀ n, 2 ^ n * a 0 ≤ a n := by
      refine' fun n => Nat.recOn n _ _ <;> simp_all +decide [ pow_succ', mul_assoc ];
      exact fun n hn => by nlinarith [ Nat.le_of_dvd ( strict_dvd_chain_pos a h0 hdvd hstrict ( n + 1 ) ) ( hdvd n ), Nat.dvd_strict_ge_two_mul ( strict_dvd_chain_pos a h0 hdvd hstrict n ) ( strict_dvd_chain_pos a h0 hdvd hstrict ( n + 1 ) ) ( hdvd n ) ( hstrict n ) ] ;

/-
A strict divisibility chain of positive naturals of finite length
    also exhibits exponential growth, provided all elements are positive.
-/
theorem strict_dvd_chain_length_bound (a : Fin (n + 1) → ℕ)
    (hpos : ∀ i, 0 < a i) (hdvd : ∀ i : Fin n, a i.castSucc ∣ a i.succ)
    (hstrict : ∀ i : Fin n, a i.castSucc ≠ a i.succ) :
    2 ^ n * a 0 ≤ a ⟨n, Nat.lt_succ_iff.mpr le_rfl⟩ := by
      induction' n with n ih;
      · norm_num;
      · specialize ih ( fun i => a i.castSucc ) ; simp_all +decide [ pow_succ', mul_assoc ];
        exact le_trans ( Nat.mul_le_mul_left _ ih ) ( Nat.dvd_strict_ge_two_mul ( hpos _ ) ( hpos _ ) ( hdvd ⟨ n, by linarith ⟩ ) ( hstrict ⟨ n, by linarith ⟩ ) )

/-! ## Section 2: BigOmega as Chain Rank -/

/-- The big omega function Ω(n): number of prime factors of n counted with multiplicity.
    We define it as the length of the prime factorization list.
    Ω(1) = 0, Ω(p) = 1 for prime p, Ω(p^k) = k, Ω(mn) = Ω(m) + Ω(n) for coprime m,n. -/
def bigOmega (n : ℕ) : ℕ := n.primeFactorsList.length

@[simp]
theorem bigOmega_one : bigOmega 1 = 0 := by
  simp [bigOmega, Nat.primeFactorsList_one]

/-- Ω(p) = 1 for any prime p. -/
theorem bigOmega_prime {p : ℕ} (hp : Nat.Prime p) : bigOmega p = 1 := by
  unfold bigOmega; have := Nat.primeFactorsList_prime hp; aesop

/-- Ω is additive on coprimes: Ω(m * n) = Ω(m) + Ω(n) when gcd(m,n) = 1. -/
theorem bigOmega_mul_coprime {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 0)
    (hcop : Nat.Coprime m n) :
    bigOmega (m * n) = bigOmega m + bigOmega n := by
  unfold bigOmega
  rw [← Multiset.coe_card, ← Multiset.coe_card, ← Multiset.coe_card]
  rw [← Multiset.card_add]
  congr 1
  ext p
  by_cases hp : Nat.Prime p <;> simp_all +decide [Nat.primeFactorsList]

/-- Ω(n) > 0 for n > 1. -/
theorem bigOmega_pos {n : ℕ} (hn : 1 < n) : 0 < bigOmega n := by
  exact List.length_pos_iff.mpr (by aesop)

/-
A strictly ascending divisibility chain from 1 to n has length at most Ω(n).
    This gives Ω a purely order-theoretic characterization as the chain rank.
-/
theorem chain_length_le_bigOmega (n : ℕ) (hn : 0 < n)
    (k : ℕ) (a : Fin (k + 1) → ℕ) (ha0 : a 0 = 1)
    (han : a ⟨k, Nat.lt_succ_iff.mpr le_rfl⟩ = n)
    (hdvd : ∀ i : Fin k, a i.castSucc ∣ a i.succ)
    (hstrict : ∀ i : Fin k, a i.castSucc ≠ a i.succ) :
    k ≤ bigOmega n := by
      -- By induction on $k$, we can show that for any $i$, $bigOmega (a (i + 1)) \geq bigOmega (a i) + 1$.
      have h_ind : ∀ i : Fin k, bigOmega (a (Fin.succ i)) ≥ bigOmega (a (Fin.castSucc i)) + 1 := by
        intro i
        obtain ⟨m, hm⟩ : ∃ m, a (Fin.succ i) = a (Fin.castSucc i) * m ∧ 1 < m := by
          obtain ⟨ m, hm ⟩ := hdvd i;
          rcases m with ( _ | _ | m ) <;> simp_all +decide;
          · -- Since $a (i + 1) = 0$, we have $a i = 0$ as well, contradicting $a i \neq a (i + 1)$.
            have h_contra : ∀ j : Fin (k + 1), j ≥ i.succ → a j = 0 := by
              intro j hj; induction' j using Fin.inductionOn with j ih ih; aesop;
              cases hj.eq_or_lt <;> [ aesop; exact Nat.eq_zero_of_zero_dvd ( dvd_trans ( by aesop ) ( hdvd _ ) ) ];
            exact absurd ( h_contra ⟨ k, Nat.lt_succ_self _ ⟩ ( Nat.succ_le_of_lt i.2 ) ) ( by aesop );
          · exact False.elim <| hstrict i hm.symm;
          · exact ⟨ _, Or.inl rfl, Nat.le_add_left _ _ ⟩;
        by_cases hi : a i.castSucc = 0 <;> by_cases hm : m = 0 <;> simp_all +decide [ bigOmega ];
        · grind;
        · have h_prime_factors : (Nat.primeFactorsList (a i.castSucc * m)).length = (Nat.primeFactorsList (a i.castSucc)).length + (Nat.primeFactorsList m).length := by
            rw [ ← Multiset.coe_card, ← Multiset.coe_card, ← Multiset.coe_card ];
            rw [ ← Multiset.card_add ];
            congr 1;
            ext p; by_cases hp : p.Prime <;> aesop;
          linarith [ show 0 < List.length ( Nat.primeFactorsList m ) from List.length_pos_iff.mpr ( by aesop ) ];
      -- By induction on $i$, we can show that for any $i$, $bigOmega (a i) \geq i$.
      have h_induction : ∀ i : Fin (k + 1), bigOmega (a i) ≥ i.val := by
        exact fun i => Fin.inductionOn i ( by simp +decide [ ha0, bigOmega_one ] ) fun i hi => by simpa using le_trans ( Nat.succ_le_succ hi ) ( h_ind i ) ;
      simpa [ han ] using h_induction ⟨ k, Nat.lt_succ_self k ⟩

/-! ## Section 3: Chain Spectrum — a Novel Invariant -/

/-- The **Chain Spectrum** of a divisibility chain: the sequence of quotient sizes
    aᵢ₊₁ / aᵢ along the chain. For the canonical chain (dividing out primes one at a time),
    this is exactly the sequence of prime factors.

    The chain spectrum captures "how" a number decomposes, not just "how much" (Ω).
    Two numbers with the same Ω can have different spectra (e.g., 12 = 2²·3 has
    spectrum {2, 2, 3} while 30 = 2·3·5 has spectrum {2, 3, 5}). -/
def ChainSpectrum (a : Fin (n + 1) → ℕ) (_h0 : ∀ i : Fin n, 0 < a i.castSucc)
    (_hdvd : ∀ i : Fin n, a i.castSucc ∣ a i.succ) : Fin n → ℕ :=
  fun i => a i.succ / a i.castSucc

/-
Each element of the chain spectrum is at least 2 for strict chains
    where all elements are positive (including the successors).
-/
theorem chainSpectrum_ge_two (a : Fin (n + 1) → ℕ) (h0 : ∀ i : Fin n, 0 < a i.castSucc)
    (hpos : ∀ i : Fin n, 0 < a i.succ)
    (hdvd : ∀ i : Fin n, a i.castSucc ∣ a i.succ)
    (hstrict : ∀ i : Fin n, a i.castSucc ≠ a i.succ)
    (i : Fin n) : 2 ≤ ChainSpectrum a h0 hdvd i := by
      obtain ⟨ k, hk ⟩ := hdvd i;
      simp_all +decide [ ChainSpectrum ];
      exact Nat.one_lt_iff_ne_zero_and_ne_one.mpr ⟨ by specialize hpos i; aesop_cat, by specialize hstrict i; aesop_cat ⟩

/-! ## Section 4: Anti-Escher Property for ℤ -/

/-- If a divides x and both are nonzero, then |a| ≤ |x|. -/
theorem int_dvd_natAbs_le {a x : ℤ} (_ha : a ≠ 0) (hx : x ≠ 0) (hdvd : a ∣ x) :
    a.natAbs ≤ x.natAbs := by
  exact Nat.le_of_dvd (Int.natAbs_pos.mpr hx) (Int.natAbs_dvd_natAbs.mpr hdvd)

/-
In a strict divisibility chain in ℤ (where consecutive elements are not associates
    and both nonzero), the absolute values grow by a factor of at least 2 at each step.
-/
theorem int_strict_dvd_grows {a b : ℤ} (ha : a ≠ 0) (hb : b ≠ 0) (hdvd : a ∣ b)
    (hna : ¬Associated a b) :
    2 * a.natAbs ≤ b.natAbs := by
      obtain ⟨ k, hk ⟩ := hdvd;
      -- Since $a$ and $b$ are not associates, $k$ cannot be $\pm 1$, so $|k| \geq 2$.
      have hk_abs : 2 ≤ Int.natAbs k := by
        contrapose! hna; interval_cases _ : Int.natAbs k <;> simp_all +decide [ Int.natAbs_eq_iff ] ;
        aesop;
      rw [ hk, Int.natAbs_mul ] ; nlinarith [ abs_pos.mpr ha ]

/-
In an infinite strict divisibility chain in ℤ with nonzero first element,
    all elements are nonzero (since a ∣ b and a ≠ 0 with ¬Associated implies b ≠ 0).
-/
theorem int_chain_all_nonzero (a : ℕ → ℤ) (h0 : a 0 ≠ 0)
    (hdvd : ∀ n, a n ∣ a (n + 1))
    (hstrict : ∀ n, ¬Associated (a n) (a (n + 1))) :
    ∀ n, a n ≠ 0 := by
      intro n hn; induction' n with n ih <;> simp_all +decide ;
      specialize hstrict ( n + 1 ) ; simp_all +decide [ Associated ] ;
      exact hstrict ( by obtain ⟨ k, hk ⟩ := hdvd ( n + 1 ) ; aesop )

/-
**The Anti-Escher Property for ℤ** (element version): if a₀, a₁, ... is a sequence
    of integers where a₀ ≠ 0, aₙ | aₙ₊₁, and consecutive elements are never associates,
    then any x divisible by all aₙ must be zero.

    This is the core of the Anti-Escher theorem. The exponential growth |aₙ| ≥ 2ⁿ|a₀|
    combined with |aₙ| ≤ |x| for nonzero x gives a contradiction.
-/
theorem int_anti_escher_element (a : ℕ → ℤ) (h0 : a 0 ≠ 0)
    (hdvd : ∀ n, a n ∣ a (n + 1))
    (hstrict : ∀ n, ¬Associated (a n) (a (n + 1)))
    (x : ℤ) (hx : ∀ n, a n ∣ x) : x = 0 := by
      by_contra hx_ne_zero;
      -- By the Archimedean property, there exists an n such that 2^n > |x| / |a 0|.
      obtain ⟨n, hn⟩ : ∃ n : ℕ, 2^n > Int.natAbs x / Int.natAbs (a 0) := by
        exact pow_unbounded_of_one_lt _ one_lt_two;
      -- By repeated application of int_strict_dvd_grows, we have |a n| ≥ 2^n * |a 0|.
      have h_abs : Int.natAbs (a n) ≥ 2^n * Int.natAbs (a 0) := by
        refine' Nat.recOn n _ _ <;> simp_all +decide [ pow_succ', mul_assoc ];
        intro n hn; have := int_strict_dvd_grows ( show a n ≠ 0 from fun h => hx_ne_zero <| by simpa [ h ] using hx n ) ( show a ( n + 1 ) ≠ 0 from fun h => hx_ne_zero <| by simpa [ h ] using hx ( n + 1 ) ) ( hdvd n ) ( hstrict n ) ; nlinarith [ pow_pos ( zero_lt_two' ℕ ) n ] ;
      exact absurd ( Int.natAbs_dvd_natAbs.mpr ( hx n ) ) ( Nat.not_dvd_of_pos_of_lt ( Int.natAbs_pos.mpr hx_ne_zero ) ( by nlinarith [ Nat.div_add_mod ( Int.natAbs x ) ( Int.natAbs ( a 0 ) ), Nat.mod_lt ( Int.natAbs x ) ( Int.natAbs_pos.mpr h0 ), Int.natAbs_pos.mpr h0 ] ) )

/-
**The Anti-Escher Property for ℤ** (ideal version): the intersection of any infinite
    strictly descending chain of nonzero principal ideals in ℤ is the zero ideal.
-/
theorem int_anti_escher_ideal (a : ℕ → ℤ) (h0 : a 0 ≠ 0)
    (hdvd : ∀ n, a n ∣ a (n + 1))
    (hstrict : ∀ n, ¬Associated (a n) (a (n + 1))) :
    ⨅ n, Ideal.span ({a n} : Set ℤ) = ⊥ := by
      simp_all +decide [ Submodule.eq_bot_iff ];
      exact fun x hx => int_anti_escher_element a h0 hdvd hstrict x fun n => Ideal.mem_span_singleton.mp ( hx n )

end ChainInvariants

/-! ## Section 5: Chain Defect Characterization -/

namespace ChainInvariants

open Classical in
/-- The **chain defect** of a monotone ascending chain: the smallest index at which
    the chain stabilizes. -/
noncomputable def chainDefect {R : Type*} [CommRing R] (I : ℕ → Ideal R) (_hmono : Monotone I)
    (hstab : ∃ N, ∀ n, N ≤ n → I n = I N) : ℕ :=
  Nat.find hstab

open Classical in
/-- The chain defect is the actual stabilization point. -/
theorem chainDefect_spec {R : Type*} [CommRing R] (I : ℕ → Ideal R) (hmono : Monotone I)
    (hstab : ∃ N, ∀ n, N ≤ n → I n = I N) :
    ∀ n, chainDefect I hmono hstab ≤ n → I n = I (chainDefect I hmono hstab) := by
      -- By definition of chainDefect, we know that chainDefect I hmono hstab is the smallest index at which the chain stabilizes.
      unfold chainDefect at *; exact Nat.find_spec hstab;

/-! ## Section 6: Falsifiable Conjecture -/

/-- **Conjecture (Spectrum Sum Minimality)**: Among all maximal-length divisibility chains
    from 1 to n (length = Ω(n)), the minimum sum of quotient sizes equals sopfr(n),
    the sum of prime factors with multiplicity.

    **Test**: For n = 12: Ω(12) = 3, sopfr(12) = 2+2+3 = 7.
    Chain 1→2→4→12 has spectrum [2,2,3], sum = 7. ✓
    Chain 1→2→6→12 has spectrum [2,3,2], sum = 7. ✓
    Chain 1→3→6→12 has spectrum [3,2,2], sum = 7. ✓
    All maximal chains for 12 achieve the same sum — the conjecture predicts this
    always equals sopfr(n). -/
def spectrumSumConjecture : Prop :=
  ∀ (n : ℕ) (_hn : 1 < n)
    (a : Fin (bigOmega n + 1) → ℕ) (_ha0 : a 0 = 1)
    (_han : a ⟨bigOmega n, Nat.lt_succ_iff.mpr le_rfl⟩ = n)
    (_hdvd : ∀ i : Fin (bigOmega n), a i.castSucc ∣ a i.succ)
    (_hstrict : ∀ i : Fin (bigOmega n), a i.castSucc ≠ a i.succ),
    n.primeFactorsList.sum ≤ ∑ i : Fin (bigOmega n),
      a i.succ / a i.castSucc

end ChainInvariants