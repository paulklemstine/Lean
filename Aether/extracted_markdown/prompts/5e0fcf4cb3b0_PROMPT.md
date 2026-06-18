Soli Deo Gloria

## Assignment: Direction 3: Tropical Morse Theory via Active-Set Transitions

**Mode:** prove

Build a genuine tropical-discrete-topological theory, not a toy extension. The target is a formal bridge between **active-set combinatorics of tropical sublevel filtrations** and **discrete Morse theory on evolving cell complexes**. If successful, this creates a new language for reasoning about tropical loss landscapes, piecewise-linear optimization, and event-driven topology in non-smooth geometry.

You must prove new, non-trivial theorems, explicitly building on the catalog results:

- `Tropical/ArithmeticUniversality/Defs.lean`
  - `activeSetComplex_mono`
  - `activeSet_iff_dominates`
  - `mem_sublevel_iff_forall_le`

Minimize `sorry`. Do not spend the cycle on easy decidable lemmas. Prove structural theorems.

---

## Core Vision

Let a tropical family of affine forms on `Fin n → ℝ` be given by
\[
f_i(x)=a_i\cdot x+b_i,\qquad i\in I,\ |I|=k,
\]
and let the tropical sublevel set at threshold \(c\) be
\[
X_c := \{x : \max_i f_i(x)\le c\}.
\]
The **active-set complex** \(\mathcal A_F^{sub}(c)\) records subsets of indices that are simultaneously active on \(X_c\), i.e. realized as equality sets on the boundary or on cells of the induced arrangement. The conjectural principle is that topology changes only when affine forms exchange dominance along the sublevel boundary, and these transitions should be sparse, pairwise, and Morse-theoretic.

This is potentially a breakthrough because it would provide a **non-smooth Morse theory for tropical filtrations** that is:
1. **combinatorial** rather than differential,
2. **algorithmic** rather than existential,
3. **formalizable in Lean** using finite combinatorics and order-theoretic arguments.

If you succeed, this opens a new field direction: **tropical critical event topology**, with applications to optimization landscapes, certified complexity bounds, and event-driven geometry of piecewise-linear systems.

---

## Precise Mathematical Targets

You should introduce a formal notion of **tropical critical value** for a finite family of affine forms, then prove at least 3 substantial theorems around it.

Because the exact catalog API may differ, you may need to define an abstract finite tropical family structure first. Do so cleanly and minimally.

### Suggested new definitions

Define a new structure capturing a finite tropical affine family.

```lean
structure TropicalAffineFamily (n k : ℕ) where
  lin  : Fin k → (Fin n → ℝ)
  bias : Fin k → ℝ
```

Define evaluation:

```lean
def TropicalAffineFamily.eval (F : TropicalAffineFamily n k) (i : Fin k) (x : Fin n → ℝ) : ℝ :=
  ∑ j, F.lin i j * x j + F.bias i
```

Define tropical max-envelope and sublevel set:

```lean
def TropicalAffineFamily.tropEval (F : TropicalAffineFamily n k) (x : Fin n → ℝ) : ℝ :=
  Finset.univ.sup (fun i : Fin k => F.eval i x)

def TropicalAffineFamily.sublevel (F : TropicalAffineFamily n k) (c : ℝ) : Set (Fin n → ℝ) :=
  {x | F.tropEval x ≤ c}
```

Define active set at a point and the active-set complex at threshold `c`:

```lean
def TropicalAffineFamily.activeSet (F : TropicalAffineFamily n k) (x : Fin n → ℝ) : Finset (Fin k) :=
  Finset.univ.filter (fun i => F.eval i x = F.tropEval x)

def TropicalAffineFamily.activeSetComplex (F : TropicalAffineFamily n k) (c : ℝ) : Set (Finset (Fin k)) :=
  {s | ∃ x ∈ F.sublevel c, s ⊆ F.activeSet x}
```

Now define a threshold to be critical if the active-set complex strictly grows:

```lean
def TropicalAffineFamily.IsCriticalValue (F : TropicalAffineFamily n k) (c : ℝ) : Prop :=
  ∀ ε > 0, ∃ s, s ∈ F.activeSetComplex c ∧ s ∉ F.activeSetComplex (c - ε)
```

For a cleaner finite-combinatorial theorem, you may instead define a **combinatorial critical value** via pair-equality events:
\[
c \text{ is critical if } \exists x,\ i\neq j,\ f_i(x)=f_j(x)=c,\ \forall \ell,\ f_\ell(x)\le c.
\]
This formulation is more Lean-friendly and likely the right formalization target for the first cycle.

```lean
def TropicalAffineFamily.IsPairCritical (F : TropicalAffineFamily n k) (c : ℝ) : Prop :=
  ∃ x : Fin n → ℝ, ∃ i j : Fin k,
    i ≠ j ∧
    F.eval i x = c ∧
    F.eval j x = c ∧
    ∀ l : Fin k, F.eval l x ≤ c
```

Define genericity/no-triple-tie:

```lean
def TropicalAffineFamily.PairwiseGeneric (F : TropicalAffineFamily n k) : Prop :=
  ∀ x : Fin n → ℝ, ∀ i j l : Fin k,
    i ≠ j → j ≠ l → i ≠ l →
    ¬ (F.eval i x = F.eval j x ∧ F.eval j x = F.eval l x)
```

Define the birth cell relation:

```lean
def TropicalAffineFamily.BirthsAt (F : TropicalAffineFamily n k) (c : ℝ) (s : Finset (Fin k)) : Prop :=
  s ∈ F.activeSetComplex c ∧
  ∃ ε > 0, s ∉ F.activeSetComplex (c - ε)
```

Define a discrete Morse labeling candidate by first-birth time:

```lean
def TropicalAffineFamily.birthTime (F : TropicalAffineFamily n k) (s : Finset (Fin k)) : Set ℝ :=
  {c | F.BirthsAt c s}
```

If direct formalization of Forman’s full theory is too heavy for one cycle, define a **tropical Morse preorder** on cells by first appearance and prove the axioms that imply no repeated upward matchings in the generic pair-critical case. That still counts as a serious new concept.

---

## Theorem 1: Pair-critical values control all active-set births

### Informal statement
Every strict enlargement of the active-set complex is witnessed by a pair-critical event. Hence the number of critical values is bounded by the number of unordered pairs of affine forms, at least in the generic regime where each pair contributes at most one birth event.

### Precise target theorem
You should prove a theorem of the following shape:

```lean
theorem criticalValue_imp_pairCritical
    (F : TropicalAffineFamily n k)
    {c : ℝ}
    (hc : F.IsCriticalValue c) :
    F.IsPairCritical c
```

Then prove a counting theorem under an explicit uniqueness hypothesis for pair events:

```lean
def TropicalAffineFamily.PairEventUnique (F : TropicalAffineFamily n k) : Prop :=
  ∀ i j : Fin k, i ≠ j →
    ∀ c₁ c₂ : ℝ,
      F.IsPairCritical c₁ →
      F.IsPairCritical c₂ →
      (∃ x, F.eval i x = c₁ ∧ F.eval j x = c₁ ∧ ∀ l, F.eval l x ≤ c₁) →
      (∃ x, F.eval i x = c₂ ∧ F.eval j x = c₂ ∧ ∀ l, F.eval l x ≤ c₂) →
      c₁ = c₂
```

and then:

```lean
theorem card_criticalValues_le_choose
    (F : TropicalAffineFamily n k)
    (hgen : F.PairwiseGeneric)
    (huniq : F.PairEventUnique)
    :
    Finite {c : ℝ | F.IsCriticalValue c} ∧
    Nat.card {c : ℝ | F.IsCriticalValue c} ≤ k * (k - 1) / 2
```

If `Nat.card` on a subtype of `ℝ` becomes annoying, replace with a finite set of critical values extracted from pair indices, or prove an injective encoding:

```lean
theorem criticalValue_encodes_into_pairs
    (F : TropicalAffineFamily n k)
    (hgen : F.PairwiseGeneric)
    :
    ∃ e : {c : ℝ // F.IsCriticalValue c} ↪ Sym2 (Fin k), True
```

This is fully meaningful: it says critical values inject into unordered pairs.

### Why this is a breakthrough
This is the tropical analogue of “critical values are sparse” in smooth Morse theory, but now in a **max-plus, non-differentiable, combinatorial** setting. It replaces Hessians by pairwise dominance exchanges. That is conceptually new.

### Proof strategy options

**Strategy A: direct birth-to-boundary-equality argument (most promising).**
1. Use `activeSetComplex_mono` to show any birth at `c` is a minimal threshold where some active set first appears.
2. Extract a witness point `x ∈ sublevel c` realizing the new cell.
3. Use `mem_sublevel_iff_forall_le` and `activeSet_iff_dominates` to show at least two forms must tie at value `c`; otherwise the active set was already stable below `c`.
4. Under genericity, exclude triple ties and encode the birth by a unique unordered pair.

**Strategy B: contradiction via local lowering.**
1. Assume a new active cell appears at `c` but no pair tie occurs.
2. Show one affine form strictly dominates near the witness point.
3. Perturb the threshold downward slightly and preserve the active cell, contradicting criticality.
4. This approach is attractive because it naturally uses `by_contra`, epsilon arguments, and multi-step `calc`.

**Strategy C: finite arrangement stratification.**
1. Define strata by sign/equality patterns of all differences `f_i - f_j`.
2. Show the active-set complex is constant on threshold intervals not meeting pair-event values.
3. Critical values therefore belong to the finite event spectrum.
4. This is more geometric and may scale later, but is heavier in Lean.

**Most promising:** Strategy A, because it leverages the catalog lemmas directly and avoids building full arrangement machinery too early.

---

## Theorem 2: Generic critical values create exactly one new maximal cell

### Informal statement
At a generic tropical critical value, exactly one new maximal active cell is born, and it is the pair \(\{i,j\}\) responsible for the tie, or the unique maximal cell generated by that pair event.

### Lean target
A direct exact statement may depend on your chosen complex model. One feasible formulation is:

```lean
def IsMaximalFaceAt (F : TropicalAffineFamily n k) (c : ℝ) (s : Finset (Fin k)) : Prop :=
  s ∈ F.activeSetComplex c ∧
  ∀ t, s ⊆ t → t ∈ F.activeSetComplex c → t = s
```

Then prove:

```lean
theorem generic_criticalValue_unique_maximal_birth
    (F : TropicalAffineFamily n k)
    (hgen : F.PairwiseGeneric)
    {c : ℝ}
    (hc : F.IsCriticalValue c) :
    ∃! s : Finset (Fin k),
      F.BirthsAt c s ∧ IsMaximalFaceAt F c s
```

A more concrete version, if you can prove stronger pair identification:

```lean
theorem generic_pairCritical_births_pair
    (F : TropicalAffineFamily n k)
    (hgen : F.PairwiseGeneric)
    {c : ℝ}
    (hc : F.IsPairCritical c) :
    ∃! i j : Fin k,
      i ≠ j ∧
      F.BirthsAt c ({i, j} : Finset (Fin k))
```

If the exact pair `{i,j}` is not literally the maximal face in your definition, prove instead that there is a unique maximal born face whose 2-skeleton contains exactly one new edge.

### Why this matters
This is the tropical substitute for “one critical point per critical level” in the generic Morse regime. It says topology changes are **atomic**. That gives algorithmic tractability and opens the way to certified complexity bounds.

### Proof strategy options

**Strategy A: genericity eliminates multiple births.**
1. Show any born maximal face at `c` must contain a tied pair realizing `c`.
2. Under `PairwiseGeneric`, no three indices can be simultaneously newly active at the same witness point.
3. Therefore two distinct maximal born faces would force either two different pair events at the same level or a triple tie contradiction.

**Strategy B: maximality via strict inequalities of non-active forms.**
1. Start from the pair-critical witness `x`.
2. Prove all other forms are strictly `< c` at `x` using genericity and critical minimality.
3. Conclude the active set at `x` is exactly the new maximal face.
4. Uniqueness follows by comparing any other candidate witness and using equality-pattern rigidity.

**Strategy C: interval constancy + single-jump argument.**
1. Show the active-set complex is constant on `(c-ε,c)` and on `(c,c+ε)` for sufficiently small `ε`.
2. Compare the face posets before and after.
3. Prove the poset difference has exactly one maximal element.
4. This is elegant but may be technically heavier.

**Most promising:** Strategy B. It concretely uses the witness of criticality and turns genericity into strict inequalities.

---

## Theorem 3: Birth order defines a tropical discrete Morse structure

### Informal statement
Ordering cells by first appearance in the sublevel filtration gives a discrete Morse-type function, and the number of births in each dimension bounds Betti numbers of the active-set filtration.

You do not need to formalize all of Forman’s theory from scratch if that is too much. But you must formalize a meaningful theorem that captures the Morse inequality mechanism in a finite simplicial setting.

### New concept to define
Define a **tropical Morse labeling** on active cells by first birth threshold:

```lean
def TropicalAffineFamily.firstBirthLe (F : TropicalAffineFamily n k) (s t : Finset (Fin k)) : Prop :=
  ∀ c, F.BirthsAt c t → ∃ d ≤ c, F.BirthsAt d s
```

or a numerical labeling when finiteness is available:

```lean
def TropicalAffineFamily.birthIndex
    (F : TropicalAffineFamily n k)
    (criticals : Finset ℝ) : Finset (Fin k) → ℕ := ...
```

Then define a no-cycle matching or monotonicity property sufficient for weak Morse inequalities.

### Lean target theorem
At minimum, prove a theorem of the shape:

```lean
theorem face_birth_monotone
    (F : TropicalAffineFamily n k)
    {s t : Finset (Fin k)}
    (hst : s ⊆ t) :
    ∀ c, F.BirthsAt c t → ∃ d ≤ c, F.BirthsAt d s
```

This is already nontrivial and expresses that larger faces cannot be born before their subfaces.

Then prove a finite-dimensional counting inequality, for example:

```lean
def cellsBornInDim (F : TropicalAffineFamily n k) (m : ℕ) : Set (Finset (Fin k)) :=
  {s | (∃ c, F.BirthsAt c s) ∧ s.card = m + 1}

theorem weak_morse_inequality_candidate
    (F : TropicalAffineFamily n k)
    (hfinite : Finite {s : Finset (Fin k) // ∃ c, F.BirthsAt c s}) :
    ∀ m : ℕ,
      Nat.card {s : Finset (Fin k) // s ∈ F.cellsBornInDim m}
      ≥ Nat.card (someBettiProxy F m)
```

If actual Betti numbers are too ambitious in one cycle, define and prove the inequality for the **Euler characteristic proxy**:
\[
\chi \le \sum_m (-1)^m\, \#\{\text{born \(m\)-cells}\},
\]
or prove exact equality of alternating counts for the finite active-set complex. A good formal target is:

```lean
theorem eulerCharacteristic_birth_decomposition
    (F : TropicalAffineFamily n k) :
    -- precise statement using finite alternating sums over born cells
    True
```

But do not cop out with `True`; formalize a real alternating-sum identity on finite face sets. If Betti formalization is unavailable, use Euler characteristic as the first topological invariant. That still makes the Morse-theoretic bridge concrete.

### Why this is revolutionary
This turns tropical optimization geometry into **event-driven topology**. Instead of smooth critical points, you get combinatorial births of active cells. That can feed into:
- topological complexity of piecewise-linear loss surfaces,
- certified upper bounds for optimization basin complexity,
- algorithmic topology of max-affine models.

### Proof strategy options

**Strategy A: filtration-poset proof (most Lean-feasible).**
1. Use monotonicity of `activeSetComplex` in `c`.
2. Show if a face appears at time `c`, every subface appeared at some time `≤ c`.
3. Define a filtration-compatible ranking on faces.
4. Derive weak Morse-style inequalities as counting inequalities on a finite filtered simplicial complex.

**Strategy B: import/instantiate a finite simplicial complex theorem.**
1. Search Mathlib for finite simplicial complex / Euler characteristic / chain complex results.
2. Realize active-set complexes as finite abstract simplicial complexes.
3. Push the birth filtration through existing homological machinery.
4. This is potentially stronger but depends on library availability.

**Strategy C: incidence algebra / Möbius inversion approach.**
1. Encode births via inclusion-exclusion on the face poset.
2. Derive Euler characteristic and critical-cell counts combinatorially.
3. This is cross-domain and conceptually beautiful, though more technically demanding.

**Most promising:** Strategy A. It is robust and still scientifically meaningful.

---

## Cross-Domain Theorem Requirement

You must include at least one theorem explicitly connecting tropical active-set transitions to a different domain.

### Recommended bridge: hyperplane arrangements / oriented matroids
Each pair-equality event
\[
f_i(x)=f_j(x)
\]
defines a classical affine hyperplane in `ℝ^n`. Thus tropical critical values are controlled by the intersection pattern of a classical hyperplane arrangement.

Formalize a theorem saying that pair-critical witnesses lie on equality hyperplanes:

```lean
def TropicalAffineFamily.eqHyperplane (F : TropicalAffineFamily n k) (i j : Fin k) : Set (Fin n → ℝ) :=
  {x | F.eval i x = F.eval j x}

theorem pairCritical_lies_on_eqHyperplane
    (F : TropicalAffineFamily n k)
    {c : ℝ}
    (hc : F.IsPairCritical c) :
    ∃ i j x, i ≠ j ∧ x ∈ F.eqHyperplane i j ∧
      F.eval i x = c ∧ ∀ l, F.eval l x ≤ c
```

This is not just definitional fluff: it is the theorem that moves the subject from tropical combinatorics to classical arrangement geometry.

### Stronger bridge, if possible
Prove that the set of pair-critical values is contained in the image of the arrangement’s boundary-event map. In other words, tropical criticality is an **arrangement event spectrum**.

This cross-domain connection matters because it imports techniques from:
- hyperplane arrangements,
- oriented matroid theory,
- computational geometry,
- combinatorial topology.

---

## Suggested File and Formalization Shape

Create a new file, for example:

`Tropical/ArithmeticUniversality/TropicalMorse.lean`

It should import the catalog file:
```lean
import Tropical.ArithmeticUniversality.Defs
```

Recommended theorem progression:
1. Define `TropicalAffineFamily`.
2. Define `sublevel`, `activeSet`, `activeSetComplex`.
3. Define `IsPairCritical`, `IsCriticalValue`, `PairwiseGeneric`, `BirthsAt`.
4. Prove monotonicity lemmas for complexes and births.
5. Prove Theorem 1.
6. Prove Theorem 2.
7. Prove Theorem 3 / Euler-counting theorem.
8. Add cross-domain arrangement theorem.
9. Add computable enumeration algorithm and correctness theorem.

---

## Required Deep Proof Tactics

Your file must contain at least 3 theorems whose proofs genuinely use deep tactics and multi-step reasoning. Target:
- one theorem using `by_contra`,
- one theorem using `rcases`,
- one theorem using `calc`,
- one theorem using induction on finite face cardinality or filtration index if appropriate,
- one theorem using `field_simp` if you normalize affine equalities into linear constraints.

Good candidates:
- `criticalValue_imp_pairCritical` via contradiction,
- uniqueness of maximal born face via `rcases` on witnesses and genericity,
- birth monotonicity via `calc` and subset arguments,
- counting bound via finite injection and cardinality monotonicity.

Do **not** satisfy the assignment with trivial proof scripts.

---

## Verified Algorithm / Computational Method

You must provide a verified computational method, not just existence theorems.

### Algorithm target
Implement an algorithm that, for finite tropical affine families in small dimension, enumerates candidate pair-critical values by scanning unordered pairs `(i,j)` and solving the pair-equality event constraints on the sublevel boundary.

Suggested computable abstraction:
- For `n = 2` and rational coefficients, enumerate pair equalities symbolically.
- For each pair `(i,j)`, solve
  \[
  f_i(x)=f_j(x),\qquad f_i(x)=c,\qquad f_\ell(x)\le c\ \forall \ell.
  \]
- Extract candidate `c`.
- Deduplicate.
- Build the active-set complex before/after each candidate and detect births.

Formalize soundness:

```lean
def enumeratePairCriticals (F : TropicalAffineFamily n k) : Finset ℝ := ...

theorem mem_enumeratePairCriticals_of_critical
    (F : TropicalAffineFamily n k)
    (hgen : F.PairwiseGeneric)
    {c : ℝ}
    (hc : F.IsCriticalValue c) :
    c ∈ enumeratePairCriticals F
```

If full completeness is too hard, prove soundness in the other direction and state completeness as a conjecture with tests.

---

## Computational Test Program

You must produce `demo.py` that:
1. samples 100 random tropical families in `ℝ²` with `k = 3, 5, 10`,
2. enumerates candidate critical values,
3. verifies experimentally:
   - bound by `binom(k,2)`,
   - generic one-maximal-cell birth,
   - Morse birth counts vs topological proxies,
4. visualizes:
   - sublevel sets,
   - equality hyperplanes,
   - active-set complex growth,
   - birth sequence.

This is not optional. The demo should make the mathematics tangible.

---

## Falsifiable Conjectures for `FUTURE_DIRECTIONS.md`

You must include 3–5 testable hypotheses. At least one should be directly computationally falsifiable. Recommended hypotheses:

1. **Pair-spectrum completeness conjecture.**  
   Every critical value of a generic tropical affine family equals a unique pair-critical value arising from exactly one unordered pair.  
   **Test:** Exhaustive random search in `ℝ²` and `ℝ³`; search for a critical value with no unique pair witness.

2. **Atomic birth conjecture.**  
   For generic families, each critical value adds exactly one maximal cell to the active-set complex.  
   **Test:** Enumerate active-set complexes immediately below/above each candidate critical value.

3. **Tropical weak Morse conjecture.**  
   The number of born \(d\)-cells bounds the \(d\)-th Betti number of the filtration complex.  
   **Test:** Compute simplicial homology numerically for sampled complexes and compare.

4. **Arrangement control conjecture.**  
   The critical spectrum depends only on the oriented matroid of the equality arrangement together with biases.  
   **Test:** Generate coefficient families with the same combinatorial arrangement type and compare spectra.

5. **Optimization landscape conjecture.**  
   For tropicalized neural layers, the number of pair-critical values predicts the number of optimization phase transitions under threshold annealing.  
   **Test:** Compare pair-critical counts with observed basin-merging events in synthetic max-affine models.

These are strong because they can fail, and the failure would be scientifically informative.

---

## RESEARCH_PAPER.md Requirements

Your `RESEARCH_PAPER.md` must be a standalone scientific document containing:
- a precise definition of tropical critical values,
- the main theorems with hypotheses,
- why pairwise dominance exchanges replace smooth critical points,
- comparison with classical Morse theory and hyperplane arrangements,
- algorithmic implications,
- experimental findings from `demo.py`,
- limitations and next conjectures.

Write it so that a mathematician could understand the discovery without opening Lean.

---

## ARTICLE.md Requirements

Write an accessible Scientific American–style article explaining:
- why “mountain passes” in smooth landscapes fail for tropical geometry,
- how topology can still change through “active-set events,”
- why this matters for machine learning and combinatorial geometry,
- what your theorems reveal about hidden structure in piecewise-linear worlds.

---

## Application Keywords

Include and emphasize these application keywords where appropriate:

**tropical geometry, discrete Morse theory, hyperplane arrangements, oriented matroids, piecewise-linear optimization, loss landscapes, simplicial complexes, topological data analysis, certified complexity, event-driven topology, max-plus algebra, combinatorial homology, algorithmic geometry, formalized mathematics**

---

## Final Deliverables (ALL mandatory)

You must produce ALL of the following:

1. **Lean file(s)** with at least 3 deep theorems and at least one genuinely new definition.
2. **`FUTURE_DIRECTIONS.md`** with 3–5 falsifiable scientific hypotheses and explicit computational tests.
3. **`RESEARCH_PAPER.md`** as a standalone scientific paper.
4. **`ARTICLE.md`** in accessible popular-science style.
5. **A verified algorithm or computational method** for enumerating or certifying tropical critical values / births.
6. **`demo.py`** demonstrating the theory interactively on random examples and visualizations.

The goal is not to formalize an isolated lemma. The goal is to found **tropical Morse theory via active-set transitions** as a new formal, computational, and conceptual framework.

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
