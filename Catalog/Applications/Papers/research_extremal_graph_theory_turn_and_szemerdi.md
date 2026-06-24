# A Parity-Uniform Cubic Upper Bound for $\mathrm{ex}(n, K_{a,b}, K_{3,t})$, with Threshold Analysis and Downward Closure

**Author:** Aristotle

**Date:** 2026-06-24

---

## Abstract

We study the generalized (Alon–Shikhelman) Turán problem of counting copies of the complete bipartite graph $K_{a,b}$ inside graphs that forbid the smaller complete bipartite graph $K_{3,t}$. We prove an explicit cubic upper bound: for every $K_{3,t}$-free graph $G$ on $n$ vertices with $3\le a$, $3\le b$, the number of labelled copies of $K_{a,b}$ is at most $\binom{n}{3}\binom{t-1}{b}\binom{t-1}{a-3}$, hence $O(n^3)$. The argument is a Kővári–Sós–Turán-style double count anchored on a $3$-element core extracted from the $a$-side of each copy, using the equivalence between $K_{3,t}$-freeness and a uniform cap of $t-1$ on the common neighborhood of every triple. The bound holds *uniformly at the conjectured necessary threshold* $t = b+1$ for every parity of $b$; the parity subtlety in the literature lives entirely in the matching lower-bound construction. We complement the bound with an exact threshold analysis: for $b\ge 6$ the proved Janzer–Longbrake–Yepremyan threshold $2\max\{3,\lceil b/2\rceil\}+1$ equals $b+1+(b\bmod 2)$, so it coincides with the necessary threshold $b+1$ exactly when $b$ is even and exceeds it by one exactly when $b$ is odd. Finally, we establish *downward closure*: the cubic bound transfers verbatim, with the same constant, to every subgraph of a $K_{3,t}$-free graph, making the estimate robust under edge deletion. All results have been formally verified.

---

## 1. Introduction

### 1.1 The generalized Turán problem

Classical extremal graph theory, initiated by Turán, asks for the maximum number of edges in an $n$-vertex graph avoiding a fixed subgraph. The Alon–Shikhelman generalization replaces "number of edges" by "number of copies of a fixed pattern graph $H$": for graphs $H$ and $F$, one defines
$$\mathrm{ex}(n, H, F) = \max\{\, c_H(G) : |V(G)| = n,\ G \text{ is } F\text{-free}\,\},$$
where $c_H(G)$ is the number of (labelled) copies of $H$ in $G$. The classical case is $H = K_2$. Choosing $H$ to be a larger structure interrogates how the prohibition of $F$ constrains not just edges but rich substructures.

We focus on the bipartite-versus-bipartite instance $H = K_{a,b}$, $F = K_{3,t}$. The motivating fact (a theorem of Janzer, Longbrake, and Yepremyan) is that for $t$ above a suitable threshold,
$$\mathrm{ex}(n, K_{a,b}, K_{3,t}) = \Theta(n^3).$$
The exponent $3$ is dictated by the "$3$" of the forbidden $K_{3,t}$: the three vertices on the small side of the forbidden pattern are the only ones that may range freely, while all remaining vertices of a $K_{a,b}$-copy are forced into bounded common neighborhoods.

### 1.2 Contributions

This paper isolates and formally verifies three packaged contributions.

1. **The cubic upper bound** (Section 3). A self-contained, elementary proof that any $K_{3,t}$-free graph on $n$ vertices contains at most $\binom{n}{3}\binom{t-1}{b}\binom{t-1}{a-3}$ copies of $K_{a,b}$, valid at the necessary threshold $t=b+1$ for every parity of $b$. The headline statement is `KabCopies_cubic_of_K3tFree`.

2. **The threshold analysis** (Section 4). An exact arithmetic comparison of the proved threshold $2\max\{3,\lceil b/2\rceil\}+1$ and the necessary threshold $b+1$, showing the gap equals $b \bmod 2$ for $b\ge 6$ (`threshold_gap`), is nonzero iff $b$ is odd (`necessary_lt_paper_iff_odd`), and that the leading constant collapses to $\binom{b}{a-3}$ at the necessary threshold (`cubic_constant_at_threshold`).

3. **Downward closure** (Section 5). The cubic bound is monotone under the subgraph order: for $G\le G'$ with $G'$ being $K_{3,t}$-free, $G$ inherits the same cubic bound with the same constant (`KabCopies_cubic_of_subgraph`). This makes the estimate robust under deletion/cleaning operations.

All three are derived from a single quantitative principle: $K_{3,t}$-freeness is equivalent to a cap of $t-1$ on the common neighborhood of every triple of vertices.

---

## 2. Definitions

Throughout, $V$ is a finite vertex set with $|V| = n$, and $G$ is a simple graph on $V$ with adjacency relation $\sim$ (symmetric and irreflexive). For finite sets we write $|X|$ for cardinality and $\binom{m}{k}$ for the binomial coefficient (with the natural-number convention $\binom{m}{k}=0$ for $k>m$).

**Definition 2.1 (Common neighborhood).** For a set $S\subseteq V$, the *common neighborhood* is
$$N(S) = \{\, w\in V : \forall u\in S,\ u\sim w \,\}.$$
Membership $w\in N(S)$ means $w$ is adjacent to every vertex of $S$. (In the formalization, `cnbhd G S` is the filter of `univ` by this predicate, with `mem_cnbhd` recording the membership characterization.)

**Definition 2.2 (Copies of $K_{a,b}$).** A *labelled copy* of $K_{a,b}$ in $G$ is an ordered pair $(A,B)$ of disjoint subsets of $V$ with $|A|=a$, $|B|=b$, and every cross pair adjacent:
$$\forall u\in A,\ \forall v\in B,\ u\sim v.$$
The set of all such pairs is denoted $\mathrm{Copies}_{a,b}(G)$; its cardinality is the count $c_{K_{a,b}}(G)$. (Formally, `KabCopies G a b` is the corresponding `Finset (Finset V × Finset V)`, characterized by `mem_KabCopies`.)

**Definition 2.3 ($K_{3,t}$-freeness).** $G$ is *$K_{3,t}$-free* if no copy of $K_{3,t}$ exists:
$$\neg\,\exists\, A,B\subseteq V:\ |A|=3,\ |B|=t,\ A\cap B=\varnothing,\ \forall u\in A,\ \forall v\in B,\ u\sim v.$$
(Formally, `K3tFree G t`.)

**Definition 2.4 (Common-neighborhood bound).** $G$ satisfies the *common-neighborhood bound* at $t$ if every triple has at most $t-1$ common neighbors:
$$\forall S\subseteq V,\ |S|=3 \ \Rightarrow\ |N(S)| \le t-1.$$
(Formally, `CNbound G t`.)

**Definition 2.5 (Subgraph order).** For graphs $G, G'$ on $V$, write $G \le G'$ if every edge of $G$ is an edge of $G'$, i.e. $u\sim_G v \Rightarrow u\sim_{G'} v$. This is the standard partial order on simple graphs over a fixed vertex set.

**Definition 2.6 (Thresholds).** The *necessary threshold* is $\tau_{\mathrm{nec}}(b) = b+1$. The *proved threshold* (from the Janzer–Longbrake–Yepremyan lower-bound construction) is
$$\tau_{\mathrm{proved}}(b) = 2\max\{3,\lceil b/2\rceil\}+1, \qquad \lceil b/2\rceil = \left\lfloor \tfrac{b+1}{2}\right\rfloor.$$
(Formally, `necessaryThreshold` and `paperThreshold`.)

---

## 3. The cubic upper bound

### 3.1 Two structural lemmas on common neighborhoods

**Lemma 3.1 (Antitonicity).** If $S\subseteq T$ then $N(T)\subseteq N(S)$.

*Proof.* If $w\in N(T)$ then $w$ is adjacent to every vertex of $T\supseteq S$, hence to every vertex of $S$. $\square$ (Formally, `cnbhd_antitone`.)

**Lemma 3.2 (Freeness $\iff$ neighborhood cap).** For $t\ge 1$, $G$ is $K_{3,t}$-free if and only if $G$ satisfies the common-neighborhood bound at $t$:
$$\text{`K3tFree G t`} \iff \text{`CNbound G t`}.$$

*Proof.* ($\Rightarrow$) Suppose some triple $S$ had $|N(S)|\ge t$. Choose $B\subseteq N(S)$ with $|B|=t$. Then $S$ and $B$ are disjoint (any common element would be adjacent to itself, contradicting irreflexivity), and every $u\in S$ is adjacent to every $v\in B$ by definition of $N(S)$. This is a forbidden $K_{3,t}$. ($\Leftarrow$) Conversely, a copy $(A,B)$ of $K_{3,t}$ has $B\subseteq N(A)$ with $|A|=3$, so $|N(A)|\ge |B| = t > t-1$, violating the cap. $\square$ (Formally, `K3tFree_iff_CNbound`.)

**Lemma 3.3 (Cap extends to large sets).** If $G$ satisfies the common-neighborhood bound at $t$ and $|B|\ge 3$, then $|N(B)|\le t-1$.

*Proof.* Extract a triple $S\subseteq B$ with $|S|=3$. By antitonicity (Lemma 3.1), $N(B)\subseteq N(S)$, so $|N(B)|\le |N(S)| \le t-1$. $\square$ (Formally, `cnbhd_card_le`.)

### 3.2 The core fiber bound

The engine of the upper bound is a count of copies whose $a$-side contains a fixed triple.

**Lemma 3.4 (Fiber bound).** Suppose $G$ satisfies the common-neighborhood bound at $t$ and $3\le b$. For any fixed triple $S$ with $|S|=3$,
$$\#\{(A,B)\in\mathrm{Copies}_{a,b}(G) : S\subseteq A\}\ \le\ \binom{t-1}{b}\binom{t-1}{a-3}.$$

*Proof.* Consider a copy $(A,B)$ with $S\subseteq A$. Since every vertex of $B$ is adjacent to all of $A\supseteq S$, we have $B\subseteq N(S)$; by Lemma 3.3 (with $|S|=3$), $|N(S)|\le t-1$, so $B$ is one of at most $\binom{t-1}{b}$ subsets of $N(S)$. Likewise every vertex of $A\setminus S$ is adjacent to all of $B$, so $A\setminus S\subseteq N(B)$; since $|B|=b\ge 3$, Lemma 3.3 gives $|N(B)|\le t-1$, so $A\setminus S$ is one of at most $\binom{t-1}{a-3}$ subsets of size $a-3$.

Define the map $\Phi(A,B) = (A\setminus S,\, B)$ on the fiber. The target lands in
$$D = \bigcup_{B'\in \binom{N(S)}{b}}\ \left\{ (R, B') : R\in \binom{N(B')}{a-3} \right\},$$
and $\Phi$ is injective: from $(A\setminus S, B)$ we recover $A = (A\setminus S)\cup S$ (using $S\subseteq A$) and $B$ directly. Hence the fiber's size is at most $|D|$. By the union bound and $|\binom{X}{k}| = \binom{|X|}{k}$,
$$|D|\ \le\ \sum_{B'\in\binom{N(S)}{b}} \binom{|N(B')|}{a-3} \ \le\ \binom{|N(S)|}{b}\binom{t-1}{a-3}\ \le\ \binom{t-1}{b}\binom{t-1}{a-3},$$
where the last two steps use Lemma 3.3 monotonically through $\binom{\cdot}{k}$. $\square$ (Formally, `fiber_bound`.)

### 3.3 The double count

**Lemma 3.5 (Anchoring).** If $3\le a$, then every copy of $K_{a,b}$ is counted at least once across triples:
$$c_{K_{a,b}}(G)\ \le\ \sum_{|S|=3}\ \#\{(A,B)\in\mathrm{Copies}_{a,b}(G) : S\subseteq A\}.$$

*Proof.* For each copy $(A,B)$, the $a$-side has $\binom{a}{3}\ge 1$ triples (using $a\ge 3$). Writing $\mathbf{1}[S\subseteq A]$ and exchanging the order of summation,
$$c_{K_{a,b}}(G) = \sum_{(A,B)} 1 \le \sum_{(A,B)} \binom{|A|}{3} = \sum_{(A,B)} \sum_{|S|=3} \mathbf{1}[S\subseteq A] = \sum_{|S|=3} \#\{(A,B): S\subseteq A\}. \quad\square$$
(Formally, `KabCopies_card_le_sum`.)

**Theorem 3.6 (Main upper bound).** If $G$ satisfies the common-neighborhood bound at $t$ with $3\le a$ and $3\le b$, then
$$c_{K_{a,b}}(G)\ \le\ \binom{n}{3}\,\binom{t-1}{b}\binom{t-1}{a-3}.$$

*Proof.* Combine Lemma 3.5 with the fiber bound (Lemma 3.4) applied to each of the $\binom{n}{3}$ triples $S\subseteq V$:
$$c_{K_{a,b}}(G) \le \sum_{|S|=3} \binom{t-1}{b}\binom{t-1}{a-3} = \binom{n}{3}\binom{t-1}{b}\binom{t-1}{a-3}. \quad\square$$
(Formally, `KabCopies_card_le`.)

**Theorem 3.7 (Cubic bound for $K_{3,t}$-free graphs).** If $G$ is $K_{3,t}$-free with $3\le a$, $3\le b$, and $b+1\le t$, then
$$c_{K_{a,b}}(G)\ \le\ \binom{t-1}{b}\binom{t-1}{a-3}\cdot n^3 \ =\ O(n^3).$$

*Proof.* By Lemma 3.2, $K_{3,t}$-freeness gives the common-neighborhood bound at $t$ (the hypothesis $t\ge b+1\ge 1$ supplies the needed $t\ge 1$). Apply Theorem 3.6 and bound $\binom{n}{3}\le n^3$. $\square$ (Formally, `KabCopies_cubic_of_K3tFree`.)

**Remark 3.8 (Why the exponent is exactly $3$).** The proof exposes the source of the cubic growth: the anchor $S$ contributes the $\binom{n}{3}\le n^3$ factor, while *all* remaining $a+b-3$ vertices of a copy are confined to common neighborhoods of size $\le t-1$ and contribute only the constant $\binom{t-1}{b}\binom{t-1}{a-3}$. The exponent equals the size of the small side of the forbidden bipartite graph. Replacing $K_{3,t}$ by $K_{s,t}$ would replace the anchor by an $s$-set and yield $\Theta(n^s)$.

**Remark 3.9 (Role of the threshold hypothesis).** The hypothesis $t\ge b+1$ is *not used by the upper bound itself*: when $t-1 < b$ the factor $\binom{t-1}{b}$ simply vanishes, and the bound correctly reports zero (indeed $K_{a,b}$ then contains a forbidden $K_{3,t}$ and cannot appear). The threshold is retained in Theorem 3.7 because it is the regime in which a matching $\Omega(n^3)$ lower bound becomes possible, making the $O(n^3)$ statement sharp.

---

## 4. The threshold analysis

The Janzer–Longbrake–Yepremyan lower-bound construction achieves $\Theta(n^3)$ for $t\ge \tau_{\mathrm{proved}}(b) = 2\max\{3,\lceil b/2\rceil\}+1$. We compare this with the necessary threshold $\tau_{\mathrm{nec}}(b) = b+1$.

**Theorem 4.1 (Closed form).** For $b\ge 6$,
$$\tau_{\mathrm{proved}}(b) = b + 1 + (b \bmod 2).$$

*Proof.* For $b\ge 6$ we have $\lceil b/2\rceil = \lfloor (b+1)/2\rfloor \ge 3$, so the inner $\max\{3,\lceil b/2\rceil\}$ equals $\lceil b/2\rceil$. Then $2\lceil b/2\rceil = b$ when $b$ is even and $b+1$ when $b$ is odd; equivalently $2\lceil b/2\rceil = b + (b\bmod 2)$. Adding $1$ gives the claim. (Discharged in the formalization by linear arithmetic, `paperThreshold_eq`.) $\square$

**Corollary 4.2 (Even case).** For even $b\ge 6$, $\tau_{\mathrm{proved}}(b) = \tau_{\mathrm{nec}}(b) = b+1$. (`paperThreshold_even`.)

**Corollary 4.3 (Odd case).** For odd $b\ge 6$, $\tau_{\mathrm{proved}}(b) = \tau_{\mathrm{nec}}(b) + 1 = b+2$. (`paperThreshold_odd`.)

**Theorem 4.4 (Threshold gap).** For $b\ge 6$, the gap is exactly the parity bit:
$$\tau_{\mathrm{proved}}(b) - \tau_{\mathrm{nec}}(b) = b \bmod 2. \qquad (\text{`threshold\_gap`})$$

**Theorem 4.5 (The frontier is exactly the odd case).** For $b\ge 6$,
$$\tau_{\mathrm{nec}}(b) < \tau_{\mathrm{proved}}(b) \iff b \text{ is odd}.$$
*Proof.* Immediate from Theorem 4.4, since $b\bmod 2 > 0 \iff b$ is odd. (`necessary_lt_paper_iff_odd`.) $\square$

**Theorem 4.6 (Constant collapse at the necessary threshold).** At $t = \tau_{\mathrm{nec}}(b) = b+1$, the leading constant of Theorem 3.7 simplifies:
$$\binom{t-1}{b}\binom{t-1}{a-3}\ =\ \binom{b}{b}\binom{b}{a-3}\ =\ \binom{b}{a-3}.$$
*Proof.* With $t-1 = b$, $\binom{b}{b} = 1$. (`cubic_constant_at_threshold`.) $\square$

**Discussion.** The $b\ge 6$ guard is load-bearing: for small $b$ (e.g. $b\le 4$) the $\max$ clause dominates and the closed form of Theorem 4.1 fails. The upper bound of Section 3, in contrast, requires only $t\ge b+1$ and is *parity-blind* — it holds at the necessary threshold for every $b$. Thus the only obstruction to upgrading $O(n^3)$ to a sharp $\Theta(n^3)$ at the necessary threshold is the odd-$b$ off-by-one in the lower-bound construction; closing it is precisely the standing conjecture.

---

## 5. Downward closure

We now show the cubic bound is monotone under the subgraph order, making it robust to edge deletion ("cleaning") operations.

**Lemma 5.1 (Monotone common neighborhoods).** If $G\le G'$, then for every set $S$, $N_G(S)\subseteq N_{G'}(S)$.

*Proof.* If $w\in N_G(S)$ then $u\sim_G w$ for all $u\in S$; since $G\le G'$, $u\sim_{G'} w$ for all $u\in S$, so $w\in N_{G'}(S)$. $\square$ (Formally, `cnbhd_mono`.)

**Lemma 5.2 (Antitone freeness).** If $G\le G'$ and $G'$ is $K_{3,t}$-free, then $G$ is $K_{3,t}$-free.

*Proof.* A copy of $K_{3,t}$ in $G$ has all its cross edges in $G$, hence in $G'$ (since $G\le G'$), giving a copy of $K_{3,t}$ in $G'$ — impossible. So $G$ has none. $\square$ (Formally, `K3tFree_anti`.)

**Lemma 5.3 (Monotone neighborhood sizes).** If $G\le G'$, then $|N_G(S)|\le |N_{G'}(S)|$ for every $S$.

*Proof.* Immediate from Lemma 5.1 and monotonicity of cardinality under inclusion. $\square$ (Formally, `CNbound_anti`.)

**Theorem 5.4 (Downward closure of the cubic bound).** Let $G\le G'$ with $3\le a$, $3\le b$, $b+1\le t$, and $G'$ being $K_{3,t}$-free. Then
$$c_{K_{a,b}}(G)\ \le\ \binom{t-1}{b}\binom{t-1}{a-3}\cdot n^3,$$
the *same* cubic bound, with the *same* constant, as for $G'$.

*Proof.* By Lemma 5.2, $G$ is itself $K_{3,t}$-free. Apply Theorem 3.7 directly to $G$. $\square$ (Formally, `KabCopies_cubic_of_subgraph`, which invokes `K3tFree_anti` and then the black-box `KabCopies_cubic_of_K3tFree`.)

**Discussion.** Theorem 5.4 says the cubic estimate, once established for a dense $K_{3,t}$-free host $G'$, descends automatically to *every* subgraph $G$ beneath it in the partial order of graphs. In deletion arguments, the surviving graph after a cleaning step is exactly such a subgraph, so its copy count is controlled without re-running the double count of Section 3. The proof is purely order-theoretic: both the counting object $\mathrm{Copies}_{a,b}$ and the freeness predicate are built from $\le$-preserved adjacency conditions, so anti-monotonicity is a formal consequence of the graph order rather than of any extremal argument.

---

## 6. Algorithms

The proofs are constructive and yield direct algorithms for verifying the hypotheses and computing the bounds.

**Algorithm A — Triple common-neighborhood cap check.** Given $G$ and $t$, decide whether $G$ satisfies `CNbound G t` (equivalently, by Lemma 3.2, whether $G$ is $K_{3,t}$-free): for every triple $S$ of vertices, compute $N(S) = \bigcap_{u\in S}\mathcal{N}(u)$ and test $|N(S)|\le t-1$. Complexity: $O(n^3\cdot n) = O(n^4)$ with adjacency-list intersection, or $O(n^3)$ amortized with bitset neighborhoods. This certifies the hypothesis of Theorem 3.7.

**Algorithm B — Cubic-bound evaluator.** Given $a,b,t,n$, return $\binom{t-1}{b}\binom{t-1}{a-3}\cdot n^3$ (and the sharper $\binom{n}{3}\binom{t-1}{b}\binom{t-1}{a-3}$ of Theorem 3.6). At the necessary threshold $t=b+1$ this reduces to $\binom{b}{a-3}\cdot n^3$ by Theorem 4.6. Complexity $O(1)$ arithmetic.

**Algorithm C — Threshold comparator.** Given $b\ge 6$, compute $\tau_{\mathrm{proved}}(b)$, $\tau_{\mathrm{nec}}(b)$, the gap $\tau_{\mathrm{proved}}-\tau_{\mathrm{nec}} = b\bmod 2$, and the boolean "frontier open" $= [b \text{ odd}]$ (Theorems 4.4–4.5). Complexity $O(1)$.

---

## 7. Applications

- **Cleaning and deletion arguments.** Downward closure (Theorem 5.4) is the workhorse for arguments that delete edges/configurations and must retain a count: the surviving subgraph inherits the cubic bound for free.
- **Supersaturation base camp.** Bounds that are monotone under the subgraph order are natural starting points for averaging-over-subgraphs supersaturation results, since `CNbound_anti` provides the per-subgraph control needed for the averaging step.
- **Certified extremal counting.** Algorithms A–B give a verifiable pipeline: certify $K_{3,t}$-freeness via the triple cap, then emit a provably correct cubic upper bound on $K_{a,b}$-copies.

---

## 8. Discussion and limitations

The results isolate the *upper* half of $\mathrm{ex}(n,K_{a,b},K_{3,t}) = \Theta(n^3)$. The matching lower bound is not addressed here and is precisely where the parity subtlety resides (Section 4). The upper bound is parity-uniform and holds at the necessary threshold for all $b$; the threshold analysis shows the only remaining gap to a sharp $\Theta(n^3)$ at the necessary threshold is the odd-$b$ off-by-one in the construction. The hypotheses $3\le a$ and $3\le b$ are genuine: $a\ge 3$ is needed to extract an anchoring triple from the $a$-side, and $b\ge 3$ is needed for the second application of the neighborhood cap to $N(B)$.

---

## 9. Future directions

1. **Monotone closure of the full counting hierarchy.** Abstract `cnbhd_mono`/`K3tFree_anti` into a generic "monotone forbidden-configuration" interface so that anti-monotonicity downward-closes *every* generalized Turán bound $\mathrm{ex}(n,H,F)$ added to the catalog, not just the cubic $K_{3,t}$ case.
2. **A formal deletion/cleaning combinator.** Package deletion as explicit downward movement in the graph order: given a $K_{3,t}$-free $G'$, a deletion $G\le G'$, and the cubic bound, produce the surviving estimate together with quantitative "copies lost" accounting via a subset lemma $\mathrm{Copies}_{a,b}(G)\subseteq \mathrm{Copies}_{a,b}(G')$.
3. **Matching lower-bound constructions at the necessary threshold.** Formalize an explicit $K_{3,t}$-free graph achieving $\Theta(n^3)$ copies of $K_{a,b}$, turning $O(n^3)$ into a sharp $\Theta(n^3)$. The leading constant $\binom{t-1}{b}\binom{t-1}{a-3}$ predicts the extremal blow-up; the even-$b$ case (where proved and necessary thresholds coincide) is the natural first target.
4. **Density and supersaturation versions.** Use `CNbound_anti` as the base for supersaturation results proved by averaging over subgraphs.

---

## 10. Conclusion

A single quantitative principle — capping the common neighborhood of every triple at $t-1$ — yields, through an anchored double count, an explicit and parity-uniform cubic upper bound $\binom{n}{3}\binom{t-1}{b}\binom{t-1}{a-3}$ for $K_{a,b}$-copies in $K_{3,t}$-free graphs. An exact arithmetic analysis locates the entire remaining frontier of the sharp problem in the parity of $b$, and pure order-theoretic monotonicity makes the bound robust under deletion. The cubic exponent is no coincidence: it is the "$3$" of the forbidden $K_{3,t}$, fossilized in the answer.
