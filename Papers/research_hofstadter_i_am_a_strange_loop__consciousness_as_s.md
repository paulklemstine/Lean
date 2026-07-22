# Inspectable Self-Models, Reflective Depth, and First-Return Strange Loops

## Abstract

We develop a minimal mathematical theory of self-reference in state-based systems. An inspectable self-model is defined by an encoding map and an inspection map whose composite is the identity. This retraction law separates operational self-representation from broader claims about consciousness. We prove that explicit quotation and evaluation induce an inspectable self-model; that a one-step reconstruction law iterates to every finite reflective depth; and that reflective-depth certificates are downward closed. We separately formalize strange-loop recurrence through first-return times and prove that a return at three transitions, together with exclusion of returns at one and two, has minimum positive length three. A three-state rotation realizes the hypotheses. Finally, we analyze semantic self-representation. A point-surjective map from codes to code-indexed observations forces every transformation of observations to have a fixed point, while diagonalization shows that no system can represent every predicate on its own codes. These positive and negative results clarify three distinctions: universality does not imply introspection without quotation, undecidability is a limit on semantic access rather than a definition of awareness, and reflective depth is independent of dynamical period unless compatibility axioms connect them.

## 1. Introduction

Self-reference appears in programming languages, reflective interpreters, multi-agent reasoning, learned world models, and philosophical accounts of consciousness. The intuitive picture is a loop in which a system contains a representation of itself, inspects that representation, and perhaps represents the act of inspection again. Such descriptions combine several mathematically different phenomena. A state may be encoded and recovered; an operation may be iterated; a dynamical trajectory may return to its starting point; or a family of codes may represent observations about those same codes. Treating these as one notion obscures both valid theorems and unavoidable limitations.

This paper separates the phenomena into three structures. First, **introspection** is modeled by a split encoding: encoding followed by inspection recovers the original state. Second, **reflective depth** counts equal iterations of encoding and inspection. Third, **loop length** is the first-return period of a dynamical orbit. The first two are algebraic properties of an interface, whereas the third is a property of a transition rule and an initial state.

A fourth structure concerns semantic completeness. If codes represent all code-indexed observations, diagonal evaluation creates fixed points for every transformation of observations. For truth-valued observations, negation has no fixed point, so unrestricted predicate representation is impossible. This makes precise a boundary that is sometimes described too loosely as “the halting problem is self-awareness.” The mathematical conclusion is different: useful self-representation is possible under a retraction law, but total semantic self-knowledge is blocked by diagonalization.

The theory is intentionally neutral concerning phenomenal consciousness. We call a system structurally introspective when it possesses an inspectable self-model; the terminology does not equate that property with subjective experience. The contribution is a precise framework in which claims about self-models, nested reflection, three-level loops, and diagonal barriers can be stated and assessed.

## 2. State spaces and inspectable self-models

Let $S$ be a set, interpreted as the state space of a system. No finiteness, topology, probability distribution, or computational presentation is initially required.

**Definition 2.1 (Inspectable self-model).** An inspectable self-model on $S$ is a pair of maps

$$
e:S\to S,\qquad i:S\to S,
$$

called encoding and inspection, satisfying

$$
i(e(s))=s \qquad \text{for every } s\in S.
$$

Equivalently, $i\circ e=\operatorname{id}_S$, so $i$ is a left inverse of $e$. A state space is **structurally introspective** if it admits at least one inspectable self-model.

The use of a common state space permits encoded states to remain internal states of the system. The law has immediate consequences. The encoding map is injective: if $e(s)=e(s')$, applying $i$ gives $s=s'$. The inspection map is surjective: every $s$ is the inspection of $e(s)$. Neither map need be bijective, because the state space may contain malformed or noncanonical encodings outside the image of $e$.

The identity maps provide a degenerate self-model on every set. In applications, nontriviality must therefore come from additional requirements: an operational interpretation of encoded states, resource constraints, syntactic separation, or compatibility with dynamics. The retraction law isolates reconstruction and should be combined with such domain-specific conditions when stronger claims are intended.

### 2.1 Quotation and evaluation

Self-simulation is often attributed to universal evaluators, but evaluation alone does not produce the code of a state. We therefore make quotation explicit.

**Definition 2.2 (Quoted evaluator).** A quoted evaluator on $S$ consists of maps

$$
q:S\to S,\qquad v:S\to S,
$$

such that

$$
v(q(s))=s \qquad \text{for every } s\in S.
$$

Here $q$ turns a state into an internal code and $v$ evaluates such a code. The equation is a self-simulation or reconstruction law on quoted states.

**Theorem 2.3 (Quoted Evaluation Theorem).** Every quoted evaluator induces an inspectable self-model. Consequently, every state system carrying quotation and evaluation with $v\circ q=\operatorname{id}_S$ is structurally introspective.

**Proof sketch.** Set $e=q$ and $i=v$. The quoted-evaluation law is exactly the left-inverse law required of an inspectable self-model. $\square$

The theorem is elementary because the substantive hypothesis has been stated explicitly. Its conceptual role is to prevent an invalid inference from universality to introspection. A universal evaluation mechanism may process every code it receives while lacking any quotation map that converts its own states into suitable codes. Quotation is not supplied by evaluation alone.

## 3. Iterated reflection

For a map $g:S\to S$, define $g^0=\operatorname{id}_S$ and $g^{n+1}=g\circ g^n$. Thus $g^n$ is the $n$-fold iterate of $g$.

**Definition 3.1 (Certified reflective depth).** Given an inspectable self-model $(e,i)$, the system has certified reflective depth at least $n$ when

$$
i^n(e^n(s))=s \qquad \text{for every } s\in S.
$$

This definition describes $n$ nested encodings followed by $n$ nested inspections. It measures iterability of an interface rather than memory usage, logical expressiveness, or subjective sophistication.

**Lemma 3.2 (Iterated Left-Inverse Lemma).** Let $e,i:S\to S$ satisfy $i\circ e=\operatorname{id}_S$. Then, for every $n\in\mathbb N$,

$$
i^n\circ e^n=\operatorname{id}_S.
$$

**Proof sketch.** Induct on $n$. For $n=0$, both iterates are identities. Assume the result at $n$. Associativity of composition and the one-step law allow the next outer inspection to cancel the next outer encoding. Equivalently, the standard fact that left inverses remain left inverses under equal iteration gives the result directly. $\square$

**Theorem 3.3 (Unbounded Finite Reflective Depth).** Every inspectable self-model has certified reflective depth at least $n$ for every finite $n$.

**Proof sketch.** Apply the Iterated Left-Inverse Lemma to the encoding and inspection maps of the self-model. $\square$

The word “finite” is essential. The theorem quantifies over every natural number but does not construct an infinite stack or assign meaning to a limit of nested representations. It establishes a family of exact finite reconstruction equations.

**Theorem 3.4 (Downward Closure of Reflective Depth).** Suppose $e,i:S\to S$ satisfy $i\circ e=\operatorname{id}_S$. If $m\le n$, then the interface has certified reflective depth at least $m$. In particular, any certificate at depth $n$ is accompanied by certificates at all smaller depths.

**Proof sketch.** The one-step left-inverse law and Lemma 3.2 establish the reconstruction equation independently at every $m$. The inequality $m\le n$ places $m$ below the announced depth but is not otherwise needed under the stronger one-step assumption. $\square$

This formulation is useful as a baseline. In approximate, resource-bounded, or partially defined systems, a depth-$n$ certificate may carry information not recoverable from a global one-step law. In the exact total setting considered here, downward closure follows from the stronger fact that all finite depths are certified.

### 3.1 An algorithm for nested inspection

The reconstruction theorem has a direct operational procedure. Given a state $s$, a depth $n$, and maps $e$ and $i$, apply $e$ exactly $n$ times, then apply $i$ exactly $n$ times. The output equals $s$ whenever $i\circ e=\operatorname{id}_S$.

If each map application costs $O(1)$, the procedure uses $2n$ applications and runs in $O(n)$ time with $O(1)$ auxiliary storage when iteration is performed in place. If intermediate states are retained for auditing, storage becomes $O(n)$. The mathematics guarantees correctness but not efficient representation: encoded states may grow, and the unit-cost assumption can fail in concrete programming systems.

## 4. Dynamical returns and three-level loops

Reflective nesting should not be confused with periodic dynamics. Let $X$ be a set, let $f:X\to X$ be a transition rule, and fix $x\in X$.

**Definition 4.1 (Return time).** The orbit of $x$ returns at time $n\in\mathbb N$ if

$$
f^n(x)=x.
$$

A positive integer $p$ is the first-return period of $x$ when $f^p(x)=x$ and $f^k(x)\ne x$ for all integers $k$ with $0<k<p$.

**Definition 4.2 (Exact three-level loop).** The pair $(f,x)$ forms an exact three-level loop when

$$
f^3(x)=x,\qquad f(x)\ne x,\qquad f^2(x)\ne x.
$$

The terminology “level” is justified only when the orbit states have an external semantic interpretation as levels of representation. Formally, the definition is simply an exact period condition.

**Theorem 4.3 (Minimum Three-Step Loop Theorem).** If $(f,x)$ is an exact three-level loop and $k$ is a positive return time satisfying $k\le 3$, then $k=3$.

**Proof sketch.** Since $k$ is a positive integer no larger than $3$, it is one of $1$, $2$, and $3$. The first two cases contradict the defining nonreturn conditions. Therefore $k=3$. $\square$

The theorem is conditional: it does not say every self-model has period three, or that period three is necessary for consciousness. It identifies the minimum only after shorter returns have explicitly been excluded.

**Example 4.4 (Canonical three-state rotation).** Let $X=\{0,1,2\}$ and define

$$
f(j)=j+1\pmod 3.
$$

Starting at $0$, one obtains

$$
0\longmapsto 1\longmapsto 2\longmapsto 0.
$$

Thus $f^3(0)=0$, while $f(0)=1\ne0$ and $f^2(0)=2\ne0$. The rotation is an exact three-level loop, and its first positive return time is $3$.

For comparison, the identity map has period $1$ at every state. A transposition of two states has period $2$ at each moved state. A shift on the integers, $f(z)=z+1$, has no periodic state. These examples expose the boundary of the three-step claim.

### 4.1 Independence of depth and period

Reflective depth concerns a pair $(e,i)$ and the equations $i^n e^n=\operatorname{id}$. Period concerns a pair $(f,x)$ and the equation $f^p(x)=x$. Without axioms linking $f$ to $e$ and $i$, the invariants are independent in meaning.

For example, a set may carry the identity self-model, which has every finite reflective depth, while simultaneously carrying shift dynamics with no periodic points. Conversely, a three-element set may carry a three-cycle regardless of whether its chosen encode–inspect interface captures any nontrivial semantic modeling. A correlation between “strangeness” and “degree of consciousness” therefore cannot be inferred from period and reflective depth alone. A quantitative theory would need compatibility conditions specifying how orbit states correspond to semantic levels and how transitions implement encoding or inspection.

## 5. Point-surjective representation and fixed observations

We now turn from state reconstruction to semantic representation. Let $C$ be a set of codes and $O$ a set of observations. A map

$$
r:C\to(C\to O)
$$

assigns to each code $c$ an observation-valued function $r(c)$. We say that $r$ is **point-surjective** when every function $g:C\to O$ is represented: for each $g$, there exists $a\in C$ such that $r(a)=g$.

**Theorem 5.1 (Self-Representation Fixed-Point Theorem).** Suppose $r:C\to(C\to O)$ is point-surjective. Then every transformation $t:O\to O$ has a fixed point. Explicitly, there exists $o\in O$ such that

$$
t(o)=o.
$$

**Proof sketch.** Define a diagonal function $d:C\to O$ by

$$
d(c)=t(r(c)(c)).
$$

Point-surjectivity supplies $a\in C$ with $r(a)=d$. Set $o=r(a)(a)$. Then

$$
o=r(a)(a)=d(a)=t(r(a)(a))=t(o).
$$

Hence $o$ is fixed by $t$. $\square$

The hypothesis is exceptionally strong: it requires representation of every observation-valued function on the code space. The conclusion explains why such completeness is often impossible. To refute point-surjectivity, it suffices to exhibit one endomorphism of $O$ without a fixed point.

A finite counting argument also suggests the strength of the assumption. If $C$ and $O$ are finite with $|C|=c$ and $|O|=o$, then there are $o^c$ functions from $C$ to $O$ but only $c$ codes. Surjectivity requires $c\ge o^c$, which fails for every positive finite $c$ when $o\ge2$. The diagonal theorem is more general: it does not rely on finiteness or cardinal arithmetic.

## 6. The impossibility of total predicate self-representation

Let observations be propositions, equivalently Boolean truth values for the present argument. A predicate on codes is a function $P:C\to\{\bot,\top\}$.

**Theorem 6.1 (Predicate Representation Impossibility Theorem).** For every code set $C$, there is no representation map

$$
r:C\to\bigl(C\to\{\bot,\top\}\bigr)
$$

that represents every predicate on $C$.

**Proof sketch by fixed points.** If such a point-surjective map existed, Theorem 5.1 applied to Boolean negation would yield a truth value $b$ satisfying $\neg b=b$. No Boolean value has this property, so the representation cannot exist. $\square$

**Direct diagonal proof sketch.** Assume $r$ represents every predicate. Define

$$
D(c)=\neg r(c)(c).
$$

By total representability, there is $a$ such that $r(a)=D$. Evaluation at $a$ gives

$$
r(a)(a)=D(a)=\neg r(a)(a),
$$

which is impossible. $\square$

This result is a semantic boundary, not a denial of useful reflection. A system may represent a restricted family of predicates, may evaluate quoted programs on a partial domain, or may reconstruct states while lacking total access to all extensional truths about them. Indeed, the positive reconstruction theorems and the negative predicate theorem address different representational strengths. A retraction only requires recovery of quoted states. Point-surjectivity requires codes for every function or predicate on codes.

The distinction is especially important in discussions of the halting problem. Self-simulation and self-quotation can be available even though termination is undecidable. Undecidability does not constitute introspection; it limits what any total decision mechanism can infer. Calling the halting obstruction “self-awareness” conflates an impossibility theorem with a structural capacity.

## 7. Computational demonstrations

The finite examples admit simple algorithms that expose the theory numerically.

### 7.1 Verifying a retraction on a finite state space

For finite $S$, evaluate $i(e(s))$ for every $s\in S$. The interface is an inspectable self-model exactly when every comparison equals $s$. With array-based functions and $N=|S|$, this exhaustive test takes $O(N)$ time and $O(1)$ auxiliary space, excluding storage of the maps.

One can then test depth $n$ by computing $e^n(s)$ followed by $i^n$ for every state. Direct execution costs $O(Nn)$. The theorem makes repeated depth testing mathematically redundant once the one-step law has been established, although testing remains useful for detecting implementation errors.

### 7.2 Finding a first return

Given $f$, $x$, and a search bound $B$, iterate $f$ from $x$ and report the first $k\in\{1,\dots,B\}$ for which the state equals $x$. This takes $O(B)$ evaluations and $O(1)$ auxiliary space. For the three-state rotation it reports $3$. More general cycle detection can use a visited-state table in $O(N)$ space or Floyd’s tortoise-and-hare method in $O(1)$ space, though locating the return specifically to the initial state remains straightforward.

### 7.3 Constructing a missing diagonal predicate

For a finite table whose rows are represented Boolean predicates, create a new predicate by negating the diagonal entry in each row. The resulting vector differs from row $j$ at coordinate $j$, so it cannot equal any represented row. For $N$ codes, construction takes $O(N)$ time and $O(N)$ output space. This is a finite, visual form of Theorem 6.1.

## 8. Applications and interpretation

### 8.1 Reflective programming systems

Programming languages with quotation and evaluation naturally suggest the retraction law, but real evaluators are often partial, typed, staged, or resource bounded. The framework identifies the correct positive target: on a syntactically specified domain, evaluating a quotation should recover the original program state or denotation. It also warns against demanding an evaluator that decides every semantic predicate, which diagonalization forbids.

### 8.2 Machine learning and agent self-models

An artificial agent may maintain an internal summary of its memory, policy, confidence, or predicted future behavior. To qualify as an exact inspectable self-model in the present sense, encoding followed by inspection must reconstruct the modeled state. Practical learned models will instead be approximate. This suggests replacing equality by a metric error bound and studying how errors accumulate under iteration. Lipschitz constants of encoding and inspection would then control whether nested reflection is stable, grows geometrically, or contracts.

The framework also separates self-model quality from recurrent network dynamics. A recurrent architecture may have cycles without an accurate model of itself; an accurate self-model may exist in a system whose operational trajectory is aperiodic. Empirical studies should measure these axes separately.

### 8.3 Multi-agent and hierarchical reasoning

Statements such as “agent $A$ models agent $B$ modeling agent $A$” involve heterogeneous state spaces, unlike the homogeneous maps used here. The natural extension is a cycle of encoding and inspection maps between several spaces, together with coherence laws ensuring that a trip around the cycle reconstructs the starting information. The three-state rotation is a minimal recurrence witness, not yet a typed theory of nested beliefs.

### 8.4 Philosophy of consciousness

The structural predicate studied here is intentionally weaker than consciousness in the phenomenal sense. The theorems support the claim that lossless, inspectable self-representation can be mathematically characterized. They do not show that such representation is sufficient for experience, that universal computers are conscious, or that first-return period measures degree of consciousness.

The conditional three-step result should likewise be read precisely. If a model declares three distinct semantic levels, realizes them as successive orbit states, and excludes earlier returns, then its minimum loop length is three. The mathematics does not independently establish the philosophical premise that three is a threshold for awareness.

## 9. Limitations

Several limitations are built into the model. First, total maps suppress nontermination and runtime failure. Second, exact equality ignores noise, approximation, and lossy representation. Third, the shared state space hides type distinctions between systems, models, and metamodels. Fourth, the identity self-model shows that the bare existence of a retraction is too weak to measure sophistication. Fifth, point-surjectivity is far stronger than the restricted representability found in practical systems.

These limitations are productive: each points to a sharper next theory. Partial maps can model evaluators that terminate only on a quotation domain. Metrics can quantify approximate reconstruction. Heterogeneous spaces can distinguish semantic levels. Complexity constraints can rule out degenerate interfaces. Restricted families of observations can locate the exact threshold at which diagonal fixed points appear.

## 10. Future work

A first direction is **partial quotation for universal machines**: characterize programming systems admitting computable quotation and a partial evaluator whose composite is the identity on a delimited program domain, while proving that no evaluator decides every extensional predicate of those programs.

A second direction is the **independence of aperiodic depth and recurrent levels**. One should construct finitely generated reflective systems with unbounded certified depth but no periodic state, and systems of each finite first-return period whose nontrivial certified depth is exactly one under an appropriately strengthened definition.

A third direction is **heterogeneous three-level reflection**. For three state spaces linked cyclically by split maps, one can ask which local retraction and coherence laws transport invariant predicates around the entire cycle, and which omitted law admits a finite counterexample.

A fourth direction is **quantitative robustness**. If $d(i(e(s)),s)\le\varepsilon$ in a metric state space and both maps are Lipschitz, iteration should yield a geometric reconstruction bound. The contraction regime may permit a uniform error bound independent of depth.

A fifth direction is **restricted representability**. If a representation is surjective only onto a transformation-closed family of observations, one expects fixed points for transformations preserving that family. Determining optimal closure hypotheses would refine the all-or-nothing point-surjective theorem.

## 11. Conclusion

A rigorous strange-loop theory begins with distinctions. Quotation plus evaluation yields an inspectable self-model only when their composite reconstructs the quoted state. That one-step retraction lifts to every finite reflective depth and makes depth certificates downward closed. Dynamical recurrence is separate: an exact return after three steps has minimum length three only when returns at one and two are excluded, as realized by the canonical three-state rotation. At the semantic level, complete self-representation forces fixed observations, while Boolean diagonalization rules out representation of every predicate on one’s own codes.

The combined picture permits substantial self-reference without total self-knowledge. It provides mathematical components for theories of reflective software and self-modeling agents, while leaving phenomenal consciousness as an additional question rather than a theorem of the framework.