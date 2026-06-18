# Future Directions: Korselt's Criterion and Carmichael Numbers in Lean 4

## Synthesis

This cycle installed the structural backbone of **Carmichael number theory** — a topic that
Mathlib's own `Mathlib/NumberTheory/FermatPsp.lean` explicitly flags as *"not yet defined"*.
The new file `Catalog/Novelty/KorseltCarmichael.lean` formalizes the *sufficient half* of
**Korselt's criterion** through the predicate `IsKorselt n` (squarefree, composite, `> 1`, and
`(p - 1) ∣ (n - 1)` for every prime `p ∣ n`) and proves that any such number is a genuine
Carmichael number: a Fermat pseudoprime to **every** coprime base.

The proof is deliberately first-principles and factored into two reusable mechanisms:

1. **Local mechanism (`pow_eq_self_zmod`)**: in each residue field `ZMod p`, the identity
   `x ^ n = x` holds for all `x` precisely because `(p-1) ∣ (n-1)` collapses the unit-group
   exponent via `ZMod.pow_card_sub_one_eq_one`.
2. **Global recombination (`dvd_pow_sub_self`)**: squarefreeness expresses `n` as a product of
   *pairwise coprime* primes, so the local divisibilities glue back together through
   `Finset.prod_dvd_of_coprime`.

These two lemmas are of independent interest and immediately yield three structural theorems —
`odd`, `not_eq_mul_two_primes`, and `three_le_card_primeFactors` (every Carmichael number is odd,
squarefree, and has at least three distinct prime factors) — plus the verified canonical instance
`561 = 3·11·17`. The headline `fermatPsp_of_coprime` is a genuine cross-domain bridge: it connects
finite-field exponentiation to Mathlib's existing `Nat.FermatPsp` API, closing the gap that
Mathlib's documentation names out loud.

## Results Summary

| Theorem | Statement |
|---|---|
| `pow_eq_self_zmod` | In `ZMod p`, `(p-1) ∣ (n-1)` and `n ≥ 1` give `x^n = x` for all `x`. |
| `prime_dvd_pow_sub_self` | For a prime `p` with `(p-1) ∣ (n-1)`, `(p:ℤ) ∣ a^n - a`. |
| `dvd_pow_sub_self` | Squarefree + Korselt divisibility ⟹ `(n:ℤ) ∣ a^n - a` for **all** `a`. |
| `fermatPsp_of_coprime` | A Korselt number is `Nat.FermatPsp n b` for every coprime base `b ≥ 1`. |
| `odd` | Every Korselt number is odd. |
| `not_eq_mul_two_primes` | A Korselt number is never a product of two distinct primes. |
| `three_le_card_primeFactors` | Every Korselt number has `≥ 3` distinct prime factors. |
| `korselt_561` / `fermatPsp_561` | `561` is Korselt, hence the smallest Carmichael number. |

All main results carry `sorry = 0` and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## Bold, Falsifiable Research Directions

### 1. The converse: Korselt's criterion is an *iff*

Conjecture: if a composite `n` divides `a^(n-1) - 1` for every `a` coprime to `n` (equivalently,
`Nat.FermatPsp n b` for all coprime `b`), then `n` is squarefree and `(p-1) ∣ (n-1)` for every
prime `p ∣ n`. Together with `fermatPsp_of_coprime` this would give the full biconditional
`IsKorselt n ↔ IsCarmichael n`.
The key insight is that the *necessity* direction is forced by a single well-chosen base: picking
`a` to be a primitive root modulo `p` (a generator of `(ZMod p)ˣ`) makes the order `p-1` divide the
exponent `n-1`, and choosing `a` with `p² ∣ a^? ` style obstructions rules out repeated prime
factors. Why now? Mathlib already has the cyclicity of `(ZMod p)ˣ` (`ZMod.instIsCyclic` /
`ZMod.exists_orderOf_eq_prime_sub_one`-style results) and `IsPrimitiveRoot` machinery, so the
generator argument can be assembled from existing parts rather than built from scratch.

### 2. Chernick's three-prime family generates Carmichael numbers

Conjecture: for `k ≥ 1`, if `6k+1`, `12k+1`, and `18k+1` are all prime, then
`n = (6k+1)(12k+1)(18k+1)` satisfies `IsKorselt n` (hence is Carmichael). The `k=1` case is
`1729 = 7·13·19`.
The key insight is that `n - 1` is divisible by each of `6k`, `12k`, `18k` *because of the shared
arithmetic-progression structure*: expanding the product shows `n ≡ 1` modulo each `pᵢ - 1`,
which is exactly the Korselt condition, reducing an infinitude-flavoured statement to a finite
polynomial identity checkable by `ring`/`omega`. Why now? `dvd_pow_sub_self` already converts the
Korselt condition into the Carmichael property, so this direction only needs the (purely algebraic)
divisibility bookkeeping — no new analytic input — and would turn the catalog's single instance
`561` into an infinite conditional family.

### 3. The smallest prime factor is small

Conjecture: every Carmichael number `n` has a prime factor `p` with `p < n^{1/2}` (a weak,
provable shadow of the classical `p < n^{1/3}` bound), strengthening `three_le_card_primeFactors`.
The key insight is that with `≥ 3` pairwise-distinct prime factors whose product is `n`, the
smallest must lie below the geometric mean `n^{1/3} ≤ n^{1/2}`; the `≥ 3` count we just proved is
exactly the lever that makes the pigeonhole bound bite. Why now? We have
`three_le_card_primeFactors` and `Nat.prod_primeFactors_of_squarefree` in hand, so the bound is a
direct consequence of a product-of-three-or-more decomposition plus monotonicity, with no need for
the deep sieve theory the sharp `n^{1/3}` bound requires.

### 4. A Knödel-number generalization

Conjecture: fix `k ≥ 1` and define `IsKnodel k n` to mean `n` composite with `n - k ` divisible by
`p - 1`-style data so that `a^(n-k) ≡ 1 (mod n)` for all `a` coprime to `n` with `gcd(a,n)=1`; then
the same squarefree-plus-divisibility criterion characterizes membership, and `IsKorselt = IsKnodel 1`.
The key insight is that `pow_eq_self_zmod` never used `k = 1` essentially — it only used that the
exponent is congruent to `1` modulo each `p-1` — so the entire local/global machinery generalizes
verbatim once the divisibility hypothesis is reparametrized. Why now? The two engine lemmas are
already parametric in `n`; lifting them to a `k`-shifted exponent is a refactor, not a reproof, and
opens a whole family (Knödel numbers `Kₖ`) absent from Mathlib.

### 5. Carmichael numbers are not perfect powers and not prime powers

Conjecture: no Carmichael number is of the form `p^e` with `e ≥ 2`; more strongly, every Carmichael
number is squarefree (already isolated here as a hypothesis of `IsKorselt`) and therefore radical-equal
to itself, so `Nat.factorization n p ≤ 1` for all `p`.
The key insight is that squarefreeness is not an extra assumption but a *forced consequence* of the
universal Fermat condition: a repeated prime factor `p²` makes the multiplicative group modulo `p²`
non-cyclic-enough to break `a^(n-1) ≡ 1` for a suitable lift of a primitive root mod `p`. Why now?
Establishing this turns the squarefree clause of `IsKorselt` from an input into a theorem, tightening
the bridge of Direction 1 and giving a clean, self-contained `squarefree_of_carmichael` lemma that
reuses the `ZMod`/unit-group API already exercised in `pow_eq_self_zmod`.
