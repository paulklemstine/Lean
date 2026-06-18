# Future Directions: Spectral Margin Framework for Expression Complexity

## Synthesis

The Controlled-Inverse Depth Hierarchy Theorem establishes that well-conditioned inverses are "spectrally invisible" to the depth hierarchy — they do not increase the poly-tower majorant height. This opens five natural research directions, unified by a single question: **where exactly is the boundary between operations that preserve and operations that break the depth hierarchy?**

The directions below probe this boundary from five angles: relaxing the uniformity condition (Direction 1), moving to tropical algebra (Direction 2), extending to multiple variables (Direction 3), quantifying the critical stability threshold (Direction 4), and connecting to differential operators (Direction 5). Together, they form a systematic exploration of the spectral margin framework's scope and limitations.

Directions 1 and 4 are *grand challenges* — resolving either would fundamentally change our understanding of expression complexity. Directions 2, 3, and 5 are *solid extensions* that build directly on the proven catalog theorems.

---

## Direction 1: Uncontrolled Inverse Collapse Conjecture

**Conjecture:** If inverses are allowed on any nonvanishing expression (|eval(e, x)| > 0 for all x > 0, but no *uniform* lower bound δ > 0), then the depth hierarchy collapses: there exists a depth-D expression with uncontrolled inverses that represents iterExp(D+1, x).

**Test:** Enumerate EML expressions with uncontrolled inverses up to depth 3 and expression size 25. For each, evaluate at test points x ∈ {2, 3, 5, 10, 100, 1000}. Check if any expression with uncontrolled inverses at depth 3 matches iterExp(4, x) within relative error 10⁻⁶. The candidate counterexample is inv(inv(x) + inv(eml(const(1), var))) = 1/(1/x + 1/exp(x)) = x·exp(x)/(x + exp(x)) — test whether compositions of such expressions can achieve super-depth growth.

**Impact:** If true, this would demonstrate that the *uniformity* of the spectral margin (not just nonvanishing) is the essential condition. This would be a fundamental dichotomy result: the line between hierarchy and collapse runs through the distinction between "bounded below" and "merely positive."

**Catalog References:**
- `Pythagorean/ControlledInverseHierarchy/Theorems.lean`: `no_controlledInv_lowDepth_represents_iterExp` — the positive (hierarchy) side
- `Pythagorean/ControlledInverseHierarchy/Defs.lean`: `HasControlledInverses` — the condition to relax

**Proof Strategy:** For the collapse direction, construct explicit expressions. Consider e = inv(const(1) − inv(eml(const(1), var))). As x → ∞, the denominator 1 − 1/exp(x) → 1, so this is controlled. But for the *uncontrolled* case, try building expressions where the denominator approaches zero at rate 1/iterExp(k, x), forcing the inverse to grow as iterExp(k, x).

**Domain Bridges:** Operator theory (Fredholm vs. merely injective operators), numerical analysis (well-conditioned vs. ill-conditioned problems), dynamical systems (uniformly hyperbolic vs. nonuniformly hyperbolic).

**Lineage:** Direct descendant of the Controlled-Inverse Depth Hierarchy Theorem.

**Ambition:** Grand challenge — paradigm-shifting if resolved in either direction.

---

## Direction 2: Tropical Spectral Margin and Tropical Depth Hierarchy

**Conjecture:** In the tropical semiring (min-plus algebra), define the tropical EML language where multiplication becomes addition, addition becomes min, and exp becomes the identity. Define tropical spectral margin as the infimum of tropical evaluation over positive reals. Then: tropical expressions with positive tropical spectral margin satisfy a depth hierarchy analogous to the classical case.

**Test:** Implement tropical EML evaluation. Enumerate tropical expressions up to depth 4 and size 20. Verify that no tropical expression of depth D with controlled tropical inverses (tropical inversion = negation, controlled = bounded from below) can match tropical-iterExp(D+1, x) = x + x + ... + x (D+1 times in tropical sense, which is just x in min-plus).

**Impact:** Would establish a tropical analogue of the depth hierarchy, connecting expression complexity to tropical geometry and polyhedral combinatorics.

**Catalog References:**
- `Pythagorean/ControlledInverseHierarchy/Theorems.lean`: the classical depth hierarchy
- `Pythagorean/ControlledInverseHierarchy/Defs.lean`: definitions to tropicalize

**Proof Strategy:** The tropical analogue of iterExp is simpler (iterated addition in the min-plus sense). The proof should follow the same poly-tower majorant strategy, with tropical tower majorants being piecewise-linear functions.

**Domain Bridges:** Tropical geometry, polyhedral combinatorics, optimal transport.

**Lineage:** Tropical deformation of the Controlled-Inverse Depth Hierarchy.

**Ambition:** Solid extension — builds directly on proven techniques.

---

## Direction 3: Multivariate Spectral Margin on the Positive Orthant

**Conjecture:** For multivariate EML expressions e : ℝⁿ → ℝ, if spectralMargin(e) > 0 on the positive orthant ℝ₊ⁿ (meaning |eval(e, x₁, ..., xₙ)| ≥ δ > 0 for all xᵢ > 0), then the depth hierarchy persists: controlled-inverse multivariate EML expressions of depth D cannot represent multivariate iterExp functions of depth > D.

**Test:** Implement multivariate EML evaluation for n = 2, 3. Generate random multivariate expressions with controlled inverses up to depth 3. Test whether any can match bivariate iterExp(4, x₁, x₂) := exp(exp(exp(exp(x₁ + x₂)))) on a grid of positive test points.

**Impact:** Would extend the spectral margin framework to the multivariate setting, which is essential for applications to multi-input circuits and neural networks.

**Catalog References:**
- `Pythagorean/ControlledInverseHierarchy/Theorems.lean`: `controlledInv_hasPolyTowerMajorant` — to generalize
- `Pythagorean/ControlledInverseHierarchy/Defs.lean`: definitions to extend

**Proof Strategy:** Define multivariate poly-tower majorants: |eval(e, x)| ≤ iterExp(k, C · (x₁^N₁ + ... + xₙ^Nₙ)). The structural induction should carry over, with the key insight being that the inverse bound |inv(e)| ≤ 1/δ is dimension-independent.

**Domain Bridges:** Multivariable complex analysis, algebraic geometry, neural network expressivity.

**Lineage:** Direct multivariable generalization of the Controlled-Inverse Depth Hierarchy.

**Ambition:** Solid extension — the core proof technique transfers.

---

## Direction 4: Condition Number Threshold Conjecture

**Conjecture:** There exists a critical condition number function κ*(D) such that:
- If all inverses in a depth-D expression have κ < κ*(D), the depth hierarchy holds.
- If some inverse has κ > κ*(D), the depth hierarchy *might* be broken.

Moreover, κ*(D) is finite for all D ≥ 1.

**Test:** For D = 1, 2, 3, perform binary search on κ. Generate expressions of depth D with a single inverse whose condition number is κ. For each κ, check whether the expression can eventually dominate iterExp(D+1, x) by evaluating at exponentially spaced test points. Record the largest κ for which the hierarchy provably holds and the smallest κ for which it empirically fails.

**Impact:** Would quantify exactly how much ill-conditioning is tolerable before the depth hierarchy breaks. This would be a quantitative refinement of the qualitative controlled-inverse theorem.

**Catalog References:**
- `Pythagorean/ControlledInverseHierarchy/Theorems.lean`: `spectral_margin_condition_number` — the qualitative bound
- `Pythagorean/ControlledInverseHierarchy/Defs.lean`: `spectralMargin` — to relate to κ

**Proof Strategy:** For the lower bound on κ*, show that condition numbers up to κ*(D) can be absorbed into the poly-tower majorant constants. For the upper bound, construct explicit expressions exploiting large condition numbers.

**Domain Bridges:** Numerical analysis (condition number theory), random matrix theory (spectral edge statistics), information theory (channel capacity under noise).

**Lineage:** Quantitative refinement of the Controlled-Inverse Depth Hierarchy.

**Ambition:** Grand challenge — would establish a phase transition in expression complexity.

---

## Direction 5: Differential Closure and Depth Stability

**Conjecture:** If e is a controlled-inverse EML expression of depth D, then its derivative e' (with respect to x) is also a controlled-inverse expression of depth D (possibly with different spectral margins). That is, differentiation preserves the depth class for controlled-inverse expressions.

**Test:** Symbolically differentiate EML expressions of depth 1-3 with controlled inverses. Check whether the derivatives have the same depth and whether new inverses introduced by the quotient rule maintain positive spectral margins. Test on 100 random expressions per depth level.

**Impact:** Would show that the controlled-inverse depth hierarchy is closed under differentiation, connecting to the theory of Hardy fields (which are closed under differentiation) and differential algebra.

**Catalog References:**
- `Pythagorean/ControlledInverseHierarchy/Theorems.lean`: `controlledInv_hasPolyTowerMajorant` — the growth bound to preserve
- `Pythagorean/ControlledInverseHierarchy/Defs.lean`: `HasControlledInverses` — to verify for derivatives

**Proof Strategy:** The derivative of eml(a, b) = a·exp(b) is (a'·exp(b) + a·b'·exp(b)) = eml(a' + a·b', b), which has the same depth. The derivative of inv(a) = −a'/a², introducing inv(mul(a,a)). If spectralMargin(a) ≥ δ, then spectralMargin(mul(a,a)) ≥ δ², so the inverse remains controlled.

**Domain Bridges:** Hardy fields, differential algebra, dynamical systems (Liouville theory), D-modules.

**Lineage:** Extension of the Controlled-Inverse Depth Hierarchy to the differential setting.

**Ambition:** Solid extension — uses the structural induction technique with a new operation.
