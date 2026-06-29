# Dependent Ultraproducts: Formalized Construction and Transfer Theorems

## Abstract

We present a formal development of the dependent ultraproduct construction in Lean 4, establishing the foundational infrastructure for transferring algebraic properties across families of structures indexed by an ultrafilter. Our main results include: (1) the ultrafilter pigeonhole principle and finite image resolution theorem, proved by Finset induction; (2) Boolean transfer lemmas for conjunction, disjunction, and negation; (3) the characteristic zero transfer theorem, which shows that ultraproducts of fields with varying characteristics have characteristic zero; (4) well-definedness of ring operations on ultraproduct equivalence classes; (5) the integral domain transfer theorem; and (6) an inductive bounded quantifier transfer theorem that forms the basis for Łoś's theorem. All proofs are machine-verified with no axioms beyond the standard Lean 4 foundation.

**Keywords**: ultraproduct, ultrafilter, transfer principle, characteristic zero, Łoś theorem, formal verification

## 1. Introduction

The ultraproduct construction, introduced implicitly by Skolem (1934) and systematically developed by Łoś (1955), is one of the most powerful tools in model theory. Given a family of structures $(K_i)_{i \in I}$ and an ultrafilter $\mathcal{U}$ on the index set $I$, the ultraproduct $\prod_{\mathcal{U}} K_i$ is the quotient of the direct product $\prod_{i \in I} K_i$ by the equivalence relation of agreement on a $\mathcal{U}$-large set.

The power of this construction lies in Łoś's fundamental theorem: a first-order sentence holds in the ultraproduct if and only if the set of indices where it holds belongs to the ultrafilter. This enables the transfer of properties from components to the quotient, connecting finite structures to infinite ones and local properties to global ones.

### 1.1. Contributions

This paper presents:

1. **Formal definitions**: The ultraproduct setoid, quotient type, and diagonal embedding, formalized in Lean 4 with full type-theoretic rigor.

2. **Ultrafilter combinatorics**: The pigeonhole principle, complement characterization, and Boolean transfer lemmas — the combinatorial engine of all transfer results.

3. **Finite image resolution**: A theorem proved by structural induction on finite sets, showing that any finitely-valued function has a unique $\mathcal{U}$-selected value.

4. **Characteristic transfer**: The finitary characteristic zero theorem, which shows that if characteristics of component fields vary (no single prime is $\mathcal{U}$-selected), then the ultraproduct has characteristic zero.

5. **Ring operation well-definedness**: Proofs that pointwise addition, multiplication, and negation respect ultrafilter equivalence.

6. **Integral domain transfer**: The zero-product property transfers through ultraproducts of integral domains.

7. **Inductive transfer theorems**: Conjunction transfer (by structural induction on lists) and bounded universal transfer (by induction on ℕ), forming the foundation for the full Łoś theorem.

8. **Compactness bridge**: The finite compactness principle, connecting ultrafilter transfer to the compactness theorem of first-order logic.

## 2. Definitions

### 2.1. Ultrafilter Equivalence

**Definition 1** (Ultrafilter Equivalence). Let $\mathcal{U}$ be an ultrafilter on a set $I$, and let $(K_i)_{i \in I}$ be a family of types. For $f, g \in \prod_{i \in I} K_i$, we define:
$$f \sim_{\mathcal{U}} g \iff \{i \in I : f(i) = g(i)\} \in \mathcal{U}$$

**Theorem 1** (Equivalence Relation). $\sim_{\mathcal{U}}$ is an equivalence relation.

*Proof sketch.* Reflexivity: $\{i : f(i) = f(i)\} = I \in \mathcal{U}$. Symmetry: $\{i : f(i) = g(i)\} = \{i : g(i) = f(i)\}$. Transitivity: $\{i : f(i) = g(i)\} \cap \{i : g(i) = h(i)\} \subseteq \{i : f(i) = h(i)\}$, and ultrafilters are closed under intersection and supersets. □

### 2.2. The Ultraproduct

**Definition 2** (Ultraproduct). The dependent ultraproduct is:
$$\prod_{\mathcal{U}} K_i := \left(\prod_{i \in I} K_i\right) / \sim_{\mathcal{U}}$$

### 2.3. Cofinitely Varying Characteristic

**Definition 3**. A function $\text{char\_of} : I \to \mathbb{N}$ has **cofinitely varying characteristic** relative to $\mathcal{U}$ if for every prime $p$, $\{i : \text{char\_of}(i) = p\} \notin \mathcal{U}$.

### 2.4. Ultrafilter Ramsey AP (Conjecture)

**Definition 4**. An ultrafilter $\mathcal{U}$ on $\mathbb{N}$ satisfies the **Ramsey AP property** if for every 2-coloring $c : \mathbb{N} \to \{0, 1\}$, there exists a color such that the $\mathcal{U}$-selected color class contains arbitrarily long arithmetic progressions.

## 3. Main Results

### 3.1. Ultrafilter Pigeonhole Principle

**Theorem 2** (Pigeonhole). If $I = \bigcup_{k < n} S_k$ and $\bigcup_k S_k \in \mathcal{U}$, then $\exists k, S_k \in \mathcal{U}$.

*Proof.* This follows from the finite biUnion membership characterization of ultrafilters: $\bigcup_{k \in F} S_k \in \mathcal{U} \iff \exists k \in F, S_k \in \mathcal{U}$ for finite $F$. In Lean, we convert to `Set.biUnion_univ` and apply `Ultrafilter.finite_biUnion_mem_iff`. □

### 3.2. Boolean Transfer

**Theorem 3** (Conjunction Transfer). If $\{i : P(i)\} \in \mathcal{U}$ and $\{i : Q(i)\} \in \mathcal{U}$, then $\{i : P(i) \land Q(i)\} \in \mathcal{U}$.

**Theorem 4** (Disjunction Transfer). If $\{i : P(i) \lor Q(i)\} \in \mathcal{U}$, then $\{i : P(i)\} \in \mathcal{U}$ or $\{i : Q(i)\} \in \mathcal{U}$.

*Proof.* Conjunction: use closure under intersection and superset. Disjunction: the key is `Ultrafilter.union_mem_iff`, which encodes the prime ideal property of ultrafilters — the set $\{i : P(i) \lor Q(i)\} \subseteq \{i : P(i)\} \cup \{i : Q(i)\}$, and a union is in $\mathcal{U}$ iff at least one member is. □

### 3.3. Finite Image Resolution

**Theorem 5** (Finite Image Resolution). If $f : I \to \alpha$ and $S$ is a finite set with $\{i : f(i) \in S\} \in \mathcal{U}$, then $\exists a \in S, \{i : f(i) = a\} \in \mathcal{U}$.

*Proof.* By induction on $S$ using `Finset.induction_on`. The base case is vacuous (the empty set is not in any ultrafilter). The inductive step decomposes $\{i : f(i) \in S \cup \{b\}\} \subseteq \{i : f(i) = b\} \cup \{i : f(i) \in S\}$ and applies `Ultrafilter.union_mem_iff`. □

**Theorem 6** (Unique Value Determination). For $f : I \to \text{Fin}(n)$ with $n > 0$, there exists a unique $k$ with $\{i : f(i) = k\} \in \mathcal{U}$.

*Proof.* Existence follows from Theorem 5 with $S = \text{Fin}(n)$. Uniqueness: if $k \neq k'$ both had their preimages in $\mathcal{U}$, then $\{i : f(i) = k\} \cap \{i : f(i) = k'\} = \emptyset \in \mathcal{U}$, contradicting the proper filter property. □

### 3.4. Characteristic Zero Transfer

**Theorem 7** (Characteristic Zero Transfer, Finitary). Let $\text{char\_of} : I \to \mathbb{N}$, and let $P$ be a finite set of primes. If $\text{char\_of}(i) \in \{0\} \cup P$ for all $i$, and $\{i : \text{char\_of}(i) = p\} \notin \mathcal{U}$ for each $p \in P$, then $\{i : \text{char\_of}(i) = 0\} \in \mathcal{U}$.

*Proof.* By contradiction. If $\{i : \text{char\_of}(i) = 0\} \notin \mathcal{U}$, then since $I = \{i : \text{char\_of}(i) = 0\} \cup \bigcup_{p \in P} \{i : \text{char\_of}(i) = p\}$ and this union is in $\mathcal{U}$, by `Ultrafilter.union_mem_iff` the second component $\bigcup_{p \in P} \{i : \text{char\_of}(i) = p\}$ must be in $\mathcal{U}$. By `Ultrafilter.finite_biUnion_mem_iff`, some specific $p \in P$ has $\{i : \text{char\_of}(i) = p\} \in \mathcal{U}$, contradicting the hypothesis. □

**Theorem 8** (No Varying Primes). If all $\text{char\_of}(i) \in P$ (a finite set of primes) and no specific prime is $\mathcal{U}$-selected, then we reach a contradiction.

### 3.5. Ring Operation Well-definedness

**Theorem 9**. Pointwise addition, multiplication, and negation are well-defined on ultraproduct equivalence classes.

*Proof.* For addition: if $f_1 \sim g_1$ and $f_2 \sim g_2$, then on $\{i : f_1(i) = g_1(i)\} \cap \{i : f_2(i) = g_2(i)\} \in \mathcal{U}$, we have $f_1(i) + f_2(i) = g_1(i) + g_2(i)$. Similarly for multiplication and negation. □

### 3.6. Integral Domain Transfer

**Theorem 10** (Zero-Product Transfer). If each $K_i$ is an integral domain and $fg \sim 0$ in $\prod_{\mathcal{U}} K_i$, then $f \sim 0$ or $g \sim 0$.

*Proof.* On $\{i : f(i) \cdot g(i) = 0\} \in \mathcal{U}$, by the integral domain property, $f(i) = 0$ or $g(i) = 0$. This gives $\{i : f(i) = 0 \lor g(i) = 0\} \in \mathcal{U}$, and the disjunction transfer (Theorem 4) yields the result. □

### 3.7. Bounded Quantifier Transfer

**Theorem 11** (Bounded Universal Transfer). If for each $k < n$, $\{i : P(i, k)\} \in \mathcal{U}$, then $\{i : \forall k < n, P(i, k)\} \in \mathcal{U}$.

*Proof.* By induction on $n$. The base case is trivial. For the successor step, combine the inductive hypothesis ($\{i : \forall k < n, P(i,k)\} \in \mathcal{U}$) with the last case ($\{i : P(i, n)\} \in \mathcal{U}$) using intersection. □

### 3.8. Finite Compactness

**Theorem 12** (Finite Compactness). If each axiom in a finite list is satisfied by $w(i)$ on a $\mathcal{U}$-large set, then all axioms are simultaneously satisfied on a $\mathcal{U}$-large set.

*Proof.* Compose each axiom with the witness function to get predicates on $I$, apply the conjunction transfer (Theorem 3, generalized to lists), then uncompose. □

## 4. Algorithms

### 4.1. Ultrafilter Selection on Finite Index Sets

For a finite index set $I = \{1, \ldots, n\}$, any ultrafilter is principal (concentrating on a single element). The ultraproduct over a principal ultrafilter at index $i_0$ is simply $K_{i_0}$.

**Algorithm**: Given $f : I \to \alpha$ and a principal ultrafilter $\mathcal{U}_{i_0}$, the $\mathcal{U}$-selected value is $f(i_0)$.

### 4.2. Characteristic Transfer Computation

Given a finite list of primes $[p_1, \ldots, p_k]$ and an assignment $\text{char\_of} : \{1, \ldots, n\} \to \{0, p_1, \ldots, p_k\}$, for each principal ultrafilter $\mathcal{U}_j$, the transferred characteristic is $\text{char\_of}(j)$. The theorem asserts that non-principal ultrafilters (which don't exist on finite sets) would yield characteristic 0 if no prime dominates.

### 4.3. Bounded Quantifier Enumeration

To verify the bounded universal transfer for a specific $n$, enumerate all $(k, i)$ pairs with $k < n$, check $P(i, k)$, and intersect the resulting sets.

## 5. Discussion

### 5.1. Relationship to Ax's Theorem

Our characteristic zero transfer theorem (Theorem 7) is the algebraic core of Ax's theorem on the elementary theory of finite fields. Ax proved that the theory of all finite fields (the common first-order theory) coincides with the theory of pseudo-finite fields. The ultraproduct of all prime fields $\mathbb{F}_p$ (for $p$ ranging over all primes) is a pseudo-finite field of characteristic 0 — a field that is infinite but satisfies every first-order sentence true in all but finitely many finite fields.

### 5.2. Toward Full Łoś

Our bounded quantifier transfer (Theorem 11) handles the key inductive case for bounded universal quantifiers. The full Łoś theorem requires:
1. Atomic formula transfer (polynomial equality) — follows from ring operation well-definedness
2. Boolean connective transfer — established (Theorems 3, 4)
3. Quantifier transfer — requires showing that every element of the ultraproduct is represented, which needs the quotient structure

### 5.3. The Compactness Connection

The finite compactness principle (Theorem 12) is the finite fragment of the ultraproduct proof of the compactness theorem. In the full version, one takes witnesses satisfying larger and larger finite subsets of an axiom set, and forms the ultraproduct over a suitable index set and ultrafilter. Our finite version already captures the essential combinatorial content.

## 6. Future Work

1. **Full Łoś theorem**: Extend the transfer from bounded quantifiers to arbitrary first-order formulas.
2. **Field instance**: Construct the full `Field` instance on the ultraproduct when all components are fields.
3. **Pseudo-finite fields**: Formalize the theory of pseudo-finite fields and connect to finite field arithmetic.
4. **Non-standard analysis**: Use the ultrapower (ultraproduct of copies of ℝ) to formalize hyperreal numbers.
5. **Ultrafilter Ramsey conjecture**: Investigate the relationship between ultrafilter-selected sets and Szemerédi-type results.

## 7. References

1. Ax, J. "The elementary theory of finite fields." *Annals of Mathematics* 88 (1968): 239–271.
2. Chang, C.C. and Keisler, H.J. *Model Theory*. North-Holland, 3rd ed., 1990.
3. Łoś, J. "Quelques remarques, théorèmes et problèmes sur les classes définissables d'algèbres." *Mathematical Interpretation of Formal Systems*, North-Holland, 1955.
4. Szemerédi, E. "On sets of integers containing no k elements in arithmetic progression." *Acta Arithmetica* 27 (1975): 199–245.
5. Bell, J.L. and Slomson, A.B. *Models and Ultraproducts*. North-Holland, 1969.
6. Goldblatt, R. *Lectures on the Hyperreals*. Springer, 1998.
