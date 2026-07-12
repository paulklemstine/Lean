# The Finite-Kernel Criterion for Automatic Sequences: A Composition-Law Foundation

## Abstract

An *automatic sequence* is a sequence whose $n$-th term is produced by feeding
the base-$k$ digits of $n$ into a deterministic finite automaton and reading a
state-dependent output. We develop the theory of automatic sequences entirely
through the **kernel criterion**, avoiding automata as primitive objects. For a
base $k \ge 2$ and a sequence $a : \mathbb{N} \to S$, we define the *decimation*
$a_{i,r} : n \mapsto a(k^{\,i} n + r)$ and the *$k$-kernel* as the set of all
decimations with offset $r < k^{\,i}$. A sequence is declared **$k$-automatic**
when its $k$-kernel is finite (Eilenberg's criterion). Our central structural
result is a single **decimation semigroup law**: the composite of two decimations
is again a decimation, with explicit parameters. From this one identity we derive
that the kernel is closed under decimation, that automaticity is preserved by
constants, by output codings, and by arbitrary pointwise binary combinations, and
that every automatic sequence has finite range. We then treat the **Thue–Morse
sequence** as the canonical example: it satisfies the base-$2$ recurrence
$t_{2n} = t_n$, $t_{2n+1} = t_n + 1$ over $\mathbb{Z}/2$, its $2$-kernel is
*exactly* $\{t,\, t+1\}$, and consequently it is $2$-automatic with a two-state
kernel. Finally we establish an exact dictionary between the additive parity form
$t_n \in \{0,1\}$ and the multiplicative sign form $\varepsilon_n = (-1)^{t_n}
\in \{\pm 1\}$. The result is a compact, characteristic-free foundation in which
the closure theory of automatic sequences reduces to elementary consequences of
one composition identity.

**Keywords:** automatic sequence, $k$-kernel, decimation, Thue–Morse sequence,
finite automaton, Eilenberg criterion, closure properties, deterministic
computation.

---

## 1. Introduction

Automatic sequences are the sequences computable by the weakest interesting model
of computation: a deterministic finite automaton with no auxiliary memory. One
feeds the digits of an index $n$ (in a fixed base $k$) into the automaton and
records an output attached to the final state. Despite this severe restriction,
the class captures a remarkable menagerie of number-theoretic objects — the
Thue–Morse sequence, the Rudin–Shapiro sequence, the regular paperfolding
sequence — and enjoys a rich algebraic and logical theory.

There are two standard vantage points. The **operational** one takes the
automaton as primitive and defines a sequence to be automatic when *some*
automaton generates it. The **combinatorial** one, due to Eilenberg, characterizes
automaticity intrinsically: a sequence is $k$-automatic iff its *$k$-kernel* — the
collection of subsequences obtained by sampling along power-of-$k$ arithmetic
progressions — is finite. The two are equivalent, and the kernel viewpoint has a
decisive advantage: it never mentions automata, states, or transitions, so it can
serve as a *definition* from which the entire structural theory is derived by
elementary means.

This paper takes the kernel criterion as the definition and shows how far a single
composition identity carries. The organizing principle is that **decimations
compose**: sampling along one power-of-$k$ progression and then along another is
the same as sampling along a single, explicitly computable progression. This
semigroup law is the source of every closure theorem below. We work over an
arbitrary output type $S$ so that the finiteness statements have genuine content
(they are not artifacts of a finite codomain), and we specialize to Thue–Morse to
exhibit the smallest nontrivial kernel.

### Contributions

1. A self-contained development of the $k$-kernel and the finite-kernel
   definition of automaticity over an arbitrary output alphabet (Section 3).
2. The decimation semigroup law and the resulting kernel-closure property
   (Section 4).
3. Closure of the automatic class under constants, output codings, and pointwise
   binary operations, plus finiteness of range (Section 5).
4. A complete analysis of the Thue–Morse kernel: the base-$2$ recurrence, the
   exact two-element kernel, and automaticity (Section 6).
5. The parity–sign dictionary linking the additive and multiplicative forms of
   Thue–Morse (Section 7).

---

## 2. Notation

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$, the base $k$ is a natural number
(the interesting range is $k \ge 2$), and $S, T, U$ are arbitrary types serving as
output alphabets. A *sequence* over $S$ is a function $a : \mathbb{N} \to S$. We
write $s_2(n)$ for the number of $1$-digits in the binary expansion of $n$ (the
binary digit sum). A subset of a type is *finite* in the usual sense; the key
technical fact we use repeatedly is that a subset of a finite set is finite, and
that the image of a finite set under a function is finite.

---

## 3. The kernel criterion

**Definition 3.1 (Decimation).** For a base $k$, a sequence $a : \mathbb{N} \to
S$, and natural numbers $i$ (the *depth*) and $r$ (the *offset*), the
**$(i,r)$-decimation** of $a$ is the sequence
$$a_{i,r} : \mathbb{N} \to S, \qquad a_{i,r}(n) = a\big(k^{\,i} n + r\big).$$

Intuitively, $a_{i,r}$ is the subsequence of $a$ indexed by the arithmetic
progression $r, r + k^{\,i}, r + 2k^{\,i}, \dots$. When $k = 2$, $i = 1$, the two
decimations $a_{1,0}$ and $a_{1,1}$ are the even- and odd-indexed subsequences.

**Definition 3.2 ($k$-kernel).** The **$k$-kernel** of $a$ is the set of all
decimations whose offset is a proper residue for the depth:
$$\mathcal{K}_k(a) = \big\{\, a_{i,r} \;:\; i, r \in \mathbb{N},\ r < k^{\,i} \,\big\}.$$
The offset bound $r < k^{\,i}$ restricts attention to residues modulo $k^{\,i}$,
which is exactly the set of prefixes of length $i$ read by an automaton; it is
also what makes the kernel closed under composition (Section 4).

**Definition 3.3 (Automaticity).** A sequence $a$ is **$k$-automatic** if its
$k$-kernel $\mathcal{K}_k(a)$ is finite.

**Lemma 3.4 (Trivial decimation).** The $(0,0)$-decimation recovers the sequence:
$a_{0,0} = a$. In particular $a \in \mathcal{K}_k(a)$.

*Proof.* $a_{0,0}(n) = a(k^{0} n + 0) = a(n)$. Taking $i = r = 0$ (and $0 < k^0 =
1$) exhibits $a$ as a member of its own kernel. $\qquad\blacksquare$

---

## 4. The composition law

The technical heart of the theory is that decimation is closed under iteration.

**Theorem 4.1 (Decimation semigroup law).** For every base $k$, sequence $a$, and
parameters $i, r, j, s$,
$$\big(a_{i,r}\big)_{j,s} \;=\; a_{\,i+j,\ k^{\,i} s + r}.$$

*Proof.* Evaluate both sides at $n$. The left side is
$$\big(a_{i,r}\big)_{j,s}(n) = a_{i,r}\big(k^{\,j} n + s\big)
  = a\big(k^{\,i}(k^{\,j} n + s) + r\big) = a\big(k^{\,i+j} n + k^{\,i} s + r\big),$$
using $k^{\,i} k^{\,j} = k^{\,i+j}$. The right side is
$a_{\,i+j,\ k^{\,i} s + r}(n) = a\big(k^{\,i+j} n + (k^{\,i} s + r)\big)$, which
agrees. $\qquad\blacksquare$

The law says the parameter set $\{(i, r)\}$ acts on sequences as a semigroup:
composing $(i, r)$ after $(j, s)$ yields $(i + j,\ k^{\,i} s + r)$. This is the
monoid structure underlying automatic sequences.

**Theorem 4.2 (Kernel closure).** If $b \in \mathcal{K}_k(a)$, then
$\mathcal{K}_k(b) \subseteq \mathcal{K}_k(a)$.

*Proof.* Write $b = a_{i,r}$ with $r < k^{\,i}$. Let $c \in \mathcal{K}_k(b)$, so
$c = b_{j,s} = (a_{i,r})_{j,s}$ with $s < k^{\,j}$. By Theorem 4.1, $c =
a_{\,i+j,\ k^{\,i} s + r}$. It remains to check the offset bound. Since $s + 1 \le
k^{\,j}$ and $r < k^{\,i}$,
$$k^{\,i} s + r < k^{\,i} s + k^{\,i} = k^{\,i}(s + 1) \le k^{\,i} k^{\,j} =
k^{\,i+j}.$$
Hence $c = a_{\,i+j,\ k^{\,i} s + r}$ with offset $< k^{\,i+j}$, i.e. $c \in
\mathcal{K}_k(a)$. $\qquad\blacksquare$

The inequality $k^{\,i} s + r < k^{\,i+j}$ is the load-bearing step: it certifies
that a decimation of a decimation is a *legitimate* kernel member, not merely a
decimation with an out-of-range offset.

**Corollary 4.3 (Automaticity is inherited by decimations).** If $a$ is
$k$-automatic and $b \in \mathcal{K}_k(a)$, then $b$ is $k$-automatic.

*Proof.* By Theorem 4.2, $\mathcal{K}_k(b) \subseteq \mathcal{K}_k(a)$; a subset
of a finite set is finite. $\qquad\blacksquare$

---

## 5. Closure properties

We now record the algebraic robustness of the automatic class. Each proof
exhibits the kernel of the constructed sequence as a subset (or a finite image) of
a finite set.

**Proposition 5.1 (Constants).** For any $c \in S$, the constant sequence $n
\mapsto c$ is $k$-automatic.

*Proof.* Every decimation of a constant sequence is the same constant sequence,
so $\mathcal{K}_k(\text{const}_c) \subseteq \{\text{const}_c\}$, a singleton. A
subset of a singleton is finite. $\qquad\blacksquare$

**Lemma 5.2 (Decimation commutes with output coding).** For $g : S \to T$,
$$\big(g \circ a\big)_{i,r} = g \circ \big(a_{i,r}\big).$$

*Proof.* Both sides send $n$ to $g\big(a(k^{\,i} n + r)\big)$. $\qquad\blacksquare$

**Theorem 5.3 (Closure under output codings).** If $a$ is $k$-automatic and $g :
S \to T$ is any function, then $g \circ a$ is $k$-automatic.

*Proof.* By Lemma 5.2, every decimation of $g \circ a$ has the form $g \circ b$
for some $b \in \mathcal{K}_k(a)$. Thus $\mathcal{K}_k(g \circ a)$ is contained in
the image of the finite set $\mathcal{K}_k(a)$ under the map $b \mapsto g \circ
b$; the image of a finite set is finite. $\qquad\blacksquare$

**Lemma 5.4 (Decimation commutes with pointwise combination).** For $f : S \to T
\to U$ and sequences $a, b$,
$$\big(n \mapsto f(a_n, b_n)\big)_{i,r} = \big(n \mapsto f(a_{i,r}(n),\, b_{i,r}(n))\big).$$

*Proof.* Both sides send $n$ to $f\big(a(k^{\,i} n + r),\, b(k^{\,i} n + r)\big)$.
$\qquad\blacksquare$

**Theorem 5.5 (Closure under pointwise operations).** If $a$ and $b$ are both
$k$-automatic and $f : S \to T \to U$ is arbitrary, then $n \mapsto f(a_n, b_n)$
is $k$-automatic. In particular, when the outputs lie in a ring, the pointwise
sum $n \mapsto a_n + b_n$ and pointwise product $n \mapsto a_n \cdot b_n$ are
$k$-automatic.

*Proof.* By Lemma 5.4, each decimation of $n \mapsto f(a_n, b_n)$ is determined by
the pair $\big(a_{i,r},\, b_{i,r}\big) \in \mathcal{K}_k(a) \times
\mathcal{K}_k(b)$ via the map $(p, q) \mapsto \big(n \mapsto f(p(n), q(n))\big)$.
The product of two finite sets is finite, and the image of a finite set under a
map is finite, so $\mathcal{K}_k\big(n \mapsto f(a_n, b_n)\big)$ is finite.
$\qquad\blacksquare$

**Theorem 5.6 (Finite range).** If $a$ is $k$-automatic with $k \ge 2$, then the
range $\{a_n : n \in \mathbb{N}\}$ is finite.

*Proof.* Evaluate every kernel element at $0$: the map $b \mapsto b(0)$ sends the
finite set $\mathcal{K}_k(a)$ to a finite subset of $S$. For each $n$, the
decimation $a_{i,r}$ with $i$ large enough that $n < k^{\,i}$ and offset $r = n$
satisfies $a_{i,n}(0) = a(n)$, so $a_n$ lies in that finite image. Hence the range
is contained in a finite set. $\qquad\blacksquare$

Theorem 5.6 also serves as a negative test: a sequence that assumes infinitely
many values (for example the identity $a_n = n$) cannot be automatic in any base.

Taken together, Propositions and Theorems 5.1–5.6 say that, for a fixed base, the
$k$-automatic sequences form an algebra closed under the arithmetic operations of
the output ring and under arbitrary finite-state output codings.

---

## 6. The Thue–Morse sequence

Fix $k = 2$ and take outputs in $\mathbb{Z}/2 = \{0, 1\}$. Define the **Thue–Morse
sequence** by
$$t_n = s_2(n) \bmod 2,$$
the parity of the number of $1$-digits in the binary expansion of $n$. Its first
terms are $0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0,\dots$

**Lemma 6.1 (Automaton recurrence).** For all $n$,
$$t_{2n} = t_n, \qquad t_{2n+1} = t_n + 1 \quad (\text{in } \mathbb{Z}/2).$$

*Proof.* Appending the binary digit $0$ to $n$ produces $2n$ and does not change
the digit sum, so $s_2(2n) = s_2(n)$ and $t_{2n} = t_n$. Appending the digit $1$
produces $2n + 1$ and increases the digit sum by exactly one, so $s_2(2n+1) =
s_2(n) + 1$ and $t_{2n+1} = t_n + 1 \pmod 2$. $\qquad\blacksquare$

In kernel language, Lemma 6.1 says the two depth-$1$ children of $t$ are
$$t_{1,0} = t, \qquad t_{1,1} = t + 1,$$
where $t + 1$ denotes the pointwise complement $n \mapsto t_n + 1$ in
$\mathbb{Z}/2$.

**Theorem 6.2 (Exact kernel).** The $2$-kernel of Thue–Morse is exactly the
two-element set
$$\mathcal{K}_2(t) = \{\, t,\ t + 1 \,\}.$$

*Proof.* Both inclusions.

$(\supseteq)$ We have $t = t_{0,0} \in \mathcal{K}_2(t)$ by Lemma 3.4, and $t + 1
= t_{1,1} \in \mathcal{K}_2(t)$ by Lemma 6.1.

$(\subseteq)$ We show by induction on the depth $i$ that every decimation
$t_{i,r}$ with $r < 2^{\,i}$ equals either $t$ or $t + 1$. For $i = 0$ the only
offset is $r = 0$ and $t_{0,0} = t$. For the inductive step, a decimation of depth
$i + 1$ can be written as a depth-$1$ decimation of a depth-$i$ decimation: by the
composition law (Theorem 4.1), $t_{i+1, r}$ is $(t_{i, r'})_{1, b}$ for the
low binary digit $b \in \{0,1\}$ of $r$ and the remaining offset $r' < 2^{\,i}$.
By the inductive hypothesis $t_{i, r'} \in \{t, t+1\}$. Applying the depth-$1$
children (Lemma 6.1) to each:
$$t_{1,0} = t,\quad t_{1,1} = t+1,\quad (t+1)_{1,0} = t+1,\quad (t+1)_{1,1} = t,$$
where the last two use that adding $1$ is a pointwise operation commuting with
decimation (Lemma 5.4) and that $x \mapsto x + 1$ is an involution on
$\mathbb{Z}/2$. In every case the result lies in $\{t, t+1\}$. This closes the
induction. $\qquad\blacksquare$

**Corollary 6.3 (Automaticity of Thue–Morse).** The Thue–Morse sequence is
$2$-automatic.

*Proof.* By Theorem 6.2 its kernel has two elements, hence is finite. $\qquad
\blacksquare$

The essential mechanism is that $\mathbb{Z}/2$ makes $x \mapsto x + 1$ an
involution, so the two children $t \mapsto \{t, t+1\}$ and $t+1 \mapsto \{t+1,
t\}$ never escape the pair $\{t, t+1\}$. This is precisely the two-state automaton
whose states are "even number of ones read so far" and "odd number of ones read
so far."

---

## 7. Parity and sign

Thue–Morse admits an equivalent multiplicative description. Define the **sign
form**
$$\varepsilon_n = (-1)^{\,s_2(n)} \in \{+1, -1\}.$$

**Proposition 7.1 (Parity–sign dictionary).** For all $n$,
$$t_n = 0 \iff \varepsilon_n = +1, \qquad t_n = 1 \iff \varepsilon_n = -1.$$

*Proof.* $\varepsilon_n = (-1)^{s_2(n)}$ depends only on the parity of $s_2(n)$,
which is $t_n$. If $t_n = 0$ then $s_2(n)$ is even and $(-1)^{s_2(n)} = +1$; if
$t_n = 1$ then $s_2(n)$ is odd and $(-1)^{s_2(n)} = -1$. Both equivalences follow.
$\qquad\blacksquare$

The dictionary is more than cosmetic. The additive form places Thue–Morse in
$\mathbb{Z}/2$, where the automaton transition "flip a bit" is *addition*; the
multiplicative form places it in $\{\pm 1\}$, where the same transition is
*multiplication by $-1$*. Because Theorem 5.3 guarantees closure under output
codings, the map $x \mapsto (-1)^x$ transports every automaticity statement from
one form to the other: the sign sequence $\varepsilon$ is $2$-automatic precisely
because $t$ is, and its kernel is the coded image $\{\varepsilon,\ -\varepsilon\}$.
This lets identities phrased multiplicatively (products of signs, character-like
sums) interact with identities phrased additively (bit-parity counts).

---

## 8. Algorithms

The kernel criterion is directly computational. We summarize the two central
procedures; full implementations appear in the accompanying demonstration code.

**Algorithm A (Kernel enumeration / automaticity test).** Given a base $k$, a
sequence oracle $a$, a probing horizon $N$, and a maximum depth $D$, compute the
distinct decimations $a_{i,r}$ (for $0 \le i \le D$, $0 \le r < k^{\,i}$)
represented by their length-$N$ prefixes, deduplicate them, and report the number
of distinct decimations found. A kernel size that stabilizes as $D$ grows is
strong evidence of automaticity; the stable value is a candidate for the minimal
automaton's state count. Complexity: $O\big((\sum_{i \le D} k^{\,i}) \cdot N\big)$
sequence evaluations, i.e. $O(k^{\,D} N)$.

**Algorithm B (Automaton simulation from a stabilized kernel).** Once the kernel
is finite, label its elements as states, precompute the $k$ transition targets of
each state (the depth-$1$ children, located by prefix matching), fix the start
state as the whole sequence and the output of each state as its value at $0$, and
evaluate $a_n$ by feeding the base-$k$ digits of $n$ (most significant first)
through the transition table. Complexity: $O(\log_k n)$ per evaluation after an
$O(|\mathcal{K}| \cdot k \cdot N)$ preprocessing pass.

---

## 9. Applications

- **Deciding sequence identities.** Because automatic sequences have finite,
  computable kernels, equality of two automatic sequences over the same base is
  decidable: compare the finite transition structures. Combinatorial claims about
  Thue–Morse reduce to finite checks.
- **Signal and code design.** The Thue–Morse and Rudin–Shapiro sequences are used
  to build low-autocorrelation binary sequences and flat trigonometric
  polynomials; the closure theorems guarantee that arithmetic combinations of such
  building blocks remain finite-state, hence cheaply generable.
- **Fair division and scheduling.** The Thue–Morse ordering yields provably
  balanced turn-taking; the automaton form gives $O(\log n)$-time access to the
  $n$-th turn without storing the sequence.
- **A computability landmark.** Automatic sequences delineate the sequences a
  bounded-memory machine can produce. They form a decidable island adjacent to the
  vast undecidable ocean of general computable and non-computable sequences,
  making them a clean testbed for questions about how much memory a pattern
  demands.

---

## 10. Discussion

The development shows that a single identity — the decimation semigroup law — is
sufficient to erect the structural theory of automatic sequences. Closure under
constants, output codings, and pointwise operations, as well as finiteness of
range, all follow by exhibiting the constructed kernel as a subset or finite image
of a known finite set. Working over an arbitrary output type ensures these
finiteness statements are not vacuous consequences of a finite codomain; the
Thue–Morse specialization then demonstrates the minimal nontrivial case, a
two-state kernel, and the parity–sign dictionary connects the additive and
multiplicative incarnations.

The kernel viewpoint's main conceptual payoff is that it reframes "generated by a
finite automaton" as a *finiteness* statement about a set of subsequences, with
the automaton's states appearing as the distinct decimations. This makes the
theory characteristic-free and elementary, and it isolates exactly where the
finiteness comes from in each construction.

---

## 11. Future work

**Exact kernel size equals the minimal automaton's state count.** We conjecture
that for every base $k \ge 2$ and every $k$-automatic sequence, the number of
distinct decimations equals the number of states of the minimal deterministic
automaton generating it; hence a sequence with a kernel of size $m$ cannot be
generated by any automaton with fewer than $m$ states. Decimations are not merely
witnesses of automaticity but are in canonical bijection with the reachable states
of the syntactic automaton, so counting decimations is state minimization in
disguise. The composition law gives decimations the structure of a monoid action,
turning state minimization into orbit counting for that action — now within reach
of an elementary argument.

**Product bases: kernel finiteness is multiplicative.** We conjecture that a
sequence is simultaneously $k$-automatic and $\ell$-automatic for
multiplicatively independent $k, \ell$ only when it is eventually periodic, and in
that case both kernels have sizes bounded by the eventual period. The two
decimation monoids generate incompatible scaling symmetries unless the sequence
already has a translation symmetry, so double-automaticity forces periodicity — a
finite-kernel avatar of Cobham's theorem. Closure under pointwise operations lets
the difference sequence $n \mapsto a_{n+1} - a_n$ be analyzed inside the same
framework.

**Closure under Cauchy convolution modulo a prime.** We conjecture that if $a$
and $b$ are $p$-automatic with values in $\mathbb{Z}/p$, then the running-sum
sequence and, more strongly, the mod-$p$ Cauchy convolution $n \mapsto \sum_{i \le
n} a_i \cdot b_{n-i}$ are again $p$-automatic. Mod-$p$ convolution interacts with
base-$p$ decimation through a carry-free "digit convolution" identity, so the
convolution's kernel is a finite image of the product of the two input kernels.

---

## 12. Conclusion

We have presented a compact foundation for automatic sequences built on the
finite-kernel criterion and a single composition identity. The decimation
semigroup law yields kernel closure, which in turn yields the algebraic closure
properties of the automatic class and the finiteness of range. The Thue–Morse
sequence realizes the theory with the smallest possible nontrivial kernel,
$\{t, t+1\}$, and its parity and sign forms are shown to be two faithful costumes
for the same object. The framework is elementary, characteristic-free, and
directly computational, and it points to sharp conjectures on kernel size,
multiplicative independence of bases, and convolution closure.
