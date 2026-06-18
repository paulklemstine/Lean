# Future Directions: Falsifiable Hypotheses and Conjectures

## Conjecture 1: Tropical Data Processing Inequality

**Precise Statement.** For any functions f : α → β and g : β → γ between finite types:

$$L_{\text{trop}}(g \circ f) \leq L_{\text{trop}}(f) + L_{\text{trop}}(g)$$

That is, tropical entropy loss is subadditive under composition.

**Test.** Formalize `tropicalEntropyLoss (g ∘ f) ≤ tropicalEntropyLoss f + tropicalEntropyLoss g` in Lean 4 and attempt a proof. A disproof would require exhibiting concrete finite functions f, g where the inequality fails. Test computationally on all functions {0,1}³ → {0,1}² → {0,1}.

**Impact.** If true, this would establish tropical entropy loss as a well-behaved information measure with its own data processing inequality, founding a complete "tropical information theory." If false, it would identify a fundamental asymmetry between Shannon and tropical frameworks.

---

## Conjecture 2: Complete Characterization of Shannon–Tropical Equality

**Precise Statement.** For a function f : α → β between finite nonempty types with uniform input:

$$\Delta H(f) = L_{\text{trop}}(f) \quad \iff \quad f \text{ has constant fibers}$$

The forward direction (constant fibers ⟹ equality) is proved in our Theorem 3.6. The conjecture is that the converse also holds: if Shannon equals tropical, then all nonempty fibers must have equal cardinality.

**Test.** Formalize the converse in Lean 4: `entropyDefectFn f = tropicalEntropyLoss f → HasConstantFibers f`. Alternatively, find a non-constant-fiber function where Shannon = tropical (which would disprove the conjecture). Test computationally on all functions from Fin 6 → Fin 4.

**Impact.** If true, this would give a clean characterization theorem: "Shannon and tropical semantics agree if and only if the computation is democratically irreversible (all inputs are equally expendable)." This would identify constant-fiber maps as the canonical class for tropical information theory.

---

## Conjecture 3: Quantum Stabilizer Entropy Law

**Precise Statement.** For a quantum stabilizer code [[n, k, d]] over GF(q), the entropy of the syndrome extraction map (projecting onto the code space) equals exactly (n − k) · log q, where the entropy is computed with respect to the uniform distribution on all n-qudit states.

More precisely: the syndrome map S : GF(q)^n → GF(q)^(n-k) defined by the parity check matrix H has entropy defect dim(ker H) · log q = k · log q.

**Test.** Formalize the stabilizer code syndrome map as a linear map over GF(q) and instantiate Theorem 3.3. The key challenge is connecting the quantum stabilizer formalism to the finite-field linear algebra framework. Verify computationally for the [[7,1,3]] Steane code over GF(2).

**Impact.** If established, this would extend the algebraic Landauer principle to quantum error correction, providing exact entropy costs for quantum syndrome measurement. It would connect our framework to quantum resource theories and potentially give new lower bounds on the physical cost of quantum error correction.

---

## Conjecture 4: Tropical Entropy Loss is Monotone Under Injective Post-Processing

**Precise Statement.** For f : α → β and an injection ι : β ↪ γ:

$$L_{\text{trop}}(\iota \circ f) = L_{\text{trop}}(f)$$

More generally, for any g : β → γ:

$$L_{\text{trop}}(g \circ f) \leq L_{\text{trop}}(f) \cdot L_{\text{trop}}(g)$$

Wait — this should be additive (in log scale), not multiplicative. Reformulating:

For any g : β → γ, and y ∈ range(g):
$$\max_{z \in \text{range}(g \circ f)} |(g \circ f)^{-1}(z)| \leq \max_{y \in \text{range}(f)} |f^{-1}(y)| \cdot \max_{z \in \text{range}(g)} |g^{-1}(z)|$$

Hence: $L_{\text{trop}}(g \circ f) \leq L_{\text{trop}}(f) + L_{\text{trop}}(g)$.

**Test.** This is essentially Conjecture 1. The inequality follows from the fact that $(g \circ f)^{-1}(z) = \bigcup_{y \in g^{-1}(z)} f^{-1}(y)$, so $|(g \circ f)^{-1}(z)| \leq |g^{-1}(z)| \cdot \max_y |f^{-1}(y)|$. Formalize this argument in Lean.

**Impact.** This would prove Conjecture 1 and give tropical entropy its data processing inequality. The proof strategy is clear (fiber decomposition), making this a strong candidate for the next formalization target.

---

## Conjecture 5: Fiber Entropy Determines Circuit Complexity

**Precise Statement.** For a Boolean function f : {0,1}^n → {0,1}^m, define the *fiber entropy profile* as the multiset {log|f⁻¹(y)| : y ∈ range(f)}. Then the minimum number of ancilla bits needed for any reversible implementation of f is:

$$\text{ancilla}(f) \geq \lceil \log_2(\max_{y} |f^{-1}(y)|) \rceil$$

Furthermore, this bound is tight: there exists a reversible implementation achieving it.

**Test.** The lower bound should follow from the fact that the reversible map must be injective, so distinct elements of a fiber must map to distinct ancilla values. Formalize in Lean. For tightness, construct explicit reversible implementations for small Boolean functions (e.g., all functions on 3 bits) and verify computationally that the bound is achieved.

**Impact.** If true (both bound and tightness), this would give a complete characterization of ancilla complexity in terms of fiber geometry. It would provide circuit designers with an exact formula for the minimum overhead of reversible implementation, with direct applications to quantum circuit synthesis where ancilla minimization is critical for reducing qubit count.

---

## Priority Ranking

1. **Conjecture 4** (Tropical DPI via fiber decomposition) — Most likely to succeed; clear proof strategy.
2. **Conjecture 2** (Shannon–Tropical characterization) — High impact; the forward direction is already proved.
3. **Conjecture 5** (Fiber complexity = ancilla count) — Most practically useful; connects to circuit design.
4. **Conjecture 3** (Quantum stabilizer extension) — Highest theoretical impact but requires quantum formalism.
5. **Conjecture 1** (General tropical DPI) — Subsumed by Conjecture 4 if that proof strategy works.
