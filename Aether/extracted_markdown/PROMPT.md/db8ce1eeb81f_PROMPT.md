## Assignment: Stereographic Capacity Theory: Packing Bounds on Spheres via Plane Geometry

**Mode:** `prove`

Aristotle, this direction is far more than a repackaging of spherical codes. The real opportunity is to create a **formal bridge principle**: stereographic projection converts hard packing questions on curved manifolds into weighted Euclidean exclusion problems with explicit distortion control. If executed correctly, this becomes a prototype for a new formal theory of **conformal capacity bounds**: curvature-controlled packing estimates obtained by transporting metric separation through conformal charts.

Your task is to prove genuinely new theorems, not merely restate classical folklore. The decisive breakthrough is to formalize an **explicit distortion calculus** for stereographic projection and use it to derive certified upper bounds on spherical packing numbers from planar or Euclidean area/volume arguments.

Build on catalog theorems about Euclidean balls, measure/volume monotonicity, metric separation, and any vetted geometry files on spheres, inner product spaces, and conformal maps. If exact stereographic machinery is missing in Mathlib, define the needed objects yourself in a mathematically clean way and prove the distortion lemmas directly.

Minimize sorry.

---

## Core Vision

Let `S^n` be the unit sphere in `ℝ^{n+1}`. For `r > 0`, define the **spherical packing number**
\[
N(n,r) := \max\{ |C| : C \subset S^n,\ \forall x\neq y\in C,\ d_{S^n}(x,y)\ge 2r\}.
\]
Equivalently, this is the maximal number of pairwise interior-disjoint geodesic caps of radius `r`.

The proposed breakthrough is to show that stereographic projection from the north pole transforms such a configuration into a Euclidean configuration with a **point-dependent exclusion radius**, governed by the conformal factor
\[
\lambda(x)=\frac{2}{1+\|x\|^2}.
\]
This should yield rigorous packing inequalities of the form
\[
N(n,r)\le D(n,r)\,\frac{\operatorname{vol}(S^n)}{\operatorname{capVol}(n,r)},
\]
with an explicit distortion multiplier `D(n,r)`, and in dimension `2` a sharpened planar theorem derived from area estimates.

The revolutionary significance is that this opens a new field-level program:

- **Spherical coding via conformal transport**
- **Curvature-aware packing certification**
- **Formal geometric inequalities on manifolds via Euclidean reduction**
- **Applications to coding theory, molecular geometry, and directional statistics**

---

## Precise Theorem Targets

You must formalize at least one new definition and prove at least 3 substantial theorems. The following are the exact theorem targets I want you to pursue.

### New definitions to introduce

1. **Stereographic conformal factor**
   ```lean
   def stereoFactor {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) : ℝ :=
     2 / (1 + ‖x‖^2)
   ```

2. **Weighted Euclidean exclusion radius induced by spherical radius**
   ```lean
   def stereoExclusionRadius {n : ℕ} (r : ℝ) (x : EuclideanSpace ℝ (Fin n)) : ℝ :=
     (Real.tan (r / 2)) / stereoFactor x
   ```
   or a comparable formula depending on the exact normalization you prove.

3. **Stereographic packing admissibility**
   ```lean
   def StereoSeparated {n : ℕ}
     (r : ℝ) (s : Finset (EuclideanSpace ℝ (Fin n))) : Prop :=
     ∀ ⦃x y⦄, x ∈ s → y ∈ s → x ≠ y →
       stereoExclusionRadius r x + stereoExclusionRadius r y ≤ ‖x - y‖
   ```

4. **Spherical packing number as a supremal finite cardinality**
   If a direct `Nat`-valued max is awkward, define a bounded predicate and prove upper bounds abstractly:
   ```lean
   def SphericalPackingBound (n : ℕ) (r B : ℝ) : Prop :=
     ∀ s : Finset (Sphere (0 : EuclideanSpace ℝ (Fin (n+1))) 1),
       (∀ ⦃x y⦄, x ∈ s → y ∈ s → x ≠ y →
         2 * r ≤ dist x y) →
       s.card ≤ ⌈B⌉₊
   ```

You may refine these signatures to match existing Mathlib sphere types, but the mathematical content must remain.

---

## Main theorem statement with Lean 4 target signature

### Theorem 1: Distortion-controlled separation under stereographic projection
This is the foundational theorem. It should explicitly quantify how spherical separation implies Euclidean weighted separation.

Mathematical statement:
For points `p,q ∈ S^n \ {N}` with geodesic distance at least `2r`, their stereographic images `x,y ∈ ℝ^n` satisfy
\[
\|x-y\| \ge \tan(r/2)\left(\frac{1}{\lambda(x)}+\frac{1}{\lambda(y)}\right),
\]
or another equivalent explicit inequality derived from the exact chordal/stereographic formula.

Lean target:
```lean
theorem stereographic_separation_lower_bound
  {n : ℕ} {r : ℝ}
  (hr : 0 < r) (hrπ : r < Real.pi / 2)
  {p q : Sphere (0 : EuclideanSpace ℝ (Fin (n+1))) 1}
  (hpq : 2 * r ≤ sphericalDist p q) :
  let x := stereographicProj p
  let y := stereographicProj q
  stereoExclusionRadius r x + stereoExclusionRadius r y ≤ ‖x - y‖
```

This is the theorem that makes the entire program real.

---

### Theorem 2: Area/volume packing bound via stereographic transport
Mathematical statement:
If a finite set of spherical cap centers of radius `r` is pairwise `2r`-separated, then after stereographic projection the corresponding Euclidean exclusion regions are disjoint; summing their weighted volumes gives
\[
|C| \cdot \inf_x \operatorname{vol}(B(x,\rho_x))
\le \sum_{x\in C} \operatorname{vol}(B(x,\rho_x))
\le \text{transported total measure},
\]
which yields an explicit upper bound of the form
\[
|C| \le D(n,r)\,\frac{\operatorname{vol}(S^n)}{\operatorname{capVol}(n,r)}.
\]

Lean target:
```lean
theorem spherical_packing_card_le_stereo_volume_bound
  {n : ℕ} {r D : ℝ}
  (hr : 0 < r) (hD : 0 ≤ D)
  (hdistortion :
    ∀ x : EuclideanSpace ℝ (Fin n),
      1 / stereoFactor x ^ n ≤ D)
  (s : Finset (Sphere (0 : EuclideanSpace ℝ (Fin (n+1))) 1))
  (hsep : ∀ ⦃x y⦄, x ∈ s → y ∈ s → x ≠ y → 2 * r ≤ sphericalDist x y) :
  (s.card : ℝ) ≤ D * sphereVolume n / sphericalCapVolume n r
```

You may need to replace the global distortion assumption by a localized one over the image of the packing. That is mathematically acceptable and probably more accurate.

---

### Theorem 3: Dimension-2 explicit bound
This is the theorem most likely to be fully executable in current Mathlib.

Mathematical statement:
For `n = 2`,
\[
N(2,r)\le \left(\frac{2}{\cos r}\right)^2 \frac{4\pi}{\operatorname{capArea}(r)}
\]
for all `0 < r < π/2`, where `capArea(r)=2\pi(1-\cos r)` on the unit sphere.

Simplifying:
\[
N(2,r)\le \frac{4}{\cos^2 r}\cdot \frac{4\pi}{2\pi(1-\cos r)}
= \frac{8}{\cos^2 r(1-\cos r)}.
\]

Lean target:
```lean
theorem packing_bound_S2
  {r : ℝ}
  (hr : 0 < r) (hrπ : r < Real.pi / 2) :
  SphericalPackingBound 2 r
    (((2 / Real.cos r)^2) * (sphereArea 2 / sphericalCapArea r))
```

If exact `sphereArea 2 = 4 * Real.pi` and `sphericalCapArea r = 2 * Real.pi * (1 - Real.cos r)` are available or can be established, derive the closed form:

```lean
theorem packing_bound_S2_closed_form
  {r : ℝ}
  (hr : 0 < r) (hrπ : r < Real.pi / 2) :
  SphericalPackingBound 2 r (8 / (Real.cos r)^2 / (1 - Real.cos r))
```

---

### Theorem 4: Verification against classical configurations
Do not merely cite folklore; prove the **bound is consistent** with known optimal configurations.

Mathematical statements:
- At `r = π/6`, the bound is at least `12`.
- At `r = π/4`, the bound is at least `6`.
- At `r = π/3`, the bound is at least `4`.

This is not the same as proving optimality. It is a formal calibration theorem.

Lean target:
```lean
theorem packing_bound_S2_pi_over_6_calibration :
  12 ≤ ((2 / Real.cos (Real.pi / 6))^2) *
       (sphereArea 2 / sphericalCapArea (Real.pi / 6))

theorem packing_bound_S2_pi_over_4_calibration :
  6 ≤ ((2 / Real.cos (Real.pi / 4))^2) *
      (sphereArea 2 / sphericalCapArea (Real.pi / 4))

theorem packing_bound_S2_pi_over_3_calibration :
  4 ≤ ((2 / Real.cos (Real.pi / 3))^2) *
      (sphereArea 2 / sphericalCapArea (Real.pi / 3))
```

These should require real trigonometric simplification and inequality reasoning, not trivial automation.

---

## Stronger conjectural target

The truly exciting statement is asymptotic and should be included as a conjecture with computational tests.

### Conjecture: Second-order stereographic asymptotic for spherical packing
For fixed dimension `n`,
\[
N(n,r)\le \left(1 + C_n r^2 + o(r^2)\right)\frac{\operatorname{vol}(S^n)}{\operatorname{capVol}(n,r)}
\quad\text{as } r\to 0,
\]
where `C_n` is explicitly computable from the quadratic term in the stereographic conformal distortion.

A more testable finite-radius version:
\[
N(n,r)\le \Bigl(\sup_{\|x\|\le \tan(r/2)} (1+\|x\|^2)^n / 2^n \Bigr)\,
\frac{\operatorname{vol}(S^n)}{\operatorname{capVol}(n,r)}.
\]

Lean-style conjecture declaration:
```lean
conjecture stereographic_packing_asymptotic
  (n : ℕ) :
  ∃ C : ℝ, ∀ᶠ r in nhdsWithin (0 : ℝ) (Set.Ioi 0),
    packingNumber n r ≤
      (1 + C * r^2) * sphereVolume n / sphericalCapVolume n r
```

### Clear computational falsification test
For each fixed `n ∈ {2,3,4}` and a grid of radii `r_k → 0`, compute:
\[
Q_{n}(r_k)=\frac{N_{\mathrm{known/lower}}(n,r_k)\,\operatorname{capVol}(n,r_k)}{\operatorname{vol}(S^n)}.
\]
If `Q_n(r_k)` exceeds `1 + C r_k^2` for every plausible `C` extracted from the distortion model, the conjecture is false. Your `demo.py` must implement this test numerically for `n=2`, comparing against known spherical code tables where available.

---

## Proof strategy architecture

You must present and pursue at least 2–3 proof strategies. Here are the main routes.

### Strategy A: Direct conformal-metric transport
Most promising.

1. Define stereographic projection and prove the pullback metric is conformal:
   \[
   ds^2_{S^n} = \lambda(x)^2 ds^2_{\mathbb R^n},\qquad \lambda(x)=\frac{2}{1+\|x\|^2}.
   \]
   In Lean, this may be encoded not as a full Riemannian tensor identity, but as a concrete distance comparison lemma on sufficiently small radial sets.

2. Show that a spherical cap of geodesic radius `r` centered at `p` maps to a Euclidean ball centered at `stereographicProj p` with radius controlled above and below by explicit functions of `r` and `‖x‖`.

3. Use pairwise cap disjointness to deduce Euclidean disjointness of weighted balls, then sum Euclidean volumes and compare to the transported area/volume measure.

**Why this is most promising:** it avoids needing a complete formal Riemannian manifold framework and reduces the geometry to explicit algebraic identities in `ℝ^n`.

---

### Strategy B: Chordal-distance intermediary
Potentially easier for Lean.

1. Replace geodesic separation `d_S(p,q) ≥ 2r` by a chordal inequality:
   \[
   \|p-q\| \ge 2\sin r.
   \]

2. Use the explicit stereographic formula relating chordal distance on the sphere to Euclidean distance in the plane:
   \[
   \|p-q\|
   = \frac{2\|x-y\|}{\sqrt{(1+\|x\|^2)(1+\|y\|^2)}}.
   \]

3. Rearrange to obtain
   \[
   \|x-y\|
   \ge \sin r \cdot \frac{\sqrt{(1+\|x\|^2)(1+\|y\|^2)}}{1}
   \]
   and then use AM-GM or similar inequalities to derive additive exclusion radii.

**Why promising:** this route replaces differential geometry with pure Euclidean algebra plus trig identities. It is especially suitable for theorem proving with `field_simp`, `nlinarith`, and `calc`.

---

### Strategy C: Möbius-energy / potential-theoretic reformulation
High-risk, high-payoff.

1. Interpret pairwise spherical separation as a lower bound on a repulsive energy kernel.
2. Transport the kernel through stereographic projection into a weighted Riesz-type energy on `ℝ^n`.
3. Derive cardinality bounds from energy inequalities or mass-distribution principles.

**Why this matters:** if successful, it opens a pathway from spherical packings to **potential theory, coding bounds, and statistical mechanics**. Even a partial theorem here would be paradigm-shifting.

---

## Cross-domain connections you must explicitly exploit

At least one theorem must connect this project to another mathematical domain.

### 1. Coding theory
A spherical code is exactly a finite subset of `S^n` with prescribed angular separation. Your packing bounds therefore imply upper bounds on code size for real projective or spherical communication channels.

Possible theorem:
```lean
theorem code_size_le_stereographic_bound
  {n : ℕ} {θ : ℝ} :
  codeSize n θ ≤ ((2 / Real.cos (θ / 2))^n) * sphereVolume n / sphericalCapVolume n (θ / 2)
```

**Application keywords:** spherical codes, angular separation, communication complexity, signal constellations.

### 2. Conformal geometry / mathematical physics
The factor `(1 + ‖x‖^2)^2 / 4` is the same conformal weight appearing in compactification of Euclidean space and in 2D conformal field theory. A theorem relating packing density distortion to this factor creates a formal bridge to **curvature renormalization** ideas.

Possible conceptual theorem:
```lean
theorem stereographic_density_transformation
  {n : ℕ} :
  transportedDensity n = fun x => (stereoFactor x) ^ n
```

**Application keywords:** conformal compactification, geometric analysis, CFT, curvature distortion.

### 3. Discrete geometry + numerical certification
The explicit bound is algorithmic: given `r`, compute a certified upper bound on packing number. This is exactly the sort of theorem that can drive a verified scientific computation pipeline.

**Application keywords:** certified numerics, discrete geometry, optimization, molecular geometry.

---

## Recommended supporting lemmas

These are likely necessary and should be proved as standalone reusable results.

```lean
theorem stereoFactor_pos {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) :
  0 < stereoFactor x
```

```lean
theorem stereoFactor_le_two {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) :
  stereoFactor x ≤ 2
```

```lean
theorem stereographic_chord_formula
  {n : ℕ} {p q : Sphere (0 : EuclideanSpace ℝ (Fin (n+1))) 1} :
  let x := stereographicProj p
  let y := stereographicProj q
  ‖((p : EuclideanSpace ℝ (Fin (n+1))) - q)‖
    = (2 * ‖x - y‖) /
      Real.sqrt ((1 + ‖x‖^2) * (1 + ‖y‖^2))
```

```lean
theorem geodesic_to_chord_lower_bound
  {n : ℕ} {p q : Sphere (0 : EuclideanSpace ℝ (Fin (n+1))) 1} {r : ℝ}
  (h : 2 * r ≤ sphericalDist p q) :
  2 * Real.sin r ≤ ‖((p : EuclideanSpace ℝ (Fin (n+1))) - q)‖
```

```lean
theorem cap_area_S2
  {r : ℝ} :
  sphericalCapArea r = 2 * Real.pi * (1 - Real.cos r)
```

Each of these should require nontrivial algebraic and trigonometric reasoning.

---

## Lean 4 implementation expectations

You must provide exact formal objects, not handwaving. If full manifold support is cumbersome, work with explicit coordinate formulas.

Suggested file organization:
- `StereographicCapacity/Definitions.lean`
- `StereographicCapacity/Distortion.lean`
- `StereographicCapacity/PackingBoundS2.lean`
- `StereographicCapacity/CodingConnection.lean`

Use:
- `field_simp` for rational identities in the stereographic formulas
- `ring_nf` / `nlinarith` for norm-square inequalities
- `by_contra` for disjointness/packing contradiction arguments
- `rcases` for unpacking separation hypotheses and finite-set membership
- multi-step `calc` chains for trig/measure inequalities

Avoid a theorem if it collapses to a one-line computation.

---

## Deliverables you must produce

You must produce **all** of the following:

1. **Lean formalization** with at least 3 substantial theorems and at least 1 novel definition.
2. **A verified algorithm or computational method**:
   - Given `n` and `r`, compute the stereographic upper bound
   - In dimension `2`, evaluate the closed-form bound numerically
   - Include correctness statements connecting the algorithm output to the formal theorem
3. **`demo.py`**:
   - Interactive input of `r`
   - Computes the `S^2` upper bound
   - Compares against calibration values `π/6`, `π/4`, `π/3`
   - Optionally plots the bound as a function of `r`
4. **`FUTURE_DIRECTIONS.md`** with 3–5 falsifiable hypotheses
5. **`RESEARCH_PAPER.md`** as a standalone scientific paper
6. **`ARTICLE.md`** in Scientific American style

---

## Required falsifiable hypotheses for FUTURE_DIRECTIONS.md

Include 3–5 hypotheses like the following.

1. **Second-order asymptotic sharpness hypothesis**  
   For fixed `n`, the stereographic distortion bound is asymptotically sharp up to `O(r^2)` as `r → 0`.  
   **Test:** numerically compare bound/value ratios using known spherical code data for small `r`.

2. **Dimension-2 constant improvement hypothesis**  
   The factor `(2 / cos r)^2` is not optimal on `S^2`; it can be replaced by a smaller explicit radial average distortion factor.  
   **Test:** compute the exact maximal Jacobian distortion over images of caps centered at various latitudes.

3. **Weighted planar packing equivalence hypothesis**  
   Every `S^2` cap packing corresponds to a planar weighted disk packing whose maximal cardinality gives the same upper bound.  
   **Test:** brute-force small-cardinality optimization in the plane with the induced radius law.

4. **Coding-theoretic transfer hypothesis**  
   The stereographic bound improves elementary upper bounds for certain ranges of angular separation in spherical coding.  
   **Test:** compare numerically against naive volume bounds and Rankin-type estimates.

5. **Curvature-generalization hypothesis**  
   An analogous conformal packing bound exists for any manifold admitting a conformal chart with bounded distortion.  
   **Test:** implement the argument on the hyperbolic disk or the Riemann sphere with alternate charts.

---

## What would make this a breakthrough

If you succeed, you will have created a formally verified framework showing that **packing on curved spaces can be bounded by transporting geometry into flat space with explicit distortion accounting**. That is not an incremental lemma; it is a reusable scientific machine. It opens:

- certified upper bounds for spherical codes,
- formally verified geometric inequalities in applied signal design,
- a new interface between conformal geometry and discrete optimization,
- a pathway toward packing bounds on more general manifolds.

This is exactly the kind of result that makes a mathematician say: *I did not expect stereographic projection to become a theorem-proving engine for sphere packings.*

**Application keywords:** sphere packing, spherical codes, stereographic projection, conformal geometry, cap packing, coding theory, discrete geometry, certified numerics, geometric analysis, signal processing, molecular geometry, angular codes.

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

Research domain: Geometry
Research mode: prove
