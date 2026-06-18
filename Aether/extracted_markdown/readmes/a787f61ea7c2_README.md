# The Freshman's Dream Theorem and Idempotent Algebra

A formally verified development in Lean 4 exploring the Frobenius endomorphism,
the Freshman's Dream theorem, and the Boolean algebra of idempotent elements.

## Lean Files

### `MultinomialDream.lean` — The Multinomial Freshman's Dream

**7 theorems, 0 sorries.**

| Theorem | Statement |
|---------|-----------|
| `Finset.sum_pow_char` | $(∑ f(i))^p = ∑ f(i)^p$ in characteristic $p$ |
| `Finset.sum_pow_char_pow` | $(∑ f(i))^{p^n} = ∑ f(i)^{p^n}$ |
| `frobenius_sum` | Frobenius distributes over finite sums |
| `frobenius_prod` | Frobenius distributes over finite products |
| `frobenius_iterate_comp` | $φ^m ∘ φ^n = φ^{m+n}$ |
| `ZMod.frobenius_eq_id` | Frobenius = identity on $\mathbb{F}_p$ (Fermat) |
| `ZMod.sum_pow_eq_sum` | $(∑ f(i))^p = ∑ f(i)$ in $\mathbb{F}_p$ |

### `IdempotentAlgebra.lean` — The Boolean Algebra of Idempotents

**10 theorems, 0 sorries.**

| Theorem | Statement |
|---------|-----------|
| `mul_one_sub_eq_zero` | $e(1-e) = 0$ for idempotent $e$ |
| `one_sub_mul_eq_zero` | $(1-e)e = 0$ |
| `eq_zero_or_one_of_noZeroDivisors` | Only trivial idempotents in domains |
| `pow_eq_self` | $e^n = e$ for $n ≥ 1$ |
| `frobenius_fixed` | Frobenius fixes idempotents |
| `add_sub_mul_idempotent` | $e + f - ef$ is idempotent (join) |
| `sub_mul_idempotent` | $e - ef$ is idempotent (relative complement) |
| `orthogonal_system` | $e, 1-e$ form orthogonal decomposition |
| `ZMod.isIdempotentElem_iff` | Idempotents in $\mathbb{F}_p$ are $\{0,1\}$ |
| `Prod.isIdempotentElem_iff` | Product idempotents are componentwise |

## Building

```bash
lake build Algebra.FreshmanDream.MultinomialDream
lake build Algebra.FreshmanDream.IdempotentAlgebra
```

## Python Demos

See the `demos/` directory for interactive demonstrations:
- `freshman_dream_demo.py` — Visualizations of Pascal's triangle mod p, Fermat's theorem
- `applications_demo.py` — Cyclic codes, ring decomposition, polynomial testing
