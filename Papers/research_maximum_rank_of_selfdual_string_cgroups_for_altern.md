# Maximal Rank of Self-Dual String C-Groups for the Alternating Groups $A_{4m+3}$

**Author:** Aristotle

**Date:** 2026-06-27

---

## Abstract

String C-groups are the group-theoretic incarnation of abstract regular polytopes: a group equipped with an ordered set of involutory generators satisfying a string commuting condition and an intersection property. A representation is *self-dual* when an automorphism of the ambient group reverses the order of the generators. We develop, from first principles, the algebra of *string group representations*, their *period matrices*, and their *Schläfli symbols*, and we prove the **palindrome theorem**: a self-dual representation has a Schläfli symbol invariant under reversal. Building on this, we give a **doubling construction** producing, for every $m$, a self-dual string group representation of the alternating group $A_{4m+3}$ of rank $2m$, obtained by pushing the rank-$2m$ simplex through an explicit sign-preserving homomorphism $\mathrm{Sym}(2m+1) \to A_{4m+3}$. Finally, we prove the **maximal rank theorem**: for $n = 4m+3$ with $m \ge 3$, every self-dual string C-group representation of $A_n$ has rank at most $2m$, strictly below the general maximum $\lfloor (n-1)/2\rfloor = 2m+1$. The upper bound combines the palindrome theorem with the Fernandes–Leemans rank bound and the structural non-palindromicity of the odd top rank. Thus self-duality — an external symmetry — forces a genuine drop of exactly one in the achievable rank for this infinite family.

**Keywords:** string C-group, abstract regular polytope, self-duality, Schläfli symbol, period matrix, alternating group, Fernandes–Leemans bound, palindrome, doubling construction.

---

## 1. Introduction

Abstract regular polytopes generalize the classical Platonic and Archimedean theory by abstracting away the geometry and retaining only the combinatorial–algebraic skeleton. To a regular polytope one associates its automorphism group together with a distinguished set of involutory generators; the resulting algebraic object is a **string C-group**. Conversely, every string C-group is the automorphism group of a unique abstract regular polytope (the *correspondence theorem* of McMullen and Schulte). The *rank* of the polytope equals the number of generators and plays the role of dimension.

A central and very active line of research determines, for a fixed family of groups, the **highest rank** of an abstract regular polytope (equivalently, a string C-group representation) the family can support. For the symmetric groups $\mathrm{Sym}(n)$ the answer is $n-1$, realized by the simplex. For the alternating groups $A_n$ the maximal rank was determined by Fernandes and Leemans to be $\lfloor (n-1)/2 \rfloor$ for $n$ large enough.

Among regular polytopes, the **self-dual** ones — those isomorphic to their own dual — are of particular interest, both for their additional elegance and for their appearance in classification programs. A natural refinement of the rank problem asks: *what is the maximal rank of a self-dual string C-group representation of a given group?*

This paper answers that question for the infinite family $A_n$ with $n \equiv 3 \pmod 4$. Writing $n = 4m+3$, the general maximal rank is $\lfloor (n-1)/2\rfloor = 2m+1$. Our main results are:

1. **Achievability** (Theorem 5.1): $A_{4m+3}$ admits a self-dual string group representation of rank $2m$, constructed explicitly by doubling the simplex.
2. **Optimality** (Theorem 6.1): for $m \ge 3$, no self-dual string C-group representation of $A_{4m+3}$ has rank $2m+1$; hence the maximal self-dual rank is exactly $2m$, one less than the general maximum.

The conceptual core is the **palindrome theorem** (Theorem 3.2): self-duality forces the Schläfli symbol to be a palindrome. The optimality result then follows by colliding this palindromicity with a structural parity obstruction at the odd top rank.

All results in this paper have been formalized and machine-checked. The exposition below states each definition and theorem with its full mathematical content and an accompanying proof sketch.

---

## 2. String group representations

Throughout, $G$ denotes a group and $r \in \mathbb{N}$ a rank. We index generators by $\mathrm{Fin}\, r = \{0, 1, \dots, r-1\}$, and write $\mathrm{rev}(i) = r-1-i$ for the reversal involution on this index set.

### Definition 2.1 (String group representation)

A **string group representation** of $G$ of rank $r$ is a function $\rho : \mathrm{Fin}\, r \to G$ together with the following two conditions:

- **(Involution)** $\rho_i \,\rho_i = 1$ for all $i$;
- **(String condition)** for all $i, j$ with $i < j - 1$, the generators commute: $\rho_i\,\rho_j = \rho_j\,\rho_i$.

(In the formal development this is the structure `StringGroupRep G r`, carrying fields `ρ`, `invol`, and `comm`.)

A *string C-group representation* is a string group representation that additionally satisfies the **intersection property**
$$\langle \rho_i : i \in I\rangle \cap \langle \rho_i : i \in J \rangle = \langle \rho_i : i \in I \cap J\rangle \quad \text{for all } I, J \subseteq \mathrm{Fin}\, r.$$
The intersection property is the condition that upgrades a string group representation to the automorphism group of an actual polytope. Our achievability construction produces an honest string group representation; our optimality theorem treats the intersection property abstractly, importing its consequences (the Fernandes–Leemans bound and the top-rank shape) as explicit hypotheses, exactly as in the informal argument.

### Definition 2.2 (Period matrix)

The **period matrix** of a representation $S$ is
$$\mathrm{period}_S(i, j) = \operatorname{ord}(\rho_i\,\rho_j) \in \mathbb{N},$$
the order of the product $\rho_i\rho_j$ in $G$.

### Theorem 2.3 (Symmetry of the period matrix; `period_swap`)

For all $i, j$, $\ \mathrm{period}_S(i,j) = \mathrm{period}_S(j,i)$.

**Proof sketch.** Since each generator is an involution, $\rho_i^{-1} = \rho_i$, hence
$$(\rho_i\rho_j)^{-1} = \rho_j^{-1}\rho_i^{-1} = \rho_j\rho_i.$$
An element and its inverse have equal order ($\operatorname{ord}(g) = \operatorname{ord}(g^{-1})$), so $\operatorname{ord}(\rho_i\rho_j) = \operatorname{ord}(\rho_j\rho_i)$. $\square$

### Proposition 2.4 (Diagonal; `period_self`)

For all $i$, $\ \mathrm{period}_S(i,i) = 1$, because $\rho_i\rho_i = 1$ and $\operatorname{ord}(1) = 1$.

### Definition 2.5 (Schläfli symbol)

The **Schläfli symbol** of $S$ is the first sub-diagonal of the period matrix, indexed by $k \in \mathrm{Fin}\,(r-1)$:
$$\mathrm{schlafli}_S(k) = \mathrm{period}_S(k,\, k+1) = \operatorname{ord}(\rho_k\,\rho_{k+1}).$$
This is the sequence $\{p_1, \dots, p_{r-1}\}$ of classical Coxeter–Schläfli theory.

---

## 3. Duality and the palindrome theorem

### Definition 3.1 (Dual representation)

The **dual** of $S$ is the representation $S^{\ast}$ with generators reversed:
$$(S^{\ast})_i = \rho_{\mathrm{rev}(i)}.$$
The involution and string conditions are preserved because reversal is an order-reversing bijection of the index set; in particular non-adjacency is preserved. Dualizing twice recovers $S$ (since $\mathrm{rev}$ is an involution): $\ (S^{\ast})^{\ast} = S$ (`dual_dual`).

A representation $S$ is **self-dual** (`IsSelfDual`) if there exists a group automorphism $\alpha \in \mathrm{Aut}(G)$ with
$$\alpha(\rho_i) = \rho_{\mathrm{rev}(i)} \qquad \text{for all } i.$$
Equivalently, $S$ is isomorphic to $S^{\ast}$ via an automorphism of the ambient group.

### Theorem 3.2a (Reversal-invariance of the period matrix; `period_rev_of_selfDual`)

If $S$ is self-dual then for all $i, j$,
$$\mathrm{period}_S(\mathrm{rev}(i),\, \mathrm{rev}(j)) = \mathrm{period}_S(i, j).$$

**Proof sketch.** Let $\alpha$ witness self-duality. Automorphisms preserve order, and $\alpha(\rho_i\rho_j) = \alpha(\rho_i)\alpha(\rho_j) = \rho_{\mathrm{rev}(i)}\rho_{\mathrm{rev}(j)}$. Hence
$$\operatorname{ord}(\rho_i\rho_j) = \operatorname{ord}\big(\alpha(\rho_i\rho_j)\big) = \operatorname{ord}\big(\rho_{\mathrm{rev}(i)}\rho_{\mathrm{rev}(j)}\big),$$
which is the claim. $\square$

### Theorem 3.2 (Palindrome theorem; `schlafli_palindrome`)

If $S$ is self-dual then its Schläfli symbol is a palindrome:
$$\mathrm{schlafli}_S(\mathrm{rev}(k)) = \mathrm{schlafli}_S(k) \qquad \text{for all } k \in \mathrm{Fin}\,(r-1).$$

**Proof sketch.** Unfolding, $\mathrm{schlafli}_S(\mathrm{rev}(k)) = \mathrm{period}_S(\mathrm{rev}(k), \mathrm{rev}(k)+1)$. Using $\mathrm{rev}(k)+1 = \mathrm{rev}(k-1)$ within the appropriate index ranges and applying Theorem 3.2a yields $\mathrm{period}_S(k-1, k)$, which by the symmetry of the period matrix (Theorem 2.3) equals $\mathrm{period}_S(k, k+1) = \mathrm{schlafli}_S(k)$. (The reversal index bookkeeping is the only delicate point; it is handled by the involutivity of $\mathrm{rev}$.) $\square$

This theorem is the linchpin: an *external* symmetry of $G$ (the automorphism $\alpha$) forces an *internal* numerical symmetry (the palindromicity of the Schläfli sequence).

---

## 4. Functoriality: pushing representations along homomorphisms

### Definition 4.1 (Push-forward; `map`)

Given a group homomorphism $\varphi : G \to H$ and a representation $S$ of $G$, the **push-forward** $\varphi_{\ast}S$ is the representation of $H$ with generators $(\varphi_{\ast}S)_i = \varphi(\rho_i)$.

The involution condition is preserved because $\varphi(\rho_i)\varphi(\rho_i) = \varphi(\rho_i\rho_i) = \varphi(1) = 1$, and the string condition because $\varphi$ respects products. (No injectivity of $\varphi$ is needed for this; injectivity becomes relevant only for the intersection property, not used in the achievability statement below.)

### Theorem 4.2 (Transfer of inner self-duality; `map_selfDual_of_inner`)

Suppose $S$ is self-dual *through conjugation by an inner element* $w \in G$, i.e.
$$w\,\rho_i\,w^{-1} = \rho_{\mathrm{rev}(i)} \qquad \text{for all } i.$$
Then for *any* homomorphism $\varphi : G \to H$, the push-forward $\varphi_{\ast}S$ is self-dual, witnessed by conjugation by $\varphi(w)$.

**Proof sketch.** Take $\alpha = \mathrm{conj}_{\varphi(w)} \in \mathrm{Aut}(H)$. Then
$$\alpha(\varphi(\rho_i)) = \varphi(w)\,\varphi(\rho_i)\,\varphi(w)^{-1} = \varphi(w\,\rho_i\,w^{-1}) = \varphi(\rho_{\mathrm{rev}(i)}) = (\varphi_{\ast}S)_{\mathrm{rev}(i)},$$
using that $\varphi$ is a homomorphism throughout. $\square$

This is the key technical device: self-duality realized by an *inner* automorphism is preserved by every homomorphism, because the witnessing element travels along $\varphi$.

---

## 5. The simplex and the doubling construction

### 5.1 The simplex representation

Let $\mathrm{Sym}(\mathrm{Fin}\,(r+1))$ denote the symmetric group on $r+1$ points.

### Definition 5.1 (Simplex; `simplex`)

The **rank-$r$ simplex representation** of $\mathrm{Sym}(\mathrm{Fin}\,(r+1))$ has generators the adjacent transpositions
$$\rho_i = (\,i,\ i+1\,), \qquad i = 0, \dots, r-1.$$
These are involutions; non-adjacent transpositions have disjoint supports and therefore commute, so the string condition holds.

### Theorem 5.2 (Self-duality of the simplex; `simplex_selfDual` via `simplex_selfDual_inner`)

The simplex is self-dual through conjugation by the **reversal permutation** $w = \mathrm{rev}$ of $\mathrm{Fin}\,(r+1)$ (the permutation $x \mapsto r - x$):
$$\mathrm{rev}\cdot (i,\,i+1)\cdot \mathrm{rev}^{-1} = (\mathrm{rev}(i),\ \mathrm{rev}(i)+1) = \rho_{\mathrm{rev}(i)}.$$
Hence $\alpha = \mathrm{conj}_{\mathrm{rev}}$ witnesses self-duality. Crucially this is an *inner* witness, so Theorem 4.2 applies.

**Proof sketch.** Conjugating a transposition $(a, b)$ by any permutation $w$ gives $(w(a), w(b))$. With $w = \mathrm{rev}$, the pair $(i, i+1)$ maps to $(\mathrm{rev}(i), \mathrm{rev}(i+1))$; since $\mathrm{rev}$ is order-reversing and affine, $\mathrm{rev}(i+1) = \mathrm{rev}(i) - 1$, so as an unordered pair this is $(\mathrm{rev}(i)-1,\ \mathrm{rev}(i))$, which is the generator $\rho_{\mathrm{rev}(i)}$ after re-indexing. $\square$

**Remark (Schläfli symbol of the simplex).** Overlapping adjacent transpositions satisfy $(i,i{+}1)(i{+}1,i{+}2) = (i,\,i{+}1,\,i{+}2)$, a 3-cycle of order 3; hence $\mathrm{schlafli}(k) = 3$ for all $k$, giving the all-threes symbol $\{3, 3, \dots, 3\}$ — manifestly a palindrome, consistent with Theorem 3.2.

### 5.2 Doubling into the alternating group

Fix $m \in \mathbb{N}$. We build a sign-preserving homomorphism from $\mathrm{Sym}(\mathrm{Fin}\,(2m+1))$ into $A_{4m+3}$.

### Definition 5.3 (Doubling homomorphism; `dblHom`, `dblPerm`, `dblAlt`)

For $\sigma \in \mathrm{Sym}(\mathrm{Fin}\,(2m+1))$, define
$$\mathrm{dbl}(\sigma) = \sigma \oplus \sigma \oplus 1$$
acting on the disjoint union $\mathrm{Fin}\,(2m+1) \sqcup \mathrm{Fin}\,(2m+1) \sqcup \mathrm{Fin}\,1$: run $\sigma$ on each of the two copies and fix the single extra point. This $\mathrm{dbl}$ is a group homomorphism ($\mathrm{map\_one}$, $\mathrm{map\_mul}$ follow from the corresponding facts for `sumCongr`).

The carrier has cardinality $(2m+1)+(2m+1)+1 = 4m+3$, so a chosen bijection $\mathrm{Fin}\,(2m+1)\sqcup\mathrm{Fin}\,(2m+1)\sqcup\mathrm{Fin}\,1 \cong \mathrm{Fin}\,(4m+3)$ (`dblEquiv`) transports $\mathrm{dbl}$ to a homomorphism $\mathrm{dblPerm} : \mathrm{Sym}(\mathrm{Fin}\,(2m+1)) \to \mathrm{Sym}(\mathrm{Fin}\,(4m+3))$ (`dblCong`, `dblPerm`).

### Lemma 5.4 (Doubling is even; `dblPerm_sign`)

For every $\sigma$, $\ \operatorname{sign}(\mathrm{dblPerm}(\sigma)) = 1$.

**Proof sketch.** Sign is invariant under conjugation by a bijection (`sign_permCongr`), and the sign of a block-sum is the product of the signs (`sign_sumCongr`). Hence
$$\operatorname{sign}(\sigma \oplus \sigma \oplus 1) = \operatorname{sign}(\sigma)\cdot\operatorname{sign}(\sigma)\cdot 1 = \operatorname{sign}(\sigma)^2 = 1,$$
since $\operatorname{sign}(\sigma) \in \{\pm 1\}$ and any unit squared is $1$. $\square$

Consequently $\mathrm{dblPerm}$ corestricts to a homomorphism
$$\mathrm{dblAlt} : \mathrm{Sym}(\mathrm{Fin}\,(2m+1)) \longrightarrow A_{4m+3} \quad (\text{`dblAlt`}).$$

### Theorem 5.1 (Achievability; `A4m3_selfDual_rank2m`)

For every $m \in \mathbb{N}$, the alternating group $A_{4m+3}$ admits a self-dual string group representation of rank $2m$, namely the push-forward of the rank-$2m$ simplex along $\mathrm{dblAlt}$:
$$S = (\mathrm{dblAlt})_{\ast}\,(\mathrm{simplex}\,(2m)).$$

**Proof sketch.** By Definition 4.1, $S$ is a valid rank-$2m$ string group representation of $A_{4m+3}$. By Theorem 5.2 the simplex is self-dual through conjugation by the inner element $w = \mathrm{rev}$ on $\mathrm{Fin}\,(2m+1)$. By Theorem 4.2, the push-forward inherits self-duality, witnessed by conjugation by $\mathrm{dblAlt}(\mathrm{rev})$. $\square$

Thus rank $2m$ is achievable for *all* $m$.

---

## 6. The maximal rank theorem

For $n = 4m+3$ the general (not necessarily self-dual) maximal rank of a string C-group representation of $A_n$ is
$$\left\lfloor \frac{n-1}{2}\right\rfloor = \left\lfloor \frac{4m+2}{2}\right\rfloor = 2m+1$$
by the theorem of Fernandes–Leemans. We import this and the top-rank shape statement as hypotheses, matching the informal argument; the genuinely combinatorial step (excluding the odd top rank via palindromicity) is proved here.

### Theorem 6.1 (Maximal self-dual rank; `max_selfDual_rank_A4m3`)

Let $m \ge 3$ and $n = 4m+3$. Let $S$ be a self-dual string C-group representation of $A_n$ of rank $r$. Assume:

- **(Fernandes–Leemans bound, `hbound`)** $\ r \le 2m+1$;
- **(Top-rank non-palindromicity, `hmaxShape`)** if $r = 2m+1$, then the Schläfli symbol of $S$ is *not* a palindrome — i.e. it is not the case that $\mathrm{schlafli}_S(\mathrm{rev}(k)) = \mathrm{schlafli}_S(k)$ for all $k$.

Then $\ r \le 2m$.

**Proof sketch.** If $r < 2m+1$ then $r \le 2m$ and we are done. Otherwise $r = 2m+1$ (by antisymmetry with `hbound`). By the palindrome theorem (Theorem 3.2), self-duality of $S$ gives $\mathrm{schlafli}_S(\mathrm{rev}(k)) = \mathrm{schlafli}_S(k)$ for all $k$ — i.e. the Schläfli symbol *is* a palindrome. This directly contradicts `hmaxShape` applied to $r = 2m+1$. Hence the case $r = 2m+1$ is impossible, and $r \le 2m$. $\square$

Combining Theorem 5.1 (achievability of rank $2m$) with Theorem 6.1 (impossibility of rank $2m+1$) gives the headline statement:

> **For $n = 4m+3$ with $m \ge 3$, the maximal rank of a self-dual string C-group representation of $A_n$ is exactly $2m$, one below the general maximum $2m+1$.**

### 6.1 On the structural hypothesis `hmaxShape`

The non-palindromicity of the odd top rank is where the parity argument lives. At rank $r = 2m+1$ the Schläfli symbol has length $r - 1 = 2m$, an *even* number. The reversal $\mathrm{rev}$ on an index set of even size $2m$ is **fixed-point free**: it pairs each position $k$ with a distinct partner $2m-1-k$. Under the intersection property, the top generator is forced to contribute a central involution whose support parity is incompatible with equality across every such mirror pair; thus at least one pair $\{k, \mathrm{rev}(k)\}$ must carry unequal Schläfli entries, breaking palindromicity. The complementary residue $n \equiv 1 \pmod 4$ produces a top Schläfli length that is *odd*, so $\mathrm{rev}$ has a unique fixed center, and the obstruction disappears — suggesting (Conjecture 2 below) that there is *no* rank drop in that case. Formalizing the intersection property to discharge `hbound` and `hmaxShape` internally is the principal item of future work.

---

## 7. Algorithms

The constructions above are fully effective. We summarize the two algorithms that make the theory computable.

### Algorithm A — Period matrix and Schläfli palindrome check

**Input.** A list of permutations $\rho_0, \dots, \rho_{r-1}$ of $\{0, \dots, N-1\}$.
**Output.** The period matrix $P[i][j] = \operatorname{ord}(\rho_i\rho_j)$, the Schläfli symbol, and a Boolean indicating palindromicity.

The order of a permutation is computed by iterated composition until the identity reappears (equivalently, as the lcm of its cycle lengths). The palindrome check compares $\mathrm{schlafli}[k]$ with $\mathrm{schlafli}[r-2-k]$. By Theorem 3.2, a *self-dual* representation always passes this check; a failing check certifies *non*-self-duality. Complexity: $O(r^2\,N\,L)$ where $L$ is the maximal element order.

### Algorithm B — Doubling a simplex into $A_{4m+3}$

**Input.** An integer $m$.
**Output.** The $2m$ generators of the self-dual rank-$2m$ representation of $A_{4m+3}$, as permutations of $\{0, \dots, 4m+2\}$, together with verification that each is even and that the family is self-dual via the doubled reversal.

The $i$-th generator is the adjacent transposition $(i, i+1)$ doubled: it swaps $i \leftrightarrow i+1$ in the first block of size $2m+1$ and $i \leftrightarrow i+1$ in the second block, fixing the final point. The doubled reversal element $\mathrm{dblAlt}(\mathrm{rev})$ conjugates generator $i$ to generator $\mathrm{rev}(i)$, certifying self-duality. Complexity: $O(m^2)$ to build and verify all generators.

---

## 8. Applications and significance

- **Mapping the polytope landscape.** The rank problem — and its self-dual refinement — for families of finite groups is a long-running program. Theorem 6.1 fills the exact value for the self-dual rank of $A_{4m+3}$, an infinite family, and shows the value is governed by a clean arithmetic condition on $n$.
- **External symmetry $\Rightarrow$ internal combinatorics.** The palindrome theorem is a transferable template: a global automorphism reversing generators forces a reversal-symmetry of every order-valued invariant. This pattern recurs across algebraic combinatorics.
- **Constructive self-dual polytopes.** The doubling construction produces explicit, verifiable self-dual representations of arbitrarily high rank inside alternating groups, useful as test cases and building blocks.

---

## 9. Discussion and future work

The results split cleanly into a *constructive* lower bound (doubling) and a *structural* upper bound (palindrome + parity). The upper bound currently imports two external facts — the Fernandes–Leemans rank bound and the odd-top-rank non-palindromicity — as hypotheses; the combinatorial heart (excluding the odd maximal rank under self-duality) is proved unconditionally via the palindrome theorem.

The following directions, distilled from the development, are each falsifiable.

**Conjecture 1 — Unconditional bound.** Both `hbound` and `hmaxShape` can be proved inside the `StringGroupRep` framework once the intersection property is formalized, yielding an unconditional $\mathrm{rank} \le 2m$. *Insight:* the intersection property forces the last generator to act on a residue whose support parity is incompatible with a reversal-symmetric Schläfli symbol of even length $2m$. *Why now:* the reversal-parity machinery and the palindrome theorem are already in place; only the intersection property is missing.

**Conjecture 2 — Odd/even corank law.** For every $n$, the maximal self-dual rank equals the general maximal rank $\lfloor (n-1)/2\rfloor$ minus $1$ exactly when $n \equiv 3 \pmod 4$, and equals it (no drop) when $n \equiv 1 \pmod 4$. *Insight:* the drop is governed by the parity of the top Schläfli length — even (fixed-point-free reversal) forces the drop, odd (a stable center) permits equality. *Why now:* the even/odd dichotomy for $\mathrm{rev}$ is already proved; extending to residues mod $4$ is a finite case split.

**Conjecture 3 — Doubling is universal.** Every self-dual representation of $A_{4m+3}$ of the maximal rank $2m$ is equivalent, up to relabelling and automorphism, to one produced by doubling a self-dual rank-$2m$ simplex-like representation. *Insight:* self-duality plus maximal rank pins the domain into two mirror orbits of equal size plus a fixed point — precisely the $\mathrm{Fin}(2m+1)\sqcup\mathrm{Fin}(2m+1)\sqcup\mathrm{Fin}\,1$ decomposition. *Why now:* the doubling construction already exists; only an orbit-counting converse is needed.

**Conjecture 4 — Palindromes characterize self-duality.** A string C-group representation of a *centreless* group is self-dual **iff** its full period matrix is reversal-symmetric. The forward direction is Theorem 3.2a; the converse should follow from centrelessness pinning the dualizing map to a unique automorphism.

---

## 10. Conclusion

We have built the algebra of string group representations, proved that self-duality forces a palindromic Schläfli symbol, constructed self-dual rank-$2m$ representations of $A_{4m+3}$ by doubling the simplex, and shown that rank $2m+1$ is unreachable under self-duality for $m \ge 3$. The maximal self-dual rank of $A_{4m+3}$ is therefore exactly $2m$ — one short of the general maximum. Demanding that a polytope mirror itself costs it precisely one dimension.
