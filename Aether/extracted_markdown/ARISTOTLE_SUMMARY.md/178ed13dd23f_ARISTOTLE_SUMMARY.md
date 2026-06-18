# Summary of changes for run 4a61e052-85c8-4b21-ac3a-246fefddfa7c
## Completed: Tropical One-Way Minors via Valuation Congruence Obstructions

### Lean 4 Formalization (0 sorry, clean build)

**File:** `Bridges/AlgebraSpeculativeCryptography/TropicalOneWayMinors.lean` (502 lines)

All 15 theorems are fully proven with only standard axioms (propext, Classical.choice, Quot.sound):

**Core Definitions:**
- `evalWordMatrix` — semigroup homomorphism from free monoid to matrix monoid
- `tropicalAct` — matrix semigroup action on vectors
- `ValCongProfile` — valuation-congruence profile (principal minors + kernel datum + congruence class)
- `collisionFreeOnBall` — collision-freeness on radius-R ball

**Main Bridge Theorems:**
1. `tropical_minor_congruence_collision_bridge` — **the main theorem**: profile separation + witness soundness ⟹ collision-freeness on the ball
2. `collision_iff_bounded_congruence_obstruction` — biconditional: collision ↔ bounded witness
3. `extract_witness_of_collision_on_ball` — constructive witness extraction from collisions
4. `no_collision_on_ball_of_no_bounded_witness` — no witness ⟹ collision-free
5. `collision_free_on_ball_of_profile_separation` — profile injectivity ⟹ collision-free

**Algorithmic Corollaries:**
6. `verifier_sound` — Boolean verifier correctness for collision separation

**Structural Properties:**
7. `collision_separation_radius_mono` — monotonicity in radius
8. `profile_separation_excludes_collision` — direct separation → no collision
9. `collision_implies_profile_collapse_or_witness` — dichotomy lemma
10. `no_collision_of_diff_profile_no_witness` — different profiles + no witness → no collision

**Concrete Instantiation:**
11. `basicProfile_injective_of_diag_ne` — distinct diagonals → distinct profiles
12. `collision_free_length_one` — length-1 collision-freeness from generator injectivity
13. `same_matrix_same_action` — same matrix → same action
14. `evalWordMatrix_append` — semigroup homomorphism property
15. `wordProfile_singleton` — singleton word profile = generator diagonal

### Other Deliverables
- **ARTICLE.md** — Popular science article (~2000 words) explaining tropical cryptography
- **RESEARCH_PAPER.md** — Full research paper with definitions, theorems, algorithms, and references
- **FUTURE_DIRECTIONS.md** — 5 concrete next research directions with theorem targets
- **demo.py** — Python demonstrations with 4 demos (standard matrices, tropical matrices, witness extraction, profile separation statistics)
- **PACKAGE.json** — Complete JSON data package with SVG diagram, all content embedded