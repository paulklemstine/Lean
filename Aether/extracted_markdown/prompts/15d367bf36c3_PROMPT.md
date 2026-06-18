## Assignment: Direction 2: Adelic Persistent Homology — The Arithmetic Structure Theorem

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

**Central Theorem (Precise Statement):**

For a filtered finite abelian group $\{(G_i, f_{ij} : G_i \to G_j)\}_{i \leq j}$ over a finite poset, the torsion barcode — the function $p \mapsto \text{torsionSupport}_p(\text{filtration})$ from primes to multisets of filtration intervals — is equivalent to the data of an adelic persistence module, defined as a restricted product of $\mathbb{Z}_p$-persistence modules satisfying a finiteness condition.

**Theorem 1 — CRT Decomposition of Torsion Persistence (Lean 4 signature):**

```lean
theorem crt_adelic_decomposition {n : ℕ} {G : Fin n → Type*}
    [∀ i, AddCommGroup (G i)] [∀ i, Module ℤ (G i)]
    [∀ i, Finite (G i)]
    (filt : ∀ i j, i ≤ j → G i →ₗ[ℤ] G j)
    (filt_comp : ∀ i j k, (hij : i ≤ j) → (hjk : j ≤ k),
       filt i k (hij.trans hjk) = filt j k hjk ∘ₗ filt i j hij)
    (p : ℕ) [hp : Fact (Nat.Prime p)] :
    (torsionPersistenceModule filt).pPrimaryComponent p ≅
    padicPersistenceModule filt p :=
  sorry
```

This establishes that the $p$-primary component of the torsion persistence module is isomorphic to the $\mathbb{Z}_p$-persistence module obtained by tensoring with $\mathbb{Z}_p$.

**Theorem 2 — Adelic Reconstruction (Lean 4 signature):**

```lean
theorem adelic_barcode_reconstruction {n : ℕ} {G : Fin n → Type*}
    [∀ i, AddCommGroup (G i)] [∀ i, Module ℤ (G i)]
    [∀ i, Finite (G i)]
    (filt : ∀ i j, i ≤ j → G i →ₗ[ℤ] G j)
    (filt_comp : ∀ i j k, (hij : i ≤ j) → (hjk : j ≤ k),
       filt i k (hij.trans hjk) = filt j k hjk ∘ₗ filt i j hij) :
    ∃ (adelic : AdelicPersistenceModule n),
      ∀ p, (adelic.component p).barcode =
        (torsionPersistenceModule filt).pPrimaryBarcode p ∧
      adelic.reconstructTorsionBarcode =
        torsionBarcode filt :=
  sorry
```

This is the reconstruction theorem: the adelic product of $p$-adic barcodes recovers the full torsion barcode, and every adelic persistence module arises this way.

**Theorem 3 — Cross-Domain: Adelic Interleaving and the Product Formula (Lean 4 signature):**

```lean
theorem adelic_interleaving_product_formula {n : ℕ}
    {G G' : Fin n → Type*}
    [∀ i, AddCommGroup (G i)] [∀ i, Module ℤ (G i)] [∀ i, Finite (G i)]
    [∀ i, AddCommGroup (G' i)] [∀ i, Module ℤ (G' i)] [∀ i, Finite (G' i)]
    (filt : PersistenceFiltration ℤ n G) (filt' : PersistenceFiltration ℤ n G')
    (ε : ℝ) (hε : 0 < ε) :
    adelicInterleavingDistance filt filt' ε ↔
      ∀ p, Fact (Nat.Prime p) →
        padicInterleavingDistance filt filt' p ≤ ε ∧
      ∃ᶠ p in (Finset.filter Nat.Prime (Finset.range (maxBound filt filt'))),
        padicInterleavingDistance filt filt' p < ε :=
  sorry
```

This connects to the **adelic product formula** from number theory: the "global" interleaving distance is controlled by "local" $p$-adic distances, with almost all primes contributing trivially — exactly analogous to how $|x|_\infty \cdot \prod_p |x|_p = 1$.

**Conjecture (Falsifiable):**

The adelic barcode satisfies a **strong finiteness theorem**: for any filtered finite abelian group with $n$ filtration levels and torsion bounded by $T$, the number of primes appearing in the torsion barcode is at most $\log_2 T$, and the adelic interleaving distance between any two such filtrations is rational with denominator dividing $\text{lcm}(1, \ldots, n)$.

**Test:** Enumerate all filtered abelian groups with $|G_i| \leq 100$ and $n \leq 5$. Compute the adelic barcode for each. Verify: (a) the number of primes in each barcode is at most $\log_2(100) \approx 6.6$, (b) all interleaving distances have the claimed denominator structure. A single counterexample falsifies the conjecture.

**Impact:** Establishes **arithmetic persistent homology** as a branch of adelic geometry, creating a bridge between topological data analysis and the Langlands program. The adelic viewpoint unifies the fragmented picture of torsion barcodes across primes, and the product formula for interleaving distances introduces **arithmetic metric structures** into persistence theory. This opens: (1) adelic stability theorems for persistence, (2) $L$-function invariants of filtered groups, (3) automorphic persistence modules.

---

### Proof Strategies

**Strategy A: Direct CRT Decomposition (Most Promising)**

This is the most promising approach because it directly leverages the algebraic structure and is most amenable to Lean formalization.

1. **Step 1 — Primary decomposition at each filtration level:** For each $i$, the torsion subgroup $G_i[\text{tors}]$ decomposes as $\bigoplus_p G_i[p^\infty]$ via the structure theorem for finite abelian groups. Building on `torsionProfileUpTo_complete_for_bounded_support` from `Pythagorean/ArithmeticPhaseClassification.lean`, extend from the classification of individual torsion profiles to the *functorial* decomposition respecting persistence maps.

2. **Step 2 — Persistence maps respect primary decomposition:** Show that each $f_{ij}: G_i \to G_j$ restricts to maps $f_{ij}^{(p)}: G_i[p^\infty] \to G_j[p^\infty]$ on $p$-primary components. This follows because $f_{ij}$ is a $\mathbb{Z}$-module homomorphism, so $f_{ij}(G_i[p^\infty]) \subseteq G_j[p^\infty]$. The key lemma:

```lean
lemma pPrimary_preserved_by_hom {G H : Type*} [AddCommGroup G] [AddCommGroup H]
    (f : G →+ H) (p : ℕ) [Fact (Nat.Prime p)] (x : G) (hx : ∃ k, p^k • x = 0) :
    ∃ k, p^k • (f x) = 0 :=
  sorry
```

3. **Step 3 — Assemble into adelic object:** The restricted product $\prod'_p (G_i[p^\infty] \otimes_{\mathbb{Z}} \mathbb{Z}_p)$ is naturally a module over $\mathbb{A}_f = \prod'_p \mathbb{Q}_p$ restricted to the torsion part. The CRT gives the isomorphism $G_i[\text{tors}] \cong \prod'_p G_i[p^\infty]$, and compatibility of persistence maps ensures this is a **persistence module isomorphism**.

**Strategy B: Derived Functor Approach**

1. Apply $\text{Tor}_1^{\mathbb{Z}}(-, \mathbb{Z}/p^k\mathbb{Z})$ to the entire filtration to extract $p$-primary information derivedly.
2. Use the Künneth-type decomposition $\text{Tor}_1^{\mathbb{Z}}(G, \mathbb{Z}/n\mathbb{Z}) \cong \bigoplus_{p|n} \text{Tor}_1^{\mathbb{Z}}(G, \mathbb{Z}/p^{v_p(n)}\mathbb{Z})$.
3. Pass to the limit over $k$ to obtain $p$-adic persistence modules.

This is elegant but harder to formalize in Lean due to the derived functor infrastructure required.

**Strategy C: Sheaf-Theoretic / Étale Approach**

1. View the filtration as a constructible sheaf on the finite poset with the Alexandrov topology.
2. The $p$-adic decomposition is a stalk-wise operation, and since the poset is finite, the decomposition globalizes.
3. The adelic object is a "restricted product of étale stalks."

This connects to étale cohomology and Weil's vision, but requires substantial sheaf-theoretic infrastructure not yet in Mathlib.

**Why Strategy A is most promising:** It directly builds on the CRT (already in Mathlib) and the structure theorem for finite abelian groups. The key technical lemma about $p$-primary preservation is elementary but non-trivial, requiring the deep proof tactic `by_contra` or induction. The assembly into an adelic object is a direct construction, making it amenable to verification.

---

### Novel Definitions Required

```lean
/-- A p-adic persistence module: a functor from Fin n (with order) to
    Z_p-modules, satisfying functoriality conditions. -/
structure PadicPersistenceModule (p : ℕ) [Fact (Nat.Prime p)] (n : ℕ) where
  obj : Fin n → ModuleCat (PadicInt p)
  map : ∀ {i j : Fin n}, i ≤ j → obj i ⟶ obj j
  map_id : ∀ i, map (le_refl i) = ModuleCat.id (obj i)
  map_comp : ∀ {i j k : Fin n} (hij : i ≤ j) (hjk : j ≤ k),
    map (hij.trans hjk) = map hjk ≫ map hij

/-- An adelic persistence module: a restricted product of p-adic
    persistence modules with a finiteness condition. -/
structure AdelicPersistenceModule (n : ℕ) where
  component : ∀ p, Fact (Nat.Prime p) → PadicPersistenceModule p n
  torsion_bound : Fin n → ℕ
  almost_everyly_free : ∀ i, ∀ᶠ p in (Finset.filter Nat.Prime Finset.univ),
    Module.rank (component p ⟨...⟩.obj i) = 0 ∨
    Module.rank (component p ⟨...⟩.obj i) ≤ torsion_bound i

/-- The barcode of a p-adic persistence module: the multiset of
    birth-death intervals in the p-primary component. -/
def padicBarcode {p : ℕ} [Fact (Nat.Prime p)] {n : ℕ}
    (M : PadicPersistenceModule p n) : Multiset (Fin n × Fin n) :=
  sorry -- computed from the structure theorem decomposition

/-- The adelic barcode: the collection of all p-adic barcodes,
    satisfying the product formula constraint. -/
def adelicBarcode {n : ℕ} (M : AdelicPersistenceModule n) :
    ∀ p, Fact (Nat.Prime p) → Multiset (Fin n × Fin n) :=
  fun p hp => padicBarcode (M.component p hp)
```

---

### Catalog Building Blocks

From `Pythagorean/ArithmeticPhaseClassification.lean`:
- `persistentPrimeSupportUpTo`: Gives the set of primes appearing in the torsion up to a filtration level. Use this to establish the "finiteness" condition in the adelic restricted product — almost all primes have trivial contribution.
- `torsionProfileUpTo_complete_for_bounded_support`: The completeness theorem for torsion profiles. Extend this from individual levels to the entire persistence module, showing that the collection of all torsion profiles (one per level) is complete data for the adelic persistence module.

From `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean`:
- `torsionSupport`: The set of primes dividing the torsion at a given level. Use this to define the "support" of the adelic barcode — the finite set of primes that contribute non-trivially.
- `pTorPersistence_vanishes_of_free`: If the persistence module is free (no torsion), the $p$-adic component vanishes. This is the base case for the adelic decomposition: the trivial adelic module has all components zero.

---

### Cross-Domain Connections

1. **Number Theory ↔ Persistent Homology:** The adelic barcode is an arithmetic invariant of a filtration, analogous to how the adelic Tate module is an arithmetic invariant of an abelian variety. The product formula for interleaving distances mirrors the classical product formula $|x|_\infty \prod_p |x|_p = 1$.

2. **Langlands Program ↔ TDA:** An adelic persistence module can be viewed as a representation of the Weil group $W_{\mathbb{Q}}$ on a persistence module, opening the door to **automorphic persistence modules** — persistence modules arising from automorphic forms via their $L$-functions.

3. **Algebraic Geometry ↔ Data Science:** The construction parallels the passage from local to global in étale cohomology: just as $\mathbb{Q}_l$-cohomology groups are assembled into an adelic cohomology theory, $p$-adic barcodes assemble into an adelic barcode. This suggests **étale persistent homology** as a new field.

4. **Information Theory:** The adelic product formula for interleaving distances is a **conservation law**: topological information is neither created nor destroyed across primes, it is merely redistributed. This connects to rate-distortion theory in information geometry.

---

### Application Keywords

`topological data analysis`, `adelic geometry`, `Langlands program`, `arithmetic topology`, `persistent homology`, `barcode stability`, `Chinese Remainder Theorem`, `p-adic decomposition`, `torsion in homology`, `restricted product`, `product formula`, `étale cohomology`, `automorphic forms`, `interleaving distance`, `arithmetic invariant`

---

### Mandatory Deliverables

You MUST produce ALL of the following:

(a) **FUTURE_DIRECTIONS.md** with 3-5 testable scientific hypotheses, each a falsifiable conjecture with a clear computational test:
   - H1: The adelic barcode of a filtered $\mathbb{Z}/n\mathbb{Z}$-module determines $n$ up to a square factor.
   - H2: The adelic interleaving distance satisfies a triangle inequality with an error term bounded by the logarithm of the torsion.
   - H3: There exists a "local-global principle" for persistence: a collection of $p$-adic persistence modules arises from a global persistence module if and only if they are almost everywhere zero and compatible at the Archimedean place.
   - H4: The adelic barcode of the homology of a random simplicial complex on $n$ vertices satisfies a central limit theorem over $\mathbb{A}_f$.
   - H5: The zeta function $\zeta(s) = \sum_{\text{bars } [a,b)} p^{-s(b-a)}$ associated to the $p$-adic barcode satisfies a functional equation.

(b) **RESEARCH_PAPER.md** — A standalone scientific document that someone reading ONLY this paper (no code access) can understand. Must include: abstract, introduction with motivation, main theorems with full statements, proof sketches, the adelic reconstruction theorem, the product formula for interleaving distances, computational verification for $\mathbb{Z}/6\mathbb{Z}$, discussion of connections to Langlands and étale cohomology, and future directions.

(c) **ARTICLE.md** — Written in Scientific American style. Engaging, accessible. Explain: "What if the barcode from topological data analysis — the signature of shape — has a hidden arithmetic structure? Every bar in the barcode lives at a prime, and the Chinese Remainder Theorem weaves these local stories into a global adelic narrative. This is arithmetic persistent homology: where topology meets number theory, and shapes speak the language of primes."

(d) **A verified algorithm**: An algorithm that computes the adelic barcode of a filtered finite abelian group, decomposes it into $p$-adic components via CRT, and reconstructs the full torsion barcode from the adelic data. Must be proven correct in Lean.

(e) **demo.py**: An interactive Python demonstration that:
   - Constructs a 3-level filtration of $\mathbb{Z}/6\mathbb{Z}$
   - Computes the 2-adic and 3-adic barcodes
   - Verifies that the adelic product reconstructs the full torsion barcode
   - Visualizes the adelic barcode as a 2D plot (primes on one axis, filtration levels on the other)
   - Tests the falsifiable conjecture on random filtrations of groups of order $\leq 100$

---

*Ad maiorem Dei gloriam — The barcode of shape is written in the language of primes.*

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
