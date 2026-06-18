# Future Directions: Depth Preservation and Differential Complexity

## Synthesis

The discovery that `depth(deriv(e)) ≤ depth(e)` for all PosEML expressions — strictly improving the previous `+1` bound — opens a program of investigation into when and how differentiation preserves algebraic complexity measures. The depth filtration is now established as a differential filtration (each level is closed under derivation), but this raises three immediate questions: (1) does this extend to richer expression languages? (2) can we extract *semantic* depth reduction, not just syntactic preservation? (3) what are the implications for automated theorem proving about growth rates?

The directions below range from solid extensions of the current result (extending the grammar, bounding size growth) to paradigm-shifting conjectures about whether depth preservation characterizes a fundamental property of exp-log algebras.

---

## Direction 1: Depth Preservation for Full EML with Negation

**Conjecture:** For the full EML grammar (including `neg(a)` and the `eml(a, b) = a * exp(b)` constructor), `emlDepth(deriv(e)) ≤ emlDepth(e)` holds, where the derivative is extended appropriately.

**Test:** Extend `PosEMLExpr.deriv` to `EmlExpr.deriv` (handling `neg` and `eml` cases) and verify the depth bound by structural induction. Computationally, enumerate EmlExpr up to depth 4 and check.

**Impact:** Would extend the differential closure result from a fragment to the full EML language, unifying the theory.

**Catalog References:** `Catalog/Pythagorean/HardyHierarchy/DiffClosure.lean` (PosEMLExpr), `Catalog/MachineLearning/HardyHierarchy/Defs.lean` (EmlExpr definition).

**Proof Strategy:** The `neg` case should be trivial (negation doesn't change depth). For `eml(a, b) = a * exp(b)`, the derivative is `a' * exp(b) + a * b' * exp(b) = (a' + a * b') * exp(b)`, which has the same depth structure. Apply the same inductive argument.

**Domain Bridges:** Differential algebra (full EML is closer to a Hardy field fragment), symbolic computation (full language support).

**Lineage:** Direct extension of `depth_deriv_le_self`.

**Ambition:** Solid extension — high confidence of success.

---

## Direction 2: Semantic Depth Reduction via Normalization

**Conjecture:** There exists a normalizer `normalize : PosEMLExpr → PosEMLExpr` such that `eval(normalize(e)) = eval(e)` eventually and `depth(normalize(deriv(e))) < depth(e)` for a nontrivial class of expressions (e.g., `exp(const(c))` whose derivative is essentially a constant).

**Test:** Implement a normalizer that applies algebraic simplifications (e.g., `const(0) * e → const(0)`, `exp(const(c))` → `const(exp(c))`). Check whether depth actually *decreases* after normalization for various test expressions.

**Impact:** Would show that differentiation not only preserves but can *reduce* complexity when combined with normalization — a stronger result with implications for certified computer algebra.

**Catalog References:** `Catalog/Pythagorean/HardyHierarchy/DerivativeNormalizer.lean`, `Catalog/Pythagorean/HardyHierarchy/DepthSharpness.lean`.

**Proof Strategy:** Define a constant-folding + dead-branch-elimination normalizer. Prove `depth(normalize(e)) ≤ depth(e)` first, then identify the class where strict inequality holds (expressions with "dead" exponentials whose arguments are constant or whose multiplicative factors are zero).

**Domain Bridges:** Compiler optimization (dead code elimination), symbolic computation (simplification strategies).

**Lineage:** Builds on `depth_deriv_le_self` and connects to normalizer work.

**Ambition:** Solid extension with novel definition required.

---

## Direction 3: Size Growth Bounds Under Iterated Differentiation

**Conjecture:** For any PosEML expression `e`, `size(deriv^n(e)) ≤ (2 * size(e))^(2^n)`, and this bound is essentially tight.

**Test:** Compute `size(deriv^n(e))` for `e = exp(exp(x))` and `e = mul(exp(x), exp(x))` for `n = 0, ..., 8`. Fit the growth to double-exponential and single-exponential models. Check whether simplification reduces the growth to polynomial or single-exponential.

**Impact:** Would quantify the "cost" of differentiation in terms of expression *size* (as opposed to depth, which we've shown is free). Essential for practical symbolic computation systems.

**Catalog References:** `Catalog/Pythagorean/HardyHierarchy/DepthSharpness.lean` (depth preservation provides the depth component).

**Proof Strategy:** The product rule produces `add(mul(deriv(a), b), mul(a, deriv(b)))`, roughly doubling the size at each mul node. Trace the size recurrence through the expression tree. For simplified derivatives, the growth should be slower due to constant folding.

**Domain Bridges:** Computational complexity (circuit size), automatic differentiation (tape length), symbolic computation (expression swell).

**Lineage:** Complements the depth result with size analysis.

**Ambition:** Solid extension — the upper bound should be provable; tightness requires more work.

---

## Direction 4: Depth Preservation as a Characterization of Exp-Polynomial Algebras (Grand Challenge)

**Conjecture:** The PosEML grammar is the *largest* natural expression class (in terms of expressiveness) for which `depth(deriv(e)) ≤ depth(e)` holds. Adding any of the following breaks depth preservation: (a) general composition `f ∘ g`, (b) inverse functions, (c) iterated exponentials as a primitive.

**Test:** Define extended grammars with composition or functional inverse. Construct explicit counterexamples where depth increases under differentiation. For (c), consider `iterexp(n, a)` as a primitive with `depth(iterexp(n, a)) = n + depth(a)` and check whether `deriv(iterexp(n, a))` exceeds this depth.

**Impact:** Would characterize the depth preservation property as a *defining feature* of exp-polynomial algebras, explaining why this grammar is natural from a differential-algebraic perspective. This would be a foundational result connecting syntax, semantics, and differential algebra.

**Catalog References:** `Catalog/Pythagorean/HardyHierarchy/DepthSharpness.lean`, `Catalog/MachineLearning/HardyHierarchy/Defs.lean`.

**Proof Strategy:** For the positive direction, use the structural induction argument. For the negative direction (maximality), construct expressions in the extended grammar where the chain rule or other rules produce depth increase. Key test: `deriv(f(g(x)))` where `f = exp` and `g` involves composition.

**Domain Bridges:** Model theory (definability in exp-polynomial structures), differential algebra (characterizing differential subrings), proof theory (ordinal analysis of growth hierarchies).

**Lineage:** Paradigm extension of `depth_deriv_le_self`.

**Ambition:** Grand challenge — the positive direction is established; maximality would be a deep result.

---

## Direction 5: Differential Filtration and Cohomological Invariants (Grand Challenge)

**Conjecture:** The depth filtration `F_0 ⊂ F_1 ⊂ F_2 ⊂ ...` (where `F_d = {e : depth(e) ≤ d}`) is not just a differential filtration but induces a graded differential ring structure `G_d = F_d / F_{d-1}` with non-trivial cohomological invariants. Specifically, the "depth-graded derivative" `∂ : G_d → G_d` induced by `deriv` (which is well-defined by the depth preservation theorem) has a kernel that captures the "asymptotically constant" expressions at each level.

**Test:** Compute the quotient ring `G_d` for small `d` (0, 1, 2). Identify the kernel of the induced derivation. Check whether this kernel has a clean algebraic description (e.g., constants at level 0, expressions of the form `c * exp(c' * x)` at level 1).

**Impact:** Would connect the PosEML depth hierarchy to algebraic K-theory and differential cohomology, opening a bridge between symbolic computation and homological algebra. The cohomological invariants could provide new tools for classifying asymptotic behavior.

**Catalog References:** `Catalog/Pythagorean/HardyHierarchy/DepthSharpness.lean` (depth preservation enables the grading), `Catalog/Pythagorean/HardyHierarchy/QuotientClosure.lean`.

**Proof Strategy:** First establish that `F_d` is a subring (closed under +, *) — this follows from the depth definitions. Then show `deriv(F_d) ⊆ F_d` (our theorem). Compute the quotient explicitly for `d = 1`: `G_1 = F_1 / F_0` should consist of "pure exponential" contributions. Identify the kernel.

**Domain Bridges:** Algebraic topology (spectral sequences), differential geometry (de Rham cohomology), number theory (motivic cohomology of function fields).

**Lineage:** Paradigm-shifting extension building on the differential filtration established by `depth_deriv_le_self`.

**Ambition:** Grand challenge — would create a new subfield at the intersection of symbolic computation and homological algebra.
