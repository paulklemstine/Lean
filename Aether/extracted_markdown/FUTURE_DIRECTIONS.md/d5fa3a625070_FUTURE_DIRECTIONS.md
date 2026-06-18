# Future Directions: Formal Quantum Topology

This document outlines concrete next steps opened by the formalization of the Kauffman bracket, Jones polynomial, and Reidemeister invariance in a machine-checked proof system.

---

## 1. Reidemeister II Invariance via Planar Arc Models

**Status:** The current formalization proves bracket invariance under RIII (via state bijection) and RI behavior (via sum decomposition). RII invariance requires richer diagram structure.

**Next Step:** Build a concrete planar diagram model using arc-connection data:
- Define `PlanarDiagram` with explicit arc pairings at each crossing
- Derive loop counts computationally from the arc connection graph
- Prove RII invariance by showing the algebraic identity `A²δ + 2 + A⁻²δ = -(A⁴ + A⁻⁴)` cancels correctly when combined with the topology-dependent loop contributions
- This requires tracking how individual loops merge/split under smoothing, not just total loop counts

**Impact:** Completes the full Reidemeister invariance proof for the Jones polynomial. Opens the door to certified knot recognition algorithms.

**Hypothesis:** A planar diagram model with O(n) arc data suffices to derive all Reidemeister invariance proofs from local rewrite rules, without requiring embeddings in surfaces.

---

## 2. Adequacy and the Span Theorem for Alternating Knots

**Status:** The detection theorem (`jones_ne_one_of_adequate`) is stated but requires coefficient-level analysis of Laurent polynomials.

**Next Step:** Build a Laurent polynomial coefficient API:
- Prove `δ^k` has leading coefficient `(-1)^k` at degree `2k`
- Prove the state contribution `T(e) * δ^m` has support in `[e - 2m, e + 2m]`
- Show that for adequate diagrams, the leading coefficient of the bracket comes uniquely from the all-A state
- Derive the Kauffman–Murasugi–Thistlethwaite span formula: `span(⟨D⟩) = 4n` for reduced alternating diagrams with `n` crossings
- Conclude: alternating knots with `n > 0` crossings have `jones ≠ 1`

**Impact:** Machine-verified unknot detection in the alternating class. First formally proved detection theorem in knot theory.

**Proof Strategy:** Induction on `k` for `δ^k` leading coefficient, then finite case analysis over state exponents.

---

## 3. Braid Group Representations and Markov Trace

**Status:** The current formalization uses abstract diagram models. Braids provide a more algebraic entry point.

**Next Step:**
- Define the braid group `B_n` as a finitely presented group (Artin generators with braid relations)
- Define braid closure and prove every link is a closed braid (Alexander's theorem, stated axiomatically)
- Define the Temperley–Lieb algebra `TL_n(δ)` as a quotient of the braid group algebra
- Construct the Jones representation `B_n → TL_n`
- Define the Markov trace on `TL_n` and prove it yields the Jones polynomial
- Prove agreement with the Kauffman bracket on braid closures

**Impact:** Opens quantum algebra formalization: R-matrices, quantum groups, modular tensor categories. Enables certified computation of Jones polynomials for torus knots via braid word evaluation.

**Cross-Domain Connection:** The Temperley–Lieb algebra is the partition function algebra of the Potts model in statistical mechanics. Formalizing it creates a bridge between quantum topology and certified statistical mechanics.

---

## 4. Khovanov Homology as a Categorification

**Status:** The Kauffman bracket is a decategorified invariant (a polynomial). Khovanov homology lifts it to a graded chain complex.

**Next Step:**
- Define the Khovanov chain complex: for each state, assign a graded vector space based on loop count
- Define the differential using merge/split maps between smoothing states
- Prove the graded Euler characteristic equals the Jones polynomial
- Prove Reidemeister invariance of Khovanov homology (as a bigraded group, up to isomorphism)
- Compute Khovanov homology for the trefoil and figure-eight knot

**Impact:** First formal categorification in topology. Khovanov homology detects the unknot (Kronheimer–Mrowka, via gauge theory), so this would be a step toward certified unknot detection algorithms.

**Hypothesis:** The chain complex structure can be defined purely combinatorially in Lean using Mathlib's homological algebra library.

---

## 5. Certified Knot Recognition Pipeline

**Status:** The formalization provides invariant computation (Jones polynomial) but not decision procedures.

**Next Step:**
- Implement Dowker notation and PD code parsers as Lean definitions
- Build a verified bracket evaluator: given a PD code, compute the bracket by state-sum enumeration
- Implement the Reidemeister move search: given two diagrams, search for a sequence of moves connecting them
- Use the Jones polynomial as a first-pass filter: if `jones D₁ ≠ jones D₂`, certify that `D₁` and `D₂` represent different knots
- For alternating knots, use the span theorem to certify unknottedness

**Impact:** First formally verified knot tabulation tool. Could certify knot tables up to ~15 crossings with proof certificates.

**Performance Target:** Bracket evaluation for diagrams with ≤ 20 crossings in < 1 second using compiled Lean code.

---

## Summary Table

| Direction | Difficulty | Dependencies | Impact |
|-----------|-----------|--------------|--------|
| RII via planar models | Medium | New diagram type | Completes invariance |
| Span theorem | Medium | Laurent coeff API | Unknot detection |
| Braid/Markov trace | Hard | Group theory, TL algebra | Quantum algebra |
| Khovanov homology | Very Hard | Homological algebra | Categorification |
| Certified pipeline | Medium | PD code parser, evaluator | Applications |
