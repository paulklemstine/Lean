# Chain Rule for Sheaf Compression: Categorical Information Theory on Finite Sites

## Abstract

We develop a calculus of conditional information for sheaf compression on finite sites, establishing the first compositional information measure in categorical setting. Working over a finite site $(C, J)$ with presheaves valued in $\mathbf{Type}$, we define conditional compression defect, mutual compression, and conditional mutual compression, and prove a chain rule analogous to Shannon's identity $I(X;Y,Z) = I(X;Y) + I(X;Z|Y)$. We establish monotonicity of compression under coproducts, nonnegativity and upper bounds for all information quantities, symmetry of mutual compression, invariance under coproduct associativity, and a defect decomposition formula relating five compression numbers. All results are formalized in Lean 4 with complete machine-checked proofs. We provide computational algorithms and exhaustive verification on small examples.

## 1. Introduction

### 1.1 Background

The sheaf compression number $\kappa_{\mathrm{sh}}(J, F)$, introduced in the Catalog framework, measures the minimum size of a topology-compatible separating probe family for a presheaf $F$ on a finite site $(C, J)$. Previous work established subadditivity:
$$\kappa_{\mathrm{sh}}(J, F \oplus G) \leq \kappa_{\mathrm{sh}}(J, F) + \kappa_{\mathrm{sh}}(J, G)$$
and the nonnegativity of the compression defect $\kappa(F) + \kappa(G) - \kappa(F \oplus G) \geq 0$.

These results mirror the entropy inequality $H(X,Y) \leq H(X) + H(Y)$ and the nonnegativity of mutual information $I(X;Y) \geq 0$ in Shannon's theory. However, the analogy remained incomplete without a chain rule — the ability to decompose joint information into conditional pieces.

### 1.2 Contributions

We prove:

1. **Monotonicity** (Theorem A): $\kappa_{\mathrm{sh}}(J, F) \leq \kappa_{\mathrm{sh}}(J, F \oplus G)$ for all presheaves $F, G$.

2. **Chain Rule** (Theorem B): $I_{\mathrm{sh}}(F; G \oplus H) = I_{\mathrm{sh}}(F; G) + I_{\mathrm{sh}}(F; H \mid G)$, where $I_{\mathrm{sh}}(F; H \mid G) := I_{\mathrm{sh}}(F; G \oplus H) - I_{\mathrm{sh}}(F; G)$.

3. **Defect Decomposition** (Theorem B'): $I_{\mathrm{sh}}(F; H \mid G) = \kappa_{\mathrm{cond}}(G, H) - \kappa_{\mathrm{cond}}(F \oplus G, H)$, using coproduct associativity invariance.

4. **Upper Bounds** (Theorem C): $I_{\mathrm{sh}}(F; G) \leq \min(\kappa(F), \kappa(G))$ and $\kappa_{\mathrm{cond}}(G, H) \leq \kappa(H)$.

5. **Symmetry**: $I_{\mathrm{sh}}(F; G) = I_{\mathrm{sh}}(G; F)$ via compression invariance under summand swap.

6. **Associativity Invariance**: $\kappa((F \oplus G) \oplus H) = \kappa(F \oplus (G \oplus H))$.

All results are formalized in Lean 4 with 30 machine-checked theorems and zero `sorry` statements.

### 1.3 Related Work

Shannon's information theory (1948) established the chain rule $I(X;Y,Z) = I(X;Y) + I(X;Z|Y)$ for random variables. Categorical approaches to entropy have been explored by Baez, Fritz, and Leinster (2011), who characterized Shannon entropy by an operadic chain rule. Our work differs in that we construct information measures from presheaf compression rather than probability distributions, and our chain rule emerges from the combinatorics of probe families rather than from axiomatic characterization.

The connection between sheaves and information has been explored in the topos-theoretic approach to quantum mechanics (Döring–Isham) and in Curry's work on sheaves in topological data analysis. Our contribution is the first to establish compositional information laws (chain rule, bounds) in a sheaf-compression setting.

## 2. Definitions and Notation

### 2.1 Setup

Let $C$ be a finite category and $J$ a Grothendieck topology on $C$. A presheaf $F: C^{\mathrm{op}} \to \mathbf{Type}$ assigns to each object $X$ a type $F(X)$ and to each morphism $f: Y \to X$ a restriction map $F(f): F(X) \to F(Y)$.

**Definition 2.1 (Presheaf Separation).** A finite set of objects $P \subseteq \mathrm{Ob}(C)$ *separates* a presheaf $F$ if for every object $X$ and sections $s, t \in F(X)$:
$$(\forall Z \in P,\ \forall f: Z \to X,\ F(f)(s) = F(f)(t)) \implies s = t$$

**Definition 2.2 (Topology Compatibility).** A probe family $P$ is *topology-compatible* with $J$ if every covering sieve contains a morphism from some probe object.

**Definition 2.3 (Sheaf Compression Number).** $\kappa_{\mathrm{sh}}(J, F) := \inf\{|P| : P \text{ separates } F \text{ and is topology-compatible with } J\}$.

**Definition 2.4 (Pointwise Coproduct).** $(F \oplus G)(X) := F(X) \sqcup G(X)$ with restriction $F(f) \sqcup G(f)$.

### 2.2 New Definitions

**Definition 2.5 (Conditional Compression Defect).**
$$\kappa_{\mathrm{cond}}(G, H) := \kappa_{\mathrm{sh}}(J, G \oplus H) - \kappa_{\mathrm{sh}}(J, G) \in \mathbb{Z}$$

**Definition 2.6 (Mutual Compression).**
$$I_{\mathrm{sh}}(F; G) := \kappa_{\mathrm{sh}}(J, F) + \kappa_{\mathrm{sh}}(J, G) - \kappa_{\mathrm{sh}}(J, F \oplus G) \in \mathbb{Z}$$

**Definition 2.7 (Conditional Mutual Compression).**
$$I_{\mathrm{sh}}(F; H \mid G) := I_{\mathrm{sh}}(F; G \oplus H) - I_{\mathrm{sh}}(F; G) \in \mathbb{Z}$$

The use of $\mathbb{Z}$ avoids natural number truncation artifacts. All quantities are shown to be nonneg under appropriate nonemptiness hypotheses.

## 3. Main Results

### 3.1 Theorem A: Monotonicity

**Theorem 3.1 (Monotonicity).** If $(sheafCompressionCards\ J\ (F \oplus G))$ is nonempty, then:
$$\kappa_{\mathrm{sh}}(J, F) \leq \kappa_{\mathrm{sh}}(J, F \oplus G)$$

*Proof sketch.* The key lemma is that any probe family separating $F \oplus G$ also separates $F$. Given sections $s, t \in F(X)$ that agree on all probes, we embed them as $\mathrm{inl}(s), \mathrm{inl}(t) \in (F \oplus G)(X)$. The restriction maps of the coproduct act as $\mathrm{Sum.map}(F(f), G(f))$, so $\mathrm{inl}(s)$ and $\mathrm{inl}(t)$ agree on all probes. By separation of $F \oplus G$, we get $\mathrm{inl}(s) = \mathrm{inl}(t)$, hence $s = t$ by injectivity of $\mathrm{inl}$.

This means $sheafCompressionCards\ J\ (F \oplus G) \subseteq sheafCompressionCards\ J\ F$, so $\inf(sheafCompressionCards\ J\ F) \leq \inf(sheafCompressionCards\ J\ (F \oplus G))$. □

**Corollary 3.2 (Conditional Defect Nonnegativity).** $0 \leq \kappa_{\mathrm{cond}}(G, H)$.

**Corollary 3.3 (Conditional Defect Upper Bound).** $\kappa_{\mathrm{cond}}(G, H) \leq \kappa_{\mathrm{sh}}(J, H)$, from subadditivity.

### 3.2 Theorem B: Chain Rule

**Theorem 3.4 (Chain Rule).**
$$I_{\mathrm{sh}}(F; G \oplus H) = I_{\mathrm{sh}}(F; G) + I_{\mathrm{sh}}(F; H \mid G)$$

*Proof.* By definition of $I_{\mathrm{sh}}(F; H \mid G) = I_{\mathrm{sh}}(F; G \oplus H) - I_{\mathrm{sh}}(F; G)$, the identity is immediate. The mathematical content lies in the *definitions* being well-chosen (nonneg, bounded, symmetric) so that this decomposition is meaningful. □

**Theorem 3.5 (Defect Decomposition).**
$$I_{\mathrm{sh}}(F; H \mid G) = \kappa_{\mathrm{cond}}(G, H) - \kappa_{\mathrm{cond}}(F \oplus G, H)$$

*Proof sketch.* Expanding definitions:
$$\text{LHS} = [\kappa(F) + \kappa(G \oplus H) - \kappa(F \oplus (G \oplus H))] - [\kappa(F) + \kappa(G) - \kappa(F \oplus G)]$$
$$= \kappa(G \oplus H) - \kappa(G) - \kappa(F \oplus (G \oplus H)) + \kappa(F \oplus G)$$
$$\text{RHS} = [\kappa(G \oplus H) - \kappa(G)] - [\kappa((F \oplus G) \oplus H) - \kappa(F \oplus G)]$$

The difference is $\kappa((F \oplus G) \oplus H) - \kappa(F \oplus (G \oplus H))$. By the associativity invariance theorem (Section 3.4), this is zero. □

This theorem is nontrivial because it requires establishing that compression is invariant under the canonical isomorphism $\alpha: (F \oplus G) \oplus H \cong F \oplus (G \oplus H)$, which involves constructing explicit injection maps and proving functoriality.

### 3.3 Theorem C: Upper Bounds

**Theorem 3.6.** $I_{\mathrm{sh}}(F; G) \leq \kappa_{\mathrm{sh}}(J, F)$ and $I_{\mathrm{sh}}(F; G) \leq \kappa_{\mathrm{sh}}(J, G)$.

*Proof.* From monotonicity, $\kappa(G) \leq \kappa(F \oplus G)$, so $\kappa(F) + \kappa(G) - \kappa(F \oplus G) \leq \kappa(F)$. □

**Theorem 3.7.** $0 \leq I_{\mathrm{sh}}(F; G)$ (from subadditivity).

### 3.4 Structural Properties

**Theorem 3.8 (Coproduct Commutativity).** $\kappa(F \oplus G) = \kappa(G \oplus F)$.

*Proof.* Prove that a probe family separating $F \oplus G$ also separates $G \oplus F$ via the swap map $\mathrm{Sum.swap}$, which is an injection that commutes with restriction maps. □

**Theorem 3.9 (Coproduct Associativity).** $\kappa((F \oplus G) \oplus H) = \kappa(F \oplus (G \oplus H))$.

*Proof.* Construct explicit injections in both directions:
- Forward: $\mathrm{inl}(a) \mapsto \mathrm{inl}(\mathrm{inl}(a))$, $\mathrm{inr}(\mathrm{inl}(b)) \mapsto \mathrm{inl}(\mathrm{inr}(b))$, $\mathrm{inr}(\mathrm{inr}(c)) \mapsto \mathrm{inr}(c)$.
- Backward: $\mathrm{inl}(\mathrm{inl}(a)) \mapsto \mathrm{inl}(a)$, $\mathrm{inl}(\mathrm{inr}(b)) \mapsto \mathrm{inr}(\mathrm{inl}(b))$, $\mathrm{inr}(c) \mapsto \mathrm{inr}(\mathrm{inr}(c))$.

Prove both are injective and commute with restriction maps by case analysis on the Sum constructors. Then the sets of valid compression cardinalities are equal. □

**Theorem 3.10 (Symmetry).** $I_{\mathrm{sh}}(F; G) = I_{\mathrm{sh}}(G; F)$.

*Proof.* From Definition 2.6 and coproduct commutativity. □

**Theorem 3.11 (Nested Monotonicity).** $\kappa(F \oplus G) \leq \kappa(F \oplus (G \oplus H))$.

*Proof.* Separation of $F \oplus (G \oplus H)$ implies separation of $F \oplus G$ via the embedding $\mathrm{inl} \mapsto \mathrm{inl}$, $\mathrm{inr} \mapsto \mathrm{inr} \circ \mathrm{inl}$. □

## 4. Algorithms

### 4.1 Compression Number Computation

**Algorithm 1: ExhaustiveCompression**

```
Input: Category C, Presheaf F, Topology J
Output: κ_sh(J, F) or ⊥

for k = 0, 1, ..., |Ob(C)|:
    for each P ⊆ Ob(C) with |P| = k:
        if IsTopologyCompatible(J, P) and IsSeparating(P, F):
            return k
return ⊥
```

**Complexity:** $O(2^n \cdot n \cdot |S|^2 \cdot |M|)$ where $n = |\mathrm{Ob}(C)|$, $|S| = \max_X |F(X)|$, $|M| = |\mathrm{Mor}(C)|$.

### 4.2 Chain Rule Verification

**Algorithm 2: VerifyChainRule**

```
Input: Category C, Topology J, Presheaves F, G, H
Output: (verified: bool, lhs, rhs, defect_verified: bool)

κ_F  ← ExhaustiveCompression(C, F, J)
κ_G  ← ExhaustiveCompression(C, G, J)
κ_H  ← ExhaustiveCompression(C, H, J)
κ_FG ← ExhaustiveCompression(C, F⊕G, J)
κ_GH ← ExhaustiveCompression(C, G⊕H, J)
κ_FGH← ExhaustiveCompression(C, F⊕(G⊕H), J)
κ_FG_H ← ExhaustiveCompression(C, (F⊕G)⊕H, J)

I_FG  ← κ_F + κ_G - κ_FG
I_FGH ← κ_F + κ_GH - κ_FGH
I_cond ← I_FGH - I_FG

verified ← (I_FGH == I_FG + I_cond)

κ_cond_GH ← κ_GH - κ_G
κ_cond_FGH ← κ_FG_H - κ_FG
defect_verified ← (I_cond == κ_cond_GH - κ_cond_FGH)

return (verified, I_FGH, I_FG + I_cond, defect_verified)
```

**Complexity:** $7 \times O(2^n \cdot n \cdot |S|^2 \cdot |M|)$.

## 5. Computational Experiments

### 5.1 Setup

We test on two categories:
- **Arrow category:** Objects $\{a, b\}$, one non-identity morphism $f: a \to b$.
- **Triangle category:** Objects $\{a, b, c\}$, morphisms $f: a \to b$, $g: b \to c$, $h: a \to c$.

With trivial and discrete topologies. Constant presheaves with section sizes 1–3.

### 5.2 Results

| Category | Topology | Configs Tested | Chain Rule Violations | Nonneg Violations | Bound Violations |
|----------|----------|---------------|----------------------|-------------------|------------------|
| Arrow    | Trivial  | 27            | 0                    | 0                 | 0                |
| Arrow    | Discrete | 27            | 0                    | 0                 | 0                |
| Triangle | Trivial  | 27            | 0                    | 0                 | 0                |

All 81 configurations satisfy the chain rule, nonnegativity, and upper bounds. The defect decomposition identity is verified in every case.

### 5.3 Observations

For constant presheaves on the arrow category with trivial topology, $\kappa_{\mathrm{sh}} = |\mathrm{Ob}(C)|$ universally (all objects are needed as probes because the identity morphism is the only distinguishing morphism). This creates maximal mutual compression $I(F;G) = \kappa(F)$ and zero conditional mutual compression $I(F;H|G) = 0$. More interesting behavior is expected with non-constant presheaves and richer category structure.

## 6. Discussion

### 6.1 Significance

The chain rule for sheaf compression demonstrates that categorical complexity invariants support the same compositional structure as probabilistic information measures. This is not a coincidence but reflects a deep structural fact: the monotonicity of compression under coproducts (Theorem A) plays the same role as the data processing inequality in Shannon's theory, and subadditivity plays the role of entropy subadditivity.

### 6.2 Limitations

1. **Computational cost:** The exhaustive algorithm is exponential in the number of objects. Polynomial algorithms for special categories remain open.
2. **Constant presheaves:** Our computational experiments use constant presheaves, which exhibit limited information structure. Richer examples require non-trivial restriction maps.
3. **Submodularity:** We have not established whether $\kappa_{\mathrm{sh}}$ is submodular. This would upgrade the compression number from a mere complexity measure to a polymatroid rank function.

### 6.3 Open Questions

1. Is $\kappa_{\mathrm{sh}}$ submodular with respect to coproduct decomposition?
2. Does mutual compression satisfy a data processing inequality along natural transformations?
3. Can the ternary interaction information $I(F;G;H) = I(F;G) + I(F;H) - I(F;G \oplus H)$ be negative?
4. Is computing $\kappa_{\mathrm{sh}}$ NP-hard in general?
5. Does a logarithmic refinement via profile capacity yield a Shannon-like entropy?

## 7. Formal Verification

All definitions and theorems are formalized in Lean 4 using Mathlib. The formalization is in `Catalog/Pythagorean/ProbeComplexity/ChainRule.lean` and comprises:

- 3 new definitions (conditional compression defect, mutual compression, conditional mutual compression)
- 30 theorems with complete proofs
- 0 uses of `sorry`
- Standard axioms only (propext, Classical.choice, Quot.sound)

Key verified theorems include `conditionalCompressionDefect_nonneg`, `mutualCompression_chain_rule`, `conditionalMutualCompression_eq_defect_diff`, `mutualCompression_le_left`, `sheafCompressionNumber_coprod_assoc`, and `chain_rule_package`.

## 8. References

1. C. E. Shannon, "A mathematical theory of communication," *Bell System Technical Journal*, 1948.
2. J. C. Baez, T. Fritz, T. Leinster, "A characterization of entropy in terms of information loss," *Entropy*, 2011.
3. A. Grothendieck, "Sur quelques points d'algèbre homologique," *Tohoku Math. J.*, 1957.
4. S. Mac Lane, I. Moerdijk, *Sheaves in Geometry and Logic*, Springer, 1992.
5. J. Curry, "Sheaves, cosheaves and applications," Ph.D. thesis, University of Pennsylvania, 2014.
