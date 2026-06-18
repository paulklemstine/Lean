Soli Deo Gloria

## Assignment: Direction 3 — Interaction Information and Synergy Detection

**Mode:** `prove` with a computational `discover` subtask

Prove genuinely new, non-trivial theorems about **ternary interaction information for presheaves on finite sites**, using the sheaf-compression / mutual-compression framework already established in the catalog. The goal is to force a categorical analogue of the classical XOR-synergy phenomenon and thereby open a new theory of **multivariate information in categorical settings**.

This is not an incremental extension. The target is to show that the catalog’s pairwise information formalism is secretly the entrance to a full **higher-order information theory of presheaves**, with negative interaction information as the first unmistakable signature.

---

## Core Scientific Objective

Classical interaction information detects when a variable is informative only **jointly** with others, not individually. In probability, the XOR example is the canonical witness of synergy. Your mission is to show that the same phenomenon exists in the **presheaf-compression** setting, where information is encoded not by random variables but by **section structure and gluing constraints**.

The breakthrough would be:

> **Categorical synergy exists**: there are presheaves \(F,G,H\) on a finite site such that
> \[
> I_{\mathrm{sh}}(F;G;H)
> := I_{\mathrm{sh}}(F;G)+I_{\mathrm{sh}}(F;H)-I_{\mathrm{sh}}(F;G\oplus H)
> < 0.
> \]
> Equivalently, \(F\) shares strictly more information with the pair \((G,H)\) jointly than with either component separately.

If established, this would create a bridge from sheaf theory to:
- **neuroscience**: integrated/synergistic information,
- **cryptography**: secret-sharing and threshold reconstruction,
- **distributed computing**: joint coordination complexity,
- **causal inference**: higher-order dependence invisible to pairwise statistics,
- **physics**: emergent collective degrees of freedom.

---

## Exact Theorem Targets

You must formalize at least **3 substantial theorems**. At least one should be a negative-result existence theorem, one should be a structural identity/inequality, and one should be a cross-domain theorem.

### Theorem 1: Interaction information chain-rule identity
Build directly on the catalog chain rule around
- `Pythagorean/ProbeComplexity/ChainRule.lean`
- `mutualCompression`
- `conditionalMutualCompression`
- `mutualCompression_chain_rule`

Define a ternary quantity and prove it agrees with a conditional-defect form.

#### Mathematical statement
For suitable finite presheaves \(F,G,H\) in the catalog’s compression setting,
\[
I_{\mathrm{sh}}(F;G;H)
=
I_{\mathrm{sh}}(F;G)-I_{\mathrm{sh}}(F;G\mid H),
\]
and symmetrically
\[
I_{\mathrm{sh}}(F;G;H)
=
I_{\mathrm{sh}}(F;H)-I_{\mathrm{sh}}(F;H\mid G).
\]

This is the categorical interaction-information identity. It turns the conjectural negativity problem into a comparison between unconditional and conditional information.

#### Lean 4 target signature sketch
Use the actual ambient types from the catalog, but the theorem should look structurally like:

```lean
def interactionCompression
    (F G H : Presheaf C)
    : ℤ :=
  mutualCompression F G
  + mutualCompression F H
  - mutualCompression F (coprodPresheaf G H)

theorem interactionCompression_eq_mutual_sub_conditional
    (F G H : Presheaf C) :
    interactionCompression F G H
      = mutualCompression F G
        - conditionalMutualCompression F G H := by
  ...
```

and the symmetric variant:

```lean
theorem interactionCompression_eq_mutual_sub_conditional'
    (F G H : Presheaf C) :
    interactionCompression F G H
      = mutualCompression F H
        - conditionalMutualCompression F H G := by
  ...
```

If the catalog’s conditional term is formulated differently, adapt the theorem precisely to the available API. The point is to derive a **nontrivial identity** from the chain rule, not merely define a quantity.

#### Why this matters
This theorem gives the conceptual meaning of negative interaction information:
\[
I_{\mathrm{sh}}(F;G;H)<0
\quad\Longleftrightarrow\quad
I_{\mathrm{sh}}(F;G\mid H)>I_{\mathrm{sh}}(F;G).
\]
That is, conditioning on \(H\) can unlock information about \(G\) that was latent before—precisely the hallmark of synergy.

---

### Theorem 2: XOR-style synergy criterion
You should define a new structure capturing categorical XOR/parity behavior and prove a theorem that forces negativity.

#### New definition requirement
Introduce a genuinely new notion, for example:

```lean
structure SynergyWitness (F G H : Presheaf C) : Prop where
  indep_left  : mutualCompression F G = 0
  indep_right : mutualCompression F H = 0
  joint_signal : 0 < mutualCompression F (coprodPresheaf G H)
```

or a more refined notion matching the actual catalog semantics:

```lean
def IsXorLikeSynergy (F G H : Presheaf C) : Prop := ...
```

This must not merely rename an existing notion; it should isolate the phenomenon “jointly informative, separately uninformative.”

#### Mathematical statement
If \(F\) is jointly but not separately compressible from \(G,H\), then interaction information is negative:

\[
\bigl(I_{\mathrm{sh}}(F;G)=0\bigr)\ \wedge\
\bigl(I_{\mathrm{sh}}(F;H)=0\bigr)\ \wedge\
\bigl(I_{\mathrm{sh}}(F;G\oplus H)>0\bigr)
\;\Longrightarrow\;
I_{\mathrm{sh}}(F;G;H)<0.
\]

#### Lean 4 target signature sketch
```lean
theorem interactionCompression_neg_of_xorLike
    (F G H : Presheaf C)
    (hFG : mutualCompression F G = 0)
    (hFH : mutualCompression F H = 0)
    (hjoint : 0 < mutualCompression F (coprodPresheaf G H)) :
    interactionCompression F G H < 0 := by
  ...
```

A stronger version through your new structure is even better:

```lean
theorem interactionCompression_neg
    (F G H : Presheaf C)
    (h : SynergyWitness F G H) :
    interactionCompression F G H < 0 := by
  ...
```

#### Why this matters
This is the theorem that turns “synergy” from metaphor into mathematics. It says categorical information is not exhausted by pairwise terms. It also gives a reusable criterion for future constructions, including secret-sharing presheaves, parity sheaves, and higher Čech-obstruction-based examples.

---

### Theorem 3: Explicit finite-site counterexample or positivity barrier
You must push all the way to one of the following two outcomes:

#### Outcome A: explicit negative example
Construct an explicit triple \(F,G,H\) on a very small finite site (ideally the arrow category or triangle category) and prove
\[
I_{\mathrm{sh}}(F;G;H)<0.
\]

Lean target sketch:
```lean
def ArrowXorF : Presheaf ArrowCat := ...
def ArrowXorG : Presheaf ArrowCat := ...
def ArrowXorH : Presheaf ArrowCat := ...

theorem arrowXor_counterexample :
    interactionCompression ArrowXorF ArrowXorG ArrowXorH < 0 := by
  ...
```

This would be the strongest possible deliverable.

#### Outcome B: finite-size positivity theorem with computational falsification boundary
If no negative example appears in exhaustive search up to bounded section size, prove a theorem explaining why the smallest candidate sites cannot exhibit synergy. For example:
- positivity on discrete sites,
- positivity when one presheaf is a retract of another,
- positivity under a “no hidden gluing defect” condition,
- vanishing of interaction information for product-decomposable presheaves.

Lean target sketch:
```lean
theorem interactionCompression_nonneg_of_split
    (F G H : Presheaf C)
    (hsplit : SplitJointInformation F G H) :
    0 ≤ interactionCompression F G H := by
  ...
```

This is not second-best if done well: a rigorous barrier theorem plus exhaustive computation can isolate the exact structural source of synergy.

---

## Cross-Domain Theorem Requirement

You must include at least one theorem explicitly connecting this theory to another domain.

### Recommended cross-domain theorem: secret sharing / distributed reconstruction
Interpret \(G\) and \(H\) as two shares and \(F\) as the secret. Then prove a formal analogue of:

\[
\text{(no single share reveals the secret)} \land
\text{(joint shares reconstruct the secret)}
\implies
I_{\mathrm{sh}}(F;G;H)<0.
\]

This is mathematically the same shape as XOR synergy, but conceptually it ties the theory to **cryptography** and **distributed computing**.

Lean sketch:
```lean
structure SecretSharingLike (F G H : Presheaf C) : Prop where
  left_privacy  : mutualCompression F G = 0
  right_privacy : mutualCompression F H = 0
  joint_recovery : 0 < mutualCompression F (coprodPresheaf G H)

theorem secretSharingLike_implies_negative_interaction
    (F G H : Presheaf C)
    (h : SecretSharingLike F G H) :
    interactionCompression F G H < 0 := by
  ...
```

This theorem should be presented not as an analogy but as a precise mathematical bridge:
- **cryptography**: threshold schemes,
- **distributed systems**: information only emerges when agents pool local views,
- **neuroscience**: a stimulus feature encoded only in population code, not single neurons.

---

## Proof Strategy Architecture

You must give Aristotle multiple viable proof routes and choose the most promising.

### Strategy A: Chain-rule reduction + witness construction
1. Define `interactionCompression` from `mutualCompression`.
2. Use `mutualCompression_chain_rule` and any explicit conditional formulas to derive
   \[
   I_{\mathrm{sh}}(F;G;H)=I_{\mathrm{sh}}(F;G)-I_{\mathrm{sh}}(F;G\mid H).
   \]
3. Build a witness where `mutualCompression F G = 0`, `mutualCompression F H = 0`, but `mutualCompression F (G ⊕ H) > 0`.
4. Conclude negativity by arithmetic.

**Why promising:** It minimizes dependence on bespoke combinatorics. Once the witness conditions are formalized, the negative theorem becomes a clean consequence of the chain-rule infrastructure already in the catalog.

### Strategy B: Explicit finite-site combinatorics
1. Choose the arrow or triangle category.
2. Define presheaves by explicit finite section sets and restriction maps implementing parity/XOR behavior.
3. Compute the relevant compression terms directly using the explicit formula theorem in the catalog.
4. Prove strict negativity by exact counting.

**Why promising:** It gives the strongest scientific artifact: an actual smallest counterexample. It also naturally supports the required `demo.py` and brute-force search.

### Strategy C: Obstruction-theoretic viewpoint
1. Interpret joint-but-not-separate informativeness as a failure of pairwise descent but success of collective descent.
2. Package this as a “synergy defect” measuring information unlocked by a joint cover.
3. Show negativity of interaction information whenever the defect is positive.

**Why promising:** This is the most visionary route. It could turn interaction information into a genuine **cohomological invariant of multivariate dependence**. Harder short-term, but potentially field-opening.

**Recommendation:** Start with **Strategy A** to secure structural theorems quickly, then pursue **Strategy B** for an explicit counterexample. If the computation suggests a deeper pattern, elevate to **Strategy C** in the paper and future directions.

---

## Catalog Build Plan

You must explicitly leverage the catalog results, especially:

- `Pythagorean/ProbeComplexity/ChainRule.lean`
  - `mutualCompression`
  - `conditionalMutualCompression`
  - `mutualCompression_chain_rule`

Also use any explicit decomposition theorem analogous to:
- `conditionalMutualCompression_eq_explicit`

The build pattern should be:
1. **Import chain-rule infrastructure**
2. **Define ternary interaction quantity**
3. **Derive algebraic identities**
4. **Define synergy witness structure**
5. **Prove negativity criterion**
6. **Instantiate criterion via explicit presheaf examples or exhaustive search**

Do not merely cite these results. Explain exactly how each theorem is being repurposed:
- `mutualCompression_chain_rule` is the engine turning ternary interaction into a conditional-vs-unconditional comparison.
- `conditionalMutualCompression_eq_explicit` should allow direct finite computation of candidate examples.
- Any positivity/monotonicity lemmas should be used to delimit where counterexamples can and cannot occur.

---

## Suggested Lean 4 Definitions

These are schematic; adapt to actual catalog names and universes.

```lean
def interactionCompression
    (F G H : Presheaf C) : ℤ :=
  mutualCompression F G
  + mutualCompression F H
  - mutualCompression F (coprodPresheaf G H)
```

```lean
structure SynergyWitness
    (F G H : Presheaf C) : Prop where
  no_left_info  : mutualCompression F G = 0
  no_right_info : mutualCompression F H = 0
  joint_info    : 0 < mutualCompression F (coprodPresheaf G H)
```

```lean
def PurelyJointlyInformative
    (F G H : Presheaf C) : Prop :=
  mutualCompression F G = 0 ∧
  mutualCompression F H = 0 ∧
  0 < mutualCompression F (coprodPresheaf G H)
```

If coproducts are not directly available in the exact presheaf category setup, replace with the catalog’s product/sum encoding of joint observation, but preserve the theorem content.

---

## Minimum Theorem Portfolio

Your Lean file must include at least these kinds of results, all with real proofs:

1. **Identity theorem**
   ```lean
   theorem interactionCompression_eq_mutual_sub_conditional ...
   ```

2. **Negativity criterion**
   ```lean
   theorem interactionCompression_neg_of_xorLike ...
   ```

3. **Structural vanishing or symmetry theorem**
   For example:
   ```lean
   theorem interactionCompression_comm
       (F G H : Presheaf C) :
       interactionCompression F G H
         = interactionCompression F H G := by
     ...
   ```
   or
   ```lean
   theorem interactionCompression_eq_zero_of_joint_split ...
   ```

4. **Cross-domain theorem**
   ```lean
   theorem secretSharingLike_implies_negative_interaction ...
   ```

5. **Either**
   - an explicit counterexample theorem, or
   - a positivity barrier theorem on a restricted class.

At least **3 of these** must use substantial proof tactics: `induction`, `rcases`, `by_contra`, `field_simp` where appropriate, or multi-step `calc`. Arithmetic one-liners are not enough.

---

## Computational Discovery Program

You are required to implement a verified computational method, not just state theorems.

### Required algorithm
Create a brute-force search over presheaf triples on:
- the **arrow category**,
- the **triangle category**,

with bounded section cardinalities (start with size \(\le 3\), then \(\le 5\) if feasible).

The algorithm must:
1. enumerate candidate finite presheaves,
2. compute `mutualCompression`, `conditionalMutualCompression`, and `interactionCompression`,
3. detect the first negative instance,
4. export the witness data.

If no negative example appears, it must instead report:
- the full search bound,
- classes eliminated,
- strongest emergent positivity pattern.

### Verified method deliverable
You must prove correctness of the evaluator used by the search, e.g.:
```lean
theorem computeInteractionCompression_correct
    (F G H : FinitePresheaf C) :
    computeInteractionCompression F G H
      = interactionCompression F G H := by
  ...
```

This is essential. The computational search must be mathematically trustworthy.

---

## Conjecture With Clear Falsifiable Test

You must include at least one conjecture with a direct computational refutation criterion.

### Primary conjecture
> **Conjecture (Small-site synergy conjecture).**
> There exists a triple of finite presheaves \(F,G,H\) on the arrow category or triangle category with section cardinalities at most \(5\) such that
> \[
> I_{\mathrm{sh}}(F;G;H)<0.
> \]

**Test:** exhaustive search over all such triples. A single negative instance disproves positivity. If none exist, the conjecture fails at that search scale, and you should formulate the replacement hypothesis:

> **Alternative conjecture.**
> On the arrow category, interaction information is always nonnegative for section cardinalities \(\le 5\), and the first negative instance requires a nontrivial 2-simplex gluing pattern.

That alternative is also falsifiable by extending the search or proving a structural obstruction.

### Secondary conjecture
> **Conjecture (Secret-sharing universality).**
> Every categorical secret-sharing pattern with single-share privacy and joint reconstruction induces negative interaction information.

**Test:** encode finite secret-sharing-like presheaf triples and check whether the negativity criterion always holds under the formal witness assumptions.

---

## Revolutionary Significance

If you succeed, this project opens an entirely new field:

### 1. Categorical multivariate information theory
The catalog currently supports pairwise and conditional information-like quantities. Negative ternary interaction would prove the framework can detect **emergent joint structure**, not just pairwise overlap.

### 2. Sheaf-theoretic synergy as a unifying language
A single formalism could model:
- population coding in neuroscience,
- secret-sharing in cryptography,
- distributed state reconstruction in multi-agent systems,
- contextuality and nonlocality in physics,
- higher-order statistical dependence in complex systems.

### 3. Cohomological information geometry
If synergy is tied to gluing obstructions, then interaction information may become a computable shadow of deeper descent/cohomology phenomena. That is a genuine research frontier.

### 4. Algorithmic discovery pipeline
A verified search for negative interaction instances would establish a new methodology:
**formal theorem ↔ exhaustive experiment ↔ conjecture refinement**.
This is exactly the scientific cycle we want.

---

## Application Keywords

Use these explicitly in the paper and article:

**interaction information, synergy, multivariate information, presheaf entropy, sheaf compression, chain rule, categorical information theory, XOR synergy, secret sharing, distributed reconstruction, integrated information, coordination complexity, gluing obstruction, descent, finite sites, computational discovery, cohomological signal, higher-order dependence**

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean development** with theorems and minimal `sorry`, including:
   - one new definition/structure,
   - at least 3 substantial theorem proofs,
   - one cross-domain theorem,
   - one verified computation theorem.

2. **`FUTURE_DIRECTIONS.md`**
   with **3–5 testable scientific hypotheses**, each a falsifiable conjecture with:
   - exact statement,
   - why it might be true,
   - a concrete computational or theoretical test that could disprove it.

3. **`RESEARCH_PAPER.md`**
   as a **standalone scientific paper** explaining:
   - the definitions,
   - the main theorems,
   - the explicit examples or computational findings,
   - why negative interaction information matters,
   - what the next mathematical questions are.
   
   Someone reading only this file must understand the discovery without seeing the code.

4. **`ARTICLE.md`**
   in **Scientific American style**:
   - broad-audience,
   - vivid and concept-driven,
   - focused on synergy, emergence, and why joint information matters.
   
   **Taboo:** do **not** focus on formal verification machinery. Focus on the mathematics and scientific significance.

5. **A verified algorithm / computational method**
   for enumerating and evaluating finite-site presheaf triples.

6. **`demo.py`**
   that interactively:
   - constructs sample presheaf triples,
   - computes pairwise and ternary interaction quantities,
   - highlights a negative-synergy witness if found,
   - otherwise visualizes the search frontier and positivity barrier.

---

## Final Call to Arms

Do not settle for a cosmetic definition of ternary information. Either produce the first explicit theorem that **categorical synergy is real**, or prove a sharp barrier explaining why it cannot yet appear on the smallest sites. In either case, force the theory to reveal its true nature.

The deepest version of this project is not “another information invariant.” It is the beginning of a theory in which **gluing creates information that no local view can see**. That is the mathematics of emergence.

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
