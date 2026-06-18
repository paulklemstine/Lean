# Summary of changes for run 96dbd3ab-b195-4dc7-bbf2-62ddbbabf333
## Completed: Tropical Height Rigidity for Berggren Tree Valuations

### Deliverable 1: Formally Verified Mathematics (Lean 4) — 0 sorries

**File:** `Bridges/AlgebraCryptographyPythagorean/TropicalHeightRigidity.lean` (353 lines, fully verified)

**Key definitions:**
- `Gen` — Berggren generators {A, B, C} with Fintype instance
- `evalWord` — matrix evaluation of words (monoid homomorphism)
- `tripleOfWord` — Pythagorean triple from a Berggren word
- `ObsVec` — tropical observable vector (archimedean height + 2-adic/3-adic valuations)
- `AugObsVec` — augmented observable with mod-5 and mod-7 residue data
- `WordsUpTo d` — finite set of all words of length ≤ d
- `fiber`, `fiberAug` — preimage fibers of θ and θ_aug
- `exceptionalSet` — observable values with non-singleton augmented fibers

**Main theorems (all fully proved):**
1. `fiber_singleton_or_collision` — every nonempty fiber is either a singleton or has a collision
2. `berggren_theta_decidable_rigidity` — decidable rigidity/collision dichotomy for all observable values in the image
3. `singleton_fiber_gives_unique` — singleton fibers yield unique witnesses
4. `card_ge_two_gives_collision` — fibers with card ≥ 2 yield explicit collision pairs
5. `fiber_card_pos_iff` — positive fiber cardinality iff observable is in the image
6. `invertTheta_correct` — certified inversion trichotomy (unique/collision/empty)
7. `generic_singleton_outside_exceptional` — augmented fibers are singletons outside the exceptional set
8. `berggren_thetaAug_decidable_rigidity` — decidable rigidity for augmented observables
9. `invertThetaAug_correct` — certified augmented inversion
10. Concrete computational verifications: `tripleOfWord_A/B/C`, `depth1_all_rigid`, `depth1_aug_all_rigid`
11. Structural lemmas: `evalWord_append`, `padic_val_mul_nat`, `root_is_pythagorean`

All axioms are standard (propext, Classical.choice, Quot.sound, Lean.ofReduceBool, Lean.trustCompiler).

### Deliverable 2: Popular Science Article
**File:** `Bridges/AlgebraCryptographyPythagorean/ARTICLE.md` (~2200 words)

### Deliverable 3: Research Paper
**File:** `Bridges/AlgebraCryptographyPythagorean/RESEARCH_PAPER.md` (~3500 words)

### Deliverable 4: Python Code
- **`demo.py`** — Full working demo showing Berggren tree triples, fiber classification at depths 1–5, augmented observable separation (100% collision reduction at all tested depths), certified inversion examples, and tree structure display
- **`visualizations.py`** — matplotlib visualizations: fiber classification bar charts, Berggren tree with height coloring, observable space scatter plots
- Generated PNGs: `rigidity_stats.png`, `berggren_tree.png`, `observable_scatter.png`

### Deliverable 5: Future Directions
**File:** `Bridges/AlgebraCryptographyPythagorean/FUTURE_DIRECTIONS.md`
Five concrete directions: (1) asymptotic sparsity of exceptional sets, (2) tropical polyhedral complex, (3) transport to Markoff/Apollonian trees, (4) complexity bounds for certified inversion, (5) cryptographic protocol design.

### Deliverable 6: JSON Package
**File:** `Bridges/AlgebraCryptographyPythagorean/PACKAGE.json` (462KB)
Complete bundle with all content, base64-encoded visualizations, and code.

### Key Mathematical Finding
Computational experiments reveal that the augmented observable θ_aug (with mod-5 and mod-7 residues) achieves **zero collisions** at all tested depths (1–5), while the base observable θ develops collisions starting at depth 3. The first collision under θ occurs between words "ABC" → (187, 84, 205) and "CCB" → (133, 156, 205), which share archimedean height and valuation profiles but differ in mod-5 residues.