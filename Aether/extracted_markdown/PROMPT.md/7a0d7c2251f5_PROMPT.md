Soli Deo Gloria

## Assignment: Direction 1 — Submodular Objectives and the Curvature-Gap Conjecture

**Mode:** `prove`

You should not treat this as a modest extension of weighted threshold rounding. The real target is to open a **formal theory of curvature-sensitive rounding for nonlinear objectives**. The existing catalog controls threshold rounding for **linear costs on hypergraphs**. Your mission is to prove that this linear theory is the visible boundary of a deeper phenomenon: **submodularity plus bounded curvature converts nonlinear objective distortion into a controlled linear surrogate loss**.

This is potentially field-opening because it would create a verified bridge between:

- combinatorial optimization on hypergraphs,
- multilinear relaxations of submodular maximization/minimization,
- approximation guarantees parameterized by **curvature**,
- and algorithmic domains like feature selection, welfare optimization, and influence maximization.

If successful, this would elevate the catalog from “rounding preserves feasibility and linear cost up to factor `d`” to “rounding preserves a broad nonlinear objective class up to factor `d/(1-κ)`,” which is exactly the kind of theorem that changes what one can formalize next.

---

## Core theorem target

Let `V` be a finite ground type, `E` a finite index type for hyperedges, and `Inc : E → Finset V` a hypergraph with maximum edge size `d`. Let `x : V → ℝ` be a fractional point in `[0,1]^V`, and let `Sτ := {v | τ ≤ x v}` be the threshold-rounded set at threshold `τ ∈ [0,1]`. Let `f : Finset V → ℝ` be monotone submodular and normalized (`f ∅ = 0`). Let `F(x)` denote the multilinear extension:
\[
F(x) = \mathbb E[f(R_x)],
\]
where each element `v` is included independently with probability `x v`.

Define the total curvature of `f` by
\[
\kappa(f) := 1 - \min_{v \in V} \frac{f(V)-f(V\setminus\{v\})}{f(\{v\})}
\]
when all singleton gains are positive, and otherwise use the natural restricted version over nonzero singleton gains.

### Breakthrough theorem statement

**Theorem (Curvature-gap threshold bound).**  
Assume:

1. `H := (V,E,Inc)` has maximum edge size at most `d`,
2. `x` is a feasible fractional transversal solution,
3. `S := thresholdSet x` is the threshold-rounded transversal from the catalog construction,
4. `f` is normalized, monotone, submodular,
5. `f` has curvature `κ < 1`.

Then:
\[
f(S) \le \frac{d}{1-\kappa}\,F(x).
\]

This is the exact conjectural statement you should aim to formalize first in a mathematically robust variant. If the full statement is too ambitious initially, prove the strongest certified version you can, but orient everything toward this theorem.

---

## Lean 4 formalization target

You should introduce a new concept expressing curvature-controlled domination by modular weights.

A promising formal target is:

```lean
def IsMonotoneSubmodular
    {V : Type _} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ) : Prop :=
  (∀ A B : Finset V, A ⊆ B → f A ≤ f B) ∧
  (∀ A B : Finset V, f A + f B ≥ f (A ∪ B) + f (A ∩ B))

def singletonWeight
    {V : Type _} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ) (v : V) : ℝ :=
  f ({v})

def totalCurvatureBound
    {V : Type _} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ) (κ : ℝ) : Prop :=
  ∀ v : V, 0 < singletonWeight f v →
    (1 - κ) * singletonWeight f v ≤
      f (Finset.univ) - f (Finset.univ.erase v)

def modularUpperSurrogate
    {V : Type _} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ) (κ : ℝ) (A : Finset V) : ℝ :=
  (1 / (1 - κ)) * ∑ v in A, singletonWeight f v

def multilinearExtension
    {V : Type _} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ) (x : V → ℝ) : ℝ := sorry
```

Then target the theorem:

```lean
theorem threshold_submodular_curvature_gap_bound
    {V E : Type _} [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    (Inc : E → Finset V)
    (d : ℕ)
    (hd : ∀ e : E, (Inc e).card ≤ d)
    (x : V → ℝ)
    (hx0 : ∀ v, 0 ≤ x v)
    (hx1 : ∀ v, x v ≤ 1)
    (htrans : fractionalTransversal Inc x)
    (f : Finset V → ℝ)
    (hsub : IsMonotoneSubmodular f)
    (hnorm : f ∅ = 0)
    (κ : ℝ)
    (hk0 : 0 ≤ κ)
    (hk1 : κ < 1)
    (hcurv : totalCurvatureBound f κ) :
    f (thresholdSet x) ≤
      (d : ℝ) / (1 - κ) * multilinearExtension f x := by
  sorry
```

If the full `multilinearExtension` is too difficult to define measure-theoretically in the first pass, prove a finitistic sampled version first using finite support over `Finset V → ℝ`:

```lean
def bernoulliProductMass
    {V : Type _} [Fintype V] [DecidableEq V]
    (x : V → ℝ) (A : Finset V) : ℝ :=
  ∏ v in A, x v * ∏ v in Aᶜ, (1 - x v)

def finiteMultilinearExtension
    {V : Type _} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ) (x : V → ℝ) : ℝ :=
  ∑ A in Finset.powerset Finset.univ, bernoulliProductMass x A * f A
```

and prove the corresponding theorem with `finiteMultilinearExtension`. This may actually be the better first formal object.

---

## New definitions you should introduce

At least one new concept must be added beyond what is already in the catalog. I recommend introducing **all three** of the following, because together they create a reusable mini-theory.

### 1. Curvature-controlled modular domination
A submodular function with curvature `κ` is pointwise dominated by a modular function scaled by `1/(1-κ)`:
\[
f(A) \le \frac{1}{1-\kappa}\sum_{v\in A} f(\{v\}).
\]
Formalize this as a structure or predicate, and then prove it from monotonicity + submodularity + curvature.

Suggested signature:

```lean
def HasCurvatureModularUpperBound
    {V : Type _} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ) (κ : ℝ) : Prop :=
  ∀ A : Finset V,
    f A ≤ (1 / (1 - κ)) * ∑ v in A, f ({v})
```

### 2. Finite multilinear extension
A finite combinatorial definition, avoiding analytic overhead.

### 3. Threshold profile of a fractional solution
A formal object connecting threshold rounding and expected indicator behavior:
```lean
def thresholdSet
    {V : Type _} [Fintype V] [DecidableEq V]
    (x : V → ℝ) : Finset V := sorry
```
If the catalog already contains this exact object, reuse it; otherwise define a compatible wrapper.

---

## Theorems you should prove

You are required to prove at least 3 substantial theorems with nontrivial proof structure. The following package is mathematically coherent and strong.

### Theorem 1: Curvature implies modular domination
This is the conceptual heart.

```lean
theorem submodular_le_modular_of_curvature
    {V : Type _} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ) (κ : ℝ)
    (hsub : IsMonotoneSubmodular f)
    (hnorm : f ∅ = 0)
    (hk0 : 0 ≤ κ) (hk1 : κ < 1)
    (hcurv : totalCurvatureBound f κ) :
    ∀ A : Finset V,
      f A ≤ (1 / (1 - κ)) * ∑ v in A, f ({v}) := by
  sorry
```

**Mathematical content.** This theorem converts a nonlinear submodular objective into a linear surrogate with explicit distortion depending only on curvature. It is the formal lever that lets you import the catalog’s linear threshold bounds.

**Likely proof ingredients.**
- Induction on `A.card`.
- Decompose `A = insert v B`.
- Use submodularity as diminishing marginal returns:
  \[
  f(B \cup \{v\}) - f(B) \le f(\{v\}),
  \]
  then strengthen via curvature to recover the `1/(1-κ)` factor.
- Multi-step `calc` with careful singleton-gain estimates.
- You may need a lemma comparing marginal values on `B` and on `V \setminus {v}`.

This theorem should absolutely not be trivial; it should require induction, `rcases` on insertions into finite sets, and several inequality manipulations.

---

### Theorem 2: Multilinear extension is bounded by the same modular surrogate
This theorem is where the nonlinear expectation becomes compatible with catalog weighted bounds.

```lean
theorem multilinearExtension_le_modular_expectation
    {V : Type _} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ) (x : V → ℝ)
    (hx0 : ∀ v, 0 ≤ x v) (hx1 : ∀ v, x v ≤ 1)
    (κ : ℝ)
    (hmod : HasCurvatureModularUpperBound f κ) :
    finiteMultilinearExtension f x ≤
      (1 / (1 - κ)) * ∑ v in Finset.univ, x v * f ({v}) := by
  sorry
```

You should also attempt the reverse lower bound under monotonicity/submodularity:
\[
(1-\kappa)\sum_v x_v f(\{v\}) \le F(x),
\]
if it is actually true in your formal setting; if not, formulate a weaker certified lower bound. The point is to pin `F(x)` between modular expressions.

**Why it matters.** This theorem identifies the multilinear extension as the correct nonlinear quantity to compare against the threshold-rounded set. It is the bridge between stochastic fractional optimization and deterministic threshold output.

**Proof style.**
- Expand `finiteMultilinearExtension` as a sum over subsets.
- Apply Theorem 1 pointwise to each subset in the support.
- Exchange finite sums.
- Prove the Bernoulli expectation identity:
  \[
  \sum_A \Pr_x[A]\sum_{v\in A} w_v = \sum_v x_v w_v.
  \]
This identity itself is a substantial combinatorial lemma worth isolating.

---

### Theorem 3: Threshold rounding bound for submodular curvature objectives
This is the flagship theorem.

```lean
theorem threshold_submodular_curvature_gap_bound_finite
    {V E : Type _} [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    (Inc : E → Finset V)
    (d : ℕ)
    (hd : ∀ e : E, (Inc e).card ≤ d)
    (x : V → ℝ)
    (hx0 : ∀ v, 0 ≤ x v)
    (hx1 : ∀ v, x v ≤ 1)
    (htrans : fractionalTransversal Inc x)
    (f : Finset V → ℝ)
    (hsub : IsMonotoneSubmodular f)
    (hnorm : f ∅ = 0)
    (κ : ℝ)
    (hk0 : 0 ≤ κ)
    (hk1 : κ < 1)
    (hcurv : totalCurvatureBound f κ) :
    f (thresholdSet x) ≤
      (d : ℝ) / (1 - κ) * finiteMultilinearExtension f x := by
  sorry
```

This is the theorem that would genuinely broaden the scope of the catalog.

**How to build on the catalog.**
Use:
- `Catalog/Pythagorean/WeightedHypergraphTransversal.lean`
  - `weighted_threshold_cost_bound`
  - `threshold_simultaneous_multiobjective_bound`
- `Catalog/Pythagorean/HypergraphTransversal.lean`
  - `threshold_isTransversal`
  - `threshold_card_bound`

The plan is to instantiate the catalog’s weighted theorem with modular weights
\[
w(v) := f(\{v\}),
\]
derive
\[
\sum_{v\in S} f(\{v\}) \le d \sum_v x_v f(\{v\}),
\]
then combine:
\[
f(S) \le \frac{1}{1-\kappa}\sum_{v\in S} f(\{v\})
\le \frac{d}{1-\kappa}\sum_v x_v f(\{v\}),
\]
and finally compare `∑ x_v f({v})` to `F(x)` via your multilinear lemmas.

If the final comparison only gives
\[
f(S) \le \frac{d}{(1-\kappa)^2}F(x),
\]
do **not** hide it. Prove it honestly as an intermediate theorem, then isolate the exact place where one factor of `(1-κ)` is lost. That loss is mathematically informative and may point to the true sharp statement.

---

## Strong intermediate lemmas you should isolate

These are not optional fluff; they are the scaffolding.

### Lemma A: Submodular telescoping by insertions
```lean
theorem submodular_telescope_singletons
    {V : Type _} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ)
    (hsub : IsMonotoneSubmodular f)
    (hnorm : f ∅ = 0) :
    ∀ A : Finset V, f A ≤ ∑ v in A, f ({v}) := by
  sorry
```
This is the curvature-zero baseline and should be proved by induction on finite sets.

### Lemma B: Bernoulli expectation of modular weights
```lean
theorem finiteMultilinear_modular_eq
    {V : Type _} [Fintype V] [DecidableEq V]
    (w : V → ℝ) (x : V → ℝ)
    (hx0 : ∀ v, 0 ≤ x v) (hx1 : ∀ v, x v ≤ 1) :
    finiteMultilinearExtension (fun A => ∑ v in A, w v) x
      = ∑ v in Finset.univ, x v * w v := by
  sorry
```
This is a beautiful finite probability-combinatorics theorem and may require `Finset.induction`, `field_simp`, and sum/product rearrangement.

### Lemma C: Curvature lower bound on marginals
Formalize the finite-set version of the curvature statement you actually need:
```lean
theorem curvature_controls_marginal
    {V : Type _} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ) (κ : ℝ)
    (hsub : IsMonotoneSubmodular f)
    (hcurv : totalCurvatureBound f κ) :
    ∀ (A : Finset V) (v : V), v ∉ A →
      (1 - κ) * f ({v}) ≤ f (insert v A) - f A := by
  sorry
```
If this exact statement is false, find and prove the correct variant. This is where the mathematics becomes real: isolate the true finite combinatorial content of curvature.

---

## Proof strategy architecture

You must not pursue only one path. I want you to actively test multiple proof architectures.

### Strategy A — Modular domination reduction
This is the most promising route.

1. **Prove curvature ⇒ modular upper bound.**  
   Show `f(A)` is controlled by scaled singleton weights:
   \[
   f(A) \le \frac{1}{1-\kappa}\sum_{v\in A} f(\{v\}).
   \]
2. **Invoke catalog weighted threshold theorem** with weight `w(v)=f({v})`.
3. **Relate modular expectation to multilinear extension** through finite Bernoulli identities and submodular comparison.

**Why this is most promising:**  
It reuses the strongest certified catalog infrastructure and reduces the nonlinear theorem to a chain of finite combinatorial inequalities. It is Lean-friendly because it avoids heavy measure theory and pushes complexity into `Finset` induction and algebraic rearrangements.

---

### Strategy B — Lovász/multilinear convex decomposition route
This is conceptually elegant but may be harder to formalize.

1. Express the multilinear extension as a convex combination or expectation over chains/level sets.
2. Compare threshold rounding directly to this distribution of random sets.
3. Use submodularity to control the deterministic threshold set against the expected random objective.

**Why it is attractive:**  
This route could reveal a stronger theorem than the modular-domination path, perhaps even the sharp `d/(1-κ)` constant without losing an extra factor.

**Why it is harder:**  
Formalizing the right expectation identity and chain decomposition in Lean may be significantly more demanding.

---

### Strategy C — Counterexample-guided refinement
You should run this in parallel.

1. Implement random weighted coverage functions with tunable overlap.
2. Empirically test the exact conjecture:
   \[
   f(S)/F(x) \le d/(1-\kappa).
   \]
3. If violated, search for a corrected statement:
   - `d/(1-κ)^2`,
   - `d/(1-cκ)`,
   - or a theorem under a stronger hypothesis such as coverage functions, rank functions, or bounded overlap systems.

**Why this is essential:**  
The curvature literature is subtle. The exact finite-set inequality you need may fail in full generality. A counterexample is not failure; it is scientific progress. If the conjecture breaks, pivot immediately to the strongest true theorem and explain precisely why.

---

## Cross-domain connections you must explicitly develop

At least one theorem should connect this work to another domain. Here are the most promising bridges.

### 1. Machine learning: feature selection and sparsification
Coverage functions and facility-location objectives are standard submodular surrogates for feature selection, active learning, and sensor placement. Your theorem would certify that threshold rounding of fractional relaxations preserves nonlinear utility up to curvature-dependent distortion.

Possible formal corollary:
- For weighted coverage objectives, threshold rounding yields a bounded loss in selected-information score.

### 2. Welfare economics: diminishing returns and fair allocation
Submodularity encodes diminishing marginal utility. The theorem says a deterministic threshold policy approximately preserves expected welfare from a fractional plan. This is a mathematically clean bridge between combinatorial optimization and economic allocation theory.

### 3. Social networks: influence maximization
Influence spread under independent cascade admits submodular structure. A curvature-aware threshold theorem would imply deterministic seed-set extraction guarantees from fractional or relaxed influence policies.

### 4. Statistical physics / probabilistic combinatorics
The multilinear extension is an expectation over independent Bernoulli spins; threshold rounding is a zero-temperature deterministic projection. Your theorem would be a rigorous inequality comparing a stochastic partition-function-like observable to a deterministic ground-state-like slice. This is exactly the kind of cross-domain connection that makes mathematicians pause.

You should state at least one theorem or corollary in one of these languages, not merely mention the application.

---

## Concrete catalog build plan

You must explicitly inspect and exploit:

- `Catalog/Pythagorean/WeightedHypergraphTransversal.lean`
  - `weighted_threshold_cost_bound`
  - `threshold_simultaneous_multiobjective_bound`

Use these as the linear backbone. Most likely they provide a theorem of the form:
\[
\sum_{v \in S} w(v) \le d \sum_v x(v)w(v)
\]
for threshold-rounded `S`.

- `Catalog/Pythagorean/HypergraphTransversal.lean`
  - `threshold_isTransversal`
  - `threshold_card_bound`

Use these to preserve feasibility and compare to the cardinality special case.

A strong deliverable would be a theorem showing your new submodular theorem strictly generalizes the cardinality theorem by instantiating `f(A)=A.card` or weighted cardinality.

---

## Computational component: required verified algorithm

You must provide a **verified computational method**, not only theorem statements.

### Algorithm target
Implement a certified estimator and tester for the conjecture on weighted coverage functions.

1. Generate random hypergraphs on `n = 20`.
2. Generate random coverage functions:
   \[
   f(A)=\sum_{u \in U} w_u \mathbf{1}\{A \cap C_u \neq \emptyset\}.
   \]
3. Estimate `F(x)` by Monte Carlo with 1000 Bernoulli samples.
4. Apply threshold rounding to obtain `S`.
5. Compute empirical ratio:
   \[
   \rho = f(S)/\widehat{F(x)}.
   \]
6. Estimate curvature from singleton and full-set marginal data.
7. Search for violations of
   \[
   \rho \le d/(1-\kappa)+\varepsilon.
   \]

### Formal/computational bridge
If full probabilistic verification is too heavy, verify the deterministic pieces:
- exact computation of coverage objective,
- exact threshold rounding,
- exact curvature computation for finite coverage instances,
- exact modular surrogate bound.

Then use `demo.py` for randomized exploration.

---

## Falsifiable conjecture and testable prediction

You must include at least one falsifiable conjecture with a computational test.

### Primary conjecture
**Conjecture (coverage-case sharp curvature-gap).**  
For every finite weighted coverage function `f` on a hypergraph of rank `d`, every feasible fractional transversal `x`, and threshold-rounded set `S`,
\[
f(S) \le \frac{d}{1-\kappa(f)} F(x).
\]

This is a cleaner restricted conjecture than the full general submodular statement and may well be the true sharp theorem.

**Testable prediction:**  
In random coverage instances with overlap-driven curvature, the empirical ratio
\[
f(S)/F(x)
\]
tracks closely with `d/(1-κ)` and remains strictly below it. A single instance exceeding this threshold by statistically stable margin disproves the conjecture.

### Backup conjecture
If the sharp conjecture fails empirically, formulate:
\[
f(S) \le \frac{d}{(1-\kappa)^2}F(x)
\]
for all monotone submodular `f`, and test whether the extra factor is genuinely necessary.

---

## What would count as a breakthrough

Any one of the following would be excellent:

1. **Full theorem** `f(S) ≤ d/(1-κ) · F(x)` for a broad class of monotone submodular functions.
2. **Sharp theorem for weighted coverage functions**, with formal proof.
3. **A rigorously proved weaker theorem** such as `d/(1-κ)^2`, together with a computationally discovered obstruction to the sharp conjecture.
4. **A counterexample** showing the naive curvature-gap conjecture is false in general, plus a corrected theorem for a meaningful subclass.

Do not confuse “we proved something true” with “we found the right theorem.” If the conjecture is false, discovering the obstruction and repairing the statement is just as valuable.

---

## Application keywords

Submodular optimization; curvature; multilinear extension; threshold rounding; hypergraph transversal; approximation algorithms; weighted coverage; feature selection; influence maximization; welfare economics; probabilistic combinatorics; statistical physics; deterministic rounding; finite probability; certified optimization.

---

## Deliverables (ALL mandatory)

You must produce all of the following:

1. **Lean file(s)** with:
   - at least 3 nontrivial theorems,
   - at least one genuinely new definition,
   - proofs using induction / `rcases` / `by_contra` / `field_simp` / multi-step `calc`,
   - minimal `sorry`.

2. **`FUTURE_DIRECTIONS.md`** with 3–5 research directions.  
   Each direction must include the exact sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   At least one direction must bridge to a different domain.

3. **`RESEARCH_PAPER.md`** as a standalone scientific paper.  
   A reader with no access to code must understand:
   - the theorem(s),
   - why they matter,
   - what was conjectured,
   - what was proved or refuted,
   - and what comes next.

4. **`ARTICLE.md`** in Scientific American style.  
   It must be engaging and accessible, and it must focus on the mathematics and significance.  
   **Taboo:** do not focus on formal verification machinery.

5. **A verified algorithm or computational method.**  
   This can be a certified curvature calculator, exact coverage evaluator, exact threshold-rounding checker, or a finite multilinear-extension evaluator for small instances.

6. **`demo.py`** that interactively demonstrates:
   - generation of random coverage instances,
   - threshold rounding,
   - Monte Carlo estimation of multilinear extension,
   - curvature estimation,
   - and empirical ratio plots against the conjectured bound.

---

## Final instruction

Be bold. Either prove the curvature-gap theorem, prove the strongest true variant, or kill the conjecture with a counterexample and replace it with the right theorem. The point is not to formalize a folklore inequality. The point is to discover whether **curvature is the missing parameter that upgrades linear hypergraph rounding into a nonlinear theory of deterministic approximation**.

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
    "visualizations": [ { "name": "...", "code": "# matplotlib or plotly script, self-contained", "description": "What this visualizes" } ],
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
