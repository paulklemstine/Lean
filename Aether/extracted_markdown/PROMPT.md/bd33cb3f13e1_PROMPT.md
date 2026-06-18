## Assignment: Convex Geometry Beyond Brunn–Minkowski — Mixed Volumes, Support Duality, and a Formal Route to Isoperimetry

You are not being asked for a routine transcription of classical convexity. You are being asked to build the formal backbone for one of the deepest organizing principles in geometry: **volume behaves like a nonlinear linear functional under Minkowski addition**, and from that single fact radiate isoperimetry, mixed volumes, Alexandrov–Fenchel, concentration phenomena, PDE heuristics, and asymptotic convexity.

The target is not “some version” of Brunn–Minkowski. The target is a Lean 4 development that isolates the exact formal mechanisms by which:
1. Minkowski addition turns convex bodies into a commutative semigroup,
2. support functions linearize Minkowski addition,
3. volume along Minkowski rays becomes polynomial or at least concavity-controlled,
4. isoperimetry emerges as a first-variation shadow of Brunn–Minkowski,
5. mixed-volume inequalities begin to appear in a formally reusable way.

This would open a major bridgehead for future formalization of:
- geometric functional analysis,
- optimal transport and displacement convexity,
- asymptotic convex geometry,
- tropical and idempotent convexity,
- entropy-power analogies in information theory,
- log-concavity and Hodge-type inequalities in combinatorics.

### Mode
**prove**

## Core Vision

Classically, Brunn–Minkowski says that for measurable sets \(A,B \subset \mathbb{R}^n\),
\[
\mu(A+B)^{1/n} \ge \mu(A)^{1/n} + \mu(B)^{1/n},
\]
where \(A+B=\{a+b : a\in A, b\in B\}\).

But in formal mathematics, the true breakthrough is to package this not as an isolated inequality but as a **convex-geometric calculus**:
- support functions convert geometry into order-theoretic linear algebra,
- Minkowski addition becomes addition of support functions,
- volume inequalities become concavity statements,
- isoperimetric and Alexandrov–Fenchel-type statements become consequences of a single formal infrastructure.

Your file should therefore not merely state Brunn–Minkowski; it should introduce enough structure that later work on mixed volumes, quermassintegrals, and entropy analogues becomes inevitable.

---

## Precise Formal Targets

Work in finite-dimensional Euclidean space, ideally `E := Fin n → ℝ` or a general finite-dimensional real inner product space when feasible. If Mathlib measure-theoretic volume on arbitrary convex bodies is too heavy, first prove theorems for **compact convex boxes / finite products of intervals / centrally symmetric polytopal models**, then abstract upward. A field-opening result can still be revolutionary if the formal architecture is correct.

### New definitions you should introduce

At least one of these must be genuinely new in your file.

1. **Minkowski sum of sets**
```lean
def minkowskiSum {E : Type*} [Add E] (A B : Set E) : Set E :=
  {x | ∃ a ∈ A, ∃ b ∈ B, a + b = x}
```

2. **Convex body predicate**: a compact convex set with nonempty interior, or at least a reusable approximation.
```lean
structure ConvexBody (E : Type*) [NormedAddCommGroup E] [NormedSpace ℝ E] where
  carrier : Set E
  convex' : Convex ℝ carrier
  isCompact' : IsCompact carrier
  nonempty' : carrier.Nonempty
```
If interior is hard, use a staged development:
- `PreConvexBody`: compact + convex + nonempty,
- then later add full-dimensional hypotheses as needed.

3. **Support function**
```lean
def supportFunction (K : Set E) (u : E) : ℝ :=
  sSup ((fun x => inner ℝ u x) '' K)
```
or in `E := Fin n → ℝ` using dot products if inner-product abstraction is inconvenient.

4. **Outer parallel volume profile**
```lean
def parallelVolume (K B : Set E) (t : ℝ) : ℝ :=
  volume (K ⊕ minkowskiSMul t B)
```
where `minkowskiSMul` is scalar dilation of a set. Even if initially only for `t ≥ 0`.

5. **Formal mixed-volume shadow / first variation surrogate**
A new definition that captures the difference quotient
```lean
def firstVariationApprox (K B : Set E) (t : ℝ) : ℝ :=
  (volume (K ⊕ minkowskiSMul t B) - volume K) / t
```
for later convergence investigations. Even if you cannot yet prove existence of the limit in full generality, defining this object is valuable and nontrivial.

---

## Theorem Cluster A: Algebra of Minkowski Addition and Support Functions

These are not the final destination; they are the formal skeleton required for everything else.

### Theorem A1: support functions linearize Minkowski addition
Mathematical statement:
For nonempty compact sets \(A,B \subset E\), for every \(u\),
\[
h_{A+B}(u) = h_A(u) + h_B(u).
\]

Suggested Lean signature:
```lean
theorem supportFunction_minkowskiSum
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [FiniteDimensional ℝ E]
    (A B : Set E)
    (hA : IsCompact A) (hB : IsCompact B)
    (hneA : A.Nonempty) (hneB : B.Nonempty) :
    supportFunction (minkowskiSum A B) = fun u =>
      supportFunction A u + supportFunction B u
```
You may need extensional equality:
```lean
theorem supportFunction_minkowskiSum_pointwise ... (u : E) : ...
```

Why this matters:
This theorem is the gateway from nonlinear geometry to linear functional calculus. Once formalized, Minkowski addition becomes ordinary addition at the level of support functions, which is the correct language for mixed-volume theory and duality.

### Theorem A2: monotonicity of support functions
If \(A \subseteq B\), then \(h_A(u) \le h_B(u)\).

Suggested Lean signature:
```lean
theorem supportFunction_mono
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (A B : Set E) (hAB : A ⊆ B) (u : E) :
    supportFunction A u ≤ supportFunction B u
```

### Theorem A3: convexity encoded by support inequalities
A useful partial theorem: if `x ∈ A`, then `inner u x ≤ supportFunction A u`. This will become a reusable bound in later duality arguments.

Suggested Lean signature:
```lean
theorem le_supportFunction
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (A : Set E) (u x : E) (hx : x ∈ A) :
    inner ℝ u x ≤ supportFunction A u
```

---

## Theorem Cluster B: Brunn–Minkowski in a Formalizable Regime

You should aim for the strongest theorem Mathlib currently supports, but architect the file so that even a restricted theorem is conceptually exact.

### Primary target theorem: Brunn–Minkowski for convex bodies / boxes / measurable compact convex sets

Mathematical statement:
For nonempty compact convex measurable sets \(A,B \subset \mathbb{R}^n\),
\[
\mathrm{vol}(A+B)^{1/n} \ge \mathrm{vol}(A)^{1/n} + \mathrm{vol}(B)^{1/n}.
\]

A realistic staged Lean signature:
```lean
theorem brunn_minkowski_convexBody
    {n : ℕ} (hn : 0 < n)
    (K L : ConvexBody (Fin n → ℝ)) :
    (volume (minkowskiSum K.carrier L.carrier)) ^ (1 / (n : ℝ))
      ≥ (volume K.carrier) ^ (1 / (n : ℝ))
        + (volume L.carrier) ^ (1 / (n : ℝ))
```
If exponentiation by `1/(n:ℝ)` is awkward, use a monotone equivalent formulation:
```lean
(volume (minkowskiSum K.carrier L.carrier)) ≥
  ((volume K.carrier) ^ (1 / (n : ℝ)) + (volume L.carrier) ^ (1 / (n : ℝ))) ^ n
```
or an `ENNReal` formulation followed by coercions to `ℝ≥0∞` / `ℝ`.

If full generality is too ambitious, prove first:

### Theorem B1: Brunn–Minkowski for axis-aligned boxes
For boxes \( \prod_i [a_i,b_i]\) and \( \prod_i [c_i,d_i]\), Minkowski sum is another box and the inequality follows from product inequalities.

Suggested Lean signature:
```lean
theorem brunn_minkowski_box
    {n : ℕ} (A B : Fin n → ℝ × ℝ)
    (hA : ∀ i, (A i).1 ≤ (A i).2)
    (hB : ∀ i, (B i).1 ≤ (B i).2) :
    ...
```
This is not trivial if done correctly: it should use multi-step `calc`, product formulas, and a genuine inequality such as AM-GM / Hölder / Minkowski for vectors of side lengths.

### Theorem B2: concavity of the volume profile along Minkowski interpolation
For \(0 \le t \le 1\),
\[
\mathrm{vol}((1-t)A+tB)^{1/n}
\]
is concave in \(t\), at least in a restricted class such as boxes or homothetic bodies.

Suggested Lean signature:
```lean
theorem volume_root_concave_on_boxes
    {n : ℕ} (hn : 0 < n)
    (A B : Box n) :
    ConcaveOn ℝ (Set.Icc (0:ℝ) 1)
      (fun t => (boxVolume ((1 - t) • A + t • B)) ^ (1 / (n : ℝ)))
```
If a custom `Box n` structure is needed, that itself is a strong and useful novel definition.

Why this matters:
Formalizing even a robust special-case Brunn–Minkowski theorem creates the seed of the entire log-concavity universe in Lean: entropy power, Prékopa–Leindler analogues, concentration, and asymptotic geometric inequalities.

---

## Theorem Cluster C: Isoperimetric Inequality as a Consequence

This is where the project becomes transformative. Do not merely state isoperimetry independently; derive it from the Minkowski framework.

### Theorem C1: restricted isoperimetric inequality
For a sufficiently regular convex body \(K\subset \mathbb{R}^n\),
\[
\mathrm{Surf}(K)^n \ge n^n \omega_n \, \mathrm{vol}(K)^{n-1},
\]
with equality for Euclidean balls.

If full surface area is too difficult, prove a **formal first-variation surrogate**:
- define outer parallel volume `t ↦ vol(K + tB)`,
- prove lower bounds comparing it to the ball case,
- derive a dimensionally correct inequality for a finite-difference perimeter proxy.

Suggested Lean signature:
```lean
theorem isoperimetric_from_parallel_volume
    {n : ℕ} (hn : 0 < n)
    (K : ConvexBody (Fin n → ℝ)) :
    perimeterProxy K ^ n ≥
      ((n : ℝ) ^ n) * unitBallVolume n * (volume K.carrier) ^ (n - 1)
```
where `perimeterProxy` is your new definition built from first variation or outer parallel growth.

This is mathematically honest and formally strategic: even a proxy theorem can later be upgraded to classical surface area once geometric measure theory infrastructure improves.

Why this matters:
A formal derivation of isoperimetry from Brunn–Minkowski is a conceptual milestone, not just another inequality. It imports a central “geometry from concavity” principle into Lean.

---

## Theorem Cluster D: Alexandrov–Fenchel Shadow / Mixed-Volume Entry Point

Full Alexandrov–Fenchel may be beyond current library support, but you should still formalize a meaningful nontrivial shadow theorem that points directly toward it.

### Primary visionary target
For convex bodies \(K,L,C_3,\dots,C_n\),
\[
V(K,L,C_3,\dots,C_n)^2 \ge V(K,K,C_3,\dots,C_n)\,V(L,L,C_3,\dots,C_n).
\]

### Realistic staged theorem D1: Minkowski quadratic inequality for boxes / orthotopes
For axis-aligned boxes, define a mixed-volume surrogate via polarization of the volume polynomial and prove the Alexandrov–Fenchel inequality in this regime.

Suggested Lean signature:
```lean
def boxMixedCoeff {n : ℕ} (A B : Box n) : ℝ := ...

theorem alexandrov_fenchel_box
    {n : ℕ} (A B : Box n) :
    boxMixedCoeff A B ^ 2 ≤ boxMixedCoeff A A * boxMixedCoeff B B
```
or the inequality orientation depending on your normalization.

Alternative formulation:
show log-concavity of the coefficients of
\[
\mathrm{vol}(A + tB)
\]
for boxes. This is already deep and connects directly to Alexandrov–Fenchel/Newton inequalities.

Suggested Lean signature:
```lean
theorem box_volume_polynomial_logconcave
    {n : ℕ} (A B : Box n) :
    LogConcave (volumePolynomialCoeffs A B)
```

Why this matters:
A formally verified AF-shadow theorem would open the road to Hodge-theoretic inequalities, matroid log-concavity, and combinatorial geometry. Even a box/polytopal version is a serious breakthrough if architected correctly.

---

## Recommended Proof Strategies

You must include at least 3 theorems with real proof depth using induction, `rcases`, `by_contra`, `field_simp`, or multi-step `calc`.

### Strategy 1: Support-function linearization route
**Best for A1, A2, and as infrastructure for B/C/D.**

Steps:
1. Expand `minkowskiSum` membership with `rcases`:
   - from `x ∈ A ⊕ B`, obtain `a ∈ A`, `b ∈ B`, `a + b = x`.
2. Show pointwise upper bound:
   \[
   \langle u, x\rangle = \langle u,a\rangle + \langle u,b\rangle \le h_A(u)+h_B(u).
   \]
3. For the reverse inequality, use compactness/nonemptiness to extract approximate or exact maximizers of the continuous linear functional on compact sets; then combine them.

Why promising:
This route is structurally clean and yields reusable lemmas. It is the correct abstraction for future mixed-volume work.

### Strategy 2: Box model + induction on dimension
**Best for Brunn–Minkowski and Alexandrov–Fenchel shadows in a formalizable setting.**

Steps:
1. Define `Box n` as a product of intervals with side lengths `ℓ_i ≥ 0`.
2. Prove Minkowski sum of boxes corresponds to coordinatewise addition of side lengths.
3. Reduce volume inequalities to algebraic inequalities on products:
   \[
   \Big(\prod_i (\ell_i + m_i)\Big)^{1/n} \ge
   \Big(\prod_i \ell_i\Big)^{1/n} + \Big(\prod_i m_i\Big)^{1/n}.
   \]
4. Prove this via induction on `n`, Hölder/Minkowski-type product inequalities, or log-convexity arguments.
5. Use `field_simp` and `calc` chains to manage exponent identities carefully.

Why promising:
This avoids the heaviest measure-theoretic obstacles while still capturing the deep structure. It also gives explicit algorithms and computational tests.

### Strategy 3: Parallel-volume / finite-difference isoperimetry
**Best for deriving isoperimetric consequences without full GMT.**

Steps:
1. Define
   \[
   P_K(t)=\mathrm{vol}(K+tB).
   \]
2. Prove monotonicity and Brunn–Minkowski-type concavity for \(P_K(t)^{1/n}\).
3. Compare the finite difference quotient
   \[
   \frac{P_K(t)-P_K(0)}{t}
   \]
   to the ball model and derive a perimeter proxy inequality.
4. Use `by_contra` with the concavity inequality to show any violation would contradict the ball extremizer profile.

Why promising:
This is the most realistic route to a meaningful isoperimetric theorem in current formal infrastructure.

---

## Cross-Domain Connections You Must Exploit

At least one theorem should explicitly connect convex geometry to another domain.

### Connection 1: Information theory
Brunn–Minkowski is the geometric analogue of the entropy power inequality. Formalizing concavity of \( \mathrm{vol}^{1/n}\) lays the conceptual groundwork for a future Lean proof of EPI.

Possible theorem statement in your paper/discussion:
- “For boxes, the logarithm of volume under Minkowski interpolation behaves like Shannon entropy under convolution.”
Even if not fully formalized, explicitly state and test this analogy.

### Connection 2: Tropical geometry / idempotent analysis
Support functions convert convex bodies into max-plus linear data:
\[
h_{A+B} = h_A + h_B,
\]
which is classical linearity in ordinary arithmetic but also the gateway to tropical convexity and Newton polytopes.

Build on catalog inequality patterns such as:
- `tropical_product_sum_inequality`
to motivate product/sum inequalities for box side lengths or support-function envelopes.
Do not force a fake dependency, but explicitly connect the algebraic pattern:
- Minkowski sum of polytopes ↔ addition of support functions,
- Newton polytope of a product ↔ Minkowski sum,
- tropicalization converts multiplicative algebra into polyhedral geometry.

### Connection 3: Discrete/combinatorial geometry
A box-version Alexandrov–Fenchel shadow directly resembles log-concavity of coefficient sequences, with downstream relevance to matroids and Hodge theory. Connect your coefficient inequalities to combinatorial log-concavity.

### Application keywords
Use these explicitly in the deliverables:
**Brunn–Minkowski, isoperimetric inequality, mixed volumes, support functions, convex bodies, log-concavity, Alexandrov–Fenchel, entropy power inequality, tropical geometry, Newton polytopes, geometric functional analysis, optimal transport, Hodge inequalities**

---

## Suggested Lean 4 Theorem Signatures

These are targets; adjust to actual Mathlib APIs, but stay mathematically precise.

```lean
def minkowskiSum {E : Type*} [Add E] (A B : Set E) : Set E :=
  {x | ∃ a ∈ A, ∃ b ∈ B, a + b = x}

structure ConvexBody (E : Type*) [NormedAddCommGroup E] [NormedSpace ℝ E] where
  carrier : Set E
  convex' : Convex ℝ carrier
  isCompact' : IsCompact carrier
  nonempty' : carrier.Nonempty

def supportFunction
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (K : Set E) (u : E) : ℝ :=
  sSup ((fun x => inner ℝ u x) '' K)

theorem supportFunction_mono
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (A B : Set E) (hAB : A ⊆ B) (u : E) :
    supportFunction A u ≤ supportFunction B u := by
  ...

theorem le_supportFunction
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (A : Set E) (u x : E) (hx : x ∈ A) :
    inner ℝ u x ≤ supportFunction A u := by
  ...

theorem supportFunction_minkowskiSum_pointwise
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [FiniteDimensional ℝ E]
    (A B : Set E)
    (hA : IsCompact A) (hB : IsCompact B)
    (hneA : A.Nonempty) (hneB : B.Nonempty)
    (u : E) :
    supportFunction (minkowskiSum A B) u
      = supportFunction A u + supportFunction B u := by
  ...

structure Box (n : ℕ) where
  lo : Fin n → ℝ
  hi : Fin n → ℝ
  hle : ∀ i, lo i ≤ hi i

def boxVolume {n : ℕ} (B : Box n) : ℝ :=
  ∏ i, (B.hi i - B.lo i)

def boxMinkowskiSum {n : ℕ} (A B : Box n) : Box n := ...

theorem boxVolume_minkowskiSum
    {n : ℕ} (A B : Box n) :
    boxVolume (boxMinkowskiSum A B)
      = ∏ i, ((A.hi i - A.lo i) + (B.hi i - B.lo i)) := by
  ...

theorem brunn_minkowski_box
    {n : ℕ} (hn : 0 < n) (A B : Box n) :
    (boxVolume (boxMinkowskiSum A B)) ^ (1 / (n : ℝ))
      ≥ (boxVolume A) ^ (1 / (n : ℝ)) + (boxVolume B) ^ (1 / (n : ℝ)) := by
  ...

def perimeterProxy {n : ℕ} (K : ConvexBody (Fin n → ℝ)) : ℝ := ...

theorem isoperimetric_from_parallel_volume
    {n : ℕ} (hn : 0 < n)
    (K : ConvexBody (Fin n → ℝ)) :
    perimeterProxy K ^ n ≥
      ((n : ℝ) ^ n) * unitBallVolume n * (volume K.carrier) ^ (n - 1) := by
  ...
```

If the exact measure-theoretic volume API is too unstable, it is acceptable to define and prove everything first for `Box n` and `Parallelotope n`, then state a precise conjectural extension to `ConvexBody`.

---

## How to Use Existing Verified Theorems

The catalog entries listed are not directly convex-geometric, but you should still exploit their **proof patterns** and inequality engineering style.

1. `strong_algebraic_inequality`
   - Use this as a model for building robust multistep algebraic inequalities in your box-volume arguments.
   - Especially relevant when proving product inequalities from coordinatewise expansions.

2. `tropical_product_sum_inequality`
   - This is conceptually aligned with the algebra of side lengths and support functions.
   - Use it as a bridge theorem in your narrative: tropical/product-sum inequalities are shadows of convex-geometric addition laws.
   - If adaptable, use it to control side-length product expansions in the box Brunn–Minkowski proof.

3. Sum-of-squares theorems in geometry files
   - Mine them for `ring_nf`, positivity, and structured `calc` techniques.
   - These can help when proving nonnegativity of polynomial coefficients in `vol(A + tB)` for boxes.

Do not cite them decoratively; either import their proof patterns or explain precisely in `RESEARCH_PAPER.md` how their inequality architecture informed your convex proof.

---

## Minimum Deep Theorem Requirements

Your Lean development must contain **at least 3 substantial theorems**, and at least 3 proofs should use serious tactics such as:
- `induction` on dimension or finite index sets,
- `rcases` for Minkowski membership decompositions,
- `by_contra` in a concavity or extremality argument,
- `field_simp` for exponent/rational-function cleanup,
- multi-step `calc` chains.

Recommended three flagship proofs:
1. `supportFunction_minkowskiSum_pointwise`
2. `brunn_minkowski_box`
3. `isoperimetric_from_parallel_volume` or `box_volume_polynomial_logconcave`

---

## Falsifiable Conjecture with Computational Test

You must state at least one explicit conjecture and provide a computational disproof test.

### Conjecture 1: Log-concavity of discretized mixed coefficients for random boxes
For random boxes \(A,B\subset \mathbb{R}^n\), if
\[
\mathrm{vol}(A+tB)=\sum_{k=0}^n c_k t^k,
\]
then the coefficient sequence `(c_k)` is log-concave:
\[
c_k^2 \ge c_{k-1}c_{k+1}.
\]

Computational test:
- generate random positive side lengths for boxes in dimensions `n = 2,3,4,5`,
- compute the exact polynomial coefficients,
- search for violations of log-concavity.

This is falsifiable: one counterexample disproves it for your chosen normalization.

### Conjecture 2: Perimeter proxy is minimized by Euclidean-symmetric boxes at fixed volume
For axis-aligned boxes with fixed volume, your finite-difference `perimeterProxyBox` is minimized by the cube.

Computational test:
- sample side-length vectors with fixed product,
- evaluate the proxy,
- test whether the cube is always minimal.

This gives an immediate experimental geometry program.

---

## Required Deliverables

You must produce **all** of the following:

1. **Lean file(s)** with theorems, minimizing `sorry` and prioritizing deep proofs over breadth.

2. **FUTURE_DIRECTIONS.md**
   Include **3–5 testable scientific hypotheses**, each a falsifiable conjecture with:
   - exact mathematical statement,
   - why it should be true,
   - explicit computational or formal test that could fail.

3. **RESEARCH_PAPER.md**
   A standalone scientific paper that explains:
   - the formal objects introduced,
   - exact theorem statements,
   - proof architecture,
   - why this is a breakthrough,
   - what mixed-volume / isoperimetric / information-theoretic directions it opens next.
   Someone reading only this file must understand the discovery.

4. **ARTICLE.md**
   Scientific American style:
   - what Brunn–Minkowski means intuitively,
   - why “adding shapes makes volume behave concavely,”
   - why this matters for geometry, data, physics, and information.

5. **Verified algorithm or computational method**
   At minimum, one of:
   - algorithm computing Minkowski sum and support function of boxes/polytopes,
   - algorithm extracting coefficients of `vol(A + tB)` for boxes,
   - algorithm testing log-concavity / Brunn–Minkowski numerically with certified exact arithmetic where possible.

6. **demo.py**
   Interactive demonstration that:
   - samples boxes or planar convex polygons,
   - computes Minkowski sums,
   - plots volume growth under interpolation,
   - numerically illustrates Brunn–Minkowski and your conjecture tests.

---

## Final Challenge

Do not settle for “I formalized a definition and one inequality.” The real target is to establish a **formal convex-geometric engine**:
- support functions as linearizers,
- Minkowski addition as geometry-level addition,
- volume-root concavity as the master principle,
- isoperimetry as a derived phenomenon,
- Alexandrov–Fenchel as the horizon.

If you execute this well, you will not just formalize a theorem. You will create the first reusable Lean infrastructure for a vast region of high-dimensional geometry and its bridges to information theory, tropical mathematics, and combinatorial Hodge theory.

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

Research domain: Geometry
Research mode: prove
