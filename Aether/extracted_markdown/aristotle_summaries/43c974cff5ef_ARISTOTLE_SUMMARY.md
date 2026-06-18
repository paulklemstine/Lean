# Summary of changes for run 0d957ab8-0956-4cf2-a814-53210fde4e54
## Completed: Berggren-Tree Shortest-Word Rigidity

### Formal Mathematics (Lean 4)

Created `Cryptography/BerggrenHeightDescent.lean` — a 337-line, fully verified Lean 4 file with **zero sorry placeholders** and only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

**Key theorems proved:**

1. **`evalAtRoot_injective`** — The evaluation map from generator words to Pythagorean triples is injective (free-semigroup faithfulness). This is the shortest-word rigidity theorem: distinct words always produce distinct triples.

2. **`actGen_preserves_good`** — Each Berggren generator preserves positive Pythagorean triples.

3. **`actGen_generator_determined`** — If two generators applied to good triples produce the same output, the generators must be identical (cone separation).

4. **`invActGen_unique_good_branch`** — For any good triple, at most one inverse Berggren branch produces a good triple (branch exclusivity).

5. **`actGen_invActGen` / `invActGen_actGen`** — The inverse generators are exact two-sided inverses.

6. **`parent_hyp_lt`** — The parent's hypotenuse is strictly smaller than the child's (height descent).

7. **`hyp_strictly_increases`** — Every generator strictly increases the hypotenuse.

8. **`prefix_rigidity_exact`** — L∞ distance zero between triples iff the words are identical.

9. **`distinct_words_positive_dist`** — Different words always produce triples with positive distance.

10. **`finitely_many_words_bounded_height`** — Only finitely many words produce triples with bounded height.

**Supporting infrastructure:** `evalWord_append` (word composition), `height_lower_bound_root` (linear height growth), `tripleDefect` and `geoDist` (distance metrics), concrete computations for depth-1 triples.

### Python Demos (`demos/`)

- **`berggren_demo.py`** — Seven demonstrations bringing the theorems to life:
  1. Tree generation verifying injectivity at depths 0–4
  2. Parent descent recovering words from triples
  3. Height growth/descent visualization (saved as `height_analysis.png`)
  4. Unique inverse branch verification on 120 triples
  5. Noisy decoding experiments showing exact vs. perturbed recovery
  6. Tree visualization (saved as `berggren_tree.png`)
  7. Branch separation analysis at depths 1–5

### Research Paper (`paper.md`)

A complete mathematical paper covering:
- The Berggren tree and its properties
- Proof architecture and key lemmas
- Cryptographic applications (one-way functions, noncommutative key exchange)
- Comparison with lattice-based cryptography
- An accessible "Scientific American style" discussion section explaining the results via a forest analogy
- References to Berggren (1934), Barning (1963), Hall (1970), and Anshel-Anshel-Goldfeld (1999)

### Future Directions (`FUTURE_DIRECTIONS.md`)

Five concrete next steps with formal Lean theorem signatures:
1. Certified decoding radii and explicit branch-separation thresholds
2. Polynomial-complexity nearest-plane decoder analogous to LLL/BKZ
3. Symbolic geodesic coding connecting to hyperbolic dynamics and continued fractions
4. Cryptographic hardness reductions from noisy Berggren decoding to word recovery
5. Higher-dimensional analogues for Markov-Hurwitz and Lorentzian norm-form trees