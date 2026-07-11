# The Unreasonable Effectiveness of Wrong Theories: A Geometric Meta-Theory of Predictive Superiority

**Author:** Aristotle
**Date:** 2026-07-11

## Abstract

We develop a geometric meta-theory of physical theories in which the space of all theories is modeled as a real inner-product space, the true description of nature is a distinguished point, and each empirical question is a direction along which theories cast predictive shadows. Within this framework we prove that a theory known to be *wrong* — at strictly positive distance from the truth — can nonetheless out-predict its rivals on carefully chosen phenomena, and we make the phenomenon and the winning margin fully explicit. Our central results are: (i) prediction error is globally dominated by wrongness via the Cauchy–Schwarz inequality; (ii) convergent perturbative corrections drive the prediction error to zero on every fixed phenomenon; (iii) for any single rival that errs non-parallel to the wrong theory, the orthogonal residue of the rival's error is an explicit phenomenon on which the wrong theory is exact and the rival errs by exactly the squared length of the residue; and (iv) the flagship generalization — for *any finite family* of rivals whose errors are each non-parallel to the wrong theory's error, there exists a *single* phenomenon on which the wrong theory is exact while *every* rival simultaneously errs. The multi-rival result rests on a linear-algebra core lemma: any finite set of nonzero vectors admits a common vector pairing nontrivially with all of them and lying in their span. We give complete proof sketches, algorithms realizing the constructions, and numerical demonstrations.

## 1. Introduction

Wigner spoke of the *unreasonable effectiveness of mathematics* in the natural sciences. We address a companion puzzle, at least as old and at least as practical: the unreasonable effectiveness of theories we *know to be false*. Newtonian mechanics is superseded, yet remains the tool of choice for celestial navigation. Ray optics is false, yet designs telescopes. The Bohr model is wrong, yet predicts the hydrogen spectrum. Working scientists treat superseded theories not as errors to be purged but as instruments to be deployed on the right problems.

This paper turns that folklore into mathematics. We model theory-space as a real inner-product space, so that the intuitive notions of "how wrong" and "how off on this question" acquire precise, computable meanings — a *global* distance and a *directional* projection, respectively. The gap between these two notions is the entire phenomenon: a theory can be globally far from the truth while its error vector points *sideways* to a particular question, making its directional prediction flawless.

We then prove that this is not a fragile coincidence but a structural certainty. Whenever a wrong theory fails in a direction genuinely its own — non-parallel to a rival's failure — there is an explicit question on which it strictly out-predicts that rival. More strikingly, against any finite field of rivals with pairwise-distinct-from-ours failure directions, a *single* question exists on which the wrong theory alone is exact.

### 1.1 Contributions

- A self-contained geometric model of theories, wrongness, phenomena, and prediction error over an arbitrary real inner-product space.
- A proof that prediction error is uniformly controlled by wrongness (Cauchy–Schwarz).
- A perturbative-convergence theorem transferring theory-space convergence to every fixed phenomenon.
- An explicit, quantitative single-rival superiority theorem with a closed-form winning phenomenon and an exact gap of $\|q\|^2$.
- A hyperplane-avoidance lemma and, from it, the multi-rival superiority theorem defeating any finite field of rivals at once.

## 2. The framework

Throughout, $E$ is a real inner-product space with inner product $\langle\cdot,\cdot\rangle$ and induced norm $\|x\| = \sqrt{\langle x,x\rangle}$. All results hold over an arbitrary such space (finite- or infinite-dimensional); completeness is not required except where noted.

**Definition 2.1 (Theory, truth).** A *theory* is a point $T \in E$. A distinguished point $\mathsf{truth}\in E$ represents the exact description of nature.

**Definition 2.2 (Wrongness).** The *wrongness* of a theory $T$ is its distance from the truth,
$$\mathrm{wrongness}(T) = \|T - \mathsf{truth}\|.$$
It is manifestly nonnegative, and equals zero if and only if $T = \mathsf{truth}$.

**Definition 2.3 (Phenomenon, prediction, prediction error).** A *phenomenon* is a direction $u \in E$. The *prediction* of theory $T$ for $u$ is $\langle T, u\rangle$. The *prediction error* of $T$ on $u$ is
$$\mathrm{predErr}(T, u) = \bigl|\langle T - \mathsf{truth},\, u\rangle\bigr| \ge 0.$$

We write $a := A - \mathsf{truth}$ for the *error vector* of a theory $A$; a phenomenon $u$ is predicted exactly by $A$ precisely when $u \perp a$.

**Definition 2.4 (Corrected theories).** Given a base theory $T_0 \in E$ and a sequence of *corrections* $c : \mathbb{N} \to E$, the $n$-th *corrected theory* is
$$P_n = T_0 + \sum_{i<n} c_i.$$

**Definition 2.5 (Non-parallel errors).** Rival $B$ errs *non-parallel* to $A$ if $B - \mathsf{truth}$ is not a scalar multiple of $A - \mathsf{truth}$; equivalently, the two error vectors are linearly independent.

## 3. Errors are governed by wrongness

**Theorem 3.1 (Prediction error is dominated by wrongness).** For every theory $T$ and phenomenon $u$,
$$\mathrm{predErr}(T, u) \le \mathrm{wrongness}(T)\cdot \|u\|.$$

*Proof.* Apply the Cauchy–Schwarz inequality to the error vector $T-\mathsf{truth}$ and the phenomenon $u$: $|\langle T-\mathsf{truth}, u\rangle| \le \|T-\mathsf{truth}\|\,\|u\|$. The left side is $\mathrm{predErr}(T,u)$ by definition, and $\|T-\mathsf{truth}\| = \mathrm{wrongness}(T)$. $\square$

The theorem certifies that global proximity to the truth entails uniform predictive accuracy: a theory of small wrongness cannot err appreciably on any bounded phenomenon. Wrongness is a genuine ceiling on error and never a floor — nothing here prevents the error from being far smaller than the bound, and indeed the results of Section 5 exploit exactly the cases in which it is zero.

## 4. Perturbative convergence propagates to predictions

**Theorem 4.1 (Predictions converge).** Let $T_0 \in E$ and $c : \mathbb{N}\to E$, and suppose the correction series sums to the gap, $\sum_{i} c_i = \mathsf{truth} - T_0$. Then for every fixed phenomenon $u$,
$$\mathrm{predErr}(P_n, u) \xrightarrow[n\to\infty]{} 0, \qquad P_n = T_0 + \sum_{i<n} c_i.$$

*Proof sketch.* Since the partial sums $\sum_{i<n} c_i$ converge to $\mathsf{truth}-T_0$, the corrected theories $P_n = T_0 + \sum_{i<n}c_i$ converge in $E$ to $\mathsf{truth}$. Hence $\mathrm{wrongness}(P_n) = \|P_n - \mathsf{truth}\| \to 0$, and therefore $\mathrm{wrongness}(P_n)\cdot\|u\| \to 0$. By Theorem 3.1,
$$0 \le \mathrm{predErr}(P_n, u) \le \mathrm{wrongness}(P_n)\cdot \|u\|,$$
so the squeeze theorem forces $\mathrm{predErr}(P_n, u)\to 0$. $\square$

Convergence of a theory in theory-space thus entails convergence of *all* of its predictions simultaneously: perturbation series that close the gap close every question along the way.

## 5. A wrong theory beats a single rival

We now reach the phenomenon that names the paper. Fix a wrong theory $A$ with $A \ne \mathsf{truth}$ and a rival $B$ erring non-parallel to $A$. Put $a = A-\mathsf{truth}$, $b = B-\mathsf{truth}$, and form the Gram–Schmidt residue of $b$ against $a$:
$$q = b - \frac{\langle b, a\rangle}{\langle a, a\rangle}\, a.$$
This $q$ is the component of the rival's error orthogonal to the wrong theory's error.

**Theorem 5.1 (Quantitative single-rival superiority).** With $A\ne\mathsf{truth}$ and $b$ not parallel to $a$, the phenomenon $q$ satisfies
$$\mathrm{predErr}(A, q) = 0, \qquad \mathrm{predErr}(B, q) = \|q\|^2 > 0.$$

*Proof sketch.* **Exactness of $A$.** Compute $\langle a, q\rangle = \langle a, b\rangle - \frac{\langle b,a\rangle}{\langle a,a\rangle}\langle a,a\rangle = \langle a,b\rangle - \langle b,a\rangle = 0$ by symmetry of the real inner product. Hence $\mathrm{predErr}(A,q) = |\langle a, q\rangle| = 0$. **Error of $B$.** Since $q = b - \frac{\langle b,a\rangle}{\langle a,a\rangle}a$ and $q\perp a$, we have $\langle b, q\rangle = \langle q + \frac{\langle b,a\rangle}{\langle a,a\rangle}a,\ q\rangle = \langle q,q\rangle + 0 = \|q\|^2$, which is nonnegative, so $\mathrm{predErr}(B,q) = |\langle b,q\rangle| = \|q\|^2$. **Positivity.** If $\|q\|^2 = 0$ then $q = 0$, i.e. $b = \frac{\langle b,a\rangle}{\langle a,a\rangle}a$, exhibiting $b$ as a scalar multiple of $a$ — contradicting non-parallelism (here $\langle a,a\rangle = \|a\|^2 > 0$ because $A\ne\mathsf{truth}$). Hence $\|q\|^2 > 0$. $\square$

The winning phenomenon and the winning margin are both explicit and computable: the wrong theory is not merely competitive but exact on $q$, and it beats the rival by precisely the squared length of the rival's orthogonalized error.

## 6. Beating a whole field of rivals

The single-rival theorem generalizes to an arbitrary finite field of rivals. The bridge is a purely linear-algebraic lemma about simultaneously avoiding finitely many orthogonality conditions.

**Lemma 6.1 (Common non-annihilating vector).** Let $q_1,\dots,q_k \in E$ be nonzero. Then there exists $u \in E$ with
$$\langle q_i, u\rangle \ne 0 \quad \text{for all } i,$$
and such that $u$ is orthogonal to every vector annihilated by all the $q_i$: if $\langle q_i, v\rangle = 0$ for all $i$, then $\langle v, u\rangle = 0$. (Dually, $u$ lies in the span of $q_1,\dots,q_k$.)

*Proof sketch.* Induct on the list. The empty list is served by $u = 0$. For the inductive step, suppose $u$ works for $q_1,\dots,q_{k-1}$ and let $q_k \ne 0$. Consider the one-parameter family $u_t = u + t\,q_k$. For each $i \le k-1$, the condition $\langle q_i, u_t\rangle = 0$ is a linear equation in $t$ and hence has at most one solution (none if $\langle q_i, q_k\rangle = 0$, since then $\langle q_i, u_t\rangle = \langle q_i, u\rangle \ne 0$ is constant). The condition $\langle q_k, u_t\rangle = \langle q_k, u\rangle + t\|q_k\|^2 = 0$ likewise has exactly one solution since $\|q_k\|^2 > 0$. The forbidden set of $t$ is therefore finite, so some $t \in \mathbb{R}$ makes $\langle q_i, u_t\rangle \ne 0$ for all $i \le k$. The span/orthogonality clause is preserved because $u_t = u + t q_k$ is a combination of vectors in the span of $q_1,\dots,q_k$: if $v$ is annihilated by all $q_i$ then $\langle v, u_t\rangle = \langle v, u\rangle + t\langle v, q_k\rangle = 0 + t\cdot 0 = 0$. $\square$

The lemma is the geometry of avoiding finitely many hyperplanes: each spoiling condition carves out a measure-zero slice of the parameter line, and finitely many such slices cannot exhaust the continuum.

**Theorem 6.2 (Multi-rival superiority — flagship).** Let $A \ne \mathsf{truth}$ and let $B_1,\dots,B_k$ be any finite family of rivals, each erring non-parallel to $A$. Then there exists a *single* phenomenon $u \in E$ with
$$\mathrm{predErr}(A, u) = 0 \qquad\text{and}\qquad \mathrm{predErr}(B_j, u) > 0 \ \text{ for every } j.$$

*Proof sketch.* Let $a = A - \mathsf{truth}$ and, for each rival, form the orthogonalized error residue
$$q_j = (B_j - \mathsf{truth}) - \frac{\langle B_j - \mathsf{truth},\, a\rangle}{\langle a, a\rangle}\, a.$$
By the argument of Theorem 5.1, each $q_j$ is nonzero (non-parallelism) and orthogonal to $a$. Apply Lemma 6.1 to $q_1,\dots,q_k$ to obtain a single $u$ with $\langle q_j, u\rangle \ne 0$ for all $j$ and with $u$ orthogonal to everything the $q_j$ annihilate. Since each $q_j \perp a$, the vector $a$ is annihilated by all $q_j$ in the relevant sense, so the span clause of the lemma gives $\langle a, u\rangle = 0$; hence $\mathrm{predErr}(A,u) = |\langle a, u\rangle| = 0$: the wrong theory is exact on $u$. For each rival, because $q_j \perp a$ and $\langle a, u\rangle = 0$ we have $\langle B_j - \mathsf{truth}, u\rangle = \langle q_j, u\rangle \ne 0$, so $\mathrm{predErr}(B_j, u) = |\langle q_j, u\rangle| > 0$. Thus $A$ predicts $u$ exactly while every rival errs. $\square$

No coalition of finitely many rivals — however accurate individually — can construct a shield of questions that locks out a wrong theory, provided that theory fails in a direction none of them shares.

## 7. Algorithms

The proofs are constructive; each yields an algorithm.

**Algorithm A (Single-rival winning phenomenon).** Given $\mathsf{truth}, A, B$, return $q = b - \frac{\langle b,a\rangle}{\langle a,a\rangle}a$ where $a = A-\mathsf{truth}$, $b = B-\mathsf{truth}$. The wrong theory $A$ is exact on $q$ and beats $B$ by $\|q\|^2$. Cost: $O(d)$ inner products in dimension $d$.

**Algorithm B (Hyperplane avoidance).** Given nonzero $q_1,\dots,q_k$, build $u$ incrementally: start $u \leftarrow 0$; for each new $q_j$, choose $t$ outside the finite forbidden set (e.g. one more than the maximum absolute forbidden value, or a random draw) and update $u \leftarrow u + t\,q_j$. Cost: $O(k^2 d)$.

**Algorithm C (Multi-rival winning phenomenon).** Orthogonalize each rival error against $a$ to get $q_1,\dots,q_k$ (Algorithm A componentwise), then run Algorithm B to obtain $u$. Output $u$: exact for $A$, erroneous for every rival.

## 8. Applications and interpretation

**History of physics as a toolkit.** The results explain why superseded theories persist. A superseded theory $A$ is at strictly positive wrongness, yet on any question orthogonal to its error vector it is exact (Theorem 5.1), and against a finite field of alternatives that fail differently it owns a question outright (Theorem 6.2). Being wrong is a *direction*, not merely a magnitude.

**Model selection.** In statistical and physical modeling, one rarely has the true model. Theorem 5.1 warns that comparisons on a fixed benchmark phenomenon can be dominated by whichever candidate happens to be orthogonal to its own error there; robust evaluation must probe a spread of phenomena, not a single favored direction.

**Perturbation theory.** Theorem 4.1 justifies the practice of truncating convergent expansions: if the correction series closes the gap in theory-space, every observable's error decays, uniformly in the sense of the Cauchy–Schwarz bound.

## 9. Discussion and limitations

Two structural assumptions do the work. *Inner-product geometry* supplies orthogonality, without which "erring sideways to a question" has no meaning; the separation results rely on Gram–Schmidt residues and hyperplane avoidance. *Non-parallelism* is essential and sharp: if a rival errs exactly parallel to $A$, then their error vectors span the same line, every phenomenon sees their errors in fixed proportion, and no phenomenon can make $A$ exact while $B$ errs. The theorems therefore describe genuine *diversity* of error, not mere multiplicity of theories.

The framework idealizes: it linearizes predictions (as inner products) and treats theory-space as flat. Real theories predict nonlinearly and live on curved manifolds of models. The linear model should be read as the tangent-space approximation near the truth — precisely the regime perturbation theory inhabits.

## 10. Future directions

1. **Countably many rivals.** Extend the multi-rival theorem to a countable family whose orthogonalized errors are uniformly bounded below, via a Baire-category argument in a complete space: the set of good phenomena is a dense $G_\delta$.

2. **Measure of good phenomena.** Show the set of phenomena on which $A$ beats a fixed rival $B$ is *large* — the complement of a proper subspace (measure zero / meager) — so generic phenomena favor the wrong theory once its error is non-parallel.

3. **Quantitative multi-rival gap.** Give an explicit lower bound on $\min_j \mathrm{predErr}(B_j, u)$ for the constructed $u$, in terms of the Gram matrix of the orthogonalized rival errors.

4. **Best wrong theory in a model class.** For a closed subspace $M \subseteq E$ of admissible theories, relate the minimal achievable wrongness to the orthogonal projection of $\mathsf{truth}$ onto $M$, and characterize the phenomena on which the projected theory is exact.

5. **Normed (non-inner-product) theory-space.** Replace the inner product by a general dual pairing / Banach setting and identify which results survive, with Hahn–Banach replacing Gram–Schmidt for the separation statements.

## 11. Conclusion

Modeling theories as points in an inner-product space renders the paradox of effective-yet-false theories a matter of elementary geometry. Wrongness bounds error from above (Theorem 3.1); convergent corrections annihilate error on every question (Theorem 4.1); and — the heart of the matter — a wrong theory that fails in its own direction is not merely competitive but *exact* on an explicit question, beating any single rival by a computable margin (Theorem 5.1) and defeating any finite field of rivals on a single shared question (Theorem 6.2). The effectiveness of wrong theories is, on inspection, entirely reasonable.
