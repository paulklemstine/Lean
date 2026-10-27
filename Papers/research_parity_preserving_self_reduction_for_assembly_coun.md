# Parity-Preserving Self-Reduction for Jigsaw Assembly Counting

**Aristotle**

*October 2026*

---

## Abstract

We study the problem of counting the assemblies of *framed jigsaw puzzles*. In this combinatorial model, $n$ variable sockets each receive a tab or a blank piece, and clause pieces snap into place when at least one of their connectors mates. The model is literally conjunctive normal form, so the assembly count of a puzzle equals the number of satisfying assignments of a CNF formula. Our main structural result concerns the hyperoctahedral group $B_n = (\mathbb{Z}/2)^n \rtimes S_n$ of signed permutations of the sockets. This group acts on puzzles through a genuine group action, and each group element induces an explicit bijection between the assembly spaces of $P$ and $g\cdot P$. The assembly count is therefore an orbit invariant. Global tab/blank complementation $P \mapsto \overline{P}$ is the special element $(\mathrm{id}, \mathbf 1)$. It is a size-preserving, involutive, linear-time **parsimonious self-reduction** of assembly counting, so it preserves the count modulo every integer $k$, in particular the parity. Complementation acts freely on the instance space apart from the degenerate puzzles whose clause pieces are all empty. Translations of the cube that stabilise the solution set give *2-adic certificates*: the order $2^k$ of this mask-symmetry group divides the count, it is a $B_n$-invariant, and odd counts force it to be trivial. We give the mod-2 count by signless inclusion–exclusion over clause subsets. A short argument reduces this to counting clause subsets that consistently pin every socket. We show that the translations between DIMACS CNF and puzzles are parsimonious in both directions, so every modular-counting hardness result for SAT transfers to jigsaw assembly. Finally, we show that the physical encoding into labelled pieces multiplies the count by $(m+2)!\,(n!)^2$. That encoding is never parsimonious on solvable instances and always produces an even count. The loss of counting information therefore comes from the encoding and not from the underlying mathematics.

---

## 1. Introduction

Reductions between combinatorial problems usually preserve only *solvability*. A reduction $f$ from a decision problem $A$ to a decision problem $B$ only needs $x \in A \iff f(x)\in B$. Counting complexity asks for more. A reduction is **parsimonious** when the number of witnesses of $f(x)$ equals the number of witnesses of $x$. Parsimonious reductions are the natural morphisms of the class $\#\mathrm{P}$ introduced by Valiant (1979). Since a parsimonious reduction preserves the exact count, it also preserves the count modulo every $k$. So it transports hardness for every modular counting class $\mathrm{Mod}_k\mathrm{P}$ at once, including $\oplus\mathrm{P} = \mathrm{Mod}_2\mathrm{P}$.

Jigsaw puzzles are a classical source of NP-complete problems. This paper studies a framed variant in which the frame contributes $n$ binary *variable sockets* and the remaining pieces act as *clauses*. The variant is designed so that solving it is exactly satisfiability. The question we address is how the natural symmetries of the instance space interact with counting. The most natural symmetry is global complementation: swap every tab for a blank and vice versa. This map is a bijection on instances, and we ask whether it is also a bijection on *witnesses*. If it is, it is a parsimonious self-reduction, and every modular count is a complementation invariant.

We show that this is the case, and more. Complementation is one element of a parsimonious action of the full hyperoctahedral group. The action has three consequences:

1. **Invariance.** The exact count is constant on orbits (Theorems 3.3 and 3.5), and hence so is every modular count (Corollary 4.2).
2. **Freeness.** Complementation fixes no instance except the degenerate ones (Theorem 4.3).
3. **Divisibility.** Stabilisers in the translation subgroup produce powers of two dividing the count (Theorem 5.2).

We also describe exactly where parsimony fails: in the physical encoding by labelled pieces (Theorem 7.3), not in the mathematics.

**Scope.** The model of efficiency used here is the encoding-size bound: every reduction we construct produces an output whose size is at most linear in the input size. All of these maps are evidently computable in linear time. We do not reprove that #SAT is #P-complete. We use the classical fact as a black box and prove the parsimonious transfer from #SAT to jigsaw counting.

---

## 2. The model

Throughout, $\mathbb{F}_2 = \mathbb{Z}/2$ and $[n] = \{1,\dots,n\}$. We write the Boolean cube additively:
$$Q_n = \mathbb{F}_2^{\,n}, \qquad a = (a_1,\dots,a_n).$$
A coordinate $a_i = 1$ means socket $i$ holds the tab piece, and $a_i = 0$ means it holds the blank.

**Definition 2.1 (Literal input, clause piece, framed puzzle).** A *literal input* on $n$ sockets is a pair $\ell = (i,p) \in [n]\times\mathbb{F}_2$: a socket together with the polarity it is milled for. A *clause piece* is a finite list of literal inputs. A *framed puzzle* $P$ on $n$ sockets is a finite list $P = (c_1,\dots,c_m)$ of clause pieces. Its *size* is $|P| = m + \sum_j |c_j|$.

**Definition 2.2 (Fitting, assembling).** A literal input $(i,p)$ *fits* a filling $a\in Q_n$ when $a_i = p$. A filling $a$ *assembles* $P$ when every clause piece contains a literal input that fits:
$$a \models P \quad:\Longleftrightarrow\quad \forall c\in P\;\; \exists (i,p)\in c:\; a_i = p.$$
The *assembly space* is $\mathcal{A}(P) = \{a\in Q_n : a\models P\}$, and the *assembly count* is $\#P = |\mathcal{A}(P)|$.

A literal $(i,1)$ is the positive literal $x_i$ and $(i,0)$ is the negative literal $\lnot x_i$. Under this dictionary a puzzle is a CNF formula, $a \models P$ is satisfaction, and $\#P$ is the number of satisfying assignments. A clause piece with no inputs can never snap in, so a puzzle containing one has $\#P = 0$. The empty puzzle has $\#P = 2^n$.

**Example 2.3.** Let $n=3$ and $P = \big((1,1),(2,1)\big),\big((2,0),(3,1)\big)$, i.e. $(x_1\lor x_2)\land(\lnot x_2\lor x_3)$. Then $\mathcal{A}(P) = \{011, 100, 101, 111\}$ (written $a_1a_2a_3$) and $\#P = 4$.

---

## 3. The hyperoctahedral action

**Definition 3.1 (Signed permutation).** A *signed permutation* of the sockets is a pair $g = (\sigma,\mu)$ with $\sigma\in S_n$ and $\mu\in Q_n$. It acts on literal inputs, puzzles and fillings by
$$g\cdot(i,p) = \big(\sigma(i),\; p + \mu_i\big), \qquad g\cdot P = \big(\,(g\cdot\ell)_{\ell\in c}\,\big)_{c\in P},$$
$$(g\cdot a)_j = a_{\sigma^{-1}(j)} + \mu_{\sigma^{-1}(j)}.$$
That is, socket $i$ is relabelled $\sigma(i)$, and the tab/blank polarity at socket $i$ is flipped exactly when $\mu_i = 1$. The inverse action on fillings is $(g^{-1}\cdot b)_i = b_{\sigma(i)} - \mu_i$. It satisfies $g^{-1}\cdot(g\cdot a) = a$ and $g\cdot(g^{-1}\cdot b)=b$, so $a\mapsto g\cdot a$ is a bijection of $Q_n$.

**Lemma 3.2 (Literal-level transport).** For every $g$, $a$ and $\ell$: $\;g\cdot\ell$ fits $g\cdot a$ $\iff$ $\ell$ fits $a$.

*Proof.* Let $\ell=(i,p)$. Then $(g\cdot a)_{\sigma(i)} = a_i + \mu_i$ and $g\cdot \ell = (\sigma(i), p+\mu_i)$. So the condition reads $a_i+\mu_i = p+\mu_i$, which is equivalent to $a_i = p$ by cancellation in $\mathbb{F}_2$. $\square$

**Theorem 3.3 (Witness-preserving bijection).** For every signed permutation $g$ and every puzzle $P$, and for every filling $a$,
$$g\cdot a \models g\cdot P \iff a\models P.$$
Consequently $a\mapsto g\cdot a$ restricts to a bijection $\mathcal{A}(P)\to\mathcal{A}(g\cdot P)$ with inverse $b\mapsto g^{-1}\cdot b$. Equivalently, $\mathcal{A}(g\cdot P) = g\cdot\mathcal{A}(P)$, and in particular
$$\#(g\cdot P) = \#P.$$

*Proof.* The clause pieces of $g\cdot P$ are the images $g\cdot c$ of the clause pieces $c$ of $P$, and the inputs of $g\cdot c$ are the images of the inputs of $c$. Suppose $a \models P$, and take a clause piece $g\cdot c$. Choose an input $\ell \in c$ that fits $a$. By Lemma 3.2, $g\cdot\ell$ fits $g\cdot a$. Conversely, suppose $g\cdot a\models g\cdot P$ and take $c\in P$. Some input of $g\cdot c$ fits $g\cdot a$. That input has the form $g\cdot\ell$ with $\ell\in c$, and Lemma 3.2 shows $\ell$ fits $a$. The two maps on fillings are mutually inverse, so the restriction is a bijection. $\square$

**Definition 3.4 (Group law).** Define $g h = (\sigma_g\sigma_h,\; \nu)$ with $\nu_i = \mu_{h,i} + \mu_{g,\sigma_h(i)}$. The product means "first $h$, then $g$". This is the multiplication of the wreath product $\mathbb{F}_2\wr S_n = B_n$, a group of order $2^n n!$.

**Theorem 3.5 (Action compatibility and orbit invariance).** For all $g,h$ and $P$, $(gh)\cdot P = g\cdot(h\cdot P)$. Consequently, for any finite word $g_1g_2\cdots g_r$,
$$\#\big(g_1\cdot(g_2\cdot(\cdots(g_r\cdot P)\cdots))\big) = \#P,$$
so the assembly count is constant on every $B_n$-orbit of puzzles.

*Proof.* It suffices to check the identity on literal inputs:
$$g\cdot(h\cdot(i,p)) = g\cdot(\sigma_h(i),\,p+\mu_{h,i}) = (\sigma_g\sigma_h(i),\; p+\mu_{h,i}+\mu_{g,\sigma_h(i)}) = (gh)\cdot(i,p).$$
Mapping over clause pieces and over the puzzle preserves this identity. Orbit invariance then follows by induction on the length of the word, using Theorem 3.3 at each step. $\square$

**Remark 3.6 (Geometry).** $B_n$ is the symmetry group of the $n$-cube, and $a\mapsto g\cdot a$ is the corresponding isometry of $Q_n$ for the Hamming metric. Theorem 3.3 says that transforming the instance moves the solution set by a cube symmetry. Every invariant of subsets of $Q_n$ under cube symmetries is therefore an invariant of puzzles. This includes cardinality, the weight enumerator up to complementation, and the dimension of the affine hull.

---

## 4. Complementation as a parsimonious self-reduction

**Definition 4.1 (Complement).** The *complement* of $P$ is $\overline{P} = (\mathrm{id},\mathbf{1})\cdot P$, obtained by replacing every input $(i,p)$ with $(i,p+1)$. On fillings, $(\mathrm{id},\mathbf 1)$ acts by bitwise negation $a\mapsto a+\mathbf 1$.

**Corollary 4.2 (Complementation is parsimonious).** For every puzzle $P$:

1. $a\models P \iff a+\mathbf{1}\models\overline{P}$, so bitwise negation is an explicit bijection $\mathcal{A}(P)\to\mathcal{A}(\overline{P})$;
2. $\#\overline{P} = \#P$;
3. $\#\overline{P}\equiv\#P \pmod k$ for every $k\ge 1$. In particular, $\#P$ is even if and only if $\#\overline P$ is even;
4. $\overline{\overline{P}} = P$ and $|\overline{P}| = |P|$.

*Proof.* Items 1–3 are Theorem 3.3 applied to $g = (\mathrm{id},\mathbf 1)$. Item 4 holds because $p+1+1 = p$ in $\mathbb{F}_2$ and the shape of the list of lists is unchanged. $\square$

In the language of reductions, define a **counting problem** to be a set of instances $X$ with a size function $|\cdot|$ and a count $c_X : X\to\mathbb{N}$. A **parsimonious reduction** from $(X,c_X)$ to $(Y,c_Y)$ is a map $f:X\to Y$ with $c_Y(f(x)) = c_X(x)$ and $|f(x)| \le C|x| + D$ for constants $C, D$. Corollary 4.2 shows that complementation is a parsimonious self-reduction of $\#\mathrm{Jigsaw} = (\text{puzzles},\#)$ with $C=1$, $D=0$. It is computable in a single linear pass.

**Theorem 4.3 (Freeness).** $\overline{P} = P$ if and only if every clause piece of $P$ is empty.

*Proof.* If all clause pieces are empty there is nothing to flip. Conversely, $\overline{P}$ has the same shape as $P$. If some clause piece has an input $(i,p)$, then the corresponding position of $\overline P$ holds $(i,p+1)\ne(i,p)$. $\square$

Thus $\langle(\mathrm{id},\mathbf 1)\rangle\cong\mathbb{Z}/2$ acts freely on the non-degenerate puzzles. That part of the instance space is partitioned into pairs $\{P,\overline P\}$ of distinct instances with equal counts. Degenerate puzzles have count $0$ if they contain at least one (empty) clause and count $2^n$ if they have no clauses.

---

## 5. Mask symmetries and 2-adic certificates

The translations $\tau_\mu = (\mathrm{id},\mu)$ form the normal subgroup $\mathbb{F}_2^{\,n}\trianglelefteq B_n$.

**Definition 5.1 (Mask-symmetry group).** For a puzzle $P$ let
$$H_P = \{\mu\in Q_n : \mathcal{A}(P) + \mu = \mathcal{A}(P)\},$$
the stabiliser of the assembly space under translations. It is a subgroup of $Q_n$, i.e. an $\mathbb{F}_2$-linear subspace. Every mask $\mu$ with $\tau_\mu\cdot P = P$, or more generally with $\tau_\mu\cdot P$ having the same assembly space as $P$, lies in $H_P$ by Theorem 3.3, so the results below apply to those masks as well.

**Theorem 5.2 (2-adic certificate).** For every puzzle $P$:

1. $|H_P| = 2^k$ with $k = \dim_{\mathbb{F}_2}H_P$, and $2^k$ divides $\#P$. In fact $\#P = 2^k\cdot\big|\mathcal{A}(P)/H_P\big|$;
2. $|H_{g\cdot P}| = |H_P|$ for every signed permutation $g$;
3. if $\#P$ is odd, then $H_P = \{0\}$.

*Proof.* (1) $H_P$ is a subspace of $\mathbb{F}_2^{\,n}$, so its order is a power of two. It acts on the finite set $\mathcal{A}(P)$ by translation, and the action is free because $a+\mu = a$ forces $\mu = 0$. All orbits therefore have size $|H_P|$, and $|\mathcal{A}(P)| = |H_P|\cdot\#\text{orbits}$. (2) Write $g = (\sigma,\mu_g)$. A direct computation gives $g\cdot(a+\nu) = g\cdot a + \nu\circ\sigma^{-1}$, i.e. $g\tau_\nu g^{-1} = \tau_{\nu\circ\sigma^{-1}}$. Combined with $\mathcal{A}(g\cdot P) = g\cdot\mathcal{A}(P)$ (Theorem 3.3), this yields $H_{g\cdot P} = \{\nu\circ\sigma^{-1} : \nu\in H_P\}$, which has the same order. (3) If $2^k$ divides an odd number then $k=0$. $\square$

The certificate is cheap to state and often sharp. Let $v_2$ denote the 2-adic valuation. On random puzzles with $n\le 4$ sockets, $v_2(\#P) = k$ held for the large majority of solvable samples (242 of 243 in the experiment reported in Section 8). By part (1), the gap $v_2(\#P)-k$ is exactly $v_2$ of the number of $H_P$-orbits on the assembly space.

---

## 6. The parity of the count

**Theorem 6.1 (Mod-2 count by signless inclusion–exclusion).** For a set $S$ of clause pieces of $P$, let $F_S = \{a\in Q_n : \text{no } c\in S \text{ has an input fitting } a\}$ be the set of common falsifiers. Then
$$\#P \equiv \sum_{S\subseteq P} |F_S| \pmod 2.$$

*Proof.* By inclusion–exclusion over the "bad" events "clause $c$ fails", $\#P = \sum_{S}(-1)^{|S|}|F_S|$. Reducing modulo $2$ removes the signs, since $-1\equiv 1$. $\square$

**Proposition 6.2 (Affine-subcube criterion).** Each $F_S$ is either empty or an affine subcube of $Q_n$. Call $S$ *consistent* if no socket is forced to both values, and *fully pinning* if every socket $i\in[n]$ occurs in some input of some clause in $S$. Then
$$\#P \equiv \big|\{S\subseteq P : S \text{ consistent and fully pinning}\}\big| \pmod 2.$$

*Proof.* A clause piece $c$ fails at $a$ exactly when $a_i = p+1$ for every input $(i,p)\in c$. So $F_S$ is the set of fillings satisfying the pinning constraints $\{a_i = p+1 : (i,p)\in c\in S\}$. If two constraints conflict, $F_S=\varnothing$. Otherwise the pinned sockets $V(S)$ are fixed and the rest are free, so $|F_S| = 2^{\,n-|V(S)|}$. This number is odd exactly when $V(S) = [n]$. Substituting into Theorem 6.1 gives the claim. $\square$

In Example 2.3 the falsifier sizes are $|F_\varnothing| = 8$, $|F_{\{c_1\}}| = |F_{\{c_2\}}| = 2$ and $|F_{\{c_1,c_2\}}| = 0$. No subset is fully pinning, and indeed $\#P = 8-2-2+0 = 4$ is even.

Proposition 6.2 is a sum over $2^m$ subsets. It does not make parity counting easy in general, which is consistent with $\oplus\mathrm{SAT}$ being $\oplus\mathrm{P}$-complete. It does show that only clause subsets with at least $n$ distinct sockets can contribute. It also identifies combinatorial families (for instance, puzzles in which no subset of clause pieces covers all sockets consistently) where the parity is forced to be even.

---

## 7. Encodings: where parsimony breaks

### 7.1 SAT and jigsaw reduce to each other parsimoniously

A DIMACS CNF on variables $1,\dots,n$ is a list of clauses, each a list of nonzero integers. Translate the literal $+v$ to $(v,1)$ and $-v$ to $(v,0)$. This gives a puzzle on $n$ sockets with the same shape. The reverse translation inverts it.

**Theorem 7.1 (Two-way parsimony).** The translations $\mathrm{CNF}\to\mathrm{Puzzle}$ and $\mathrm{Puzzle}\to\mathrm{CNF}$ are mutually inverse, size-preserving and parsimonious: the number of satisfying assignments of the formula equals the assembly count of the puzzle.

**Corollary 7.2 (Hardness transfer).** If a counting problem $(X,c_X)$ reduces parsimoniously to $\#\mathrm{SAT}$, then it reduces parsimoniously to $\#\mathrm{Jigsaw}$. Hence for every $k$ it also reduces to the problem of computing $\#P \bmod k$. Since #SAT is #P-complete under parsimonious reductions (Valiant), exact jigsaw assembly counting is #P-complete, and computing $\#P\bmod k$ is $\mathrm{Mod}_k\mathrm{P}$-hard.

*Proof.* Composition of parsimonious maps is parsimonious, and linear size bounds compose to linear size bounds. $\square$

### 7.2 Labelled physical assemblies

To build a physical jigsaw, a framed puzzle with $m$ clause pieces on $n$ sockets is encoded as a pile of labelled pieces. Some of those pieces are physically interchangeable; the multiplicity factor below records the relabellings of interchangeable pieces (one family of size $m+2$ and two families of size $n$). A *labelled assembly* records which physical piece sits where. Each mathematical assembly therefore lifts to many labelled ones.

**Theorem 7.3 (The encoding breaks parsimony).** The number of labelled physical assemblies is
$$\#_{\mathrm{lab}}(P) = \#P\cdot(m+2)!\cdot n!\cdot n!.$$
Consequently:

1. $\#_{\mathrm{lab}}(P)$ is always even;
2. $\#_{\mathrm{lab}}(P) = 0\iff\#P = 0$, so the encoding is a valid *decision* reduction;
3. if $\#P>0$ then $\#_{\mathrm{lab}}(P)\ne\#P$, so the encoding is never parsimonious on a solvable instance.

*Proof.* Each mathematical assembly lifts to exactly $(m+2)!\,(n!)^2$ labelled ones, one for each way of distributing the interchangeable labels. Since $(m+2)!\ge 2$, the product is even and is strictly larger than $\#P$ whenever $\#P\ge 1$. $\square$

Corollary 4.2 and Theorem 7.3 show where counting information goes. The symmetry $P\mapsto\overline P$ preserves all of it. The physical encoding keeps the zero/nonzero distinction and erases the parity entirely: the multiplicity factor $(m+2)!(n!)^2$ is even, so $\#_{\mathrm{lab}}\equiv 0\pmod 2$ for every puzzle. **Piece multiplicities carry counting information.** A counting-faithful physical encoding would have to break the interchangeability, for example by making every piece unique, or would have to divide out the known multiplicity.

---

## 8. Algorithms and experiments

**Algorithm A (brute-force assembly count).** Enumerate $a\in Q_n$ and test $a\models P$ in time $O(|P|)$ per filling. Total cost: $O(2^n|P|)$.

**Algorithm B (witness transport).** Given $g=(\sigma,\mu)$ and $a\in\mathcal A(P)$, output $g\cdot a$ in $O(n)$ time. Theorem 3.3 guarantees that the output lies in $\mathcal A(g\cdot P)$. Transforming the instance costs $O(|P|)$.

**Algorithm C (parity by pinning).** For each $S\subseteq P$, maintain a partial assignment of forced values $a_i=p+1$. Abort on conflict, and count $S$ if all $n$ sockets end up forced. Cost: $O(2^m|P|)$. This is preferable to Algorithm A when $m < n$.

**Algorithm D (mask-symmetry group).** For each $\mu\in Q_n$, test whether $\mathcal A(P)+\mu = \mathcal A(P)$. Cost: $O(2^n\,\#P)$ after computing $\mathcal A(P)$.

We implemented all four algorithms and tested the results above on enumerated and random instances:

- Theorem 3.3 on 1440 random (puzzle, signed permutation) pairs with $n\le 4$, checking that $g\cdot\mathcal A(P) = \mathcal A(g\cdot P)$.
- Theorem 3.5 on 300 random triples $(g,h,P)$.
- Corollary 4.2 and Theorem 4.3 *exhaustively* on all two-clause puzzles with clause width at most $2$, for $n=1,2,3$ (16, 121 and 484 puzzles). This covered counts modulo $2,3,5$, involutivity, size preservation and the freeness criterion.
- Theorem 5.2 on 400 random puzzles, including the $B_n$-invariance of $|H_P|$.
- Theorem 6.1 and Proposition 6.2 on 300 random puzzles. The three parity computations agreed in every case.
- Theorem 7.1 on 200 random CNFs.

For Example 2.3 with $m=2$, $n=3$, the labelled count is $4\cdot 4!\cdot 3!\cdot 3! = 3456$, while $\#P = 4$.

---

## 9. Discussion

Complementation was conjectured to be a parsimonious self-reduction, making the mod-2 count a complementation invariant while the exact count stays #P-hard. This holds, for a structural reason: the full hyperoctahedral group acts on instances and on witnesses compatibly. Such a symmetry does not make counting easier. The orbit of $P$ has at most $2^n n!$ elements, all with the same count, and the count of any one of them is still #P-hard to compute. What the symmetry does give is (i) free equivalences between instances, useful for canonicalisation and for symmetry breaking in model counters, and (ii) arithmetic information about stabilisers, in the form of the powers of two in Theorem 5.2.

The negative result of Theorem 7.3 is equally informative. Standard NP-hardness reductions for physical puzzles are not counting-faithful, because physically identical pieces generate labelled solutions in multiplicity. The multiplicity factor here is a product of factorials. That factor is divisible by every prime $\le m+2$, so the encoding erases not only the parity but every $\mathrm{Mod}_q$ count for primes $q\le m+2$.

## 10. Future work

1. **Burnside census.** $B_n$ genuinely acts on puzzles (Theorem 3.5), so Burnside's lemma counts the orbits of two-clause puzzles on $n$ sockets as a sum over signed cycle types. Both $\#P$ and $|H_P|$ are constant on each orbit.
2. **Sharpness of the 2-adic certificate.** Characterise the puzzles with $v_2(\#P) = \log_2|H_P|$, i.e. those for which the number of $H_P$-orbits on $\mathcal{A}(P)$ is odd. Prove that this is the generic case for small $n$.
3. **Parity-tractable families.** Use Proposition 6.2 to identify structural classes, for example puzzles whose clause hypergraph cannot be covered consistently, in which the parity is computable in polynomial time.
4. **Counting-faithful encodings.** Design physical encodings whose multiplicity factor is a known odd number, or is $1$, so that modular counts survive the passage to real pieces.

## References

- L. G. Valiant, *The complexity of computing the permanent*, Theoretical Computer Science 8 (1979); and *The complexity of enumeration and reliability problems*, SIAM J. Computing 8 (1979).
- C. H. Papadimitriou and S. Zachos, *Two remarks on the power of counting*, Theoretical Computer Science (1983).
- S. Toda, *PP is as hard as the polynomial-time hierarchy*, SIAM J. Computing 20 (1991).
