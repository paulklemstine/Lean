# Summary of changes for run 8203decf-b74b-41e9-a267-34ce4c7db7d5
## Summary

I produced a new self-contained Lean 4 development plus the required research narrative, both building on the existing Baker–Norine chip-firing infrastructure in `Catalog/Bridges/GraphRiemannRoch.lean` and `Catalog/Tropical/TropicalAdvancedTheory.lean`.

### New file: `Catalog/Bridges/TropicalRiemannRochRank.lean`
This generalizes graph chip-firing rank theory to an abstract **degree-preserving move system** `moves : ι → Divisor n` (each move of total degree 0), of which graph firing vectors are the canonical instance. All main theorems are proved with **no `sorry`** (verified via the LSP):

**Step 1 — theorem declarations / status (all `proved`):**
1. `principalEquiv_degree` — linear equivalence preserves degree (abstract form of chip-firing degree invariance).
2. `rank_le_degree` — easy half of Riemann–Roch: `r(D) ≤ deg D`. *(best theorem)*
3. `rank_antitone` — the Baker–Norine rank is downward closed in `r` (monotonicity); stated with the minimal hypothesis `s ≤ r` since the lower bound on `s` is unnecessary.
4. `not_hasRank_zero_of_neg_degree` — negative-degree divisors have rank `−1`.
5. `rank_zero_divisor` — exact rank computation `r(0) = 0`.
6. `graph_riemann_roch_inequality` — instantiation of the abstract bound back to genuine `SimpleGraph` chip-firing (cross-domain bridge), supported by `firingVector_degree_zero`.

Each theorem carries a one-to-two sentence proof sketch in `-- !-- ... -- !--` blocks, plus supporting lemmas on divisor degree, effectivity, and a point-divisor construction.

For the best theorem (`rank_le_degree`), the file also contains its complementary results: `rank_antitone` (a strengthening to a full monotonicity statement) and `not_hasRank_zero_of_neg_degree` (the boundary case where degree drops below 0 and rank collapses to `−1`).

The catalog globs in `lakefile.toml` point at directory names that don't match the actual `Catalog/...` layout, so whole-project `lake build` of these files is a no-op in this repo; I therefore verified the entire file compiles cleanly with zero diagnostics and zero sorries through the language server.

### `FUTURE_DIRECTIONS.md`
Five falsifiable research conjectures extending the work (full Riemann–Roch inequality `deg D − g + 1 ≤ r(D)`; `q`-reduced divisors / Dhar's burning algorithm as a certified decision procedure; well-definedness of the integer rank function; Clifford's inequality; and specialization functoriality across move systems), each with an explicit "The key insight is…" and "Why now?" justification tied to the lemmas just proven.