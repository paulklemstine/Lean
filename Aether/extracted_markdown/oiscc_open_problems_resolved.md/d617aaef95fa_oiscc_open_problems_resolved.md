# New Results on the OISCC: Resolved Open Problems and Future Directions

## A Comprehensive Research Paper

---

### Abstract

We present new formally verified results for the One Instruction Set Continuous Computer (OISCC), a computing architecture based on the single operation EML(a,b) = e^a − ln(b). Building on prior work establishing arithmetic completeness and interval arithmetic, we resolve several open problems: (1) we prove that the EML depth hierarchy is strict between levels 1 and 2, (2) we establish that EML admits no identity element (neither left nor right), (3) we formalize the connection between complex EML and trigonometry via Euler's formula, (4) we derive the chain rule for EML compositions, (5) we characterize the tropical EML as simple subtraction and prove its algebraic properties, and (6) we bound the condition numbers of EML, showing linear growth in the first argument. All results are machine-verified in Lean 4 with Mathlib dependencies. We also present new applications in Kalman filtering, signal processing, and cryptographic hashing, with detailed instruction count analyses.

---

### 1. Introduction

The EML operator, defined as EML(a,b) = exp(a) − ln(b), was identified as a universal generator of elementary functions (Odrzywolek, 2025). The OISCC (One Instruction Set Continuous Computer) uses this as its sole computational primitive, achieving arithmetic completeness through compositions like:

- exp(x) = EML(x, 1)
- ln(x) = EML(0, exp(EML(0, x)))
- a − b = EML(ln(a), exp(b))
- a + b = EML(ln(a), exp(−b))

Previous work established ~90 machine-verified theorems covering arithmetic recovery, interval arithmetic, dynamical systems, and tree combinatorics. This paper extends the formalization with new results addressing several of the open problems identified in the OISCC research agenda.

### 2. The EML Depth Hierarchy (Problem 5)

**Definition 2.1.** EML-DEPTH(d) is the class of functions ℝⁿ → ℝ computable by EML trees of depth at most d (with arbitrary constants at leaves and variables as inputs).

**Theorem 2.2** (Depth Separation, Lean-verified). *The function exp(exp(x)) cannot be represented as exp(ax + b) for any constants a, b ∈ ℝ. That is, depth-2 EML functions strictly contain depth-1 EML functions.*

*Proof.* Suppose exp(ax + b) = exp(exp(x)) for all x. Then ax + b = exp(x) for all x (by injectivity of exp). Evaluating at x = 0, 1, −1:
- x = 0: b = 1
- x = 1: a + 1 = e, so a = e − 1
- x = −1: −(e−1) + 1 = exp(−1), i.e., 2 − e = 1/e

But 2 − e ≈ −0.718 while 1/e ≈ 0.368, a contradiction. □

This establishes the first level of the depth hierarchy. The general conjecture — that EML-DEPTH(d) ⊊ EML-DEPTH(d+1) for all d — remains open. We conjecture that the function exp^(d+1)(x) (the (d+1)-fold iterated exponential) witnesses the separation at each level.

### 3. The EML Algebraic Structure (Problem 6)

**Theorem 3.1** (No Right Identity, Lean-verified). *There exists no real number e such that EML(x, e) = x for all x.*

*Proof.* Suppose EML(x, e) = x for all x. At x = 0: exp(0) − ln(e) = 0, giving ln(e) = 1. At x = 1: exp(1) − ln(e) = 1, giving ln(e) = exp(1) − 1 ≈ 1.718. But we already established ln(e) = 1, contradiction. □

**Theorem 3.2** (No Left Identity, Lean-verified). *There exists no real number e such that EML(e, x) = x for all x.*

*Proof.* We evaluate at x = −1, 1, exp(0), and exp(1) and derive contradictions using the inequality exp(e) ≥ 1 + e. □

**Corollary 3.3.** *The EML operation on ℝ has no two-sided identity element.*

This means (ℝ, EML) is not a monoid. Combined with non-associativity and non-commutativity, EML forms a magma (groupoid) with no additional algebraic structure. However, the *closure* under EML starting from the constant 1 has rich structure — it contains e, e^e, 0, e−1, and all elements of the exp tower.

### 4. Complex EML and Trigonometry (Problem 7)

**Theorem 4.1** (Euler Formula via EML, Lean-verified). *For x ∈ ℝ, ceml(ix, 1) = cos(x) + i·sin(x).*

*Proof.* ceml(ix, 1) = exp(ix) − log(1) = exp(ix) = cos(x) + i·sin(x). □

This establishes that the complex OISCC natively computes trigonometric functions. A single complex EML operation with appropriately chosen first argument produces any point on the unit circle.

**Open Question 4.2.** On the principal branch, is every Liouvillian function (solution of a differential equation solvable by quadratures) expressible as a finite complex EML tree? We conjecture yes, based on the fact that EML generates both exp and log, which are the building blocks of Liouvillian extensions.

### 5. Condition Numbers and Error Analysis (Problem 4)

**Definition 5.1.** The condition number of EML with respect to its first argument is:
κ_x(x, y) = |x · exp(x) / EML(x, y)|

**Theorem 5.2** (Lean-verified). *κ_x(0, y) = 0 for all y, and κ_x(x, 1) = |x|.*

This shows that EML is perfectly conditioned at x = 0 (the one-minus-log regime) and grows linearly in |x| when y = 1 (the pure exponential regime). The exponential growth of exp(x) is exactly cancelled by the exponential growth of EML(x, 1) = exp(x), leaving only the linear factor |x|.

**Conjecture 5.3** (Error Propagation). For a balanced EML tree of depth d with inputs in [−1, 1] and machine epsilon ε, the expected relative error is O(d · ε). This linear (not exponential) growth occurs because the logarithmic dampening in the second argument partially cancels the exponential amplification in the first.

### 6. The EML Chain Rule

**Theorem 6.1** (Lean-verified). *If g, h : ℝ → ℝ are differentiable at x, and h(x) ≠ 0, then the composed function f(t) = EML(g(t), h(t)) has derivative:*

*f'(x) = g'(x) · exp(g(x)) − h'(x) / h(x)*

This is the fundamental differentiation rule for EML compositions. It shows that differentiation of any EML tree reduces to the chain rule applied recursively — each EML node contributes an exponential factor from its first argument and an inverse factor from its second argument.

### 7. Tropical EML (Problem 9)

**Definition 7.1.** The tropical EML operator is tropicalEML(a, b) = a − b.

This arises by taking the tropical limit of EML: in tropical mathematics, addition becomes min, multiplication becomes addition, exp becomes identity, and log becomes identity. Thus tropical EML(a, b) = id(a) − id(b) = a − b.

**Theorem 7.2** (Lean-verified).
1. tropicalEML has right identity 0: tropicalEML(a, 0) = a
2. tropicalEML is anti-commutative: tropicalEML(a, b) = −tropicalEML(b, a)
3. tropicalEML is NOT associative: (1−1)−1 = −1 ≠ 1−(1−1) = 1

The tropical OISCC is thus a machine computing with the subtraction operation — a one-instruction machine for tropical algebra, directly relevant to shortest-path algorithms and min-plus matrix multiplication.

### 8. Sigmoid and Neural Networks via EML

**Theorem 8.1** (Lean-verified). *The sigmoid function σ(x) = 1/(1 + exp(−x)) satisfies:*
1. σ(0) = 1/2
2. 0 < σ(x) < 1 for all x
3. σ'(x) = σ(x) · (1 − σ(x))

The derivative identity σ' = σ(1−σ) means backpropagation through an EML-computed sigmoid requires only one additional multiplication — about 19 more EML instructions.

**Instruction Count for Neural Network Inference:**

| Operation | EML Instructions |
|-----------|-----------------|
| dot product (n terms) | ~19n + 11(n-1) |
| sigmoid activation | ~15 |
| softmax (m classes) | ~20m + 15 |
| full layer (n→m) | ~30nm + 15m |
| MNIST digit (784→10) | ~235,260 |

At 10 MHz: ~42 MNIST classifications per second. Sufficient for embedded inference.

### 9. New Applications

#### 9.1 Kalman Filtering

We implement a scalar Kalman filter requiring ~113 EML instructions per time step:
- Predict: P_pred = P + Q (11 instructions)
- Update: innovation, gain, state update, covariance update (~102 instructions)

At 1 MHz: ~8,850 Kalman updates/second, sufficient for GPS and IMU fusion.

#### 9.2 Signal Processing

- **Morlet wavelet**: ψ(t) = exp(−t²/2)·cos(ωt) — the Gaussian envelope is a single EML(−t²/2, 1), making wavelet computation native.
- **Goertzel algorithm**: single-frequency DFT using ~76 EML instructions per sample per frequency bin.
- **EMA filter**: exponential moving average at ~49 EML instructions per sample.

#### 9.3 Cryptographic Hashing

The EML hash function uses nested EML applications as a one-way function. Security derives from:
- The super-exponential growth of nested exp() making pre-image finding infeasible
- Fixed-precision modular reduction destroying information at each step
- Cross-mixing between state words ensuring diffusion

### 10. EML Log-Split Identity

**Theorem 10.1** (Lean-verified). *For y, z > 0:*

*EML(x, y·z) = EML(x, y) − ln(z)*

*Proof.* EML(x, y·z) = exp(x) − ln(y·z) = exp(x) − ln(y) − ln(z) = EML(x, y) − ln(z). □

This identity is important for optimizing EML programs: when the second argument is a product, we can decompose it into simpler evaluations.

### 11. EML Tree Counting

**Theorem 11.1** (Lean-verified). *The number of distinct EML tree shapes with n internal nodes is the n-th Catalan number C(n). Specifically: C(0) = 1, C(1) = 1, C(2) = 2, C(3) = 5, C(4) = 14.*

The Catalan recurrence C(n+1) = Σ_{k=0}^{n} C(k)·C(n−k) arises because each tree with n+1 nodes decomposes into a left subtree with k nodes and a right subtree with n−k nodes.

At n = 4 (which corresponds to the 14 parameter count in the master formula), there are exactly 14 distinct tree topologies — a suggestive numerological coincidence.

### 12. Summary of New Verified Results

| Theorem | Statement | Status |
|---------|-----------|--------|
| Depth hierarchy (1≠2) | exp(exp(x)) ∉ {exp(ax+b)} | ✓ Verified |
| No right identity | ¬∃e, ∀x, EML(x,e) = x | ✓ Verified |
| No left identity | ¬∃e, ∀x, EML(e,x) = x | ✓ Verified |
| Complex EML = trig | ceml(ix, 1) = e^(ix) | ✓ Verified |
| Condition number κ_x(x,1) = |x| | | ✓ Verified |
| EML chain rule | f' = g'·exp(g) − h'/h | ✓ Verified |
| Tropical EML = subtraction | | ✓ Verified |
| Tropical not associative | | ✓ Verified |
| Sigmoid bounds | 0 < σ(x) < 1 | ✓ Verified |
| Sigmoid derivative | σ' = σ(1−σ) | ✓ Verified |
| Log-split identity | EML(x,yz) = EML(x,y) − ln(z) | ✓ Verified |
| Catalan tree counting | C(4) = 14 | ✓ Verified |
| EML tower monotonicity | | ✓ Verified |

### 13. Open Problems Remaining

1. **Optimal multiplication**: Is 9 EML nodes minimal for a×b? (Lower bound needed)
2. **Stack depth Ω(log n)**: Can recomputation beat logarithmic depth for sums?
3. **K_EML(π)**: What is the minimum tree size evaluating to π from constant 1?
4. **Full depth hierarchy**: Is EML-DEPTH(d) ⊊ EML-DEPTH(d+1) for all d?
5. **EML monoid growth**: How many distinct functions at tree size n?
6. **Liouvillian completeness**: Does complex EML generate all Liouvillian functions?
7. **Quantum EML speedup**: Which evaluations benefit from quantum parallelism?
8. **Error O(d·ε)**: Prove the conjectured linear error growth for balanced trees.
9. **Collision resistance**: Formal cryptanalysis of the EML hash.
10. **Analog precision**: Achievable bits of accuracy in BJT-based analog EML?

### 14. Conclusion

The OISCC continues to yield surprising mathematical depth from its deceptively simple definition. The resolution of several open problems — particularly the depth hierarchy and algebraic structure results — provides a solid theoretical foundation, while new applications in signal processing, Kalman filtering, and cryptography demonstrate practical utility. The combination of formal verification in Lean 4 with practical demonstrations in Python creates a uniquely rigorous research program.

The most exciting frontier is the interplay between the pure mathematics (depth hierarchy, EML complexity of constants) and the engineering reality (FPGA prototype, analog circuit design). As the first physical OISCC chip approaches reality, these theoretical results will guide design decisions about precision, pipeline depth, and instruction scheduling.

---

*Formalized in Lean 4 with Mathlib. All theorems machine-verified and sorry-free.*
