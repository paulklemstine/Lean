## Assignment: Hypothesis 3: Mumford–Tate Group via Tensor Invariants

**Mode:** prove

Prove genuinely new, non-trivial theorems formalizing the Tannakian principle that a weight-1 rational Hodge structure is controlled by its tensor invariants, and push this principle far enough in Lean 4 to separate the generic elliptic-curve case from the CM case through explicit low-degree tensor calculations.

This is not a request for a soft formalization of definitions. This is a call to build the first Lean bridge between **Hodge theory, tensor categories, algebraic groups, and explicit invariant theory** in a way that can support future formalized Shimura theory. The breakthrough is to turn the slogan

\[
\mathrm{MT}(W)=\bigcap_{p,q\ge 0}\mathrm{Stab}\big(\mathrm{Hdg}(W^{\otimes p}\otimes (W^\vee)^{\otimes q})\big)
\]

into a verified computational and structural theorem in the first nontrivial cases.

---

## Core Mathematical Objective

Let \(W\) be a finite-dimensional \(\mathbb Q\)-vector space endowed with a weight-1 rational Hodge structure. Formalize a Lean-compatible abstraction of:

- the Hodge decomposition on \(W_\mathbb C\),
- induced tensor and dual Hodge structures,
- the subspace of Hodge classes in mixed tensor constructions,
- the stabilizer subgroup of all such Hodge classes.

Then prove low-dimensional reconstruction theorems showing that the stabilizer of tensor Hodge classes recovers the expected symmetry group in the generic case, and shrinks in the CM case.

The field-opening significance is this: once tensor invariants are formalized, Aristotle can attack **Mumford–Tate groups, motivic Galois groups, period constraints, and Tannakian reconstruction** inside Lean rather than treating them as external black boxes.

---

## New Definitions You Should Introduce

You must define at least one genuinely new concept not already in the catalog. The following package is the right level of ambition.

### 1. A finite-dimensional weight-1 rational Hodge structure
Introduce a structure encoding the minimum data needed for the project.

Suggested Lean sketch:
```lean
structure WeightOneHodgeStructure where
  W : Type
  [addCommGroup_W : AddCommGroup W]
  [module_W : Module ℚ W]
  [finite_W : FiniteDimensional ℚ W]
  hodgeFiltration :
    -- choose one formalization path: decomposition, idempotent, or C-subspaces
    Submodule ℂ (ℂ ⊗[ℚ] W)  -- intended as H^{1,0}
  conj_stable :
    -- compatibility expressing H^{0,1} as complex conjugate complement
    Prop
```

If the decomposition route is cleaner, use:
```lean
structure WeightOneHodgeDecomp where
  W : Type
  [AddCommGroup W] [Module ℚ W] [FiniteDimensional ℚ W]
  H10 : Submodule ℂ (ℂ ⊗[ℚ] W)
  H01 : Submodule ℂ (ℂ ⊗[ℚ] W)
  direct_sum : IsCompl H10 H01
  conj_exchanges : Prop
```

### 2. Tensor-Hodge-class space
Define the subspace of classes of type \((0,0)\) inside \(W^{\otimes p}\otimes (W^\vee)^{\otimes q}\), or if full bidegree formalization is too heavy, define a verified surrogate sufficient for weight-1 low-degree computations.

Suggested Lean-facing notion:
```lean
def tensorPowerDual (H : WeightOneHodgeStructure) (p q : ℕ) : Type := ...

def hodgeClasses (H : WeightOneHodgeStructure) (p q : ℕ) :
    Submodule ℚ (tensorPowerDual H p q) := ...
```

### 3. Tensor-invariant stabilizer
Define the subgroup of \( \mathrm{GL}(W) \) preserving all low-degree Hodge classes:
```lean
def tensorInvariantStabilizer (H : WeightOneHodgeStructure) (N : ℕ) :
    Subgroup (LinearEquiv.GeneralLinearGroup ℚ H.W) := ...
```

This finite-level stabilizer is mathematically meaningful even before full Mumford–Tate formalization. It is also algorithmically testable.

### 4. CM witness / extra endomorphism datum
To separate generic and CM cases, define a structure expressing the existence of a non-scalar \(\mathbb Q\)-endomorphism commuting with the Hodge decomposition:
```lean
structure HasCMWitness (H : WeightOneHodgeStructure) where
  φ : Module.End ℚ H.W
  nonScalar : ¬ ∃ a : ℚ, φ = a • LinearMap.id
  hodge_compatible : Prop
```

This gives a precise formal surrogate for “CM produces extra Hodge tensors.”

---

## Precise Theorem Targets

You must prove at least 3 substantial theorems. The following are the right targets.

### Theorem 1: Evaluation tensor is always a Hodge class
This is the seed invariant from which stabilizer constraints arise.

Mathematical statement:
For any finite-dimensional weight-1 rational Hodge structure \(W\), the canonical evaluation element in \(W \otimes W^\vee\) is a Hodge class.

Suggested Lean type signature:
```lean
theorem evalTensor_mem_hodgeClasses
    (H : WeightOneHodgeStructure) :
    canonicalEvalTensor ℚ H.W ∈ hodgeClasses H 1 1
```

Breakthrough significance:
This theorem is the first Tannakian invariant. It certifies that the formalism is not decorative: the most fundamental categorical tensor already lands in the Hodge-class subspace.

---

### Theorem 2: Scalar-preserving criterion from low-degree tensors in dimension 2
In dimension \(2\), any linear automorphism preserving the canonical contraction tensors acts through the expected classical group constraint.

There are two good variants; prove whichever is more realistic in Lean.

#### Variant A: GL recovery from evaluation-only invariants
If your formalization uses \(W \otimes W^\vee\)-invariants only:
```lean
theorem stabilizer_evalTensor_eq_generalLinear
    (H : WeightOneHodgeStructure)
    (h_dim : FiniteDimensional.finrank ℚ H.W = 2) :
    tensorInvariantStabilizer H 2 = ⊤
```
This is weaker but still useful if the ambient action is already by `GL(W)`.

#### Variant B: Symplectic recovery when a polarization is added
If you enrich the structure with a polarization \(\psi : \Lambda^2 W \to \mathbb Q(-1)\), then the generic weight-1 group should be `GSp`.
Suggested signature:
```lean
theorem stabilizer_lowDegree_eq_GSp_of_generic_dim2
    (H : PolarizedWeightOneHodgeStructure)
    (h_dim : FiniteDimensional.finrank ℚ H.W = 2)
    (h_generic : NoExtraHodgeTensorsUpToDegree H 4) :
    tensorInvariantStabilizer H 4 = similitudeSymplecticSubgroup ℚ H.polarization
```

Breakthrough significance:
This is the first verified low-dimensional instance of the principle “generic Hodge structures have maximal Mumford–Tate group.” Even in dimension 2, that is not bookkeeping; it is a formalized avatar of a central phenomenon in arithmetic geometry.

---

### Theorem 3: CM forces a proper stabilizer
Mathematical statement:
If a weight-1 Hodge structure on a 2-dimensional \(\mathbb Q\)-vector space admits a non-scalar Hodge-compatible endomorphism, then the stabilizer of tensor Hodge classes up to some bounded degree is a proper subgroup of \(\mathrm{GL}(W)\).

Suggested Lean type signature:
```lean
theorem tensorInvariantStabilizer_proper_of_CM
    (H : WeightOneHodgeStructure)
    (h_dim : FiniteDimensional.finrank ℚ H.W = 2)
    (hCM : HasCMWitness H) :
    tensorInvariantStabilizer H 4 < ⊤
```

A more concrete theorem, likely easier to prove:
```lean
theorem exists_tensor_not_preserved_of_not_commuting_CM
    (H : WeightOneHodgeStructure)
    (hCM : HasCMWitness H)
    {g : LinearEquiv.GeneralLinearGroup ℚ H.W}
    (h_not_comm : ¬ Commute (g : Module.End ℚ H.W) hCM.φ) :
    ∃ t ∈ hodgeClasses H 1 1, g • t ≠ t
```

Breakthrough significance:
This theorem is the arithmetic bifurcation between generic and CM elliptic curves, encoded entirely in tensor invariants. It gives Lean a mechanism to *detect hidden endomorphisms through invariant tensors*, which is exactly the kind of bridge needed for future formalized moduli problems.

---

### Theorem 4: Explicit low-degree classification for \(g=1\)
You should aim for a concrete computational theorem for \(p+q \le 4\).

Mathematical statement:
For a non-CM 2-dimensional weight-1 Hodge structure, all Hodge classes in \(W^{\otimes p}\otimes (W^\vee)^{\otimes q}\) for \(p+q\le 4\) are generated by iterated contractions and identity tensors; for a CM structure, there exists at least one additional independent class.

Suggested Lean signature:
```lean
theorem hodgeClasses_low_degree_dim2_nonCM_generated_by_contractions
    (H : WeightOneHodgeStructure)
    (h_dim : FiniteDimensional.finrank ℚ H.W = 2)
    (h_generic : NoExtraHodgeTensorsUpToDegree H 4) :
    ∀ p q : ℕ, p + q ≤ 4 →
      hodgeClasses H p q = contractionGeneratedSubspace H p q
```

and
```lean
theorem hodgeClasses_low_degree_dim2_CM_strictly_larger
    (H : WeightOneHodgeStructure)
    (h_dim : FiniteDimensional.finrank ℚ H.W = 2)
    (hCM : HasCMWitness H) :
    ∃ p q : ℕ, p + q ≤ 4 ∧
      contractionGeneratedSubspace H p q < hodgeClasses H p q
```

Breakthrough significance:
This is the computational heart of the project. It transforms the conjecture into a falsifiable finite test and creates a prototype for machine-assisted Hodge-theoretic experimentation.

---

## Lean 4 Formalization Guidance

Because full algebraic-group Mumford–Tate formalization may be too large for one cycle, target a **finite-level Tannakian approximation**:

\[
\mathrm{MT}_{\le N}(W) := \bigcap_{p+q\le N} \mathrm{Stab}(\mathrm{Hdg}(W^{\otimes p}\otimes (W^\vee)^{\otimes q})).
\]

Then prove:
- monotonicity in \(N\),
- generic equality with the expected classical group for \(N=4\) in dimension 2,
- strict shrinking in the CM case.

Suggested theorem:
```lean
theorem tensorInvariantStabilizer_antiMonotone
    (H : WeightOneHodgeStructure) {N M : ℕ} (hNM : N ≤ M) :
    tensorInvariantStabilizer H M ≤ tensorInvariantStabilizer H N
```

This gives a real research scaffold and avoids overpromising on full algebraic-group machinery.

---

## Proof Strategy Architecture

You must not rely on trivial automation. Use multi-step proofs with induction, `rcases`, `by_contra`, `field_simp`, and structured `calc`.

### Strategy A: Tannakian-from-tensors route
Most promising.

1. **Build tensor actions explicitly.**  
   Define the action of `GL(W)` on `W^{⊗ p} ⊗ (W^∨)^{⊗ q}` and verify functoriality under composition.
2. **Construct canonical invariant tensors.**  
   Show evaluation and contraction tensors are Hodge classes by direct decomposition into \((1,0)\) and \((0,1)\)-pieces.
3. **Identify stabilizers via commutants.**  
   In dimension 2, prove that preserving all contraction-generated tensors forces commutation with the same endomorphism algebra as the expected generic/CM group.

Why this is most promising: it stays close to existing linear algebra in Mathlib and replaces deep algebraic-group formalization with explicit finite-dimensional invariant theory.

### Strategy B: Matrix classification in dimension 2
Very viable for the low-degree elliptic-curve case.

1. Choose a basis and represent tensors and endomorphisms as matrices.
2. Compute the low-degree Hodge classes explicitly in matrix coordinates.
3. Solve the stabilizer equations and show:
   - generic case gives the maximal expected matrix subgroup,
   - CM case imposes extra commutation equations, hence properness.

Use `Matrix`, `LinearMap.toMatrix`, determinant conditions, and `field_simp` for rational-function identities.

Why useful: explicit and computationally checkable; ideal for `demo.py`.

### Strategy C: Representation-theoretic route through Schur–Weyl style decomposition
Most conceptually powerful, but probably heavier.

1. Decompose low-degree tensor powers under `GL₂`.
2. Identify invariant lines/subspaces corresponding to contractions.
3. Show extra Hodge classes correspond to extra endomorphisms, i.e. a larger commutant.

Why valuable: this is the conceptual bridge to future work on motivic Galois groups and Tannakian categories, even if only partially formalized now.

---

## Cross-Domain Connections You Must Explicitly Exploit

This project should not remain trapped inside pure Hodge theory. Include at least one theorem or discussion tying it to another domain.

### 1. Algebraic geometry + representation theory
The Mumford–Tate group is a symmetry group recovered from tensor invariants; this is a concrete Tannakian reconstruction principle. Make this explicit in the paper and code organization.

### 2. Arithmetic geometry + quantum information
Tensor invariants and stabilizer groups mirror the role of symmetry constraints in entanglement classification. The space of low-degree Hodge classes behaves like a “selection rule” subspace. Even a modest theorem formalizing stabilizer monotonicity or extra-invariant detection can be framed as a rigorous analogue of symmetry-protected observables.

Possible cross-domain theorem:
```lean
theorem commutant_detects_extra_invariants
    (H : WeightOneHodgeStructure)
    (φ : Module.End ℚ H.W) :
    φ ∈ hodgeCompatibleEndomorphisms H →
    associatedTensor φ ∈ hodgeClasses H 1 1
```
This turns endomorphism symmetry into observable tensor data, directly echoing physics-style conserved quantities.

### 3. Arithmetic geometry + algorithmic invariant theory
Your low-degree tensor classification should lead to a verified algorithm deciding whether a candidate dimension-2 Hodge structure behaves generically or CM-like from finite tensor data. This is the computational seed of machine-assisted period classification.

---

## Application Keywords

Include these explicitly in the paper, article, and future directions:

**Tannakian reconstruction, Mumford–Tate group, Hodge classes, tensor invariants, CM elliptic curves, generic symplectic monodromy, motivic Galois symmetry, invariant theory, representation theory, algorithmic arithmetic geometry, symbolic tensor computation, symmetry detection, formalized Hodge theory, quantum symmetry analogies.**

---

## Computational / Algorithmic Deliverable

You must produce a verified algorithm, not just theorems.

### Required algorithm
Implement a procedure that, for low-dimensional input data encoding a weight-1 Hodge structure and a bound \(N\), computes the finite-level tensor-invariant stabilizer constraints up to degree \(N\).

At minimum, for the dimension-2 case:
- enumerate tensor types \((p,q)\) with \(p+q\le 4\),
- construct contraction-generated tensors,
- optionally incorporate a CM witness tensor,
- test whether a given matrix preserves all these tensors.

Suggested API:
```lean
def preservesLowDegreeHodgeTensors
    (H : WeightOneHodgeStructure) (N : ℕ)
    (g : LinearEquiv.GeneralLinearGroup ℚ H.W) : Bool := ...
```

and prove a soundness theorem:
```lean
theorem preservesLowDegreeHodgeTensors_sound
    (H : WeightOneHodgeStructure) (N : ℕ)
    (g : LinearEquiv.GeneralLinearGroup ℚ H.W) :
    preservesLowDegreeHodgeTensors H N g = true →
    g ∈ tensorInvariantStabilizer H N
```

If decidability is feasible in your concrete dimension-2 matrix model, also prove completeness there.

---

## demo.py Requirements

Your `demo.py` must:
1. instantiate a toy non-CM elliptic-style weight-1 structure,
2. instantiate a toy CM-style structure with an extra endomorphism,
3. compute low-degree invariant tensors for \(p+q\le 4\),
4. test sample matrices for membership in the finite-level stabilizer,
5. visibly demonstrate the generic/CM bifurcation.

The demo should print:
- basis descriptions of low-degree invariant spaces,
- whether the stabilizer constraints are maximal or proper,
- a witness matrix failing preservation in the CM case.

---

## Falsifiable Conjecture and Testable Prediction

You must include at least one falsifiable conjecture with a clear computational disproof criterion.

### Primary conjecture
For every 2-dimensional weight-1 rational Hodge structure \(H\), the finite-level stabilizer at degree \(4\) already detects the CM/non-CM dichotomy:
\[
\mathrm{MT}_{\le 4}(H)=
\begin{cases}
\text{maximal expected group} & \text{if } H \text{ is non-CM},\\
\text{a proper subgroup} & \text{if } H \text{ is CM}.
\end{cases}
\]

Lean-friendly statement:
```lean
conjecture degreeFour_detects_CM_dichotomy
    (H : WeightOneHodgeStructure)
    (h_dim : FiniteDimensional.finrank ℚ H.W = 2) :
    (¬ Nonempty (HasCMWitness H)) →
      tensorInvariantStabilizer H 4 = genericExpectedSubgroup H
```
and
```lean
conjecture degreeFour_CM_implies_proper
    (H : WeightOneHodgeStructure)
    (h_dim : FiniteDimensional.finrank ℚ H.W = 2) :
    Nonempty (HasCMWitness H) →
      tensorInvariantStabilizer H 4 < genericAmbientSubgroup H
```

### Computational refutation criterion
Refutation occurs if either:
1. a CM witness exists but every low-degree tensor stabilizer up to degree 4 is still maximal, or
2. a purported non-CM example exhibits an extra independent low-degree Hodge tensor beyond contraction-generated ones.

That gives a clear test harness for `demo.py`.

---

## Minimum Theorem Count and Proof Depth

Your Lean development must include **at least 3 deep theorems** whose proofs are not trivial and visibly use nontrivial tactics or constructions such as:
- induction on tensor degree,
- `rcases` decomposition of tensor/Hodge data,
- `by_contra` for properness or uniqueness arguments,
- `field_simp` in matrix-coordinate stabilizer calculations,
- multi-step `calc` chains for tensor action identities.

Good candidates:
- anti-monotonicity of stabilizers,
- evaluation tensor is Hodge,
- properness from CM witness,
- low-degree generation by contractions.

---

## Deliverables — ALL REQUIRED

You must produce all of the following:

1. **Lean file(s)** with the new definitions and at least 3 substantial theorems, minimizing `sorry`.
2. **FUTURE_DIRECTIONS.md** containing **3–5 testable scientific hypotheses**, each falsifiable with a clear experimental or computational protocol.
3. **RESEARCH_PAPER.md** as a **standalone scientific paper** explaining:
   - the exact definitions,
   - the main theorems,
   - why finite-level tensor stabilizers matter,
   - how the CM/non-CM dichotomy appears,
   - what this opens for formalized arithmetic geometry.
4. **ARTICLE.md** in Scientific American style, accessible but intellectually serious, explaining how hidden symmetries of elliptic curves can be recovered from the tensors they preserve.
5. **A verified algorithm/computational method** for finite-level stabilizer detection.
6. **demo.py** showing the explicit low-degree tensor computations and generic/CM separation interactively.

---

## Final Research Vision

If you execute this well, you will not merely formalize a conjectural slogan. You will create the first Lean-native prototype of **Tannakian Hodge detection**: recovering hidden arithmetic symmetry groups from finitely many tensor observables. That is the seed of a future formal theory of Mumford–Tate groups, motivic Galois groups, and period symmetries.

The real prize is not just \(g=1\). The real prize is a new formal language in which **arithmetic geometry becomes computable through invariant tensors**.

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
