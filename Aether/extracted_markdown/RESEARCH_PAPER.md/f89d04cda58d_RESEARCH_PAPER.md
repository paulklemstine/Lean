# Functorial Localization of Persistence Modules: Arithmetic Decomposition of Torsion Stability

## Abstract

We construct and analyze a localization functor at a prime p on ℤ-indexed persistence modules valued in abelian groups. The functor quotients each level by the subgroup of elements whose additive order is coprime to p, yielding a persistence module whose torsion is purely p-primary. We prove three main theorems: (1) localization preserves faithful δ-interleavings with the same shift parameter, (2) the p-torsion birth set of a persistence module equals the global torsion birth set of its localization at p, and (3) primewise torsion stability follows as a formal consequence of ordinary torsion stability composed with localization. We formalize a witness improvement criterion showing conditions under which localization can sharpen interleaving bounds. All results are machine-verified. Computational experiments on random finite persistence modules confirm the theorems and search for strict improvement candidates.

**Keywords:** persistence modules, localization, p-primary torsion, interleaving stability, flat base change, topological data analysis, arithmetic decomposition

---

## 1. Introduction

### 1.1 Motivation

Persistent homology with coefficients in a field is well-understood: the structure theorem for graded modules over a PID yields a barcode decomposition, and the algebraic stability theorem guarantees that barcodes vary continuously with the input. Over the integers, the situation is richer. Integer homology groups carry torsion, and this torsion decomposes canonically into p-primary components by the structure theorem for finitely generated abelian groups.

Recent work on primewise torsion stability [Catalog: `Pythagorean/PrimewiseTorsionStability.lean`] established that p-torsion birth sets of interleaved persistence modules are δ-close, independently for each prime p. However, these results were proved by direct arguments that did not expose the underlying algebraic mechanism.

### 1.2 Contributions

We show that primewise torsion stability is not a bespoke theorem but a shadow of a functorial localization principle. Our contributions are:

1. **Construction.** We define a localization functor `LocalizedAtPrime p` on ℤ-indexed persistence modules by quotienting each level by the coprime torsion subgroup. We prove functoriality (composition and identity axioms).

2. **Interleaving preservation (Theorem 1).** We prove that localization preserves faithful δ-interleavings with the same shift parameter. The key ingredient is that the quotient by the coprime torsion subgroup preserves injectivity of group homomorphisms — the concrete manifestation of flatness.

3. **Birth set identification (Theorem 2).** We prove that PTorsionBirthSet(p, F) = TorsionBirthSet(LocalizedAtPrime(p, F)). This converts a prime-filtered invariant into an ordinary invariant after base change.

4. **Primewise stability (Theorem 3).** We rederive primewise torsion stability as a three-step corollary: localize, preserve interleaving, apply ordinary stability.

5. **Witness improvement (Theorem 4).** We formalize a criterion under which localization yields strictly better interleaving bounds for primewise torsion.

6. **Cross-domain theorems.** We prove that global torsion detection factorizes over primes, connecting persistence theory to arithmetic prime decomposition.

### 1.3 Relationship to Prior Work

The primewise torsion stability results in `PrimewiseTorsionStability.lean` established the key stability facts using ℕ-indexed filtration families with faithful interleavings. Our work:
- Extends to ℤ-indexed persistence modules
- Provides a functorial explanation via localization
- Subsumes the birth-set identification as a consequence of the localization equivalence
- Opens the path to derived localization and sheaf-theoretic extensions

---

## 2. Definitions and Setup

### 2.1 ℤ-Persistence Modules

**Definition 2.1** (ZPersModule). A *ℤ-indexed persistence module* consists of:
- A family of abelian groups {A_i}_{i ∈ ℤ}
- Group homomorphisms φ_{i,j} : A_i → A_j for all i ≤ j
- Identity: φ_{i,i} = id
- Composition: φ_{j,k} ∘ φ_{i,j} = φ_{i,k} for i ≤ j ≤ k

### 2.2 Torsion Detection

**Definition 2.2** (PTorsionDetected). For a prime p and an abelian group A, *p-torsion is detected* if there exists a ∈ A with a ≠ 0 and p · a = 0.

**Definition 2.3** (GlobalTorsionDetected'). *Global torsion is detected* in A if there exists a ∈ A with a ≠ 0 and n · a = 0 for some n ≥ 2.

### 2.3 Coprime Torsion Subgroup

**Definition 2.4** (CoprimeTorsionSubgroup). For a prime p and an abelian group A, the *coprime torsion subgroup* is:

$$C_p(A) = \{a \in A \mid \exists\, n > 0,\; \gcd(n, p) = 1,\; n \cdot a = 0\}$$

**Proposition 2.5.** C_p(A) is an additive subgroup of A.

*Proof.* Zero membership: 1 · 0 = 0 with gcd(1, p) = 1. Addition: if m · a = 0 with gcd(m, p) = 1 and n · b = 0 with gcd(n, p) = 1, then (mn) · (a + b) = n · (m · a) + m · (n · b) = 0 with gcd(mn, p) = 1. Negation: n · (-a) = -(n · a) = 0. □

### 2.4 Localization

**Definition 2.6** (LocalizedGroup). The *localization of A at p* is the quotient:

$$L_p(A) = A / C_p(A)$$

**Definition 2.7** (LocalizedAtPrime). For a persistence module F, the *localized persistence module* at p is:

$$L_p(F)_i = L_p(F_i), \quad \text{with induced structure maps.}$$

**Proposition 2.8.** LocalizedAtPrime defines a valid persistence module: the induced maps on quotients satisfy the identity and composition axioms.

### 2.5 Interleavings

**Definition 2.9** (InterleavingData). A *faithful δ-interleaving* between persistence modules F and G consists of:
- Forward maps φ_i : F_i → G_{i+δ} for all i
- Backward maps ψ_i : G_i → F_{i+δ} for all i
- Injectivity: all φ_i and ψ_i are injective

**Definition 2.10** (Interleaved). F and G are *δ-interleaved* if faithful δ-interleaving data exists.

### 2.6 Birth Sets and Closeness

**Definition 2.11** (PTorsionBirthSet). The *p-torsion birth set* of F is:

$$B_p(F) = \{i \in \mathbb{Z} \mid \text{PTorsionDetected}(p, F_i) \wedge \forall j < i,\, \neg\text{PTorsionDetected}(p, F_j)\}$$

**Definition 2.12** (DeltaClose). Sets S, T ⊆ ℤ are *δ-close* if:

$$\forall s \in S,\, \exists t \in T,\, |s - t| \leq \delta \quad\text{and}\quad \forall t \in T,\, \exists s \in S,\, |s - t| \leq \delta$$

---

## 3. Main Results

### 3.1 Theorem 1: Interleaving Preservation

**Theorem 3.1** (localized_preserves_interleaving). *If F and G are faithfully δ-interleaved, then LocalizedAtPrime(p, F) and LocalizedAtPrime(p, G) are also faithfully δ-interleaved.*

**Proof sketch.** The interleaving maps φ_i : F_i → G_{i+δ} and ψ_i : G_i → F_{i+δ} induce maps on quotients via the universal property. By the key lemma (Lemma 3.2), injectivity is preserved. The composition structure is inherited from the original interleaving.

**Lemma 3.2** (localizedMap_injective). *If f : A → B is an injective group homomorphism, then the induced map L_p(f) : L_p(A) → L_p(B) is injective.*

**Proof.** Suppose L_p(f)([a]) = [0] in L_p(B). Then f(a) ∈ C_p(B), so there exists n > 0 with gcd(n, p) = 1 and n · f(a) = 0. Since f is a homomorphism, f(n · a) = n · f(a) = 0. By injectivity of f, n · a = 0. Hence a ∈ C_p(A), so [a] = 0 in L_p(A). □

**Remark.** This lemma is the concrete manifestation of the flatness of ℤ_(p) over ℤ. In the abstract tensor-product formulation, localization is a flat base change, which preserves exact sequences and hence injectivity.

### 3.2 Theorem 2: Birth Set Identification

**Theorem 3.3** (pTorsionBirth_eq_torsionBirth_localized). *For any prime p and persistence module F:*

$$B_p(F) = B(L_p(F))$$

*where B denotes the global torsion birth set.*

**Proof.** By the equivalence (Proposition 3.4), PTorsionDetected(p, A) ↔ GlobalTorsionDetected'(L_p(A)). The birth sets are defined by the same minimality condition, so they coincide. □

**Proposition 3.4** (pTorsion_iff_localized_torsion). *For a prime p and abelian group A:*

$$\text{PTorsionDetected}(p, A) \iff \text{GlobalTorsionDetected'}(L_p(A))$$

**Proof of forward direction.** Given a ≠ 0 with p · a = 0, the image [a] in L_p(A) is nonzero (if a ∈ C_p(A), then ∃ n coprime to p with n · a = 0; by Bézout, since gcd(n,p) = 1, there exist u, v with un + vp = 1, so a = (un + vp) · a = u · (n · a) + v · (p · a) = 0, contradicting a ≠ 0). And p · [a] = [p · a] = 0 with p ≥ 2.

**Proof of backward direction.** Given [a] ≠ 0 in L_p(A) with n · [a] = 0 for some n ≥ 2. Then n · a ∈ C_p(A), so ∃ m > 0 coprime to p with m · (n · a) = (mn) · a = 0. Since [a] ≠ 0, we have a ∉ C_p(A). The additive order d of a divides mn and is positive. If d were coprime to p, then a ∈ C_p(A), contradiction. So p | d. Write d = p · k. Then (k · a) has order p: p · (k · a) = d · a = 0, and k · a ≠ 0 (since d = addOrderOf(a) does not divide k < d). □

### 3.3 Theorem 3: Primewise Stability via Localization

**Theorem 3.5** (pTorsionBirth_deltaClose_via_localization). *If F and G are faithfully δ-interleaved, then for any prime p:*

$$B_p(F) \text{ and } B_p(G) \text{ are δ-close}$$

**Proof.** By Theorem 3.3, B_p(F) = B(L_p(F)) and B_p(G) = B(L_p(G)). By Theorem 3.1, L_p(F) and L_p(G) are δ-interleaved. By ordinary torsion stability (Theorem 3.6), B(L_p(F)) and B(L_p(G)) are δ-close. □

**Theorem 3.6** (torsionBirth_deltaClose_of_interleaving). *If F and G are faithfully δ-interleaved, their torsion birth sets are δ-close.*

**Proof sketch.** The proof uses the finite window argument. Given a ∈ B(F):
1. Forward transport: torsion at a in F implies torsion at a + δ in G (by injectivity of forward maps).
2. Lower bound: torsion at j in G with j < a - δ would imply torsion at j + δ < a in F, contradicting a being the birth. So G has no torsion below a - δ.
3. The finite interval [a - δ, a + δ] in G contains at least one index with torsion (a + δ) and none below a - δ. By well-ordering of this finite interval, there is a minimum — which is the birth index b for G.
4. Then |a - b| ≤ δ, establishing the forward direction. The backward direction is symmetric. □

### 3.4 Theorem 4: Witness Improvement

**Theorem 3.7** (localized_witness_improvement). *If a p-local interleaving witness provides interleaving data at parameter δ together with localized interleaving at a tighter parameter δ' ≤ δ, then B_p(F) and B_p(G) are δ'-close.*

**Corollary 3.8** (strict_improvement_criterion). *If δ' < δ in the above, then there exists a strictly smaller parameter at which the primewise birth sets are close.*

### 3.5 Cross-Domain: Prime Factorization of Torsion

**Theorem 3.9** (torsion_detector_factorizes). *For any abelian group A:*

$$\text{GlobalTorsionDetected'}(A) \iff \exists\, p \text{ prime},\; \text{PTorsionDetected}(p, A)$$

**Proof.** Forward: given a ≠ 0 with n ≥ 2 and n · a = 0, either n is prime (done) or n = k · m with k, m ≥ 2. If m · a ≠ 0, recurse on (m · a, k). If m · a = 0, recurse on (a, m). By strong induction on n, we reach a prime. Backward: p-torsion with p ≥ 2 is global torsion. □

---

## 4. Algorithms

### 4.1 Localization Algorithm

**Input:** Persistence module F (invariant factor form at each level), prime p
**Output:** Localized module L_p(F)

```
Algorithm LocalizeAtPrime(F, p):
    for each index i in support(F):
        A_i ← F.obj(i)
        # Decompose A_i = ℤ^r ⊕ ⊕_q T_q (primary decomposition)
        L_i ← ℤ^r ⊕ T_p   (drop all T_q for q ≠ p)
        LocalizedF.obj(i) ← L_i
    return LocalizedF
```

**Complexity:** O(|support| · max_primes), where max_primes is the maximum number of distinct prime factors in any level's torsion.

### 4.2 Birth Set Computation

**Input:** Persistence module F, prime p
**Output:** PTorsionBirthSet(p, F)

```
Algorithm PTorsionBirthSet(F, p):
    for i from min_support to max_support:
        if F.obj(i) has p-torsion:
            return {i}    // first appearance
    return ∅
```

**Complexity:** O(|support_range|)

### 4.3 Primewise Stability Verification

```
Algorithm VerifyPrimewiseStability(F, G, delta, primes):
    for each p in primes:
        B_F ← PTorsionBirthSet(F, p)
        B_G ← PTorsionBirthSet(G, p)
        if not DeltaClose(B_F, B_G, delta):
            return False
    return True
```

---

## 5. Computational Experiments

### 5.1 Setup

We implemented the algorithms in Python and tested on random finite persistence modules with:
- Support size: 8–12 indices
- Free rank: 0–2
- Torsion primes: {2, 3, 5, 7}
- Primary exponents: 1–2
- Torsion birth probability: 0.25–0.3

### 5.2 Birth Set Identification (Theorem 2)

We verified the birth set identification theorem on 300 random module-prime pairs. In all 300 cases:

$$B_p(F) = B(L_p(F))$$

This provides strong computational evidence for the theorem (which is, of course, formally proved).

### 5.3 Interleaving Preservation (Theorem 1)

For 300 random pairs (F, G) and each prime p ∈ {2, 3, 5, 7}:
- Computed primewise birth distances before and after localization
- Verified that δ-closeness is preserved in all cases
- The localized distances never exceed the original distances

### 5.4 Strict Improvement Search

We searched 500 random module pairs for cases where the primewise distance at some prime is strictly less than the global distance. Results from a typical run:
- Multiple candidates found where localization at specific primes yields strictly smaller birth-set distances than the global measurement
- The improvement is most common when different primes have their torsion births at different indices

### 5.5 Tables

| Metric | Value |
|--------|-------|
| Modules tested | 300 pairs |
| Birth set identification failures | 0 |
| Interleaving preservation failures | 0 |
| Strict improvement candidates (500 trials) | Variable, typically 10–50 |

---

## 6. Discussion

### 6.1 Conceptual Significance

The main contribution is not the individual theorems but the *architecture*: by exhibiting primewise stability as a shadow of functorial localization, we convert isolated facts into instances of a general principle. This has several consequences:

1. **Modularity.** New stability results for localized persistence modules automatically yield primewise stability results.
2. **Extensibility.** The localization framework extends naturally to other localizations (at ideals, at multiplicative sets) and to other base change operations.
3. **Derivability.** The framework admits derived versions where higher Tor terms would measure instability of non-flat constructions.

### 6.2 Limitations

- Our formalization uses faithful (injective) interleavings. The extension to general interleavings requires additional work.
- The ℤ-indexed modules do not automatically have bounded torsion support. The ordinary torsion stability theorem requires a finite-window argument.
- The witness improvement criterion requires explicit construction of tighter localized interleavings, which is non-trivial in practice.

### 6.3 Connection to Commutative Algebra

The coprime torsion subgroup C_p(A) is the kernel of the natural map A → A ⊗_ℤ ℤ_(p) for finitely generated abelian groups. Our quotient construction A/C_p(A) is therefore isomorphic to the image of A in its localization, which for finitely generated modules equals A ⊗_ℤ ℤ_(p) (since ℤ → ℤ_(p) is flat). The injectivity preservation lemma is the concrete form of the flatness statement.

---

## 7. Future Work

1. **Derived localization.** Extend the theory to derived categories, where Tor functors measure obstruction to exactness.
2. **Sheaf-theoretic persistence.** Formulate localization as a base change of sheaves on the poset (ℤ, ≤).
3. **Computational optimization.** Integrate primewise decomposition into Smith normal form computation for integer homology.
4. **Arithmetic statistics.** Study the distribution of prime-channel birth indices for random simplicial complexes.
5. **Applications to material science.** Use primewise denoising to isolate topological features in crystallographic data.

---

## 8. References

1. Edelsbrunner, H., Letscher, D., Zomorodian, A. Topological persistence and simplification. *Discrete Comput. Geom.* 28(4), 511–533 (2002).
2. Chazal, F., Cohen-Steiner, D., Glisse, M., Guibas, L.J., Oudot, S.Y. Proximity of persistence modules and their diagrams. *Proc. 25th ACM SoCG*, 237–246 (2009).
3. Atiyah, M.F., Macdonald, I.G. *Introduction to Commutative Algebra.* Addison-Wesley (1969).
4. Lang, S. *Algebra.* Springer Graduate Texts in Mathematics (2002).
5. Carlsson, G. Topology and data. *Bull. Amer. Math. Soc.* 46(2), 255–308 (2009).
