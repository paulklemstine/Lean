# Future Directions: Certified Computational Conjecture Validation

## Overview

This document outlines five specific research directions opened by the bounded divisor search formalization. Each direction includes exact theorem statements, proof strategies, and cross-domain significance.

---

## Direction 1: Abstract Bounded-Witness Schema

### Goal
Formalize a general typeclass or theorem pattern capturing the idea that a global predicate on a type is equivalent to the existence of a witness in a bounded finite set.

### Proposed Formalization

```lean
/-- A bounded witness principle: a predicate P on elements of type α is equivalent
    to the existence of a witness in a finite set S. -/
structure BoundedWitnessPrinciple (α : Type*) where
  P : α → Prop
  S : α → Finset α
  witness_type : α → Type*
  complete : ∀ x, P x → ∃ w ∈ S x, witness_type w
  sound : ∀ x, (∃ w ∈ S x, witness_type w) → P x
```

### Instances

1. **Compositeness**: `P N = ¬ Nat.Prime N`, `S N = Finset.Icc 2 (Nat.sqrt N)`, `witness_type d = d ∣ N`
2. **B-smooth detection**: `P N = (∀ p, Nat.Prime p → p ∣ N → p ≤ B)`, with witness set `Finset.Icc 2 B`
3. **Polynomial root bounding**: `P f = (∃ r, f.eval r = 0)`, with `S f` a finite set determined by degree and coefficients

### Proof Strategy
Instantiate the compositeness case using `composite_detection_complete_on_Icc`. For other instances, develop analogous bounded search theorems.

### Cross-Domain Significance
This captures the shared structure between arithmetic search, information-theoretic feasibility, and algebraic dimension bounds in a single reusable framework.

---

## Direction 2: Least-Witness Correctness and Primality

### Goal
Prove that the least divisor of N found by bounded search is itself prime, giving a stronger structural guarantee than mere divisibility.

### Proposed Theorem

```lean
theorem least_divisor_is_prime
    (N : ℕ) (hN : 2 ≤ N) :
    Nat.Prime (Nat.minFac N) ∨ N = 1 := by
  ...

theorem minFac_le_sqrt_of_composite
    (N : ℕ) (hN : 2 ≤ N) (hcomp : ¬ Nat.Prime N) :
    Nat.minFac N ≤ Nat.sqrt N := by
  ...
```

### Proof Strategy
`Nat.minFac_prime` in Mathlib already establishes that `minFac N` is prime for N ≥ 2. The bound `minFac N ≤ √N` follows from `exists_small_factor_of_composite` and the minimality of `minFac`.

### Cross-Domain Significance
This upgrades the bounded search from "find any witness" to "find the canonical minimal witness," analogous to finding the tightest feasible point in an optimization problem.

---

## Direction 3: Certified Complexity Upper Bound

### Goal
Formalize that trial division up to √N performs at most √N - 1 divisibility tests, giving an exact resource bound for compositeness detection.

### Proposed Theorem

```lean
theorem trial_division_test_count
    (N : ℕ) (hN : 2 ≤ N) :
    (Finset.Icc 2 (Nat.sqrt N)).card = Nat.sqrt N - 1 := by
  ...

theorem compositeness_decidable_in_sqrt_steps
    (N : ℕ) (hN : 2 ≤ N) :
    ∃ (f : Fin (Nat.sqrt N - 1) → Bool),
      (¬ Nat.Prime N ↔ ∃ i, f i = true) := by
  ...
```

### Proof Strategy
The cardinality claim is a direct computation on `Finset.Icc`. The decidability claim constructs the function `f i = ((i + 2) ∣ N)` and uses `composite_detection_complete_on_Icc`.

### Cross-Domain Significance
This connects arithmetic proof to resource-bounded verification, a key concept in computational complexity. It formalizes the intuition that "checking primality costs O(√N) operations" as a theorem about function existence, not just algorithm design.

---

## Direction 4: Bridge to Finite Feasibility in Information Theory

### Goal
Generalize from divisor search to a common framework with information-theoretic bounded feasibility, showing that both are instances of a "compact witness set" principle.

### Proposed Theorem

```lean
/-- A finite feasibility principle: if a predicate holds, witnesses exist in a 
    bounded finite set, and the set size is controlled by a parameter. -/
theorem finite_feasibility_arithmetic
    (N : ℕ) (hN : 2 ≤ N) :
    (¬ Nat.Prime N) → 
    ∃ S : Finset ℕ, S.card ≤ Nat.sqrt N ∧ ∃ d ∈ S, d ∣ N := by
  ...

/-- The information-theoretic analogue: if a rate-distortion pair is achievable,
    the achieving channels lie in a bounded set. -/
-- (Already exists as feasibleChannelSet_bounded in the catalog)
```

### Proof Strategy
The arithmetic version follows from `composite_detection_complete_on_Icc` by taking `S = Finset.Icc 2 (Nat.sqrt N)`. The bridge theorem would state both as instances of a common pattern, parameterized by:
- A universe type (ℕ for arithmetic, channel space for info theory)
- A predicate (compositeness, achievability)
- A witness relation (divisibility, distortion constraint)
- A bounding function (√N, a function of rate/distortion)

### Cross-Domain Significance
This would be the first formal theorem explicitly unifying arithmetic search and information-theoretic feasibility under a common bounded-witness framework.

---

## Direction 5: Recurrence-Search Analogue (Fibonacci/GCD)

### Goal
Develop a bounded-search analogue for GCD-recursive structure in Fibonacci numbers, where computationally observed divisibility patterns are reduced to certified bounded witnesses.

### Proposed Theorems

```lean
/-- The period of Fibonacci numbers modulo m (Pisano period) is bounded. -/
theorem pisano_period_exists (m : ℕ) (hm : 1 ≤ m) :
    ∃ π, 0 < π ∧ π ≤ 6 * m ∧ ∀ n, Nat.fib (n + π) % m = Nat.fib n % m := by
  ...

/-- Fibonacci divisibility search: if m | fib(n), then m | fib(k) for some k ≤ 6m. -/
theorem fib_divisibility_bounded_search
    (m n : ℕ) (hm : 2 ≤ m) (hdvd : m ∣ Nat.fib n) :
    ∃ k, 0 < k ∧ k ≤ 6 * m ∧ m ∣ Nat.fib k := by
  ...
```

### Proof Strategy
The Pisano period π(m) satisfies π(m) ≤ 6m (a known bound). Once this is established, the zero-appearance property of Fibonacci numbers modulo m gives a bounded search: the first k with m | fib(k) satisfies k ≤ π(m) ≤ 6m.

This requires:
1. Existence of the Pisano period (periodicity of fib mod m)
2. The bound π(m) ≤ 6m
3. The zero-appearance property: fib(0) = 0 ≡ 0 mod m, and periodicity ensures recurrence

### Cross-Domain Significance
This extends the bounded-witness paradigm from multiplicative structure (divisors) to additive-recursive structure (Fibonacci), showing the paradigm's generality. It also connects to the catalog's `fib_gcd_identity` and `fib_dvd_chain`, building a unified arithmetic search theory.

---

## Team Directive

Each direction is designed to be independently pursuable by a research team:

1. **Direction 1** (Abstract Schema): Requires expertise in Lean typeclass design and abstract algebra formalization. Start by implementing the `BoundedWitnessPrinciple` structure and instantiating for compositeness.

2. **Direction 2** (Least-Witness): Requires familiarity with Mathlib's `Nat.minFac` API. Straightforward given existing infrastructure.

3. **Direction 3** (Complexity): Requires connecting `Finset.card` computations to algorithmic resource bounds. Good entry point for CS-oriented formalization.

4. **Direction 4** (Info-Theory Bridge): Requires understanding of both arithmetic and information-theoretic formalization. Most ambitious; start with the arithmetic side and connect to `feasibleChannelSet_bounded`.

5. **Direction 5** (Fibonacci): Requires developing Pisano period theory in Lean. The catalog already has `fib_gcd_identity` and related results to build on.

### Iteration Protocol
- Hypothesize → Compute (Python) → Formalize (Lean) → Verify → Generalize
- Each cycle should produce at least one machine-verified theorem
- Cross-domain connections should be made explicit in theorem comments
- Failed conjectures should be documented with counterexamples

### Success Criteria
- Zero `sorry` in final Lean code
- At least one cross-domain bridge theorem per direction
- Python validation covering ≥ 10⁵ test cases per conjecture
- FUTURE_DIRECTIONS.md updated with results after each cycle
