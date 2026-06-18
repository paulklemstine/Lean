# Summary of changes for run 0293a334-0faa-41ad-b777-d92a0faeb6c6
# Riemann-Roch Theorem for Graphs: Chip-Firing and the Canonical Divisor

## Lean 4 Formalization (`Bridges/GraphRiemannRoch.lean`)

Fully verified (zero `sorry`) formalization of Baker-Norine theory with **16 proved theorems**:

### Novel Definitions (not in Catalog or Mathlib)
- `GraphDivisor n` — divisors on graphs with vertex set `Fin n`
- `ChipFiring.chipFire` — the chip-firing operation
- `ChipFiring.canonicalDivisor` — the canonical divisor K_G(v) = deg(v) - 2
- `ChipFiring.LinearEquiv` — linear equivalence via the graph Laplacian
- `ChipFiring.HasRankAtLeast` — divisor rank predicate
- `RiemannRoch.CanonicalRankConjecture` — testable conjecture: rank(K_{K_n}) = g - 1

### Key Theorems Proved
1. **`chipFire_preserves_degree`** — Chip-firing conserves total chips (multi-step rewriting proof)
2. **`canonical_divisor_degree`** — deg(K_G) = 2g - 2 (uses handshaking lemma)
3. **`K_genus`** — Genus of K_n = (n-1)(n-2)/2 (cases + omega reasoning)
4. **`linearEquiv_degree`** — Linear equivalence preserves degree (sum interchange + firing vector)
5. **`negative_degree_not_equiv_effective`** — Negative degree ⟹ no effective equivalent (contradiction argument)
6. **`K_edge_count`** — |E(K_n)| = n(n-1)/2 (bijection with powerset)
7. **`K_canonical_value`** — K_{K_n}(v) = n-3 for all vertices
8. **`K_canonical_degree`** — deg(K_{K_n}) = n(n-3)
9. **`K_chipFire_effect`** — Chip-firing on K_n: non-firing vertices gain exactly 1
10. Plus 7 more supporting theorems

All proofs use only standard axioms (propext, Classical.choice, Quot.sound).

### Testable Conjecture
**`CanonicalRankConjecture`**: For K_n, rank(K_{K_n}) = g - 1. Verified computationally for n = 3, 4, 5, 6 (all pass).

## Computational Verification (`demo.py`, `algorithms.py`)
- Implements Dhar's burning algorithm for q-reduced divisors
- Verifies Riemann-Roch formula r(D) - r(K-D) = deg(D) + 1 - g on K_3, K_4, K_5, K_6 and cycle graphs C_3–C_6
- All tests pass: the Riemann-Roch formula holds for every tested divisor

## Deliverables
- **`ARTICLE.md`** — Scientific American-style article about chip-firing and graph Riemann-Roch (no mentions of formal verification)
- **`RESEARCH_PAPER.md`** — Technical paper with proofs, algorithms, and computational results
- **`FUTURE_DIRECTIONS.md`** — 5 research directions including formal Riemann-Roch proof (grand challenge), Jacobian/sandpile isomorphism (grand challenge), tropical Brill-Noether theory, random graph phase transitions, and specialization from curves to graphs
- **`PACKAGE.json`** — Complete bundle with interactive HTML chip-firing demo (click vertices to fire, select K_3/K_4/K_5)
- **`visualize_chipfiring.py`** — Matplotlib visualizations of genus, canonical divisor degree, and Riemann-Roch verification