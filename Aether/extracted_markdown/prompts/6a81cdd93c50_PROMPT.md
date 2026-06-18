## Assignment: Homotopy Type Theory Foundations — but make it mathematically decisive

You are not being asked to “encode some HoTT vocabulary.” You are being asked to force a genuine bridge between intensional identity, equivalence, truncation-level structure, and constructive computation inside Lean 4’s dependent type theory. The target is not a toy axiomatization; the target is a blueprint showing that HoTT-style reasoning can be made mathematically productive, structurally rich, and computationally meaningful even in a proof assistant whose kernel is not natively cubical.

Your mission is to isolate a formally robust fragment of HoTT, prove nontrivial structural theorems about it, and demonstrate that this fragment already yields a constructive foundation with concrete consequences in logic and computation.

## Mode
**prove + formalize + discover**

## Core Objective
Formalize a Lean 4 framework for a synthetic HoTT-style fragment featuring:
- identity-to-equivalence transport principles,
- a formally usable notion of homotopy fiber / contractibility / proposition-level truncation surrogate,
- a version of the fundamental theorem of identity types,
- at least one higher-inductive-type-inspired construction encoded via universal properties or quotient-style recursors,
- and a theorem showing that this framework supports constructive mathematics by extracting computationally meaningful data from proofs.

You must **not** settle for merely postulating `Univalence`. Instead, make the formal story mathematically fruitful: define the right structures, prove coherence lemmas, and show how they organize ordinary mathematics.

---

## Precise Theorem Targets

You must prove **at least 3 deep theorems**, and the following are the primary targets. If one exact statement is impossible due to Lean kernel limitations, prove the strongest precise surrogate and document the obstruction in `RESEARCH_PAPER.md`.

### Theorem 1: Fundamental theorem of identity types via contractible total spaces
This is the conceptual heart. Build on the catalog’s `fundamental_theorem_subsingleton` but strengthen it from mere proof-irrelevance/subsingleton behavior to a HoTT-style characterization of identity systems.

Define a new structure expressing a family with a chosen center and contractible total space, e.g.
```lean
structure IdentitySystem
    (A : Sort u) (a₀ : A)
    (R : A → Sort v) where
  rflR : R a₀
  contr_total : Contractible (Sigma R)
```
with your own `Contractible` if needed:
```lean
structure Contractible (X : Sort u) where
  center : X
  contr : ∀ y : X, y = center
```

Then target a theorem of the following shape:
```lean
theorem identity_system_equiv_path
    {A : Sort u} {a₀ : A} {R : A → Sort v}
    (S : IdentitySystem A a₀ R) :
    ∀ a : A, Equiv (a₀ = a) (R a)
```
If `Equiv` is inconvenient, define a bespoke equivalence structure:
```lean
structure Equiv' (α : Sort u) (β : Sort v) where
  toFun : α → β
  invFun : β → α
  left_inv : ∀ x, invFun (toFun x) = x
  right_inv : ∀ y, toFun (invFun y) = y
```

**Why this is a breakthrough:** this theorem is the operational core of the “fundamental theorem of identity types”: identity is characterized by any family that behaves like a path space from a base point and whose total space is contractible. Formalizing this cleanly in Lean 4 gives a reusable engine for synthetic homotopy arguments, not just a one-off proposition.

---

### Theorem 2: Univalence-style transport for a universe of structured propositions or sets
You likely cannot prove full univalence in kernel Lean without axioms or cubical infrastructure. So do something more powerful scientifically: isolate a universe where a **provable univalence surrogate** holds.

For example, define a type of “h-propositions” or “setoids with proof-irrelevant carrier predicates,” and prove that equality in that universe is equivalent to logical equivalence / structure equivalence.

Candidate target:
```lean
structure HProp where
  carrier : Prop

def HPropEquiv (P Q : HProp) : Prop :=
  P.carrier ↔ Q.carrier

theorem hprop_univalence_surrogate
    (P Q : HProp) :
    (P = Q) ↔ HPropEquiv P Q
```
If this exact statement is false due to record equality extensionality issues, prove a sigma/extensional reformulation:
```lean
theorem hprop_univalence_surrogate'
    {P Q : HProp} :
    Nonempty (Equiv' P.carrier Q.carrier) → P = Q
```
or a theorem for a quotient/universe representation where equality *is* logical equivalence by construction.

A stronger and more interesting target is a universe of pointed contractible types, propositions, or truncation-level-coded objects:
```lean
structure HSetLike where
  carrier : Type u
  isSet : ∀ x y : carrier, Subsingleton (x = y)
```
Then prove a transport/equivalence principle on this universe.

**Why this is a breakthrough:** rather than merely asserting univalence axiomatically, you identify a mathematically meaningful subuniverse where univalence is theorematic. This is exactly how one turns philosophical HoTT principles into formal infrastructure Lean can exploit today.

---

### Theorem 3: Encoded higher-inductive-type principle via quotient or pushout surrogate
You must define at least one **new concept** inspired by higher inductive types and prove its induction/elimination behavior.

A strong candidate is a “synthetic circle code” via a quotient of `ℤ`-action, or a pushout-like gluing object encoded by an inductive relation plus quotient. For example:
```lean
inductive CircleRel : Unit → Unit → Prop
| loop : CircleRel () ()

def Circle := Quot (fun _ _ : Unit => True)   -- too trivial, do not do this
```
That trivializes. Instead, encode a genuine HIT surrogate using a graph quotient or free path object.

A more realistic target:
- define a **coequalizer / pushout surrogate** as a quotient of a sum by a generated relation,
- prove its recursion principle,
- prove a nontrivial universal property.

For instance:
```lean
inductive PushoutRel {A B C : Type u} (f : A → B) (g : A → C) :
    Sum B C → Sum B C → Prop
| glue : ∀ a, PushoutRel f g (Sum.inl (f a)) (Sum.inr (g a))
| symm : ...
| trans : ...
```
Then:
```lean
def Pushout (f : A → B) (g : A → C) := Quot (PushoutRel f g)
```
and prove a recursor/universal property:
```lean
theorem pushout_rec_unique
    {A B C X : Type u} (f : A → B) (g : A → C)
    (iB : B → X) (iC : C → X)
    (comm : ∀ a, iB (f a) = iC (g a)) :
    ∃! h : Pushout f g → X,
      (∀ b, h (Quot.mk _ (Sum.inl b)) = iB b) ∧
      (∀ c, h (Quot.mk _ (Sum.inr c)) = iC c)
```

**Why this is a breakthrough:** higher inductive types are where HoTT becomes geometry rather than just logic. Even a quotient-based surrogate with a verified universal property gives Lean users a practical synthetic topology toolkit.

---

### Theorem 4: Constructive content theorem
You must prove at least one theorem making the slogan “HoTT provides a constructive foundation for mathematics” mathematically testable.

A promising precise target is to show that contractibility/equivalence data yields computationally extractable witnesses.

Example:
```lean
theorem contractible_choice
    {A : Type u} {B : A → Type v}
    (h : Contractible (Sigma B)) :
    ∃ a : A, B a
```
This is easy alone, so strengthen it substantially:
```lean
theorem equiv_transports_decidability
    {α : Type u} {β : Type v}
    (e : Equiv' α β) [DecidableEq α] :
    DecidableEq β
```
and combine with identity-system machinery to show that structure can be transported constructively along equivalences.

Or prove:
```lean
theorem contractible_total_gives_unique_section
    {A : Type u} {B : A → Type v}
    (hA : Contractible A)
    (hB : ∀ a, Contractible (B a)) :
    Contractible ((a : A) → B a)
```
This is a genuine synthetic constructive theorem: it shows function spaces inherit contractibility from fibers and base.

**Why this matters:** it demonstrates that your HoTT fragment is not just semantic ornamentation; it supports witness extraction, transport of algorithmic structure, and compositional constructive mathematics.

---

## Lean 4 Type Signature Targets

Use these as anchors. You may refine universe levels, but the mathematical shape should remain.

```lean
structure Contractible (X : Sort u) where
  center : X
  contr : ∀ y : X, y = center

structure Equiv' (α : Sort u) (β : Sort v) where
  toFun : α → β
  invFun : β → α
  left_inv : ∀ x, invFun (toFun x) = x
  right_inv : ∀ y, toFun (invFun y) = y

structure IdentitySystem
    (A : Sort u) (a₀ : A)
    (R : A → Sort v) where
  rflR : R a₀
  contr_total : Contractible (Sigma R)

theorem identity_system_equiv_path
    {A : Sort u} {a₀ : A} {R : A → Sort v}
    (S : IdentitySystem A a₀ R) :
    ∀ a : A, Equiv' (a₀ = a) (R a)

structure HProp' where
  carrier : Prop

def HPropEquiv (P Q : HProp') : Prop := P.carrier ↔ Q.carrier

theorem hprop_univalence_surrogate :
    ∀ P Q : HProp', HPropEquiv P Q → P = Q
```

If the last theorem is too strong for the chosen representation, replace the representation so that it becomes true by construction, or prove the optimal extensional form and explain the exact boundary.

For the HIT surrogate:
```lean
def Pushout {A B C : Type u} (f : A → B) (g : A → C) : Type u := ...

theorem pushout_rec_unique
    {A B C X : Type u} (f : A → B) (g : A → C)
    (iB : B → X) (iC : C → X)
    (comm : ∀ a, iB (f a) = iC (g a)) :
    ∃! h : Pushout f g → X, True
```
Strengthen the `True` into the actual boundary equations.

For constructive transport:
```lean
theorem equiv_transports_decidableEq
    {α : Type u} {β : Type v}
    (e : Equiv' α β) [DecidableEq α] :
    DecidableEq β
```

---

## Proof Strategy Architecture

You must pursue **2–3 serious proof routes**, not just one.

### Strategy A: Contractible-total-space route to identity
1. Define `Contractible`, `Equiv'`, and `IdentitySystem`.
2. Construct the map `(a₀ = a) → R a` by path induction / `Eq.rec` transporting `S.rflR`.
3. Construct the inverse `R a → (a₀ = a)` by sending `r : R a` to equality of sigma points:
   compare `(a₀, S.rflR)` and `(a, r)` inside the contractible total space `Sigma R`,
   then project equality of first components.
4. Prove left and right inverses via `Sigma` equality analysis and multi-step `calc`.

**Why promising:** this is the closest formal analog of the standard HoTT proof and should integrate naturally with existing subsingleton/fundamental-theorem catalog lemmas.

### Strategy B: Identity systems via based induction principle
1. Reformulate the desired theorem as an induction principle:
   every based family over `A` is determined by its value at `a₀`.
2. Show that contractibility of `Sigma R` gives uniqueness of based sections.
3. Deduce equivalence with the actual identity family by universal characterization.

**Why promising:** this route may avoid difficult direct manipulations of sigma equalities and clarify the theorem conceptually. It also scales better to future work on truncation levels and modalities.

### Strategy C: Quotient/HIT surrogate via universal property
1. Define a generated relation implementing gluing data.
2. Use quotient recursion to build the recursor.
3. Prove uniqueness of maps out of the quotient using relation induction and function extensionality on representatives.
4. Connect this to homotopical thinking: the quotient is a 1-dimensional gluing object approximating a HIT.

**Why promising:** Lean’s quotient API is mature, and this gives a practical stand-in for HITs while preserving the universal-property viewpoint central to HoTT.

Most promising overall:
- **For identity types:** Strategy A.
- **For higher inductive behavior:** Strategy C.
- **For constructive foundation claims:** combine Strategy A with transport theorems on decidability/subsingleton/contractibility.

---

## Build Explicitly on Catalog Theorems

You must reference and exploit the catalog theorems, especially:

1. `fundamental_theorem_subsingleton`
   - files:
     - `FINAL/Logic/FundamentalTheorem.lean`
     - `Logic/HoTT/FundamentalTheorem.lean`

Use this as the base case / low-homotopy-level shadow of your stronger theorem. Explain in code comments and in the paper:
- the catalog theorem handles the degenerate level where identity proofs collapse,
- your theorem upgrades from subsingleton uniqueness to a full equivalence between path spaces and a chosen identity system,
- this is the correct HoTT generalization.

2. `uniform_likelihood_identity`
   - file: `FINAL/Logic/AdvancedTheorems.lean`

This is your opening for a cross-domain theorem. The word “identity” here suggests a bridge between logical identity and probabilistic uniformity. Do not force a fake connection; instead prove a theorem showing that equivalences preserve finite uniform structure or transport counting/decision structure across equivalent types.

3. `fundamental_theorem_oracle'`
   - files:
     - `Computation/Oracles/OmniscientOracle.lean`
     - `FINAL/Computation/OmniscientOracle.lean`

Use this as the computational side of your constructive-foundation story. A compelling direction is to prove that equivalence/contractibility principles let you transfer oracle-decidable structure between equivalent types or encode extensional invariance of oracle computations under equivalence.

Do **not** merely cite these. State in comments and in `RESEARCH_PAPER.md` exactly how your theorems strengthen, reinterpret, or repurpose them.

---

## Cross-Domain Connection Requirement

You must include at least one theorem connecting HoTT foundations to a different domain.

### Preferred connection: HoTT + computation / algorithms
Prove that equivalence preserves algorithmic structure.

Example target:
```lean
theorem equiv_transports_fintype
    {α : Type u} {β : Type v}
    (e : Equiv' α β) [Fintype α] :
    Fintype β
```
or
```lean
theorem equiv_transports_decidablePred
    {α : Type u} {β : Type v}
    (e : Equiv' α β) (P : α → Prop)
    [DecidablePred P] :
    DecidablePred (fun b : β => P (e.invFun b))
```
Then explain this as a constructive analogue of invariance under equivalence: mathematical structure is portable, not tied to representation.

### Alternative connection: HoTT + probability / information
If feasible, define transport of finite distributions along equivalences and prove normalization is preserved:
```lean
theorem equiv_pushforward_preserves_total_mass ...
```
This would connect identity/equivalence principles to probabilistic semantics.

### Alternative connection: HoTT + algebra
Show that a contractible type admits a unique magma/group-like structure up to transport, or that equivalences preserve algebraic laws. This is weaker than the computation route unless made very explicit.

**Application keywords:** constructive foundations, identity types, equivalence transport, quotient semantics, higher inductive surrogates, certified recursion, computational extraction, type-theoretic invariance, synthetic topology, proof-relevant foundations.

---

## Novel Definitions Required

You must define at least one genuinely new concept not already present in the catalog. Strong candidates:
- `IdentitySystem`
- `Contractible`
- `Equiv'` if needed for independence/control
- `Pushout` or `PushoutRel` as a HIT surrogate
- a universe/subuniverse object such as `HProp'` or `Trunc0Like`

Do not define something cosmetic. The new definition must do conceptual work in at least one major theorem.

---

## Deep Proof Tactic Requirements

At least 3 theorem proofs must substantially use:
- induction,
- `rcases`,
- `by_contra`,
- `field_simp` where mathematically relevant,
- or multi-step `calc`.

For this topic, the natural deep tactics are:
- induction on equality proofs,
- `rcases` on contractibility witnesses / sigma objects,
- nontrivial `calc` chains projecting equalities from sigma equalities,
- `by_contra` in uniqueness or extensionality arguments where suitable.

You are explicitly forbidden from padding the file with trivial theorem count inflation.

---

## Falsifiable Conjecture with Computational Test

Include at least one conjecture that can be disproved computationally.

### Recommended conjecture
For finite types represented via your `Equiv'`, transport along equivalence preserves the number of definable quotient-recursors from a fixed pushout surrogate.

This is abstract; make it testable by instantiating finite sets and counting functions in `demo.py`.

A more concrete version:
```text
Conjecture: For any finite span A → B, A → C with injective legs, the cardinality of the quotient-based pushout surrogate equals |B| + |C| - |A|.
```
This is falsifiable:
- enumerate finite examples,
- compute the quotient classes,
- compare with the formula.
If false, the experiment will expose where the relation closure differs from set-theoretic pushout expectations.

An even better conjecture if you implement finite pushouts:
```text
Conjecture: For finite spans with embeddings, your quotient pushout satisfies the expected inclusion–exclusion cardinality formula exactly.
```

This directly links HoTT-inspired gluing with combinatorics and computation.

---

## Deliverables You Must Produce

You must produce **all** of the following:

1. **Lean file(s)** with theorems and minimal `sorry`.
2. **FUTURE_DIRECTIONS.md**
   - 3–5 falsifiable scientific hypotheses.
   - Each must include:
     - precise statement,
     - what computational experiment or formal test could refute it,
     - what positive result would imply.
3. **RESEARCH_PAPER.md**
   - Standalone scientific paper.
   - Must explain:
     - the fragment of HoTT you formalized,
     - exact theorem statements,
     - why full univalence/HITs are difficult in kernel Lean,
     - how your surrogates recover real mathematical content,
     - what the constructive-foundation claim means operationally.
4. **ARTICLE.md**
   - Scientific American style.
   - Explain to a broad audience why “identity can behave like geometry,” and why proving transport/universal properties in Lean matters.
5. **A verified algorithm or computational method**
   - e.g. quotient-class computation for finite pushouts,
   - transport of decidability/finiteness along equivalence,
   - or a certified recursor constructor for your HIT surrogate.
6. **demo.py**
   - interactive demonstration of:
     - finite pushout construction,
     - quotient class enumeration,
     - testing the inclusion–exclusion conjecture,
     - or transport of structures across explicit equivalences.

---

## Concrete File-Level Expectations

Your Lean development should contain:
- one foundational file for definitions (`Contractible`, `Equiv'`, `IdentitySystem`, perhaps `HProp'`),
- one theorem file for identity-system results,
- one file for pushout/HIT surrogate,
- one file for computational transport/cross-domain results.

Each theorem should include comments saying:
- what theorem from the catalog it builds on,
- what is genuinely new,
- what future theorem it enables.

---

## Scientific Significance

If you succeed, this project opens a real research direction:

- It shows that **HoTT ideas can be made productive inside standard Lean 4** without waiting for full cubical infrastructure.
- It yields a reusable formal toolkit for **identity systems, contractibility, equivalence transport, and quotient-based synthetic topology**.
- It creates a bridge from foundations to **computation**, showing that equivalence is not merely philosophical but algorithmically actionable.
- It lays the groundwork for future formalized work on:
  - truncation levels,
  - modalities,
  - synthetic homotopy constructions,
  - semantics of proof-relevant programming,
  - and type-theoretic invariance principles in algorithms.

This is not an incremental extension. It is the beginning of a practicable HoTT-for-Lean methodology.

---

## Minimum theorem roster you should aim to prove

At minimum, aim for this list or stronger:

```lean
theorem contractible_subsingleton
    {X : Sort u} (h : Contractible X) : Subsingleton X

theorem identity_system_equiv_path
    {A : Sort u} {a₀ : A} {R : A → Sort v}
    (S : IdentitySystem A a₀ R) :
    ∀ a : A, Equiv' (a₀ = a) (R a)

theorem contractible_total_gives_unique_section
    {A : Type u} {B : A → Type v}
    (hA : Contractible A)
    (hB : ∀ a, Contractible (B a)) :
    Contractible ((a : A) → B a)

theorem equiv_transports_decidableEq
    {α : Type u} {β : Type v}
    (e : Equiv' α β) [DecidableEq α] :
    DecidableEq β

theorem pushout_rec_unique
    {A B C X : Type u} (f : A → B) (g : A → C)
    (iB : B → X) (iC : C → X)
    (comm : ∀ a, iB (f a) = iC (g a)) :
    ∃! h : Pushout f g → X, ...

theorem finite_pushout_cardinality_formula
    ... -- if you implement finite quotient computation
```

At least three of these must have substantial proofs.

---

## Final instruction

Be ruthless about theorem quality. If a statement collapses to definitional equality or automation, replace it with a stronger one. Every theorem should either:
- reveal the structure of identity,
- establish a universal property,
- or transport constructive/computational content across equivalence.

That is the bar.

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

Research domain: Logic
Research mode: prove
