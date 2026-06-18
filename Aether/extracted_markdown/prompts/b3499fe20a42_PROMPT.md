Soli Deo Gloria

## Assignment: Direction 1: Higher-Order Entropy Bounds from the Full Newton Hierarchy

**Mode:** prove

Prove genuinely new, non-trivial theorems at the interface of **quantum information, algebraic combinatorics, and approximation theory**, using Lean 4 + Mathlib and building explicitly on:

- `Pythagorean/EntanglementEntropy.lean`
- `Bridges/LorentzianNewton.lean`

Your mission is to turn the existing first-order Newton/entropy bridge into a **higher-order Newton hierarchy for entanglement**, where the full sequence of elementary symmetric data controls Rényi entropy and related spectral functionals. The conceptual breakthrough is this:

> **Entanglement without diagonalization:** replace direct access to the correlation eigenvalues by a structured finite list of Newton/Lorentzian invariants, and prove that these invariants control entropy, purity, and higher spectral moments.

If successful, this opens a new program: **Lorentzian-compressed quantum information**, where one studies many-body entanglement through algebraic signatures of spectra rather than through the spectra themselves.

---

## Core Mathematical Objective

Let `λ = (λ₁, …, λₘ)` with each `λᵢ ∈ [0,1]`. For free fermions, this is the one-body correlation spectrum of a subsystem. Define:

- elementary symmetric polynomials `e_k(λ)`,
- Newton ratios
  \[
  \rho_k(\lambda) := \frac{e_k(\lambda)^2}{e_{k-1}(\lambda)\, e_{k+1}(\lambda)}
  \qquad (1 \le k \le m-1),
  \]
  whenever denominators are nonzero,
- power sums
  \[
  p_r(\lambda) := \sum_{i=1}^m \lambda_i^r,
  \]
- binary Rényi entropy contribution
  \[
  h_\alpha(x) := \frac{\log(x^\alpha + (1-x)^\alpha)}{1-\alpha}
  \quad (\alpha \ne 1),
  \]
  and binary Shannon entropy
  \[
  h_1(x) := -x\log x - (1-x)\log(1-x).
  \]
Then subsystem Rényi entropy is
\[
S_\alpha(\lambda) := \sum_{i=1}^m h_\alpha(\lambda_i).
\]

The bold thesis to formalize is:

> The **full Newton hierarchy** `(e₁, …, e_m)` and especially the derived ratio profile `(ρ₁, …, ρ_{m-1})` encodes enough information to produce sharp deterministic bounds, effective approximations, and eventually asymptotic reconstruction of `S_α`.

This is not a minor strengthening of one entropy inequality. It is the beginning of a **dictionary between Lorentzian algebra and entanglement theory**.

---

## New Definitions You Should Introduce

You must define at least one genuinely new concept not already present in the catalog. I suggest introducing all of the following.

### 1. Newton ratio profile
A structure packaging the elementary symmetric sequence and its log-concavity diagnostics.

```lean
structure NewtonRatioProfile (m : ℕ) where
  e    : Fin (m + 1) → ℝ
  rho  : Fin (m - 1) → ℝ
  nonneg_e : ∀ k, 0 ≤ e k
  top_one : e 0 = 1
  ratio_spec :
    ∀ k : Fin (m - 1),
      rho k * e ⟨k.1, Nat.lt_trans k.2 (Nat.lt_succ_self _)⟩ *
        e ⟨k.1 + 2, by omega⟩
      = (e ⟨k.1 + 1, by omega⟩)^2
```

You may refine the indexing if this exact signature is awkward.

### 2. Newton-controlled entropy surrogate
A truncated algebraic approximation to entropy using only symmetric data.

```lean
def entropySurrogateFromPowerSums (N : ℕ) (p : ℕ → ℝ) : ℝ := ...
```

or, more structurally,

```lean
def newtonEntropySurrogate (N : ℕ) (e : ℕ → ℝ) : ℝ := ...
```

where the surrogate is obtained by expressing low-order power sums through Newton–Girard identities and inserting them into a polynomial / rational approximation of `h_α`.

### 3. Area-law compatible profile
A finite-dimensional condition abstracting the physical regime.

```lean
def AreaLawCompatible (C : ℝ) (λ : Fin m → ℝ) : Prop := ...
```

Possible formal choices:
- bounded total entropy,
- bounded first few centered moments,
- uniform decay of tail Newton defects,
- or bounded variation of the ratio profile.

Even if the asymptotic conjecture is not fully proved, formalizing a robust finite version is already valuable.

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems**. They should involve induction, `rcases`, `by_contra`, `field_simp`, and/or multi-step `calc` arguments. Do not settle for easy inequalities.

Below are the target theorems. If exact names in the catalog differ, adapt them, but preserve the mathematical content.

---

### Theorem 1: Newton–Girard control of low-order spectral moments

**Statement.** For every `k`, the power sum `p_k` is a universal polynomial in `e₁, …, e_k`. Therefore any polynomial approximation to `h_α` of degree `N` yields an entropy surrogate depending only on the first `N` elementary symmetric polynomials.

#### Lean-style target
```lean
theorem powerSum_eq_poly_esymm
    {m k : ℕ} (hk : 1 ≤ k) :
    ∃ P : MvPolynomial (Fin k) ℤ,
      ∀ (λ : Fin m → ℝ),
        powerSum λ k =
          MvPolynomial.eval
            (fun i => esymm λ (i.1 + 1))
            (MvPolynomial.map (Int.castRingHom ℝ) P)
```

A weaker but more implementation-friendly version is also acceptable:

```lean
theorem powerSum_mem_esymm_subalgebra
    {m k : ℕ} (hk : 1 ≤ k) :
    ∃ f : (Fin k → ℝ) → ℝ,
      ∀ λ : Fin m → ℝ,
        powerSum λ k = f (fun i => esymm λ (i.1 + 1))
```

#### Why this matters
This theorem is the algebraic engine. It converts entropy approximation into a finite invariant problem. Once proved, every polynomial approximation of entropy immediately becomes a theorem about symmetric data.

#### Proof strategy options
- **Strategy A: Newton–Girard recursion.**  
  Define `p_k` recursively from `e_1, ..., e_k` using the classical identity
  \[
  k e_k = \sum_{i=1}^k (-1)^{i-1} e_{k-i} p_i.
  \]
  Then solve inductively for `p_k`.  
  **Most promising**, because it mirrors the existing catalog machinery and gives constructive formulas.
- **Strategy B: generating functions.**  
  Use
  \[
  E(t)=\sum_{k=0}^m e_k t^k = \prod_i (1+\lambda_i t),
  \qquad
  \frac{E'(t)}{E(t)} = \sum_{r\ge1}(-1)^{r-1}p_r t^{r-1},
  \]
  then extract coefficients. Elegant but may be heavier to formalize.
- **Strategy C: symmetric polynomial universality.**  
  Appeal to the theorem that every symmetric polynomial is a polynomial in elementary symmetric polynomials. This is conceptually clean, but may be less explicit for computational extraction.

---

### Theorem 2: Truncated entropy approximation from symmetric data

Fix `α > 0`, `α ≠ 1`. Prove that on any compact subinterval `[δ, 1-δ] ⊂ (0,1)`, the binary Rényi entropy `h_α` admits polynomial approximation with explicit error, and therefore subsystem Rényi entropy admits a bound in terms of finitely many power sums, hence finitely many `e_k`.

#### Lean-style target
```lean
theorem renyi_entropy_approx_by_esymm
    {m N : ℕ} {α δ : ℝ}
    (hα_pos : 0 < α) (hα_ne : α ≠ 1)
    (hδ : 0 < δ ∧ δ < 1 / 2) :
    ∃ Φ : (Fin N → ℝ) → ℝ, ∃ εN : ℝ,
      0 ≤ εN ∧
      ∀ λ : Fin m → ℝ,
        (∀ i, δ ≤ λ i ∧ λ i ≤ 1 - δ) →
        ∃ e : Fin N → ℝ,
          (∀ i, e i = esymm λ (i.1 + 1)) ∧
          |renyiEntropy α λ - Φ e| ≤ εN
```

A stronger theorem should make `εN → 0` as `N → ∞`:

```lean
theorem renyi_entropy_approx_by_esymm_tendsTo
    {m : ℕ} {α δ : ℝ}
    (hα_pos : 0 < α) (hα_ne : α ≠ 1)
    (hδ : 0 < δ ∧ δ < 1 / 2) :
    ∃ Φ : ℕ → (∀ N, (Fin N → ℝ) → ℝ),
      ∃ ε : ℕ → ℝ,
        Tendsto ε atTop (𝓝 0) ∧
        ∀ N λ,
          (∀ i, δ ≤ λ i ∧ λ i ≤ 1 - δ) →
          |renyiEntropy α λ - Φ N (fun i => esymm λ (i.1 + 1))| ≤ ε N
```

#### Why this matters
This is the first rigorous statement that **entropy is algorithmically compressible into Lorentzian algebraic data**. It is the finite-dimensional precursor to the asymptotic conjecture in the prompt.

#### Proof strategy options
- **Strategy A: Chebyshev / Weierstrass approximation + Newton–Girard.**  
  Approximate `h_α(x)` uniformly on `[δ,1-δ]` by a polynomial `q_N(x)`. Then
  \[
  S_\alpha(\lambda) \approx \sum_i q_N(\lambda_i),
  \]
  and the latter is a linear combination of power sums `p_r`, each expressible through `e_1,\dots,e_r`.  
  **Most promising**, because it separates analysis and algebra cleanly.
- **Strategy B: Taylor expansion around `1/2`.**  
  Since `h_α` is analytic on `(0,1)` for `α > 0`, expand around `x=1/2`, control the remainder on `[δ,1-δ]`, and rewrite moments of `(λ_i - 1/2)` using power sums. More explicit, but bookkeeping may be heavier.
- **Strategy C: Bernstein polynomial approximation.**  
  Useful if you want positivity/monotonicity built in. Less sharp but formalization-friendly.

---

### Theorem 3: Newton-ratio monotonicity forces entropy rigidity

Prove a genuinely new inequality showing that if the Newton ratios are uniformly close to `1`, then the spectrum is close to a degenerate geometric progression regime, and entropy is correspondingly rigid.

A finite, formalizable version:

#### Mathematical statement
For fixed `m`, there exist constants `C_{m,α}` such that if
\[
\max_{1 \le k \le m-1} |\log \rho_k(\lambda)| \le \varepsilon,
\]
then
\[
|S_\alpha(\lambda) - \Psi_{m,\alpha}(e_1(\lambda), e_2(\lambda))|
\le C_{m,\alpha}\,\varepsilon
\]
for some explicit algebraic surrogate `\Psi_{m,\alpha}`.

Even a weaker but rigorous theorem is valuable:

> Uniform control of the Newton defects
> \[
> \Delta_k := e_k^2 - e_{k-1}e_{k+1}
> \]
> yields quantitative control on variance / purity / second Rényi entropy.

#### Lean-style target
```lean
theorem renyi_two_stable_under_newton_defect
    {m : ℕ} :
    ∃ C : ℝ,
      0 ≤ C ∧
      ∀ λ : Fin m → ℝ,
        (∀ i, 0 ≤ λ i ∧ λ i ≤ 1) →
        |renyiEntropy 2 λ - puritySurrogate (fun k => esymm λ k)| ≤
          C * ∑ k : Fin (m - 1), |(esymm λ (k.1 + 1))^2 - esymm λ k.1 * esymm λ (k.1 + 2)|
```

Or a more tractable theorem focused on moments:

```lean
theorem powerSum_two_controlled_by_newton_defects
    {m : ℕ} :
    ∃ C : ℝ,
      0 ≤ C ∧
      ∀ λ : Fin m → ℝ,
        (∀ i, 0 ≤ λ i ∧ λ i ≤ 1) →
        |powerSum λ 2 - momentSurrogateFromEsymm (fun k => esymm λ k)| ≤
          C * ∑ k : Fin (m - 1), |(esymm λ (k.1 + 1))^2 - esymm λ k.1 * esymm λ (k.1 + 2)|
```

#### Why this matters
This is the first step from **exact algebraic identities** to **robust inverse theory**. It says not only that entropy is a function of symmetric data, but that **small Lorentzian defects imply spectral rigidity**. That is a new bridge from combinatorial Hodge theory to many-body physics.

#### Proof strategy options
- **Strategy A: stability of Newton inequalities + Lipschitz continuity of entropy.**  
  First derive quantitative bounds on low-order moments from small Newton defects. Then use Lipschitz control of `h_α` on `[δ,1-δ]` or direct formulas for `α=2`.  
  **Most promising** for a first formal theorem.
- **Strategy B: log-concavity interpolation.**  
  Use the sequence `log e_k` and near-affinity implied by `ρ_k ≈ 1` to show approximate geometric structure of `e_k`, then reconstruct moment information.
- **Strategy C: majorization route.**  
  Translate Newton-ratio bounds into Schur-convex constraints and then use entropy monotonicity under majorization. More ambitious, possibly future work.

---

### Theorem 4: Cross-domain bridge — complete monotonicity / approximation-theoretic control

You are required to include at least one theorem connecting to another domain. The strongest natural bridge here is to **approximation theory** or **real-rooted/Lorentzian geometry**.

A particularly strong bridge theorem:

#### Mathematical statement
For integer `r ≥ 1`, the map
\[
\lambda \mapsto \sum_i \lambda_i^r
\]
is a polynomial spectral statistic determined by the elementary symmetric sequence; moreover, for `0 < α ≤ 2`, the binary Rényi kernel `h_α` can be uniformly approximated on compact subsets of `(0,1)` by linear combinations of such polynomial spectral statistics. Therefore free-fermion Rényi entropy lies in the closure of the algebra generated by Lorentzian Newton data.

#### Lean-style target
```lean
theorem renyi_in_closed_algebra_generated_by_esymm
    {m : ℕ} {α δ : ℝ}
    (hα : 0 < α) (hα_ne : α ≠ 1) (hδ : 0 < δ ∧ δ < 1 / 2) :
    ∀ ε > 0, ∃ N : ℕ, ∃ Φ : (Fin N → ℝ) → ℝ,
      ∀ λ : Fin m → ℝ,
        (∀ i, δ ≤ λ i ∧ λ i ≤ 1 - δ) →
        |renyiEntropy α λ - Φ (fun i => esymm λ (i.1 + 1))| < ε
```

#### Cross-domain significance
This theorem links:
- **quantum information**: entanglement spectra,
- **algebraic combinatorics**: elementary symmetric functions, Newton identities,
- **approximation theory**: polynomial approximation of nonlinear observables,
- **Lorentzian/Hodge theory**: log-concavity and Newton constraints.

This is exactly the kind of connection that makes mathematicians say: *I had not thought to use Lorentzian polynomial data as a compressed coordinate system for quantum entropy.*

---

## The Central Conjecture to State Clearly

You should explicitly state the following conjecture in the Lean file and in the paper, with a computationally testable finite version.

### Asymptotic Newton-hierarchy entropy conjecture
For each `α > 0`, there exists a universal family of functions
\[
\Psi_{\alpha,m} : \mathbb{R}^{m-1} \to \mathbb{R}
\]
such that for every sequence of free-fermion spectra `λ^(m) ∈ [0,1]^m` satisfying an area-law compatible condition,
\[
\bigl|S_\alpha(\lambda^{(m)}) - \Psi_{\alpha,m}(\rho_1(\lambda^{(m)}),\dots,\rho_{m-1}(\lambda^{(m)}))\bigr| \to 0
\quad \text{as } m \to \infty.
\]

A practical finite prediction:

> For 1D gapped free-fermion chains, a low-degree polynomial in `log ρ_k` fitted on moderate subsystem sizes predicts `S_α` with error decaying as subsystem size grows.

#### Lean-style conjecture stub
```lean
conjecture asymptotic_renyi_from_newton_ratios
    (α : ℝ) (hα : 0 < α) :
    ∃ Ψ : ∀ m : ℕ, (Fin (m - 1) → ℝ) → ℝ,
      ∀ (λseq : ℕ → Σ m : ℕ, Fin m → ℝ),
        AreaLawSequence λseq →
        Tendsto
          (fun n =>
            let m := (λseq n).1
            let λ := (λseq n).2
            |renyiEntropy α λ - Ψ m (fun k => newtonRatio λ k)|)
          atTop (𝓝 0)
```

If this is too ambitious to formalize fully, still state it as a conjecture and prove finite approximant theorems supporting it.

---

## Concrete Build on Catalog Theorems

You must explicitly identify and reuse the strongest available catalog theorems, likely including variants of:

- `entropy_ge_esymm_bound` from `Pythagorean/EntanglementEntropy.lean`
- `esymm_newton_inequality` from `Bridges/LorentzianNewton.lean`

Do not merely cite them. Explain how to use them:

1. **From `esymm_newton_inequality`**  
   Use it to establish log-concavity of the `e_k` sequence and nonnegativity of Newton defects. This gives the admissible region for your new `NewtonRatioProfile`.

2. **From `entropy_ge_esymm_bound`**  
   Use it as the `k = 2` or first-order anchor case of your hierarchy. Then prove higher-order analogues by replacing the coarse variance lower bound with polynomial approximants to `h_α`.

3. If the catalog already contains moment or entropy lemmas for functions on `[0,1]`, integrate them into the approximation step rather than reproving elementary analytic facts.

---

## Recommended Proof Architecture

### Path A: Most promising
1. Define `powerSum`, `newtonRatio`, `newtonDefect`, and `renyiEntropy`.
2. Prove `powerSum_eq_poly_esymm` by Newton–Girard induction.
3. Prove a uniform polynomial approximation theorem for `h_α` on `[δ,1-δ]`.
4. Sum over coordinates and substitute the power-sum-as-esymm polynomial.
5. Derive explicit entropy surrogates `Φ_N`.
6. Use Newton inequalities to prove stability / monotonicity statements for these surrogates.

This path gives both theorem-level mathematics and an implementable algorithm.

### Path B: Analytic-first
1. Approximate `h_α` by centered polynomial expansions around `1/2`.
2. Rewrite centered moments via ordinary power sums.
3. Express power sums via Newton–Girard.
4. Use Lorentzian/Newton inequalities to compress the resulting formulas.

This may produce cleaner formulas for `α = 1, 2`.

### Path C: Ratio-profile-first
1. Study the geometry of sequences with `ρ_k ≈ 1`.
2. Show approximate geometricity of `e_k`.
3. Deduce control of low-order moments and hence entropy.
4. Compare with empirical free-fermion data.

This is conceptually daring and could lead to the strongest novelty, but it is riskier as a first formal pass.

---

## Verified Algorithm / Computational Deliverable

You must produce not only theorems but a **verified computational method**.

### Required algorithm
Implement an algorithm that:
1. takes as input either a spectrum `λ : Fin m → ℝ` or its elementary symmetric data,
2. computes the first `N` elementary symmetric polynomials,
3. converts them to power sums using Newton–Girard,
4. evaluates a polynomial approximation to `h_α`,
5. returns a certified approximation interval for `S_α`.

Possible Lean signature:
```lean
def certifiedRenyiApprox
    (α : ℝ) (N : ℕ) (λ : Fin m → ℝ) : ℝ × ℝ := ...
```
where the pair is `(approximation, error_bound)`.

You should prove a correctness theorem of the form:
```lean
theorem certifiedRenyiApprox_spec
    {m N : ℕ} {α δ : ℝ}
    (hα : 0 < α) (hα_ne : α ≠ 1) (hδ : 0 < δ ∧ δ < 1 / 2)
    (λ : Fin m → ℝ)
    (hλ : ∀ i, δ ≤ λ i ∧ λ i ≤ 1 - δ) :
    let out := certifiedRenyiApprox α N λ
    |renyiEntropy α λ - out.1| ≤ out.2
```

This algorithm is scientifically central: it is the first prototype for **entropy estimation from Lorentzian compressed data**.

---

## demo.py Requirements

Write `demo.py` that:

1. generates free-fermion correlation spectra from simple 1D tight-binding or Toeplitz correlation matrices,
2. computes:
   - exact `S_α` for `α ∈ {0.5, 1, 2}`,
   - `e_k`,
   - Newton ratios `ρ_k`,
   - surrogate predictions from your certified approximation,
3. plots:
   - true vs predicted entropy,
   - error vs truncation order `N`,
   - ratio profiles `k ↦ log ρ_k`,
4. tests extrapolation from 1D-trained surrogates to a small 2D model.

The demo should make the conjecture falsifiable, not merely illustrative.

---

## Testable Prediction / Falsifiable Conjecture

You must include at least one conjecture with a clear computational disproof criterion.

### Prediction A
For gapped 1D free-fermion chains and fixed `α ∈ {1,2}`, there exists a degree-`d` polynomial `P_α` such that
\[
|S_\alpha - P_\alpha(\log \rho_1,\dots,\log \rho_K)| \le C_\alpha K^{-\beta}
\]
uniformly over subsystem sizes up to `L`, for some `β > 0`.

**Disproof criterion:** If regression error fails to decrease with increasing `K` across growing training windows, the conjecture is false in this form.

### Prediction B
For area-law compatible spectra, the second Rényi entropy is asymptotically determined by the first `O(1)` Newton ratios.

**Disproof criterion:** Construct sequences with bounded entropy but diverging prediction error under all fixed-window ratio models.

These predictions are strong enough to fail. Good. That is real science.

---

## Cross-Domain Connections You Must Emphasize

1. **Quantum information ↔ algebraic combinatorics**  
   Entanglement entropy becomes a spectral statistic controlled by elementary symmetric functions and Newton identities.

2. **Quantum information ↔ Lorentzian / Hodge theory**  
   Log-concavity constraints on `e_k` coming from Lorentzian polynomial ideas become physical constraints on admissible entanglement spectra.

3. **Quantum information ↔ approximation theory**  
   Entropy estimation reduces to uniform approximation of `h_α` by polynomials, turning nonlinear many-body observables into finite algebraic summaries.

4. **Potential bridge to statistical mechanics**  
   Newton-ratio profiles may serve as compressed order parameters for Gaussian states, suggesting a new language for phase diagnostics.

5. **Potential bridge to numerical linear algebra**  
   If entropy can be estimated from low-order symmetric invariants, one may bypass repeated diagonalization in large-scale fermionic simulations.

---

## Application Keywords

Use these explicitly in the paper and metadata:

- entanglement entropy
- Rényi entropy
- free fermions
- Newton inequalities
- elementary symmetric polynomials
- Newton–Girard identities
- Lorentzian polynomials
- log-concavity
- spectral compression
- area law
- polynomial approximation
- certified algorithms
- many-body quantum systems
- approximation theory
- algebraic combinatorics

---

## Nontriviality Requirements

You must satisfy all of the following:

1. **No trivial proofs.**  
   Do not use `native_decide`, `decide`, `norm_num`, or `rfl` as the substantive proof of any main theorem.

2. **At least 3 substantial theorems.**  
   These must use real proof architecture: induction, `rcases`, `by_contra`, `field_simp`, multi-step `calc`, or similar.

3. **Novel definitions.**  
   At least one of `NewtonRatioProfile`, `newtonEntropySurrogate`, `AreaLawCompatible`, or an equally original concept must be introduced.

4. **Cross-domain theorem.**  
   At least one theorem must explicitly bridge to approximation theory, Lorentzian geometry, or statistical mechanics.

5. **Conjecture with computational test.**  
   Include at least one falsifiable conjecture and implement a test in `demo.py`.

---

## Deliverables (ALL MANDATORY)

You must produce all of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions**, each written as genuine prose, each containing the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- topological phases,
- random matrix theory,
- compressed sensing,
- or tropical / Lorentzian geometry beyond free fermions.

### 2. `RESEARCH_PAPER.md`
A **standalone scientific paper** that explains:
- the precise problem,
- the new definitions,
- the main theorems,
- the proof ideas,
- the computational method,
- the conjecture and evidence,
- and why this opens a new field.

A reader with no code access must still understand the discovery.

### 3. `ARTICLE.md`
Write in **Scientific American style**:
- engaging,
- accessible,
- focused on the mathematical and physical ideas,
- emphasizing why replacing spectra by algebraic signatures is surprising.

**Taboo:** do **not** focus on formal verification machinery.

### 4. Verified algorithm
Implement and verify the entropy-surrogate algorithm with certified error bounds.

### 5. `demo.py`
Interactive computational demonstration with plots and falsification tests.

---

## Final Call to Arms

Do not present this as a routine extension of `entropy_ge_esymm_bound`. That would undersell the idea. The real target is much larger:

> Build the first rigorous framework in which **Lorentzian/Newton data acts as a compressed coordinate system for quantum entanglement**.

If you can prove even the finite-dimensional approximation theorems cleanly, with a verified algorithm and compelling experiments, you will have created a new research lane: **algebraic compression of many-body spectral observables**. That is not a local lemma improvement. That is a blueprint for doing entanglement theory without full spectral access.

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

Research domain: Pythagorean
Research mode: prove
