## YOUR ASSIGNMENT: Prime-Spectral Rate–Distortion Reconstruction for Closure-Generated Proof Semirings via Free-Energy Quantization

Work in the finite-spectrum regime and make the construction completely concrete in Lean 4 using `Finset`, `ℝ`, and computable minimization over finite sets. The core objective is to turn the existing prime-spectrum / free-energy separation infrastructure into a genuine rate–distortion theory with optimal codebooks and a reconstruction map into quotient/nucleus semantics.

### 1. Core data and exact formal targets

You should **specialize aggressively to a finite prime spectrum** so that the main existence theorem is genuinely provable in Lean without analytic compactness machinery.

Use a finite index type for spectral states:
```lean
structure BetaParam where
  val : ℝ
deriving DecidableEq

abbrev PrimeBetaState (ι : Type _) := ι × BetaParam
```

For the semantic objects being separated, use a concrete pair type:
```lean
abbrev Pair (S : Type _) := S × S
```

Assume a distortion kernel:
```lean
variable {S ι : Type _} [DecidableEq S] [Fintype ι] [DecidableEq ι]

variable (gap : PrimeBetaState ι → Pair S → ℝ)
```

Define the “full spectral gap” and “restricted gap” by finite suprema over `Finset.univ`. Since `Finset.sup` is cleaner over an ordered type with a bottom, either:
- work with `ℝ≥0` if your existing gap infrastructure is nonnegative, or
- define via `s.sup id` after coercing to `WithBot ℝ`,
- or, most simply, use `Finset.max'` with a nonempty witness because `Fintype ι` gives nonemptiness only if `[Nonempty ι]`; if nonemptiness is awkward, define the spectrum hypothesis with an explicit finite nonempty `Finset`.

A robust Lean-friendly route is:

```lean
variable (spec : Finset (PrimeBetaState ι))
variable (hspec : spec.Nonempty)

def fullGap (x : Pair S) : ℝ :=
  spec.sup' hspec (fun ω => gap ω x)

def restrictedGap (C : Finset (PrimeBetaState ι)) (x : Pair S) : ℝ :=
  if hC : C.Nonempty then C.sup' hC (fun ω => gap ω x) else 0

def distortion (C : Finset (PrimeBetaState ι)) (x : Pair S) : ℝ :=
  fullGap gap spec hspec x - restrictedGap gap C x
```

Then define the codebook predicate and coding number over a **finite training/evaluation set** of pairs:
```lean
variable (pairs : Finset (Pair S))

def IsEpsilonCodebook (ε : ℝ) (C : Finset (PrimeBetaState ι)) : Prop :=
  ∀ x ∈ pairs, distortion gap spec hspec C x ≤ ε

def codingNumber (ε : ℝ) : ℕ :=
  sInf {n : ℕ | ∃ C : Finset (PrimeBetaState ι), C.card = n ∧ IsEpsilonCodebook gap spec hspec pairs ε C}
```

If `sInf` over `ℕ` is annoying, replace `codingNumber` by a minimization over the finite powerset:
```lean
def admissibleCodebooks (ε : ℝ) : Finset (Finset (PrimeBetaState ι)) :=
  spec.powerset.filter (fun C => IsEpsilonCodebook gap spec hspec pairs ε C)

def codingNumber (ε : ℝ) : ℕ :=
  if h : (admissibleCodebooks gap spec hspec pairs ε).Nonempty then
    ((admissibleCodebooks gap spec hspec pairs ε).image Finset.card).min' (by
      simpa using Finset.Nonempty.image _ h)
  else
    spec.card + 1
```

This finite-powerset definition is much more Lean-tractable and should be your default.

### 2. Main theorem package: exact theorem statements

Prove the following with precise Lean signatures.

#### A. Existence of an optimal codebook on a finite spectrum
This is the foundational finite combinatorial compactness theorem.

```lean
theorem exists_optimal_codebook_of_finite_spectrum
    (ε : ℝ) :
    ∃ C : Finset (PrimeBetaState ι),
      C ⊆ spec ∧
      IsEpsilonCodebook gap spec hspec pairs ε C ∧
      C.card = codingNumber gap spec hspec pairs ε := by
  ...
```

If exact existence fails because there is no `ε`-codebook, prove the sharpened alternative:

```lean
theorem exists_optimal_codebook_of_finite_spectrum_or_none
    (ε : ℝ) :
    (∃ C : Finset (PrimeBetaState ι),
      C ⊆ spec ∧
      IsEpsilonCodebook gap spec hspec pairs ε C ∧
      C.card = codingNumber gap spec hspec pairs ε)
    ∨ codingNumber gap spec hspec pairs ε = spec.card + 1 := by
  ...
```

But the preferred formulation is to first prove that `spec` itself is always a `0`-codebook, hence an `ε`-codebook for `ε ≥ 0`, and then impose `hε : 0 ≤ ε`:

```lean
theorem spec_is_zero_codebook :
    IsEpsilonCodebook gap spec hspec pairs 0 spec := by
  ...

theorem exists_optimal_codebook_of_finite_spectrum
    (ε : ℝ) (hε : 0 ≤ ε) :
    ∃ C : Finset (PrimeBetaState ι),
      C ⊆ spec ∧
      IsEpsilonCodebook gap spec hspec pairs ε C ∧
      C.card = codingNumber gap spec hspec pairs ε := by
  ...
```

#### B. Monotonicity of coding number
More tolerance should never require more codewords.

```lean
theorem codingNumber_mono {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) :
    codingNumber gap spec hspec pairs ε₂ ≤ codingNumber gap spec hspec pairs ε₁ := by
  ...
```

This is the formal rate–distortion monotonicity law.

#### C. Zero distortion iff complete separation
You need a precise notion of “complete separation on the dataset” by a codebook:

```lean
def CompleteSeparation (C : Finset (PrimeBetaState ι)) : Prop :=
  ∀ x ∈ pairs, restrictedGap gap C x = fullGap gap spec hspec x
```

Then prove:
```lean
theorem zero_distortion_iff_complete_separation (C : Finset (PrimeBetaState ι)) :
    (∀ x ∈ pairs, distortion gap spec hspec C x = 0) ↔ CompleteSeparation gap spec hspec pairs C := by
  ...
```

If subtraction over `ℝ` causes issues because you need `restrictedGap ≤ fullGap`, first prove the domination lemma:

```lean
theorem restrictedGap_le_fullGap (C : Finset (PrimeBetaState ι)) (hC : C ⊆ spec) :
    ∀ x, restrictedGap gap C x ≤ fullGap gap spec hspec x := by
  ...
```

Then use `sub_eq_zero.mp` after order reasoning.

#### D. Greedy approximation theorem
Define the one-step gain of adding a spectral state:
```lean
def totalDistortion (C : Finset (PrimeBetaState ι)) : ℝ :=
  ∑ x in pairs, distortion gap spec hspec C x

def marginalGain (C : Finset (PrimeBetaState ι)) (ω : PrimeBetaState ι) : ℝ :=
  totalDistortion gap spec hspec pairs C - totalDistortion gap spec hspec pairs (insert ω C)
```

Define a greedy sequence recursively over `ℕ`; if full recursion is cumbersome, define the `k`-th greedy codebook noncomputably by choosing a maximizer from the finite remainder:
```lean
noncomputable def greedyStep (C : Finset (PrimeBetaState ι)) : Finset (PrimeBetaState ι) := ...
noncomputable def greedyCodebook : ℕ → Finset (PrimeBetaState ι)
| 0 => ∅
| k+1 => greedyStep gap spec hspec pairs (greedyCodebook k)
```

Then prove at least the finite-step approximation guarantee:

```lean
theorem greedy_codebook_approx :
    ∀ k : ℕ,
      ∃ C : Finset (PrimeBetaState ι),
        C ⊆ spec ∧
        C.card ≤ k ∧
        totalDistortion gap spec hspec pairs C
          ≤ totalDistortion gap spec hspec pairs (greedyCodebook gap spec hspec pairs k) := by
  ...
```

A stronger and more meaningful theorem, if you can get the combinatorics to go through, is the standard averaging bound:

```lean
theorem greedy_codebook_approx_vs_opt
    (k : ℕ) :
    totalDistortion gap spec hspec pairs (greedyCodebook gap spec hspec pairs k)
      ≤ (1 - (k : ℝ) / spec.card) * totalDistortion gap spec hspec pairs ∅ := by
  ...
```

or, better, relative to an optimal `k`-codebook:
```lean
theorem greedy_codebook_approx_vs_opt
    (k : ℕ) :
    ∃ Copt : Finset (PrimeBetaState ι),
      Copt ⊆ spec ∧
      Copt.card ≤ k ∧
      totalDistortion gap spec hspec pairs (greedyCodebook gap spec hspec pairs k)
        ≤ totalDistortion gap spec hspec pairs Copt
          + ((spec.card - k : ℕ) : ℝ) / spec.card * totalDistortion gap spec hspec pairs ∅ := by
  ...
```

If the full submodular approximation is too ambitious, prove the weaker but still valuable theorem:
- greedy total distortion is nonincreasing in `k`,
- each step is at least as good as any single insertion into the previous codebook,
- greedy attains optimality when `k = spec.card`.

Those are already enough to support a finite constructive reconstruction theorem.

#### E. Reconstruction theorem into quotient/nucleus semantics
Package a semantic reconstruction map from a codebook by taking the profile of gap values on the selected states:

```lean
def reconstruct (C : Finset (PrimeBetaState ι)) (x : Pair S) :
    PrimeBetaState ι → ℝ :=
  fun ω => if ω ∈ C then gap ω x else 0
```

If you already have a quotient/nucleus semantic object in the catalog, define a map into that object instead. At minimum prove a factorization statement saying that if two pairs have identical restricted spectral profiles on `C`, then they are indistinguishable by the reconstructed semantics.

A generic exact statement:

```lean
def SameCodeProfile (C : Finset (PrimeBetaState ι)) (x y : Pair S) : Prop :=
  ∀ ω ∈ C, gap ω x = gap ω y

theorem reconstruction_sound
    (C : Finset (PrimeBetaState ι)) :
    ∀ {x y : Pair S}, SameCodeProfile gap C x y →
      restrictedGap gap C x = restrictedGap gap C y := by
  ...
```

Then the approximate semantic reconstruction theorem:

```lean
theorem approximate_reconstruction
    {ε : ℝ} (C : Finset (PrimeBetaState ι))
    (hC : IsEpsilonCodebook gap spec hspec pairs ε C) :
    ∀ x ∈ pairs,
      fullGap gap spec hspec x - ε ≤ restrictedGap gap C x := by
  ...
```

This is the exact finite rate–distortion reconstruction inequality: the codebook loses at most `ε` separation power.

If your quotient/nucleus semantics infrastructure exposes a semantic pseudometric `dSem`, push further and prove:
```lean
theorem approximate_reconstruction_in_quotient
    {ε : ℝ} (C : Finset (PrimeBetaState ι))
    (hC : IsEpsilonCodebook gap spec hspec pairs ε C) :
    ∀ x ∈ pairs,
      dSem (fullSemanticState x) (reconstructedSemanticState C x) ≤ ε := by
  ...
```
Use whatever concrete semantic type is already available in the catalog.

---

### 3. Proof architecture: 5 concrete steps

#### Step 1: Make finite suprema behave algebraically
First prove the monotonicity of restricted suprema under inclusion:
```lean
theorem restrictedGap_mono {C D : Finset (PrimeBetaState ι)}
    (hCD : C ⊆ D) :
    ∀ x, restrictedGap gap C x ≤ restrictedGap gap D x := by
  ...
```

Key tools:
- `Finset.sup'_le_iff`
- `Finset.le_sup'`
- case split on `C.Nonempty`, `D.Nonempty`

Then deduce:
```lean
theorem restrictedGap_le_fullGap (C : Finset (PrimeBetaState ι)) (hC : C ⊆ spec) :
    ∀ x, restrictedGap gap C x ≤ fullGap gap spec hspec x := by
  exact restrictedGap_mono ... 
```

This one lemma unlocks `distortion ≥ 0`, `zero_distortion_iff_complete_separation`, and monotonicity of total distortion.

#### Step 2: Reduce existence of optimal codebooks to minimization over the finite powerset
The key combinatorial insight is that all admissible codebooks lie in `spec.powerset`, hence the optimization domain is finite. Define:
```lean
def admissibleCodebooks (ε : ℝ) : Finset (Finset (PrimeBetaState ι)) :=
  spec.powerset.filter (fun C => IsEpsilonCodebook gap spec hspec pairs ε C)
```

Then prove:
1. `C ∈ admissibleCodebooks ... → C ⊆ spec`
2. if `0 ≤ ε`, then `spec ∈ admissibleCodebooks ...`
3. therefore the image under `Finset.card` is nonempty
4. choose a minimizer using `Finset.min'`

Critical lemmas:
- `Finset.mem_filter`
- `Finset.mem_powerset`
- `Finset.min'_mem`
- an image/card minimality lemma:
```lean
theorem min_card_le_card_of_mem ...
```

This is the cleanest finite analog of compactness/existence of minimizers.

#### Step 3: Prove monotonicity of coding number by inclusion of admissible families
Show:
```lean
theorem IsEpsilonCodebook_mono {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) :
    ∀ {C}, IsEpsilonCodebook gap spec hspec pairs ε₁ C →
           IsEpsilonCodebook gap spec hspec pairs ε₂ C := by
  ...
```

Then prove:
```lean
admissibleCodebooks gap spec hspec pairs ε₁ ⊆ admissibleCodebooks gap spec hspec pairs ε₂
```
for `ε₁ ≤ ε₂`, and use minimal-cardinality comparison to derive `codingNumber_mono`.

This theorem is not merely formal bookkeeping: it is the rate–distortion monotonicity law expressing that relaxed fidelity lowers coding complexity.

#### Step 4: Characterize zero distortion as exact semantic sufficiency
After proving `restrictedGap ≤ fullGap`, show:
```lean
distortion ... C x = 0 ↔ restrictedGap ... C x = fullGap ... x
```
using:
- `sub_eq_zero`
- `le_antisymm`
- or direct `linarith` once both inequalities are present

Then lift pointwise equality over all `x ∈ pairs` to:
```lean
(∀ x ∈ pairs, distortion ... C x = 0) ↔ CompleteSeparation ...
```

This theorem is the semantic heart of the program: a finite codebook has zero distortion exactly when it preserves all derivability-separation witnesses on the dataset. It is the exact analog of lossless compression in the prime-spectral world.

#### Step 5: Greedy approximation via maximal marginal gain on a finite set
For each `C ⊆ spec`, define the candidate remainder:
```lean
(spec.eraseDuplicates? -- or simply spec.filter fun ω => ω ∉ C)
```
and choose `ω` maximizing `marginalGain C ω`. Then prove:
1. `greedyCodebook k ⊆ spec`
2. `card (greedyCodebook k) ≤ k`
3. `totalDistortion` is nonincreasing along the greedy sequence
4. if `C` is any `k`-element codebook, then at each step greedy gains at least the average gain available from elements of `C \ greedyCodebook i`

If a full submodular theorem is too hard, prove the weaker finite domination theorem:
```lean
theorem greedyStep_best_single_insertion
    (C : Finset (PrimeBetaState ι)) :
    ∀ ω ∈ spec,
      totalDistortion ... (greedyStep ... C)
        ≤ totalDistortion ... (insert ω C) := by
  ...
```
This already shows the greedy step is locally optimal among all one-state refinements.

---

### 4. Key structural lemmas worth proving first

These should be standalone lemmas in the file; they will simplify everything else.

```lean
theorem distortion_nonneg
    (C : Finset (PrimeBetaState ι)) (hC : C ⊆ spec) :
    ∀ x, 0 ≤ distortion gap spec hspec C x := by
  ...
```

```lean
theorem spec_exact
    (x : Pair S) :
    restrictedGap gap spec x = fullGap gap spec hspec x := by
  ...
```
If needed, define `restrictedGap` with an explicit nonempty proof when `C = spec`.

```lean
theorem spec_is_epsilon_codebook (ε : ℝ) (hε : 0 ≤ ε) :
    IsEpsilonCodebook gap spec hspec pairs ε spec := by
  ...
```

```lean
theorem totalDistortion_mono
    {C D : Finset (PrimeBetaState ι)} (hCD : C ⊆ D) (hD : D ⊆ spec) :
    totalDistortion gap spec hspec pairs D ≤ totalDistortion gap spec hspec pairs C := by
  ...
```

```lean
theorem completeSeparation_iff_zero_totalDistortion
    (C : Finset (PrimeBetaState ι)) (hC : C ⊆ spec) :
    CompleteSeparation gap spec hspec pairs C
      ↔ totalDistortion gap spec hspec pairs C = 0 := by
  ...
```
This is very useful for passing from pointwise to global optimization.

---

### 5. Why this matters to the research program

This is not just another finite optimization exercise. It is the first genuine **constructive rate–distortion theory for proof semantics** in which:

- **Prime states become codewords**: spectral witnesses of non-derivability are compressed into finite semantic dictionaries.
- **Free-energy separation becomes distortion**: semantic fidelity is measured by loss of separation power, not by an arbitrary metric.
- **Optimal codebooks become computable**: the finite-spectrum hypothesis turns abstract Stone duality into an actual search problem over `powerset`.
- **Reconstruction becomes semantic factorization**: the compressed object still controls quotient/nucleus semantics up to explicit error `ε`.

This opens three major directions immediately:
1. **Algorithmic countermodel extraction**: minimal codebooks are compressed certificates of non-derivability and should support efficient witness extraction.
2. **Semantic channel capacity for proof systems**: `codingNumber ε` is a concrete rate function, suggesting a Shannon-style theory of logical information flow.
3. **Thermodynamic/tropical duality**: the `sup`-based gap aggregation is max-plus in spirit, so this theory should interact naturally with tropical convexity and free-energy variational principles.

In other words: you are turning spectral completeness into **compressible semantics**. That is a field-opening move.

---

### 6. If the full theorem is too hard, prioritize this strongest provable core

If necessary, prove the following reduced but still substantial package:

```lean
theorem exists_optimal_codebook_of_finite_spectrum
    (ε : ℝ) (hε : 0 ≤ ε) :
    ∃ C : Finset (PrimeBetaState ι),
      C ⊆ spec ∧
      IsEpsilonCodebook gap spec hspec pairs ε C ∧
      ∀ D : Finset (PrimeBetaState ι),
        D ⊆ spec →
        IsEpsilonCodebook gap spec hspec pairs ε D →
        C.card ≤ D.card := by
  ...
```

```lean
theorem codingNumber_mono {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) :
    codingNumber gap spec hspec pairs ε₂ ≤ codingNumber gap spec hspec pairs ε₁ := by
  ...
```

```lean
theorem zero_distortion_iff_complete_separation
    (C : Finset (PrimeBetaState ι)) (hC : C ⊆ spec) :
    (∀ x ∈ pairs, distortion gap spec hspec C x = 0) ↔
    CompleteSeparation gap spec hspec pairs C := by
  ...
```

```lean
theorem approximate_reconstruction
    {ε : ℝ} (C : Finset (PrimeBetaState ι))
    (hCsub : C ⊆ spec)
    (hC : IsEpsilonCodebook gap spec hspec pairs ε C) :
    ∀ x ∈ pairs, fullGap gap spec hspec x - ε ≤ restrictedGap gap C x := by
  ...
```

This reduced package is already enough to establish a rigorous finite prime-spectral rate–distortion theory.

---

### 7. Deliverable structure

Produce the Lean development so that the file contains, in order:

1. concrete definitions (`BetaParam`, `PrimeBetaState`, `Pair`, `fullGap`, `restrictedGap`, `distortion`)
2. codebook and coding number definitions
3. monotonicity and domination lemmas for restricted/full gap
4. existence of optimal codebooks by finite powerset minimization
5. `codingNumber_mono`
6. `zero_distortion_iff_complete_separation`
7. greedy codebook construction and at least one nontrivial approximation theorem
8. approximate reconstruction theorem into code-profile / quotient / nucleus semantics

Also produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next theorems, for example:
- a variational formula identifying `codingNumber` with a prime free-energy capacity,
- a submodularity theorem for total distortion giving a true `(1 - e^{-k/n})` greedy guarantee,
- a semantic Shannon theorem for proof semirings,
- a tropicalization of the distortion functional,
- an algorithm extracting minimal-energy countermodels from optimal codebooks.

### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Bridges
Research mode: prove
