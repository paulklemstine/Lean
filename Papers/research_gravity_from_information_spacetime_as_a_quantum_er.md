# Geometric Defect and Logical Capacity: Singleton Constraints on Spacetime-Code Dictionaries

**Aristotle**  
**18 July 2026**

## Abstract

A proposed bridge between quantum error correction and emergent geometry identifies the physical length $n$, logical dimension parameter $k$, and distance $d$ of an $[[n,k,d]]$ quantum code with microscopic boundary size, protected entropy, and a bulk geometric length. This paper analyzes the arithmetic consequences of that dictionary using the quantum Singleton bound. The central distinction is between validity, $2d+k\le n+2$, and saturation, $2d+k=n+2$: only saturation yields the exact identity $k=n-2d+2$. We define the geometric defect $\delta$ by $n=2d+\delta$ and prove the defect–capacity law $k\le\delta+2$. Exact balance $n=2d$ consequently permits at most two logical qubits, and Singleton saturation at balance occurs exactly when $k=2$. If a reversed redundancy inequality is imposed together with the genuine bound, balanced parameters are forced to $k=2$. For code families, uniformly bounded defect implies uniformly bounded logical capacity and a logical rate that tends to zero as physical size grows. These conclusions delimit what a global Singleton argument can support: an extensive entropy requires extensive defect, while an exact entropy formula requires a separate saturation mechanism. We discuss algorithms for auditing geometric dictionaries, numerical examples, cut-dependent refinements, and the physical assumptions still needed to turn parameter consistency into a theory of spacetime.

## 1. Introduction

Quantum error correction and gravitational geometry share a suggestive structural theme. In a quantum code, information is represented nonlocally so that local damage need not destroy it. In gravitational and holographic settings, information associated with a bulk region may be recoverable from boundary degrees of freedom, while geometric extremal surfaces organize entanglement. This resemblance motivates a strong conjectural picture: microscopic spatial degrees of freedom act as physical qubits, bulk information acts as logical qubits, and geometric obstruction lengths act as code distances.

The purpose of this paper is neither to assume nor to dismiss that picture. It is to isolate a precise coding-theoretic claim and determine exactly what follows from it. Consider an $[[n,k,d]]$ quantum code, where $n$ is the number of physical qubits, $k$ is the number of logical qubits, and $d$ is the code distance. A proposed geometric dictionary may read $n$ as a boundary measure in microscopic units, $k$ as an entropy in bits or qubits, and $d$ as a minimal bulk length in corresponding units. The quantum Singleton bound then supplies a necessary constraint:

$$
2d+k\le n+2.
$$

The motivating temptation is to rearrange this relation into an exact formula $k=n-2d+2$ and compare it with an entropy–area law. That step is valid only if the bound is saturated. The distinction between inequality and equality is therefore the first organizing principle of our analysis.

The second organizing principle is the quantity left after distance is accounted for. We define the geometric defect $\delta$ through $n=2d+\delta$. Substitution into Singleton immediately gives $k\le\delta+2$. This result shows that the excess of physical size over twice the distance—not physical size alone—controls the permitted logical capacity. In particular, the frequently suggested balance $n=2d$ forces $k\le2$ independently of scale.

The paper develops these consequences systematically. Section 2 defines the parameter framework. Section 3 distinguishes Singleton validity from saturation and reconciles two common forms of the bound. Section 4 proves the defect–capacity theorem and its finite consequences. Section 5 treats families and asymptotic rates. Section 6 presents auditing algorithms and examples. Section 7 explains implications for geometric entropy proposals, while Section 8 separates established parameter consequences from additional physical hypotheses.

## 2. Parameter framework and geometric dictionary

### 2.1 Quantum-code parameters

**Definition 2.1 (Quantum-code parameter triple).** An $[[n,k,d]]$ quantum code is described here by natural numbers $n$, $k$, and $d$, where $n$ is the number of physical qubits, $k$ is the number of encoded logical qubits, and $d$ is the minimum weight of an undetectable logical error. We assume the basic parameter conditions $k\le n$ and $d\ge1$ whenever subtraction-based forms of coding bounds are used.

The operational meaning of $d$ is that errors on fewer than $d$ physical locations cannot implement a nontrivial logical operation. Greater distance therefore demands greater redundancy.

**Definition 2.2 (Singleton validity).** A parameter triple is Singleton-valid if it satisfies

$$
2d+k\le n+2.
$$

This subtraction-free expression is convenient over natural numbers and includes the usual additive constant associated with quantum codes.

**Definition 2.3 (Singleton saturation).** A Singleton-valid triple is Singleton-saturating if

$$
2d+k=n+2.
$$

Saturation is an additional optimality property, not a consequence of validity.

### 2.2 Redundancy form

The Singleton bound is also commonly presented as a statement about redundancy.

**Lemma 2.4 (Equivalence of Singleton forms).** If $k\le n$ and $d\ge1$, then

$$
2d+k\le n+2
$$

if and only if

$$
2(d-1)\le n-k.
$$

**Proof sketch.** Subtract $k$ and $2$ from the first inequality, which is legitimate under the parameter assumptions, to obtain $2d-2\le n-k$. Factor the left side as $2(d-1)$. Reversing these algebraic steps gives the converse. The assumptions prevent ambiguities from truncated subtraction on natural numbers. $\square$

The redundancy $n-k$ must therefore be at least twice $d-1$. This is the familiar trade-off: increasing the protected logical payload leaves less room for distance.

### 2.3 Geometric interpretation and defect

A geometric application supplies a dictionary rather than a theorem. For example, a boundary measure $A$ and microscopic scale $\ell$ might suggest $n=A/\ell$, while a characteristic minimal length $L$ might suggest $d=L/(2\ell)$. The exact factors depend on the model and must be stated explicitly.

**Definition 2.5 (Geometric defect).** A nonnegative integer $\delta$ is the geometric defect of a parameter triple if

$$
n=2d+\delta.
$$

This equation is preferable to writing $\delta=n-2d$ because it records nonnegativity without relying on truncated subtraction. The defect measures the physical size left over after the distance contribution $2d$ has been removed.

**Definition 2.6 (Exact geometric balance).** A code is exactly balanced when $n=2d$, equivalently when its geometric defect is $\delta=0$.

The geometric terminology does not assert that a code realizes an actual spacetime. It labels the arithmetic structure induced by a proposed dictionary.

## 3. Inequality, saturation, and exact identities

The logical capacity identity often sought in geometric applications is a statement about saturation.

**Theorem 3.1 (Saturation Capacity Identity).** If an $[[n,k,d]]$ code saturates the quantum Singleton bound, then

$$
k+2d=n+2,
$$

or equivalently,

$$
k=n-2d+2.
$$

**Proof sketch.** The first equation is merely the saturation hypothesis with the summands reordered. Solving for $k$ gives the second form whenever integer subtraction is interpreted under the equality. $\square$

The theorem is deliberately conditional. Singleton validity alone gives only

$$
k\le n-2d+2,
$$

not equality. Thus an exact entropy formula cannot be identified with Singleton solely because both expressions contain related parameters. A model must prove that its codes lie on the Singleton boundary.

One may quantify the failure of saturation by a nonnegative slack $s$ defined through

$$
2d+k+s=n+2.
$$

Then

$$
k=n-2d+2-s.
$$

The desired identity corresponds exactly to $s=0$. This elementary observation is important in applications: an entropy deficit relative to a proposed area expression may reflect coding slack rather than geometry itself.

## 4. The defect–capacity law

We now state the principal finite-parameter result.

**Theorem 4.1 (Defect–Capacity Theorem).** Let an $[[n,k,d]]$ quantum code satisfy the Singleton bound, and suppose its geometric defect is $\delta$, so that $n=2d+\delta$. Then

$$
k\le\delta+2.
$$

**Proof sketch.** Substitute $n=2d+\delta$ into $2d+k\le n+2$ to obtain

$$
2d+k\le2d+\delta+2.
$$

Cancel $2d$ from both sides. $\square$

The theorem converts a three-parameter bound into a direct capacity estimate. Its interpretation is that distance consumes the portion $2d$ of the physical size. Only the residual $\delta$, together with the additive constant two, is available under the Singleton ceiling.

### 4.1 Exact balance

**Corollary 4.2 (Balanced Capacity Bound).** If a Singleton-valid code satisfies $n=2d$, then

$$
k\le2.
$$

**Proof sketch.** Exact balance means $\delta=0$. Apply Theorem 4.1. $\square$

**Corollary 4.3 (No Extensive Entropy at Exact Balance).** No parameter triple with $n=2d$ and $k\ge3$ can satisfy the quantum Singleton bound.

**Proof sketch.** Corollary 4.2 gives $k\le2$, contradicting $k\ge3$. $\square$

This obstruction is independent of scale. The pairs $(n,d)=(100,50)$ and $(10^{12},5\cdot10^{11})$ produce the same ceiling $k\le2$. Growth of $n$ is exactly offset by growth of $d$.

### 4.2 Saturation at balance

**Theorem 4.4 (Balanced Saturation Characterization).** Under exact balance $n=2d$, Singleton saturation occurs if and only if $k=2$:

$$
2d+k=n+2 \quad\Longleftrightarrow\quad k=2.
$$

**Proof sketch.** Replace $n$ by $2d$ in the saturation equation. It becomes $2d+k=2d+2$, which is equivalent to $k=2$. $\square$

Thus the bound is saturated at exact balance at one and only one logical capacity. Values $k=0$ and $k=1$ are Singleton-valid but nonsaturating; $k=2$ saturates; values $k\ge3$ are invalid.

### 4.3 Entropy demand forces defect

**Theorem 4.5 (Capacity Demand Bound).** Suppose a Singleton-valid code has defect $\delta$ and is required to encode at least $m$ logical qubits, so $m\le k$. Then

$$
m\le\delta+2.
$$

Equivalently, for $m\ge2$, the defect must obey $\delta\ge m-2$.

**Proof sketch.** Combine the demand $m\le k$ with Theorem 4.1, which gives $k\le\delta+2$, and use transitivity. $\square$

If logical entropy is intended to grow proportionally to a geometric size, then the defect must grow at least comparably. An extensive $k$ cannot be obtained from bounded $\delta$.

## 5. Direction reversal and parameter collision

A potentially misleading calculation arises by reversing the redundancy form of Singleton. The genuine inequality is

$$
2(d-1)\le n-k.
$$

Consider instead the reversed inequality

$$
n-k\le2(d-1).
$$

This reversed relation is not the Singleton bound. At exact balance, however, it has a simple interpretation.

**Lemma 5.1 (Reversed Redundancy at Balance).** Assume $k\le n$, $d\ge1$, and $n=2d$. Then

$$
n-k\le2(d-1)
$$

if and only if

$$
2\le k.
$$

**Proof sketch.** Substitute $n=2d$. The inequality becomes $2d-k\le2d-2$. Canceling $2d$ and reversing signs yields $k\ge2$. The parameter assumptions ensure the natural-number expressions have their ordinary integer meaning. $\square$

**Theorem 5.2 (Direction-Collision Theorem).** Suppose a code is Singleton-valid, exactly balanced, and also satisfies the reversed redundancy inequality. Then

$$
k=2.
$$

**Proof sketch.** Singleton validity and exact balance imply $k\le2$ by Corollary 4.2. Lemma 5.1 turns the reversed inequality into $2\le k$. Antisymmetry gives $k=2$. $\square$

This theorem explains a subtle trap. An erroneous reversed inequality may appear to support a special identity when combined with the correct inequality, but the agreement occurs because opposite bounds squeeze $k$ to a single value. It does not validate the reversal or establish a scale-dependent entropy law.

## 6. Families and asymptotic rate

Finite bounds become asymptotic obstructions when applied uniformly.

**Definition 6.1 (Bounded-defect family).** A family of codes $[[n_i,k_i,d_i]]$, indexed by $i$, has uniformly bounded defect if there is a fixed natural number $D$ and defects $\delta_i$ such that

$$
n_i=2d_i+\delta_i,
\qquad
\delta_i\le D
$$

for every $i$.

**Theorem 6.2 (Bounded-Defect Family Theorem).** If every code in a bounded-defect family is Singleton-valid, then

$$
k_i\le D+2
$$

for every $i$.

**Proof sketch.** Apply Theorem 4.1 to each member to obtain $k_i\le\delta_i+2$, then use $\delta_i\le D$. $\square$

The theorem says that increasing block length alone does not yield increasing logical capacity when the distance remains within a bounded additive defect of $n/2$.

**Theorem 6.3 (Vanishing-Rate Theorem).** Let a Singleton-valid code family have defect bounded by $D$. For every real $\varepsilon>0$, there exists a threshold $N$ such that

$$
N\le n_i \quad\Longrightarrow\quad \frac{k_i}{n_i}<\varepsilon.
$$

One may choose any integer $N$ satisfying

$$
N>\frac{D+2}{\varepsilon}.
$$

**Proof sketch.** Theorem 6.2 gives $k_i\le D+2$. If $n_i>N>(D+2)/\varepsilon$, then

$$
\frac{k_i}{n_i}\le\frac{D+2}{n_i}<\varepsilon.
$$

Therefore the logical rate approaches zero along any subfamily whose physical size tends to infinity. $\square$

This conclusion is stronger than saying that exact balance limits capacity. Even a bounded departure from balance leaves capacity uniformly bounded and causes its fraction of the physical system to vanish.

## 7. Computational audit algorithms

The theorems lead to simple and transparent parameter-audit procedures.

### 7.1 Single-code audit

**Algorithm 7.1 (Singleton Geometric-Defect Audit).** Given integers $n$, $k$, and $d$ with $n,k\ge0$ and $d\ge1$:

1. Compute the Singleton left side $B=2d+k$ and right side $R=n+2$.
2. Declare the triple Singleton-valid exactly when $B\le R$.
3. If $n\ge2d$, compute $\delta=n-2d$; otherwise report that no nonnegative geometric defect exists under this dictionary.
4. Compute the defect ceiling $k_{\max}=\delta+2$.
5. Check that Singleton validity is equivalent to $k\le k_{\max}$ once the defect equation holds.
6. Declare saturation exactly when $B=R$.

The algorithm uses constant time and constant memory for fixed-width integers; with arbitrary-precision integers, its bit complexity is linear in the maximum input bit length up to the cost of basic arithmetic.

### 7.2 Family audit

**Algorithm 7.2 (Bounded-Defect Rate Audit).** Given a finite list of triples and a proposed bound $D$:

1. For each triple, verify Singleton validity.
2. Compute $\delta_i=n_i-2d_i$ when nonnegative.
3. Verify $\delta_i\le D$.
4. Verify $k_i\le D+2$.
5. Compute the observed logical rate $k_i/n_i$.
6. For a chosen $\varepsilon>0$, compute $N=\lfloor(D+2)/\varepsilon\rfloor+1$ and confirm that entries with $n_i\ge N$ have rate below $\varepsilon$.

The algorithm is linear in the number of triples. It is an audit of necessary arithmetic conditions, not an existence test for quantum codes with those parameters.

### 7.3 Saturation and reversal diagnostic

**Algorithm 7.3 (Balanced Direction Diagnostic).** For a balanced triple with $n=2d$:

1. Evaluate the genuine Singleton condition $2(d-1)\le n-k$.
2. Evaluate the reversed condition $n-k\le2(d-1)$.
3. If both hold, conclude $k=2$.
4. If only the genuine condition holds, conclude $k<2$ is permitted.
5. If only the reversed condition holds, the triple has $k>2$ and violates Singleton.

This diagnostic makes inequality direction visible rather than burying it in rearrangement.

## 8. Numerical examples

**Example 8.1 (Exact balance).** Let $n=100$ and $d=50$. Then $\delta=0$, so $k\le2$. The triples $[[100,0,50]]$, $[[100,1,50]]$, and $[[100,2,50]]$ satisfy the arithmetic Singleton condition; only the last saturates it. The triple $[[100,3,50]]$ violates it because $2\cdot50+3>102$.

**Example 8.2 (Moderate defect).** Let $n=120$ and $d=50$. Then $\delta=20$, and $k\le22$. The triple $[[120,22,50]]$ saturates Singleton, while $[[120,10,50]]$ has slack $12$.

**Example 8.3 (Scaling at fixed defect).** Consider $n_i=2i+10$, $d_i=i$, and any Singleton-valid $k_i$. Here $\delta_i=10$ for all $i$, so $k_i\le12$. Even if every code saturates with $k_i=12$, its rate is

$$
\frac{12}{2i+10},
$$

which tends to zero.

**Example 8.4 (Extensive target).** Suppose one demands $k\ge0.1n$ for a large code. Theorem 4.5 requires $\delta+2\ge0.1n$, hence $\delta\ge0.1n-2$. The defect must therefore grow linearly with $n$; a bounded defect cannot support the target.

**Example 8.5 (AdS-like length dictionary).** If a boundary length $L$ and microscopic length $\ell$ are translated as $n=L/\ell$ and $d=L/(2\ell)$, then $n=2d$. Singleton therefore gives $k\le2$, not an entropy proportional to $L$. An extensive boundary entropy is incompatible with this global dictionary unless the interpretation of $n$, $d$, or $k$ is modified, or a different coding inequality is used.

## 9. Implications for entropy–geometry proposals

An entropy–area relation is an equality. A Singleton bound is an inequality. Their identification requires more structure than a resemblance between formulas.

First, a candidate construction must specify an actual code or family of codes and show that the code parameters correspond to the proposed geometric quantities. In particular, geometric length does not become code distance merely by dimensional comparison. Distance is an operational property defined by correctable errors and logical operators.

Second, the construction must establish saturation if it seeks the identity $k=n-2d+2$. Codes with identical $n$ and $d$ can have smaller $k$, and Singleton permits all of them. Saturation may arise from special algebraic structure, but it cannot be inferred from the bound itself.

Third, the exact-balance dictionary $n=2d$ is too rigid for extensive protected entropy under the global parameter interpretation. It leaves only $k\le2$. If $k$ is identified with an entropy that grows with boundary area, then at least one identification fails at large scale.

A promising resolution is regional rather than global. Holographic entropy formulas associate each boundary region with a minimal cut. One may therefore need a cut-indexed collection of effective parameters $n_A$, $k_A$, and $d_A$, together with region-dependent defects

$$
\delta_A=n_A-2d_A.
$$

An entropy equality might then represent saturation of a family of local or cut-dependent inequalities rather than one global Singleton inequality. This proposal is not established by the present results, but it responds directly to the obstruction they identify.

## 10. Scope and limitations

The conclusions in this paper are parameter theorems. They do not prove the existence of a stabilizer code realizing a given geometry. They do not derive Einstein dynamics, identify matter with an error syndrome, or establish curvature as a decoding response. Those claims require at least:

1. a microscopic state space and encoding map;
2. a specified class of errors or noise channel;
3. a locality structure relating physical qubits to geometry;
4. an operational derivation of code distance from geometric data;
5. a mechanism selecting Singleton saturation, if equality is required;
6. dynamical predictions that distinguish the model from alternative descriptions.

Nor does arithmetic Singleton validity guarantee that an $[[n,k,d]]$ quantum code exists. Coding bounds are necessary constraints. Construction and existence are separate problems.

The additive constant two also deserves care. It is negligible in conventional asymptotic-rate calculations but decisive at exact balance, where it supplies the entire capacity ceiling. Dropping it prematurely would incorrectly predict $k\le0$ instead of $k\le2$.

Finally, entropy and logical-qubit count are not automatically identical. A code with $k$ logical qubits has a logical Hilbert space of dimension $2^k$, whose maximal entropy is $k$ bits, but actual state entropy depends on the state. Any physical use of $k$ as entropy must specify the logarithm base, state ensemble, and operational meaning.

## 11. Discussion and future work

The defect–capacity law suggests several concrete directions. For geometrically local code families, one may ask whether normalized defect $(n-2d)/n$ not only upper-bounds but also predicts achievable logical rate within fixed locality classes. Matching lower bounds would turn the present obstruction into a capacity characterization.

For tensor-network models, cut-dependent parameters can be computed for finite networks. One can compare minimal-cut size, erasure distance, and reduced-state entropy for every boundary subset, testing whether entropy identities coincide with saturation of cut-indexed coding inequalities.

For families satisfying $n=2d+O(1)$, the present results predict uniformly bounded protected entropy whenever that entropy is bounded by $k$. Explicit noise models can test whether some alternative operational entropy evades this conclusion.

A further conjecture is that geometry may depend not on a constant global defect but on spatial variation of a local defect density. On triangulated surfaces, one could compare coarse-grained curvature with a discrete Laplacian of local coding defect across regular, conical, and random refinements. Such a relation would require definitions beyond global code parameters, but it offers a falsifiable way to connect coding inhomogeneity with geometry.

## 12. Conclusion

The quantum Singleton bound provides a rigorous consistency test for proposed spacetime-code dictionaries. Its consequences are exact:

$$
2d+k\le n+2,
$$

and, with $n=2d+\delta$,

$$
k\le\delta+2.
$$

Equality $k=n-2d+2$ requires Singleton saturation. Exact balance $n=2d$ permits at most two logical qubits, with saturation precisely at $k=2$. Uniformly bounded defect yields uniformly bounded logical capacity and vanishing asymptotic logical rate. Conversely, extensive logical entropy demands extensive defect.

These results neither establish nor refute the broader possibility that geometry emerges from quantum information. They identify the burden a successful model must meet. A global balance between physical size and twice the distance cannot by itself produce extensive protected entropy. The relevant resource is the excess beyond that balance, or else a richer regional structure in which different cuts carry different effective coding constraints.