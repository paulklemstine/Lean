# Summary of changes for run c9e9f442-0ff4-49ae-9f62-7834907df3bc
# Collatz Affine Monoid (CAM) — Research Cycle Complete

## Lean 4 Formalization

**File:** `Catalog/Algebra/CollatzAffineMonoid.lean` (279 lines, **zero sorries**, builds cleanly)

### Verified Theorems (14 non-trivial results):

1. **Three-Two Separation (Strong Form):** `three_two_separation_strong` — 3^s = 2^e implies s = 0 ∧ e = 0. The only solution in naturals is the trivial one.

2. **Three-Two Separation:** `three_two_separation` — 3^s ≠ 2^e when s ≥ 1 and e ≥ 1 (oddness vs. evenness argument).

3. **Growth-Decay Dichotomy:** `growth_decay_dichotomy` — For s + e > 0, either 3^s < 2^e or 3^s > 2^e. No "neutral" orbit segments exist.

4. **Fundamental Asymmetry:** `fundamental_asymmetry` — For any non-empty parity word, the CAM numerator ≠ denominator. Every non-trivial orbit segment either grows or shrinks.

5. **Parity Word Numerator:** `parityWordCAM_num` — The numerator of a parity word's CAM element is exactly 3^(odd step count).

6. **Parity Word Denominator:** `parityWordCAM_denom` — The denominator is exactly 2^(even step count).

7. **Density Contraction:** `density_contraction_sufficient` — When 3s ≤ k (at least 2/3 of steps are even), 3^s < 2^(k-s). Note: the initially conjectured condition 2s < k was *disproved* (counterexample: s=2, k=5).

8. **Double-Density Contraction:** `three_pow_lt_two_pow_double` — 3^s < 2^(2s) for s ≥ 1.

9. **Offset Positivity:** `offset_positive_of_has_odd` — Any parity word with at least one odd step has positive offset.

10. **Coprimality:** `three_pow_coprime_two_pow` — gcd(3^s, 2^e) = 1.

11. **Three-Power Periodicity mod 8:** `three_pow_mod_eight` — 3^s mod 8 = 1 if s is even, 3 if s is odd.

12. **Termination Hierarchy Monotonicity:** `termLevel_mono` — T(k) ⊆ T(k+1).

13. **Collatz Reformulation:** `collatz_iff_union` — The conjecture ↔ every n ≥ 1 belongs to some T(k).

14. **Hierarchy Strictness:** Concrete proofs that 2 ∈ T(1)\T(0) and 4 ∈ T(2)\T(1).

### Key Disproof Discovery
The initially hypothesized `density_half_contraction` (2s < k ⟹ 3^s < 2^(k-s)) was **disproved** — the counterexample s=2, k=5 shows 9 > 8. The corrected sufficient condition requires 3s ≤ k, reflecting the true threshold log₂(3) ≈ 1.585.

## Deliverables

- **`ARTICLE.md`** — 2000-word Scientific American-style article about the mathematical ideas
- **`RESEARCH_PAPER.md`** — 3500-word research paper with formal definitions, theorem statements, proof sketches, and references
- **`FUTURE_DIRECTIONS.md`** — 5 research directions including 2-adic offset measures (grand challenge), tropical CAM, matrix representation, Collatz-Beal bridge, and automated offset classification
- **`demo.py`** — Interactive demo computing CAM elements for specific orbits
- **`algorithms.py`** — Type-hinted Python implementations of all CAM algorithms
- **`visualize_cam.py`** — Matplotlib visualization of offset landscapes and growth-decay diagrams
- **`PACKAGE.json`** — Bundle with 3 interactive HTML widgets (CAM Explorer, Three-Two Separator, Composition Calculator)