## Assignment: Direction 2: Polynomial Width Growth

Prove genuinely new, non-trivial theorems about the **width of bounded certificate-family posets** on `Fin n`, sharpening the catalog’s current exponential antichain bound to a polynomial one for fixed certificate size bound `t`. The goal is not a cosmetic improvement: it is to convert the finite-basis theorem from a qualitative well-quasi-ordering statement into a **quantitative complexity theorem** for obstruction search.

This is the point where extremal combinatorics should enter the certificate-poset story decisively.

---

## Core Vision

The catalog already gives a finite-antichain mechanism and an exponential cardinal upper bound:
- `Pythagorean/CertificatePosetWQO.lean`
  - `antichain_card_bound`
  - `finite_antichain_of_bounded`

Those results say bounded-certificate families cannot realize arbitrarily large antichains, but the current upper bound is too coarse to guide algorithms. If, for each fixed certificate-size cap `t`, the width grows like `n^C` rather than `exp(c n)` or worse, then exhaustive obstruction search becomes parallelizable in a mathematically controlled way. That would turn the abstract WQO theorem into a usable complexity principle.

The breakthrough theorem to aim for is:

> **Polynomial Width Theorem.** For every fixed certificate size bound `t`, there exists an exponent `d(t)` and constant `C(t)` such that for all `n`, every antichain in the bounded-certificate family poset on `Fin n` has cardinality at most `C(t) * n ^ d(t)`.

This would open a new interface between:
- well-quasi-order theory,
- extremal set theory,
- profile methods in combinatorics,
- and algorithmic complexity of finite obstruction search.

---

## Precise Theorem Targets

You should formalize a **profile encoding** of bounded certificate families and prove polynomial width through it.

Because the exact definitions in `CertificatePosetWQO.lean` are catalog-specific, your first task is to align names and types precisely with the existing file. But the target theorem shape should be as close as possible to the following Lean signatures.

### New definition: profile vector / certificate shape count

Define a new concept not already in the catalog: a **certificate profile**, recording how many certificates of each admissible shape/size occur in a bounded family.

Suggested formalization pattern:

```lean
def CertificateProfile (t : ℕ) := Fin ((t + 1) * (t + 1)) → ℕ
```

or, if shape classes are already encoded in the catalog, a more semantic structure:

```lean
structure CertificateProfile (t : ℕ) where
  count : Fin ((t + 1) * (t + 1)) → ℕ
```

Then define the profile map from bounded certificate families on `Fin n`:

```lean
def certificateProfile {n t : ℕ} :
  BoundedCertificateFamily n t → CertificateProfile t
```

If the catalog has a better notion of certificate “type” or “shape class”, use that instead of the crude `(t+1)^2` index set. The key novelty is the **compression map from families to bounded-dimensional profile space**.

---

### Theorem 1: coordinate bounds are polynomial in `n`

For fixed `t`, each profile coordinate should be bounded by a polynomial in `n`, because certificates of size at most `t` are chosen from `Fin n`.

Target statement:

```lean
theorem profile_coordinate_bound
    (t : ℕ) :
    ∃ d : ℕ, ∀ n : ℕ, ∀ F : BoundedCertificateFamily n t,
      ∀ i : Fin ((t + 1) * (t + 1)),
        certificateProfile F i ≤ n ^ d
```

A sharper version, if available from counting shape classes, is preferable:

```lean
theorem profile_coordinate_bound_explicit
    (t n : ℕ) (F : BoundedCertificateFamily n t)
    (i : Fin ((t + 1) * (t + 1))) :
    certificateProfile F i ≤ ∑ k in Finset.range (t + 1), n ^ k
```

This theorem is the engine that turns combinatorial boundedness into asymptotic polynomiality.

---

### Theorem 2: incomparability lifts to profile incomparability

You need a theorem showing that if two families are incomparable in the certificate poset, then their profiles are incomparable in the product order, or at least that an antichain injects into a profile antichain.

Target statement:

```lean
theorem antichain_profile_injective
    {n t : ℕ} {s : Finset (BoundedCertificateFamily n t)}
    (hs : Set.Pairwise (fun a b => ¬ a ≤ b ∧ ¬ b ≤ a) ↑s) :
    Set.InjOn certificateProfile ↑s
```

Even better, if the order is reflected:

```lean
theorem profile_order_reflects
    {n t : ℕ} {F G : BoundedCertificateFamily n t} :
    certificateProfile F ≤ certificateProfile G → F ≤ G
```

If full order reflection is false, prove the weaker but sufficient statement:

```lean
theorem antichain_maps_to_profile_antichain
    {n t : ℕ} {A : Finset (BoundedCertificateFamily n t)}
    (hA : IsAntichain (· ≤ ·) (↑A : Set (BoundedCertificateFamily n t))) :
    IsAntichain (· ≤ ·) (certificateProfile '' (↑A : Set _))
```

This is the conceptual hinge: antichains in the certificate world are controlled by antichains in a fixed-dimensional lattice.

---

### Theorem 3: polynomial width bound

This is the headline theorem.

Target Lean shape:

```lean
theorem bounded_certificate_width_polynomial
    (t : ℕ) :
    ∃ C d : ℕ, ∀ n : ℕ,
      width (BoundedCertificateFamily n t) ≤ C * n ^ d
```

If `width` is not already defined in the catalog, define it via finite antichains:

```lean
def posetWidth (α : Type _) [Preorder α] [Fintype α] : ℕ :=
  sSup {k | ∃ A : Finset α, IsAntichain (· ≤ ·) (↑A : Set α) ∧ A.card = k}
```

Then prove:

```lean
theorem posetWidth_bounded_certificate_polynomial
    (t : ℕ) :
    ∃ C d : ℕ, ∀ n : ℕ,
      posetWidth (BoundedCertificateFamily n t) ≤ C * n ^ d
```

An explicit exponent in terms of profile dimension is even better:
- if the profile dimension is `m(t)`,
- then width in the box `[0, N]^m` is `O(N^(m-1))`,
- and if `N = O(n^t)`, then width is `O(n^{t(m-1)})`.

Even a crude explicit bound is scientifically valuable.

---

## Stronger Intermediate Lemma to Pursue

A major technical stepping stone, and itself a meaningful theorem:

```lean
theorem width_product_order_box_polynomial
    (m : ℕ) :
    ∃ C d : ℕ, ∀ N : ℕ,
      posetWidth ((Fin m → ℕ)ˢᵘᵇ fun f => ∀ i, f i ≤ N) ≤ C * N ^ d
```

This is a standalone extremal combinatorics result: the width of the integer box `[0,N]^m` under product order is polynomial in `N` for fixed `m`. It is morally a multivariate Sperner theorem. Once this is proved, the certificate theorem becomes a transfer theorem via profiles.

This is a beautiful cross-domain bridge:
- certificate obstructions become lattice points,
- antichains become level-set phenomena,
- and width becomes an enumerative question in discrete geometry.

---

## Proof Strategy Architecture

You must give Aristotle multiple proof paths and pursue the one that best matches the catalog infrastructure.

### Strategy A: Profile embedding + rank layers in a bounded box
**Most promising.**

1. **Define profile space** of bounded dimension depending only on `t`.
   - Each coordinate counts certificates in a fixed size/shape class.
   - Prove each coordinate is bounded by a polynomial in `n`.

2. **Show antichains inject into product-order antichains** in a box `[0, N(n,t)]^m`.
   - This is the conceptual transfer from certificate families to lattice points.

3. **Bound width of the box** using rank decomposition.
   - Equip `(Fin m → ℕ)` with rank `ρ(f) = ∑ i, f i`.
   - Every antichain intersects each rank level in at most that level’s cardinality.
   - The maximal level size is polynomial in `N` for fixed `m`, via coefficient bounds for
     \[
     (1 + x + \cdots + x^N)^m.
     \]
   - Formal route: prove every level has size at most `(m*N+1)^(m-1)` or another explicit polynomial.

Why this is best:
- It avoids importing the full strength of Dilworth/Mirsky if not already available.
- It converts the problem into finite counting in `ℕ^m`, which Lean handles well.
- It naturally yields an algorithm for profile-based width estimation.

---

### Strategy B: Chain decomposition via multivariate Dilworth/Mirsky
**Conceptually elegant, possibly heavier in Lean.**

1. Prove the profile image lies in a finite graded poset.
2. Use chain decomposition or Mirsky’s theorem to control antichains by the number of rank levels.
3. Estimate maximal rank level combinatorially.

This is attractive if Mathlib already has enough finite-poset machinery, but likely more infrastructure-heavy than necessary.

---

### Strategy C: Generating-function / coefficient extraction approach
**Most mathematically sophisticated; useful for explicit asymptotics.**

1. Encode profile vectors of rank `r` as coefficients of
   \[
   (1+x+\cdots+x^N)^m.
   \]
2. Show the maximal coefficient is `O(N^(m-1))` for fixed `m`.
3. Transfer that bound to profile antichains.

This route has strong scientific value because it links the theorem to analytic combinatorics and statistical mechanics:
- antichain width becomes a density-of-states problem,
- profile rank becomes an “energy,”
- and the central layer is the entropy-maximizing macrostate.

This is an excellent cross-domain connection if you can make even a partial formal bridge.

---

## Required Deep Proof Tactics

Your file must contain at least 3 substantial theorems proved using genuinely mathematical tactics such as:
- induction on `m`, `t`, or certificate size,
- `rcases` decompositions of finite-support/profile objects,
- `by_contra` to derive comparability from profile equality or rank arguments,
- `field_simp` if you normalize generating-function inequalities,
- multi-step `calc` blocks for polynomial inequalities and cardinal estimates.

Do **not** let the main theorems collapse to trivial automation.

Likely candidates for deep proofs:
1. `profile_coordinate_bound`
2. `antichain_maps_to_profile_antichain`
3. `width_product_order_box_polynomial`
4. `bounded_certificate_width_polynomial`

---

## Catalog Build-On Instructions

You must explicitly leverage:

- `Pythagorean/CertificatePosetWQO.lean`
  - `finite_antichain_of_bounded`
  - `antichain_card_bound`

Use them as follows:
- `finite_antichain_of_bounded` supplies the finiteness regime needed to define width meaningfully for bounded certificate families.
- `antichain_card_bound` gives a baseline exponential estimate; your theorem should be stated and documented as a **strict sharpening**.
- If possible, derive your polynomial theorem as a replacement corollary:
  ```lean
  theorem antichain_card_bound_polynomial ...
  ```
  and compare it directly against the old exponential bound in comments and in `RESEARCH_PAPER.md`.

---

## Cross-Domain Connections You Should Make Explicit

At least one theorem and the surrounding exposition must connect this direction to another domain.

### 1. Extremal combinatorics
This is the main bridge.
- Product-order width in `[0,N]^m`
- Sperner-type layer bounds
- Rank-unimodality heuristics

### 2. Enumerative combinatorics / generating functions
Profile counts are coefficients of bounded-degree multivariate generating functions.
Potential theorem:
```lean
theorem rank_level_cardinality_bound
    (m N r : ℕ) :
    card {f : Fin m → ℕ | (∀ i, f i ≤ N) ∧ ∑ i, f i = r} ≤ (m * N + 1) ^ (m - 1)
```

### 3. Statistical mechanics / entropy language
Not as metaphor only: profile vectors behave like occupancy distributions.
Width corresponds to the size of the most probable macro-layer.
This is scientifically important because it suggests asymptotic Gaussian/local-limit refinements later.

### 4. Algorithmic complexity
Polynomial width implies bounded parallel frontier size in exhaustive obstruction search.
This is not just abstract order theory; it predicts practical tractability.

---

## Application Keywords

Include these explicitly in your writeup and metadata-like comments:

**Application keywords:**  
quantitative well-quasi-ordering, antichain width, Sperner theory, Dilworth theory, profile method, obstruction search, parameterized complexity, finite basis theorem, discrete geometry, generating functions, entropy method, algorithmic combinatorics

---

## Concrete Theorem Menu

You need at least 3 nontrivial theorems. A strong file would include:

1. **Profile coordinate polynomial bound**
   ```lean
   theorem profile_coordinate_bound ...
   ```

2. **Profile antichain transfer**
   ```lean
   theorem antichain_maps_to_profile_antichain ...
   ```

3. **Width of bounded boxes in product order is polynomial**
   ```lean
   theorem width_product_order_box_polynomial ...
   ```

4. **Main transfer theorem for bounded certificate families**
   ```lean
   theorem bounded_certificate_width_polynomial ...
   ```

5. Optional stronger theorem:
   ```lean
   theorem bounded_certificate_width_explicit
       (t : ℕ) :
       ∃ d : ℕ, ∀ n : ℕ,
         posetWidth (BoundedCertificateFamily n t) ≤ (t + 1) ^ d * n ^ d
   ```

---

## Computational / Algorithmic Deliverable

Do not stop at existential theorems. Produce a verified computational method.

Define and verify a profile-based width estimator or exact enumerator for small `n,t`:
```lean
def enumerateProfiles (n t : ℕ) : Finset (CertificateProfile t)
def exactWidthFromProfiles (n t : ℕ) : ℕ
```

Then prove correctness in the small finite regime:
```lean
theorem exactWidthFromProfiles_spec
    (n t : ℕ) :
    exactWidthFromProfiles n t =
      posetWidth (BoundedCertificateFamily n t)
```
if full exactness is too hard, prove sound upper/lower bounds:
```lean
theorem exactWidthFromProfiles_upper ...
theorem exactWidthFromProfiles_lower ...
```

This algorithm is essential: the theorem should generate data, not just prose.

---

## Testable Conjectures

You must include at least one falsifiable conjecture with a clear computational disproof criterion. Include 3–5 if possible in `FUTURE_DIRECTIONS.md`.

### Conjecture A: sharp exponent conjecture
For fixed `t`, the width is asymptotically `Θ(n^{d(t)})` for an integer exponent `d(t)` determined by the profile dimension minus one.

**Test:** Compute exact widths for `n = 3,4,5,6` and `t = 2,3,4`; fit `log(width)` vs `log(n)` and compare against candidate exponents predicted by profile dimension.

### Conjecture B: central-layer extremality
The maximal antichains in profile space are induced by near-constant rank layers under the sum-of-coordinates grading.

**Disproof criterion:** Find a larger antichain not concentrated in a single rank layer.

### Conjecture C: asymptotic unimodality
For fixed `t`, the rank distribution of certificate profiles is eventually unimodal in `n`.

**Disproof criterion:** Compute profile rank histograms and exhibit a non-unimodal instance for larger `n`.

### Conjecture D: entropy refinement
The true width is asymptotic to the maximal coefficient of a profile generating polynomial, up to a multiplicative constant depending only on `t`.

**Disproof criterion:** Numerically compare exact width to maximal profile-layer size and detect unbounded ratio growth.

These are real scientific hypotheses, not vague invitations.

---

## Demo Requirements

Produce `demo.py` that:
1. Computes exact or estimated widths for `n = 3,4,5,6` and `t = 2,3,4`.
2. Prints the exponential catalog bound versus your polynomial/profile bound.
3. Fits a slope on log-log axes.
4. Visualizes rank-layer sizes in profile space if possible.

This is where the theorem meets experiment.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean file(s)** with the new definitions and at least 3 deep theorems, minimizing `sorry`.
2. **A structured `FUTURE_DIRECTIONS.md`** containing 3–5 falsifiable scientific hypotheses with explicit computational tests.
3. **A standalone `RESEARCH_PAPER.md`** explaining the theorem, proof architecture, significance, relation to catalog theorems, and next steps. A reader with no access to code must still understand the discovery.
4. **An `ARTICLE.md` in Scientific American style** explaining the mathematical idea and why polynomial width matters for searching obstruction landscapes. Do **not** focus on formal verification machinery.
5. **A verified algorithm or computational method** for exact/profile-based width computation or certified upper bounds.
6. **A `demo.py`** that interactively demonstrates the result on small cases.

---

## Standard of Success

Success is not “we improved a constant.” Success is:

- a new profile formalism for bounded certificate families,
- a theorem converting exponential antichain bounds into polynomial ones,
- a bridge from WQO theory to extremal combinatorics,
- and a computational pipeline showing the theorem’s quantitative bite.

If you can prove the full polynomial-width theorem, this becomes a field-opening statement: **finite basis theorems can carry complexity content**. If the full theorem resists, prove the box-width polynomial theorem and a rigorous profile transfer theorem; that already establishes the right architecture and likely unlocks the main result next cycle.

Soli Deo Gloria

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
