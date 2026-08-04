# Computational evidence

Target of the formalization: on a ring generated over `ℤ` by a root of unity `ζ`, the
"catalog map" `σ_p : ζ ↦ ζ^p` satisfies the Frobenius congruence

```
σ_p(x) ≡ x^p   (mod p)      for every x ∈ ℤ[ζ],
```

and, at a prime `Q` of `ℤ[ζ]` whose residue field has cardinality `p`, this congruence
characterizes `σ_p` as *the* arithmetic Frobenius at `Q`.

All computations below were run in exact integer arithmetic in the model ring
`ℤ[x]/(Φ_n(x)) ≅ ℤ[ζ_n]`, with `Φ_n` computed by exact division of `x^n − 1` by the
lower cyclotomic polynomials. (Script: throwaway Python, reproduced in the repository
history of this note; the mathematical claims are all *proved* in Lean, see
`Catalog/Pythagorean/NumberTheory/CyclotomicFrobenius.lean`, so the numerics below only
served to fix the correct hypotheses before formalizing.)

## 1. Small-case calculations

For `n = 1, …, 20` and each prime `p ∈ {2,3,5,7,11,13}` with `p ∤ n`, and for 20 random
elements `f ∈ ℤ[x]/(Φ_n)` with coefficients in `[-5,5]`:

```
random congruence checks: 1920      failures: 0
```

Every instance satisfied `f(x^p) ≡ f(x)^p (mod p, Φ_n)`.

## 2. Is `p ∤ n` needed for the congruence?

No. Repeating the test for the pairs with `p | n`:

```
checks with p | n: 220              failures: 0
```

This matched the shape of the Lean statement finally adopted:
`sub_pow_mem_span_of_mem_adjoin` requires only that `p` be prime and `σ ζ = ζ^p`; the
coprimality `p ∤ n` is needed only for the *converse* direction (recovering `σ ζ = ζ^p`
from the Frobenius property), where it appears as the hypothesis `(n : S) ∉ Q`.

## 3. Counterexample hunt: is primality of `p` needed?

Yes. Replacing the prime `p` by a composite `q ∈ {4,6,8,9,10}` (still with `q ∤ n`):

```
composite exponent: 52 of the tested (n,q) pairs produced an explicit failure
first failures: (n,q,f) = (1,4,-5), (1,6,2), (1,8,-1), (1,9,4), (1,10,-3)
```

e.g. for `n = 1` (so the ring is `ℤ`) and `q = 4`, `x = -5`: `σ_4(x) − x^4 = −5 − 625 = −630`
is not divisible by `4`. So the hypothesis `hp : p.Prime` in
`sub_pow_mem_span_of_mem_adjoin` is load-bearing, and the proof indeed uses it twice
(through Fermat's little theorem on `ℤ` and through `p ∣ (p.choose k)` for `0 < k < p`).

## 4. Table: degrees and the catalog map

| n | deg Φ_n = φ(n) | #(ZMod n)ˣ | primes p ≤ 13 with p ∤ n |
|---|---|---|---|
| 5 | 4 | 4 | 2,3,7,11,13 |
| 8 | 4 | 4 | 3,5,7,11,13 |
| 12 | 4 | 4 | 5,7,11,13 |
| 15 | 8 | 8 | 2,7,11,13 |
| 20 | 8 | 8 | 3,7,11,13 |

The equality of the middle two columns is Mathlib's `IsCyclotomicExtension.autEquivPow`
(irreducibility of `Φ_n` over `ℚ`), which we reuse rather than re-prove; the content added
here is that the resulting group isomorphism is *arithmetically* the Frobenius.

No OEIS sequence is relevant to this statement (the data are the values `φ(n)`, OEIS A000010).
