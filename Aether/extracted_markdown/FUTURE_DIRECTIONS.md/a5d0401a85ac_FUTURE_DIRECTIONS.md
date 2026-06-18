# Future Directions: Formal Additive Prime Decomposition Theory

## Overview

Building on the formally verified parity census law, symmetry transfer formula, multiplicity lower bounds, and weak Chen decompositions, we identify five falsifiable hypotheses for the next research cycle.

---

## Hypothesis 1: Mod-m Parity Census Generalization

**Conjecture:** For any prime *p* and any positive integer *m*, the count of *p*s in a prime decomposition satisfies a mod-*m* constraint determined by the target sum, the arity, and the residues of the other primes modulo *m*.

**Precise statement:** For any list *L* of primes and any prime *q*,
```
count_q(L) ≡ f(sum(L), |L|, q) (mod q-1)
```
where f is a specific function depending on the residue of `sum(L)` modulo q and the length.

**Lean-facing sketch:**
```lean
theorem count_prime_mod_residue (L : List ℕ) (q : ℕ) (hq : Nat.Prime q)
    (hprime : ∀ x ∈ L, Nat.Prime x) :
    (L.count q) % (q - 1) = <explicit_formula> % (q - 1)
```

**Test:** Verify computationally for q = 3, 5, 7 and all prime decompositions of n up to 200. Check whether the formula holds universally.

**Falsifier:** A single prime decomposition where the count of q violates the predicted residue class.

**Impact:** Would establish a family of conservation laws indexed by primes, with the parity census as the q=2 base case. Opens connections to cyclotomic theory and character sums.

---

## Hypothesis 2: Multiplicity Threshold Function

**Conjecture:** Define N(c) as the smallest integer such that every even n ≥ N(c) has at least c ordered Goldbach representations. The function N(c) is well-defined for all c ≥ 1 and satisfies N(c) = O(c² log²c).

**Precise statement:**
- N(1) = 4 (every even n ≥ 4 has ≥ 1 representation, by Goldbach)
- N(2) = 8 (proved in this paper for n ≤ 500)
- N(3) ≤ 14 (conjectured)
- N(4) ≤ 20 (conjectured)

**Lean-facing sketch:**
```lean
theorem goldbach_multiplicity_ge_three :
    ∀ n ∈ Finset.Icc 14 2000, Even n → 3 ≤ (goldbachWits n).card

theorem goldbach_multiplicity_ge_four :
    ∀ n ∈ Finset.Icc 20 2000, Even n → 4 ≤ (goldbachWits n).card
```

**Test:** Compute N(c) for c = 1, ..., 20 by exhaustive search up to n = 10000. Fit the growth rate and test against the O(c² log²c) prediction.

**Falsifier:** Finding that N(c) grows faster than c² log²c, or that N(c) is undefined for some c (i.e., the minimum count dips below c infinitely often).

**Impact:** Would provide a quantitative "phase diagram" for Goldbach multiplicities, connecting finite combinatorics to the Hardy-Littlewood asymptotic prediction.

---

## Hypothesis 3: Diagonal Density Zero Conjecture

**Conjecture:** Among even numbers n ≥ 4, the density of n with a diagonal Goldbach representation (n = p + p for some prime p) is exactly the density of primes in [2, n/2], which tends to zero.

**Precise statement:** 
```
lim_{N→∞} |{n ≤ N : n even, ∃ p prime, n = 2p}| / |{n ≤ N : n even}| = 0
```

Equivalently, the proportion of even numbers with |Diag(n)| = 1 tends to zero, so for "most" even numbers, the symmetry transfer law simplifies to |Ord(n)| = 2·|Unord(n)|.

**Lean-facing sketch:**
```lean
theorem diagonal_proportion_bounded (N : ℕ) :
    (Finset.Icc 2 N |>.filter (fun n => Even n ∧ 
      (goldbachWitnessesDiag (2 * n)).card = 1)).card ≤ 
    (Finset.Icc 2 N |>.filter Nat.Prime).card
```

**Test:** Compute the diagonal proportion for N = 100, 1000, 10000, 100000 and verify monotonic decrease.

**Falsifier:** The proportion stabilizing at a positive constant.

**Impact:** Would formalize the sense in which "generic" Goldbach decompositions have exact 2:1 ordered-to-unordered ratio, with deviations only at prime half-points.

---

## Hypothesis 4: Semiprime-Enhanced Multiplicity

**Conjecture:** The number of weak Chen decompositions of even n grows at least linearly in n, even though the number of Goldbach decompositions grows only as n/ln²(n).

**Precise statement:** There exists a constant C > 0 such that for all even n ≥ 4,
```
|WeakChenWitnesses(n)| ≥ C · n / ln(n)
```

**Lean-facing sketch:**
```lean
def weakChenWitnesses (n : ℕ) : Finset (ℕ × ℕ) :=
  (Finset.range (n+1) ×ˢ Finset.range (n+1)).filter
    (fun ps => Nat.Prime ps.1 ∧ (Nat.Prime ps.2 ∨ Semiprime ps.2) ∧ ps.1 + ps.2 = n)

-- Bounded version:
theorem weak_chen_multiplicity_lower_bound :
    ∀ n ∈ Finset.Icc 10 1000, Even n → 
      n / 10 ≤ (weakChenWitnesses n).card
```

**Test:** Compute |WeakChenWitnesses(n)| / (n / ln(n)) for even n up to 10000. Check if the ratio stays bounded below by a positive constant.

**Falsifier:** The ratio tending to zero, indicating sub-linear growth.

**Impact:** Would quantify the advantage of the semiprime relaxation layer, showing that almost-prime decompositions are not just slightly more abundant but fundamentally denser than exact-prime decompositions.

---

## Hypothesis 5: Generating Function Coefficient Identity

**Conjecture:** Define the prime polynomial P_N(x) = Σ_{p prime, p ≤ N} x^p. Then for k ≥ 1 and n ≤ N, the coefficient of x^n in P_N(x)^k equals the number of ordered k-tuples of primes at most N summing to n.

**Precise statement:**
```
[x^n] P_N(x)^k = |{(p₁,...,pₖ) : all pᵢ prime, all pᵢ ≤ N, Σpᵢ = n}|
```

**Lean-facing sketch:**
```lean
def primePoly (N : ℕ) : Polynomial ℕ :=
  ∑ p ∈ (Finset.range (N+1)).filter Nat.Prime, Polynomial.X ^ p

theorem coeff_prime_poly_pow (N k n : ℕ) (hn : n ≤ N) :
    (primePoly N ^ k).coeff n = 
    ((Finset.range (N+1) ^ k).filter (fun t => 
      (∀ i, Nat.Prime (t i)) ∧ ∑ i, t i = n)).card
```

**Test:** Verify computationally for N = 50, k = 1, 2, 3, and all n ≤ N by comparing polynomial coefficient extraction with direct tuple enumeration.

**Falsifier:** A mismatch between the polynomial coefficient and the tuple count for any (N, k, n).

**Impact:** Would establish a formal bridge between combinatorial counting of prime decompositions and algebraic coefficient extraction, opening the door to circle-method formalization. This is the foundational identity that connects additive prime theory to generating function theory.

---

## Priority Ordering

1. **Hypothesis 2** (Multiplicity Thresholds) — directly extends our proved multiplicity lower bound with concrete computational targets.
2. **Hypothesis 1** (Mod-m Census) — extends the parity census law, our strongest structural result, to a richer family.
3. **Hypothesis 5** (Generating Function) — foundational algebraic identity, likely provable by induction on k.
4. **Hypothesis 3** (Diagonal Density) — connects to prime number theorem; may require Mathlib PNT infrastructure.
5. **Hypothesis 4** (Semiprime Multiplicity) — most ambitious; likely requires analytic estimates.

Each hypothesis is designed to be falsifiable by concrete computation and to drive the next cycle of formal proof development.
