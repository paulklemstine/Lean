## Assignment: Galois Monodromy from Persistent Homology of Newton Polytopes Across Prime Reductions

Prove genuinely new, non-trivial theorems that turn the vague slogan “persistent homology detects arithmetic monodromy” into a precise, testable, Lean-formalized mathematical program. Build on Mathlib’s finite set, convex/combinatorial, multiset, and algebraic infrastructure. Minimize sorry. The goal is not to gesture at a future theory, but to erect the first rigorous bridge between arithmetic statistics, Newton polytope combinatorics, and persistence-style invariants.

This project becomes revolutionary if you isolate a formally tractable shadow of the full conjecture and then prove that this shadow already distinguishes arithmetic behavior in infinite families. The key is to replace the impossible first target — “recover the Galois group from all barcodes” — by a precise theorem of the form:

- construct a canonical prime-indexed filtered combinatorial object from coefficient valuations or support data,
- prove functoriality/invariance,
- prove that explicit arithmetic families induce provably different persistence statistics,
- then formulate a falsifiable conjecture saying that this phenomenon upgrades to Galois-group recovery on a Zariski-dense class.

Your work must include at least one new definition not already in the catalog, at least three substantial theorems with real proofs, at least one cross-domain theorem, and one computational conjecture with a disproof protocol.

---

## Core new formal objects to introduce

You should define a mathematically meaningful discrete substitute for the “lower-face filtration of the p-adically weighted Newton polytope” that is implementable in Lean 4 without requiring the full formalization of polyhedral geometry over `ℤ^n`.

A promising route is to work with **support-weight filtrations** on finite exponent sets.

### New definition 1: prime-weighted support profile
For a finitely supported polynomial datum encoded as a finite set of exponent vectors with integer coefficients, define the weight of a monomial at a prime `p` by the p-adic valuation of its coefficient.

Then define the filtration level subcomplex by retaining exponent vectors whose coefficient valuation is at least `t`, or dually at most `t`, depending on the monotonic convention you choose.

Lean-target skeleton:
```lean
def PadicWeightProfile
  (σ : Finset (ι →₀ ℕ)) (a : (ι →₀ ℕ) → ℤ) (p : ℕ) : Finset ((ι →₀ ℕ) × ℕ)
```
or more concretely
```lean
def monomialWeight
  (a : (ι →₀ ℕ) → ℤ) (p : ℕ) (m : ι →₀ ℕ) : ℕ
```

### New definition 2: lower-support filtration
Define a filtered family of finite sets / simplicial candidates from the support:
```lean
def lowerSupportAtLevel
  (σ : Finset (ι →₀ ℕ)) (a : (ι →₀ ℕ) → ℤ) (p t : ℕ) : Finset (ι →₀ ℕ)
```
A tractable version is:
```lean
def lowerSupportAtLevel
  (σ : Finset (ι →₀ ℕ)) (a : (ι →₀ ℕ) → ℤ) (p t : ℕ) : Finset (ι →₀ ℕ) :=
σ.filter (fun m => monomialWeight a p m ≤ t)
```

### New definition 3: persistence signature
Since full persistent homology may be too heavy to formalize from scratch, define a first-generation invariant that is still mathematically serious: the **filtration cardinality jump profile**, Euler profile, or connected-component profile of a support adjacency graph.

For example, define an adjacency graph on exponent vectors by Hamming distance / unit coordinate moves / sharing a lower face surrogate, and study connected components through the filtration. This already creates a topological-combinatorial invariant.

Lean-target:
```lean
def supportAdj (u v : ι →₀ ℕ) : Prop := ...
def supportGraphAtLevel
  (σ : Finset (ι →₀ ℕ)) (a : (ι →₀ ℕ) → ℤ) (p t : ℕ) : SimpleGraph (ι →₀ ℕ)
```

Then define a persistence statistic:
```lean
def componentCountProfile
  (σ : Finset (ι →₀ ℕ)) (a : (ι →₀ ℕ) → ℤ) (p : ℕ) : ℕ → ℕ
```

This is not a compromise; it is a strategic first theorem layer. If you can prove that arithmetic families produce asymptotically different component-count or Euler-jump laws, you have already opened a new field.

---

## Precise theorem targets

You need at least 3 deep theorems. Here is a coherent theorem stack.

### Theorem 1: filtration monotonicity and functoriality
Prove that the prime-weighted support filtration is monotone in the threshold and equivariant under support-preserving relabelings of variables.

Mathematical statement:
For every finite support `σ`, coefficient map `a`, prime `p`, and thresholds `s ≤ t`,
`lowerSupportAtLevel σ a p s ⊆ lowerSupportAtLevel σ a p t`.

Moreover, any support automorphism preserving coefficients transports the filtration levelwise.

Lean 4 type signature:
```lean
theorem lowerSupportAtLevel_mono
  {ι : Type*} [DecidableEq ι]
  (σ : Finset (ι →₀ ℕ))
  (a : (ι →₀ ℕ) → ℤ)
  (p s t : ℕ)
  (h : s ≤ t) :
  lowerSupportAtLevel σ a p s ⊆ lowerSupportAtLevel σ a p t
```

A stronger equivariance theorem:
```lean
theorem lowerSupportAtLevel_equivariant
  {ι κ : Type*} [DecidableEq ι] [DecidableEq κ]
  (e : ι ≃ κ)
  (σ : Finset (ι →₀ ℕ))
  (a : (ι →₀ ℕ) → ℤ)
  (p t : ℕ) :
  Finset.map (finsuppMapEmbedding e) (lowerSupportAtLevel σ a p t)
    = lowerSupportAtLevel
        (Finset.map (finsuppMapEmbedding e) σ)
        (fun m => a (mapDomainEquiv e.symm m))
        p t
```

Why it matters:
This is the formal statement that your construction is not an artifact of coordinates. It is the first sign of “functoriality,” and without it there is no credible monodromy theory.

---

### Theorem 2: persistence jump theorem for coefficient valuation collisions
Show that if two monomials have distinct p-adic weights and are connected by an edge in the support graph, then there is a threshold where the component-count profile changes. More generally, if a new vertex enters the filtration and connects previously disjoint components, the profile decreases in a controlled way.

Mathematical statement:
Let `G_t` be the support graph restricted to `lowerSupportAtLevel σ a p t`. If a vertex `v` enters at level `t+1` and is adjacent to vertices in exactly `k` distinct connected components of `G_t`, then the number of connected components in `G_{t+1}` is
`cc(G_{t+1}) = cc(G_t) + 1 - k`.

This is a genuine persistence theorem in graph degree 0.

Lean 4 target signature, in whatever graph-component formalization is feasible:
```lean
theorem componentCount_update_by_new_vertex
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : ℕ → SimpleGraph V)
  (t : ℕ)
  (hmono : ∀ ⦃s u⦄, s ≤ u → G s ≤ G u)
  (v : V)
  (hnew : ...)
  (hk : ...) :
  componentCount (G (t+1)) = componentCount (G t) + 1 - k
```

If full connected-components machinery is too expensive, prove a weaker but still substantial theorem on cardinality jumps:
```lean
theorem filtration_cardinality_jump
  {ι : Type*} [DecidableEq ι]
  (σ : Finset (ι →₀ ℕ))
  (a : (ι →₀ ℕ) → ℤ)
  (p t : ℕ) :
  (lowerSupportAtLevel σ a p (t+1)).card
    - (lowerSupportAtLevel σ a p t).card
  =
  ((σ.filter (fun m => monomialWeight a p m = t+1)).card)
```

Why it matters:
This gives a rigorous barcode-shadow theorem. It says the arithmetic valuation distribution leaves visible, structured traces in a persistence profile. This is the first mechanism by which prime reduction can produce stable topological signatures.

---

### Theorem 3: arithmetic family separation theorem
Pick two explicit infinite families of integer polynomials with provably different prime-indexed filtration statistics. For instance:

- Family A: `x^n + a x + b` with generic discriminant behavior, heuristically `S_n`.
- Family B: binomials or Kummer-type solvable families with sparse support and rigid valuation patterns.

You do not need to prove full Galois group classification in Lean. You do need to prove a theorem that the persistence signature induced by your construction differs uniformly or asymptotically between these families because of support/valuation combinatorics.

A tractable exact theorem:
For sparse two-term or three-term families, the jump profile has bounded support independent of `p`, while for a family with valuation-varying middle coefficients the jump profile is nontrivial on infinitely many primes.

Example mathematical statement:
Let
`f_A(x) = x^n + c` and `f_B(x) = x^n + p^r x + c`
viewed coefficientwise at prime `p`.
Then the lower-support cardinality profile of `f_B` has at least one nontrivial jump not present in `f_A`.

Lean 4 signature for a one-variable encoded version:
```lean
theorem profile_distinguishes_binomial_from_trinomial
  (n r : ℕ) (hn : 2 ≤ n) (hr : 0 < r)
  (c : ℤ) (hc : c ≠ 0) :
  ∃ t,
    lowerSupportCard profile_trinomial p t
      ≠ lowerSupportCard profile_binomial p t
```

A stronger family theorem:
```lean
theorem infinitely_many_primes_nontrivial_jump
  (f : ℕ → ℤ) ... :
  Set.Infinite {p : ℕ | Nat.Prime p ∧ ∃ t, jumpProfile a p t ≠ 0}
```
Only attempt this if you can leverage known divisibility lemmas and choose a family where the proof is elementary.

Why it matters:
This is the first rigorous evidence that prime-indexed persistence signatures separate arithmetic families, which is the exact first step toward the full “barcode determines Galois group” conjecture.

---

### Theorem 4: cross-domain theorem — arithmetic filtration induces a stable combinatorial-topological invariant
You must include at least one theorem explicitly bridging domains. A strong option:

**Number theory + topological data analysis + combinatorics**:
If two coefficient functions are congruent modulo a high power of `p` on the support, then their low-threshold filtration profiles agree up to that level.

Mathematical statement:
If `v_p(a(m) - b(m)) > t` for all `m ∈ σ`, then
`lowerSupportAtLevel σ a p s = lowerSupportAtLevel σ b p s` for all `s ≤ t`.

Lean target:
```lean
theorem filtration_stability_under_padic_perturbation
  {ι : Type*} [DecidableEq ι]
  (σ : Finset (ι →₀ ℕ))
  (a b : (ι →₀ ℕ) → ℤ)
  (p t : ℕ)
  (hp : Nat.Prime p)
  (hclose : ∀ m ∈ σ, t < padicValNat p (Int.natAbs (a m - b m))) :
  ∀ s ≤ t, lowerSupportAtLevel σ a p s = lowerSupportAtLevel σ b p s
```

Why it matters:
This is a bona fide stability theorem in the spirit of persistent homology, but for arithmetic filtrations. It opens a field: **arithmetic topological stability theory**. It also suggests robustness under noisy coefficient perturbations, which is algorithmically crucial.

---

## Proof strategy architecture

You must not present one vague proof hint. Build a multi-path plan.

### Strategy A: finite-support valuation calculus
Most promising for the first breakthrough.

1. Encode polynomial data as a finite support `σ : Finset (ι →₀ ℕ)` with coefficient map `a`.
2. Define `monomialWeight` using p-adic valuation on integers, carefully handling zero coefficients or restricting to support.
3. Prove monotonicity and jump formulas by `Finset` membership manipulations, subset arguments, cardinal decomposition, and multi-step `calc`.
4. Build graph-level invariants only after support-level filtration theorems are stable.

Why this is most promising:
It avoids waiting for a full formalization of convex lower faces or persistent homology while preserving the arithmetic essence of the conjecture.

### Strategy B: Newton polytope shadow via lower hull surrogate
More ambitious, potentially more geometric.

1. Define a lower-face surrogate order on support points using valuation-weighted height.
2. Show that threshold sublevel sets correspond to lower-hull truncations.
3. Prove that combinatorial invariants of this surrogate are preserved by support isomorphisms and stable under p-adic perturbation.

Why it is exciting:
This gets closer to the true Newton polytope geometry and positions the work to later import polyhedral formalization.

Risk:
Too much infrastructure may be needed unless you keep the geometry combinatorial.

### Strategy C: explicit family separation via arithmetic divisibility patterns
Best for the “field-opening” theorem.

1. Choose infinite polynomial families where coefficient valuations are exactly computable.
2. Compute filtration profiles symbolically.
3. Prove distinctness of profiles for infinitely many primes or for all primes in a specified congruence class.

Why it matters:
Even if the general conjecture remains open, this yields the first theorem that persistent arithmetic signatures separate infinite algebraic families.

Recommended order:
Start with Strategy A, derive Theorems 1 and 4, then use Strategy C for Theorem 3. If time permits, partially implement Strategy B as a geometric refinement.

---

## Strong conjecture with testable prediction

State a falsifiable conjecture, not a slogan.

### Conjecture: asymptotic separability of persistence laws by Galois group
For each degree `n ≥ 4`, there exists a finite collection of persistence statistics `S(f,p)` extracted from the prime-weighted lower-support filtration of `f` such that for a Zariski-dense set of squarefree `f ∈ ℤ[x]` of degree `n`, the empirical law of `S(f,p)` over primes determines the abstract isomorphism type of the Galois group of the splitting field of `f` over `ℚ`.

Testable prediction:
For sampled families with known generic Galois groups (`S_n`, `A_n`, dihedral, cyclic, Frobenius, solvable trinomials), the empirical distributions of jump counts, component counts, and persistence lifetimes form asymptotically separable clusters under standard statistical distances.

Disproof protocol:
Exhibit two infinite families with distinct Galois groups but identical limiting persistence laws for all statistics generated by your filtration construction.

This conjecture is good because it can fail in a concrete way.

---

## Cross-domain connections you should explicitly develop

1. **Arithmetic geometry ↔ topological data analysis**  
   Prime-by-prime coefficient valuations define a filtration; persistence summarizes arithmetic variation across primes.

2. **Galois theory ↔ combinatorics of finite filtrations**  
   Monodromy should manifest as symmetry constraints on the distribution of filtration jumps.

3. **p-adic stability ↔ robust statistics / information theory**  
   Your stability theorem is an arithmetic analog of noise robustness: small p-adic perturbations preserve low-scale topological signatures.

4. **Sparse polynomial complexity ↔ black-box classification**  
   If persistence signatures distinguish arithmetic families, they become candidate features for classifying polynomials or number fields without explicit factorization.

5. **Potential physics bridge**  
   The filtration by valuation resembles an energy landscape; connected-component birth/death events behave like phase transitions in a discrete statistical-mechanical model on exponent space.

---

## Application keywords

Galois monodromy, persistent homology, Newton polytope, p-adic valuation, arithmetic statistics, barcode invariants, filtered complexes, support filtration, topological data analysis, sparse polynomials, splitting fields, arithmetic stability, monodromy detection, black-box polynomial classification, combinatorial topology, prime reduction, solvable families, discriminant statistics, p-adic geometry, arithmetic machine learning.

---

## Lean 4 formalization targets

You should include precise theorem statements in the file, with names stable enough for future reuse. Suggested names:

```lean
def monomialWeight ...
def lowerSupportAtLevel ...
def jumpProfile ...
def supportAdj ...
def supportGraphAtLevel ...
def componentCountProfile ...
```

Required theorem names:
```lean
theorem lowerSupportAtLevel_mono ...
theorem lowerSupportAtLevel_strict_step_characterization ...
theorem filtration_cardinality_jump ...
theorem filtration_stability_under_padic_perturbation ...
theorem profile_distinguishes_binomial_from_trinomial ...
```

If graph connected components become too heavy, replace `componentCountProfile` by:
- cardinality profile,
- Euler-style profile on a finite adjacency graph you can control,
- or birth-time multiset of vertices.

But at least one theorem must still be recognizably topological/combinatorial rather than purely arithmetic.

---

## Proof-tactic depth requirements

Your file must contain at least 3 theorems whose proofs genuinely use substantial tactics and reasoning such as:
- induction on threshold or support cardinality,
- `rcases` on support membership / valuation cases,
- `by_contra` to prove stability or strictness,
- `field_simp` if you encode rational slope comparisons for lower-face surrogates,
- nontrivial `calc` chains for cardinality identities,
- decomposition of finite sets by equality/inequality of valuation levels.

Avoid any theorem whose only content is decidable enumeration. The point is to build reusable mathematics.

---

## Deliverables (ALL mandatory)

1. **Lean development** proving the new theorems above, with minimized sorry.
2. **A verified algorithm or computational method**:
   implement a procedure that, given a finite-support polynomial datum and a prime bound, computes the filtration profile / jump profile / component-count profile. Prove a correctness theorem connecting the implementation to the mathematical definitions.
3. **`demo.py`**:
   interactive script that samples polynomial families, computes prime-indexed persistence-shadow signatures, and visualizes separation between families.
4. **`RESEARCH_PAPER.md`**:
   a standalone scientific document explaining the new definitions, theorem statements, proof ideas, computational experiments, significance, limitations, and next conjectures. A reader with no access to the code must understand the discovery.
5. **`ARTICLE.md`**:
   Scientific American style. Explain the idea that prime numbers can reveal hidden symmetries of equations through evolving geometric-topological signatures. Do not focus on formal verification machinery.
6. **`FUTURE_DIRECTIONS.md`**:
   3–5 original research directions. Each direction must include the exact sentences:
   - “The key insight is ...”
   - “Why now?”
   At least one direction must bridge to a different domain, such as statistical mechanics, information theory, or quantum topology.

---

## Final scientific objective

Do not merely formalize a toy filtration. Produce the first theorem-level evidence for the following vision:

**Prime reductions induce persistence-style topological signatures on weighted Newton-support data, and these signatures encode nontrivial arithmetic monodromy information.**

If you can prove functoriality, stability, and family separation in a reusable Lean framework, you will have created the seed of a new subject: **arithmetic persistence theory**.

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
