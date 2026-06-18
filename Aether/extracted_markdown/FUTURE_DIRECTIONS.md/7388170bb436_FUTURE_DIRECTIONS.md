# Future Directions: Depth Stability in the Hardy Hierarchy

## Synthesis

The depth stability theorem — that differentiation of PosEMLExpr does not increase Hardy depth — opens a systematic program connecting differential algebra, tropical geometry, and asymptotic analysis through the unifying lens of the Hardy hierarchy. The five directions below form a coherent research arc: Direction 1 extends the algebraic fragment to include logarithms; Direction 2 lifts syntactic depth stability to semantic Hardy level stability; Direction 3 explores compositional closure for automated WKB solvers; Direction 4 connects to tropical algebraic geometry for potential applications in optimization; and Direction 5 probes the boundaries by seeking counterexamples in signed expressions. Together, they chart a path from a single structural theorem to a comprehensive theory of complexity-preserving operations in differential algebra.

---

## Direction 1: Logarithmic Extension — Depth Stability for LogEMLExpr

**Conjecture:** Define LogEMLExpr by extending PosEMLExpr with a `log` constructor, where depth(log(f)) = max(depth(f) - 1, 0). Then depth stability holds: depth(deriv(b)) ≤ depth(b) for all LogEMLExpr b. The critical case is deriv(log(f)) = deriv(f) / f, which should satisfy depth(deriv(f)/f) ≤ depth(log(f)) = max(depth(f) - 1, 0).

**Test:** Implement LogEMLExpr in Lean with the log constructor. Enumerate all LogEMLExpr of depth ≤ 3 with a single variable. For each, compute deriv symbolically and verify depth(deriv) ≤ depth. If a counterexample is found, identify the minimal failing expression. The most likely failure point is log(exp(f)) where normalization may be needed.

**Impact:** Establishing depth stability for the log-exp fragment would cover the full Hardy field operations, providing a complete complexity theory for transseries differentiation. This would directly enable certified computer algebra systems for asymptotic expansion.

**Catalog References:**
- `Pythagorean/HardyHierarchy/DiffClosure.lean` — PosEMLExpr definitions and depth_deriv_le
- `Pythagorean/HardyHierarchy/DepthStability.lean` — depth_deriv_le_self (this work)
- `MachineLearning/HardyHierarchy/Defs.lean` — EmlExpr with neg but no log

**Proof Strategy:** Structural induction on LogEMLExpr. The log case requires showing depth(add(mul(deriv(f), inv(f)))) ≤ max(depth(f) - 1, 0). This needs a sub-lemma that depth(inv(f)) ≤ depth(f) for appropriate definitions of syntactic inversion.

**Domain Bridges:** Differential algebra ↔ Computer algebra ↔ Asymptotic analysis

**Lineage:** Direct extension of depth_deriv_le_self (this work)

**Ambition:** ★★★☆☆ (Moderate — extends existing framework with one new constructor)

---

## Direction 2: Semantic Depth Stability — Hardy Level Preservation Under Analytic Differentiation

**Conjecture:** If a smooth function f : ℝ → ℝ has Hardy level n (in the inductive HardyLevel sense), then its analytic derivative f' also has Hardy level n. That is, HardyLevel n f → HardyLevel n (deriv f). This lifts our syntactic result to a purely semantic statement about functions, independent of their syntactic representation.

**Test:** For n = 0 (polynomial growth functions), verify that the derivative also has polynomial growth. This is already established by hardyLevel_zero_poly_bound combined with the fact that derivatives of polynomially-bounded smooth functions have polynomial growth (requires growth bounds on derivatives). For n = 1, verify that derivatives of functions in Hardy level 1 remain in Hardy level 1 by checking specific examples: deriv(x · exp(x)) = (1 + x) · exp(x) ∈ HardyLevel 1.

**Impact:** This would be a deep result in the theory of Hardy fields, showing that the Hardy level filtration is a differential filtration. It would connect our syntactic work to the classical theory of Hardy fields and transseries, potentially providing new tools for asymptotic analysis.

**Catalog References:**
- `Speculative/HardyHierarchy/Theorems.lean` — HardyLevel inductive definition
- `Pythagorean/HardyHierarchy/DepthStability.lean` — syntactic depth stability

**Proof Strategy:** The key difficulty is the `congr` constructor: if f is eventually equal to a Hardy level n function, its derivative may not be eventually equal to a Hardy level n derivative (since eventually equal functions can have different derivatives). This may require additional regularity hypotheses. Strategy: restrict to functions that are *representable* as EML expressions, leveraging our syntactic result via the embedding.

**Domain Bridges:** Real analysis ↔ Model theory (o-minimal structures) ↔ Differential algebra

**Lineage:** Semantic lift of depth_deriv_le_self; builds on hardyLevel_of_depth

**Ambition:** ★★★★★ (Grand challenge — requires bridging syntax and semantics of Hardy fields)

---

## Direction 3: Compositional Depth Stability and Automated WKB Solvers

**Conjecture:** If IsDepthStable(f) and IsDepthStable(g), and we define composition comp(f, g) as the PosEMLExpr obtained by substituting g for var in f, then IsDepthStable(comp(f, g)). Furthermore, depth(comp(f, g)) = depth(f) + depth(g) · (max exponential nesting of var occurrences in f).

**Test:** Implement syntactic composition for PosEMLExpr. Enumerate all pairs (f, g) with depth(f), depth(g) ≤ 2. For each, compute comp(f, g), its derivative, and verify depth(deriv(comp(f, g))) ≤ depth(comp(f, g)). The chain rule deriv(comp(f, g)) = comp(deriv(f), g) · deriv(g) introduces a product that could potentially increase depth.

**Impact:** Compositional depth stability would enable automated WKB solvers: given an ODE y'' + Q(x)y = 0 where Q is a PosEMLExpr, automatically compute the WKB approximation y ≈ Q^{-1/4} exp(∫√Q) with guaranteed depth bounds on all intermediate expressions. This has direct applications in semiclassical quantum mechanics and wave propagation.

**Catalog References:**
- `Pythagorean/HardyHierarchy/DepthStability.lean` — depth_deriv_le_self, riccati_depth_bound
- `Pythagorean/HardyHierarchy/DiffClosure.lean` — logDeriv_mul_exp

**Proof Strategy:** Define comp by structural induction (substitution). The chain rule gives deriv(comp(f, g)) in terms of comp(deriv(f), g) and deriv(g). Use depth_deriv_le_self on f and g separately, then bound the depth of the composed derivative.

**Domain Bridges:** Computer algebra ↔ Quantum mechanics ↔ Control theory

**Lineage:** Extension of depth_deriv_le_self to compositional setting

**Ambition:** ★★★★☆ (High — composition introduces multiplicative depth interactions)

---

## Direction 4: Tropical Depth and Optimization — The Maslov Dequantization Bridge

**Conjecture:** The tropicalization functor trop : PosEMLExpr → TropicalExpr preserves not just depth but the full *filtration structure*: the induced map on depth-d fragments is an isomorphism of depth-filtered algebras. Furthermore, tropical depth stability (tropical_deriv_depth_le) has applications to complexity bounds in tropical optimization: the sensitivity of a tropical polynomial's optimal value to parameter perturbations is bounded by the tropical depth.

**Test:** Implement tropical evaluation (interpreting add as max, mul as +, scale as identity) and compare the asymptotic behavior of eval(e, x) as x → ∞ with the tropical evaluation tropEval(trop(e), x). Verify that for all PosEMLExpr of depth ≤ 3, the leading asymptotic term of log(eval(e, x)) agrees with tropEval(trop(e), x). Compute the tropical derivative of 100 random tropical expressions and verify depth stability.

**Impact:** Connecting Hardy depth to tropical complexity would bridge classical analysis with combinatorial optimization. In the Maslov dequantization framework, the "classical" world (standard arithmetic) is the "quantum" version and the tropical world is the "classical limit." Depth stability in both worlds would suggest a universal complexity principle.

**Catalog References:**
- `Pythagorean/HardyHierarchy/DepthStability.lean` — tropical_deriv_depth_le, tropical_depth_stability_equiv
- `Catalog/Tropical/` — existing tropical geometry formalizations

**Proof Strategy:** Define a tropical evaluation function and prove that trop commutes with evaluation in the asymptotic limit (Maslov dequantization theorem). Then lift depth stability from the classical world to the tropical world via this correspondence.

**Domain Bridges:** Tropical geometry ↔ Optimization ↔ Statistical mechanics (Maslov dequantization)

**Lineage:** Extension of tropical_depth_stability_equiv to semantic level

**Ambition:** ★★★★★ (Grand challenge — connects three major mathematical areas)

---

## Direction 5: Boundary Probing — Counterexamples in Signed Expressions

**Conjecture:** Depth stability FAILS for the full EMLExpr (with negation) when cancellation effects are considered. Specifically, there exists an EMLExpr e such that the *simplified* derivative has higher depth than e. The failure mechanism: if e = add(exp(f), neg(exp(f))) = 0 (exact cancellation), then depth(e) should semantically be 0, but deriv(e) = add(mul(deriv(f), exp(f)), neg(mul(deriv(f), exp(f)))) which also cancels but has syntactic depth > 0.

**Test:** Enumerate EMLExpr (with neg) of depth ≤ 2. For each, compute deriv symbolically, then apply a normalizer (from DerivativeNormalizer.lean) to simplify. Check if any normalized derivative has higher depth than the normalized original. Focus on expressions with cancellation patterns like a + (-a). If no counterexample is found at depth 2, extend to depth 3.

**Impact:** Finding a counterexample would precisely delineate the boundary of depth stability: it holds for the positive fragment but fails for signed expressions. This would motivate the study of "signed depth" — a refined complexity measure that accounts for cancellation. Alternatively, proving depth stability for the full signed case would be a significant strengthening.

**Catalog References:**
- `MachineLearning/HardyHierarchy/Defs.lean` — EmlExpr with neg constructor
- `Pythagorean/HardyHierarchy/DerivativeNormalizer.lean` — expression normalization
- `Pythagorean/HardyHierarchy/DepthStability.lean` — depth_deriv_le_self for positive fragment

**Proof Strategy:** If a counterexample exists, formalize it as a Lean theorem `¬ ∀ e : EmlExpr, depth(deriv(e)) ≤ depth(e)` with a concrete witness. If no counterexample exists, prove depth stability for EmlExpr by extending the structural induction to handle the neg case.

**Domain Bridges:** Algebra (cancellation theory) ↔ Complexity theory ↔ Differential algebra

**Lineage:** Boundary analysis of depth_deriv_le_self

**Ambition:** ★★☆☆☆ (Focused — concrete computational search with clear outcome)
