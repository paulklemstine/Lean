# Future Directions: Perfect Cuboid Formalization Program

## Overview

Building on the formally verified foundations established here—primitive reduction, parity/modular obstructions, rational surface reduction, and infinite Euler brick families—we identify five precise, testable hypotheses that constitute the next frontier of this research program.

---

### 1. Residue Obstruction Hypothesis (Mod-105 Sieve)

**Hypothesis:** Every primitive perfect cuboid triple `(x, y, z)` satisfying the two-even-one-odd constraint violates at least one congruence condition modulo `M = 105 = 3 × 5 × 7`, beyond the mod-4 and mod-8 obstructions already proved.

**Test:** Enumerate all residue classes `(x, y, z) mod 105` with exactly two even and one odd coordinate, check whether `x² + y²`, `x² + z²`, `y² + z²`, and `x² + y² + z²` are all quadratic residues mod 105 simultaneously. If no valid residue class survives, the obstruction is total at this modulus.

**Possible outcome if true:** This would eliminate all solutions modulo 105, proving nonexistence of primitive perfect cuboids in residue classes covering a large fraction of all integers. Combined with the Chinese Remainder Theorem and the mod-4/mod-8 results, this could provably reduce the search space by a factor exceeding 10⁶.

**Possible outcome if false:** Some residue classes survive, but the count gives a sharp upper bound on the density of potential perfect cuboids. Each surviving class becomes a concrete target for higher-modulus sieves or descent arguments.

---

### 2. Surface Parametrization Hypothesis

**Hypothesis:** The affine surface `w² = u² + v² - 1` with the additional constraints that `u² - 1` and `v² - 1` are both rational squares admits a 2-parameter birational map from ℚ² that generates a Zariski-dense family of rational points. Specifically, there exists a rational map `(s, t) ↦ (u(s,t), v(s,t), w(s,t))` such that `u(s,t)² - 1` and `v(s,t)² - 1` are identically perfect squares in ℚ(s,t).

**Test:** Derive candidate parametrizations by fixing one variable and solving the resulting conic. Verify the surface equation symbolically in a computer algebra system. Formalize the algebraic identity in Lean and check that the square constraints are satisfied generically (not just at isolated points).

**Possible outcome if true:** This would provide an explicit two-parameter family of candidate perfect cuboid configurations over ℚ, reducing the problem to finding integer points in this family. The parametrization would interface directly with the Hasse-Minkowski theorem and local-global analysis.

**Possible outcome if false:** The surface has geometric obstructions (e.g., Brauer-Manin obstruction, genus considerations) that prevent dense rational parametrization. This would itself be a significant result, connecting the perfect cuboid problem to the Shafarevich-Tate group or higher obstruction theory.

---

### 3. Near-Miss Infinitude Hypothesis

**Hypothesis:** There are infinitely many Euler bricks `(x, y, z)` for which the space diagonal satisfies `|x² + y² + z² - d²| ≤ 1` for some integer `d`. More precisely, within the Saunderson parametric family `(u(4v²-w²), v(4u²-w²), 4uvw)` for Pythagorean triples `(u,v,w)`, the proportion of triples with space diagonal gap ≤ ε is Ω(ε^α) for some `α > 0`.

**Test:** Compute the space diagonal gap for all Saunderson Euler bricks generated from Pythagorean triples with hypotenuse ≤ 10⁶. Fit the empirical distribution of gaps. Formalize the family construction and prove the gap bound for the first N cases.

**Possible outcome if true:** An infinite near-miss family would provide strong heuristic evidence that perfect cuboids "almost" exist, and would quantify exactly how close the Diophantine system comes to having solutions. The growth rate α would connect to Diophantine approximation theory.

**Possible outcome if false:** Near-misses become exponentially rare, suggesting a deep arithmetic obstruction beyond modular constraints. This would motivate p-adic or adelic analysis of the cuboid equations.

---

### 4. Elliptic Fibration Slice Hypothesis

**Hypothesis:** Fixing one normalized face parameter `u₀ = a/x` in the cuboid surface `w² = u₀² + v² - 1` (with `v² - 1` a rational square) reduces to an elliptic curve of positive Mordell-Weil rank for infinitely many rational values `u₀`. Specifically, setting `v = (t² + 1)/(2t)` (parametrizing `v² - 1 = ((t² - 1)/(2t))²`), the equation `w² = u₀² + ((t² + 1)/(2t))² - 1` defines an elliptic curve in `(t, w)` whose rank is positive when `u₀` corresponds to a known Euler brick face ratio.

**Test:** Derive the Weierstrass form of the slice curve for `u₀ = 125/44` (from the smallest Euler brick). Compute its rank using Sage or Magma. If the rank is positive, find an explicit rational point and check whether it yields a perfect cuboid.

**Possible outcome if true:** Each positive-rank slice would contain infinitely many rational points on the cuboid surface, dramatically narrowing the search. The locus of positive-rank slices would define a moduli problem connecting to the arithmetic of elliptic curves.

**Possible outcome if false:** All slices have rank 0 or are torsion-only, meaning the surface has no elliptic pencil with infinitely many sections. This would be evidence for the non-existence of perfect cuboids via the geometry of the surface.

---

### 5. No Perfect Cuboid in Saunderson Family Hypothesis

**Hypothesis:** No Euler brick in the Saunderson family `(u(4v²-w²), v(4u²-w²), 4uvw)` for any Pythagorean triple `(u, v, w)` is a perfect cuboid. That is, `u²(4v²-w²)² + v²(4u²-w²)² + 16u²v²w²` is never a perfect square when `u² + v² = w²`.

**Test:** First, verify computationally for all Pythagorean triples with hypotenuse ≤ 10⁸. Then attempt a formal proof by analyzing the expression modulo small primes (3, 5, 7, 11) and showing the resulting residue constraints are unsatisfiable. Alternatively, show the expression factors in a way that prevents it from being a perfect square via descent.

**Possible outcome if true:** This would formally eliminate the most classical parametric family of Euler bricks from containing a perfect cuboid. Combined with analogous results for other known families, it would show that perfect cuboids (if they exist) must arise from fundamentally different constructions.

**Possible outcome if false:** A counterexample Pythagorean triple `(u,v,w)` yielding a perfect cuboid would resolve the centuries-old open problem. The discovery would immediately generate intense interest in the arithmetic structure of the specific triple.

---

## Priority Ranking

1. **Residue obstruction (Hypothesis 1)**: Most immediately tractable; builds directly on the mod-4/mod-8 machinery already formalized.
2. **No-solution-in-family (Hypothesis 5)**: Concrete and falsifiable; computationally testable before formal proof.
3. **Near-miss infinitude (Hypothesis 3)**: Mixes computation with formalization; good for building intuition.
4. **Elliptic fibration (Hypothesis 4)**: Requires CAS computation but opens the deepest mathematical connections.
5. **Surface parametrization (Hypothesis 2)**: Most ambitious; success here would transform the field.

## Technical Prerequisites

- Higher-modulus modular arithmetic in Lean (ZMod, Chinese Remainder Theorem formalization)
- Elliptic curve rank computation interface (possibly via external oracle)
- Formalized Pythagorean triple parametrization theory
- Rational point counting on algebraic surfaces
- Interface between computational search certificates and formal proofs
