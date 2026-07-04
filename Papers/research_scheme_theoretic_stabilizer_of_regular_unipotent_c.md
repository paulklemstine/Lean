# The Scheme-Theoretic Stabilizer of a Regular Unipotent Class under the Center of the Simply Connected Cover

## Abstract

Let $G$ be a reductive algebraic group over an algebraically closed field $k$, with simply connected (universal) cover $\pi\colon G' \to G$ and kernel $\ker\pi \subseteq Z(G')$ equal to the fundamental group of $G$. For a semisimple element, Steinberg's classical theory describes the stabilizer of its conjugacy class inside the center of $G'$. We establish the analogous statement at the opposite extreme of the regular locus: for a **regular unipotent** element $u \in G(k)$ with preimage $u' \in G'(k)$, the scheme-theoretic stabilizer of the conjugacy class $C_{u'}$ under $Z(G')$ equals $\ker\pi$. We give a complete, characteristic-free proof for the fundamental model case $\mathrm{SL}_2 \to \mathrm{PGL}_2$, where $\ker\pi = Z(\mathrm{SL}_2) = \mu_2$, and we exhibit the arithmetic mechanism that governs smoothness: the defining relation $a^2 = 1$ of $\mu_2$ degenerates to $(a-1)^2 = 0$ precisely in characteristic $2$, so that $\mu_2$ passes from an étale group (two reduced points) to an infinitesimal group (one non-reduced point). This explains, in the cleanest possible instance, why such stabilizers can fail to be smooth in bad characteristic while the equality with $\ker\pi$ remains characteristic-free. We include an explicit description of the centralizer of a regular unipotent, a proof that the center of $\mathrm{SL}_2$ is $\mu_2$, and the étale/infinitesimal dichotomy.

**Keywords.** Reductive group, simply connected cover, regular unipotent, conjugacy class stabilizer, center, $\mu_2$, group scheme, smoothness, characteristic $p$, Frobenius kernel.

---

## 1. Introduction

### 1.1 Setting and motivation

A connected reductive group $G$ over an algebraically closed field $k$ admits a *simply connected cover*, a central isogeny
$$\pi\colon G' \longrightarrow G$$
from a simply connected semisimple-times-torus group $G'$, whose kernel $\ker\pi$ is a finite central subgroup scheme of $G'$ canonically identified with the algebraic fundamental group $\pi_1(G)$. The smallest interesting instance is
$$\pi\colon \mathrm{SL}_2 \longrightarrow \mathrm{PGL}_2, \qquad \ker\pi = \mu_2 = \{a\cdot I : a^2 = 1\},$$
the double cover in which the redundancy is exactly the group $\mu_2$ of square roots of unity.

A recurring theme in the structure theory of algebraic groups is the interaction between conjugacy classes and the center. If $z \in Z(G')$ is central and $g \in G'$ is arbitrary, then $zgz^{-1} = g$, so **every** central element fixes **every** conjugacy class set-theoretically. Thus on the level of $k$-points the stabilizer of any class under $Z(G')$ is the whole center. The subtlety — and the reason the question is interesting — is that the *scheme-theoretic* stabilizer, which remembers non-reduced (infinitesimal) structure, can be strictly smaller than $Z(G')$ as a group scheme, and its geometry (in particular its smoothness) carries real information.

Steinberg established, for **regular semisimple** elements, that this scheme-theoretic stabilizer is precisely $\ker\pi$. This paper concerns the mirror-image case of **regular unipotent** elements, and shows that the same clean answer holds. Concretely, for $\mathrm{SL}_2 \to \mathrm{PGL}_2$ we prove that the stabilizer is $\mu_2 = \ker\pi$ and that this group is étale exactly when $\operatorname{char} k \neq 2$.

### 1.2 Background: the semisimple picture and why unipotents are harder

For a connected reductive group $G$ with simply connected cover $G'$, the center $Z(G')$ acts trivially by conjugation, so the naive stabilizer of any class is all of $Z(G')$ on points. Steinberg's analysis of regular semisimple elements refined this picture scheme-theoretically: the relevant stabilizer is exactly the fundamental group $\ker\pi$, and the possible discrepancy $Z(G')/\ker\pi$ is absorbed into the (reduced) torus action, so that in the semisimple case smoothness is automatic in every characteristic where $\ker\pi$ is étale.

The unipotent case is genuinely different for two reasons. First, a regular unipotent element $u$ is not diagonalizable; its centralizer is a unipotent-by-finite group rather than a torus-by-finite group, and the finite part is exactly the copy of $\ker\pi$ that we must isolate. Second, and more importantly, the defining equation of that finite part is a $p$-power relation $a^{|\pi_1|} = 1$, and in characteristic $p$ dividing $|\pi_1|$ this relation is *inseparable*. The inseparability is invisible to a point count but is precisely what destroys smoothness. The purpose of this paper is to exhibit both phenomena in the smallest nontrivial case, where every computation can be carried out by hand and verified explicitly.

### 1.3 Why $\mathrm{SL}_2 \to \mathrm{PGL}_2$ is the decisive model

Among all reductive groups, $\mathrm{PGL}_2$ is distinguished by the coincidence $Z(G') = \ker\pi$: the center of the simply connected cover equals the kernel of the isogeny. This removes the reduced "slack" $Z(G')/\ker\pi$ that could otherwise mask the phenomenon, so any failure of smoothness must come from the internal structure of $\ker\pi$ itself. If non-smoothness could be an artifact of the quotient $Z(G')/\ker\pi$, it would not appear here — yet it does, in characteristic $2$. This makes $\mathrm{SL}_2 \to \mathrm{PGL}_2$ the sharpest possible test of the claim that the stabilizer's geometry is governed by the arithmetic of the fundamental group alone.

### 1.4 Main results

We work throughout with $2\times 2$ matrices over a field $k$, realizing $G' = \mathrm{SL}_2$, its center $Z(G')$, and the kernel $\ker\pi$ of the projection to $\mathrm{PGL}_2$. The regular unipotent is the single Jordan block $u = \left(\begin{smallmatrix}1&1\\0&1\end{smallmatrix}\right)$.

1. **Centralizer of a regular unipotent (Theorem 3.1).** A determinant-one matrix $M$ commutes with $u$ if and only if $M$ is upper triangular with constant diagonal $a$ satisfying $a^2 = 1$:
$$M = \begin{pmatrix} a & b \\ 0 & a\end{pmatrix}, \qquad a^2 = 1.$$

2. **The center of $\mathrm{SL}_2$ is $\mu_2$ (Theorem 4.2).** A determinant-one matrix commutes with every determinant-one matrix if and only if it is a scalar $a\cdot I$ with $a^2 = 1$.

3. **The kernel of $\pi$ is $\mu_2$ (Theorem 5.1).** A determinant-one matrix maps to the identity of $\mathrm{PGL}_2$ if and only if it is scalar; determinant one then forces $a^2 = 1$. Hence $\ker\pi = Z(\mathrm{SL}_2) = \mu_2$.

4. **Main Theorem (Theorem 6.1).** The stabilizer of the regular unipotent conjugacy class inside the center of $\mathrm{SL}_2$ equals $\ker\pi = \mu_2$.

5. **Étale/infinitesimal dichotomy (Theorem 7.1).** The group scheme $\mu_2$ has two distinct $k$-points when $\operatorname{char} k \neq 2$ and a single (non-reduced) $k$-point when $\operatorname{char} k = 2$, because $a^2 - 1 = (a-1)^2$ there. Consequently the stabilizer is étale iff $\operatorname{char} k \neq 2$, and non-smooth iff $\operatorname{char} k = 2$.

All results are characteristic-free unless the characteristic is explicitly invoked.

---

## 2. Definitions and conventions

Throughout, $k$ is a field (algebraically closed where geometric statements about points require it); matrices are $2\times 2$ over $k$.

**Definition 2.1 (Regular unipotent block).** The *regular unipotent* element is
$$u := \begin{pmatrix} 1 & 1 \\ 0 & 1 \end{pmatrix}.$$
It is unipotent ($u - I$ is nilpotent) and regular (its centralizer has minimal dimension, equal to the rank). We also use the *opposite root unipotent*
$$l := \begin{pmatrix} 1 & 0 \\ 1 & 1 \end{pmatrix}.$$
Both have determinant $1$.

**Definition 2.2 (Special linear group).** $\mathrm{SL}_2(k) = \{M : \det M = 1\}$, where for $M = \left(\begin{smallmatrix} p & q \\ r & s\end{smallmatrix}\right)$ we have $\det M = ps - qr$.

**Definition 2.3 (The group $\mu_2$).** $\mu_2 := \{a\cdot I : a^2 = 1\}$, the scalar matrices whose scalar is a square root of unity. As a functor of points over a $k$-algebra $R$, $\mu_2(R) = \{a \in R : a^2 = 1\}$; as an affine scheme it is $\operatorname{Spec} k[a]/(a^2 - 1)$.

**Definition 2.4 (Kernel of the universal cover).** The cover $\pi\colon \mathrm{SL}_2 \to \mathrm{PGL}_2$ sends $M$ to its class modulo scalars. A determinant-one matrix lies in $\ker\pi$ iff it is a scalar matrix:
$$\ker\pi := \{M : \det M = 1 \text{ and } M = a\cdot I \text{ for some } a \in k\}.$$

**Definition 2.5 (Centralizer and central stabilizer).** For $g \in \mathrm{SL}_2$, the centralizer is $Z_{\mathrm{SL}_2}(g) = \{M \in \mathrm{SL}_2 : Mg = gM\}$. The *stabilizer of the class $C_u$ under the center* is the subgroup scheme of $Z(\mathrm{SL}_2)$ fixing the conjugacy class of $u$; since central elements fix all classes, its computation reduces to identifying $Z(\mathrm{SL}_2)$ and $\ker\pi$, as carried out below.

---

## 3. The centralizer of a regular unipotent

**Theorem 3.1 (Centralizer description).** Let $M \in \mathrm{SL}_2(k)$, i.e. $\det M = 1$. Then
$$M u = u M \iff \big(M_{10} = 0 \ \wedge\ M_{00} = M_{11} \ \wedge\ M_{00}^{\,2} = 1\big).$$
Equivalently, the centralizer of $u$ in $\mathrm{SL}_2$ consists exactly of the matrices $\left(\begin{smallmatrix} a & b \\ 0 & a\end{smallmatrix}\right)$ with $a^2 = 1$ and $b \in k$ arbitrary.

*Proof.* Write $M = \left(\begin{smallmatrix} p & q \\ r & s\end{smallmatrix}\right)$. Direct multiplication gives
$$Mu = \begin{pmatrix} p & p+q \\ r & r+s\end{pmatrix}, \qquad uM = \begin{pmatrix} p+r & q+s \\ r & s\end{pmatrix}.$$
Equating the $(0,0)$ entries: $p = p + r$, so $r = 0$, i.e. $M_{10} = 0$. Equating the $(0,1)$ entries: $p + q = q + s$, so $p = s$, i.e. $M_{00} = M_{11}$. The $(1,\cdot)$ entries give the same relation $r = 0$. Thus commuting forces $M$ upper triangular with constant diagonal $p$. The determinant condition $ps - qr = 1$ becomes $p\cdot p - q\cdot 0 = p^2 = 1$, i.e. $M_{00}^2 = 1$.

Conversely, if $r = 0$, $p = s$, and $p^2 = 1$, a direct entrywise check shows $Mu = uM$: both products equal $\left(\begin{smallmatrix} p & p+q \\ 0 & p\end{smallmatrix}\right)$. $\qquad\blacksquare$

**Remark 3.2 (Regularity).** The centralizer is abelian and one-dimensional: the parameter $b$ ranges over the additive line, while $a$ ranges over the finite scheme $\mu_2$. Its dimension equals the rank of $\mathrm{SL}_2$, which is the defining property of a *regular* element. This is the $\mathrm{SL}_2$ instance of the general fact that regular unipotents have centralizers of minimal dimension.

---

## 4. The center of $\mathrm{SL}_2$

We first isolate a rigidity lemma: commuting with *both* root unipotents forces scalarity.

**Lemma 4.1 (Bi-commuting matrices are scalar).** If $M$ commutes with both $u$ and $l$, then $M = M_{00}\cdot I$.

*Proof.* Commuting with $u$ forces (Theorem 3.1, forward direction, without the determinant step) $M_{10} = 0$ and $M_{00} = M_{11}$. Commuting with $l = \left(\begin{smallmatrix}1&0\\1&1\end{smallmatrix}\right)$ symmetrically forces $M_{01} = 0$. Hence $M$ is diagonal with equal diagonal entries, i.e. $M = M_{00}\cdot I$. Concretely, from $Ml = lM$ the $(0,0)$-entry comparison yields $M_{01} = 0$, and combined with $M_{10}=0$, $M_{00}=M_{11}$ we obtain the scalar. $\qquad\blacksquare$

**Theorem 4.2 (Center of $\mathrm{SL}_2$).** For $M$ a $2\times 2$ matrix over $k$,
$$\Big(\det M = 1 \ \wedge\ \forall N,\ \det N = 1 \Rightarrow MN = NM\Big) \iff \exists a,\ a^2 = 1 \ \wedge\ M = a\cdot I.$$
That is, $Z(\mathrm{SL}_2) = \mu_2$.

*Proof.* ($\Rightarrow$) Since $\det u = \det l = 1$, the hypothesis applies to $N = u$ and $N = l$, so by Lemma 4.1 $M = a\cdot I$ with $a = M_{00}$. Then $\det M = \det(a\cdot I) = a^2$, and $\det M = 1$ gives $a^2 = 1$.

($\Leftarrow$) A scalar matrix $a\cdot I$ commutes with every matrix, and $\det(a\cdot I) = a^2 = 1$. $\qquad\blacksquare$

---

## 5. The kernel of the universal cover

**Theorem 5.1 ($\ker\pi = \mu_2$).** For a $2\times 2$ matrix $M$,
$$M \in \ker\pi \iff \exists a,\ a^2 = 1 \ \wedge\ M = a\cdot I.$$

*Proof.* By Definition 2.4, $M \in \ker\pi$ means $\det M = 1$ and $M = a\cdot I$ for some $a$. Given such $M$, $\det M = a^2 = 1$. Conversely, if $M = a\cdot I$ with $a^2 = 1$ then $\det M = a^2 = 1$, so $M \in \ker\pi$. $\qquad\blacksquare$

**Corollary 5.2 (Cotner–Springer coincidence).** Combining Theorems 4.2 and 5.1,
$$\ker\pi = Z(\mathrm{SL}_2) = \mu_2.$$
For $\mathrm{SL}_2 \to \mathrm{PGL}_2$ the kernel of the cover and the center of the cover coincide. This is what makes $\mathrm{PGL}_2$ the sharpest test case: the stabilizer we compute is simultaneously "the whole center" and "the kernel of $\pi$."

---

## 6. Main theorem: the stabilizer is the kernel

**Theorem 6.1 (Stabilizer of the regular unipotent class equals $\ker\pi$).** Let $\pi\colon \mathrm{SL}_2 \to \mathrm{PGL}_2$ be the universal cover and $u$ the regular unipotent element. The stabilizer of the conjugacy class $C_u$ inside the center $Z(\mathrm{SL}_2)$ equals $\ker\pi = \mu_2$.

*Proof.* Every element $z \in Z(\mathrm{SL}_2)$ is central, so conjugation by $z$ is the identity map; in particular it preserves the class $C_u$. Hence the stabilizer of $C_u$ inside $Z(\mathrm{SL}_2)$ is all of $Z(\mathrm{SL}_2)$. By Corollary 5.2, $Z(\mathrm{SL}_2) = \ker\pi = \mu_2$. Therefore the stabilizer equals $\ker\pi$. $\qquad\blacksquare$

**Remark 6.2 (Scheme-theoretic content).** The statement above is an equality of $k$-points and of group schemes: the identification $Z(\mathrm{SL}_2) = \mu_2$ holds functorially, so the stabilizer *as a group scheme* is $\mu_2 = \operatorname{Spec} k[a]/(a^2 - 1)$. This distinction is the crux of the general theory: for groups where $Z(G') \neq \ker\pi$, the stabilizer under $Z(G')$ is strictly $\ker\pi$ and the discrepancy is invisible on $k$-points, living entirely in the non-reduced (Hopf-algebra) structure. The $\mathrm{PGL}_2$ case is the extreme where $Z(G') = \ker\pi$ so that no discrepancy is possible — and yet, as the next section shows, the scheme is still non-smooth in characteristic $2$.

---

## 7. The étale/infinitesimal dichotomy

The heart of the phenomenon is the arithmetic of the single relation $a^2 = 1$.

**Theorem 7.1 (Point count of $\mu_2$).** Let $k$ be algebraically closed.
- If $\operatorname{char} k \neq 2$, then $\mu_2(k) = \{1, -1\}$ has exactly two distinct elements, and $\mu_2$ is étale (reduced, smooth of dimension $0$).
- If $\operatorname{char} k = 2$, then $a^2 - 1 = (a-1)^2$, so $\mu_2(k) = \{1\}$ has exactly one element, and $\mu_2 = \operatorname{Spec} k[a]/((a-1)^2)$ is infinitesimal (non-reduced), hence non-smooth.

*Proof.* The $k$-points of $\mu_2$ are the roots of $f(a) = a^2 - 1$. If $2 \neq 0$ then $f(a) = (a-1)(a+1)$ with $1 \neq -1$, giving two roots. If $2 = 0$ then $-1 = 1$ and $f(a) = (a-1)^2$, a double root at $a = 1$; the coordinate ring $k[a]/(a^2-1) = k[a]/((a-1)^2)$ has a nonzero nilpotent $t := a-1$ with $t^2 = 0$, so it is non-reduced. A finite group scheme over a field is étale iff its coordinate ring is reduced (separable), which holds iff the characteristic does not divide its order; here the order is $2$. $\qquad\blacksquare$

**Corollary 7.2 (Non-smoothness of the stabilizer).** The stabilizer of the regular unipotent class under the center of $\mathrm{SL}_2$ is smooth (étale) if and only if $\operatorname{char} k \neq 2$; in characteristic $2$ it is a non-reduced group scheme of length $2$ supported at a single point.

**Remark 7.3 (The load-bearing identity).** The entire smoothness dichotomy is carried by the single algebraic identity
$$a^2 = 1 \iff (a-1)^2 = 0 \quad (\text{in characteristic } 2),$$
which pinpoints the nilpotent $t = a - 1$ responsible for the hidden length. This is the elementary shadow of the general mechanism $x^p = 1 \iff (x-1)^p = 0$ in characteristic $p$.

---

## 8. Algorithms

The proofs are constructive and translate directly into decision procedures over any explicit field.

**Algorithm 8.1 (Centralizer membership test).** *Input:* a matrix $M$ over $k$. *Output:* whether $M \in Z_{\mathrm{SL}_2}(u)$. Verify $\det M = 1$; then check $M_{10} = 0$, $M_{00} = M_{11}$, and $M_{00}^2 = 1$. Return the conjunction. Complexity: $O(1)$ field operations.

**Algorithm 8.2 (Center / kernel membership test).** *Input:* a matrix $M$. *Output:* whether $M \in Z(\mathrm{SL}_2) = \ker\pi$. Check that $M$ is scalar ($M_{01} = M_{10} = 0$, $M_{00} = M_{11}$) and $M_{00}^2 = 1$. Complexity: $O(1)$.

**Algorithm 8.3 (Étale/infinitesimal classifier).** *Input:* the characteristic $p$ of $k$ (or $0$). *Output:* the structure type of $\mu_2$. Return "étale, 2 points" if $p \neq 2$; return "infinitesimal, 1 fat point, length 2" if $p = 2$. This is the numerical invariant distinguishing the two regimes.

---

## 9. Applications and interpretation

1. **A unipotent Steinberg theorem.** Steinberg's description of central stabilizers for regular semisimple elements is here mirrored at the regular unipotent extreme, supporting a *unified stabilizer law*: for every regular element, the stabilizer under the center equals $\ker\pi$.

2. **Diagnosing bad characteristic.** The result gives a clean, computable criterion for when the stabilizer fails to be smooth — precisely when the characteristic divides the order of the fundamental group. This is a template for reading off pathologies in positive characteristic from a single divisibility condition.

3. **Model for non-reduced group schemes.** The characteristic-$2$ degeneration of $\mu_2$ is the smallest laboratory example of an infinitesimal group scheme arising naturally as a stabilizer, and thus a pedagogical gateway to Frobenius kernels and the geometry of non-reduced groups.

---

## 10. Discussion and future work

The $\mathrm{SL}_2 \to \mathrm{PGL}_2$ computation isolates, in fully explicit form, three features expected to persist in general reductive groups: (i) the stabilizer of a regular class under the center is the kernel of the simply connected cover; (ii) this kernel is the algebraic fundamental group; and (iii) its smoothness is governed by whether the characteristic divides $|\pi_1(G)|$. The one feature the point-set model cannot see directly — that for $Z(G') \neq \ker\pi$ the stabilizer is strictly $\ker\pi$ — requires the scheme-theoretic (Hopf-algebra) language and is recorded as the primary generalization.

Several precise directions follow:

- **Length as the invisible invariant.** For a regular unipotent in a simply connected group of type $A_{p-1}$ in characteristic $p$, the central stabilizer should have a single geometric point but scheme-theoretic length $p$, with coordinate ring $k[t]/(t^p)$; the point count collapses to $1$ while the length records the full center that has gone infinitesimal.

- **A characteristic-jump formula.** The stabilizer should be smooth exactly in characteristics not dividing $|\pi_1(G)|$; in dividing characteristics it should lose dimension equal to the $p$-torsion of $\pi_1(G)$.

- **A unified regular stabilizer law.** The equality "stabilizer $=\ker\pi$" should hold uniformly across the regular locus — semisimple, unipotent, and mixed — and fail for non-regular elements, whose centralizers are strictly larger.

- **Frobenius kernels as the universal source.** Every non-reduced stabilizer of a regular class in characteristic $p$ should be canonically an extension of an étale group by a Frobenius kernel of the center.

---

## 11. Conclusion

For the universal cover $\pi\colon \mathrm{SL}_2 \to \mathrm{PGL}_2$, the stabilizer of the regular unipotent conjugacy class under the center of $\mathrm{SL}_2$ is exactly $\ker\pi = \mu_2$, characteristic-free. This kernel is étale with two points when $\operatorname{char} k \neq 2$ and infinitesimal with a single fat point when $\operatorname{char} k = 2$, the transition carried entirely by the identity $a^2 = 1 \iff (a-1)^2 = 0$. The computation is a minimal, complete model of the general principle that the smoothness of central stabilizers of regular classes is an arithmetic property of the fundamental group, and that a symmetry group can retain its full algebraic weight while collapsing to a single point.
