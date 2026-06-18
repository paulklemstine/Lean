# Summary of changes for run 7c3262d1-78ce-4c31-8356-e5c4d8e098bb
## Summary

I produced a new, self-contained Lean 4 file `Catalog/Novelty/GilbertVarshamov.lean` extending the "Library of Babel" Hamming-space framework with the two complementary extremal bounds of coding theory, plus a `Catalog/Novelty/FUTURE_DIRECTIONS.md`.

### Theorem declarations (all `proved`, sorry = 0)
Over words `Word A L = Fin L → Fin A` with the Hamming metric:

1. `mem_ball` — characterization of Hamming-ball membership.
2. `ball_disjoint` — in a `(2r+1)`-separated code, radius-`r` balls around distinct codewords are disjoint (triangle inequality). Non-trivial: turns a metric separation hypothesis into set disjointness.
3. `hamming_sum_bound` — disjoint balls fit in the space: `Σ |ball c r| ≤ A^L`.
4. `maximal_covers` — maximality ⇒ every word lies within `d-1` of a codeword (else it could be added). Key combinatorial step of Gilbert–Varshamov.
5. `maximal_ball_cover` / `gv_sum_bound` — the radius-`(d-1)` balls of a maximal code cover everything, so `A^L ≤ Σ |ball c (d-1)|`.
6. `ball_card_uniform` — Hamming space is homogeneous: ball cardinality is centre-independent, via a coordinatewise transposition bijection.
7. `sphere_card` — exact count `#{v : d(c,v)=k} = C(L,k)(A-1)^k`, proved by induction on `L` with a head/tail split and Pascal's rule (the deepest result).
8. `ball_card_eq` — closed-form ball volume `V(r) = Σ_{k≤r} C(L,k)(A-1)^k`.
9. **`gilbert_varshamov`** (headline) — for a maximal code: `A^L ≤ |C| · V(d-1)` (lower bound on code size).
10. **`hamming_packing`** (headline) — for a `(2r+1)`-separated code: `|C| · V(r) ≤ A^L` (sphere-packing upper bound).
11. **`code_size_sandwich`** — combines both into `|C|·V(r) ≤ A^L ≤ |C|·V(2r)` for a maximal `(2r+1)`-code.

All proofs compile and depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound` (verified via `#print axioms`); there are no `sorry`/`admit`. Proof sketches are included inline as `!-- ... --!` comment blocks. The file is self-contained (imports only Mathlib) and does not depend on the pre-existing broken sibling file `BabelFoundations.lean`.

During development I found that the existing `BabelFoundations.lean` references undefined names and does not compile, and that the project's `lakefile.toml` does not register the `Novelty` directory or its source root as a build target (so `lake build` was a no-op even before my work). To avoid converting that vacuously-passing build into a failing one by activating pre-existing broken files, I left `lakefile.toml` unchanged; the new file was verified to compile cleanly against Mathlib independently.

### FUTURE_DIRECTIONS.md
Five falsifiable research conjectures extending the work, each with a "The key insight is..." sentence and a "Why now?" justification: (1) the Singleton bound and MDS codes, (2) the Plotkin bound via average pairwise distance, (3) asymptotic rate vs. the entropy bound, (4) a greedy construction attaining the Gilbert–Varshamov bound, and (5) perfect codes and the equality case of sphere-packing.