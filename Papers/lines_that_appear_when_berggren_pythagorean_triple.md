# A Fan at Every Fraction

### A guided tour of the star map hidden inside the Pythagorean triples

---

## 1. Where the picture comes from

Start with the oldest theorem in mathematics. A **primitive Pythagorean triple** is a triple of whole numbers $(a,b,c)$ with $a^2+b^2=c^2$ and no common factor: $(3,4,5)$, $(5,12,13)$, $(8,15,17)$, $(20,21,29)$, and infinitely many more.

Euclid showed that each of them is built from a pair of whole numbers. Call $(m,n)$ a **Euclid seed** if

$$0 < n < m, \qquad \gcd(m,n)=1, \qquad m+n \ \text{is odd},$$

and attach to it the triple

$$(a,b,c) = (m^2-n^2,\ 2mn,\ m^2+n^2).$$

This is a perfect dictionary: every primitive triple comes from exactly one seed. The seed $(2,1)$ gives $(3,4,5)$; the seed $(3,2)$ gives $(5,12,13)$; the seed $(4,1)$ gives $(15,8,17)$.

There is also a way to *grow* the seeds. Three simple rules,

$$B_1(m,n) = (2m-n,\ m), \qquad B_2(m,n) = (2m+n,\ m), \qquad B_3(m,n) = (m+2n,\ n),$$

each turn a seed into a seed, and starting from $(2,1)$ they produce every seed exactly once. The result is an infinite ternary tree — the [Berggren tree](https://en.wikipedia.org/wiki/Tree_of_primitive_Pythagorean_triples) — in which each triple has precisely three children and precisely one parent.

<details>
<summary><b>Why do the three rules keep a seed a seed?</b> (click to expand)</summary>

Take $B_1(m,n) = (2m-n, m)$. Positivity and the ordering are immediate from $0<n<m$: the new second coordinate is $m$, and $m < 2m-n$ because $n<m$. For coprimality, any common divisor of $2m-n$ and $m$ divides their combination $n$, hence divides $\gcd(m,n)=1$. For parity, the coordinate sum changes by $(2m-n)+m-(m+n) = 2(m-n)$, an even amount, so the oddness of $m+n$ survives. The other two rules are identical arguments.

</details>

Now plot the seeds. Send each one to the complex number

$$z(m,n) \;=\; \frac{n+i}{m} \;=\; \underbrace{\frac{n}{m}}_{\text{horizontal}} \;+\; i\,\underbrace{\frac1m}_{\text{height}},$$

a point in the upper half of the plane. The picture that results is the subject of everything below.

---

## 2. Look at it first

Before any theory: here is the map. Every dot is one Pythagorean triple. Drag the sliders to choose a fraction on the bottom edge, and watch the fan at that fraction light up.

{{interactive_demo:0}}

Three things should be immediately visible.

1. **The dots are not scattered.** They line up along straight rays that converge on points of the bottom edge.
2. **There is a fan at $0$ and a fan at $1$, but also at $1/2$, at $1/3$, at $1/5$, …** In fact, as you will see, at *every* fraction.
3. **The fans do not all look alike.** Some have a ray straight down the middle and rays at every level; others have a hole in the middle and only every second ray.

The rest of this page explains all three, exactly.

---

## 3. One integer explains the rays

Fix a fraction $p/q$ in lowest terms. Give every seed $(m,n)$ the integer

$$\chi \;=\; p\,m - q\,n,$$

its **charge at $p/q$**. Now do the one-line computation that starts everything:

$$\frac{p}{q} - \frac{n}{m} \;=\; \frac{pm-qn}{qm} \;=\; \frac{\chi}{q}\cdot\frac1m .$$

Read it geometrically. The left-hand side is how far the node sits horizontally from $p/q$; the right-hand side is $\chi/q$ times the node's height. That is the equation of a straight line through the boundary point $p/q$.

> **Star line theorem.** For every $p,q,m,n$,
> $$\frac{p}{q} - \operatorname{Re} z(m,n) \;=\; \frac{\chi}{q}\cdot \operatorname{Im} z(m,n).$$
> All seeds of a common charge at $p/q$ lie on one and the same Euclidean ray emanating from $p/q$.

**The rays of the picture are the level sets of the charge**, and since $p/q$ was arbitrary, there is one pencil of rays at every rational boundary point. The two conspicuous stars at $0$ and $1$ are just the cases $q=1$, where the charge is $-n$ and $m-n$.

<details>
<summary><b>What kind of curve is a ray, in hyperbolic terms?</b></summary>

The half-plane is not ordinary paper: with the length element $ds = |dz|/\operatorname{Im}z$ it is the [Poincaré model](https://en.wikipedia.org/wiki/Poincar%C3%A9_half-plane_model) of hyperbolic geometry, whose straight lines are vertical rays and semicircles meeting the real axis at right angles. A Euclidean line hitting the boundary at an *angle* is therefore not a geodesic. It is a **hypercycle**: a curve of constant distance from a geodesic.

*Hypercycle theorem.* If $x - \operatorname{Re}z = u\operatorname{Im}z$ and $\gamma_x$ is the vertical geodesic over $x$, then $d(z,\gamma_x) = \operatorname{arsinh}|u|$.

*Proof.* Write $y=\operatorname{Im}z$ and take a competitor $w = x+is$ on the geodesic. Since $(\operatorname{Re}z-x)^2 = u^2y^2$, the distance formula $\cosh d(z,w) = 1 + |z-w|^2/(2\operatorname{Im}z\operatorname{Im}w)$ becomes
$$\cosh d(z,w) = \frac{(1+u^2)y^2 + s^2}{2ys} \ \ge\ \sqrt{1+u^2}$$
by the arithmetic–geometric mean inequality, with equality exactly at $s = y\sqrt{1+u^2}$. Finally $\operatorname{arcosh}\sqrt{1+u^2} = \operatorname{arsinh}|u|$. $\blacksquare$

Applying this with $u = \chi/q$: the node $z(m,n)$ lies at hyperbolic distance exactly
$$\operatorname{arsinh}\!\left(\frac{|\chi|}{q}\right)$$
from the geodesic over $p/q$. **The charge is a hyperbolic width**, and a fan is a quantised ladder of hypercycles at the levels $\operatorname{arsinh}(1/q), \operatorname{arsinh}(2/q), \ldots$

</details>

Hover any node in the map above and the readout gives you its charge at the selected centre, the corresponding hypercycle level, and the approximation error — all three are the same number in different clothes.

---

## 4. Why some fans have holes: a parity rule

Here is where arithmetic bites. A Euclid seed always has $m+n$ odd. Suppose $p$ and $q$ are **both odd** — the fractions $1/3$, $1/5$, $3/5$, and also $1/1$. Then, working modulo $2$,

$$\chi = pm - qn \equiv m - n \equiv m+n \equiv 1.$$

Every charge at such a centre is **odd**. The rays of even charge exist as lines, but no node of the tree ever lands on them. Half the fan is switched off.

And when $p+q$ is odd — $1/2$, $1/4$, $2/5$, and $0/1$ — no obstruction exists, and in fact *every* integer charge is realised, by infinitely many nodes.

> **Realisation theorem.** For a fraction $p/q$ strictly between $0$ and $1$ in lowest terms, the charges realised by Euclid seeds are:
> all of $\mathbb{Z}$ when $p+q$ is odd; exactly the odd integers when $p+q$ is even. Every realised ray carries infinitely many nodes.

<details>
<summary><b>How do you prove that every admissible ray really is populated?</b></summary>

By a change of variables that is a change of basis. Because $\gcd(p,q)=1$ we may choose $a,b$ with $pb-qa=1$, and then the general integral solution of $pm-qn=k$ is

$$(m,n) \;=\; \sigma(k,s) \;=\; (kb+sq,\ ka+sp), \qquad s \in \mathbb{Z}.$$

This substitution has determinant $1$, so it transports arithmetic faithfully:

- the charge is $k$ identically in $s$, since $p(kb+sq) - q(ka+sp) = k(pb-qa) = k$;
- the parameter is recovered by $s = b\,n - a\,m$, so the map is invertible over $\mathbb{Z}$;
- **$\gcd(m,n)=1$ if and only if $\gcd(k,s)=1$** — both directions come straight from the two Bézout relations above;
- $m+n = k(a+b) + s(p+q)$, an explicit affine function of $s$.

Now assemble a seed. Ordering ($0<n<m$) holds for every $s$ past the explicit bound $S_0 = |ka|+|kb|+|k(b-a)|+1$. Primitivity is $\gcd(k,s)=1$. Parity: if $p+q$ is even then $p,q$ are both odd, $pb-qa=1$ forces $a+b$ odd, and $m+n = k(a+b)+s(p+q)$ is odd $+$ even $=$ odd for *every* $s$, provided $k$ is odd — the condition is free. If $p+q$ is odd, parity is a single congruence $s\equiv\epsilon\pmod2$. Either way one can take $s = 1+2j|k|$ (odd, coprime to $k$) or $s = 2+2j|k|$ (even, coprime to $k$ when $k$ is odd) and let $j\to\infty$. Since $m = kb+sq\to\infty$, the ray contains nodes of arbitrarily large size, hence infinitely many. $\blacksquare$

</details>

There is a matching statement about the *axis* of a fan — the vertical ray of charge $0$.

> **Axis theorem.** A Euclid seed has charge $0$ at $p/q$ if and only if $(m,n) = (q,p)$. Such a seed exists precisely when $p+q$ is odd.

Which means: a fan has at most **one** node sitting exactly on its centre line. At $p/q = 1/2$ that node is $(2,1)$ — the root of the whole tree, the seed of $(3,4,5)$. It is circled in white in the map above.

Run the census yourself: the following program enumerates every seed up to a bound, tabulates which charges occur at a list of centres, and confirms the parity dichotomy and the axis theorem empirically.

{{demo:0}}

---

## 5. Why you only see a handful of fans

If every fraction carries a fan, why does the picture show a dozen? Because fans have *width*, and width is $1/q$.

> **Separation law.** Two nodes at the same height $y$ whose charges at $p/q$ differ by $d$ are separated horizontally by exactly $|d|\,y/q$. In particular adjacent rays are $y/q$ apart.

So if a plot resolves features of size $\varepsilon$, the fan at $p/q$ is visible *as a fan* exactly when

$$\frac{y}{q} \ \ge\ \varepsilon \qquad\Longleftrightarrow\qquad q \ \le\ \frac{y}{\varepsilon}.$$

A geometric question — which fans does the plot resolve? — has just become a purely arithmetic one. The visible centres are precisely the fractions of denominator at most $Q = \lfloor y/\varepsilon\rfloor$: the [Farey fractions](https://en.wikipedia.org/wiki/Farey_sequence) of level $Q$. Their number in $(0,1]$ is

$$\Phi(Q) \;=\; \sum_{q=1}^{Q}\varphi(q),$$

with $\varphi$ [Euler's totient function](https://en.wikipedia.org/wiki/Euler%27s_totient_function). At height $y = 0.5$ and resolution one part in ten, $Q = 5$ and $\Phi(5) = 1+1+2+2+4 = 10$: the centres $1/1, 1/2, 1/3, 2/3, 1/4, 3/4, 1/5, 2/5, 3/5, 4/5$ — precisely what the eye picks out.

Move the *resolution* slider in the map above and watch the faint fans appear and disappear tier by tier; the chip list shows exactly which centres are resolved.

{{algorithm:1}}

Since $\Phi(Q) \sim 3Q^2/\pi^2$, doubling the resolution roughly quadruples the number of visible fans. This is what the left panel of the following figure shows; the right panel previews the next section.

{{visualization:1}}

---

## 6. A low ray means a good approximation

The identity behind the rays can be rearranged into a dictionary between geometry and Diophantine approximation:

$$\frac{n}{m} - \frac{p}{q} \;=\; \frac{-\chi}{q\,m}, \qquad\text{so}\qquad \left|\frac nm - \frac pq\right| \le \frac{K}{qm} \iff |\chi| \le K.$$

**Small charge means good approximation.** The innermost rays of a fan, $|\chi| = 1$, are the nodes whose slope is a *Farey neighbour* of the centre — a unimodular partner, $qn-pm = \pm1$.

<details>
<summary><b>Farey's theorem, and why the innermost ray is unimprovable</b></summary>

*Theorem.* If $qn - pm = 1$ with $q,m>0$, then no fraction $r/s$ with $0<s<q+m$ lies strictly between $p/q$ and $n/m$.

*Proof.* If $p/q < r/s < n/m$ then $rq-ps$ and $ns-rm$ are both positive integers, hence both at least $1$. Multiply the first by $m$, the second by $q$, and add:
$$m(rq-ps) + q(ns-rm) = s(qn-pm) = s,$$
so $s \ge m+q$. $\blacksquare$

*Sharpness.* The mediant $(p+n)/(q+m)$ lies strictly between the two fractions, because $(p+n)/(q+m)-p/q = 1/(q(q+m))>0$ and $n/m-(p+n)/(q+m) = 1/(m(q+m))>0$. So the bound $q+m$ is attained.

</details>

The relation is reciprocal, and this is one of the prettiest consequences of the whole story:

> **Two principal stars.** Every Euclid seed with $m\ge2$ is a Farey neighbour of two distinct fractions of denominator smaller than $m$ — one giving charge $-1$, the other charge $+1$. Every node of the tree is an innermost spoke of at least two of the visible fans.

Nothing in the star map is a bystander.

---

## 7. How thick is a single ray?

A ray is infinite, but not uniformly dense — and the sparsity is measured by a totient. Take a centre with $p$ and $q$ both odd, and a ray of odd charge $k$. Using the unimodular parametrisation $(m,n) = (kb+sq,\ ka+sp)$: the parity condition is automatic, so the parametrised pair is a genuine seed **exactly when $\gcd(|k|,s)=1$**. Counting coprime residues in a window then gives an exact periodic law.

> **Totient density law.** In any window of $2|k|$ consecutive parameters (past the starting bound), the ray of charge $k$ carries exactly $2\varphi(|k|)$ nodes. The ray therefore has arithmetic density $\varphi(|k|)/|k|$.

The spoke of charge $1$ is completely full; the spoke of charge $3$ is two-thirds full; the spoke of charge $15$ is only $8/15$ full and is visibly dotted. **The faint rays of the picture are the ones of highly composite charge.**

Explore the mechanism directly below: choose a centre and a charge, and step through the parameter window one value at a time. Green rows are the parameters that produce a genuine Pythagorean triple; grey rows are the ones killed by a common factor with $k$. Slide the window offset and note that the count never changes.

{{interactive_demo:1}}

Then run the counting law at scale:

{{demo:1}}

<details>
<summary><b>Why exactly <code>2φ(K)</code>, and what happens to the even parameters</b></summary>

A window of $2K$ consecutive integers splits into two blocks of $K$, each a complete residue system modulo $K$, each therefore containing exactly $\varphi(K)$ integers coprime to $K$ — total $2\varphi(K)$.

The split by parity is also exact: coprimality to $2K$ is the same as coprimality to $K$ *together with* oddness, and a window of length $2K$ contains exactly $\varphi(2K)$ integers coprime to $2K$. So the odd parameters contribute $\varphi(2K)$ and the even ones $2\varphi(K)-\varphi(2K)$. When $K$ is odd, $\varphi(2K)=\varphi(K)$ and the two classes are perfectly balanced.

This is exactly what is observed numerically: at a centre with $p+q$ *odd*, where the parity condition selects one class of parameters instead of being automatic, the measured density drops by a further factor of $2$ precisely when $K$ is odd.

</details>

---

## 8. The tree shuffles the fans

One last surprise. The three growth rules do not merely move nodes — they move whole fans. Each rule has a shadow acting on the pair $(p,q)$ labelling a fan:

$$T_1(p,q) = (2p-q,\ p), \qquad T_2(p,q) = (2p-q,\ -p), \qquad T_3(p,q) = (p,\ q-2p),$$

and the charge is exactly covariant: *the charge of a moved node at the old fan equals the charge of the original node at the new fan.*

Two consequences, one structural and one visual.

**Infinitely many fans are one fan.** Since $T_1(k+1,k+2) = (k,k+1)$, applying $B_1$ exactly $k$ times carries the fan at $k/(k+1)$ onto the fan at $0$. The fans at $1/2, 2/3, 3/4, 4/5,\ldots$ marching towards the ideal point $1$ are all transported copies of the fan at $0$ — and each of them, having odd parameter sum, is full.

**The asymmetry is permanent.** The parity of $p+q$ is *invariant* under transport:

$$(2p-q)+p \equiv (2p-q)-p \equiv p+(q-2p) \equiv p+q \pmod 2 .$$

Since the fan at $0$ has parameter sum $1$ and the fan at $1$ has parameter sum $2$, **no word in the three rules can ever turn one into the other.** The lopsidedness of the picture's two most conspicuous stars is not an accident of where we chose to root the tree: it is a conserved quantity.

{{algorithm:2}}

---

## 9. The whole picture, in one figure

Everything above, drawn at once: the node set, the two classical fans, the fans at $1/2$, $1/3$ and $1/5$ with exactly their realised charges, the nested hyperbolic circles, and the root of the tree sitting on the axis of the fan at $0.5$.

{{visualization:0}}

And the tool that generates any single ray on demand, from a centre and a charge, in time proportional to the number of nodes it returns:

{{algorithm:0}}

---

## 10. What the picture is

Step back. A tree of Pythagorean triples, plotted through a two-thousand-year-old parametrisation into a nineteenth-century geometry, produces a star map whose every feature is an exact statement about the rationals:

| what you see | what it is |
|---|---|
| a fan at each fraction | the level sets of the charge $\chi = pm-qn$ |
| a straight ray | a hypercycle at distance $\operatorname{arsinh}(|\chi|/q)$ from a geodesic |
| holes in some fans | $p,q$ both odd forces $\chi$ odd |
| a node dead-centre in others | the unique axis node $(q,p)$, existing iff $p+q$ is odd |
| only a dozen fans visible | the Farey fractions of level $\lfloor y/\varepsilon\rfloor$, counted by $\sum_{q\le Q}\varphi(q)$ |
| the brightest spokes | best rational approximations to the fan's centre |
| some rays faint and dotted | arithmetic density $\varphi(|k|)/|k|$ |
| the lopsided pair of big stars | a parity class that no tree move can change |

The picture, in other words, is not a picture *of* Pythagorean triples. It is a picture of the rational numbers, and the triples are the ink.
