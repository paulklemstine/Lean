# Mode: prove

## Assignment: Conjecture 5 — Curvature-Generalization to Constant-Curvature Spaces

Prove a genuinely new hyperbolic conformal-packing theorem in Lean 4, not a cosmetic variant of Euclidean packing. The target is to turn the Poincaré disk model into a certified quantitative bridge between conformal geometry, metric packing, and algorithmic density bounds.

You should treat this as the first step toward a **formal theory of curvature-aware packing inequalities** valid across Euclidean, spherical, and hyperbolic geometries. The hyperbolic case is the forcing ground because conformal distortion is extreme near the boundary, and any theorem that survives there is structurally meaningful.

---

## Core breakthrough target

### Precise theorem statement

Let \(B^n := \{x \in \mathbb{R}^n : \|x\| < 1\}\) be the Euclidean unit ball, equipped with the Poincaré conformal factor
\[
\lambda_{\mathbb H}(x) = \frac{2}{1-\|x\|^2}.
\]
For a measurable domain \(\Omega \subseteq B^n\), define its hyperbolic weighted volume by
\[
\mathrm{hvol}_n(\Omega) := \int_{\Omega} \lambda_{\mathbb H}(x)^n \, dx.
\]
Define also the radial distortion on \(\Omega\):
\[
\Delta_\Omega := \frac{\sup_{x \in \Omega} \lambda_{\mathbb H}(x)^n}{\inf_{x \in \Omega} \lambda_{\mathbb H}(x)^n}.
\]

A first rigorous theorem to formalize is:

> **Theorem A (local hyperbolic conformal packing bound).**  
> Let \(n \ge 1\), let \(\Omega \subseteq B^n\) be measurable with finite Euclidean volume, and assume \(\Omega\) is contained in a closed Euclidean ball \(\overline B(0,\rho)\) with \(0 \le \rho < 1\). If \(S \subseteq \Omega\) is a set of centers of pairwise disjoint hyperbolic balls of radius \(r>0\), all contained in \(\Omega\), then
> \[
> \#S \cdot \inf_{x \in \Omega}\lambda_{\mathbb H}(x)^n \cdot \mathrm{capVol}_{\mathbb E}(n,\rho,r)
> \;\le\;
> \mathrm{hvol}_n(\Omega),
> \]
> where \(\mathrm{capVol}_{\mathbb E}(n,\rho,r)\) is a Euclidean lower bound for the Euclidean volume of a hyperbolic \(r\)-ball centered in \(\overline B(0,\rho)\).
> Consequently,
> \[
> \#S \le
> \frac{\mathrm{hvol}_n(\Omega)}
> {\inf_{x \in \Omega}\lambda_{\mathbb H}(x)^n \cdot \mathrm{capVol}_{\mathbb E}(n,\rho,r)}.
> \]

This is already nontrivial and formalizable: it replaces exact hyperbolic-volume formulas by a conformal lower bound that depends on the ambient radial cap \(\rho\).

Then push to the sharper radial formula:

> **Theorem B (explicit cap-volume lower bound in the Poincaré ball).**  
> If \(c \in B^n\) satisfies \(\|c\|\le \rho<1\), then every hyperbolic ball \(B_{\mathbb H}(c,r)\) contains a Euclidean ball of radius
> \[
> \underline R(\rho,r)=
> \frac{(1-\rho^2)\tanh(r/2)}{1+\rho\tanh(r/2)}
> \]
> and therefore
> \[
> \mathrm{vol}_{\mathbb E}(B_{\mathbb H}(c,r))
> \ge \omega_n \,\underline R(\rho,r)^n.
> \]
> Hence
> \[
> \#S \le
> \frac{\mathrm{hvol}_n(\Omega)}
> {\inf_{x \in \Omega}\lambda_{\mathbb H}(x)^n \,\omega_n\, \underline R(\rho,r)^n }.
> \]

Finally, isolate the curvature-generalization statement you actually want:

> **Theorem C (constant-curvature distortion schema, hyperbolic instance).**  
> There exists an explicit distortion factor
> \[
> D_{\mathbb H}(n,\rho,r)
> :=
> \frac{\sup_{\|x\|\le \rho}\lambda_{\mathbb H}(x)^n}
>      {\inf_{\|x\|\le \rho}\lambda_{\mathbb H}(x)^n}
> \cdot
> \frac{\mathrm{capVol}_{\mathbb H}(n,r)}
>      {\omega_n \underline R(\rho,r)^n}
> \]
> such that for every packing of hyperbolic \(r\)-balls in \(\Omega \subseteq \overline B(0,\rho)\),
> \[
> N_{\mathbb H}(\Omega,r)
> \le
> D_{\mathbb H}(n,\rho,r)\,
> \frac{\mathrm{hvol}_n(\Omega)}
>      {\mathrm{capVol}_{\mathbb H}(n,r)}.
> \]
> This is the correct formally robust version of the proposed hyperbolic conformal packing inequality.

This is the theorem you should actually prove. It captures the intended conjecture while avoiding false global uniformity over all of \(B^n\): because \(\lambda_{\mathbb H}(x)\to\infty\) as \(\|x\|\to 1\), any global distortion constant independent of \(\rho\) is almost certainly too optimistic. A successful formalization here does something more valuable than proving the original statement verbatim: it identifies the **correct renormalized theorem**.

---

## Lean 4 formalization targets

You should introduce a new structure encoding conformal metrics on Euclidean domains, specialized to the Poincaré ball.

### New definitions required

These definitions are mathematically meaningful and novel enough to satisfy the “new structure” requirement.

```lean
structure ConformalBallMetric (n : ℕ) where
  carrier : Set (EuclideanSpace ℝ (Fin n))
  cf      : EuclideanSpace ℝ (Fin n) → ℝ
  cf_pos  : ∀ ⦃x⦄, x ∈ carrier → 0 < cf x
```

```lean
def poincareCF {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) : ℝ :=
  2 / (1 - ‖x‖^2)
```

```lean
def poincareBall (n : ℕ) : Set (EuclideanSpace ℝ (Fin n)) :=
  {x | ‖x‖ < 1}
```

```lean
def hyperbolicWeightedVolume
    {n : ℕ}
    (s : Set (EuclideanSpace ℝ (Fin n))) : ℝ :=
  ∫ x in s, (poincareCF x) ^ n
```

```lean
def radialDistortion
    {n : ℕ}
    (ρ : ℝ) : ℝ :=
  ((2 / (1 - ρ^2)) ^ n) / ((2 : ℝ) ^ n)
```

```lean
def euclideanSubballRadius (ρ r : ℝ) : ℝ :=
  ((1 - ρ^2) * Real.tanh (r / 2)) / (1 + ρ * Real.tanh (r / 2))
```

```lean
def hyperbolicPackingNumber
    {n : ℕ}
    (Ω : Set (EuclideanSpace ℝ (Fin n))) (r : ℝ) : ℕ := ...
```

If exact metric-ball formalization becomes too heavy, define an abstract predicate expressing that a family of centers determines pairwise disjoint hyperbolic \(r\)-balls, and prove the counting theorem from that predicate.

---

## Suggested Lean theorem signatures

These signatures are intentionally realistic rather than ornamental. Adjust exact namespaces/types to match Mathlib conventions.

```lean
theorem poincareCF_monotone_radial
    {n : ℕ} {x y : EuclideanSpace ℝ (Fin n)}
    (hx : ‖x‖ ≤ ‖y‖) (hy : ‖y‖ < 1) :
    poincareCF x ≤ poincareCF y := by
  ...
```

```lean
theorem poincareCF_bounds_on_ball
    {n : ℕ} {ρ : ℝ}
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1) :
    ∀ x ∈ Metric.closedBall (0 : EuclideanSpace ℝ (Fin n)) ρ,
      (2 : ℝ) ≤ poincareCF x ∧ poincareCF x ≤ 2 / (1 - ρ^2) := by
  ...
```

```lean
theorem euclideanSubballRadius_pos
    {ρ r : ℝ} (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1) (hr : 0 < r) :
    0 < euclideanSubballRadius ρ r := by
  ...
```

```lean
theorem weighted_volume_lower_bound_of_subset_closedBall
    {n : ℕ}
    {Ω : Set (EuclideanSpace ℝ (Fin n))} {ρ : ℝ}
    (hΩ : Ω ⊆ Metric.closedBall (0 : EuclideanSpace ℝ (Fin n)) ρ)
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1) :
    (2 : ℝ) ^ n * volume Ω ≤ hyperbolicWeightedVolume Ω := by
  ...
```

```lean
theorem weighted_volume_upper_bound_of_subset_closedBall
    {n : ℕ}
    {Ω : Set (EuclideanSpace ℝ (Fin n))} {ρ : ℝ}
    (hΩ : Ω ⊆ Metric.closedBall (0 : EuclideanSpace ℝ (Fin n)) ρ)
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1) :
    hyperbolicWeightedVolume Ω ≤ (2 / (1 - ρ^2)) ^ n * volume Ω := by
  ...
```

```lean
theorem hyperbolic_ball_contains_euclidean_ball
    {n : ℕ} {c : EuclideanSpace ℝ (Fin n)} {ρ r : ℝ}
    (hc : ‖c‖ ≤ ρ) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1) (hr : 0 < r) :
    Metric.ball c (euclideanSubballRadius ρ r) ⊆ hyperbolicBall c r := by
  ...
```

```lean
theorem hyperbolic_packing_bound_local
    {n : ℕ}
    {Ω : Set (EuclideanSpace ℝ (Fin n))} {ρ r : ℝ}
    (hΩ : Ω ⊆ Metric.closedBall (0 : EuclideanSpace ℝ (Fin n)) ρ)
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1) (hr : 0 < r)
    (hs : IsHyperbolicPackingIn Ω r S) :
    (Nat.card S : ℝ) ≤
      hyperbolicWeightedVolume Ω /
      ((2 : ℝ) ^ n * volume (Metric.ball (0 : EuclideanSpace ℝ (Fin n))
        (euclideanSubballRadius ρ r))) := by
  ...
```

```lean
theorem hyperbolic_distortion_schema
    {n : ℕ}
    {Ω : Set (EuclideanSpace ℝ (Fin n))} {ρ r : ℝ}
    (hΩ : Ω ⊆ Metric.closedBall (0 : EuclideanSpace ℝ (Fin n)) ρ)
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1) (hr : 0 < r) :
    (hyperbolicPackingNumber Ω r : ℝ) ≤
      radialDistortion (n := n) ρ *
      (hyperbolicWeightedVolume Ω / hyperbolicCapVol n r) := by
  ...
```

The final theorem may require a custom `hyperbolicCapVol` definition if exact hyperbolic volume formulas are available; otherwise define it axiomatically first as the weighted volume of a model hyperbolic ball and prove comparison bounds.

---

## Proof strategy architecture

### Strategy A: Conformal-volume sandwich via Euclidean disjointness
This is the most promising route.

1. **Radial monotonicity of the conformal factor.**  
   Prove that \(x \mapsto 2/(1-\|x\|^2)\) is increasing in \(\|x\|\) on \([0,1)\). This gives explicit lower and upper bounds for \(\lambda_{\mathbb H}\) on any closed Euclidean subball \(\overline B(0,\rho)\).

2. **Euclidean subball inside hyperbolic ball.**  
   Use the explicit Poincaré-ball relation between hyperbolic radius \(r\) and Euclidean radius \(\tanh(r/2)\), corrected for an off-center point \(c\), to show that every hyperbolic ball centered at \(\|c\|\le \rho\) contains a Euclidean ball of radius \(\underline R(\rho,r)\).

3. **Disjoint-volume counting.**  
   A hyperbolic packing gives disjoint Euclidean subballs. Sum their Euclidean volumes, compare with the Euclidean volume of \(\Omega\), and then convert Euclidean volume to hyperbolic weighted volume using the lower conformal bound.

Why this is strongest: it minimizes dependence on a fully formal hyperbolic metric-space development and uses concrete inequalities, integration, and geometric containment—all highly formalizable.

---

### Strategy B: Weighted-measure disjointness directly in the Poincaré metric
This is conceptually cleaner but likely heavier.

1. Define hyperbolic volume of a set as \(\int \lambda^n\).
2. Prove that all hyperbolic \(r\)-balls centered in a radial cap \(\|c\|\le \rho\) have weighted volume bounded below uniformly.
3. Use countable additivity/subadditivity on pairwise disjoint packed balls.

Why this matters: if successful, it gives a reusable formal infrastructure for **all conformal metrics**, not just hyperbolic space. But it may require more measure-theoretic boilerplate.

---

### Strategy C: Möbius-invariant normalization plus center transport
This is the most conceptually ambitious.

1. Use the Möbius automorphism of the Poincaré ball sending \(c\) to \(0\).
2. Reduce geometric statements about off-center balls to the centered case.
3. Pull back Euclidean and weighted volume estimates through the automorphism, controlling Jacobians.

Why this is revolutionary: it would open the door to a **formalized hyperbolic harmonic analysis toolkit** in Lean. But it is probably a second-stage project unless relevant Möbius machinery already exists in the catalog.

---

## Minimum theorem slate

Your file must contain at least 3 serious theorems with nontrivial proofs. The following is the recommended slate:

1. `poincareCF_monotone_radial`  
   Proof should use inequality manipulation, monotonicity of \(t \mapsto 1/(1-t)\), and a `field_simp` stage.

2. `weighted_volume_lower_bound_of_subset_closedBall`  
   Proof should use measurable-set restriction, integral monotonicity, and a multi-step `calc`.

3. `hyperbolic_ball_contains_euclidean_ball`  
   Proof should use explicit inequalities for \(\tanh(r/2)\), radial estimates, and nontrivial algebra.

4. `hyperbolic_packing_bound_local`  
   Proof should combine disjointness, volume summation, lower bounds, and contradiction if needed.

At least three of these must be fully formalized with substantial tactics such as `rcases`, `by_contra`, `field_simp`, induction on finite packings, or layered `calc`.

---

## Cross-domain connections you must exploit

Do not keep this trapped in differential geometry. Make at least one theorem or discussion explicitly connect to another domain.

### 1. Information geometry / machine learning
The conformal factor blows up near the boundary, meaning hyperbolic geometry allocates exponentially more “representation volume” to peripheral regions. This is exactly why hyperbolic embeddings model trees and hierarchical data so well. Your packing theorem becomes a **certified capacity bound** for hyperbolic representation spaces.

Possible formal statement:
- A radial cap \(\|x\|\le \rho\) has weighted volume growth asymptotic to \((1-\rho^2)^{-n}\), implying exponentially increasing packing capacity near the boundary.

### 2. Statistical mechanics / negative-curvature phase space
Hyperbolic packing behaves unlike Euclidean packing because boundary growth is exponential. This mirrors phase-space growth in systems with negative curvature. Your theorem can be read as a **finite-volume entropy bound**: number of distinguishable \(r\)-states is bounded by weighted volume divided by local cell volume.

### 3. Geometric group theory
Hyperbolic volume growth is the continuous analogue of exponential growth in hyperbolic groups. The packing bound suggests a formal bridge between:
- packing numbers in \( \mathbb H^n \),
- growth functions of negatively curved groups,
- and coarse entropy estimates.

You should mention this explicitly in `RESEARCH_PAPER.md` and include application keywords below.

---

## Testable conjecture to include

State at least one falsifiable conjecture with a concrete computational test.

> **Conjecture D (boundary-shell asymptotic sharpness).**  
> For fixed \(n\) and \(r>0\), if
> \[
> \Omega_\rho := \{x \in \mathbb{R}^n : \rho_0 \le \|x\| < \rho\}
> \quad\text{with }\rho \to 1^-,
> \]
> then the ratio
> \[
> \frac{N_{\mathbb H}(\Omega_\rho,r)\,\mathrm{capVol}_{\mathbb H}(n,r)}
>      {\mathrm{hvol}_n(\Omega_\rho)}
> \]
> converges to \(1\) along an explicit family of shell packings.
> In words: the local conformal packing bound becomes asymptotically sharp in thin boundary shells.

**Computational test:**  
Implement shell domains in the 2D Poincaré disk, generate greedy packings for fixed hyperbolic radius \(r\), compute the normalized ratio above for \(\rho = 0.8, 0.9, 0.95, 0.98, 0.99\), and look for convergence or systematic failure. If the ratio stays bounded away from 1, the conjecture is false.

A second optional conjecture:

> **Conjecture E (curvature interpolation law).**  
> There exists a unified distortion factor \(D_K(n,\rho,r)\) for constant sectional curvature \(K\in\{-1,0,+1\}\) such that the Euclidean, hyperbolic, and spherical packing bounds are recovered as special cases and \(D_K\) varies continuously in the flat limit \(K\to 0\).

This is field-opening if you can formalize even a weak version.

---

## Computational / algorithmic deliverable

You must produce a verified computational method, not just theorems.

### Required algorithm
Implement an algorithm that:
1. samples a domain \(\Omega \subset B^2\),
2. computes the hyperbolic weighted area numerically,
3. computes the explicit lower-bound cell area from `euclideanSubballRadius ρ r`,
4. returns the certified upper bound on the number of disjoint hyperbolic \(r\)-balls.

Then compare against:
- greedy hyperbolic circle packings,
- known asymptotics for hyperbolic area growth,
- and sensitivity as \(\rho \to 1\).

The algorithm should expose the distinction between:
- Euclidean area,
- weighted hyperbolic area,
- exact hyperbolic disk area if available,
- and certified packing count.

This is not optional: it turns the theorem into a scientific instrument.

---

## Why this would be a breakthrough

If successful, this work opens a new formal field: **certified synthetic packing theory in curved spaces**.

That matters because it creates a machine-checked foundation for:
- hyperbolic coding and communication bounds,
- capacity estimates for hyperbolic embeddings in machine learning,
- coarse entropy bounds in negatively curved dynamics,
- sphere/ball packing analogues in geometric group theory,
- and eventually a unified constant-curvature packing calculus.

Most importantly, it upgrades “hyperbolic geometry is qualitatively different” into a **quantitative, formal, algorithmically certified theorem schema**. That is a publishable mathematical shift, not a library exercise.

---

## Build on catalog theorems

Use existing catalog theorems on:
- measure monotonicity and integration over measurable sets,
- volume of Euclidean balls,
- finite/disjoint family volume additivity,
- norm inequalities in Euclidean space,
- and any existing conformal or packing lemmas from the catalog.

Do not merely cite them; explicitly explain in comments and the paper how they are used:
- Euclidean disjoint-ball volume additivity feeds the packing count,
- norm monotonicity feeds the radial conformal bound,
- measurable integral comparison feeds the weighted-volume sandwich.

If the catalog contains prior Euclidean conformal packing bounds, your job is to **factor the proof through a reusable conformal-metric interface** and then instantiate it for the Poincaré disk. That is the right abstraction jump.

---

## Mandatory deliverables

You must produce **all** of the following:

1. **Lean file** with the new definitions and at least 3 nontrivial theorems fully proved, minimizing `sorry`.
2. **FUTURE_DIRECTIONS.md** with 3–5 testable scientific hypotheses, each falsifiable and paired with a concrete computational test.
3. **RESEARCH_PAPER.md** as a standalone scientific document explaining:
   - the theorem,
   - the corrected form of the original conjecture,
   - proof ideas,
   - computational experiments,
   - significance,
   - and next steps.
4. **ARTICLE.md** in Scientific American style, explaining why negative curvature changes packing so dramatically.
5. **A verified algorithm or computational method** for certified hyperbolic packing bounds.
6. **demo.py** that interactively:
   - visualizes the Poincaré disk,
   - lets the user vary \(r\), \(\rho\), and a domain,
   - computes weighted area and certified packing bounds,
   - and compares against sampled greedy packings.

---

## Application keywords

hyperbolic geometry, conformal metric, Poincaré disk, packing bounds, geometric analysis, metric entropy, information geometry, hyperbolic embeddings, negatively curved spaces, geometric group theory, statistical mechanics, certified algorithms, formalized mathematics, Lean 4, Mathlib, curvature interpolation, synthetic geometry, volume distortion, hierarchical representation learning

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
