# Summary of changes for run 01bcf6a0-39d5-4711-b461-ab9bf0465994
Completed a research cycle on **"Zombies and Qualia: Mathematics of Subjective Experience"** in the MachineLearning domain.

## Deliverables

**1. Lean 4 proofs** — `Catalog/MachineLearning/ZombieQualia.lean` (fully compiles, 0 sorries, only standard axioms). It builds a formal theory where a `Mind` is a pair `(behavior : S → B, quale : S → Q)`, and the zombie/qualia debate becomes a question about whether the internal `quale` map factors through the observable `behavior` map. This doubles as a formalization of **representational non-identifiability** in ML (two parameter settings, same I/O, different internal representation). Main results, all proved:
- `supervenes_iff_factors` — qualia supervene on behavior ⇔ `quale = f ∘ behavior` (functionalism = factorization).
- `not_supervenes_iff_exists_zombiePair` — the "hard problem" is exactly non-factorization (a zombie pair).
- `supervenes_of_injective_behavior` / `not_injective_behavior_of_zombiePair` — separating behavior forbids zombies; zombies force behavioral collapse.
- `conceivability` — every mind has a behaviorally identical constant-quale zombie twin.
- `behavior_underdetermines_qualia` and `exists_nonsupervening_mind` — behavior underdetermines qualia, and behavioral collapse + ≥2 qualia makes a genuine non-supervening mind realizable.
- `physical_no_zombies` — under physicalism (a single shared read-out law `B → Q`) zombies are impossible; `spectrum_inversion_under_physicalism` — yet inverted spectra stay behaviorally undetectable when the law may vary.
- `card_qualia_assignments` — the "zombie space" for a fixed behavior has size `|Q|^|S|`.
- Second cycle (§7): `supervenes_iff_ker_le` recasts supervenience as a `Setoid.ker` comparison, and `superveningEquivRange` proves the bijection {supervening assignments} ≃ `(Set.range behavior → Q)`, quantifying the non-identifiability degeneracy.

**2. Lab notes** — inline `-- !-- Lab Notes -- !--` blocks document hypotheses (functional core, conceivability-as-theorem, physicalism-as-shared-law), outcomes, ML bridge insights, and failure analysis across both cycles.

**3. Future directions** — `Catalog/MachineLearning/ZombieQualia_FUTURE_DIRECTIONS.md` with 5 precise, falsifiable conjectures (exact supervening-count formula, Galois/closure structure of supervenience, an information-theoretic qualia-entropy gap, a faithful-functor characterization of zombie-free worlds, and an orbit–stabilizer account of inverted spectra).

The new module compiles independently and cleanly. Note: the catalog's aggregate default build was already broken before this work by a missing pre-existing file (`Algebra/SpectralNovelty/CutMetric.lean`), which is unrelated to the added module.