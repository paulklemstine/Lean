/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Arithmetic Statistics of Graph Jacobians

This file establishes the deterministic algebraic backbone connecting
graph Jacobians (via Smith normal form invariant factors) to arithmetic
statistics in the spirit of Cohen–Lenstra heuristics.

## Mathematical Context

For a finite connected graph G, the **graph Jacobian** (also called the
critical group or sandpile group) is the finite abelian group
  Jac(G) ≅ ⊕ᵢ ℤ/dᵢℤ
where (d₁, …, dᵣ) are the Smith normal form invariant factors of a
reduced Laplacian of G. These invariant factors encode the complete
arithmetic structure of Jac(G).

The **Cohen–Lenstra heuristics** predict that for random graphs in suitable
regimes, the p-primary statistics of Jac(G) follow specific distributions.
This file proves the exact finite-n structural theorems that make such
predictions mathematically precise:

1. **Divisibility criterion** (Theorem A): q^k ∣ exp(Jac(G)) iff q^k divides
   some invariant factor.
2. **Prime-power moment identity** (Theorem B): The q^k-torsion count equals
   the product of gcd(dᵢ, q^k).
3. **Profile recovery** (Theorem C): The q-primary partition profile is
   recoverable from moment valuations via discrete differences.

## Main Definitions

* `InvariantFactorData` — Smith normal form data as a function from Fin n to ℕ
* `InvariantFactorData.exponent` — the exponent (lcm of all factors)
* `InvariantFactorData.primePowerMoment` — the q^k-torsion count
* `InvariantFactorData.qProfileCount` — the q-primary profile count
* `InvariantFactorProfile` — structure for q-primary partition data

## Cross-Domain Significance

These theorems bridge:
- **Graph theory ↔ Number theory**: Graph Jacobians are finite abelian groups
  whose arithmetic invariants obey the same algebraic laws as class groups.
- **Combinatorial probability ↔ Arithmetic statistics**: Random graph
  Laplacians produce groups whose laws match Cohen–Lenstra distributions.
- **Tropical geometry ↔ Arithmetic invariants**: The Jacobian is a
  tropical-harmonic object whose invariant factors obey number-theoretic
  statistics via the Smith normal form bridge.

## References

* Cohen, H. and Lenstra, H.W. "Heuristics on class groups" (1984)
* Clancy, J. et al. "Cohen–Lenstra for Jacobians of random graphs" (2015)
* Wood, M.M. "Sandpile groups of random graphs" (2017)
-/

open Finset BigOperators

/-! ## Core Structures -/

/-- Smith normal form invariant factor data: a sequence of positive natural numbers
representing the diagonal entries of the Smith normal form of an integer matrix.
For graph Jacobians, these are the invariant factors of the reduced Laplacian,
giving Jac(G) ≅ ⊕ᵢ ℤ/dᵢℤ. -/
structure InvariantFactorData (n : ℕ) where
  /-- The invariant factors, each a positive natural number -/
  factors : Fin n → ℕ
  /-- Each invariant factor is positive -/
  pos : ∀ i, 0 < factors i

namespace InvariantFactorData

variable {n : ℕ}

/-- The exponent of the finite abelian group ⊕ᵢ ℤ/dᵢℤ,
which is the least common multiple of all invariant factors. -/
def exponent (S : InvariantFactorData n) : ℕ :=
  (Finset.univ : Finset (Fin n)).lcm S.factors

/-- The q^k-torsion count (prime-power moment): for the direct sum of cyclic groups
ℤ/d₁ℤ × ⋯ × ℤ/dₙℤ, this is ∏ᵢ gcd(dᵢ, q^k), counting elements killed by q^k. -/
def primePowerMoment (S : InvariantFactorData n) (q k : ℕ) : ℕ :=
  ∏ i : Fin n, Nat.gcd (S.factors i) (q ^ k)

/-- The q-primary profile count at level j: the number of invariant factors
divisible by q^j. This encodes the q-primary partition type of the group. -/
def qProfileCount (S : InvariantFactorData n) (q : ℕ) (j : ℕ) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter (fun i => q ^ j ∣ S.factors i)).card

/-- An invariant factor sequence is in **divisibility order** if each factor
divides the next: d₁ | d₂ | ⋯ | dₙ. This is the standard Smith normal form
convention. -/
def isDivisibilityOrdered (S : InvariantFactorData n) : Prop :=
  ∀ i j : Fin n, i ≤ j → S.factors i ∣ S.factors j

end InvariantFactorData

/-! ## Invariant Factor Profile

A novel structure organizing the q-primary partition data of a finite abelian
group. This is the key statistical fingerprint for Cohen–Lenstra comparisons. -/

/-- The invariant factor profile at a prime q captures the complete q-primary
partition type of a finite abelian group presented via Smith normal form.
The `levels` function gives the number of invariant factors divisible by q^j,
which is monotone decreasing since q^(j+1) | d implies q^j | d. -/
structure InvariantFactorProfile where
  /-- The underlying prime -/
  q : ℕ
  /-- Total number of invariant factors -/
  rank : ℕ
  /-- Number of invariant factors divisible by q^j -/
  levels : ℕ → ℕ
  /-- levels is monotone decreasing -/
  mono : ∀ j, levels (j + 1) ≤ levels j
  /-- levels is bounded by rank -/
  bounded : ∀ j, levels j ≤ rank

/-! ## Theorem A — Divisibility Criterion via Invariant Factors

For a finite abelian group ⊕ᵢ ℤ/dᵢℤ with exponent lcm(dᵢ), and a prime q:
  q^k ∣ lcm(dᵢ) ↔ ∃ i, q^k ∣ dᵢ

This is the fundamental arithmetic observable: the exponent is controlled
by the largest prime-power factor among all invariant factors.
-/

/-
**Theorem A (Divisibility Criterion)**: A prime power q^k divides the exponent
(lcm of invariant factors) if and only if it divides at least one invariant factor.

This is the exact arithmetic observable needed for comparing random graphs to
Cohen–Lenstra predictions: the exponent and largest invariant factor become
computable through SNF data.
-/
theorem primePow_dvd_exponent_iff_dvd_factor
    {n : ℕ} (hn : 0 < n) (S : InvariantFactorData n) (q : ℕ) (k : ℕ) (hq : Nat.Prime q) :
    q ^ k ∣ S.exponent ↔ ∃ i : Fin n, q ^ k ∣ S.factors i := by
  unfold InvariantFactorData.exponent;
  refine' ⟨ fun h => _, fun h => _ ⟩;
  · contrapose! h;
    -- If $q^k$ does not divide any of the factors, then the $q$-adic valuation of each factor is less than $k$.
    have h_val : ∀ i : Fin n, Nat.factorization (S.factors i) q < k := by
      exact fun i => Nat.lt_of_not_ge fun hi => h i <| Nat.dvd_trans ( pow_dvd_pow _ hi ) <| Nat.ordProj_dvd _ _;
    -- The $q$-adic valuation of the lcm of the factors is the maximum of the $q$-adic valuations of the factors.
    have h_lcm_val : Nat.factorization (Finset.lcm (Finset.univ : Finset (Fin n)) S.factors) q ≤ Finset.sup (Finset.univ : Finset (Fin n)) (fun i => Nat.factorization (S.factors i) q) := by
      induction' ( Finset.univ : Finset ( Fin n ) ) using Finset.induction <;> simp_all +decide;
      erw [ Nat.factorization_lcm ] <;> simp_all +decide;
      · grind;
      · exact Nat.ne_of_gt ( S.pos _ );
      · exact fun i _ => Nat.ne_of_gt ( S.pos i );
    rw [ Nat.Prime.pow_dvd_iff_le_factorization ] <;> norm_num [ hq ];
    · exact lt_of_le_of_lt h_lcm_val ( lt_of_le_of_lt ( Finset.sup_le fun i _ => Nat.le_sub_one_of_lt ( h_val i ) ) ( Nat.sub_lt ( by linarith [ h_val ⟨ 0, hn ⟩ ] ) zero_lt_one ) );
    · exact fun i => ne_of_gt ( S.pos i );
  · exact dvd_trans h.choose_spec ( Finset.dvd_lcm ( Finset.mem_univ _ ) )

/-! ## Theorem B — Prime-Power Moment Identity

For a finite abelian group ⊕ᵢ ℤ/dᵢℤ, the number of elements killed by q^k is:
  M_{q,k} = ∏ᵢ gcd(dᵢ, q^k)

This is the exact finite-n analog of the moment method behind Cohen–Lenstra.
-/

/-- **Theorem B**: The prime-power moment equals the product of gcds.
This is true by definition, but we state it as a theorem to emphasize
that it is the exact identity underlying the Cohen–Lenstra moment method:
  M_{q,k}(⊕ᵢ ℤ/dᵢℤ) = ∏ᵢ gcd(dᵢ, q^k). -/
theorem primePowerMoment_eq_prod_gcd
    {n : ℕ} (S : InvariantFactorData n) (q k : ℕ) :
    S.primePowerMoment q k = ∏ i : Fin n, Nat.gcd (S.factors i) (q ^ k) := by
  rfl

/-! ## Theorem C — Profile Recovery from Moment Valuations

The q-primary profile is recoverable from the valuations of prime-power moments
via discrete differencing.
-/

/-
The q-adic valuation of gcd(d, q^k) equals min(v_q(d), k).
This is the key bridge between gcd arithmetic and valuation theory.
-/
theorem padicVal_gcd_prime_pow (q d : ℕ) (k : ℕ) (hq : Nat.Prime q) (hd : 0 < d) :
    padicValNat q (Nat.gcd d (q ^ k)) = min (padicValNat q d) k := by
  rw [ ← Nat.factorization_def, ← Nat.factorization_def, Nat.factorization_gcd ] <;> norm_num [ hd.ne', hq.ne_zero ];
  · rw [ hq.factorization_self, mul_one ];
  · exact hq;
  · exact hq

/-
**Theorem C (Profile Recovery)**: The q-primary profile at level j
equals the discrete difference of the sum ∑ᵢ min(v_q(dᵢ), k) as k goes from j-1 to j.

Specifically, #{i : q^j ∣ dᵢ} = (∑ᵢ min(v_q(dᵢ), j)) - (∑ᵢ min(v_q(dᵢ), j-1))

This means the complete q-primary partition type is recoverable from
the sequence of prime-power moments.
-/
theorem qProfile_eq_moment_difference
    {n : ℕ} (S : InvariantFactorData n) (q : ℕ) (j : ℕ) (hq : Nat.Prime q)
    (hj : 0 < j) :
    S.qProfileCount q j =
      (∑ i : Fin n, min (padicValNat q (S.factors i)) j) -
      (∑ i : Fin n, min (padicValNat q (S.factors i)) (j - 1)) := by
  rw [ tsub_eq_of_eq_add ];
  convert Finset.sum_congr rfl fun i _ => show min ( padicValNat q ( S.factors i ) ) j = min ( padicValNat q ( S.factors i ) ) ( j - 1 ) + if q ^ j ∣ S.factors i then 1 else 0 from ?_ using 1;
  · simp +decide [ Finset.sum_add_distrib, InvariantFactorData.qProfileCount ];
    ring;
  · have h_val : q ^ j ∣ S.factors i ↔ padicValNat q (S.factors i) ≥ j := by
      rw [ ← Nat.factorization_le_iff_dvd ] <;> norm_num [ hq, S.pos i ];
      · rw [ Nat.factorization_def ] ; aesop;
      · aesop;
      · exact ne_of_gt ( S.pos i );
    grind

/-! ## Theorem D — Exponent equals last invariant factor (in divisibility order)

When invariant factors are in divisibility order (d₁ | d₂ | ⋯ | dₙ),
the exponent equals the last factor dₙ. -/

/-
**Theorem D**: When invariant factors are in divisibility order,
the exponent is the last invariant factor.

Combined with Theorem A, this gives: q^k ∣ exp(⊕ ℤ/dᵢℤ) ↔ q^k ∣ dₙ,
making the exponent directly readable from the Smith normal form.
-/
theorem exponent_eq_last_of_divisibility_ordered
    {n : ℕ} (hn : 0 < n) (S : InvariantFactorData n) (hS : S.isDivisibilityOrdered) :
    S.exponent = S.factors ⟨n - 1, Nat.sub_lt hn Nat.one_pos⟩ := by
  refine' Nat.dvd_antisymm _ _;
  · exact Finset.lcm_dvd fun i _ => hS i ⟨ n - 1, Nat.sub_lt hn zero_lt_one ⟩ ( Nat.le_pred_of_lt ( Fin.is_lt i ) );
  · exact Finset.dvd_lcm ( Finset.mem_univ _ )

/-! ## Theorem E — gcd monotonicity and moment divisibility -/

/-
gcd(d, q^k) divides gcd(d, q^{k+1}) for all d, q, k.
-/
theorem gcd_pow_dvd_gcd_pow_succ (d q k : ℕ) :
    Nat.gcd d (q ^ k) ∣ Nat.gcd d (q ^ (k + 1)) := by
  exact Nat.dvd_gcd ( Nat.gcd_dvd_left _ _ ) ( dvd_trans ( Nat.gcd_dvd_right _ _ ) ( pow_dvd_pow _ ( Nat.le_succ _ ) ) )

/-
**Theorem E (Moment Monotonicity)**: Prime-power moments are monotone
in k: M_{q,k} divides M_{q,k+1}. This reflects that higher-order torsion
subgroups contain all lower-order torsion elements.
-/
theorem primePowerMoment_mono {n : ℕ} (S : InvariantFactorData n) (q k : ℕ) :
    S.primePowerMoment q k ∣ S.primePowerMoment q (k + 1) := by
  convert Finset.prod_dvd_prod_of_dvd _ _ fun i _ => gcd_pow_dvd_gcd_pow_succ ( S.factors i ) q k using 1

/-! ## Theorem F — Profile monotonicity -/

/-
**Theorem F (Profile Monotonicity)**: The q-profile is monotone decreasing:
#{i : q^(j+1) ∣ dᵢ} ≤ #{i : q^j ∣ dᵢ}.
This holds because q^(j+1) ∣ d implies q^j ∣ d.
-/
theorem qProfile_mono {n : ℕ} (S : InvariantFactorData n) (q j : ℕ) :
    S.qProfileCount q (j + 1) ≤ S.qProfileCount q j := by
  convert Set.ncard_le_ncard ( show { i : Fin n | q ^ ( j + 1 ) ∣ S.factors i } ⊆ { i : Fin n | q ^ j ∣ S.factors i } from fun i hi => dvd_trans ( pow_dvd_pow q ( Nat.le_succ j ) ) hi ) using 1;
  · unfold InvariantFactorData.qProfileCount; simp +decide [ Set.ncard_eq_toFinset_card' ] ;
  · rw [ Set.ncard_eq_toFinset_card _ ] ; aesop

/-! ## Computational Examples

Verify the theory on concrete examples. -/

/-- Example: The cyclic group ℤ/6ℤ has invariant factors [6]. -/
def example_Z6 : InvariantFactorData 1 where
  factors := ![6]
  pos := by intro i; fin_cases i; norm_num

/-- Example: ℤ/2ℤ × ℤ/6ℤ has invariant factors [2, 6]. -/
def example_Z2xZ6 : InvariantFactorData 2 where
  factors := ![2, 6]
  pos := by intro i; fin_cases i <;> norm_num

/-- The exponent of ℤ/6ℤ is 6. -/
theorem example_Z6_exponent : example_Z6.exponent = 6 := by native_decide

/-- The exponent of ℤ/2ℤ × ℤ/6ℤ is 6 (= lcm(2,6)). -/
theorem example_Z2xZ6_exponent : example_Z2xZ6.exponent = 6 := by native_decide

/-- The 2-torsion of ℤ/2ℤ × ℤ/6ℤ is gcd(2,2) · gcd(6,2) = 2 · 2 = 4. -/
theorem example_Z2xZ6_moment_2_1 : example_Z2xZ6.primePowerMoment 2 1 = 4 := by native_decide

/-- The 3-torsion of ℤ/2ℤ × ℤ/6ℤ is gcd(2,3) · gcd(6,3) = 1 · 3 = 3. -/
theorem example_Z2xZ6_moment_3_1 : example_Z2xZ6.primePowerMoment 3 1 = 3 := by native_decide

/-- The 4-torsion of ℤ/2ℤ × ℤ/6ℤ is gcd(2,4) · gcd(6,4) = 2 · 2 = 4. -/
theorem example_Z2xZ6_moment_2_2 : example_Z2xZ6.primePowerMoment 2 2 = 4 := by native_decide

/-- The 2-profile at level 1 for ℤ/2ℤ × ℤ/6ℤ: both 2 and 6 are divisible by 2. -/
theorem example_Z2xZ6_qProfile_2_1 : example_Z2xZ6.qProfileCount 2 1 = 2 := by native_decide

/-- The 2-profile at level 2 for ℤ/2ℤ × ℤ/6ℤ: neither 2 nor 6 is divisible by 4. -/
theorem example_Z2xZ6_qProfile_2_2 : example_Z2xZ6.qProfileCount 2 2 = 0 := by native_decide

/-- The 3-profile at level 1 for ℤ/2ℤ × ℤ/6ℤ: only 6 is divisible by 3. -/
theorem example_Z2xZ6_qProfile_3_1 : example_Z2xZ6.qProfileCount 3 1 = 1 := by native_decide

/-! ## Cohen–Lenstra Connection

### Conjecture (CL-ER): Cohen–Lenstra for Erdős–Rényi Graphs

Fix a prime q and p ∈ (0,1). Let Gₙ ~ G(n,p). Then for every finite abelian
q-group A:
  lim_{n→∞} Pr(Jac(Gₙ)_(q) ≅ A) = μ_{CL,q}(A)

A weaker testable prediction using Theorem B:
  lim_{n→∞} 𝔼[M_{q,k}(Jac(Gₙ))] = 𝔼_{CL}[M_{q,k}]

The theorems proved here show that:
1. The exponent is determined by the largest prime-power invariant factor
   (Theorem A), making it a clean observable for testing.
2. The moments M_{q,k} are exact products of gcd values (Theorem B),
   making them efficiently computable for random graphs.
3. The moments determine the complete q-primary partition (Theorem C),
   so moment convergence implies distributional convergence.
-/