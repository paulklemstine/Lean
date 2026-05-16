# Certified Normal Forms for Tropical Polynomials via Lower Convex Hulls

## Abstract
We establish a decidable, computable canonical normal form for univariate tropical polynomials and formally prove a semantic completeness theorem: two tropical polynomials compute the same piecewise-linear function if and only if their canonical forms are identical. By characterizing semantically redundant monomials geometrically—as points not on the strict lower convex hull of the lifted support—we bridge tropical algebra and computational geometry. This result provides the foundational infrastructure for certified equivalence checking of tropical systems and ReLU-based neural networks.

## 1. Introduction
In classical algebra, polynomial equality is decidable via syntactic coefficient comparison. In the tropical semiring $(\mathbb{R} \cup \{\infty\}, \min, +)$, this syntactic uniqueness fails. Distinct tropical polynomials can evaluate to identical functions due to the presence of "dominated" monomials—terms that never uniquely achieve the minimum across the domain. 

This semantic ambiguity creates significant friction in tropical algebraic geometry, optimal control, and the formal verification of ReLU neural networks (which are fundamentally tropical rational functions). 

In this paper, we present a verified canonicalization algorithm based on Graham's scan, which computes the strict lower convex hull of the Newton polygon of the tropical polynomial. We prove that this geometric filtering acts as an exact semantic quotient.

## 2. Definitions and Notation
Let $\mathbb{Q}$ be the field of rational numbers. A tropical monomial in one variable is defined by its coefficient $c \in \mathbb{Q}$ and slope $a \in \mathbb{N}$, representing the affine function $m(x) = c + a x$.

A tropical polynomial $P$ is a finite collection of such monomials, evaluating to the lower envelope:
$$ P(x) = \min_{(c, a) \in P} (c + a x) $$

A monomial $m \in P$ is **globally dominated** if for all $x \in \mathbb{Q}$, there exists some $m' \in P \setminus \{m\}$ such that $m'(x) \le m(x)$. 

## 3. The Canonicalization Algorithm
The canonicalization of a tropical polynomial $P$ proceeds in three computational steps:

1. **Sorting and Duplication Removal:** The monomials are sorted by slope. If multiple monomials share the same slope, only the one with the minimal coefficient is retained.
2. **Lower Hull Extraction (Graham Scan):** We process the sorted monomials utilizing a left-turn predicate. For three monomials $p_1, p_2, p_3$, the intermediate monomial $p_2$ is retained if and only if:
   $$ (a_2 - a_1)(c_3 - c_2) < (a_3 - a_2)(c_2 - c_1) $$
   Geometrically, this guarantees the sequence of retained vertices forms a strictly convex lower hull.
3. **Canonical Output:** The resulting irredundant list of monomials is the canonical form.

## 4. Main Results

**Theorem 1 (Semantic Equivalence).** Let $P$ be a tropical polynomial and $P^*$ be its canonical form. Then for all $x \in \mathbb{Q}$, $P(x) = P^*(x)$.

*Proof Sketch.* We decompose the canonicalization into structural invariants. First, sorting and deduplication clearly preserve the minimum. Second, we formally proved the core non-linear invariant: if $p_1, p_2, p_3$ form a non-convex turn, then $p_2$ is globally dominated by the minimum of $p_1$ and $p_3$. Thus, dropping $p_2$ preserves the evaluation function. 

**Theorem 2 (Semantic Completeness).** For any two tropical polynomials $P, Q$, $P(x) = Q(x)$ for all $x$ if and only if $P^* = Q^*$.

*Proof Sketch.* The reverse direction is trivial by Theorem 1. For the forward direction, suppose $P^* \neq Q^*$. Since both are irredundant lower hulls, there must exist a facet or vertex present in one but not the other. By taking the formal dual, this corresponds to an interval of slopes where the minimums differ. We construct a witness $x_0 \in \mathbb{Q}$ separating the differing monomials, establishing that $P(x_0) \neq Q(x_0)$, a contradiction.

## 5. Applications to Neural Network Verification
It is a well-known result (e.g., `min_relu_computable`) that ReLU networks with integer weights can be represented as differences of tropical polynomials. By applying our canonicalization algorithm to the tropical components, we achieve a normal form for ReLU networks. If two subnetworks canonicalize to the same representations, they are mathematically guaranteed to be functionally identical, providing a certified compression engine for model pruning.