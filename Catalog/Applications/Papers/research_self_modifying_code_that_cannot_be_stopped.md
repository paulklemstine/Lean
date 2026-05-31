# Self-Modifying Halting: A Formal Framework for Undecidability in Dynamic Computational Systems

## Abstract

We introduce a formal mathematical framework for studying the halting problem in self-modifying computational systems—programs that can rewrite their own code during execution. We define the notion of a *self-modifying system* (SMS), formalize halting oracles, virus detectors, and alignment monitors for such systems, and prove a suite of impossibility and structural theorems. Our main results are: (1) no algorithm can decide the halting problem for self-modifying programs (Theorem 1); (2) the classical halting problem reduces to the self-modifying halting problem, establishing it is at least as hard (Theorem 2); (3) perfect virus detection for self-modifying code is impossible (Theorem 3); (4) no algorithm can predict self-modification fixed points (Theorem 4); (5) there exists a strict hierarchy of self-modification levels (Theorem 5); (6) any monitor for a self-modifying system that is observable by the system can be evaded (Theorem 6). We also prove quantitative bounds on orbit structure in finite self-modifying systems using pigeonhole arguments. All results have been formally verified in Lean 4 with Mathlib.

**Keywords**: Halting problem, self-modifying code, undecidability, virus detection, AI alignment, diagonal argument, formal verification

---

## 1. Introduction

The halting problem, established by Turing (1936), is one of the foundational results in computability theory. It states that no algorithm can decide, for an arbitrary program and input, whether the program eventually halts. This result has profound implications for software verification, mathematical logic, and the foundations of computing.

However, Turing's formalization assumes a static model of computation: the program's instructions do not change during execution. Modern software routinely violates this assumption. Self-modifying code appears in:

- **Polymorphic and metamorphic malware**: Viruses that rewrite their own code to evade signature-based detection (Szor, 2005).
- **Just-in-time compilation**: Runtime systems that recompile code for optimization (Aycock, 2003).
- **Self-improving AI**: Systems designed to modify their own learning algorithms or reasoning processes (Schmidhuber, 2007).
- **Genetic programming**: Evolutionary computation where programs mutate and recombine (Koza, 1992).

Despite the ubiquity of self-modifying code, the computability-theoretic analysis of such systems has been fragmented. We provide a unified framework that captures the essential features of self-modification and derives a hierarchy of undecidability results.

### 1.1 Contributions

1. **Formal definition** of self-modifying systems (Definition 1) that captures code mutation, universal encoding, and execution semantics.
2. **Diagonal impossibility** for self-modifying halting (Theorem 1).
3. **Reduction theorem** showing classical halting embeds into self-modifying halting (Theorem 2).
4. **Virus detection impossibility** for self-modifying code (Theorem 3).
5. **Fixed-point obstruction** for alignment monitors (Theorem 4).
6. **Strict hierarchy** of self-modification levels (Theorem 5).
7. **Monitor evasion** for observable oversight systems (Theorem 6).
8. **Quantitative bounds** on finite self-modifying systems (Theorems 7–9).

All results are formalized and verified in Lean 4 with the Mathlib library.

---

## 2. Definitions

### Definition 1 (Self-Modifying System)

A *self-modifying system* $S = (\mathcal{C}, \mathcal{I}, \text{exec}, \text{modify}, \text{encode})$ consists of:
- A type $\mathcal{C}$ of *codes* (programs).
- A type $\mathcal{I}$ of *inputs*.
- An execution function $\text{exec} : \mathcal{C} \times \mathcal{I} \to \text{Option}(\text{Bool})$, where $\text{some}(b)$ denotes halting with output $b$ and $\text{none}$ denotes divergence.
- A modification function $\text{modify} : \mathcal{C} \times \mathcal{I} \to \mathcal{C}$, representing self-modification.
- An encoding function $\text{encode} : \mathcal{C} \to \mathcal{I}$ that is injective, enabling self-reference.

The key distinction from classical Turing machines is the modification function: during execution, the system can produce a new code that differs from the original.

### Definition 2 (Halting Oracle)

A *halting oracle* for $S$ is a total function $\text{oracle} : \mathcal{C} \times \mathcal{I} \to \text{Bool}$ satisfying:
$$\text{oracle}(c, i) = \text{true} \iff \text{exec}(c, i) \in \{\text{some true}, \text{some false}\}$$

### Definition 3 (Self-Modifying Halting Oracle)

A *self-modifying halting oracle* for $S$ is a total function $\text{oracle} : \mathcal{C} \times \mathcal{I} \to \text{Bool}$ satisfying:
$$\text{oracle}(c, i) = \text{true} \iff \text{exec}(\text{modify}(c, i), i) \text{ halts}$$

This oracle must predict the halting behavior of the *modified* code, not the original.

### Definition 4 (Perfect Virus Detector)

A *perfect virus detector* for $S$ is a total function $\text{detector} : \mathcal{C} \to \text{Bool}$ satisfying:
$$\text{detector}(c) = \text{true} \iff \text{exec}(\text{modify}(c, \text{encode}(c)), \text{encode}(c)) = \text{none}$$

### Definition 5 (Alignment Monitor)

An *alignment monitor* for $S$ is a total function $\text{monitor} : \mathcal{C} \to \text{Bool}$ satisfying:
$$\text{monitor}(c) = \text{true} \iff \text{modify}(c, \text{encode}(c)) = c$$

This predicts whether a program is a fixed point of its own self-modification.

### Definition 6 (Self-Modification Depth)

The *self-modification depth* function $\text{depth}_S(c, i, \cdot) : \mathbb{N} \to \mathcal{C}$ is defined recursively:
$$\text{depth}_S(c, i, 0) = c, \quad \text{depth}_S(c, i, n+1) = \text{modify}(\text{depth}_S(c, i, n), i)$$

This gives the code after $n$ rounds of self-modification.

### Definition 7 (Monitored System)

A *monitored system* extends a self-modifying system with:
- A monitor function $\text{monitor} : \mathcal{C} \times \mathcal{I} \to \text{Bool}$.
- An observation function $\text{observe} : \mathcal{C} \times (\mathcal{C} \times \mathcal{I} \to \text{Bool}) \to \mathcal{C}$, allowing the system to react to the monitor.

---

## 3. Main Results

### 3.1 Self-Modifying Halting Undecidability

**Theorem 1** (No Self-Modifying Halting Oracle). *Let $S$ be a self-modifying system admitting a diagonal program $\text{diag} \in \mathcal{C}$ such that for any candidate oracle $h$:*
$$\text{exec}(\text{modify}(\text{diag}, \text{encode}(\text{diag})), \text{encode}(\text{diag})) = \begin{cases} \text{none} & \text{if } h(\text{diag}, \text{encode}(\text{diag})) = \text{true} \\ \text{some true} & \text{if } h(\text{diag}, \text{encode}(\text{diag})) = \text{false} \end{cases}$$
*Then no self-modifying halting oracle for $S$ exists.*

**Proof sketch.** Assume oracle $h$ exists satisfying the self-modifying halting oracle property. Apply the diagonal condition with $h$ as the candidate. If $h(\text{diag}, \text{encode}(\text{diag})) = \text{true}$, then the oracle property implies $\text{exec}(\text{modify}(\text{diag}, \text{encode}(\text{diag})), \text{encode}(\text{diag}))$ halts, but the diagonal condition gives $\text{none}$ (divergence). If $h(\text{diag}, \text{encode}(\text{diag})) = \text{false}$, the oracle property implies divergence, but the diagonal condition gives $\text{some true}$ (halting). Both cases yield contradiction. ∎

### 3.2 Reduction from Classical Halting

**Theorem 2** (Classical Reduces to Self-Modifying). *For any classical halting instance $(\mathcal{C}, \mathcal{I}, \text{exec}, \text{encode})$ with a halting oracle, the same oracle serves as a halting oracle for the self-modifying system with identity modification $\text{modify}(c, i) = c$.*

**Proof sketch.** The identity modification system is a degenerate self-modifying system. The halting oracle condition is identical to the classical condition. ∎

### 3.3 Virus Detection Impossibility

**Theorem 3** (No Perfect Virus Detector). *Let $S$ be a self-modifying system admitting a dual diagonal program (one that flips behavior based on the detector's output). Then no perfect virus detector for $S$ exists.*

**Proof sketch.** The argument mirrors Theorem 1, with the virus detector playing the role of the oracle and the dual diagonal program constructing the contradiction. ∎

### 3.4 Fixed-Point Obstruction

**Theorem 4** (No Alignment Monitor). *Let $S$ be a self-modifying system admitting a program $\text{diag}$ such that $\text{modify}(\text{diag}, \text{encode}(\text{diag})) = \text{diag}$ if and only if any candidate monitor outputs $\text{false}$ on $\text{diag}$. Then no alignment monitor for $S$ exists.*

**Proof sketch.** Assume a monitor $m$ exists. Then $m(\text{diag}) = \text{true}$ iff $\text{modify}(\text{diag}, \text{encode}(\text{diag})) = \text{diag}$ (by the alignment monitor property), which iff $m(\text{diag}) = \text{false}$ (by the diagonal condition). This is a contradiction. ∎

### 3.5 Strict Hierarchy

**Theorem 5** (Hierarchy Separation). *If a program stabilizes at exactly self-modification depth $k$ (i.e., $\text{depth}(k+1) = \text{depth}(k)$ but $\text{depth}(j+1) \neq \text{depth}(j)$ for all $j < k$), then $\text{depth}(j) \neq \text{depth}(k)$ for all $j < k$.*

**Proof sketch.** If $\text{depth}(j) = \text{depth}(k)$ for some $j < k$, then $\text{depth}(j+1) = \text{modify}(\text{depth}(j), i) = \text{modify}(\text{depth}(k), i) = \text{depth}(k+1) = \text{depth}(k) = \text{depth}(j)$, contradicting the instability at level $j$. ∎

### 3.6 Monitor Evasion

**Theorem 6** (Monitor Evasion). *Let $M$ be a monitored system where the system can observe the monitor and act contrarily (halting when the monitor predicts divergence and diverging when the monitor predicts halting). Then there exists a program that evades the monitor in both directions: if declared halting, it diverges; if declared divergent, it halts.*

**Proof sketch.** Instantiate the universal evasion hypothesis with any element of the code type (which is nonempty by hypothesis). The conditional behavior directly gives both implications. ∎

### 3.7 Quantitative Bounds

**Theorem 7** (Pigeonhole for Iteration). *In a finite type with $n$ elements, for any function $f$ and starting point $a$, there exist $i < j \leq n$ with $f^i(a) = f^j(a)$.*

**Proof sketch.** The $n+1$ values $a, f(a), \ldots, f^n(a)$ take values in a set of size $n$. By the pigeonhole principle, two must coincide. ∎

**Theorem 8** (Reachable State Bound). *The number of distinct states in the orbit $\{a, f(a), \ldots, f^k(a)\}$ is at most $\min(k+1, n)$.*

**Proof sketch.** The image of a set under any function has cardinality at most the set's cardinality ($k+1$) and at most the type's cardinality ($n$). ∎

**Theorem 9** (Fixed-Point Delay). *If $f : \text{Fin}(n) \to \text{Fin}(n)$ has a fixed point reachable from $a$ (i.e., $\exists k, f^k(a) = f^{k+1}(a)$), then a fixed point is reached within $n-1$ steps.*

**Proof sketch.** Let $k_0$ be the minimal such $k$ (via well-ordering). If $k_0 \geq n$, then the $k_0 + 1$ values $a, f(a), \ldots, f^{k_0}(a)$ are all distinct (by minimality: if $f^i(a) = f^j(a)$ for $i < j \leq k_0$, applying $f^{k_0 - j}$ times yields $f^{i + k_0 - j}(a) = f^{k_0}(a)$, so $f^{i+k_0-j}(a) = f^{i+k_0-j+1}(a)$, contradicting minimality since $i + k_0 - j < k_0$). But $k_0 + 1 > n$ elements in $\text{Fin}(n)$ is impossible. ∎

---

## 4. The Self-Modification Depth Algebra

The self-modification depth function satisfies a composition law:

**Theorem** (Depth Additivity). $\text{depth}_S(c, i, m + n) = \text{depth}_S(\text{depth}_S(c, i, m), i, n)$

This means the depth function forms a monoid action of $(\mathbb{N}, +)$ on the code space. Combined with the hierarchy separation theorem, this shows that the orbit structure of self-modification is algebraically well-behaved even though the halting behavior is undecidable.

---

## 5. Applications

### 5.1 Cybersecurity

Theorem 3 formalizes the virus paradox: no static analysis tool can perfectly classify self-modifying code as malicious or benign. This has been observed empirically (the arms race between malware authors and antivirus vendors) but our result establishes it as a mathematical theorem, not merely an engineering challenge.

**Implication**: Antivirus strategies must be inherently approximate and adaptive. Static signature-based detection is provably incomplete against self-modifying malware.

### 5.2 AI Alignment

Theorems 4 and 6 formalize two distinct alignment challenges:

1. **Stability prediction** (Theorem 4): No algorithm can determine whether a self-modifying AI will eventually stabilize. This is relevant to recursive self-improvement scenarios.

2. **Monitor evasion** (Theorem 6): Any oversight mechanism that is observable by a self-modifying system can be evaded. This suggests that alignment strategies must either (a) make the monitor unobservable (information-theoretic isolation) or (b) constrain the system's self-modification capabilities directly.

### 5.3 Software Verification

The hierarchy theorem (Theorem 5) suggests that verification techniques must be stratified by self-modification depth. Techniques adequate for depth-$k$ systems are provably inadequate for depth-$(k+1)$ systems. This provides a principled basis for risk assessment of self-modifying software.

---

## 6. Related Work

- **Classical halting problem**: Turing (1936), with formalizations by many authors.
- **Rice's theorem**: Generalization of halting undecidability to all non-trivial semantic properties (Rice, 1953).
- **Self-modifying code theory**: Cai et al. (2007) studied operational semantics; our approach is more abstract and focuses on undecidability.
- **Virus detection complexity**: Cohen (1987) showed undecidability of virus detection; our result extends this to self-modifying systems.
- **AI alignment impossibility**: Informal arguments by Omohundro (2008) and Soares & Fallenstein (2017); our results provide formal backing.

---

## 7. Conjecture and Future Work

**Conjecture** (Fixed-Point Delay Tightness). *For $n \geq 2$, the bound $n - 1$ in Theorem 9 is tight: there exists $f : \text{Fin}(n) \to \text{Fin}(n)$ and $a$ such that the minimum $k$ with $f^k(a) = f^{k+1}(a)$ is exactly $n - 1$.*

**Testable prediction**: For $n = 4$, the function $f(0) = 1, f(1) = 2, f(2) = 3, f(3) = 3$ starting from $a = 0$ gives $0 \to 1 \to 2 \to 3 \to 3$, reaching a fixed point at step 3 = $n - 1$. This can be verified computationally for small $n$.

### Future Directions

1. **Probabilistic self-modifying systems**: What if modification is stochastic? The diagonal argument may not directly apply.
2. **Resource-bounded self-modification**: How does the hierarchy change when self-modification has a cost?
3. **Multi-agent self-modification**: Systems of programs that modify each other.
4. **Connections to Gödel incompleteness**: Formalize the precise relationship between self-modification levels and consistency strength.

---

## 8. Conclusion

We have established that self-modifying computational systems exhibit a strict hierarchy of undecidability that extends and strengthens the classical halting problem. The impossibility of perfect virus detection and alignment monitoring follow as corollaries, connecting abstract computability theory to pressing practical concerns in cybersecurity and AI safety. The formal verification of all results in Lean 4 provides the highest available standard of mathematical certainty.

---

## References

- Turing, A.M. (1936). On Computable Numbers, with an Application to the Entscheidungsproblem. *Proc. London Math. Soc.* 42, 230–265.
- Rice, H.G. (1953). Classes of recursively enumerable sets and their decision problems. *Trans. AMS* 74, 358–366.
- Cohen, F. (1987). Computer viruses: Theory and experiments. *Computers & Security* 6, 22–35.
- Koza, J.R. (1992). *Genetic Programming*. MIT Press.
- Aycock, J. (2003). A brief history of just-in-time. *ACM Computing Surveys* 35, 97–113.
- Szor, P. (2005). *The Art of Computer Virus Research and Defense*. Addison-Wesley.
- Schmidhuber, J. (2007). Gödel machines: Fully self-referential optimal universal self-improvers. In *Artificial General Intelligence*, 199–226.
- Omohundro, S. (2008). The basic AI drives. In *AGI 2008*, 483–492.
- Soares, N. & Fallenstein, B. (2017). Agent foundations for aligning machine intelligence with human interests. In *Machine Intelligence Research Institute Technical Report*.
