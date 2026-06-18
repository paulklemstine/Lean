# Summary of changes for run 67c561c0-f725-41f1-b0d4-3dcdeead6983
## Summary

### Key Mathematical Finding

The originally conjectured theorem **m³ = m² (uniform exponent 2)** for the transition monoid of CA column languages is **false** for strip heights h ≥ 3. An explicit counterexample: the left-projection rule f(x,y) = x with h = 3, where the single-letter transition reading 0 satisfies m²(1,0,0) = (0,0,1) ≠ (0,0,0) = m³(1,0,0).

The **correct theorem** is: **m^{h+1} = m^h** — the aperiodicity exponent equals the strip height h, not 2. This bound is tight.

### Proof Mechanism

The proof exploits the "diagonal shift" structure of the column-extension DFA:
1. **Agreement Lemma**: Each step transition increases the agreement level between any two states by 1 (coordinate i of the output depends only on coordinates 0,...,i-1 of the input).
2. **Constancy**: After reading a word of length ≥ h, the transition is a constant function (all initial information has been "flushed out").
3. **Main Theorem**: Since (wordFn w)^h reads h·|w| ≥ h characters, it is constant. Composing a constant function with anything yields the same constant, so (wordFn w)^{h+1} = (wordFn w)^h.

### Deliverables Produced

1. **`Speculative/CATransitionMonoid.lean`** — Fully verified Lean 4 formalization (213 lines, 0 sorry statements):
   - Definitions: `diagStep`, `stepFn`, `wordFn`, `repeatList`
   - Core lemmas: `diagStep_ext`, `stepFn_agreement`, `wordFn_agreement`, `wordFn_constant`, `wordFn_append`
   - **Main theorem**: `transition_stabilizes` — ∀ w, (wordFn f h w)^[h+1] = (wordFn f h w)^[h]
   - **Counterexample**: `counterexample_m2_ne_m3` — formal disproof of m³ = m² for h = 3
   - All axioms are standard (propext, Classical.choice, Quot.sound)

2. **`ARTICLE.md`** — Popular science article (~1800 words) explaining the result without technical jargon

3. **`RESEARCH_PAPER.md`** — Comprehensive research paper with full theorem statements, proof sketches, computational experiments (exponent tables, monoid size data), and discussion

4. **`FUTURE_DIRECTIONS.md`** — Five falsifiable hypotheses:
   - Rule-dependent exponent formula
   - J-triviality conjecture
   - Piecewise-testability rank bound
   - Generating function pole restrictions
   - Extension to larger neighborhoods

5. **`demo.py`** — Self-contained Python demo showing the counterexample, theorem verification, information propagation visualization, and monoid size computation

6. **`algorithms.py`** — Implementations of transition monoid computation, exponent finding, Green's relations, and rule classification algorithms with docstrings and complexity analysis

7. **`applications.py`** — Applications including bounded model checking, column sequence counting, rule classification, and descriptive complexity bounds

8. **`PACKAGE.json`** — Valid JSON bundle of all deliverables for the web templating system