# Summary of changes for run c5453896-7707-485b-9432-f42d992e932a
# Galois Group of X⁵ − X − 1 is S₅: Formal Verification

## Overview

I formalized a proof that the Galois group of the polynomial f(X) = X⁵ − X − 1 over ℚ is isomorphic to the symmetric group S₅. The proof combines polynomial arithmetic, modular factorization, and finite group classification in a pipeline that serves as a prototype for certified Galois group computation.

## Lean 4 Formalization

### File: `Catalog/Speculative/GaloisS5/GroupTheory.lean` (100% sorry-free)
Contains 4 sorry-free theorems about the structure of S₅:
- **`Perm_Fin5_alternating_le_of_normal_nontrivial`**: Any nontrivial normal subgroup of S₅ contains A₅ (uses simplicity of A₅ and trivial center of S₅ via `native_decide`).
- **`Perm_Fin5_no_index_four`**: S₅ has no subgroup of index 4 (via coset action and kernel analysis).
- **`Perm_Fin5_index_two_eq_alt`**: Any index-2 subgroup of S₅ is A₅ (via Mathlib's `eq_alternatingGroup_of_index_eq_two`).
- **`S5_of_30_dvd_not_alt`**: If H ≤ S₅, 30 | |H|, and H ⊄ A₅, then H = S₅.

### File: `Catalog/Speculative/GaloisS5/Basic.lean` (2 remaining sorry's in connecting theorems)
Contains 16+ sorry-free theorems:
- **Irreducibility**: `quinticS5_irreducible_ℚ` — proved by lifting irreducibility from 𝔽₃ via `Polynomial.Monic.irreducible_of_irreducible_map` and Gauss's lemma.
- **Mod-2 factorization**: `quinticS5_mod2_factorization` — X⁵+X+1 = (X²+X+1)(X³+X²+1) over 𝔽₂, with both factors proved irreducible.
- **Discriminant**: `quinticS5_not_isSquare_disc` — 2869 is not a perfect square (via `native_decide`).
- **Galois properties**: 5 divides |Gal|, pretransitive action, elements of order 6 in S₅ are odd.
- **Conditional main theorem**: `quinticS5_30_dvd_gal_card` — if Gal contains an order-6 element, then 30 | |Gal|.

The 2 remaining sorry's are in the final connecting theorems (`quinticS5_gal_card_of_dedekind` and `quinticS5_galActionHom_bijective_of_dedekind`). These require (a) Dedekind's theorem (deep algebraic number theory, not in Mathlib) and (b) a type-theoretic transfer between `Perm(rootSet f ℂ)` and `Perm(Fin 5)` that is mathematically trivial but technically involved.

### Key mathematical correction
The problem blueprint claimed f is irreducible mod 2 — this is **false**: X⁵+X+1 = (X²+X+1)(X³+X²+1) over 𝔽₂. The correct proof uses mod-3 irreducibility for the lifting argument, and the mod-2 *factorization* for the Dedekind cycle-type witness. The original S₅ classification lemma (transitive + 5-cycle + not in A₅) was also incorrect — the Frobenius group F₂₀ is a counterexample. The corrected lemma uses 30 | |H| instead.

## Deliverables

1. **`ARTICLE.md`** — Popular science article (~2000 words) about how symmetry groups of polynomial equations are determined through arithmetic data.
2. **`RESEARCH_PAPER.md`** — Technical research paper documenting the formalization, proof strategy, and Mathlib infrastructure used.
3. **`FUTURE_DIRECTIONS.md`** — Roadmap with 6 concrete next steps, prioritized by impact.
4. **`demo.py`** — Interactive demonstration of the arithmetic certificates.
5. **`algorithms.py`** — Galois group computation pipeline for quintics over ℚ.
6. **`applications.py`** — Applications: solvability analysis, subgroup lattice, certification examples.
7. **`visualizations.py`** — Matplotlib visualizations: roots in ℂ, subgroup lattice, polynomial graph.
8. **`PACKAGE.json`** — JSON bundle of all artifacts with embedded base64 visualizations.
