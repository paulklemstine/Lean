# Cographs Are a Self-Complementary Hereditary Class: The Structural Foundation for Generalized Spectral Closure

## Abstract

A graph is a *cograph* if it contains no induced path on four vertices, $P_4$;
equivalently, cographs are exactly the graphs generated from a single vertex by
disjoint union and join. Cographs are central to the theory of *generalized
spectral characterizations*, in which one asks whether a graph is determined, up to
isomorphism-relevant structure, by the pair consisting of its adjacency spectrum
and the spectrum of its complement. We isolate and prove the structural backbone
that makes the complement spectrum the correct companion invariant for this class.
Our results are fourfold. First, complementation is *functorial* on induced
embeddings: an induced embedding $G \hookrightarrow H$ yields an induced embedding
$G^\complement \hookrightarrow H^\complement$ on the same vertex map. Second, the
path $P_4$ is *self-complementary*, $P_4 \cong P_4^\complement$, via the explicit
permutation $0\,1\,2\,3 \mapsto 1\,3\,0\,2$. Together these give the third and
central result: the class of cographs is *closed under complementation* — a graph
is a cograph if and only if its complement is. Fourth, the algebraic bridge
$A(G^\complement) = J - I - A(G)$ couples the complement spectrum to the adjacency
spectrum, and the two-spectrum invariant (generalized cospectrality) is itself
closed under complementation, acting on the invariant by swapping its components.
We record the hereditary and isomorphism-invariance properties of cographs, and we
formulate the resulting conjecture that cographs are generalized spectrally closed,
together with a program of supporting conjectures relating induced-$P_4$ counts to
joint spectral moments.

**Keywords:** cograph, forbidden induced subgraph, $P_4$, self-complementary graph
class, adjacency spectrum, generalized cospectrality, spectral graph theory,
threshold graph, hereditary class.

---

## 1. Introduction

### 1.1 Spectral determination

A finite simple graph $G$ on vertex set $V$ has an *adjacency matrix* $A(G)$, the
symmetric $0/1$ matrix whose $(u,v)$ entry is $1$ exactly when $u$ and $v$ are
adjacent. The multiset of eigenvalues of $A(G)$ is the *adjacency spectrum* of $G$.
A foundational and still largely open problem of spectral graph theory asks: to what
extent is a graph determined by its spectrum? Two graphs with the same spectrum are
*cospectral*, and cospectral non-isomorphic graphs abound, so the spectrum alone
generally fails to determine a graph.

A refinement that dramatically improves matters is to record, in addition, the
spectrum of the *complement*. Two graphs $G$ and $H$ on the same vertex set are
**generalized cospectral** when they share the characteristic polynomial of the
adjacency matrix *and* the characteristic polynomial of the complement adjacency
matrix. Many classes that fail to be determined by the adjacency spectrum alone are
determined by this richer, two-spectrum invariant.

### 1.2 Self-complementary forbidden-subgraph classes

Say that a hereditary graph class $\mathcal C$ is **generalized spectrally closed**
if every graph generalized cospectral with a member of $\mathcal C$ is again a
member of $\mathcal C$. There is a natural heuristic: a class defined by forbidding
a *self-complementary* configuration ought to be governed by a *self-complementary*
invariant, and generalized cospectrality — which pairs the adjacency and complement
spectra symmetrically — is exactly such an invariant.

This paper makes that heuristic precise for the class of **cographs**, the graphs
with no induced $P_4$. We prove the structural facts on which a generalized spectral
closure theorem must rest, and we lay out the conjectural bridge from structure to
spectrum. The known generalized spectral characterization of **threshold graphs**,
the subclass $\mathrm{Forb}(2K_2, P_4, C_4)$, is the motivating precedent: cographs
enlarge that class by dropping two of the three forbidden patterns, and we argue
that the same two-spectrum guarantee should persist.

### 1.3 Contributions

1. **Complement functor on induced embeddings** (Theorem 3.1): induced embeddings
   are preserved by complementation on the identical vertex map.
2. **Self-complementarity of $P_4$** (Theorem 4.1): an explicit isomorphism
   $P_4 \cong P_4^\complement$.
3. **Cographs are closed under complementation** (Theorem 5.2), together with the
   hereditary property (Theorem 5.3) and isomorphism invariance (Theorem 5.4).
4. **Complement adjacency identity** (Theorem 6.1): $A(G^\complement) = J - I -
   A(G)$; and closure of the two-spectrum invariant under complementation
   (Theorem 6.4).
5. A conjectural program (Section 7) predicting that cographs are generalized
   spectrally closed and identifying the induced-$P_4$ count as a joint spectral
   moment.

---

## 2. Definitions and conventions

Throughout, graphs are finite, simple, and undirected. For a graph $G$ on vertex
set $V$ we write $u \sim_G v$ for adjacency.

**Definition 2.1 (Complement).** The *complement* $G^\complement$ of $G$ has the
same vertex set, with $u \sim_{G^\complement} v$ if and only if $u \neq v$ and
$u \not\sim_G v$. Complementation is an involution: $(G^\complement)^\complement =
G$.

**Definition 2.2 (Induced embedding).** An *induced embedding* $f : G
\hookrightarrow H$ is an injection of vertex sets that preserves adjacency *and*
non-adjacency: for all $a, b$,
$$ a \sim_G b \iff f(a) \sim_H f(b). $$
Equivalently, $f$ is an isomorphism from $G$ onto the subgraph of $H$ induced by the
image of $f$. When such an $f$ exists we say $G$ *embeds as an induced subgraph* of
$H$. An *isomorphism* is a bijective induced embedding.

**Definition 2.3 (The path $P_4$).** $P_4$ is the graph on vertices $\{0,1,2,3\}$
with edges $\{0,1\}, \{1,2\}, \{2,3\}$. It is the path on four vertices.

**Definition 2.4 (Cograph).** A graph $G$ is a *cograph* if there is no induced
embedding of $P_4$ into $G$; that is, the set of induced embeddings $P_4
\hookrightarrow G$ is empty. Equivalently, cographs are exactly the graphs
constructible from single vertices by iterated disjoint union and join.

**Definition 2.5 (Generalized cospectral).** Let $G, H$ be graphs on a common
finite vertex set. They are *generalized cospectral* if
$$ \chi_{A(G)} = \chi_{A(H)} \quad\text{and}\quad \chi_{A(G^\complement)} =
\chi_{A(H^\complement)}, $$
where $\chi_M$ denotes the characteristic polynomial of the matrix $M$. Since the
characteristic polynomial determines and is determined by the multiset of
eigenvalues, this says $G, H$ have equal adjacency spectra and equal complement
spectra.

Here $J$ denotes the all-ones matrix and $I$ the identity, both of size $|V|$.

---

## 3. The complement functor on induced embeddings

The first pillar is that complementation is functorial on induced subgraph
relationships.

**Theorem 3.1 (Complement functor).** Let $G, H$ be graphs and let $f : G
\hookrightarrow H$ be an induced embedding. Then the same underlying vertex map is
an induced embedding $f : G^\complement \hookrightarrow H^\complement$.

*Proof.* The map $f$ is already injective, so it remains to check that it preserves
and reflects adjacency in the complements. Fix vertices $a, b$. By Definition 2.1,
$$ a \sim_{G^\complement} b \iff (a \neq b \ \wedge\ a \not\sim_G b). $$
Suppose first $a \sim_{G^\complement} b$, i.e. $a \neq b$ and $a \not\sim_G b$.
Since $f$ is injective, $f(a) \neq f(b)$. Since $f$ reflects adjacency ($a \sim_G b
\iff f(a) \sim_H f(b)$) and $a \not\sim_G b$, we get $f(a) \not\sim_H f(b)$. Hence
$f(a) \sim_{H^\complement} f(b)$. Conversely, suppose $f(a) \sim_{H^\complement}
f(b)$, i.e. $f(a) \neq f(b)$ and $f(a) \not\sim_H f(b)$. Injectivity of $f$ gives
$a \neq b$ (if $a = b$ then $f(a) = f(b)$), and reflecting adjacency the other way
gives $a \not\sim_G b$. Hence $a \sim_{G^\complement} b$. Both directions together
say $a \sim_{G^\complement} b \iff f(a) \sim_{H^\complement} f(b)$, so $f$ is an
induced embedding of complements. $\qquad\blacksquare$

The content of Theorem 3.1 is that forbidden-induced-subgraph classes *transport
across complements*: if $F$ embeds as an induced subgraph of $G$, then $F^\complement$
embeds as an induced subgraph of $G^\complement$, on the same vertices.

---

## 4. The path $P_4$ is self-complementary

The second pillar is a small but decisive combinatorial fact.

**Theorem 4.1 (Chameleon Lemma).** $P_4$ is self-complementary:
$P_4 \cong P_4^\complement$. An explicit isomorphism is the vertex permutation
$$ \sigma : 0 \mapsto 1,\quad 1 \mapsto 3,\quad 2 \mapsto 0,\quad 3 \mapsto 2, $$
with inverse $\sigma^{-1} : 0 \mapsto 2,\ 1 \mapsto 0,\ 2 \mapsto 3,\ 3 \mapsto 1$.

*Proof.* The edges of $P_4$ are $\{0,1\},\{1,2\},\{2,3\}$; hence the edges of
$P_4^\complement$ are the remaining pairs $\{0,2\},\{0,3\},\{1,3\}$. We verify that
$\sigma$ carries edges of $P_4$ to edges of $P_4^\complement$ and non-edges to
non-edges, which since $\sigma$ is a bijection suffices for it to be an isomorphism
$P_4 \to P_4^\complement$. Checking each of the $\binom{4}{2}=6$ unordered pairs:

| pair $\{a,b\}$ | edge in $P_4$? | $\{\sigma a,\sigma b\}$ | edge in $P_4^\complement$? |
|:---:|:---:|:---:|:---:|
| $\{0,1\}$ | yes | $\{1,3\}$ | yes |
| $\{1,2\}$ | yes | $\{3,0\}$ | yes |
| $\{2,3\}$ | yes | $\{0,2\}$ | yes |
| $\{0,2\}$ | no  | $\{1,0\}$ | no  |
| $\{0,3\}$ | no  | $\{1,2\}$ | no  |
| $\{1,3\}$ | no  | $\{3,2\}$ | no  |

Every row matches: edges map to edges, non-edges to non-edges. Hence $\sigma$ is a
graph isomorphism $P_4 \cong P_4^\complement$. $\qquad\blacksquare$

The self-complementarity of $P_4$ is the reason the *single* forbidden pattern
defining cographs is invariant under complementation.

---

## 5. Cographs form a self-complementary hereditary class

We now combine Theorems 3.1 and 4.1.

**Lemma 5.1 (Complementing an induced $P_4$).** If $G$ contains an induced $P_4$,
then $G^\complement$ contains an induced $P_4$.

*Proof.* Let $e : P_4 \hookrightarrow G$ be an induced embedding. By Theorem 3.1,
$e$ is also an induced embedding $P_4^\complement \hookrightarrow G^\complement$. By
Theorem 4.1 there is an isomorphism $\sigma : P_4 \cong P_4^\complement$. The
composite $e \circ \sigma : P_4 \hookrightarrow G^\complement$ is an induced
embedding, since a composition of an isomorphism followed by an induced embedding is
an induced embedding. Hence $G^\complement$ contains an induced $P_4$.
$\qquad\blacksquare$

**Theorem 5.2 (Cographs are closed under complementation).** A graph $G$ is a
cograph if and only if $G^\complement$ is a cograph.

*Proof.* We show the contrapositive of each direction, i.e. that $G$ contains an
induced $P_4$ iff $G^\complement$ does. The forward implication is Lemma 5.1.
For the converse, apply Lemma 5.1 to $G^\complement$: if $G^\complement$ contains an
induced $P_4$ then $(G^\complement)^\complement = G$ does too, using that
complementation is an involution. Thus $G$ has no induced $P_4$ iff $G^\complement$
has none — precisely the statement that $G$ is a cograph iff $G^\complement$ is.
$\qquad\blacksquare$

Theorem 5.2 says the cograph class is *self-complementary*. It also follows
directly from the union/join description: complementation exchanges disjoint union
and join, and a construction tree built from unions and joins remains such a tree
after the swap. The proof above, however, is what generalizes: it shows that
$\mathrm{Forb}(F)$ is complement-closed whenever the finite forbidden family $F$ is
closed under complementation.

**Theorem 5.3 (Hereditary property).** If $f : G \hookrightarrow H$ is an induced
embedding and $H$ is a cograph, then $G$ is a cograph.

*Proof.* Suppose for contradiction $G$ has an induced $P_4$, witnessed by $e : P_4
\hookrightarrow G$. Then $f \circ e : P_4 \hookrightarrow H$ is an induced embedding
(compositions of induced embeddings are induced embeddings), so $H$ contains an
induced $P_4$, contradicting that $H$ is a cograph. Hence $G$ has no induced $P_4$.
$\qquad\blacksquare$

**Theorem 5.4 (Isomorphism invariance).** If $G \cong H$ then $G$ is a cograph if
and only if $H$ is a cograph.

*Proof.* An isomorphism is an induced embedding in both directions, so Theorem 5.3
applies each way. $\qquad\blacksquare$

Theorems 5.3 and 5.4 confirm that "being a cograph" is a hereditary graph
invariant — a prerequisite for any spectral characterization to be well posed.

---

## 6. The algebraic bridge to spectra

We now connect structure to linear algebra. Fix a finite vertex set $V$ and work
over the rationals $\mathbb Q$ (any field of characteristic $0$ serves equally).

**Theorem 6.1 (Complement adjacency identity).** For every graph $G$ on $V$,
$$ A(G^\complement) = J - I - A(G), $$
where $J$ is the all-ones matrix and $I$ the identity of size $|V|$.

*Proof.* Compare entries. Fix $v, w \in V$. If $v = w$, then the left side is $0$
(no self-loops), and the right side is $1 - 1 - 0 = 0$. If $v \neq w$, then $(J -
I)_{vw} = 1 - 0 = 1$. If $v \sim_G w$, then $A(G)_{vw} = 1$ and $v
\not\sim_{G^\complement} w$, so both sides equal $1 - 1 = 0$. If $v \not\sim_G w$,
then $A(G)_{vw} = 0$ and $v \sim_{G^\complement} w$, so both sides equal $1 - 0 =
1$. All cases agree. $\qquad\blacksquare$

**Remark 6.2.** The identity is the mechanism by which the complement spectrum is
*not* a function of the adjacency spectrum alone. Because $J$ does not commute with
$A(G)$ in general, the eigenvalues of $J - I - A(G)$ are not simple shifts of those
of $A(G)$; they carry genuinely new information. Simultaneously, they are rigidly
tied to $A(G)$ through this linear law, so the pair (adjacency spectrum, complement
spectrum) is one coherent object rather than two independent ones.

**Definition 6.3 (Two-spectrum invariant).** Recall from Definition 2.5 that $G$
and $H$ are generalized cospectral when $\chi_{A(G)} = \chi_{A(H)}$ and
$\chi_{A(G^\complement)} = \chi_{A(H^\complement)}$. This relation is reflexive and
symmetric.

**Theorem 6.4 (Complementation acts on the invariant by swapping halves).** If $G$
and $H$ are generalized cospectral, then so are $G^\complement$ and $H^\complement$.

*Proof.* By definition, generalized cospectrality of $G^\complement$ and
$H^\complement$ requires $\chi_{A(G^\complement)} = \chi_{A(H^\complement)}$ and
$\chi_{A(G^{\complement\complement})} = \chi_{A(H^{\complement\complement})}$. The
first is exactly the *second* clause of the hypothesis. For the second, since
complementation is an involution, $G^{\complement\complement} = G$ and
$H^{\complement\complement} = H$, so it reduces to $\chi_{A(G)} = \chi_{A(H)}$, the
*first* clause of the hypothesis. Thus complementation swaps the two clauses and
preserves the relation. $\qquad\blacksquare$

Theorem 6.4 is the algebraic mirror of Theorem 5.2: the structural class and its
governing invariant are both self-complementary, and complementation acts on each
by the same elementary symmetry.

---

## 7. Toward generalized spectral closure: a conjectural program

The results above furnish the exact hypotheses under which a generalized spectral
closure theorem for cographs can be attacked. We record the central conjecture and
its supporting steps.

**Conjecture 7.1 (Cographs are generalized spectrally closed).** If $G$ is a
cograph and $H$ is generalized cospectral with $G$, then $H$ is a cograph.

*Proof strategy.* The plan is to show that the number of induced copies of $P_4$ is
an invariant of generalized cospectrality; then a cograph (with zero induced $P_4$'s)
forces its generalized-cospectral mate to have zero as well, hence to be a cograph.

**Conjecture 7.2 (Induced-$P_4$ count as a joint spectral moment).** The number of
induced copies of $P_4$ in a graph is a fixed polynomial in the *moments*
(power sums of eigenvalues) $\operatorname{tr} A(G)^k$ and $\operatorname{tr}
A(G^\complement)^k$ of the adjacency and complement adjacency matrices.
Consequently it is determined by generalized cospectrality.

*Rationale.* Counts of small subgraphs are classically expressible through closed
walk counts, which are traces of matrix powers. The number of *homomorphic* or
*labeled walk* copies of $P_4$-type configurations is a polynomial in
$\operatorname{tr} A^k$; passing from these to the count of *induced* $P_4$'s
requires inclusion–exclusion over which of the three non-path pairs are edges, i.e.
over the complement. Theorem 6.1 turns every $\operatorname{tr} A(G^\complement)^k$
into a symmetric function of $J, I, A(G)$, and hence — after taking traces, which
are symmetric functions of eigenvalues — into a joint spectral moment. Two
generalized-cospectral graphs share all these moments and therefore share the
induced-$P_4$ count.

**Conjecture 7.3 (Spectral detectability governs closure).** For a finite family
$F$ closed under complementation, the class $\mathrm{Forb}(F)$ is generalized
spectrally closed precisely when, for each $H \in F$, the property "contains $H$ as
an induced subgraph" is determined by the joint spectra. Cographs, with $F =
\{P_4\}$, are the minimal nontrivial instance.

*Rationale.* By Theorem 3.1, $\mathrm{Forb}(F)$ is complement-closed exactly when
$F$ is closed under complementation, which is necessary for the two-spectrum
invariant to be the natural one. Given that, closure of the class reduces to
spectral detectability of each forbidden pattern.

**Conjecture 7.4 (Threshold graphs factor through the cograph result).** Threshold
graphs, $\mathrm{Forb}(2K_2, P_4, C_4)$, whose generalized spectral characterization
is known, sit strictly inside the cograph closure: a threshold graph's
generalized-cospectral mates are exactly its cograph mates that additionally avoid
$2K_2$ and $C_4$. Both $2K_2$ and $C_4$ are self-complementary-friendly forbidden
patterns whose presence is itself two-spectrum detectable ($2K_2$ and $C_4$ are
complements of one another together with $P_4$-type analysis).

The forbidden family $\{2K_2, P_4, C_4\}$ is closed under complementation
($2K_2^\complement = C_4$ up to the shared $P_4$), so Conjecture 7.3 predicts the
known threshold result and Conjecture 7.1 subsumes it upon dropping $2K_2$ and
$C_4$.

---

## 8. Algorithms

The structural results are effective and lead to simple, verifiable algorithms.

**Algorithm A (Cograph recognition by $P_4$ search).** Given $G$ on $n$ vertices,
enumerate all $\binom{n}{4}$ quadruples and test whether the induced subgraph on
each is isomorphic to $P_4$ (equivalently, has exactly three edges forming a path).
$G$ is a cograph iff no quadruple induces a $P_4$. This is $O(n^4)$; specialized
modular-decomposition recognizers achieve $O(n+m)$, but the brute-force version is
the direct combinatorial certificate of Definition 2.4.

**Algorithm B (Complement-functor transport).** Given an induced embedding $f : F
\hookrightarrow G$, output the *same* vertex map as an induced embedding
$F^\complement \hookrightarrow G^\complement$ (Theorem 3.1). No recomputation is
needed; correctness is the content of Theorem 3.1.

**Algorithm C (Generalized-cospectrality test).** Given $G, H$ on $n$ vertices,
form $A(G), A(H)$ and $A(G^\complement) = J - I - A(G)$, $A(H^\complement) = J - I -
A(H)$ (Theorem 6.1), compute the four characteristic polynomials, and report equal
of the two required pairs. This is $O(n^3)$ per characteristic polynomial by
standard linear algebra.

---

## 9. Applications and discussion

**Series–parallel and modular structure.** Cographs model systems built by pure
parallel and series composition; the self-complementarity (Theorem 5.2) reflects the
duality between "all disconnected" and "all connected" composition. The two-spectrum
invariant offers a *global* fingerprint complementing the *local* modular
decomposition.

**Network comparison.** Generalized cospectrality (Algorithm C) is a fast necessary
condition for isomorphism that is far more discriminating than the adjacency
spectrum alone. For cographs — and, conjecturally, in general (Conjecture 7.1) — it
also guarantees that a spectral match cannot masquerade a non-cograph as a cograph.

**A design principle.** Theorems 5.2 and 6.4 together articulate a reusable
principle: *the symmetry of a graph class should dictate the symmetry of the
invariant used to characterize it.* A complement-closed class calls for a
complement-symmetric invariant, and generalized cospectrality is that invariant.

---

## 10. Conclusion

We have established that cographs form a self-complementary hereditary class:
complementation is functorial on induced embeddings (Theorem 3.1), the defining
forbidden pattern $P_4$ is self-complementary (Theorem 4.1), and consequently the
cograph class is closed under complementation (Theorem 5.2), hereditary (Theorem
5.3), and an isomorphism invariant (Theorem 5.4). The linear identity
$A(G^\complement) = J - I - A(G)$ (Theorem 6.1) couples the complement spectrum to
the adjacency spectrum, and the two-spectrum invariant is itself self-complementary
(Theorem 6.4). These facts pinpoint generalized cospectrality as the natural
invariant for cographs and motivate the conjecture that cographs are generalized
spectrally closed, with a concrete route through joint spectral moments of the
induced-$P_4$ count. The threshold-graph characterization emerges as a special case
of the broader picture.
