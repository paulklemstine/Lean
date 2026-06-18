# Thermodynamic Elimination via Prime-Spectral Legendre Duality for Coherent Proof Semirings

## Abstract

We establish a formally verified duality theorem connecting variable elimination in 
polynomial extensions of commutative rings with a variational principle over the prime 
spectrum. Specifically, for a commutative ring $R$ and an ideal $I \subseteq R[X]$, we 
prove that an element $a \in R$ belongs to the radical elimination ideal 
$\sqrt{I} \cap R$ if and only if the constant polynomial $C(a)$ belongs to every prime 
ideal of $R[X]$ containing $I$. We frame this classical result through a thermodynamic 
lens: each prime ideal is an "equilibrium state," membership is an "energy evaluation," 
and elimination becomes a zero-energy condition across all compatible equilibria. The 
formalization in Lean 4 with Mathlib provides machine-verified proofs of the main duality, 
prime witness extraction, and a quantitative separation theorem.

## 1. Introduction

### 1.1 Motivation

The elimination of variables is a fundamental operation across mathematics:
- In **algebraic geometry**, elimination ideals compute projections of varieties
- In **logic**, quantifier elimination removes bound variables from formulas  
- In **optimization**, projection onto subspaces eliminates auxiliary variables
- In **statistical mechanics**, tracing out degrees of freedom produces effective theories

These operations share a common structure: information about a "witness" variable is 
compressed into a statement about "observable" quantities. The central question is: 
*which observable statements survive elimination?*

### 1.2 The Main Result

We prove that elimination in polynomial rings is governed by a variational principle 
on the prime spectrum. For a commutative ring $R$ and ideal $I \subseteq R[X]$:

**Theorem (Prime-Spectral Elimination Duality).** *For any $a \in R$:*
$$a \in \sqrt{I} \cap R \quad \Longleftrightarrow \quad \forall P \in \operatorname{Spec}(R[X]),\; I \subseteq P \;\Rightarrow\; C(a) \in P$$

*where $C : R \to R[X]$ is the constant polynomial embedding.*

In thermodynamic language: **an element is eliminated if and only if its "energy" 
vanishes at every compatible "equilibrium state."**

### 1.3 The Thermodynamic Interpretation

We define the **energy evaluation** at a prime $P$:
$$\mathcal{E}(P, a) = \begin{cases} 0 & \text{if } C(a) \in P \\ 1 & \text{if } C(a) \notin P \end{cases}$$

The **free-energy gap** at $P$ is $\mathcal{E}(P, a)$ itself. The theorem becomes:

$$a \in \operatorname{radicalElim}(I) \quad \Longleftrightarrow \quad \forall P \in \operatorname{Spec}(R[X]),\; I \subseteq P \;\Rightarrow\; \mathcal{E}(P, a) = 0$$

This is a **Legendre-Fenchel type duality**: the "primal" problem (checking radical 
membership via powers) equals the "dual" problem (checking against all primes).

## 2. Definitions and Setup

### 2.1 Elimination Ideals

**Definition 2.1.** For an ideal $I \subseteq R[X]$, the **elimination ideal** is:
$$\operatorname{elim}(I) = I \cap R = \operatorname{comap}_C(I)$$

The **radical elimination ideal** is:
$$\operatorname{radicalElim}(I) = \sqrt{I} \cap R = \operatorname{comap}_C(\sqrt{I})$$

**Proposition 2.2.** $a \in \operatorname{radicalElim}(I)$ if and only if there exists 
$n \in \mathbb{N}$ such that $C(a^n) \in I$.

### 2.2 Spectral Elimination

**Definition 2.3.** A prime $P \in \operatorname{Spec}(R[X])$ is **compatible** with 
$I$ if $I \subseteq P$.

**Definition 2.4.** The **spectral elimination set** is:
$$\operatorname{spectralElim}(I) = \{a \in R \mid \forall P \in \operatorname{Spec}(R[X]),\; I \subseteq P \;\Rightarrow\; C(a) \in P\}$$

### 2.3 The Contraction Map

The constant polynomial embedding $C : R \to R[X]$ induces a contraction map:
$$C^* : \operatorname{Spec}(R[X]) \to \operatorname{Spec}(R), \quad P \mapsto C^{-1}(P)$$

This map is the geometric shadow of the forgetful functor from $R[X]$-modules to 
$R$-modules.

## 3. Main Results

### 3.1 The Duality Theorem

**Theorem 3.1** (Main Duality). *For any commutative ring $R$ and ideal 
$I \subseteq R[X]$:*
$$\operatorname{radicalElim}(I) = \operatorname{spectralElim}(I)$$

*Proof.* The key ingredient is Krull's theorem in the form:
$$\sqrt{I} = \bigcap_{\substack{P \in \operatorname{Spec}(R[X]) \\ I \subseteq P}} P$$

For the forward direction ($\subseteq$): if $a \in \operatorname{radicalElim}(I)$, then 
$C(a) \in \sqrt{I}$, so $C(a) \in P$ for every $P \supseteq I$.

For the reverse direction ($\supseteq$): if $C(a) \in P$ for every prime $P \supseteq I$, 
then $C(a) \in \bigcap_{P \supseteq I} P = \sqrt{I}$, so $a \in \operatorname{radicalElim}(I)$. $\square$

### 3.2 Prime Witness Extraction

**Theorem 3.2** (Separation). *If $a \notin \operatorname{radicalElim}(I)$, then there 
exists a prime $P \in \operatorname{Spec}(R[X])$ with $I \subseteq P$ and $C(a) \notin P$.*

This is the contrapositive of the completeness direction. In thermodynamic terms: 
**non-elimination is witnessed by a prime with positive energy.**

**Corollary 3.3** (Quantitative Separation). *If $a \notin \operatorname{radicalElim}(I)$, 
there exists a prime $P$ with $\mathcal{E}(P, a) = 1$.*

### 3.3 Geometric Intersection

**Theorem 3.4** (Spectral Intersection). *The spectral elimination set equals:*
$$\operatorname{spectralElim}(I) = \bigcap_{\substack{P \in \operatorname{Spec}(R[X]) \\ I \subseteq P}} C^{-1}(P)$$

*viewed as a set-theoretic intersection of contraction ideals.*

### 3.4 Thermodynamic Completeness

**Theorem 3.5** (Thermodynamic Elimination Completeness). *The following are equivalent:*

1. $a \in \operatorname{radicalElim}(I)$  *(algebraic: radical contraction)*
2. $\forall P \supseteq I: C(a) \in P$  *(geometric: spectral domination)*
3. $\forall P \supseteq I: \mathcal{E}(P, a) = 0$  *(thermodynamic: zero energy)*
4. $\forall P \supseteq I: \mathcal{E}(P, a) \leq 0$  *(variational: non-positive pressure)*
5. $a \in \operatorname{primeVariationalKernel}(I)$  *(kernel membership)*

### 3.5 Monotonicity

**Proposition 3.6.** *Elimination is monotone: $I \subseteq J$ implies 
$\operatorname{radicalElim}(I) \subseteq \operatorname{radicalElim}(J)$.*

**Proposition 3.7.** *Spectral elimination is monotone: $I \subseteq J$ implies 
$\operatorname{spectralElim}(I) \subseteq \operatorname{spectralElim}(J)$.*

## 4. Formalization

### 4.1 Lean 4 Architecture

The formalization consists of two files:

1. **`Basic.lean`** (~280 lines): Core definitions and the main duality theorem
   - `eliminationIdeal`, `radicalEliminationIdeal`: contraction ideals
   - `spectralElimination`: prime intersection set  
   - `primePressureIndicator`, `freeEnergyGap`: thermodynamic functionals
   - `mem_radicalElim_iff_spectral`: the main duality
   - `radicalElim_eq_spectralElim`: set equality form
   - `not_mem_radicalElim_iff_exists_prime_witness`: separation theorem

2. **`Duality.lean`** (~175 lines): Extended theory
   - `energyEval`: real-valued energy functional
   - `elim_eq_iInter_primes`: geometric intersection form
   - `thermodynamic_elimination_completeness`: five-way equivalence
   - `exists_energy_separation`: quantitative separation
   - `mem_radical_span_iff_all_primes`: base-ring spectral duality

### 4.2 Proof Architecture

The central proof relies on one key Mathlib theorem:

```lean
Ideal.radical_eq_sInf (I : Ideal R) : 
  I.radical = sInf {J | I ≤ J ∧ J.IsPrime}
```

This characterizes the radical as the intersection of all containing primes. 
Our contribution is:
1. Wrapping this into the `PrimeSpectrum` API
2. Translating through the polynomial embedding $C$
3. Building the thermodynamic interpretation layer
4. Proving the five-way equivalence theorem

### 4.3 Axiom Verification

All theorems depend only on the standard axioms:
- `propext` (propositional extensionality)
- `Classical.choice` (axiom of choice, used via Zorn's lemma in Krull's theorem)
- `Quot.sound` (quotient soundness)

No `sorry`, `axiom`, or `@[implemented_by]` appears in the final code.

## 5. Applications

### 5.1 Algebraic Geometry: Projection of Varieties

For an algebraic variety $V(I) \subseteq \mathbb{A}^{n+1}$, the elimination ideal 
$I \cap k[x_1, \ldots, x_n]$ defines the **projection** 
$\pi(V(I)) \subseteq \mathbb{A}^n$. Our theorem provides a spectral characterization: 
$a$ is in the projection iff it passes all prime tests.

### 5.2 Proof Theory: Quantifier Elimination

In proof-theoretic terms, the polynomial ring $R[X]$ models the "language extended 
by a witness variable." The elimination ideal captures "what can be proved without 
the witness." The spectral theorem says: **a statement is provable without the 
witness iff every prime theory that accepts the axioms also accepts the statement.**

### 5.3 Optimization: Certified Feasibility

In optimization, $I$ encodes constraints and $X$ is an auxiliary variable. The 
elimination ideal characterizes which objective values are feasible after 
optimizing over $X$. The spectral theorem provides a dual certificate: feasibility 
is certified by checking against all dual "equilibrium" points.

## 6. Discussion: A Scientific American Perspective

### The Big Picture

Imagine you're a detective investigating a crime. You have a set of clues (the ideal 
$I$), some of which involve an unknown suspect (the variable $X$). You want to know: 
*what can you conclude about the observable facts, regardless of who the suspect is?*

The **elimination** answer: compute which facts follow from the clues, no matter what 
value the suspect takes.

The **spectral** answer: check every possible "worldview" (prime ideal) that's 
consistent with your clues. If a fact holds in every consistent worldview, it's 
a genuine conclusion.

Our theorem says these two approaches give exactly the same answer. This is 
remarkable because:
- The elimination approach is **constructive** but potentially expensive (Gröbner bases)
- The spectral approach is **universal** but involves infinitely many worldviews
- Their equivalence is a deep structural fact, mediated by the prime ideal theorem

### The Thermodynamic Metaphor

In statistical mechanics, a system has many possible microscopic states (like our 
prime ideals). The **free energy** tells you which macroscopic observables are 
consistent with the microscopic physics. Our theorem is the algebraic analogue:

| Physics | Algebra | This Work |
|---------|---------|-----------|
| Microscopic state | Prime ideal $P$ | "Equilibrium state" |
| Observable | Element $a \in R$ | "Macroscopic variable" |
| Hidden DOF | Variable $X$ | "Witness variable" |
| Free energy | $\mathcal{E}(P, a)$ | Energy evaluation |
| Equilibrium condition | $F = 0$ | $\mathcal{E}(P,a) = 0$ |
| Thermodynamic limit | $\sqrt{I} \cap R$ | Radical elimination |

The duality says: **the macroscopic predictions of the theory (elimination ideal) 
are exactly those validated by every microscopic equilibrium (prime).**

### Historical Context

This result sits at the intersection of several classical threads:
- **Hilbert's Nullstellensatz** (1893): the radical of an ideal equals the 
  intersection of containing maximal ideals (over algebraically closed fields)
- **Krull's prime ideal theorem** (1929): every proper ideal is contained 
  in a prime ideal
- **Stone duality** (1936): Boolean algebras correspond to compact totally 
  disconnected spaces
- **Lawvere's metric semantics** (1973): logic has a quantitative/metric structure

Our contribution is the synthesis: framing elimination as a variational principle 
and formalizing it in a proof assistant, making the connection between algebraic 
geometry and thermodynamics machine-verifiable.

## 7. Conclusion

We have formalized and proved the prime-spectral elimination duality theorem in 
Lean 4, establishing a machine-verified bridge between:
- Algebraic elimination (radical ideal contraction)
- Geometric spectral theory (prime intersection)
- Thermodynamic variational principles (zero-energy conditions)

The formalization is complete (no `sorry`), uses only standard axioms, and builds 
on Mathlib's existing infrastructure for commutative algebra and prime spectra.

## References

1. Hilbert, D. (1893). Über die vollen Invariantensysteme. *Math. Ann.* 42, 313–373.
2. Krull, W. (1929). Idealtheorie in Ringen ohne Endlichkeitsbedingung. *Math. Ann.* 101, 729–744.
3. Stone, M.H. (1936). The theory of representations for Boolean algebras. *Trans. AMS* 40, 37–111.
4. Lawvere, F.W. (1973). Metric spaces, generalized logic, and closed categories. *Rend. Sem. Mat. Fis. Milano* 43, 135–166.
5. Mathlib Community (2024). Mathlib4: Mathematics in Lean. https://github.com/leanprover-community/mathlib4
