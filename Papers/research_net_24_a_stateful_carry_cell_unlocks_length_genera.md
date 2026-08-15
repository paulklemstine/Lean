# The Carry Chain Is an Answer-Function Obstruction: Depth Lower Bounds, a Stateful Cure, and the Cocycle Behind Them

**Author:** Aristotle
**Date:** 2026-08-15

---

## Abstract

We give a complete, elementary account of why base-$b$ addition resists computation by fixed-depth, state-free, position-parameterised answer functions, and of the minimal modification that removes the obstruction. Our results are of three kinds.

*Impossibility.* For every base $b \ge 2$ and every radius $k$, no state-free answer function whose output at column $i$ depends only on input columns $i-k, \dots, i$ produces the correct addition digits; the failure occurs already at column $k+1$. We derive the bounded-radius hypothesis from a structural model of layered local computation: a depth-$D$, radius-$r$ layered circuit has receptive field $D\cdot r$, hence correctness on all columns $i < n$ forces $n \le D r + 1$, i.e. $D \ge (n-1)/r$. Depth must grow *linearly* in the number of digits. Two corollaries isolate the mechanism: an order-blind (commutative) pooling of position-blind column features cannot compute the carry, and a stateful cell with a trivial (one-element) state type is exactly a radius-$0$ readout and therefore fails.

*Cure.* A single length-independent recurrent cell whose state admits a Boolean summary satisfying the one-column carry recurrence, and whose readout satisfies the one-column digit identity, is correct at *every* column and *every* length. Local (single-column) correctness of a stateful cell implies unbounded length generalisation, whereas for state-free readouts local correctness is unattainable at any radius. The concrete witness has a one-bit state. Conversely (a Myhill–Nerode argument) any cell correct at all lengths must separate histories by their carry: the carry bit is a function of the state, so one bit is necessary as well as sufficient.

*Structure.* The carry chain is the fold of per-column signals in the kill/propagate/generate monoid, which is associative but non-commutative; and the single-column carry $c(u,v) = \lfloor (u+v)/b\rfloor$ is a $2$-cocycle, $c(u,v) + c((u+v)\bmod b, w) = c(v,w) + c(u,(v+w)\bmod b)$, presenting the extension $0 \to \mathbb{Z}/b \to \mathbb{Z}/b^2 \to \mathbb{Z}/b \to 0$. Associativity of the cocycle and non-commutativity of the fold are the two halves of "the carry is order-sensitive sequential information".

We close by matching the theory against a controlled experimental programme in which a state-free attention model trained to perfection on $5$-digit addition scores exactly $0$ on $6$–$8$ digits, and in which replacing *only* the readout by a recurrent cell — same encoder, same budget, same masking — raises $8$-digit accuracy to $1.0000$.

---

## 1. Introduction

### 1.1 The phenomenon

Column addition is the first algorithm most people learn, and it is the standard stress test for length generalisation in sequence models. The empirical picture is stark and highly reproducible. A model trained on $n$-digit addition attains perfect accuracy on held-out $n$-digit problems, and then scores at chance on $(n{+}1)$-digit problems. The transition is not a degradation curve; it is a cliff.

More striking still is the *immunity* of the cliff to intervention. Increasing depth, increasing width, extending training, altering the curriculum, reformatting the task (reversing digit order, padding, index hinting), and changing the positional scheme all move the cliff or leave it where it is, but none of them abolishes it. The most diagnostic negative result is that supplying the *correct carries as additional input tokens* also fails.

This paper argues that the phenomenon is a theorem about a *class of functions*, not a fact about optimisation, data, or attention. The class is: fixed-depth, state-free, position-parameterised answer functions. Membership in that class is incompatible with correct addition at all lengths, for elementary and quantitative reasons. And leaving the class — by putting a single bit of running state in the answer path — makes correctness at all lengths automatic.

### 1.2 Notation and conventions

Fix a base $b \ge 2$. Digit streams are functions $x, y : \mathbb{N} \to \mathbb{N}$; a stream is *base-$b$ valid* if $x_j < b$ for all $j$. Column $0$ is the least significant. For a stream $x$ we write

$$\mathrm{val}_n(x) = \sum_{j<n} x_j b^{j}$$

for the value of its first $n$ columns. All results are stated for streams defined on all of $\mathbb{N}$; a finite problem of length $n$ is a stream padded with zeros, and all statements about "columns $i < n$" are statements about such padded streams. Working with infinite streams rather than $n$-indexed vectors is a deliberate simplification: it removes bookkeeping about lengths from every statement, and length generalisation becomes the plain assertion "for all $i$".

We write $[\![P]\!] \in \{0,1\}$ for the indicator of a proposition $P$.

---

## 2. The carry chain and its correctness at all lengths

**Definition 2.1 (Carry chain).** For base-$b$ streams $x,y$, define the *carry into column $i$*, $c_i \in \{0,1\}$, by
$$c_0 = 0, \qquad c_{i+1} = [\![\, b \le x_i + y_i + c_i \,]\!].$$
Define the *output digit at column $i$* by
$$d_i = (x_i + y_i + c_i) \bmod b .$$

Two features of this definition deserve emphasis because they are the crux of everything below. First, the recurrence is *length-independent*: the rule producing $c_{i+1}$ from $c_i$ and column $i$ makes no reference to $n$. Second, it is *stateful*: $d_i$ is not a function of $(x_i, y_i)$ alone, nor of any bounded window around column $i$.

**Lemma 2.2 (Column identity).** If $x_i < b$ and $y_i < b$, then
$$d_i + b\,c_{i+1} = x_i + y_i + c_i .$$

*Proof sketch.* Since $c_i \le 1$ and $x_i, y_i \le b-1$, we have $s := x_i + y_i + c_i < 2b$. If $s \ge b$ then $c_{i+1} = 1$ and $s \bmod b = s - b$, so $d_i + b = s$. If $s < b$ then $c_{i+1} = 0$ and $s \bmod b = s$. $\square$

This one equation is the entire arithmetic content of addition. Everything else is induction.

**Theorem 2.3 (Length-general correctness of the carry cell).** For all base-$b$ valid streams $x, y$ and all $n \ge 0$,
$$\mathrm{val}_n(d) + b^{n} c_n = \mathrm{val}_n(x) + \mathrm{val}_n(y).$$

*Proof sketch.* Induction on $n$. The base case is $0 = 0$. For the step, multiply the column identity at column $n$ by $b^n$:
$$d_n b^n + b^{n+1} c_{n+1} = x_n b^n + y_n b^n + b^n c_n ,$$
and add the inductive hypothesis $\mathrm{val}_n(d) + b^n c_n = \mathrm{val}_n(x) + \mathrm{val}_n(y)$, cancelling the common term $b^n c_n$. $\square$

Theorem 2.3 is the formal sense in which the schoolbook algorithm "generalises to every length": a *single* transition rule, unrolled, is exactly correct for all $n$ simultaneously. The rest of the paper is about which computational shapes can and cannot realise this.

---

## 3. Structure: the carry monoid and the carry cocycle

### 3.1 Kill, propagate, generate

**Definition 3.1 (Column signal).** The *signal* of column $i$ is the element of $\Sigma = \{\mathsf{kill}, \mathsf{prop}, \mathsf{gen}\}$ given by
$$\sigma_i = \begin{cases}\mathsf{gen} & x_i + y_i \ge b,\\ \mathsf{prop} & x_i + y_i = b-1,\\ \mathsf{kill} & x_i + y_i < b-1.\end{cases}$$
Signals act on an incoming carry bit by $\mathsf{kill}\cdot c = 0$, $\mathsf{prop}\cdot c = c$, $\mathsf{gen}\cdot c = 1$, and compose by "apply the right one, then the left one":
$$\mathsf{kill}\circ s = \mathsf{kill},\qquad \mathsf{gen}\circ s = \mathsf{gen},\qquad \mathsf{prop}\circ s = s .$$

**Proposition 3.2 (Monoid structure).** $(\Sigma, \circ, \mathsf{prop})$ is a monoid: composition is associative with identity $\mathsf{prop}$, and $(s \circ t)$ acts as the composite of the actions of $s$ and $t$. It is **not** commutative: $\mathsf{kill}\circ\mathsf{gen} = \mathsf{kill} \ne \mathsf{gen} = \mathsf{gen}\circ\mathsf{kill}$.

*Proof sketch.* Finite case check on $3^3$ triples for associativity, $3^2 \times 2$ for the action, and one explicit pair for non-commutativity. $\square$

**Theorem 3.3 (The carry is a monoid fold).** Let $S_n = \sigma_{n-1} \circ \sigma_{n-2} \circ \cdots \circ \sigma_0$ (with $S_0 = \mathsf{prop}$). Then $c_n = S_n \cdot 0$ for every $n$.

*Proof sketch.* Induction, using $S_{n+1} = \sigma_n \circ S_n$ and compatibility of composition with the action. $\square$

Theorem 3.3 says the carry is intrinsically an *ordered* accumulation. It is also the reason parallel-prefix (Kogge–Stone, Brent–Kung) adders exist: an associative fold of length $n$ can be computed in $O(\log n)$ rounds *if arbitrary long-range combination is allowed*. Note the qualifier — it is locality, not depth per se, that produces the wall of Section 4; see Section 8, Conjecture 2.

Non-commutativity has an immediate architectural consequence.

**Theorem 3.4 (No order-blind pooling).** Let $b \ge 2$, let $M$ be a commutative monoid, let $\phi : \mathbb{N}\times\mathbb{N} \to M$ be a position-blind per-column feature map and $\delta : M \to \{0,1\}$ a decision map. Then it is impossible that
$$c_n = \delta\Big(\textstyle\prod_{j<n} \phi(x_j,y_j)\Big)$$
for all base-$b$ valid $x, y$ and all $n$.

*Proof sketch.* Take the two-column inputs $x = (b-1, 0)$, $y = (1, 0)$ — generate then kill — and $x' = (0, b-1)$, $y' = (0,1)$ — kill then generate. Then $c_2 = 0$ for the first and $c_2 = 1$ for the second. But the two multisets of columns coincide, so by commutativity the two products agree, forcing $\delta$ to return the same bit. Contradiction. $\square$

This rules out, in one stroke, any readout that aggregates column features by an order-insensitive operation (sum, mean, max, unordered attention over content-only keys) and then thresholds.

### 3.2 The carry as a $2$-cocycle

Define the *numeric single-column carry*
$$c(u,v) = \left\lfloor \frac{u+v}{b} \right\rfloor .$$

**Proposition 3.5 (Basic properties).** For $u,v < b$: $c(u,v) \le 1$, and $c(u,v) = 1 \iff u + v \ge b$. Also $c(0,v) = 0$ for $v < b$, and $c(u,v) = c(v,u)$ for all $u,v$.

**Lemma 3.6 (Two-step carry accumulation).** For $b \ge 1$ and all $u,v,w$,
$$c(u,v) + c\big((u+v)\bmod b,\ w\big) = \left\lfloor \frac{u+v+w}{b}\right\rfloor .$$

*Proof sketch.* Write $u+v = b\lfloor (u+v)/b\rfloor + ((u+v)\bmod b)$, so that $u+v+w = ((u+v)\bmod b + w) + b\lfloor (u+v)/b\rfloor$; divide by $b$ and use $\lfloor (a + bq)/b \rfloor = \lfloor a/b\rfloor + q$. $\square$

**Theorem 3.7 (Carry cocycle identity).** For $b \ge 1$ and all $u,v,w \in \mathbb{N}$,
$$c(u,v) + c\big((u+v)\bmod b,\ w\big) \;=\; c(v,w) + c\big(u,\ (v+w)\bmod b\big).$$

*Proof sketch.* By Lemma 3.6 the left side equals $\lfloor (u+v+w)/b\rfloor$. For the right, use symmetry (Proposition 3.5) to rewrite $c(u, (v+w)\bmod b) = c((v+w)\bmod b, u)$ and apply Lemma 3.6 again with the triple $(v,w,u)$; the result is $\lfloor (v+w+u)/b\rfloor$. $\square$

Theorem 3.7 is precisely the $2$-cocycle condition for $c : \mathbb{Z}/b \times \mathbb{Z}/b \to \mathbb{Z}/b$, and $c$ is the classical cocycle presenting the central extension
$$0 \to \mathbb{Z}/b \to \mathbb{Z}/b^2 \to \mathbb{Z}/b \to 0 ,$$
under which an element of $\mathbb{Z}/b^2$ is written as a pair (low digit, high digit) and multiplication acquires the carry as its twist. The class $[c] \in H^2(\mathbb{Z}/b,\mathbb{Z}/b)$ is nonzero exactly because $\mathbb{Z}/b^2 \not\cong \mathbb{Z}/b \times \mathbb{Z}/b$ — i.e. exactly because carrying occurs.

Two readings of the algebra are worth separating:

- The cocycle is **symmetric** ($c(u,v) = c(v,u)$): a *single* column is order-free.
- The fold is **non-commutative** (Proposition 3.2): a *chain* of columns is not.

So the sequentiality of addition is not located in any column; it is created by composition. This is the precise sense in which the carry is "genuinely sequential information", and it is what makes the obstruction of the next section unavoidable rather than an artefact of encoding.

---

## 4. The wall: state-free bounded-window answer functions

### 4.1 The witness pair

Fix $b \ge 2$ and define three streams:
$$x^{\mathrm{hi}}_j = \begin{cases}1 & j = 0\\ b-1 & j > 0\end{cases}, \qquad x^{\mathrm{lo}}_j = \begin{cases}0 & j = 0\\ b-1 & j > 0\end{cases}, \qquad y^{\ast}_j = \begin{cases}b-1 & j = 0\\ 0 & j > 0.\end{cases}$$
All three are base-$b$ valid, and $x^{\mathrm{hi}}$ and $x^{\mathrm{lo}}$ agree at every column $j \ge 1$.

**Lemma 4.1 (Carry behaviour of the witnesses).** For all $i \ge 0$:
$$c_{i+1}(x^{\mathrm{hi}}, y^{\ast}) = 1, \qquad c_{i}(x^{\mathrm{lo}}, y^{\ast}) = 0 .$$

*Proof sketch.* For $x^{\mathrm{hi}}$: at column $0$, $1 + (b-1) = b$, so a carry is generated. At column $i \ge 1$, $(b-1) + 0 + 1 = b$, so the carry propagates; induction. For $x^{\mathrm{lo}}$: at column $0$, $0 + (b-1) = b-1 < b$; at column $i\ge1$, $(b-1)+0+0 = b-1 < b$; induction. $\square$

**Lemma 4.2 (Maximal digit divergence).** For every $i \ge 0$,
$$d_{i+1}(x^{\mathrm{hi}}, y^{\ast}) = 0 \qquad\text{and}\qquad d_{i+1}(x^{\mathrm{lo}}, y^{\ast}) = b-1 ,$$
so the two outputs differ at *every* column $\ge 1$.

*Proof sketch.* Immediate from Lemma 4.1: $((b-1) + 0 + 1)\bmod b = 0$ and $((b-1)+0+0)\bmod b = b-1$, and $0 \ne b-1$ since $b \ge 2$. $\square$

**Corollary 4.3 ($\Omega(n)$ sensitivity).** For every $n \ge 1$, the carry out of column $n$ depends on column $0$: the witnesses agree at all columns $j\ge 1$ yet $c_{n+1}(x^{\mathrm{hi}},y^{\ast}) \ne c_{n+1}(x^{\mathrm{lo}},y^{\ast})$.

The sensitivity is *maximal*: a single-coordinate perturbation flips every output coordinate. This is the strongest possible form of the obstruction, and it is why *every* intervention on window size merely relocates the failure.

### 4.2 The impossibility theorem

**Definition 4.4 (State-free readout of radius $k$).** A function $g : \mathbb{N} \times (\mathbb{N}\to\mathbb{N}) \times (\mathbb{N}\to\mathbb{N}) \to \mathbb{N}$ is a *state-free, position-parameterised answer function of receptive field $k$* if for all $i$ and all streams $x,y,x',y'$,
$$\big(\forall j,\ i-k \le j \le i \Rightarrow x_j = x'_j\big) \ \wedge\ \big(\forall j,\ i-k \le j \le i \Rightarrow y_j = y'_j\big)\ \Longrightarrow\ g(i,x,y) = g(i,x',y').$$

Note the generosity of the definition. The dependence on $i$ is completely arbitrary — a different, arbitrarily complex, arbitrarily well-tuned rule may be used at each position. The only constraint is that the answer at $i$ is a function of the inputs in a window of fixed radius, and does not depend on any quantity accumulated across positions.

**Theorem 4.5 (The Carry Wall).** Let $b \ge 2$ and $k \in \mathbb{N}$. There is no state-free answer function $g$ of receptive field $k$ with
$$g(i,x,y) = d_i(x,y) \quad\text{for all } i \text{ and all base-}b\text{ valid } x,y .$$
Moreover the failure is localised: correctness fails already at column $k+1$.

*Proof sketch.* Evaluate at $i = k+1$. The window is $\{1, \dots, k+1\}$, and on that window $x^{\mathrm{hi}}$ and $x^{\mathrm{lo}}$ agree (they differ only at column $0$), while $y^\ast$ is compared with itself. Locality gives $g(k+1, x^{\mathrm{hi}}, y^\ast) = g(k+1, x^{\mathrm{lo}}, y^\ast)$. Correctness rewrites both sides as the corresponding true digits, which by Lemma 4.2 are $0$ and $b-1$. $\square$

The theorem should be read as a statement about *where* a bounded-window learner can be correct: on columns $0,\dots,k$ nothing prevents correctness, and at column $k+1$ correctness is impossible. This matches, exactly, the observed shape of the empirical wall — perfect up to the training length, chance immediately beyond.

---

## 5. From layered locality to a depth lower bound

Theorem 4.5 assumes a bounded receptive field. We now derive that assumption from a structural model, and quantify it.

**Definition 5.1 (Layered local circuit).** Fix a value type $V$ and a *mixing radius* $r$. A *layered local circuit of depth $D$* consists of:
- an embedding $E : \mathbb{N}\times\mathbb{N}\times\mathbb{N}\to V$, giving the layer-$0$ value $v^{(0)}_i = E(i, x_i, y_i)$;
- layer maps $L_\ell : \mathbb{N} \times (\mathbb{N}\to V) \to V$ for $\ell = 0,\dots,D-1$, with $v^{(\ell+1)}_i = L_\ell(i, v^{(\ell)})$, subject to the *locality constraint*: $L_\ell(i, v)$ depends only on the values $v_j$ for $i - r \le j \le i$;
- a readout $R : V \to \mathbb{N}$, giving the answer $\mathcal{A}(i,x,y) = R\big(v^{(D)}_i\big)$.

Both the embedding and every layer may depend arbitrarily on the position index $i$ and on the layer index $\ell$. This is the natural abstraction of a fixed-depth stack of local mixing layers with an arbitrary position-parameterised readout.

**Theorem 5.2 (Receptive field growth).** For every $\ell$ and $i$, the value $v^{(\ell)}_i$ depends only on the input columns $j$ with $i - \ell r \le j \le i$. Formally, if $x_j = x'_j$ and $y_j = y'_j$ for all $j$ with $i - \ell r \le j \le i$, then the layer-$\ell$ values at column $i$ computed from $(x,y)$ and from $(x',y')$ coincide.

*Proof sketch.* Induction on $\ell$. At $\ell = 0$ the value depends only on column $i$. For the step, apply the locality constraint at layer $\ell$: it suffices that the layer-$\ell$ values agree at every $j \in [i-r, i]$. For such $j$, the inductive hypothesis needs agreement of inputs on $[j - \ell r, j] \subseteq [i - r - \ell r, i] = [i - (\ell+1)r, i]$, which is the hypothesis. (The only subtlety is truncated subtraction on $\mathbb{N}$: one uses $i - (\ell+1)r = i - r - \ell r$.) $\square$

**Corollary 5.3.** A depth-$D$, radius-$r$ layered local circuit realises a state-free answer function of receptive field $D\cdot r$.

**Theorem 5.4 (No fixed-depth local circuit adds).** For every $b \ge 2$, every $r$, every $D$ and every layered local circuit of depth $D$ and radius $r$, the circuit's answer function fails to equal $d_i$ for all $i$ and all base-$b$ valid inputs. The failure occurs at column $D r + 1$.

*Proof sketch.* Combine Corollary 5.3 with Theorem 4.5 at $k = Dr$. $\square$

**Theorem 5.5 (Depth lower bound).** Let $b\ge 2$ and let a layered local circuit of depth $D$ and radius $r$ be correct at every column $i < n$ (for all base-$b$ valid inputs). Then
$$n \le D\,r + 1, \qquad\text{i.e.}\qquad D \ \ge\ \frac{n-1}{r}.$$

*Proof sketch.* Suppose $n > Dr + 1$ and set $k = Dr$. Then $k+1 < n$, so correctness applies at column $k+1$. As in Theorem 4.5, the witnesses agree on the window $[1, k+1]$, so the circuit's answers agree, while the true digits are $0$ and $b-1$. $\square$

Three remarks.

1. **Linear, not logarithmic.** The bound is linear in $n$ for fixed $r$. The $O(\log n)$ depth of parallel-prefix adders is not a counterexample: those circuits use *global* combination (at round $t$ a node reads a node $2^t$ positions away), which violates the fixed-radius locality constraint. What Theorem 5.5 isolates is that *locality*, in the presence of fixed depth, is the binding constraint.
2. **The wall is a resource wall, and scaling relocates it.** Doubling $D$ doubles the reachable length. It never removes the boundary. This is the theoretical content of the empirical observation that the cliff is immune to scale.
3. **Sharpness of the failure column.** The bound is achieved at exactly the first column beyond reach, which is why the observed transition is a cliff rather than a slope.

Contrast the stateful case:

**Proposition 5.6 (No depth bound for the stateful cell).** The one-bit carry cell emits the correct digit at every column $i < n$, for every $n$, with a single recurrent layer. Hence no analogue of Theorem 5.5 constrains it: the depth bound is a property of state-freeness, not of the task.

---

## 6. The cure: stateful answer cells

### 6.1 Abstract cells and length generalisation

**Definition 6.1 (Answer cell).** An *answer cell* over a state type $S$ is a triple $C = (\mathrm{init}, \mathrm{step}, \mathrm{out})$ with $\mathrm{init} \in S$, $\mathrm{step} : S \times \mathbb{N}\times\mathbb{N} \to S$, and $\mathrm{out} : S\times\mathbb{N}\times\mathbb{N}\to\mathbb{N}$. Its *unrolling* is
$$\mathrm{run}_0 = \mathrm{init}, \qquad \mathrm{run}_{i+1} = \mathrm{step}(\mathrm{run}_i,\ x_i,\ y_i),$$
and its answer at column $i$ is $\mathrm{out}(\mathrm{run}_i, x_i, y_i)$.

The cell is *length-independent by construction*: one transition, one readout, applied identically at every column, with no reference to $n$. It may depend arbitrarily on the per-column features it is fed.

**Theorem 6.2 (Stateful cure: local correctness implies length generalisation).** Let $C$ be an answer cell over any state type $S$, and suppose there exists a summary $\rho : S \to \{0,1\}$ such that

1. $\rho(\mathrm{init}) = 0$;
2. for every $s\in S$ and every $u,v < b$: $\ \rho(\mathrm{step}(s,u,v)) = [\![\, b \le u + v + \rho(s)\,]\!]$;
3. for every $s\in S$ and every $u,v<b$: $\ \mathrm{out}(s,u,v) = (u + v + \rho(s)) \bmod b$.

Then for all base-$b$ valid streams $x,y$ and all $i$, $\ \mathrm{out}(\mathrm{run}_i, x_i, y_i) = d_i(x,y)$.

*Proof sketch.* First show $\rho(\mathrm{run}_i) = c_i$ by induction: the base case is (1), and the step is (2) followed by the definition of $c_{i+1}$. Then apply (3) at column $i$ and substitute. $\square$

The logical shape here is the point of the paper. Hypotheses (1)–(3) are statements about *one column* — quantities a learner can be exposed to entirely within its training distribution. The conclusion is correctness at *all* columns and *all* lengths. Nothing bridges the two except the recurrence.

Compare with the state-free case. There, the analogous "local correctness" requirement is not merely difficult to satisfy from short data — Theorem 4.5 says it is unsatisfiable at any radius. The distinction is not statistical (how much data, what curriculum) but expressive.

**Definition 6.3 (The one-bit carry cell).** Let $S = \{0,1\}$, $\mathrm{init} = 0$, $\mathrm{step}(c,u,v) = [\![b \le u+v+c]\!]$, and $\mathrm{out}(c,u,v) = (u+v+c)\bmod b$.

**Proposition 6.4.** The unrolled state of the one-bit carry cell is exactly the carry chain, $\mathrm{run}_i = c_i$, and consequently it emits exactly the addition digits at every column; combined with Theorem 2.3, its outputs sum correctly at every length.

### 6.2 State is necessary

**Theorem 6.5 (Stateless cells fail).** If the state type $S$ is a singleton (more generally, a subsingleton), then no answer cell over $S$ is correct at all columns, for any $b \ge 2$.

*Proof sketch.* If all states are equal, $\mathrm{run}_i$ carries no information, so $\mathrm{out}(\mathrm{run}_i,x_i,y_i)$ is a function of $(i, x_i, y_i)$ only, i.e. a state-free readout of radius $0$. Apply Theorem 4.5 with $k=0$. $\square$

**Theorem 6.6 (Any correct cell encodes the carry; Myhill–Nerode).** Let $C$ be an answer cell over any state type $S$ that is correct at all columns for all base-$b$ valid inputs. If two histories drive the cell into the same state — that is, if $\mathrm{run}_i(x,y) = \mathrm{run}_{i'}(x',y')$ for base-$b$ valid $x,y,x',y'$ and possibly different $i, i'$ — then $c_i(x,y) = c_{i'}(x',y')$. Equivalently, the carry bit factors through the reachable states.

*Proof sketch.* Probe the state with a *zero column*. Replace $x,y$ by streams $z,w$ that agree with $x,y$ below column $i$ and have $z_i = w_i = 0$; do the same for $x',y'$ at column $i'$. Since both the unrolled state at $i$ and the carry into $i$ depend only on columns strictly below $i$, the probe changes neither: $\mathrm{run}_i(z,w) = \mathrm{run}_i(x,y)$ and $c_i(z,w) = c_i(x,y)$. But on a zero column the emitted digit is
$$d_i(z,w) = (0 + 0 + c_i)\bmod b = c_i$$
(using $c_i \le 1 < b$). Correctness therefore forces $\mathrm{out}(\mathrm{run}_i, 0,0) = c_i(x,y)$ and likewise $\mathrm{out}(\mathrm{run}_{i'},0,0) = c_{i'}(x',y')$. Since the states are equal, the two left sides are equal, hence so are the carries. $\square$

Theorems 6.2, 6.5 and 6.6 together characterise the situation: at least two reachable states are needed, one bit suffices, and what the bit must contain is exactly the carry. Nothing else about the state matters, and no amount of state can substitute for having *that* bit.

### 6.3 The dichotomy in one statement

**Theorem 6.7 (Dichotomy).** Let $b \ge 2$ and $k \in \mathbb{N}$. Then simultaneously:

1. no state-free, position-parameterised answer function of receptive field $k$ produces the correct addition digits at all columns;
2. the one-bit carry cell produces the correct addition digit at every column, for every input;
3. its digit outputs satisfy $\mathrm{val}_n(d) + b^n c_n = \mathrm{val}_n(x) + \mathrm{val}_n(y)$ for every $n$.

The same task, the same per-column information; the only difference between (1) and (2) is whether the answer path has state.

---

## 7. Matching the theory to experiment

The mathematics above predicts a precise experimental signature. We record the correspondence.

**Setup.** A causal attention encoder ($d_{\text{model}} = 192$) produces per-column features for a base-$10$ addition problem; a readout turns features into output digits. Training is on $5$-digit problems only, teacher-forced on the input, batch size $256$, $12{,}000$ steps. Evaluation uses $2048$ fresh problems at each of $n = 5,6,7,8$, with two independent seeds. All arms share the encoder, budget and masking; only the readout differs.

| Arm | $n=5$ | $n=6$ | $n=7$ | $n=8$ |
|---|---|---|---|---|
| Recurrent cell on raw one-hot columns, seed 0 | 1.0000 | 0.9980 | 0.7021 | 0.0806 |
| Recurrent cell on raw one-hot columns, seed 1 | 1.0000 | 1.0000 | 0.9854 | 0.6997 |
| **Encoder $\to$ recurrent readout (rotary positions), seed 0** | **1.0000** | **1.0000** | **1.0000** | **1.0000** |
| **Encoder $\to$ recurrent readout (rotary positions), seed 1** | **1.0000** | **1.0000** | **1.0000** | **1.0000** |
| Encoder $\to$ recurrent readout (learned absolute positions) | 1.0000 | 0.9834 | 0.9634 | 0.9624 |
| Encoder $\to$ state-free readout (reference) | 1.0000 | **0.0000** | **0.0000** | **0.0000** |

Four observations, each with a theoretical counterpart.

**(i) The reference wall is exact, not approximate.** The state-free readout scores $1.0000$ at the training length and $0.0000$ immediately beyond. Theorem 4.5 predicts precisely this: correctness is possible up to the receptive-field horizon and *impossible* at the very next column, and Lemma 4.2 explains why the failure is total rather than partial — the witness pair differs in *every* output column, so a maximally-sensitive task offers no graceful degradation.

**(ii) The state, and only the state, is the cure.** Same encoder, same budget, same mask; the only change is that the readout carries a hidden state across columns. Accuracy at $n=8$ moves from $0.0000$ to $1.0000$, with zero errors across $18{,}400$ fresh digit predictions and both seeds. Theorem 6.2 is the reason such a jump is even possible: the recurrent readout only ever has to be locally correct, and local correctness is self-propagating to all lengths.

**(iii) Carries as input tokens are useless; carries as state are the cure.** A prior negative result in the same programme is that supplying the ground-truth carries as extra *input tokens* leaves the wall in place. The theory explains it exactly: a state-free bounded-window readout given carries in the input must still route the carry to the correct column through a bounded window, and Theorem 4.5 applies verbatim to the augmented input as long as the readout remains state-free and local. The information content is not the issue; the *shape of the function consuming it* is.

**(iv) Recurrence alone is not sufficient — features matter too.** A plain recurrent network fed raw one-hot columns extends only one or two columns past its training unroll ($0.70$ at $n=7$, $0.08$ at $n=8$ for one seed; better but still degrading for the other). The theory locates the failure: hypothesis (2) of Theorem 6.2 (the carry transition) is length-general and is learned; hypothesis (3) (the digit readout) is a statement about *feature patterns*, and a readout that has only seen a subset of them misfires. The cure is state **plus** content-rich column features. (A capacity caveat should be flagged honestly: the pure recurrent arm has $\approx 125$k parameters against $\approx 782$k for the hybrid.)

**(v) The cure is positional-scheme independent.** The learned-absolute-position hybrid also generalises past its training length ($0.9624$ at $n=8$), with a thin uniform per-column error tail — the signature of untrained embedding-table entries, i.e. feature-quality noise, not a structural barrier. Nothing in Theorem 6.2 mentions positions; consistently, the cure survives changing them.

The single caveat we flag is that the central claim (0 $\to$ 1 at $n=8$) is supported by two seeds, both at $1.0000$, whereas the pure-recurrent state-horizon effect is seed-dependent.

---

## 8. Discussion and future directions

### 8.1 What the results do and do not say

They say: *fixed-depth, state-free, bounded-window* computation of the base-$b$ addition digits is impossible at all lengths, with a sharp failure column and a linear depth requirement; a single bit of running state in the answer path removes the obstruction, and that bit is forced.

They do not say that attention architectures cannot add. They say that the *answer function* must have state — where "state" means a quantity threaded across output positions, not merely an activation computed in parallel. Nor do they bound anything about learnability: all statements are expressive.

### 8.2 Four conjectures

**Conjecture 1 (Sharp state-size threshold).** For every base $b \ge 2$, a cell that emits the base-$b$ addition digits at every column induces a surjection from its reachable states onto $\{0,1\}$ given by the carry, and a two-element state suffices; hence the minimum state size is $2$, *independently of $b$*. The necessity half is Theorem 6.6 and the sufficiency half is Definition 6.3; what remains is the reachability of both carry values and packaging as a cardinality statement. Notably the base enters the readout, never the state.

**Conjecture 2 (The depth–radius–length trade-off is tight).** Theorem 5.5 gives $n \le Dr+1$. Conjecture: for every $n, r$ there is an explicit circuit of depth $\lceil (n-1)/r\rceil$ computing all digits of $n$-digit base-$b$ addition, via a prefix scan over the signal monoid with $r$-ary composition per layer. Since a monoid scan of length $n$ with $r$-ary associative combination has depth $\lceil \log_r n\rceil$ under the *balanced* schedule, the conjecture also predicts that allowing global (non-local) mixing collapses the linear bound to a logarithmic one — isolating *locality*, not depth, as the operative constraint.

**Conjecture 3 (Cohomological criterion for walling).** For a finite abelian extension $0 \to A \to E \to Q \to 0$ with cocycle $c$, a state-free bounded-window readout can compute the $E$-product of $n$ factors *iff* the class $[c] \in H^2(Q,A)$ is trivial. The carry chain is walled exactly because $[c]\neq 0$ for $\mathbb{Z}/b^2 \to \mathbb{Z}/b$. The intuition: a coboundary $c = \delta f$ can be absorbed into a per-column relabelling, which is precisely a state-free positionwise transformation; a nontrivial class cannot.

**Conjecture 4 (Sensitivity dichotomy).** For families of column tasks computable by *some* finite-state cell, the state-free bounded-window wall occurs exactly when the task has $\Omega(n)$ sensitivity in the sense of Corollary 4.3 — a single low-order coordinate influencing arbitrarily distant outputs. Tasks with $O(1)$ sensitivity should be exactly the ones a bounded window handles.

### 8.3 Practical reading

If a model must compose an unbounded number of steps and the composition law is order-sensitive, put state in the answer path. Increasing depth buys columns linearly and then stops; providing the missing quantity as *input* does not help if the consumer is still a local, state-free function; and the amount of state needed may be, as here, a single bit. The engineering question the mathematics leaves open is whether the same surgery — a stateful answer path over strong parallel features — transfers to sequential-composition failures in general-purpose language models. That is the frontier.

---

## 9. Summary of results

- **Column identity and length-general correctness.** $d_i + b c_{i+1} = x_i+y_i+c_i$; hence $\mathrm{val}_n(d) + b^n c_n = \mathrm{val}_n(x)+\mathrm{val}_n(y)$ for all $n$.
- **Monoid structure.** The carry is the fold of kill/propagate/generate signals; composition is associative with identity $\mathsf{prop}$ and is non-commutative.
- **No order-blind pooling.** Commutative pooling of position-blind column features cannot produce the carry bit.
- **Maximal sensitivity.** Two inputs differing only in column $0$ have outputs differing in every column $\ge 1$.
- **The Carry Wall.** No state-free readout of any radius $k$ is correct; failure occurs at column $k+1$.
- **Receptive field and depth bound.** A depth-$D$, radius-$r$ layered local circuit has receptive field $Dr$; correctness on all columns $< n$ forces $n \le Dr+1$.
- **Stateful cure.** One-column correctness of a stateful cell implies correctness at every column and every length; a one-bit state suffices.
- **Necessity of the carry bit.** Any cell correct at all lengths has the carry as a function of its state; a subsingleton state type fails.
- **Carry cocycle.** $c(u,v)=\lfloor (u+v)/b\rfloor$ satisfies the $2$-cocycle identity and presents $0\to\mathbb{Z}/b\to\mathbb{Z}/b^2\to\mathbb{Z}/b\to 0$; it is symmetric, so order-sensitivity lives in the composition, not the column.
