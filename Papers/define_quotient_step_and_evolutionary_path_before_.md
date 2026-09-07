# Computational Evidence — Quotient Steps and Evolutionary Paths

All computations below were run inside the project's Lean 4 / Mathlib toolchain
(`#eval`), on the concrete instance of the theory that lives in
`Catalog/Shared/EvolutionaryPathArithmetic.lean`: the *multiplicative quotient
system* on `ℕ`, whose quotient steps are `n --p--> n/p` for a prime `p ∣ n`.

They were used **before** the formal proofs, to decide which conjectures were
worth attacking and which needed a different definition.

## 1. Small-case table

For each `n`, we record `Ω(n)` (the number of prime factors with multiplicity =
the *height* of `n`), the number of complete evolutionary paths from `n` down to
`1`, and the number of divisors of `n` (= the number of stages reachable from
`n`).

```
 n : Ω(n)  #complete paths  #reachable stages
 2 :  1        1                2
 3 :  1        1                2
 4 :  2        1                3
 5 :  1        1                2
 6 :  2        2                4
 7 :  1        1                2
 8 :  3        1                4
 9 :  2        1                3
10 :  2        2                4
11 :  1        1                2
12 :  3        3                6
13 :  1        1                2
14 :  2        2                4
15 :  2        2                4
16 :  4        1                5
17 :  1        1                2
18 :  3        3                6
19 :  1        1                2
20 :  3        3                6
21 :  2        2                4
22 :  2        2                4
23 :  1        1                2
24 :  4        4                8
25 :  2        1                3
26 :  2        2                4
27 :  3        1                4
28 :  3        3                6
29 :  1        1                2
30 :  3        6                8
```

Observations that drove the formalisation:

* the **length** of a complete path is always `Ω(n)`, never anything else —
  this is the Jordan–Hölder statement, now proved abstractly as
  `EvolPath.jordan_holder` / `natHeight_eq_card_factors`;
* the **number** of complete paths matches the multinomial coefficient
  `Ω(n)! / ∏ aᵢ!` of the exponent vector (e.g. `30 = 2·3·5` gives `3! = 6`,
  `24 = 2³·3` gives `4!/3! = 4`), suggesting that *every* ordering of the prime
  labels is realisable — now proved as `nat_complete_path_iff`;
* the **number of reachable stages** equals the number of sub-multisets of the
  factorisation multiset, suggesting the classification theorem — now proved as
  `nat_divisor_classification`.

## 2. Bulk checks (all returned `true`)

| Check | Range | Result |
|---|---|---|
| `#complete paths n = Ω(n)! / ∏ aᵢ!` | `2 ≤ n ≤ 60` | true |
| `∏ (aᵢ+1) = #divisors n` (sub-multisets ↔ reachable stages) | `1 ≤ n < 200` | true |

Both are *evidence*, not proof; the corresponding theorems that are actually
proved in Lean are `nat_complete_path_iff` (paths ↔ orderings, which is the
bijective content behind the multinomial count) and `nat_divisor_classification`
(reachable stages ↔ sub-multisets).  The purely numerical multinomial *count*
itself is left as a stated future direction, since it needs a `Fintype`
structure on path space.

## 3. Counterexample hunt

The universal claims were attacked before being formalised.

* *"Two complete chains always have the same length."*  **False** without the
  exchange axiom.  Smallest counterexample found by hand-enumeration over
  3-element step relations: `0 → 1 → 2` together with the shortcut `0 → 2`;
  chains of lengths `2` and `1` both end at the terminal object `2`.
  Formalised as `exchange_is_necessary`.
* *"`decomp` separates reachable stages."*  **False** in general.  Smallest
  counterexample: the diamond `3 → {1,2} → 0` with a single label; the two
  middle stages are distinct but have equal invariant `{()}`.  Formalised as
  `diamond_decomp_not_injective`; the guarded version (separated systems) is
  `decomp_injOn_reach`.
* *"Every label of `decomp x` is available as an immediate step."*  **False**.
  Counterexample: the two-step chain `2 --false--> 1 --true--> 0`, where
  `true ∈ decomp 2` but no `true`-step leaves `2`.  Formalised as
  `chain_not_saturated`; this is exactly why the classification theorem needs
  the extra `Saturated` hypothesis.

## 4. OEIS

The two sequences appearing in the table are classical and were used only as
sanity checks: `Ω(n)` (number of prime factors with multiplicity) and `d(n)`
(number of divisors).  The path-count column is the multinomial of the exponent
vector, i.e. the number of ordered factorisations of `n` into primes.  No new
sequence was needed for the results proved here.

## 5. Lab notes

* First formulation of the exchange axiom used *equal* labels on the two sides
  of the diamond; it made the Jordan–Hölder induction fail on `12 = 2·6 = 3·4`.
  Swapping the labels (`step y₁ l₂ z ∧ step y₂ l₁ z`) is what makes the
  arithmetic instance true, and is also what the group-theoretic butterfly
  lemma provides.  *Needed a different definition*, not a harder proof.
* `label_unique` was initially forgotten.  The proof of the diamond case of
  Jordan–Hölder went through, but the "same successor" case did not: two steps
  to the same target with different labels break multiset invariance.  This is
  recorded as `label_unique_is_necessary`.
* Working with `ℕ` (rather than `ℕ+`) and demanding `0 < m` in a step keeps `0`
  as an isolated terminal object and avoids all subtype friction; the rank
  `Ω(n)` then decreases strictly on every step.

## 6. Path-integral cycle (`EvolutionaryPathIntegral.lean`)

Before formalising the characterisation of arithmetic functions as path
integrals, the two ingredients were checked computationally with `#eval`
(Lean 4 / Mathlib, same toolchain as the proofs):

```lean
-- complete additivity of the height Ω on the whole 40 × 40 multiplication table
#eval decide (∀ m ∈ List.range' 1 40, ∀ n ∈ List.range' 1 40,
  (Nat.primeFactorsList (m*n)).length
    = (Nat.primeFactorsList m).length + (Nat.primeFactorsList n).length)
-- ⇒ true

-- the label counts of the arithmetic system are the p-adic valuations
#eval (List.range' 1 60).all (fun n => [2,3,5,7].all (fun p =>
  (Nat.primeFactorsList n).count p == n.factorization p))
-- ⇒ true
```

Counterexample hunt for the converse direction: the number of *distinct* prime
factors `ω` is **not** a path action, and the smallest witness is `n = 4`:

```lean
#eval ((4:ℕ).primeFactors.card, ((2:ℕ).primeFactors.card + (2:ℕ).primeFactors.card))
-- ⇒ (1, 2)
```

so `ω(2·2) ≠ ω(2) + ω(2)`; this is exactly the failure of complete additivity
that the characterisation predicts, since a path action must count *every*
label of the path, with multiplicity.  Both directions of
`natCompletelyAdditive_iff_pathAction` and
`natCompletelyMultiplicative_iff_pathWeight` are now proved, sorry-free.
