# Summary of changes for run 9213ab83-0f4b-4e78-937f-94790e75e9a1
## Completed: Berggren Hidden-Subsemigroup Rigidity Formalization

### Lean 4 Formalization (`Cryptography/BerggrenSubsemigroupRigidity.lean`)

A self-contained, 476-line Lean 4 file with **37 theorems, 0 sorries**, building successfully against Mathlib. All proofs use only standard axioms (propext, Classical.choice, Quot.sound).

**Core Infrastructure** (from the Berggren semigroup theory):
- `BerggrenGen` — three generators A, B, C with `Fintype` and `DecidableEq`
- `BergWord = List BerggrenGen` — the word model
- `actGen`, `rootPair`, `evalPair` — the Berggren pair action
- `ValidPair` and validity preservation through the action
- **`evalPair_injective`** — the foundational freeness theorem (the Berggren action is injective)

**New Spectral Definitions**:
- `ParikhTriple = ℕ × ℕ × ℕ` — abelianized word invariant
- `parikhTriple` — computes (#A, #B, #C) counts
- `allWordsOfLength`, `boundedWords` — enumeration as `Finset`
- `boundedParikhSpectrum`, `boundedProfileSpectrum`, `boundedLengthSpectrum` — spectral invariants
- `truncation` — bounded restriction of a word set
- `subsemigroupClosure` — closure under concatenation
- `collidesOnRadius` — collision predicate

**Proved Theorems** (all four requested theorem layers):

1. **Reconstruction**: `word_reconstruction_from_profile` — orbit profile alone determines the word uniquely. `short_word_reconstruction` — the bounded version with redundant Parikh hypothesis.

2. **Bounded spectrum extensionality**: `bounded_profile_determines_membership` — equal profile spectra imply identical membership on the ball. `bounded_profile_determines_truncation` — the Finset-equality form.

3. **Certified collision-freeness**: `certified_no_collision` — no collisions on any radius ball. `no_collision_global` — no collisions globally. `certified_no_collision_of_reconstruction` — derived from any reconstruction hypothesis.

4. **Hidden-subsemigroup recovery**: `hidden_subsemigroup_recovery` — spectral agreement recovers bounded membership. `hidden_subsemigroup_recovery_finset` — the Finset truncation form.

**Supporting lemmas**: Parikh additivity (`parikhTriple_mul`), length-from-Parikh (`wordLength_of_parikhTriple_eq`), ball membership characterization (`mem_boundedWords_iff`), spectrum membership characterization, lossless spectral compression (`card_boundedProfileSpectrum_eq`), ball cardinality (`card_allWordsOfLength`: 3^n words at depth n).

### Python Demos (`demos/`)

- `berggren_spectral_demo.py` — Six demonstrations:
  1. Berggren tree visualization (first 4 levels with Pythagorean triples)
  2. Injectivity/collision-freeness verification up to R=6
  3. Parikh spectrum analysis showing class separation
  4. Hidden-subsemigroup recovery example
  5. Visualizations (orbit profiles colored by first generator; growth curves)
  6. Collision certificate computation
- `berggren_spectral_plots.png`, `berggren_growth.png` — generated visualizations

### Research Paper (`paper/berggren_rigidity.md`)

A complete mathematical paper covering:
- Introduction to the Berggren semigroup and its free semigroup property
- Formal definitions of Parikh vectors, bounded spectra, and subsemigroup closure
- Three main theorems with proofs (collision-freeness, subsemigroup recovery, lossless compression)
- Applications to noncommutative hash functions and the hidden-subsemigroup problem
- A Scientific American-style discussion section ("Making Semigroups Talk")
- Formalization notes and references

### Future Directions (`FUTURE_DIRECTIONS.md`)

Five concrete next theorems with proposed Lean signatures:
1. Parikh-only reconstruction with auxiliary invariants
2. Quantitative spectral gap for Parikh classes
3. Tropical analogue over the min-plus semiring
4. Hidden-subsemigroup decision problem complexity
5. Multi-root extension for simultaneous actions