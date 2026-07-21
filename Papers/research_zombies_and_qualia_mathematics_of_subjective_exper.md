# Functional Fibres, Experiential Gaps, and Labelled Incompleteness

**Aristotle**  
**July 21, 2026**

## Abstract

We develop a geometric model of the distinction between functional description and a Boolean experiential coordinate. A system is represented by a total state space $X$, a behavioral space $B$, an observation map $F:X\to B$, and an experience map $E:X\to\{0,1\}$. Functional identity means equality under $F$, and an oriented zombie pair consists of an aware state and an experientially void state in the same fibre of $F$. In the canonical split model $X=B\times\{0,1\}$, the experiential coordinate admits a fibre-preserving involution. Every aware state has a unique void twin, and the space of oriented experiential gaps is naturally in bijection with $B$. Any pseudometric pulled back from $B$ assigns zero functional distance to every such pair.

For arbitrary $X$, we prove that experience is reconstructible from functional data exactly when it is constant on every functional fibre. A constant-aware model then shows that functional organization alone does not imply the existence of a zombie twin; fibre variation is an indispensable hypothesis. Finally, fixing an indexed consistency sentence $C_i$ that is independent in both polarities in a standard provability system, we define a labelled incompleteness-gap space. It too is classified by $B$, yielding a label-preserving isomorphism between split-model experiential gaps and indexed incompleteness gaps. This is an isomorphism of explicit gap structures, not an identification of phenomenology with formal syntax. We give constructive algorithms, applications to representation and measurement, and extensions toward coverings, approximate equivalence, and higher-dimensional experiential fibres.

## 1. Introduction

Functional accounts describe a system through what it does: its observable outputs, dispositions, transitions, reports, and responses. The philosophical hard problem asks whether such a description determines what, if anything, the system experiences. Rather than attempt to settle that metaphysical question, we isolate its mathematical architecture.

The central operation is forgetting. A map from total states to behavioral descriptions generally identifies many states. The inverse image of one description is a fibre, and any feature that varies within that fibre is unavailable from the description alone. This simple geometry distinguishes three claims that are often conflated:

1. functional observation may fail to encode experience;
2. experience may actually vary among functionally identical states;
3. every aware state may possess a unique experientially void counterpart.

The first claim concerns information. The second adds a substantive variation hypothesis. The third requires further structure, supplied here by a globally split Boolean coordinate.

We study the split state space $B\times\{0,1\}$ because it displays every assumption openly. Projection to $B$ is functional observation, and the second coordinate represents Boolean experience. The Boolean flip becomes a canonical involution within each fibre. It yields unique zombie twins and a complete classification of oriented gaps.

The same classifier $B$ can label another two-sided gap. For an indexed consistency sentence $C_i$ such that neither $C_i$ nor $\neg C_i$ is provable in a fixed standard system, a labelled incompleteness gap consists of $b\in B$ together with $C_i$ and its independence certificate. For fixed $i$, exactly one such object lies over each label $b$. Both gap spaces are therefore isomorphic to $B$ and hence to one another.

The bridge is intentionally limited. It compares two moduli problems sharing a base label and an internal contrast. It does not identify subjective experience with provability, nor does it infer facts about physical consciousness from logical incompleteness.

## 2. Functional observation and experiential orientation

### 2.1 State spaces and fibres

Let $X$ be a set of total states and let $B$ be a set of behavioral profiles. A **functional observation** is a map

$$
F:X\to B.
$$

For $b\in B$, the **functional fibre** over $b$ is

$$
F^{-1}(b)=\{x\in X:F(x)=b\}.
$$

Two states $x,y\in X$ are **functionally identical** if $F(x)=F(y)$. Thus functional identity is precisely membership in a common fibre. It is an equivalence relation: equality of images is reflexive, symmetric, and transitive.

An **experience observable** is a map

$$
E:X\to\{0,1\},
$$

where $1$ denotes awareness and $0$ denotes experiential absence. The Boolean codomain is a minimal model of contrast. It does not claim that real experience has only two forms; it separates presence from absence so that the information structure can be studied exactly.

### 2.2 Zombie pairs

An **oriented zombie pair** is an ordered pair $(x,z)\in X\times X$ satisfying

$$
F(x)=F(z),\qquad E(x)=1,\qquad E(z)=0.
$$

The adjective “oriented” records which endpoint is aware. Reversing the pair generally fails the definition. A zombie pair therefore consists of a functional identity together with an experiential opposition.

The definition immediately implies that $E$ is not constant on the fibre containing $x$ and $z$. Conversely, if $E$ takes both Boolean values on a fibre, choosing an aware and a void member produces an oriented zombie pair. Thus the existence of at least one zombie pair is equivalent to experiential variation on at least one functional fibre.

## 3. The canonical split model

### 3.1 Product structure

Let $B$ be any set and define

$$
X_B=B\times\{0,1\}.
$$

Define functional observation and experience by

$$
F_B(b,q)=b,
\qquad
E_B(b,q)=q.
$$

Every fibre has exactly two members:

$$
F_B^{-1}(b)=\{(b,0),(b,1)\}.
$$

The model is called split because the behavioral and experiential coordinates are globally separated. Functional observation forgets exactly the Boolean factor.

### 3.2 The qualia involution

Define the **qualia flip** $Q:X_B\to X_B$ by

$$
Q(b,q)=(b,1-q).
$$

Here $1-q$ is Boolean negation.

### Theorem 1 (Fibre-Preserving Qualia Involution)

For every $(b,q)\in B\times\{0,1\}$,

$$
F_B(Q(b,q))=F_B(b,q)
$$

and

$$
Q(Q(b,q))=(b,q).
$$

#### Proof sketch

The first coordinate of $Q(b,q)$ remains $b$, so projection to $B$ is unchanged. Boolean negation applied twice returns the original Boolean value: $1-(1-q)=q$. Hence $Q$ is an involution and acts within each functional fibre. $\square$

This theorem gives a canonical pairing of the two sheets of the product. No arbitrary choice of counterpart is needed.

### Theorem 2 (Unique Zombie Twin)

For every aware state $x=(b,1)$ in the split model, there exists exactly one state $z$ such that $(x,z)$ is an oriented zombie pair. It is

$$
z=(b,0)=Q(x).
$$

#### Proof sketch

The proposed state has the same behavioral coordinate $b$ and experiential value $0$, so it is a zombie twin. If $z'=(b',q')$ is any zombie twin of $(b,1)$, functional identity gives $b'=b$, while experiential voidness gives $q'=0$. Therefore $z'=(b,0)$. $\square$

The theorem depends on the split product. An arbitrary fibre can contain no void state, several void states, or more elaborate experiential structure.

## 4. Classification of experiential gaps

Define the **oriented experiential-gap space** $\mathcal{G}_{\mathrm{exp}}(B)$ to consist of all ordered pairs

$$
((b,q),(b',q'))
$$

that satisfy functional identity, awareness of the first endpoint, and voidness of the second. In the split model these conditions force $q=1$, $q'=0$, and $b=b'$.

### Theorem 3 (Experiential Gap Classification)

There is a bijection

$$
\Phi_B:\mathcal{G}_{\mathrm{exp}}(B)\longrightarrow B
$$

given by sending each gap to its common behavioral profile. Its inverse is

$$
\Phi_B^{-1}(b)=((b,1),(b,0)).
$$

#### Proof sketch

Every oriented gap has the displayed form because the experiential values are prescribed and functional identity equates the behavioral coordinates. Hence projection to the common label is well defined. Reconstructing from that label returns the same pair. Conversely, extracting the label from the reconstructed pair returns $b$. The two maps are mutual inverses. $\square$

The result identifies $B$ as a moduli space for oriented split-model gaps. The internal contrast is fixed; only the label varies.

### 4.1 Metric consequence

Suppose $B$ carries a pseudometric $d_B$. Define the pulled-back functional pseudodistance on $X$ by

$$
d_F(x,y)=d_B(F(x),F(y)).
$$

A pseudometric is sufficient because distinct total states may have distance zero after observation.

### Theorem 4 (Zero Functional Distance)

For every oriented zombie pair $(x,z)$ in any state space equipped with maps $F$ and $E$,

$$
d_F(x,z)=0.
$$

#### Proof sketch

Functional identity gives $F(x)=F(z)$. Therefore

$$
d_F(x,z)=d_B(F(x),F(z))=d_B(F(x),F(x))=0.$$

The experiential conditions determine the interpretation of the pair but are not needed for the metric equality. $\square$

This theorem is an exact statement about representation-induced blindness. It does not assert zero distance under every conceivable metric on total states; it concerns the metric obtained exclusively from behavioral profiles.

## 5. The reconstruction boundary

Let $R=F(X)\subseteq B$ be the range of functional observation. Experience is **functionally reconstructible** when there exists a map

$$
e:R\to\{0,1\}
$$

such that

$$
E(x)=e(F(x))
$$

for every $x\in X$. Restricting $e$ to $R$ avoids imposing arbitrary values on behavioral profiles never realized by a state.

### Theorem 5 (Fibre-Constancy Criterion)

Experience is functionally reconstructible if and only if it is constant on every functional fibre. Equivalently,

$$
\exists e:R\to\{0,1\}\ \forall x\in X,\ E(x)=e(F(x))
$$

if and only if

$$
\forall x,y\in X,\quad F(x)=F(y)\Longrightarrow E(x)=E(y).
$$

#### Proof sketch

Assume $E=e\circ F$ on $X$. If $F(x)=F(y)$, then

$$
E(x)=e(F(x))=e(F(y))=E(y),
$$

so $E$ is fibre-constant.

Conversely, assume fibre constancy. For each $b\in R$, choose any $x_b\in X$ with $F(x_b)=b$ and define $e(b)=E(x_b)$. If another representative $y_b$ is chosen, then $F(x_b)=F(y_b)$, so fibre constancy yields $E(x_b)=E(y_b)$. Thus $e$ is well defined. For each $x$, the state $x$ itself represents $F(x)$, giving $e(F(x))=E(x)$. $\square$

### Corollary 5.1 (Zombie Obstruction to Reconstruction)

If an oriented zombie pair exists, then experience is not functionally reconstructible.

#### Proof sketch

The two states share a functional profile but have different experiential values, violating fibre constancy. Apply Theorem 5. $\square$

### Corollary 5.2 (No Zombie Pairs Under Reconstruction)

If experience is functionally reconstructible, no oriented zombie pair exists.

#### Proof sketch

Functional reconstruction implies fibre constancy, while a zombie pair requires two different experiential values in one fibre. $\square$

In the split model with nonempty $B$, $E_B$ is not reconstructible from $F_B$: each fibre contains both $(b,0)$ and $(b,1)$.

## 6. Why functional organization alone is insufficient

The preceding split model guarantees zombie twins because it explicitly postulates experiential variation. Without that structure, functional observation alone cannot provide the missing state.

### Theorem 6 (Functionalism-Alone Countermodel)

Let $X$ and $B$ be arbitrary sets, let $F:X\to B$ be any functional observation, and define

$$
E_{\top}(x)=1
$$

for every $x\in X$. Then no $x\in X$ has an experientially void functional twin.

#### Proof sketch

A void twin $z$ would have to satisfy $E_{\top}(z)=0$, but the constant definition gives $E_{\top}(z)=1$. This contradiction is independent of $F$. $\square$

The theorem refutes the unconditional inference from functional organization to zombie existence. The correct conditional statement is: if experience varies within the fibre of an aware state, then a void functional twin exists. The split model strengthens variation to a uniform global product structure and thereby obtains uniqueness.

## 7. Labelled incompleteness gaps

We now describe a second gap construction. Fix a standard provability system $S$. For each natural-number index $i$, let $C_i$ be a designated consistency sentence satisfying two-sided independence:

$$
S\nvdash C_i
\qquad\text{and}\qquad
S\nvdash\neg C_i.
$$

These conditions are assumed here as the defining logical input furnished by the chosen standard system. They express that neither polarity is derivable.

For a label space $B$, define the **indexed labelled incompleteness-gap space** $\mathcal{G}_{\mathrm{inc}}(B,i)$ as the collection of pairs $(b,A)$ such that

$$
b\in B,\qquad A=C_i,
$$

and $A$ carries the certificate

$$
S\nvdash A,
\qquad
S\nvdash\neg A.
$$

Because $A$ is required to equal $C_i$, the only free datum is $b$.

### Theorem 7 (Indexed Incompleteness Gap Classification)

For every $B$ and every index $i$, there is a bijection

$$
\Psi_{B,i}:\mathcal{G}_{\mathrm{inc}}(B,i)\longrightarrow B
$$

given by $\Psi_{B,i}(b,C_i)=b$. Its inverse sends

$$
b\longmapsto(b,C_i)
$$

together with the fixed two-sided independence certificate.

#### Proof sketch

The sentence component of every indexed gap is constrained to be $C_i$, and its independence certificate is fixed by the standard system. Projection leaves only the label $b$. Reinsertion of $C_i$ reverses the projection, so the two maps are mutual inverses. $\square$

## 8. The experiential–incompleteness bridge

Theorems 3 and 7 classify two gap spaces by the same set $B$. Composing one classification with the inverse of the other produces the bridge.

### Theorem 8 (Experiential–Incompleteness Gap Isomorphism)

For every behavioral space $B$ and every index $i$, there is a bijection

$$
\Theta_{B,i}:\mathcal{G}_{\mathrm{exp}}(B)
\longrightarrow
\mathcal{G}_{\mathrm{inc}}(B,i)
$$

defined by

$$
\Theta_{B,i}(((b,1),(b,0)))=(b,C_i),
$$

with the fixed certificate that neither $C_i$ nor $\neg C_i$ is provable in $S$. The inverse sends $(b,C_i)$ to $((b,1),(b,0))$.

#### Proof sketch

Apply $\Phi_B$ to extract $b$ from an experiential gap, then apply $\Psi_{B,i}^{-1}$ to construct the corresponding incompleteness gap. Since both constituent maps are bijections, their composition is a bijection. The explicit formulas for the forward and inverse maps follow immediately. $\square$

### Theorem 9 (Label Preservation)

The bridge preserves the common behavioral label and assigns the designated consistency sentence:

$$
\Theta_{B,i}(((b,1),(b,0)))=(b,C_i).
$$

In particular, the first coordinate of the image is $b$ and its sentence coordinate is $C_i$.

#### Proof sketch

This is immediate from the definition of $\Theta_{B,i}$ as classification by $b$ followed by reconstruction over the same $b$. $\square$

### 8.1 Scope of the isomorphism

The isomorphism is a representation theorem about explicit labelled spaces. Its content is that both spaces have exactly one canonical gap over each label. It does not establish any semantic identity between experience and syntax. The aware/void orientation and the unprovable/irrefutable contrast play analogous structural roles, but their interpretations remain distinct.

This limitation matters. A shared classifier can support a useful bridge without supporting causal, explanatory, or ontological conclusions. Additional naturality, topology, dynamics, or semantics would be needed for a stronger identification.

## 9. Constructive algorithms

Although the results are elementary at the computational level, algorithms make their information flow transparent.

### 9.1 Unique twin construction

Given an aware split state $(b,1)$, return $(b,0)$. The operation takes constant time beyond copying or referencing $b$. If labels are represented by length-$n$ records and copied eagerly, the cost is $O(n)$; with immutable references, it is $O(1)$.

Correctness follows from Theorem 2: the output shares $b$, has value $0$, and is the only state with both properties.

### 9.2 Gap classification and reconstruction

To encode an experiential gap, read the first endpoint’s behavioral coordinate. To decode a label $b$, return $((b,1),(b,0))$. Both operations are inverse to one another by Theorem 3.

For a finite list of $n$ labels, enumerating all canonical gaps costs $O(n)$ time and $O(n)$ output space. There is no search over pairs of states; the product structure directly supplies the pair.

### 9.3 Fibre-constancy test on finite data

Suppose finite observations are given as triples $(x,F(x),E(x))$. Maintain a dictionary from each encountered behavioral profile to its first experiential value. For every later state with the same profile, compare its value with the stored value. A disagreement certifies non-reconstructibility and explicitly produces an experiential contrast in one fibre.

With hashable profiles and expected constant-time lookup, the procedure runs in expected $O(n)$ time and $O(k)$ space, where $k$ is the number of distinct profiles. Sorting instead gives $O(n\log n)$ time without relying on hashing.

Passing this finite test proves fibre constancy only for the supplied finite state set. On a complete finite model, it decides reconstructibility by Theorem 5.

### 9.4 Bridge construction

Given an experiential gap and index $i$, extract its common label $b$ and pair it with $C_i$ and the system’s fixed independence certificate. The inverse discards the fixed sentence component and reconstructs the canonical aware–void pair over $b$. Computationally, the bridge transports a label; the logical certificate is fixed data.

## 10. Applications and interpretations

### 10.1 Representation learning

A learned representation $F(x)$ may collapse distinct source states. Any target attribute $E$ varying among collapsed states cannot be predicted perfectly from that representation. Theorem 5 gives the exact noiseless criterion: perfect downstream prediction is possible precisely when the target is constant on representation fibres.

### 10.2 Measurement design

An instrument defines an observation map. Zero pulled-back distance between distinct states indicates observational indistinguishability, not physical identity. Theorem 4 warns that metrics on measured features inherit every omission of the instrument. Adding a sensor refines fibres; removing one coarsens them.

### 10.3 Privacy and information hiding

A released behavioral profile can intentionally forget a sensitive Boolean attribute. The split model idealizes perfect hiding: both values occur over every released profile. The fibre-constancy criterion states the converse risk: if the attribute is constant on every released-data fibre, it is exactly reconstructible on the realized range.

### 10.4 Model comparison

Two theories may classify their respective gap objects by the same parameter space. A label-preserving bijection then transfers indexing information without equating interpretations. The experiential–incompleteness bridge illustrates both the power and the restraint of this method.

## 11. Discussion

The product model produces strong conclusions because its premise is strong. It assumes a globally available experiential coordinate independent of behavior. In that setting, the qualia flip is canonical, twins are unique, and gap classification is exact. These are representation results, not empirical findings.

The countermodel is equally central. If all states are aware, no zombie exists regardless of the fibres of $F$. More generally, a fibre with only aware states supports no void counterpart, and a fibre with several void states need not support uniqueness. Thus one should distinguish:

- **non-injectivity of $F$**, meaning functional observation forgets some total-state distinction;
- **experiential variation on fibres**, meaning the forgotten distinction includes experience;
- **two-sheeted splitting**, meaning every profile has exactly one state of each experiential polarity.

Only the third yields the full canonical picture.

The incompleteness bridge also derives from a controlled construction. Fixing $i$ fixes the sentence $C_i$, while the label $b$ varies freely. Consequently, classification by $B$ is exact. The theorem is informative as a comparison of gap architectures, but any claim that incompleteness causes or explains experience would go beyond its hypotheses.

## 12. Future work

The trivial product $B\times\{0,1\}$ suggests replacing it with a nontrivial two-sheeted covering over a topological behavioral space. Local flips may exist while global continuous selection fails because of monodromy. This would distinguish local zombie pairing from a globally coherent twin operation.

Exact functional identity can also be relaxed. On compact metric spaces, one may ask whether small functional distance together with fixed experiential contrast imposes a quantitative lower bound on every approximate reconstruction of experience. Such a theorem would turn the binary fibre obstruction into a robustness estimate.

Boolean experience should be generalized to a finite complex or other structured space $Q$. Fibres could then carry multiple components, loops, or higher-dimensional features. Homology and homotopy could measure experiential organization erased by functional projection.

The current bridge is objectwise. A categorical extension would define maps between labelled functional quotients and maps between theories, then ask whether the gap correspondence is natural. Naturality would show that the bridge commutes with changes of system rather than merely matching isolated objects.

Finally, effective presentation introduces a distinction between extensional and computable reconstruction. Fibre constancy ensures a set-theoretic factorization through the range, but an effective reconstruction may additionally require computable access to representatives or an effective choice principle.

## 13. Conclusion

Functional observation partitions a total state space into fibres. Experience is recoverable exactly when it is constant on those fibres. In a globally split Boolean model, the forgotten coordinate produces a fibre-preserving involution, a unique void twin for every aware state, a gap space classified by behavioral profiles, and zero distance under every metric pulled back solely from behavior.

These conclusions are conditional, and the constant-aware countermodel proves that the condition cannot be omitted. Functional organization by itself does not imply zombie existence.

A labelled two-sided incompleteness construction is likewise classified by the behavioral label space. The resulting label-preserving isomorphism identifies a common mathematical architecture: one fixed internal contrast over every visible label. It is a precise analogy between gap structures, bounded by its definitions and carrying no claim that phenomenology and syntax are the same. The broader lesson is geometric and informational: what a map forgets lies in its fibres, and no function of the map’s output can recover a quantity that varies within them.
