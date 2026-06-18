# Future Directions: Depth Rigidity and Reciprocal Envelopes

## Synthesis

The depth rigidity theorem for the full EML language with inversions opens a family of interconnected research directions, all centered on a single question: **how far does the reciprocal envelope framework extend?** The core insight — that inversion swaps asymptotic bounds without increasing tower height — is not limited to the specific language `{var, const, mul, inv, exp}`. It suggests a general principle: semantic complexity measures that are self-dual under reciprocal are robust against division. The directions below test this principle in progressively broader settings: from adding addition and logarithms, to approximate computation, to abstract algebraic frameworks, to connections with differential algebra and complexity theory.

---

## Direction 1: Depth Rigidity with Addition

**Conjecture:** The depth rigidity theorem extends to the full field language `{+, -, ×, ÷, exp}` over positive reals: any expression computing `iterExp(n)` on `(0, ∞)` requires depth ≥ n.

**Test:** Enumerate expressions in the full field language up to size 10 and depth < 4. Evaluate at test points {0.1, 0.5, 1.0, 2.0, 3.0} and compare against `iterExp(n)` for n = 1, 2, 3, 4. A single match with depth < n disproves the conjecture.

**Impact:** This would establish depth rigidity for the most natural arithmetic language over the reals, making the result maximally applicable to compiler optimization and symbolic computation.

**Catalog References:**
- `Pythagorean/DepthRigidityFull/Theorems.lean` — current result without addition
- `Catalog/Algebra/TightDepthHierarchy/Theorems.lean` — inverse-free hierarchy with addition

**Proof Strategy:** Extend the reciprocal envelope to a **signed envelope** that tracks both positive and negative parts. The challenge is that addition can create cancellation: `exp(x) + (-exp(x)) = 0`, which destroys positivity. One approach: define `HasSignedEnvelope(d, f)` requiring `|f(x)| ≤ iterExp(d, C·x^N)` (no reciprocal needed, since `|f| = |1/f|^{-1}` and absolute value handles signs). Then show: addition preserves the level (triangle inequality), multiplication preserves the level (product of bounded functions), and exponentiation increments the level.

**Domain Bridges:** Connects to elimination theory in symbolic computation: can expressions with `+` be simplified to a canonical form that reveals depth?

**Lineage:** Extends the current work by adding the single most important missing operation.

**Ambition:** Grand challenge — addition fundamentally changes the algebraic structure.

---

## Direction 2: Approximate Depth Rigidity

**Conjecture:** For any ε > 0 and expression `e` with `|e.eval(x) - iterExp(n, x)| ≤ ε · iterExp(n, x)` for all sufficiently large x > 0, we have `depth(e) ≥ n`.

**Test:** For n = 3, search for depth-2 expressions that approximate `iterExp(3)` within relative error ε = 0.01 on {10, 20, 50, 100}. Compare relative errors: if any depth-2 expression achieves ε < 0.01 at all test points, investigate further.

**Impact:** An approximate depth rigidity theorem would apply to numerical computation, not just exact symbolic computation. It would mean that even hardware-efficient approximations to iterated exponentials require full depth.

**Catalog References:**
- `Pythagorean/DepthRigidityFull/Theorems.lean` — exact computation version

**Proof Strategy:** The separation argument `iterExp(d, C·x^N) < iterExp(d+1, x)` is asymptotic: the gap grows without bound. If `e.eval` is within relative ε of `iterExp(n)` for large x, then `e.eval(x) ≥ (1-ε)·iterExp(n, x)`, which eventually exceeds `iterExp(d, C·x^N)` for any d < n. The reciprocal bound follows similarly. The key lemma is that `(1-ε)·iterExp(n, x)` still grows faster than `iterExp(n-1, C·x^N)`.

**Domain Bridges:** Numerical analysis, approximation theory, hardware design for scientific computing.

**Lineage:** Natural quantitative strengthening of the exact result.

**Ambition:** Solid extension — the asymptotic gap makes this likely provable.

---

## Direction 3: Differential-Algebraic Characterization of Growth Rank

**Conjecture:** The growth rank of a function equals the minimal order of an algebraic differential equation over the field of rational functions that it satisfies. More precisely: `growthRank(f) = n` iff f satisfies a differential equation of order n over `ℝ(x)` involving exp, but no equation of order n-1.

**Test:** For `iterExp(n)` with n = 1, 2, 3, compute the differential equation satisfied by the function and verify its order equals n. For `exp(x)`: y' = y (order 1). For `exp(exp(x))`: y'/(y·ln(y)) = 1, or equivalently y'' = y'²/y + y' (order 2). Check that no order-1 equation works.

**Impact:** This would bridge depth rigidity with Liouvillian tower theory, connecting circuit complexity to differential algebra. It would provide an alternative characterization of the depth hierarchy in terms of differential equations rather than expression structure.

**Catalog References:**
- `Pythagorean/DepthRigidityFull/Defs.lean` — `PosExpr.logTameIndex` definition (connects log-descent to growth rank)

**Proof Strategy:** Use the fact that exp(f) satisfies a differential equation of order one higher than f does. Formally: if f satisfies P(x, f, f', ..., f^(k)) = 0, then g = exp(f) satisfies Q(x, g, g', ..., g^(k+1)) = 0 obtained by substituting f = log(g) and its derivatives. The converse (lower bound on order) uses transcendence arguments.

**Domain Bridges:** Differential algebra, model theory of exponential fields, Ax-Schanuel conjecture.

**Lineage:** Connects the syntactic notion of depth to a semantic notion from differential algebra.

**Ambition:** Grand challenge — would require significant new formalization of differential algebra.

---

## Direction 4: Reciprocal Envelope Completeness

**Conjecture:** A positive function `f : (0,∞) → (0,∞)` is definable by a depth-d expression (with inversions) iff it has a reciprocal envelope at level d and satisfies suitable regularity conditions (e.g., elementary function, analytic on `(0,∞)`).

**Test:** Classify all depth-≤2 functions by their asymptotic behavior. Check whether every function with a level-2 reciprocal envelope that is "EML-regular" (expressible as finite compositions of exp, ×, ÷) actually has a depth-2 expression computing it. Candidate: `exp(x²)` has level-1 envelope (since `exp(x²) ≤ exp(x² + 1) ≤ iterExp(1, x² + 1)`), but is it depth-1 expressible?

**Impact:** A completeness theorem would turn the reciprocal envelope from a lower bound tool into a complete characterization of expressibility.

**Catalog References:**
- `Pythagorean/DepthRigidityFull/Defs.lean` — `HasReciprocalEnvelope` definition

**Proof Strategy:** The forward direction (depth d implies envelope d) is our Theorem 4.1. The converse requires constructing an expression from the envelope, which seems much harder and may require additional regularity assumptions.

**Domain Bridges:** Descriptive set theory, o-minimal structures, tame topology.

**Lineage:** The natural "converse" question to our main theorem.

**Ambition:** Solid extension — the forward direction is proved; the converse needs significant new ideas but is well-defined.

---

## Direction 5: Depth Rigidity for Multivariate Expressions

**Conjecture:** For multivariate expressions `e(x₁, ..., xₖ)`, if `e` computes `iterExp(n, x₁)` for all positive `x₁, ..., xₖ`, then `depth(e) ≥ n`, regardless of the auxiliary variables.

**Test:** Search for depth-2 bivariate expressions `e(x, y)` that compute `iterExp(3, x)` for all `x, y > 0`. Use test grid {0.5, 1.0, 2.0} × {0.5, 1.0, 2.0}. Any match would be a counterexample.

**Impact:** Multivariate depth rigidity would rule out "dimension tricks" — using extra variables as scratch space to reduce exponential depth.

**Catalog References:**
- `Pythagorean/DepthRigidityFull/Theorems.lean` — univariate version

**Proof Strategy:** Project the multivariate envelope to the x₁ coordinate. If `e(x₁, ..., xₖ) = iterExp(n, x₁)`, fix `x₂ = ... = xₖ = 1` to reduce to the univariate case. The depth of the specialized expression is at most the depth of the original.

**Domain Bridges:** Algebraic geometry (dimension of the variety of depth-bounded functions), circuit complexity (depth vs width tradeoffs).

**Lineage:** Natural generalization from univariate to multivariate.

**Ambition:** Solid extension — the reduction to the univariate case via specialization seems straightforward.
