# Future Directions

## Synthesis

The DAG depth rigidity theorem establishes that sharing (common subexpression elimination) preserves the essential sequential complexity of iterated exponentiation in the inverse-free EML fragment. This opens a systematic research program connecting formal lower bounds to circuit complexity, compiler optimization theory, and parallel computation. The five directions below form a coherent arc: Direction 1 removes the key restriction (inverse-freeness), Direction 2 explores the approximation boundary, Direction 3 extends to richer function families, Direction 4 bridges to classical circuit complexity, and Direction 5 pushes toward a grand unification of depth rigidity across computational models. Together, they chart a path from the current result to a general theory of when sharing compresses size but not depth.

---

## Direction 1: Depth Rigidity in the Full EML Language (with Inversions)

**Conjecture:** For every $n \in \mathbb{N}$ and every DAG $G$ in the full EML language (including inversions) that computes $\text{iterExp}(n)$ on positive reals, $\text{depth}(G) \geq n$.

**Test:**
- Exhaustive search: enumerate DAGs with inversion nodes up to 10 nodes and depth $< 5$, test against iterExp on $\{0.1, 0.5, 1.0, 2.0, 3.0\}$.
- Analytical test: attempt to construct $\text{iterExp}(3)$ using depth-2 expressions with strategic inversions. If any candidate survives the test suite, investigate whether it truly computes iterExp or merely agrees on finitely many points.
- Disproof protocol: a single DAG with inversions computing iterExp(n) at depth $< n$ would refute the conjecture.

**Impact:** Removing the inverse-free restriction would make the lower bound robust under the full arithmetic of the real field, significantly strengthening its implications for symbolic computation and compiler optimization.

**Catalog References:** `Catalog/Algebra/TightDepthHierarchy/Theorems.lean` (tree lower bound), `Catalog/Speculative/DagDepthHierarchy/Theorems.lean` (DAG lower bound)

**Proof Strategy:** The main obstacle is that inversions enable cancellations that can flatten growth rates. A promising approach: show that any use of inversion in a depth-$D$ computation can be "absorbed" into a modified majorant bound, perhaps using a refined growth classification that tracks both upper and lower growth envelopes.

**Domain Bridges:** Algebraic complexity theory (arithmetic circuits with division), differential algebra (Liouville's theorem on elementary functions), computer algebra systems (simplification algorithms).

**Lineage:** Direct extension of the current DAG depth rigidity theorem. Builds on the observation that the tree lower bound already handles the inverse-free case; the question is whether inversions provide a fundamentally different mechanism for depth reduction.

**Ambition:** High — this would be a significant result in algebraic complexity, establishing depth lower bounds for a complete arithmetic model.

---

## Direction 2: Approximate Depth Rigidity

**Conjecture:** For every $n \in \mathbb{N}$, $\epsilon > 0$, and inverse-free DAG $G$: if $|G.\text{eval}(x) - \text{iterExp}(n, x)| < \epsilon$ for all $x \in [1, 10]$, then $\text{depth}(G) \geq n - O(\log \log(1/\epsilon))$.

**Test:**
- Construct explicit inverse-free DAGs of depth $n - 1$ and measure their maximum deviation from iterExp(n) on $[1, 10]$.
- Plot the approximation error as a function of depth for various $n$ values.
- Check whether Chebyshev-like polynomial approximations of $\exp$ can reduce EML depth when composed.
- Disproof protocol: construct a depth-$(n-2)$ DAG that approximates $\text{iterExp}(n)$ to within $10^{-6}$ on $[1, 10]$.

**Impact:** Understanding the approximation boundary is essential for practical applications where exact computation is unnecessary. This connects to numerical analysis and the theory of function approximation.

**Catalog References:** `Catalog/Algebra/TightDepthHierarchy/Defs.lean` (HasPolyTowerMajorant definition), `Catalog/Speculative/DagDepthHierarchy/Theorems.lean`

**Proof Strategy:** The tower majorant argument shows that depth-$D$ expressions grow at most as fast as iterExp($D$). For approximation, one needs to show that no depth-$(n-1)$ expression can even *approximate* iterExp($n$) well on a compact interval. This should follow from the rapid separation between adjacent tower levels.

**Domain Bridges:** Approximation theory, numerical analysis, computational learning theory (PAC-learning of function classes), real algebraic geometry.

**Lineage:** Extends the exact lower bound to the approximate setting. Motivated by practical considerations in numerical computation.

**Ambition:** Medium-high — the exact statement of the conjecture requires care, but the basic phenomenon (rapid growth separation) should make it provable.

---

## Direction 3: Depth Rigidity for Generalized Tower Families

**Conjecture:** There exists a family of functions $\{f_n\}$ beyond iterExp such that:
1. Each $f_n$ is computable by an inverse-free DAG of depth $n$.
2. No inverse-free DAG of depth $< n$ computes $f_n$.
3. The depth lower bound grows faster than $\log n$ despite unrestricted sharing.

**Test:**
- Define candidate families: hyper-operators $H(a, n, x)$, tetration variants, compositions of tower functions with polynomial arguments.
- For each candidate family, compute the growth rate and check whether the majorant classification distinguishes level $n$ from level $n - 1$.
- Enumerate small DAGs and test agreement with candidate functions.
- Disproof protocol: for a candidate $f_n$, exhibit a DAG of depth $o(n)$ computing it.

**Impact:** Extending depth rigidity beyond the iterExp family would establish a robust theory of sequential barriers, applicable to a wider class of mathematical computations.

**Catalog References:** `Catalog/Algebra/TightDepthHierarchy/Defs.lean` (growth rank, tower majorant), `Catalog/Speculative/DagDepthHierarchy/Defs.lean` (DAG definitions)

**Proof Strategy:** The key ingredient is a growth classification theorem that distinguishes tower levels. For generalized families, one needs to show that the growth rate of $f_n$ exceeds any tower of level $< n$ with polynomial arguments — the same majorant analysis used for iterExp, but applied to the new family.

**Domain Bridges:** Ordinal analysis (fast-growing hierarchies), reverse mathematics, proof theory (consistency strengths), computer science (hierarchy theorems).

**Lineage:** Natural generalization of the iterExp depth hierarchy. The existing majorant framework should extend with moderate effort.

**Ambition:** Medium — the framework is in place; the challenge is identifying families where the growth analysis yields clean bounds.

---

## Direction 4: Formal Bridge to Boolean Circuit Complexity (Grand Challenge)

**Conjecture:** The unfold-and-reduce technique can be formalized as a general circuit-to-formula depth preservation theorem, applicable to restricted Boolean circuit classes.

Specifically: for monotone Boolean circuits computing the iterated composition of a fixed monotone function $f$ (e.g., majority, threshold), the circuit depth equals the formula depth up to constant factors.

**Test:**
- Formalize monotone Boolean DAGs and their unfolding in Lean 4.
- Prove depth non-inflation for Boolean unfolding (this should be straightforward, analogous to the EML case).
- Identify a monotone function family where formula depth lower bounds are known (e.g., from Karchmer-Wigderson games).
- Attempt to combine Boolean unfolding with known formula lower bounds to obtain circuit lower bounds.
- Disproof protocol: exhibit a monotone circuit for an iterated function that is provably shallower than any formula.

**Impact:** This would be a breakthrough in computational complexity, connecting formalized algebraic lower bounds to the central open problems of circuit complexity.

**Catalog References:** `Catalog/Speculative/DagDepthHierarchy/Theorems.lean` (unfolding framework), `Catalog/Algebra/TightDepthHierarchy/Theorems.lean` (tree lower bounds)

**Proof Strategy:** The unfolding technique is model-agnostic: it depends only on the DAG structure, not on the specific operations. The challenge is finding Boolean function families where (1) tree/formula lower bounds are known and (2) the unfolding depth bound is tight.

**Domain Bridges:** Boolean circuit complexity, communication complexity (Karchmer-Wigderson), monotone complexity, proof complexity.

**Lineage:** Grand challenge extending the EML results to the Boolean world. Represents the ultimate payoff of the unfold-and-reduce methodology.

**Ambition:** Very high — this is a genuine research frontier. Even partial results (e.g., for restricted circuit classes) would be significant.

---

## Direction 5: Compiler Lower Bound Hypothesis

**Conjecture:** Any semantics-preserving compiler optimization pass on inverse-free EML programs that performs common subexpression elimination, constant folding, and algebraic simplification cannot reduce the critical-path depth of programs computing $\text{iterExp}(n)$.

More precisely: let $T$ be any semantics-preserving transformation on inverse-free EML DAGs. Then $\text{depth}(T(G)) \geq \text{depth}(G)$ whenever $G$ computes $\text{iterExp}(n)$ and $\text{depth}(G) = n$.

**Test:**
- Implement CSE, constant folding, and algebraic simplification on EML DAGs.
- Apply these transformations to canonical iterExp DAGs and verify depth is preserved.
- Attempt to design adversarial transformations that reduce depth (should fail by the theorem).
- Formalize specific transformation passes and prove depth preservation.
- Disproof protocol: design a semantics-preserving transformation that reduces depth for some representation of iterExp.

**Impact:** This would provide the first formal impossibility result for compiler optimization in a mathematical setting, with potential applications to verified compiler design.

**Catalog References:** `Catalog/Speculative/DagDepthHierarchy/Theorems.lean` (main theorem proves this for arbitrary DAGs, which subsumes any transformation output)

**Proof Strategy:** The current theorem already implies this: if $T(G)$ computes iterExp(n) and is inverse-free, then $\text{depth}(T(G)) \geq n$. The interesting extension is to formalize specific transformation passes and show they preserve both inverse-freeness and semantics.

**Domain Bridges:** Compiler theory, program optimization, verified compilation (CompCert, CakeML), abstract interpretation.

**Lineage:** Direct application of the DAG lower bound to compiler optimization. The theorem is the compiler lower bound; this direction makes it explicit.

**Ambition:** Medium — the theorem already provides the core result; the direction is about making the connection to compiler theory explicit and actionable.
