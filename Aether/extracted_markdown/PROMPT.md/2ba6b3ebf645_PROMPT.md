## Soli Deo Gloria

## Assignment: Direction 1: Non-Abelian Arithmetic Phase Classification — The Abelianization Principle and Its Obstructions

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

**Ambition:** grand_challenge

**The Deep Question:** When does the abelianization of a non-abelian group capture ALL homologically detectable arithmetic phase information? The naive conjecture — that $G^{\text{ab}}$ always suffices — is **false**, and proving this false is as important as identifying the correct class of groups where it holds. The truth involves a subtle interplay between the commutator subgroup's structure and the Lyndon-Hochschild-Serre spectral sequence.

---

### Precise Theorem Targets

**Theorem 1 (Abelianization Torsion Detection for p-Perfect Commutators):**
Let $G$ be a finite group, $p$ a prime. If the commutator subgroup $[G,G]$ is $p$-perfect (i.e., $H_1([G,G]; \mathbb{Z})$ has no $p$-torsion, equivalently $([G,G])^{\text{ab}}$ has no element of order $p$), then the $p$-primary torsion profile of $\mathbb{Z}[G]$ in $\text{Tor}_1^{\mathbb{Z}[G]}(\mathbb{Z}, \mathbb{Z})$ agrees with that of $\mathbb{Z}[G^{\text{ab}}]$.

```lean
theorem abelianization_detects_torsion_of_pPerfect_commutator
    (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    (p : ℕ) [hp : Fact (Nat.Prime p)]
    (h_comm_pPerfect : ¬HasPTorsion (Abelianization.commutator G) p) :
    torsionProfile (ℤ[G]) p = torsionProfile (ℤ[Abelianization G]) p := by
  sorry
```

**Theorem 2 (Obstruction: The Commutator Homology Class):**
The obstruction to abelianization detecting $p$-torsion is precisely the $p$-torsion in $H_2([G,G]; \mathbb{Z})^{G^{\text{ab}}}$ — the $G^{\text{ab}}$-invariant part of the second homology of the commutator subgroup. When this vanishes, the LHS spectral sequence collapses and abelianization suffices.

```lean
theorem torsion_obstruction_is_commutator_H2_invariant
    (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    (p : ℕ) [hp : Fact (Nat.Prime p)] :
    torsionProfile (ℤ[G]) p ≠ torsionProfile (ℤ[Abelianization G]) p ↔
    HasPTorsion (groupHomology (Abelianization.commutator G) 2 ⧸
      (actionInvariantSubmodule (Abelianization.commutator G) (Abelianization G))) p := by
  sorry
```

**Theorem 3 (Counterexample: $D_4$ vs $Q_8$):**
The dihedral group $D_4$ and the quaternion group $Q_8$ both have abelianization $\mathbb{Z}/2 \times \mathbb{Z}/2$, but their $2$-torsion profiles differ: $H_2(D_4; \mathbb{Z}) = 0$ while $H_2(Q_8; \mathbb{Z}) \cong \mathbb{Z}/2$. This falsifies the strong conjecture that abelianization always captures torsion.

```lean
theorem D4_Q8_same_abelianization_different_torsion :
    Abelianization (DihedralGroup 4) ≃* (ZMod 2 × ZMod 2) ∧
    Abelianization (QuaternionGroup 2) ≃* (ZMod 2 × ZMod 2) ∧
    torsionProfile (ℤ[DihedralGroup 4]) 2 ≠
    torsionProfile (ℤ[QuaternionGroup 2]) 2 := by
  sorry
```

**Theorem 4 (Cross-Domain: Lattice Gauge Theory Phase Equivalence):**
Two non-abelian lattice gauge theories with gauge groups $G_1, G_2$ have the same confining phase structure at prime $p$ if and only if $G_1^{\text{ab}} \cong G_2^{\text{ab}}$ AND the $p$-torsion in $H_2([G_i, G_i]; \mathbb{Z})^{G_i^{\text{ab}}}$ agrees for $i = 1, 2$. This connects group cohomology to the confinement/deconfinement phase transition in Hamiltonian lattice gauge theory.

```lean
theorem lattice_gauge_phase_equivalence_iff
    (G₁ G₂ : Type*) [Group G₁] [Group G₂] [Fintype G₁] [Fintype G₂]
    [DecidableEq G₁] [DecidableEq G₂]
    (p : ℕ) [Fact (Nat.Prime p)]
    (e : Abelianization G₁ ≃* Abelianization G₂) :
    gaugePhaseProfile G₁ p = gaugePhaseProfile G₂ p ↔
    torsionProfile (groupHomology (Abelianization.commutator G₁) 2 ⧸
      actionInvariantSubmodule _ _) p =
    torsionProfile (groupHomology (Abelianization.commutator G₂) 2 ⧸
      actionInvariantSubmodule _ _) p := by
  sorry
```

---

### Proof Strategies

**Strategy A (LHS Spectral Sequence Collapse):** Use the Lyndon-Hochschild-Serre spectral sequence for the extension $1 \to [G,G] \to G \to G^{\text{ab}} \to 1$. The $E^2$ page has $E^2_{s,t} = H_s(G^{\text{ab}}, H_t([G,G], \mathbb{Z}))$. When $[G,G]$ is $p$-perfect, $H_1([G,G])$ has no $p$-torsion, and by induction on the LHS filtration, the $p$-torsion in $H_n(G)$ comes entirely from $H_n(G^{\text{ab}})$. **This is the most promising approach** because it gives a structural reason for the collapse and naturally produces the obstruction class.

**Strategy B (Shapiro's Lemma and Induced Modules):** Use Shapiro's lemma to identify $\text{Tor}_*^{\mathbb{Z}[G]}(\mathbb{Z}, M)$ with $\text{Tor}_*^{\mathbb{Z}[[G,G]]}(\mathbb{Z}, \text{Res}_{[G,G]} M)$ for appropriate modules $M$. Then use the fact that $\mathbb{Z}[G] \cong \mathbb{Z}[G^{\text{ab}}] \otimes_{\mathbb{Z}} \mathbb{Z}[[G,G]]^{\text{conj}}$ as $\mathbb{Z}[G^{\text{ab}}]$-modules, where the conjugation action creates the obstruction. **Less promising** because the tensor decomposition is not natural in the derived sense.

**Strategy C (Universal Coefficient Theorem for Group Algebras):** Apply the universal coefficient theorem to relate $\text{Tor}^{\mathbb{Z}[G]}_*(\mathbb{Z}, \mathbb{Z})$ to $\text{Tor}^{\mathbb{Z}[G^{\text{ab}}]}_*(\mathbb{Z}, \mathbb{Z})$ via the change-of-rings spectral sequence. The key step is showing that the edge homomorphism is an isomorphism on $p$-torsion when $[G,G]$ is $p$-perfect. **Promising as a verification method** but harder to make constructive.

---

### Novel Definitions Required

```lean
/-- A group is p-perfect if its abelianization has no element of order p.
    This is the key structural condition for abelianization to detect torsion. -/
class IsPPerfect (G : Type*) [Group G] [Fintype G] (p : ℕ) [Fact (Nat.Prime p)] : Prop where
  no_ptorsion : ∀ g : Abelianization G, g ≠ 1 → ¬(p • g = 1)

/-- The arithmetic torsion profile of a group algebra at prime p:
    maps to the p-adic valuation of the torsion in each Tor group. -/
noncomputable def arithmeticTorsionProfile
    (G : Type*) [Group G] [Fintype G] (p : ℕ) [Fact (Nat.Prime p)] : ℕ → ℕ :=
  fun n => padicValNat p (Fintype.card (groupHomology G n))

/-- The gauge phase profile: classifies confinement phases by torsion data.
    Connects to Fröhlich's work on arithmetic gauge theory. -/
noncomputable def gaugePhaseProfile
    (G : Type*) [Group G] [Fintype G] (p : ℕ) [Fact (Nat.Prime p)] :
    ArithmeticPhaseClass := by
  -- constructed from arithmeticTorsionProfile
  sorry
```

---

### Catalog Building Blocks

1. **`HasPTorsion_ZMod_iff_dvd`** from `Pythagorean/ArithmeticPhaseClassification.lean`: Use this to detect $p$-torsion in the abelianization $G^{\text{ab}}$, which is a product of $\mathbb{Z}/n$ factors. Extend the `iff` to products of arbitrary finite abelian groups.

2. **`torsionProfileUpTo_prod`** from the same file: This handles torsion profiles of direct products. Extend to semidirect products $G = [G,G] \rtimes G^{\text{ab}}$ using the LHS spectral sequence as a "twisted product" generalization.

3. **`torsion_invisible_wrong_characteristic`** from `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean`: This shows that torsion can be "invisible" at the wrong characteristic. Use this to explain why $p$-perfectness of $[G,G]$ makes commutator torsion invisible at $p$.

---

### Cross-Domain Connections

**Algebraic Topology ↔ Lattice Gauge Theory:** The $p$-torsion in $H_2(G; \mathbb{Z})$ classifies the $p$-adic topological order in Hamiltonian lattice gauge theories with gauge group $G$ (Senthil-Levin, Phys. Rev. Lett. 2013). Theorem 2 implies that two gauge groups with isomorphic abelianizations and the same commutator obstruction have identical topological order — a new universality class identification.

**Representation Theory ↔ Arithmetic Geometry:** The group algebra $\mathbb{Z}[G]$ is an order in $\mathbb{Q}[G]$. The torsion profile controls the conductor of the associated Artin $L$-function. Theorem 1 implies that for $p$-perfect commutators, the conductor's $p$-part depends only on $G^{\text{ab}}$ — connecting to the Stark conjectures.

**Cohomology of Groups ↔ Quantum Error Correction:** The $p$-torsion in $H_2(G; \mathbb{Z})$ classifies central extensions by $\mathbb{Z}/p$, which are the symmetry-protected topological phases in $(2+1)$D gauge theories. The obstruction in Theorem 2 is exactly the "anomaly" that prevents gauging the $1$-form symmetry.

---

### Falsifiable Refined Conjecture

**Conjecture (Abelianization Completeness for Supersolvable Groups):** If $G$ is a finite supersolvable group and $p$ does not divide $|[G,G]^{\text{ab}}|$, then the arithmetic torsion profile of $G$ at $p$ is completely determined by $G^{\text{ab}}$.

**Test:** Compute `arithmeticTorsionProfile` at $p = 3$ for $A_4$ (supersolvable, $[A_4, A_4] \cong V_4$, $|V_4^{\text{ab}}| = 4$ not divisible by 3) and compare with $\mathbb{Z}/3$. Then test $p = 2$ for $S_4$ (supersolvable, $[S_4, S_4] \cong A_4$, $|A_4^{\text{ab}}| = 3$, not divisible by 2) comparing with $\mathbb{Z}/2$. If the profiles match in both cases, the conjecture survives. If they differ, the supersolvability hypothesis is insufficient and we need the stronger condition that $[G,G]$ is nilpotent with $p$-group-free abelianization.

**Disproof protocol:** Find a supersolvable group $G$ with $p \nmid |[G,G]^{\text{ab}}|$ but $H_3(G; \mathbb{Z})$ has $p$-torsion not predicted by $G^{\text{ab}}$. The smallest candidate is $S_4$ at $p = 3$.

---

### Revolutionary Significance

This work establishes the **first complete obstruction theory for arithmetic phase classification beyond the abelian case**, solving a problem implicit in Fröhlich's arithmetic gauge theory since 1983. The $D_4$ vs $Q_8$ counterexample (Theorem 3) is the group-theoretic analog of the Jones polynomial distinguishing knots that the Alexander polynomial cannot — it shows that abelianization alone is an insufficient invariant, and identifies the precise homological obstruction. This opens:

1. **Arithmetic SPT classification**: A complete theory of symmetry-protected topological phases for non-abelian gauge groups, with computable invariants.
2. **Derived arithmetic duality**: The LHS spectral sequence provides a "derived abelianization" that captures the lost information, opening a derived approach to Langlands-type correspondences for non-abelian groups.
3. **Computational gauge theory**: Algorithms for computing `gaugePhaseProfile` from group presentations, enabling automated phase classification for lattice models.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 testable scientific hypotheses, each a falsifiable conjecture with a clear computational test. Include the supersolvable completeness conjecture above, a conjecture about nilpotent groups, and a conjecture connecting to Iwasawa theory.

(b) **RESEARCH_PAPER.md** that is a STANDALONE scientific document — someone reading ONLY this paper must understand what was discovered (the obstruction theory for abelianization-detectable torsion), why it matters (classifies when non-abelian gauge theories reduce to abelian ones), and what to investigate next (derived abelianization, higher obstructions).

(c) **ARTICLE.md** written in Scientific American style — explain how the "shadow" of a non-abelian group (its abelianization) sometimes captures everything important about its arithmetic phases, but sometimes misses crucial structure, using $D_4$ and $Q_8$ as the central example. The analogy: abelianization is like a shadow cast by a 3D object; sometimes the shadow determines the object, sometimes it doesn't.

(d) A verified algorithm for computing `arithmeticTorsionProfile` for any finite group presented as a concrete type with decidable equality.

(e) A **demo.py** that:
   - Computes torsion profiles for $S_3$, $A_4$, $D_4$, $Q_8$, $S_4$ using GAP via SAGE
   - Verifies Theorem 3 ($D_4$ vs $Q_8$) computationally
   - Tests the supersolvable completeness conjecture for all supersolvable groups of order ≤ 120
   - Visualizes the "abelianization sufficiency map" — for each group order, what fraction of groups have abelianization-detectable torsion

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
