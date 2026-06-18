## Soli Deo Gloria

## Assignment: Quantum Runge-Lenz Algebra and the Algebraic Derivation of Hydrogen Degeneracy

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.
2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.
3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog.
4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain.
5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

### The Grand Theorem: Hydrogen Degeneracy from so(4) Casimir Eigenvalue

**Precise Statement.** Let $\mathfrak{g}$ be the 7-dimensional real Lie algebra with basis $\{L_1, L_2, L_3, A_1, A_2, A_3, H\}$ and Lie bracket defined by:
- $[L_i, L_j] = i\hbar\,\epsilon_{ijk}\,L_k$
- $[A_i, L_j] = i\hbar\,\epsilon_{ijk}\,A_k$
- $[A_i, A_j] = -\frac{2i\hbar}{m}\,H\,\epsilon_{ijk}\,L_k$
- $[H, \cdot] = 0$ (H is central)

For $E < 0$, define $\alpha = \sqrt{-2mE}$ and the rescaled operators:
$$J_i^+ = \frac{1}{2}\!\left(L_i + \frac{A_i}{\alpha}\right), \qquad J_i^- = \frac{1}{2}\!\left(L_i - \frac{A_i}{\alpha}\right).$$

Then:

**(Theorem A — so(4) Fission):** $[J_i^+, J_j^+] = i\hbar\,\epsilon_{ijk}\,J_k^+$, $\;[J_i^-, J_j^-] = i\hbar\,\epsilon_{ijk}\,J_k^-$, $\;[J_i^+, J_j^-] = 0$.

**(Theorem B — Casimir Identification):** The Casimir operator $C = \mathbf{L}^2 + \mathbf{A}^2/(-2mE)$ satisfies:
$$C = 4\!\left(|\mathbf{J}^+|^2 + |\mathbf{J}^-|^2\right) + \hbar^2.$$

Wait — let me correct this with the standard normalization. The precise Casimir relation is:
$$C = \mathbf{L}^2 + \frac{\mathbf{A}^2}{-2mE} = 4\!\left(|\mathbf{J}^+|^2 + |\mathbf{J}^-|^2\right) - \hbar^2.$$

**(Theorem C — Degeneracy Formula):** On the energy eigenspace $V_n$ with $j^+ = j^- = \frac{n-1}{2}$:
$$C\big|_{V_n} = \hbar^2(n^2 - 1), \qquad \dim V_n = (2j^+ + 1)(2j^- + 1) = n^2.$$

**(Theorem D — Energy Quantization):** From $C = \hbar^2(n^2 - 1)$ and the identity $\mathbf{A}^2 = 2mH(\mathbf{L}^2 + \hbar^2) + mk^2$ (the quantum virial identity for Coulomb), one derives:
$$E_n = -\frac{mk^2}{2\hbar^2 n^2}.$$

---

### Lean 4 Type Signatures

```lean
/-- The quantum Runge-Lenz Lie algebra: 7-dimensional with basis L_i, A_i, H -/
structure RungeLenzLieAlgebra where
  -- The underlying 7-dimensional real vector space
  carrier : Type*
  [addCommGroup : AddCommGroup carrier]
  [module : Module ℝ carrier]
  [finiteDim : FiniteDimensional ℝ carrier]
  [lieRing : LieRing carrier]
  [lieAlgebra : LieAlgebra ℝ carrier]
  -- Designated basis elements
  L : Fin 3 → carrier  -- angular momentum
  A : Fin 3 → carrier  -- Runge-Lenz
  H : carrier          -- Hamiltonian (central)
  -- Axioms with physical constants hbar, m, k parameterized
  hbar : ℝ
  m : ℝ
  k : ℝ
  -- Commutation relations
  hLL : ∀ i j, ⁅L i, L j⁆ = hbar * (LeviCivita i j) • L (cross3 i j)
  hAL : ∀ i j, ⁅A i, L j⁆ = hbar * (LeviCivita i j) • A (cross3 i j)
  hAA : ∀ i j, ⁅A i, A j⁆ = -(2 * hbar / m) • H + (LeviCivita i j) • L (cross3 i j)
  hHL : ∀ i, ⁅H, L i⁆ = 0
  hHA : ∀ i, ⁅H, A i⁆ = 0
  -- Orthogonality L · A = 0 (as Casimir constraint)
  orthog : ∀ i, ⁅L i, A i⁆ = 0  -- simplified; full form needs dot product

/-- The so(4) fission theorem: J⁺ and J⁻ form commuting su(2) subalgebras -/
theorem so4_fission (R : RungeLenzLieAlgebra) {E : ℝ} (hE : E < 0) :
    ∀ i j,
      ⁅Jplus R E i, Jplus R E j⁆ = R.hbar * (LeviCivita i j) • Jplus R E (cross3 i j) ∧
      ⁅Jminus R E i, Jminus R E j⁆ = R.hbar * (LeviCivita i j) • Jminus R E (cross3 i j) ∧
      ⁅Jplus R E i, Jminus R E j⁆ = 0 := by
  sorry

/-- Casimir identification: L² + A²/(-2mE) = 4(|J⁺|² + |J⁻|²) - ℏ² -/
theorem casimir_identification (R : RungeLenzLieAlgebra) {E : ℝ} (hE : E < 0) :
    casimir R E = 4 * (casimirJplus R E + casimirJminus R E) - R.hbar^2 := by
  sorry

/-- The n²-fold degeneracy follows from so(4) representation theory -/
theorem hydrogen_degeneracy (n : ℕ) (hn : n ≥ 1) :
    ∃ (j : ℕ), j = (n - 1) / 2 ∧
    (2 * j + 1) * (2 * j + 1) = n * n := by
  sorry
```

---

### Proof Strategies (Three Paths)

**Strategy A — Direct Bracket Computation (Most Promising for Lean 4).**
This is the most mechanical and verifiable path:
1. Define `Jplus` and `Jminus` as linear combinations of `L` and `A` with the scaling factor $\alpha = \sqrt{-2mE}$.
2. Expand $[J_i^+, J_j^+]$ using bilinearity of the Lie bracket into four terms: $\frac{1}{4}([L_i, L_j] + [L_i, A_j]/\alpha + [A_i, L_j]/\alpha + [A_i, A_j]/\alpha^2)$.
3. Apply the axioms `hLL`, `hAL`, `hAA` to each term. The $\alpha^2 = -2mE$ cancellation in the $[A_i, A_j]$ term is the key algebraic miracle: it produces $(-2i\hbar H/m) \cdot \epsilon_{ijk} L_k / (-2mE) = (i\hbar H/(m^2 E)) \epsilon_{ijk} L_k$, which combined with the $[L_i, A_j]$ terms reconstructs the $i\hbar\epsilon_{ijk}J_k^+$ structure.
4. The cross terms $[J_i^+, J_j^-]$ vanish because the $L$-$L$ terms cancel against the $A$-$A$ terms (opposite signs from the $\pm$ splitting).
**Why most promising:** Purely algebraic, no analysis or topology needed. Every step is a rewrite using the five bracket axioms.

**Strategy B — Representation-Theoretic (Most Elegant).**
1. Prove that the Runge-Lenz Lie algebra for $E < 0$ is isomorphic to $\mathfrak{so}(4) \cong \mathfrak{su}(2) \oplus \mathfrak{su}(2)$ by constructing an explicit Lie algebra isomorphism $\phi: \mathfrak{g}_E \to \mathfrak{su}(2) \oplus \mathfrak{su}(2)$.
2. Use Mathlib's `LieAlgebra` and `Representation` framework to classify finite-dimensional irreducible representations of $\mathfrak{su}(2) \oplus \mathfrak{su}(2)$.
3. Apply the Weyl dimension formula: $\dim V_{(j_1, j_2)} = (2j_1+1)(2j_2+1)$.
4. The constraint $\mathbf{L} \cdot \mathbf{A} = 0$ forces $j_1 = j_2 = (n-1)/2$.
**Why elegant but harder:** Requires building representation theory infrastructure that Mathlib may not yet have at the needed level of generality.

**Strategy C — Spectral/Operator-Theoretic (Most Faithful to Physics).**
1. Define $L_i$ and $A_i$ as concrete unbounded operators on $L^2(\mathbb{R}^3)$ using Mathlib's `BoundedLinearMap` and domain theory.
2. Prove commutation relations from the canonical $[x_i, p_j] = i\hbar\delta_{ij}$.
3. Derive the Runge-Lenz commutation relations as theorems about these concrete operators.
4. Apply spectral theory to extract the Casimir eigenvalue.
**Why hardest:** Unbounded operator algebra in Lean 4 is essentially nonexistent. This path requires building significant analysis infrastructure first. Reserve for a future cycle.

**Recommendation:** Execute Strategy A for the core algebraic theorems (Theorems A and B), then use Strategy B's representation theory for Theorem C (degeneracy). Strategy C is a future grand challenge.

---

### Cross-Domain Connections

1. **Classical Mechanics ↔ Quantum Mechanics (Deformation Quantization).** The catalog's `so4_casimir_classical` and `runge_lenz_determines_eccentricity` give the *classical* Runge-Lenz story. The quantum algebra is a *deformation* of the classical one: the bracket $[A_i, A_j]_{\text{quantum}} = [A_i, A_j]_{\text{classical}} + \mathcal{O}(\hbar)$. **Theorem to prove:** The $\hbar \to 0$ limit of the quantum Casimir $C_{\text{quantum}} = \hbar^2(n^2-1)$ recovers the classical Casimir $C_{\text{classical}} = L^2 + A^2/(-2mE)$ with $n$ replaced by the classical action variable $J = \sqrt{-2mE}/\hbar$.

2. **Number Theory — Degeneracy as Sum of Odd Numbers.** The identity $n^2 = \sum_{l=0}^{n-1}(2l+1)$ is not merely arithmetic — it encodes the angular momentum decomposition of the $n$-th shell. **Theorem to prove:** For each $n \geq 1$, the $n^2$-dimensional representation $V_n$ of $\mathfrak{so}(4)$ decomposes under the $\mathfrak{so}(3)$ subalgebra (generated by $\mathbf{L}$ alone) as $V_n = \bigoplus_{l=0}^{n-1} V_{2l+1}$, where $V_{2l+1}$ is the $(2l+1)$-dimensional irrep of $\mathfrak{so}(3)$ with angular momentum $l$. This is a *branching rule* for the inclusion $\mathfrak{so}(3) \hookrightarrow \mathfrak{so}(4)$.

3. **Spectral Geometry — The Laplacian on $S^3$.** The hydrogen energy levels $E_n$ are in bijection with the eigenvalues of the Laplacian on $S^3$: $\Delta_{S^3} Y_{n,l,m} = n(n+2) Y_{n,l,m}$. **Theorem to prove (conjecture):** The algebra isomorphism $\mathfrak{so}(4) \cong \mathfrak{su}(2) \oplus \mathfrak{su}(2)$ induces a unitary equivalence between the hydrogen eigenspace $V_n$ and the space of spherical harmonics of degree $n-1$ on $S^3$.

4. **Quantum Information — Entanglement and Symmetry.** The so(4) symmetry means hydrogen eigenstates have higher entanglement than generic central-potential states. **Conjecture:** The geometric entanglement (distance to nearest product state) of hydrogen eigenstates $|n,l,m\rangle$ satisfies $E_G \geq c \cdot n$ for some constant $c > 0$, growing with principal quantum number. This is *falsifiable*: compute $E_G$ numerically for $n = 1,\ldots,20$ and check the linear bound.

---

### Application Keywords
`hydrogen_atom`, `accidental_degeneracy`, `so4_symmetry`, `Runge_Lenz`, `Pauli_method`, `Casimir_eigenvalue`, `Lie_algebra_representation`, `branching_rules`, `spectral_geometry`, `quantum_information`

---

### Conjecture with Testable Prediction

**Conjecture (Tropical Hydrogen Spectrum).** The tropicalization of the hydrogen energy levels $E_n = -mk^2/(2\hbar^2 n^2)$ under the min-plus semiring gives a piecewise-linear spectrum $\operatorname{Trop}(E_n) = \log(mk^2/(2\hbar^2)) - 2\log n$ that satisfies a tropical eigenvalue equation for a tropical Laplacian on a tropical $S^3$. Specifically, the tropical Casimir $\operatorname{Trop}(C) = \max(2\log L, 2\log A - \log(-2mE))$ has tropical eigenvalue $2\log n$, and the tropical degeneracy is $n^{\oplus 2} = 2 \cdot \log n$ (tropical multiplication replaces ordinary multiplication).

**Computational Test:** Implement the tropical hydrogen spectrum for $n = 1,\ldots,50$ and verify that:
1. $\operatorname{Trop}(E_n) - \operatorname{Trop}(E_{n+1}) = 2(\log(n+1) - \log n)$ (tropical spectral gap).
2. The tropical Casimir eigenvalues satisfy $\operatorname{Trop}(C_n) = 2\log n$.
3. The tropical degeneracy $2\log n$ matches the tropical dimension of the representation.

If any of these fail for $n \leq 50$, the conjecture is falsified.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3–5 testable scientific hypotheses:
   1. The branching rule $V_n = \bigoplus_{l=0}^{n-1} V_{2l+1}$ for $\mathfrak{so}(3) \hookrightarrow \mathfrak{so}(4)$ can be proven by induction on $n$ using ladder operators.
   2. The classical limit $\hbar \to 0$ of the quantum Casimir recovers the classical one (deformation quantization conjecture).
   3. The geometric entanglement of hydrogen eigenstates grows at least linearly with $n$.
   4. The tropical hydrogen spectrum satisfies a tropical eigenvalue equation.
   5. The Pauli algebraic method extends to the Klein-Gordon hydrogen atom (relativistic spin-0), where the Runge-Lenz algebra deforms to $\mathfrak{so}(4,1)$ and degeneracy is partially broken.

(b) **RESEARCH_PAPER.md** — Standalone scientific document: what was discovered (the so(4) fission and Casimir eigenvalue theorems), why it matters (first formal verification of the algebraic solution to hydrogen), and what to investigate next (branching rules, classical limit, tropical spectrum).

(c) **ARTICLE.md** — Scientific American style: "The Hidden Symmetry That Explains the Atom" — how an obscure 1926 trick by Wolfgang Pauli, using a conserved quantity from planetary orbits, reveals that the hydrogen atom has far more symmetry than anyone expected, and why formalizing this in Lean 4 matters for physics and mathematics.

(d) **Verified algorithm:** An algorithm that, given $n$, computes the Casimir eigenvalue $C_n = \hbar^2(n^2-1)$, the energy $E_n = -mk^2/(2\hbar^2 n^2)$, and the degeneracy $n^2$, with all three quantities verified to satisfy the algebraic identities from Theorems A–D.

(e) **demo.py** — Interactive demonstration: input $n$, see the so(4) quantum numbers $(j^+, j^-) = ((n-1)/2, (n-1)/2)$, the Casimir eigenvalue, the energy level, the angular momentum decomposition $V_n = \bigoplus_{l=0}^{n-1}(2l+1)$, and a visual plot of the degeneracy tower.

---

### Catalog References to Build On

- `Pythagorean/KeplerLaws.lean`: `so4_casimir_classical` — the classical Casimir identity $L^2 + A^2/(-2mE) = $ const. This is the *classical* shadow of Theorem B. Extend it by adding the $\hbar^2$ quantum correction.
- `Pythagorean/KeplerLaws.lean`: `runge_lenz_determines_eccentricity` — the classical result that $|A|$ determines orbit shape. The quantum analogue: $|\mathbf{A}|^2$ on $V_n$ determines the angular momentum content (branching rule).
- Use Mathlib's `LieAlgebra`, `LieRing`, `FiniteDimensional`, and `LeviCivita` (if available; otherwise define `cross3` and `leviCivita3` locally).

---

*This is the first formal verification of Pauli's 1926 algebraic solution to the hydrogen atom — the moment where classical orbit theory, Lie algebra representation theory, and quantum spectroscopy converge into a single verified mathematical structure. The so(4) symmetry is not merely "accidental"; it is the deepest structural fact about the simplest atom.*

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
