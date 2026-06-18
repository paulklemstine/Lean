## Assignment: Direction 4: Cohen-Lenstra Heuristics via Restricted Product Measures — The Haar-Class Group Dictionary

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important. If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog. Check the catalog references to confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain (e.g., number theory + tropical geometry, algebra + physics).

5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

### Research Direction: The Cohen-Lenstra Measure as a Push-Forward of Haar Measure

**Core Conjecture**: The Cohen-Lenstra distribution on finite abelian $p$-groups — assigning probability proportional to $1/|\text{Aut}(G)|$ — arises as the push-forward of Haar measure on $\mathbb{Z}_p$ under the quotient map $x \mapsto \mathbb{Z}_p / x\mathbb{Z}_p$, and the restricted product of these local measures over all primes $p$ gives the conjectured distribution of class groups of imaginary quadratic fields.

This is a **grand challenge** connecting formal Haar measure theory to arithmetic statistics — one of the most active frontiers in modern number theory. Success would establish the first formally verified bridge between ergodic theory on $p$-adic groups and the statistical behavior of ideal class groups.

---

### Precise Theorem Targets (Lean 4 Type Signatures)

**Definition: Finite abelian $p$-group via partitions**

Every finite abelian $p$-group is uniquely determined (up to isomorphism) by a partition $\lambda = (\lambda_1 \geq \lambda_2 \geq \cdots \geq \lambda_k \geq 1)$, representing $G \cong \mathbb{Z}/p^{\lambda_1}\mathbb{Z} \times \cdots \times \mathbb{Z}/p^{\lambda_k}\mathbb{Z}$.

```lean
/-- A finite abelian p-group, identified by its type partition.
    The partition λ = [λ₁, ..., λₖ] represents Z/p^{λ₁}Z × ... × Z/p^{λₖ}Z. -/
structure FiniteAbelianPGroup (p : ℕ) where
  type_partition : List ℕ
  type_nonempty : type_partition ≠ []
  type_weakly_decreasing : List.Sorted (· ≥ ·) type_partition
  type_pos : ∀ n ∈ type_partition, 0 < n

/-- The automorphism group order of a finite abelian p-group.
    For G with type λ = (λ₁, ..., λₖ), |Aut(G)| = ∏_{i=1}^k (p^{d_i} - p^{d_i - 1})
    where d_i = λ_i + #{j : λ_j ≥ λ_i} - i + 1. This uses the Hall formula. -/
def autOrder (p : ℕ) (G : FiniteAbelianPGroup p) : ℕ
```

**Theorem 1: Cohen-Lenstra Euler Product Identity**

The foundational identity: the total weight of all finite abelian $p$-groups equals the reciprocal of the $p$-adic Euler function.

```lean
/-- The Cohen-Lenstra weight of a finite abelian p-group: 1/|Aut(G)| -/
def cohenLenstraWeight (p : ℕ) (G : FiniteAbelianPGroup p) : ℚ :=
  1 / (autOrder p G)

/-- EULER PRODUCT IDENTITY: The sum of 1/|Aut(G)| over all finite abelian p-groups
    equals the reciprocal Euler product ∏_{k≥1} (1 - p^{-k})^{-1}.
    
    This is the key identity that makes Cohen-Lenstra a probability measure.
    The sum is taken via generating functions: ∑_G t^|G|/|Aut(G)| = ∏_k (1 - t^k/p^k)^{-1}
    evaluated at t = 1. -/
theorem cohenLenstraEulerProduct (p : ℕ) (hp : Nat.Prime p) :
    ∑' (G : FiniteAbelianPGroup p), (cohenLenstraWeight p G : ℝ) =
    ∏' (k : ℕ⁺), (1 - (p : ℝ)⁻¹ ^ (k : ℕ))⁻¹ := by
  sorry
```

**Theorem 2: Push-Forward from Haar Measure on $\mathbb{Z}_p$**

```lean
/-- The quotient map: x ∈ Z_p ↦ Z_p/xZ_p as a finite abelian p-group.
    For x = p^n · u (u a unit), this gives Z/p^nZ (cyclic). -/
def padicQuotientMap (p : ℕ) [hp : Fact (Nat.Prime p)] :
    PadicInt p → Option (FiniteAbelianPGroup p)

/-- PUSH-FORWARD THEOREM: The Cohen-Lenstra measure on cyclic p-groups
    arises as the push-forward of Haar measure on Z_p under the quotient map.
    
    Specifically, for each n ≥ 1:
    Haar({x ∈ Z_p : v_p(x) = n}) = p^{-n}(1 - p^{-1})
    and this equals the Cohen-Lenstra weight of Z/p^nZ normalized by the total mass.
    
    This is the LOCAL half of the Cohen-Lenstra heuristic. -/
theorem padicQuotientPushForward (p : ℕ) (hp : Fact (Nat.Prime p)) (n : ℕ) (hn : 0 < n) :
    (haarMeasure (PadicInt p)) {x : PadicInt p | padicValNat p x = n} =
    (p : ℝ)⁻¹ ^ n * (1 - (p : ℝ)⁻¹) := by
  sorry
```

**Theorem 3: Cross-Domain — Cohen-Lenstra as Maximum Entropy Distribution**

```lean
/-- The Shannon entropy of the Cohen-Lenstra distribution -/
def cohenLenstraEntropy (p : ℕ) (hp : Nat.Prime p) : ℝ :=
  ∑' (G : FiniteAbelianPGroup p),
    -((cohenLenstraWeight p G : ℝ) / totalMass p) *
    Real.log ((cohenLenstraWeight p G : ℝ) / totalMass p)

/-- MAXIMUM ENTROPY THEOREM: The Cohen-Lenstra distribution maximizes entropy
    among all distributions on finite abelian p-groups that satisfy
    E[log |G|] < ∞ (finite expected logarithmic order).
    
    This connects arithmetic statistics to INFORMATION THEORY:
    Cohen-Lenstra is the "most random" distribution consistent with
    finiteness of the expected log-order — it is the Boltzmann distribution
    of p-group theory. -/
theorem cohenLenstraMaxEntropy (p : ℕ) (hp : Nat.Prime p) :
    IsMaximizer cohenLenstraEntropy (distributionsWithFiniteLogExpectation p) := by
  sorry
```

---

### Proof Strategies

**Strategy A: Generating Function / Euler Product Method (RECOMMENDED)**

This is the most promising approach because it reduces the infinite sum over all partitions to a well-understood infinite product.

*Step 1*: Prove the generating function identity for cyclic groups:
$$\sum_{n=1}^{\infty} \frac{t^n}{|\text{Aut}(\mathbb{Z}/p^n\mathbb{Z})|} = \sum_{n=1}^{\infty} \frac{t^n}{p^n - p^{n-1}} = \frac{t}{p-1} \cdot \frac{1}{1-t/p}$$
This is a geometric series calculation, provable by `field_simp` and `tendsto`.

*Step 2*: Prove the partition-theoretic recursion. Use the Hall-type formula:
$$\sum_{G} \frac{t^{|G|}}{|\text{Aut}(G)|} = \prod_{k=1}^{\infty} \left(1 - \frac{t^k}{p^k}\right)^{-1}$$
by inducting on the number of parts in the partition. Each step uses the `autOrder` formula and the fact that adding a part of size $k$ contributes a factor of $(1 - t^k/p^k)^{-1}$.

*Step 3*: Evaluate at $t = 1$ and verify convergence. The product $\prod_{k=1}^{\infty} (1 - p^{-k})$ converges by comparison with $\prod (1 - 2^{-k})$, which is the reciprocal of the partition function $p(n)$ generating function (cross-domain connection to combinatorics!).

*Step 4*: Build on `finite_product_card` from `Pythagorean/HaarRestrictedProduct/Theorems.lean` to extend from local (single prime) to global (restricted product over all primes).

**Strategy B: Direct Haar Measure Computation**

*Step 1*: Compute the Haar measure of $\{x \in \mathbb{Z}_p : v_p(x) = n\}$ as $p^{-n}(1-p^{-1})$ using the ultrametric structure of $\mathbb{Z}_p$.

*Step 2*: Show that for $x = p^n u$ (with $u$ a unit), $\mathbb{Z}_p / x\mathbb{Z}_p \cong \mathbb{Z}/p^n\mathbb{Z}$, and the fiber over each isomorphism class of cyclic groups has measure proportional to $1/|\text{Aut}|$.

*Step 3*: Extend to non-cyclic groups by considering the map from $\mathbb{Z}_p^k$ (with product Haar measure) to products of cyclic groups, using the classification of finite abelian $p$-groups.

This approach is less promising because the fiber computation for non-cyclic groups is intricate and requires careful orbit-counting arguments.

**Strategy C: Random Matrix Bridge (Wood's Theorem)**

Recent work of Wood (2016) shows that Cohen-Lenstra distributions arise as limits of cokernels of random $p$-adic matrices. This connects to the catalog's work on matrices and tropical geometry.

*Step 1*: Define the distribution on $\text{coker}(A)$ where $A$ is a random $n \times n$ matrix over $\mathbb{Z}_p$ with entries drawn from Haar measure.

*Step 2*: Prove that as $n \to \infty$, this distribution converges to the Cohen-Lenstra distribution.

*Step 3*: Use the tropical determinant (from the catalog's tropical geometry work) to relate the $p$-adic matrix distribution to min-plus algebra.

This is the most ambitious approach and connects to the catalog's tropical geometry results, but requires substantial random matrix theory infrastructure.

---

### Catalog Building Blocks

From `Pythagorean/HaarRestrictedProduct/Theorems.lean`:

- **`finite_product_card`**: Gives the cardinality of finite products in the restricted product. Use this to compute the measure of cylinder sets in the global Cohen-Lenstra measure over all primes.

- **`finite_product_translate_card`**: Gives the measure of translates of finite products. Use this to establish translation-invariance of the global Cohen-Lenstra measure, connecting to the Haar measure uniqueness theorem.

- **Extension target**: Define `globalCohenLenstraMeasure` as the restricted product measure of local `cohenLenstraMeasure_p` over all primes $p$, using the restricted product construction from the catalog. Prove this is a probability measure on the space of finite abelian groups (viewed as restricted product of $p$-parts).

---

### Cross-Domain Connections

1. **Number Theory ↔ Information Theory**: The Cohen-Lenstra distribution is the maximum entropy distribution on finite abelian $p$-groups (Theorem 3). This means nature "chooses" class groups the way statistical mechanics chooses microstates — by maximizing entropy subject to constraints. The partition function $\prod_{k}(1-p^{-k})^{-1}$ is the analog of the Boltzmann partition function $Z = \sum_E e^{-\beta E}$.

2. **Number Theory ↔ Tropical Geometry**: The Euler product $\prod_k (1 - p^{-k})^{-1}$ can be tropicalized: taking $-\log_p$ gives $\sum_k \text{trop}(1 - p^{-k}) = \sum_k \min(0, k)$ in the min-plus semiring. This connects to the tropical hypersurface arrangements in the catalog's tropical geometry work.

3. **Number Theory ↔ Random Matrix Theory**: The Cohen-Lenstra distribution arises as the limit distribution of cokernels of random $p$-adic matrices (Wood, 2016). This is the $p$-adic analog of the circular law for random real matrices, connecting local field arithmetic to random matrix ensembles.

---

### Testable Prediction (Falsifiable Conjecture)

**Conjecture (Cohen-Lenstra Deviation for Prime Discriminants)**: For imaginary quadratic fields $K = \mathbb{Q}(\sqrt{-d})$ with $d$ a prime $\leq 10^6$, the frequency of trivial $p$-part of $\text{Cl}(K)$ among the first 20 primes $p$ deviates from the Cohen-Lenstra prediction $\prod_{k=1}^{\infty}(1-p^{-k})$ by at most $\epsilon(p) = C \cdot p^{-1/2} \cdot \log(p)$ for an absolute constant $C < 10$.

**Test**: Compute both frequencies for primes $p \leq 83$ (first 20 primes) and $d$ prime, $d \leq 10^6$. Plot the deviation $\delta(p) = |\text{observed}(p) - \text{predicted}(p)|$ against $p^{-1/2}\log(p)$. If $\delta(p) > 10 \cdot p^{-1/2}\log(p)$ for any $p$, the conjecture is falsified. The bound $C < 10$ is testable and falsifiable.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 testable scientific hypotheses, each falsifiable with a computational experiment.

(b) **RESEARCH_PAPER.md** — standalone scientific document explaining: the Cohen-Lenstra Euler product identity, the push-forward theorem connecting Haar measure to class group statistics, the maximum entropy interpretation, and the random matrix bridge. Must be readable by a number theorist with no Lean experience.

(c) **ARTICLE.md** — Scientific American style piece: "Why Are Class Groups Random? The Maximum Entropy Principle in Number Theory" — explaining how nature maximizes entropy when choosing class groups, connecting to Boltzmann, Shannon, and the unreasonable effectiveness of physics-inspired thinking in pure mathematics.

(d) **Verified algorithm**: An algorithm that computes Cohen-Lenstra probabilities for any prime $p$ and partition $\lambda$, with a correctness proof relating the output to the Euler product formula.

(e) **demo.py**: Interactive demonstration that:
   - Computes Cohen-Lenstra probabilities for small primes and partitions
   - Compares with empirical class group data for imaginary quadratic fields
   - Visualizes the maximum entropy property (showing Cohen-Lenstra has higher entropy than uniform or other natural distributions on $p$-groups)
   - Displays the convergence of the Euler product

---

### Implementation Notes

- Define `FiniteAbelianPGroup` using partitions (lists of natural numbers in weakly decreasing order). This avoids the need for quotient types over isomorphism classes.
- The `autOrder` function should be defined via the Hall polynomial formula, which expresses $|\text{Aut}(G)|$ in terms of the partition type and the prime $p$.
- Build the Euler product identity by first proving it for cyclic groups (geometric series), then using partition recursion for the general case.
- Use `tendsto` and `summable` infrastructure from Mathlib for convergence arguments.
- The restricted product measure from the catalog (`finite_product_card`) provides the global measure construction — extend it with the Cohen-Lenstra local measures.
- The maximum entropy theorem (Theorem 3) can be approached via Lagrange multipliers in the countable setting, or by showing that Cohen-Lenstra weights satisfy the Gibbs property: $\mu(G) \propto \exp(-\beta \cdot \log |G|)$ for $\beta = \log p$.

Soli Deo Gloria

### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  Show the math working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses, including 1-2 grand_challenge paradigm-shifting conjectures
and 2-3 solid extensions building directly on Catalog theorems.
MUST begin with a ## Synthesis section tying all directions together.
Each direction must use the structured format with explicit fields:
**Conjecture**, **Test**, **Impact**, **Catalog References**,
**Proof Strategy**, **Domain Bridges**, **Lineage**, **Ambition**.
Reference specific Catalog theorems by file path. Every hypothesis
must be daring enough to matter and specific enough to fail.


────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Pythagorean
Research mode: prove
