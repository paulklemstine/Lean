# Seed-Compressible Data: Fingerprinting, Routing and Seed Recovery for Generator-Produced Pythagorean Streams

**Author:** Aristotle
**Date:** 2026-08-18

---

## Abstract

A pseudorandom or procedural generator turns a short seed into an arbitrarily long file. When such a file appears in a corpus, the optimal encoding of it is its seed, and the compression ratio is unbounded. This paper carries the detection-and-recovery programme through to a complete answer in a setting where every question can be settled exactly: streams of Pythagorean triples produced by the Barning–Berggren generators, three unimodular $3\times3$ integer matrices whose orbits from the root $(3,4,5)$ enumerate every primitive Pythagorean triple exactly once.

We establish four results. **(i) Fingerprinting.** By Cayley–Hamilton, every linear readout of every orbit of an integer $3\times3$ matrix $M$ satisfies the order-3 linear recurrence with taps $(\det M, -c_2(M), \operatorname{tr} M)$; for the Berggren moves the taps are $(1,-3,3)$ on the two unipotent branches and $(-1,5,5)$ on the Pell branch. The bound is sharp: the true linear complexity of the hypotenuse stream is $3$ on the unipotent branches and $2$ on the Pell branch, so linear complexity alone is a branch classifier. Composite generators driven by a repeated control word remain order-3 detectable. **(ii) Recovery.** Three observed symbols regenerate a single-move stream exactly at every index; for the full ternary generator, three sign tests per level recover the control word letter for letter, and the code is uniquely decodable. **(iii) Coverage versus rarity.** Every normalised primitive Pythagorean triple is generator output for exactly one control word — the corpus is $100\%$ seed-compressible — while the number of length-$n$ files reachable from a seed box $[-N,N]^3$ is at most $3(2N+1)^3$, *independently of $n$*: over arbitrary files the reach is vanishingly small. **(iv) Rate dichotomy.** Detectability and profitability are distinct invariants of the same matrix. The all-$B$ word of length $k$ emits a hypotenuse $\ge 5\cdot3^k$ (logarithmic seed: genuine compression), while the all-$A$ word emits a hypotenuse $\le 2(k+2)^2$ (square-root seed: catastrophic expansion). No branch ever beats logarithmic, since one step multiplies the hypotenuse by at most $7$.

**Keywords:** seed recovery, linear complexity, Berlekamp–Massey, Barning–Berggren tree, Pythagorean triples, Cayley–Hamilton, unipotent matrices, Pell recurrence.

---

## 1. Introduction

### 1.1 Compression beyond the pigeonhole bound

The counting argument that limits lossless compression is airtight: an injective map from $\{0,1\}^n$ into $\bigcup_{m<n}\{0,1\}^m$ cannot exist, so no compressor shortens every input. Practical compression escapes this only by exploiting that real corpora concentrate on a thin, structured subset of all strings.

Almost all deployed compression exploits *statistical* structure: local correlations captured by a model, coded near the model's entropy. There is a second, qualitatively different, kind of structure: some files are *literally generator output*. Procedural game worlds, deterministic simulations, test vectors, tabulated mathematical sequences, and certain file-format paddings are the exact orbit of a short deterministic program run from a short seed. For such a file the ideal code length is the seed length, which may be dozens of bits against gigabytes of data.

Exploiting this requires three separable capabilities:

1. a **fingerprint** — a cheap statistic on raw observations that indicates generator output without knowing the seed;
2. **seed recovery** — an algorithm that inverts the generator, with the falsifiability gate that replaying the recovered seed reproduces the file *exactly*;
3. a **router** — a classifier deciding, per file, between *seed-compressible* and *model-compressible*, since the seed compressor is useless on almost all inputs.

### 1.2 A setting where everything is provable

We instantiate the programme on the Barning–Berggren generators of Pythagorean triples. The choice is deliberate: it is simultaneously (a) real data, since tabulated Pythagorean triples occur in geometry software, test corpora and number-theoretic datasets; (b) genuinely generator-produced, with a known, finitely presented generator; and (c) small enough that coverage, rarity, and compression rate can all be determined exactly rather than estimated.

Write a triple as a column vector $(a,b,c)^{\mathsf T}$. The three Barning matrices are

$$
B_A=\begin{pmatrix}1&-2&2\\2&-1&2\\2&-2&3\end{pmatrix},\qquad
B_B=\begin{pmatrix}1&2&2\\2&1&2\\2&2&3\end{pmatrix},\qquad
B_C=\begin{pmatrix}-1&2&2\\-2&1&2\\-2&2&3\end{pmatrix}.
$$

We write $A,B,C$ for the corresponding maps on $\mathbb{Z}^3$; explicitly

$$
\begin{aligned}
A(a,b,c) &= (a-2b+2c,\; 2a-b+2c,\; 2a-2b+3c),\\
B(a,b,c) &= (a+2b+2c,\; 2a+b+2c,\; 2a+2b+3c),\\
C(a,b,c) &= (-a+2b+2c,\; -2a+b+2c,\; -2a+2b+3c).
\end{aligned}
$$

Each preserves the Lorentz form $a^2+b^2-c^2$, hence maps Pythagorean triples to Pythagorean triples. From the root $(3,4,5)$ they generate $(5,12,13)$, $(21,20,29)$, $(15,8,17)$ respectively.

### 1.3 Contributions

- **Universal order-$3$ fingerprint** (§3) valid for any integer $3\times3$ generator matrix, with taps given by the characteristic polynomial, and stable under composition with periodic control words.
- **Sharpness of the fingerprint** (§3.4), separating unipotent from Pell branches by linear complexity alone.
- **Exact seed recovery** (§4): three-symbol recovery for fixed-move streams, and a linear-time sign-test decoder for the full ternary code, with unique decodability.
- **A sound, complete, exact router** (§5), together with conserved branch signatures computable from two consecutive observations.
- **Coverage** (§6): every normalised primitive triple is generator output, for exactly one control word — an explicit bijection $\{A,B,C\}^*\simeq$ normalised primitive triples.
- **Rarity** (§6.3): a length-independent cardinality bound on the reach of the seed compressor, and hence explicit incompressible files.
- **Rate dichotomy** (§7): logarithmic seeds on the Pell branch, square-root seeds on the unipotent branches, and a universal logarithmic floor.

---

## 2. Preliminaries

### 2.1 Generators, streams and seed compressibility

**Definition 2.1 (Generator).** A *generator* on a state space $S$ with output alphabet $O$ is a pair $(\text{next}, \text{out})$ with $\text{next}:S\to S$ and $\text{out}:S\to O$. Its *stream* from seed $s\in S$ is $\sigma_s(t) = \text{out}(\text{next}^{t}(s))$, and its length-$n$ *prefix* is $\sigma_s|_{\{0,\dots,n-1\}}$.

For the Berggren generators we take $S=O=\mathbb{Z}^3$, $\text{next}$ one of $A,B,C$, and $\text{out}=\mathrm{id}$: the emitted symbol is the entire current triple.

**Definition 2.2 (Seed compressibility).** A length-$n$ file $x$ is *seed-compressible* for a generator $G$ if $x$ is a length-$n$ prefix of some stream of $G$. If the prefix map is injective, the seed is uniquely determined and the *decoder* returns it.

**Definition 2.3 (Orbit predicate).** An observed stream $x:\mathbb{N}\to\mathbb{Z}^3$ *is an orbit* of the self-map $m$ if $x(t+1) = m(x(t))$ for all $t$.

**Proposition 2.4 (Orbit = stream from the first symbol).** $x$ is an orbit of $m$ if and only if $x(t) = m^{t}(x(0))$ for all $t$. Hence seed recovery for a triple stream is simply reading off $x(0)$.

*Proof sketch.* Forward: induct on $t$, using $x(t+1)=m(x(t))$ and $m^{t+1} = m\circ m^{t}$. Backward: substitute the closed form at $t$ and $t+1$ and use the same iterate identity. $\square$

### 2.2 Linear recurrences and linear complexity

**Definition 2.5 (LFSR stream).** A sequence $y:\mathbb{N}\to\mathbb{Z}$ *satisfies the taps* $(\tau_0,\dots,\tau_{d-1})$ if
$$y(t+d) \;=\; \sum_{i=0}^{d-1}\tau_i\, y(t+i)\qquad\text{for all }t\ge0 .$$
The *linear complexity* of $y$ is the least such $d$.

**Definition 2.6 (LFSR generator).** Given taps $\tau$, the associated generator has state $(y(t),\dots,y(t+d-1))\in\mathbb{Z}^d$, shifting in the value $\sum_i \tau_i y(t+i)$ and emitting the first coordinate. Its seed is the initial window of $d$ symbols.

**Lemma 2.7 (Exact reproduction).** If $y$ satisfies taps $\tau$ of order $d$, then the stream of the LFSR generator with taps $\tau$ seeded by $(y(0),\dots,y(d-1))$ equals $y$ at every index.

*Proof sketch.* Induction on $t$: the state after $t$ shifts is the window $(y(t),\dots,y(t+d-1))$, because each shift-in value is forced to be $y(t+d)$ by the recurrence. $\square$

Lemma 2.7 is the falsifiability gate in its purest form: the decompressed output is not approximately, but *identically*, the observed data. Berlekamp–Massey supplies the practical converse — from $2d$ symbols of a sequence of complexity $\le d$ it returns the taps.

### 2.3 Normalisation

**Definition 2.8 (Good triple).** $(a,b,c)$ is *good* if $a^2+b^2=c^2$ and $a,b,c>0$.

**Definition 2.9 (Tree triple).** A good triple is a *tree triple* (normalised primitive) if additionally $\gcd(a,b)=1$ and $a$ is odd.

**Lemma 2.10.** For a good triple, $a<c$ and $b<c$.

*Proof sketch.* From $a^2 + b^2 = c^2$ with all entries positive, $a^2<c^2$, and positivity gives $a<c$; symmetrically for $b$. $\square$

**Lemma 2.11 (Invariance of normalisation).** Each of $A,B,C$ maps good triples to good triples and tree triples to tree triples.

*Proof sketch.* Preservation of $a^2+b^2-c^2$ is a direct computation. Positivity of the images follows from Lemma 2.10 by linear arithmetic ($a-2b+2c > 0$ because $c>b$, etc.). Primitivity is preserved because any common divisor of the image legs divides the preimage legs (the matrices are unimodular), and the parity of the first coordinate is preserved because each image first coordinate differs from $\pm a$ by an even number. $\square$

---

## 3. Fingerprinting: generator output leaves an order-3 signature

### 3.1 The general theorem

For $M\in \mathbb{Z}^{3\times3}$ write $\operatorname{tr} M$ for its trace, $\det M$ for its determinant, and
$$c_2(M) \;=\; (M_{00}M_{11}-M_{01}M_{10}) + (M_{00}M_{22}-M_{02}M_{20}) + (M_{11}M_{22}-M_{12}M_{21})$$
for the sum of principal $2\times2$ minors, so that the characteristic polynomial is $\lambda^3 - (\operatorname{tr} M)\lambda^2 + c_2(M)\lambda - \det M$.

**Theorem 3.1 (Cayley–Hamilton in readout form).** For every $M \in \mathbb{Z}^{3\times3}$ and all vectors $u,w\in\mathbb{Z}^3$,
$$u\cdot M^3 w \;=\; \operatorname{tr}(M)\,\bigl(u\cdot M^2 w\bigr) \;-\; c_2(M)\,\bigl(u\cdot M w\bigr) \;+\; \det(M)\,(u\cdot w).$$

*Proof sketch.* Expand both sides as polynomials in the nine entries of $M$ and the six entries of $u,w$; the identity is the Cayley–Hamilton relation $M^3 = (\operatorname{tr} M)M^2 - c_2(M)M + (\det M)I$ paired against $u$ and $w$, and is verified by direct algebraic expansion. $\square$

**Theorem 3.2 (Universal fingerprint).** For every $M\in\mathbb{Z}^{3\times3}$, every observation functional $u$, and every seed $v$, the readout stream $y(t) = u\cdot M^{t}v$ satisfies the order-3 taps
$$\bigl(\det M,\; -c_2(M),\; \operatorname{tr} M\bigr),$$
i.e. $y(t+3) = \operatorname{tr}(M) y(t+2) - c_2(M) y(t+1) + \det(M) y(t)$.

*Proof sketch.* Apply Theorem 3.1 with $w = M^{t}v$, then rewrite $M^{t+j}v = M^{j}(M^{t}v)$. $\square$

Two features are worth emphasising. First, the taps are independent of both the seed and the observation functional: a detector need not know what it is measuring. Second, the linear complexity of *any* observable is at most $3$, so Berlekamp–Massey applied to six samples of any coordinate returns the generator's characteristic data.

### 3.2 The Berggren taps

**Corollary 3.3 (Branch fingerprints).** For all $u,v,w\in\mathbb{Z}$ and every seed $p$:

- the readout $t\mapsto u\,a_t + v\,b_t + w\,c_t$ of the $A$-orbit satisfies the taps $(1,-3,3)$;
- the same readout of the $C$-orbit satisfies the taps $(1,-3,3)$;
- the same readout of the $B$-orbit satisfies the taps $(-1,5,5)$.

*Proof sketch.* $\operatorname{tr} B_A = 3$, $c_2(B_A) = 3$, $\det B_A = 1$, giving the characteristic polynomial $(\lambda-1)^3$; identically for $B_C$. For $B_B$, $\operatorname{tr}=5$, $c_2 = -5$, $\det = -1$, giving $\lambda^3 - 5\lambda^2 - 5\lambda + 1 = (\lambda+1)(\lambda^2-6\lambda+1)$. Apply Theorem 3.2. $\square$

The taps $(1,-3,3)$ say precisely that the third difference of the stream vanishes, i.e. the stream is a quadratic polynomial in $t$. This is confirmed by explicit closed forms.

**Theorem 3.4 (Closed forms on the unipotent branches).** For every $(a,b,c)$ and $t\ge0$,
$$A^{t}(a,b,c) = \bigl(a + 2t(c-b),\; b + 2t(a-b+c) + 2t(t-1)(c-b),\; c + 2t(a-b+c)+2t(t-1)(c-b)\bigr),$$
$$C^{t}(a,b,c) = \bigl(a + 2t(-a+b+c) + 2t(t-1)(c-a),\; b + 2t(c-a),\; c + 2t(-a+b+c)+2t(t-1)(c-a)\bigr).$$

*Proof sketch.* Induction on $t$; the successor step is a polynomial identity in $a,b,c,t$. $\square$

**Corollary 3.5 (Benchmark families).** From the root,
$$A^{t}(3,4,5) = (2t+3,\; 2t^2+6t+4,\; 2t^2+6t+5),\qquad C^{t}(3,4,5) = (4t^2+8t+3,\; 4t+4,\; 4t^2+8t+5).$$
In particular the $A$-branch first leg and the $C$-branch second leg are arithmetic progressions, with common differences $2(c-b)$ and $2(c-a)$ respectively.

### 3.3 The Pell factor

**Theorem 3.6 (Order-2 recurrence on the $B$-branch).** For every seed $p$ and $t\ge0$,
$$c_{t+2} = 6\,c_{t+1} - c_t, \qquad (a+b)_{t+2} = 6\,(a+b)_{t+1} - (a+b)_t,$$
where the subscripts index the $B$-orbit. Moreover the leg difference alternates: $b_t - a_t = (-1)^t (b_0-a_0)$.

*Proof sketch.* On the $B$-branch, the pair $(a+b,\,c)$ evolves by $\begin{pmatrix}3&4\\2&3\end{pmatrix}$, whose characteristic polynomial is $\lambda^2-6\lambda+1$; the third eigendirection, spanned by $b-a$, has eigenvalue $-1$. Substituting the definitions of two and three successive $B$-steps and simplifying gives each identity directly. $\square$

From the root the $B$-hypotenuses are $5,29,169,985,5741,\dots$, with ratio tending to $3+2\sqrt2 \approx 5.828$, the larger root of $\lambda^2 - 6\lambda+1$.

### 3.4 Sharpness, and complexity as a classifier

**Theorem 3.7 (Sharpness).**
(i) The $A$-branch hypotenuse stream from the root, $c_t = 2t^2+6t+5$, satisfies no order-2 recurrence: there are no $\gamma_0,\gamma_1\in\mathbb{Z}$ with $c_{t+2} = \gamma_0 c_t + \gamma_1 c_{t+1}$ for all $t$. The same holds on the $C$-branch for $c_t = 4t^2+8t+5$.
(ii) The $B$-branch hypotenuse stream satisfies no order-1 recurrence.

*Proof sketch.* (i) The three instances $t=0,1,2$ give the linear system $25 = 5\gamma_0 + 13\gamma_1$, $41 = 13\gamma_0+25\gamma_1$, $61 = 25\gamma_0+41\gamma_1$, which is inconsistent over $\mathbb{Z}$ (indeed over $\mathbb{Q}$). (ii) $c_0=5$, $c_1=29$, and $29 = 5\gamma_0$ has no integer solution. $\square$

**Corollary 3.8 (Linear complexity separates the branches).** The hypotenuse stream from the root has linear complexity exactly $3$ on the $A$- and $C$-branches and exactly $2$ on the $B$-branch. Hence measuring the linear complexity of a *single* observed coordinate distinguishes the exponential branch from the unipotent ones, without any seed search.

### 3.5 Composite generators remain detectable

A realistic generator need not iterate a single move; it may be driven by a control word. Let $w\in\{A,B,C\}^*$ and let $M_w$ be the product of the corresponding Barning matrices (in application order).

**Theorem 3.9 (Periodic control words).** For any control word $w$, any observation functional $u$, and any seed $p$, the stream $t\mapsto u\cdot(\text{apply } w)^{t}(p)$ satisfies the order-3 taps $(\det M_w,\,-c_2(M_w),\,\operatorname{tr} M_w)$.

*Proof sketch.* Applying $w$ once is multiplication by $M_w$ (induction on $w$, using that each step is a matrix–vector product). So the orbit of the composite map is the orbit of a single $3\times3$ integer matrix, and Theorem 3.2 applies. $\square$

Thus periodic seeding does not defeat the fingerprint. Only the taps change.

---

## 4. Seed recovery

### 4.1 Fixed-move streams: three symbols suffice

**Theorem 4.1 (Three-symbol recovery).** Let $y(t) = u\,a_t+v\,b_t+w\,c_t$ be any linear readout of an $A$-orbit. Then the LFSR generator with taps $(1,-3,3)$, seeded with $(y(0),y(1),y(2))$, reproduces $y(t)$ for every $t$. The analogous statements hold for the $C$-branch (taps $(1,-3,3)$) and the $B$-branch (taps $(-1,5,5)$).

*Proof sketch.* Combine Corollary 3.3 with Lemma 2.7. $\square$

So an observed file of $n$ triples on a fixed branch encodes into: a two-bit branch label plus three integers. The compression ratio is unbounded in $n$.

**Theorem 4.2 (Seed uniqueness for the triple stream).** Since the first emitted symbol *is* the seed, the length-$n$ prefix map of a Berggren generator is injective for every $n\ge1$; hence any decoder that returns *a* seed consistent with an observed file returns *the* seed.

**Theorem 4.3 (Backward recovery).** Each move is invertible over $\mathbb{Z}$ ($\det = \pm1$), and applying the inverse $t$ times to the $t$-th orbit point returns the seed exactly: $A'^{\,t}(A^{t}p) = p$, and similarly for $B$ and $C$.

*Proof sketch.* Induction on $t$ from $A'\circ A = \mathrm{id}$. $\square$

### 4.2 The path code and its decoder

For the full generator, the seed is the control word $w\in\{A,B,C\}^*$ and the output is $\mathrm{path}(w)$, the triple obtained by applying $w$ to the root $(3,4,5)$.

**Lemma 4.4 (Growth).** For every good triple $p$ and every step $s$, $\;c(s\,p) \ge c(p) + 4$. Consequently $c(\mathrm{path}(w)) \ge 5 + 4|w|$, i.e. $|w| \le (c-5)/4$.

*Proof sketch.* The three increments are $c(Ap)-c(p) = 2(a + c - b)$, $c(Bp)-c(p) = 2(a+b+c)$ and $c(Cp)-c(p) = 2(b + c - a)$. Each is a sum of two positive integers doubled, since $a,b>0$ and $a,b<c$ (Lemma 2.10), hence at least $4$. The bound on $|w|$ follows by induction on the word from $c(\mathrm{path}(\varepsilon))=5$. $\square$

**Lemma 4.5 (Parent uniqueness).** If $p,p'$ are triples with positive legs and $s\,p = s'\,p'$ for steps $s,s'$, then $s=s'$ and $p=p'$.

*Proof sketch.* Each pair of distinct moves is separated by a sign obstruction: e.g. $A p = B p'$ forces $2a-b+2c = 2a'+b'+2c'$ and $a-2b+2c = a'+2b'+2c'$ simultaneously, which contradicts positivity of $b,b'$ by linear arithmetic. Once $s=s'$, injectivity of the (unimodular) move gives $p=p'$. $\square$

**Theorem 4.6 (Unique decodability).** $\mathrm{path}$ is injective: distinct control words emit distinct triples.

*Proof sketch.* Strong induction on $|w|$. If one word is empty and the other is not, Lemma 4.4 forces different hypotenuses ($5$ versus $\ge9$). Otherwise write $w=u\cdot s$ and $w'=u'\cdot s'$; then $s\,\mathrm{path}(u) = s'\,\mathrm{path}(u')$, so Lemma 4.5 gives $s=s'$ and $\mathrm{path}(u)=\mathrm{path}(u')$, and the induction hypothesis gives $u=u'$. $\square$

**Definition 4.7 (Sign-test decoder).** For an observed triple $q$, define $\mathrm{parentStep}(q)$ by trying the inverse moves in order: return $A$ if $A^{-1}q$ has both legs positive, else $B$ if $B^{-1}q$ does, else $C$ if $C^{-1}q$ does, else nothing; and let $\mathrm{parentOf}(q)$ be the corresponding preimage. The decoder peels symbols:
$$\mathrm{decode}(0,q) = \varepsilon,\qquad \mathrm{decode}(n+1,q) = \begin{cases}\varepsilon & \text{if }\mathrm{parentStep}(q)\text{ is undefined},\\ \mathrm{decode}(n,\mathrm{parentOf}(q))\cdot s & \text{if }\mathrm{parentStep}(q)=s.\end{cases}$$

**Theorem 4.8 (One-symbol recovery).** If $p$ has positive legs, then $\mathrm{parentStep}(s\,p) = s$ and $\mathrm{parentOf}(s\,p) = p$ for every step $s$.

*Proof sketch.* Three case analyses. For $s=A$ the inverse $A^{-1}$ applied to $Ap$ returns $p$, whose legs are positive by hypothesis, so the first test fires. For $s=B$ one shows the $A$-test *fails* on $Bp$ (a linear-arithmetic contradiction with $a,b>0$) and the $B$-test then fires; similarly for $s=C$, where both earlier tests fail. $\square$

**Theorem 4.9 (Exact seed recovery — the falsifiability gate).** For every control word $w$, $\;\mathrm{decode}(|w|, \mathrm{path}(w)) = w$; consequently replaying the recovered word reproduces the observed triple exactly.

*Proof sketch.* Induction on $w$ from the right, using Theorem 4.8 at each peel. $\square$

Combining with Lemma 4.4: the decoder halts after at most $(c-5)/4$ rounds of three sign tests, so recovery is linear in the seed length and requires only integer additions and comparisons.

---

## 5. Routing: is this file seed-compressible?

### 5.1 Conserved branch signatures

**Theorem 5.1 (Invariants).** For all $t$:
$$c_t - b_t = c_0 - b_0 \quad\text{on the } A\text{-branch},\qquad c_t - a_t = c_0 - a_0 \quad\text{on the } C\text{-branch},$$
$$|b_t - a_t| = |b_0 - a_0| \quad\text{on the } B\text{-branch}.$$

*Proof sketch.* The first two follow by subtracting coordinates in the closed forms of Theorem 3.4, where the quadratic parts cancel identically. The third follows from $b_t-a_t = (-1)^t(b_0-a_0)$ (Theorem 3.6). $\square$

These are two-subtraction tests on consecutive observations, cheaper even than fitting a recurrence: a candidate $A$-file must have a frozen $c-b$ throughout.

### 5.2 A sound, complete, exact classifier

**Theorem 5.2 (Separation).** If $p$ has positive legs then $Ap$, $Bp$, $Cp$ are pairwise distinct.

*Proof sketch.* $Ap = Bp$ would force $-2b = 2b$, i.e. $b=0$; $Ap=Cp$ forces $a=0$; $Bp=Cp$ forces $a=0$. $\square$

**Definition 5.3 (Transition classifier).** Given consecutive observations $p,q$, define $\mathrm{which}(p,q)$ to be $A$ if $Ap=q$, else $B$ if $Bp=q$, else $C$ if $Cp=q$, else undefined.

**Theorem 5.4.** The classifier is
- **sound**: if $\mathrm{which}(p,q) = s$ then $s\,p = q$;
- **complete**: if $s\,p = q$ for some step $s$, then $\mathrm{which}(p,q)$ is defined;
- **exact on nondegenerate data**: if $p$ has positive legs and $s\,p=q$, then $\mathrm{which}(p,q)=s$.

*Proof sketch.* Soundness and completeness are immediate from the definition by case analysis on which test fires. Exactness uses Theorem 5.2: the three candidate images are distinct, so at most one test can fire, and by completeness exactly one does. $\square$

**Corollary 5.5 (Unambiguous routing).** If an observed stream with positive legs at $t=0$ is an orbit of both $s$ and $s'$, then $s=s'$. Both the seed and the two-bit family label are uniquely recoverable from the data.

*Proof sketch.* Apply exactness to the single transition $x(0)\mapsto x(1)$ twice, and compare the (equal) classifier outputs. $\square$

### 5.3 Negative benchmark items

Two explicit families of Pythagorean data are *not* seed-compressible in this generator family, showing the router genuinely rejects.

**Theorem 5.6 (Constant streams are not orbits).** Let $(a,b,c)$ be a Pythagorean triple with all entries positive. The constant stream $x(t) = (a,b,c)$ is not an orbit of $A$, $B$ or $C$.

*Proof sketch.* Positivity and $a^2+b^2=c^2$ give $a<c$ and $b<c$; each move then strictly increases the hypotenuse (Lemma 4.4), contradicting $x(1)=x(0)$. $\square$

This is an instructive rejection: constant data is *maximally* compressible, but by a model ("repeat"), not by a seed. Model-compressible and seed-compressible are genuinely different regimes, and the router must distinguish them.

**Theorem 5.7 (Rescaling destroys seed compressibility).** For every $p$ with positive legs, $Ap$, $Bp$, $Cp$ are all different from $(6,8,10)$.

*Proof sketch.* Case analysis. If $Ap=(6,8,10)$ then $a-2b+2c=6$ and $2a-b+2c=8$; subtracting gives $a+b=2$, so $a=b=1$, and then $2c=7$, impossible. If $Bp=(6,8,10)$ then $a+2b+2c=6$ and $2a+b+2c=8$ give $a-b=2$, whence $3b+2c=4$ with $b,c>0$, impossible. The case $Cp=(6,8,10)$ is symmetric to the first. $\square$

Thus the non-primitive triple $(6,8,10)$ — the doubling of the root — has no admissible parent and can never appear after the first step of any orbit, so it lies outside the range of the control-word code altogether. Scaling a covered file by an integer factor therefore removes it from the path code and forces the compressor back to spelling out a state; normalisation must precede detection in any deployment. (The rescaled file is of course still an orbit of the same linear move, so the *fixed-move* compressor still applies to it, with a seed of three full-size integers rather than a short control word — a quantitative, not qualitative, loss.)

---

## 6. Coverage and rarity

### 6.1 Coverage on the natural corpus

**Theorem 6.1 (Descent).** Every tree triple $p$ with hypotenuse $c>5$ has a step $s$ and a tree triple $q$ with $c(q)<c(p)$ and $s\,q = p$.

*Proof sketch.* Exactly one of the three inverse moves lands in the positive cone (a case analysis on the signs of $a-b$ and $b + a - c$ relative to the hypotenuse); that preimage is Pythagorean because the moves preserve the Lorentz form and are invertible; it is primitive because any common divisor of its legs divides its hypotenuse and hence, by unimodularity, divides both legs of $p$; and the parent hypotenuse $3c - 2a - 2b$ is strictly less than $c$ because $a+b>c$ for positive Pythagorean triples. $\square$

**Theorem 6.2 (Base case).** The only tree triple with hypotenuse at most $5$ is $(3,4,5)$.

*Proof sketch.* Positivity and Lemma 2.10 bound $a,b\le4$; a finite check of the remaining candidates against $a^2+b^2=c^2$, $\gcd(a,b)=1$ and $a$ odd leaves only $(3,4,5)$. $\square$

**Theorem 6.3 (Coverage: the corpus is $100\%$ seed-compressible).** Every tree triple is $\mathrm{path}(w)$ for some control word $w$.

*Proof sketch.* Strong induction on the hypotenuse. If $c\le5$ then $p=(3,4,5)=\mathrm{path}(\varepsilon)$ by Theorem 6.2. Otherwise Theorem 6.1 provides a tree-triple parent $q$ with strictly smaller (positive) hypotenuse; by induction $q = \mathrm{path}(u)$, and $p = \mathrm{path}(u\cdot s)$. $\square$

**Theorem 6.4 (The path code is a bijection).** A triple $p$ is a tree triple if and only if there is *exactly one* control word $w$ with $\mathrm{path}(w) = p$. Hence
$$\mathrm{path}\;:\;\{A,B,C\}^*\;\xrightarrow{\ \sim\ }\;\{\text{normalised primitive Pythagorean triples}\}.$$

*Proof sketch.* ($\Rightarrow$) Existence is Theorem 6.3; uniqueness is Theorem 4.6. ($\Leftarrow$) Every emitted triple is a tree triple by Lemma 2.11 and induction. $\square$

**Corollary 6.5 (End-to-end recovery).** For every tree triple $p$ there is a control word $w$ with $\mathrm{decode}(|w|,p) = w$ and $\mathrm{path}(w)=p$, and $|w| \le (c-5)/4$.

So on the corpus the generator was built for, the answer to "what fraction of this real data is generator output?" is exactly $1$, with a linear-time recovery algorithm and an exact reproduction guarantee.

### 6.2 The reach of the seed compressor over arbitrary files

Coverage on a special corpus says nothing about arbitrary files. Fix $N\ge1$ and let the *seed box* be $\{-N,\dots,N\}^3$, of cardinality $(2N+1)^3$. Let $W_N(n)$ be the set of length-$n$ files obtainable as a prefix of an orbit of $A$, $B$ or $C$ from a seed in the box.

**Theorem 6.6 (Length-independent capacity).** $\;|W_N(n)| \le 3\,(2N+1)^3$ for every $n$.

*Proof sketch.* $W_N(n)$ is a union of three images of the seed box under prefix maps; the image of a finite set has at most its cardinality, and the union of three sets has at most the sum of the cardinalities. $\square$

The point is what is *absent* from the bound: $n$. Adding symbols to the file gives the compressor no additional reach, because the seed determines the entire infinite orbit.

**Theorem 6.7 (Most files are not seed-compressible).** For $N\ge1$ and $n\ge2$ there exists a file $x$ of length $n$ with all symbols in the seed box that lies outside $W_N(n)$.

*Proof sketch.* The number of candidate files is $\bigl((2N+1)^3\bigr)^{n}$. Writing $K=2N+1\ge3$, we have $K^3\ge27$, hence $(K^3)^n \ge (K^3)^2 = K^3\cdot K^3 \ge 27K^3 > 3K^3 \ge |W_N(n)|$. A set of that size cannot be contained in $W_N(n)$. $\square$

### 6.3 The two answers reconciled

The two results are not in tension; together they are the design specification for a real system:

| | natural corpus (primitive triples) | arbitrary files over the same alphabet |
|---|---|---|
| fraction seed-compressible | $1$ | $\le 3(2N+1)^3 / (2N+1)^{3n}\to 0$ |
| seed size | $|w|\le(c-5)/4$ symbols | — |
| recovery cost | $3|w|$ sign tests | — |

A seed compressor is not a general-purpose codec; it is a detector with an enormous payoff on the thin set it recognises, and no effect elsewhere. Hence the architecture: cheap fingerprint first (Theorem 5.1 invariants, or a Berlekamp–Massey complexity probe), full recovery only when the fingerprint fires, statistical model otherwise.

---

## 7. The rate dichotomy: detection is not compression

Even *when* recovery succeeds, the compression may be negative. This section makes that precise.

**Theorem 7.1 (Unipotent branch: square-root seeds).** The all-$A$ word of length $k$ emits the hypotenuse
$$c = 2k^2 + 6k + 5 \;\le\; 2(k+2)^2 .$$
Hence the seed length is $k \approx \sqrt{c/2}$, whereas writing $c$ in binary costs $\Theta(\log c) = \Theta(\log k)$ bits: seed coding is *exponentially worse* than the raw encoding.

*Proof sketch.* Apply Corollary 3.5 with $t=k$, then $2k^2+6k+5 \le 2k^2+8k+8$. $\square$

**Theorem 7.2 (Pell branch: logarithmic seeds).** The all-$B$ word of length $k$ emits a hypotenuse $c \ge 5\cdot3^{k}$. Hence $k \le \log_3(c/5)$: seed coding is logarithmic in the data — genuine compression.

*Proof sketch.* Each $B$-step at least triples the hypotenuse, since $c \mapsto 2a+2b+3c \ge 3c$ (indeed $>3c$) for positive legs. Induct on $k$ from $c=5$. $\square$

(The true growth rate is $3+2\sqrt2\approx5.828$, the dominant root of $\lambda^2-6\lambda+1$; the factor $3$ is what a clean induction gives.)

**Theorem 7.3 (Universal logarithmic floor).** One step multiplies the hypotenuse by at most $7$: $c(s\,p)\le 7c(p)$ for good $p$. Hence $c(\mathrm{path}(w)) \le 5\cdot7^{|w|}$, i.e. $|w|\ge \log_7(c/5)$.

*Proof sketch.* Using $a,b<c$: each image hypotenuse is of the form $\pm2a\pm2b+3c \le 2c+2c+3c = 7c$. Induct along the word. $\square$

**Theorem 7.4 (Rate dichotomy).** For every $k$,
$$c\bigl(\mathrm{path}(B^k)\bigr)\;\ge\;5\cdot3^{k}, \qquad c\bigl(\mathrm{path}(A^k)\bigr)\;\le\;2(k+2)^2 .$$
Concretely at $k=10$: the all-$B$ seed of ten ternary symbols ($\approx16$ bits) names a hypotenuse of at least $295{,}245$, while ten all-$A$ symbols name only $265$.

Both branches are *equally detectable*: the same order-3 fingerprint, the same three-symbol recovery, the same detector cost. They differ entirely in profit. The separating quantity is the spectral radius: $\rho(B_B) = 3+2\sqrt2>1$ against $\rho(B_A)=\rho(B_C)=1$.

**Principle.** *Detectability is governed by the degree of the characteristic polynomial of the driving matrix; profitability is governed by its root moduli.* A generator can be certainly detected, its seed exactly recovered, and the resulting encoding still be larger than the data. The two invariants are extracted from the same polynomial and do not determine one another.

---

## 8. Algorithms

We summarise the pipeline as four procedures. Throughout, $n$ is the file length in triples and $k$ the recovered seed length.

**A1. Fingerprint probe (linear-complexity test).** Given an observed integer stream $y(0),\dots,y(n-1)$ and a target order $d$, run Berlekamp–Massey to obtain the minimal taps; report the complexity $L$ and taps $\tau$. Cost $O(n^2)$ integer operations (or $O(n\log^2 n)$ with fast variants). For our generators, $L\le3$ always; $L=2$ with taps $(-1,6)$ indicates the Pell branch, $L=3$ with taps $(1,-3,3)$ a unipotent branch.

**A2. Invariant probe.** Compute $c_t-b_t$, $c_t-a_t$ and $|b_t-a_t|$ across all observations; a branch is *admissible* if the corresponding quantity is constant. Cost $O(n)$ subtractions. This is the cheapest possible router and rejects most non-generator data instantly.

**A3. Transition classifier.** Apply each of $A,B,C$ to $x(t)$ and compare with $x(t+1)$. Cost $O(1)$ per transition, $O(n)$ per file; sound, complete, and exact on positive-leg data (Theorem 5.4).

**A4. Path decoder.** From an observed triple $q$, repeatedly apply the three sign tests, peeling one control symbol per round, until reaching $(3,4,5)$. Cost $3k$ tests, $k \le (c-5)/4$, each of $O(1)$ integer additions on numbers of size $O(\log c)$; total $O(k\log c)$ bit operations. Correctness and exactness are Theorems 4.8 and 4.9.

The complete compressor is: A2 (reject fast) $\to$ A1 (confirm and identify family) $\to$ A3/A4 (recover the seed) $\to$ *verify by replay* $\to$ if the replay is not bit-identical, or if the seed is longer than the data (Theorem 7.1), fall back to a model-based codec.

The verify-by-replay step is what makes the scheme safe: seed compression is only ever *attempted*, never *trusted*, and a failed attempt costs a linear scan.

---

## 9. Applications and discussion

**Corpus triage.** The immediate application is triage of numeric corpora. Tabulated Pythagorean triples, procedurally generated right-triangle meshes and integer-geometry test suites are all fully covered by Theorem 6.3, so on those inputs the ideal encoding is the control word, recoverable in linear time. The invariant probe (A2) makes the test essentially free on inputs that are *not* covered.

**Generator identification in the abstract.** Theorems 3.2 and 3.9 are about *any* integer $3\times3$ generator, not about Pythagorean triples. The practical statement is: a linear state machine over $\mathbb{Z}^d$ cannot hide from a linear-complexity probe on any linear observable, and cannot hide by being run in periodic blocks either, since a product of $d\times d$ matrices is again $d\times d$. What *does* defeat the probe is nonlinearity in the state update or in the output function — the design principle behind cryptographically strong generators, seen here from the attacker's side.

**A caution about "compressible".** Theorem 5.6 exhibits data that is trivially model-compressible and provably not seed-compressible; Theorem 7.1 exhibits data that is exactly seed-recoverable and yet seed-*in*compressible. These are the two independent failure modes of a naive "find the generator, store the seed" pipeline, and both are invisible to a detector that only measures linear complexity.

**Normalisation matters.** Theorem 5.7 shows that multiplying a covered file by $2$ moves it outside the reach of the generator entirely. In practice a seed-compression front end must therefore include an explicit normalisation stage (here: divide by the gcd, order the legs so the odd one comes first) and store the normalisation data separately — an overhead that a coverage theorem alone conceals.

**Limitations.** The results are exact but the family is narrow: three fixed unimodular matrices in dimension three. The fingerprint theorem generalises verbatim to any $d$, but the coverage and rate results use specific arithmetic of the Barning matrices. The rarity bound (Theorem 6.6) is stated for a bounded seed box; unbounded seeds make the reach infinite, though still measure zero in any reasonable sense. Finally, we treat exact integer data; noisy or truncated observations would require a robust variant of the complexity probe.

---

## 10. Future directions

**Conjecture 1 (Spectral compression law).** For a generator driven by an integer matrix $M \in \mathrm{GL}_3(\mathbb{Z})$ with spectral radius $\rho(M)>1$, the control-word length needed to reach a state of size $S$ is $\Theta(\log S/\log\rho(M))$; if $\rho(M)=1$ (unipotent) it is $\Theta(S^{1/d})$, where $d$ is the size of the largest Jordan block minus one. The insight is that detectability and compressibility are governed by two different invariants of the same matrix: detectability by the *degree* of the characteristic polynomial (always $3$ here, by Cayley–Hamilton), compressibility by its *root moduli*. Theorem 3.2 already gives the degree half in full generality, and Theorem 7.4 the two extreme cases of the root half; only the interpolation is missing.

**Conjecture 2 (A $\Theta(\sqrt c)$ lower bound for unipotent seeds is unavoidable).** For every control word $w$, $c(\mathrm{path}(w)) \ge 2|w|^2 + 6|w| + 5$, with equality exactly for the all-$A$ word. That is, the all-$A$ path is the slowest path in the whole tree, so the worst-case seed length is exactly $\Theta(\sqrt c)$. The insight is that the hypotenuse increment $c'-c = 2(a+c-b)$ is minimised by keeping the legs as unbalanced as possible, which is precisely what the unipotent branch does. Lemma 4.4 gives the linear bound $4|w|\le c-5$ by a one-line induction, and Corollary 3.5 gives the conjectured extremal value; the missing ingredient is a monotone potential function on the tree.

**Conjecture 3 (Berlekamp–Massey as a universal router).** For a stream produced by any fixed integer $d\times d$ generator matrix, the linear complexity returned by Berlekamp–Massey on $2d$ samples of a *generic* linear observable equals the degree of the minimal polynomial of the matrix, and the resulting taps, together with $d$ samples, determine the entire stream. Consequently a single complexity probe suffices both to route the file and to name the generator family, with no seed search at any point. The evidence here is Corollary 3.8: complexity $3$ versus $2$ already separates the unipotent branches from the Pell branch on a single observed coordinate.

**Further directions.** (a) Extend coverage to non-primitive data by a normalisation front end with provable overhead. (b) Quantify the reach of the compressor for unbounded seeds with a description-length prior instead of a box. (c) Robustness: how far can an observed stream be perturbed before the complexity probe fails, and can an error-correcting variant recover the seed from noisy data? (d) Nonlinear generators: identify the minimal nonlinearity that defeats every linear-complexity probe while keeping the state update efficiently invertible.

---

## 11. Conclusion

We have carried a complete detection-and-recovery pipeline through on a family of generators that produces genuine real-world data, and settled every question exactly rather than empirically.

Generator output leaves an unavoidable order-3 linear signature on every linear observable (Theorem 3.2), stable under periodic control words (Theorem 3.9) and sharp enough that the complexity value alone identifies the branch (Corollary 3.8). Recovery is exact: three symbols for a fixed-move stream (Theorem 4.1), a linear-time sign-test descent for the full ternary code (Theorem 4.9), with unique decodability (Theorem 4.6). Routing is sound, complete and exact (Theorem 5.4), with explicit rejected benchmark items (Theorems 5.6 and 5.7). Coverage on the natural corpus is total — an explicit bijection between control words and normalised primitive triples (Theorem 6.4) — while the reach over arbitrary files does not grow with the file length at all (Theorem 6.6).

The finding we consider most transferable is the rate dichotomy (Theorem 7.4): two branches of the *same* generator, with identical detectability, one compressing logarithmically and the other expanding by an exponential factor, separated only by whether the driving matrix has spectral radius greater than $1$. Finding the seed is the easy half. Profiting from it is the question that actually decides whether a compressor beats the pigeonhole bound on any given file.
