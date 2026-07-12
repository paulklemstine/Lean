# Computational Evidence — Universal Mathematics & Alien Arithmetic

This note records the small-case checks that motivated and sanity-checked the
formal statements in `UniversalMathematics.lean` and `AlienArithmetic.lean`.
Everything asserted here is also *proved* in Lean (0 sorries), so the evidence
below is only supporting intuition.

## 1. Independence of commutativity (the "parallel postulate" analogue)

The claim `commutativity_not_universal` rests on exhibiting one abelian and one
non-abelian group. The witnesses are finite, so the relevant facts are decidable
and were checked by `decide` inside Lean:

| group        | order | commutative? |
|--------------|-------|--------------|
| `ℤ/2ℤ`       | 2     | yes          |
| `S₃` (`Perm (Fin 3)`) | 6 | **no** — e.g. `(0 1)·(1 2) ≠ (1 2)·(0 1)` |

Because both a model and a countermodel exist, the commutativity axiom is
independent of the group axioms — exactly the structure of "the parallel
postulate is independent of the remaining axioms of geometry" (Euclidean vs.
hyperbolic models).

## 2. Would aliens discover primes? Small-case factorizations

First multiplicatively indecomposable numbers (`prime_iff_indecomposable`):

```
2, 3, 5, 7, 11, 13, 17, 19, 23, 29, ...   (OEIS A000040, the primes)
```

The "canonical prime finder" `minFac` (smallest factor > 1) on the first
composites:

```
minFac 4 = 2,  minFac 6 = 2,  minFac 9 = 3,  minFac 15 = 3,  minFac 25 = 5,
minFac 49 = 7,  minFac 77 = 7,  minFac 91 = 7
```

Each output is prime, matching `minFac_is_prime`.

Unique factorization (`factorization_exists` / `factorization_unique`):

```
12  = 2·2·3        60  = 2·2·3·5
360 = 2·2·2·3·3·5  1001 = 7·11·13
```

Any reordering of these lists is the *only* freedom — the multiset of primes is
an invariant, which is the Fundamental Theorem of Arithmetic.

## 3. Counterexample hunt for the metatheorems

* `universal_iff_entails` (universal = provable over a consistent base): searched
  for a sentence universal but not entailed — impossible, since a theory is a
  consistent extension of itself. No counterexample; the equivalence is proved.
* `universal_or_iff_decided`: the reduction "φ or ¬φ universal ⇔ theory decides
  φ" is a direct rewrite of `universal_iff_entails` applied to φ and ¬φ; no
  counterexample exists.
* Riemann Hypothesis universality: **deliberately left as a conjecture.** On this
  semantics it is equivalent to "arithmetic decides RH", which is open. No
  computational check can settle it; hence it appears only in
  `FUTURE_DIRECTIONS.md`, never as a Lean theorem.

## OEIS references

* Primes: **A000040** — 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, ...
* Orders of the two group witnesses: 2 and 6.
