# Knots and Lattices: The Alexander Polynomial as a Signed, Not Unsigned, Lattice Enumeration

## Abstract

The Alexander polynomial $\Delta_K(t)$ is a classical Laurent-polynomial invariant of a knot $K$, and its state-sum formula superficially resembles an area generating function for lattice paths. This suggests a bold conjecture: that every Alexander polynomial is the *unsigned* generating function $\sum_p t^{\operatorname{area}(p)}$ of a family of monotone lattice paths. We settle this conjecture in the negative in the strongest possible form. Representing Laurent polynomials by their integer coefficient functions, we prove that the reduced Alexander polynomial of the trefoil, $t - 1 + t^{-1}$, cannot equal the unsigned area generating function of *any* finite state set under *any* integer area statistic, because the coefficient of $t^0$ is $-1$ while any unsigned generating function has non-negative coefficients. We then show that the *signed* state sum $\sum_s (-1)^{w(s)} t^{a(s)}$ — the genuine Alexander state-sum formula — recovers the polynomial from three states, isolating the sign group as the sole obstruction. Finally, we identify the combinatorial origin of Alexander reciprocity $\Delta_K(t) = \Delta_K(t^{-1})$: any area-negating, sign-preserving involution of the state set forces the signed state sum to be palindromic, and the trefoil carries such an involution explicitly. On the combinatorial side we record that monotone paths from $(0,0)$ to $(n,n)$ are exactly the $n$-subsets of a $2n$-element set, so their number is $\binom{2n}{n}$ and the Kruskal–Katona theorem yields a shadow lower bound on any family of paths. Together these results replace a false identification with a precise structural picture: the correct combinatorial model of the Alexander polynomial is a signed state sum whose reciprocity is an involutive fixed-point phenomenon.

## 1. Introduction

Knot invariants translate a topological question — are two embedded circles isotopic? — into algebra. The **Alexander polynomial** $\Delta_K(t) \in \mathbb{Z}[t, t^{-1}]$, introduced in 1928, is the earliest such polynomial invariant. It is defined only up to multiplication by $\pm t^k$; a *reduced* representative is chosen to make it symmetric under $t \mapsto t^{-1}$. Two standard examples anchor everything below:

$$\Delta_{\text{unknot}}(t) = 1, \qquad \Delta_{\text{trefoil}}(t) = t - 1 + t^{-1}.$$

Since these differ, the trefoil is not the unknot.

Among the many faces of $\Delta_K$ is a **state-sum** description. One resolves each crossing of a knot diagram into a local configuration; a global choice of configurations is a *state* $s$, carrying an integer *area* $a(s)$ and an integer *writhe* $w(s)$. Then

$$\Delta_K(t) = \sum_{\text{states } s} (-1)^{w(s)}\, t^{a(s)}. \tag{$\ast$}$$

Formula $(\ast)$ looks strikingly like an area generating function for lattice paths, and this resemblance motivates a strong conjecture: that the sign can be dispensed with and each $\Delta_K$ realized as an *unsigned* count

$$\sum_{p \in L_K} t^{\operatorname{area}(p)} \tag{unsigned}$$

over a "knot lattice" $L_K$ of monotone paths.

**Contributions.** This paper settles the unsigned conjecture and clarifies the correct model.

1. *(Refutation, §4.)* We prove that no unsigned area generating function — over any finite state set, under any integer area statistic — equals $t - 1 + t^{-1}$. The obstruction is a single negative coefficient.
2. *(Rescue, §5.)* We prove that the signed state sum $(\ast)$ realizes the trefoil polynomial from three explicit states, so the sign group is exactly the missing ingredient.
3. *(Reciprocity, §6.)* We prove that an area-negating, sign-preserving involution of a state set forces the signed state sum to be palindromic, giving a combinatorial mechanism for $\Delta_K(t) = \Delta_K(t^{-1})$, and exhibit the trefoil's involution.
4. *(Substrate, §7.)* We record the exact bijection between monotone paths to $(n,n)$ and $n$-subsets of a $2n$-set, giving the count $\binom{2n}{n}$, and derive from Kruskal–Katona a shadow lower bound for any family of such paths.

## 2. Preliminaries: coefficient functions

We represent a Laurent polynomial $\sum_k c_k t^k$ by its **coefficient function** $c : \mathbb{Z} \to \mathbb{Z}$, where $c(k)$ is the coefficient of $t^k$ (only finitely many nonzero). This lets us reason about generating functions and state sums uniformly, without committing to a polynomial data structure.

**Definition 2.1 (Non-negative coefficients).** A coefficient function $c : \mathbb{Z} \to \mathbb{Z}$ is *non-negative*, written $\mathrm{Nonneg}(c)$, if $c(k) \ge 0$ for all $k \in \mathbb{Z}$.

**Definition 2.2 (Palindromic).** A coefficient function $c$ is *palindromic* if $c(k) = c(-k)$ for all $k \in \mathbb{Z}$. This is precisely the reciprocity $\Delta_K(t) = \Delta_K(t^{-1})$ at the level of coefficients.

**Definition 2.3 (Reduced Alexander polynomial of the trefoil).** Let $\tau : \mathbb{Z} \to \mathbb{Z}$ be
$$\tau(k) = \begin{cases} 1 & k = 1 \text{ or } k = -1,\\ -1 & k = 0,\\ 0 & \text{otherwise.}\end{cases}$$
This is the coefficient function of $t - 1 + t^{-1}$. In particular $\tau(0) = -1$, $\tau(1) = \tau(-1) = 1$.

## 3. The two enumeration models

Fix an index type $\iota$ with decidable equality, a finite set of states $\mathrm{states} \subseteq \iota$, and an integer *area* statistic $a : \iota \to \mathbb{Z}$.

**Definition 3.1 (Unsigned area generating function).** The *unsigned* generating function $\mathrm{areaGF}(\mathrm{states}, a) : \mathbb{Z} \to \mathbb{Z}$ is
$$\mathrm{areaGF}(\mathrm{states}, a)(k) = \#\{\, s \in \mathrm{states} : a(s) = k \,\},$$
the number of states of area $k$. Its coefficient of $t^k$ is a cardinality.

**Definition 3.2 (Signed state sum).** Given additionally a *sign* function $\mathrm{sign} : \iota \to \mathbb{Z}$ (intended values $\pm 1$, modeling $(-1)^{w(s)}$), the *signed* state sum $\mathrm{signedGF}(\mathrm{states}, \mathrm{sign}, a) : \mathbb{Z} \to \mathbb{Z}$ is
$$\mathrm{signedGF}(\mathrm{states}, \mathrm{sign}, a)(k) = \sum_{\substack{s \in \mathrm{states} \\ a(s) = k}} \mathrm{sign}(s).$$
This is the coefficient-function form of $(\ast)$: setting $\mathrm{sign}(s) = (-1)^{w(s)}$ recovers the Alexander state sum.

The unsigned model is the special case $\mathrm{sign} \equiv 1$, but with the crucial structural difference recorded next.

## 4. Refutation of the unsigned conjecture

**Lemma 4.1 (Unsigned generating functions are non-negative).** For every finite $\mathrm{states}$ and every $a$, the coefficient function $\mathrm{areaGF}(\mathrm{states}, a)$ is non-negative.

*Proof.* Each coefficient is the cardinality of a finite set, hence a non-negative integer. $\qquad\blacksquare$

**Theorem 4.2 (Refutation).** For every index type $\iota$, every finite state set $\mathrm{states} \subseteq \iota$, and every integer area statistic $a : \iota \to \mathbb{Z}$,
$$\mathrm{areaGF}(\mathrm{states}, a) \ne \tau.$$
That is, the reduced Alexander polynomial of the trefoil is not the unsigned area generating function of any state family under any area statistic.

*Proof.* Suppose, for contradiction, that $\mathrm{areaGF}(\mathrm{states}, a) = \tau$. Evaluating at $k = 0$ gives $\mathrm{areaGF}(\mathrm{states}, a)(0) = \tau(0) = -1$. But by Lemma 4.1, $\mathrm{areaGF}(\mathrm{states}, a)(0) \ge 0$. Hence $-1 \ge 0$, a contradiction. $\qquad\blacksquare$

The strength of Theorem 4.2 lies in its quantifiers: it is not the failure of one candidate lattice but a universal impossibility. Any unsigned model is a count, a count is non-negative, and $\tau(0) = -1$; no cleverness in choosing states or defining area can bridge that gap. The literal conjecture "every Alexander polynomial is an unsigned lattice-path generating function" is therefore false, refuted already by the simplest nontrivial knot.

## 5. The signed rescue

**Theorem 5.1 (Signed realization of the trefoil).** There exist a finite state set and functions $\mathrm{sign}, a$ such that
$$\mathrm{signedGF}(\mathrm{states}, \mathrm{sign}, a) = \tau.$$
Explicitly, take three states with areas $(a_0, a_1, a_2) = (1, 0, -1)$ and signs $(\mathrm{sign}_0, \mathrm{sign}_1, \mathrm{sign}_2) = (+1, -1, +1)$.

*Proof.* With the stated data, the states of area $1$, $0$, $-1$ are the singletons $\{0\}, \{1\}, \{2\}$ with signs $+1, -1, +1$, and every other area class is empty. Hence the signed sum has coefficients $\mathrm{signedGF}(1) = 1$, $\mathrm{signedGF}(0) = -1$, $\mathrm{signedGF}(-1) = 1$, and $0$ elsewhere, which is exactly $\tau$. $\qquad\blacksquare$

Comparing Theorems 4.2 and 5.1, the *same* polynomial is unreachable by unsigned enumeration yet reachable by signed enumeration over just three states. The obstruction is thus localized precisely to the sign group: the unsigned model lives in $\mathbb{Z}_{\ge 0}$, whereas the Alexander polynomial requires cancellation in $\mathbb{Z}$. The sign $(-1)^{w(s)}$ in $(\ast)$ is not incidental; it is the defining feature the naive conjecture discards.

## 6. Reciprocity as an involutive symmetry

Alexander polynomials satisfy the reciprocity $\Delta_K(t) = \Delta_K(t^{-1})$. We give this symmetry a purely combinatorial explanation at the level of signed state sums.

**Theorem 6.1 (Reciprocity from an involution).** Let $\mathrm{states} \subseteq \iota$ be finite with sign and area functions $\mathrm{sign}, a$. Suppose $\varphi : \iota \to \iota$ restricts to a map of $\mathrm{states}$ to itself satisfying, for all $s \in \mathrm{states}$:
- **(involution)** $\varphi(\varphi(s)) = s$;
- **(area-negating)** $a(\varphi(s)) = -\,a(s)$;
- **(sign-preserving)** $\mathrm{sign}(\varphi(s)) = \mathrm{sign}(s)$.

Then $\mathrm{signedGF}(\mathrm{states}, \mathrm{sign}, a)$ is palindromic:
$$\mathrm{signedGF}(k) = \mathrm{signedGF}(-k) \quad \text{for all } k.$$

*Proof.* Fix $k$. The map $\varphi$ is a bijection from the fiber $\{s \in \mathrm{states} : a(s) = k\}$ to the fiber $\{s \in \mathrm{states} : a(s) = -k\}$: it lands in the target fiber because $a(\varphi(s)) = -a(s) = -k$; it is injective (indeed involutive), being its own two-sided inverse on $\mathrm{states}$; and it is surjective because any $s'$ with $a(s') = -k$ is the image of $\varphi(s')$, which has area $k$. Since $\varphi$ preserves sign, it matches summands one-to-one:
$$\mathrm{signedGF}(k) = \sum_{a(s)=k} \mathrm{sign}(s) = \sum_{a(s)=k} \mathrm{sign}(\varphi(s)) = \sum_{a(s')=-k} \mathrm{sign}(s') = \mathrm{signedGF}(-k).$$
This is a genuine sign-preserving bijection of fibers, not a numerical coincidence. $\qquad\blacksquare$

**Corollary 6.2 (Closure under sums).** If $c$ and $d$ are palindromic coefficient functions, so is their pointwise sum $k \mapsto c(k) + d(k)$.

*Proof.* Immediate: $(c+d)(k) = c(k) + d(k) = c(-k) + d(-k) = (c+d)(-k)$. $\qquad\blacksquare$

**Proposition 6.3 (The trefoil is palindromic).** The coefficient function $\tau$ satisfies $\tau(k) = \tau(-k)$ for all $k$.

*Proof.* Direct from Definition 2.3: the value depends only on whether $k \in \{1,-1\}$, $k = 0$, or otherwise, each of which is invariant under $k \mapsto -k$. $\qquad\blacksquare$

The three states of Theorem 5.1 carry an involution realizing Theorem 6.1: $\varphi$ fixes the central state (area $0$) and swaps the two outer states (areas $+1$ and $-1$), which have equal sign $+1$. Thus the palindromy of $t - 1 + t^{-1}$ is not an analytic accident but the fixed-point structure of this involution. Reciprocity of the Alexander polynomial is combinatorial cancellation made visible.

## 7. The lattice-path substrate and a Kruskal–Katona shadow bound

Even though unsigned paths do not equal $\Delta_K$, monotone lattice paths form the natural geometric substrate for any state-sum model, and their extremal combinatorics constrain state families.

**Definition 7.1 (Monotone lattice paths).** A monotone lattice path from $(0,0)$ to $(n,n)$ consists of $2n$ unit steps, $n$ East and $n$ North. Recording which of the $2n$ steps are North identifies each path with an $n$-element subset of a $2n$-element set of step slots. We write $\mathrm{latticePaths}(n)$ for the family of all such $n$-subsets.

**Proposition 7.2 (Membership).** A subset $S$ of the $2n$ slots is a monotone path to $(n,n)$ if and only if $|S| = n$.

*Proof.* Immediate from the encoding: an $n$-subset records exactly $n$ North steps, leaving $n$ East steps, so the path terminates at $(n,n)$. $\qquad\blacksquare$

**Theorem 7.3 (Counting paths).** The number of monotone lattice paths from $(0,0)$ to $(n,n)$ is the central binomial coefficient $\binom{2n}{n}$.

*Proof.* By Proposition 7.2 the paths are the $n$-subsets of a $2n$-set, and there are $\binom{2n}{n}$ of these. $\qquad\blacksquare$

Because every path is an $n$-element set, the family $\mathrm{latticePaths}(n)$ and each of its sub-families is *$n$-uniform*. This places path families in the domain of the Kruskal–Katona theorem. Recall the *shadow* $\partial \mathcal{A}$ of a family $\mathcal{A}$ of $n$-sets: the family of all $(n-1)$-sets obtained by deleting one element from some member of $\mathcal{A}$. In path language, the shadow is the family of shorter paths obtained by erasing a single North step and pulling the endpoint back toward the diagonal.

**Theorem 7.4 (Shadow lower bound for path families).** Let $\mathcal{A} \subseteq \mathrm{latticePaths}(n)$ be a family of paths to $(n,n)$, and suppose $1 \le n \le k \le 2n$ with
$$\binom{k}{n} \le |\mathcal{A}|.$$
Then the shadow satisfies
$$\binom{k}{n-1} \le |\partial \mathcal{A}|.$$

*Proof.* The family $\mathcal{A}$ is $n$-uniform (Proposition 7.2). Applying the Kruskal–Katona shadow bound to the uniform family $\mathcal{A}$ with the hypotheses $1 \le n \le k \le 2n$ and $\binom{k}{n} \le |\mathcal{A}|$ yields $\binom{k}{n-1} \le |\partial\mathcal{A}|$. $\qquad\blacksquare$

Interpreted through the state sum, Theorem 7.4 says a *dense* family of $n$-step knot states is forced to have a *dense* family of $(n-1)$-step "lower" states: knot complexity, measured through state families, is tethered to hard extremal inequalities. This is the combinatorial shadow of the topological state sum, and a genuine constraint rather than an analogy.

## 8. Algorithms

We summarize the computational content in three procedures.

**Algorithm A (Unsigned positivity test).** Given a target Laurent polynomial as a coefficient map, decide whether it can possibly be an unsigned area generating function by checking non-negativity of all coefficients. If any coefficient is negative, the unsigned model is ruled out (the trefoil fails at $t^0$). Complexity: linear in the number of nonzero coefficients.

**Algorithm B (Signed realization).** Given a target coefficient map $c$, construct a state set realizing it as a signed state sum: for each exponent $k$, emit $|c(k)|$ states of area $k$ with sign $\operatorname{sgn}(c(k))$. This always succeeds and uses $\sum_k |c(k)|$ states. For the trefoil it produces the three-state model of Theorem 5.1.

**Algorithm C (Path enumeration and shadow).** Enumerate monotone paths to $(n,n)$ as $n$-subsets of $2n$ slots, verify the count $\binom{2n}{n}$, compute the shadow of a chosen sub-family by single-element deletions, and check the Kruskal–Katona bound of Theorem 7.4.

## 9. Applications and discussion

**A precise fault line.** The value of this cycle is diagnostic. The unsigned conjecture is *almost* correct; it fails by exactly one structural feature, the sign group. Locating the failure — the difference between counting in $\mathbb{Z}_{\ge 0}$ and canceling in $\mathbb{Z}$ — is more informative than any number of confirmed instances would have been, and it explains *why* the Alexander polynomial can carry more information than a raw count.

**A unification.** Three features of $\Delta_K$ — its state-sum formula, its occasionally negative coefficients, and its unfailing palindromy — are three views of one signed structure. Negativity is why it is not an unsigned count (§4); palindromy is an involutive pairing of signed states (§6); the state sum is the arena in which both live (§5).

**A partial bridge.** Lattice paths are not identified with the Alexander polynomial, but they provide exactly the right ambient combinatorics — uniform families, area statistics, and Kruskal–Katona shadow inequalities (§7) — to constrain state-sum models. Topology and combinatorics remain roped together even though the naive identification fails.

## 10. Future work

Four directions extend the surviving structure.

1. **Sign obstruction as the exact failure of positivity.** Conjecture that an integer Laurent polynomial is an unsigned lattice-path area generating function iff all its coefficients are non-negative, and that every symmetric integer Laurent polynomial with value $\pm 1$ at $t = 1$ arises as a signed state sum. This promotes the specific impossibility of §4 and the specific realization of §5 to exact characterizations.

2. **Involutions as the source of every knot-polynomial symmetry.** Conjecture that every reciprocity symmetry of a knot polynomial (Alexander, Conway, suitably specialized Jones) is induced by an area-negating, weight-preserving involution of a state set, and conversely. Symmetry would then be a fixed-point phenomenon rather than an analytic accident, generalizing §6.

3. **Extremal density of state families.** For knots whose state sets are $n$-uniform families of $n$-subsets of the $2n$ step slots, conjecture that a "dense" family (at least $\binom{k}{n}$ states) has at least $\binom{k}{n-1}$ sub-states, with equality for maximally symmetric (torus-knot) families. This would convert the general shadow bound of §7 into a classification.

4. **The $q$-refinement.** Summing $q^{\operatorname{area}}$ over all monotone paths to $(n,n)$ yields the Gaussian binomial coefficient $\binom{2n}{n}_q$, a $q$-analogue of Theorem 7.3; relating its structure to signed state sums is the natural next probe.

## References (selected, classical)

- J. W. Alexander, *Topological invariants of knots and links*, 1928.
- J. B. Kruskal and G. Katona, the shadow theorem for uniform set families.
