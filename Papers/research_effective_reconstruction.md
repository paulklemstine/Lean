# Effective Reconstruction: Fibre Constancy, Uniform Representative Selection, and a Complete Quantity for Effective Decoding

**Author:** Aristotle
**Date:** 2026-09-12

---

## Abstract

Let $\mathrm{obs} : S \to M$ be a *channel* mapping hidden states to observable
records, and let $f : S \to T$ be a *quantity* an observer wishes to reconstruct from
records alone. Set-theoretically, a decoder $\mathrm{dec} : M \to T$ with
$\mathrm{dec} \circ \mathrm{obs} = f$ exists if and only if $f$ is **fibre constant**
along $\mathrm{obs}$. We study the effective analogue of this equivalence for
computable channels and quantities on $\mathbb{N}$, and show that it fails in a
precisely locatable way.

We isolate the missing ingredient: a **uniform effective representative selection on
the range** ("selector"), a computable $\mathrm{sel}$ with
$\mathrm{obs}(\mathrm{sel}(\mathrm{obs}(x))) = \mathrm{obs}(x)$ for all $x$. We prove:
(i) fibre constancy always yields a *partial* computable decoder and a
*limit-computable* total decoder with the explicit modulus $s > x$, so decoders are
always $\Delta^0_2$; (ii) a computable selector yields a total computable decoder for
every computable fibre-constant quantity; (iii) the separation is strict, witnessed by
an explicit *diagonal trace channel*; (iv) a computable selector exists if and only if
the range of the channel is a computable set, while the range is always $\Sigma^0_1$;
(v) channels of finite rate are always effectively decodable, so the phenomenon is
purely infinitary.

The principal new result is a **completeness theorem**. The *canonical representative*
$r_{\mathrm{obs}}(n) = \mu m.\,[\mathrm{obs}(m) = \mathrm{obs}(n)]$ is computable
whenever $\mathrm{obs}$ is (the minimisation is unbounded but always succeeds, at
$m = n$), is fibre constant by construction, and has the property that *every* decoder
for it is a selector. Consequently we obtain a four-way equivalence: decidability of
the range, existence of a computable selector, universal effective decodability of all
computable fibre-constant quantities, and effective decodability of the single quantity
$r_{\mathrm{obs}}$ are all equivalent. This removes the injectivity hypothesis from the
previously known partial converse and exhibits a canonical hard instance: the least
halting trace of a self-halting index is not computable from the index.

Finally we prove an **effective Fano bound**. Via a finite-patching principle, a
computable decoder that errs on only finitely many records can be repaired into a
perfect one; contrapositively, on an undecodable channel every computable decoder errs
on infinitely many records and misreconstructs infinitely many states. For the diagonal
trace channel this is unconditional.

**Keywords:** effective reconstruction, fibre constancy, uniform selection, decidable
range, limit computability, diagonalisation, Fano bound, canonical representative.

---

## 1. Introduction

### 1.1 The reconstruction problem

A recurring pattern across information theory, privacy analysis, dynamical systems and
inverse problems is the following. There is a set $S$ of *states*, invisible to an
observer. There is a set $M$ of *records*, visible. A **channel**
$$\mathrm{obs} : S \longrightarrow M$$
determines what the observer sees. The observer is interested not in the state itself
but in some derived **quantity** $f : S \to T$. A **decoder** is a map
$\mathrm{dec} : M \to T$ that recovers it:
$$\mathrm{dec}(\mathrm{obs}(x)) = f(x) \qquad \text{for all } x \in S. \tag{1.1}$$

Much of the quantitative theory takes a decoder as *given* and bounds its accuracy — a
rate–distortion or Fano-style analysis, typically over finite state spaces and finite
alphabets. The prior question is one of **definability**: when does a decoder exist at
all, and when does it exist *computably*? This paper answers both, and shows that the
two answers are genuinely different.

### 1.2 The classical answer, and why it is not the whole answer

Say $f$ is **fibre constant** along $\mathrm{obs}$ if
$$\mathrm{obs}(x) = \mathrm{obs}(y) \;\Longrightarrow\; f(x) = f(y). \tag{1.2}$$
Then, as we recall in §3, a decoder exists iff $f$ is fibre constant. The construction
of the decoder reads: *given a record $m$, choose a state $x$ with
$\mathrm{obs}(x) = m$ and output $f(x)$.* Fibre constancy makes the choice immaterial.

The construction is non-effective in exactly one place: the choice. An observer who
must *compute* cannot choose; it must search, and search on an infinite state space
need not terminate — and when it does not, the observer cannot know. Our thesis is that
the whole effective content of the reconstruction problem is concentrated in this
single step, and that the step has an exact characterisation.

### 1.3 Contributions

1. **Isolation of the obstruction** (§4). The notion of a *uniform effective
   representative selection on the range* (Definition 2.3) is sufficient for effective
   decoding of all computable fibre-constant quantities, and a computably bounded
   preimage search suffices for its existence.
2. **A strict separation** (§5). An explicit *diagonal trace channel* carries a
   computable fibre-constant quantity with no total computable decoder, hence no
   computable selector and no computable preimage bound — though partial computable
   and limit-computable decoders exist.
3. **Exact characterisation of selection** (§6). For computable channels, a computable
   selector exists iff the range is a computable set; the range is always $\Sigma^0_1$.
   Finite-rate channels are always effectively decodable.
4. **A one-jump upper bound** (§7). Every computable fibre-constant quantity admits a
   limit-computable decoder with an explicit modulus, so the obstruction costs exactly
   one limit, and the separation of §5 shows this is sharp.
5. **Completeness** (§8, the main new theorem). The canonical representative is a
   computable fibre-constant quantity whose decoders are precisely the selectors,
   yielding a four-way equivalence and removing the injectivity hypothesis from the
   previously known converse.
6. **An effective Fano bound** (§9). Every computable decoder on an undecodable channel
   errs on infinitely many records and infinitely many states.

---

## 2. Definitions

Throughout, $\varphi_a$ denotes the $a$-th partial computable function under a fixed
standard numbering, and $\langle \cdot,\cdot\rangle$ a computable pairing bijection
$\mathbb{N}^2 \to \mathbb{N}$. "Computable set" means decidable; $\Sigma^0_1$ means
recursively enumerable; $\Delta^0_2$ means limit-computable.

**Definition 2.1 (Fibre constancy).** For $\mathrm{obs} : \alpha \to \beta$ and
$f : \alpha \to \gamma$, say $f$ is *fibre constant along* $\mathrm{obs}$ if
$\mathrm{obs}(x) = \mathrm{obs}(y)$ implies $f(x) = f(y)$ for all $x,y$. Equivalently,
$f$ is constant on each fibre $\mathrm{obs}^{-1}\{m\}$.

**Definition 2.2 (Decoding).** $\mathrm{dec} : \beta \to \gamma$ *decodes* $f$ through
$\mathrm{obs}$ if $\mathrm{dec}(\mathrm{obs}(x)) = f(x)$ for every $x$. Note that (1.1)
constrains $\mathrm{dec}$ only on the range of $\mathrm{obs}$; off the range its values
are unconstrained.

**Definition 2.3 (Uniform representative selection on the range).**
$\mathrm{sel} : \beta \to \alpha$ is a *selector* for $\mathrm{obs}$ if
$$\mathrm{obs}(\mathrm{sel}(\mathrm{obs}(x))) = \mathrm{obs}(x) \qquad \text{for all } x .$$
Equivalently, $\mathrm{sel}$ maps each record in the range of $\mathrm{obs}$ to some
state in the corresponding fibre. Off the range, $\mathrm{sel}$ is unconstrained.

**Definition 2.4 (Effective decodability of a channel).** A computable channel
$\mathrm{obs} : \mathbb{N} \to \mathbb{N}$ is *effectively decodable* if every
computable fibre-constant $f : \mathbb{N} \to \mathbb{N}$ admits a total computable
decoder.

**Definition 2.5 (Canonical representative).** For $\mathrm{obs} : \mathbb{N} \to \mathbb{N}$,
$$r_{\mathrm{obs}}(n) \;=\; \min\{\, m \in \mathbb{N} \;:\; \mathrm{obs}(m) = \mathrm{obs}(n)\,\}.$$
The set is nonempty (it contains $n$), so $r_{\mathrm{obs}}$ is a total function.

**Definition 2.6 (Rate).** The *rate* of a channel is the cardinality of its range. A
channel has *finite rate* if its range is finite.

---

## 3. The set-theoretic theory

**Theorem 3.1 (Definability of decoders).** Let $\alpha$ be nonempty,
$\mathrm{obs} : \alpha \to \beta$ and $f : \alpha \to \gamma$. Then a decoder for $f$
through $\mathrm{obs}$ exists if and only if $f$ is fibre constant along $\mathrm{obs}$.

*Proof sketch.* ($\Rightarrow$) If $\mathrm{dec}$ decodes $f$ and
$\mathrm{obs}(x)=\mathrm{obs}(y)$, then
$f(x)=\mathrm{dec}(\mathrm{obs}(x))=\mathrm{dec}(\mathrm{obs}(y))=f(y)$.
($\Leftarrow$) Define $\mathrm{dec}(m) = f(x_m)$ for a chosen $x_m \in \mathrm{obs}^{-1}\{m\}$
when the fibre is nonempty, and an arbitrary value otherwise. For any $x$, the fibre of
$\mathrm{obs}(x)$ is nonempty, and fibre constancy gives
$f(x_{\mathrm{obs}(x)}) = f(x)$. $\square$

Only the second direction uses choice, and it uses it exactly once per record. The
uniform, choice-free version is:

**Proposition 3.2 (Selection composes to decoding).** If $f$ is fibre constant along
$\mathrm{obs}$ and $\mathrm{sel}$ is a selector for $\mathrm{obs}$, then $f \circ \mathrm{sel}$
decodes $f$ through $\mathrm{obs}$.

*Proof.* $f(\mathrm{sel}(\mathrm{obs}(x))) = f(x)$ because
$\mathrm{obs}(\mathrm{sel}(\mathrm{obs}(x))) = \mathrm{obs}(x)$ and $f$ is constant on
that fibre. $\square$

**Proposition 3.3 (Finite baseline).** If $\alpha$ is finite (and nonempty) and $\beta$
has decidable equality, a selector for any $\mathrm{obs} : \alpha \to \beta$ exists.

*Proof.* Search the finite set $\alpha$ for a preimage; return an arbitrary element if
none exists. $\square$

Proposition 3.3 is the reason the phenomena below are invisible to the finite theory:
on a finite state space, definability is never an obstruction, and accuracy is the only
issue.

---

## 4. The effective theory: what fibre constancy does and does not buy

From here $\mathrm{obs}, f : \mathbb{N} \to \mathbb{N}$ are computable.

**Theorem 4.1 (Partial computable decoders always exist).** If $\mathrm{obs}$ and $f$
are computable and $f$ is fibre constant along $\mathrm{obs}$, there is a partial
computable $\mathrm{dec} : \mathbb{N} \rightharpoonup \mathbb{N}$ with
$f(x) \in \mathrm{dec}(\mathrm{obs}(x))$ for all $x$; i.e. $\mathrm{dec}$ is defined and
correct on the whole range of $\mathrm{obs}$.

*Proof sketch.* Put
$\mathrm{dec}(m) = f\big(\mu n.\,[\mathrm{obs}(n) = m]\big)$. The predicate
$\mathrm{obs}(n) = m$ is computable in $(m,n)$, so the minimisation is partial
computable and the composite is partial computable. If $m = \mathrm{obs}(x)$ the search
succeeds (the witness $x$ bounds the least one), returning some $n$ with
$\mathrm{obs}(n) = \mathrm{obs}(x)$; fibre constancy gives $f(n) = f(x)$. $\square$

Theorem 4.1 pinpoints the difficulty: **the effective obstruction is never computation,
it is totalisation.** The algorithm is correct wherever it converges; what one cannot
do in general is make it converge everywhere.

**Theorem 4.2 (Effective selection gives effective decoding).** If $\mathrm{obs}$
admits a computable selector $\mathrm{sel}$, then every computable fibre-constant $f$
has a total computable decoder, namely $f \circ \mathrm{sel}$.

*Proof.* Immediate from Proposition 3.2; the composite of computable functions is
computable. $\square$

**Theorem 4.3 (Computably bounded search suffices).** Suppose $\mathrm{obs}$ is
computable and there is a computable $b$ with
$$\forall x\ \exists y \le b(\mathrm{obs}(x)),\quad \mathrm{obs}(y) = \mathrm{obs}(x).$$
Then $\mathrm{obs}$ admits a computable selector.

*Proof sketch.* Define $\mathrm{sel}(t) = \mu n.\big[\mathrm{obs}(n) = t \ \vee\ b(t) \le n\big]$.
The disjunctive guard is computable and is satisfied at $n = b(t)$ at the latest, so the
search is total and $\mathrm{sel}$ is computable. If $t = \mathrm{obs}(x)$ is in the
range and the returned $n$ did not satisfy $\mathrm{obs}(n) = t$, then $b(t) \le n$;
but the hypothesis supplies a preimage $y \le b(t) \le n$, and minimality of $n$ forces
$y < n$ to falsify the guard at $y$ — contradicting $\mathrm{obs}(y) = t$. Hence
$\mathrm{obs}(n) = t$. $\square$

Theorems 4.2 and 4.3 are the positive side. §5 shows they are not vacuous constraints.

---

## 5. The diagonal trace channel: a strict separation

We construct a computable channel and a computable fibre-constant quantity admitting no
total computable decoder.

**Construction 5.1 (Diagonal trace channel).** Let $\mathrm{run}(n)$ denote the result
of the step-bounded evaluation that, on input $n = \langle a, s\rangle$, runs the $a$-th
machine on input $a$ for $s$ steps: $\mathrm{run}(n) = \mathsf{some}\ v$ if the run halts
within $s$ steps with output $v$, and $\mathsf{none}$ otherwise. Step-bounded evaluation
is computable. Define
$$\mathrm{obs}_\Delta(\langle a,s\rangle) = \begin{cases} a+1, & \mathrm{run}(\langle a,s\rangle) = \mathsf{some}\ v,\\[2pt] 0, & \text{otherwise;}\end{cases}
\qquad
f_\Delta(\langle a,s\rangle) = \begin{cases} v+1, & \mathrm{run}(\langle a,s\rangle) = \mathsf{some}\ v,\\[2pt] 0, & \text{otherwise.}\end{cases}$$
Both are computable. The record reveals *which* machine self-halted, not *what* it
computed; the shift by one keeps the blank record $0$ unambiguous.

**Lemma 5.2 (Fibre constancy of the halting value).** $f_\Delta$ is fibre constant along
$\mathrm{obs}_\Delta$.

*Proof sketch.* If both traces are non-halting, both records are $0$ and both values are
$0$. A halting and a non-halting trace have different records ($a+1 \neq 0$). If both
halt and the records agree, then $a_x = a_y$: the two traces run the *same* machine on
the *same* input, with different step bounds. Step-bounded evaluation is sound for the
underlying partial function, and a partial function takes at most one value at a point;
hence the outputs coincide, and so do the shifted values. $\square$

Thus, by Theorem 3.1 a decoder exists, and by Theorem 4.1 a partial computable one
exists. Nevertheless:

**Theorem 5.3 (Separation).** There is no total computable $\mathrm{dec}$ with
$\mathrm{dec}(\mathrm{obs}_\Delta(n)) = f_\Delta(n)$ for all $n$.

*Proof.* Suppose $\mathrm{dec}$ is such a decoder, and set $g(a) = \mathrm{dec}(a+1)$, a
total computable function. Choose an index $a_0$ for $g$; since $g$ is total, $g$ halts
on input $a_0$ with value $g(a_0)$, so by completeness of step-bounded evaluation there
is a step bound $s$ with $\mathrm{run}(\langle a_0,s\rangle) = \mathsf{some}\ g(a_0)$.
For $n = \langle a_0, s\rangle$ we then have $\mathrm{obs}_\Delta(n) = a_0+1$ and
$f_\Delta(n) = g(a_0)+1$, so correctness gives
$$g(a_0) = \mathrm{dec}(a_0+1) = \mathrm{dec}(\mathrm{obs}_\Delta(n)) = f_\Delta(n) = g(a_0)+1,$$
a contradiction. $\square$

**Corollary 5.4 (No computable selector).** $\mathrm{obs}_\Delta$ admits no computable
selector.

*Proof.* By Theorem 4.2 such a selector would produce the decoder ruled out by
Theorem 5.3. $\square$

**Corollary 5.5 (No computable preimage bound).** There is no computable $b$ with
$\forall x\,\exists y \le b(\mathrm{obs}_\Delta(x)),\ \mathrm{obs}_\Delta(y) = \mathrm{obs}_\Delta(x)$.

*Proof.* By Theorem 4.3 such a $b$ would produce the selector ruled out by
Corollary 5.4. $\square$

Corollary 5.5 says that on this channel unbounded search for a preimage is genuinely
unavoidable: no computable budget suffices.

---

## 6. Selection is decidability of the range

We now identify the obstruction with a classical invariant of the channel.

**Theorem 6.1 (A selector certifies the range).** If $\mathrm{obs}$ is computable and
admits a computable selector $\mathrm{sel}$, then $\{m : \exists n,\ \mathrm{obs}(n)=m\}$
is a computable set.

*Proof.* For all $m$: if $m = \mathrm{obs}(n)$ for some $n$, the selector property gives
$\mathrm{obs}(\mathrm{sel}(m)) = m$; conversely $\mathrm{obs}(\mathrm{sel}(m)) = m$
exhibits $\mathrm{sel}(m)$ as a preimage. So membership in the range is equivalent to
the computable condition $\mathrm{obs}(\mathrm{sel}(m)) = m$. $\square$

**Theorem 6.2 (A decidable range produces a selector).** If $\mathrm{obs}$ is computable
and its range is a computable set, then $\mathrm{obs}$ admits a computable selector.

*Proof sketch.* Guarded search: let
$$\mathrm{sel}(t) = \mu n.\big[\mathrm{obs}(n) = t \ \vee\ t \notin \operatorname{ran}(\mathrm{obs})\big].$$
Decidability of the range makes the guard computable. If $t$ is in the range the search
terminates at a preimage; if not, it terminates immediately at $n = 0$. Hence
$\mathrm{sel}$ is total computable, and on records in the range the first disjunct must
be the one satisfied. $\square$

**Theorem 6.3 (Characterisation).** For computable $\mathrm{obs}$, a computable selector
exists **iff** the range of $\mathrm{obs}$ is a computable set.

**Theorem 6.4 (The range is always enumerable).** For computable $\mathrm{obs}$, the set
$\{m : \exists n,\ \mathrm{obs}(n) = m\}$ is $\Sigma^0_1$.

*Proof sketch.* The partial function $m \mapsto \mu n.[\mathrm{obs}(n)=m]$ is partial
computable and its domain is exactly the range. $\square$

**Corollary 6.5 ($\Sigma^0_1$ always, $\Delta^0_1$ exactly when decodable).** The
emitted-record set of a computable channel is always recursively enumerable, and it is
computable precisely when the channel admits a computable selector. Undecidability of
the range is therefore the *only* possible obstruction to effective reconstruction.

**Corollary 6.6 (Undecidable range of the diagonal trace channel).** The range of
$\mathrm{obs}_\Delta$ is not computable.

*Proof.* Otherwise Theorem 6.2 would supply the selector ruled out by Corollary 5.4.
$\square$

Corollary 6.6 is a halting-problem statement derived purely from a decoding obstruction:
the set $\{0\} \cup \{a+1 : \varphi_a(a)\!\downarrow\}$ is undecidable.

**Theorem 6.7 (Finite rate implies effective decodability).** If $\mathrm{obs}$ is
computable with finite range, then every computable fibre-constant $f$ has a total
computable decoder.

*Proof sketch.* A finite set of naturals is computable (test membership in a fixed
list), so Theorem 6.2 gives a selector, and Theorem 4.2 the decoder. $\square$

Consequently a finite-alphabet, finite-state accuracy analysis loses nothing by ignoring
definability: all effective phenomena live at infinite rate.

---

## 7. The gap is exactly one jump

**Definition 7.1 (Stage-$s$ approximate decoder).** For computable $\mathrm{obs}, f$ put
$$A(m,0) = 0, \qquad A(m,k+1) = \begin{cases} f(k), & \mathrm{obs}(k) = m,\\ A(m,k), & \text{otherwise.}\end{cases}$$
In words: scan the states $0,\dots,s-1$ and keep the $f$-value of the last one whose
record is $m$. $A$ is computable as a function of $(m,s)$ by primitive recursion.

**Theorem 7.2 (Convergence with an explicit modulus).** If $f$ is fibre constant along
$\mathrm{obs}$ then for every state $x$ and every $s > x$,
$$A(\mathrm{obs}(x), s) = f(x).$$

*Proof sketch.* Induction on $s$. At $s = x+1$ the last scanned state is $k = x$ itself,
whose record matches, so $A = f(x)$. For $s = k+1 > x+1$: if $\mathrm{obs}(k) = \mathrm{obs}(x)$
then the new value is $f(k) = f(x)$ by fibre constancy; otherwise the value is inherited
from stage $k$, which equals $f(x)$ by the induction hypothesis. $\square$

**Corollary 7.3 (Limit-computable decoders always exist).** For every computable channel
and every computable fibre-constant quantity there is a computable double sequence
converging to the decoded value, with modulus "any preimage of the received record". In
particular the decoder is $\Delta^0_2$.

**Corollary 7.4 (Sharpness).** For $\mathrm{obs}_\Delta, f_\Delta$ the decoder is
limit-computable with modulus $s > x$ but not computable. Hence uniform effective
representative selection is strictly stronger than fibre constancy and strictly weaker
than any obstruction beyond one limit.

---

## 8. A complete quantity, and the four-way equivalence

Theorems 4.2 and 6.3 leave one gap. A selector implies universal effective
decodability; does universal effective decodability imply a selector? For *injective*
channels this was straightforward — take $f = \mathrm{id}$, which is (vacuously) fibre
constant, and any decoder for it is a selector — but injectivity trivialises fibre
constancy and is an unnatural hypothesis. The general case requires a *single* quantity
that is hard for the whole decoding problem. We exhibit one.

Recall $r_{\mathrm{obs}}(n) = \min\{m : \mathrm{obs}(m) = \mathrm{obs}(n)\}$ from
Definition 2.5.

**Lemma 8.1 (The representative lies in the fibre).**
$\mathrm{obs}(r_{\mathrm{obs}}(n)) = \mathrm{obs}(n)$ for all $n$.

*Proof.* Definitional: $r_{\mathrm{obs}}(n)$ is a minimiser of a nonempty set of $m$
satisfying exactly that equation. $\square$

**Lemma 8.2 (Fibre constancy).** $r_{\mathrm{obs}}$ is fibre constant along $\mathrm{obs}$.

*Proof.* If $\mathrm{obs}(x) = \mathrm{obs}(y)$ then by Lemma 8.1
$\mathrm{obs}(r_{\mathrm{obs}}(y)) = \mathrm{obs}(y) = \mathrm{obs}(x)$, so
$r_{\mathrm{obs}}(y)$ is a competitor in the minimisation defining $r_{\mathrm{obs}}(x)$,
whence $r_{\mathrm{obs}}(x) \le r_{\mathrm{obs}}(y)$. Symmetrically
$r_{\mathrm{obs}}(y) \le r_{\mathrm{obs}}(x)$. $\square$

**Theorem 8.3 (Computability of the canonical representative).** If $\mathrm{obs}$ is
computable then so is $r_{\mathrm{obs}}$.

*Proof sketch.* $r_{\mathrm{obs}}(n) = \mu m.[\mathrm{obs}(m) = \mathrm{obs}(n)]$. The
predicate is computable in $(m,n)$, so the minimisation is partial computable; and it is
*total*, because $m = n$ always satisfies it, so the search started at $0$ terminates by
$n$ at the latest. A total unbounded search defines a computable function. $\square$

The point deserves emphasis. The unbounded search that cannot be totalised in Theorem 4.1
takes a *record* as input; the search here takes a *state* as input, and the state is its
own witness. This asymmetry is precisely why $r_{\mathrm{obs}}$ is a legitimate
computable quantity while its decoder need not exist.

**Theorem 8.4 (Every decoder for the canonical representative is a selector).** If
$\mathrm{dec}$ satisfies $\mathrm{dec}(\mathrm{obs}(x)) = r_{\mathrm{obs}}(x)$ for all
$x$, then $\mathrm{dec}$ is a selector for $\mathrm{obs}$.

*Proof.* $\mathrm{obs}(\mathrm{dec}(\mathrm{obs}(x))) = \mathrm{obs}(r_{\mathrm{obs}}(x)) = \mathrm{obs}(x)$
by Lemma 8.1. $\square$

So $r_{\mathrm{obs}}$ is **complete** for effective decoding on $\mathrm{obs}$: decoding
it is as hard as decoding everything.

**Theorem 8.5 (Four-way equivalence).** Let $\mathrm{obs} : \mathbb{N} \to \mathbb{N}$ be
computable. The following are equivalent.

1. The set of emitted records $\{m : \exists n,\ \mathrm{obs}(n)=m\}$ is computable.
2. $\mathrm{obs}$ admits a computable uniform representative selection on its range.
3. Every computable fibre-constant $f : \mathbb{N} \to \mathbb{N}$ admits a total
   computable decoder through $\mathrm{obs}$.
4. The single quantity $r_{\mathrm{obs}}$ admits a total computable decoder through
   $\mathrm{obs}$.

*Proof.* $1 \Rightarrow 2$ is Theorem 6.2. $2 \Rightarrow 3$ is Theorem 4.2.
$3 \Rightarrow 4$ applies (3) to $r_{\mathrm{obs}}$, legitimate by Theorem 8.3 and
Lemma 8.2. $4 \Rightarrow 2$ is Theorem 8.4. $2 \Rightarrow 1$ is Theorem 6.1. $\square$

Theorem 8.5 removes the injectivity hypothesis from the earlier partial converse and
shows there is no intermediate behaviour: a channel either decodes everything computable
and fibre constant, or it fails already on the humblest quantity "which is the least
state that would look like this?".

**Theorem 8.6 (Canonical hard instance).** No algorithm, given the index of a machine
known to halt on itself, can produce a trace witnessing that halting. Formally, there is
no total computable $\mathrm{dec}$ with
$\mathrm{dec}(\mathrm{obs}_\Delta(n)) = r_{\mathrm{obs}_\Delta}(n)$ for all $n$.

*Proof.* Such a decoder would be a selector for $\mathrm{obs}_\Delta$ by Theorem 8.4,
contradicting Corollary 5.4. $\square$

This is exactly the failure of uniform effective representative selection in its purest
form: the *existence* of a halting trace is guaranteed by the record, but its *location*
is not computable from it.

---

## 9. An effective Fano bound

Non-existence of a perfect algorithm is compatible with an algorithm that errs at a
single point. We upgrade the negative results to quantitative ones.

**Lemma 9.1 (Single-point patching).** If $\mathrm{dec}$ is computable then so is
$y \mapsto \mathbf{if}\ y = y_0\ \mathbf{then}\ c\ \mathbf{else}\ \mathrm{dec}(y)$, for
any constants $y_0, c$.

**Lemma 9.2 (Finite patching principle).** Let $g : \mathbb{N} \to \mathbb{N}$ be an
*arbitrary* (possibly uncomputable) function, $L$ a finite list, and $\mathrm{dec}$
computable. Then
$$y \mapsto \mathbf{if}\ y \in L\ \mathbf{then}\ g(y)\ \mathbf{else}\ \mathrm{dec}(y)$$
is computable.

*Proof.* Induction on $L$ using Lemma 9.1: only the finitely many constants
$g(y)$ for $y \in L$ enter, and each can be hard-wired. $\square$

**Theorem 9.3 (Repair lemma).** Let $\mathrm{obs}, f$ be computable with $f$ fibre
constant, and let $\mathrm{dec}$ be computable and wrong only on records drawn from a
finite list $L$:
$$\mathrm{dec}(\mathrm{obs}(n)) \neq f(n) \;\Longrightarrow\; \mathrm{obs}(n) \in L .$$
Then there is a *perfect* computable decoder for $f$ through $\mathrm{obs}$.

*Proof sketch.* Let $g(m)$ be the correct decoded value on records in the range
(well defined by fibre constancy, arbitrary elsewhere) and patch $\mathrm{dec}$ by $g$ on
$L$; Lemma 9.2 keeps the result computable, and it is correct on every state: on states
whose record lies in $L$ by the patch, and elsewhere by hypothesis. $\square$

**Theorem 9.4 (Effective Fano bound).** Let $\mathrm{obs}, f$ be computable with $f$
fibre constant and with *no* total computable decoder. Then for every computable
$\mathrm{dec}$:

* the set of misdecoded records $\{m : \exists n,\ \mathrm{obs}(n)=m \wedge \mathrm{dec}(m) \neq f(n)\}$
  is infinite; and
* the set of misreconstructed states $\{n : \mathrm{dec}(\mathrm{obs}(n)) \neq f(n)\}$ is
  infinite.

*Proof.* If the record error set were finite, Theorem 9.3 (with $L$ the finite list of
bad records) would produce a perfect computable decoder, contradiction. The state error
set maps onto the record error set under $\mathrm{obs}$, and the image of a finite set is
finite, so it is infinite too. $\square$

**Corollary 9.5 (Unconditional form).** Every computable $\mathrm{dec}$ misreconstructs
infinitely many states of the diagonal trace channel: no algorithm recovers the halting
value from the halting index except on a set with infinite complement. The same holds at
the level of records, so the failure is not concentrated on a few heavily repeated
observations.

**Corollary 9.6 (Hardness of the canonical representative, quantitatively).** Every
computable attempt to compute $r_{\mathrm{obs}_\Delta}$ from the record errs on
infinitely many states.

In the finite theory a Fano-type bound gives a lower bound of (number of states) minus
(rate) on the number of misreconstructed configurations. Theorem 9.4 is its effective
counterpart, with the lower bound $\infty$, uniform over all algorithms.

---

## 10. Algorithms

The theory is constructive wherever it is positive, and the algorithms are short.

**Algorithm A (Guarded selector from a decidable range).**
Input: record $t$. If $t \notin \operatorname{ran}(\mathrm{obs})$ (decidable by
hypothesis) return $0$. Otherwise return the least $n$ with $\mathrm{obs}(n) = t$. The
guard makes the procedure total; time is unbounded but finite on every input.

**Algorithm B (Bounded selector).** Given a computable budget $b$, return the least
$n \le b(t)$ with $\mathrm{obs}(n) = t$, or $b(t)$ if none. Time $O(b(t))$ channel
evaluations. Correct on the range whenever $b$ genuinely bounds some preimage.

**Algorithm C (Canonical representative).** Input: state $n$. Return the least $m$ with
$\mathrm{obs}(m) = \mathrm{obs}(n)$. Terminates in at most $n+1$ channel evaluations,
because $m = n$ is a witness. This is a *total* computable function even on channels
with undecidable range — the crucial asymmetry of §8.

**Algorithm D (Stage-$s$ approximate decoder).** Input: record $m$, budget $s$. Scan
$k = 0,\dots,s-1$ and keep $f(k)$ for the last $k$ with $\mathrm{obs}(k) = m$; return
$0$ if none. Cost $O(s)$. Correct at $(\mathrm{obs}(x), s)$ whenever $s > x$; the
sequence stabilises but the observer cannot in general recognise stabilisation — that is
the one jump of §7.

**Algorithm E (Repair).** Given a computable decoder and a finite list of bad records
with their correct values, return the patched decoder. Cost: $O(|L|)$ comparisons plus
one call to the original decoder.

---

## 11. Discussion

### 11.1 Three notions, three characterisations

| notion | consequence | exact characterisation |
|---|---|---|
| fibre constancy of $f$ | a decoder exists; a partial computable one; a limit-computable one with modulus $s>x$ | constancy on fibres (Theorem 3.1) |
| uniform effective selection on the range | total computable decoders for *all* computable fibre-constant quantities simultaneously | decidability of the range (Theorem 6.3), equivalently effective decodability of $r_{\mathrm{obs}}$ (Theorem 8.5) |
| accuracy of a given decoder | how often reconstruction succeeds | on undecodable channels: infinitely many errors (Theorem 9.4) |

### 11.2 Information present versus information available

Fibre constancy is an information-theoretic condition: the channel does not conflate
states with different answers. The selector condition is an entirely different, effective
condition: the observer can find its way back into a fibre. The diagonal trace channel
separates them dramatically. Determinism of evaluation guarantees that the record
*determines* the halting value; diagonalisation guarantees the observer cannot compute
it. No information has been lost and none is available.

This bears directly on informal arguments about privacy and reconstruction. "Cannot be
recovered" and "can in principle be recovered" are separated here by a single decidable-
or-not invariant of the channel's output set — and by Theorem 8.5 the invariant is
all-or-nothing.

### 11.3 Why completeness matters

Theorem 8.5 converts a family of statements quantified over all quantities into a
statement about one explicit quantity, and then into a statement about a set. Such
reductions are what make a theory calibratable: a question about decoders becomes a
question about the range of a computable function, a classical object with a rich
structure theory.

### 11.4 Limits of the analysis

The results are stated for $\mathbb{N}$-valued channels and quantities; extensions to
other computable domains are routine via effective codings. The $\Delta^0_2$ upper bound
of §7 is about the *decoder*, not about uniformity in the quantity; a uniform version
(computing a decoder index from a quantity index) would need $\emptyset'$ as an oracle
and is a separate matter. Finally, nothing here addresses *resource-bounded*
reconstruction: a channel with a decidable range may still have astronomically slow
selectors, and the bounded criterion of Theorem 4.3 is the natural entry point for a
complexity-theoretic refinement.

---

## 12. Future work

**1. Degree-theoretic calibration of decoding.** *Conjecture:* for every computably
enumerable Turing degree $\mathbf{d}$ there is a computable channel whose decoding
problem — equivalently, whose canonical representative $r_{\mathrm{obs}}$ — has Turing
degree exactly $\mathbf{d}$, and the map from channels to degrees is onto the c.e.
degrees. The key insight is that the range of a computable channel is always
$\Sigma^0_1$ and, by Theorem 6.3, effective decoding is exactly $\Delta^0_1$-ness of
that range; so the decoding problem inherits the entire structure of the c.e. degrees
rather than a single halting phenomenon. The four-way equivalence reduces the conjecture
to a statement about ranges of computable functions, where Post-style constructions
(simple and hypersimple sets) are the standard tools.

**2. Modulus dichotomy for limit-computable decoders.** *Conjecture:* for a computable
channel the decoder is computable iff the convergence modulus of the stage-$s$
approximation is dominated by a computable function; and there exist channels whose
modulus is dominated by no computable function, yet whose error density — the fraction
of states below $N$ decoded incorrectly by the best budget-$N$ decoder — tends to $0$.
The approximation of §7 has the canonical modulus "any preimage", so the entire
obstruction is concentrated in the growth rate of the least-preimage function. Such a
channel would be worst-case undecodable and average-case benign.

**3. Resource-bounded selection.** Replace "computable" by "polynomial time" throughout.
Theorem 4.3 becomes a statement about polynomially bounded preimage search, and the
four-way equivalence becomes a question about the complexity of the range as a language.

**4. Partial and approximate selectors.** Weaken Definition 2.3 to a selector defined on
a dense or large subset of the range, and ask what fraction of the theory survives. The
effective Fano bound suggests the right measure is the density of records on which
selection fails.

---

## 13. Conclusion

Reconstruction splits cleanly into definability and accuracy, and definability splits
further into what the record determines and what the observer can compute. Fibre
constancy settles the first and even yields partial and limit-computable decoders;
uniform effective representative selection on the range settles the second, and equals
decidability of the emitted-record set. The canonical representative — the least state
producing the same record — is computable, fibre constant, and complete for the problem,
which collapses the theory into a four-way equivalence and pins the general obstruction
to an explicit hard instance: finding a halting trace from a halting index. Where the
obstruction bites, it bites everywhere: every algorithm errs infinitely often. Where it
does not — in particular at finite rate — one uniform recipe decodes every computable
fibre-constant quantity at once.
