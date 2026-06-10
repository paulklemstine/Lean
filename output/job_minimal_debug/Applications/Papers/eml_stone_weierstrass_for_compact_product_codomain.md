# Stone–Weierstrass for Product Codomains via Factorwise Approximation and Diagonal Assembly

## Abstract

We prove, in Lean 4 with Mathlib, that uniform approximation of continuous maps lifts from individual metric codomains to their finite products. If classes $A_Y \subseteq C(X,Y)$ and $A_Z \subseteq C(X,Z)$ each uniformly approximate all continuous maps into their respective codomains, then the *paired class* $\{(g_Y, g_Z) : g_Y \in A_Y, g_Z \in A_Z\}$ uniformly approximates all continuous maps into $Y \times Z$. The proof is a three-line argument exploiting Mathlib's sup-metric structure on products: coordinatewise $\varepsilon$-approximation yields productwise $\varepsilon$-approximation with no need to halve the tolerance. We specialize the result to EML (exponential–multiplicative–logarithmic) approximation classes, demonstrating that universal approximation over product codomains follows formally from the scalar case.

**Keywords:** Stone–Weierstrass theorem, product metric, universal approximation, EML functions, continuous map spaces, formal verification, Lean 4

---

## 1. Introduction

The Stone–Weierstrass theorem tells us that sufficiently rich classes of functions are dense in spaces of continuous real-valued functions. A natural question arises: once we know a class $A$ can approximate continuous maps $X \to \mathbb{R}$, can it also approximate maps $X \to \mathbb{R}^n$? More generally, if $A_Y$ approximates maps into $Y$ and $A_Z$ approximates maps into $Z$, does the paired class approximate maps into $Y \times Z$?

The answer is yes, and the proof is almost trivial once one recognizes that the product metric on $Y \times Z$ is the *sup* (maximum) metric:

$$d_{Y \times Z}((y_1, z_1), (y_2, z_2)) = \max(d_Y(y_1, y_2), d_Z(z_1, z_2))$$

This identity means that coordinatewise $\varepsilon$-bounds immediately compose into a product $\varepsilon$-bound—no $\varepsilon/2$ splitting is needed. Despite its simplicity, this observation has significant structural consequences: it turns universal approximation from a collection of isolated results into a *compositional calculus* closed under finite products.

### 1.1 Why formalize this?

The theorem itself is mathematically routine. Its value lies in three dimensions:

1. **Compositionality.** It provides a certified building block: prove approximation for basic codomains once, then obtain product results for free. This is the correct pattern for scaling universal approximation theorems.

2. **Infrastructure for EML.** The EML (exponential–multiplicative–logarithmic) program aims to show that a specific class of functions is a universal approximator. Product closure is a necessary step toward multi-output EML networks.

3. **Formal verification discipline.** Even "obvious" theorems can hide subtle issues with metric instances, universe levels, or typeclass resolution. Formalizing in Lean 4 ensures the argument is watertight and machine-checkable.

---

## 2. Mathematical Content

### 2.1 Setup

Let $X$ be a topological space and $(Y, d_Y)$, $(Z, d_Z)$ pseudo-metric spaces. The product $Y \times Z$ carries the metric

$$d_{Y \times Z}(a, b) = \max(d_Y(a_1, b_1), d_Z(a_2, b_2))$$

which is Mathlib's `Prod.dist_eq`. Given sets $A_Y \subseteq C(X, Y)$ and $A_Z \subseteq C(X, Z)$, define the **paired class**:

$$\text{PairClass}(A_Y, A_Z) = \{(g, h) : g \in A_Y, h \in A_Z\} \subseteq C(X, Y \times Z)$$

where we identify $(g, h)$ with the map $x \mapsto (g(x), h(x))$.

### 2.2 Key Lemma: Product Metric Estimate

**Lemma** (`dist_prod_mk_lt_of_lt`). *If $d_Y(y_1, y_2) < \varepsilon$ and $d_Z(z_1, z_2) < \varepsilon$, then $d_{Y \times Z}((y_1, z_1), (y_2, z_2)) < \varepsilon$.*

*Proof.* By `Prod.dist_eq`, the left-hand side equals $\max(d_Y(y_1, y_2), d_Z(z_1, z_2))$, and the maximum of two quantities each $< \varepsilon$ is $< \varepsilon$. ∎

### 2.3 Decomposition Identity

**Lemma** (`ContinuousMap.prodMk_projFst_projSnd`). *For any $f : C(X, Y \times Z)$, we have*
$$\text{prodMk}(f.\text{projFst}, f.\text{projSnd}) = f$$

This is the categorical product property: a map into a product is determined by its coordinate projections.

### 2.4 Main Theorem

**Theorem** (`pairClass_uniform_dense`). *Let $A_Y \subseteq C(X, Y)$ and $A_Z \subseteq C(X, Z)$ be uniformly dense: for every $f \in C(X, Y)$ and $\varepsilon > 0$ there exists $g \in A_Y$ with $d_Y(g(x), f(x)) < \varepsilon$ for all $x$, and similarly for $A_Z$. Then $\text{PairClass}(A_Y, A_Z)$ is uniformly dense in $C(X, Y \times Z)$.*

*Proof.* Given $f : C(X, Y \times Z)$ and $\varepsilon > 0$:
1. Set $f_Y = f.\text{projFst}$ and $f_Z = f.\text{projSnd}$.
2. Choose $g_Y \in A_Y$ with $d_Y(g_Y(x), f_Y(x)) < \varepsilon$ for all $x$.
3. Choose $g_Z \in A_Z$ with $d_Z(g_Z(x), f_Z(x)) < \varepsilon$ for all $x$.
4. Set $g = \text{prodMk}(g_Y, g_Z) \in \text{PairClass}(A_Y, A_Z)$.
5. For each $x$: $d_{Y \times Z}(g(x), f(x)) = \max(d_Y(g_Y(x), f_Y(x)), d_Z(g_Z(x), f_Z(x))) < \varepsilon$. ∎

### 2.5 Ternary Extension

**Corollary** (`pairClass_uniform_dense_triple`). *The theorem extends to $Y \times Z \times W$ by two applications of the binary case, since Lean's product type is right-associated: $Y \times Z \times W = Y \times (Z \times W)$.*

### 2.6 EML Specialization

**Theorem** (`eml_uniform_dense_prod`). *For any predicate $P$ on continuous maps, if $P$-maps approximate maps into $Y$ and $Z$ separately, and $P$ is closed under pairing, then $P$-maps approximate maps into $Y \times Z$.*

This is the same argument with $A_Y = \{g : P_Y(g)\}$, $A_Z = \{g : P_Z(g)\}$, and the pairing closure hypothesis providing $P_{Y \times Z}(\text{prodMk}(g_Y, g_Z))$.

---

## 3. Formal Verification

### 3.1 Lean 4 Implementation

The complete formalization is in `EML/ProductApproximation.lean` (≈210 lines). All 10 theorems compile without `sorry` and depend only on standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

Key design decisions:
- **Projection definitions.** We define `ContinuousMap.projFst` and `ContinuousMap.projSnd` rather than using Mathlib's `ContinuousMap.fst`/`.snd`, which are projections *from* a product domain rather than *into* a product codomain.
- **No universe polymorphism issues.** The EML specialization uses three separate predicates `PY`, `PZ`, `PYZ` rather than a single universe-polymorphic predicate, avoiding Lean's universe constraint solver.
- **The sup metric is definitional.** `Prod.dist_eq` is a propositional equality, but `max_lt` closes the product estimate in one step—no coercion or rewriting friction.

### 3.2 Axiom Audit

Every theorem in the file depends only on:
- `propext` (propositional extensionality)
- `Classical.choice` (axiom of choice)
- `Quot.sound` (quotient soundness)

No `sorry`, no custom axioms, no `@[implemented_by]`.

---

## 4. Applications

### 4.1 Multi-output neural networks

The most immediate application is to neural network universal approximation. If a network architecture (e.g., EML networks) can approximate any continuous function $X \to \mathbb{R}$, then by our theorem, the same architecture with paired outputs can approximate any continuous function $X \to \mathbb{R}^n$—simply by approximating each output coordinate independently and combining. This is the standard practice in machine learning (using multiple output neurons), and our theorem provides the formal justification.

### 4.2 Control systems

In control theory, one often needs to approximate a continuous feedback law $u : X \to \mathbb{R}^m$ where $m$ is the number of control inputs. The product theorem guarantees that any approximation class sufficient for scalar control extends to vector-valued control laws.

### 4.3 Computer graphics and simulation

Shape approximation, color space mappings, and physics simulations often require approximating maps into $\mathbb{R}^3$ or higher-dimensional spaces. The product theorem ensures that any 1D approximation scheme extends to multi-dimensional outputs.

### 4.4 Compositional approximation theory

More abstractly, the theorem establishes that the collection of "approximable codomains" is closed under finite products. This is a category-theoretic closure property: if $Y$ and $Z$ are approximable, so is $Y \times Z$. Future work can extend this to:
- Convex compact codomains (via embedding into products of intervals)
- ANRs (absolute neighborhood retracts)
- Embedded manifolds

---

## 5. Discussion: The Lego Principle of Approximation

*For a general audience*

Imagine you're an artist who has mastered drawing straight lines. Can you draw any picture? The Stone–Weierstrass theorem says: essentially, yes—any continuous curve can be approximated by combinations of simple building blocks.

But what about drawing in color? A color image is really three images—one for red, one for green, one for blue. If you can approximate any grayscale image, can you approximate any color image?

Our theorem says: of course! Just approximate each color channel separately and combine the results. This sounds obvious, but there's a subtlety: how do you measure the error of a color approximation? If the red channel is off by 0.01 and the green channel is off by 0.02, is the overall color error 0.01 + 0.02 = 0.03? Or something else?

The answer depends on which "ruler" you use to measure color differences. The *sup metric* (or *max metric*) says the overall error is $\max(0.01, 0.02) = 0.02$—the error is only as bad as the worst channel. This is the metric that Lean's Mathlib library uses for product spaces, and it's the one that makes our theorem work most cleanly: if each channel is within $\varepsilon$, the overall color is within $\varepsilon$. No need to be more careful.

This might seem like a small observation, but it has a powerful consequence. It means that approximation theory is *modular*: once you prove a result for one-dimensional outputs, you get multi-dimensional outputs for free. You don't need to redo the hard work of approximation theory every time you add a dimension. This is the "Lego principle"—snap together building blocks to build bigger structures.

In machine learning, this principle justifies the common practice of using multiple output neurons: if a single-output network is a universal approximator, then a multi-output network (which is just several single-output networks running in parallel) is also a universal approximator for vector-valued functions.

### Historical context

The Stone–Weierstrass theorem (1937, 1948) generalized Weierstrass's 1885 result on polynomial approximation. Marshall Stone showed that any subalgebra of continuous functions that separates points and contains the constants is dense. Our result is a modest but structurally important extension: it shows how to *compose* approximation results across product spaces.

The formal verification in Lean 4 is part of a broader program to build machine-checkable foundations for approximation theory, particularly for EML (exponential–multiplicative–logarithmic) function classes. The EML program aims to identify computationally efficient universal approximators with algebraic closure properties—and product closure is one of the first such properties to formalize.

---

## 6. Future Directions

1. **Finite products via induction.** Extend from binary to $n$-ary products $Y_1 \times \cdots \times Y_n$ by induction, proving that $\text{PairClass}$ composes associatively.

2. **Function spaces.** If $Y$ is a function space $C(A, B)$, can product closure be used to derive approximation for $C(X, C(A, B))$?

3. **Metric dependence.** The theorem works for the sup metric on products. What happens for the $L^p$ product metric $d_p((y_1,z_1),(y_2,z_2)) = (d_Y^p + d_Z^p)^{1/p}$? The same argument gives a bound of $(2\varepsilon^p)^{1/p} = 2^{1/p}\varepsilon$, which is still sufficient for density but with a constant factor.

4. **Subalgebra formulation.** Connect `PairClass` to the tensor product of subalgebras: if $A_Y$ generates a dense subalgebra of $C(X, \mathbb{R})$ (via composition with projection), does the product closure theorem follow from the algebraic tensor product structure?

5. **EML pairing constructor.** Formalize the syntactic closure of EML expressions under pairing, providing the `hpair` hypothesis needed by `eml_uniform_dense_prod`.

---

## 7. Conclusion

We have formally verified in Lean 4 that uniform approximation of continuous maps is closed under finite products of codomains, when the product carries the sup metric. The proof is short (the main theorem is three lines after the setup lemmas) but structurally important: it transforms universal approximation from a per-codomain theorem into a compositional calculus. The specialization to EML predicates provides a template for extending the EML universal approximation program to multi-output function classes.

All code is available at `EML/ProductApproximation.lean` and `EML/demo_product_approximation.py`.

---

## Appendix: Theorem Catalog

| Theorem | Statement (informal) |
|---------|---------------------|
| `dist_prod_le_max` | $d_{Y \times Z}(a,b) \le \max(d_Y(a_1,b_1), d_Z(a_2,b_2))$ |
| `dist_prod_mk_lt_of_lt` | Coordinatewise $< \varepsilon$ implies productwise $< \varepsilon$ |
| `ContinuousMap.prodMk_projFst_projSnd` | $\text{prodMk}(f.\text{projFst}, f.\text{projSnd}) = f$ |
| `pairClass_uniform_dense` | Main theorem: PairClass is uniformly dense |
| `denseRange_pair_of_denseRange_fst_snd` | Alternative formulation with explicit witnesses |
| `eml_uniform_dense_prod` | Specialization to any EML-like predicate |
| `pairClass_uniform_dense_triple` | Ternary product corollary |
| `PairClass_mono` | PairClass is monotone in both arguments |
| `PairClass_projFst_mem` | First projection of PairClass element is in $A_Y$ |
| `PairClass_projSnd_mem` | Second projection of PairClass element is in $A_Z$ |
