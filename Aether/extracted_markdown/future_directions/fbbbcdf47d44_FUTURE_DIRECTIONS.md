# Future Directions — Entry-Point Theory as a Functor on Strong Divisibility Sequences

## Synthesis

This cycle abstracted the Fibonacci entry-point (rank-of-apparition) theory into a
single reusable development parametrised by a **strong divisibility sequence**.
Working in the new file
`Catalog/Speculative/AutoResearch/StrongDivisibilityEntryPoint.lean`, we observed
that none of the structural theorems in the prior cycle's
`FibonacciEntryPointCharacterization.lean` actually touch the Fibonacci
recurrence — they consume only the strong divisibility identity
`gcd (s m) (s n) = s (gcd m n)` together with the normalisation `s 0 = 0`.

We therefore bundled a structure `StrongDivSeq` carrying exactly those two data,
and re-proved the *entire* package generically:

* `dvd_of_dvd` — the sequence is divisibility-monotone (`m ∣ n → s m ∣ s n`);
* `dvd_gcd_index` — the gcd backbone (`p ∣ s m → p ∣ s n → p ∣ s (gcd m n)`);
* `dvd_iff_entryPt_dvd` — the **entry-point characterization**
  `p ∣ s k ↔ entryPt s p ∣ k`, exhibiting the apparition index set as the
  principal ideal `(entryPt s p)` of `ℕ`;
* `indexSubmonoid` / `indexSubmonoid_eq_multiples` — the apparition set realised
  as a **principal additive submonoid** of `ℕ`;
* `entryPt_dvd_of_dvd` — **divisibility-monotonicity of the entry-point map**;
* `entryPt_one` — the normalisation `entryPt s 1 = 1`;
* `entryPt_mul_coprime` — the **lcm law**
  `entryPt s (a*b) = lcm (entryPt s a) (entryPt s b)` for coprime `a, b`.

The conceptual-unification payoff: the previous cycle's roughly ten Fibonacci
lemmas are now *corollaries* obtained by instantiating `s := fibSeq` (`Nat.fib`,
via `Nat.fib_gcd`). We provide the recovered statements `fib_dvd_iff_entryPt_dvd`
and `fib_entryPt_mul_coprime` to demonstrate the reduction, and a *second* model
`idSeq` (the identity sequence) with `entryPt_idSeq : entryPt idSeq p = p`,
certifying that the framework is genuinely sequence-agnostic rather than a
Fibonacci-flavoured restatement.

Read homotopically, `entryPt : StrongDivSeq → (ℕ → ℕ)` is a divisibility-poset
functor whose fibres are the primitive indices; the two models `fibSeq` and
`idSeq` are objects, and any morphism of strong divisibility sequences should
induce a comparison of their entry-point maps — the localization picture that the
next cycle can make precise.

## Results Summary

All results are `sorry`-free and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

| Theorem | Statement |
|---|---|
| `dvd_of_dvd` | `m ∣ n → s m ∣ s n` for any strong divisibility sequence |
| `dvd_gcd_index` | `p ∣ s m → p ∣ s n → p ∣ s (gcd m n)` |
| `dvd_iff_entryPt_dvd` | `p ∣ s k ↔ entryPt s p ∣ k` (generic characterization) |
| `setOf_dvd_eq_multiples` | `{k | p ∣ s k} = {k | entryPt s p ∣ k}` |
| `indexSubmonoid` (+ `_eq_multiples`) | apparition set as principal `AddSubmonoid ℕ` |
| `entryPt_dvd_of_dvd` | entry-point map is divisibility-monotone |
| `entryPt_one` | `entryPt s 1 = 1` |
| `entryPt_mul_coprime` | `entryPt s (a*b) = lcm (entryPt s a) (entryPt s b)`, coprime `a,b` |
| `fib_dvd_iff_entryPt_dvd`, `fib_entryPt_mul_coprime` | Fibonacci corollaries via `fibSeq` |
| `entryPt_idSeq` | `entryPt idSeq p = p` (identity model) |

## Bold, Falsifiable Research Directions

### 1. Pell and Lucas as `StrongDivSeq` instances
Instantiate `StrongDivSeq` with the Pell numbers `P_n` and the balanced Lucas
sequences `U_n(P,Q)` with `gcd(P,Q) = 1`, immediately inheriting the entire
entry-point package (characterization, submonoid, lcm law, monotonicity) for free.
**The key insight is** that `StrongDivSeq` isolates the *only* hypotheses the
theory needs — strong divisibility plus `s 0 = 0` — so each new instance reduces
to verifying a single `gcd` identity rather than re-deriving ten lemmas.
**Why now?** The generic file is proved this cycle; Mathlib already carries
`gcd`-divisibility lemmas for several Lucas-type sequences, so the remaining work
is one structure constructor per sequence. Falsifiable: a candidate sequence whose
`gcd` identity fails to typecheck against `StrongDivSeq.strong_gcd` is not an
instance, and any instance violating `entryPt_mul_coprime` would refute the
abstraction.

### 2. Functoriality under sequence morphisms
Define a morphism `f : s ⟶ t` of strong divisibility sequences as an index map
respecting apparition (e.g. `s k ∣ s' (g k)`), and prove that `entryPt` is a
contravariant/​covariant functor on the resulting category: morphisms induce
divisibility relations `entryPt t p ∣ entryPt s p` (or vice versa).
**The key insight is** that `dvd_iff_entryPt_dvd` already characterizes `entryPt`
purely by the principal-ideal structure of the apparition set, so a map of
apparition sets is exactly a map of principal ideals, i.e. a divisibility of
generators. **Why now?** The principal-submonoid description
`indexSubmonoid_eq_multiples` is proved this cycle and is precisely the object a
functor must act on. Falsifiable: exhibit a morphism inducing a generator
relation contradicting the predicted direction.

### 3. The prime-power reconstruction theorem (Finset-indexed lcm law)
Lift `entryPt_mul_coprime` by induction to the full factorization:
`entryPt s m = lcm_{p^e ‖ m} entryPt s (p^e)` for any `m` whose prime powers each
admit an entry point. **The key insight is** that distinct prime powers are
pairwise coprime, so the two-factor lcm law is the base case of a
`Nat.factorization` / `Finset.prod` induction with no new sequence-specific input.
**Why now?** `entryPt_mul_coprime` holds generically as of this cycle, and
Mathlib's `Nat.factorizationEquiv` / `Finsupp.prod` give a ready induction
skeleton; only a `Finset`-indexed lcm lemma is missing. Falsifiable by any `m`
(in any model) whose entry point differs from the lcm of its prime-power entry
points.

### 4. The Pisano / order connection at the abstract level
For a strong divisibility sequence equipped with a state recurrence, relate the
entry point `entryPt s m` to the period of `s mod m`: the index submonoid being
principal forces `entryPt s m` to divide the state period.
**The key insight is** that `indexSubmonoid_eq_multiples` already identifies
`entryPt s m` as the additive order of the *value* stream, while the period is the
order of the *state* stream, and the state-to-value projection forces divisibility
without re-deriving any recurrence. **Why now?** The submonoid description is the
exact structural fact needed; abstracting it away from Fibonacci is the natural
follow-up to this cycle. Falsifiable: a model with `entryPt s m ∤ period`.

### 5. Carmichael as eventual surjectivity of `entryPt` on primes
Recast the primitive-divisor question uniformly: a strong divisibility sequence
has the Carmichael property iff its prime-restricted entry-point map is eventually
surjective onto the admissible indices. **The key insight is** that the
entry-point characterization turns "does `s n` have a primitive prime divisor?"
into "is `n` in the image of `entryPt` on primes?", an image question about the
functor rather than a growth estimate on `s`. **Why now?** With the generic
characterization in hand, the hard analytic core (a new prime dividing `s n` but
no earlier `s k`) is isolated behind a clean surjectivity wrapper that
cyclotomic/Zsygmondy machinery can attack model-by-model. Falsifiable: an
admissible index with empty `entryPt`-preimage among primes for some model with
the Carmichael property.
