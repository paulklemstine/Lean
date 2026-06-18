Soli Deo Gloria

## Assignment: Direction 2: Adelic Persistent Homology

**Mode:** prove

Prove genuinely new, non-trivial theorems at the interface of arithmetic topology, persistence theory, and adelic algebra. This project should not merely repackage prime-wise torsion data; it should show that the arithmetic decomposition of torsion persistence is naturally governed by an adelic object, and that this viewpoint produces reconstruction, uniqueness, and computable invariants.

Build directly on the catalog results

- `Pythagorean/ArithmeticPhaseClassification.lean`
  - `persistentPrimeSupportUpTo`
  - `torsionProfileUpTo_complete_for_bounded_support`
- `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean`
  - `torsionSupport`
  - `pTorPersistence_vanishes_of_free`

and treat them as the prime-local shadows of a single global theorem.

## Grand Objective

Formalize and prove that for a filtered finite abelian group, the entire torsion barcode is equivalent to the family of its prime-primary persistence modules, and that this family admits an adelic packaging whose support and reconstruction properties are canonical.

The revolutionary point is this: persistent homology usually records scale-by-scale topological birth and death. Here, the scale parameter is enriched by arithmetic place data. If successful, this opens a new field: **arithmetic persistent homology**, where barcodes are not just intervals but adelic objects carrying local-global information. This is the kind of bridge that could eventually connect TDA, arithmetic geometry, and representation-theoretic local-global principles.

---

## Core new definitions to introduce

You must define at least one genuinely new structure not already in the catalog. I recommend introducing all of the following.

### 1. Prime-primary torsion persistence profile
For a filtration `F : Fin (n+1) → AddCommGroupCat` with structure maps
`ι : ∀ i j, i ≤ j → F i ⟶ F j`, define the prime support at level `k` by extracting the set of primes for which the torsion subgroup has nontrivial `p`-primary part.

In Lean, for a finite abelian group model `A : Type*` with `[AddCommGroup A] [Finite A]`, define something like:

```lean
def pPrimaryTorsionNonempty (p : ℕ) [Fact p.Prime] (A : Type*) [AddCommGroup A] : Prop := ...
```

and then for a filtration:

```lean
def torsionPrimeSupport
    {n : ℕ} (F : Fin (n+1) → Type*) [∀ i, AddCommGroup (F i)] :
    Fin (n+1) → Finset ℕ := ...
```

### 2. Adelic torsion persistence datum
Define a structure packaging the family of prime-primary persistence modules together with finite-support compatibility.

A possible Lean shape:

```lean
structure AdelicTorsionDatum (n : ℕ) where
  carrier : ℕ → Fin (n+1) → Type*
  instAddCommGroup : ∀ p i, AddCommGroup (carrier p i)
  structureMap :
    ∀ p {i j : Fin (n+1)}, i ≤ j → carrier p i →+ carrier p j
  finitePrimeSupport :
    ∀ i, {p : ℕ | Nat.Prime p ∧ Nonempty (carrier p i)}.Finite
```

You may want a more concrete version using subgroups or quotients already available in Mathlib. The key novelty is the **finite-support adelic packaging**.

### 3. Barcode reconstruction map
Define a map from the adelic datum back to the global torsion barcode:

```lean
def reconstructTorsionSupport
    {n : ℕ} (D : AdelicTorsionDatum n) :
    Fin (n+1) → Finset ℕ := ...
```

This should be the formal bridge between local prime data and the global barcode.

---

## Precise theorem targets

You must prove at least 3 substantial theorems. The following are the target statements.

### Theorem 1: Prime-wise decomposition of torsion persistence
For a filtered finite abelian group, the torsion support at each level equals the union of the supports of the prime-primary components, and the persistence maps preserve this decomposition.

**Mathematical statement.**
Let `F : Fin (n+1) → Ab` be a finite filtration of finite abelian groups with compatible maps. For each index `i`, the torsion subgroup `T(F_i)` decomposes canonically as a finite direct sum over primes
\[
T(F_i) \cong \bigoplus_p T_p(F_i),
\]
and for every `i ≤ j`, the map `F_i → F_j` restricts to maps `T_p(F_i) → T_p(F_j)` commuting with the decomposition. Hence the torsion barcode is determined prime-wise.

**Lean-oriented target signature.**
A realistic formalization target may look like:

```lean
theorem torsionSupport_eq_union_primeSupports
    {n : ℕ}
    (F : Fin (n+1) → Type*)
    [∀ i, AddCommGroup (F i)]
    [∀ i, Finite (F i)]
    (map : ∀ {i j : Fin (n+1)}, i ≤ j → F i →+ F j) :
    ∀ i : Fin (n+1),
      torsionSupport F i =
        (Finset.biUnion (persistentPrimeSupportUpTo F i) fun p => {i}) := ...
```

If the exact existing catalog definitions force a different shape, adapt the statement but preserve the content: **global torsion support is exactly the prime-wise union**.

A second, stronger version should state functoriality:

```lean
theorem map_preserves_pPrimary_torsion
    {n : ℕ}
    (F : Fin (n+1) → Type*)
    [∀ i, AddCommGroup (F i)]
    [∀ i, Finite (F i)]
    (map : ∀ {i j : Fin (n+1)}, i ≤ j → F i →+ F j)
    {p : ℕ} [Fact p.Prime] {i j : Fin (n+1)} (hij : i ≤ j) :
    MapsTo (pPrimaryTorsionSubgroup p (F i)) (pPrimaryTorsionSubgroup p (F j)) (map hij) := ...
```

This theorem is the arithmetic backbone of the entire program.

---

### Theorem 2: Adelic reconstruction theorem
This is the central breakthrough theorem.

**Mathematical statement.**
For every finite filtration of finite abelian groups `F`, there exists an adelic torsion persistence datum `A(F)` such that for every filtration index `i`, the torsion barcode at `i` is recoverable exactly from the set of primes with nontrivial `p`-component in `A(F)`. Moreover, this reconstruction is unique among finite-support prime-wise decompositions.

Formally:
\[
\forall i,\quad \mathrm{torsionSupport}(F,i)
=
\mathrm{reconstructTorsionSupport}(A(F),i),
\]
and if `D` is any other finite-support prime-wise persistence datum with the same local supports, then `D` has the same reconstructed barcode.

**Lean-oriented target signature.**
```lean
theorem exists_adelic_torsion_datum_reconstructing
    {n : ℕ}
    (F : Fin (n+1) → Type*)
    [∀ i, AddCommGroup (F i)]
    [∀ i, Finite (F i)] :
    ∃ D : AdelicTorsionDatum n,
      ∀ i : Fin (n+1),
        reconstructTorsionSupport D i = torsionSupport F i := ...
```

and uniqueness at the level of reconstructed barcode:

```lean
theorem adelic_reconstruction_unique_on_support
    {n : ℕ}
    {D₁ D₂ : AdelicTorsionDatum n}
    (h :
      ∀ p i, localPrimeSupport D₁ p i = localPrimeSupport D₂ p i) :
    ∀ i, reconstructTorsionSupport D₁ i = reconstructTorsionSupport D₂ i := ...
```

This is the theorem that upgrades catalog-level completeness from bounded support bookkeeping to a local-global arithmetic principle.

---

### Theorem 3: Finite-support criterion via bounded torsion profile
Use the catalog theorem `torsionProfileUpTo_complete_for_bounded_support` as a serious input, not just a citation.

**Mathematical statement.**
If a filtered abelian group has bounded torsion profile up to level `N`, then its adelic torsion datum has finite prime support up to level `N`, and conversely, finite prime support determines the bounded torsion profile completely.

This should sharpen the existing bounded-support completeness theorem into an adelic equivalence criterion.

**Lean-oriented target signature.**
```lean
theorem bounded_support_iff_finite_adelic_support
    {n : ℕ}
    (F : Fin (n+1) → Type*)
    [∀ i, AddCommGroup (F i)]
    [∀ i, Finite (F i)] :
    (∃ B, torsionProfileBoundedBy F B) ↔
    (∃ D : AdelicTorsionDatum n, ∀ i, (primeSupportAt D i).Finite) := ...
```

A more implementation-friendly finite version with `Finset ℕ` is also acceptable:

```lean
theorem bounded_support_iff_exists_finset_prime_control
    {n : ℕ}
    (F : Fin (n+1) → Type*)
    [∀ i, AddCommGroup (F i)]
    [∀ i, Finite (F i)] :
    (∃ S : Finset ℕ, ∀ i, torsionPrimeSupport F i ⊆ S) ↔
    ∃ D : AdelicTorsionDatum n, ∀ i, primeSupportFinset D i ⊆ S := ...
```

This theorem is where the catalog lineage becomes mathematically decisive.

---

### Theorem 4: Cross-domain theorem — arithmetic persistence detects CRT splitting
You are required to include at least one theorem connecting to a different domain. The strongest accessible bridge here is between persistent homology and classical algebra/number theory via the Chinese Remainder Theorem.

**Mathematical statement.**
For a filtration whose torsion orders are supported on coprime integers `m` and `n`, the persistence module on the `mn`-torsion part splits as the product of the `m`- and `n`-torsion persistence modules. This is a persistence-theoretic analogue of CRT.

**Lean-oriented target signature.**
```lean
theorem persistence_CRT_split
    {n : ℕ}
    (F : Fin (n+1) → Type*)
    [∀ i, AddCommGroup (F i)]
    [∀ i, Finite (F i)]
    (map : ∀ {i j : Fin (n+1)}, i ≤ j → F i →+ F j)
    {m k : ℕ} (hcop : Nat.Coprime m k) :
    ∀ i : Fin (n+1),
      mnTorsionSubgroup (m * k) (F i) ≃+
        productTorsionSubgroup m k (F i) := ...
```

This is not merely algebraic bookkeeping. It says persistence itself respects local-global factorization. That is the conceptual leap.

---

## Why this would be a breakthrough

If you prove these theorems, you establish that torsion barcodes are not arbitrary finite combinatorial artifacts but arithmetic objects with local-global structure. This opens:

- **Arithmetic Topological Data Analysis**
- **Persistence over local and global fields**
- **Prime-sensitive invariants for filtered complexes**
- Potential analogies with **Euler products**, **adelic sheaves**, and eventually **representation-theoretic persistence**
- A route toward defining zeta functions or L-functions attached to persistence modules

This is not “persistent homology with extra labels.” It is the beginning of a local-global theory of topological signals.

---

## Proof architecture: 3 possible strategies

You must include multi-step proofs with real mathematical content. Use induction, `rcases`, `by_contra`, `field_simp` where relevant for rational identities if you introduce counting invariants, and substantial `calc` chains.

### Strategy A: Finite abelian group classification + functorial p-primary decomposition
**Most promising.**

1. For each filtration level `F i`, invoke the structure theory of finite abelian groups to isolate the torsion subgroup and decompose it into `p`-primary pieces.
2. Prove that any homomorphism between finite abelian groups sends `p`-primary torsion to `p`-primary torsion. This gives a prime-wise persistence module.
3. Package the family over all primes into `AdelicTorsionDatum`; prove finite support using finiteness of each group order.
4. Deduce reconstruction by showing an element is torsion iff its order has some prime divisor, and use the catalog support theorems to identify the support sets.

Why this is strongest: it matches the arithmetic content directly and should be formalizable with subgroup-level arguments without needing a full formalization of topological adeles.

### Strategy B: Chinese Remainder assembly first, then pass to primes
1. Work with `n`-torsion subgroups for composite `n`.
2. Use CRT to split coprime torsion parts and recursively decompose by prime-power factorization.
3. Define the adelic datum as the compatible family of all prime-power persistence slices.
4. Recover prime support and barcode by projection.

Why this is attractive: it produces a constructive algorithm and naturally yields the demo for `ℤ/6ℤ`.  
Why it is secondary: formal CRT decomposition in full generality may be heavier than direct prime-primary subgroup arguments.

### Strategy C: Bounded-support completeness via catalog theorem as the organizing principle
1. Start from `torsionProfileUpTo_complete_for_bounded_support`.
2. Show that bounded support implies only finitely many relevant primes.
3. Define the adelic object abstractly as the family indexed by those primes.
4. Prove uniqueness by extensionality on reconstructed support sets.

Why this matters: it tightly integrates the catalog and gives a clean equivalence theorem.  
Why it should supplement, not replace, Strategy A: by itself it risks being too support-combinatorial unless grounded in actual subgroup decomposition.

**Recommendation:** Use Strategy A for the main existence/reconstruction theorem, Strategy B for the explicit CRT-splitting theorem and algorithm, and Strategy C for the bounded-support equivalence theorem.

---

## Required deep proof tactics

Your file must contain at least 3 theorem proofs using nontrivial tactics and structure. Suggested proof patterns:

- **Induction** on the number of prime divisors of the torsion exponent, or on filtration index.
- **`rcases`** to unpack finite abelian decomposition data or support witnesses.
- **`by_contra`** to prove uniqueness of reconstruction from prime supports.
- **Multi-step `calc`** reasoning to relate support sets under decomposition.
- **`field_simp`** if you define any rational generating series, e.g. an Euler characteristic generating function or a persistence zeta toy invariant.

Do not produce a file whose main theorems collapse to computational enumeration.

---

## Concrete computational test case

You must formalize and compute the explicit example of `ℤ/6ℤ` with a 3-level filtration, e.g.
\[
0 \subset 2\mathbb{Z}/6\mathbb{Z} \subset \mathbb{Z}/6\mathbb{Z}
\]
or another genuinely nontrivial 3-level filtration with changing 2- and 3-primary behavior.

Required deliverables in Lean and Python:

1. Construct the filtration explicitly.
2. Compute the 2-primary barcode.
3. Compute the 3-primary barcode.
4. Show the reconstructed adelic barcode matches the full torsion barcode.
5. Search over filtrations with at least 4 levels on small groups such as `ℤ/12ℤ`, `ℤ/18ℤ`, `ℤ/2 × ℤ/6`, and attempt falsification of the conjecture.

This computational component is scientifically essential: if reconstruction fails, that failure is as valuable as a theorem.

---

## Cross-domain connections to emphasize

You must explicitly connect this work to at least one other domain in a theorem or construction.

### Number theory ↔ persistent homology
Prime decomposition of torsion becomes decomposition of barcodes by arithmetic place.

### Algebraic geometry ↔ persistence
The adelic packaging should be framed as a first approximation to a sheaf-like object over `Spec ℤ`, where each prime fiber records a local persistence module.

### Representation theory / Langlands heuristics
Do not overclaim, but explain the analogy: local data at each prime plus a global finite-support compatibility condition is the same architecture that makes adelic mathematics powerful.

### Application keywords
Include these explicitly in your paper and article:
- arithmetic persistent homology
- adelic barcode
- prime-sensitive topological invariants
- local-global principle
- Chinese remainder persistence
- arithmetic TDA
- torsion decomposition
- filtered finite abelian groups
- persistence over local fields
- barcode reconstruction

---

## Testable conjecture to state clearly

You must include at least one falsifiable conjecture with a computational disproof protocol.

### Main conjecture
For every finite filtration `F` of finite abelian groups, the reconstructed support from the adelic torsion datum equals the global torsion barcode at every level.

A Lean-facing statement could be recorded as:

```lean
conjecture adelic_barcode_reconstruction_conjecture
    {n : ℕ}
    (F : Fin (n+1) → Type*)
    [∀ i, AddCommGroup (F i)]
    [∀ i, Finite (F i)] :
    ∃ D : AdelicTorsionDatum n,
      ∀ i, reconstructTorsionSupport D i = torsionSupport F i
```

### Falsification test
Enumerate filtrations of small finite abelian groups with at least 4 levels and compare:
- direct global torsion support,
- prime-wise reconstructed support,
- CRT-assembled support.

A single mismatch falsifies the conjecture.

### Stronger hypothesis for FUTURE_DIRECTIONS
The adelic datum determines not only support but also interval multiplicities of a torsion barcode decomposition prime-by-prime.

This is stronger and likely false in full generality; it is an excellent target for computational stress tests.

---

## Mandatory deliverables

You must produce **all** of the following.

### 1. Lean file with new definitions and at least 3 deep theorems
- Minimize `sorry`
- Include at least one new structure
- Include at least one cross-domain theorem
- Include the explicit `ℤ/6ℤ` worked example

### 2. `FUTURE_DIRECTIONS.md`
Include 3–5 **testable scientific hypotheses**, each with a clear falsification method. Examples:

- **Hypothesis 1:** For finite filtrations of finite abelian groups, adelic support reconstruction is always exact.  
  **Test:** Exhaustive search on groups of order ≤ 32.

- **Hypothesis 2:** Prime-wise interval multiplicities determine the full torsion barcode for split filtrations.  
  **Test:** Compare split vs nonsplit filtrations on `ℤ/4 × ℤ/9`.

- **Hypothesis 3:** CRT splitting persists under all filtration maps with coprime torsion exponents.  
  **Test:** Enumerate compatible maps and search for counterexamples.

- **Hypothesis 4:** A persistence zeta function formed from prime barcode lengths satisfies multiplicativity under direct products.  
  **Test:** Compute on small examples.

### 3. `RESEARCH_PAPER.md`
A standalone scientific paper containing:
- precise definitions,
- theorem statements,
- proof ideas,
- computational experiments,
- significance,
- limitations,
- next conjectures.

Someone reading only this paper must understand the discovery without seeing code.

### 4. `ARTICLE.md`
Write in Scientific American style. Make it vivid and conceptual.  
**Taboo:** do not focus on formal verification machinery. Focus on the mathematical idea: topological signatures with arithmetic place structure.

### 5. Verified algorithm / computational method
Implement an algorithm that:
- takes a filtered finite abelian group,
- computes prime-wise torsion persistence data,
- assembles the adelic support,
- reconstructs the global torsion barcode,
- checks equality.

### 6. `demo.py`
Provide an interactive demonstration:
- choose a small filtered finite abelian group,
- display prime-wise supports,
- display adelic reconstruction,
- verify or refute the conjecture on sample instances.

---

## Final call to arms

Do not settle for “support is a union over primes.” That is only the entry point. The real target is a **local-global theorem for persistence**: an arithmetic decomposition principle showing that topological evolution across a filtration can be encoded place-by-place and reassembled adelically.

If you can make this precise in Lean 4 with strong theorems, explicit constructions, and computational tests, you will have created a new research direction: **adelic persistent homology**. This is exactly the kind of idea that can seed a field.

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
