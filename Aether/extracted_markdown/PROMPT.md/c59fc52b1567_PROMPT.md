Soli Deo Gloria

## Assignment: Zero-Knowledge Theorem Proving: I Can Prove Fermat's Last Theorem Without Showing You the Proof

**Mode:** `prove` + `discover`

Aristotle, do not treat this as a toy formalization of cryptographic folklore. The real target is a new mathematical interface between **proof theory, complexity theory, information theory, and formal verification of interactive protocols**. The breakthrough is not “implement a verifier.” The breakthrough is to isolate a mathematically clean notion of **proof-local revelation** and prove theorems showing that local checking can certify global provability while leaking only sharply bounded information.

Your mission is to build a Lean 4 theory of **zero-knowledge theorem proving for finitely presented proof systems**, then push it far enough to make a serious conjectural bridge to arithmetic provability.

The central conceptual move should be this:

> Replace the vague slogan “the verifier sees only one proof step” by a precise quantitative invariant measuring how much of a proof object is exposed by a challenge protocol, and prove soundness / completeness / bounded leakage theorems for that invariant.

This is stronger, cleaner, and more field-opening than merely encoding an existing Sigma protocol.

---

## Core Breakthrough Goal

Formalize a finite proof system for propositional formulas or derivation DAGs, define a **challenge-response proof audit protocol**, and prove that:

1. **Honest complete derivations are accepted with probability 1**.
2. **Invalid derivations are rejected with probability bounded below by a structural defect density**.
3. **The verifier’s transcript can be simulated from public data plus challenge randomness and therefore reveals only bounded local information**.
4. **Repeated auditing amplifies soundness exponentially while leakage grows only linearly in the number of rounds**.

This would create a new formal mathematical object: a **locally auditable proof certificate**. That object is potentially exportable to complexity theory, proof-carrying code, distributed theorem certification, and information-theoretic models of scientific trust.

---

## Precise Formal Targets

You should introduce a new concept not already standard in Mathlib:

### New definition: locally auditable derivation system

A promising Lean shape is:

```lean
structure LocalRuleSystem (Stmt Step : Type _) where
  valid_step : List Step → Step → Prop
  concludes  : Step → Stmt
  axiomatic  : Step → Prop
```

Then define a finite derivation certificate with explicit dependency graph:

```lean
structure DerivationCert (Stmt Step : Type _) where
  steps : Fin n → Step
  deps  : Fin n → Finset (Fin n)
  wf    : ∀ i, ∀ j ∈ deps i, j.val < i.val
  local_ok :
    ∀ i, LocalRuleSystem.valid_step R ((deps i).val.map steps) (steps i) ∨ R.axiomatic (steps i)
  goal : Stmt
  goal_ok : R.concludes (steps (Fin.last n)) = goal
```

You may need a more Lean-friendly formulation using `Vector`, `Array`, or `List` with index bounds.

### New definition: one-step audit protocol

```lean
structure AuditTranscript (Stmt Step : Type _) where
  challenged : Fin n
  revealed_step : Step
  revealed_deps : Finset (Fin n)
```

### New definition: leakage budget

A mathematically interesting invariant:

```lean
def transcriptSupportSize (π : DerivationCert Stmt Step) (t : AuditTranscript Stmt Step) : Nat := ...
```

or more abstractly:

```lean
def leakageCost (t : AuditTranscript Stmt Step) : Nat := ...
```

Then define repeated auditing:

```lean
def repeatedAuditAccepts (k : Nat) (π : DerivationCert Stmt Step) (challenges : Fin k → Fin n) : Prop := ...
```

---

## Theorem Cluster to Prove

You must prove **at least 3 substantial theorems**, with nontrivial tactics and multi-step reasoning. Here is the target theorem package.

### Theorem 1: Perfect completeness of local audit

**Mathematical statement.**  
For every well-formed derivation certificate, every challenge to any step is answered consistently and accepted.

**Lean-style signature:**
```lean
theorem audit_perfect_completeness
  {Stmt Step : Type _}
  (R : LocalRuleSystem Stmt Step)
  (π : DerivationCert Stmt Step)
  (hπ : π.WellFormed R) :
  ∀ i : Fin π.length, auditAccepts R π i
```

If your actual definitions differ, keep the quantifier structure:  
`∀ certificate, well_formed → ∀ challenge, accepts`.

**Why this matters.**  
This is the formal anchor: global provability implies local verifiability. Without it, there is no theorem-proving interpretation.

**Proof strategy options.**
- **Strategy A: direct unfolding + dependency well-foundedness.**  
  Unfold `auditAccepts`, use the stored `local_ok` witness, and verify that all dependencies are earlier by `wf`. Most promising if your certificate stores enough local evidence.
- **Strategy B: induction on challenged index.**  
  Prove a stronger statement that every prefix of the derivation is auditable. This is more robust if your local rule checker recursively references earlier steps.
- **Strategy C: derivation DAG recast as list recursion.**  
  Convert the certificate into a prefix-closed list of validated steps and prove acceptance by recursive construction.

**Most promising:** Strategy A if you design the certificate correctly. This theorem should become nearly structural, but not trivial.

---

### Theorem 2: Defect-detection lower bound

You need a real theorem here, not a slogan.

Define a **defective index** as a step that is neither axiomatic nor locally derivable from its declared dependencies. Let `badIndices π` be the set of defective steps. Then prove:

**Mathematical statement.**  
If a certificate contains at least one defective step, then a uniformly random audit catches an error with probability at least the fraction of defective steps.

A finite combinatorial version is sufficient if measure-theoretic probability is too heavy:

```lean
theorem audit_detection_count_bound
  {Stmt Step : Type _}
  [Fintype (Fin n)]
  (R : LocalRuleSystem Stmt Step)
  (π : RawCert Stmt Step n) :
  card (failingChallenges R π) ≥ card (badIndices R π)
```

and therefore, under the uniform distribution on challenges:

```lean
theorem audit_detection_probability_lower_bound
  {Stmt Step : Type _}
  (R : LocalRuleSystem Stmt Step)
  (π : RawCert Stmt Step n) :
  (badIndices R π).card ≤ (failingChallenges R π).card
```

or in normalized form if you build finite probabilities:

```lean
theorem audit_detection_prob_ge_defect_density
  ...
  : defectDensity R π ≤ rejectProbUniform R π
```

**Why this matters.**  
This is the precise replacement for the handwave “the verifier checks one random step.” It quantifies soundness in structural terms and opens the door to PCP-style amplification.

**Proof strategy options.**
- **Strategy A: explicit injection from bad indices to failing challenges.**  
  Show every bad step yields a challenge that rejects. Then use finite-cardinality monotonicity. This is the cleanest.
- **Strategy B: partition challenges into accepting and rejecting classes.**  
  Prove `badIndices ⊆ failingChallenges` and conclude by `Finset.card_le_card`.
- **Strategy C: contrapositive.**  
  If all challenges accept, then every step is locally valid or axiomatic; hence no bad indices exist.

**Most promising:** Strategy B. It gives both the counting theorem and an elegant corollary: “universal local acceptance implies global local correctness.”

This theorem should require `rcases`, set/finset inclusions, and a nontrivial cardinality argument.

---

### Theorem 3: Exponential soundness amplification under repeated independent audits

**Mathematical statement.**  
If a single random challenge rejects with probability at least `ε`, then `k` independent audits all accepting has probability at most `(1 - ε)^k`.

A finite counting or rational-valued version is acceptable.

**Lean-style signature:**
```lean
theorem repeated_audit_soundness_amplification
  {Stmt Step : Type _}
  (R : LocalRuleSystem Stmt Step)
  (π : RawCert Stmt Step n)
  (ε : ℚ)
  (hε : ε ≤ rejectProbUniform R π) :
  acceptProbRepeatedUniform R π k ≤ (1 - ε)^k
```

If probability formalization is too heavy, prove the combinatorial counting analogue over `Fin k → Fin n`:

```lean
theorem repeated_audit_accept_count_le_pow
  ...
  : card {c : Fin k → Fin n | repeatedAuditAccepts R π c}
    ≤ (card (acceptingChallenges R π)) ^ k
```

and derive the normalized statement afterward.

**Why this matters.**  
This upgrades local auditing from a curiosity into a real certification mechanism. It is the first theorem in the file that begins to look like a complexity-theoretic protocol theorem rather than a data-structure lemma.

**Proof strategy options.**
- **Strategy A: product counting over function spaces.**  
  Characterize accepting challenge sequences pointwise and count them as a Cartesian power.
- **Strategy B: induction on `k`.**  
  Base case `k = 0`; inductive step splits the first challenge from the remaining `k` challenges.
- **Strategy C: use finite probability independence if you formalize distributions.**  
  More elegant conceptually, but heavier in Lean.

**Most promising:** Strategy B with a combinatorial counting lemma. It is more feasible in Lean and still mathematically meaningful.

This theorem should use induction and multi-step `calc`.

---

### Theorem 4: Transcript simulation / bounded leakage

Do not oversell perfect zero-knowledge unless you truly formalize a simulator. A strong and realistic theorem is:

**Mathematical statement.**  
For a one-step audit protocol, the verifier transcript is determined by the public statement, the challenged index, and the local neighborhood of that index. In particular, the transcript depends on at most `1 + max_dependency_size` proof nodes.

A Lean-friendly form:

```lean
theorem audit_transcript_locality
  {Stmt Step : Type _}
  (R : LocalRuleSystem Stmt Step)
  (π : DerivationCert Stmt Step)
  (i : Fin π.length) :
  leakageCost (auditTranscript R π i) ≤ 1 + (π.deps i).card
```

A stronger simulator theorem, if feasible:

```lean
theorem exists_local_simulator
  {Stmt Step : Type _}
  (R : LocalRuleSystem Stmt Step)
  :
  ∃ S : PublicInput → Challenge → AuditTranscript Stmt Step,
    ∀ π i, transcriptEquivalent (S (publicView π) i) (auditTranscript R π i)
```

You may need a weaker equivalence notion, e.g. equality on verifier-observable fields only.

**Why this matters.**  
This is the actual mathematical embodiment of “zero knowledge” in your formal setting: the verifier learns only a local slice.

**Proof strategy options.**
- **Strategy A: direct support bound.**  
  Define support of a transcript and show it is contained in `{i} ∪ deps i`.
- **Strategy B: simulator by projection.**  
  Construct the transcript from public data plus challenge and prove observable equivalence.
- **Strategy C: entropy-free information bound.**  
  Avoid Shannon entropy entirely; prove a combinatorial support-size bound first.

**Most promising:** Strategy A, then optionally B. Entropy can come later.

---

## Cross-Domain Theorem Requirement

You must include at least one theorem connecting this subject to another domain.

### Recommended connection: information theory

Define a crude combinatorial information measure: the number of proof nodes exposed by a transcript. Then prove a subadditivity or linear-growth theorem under repetition:

```lean
theorem repeated_audit_leakage_linear
  (π : DerivationCert Stmt Step)
  (ch : Fin k → Fin π.length) :
  totalLeakageCost (repeatedAuditTranscript π ch)
    ≤ k * (1 + maxDepCard π)
```

This connects **proof theory** with **information theory / communication complexity**.

Alternative cross-domain bridges:
- **Proof theory + graph theory:** derivations as DAGs, local audit as graph property testing.
- **Proof theory + coding theory:** local consistency checks as parity-style tests; analogies with LTC/PCP.
- **Proof theory + economics/game theory:** sealed-bid revelation of mathematical strategy; strategic disclosure.
- **Proof theory + physics:** local observables of a global state; audit protocol as measurement with bounded disturbance.

A theorem comparing derivation defects to graph-local property testing would be particularly fresh.

---

## Strong Conjecture with Testable Prediction

State a falsifiable conjecture, and make it computationally testable in `demo.py`.

### Suggested conjecture

**Conjecture (Polynomial-length local audit for arithmetic provability).**  
There exists a family of locally auditable certificates for PA-provable statements such that for every theorem statement `φ`, there is a certificate for `φ` whose verifier communication under `k`-round audit is polynomial in `|φ| + k`, independent of the full proof length up to polynomial preprocessing.

This is ambitious; do not claim it proven.

### Concrete finite test prediction

For your implemented propositional proof system, define:
- formula size `|φ|`,
- derivation size `N`,
- maximum dependency size `d`,
- rounds `k`.

Then test the empirical prediction:

> For families of tautologies with succinct derivations, verifier transcript size grows like `O(k d log N)` while rejection probability on corrupted certificates matches or exceeds the defect-density lower bound.

A stronger falsifiable prediction:
- Randomly corrupting `m` out of `N` steps should produce empirical rejection frequency at least `m/N` under one-step audit, and acceptance after `k` rounds should decay near `(1 - m/N)^k`.

This can be simulated directly.

---

## Suggested Formal Development Order

1. **Choose a proof language**: propositional formulas with a Hilbert-style or natural deduction fragment, or a generic abstract local rule system.
2. **Define raw certificates** and well-formed certificates.
3. **Define bad indices**, accepting challenges, rejecting challenges.
4. **Prove local completeness**.
5. **Prove bad index inclusion into rejecting challenges**.
6. **Derive the counting/probability lower bound**.
7. **Define repeated audit and prove amplification**.
8. **Define leakage cost and prove locality / linear growth**.
9. **Instantiate the abstract theory** with a concrete propositional tautology system.
10. **Implement demo.py** to generate certificates, corrupt them, and measure detection/leakage.

---

## Lean 4 Type Signature Suggestions

These are not mandatory exact signatures, but the file should contain theorems recognizably close to these.

```lean
structure LocalRuleSystem (Stmt Step : Type _) where
  valid_step : List Step → Step → Prop
  concludes  : Step → Stmt
  axiomatic  : Step → Prop

structure RawCert (Step : Type _) (n : Nat) where
  steps : Fin n → Step
  deps  : Fin n → Finset (Fin n)

def StepDefective
  (R : LocalRuleSystem Stmt Step)
  (π : RawCert Step n)
  (i : Fin n) : Prop :=
  ¬ (R.axiomatic (π.steps i) ∨
     R.valid_step (((π.deps i).1.map π.steps)) (π.steps i))

def badIndices
  (R : LocalRuleSystem Stmt Step)
  (π : RawCert Step n) : Finset (Fin n) :=
  Finset.univ.filter (fun i => StepDefective R π i)

def auditAccepts
  (R : LocalRuleSystem Stmt Step)
  (π : RawCert Step n)
  (i : Fin n) : Prop :=
  R.axiomatic (π.steps i) ∨
  R.valid_step (((π.deps i).1.map π.steps)) (π.steps i)

theorem bad_subset_failing
  (R : LocalRuleSystem Stmt Step)
  (π : RawCert Step n) :
  badIndices R π ⊆ Finset.univ.filter (fun i => ¬ auditAccepts R π i)

theorem audit_detection_count_bound
  (R : LocalRuleSystem Stmt Step)
  (π : RawCert Step n) :
  (badIndices R π).card ≤
    (Finset.univ.filter (fun i => ¬ auditAccepts R π i)).card

def repeatedAuditAccepts
  (R : LocalRuleSystem Stmt Step)
  (π : RawCert Step n)
  (k : Nat) (ch : Fin k → Fin n) : Prop :=
  ∀ t, auditAccepts R π (ch t)

theorem repeated_audit_accept_count_le_pow
  (R : LocalRuleSystem Stmt Step)
  (π : RawCert Step n) :
  Fintype.card {ch : Fin k → Fin n // repeatedAuditAccepts R π k ch}
    ≤ ((Finset.univ.filter (fun i => auditAccepts R π i)).card)^k

def leakageCost
  (π : RawCert Step n)
  (i : Fin n) : Nat := 1 + (π.deps i).card

theorem audit_transcript_locality
  (π : RawCert Step n)
  (i : Fin n) :
  leakageCost π i ≤ 1 + maxDepCard π

theorem repeated_audit_leakage_linear
  (π : RawCert Step n)
  (k : Nat) (ch : Fin k → Fin n) :
  totalLeakageCost π ch ≤ k * (1 + maxDepCard π)
```

If necessary, replace `List.map` on dependent types with a helper function converting dependency finsets to lists of prior steps.

---

## Catalog-Building Perspective

Build on Mathlib’s strengths rather than fighting them:
- finite types and `Fintype.card`,
- `Finset` inclusions and cardinality lemmas,
- induction on `Nat`,
- `by_contra` for defect-free/global-validity contrapositives,
- `calc` chains for counting inequalities,
- `rcases` to unpack filtered membership and local witnesses.

Do **not** burn time trying to formalize full PCP or full cryptographic zero-knowledge unless the abstraction is already stable. The field-opening move is to create a mathematically reusable audited-derivation framework.

---

## Why This Would Be Revolutionary

If you succeed, you will have formalized a new kind of theorem certificate that sits between ordinary proofs and interactive proofs:

- **For proof theory:** a new notion of local certifiability of derivations.
- **For complexity theory:** a finite combinatorial stepping stone toward succinct proof verification.
- **For information theory:** a rigorous leakage budget for theorem certification.
- **For philosophy of mathematics / scientific practice:** a model for trusting a theorem without seeing the full strategy.
- **For distributed mathematics:** collaborative proof markets, priority-preserving theorem certification, and selective disclosure of ideas.

This opens follow-on work on:
- locally testable formal proofs,
- PCP-style theorem certification,
- zero-knowledge proof-carrying code,
- privacy-preserving peer review of mathematical claims,
- compressed proof publication standards.

This is not an incremental variant. It is the beginning of a new language for mathematical trust.

---

## Implementation Deliverables

You must produce **all** of the following:

1. **Lean file(s)** with:
   - at least one novel definition,
   - at least 3 nontrivial theorems,
   - proofs using induction / `rcases` / `by_contra` / `field_simp` where appropriate / multi-step `calc`,
   - minimal `sorry`.

2. **A verified algorithm or computational method**:
   - an executable checker for local audits of derivation certificates,
   - and a repeated-audit evaluator that computes acceptance / rejection and leakage cost.

3. **`demo.py`**:
   - generate sample propositional derivation certificates,
   - corrupt selected proof steps,
   - empirically measure one-step rejection frequency versus defect density,
   - measure repeated-audit acceptance decay,
   - plot or print transcript-size growth against round count.

4. **`RESEARCH_PAPER.md`**:
   - a standalone scientific paper,
   - define the audited-derivation model,
   - state the main theorems clearly,
   - explain significance and limitations,
   - include the arithmetic zero-knowledge conjecture and what remains open.

5. **`ARTICLE.md`**:
   - Scientific American style,
   - explain the idea of proving a theorem without revealing the proof,
   - focus on the mathematics and conceptual stakes,
   - **do not** focus on formal verification machinery.

6. **`FUTURE_DIRECTIONS.md`** with **3–5 original research directions**.
   Each direction must include:
   - a sentence beginning **“The key insight is…”**
   - a sentence beginning **“Why now?”**
   - at least one direction that bridges to a different domain.

---

## Application Keywords

zero-knowledge proofs, interactive proof systems, proof complexity, local testability, PCP heuristics, communication complexity, information leakage, proof-carrying code, derivation DAGs, property testing, finite combinatorics, propositional logic, arithmetization, privacy-preserving certification, scientific trust protocols

---

## Final Charge

Do not merely formalize “a verifier checks one random line.” Create the mathematics of **auditable truth with bounded revelation**. The file should read like the first chapter of a subject that did not exist before.

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
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

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
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
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
