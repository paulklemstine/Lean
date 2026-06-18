## Assignment: Direction 3: Quotient Security Monotonicity — Proof or Counterexample

**Mode:** `prove` with a parallel `counterexample` branch if the stated generality fails.

Prove genuinely new, non-trivial theorems about **security monotonicity under quotient/compression maps** for finite module-LWE style distributions. Build directly on the catalog lemmas
- `Cryptography/ModuleLWE/KernelQuotient.lean`
- `Cryptography/ModuleLWE/SearchDecision.lean`
especially the existing statement around `quotientSecurityMonotonicity_conjecture` and the transport identity `acceptProb_map_eq`.

The core opportunity is this: what looks like a folklore “data processing” statement for distinguishers should be turned into a **formal theorem schema** in Lean for finite algebraic probability spaces. If the broad conjecture is false, isolate the exact obstruction and produce the sharp corrected theorem. Either outcome is scientifically valuable.

---

## Central Mathematical Goal

The informal conjecture as stated is morally a **decision-theoretic data processing inequality** for finite pushforward distributions along a surjective linear map. The crucial insight is that there are really **three levels** here:

1. **Single-distribution advantage against uniform baseline**  
2. **Binary distinguishing advantage between two distributions**  
3. **Module-LWE quotient security as a special case of (2)**

You should not stop at the ad hoc module-LWE formulation. Instead, formalize the general finite theorem and recover the cryptographic corollary.

---

## Precise Theorem Targets

### Theorem 1: Pullback Preservation of Acceptance Probability
This is the structural engine and should be restated in the strongest useful form.

Let `μ : PMF M`, `f : M → N`, `D : N → Bool`. Then acceptance probability after pushforward equals acceptance probability before pushforward against the pullback distinguisher.

### Lean 4 target signature
```lean
theorem acceptProb_map_pullback
    {M N : Type*} [Fintype M] [DecidableEq M] [Fintype N] [DecidableEq N]
    (μ : PMF M) (f : M → N) (D : N → Bool) :
    acceptProb (PMF.map f μ) D = acceptProb μ (fun m => D (f m))
```

If the catalog theorem `acceptProb_map_eq` already has essentially this statement, then:
- use it explicitly,
- generalize it if needed to the cleanest finite form,
- and make this theorem the entry point for the later security monotonicity results.

---

### Theorem 2: Quotient Security Monotonicity Against a Reference Distribution
The right theorem is not merely about one distribution `χ` versus `1/2`, but about **distance from a reference distribution** transported through a map.

For distributions `μ ν : PMF M`, define decision advantage
```lean
def decisionAdvantage (μ ν : PMF α) : ℝ := 
  supᵢ? -- or a finite-set max over Boolean distinguishers
```
In the finite setting, Boolean distinguishers are finite, so this should be definable as a `Finset.sup`/`Finset.max'` over functions `α → Bool`.

Then prove monotonicity:
```lean
theorem decisionAdvantage_map_le
    {M N : Type*} [Fintype M] [DecidableEq M] [Fintype N] [DecidableEq N]
    (μ ν : PMF M) (f : M → N) :
    decisionAdvantage (PMF.map f μ) (PMF.map f ν) ≤ decisionAdvantage μ ν
```

This is the real theorem. It is the finite, exact, formal cryptographic version of the **data processing inequality for total variation / optimal testing advantage**.

If a direct `decisionAdvantage` definition is too heavy, use the equivalent finite formulation:
```lean
def testAdv (μ ν : PMF α) (D : α → Bool) : ℝ :=
  |acceptProb μ D - acceptProb ν D|

theorem testAdv_map_le
    {M N : Type*} [Fintype M] [DecidableEq M] [Fintype N] [DecidableEq N]
    (μ ν : PMF M) (f : M → N) (D : N → Bool) :
    testAdv (PMF.map f μ) (PMF.map f ν) D ≤
      testAdv μ ν (fun m => D (f m))
```
and then derive the max-over-distinguishers corollary.

---

### Theorem 3: Quotient Security Monotonicity for Uniform Baseline on the Codomain
This theorem connects compression to cryptographic security margins.

Assume `f : M →ₗ[R] N` is surjective and `uM`, `uN` are uniform distributions on finite `M`, `N`. Then pushforward of `uM` under `f` is `uN`. Therefore any distinguisher against compressed noise relative to uniform can be pulled back to a distinguisher before compression with exactly the same bias.

Precise statement:
```lean
theorem quotientSecurityMonotonicity_uniform
    {R M N : Type*}
    [Semiring R]
    [AddCommMonoid M] [Module R M] [Fintype M] [DecidableEq M]
    [AddCommMonoid N] [Module R N] [Fintype N] [DecidableEq N]
    (f : M →ₗ[R] N)
    (hsurj : Function.Surjective f)
    (χ : PMF M)
    (D : N → Bool) :
    |acceptProb (PMF.map f χ) D - (1/2 : ℝ)| ≤
    |acceptProb χ (fun m => D (f m)) - (1/2 : ℝ)|
```
This exact `1/2` statement is only natural if the codomain reference distribution is already known to map appropriately to a balanced baseline. More conceptually, the cleaner theorem is
```lean
theorem quotientSecurityMonotonicity_uniform'
    ...
    |acceptProb (PMF.map f χ) D - acceptProb uniformN D| ≤
    |acceptProb χ (fun m => D (f m)) - acceptProb uniformM (fun m => D (f m))|
```
and then derive the `1/2` version only under a separate “balanced test” hypothesis if necessary.

**Important:** The original conjecture with `1/2` may be too coarse or even improperly normalized unless the baseline is exactly uniform and the distinguisher is interpreted appropriately. If so, correct it rather than forcing a false statement.

---

## New Definition Requirement

You must introduce at least one genuinely new definition not already present in the catalog.

### Recommended new definition
Define a **compression-secure pair** or **quotient-monotone channel**:
```lean
def QuotientMonotone
    {M N : Type*} [Fintype M] [DecidableEq M] [Fintype N] [DecidableEq N]
    (f : M → N) : Prop :=
  ∀ μ ν : PMF M, decisionAdvantage (PMF.map f μ) (PMF.map f ν) ≤ decisionAdvantage μ ν
```

Then prove:
```lean
theorem linearMap_quotientMonotone
    {R M N : Type*} ...
    (f : M →ₗ[R] N) :
    QuotientMonotone f
```
or the strongest valid variant.

This is more than a cryptographic lemma: it turns quotient maps into **information-loss channels with formally certified monotone testing power**.

---

## If the Original Conjecture Fails: Produce the Sharp Counterexample

If the exact statement involving only a single distribution `χ` and baseline `1/2` does not typecheck mathematically or fails semantically, do not patch it cosmetically. Instead:

1. Produce a finite explicit counterexample.
2. Show exactly which assumption is missing:
   - wrong baseline,
   - lack of surjectivity,
   - non-uniform reference not preserved by pushforward,
   - non-kernel-invariant error,
   - non-Boolean vs Boolean test mismatch.
3. Replace the conjecture with the strongest true theorem.

A valuable counterexample target:
```lean
theorem non_surjective_compression_can_increase_bias :
  ∃ (M N : Type) (_ : Fintype M) (_ : DecidableEq M)
    (_ : Fintype N) (_ : DecidableEq N)
    (μ : PMF M) (f : M → N) (D : N → Bool),
    ¬ Function.Surjective f ∧
    |acceptProb (PMF.map f μ) D - acceptProb uniformN D| >
    |acceptProb μ (fun m => D (f m)) - acceptProb uniformM (fun m => D (f m))|
```
or a simpler finite version over `Fin n`.

This would reveal the exact role of surjectivity and uniform pushforward.

---

## Lean 4 Type Signature Suggestions

You should aim to formalize at least some of the following signatures, adapted to the actual catalog APIs:

```lean
def testAdvantage
    {α : Type*} [Fintype α] [DecidableEq α]
    (μ ν : PMF α) (D : α → Bool) : ℝ :=
  |acceptProb μ D - acceptProb ν D|

def maxTestAdvantage
    {α : Type*} [Fintype α] [DecidableEq α]
    (μ ν : PMF α) : ℝ :=
  Finset.sup (univ.pi (fun _ => ({true, false} : Finset Bool))) (fun D => testAdvantage μ ν D)
```

```lean
theorem testAdvantage_map_eq_pullback
    {M N : Type*} [Fintype M] [DecidableEq M] [Fintype N] [DecidableEq N]
    (μ ν : PMF M) (f : M → N) (D : N → Bool) :
    testAdvantage (PMF.map f μ) (PMF.map f ν) D =
    testAdvantage μ ν (fun m => D (f m))
```

```lean
theorem maxTestAdvantage_map_le
    {M N : Type*} [Fintype M] [DecidableEq M] [Fintype N] [DecidableEq N]
    (μ ν : PMF M) (f : M → N) :
    maxTestAdvantage (PMF.map f μ) (PMF.map f ν) ≤ maxTestAdvantage μ ν
```

```lean
def KernelInvariant
    {R M N : Type*} [Semiring R]
    [AddCommMonoid M] [Module R M]
    (f : M →ₗ[R] N) (χ : PMF M) : Prop :=
  ∀ m k, k ∈ LinearMap.ker f → χ m = χ (m + k)
```
If this exact notion is absent in the catalog, introducing it is mathematically worthwhile. Then prove it implies factorization through the quotient / fibers, if feasible.

```lean
theorem kernelInvariant_factor_through_pushforward
    ...
```

This creates a strong bridge between algebraic symmetry and statistical indistinguishability.

---

## Proof Strategy Architecture

### Strategy A: Direct pullback-of-distinguishers argument
**Most promising for the main theorem.**

1. Use `acceptProb_map_eq` to rewrite
   `acceptProb (PMF.map f μ) D = acceptProb μ (D ∘ f)`.
2. Do the same for the reference distribution `ν`.
3. Conclude
   `testAdvantage (PMF.map f μ) (PMF.map f ν) D = testAdvantage μ ν (D ∘ f)`.
4. If using a max-over-distinguishers definition, show every distinguisher on `N` pulls back to one on `M`, hence the set of compressed distinguishers is a subset of all original distinguishers.

Why this is best: it is conceptually exact, uses existing catalog infrastructure, and gives equality at the level of individual tests, from which monotonicity is immediate.

---

### Strategy B: Total variation / Neyman–Pearson route
**Best for a stronger conceptual paper, possibly harder in Lean.**

1. Define finite total variation distance:
   `TV(μ, ν) = (1/2) * ∑ x, |μ x - ν x|`.
2. Prove the finite variational characterization:
   `TV(μ, ν) = max_D |acceptProb μ D - acceptProb ν D|`.
3. Show pushforward contracts TV:
   `TV(map f μ, map f ν) ≤ TV(μ, ν)`,
   by summing over fibers and using triangle inequality.
4. Deduce quotient security monotonicity.

Why it matters: this turns the cryptographic statement into a theorem in finite information theory and statistical decision theory, opening a path to KL-divergence, Rényi divergence, and strong data-processing constants.

---

### Strategy C: Fiber-constant / quotient-factorization route
**Best if kernel invariance is central to the module-LWE application.**

1. Define kernel-invariant PMFs and prove that such a PMF is constant on fibers of `f`.
2. Construct the induced PMF on the quotient/codomain and show exact factorization.
3. Show that any distinguisher on the quotient lifts canonically to a fiber-constant distinguisher upstairs.
4. Conclude that compression cannot create new distinguishing power; it only restricts the class of visible observables.

Why this is valuable: it reveals the algebraic mechanism behind security monotonicity, not merely the probabilistic one.

---

## Required Theorem Portfolio

Your Lean file must contain **at least 3 nontrivial theorems**, with proofs using multi-step reasoning. Recommended portfolio:

1. `testAdvantage_map_eq_pullback`
   - use `calc`, rewriting, absolute value congruence.
2. `maxTestAdvantage_map_le`
   - use finite enumeration of Boolean distinguishers and subset/sup arguments.
3. `uniform_map_of_surjective_linear`
   - prove pushforward of uniform under surjective finite linear map is uniform on codomain, likely requiring counting fibers/cardinality arguments.
4. Optional stronger theorem: `linearMap_quotientMonotone`.
5. Optional structural theorem: `kernelInvariant_factor_through_pushforward`.

At least one proof should genuinely use:
- `rcases` on surjectivity witnesses,
- induction or finite-sum reasoning,
- `by_contra`,
- `field_simp` if normalized cardinalities appear,
- substantial `calc` chains.

No trivial `native_decide`-style closure.

---

## Cross-Domain Connections

This project is strongest if presented not merely as a cryptography lemma, but as a new formal bridge among:

- **Cryptography**: module-LWE compression and security preservation
- **Information theory**: data processing inequality for statistical tests
- **Representation / module theory**: quotient maps, kernels, fiber symmetries
- **Statistical decision theory**: Neyman–Pearson optimal distinguishers
- **Theoretical computer science**: hardness preservation under lossy compression
- **Physics analogy**: coarse-graining in statistical mechanics cannot increase observable distinguishing power under deterministic projection

This “coarse-graining cannot increase distinguishability” viewpoint is especially powerful. It reframes quotient security as a theorem about **renormalization of observables**.

---

## Breakthrough Significance

If proved in the right generality, this becomes a foundational theorem schema:

> Deterministic quotient channels in finite algebraic systems are monotone for optimal binary statistical tests.

That is bigger than module-LWE. It would let future work formalize:
- security monotonicity for ring-LWE and code-based schemes,
- certified privacy amplification by deterministic compression,
- strong data-processing constants for structured algebraic channels,
- coarse-grained distinguishability in finite physical and probabilistic models.

If instead you find a counterexample, the impact is equally sharp: it pinpoints exactly where cryptographic intuition based on “compression helps security” breaks, which is crucial for modular protocol design.

---

## Computational / Algorithmic Deliverable

You must provide a **verified algorithm** that computes, for finite spaces:
1. the test advantage of a fixed distinguisher,
2. the maximum test advantage over all Boolean distinguishers,
3. and checks monotonicity under a given map.

This algorithm should support exhaustive tests for:
- `(Z/qZ)^n → Z/qZ` with `q ≤ 7`, `n ≤ 3`,
- and, if feasible, `q ≤ 11` for selected sparse distributions.

The algorithm should be mirrored by `demo.py`, which:
- constructs small finite module instances,
- computes pre/post compression distinguishing advantages,
- searches for counterexamples when assumptions are weakened,
- and visualizes advantage contraction over quotient maps.

---

## Testable Conjectures for FUTURE_DIRECTIONS.md

You must include **3–5 falsifiable hypotheses**. At least one should be computationally testable immediately. Recommended examples:

1. **Strict contraction conjecture**  
   For every non-injective surjective linear map `f : (Z/qZ)^n → (Z/qZ)^m` with `m < n`, there exists a pair of distributions `μ, ν` such that
   `decisionAdvantage (map f μ) (map f ν) < decisionAdvantage μ ν`.
   **Test:** exhaustive search for small `q,n,m`.

2. **Equality characterization conjecture**  
   Equality in `decisionAdvantage_map_le` holds iff an optimal distinguisher for `(μ, ν)` is fiber-constant along `f`.
   **Test:** enumerate optimal distinguishers on small finite instances and compare with fiber partitions.

3. **Kernel-invariance factorization conjecture**  
   If `χ` is kernel-invariant under `f`, then every optimal distinguisher against `χ` versus uniform can be chosen fiber-constant.
   **Test:** exhaustive search over small module distributions.

4. **Non-surjective obstruction conjecture**  
   Dropping surjectivity destroys uniform-baseline monotonicity.
   **Test:** search all maps `Fin n → Fin m` for smallest counterexample.

5. **Strong data-processing constant conjecture**  
   For random surjective linear maps over `Z/qZ`, the expected contraction ratio of decision advantage depends only on fiber size asymptotically.
   **Test:** Monte Carlo over random maps/distributions in Python.

Each hypothesis must be stated so that a finite computation could refute it.

---

## Deliverables (ALL mandatory)

Produce all of the following:

1. **Lean formalization** with at least 3 nontrivial theorems and minimal `sorry`.
2. **`FUTURE_DIRECTIONS.md`** with 3–5 falsifiable scientific hypotheses and explicit computational tests.
3. **`RESEARCH_PAPER.md`** as a standalone scientific paper explaining:
   - the theorem or counterexample,
   - the proof architecture,
   - why quotient security monotonicity matters,
   - and what new research program it opens.
4. **`ARTICLE.md`** in Scientific American style, accessible and engaging.
5. **A verified algorithm or computational method** for exhaustive finite-instance checking.
6. **`demo.py`** demonstrating the theorem numerically and interactively.

---

## Application Keywords

module-LWE, quotient security, data processing inequality, total variation distance, Neyman–Pearson lemma, finite probability, pushforward measure, linear compression, kernel invariance, coarse-graining, statistical distinguishability, algebraic cryptography, finite modules, decision theory, information contraction, formal verification, Lean 4, Mathlib

---

## Final Charge

Do not merely prove the easy witness theorem `D' = D ∘ f` and stop. Either:

- elevate it into a **general finite data-processing theorem for distinguishers**, or
- discover the exact obstruction and produce the **sharp corrected statement with counterexample**.

The breakthrough is not “compression doesn’t hurt security” in one toy setting. The breakthrough is a formally verified principle that **quotients are monotone for observable statistical power** — or a precise theorem explaining why that seductive principle fails.

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
