# Future Directions: Certified Derivative Normalization

## Synthesis

The zero-overhead differentiation theorem (`depth(normalize(deriv(e))) ≤ depth(e)`) establishes that algebraic normalization completely controls the structural complexity of symbolic differentiation in the positive EML fragment. This opens five interconnected research directions: (1) strengthening the normalizer to achieve canonical forms and size control, (2) extending the language with logarithms and division, (3) investigating integration and higher-order operators, (4) connecting depth stability to dynamical systems on expression spaces, and (5) extracting verified executable symbolic engines.

These directions form a progression from local refinement (better normalization) through language extension (richer expressions) to conceptual deepening (complexity theory for symbolic computation). Each builds on the verified infrastructure—smart constructors, depth bounds, semantic preservation—established in the current work, and each is falsifiable through specific computational or formal tests.

---

## Direction 1: Canonical Forms via Confluent Normalization

**Conjecture:** There exists an extension of the current normalizer with commutativity (`add(a,b) ↦ add(b,a)` under a total order on expressions), associativity flattening, and constant folding, such that:
1. The extended normalizer produces a unique canonical form for each semantic equivalence class (restricted to the positive EML fragment over ℚ-valued constants).
2. The canonical normalizer still satisfies `depth(canonicalize(e)) ≤ depth(e)`.

**Test:** Enumerate all expressions up to depth 3 with constants in {0, 1, 2}. For each pair (e₁, e₂) that evaluate to the same function at 100 test points, check whether `canonicalize(e₁) = canonicalize(e₂)` syntactically. Any pair that evaluates identically but normalizes differently is a counterexample to confluence. Richardson's theorem (1968) implies full canonicalization is undecidable for general real expressions, so the conjecture may fail for sufficiently complex expressions—identifying the boundary is the scientific contribution.

**Impact:** A canonical form would solve the expression equivalence problem for the fragment, enabling optimal symbolic computation.

**Catalog References:** `Catalog/Pythagorean/HardyHierarchy/DerivativeNormalizer.lean` (normalize, eval_normalize, depth_normalize_le)

**Proof Strategy:** Define a total order on PosEMLExpr (lexicographic on structure, then on constants). Extend `mkAdd` and `mkMul` to sort arguments. Prove confluence by showing all critical pairs resolve. The depth bound should follow from the same smart-constructor architecture.

**Domain Bridges:** Term rewriting theory (Knuth-Bendix completion), computer algebra (canonical simplification), compiler optimization (GVN/reassociation).

**Lineage:** Direct extension of `normalize` from DerivativeNormalizer.lean.

**Ambition:** Extension — refines existing normalizer to achieve a stronger property.

---

## Direction 2: Size Bounds on the Good Fragment Under Iterated Differentiation

**Conjecture:** For expressions in the `Good` fragment (polynomial-exponential, no nested `exp`), the size of `normalize(deriv^n(e))` grows at most polynomially in `n`:
$$\text{size}(\text{normalize}(\text{deriv}^n(e))) \leq C(e) \cdot n^{d+1}$$
where `d = depth(e)` and `C(e)` depends only on the initial expression.

**Test:** For each Good expression `e` up to depth 2 and size ≤ 10, compute `size(normalize(deriv^n(e)))` for `n = 1, ..., 20`. Fit a polynomial `c · n^k` by least squares. Check whether `k ≤ depth(e) + 1` for all test expressions. A super-polynomial growth rate in any Good expression would refute the conjecture.

**Impact:** Would establish that the Good fragment has computationally tractable iterated differentiation—not just bounded depth, but bounded overall complexity.

**Catalog References:** `Catalog/Pythagorean/HardyHierarchy/DerivativeNormalizer.lean` (Good, depth_normalize_deriv_le)

**Proof Strategy:** For depth-0 (polynomial) expressions, `deriv` reduces degree by 1, so iterated derivatives terminate. For depth-1 (polynomial × exp(polynomial)), the derivative produces `(polynomial' × exp(poly) + polynomial × poly' × exp(poly))` = `new_poly × exp(poly)`. Track the degree of the polynomial prefactor, which grows linearly with each differentiation step.

**Domain Bridges:** Computational complexity (polynomial-time symbolic computation), automatic differentiation (gradient complexity), analytic combinatorics (coefficient growth).

**Lineage:** Extends the zero-overhead theorem from depth to size.

**Ambition:** Extension — quantifies the computational cost of iterated differentiation.

---

## Direction 3: Depth Stability for Extended Languages (Logarithms and Division)

**Conjecture (Grand Challenge):** There exists an extension of PosEMLExpr with `log(a)` and `div(a, b)` constructors, a corresponding normalizer, and a fragment predicate, such that:
$$\text{depth}(\text{normalize}_{\text{ext}}(\text{deriv}_{\text{ext}}(e))) \leq \text{depth}(e)$$
where `depth(log(a)) = depth(a) + 1` (logarithm is the inverse operation to exponentiation in the hierarchy).

**Test:** Implement the extended language in Python. Enumerate expressions up to depth 3 including `log` and `div` nodes. Compute the depth gap `depth(normalize(deriv(e))) - depth(e)` for each. Any positive gap identifies a problematic pattern that the normalizer must handle.

The key challenge: `deriv(log(a)) = deriv(a) / a`, which introduces division. The normalizer must handle `div(a, a) = 1` and similar patterns. Since `log(exp(a)) = a`, the normalizer should also perform log-exp cancellation.

**Impact:** Would extend the zero-overhead theorem to the full Hardy field language, covering the logarithmic-exponential functions that dominate asymptotic analysis.

**Catalog References:** `Catalog/Pythagorean/HardyHierarchy/DerivativeNormalizer.lean`, `Catalog/MachineLearning/HardyHierarchy/Defs.lean` (EmlExpr, Hardy hierarchy definitions)

**Proof Strategy:** Define `depth(log(a)) = depth(a) + 1` and `depth(div(a,b)) = max(depth(a), depth(b))`. The critical case is `deriv(log(a)) = div(deriv(a), a)`. By IH, `depth(normalize(deriv(a))) ≤ depth(a)`, and `depth(a) < depth(log(a))`, so `depth(div(normalize(deriv(a)), normalize(a))) ≤ depth(a) < depth(log(a))`. This should work!

**Domain Bridges:** Hardy fields (log-exp closure), asymptotic analysis (L'Hôpital's rule), transseries (log-exp monomials).

**Lineage:** Grand extension of the current positive-EML framework.

**Ambition:** Grand challenge — requires significant new infrastructure.

---

## Direction 4: Expression Space Dynamics and Fixed Points

**Conjecture:** The map `e ↦ normalize(deriv(e))` on depth-bounded PosEMLExpr expressions has a finite number of periodic orbits (up to a suitable equivalence). Specifically, for depth-1 expressions, every orbit of `normalize ∘ deriv` either converges to `const(0)` or enters a cycle of length at most 1.

**Test:** For all depth-1 expressions up to size 15, iterate `normalize ∘ deriv` up to 50 times. Record the eventual behavior: convergence to `const(0)`, fixed point, cycle, or apparent non-termination. Classify the expressions by their dynamical behavior. If any expression exhibits a cycle of length > 1, this refutes the conjecture for depth 1.

Computational evidence suggests `exp(x) → exp(x)` is a fixed point, and polynomial expressions converge to `const(0)`. The conjecture is that these are the only behaviors at depth 1.

**Impact:** Would establish a dynamical systems theory for symbolic differentiation, connecting the discrete dynamics of expression transformation to the continuous dynamics of the underlying functions.

**Catalog References:** `Catalog/Pythagorean/HardyHierarchy/DerivativeNormalizer.lean` (normalize, deriv, depth_normalize_deriv_le)

**Proof Strategy:** For depth-0 expressions (polynomials), each differentiation reduces size, so the orbit converges to `const(0)`. For depth-1 expressions of the form `p(x) · exp(q(x))`, the derivative normalizes to `(p'(x) + p(x)·q'(x)) · exp(q(x))`, a depth-1 expression with a new polynomial prefactor. The dynamics reduce to the transformation `p ↦ p' + p·q'` on the polynomial prefactor.

**Domain Bridges:** Dynamical systems (symbolic dynamics on term spaces), ergodic theory (recurrence in discrete systems), automata theory (finite-state behavior of transformations).

**Lineage:** Novel application of the normalizer infrastructure.

**Ambition:** Grand challenge — connects discrete algebra to dynamical systems theory.

---

## Direction 5: Verified Executable Extraction and Benchmarking

**Conjecture:** The normalizer can be made computable (by restricting to rational constants and using decidable equality on ℚ) and extracted to an efficient executable that outperforms naive symbolic differentiation libraries on expressions with many zero/one patterns.

**Test:** Implement a computable version using `PosEMLExprQ` with `ℚ` constants. Extract to executable code via Lean's compiler. Benchmark against SymPy's `diff` followed by `simplify` on 1000 random expressions of sizes 10-100. Measure:
1. Correctness: all evaluations match to 10⁻¹⁰ relative error.
2. Output size: ratio of `size(our_output) / size(sympy_output)`.
3. Speed: wall-clock time ratio.

**Impact:** Would demonstrate that formally verified symbolic computation can be practically competitive.

**Catalog References:** `Catalog/Pythagorean/HardyHierarchy/DerivativeNormalizer.lean` (normalize, certify)

**Proof Strategy:** Replace `ℝ` with `ℚ` in the expression type. Since `DecidableEq ℚ` exists, the smart constructors become computable. Re-prove all theorems (they should transfer almost verbatim). Use `@[csimp]` for any performance-critical implementations.

**Domain Bridges:** Verified software extraction (CompCert, CakeML), computer algebra systems (Mathematica, SymPy), performance engineering.

**Lineage:** Practical application of the theoretical framework.

**Ambition:** Extension — engineering contribution with formal backing.
