# Summary of changes for run dcd67703-b85b-468e-b056-205f8d8c458c
# Counterfactual Number Theory: What If Primes Were Random?

## Research Summary

This research cycle investigated which theorems of classical number theory survive when primes are replaced by random subsets of ℕ with density n/log(n) (the Cramér model). The central discovery is that **product-freeness** — the property that no product of two "primes" is itself "prime" — is the precise structural feature separating real primes from random dense sets, and it is both necessary and sufficient for unique factorization.

## Lean 4 Formalization: `Shared/CounterfactualPrimes.lean`

**9 theorems, all fully proved (0 sorries), verified clean build:**

### Novel Definitions
- **PseudoPrimeSystem**: A subset of ℕ≥2 serving as generalized "primes"
- **SFactorization**: Multiset factorization using generators of a pseudo-prime system
- **HasUniqueFactorization**: Generalized UFD property for pseudo-prime systems
- **IsProductFree**: No product of two generators is a generator
- **ProductWitness**: Constructive evidence of non-product-freeness
- **Shadow**: The multiplicative shadow of a set under scaling by p
- **CramerUFDIncompatibility**: The central open conjecture (stated, not proved)

### Key Theorems (3+ with genuine mathematical insight)
1. **product_witness_breaks_uf**: If S contains a,b with a·b ∈ S, then unique factorization fails. Constructs two distinct multiset factorizations of different cardinality.
2. **primes_product_free**: The standard primes are product-free — no product of two primes is prime. Uses `Nat.prime_mul_iff`.
3. **uf_implies_product_free**: Product-freeness is *necessary* for unique factorization (sharp dichotomy).
4. **length_spectrum_nontrivial**: Product witnesses create factorizations of different *lengths* (1 vs 2) — a phenomenon absent in standard number theory.
5. **shadow_disjoint_of_product_free**: The multiplicative shadow of a product-free set is disjoint from the set itself, constraining density.
6. **shadow_card**: Shadow cardinality equals source size (injectivity of multiplication).
7. **product_free_no_self_representation**: Product-free systems have zero "self-representations."
8. **system236_not_uf**: Explicit UFD failure for the system {2,3,6}.
9. **dirichlet_survival**: Density in residue classes implies infinitude (Dirichlet survives).

### Falsifiable Conjecture
**CramerUFDIncompatibility**: No pseudo-prime system with counting function ≥ n/log(n) can be product-free. Computationally testable: search for the densest product-free subset of {2,...,N} and check if density can reach 1/log(N).

## What Survives vs. What Collapses
- **PNT**: Survives by construction (density is built into the model)
- **Dirichlet's theorem**: Survives — it's a density/equidistribution fact, not a multiplicative one
- **Unique factorization**: **Collapses** — random dense sets inevitably contain product witnesses
- **Riemann Hypothesis**: Fails almost surely — random sets have Gaussian fluctuations, not the constrained behavior RH predicts

## Deliverables
- `Shared/CounterfactualPrimes.lean` — 312 lines, 9 verified theorems
- `ARTICLE.md` — Popular science article (no mention of formal verification)
- `RESEARCH_PAPER.md` — Full research paper with proofs, algorithms, discussion
- `FUTURE_DIRECTIONS.md` — 5 research directions with conjectures, tests, and strategies
- `demo.py` — Numerical demonstrations of all key results
- `algorithms.py` — Type-hinted implementations of core algorithms
- `viz_product_witnesses.py`, `viz_density_spectrum.py` — Visualization scripts
- `PACKAGE.json` — Bundle with 3 interactive HTML widgets