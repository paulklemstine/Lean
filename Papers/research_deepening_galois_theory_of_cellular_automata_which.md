# Universal Reversibility of Elementary Cellular Automata on Finite Cycles

**Aristotle**  
**1 August 2026**

## Abstract

We classify the elementary binary radius-one cellular automata whose global dynamics are bijective on every nonempty finite cyclic lattice. Among the $256$ Wolfram rules, exactly six have this property: rules $15$, $51$, $85$, $170$, $204$, and $240$. These are precisely the rules that select one coordinate of the local neighborhood—left, center, or right—and then apply one of the two permutations of the binary alphabet. The positive direction is structural: cyclic shifts, pointwise alphabet permutations, and their compositions have explicit inverses. The negative direction is certified by a bounded obstruction theorem: every other elementary rule already fails bijectivity on at least one cycle of length $1$, $2$, $3$, or $4$. Thus bijectivity on those four small cycles is equivalent to bijectivity on every nonempty finite cycle. We also establish the alphabet-independent positive theorem: over an arbitrary alphabet, every single-coordinate radius-one rule followed by an alphabet permutation is reversible, with an explicit opposite-shift inverse. Finally, we describe the action obtained by independently permuting coordinates and alphabet symbols, its composition law, exhaustive classification algorithms, and implications for reversible computation and symbolic dynamics.

## 1. Introduction

A cellular automaton combines a local update law with synchronous global evolution. Although every deterministic rule produces a unique future from a given present, it need not permit reconstruction of the past. Reversibility asks for precisely this stronger property: the induced global transformation must be bijective.

This distinction is already nontrivial for elementary cellular automata. An elementary rule acts on binary configurations and updates each site from its radius-one neighborhood. There are eight binary neighborhoods and two possible outputs for each, hence $2^8=256$ rules. Their simplicity makes them a natural laboratory for a basic question: which local laws conserve all global information?

It is important to formulate the question correctly. A binary radius-one local rule has type

$$
\{0,1\}^3\longrightarrow\{0,1\},
$$

so it cannot be a permutation of its eight-element neighborhood domain. Reversibility belongs to the induced map on full configurations. In this paper the underlying spaces are nonempty finite cycles. This setting captures periodic configurations, permits complete finite tests, and makes inverse maps concrete.

Our main result gives three equivalent descriptions of universal finite-cycle reversibility. An elementary rule is universally reversible if and only if it passes the four cycle tests of lengths $1$ through $4$; if and only if its Wolfram number belongs to

$$
\{15,51,85,170,204,240\};
$$

if and only if it reads one neighborhood coordinate and applies a binary alphabet permutation. Every rule not in this set has a short periodic obstruction.

The proof has two complementary components. First, we identify the six rules as left shift, identity, or right shift, optionally composed with pointwise complement. Their inverses follow from elementary cyclic-index identities. Second, a finite exhaustive analysis of all $256$ local tables on cycles of lengths at most $4$ proves that no additional rule survives. Enumeration supplies completeness, while the structural formulas explain why the survivors work at every size.

The positive mechanism extends to arbitrary alphabets. If $e$ is a permutation of an alphabet $A$, then each rule

$$
f(l,c,r)=e(l),\qquad f(l,c,r)=e(c),\qquad\text{or}\qquad f(l,c,r)=e(r)
$$

is reversible on every nonempty finite cycle. The inverse applies $e^{-1}$ and shifts in the opposite direction when necessary. This extension separates the binary classification from the general reversible construction.

## 2. Elementary rules and cyclic global maps

### 2.1. Local rules

Let $B=\{0,1\}$. A binary radius-one local rule is a function

$$
f:B^3\longrightarrow B.
$$

We write an input as $(l,c,r)$ for the left, center, and right values. Associate to this neighborhood the integer

$$
\iota(l,c,r)=4l+2c+r\in\{0,1,\ldots,7\}.
$$

For a Wolfram number $w\in\{0,1,\ldots,255\}$, let $b_j(w)$ denote bit $j$ of $w$, where $j=0$ is the least significant bit. The elementary rule with number $w$ is

$$
f_w(l,c,r)=b_{\iota(l,c,r)}(w).
$$

This convention completely identifies local tables with the integers from $0$ to $255$.

### 2.2. Configurations on a cycle

Fix $n>0$. The sites form the cyclic set

$$
C_n=\mathbb Z/n\mathbb Z.
$$

A binary configuration is a function $x:C_n\to B$. The configuration space $B^{C_n}$ has cardinality $2^n$. Define the cyclic successor and predecessor by

$$
R(i)=i+1\pmod n,
\qquad
L(i)=i-1\pmod n.
$$

They satisfy

$$
L(R(i))=i,
\qquad
R(L(i))=i.
$$

Therefore $L$ and $R$ are mutually inverse permutations of $C_n$.

The global map induced by a local rule $f$ is

$$
F_{f,n}:B^{C_n}\longrightarrow B^{C_n},
$$

with

$$
F_{f,n}(x)_i=f(x_{L(i)},x_i,x_{R(i)}).
$$

For a Wolfram rule $w$, abbreviate this map as $F_{w,n}$.

**Definition 2.1 (Reversibility on a cycle).** A Wolfram rule $w$ is reversible on the cycle of length $n>0$ if $F_{w,n}$ is bijective.

**Definition 2.2 (Universal finite-cycle reversibility).** A Wolfram rule $w$ is universally reversible if $F_{w,n}$ is bijective for every integer $n>0$.

Since $F_{w,n}$ is an endomorphism of a finite set, injectivity, surjectivity, and bijectivity are equivalent for fixed $n$. Nevertheless, both interpretations are useful: noninjectivity identifies merged pasts, whereas nonsurjectivity identifies unreachable futures.

## 3. Fundamental reversible operations

The classification rests on two elementary reversible operations: spatial shifts and alphabet complement.

### 3.1. Cyclic shifts

Define transformations $S_R,S_L:B^{C_n}\to B^{C_n}$ by

$$
S_R(x)_i=x_{R(i)},
\qquad
S_L(x)_i=x_{L(i)}.
$$

**Lemma 3.1 (Cyclic shift inverse).** For every $n>0$, the maps $S_R$ and $S_L$ are mutual inverses. Consequently, each is bijective.

**Proof sketch.** For each configuration $x$ and site $i$,

$$
(S_L\circ S_R)(x)_i=x_{R(L(i))}=x_i
$$

and

$$
(S_R\circ S_L)(x)_i=x_{L(R(i))}=x_i.
$$

Thus both composites are the identity. $\square$

### 3.2. Pointwise complement

Define $K:B^{C_n}\to B^{C_n}$ by

$$
K(x)_i=1-x_i.
$$

**Lemma 3.2 (Complement involution).** Pointwise complement is an involution and hence a bijection:

$$
K(K(x))=x.
$$

**Proof sketch.** At each site,

$$
1-(1-x_i)=x_i.
$$

The equality therefore holds for configurations pointwise. $\square$

**Corollary 3.3.** The maps $K\circ S_R$ and $K\circ S_L$ are bijective.

**Proof sketch.** Each is a composition of bijections. Equivalently, complement commutes with coordinate shifts, and the inverse is the opposite shift followed by complement. $\square$

## 4. The six reversible elementary rules

Direct evaluation of the eight local neighborhoods gives the following formulas.

**Lemma 4.1 (Six rule formulas).** For every nonempty cycle and every configuration $x$,

$$
\begin{aligned}
F_{15,n}(x)_i&=1-x_{L(i)},\\
F_{51,n}(x)_i&=1-x_i,\\
F_{85,n}(x)_i&=1-x_{R(i)},\\
F_{170,n}(x)_i&=x_{R(i)},\\
F_{204,n}(x)_i&=x_i,\\
F_{240,n}(x)_i&=x_{L(i)}.
\end{aligned}
$$

**Proof sketch.** For each rule, inspect its eight output bits in neighborhood order $4l+2c+r$. Rule $240$ returns $l$, rule $204$ returns $c$, and rule $170$ returns $r$. Their bitwise output complements are rules $15$, $51$, and $85$, respectively. Substitution into the global update formula yields the six identities. $\square$

**Theorem 4.2 (Universal reversibility of the six rules).** Each rule in

$$
\{15,51,85,170,204,240\}
$$

is reversible on every nonempty finite cycle.

**Proof sketch.** By Lemma 4.1, the six global maps are exactly

$$
K\circ S_L,
\quad K,
\quad K\circ S_R,
\quad S_R,
\quad \operatorname{id},
\quad S_L.
$$

Lemma 3.1, Lemma 3.2, and closure of bijections under composition prove the claim. Explicitly, $S_R^{-1}=S_L$, $S_L^{-1}=S_R$, $K^{-1}=K$, and identity is self-inverse. $\square$

This theorem handles all cycle lengths at once. The remaining task is to prove that no other elementary rule is universally reversible.

## 5. Exhaustive small-cycle classification

### 5.1. Finite testing procedure

For fixed $w$ and $n$, enumerate the $2^n$ configurations. Encode a configuration by an integer $s$ from $0$ to $2^n-1$, with its $i$th bit representing $x_i$. Compute $F_{w,n}(x)$ by reading the three cyclic neighbor bits at every site and looking up the corresponding output bit of $w$. Encode the output as another integer.

The global map is bijective exactly when the set of encoded outputs has cardinality $2^n$. The test may stop immediately when two inputs produce the same output, since a collision proves noninjectivity and hence nonbijectivity.

For cycle lengths $1$ through $4$, the number of configuration evaluations per rule is

$$
2^1+2^2+2^3+2^4=30.
$$

Testing all rules therefore requires only

$$
256\cdot30=7680
$$

global-map evaluations, each involving at most four local updates. This bounded computation directly evaluates the definitions; it does not extrapolate from random samples.

### 5.2. Classification theorem

**Theorem 5.1 (Small-cycle classification).** For an elementary Wolfram rule $w$, the following are equivalent:

1. $F_{w,n}$ is bijective for each $n\in\{1,2,3,4\}$.
2. $w\in\{15,51,85,170,204,240\}$.

**Proof sketch.** For the forward implication, exhaust the $256$ possible rule numbers. For each rule, construct its global image sets on cycles of lengths $1$, $2$, $3$, and $4$. Exactly the six listed rules produce full image sets in all four cases. For the reverse implication, Theorem 4.2 shows that each listed rule is bijective not merely on these four cycles but on every nonempty cycle. $\square$

The theorem converts a universal-looking structural question into a finite decision procedure.

**Theorem 5.2 (Short-period obstruction).** If an elementary rule $w$ does not belong to

$$
\{15,51,85,170,204,240\},
$$

then there exists $n\in\{1,2,3,4\}$ such that $F_{w,n}$ is not bijective.

**Proof sketch.** Take the contrapositive of the forward implication in Theorem 5.1. If all four maps were bijective, the rule would lie in the six-element set. Therefore a rule outside the set must fail at least one test. $\square$

Because domain and codomain both have $2^n$ elements, failure may be exhibited either by two distinct inputs with the same output or by an output with no preimage. The theorem bounds the size of such a periodic witness by four.

## 6. Complete characterization

We now connect the numerical list to a conceptual local property.

**Definition 6.1 (Single-coordinate permutative rule).** Let $A$ be an alphabet. A radius-one rule $f:A^3\to A$ is single-coordinate permutative if there is a permutation $e:A\to A$ such that one of the following holds for every $(l,c,r)\in A^3$:

$$
f(l,c,r)=e(l),
$$

$$
f(l,c,r)=e(c),
$$

or

$$
f(l,c,r)=e(r).
$$

For $A=B$, there are exactly two alphabet permutations: identity and complement. Choosing one of three coordinates and one of these two permutations gives six local rules.

**Lemma 6.2 (Binary coordinate classification).** An elementary rule is single-coordinate permutative if and only if its Wolfram number belongs to

$$
\{15,51,85,170,204,240\}.
$$

**Proof sketch.** The identity permutation applied to the left, center, and right coordinates gives rules $240$, $204$, and $170$. Complement applied to those coordinates gives rules $15$, $51$, and $85$. Conversely, the binary alphabet has no other permutations, so the six cases exhaust the definition. This can also be checked directly from the eight-entry tables. $\square$

**Theorem 6.3 (Universal reversibility classification).** For an elementary binary radius-one rule $w$, the following statements are equivalent:

1. The rule is reversible on every nonempty finite cycle.
2. The rule is reversible on cycles of lengths $1$, $2$, $3$, and $4$.
3. Its Wolfram number is one of $15$, $51$, $85$, $170$, $204$, and $240$.
4. Its local rule is single-coordinate permutative.

**Proof sketch.** Universal reversibility implies reversibility on the four specified cycles. Theorem 5.1 identifies the rules passing those tests. Theorem 4.2 proves that all six listed rules are universally reversible. Lemma 6.2 equates the six-rule list with the single-coordinate condition. Chaining these implications establishes all equivalences. $\square$

This theorem is the central classification. It corrects any local-permutation interpretation by giving the exact local form relevant to the global dynamics.

## 7. Arbitrary alphabets and explicit inverses

The completeness statement in Theorem 6.3 is binary. Its positive structural mechanism, however, requires no finiteness and no binary arithmetic.

Let $A$ be any type of symbols, and let $e:A\to A$ be a bijection with inverse $e^{-1}$. For a nonempty cycle $C_n$, configurations form $A^{C_n}$. A radius-one rule $f:A^3\to A$ induces

$$
F_{f,n}(x)_i=f(x_{L(i)},x_i,x_{R(i)}).
$$

**Theorem 7.1 (Single-coordinate reversibility over an arbitrary alphabet).** Suppose that $f$ has one of the forms

$$
f(l,c,r)=e(l),
\qquad
f(l,c,r)=e(c),
\qquad
f(l,c,r)=e(r),
$$

where $e$ is a permutation of $A$. Then $F_{f,n}$ is bijective for every $n>0$.

**Proof sketch.** In the left-reading case,

$$
F_{f,n}(x)_i=e(x_{L(i)}).
$$

Define

$$
G(y)_i=e^{-1}(y_{R(i)}).
$$

Then

$$
G(F_{f,n}(x))_i
=e^{-1}\!\left(e(x_{L(R(i))})\right)
=x_i,
$$

and

$$
F_{f,n}(G(y))_i
=e\!\left(e^{-1}(y_{R(L(i))})\right)
=y_i.
$$

Thus $G$ is a two-sided inverse. In the center-reading case the inverse is pointwise application of $e^{-1}$. In the right-reading case it is $e^{-1}$ after the left shift. $\square$

**Corollary 7.2 (Explicit inverse for a left-reading rule).** If $f(l,c,r)=e(l)$, then

$$
F_{f,n}^{-1}(y)_i=e^{-1}(y_{R(i)}).
$$

The formula is both a left inverse and a right inverse.

This result highlights a conservation principle. A symbol is not combined with competing symbols; it is transported to a neighboring position and relabeled bijectively. Both operations preserve all information.

## 8. Independent coordinate and alphabet actions

The preceding maps belong to a larger family of configuration-space symmetries. Let $p:C_n\to C_n$ be any permutation of sites and let $e:A\to A$ be any permutation of symbols. Define

$$
T_{p,e}:A^{C_n}\longrightarrow A^{C_n}
$$

by

$$
T_{p,e}(x)_i=e(x_{p(i)}).
$$

**Proposition 8.1 (Coordinate-alphabet equivalence).** The map $T_{p,e}$ is bijective, with inverse

$$
T_{p,e}^{-1}(y)_i=e^{-1}(y_{p^{-1}(i)}).
$$

**Proof sketch.** Applying the proposed inverse after $T_{p,e}$ cancels $e$ with $e^{-1}$ and $p$ with $p^{-1}$. The same cancellation in the reverse order proves both inverse identities. $\square$

**Proposition 8.2 (Composition law).** If $p,q$ are site permutations and $e,d$ are alphabet permutations, then applying $T_{p,e}$ followed by $T_{q,d}$ gives

$$
(T_{q,d}\circ T_{p,e})(x)_i
=(d\circ e)(x_{p(q(i))}).
$$

Thus the family is closed under composition, with independent composition in the spatial and alphabet components, subject only to the order imposed by precomposition on coordinates.

**Proof sketch.** Expand the definitions:

$$
T_{q,d}(T_{p,e}(x))_i
=d(T_{p,e}(x)_{q(i)})
=d(e(x_{p(q(i))})).
$$

This is exactly the claimed form. $\square$

The six elementary reversible rules arise when $p$ is one of the two one-step cyclic shifts or identity, and $e$ is identity or complement. The broader family clarifies why spatial transport and symbol relabeling can be analyzed separately.

## 9. Algorithms and computational complexity

### 9.1. Global update algorithm

Given $w$, $n$, and an encoded state $s$, compute every output bit independently. At site $i$, extract the bits at $(i-1)\bmod n$, $i$, and $(i+1)\bmod n$, form $j=4l+2c+r$, and output bit $j$ of $w$.

The running time is $O(n)$ and the auxiliary space is $O(1)$ beyond the output integer. If explicit bit arrays are used, the space is $O(n)$.

### 9.2. Bijectivity test on one cycle

Enumerate all $2^n$ states, compute each image, and insert it into a set. A repeated image proves failure. If all images are distinct, the finite endomap is bijective. The running time is $O(n2^n)$, and the set uses $O(2^n)$ space. A Boolean visitation array indexed by output states gives the same asymptotic bounds and lower overhead.

### 9.3. Classification of all elementary rules

Run the cycle test for every $w\in\{0,\ldots,255\}$ and each $n\in\{1,2,3,4\}$. Keep a rule only if all four tests pass. In general, testing $R$ rules through maximum cycle length $N$ costs

$$
O\!\left(R\sum_{n=1}^{N}n2^n\right)=O(RN2^N).
$$

For $R=256$ and $N=4$, this is tiny. The resulting survivor list is exactly the six-rule set.

### 9.4. Witness extraction

When a repeated output appears, retain the first preimage. The algorithm then returns a concrete collision pair $x\ne x'$ satisfying $F_{w,n}(x)=F_{w,n}(x')$. Alternatively, after computing the image set, scan for a missing encoded output to return an unreachable configuration. The first failure among $n=1,2,3,4$ provides the short-period obstruction guaranteed by Theorem 5.2.

## 10. Examples

### 10.1. Rule $170$

Rule $170$ reads the right neighbor:

$$
F_{170,n}(x)_i=x_{i+1}.
$$

On a six-cell ring, the configuration $(1,0,1,1,0,0)$ maps to

$$
(0,1,1,0,0,1).
$$

Applying the opposite shift restores the original configuration. No information is changed; it is merely transported.

### 10.2. Rule $15$

Rule $15$ complements the left neighbor:

$$
F_{15,n}(x)_i=1-x_{i-1}.
$$

Its inverse complements and shifts in the opposite direction:

$$
F_{15,n}^{-1}(y)_i=1-y_{i+1}.
$$

The two complement operations cancel, as do the two opposing shifts.

### 10.3. An irreversible rule

For a rule outside the six-element set, exhaustive inspection finds a cycle of size at most four on which the global map is not one-to-one. The numerical demonstration accompanying this paper reports the earliest such ring and a collision pair. This witness is stronger than a visual impression of information loss: it gives two explicit distinct pasts with the same future.

## 11. Applications and interpretation

### 11.1. Reversible computation

A bijective update retains enough information to run backward. The six elementary reversible rules therefore define lossless transformations on every finite cyclic register. They are computationally simple—wire permutations and optional bit flips—but they illustrate the exact distinction between deterministic and reversible gates. Most deterministic local rules discard distinctions between states.

### 11.2. Symbolic dynamics

Finite cycles encode periodic configurations. A collision on a cycle gives two distinct periodic configurations with the same periodic image. The short-period theorem therefore states that every excluded elementary rule has a periodic obstruction of period at most four to universal finite-cycle reversibility.

### 11.3. Discrete physical models

Reversible dynamics are natural candidates for microscopic laws in closed discrete systems because each state has a unique predecessor and successor. The classification shows that the elementary binary radius-one setting is too restrictive to support universally reversible finite-ring dynamics that genuinely mix neighborhood data. Richer reversible behavior requires larger neighborhoods, richer alphabets, partitioned updates, or other structural devices.

### 11.4. Verification by bounded exhaustive search

The result illustrates a general methodological pattern. Structural reasoning supplies an infinite family of positive instances by explicit inverses. Exhaustive search over a finite parameter space supplies a complete negative classification. A bounded obstruction theorem then connects the finite search to the universal statement.

## 12. Discussion

The four-cycle criterion is unusually compact. Universal reversibility quantifies over infinitely many cycle lengths, yet the entire elementary rule space can be separated using only $30$ configurations per rule across four sizes. This works because the parameter space itself is finite and because the surviving candidates admit size-independent inverse formulas.

The classification should not be overgeneralized. For larger alphabets or different neighborhoods, reversible cellular automata need not be single-coordinate rules. The theorem states an exact fact about elementary binary radius-one rules under universal finite-cycle reversibility. The arbitrary-alphabet theorem proves sufficiency of single-coordinate permutative rules, not their necessity in every generalized setting.

A further subtlety concerns the precise obstruction bound. The established result shows that $4$ is sufficient. It does not by itself show that $4$ is minimal. Determining whether lengths $1$, $2$, and $3$ already isolate the same six rules remains a sharply posed finite question.

The coordinate-alphabet construction also suggests a group-theoretic direction. The transformations $T_{p,e}$ arise from permutations of sites and symbols. Understanding when two pairs $(p,e)$ yield the same action, and under what hypotheses the representation is faithful, would identify the exact subgroup of the full symmetric group on configuration space generated by independent spatial and alphabet permutations.

## 13. Future work

Several extensions arise naturally.

First, determine the sharp elementary obstruction period: test whether bijectivity on cycles of lengths $1$, $2$, and $3$ already forces membership in the six-rule set, or produce a rule that passes those tests but fails at length $4$.

Second, classify ternary radius-one rules. For alphabet $\{0,1,2\}$, one can ask which maps $A^3\to A$ induce bijections on every finite cycle, and whether all such rules are single-coordinate rules followed by one of the six alphabet permutations.

Third, seek uniform finite obstruction bounds. For each finite alphabet size $q\ge2$, does there exist $B(q)$ such that reversibility on cycles $1$ through $B(q)$ implies reversibility on every finite cycle? A concrete initial target is $B(3)\le8$.

Fourth, establish faithfulness of the coordinate-alphabet action under natural size hypotheses: determine whether $T_{p,e}=T_{q,d}$ forces $p=q$ and $e=d$ when $n\ge3$ and the alphabet has at least two symbols.

Finally, extend the explicit inverse formulas to configurations indexed by $\mathbb Z$. A single-coordinate permutative radius-one rule should have an inverse that is again a radius-one cellular automaton, using the same opposite-shift construction.

## 14. Conclusion

Universal finite-cycle reversibility for elementary cellular automata is completely rigid. Exactly six of the $256$ rules qualify:

$$
15,
\quad51,
\quad85,
\quad170,
\quad204,
\quad240.
$$

They are precisely the left, center, and right coordinate projections, optionally followed by binary complement. Each has an explicit inverse built from the opposite cyclic shift and inverse alphabet permutation. Every other rule fails on a cycle of length at most four. Consequently, four small finite tests decide an infinite family of reversibility requirements.

The arbitrary-alphabet construction reveals the underlying principle: reversible transport of coordinates and reversible relabeling of symbols compose to produce reversible global dynamics. In the elementary binary setting, this principle does not merely provide examples; it exhausts all possibilities.