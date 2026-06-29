# Tropical Valuation Functor from Commutative Semirings to Closure-Stable Probe Systems

## Abstract

We construct a canonical functor from tropical valuations on commutative semirings to closure systems equipped with probe families. Given a valuation $v : R \to \mathbb{N}_\infty$ satisfying the multiplicative homomorphism property $v(ab) = v(a) + v(b)$ and the ultrametric inequality $\min(v(a), v(b)) \leq v(a+b)$, we define the *level-set closure* $\text{cl}_v(S) = \{x \mid \exists s \in S,\, v(x) = v(s)\}$ and prove it is an idempotent closure operator. Our main theorem characterizes the closure-stable probes: an observable $p : R \to K$ is closure-stable if and only if it factors through $v$. We establish multiplicative compatibility (tropical functoriality), a complete characterization of closure equivalence between valuations, functoriality under valuation-preserving morphisms, and a threshold filtration with absorption. All results are formalized and verified in Lean 4 with Mathlib.

**Keywords**: tropical valuation, closure operator, probe system, level-set closure, tropical functoriality, filtered closure system, commutative semiring

## 1. Introduction

### 1.1 Motivation

Tropical geometry, the study of algebraic structures under the transformation $(+, \times) \mapsto (\min, +)$, has found applications across mathematics, from enumerative geometry to optimization theory. The fundamental tool of tropicalization is the *valuation*: a map from an algebraic object to an ordered abelian group that converts multiplication to addition and controls addition via the ultrametric inequality.

Separately, *closure operators* provide a foundational framework for studying observability and indistinguishability in dynamical systems, automata theory, and information theory. A closure-stable probe is an observable whose readings are invariant under the expansion of a set to its closure — such probes see only "macroscopic" features that survive coarse-graining.

This paper establishes a precise bridge between these two frameworks: every tropical valuation canonically induces a closure operator, and the closure-stable probes for this operator are completely characterized as the observables that factor through the valuation.

### 1.2 Main Results

1. **Closure System Construction** (Theorem 3.4): For any function $v : \sigma \to \mathbb{N}_\infty$, the level-set closure operator is extensive, monotone, and idempotent.

2. **Probe Characterization** (Theorem 5.1): A probe $p : \sigma \to K$ is closure-stable for the level-set closure if and only if it factors through $v$ (i.e., $v(x) = v(y) \implies p(x) = p(y)$).

3. **Multiplicative Compatibility** (Theorem 7.1): For a tropical valuation $v$ on a commutative semiring, if $x \in \text{cl}_v(\{a\})$ and $y \in \text{cl}_v(\{b\})$, then $xy \in \text{cl}_v(\{ab\})$.

4. **Closure Determines Level Sets** (Theorem 8.3): Two valuations $v_1, v_2$ satisfy $\text{cl}_{v_1} = \text{cl}_{v_2}$ as operators if and only if they induce the same partition: $v_1(x) = v_1(y) \iff v_2(x) = v_2(y)$ for all $x, y$.

5. **Threshold Separation** (Theorem 6.4): The threshold probe family separates elements with distinct valuations.

6. **Filtered Absorption** (Theorem 13.5): The threshold closures $\text{cl}_n(S) = \{x \mid v(x) \leq n\} \cup S$ satisfy the absorption law $\text{cl}_n(\text{cl}_m(S)) = \text{cl}_n(S)$ for $m \leq n$.

## 2. Preliminaries

### 2.1 Extended Natural Numbers

We work with $\mathbb{N}_\infty = \mathbb{N} \cup \{\top\}$ (denoted `WithTop ℕ` in Lean), equipped with the natural order extending $\leq$ on $\mathbb{N}$ by $n \leq \top$ for all $n$, and the extended addition $n + \top = \top + n = \top$, $n + m$ as usual for finite values.

$\mathbb{N}_\infty$ is a complete lattice with $\bot = 0$ and $\top = \infty$, and a linearly ordered commutative monoid under addition.

### 2.2 Tropical Valuation

**Definition 2.1** (Tropical Valuation). A *tropical valuation* on a commutative monoid with zero $(R, \cdot, 0, 1)$ equipped with addition is a function $v : R \to \mathbb{N}_\infty$ satisfying:
1. $v(0) = \top$ (zero maps to infinity)
2. $v(1) = 0$ (unit maps to zero)
3. $v(ab) = v(a) + v(b)$ (multiplicative homomorphism)
4. $\min(v(a), v(b)) \leq v(a+b)$ (ultrametric inequality)

**Example 2.2** (p-Adic Valuation). For a prime $p$, the extended multiplicity $\text{emultiplicity}(p, n)$ on $\mathbb{N}$ is a tropical valuation. This is verified in our formalization using Mathlib's `emultiplicity` function.

### 2.3 Closure Operator

**Definition 2.3** (Closure System). A *closure system* on a type $\sigma$ is a function $\text{cl} : \mathcal{P}(\sigma) \to \mathcal{P}(\sigma)$ satisfying:
- Extensivity: $S \subseteq \text{cl}(S)$
- Monotonicity: $S \subseteq T \implies \text{cl}(S) \subseteq \text{cl}(T)$
- Idempotence: $\text{cl}(\text{cl}(S)) \subseteq \text{cl}(S)$

## 3. Level-Set Closure

### 3.1 Definition

**Definition 3.1** (Level-Set Closure). For $v : \sigma \to \mathbb{N}_\infty$ and $S \subseteq \sigma$:
$$\text{cl}_v(S) = \{x \in \sigma \mid \exists s \in S,\, v(x) = v(s)\}$$

This closure adds to $S$ every element whose valuation matches some element of $S$. It is the coarsest closure that identifies elements sharing a valuation with a seed element.

### 3.2 Closure Axioms

**Theorem 3.2** (Extensivity). $S \subseteq \text{cl}_v(S)$.

*Proof.* If $x \in S$, take $s = x$; then $v(x) = v(s)$.

**Theorem 3.3** (Monotonicity). If $S \subseteq T$, then $\text{cl}_v(S) \subseteq \text{cl}_v(T)$.

*Proof.* If $x \in \text{cl}_v(S)$, there exists $s \in S$ with $v(x) = v(s)$. Since $s \in S \subseteq T$, we have $x \in \text{cl}_v(T)$.

**Theorem 3.4** (Idempotence). $\text{cl}_v(\text{cl}_v(S)) = \text{cl}_v(S)$.

*Proof.* The inclusion $\supseteq$ follows from extensivity and monotonicity. For $\subseteq$: if $x \in \text{cl}_v(\text{cl}_v(S))$, there exists $y \in \text{cl}_v(S)$ with $v(x) = v(y)$, and there exists $s \in S$ with $v(y) = v(s)$. By transitivity, $v(x) = v(s)$, so $x \in \text{cl}_v(S)$.

**Theorem 3.5** (Empty Set). $\text{cl}_v(\emptyset) = \emptyset$.

*Proof.* There is no $s \in \emptyset$ to witness membership.

## 4. Singleton Closure and Fibers

**Theorem 4.1** (Singleton Fiber). $\text{cl}_v(\{a\}) = \{x \mid v(x) = v(a)\}$.

This shows the closure of a singleton is exactly the $v$-fiber through $a$: the set of all elements with the same valuation as $a$.

## 5. Closure-Stable Probes

### 5.1 Definitions

**Definition 5.1** (Factors Through Valuation). A function $p : \sigma \to K$ *factors through* $v : \sigma \to \mathbb{N}_\infty$ if $v(x) = v(y) \implies p(x) = p(y)$ for all $x, y$.

**Definition 5.2** (Closure-Stable). A function $p : \sigma \to K$ is *closure-stable* for $v$ if for all $S \subseteq \sigma$ and $x \in \text{cl}_v(S)$, there exists $y \in S$ with $p(x) = p(y)$.

### 5.2 Main Characterization

**Theorem 5.3** (Closure-Stable ↔ Factors Through Valuation). $p$ is closure-stable for $\text{cl}_v$ if and only if $p$ factors through $v$.

*Proof.*

($\Leftarrow$) Suppose $p$ factors through $v$. Let $x \in \text{cl}_v(S)$. Then $\exists s \in S$ with $v(x) = v(s)$, so $p(x) = p(s)$. Take $y = s$.

($\Rightarrow$) Suppose $p$ is closure-stable. Let $v(x) = v(y)$. Then $x \in \text{cl}_v(\{y\})$. By closure stability, $\exists z \in \{y\}$ with $p(x) = p(z)$. Since $z = y$, we get $p(x) = p(y)$. $\square$

**Remark.** The forward direction uses singleton sets as "discriminators" — this is the key insight that the closure, despite being defined on all subsets, is already determined by its action on singletons.

## 6. Threshold Probes

**Definition 6.1** (Threshold Probe). For $n \in \mathbb{N}_\infty$:
$$p_n(x) = \begin{cases} 1 & \text{if } v(x) \leq n \\ 0 & \text{otherwise} \end{cases}$$

**Theorem 6.2.** Every threshold probe factors through $v$.

*Proof.* If $v(x) = v(y)$, then $v(x) \leq n \iff v(y) \leq n$, so $p_n(x) = p_n(y)$.

**Corollary 6.3.** Every threshold probe is closure-stable.

**Theorem 6.4** (Threshold Separation). If $v(x) \neq v(y)$, then $\exists n$ with $p_n(x) \neq p_n(y)$.

*Proof.* Since $\mathbb{N}_\infty$ is linearly ordered and $v(x) \neq v(y)$, either $v(x) < v(y)$ or $v(y) < v(x)$. In the first case, take $n = v(x)$: then $p_n(x) = 1$ but $v(y) > v(x) = n$ gives $p_n(y) = 0$.

## 7. Multiplicative Compatibility

**Theorem 7.1** (Tropical Functoriality). Let $v$ be a tropical valuation on a commutative semiring $R$. If $v(x) = v(a)$ and $v(y) = v(b)$, then $v(xy) = v(ab)$.

*Proof.* $v(xy) = v(x) + v(y) = v(a) + v(b) = v(ab)$.

**Corollary 7.2.** If $x \in \text{cl}_v(\{a\})$ and $y \in \text{cl}_v(\{b\})$, then $xy \in \text{cl}_v(\{ab\})$.

**Remark.** This corollary says the level-set closure is compatible with the ring multiplication: the closure of a product factors through the closures of the factors. This is the functorial property that justifies calling the valuation a "tropical functor." Note that the analogous statement for addition is *not* true in general, because addition can cause cancellation that increases the valuation.

## 8. Closure Equivalence

### 8.1 Closure Determines Partition

**Theorem 8.1.** If $\text{cl}_{v_1} = \text{cl}_{v_2}$ as operators $\mathcal{P}(\sigma) \to \mathcal{P}(\sigma)$, then for all $x, y$: $v_1(x) = v_1(y) \iff v_2(x) = v_2(y)$.

*Proof.* For any $y$, $\text{cl}_{v_1}(\{y\}) = \text{cl}_{v_2}(\{y\})$ by hypothesis. So $\{x \mid v_1(x) = v_1(y)\} = \{x \mid v_2(x) = v_2(y)\}$. The conclusion follows by membership.

### 8.2 Partition Determines Closure

**Theorem 8.2.** If $v_1(x) = v_1(y) \iff v_2(x) = v_2(y)$ for all $x, y$, then $\text{cl}_{v_1} = \text{cl}_{v_2}$.

*Proof.* For any $S$ and $x$: $x \in \text{cl}_{v_1}(S) \iff \exists s \in S,\, v_1(x) = v_1(s) \iff \exists s \in S,\, v_2(x) = v_2(s) \iff x \in \text{cl}_{v_2}(S)$.

### 8.3 Complete Characterization

**Theorem 8.3** (Iff). $\text{cl}_{v_1} = \text{cl}_{v_2}$ if and only if $v_1$ and $v_2$ induce the same partition on $\sigma$.

**Interpretation.** The closure operator remembers exactly the *partition structure* of the valuation. The 2-adic and 3-adic valuations on $\mathbb{N}$ give different closures because they partition $\mathbb{N}$ differently (e.g., 4 and 9 are in the same 3-adic fiber but different 2-adic fibers).

## 9. Functoriality

**Theorem 9.1.** Let $f : \sigma \to \tau$ satisfy $w(f(x)) = v(x)$ for all $x$. Then $f(\text{cl}_v(S)) \subseteq \text{cl}_w(f(S))$.

**Theorem 9.2.** If additionally $f$ is surjective, then $f(\text{cl}_v(S)) = \text{cl}_w(f(S))$.

**Theorem 9.3** (Refinement). If $v(x) = v(y) \implies w(x) = w(y)$ for all $x, y$ (i.e., $v$ is finer than $w$), then $\text{cl}_v(S) \subseteq \text{cl}_w(S)$ for all $S$.

## 10. Threshold Filtration

### 10.1 Definition

**Definition 10.1.** $\text{cl}_n(S) = \{x \mid v(x) \leq n\} \cup S$.

### 10.2 Properties

**Theorem 10.2.** $\text{cl}_n$ is extensive, set-monotone, and idempotent.

**Theorem 10.3** (Scale Monotonicity). $m \leq n \implies \text{cl}_m(S) \subseteq \text{cl}_n(S)$.

**Theorem 10.4** (Absorption). $m \leq n \implies \text{cl}_n(\text{cl}_m(S)) = \text{cl}_n(S)$.

*Proof.* $\text{cl}_n(\text{cl}_m(S)) = \{x \mid v(x) \leq n\} \cup \{x \mid v(x) \leq m\} \cup S = \{x \mid v(x) \leq n\} \cup S = \text{cl}_n(S)$, using $\{x \mid v(x) \leq m\} \subseteq \{x \mid v(x) \leq n\}$ when $m \leq n$.

### 10.3 Defect

**Definition 10.5.** The *threshold defect* $D(m, n, S) = \text{cl}_n(S) \setminus \text{cl}_m(S)$.

**Theorem 10.6.** For $x \in D(m, n, S) \setminus S$: $m < v(x) \leq n$.

## 11. The p-Adic Instance

For a prime $p$, the extended multiplicity $\text{emult}(p, \cdot) : \mathbb{N} \to \mathbb{N}_\infty$ is a tropical valuation on $(\mathbb{N}, \cdot, +)$. This is verified using Mathlib's `emultiplicity_zero`, `emultiplicity_one`, `emultiplicity_mul`, and `min_le_emultiplicity_add`.

The induced closure system on $\mathbb{N}$ groups numbers by their $p$-adic valuation. Different primes give genuinely different closure systems.

## 12. Algorithms

### 12.1 Computing the Level-Set Closure

Given a finite set $S$ and an efficiently computable valuation $v$:

```
function LevelSetClosure(v, S, domain):
    V = {v(s) : s ∈ S}          # valuation image
    return {x ∈ domain : v(x) ∈ V}  # preimage of image
```

Time complexity: $O(|S| + |\text{domain}|)$ assuming $O(1)$ valuation computation.

### 12.2 Computing Threshold Probes

```
function ThresholdProbeVector(v, element, max_scale):
    return [1 if v(element) ≤ n else 0 for n in range(max_scale + 1)]
```

### 12.3 Testing Closure Equivalence

```
function AreCosureEquivalent(v1, v2, domain):
    for x in domain:
        for y in domain:
            if (v1(x) == v1(y)) != (v2(x) == v2(y)):
                return False
    return True
```

## 13. Discussion

### 13.1 Universal Property

The level-set closure has a clean universal property: it is the coarsest closure operator that makes all $v$-dependent observables stable. Any coarser closure would fail to preserve some observable that depends only on $v$; any finer closure would unnecessarily restrict the stable observables.

### 13.2 Comparison with Classical Approaches

Classical tropical geometry defines the *tropical variety* of an ideal as the corner locus of the tropicalization of its generators. Our level-set closure provides a complementary, set-theoretic perspective: rather than studying the geometry of tropical varieties, we study the *observational structure* that the valuation imposes on the underlying algebra.

### 13.3 Connection to Automata Theory

The closure-stable probe characterization connects to the Myhill-Nerode theorem in automata theory: two strings are equivalent iff no probe (future context) distinguishes them. Our theorem provides the analogous result for valuation-based equivalence: two elements are equivalent iff no $v$-factoring probe distinguishes them.

### 13.4 Limitations

The level-set closure uses only the *equality* structure of the valuation, not the *order* structure. The threshold filtration exploits the order structure to give a richer family of closures. Combining the level-set closure with the threshold filtration — perhaps via a "metric closure" that groups elements within $\epsilon$ of each other in valuation — is a natural direction for future work.

## 14. Future Work

1. **Metric closure**: Define $\text{cl}_\epsilon(S) = \{x \mid \exists s \in S,\, |v(x) - v(s)| \leq \epsilon\}$ and characterize its stable probes.

2. **Tropical convex hull**: Connect the level-set closure to tropical convex geometry, showing that the closure of a linear combination lies in the tropical hull of the closure of the coefficients.

3. **Derived invariants**: Define the "closure rank" of a set (the number of distinct valuations of its elements) and study its behavior under algebraic operations.

4. **Computational complexity**: Analyze the complexity of closure-based invariants for lattice problems, connecting to post-quantum security parameters.

## 15. Conclusion

We have established a precise, formally verified bridge from tropical valuations to closure-stable probe systems. The main characterization theorem — closure stability equals valuation factoring — provides a complete dictionary between algebraic and observational structure. The multiplicative compatibility result shows this bridge is functorial: it preserves the essential algebraic operations. The closure equivalence characterization shows the bridge is information-theoretically optimal: it remembers exactly the partition structure of the valuation. These results formalize the intuition that tropicalization is a canonical "forgetting" functor, and make precise what is remembered and what is lost.

## References

1. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry*. Graduate Studies in Mathematics, vol. 161, AMS, 2015.

2. Birkhoff, G. *Lattice Theory*, 3rd ed. AMS Colloquium Publications, 1967.

3. Davey, B. A. and Priestley, H. A. *Introduction to Lattices and Order*, 2nd ed. Cambridge University Press, 2002.

4. Viro, O. "Dequantization of real algebraic geometry on logarithmic paper." *European Congress of Mathematics*, 2001.

5. Mikhalkin, G. "Enumerative tropical algebraic geometry in ℝ²." *Journal of the AMS*, 18(2):313–377, 2005.
