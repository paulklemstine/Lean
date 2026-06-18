# Future Directions: Hardy Hierarchy for EML Expressions

## Synthesis

The Hardy level hierarchy established in this work creates a formally verified bridge between syntactic expression depth and asymptotic growth classification. This opens three major research programs: (1) completing the strict separation at all levels, which would make `emlDepth` a provably exact asymptotic invariant; (2) extending the hierarchy to include logarithms and differential closure, connecting to the classical Hardy field and transseries theories; and (3) applying the certified classifier to practical domains including symbolic AI, numerical analysis, and computational complexity. Each direction below builds on the core `HardyLevel` inductive and the soundness theorem `emlDepth_le_hardyLevel`, extending the certified asymptotic classification to richer mathematical and computational settings.

---

## Direction 1: Complete Strict Hierarchy Separation

**Conjecture:** For every *n ≥ 1*, `¬ HardyLevel (n-1) (iterExp n)`. That is, the *n*-fold iterated exponential strictly requires Hardy level *n* and cannot be represented at level *n-1*.

**Test:** For each *n* from 1 to 10:
1. Attempt to construct a `HardyLevel (n-1)` derivation tree for `iterExp n`. If successful, the conjecture is false.
2. Numerically sample `iterExp n` at large inputs and compare against the best polynomial bound (for *n=1*) or the best level-(*n-1*) bound. If `iterExp n` is eventually dominated by a level-(*n-1*) function, the conjecture is false.
3. Formally prove growth bounds: every level-*n* function is eventually bounded by a fixed function of `iterExp (n+1)`. Use this to derive a contradiction from the assumption `HardyLevel (n-1) (iterExp n)`.

**Impact:** Completing this would make `emlDepth` a provably **exact** asymptotic invariant — not just a sound upper bound but a tight one. This transforms the framework from a classification tool to a characterization theorem.

**Catalog References:** `Speculative/HardyHierarchy/Theorems.lean` — `exp_not_hardyLevel_zero` (base case), `iterExp_not_mem_lower_hardyLevel_conj` (conjecture statement).

**Proof Strategy:** Prove `hardyLevel_n_bounded_by_iterExp_succ` by refined structural induction, showing that products of level-*n* functions remain bounded because the exp_step structure prevents true multiplication of growth rates (products of `a·exp(b)` terms collapse to `(a₁a₂)·exp(b₁+b₂)` which stays at the same level). Then use this bound plus the super-exponential growth of `iterExp (n+1)` to derive contradictions.

**Domain Bridges:** Computational complexity (circuit depth lower bounds), model theory (o-minimal definability).

**Lineage:** Extends `exp_not_hardyLevel_zero` from base case to general case.

**Ambition:** Grand challenge — would be a landmark result in formal asymptotic analysis.

---

## Direction 2: Logarithmic Extension and Full Log-Exp Hierarchy

**Conjecture:** The Hardy level hierarchy can be extended with logarithmic levels below level 0, creating a bi-directional hierarchy:
- Level *-k*: functions growing like *log(log(...log(x)...))* with *k* iterations
- Level 0: polynomial growth
- Level *k*: functions growing like *exp(exp(...exp(x)...))* with *k* iterations

Furthermore, EML expressions extended with a `log` primitive would satisfy an analogous soundness theorem.

**Test:**
1. Define `HardyLevelZ : ℤ → (ℝ → ℝ) → Prop` extending `HardyLevel` with logarithmic descent.
2. Prove that iterated logarithms `log^n(x)` belong to level *-n*.
3. Verify computationally: for random expressions involving log and exp, the integer-valued depth matches the Hardy level.

**Impact:** Would connect the formal framework to the full classical Hardy hierarchy and to the theory of o-minimal structures, where the log-exp field is the canonical example.

**Catalog References:** `Speculative/HardyHierarchy/Defs.lean` — `HardyLevel` definition.

**Proof Strategy:** Add constructors for `log_step : HardyLevel (n+1) f → HardyLevel n (fun x => log(f x))` (descending logarithm). Prove closure properties. The key challenge is ensuring the resulting hierarchy is still well-ordered and matches the classical one.

**Domain Bridges:** O-minimal geometry (definable function classes), analytic number theory (asymptotic expansion of arithmetic functions), transseries theory.

**Lineage:** Natural extension of the current `HardyLevel` hierarchy.

**Ambition:** Solid extension — technically challenging but well-motivated by existing theory.

---

## Direction 3: Differential Closure and Transseries Fragments

**Conjecture:** Differentiation raises Hardy level by at most 1 on positive EML expressions. Specifically, if `f` is represented by an EML expression of depth *d* and `f(x) > 0` for large *x*, then `f'` is at Hardy level *d + 1*.

**Test:**
1. Symbolically differentiate EML expressions up to depth 3.
2. Compute the Hardy level of the derivative and compare with *d + 1*.
3. Search for counterexamples where the derivative exceeds level *d + 1*.

**Impact:** Would connect the Hardy hierarchy to differential algebra, opening a path toward formal transseries. Transseries are the natural setting for asymptotic solutions of differential equations, and a certified differential closure theorem would be a major step.

**Catalog References:** `Speculative/HardyHierarchy/Theorems.lean` — `hardyLevel_closed_under_eml` (closure under eml).

**Proof Strategy:** Use the chain rule: `d/dx [a·exp(b)] = a'·exp(b) + a·b'·exp(b) = (a' + a·b')·exp(b)`. If `a, b` are at level *n*, then `a', b'` should be at level *n* or *n+1* (by induction). The result `(a' + ab')·exp(b)` is then at level *n+1*.

**Domain Bridges:** Differential algebra, asymptotic analysis (WKB approximation, saddle-point method), mathematical physics (renormalization group flows).

**Lineage:** Builds on `hardyLevel_closed_under_eml` and the soundness theorem.

**Ambition:** Grand challenge — differential closure in the Hardy hierarchy is a deep classical problem.

---

## Direction 4: Neural Architecture Complexity Classification

**Conjecture:** The expressive power of feedforward neural networks with exponential activation functions (softmax, sigmoid, GELU) is stratified by depth in a way that corresponds to the Hardy hierarchy. Specifically, a depth-*d* network with exponential activations can represent functions up to Hardy level *d*, and there exist functions at level *d* that require depth *d*.

**Test:**
1. Formalize neural network architectures as EML expressions (the activation `σ(x) = 1/(1+exp(-x))` involves one `eml` application).
2. Compute the emlDepth of network expressions of various depths.
3. Numerically train networks of different depths to approximate `iterExp n` and measure approximation quality as a function of depth and level.

**Impact:** Would provide a mathematically rigorous framework for understanding the depth-expressiveness tradeoff in neural networks, grounding empirical observations about "the power of depth" in certified asymptotic theory.

**Catalog References:** `Speculative/HardyHierarchy/Theorems.lean` — `emlDepth_le_hardyLevel`, `hardyClassify`.

**Proof Strategy:** Express standard neural network layers as EML expressions. Each layer with an exponential activation contributes one eml application, hence one Hardy level. The soundness theorem then gives the upper bound. The lower bound follows from strict separation.

**Domain Bridges:** Machine learning theory (universal approximation, depth separation), circuit complexity (AC⁰ vs TC⁰ vs NC¹).

**Lineage:** Application of the certified classifier to a practical domain.

**Ambition:** Solid extension — technically feasible and highly relevant to current ML theory.

---

## Direction 5: Certified Asymptotic Simplification Engine

**Conjecture:** Two EML expressions at different Hardy levels cannot be eventually equal (assuming strict separation). This enables a certified simplification procedure: if two expressions have different emlDepth, they represent asymptotically distinct functions, and any "simplification" that changes the depth must change the asymptotic behavior.

**Test:**
1. Enumerate pairs of EML expressions with different depths.
2. Verify numerically that no pair is eventually equal (sample at large inputs).
3. Implement a simplification engine that uses Hardy level as a conserved invariant: simplifications must preserve emlDepth.

**Impact:** Would create the first certified asymptotic simplification engine — a tool that simplifies mathematical expressions while guaranteeing that asymptotic behavior is preserved.

**Catalog References:** `Speculative/HardyHierarchy/Theorems.lean` — `growthRank_sound`, `hardyClassify`.

**Proof Strategy:** Use strict separation: if `f` is at level *d₁* and `g` is at level *d₂ > d₁*, then `f` has slower eventual growth than `g`, so they cannot be eventually equal.

**Domain Bridges:** Computer algebra (symbolic simplification), numerical analysis (asymptotic approximation), compiler optimization (strength reduction for mathematical expressions).

**Lineage:** Direct application of the strict separation conjecture.

**Ambition:** Solid extension — highly practical if the strict separation is established.
