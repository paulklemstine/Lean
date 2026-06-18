# Summary of changes for run e6abdb5b-5732-4230-ad57-136c9bc797bc
## The Periodic Table of Finite Groups: Chemistry Meets Algebra

### Research Completed

I developed a rigorous mathematical framework that draws deep parallels between Mendeleev's periodic table of chemical elements and the classification of finite groups. The project builds upon and extends the existing `simple_group_valence_eq_one` theorem from the Catalog (`EML/PeriodicTableGroups.lean`).

### Lean 4 Proofs — 18 Theorems, 0 Sorries

All theorems in `Novelty/PeriodicTableDeep.lean` compile cleanly with only standard axioms (`propext`, `Classical.choice`, `Quot.sound`). Key results:

1. **Derived–Central Series Inequality** (`derived_le_lowerCentral`): D_n(G) ≤ γ_n(G) — the structural backbone establishing abelian ⇒ nilpotent ⇒ solvable.

2. **Noble Gas Theorem** (`noble_gas_depth_bound`): At the nilpotency class, the derived series reaches ⊥. Combined with `derivedDepth_le_nilpotencyClass'`, shows derived depth ≤ nilpotency class.

3. **Chemical Synthesis Theorem** (`solvable_extension'`): Solvability is preserved under group extensions — if N ◁ G with both N and G/N solvable, then G is solvable.

4. **Simple Group Valence Theorem** (`simple_valence_one'`): A nontrivial simple group has exactly one minimal normal subgroup (itself), so valence = 1. Built from `simple_top_minimal_normal'` and `simple_unique_minimal_normal'`.

5. **Information Dimension Additivity** (`groupInfoDimension_prod`): Ω(|G × H|) = Ω(|G|) + Ω(|H|) — the "mass additivity" law.

6. **Halogen Unsolvability** (`halogen_unsolvable'`): S₅ is not solvable.

7. **Nilpotency Class Spectrum** (`nilpotencyClass_one_iff_comm'`): A nontrivial nilpotent group has class 1 iff it is abelian.

8. **Derived Depth Product Formula** (`derivedDepth_prod'`): derivedDepth(G × H) = max(derivedDepth(G), derivedDepth(H)).

9. **Derived Series Product Decomposition** (`derivedSeries_prod'`): The derived series of a product equals the product of derived series.

Plus additional results: `noble_gas_solvable`, `abelianization_comm'`, `commutator_bot_of_comm'`, `nilpotencyClass_prod_eq_max'`, `derivedSeries_antitone'`, `nilpotencyClass_zero_iff'`.

### Deliverables

- **`Novelty/PeriodicTableDeep.lean`** — All 18 Lean 4 theorems, fully proved
- **`Novelty/ARTICLE.md`** — Popular science article (~2500 words) on the group-chemical analogy
- **`Novelty/RESEARCH_PAPER.md`** — Research paper with PEGB analysis for all major theorems
- **`Novelty/FUTURE_DIRECTIONS.md`** — 5 research directions including the Quantitative Periodic Law (grand challenge) and Socle Decomposition
- **`Novelty/demo.py`** — Interactive Python demo computing group invariants
- **`Novelty/algorithms.py`** — Type-hinted classification algorithms
- **`Novelty/visualize_periodic_table.py`** — Matplotlib visualization
- **`Novelty/PACKAGE.json`** — Bundle with 2 interactive HTML widgets (Periodic Table Explorer, Group Order Analyzer)

### Deepening of Catalog Results

The project extends `simple_group_valence_eq_one` (Catalog) by:
- **Generalizing**: Full characterization of minimal normal subgroups of simple groups (unique = ⊤)
- **Strengthening**: Proving the Derived-Central Series Inequality as the unifying structural principle
- **Bridging**: Connecting group valence to lattice theory (atoms of the normal subgroup lattice) and to information theory (prime factorization as information dimension)