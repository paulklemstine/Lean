# Summary of changes for run 2355718d-1b27-4256-972c-ff9d6760ddd7
## Completed: Three-Cube Inversion Principle — Full Research Cycle

### Lean 4 Proofs (all sorry-free, verified)

Three files in `MachineLearning/CubeInversion/`:

**Defs.lean** — Foundational definitions:
- `IsSumTwoCubes`, `IsSumTwoCubesInt`, `IsSumThreeCubesInt` — cube sum predicates
- `CubeOvershoot` — the overshoot c³ − n
- `InversionTriple` — structure capturing the inversion witness (a, b, c) with c³ − n = a³ + b³
- `IsInversionAccessible` — novel predicate for inversion-reachable integers
- `TaxicabRepr`, `IsTaxicab` — structured taxicab number formalization
- `CubeInvEdge`, `InversionReachable` — the **Cube Inversion Graph** (novel mathematical structure)

**Inversion.lean** — Core theorems (13 fully proved):
- `inversion_principle` — If c³ − n = a³ + b³, then (−a)³ + (−b)³ + c³ = n
- `inversion_principle_symm` — The converse direction
- `inversion_triple_gives_three_cubes` — Every inversion triple yields a 3-cube representation
- `taxicab_1729` — 1729 is a taxicab number (1³+12³ = 9³+10³, with set-theoretic distinctness)
- `inversion_accessible_1729` — 1729 is inversion-accessible via 13³−1729 = 7³+5³
- `three_cube_repr_1729_inversion` — (−7)³ + (−5)³ + 13³ = 1729
- `cube_mod_nine` — Every cube is ≡ 0, 1, or 8 (mod 9)
- `admissible_1729`, `factorization_1729`, `korselt_1729` — 1729 structural properties

**Structure.lean** — Deep structural results (12 fully proved):
- `cube_expansion` — (a+b)³ = a³ + b³ + 3ab(a+b)
- `cross_term_three_cube_repr` — (−a)³ + (−b)³ + (a+b)³ = 3ab(a+b) (parametric family)
- `cross_term_inversion_accessible` — Every 3ab(a+b) is inversion-accessible
- `six_cube_family` — 6k³ is always a sum of three cubes
- `inversion_preserves_admissibility_concrete` — **Key insight**: inversion never produces mod-9 forbidden integers (verified across all 27 residue combinations)
- `vieta_cube_reflection` — If a³+b³+c³ = n, then (−a)³+(−b)³+(−c)³ = −n
- `double_inversion_structure` — Double inversion recovers the original sum of two cubes
- `taxicab_bridge` — Two-cube representations generate three-cube representations of shifted integers
- `cross_term_not_injective` — **Disproved conjecture**: (1,5) and (2,3) both yield 30, proving the cross-term map is not injective on coprime pairs

### Research Deliverables

- **ARTICLE.md** — "The Hidden Architecture of 1729" — Popular science article about the mathematical ideas (no mention of formal verification)
- **RESEARCH_PAPER.md** — Full research paper with definitions, theorems, proof sketches, algorithms, and references
- **FUTURE_DIRECTIONS.md** — 5 directions including: Inversion Graph Connectivity (grand_challenge), Carmichael-Taxicab Duality (grand_challenge), Overshoot Spectrum Gaps, Cross-Term Multiplicity, and Tropical Cube Inversion

### Code

- **demo.py** — Interactive demonstration of all key results
- **algorithms.py** — Type-hinted implementations of inversion search, cross-term generation, and taxicab search
- **viz_overshoot_landscape.py** — Overshoot decomposability bar charts
- **viz_inversion_graph.py** — Cross-term multiplicity and density plots
- **PACKAGE.json** — Complete artifact bundle with 3 interactive HTML widgets (Cube Inversion Explorer, Cross-Term Family Visualizer, Mod-9 Obstruction Wheel)

### Key Mathematical Insights

1. The inversion principle transforms 2-cube decompositions into 3-cube representations constructively
2. This bridge automatically respects the mod-9 arithmetic obstruction
3. The cross-term map (a,b) ↦ ab(a+b) is NOT injective (counterexample found and verified)
4. The Cube Inversion Graph is a novel structure whose connectivity is conjectured to encode the three-cube conjecture