# Future Directions: Logarithmic Derivative Level Bound

## Synthesis

The sharp depth bound `depth(deriv(e)) ≤ depth(e)` and the resulting logarithmic derivative level neutrality for pure exponentials establish a **conservation law for differential complexity** in the Hardy hierarchy. This opens five interconnected research directions:

1. **Extending the fragment**: Can the conservation law survive the addition of division, logarithms, and composition? The answer determines whether the Hardy hierarchy is a natural differential-algebraic invariant or merely a syntactic accident of the `PosEMLExpr` grammar.

2. **Iterated stability**: The one-step bound immediately implies multi-step bounds. But does iterated differentiation cause expressions to *simplify* (depth decrease) or merely *preserve* complexity? The answer reveals the *attractor structure* of the differentiation operator on the expression space.

3. **Obstruction classification**: If we extend the expression language, which constructors break depth preservation? A sharp classification would identify the exact boundary of the conservation law.

4. **Riccati flow complexity**: Repeated Riccati iterations `u ↦ u' + u²` model nonlinear ODE flows. Does depth preservation survive these nonlinear operations?

5. **Certified asymptotic computation**: The verified depth analyzer is a prototype for certified symbolic computation. Can we build a full asymptotic-expansion engine with complexity certificates?

---

## Direction 1: Full EML Extension with Division and Logarithms

**Conjecture:** Define `FullEMLExpr` by adding `div`, `log`, and `neg` to `PosEMLExpr`, with `depth(log a) = depth(a)` and `depth(div a b) = max(depth a, depth b)`. Then `depth(deriv(e)) ≤ depth(e) + 1` for all `FullEMLExpr`, and `depth(deriv(e)) ≤ depth(e)` for the sub-fragment excluding `div`.

**Test:** Enumerate `FullEMLExpr` up to depth 4 and size 10. Compute `depth(deriv(e))` and check the bound. If violations occur, classify the minimal obstruction pattern.

**Impact:** Would determine whether the conservation law extends to the full Hardy field or is specific to the exponential-positive fragment. A positive result would be a major structural theorem about Hardy fields.

**Catalog References:** `Catalog/Pythagorean/HardyHierarchy/DiffClosure.lean` (PosEMLExpr.depth_deriv_le), `Catalog/Pythagorean/HardyHierarchy/LogDerivLevel.lean` (depth_deriv_le_self).

**Proof Strategy:** Extend the structural induction. The `div` case `deriv(a/b) = (a'b - ab')/b²` produces a `mul` and `div`; track depth through this. The `log` case `deriv(log a) = a'/a` is a `div`; this is where the `+1` might reappear.

**Domain Bridges:** Differential algebra (Hardy fields are closed under composition with log); transseries (logarithmic monomials form part of the basis).

**Lineage:** Directly extends `depth_deriv_le_self` from this work.

**Ambition:** 🔬 Solid extension — high confidence of partial success; full success would be notable.

---

## Direction 2: Iterated Differentiation and Depth Attractors (Grand Challenge)

**Conjecture:** For every `PosEMLExpr` `e` and every `k ≥ 0`, `depth(deriv^k(e)) ≤ depth(e)`. Moreover, the sequence `k ↦ depth(deriv^k(e))` is eventually constant.

**Test:** For all expressions up to depth 5 and size 8, compute `deriv^k` for `k = 1, ..., 10` (with expression simplification to control size growth). Record the depth sequence and check for eventual constancy.

**Impact:** Would establish that differentiation is not just depth-nonincreasing but generates a *convergent* complexity sequence. The limiting depth is a new invariant — the "differential core depth" of an expression.

**Catalog References:** `Catalog/Pythagorean/HardyHierarchy/LogDerivLevel.lean` (depth_deriv_le_self, deriv_depth_classification).

**Proof Strategy:** The bound `depth(deriv^k(e)) ≤ depth(e)` follows immediately by induction from `depth_deriv_le_self`. The eventual constancy requires a more refined argument: since the sequence is non-increasing and bounded below by 0, it stabilizes. But *when* it stabilizes — and whether the stabilization depth depends only on `depth(e)` or on the full expression structure — is the deeper question.

**Domain Bridges:** Dynamical systems (the differentiation operator as a map on expression space); Noetherian induction (the depth filtration is a well-ordering).

**Lineage:** Builds on `depth_deriv_le_self` and `deriv_depth_classification`.

**Ambition:** 🌟 Grand challenge — the eventual constancy is easy but the characterization of the limiting depth would be paradigm-shifting.

---

## Direction 3: Sharp Obstruction Classification for Extended Fragments

**Conjecture:** If `PosEMLExpr` is extended with a `div` constructor, then `depth(deriv(e)) > depth(e)` can occur, and the minimal obstruction has the form `div (exp a) (exp b)` where `a` and `b` have equal depth and interacting derivatives.

**Test:** Enumerate expressions in the extended language up to depth 3. Find all `(e, deriv(e))` pairs where `depth(deriv(e)) > depth(e)`. Extract the common syntactic pattern.

**Impact:** A sharp obstruction theorem would precisely delineate the boundary of the conservation law. This is arguably more valuable than a blanket positive result — it reveals the *mechanism* by which complexity can increase.

**Catalog References:** `Catalog/Pythagorean/HardyHierarchy/LogDerivLevel.lean` (no_depth_increasing_deriv — for the positive fragment, there are no obstructions).

**Proof Strategy:** Minimal counterexample argument. Assume a depth-increasing expression of minimal size; case-split on the top constructor. Most cases are eliminated by the inductive hypothesis; the surviving case(s) reveal the obstruction pattern. This is Strategy C from the assignment.

**Domain Bridges:** Combinatorics on expression trees; classification theorems in algebra (analogy with classification of finite simple groups — identify the "sporadic" obstructions).

**Lineage:** Extends `no_depth_increasing_deriv` to larger fragments.

**Ambition:** 🔬 Solid extension — likely achievable with systematic enumeration and pattern recognition.

---

## Direction 4: Riccati Flow Complexity (Grand Challenge)

**Conjecture:** For the Riccati operator `R(u) = u' + u²`, if `u` has depth `d`, then `R(u)` has depth at most `d`. That is, the Riccati nonlinearity does not increase Hardy depth.

**Test:** For `u = deriv(b)` with `b : PosEMLExpr` of depth ≤ 3, compute `R(u)` symbolically and check its depth. This requires extending the expression language with squaring (which is `mul u u`, already supported).

**Impact:** Would establish that the **full Riccati transform** — not just the linearization — preserves asymptotic complexity. This would be a foundational theorem for the formal complexity theory of nonlinear ODEs.

**Catalog References:** `Catalog/Pythagorean/HardyHierarchy/LogDerivLevel.lean` (hardyLevel_riccati_ansatz_le, riccati_identity_exp).

**Proof Strategy:** The key is that `u² = (deriv b)²` has depth `max(depth(deriv b), depth(deriv b)) = depth(deriv b) ≤ depth(b)`. And `u' = deriv(deriv b)` has depth `≤ depth(deriv b) ≤ depth(b)`. So `R(u)` has depth at most `depth(b)`. But we need this for *arbitrary* `u`, not just `u = deriv(b)`.

**Domain Bridges:** Nonlinear ODE theory; dynamical systems; WKB transport hierarchies; Painlevé transcendents (which arise from Riccati-type equations).

**Lineage:** Extends `hardyLevel_riccati_ansatz_le` from linear to nonlinear.

**Ambition:** 🌟 Grand challenge — success would create a formal complexity theory for Riccati flows, with immediate applications to mathematical physics.

---

## Direction 5: Certified Asymptotic Expansion Engine

**Conjecture:** A symbolic computation engine can be built that, given a `PosEMLExpr` `e` and a target precision, produces an asymptotic expansion of `eval(e)` as `x → ∞`, together with a formal certificate that (a) the expansion is correct to the stated precision, and (b) each term of the expansion has depth at most `depth(e)`.

**Test:** Implement a prototype engine for depth-0 expressions (polynomials) and depth-1 expressions (exponential polynomials). Verify correctness on standard test cases (e.g., Stirling's approximation, Laplace's method for simple integrals).

**Impact:** Would be the first *certified* symbolic asymptotic computation system. Current CAS (Mathematica, Maple) compute asymptotic expansions heuristically; a certified system would provide mathematical guarantees.

**Catalog References:** `Catalog/Pythagorean/HardyHierarchy/DiffClosure.lean` (DiffClosedFragment, posEMLFragment), `Catalog/Pythagorean/HardyHierarchy/LogDerivLevel.lean` (depthAnalyzer).

**Proof Strategy:** Build on the `DiffClosedFragment` structure. Implement asymptotic expansion as a recursive algorithm on `PosEMLExpr`, using `depth_deriv_le_self` to certify that intermediate computations stay within the correct complexity class. The depth analyzer provides the complexity certificate at each step.

**Domain Bridges:** Computer algebra; certified computation; numerical analysis; applied mathematics.

**Lineage:** Extends `posEMLFragment` and `depthAnalyzer` from this work.

**Ambition:** 🔬 Solid extension — the prototype is achievable; a full engine would be a major software project.
