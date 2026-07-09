# A Framework for Proof Refinement: Well-Foundedness, Halting, and the Limits of Local Simplification

## Abstract

Proofs are usually regarded as static objects: a fixed argument establishing a
fixed statement. In practice, however, proofs are routinely *simplified* —
lemmas are eliminated, case splits shortened, quantifiers removed — producing new
proofs of the same theorem with smaller complexity. We formalize this
observation as a general **refinement system**: a type of proof candidates for a
fixed target, a validity (soundness) predicate, and a natural-number complexity
measure. A candidate $P'$ *refines* $P$ when both are valid and $C(P') < C(P)$.

We establish three positive structural results. First, refinement is
**well-founded**: no infinite chain of strict simplifications exists. Second,
any deterministic, complexity-non-increasing simplification process **halts** in
the sense that its complexity eventually becomes constant. Third, whenever the
target is provable at all, a **complexity-minimal** valid proof exists — a
"simplest proof." We then delimit these results with two counterexamples: the
simplest proof need **not be unique** (two distinct global minima for the target
$2+2=4$), and a deterministic process can become trapped at a **local minimum**
strictly above the global one. Finally, we show that every refinement chain has
length bounded by its initial complexity, and that this bound is **tight**:
chains can be made arbitrarily long, giving rigorous content to the intuition
that the simplest proof may lie an astronomically long — but always finite —
sequence of refinements away.

**Keywords:** proof complexity, refinement, well-founded relations, local
minima, well-order, simplification, halting.

---

## 1. Introduction

A working mathematician improves proofs constantly. The second draft is cleaner
than the first; a published proof is often superseded by a slicker one; folklore
"book proofs" represent decades of collective polishing. Each such act replaces
one argument with another that proves the same statement more economically. This
paper takes that informal activity seriously and asks what can be said, in full
generality, about the *dynamics of proof simplification*.

We introduce a minimal abstract model — a **refinement system** — in which the
only structure assumed is:

1. a set of proof candidates for a fixed target proposition;
2. a way to tell which candidates are genuine (valid) proofs; and
3. a natural-number *complexity* assigned to each candidate.

Refinement is then the relation "valid, simpler, and proving the same thing." The
model is deliberately spare, so that its theorems apply regardless of what one
means by "proof" (a formal term, a tactic script, an informal write-up) or by
"complexity" (term size, line count, lemma count, or a weighted mixture such as
$C(P) = \text{length}(P) + \text{depth}(P) + \#\{\text{lemmas}\}$).

### Contributions

- **Well-foundedness** of the refinement relation (§3.1): no infinite descent.
- **Halting** of deterministic non-increasing processes (§3.2): complexity
  stabilizes.
- **Existence of a simplest proof** (§3.3): a global complexity minimum whenever
  the target is provable.
- **Non-uniqueness** of the simplest proof (§4.1): distinct global minima.
- **Local minima that are not global** (§4.2): greedy processes can get stuck.
- **Length bound and its tightness** (§5): every chain is finite with length
  $\le$ initial complexity, but chains can be arbitrarily long.

The unifying technical engine is the well-foundedness of the strict order $<$ on
the natural numbers $\mathbb{N}$, pulled back along the complexity measure.

---

## 2. The model

### 2.1 Refinement systems

**Definition 2.1 (Refinement system).** A *refinement system* for a fixed target
proposition consists of:

- a type $\mathcal{C}$ of **candidates** (concrete proof attempts for the
  target);
- a **validity predicate** $\mathrm{valid} : \mathcal{C} \to \mathrm{Prop}$,
  where $\mathrm{valid}(c)$ asserts that $c$ genuinely certifies the target
  (soundness); and
- a **complexity measure** $C : \mathcal{C} \to \mathbb{N}$.

The choice of $\mathbb{N}$ as the codomain of $C$ is not incidental: it is
precisely the well-ordering of $\mathbb{N}$ that yields every result below.

**Definition 2.2 (Refinement).** For candidates $P', P \in \mathcal{C}$, we say
$P'$ **refines** $P$, written $P' \succ P$, when
$$
\mathrm{valid}(P') \;\wedge\; \mathrm{valid}(P) \;\wedge\; C(P') < C(P).
$$
That is, $P'$ and $P$ are both valid proofs of the target and $P'$ is strictly
simpler.

**Definition 2.3 (Global minimum / simplest proof).** A candidate $c_{\min}$ is a
*globally minimal* (simplest) proof if $\mathrm{valid}(c_{\min})$ and, for every
valid candidate $c'$, $C(c_{\min}) \le C(c')$.

**Definition 2.4 (Local minimum of a process).** Given a step relation
$\rightsquigarrow$ describing the moves a simplification process may make, a
candidate $p$ is a *local minimum* if there is no $p'$ with $p \rightsquigarrow
p'$.

---

## 3. Positive results

### 3.1 Refinement is well-founded

**Theorem 3.1 (Well-foundedness).** In any refinement system, the relation
$\succ$ is well-founded. Equivalently, there is no infinite sequence
$P_0 \succ P_1 \succ P_2 \succ \cdots$.

*Proof sketch.* Refinement is a sub-relation of the relation "$C(P') < C(P)$,"
i.e. the pullback (inverse image) of the strict order $<$ on $\mathbb{N}$ along
the map $C$. The order $<$ on $\mathbb{N}$ is well-founded, and the inverse image
of a well-founded relation under any map is well-founded. Any sub-relation of a
well-founded relation is well-founded. Hence $\succ$ is well-founded. Concretely,
an infinite descending chain of refinements would induce an infinite strictly
decreasing sequence of natural numbers $C(P_0) > C(P_1) > \cdots$, which is
impossible. $\qquad\blacksquare$

### 3.2 Deterministic non-increasing processes halt

**Theorem 3.2 (Halting).** Let $\text{step} : \mathcal{C} \to \mathcal{C}$ be a
deterministic rule with $C(\text{step}(c)) \le C(c)$ for all $c$ (it never
increases complexity). Then for every starting candidate $c_0$ there exists an
index $N$ such that for all $n \ge N$,
$$
C\big(\text{step}^{[n]}(c_0)\big) = C\big(\text{step}^{[N]}(c_0)\big),
$$
where $\text{step}^{[n]}$ denotes $n$-fold iteration. That is, the complexity is
eventually constant.

*Proof sketch.* Define $a_n = C(\text{step}^{[n]}(c_0))$. Because $\text{step}$
never increases complexity, $a_{n+1} \le a_n$, so $(a_n)$ is antitone (a
non-increasing sequence of natural numbers). Its range is a non-empty subset of
$\mathbb{N}$ bounded above by $a_0$, hence finite and possessing a least element
$a_N$ attained at some index $N$. For $n \ge N$ monotonicity gives $a_n \le a_N$,
while minimality gives $a_N \le a_n$; therefore $a_n = a_N$. $\qquad\blacksquare$

Note the hypothesis is only that complexity does not *increase*; the process need
not strictly decrease it at every step, and indeed a process that has reached a
fixed point simply repeats it.

### 3.3 A simplest proof always exists

**Theorem 3.3 (Existence of a simplest proof).** If the target has at least one
valid candidate, then it has a globally minimal valid candidate: a $c_{\min}$
with $\mathrm{valid}(c_{\min})$ and $C(c_{\min}) \le C(c')$ for every valid $c'$.

*Proof sketch.* Consider the set $V = \{ c : \mathrm{valid}(c) \}$, which is
non-empty by hypothesis. Since $\succ$ is well-founded (Theorem 3.1), $V$ has a
$\succ$-minimal element $c_{\min}$: a valid candidate admitting no valid
refinement. Suppose, for contradiction, $c_{\min}$ were not a global minimum.
Then some valid $c'$ has $C(c') < C(c_{\min})$, whence $c' \succ c_{\min}$,
contradicting minimality of $c_{\min}$ in $V$. Therefore $C(c_{\min}) \le C(c')$
for all valid $c'$. $\qquad\blacksquare$

Theorem 3.3 makes precise the idea of a "limit" of the refinement process: the
simplest proof exists as an actual object, and the complexity landscape has a
genuine floor.

---

## 4. The limits of simplification

The results of §3 are entirely positive. It is tempting to infer that diligent,
step-by-step simplification will deliver the simplest proof, and that this proof
is canonical. Both inferences are false. This section supplies explicit
counterexamples.

### 4.1 The simplest proof need not be unique

Take the (true) target $2 + 2 = 4$. Because the target holds, every candidate is
valid, so validity imposes no constraint and the entire content is in the
complexity assignment.

Consider three candidates:

- $r$ ("reflexivity/computation"), with $C(r) = 1$;
- $n$ ("normalization"), with $C(n) = 1$;
- $v$ ("verbose"), with $C(v) = 3$.

**Theorem 4.1 (Two distinct global minima).** The candidates $r$ and $n$ are
distinct, both valid, of equal complexity, and both globally minimal.

*Proof sketch.* Distinctness is by construction. Both are valid because the
target $2+2=4$ is true. Both have complexity $1$. For global minimality, a finite
case check over the three candidates shows $1 \le C(c')$ for every candidate
$c'$ (the complexities are $1, 1, 3$), so no candidate is simpler than complexity
$1$. Hence $r$ and $n$ are two distinct simplest proofs. $\qquad\blacksquare$

Thus "the simplest proof" is properly "*a* simplest proof": minimality is a
property that may be shared. Any hope of a unique canonical proof, selected by
complexity alone, is unfounded.

### 4.2 A local minimum that is not global

We now exhibit a deterministic simplification process that halts (as Theorem 3.2
guarantees) but at a suboptimal point.

Let the candidates be $s, m, \ell, g$ ("start, mid, local, global") with
complexities
$$
C(s) = 5,\quad C(m) = 4,\quad C(\ell) = 3,\quad C(g) = 2,
$$
and let every candidate be valid. Define the deterministic successor rule
$$
\text{next}(s) = m,\quad \text{next}(m) = \ell,\quad \text{next}(\ell) = \ell,\quad \text{next}(g) = g,
$$
and let the process's *allowed steps* be $p \rightsquigarrow p'$ iff
$p' = \text{next}(p)$ **and** $C(p') < C(p)$ (a move is taken only when it
strictly simplifies).

**Proposition 4.2 (The process descends).** $s \rightsquigarrow m$ and
$m \rightsquigarrow \ell$.

*Proof sketch.* $\text{next}(s) = m$ with $4 < 5$, and $\text{next}(m) = \ell$
with $3 < 4$; both are decidable numeric checks. $\qquad\blacksquare$

**Proposition 4.3 ($\ell$ is a local minimum).** There is no $p'$ with
$\ell \rightsquigarrow p'$.

*Proof sketch.* The only candidate the rule can produce from $\ell$ is
$\text{next}(\ell) = \ell$, and the step requires $C(\ell) < C(\ell)$, i.e.
$3 < 3$, which is false. Hence no allowed step exists. $\qquad\blacksquare$

**Proposition 4.4 ($\ell$ is not a global minimum).** The candidate $g$ is valid
and refines $\ell$ in the sense of Definition 2.2, since $g$ and $\ell$ are valid
and $C(g) = 2 < 3 = C(\ell)$.

*Proof sketch.* Validity is immediate (all candidates are valid), and $2 < 3$ is
a numeric check. $\qquad\blacksquare$

**Theorem 4.5 (Trapped process).** Starting from $s$, the process descends
$s \rightsquigarrow m \rightsquigarrow \ell$ and then halts at $\ell$
(complexity $3$), even though a strictly simpler valid candidate $g$ (complexity
$2$) exists. Consequently, well-foundedness, halting, and existence of a global
minimum do **not** imply that a deterministic process reaches the global optimum.

*Proof sketch.* Combine Propositions 4.2–4.4. The process reaches $\ell$ and can
take no further step (4.3), yet $g$ is a strictly simpler valid proof (4.4). The
optimum $g$ is unreachable because it is not in the image of the process's step
rule from $\ell$. $\qquad\blacksquare$

This is the central cautionary result. The abstract refinement relation
$\succ$ still connects $\ell$ to $g$; what fails is that a *particular
deterministic strategy* need not follow that connection. Greedy local
simplification and global optimality are genuinely different.

---

## 5. How long can simplification take?

Well-foundedness (Theorem 3.1) tells us every refinement chain is finite, but
says nothing about *how* finite. We now quantify.

**Theorem 5.1 (Length bound).** Any strict refinement chain
$P_0 \succ P_1 \succ \cdots \succ P_k$ satisfies $k \le C(P_0)$.

*Proof sketch.* Each step strictly decreases a natural-number complexity, so
$C(P_0) > C(P_1) > \cdots > C(P_k) \ge 0$. A strictly decreasing chain of
natural numbers starting at $C(P_0)$ has at most $C(P_0)$ steps. $\qquad
\blacksquare$

**Theorem 5.2 (Tightness / arbitrarily long chains).** For every $m \in
\mathbb{N}$ there is a refinement system and a genuine refinement chain of
exactly $m$ steps. Hence there is no uniform bound on chain length valid across
all targets.

*Proof sketch.* Fix $m$. Take candidates $0, 1, \dots, m$ (all valid, e.g. for a
true target), and set $C(i) = i$. Then $m \succ m-1 \succ \cdots \succ 1 \succ 0$
is a strict refinement chain of length exactly $m$, since each step decreases
complexity by one and all candidates are valid. As $m$ ranges over $\mathbb{N}$,
chain lengths are unbounded. $\qquad\blacksquare$

Together, Theorems 5.1 and 5.2 give a precise sense to the folklore claim that
the simplest proof of a theorem might be reached only after an astronomically
long sequence of refinements (say $10^{100}$): the number of refinement steps is
always **finite** but subject to **no universal bound**. The road down to the
simplest proof is guaranteed to end, yet may be arbitrarily long.

---

## 6. Algorithms

The theory suggests two natural algorithms, both grounded in the results above.

**Algorithm A (Iterative simplification to a local minimum).** Given a
non-increasing deterministic step rule and a start candidate, iterate until the
complexity stops changing. Theorem 3.2 guarantees termination; the result is a
local minimum of the process, which by §4.2 need not be global.

**Algorithm B (Exhaustive search for the global minimum).** Over a finite (or
finitely enumerable) candidate space, filter to valid candidates and select one
of minimum complexity. Theorem 3.3 guarantees such a candidate exists; Theorem
4.1 warns that the minimizer may not be unique, so any tie-break is a convention.

The contrast between A and B is exactly the contrast between local and global
optimization. A is cheap and always halts but can be trapped; B is correct but
requires surveying the whole candidate space.

---

## 7. Applications and connections

- **Automated proof simplification.** Tactic-level or term-level simplifiers are
  instances of Algorithm A. The theory explains both why they always terminate
  (Theorem 3.2) and why they may leave a strictly simpler proof on the table
  (Theorem 4.5). To recover global optimality one must either enlarge the step
  relation or switch to a search strategy (Algorithm B).

- **Optimization in general.** The local-versus-global gap here is the same
  phenomenon that appears in gradient descent on non-convex landscapes, energy
  minimization in physics, and lossless compression. "Downhill is easy;
  the bottom is hard" is a structural fact, not an artifact of any particular
  domain.

- **The book-proof heuristic.** The existence of a simplest proof (Theorem 3.3)
  formalizes the aspiration behind "proofs from the book," while non-uniqueness
  (Theorem 4.1) tempers it: there may be several equally minimal book proofs.

---

## 8. Discussion

The framework isolates exactly which optimistic intuitions about proof
simplification are correct and which are not. Correct: simplification terminates,
a simplest proof exists, automated polishing stabilizes. Incorrect: that greedy
polishing reaches the simplest proof, and that the simplest proof is unique.

The single mathematical fact responsible for the positive results is the
well-ordering of $\mathbb{N}$ under $<$. This suggests the theory is robust to
generalization: replacing $\mathbb{N}$ by any well-founded order (e.g. a
lexicographic product $\text{length} \times \text{depth} \times \#\text{lemmas}$,
or the ordinals) preserves well-foundedness and hence the existence and
termination results, while the counterexamples of §4 are already about the gap
between a relation and a chosen sub-process, independent of the codomain of $C$.

---

## 9. Future directions

We formalized a proof-refinement system for a fixed target proposition $T$: an
abstract type of candidate proofs, a natural-valued complexity $C$, a validity
predicate, and a soundness guarantee. Refinement is $C(P') < C(P)$ between valid
candidates. We proved: refinement is well-founded (no infinite strict
simplification); finite chains are length-bounded by the initial complexity, and
this bound is tight (for every $m$ there is a genuine refinement chain of exactly
$m$ steps — finite, but with no uniform length bound); every non-increasing
refinement process halts; a simplest proof exists; but the halting limit need not
be simplest, with a concrete $\sqrt 2$-flavored counterexample. Building on this:

1. **Syntactic complexity.** Replace the abstract $C$ with a genuine measure on
   proof terms/tactic scripts ($\text{length} + \text{depth} + \#\text{lemmas}$)
   and re-derive the theorems for that concrete $C$.

2. **Steepest-descent refinement.** Model a refinement *strategy* as a function
   choosing the next candidate, and characterize which strategies do reach the
   global minimum (e.g. always pick a strict refinement when one exists). The
   present counterexample shows arbitrary non-increasing strategies fail.

3. **Multi-objective complexity.** Take $C$ valued in a well-order other than
   $\mathbb{N}$ (lexicographic $\text{length} \times \text{depth} \times
   \#\text{lemmas}$, or ordinals) and check which results survive;
   well-foundedness generalizes to any well-founded order.

4. **Uncomputability of the optimum.** Formalize that "the Kolmogorov-minimal
   proof" is not computable, sharpening why local refinement cannot in general
   attain it.

5. **Quantitative arbitrariness.** The tightness of the length bound is
   established: for every $m$ there is a system with a strict refinement chain of
   exactly $m$ steps, matching the $10^{100}$ remark. A natural extension is to
   exhibit chains whose length as a function of the theorem's statement size
   grows faster than any computable function, sharpening the "arbitrarily long"
   slogan quantitatively.

---

## 10. Conclusion

A proof, viewed through the lens of complexity, is not a static artifact but a
point in a landscape connected by refinement. That landscape is well-founded, so
descent always terminates; it has a floor, so a simplest proof always exists; and
non-increasing processes always come to rest. But its minima can be plural, and
local descent can halt above the true bottom. The simplest proof of a theorem is
guaranteed to exist and to be finitely far away — yet finding it, in general,
demands more than diligent step-by-step improvement.
