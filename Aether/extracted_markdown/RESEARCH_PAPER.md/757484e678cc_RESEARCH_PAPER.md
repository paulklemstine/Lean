# The Category of EML-Computable Maps: Categorical Foundations for Exp-Log Computation

## Abstract

We introduce **EML_Comp**, the category whose objects are finite-dimensional Euclidean spaces $\mathbb{R}^n$ (indexed by natural numbers) and whose morphisms are functions $\mathbb{R}^n \to \mathbb{R}^m$ expressible as finite compositions of exponential, logarithm, addition, multiplication, and constants. We prove that EML_Comp satisfies the three category axioms (identity, composition closure, associativity), possesses a terminal object ($\mathbb{R}^0$), and has finite binary products (via $\mathbb{R}^{n+m}$ with coordinate projections and universal pairing). We establish that $\exp$ and $\log$ form a retraction pair in EML_Comp, prove a currying theorem for parameter splitting, construct the endomorphism monoid $\text{End}(\mathbb{R}^n)$, and develop a derivation depth hierarchy with a strict inclusion $D_0 \subsetneq D_1$ and a depth–size inequality $\text{depth}(d) \leq \text{size}(d)$. All results are formalized in Lean 4 with Mathlib.

**Keywords:** EML computation, category theory, finite products, derivation depth, retraction, exp-log algebra.

---

## 1. Introduction

The class of functions built from $\exp$, $\log$, $+$, $\times$, and constants—which we call **EML-computable functions** (for Exp-Minus-Log)—appears throughout applied mathematics: neural network architectures (softmax, log-sum-exp, attention), statistical models (exponential families, log-linear models), signal processing, and numerical analysis. Despite their ubiquity, these functions have not previously been studied as a *categorical* object.

This paper places EML computation on firm categorical foundations. We define a category EML_Comp, prove it has finite products (but not full exponentials), and develop a quantitative complexity theory via derivation depth.

### 1.1 Related Work

The EML framework was introduced in the context of one-instruction set computing (OISCC), where it was shown that $\text{eml}(a, b) = \exp(a) - \log(b)$ is arithmetically complete on positive reals [OISCC theory]. The closure operator theory established that the EML functional closure satisfies extensivity, monotonicity, and idempotence. The present work extends these results by upgrading from closure operators (a lattice-theoretic perspective) to category theory (a compositional perspective).

### 1.2 Contributions

1. **Definition of EML_Comp** as a category with objects $\mathbb{N}$ and morphisms $\text{EMLMor}(n, m)$.
2. **Finite products** via $\mathbb{R}^{n+m}$, with projections, pairing, and the universal property.
3. **Retraction theorem**: $\log \circ \exp = \text{id}_{\mathbb{R}^1}$ as a morphism identity.
4. **Currying theorem**: parameter specialization preserves EML computability.
5. **Derivation depth theory**: a Type-valued derivation tree with depth and size measures, the depth–size inequality, and strict hierarchy.
6. **Endomorphism monoid**: $\text{End}(\mathbb{R}^n)$ is a monoid under composition.

---

## 2. Definitions

### 2.1 Scalar EML Computability

**Definition 2.1** (ScalarEML). The predicate $\text{ScalarEML}(n, f)$ asserts that $f : \mathbb{R}^n \to \mathbb{R}$ is EML-computable. It is defined inductively:

- **(coord)** $x \mapsto x_i$ is ScalarEML for each $i \in \text{Fin}(n)$.
- **(const)** $x \mapsto c$ is ScalarEML for each $c \in \mathbb{R}$.
- **(add)** If $f, g$ are ScalarEML, so is $x \mapsto f(x) + g(x)$.
- **(mul)** If $f, g$ are ScalarEML, so is $x \mapsto f(x) \cdot g(x)$.
- **(exp)** If $f$ is ScalarEML, so is $x \mapsto \exp(f(x))$.
- **(log)** If $f$ is ScalarEML, so is $x \mapsto \log(f(x))$.
- **(comp)** If $g : \mathbb{R}^m \to \mathbb{R}$ is ScalarEML and each $f_j : \mathbb{R}^n \to \mathbb{R}$ is ScalarEML, then $x \mapsto g(f_1(x), \ldots, f_m(x))$ is ScalarEML.

Note that $n$ is an *index*, not a parameter, of the inductive type, allowing the composition rule to change dimension.

### 2.2 Vector EML Computability

**Definition 2.2** (VecEMLComp). A function $f : \mathbb{R}^n \to \mathbb{R}^m$ is **vector EML-computable** if each output coordinate $x \mapsto f(x)_j$ is ScalarEML:

$$\text{VecEMLComp}(n, m, f) \iff \forall j \in \text{Fin}(m),\ \text{ScalarEML}(n, x \mapsto f(x)_j)$$

### 2.3 EML Morphisms

**Definition 2.3** (EMLMor). An EML morphism from $n$ to $m$ is a pair $(f, \pi)$ where $f : \mathbb{R}^n \to \mathbb{R}^m$ and $\pi$ is a proof that $\text{VecEMLComp}(n, m, f)$.

Two EML morphisms are equal when their underlying functions are equal (proof irrelevance).

### 2.4 Positive Vectors and Log-Affine Functions

**Definition 2.4** (PosVec). A positive vector $x \in (\mathbb{R}_{>0})^n$ is a function $x : \text{Fin}(n) \to \mathbb{R}$ with $x_i > 0$ for all $i$.

**Definition 2.5** (LogAffine). A function $f : (\mathbb{R}_{>0})^n \to \mathbb{R}$ is **log-affine** if there exist weights $w : \text{Fin}(n) \to \mathbb{R}$ and a constant $c$ such that:

$$f(x) = \exp\left(\sum_i w_i \cdot \log(x_i) + c\right)$$

---

## 3. Main Results

### 3.1 Category Axioms

**Theorem 3.1** (Identity). The identity function $\text{id} : \mathbb{R}^n \to \mathbb{R}^n$ is EML-computable.

*Proof.* Each coordinate $x \mapsto x_j$ is ScalarEML by the coord rule. □

**Theorem 3.2** (Composition). If $f : \mathbb{R}^n \to \mathbb{R}^m$ and $g : \mathbb{R}^m \to \mathbb{R}^k$ are EML-computable, then $g \circ f$ is EML-computable.

*Proof.* For each output coordinate $j$, $g(\cdot)_j$ is ScalarEML in $m$ variables, and each component of $f$ is ScalarEML in $n$ variables. By the comp rule, $x \mapsto g(f(x))_j$ is ScalarEML in $n$ variables. □

**Theorem 3.3** (Associativity). $(h \circ g) \circ f = h \circ (g \circ f)$ as EML morphisms.

*Proof.* Both sides have the same underlying function by associativity of function composition. By proof irrelevance for the VecEMLComp predicate, the morphisms are equal. □

### 3.2 Terminal Object

**Theorem 3.4** (Terminal). $\mathbb{R}^0$ is a terminal object: for every $n$, there exists a unique EML morphism $\mathbb{R}^n \to \mathbb{R}^0$.

*Proof.* The unique morphism sends everything to the empty tuple (the only element of $\mathbb{R}^0 = \text{Fin}(0) \to \mathbb{R}$, which is $\text{Fin.elim0}$). Uniqueness follows because any two functions to $\mathbb{R}^0$ agree on all inputs (there are no output coordinates to disagree on). □

### 3.3 Binary Products

**Theorem 3.5** (Products). $\mathbb{R}^{n+m}$ is the categorical product of $\mathbb{R}^n$ and $\mathbb{R}^m$ in EML_Comp.

*Proof.* The projections $\pi_1 : \mathbb{R}^{n+m} \to \mathbb{R}^n$ and $\pi_2 : \mathbb{R}^{n+m} \to \mathbb{R}^m$ extract the first $n$ and last $m$ coordinates respectively—both EML-computable by the coord rule.

Given EML morphisms $f : \mathbb{R}^k \to \mathbb{R}^n$ and $g : \mathbb{R}^k \to \mathbb{R}^m$, the pairing $\langle f, g \rangle : \mathbb{R}^k \to \mathbb{R}^{n+m}$ defined by $\text{Fin.addCases}(f(x), g(x))$ is EML-computable. The product laws $\pi_1 \circ \langle f, g \rangle = f$ and $\pi_2 \circ \langle f, g \rangle = g$ hold by computation. □

### 3.4 Diagonal (Comonoid Structure)

**Theorem 3.6** (Diagonal). The diagonal $\Delta = \langle \text{id}, \text{id} \rangle : \mathbb{R}^n \to \mathbb{R}^{2n}$ satisfies $\pi_1 \circ \Delta = \text{id}$ and $\pi_2 \circ \Delta = \text{id}$.

*Proof.* Immediate from the product laws applied to $f = g = \text{id}$. □

The diagonal enables *variable sharing*: when a variable appears multiple times in an EML expression, the diagonal duplicates it before feeding it to independent sub-expressions.

### 3.5 The exp-log Retraction

**Theorem 3.7** (Retraction). $\log \circ \exp = \text{id}_{\mathbb{R}^1}$ as EML morphisms.

*Proof.* Both morphisms are EML-computable by the exp and log rules. The equality $\log(\exp(x)) = x$ is the standard identity `Real.log_exp` applied coordinate-wise. □

**Theorem 3.8** (Partial section). For $x \in \mathbb{R}^1$ with $x_0 > 0$: $(\exp \circ \log)(x) = x$.

*Proof.* Uses `Real.exp_log` with the positivity hypothesis. □

This makes $(\mathbb{R}^1, \exp, \log)$ a retraction pair in EML_Comp. The positive reals are a retract of all reals.

### 3.6 Currying

**Theorem 3.9** (Currying). If $f : \mathbb{R}^{p+n} \to \mathbb{R}^m$ is EML-computable and $\theta \in \mathbb{R}^p$ is fixed, then $x \mapsto f(\theta, x)$ is EML-computable as a function $\mathbb{R}^n \to \mathbb{R}^m$.

*Proof.* The specialized function is obtained by composing $f$ with the map $x \mapsto (\theta, x)$, which is EML-computable (constants in the first $p$ coordinates, coordinates in the last $n$). Closure under composition gives the result. □

### 3.7 Endomorphism Monoid

**Theorem 3.10**. For each $n$, $\text{End}_{\text{EML}}(\mathbb{R}^n)$ is a monoid under composition.

*Proof.* The identity morphism is the unit. Composition is associative (Theorem 3.3) and has the identity as left and right unit. □

### 3.8 Derivation Depth Theory

**Definition 3.11** (EMLDeriv). A Type-valued inductive mirroring ScalarEML, but living in `Type` rather than `Prop`, enabling extraction of computational data.

**Definition 3.12** (Depth and Size).
- $\text{depth}(\text{coord}_i) = 0$, $\text{depth}(\text{const}_c) = 0$
- $\text{depth}(f \oplus g) = \max(\text{depth}(f), \text{depth}(g)) + 1$ for $\oplus \in \{+, \times\}$
- $\text{depth}(\exp(f)) = \text{depth}(f) + 1$, similarly for $\log$
- $\text{size}$ replaces $\max$ with $+$ and all base cases are 1 instead of 0.

**Theorem 3.13** (Depth–Size Inequality). For any derivation $d$: $\text{depth}(d) \leq \text{size}(d)$.

*Proof.* By induction on $d$. Base cases: $0 \leq 1$. Binary cases: $\max(d_1, d_2) + 1 \leq (s_1 + s_2) + 1$ using $\max(a, b) \leq a + b$ and the inductive hypotheses $d_i \leq s_i$. Unary cases: immediate from the inductive hypothesis. □

**Definition 3.14** (Depth Class). $D_k(n) = \{f \mid \exists d : \text{EMLDeriv}(n, f),\ \text{depth}(d) \leq k\}$.

**Theorem 3.15** (Monotonicity). $k_1 \leq k_2 \implies D_{k_1}(n) \subseteq D_{k_2}(n)$.

**Theorem 3.16** (Strictness at level 0–1). $D_0(1) \subsetneq D_1(1)$. The function $\exp(x_0)$ witnesses the strict inclusion (it is in $D_1$ but not $D_0$, since depth-0 derivations can only produce constants and coordinate projections).

### 3.9 Arithmetic Morphisms

**Theorem 3.17**. Addition $(a, b) \mapsto a + b$ and multiplication $(a, b) \mapsto a \cdot b$ are EML morphisms $\mathbb{R}^2 \to \mathbb{R}^1$.

### 3.10 Global Elements

**Theorem 3.18** (Enough points). For every $v \in \mathbb{R}^n$, there exists a global element $\gamma_v : \mathbb{R}^0 \to \mathbb{R}^n$ (a constant morphism) such that $\text{id} \circ \gamma_v = \gamma_v$ evaluates to $v$.

---

## 4. The EML Category Is Not Cartesian Closed

**Conjecture 4.1**. EML_Comp does not have full exponential objects. The internal hom $[\mathbb{R}^n, \mathbb{R}^m]$ would need to be a finite-dimensional space parameterizing all EML-computable functions $\mathbb{R}^n \to \mathbb{R}^m$, but there are countably many such functions (each is a finite derivation tree) and no finite-dimensional space can classify them all in an EML-computable way.

The currying theorem (3.9) shows that EML_Comp has *partial* exponential structure: for any fixed parameter dimension $p$, the exponential object $[\mathbb{R}^n, \mathbb{R}^m]_p = \mathbb{R}^p$ classifies the $p$-parameter subfamily. The full exponential is the colimit $\varinjlim_p [\mathbb{R}^n, \mathbb{R}^m]_p$, which exists as a set but not as a finite-dimensional EML object.

---

## 5. Cross-Domain Connections

### 5.1 Connection to OISCC

The OISCC (One-Instruction Set Computer for Continuous computation) uses the single instruction $\text{eml}(a, b) = \exp(a) - \log(b)$ with a stack machine. The existing catalog results (`eml_recovers_exp`, `eml_recovers_sub`, `eml_recovers_add`, `eml_mul_final`) show that basic arithmetic is recoverable. Our categorical framework provides the semantic underpinning: OISCC programs are *syntax* for morphisms in EML_Comp.

### 5.2 Connection to Log-Affine Geometry

The log-affine fragment (functions of the form $\exp(\sum w_i \log x_i + c)$) forms a subcategory of EML_Comp on the positive orthant. This subcategory corresponds exactly to the category of affine maps in logarithmic coordinates, connecting EML computation to convex geometry and tropical mathematics.

### 5.3 Connection to Closure Operators

The existing `EMLClosure` operator (from `ClosureOperator.lean`) gives the extensivity–monotonicity–idempotence axioms for the *lattice* of EML-generated function sets. Our categorical framework provides the complementary *compositional* structure: closure operators tell you what's in the set; the category tells you how the elements compose.

---

## 6. Algorithms

### 6.1 EML Expression Evaluator

Given an EML derivation tree and input vector, evaluate the expression bottom-up in $O(\text{size})$ time.

### 6.2 Depth Computation

Compute the depth of a derivation tree in $O(\text{size})$ time by bottom-up traversal.

### 6.3 Pairing and Projection

Given two EML morphisms $f : \mathbb{R}^n \to \mathbb{R}^m$ and $g : \mathbb{R}^n \to \mathbb{R}^k$, construct $\langle f, g \rangle$ in $O(m + k)$ time by concatenating derivation lists.

---

## 7. Discussion and Future Work

The EML category theorem opens several directions:

1. **Monoidal structure**: Is EML_Comp symmetric monoidal with $\otimes = +$ on objects? The swap morphism exists; proving it is involutive would establish symmetry.

2. **Enrichment**: Can EML_Comp be enriched over topological spaces (giving the compact-open topology on morphism sets)?

3. **Depth separation**: Are there functions in $D_k \setminus D_{k-1}$ for all $k$? The iterated exponential $\exp^{(k)}(x)$ is a natural candidate.

4. **Functor to differential geometry**: Is there a faithful functor from EML_Comp to the category of smooth manifolds and smooth maps?

5. **Computational complexity**: What is the relationship between EML derivation depth and circuit complexity (AC^0, TC^0, etc.)?

---

## 8. Formalization Notes

All results in Sections 2–3 are fully formalized in Lean 4 with Mathlib. Key design decisions:

- `ScalarEML` is defined with `n` as an index (not parameter) to allow the composition rule to change dimension.
- `EMLDeriv` is a separate `Type`-valued inductive paralleling `ScalarEML`, enabling extraction of depth/size data (Lean's `Prop`-valued inductives cannot eliminate into `Nat`).
- Morphism equality uses `funext` on the underlying function, with proof irrelevance for the computability certificate.
- Products use `Fin.addCases` for the pairing operation, which Lean's `simp` handles cleanly.

---

## References

1. Existing catalog: `EML/OISCC.lean` — OISCC arithmetic completeness.
2. Existing catalog: `EML/ClosureOperator.lean` — EML closure operator axioms.
3. Existing catalog: `EML/CategoryTheorems.lean` — Prior categorical results (depends on this paper's `CategoryDefs.lean`).
4. Existing catalog: `EML/LogAffineNormal.lean` — Normalization for the multiplicative positive fragment.
5. Mathlib: `CategoryTheory.Category.Basic` — Category axioms.
