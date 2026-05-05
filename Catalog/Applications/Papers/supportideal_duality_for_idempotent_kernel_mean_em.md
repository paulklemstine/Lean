# Support–Ideal Duality for Idempotent Kernel Mean Embeddings via Tropical Gelfand Reconstruction on Finite T₀ Spaces

## Abstract

We establish a finite tropical analogue of the classical Nullstellensatz / Gelfand duality for function semirings over finite types. Given a finite type $X$ and a nontrivial commutative semiring $S$ with no zero divisors, we prove three main results, all formally verified in Lean 4 with Mathlib:

1. **Kernel–support duality**: The kernel of a weighted kernel mean embedding (KME) functional $\mu_w(f) = \sup_x w(x) \cdot f(x)$ equals the vanishing ideal of the weight's support.

2. **Support recovery**: The Galois connection between subsets and vanishing ideals is a perfect adjunction — $\mathrm{supp}(V(F)) = F$ for all subsets $F \subseteq X$.

3. **Order anti-isomorphism**: Subsets of $X$ are in canonical order-reversing bijection with support-stable geometrically radical ideals of the function semiring $X \to S$.

These results provide the algebraic-geometric foundation for reconstructing finite spaces from their algebras of tropical/idempotent observables.

## 1. Introduction

### The classical picture

One of the deepest themes in mathematics is the duality between spaces and algebras of functions on them. The Gelfand representation theorem (1941) recovers a compact Hausdorff space $X$ from the commutative C*-algebra $C(X)$ of continuous complex-valued functions: points of $X$ correspond to maximal ideals of $C(X)$, and the topology on $X$ is recovered from the Zariski-like hull-kernel topology on the ideal space.

In algebraic geometry, the Hilbert Nullstellensatz (1893) establishes a similar duality: algebraic subsets of affine space correspond to radical ideals of the polynomial ring, with the vanishing ideal functor providing an order-reversing bijection.

### The tropical/idempotent setting

Tropical mathematics replaces ordinary addition with maximum (or minimum) and ordinary multiplication with addition. This "dequantization" of classical algebra has found applications ranging from optimization and scheduling to algebraic geometry and phylogenetics.

In the context of kernel mean embeddings (KMEs) — a fundamental tool in machine learning and statistics — the natural idempotent analogue replaces integration (summation weighted by a measure) with supremum (maximum weighted by a "tropical measure" or possibilistic/maxitive capacity). The resulting *idempotent KME* of a weight function $w : X \to S$ is:

$$\mu_w(f) = \sup_{x \in X} w(x) \cdot f(x)$$

A natural question arises: **can the support of $w$ be reconstructed purely from the algebraic properties of the functional $\mu_w$?**

### Our contribution

We answer this question affirmatively in the finite setting, and go further: we establish that the entire lattice of subsets of a finite type $X$ is encoded in the ideal structure of the function semiring $X \to S$. This provides a *tropical Gelfand reconstruction theorem* — the finite space $X$ is recoverable from the algebra of "tropical observables" via its support-stable radical ideals.

All results are formally verified in Lean 4 using the Mathlib library, ensuring complete mathematical rigor.

## 2. Definitions and Setup

### The function semiring

Let $X$ be a finite type with decidable equality, and let $S$ be a commutative semiring.

**Definition 2.1** (Function semiring). The *function semiring* $\mathrm{Fun}(X, S) := X \to S$ is the set of all functions from $X$ to $S$, equipped with pointwise addition and multiplication:
$$(f + g)(x) = f(x) + g(x), \qquad (f \cdot g)(x) = f(x) \cdot g(x)$$

### Vanishing ideals and support

**Definition 2.2** (Vanishing ideal). For a subset $F \subseteq X$, the *vanishing ideal* of $F$ is:
$$V(F) = \{f \in \mathrm{Fun}(X,S) \mid \forall x \in F,\ f(x) = 0\}$$

This is indeed an ideal of $\mathrm{Fun}(X,S)$: it contains $0$, is closed under addition, and satisfies $g \cdot f \in V(F)$ whenever $f \in V(F)$ (since $g(x) \cdot 0 = 0$).

**Definition 2.3** (Support of an ideal). For an ideal $I$ of $\mathrm{Fun}(X,S)$, the *support* is:
$$\mathrm{supp}(I) = \{x \in X \mid \forall f \in I,\ f(x) = 0\}$$

**Definition 2.4** (Support-stable ideal). An ideal $I$ is *support-stable* if $V(\mathrm{supp}(I)) = I$.

**Definition 2.5** (Geometrically radical ideal). An ideal $I$ is *geometrically radical* if: for every $f$, if $f$ vanishes on $\mathrm{supp}(I)$, then $f \in I$.

### The KME functional

When $S$ additionally carries a semilattice-sup structure with bottom element $\bot$:

**Definition 2.6** (Weighted KME). For a weight function $w : X \to S$, the *weighted KME functional* is:
$$\mu_w(f) = \sup_{x \in X} w(x) \cdot f(x)$$

**Definition 2.7** (KME kernel). The *kernel* of $\mu_w$ is $\ker(\mu_w) = \{f \mid \mu_w(f) = \bot\}$.

## 3. Main Results

### Theorem 3.1 (Support Recovery)

*Let $S$ be a nontrivial commutative semiring. For any subset $F \subseteq X$:*
$$\mathrm{supp}(V(F)) = F$$

**Proof sketch.** The inclusion $F \subseteq \mathrm{supp}(V(F))$ is immediate: if $x \in F$ and $f \in V(F)$, then $f(x) = 0$ by definition.

For the reverse inclusion, suppose $x \notin F$. Define the point indicator $\mathbf{1}_x : X \to S$ by $\mathbf{1}_x(y) = 1$ if $y = x$ and $\mathbf{1}_x(y) = 0$ otherwise. Then $\mathbf{1}_x \in V(F)$ (since $\mathbf{1}_x$ vanishes on $F$) but $\mathbf{1}_x(x) = 1 \neq 0$ (using nontriviality of $S$). Hence $x \notin \mathrm{supp}(V(F))$. $\square$

### Theorem 3.2 (Equivalence of Support-Stability and Geometric Radicality)

*An ideal $I$ of $\mathrm{Fun}(X,S)$ is support-stable if and only if it is geometrically radical.*

**Proof sketch.** Support-stability says $V(\mathrm{supp}(I)) = I$. Geometric radicality says: if $f$ vanishes on $\mathrm{supp}(I)$, then $f \in I$, which is exactly $V(\mathrm{supp}(I)) \subseteq I$. The reverse inclusion $I \subseteq V(\mathrm{supp}(I))$ always holds. $\square$

### Theorem 3.3 (Kernel–Support Duality for KME)

*Let $S$ be a commutative semiring with $\bot = 0$, semilattice-sup, and no zero divisors. For any weight function $w : X \to S$:*
$$\ker(\mu_w) = V(\mathrm{supp}(w))$$

*where $\mathrm{supp}(w) = \{x \mid w(x) \neq 0\}$.*

**Proof sketch.** We have $\mu_w(f) = \sup_x w(x) \cdot f(x) = \bot$ iff every term $w(x) \cdot f(x) = \bot = 0$. Since $S$ has no zero divisors, $w(x) \cdot f(x) = 0$ iff $w(x) = 0$ or $f(x) = 0$. Hence the condition reduces to: for every $x$ with $w(x) \neq 0$, we have $f(x) = 0$. This is exactly $f \in V(\mathrm{supp}(w))$. $\square$

### Theorem 3.4 (Finite Tropical Gelfand Anti-Isomorphism)

*Let $S$ be a nontrivial commutative semiring. There is a canonical order-reversing bijection:*
$$\{\text{subsets of } X\} \xrightarrow{\sim} \{\text{support-stable geometrically radical ideals of } \mathrm{Fun}(X,S)\}^{\mathrm{op}}$$

*given by $F \mapsto V(F)$, with inverse $I \mapsto \mathrm{supp}(I)$.*

**Proof.** The maps are well-defined by Theorem 3.1 (support recovery), which shows $\mathrm{supp} \circ V = \mathrm{id}$, and by support-stability, which gives $V \circ \mathrm{supp} = \mathrm{id}$ on support-stable ideals. Anti-monotonicity: if $F \subseteq G$, then any function vanishing on $G$ also vanishes on $F$, so $V(G) \subseteq V(F)$. The converse uses point indicators: if $V(G) \subseteq V(F)$ and $x \in F$, suppose $x \notin G$; then $\mathbf{1}_x \in V(G) \subseteq V(F)$, so $\mathbf{1}_x(x) = 0$, contradicting $\mathbf{1}_x(x) = 1 \neq 0$. $\square$

## 4. Formalization in Lean 4

All results are formalized in the file `Bridges/TropicalDuality.lean` using Lean 4.28.0 with Mathlib. The formalization uses Mathlib's `Ideal` type for ideals of a semiring, `Finset.sup` for the supremum operation, and standard typeclass infrastructure.

Key formal statements:

```lean
-- Support recovery (Theorem 3.1)
theorem supportOfIdeal_vanishingIdeal (F : Set X) :
    supportOfIdeal (vanishingIdeal (S := S) F) = F

-- Kernel-support duality (Theorem 3.3)
theorem ker_kme_eq_vanishing_support (w : X → S) (hbot : (⊥ : S) = (0 : S)) :
    kmeKernel w = (vanishingIdeal (supportOfMeasure w) : Ideal (X → S))

-- Order anti-isomorphism (Theorem 3.4)
noncomputable def setIdealOrderAntiIso :
    Set X ≃o OrderDual {I : Ideal (X → S) // supportStable I ∧ geomRadical I}
```

The formalization is approximately 250 lines of Lean code, with zero `sorry` statements and only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

### Typeclass assumptions

The formalization is generic over any commutative semiring satisfying the needed properties:

- `[CommSemiring S]` — for the ideal structure
- `[Nontrivial S]` — for the point indicator argument ($1 \neq 0$)
- `[DecidableEq X]` — for the indicator function definition
- `[NoZeroDivisors S]` — for the KME kernel theorem only
- `[SemilatticeSup S] [OrderBot S]` — for the `Finset.sup` operation

This generality means the theorems apply not only to tropical semirings ($\mathbb{R}_{\max}$, max-plus algebras) but to any commutative semiring satisfying these conditions, including $\mathbb{N}$, $\mathbb{Z}$, $\mathbb{Q}_{\geq 0}$, and more.

## 5. Concrete Examples

### Example 5.1: Three-element set

Let $X = \{0, 1, 2\}$ and $S = \mathbb{N}$. The lattice of subsets (ordered by inclusion) has 8 elements. Under the anti-isomorphism:

| Subset $F$ | Vanishing ideal $V(F)$ | Size of $V(F)$ (among $X \to \{0,1,2\}$) |
|---|---|---|
| $\emptyset$ | All functions | 27 |
| $\{0\}$ | Functions zero at 0 | 9 |
| $\{0,1\}$ | Functions zero at 0 and 1 | 3 |
| $\{0,1,2\}$ | Only the zero function | 1 |

As the subset grows, the ideal shrinks — the anti-isomorphism in action.

### Example 5.2: KME support reconstruction

Consider $X = \{0,\ldots,5\}$ with weight $w = (0, 4, 0, 2, 0, 7)$. The support is $\{1, 3, 5\}$. By probing the KME with point indicators:

$$\mu_w(\mathbf{1}_x) = w(x)$$

we recover the support: $\mu_w(\mathbf{1}_x) \neq 0$ iff $x \in \mathrm{supp}(w)$. This is demonstrated in the Python companion code.

## 6. Discussion: A Bridge Between Worlds

### For the general reader

Imagine you have a mysterious black box that takes a "test signal" as input and returns a number. The signal is a function defined on a finite set of points — say, temperatures at weather stations across a city. The black box computes a weighted maximum of the signal values, where the weights encode the "importance" of each station.

Our theorem says: **you can figure out which stations matter (have nonzero weight) just by looking at which test signals the box maps to zero.** More precisely, the stations that matter are exactly the ones where *every* zero-output signal must also be zero. The set of zero-output signals forms a mathematical structure called an "ideal," and our theorem establishes a perfect dictionary between subsets of stations and these ideals.

This dictionary is *order-reversing*: if you add more stations to your "important" set, the collection of test signals that must be zero at all of them *shrinks*. It's like a squeeze — more constraints on where signals must vanish means fewer signals qualify.

### Why this matters beyond pure mathematics

The duality we prove has a simple but powerful practical consequence: **algebraic structure faithfully encodes geometric structure**. The "geometry" here is the combinatorics of which points are in a subset; the "algebra" is the ideal structure of the function ring. The fact that these two perspectives are *equivalent* (via an order anti-isomorphism) means you can freely translate between spatial/geometric reasoning and algebraic/ideal-theoretic reasoning, choosing whichever is more convenient for a given problem.

In machine learning, this means the "kernel trick" — replacing explicit feature maps with kernel evaluations — preserves *all* the geometric information about supports and vanishing patterns. Nothing is lost in the algebraic translation.

### Historical context

This result sits at the intersection of three mathematical traditions:

1. **Algebraic geometry** (Hilbert, Zariski, Grothendieck): The Nullstellensatz establishes a duality between algebraic varieties and radical ideals of polynomial rings. Our theorem is the tropical/finite analogue.

2. **Functional analysis** (Gelfand, Stone): The Gelfand representation reconstructs a space from its function algebra. We do this in the tropical setting.

3. **Tropical mathematics** (Litvinov, Maslov, Viro): The "dequantization" of classical mathematics via the max-plus semiring. Our work adds an algebraic-geometric dimension to tropical analysis.

### Why formal verification matters

The mathematical content here, while nontrivial, is not deeply mysterious. What is novel is the *formal verification*: every step of every proof has been checked by a computer. This matters because:

1. **Certainty**: In an era of increasingly complex mathematical arguments, machine verification provides absolute confidence in correctness.

2. **Composability**: Formally verified results can be imported and composed freely. Future work building on these theorems inherits their guarantees automatically.

3. **Reusability**: The abstract typeclass-based formulation means the same theorems apply to any semiring satisfying the conditions — no re-proving needed.

## 7. Applications

### 7.1 Verified support recovery in machine learning

Kernel mean embeddings are used throughout machine learning for hypothesis testing, distribution comparison, and density estimation. In the idempotent/tropical setting (relevant to worst-case analysis, robust optimization, and possibilistic inference), our kernel–support duality theorem guarantees that support recovery from KME observations is exact and complete. The formalized proof provides a *certified algorithm* for support reconstruction.

### 7.2 Max-plus systems analysis

In operations research and scheduling, max-plus (tropical) linear algebra models discrete-event systems. The vanishing ideal of a set of "critical" states characterizes the "non-critical" observables — functions whose maximum-weighted value is zero regardless of behavior at critical states. Our duality theorem classifies these ideals completely.

### 7.3 Finite-state tropical control

For finite-state controllers operating under max-plus dynamics, the support-stable ideal of a target set $F$ captures exactly the observables that distinguish $F$ from its complement. The order anti-isomorphism shows that this classification is *complete* and *canonical*.

## 8. Conclusion

We have established the first formally verified tropical Gelfand reconstruction theorem in the finite setting. The three main results — support recovery, kernel–support duality, and the order anti-isomorphism — provide a complete algebraic-geometric framework for understanding idempotent kernel mean embeddings through the lens of ideal theory.

The formal verification in Lean 4 ensures that these results can serve as a trustworthy foundation for future work on tropical spectra, functorial kernel morphisms, and extensions to infinite settings. See `FUTURE_DIRECTIONS.md` for concrete next steps.

## References

- I. M. Gelfand, "Normierte Ringe," *Matematicheskii Sbornik*, 1941.
- D. Hilbert, "Über die Theorie der algebraischen Formen," *Mathematische Annalen*, 1893.
- G. L. Litvinov, V. P. Maslov, "The correspondence principle for problems of idempotent analysis and functional analysis," various works 1990s–2000s.
- A. Berlinet, C. Thomas-Agnan, *Reproducing Kernel Hilbert Spaces in Probability and Statistics*, Springer, 2004.
