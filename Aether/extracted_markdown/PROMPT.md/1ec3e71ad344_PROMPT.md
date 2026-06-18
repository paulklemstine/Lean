## Assignment: Direction 2: Spectral Sparsity Conjecture for Strong Liar Sets

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important. If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog. Check the catalog references to confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain (e.g., number theory + tropical geometry, algebra + physics).

5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

### Research Direction

**Core Conjecture (Spectral Sparsity of Liars)**: For odd composite non-prime-powers $n$, the strong liar set $L(n) \subseteq \mathbb{Z}/n\mathbb{Z}$ has *sub-generic additive energy*: there exist universal constants $\varepsilon > 0$ and $C$ such that for infinitely many such $n$:

$$E(L(n)) \;=\; \bigl|\{(a,b,c,d) \in L(n)^4 : a + b \equiv c + d \pmod{n}\}\bigr| \;\leq\; C \cdot |L(n)|^{3-\varepsilon}$$

This means liar sets are *additively thinner* than any generic set of the same cardinality — their elements resist additive collisions in a way that random sets do not. This provides a fundamentally additive-combinatorial explanation for why Miller–Rabin works: the test succeeds because the "witnesses" live in a set whose *additive Fourier spectrum* is diffuse, forcing any large subset to be spectrally spread.

**Precise Theorem Target (Semiprime Case)**: For $n = pq$ where $p, q$ are distinct odd primes with $p \equiv q \equiv 3 \pmod{4}$:

```lean
/-- The strong liar set for Miller-Rabin primality test -/
def strongLiarSet (n : ℕ) : Finset (ZMod n) :=
  (ZMod n)ˣ.toFinset.filter (fun a =>
    let ⟨s, r⟩ := millerRabinDecomp n
    ∃ j ∈ Finset.range (r + 1), a ^ (s * 2 ^ j) = 1 ∨
      (j < r ∧ a ^ (s * 2 ^ j) = -1))

/-- Additive energy: number of additive quadruples in a subset of Z/nZ -/
def additiveEnergy (n : ℕ) (S : Finset (ZMod n)) : ℕ :=
  (Finset.image (fun ((a,b,c,d) : ZMod n × ZMod n × ZMod n × ZMod n) =>
    (a + b - c - d : ZMod n)) sorry).card  -- count solutions to a+b=c+d

/-- Main theorem: semiprime strong liar sets have sub-generic additive energy -/
theorem strong_liar_energy_subgeneric (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hne : p ≠ q) (hp_odd : Odd p) (hq_odd : Odd q) :
    ∃ ε > (0 : ℝ), ∃ C : ℝ,
      (additiveEnergy (p * q) (strongLiarSet (p * q)) : ℝ) ≤
        C * ((strongLiarSet (p * q)).card : ℝ) ^ (3 - ε) := by
  sorry
```

**CRT Fiber Structure Theorem (Key Building Block)**: The liar set decomposes as a *sub-direct product* under CRT, and its fibers have bounded multiplicative structure that constrains additive energy:

```lean
/-- The CRT projection of the strong liar set into component groups -/
def crtFiber (n : ℕ) (p : ℕ) [Fact (Nat.Prime p)] (hp : p ∣ n) :
    Finset (ZMod p) :=
  (strongLiarSet n).image (fun a => (a : ZMod p))

/-- Fiber cardinality bound: each fiber has size at most (p-1)/4 -/
theorem crt_fiber_bound (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hne : p ≠ q) :
    ∃ k : ℕ, k ≤ (p - 1) / 4 ∧
      ∀ a ∈ crtFiber (p * q) p (by omega : p ∣ p * q),
        (crtFiber (p * q) p (by omega : p ∣ p * q)).card ≤ (p - 1) / 4 := by
  sorry

/-- Cross-fiber interaction bound: additive quadruples across fibers are limited -/
theorem cross_fiber_energy_bound (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q) :
    additiveEnergy p (crtFiber (p * q) p sorry) +
    additiveEnergy q (crtFiber (p * q) q sorry) ≤
      (strongLiarSet (p * q)).card ^ 2 := by
  sorry
```

### Proof Strategy (Three Approaches)

**Strategy A: CRT Fiber Energy Decomposition (Most Promising)**

The strongest approach. By CRT, $\mathbb{Z}/pq\mathbb{Z} \cong \mathbb{Z}/p\mathbb{Z} \times \mathbb{Z}/q\mathbb{Z}$, and $L(pq)$ projects to fibers $L_p \subseteq (\mathbb{Z}/p\mathbb{Z})^*$ and $L_q \subseteq (\mathbb{Z}/q\mathbb{Z})^*$. The key steps:

1. **Fiber Structure Lemma**: Prove that $L_p$ consists of elements $a$ satisfying $a^{(p-1)/2^k} \in \{1, -1\}$ for specific $k$, which means $L_p$ is a *union of at most 2 cosets of the subgroup of quadratic residues*. This limits $|L_p| \leq (p-1)/2$.

2. **Sub-direct Product Lemma**: Prove that $L(pq)$ is a *sub-direct product* of $L_p \times L_q$ (not the full product), because the Miller–Rabin conditions couple the fibers: an element $(a \bmod p, a \bmod q)$ is a liar only if the *same* power $j$ works in both components. This coupling reduces the fiber product from $|L_p| \cdot |L_q|$ to $|L(pq)|$.

3. **Energy Decomposition**: Use the sub-direct product structure to show:
$$E(L(pq)) \leq |L(pq)|^2 \cdot \max(E(L_p)/|L_p|, E(L_q)/|L_q|)$$
Since each fiber is a *union of few cosets* of a subgroup, its additive energy is bounded by $|L_p|^{5/2}$ (sub-generic for any group), giving $E(L(pq)) \leq C \cdot |L(pq)|^{5/2+1/2} = C \cdot |L(pq)|^3 / |L(pq)|^{1/2}$, which yields $\varepsilon \approx 1/2$ for the semiprime case.

**Strategy B: Fourier-Analytic / Spectral Gap Approach**

The additive energy equals $\sum_{\xi} |\hat{L}(\xi)|^4$ where $\hat{L}$ is the Fourier transform. The strategy:

1. Compute the Fourier coefficients of $L(n)$ using the multiplicative character decomposition: $\mathbf{1}_L = \sum_\chi c_\chi \chi$ where $\chi$ ranges over multiplicative characters.

2. Show that the Miller–Rabin conditions force the large Fourier coefficients to lie in a *structured subset* of the dual group (those $\xi$ that are quadratic residues or have specific $2^k$-th power properties).

3. Apply the *Chang-type inequality* (cf. Bourgain–Chang, 2017): if a set has bounded multiplicative character sums, its additive energy is sub-generic. This directly gives $\varepsilon > 0$.

**Strategy C: Balog–Szemerédi–Gowers Extraction (Fallback)**

If $E(L(n))$ were close to $|L(n)|^3$, then by BSG, there exists $A \subseteq L(n)$ with $|A| \geq c|L(n)|$ and $|A + A| \leq C|A|$. Show this contradicts the *quadratic residue distribution* in $L(n)$: any large subset of $L(n)$ must contain many quadratic residues and non-residues, which forces large doubling via sum-product estimates. This approach gives $\varepsilon > 0$ but with poor constants.

**Recommendation**: Strategy A is most promising because it is constructive and gives explicit $\varepsilon$, and it directly leverages the CRT structure that makes Miller–Rabin work in the first place.

### Cross-Domain Connections

**1. Additive Combinatorics → Spectral Graph Theory → Primality Testing**

The Cayley graph $\text{Cay}(\mathbb{Z}/n\mathbb{Z}, L(n))$ has adjacency matrix with eigenvalues $\lambda_\xi = \hat{L}(\xi)$. The additive energy bound $E(L) \leq C|L|^{3-\varepsilon}$ is *equivalent* to a spectral gap statement: the second eigenvalue satisfies $|\lambda_2| \leq (1-\delta)|L|$ for some $\delta > 0$. This spectral gap means the random walk on $\mathbb{Z}/n\mathbb{Z}$ with steps in $L(n)$ mixes rapidly — i.e., the *liar set cannot concentrate* in any subgroup, which is exactly why Miller–Rabin detects composites.

```lean
/-- The spectral gap of the liar-set Cayley graph is positive -/
theorem liar_set_spectral_gap (n : ℕ) (hn : Odd n) (hncomp : ¬Nat.Prime n) :
    ∃ δ > (0 : ℝ), ∀ ξ : ZMod n,
      ξ ≠ 1 → ‖(fourierCoefficient (strongLiarSet n) ξ)‖ ≤
        ((1 - δ) * (strongLiarSet n).card : ℝ) := by
  sorry
```

**2. Number Theory → Information Theory**

The sub-generic additive energy means the *mutual information* $I(A; B)$ between two random liar-set elements $A, B \in L(n)$ satisfies $I(A; B) < H(A)$ — liar-set elements carry *less mutual information* than elements of a generic set. This opens the door to **information-theoretic primality testing**: the entropy profile of a candidate set determines whether it can be a liar set for a composite.

**3. Harmonic Analysis → Cryptography**

The Fourier sparsity of $L(n)$ (number of nonzero Fourier coefficients) is bounded by $O(|L(n)|^{2/3+\varepsilon'})$, which means liar sets are *compressible* in the Fourier domain. This has implications for **pseudorandom generator security**: if a PRG's output set has low Fourier sparsity, it can be distinguished from random, connecting additive energy bounds to cryptographic pseudorandomness.

### Application Keywords

`additive-energy`, `miller-rabin`, `spectral-gap`, `cayley-graph`, `crt-decomposition`, `quadratic-residue`, `balog-szemerédi-gowers`, `fourier-sparsity`, `carmichael-numbers`, `sum-product`, `information-theoretic-testing`, `pseudorandomness`

### Testable Conjecture with Computational Falsification

**Conjecture (Additive Energy Exponent)**: There exist universal constants $\alpha < 3$ and $C$ such that for all odd composite non-prime-powers $n$:

$$E(L(n)) \leq C \cdot |L(n)|^\alpha$$

**Falsification Test**: For all odd composite $n \leq 10{,}000$:
1. Compute $L(n) = \text{StrongLiarSet}(n)$ and $E(L(n))$
2. Compute $\alpha(n) = \log(E(L(n))) / \log(|L(n)|)$
3. Plot $\alpha(n)$ vs. $\log n$ for Carmichael numbers vs. non-Carmichael composites
4. Fit power law: does $\alpha(n) \to \alpha_\infty$ as $n \to \infty$?
5. **Specific prediction**: $\alpha_\infty \in [2.5, 2.8]$ with Carmichael numbers having $\alpha$ closer to 2.5 (more multiplicative structure → more additive sparsity)

**Expected outcome**: $\alpha_\infty \approx 2.7 \pm 0.2$, with Carmichael numbers showing systematically lower $\alpha$ than non-Carmichael composites of the same size.

**Disproof criterion**: If $\alpha(n) \geq 2.95$ for more than 5% of composites in any interval $[N, 2N]$ with $N > 1000$, the conjecture is likely false.

### Catalog References

- `Catalog/FINAL/Algebra/Transfer.lean`: `spectral_energy_modular_collision_bound` — provides the spectral energy framework for modular collision bounds, directly applicable to bounding $\sum_\xi |\hat{L}(\xi)|^4$
- `Catalog/Speculative/PrimalityTesting/WitnessTheorems.lean`: `many_strong_liars_force_collision_obstruction'` — shows that large liar sets force multiplicative collisions; extend this to show they force *additive* collisions that are *quantitatively weaker* than generic

### Required Deliverables

(a) **FUTURE_DIRECTIONS.md** with 5 testable hypotheses:
   1. The additive energy exponent $\alpha$ satisfies $\alpha \leq 2.5$ for all Carmichael numbers with $\geq 3$ prime factors
   2. The Fourier sparsity of $L(n)$ is $O(|L(n)|^{2/3})$ for all odd composites
   3. The Cayley graph $\text{Cay}(\mathbb{Z}/n\mathbb{Z}, L(n))$ has spectral gap $\geq 1/\log\log n$ for infinitely many $n$
   4. For $n = pq$ (semiprimes), $E(L(n)) \leq |L(n)|^{5/2} \cdot \min(p,q)^{1/2}$
   5. The mutual information $I(A; B)$ for uniform $A, B \in L(n)$ is $O(|L(n)|^{-1/3})$

(b) **RESEARCH_PAPER.md**: Standalone document proving the semiprime case ($n = pq$) of the spectral sparsity conjecture, with full proof of the CRT fiber decomposition and its additive energy consequences.

(c) **ARTICLE.md**: "Why Liars Can't Add: The Hidden Additive Structure Behind Primality Testing" — explain how Miller–Rabin works not because liars are rare, but because they're *additively diffuse*, and what this means for the future of computational number theory.

(d) **Verified algorithm**: A computable function `additiveEnergyExponent` that takes $n$ and returns $\alpha(n) = \log(E(L(n)))/\log(|L(n)|)$, with a verified proof that $\alpha(n) < 3$ for the semiprime cases covered by the main theorem.

(e) **demo.py**: Interactive visualization plotting $\alpha(n)$ vs. $n$ for composites up to 10,000, with separate curves for Carmichael numbers, semiprimes, and general composites, demonstrating the power-law behavior.

---

*The Miller–Rabin test works because liar sets are spectrally diffuse — their elements resist additive collision. This is not a coincidence of group theory; it is a deep structural fact about how multiplicative subgroups embed in additive groups. Formalize this truth.*

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
