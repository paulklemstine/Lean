Soli Deo Gloria

## Assignment: Direction 1: Sharp Total KAM Radius

**Mode:** prove

Prove new, non-trivial theorems establishing a **sharp instability threshold** for finite-scale tropical/KAM-type Diophantine protection under cumulative perturbations. Build directly on the catalog results in:

- `Pythagorean/TropicalKAMRenormalization.lean`
  - `total_perturbation_budget_bound`
  - `certifyMultiScaleKAM_sound`

The objective is not another upper-bound variant. The objective is to turn the existing one-sided certification theorem into an **exact phase-transition theorem**: the safe total perturbation budget `C / K` is not merely sufficient, but in an appropriate universal sense **best possible**.

---

## Central Vision

The existing catalog theorem morally says:

> if the total perturbation budget is strictly below `C / K`, then every finite-step resonance profile up to scale `K` survives.

That is a **stability theorem**. What is missing is the matching **instability theorem**.

The breakthrough target is to show that the quantity `C / K` behaves like a **critical radius** or **sharp threshold**, analogous to:
- injectivity radius in geometry,
- noise thresholds in coding theory,
- stability margins in control,
- critical temperature in statistical physics,
- adversarial robustness radius in optimization/ML,
- percolation thresholds in probability.

This would elevate tropical KAM from a collection of certification lemmas to a **threshold theory**.

---

## Exact Mathematical Target

Let the finite-scale Diophantine predicate be the one already encoded in the catalog: for frequency vectors `ω`, the statement that every nonzero integer mode `k` with `‖k‖₁ ≤ K` satisfies the lower bound
`|k • ω| ≥ C`.

You should formalize a notion of **distance to the finite resonance arrangement**
\[
\mathcal R_K := \bigcup_{\substack{k \in \mathbb Z^d \\ 0 < \|k\|_1 \le K}} \{\omega : k \cdot \omega = 0\}.
\]
The governing principle is:

\[
\operatorname{dist}(\omega,\mathcal R_K)
=
\inf_{0 < \|k\|_1 \le K} \frac{|k\cdot \omega|}{\|k\|_2},
\]
while the catalog safety bound is driven by the weaker but universal estimate
\[
|k\cdot \delta| \le \|k\|_1 \|\delta\|_\infty \le K\|\delta\|_\infty.
\]
Hence the threshold `C/K` is the exact universal radius in `‖·‖∞`, because one can align a perturbation with a sign pattern of a near-critical mode.

The key distinction is:

- **Certified safe radius**: every perturbation with total `∞`-budget `< C/K` preserves finite-scale Diophantine nonresonance.
- **Sharpness / optimality**: for any budget `B > C/K`, there exists some `(K,C)`-Diophantine frequency and some perturbation of `∞`-size at most `B` that creates a resonance.
- **Instance-wise exactness**: if a mode `k₀` with `‖k₀‖₁ = K` exactly attains the Diophantine margin `|k₀ • ω| = C`, then a perturbation of `∞`-norm exactly `C/K` can force `k₀ • (ω+δ)=0`.

This is the right theorem schema: one universal sharpness theorem, plus one exact attainment theorem, plus one geometric reformulation theorem.

---

## Precise Theorem Statements to Target

You should introduce at least one new definition capturing the resonance geometry.

### New definitions to add

1. **Finite resonance set**
   ```lean
   def finiteResonanceSet (K : ℕ) : Set (EuclideanSpace ℝ (Fin d)) :=
     {ω | ∃ k : EuclideanSpace ℤ (Fin d),
         k ≠ 0 ∧ ‖k‖₁ ≤ K ∧ ∑ i, (k i : ℝ) * ω i = 0}
   ```

2. **Finite-scale Diophantine predicate**
   ```lean
   def IsKDiophantine (K : ℕ) (C : ℝ) (ω : EuclideanSpace ℝ (Fin d)) : Prop :=
     ∀ k : EuclideanSpace ℤ (Fin d),
       k ≠ 0 → ‖k‖₁ ≤ K →
       C ≤ |∑ i, (k i : ℝ) * ω i|
   ```

3. **Critical budget**
   ```lean
   def criticalBudget (K : ℕ) (C : ℝ) : ℝ := C / K
   ```

4. **Mode-attaining margin**
   ```lean
   def AttainsMargin (K : ℕ) (C : ℝ) (ω : EuclideanSpace ℝ (Fin d)) : Prop :=
     ∃ k : EuclideanSpace ℤ (Fin d),
       k ≠ 0 ∧ ‖k‖₁ = K ∧ |∑ i, (k i : ℝ) * ω i| = C
   ```

If the catalog already has close analogues, refine rather than duplicate; but at least one genuinely new concept must appear, e.g. a **finite resonance distance** or **critical mode profile**.

---

## Core theorem 1: universal sharpness of `C / K`

This should be your flagship theorem.

### Mathematical statement
For every `K ≥ 1`, every `C > 0`, and every budget `B > C / K`, there exist a dimension `d` (it is enough to take `d = 2`), a frequency `ω`, and a perturbation `δ` such that:
1. `ω` is `(K,C)`-Diophantine,
2. `‖δ‖∞ ≤ B`,
3. `ω + δ` is not `(K,C')`-Diophantine for any `C' > 0`, because some nonzero `k` with `‖k‖₁ ≤ K` satisfies `k • (ω + δ) = 0`.

A concrete witness family should be used, e.g.
\[
k_0 = (K,0), \qquad \omega = (C/K + \varepsilon, 1),
\qquad \delta = (-(C/K+\varepsilon),0),
\]
with `0 < ε < B - C/K`.
Then `ω` is `(K,C)`-Diophantine if all other small modes are kept safely away; choosing dimension 2 with a carefully separated second coordinate can make this work.

### Lean-style type signature
A realistic version, fixing dimension `Fin 2`, could be:
```lean
theorem exists_resonant_perturbation_above_critical
    {K : ℕ} (hK : 0 < K) {C B : ℝ}
    (hC : 0 < C) (hB : C / K < B) :
    ∃ ω δ : EuclideanSpace ℝ (Fin 2),
      IsKDiophantine K C ω ∧
      ‖δ‖∞ ≤ B ∧
      ∃ k : EuclideanSpace ℤ (Fin 2),
        k ≠ 0 ∧ ‖k‖₁ ≤ K ∧
        ∑ i, (k i : ℝ) * (ω i + δ i) = 0
```

If exact `‖·‖∞` notation is awkward in Mathlib for your chosen representation, specialize to `Fin 2 → ℝ` and define the sup norm explicitly:
```lean
def supNorm2 (x : Fin 2 → ℝ) : ℝ := max (|x 0|) (|x 1|)
```
That may be much easier to control formally.

---

## Core theorem 2: exact attainment at the threshold

This theorem turns the heuristic “push toward the nearest resonance” into an exact formula.

### Mathematical statement
Suppose `ω` is `(K,C)`-Diophantine and there exists a mode `k₀` with `‖k₀‖₁ = K` and `|k₀ • ω| = C`. Then there exists `δ` with `‖δ‖∞ = C / K` such that
\[
k_0 \cdot (\omega+\delta)=0.
\]
Thus the universal safe radius cannot be improved even by an epsilon.

The perturbation should be chosen by the sign vector of `k₀`:
\[
\delta_i = -\operatorname{sgn}(k_0\cdot \omega)\,\operatorname{sgn}(k_{0,i})\, C/K,
\]
on coordinates where `k₀,i ≠ 0`, adjusted so that
\[
k_0\cdot \delta = -\,k_0\cdot \omega.
\]
Because
\[
\sum_i |k_{0,i}| \cdot (C/K) = C,
\]
exact cancellation is available when `‖k₀‖₁ = K`.

### Lean-style type signature
```lean
theorem exact_resonance_at_critical_budget
    {K : ℕ} (hK : 0 < K) {C : ℝ} (hC : 0 ≤ C)
    {ω : EuclideanSpace ℝ (Fin d)}
    (hω : IsKDiophantine K C ω)
    (hattain : AttainsMargin K C ω) :
    ∃ δ : EuclideanSpace ℝ (Fin d),
      ‖δ‖∞ = C / K ∧
      ∃ k : EuclideanSpace ℤ (Fin d),
        k ≠ 0 ∧ ‖k‖₁ = K ∧
        ∑ i, (k i : ℝ) * (ω i + δ i) = 0
```

This theorem is deep because it formalizes the exact geometry of the `ℓ¹`/`ℓ∞` duality underlying the catalog bound.

---

## Core theorem 3: geometric reformulation as distance to resonance

This theorem is the conceptual payoff.

### Mathematical statement
For finite scale `K`, define the resonance distance
\[
\operatorname{resDist}_K(\omega)
:=
\inf_{\substack{k \neq 0\\ \|k\|_1\le K}}
\frac{|k\cdot \omega|}{\|k\|_1}.
\]
Then:
1. if `B < resDist_K(ω)`, every perturbation `δ` with `‖δ‖∞ ≤ B` preserves nonresonance up to scale `K`;
2. if the infimum is attained by some `k₀`, then there exists `δ` with `‖δ‖∞ = resDist_K(ω)` making `k₀ • (ω+δ)=0`.

This is stronger than the original conjecture: it identifies `C/K` as the universal lower envelope, while `resDist_K(ω)` is the **instance-specific exact adversarial radius**.

### Lean-style type signature
```lean
def resonanceDistance (K : ℕ) (ω : EuclideanSpace ℝ (Fin d)) : ℝ :=
  sInf {r : ℝ | ∃ k : EuclideanSpace ℤ (Fin d),
    k ≠ 0 ∧ ‖k‖₁ ≤ K ∧ r = |∑ i, (k i : ℝ) * ω i| / ‖k‖₁}

theorem perturbation_below_resonanceDistance_safe
    {K : ℕ} {ω δ : EuclideanSpace ℝ (Fin d)} {B : ℝ}
    (hB : ‖δ‖∞ < resonanceDistance K ω) :
    ∀ k : EuclideanSpace ℤ (Fin d),
      k ≠ 0 → ‖k‖₁ ≤ K →
      ∑ i, (k i : ℝ) * (ω i + δ i) ≠ 0
```

And an attainment theorem under finite-set compactness/attainment:
```lean
theorem resonanceDistance_attained_gives_exact_instability
    {K : ℕ} {ω : EuclideanSpace ℝ (Fin d)}
    (hattain :
      ∃ k : EuclideanSpace ℤ (Fin d),
        k ≠ 0 ∧ ‖k‖₁ ≤ K ∧
        resonanceDistance K ω = |∑ i, (k i : ℝ) * ω i| / ‖k‖₁) :
    ∃ δ : EuclideanSpace ℝ (Fin d),
      ‖δ‖∞ = resonanceDistance K ω ∧
      ∃ k : EuclideanSpace ℤ (Fin d),
        k ≠ 0 ∧ ‖k‖₁ ≤ K ∧
        ∑ i, (k i : ℝ) * (ω i + δ i) = 0
```

Because the set of integer modes with `‖k‖₁ ≤ K` is finite, you should strongly consider replacing `sInf` with a finite minimum over a finset. That will likely be much more tractable in Lean and more algorithmic.

---

## Most Promising Proof Architecture

### Strategy A: finite-mode minimization + explicit dual witness
This is the most promising route.

1. **Enumerate the finite mode set**
   \[
   \{k \in \mathbb Z^d : 0 < \|k\|_1 \le K\}
   \]
   as a finite set / finset. This converts the abstract geometry into a finite optimization problem.

2. **Define the adversarial radius**
   as the minimum of
   \[
   |k\cdot \omega| / \|k\|_1
   \]
   over that finite set.

3. **Use the dual inequality**
   \[
   |k\cdot \delta| \le \|k\|_1\|\delta\|_\infty
   \]
   for safety below the minimum.

4. **Construct a sign perturbation**
   achieving equality for a minimizer:
   choose `δ_i = - s * sign(k_i) * r` with a small coordinate correction if needed, where `r` is the minimizing ratio. This gives exact resonance.

Why this is best: it mirrors the catalog bound exactly, uses only finite combinatorics and norm inequalities, and naturally produces a verified algorithm.

---

### Strategy B: distance-to-hyperplane geometry in `ℓ∞`
Interpret each resonance condition `k • ω = 0` as a hyperplane. Then prove:

\[
\operatorname{dist}_{\infty}(\omega,\{x : k\cdot x = 0\})
=
\frac{|k\cdot \omega|}{\|k\|_1}.
\]

Then take the minimum over all admissible `k`. This yields a geometric theorem:
the finite resonance arrangement has exact `ℓ∞`-distance equal to the adversarial radius.

Why this is powerful: it turns the KAM statement into convex geometry / dual norm theory. It opens immediate bridges to optimization, robust control, and tropical polyhedral geometry.

Potential issue: formalizing distance-to-set cleanly may be heavier than the finite-minimum route.

---

### Strategy C: schedule-level theorem from one-shot theorem
If the catalog theorem is phrased for geometric schedules and cumulative budget, prove first a one-shot perturbation theorem and then embed it as a one-step or tail-concentrated schedule:
- set all earlier perturbations to `0`,
- put the entire adversarial perturbation at one scale,
- verify the total budget is exactly the desired amount.

Why this matters: it upgrades the static sharpness theorem to the exact language of the catalog’s renormalization/schedule framework.

This should likely be done after Strategy A, not before.

---

## Proof Tactics Requirements

Your file must contain at least 3 theorems with genuinely nontrivial proofs using combinations of:
- `induction`
- `rcases`
- `by_contra`
- `field_simp`
- `linarith`
- `nlinarith`
- `have` chains
- multi-step `calc`
- explicit inequality manipulation
- finite set minimization arguments

In particular, likely candidates:
1. the `ℓ¹`/`ℓ∞` dual inequality for finite sums,
2. the safety-below-threshold theorem,
3. the exact-resonance-at-threshold theorem,
4. the finset-attainment theorem for the minimum adversarial radius.

Do **not** let the file devolve into decidable enumeration.

---

## Cross-Domain Connections You Must Make Explicit

Include at least one theorem or formal remark bridging this KAM threshold to another domain.

### Bridge 1: Convex geometry / optimization
The quantity
\[
\min_{0<\|k\|_1\le K}\frac{|k\cdot \omega|}{\|k\|_1}
\]
is exactly a **robust margin** under `ℓ∞` adversaries. This is the same geometry behind:
- linear classification margins,
- adversarial examples in machine learning,
- support functions of cross-polytopes,
- dual norms in Banach space theory.

Formal target:
```lean
theorem hyperplane_supNorm_distance_formula
    (k : EuclideanSpace ℤ (Fin d)) (hk : k ≠ 0) (ω : EuclideanSpace ℝ (Fin d)) :
    infDist ω {x | ∑ i, (k i : ℝ) * x i = 0} =
      |∑ i, (k i : ℝ) * ω i| / ‖k‖₁
```
If `infDist` is too heavy, prove a custom existential version.

### Bridge 2: Statistical physics / critical phenomena
Interpret `C/K` as a **critical budget** where the system transitions from universally stable to potentially resonant. This is mathematically analogous to:
- percolation thresholds,
- spinodal instability,
- depinning transitions.

You need not formalize physics, but your `RESEARCH_PAPER.md` must articulate this precisely:
the theorem identifies an order parameter (resonance/nonresonance) and a sharp control parameter (budget).

### Bridge 3: Computer science / worst-case complexity
The minimizing mode is a **worst-case certificate**. The verified algorithm computes the exact finite adversarial radius by scanning all integer modes up to scale `K`. This is a discrete robust optimization problem.

---

## Verified Algorithmic Deliverable

You must produce a verified computational method, not only existence theorems.

### Algorithm target
Given `K`, `ω`, compute
\[
r_K(\omega)=\min_{0<\|k\|_1\le K}\frac{|k\cdot \omega|}{\|k\|_1}.
\]

Then:
- certify that any perturbation with total sup-budget `< r_K(ω)` is safe;
- construct an explicit perturbation of size `= r_K(ω)` producing resonance when a minimizing mode is found.

### Lean-facing structure
- define the finite mode `Finset`,
- compute candidate ratios,
- prove the returned minimum equals the mathematical adversarial radius,
- prove the constructed perturbation is sound.

This is the computational heart of the project and should connect directly to `demo.py`.

---

## Demo Requirements

Your `demo.py` must:
1. instantiate `ω = (1, φ)` or rational approximants to it,
2. fix values such as `K = 10`,
3. enumerate modes `k` with `‖k‖₁ ≤ K`,
4. compute the empirical critical radius,
5. construct perturbations with budgets:
   - `0.99 * r`
   - `1.01 * r`
   - `1.1 * r`
6. show numerically that:
   - below `r`, no resonance is hit among admissible modes,
   - at/above `r`, a minimizing mode can be driven to resonance or near-resonance.

The demo should visually present the threshold behavior.

---

## Testable Conjectures for FUTURE_DIRECTIONS.md

You must include 3–5 falsifiable hypotheses. At least one should be:

### Conjecture A: universal sharp threshold
For every `K ≥ 1` and `C > 0`, the universal safe sup-budget for all `(K,C)`-Diophantine frequencies is exactly `C/K`.

**Test:** generate many `(K,C)`-Diophantine samples in dimension 2 or 3, compute empirical adversarial radii, and verify none fall below `C/K`, while examples arbitrarily close to `C/K` are found.

Additional strong hypotheses you should include:

### Conjecture B: asymptotic mode concentration
For generic 2D frequencies, the minimizing mode for `r_K(ω)` asymptotically lies on the boundary `‖k‖₁ = K`.

**Test:** for random irrational `ω`, compute minimizing modes as `K` grows; record whether minimizers concentrate on `‖k‖₁ = K`.

### Conjecture C: tropical polytope structure
The sublevel sets
\[
\{\omega : r_K(\omega)\ge t\}
\]
form centrally symmetric polyhedral regions determined by finitely many admissible modes.

**Test:** in dimension 2, explicitly plot these regions and verify polyhedrality.

### Conjecture D: universality across schedules
For any admissible cumulative schedule model in the catalog, the sharp instability threshold equals the one-shot adversarial radius.

**Test:** compare one-shot and distributed schedules numerically under identical total budgets.

### Conjecture E: critical scaling law
For badly approximable frequencies such as `(1,φ)`, the empirical radius `r_K(ω)` scales like `const / K`.

**Test:** fit `K * r_K(ω)` over a large range of `K` and check convergence/nonconvergence.

---

## Concrete Lean Engineering Advice

You should strongly consider working in `Fin 2 → ℝ` or `Fin d → ℝ` with custom norms if the existing normed-space machinery becomes cumbersome. A simple and robust path is:

```lean
def dot2 (k : Fin 2 → ℤ) (ω : Fin 2 → ℝ) : ℝ :=
  ∑ i, (k i : ℝ) * ω i

def l1NormInt2 (k : Fin 2 → ℤ) : ℕ :=
  ∑ i, Int.natAbs (k i)

def supNorm2 (x : Fin 2 → ℝ) : ℝ :=
  max (|x 0|) (|x 1|)
```

Then prove:
```lean
theorem dot_le_l1_mul_sup
    (k : Fin 2 → ℤ) (x : Fin 2 → ℝ) :
    |dot2 k x| ≤ (l1NormInt2 k : ℝ) * supNorm2 x
```

This theorem is mathematically substantive and should require real proof steps (`calc`, triangle inequality, case splits on `Fin 2`, etc.).

Then build the instability theorem from this.

---

## Minimal Theorem Bundle Expected in the Lean File

At least these 3 theorem-level deliverables:

1. **Dual norm bound**
   ```lean
   theorem dot_le_l1_mul_sup ...
   ```

2. **Safety below critical radius**
   A theorem extending `total_perturbation_budget_bound` / `certifyMultiScaleKAM_sound` to a finite-resonance-distance formulation.

3. **Sharpness / exact resonance above or at threshold**
   An explicit construction theorem producing resonance from budget `> C/K` or exactly `= C/K` under attainment assumptions.

A fourth theorem is strongly encouraged:

4. **Finite minimum attainment**
   The admissible resonance margin is realized by some mode because the mode set is finite.

---

## Why This Would Be a Breakthrough

If you complete this, you will have transformed a one-sided tropical KAM robustness estimate into an **exact threshold theorem**. That is qualitatively different mathematics.

It would mean:
- the catalog’s perturbation bound is not an artifact of proof technique;
- the `ℓ¹`/`ℓ∞` duality is the true hidden geometry of finite-scale resonance;
- tropical KAM admits a **critical-phenomena interpretation** with a sharp control parameter;
- one can algorithmically compute exact adversarial radii, not just safe certificates.

This opens a new field direction: **robust arithmetic dynamics**, where resonance avoidance is studied using optimization, polyhedral geometry, and threshold theory.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean file(s)** with the new definitions and at least 3 substantial theorems, minimizing `sorry`.
2. **`FUTURE_DIRECTIONS.md`** containing 3–5 falsifiable scientific hypotheses, each with a clear computational disproof test.
3. **`RESEARCH_PAPER.md`** as a standalone scientific paper explaining the theorem, proof ideas, significance, and next questions without requiring code access.
4. **`ARTICLE.md`** in Scientific American style, focused on the mathematics and significance — **do not focus on formal verification machinery**.
5. **A verified algorithm or computational method** for computing the finite adversarial radius / critical budget.
6. **`demo.py`** demonstrating the sharp threshold numerically and interactively.

---

## Application Keywords

tropical KAM, Diophantine stability, sharp threshold, critical radius, resonance geometry, adversarial robustness, dual norms, hyperplane arrangements, polyhedral distance, worst-case analysis, robust optimization, critical phenomena, percolation analogy, finite-scale arithmetic dynamics, tropical renormalization

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
