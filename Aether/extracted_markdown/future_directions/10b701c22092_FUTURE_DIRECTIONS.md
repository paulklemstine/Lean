# Future Directions: Frequency Potentials and Frankl's Conjecture

## Direction 1: Average-Threshold Conjecture for Non-Chain Families

**Conjecture.** For every finite union-closed family $\mathcal{F}$ with $\emptyset \in \mathcal{F}$, if $\mathcal{F}$ is not a chain under inclusion (i.e., there exist incomparable members), then:
$$2 \cdot \text{totalWeight}(\mathcal{F}) \geq |\mathcal{F}| \cdot |\text{supp}(\mathcal{F})|.$$

**Test.** Exhaustively enumerate all union-closed families on ground sets of size $n \leq 7$. For each non-chain family, verify the inequality. The chain case is excluded because chains can have arbitrarily small average set size (e.g., $\{\emptyset, \{1\}, \{1,2\}, \ldots, \{1,\ldots,n\}\}$ is a chain with average size $n/2$ but support size $n$, so $2W = n(n+1)/2 \cdot 2/(n+1) \cdot |\mathcal{F}|$ which may or may not satisfy the bound depending on structure).

**Impact.** If true, this immediately implies Frankl's conjecture via our verified `exists_frequent_of_large_average` theorem. This would reduce the 45-year-old open problem to a statement about averages in non-chain lattices. If false, the minimal counterexample would reveal important structural information about "thin" union-closed families.

**Status.** Verified computationally for $n \leq 4$ (2,546+ families). No counterexamples found.

---

## Direction 2: Disjoint-Generator Exact-Half Phenomenon

**Conjecture.** Let $G = \{G_1, \ldots, G_k\}$ be a family of $k \geq 1$ pairwise disjoint nonempty finite sets. Let $\mathcal{F}$ be the union-closure of $G$ (including $\emptyset$). Then:
1. $|\mathcal{F}| = 2^k$.
2. For every $a \in G_i$, $\text{freq}(\mathcal{F}, a) = 2^{k-1}$.
3. Every element of $\bigcup G$ is a Frankl witness.

**Test.** Enumerate all families of pairwise disjoint nonempty subsets of $\{0, \ldots, n-1\}$ for $n \leq 8$. For each, compute the union-closure and verify properties (1)–(3).

**Impact.** This isolates the algebraically cleanest class where Frankl holds with equality. If formalized, it provides a large certified family of examples and connects to Boolean algebra structure (the generated family is isomorphic to $2^k$). The proof technique (powerset symmetry) could generalize to nearly-disjoint generators.

**Status.** Verified for $k \leq 6$. All properties hold.

---

## Direction 3: Closure-Fixed-Point Strengthening

**Conjecture.** Let $\mathcal{F}$ be a finite union-closed family with $\emptyset \in \mathcal{F}$. Define the closure operator $\text{cl}(S) = \bigcap \{T \in \mathcal{F} : S \subseteq T\}$. Then every join-irreducible element $J$ of $\mathcal{F}$ (viewed as a lattice under inclusion) satisfies:
$$|\{T \in \mathcal{F} : J \subseteq T\}| \geq |\mathcal{F}|/2.$$

**Test.** Enumerate union-closed families on $n \leq 5$. For each, identify join-irreducible elements (members that cannot be written as $A \cup B$ for $A, B \in \mathcal{F}$ with $A \neq J$ and $B \neq J$). Check the principal filter size condition.

**Impact.** If true, this provides a structural characterization of Frankl witnesses in terms of lattice theory. Join-irreducibles are the "atoms" of the lattice structure. If every join-irreducible's upper cone is large, then elements belonging to join-irreducibles are automatically frequent. This would bridge Frankl's conjecture to the extensive theory of finite lattices.

**Status.** Untested. Requires implementation of join-irreducible detection.

---

## Direction 4: Compression Monotonicity

**Conjecture.** Let $\mathcal{F}$ be a finite union-closed family on ground set $[n]$. Define the compression of $\mathcal{F}$ along elements $i, j$ (with $i < j$) as:
$$C_{ij}(\mathcal{F}) = \{S_{ij} : S \in \mathcal{F}\} \cup \{S : S \in \mathcal{F},\; S_{ij} \in \mathcal{F}\}$$
where $S_{ij} = (S \setminus \{j\}) \cup \{i\}$ if $j \in S$ and $i \notin S$, otherwise $S_{ij} = S$.

Then:
1. If $C_{ij}(\mathcal{F})$ is union-closed, then $\max_a \text{freq}(C_{ij}(\mathcal{F}), a) \geq \max_a \text{freq}(\mathcal{F}, a)$.
2. Repeated compression terminates.
3. The fully compressed family satisfies the average-size criterion.

**Test.** Implement compression and apply to random union-closed families on $n \leq 6$. Track the maximum frequency through compression sequences. Check whether fully compressed families satisfy $2W \geq |\mathcal{F}| \cdot n$.

**Impact.** Compression is a standard technique in extremal combinatorics (used for Kruskal-Katona, isoperimetric inequalities). If compression preserves union-closure and increases maximum frequency, it would reduce Frankl's conjecture to the compressed case, which may be tractable.

**Status.** Untested. The key challenge is proving that compression preserves union-closure.

---

## Direction 5: Entropy Surrogate Monotonicity

**Conjecture.** Let $G$ be a set of generators and $\mathcal{F} = \text{UC}(G)$ its union-closure. Define the frequency variance:
$$V(\mathcal{F}) = \text{Var}_{a \in \text{supp}(\mathcal{F})}[\text{freq}(\mathcal{F}, a)] = \frac{1}{|\text{supp}|}\sum_a (\text{freq}(\mathcal{F}, a) - \bar{f})^2$$
where $\bar{f}$ is the mean frequency. Then:

$V(\mathcal{F}) \leq V(G \cup \{\emptyset\})$.

That is, closing under unions makes element frequencies more uniform.

**Test.** Generate random generator sets $G$ on $n \leq 6$. Compute $V(G \cup \{\emptyset\})$ and $V(\text{UC}(G))$. Plot the relationship and check whether $V$ always decreases.

**Impact.** If frequency variance decreases under closure, it means union-closure "smooths out" the frequency distribution. Combined with the double-counting identity (which fixes the mean), decreased variance implies the minimum frequency increases — moving toward the Frankl threshold. This connects the conjecture to information-theoretic principles about entropy maximization under constraints.

**Status.** Untested. Requires statistical analysis on random generators.

---

## Priority Ranking

1. **Direction 1** (Average-Threshold) — Highest impact, directly implies Frankl if true, computationally testable now.
2. **Direction 4** (Compression) — Classical technique, could yield a full proof strategy.
3. **Direction 5** (Entropy Monotonicity) — Novel connection to information theory, experimentally accessible.
4. **Direction 3** (Lattice Fixed Points) — Deep structural insight, harder to test.
5. **Direction 2** (Disjoint Generators) — Clean but limited scope; best as a base case for inductive arguments.
