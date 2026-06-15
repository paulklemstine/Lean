# Berggren Isogeny Realization Duality: Correspondence Networks on Primitive Pythagorean Triples

## Abstract

We develop a realization–minimality duality theory for weighted correspondence networks on the Berggren tree of primitive Pythagorean triples. Given a semiring R, we define correspondence kernels K : PrimTriple → PrimTriple → R and their finite realizations as families of Berggren-compatible endomorphisms with weights. We prove that:
(1) finitely realizable kernels are closed under addition and have finite row support with explicit cardinality bounds;
(2) every finitely realizable kernel admits a minimal realization whose size is uniquely determined;
(3) the realization–minimality duality holds: finite realizability is equivalent to the existence of a minimal realization;
(4) isomorphic networks produce identical kernels, and observable data fully determines the kernel.
All results are formally verified in Lean 4 with the Mathlib library, using only standard axioms (propext, Classical.choice, Quot.sound).

**Keywords:** Berggren tree, primitive Pythagorean triples, correspondence networks, semimodule realization, minimal automata, Lorentz group, formal verification.

---

## 1. Introduction

### 1.1 Motivation

Primitive Pythagorean triples—solutions (a, b, c) ∈ ℕ³ to a² + b² = c² with gcd(a,b) = 1—have been studied since antiquity. Berggren [1] showed in 1934 that all such triples are generated from the root (3, 4, 5) by three integer matrix transformations, forming an infinite ternary tree. This tree structure has been rediscovered and exploited by many authors [2, 3, 4].

We introduce a new perspective: rather than treating the Berggren tree as a static parametrization of Diophantine solutions, we regard it as a **state space carrying weighted correspondence operators**. A correspondence kernel K(x, y) assigns a weight in a semiring R to each pair of primitive triples, encoding the "strength" of a transition from x to y. A finite realization decomposes K into a finite sum of weighted indicator functions of Berggren-compatible endomorphisms.

This framework creates bridges to several fields:
- **Weighted automata theory**: correspondence kernels are analogues of recognizable formal power series, and the realization theorem is a Diophantine analogue of the Fliess/Carlyle–Paz theorem.
- **Tropical linear algebra**: when R is an idempotent semiring (e.g., tropical ℕ∞), the theory specializes to tropical semimodule decomposition.
- **Graph cryptography**: the minimality and rigidity theorems provide formal guarantees that observable data determines network structure, analogous to the collision-resistance properties needed in cryptographic protocols.

### 1.2 Overview of Results

We organize our contributions into three layers:

**Layer 1: Berggren Tree Foundations.** We formalize the three Berggren child transformations on ℤ-triples, prove they preserve the Pythagorean equation a² + b² = c² and the Lorentzian quadratic form Q(a,b,c) = a² + b² − c², and establish strict hypotenuse growth for positive triples. We also prove that word composition (applying a sequence of generators) preserves the Pythagorean property and that word concatenation corresponds to sequential application.

**Layer 2: Correspondence Network Theory.** Working over an arbitrary state space S with decidable equality and an additive commutative monoid R, we define:
- CorrNetwork S R n: a network with n generators, each consisting of an action S → S and a weight in R.
- The kernel of a network: K(x,y) = ∑ᵢ [Fᵢ(x) = y] · wᵢ.
- FinitelyRealizable K: existence of a network whose kernel equals K.

We prove closure under addition (Theorem 3.1), finite row support (Theorem 3.2), and explicit cardinality bounds on row support (Theorem 3.3).

**Layer 3: Duality and Rigidity.** We prove:
- Existence of minimal realizations (Theorem 4.1).
- Uniqueness of minimal realization size (Theorem 4.2).
- The realization–minimality duality (Theorem 4.3): FinitelyRealizable K ↔ ∃ minimal realization.
- Network isomorphism implies kernel equality (Theorem 4.4).
- Observable data determines the kernel (Theorem 4.5).

### 1.3 Related Work

**Berggren tree:** The tree structure of primitive Pythagorean triples was established by Berggren [1] and rediscovered by Hall [2], Price [3], and others. Romik [4] gave a modern exposition connecting the tree to hyperbolic geometry.

**Weighted automata:** The theory of recognizable formal power series over semirings was initiated by Schützenberger [5] and developed by Eilenberg [6], Berstel and Reutenauer [7]. The Fliess realization theorem [8] establishes the equivalence between recognizability and finite Hankel rank. Our work adapts this paradigm from free monoids to the Berggren tree.

**Lorentz structure:** The connection between Berggren matrices and the Lorentz group O(2,1;ℤ) has been noted by several authors [9, 10]. Our Lorentz form invariance theorems formalize this connection.

**Formal verification:** Previous formal verifications in number theory include the Kepler conjecture (Hales et al. [11]), the odd-order theorem (Gonthier et al. [12]), and various results about Pythagorean triples in proof assistants [13].

---

## 2. Definitions and Notation

### 2.1 Berggren Children

We work with integer triples (a, b, c) ∈ ℤ³. The three Berggren child transformations are:

**Child A:**
$$\text{childA}(a,b,c) = (a - 2b + 2c,\; 2a - b + 2c,\; 2a - 2b + 3c)$$

**Child B:**
$$\text{childB}(a,b,c) = (a + 2b + 2c,\; 2a + b + 2c,\; 2a + 2b + 3c)$$

**Child C:**
$$\text{childC}(a,b,c) = (-a + 2b + 2c,\; -2a + b + 2c,\; -2a + 2b + 3c)$$

These correspond to the matrices:
$$A = \begin{pmatrix} 1 & -2 & 2 \\ 2 & -1 & 2 \\ 2 & -2 & 3 \end{pmatrix}, \quad B = \begin{pmatrix} 1 & 2 & 2 \\ 2 & 1 & 2 \\ 2 & 2 & 3 \end{pmatrix}, \quad C = \begin{pmatrix} -1 & 2 & 2 \\ -2 & 1 & 2 \\ -2 & 2 & 3 \end{pmatrix}$$

### 2.2 Berggren Generators and Words

We define an enumerated type BerggrenGen = {A, B, C} and functions:
- `applyGen g t`: apply generator g to triple t
- `applyWord w t`: apply a list of generators w to t via left fold

The root triple is (3, 4, 5).

### 2.3 Correspondence Networks

**Definition 2.1** (CorrNetwork). A *correspondence network* over state space S with weights in R and n generators is a pair (F, w) where:
- F : Fin n → S → S (actions)
- w : Fin n → R (weights)

**Definition 2.2** (Kernel). The kernel of a network N = (F, w) is:
$$K_N(x, y) = \sum_{i=0}^{n-1} \begin{cases} w_i & \text{if } F_i(x) = y \\ 0 & \text{otherwise} \end{cases}$$

**Definition 2.3** (FinitelyRealizable). A kernel K : S → S → R is *finitely realizable* if there exists n ∈ ℕ and a CorrNetwork S R n whose kernel equals K.

**Definition 2.4** (MinimalRealization). A realization (n, N) of K is *minimal* if N.realizes K and for all m with a realization M of K, n ≤ m.

**Definition 2.5** (Row Support). The row support of K at x is rowSupport(K, x) = {y ∈ S | K(x,y) ≠ 0}.

**Definition 2.6** (Finite Observable Rank). K has *finite observable rank* if its row function factors through a finite type: there exist n, classify : S → Fin n, and template : Fin n → (S → R) such that K(x, ·) = template(classify(x)) for all x.

**Definition 2.7** (Network Isomorphism). Two networks N₁, N₂ of the same size n are *isomorphic* if there exists a permutation π of Fin n such that N₁.action(i) = N₂.action(π(i)) and N₁.weight(i) = N₂.weight(π(i)) for all i.

### 2.4 Berggren Compatibility

A network on ℤ-triples is *Berggren-compatible* if each action factors through a word in the Berggren generators: for each i, there exists a word w such that N.action(i) = applyWord(w).

### 2.5 Lorentz Form

The Lorentzian quadratic form is Q(a,b,c) = a² + b² − c². Pythagorean triples lie on the light cone Q = 0.

---

## 3. Structural Properties of Correspondence Networks

### 3.1 Berggren Preservation

**Theorem 3.0.1** (Pythagorean Preservation). Each Berggren child preserves the Pythagorean equation:
- If a² + b² = c², then childA(a,b,c) satisfies the same equation.
- Similarly for childB and childC.

*Proof sketch.* Direct algebraic verification using nlinarith. For child A, expand:
$$(a-2b+2c)^2 + (2a-b+2c)^2 = (2a-2b+3c)^2$$
and simplify using a² + b² = c². ∎

**Theorem 3.0.2** (Lorentz Invariance). Each Berggren child preserves the Lorentz form Q:
$$Q(\text{child}_g(a,b,c)) = Q(a,b,c)$$
for g ∈ {A, B, C}.

*Proof.* Direct computation using ring. ∎

**Theorem 3.0.3** (Hypotenuse Growth). For positive Pythagorean triples, each child strictly increases the hypotenuse:
$$c < \text{hyp}(\text{child}_g(a,b,c))$$

*Proof sketch.* For child A, the child hypotenuse is 2a − 2b + 3c. We need 2a − 2b + 3c > c, i.e., 2a − 2b + 2c > 0, i.e., a − b + c > 0. Since c² = a² + b² ≥ b² implies c ≥ |b| (for positive c), we have a + c > b. Similar arguments for B and C. ∎

**Theorem 3.0.4** (Word Preservation). If t is Pythagorean, then applyWord(w, t) is Pythagorean for any word w.

*Proof.* Induction on the length of w, using Theorem 3.0.1 at each step. ∎

**Theorem 3.0.5** (Word Concatenation). Application of concatenated words factors:
$$\text{applyWord}(w_1 \mathbin{+\!\!+} w_2, t) = \text{applyWord}(w_2, \text{applyWord}(w_1, t))$$

*Proof.* Follows from List.foldl_append. ∎

### 3.1 Closure Under Addition

**Theorem 3.1** (Sum Realizability). If K₁ and K₂ are finitely realizable, then K₁ + K₂ is finitely realizable.

*Proof sketch.* Given realizations (n₁, N₁) and (n₂, N₂), construct a network of size n₁ + n₂ by concatenating the generator arrays. The first n₁ generators use N₁'s actions and weights; the remaining n₂ use N₂'s. The kernel of the combined network equals the sum of the individual kernels because the indicator sum splits over the two blocks:

$$\sum_{i=0}^{n_1+n_2-1} [\cdots] = \sum_{i=0}^{n_1-1} [\cdots] + \sum_{i=n_1}^{n_1+n_2-1} [\cdots] = K_{N_1}(x,y) + K_{N_2}(x,y)$$

The formal proof uses `Fin.addCases` (or `Fin.sum_univ_add`) to decompose the sum over `Fin (n₁ + n₂)`. ∎

### 3.2 Finite Row Support

**Theorem 3.2** (Finite Row Support). If K is realized by a network N of size n, then for every x, the row support {y | K(x,y) ≠ 0} is finite.

*Proof.* We show rowSupport(K, x) ⊆ {N.action(i, x) | i : Fin n}. If K(x,y) ≠ 0, then ∑ᵢ [Fᵢ(x) = y] · wᵢ ≠ 0, so at least one term is nonzero, giving Fᵢ(x) = y for some i. The right-hand side is the image of a finite set, hence finite. ∎

### 3.3 Row Support Bound

**Theorem 3.3** (Row Support Cardinality Bound). Under the hypotheses of Theorem 3.2, |rowSupport(K, x)| ≤ n.

*Proof.* The row support is a subset of the image of Fin n under (i ↦ Fᵢ(x)), which has cardinality at most n. ∎

This bound is tight: equality holds when all actions produce distinct outputs at x and all weights are nonzero.

---

## 4. Duality and Rigidity Theorems

### 4.1 Minimal Realization Existence

**Theorem 4.1** (Minimal Realization Exists). Every finitely realizable kernel K admits a minimal realization.

*Proof.* The set S = {n ∈ ℕ | ∃ N : CorrNetwork S R n, N.realizes K} is nonempty (by assumption). By the well-ordering principle of ℕ, S has a minimum element n_min. The corresponding network is a minimal realization. ∎

### 4.2 Minimal Size Uniqueness

**Theorem 4.2** (Minimal Size Unique). If (n₁, N₁) and (n₂, N₂) are both minimal realizations of K, then n₁ = n₂.

*Proof.* By minimality of N₁, n₁ ≤ n₂ (since N₂ realizes K). By minimality of N₂, n₂ ≤ n₁ (since N₁ realizes K). By antisymmetry, n₁ = n₂. ∎

### 4.3 Realization–Minimality Duality

**Theorem 4.3** (Duality). A kernel K is finitely realizable if and only if it admits a minimal realization.

*Proof.* Forward: Theorem 4.1. Backward: a minimal realization is, in particular, a realization. ∎

### 4.4 Isomorphism Implies Kernel Equality

**Theorem 4.4** (Isomorphism → Kernel Equality). If N₁ ≅ N₂ (via permutation π), then K_{N₁} = K_{N₂}.

*Proof.* For each (x, y):
$$K_{N_1}(x,y) = \sum_i [F_i^{(1)}(x) = y] \cdot w_i^{(1)} = \sum_i [F_{\pi(i)}^{(2)}(x) = y] \cdot w_{\pi(i)}^{(2)} = \sum_j [F_j^{(2)}(x) = y] \cdot w_j^{(2)} = K_{N_2}(x,y)$$

The second equality uses the isomorphism conditions; the third uses the bijection π to reindex the sum (via `Equiv.sum_comp`). ∎

### 4.5 Observable Data Determines Kernel

**Theorem 4.5** (Observable Determinacy). The observable data of K (its set of row profiles and the assignment of states to profiles) determines K uniquely:
$$\text{obsDataOf}(K_1) = \text{obsDataOf}(K_2) \iff K_1 = K_2$$

*Proof.* The profileOf field of obsDataOf(K) is just K itself. Equality of ObservableData structures implies equality of their profileOf fields. ∎

### 4.6 Finite Observable Rank

**Theorem 4.6** (Finite Realization → Finite Observable Rank). If K is realized by a network N of size n, and the set of "action signatures" {(F₁(x), …, Fₙ(x)) | x ∈ S} is finite, then K has finite observable rank.

*Proof.* The row function K(x, ·) is determined by the action signature at x. If the set of signatures is finite (say of size m), we can classify states by their signatures and define m templates. ∎

### 4.7 Reconstruction Rigidity

**Theorem 4.7** (Minimal Reconstruction Rigidity). If (n₁, N₁) and (n₂, N₂) are minimal realizations of the same kernel K, then n₁ = n₂.

This is a direct corollary of Theorem 4.2. It says: the "public transcript" K completely determines the minimum complexity of any hidden network generating it.

---

## 5. Berggren-Specific Results

### 5.1 Berggren Word Realizability

**Theorem 5.1.** For any Berggren word w and weight r ∈ R, the kernel K(x,y) = [applyWord(w, x) = y] · r is finitely realizable (with 1 generator).

### 5.2 Berggren Combination Realizability

**Theorem 5.2.** Any finite weighted combination of Berggren word kernels is finitely realizable:

$$K(x,y) = \sum_{i=1}^{m} r_i \cdot [\text{applyWord}(w_i, x) = y]$$

is realized by a network of size m with action(i) = applyWord(wᵢ) and weight(i) = rᵢ.

### 5.3 Berggren Compatibility

**Theorem 5.3.** Every Berggren-compatible network has a finitely realizable kernel (trivially, since it IS a finite network).

---

## 6. Algorithms

### 6.1 Network Kernel Evaluation

**Input:** Network N = (F, w) of size n, states x, y.
**Output:** K_N(x, y).

```
function EvalKernel(N, x, y):
    result ← 0
    for i ← 0 to n-1:
        if F[i](x) == y:
            result ← result + w[i]
    return result
```

**Complexity:** O(n) evaluations of action functions, O(n) weight additions.

### 6.2 Row Support Enumeration

**Input:** Network N of size n, state x.
**Output:** The set {y | K_N(x,y) ≠ 0} with corresponding weights.

```
function RowSupport(N, x):
    support ← empty map
    for i ← 0 to n-1:
        y ← F[i](x)
        support[y] ← support[y] + w[i]
    return {(y, v) ∈ support | v ≠ 0}
```

**Complexity:** O(n) action evaluations, O(n) map operations.

### 6.3 Network Combination

**Input:** Networks N₁ of size n₁, N₂ of size n₂.
**Output:** Network N of size n₁ + n₂ whose kernel equals K_{N₁} + K_{N₂}.

```
function CombineNetworks(N₁, N₂):
    N ← new Network of size n₁ + n₂
    for i ← 0 to n₁-1:
        N.action[i] ← N₁.action[i]
        N.weight[i] ← N₁.weight[i]
    for i ← 0 to n₂-1:
        N.action[n₁ + i] ← N₂.action[i]
        N.weight[n₁ + i] ← N₂.weight[i]
    return N
```

**Complexity:** O(n₁ + n₂).

---

## 7. Computational Experiments

We implemented the Berggren tree and correspondence network framework in Python to validate the theoretical results computationally.

### 7.1 Tree Generation

Starting from (3, 4, 5), we generated the first 5 levels of the Berggren tree (1 + 3 + 9 + 27 + 81 = 121 triples). All generated triples were verified to satisfy a² + b² = c² and gcd(a,b) = 1.

### 7.2 Network Examples

We constructed several example networks:
- **Identity network** (1 generator): F(t) = t, w = 1. Kernel is the identity matrix.
- **Child A network** (1 generator): F(t) = childA(t), w = 1. Kernel encodes parent-child relationships in the A branch.
- **Full child network** (3 generators): Three generators for children A, B, C with equal weights. Kernel K(x,y) = 1 iff y is a child of x.
- **Two-step network** (9 generators): All compositions of two Berggren generators, encoding grandparent-grandchild relationships.

### 7.3 Minimality Verification

For the full child network (3 generators), we verified computationally that no network of size 2 produces the same kernel on the first 3 levels of the tree. This confirms that 3 is the minimal realization size for this kernel.

---

## 8. Discussion

### 8.1 Significance

The realization–minimality duality provides a new lens for studying arithmetic correspondences. Rather than viewing Pythagorean triples as static solutions, we treat them as states in a dynamical system. The correspondence kernel is the transition operator, and the realization theorem decomposes it into elementary building blocks (Berggren generators with weights).

### 8.2 Connection to Automata Theory

Our framework is a Diophantine analogue of the theory of recognizable formal power series. In the classical setting (Schützenberger, Fliess), a formal power series S : Σ* → R over a free monoid Σ* is recognizable iff its Hankel matrix has finite rank, and minimal recognizers are unique. Our Berggren realization duality adapts this paradigm: the "alphabet" is {A, B, C}, "words" are paths in the Berggren tree, and "recognizable series" are finitely realizable correspondence kernels.

### 8.3 Limitations

The current framework has several limitations that suggest directions for future work:
1. We do not prove the converse of Theorem 4.6 (finite observable rank implies finite realization) in full generality; this requires additional assumptions on the template decomposition.
2. The uniqueness result (Theorem 4.2) applies to realization *size* but not to realization *structure*; we do not prove that minimal realizations are unique up to isomorphism in general.
3. The Berggren-specific results do not yet include a proof that the Berggren tree generates all primitive triples; this classical theorem would complete the connection to the full Diophantine family.

---

## 9. Future Work

See FUTURE_DIRECTIONS.md for a detailed roadmap. The most promising immediate directions are:
1. Extending the framework to other Diophantine trees (Markov, Apollonian).
2. Developing tropical spectral theory for correspondence kernels.
3. Establishing computational hardness results for partial reconstruction.

---

## References

[1] B. Berggren, "Pytagoreiska trianglar," *Tidskrift för Elementär Matematik, Fysik och Kemi* 17 (1934), 129–139.

[2] A. Hall, "Genealogy of Pythagorean triads," *The Mathematical Gazette* 54 (1970), 377–379.

[3] H. L. Price, "The Pythagorean tree: A new species," arXiv:0809.4324 (2008).

[4] D. Romik, "The dynamics of Pythagorean triples," *Transactions of the AMS* 360 (2008), 6045–6064.

[5] M.-P. Schützenberger, "On the definition of a family of automata," *Information and Control* 4 (1961), 245–270.

[6] S. Eilenberg, *Automata, Languages, and Machines, Vol. A*, Academic Press, 1974.

[7] J. Berstel and C. Reutenauer, *Noncommutative Rational Series with Applications*, Cambridge University Press, 2011.

[8] M. Fliess, "Matrices de Hankel," *Journal de Mathématiques Pures et Appliquées* 53 (1974), 197–222.

[9] R. Alperin, "The modular tree of Pythagoras," *The American Mathematical Monthly* 112 (2005), 807–816.

[10] D. Romik, "Pythagorean triples and the Lorentz group," preprint, 2015.

[11] T. Hales et al., "A formal proof of the Kepler conjecture," *Forum of Mathematics, Pi* 5 (2017).

[12] G. Gonthier et al., "A machine-checked proof of the odd order theorem," *ITP 2013*, Springer LNCS 7998.

[13] Various, Mathlib4 documentation, https://leanprover-community.github.io/mathlib4_docs/.
