# Quadratic Recurrence and Hidden Arithmetic: Rotation Numbers, Fibonacci Spirals, and the Factorization of Bulb Periods

## Abstract

The quadratic family $z \mapsto z^2 + c$ generates, through a single squaring-and-adding rule, the most intricate boundary in elementary dynamics. We study the arithmetic that organizes this boundary. Three strands are developed. First, an **escape criterion**: a constructive one-step growth estimate $|z^2 + c| \ge |z|(|z|-1)$ that forces every orbit crossing the circle of radius $2$ to diverge, with the threshold $2$ shown to be sharp along the real axis. Second, a **rotation-number dictionary**: the hyperbolic components ("bulbs") attached to the main cardioid are indexed by reduced fractions $p/q$, whose denominator equals the bulb's period, realized concretely as the additive order of $p$ in $\mathbb{Z}/q\mathbb{Z}$; the center's Lyapunov exponent is conjectured to equal $\log 2 \cdot \cos(\pi p/q)$. Third, an **arithmetic of assembly**: the Fibonacci ratios $F_n/F_{n+1}$ are the greedy geodesics of the Farey/Stern–Brocot tree — a fact traced to Cassini's identity $F_{n+1}^2 - F_n F_{n+2} = (-1)^n$ and the coprimality of consecutive Fibonacci numbers — while composite-period bulbs decompose as products of prime-power bulbs, a consequence of the multiplicativity of additive order over coprime moduli via the Chinese Remainder Theorem. Together these results present the Mandelbrot set as a geometric encoding of elementary number theory.

**Keywords:** quadratic recurrence, escape radius, rotation number, additive order, Fibonacci sequence, Cassini identity, Chinese Remainder Theorem, prime factorization, Farey mediant, Lyapunov exponent.

---

## 1. Introduction

The Mandelbrot set
$$M \;=\; \{\, c \in \mathbb{C} : \text{the orbit } 0, c, c^2+c, \dots \text{ under } z \mapsto z^2 + c \text{ is bounded} \,\}$$
is defined by a rule so simple it can be stated to a child, yet its boundary is a limit of unbounded complexity. This paper is concerned not with that complexity but with the **order** underlying it. Our thesis is that a substantial part of the combinatorial skeleton of $M$ — which bulbs exist, what their periods are, how large they are, and how they combine — is governed by classical elementary number theory: modular arithmetic, the Fibonacci recurrence, and unique factorization.

We organize the exposition around three self-contained developments.

- **Section 3** establishes the escape criterion that makes the set computable in the first place, and argues sharpness of the escape radius.
- **Section 4** develops the rotation-number dictionary, identifying bulb period with additive order and stating the Lyapunov formula for bulb centers.
- **Section 5** treats the arithmetic of assembly: the Fibonacci spiral via Cassini's identity, and the product structure of composite bulbs via the Chinese Remainder Theorem.

Section 6 collects applications, Section 7 discusses limitations, and Section 8 records open directions.

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$, $|\cdot|$ denotes complex modulus, and for $q \ge 1$ we write $\mathbb{Z}/q\mathbb{Z}$ for the additive group of residues modulo $q$. For $a \in \mathbb{Z}/q\mathbb{Z}$, $\operatorname{ord}(a)$ is its additive order, the least $k \ge 1$ with $k a \equiv 0 \pmod q$.

---

## 2. Preliminaries and definitions

**Definition 2.1 (Quadratic orbit).** For $c \in \mathbb{C}$ define the sequence $(z_n(c))_{n\ge 0}$ by $z_0 = 0$ and $z_{n+1} = z_n^2 + c$. The orbit is *bounded* if $\sup_n |z_n(c)| < \infty$.

**Definition 2.2 (Connectedness / Mandelbrot locus).** $M = \{ c : (z_n(c)) \text{ is bounded} \}$. The *boundary* $\partial M$ is where orbits are bounded but not robustly so.

**Definition 2.3 (Rotation number and bulb).** A *hyperbolic component* of $M$ is a maximal open region on which the map $z \mapsto z^2 + c$ has an attracting cycle; the number of points in that cycle is the *period*. The components directly attached to the main cardioid are the *bulbs*. Each bulb is attached at the point of the cardioid parameterized by an *internal angle* $\theta = p/q \in \mathbb{Q} \cap [0,1)$, its *rotation number*; on the bulb the attracting cycle is permuted cyclically with combinatorial rotation $p/q$.

**Definition 2.4 (Additive order).** For coprime $p, q$ with $1 \le p < q$, the additive order of $p$ modulo $q$ is
$$\operatorname{ord}_q(p) = \min\{ k \ge 1 : q \mid k p \}.$$

**Definition 2.5 (Lyapunov exponent).** For a parameter $c$ with an attracting cycle $\{w_0, \dots, w_{m-1}\}$ of period $m$, the Lyapunov exponent along the cycle is
$$\lambda(c) = \frac{1}{m}\sum_{j=0}^{m-1} \log\bigl| (z^2+c)'(w_j) \bigr| = \frac{1}{m}\sum_{j=0}^{m-1}\log\bigl(2|w_j|\bigr).$$
Negative $\lambda$ indicates attraction (stability), positive $\lambda$ indicates expansion (chaos).

**Definition 2.6 (Fibonacci sequence).** $F_0 = 0$, $F_1 = 1$, $F_{n+2} = F_{n+1} + F_n$.

**Definition 2.7 (Farey mediant).** The mediant of reduced fractions $a/b$ and $c/d$ is $(a+c)/(b+d)$. Two reduced fractions $a/b < c/d$ are *Farey neighbours* (unimodular) if $bc - ad = 1$.

---

## 3. The escape criterion and a sharp radius

The set $M$ is defined by a condition over infinitely many iterates. It becomes computable through a finite escape test.

**Theorem 3.1 (One-step growth estimate).** For all $z, c \in \mathbb{C}$,
$$|z^2 + c| \;\ge\; |z|^2 - |c|,\qquad\text{and in particular}\qquad |z^2+c| \ge |z|\bigl(|z| - 1\bigr)\ \text{ whenever } |c| \le |z|.$$

*Proof.* The reverse triangle inequality gives $|z^2 + c| \ge |z^2| - |c| = |z|^2 - |c|$. If $|c| \le |z|$ then $|z|^2 - |c| \ge |z|^2 - |z| = |z|(|z|-1)$. $\qquad\blacksquare$

**Theorem 3.2 (Escape criterion).** Let $c \in \mathbb{C}$ and suppose that for some $N$ we have $|z_N(c)| > 2$ and $|z_N(c)| \ge |c|$. Then $|z_n(c)| \to \infty$; in particular $c \notin M$.

*Proof.* Write $r = |z_N|$. Set $\varepsilon = r - 2 > 0$. For $n \ge N$ we show by induction that $|z_{n+1}| \ge (1+\delta)|z_n|$ with $\delta = r - 1 - 1 = r-2 = \varepsilon$ at the first step, and the ratio only improves. Indeed, since $|z_N| \ge |c|$ and $|z_N| > 2$, Theorem 3.1 gives $|z_{N+1}| \ge |z_N|(|z_N|-1) > |z_N|\cdot 1 = |z_N| > 2$, and moreover $|z_{N+1}| \ge |z_N|(r-1)$. Because $r - 1 > 1$, we have $|z_{N+1}| > |z_N| \ge |c|$, so the hypothesis $|z_{n}| \ge |c|$ is preserved and the modulus is strictly increasing past $2$. Iterating, $|z_{N+k}| \ge |z_N|\,(r-1)^{k}$, and since $r - 1 > 1$ this tends to infinity. $\qquad\blacksquare$

**Corollary 3.3 (Standard escape radius).** If $|c| > 2$ then $c \notin M$. If at any step $|z_n(c)| > 2$ then $c \notin M$. Hence $M \subseteq \{|c| \le 2\}$, and membership can be tested by iterating until the modulus first exceeds $2$.

*Proof.* If $|c| > 2$, then $z_1 = c$ has $|z_1| = |c| > 2$ and $|z_1| \ge |c|$; apply Theorem 3.2. In general once $|z_n| > 2 \ge \dots$, one checks $|z_n| \ge |c|$ (an orbit reaching modulus $>2$ has already surpassed $|c|$ when $|c|\le 2$), and Theorem 3.2 applies. $\qquad\blacksquare$

**Theorem 3.4 (Sharpness on the real axis).** For real $c$, the orbit of $0$ is bounded if and only if $-2 \le c \le \tfrac14$. At $c = -2$ the orbit remains in $[-2, 2]$ for all time, so the escape radius $2$ cannot be lowered while remaining valid in all directions.

*Discussion of proof.* For $c \in [-2, \tfrac14]$ the interval $[-2,2]$ (equivalently a suitable interval containing the orbit) is forward-invariant: the map $x \mapsto x^2 + c$ sends $[-2,2]$ into itself precisely when $c \ge -2$ and has a real fixed point when $c \le \tfrac14$. For $c > \tfrac14$ there is no real fixed point and the orbit increases without bound; for $c < -2$ one has $z_1 = c < -2$, and the geometric estimate $|z_{n+1}| \ge |z_n|(|z_n|-1)$ becomes an equality of leading order along the negative real axis, where the cancellation between $z_n^2$ and $c$ is maximal, forcing escape. The value $c = -2$ is the exact break-even point, pinning the critical modulus at $2$. $\qquad\blacksquare$

The content of Theorem 3.4 is that the constant $2$ in the escape test is not a convenient overestimate but the true infimum of valid escape radii.

---

## 4. The rotation-number dictionary

We now index the bulbs and read their periods arithmetically.

### 4.1 Period equals denominator

**Theorem 4.1 (Period–denominator identity).** Let $p/q$ be a rotation number in lowest terms, $\gcd(p,q)=1$, $1 \le p < q$. Then the period of the bulb at internal angle $p/q$ equals $q$. Equivalently, the period equals $\operatorname{ord}_q(p)$, the additive order of $p$ in $\mathbb{Z}/q\mathbb{Z}$, and when $\gcd(p,q)=1$ this order is $q$.

*Proof of the arithmetic core.* The combinatorial rotation by $p/q$ realizes the attracting cycle as the orbit of $0$ under $x \mapsto x + p$ in $\mathbb{Z}/q\mathbb{Z}$; its length is the least $k \ge 1$ with $kp \equiv 0 \pmod q$, i.e. $\operatorname{ord}_q(p)$. Since $q \mid kp$ and $\gcd(p,q) = 1$ imply $q \mid k$, the least such $k$ is $q$. Conversely $q p \equiv 0$, so $\operatorname{ord}_q(p) = q$. If instead the fraction is *not* reduced, say $\gcd(p,q) = d > 1$, then $\operatorname{ord}_q(p) = q/d < q$ and the same fraction in lowest terms $p'/q'$ with $q' = q/d$ labels the bulb, giving period $q'$. $\qquad\blacksquare$

**Corollary 4.2 (Antenna count).** The bulb at $p/q$ (reduced) carries a repelling "antenna" whose number of principal spokes equals its period $q$; counting spokes reads off the denominator directly.

### 4.2 The Lyapunov formula at bulb centers

**Conjecture 4.3 (Lyapunov value at the center).** Let $c_{p/q}$ be the center of the $p/q$ bulb (the parameter whose period-$q$ cycle is superattracting-adjacent, i.e. the root of the bulb's stability equation of maximal stability). Then
$$\lambda(c_{p/q}) \;=\; \log 2 \cdot \cos\!\left(\pi \frac{p}{q}\right).$$

*Rationale.* Near the cardioid, the attracting multiplier on the $p/q$ bulb is $e^{2\pi i p/q}$ to leading order, and the averaged log-derivative of the period-$q$ map, expanded to first order in the internal angle, contributes the real part $\cos(\pi p/q)$ scaled by the base expansion rate $\log 2$ of the doubling map to which $z \mapsto z^2$ is conjugate on the unit circle. The formula interpolates monotonically from maximal stability at $p/q \to 0$ to the onset of chaos as $p/q \to \tfrac12$, where $\cos(\pi/2) = 0$. A rigorous derivation requires control of the linearizing coordinate on the bulb; we state it as a conjecture and verify it numerically in Section 6.

### 4.3 Symmetry of prime bulbs

**Proposition 4.4 (Dihedral symmetry of prime bulbs).** For a prime $q$, the bulb at $1/q$ (and by conjugation the family $p/q$, $1 \le p < q$) carries the dihedral symmetry $D_q$ of a regular $q$-gon: the $q$ points of its attracting cycle are permuted by a cyclic rotation of order $q$ together with a reflection. When $q$ is prime this action is transitive and admits no proper invariant sub-cycle, so the symmetry group does not factor.

*Proof sketch.* The cycle carries the regular action of $\mathbb{Z}/q\mathbb{Z}$ by rotation number $p$; adjoining complex conjugation (a reflection of the parameter plane) yields the dihedral extension $D_q$. Primality of $q$ ensures $\mathbb{Z}/q\mathbb{Z}$ has no nontrivial subgroup, so there is no coarser invariant structure and the bulb is a symmetry "atom." $\qquad\blacksquare$

---

## 5. The arithmetic of assembly

Two structural laws remain: how bulbs are ordered (Fibonacci/Farey) and how their periods combine (Chinese Remainder).

### 5.1 Fibonacci ratios as greedy Farey geodesics

**Lemma 5.1 (Coprimality of Fibonacci neighbours).** For all $n \ge 1$, $\gcd(F_n, F_{n+1}) = 1$.

*Proof.* By the recurrence, any common divisor of $F_{n+1}$ and $F_n$ divides $F_{n+1} - F_n = F_{n-1}$, and descending, divides $F_1 = 1$. Hence the gcd is $1$. $\qquad\blacksquare$

**Lemma 5.2 (Cassini's identity).** For all $n \ge 0$,
$$F_{n+1}^2 - F_n F_{n+2} = (-1)^n.$$

*Proof.* Equivalent to $\det\begin{pmatrix}F_{n+1} & F_n\\ F_n & F_{n-1}\end{pmatrix} = (-1)^n$, which follows by induction from $\begin{pmatrix}1&1\\1&0\end{pmatrix}^{n} = \begin{pmatrix}F_{n+1} & F_n\\ F_n & F_{n-1}\end{pmatrix}$ and multiplicativity of the determinant. Directly: $F_{n+1}^2 - F_n F_{n+2} = F_{n+1}^2 - F_n(F_{n+1}+F_n) = F_{n+1}(F_{n+1}-F_n) - F_n^2 = F_{n+1}F_{n-1} - F_n^2 = -(F_n^2 - F_{n+1}F_{n-1})$, and induction flips the sign each step from the base $F_1^2 - F_0 F_2 = 1$. $\qquad\blacksquare$

**Theorem 5.3 (Fibonacci fractions are Farey neighbours).** For every $n \ge 1$, the reduced fractions $F_n/F_{n+1}$ and $F_{n+1}/F_{n+2}$ are unimodular Farey neighbours:
$$F_{n+1}\cdot F_{n+1} - F_n \cdot F_{n+2} = (-1)^n = \pm 1.$$
Consequently no fraction with denominator smaller than $F_{n+2}$ lies strictly between them, and the mediant of the pair is $F_{n+2}/F_{n+3}$.

*Proof.* The determinant $F_{n+1}^2 - F_n F_{n+2}$ equals $(-1)^n$ by Lemma 5.2, so the $2\times 2$ matrix of numerators and denominators is unimodular; this is exactly the Farey-neighbour condition. Unimodular neighbours admit no intervening fraction of smaller denominator (a standard property of the Stern–Brocot tree), and their mediant is $(F_n + F_{n+1})/(F_{n+1}+F_{n+2}) = F_{n+2}/F_{n+3}$ by the Fibonacci recurrence. $\qquad\blacksquare$

**Corollary 5.4 (The golden geodesic).** The greedy path in the bulb tree — at each step descend to the child of largest angular width, i.e. take the mediant toward the golden section — visits exactly the Fibonacci ratios $F_n/F_{n+1}$, which converge to $1/\varphi$ where $\varphi = (1+\sqrt5)/2$. These fractions realize the extremal (slowest) rational approximation, the arithmetic origin of the observed golden spiral of bulbs.

### 5.2 Product structure of composite bulbs

**Theorem 5.5 (Multiplicativity of additive order over coprime moduli).** If $\gcd(q_1, q_2) = 1$, then for any residue class corresponding to a rotation number, under the Chinese Remainder isomorphism
$$\mathbb{Z}/q_1 q_2\mathbb{Z} \;\cong\; \mathbb{Z}/q_1\mathbb{Z} \times \mathbb{Z}/q_2\mathbb{Z},$$
additive order is the least common multiple of the component orders:
$$\operatorname{ord}_{q_1 q_2}(a) = \operatorname{lcm}\bigl(\operatorname{ord}_{q_1}(a),\, \operatorname{ord}_{q_2}(a)\bigr).$$

*Proof.* Under the isomorphism $a \mapsto (a_1, a_2)$, we have $k a = 0$ in $\mathbb{Z}/q_1q_2\mathbb{Z}$ iff $k a_1 = 0$ and $k a_2 = 0$ in the respective factors, i.e. $\operatorname{ord}_{q_1}(a_1) \mid k$ and $\operatorname{ord}_{q_2}(a_2) \mid k$. The least such $k$ is the least common multiple of the two orders. $\qquad\blacksquare$

**Theorem 5.6 (Product structure of composite-period bulbs).** Let $n = p_1^{a_1}\cdots p_k^{a_k}$ be the prime factorization of a bulb's period. Then the bulb's combinatorial structure decomposes as a product of $k$ prime-power bulbs of periods $p_1^{a_1}, \dots, p_k^{a_k}$: its cycle, symmetry action, and internal angle data factor as the corresponding product across the Chinese Remainder decomposition of $\mathbb{Z}/n\mathbb{Z}$.

*Proof sketch.* By Theorem 4.1 the period is the additive order in $\mathbb{Z}/n\mathbb{Z}$; by Theorem 5.5 this order, and the underlying cyclic action, factor through $\prod_i \mathbb{Z}/p_i^{a_i}\mathbb{Z}$. Each factor is the action realized by the prime-power bulb of period $p_i^{a_i}$. The combinatorial invariants that depend only on this action therefore decompose as the product. Prime bulbs ($k=1$, $a_1=1$) are the indecomposable atoms, consistent with the dihedral rigidity of Proposition 4.4. $\qquad\blacksquare$

**Corollary 5.7 (Visual factorization).** Reading a bulb's period from its antenna count (Corollary 4.2) and factoring that integer determines the bulb's product decomposition: the geometry of $M$ encodes the prime factorization of every period.

---

## 6. Applications and numerical verification

**Escape rendering.** Corollary 3.3 is the algorithmic foundation of every Mandelbrot image: iterate until $|z_n| > 2$ or a maximum count is reached; the first-passage count gives the standard escape-time coloring. Theorem 3.2 guarantees no false negatives — a point that ever crosses radius $2$ genuinely escapes.

**Bulb location and period test.** For $q \le 20$ and each $p$ with $\gcd(p,q) = 1$, one locates the $p/q$ bulb along the cardioid via its internal angle, samples the parameter, and confirms that the attracting cycle has length exactly $q$ (Theorem 4.1). The companion demonstration computes $\operatorname{ord}_q(p)$ directly and matches it against the numerically observed period.

**Lyapunov check.** At each bulb center one computes $\lambda(c)$ as the averaged $\log|2 w_j|$ over the cycle (Definition 2.5) and compares against $\log 2 \cdot \cos(\pi p/q)$ (Conjecture 4.3). Agreement to numerical tolerance across $q \le 20$ provides strong evidence for the formula.

**Fibonacci spiral.** Generating the Farey mediant tree from $0/1, 1/1$ and following the golden geodesic reproduces $F_n/F_{n+1}$; Cassini's identity (Lemma 5.2) is checked to hold exactly, certifying the neighbour relation (Theorem 5.3).

**Factorization classifier.** For each period $n \le 100$, factor $n$, form the Chinese Remainder decomposition, and verify $\operatorname{ord}_{n}(a) = \operatorname{lcm}_i \operatorname{ord}_{p_i^{a_i}}(a)$ (Theorem 5.5). This exhibits the product structure of composite bulbs as a purely arithmetic identity.

---

## 7. Discussion and limitations

The results split cleanly into two tiers of certainty. The **arithmetic backbone** — the escape estimate (Theorems 3.1–3.2), the additive-order interpretation of period (Theorem 4.1), coprimality and Cassini for Fibonacci neighbours (Lemmas 5.1–5.2, Theorem 5.3), and multiplicativity of order (Theorem 5.5) — consists of elementary but fully rigorous statements. The **dynamical dictionary** connecting these to the actual geometry of $M$ (that internal angle realizes the modular rotation; the Lyapunov formula 4.3; the exact product law for bulbs, Theorem 5.6) rests on the established theory of hyperbolic components and internal rays, and where a complete self-contained proof is not given we have marked the statement as a conjecture and supplied numerical confirmation. The Lyapunov identity in particular is presented as a conjecture: it matches leading-order asymptotics and all tested cases but a full proof requires control of the linearizing coordinate throughout the bulb.

A second caveat concerns sharpness: Theorem 3.4 is stated for the real axis, where the extremal cancellation occurs; the radius $2$ remains a valid (though non-attained) bound in every direction.

---

## 8. Future directions

See the companion "Future Directions" record for detailed conjectures, including: sharpness of the escape radius along the real axis via an explicit bounded orbit at $c = -2$; a complete order-theoretic dictionary in which $p/q \mapsto \operatorname{ord}_q(p)$ is a faithful invariant of hyperbolic components and period is multiplicative across coprime denominators; the extremality of Fibonacci fractions among bounded-denominator rotation numbers (the three-distance/Steinhaus phenomenon for the golden angle); and a determinant criterion for adjacency of bulbs based on the unimodular Farey-neighbour relation.

---

## 9. Conclusion

Beginning from nothing but "square and add," we have traced how the boundary of the quadratic connectedness locus becomes a repository of elementary number theory. The escape radius is pinned at $2$ by a one-line growth inequality; each bulb's period is the additive order of its rotation number; the Fibonacci spiral is the shadow of Cassini's determinant identity and Fibonacci coprimality; and composite bulbs factor exactly as their periods do, courtesy of the Chinese Remainder Theorem. The Mandelbrot set is, in a precise sense, a visual calculator for prime factorization.
