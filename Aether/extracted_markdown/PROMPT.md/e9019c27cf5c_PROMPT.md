## Assignment: Algebra–Physics–Pythagorean Tropical Lens Duality via Berggren Geodesic Semimodules and Certified Factor Reconstruction

**Mode:** `prove`

Prove genuinely new theorems that fuse tropical realization theory, Berggren-tree arithmetic dynamics, and inverse-problem ideas from gravitational lensing. Build explicitly on the catalog theorems below, but do **not** merely restate them in a new vocabulary. The goal is to open a new formal arc: **gravitational_factoring via tropical inverse geometry on arithmetic trees**.

Minimize `sorry`. If auxiliary definitions are needed, isolate them cleanly in the target file and prove the smallest reusable lemmas first.

### Target file
`Bridges/AlgebraPhysicsPythagorean/TropicalLensBerggrenDuality.lean`

---

## Vision

The breakthrough is to show that arithmetic information on the Berggren tree of primitive Pythagorean triples can be treated as a **tropical lensing system**: sources emit min-plus geodesic signals, observers record delay spectra, and finite separated spectra force a **minimal realizable inverse model**. This is not a variant of the existing Berggren quantum walk story. It replaces amplitudes by geodesic action, Fourier structure by arrival-time geometry, and generic reconstruction by a **certified finite realization theorem with arithmetic content**.

If successful, this creates a formal bridge among:

- tropical geometry,
- inverse problems in mathematical physics,
- automata/minimal realization over idempotent semirings,
- arithmetic trees of primitive triples,
- and certified factor recovery from geometric delay data.

That is a field-opening move: **factorization as inverse tropical lensing on arithmetic state spaces**.

---

## Existing verified theorems to build on

Use these concretely, not decoratively:

1. `finite_tropical_lens_realization`
   from `Bridges/AlgebraTropicalGeometry/TropicalGravitationalFactoringDuality.lean`

   Use this as the finite-realization seed: it already certifies that finite observer data can produce a tropical lens realization under positivity hypotheses. Your job is to **specialize and lift** it to the Berggren geodesic semimodule setting, where the state space carries arithmetic semantics.

2. `exists_minimal_graph_from_rank_data`
   from `Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean`

   Use this to convert tropical Hankel/rank-style observer data into a **minimal graph model**. The key innovation is to define Berggren delay data so that its induced congruence/rank object feeds into this theorem.

3. `berggren_reconstruction_from_measurements`
   from `Bridges/QuantumPythagoras/BerggrenFourierDuality.lean`

   Use this as the arithmetic reconstruction backbone. Even if its original language is Fourier/measurement-based, extract the principle that **sufficiently rich finite observations determine Berggren-structured arithmetic states up to an equivalence**. Then reinterpret the “measurements” as tropical delay observables.

4. `finite_coordinateBounded_quantum_certified`
   from the existing catalog fragment

   Use this only if it gives a coordinate-bounded certification principle. The important point is not the quantum origin, but the already-verified mechanism for passing from bounded finite data to a certified conclusion.

---

## Mathematical objects to define

Introduce these definitions cleanly and minimally.

### 1. Berggren geodesic semimodule
Define a type of finitely supported tropical weightings on Berggren nodes.

At minimum, formalize a structure or abbreviation expressing:
- a Berggren node/state space,
- finitely supported tropical source weights,
- an arithmetic edge-cost function,
- and a min-plus path/action value.

You do **not** need to formalize full gravitational lensing physics. What matters is a mathematically rigid min-plus geodesic propagation model.

Suggested ingredients:
- nodes = Berggren triples or an abstract type equipped with a `parent/children` graph relation,
- source = finitely supported map `Node → ℤ∞` / `WithTop ℤ` / another existing tropical codomain in Mathlib,
- edge cost = arithmetic cost functional depending on triple parameters and divisibility observables,
- observer family = finite set of nodes or boundary probes.

### 2. Tropical lens transform
Define the observer delay profile of a source weighting:
- arrival time at observer `o` = min over source nodes `s` of `sourceWeight s + geodesicCost s o`.

This is the min-plus convolution / tropical integral kernel. Keep it finite and computable whenever possible.

### 3. Delay-separation condition
Define a predicate saying that the relevant geodesic spectra are separated enough that distinct source classes do not collapse under observation. This is the exact hypothesis enabling finite reconstruction.

### 4. Observational equivalence
Define two sources to be observationally equivalent if they induce the same observer delay profile on the chosen observer family.

This quotient is essential: uniqueness should be stated **up to observational equivalence**, unless your formalization can prove stronger injectivity in a subclass.

---

## Primary theorem: finite realization + minimal reconstruction duality

Prove a theorem of the following shape.

### Mathematical statement
For every finitely generated Berggren tropical lens system with separated observer delay spectra, the observer-delay congruence is finite and there exists a certified minimal realization whose tropical lens transform agrees with the original delay data; moreover this realization reconstructs the underlying source uniquely up to observational equivalence.

### Lean 4 target signature sketch
You will need to adapt names/types to the actual local definitions, but aim for something this precise:

```lean
theorem berggren_tropical_lens_finite_realization
    (Sys : BerggrenLensSystem)
    (hfin : Sys.FinitelyGenerated)
    (hsep : Sys.DelaySeparated) :
    ∃ R : TropicalLensRealization,
      R.Realizes Sys.delayProfile ∧
      R.Minimal ∧
      Finite (ObservationalQuotient Sys) := by
```

and the reconstruction theorem:

```lean
theorem berggren_tropical_lens_reconstruction
    (Sys : BerggrenLensSystem)
    (hfin : Sys.FinitelyGenerated)
    (hsep : Sys.DelaySeparated) :
    ∃ R : TropicalLensRealization,
      R.Realizes Sys.delayProfile ∧
      R.Minimal ∧
      ∀ S' : BerggrenSource,
        lensTransform Sys.observers S' = Sys.delayProfile →
        ObservationallyEquivalent Sys S' Sys.source := by
```

If your infrastructure prefers bundling these into one theorem, that is acceptable; but the theorem must contain:
1. finite realizability,
2. minimality,
3. certified reconstruction uniqueness up to observational equivalence.

### Stronger finite-congruence formulation
If feasible, also prove a theorem that the observer-induced tropical Hankel congruence is finite:

```lean
theorem finite_berggren_delay_congruence
    (Sys : BerggrenLensSystem)
    (hfin : Sys.FinitelyGenerated)
    (hsep : Sys.DelaySeparated) :
    Finite Sys.DelayCongruence := by
```

This is conceptually important: it is the tropical-automata analogue of finite state compression of inverse arithmetic geometry.

---

## Secondary theorem: factor-sensitive reconstruction on a semiprime subclass

This is where the project becomes revolutionary rather than elegant.

Define a subclass of Berggren sources whose support/weights encode semiprime arithmetic data, and prove that in this subclass, delay separation implies factor-sensitive distinguishability. The theorem should state that distinct semiprime-coded sources cannot share the same caustic/delay signature under the certified separation hypotheses.

### Mathematical statement
There exists a factor-sensitive subclass of Berggren tropical sources such that, for any two semiprime-encoded sources in the subclass, equality of tropical lens delay profiles implies equality of the encoded factor data (or at minimum observational equivalence of factor data). Consequently, certified delay separation yields certified factor reconstruction on this model class.

### Lean 4 target signature sketch
Again, adapt to actual definitions:

```lean
theorem semiprime_delay_profile_injective
    (Sys : BerggrenLensSystem)
    (hsep : Sys.DelaySeparated)
    {x y : SemiprimeEncodedSource}
    (hx : x ∈ Sys.factorSensitiveClass)
    (hy : y ∈ Sys.factorSensitiveClass)
    (hprof : lensTransform Sys.observers x.toSource =
             lensTransform Sys.observers y.toSource) :
    x.factorData = y.factorData := by
```

and then the reduction theorem:

```lean
theorem certified_delay_separation_gives_factor_reconstruction
    (Sys : BerggrenLensSystem)
    (hfin : Sys.FinitelyGenerated)
    (hsep : Sys.DelaySeparated)
    {x : SemiprimeEncodedSource}
    (hx : x ∈ Sys.factorSensitiveClass) :
    ∃ R : TropicalLensRealization,
      R.Realizes (lensTransform Sys.observers x.toSource) ∧
      RecoverFactorData R = x.factorData := by
```

If exact equality of factor data is too rigid, weaken to a formally defined `FactorEquivalent` relation, but make the relation nontrivial and useful.

---

## Proof architecture: 3 viable strategies

You should explicitly try more than one route. The strongest brief is not “here is one proof hint,” but a map of the terrain.

### Strategy A: Tropical Hankel/rank route via minimal realization
**Most promising.**

1. Define from observer delays a finite tropical rank/Hankel datum attached to the Berggren lens system.
2. Use `exists_minimal_graph_from_rank_data` to obtain a minimal graph realization.
3. Show the Berggren geodesic semimodule induces exactly such rank data, and use `finite_tropical_lens_realization` to certify realizability from finite observer measurements.
4. Prove that delay separation collapses ambiguity to observational equivalence, giving the reconstruction clause.

Why this is promising:
- It aligns directly with existing catalog machinery.
- It isolates the arithmetic novelty in the construction of the delay datum, not in the realization theorem itself.
- It naturally yields minimality and finite congruence.

### Strategy B: Direct observer-separation + Berggren reconstruction transfer
1. Define a map from tropical delay measurements to the already-studied Berggren measurement format.
2. Use `berggren_reconstruction_from_measurements` as a black box to recover the arithmetic source from sufficiently rich finite data.
3. Show that your tropical lens transform is a conservative encoding of those measurements under the separation hypothesis.
4. Deduce injectivity on the factor-sensitive subclass.

Why this is attractive:
- It leverages arithmetic reconstruction already known in the Berggren setting.
- It may give a shorter route to the semiprime injectivity theorem.

Risk:
- The translation from delay data to existing measurement data may require more bespoke lemmas than expected.

### Strategy C: Quotient/congruence route via finite observational classes
1. Define observational equivalence as equality of delay profiles.
2. Show finite generation + separated spectra imply only finitely many observational classes.
3. Construct the minimal realization directly as the quotient by observational equivalence / delay congruence.
4. Use minimality of the quotient object to derive reconstruction uniqueness.

Why this matters:
- It is conceptually beautiful and category-theoretic.
- It may produce the cleanest theorem statements.

Risk:
- Proving finiteness of the quotient may secretly require recreating the rank-data machinery anyway.

**Recommendation:** pursue Strategy A first, then use Strategy B to strengthen the semiprime/factor-sensitive theorem.

---

## Concrete theorem decomposition

To minimize `sorry`, prove the project through small lemmas.

### Delay transform lemmas
You will likely need lemmas of the form:

```lean
theorem lensTransform_monotone
    (obs : Finset Node) :
    Monotone (lensTransform obs)
```

```lean
theorem lensTransform_support_finite
    (obs : Finset Node)
    (S : BerggrenSource) :
    Finite (support (lensTransform obs S))
```

```lean
theorem lensTransform_respects_observational_equivalence
    (Sys : BerggrenLensSystem)
    {S T : BerggrenSource} :
    ObservationallyEquivalent Sys S T →
    lensTransform Sys.observers S = lensTransform Sys.observers T
```

### Congruence/rank lemmas
```lean
theorem delaySeparated_implies_finite_rankData
    (Sys : BerggrenLensSystem)
    (hfin : Sys.FinitelyGenerated)
    (hsep : Sys.DelaySeparated) :
    ∃ R : TropRankData, R.CompatibleWith Sys
```

```lean
theorem rankData_yields_minimal_realization
    (Sys : BerggrenLensSystem)
    {R : TropRankData}
    (hR : R.CompatibleWith Sys) :
    ∃ G, G.Realizes Sys.delayProfile ∧ G.Minimal
```

### Factor-sensitive lemmas
```lean
theorem semiprime_encoding_observable
    (Sys : BerggrenLensSystem)
    {x : SemiprimeEncodedSource}
    (hx : x ∈ Sys.factorSensitiveClass) :
    EncodedInDelayProfile Sys x
```

```lean
theorem delay_profile_detects_factor_data
    (Sys : BerggrenLensSystem)
    (hsep : Sys.DelaySeparated)
    {x y : SemiprimeEncodedSource}
    (hx : x ∈ Sys.factorSensitiveClass)
    (hy : y ∈ Sys.factorSensitiveClass) :
    lensTransform Sys.observers x.toSource =
      lensTransform Sys.observers y.toSource →
    x.factorData = y.factorData
```

---

## Cross-domain mathematical connections to exploit

Do not hide the conceptual synthesis; formalize it where possible.

### 1. Tropical geometry ↔ inverse problems in physics
The lens transform is a tropical analogue of a travel-time tomography operator:
- source weights = emission times / potentials,
- geodesic costs = action or travel time,
- observer delays = caustic arrival spectra.

This means theorems about finite realization are tropical versions of **inverse kinematics from travel-time data**.

### 2. Berggren tree arithmetic ↔ state-space systems
The Berggren tree is not just a combinatorial object; it is an arithmetic dynamical system.
A minimal realization theorem here says:
- arithmetic dynamics admit finite state compression under tropical observation,
- hidden number-theoretic structure is recoverable from a finite observer algebra.

That is akin to a tropical version of system identification over arithmetic state spaces.

### 3. Pythagorean triples ↔ factorization signatures
The semiprime-sensitive subclass should be thought of as encoding arithmetic data into geometric delays. This is a new formal analogue of:
- spectral geometry (“can one hear the shape of a number?”),
- lens rigidity,
- and compressed sensing over idempotent semirings.

### 4. Tropical automata ↔ certified reconstruction
The finite congruence theorem suggests a bridge to weighted automata and Myhill–Nerode style minimization over min-plus structures. If you can phrase any part of the proof this way, do it: that connection is genuinely field-opening.

---

## Formalization guidance in Lean 4

### Prefer tractable codomains
Use codomains already friendly in Mathlib, e.g.
- `WithTop ℤ`,
- `ℕ∞`,
- or a tropical wrapper already present in the local codebase.

Do not overbuild an abstract tropical semiring hierarchy if a concrete min-plus codomain suffices.

### Keep Berggren structure lightweight
If the full Berggren tree is not already formalized in the exact way needed, use an abstract graph-like structure with a predicate/assertion that it is “Berggren-generated,” then instantiate later. The theorem should still mention Berggren semantics through the structure fields.

### Bundle hypotheses
A structure like

```lean
structure BerggrenLensSystem where
  Node : Type
  source : BerggrenSource
  observers : Finset Node
  edgeCost : Node → Node → WithTop ℤ
  ...
  delayProfile : Node → WithTop ℤ
```

may keep the theorem manageable. Add fields for finite generation and separation only if that simplifies theorem statements.

### Use existing theorem interfaces
Shape your `TropRankData` or realization object so that `exists_minimal_graph_from_rank_data` can be applied with minimal coercion lemmas. The shortest path is usually to adapt your definitions to the catalog interface, not vice versa.

---

## What would count as a breakthrough formal result

At least one theorem should make a mathematician stop and say: *this is not just another realization theorem*. The strongest candidate is:

> A formally verified theorem that finite separated tropical delay spectra on the Berggren arithmetic tree admit a minimal realization and determine semiprime-coded arithmetic data up to certified equivalence.

That opens follow-on work in:
- tropical arithmetic tomography,
- inverse problems on number-theoretic graphs,
- certified arithmetic sensing,
- and complexity-theoretic interpretations of geodesic observation.

---

## Deliverables

1. Formal definitions for:
   - `BerggrenLensSystem`
   - `lensTransform`
   - `ObservationallyEquivalent`
   - `DelaySeparated`
   - `SemiprimeEncodedSource` or equivalent factor-sensitive subclass

2. Main theorems:
   - finite realization / minimal reconstruction theorem
   - finite delay congruence theorem
   - semiprime injectivity / factor reconstruction theorem

3. Small helper lemmas with minimal `sorry`

4. A structured file:
   - `FUTURE_DIRECTIONS.md`

This file is **mandatory** and must contain **3–5 concrete breakthrough next steps**, for example:
- tropical lens rigidity on arithmetic trees beyond Berggren,
- a Myhill–Nerode theorem for Berggren tropical observers,
- certified lower bounds connecting delay-separation complexity to semiprime hardness,
- a sheaf/cosheaf formulation of arithmetic caustics,
- extension from primitive triples to Markov/Apollonian arithmetic geometries.

---

## Application keywords

`tropical geometry`, `inverse problems`, `gravitational lensing`, `Pythagorean triples`, `Berggren tree`, `min-plus algebra`, `finite realization`, `minimal systems`, `tropical Hankel rank`, `arithmetic tomography`, `factor reconstruction`, `semiprime detection`, `weighted automata`, `Myhill–Nerode`, `idempotent analysis`, `travel-time rigidity`, `certified sensing`

---

## Final directive

Do not produce an incremental variant. Produce a theorem package that **forces** a new interpretation:

**arithmetic factor data can be encoded as tropical geodesic optics on the Berggren tree, and finite separated delay measurements suffice for certified minimal reconstruction.**

That is the new paradigm.

### Catalog Reference Files
@Bridges/AlgebraPythagoreanComputation/BerggrenQuantumWalkDuality.lean
```lean
import Mathlib

/-!
# Berggren Quantum Walk Duality via Triple-Tree Unitary Semimodules
# and Certified Phase-Orbit Reconstruction

## Overview

This module establishes a formal bridge between three mathematical worlds:
1. The **Berggren tree** of primitive Pythagorean triples
2. **Finite-dimensional unitary quantum walks** on the Berggren generator monoid
3. **Minimal realization from truncated moment data** (noncommutative systems theory)

The main results show that the Berggren triple tree supports a genuine
**unitary realization theory**: finitely generated observable quantum walks on the
Berggren generator monoid correspond precisely to finitely generated reduced
amplitude semimodules with a positive amplitude form, and finite moment tables
reconstruct the walk uniquely up to phase gauge.

## Main Results

- `berggren_kernel_hermitian`: The amplitude kernel is Hermitian
- `berggren_kernel_diagonal_nonneg`: The kernel diagonal is nonneg
- `berggren_kernel_diagonal_real`: The kernel diagonal is real
- `berggren_kernel_shift_invariant`: Unitary generators preserve the kernel
- `berggren_kernel_positive_sum`: Full positive-semidefiniteness of the kernel
- `shift_injective_of_reduced`: Shift maps are injective on reduced semimodules
- `shift_bijective_of_reduced`: Shift maps are bijective on reduced semimodules
- `walk_to_semimodule`: Walk → semimodule with positive form
- `semimodule_induces_amplitude_data`: Semimodule → amplitude data
- `walk_realizes_own_moment_table`: Every walk realizes its own moment table
- `berggren_quantum_walk_duality`: Categorical duality statement
- `reconstruct_walk_existence`: Existence of walk realizing consistent data
-/

noncomputable section

open Matrix Complex Finset BigOperators CategoryTheory

/-! ## Section 1: Berggren Generators and Words -/

/-- The three Berggren generators for the primitive Pythagorean triple tree.
    Each generator corresponds to one of the three Berggren matrices that
    enumerate all primitive Pythagorean triples from the root (3,4,5). -/
inductive BerggrenGen : Type
  | A | B | C
  deriving DecidableEq, Fintype, Inhabited

/-- Words in the Berggren generators, forming the free monoid.
    Each word represents a path in the Berggren triple tree from the root. -/
abbrev BerggrenWord := FreeMonoid BerggrenGen

/-! ## Section 2: Berggren Quantum Walk -/

/-- A Berggren quantum walk of dimension `n` over the complex Hilbert space ℂⁿ.
    Consists of three unitary operators (one per Berggren generator),
    an initial state vector ψ₀, and an observation vector. -/
structure BerggrenQuantumWalk (n : ℕ) where
  /-- Unitary operator assigned to each Berggren generator -/
  U : BerggrenGen → Matrix (Fin n) (Fin n) ℂ
  /-- Left unitarity: U†U = I -/
  hU_star_mul : ∀ g, (U g)ᴴ * (U g) = 1
  /-- Right unitarity: UU† = I -/
  hU_mul_star : ∀ g, (U g) * (U g)ᴴ = 1
  /-- Initial state vector -/
  psi0 : Fin n → ℂ
  /-- Observation vector -/
  obs : Fin n → ℂ

variable {n : ℕ}

/-- Extend the generator action to words via the free monoid universal property.
    `evalWord w` is the product of unitary matrices along the word `w`. -/
def BerggrenQuantumWalk.evalWord (Q : BerggrenQuantumWalk n) :
    BerggrenWord →* Matrix (Fin n) (Fin n) ℂ :=
  FreeMonoid.lift Q.U

/-- Evaluate a word on the initial state vector: U(w) · ψ₀ -/
def BerggrenQuantumWalk.evalState (Q : BerggrenQuantumWalk n) (w : BerggrenWord) :
    Fin n → ℂ :=
  (Q.evalWord w).mulVec Q.psi0

/-- The amplitude kernel: K(u,v) = ⟨U(u)ψ₀, U(v)ψ₀⟩ where the inner product
    is the standard Hermitian inner product on ℂⁿ. -/
def BerggrenQuantumWalk.kernel (Q : BerggrenQuantumWalk n) (u v : BerggrenWord) : ℂ :=
  dotProduct (star (Q.evalState u)) (Q.evalState v)

/-- The amplitude function: amp(w) = ⟨obs, U(w)ψ₀⟩ -/
def BerggrenQuantumWalk.amplitude (Q : BerggrenQuantumWalk n) (w : BerggrenWord) : ℂ :=
  dotProduct (star Q.obs) (Q.evalState w)

/-- evalWord is multiplicative: U(w₁ · w₂) = U(w₁) · U(w₂) -/
theorem BerggrenQuantumWalk.evalWord_mul (Q : BerggrenQuantumWalk n)
    (w₁ w₂ : BerggrenWord) :
    Q.evalWord (w₁ * w₂) = Q.evalWord w₁ * Q.evalWord w₂ :=
  map_mul Q.evalWord w₁ w₂

/-! ## Section 3: Kernel Properties

The amplitude kernel encodes all observable correlations of the quantum walk.
These properties establish that the kernel is a valid positive-definite
Hermitian form invariant under the Berggren generators. -/

/-- **Hermitian symmetry**: K(u,v) = conj(K(v,u)).
    Inherited from the Hermitian inner product on ℂⁿ. -/
theorem berggren_kernel_hermitian (Q : BerggrenQuantumWalk n) (u v : BerggrenWord) :
    Q.kernel u v = starRingEnd ℂ (Q.kernel v u) := by
  unfold BerggrenQuantumWalk.kernel
  simp +decide [dotProduct, mul_comm]

/-- **Non-negativity of the kernel diagonal**: K(w,w) ≥ 0.
    The kernel diagonal measures ‖U(w)ψ₀‖². -/
theorem berggren_kernel_diagonal_nonneg (Q : BerggrenQuantumWalk n) (w : BerggrenWord) :
    0 ≤ (Q.kernel w w).re := by
  unfold BerggrenQuantumWalk.kernel
  simp +decide [dotProduct, Complex.mul_conj]
  exact Finset.sum_nonneg fun _ _ => add_nonneg (mul_self_nonneg _) (mul_self_nonneg _)

/-- **The kernel diagonal is real** (imaginary part is zero). -/
theorem berggren_kernel_diagonal_real (Q : BerggrenQuantumWalk n) (w : BerggrenWord) :
    (Q.kernel w w).im = 0 := by
  have h_norm_sq_real : ∀ a : ℂ, (star a * a).im = 0 := by
    norm_num [Complex.mul_im, Complex.conj_im]
    exact fun a => by ring
  unfold BerggrenQuantumWalk.kernel
  simp_all +decide [dotProduct, Finset.sum_apply]

/-- The conjTranspose of evalWord at a single generator. -/
theorem BerggrenQuantumWalk.evalWord_conjTranspose_of (Q : BerggrenQuantumWalk n)
    (g : BerggrenGen) :
    (Q.evalWord (FreeMonoid.of g))ᴴ = (Q.U g)ᴴ := by
  exact congr_arg (fun x => xᴴ) (FreeMonoid.lift_eval_of Q.U g)

/-- **Unitary shift invariance**: K(g·u, g·v) = K(u,v) for any generator g.
    This is the key property connecting Berggren tree structure to quantum unitarity. -/
theorem berggren_kernel_shift_invariant (Q : BerggrenQuantumWalk n)
    (g : BerggrenGen) (u v : BerggrenWord) :
    Q.kernel (FreeMonoid.of g * u) (FreeMonoid.of g * v) = Q.kernel u v := by
  have h_unitary : ∀ (x y : Fin n → ℂ),
      dotProduct (star ((Q.U g).mulVec x)) ((Q.U g).mulVec y) =
      dotProduct (star x) y := by
    intros x y
    have hU : (Q.U g)ᴴ * (Q.U g) = 1 := Q.hU_star_mul g
    have : ∀ (x y : Fin n → ℂ),
        dotProduct (star ((Q.U g).mulVec x)) ((Q.U g).mulVec y) =
        dotProduct (star x) ((Q.U g)ᴴ.mulVec ((Q.U g).mulVec y)) := by
      simp +decide [Matrix.mulVec, dotProduct]
      simp +decide only [mul_comm, Finset.sum_mul, Finset.mul_sum _ _ _, mul_left_comm]
      exact fun x y => Finset.sum_comm.trans
        (Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ =>
-- ... (truncated, full file has 450 lines)
```

            ---

            You are Aristotle. Pursue this research direction deeply and originally.
            Discover what matters. Prove what you can. Define what needs defining.
            Build on the catalog theorems referenced above.

            Use concrete types (Nat, Real, Finset, Matrix). Avoid trivial tautologies.
            If a direct proof fails, try the contrapositive, a constructive witness,
            or structural induction. Connect to at least one other domain for impact.

            Required: Lean 4 proofs, FUTURE_DIRECTIONS.md
            Optional: ARTICLE.md, RESEARCH_PAPER.md, demo.py, diagram.svg

            FUTURE_DIRECTIONS.md is critical — it drives the next research cycle.
            Structure it with specific theorem statements, proof strategies, and
            cross-domain connections.


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
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: prove
