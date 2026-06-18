# Future Directions: Tropical Substitution Fractals

## Overview

This document outlines breakthrough research opportunities opened by the formalization
of dragon curve iteration as min-plus (tropical) recursion. The core result — that
reachable states of the dragon substitution system are exactly the zero set of a
tropically-defined potential — establishes a new bridge between symbolic dynamics,
tropical algebra, and fractal geometry. The following directions are specific enough
for a research team to pursue with clear hypotheses, proof strategies, and
cross-domain connections.

---

## Direction 1: Tropical Substitution Curves Beyond the Dragon

**Hypothesis:** Every binary substitution system on a lattice with finitely many
orientations admits a min-plus potential characterization of its reachable set,
generalizing our dragon curve theorem.

**Specific Targets:**
- **Twin Dragon:** The twin dragon arises from the same `1+i` scaling but uses
  both digit choices simultaneously. Formalize the twin dragon as a two-branch
  substitution and prove that its boundary (the "twindragon tile boundary") has
  a tropical potential encoding. The key difference is that collisions between
  branches become nontrivial.
- **Terdragon:** A ternary substitution (three successor maps instead of two) on
  a hexagonal lattice (Fin 6 orientations). The min-plus recursion becomes
  `tropPot(n+1, s) = min(tropPot(n, A⁻¹s), tropPot(n, B⁻¹s), tropPot(n, C⁻¹s))`.
  Prove the analogous reachability theorem.
- **Paper-Folding Curves:** The regular paper-folding sequence generates a family
  of space-filling curves. Prove that the entire family admits tropical generation,
  parametrized by the folding direction sequence.
- **Rauzy Fractals:** These arise from Pisot substitutions and live in higher-dimensional
  lattices. They are the natural generalization of dragon tiles to non-binary alphabets.
  Formalize the tropical potential for the Tribonacci Rauzy fractal.

**Proof Strategy:** Abstract the key lemma structure (bijective step maps,
min-plus recursion, zero-set characterization) into a general framework
`SubstitutionTropical` parametrized by the number of branches, lattice dimension,
and orientation group.

**Cross-Domain Connections:** Symbolic dynamics, numeration systems (balanced
representations in algebraic number fields), automatic sequences.

---

## Direction 2: Dimension Transfer Theorems

**Hypothesis:** The discrete Minkowski dimension of tropically-generated lattice
approximants equals the Hausdorff dimension of the corresponding limit set, under
natural regularity conditions (open set condition, bounded distortion).

**Specific Targets:**
- Prove that if `|occupiedCells(n)| ~ C · r^n` and `diameter(occupiedCells(n)) ~ D · r^{n/d}`
  for constants `C, D, r, d`, then the box-counting dimension of the limit set is `d`.
- For the dragon curve specifically: prove `|reachable(n)| = 2^n` (requiring an
  injectivity theorem for the step maps on reachable sets) and diameter growth
  `~ 2^{n/2}`, yielding discrete dimension 2.
- Formalize the passage from box-counting dimension to Hausdorff dimension using
  the equivalence for self-similar sets satisfying the open set condition.

**Key Technical Challenge:** The injectivity theorem — showing that distinct
paths in the binary tree yield distinct dragon states — requires careful
lattice arithmetic. The Gaussian integer model (representing positions as
elements of ℤ[i]) may simplify this by encoding the substitution as
multiplication by `1+i`.

**Proof Strategy:**
1. Prove injectivity of the path-to-state map by induction, using the quarter-turn
   structure to separate cases.
2. Establish diameter bounds via the spectral radius of the substitution matrix
   `[[1,-1],[1,1]]` (eigenvalues `1±i`, modulus `√2`).
3. Connect to Mathlib's measure theory for the final dimension statement.

---

## Direction 3: Tropical Entropy of Substitution Systems

**Hypothesis:** The topological entropy of a substitution dynamical system equals
the tropical growth rate of its min-plus potential, defined as
`lim_{n→∞} (1/n) · log(|{s : tropPot(n, s) = 0}|)`.

**Specific Targets:**
- For the dragon system: entropy = log 2 (since |reachable(n)| = 2^n, assuming
  injectivity).
- For the terdragon: entropy = log 3.
- Formalize the notion of "tropical entropy" as a tropical analogue of pressure
  in thermodynamic formalism.
- Prove that tropical entropy is invariant under tropical conjugacy (min-plus
  linear change of coordinates).

**Cross-Domain Connections:**
- Thermodynamic formalism: the tropical potential is a zero-temperature limit
  of a Gibbs measure.
- Ergodic theory: entropy of substitution shifts.
- Information theory: compression rates of substitution sequences.

---

## Direction 4: Certified Algorithms for Fractal Membership and Rendering

**Hypothesis:** The tropical potential provides a polynomial-time certificate
for membership in dragon curve approximants, enabling formally verified
fractal rendering.

**Specific Targets:**
- Implement a verified `O(n)` algorithm for deciding `s ∈ reachable(n)` by
  evaluating `tropPot(n, s)` via the recursion. The recursion traces back
  through inverse maps, requiring O(n) steps.
- Prove correctness: the algorithm returns `true` if and only if `tropPot(n,s) = 0`.
- Implement verified rendering: given a bounding box and resolution, enumerate
  all reachable states within the box and output pixel coordinates.
- Prove that the rendering is exact (no false positives or negatives for the
  discrete approximant).
- Extend to anti-aliased rendering by using weighted tropical potentials
  (values in ℝ instead of {0,1}).

**Complexity Analysis:** Membership in `reachable(n)` is decidable in O(n) time
and O(1) space (just trace inverses). Enumeration of all 2^n states takes O(2^n)
time but can be parallelized perfectly (each leaf of the binary tree is independent).

**Applications:** Verified computer graphics, exact symbolic computation with
fractals, certified mathematical visualization.

---

## Direction 5: Tropical Automata and Universality Classification

**Hypothesis:** The class of limit sets generated by tropical substitution
recursions (iterated min-plus affine maps on lattices) forms a proper subclass
of self-affine tiles, strictly between the class of dragon-type curves and the
class of all space-filling curves.

**Specific Targets:**
- Define "tropical substitution fractals" formally as limit objects of
  sequences `{s : tropPot(n,s) = 0}` under appropriate rescaling.
- Prove that every self-similar tile with a digit set and expanding matrix
  admits a tropical substitution fractal representation.
- Prove that not every self-affine tile does (the affine case requires
  different branch scalings, which may break the min-plus structure).
- Classify which space-filling curves arise as tropical limits:
  - Hilbert curve: YES (binary substitution on a square lattice with 4 orientations)
  - Peano curve: YES (ternary substitution)
  - Lebesgue/Z-order curve: YES (binary, axis-aligned)
  - General continuous surjections [0,1] → [0,1]²: NO (our counterexample)
- Formalize a "tropical automaton" as a finite-state machine operating over
  the min-plus semiring, and show that dragon-type substitutions are exactly
  the deterministic tropical automata with bijective transitions.

**Cross-Domain Connections:**
- Automata theory (weighted automata over semirings)
- Tiling theory (Thurston's characterization of expanding maps)
- Computational complexity (membership complexity as a function of automaton size)

**Revolutionary Potential:** This direction would create a new classification
theory for fractal objects based on their tropical algebraic complexity, analogous
to the Chomsky hierarchy for formal languages.
