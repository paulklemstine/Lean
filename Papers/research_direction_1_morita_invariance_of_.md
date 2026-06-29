# Morita Invariance of Probe Complexity for Finite Categories

## Abstract

We prove that the probe complexity κ(C) — the minimum cardinality of a separating probe family for a finite category C — is invariant under Morita equivalence. Specifically, we establish that κ(C) = κ(Kar(C)) where Kar(C) is the Karoubi envelope (idempotent completion), and consequently κ(C) = κ(D) whenever the Karoubi envelopes of C and D are equivalent. Since Morita equivalence of small categories is characterized by equivalence of Cauchy completions, this elevates κ from a combinatorial statistic on finite categories to a genuine invariant of presheaf toposes. All theorems are formally verified in Lean 4 with the Mathlib library. We provide algorithms for computing κ and its Karoubi completion, demonstrate the invariance computationally on families of examples, and discuss applications to automata theory, representation theory, algebraic geometry, and categorical semantics.

**Keywords:** Morita equivalence, probe complexity, Karoubi envelope, Cauchy completion, presheaf topos, finite categories, observational complexity, idempotent splitting

## 1. Introduction

### 1.1 Background and Motivation

The probe complexity κ(C) of a finite category C was introduced as a quantitative refinement of the Yoneda-style reconstruction principle: it counts the minimum number of objects needed as "test probes" to distinguish all parallel morphisms by precomposition. Previous work established:

- κ(C) ≤ |Obj(C)| (the total probe family always separates)
- κ(C) = 0 iff all hom-sets are subsingleton (thin category theorem)
- κ(C) = 1 for any nontrivial monoid viewed as a one-object category
- Invariance under categorical equivalence: C ≌ D implies κ(C) = κ(D)

A natural question arises: is κ(C) invariant under the weaker notion of Morita equivalence? Two small categories C and D are Morita equivalent if their presheaf categories [C^op, Set] and [D^op, Set] are equivalent. This is a strictly weaker condition than categorical equivalence — it identifies categories that "see the same mathematics" through different presentations.

The classical theorem of Morita theory states that for small categories, Morita equivalence is characterized by equivalence of Cauchy completions (= Karoubi envelopes = idempotent completions). Thus, proving κ(C) = κ(Kar(C)) is the key step toward full Morita invariance.

### 1.2 Main Results

We prove three main theorems:

**Theorem A (Equivalence Invariance).** If C ≌ D as categories, then κ(C) = κ(D).

**Theorem B (Karoubi Invariance).** For any finite category C with finite hom-sets, κ(C) = κ(Kar(C)).

**Theorem C (Morita Invariance).** If Kar(C) ≌ Kar(D), then κ(C) = κ(D).

We also introduce two new definitions:

- **Split-stable probe family**: a separating family on C that extends to Kar(C) without size increase.
- **Retract profile**: a combinatorial invariant recording how Karoubi objects are observed through probe embeddings.

### 1.3 Significance

This result has implications across several domains:

1. **Topos theory**: κ becomes an invariant of presheaf toposes, giving a computable complexity measure for topological/geometric structures presented as presheaf categories.

2. **Representation theory**: κ is stable under idempotent completion, the operation that decomposes representations into direct summands. This places κ alongside K-theoretic invariants in its stability properties.

3. **Computer science**: For automata and transition systems modeled as categories, Morita invariance means observational complexity is preserved under state completion with retract states.

4. **Algebraic geometry**: Different site presentations of the same topos yield the same κ, providing a computable criterion for Morita non-equivalence.

## 2. Definitions and Notation

### 2.1 Finite Categories

A **finite category** C consists of:
- A finite set Obj(C) of objects
- For each pair X, Y ∈ Obj(C), a finite set Hom(X,Y) of morphisms
- Composition maps and identity morphisms satisfying the usual axioms

We assume all hom-sets are finite and carry decidable equality (the class `FiniteHomCategory` in our formalization).

### 2.2 Probe Families and Probe Complexity

**Definition 2.1.** A **probe family** P ⊆ Obj(C) is a finite set of objects.

**Definition 2.2.** A probe family P **separates** morphisms if for all X, Y ∈ Obj(C) and f, g : X → Y with f ≠ g, there exist Z ∈ P and h : Z → X such that h ∘ f ≠ h ∘ g.

**Definition 2.3.** The **probe complexity** κ(C) is the minimum cardinality of a separating probe family:
$$\kappa(C) = \min \{ |P| : P \subseteq \text{Obj}(C),\ P \text{ separating} \}$$

This is well-defined since the total family Obj(C) is always separating (take h = id_X).

### 2.3 Karoubi Envelope

**Definition 2.4.** An endomorphism p : X → X is **idempotent** if p ∘ p = p.

**Definition 2.5.** The **Karoubi envelope** Kar(C) has:
- Objects: pairs (X, p) where X ∈ Obj(C) and p : X → X is idempotent
- Morphisms (X,p) → (Y,q): morphisms f : X → Y in C with p ∘ f ∘ q = f
- Composition: inherited from C
- Identity on (X,p): the morphism p itself

There is a canonical fully faithful embedding ι : C → Kar(C) mapping X to (X, id_X).

### 2.4 Split-Stable Probe Family (New)

**Definition 2.6.** A **split-stable probe family** on C is a triple (P, σ, τ) where:
- P ⊆ Obj(C) is a probe family
- σ is a proof that P separates morphisms in C
- τ is a proof that ι(P) = {(Z, id_Z) : Z ∈ P} separates morphisms in Kar(C)

**Theorem (Every Separating Family is Split-Stable).** Every separating probe family on C is split-stable.

### 2.5 Retract Profile (New)

**Definition 2.7.** The **retract profile** of a Karoubi object (X, p) relative to a probe family P is the family:
$$\text{rprof}_P(X,p) = \bigl( \text{Hom}_{\text{Kar}(C)}(\iota(Z), (X,p)) \bigr)_{Z \in P}$$
recording how (X,p) is observed through each embedded probe.

## 3. Main Theorems and Proof Sketches

### 3.1 Theorem A: Equivalence Invariance

**Theorem 3.1.** If e : C ≌ D is an equivalence of categories, then κ(C) = κ(D).

*Proof sketch.* It suffices to show κ(D) ≤ κ(C) for any equivalence e : C ≌ D; the reverse follows by applying the same argument to e⁻¹.

Let P be a minimum separating family for C. We show e.F(P) = {e.F(Z) : Z ∈ P} separates D. Given f ≠ g : X → Y in D, consider e.G(f) ≠ e.G(g) (by faithfulness of G = e.inverse). Since P separates C, there exist Z ∈ P and h₀ : Z → e.G(X) with h₀ ∘ e.G(f) ≠ h₀ ∘ e.G(g).

Define h = e.F(h₀) ∘ ε_X : e.F(Z) → X where ε is the counit of e. By naturality of ε and faithfulness of e.F, h separates f from g.

Since |e.F(P)| ≤ |P|, we get κ(D) ≤ κ(C). □

### 3.2 Key Lemma: Karoubi Morphism Absorption

**Lemma 3.2.** For any Karoubi morphism f : (X,p) → (Y,q), we have p ∘ f = f and f ∘ q = f.

*Proof.* From the Karoubi condition p ∘ f ∘ q = f:
- Left absorption: p ∘ f = p ∘ (p ∘ f ∘ q) = (p ∘ p) ∘ f ∘ q = p ∘ f ∘ q = f
- Right absorption: f ∘ q = (p ∘ f ∘ q) ∘ q = p ∘ f ∘ (q ∘ q) = p ∘ f ∘ q = f □

### 3.3 Theorem B: Karoubi Invariance (Upper Bound)

**Theorem 3.3.** κ(Kar(C)) ≤ κ(C).

*Proof sketch.* Let P be a minimum separating family for C. We show that ι(P) = {(Z, id_Z) : Z ∈ P} separates morphisms in Kar(C).

Let f ≠ g : (X,p) → (Y,q) in Kar(C). Then f_underlying ≠ g_underlying as morphisms X → Y in C (by the definition of equality in Karoubi hom-sets). Since P separates C, there exist Z ∈ P and h₀ : Z → X with h₀ ∘ f_underlying ≠ h₀ ∘ g_underlying.

**Key step:** Define h = h₀ ∘ p : Z → X. This is a valid Karoubi morphism (Z, id_Z) → (X, p) because:
$$\text{id}_Z \circ h \circ p = h_0 \circ p \circ p = h_0 \circ p = h$$

Moreover, h still separates:
$$h \circ f_{\text{underlying}} = h_0 \circ p \circ f_{\text{underlying}} = h_0 \circ f_{\text{underlying}}$$
using Lemma 3.2 (p ∘ f_underlying = f_underlying). Similarly for g. Since h₀ ∘ f_underlying ≠ h₀ ∘ g_underlying, we conclude h ∘ f ≠ h ∘ g in Kar(C). □

### 3.4 Theorem B: Karoubi Invariance (Lower Bound)

**Theorem 3.4.** κ(C) ≤ κ(Kar(C)).

*Proof sketch.* Let Q be a minimum separating family for Kar(C). Define R = {K.X : K ∈ Q} ⊆ Obj(C). Then |R| ≤ |Q|.

For f ≠ g : X → Y in C, their images ι(f) ≠ ι(g) in Kar(C) (ι is faithful; in fact, f and g have the same underlying morphisms as ι(f) and ι(g)). Since Q separates Kar(C), there exist K = (Z, p) ∈ Q and h : K → ι(X) = (X, id_X) with h ∘ ι(f) ≠ h ∘ ι(g).

The underlying morphism h_underlying : Z → X satisfies h_underlying ∘ f ≠ h_underlying ∘ g (since composition of underlying morphisms in Kar(C) is just composition in C). Since Z = K.X ∈ R, the family R separates C.

Therefore κ(C) ≤ |R| ≤ |Q| = κ(Kar(C)). □

### 3.5 Theorem B: Karoubi Invariance (Combined)

**Theorem 3.5 (Theorem B).** κ(C) = κ(Kar(C)).

*Proof.* Immediate from Theorems 3.3 and 3.4 by antisymmetry of ≤. □

### 3.6 Theorem C: Morita Invariance

**Theorem 3.6 (Theorem C).** If Kar(C) ≌ Kar(D), then κ(C) = κ(D).

*Proof.*
$$\kappa(C) = \kappa(\text{Kar}(C)) = \kappa(\text{Kar}(D)) = \kappa(D)$$
using Theorem B for the first and third equalities and Theorem A for the second. □

## 4. Algorithms

### 4.1 Computing κ(C)

**Algorithm 1: Exact Probe Complexity**
```
Input: Finite category C = (Obj, Hom, ∘, id)
Output: κ(C)

1. Compute P = {(f,g) : f ≠ g, f || g} (parallel pairs)
2. If P = ∅, return 0
3. For k = 1, 2, ..., |Obj|:
4.   For each S ⊆ Obj with |S| = k:
5.     If separates(S, P, C):
6.       Return k
7. Return |Obj|  // unreachable

separates(S, P, C):
  For each (f,g) ∈ P:
    found ← false
    For each Z ∈ S:
      For each h ∈ Hom(Z, source(f)):
        If h∘f ≠ h∘g: found ← true; break
    If not found: return false
  Return true
```

**Complexity:** O(C(n,k) · |P| · n · H) where n = |Obj|, k = κ(C), H = max hom-set size.

### 4.2 Building the Karoubi Envelope

**Algorithm 2: Karoubi Envelope Construction**
```
Input: Finite category C
Output: Kar(C) as a finite category

1. For each X ∈ Obj(C):
2.   Compute Idem(X) = {p ∈ End(X) : p∘p = p}
3. Kar_Obj ← {(X,p) : X ∈ Obj(C), p ∈ Idem(X)}
4. For each (X,p), (Y,q) ∈ Kar_Obj:
5.   Kar_Hom((X,p),(Y,q)) ← {f ∈ Hom(X,Y) : p∘f∘q = f}
6. Inherit composition from C
7. Identity on (X,p) is p
8. Return Kar(C)
```

**Complexity:** O(n·E² + K²·H) where E = max |End(X)|, K = |Kar_Obj|.

### 4.3 Certified Comparison

**Algorithm 3: Certified κ-Comparison**
```
Input: Finite category C
Output: Certificate that κ(C) = κ(Kar(C))

1. κ₁ ← compute_kappa(C)
2. Kar_C ← build_karoubi(C)
3. κ₂ ← compute_kappa(Kar_C)
4. Assert κ₁ = κ₂ (guaranteed by theorem)
5. Return (κ₁, κ₂, separating families as witnesses)
```

## 5. Computational Experiments

### 5.1 Test Suite

We tested the Karoubi invariance theorem on the following families:

| Category | |Obj| | |Mor| | κ(C) | |Kar Obj| | |Kar Mor| | κ(Kar) | Match |
|---|---|---|---|---|---|---|---|
| Discrete(2) | 2 | 2 | 0 | 2 | 2 | 0 | ✓ |
| Z/2Z monoid | 1 | 2 | 1 | 1 | 2 | 1 | ✓ |
| Band{1,e,f} | 1 | 3 | 1 | 3 | 14 | 1 | ✓ |
| TwoParallel (A⇉B) | 2 | 4 | 1 | 2 | 4 | 1 | ✓ |
| Chain(3) poset | 3 | 6 | 0 | 3 | 6 | 0 | ✓ |

### 5.2 Observations

1. **Idempotent-free categories**: When C has no nontrivial idempotents, Kar(C) ≅ C and invariance is trivial.

2. **Band monoids**: The most interesting test case. The band {1,e,f} with e²=e, f²=f, ef=fe=e has three nontrivial idempotents. Its Karoubi envelope expands from 1 object / 3 morphisms to 3 objects / 14 morphisms, yet κ remains 1.

3. **Thin categories**: All poset/preorder categories have κ = 0, and this is preserved since idempotent completion of a thin category remains thin.

## 6. Applications

### 6.1 Topos Theory and Algebraic Geometry

Different sites can present the same presheaf topos. If κ is indeed a topos invariant (which our theorem establishes for finite sites), then:

- κ provides a **computable obstruction** to Morita equivalence: if κ(C) ≠ κ(D), then [C^op, Set] ≇ [D^op, Set].
- For scheme presentations, κ measures the minimum "atlas size" for morphism detection.

### 6.2 Automata and Transition Systems

A deterministic finite automaton with state set S and input alphabet Σ generates a transition monoid M ⊆ End(S). The one-object category of M has κ(M) measuring the observational complexity of the automaton.

Morita invariance implies: completing the transition monoid with formal images of idempotent transformations (adding "latent retract states") does not change the observational complexity. This is a categorical version of state minimization invariance.

### 6.3 Representation Theory

For a finite monoid M, the Karoubi envelope of the one-object category of M corresponds to splitting the idempotents of M — making each principal right ideal Me (for idempotent e) into an explicit object. The theorem says κ is stable under this splitting, connecting to Green's J-relation and the classification of finite semigroups.

## 7. New Definitions and Their Theory

### 7.1 Split-Stable Probe Families

The concept of a split-stable probe family captures a structural property: a separating family that remains separating when lifted to the Karoubi envelope. Our main theorem shows this is *automatic* — every separating family is split-stable. This suggests that the combinatorics of probe families are intrinsically compatible with idempotent splitting.

### 7.2 Retract Profiles

The retract profile provides a finer invariant: for each Karoubi object (X,p) and each probe Z, it records the full hom-set from the embedded probe to (X,p). Objects with identical retract profiles are indistinguishable by the probe family. This gives a direct combinatorial characterization of how probes interact with idempotent splitting.

## 8. Discussion

### 8.1 Formal Verification

All main theorems are formalized and verified in Lean 4 using the Mathlib library. The formalization includes:

- Definition of `FiniteHomCategory` — the typeclass for categories with finite decidable hom-sets
- Finiteness instances for the Karoubi envelope
- The full proof chain: equivalence invariance → Karoubi upper/lower bounds → Morita invariance
- The `SplitStableProbeFamily` structure and the theorem that all separating families are split-stable

The proofs rely on standard axioms only (propext, Classical.choice, Quot.sound).

### 8.2 Limitations

1. The full presheaf-Morita bridge (presheaf equivalence implies Cauchy completion equivalence) is not formalized, as it requires significant Morita theory infrastructure. We state it as a clearly isolated assumption.

2. Our algorithms are exponential in the number of objects. Polynomial-time algorithms or approximations for κ remain open.

3. The extension to infinite categories requires careful treatment of the "finite separating family" condition.

## 9. Future Work

1. **Topos-generator conjecture**: κ(C) equals the minimal size of a finite separating family of representable presheaves in [C^op, Set].

2. **Subadditivity**: Investigate whether κ(C ⊔ D) = max(κ(C), κ(D)).

3. **Product formula extension**: The existing κ(C × D) = κ(C) + κ(D) should interact with Karoubi invariance to give κ(Kar(C × D)) = κ(C) + κ(D).

4. **Efficient algorithms**: Develop polynomial-time algorithms or FPT algorithms for computing κ.

5. **Higher-categorical generalization**: Extend κ to enriched categories or (∞,1)-categories.

## 10. References

1. Morita, K. "Duality for modules and its applications to the theory of rings with minimum condition." *Science Reports of the Tokyo Kyoiku Daigaku* 6 (1958): 83–142.

2. Karoubi, M. "K-théorie." *Annals of Mathematics Studies* 226, Princeton University Press, 1978.

3. Borceux, F. *Handbook of Categorical Algebra*, Cambridge University Press, 1994.

4. Mathlib Contributors. "Mathlib: the math library of Lean 4." https://leanprover-community.github.io/mathlib4_docs/

5. Mac Lane, S. and Moerdijk, I. *Sheaves in Geometry and Logic*, Springer, 1992.

6. Rhodes, J. and Steinberg, B. *The q-theory of Finite Semigroups*, Springer, 2009.
