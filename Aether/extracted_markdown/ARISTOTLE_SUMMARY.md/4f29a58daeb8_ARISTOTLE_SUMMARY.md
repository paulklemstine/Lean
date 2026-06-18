# Summary of changes for run fcef5018-11f5-4664-9767-8bcab6b0c94e
## Summary

I added a new, fully-proved Lean module extending the project's cryptographic hardness lattice (the existing `OWF → PRG → PRF → ENC` chain, `LossyFunction` model, and `fiber` preimage calculus already in `Cryptography/HardnessHierarchy.lean` and `Cryptography/Core.lean`).

### New file: `Cryptography/HardnessSeparation.lean`
A rigorous **combinatorial theory of one-wayness** centered on a function's *image density* `|Im f|/|β|` and *collision count* `∑_y |f⁻¹(y)|²`. All theorems are complete with **no `sorry`** and depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound` (verified). The module compiles cleanly with no warnings.

**Theorem declarations (all `proved`):**
1. `fiber_sum_eq_card` — fibers partition the domain (`∑ |f⁻¹(y)| = |α|`); local recall of the catalog lemma. *Why non-trivial:* disjoint-union counting over the image.
2. `directProduct_image_eq_piFinset` — the image of the k-fold parallel repetition is the constant pi-finset of `Im f`. *Constructive forward + choice backward.*
3. `directProduct_image_card` — **Yao's direct-product image identity** `|Im(fᵏ)| = |Im f|ᵏ`. *Combinatorial heart of hardness amplification.*
4. `directProduct_density` — image density is **multiplicative**: `density(fᵏ) = density(f)ᵏ`.
5. `directProduct_density_strict_lt` — **strict amplification / separation**: a non-surjective `f` has strictly smaller density after repetition (`k ≥ 2`); the base lies in (0,1).
6. `inversion_lower_bound` — **Cauchy–Schwarz inversion bound** `|α|² ≤ |Im f| · collisionCount f`, tying the fiber calculus to one-wayness.
7. `randomGuess_success_ge` — rational form: random-guess inversion succeeds with probability `≥ 1/|Im f|`.
8. `lossy_not_oneway_random_guess` — **cross-domain separation** bridging `LossyFunction` ↦ OWF: a lossy (small-image) function is invertible by random guessing with probability `≥ 1/imageSize`, hence cannot be one-way.

Each theorem carries a one-to-two-sentence proof sketch in `-- !-- … -- !--` blocks, and the file's module docstring explains how the results extend the catalog.

### New file: `Cryptography/FUTURE_DIRECTIONS.md`
Five falsifiable research conjectures extending the work (exact tensorization of collision count; quantitative OWF/PRG output-gap separation; tightness of the inversion bound for regular functions; multiplicative end-to-end inversion security through reduction chains; a combinatorial PRF lower bound via GGM tree image saturation). Each includes a "The key insight is…" sentence and a "Why now?" justification grounded in the now-available lemmas.

The module builds successfully (`Cryptography.HardnessSeparation`, 8026 jobs) and is part of the `Cryptography` library target.