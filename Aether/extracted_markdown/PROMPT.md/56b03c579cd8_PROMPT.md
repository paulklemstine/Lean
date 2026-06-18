## Assignment: Direction 1: Non-Abelian Arithmetic Phase Classification — Abelianization Torsion Completeness and Its Failure

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

---

### The Central Problem

The catalog establishes torsion detection for *abelian* groups via `HasPTorsion_ZMod_iff_dvd` and `torsionProfileUpTo_prod`. The grand challenge: does the abelianization functor $G \mapsto G^{\mathrm{ab}} = G/[G,G]$ extend this to *all* finite groups? **No.** The conjecture as originally stated is false — but its *failure* is more revealing than its truth would have been. The correct theorem is a *refinement*: abelianization captures exactly degree-1 homological torsion, and the Schur multiplier $H_2(G,\mathbb{Z})$ measures the obstruction to completeness.

---

### Precise Theorem Statements with Lean 4 Signatures

**Theorem 1 (Abelianization Completeness for Degree-1 Torsion).** For finite groups $G_1, G_2$ with $G_1^{\mathrm{ab}} \cong G_2^{\mathrm{ab}}$, the $p$-primary torsion profiles of $H_1(G_1, \mathbb{Z}/p\mathbb{Z})$ and $H_1(G_2, \mathbb{Z}/p\mathbb{Z})$ are isomorphic at every prime $p$.

```lean
theorem abelianization_determines_H1_torsion
    {G₁ G₂ : Type*} [Group G₁] [Group G₂] [Fintype G₁] [Fintype G₂]
    (h_ab : Nonempty (Abelianization G₁ ≃* Abelianization G₂))
    (p : ℕ) [hp : Fact p.Prime] :
    (torsionInH1 G₁ p).card = (torsionInH1 G₂ p) ∧
    ∀ n ∈ torsionInH1 G₁ p, n ∈ torsionInH1 G₂ p :=
  sorry
```

**Theorem 2 (Abelianization Incompleteness — the $Q_8$ Counterexample).** The quaternion group $Q_8$ and the Klein four-group $V_4 = \mathbb{Z}/2\mathbb{Z} \times \mathbb{Z}/2\mathbb{Z}$ have isomorphic abelianizations $(\mathbb{Z}/2\mathbb{Z})^2$, yet their Schur multipliers differ: $M(Q_8) = 0$ while $M(V_4) \cong \mathbb{Z}/2\mathbb{Z}$. This falsifies the conjecture that abelianization captures *all* prime-level phase information.

```lean
theorem abelianization_incomplete_counterexample :
    -- Q₈ and V₄ have isomorphic abelianizations
    Nonempty (Abelianization QuaternionGroup ≃* 
              Abelianization (ZMod 2 × ZMod 2)) ∧
    -- but different Schur multipliers
    schurMultiplier (QuaternionGroup 2) ≃+ schurMultiplier (ZMod 2 × ZMod 2) → False :=
  sorry
```

**Theorem 3 (Schur Refinement — the Correct Invariant).** The pair $(G^{\mathrm{ab}}, M(G))$ where $M(G) = H_2(G, \mathbb{Z})$ is the Schur multiplier forms a strictly finer invariant. For groups $G$ with $M(G) = 0$ (perfect central extensions excluded), the abelianization alone suffices for degree-1 torsion; the Schur multiplier precisely measures the degree-2 torsion invisible to the abelianization.

```lean
theorem schur_refinement_torsion_classification
    {G : Type*} [Group G] [Fintype G] (p : ℕ) [Fact p.Prime] :
    -- The p-torsion in M(G) classifies the p-primary discrepancy
    -- between H*(G, Z/pZ) and H*(G^ab, Z/pZ) in degree ≥ 2
    (schurMultiplier G).pTorsion p ≃+ 
      (higherTorsionDiscrepancy G p) :=
  sorry
```

---

### Proof Strategies

**Strategy A (Homological Algebra — Recommended).** Use the Lyndon-Hochschild-Serre spectral sequence for the extension $1 \to [G,G] \to G \to G^{\mathrm{ab}} \to 1$. The $E^2$ page has $E^2_{p,q} = H_p(G^{\mathrm{ab}}, H_q([G,G], \mathbb{Z}/p\mathbb{Z}))$. In degree 1, the five-term exact sequence gives $H_1(G, \mathbb{Z}/p\mathbb{Z}) \cong H_1(G^{\mathrm{ab}}, \mathbb{Z}/p\mathbb{Z})$, proving Theorem 1. The differential $d^2: E^2_{2,0} \to E^2_{0,1}$ encodes the Schur multiplier obstruction, proving Theorem 3. **This is most promising** because the spectral sequence cleanly separates the abelianization contribution (degree 1) from the commutator contribution (degree $\geq 2$).

**Strategy B (Direct Group Algebra Computation).** Work with the group algebra $\mathbb{Z}[G]$ directly. The augmentation ideal $I(G) = \ker(\varepsilon: \mathbb{Z}[G] \to \mathbb{Z})$ decomposes as $I(G) = I(G^{\mathrm{ab}}) \oplus J$ where $J$ is the commutator ideal. Show that $J \otimes \mathbb{Z}/p\mathbb{Z}$ has no effect on degree-1 Tor but contributes to degree-2. Compute $J$ explicitly for $Q_8$ and $V_4$ to establish the counterexample. This is more concrete but requires explicit group algebra computations.

**Strategy C (Category-Theoretic Universal Property).** Use the universal property of abelianization: $G^{\mathrm{ab}}$ is the left adjoint to the inclusion $\mathbf{Ab} \hookrightarrow \mathbf{Grp}$. Since $\mathrm{Tor}_1^{\mathbb{Z}[G]}$ is a derived functor of an additive functor that factors through $\mathbf{Ab}$, apply the Grothendieck spectral sequence to obtain the degree-1 isomorphism. The failure at degree 2 follows because the derived functors of the inclusion $\mathbf{Ab} \hookrightarrow \mathbf{Grp}$ are precisely the Schur multiplier.

---

### Cross-Domain Connections

1. **Lattice Gauge Theory ↔ Homological Algebra:** In lattice gauge theory with gauge group $G$, the confinement phase transition depends on the center $Z(G)$ and the abelianization. Theorem 1 proves that *abelian* confinement phases are classified by $G^{\mathrm{ab}}$ alone. Theorem 2 shows that *non-abelian* phases (e.g., $Q_8$ gauge theory vs. $V_4$ gauge theory) exhibit different topological orders invisible to the abelianization — this is the homological shadow of topological order in condensed matter.

2. **Projective Representation Theory ↔ Schur Multiplier:** $M(G) = H_2(G, \mathbb{Z})$ classifies central extensions $1 \to A \to \hat{G} \to G \to 1$ and hence projective representations. Theorem 3 connects torsion detection to representation theory: the torsion invisible to abelianization is exactly the torsion controlling multipliers of projective representations.

3. **Arithmetic Topology ↔ Class Field Theory:** The $p$-primary decomposition of $G^{\mathrm{ab}}$ mirrors the decomposition of ray class groups in number fields. The Schur multiplier obstruction is the non-abelian analogue of the Hilbert class group measuring "invisible ramification."

**Application Keywords:** `non-abelian gauge theory`, `Schur multiplier`, `topological order`, `projective representations`, `spectral sequence`, `group homology`, `torsion classification`, `lattice gauge theory`, `arithmetic topology`

---

### Novel Definitions (Required)

```lean
/-- The Schur multiplier M(G) = H₂(G, ℤ), classifying central extensions -/
noncomputable def schurMultiplier (G : Type*) [Group G] [Fintype G] : Type* :=
  -- Defined as H₂(G, ℤ) via group homology
  sorry

/-- The derived torsion profile: pairs (abelianization torsion, Schur multiplier torsion) -/
noncomputable def derivedTorsionProfile 
    (G : Type*) [Group G] [Fintype G] (p : ℕ) : Finset ℕ :=
  -- p-primary torsion orders in G^ab ∪ p-primary torsion orders in M(G)
  sorry

/-- The homological detectability boundary: the smallest degree at which 
    abelianization fails to capture torsion -/
noncomputable def detectabilityBoundary (G : Type*) [Group G] [Fintype G] : ℕ :=
  -- inf {n | H_n(G, ℤ) has torsion invisible to G^ab}
  sorry
```

---

### Conjecture with Testable Prediction

**Conjecture (Schur-Torsion Monotonicity):** For any finite group $G$ and prime $p$ dividing $|G|$, the detectability boundary satisfies $\mathrm{bd}(G) \leq 2$. That is, abelianization captures all degree-1 torsion, and all residual torsion appears in degree exactly 2 (the Schur multiplier).

**Test:** Compute $H_n(G, \mathbb{Z}/p\mathbb{Z})$ for $n = 1, 2, 3$ for all groups of order $\leq 32$ (there are 228 such groups). If any group has torsion in $H_3$ invisible to both $G^{\mathrm{ab}}$ and $M(G)$, the conjecture is falsified. The test can be implemented in GAP via the `HAP` package.

---

### Depth Requirements (MANDATORY)

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.

3. **Novel definitions**: `schurMultiplier`, `derivedTorsionProfile`, `detectabilityBoundary` are novel — confirm they do not exist in the catalog.

4. **Cross-domain connections**: Theorems must connect to lattice gauge theory (degree-1 confinement classification) and projective representation theory (Schur multiplier as obstruction).

5. **Conjecture with testable prediction**: Schur-Torsion Monotonicity conjecture above, falsifiable by exhaustive computation for groups of order $\leq 32$.

---

### Catalog References to Build On

- `Pythagorean/ArithmeticPhaseClassification.lean`: `HasPTorsion_ZMod_iff_dvd` — extend from cyclic groups to group algebras via abelianization
- `Pythagorean/ArithmeticPhaseClassification.lean`: `torsionProfileUpTo_prod` — extend from products of cyclic groups to products of arbitrary finite groups via the Schur multiplier correction
- `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean`: `torsion_invisible_wrong_characteristic` — use this to prove that the Schur multiplier captures exactly the torsion invisible to abelianization

---

### Lineage

Extends `HasPTorsion_prod_iff` from products of cyclic groups to arbitrary finite groups, introducing the Schur multiplier as the correction term that makes the classification complete.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3–5 testable scientific hypotheses:
   - Schur-Torsion Monotonicity (degree-2 completeness)
   - The detectability boundary equals 2 for all finite solvable groups
   - The derived torsion profile is a complete invariant for nilpotent groups of class ≤ 2
   - For $p$-groups, $M(G)$ determines the $p$-primary torsion in $H_n$ for all $n$
   - The conjecture extends to profinite groups via inverse limits

(b) **RESEARCH_PAPER.md** — standalone scientific document explaining the abelianization completeness theorem, the $Q_8$ counterexample, and the Schur multiplier refinement, readable without access to code.

(c) **ARTICLE.md** — Scientific American style, titled "The Invisible Shape of Symmetry: How Mathematicians Discovered What Group Theory Missed." Explain how the humble abelianization captures most but not all of a group's torsion character, and how the Schur multiplier reveals the hidden structure. TABOO: Do NOT focus on formal verification.

(d) **Verified algorithm**: A computational method `computeDerivedTorsionProfile` that, given a finite group presentation, computes the derived torsion profile $(G^{\mathrm{ab}} \text{ torsion}, M(G) \text{ torsion})$ at each prime.

(e) **demo.py** implementing the derived torsion profile computation for $S_3$, $A_4$, $Q_8$, $D_4$, and $V_4$, demonstrating the counterexample and the refinement.

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
