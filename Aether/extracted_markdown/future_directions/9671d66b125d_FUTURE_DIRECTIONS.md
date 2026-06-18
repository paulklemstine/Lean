# Future Directions

This document outlines concrete next steps building on the formalized one-round sum-check soundness theorem. Each direction includes a precise theorem target, significance assessment, proof strategy, and cross-domain connections.

---

## 1. Multi-Round Sum-Check Soundness with Union Bound

### Precise Theorem Statement

For an $n$-round sum-check protocol over $\mathbb{F}_q$ with individual variable degree $d$, if the prover deviates from the honest strategy at any round, the probability of passing all verifier checks is at most $nd/q$.

```
theorem sumcheck_multi_round_soundness
    {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    (n d : ℕ)
    (sent truePoly : Fin n → Polynomial F)
    (hne : ∃ i, sent i ≠ truePoly i)
    (hdeg : ∀ i, (sent i - truePoly i).natDegree ≤ d) :
    -- Probability of all rounds passing ≤ n * d / |F|
    sorry
```

### Why Breakthrough-Level

This would be the first formally verified end-to-end soundness theorem for an interactive proof protocol. It directly enables verified soundness claims for systems worth billions of dollars in deployed cryptocurrency infrastructure.

### Proof Strategy

1. Model the $n$-round protocol as a sequence of polynomial checks with independent random challenges.
2. At each round where cheating occurs, apply `sumcheck_inductive_soundness_step` to bound the per-round success probability.
3. Apply a formal union bound (available in Mathlib's probability theory) to combine per-round bounds.
4. The key subtlety: after a successful cheat at round $i$, the challenge $r_i$ is fixed, potentially altering the true polynomial at round $i+1$. Handle this by conditioning and showing the inductive structure preserves the degree bound.

### Cross-Domain Connection

**Complexity theory:** This theorem directly yields a formal proof that $\text{IP} \supseteq \text{\#P}$, since sum-check reduces counting problems to interactive verification. Combined with arithmetization, it approaches the celebrated IP = PSPACE theorem.

---

## 2. Multivariate Schwartz-Zippel over Finite Grids

### Precise Theorem Statement

For a nonzero polynomial $f \in \mathbb{F}[X_1, \ldots, X_n]$ of total degree $d$ and a finite subset $S \subseteq \mathbb{F}$:
$$\Pr_{(x_1, \ldots, x_n) \sim S^n}[f(x_1, \ldots, x_n) = 0] \leq \frac{d}{|S|}.$$

```
theorem schwartz_zippel_multivariate
    {F : Type*} [Field F] [DecidableEq F]
    (n : ℕ) (S : Finset F)
    (f : MvPolynomial (Fin n) F)
    (hf : f ≠ 0)
    (hd : f.totalDegree ≤ d) :
    (S.pi (fun _ => S)).filter (fun x => MvPolynomial.eval x f = 0)).card
      ≤ d * S.card ^ (n - 1)
```

### Why Breakthrough-Level

The multivariate Schwartz-Zippel lemma is the workhorse of randomized algebraic algorithms: polynomial identity testing, perfect matching detection (Tutte matrix), circuit lower bounds, and derandomization. A formal version would be immediately reusable across dozens of formalization efforts.

### Proof Strategy

Induction on the number of variables $n$:
- **Base case ($n = 1$):** This is exactly our `card_roots_le_natDegree`.
- **Inductive step:** Write $f = \sum_{i=0}^{d_1} X_1^i \cdot g_i(X_2, \ldots, X_n)$. Fix $x_1$; either the restricted polynomial is nonzero (apply IH) or the leading coefficient polynomial vanishes at $x_1$ (bounded by degree).

This requires Mathlib's `MvPolynomial` API, coefficient extraction, and careful degree tracking.

### Cross-Domain Connection

**Randomized algorithms:** Formalizing Schwartz-Zippel enables formal verification of randomized algorithms in computational algebra, including polynomial identity testing (the Schwartz-Zippel algorithm itself), perfect matching detection via the Tutte matrix, and algebraic circuit lower bounds.

---

## 3. Formal Low-Degree Testing (Reed-Solomon Proximity)

### Precise Theorem Statement

For the Reed-Solomon code $\text{RS}[q, k]$ (evaluations of degree $< k$ polynomials over $\mathbb{F}_q$), if a function $f : \mathbb{F}_q \to \mathbb{F}_q$ is $\delta$-far from every codeword, then a random line test detects this with probability $\geq \delta$.

### Why Breakthrough-Level

Low-degree testing is the combinatorial core of PCPs and IOPs. A formal version would be a major step toward verified PCP constructions and would directly support the soundness analysis of FRI (Fast Reed-Solomon IOP of Proximity), used in STARKs.

### Proof Strategy

1. Formalize Reed-Solomon codes as evaluation maps of bounded-degree polynomials.
2. Define proximity ($\delta$-closeness) in terms of Hamming distance.
3. For the basic test (pick a random point, check consistency with a low-degree polynomial), apply our root bound.
4. For the full line test, extend to bivariate interpolation and apply the multivariate Schwartz-Zippel lemma (Direction 2).

### Cross-Domain Connection

**Coding theory:** Reed-Solomon codes are the most widely deployed algebraic error-correcting codes, used in QR codes, satellite communications, and storage systems. Low-degree testing is the algorithmic counterpart of code distance verification. Formalizing this connects proof systems to channel coding.

---

## 4. Polynomial Commitment Verification (KZG-style)

### Precise Theorem Statement

In a KZG polynomial commitment scheme, if a prover commits to a polynomial $p$ and later opens it at a point $z$ claiming $p(z) = v$, the verification equation $e([p(\tau) - v], [1]) = e([\pi], [\tau - z])$ (in pairing notation) holds if and only if the commitment is consistent. Soundness: a cheating prover cannot produce a valid opening proof for an incorrect value except with negligible probability (under the $d$-Strong Diffie-Hellman assumption).

### Why Breakthrough-Level

Polynomial commitments are the universal building block of modern SNARKs (Groth16, Plonk, Marlin, Halo2). Formally verifying their soundness would certify the security foundation of systems securing billions of dollars in digital assets.

### Proof Strategy

1. Formalize the algebraic structure: bilinear pairings over elliptic curves, commitment as polynomial evaluation at a secret point.
2. The key reduction: if $p(z) = v$ then $p(X) - v = (X - z) \cdot q(X)$ for some $q$ — this is the factor theorem.
3. Soundness reduces to: extracting $q$ from a valid proof reveals $p$, and two valid openings at different values imply ability to compute $(X - z)^{-1}$, breaking $d$-SDH.
4. The algebraic core (factor theorem for polynomials) is directly available from our formalization and Mathlib's `Polynomial.dvd_iff_isRoot`.

### Cross-Domain Connection

**Cryptography:** This directly impacts the security of deployed systems including Ethereum's EIP-4844 (proto-danksharding), which uses KZG commitments for data availability sampling. Formal verification of the underlying mathematics would provide unprecedented assurance for critical infrastructure.

---

## 5. Categorical/Sheaf-Theoretic Local Consistency Tests

### Precise Theorem Statement

Define a presheaf of polynomial evaluations on the discrete topology of $\mathbb{F}_q$. A global section (polynomial of degree $\leq d$) is determined by its values on any $d + 1$ points. The sum-check consistency check is a stalk-level test: checking agreement of a purported section with the true section at a random stalk. The detection theorem states that a non-genuine section fails the stalk test at all but a measure-zero (proportion $\leq d/q$) set of stalks.

### Why Breakthrough-Level

This reformulation connects interactive proof soundness to the language of algebraic geometry and sheaf theory. It would:
- Enable transfer of techniques from algebraic geometry to protocol design.
- Provide a unifying framework for understanding local-to-global consistency in both mathematics and computer science.
- Open connections to étale cohomology and descent theory for more sophisticated protocol analysis.

### Proof Strategy

1. Define the presheaf of polynomial evaluations: to each point $x \in \mathbb{F}_q$, assign the stalk $\mathbb{F}_q$ (the value $p(x)$).
2. Show that global sections of degree $\leq d$ form a $(d+1)$-dimensional subspace.
3. The detection theorem becomes: a non-section (element not in the image of the global-to-local map) has non-trivial fiber at all but $\leq d$ stalks.
4. Use Mathlib's category theory and sheaf infrastructure to state this cleanly.

### Cross-Domain Connection

**Algebraic geometry:** The sheaf perspective connects sum-check to the Nullstellensatz and to questions about when local data determines global structure. This is the algebraic analogue of unique continuation principles in PDE theory and holomorphic function theory — local agreement of analytic functions forces global agreement. The polynomial root bound is the discrete, finite-field version of this principle.

---

## Summary Table

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|-------------|
| 1. Multi-round soundness | Medium | Very High | Current work + probability |
| 2. Multivariate Schwartz-Zippel | Medium-Hard | Very High | Current work + MvPolynomial |
| 3. Low-degree testing | Hard | High | Directions 1-2 |
| 4. Polynomial commitments | Hard | Very High | Current work + elliptic curves |
| 5. Sheaf formulation | Medium | Medium-High | Current work + category theory |

Each direction builds on the algebraic detection theorem formalized here, extending it from a single certified brick to a comprehensive formal theory of algebraic proof system soundness.
