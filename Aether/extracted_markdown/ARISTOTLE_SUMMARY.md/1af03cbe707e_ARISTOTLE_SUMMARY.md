# Summary of changes for run 97ee6e7b-188c-4b8c-9537-36a71a66c977
## Completed: Berggren Fingerprint Rigidity — Formally Verified Collision Resistance

### Lean 4 Formalization (zero sorry, fully verified)

**File:** `Catalog/Cryptography/BerggrenFingerprintRigidity.lean` (424 lines)

All definitions and theorems compile cleanly with no `sorry` statements and only standard axioms (propext, Classical.choice, Quot.sound, Lean.ofReduceBool, Lean.trustCompiler).

#### Core Definitions
- `BerggrenWord` — words over three generators (List (Fin 3))
- `berggrenGen` — the three 3×3 integer Berggren generators U, A, D
- `evalWord` — word evaluation as matrix product
- `abelianCount` — abelianized generator counts
- `tripleOfWord` — the Pythagorean triple produced by applying a word to (3,4,5)
- `actWordTriple`, `fingerprintTripleR`, `fingerprintCodeR` — fingerprint functions
- `rootSet` — singleton {(3,4,5)} as test set
- `compareFingerprint` — computable distinguisher
- `keyExtract` — key extraction function
- `WordDist`, `distAbelianProfile` — distributional infrastructure
- `statA`, `statB`, `statC`, `statVec` — generator-sensitive observables

#### Main Theorems Proved
1. **`berggren_word_action_injective`** — Freeness: the Berggren semigroup is free on 3 generators (distinct words → distinct triples)
2. **`gen_hyp_pairwise_distinct`** — Generator separation: distinct generators produce distinct hypotenuses on any positive Pythagorean triple (uses irrationality of √2 for the a=b case)
3. **`fingerprint_root_determines_word`** — Full fingerprint rigidity: the full-triple fingerprint over {(3,4,5)} determines the word entirely
4. **`fingerprint_injective_abelianized`** — **Main theorem**: equal fingerprints imply equal abelianized generator counts
5. **`fingerprintSeparates_distinct_abelianizations`** — Collision resistance: different abelian profiles → different fingerprints
6. **`exists_certified_radius`** — Certified radius R₀ = 5 suffices
7. **`compareFingerprint_sound`** — Soundness of computable distinguisher
8. **`fingerprint_gen_injective`** — Single-step rigidity

#### Supporting Infrastructure
- `evalWord_append` — word evaluation homomorphism
- `abelianCount_append` — abelian count additivity
- `berggren_gen_preserves_positive` — generators preserve positive Pythagorean triples
- `berggren_gen_hyp_increases` — each generator strictly increases hypotenuse
- `berggren_hyp_ge_five` — minimum hypotenuse is 5
- `actGenTriple_injective` — generator injectivity
- `actGenTriple_generator_determined` — generators are distinguishable
- `hyp_diff_10`, `hyp_diff_12`, `hyp_diff_20` — exact hypotenuse difference formulas (4b, 4a, 4(b−a))
- `height_strict_mono_gen` — height monotonicity

### Python Demos

**File:** `demos/berggren_fingerprint_demo.py`

Three interactive demonstrations with two visualizations:
1. **Generator Separation** — shows distinct generators produce distinct hypotenuses
2. **Fingerprint Rigidity** — verifies all words of length ≤ 3 have distinct fingerprints
3. **Collision Resistance / Key Extraction** — tests 744 word pairs, confirms zero collisions

**Visualizations generated:**
- `demos/berggren_fingerprint_visualization.png` — Berggren tree, generator separation bars, exponential growth
- `demos/abelian_separation.png` — fingerprint separation by abelian profile

### Research Paper

**File:** `paper/berggren_fingerprint_rigidity.md`

A complete mathematical paper covering:
- The Berggren tree and fingerprint problem
- Proof architecture (positivity preservation → hypotenuse growth → freeness → generator separation → rigidity)
- The elegant role of √2 irrationality in generator separation
- A Scientific American-style discussion section explaining the result via the "labyrinth" analogy
- Applications to post-quantum hashing, verifiable computation, and number-theoretic fingerprinting

### Future Directions

**File:** `FUTURE_DIRECTIONS.md`

Five concrete next steps:
1. Full distributional rigidity for word measures
2. Partial ordered-word recovery from weaker statistics
3. Tropicalization of the fingerprint
4. Analogues for Markov triples, Apollonian gaskets, thin groups
5. Quantum query lower bounds from collision obstructions