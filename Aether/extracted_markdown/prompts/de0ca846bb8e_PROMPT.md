

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

## YOUR ASSIGNMENT: Berggren–Lattice Reduction Correspondence for Post-Quantum Trapdoor Geometry

Create a Lean 4 development that turns primitive Pythagorean triples into rank-2 integer lattice bases with certified reduction, canonical decoding, and explicit height/complexity bounds. The file should read as a unified bridge between number theory, lattice cryptography, and certified algorithmics.

### Core mathematical narrative

A primitive triple `(a,b,c)` with `a^2 + b^2 = c^2`, `0 < a`, `0 < b`, `0 < c`, and `Nat.Coprime a b` should determine a rank-2 integer basis whose Gram data remembers the triple. The Berggren generators should act on triples and induce unimodular transformations on these bases. The reduction algorithm should recover a canonical “Berggren word” witnessing how the triple arose from the root triple `(3,4,5)`, and this decoding should come with explicit monotonicity and complexity-height estimates relevant to post-quantum trapdoor geometry.

Bridge: connects arithmetic dynamics on the Berggren tree to Gaussian reduction of 2D lattices, with cryptographic interpretation via trapdoor decoding and certified robustness style complexity bounds.

---

## Required new definitions / structures / instances

Introduce at least the following, with doc comments explicitly mentioning at least one of `quantum`, `post_quantum_security`, `lattice`, `certified`, `trapdoor`, or `Lipschitz`:

```lean
structure PrimitiveTriple where
  a b c : ℤ
  sq_sum : a^2 + b^2 = c^2
  pos_a : 0 < a
  pos_b : 0 < b
  pos_c : 0 < c
  coprime_ab : Int.gcd a b = 1
  odd_oriented : a % 2 = 1

structure TripleLatticeBasis where
  triple : PrimitiveTriple
  basis : Matrix (Fin 2) (Fin 2) ℤ
  gram00 : ((basis 0 0)^2 + (basis 1 0)^2 : ℤ) = triple.c + triple.a
  gram11 : ((basis 0 1)^2 + (basis 1 1)^2 : ℤ) = triple.c - triple.a
  gram01 : (basis 0 0 * basis 0 1 + basis 1 0 * basis 1 1 : ℤ) = triple.b
  det_pos : 0 < Matrix.det basis

inductive BerggrenStep
  | left
  | mid
  | right
deriving DecidableEq, Repr

abbrev BerggrenWord := List BerggrenStep

def BerggrenMatrix : BerggrenStep → Matrix (Fin 3) (Fin 3) ℤ
def berggrenActVec : BerggrenStep → (Fin 3 → ℤ) → (Fin 3 → ℤ)
def tripleVec : PrimitiveTriple → (Fin 3 → ℤ)

def TripleLatticeBasis.height (B : TripleLatticeBasis) : ℕ
def TripleLatticeBasis.detZ (B : TripleLatticeBasis) : ℤ
def TripleLatticeBasis.gram : Matrix (Fin 2) (Fin 2) ℤ
def TripleLatticeBasis.isGaussianReduced (B : TripleLatticeBasis) : Prop

def berggrenWordEval : BerggrenWord → PrimitiveTriple → PrimitiveTriple
def berggrenRoot : PrimitiveTriple
def berggrenDepthBound : PrimitiveTriple → ℕ

def admissibleBasis : TripleLatticeBasis → Prop
def decodeStep : TripleLatticeBasis → Option BerggrenStep
def decodeWord : ℕ → TripleLatticeBasis → BerggrenWord
def canonicalDecode : TripleLatticeBasis → BerggrenWord

def wordCost : BerggrenWord → ℕ
def reductionPotential : TripleLatticeBasis → ℤ
def trapdoorGap : TripleLatticeBasis → ℤ
def quantumCertifiedRadius : TripleLatticeBasis → ℚ
```

Also add at least 5 useful supporting definitions, e.g.
`isPrimitiveVec2`, `isUnimodular2`, `columnNormSq`, `offDiagEnergy`, `slopeCode`, `berggrenParentCandidate`, `decodeInvariant`.

You should provide natural instances where meaningful, e.g.
```lean
instance : Inhabited BerggrenStep
instance : Inhabited PrimitiveTriple
instance : Inhabited TripleLatticeBasis
instance : DecidableEq PrimitiveTriple
```
If some instance is too expensive to derive directly, define manually.

---

## Precise formal targets

You should prove a coherent package of theorems. At minimum include the following theorem statements or stronger variants.

### 1. Structural arithmetic of primitive triples

```lean
theorem primitiveTriple_c_odd (t : PrimitiveTriple) : t.c % 2 = 1

theorem primitiveTriple_a_ne_zero (t : PrimitiveTriple) : t.a ≠ 0

theorem primitiveTriple_b_ne_zero (t : PrimitiveTriple) : t.b ≠ 0

theorem primitiveTriple_c_gt_a (t : PrimitiveTriple) : t.a < t.c

theorem primitiveTriple_c_gt_b (t : PrimitiveTriple) : t.b < t.c

theorem primitiveTriple_norm_gap_pos (t : PrimitiveTriple) : 0 < t.c - t.a

theorem primitiveTriple_sum_gap_pos (t : PrimitiveTriple) : 0 < t.c + t.a
```

Proof ideas: use `nlinarith` on `a^2 + b^2 = c^2`, parity from primitive Pythagorean arithmetic, and positivity. For divisibility/parity lemmas, if `Int.gcd` formulations become cumbersome, derive helper lemmas through coercion to `Nat` when positivity is available.

### 2. Canonical basis attached to Euclid parameters

Define a constructor from Euclid parameters. A robust choice is:
`a = m^2 - n^2`, `b = 2*m*n`, `c = m^2 + n^2`, and basis columns `(m,n)` and `(n,m)` or another symmetric choice whose Gram identities match your `TripleLatticeBasis` definition after a deliberate normalization. If exact equalities need a slightly different Gram encoding, adjust the structure so the identities are mathematically natural and provable.

Required theorem shape:

```lean
def mkPrimitiveTripleOfEuclid
  (m n : ℤ) (hm : 0 < m) (hn : 0 < n) (hmn : n < m)
  (hcop : Int.gcd m n = 1) (hodd : (m - n) % 2 = 1) : PrimitiveTriple

def mkTripleLatticeBasisOfEuclid
  (m n : ℤ) (hm : 0 < m) (hn : 0 < n) (hmn : n < m)
  (hcop : Int.gcd m n = 1) (hodd : (m - n) % 2 = 1) : TripleLatticeBasis

theorem euclid_basis_det_formula
  (m n : ℤ) ... :
  (mkTripleLatticeBasisOfEuclid m n hm hn hmn hcop hodd).detZ = m^2 - n^2

theorem euclid_basis_height_bound
  (m n : ℤ) ... :
  (mkTripleLatticeBasisOfEuclid m n hm hn hmn hcop hodd).height ≤ Int.natAbs (2 * (m^2 + n^2))
```

Bridge: connects classical Euclid parametrization to lattice-basis synthesis, a trapdoor generation primitive.

### 3. Berggren action on triples and induced basis transport

Define the three standard Berggren matrices and prove they preserve primitiveness and positivity under the usual orientation convention.

```lean
theorem berggren_left_preserves_primitive :
  ∀ t : PrimitiveTriple, ∃ t' : PrimitiveTriple,
    tripleVec t' = berggrenActVec BerggrenStep.left (tripleVec t)

theorem berggren_mid_preserves_primitive :
  ∀ t : PrimitiveTriple, ∃ t' : PrimitiveTriple,
    tripleVec t' = berggrenActVec BerggrenStep.mid (tripleVec t)

theorem berggren_right_preserves_primitive :
  ∀ t : PrimitiveTriple, ∃ t' : PrimitiveTriple,
    tripleVec t' = berggrenActVec BerggrenStep.right (tripleVec t)
```

Then define basis transport:
```lean
def transportBasis : BerggrenStep → TripleLatticeBasis → TripleLatticeBasis
```

and prove:

```lean
theorem transportBasis_det_invariant
  (s : BerggrenStep) (B : TripleLatticeBasis) :
  (transportBasis s B).detZ = B.detZ

theorem transportBasis_gram_covariance
  (s : BerggrenStep) (B : TripleLatticeBasis) :
  ∃ U : Matrix (Fin 2) (Fin 2) ℤ,
    Matrix.det U = 1 ∨ Matrix.det U = -1
    ∧ (transportBasis s B).gram = Uᵀ * B.gram * U

theorem berggren_height_monotone
  (s : BerggrenStep) (B : TripleLatticeBasis) :
  B.height ≤ (transportBasis s B).height
```

If the exact covariance formula is easier with a hand-crafted 2×2 matrix for each step, define it explicitly. The determinant invariance should be proved by matrix computation and `ring`/`omega`/`norm_num` style tactics.

### 4. Reduction invariants and Gaussian-style descent

Define a reduction predicate and one-step reducer. Keep the algorithm constructive and finite.

```lean
def reduceOnce : TripleLatticeBasis → TripleLatticeBasis
def reductionMeasure : TripleLatticeBasis → ℕ
```

Prove descent:

```lean
theorem reduceOnce_measure_nonincreasing
  (B : TripleLatticeBasis) :
  reductionMeasure (reduceOnce B) ≤ reductionMeasure B

theorem reduceOnce_measure_strict_of_not_reduced
  (B : TripleLatticeBasis) :
  ¬ B.isGaussianReduced → reductionMeasure (reduceOnce B) < reductionMeasure B

theorem reduction_terminates :
  ∀ B : TripleLatticeBasis, ∃ N : ℕ,
    (Nat.iterate reduceOnce N B).isGaussianReduced
```

A stronger theorem with explicit bound is required:

```lean
theorem reduction_terminates_with_height_bound :
  ∀ B : TripleLatticeBasis, ∃ N : ℕ,
    N ≤ B.height + 1 ∧ (Nat.iterate reduceOnce N B).isGaussianReduced
```

This is where `induction` on `reductionMeasure B` is natural. Use `omega` for linear arithmetic on naturals and `linarith`/`nlinarith` on integer-valued potentials after coercion.

### 5. Parent decoding and canonical Berggren word

Define a parent-selection rule on admissible reduced bases, with proof that every non-root admissible basis has a unique parent step.

```lean
def isRootBasis (B : TripleLatticeBasis) : Prop
def parentBasis : TripleLatticeBasis → Option TripleLatticeBasis
def parentStep : TripleLatticeBasis → Option BerggrenStep
```

Required theorems:

```lean
theorem root_decode_nil :
  ∀ B : TripleLatticeBasis, isRootBasis B → canonicalDecode B = []

theorem nonroot_has_parent
  (B : TripleLatticeBasis) :
  admissibleBasis B → ¬ isRootBasis B →
  ∃ s : BerggrenStep, ∃ P : TripleLatticeBasis,
    parentStep B = some s ∧ parentBasis B = some P

theorem parent_height_strict_drop
  (B P : TripleLatticeBasis) (s : BerggrenStep) :
  admissibleBasis B →
  parentStep B = some s →
  parentBasis B = some P →
  P.height < B.height

theorem canonicalDecode_correct
  (B : TripleLatticeBasis) :
  admissibleBasis B →
  berggrenWordEval (canonicalDecode B) berggrenRoot = B.triple

theorem canonicalDecode_unique
  (B : TripleLatticeBasis) (w : BerggrenWord) :
  admissibleBasis B →
  berggrenWordEval w berggrenRoot = B.triple →
  canonicalDecode B = w
```

This is the centerpiece. If full uniqueness is too strong globally, prove it first under a normal-form hypothesis:
```lean
theorem canonicalDecode_unique_of_reduced ...
```
and then reduce the general case to that theorem via your reduction correctness lemmas.

### 6. Explicit complexity and height bounds

You must state explicit asymptotic-style arithmetic bounds in theorem form, not just prose. Since Lean does not natively formalize Big-O for this development unless you choose to, an acceptable surrogate is a concrete linear or logarithmic inequality on a natural-valued cost.

```lean
theorem canonicalDecode_cost_linear_height
  (B : TripleLatticeBasis) :
  admissibleBasis B →
  wordCost (canonicalDecode B) ≤ B.height + 1

theorem canonicalDecode_cost_log_c
  (B : TripleLatticeBasis) :
  admissibleBasis B →
  ∃ K : ℕ, K ≤ B.height + 1 ∧
    wordCost (canonicalDecode B) ≤ K

theorem berggren_depthBound_le_c
  (t : PrimitiveTriple) :
  berggrenDepthBound t ≤ Int.natAbs t.c

theorem trapdoorGap_positive_on_admissible
  (B : TripleLatticeBasis) :
  admissibleBasis B → 0 < trapdoorGap B

theorem quantumCertifiedRadius_lower_bound
  (B : TripleLatticeBasis) :
  admissibleBasis B →
  ∃ q : ℚ, q = quantumCertifiedRadius B ∧ 0 < q
```

If you can prove stronger estimates such as logarithmic bounds in `c`, do so. A natural route is to show the parent map strictly decreases `c` and decreases height by at least 1.

### 7. Symmetry, involutions, and cryptographic robustness shadows

Include at least several theorems showing the geometry is not arbitrary but canonically symmetric.

```lean
def swapLegs (t : PrimitiveTriple) : PrimitiveTriple
def swapColumns (B : TripleLatticeBasis) : TripleLatticeBasis

theorem swapLegs_involutive : Function.Involutive swapLegs
theorem swapColumns_involutive : Function.Involutive swapColumns

theorem swapColumns_preserves_admissible
  (B : TripleLatticeBasis) :
  admissibleBasis (swapColumns B) ↔ admissibleBasis B

theorem trapdoorGap_swap_invariant
  (B : TripleLatticeBasis) :
  trapdoorGap (swapColumns B) = trapdoorGap B

theorem post_quantum_security_height_witness
  (B : TripleLatticeBasis) :
  admissibleBasis B →
  ∃ n : ℕ, n = B.height ∧ n ≤ wordCost (canonicalDecode B) + B.height
```

The final theorem name should explicitly carry the application keyword.

---

## Suggested proof architecture

### Phase I: arithmetic normalization
1. Prove basic positivity and strict inequalities for primitive triples using `nlinarith` from `a^2 + b^2 = c^2`.
2. Build helper lemmas converting positivity of integers into natural-number statements where `omega` is effective.
3. Prove parity and gcd side lemmas. If exact primitive-triple parity is annoying at the `Int` level, isolate it into a helper theorem with Euclid parameters and use your canonical constructor for the core pipeline.

### Phase II: matrix/lattice packaging
1. Define `gram`, `detZ`, `height`, `columnNormSq`, `offDiagEnergy`.
2. Show your Euclid basis satisfies the Gram identities by direct expansion and `ring`.
3. Prove determinant formulas with `Matrix.det_fin_two`; use `ring_nf`, `linarith`, and `field_simp` only if you introduce rational radii.
4. Establish admissibility criteria ensuring the basis really represents the triple and has positive orientation.

### Phase III: Berggren transport
1. Encode the three 3×3 Berggren matrices explicitly.
2. Prove action identities by finite-coordinate extensionality:
   ```lean
   ext i <;> fin_cases i <;> simp [berggrenActVec, BerggrenMatrix]
   ```
3. Define induced basis transport via the Euclid-parameter shadow or via explicit 2×2 unimodular maps.
4. Prove determinant invariance and Gram covariance by matrix calculation.

### Phase IV: reduction and termination
1. Choose a simple reduction potential, e.g. `height + natAbs offdiag`.
2. Define `reduceOnce` by case split on whether the basis is reduced.
3. Prove strict descent when unreduced. This is a natural place for `by_cases`, `rcases`, `omega`, and `linarith`.
4. Prove termination by well-founded induction on `reductionMeasure`.

### Phase V: decoding correctness
1. Define parent candidates by inspecting reduced shape invariants.
2. Prove existence of a parent for every non-root admissible basis.
3. Prove uniqueness using strict height drop and Berggren tree injectivity.
4. Define `canonicalDecode` using bounded recursion on `height`.
5. Prove correctness by induction on `height`, with the root basis as the base case.

---

## Concrete Lean tactics to diversify proofs

You must use a diverse tactic profile across the file:
- `induction` on `Nat` or recursion depth for `decodeWord` correctness.
- `rcases` on `Option` outputs of `parentBasis` / `parentStep`.
- `by_contra` for uniqueness of parent step or no-cycle lemmas.
- `omega` for natural-number measure inequalities.
- `linarith` / `nlinarith` for quadratic positivity from `a^2 + b^2 = c^2`.
- `ring` / `ring_nf` for determinant and Gram identities.
- `field_simp` if rational certified-radius formulas are introduced.
- `simp`, `norm_num`, `fin_cases`, `aesop?` only as support, not as the sole proof method.

---

## Exact theorem names to include

Include at least these theorem names verbatim, or stronger statements with these names as wrappers:

```lean
primitiveTriple_c_odd
euclid_basis_det_formula
euclid_basis_height_bound
berggren_left_preserves_primitive
berggren_mid_preserves_primitive
berggren_right_preserves_primitive
transportBasis_det_invariant
transportBasis_gram_covariance
berggren_height_monotone
reduceOnce_measure_nonincreasing
reduceOnce_measure_strict_of_not_reduced
reduction_terminates_with_height_bound
nonroot_has_parent
parent_height_strict_drop
canonicalDecode_correct
canonicalDecode_unique
canonicalDecode_cost_linear_height
berggren_depthBound_le_c
trapdoorGap_positive_on_admissible
quantumCertifiedRadius_lower_bound
swapColumns_involutive
trapdoorGap_swap_invariant
post_quantum_security_height_witness
```

Add at least 10 additional nontrivial lemmas around them.

---

## Significance to the research program

This development should formalize a new arithmetic-to-lattice decoding pipeline: primitive Pythagorean orbit dynamics become a certified 2D trapdoor geometry with explicit reduction and decoding guarantees. That is mathematically interesting because it reframes the Berggren tree as a canonical discrete geodesic system on a space of reduced lattice bases. It matters cryptographically because the parent map and canonical decode act like a toy trapdoor inversion algorithm, with exact proofs of correctness and explicit height-cost bounds. It matters algorithmically because the reduction potential and certified radius theorems give a formal analogue of robust decoding margins. It also creates a reusable formal bridge between classical Diophantine parametrization, matrix reduction, and post-quantum lattice language.

Bridge: connects Berggren arithmetic dynamics to Gaussian reduction, trapdoor decoding, and certified robustness style margins.

---

## If a full theorem is too strong

If global uniqueness of `canonicalDecode` is blocked, prove the strongest layered variant:
1. uniqueness for reduced admissible bases;
2. correctness for all admissible bases after `reduceOnce` iteration;
3. a precise conjecture:

```lean
conjecture canonicalDecode_unique_global
  (B : TripleLatticeBasis) (w : BerggrenWord) :
  admissibleBasis B →
  berggrenWordEval w berggrenRoot = B.triple →
  canonicalDecode B = w
```

Only use this fallback if absolutely necessary; prefer a proved theorem.

---

## File-level deliverables

Produce a substantial formalization with:
- 10+ new definitions,
- 20+ theorems,
- 3+ algorithmic functions (`reduceOnce`, `decodeWord`, `canonicalDecode`),
- explicit arithmetic bounds,
- doc comments naming the bridge to `lattice`, `post_quantum_security`, and `quantum` applications.

At the end, include a structured `FUTURE_DIRECTIONS.md` proposing 3–5 concrete next steps such as:
1. extension from rank-2 Berggren trapdoors to higher-dimensional orthogonal-design lattices,
2. certified collision bounds for Berggren-word encodings,
3. tropicalization of reduction potentials,
4. entropy or Holevo-style monotones on reduced-basis dynamics,
5. formal comparison with LLL-style reduction constants.

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
            Formalize a geometric-arithmetic correspondence between finite Berggren-tree orbits of primitive Pythagorean triples and rank-2 lattice bases, proving that Berggren generators act as determinant-preserving basis transforms whose orbit height controls Gaussian-reduction length and shortest-vector distortion. The core target is a constructive theorem: every reduced rank-2 integral lattice basis with odd coprime norm data arises from a bounded Berggren word, and Berggren word length gives explicit approximation bounds for shortest vectors and collision resistance parameters in a Pythagorean trapdoor family. This opens a new route to post-quantum cryptography via Diophantine/geometric invariants rather than standard module lattices.

            ### Precise Mathematical Framing
            Let B be the Berggren semigroup generated by the classical primitive-triple matrices. Associate to each primitive triple (a,b,c) a rank-2 lattice basis matrix L(a,b,c) whose Gram data encodes the Euclidean parametrization a=m^2-n^2, b=2mn, c=m^2+n^2. Prove: (1) Berggren equivariance: for each generator g in B there exists an integral unimodular transform Ug with Gram(L(g·t)) = Ug^T Gram(L(t)) Ug up to canonical normalization; (2) reduction monotonicity: a suitable height H on triples controls basis skew and yields an explicit upper bound on the approximation factor of the shortest primitive lattice vector after reduction; (3) surjectivity onto an odd-coprime reduced subclass: every reduced rank-2 basis with discriminant represented by a primitive sum of two squares corresponds to some primitive triple orbit point; (4) algorithmic decoding: a reduction pipeline recovers a Berggren word from such a basis in polynomial time in log H. This would connect quantum_pythagoras, cryptographic_gravity, and existing Berggren entropy/channel work into an algorithmic trapdoor geometry program. The proof should combine existing Berggren orbit factorization lemmas, matrix action identities, norm monotonicity on primitive triples, and elementary lattice reduction in dimension 2.

            ### Lean 4 Sketch
Define a structure `TripleLatticeBasis` attaching a `Matrix (Fin 2) (Fin 2) ℤ` to a primitive triple together with Gram identities. Prove Berggren generator action lemmas, determinant invariance, and reduction bounds. Then implement a canonical reduction/decode function from admissible bases to Berggren words, with correctness and complexity-height estimates.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `post_quantum_security_via_tropical_gap` : theorem post_quantum_security_via_tropical_gap
     (file: Bridges/QuantumTropicalCore.lean)
  2. `post_quantum_security_bound` : theorem post_quantum_security_bound (cert : PostQuantumHardnessCertificate) :
     (file: Bridges/DifferentialAlgebraicLearning.lean)
  3. `chain_length_bounded` : theorem chain_length_bounded
     (file: Bridges/NoetherianFeatureConvergence.lean)
  4. `post_quantum_query_bound` : theorem post_quantum_query_bound (gap : ℝ) (hgap : 0 < gap) :
     (file: Bridges/SheafConsensus/Core.lean)
  5. `certified_robustness_from_margin_and_lipschitz` : theorem certified_robustness_from_margin_and_lipschitz
     (file: Bridges/HomologicalDeepLearning.lean)

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
