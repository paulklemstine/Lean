# A Duality Framework for Hamming-Ball Discrepancy: An Exact Averaging Kernel for the Curse of Dimensionality

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Novelty (Computational Discrepancy Theory / Coding Theory)

## Abstract

We isolate and prove the deterministic, unconditional kernel behind a conjecture on the
discrepancy of random linear codes for Hamming balls, and we frame it as one half of a
duality framework for discrepancy lower bounds and the curse of dimensionality. Working in
the ambient group $G = \iota \to \alpha$ of all functions from a finite index set to a finite
abelian group (the space of length-$n$ strings over a $q$-ary alphabet), we prove the **exact
averaging identity** $\sum_{z \in G} |C \cap B_r(z)| = |C| \cdot |B_r(0)|$ for *every* subset
$C$, with no randomness and no linearity. The proof is a double count whose load-bearing
ingredient is the **translation invariance** of Hamming distance, from which we deduce that
the ball volume $|B_r(z)|$ is independent of the centre $z$. We give the explicit volume
formula $|B_r(0)| = \sum_{i \le r}\binom{n}{i}(q-1)^i$ via a support-counting bijection for
spheres. From the averaging identity we extract a one-sided (Markov) discrepancy bound: the
number of "crowded" centres with $|C \cap B_r(z)| \ge t$ is at most $|C| \cdot |B_r| / t$. For
linear codes we prove the discrepancy field is **periodic**: the intersection count is
invariant under translation by a codeword. These results pin down precisely the part of the
discrepancy conjecture that holds with certainty (the value of the mean and the upper tail),
separating it from the genuinely hard residue (lower-tail concentration), and supply the
combinatorial engine for the same averaging-versus-pigeonhole duality that drives exponential
information-complexity lower bounds in high-dimensional numerical integration.

---

## 1. Introduction

### 1.1 Motivation

Discrepancy theory measures how evenly a finite point set is distributed relative to a family
of test regions. In coding theory the relevant point set is a code $C \subseteq G$ and the
test regions are Hamming balls $B_r(z)$; the discrepancy of $C$ controls its performance as a
list-decodable code, as a source of pseudorandomness, and as a sampling set for
high-dimensional quadrature. A central conjecture predicts that a random linear code of the
appropriate dimension is *equidistributed* for all Hamming balls simultaneously: with
probability $1 - o(1)$, for **every** centre $z$,

$$|C \cap B_r(z)| = (1 \pm o(1)) \cdot \frac{|C| \cdot |B_r|}{q^n}.$$

The right-hand side is the count expected of a uniformly random set of size $|C|$ when the
ball volume is centre-independent. Two distinct claims are bundled here: (i) that the *target
value* $|C| \cdot |B_r| / q^n$ is correct, and (ii) that the individual counts *concentrate*
around it for all centres at once. This paper proves (i) unconditionally and exactly, and
reduces (ii) to a clean two-sided concentration question, isolating the upper tail as a
consequence of (i).

### 1.2 The duality principle

The unifying technique is a duality between two ways of counting incidences in the
bipartite relation "codeword $c$ lies in the ball about centre $z$":

- **Averaging (volume) view:** sum over centres first. This yields exact mean-value and
  weight-budget statements (the averaging identity, the Markov tail bound).
- **Pigeonhole (coverage) view:** sum over codewords first, or bound the image of a covering
  map. This yields existence statements (some centre must be empty / some centre must exceed
  the mean) and underlies pigeonhole lower bounds on the number of sample points.

The same duality reappears in numerical integration, where the worst-case error of a cubature
rule equals a discrepancy, and where non-negative rules require exponentially many nodes to
reach a target accuracy — the curse of dimensionality. The present paper formalizes the
combinatorial kernel of the averaging side.

### 1.3 Contributions

1. **Exact averaging identity** (Theorem 1): for any $C$, $\sum_z |C \cap B_r(z)| = |C| \cdot
   |B_r(0)|$.
2. **Centre-independence of ball volume** (Theorem 2) from translation invariance (Lemma 1).
3. **Explicit ball-volume formula** (Theorem 4): $|B_r(0)| = \sum_{i \le r}\binom{n}{i}(q-1)^i$.
4. **One-sided Markov discrepancy bound** (Theorem 3): the crowded centres are few.
5. **Periodicity of the discrepancy field** for linear/coset codes (Lemma 6).

All results are dimension-free in structure (no hidden dependence on $n$ beyond what is
written) and assume no algebraic structure on $C$ except where periodicity is claimed.

---

## 2. Setup and Definitions

Fix a finite index set $\iota$ with $|\iota| = n$ and a finite alphabet $\alpha$ with
$|\alpha| = q$. The ambient space is the product group

$$G = \{\, x : \iota \to \alpha \,\}, \qquad |G| = q^n,$$

with coordinatewise addition when $\alpha$ carries an abelian group structure.

**Definition 1 (Hamming distance).** For $x, y \in G$,
$$d(x, y) = \#\{\, i \in \iota : x_i \neq y_i \,\}.$$

**Definition 2 (Hamming ball).** For radius $r \in \mathbb{N}$ and centre $z \in G$,
$$B_r(z) = \{\, x \in G : d(x, z) \le r \,\}.$$

**Definition 3 (Hamming sphere).** The shell at exact distance $r$,
$$S_r(z) = \{\, x \in G : d(x, z) = r \,\}.$$

**Definition 4 (discrepancy count).** For a code $C \subseteq G$, centre $z$, radius $r$, the
local count is $N_C(z) = |C \cap B_r(z)|$. Its *discrepancy* is the spread of $N_C(z)$ over
$z$ relative to the mean $|C| \cdot |B_r| / q^n$.

---

## 3. Translation Invariance and Centre-Free Volume

**Lemma 1 (translation invariance of Hamming distance).** *For all $x, y, a \in G$,*
$$d(x + a, \; y + a) = d(x, y).$$
*(Lean: `hammingDist_add_right`.)*

*Proof sketch.* By definition $d$ counts coordinates where the arguments differ. For each
$i$, $(x+a)_i \neq (y+a)_i \iff x_i + a_i \neq y_i + a_i \iff x_i \neq y_i$, since adding the
common group element $a_i$ is injective. The two indicator sets coincide coordinatewise, hence
have equal cardinality. $\square$

**Lemma 2 (ball is a translate of the origin ball).** *For all $r, z$,*
$$B_r(z) = \{\, y + z : y \in B_r(0) \,\}.$$
*(Lean: `ball_eq_image`.)*

*Proof sketch.* For $x \in B_r(z)$ put $y = x - z$; Lemma 1 gives $d(y, 0) = d(x, z) \le r$,
so $y \in B_r(0)$ and $x = y + z$. Conversely if $y \in B_r(0)$ then $d(y+z, z) = d(y, 0) \le
r$. The map $y \mapsto y + z$ is a bijection between the two sets. $\square$

**Theorem 2 (ball volume is centre-independent).** *For all $r, z$,*
$$|B_r(z)| = |B_r(0)|.$$
*(Lean: `ball_card_eq`.)*

*Proof sketch.* Translation $y \mapsto y + z$ is injective on $G$, so by Lemma 2 the ball
$B_r(z)$ is the injective image of $B_r(0)$ and has the same cardinality. $\square$

**Lemma 3 (centres containing a fixed point).** *For any fixed $c \in G$ and radius $r$, the
number of centres $z$ whose ball of radius $r$ contains $c$ equals the ball volume:*
$$\#\{\, z \in G : d(c, z) \le r \,\} = |B_r(0)|.$$
*(Lean: `card_centres_containing`.)*

*Proof sketch.* By symmetry of Hamming distance, $d(c, z) \le r \iff z \in B_r(c)$, so the set
of such $z$ is exactly $B_r(c)$; apply Theorem 2. $\square$

Lemma 3 is the dual reading of a ball: a ball about $c$ is simultaneously "the points near
$c$" and "the centres that see $c$." This duality is precisely what powers the next result.

---

## 4. The Exact Averaging Identity

**Theorem 1 (exact averaging identity — main result).** *For every code $C \subseteq G$ and
every radius $r$,*
$$\sum_{z \in G} |C \cap B_r(z)| \;=\; |C| \cdot |B_r(0)|.$$
*Equivalently, the average over centres of the local count is exactly $|C| \cdot |B_r| / q^n$.*
*(Lean: `sum_inter_ball`.)*

*Proof sketch (double counting).* Rewrite the local count as a sum of indicators:
$$|C \cap B_r(z)| = \sum_{c \in C} \mathbf{1}[\, d(c, z) \le r \,].$$
Substitute and exchange the order of summation:
$$\sum_{z \in G} \sum_{c \in C} \mathbf{1}[\, d(c, z) \le r \,]
  = \sum_{c \in C} \sum_{z \in G} \mathbf{1}[\, d(c, z) \le r \,]
  = \sum_{c \in C} \#\{\, z : d(c, z) \le r \,\}.$$
By Lemma 3 the inner count equals $|B_r(0)|$ for every $c$, independent of $c$. Hence the
total is $\sum_{c \in C} |B_r(0)| = |C| \cdot |B_r(0)|$. $\square$

**Remark.** The identity is exact (no error term), dimension-free in derivation, and requires
no structure on $C$. It would *fail* if ball volume depended on the centre; this is why
translation invariance (Lemma 1) is isolated as load-bearing. Linearity of $C$ is *not*
assumed, so the statement is strictly more general than the conjecture's hypothesis.

**Corollary 1 (the mean is the conjecture's target).** Dividing by $|G| = q^n$,
$$\frac{1}{q^n} \sum_{z} |C \cap B_r(z)| = \frac{|C| \cdot |B_r|}{q^n}.$$
Thus the conjecture's "target value" is provably the exact mean; what remains is
concentration about it.

---

## 5. The Explicit Ball-Volume Formula

To make the mean a concrete rational number we compute $|B_r(0)|$.

**Lemma 4 (sphere count).** *The number of points at Hamming distance exactly $r$ from the
origin is*
$$|S_r(0)| = \binom{n}{r}\,(q-1)^r.$$
*(Lean: `sphere_card`.)*

*Proof sketch (support counting).* A point $x$ at distance $r$ from $0$ is determined by its
support $T = \{\, i : x_i \neq 0 \,\}$, a size-$r$ subset of the $n$ coordinates
($\binom{n}{r}$ choices), together with a nonzero symbol at each coordinate of $T$ ($(q-1)$
choices per coordinate, $(q-1)^r$ total). The map (point) $\mapsto$ (support, values) is a
bijection onto these data, giving the product. The subtraction $q - 1$ is the truncated
natural-number subtraction, valid since $q \ge 1$ for a nonempty alphabet. $\square$

**Lemma 5 (ball as a disjoint union of spheres).**
$$|B_r(0)| = \sum_{i=0}^{r} |S_i(0)|.$$
*(Lean: `ball_card_eq_sum_sphere`.)*

*Proof sketch.* The balls' defining inequality $d(x,0) \le r$ partitions by the exact value
$d(x,0) = i$ for $i = 0, \dots, r$; the spheres are disjoint and cover the ball. $\square$

**Theorem 4 (explicit ball volume).**
$$|B_r(0)| = \sum_{i=0}^{r} \binom{n}{i}\,(q-1)^i.$$
*(Lean: `ball_card_formula`.)*

*Proof sketch.* Combine Lemmas 4 and 5. $\square$

Consequently the conjecture's target value is the explicit rational
$$\frac{|C|}{q^n} \sum_{i=0}^{r} \binom{n}{i}\,(q-1)^i.$$

---

## 6. The One-Sided Discrepancy Bound

The averaging identity is a fixed budget, and a fixed budget immediately bounds how much can
pile up anywhere.

**Theorem 3 (Markov discrepancy bound).** *For every code $C$, radius $r$, and threshold $t \ge
1$,*
$$\#\{\, z \in G : |C \cap B_r(z)| \ge t \,\} \cdot t \;\le\; |C| \cdot |B_r(0)|,$$
*hence the number of "crowded" centres is at most $|C| \cdot |B_r| / t$.*
*(Lean: `card_bad_centres_le`.)*

*Proof sketch.* Let $H = \{\, z : N_C(z) \ge t \,\}$. Summing the constant $t$ over $H$,
$$|H| \cdot t = \sum_{z \in H} t \le \sum_{z \in H} N_C(z) \le \sum_{z \in G} N_C(z)
  = |C| \cdot |B_r(0)|,$$
using $N_C(z) \ge t$ on $H$ for the first inequality, non-negativity of the dropped terms for
the second, and Theorem 1 for the equality. $\square$

**Discussion.** Theorem 3 controls only the *upper* tail: it shows crowding is rare. It says
nothing about empty or under-subscribed centres. Full equidistribution requires a matching
*lower*-tail companion (an "exists a centre near or above the mean" / "few centres are
under-subscribed" statement), which genuinely needs the randomness or linear structure absent
from Theorems 1-3. The decomposition exact-mean (Thm 1) + one-sided-tail (Thm 3) is provably
*strictly weaker* than two-sided concentration; that gap is the residue of the conjecture.

---

## 7. Periodicity for Linear and Coset Codes

When $C$ has additive structure, the discrepancy landscape becomes periodic.

**Lemma 6 (coset periodicity of the discrepancy field).** *Let $C \subseteq G$ be a code. If
$z - z' \in C$ (equivalently $C$ is closed under the relevant translation), then*
$$|C \cap B_r(z)| = |C \cap B_r(z')|.$$
*(Lean: `inter_ball_coset_invariant`, `inter_ball_eq_of_sub_mem`.)*

*Proof sketch.* Translation by $z' - z$ is a bijection of $G$ that maps $B_r(z)$ onto
$B_r(z')$ (Lemma 2) and maps $C$ onto itself when $z - z' \in C$ and $C$ is closed under
codeword translation. A bijection between the two intersections preserves cardinality.
$\square$

Thus for a linear code the function $z \mapsto N_C(z)$ is constant on cosets of $C$ and
descends to the quotient $G / C$. The discrepancy problem becomes one of equidistribution of
a *periodic* function — the formal link to periodic $L_p$-discrepancy and to the wrap-around
spaces studied in the curse-of-dimensionality literature.

---

## 8. Algorithms

The constructive content yields three direct algorithms.

**Algorithm A (Exact Mean via Averaging Identity).** Computes $|C| \cdot |B_r(0)|$ and the
exact per-centre mean *without enumerating centres*, by Theorem 1 and Theorem 4. Complexity:
$O(r)$ field operations for the volume plus $O(1)$ for the product, versus $\Theta(q^n)$ for
naive enumeration. This is the exponential speedup that the identity buys.

**Algorithm B (Discrepancy Profile by Direct Enumeration).** For small $G$, enumerate all
$q^n$ centres, compute $N_C(z)$, and tabulate the empirical distribution. Used to *certify*
the averaging identity and to study concentration empirically. Complexity $\Theta(q^n \cdot
|C|)$.

**Algorithm C (Crowded-Centre Budget Certificate).** Given a threshold $t$, returns the
Markov upper bound $\lfloor |C| \cdot |B_r| / t \rfloor$ on the number of crowded centres
(Theorem 3) and, optionally, the true count by enumeration to confirm $\text{(true)} \le
\text{(bound)}$. Complexity $O(r)$ for the certificate, $\Theta(q^n |C|)$ for verification.

---

## 9. Applications

- **Coding theory.** Theorems 1-4 settle the value of the discrepancy mean for list-size
  analysis and reduce the random-linear-code conjecture to two-sided concentration.
- **Pseudorandomness and sampling.** The Markov bound certifies that a code over-samples few
  regions, useful for hitting-set and sampler constructions.
- **High-dimensional numerical integration.** The averaging-versus-pigeonhole duality is the
  combinatorial shadow of worst-case-error = discrepancy identities for cubature; the
  pigeonhole half forces exponentially many nodes for non-negative rules (curse of
  dimensionality), while the averaging half supplies the exact mean.
- **Periodic discrepancy.** Lemma 6 places linear codes inside the theory of periodic
  $L_p$-discrepancy, where wrap-around symmetry is the governing structure.

---

## 10. Discussion and Future Work

The methodological lesson is that demanding an *exact* statement, plus a deliberate choice of
which index to sum first, dissolves the apparently hard "target value" sub-problem entirely.
The residual difficulty — lower-tail / two-sided concentration — is now cleanly exposed.

Several concrete directions follow (companion framework; not proved here):

- **Sign-asymmetry of the curse.** Dropping non-negativity of weights should break the
  *averaging* (weight-budget) lower bound while leaving the *pigeonhole* (coverage) bound
  intact — evidence that the two halves of a curse-of-dimensionality argument have genuinely
  different hypotheses.
- **Quantitative tractability threshold.** Iterating the pigeonhole to count *many* empty
  cells should upgrade a qualitative "exponentially many nodes" statement to an
  $\varepsilon$-explicit rate.
- **Two-sided discrepancy law for codes.** Pairing the Markov upper bound (Theorem 3) with a
  lower-tail companion should yield genuine two-sided concentration for random linear codes,
  with both tails provably necessary.
- **Reproducing-kernel reading.** The combinatorial worst-case error studied here is expected
  to be the discrete shadow of an RKHS worst-case-error = discrepancy identity.

---

## 11. Conclusion

A one-line double count, resting on the translation invariance of Hamming distance, proves
that the average number of codewords in a Hamming ball is *exactly* $|C| \cdot |B_r| / q^n$
for every code. The ball volume is centre-independent and explicitly $\sum_{i \le
r}\binom{n}{i}(q-1)^i$. The same identity bounds the upper tail of the discrepancy for free,
and additive structure makes the discrepancy field periodic. Together these results separate
the certain part of a well-known conjecture (the mean and the upper tail) from its genuinely
hard residue (two-sided concentration), and they provide the averaging engine for the
duality framework behind exponential lower bounds in high-dimensional computation.
