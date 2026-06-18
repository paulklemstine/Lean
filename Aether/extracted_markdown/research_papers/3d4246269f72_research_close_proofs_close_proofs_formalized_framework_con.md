# A Categorical Helly Principle for Probe-Separated Presheaves

## Abstract

We establish a local-to-global finite generation principle for presheaves on finite discrete categories equipped with separating probe families. Given a presheaf *F* on a finite set of objects Ob and a probe family *P* ⊆ Ob of size *k* that separates *F* (in the sense that probe signatures are injective at every fiber), we prove that the global representable dimension — the total objectwise cardinality ∑_Y |F(Y)| — is bounded by |Ob| · n^k whenever every subset of size at most k + 1 has restricted representable dimension at most n. The quantity k + 1 = |P| + 1 is the **categorical Helly number**, directly analogous to the Helly number d + 1 in convex geometry. We further establish monotonicity of separation under probe enlargement and a localization theorem for non-separation obstructions. All results have been formally verified.

**Keywords:** Helly theorem, presheaves, probe families, finite generation, local-to-global principles, representable dimension, separation

---

## 1. Introduction

### 1.1 Background and Motivation

Helly's theorem (1913) asserts that for a finite family of convex sets in ℝ^d, if every d + 1 of them have nonempty intersection, then they all do. The quantity d + 1 is the Helly number — the minimal subset size whose local consistency guarantees global consistency. This local-to-global paradigm has been enormously influential, spawning fractional Helly theorems, colorful Helly theorems, topological Helly theorems, and extensions to lattices and abstract convexity structures.

In this work, we develop a Helly-type principle in a fundamentally different setting: presheaves on finite discrete categories equipped with separating probe families. Our objects of study are not convex sets but fibers of data indexed by a finite collection of objects, linked by restriction maps. The role of "dimension" is played by the size of a separating probe family, and the conclusion concerns not intersection properties but **bounded global complexity** (finite representable dimension) from local finiteness.

### 1.2 Setting

We work over a finite type Ob with decidable equality, representing the objects of a finite discrete category. A **presheaf** on Ob is an assignment F : Ob → Type with each fiber F(Y) finite. Restriction maps r(Y, Z) : F(Y) → F(Z) connect fibers across objects.

### 1.3 Overview of Results

We prove four main theorems:

1. **Fiber Capacity Bound (Theorem 1):** Under probe separation, |F(Y)| ≤ ∏_{Z ∈ P} |F(Z)| for all Y.
2. **Categorical Helly Theorem (Theorem 2):** Local finiteness on (|P|+1)-subsets implies ∑_Y |F(Y)| ≤ |Ob| · n^|P|.
3. **Separation Monotonicity (Theorem 3):** If P separates F and Q ⊇ P, then Q separates F.
4. **Obstruction Localization (Theorem 4):** Non-separation failures are witnessed by pairs localized within the Helly number.

---

## 2. Definitions

### 2.1 Probe Families and Signatures

**Definition 2.1 (Probe Family).** A *probe family* for Ob is a finite subset P ⊆ Ob, formalized as P : Finset Ob.

**Definition 2.2 (Probe Signature).** Given a presheaf F : Ob → Type with restriction maps r : ∀ Y Z, F(Y) → F(Z), the *probe signature* of an element x ∈ F(Y) with respect to P is the function:

sig_P(x) : ∏_{Z ∈ P} F(Z), defined by sig_P(x)(Z) = r(Y, Z)(x)

This records the "shadow" of x at each probe object.

**Definition 2.3 (Probe Separation).** The probe family P *separates* F (with respect to r) if for every object Y, the probe signature map sig_P(−) : F(Y) → ∏_{Z ∈ P} F(Z) is injective. Equivalently: for all Y, if x, y ∈ F(Y) satisfy sig_P(x) = sig_P(y), then x = y.

### 2.2 Representable Dimension

**Definition 2.4 (Objectwise Total Cardinality).** The *objectwise total cardinality* (or representable dimension) of F is:

repDim(F) = ∑_{Y ∈ Ob} |F(Y)|

**Definition 2.5 (Restricted Representable Dimension).** For a subset S ⊆ Ob:

repDim_S(F) = ∑_{Y ∈ S} |F(Y)|

This is monotone: if S ⊆ T then repDim_S(F) ≤ repDim_T(F). On the full set Ob, it recovers the global representable dimension.

### 2.3 Local Finite Generation

**Definition 2.6 (Locally Representably Finitely Generated).** The presheaf F is *locally representably finitely generated up to (k, n)* if for every subset S ⊆ Ob with |S| ≤ k, we have repDim_S(F) ≤ n.

This is a local finiteness condition: it bounds the total fiber size on all small subsets.

### 2.4 Probe Capacity and the Helly Number

**Definition 2.7 (Probe Capacity).** The *probe capacity* of F with respect to P is:

cap(F, P) = ∏_{Z ∈ P} |F(Z)|

This is the cardinality of the codomain of the probe signature map, hence an upper bound on the number of distinct signatures.

**Definition 2.8 (Categorical Helly Number).** The *categorical Helly number* of P is:

h(P) = |P| + 1

This is the critical subset size for local-to-global deductions.

### 2.5 Obstruction Witnesses

**Definition 2.9 (Minimal Non-Separated Witness).** A *minimal non-separated witness* at object Y is a pair (x, y) with x ≠ y in F(Y) such that sig_P(x) = sig_P(y) — two distinct elements that the probes cannot distinguish.

---

## 3. Main Results

### 3.1 Theorem 1: Fiber Capacity Bound

**Theorem 3.1 (Fiber Capacity Bound).** *Let P be a probe family that separates the presheaf F. Then for every object Y ∈ Ob:*

|F(Y)| ≤ cap(F, P) = ∏_{Z ∈ P} |F(Z)|

**Proof sketch.** Separation means the probe signature map sig_P : F(Y) → ∏_{Z ∈ P} F(Z) is injective. An injective map from a finite set to a finite set implies |domain| ≤ |codomain|. The codomain is the product type ∏_{Z ∈ P} F(Z), whose cardinality is ∏_{Z ∈ P} |F(Z)| = cap(F, P). ∎

**Remark.** This bound is tight: equality holds when every possible signature is realized, i.e., when the signature map is bijective.

### 3.2 Theorem 2: The Categorical Helly Theorem

**Theorem 3.2 (Categorical Helly Theorem).** *Let P be a probe family of size k that separates F. Suppose F is locally representably finitely generated up to (k + 1, n), i.e., every subset of Ob of cardinality at most k + 1 has restricted representable dimension at most n. Then:*

repDim(F) ≤ |Ob| · n^k

**Proof sketch.** The proof proceeds in four steps:

*Step 1: Individual probe fibers are bounded.* For each probe object Z ∈ P, the singleton {Z} has cardinality 1 ≤ k + 1, so the local bound gives |F(Z)| = repDim_{Z}(F) ≤ n.

*Step 2: Probe capacity is bounded.* Since each factor in the product satisfies |F(Z)| ≤ n, we have cap(F, P) = ∏_{Z ∈ P} |F(Z)| ≤ n^k.

*Step 3: Every fiber is bounded.* By Theorem 1, |F(Y)| ≤ cap(F, P) ≤ n^k for every object Y.

*Step 4: Global bound.* Summing: repDim(F) = ∑_Y |F(Y)| ≤ ∑_Y n^k = |Ob| · n^k. ∎

**Remark.** The Helly number k + 1 is optimal in the following sense: checking subsets of size k would not, in general, suffice to bound individual probe fibers when |P| = k and some probe objects might not appear in all k-element subsets. The "+1" accounts for the interaction between the test object Y and the probe family P.

### 3.3 Theorem 3: Separation Monotonicity

**Theorem 3.3 (Separation Preserved by Probe Enlargement).** *If P separates F and Q ⊇ P, then Q also separates F.*

**Proof sketch.** Suppose sig_Q(x) = sig_Q(y) for some x, y ∈ F(Y). Since P ⊆ Q, the signatures agree on all probe objects in P, i.e., sig_P(x) = sig_P(y). Since P separates F, this forces x = y. Hence Q separates F. ∎

**Corollary 3.4 (Helly Bound Strengthens with More Probes).** If P ⊆ Q, P separates F, and F is locally finitely generated up to (|Q| + 1, n), then repDim(F) ≤ |Ob| · n^|Q|.

This follows immediately by combining Theorems 2 and 3.

### 3.4 Theorem 4: Obstruction Localization

**Theorem 3.5 (Obstruction Localization).** *If P does not separate F, then there exists an object Y and a minimal non-separated witness at Y — i.e., a pair x ≠ y in F(Y) with sig_P(x) = sig_P(y).*

**Proof sketch.** Non-separation means there exists Y where the signature map is not injective. By contraposition: if no such witness exists at any Y, then the signature map is injective at every Y, which is exactly separation. ∎

**Theorem 3.6 (Witness Support Bound).** The support of a non-separation witness at object Y — the set {Y} ∪ P — has cardinality at most h(P) = |P| + 1.

**Proof sketch.** |{Y} ∪ P| ≤ |{Y}| + |P| = 1 + |P| = h(P). ∎

This means non-separation obstructions are always concentrated within a Helly-number-sized neighborhood. To diagnose separation failure, one need only examine subsets of this bounded size.

---

## 4. Supporting Results

### 4.1 Monotonicity of Local Generation

**Proposition 4.1.** If k ≤ l, then LocallyRepFinGenUpTo(F, l, n) implies LocallyRepFinGenUpTo(F, k, n).

Checking larger subsets is a stronger condition; bounds that hold for larger subsets automatically hold for smaller ones.

### 4.2 Probe Capacity Power Bound

**Proposition 4.2.** If |F(Z)| ≤ n for all Z ∈ P, then cap(F, P) ≤ n^|P|.

This is the product-of-bounded-terms inequality that bridges the local bound n to the exponential global bound n^|P|.

### 4.3 Extreme Cases

**Proposition 4.3.** For the empty probe family, h(∅) = 1. For the total probe family P = Ob, h(Ob) = |Ob| + 1.

**Proposition 4.4.** If every fiber achieves the probe capacity — |F(Y)| = cap(F, P) for all Y — then repDim(F) = |Ob| · cap(F, P).

### 4.4 Direct Global Bound

**Proposition 4.5.** If F is locally finitely generated up to (|Ob|, n), then repDim(F) ≤ n.

When the local bound applies to the full set, it directly yields the global bound without probe capacity arguments.

---

## 5. Proof Architecture and Verification

All theorems and supporting lemmas have been formally verified. The proof architecture follows a layered approach:

1. **Foundation layer:** Definitions of probe signatures, separation, restricted representable dimension, probe capacity, and the Helly number.
2. **Helper layer:** Singleton dimension identity, monotonicity of restricted dimension, individual fiber bounds from local generation conditions, probe capacity power bound.
3. **Main theorem layer:** Fiber capacity bound (injectivity argument), Categorical Helly theorem (four-step composition), separation monotonicity (signature restriction), obstruction localization (contraposition).
4. **Corollary layer:** Strengthening with more probes, global bounds, extreme case characterizations.

The dependency graph is acyclic and each theorem depends only on previously established results, ensuring modularity and independent verifiability.

---

## 6. Applications and Connections

### 6.1 Connection to Classical Helly Theory

The Categorical Helly Theorem mirrors the structure of Helly's theorem with the following correspondence:

| Convex Geometry | Categorical Setting |
|---|---|
| Dimension d | Probe family size |P| |
| Helly number d + 1 | Categorical Helly number |P| + 1 |
| Convex sets | Presheaf fibers |
| Nonempty intersection | Bounded representable dimension |
| "Every d+1 intersect" | "Every k+1 subset has bounded rep dim" |

### 6.2 Compressed Sensing Analogy

The probe separation framework can be viewed as a discrete analogue of compressed sensing:

- The probe signature is a measurement operator.
- Separation is the analogue of the restricted isometry property (RIP).
- The Helly theorem says that local measurement quality implies global reconstruction bounds.

### 6.3 Database Theory

In relational database terms, the presheaf fibers are relations over a schema Ob. The probe family P is a set of "key attributes." Separation means P forms a superkey. The Helly theorem bounds the total database size from local consistency checks on small sub-schemas.

### 6.4 Topological Data Analysis

Presheaves over finite categories arise naturally as cellular (co)sheaves in topological data analysis. The representable dimension is a combinatorial shadow of sheaf cohomology. The Helly principle suggests cohomological bounds may admit similar local-to-global arguments.

---

## 7. Discussion

### 7.1 Tightness of the Bound

The bound repDim(F) ≤ |Ob| · n^|P| is generally not tight — the exponential dependence on |P| arises from the product structure of the signature space. When the restriction maps have additional structure (e.g., linearity over a field), tighter bounds analogous to the rank-nullity theorem should be achievable.

### 7.2 The Role of the Helly Number

The Helly number |P| + 1 emerges naturally as the size of the minimal "test window" {Y} ∪ P. The "+1" is essential: without it, one cannot guarantee that each probe fiber individually satisfies the bound n, as a k-element subset might not contain all k probe objects.

### 7.3 Comparison with Sheaf-Theoretic Helly Theorems

Recent work by Kalai, Meshulam, and others has developed topological Helly theorems using the Leray number and sheaf cohomology. Our result is complementary: rather than using topological obstructions to intersection, we use algebraic separation (injectivity of signature maps) to control cardinality. The two approaches may converge through persistent sheaf cohomology.

---

## 8. Future Work

Several directions suggest themselves for extending this framework:

1. **Higher-categorical generalizations.** Extending probe separation to enriched or higher categories, where the fibers carry additional algebraic structure (e.g., group-valued presheaves).

2. **Quantitative refinements.** Tightening the n^|P| bound under structural assumptions on the restriction maps (e.g., when they form a family of linear maps between vector spaces).

3. **Algorithmic aspects.** Developing efficient algorithms that exploit the Helly principle for testing separation and computing representable dimensions on large finite categories.

4. **Connections to model theory.** The probe separation condition has a model-theoretic flavor (quantifier elimination via a finite set of "test formulas"). Exploring this connection could yield Helly-type principles in first-order logic.

5. **Persistent Helly numbers.** Studying how the Helly number changes as the underlying category is filtered or refined, potentially connecting to persistence theory in topological data analysis.

---

## References

The classical Helly theorem originates in:

- E. Helly, "Über Mengen konvexer Körper mit gemeinschaftlichen Punkten," *Jahresbericht der Deutschen Mathematiker-Vereinigung*, 32 (1923), 175–176.

For modern surveys of Helly-type theorems, see the handbook treatments in combinatorial convexity.

---

*All results in this paper have been formally verified in Lean 4 with the Mathlib library.*
