## Assignment: Conjecture 5: Model-Shrinkage Distance as a Proof-Complexity Invariant

**Mode:** `prove`

You are not being asked for a cosmetic formalization. You are being asked to carve out a new invariant at the interface of proof complexity, finite model theory, information theory, and combinatorial counting. The central vision is this:

> **A proof step that drastically shrinks the satisfying-model space must pay for that shrinkage in proof complexity.**

If true in any robust form, this would create a new entropy-like obstruction principle for propositional proofs, potentially opening an entirely new quantitative language for lower bounds. If false, then constructing a counterexample family would be equally valuable: it would identify a sharp separation between semantic information loss and syntactic proof cost. Either outcome is field-opening.

The current conjecture as stated for Resolution/Frege/Extended Frege is probably too ambitious to prove in full. Your mission is therefore to **formalize and prove the strongest nontrivial verified theorems that survive contact with Lean and mathematics**, while explicitly isolating the frontier conjecture and producing computational evidence.

---

## Core Mathematical Program

### New definitions to introduce
You must define at least one genuinely new concept. The following package is the right one.

Let `Var := Fin n`. A propositional formula on `n` variables may be represented first at the semantic level by its set of satisfying assignments:
- assignments are functions `σ : Fin n → Bool`
- a semantic theory is a finite set `S : Finset (Fin n → Bool)`

This is not the final notion of proof system, but it gives a rigorous finite combinatorial substrate on which exact theorems can be proved.

Define:

1. **Model-shrinkage distance**
   \[
   d(S,T) := \log_2 \frac{|S|}{|T|}
   \quad\text{for } T \subseteq S,\ T \neq \emptyset.
   \]
   In Lean, because exact real logarithms are awkward for finite combinatorics, also define the more proof-friendly integer version
   \[
   \Delta(S,T) := \Nat.log2 \left(\frac{|S|}{|T|}\right)
   \]
   when divisibility is available, or the monotone surrogate
   \[
   \Delta'(S,T) := \Nat.log2 |S| - \Nat.log2 |T|.
   \]

2. **Proof-system shrinkage profile**
   For a semantic proof system modeled as a sequence
   \[
   S_0 \supseteq S_1 \supseteq \cdots \supseteq S_k,
   \]
   define the one-step shrinkage cost and cumulative shrinkage:
   \[
   \mathrm{stepCost}(i) := \log_2\frac{|S_i|}{|S_{i+1}|},\qquad
   \mathrm{totalShrink} := \sum_i \mathrm{stepCost}(i).
   \]
   This packages a derivation as a filtration of model classes.

3. **Balanced shrinkage system**
   A system is `(C, α)`-balanced if every one-step derivation satisfies
   \[
   \log_2\frac{|S_i|}{|S_{i+1}|} \le C + \alpha \cdot \mathrm{localComplexity}(i),
   \]
   for a suitable local combinatorial complexity measure. This is the bridge from semantic shrinkage to proof length.

4. **Entropy deficiency**
   For `S ⊆ Assignments n`, define
   \[
   \mathrm{def}(S) := n - \log_2 |S|,
   \]
   so passing from `S` to `T ⊆ S` increases deficiency by exactly the model-shrinkage distance in the ideal power-of-two setting.

This reframes proof complexity as entropy accumulation.

---

## Precise theorem targets

You must prove **at least 3 substantial theorems**. At least one should be a cross-domain theorem connecting proof complexity semantics to information theory or combinatorics on the Boolean cube.

Below are the target statements. You may adjust technical hypotheses so they are true and Lean-feasible, but do not weaken them into trivialities.

---

### Theorem 1: Telescoping model-shrinkage identity
This is the semantic backbone of the entire program.

**Mathematical statement.**  
Let \(S_0 \supseteq S_1 \supseteq \cdots \supseteq S_k\) be nonempty finite sets of assignments, and suppose each ratio \(|S_i|/|S_{i+1}|\) is an exact power of two. Then
\[
\sum_{i=0}^{k-1} \log_2 \frac{|S_i|}{|S_{i+1}|}
= \log_2 \frac{|S_0|}{|S_k|}.
\]
More generally, without power-of-two hypotheses,
\[
\sum_{i=0}^{k-1} \big(\log_2 |S_i| - \log_2 |S_{i+1}|\big)
= \log_2 |S_0| - \log_2 |S_k|
\]
for the integer surrogate `Nat.log2`.

**Lean 4 type signature sketch**
```lean
theorem sum_log2_card_telescopes
  {α : Type} [DecidableEq α]
  (S : Fin (k+1) → Finset α)
  (hmono : ∀ i : Fin k, S i.succ ⊆ S i.castSucc)
  (hnonempty : ∀ i : Fin (k+1), (S i).Nonempty) :
  (∑ i : Fin k, (Nat.log2 ((S i.castSucc).card) - Nat.log2 ((S i.succ).card))) =
    Nat.log2 ((S 0).card) - Nat.log2 ((S (Fin.last k)).card)
```

A cleaner variant using lists or vectors is also acceptable.

**Why this matters.**  
This turns “proof length lower bounds from model shrinkage” into a telescoping-energy principle. Every meaningful lower bound will factor through this identity.

---

### Theorem 2: Coordinate restriction gives exact shrinkage
This is the first nontrivial family where the invariant is exact, not heuristic.

Let \(A_n := \{0,1\}^n\). For a set of coordinates \(I \subseteq \{1,\dots,n\}\) and a pattern \(b : I \to \{0,1\}\), define
\[
R(I,b) := \{\sigma \in A_n : \forall i \in I,\ \sigma(i)=b(i)\}.
\]
Then
\[
|R(I,b)| = 2^{n-|I|},
\qquad
d(A_n, R(I,b)) = |I|.
\]

**Lean 4 type signature sketch**
```lean
def restrictedAssignments (n : ℕ) (I : Finset (Fin n))
    (b : {i // i ∈ I} → Bool) : Finset (Fin n → Bool) := ...

theorem card_restrictedAssignments
  (n : ℕ) (I : Finset (Fin n))
  (b : {i // i ∈ I} → Bool) :
  (restrictedAssignments n I b).card = 2 ^ (n - I.card)

theorem shrinkage_of_coordinate_restriction
  (n : ℕ) (I : Finset (Fin n))
  (b : {i // i ∈ I} → Bool) :
  Nat.log2 ((Fintype.card (Fin n → Bool)) / (restrictedAssignments n I b).card) = I.card
```

You may need to phrase the second theorem using the already-proved first cardinality theorem plus `Fintype.card (Fin n → Bool) = 2^n`.

**Why this matters.**  
This gives the first exact calibration theorem: each forced variable contributes one bit of semantic proof burden. It is the atomic case of the conjectured invariant.

---

### Theorem 3: Entropy deficiency is monotone under implication
This is the semantic “information theory” theorem.

If \(T \subseteq S \subseteq A_n\), then
\[
\mathrm{def}(S) \le \mathrm{def}(T),
\]
with equality iff \(|S|=|T|\), hence \(S=T\) when \(T\subseteq S\).

**Lean 4 type signature sketch**
```lean
def deficiency (n : ℕ) (S : Finset (Fin n → Bool)) : ℕ :=
  n - Nat.log2 S.card

theorem deficiency_monotone
  {n : ℕ} {S T : Finset (Fin n → Bool)}
  (hTS : T ⊆ S) (hT : T.Nonempty) :
  deficiency n S ≤ deficiency n T

theorem deficiency_eq_iff_of_subset
  {n : ℕ} {S T : Finset (Fin n → Bool)}
  (hTS : T ⊆ S) (hT : T.Nonempty) :
  deficiency n S = deficiency n T ↔ S.card = T.card
```

A stronger theorem identifying strict increase under proper inclusion is highly desirable:
```lean
theorem deficiency_strict_mono
  {n : ℕ} {S T : Finset (Fin n → Bool)}
  (hTS : T ⊂ S) (hT : T.Nonempty) :
  deficiency n S < deficiency n T
```
if the chosen surrogate supports it.

**Why this matters.**  
This is the bridge from propositional implication to semantic information loss. It reframes implication as entropy contraction.

---

### Theorem 4: Additivity under independent variable splitting
This is the first genuinely structural theorem and should be pursued aggressively.

Suppose variables split into disjoint blocks of size `m` and `n`. For semantic constraints \(S \subseteq \{0,1\}^m\), \(T \subseteq \{0,1\}^n\), define the product constraint
\[
S \otimes T \subseteq \{0,1\}^{m+n}.
\]
Then
\[
\mathrm{def}(S \otimes T)=\mathrm{def}(S)+\mathrm{def}(T),
\]
and therefore model-shrinkage distances add under independent composition.

**Lean 4 type signature sketch**
```lean
def prodAssignments (S : Finset (Fin m → Bool)) (T : Finset (Fin n → Bool)) :
    Finset (Fin (m+n) → Bool) := ...

theorem card_prodAssignments
  (S : Finset (Fin m → Bool)) (T : Finset (Fin n → Bool)) :
  (prodAssignments S T).card = S.card * T.card

theorem deficiency_add
  (S : Finset (Fin m → Bool)) (T : Finset (Fin n → Bool))
  (hS : S.Nonempty) (hT : T.Nonempty) :
  deficiency (m+n) (prodAssignments S T) =
    deficiency m S + deficiency n T
```

**Why this matters.**  
This is the theorem that upgrades the invariant from a toy statistic to a compositional complexity measure. It is the semantic analogue of direct-sum phenomena in complexity theory.

---

### Theorem 5: Lower bound for bounded-shrinkage derivation systems
This is the theorem that most directly resembles the original conjecture and is likely the deepest realistic formal target.

Define a derivation system semantically as a sequence of finite assignment sets `S 0, ..., S k` with `S (i+1) ⊆ S i`. Suppose each step can shrink by at most a factor `B`, i.e.
\[
|S_i| \le B \cdot |S_{i+1}|.
\]
Then
\[
k \ge \frac{\log_2(|S_0|/|S_k|)}{\log_2 B},
\]
or in integer form,
\[
k \cdot \Nat.log2(B) \ge \Nat.log2|S_0| - \Nat.log2|S_k|.
\]

**Lean 4 type signature sketch**
```lean
theorem length_lower_bound_of_bounded_shrink
  {α : Type} [DecidableEq α]
  (S : Fin (k+1) → Finset α)
  (B : ℕ)
  (hmono : ∀ i : Fin k, S i.succ ⊆ S i.castSucc)
  (hB : ∀ i : Fin k, (S i.castSucc).card ≤ B * (S i.succ).card)
  (hpos : 1 < B)
  (hnonempty : ∀ i : Fin (k+1), (S i).Nonempty) :
  k * Nat.log2 B ≥ Nat.log2 ((S 0).card) - Nat.log2 ((S (Fin.last k)).card)
```

**Why this matters.**  
This is the first honest theorem in the direction of “proof length ≥ semantic shrinkage / local step capacity.” It won’t settle Resolution or Frege, but it isolates the exact combinatorial mechanism any future proof must exploit.

---

## Most promising proof architectures

You must include at least 2–3 proof strategies in the file comments or paper, and then execute the strongest one formally.

### Strategy A: Finite-set entropy calculus via cardinality identities
This is the most promising path for Lean.

1. Represent formulas semantically as finite sets of assignments.
2. Prove exact cardinality formulas for restriction and product constructions.
3. Convert cardinality identities into `Nat.log2` inequalities and telescoping sums.
4. Derive bounded-shrinkage lower bounds.

**Why best:** it uses only finite combinatorics, `Finset`, `Fintype`, embeddings, and arithmetic inequalities. It is robust, formalizable, and already contains a nontrivial cross-domain bridge to information theory.

---

### Strategy B: Boolean cube / coding theory viewpoint
Interpret semantic theories as subsets of the Hamming cube \(Q_n\).

1. Coordinate restrictions are affine subcubes.
2. Deficiency measures codimension for exact subcubes and entropy deficit for general subsets.
3. Product constraints become Cartesian products of cubes, giving additivity.
4. Bounded-shrinkage derivations become filtrations in the cube.

**Why useful:** this creates a connection to isoperimetry, VC-dimension, and coding theory. It may support stronger follow-up theorems: e.g. if each proof step is “local” in Hamming geometry, then shrinkage should imply boundary growth.

---

### Strategy C: Information-theoretic semantics of implication
Let a random satisfying assignment be uniform on `Mod(φ)`. If `ψ ⊨ φ`, then `Mod(ψ) ⊆ Mod(φ)` and
\[
d(\phi,\psi) = \log_2|Mod(\phi)| - \log_2|Mod(\psi)|
\]
is exactly the increase in description length of a uniform model conditioned to satisfy `ψ`.

1. Prove deficiency monotonicity as an entropy monotonicity statement.
2. Prove additivity under independent composition.
3. Reinterpret bounded-shrinkage proofs as bounded information-loss channels.

**Why revolutionary:** this points toward a semantic data-processing inequality for proofs. Even if only partially formalized, it is the conceptual engine for future work.

---

## Cross-domain connections you must explicitly exploit

You are required to include at least one theorem and discussion connecting proof complexity to another domain. The strongest options are:

1. **Information Theory**  
   `deficiency` behaves like entropy defect. Additivity under independent composition is the semantic analogue of Shannon entropy additivity.

2. **Coding Theory / Discrete Geometry**  
   Semantic theories are subsets of the Boolean cube. Coordinate restrictions are subcubes of codimension `|I|`. This identifies exact shrinkage with geometric codimension.

3. **Finite Model Theory / Database Theory**  
   Implication corresponds to query refinement; model-shrinkage is a loss of admissible worlds. This suggests analogies with information gain and provenance complexity.

4. **Statistical Physics**  
   `log₂ |Mod(φ)|` is a zero-temperature entropy. Proof steps become entropy-lowering constraints. This makes the conjecture resemble a lower bound on the number of microscopic constraint applications required to induce a macroscopic entropy drop.

Application keywords to include verbatim:
**proof complexity, model counting, #SAT, Boolean cube, entropy, codimension, information theory, direct-sum, semantic lower bounds, resolution complexity, Frege systems, combinatorial filtrations**

---

## What to build on from Mathlib / catalog-style ingredients

Even if no domain-specific proof-complexity catalog theorem is available, build aggressively on these standard certified ingredients:

- `Fintype.card_fun` / cardinality of function spaces
- `Finset.card_biUnion`, `Finset.card_product`, `Finset.card_attach`
- subset/cardinality lemmas for `Finset`
- arithmetic lemmas for `Nat.log2`, powers of two, and monotonicity
- `Nat.card`, `Fintype.card_fin`, `Fintype.card_fun`
- embeddings/equivalences splitting `Fin (m+n)` into `Fin m ⊕ Fin n`

If there is live catalog context available about entropy, combinatorics, or finite counting, explicitly connect to it and extend it.

---

## Concrete file design

Create a Lean file centered on semantic proof complexity, for example:
- `SemanticProofComplexity/ModelShrinkage.lean`

Recommended definitions:
```lean
abbrev Assignment (n : ℕ) := Fin n → Bool

def deficiency (n : ℕ) (S : Finset (Assignment n)) : ℕ := ...
def restrictedAssignments ...
def prodAssignments ...
def stepShrink ...
def cumulativeShrink ...
def BoundedShrinkageChain ...
```

Recommended theorem list:
1. `card_restrictedAssignments`
2. `shrinkage_of_coordinate_restriction`
3. `deficiency_monotone`
4. `card_prodAssignments`
5. `deficiency_add`
6. `sum_log2_card_telescopes`
7. `length_lower_bound_of_bounded_shrink`

At least **3** of these must use nontrivial proof tactics such as induction on finite chains or finite sets, `rcases` decomposition of assignments, contradiction from cardinal inequalities, and multi-step `calc`.

Do **not** trivialize by proving only easy cardinality lemmas. The bounded-shrinkage lower bound theorem is mandatory unless a stronger theorem supersedes it.

---

## Frontier conjecture to state, isolate, and test

You should explicitly state the original ambitious conjecture in the paper and future directions, but formalize a sharper semantic version first.

### Formal semantic conjecture
For any propositional proof system \(P\) admitting a semantics where each derivation step shrinks the model set by at most \(2^{c \cdot \ell}\), where \(\ell\) is local proof size and \(c\) is system-dependent, every derivation from \(\phi\) to \(\psi\) with \(\psi \models \phi\) satisfies
\[
\mathrm{ProofLength}_P(\psi) - \mathrm{ProofLength}_P(\phi)
\ge \Omega\!\left(d(\phi,\psi)\right).
\]

### Original proof-complexity conjecture
For suitable formula families in Resolution/Frege/Extended Frege,
\[
\frac{\mathrm{ProofLength}(\psi)}{\mathrm{ProofLength}(\phi)}
\ge 2^{\Omega(d(\phi,\psi))}.
\]

### Falsifiable computational prediction
Construct CNF families where `ψ` is obtained from `φ` by adding exactly `k` independent unit clauses on fresh or unrestricted coordinates. Then:
- exact model shrinkage is `k`;
- if semantic shrinkage governs proof cost, proof size in bounded-width Resolution should grow at least exponentially in `k` for some structured families;
- a family with shrinkage `k` but proof-size growth `poly(k)` would refute the strong form.

This is cleanly testable with:
- exact model counting via brute force for small `n` or #SAT tools for larger `n`;
- proof search or certificate size measurement in toy Resolution encodings.

---

## Deliverables you must produce

You must produce **all** of the following:

1. **Lean formalization** with the new definitions and at least 3 deep theorems.
2. **A verified algorithm or computational method**:
   - implement a function computing model sets of small formulas or semantic constraints,
   - compute deficiency and shrinkage along derivation chains,
   - verify the bounded-shrinkage lower bound on examples.
3. **`demo.py`**
   - interactively generate random or structured constraint chains,
   - compute exact model counts,
   - display shrinkage, deficiency, and the lower-bound certificate,
   - optionally compare with brute-force search proof proxies.
4. **`RESEARCH_PAPER.md`**
   - standalone scientific document,
   - define the invariant,
   - state and explain the formal theorems,
   - discuss relation to proof complexity and information theory,
   - articulate why the semantic theorem is a credible precursor to genuine lower bounds.
5. **`ARTICLE.md`**
   - Scientific American style,
   - explain “proofs as entropy-compressing processes” to broad readers.
6. **`FUTURE_DIRECTIONS.md`**
   with **3–5 falsifiable scientific hypotheses**, each with a concrete disproof test.

---

## Required hypotheses for FUTURE_DIRECTIONS.md

Include at least these testable hypotheses, sharpened as needed:

1. **Resolution bounded-shrinkage hypothesis**  
   Every width-`w` Resolution inference shrinks the satisfying set by at most `2^{O(w)}` on average over assignments.  
   **Test:** enumerate all width-`w` clause additions for small `n`; compute exact shrinkage.

2. **Direct-sum hypothesis for semantic proof burden**  
   For independent formula pairs, minimal derivation length to reach the product constraint is additive up to constants.  
   **Test:** brute-force derivation search on products of small cubes.

3. **Codimension-realization hypothesis**  
   Every exact codimension-`k` affine subcube can be reached by `k` independent unit restrictions and by no shorter chain in bounded-shrinkage systems with `B=2`.  
   **Test:** exhaustive search for small `n`.

4. **Refutation hypothesis for the strong conjecture**  
   There exists a family with exponential model shrinkage but only polynomial proof-length growth in Extended Frege.  
   **Test:** search among extension-variable constructions and compare model counts.

5. **Entropy-barrier hypothesis**  
   Any proof system satisfying a local data-processing inequality automatically admits semantic lower bounds proportional to total deficiency increase.  
   **Test:** formalize candidate local inequalities in toy systems.

---

## Final standard

Do not retreat into vague commentary. Produce a Lean development that makes the phrase

> “model-shrinkage is an entropy-like proof invariant”

mathematically real.

Even a semantic theorem of the form
\[
k \cdot \log_2 B \ge \log_2|S_0| - \log_2|S_k|
\]
for bounded-shrinkage derivations would already be a new conceptual tool: a proto-lower-bound theorem linking proof complexity to information loss on the Boolean cube. That is the breakthrough foothold. Build it.

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
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

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

Research domain: Speculative
Research mode: prove
