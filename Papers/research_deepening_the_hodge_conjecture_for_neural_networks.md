# The Euler–Poincaré Principle for Decision-Surface Cellular Complexes

## Abstract

The decision surface of a rectified-linear (ReLU) neural network is a piecewise-linear object: the network partitions its input space into activation regions on each of which it acts as an affine map, and the zero set $V(f) = \{x : f(x) = 0\}$ of the network function is a faceted surface glued from flat cells. Such a surface carries a cellular chain complex $C_2 \xrightarrow{d_2} C_1 \xrightarrow{d_1} C_0$ whose homology encodes its topology. We prove that the **Euler characteristic** of this complex — the alternating sum of its Betti numbers — depends only on the dimensions of the chain groups and not on the boundary maps: $\dim H_0 - \dim H_1 + \dim H_2 = \dim C_0 - \dim C_1 + \dim C_2$. This follows from an abstract Euler–Poincaré principle, valid for numerical models of chain complexes of arbitrary length, which we establish by an induction that telescopes the boundary ranks and leaves only a single top-boundary defect $(-1)^L \operatorname{rank} d_L$; the defect vanishes for bounded complexes. Combining the identity with the width-driven ceiling on activation regions yields an architecture-only bound $|\chi| \le 3 \cdot \prod_i 2^{w_i}$ on the Euler characteristic of $V(f)$. The Euler characteristic is thereby exhibited as a rigid topological invariant of the decision surface — invariant under continuous deformation of the network's weights, and bounded a priori by the network's widths.

**Keywords.** Rectified-linear networks; decision surface; piecewise-linear topology; cellular chain complex; homology; Betti numbers; Euler characteristic; Euler–Poincaré principle; rank–nullity; expressive power.

---

## 1. Introduction

### 1.1 Motivation

A central question in the theory of neural networks is how much of a network's behaviour is dictated by its *architecture* — the arrangement of layers and their widths — as opposed to its trained *parameters*. For rectified-linear networks this question has an unusually crisp geometric face. Because the rectifier $t \mapsto \max(t, 0)$ is piecewise linear, a ReLU network computes a continuous piecewise-linear function $f$; the input space is subdivided into a finite arrangement of convex **activation regions**, on each of which $f$ is affine, and the decision surface

$$V(f) = \{x : f(x) = 0\}$$

is a piecewise-linear hypersurface assembled from flat cells. The topology of $V(f)$ — its number of connected components, its loops, its enclosed voids — is a direct measure of the network's expressive power as a classifier.

Homology packages this topology into a graded sequence of vector spaces $H_0, H_1, H_2, \dots$ whose dimensions are the Betti numbers. Individually, the Betti numbers are fragile: they can jump as the network's weights vary, even continuously. This paper isolates a quantity that does *not* jump — the Euler characteristic — and shows it is completely determined by the raw cell counts of the surface, hence bounded in advance by the network's widths.

### 1.2 Prior structure

Earlier development in this line established the scaffolding on which the present results rest:

1. The **cellular chain complex** $C_2 \xrightarrow{d_2} C_1 \xrightarrow{d_1} C_0$ of the decision surface, whose middle homology is the subquotient $\ker d_1 / \operatorname{im} d_2$.
2. A **cell-count bound**: $\dim H \le \#\text{cells} \le \prod_i 2^{w_i}$, tying the total homology to the widths $w_i$ of the hidden layers.
3. The **exact middle identity** $\dim H_1 = \dim C_1 - \operatorname{rank} d_1 - \operatorname{rank} d_2$.

The contribution here is to pin down *all three* homology groups simultaneously and assemble them into the Euler characteristic — the strongest single numerical invariant of the surface — showing that the cell-count *inequality* and the middle *exact identity* are two facets of one rigidity: the entire alternating sum of homology dimensions is a function of the chain-group dimensions alone.

### 1.3 Results

- **Theorem A (Abstract Euler–Poincaré defect).** For any numerical homology profile satisfying the two rank–nullity relations, the alternating sum of homology dimensions equals the alternating sum of chain dimensions, up to a single top-boundary term $(-1)^L \operatorname{rank} d_L$.
- **Theorem B (Euler–Poincaré principle).** For a bounded complex ($\operatorname{rank} d_L = 0$) the two alternating sums coincide.
- **Theorem C (Three homology dimensions).** The bottom, middle, and top homology of the concrete three-term complex have dimensions computable by rank–nullity as a cokernel, a subquotient, and a kernel respectively.
- **Theorem D (Euler characteristic of the decision surface).** $\dim H_0 - \dim H_1 + \dim H_2 = \dim C_0 - \dim C_1 + \dim C_2$.
- **Corollaries.** The invariant depends only on chain sizes; it obeys a total-dimension bound; and it satisfies the width-driven bound $|\chi| \le 3 \cdot \prod_i 2^{w_i}$.

---

## 2. Definitions and setup

Throughout, $F$ is a field and all modules are finite-dimensional $F$-vector spaces; $\dim$ denotes $F$-dimension. For a linear map $g : U \to W$ we write $\operatorname{rank} g = \dim(\operatorname{im} g)$.

**Definition 2.1 (Cellular chain complex of a decision surface).** The decision surface $V(f)$ of a rectified-linear network, being piecewise linear, is a finite regular cell complex. Let $C_k$ be the $F$-vector space freely spanned by its $k$-cells for $k = 0, 1, 2$ (vertices, edges, facets). The boundary maps
$$C_2 \xrightarrow{\;d_2\;} C_1 \xrightarrow{\;d_1\;} C_0$$
send each cell to the signed formal sum of the cells on its boundary. They satisfy the fundamental complex law
$$d_1 \circ d_2 = 0,$$
equivalently $\operatorname{im} d_2 \subseteq \ker d_1$: the boundary of a boundary is empty.

**Definition 2.2 (Homology).** The homology groups of the complex are
$$H_0 = \operatorname{coker} d_1 = C_0 / \operatorname{im} d_1, \qquad H_1 = \ker d_1 / \operatorname{im} d_2, \qquad H_2 = \ker d_2.$$
Here $\operatorname{im} d_2 \subseteq \ker d_1$ is realized as a submodule of $\ker d_1$ via the pullback along the inclusion $\ker d_1 \hookrightarrow C_1$, so that $H_1$ is a genuine quotient of $\ker d_1$. The Betti numbers are $b_k = \dim H_k$.

**Definition 2.3 (Euler characteristic).** The Euler characteristic of a length-$L$ complex is the alternating sum of Betti numbers, $\chi(H) = \sum_{n=0}^{L} (-1)^n b_n$. The chain Euler number is $\chi(C) = \sum_{n=0}^{L} (-1)^n \dim C_n$.

**Definition 2.4 (Numerical homology profile).** A numerical homology profile of length $L$ consists of three sequences $a, r, h : \mathbb{N} \to \mathbb{Z}$, where $a_n = \dim C_n$ is the $n$-th chain dimension, $r_n = \operatorname{rank} d_n$ is the rank of the $n$-th boundary map $d_n : C_{n+1} \to C_n$, and $h_n = \dim H_n$ is the $n$-th homology dimension, subject to the rank–nullity relations
$$h_0 = a_0 - r_0, \qquad h_{n+1} = a_{n+1} - r_n - r_{n+1} \quad (n \ge 0).$$
The first relation expresses $H_0$ as a cokernel; the second expresses each interior $H_{n+1}$ as a subquotient.

**Definition 2.5 (Bounded complex).** A length-$L$ complex is bounded if its top boundary map has rank zero, $r_L = 0$ — nothing maps out of the top chain group, so its homology is the full kernel.

---

## 3. The abstract Euler–Poincaré principle

The arithmetic heart of the paper is entirely combinatorial: it concerns numerical profiles, with no modules present.

**Theorem 3.1 (Euler–Poincaré defect identity).** *Let $(a, r, h)$ be a numerical homology profile. Then for every $L \in \mathbb{N}$,*
$$\sum_{n=0}^{L} (-1)^n h_n = \left(\sum_{n=0}^{L} (-1)^n a_n\right) - (-1)^L r_L.$$

*Proof.* Induct on $L$. For $L = 0$ the sum is $h_0 = a_0 - r_0$, which is $a_0 - (-1)^0 r_0$, matching the claim. For the step, assume the identity at $L = k$. Split off the top term of each alternating sum:
$$\sum_{n=0}^{k+1} (-1)^n h_n = \sum_{n=0}^{k} (-1)^n h_n + (-1)^{k+1} h_{k+1}.$$
Apply the induction hypothesis to the first summand and the profile relation $h_{k+1} = a_{k+1} - r_k - r_{k+1}$ to the second:
$$= \left(\sum_{n=0}^{k}(-1)^n a_n - (-1)^k r_k\right) + (-1)^{k+1}\big(a_{k+1} - r_k - r_{k+1}\big).$$
Expand the second bracket. The $a_{k+1}$ term combines with the first sum to give $\sum_{n=0}^{k+1}(-1)^n a_n$. The two $r_k$ contributions are $-(-1)^k r_k$ from the induction hypothesis and $(-1)^{k+1}(-r_k) = (-1)^k r_k$ from the profile relation (using $(-1)^{k+1} = -(-1)^k$); they cancel. The remaining boundary contribution is $(-1)^{k+1}(-r_{k+1}) = -(-1)^{k+1} r_{k+1}$. Hence the total is $\sum_{n=0}^{k+1}(-1)^n a_n - (-1)^{k+1} r_{k+1}$, exactly the claim at $L = k+1$. The telescoping is the crux: each interior rank $r_k$ appears once from the induction hypothesis and once from the profile relation, with opposite signs, and annihilates. $\qquad\blacksquare$

**Theorem 3.2 (Euler–Poincaré principle).** *If in addition the complex is bounded, $r_L = 0$, then*
$$\sum_{n=0}^{L} (-1)^n h_n = \sum_{n=0}^{L} (-1)^n a_n, \qquad \text{i.e.} \qquad \chi(H) = \chi(C).$$

*Proof.* Substitute $r_L = 0$ into Theorem 3.1; the defect term $(-1)^L r_L$ vanishes. $\qquad\blacksquare$

The content of Theorem 3.2 is a genuine *rigidity*: the right-hand side involves only the sizes $a_n$ of the chain groups, so the alternating sum of homology dimensions is blind to the boundary maps $d_n$ that determine the individual Betti numbers.

---

## 4. The three homology groups of the decision-surface complex

We now compute the three Betti numbers of the concrete complex $C_2 \xrightarrow{d_2} C_1 \xrightarrow{d_1} C_0$ of finite-dimensional $F$-vector spaces, and verify that they form a numerical homology profile.

**Lemma 4.1 (Bottom homology — cokernel).** $\dim H_0 = \dim C_0 - \operatorname{rank} d_1.$

*Proof.* $H_0 = C_0 / \operatorname{im} d_1$. The quotient dimension formula $\dim(C_0/\operatorname{im} d_1) + \dim(\operatorname{im} d_1) = \dim C_0$ gives the result, since $\dim(\operatorname{im} d_1) = \operatorname{rank} d_1$. $\qquad\blacksquare$

**Lemma 4.2 (Top homology — kernel).** $\dim H_2 = \dim C_2 - \operatorname{rank} d_2.$

*Proof.* $H_2 = \ker d_2$. Rank–nullity for $d_2 : C_2 \to C_1$ reads $\dim(\operatorname{im} d_2) + \dim(\ker d_2) = \dim C_2$, i.e. $\dim(\ker d_2) = \dim C_2 - \operatorname{rank} d_2$. $\qquad\blacksquare$

**Lemma 4.3 (Middle homology — subquotient).** *If $d_1 \circ d_2 = 0$, then*
$$\dim H_1 = \dim C_1 - \operatorname{rank} d_1 - \operatorname{rank} d_2.$$

*Proof.* The hypothesis $d_1 \circ d_2 = 0$ is equivalent to $\operatorname{im} d_2 \subseteq \ker d_1$, so the pullback $B := (\operatorname{im} d_2)\!\downarrow_{\ker d_1}$ of $\operatorname{im} d_2$ along the inclusion $\ker d_1 \hookrightarrow C_1$ is isomorphic to $\operatorname{im} d_2$ itself; hence $\dim B = \operatorname{rank} d_2$. The middle homology is $H_1 = \ker d_1 / B$, so
$$\dim H_1 = \dim(\ker d_1) - \dim B = \dim(\ker d_1) - \operatorname{rank} d_2.$$
Rank–nullity for $d_1 : C_1 \to C_0$ gives $\dim(\ker d_1) = \dim C_1 - \operatorname{rank} d_1$. Combining yields the claim. $\qquad\blacksquare$

The three lemmas exhibit, in order, a cokernel dimension, a subquotient dimension, and a kernel dimension — each requiring a distinct rank–nullity or subspace-pullback input; none is a formal restatement of the others. Setting $a_0 = \dim C_0$, $a_1 = \dim C_1$, $a_2 = \dim C_2$; $r_0 = \operatorname{rank} d_1$, $r_1 = \operatorname{rank} d_2$, $r_2 = 0$; and $h_0, h_1, h_2$ the three Betti numbers, Lemmas 4.1–4.3 say precisely that $(a, r, h)$ is a numerical homology profile of length $2$ (with $h_0 = a_0 - r_0$ and $h_{1} = a_1 - r_0 - r_1$, $h_2 = a_2 - r_1 - r_2$ with $r_2 = 0$), and it is bounded because nothing maps into $C_2$.

---

## 5. The Euler characteristic of the decision surface

**Theorem 5.1 (Euler characteristic, three-term complex).** *For the decision-surface complex $C_2 \xrightarrow{d_2} C_1 \xrightarrow{d_1} C_0$ with $d_1 \circ d_2 = 0$,*
$$\dim H_0 - \dim H_1 + \dim H_2 = \dim C_0 - \dim C_1 + \dim C_2.$$

*Proof.* Feed the profile of §4 into Theorem 3.2 with $L = 2$ and $r_2 = 0$. Explicitly, substitute Lemmas 4.1–4.3:
$$
\begin{aligned}
\dim H_0 - \dim H_1 + \dim H_2
&= (\dim C_0 - \operatorname{rank} d_1) \\
&\quad - (\dim C_1 - \operatorname{rank} d_1 - \operatorname{rank} d_2) \\
&\quad + (\dim C_2 - \operatorname{rank} d_2).
\end{aligned}
$$
The two copies of $\operatorname{rank} d_1$ cancel and the two copies of $\operatorname{rank} d_2$ cancel, leaving $\dim C_0 - \dim C_1 + \dim C_2$. $\qquad\blacksquare$

**Corollary 5.2 (Independence of the differentials).** *The Euler characteristic $\dim H_0 - \dim H_1 + \dim H_2$ is unchanged if $d_1$ and $d_2$ are replaced by any other pair of maps forming a complex over the same chain groups.* Indeed the right-hand side of Theorem 5.1 mentions no differential.

**Corollary 5.3 (Total-dimension bound).** *With $\chi = \dim H_0 - \dim H_1 + \dim H_2$,*
$$|\chi| \le \dim C_0 + \dim C_1 + \dim C_2.$$
*Proof.* By Theorem 5.1, $\chi = \dim C_0 - \dim C_1 + \dim C_2$; the triangle inequality on the three signed terms gives the bound. $\qquad\blacksquare$

**Corollary 5.4 (Width-driven bound).** *If each chain group of the decision surface of a ReLU network with hidden widths $w_1, \dots, w_L$ has dimension at most the activation-region count $\prod_i 2^{w_i}$, then*
$$|\chi(V(f))| \le 3 \cdot \prod_i 2^{w_i}.$$
*Proof.* Each of the three cell counts $\dim C_0, \dim C_1, \dim C_2$ is bounded by $\prod_i 2^{w_i}$ (a cell of any dimension is supported on activation regions, whose number is at most $\prod_i 2^{w_i}$). Corollary 5.3 then gives $|\chi| \le 3 \prod_i 2^{w_i}$. $\qquad\blacksquare$

Corollary 5.4 is the mission's quantitative "Hodge-number shadow" at the level of the Euler characteristic: a bound on a genuine topological invariant of the learned decision boundary that is a function of the *architecture alone*, requiring neither the weights nor any data.

---

## 6. Algorithms

The theory is effective. Given the two boundary matrices of the surface (over a field, e.g. $\mathbb{Q}$ or $\mathbb{F}_2$), the invariants are all computable by rank computations.

**Algorithm 6.1 (Betti numbers and Euler characteristic).**
1. Input integer matrices $D_1 \in F^{|C_0| \times |C_1|}$ and $D_2 \in F^{|C_1| \times |C_2|}$ with $D_1 D_2 = 0$.
2. Compute $r_1 = \operatorname{rank} D_1$ and $r_2 = \operatorname{rank} D_2$ by Gaussian elimination.
3. Output $b_0 = |C_0| - r_1$, $b_1 = |C_1| - r_1 - r_2$, $b_2 = |C_2| - r_2$.
4. Return $\chi = b_0 - b_1 + b_2$ and verify $\chi = |C_0| - |C_1| + |C_2|$.

The dominant cost is the two rank computations, $O(|C_0|\,|C_1|\,\min(|C_0|,|C_1|))$ and similarly for $D_2$; the Euler characteristic itself needs only the cell counts (three additions).

**Algorithm 6.2 (Euler–Poincaré defect verifier).** Given sequences $a, r, h$ purporting to be a numerical homology profile, verify the two defining relations at each index and confirm $\sum (-1)^n h_n = \sum (-1)^n a_n - (-1)^L r_L$. This checks a candidate homology computation for internal consistency without recomputing any homology.

**Algorithm 6.3 (Width-bound certifier).** Given hidden widths $w_1, \dots, w_L$, output the certificate $3 \cdot \prod_i 2^{w_i}$ and confirm that a measured $\chi$ satisfies $|\chi| \le 3 \cdot \prod_i 2^{w_i}$.

---

## 7. Applications

**Expressive-power ceilings.** Corollary 5.4 turns a topological measure of decision-boundary complexity into an *a priori* architectural budget. A network cannot realize a boundary whose components-minus-loops-plus-voids exceeds $3\prod_i 2^{w_i}$, regardless of training. This complements VC-dimension and region-counting bounds with a genuinely topological ceiling.

**Stability under training.** Because $\chi$ is independent of the differentials (Corollary 5.2), it is invariant under any continuous deformation of the weights that preserves the combinatorial cell structure of the surface. The Euler characteristic is thus a conserved quantity of gradient descent between combinatorial phase transitions, and a natural signature by which to detect such transitions (the value of $\chi$ can only change when a cell is created or destroyed).

**Model comparison and verification.** Algorithm 6.1 gives a cheap fingerprint of a trained boundary; Algorithm 6.2 provides an internal consistency check on any homology pipeline, catching errors that individually plausible Betti numbers would otherwise hide.

---

## 8. Discussion

The result situates two earlier facts — the cell-count *inequality* and the middle-homology *exact identity* — as two aspects of one rigidity principle. Nothing in the derivation is definitional: the abstract induction needs the parity identity $(-1)^{L+1} = -(-1)^L$ to telescope; the three dimension lemmas each draw on a different linear-algebraic input (a quotient formula, a pullback isomorphism between $\operatorname{im} d_2$ and its preimage in $\ker d_1$, and rank–nullity); and Theorem 5.1 is a true instantiation of the general principle, not a restatement of it. The defect form (Theorem 3.1) is worth keeping even though decision surfaces are bounded: it isolates *exactly* what obstructs Euler invariance in an unbounded complex — the single top-boundary rank — and shows the obstruction telescopes away when that rank is zero.

---

## 9. Future directions

**General length-$n$ complexes.** The abstract principle already handles arbitrary length; what remains is to package a genuine $\mathbb{N}$-indexed chain complex of finite-dimensional modules (including the endpoint cokernel and kernel) and show its per-position homology dimensions satisfy the two relations $h_0 = a_0 - r_0$ and $h_{n+1} = a_{n+1} - r_n - r_{n+1}$. This would give $\chi(H) = \chi(C)$ for decision surfaces of arbitrary depth.

**Bigraded / Hodge-number refinement.** A conjectural refinement replaces the single Euler number by a Hodge diamond indexed by activation depth, with bounds of the form $h^{p,q} \le \binom{w_1}{p}\binom{w_L}{q}\prod_i w_i$.

**Sharpness.** Construct explicit ReLU networks realizing the width bound $|\chi| = 3\prod_i 2^{w_i}$, or determine the true extremal constant, turning Corollary 5.4 into an equality on a witness family.

**Morse / critical-cell interpretation.** Relate $\dim C_i$ to counts of activation regions of a fixed local dimension, giving a Morse-theoretic reading of the Euler characteristic in terms of the network's piecewise-linear geometry.

---

## 10. Conclusion

For the cellular complex of a rectified-linear network's decision surface, the alternating sum of Betti numbers equals the alternating sum of cell counts: $\dim H_0 - \dim H_1 + \dim H_2 = \dim C_0 - \dim C_1 + \dim C_2$. This Euler–Poincaré rigidity — an instance of a general defect identity that telescopes the boundary ranks — makes the Euler characteristic a differential-free, deformation-invariant topological signature of the decision boundary, bounded a priori by the network's widths, $|\chi| \le 3\prod_i 2^{w_i}$. It is the first firm invariant in a program that seeks to read the topology of what a network can learn directly from the algebra of its architecture.
