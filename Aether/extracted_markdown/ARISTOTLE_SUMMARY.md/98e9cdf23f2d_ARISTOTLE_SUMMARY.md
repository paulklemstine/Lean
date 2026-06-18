# Summary of changes for run 20b2b49c-5346-40cf-bdf0-2fa4517edb72
## Polynomial Width Growth for Bounded Certificate-Family Posets

### Formally Verified Mathematics (Lean 4)

Created `Pythagorean/PolynomialWidth.lean` containing **12 formally verified theorems with zero `sorry`** (only standard axioms: `propext`, `Classical.choice`, `Quot.sound`). The file builds on the existing catalog in `Pythagorean/CertificatePosetWQO.lean`.

**Key theorems proved:**

1. **Box Width Theorem** (`box_width_polynomial`): Any antichain in `[0,N]^m` has at most `(N+1)^m` elements — polynomial in N for fixed dimension m.

2. **Rank Monotonicity** (`rank_mono`): Componentwise domination implies rank domination.

3. **Maximum Rank Bound** (`max_rank_bound`): Maximum coordinate sum in `[0,N]^m` is `m·N`.

4. **Profile Coordinate Bounds** (`profile_coordinate_le_family_card`, `profile_coordinate_le_universe`): Each certificate profile coordinate is bounded by the family cardinality and the universe cardinality respectively.

5. **Universe Polynomial Bound** (`universe_card_polynomial`): The bounded certificate universe has at most `(n+1)^{2t}` elements — polynomial in n for fixed t. This required proving the combinatorial lemma `bounded_subsets_card_le` that the number of subsets of `Fin n` of size ≤ t is at most `(n+1)^t`.

6. **Profile-Based Width Bound** (`achievableProfiles_upper_bound`): Profile-injective antichains have cardinality at most the number of achievable profiles.

7. **Polynomial Profile-Width Theorem** (`polynomial_profile_width_bound`, **Main Result**): Any profile-injective antichain of bounded certificate families on `Fin n` has cardinality at most `((n+1)^{2t}+1)^{(t+1)²}`, which is O(n^{2t(t+1)²}) for fixed t.

8. **Existential Polynomial Width** (`bounded_certificate_width_polynomial_exists`): There exists an exponent d(t) such that every profile-injective antichain has at most `(n+1)^d` elements.

9. **Polynomial Beats Exponential** (`polynomial_beats_exponential`): The polynomial bound is provably exponentially tighter than the catalog's `2^|universe|` bound for sufficiently large n.

### Mathematical Honesty Note

The polynomial width bound holds for **profile-injective** antichains — those where no two families share the same certificate profile. The full unconditional polynomial width claim (without profile injectivity) remains open, as profile collisions can occur. This is explicitly documented and identified as a key open direction.

### All Deliverables

1. **`Pythagorean/PolynomialWidth.lean`** — 12 theorems, 0 sorry, fully verified
2. **`ARTICLE.md`** — Popular-science article (~2500 words) explaining polynomial width theory
3. **`RESEARCH_PAPER.md`** — Comprehensive research paper with proofs, algorithms, experiments, references
4. **`FUTURE_DIRECTIONS.md`** — 5 structured research directions with conjectures, tests, and impact analysis
5. **`demo.py`** — Interactive demonstration comparing polynomial vs exponential bounds
6. **`algorithms.py`** — Implementations of profile computation, rank-level counting, width estimation
7. **`applications.py`** — Applications to obstruction search, parallel budget allocation, complexity classification
8. **`PACKAGE.json`** — Complete JSON data package for web templating