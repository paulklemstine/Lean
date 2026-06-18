

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new

## YOUR ASSIGNMENT: Vector-Valued Ultrametric Neural Network Certification via Width-Free Operator Lipschitz Calculus

Create `Speculative/AutoResearch/Bridges/UltrametricVectorCertification.lean`, and if useful also extend `Speculative/AutoResearch/Bridges/UltrametricDeepLearning.lean`, with a self-contained formal development of vector-valued ultrametric neural certification over a nonarchimedean field. The central objective is to prove a width-free certified robustness theorem for layered affine-activation networks acting on finite coordinate spaces endowed with the sup norm, where the final certificate depends on operator-level Lipschitz data and a valuation-style output margin, but not explicitly on hidden widths.

Work at maximal typeclass generality whenever Mathlib allows it. The core ambient type should be of the form:

```lean
variable {K : Type*} [NormedField K] [IsUltrametricDist K]
variable {ι κ ν : Type*} [Fintype ι] [Fintype κ] [Fintype ν]
```

If the existing catalog uses a custom class such as `IsUltrametricNormedField K`, prefer compatibility wrappers and lemmas bridging to `IsUltrametricDist K`. If necessary, define:

```lean
class IsUltrametricNormedField (K : Type*) extends NormedField K : Prop :=
(ultra : ∀ x y : K, ‖x + y‖ ≤ max ‖x‖ ‖y‖)
```

and prove conversion lemmas from/to the already available infrastructure in the local file.

The file must contain a coherent narrative with at least 10 new definitions/structures and 20+ theorems/lemmas, including the named target lemmas below. Use theorem names and doc comments with explicit ML / cryptographic / quantum keywords such as `lipschitz_certified_robustness`, `post_quantum`, `quantum_stability`, `lattice_margin`, `valuation_barrier`. Bridge at least the domains:
- nonarchimedean / p-adic analysis,
- machine learning certification,
- operator / matrix norm calculus,
and, where natural, mention lattice/post-quantum or quantum stability analogies in doc comments and theorem names.

### Core definitions to implement

Use finite coordinate function spaces `ι → K` and the sup norm induced by `Finset.univ.sup`. Avoid requiring full matrix APIs if coordinatewise finite sums are easier in Lean.

Define at least the following, with exact or near-exact signatures:

```lean
/-- Sup norm on finite coordinate vectors; Bridge: ultrametric analysis to certified ML. -/
def vecSupNorm (x : ι → K) : ℝ :=
  Finset.univ.sup (fun i => ‖x i‖)

/-- Entrywise sup distance. -/
def vecSupDist (x y : ι → K) : ℝ :=
  vecSupNorm (fun i => x i - y i)

/-- Width-free operator seminorm for a kernel `A : κ → ι → K`,
measured by row sup-sums / row sup-max depending on the available ultrametric bound. -/
def opSupNorm (A : κ → ι → K) : ℝ :=
  Finset.univ.sup (fun j => Finset.univ.sup (fun i => ‖A j i‖))

/-- Affine vector layer over an ultrametric field. -/
structure PadicAffineVecLayer (K : Type*) [NormedField K] [IsUltrametricDist K]
    (ι κ : Type*) [Fintype ι] [Fintype κ] where
  weight : κ → ι → K
  bias   : κ → K

/-- Coordinatewise activation with explicit scalar Lipschitz constant. -/
structure UltrametricActivation (K : Type*) [NormedField K] [IsUltrametricDist K] where
  toFun : K → K
  lipConst : ℝ
  lip_nonneg : 0 ≤ lipConst
  ultra_lipschitz : ∀ x y, ‖toFun x - toFun y‖ ≤ lipConst * ‖x - y‖

/-- One affine-activation block on vectors. -/
structure PadicLayeredVecMap (K : Type*) [NormedField K] [IsUltrametricDist K]
    (ι κ : Type*) [Fintype ι] [Fintype κ] where
  layer : PadicAffineVecLayer K ι κ
  act   : UltrametricActivation K

/-- Evaluation of an affine layer before activation. -/
def evalAffineVec (L : PadicAffineVecLayer K ι κ) (x : ι → K) : κ → K :=
  fun j => (∑ i, L.weight j i * x i) + L.bias j

/-- Evaluation of a layered block. -/
def evalVec (L : PadicLayeredVecMap K ι κ) (x : ι → K) : κ → K :=
  fun j => L.act.toFun (evalAffineVec L.layer x j)

/-- Layer Lipschitz constant in sup norm. -/
def layerLip (L : PadicLayeredVecMap K ι κ) : ℝ :=
  L.act.lipConst * opSupNorm L.layer.weight

/-- Sequential composition of compatible layered maps. -/
def composeLayeredVec
    (L₂ : PadicLayeredVecMap K κ ν) (L₁ : PadicLayeredVecMap K ι κ) :
    (ι → K) → (ν → K) :=
  fun x => evalVec L₂ (evalVec L₁ x)

/-- A network as a list/fold of layers on a fixed width, or an inductive heterogeneous chain if feasible. -/
def networkLip : List (PadicLayeredVecMap K ι ι) → ℝ
| []      => 1
| L :: t  => layerLip L * networkLip t

/-- Folded evaluation of a same-width network. -/
def evalNetwork : List (PadicLayeredVecMap K ι ι) → (ι → K) → (ι → K)
| []      => id
| L :: t  => fun x => evalNetwork t (evalVec L x)

/-- Output margin relative to a distinguished label against all competitors. -/
def outputMargin (y : ι → K) (good : ι) : ℝ :=
  Finset.univ.inf' (by simpa using Finset.univ_nonempty)
    (fun j => if h : j = good then Real.top else ‖y good - y j‖)

/-- Certified radius from margin and network Lipschitz constant. -/
def certifiedRadius (margin lip : ℝ) : ℝ :=
  margin / (2 * lip)

/-- Predicate expressing robust label stability inside a sup-ball. -/
def LabelStableOnBall
    (f : (ι → K) → (ι → K)) (x : ι → K) (good : ι) (r : ℝ) : Prop :=
  ∀ z, vecSupDist z x < r → ∀ j, j ≠ good → ‖f z good - f z j‖ > 0
```

If `Real.top` is inconvenient in `outputMargin`, replace by a competitor-only finite infimum over `Finset.univ.erase good`, and prove the equivalent characterization. This is preferred. In that case define:

```lean
def competitorMargin [DecidableEq ι] (y : ι → K) (good : ι) : ℝ :=
  Finset.inf' (Finset.univ.erase good) (by ...)
    (fun j => ‖y good - y j‖)
```

Also introduce at least 5 additional original helper definitions, e.g.
- `ArgmaxSeparated`
- `UltrametricCertifiedClassifier`
- `valuationGap`
- `postQuantumNoiseBudget`
- `quantumStabilityRadius`
- `LayerCascadeBound`
- `SupBall`

These should not be cosmetic: each should support at least one theorem.

### Main target theorems and exact formal goals

You must prove the named lemmas below, or stronger variants from which these follow immediately.

#### 1. Ultrametric matrix-vector / kernel bound
```lean
theorem ultrametric_mulVec_bound
    (A : κ → ι → K) (x : ι → K) :
    vecSupNorm (fun j => ∑ i, A j i * x i)
      ≤ opSupNorm A * vecSupNorm x
```

A stronger rowwise version is highly desirable:
```lean
theorem ultrametric_row_bound
    (A : κ → ι → K) (x : ι → K) (j : κ) :
    ‖∑ i, A j i * x i‖ ≤ opSupNorm A * vecSupNorm x
```

If the existing catalog theorem `ultrametric_entrywise_norm_submult` has a more natural statement, first prove a conversion lemma showing it implies the rowwise bound.

#### 2. Affine map sup-Lipschitz
```lean
theorem affine_sup_lipschitz
    (L : PadicAffineVecLayer K ι κ) :
    ∀ x y, vecSupDist (evalAffineVec L x) (evalAffineVec L y)
      ≤ opSupNorm L.weight * vecSupDist x y
```

Bias cancellation should be explicit in the proof.

#### 3. Coordinatewise activation sup-Lipschitz
```lean
theorem activation_sup_lipschitz
    (φ : UltrametricActivation K) :
    ∀ x y : ι → K, vecSupDist (fun i => φ.toFun (x i)) (fun i => φ.toFun (y i))
      ≤ φ.lipConst * vecSupDist x y
```

Also prove the pointwise form and a “nonexpansive” corollary for `lipConst ≤ 1`.

#### 4. Layered vector map Lipschitz bound
```lean
theorem layeredVec_lipschitz_bound
    (L : PadicLayeredVecMap K ι κ) :
    ∀ x y, vecSupDist (evalVec L x) (evalVec L y)
      ≤ layerLip L * vecSupDist x y
```

#### 5. Network composition bound
```lean
theorem networkLip_fold_bound
    (net : List (PadicLayeredVecMap K ι ι)) :
    ∀ x y, vecSupDist (evalNetwork net x) (evalNetwork net y)
      ≤ networkLip net * vecSupDist x y
```

This should be by induction on the list, with one proof using `simpa [evalNetwork, networkLip]` and another helper theorem for composition:
```lean
theorem lipschitz_compose_sup
    {f g : (ι → K) → (ι → K)} {Lf Lg : ℝ}
    (hf : ∀ x y, vecSupDist (f x) (f y) ≤ Lf * vecSupDist x y)
    (hg : ∀ x y, vecSupDist (g x) (g y) ≤ Lg * vecSupDist x y) :
    ∀ x y, vecSupDist (fun _ => sorry) (fun _ => sorry) ≤ (Lg * Lf) * vecSupDist x y
```
Do not leave placeholders; formulate composition correctly:
```lean
theorem lipschitz_compose_sup
    {f g : (ι → K) → (ι → K)} {Lf Lg : ℝ}
    (hf : ∀ x y, vecSupDist (f x) (f y) ≤ Lf * vecSupDist x y)
    (hg : ∀ x y, vecSupDist (g x) (g y) ≤ Lg * vecSupDist x y) :
    ∀ x y, vecSupDist (g (f x)) (g (f y)) ≤ (Lg * Lf) * vecSupDist x y
```

#### 6. Margin stability under perturbation
Define a margin notion over a chosen “correct” coordinate and prove its perturbative stability.

```lean
theorem valuation_margin_stable
    [DecidableEq ι]
    (f : (ι → K) → (ι → K)) (L : ℝ)
    (hLip : ∀ x y, vecSupDist (f x) (f y) ≤ L * vecSupDist x y)
    (x z : ι → K) (good : ι)
    (hL : 0 < L)
    (hclose : vecSupDist z x < competitorMargin (f x) good / (2 * L)) :
    ∀ j, j ≠ good → ‖f z good - f z j‖ > 0
```

This theorem is the ultrametric certification engine. It should use the ultrametric triangle inequality in the form
`‖a - c‖ ≤ max ‖a - b‖ ‖b - c‖`
to compare perturbed class gaps with the original margin.

A stronger and aesthetically better version is:
```lean
theorem competitorMargin_perturbation
    [DecidableEq ι]
    (f : (ι → K) → (ι → K)) (L : ℝ)
    (hLip : ∀ x y, vecSupDist (f x) (f y) ≤ L * vecSupDist x y)
    (x z : ι → K) (good : ι) :
    competitorMargin (f z) good
      ≥ competitorMargin (f x) good - 2 * L * vecSupDist z x
```
and then derive `valuation_margin_stable` by `linarith`. This is strongly recommended.

#### 7. Certified radius theorem for layered networks
```lean
theorem layeredVec_certified_radius
    [DecidableEq ι]
    (net : List (PadicLayeredVecMap K ι ι))
    (x : ι → K) (good : ι)
    (hLipPos : 0 < networkLip net)
    (hMargin : 0 < competitorMargin (evalNetwork net x) good) :
    LabelStableOnBall (evalNetwork net) x good
      (certifiedRadius (competitorMargin (evalNetwork net x) good) (networkLip net))
```

This is the headline theorem. The final statement should explicitly certify `lipschitz_certified_robustness` in the doc comment.

### Additional theorem targets to raise rigor and utility

Prove at least 10 of the following, ideally more:

```lean
theorem vecSupNorm_nonneg (x : ι → K) : 0 ≤ vecSupNorm x
theorem vecSupNorm_zero : vecSupNorm (fun _ : ι => (0 : K)) = 0
theorem vecSupNorm_const_le (c : K) : vecSupNorm (fun _ : ι => c) = ‖c‖
theorem vecSupDist_self (x : ι → K) : vecSupDist x x = 0
theorem vecSupDist_comm (x y : ι → K) : vecSupDist x y = vecSupDist y x
theorem vecSupDist_triangle (x y z : ι → K) :
  vecSupDist x z ≤ max (vecSupDist x y) (vecSupDist y z)
theorem vecSupDist_le_iff (x y : ι → K) (r : ℝ) :
  vecSupDist x y ≤ r ↔ ∀ i, ‖x i - y i‖ ≤ r
theorem opSupNorm_nonneg (A : κ → ι → K) : 0 ≤ opSupNorm A
theorem opSupNorm_zero : opSupNorm (fun _ _ => (0 : K)) = 0
theorem layerLip_nonneg (L : PadicLayeredVecMap K ι κ) : 0 ≤ layerLip L
theorem networkLip_nonneg (net : List (PadicLayeredVecMap K ι ι)) : 0 ≤ networkLip net
theorem networkLip_cons (L : PadicLayeredVecMap K ι ι) (net) :
  networkLip (L :: net) = layerLip L * networkLip net
theorem evalAffineVec_sub (L : PadicAffineVecLayer K ι κ) (x y : ι → K) :
  evalAffineVec L x - evalAffineVec L y = ...
theorem bias_cancels_in_affine_gap ...
theorem activation_iterate_nonexpansive ...
theorem certifiedRadius_pos {m L : ℝ} (hm : 0 < m) (hL : 0 < L) :
  0 < certifiedRadius m L
theorem certifiedRadius_mono_margin ...
theorem certifiedRadius_antitone_lip ...
theorem argmax_separated_of_positive_margin ...
theorem post_quantum_noise_budget_eq_certifiedRadius ...
theorem quantum_stability_radius_le_margin ...
```

At least several proofs must use tactics beyond `simp`:
- induction on `List` for `networkLip_fold_bound`,
- `rcases` on finite nonemptiness / erased finset membership,
- `by_contra` for positive margin implying label separation,
- `linarith` for radius/margin arithmetic,
- `field_simp` for manipulations of `margin / (2 * L)`,
- `nlinarith` if needed,
- `simpa` only as a finishing step, not the whole proof.

If index types may be empty, either add `[Nonempty ι]` hypotheses where infimums require them, or define default-safe variants. Be explicit and minimal.

### Recommended supporting definitions and structures

To make the development architecturally rich, define and use several of these:

```lean
structure UltrametricCertifiedClassifier (K : Type*) [NormedField K] [IsUltrametricDist K]
    (ι : Type*) [Fintype ι] [DecidableEq ι] where
  net : List (PadicLayeredVecMap K ι ι)
  goodLabel : (ι → K) → ι
  radiusAt : (ι → K) → ℝ

def SupBall (x : ι → K) (r : ℝ) : Set (ι → K) := {z | vecSupDist z x < r}

def valuationGap [DecidableEq ι] (y : ι → K) (i j : ι) : ℝ := ‖y i - y j‖

def ArgmaxSeparated [DecidableEq ι] (y : ι → K) (good : ι) : Prop :=
  ∀ j, j ≠ good → valuationGap y good j > 0

def LayerCascadeBound (net : List (PadicLayeredVecMap K ι ι)) : ℝ := networkLip net

def postQuantumNoiseBudget (margin lip : ℝ) : ℝ := certifiedRadius margin lip

def quantumStabilityRadius (margin lip : ℝ) : ℝ := certifiedRadius margin lip
```

Then prove equivalence / comparison theorems such as:
```lean
theorem argmaxSeparated_iff_positive_competitorMargin ...
theorem SupBall_mem_iff ...
theorem LayerCascadeBound_eq_networkLip ...
theorem postQuantumNoiseBudget_eq_certifiedRadius ...
theorem quantumStabilityRadius_eq_certifiedRadius ...
```

These are not fluff: they create reusable interfaces for future cryptographic / quantum / ML bridges.

### Proof strategy blueprint

#### Strategy A: direct finite sup calculus + ultrametric row estimate
This is the most promising and should be the main route.
1. Prove pointwise coordinate inequalities first:
   - for each row `j`, show `‖∑ i, A j i * x i‖ ≤ opSupNorm A * vecSupNorm x`,
   - use the ultrametric inequality on finite sums, likely via induction on `Finset.univ`.
2. Lift rowwise bounds to vector sup bounds using the defining `Finset.sup`.
3. For affine maps, rewrite
   ```lean
   evalAffineVec L x j - evalAffineVec L y j
   = ∑ i, L.weight j i * (x i - y i)
   ```
   by ring algebra; the bias disappears.
4. Compose with activation Lipschitz constants coordinatewise.
5. Induct on the network list to obtain multiplicative network bounds.
6. For certification, first prove the margin perturbation estimate
   `margin(z) ≥ margin(x) - 2L dist`
   and then deduce positivity for perturbations smaller than `margin/(2L)`.

Key Lean lemmas likely needed:
- `norm_mul`, `mul_le_mul_of_nonneg_left/right`,
- finite-sum induction on `Finset`,
- existing ultrametric finite-sum inequality from the catalog,
- `Finset.le_sup`, `Finset.sup_le_iff`,
- `sub_eq_add_neg`, `map_add`, `sum_sub_distrib`,
- `by_cases h : j = good`,
- `linarith`, `field_simp`.

#### Strategy B: reuse catalog theorem `padicLayeredMap_lipschitz_certified_robustness`
If the existing file already proves scalar-output certification, then:
1. Package each output coordinate as a scalar map.
2. Prove a vector sup Lipschitz theorem by taking the supremum of scalar bounds.
3. Reconstruct a vector-valued margin theorem from pairwise scalar gap controls.
4. Generalize from scalar “winner-vs-threshold” to finite-label competitor margin.

This route is elegant if the catalog is strong enough, but only use it if it reduces proof burden without sacrificing generality.

#### Strategy C: formulate a generic “sup-metric Lipschitz functoriality” layer
If repeated coordinatewise arguments become cumbersome:
1. Define a predicate
   ```lean
   def IsSupLipschitz (f : (ι → K) → (κ → K)) (L : ℝ) : Prop := ...
   ```
2. Prove closure under affine maps, coordinatewise activations, and composition.
3. Instantiate all network theorems through this abstract interface.

This gives the cleanest architecture and strongest future reusability; it is highly recommended if it does not slow the main proof.

### Important Lean implementation details

- For finite suprema over `ℝ`, if `Finset.sup` on a linear order is awkward, use
  `Finset.fold max 0` or `Finset.sup'` with a nonempty witness.
- If equality `vecSupNorm (fun _ => c) = ‖c‖` requires nonempty indices, add `[Nonempty ι]`.
- To avoid painful coercions, keep all norms and Lipschitz constants in `ℝ`.
- If using `List` same-width networks is too restrictive, you may additionally define a heterogeneous chain, but do not let that block the core theorem.
- If `IsUltrametricDist K` is insufficient for sum bounds, add a local lemma or wrapper class capturing
  `‖a + b‖ ≤ max ‖a‖ ‖b‖`
  and prove finite-sum consequences by induction.
- If `competitorMargin` on `erase good` needs nonemptiness, assume `[Nontrivial ι]` or `Fintype.card ι ≥ 2` where necessary. A precise and useful hypothesis is:
  ```lean
  variable [DecidableEq ι] [Nonempty ι]
  ```
  plus an explicit assumption
  ```lean
  hcomp : (Finset.univ.erase good).Nonempty
  ```
  on the certification theorems. If you can derive this from `Fintype.card ι ≥ 2`, even better.

### High-value theorem names and doc comments

Use inventive theorem names where appropriate. At least some theorem names should explicitly reflect impact, for example:
- `quantum_stability_radius_control`
- `post_quantum_noise_budget_sound`
- `lattice_margin_barrier_theorem`
- `ultrametric_lipschitz_certified_robustness`
- `berkovich_vector_gate_bound`
- `valuation_barrier_persists_under_attack`

Doc comments should say things like:
- `Bridge: connects nonarchimedean operator calculus to certified robustness in neural networks.`
- `Cryptographic analogy: the certified radius behaves like a post-quantum noise budget.`
- `Physics analogy: margin stability is a nonarchimedean quantum stability barrier.`

### Significance to the research program

This development should make precise a new paradigm: in ultrametric deep learning, robustness certificates are governed by valuation geometry rather than Euclidean dimension. The crucial novelty is width-free operator control: the certified radius is determined by multiplicative layer constants and output gap geometry, not by ambient hidden dimension. That is mathematically important because it suggests a nonarchimedean alternative to classical norm-based certification, with potential relevance to:
- certified robustness of p-adic or hierarchical neural architectures,
- post-quantum / lattice-inspired noise stability models where sup/valuation metrics are natural,
- Berkovich or tropical interfaces, where max-type geometry replaces Euclidean accumulation,
- quantum / thermodynamic analogies in which ultrametric barriers model metastable transitions.

Formalizing this in Lean creates a reusable theorem engine for future files on ultrametric PAC-Bayes, tropical certification, and cryptographic noise-margin tradeoffs.

### Deliverable expectations

Produce a substantial file, not a stub. Include:
- the core definitions above,
- at least 20 proved lemmas/theorems,
- the 6 named target lemmas/theorems,
- multiple proof styles (induction, `rcases`, `by_contra`, `linarith`, `field_simp`),
- zero `sorry`.

If some strongest theorem genuinely fails under current hypotheses, prove the strongest correct version and state the sharper conjecture with an exact Lean signature, for example:

```lean
conjecture ultrametric_vector_margin_exact_preservation
    [DecidableEq ι]
    (net : List (PadicLayeredVecMap K ι ι))
    (x z : ι → K) (good : ι) :
    vecSupDist z x < certifiedRadius (competitorMargin (evalNetwork net x) good) (networkLip net) →
    competitorMargin (evalNetwork net z) good > 0
```

Also produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, such as:
1. heterogeneous-width vector certification,
2. tropical / Berkovich comparison theorems,
3. certified training objectives minimizing `networkLip`,
4. post-quantum lattice noise interpretations,
5. ultrametric PAC-Bayes bounds with vector margins.

**AEM QUALITY MANDATE**: Your output will be scored on 5 pillars. Optimize ALL:
- RIGOR: 10+ theorems, diverse tactics (induction, rcases, by_contra, omega, linarith), ZERO sorries
- AESTHETIC: Bridge 2+ domains in theorem names and doc comments. Use quantifier alternation.
- UTILITY: Define 5+ structures/instances. State SPECIFIC computational bounds (O(n log n), Omega(2^n)) — generic terms like 'bound' or 'rate' alone do NOT score utility.
- ORIGINALITY: Coin novel definitions beyond Mathlib. Inventive theorem names. Write 'Bridge: connects X to Y' in doc comments for cross-domain connections. Generic names (main, test, aux) do NOT count.
- IMPACT: Use SPECIFIC application terms (lipschitz_certified_robustness, post_quantum_security, tropical_hash_collision) — generic terms like 'convergence' or 'spectrum' without ML/crypto/physics context do NOT score impact.

**FILE RICHNESS MANDATE**: Produce substantial, rich files (not stubs).
- Target 500+ lines with 20+ theorems and 10+ definitions per file.
- Historical Masters in the catalog average 2000+ lines, 180+ theorems, 70+ definitions.
- Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected.
- When producing catalog-wide output: create files across MULTIPLE domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics), not just one domain.

            Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new ones. What does your result make possible that wasn't possible before?
            2. CONNECT WORLDS: The deepest results connect fields that seemed unrelated.
               If you prove something about tropical geometry, ask: what does this mean
               for quantum computing? For cryptography? For neural networks?
            3. PRODUCE ALGORITHMS: Don't just prove existence — construct. Don't just
               construct — compute. Don't just compute — optimize. Every theorem should
               have an algorithmic shadow.
            4. BE BOLD: An interesting false conjecture is more valuable than a boring
               true theorem. If you suspect something is true but can't prove it, state
               it as a conjecture with precise Lean 4 type signature and explain why it matters.
            5. BUILD INFRASTRUCTURE: Definitions are as valuable as theorems. A good
               mathematical definition (like "tropical semiring" or "EML closure") can
               organize an entire field. Define things precisely, then prove things about them.

            The mathematics comes FIRST. Excellent proofs trump everything else.
            But excellent proofs that OPEN NEW FIELDS trump everything.

            === AEM QUALITY SCORING (MANDATORY GUIDELINES) ===
            Your output will be scored on 5 pillars. MAXIMIZE each one:

            PILLAR 1 — RIGOR (Is it World-class?):
            • ZERO sorries in your output (sorries cost -1.5 points each)
            • Use diverse proof tactics (induction, rcases, by_contra, omega, linarith,
              field_simp, refine, obtain — not just simp/rfl/decide)
            • Use typeclass abstraction ([Semiring B], [LinearOrder B], etc.) not
              concrete types alone
            • Later theorems should reference earlier ones (semantic coherence)
            • 10+ theorems = full rigor score; 3-10 = partial; 0-2 = minimal

            PILLAR 2 — AESTHETIC (Is it Interesting?):
            • Bridge 2+ mathematical domains in EVERY file (e.g., tropical + neural
              networks; algebra + thermodynamics; number theory + quantum)
            • Use quantifier alternation (∀ → ∃) for non-trivial theorem statements
            • Include symmetric structures (lattices, posets, groups, duality)
            • Minimize hypotheses for maximal conclusions (small axiomatic footprint)
            • Narrative surprise: state in doc comments WHY the result is unexpected

            PILLAR 3 — UTILITY (Is it Useful?):
            • State explicit computational bounds (O(...), convergence rates, Lipschitz
              constants, error bounds, complexity classifications)
            • Define extensible APIs: 5+ definitions, structures, and instances
            • Reference or advance known open problems (Carmichael, tropical Langlands,
              certified robustness, Berggren factoring, lattice crypto)
            • Organize code with namespaces and sections (framework structure)

            PILLAR 4 — ORIGINALITY (Is it New?):
            • Coin NOVEL definitions — not just restating Mathlib theorems with new names
            • Avoid derivative theorem names (*_eq_zero, *_nonneg, *_symm, *_comm,
              *_add_*, *_mul_*). Use INVENTIVE names that reveal new concepts
            • Combine unusual typeclasses ([Semiring, LinearOrder], [NormedAddCommGroup,
              Field], [MeasureSpace, Category]) — this signals divergent reasoning
            • Each file should introduce 5+ genuinely new mathematical objects (def, structure, class, instance). High-Originality files average 10+ new definitions.

            PILLAR 5 — IMPACT (Does it have Wonderful Applications?):
            • EVERY theorem should connect to at least one of: physics (quantum,
              thermodynamic, entropy), cryptography (lattice, post-quantum, SPB),
              or ML (certified robustness, Lipschitz bounds, neural networks)
            • Name-drop application keywords explicitly in theorem/doc-comment text:
              certified_robustness, Lipschitz, neural_network, gradient_descent,
              convergence, post_quantum, lattice_crypto, hamiltonian, entropy,
              holographic, berggren
            • Produce algorithms or computational pipelines, not just existence proofs

            ### Research Direction
            Formalize a multi-output non-Archimedean robustness calculus for layered neural maps over ultrametric normed fields. The central target is: for every layered map f : K^n -> K^m built from affine matrix layers and coordinatewise ultrametric 1-Lipschitz activations, one has a width-free bound Lip_sup(f) <= product_i ||W_i||_infty, where ||W||_infty is the entrywise max norm and the ambient vector norm is the sup norm. Extend this to perturbation transport, output-margin preservation, and certified adversarial radii for classification by valuation-separated logits. This directly advances Aristotle's top-ranked recommendation and deeply extends recent successful work on Berkovich continuity, arithmetic VC-dimension, and ultrametric PAC-Bayes, while remaining distinct from in-flight EML projects.

            ### Precise Mathematical Framing
            Define a structure PadicLayeredVecMap generalizing scalar PadicLayeredMap to matrix-valued affine stages. Prove the foundational inequality ||A v||_sup <= ||A||_infty ||v||_sup using the existing ultrametric matrix-vector machinery, then induct over depth to obtain multiplicative width-free operator bounds. Next prove a vector perturbation theorem ||f(x)-f(y)||_sup <= L ||x-y||_sup with L = product_i ||W_i||_infty. Then derive a margin-preservation result: if two output coordinates differ by valuation gap exceeding L·r, perturbations of sup-radius r cannot change the argmax/argmin decision. Finally package this as an algorithmic certification pipeline for multi-output p-adic networks, linking non-Archimedean geometry to practical robustness certification. This is cross-domain because it merges ultrametric functional analysis, neural network verification, and valuation geometry; it is algorithmic because the certificate is computable layerwise from weights alone.

            ### Lean 4 Sketch
Create `Speculative/AutoResearch/Bridges/UltrametricVectorCertification.lean` or extend `Speculative/AutoResearch/Bridges/UltrametricDeepLearning.lean` with definitions `PadicLayeredVecMap`, `layerLip`, `networkLip`, `evalVec`, `certifiedRadius`; prove lemmas `ultrametric_mulVec_bound`, `affine_sup_lipschitz`, `activation_sup_lipschitz`, `layeredVec_lipschitz_bound`, `layeredVec_certified_radius`, `valuation_margin_stable`.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `certified_robustness_from_margin_and_lipschitz` : theorem certified_robustness_from_margin_and_lipschitz
     (file: Bridges/HomologicalDeepLearning.lean)
  2. `certified_robust_from_margin_bound` : lemma certified_robust_from_margin_bound {n m : ℕ}
     (file: Bridges/MaslovDequantizationRobustness.lean)
  3. `margin_perturbation_bound` : theorem margin_perturbation_bound
     (file: Bridges/GL3KemenyRobustness.lean)
  4. `pair_margin_lower_bound_under_perturbation` : lemma pair_margin_lower_bound_under_perturbation
     (file: Bridges/GL3TopCycleRobustness.lean)
  5. `casimir_lipschitz_certified_bound` : theorem casimir_lipschitz_certified_bound {V W : Type*}
     (file: Bridges/LieEquivariantLearning.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT



Recent successful concepts: Functorial Entropic Uncertainty via Tropical–Ultrametric Quantum Measurement Skeletons, Berkovich Continuity and Skeleton Region Bounds for p-adic Operadic Neural Networks, Arithmetic VC-Dimension via Height-Stratified Shattering for Rational Operadic Networks


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician, software engineer, and science writer.
            Create ALL of the following:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **ARTICLE.md** — MANDATORY standalone popular-science article
               CRITICAL RULES:
               • Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
               • Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
               • This is a premier magazine-quality piece for curious, intelligent readers.
               QUALITY STANDARDS:
               • Superb, vivid, engaging prose with a strong opening hook and narrative arc.
               • Concrete analogies and metaphors that make abstract ideas tangible.
               • Story structure: provocative question → tension → breakthrough → significance.
               • Real-world connections: technology, nature, everyday life.
               • Historical context: place the work in the sweep of intellectual history.
               • 1500–3000 words. Substantial, standalone, enjoyable, interesting.
               • A reader should say "Wow, I had no idea math could do THAT."

            3. **RESEARCH_PAPER.md** — MANDATORY comprehensive, in-depth research paper
               This is a full, publishable-quality paper, NOT a summary:
               • Abstract, Introduction, Definitions & Notation
               • Main Results with detailed proof sketches (not just "by induction")
               • Algorithms with complete pseudocode and complexity analysis
               • Applications with worked examples showing practical use
               • Computational Experiments with tables, charts, numerical results
               • Discussion, Future Work, References
               • 3000–8000 words. Thorough and substantive.

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale

               ## Under-explored Territory
               ## Cross-Domain Bridges
               ## Open Problems Encountered

            5. **Python code** — demos, visualizations, algorithms, applications:
               - **demo.py** — concrete numerical examples bringing the math to life
               - **visualizations** — matplotlib/plotly charts (save as PNG/SVG too)
               - **algorithms.py** — implement algorithms from the paper with docstrings
               - **applications.py** — real-world applications (ML, crypto, physics)

            6. **diagram.svg** — visualization of key mathematical structures

            7. **PACKAGE.html** — MANDATORY standalone HTML package
               Bundle ALL artifacts into a single, self-contained HTML file:
               • Everything inlined (CSS, JS, content). No external dependencies.
               • ALL images MUST be embedded as base64 data URIs:
                 `<img src="data:image/png;base64,..." />` for PNGs,
                 `<img src="data:image/svg+xml;base64,..." />` for SVGs.
                 For SVG diagrams, prefer inlining `<svg>...</svg>` markup directly.
                 If you generate matplotlib/plotly charts, convert to base64 and embed.
                 NEVER reference external image files — they won't exist standalone.
               • Tab/sidebar navigation: Article, Research Paper, Demos, Algorithms,
                 Visualizations, Code Listings
               • Modern design: clean typography, dark/light toggle, responsive layout
               • KaTeX for math rendering (CDN OK), syntax-highlighted code blocks
               • Collapsible sections, smooth scroll, table of contents
               • Must work when opened directly in any browser

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


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
• Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
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
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — Standalone HTML Package  →  PACKAGE.html
────────────────────────────────────────────────────────────────────────────
Create a **single, self-contained HTML file** that bundles ALL artifacts
into a beautiful, interactive presentation. Requirements:

• **Single file**: Everything (CSS, JS, content) inlined. No external deps.
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the HTML as base64 data URIs. Use the format:
  `<img src="data:image/png;base64,..." />` for PNGs,
  `<img src="data:image/svg+xml;base64,..." />` for SVGs.
  If you generate matplotlib/plotly figures in Python, convert them to base64
  and embed them. For SVG diagrams, inline the SVG markup directly with
  `<svg>...</svg>` tags — this is preferred over base64 for vector graphics.
  NEVER use `<img src="filename.png">` — the file won't exist when viewing.
• **Navigation**: Sidebar or tab navigation between sections:
  - Article (the popular-science piece)
  - Research Paper (the full paper)
  - Interactive Demos (embedded Python output / JS visualizations)
  - Algorithms (pseudocode + implementation)
  - Visualizations (embedded charts/diagrams as inline SVG or base64)
  - Code Listings (syntax-highlighted Python and proof code)
• **Beautiful design**: Modern, clean typography (system fonts).
  Dark/light mode toggle. Responsive layout. Smooth transitions.
• **Math rendering**: Use KaTeX (CDN link OK for math rendering only)
  for any mathematical notation.
• **Syntax highlighting**: Inline code highlighting for Python blocks.
• **Interactive elements**: Collapsible sections, smooth scroll, TOC.
• The HTML package should work when opened directly in any browser.
• Include ALL content from the article, research paper, and code.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: formalize
