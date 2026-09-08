# Oscillation Counting and the Exact Depth–Width Trade-off for Rectifier Networks

**Author:** Aristotle
**Date:** 2026-09-08

---

## Abstract

We develop, from first principles, a complete and unconditional account of the depth–width trade-off for feed-forward networks with the rectified linear activation $\mathrm{relu}(t)=\max(t,0)$, using a single tool: the propagation of *knots* (breakpoints of a piecewise affine function) through the layers of a network, matched against the number of *oscillations* a target function forces upon any approximant.

On the lower-bound side we prove that a network of depth $L$ and width $w$ with one real input computes a continuous piecewise affine function with at most $2(2w+2)^L$ knots, and that any function remaining within $1/4$ of the $k$-fold sawtooth tower $\tau^{\circ k}$ uniformly on $[0,1]$ has at least $(2^k-1)/2$ knots. Combining these gives the master inequality $2^k \le 4(2w+2)^L$. Specialising to $k=L^2+4$ yields a *depth separation*: the explicit function $\tau^{\circ(L^2+4)}$ is computed exactly by a network of depth $L^2+4$ and width $3$ — size $3(L^2+4)$, polynomial in $L$ — while every depth-$L$ network approximating it within $1/4$ has width at least $2^{L-1}-1$.

We then strengthen the separation in three independent directions: to the $L^1$ norm, where the integrated error of any depth-$L$, width-$w$ network against $\tau^{\circ k}$ is at least $\bigl(2^{k-1}-2(2w+2)^L\bigr)/(16\cdot 2^k) \to 1/32$; to a *density* statement, where the network is wrong by more than $1/4$ at a positive fraction (at least $1/3-o(1)$) of the $2^k+1$ dyadic sample points; and to arbitrary input dimension $D$ via a restriction principle, giving a dimension-free bound for ridge witnesses.

Finally, and in the opposite direction, we prove a matching *collapse* theorem which delimits exactly how strong such separations can be. For every $c\ge 1$ the entire height-$c$ tower is realised by a **single** rectifier layer of width $2^c+1$:
$$\tau^{\circ c}(y) \;=\; \sum_{i=0}^{2^c} a_i\,\mathrm{relu}\!\left(y-\frac{i}{2^c}\right),\qquad a_0=a_{2^c}=2^c,\ a_i=(-1)^i2^{c+1}\ \text{else}.$$
Consequently $\tau^{\circ cL}$ is computed exactly at depth $L$ and width $2^c+1$; the "one extra layer" form of the separation conjecture is *false* for sawtooth witnesses ($\tau^{\circ(L+1)}$ is an exact depth-$L$, width-$5$ network), and even a logarithmic depth gap costs only polynomial size. We prove the sharp bracket: at depth $L$ and width $2^c+1$ the maximal exactly computable tower height $k$ satisfies $cL \le k \le (c+3)L+2$, so the exactly achievable complexity is $\Theta(L\log w)$.

**Keywords:** rectifier networks, depth separation, piecewise affine functions, knot counting, sawtooth tower, oscillation bounds, expressivity.

---

## 1. Introduction

### 1.1 The question

Feed-forward networks with rectified linear units compute continuous piecewise affine functions, and nothing else. This makes the expressivity question concrete: *which* piecewise affine functions can a network of depth $L$ and width $w$ compute, and how does the answer change as we trade depth for width?

The folklore answer is that depth is exponentially more valuable than width, because complexity *composes* multiplicatively across layers while it merely *accumulates* additively within a layer. The canonical evidence is the iterated sawtooth: the tent map $\tau$ is one narrow layer, and $k$ layers produce a function with $2^{k-1}$ teeth. If one can show that shallow networks need width exponential in the number of teeth, one obtains a genuine depth separation.

Two questions remain, and this paper answers both.

1. **How strong is the separation, precisely?** We prove an unconditional master inequality $2^k \le 4(2w+2)^L$ for approximation within $1/4$, and derive from it exponential lower bounds in sup-norm, in $L^1$, in density on a sample grid, and in arbitrary input dimension.
2. **How strong *can* it be?** We prove a matching upper bound showing that the naive "depth $L{+}1$ versus depth $L$" conjecture is *false* for the canonical witnesses: sawtooth towers of height $L+O(\log L)$ collapse to depth $L$ at polynomial size. The relevant parameter is the ratio $k/L$, which must be unbounded, and we determine the exact linear-in-$L$, logarithmic-in-$w$ law governing exact computability.

### 1.2 Summary of contributions

* A self-contained *knot calculus* for piecewise affine functions on $[0,1]$: affine read-outs preserve the knot set; post-composition with $\mathrm{relu}$ multiplies the knot count by at most $2$ and adds at most $4$ (Section 3).
* The knot budget $2(2w+2)^L$ for depth-$L$, width-$w$ networks (Theorem 4.4).
* The oscillation lower bound: alternation between a low band and a high band at $m+1$ ordered points forces $m \le 2|S|+1$ knots (Theorem 5.2), and the tower $\tau^{\circ k}$ alternates at $2^k+1$ dyadic points (Lemma 5.3).
* The master inequality and the depth separation with explicit polynomial-size witness (Theorems 6.1–6.3).
* $L^1$ separation (Theorem 7.3), failure density (Theorem 7.5), dimension-free ridge separation (Theorem 7.7).
* The one-layer realisation of an entire tower (Theorem 8.3), the collapse theorems (Theorems 8.4–8.6), and the sharp tower-height bracket $cL\le k\le (c+3)L+2$ (Theorem 8.7).

---

## 2. Setting and definitions

Throughout, $\mathrm{relu}(t) = \max(t,0)$ for $t\in\mathbb{R}$.

**Definition 2.1 (Layer units).** Fix a width bound $w\in\mathbb{N}$. The families of *layer-$L$ unit functions* of a rectifier network with one real input are defined inductively.

* *Input layer:* the single-element family $u_1(x)=x$ is a layer-$0$ family.
* *Step:* if $(u_1,\dots,u_n)$ is a layer-$L$ family, $m\le w$, $W\in\mathbb{R}^{m\times n}$ and $b\in\mathbb{R}^m$, then the family
  $$v_j(x) \;=\; \mathrm{relu}\!\left(\sum_{i=1}^{n} W_{ji}\,u_i(x) + b_j\right),\qquad j=1,\dots,m,$$
  is a layer-$(L{+}1)$ family.

**Definition 2.2 (Networks).** We say $f:\mathbb{R}\to\mathbb{R}$ *is a depth-$L$, width-$w$ network*, written $f\in\mathcal{N}(w,L)$, if there is a layer-$L$ family $(u_1,\dots,u_n)$, coefficients $c\in\mathbb{R}^n$ and $d\in\mathbb{R}$ with
$$f(x) \;=\; \sum_{i=1}^n c_i u_i(x) + d \qquad (x\in\mathbb{R}).$$

Thus the network has $L$ hidden rectifier layers, each of width at most $w$, followed by a linear read-out. Its *size* (number of hidden units) is at most $wL$. Note $\mathcal{N}(w,L)\subseteq\mathcal{N}(w',L)$ for $w\le w'$.

**Definition 2.3 (Sawtooth).** The tent map is
$$\tau(y) \;=\; 2\,\mathrm{relu}(y)-4\,\mathrm{relu}\!\left(y-\tfrac12\right)+2\,\mathrm{relu}(y-1).$$
Equivalently $\tau(y)=0$ for $y\le 0$ and for $y\ge 1$, $\tau(y)=2y$ on $[0,\tfrac12]$, and $\tau(y)=2-2y$ on $[\tfrac12,1]$. We write $\tau^{\circ k}$ for the $k$-fold composite ($\tau^{\circ 0}=\mathrm{id}$), the *sawtooth tower of height $k$*.

Immediately from Definition 2.3: $\tau \in \mathcal{N}(3,1)$ with read-out weights $(2,-4,2)$ and biases $(0,-\tfrac12,-1)$.

**Definition 2.4 (Affine on an interval).** $f$ is *affine on $[u,v]$*, written $\mathrm{Aff}(f;u,v)$, if there exist $a,b\in\mathbb{R}$ with $f(x)=ax+b$ for all $x\in[u,v]$.

**Definition 2.5 (Knot set).** For a finite set $S\subset\mathbb{R}$ we say $f$ *is piecewise affine with knot set $S$*, written $\mathrm{PWA}(S,f)$, if for all $0\le u\le v\le 1$ such that every $z \in S$ satisfies $z\le u$ or $v\le z$, we have $\mathrm{Aff}(f;u,v)$.

In words: $f$ is straight on every subinterval of $[0,1]$ whose interior misses $S$. The definition is deliberately one-sided — $S$ is an *upper bound* on the breakpoints, not the exact breakpoint set — which is what makes it easy to propagate. Note the monotonicity: $\mathrm{PWA}(S,f)$ and $S\subseteq T$ imply $\mathrm{PWA}(T,f)$.

---

## 3. The knot calculus

**Lemma 3.1 (Affine functions have no knots).** For all $a,b$, $\mathrm{PWA}(\varnothing, x\mapsto ax+b)$. *Proof:* immediate. $\square$

**Lemma 3.2 (Affine read-outs are free).** Let $f_1,\dots,f_n$ satisfy $\mathrm{PWA}(S,f_i)$ for a common finite $S$, let $c\in\mathbb{R}^n$, $d\in\mathbb{R}$. Then
$$\mathrm{PWA}\Bigl(S,\ x\mapsto \sum_i c_i f_i(x)+d\Bigr).$$

*Proof.* Fix an admissible $[u,v]$. Choose $A_i,B_i$ with $f_i(x)=A_ix+B_i$ on $[u,v]$. Then $\sum_i c_if_i(x)+d = \bigl(\sum_i c_iA_i\bigr)x + \bigl(\sum_i c_iB_i + d\bigr)$ on $[u,v]$. $\square$

The one substantive step is the effect of the rectifier.

**Lemma 3.3 (No crossing, no kink).** Suppose $f(x)=Ax+B$ on $[p,q]$, that $[u,v]\subseteq[p,q]$, and let
$$\zeta \;=\; \begin{cases} p, & A=0,\\ -B/A, & A\ne 0\end{cases}$$
be the (unique, when $A\neq0$) zero of the affine piece. If $\zeta\le u$ or $v\le \zeta$, then $\mathrm{Aff}(\mathrm{relu}\circ f; u,v)$.

*Proof.* If $A=0$ then $\mathrm{relu}(f(x))=\mathrm{relu}(B)$ is constant on $[u,v]$. If $A>0$ and $\zeta\le u$ then $Ax+B\ge A\zeta+B = 0$ on $[u,v]$, so $\mathrm{relu}\circ f = Ax+B$ there; if $v\le\zeta$ then $Ax+B\le 0$ and $\mathrm{relu}\circ f \equiv 0$. The case $A<0$ is symmetric with the two conclusions exchanged. $\square$

**Theorem 3.4 (The rectifier step).** If $\mathrm{PWA}(S,f)$, then there exists a finite $T$ with
$$|T| \;\le\; 2|S| + 4 \qquad\text{and}\qquad \mathrm{PWA}\bigl(T,\ \mathrm{relu}\circ f\bigr).$$

*Proof sketch.* First normalise: replace $S$ by $S' = \{0,1\}\cup (S\cap[0,1])$, so $|S'|\le |S|+2$, every element of $S'$ lies in $[0,1]$, and still $\mathrm{PWA}(S',f)$ (dropping knots outside $[0,1]$ is harmless because admissible intervals lie inside $[0,1]$, and adding $0,1$ only shrinks the family of admissible intervals). The points of $S'$ cut $[0,1]$ into gaps. For $p \in S'$ let $\mathrm{nxt}(p)$ be the least element of $S'$ exceeding $p$ (or $1$ if none), so that $f$ is affine on $[p,\mathrm{nxt}(p)]$, say $f(x)=A_px+B_p$ there, and let $\mathrm{cross}(p)$ be the corresponding zero $\zeta$ from Lemma 3.3. Set
$$T \;=\; S' \cup \mathrm{cross}(S').$$
Then $|T| \le 2|S'| \le 2|S|+4$. Given an admissible $[u,v]$ for $T$ (a subinterval of $[0,1]$ whose interior misses $T$), if $u=v$ the claim is trivial; otherwise let $p$ be the largest element of $S'$ with $p\le u$ (it exists since $0\in S'$). Because $(u,v)$ misses $S'$ we get $v\le \mathrm{nxt}(p)$, so $[u,v]\subseteq[p,\mathrm{nxt}(p)]$ and $f$ is affine there; and because $(u,v)$ also misses $\mathrm{cross}(p)\in T$, the hypothesis of Lemma 3.3 holds. Hence $\mathrm{relu}\circ f$ is affine on $[u,v]$. $\square$

The bound "$2|S|+4$" is the normalised form of the sharper statement "one new knot per affine piece": a function with $|S|$ knots has at most $|S|+1$ pieces inside $[0,1]$, and each contributes at most one zero crossing.

---

## 4. The knot budget of a network

**Definition 4.1.** Let $\kappa(w,0)=0$ and $\kappa(w,L+1) = w\bigl(2\kappa(w,L)+4\bigr)$.

**Theorem 4.2 (Layer-wise budget).** If $(u_1,\dots,u_n)$ is a layer-$L$ family for width bound $w$, then there is a finite $S$ with $|S|\le \kappa(w,L)$ and $\mathrm{PWA}(S,u_i)$ for every $i$.

*Proof.* Induction on the layer structure. For the input layer, $u_1(x) = 1\cdot x + 0$ is affine, so $S=\varnothing$ works. For the step, let $S$ be a common knot set for the previous family with $|S|\le\kappa(w,L)$. Each pre-activation $\sum_i W_{ji}u_i + b_j$ has knot set $S$ by Lemma 3.2; by Theorem 3.4 each rectified unit $v_j$ has a knot set $T_j$ with $|T_j| \le 2|S|+4$. Take $T=\bigcup_{j\le m} T_j$; by monotonicity every $v_j$ is $\mathrm{PWA}(T,\cdot)$, and
$$|T| \le \sum_{j=1}^m |T_j| \le m(2|S|+4) \le w\bigl(2\kappa(w,L)+4\bigr) = \kappa(w,L+1).\qquad\square$$

**Corollary 4.3.** If $f\in\mathcal{N}(w,L)$ then there is $S$ with $|S|\le\kappa(w,L)$ and $\mathrm{PWA}(S,f)$ (apply Lemma 3.2 to the read-out).

**Theorem 4.4 (Closed form).** For all $w,L$: $\ \kappa(w,L)+2 \;\le\; 2(2w+2)^L$.

*Proof.* Induction on $L$. For $L=0$, $0+2 \le 2$. For the step, write $\kappa(w,L+1)+2 = 2w\bigl(\kappa(w,L)+2\bigr)+2 \le 2w\cdot 2(2w+2)^L + 2 \le 2(2w+2)^{L+1}$, the last step because $2(2w+2)^{L+1} - 4w(2w+2)^L = 4(2w+2)^L \ge 4 \ge 2$. $\square$

So: **a depth-$L$, width-$w$ rectifier network computes a piecewise affine function with at most $2(2w+2)^L$ knots.** Knots multiply with depth and add with width; this asymmetry is the entire source of the power of depth.

---

## 5. Oscillation forces knots

**Lemma 5.1 (An affine function cannot go low–high–low).** Let $x_1<x_2<x_3$ and suppose $f$ is affine on $[x_1,x_3]$ with $f(x_1)\le 1/4$, $f(x_2)\ge 3/4$, $f(x_3)\le 1/4$. Then a contradiction follows.

*Proof.* Write $f(x)=ax+b$. Then $a(x_2-x_1)\ge 1/2 >0$ forces $a>0$, while $a(x_3-x_2)\le -1/2<0$ forces $a<0$. $\square$

(The mirrored statement — an affine function cannot go high–low–high — has the identical proof, and is used for the density theorem.)

**Theorem 5.2 (Alternation costs knots).** Let $\mathrm{PWA}(S,f)$ and let $0\le p_0<p_1<\dots<p_m\le 1$ be points at which $f$ alternates between the bands, i.e. $f(p_j)\le 1/4$ for even $j$ and $f(p_j)\ge 3/4$ for odd $j$ (or vice versa). Then
$$m \;\le\; 2|S|+1.$$

*Proof sketch.* Consider the $\lfloor m/2\rfloor$ disjoint triples of consecutive indices $(p_{2t},p_{2t+1},p_{2t+2})$. Each triple exhibits a low–high–low (or high–low–high) pattern, so by Lemma 5.1 the function is *not* affine on $[p_{2t},p_{2t+2}]$; by Definition 2.5 the open interval $(p_{2t},p_{2t+2})$ must therefore contain a point of $S$. The triples overlap only at endpoints, so the associated knots are distinct, giving $\lfloor m/2 \rfloor \le |S|$, i.e. $m\le 2|S|+1$. $\square$

**Lemma 5.3 (The tower alternates at dyadic points).** For all $k\ge 0$ and all integers $0\le i\le 2^k$,
$$\tau^{\circ k}\!\left(\frac{i}{2^k}\right) \;=\; \begin{cases} 0, & i \text{ even},\\ 1, & i \text{ odd}.\end{cases}$$

*Proof sketch.* Induction on $k$. For $k=0$ the claim is $\tau^{\circ0}(i)=i$ for $i\in\{0,1\}$. For the step, apply $\tau$ once to $i/2^{k+1}$: if $i=2j$ is even, $\tau(2j/2^{k+1})$ falls at the dyadic point $j/2^k$ of the next level down after one fold... More precisely, one verifies directly from the two affine branches of $\tau$ that $\tau(i/2^{k+1})$ equals $i/2^k$ when $i\le 2^k$ and $2 - i/2^k$ when $i\ge 2^k$; in both cases $\tau^{\circ k}$ of the result is $0$ or $1$ according to the parity of $i$, using the induction hypothesis together with the symmetry $\tau^{\circ k}(2-y)$ for the reflected branch. $\square$

**Theorem 5.4 (Approximation costs knots).** Let $\mathrm{PWA}(S,f)$ and suppose $|f(x)-\tau^{\circ k}(x)|\le 1/4$ for all $x\in[0,1]$. Then
$$2^k \;\le\; 2|S|+1.$$

*Proof.* Take $p_j = j/2^k$ for $j=0,\dots,2^k$. By Lemma 5.3 and the error hypothesis, $f(p_j)\le 1/4$ for even $j$ and $f(p_j)\ge 3/4$ for odd $j$. Apply Theorem 5.2 with $m=2^k$. $\square$

Taking $f=\tau^{\circ k}$ itself ($\varepsilon = 0$) shows that even an *exact* piecewise affine representation of the height-$k$ tower needs at least $(2^k-1)/2$ knots.

---

## 6. The depth separation

**Theorem 6.1 (Master inequality).** Let $f\in\mathcal{N}(w,L)$ with $|f(x)-\tau^{\circ k}(x)|\le 1/4$ for all $x\in[0,1]$. Then
$$2^k \;\le\; 4\,(2w+2)^L.$$

*Proof.* By Corollary 4.3 pick $S$ with $|S|\le\kappa(w,L)$, $\mathrm{PWA}(S,f)$. Theorem 5.4 gives $2^k\le 2|S|+1 \le 2\kappa(w,L)+1$, and Theorem 4.4 gives $\kappa(w,L)\le 2(2w+2)^L-2$, whence $2^k \le 4(2w+2)^L-3$. $\square$

**Theorem 6.2 (Upper bound: the tower is cheap with depth).** For every $l\ge0$, $\tau^{\circ(l+1)} \in\mathcal{N}(3,l+1)$: the height-$k$ tower is computed *exactly* by a network of depth $k$ and width $3$, i.e. with $3k$ hidden units.

*Proof sketch.* One layer of three units with biases $0,-\tfrac12,-1$ and read-out $(2,-4,2)$ applied to any incoming value $y$ produces $\tau(y)$ exactly (Definition 2.3). Stacking such a layer on top of a subnetwork computing $\tau^{\circ l}$ therefore computes $\tau^{\circ(l+1)}$; induction on $l$ starting from the input layer completes the argument. $\square$

**Theorem 6.3 (Depth separation).** Let $L\ge1$, $w\ge0$, and let $f\in\mathcal{N}(w,L)$ satisfy $|f(x)-\tau^{\circ(L^2+4)}(x)|\le 1/4$ for all $x\in[0,1]$. Then
$$2^L \;\le\; 2w+2, \qquad\text{equivalently}\qquad w \;\ge\; 2^{L-1}-1.$$

*Proof.* Theorem 6.1 with $k=L^2+4$ gives $2^{L^2+4}\le 4(2w+2)^L$. Suppose for contradiction $2w+2<2^L$. Then $(2w+2)^L < (2^L)^L = 2^{L^2}$, so $16\cdot 2^{L^2} = 2^{L^2+4} \le 4(2w+2)^L < 4\cdot 2^{L^2}$, a contradiction. $\square$

**Corollary 6.4 (Separation summary).** For every $L\ge 1$:

* the explicit function $\tau^{\circ(L^2+4)}$ is a network of depth $L^2+4$ and width $3$, hence of size $3(L^2+4)$ — polynomial in $L$;
* every network of depth $L$ whose output is uniformly within $1/4$ of it on $[0,1]$ has width at least $2^{L-1}-1$, hence size at least $L(2^{L-1}-1)$ — exponential in $L$.

This is precisely the assertion "there are explicit functions represented by deep networks of polynomial size such that any depth-$L$ network approximating them within a fixed uniform tolerance has size exponential in $L$", with the deep witness of depth $L^2+4$.

---

## 7. Three strengthenings

### 7.1 Average-case ($L^1$) separation

Sup-norm statements can always be suspected of hinging on a single bad point. They do not.

**Lemma 7.1 (An affine function cannot be uniformly small).** For $a<b$ and any affine $g(x)=\alpha x+\beta$,
$$\int_a^b |g| \;\ge\; \frac{(b-a)\max\bigl(|g(a)|,|g(b)|\bigr)}{8}.$$

*Proof sketch.* Assume WLOG $M=|g(a)|\ge|g(b)|$ (else reflect). The slope obeys $|\alpha|(b-a)\le 2M$ by the triangle inequality, so on the quarter-interval $[a,a+(b-a)/4]$ we have $|g(x)| \ge M - |\alpha|(b-a)/4 \ge M/2$. Integrating over that quarter and discarding the rest gives $\int_a^b|g| \ge \frac{b-a}{4}\cdot\frac{M}{2} = \frac{(b-a)M}{8}$. $\square$

**Lemma 7.2 (An affine piece cannot track a tent).** Let $\mathrm{PWA}(S,f)$ with $f$ continuous, let $k\ge1$, and let $t$ index a full tooth $I_t=[2t/2^k,(2t+2)/2^k]$ whose interior contains no point of $S$. Then
$$\int_{I_t}\bigl|f-\tau^{\circ k}\bigr| \;\ge\; \frac{1}{16\cdot 2^k}.$$

*Proof sketch.* On $I_t$ the function $f$ is affine, and $\tau^{\circ k}$ is the tent that is $0$ at both endpoints and $1$ at the midpoint $m_t$. Consider the two half-teeth. On at least one of them, the affine error function $f-\tau^{\circ k}$ is itself affine (since $\tau^{\circ k}$ is affine on each half-tooth) and has $|{\cdot}|\ge 1/2$ at one endpoint — because $f$ cannot simultaneously be near $0$ at $2t/2^k$, near $1$ at $m_t$ and near $0$ at $(2t+2)/2^k$ (Lemma 5.1). Apply Lemma 7.1 on that half-tooth of length $1/2^k$ with $M\ge 1/2$: the integral is at least $\frac{1}{2^k}\cdot\frac{1/2}{8} = \frac{1}{16\cdot2^k}$. $\square$

**Theorem 7.3 ($L^1$ lower bound).** Let $k\ge1$, $\mathrm{PWA}(S,f)$ with $f$ continuous. Then
$$\int_0^1 \bigl|f-\tau^{\circ k}\bigr| \;\ge\; \frac{2^{k-1}-|S|}{16\cdot 2^k}.$$
Consequently, for $f\in\mathcal{N}(w,L)$ (networks are continuous),
$$\int_0^1 \bigl|f-\tau^{\circ k}\bigr| \;\ge\; \frac{2^{k-1}-2(2w+2)^L}{16\cdot 2^k}.$$

*Proof.* There are $2^{k-1}$ pairwise disjoint teeth; at most $|S|$ of them contain a knot. Apply Lemma 7.2 to each of the remaining $\ge 2^{k-1}-|S|$ teeth and sum, using the non-negativity of the integrand on the rest. The network form follows from Corollary 4.3 and Theorem 4.4. $\square$

With $k=L^2+4$ and $w<2^{L-1}-1$ the right-hand side tends to $\tfrac{1}{32}$: no subexponentially wide depth-$L$ network can even be *right on average*.

### 7.2 Failure has positive density

**Theorem 7.4 (Bad dyadic points).** Let $\mathrm{PWA}(S,f)$ and $k\ge0$. Then the number $\mathcal{B}$ of indices $j\in\{0,1,\dots,2^k\}$ with
$$\Bigl|f\bigl(j/2^k\bigr)-\tau^{\circ k}\bigl(j/2^k\bigr)\Bigr| \;>\; \tfrac14$$
satisfies $\ 2^k \le 3(\mathcal{B}+|S|)+2$, i.e. $\mathcal{B} \ge \frac{2^k-2}{3}-|S|$.

*Proof sketch.* Group the dyadic indices into consecutive triples $(3t,3t+1,3t+2)$-style blocks; in any block of three consecutive dyadic points at which $f$ is *good* (within $1/4$), the values of $f$ realise a low–high–low or high–low–high pattern by Lemma 5.3, so by Lemma 5.1 (and its mirror) the corresponding interval must contain a knot. Each knot can be charged by at most one such block, so the number of blocks containing no bad point is at most $|S|$; there are at least $(2^k-2)/3$ blocks in total. $\square$

**Theorem 7.5 (Network failure density).** For $f\in\mathcal{N}(w,L)$ the number of bad dyadic points satisfies $2^k \le 3\bigl(\mathcal{B}+2(2w+2)^L\bigr)+2$. For $k = L^2+4$ and $w<2^{L-1}-1$ this gives $\mathcal{B} \ge \bigl(\tfrac13-o(1)\bigr)2^k$: the shallow network is wrong at a constant fraction of all sample points.

### 7.3 Arbitrary input dimension

Let $\mathcal{N}_D(w,L)$ denote depth-$L$, width-$w$ networks with input in $\mathbb{R}^D$, defined exactly as in Definitions 2.1–2.2 with input layer $u_i(x)=x_i$, $i=1,\dots,D$.

**Theorem 7.6 (Restriction principle).** Let $F\in\mathcal{N}_D(w,L)$ and let $a,v\in\mathbb{R}^D$. Then the univariate restriction $t\mapsto F(a+tv)$ belongs to $\mathcal{N}(w,L)$.

*Proof sketch.* Induction on layers. Restricting the input units gives the affine functions $t\mapsto a_i+tv_i$; these are absorbed into the weights and biases of the first hidden layer, which is thereby exhibited as a legitimate first layer of a univariate network of the same width. All later layers are unchanged, since restriction commutes with weighted sums and with $\mathrm{relu}$. $\square$

**Theorem 7.7 (Dimension-free ridge separation).** Fix $D\ge1$, a coordinate index $i_0$, and $L\ge1$. The ridge function $x\mapsto \tau^{\circ(L^2+4)}(x_{i_0})$ lies in $\mathcal{N}_D(3, L^2+4)$; and every $F\in\mathcal{N}_D(w,L)$ with
$$\bigl|F(x)-\tau^{\circ(L^2+4)}(x_{i_0})\bigr|\le\tfrac14 \quad\text{for all } x\in[0,1]^D$$
satisfies $2^L\le 2w+2$. The bound is independent of $D$.

*Proof.* Restrict along the line $t\mapsto t\,e_{i_0}$, which stays in the unit cube for $t\in[0,1]$; by Theorem 7.6 the restriction is in $\mathcal{N}(w,L)$ and approximates $\tau^{\circ(L^2+4)}$ within $1/4$ on $[0,1]$. Apply Theorem 6.3. $\square$

The moral: additional input coordinates provide no leverage for imitating a ridge oscillation; the width penalty is $w$, not $w^D$.

---

## 8. How far can separations go? The collapse theorems

We now bound the phenomenon from the other side. The results of this section show that the *literal* one-step form of the depth-separation conjecture is false for sawtooth witnesses, and identify the exact regime in which separations survive.

**Theorem 8.1 (Double fold in one layer).** For all $y\in\mathbb{R}$,
$$\tau(\tau(y)) \;=\; 4\,\mathrm{relu}(y)-8\,\mathrm{relu}\!\left(y-\tfrac14\right)+8\,\mathrm{relu}\!\left(y-\tfrac12\right)-8\,\mathrm{relu}\!\left(y-\tfrac34\right)+4\,\mathrm{relu}(y-1).$$

*Proof sketch.* Both sides vanish for $y\le0$ and for $y\ge1$ (for the right side, the coefficients sum to $4-8+8-8+4=0$ and the first moment $\sum a_i\zeta_i$ also vanishes, so the function is identically zero beyond the last breakpoint). On each of the four quarters both sides are affine with slopes $4,-4,4,-4$ and matching values at the breakpoints. $\square$

**Theorem 8.2 (Affine pieces of a tower).** For $c\ge0$, $0\le m<2^c$, and $y\in[m/2^c,(m+1)/2^c]$,
$$\tau^{\circ c}(y) \;=\; \begin{cases} 2^c y - m, & m \text{ even},\\ (m+1)-2^cy, & m \text{ odd}.\end{cases}$$
Moreover $\tau^{\circ c}(y)=0$ for $y\le0$ and $y\ge1$ when $c\ge1$.

**Theorem 8.3 (One layer realises an entire tower).** For $c\ge1$ and all $y\in\mathbb{R}$,
$$\tau^{\circ c}(y) \;=\; \sum_{i=0}^{2^c} a^{(c)}_i\,\mathrm{relu}\!\left(y-\frac{i}{2^c}\right),\qquad a^{(c)}_i = \begin{cases} 2^c, & i=0 \text{ or } i=2^c,\\ (-1)^i\,2^{c+1}, & \text{otherwise}.\end{cases}$$
Hence $\tau^{\circ c}\in\mathcal{N}(2^c+1,1)$: the height-$c$ tower is a *single* rectifier layer of width $2^c+1$.

*Proof sketch.* Both sides vanish for $y\le0$. For $y$ in the $m$-th dyadic interval the right-hand side equals $\bigl(\sum_{i\le m}a_i\bigr)y - \sum_{i\le m}a_i\,i/2^c$; the partial sums are computed by telescoping the alternating coefficients: $\sum_{i\le m}a^{(c)}_i = (-1)^m 2^c$ and $\sum_{i\le m}a^{(c)}_i\,i/2^c = m$ if $m$ even, $-(m+1)$ if $m$ odd. Comparing with Theorem 8.2 gives equality on every dyadic interval. Finally, the total sum $\sum_{i=0}^{2^c}a^{(c)}_i$ and total moment both vanish (this is where the halved end coefficients matter), so the right-hand side is $0$ for $y\ge1$. $\square$

**Theorem 8.4 (Collapse of the one-step witness).** For $L\ge2$, $\ \tau^{\circ(L+1)}\in\mathcal{N}(5,L)$: the canonical depth-$(L{+}1)$ witness is computed *exactly* — with error $0$, not merely approximately — by a network of depth $L$ and width $5$, i.e. with $5L$ hidden units. In particular $\tau^{\circ(L+1)}$ is simultaneously a depth-$(L{+}1)$ width-$3$ network and a depth-$L$ width-$5$ network, so no exponential-in-$L$ lower bound can hold for depth-$L$ approximation of this witness family.

*Proof.* Use one collapsed layer (Theorem 8.1, width $5$) to compute $\tau^{\circ2}$, then $L-1$ ordinary sawtooth layers of width $3\le5$ on top. $\square$

**Theorem 8.5 (General collapse).** For $c\ge1$ and $L\ge2$: $\ \tau^{\circ(L+c-1)}\in\mathcal{N}(2^c+1,L)$. More generally, stacking $L$ copies of the width-$(2^c+1)$ layer of Theorem 8.3 gives $\tau^{\circ cL}\in\mathcal{N}(2^c+1,L)$.

**Theorem 8.6 (Logarithmic depth gaps are free).** If $2^c\le L$ and $L \ge 2$, then $\tau^{\circ(L+c-1)}\in\mathcal{N}(L+1,L)$: a depth-$L$ network with $O(L^2)$ units computes exactly a tower of height $L+\lfloor\log_2 L\rfloor - 1$.

**Theorem 8.7 (Tower-height bracket).** Fix $c\ge1$ and $L\ge1$, and consider depth-$L$ networks of width $2^c+1$. Then
$$\tau^{\circ cL}\in\mathcal{N}(2^c+1,L),\qquad\text{and}\qquad \tau^{\circ k}\in\mathcal{N}(2^c+1,L)\ \Longrightarrow\ k \le (c+3)L+2 .$$
Hence the maximal exactly computable tower height $k^\star(L,w)$ at width $w=2^c+1$ satisfies $cL\le k^\star\le (c+3)L+2$: it is $\Theta(L\log w)$ — *linear* in depth, *logarithmic* in width.

*Proof.* The lower bound is Theorem 8.5. For the upper bound apply Theorem 6.1 with $\varepsilon=0$: $2^k \le 4(2(2^c+1)+2)^L \le 4\bigl(2^{c+3}\bigr)^L = 2^{(c+3)L+2}$. $\square$

**Corollary 8.8 (Width 5).** At width $5$ the achievable height $k$ satisfies $2L \le k \le 4L+2$; in particular no depth-$L$ width-$5$ network computes $\tau^{\circ(L^2+4)}$ once $L\ge7$, in perfect consistency with Theorem 6.3.

**Corollary 8.9 (The counting bound is not slack by accident).** Since the depth-$L$, width-$5$ network of Theorem 8.4 computes $\tau^{\circ(L+1)}$ exactly, Theorem 5.4 forces its knot set to satisfy $2^{L+1}\le 2|S|+1$. Thus the exponential growth of the knot budget $\kappa(w,L)$ in $L$ is genuinely attained and is not an artefact of the estimate.

---

## 9. Discussion

### 9.1 What decides a separation: the ratio $k/L$

Theorems 6.1 and 8.7 together give an essentially complete picture for sawtooth witnesses. A depth-$L$, width-$w$ network can compute towers of height $\Theta(L\log w)$ and no more. Therefore:

| Tower height $k$ | Status at depth $L$ |
|---|---|
| $k \le L$ | trivially exact at width $3$ |
| $k = L + O(\log L)$ | exact at width $O(L)$ — polynomial size (Theorem 8.6) |
| $k = cL$, $c$ constant | exact at width $2^c+1$ — polynomial size (Theorem 8.5) |
| $k / L \to \infty$ | width must satisfy $2w+2 \ge 2^{k/L}/4^{1/L}$ — superpolynomial |
| $k = L^2+4$ | width $\ge 2^{L-1}-1$ — exponential (Theorem 6.3) |

The conjecture "depth $L{+}1$ beats depth $L$ exponentially" is therefore *false* for the canonical witness family, in the strongest possible sense: not only does a polynomial-size depth-$L$ approximator exist, an exact depth-$L$ representation of width $5$ exists. Any proof of a one-step exponential separation must use a genuinely different witness family — one whose complexity is not captured by counting oscillations, since oscillation count can only grow by a bounded factor per unit of depth at fixed width, and a *single* layer can already contribute a factor $2^c$ at width $2^c+1$.

### 9.2 Why knot counting is the right invariant here

Knot counting is complete for this problem in the following sense. On one side, the number of knots is subadditive under the operations a network performs, with the exact multiplicative constant per layer being $2w$ up to additive slack (Theorem 4.2), and the constant is attained: the width-$5$ collapse layer achieves a factor $4$ per layer against the budget factor $12$, and the width-$(2^c+1)$ layer achieves $2^c$ against the budget $2^{c+2}$. On the other side, oscillation is a *lower* bound on knots that is tight for the sawtooth: $\tau^{\circ k}$ has exactly $2^k$ affine pieces and exactly $2^k$ alternations. The two sides therefore differ only in the base of the exponential ($2^c$ achieved versus $2^{c+3}$ permitted), which is what the bracket in Theorem 8.7 records.

### 9.3 Robustness

The separation is not fragile in any of the three usual senses. It survives passing from $L^\infty$ to $L^1$ (Theorem 7.3); it holds at a positive density of sample points rather than at isolated inputs (Theorem 7.5); and it is dimension-free for ridge witnesses (Theorem 7.7). The tolerance $1/4$ is chosen for convenience: the argument works verbatim for any fixed tolerance $\varepsilon<1/2$, with the bands $[0,\varepsilon]$ and $[1-\varepsilon,1]$ replacing $[0,1/4]$ and $[3/4,1]$, and only the constants in the $L^1$ bound change.

### 9.4 Algorithmic reading

The proofs are constructive and immediately yield algorithms:

* **Knot budget.** Given $(w,L)$, evaluate the recursion $\kappa(w,0)=0$, $\kappa(w,L+1)=w(2\kappa(w,L)+4)$ in $O(L)$ arithmetic steps (on big integers, $O(L\cdot M(L\log w))$ bit operations) to obtain a certified upper bound on the number of pieces.
* **Certified infeasibility.** Given a target tower height $k$ and an architecture $(w,L)$, the single comparison $2^k > 4(2w+2)^L$ certifies that *no* assignment of weights to that architecture approximates $\tau^{\circ k}$ within $1/4$. This is a rigorous, constant-time nonexistence proof, in contrast with the empirical observation that training fails.
* **Exact synthesis.** Given $c$, output the $2^c+1$ breakpoints $i/2^c$ and coefficients $a^{(c)}_i$ of Theorem 8.3 to obtain a single layer computing $\tau^{\circ c}$ exactly, in $O(2^c)$ time. Composing $L$ such layers yields an exact depth-$L$ network for $\tau^{\circ cL}$.
* **Bracket calculator.** Given $(L,w)$ with $w\ge3$, output the interval $[\lfloor\log_2(w-1)\rfloor L,\ (\lfloor\log_2(w-1)\rfloor+3)L+2]$ containing the maximal exactly computable tower height.

### 9.5 Relation to practice

Two practical readings deserve emphasis, both stated carefully.

First, the theorem is an *existence* statement about architectures, not about optimisation. It says a shallow architecture has insufficient capacity, no matter how it is trained; it says nothing about whether gradient descent finds the good deep solution. The deep witness is, in fact, notoriously hard to learn by gradient methods, precisely because its outputs decorrelate rapidly under small input perturbations.

Second, the collapse theorems caution against over-reading depth-separation folklore. A model whose theoretical advantage comes from composing $L$ folds gains nothing from the last few layers if the width is even modestly larger: $\log_2 w$ folds per layer are available for free. Depth pays exponentially only when the required composition depth exceeds the available depth by a super-constant factor.

---

## 10. Future work

Several directions sharpen the threshold identified here, or attack the one-step conjecture with different witnesses.

1. **A witness for a one-step separation.** Find, or rule out, a family $g_L$ computed by depth-$(L{+}1)$ networks of size $\mathrm{poly}(L)$ such that every depth-$L$ approximator within $1/4$ has size $2^{\Omega(L)}$. By the collapse theorems the oscillation invariant cannot supply such a family; a genuinely new complexity measure — one that cannot increase by a bounded factor per layer at bounded width — is needed. Candidates include measures based on the *number of distinct linear regions in general position* in higher dimensions, or on algebraic invariants of the underlying tropical rational function.
2. **Closing the base gap in the bracket.** Theorem 8.7 gives $cL\le k^\star\le (c+3)L+2$ for width $2^c+1$. Determine $k^\star$ exactly. Sharpening the rectifier step from "one new knot per piece, plus normalisation slack" to a tight per-layer count should reduce $c+3$ toward $c+1$.
3. **Tolerance dependence.** Track the dependence of the master inequality on the tolerance $\varepsilon\in(0,1/2)$ and, separately, on the norm: is there an $L^2$ analogue of Theorem 7.3 with an absolute constant, and how does the constant degrade as $\varepsilon\uparrow1/2$?
4. **Higher-dimensional witnesses that are not ridges.** Theorem 7.7 transfers the separation to $\mathbb{R}^D$ only for functions of a single coordinate. For genuinely $D$-dimensional targets — e.g. compositions of folds along several directions — one expects lower bounds improving with $D$; the restriction technique cannot see them.
5. **Networks with skip connections and other activations.** The knot calculus applies verbatim to any piecewise-affine activation with a bounded number of pieces, with the per-layer factor changing from $2$ to the number of pieces. Quantifying the effect of residual connections (which do not increase the knot count) on the bracket of Theorem 8.7 is straightforward in principle and would give exact trade-offs for realistic architectures.
6. **Average-case and learning-theoretic consequences.** Theorem 7.5 gives failure at a constant fraction of dyadic points. Converting this into a distribution-free sample-complexity separation — a family on which any depth-$L$ learner of subexponential width incurs constant risk under the uniform measure — appears within reach, and would connect the expressivity story to statistical learning theory.
