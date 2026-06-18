## Assignment: Unified Certificate Generation for Classical Groups — SL_n, Sp_{2n}, and Beyond

**Mode: discover + prove**

Prove new, non-trivial theorems that establish the first unified certificate framework across classical group families. Build on catalog theorems in `Algebra/MatrixGroupGeneration.lean`. Minimize sorry.

---

### The Core Breakthrough

The catalog establishes that GL_n(F_q) is generated with probability 1 - O(1/q) by pairs of elements with irreducible characteristic polynomial, at density Θ(1/n). The conjecture: **this Θ(1/n) certificate density phenomenon is universal across all classical group families**, but the certificate predicate must be adapted to the group's intrinsic structure. This is not merely an extension — it reveals that *irreducibility of the natural representation, appropriately constrained, is the universal key to random generation*.

---

### Precise Theorem Targets

**Theorem 1 (SL_n Certificate Density).** For n ≥ 2 and a finite field F_q with q > 2, define `SLCertificate A := Irreducible (charpoly A) ∧ A.det = 1`. Then the density of certified elements in SL_n(F_q) is Θ(1/n), and two independent uniform certified elements generate SL_n(F_q) with probability 1 - O(1/q).

Lean 4 signature:
```lean
theorem sl_certificate_density (n : ℕ) (hn : n ≥ 2) (q : ℕ) (hq : q > 2) 
    (F : Type*) [Field F] [Fintype F] [hcard : Fintype.card F = q] :
    ∃ c₁ c₂ : ℝ, 0 < c₁ ∧ c₂ > 0 ∧
      ∀ (A : Matrix (Fin n) (Fin n) F) (_ : A ∈ Matrix.SpecialLinearGroup (Fin n) F),
        (SLCertificate A → 1) ∈ Θ[filter] (1/n) := by sorry

theorem sl_certified_generation (n : ℕ) (hn : n ≥ 2) (q : ℕ) (hq : q > 2)
    (F : Type*) [Field F] [Fintype F] [hcard : Fintype.card F = q] :
    ∃ C : ℝ, ∀ g₁ g₂ ∈ {A : Matrix.SpecialLinearGroup (Fin n) F // SLCertificate A.val},
      (Subgroup.closure {g₁, g₂} = ⊤) ∨ 
      (1 - (C / q : ℝ) ≤ P[g₁, g₂ generate SL_n(F_q)]) := by sorry
```

**Theorem 2 (Sp_{2n} Certificate via Self-Reciprocal Irreducibles).** For n ≥ 1 and finite field F_q with char(F) ≠ 2, define `SpCertificate A := Irreducible (charpoly A) ∧ IsSelfReciprocal (charpoly A) ∧ A ∈ symplecticGroup n F`. Then certified elements have density Θ(1/n) in Sp_{2n}(F_q) and generate with probability 1 - O(1/q).

Lean 4 signature:
```lean
/-- A polynomial is self-reciprocal if f(x) = x^d * f(1/x) where d = natDegree f -/
def IsSelfReciprocal {R : Type*} [Semiring R] (f : R[X]) : Prop :=
  f = f.reverse ∧ f.Monic

/-- Certificate for symplectic group generation -/
def SpCertificate {n : ℕ} {F : Type*} [Field F] [Fintype F] 
    (A : Matrix (Fin (2*n)) (Fin (2*n)) F) : Prop :=
  Irreducible (A.charpoly) ∧ IsSelfReciprocal (A.charpoly) ∧ A ∈ symplecticGroup n F

theorem sp_certificate_density (n : ℕ) (q : ℕ) (hq : q > 2) (hchar : ¬(2 ∣ q))
    (F : Type*) [Field F] [Fintype F] [hcard : Fintype.card F = q] :
    ∃ c₁ c₂ : ℝ, 0 < c₁ ∧ c₂ > 0 ∧
      (density_of_SpCertificate_in_Sp : ℝ) ∈ Θ[filter] (1/n) := by sorry
```

**Theorem 3 (Cross-Domain: Quantum Entangling Power Bound).** For the symplectic group Sp_{2n}(F_2) (the Clifford group modulo phases), the probability that a uniformly random element has irreducible self-reciprocal characteristic polynomial is Θ(1/n). This directly bounds the probability that a random n-qubit Clifford circuit acts irreducibly on the stabilizer subspace.

```lean
theorem clifford_entangling_bound (n : ℕ) (hn : n ≥ 1) :
    (P[g ∈ Sp_{2n}(F_2) has Irreducible charpoly ∧ IsSelfReciprocal charpoly] : ℝ)
      = (1/n) * (1 - 1/2 + O(1/2^n)) := by sorry
```

---

### Proof Strategies

**Strategy A (Counting via Function-Field Chebotarev — Most Promising).**

*Why most promising:* Directly reduces to counting irreducible polynomials with prescribed constraints, which is a well-understood problem in algebraic geometry over finite fields.

Steps:
1. **SL_n**: The characteristic polynomial of A ∈ SL_n(F_q) is monic of degree n with constant term (-1)^n. Count monic irreducible polynomials of degree n over F_q with constant term (-1)^n. By the function-field Chebotarev theorem (applied to the splitting field of x^n - (-1)^n), this count is (1/n)q^n(1 - 1/q) + O(q^{n/2}/n), giving density Θ(1/n). Build on `irreducible_count` in Mathlib's `FieldTheory/Finite/Basic.lean` and extend to prescribed constant term.

2. **Sp_{2n}**: An irreducible self-reciprocal polynomial of degree 2n corresponds to a Galois orbit in F_{q^{2n}}^* stable under α ↦ α^{-1}. Such orbits have size 2n (since α^{q^k} ≠ α^{-1} for k < 2n when f is irreducible of degree 2n). The count is (q^n - 1)/(2n) for q odd, giving density Θ(1/n) in Sp_{2n}(F_q) which has order q^{n^2} ∏_{i=1}^n(q^{2i}-1).

3. **Generation**: Apply the irreducible-action argument from the catalog's `Theorem 1` (irreducible action theorem) mutatis mutandis — a certified element acts irreducibly on the natural module, so any proper invariant subgroup must be in the center, which is trivial for SL_n (n ≥ 2) and Sp_{2n} (n ≥ 1).

**Strategy B (Restriction from GL_n — For SL_n only).**

The natural projection GL_n(F_q) → F_q^* has kernel SL_n(F_q). A certified GL_n element with det = 1 restricts to a certified SL_n element. Use the GL_n density result from the catalog and condition on det = 1. This avoids re-proving irreducibility but only works for SL_n, not for Sp_{2n} or O_n.

**Strategy C (Weil Character Sums — For precise O(1/q) bounds).**

Use Weil's bound on character sums to get sharp generation probability bounds. The key sum is Σ_{A certified} χ(det(A)) where χ is a non-trivial character of the group. Weil's Riemann hypothesis for curves gives |Σ| ≤ (2n-1)q^{n/2}, which is negligible compared to the main term. This gives the 1 - O(1/q) bound precisely. Reference: Weil's "On the Riemann hypothesis for curves over finite fields" and the Deligne estimates.

*Recommendation:* Use Strategy A for the main density results, Strategy C for the generation probability bounds, and Strategy B as a consistency check for SL_n.

---

### Novel Definitions Required

```lean
/-- Self-reciprocal (palindromic) polynomial: coefficients read the same forwards and backwards -/
def IsSelfReciprocal {R : Type*} [Semiring R] (f : R[X]) : Prop :=
  f.Monic ∧ f.reverse = f

/-- Certificate predicate parametrized by group family -/
class GroupCertificate (G : Type*) [Group G] (ι : outParam Type*) where
  certified : ι → G → Prop
  density_bound : ∃ c₁ c₂, ∀ n, c₁/n ≤ density (certified n) ≤ c₂/n
  generation_prob : ∃ C, P[∀ g₁ g₂ certified, ⟨g₁,g₂⟩ = G] ≥ 1 - C/q

/-- The symplectic J-matrix (standard symplectic form) -/
def symplecticJ (n : ℕ) : Matrix (Fin (2*n)) (Fin (2*n)) F :=
  Matrix.fromBlocks 0 1 (-1) 0  -- block form [0 I; -I 0]

/-- Symplectic group via the standard form -/
def symplecticGroup (n : ℕ) (F : Type*) [Field F] [Fintype F] :=
  {A : Matrix (Fin (2*n)) (Fin (2*n)) F // A * symplecticJ n * Aᵀ = symplecticJ n ∧ A.det = 1}
```

---

### Falsifiable Conjecture with Computational Test

**Conjecture (Universal Certificate Density).** *For every classical group family G_n(F_q) ∈ {SL_n, Sp_{2n}, SO_n^±, U_n}, there exists a certificate predicate C_n defined by irreducibility of the characteristic polynomial plus family-specific constraints (det = 1 for SL_n, self-reciprocity for Sp_{2n}, etc.) such that the density of certified elements is Θ(1/n) and two independent certified elements generate with probability 1 - O(1/q).*

**Computational test that could disprove it:**

```python
# For O_n^±(F_q): test whether irreducible charpoly + orthogonal constraint
# gives density Θ(1/n) or not.
# 
# For n=2, q=3: enumerate O_2^+(F_3) and O_2^-(F_3).
# Count elements with irreducible charpoly.
# If density ∉ [c₁/n, c₂/n] for any reasonable c₁, c₂, the conjecture fails.
#
# Key subtlety: for orthogonal groups, the charpoly of an orthogonal matrix
# satisfies f(x) = x^n f(1/x), which for n=2 means f is self-reciprocal.
# An irreducible self-reciprocal quadratic over F_q has the form
# x² - tx + 1 with t² ≠ 4. The number of such polynomials is (q-1)/2 for q odd.
# But |O_2^+(F_q)| = 2(q-1), so density ≈ (q-1)/(4(q-1)) = 1/4 for n=2,
# which is Θ(1/n) = Θ(1/2). ✓
#
# For n=3, q=3: |SO_3(F_3)| = 24. Irreducible cubic charpolys with 
# orthogonal constraint... this is where it gets interesting.
```

If the orthogonal group density deviates from Θ(1/n) for any tested (n, q), the conjecture fails for that family and the certificate must be redesigned.

---

### Cross-Domain Connections

1. **Quantum Information (Primary Bridge):** Sp_{2n}(F_2) ≅ Cl_n/Stab(1) (Clifford group modulo global phase). The certificate density Θ(1/n) means a Θ(1/n) fraction of random Clifford operations act irreducibly on stabilizer space — directly bounding the *entangling power* of random Clifford circuits. This has implications for randomized benchmarking and quantum error correction.

2. **Symplectic Geometry & Hamiltonian Dynamics:** Sp_{2n}(Z) is the structure group of Hamiltonian mechanics. The finite-field analog Sp_{2n}(F_q) appears in arithmetic symplectic dynamics. Generation by certified elements implies *transitivity of the symplectic Cremona group* over finite fields.

3. **Algebraic Topology:** The monodromy group of a Lefschetz fibration is a subgroup of Sp_{2g}(Z). Reducing mod p gives Sp_{2g}(F_p). Our generation result implies that *generic monodromy representations are surjective*, connecting to the Zariski-density results of Looijenga and A'Campo.

4. **Cryptography:** Random element generation in classical groups is a subroutine in several post-quantum cryptosystems (e.g., lattice-based schemes using symplectic bases). Certified generation provides *verifiable randomness* — a rare property in cryptographic group operations.

---

### Depth Requirements Checklist

- [x] **NO trivial proofs**: All theorems require substantial counting arguments, group theory, and polynomial algebra
- [x] **At least 3 theorems with deep proof tactics**: Theorem 1 requires induction on polynomial degree + rcases for Galois orbit analysis; Theorem 2 requires by_contra for density lower bounds; Theorem 3 requires multi-step calc for the entangling power bound
- [x] **Novel definitions**: `IsSelfReciprocal`, `GroupCertificate` typeclass, `SpCertificate`, `symplecticGroup` definition
- [x] **Cross-domain connections**: Quantum Clifford circuits (Theorem 3), symplectic geometry, algebraic topology
- [x] **Falsifiable conjecture**: Universal certificate density with explicit computational test for O_n^±

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 directions. Each must include "The key insight is..." and "Why now?" At least one must bridge to a different domain (suggest: quantum error correction via Clifford group certification).

(b) **RESEARCH_PAPER.md** — standalone scientific document proving: (1) SL_n certificate density Θ(1/n) via prescribed-constant-term irreducible polynomial counting, (2) Sp_{2n} certificate density Θ(1/n) via self-reciprocal irreducible polynomial counting, (3) the universal generation probability bound 1 - O(1/q). Must include the function-field Chebotarev argument and the Weil character sum bound.

(c) **ARTICLE.md** — Scientific American style. Tell the story: "Every important family of matrices in mathematics — from the special linear matrices preserving volume, to the symplectic matrices preserving Hamilton's equations, to the orthogonal matrices preserving distance — shares a hidden property. A thin but sufficient slice of each family, characterized by a single elegant condition on their characteristic polynomial, is enough to generate the entire group. This Θ(1/n) density phenomenon unifies classical groups the way the periodic table unifies elements." Do NOT focus on formal verification.

(d) **Verified algorithm**: Implement `certified_classical_group_sampler(G, n, q)` that samples certified elements from each classical group family and verifies generation by certified pairs. Include the density computation and the generation test.

(e) **demo.py**: Interactive demonstration showing:
   - Certificate densities for SL_n, Sp_{2n}, O_n across small parameters
   - Generation probability by certified pairs vs. random pairs
   - The quantum entangling power connection for Sp_{2n}(F_2) (Clifford group)
   - Animated visualization of the Θ(1/n) density curve across group families

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

Research domain: Pythagorean
Research mode: prove
