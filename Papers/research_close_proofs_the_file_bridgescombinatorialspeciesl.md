# The Exponential Generating Function as a Homotopy Cardinality

## Abstract

The exponential generating function (EGF) of a labelled combinatorial structure is the formal
power series $\sum_n (a_n/n!)X^n$, where $a_n$ counts the structures on $n$ labels. The division
by $n!$ is traditionally presented as a normalization that makes the algebra of generating
functions multiplicative. We give the conceptually correct account: the coefficient $a_n/n!$ is
the **homotopy (groupoid) cardinality** of the action groupoid $F[n]/\!\!/S_n$, the homotopy
quotient of the structure set $F[n]$ by the relabelling action of the symmetric group
$S_n = \mathrm{Perm}(\mathrm{Fin}\,n)$. We prove a general orbit-theoretic identity — the
homotopy cardinality of any finite action groupoid $X/\!\!/G$ equals the naïve ratio $|X|/|G|$ —
and specialize it to relabelling actions to obtain the central bridge theorem
$[X^n]\,\mathrm{EGF}(F) = |F[n]/\!\!/S_n|$. We read off the two emblematic computations: the
species of sets $E$ has $|E[n]/\!\!/S_n| = 1/n!$ (a single structure with full symmetry $S_n$),
recovering $\mathrm{EGF}(E) = \exp$; the species of linear orders $L$ has $|L[n]/\!\!/S_n| = 1$
(the relabelling action is a torsor: free and transitive, hence the homotopy quotient is
contractible), recovering $\mathrm{EGF}(L) = 1/(1-X)$. All results are formalized over $\mathbb{Q}$
and rest only on the orbit–stabilizer theorem and the orbit decomposition. This places the
$1/n!$ of every exponential generating function on a homotopy-theoretic footing and exhibits the
EGF as the homotopy-cardinality generating function of Joyal's analytic-functor theory.

**Keywords.** combinatorial species, exponential generating function, homotopy cardinality,
groupoid cardinality, action groupoid, orbit–stabilizer, torsor, analytic functor.

---

## 1. Introduction

### 1.1 The dividing factorial

Two devices encode an integer sequence $(a_n)_{n\ge 0}$ as a single power series. The *ordinary*
generating function $\sum_n a_n X^n$ is appropriate to unlabelled enumeration, where the product
of series is the ordinary Cauchy convolution $(a*b)_n = \sum_{i+j=n} a_i b_j$. The *exponential*
generating function

$$ \mathrm{EGF}(a) \;=\; \sum_{n\ge 0} \frac{a_n}{n!}\,X^n $$

is appropriate to *labelled* enumeration, where the natural product is the **binomial (exponential)
convolution**

$$ (a \star b)_n \;=\; \sum_{i+j=n} \binom{n}{i}\, a_i\, b_j, $$

reflecting the $\binom{n}{i}$ ways to distribute $n$ labels between an $i$-labelled and a
$j$-labelled component. The EGF intertwines these: $\mathrm{EGF}(a\star b) = \mathrm{EGF}(a)\cdot
\mathrm{EGF}(b)$, the Cauchy product of power series. The factorial denominators are exactly what
makes this work, and they are usually justified on those grounds — as a normalization.

### 1.2 Thesis

This paper argues that the factorial denominators are not a normalization but a *measurement of
symmetry*. The precise statement is that $a_n/n! = |F[n]|/n!$ is the homotopy cardinality of the
groupoid of $F$-structures up to relabelling. We make this rigorous through three layers:

1. A general theorem on finite group actions (Section 3): the homotopy cardinality of an action
   groupoid $X/\!\!/G$ is $|X|/|G|$.
2. Its specialization to the relabelling action of $S_n$ (Section 4): $|F[n]/\!\!/S_n| =
   |F[n]|/n!$, hence the EGF coefficient *is* the homotopy cardinality.
3. The two emblematic species (Section 5): sets (full symmetry, $1/n!$, giving $\exp$) and linear
   orders (torsor, $1$, giving $1/(1-X)$).

This sits on top of an existing algebraic bridge in which the EGF $\mathrm{egf} : (\mathbb{N}\to
\mathbb{Q}) \to \mathbb{Q}\llbracket X\rrbracket$ is a ring isomorphism carrying binomial
convolution to the Cauchy product, disjoint union to addition, differentiation to $d/dX$, and
pointing to $X\,d/dX$. The present contribution supplies the *homotopical* reading of the same
data.

---

## 2. Background and definitions

### 2.1 Species in skeletal form

We model a combinatorial species as a functor from the groupoid of finite sets to finite sets,
presented skeletally.

> **Definition 2.1 (Species).** A *species* $F$ consists of:
> - a family of types $\mathrm{obj} : \mathbb{N} \to \mathrm{Type}$, where $F[n] := \mathrm{obj}(n)$
>   is the set of $F$-structures on a fixed $n$-element label set;
> - a proof that each $F[n]$ is finite;
> - a *relabelling action*, i.e. for each $n$ a group homomorphism
>   $$ \mathrm{act}(n) : \mathrm{Perm}(\mathrm{Fin}\,n) \longrightarrow \mathrm{Perm}(F[n]), $$
>   encoding functoriality on the core groupoid of finite sets.

The associated **counting sequence** is $\mathrm{coeffSeq}(F)(n) := |F[n]|$ (the cardinality of
$F[n]$), and the **exponential generating function** is

$$ \mathrm{EGF}(F) \;:=\; \sum_{n\ge 0} \frac{|F[n]|}{n!}\,X^n \;\in\; \mathbb{Q}\llbracket X\rrbracket. $$

> **Definition 2.2 (The two running species).**
> - The *species of sets* $E$: $E[n] = \mathbf{1}$ (a one-element type) for all $n$, with the
>   trivial relabelling action. So $|E[n]| = 1$.
> - The *species of linear orders* $L$: $L[n] = \mathrm{Perm}(\mathrm{Fin}\,n)$ (a linear order
>   on $n$ labels is a bijection with $\{1,\dots,n\}$), with the regular relabelling action
>   $\mathrm{act}(n) = $ left translation. So $|L[n]| = n!$.

### 2.2 Action groupoids and homotopy cardinality

Let a finite group $G$ act on a finite set $X$. The **action groupoid** $X/\!\!/G$ has objects
the elements of $X$ and a morphism $x \to gx$ for each $g\in G$. Its isomorphism classes are the
*orbits* of the action, and the automorphism group of an object $x$ is its *stabilizer*
$\mathrm{Stab}(x) = \{g : gx = x\}$.

> **Definition 2.3 (Homotopy / groupoid cardinality).** For a finite groupoid $\mathcal{G}$ with
> isomorphism classes $[x] \in \pi_0\mathcal{G}$,
> $$ |\mathcal{G}| \;:=\; \sum_{[x] \in \pi_0\mathcal{G}} \frac{1}{|\mathrm{Aut}(x)|} \;\in\; \mathbb{Q}. $$
> For an action groupoid this reads
> $$ \big| X/\!\!/G \big| \;=\; \sum_{\text{orbits } \omega} \frac{1}{|\mathrm{Stab}(\omega)|}, $$
> the sum over orbits of the reciprocal stabilizer order (the stabilizer being well-defined up to
> conjugacy on each orbit, so its order is constant along the orbit).

We will treat $X = F[n]$ with $G = S_n = \mathrm{Perm}(\mathrm{Fin}\,n)$, acting via
$\mathrm{act}(n)$; the action groupoid $F[n]/\!\!/S_n$ is the *groupoid of $F$-structures up to
relabelling*.

### 2.3 The tools we depend on

Two classical facts carry the whole argument.

- **Orbit–stabilizer.** For $x \in X$, $|\mathrm{orbit}(x)| \cdot |\mathrm{Stab}(x)| = |G|$.
- **Orbit decomposition.** $X \simeq \bigsqcup_{\omega}\mathrm{orbit}(\omega)$, a bijection
  between $X$ and the disjoint union of its orbits; consequently $|X| = \sum_\omega
  |\mathrm{orbit}(\omega)|$.

---

## 3. Homotopy cardinality of an action groupoid

> **Theorem 3.1 (Action-groupoid cardinality).** Let $G$ be a finite group acting on a finite set
> $X$. Then
> $$ \sum_{\text{orbits } \omega} \frac{1}{|\mathrm{Stab}(\omega)|} \;=\; \frac{|X|}{|G|} \qquad\text{in } \mathbb{Q}. $$
> Equivalently, $|X/\!\!/G| = |X|/|G|$.

*Proof sketch.* Work in $\mathbb{Q}$. By the orbit decomposition we write the numerator as a sum
over orbits,
$$ |X| \;=\; \sum_{\omega} |\mathrm{orbit}(\omega)|, \qquad\text{hence}\qquad
   \frac{|X|}{|G|} \;=\; \sum_{\omega} \frac{|\mathrm{orbit}(\omega)|}{|G|}. $$
It therefore suffices to prove the per-orbit identity
$$ \frac{1}{|\mathrm{Stab}(\omega)|} \;=\; \frac{|\mathrm{orbit}(\omega)|}{|G|}. $$
Cross-multiplying, this is $|G| = |\mathrm{orbit}(\omega)| \cdot |\mathrm{Stab}(\omega)|$, which
is precisely the orbit–stabilizer theorem applied to a representative of $\omega$. Both
denominators are positive integers (orders of finite groups), so the division is valid in
$\mathbb{Q}$ and the casts are unproblematic. $\qquad\blacksquare$

*Remarks on the formalization.* The result is proved with $G$ and $X$ generic finite types
carrying a `MulAction`. The orbit decomposition is the equivalence $X \simeq
\Sigma_\omega\,\mathrm{orbit}(\omega)$; passing to cardinalities and casting to $\mathbb{Q}$ gives
the numerator identity. The per-orbit step is the orbit–stabilizer count
$|\mathrm{orbit}|\cdot|\mathrm{Stab}| = |G|$, rearranged by the cross-multiplication lemma
$\frac{a}{b} = \frac{c}{d} \iff a d = c b$ (with both denominators nonzero), then discharged by
casting the natural-number identity. A `Fintype` instance for each orbit is supplied
noncomputably from finiteness. This is the homotopy-theoretic refinement of orbit counting: the
$1/|\mathrm{Stab}|$ weighting is *exactly* homotopy cardinality, and the theorem says it
reassembles the clean ratio $|X|/|G|$.

---

## 4. The action groupoid of a species

> **Definition 4.1 (Relabelling action of a species).** For a species $F$ and $n\in\mathbb{N}$,
> the relabelling action of $S_n = \mathrm{Perm}(\mathrm{Fin}\,n)$ on $F[n]$ is the `MulAction`
> obtained by pulling back the canonical action of $\mathrm{Perm}(F[n])$ along the functoriality
> homomorphism $\mathrm{act}(n) : S_n \to \mathrm{Perm}(F[n])$.

> **Definition 4.2 (Action-groupoid cardinality of a species).**
> $$ \mathrm{actionGroupoidCard}(F)(n) \;:=\; \big| F[n]/\!\!/S_n \big|
>    \;=\; \sum_{\text{orbits }\omega} \frac{1}{|\mathrm{Stab}_{S_n}(\omega)|} \;\in\; \mathbb{Q}, $$
> the homotopy cardinality of the relabelling action groupoid — the homotopy-theoretic count of
> $F$-structures on $n$ labels up to relabelling.

> **Theorem 4.3 (Species action-groupoid cardinality).** For every species $F$ and every $n$,
> $$ \big| F[n]/\!\!/S_n \big| \;=\; \frac{|F[n]|}{n!}. $$

*Proof sketch.* This is Theorem 3.1 specialized to $G = S_n = \mathrm{Perm}(\mathrm{Fin}\,n)$ and
$X = F[n]$, using $|S_n| = |\mathrm{Perm}(\mathrm{Fin}\,n)| = (\mathrm{Fin}\,n)!\,= n!$. The only
care needed in formalization is that the `Fintype` instances chosen in the definition of
$\mathrm{actionGroupoidCard}$ are the same (definitionally) as those used by Theorem 3.1, so the
rewrite matches; this is arranged by re-establishing the instances in the proof. $\qquad\blacksquare$

> **Theorem 4.4 (The EGF coefficient is a homotopy cardinality — central bridge).** For every
> species $F$ and every $n$,
> $$ [X^n]\,\mathrm{EGF}(F) \;=\; \frac{|F[n]|}{n!} \;=\; \big| F[n]/\!\!/S_n \big|. $$

*Proof sketch.* By definition $[X^n]\,\mathrm{EGF}(F) = |F[n]|/n!$ (the $n$-th coefficient of
$\sum_n (|F[n]|/n!)X^n$), and by Theorem 4.3 this equals $|F[n]/\!\!/S_n|$. $\qquad\blacksquare$

Theorem 4.4 is the conceptual heart: the exponential generating function is the
*homotopy-cardinality generating function*. The $1/n!$ in the $n$-th coefficient is the
reciprocal order of the symmetry group $S_n$ being homotopy-quotiented, not an arbitrary
normalization. Joyal's analytic functor literally counts structures up to relabelling, weighting
each isomorphism class by the reciprocal of its automorphism group.

---

## 5. Two emblematic homotopy cardinalities

### 5.1 The species of sets: full symmetry

> **Theorem 5.1 (Sets have homotopy cardinality $1/n!$).** For the species of sets $E$,
> $$ \big| E[n]/\!\!/S_n \big| \;=\; \frac{1}{n!}, \qquad\text{and consequently}\qquad
>    \mathrm{EGF}(E) \;=\; \exp \;=\; \sum_{n\ge0}\frac{1}{n!}X^n. $$

*Proof sketch.* $E[n]$ has a single element, so $|E[n]| = 1$ and Theorem 4.3 gives
$|E[n]/\!\!/S_n| = 1/n!$. Structurally: there is exactly one orbit, and *every* permutation in
$S_n$ fixes the unique structure, so the stabilizer is all of $S_n$ — the lone isomorphism class
carries the full symmetry group $S_n$ as its automorphisms, giving symmetry discount $1/|S_n| =
1/n!$. Summing over $n$ yields the power series of $\exp$, matching the algebraic identity
$\mathrm{EGF}(E) = \exp$. $\qquad\blacksquare$

### 5.2 The species of linear orders: a torsor

> **Theorem 5.2 (Linear orders have homotopy cardinality $1$).** For the species of linear orders
> $L$,
> $$ \big| L[n]/\!\!/S_n \big| \;=\; 1, \qquad\text{and consequently}\qquad
>    (1 - X)\cdot \mathrm{EGF}(L) = 1, \quad\text{i.e.}\quad \mathrm{EGF}(L) = \frac{1}{1-X}. $$

*Proof sketch.* $L[n] = \mathrm{Perm}(\mathrm{Fin}\,n)$ has $n!$ elements, so Theorem 4.3 gives
$|L[n]/\!\!/S_n| = n!/n! = 1$. Structurally: the regular relabelling action is *free and
transitive*, i.e. $L[n]$ is a **torsor** for $S_n$. Transitivity means a single orbit;
freeness means each stabilizer is trivial. The action groupoid is thus a single point with no
nontrivial automorphisms — "contractible" — of homotopy cardinality $1/1 = 1$. Summing the
constant $1$ over $n$ gives the geometric series $\sum_n X^n = 1/(1-X)$, matching the algebraic
identity $(1-X)\cdot\mathrm{EGF}(L) = 1$. $\qquad\blacksquare$

### 5.3 The symmetry spectrum

Sets and orderings are the two poles of a single spectrum. On $n$ labels both involve the same
group $S_n$, but:

| Species | $|F[n]|$ | # orbits | $|\mathrm{Stab}|$ | $|F[n]/\!\!/S_n|$ | EGF |
|---|---|---|---|---|---|
| Sets $E$ | $1$ | $1$ | $n!$ (full) | $1/n!$ | $\exp X$ |
| Linear orders $L$ | $n!$ | $1$ | $1$ (trivial) | $1$ | $1/(1-X)$ |

Maximal symmetry produces the exponential; maximal rigidity produces the geometric series. The
two most important elementary power series are the extreme cases of the homotopy-cardinality
construction.

---

## 6. Algorithms

The bridge theorems are constructive enough to compute with directly. The following algorithms
underlie the numerical demonstrations.

### 6.1 Homotopy cardinality of an action groupoid by orbit enumeration

Given a finite group $G$ (as a set of permutations) acting on a finite set $X$, partition $X$
into orbits, compute the stabilizer order of one representative per orbit, and sum the
reciprocals. By Theorem 3.1 the result must equal the exact rational $|X|/|G|$, which provides a
built-in correctness check.

Complexity: $O(|G|\cdot|X|)$ to compute the orbit partition (apply every group element to every
point), plus $O(|G|)$ per representative for the stabilizer. Overall $O(|G|\cdot|X|)$.

### 6.2 EGF coefficients from homotopy cardinalities

Given a species presented operationally (a function returning $F[n]$ together with the
relabelling action), compute $|F[n]/\!\!/S_n|$ by Algorithm 6.1 with $G = S_n$, and assemble the
EGF $\sum_n |F[n]/\!\!/S_n|\,X^n$. By Theorem 4.4 the coefficients coincide with $|F[n]|/n!$.

---

## 7. Applications and connections

The identification of the EGF coefficient with a homotopy cardinality is the rational-valued
shadow of a deeper categorical statement, and connects the elementary algebra of generating
functions to several active areas.

- **Symmetric monoidal functoriality.** Homotopy cardinality is additive over disjoint unions of
  groupoids and multiplicative over products. The disjoint union of species (sum) and the
  Day-convolution product of species ($(F\cdot G)[n] = \sum_{S\subseteq[n]}F[S]\times G[n\setminus
  S]$) therefore map to $+$ and $\times$ of EGFs. The companion development shows the EGF is in
  fact a ring isomorphism $(\mathbb{N}\to\mathbb{Q},\star)\cong\mathbb{Q}\llbracket X\rrbracket$.
  Theorems 4.3–4.4 explain *why*: the EGF is the homotopy cardinality, and homotopy cardinality
  is a symmetric monoidal functor from finite groupoids to $\mathbb{Q}$.
- **Stacks and orbifold Euler characteristics.** In algebraic geometry, quotient stacks
  $[X/G]$ are measured by exactly this weighted count; moduli of objects-with-automorphisms are
  counted "up to isomorphism, divided by automorphisms."
- **Gauge theory.** Path integrals over field configurations divide by the volume of the gauge
  group — the continuous analogue of weighting by $1/|\mathrm{Aut}|$.
- **The mass formula.** The Smith–Minkowski–Siegel mass of a genus of quadratic forms is a sum
  of $1/|\mathrm{Aut}|$ over isomorphism classes: a homotopy cardinality of the groupoid of forms.

In each, the principle distilled here governs the count: symmetric objects are discounted by the
reciprocal order of their symmetry group.

---

## 8. Discussion

The result is deliberately elementary in its dependencies — orbit–stabilizer and the orbit
decomposition — yet it reorganizes a familiar object. The pedagogical payoff is direct: the
factorials in exponential generating functions are no longer "magic," but the visible imprint of
the symmetric group. The structural payoff is that the algebraic laws of EGFs (additivity,
multiplicativity, the derivative and pointing operators) are recognized as instances of the
functoriality of homotopy cardinality, which is why they hold uniformly.

A subtlety worth flagging: homotopy cardinality is genuinely rational-valued, not integer-valued.
The species of sets contributes $1/n!$ — a fractional "number of structures." This is not a
defect; it is the correct count in a world where objects come with symmetry, and it is what makes
the generating function exponential rather than ordinary.

---

## 9. Future directions

(See the dedicated future-directions section accompanying this package for the full programme;
the headline conjecture is that homotopy cardinality is multiplicative under products of action
groupoids, $|(F\cdot G)[n]/\!\!/S_n| = \sum_{i+j=n}|F[i]/\!\!/S_i|\cdot|G[j]/\!\!/S_j|$, exhibiting
the EGF product law as the shadow of categorical multiplicativity, together with derivative,
pointing, and species-composition refinements.)

---

## 10. Conclusion

We have shown that the $n$-th coefficient of the exponential generating function of a species is
the homotopy cardinality of the action groupoid $F[n]/\!\!/S_n$:
$$ [X^n]\,\mathrm{EGF}(F) = \frac{|F[n]|}{n!} = \big|F[n]/\!\!/S_n\big| = \sum_{[x]}\frac{1}{|\mathrm{Aut}(x)|}. $$
The general engine is the action-groupoid identity $|X/\!\!/G| = |X|/|G|$, and the two emblematic
species — sets (full symmetry, $\exp$) and linear orders (torsor, $1/(1-X)$) — display the
construction at its two extremes. The dividing factorial of the EGF is the reciprocal order of
the symmetry group being homotopy-quotiented: symmetry, made visible.
