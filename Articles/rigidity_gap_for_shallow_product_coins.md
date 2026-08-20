# The Coin That Cannot Know

## Why a machine built from independent parts can never perfectly hit a target that couples them

Imagine you are tuning a radio, except that this radio has two dials instead of one. Dial $A$ picks a frequency; dial $B$ picks a phase. Somewhere out in the space of all $(\text{frequency}, \text{phase})$ pairs there is a set $R$ of *resonant* combinations — the settings at which the machine actually rings. Your job is to build a signal that rings as loudly as possible on $R$ and nowhere else.

There is a catch, and it is the whole story. Your signal must be built as a **product**: you choose an amplitude $f(a)$ for each setting of the first dial, independently choose an amplitude $g(b)$ for each setting of the second, and the signal you emit at the pair $(a,b)$ is forced to be $f(a)\,g(b)$. The two dials are driven by separate hardware. Neither knows what the other is doing.

How loud can you make the machine ring? And when — if ever — can you ring *perfectly*?

The answer is a small, sharp theorem with an appealingly rigid shape: **you can ring perfectly if and only if the resonant set is a rectangle.** And if it is not a rectangle, you don't just fall short — you fall short by a definite, computable amount that no amount of clever tuning can recover. That's the *rigidity gap*.

---

## Setting the stage precisely

Let me make the picture exact, because the precision is where the pleasure is.

Fix two finite sets $A$ and $B$ — think of them as the possible letters that two **registers** can hold. A **coin** on the register $A$ is a complex amplitude vector $f : A \to \mathbb{C}$ normalised so that its total energy is one:
$$\sum_{a \in A} |f(a)|^2 = 1 .$$
Coins on $B$ are defined the same way. The name comes from quantum walks and randomised algorithms, where such a normalised vector is exactly the "coin" that decides which way a walker steps.

A **resonance set** is a subset $R \subseteq A \times B$: the pairs of letters at which the machine responds. Given a coin $f$ on $A$ and a coin $g$ on $B$, the **product coin** is the state $f \otimes g$ whose amplitude at $(a,b)$ is $f(a)g(b)$, and its **resonance amplitude** is the total amplitude it deposits on $R$:
$$\mathcal{A}(f,g) \;=\; \sum_{(a,b)\in R} f(a)\,g(b).$$

The quantity everyone cares about is $|\mathcal{A}(f,g)|^2$ — the *resonance intensity*, the loudness of the ring.

**How loud can it get?** Cauchy–Schwarz answers this immediately. The vector $f \otimes g$ has total energy $1$ spread over all of $A \times B$; the indicator of $R$ has energy $|R|$; their inner product is at most the product of the norms. So
$$|\mathcal{A}(f,g)|^2 \;\le\; |R| \qquad\text{for every product coin.}$$
Equality in Cauchy–Schwarz demands that the two vectors be parallel: the product coin must be *exactly* the normalised indicator of $R$, i.e. $f(a)g(b)$ must equal a fixed constant $1/\sqrt{|R|}$ on $R$ and $0$ off it.

And there is the rub. Can a product $f(a)g(b)$ ever look like the indicator of a set?

---

## Rectangles, and only rectangles

Say that $R$ is a **box** (a combinatorial rectangle) if, whenever $(a,b)$ and $(a',b')$ both lie in $R$, the recombination $(a,b')$ lies in $R$ too. Equivalently — and this is easy to check — $R$ is a box exactly when it is a genuine product $R = A_0 \times B_0$ of a set of first letters with a set of second letters.

If $R = A_0 \times B_0$ is a box, ringing perfectly is trivial: spread $f$ uniformly over $A_0$, spread $g$ uniformly over $B_0$. Then $f(a)g(b) = 1/\sqrt{|A_0||B_0|}$ exactly on $R$ and zero elsewhere, and
$$|\mathcal{A}(f,g)|^2 = |A_0|\cdot|B_0| = |R|.$$
Perfect resonance, achieved by a coin that never needs the two registers to communicate.

If $R$ is *not* a box, perfection is impossible — and this is where the quantitative story begins. Non-boxness means there are two resonant pairs $(a,b)$ and $(a',b')$ in $R$ whose crossover $(a,b')$ is *missing*. Look at the four corners
$$(a,b),\quad (a,b'),\quad (a',b),\quad (a',b')$$
of the little rectangle they span. On three of them the indicator of $R$ takes the values $1, 0, ?, 1$ (the value at $(a',b)$ is unknown but at most $1$). Its $2\times 2$ minor across these corners is $1\cdot 1 - 0\cdot ? = 1$: nonzero.

But a product $f(a)g(b)$ has *every* $2 \times 2$ minor equal to zero:
$$f(a)g(b)\cdot f(a')g(b') - f(a)g(b')\cdot f(a')g(b) = 0.$$
This is nothing but the statement that a product is a rank-one matrix. So a non-box indicator has a nonzero minor where every product coin has a zero minor. They cannot be equal. Perfection is out.

That's the qualitative dichotomy — clean, but soft. It says the maximum is not *attained*. It does not, by itself, prevent the maximum from being *approached* arbitrarily closely by better and better product coins. Ruling that out is the real theorem.

---

## The rigidity gap

**Theorem (Rigidity gap).** *Let $R \subseteq A\times B$ be a resonance set that is not a box. Then every product coin satisfies*
$$|\mathcal{A}(f,g)|^2 \cdot \bigl(3|R| + 1\bigr) \;\le\; 3|R|^2,$$
*equivalently*
$$|\mathcal{A}(f,g)|^2 \;\le\; \Bigl(1 - \frac{1}{3|R|+1}\Bigr)\,|R| \;=\; |R| - \frac{|R|}{3|R|+1}.$$
*Since a non-box set has at least two elements, this always implies the clean uniform bound*
$$|\mathcal{A}(f,g)|^2 \;\le\; |R| - \tfrac{2}{7}.$$

The deficiency $2/7 = 0.2857\ldots$ does not shrink as the alphabets grow, as $R$ grows, or — as we'll see — as the number of registers grows. It is a hard floor. A machine assembled from independent parts always leaves at least $2/7$ of a unit of resonance on the table when its target couples the parts.

### How the proof works

The argument is a beautiful little piece of elementary geometry, and it needs no spectral theory at all.

First, pass from complex amplitudes to moduli: set $u(a,b) = |f(a)|\,|g(b)|$. Then $u \ge 0$, the total energy $\sum_{a,b} u(a,b)^2$ is still $1$ (it factors as the product of the two energies), and by the triangle inequality $|\mathcal{A}(f,g)| \le T$ where $T = \sum_{x \in R} u(x)$. So it suffices to bound $T^2$.

Now write $m = |R|$ and $\mu = T/m$ — the average value of $u$ on $R$. The single most useful computation in the whole subject is that the squared distance from $u$ to the *best* multiple of the indicator $\mathbf{1}_R$ is
$$\sum_{x \in A\times B}\bigl(u(x) - \mu \mathbf{1}_R(x)\bigr)^2 \;=\; 1 - \frac{T^2}{m}.$$
(Expand: $\sum u^2 - 2\mu T + \mu^2 m = 1 - 2T^2/m + T^2/m$.) This says something intuitive: *the closer $u$ is to a multiple of the indicator, the closer $T^2$ is to $m$.* Ringing loudly and looking like the indicator are the same thing.

So to prove a gap it is enough to prove that $u$ is *quantitatively far* from every multiple of $\mathbf{1}_R$ — and that is exactly what the vanishing minor delivers. Let
$$e_{11} = u(a,b)-\mu,\quad e_{12} = u(a,b'),\quad e_{21} = u(a',b) - \mu c,\quad e_{22}=u(a',b')-\mu$$
be the four deviations at the corners, where $c = \mathbf{1}_R(a',b) \le 1$. Substituting into the rank-one identity $u(a,b)u(a',b') = u(a,b')u(a',b)$ gives a single polynomial constraint
$$\mu^2 + \mu(e_{11}+e_{22}) + e_{11}e_{22} - \mu\, c\, e_{12} - e_{12}e_{21} \;=\; 0 .$$
Read it as follows: the two "big" terms $\mu^2$ have to be cancelled by the deviations, so the deviations cannot all be small. Making that precise is a short optimisation — an arrangement of squares and an AM–GM step — which yields

**Lemma (Rank-one minor inequality).** *If $\mu \ge 0$, $e_{12}\ge 0$, $c \le 1$ and the identity above holds, then*
$$\mu^2 \;\le\; 3\bigl(e_{11}^2 + e_{12}^2 + e_{21}^2 + e_{22}^2\bigr).$$

The four corners are distinct points, so their four squared deviations are at most the total squared deviation $1 - T^2/m$. Chaining:
$$\frac{T^2}{m^2} \;=\; \mu^2 \;\le\; 3\Bigl(1 - \frac{T^2}{m}\Bigr),$$
which rearranges to precisely $T^2(3m+1) \le 3m^2$. Done. One vanishing minor, one distance identity, one inequality among four real numbers — and a universal gap falls out.

---

## Many registers, same gap

Real machines have more than two dials. Suppose there are $n$ registers, the $i$-th holding a letter from an alphabet $\alpha_i$, so that a *word* is a tuple $x = (x_1,\dots,x_n)$. A **product coin of depth $n$** is the fully unentangled state
$$\psi_f(x) \;=\; \prod_{i=1}^n f_i(x_i),$$
each $f_i$ a coin on its own register, and the resonance amplitude against a set $R$ of words is $\mathcal{A}(\psi_f) = \sum_{x\in R}\psi_f(x)$.

Call $R$ **non-box along register $i_0$** if there are words $x, y \in R$ such that the hybrid word obtained from $y$ by overwriting its $i_0$-th letter with $x$'s $i_0$-th letter escapes $R$. This is the depth-$n$ analogue of a missing crossover.

**Theorem (Depth-$n$ rigidity gap).** *If $R$ is non-box along some register $i_0$, then for every product coin of depth $n$,*
$$|\mathcal{A}(\psi_f)|^2 \le \Bigl(1 - \frac{1}{3|R|+1}\Bigr)|R|, \qquad\text{hence}\qquad |\mathcal{A}(\psi_f)|^2 \le |R| - \tfrac{2}{7}.$$
*The constant depends on nothing but $|R|$ — not on the depth $n$, not on the alphabet sizes.*

The proof is a two-line reduction once the bipartite case is in hand: split the word space at the single register $i_0$, writing a word as a pair (its $i_0$-th letter, the rest). A depth-$n$ product coin becomes a product of two coins under this splitting, because the product over the remaining $n-1$ registers is itself a normalised coin on the "tail" alphabet. Non-boxness along $i_0$ is exactly non-boxness of the image set. The bipartite theorem applies verbatim.

And the converse holds too: if $R$ is a genuine product $S_1\times\cdots\times S_n$ of letter sets, the uniform product coin achieves $|\mathcal{A}(\psi_f)|^2 = |R|$ exactly. So at every depth we get the same dichotomy — **perfect resonance is available to shallow, unentangled coins precisely for resonance sets that do not couple registers.**

### A concrete family: the agreement set

Take $n$ binary registers and let $R$ be the **agreement set**: all words $x \in \{0,1\}^n$ whose registers $i$ and $j$ carry the same bit, for a fixed pair $i \ne j$. This set has $2^{n-1}$ elements, and it is non-box along $i$ (take $x$ all-zeros, $y$ all-ones; overwriting the $i$-th bit of $y$ with $0$ breaks the agreement). So no product coin, at any depth, gets within $2/7$ of the optimum $2^{n-1}$.

For this family one can do much better than $2/7$ by hand, and the improvement is dramatic. A product coin factorises the amplitude as
$$\mathcal{A}(\psi_f) = \bigl(f_i(0)f_j(0)+f_i(1)f_j(1)\bigr)\prod_{k \ne i,j}\bigl(f_k(0)+f_k(1)\bigr).$$
The bracketed diagonal term has modulus at most $1$ (it is a two-point Cauchy–Schwarz), and each remaining factor has modulus at most $\sqrt2$. So
$$|\mathcal{A}(\psi_f)|^2 \le 2^{\,n-2} = \tfrac12\,|R|.$$
Half the optimum is lost. The unentangled machine can only ever manage a fifty-percent resonance against a set that couples two of its registers, no matter how many registers it has.

---

## How big is the gap, really?

The universal constant $2/7$ is not the truth; it is a provable, uniform *floor* under the truth. How far is it from optimal?

The smallest non-box resonance set is the **L-shape** $R=\{(0,0),(0,1),(1,0)\}$ inside a $2\times 2$ grid, with $|R|=3$. Its optimal product coin is, delightfully, governed by the golden ratio. If you set both coins to $(\cos\theta,\sin\theta)$ the amplitude is $\cos^2\theta + 2\sin\theta\cos\theta$, maximised at the golden angle, and the true optimum is
$$\sup_{f,g}\,|\mathcal{A}(f,g)|^2 \;=\; \varphi^2 \;=\; \frac{3+\sqrt5}{2} \;=\; 2.61803\ldots,\qquad \varphi=\frac{1+\sqrt5}{2}.$$
The true deficiency is therefore $3 - \varphi^2 = \frac{3-\sqrt5}{2} = 0.38196\ldots$.

One can certify this with clean rational arithmetic: the Pythagorean pair $(45/53, 28/53)$ (note $45^2+28^2=53^2$, and $28/45 = 0.6222$ is a good rational stand-in for $1/\varphi = 0.6180$) is an exact coin, and it achieves
$$|\mathcal{A}|^2 = \left(\frac{4545}{2809}\right)^2 = \frac{20657025}{7890481} = 2.6179678\ldots$$
So any constant $c$ for which "$|\mathcal{A}|^2 \le |R|-c$ holds for all non-box sets and all product coins" must satisfy $c \le 3014418/7890481 = 0.3820322\ldots$. Combining with the theorem:
$$0.2857\ldots \;=\; \frac27 \;\le\; c^\ast \;\le\; 0.3820322\ldots$$
The universal constant proved here is within a factor of $1.34$ of the best possible. This is a theorem with a number in it, and the number is nearly right.

There is a matching lower bound on the achievable loudness that costs nothing: concentrate the first coin entirely on a single letter $a$ and spread the second uniformly over the row $R_a = \{b : (a,b)\in R\}$. That product coin achieves exactly $|R_a|$. So for every resonance set,
$$\max_{a}|R_a| \;\le\; \sup_{f,g}|\mathcal{A}(f,g)|^2 \;\le\; \frac{3|R|^2}{3|R|+1},$$
squeezing the truth between a purely combinatorial quantity and the rigidity bound.

Finally, a benchmark showing that the universal $2/7$ is very conservative for particular sets: on the two-point diagonal $R=\{(0,0),(1,1)\}$ in a $2\times 2$ grid, every product coin satisfies $|\mathcal{A}(f,g)|^2 \le 1$ — a full unit below the Cauchy–Schwarz value $|R|=2$ — and the value $1$ *is* attained (put both coins entirely on the letter $0$). The diagonal is the canonical "entangled target": a product machine can hit exactly one of its two resonances.

---

## A dictionary, and why any of this matters

Everything above has a one-line spectral translation. Regard the resonance set $R$ as a $0/1$ matrix $M$ with $M_{ab}=1$ iff $(a,b)\in R$. Then $\sup_{f,g}|\mathcal{A}(f,g)|$ over unit vectors is exactly the largest singular value $\sigma_1(M)$, and $|R|$ is the squared Frobenius norm $\|M\|_F^2 = \sum_i \sigma_i^2$. The Cauchy–Schwarz bound is the trivial $\sigma_1^2 \le \sum_i \sigma_i^2$; equality means $M$ has rank one, which for a $0/1$ matrix means precisely that it is a combinatorial rectangle. The rigidity gap is then the statement that a $0/1$ matrix which is *not* a rectangle carries at least $2/7$ of its Frobenius energy outside its top singular direction. The L-shape is $\begin{pmatrix}1&1\\1&0\end{pmatrix}$, whose eigenvalues are $\varphi$ and $-1/\varphi$ — there is the golden ratio, exactly where the sharp constant said it would be.

Why should anyone care about a bound with the number $2/7$ in it?

Because "a system built from independent components cannot exactly realise a target that entangles those components" is one of the load-bearing intuitions of modern computation, and intuitions of that shape are usually stated qualitatively and then quietly assumed to be robust. They are not automatically robust. Non-attainment of a supremum is compatible with the supremum being approached to within $10^{-100}$. What a rigidity gap does is upgrade an impossibility into a *budget*: whatever your alphabet sizes, whatever the depth of your device, whatever the size of your target, a fixed amount of resonance is unrecoverable, and you can put it on an invoice.

The same skeleton recurs across fields under different names. In quantum information the product coin is an unentangled pure state and the gap says the fidelity with an entangled target is bounded away from one — with an explicit bound. In communication complexity the boxes are exactly the combinatorial rectangles that one round of communication can carve out, and non-rectangularity is the source of every lower bound in the subject; the gap gives a metric version of "this set is not a rectangle". In machine learning the product coin is a rank-one factorisation, and the theorem says that a target which is not a rectangle has a quantifiable, non-vanishing approximation error for any rank-one model. In signal processing, it is the statement that separable filters cannot match non-separable templates, with the mismatch bounded below.

What makes the present argument satisfying is how little machinery it needs. No singular value decomposition, no variational principle, no compactness. Just this: *a product has no $2\times2$ minor, an indicator of a non-rectangle does, and a single missing corner of a rectangle costs you at least two sevenths.*

The gap between $2/7$ and the golden $\frac{3-\sqrt5}{2}$ is where the remaining work lives — and $\varphi$ appearing as the extremal constant of a problem about independent machines and coupled targets is the kind of coincidence that usually turns out not to be one.
