

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

## YOUR ASSIGNMENT: Quantum Pythagorean Trapdoors via Berggren Tree State Preparation and Triple-Norm Collision Bounds

Formalize a finite, fully discrete version of the Berggren tree of primitive Pythagorean triples and use it to build a canonical trapdoor encoding with explicit collision-resistance-style lower bounds and a finite-dimensional “quantum” state-preparation layer over Berggren words. Work over `ℤ`, `ℕ`, finitely supported amplitudes, and finite truncations; avoid heavy analytic Hilbert space machinery unless it becomes genuinely useful.

The central objective is to construct:

1. an inductive word type for the free monoid on the three Berggren generators,
2. a recursive evaluator from words to primitive triples,
3. a canonical encoding theorem showing injectivity of evaluation on the rooted Berggren tree,
4. a quantitative norm-separation theorem for distinct words at their first divergence,
5. a finite-dimensional quantum state-preparation operator induced by word-prefix extension,
6. a trapdoor-style theorem: canonical Berggren encodings are easy to evaluate, structurally hard to collide, and admit explicit lower bounds on triple-distance.

This is a bridge among:
- number theory (primitive Pythagorean triples, gcd, Diophantine parametrization),
- algebra/computation (free monoid actions, matrix semigroups, canonical encodings),
- cryptography (trapdoor/collision language, post_quantum_security heuristics),
- finite quantum formalization (bounded-depth state preparation, norm preservation),
- ML/robustness style geometry (explicit Lipschitz and separation bounds).

Use theorem names and doc comments with explicit application keywords such as:
`quantum`, `post_quantum_security`, `cryptographic`, `lattice`, `certified`, `trapdoor`, `collision`, `robustness`.

---

## CORE DEFINITIONS TO INTRODUCE

You should define at least the following new objects, with doc comments explaining the bridge they create.

### 1. Primitive triple structure
```lean
structure PrimitiveTriple where
  a : ℤ
  b : ℤ
  c : ℤ
  pos_a : 0 < a
  pos_b : 0 < b
  pos_c : 0 < c
  pythagorean : a^2 + b^2 = c^2
  coprime_ab : Int.gcd a b = 1
  odd_odd_even_guard : a % 2 ≠ b % 2
```

If `Int.gcd` is awkward in your local context, introduce a replacement predicate:
```lean
def IntCoprime (x y : ℤ) : Prop := Nat.Coprime x.natAbs y.natAbs
```
and adapt the structure:
```lean
  coprime_ab : IntCoprime a b
```

### 2. Berggren generators
Define the three classical Berggren matrices as integer `3 × 3` matrices:
```lean
abbrev BerggrenMat := Matrix (Fin 3) (Fin 3) ℤ

def berggrenA : BerggrenMat := ...
def berggrenB : BerggrenMat := ...
def berggrenC : BerggrenMat := ...
```

Use the standard matrices
\[
A=\begin{pmatrix}1&-2&2\\2&-1&2\\2&-2&3\end{pmatrix},\;
B=\begin{pmatrix}1&2&2\\2&1&2\\2&2&3\end{pmatrix},\;
C=\begin{pmatrix}-1&2&2\\-2&1&2\\-2&2&3\end{pmatrix}.
\]

### 3. Root triple and vectorization
```lean
def rootTriple : PrimitiveTriple := ...
def tripleVec (t : PrimitiveTriple) : Fin 3 → ℤ := ![t.a, t.b, t.c]
```

Also define a constructor from vectors satisfying the needed properties:
```lean
def vecToPrimitiveTriple? (v : Fin 3 → ℤ) : Option PrimitiveTriple := ...
```
or a predicate-based wrapper if proving totality is simpler.

### 4. Berggren alphabet and words
```lean
inductive BerggrenStep
| A | B | C
deriving DecidableEq, Repr

abbrev BerggrenWord := List BerggrenStep
```

Define the matrix selected by a step:
```lean
def stepMatrix : BerggrenStep → BerggrenMat
```

### 5. Recursive evaluation
Define evaluation both on vectors and on triples:
```lean
def berggrenEvalVec : BerggrenWord → (Fin 3 → ℤ)
| [] => tripleVec rootTriple
| s :: w => stepMatrix s *ᵥ berggrenEvalVec w
```
or, more canonically for list recursion:
```lean
def berggrenFoldMat : BerggrenWord → BerggrenMat
def berggrenEvalVec (w : BerggrenWord) : Fin 3 → ℤ :=
  berggrenFoldMat w *ᵥ tripleVec rootTriple
```

Then package into triples:
```lean
def berggrenEvalTriple : (w : BerggrenWord) → PrimitiveTriple := ...
```
This may require proving preservation lemmas first.

### 6. Prefix / first divergence / depth
```lean
def isPrefix (u v : BerggrenWord) : Prop := ∃ t, v = u ++ t

def firstDivergence (u v : BerggrenWord) : Option (ℕ × BerggrenStep × BerggrenStep) := ...
def wordDepth (w : BerggrenWord) : ℕ := w.length
```

### 7. Triple norms and distances
Define at least two norms:
```lean
def tripleL1 (t : PrimitiveTriple) : ℤ := Int.natAbs t.a + Int.natAbs t.b + Int.natAbs t.c
def tripleMaxNorm (t : PrimitiveTriple) : ℤ := max (Int.natAbs t.a) (max (Int.natAbs t.b) (Int.natAbs t.c))

def tripleDist1 (x y : PrimitiveTriple) : ℤ :=
  Int.natAbs (x.a - y.a) + Int.natAbs (x.b - y.b) + Int.natAbs (x.c - y.c)
```
If needed for order-theoretic bounds, define `ℕ`-valued versions instead.

### 8. Canonical encoding / trapdoor wrappers
```lean
structure BerggrenCode where
  word : BerggrenWord

def encodeTriple : BerggrenWord → PrimitiveTriple := berggrenEvalTriple

def decodeOnImage : PrimitiveTriple → Option BerggrenWord := ...
```
If a total decoder is too ambitious, define a partial decoder on a bounded-depth image:
```lean
def decodeBounded (N : ℕ) : PrimitiveTriple → Option BerggrenWord := ...
```

### 9. Bounded-depth quantum state space
Use finite support over words of length at most `N`:
```lean
def boundedWords (N : ℕ) := {w : BerggrenWord // w.length ≤ N}

def Amp := ℚ

def QuantumBerggrenState (N : ℕ) := boundedWords N → Amp
```
Optionally define support-finiteness explicitly if useful, but bounded words are already finite.

### 10. Prefix-extension operator
Define a finite operator that prepends or appends a step when depth permits:
```lean
def extendState (N : ℕ) (s : BerggrenStep) : QuantumBerggrenState N → QuantumBerggrenState (N+1) := ...
```

Define a finite norm:
```lean
def stateSqNorm {N : ℕ} (ψ : QuantumBerggrenState N) : ℚ := ∑ w, ψ w * ψ w
```
You may need `Fintype` instances for `boundedWords N`; deriving/constructing them is worthwhile infrastructure.

---

## TARGET THEOREMS WITH PRECISE LEAN SHAPES

Prove as many of the following as possible, aiming for at least 20 theorems total, with these as the backbone.

### A. Algebraic and arithmetic preservation

```lean
theorem berggrenA_preserves_cone :
  ∀ v : Fin 3 → ℤ,
    0 < v 0 → 0 < v 1 → 0 < v 2 →
    (v 0)^2 + (v 1)^2 = (v 2)^2 →
    0 < (berggrenA *ᵥ v) 0 ∧
    0 < (berggrenA *ᵥ v) 1 ∧
    0 < (berggrenA *ᵥ v) 2 ∧
    ((berggrenA *ᵥ v) 0)^2 + ((berggrenA *ᵥ v) 1)^2 = ((berggrenA *ᵥ v) 2)^2
```

Similarly for `berggrenB` and `berggrenC`.

```lean
theorem matrix_action_preserves_pythagorean :
  ∀ M : BerggrenMat,
    M = berggrenA ∨ M = berggrenB ∨ M = berggrenC →
    ∀ v : Fin 3 → ℤ,
      (v 0)^2 + (v 1)^2 = (v 2)^2 →
      ((M *ᵥ v) 0)^2 + ((M *ᵥ v) 1)^2 = ((M *ᵥ v) 2)^2
```

```lean
theorem matrix_action_preserves_primitivity :
  ∀ s : BerggrenStep, ∀ t : PrimitiveTriple,
    IntCoprime ((stepMatrix s *ᵥ tripleVec t) 0) ((stepMatrix s *ᵥ tripleVec t) 1)
```

If full coprimality preservation is difficult, prove a weaker but still meaningful version:
```lean
theorem matrix_action_preserves_nontrivial_gcd_barrier :
  ∀ s : BerggrenStep, ∀ t : PrimitiveTriple,
    ¬ (2 ∣ (stepMatrix s *ᵥ tripleVec t) 0 ∧ 2 ∣ (stepMatrix s *ᵥ tripleVec t) 1)
```

### B. Recursive evaluation and positivity

```lean
theorem berggrenEvalVec_nil :
  berggrenEvalVec [] = tripleVec rootTriple
```

```lean
theorem berggrenEvalVec_cons :
  ∀ s w, berggrenEvalVec (s :: w) = stepMatrix s *ᵥ berggrenEvalVec w
```

```lean
theorem berggrenEvalTriple_spec :
  ∀ w : BerggrenWord,
    let t := berggrenEvalTriple w
    in t.a^2 + t.b^2 = t.c^2
```

```lean
theorem berggrenEvalTriple_positive :
  ∀ w : BerggrenWord,
    0 < (berggrenEvalTriple w).a ∧
    0 < (berggrenEvalTriple w).b ∧
    0 < (berggrenEvalTriple w).c
```

### C. Strict growth and complexity bounds

Prove explicit monotonicity of the hypotenuse.

```lean
theorem hypotenuse_strict_mono_step :
  ∀ s : BerggrenStep, ∀ t : PrimitiveTriple,
    t.c < (berggrenEvalTriple [s]).c := by
```
This exact shape may be awkward because the RHS ignores `t`; more useful is:

```lean
def actOnTriple (s : BerggrenStep) (t : PrimitiveTriple) : PrimitiveTriple := ...

theorem hypotenuse_strict_mono_step :
  ∀ s : BerggrenStep, ∀ t : PrimitiveTriple,
    t.c < (actOnTriple s t).c
```

Then derive by induction:
```lean
theorem hypotenuse_depth_lower_bound :
  ∀ w : BerggrenWord,
    (wordDepth w : ℤ) + rootTriple.c ≤ (berggrenEvalTriple w).c
```

Strengthen if possible to an exponential lower bound using the minimal growth factor among generators:
```lean
theorem hypotenuse_exponential_lower_bound :
  ∃ α : ℕ, 1 < α ∧
  ∀ w : BerggrenWord,
    α ^ wordDepth w ≤ Int.natAbs (berggrenEvalTriple w).c
```
If a uniform exponential base is difficult globally, prove a linear lower bound and a branchwise exponential bound.

Also include algorithmic cost:
```lean
theorem berggrenEval_time_bound_informal_shape :
  ∀ w : BerggrenWord,
    ∃ K : ℕ, K = 9 * w.length + 3
```
Better: define a symbolic cost model.
```lean
def evalCost (w : BerggrenWord) : ℕ := 9 * w.length + 3

theorem evalCost_linear :
  ∀ w, evalCost w = O(w.length)
```
Since asymptotic notation may be cumbersome, it is acceptable to state explicit linear formulas instead of Landau notation.

### D. Injectivity / unique path theorem

This is a major theorem and should be made as precise as possible.

```lean
theorem berggren_eval_injective_on_root :
  Function.Injective berggrenEvalTriple
```

If proving full injectivity directly is too hard, split it:

```lean
theorem berggren_children_pairwise_distinct :
  let tA := actOnTriple BerggrenStep.A rootTriple
  let tB := actOnTriple BerggrenStep.B rootTriple
  let tC := actOnTriple BerggrenStep.C rootTriple
  in tA ≠ tB ∧ tA ≠ tC ∧ tB ≠ tC
```

```lean
theorem berggren_prefix_separation :
  ∀ {u v : BerggrenWord},
    u ≠ v →
    berggrenEvalTriple u ≠ berggrenEvalTriple v
```

A productive route is to prove a left-cancellation / parent uniqueness theorem:
```lean
def berggrenParentCandidates (t : PrimitiveTriple) : Finset PrimitiveTriple := ...

theorem berggren_nonroot_has_unique_parent :
  ∀ t : PrimitiveTriple,
    t ≠ rootTriple →
    ∃! p : PrimitiveTriple, ∃ s : BerggrenStep, actOnTriple s p = t
```
Then deduce injectivity by induction on hypotenuse.

### E. First divergence and collision lower bounds

Define a first-divergence index and prove a norm-separation theorem with explicit constants.

```lean
theorem first_divergence_exists :
  ∀ {u v : BerggrenWord},
    u ≠ v →
    ∃ k, k ≤ u.length ∧ k ≤ v.length ∧
      u.take k = v.take k ∧
      (k = u.length ∨ k = v.length ∨ u.get? k ≠ v.get? k)
```

Now formulate the collision lower bound:
```lean
theorem first_divergence_norm_lower_bound :
  ∀ {u v : BerggrenWord},
    u ≠ v →
    ∃ k : ℕ, ∃ C : ℕ,
      u.take k = v.take k ∧
      tripleDist1 (berggrenEvalTriple u) (berggrenEvalTriple v) ≥ C
```

This is too weak to be useful; strengthen to a depth-sensitive lower bound:
```lean
theorem first_divergence_norm_lower_bound_explicit :
  ∀ {p s₁ s₂ u v},
    s₁ ≠ s₂ →
    let w₁ := p ++ s₁ :: u
    let w₂ := p ++ s₂ :: v
    tripleDist1 (berggrenEvalTriple w₁) (berggrenEvalTriple w₂) ≥
      Int.natAbs (berggrenEvalTriple p).c
```
or a constant multiple thereof. Even a simpler positive lower bound
```lean
... ≥ 2
```
is meaningful, but a prefix-dependent lower bound is much better.

Then connect to collision resistance:
```lean
theorem berggren_trapdoor_no_exact_collision :
  ∀ {u v : BerggrenWord},
    berggrenEvalTriple u = berggrenEvalTriple v → u = v
```

```lean
theorem berggren_post_quantum_security_gap :
  ∀ {u v : BerggrenWord},
    u ≠ v →
    1 ≤ tripleDist1 (berggrenEvalTriple u) (berggrenEvalTriple v)
```

### F. Bounded-depth decoding and finite search

For bounded depth, exact inversion is feasible and useful.

```lean
def wordsOfDepthLE : ℕ → Finset BerggrenWord := ...

theorem mem_wordsOfDepthLE_iff :
  ∀ {N w}, w ∈ wordsOfDepthLE N ↔ w.length ≤ N
```

```lean
def decodeBounded (N : ℕ) (t : PrimitiveTriple) : Option BerggrenWord :=
  ((wordsOfDepthLE N).find? fun w => berggrenEvalTriple w = t)
```

```lean
theorem decodeBounded_sound :
  ∀ {N t w},
    decodeBounded N t = some w →
    berggrenEvalTriple w = t
```

```lean
theorem decodeBounded_complete :
  ∀ {N w},
    w.length ≤ N →
    decodeBounded N (berggrenEvalTriple w) = some w
```

This theorem is a strong finite trapdoor/canonical encoding statement.

### G. Finite quantum state preparation theorems

Work in finite-dimensional amplitude spaces over `ℚ` or `ℝ`. If `ℚ` is easier for exact equality, use it.

```lean
instance boundedWordsFintype (N : ℕ) : Fintype (boundedWords N) := ...
instance boundedWordsDecidableEq (N : ℕ) : DecidableEq (boundedWords N) := ...
```

Define basis states:
```lean
def basisState (N : ℕ) (w : boundedWords N) : QuantumBerggrenState N := ...
```

Norm and extension:
```lean
def stateSqNorm {N : ℕ} (ψ : QuantumBerggrenState N) : ℚ := ∑ w, ψ w * ψ w

def appendStep
  (N : ℕ) (s : BerggrenStep) :
  QuantumBerggrenState N → QuantumBerggrenState (N+1) := ...
```

Then prove finite “unitarity-like” exact preservation on basis-orthogonal embeddings:
```lean
theorem appendStep_basis_injective :
  ∀ (N : ℕ) (s : BerggrenStep),
    Function.Injective (fun w : boundedWords N => ?liftedWord)
```
where `?liftedWord` appends `s`.

```lean
theorem berggren_path_quantum_norm_preserved :
  ∀ (N : ℕ) (s : BerggrenStep) (ψ : QuantumBerggrenState N),
    stateSqNorm (appendStep N s ψ) = stateSqNorm ψ
```

For repeated extension along a word:
```lean
def prepareAlongWord : ∀ {N : ℕ}, BerggrenWord → QuantumBerggrenState N → QuantumBerggrenState (N + wordDepth ?w) := ...
```
If dependent indices become awkward, specialize to basis states or define on a large enough ambient depth.

A more feasible theorem:
```lean
theorem berggren_path_unitary_on_bounded_depth :
  ∀ (N : ℕ) (w : BerggrenWord),
    w.length ≤ N →
    ∀ ψ : QuantumBerggrenState (N - w.length),
      stateSqNorm (prepareByAppending w ψ) = stateSqNorm ψ
```

Also connect amplitudes to triple images:
```lean
def pushforwardToTriples (N : ℕ) (ψ : QuantumBerggrenState N) : PrimitiveTriple → ℚ := ...
```
Then prove image support is bounded:
```lean
theorem pushforward_support_depth_bounded :
  ∀ {N ψ t},
    pushforwardToTriples N ψ t ≠ 0 →
    ∃ w : BerggrenWord, w.length ≤ N ∧ berggrenEvalTriple w = t
```

### H. Lipschitz / certified robustness style bounds

To connect to ML/certified robustness, define a metric on words and prove evaluation is Lipschitz into triple norms with explicit constants on bounded depth.

```lean
def wordHammingOnCommonPrefix (u v : BerggrenWord) : ℕ := ...
```

```lean
theorem berggren_eval_bounded_depth_lipschitz_certified_robustness :
  ∀ N, ∃ K : ℕ,
    ∀ u v : BerggrenWord,
      u.length ≤ N →
      v.length ≤ N →
      tripleDist1 (berggrenEvalTriple u) (berggrenEvalTriple v) ≤
        K * (wordDepth u + wordDepth v + 1)
```
Even a coarse bound is acceptable if explicit. This theorem matters because it recasts canonical arithmetic encodings as certified finite feature maps.

---

## PROOF STRATEGY BLUEPRINT

### Strategy A: direct matrix arithmetic + induction on words
This is the primary route and likely the best balance of rigor and feasibility.

1. **Hard-code the Berggren matrices** and prove their action preserves the quadratic form
   \[
   Q(a,b,c)=a^2+b^2-c^2.
   \]
   In Lean, expand matrix-vector multiplication coordinatewise and verify by `ring`, `omega`, `linarith`, and explicit arithmetic normalization. Small helper lemmas for each coordinate will help.

2. **Establish positivity and hypotenuse growth** for each generator on positive triples.
   Compute the transformed coordinates explicitly:
   - for `A`, `c' = 2a - 2b + 3c`,
   - for `B`, `c' = 2a + 2b + 3c`,
   - for `C`, `c' = -2a + 2b + 3c`.
   Use the facts `0 < a`, `0 < b`, `a < c`, `b < c` derivable from `a^2 + b^2 = c^2`. Prove auxiliary lemmas:
   ```lean
   theorem leg_lt_hypotenuse_left  (t : PrimitiveTriple) : t.a < t.c := ...
   theorem leg_lt_hypotenuse_right (t : PrimitiveTriple) : t.b < t.c := ...
   ```
   These are excellent places to use `nlinarith`.

3. **Define `actOnTriple`** and prove recursion theorems for words.
   Then obtain positivity and Pythagorean preservation by induction on `w`, using `rcases` on the head step.

4. **Prove injectivity via unique parent / strict hypotenuse descent**.
   The strongest path is to define inverse parent formulas for primitive triples and show exactly one applies. But if that is too long, bounded-depth injectivity can be proved by finite search plus hypotenuse growth. A good intermediate theorem is:
   ```lean
   theorem berggren_children_disjoint_from_prefix :
     ∀ p u v s₁ s₂, s₁ ≠ s₂ →
       berggrenEvalTriple (p ++ s₁ :: u) ≠ berggrenEvalTriple (p ++ s₂ :: v)
   ```
   Use explicit coordinate formulas after factoring out the common prefix action.

5. **Lift injectivity to cryptographic collision statements and bounded decoder correctness**.
   The decoder can simply search the finite set of words up to depth `N`; injectivity turns search correctness into exact inversion.

### Strategy B: parent-recovery / descent on hypotenuse
This is more elegant and potentially more revolutionary if successful.

1. Prove every non-root primitive triple has a unique predecessor under one Berggren inverse branch.
2. Show predecessor hypotenuse is strictly smaller.
3. Recover the unique word by repeated descent to `(3,4,5)`.
4. Conclude injectivity, canonical encoding, and bounded decoding as corollaries.

This is aesthetically superior because it exhibits the Berggren tree as a genuine arithmetic normal form, which is exactly the trapdoor/canonical-encoding narrative. Use it if manageable.

### Strategy C: finite quantum layer via combinatorial isometries
For the quantum section, avoid analysis.

1. Model states as functions on finite bounded word spaces.
2. Define append/prepend maps induced by injective maps on basis labels.
3. Prove exact norm preservation by reindexing finite sums over an injective image.
4. Interpret this as a finite “unitary-like” state preparation operator.

This is the right level of formalization: exact, algebraic, and computational.

---

## KEY HELPER LEMMAS TO PROVE EARLY

These lemmas will unlock the rest:

```lean
theorem rootTriple_fields :
  rootTriple.a = 3 ∧ rootTriple.b = 4 ∧ rootTriple.c = 5
```

```lean
theorem rootTriple_pythagorean :
  rootTriple.a^2 + rootTriple.b^2 = rootTriple.c^2
```

```lean
theorem primitive_leg_lt_hypotenuse :
  ∀ t : PrimitiveTriple, t.a < t.c ∧ t.b < t.c
```

```lean
theorem stepMatrix_coord_formula_A :
  ∀ t : PrimitiveTriple,
    berggrenA *ᵥ tripleVec t =
      ![t.a - 2*t.b + 2*t.c, 2*t.a - t.b + 2*t.c, 2*t.a - 2*t.b + 3*t.c]
```
and similarly for `B`, `C`.

```lean
theorem actOnTriple_c_formula :
  ∀ s t, ∃ x y : ℤ,
    (actOnTriple s t).c = x * t.a + y * t.b + 3 * t.c
```

```lean
theorem actOnTriple_hypotenuse_growth_margin :
  ∀ s t : _, (actOnTriple s t).c - t.c ≥ 1
```

```lean
theorem berggrenEval_depth_growth :
  ∀ w : BerggrenWord,
    rootTriple.c + w.length ≤ (berggrenEvalTriple w).c
```

```lean
theorem append_step_length :
  ∀ w s, wordDepth (w ++ [s]) = wordDepth w + 1
```

```lean
theorem first_divergence_prefix_factorization :
  ∀ {u v},
    u ≠ v →
    ∃ p s₁ s₂ r₁ r₂,
      s₁ ≠ s₂ ∧
      u = p ++ s₁ :: r₁ ∧
      v = p ++ s₂ :: r₂
      ∨ isPrefix u v ∨ isPrefix v u
```

```lean
theorem boundedWords_nonempty : ∀ N, Nonempty (boundedWords N)
```

```lean
theorem stateSqNorm_basis :
  ∀ N (w : boundedWords N), stateSqNorm (basisState N w) = 1
```

```lean
theorem basis_orthogonality_indicator :
  ∀ N (u v : boundedWords N), u ≠ v →
    basisState N u v = 0
```

---

## TACTICAL REQUIREMENTS

Use diverse proof styles across the file:
- `induction` on `BerggrenWord`,
- `rcases` and `cases` on `BerggrenStep`,
- `by_contra` for collision impossibility or parent uniqueness,
- `linarith` / `nlinarith` for inequalities from `a^2 + b^2 = c^2`,
- `omega` for natural-number length arithmetic,
- `field_simp` if any rational amplitude normalization is introduced,
- `ring` / `ring_nf` for coordinate identities,
- `simp` only as support, not the main engine.

Prefer typeclass abstraction where natural:
```lean
variable {R : Type*} [LinearOrderedRing R]
```
for generic quadratic-form lemmas if they simplify the integer proofs, then instantiate at `ℤ`. But keep the main arithmetic/triple theorems concrete over `ℤ` if generic abstraction becomes too costly.

---

## SIGNIFICANCE AND RESEARCH DIRECTION INSIDE THE FILE

The file should make explicit, in doc comments and theorem names, that this formalization creates a new arithmetic-combinatorial infrastructure:

1. **Canonical arithmetic state spaces**: Berggren words provide a free-monoid coordinate system for primitive triples.
2. **Post-quantum cryptographic geometry**: injective evaluation plus explicit norm separation gives a rigorous toy model of trapdoor-free collision resistance on structured arithmetic objects.
3. **Finite quantum state preparation**: bounded-depth word superpositions yield exact combinatorial analogues of unitary state preparation.
4. **Certified robustness viewpoint**: explicit lower/upper bounds on triple distances under word perturbations resemble discrete Lipschitz/certified-robustness guarantees for symbolic models.
5. **Bridge to open problems**: this infrastructure can later support counting, entropy, spectral growth, random walks on Berggren trees, and arithmetic hash constructions.

Use doc comments like:
- `Bridge: connects Diophantine tree geometry to post_quantum_security.`
- `Bridge: connects finite quantum state preparation to canonical arithmetic encodings.`
- `Bridge: connects certified robustness style Lipschitz bounds to Pythagorean triple generation.`

---

## MINIMUM DELIVERABLE SHAPE

Aim for a substantial formal development with:
- 10+ new definitions,
- 20+ proved theorems/lemmas,
- at least one injectivity theorem,
- at least one explicit quantitative lower bound,
- at least one bounded decoder correctness theorem,
- at least one finite quantum norm-preservation theorem,
- zero `sorry`.

If the full global injectivity theorem is too difficult, the fallback target is:

```lean
theorem berggren_eval_injective_bounded_depth :
  ∀ N, Function.Injective (fun w : boundedWords N => berggrenEvalTriple w.1)
```

plus
```lean
theorem decodeBounded_complete :
  ∀ {N} (w : boundedWords N),
    decodeBounded N (berggrenEvalTriple w.1) = some w.1
```

and a strong explicit branch-separation result:
```lean
theorem first_divergence_norm_lower_bound_bounded :
  ∀ {N} {u v : boundedWords N},
    u.1 ≠ v.1 →
    1 ≤ tripleDist1 (berggrenEvalTriple u.1) (berggrenEvalTriple v.1)
```

---

## FUTURE_DIRECTIONS.md

Also produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, such as:
1. parent-recovery algorithm and full canonical decoder for all primitive triples,
2. entropy/counting theorems for Berggren spheres by hypotenuse,
3. arithmetic hash families from Berggren encodings with certified collision gaps,
4. random-walk / quantum-walk mixing on bounded Berggren trees,
5. tropical or lattice embeddings of primitive triples for post-quantum constructions.

Be precise: each future direction should name the next theorem, structure, or algorithm to formalize.

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
            Formalize a cryptographic primitive built from the Berggren tree of primitive Pythagorean triples, where keys are paths in the tree, public instances are matrix-generated triples with controlled norm growth, and security is tied to the difficulty of recovering short ancestor paths from large hypotenuse data. Prove that Berggren generators act injectively on primitive triples, that path composition yields a canonical normal form, and that hypotenuse/norm growth gives a one-wayness surrogate and collision bound. Then connect this arithmetic tree structure to quantum computation by defining a reversible state-preparation map on path labels and proving orthogonality/separation bounds for distinct path states. This opens a concrete route toward a formally verified arithmetic-quantum cryptographic framework distinct from existing tropical and LWE tracks.

            ### Precise Mathematical Framing
            Let B1,B2,B3 be the classical Berggren matrices acting on primitive triples t=(a,b,c). Define eval : FreeMonoid({1,2,3}) -> Triple -> Triple by word action, and root t0=(3,4,5). Target results: (1) injectivity/canonical encoding: eval w t0 = eval w' t0 implies w = w'; (2) monotone growth: for nonempty w, hypotenuse(eval w t0) > hypotenuse(t0), with explicit multiplicative lower bounds along each generator; (3) collision separation: if w != w', then ||eval w t0 - eval w' t0||_2 is bounded below in terms of the first branching depth; (4) trapdoor inversion on bounded depth: ancestor recovery is polynomial-time given the path trapdoor but combinatorially explosive without it; (5) reversible quantum encoding: define U_B on basis states |w>|t0> = |w>|eval w t0>, prove isometricity on bounded-depth subspaces from injectivity, and derive distinguishability bounds for superpositions over distinct path sets. This creates a rigorously provable arithmetic analogue of trapdoor state generation, leveraging Pythagorean and computation infrastructure while avoiding previously attempted Berggren lattice cryptography and Diophantine quantum walks. The core proof tactics are matrix semigroup normal forms, primitive-triple invariants, norm inequalities, and finite-dimensional linear algebra on path-indexed Hilbert spaces.

            ### Lean 4 Sketch
Likely feasible by defining an inductive type for BerggrenWord, a structure PrimitiveTriple with proof a^2 + b^2 = c^2 and gcd conditions, 3 explicit integer matrices in Matrix (Fin 3) (Fin 3) Z, and recursive eval. Key lemmas should include matrix_action_preserves_primitivity, berggren_eval_injective_on_root, hypotenuse_strict_mono, first_divergence_norm_lower_bound, and berggren_path_unitary_on_bounded_depth. Quantum part can be done first on finitely supported functions over words/triples, avoiding full analytic QM.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `tropical_security_from_norm_bound` : theorem tropical_security_from_norm_bound {n m : ℕ} [NeZero n] [NeZero m]
     (file: Tropical/RieszRepresentation/Applications.lean)
  2. `berggren_stabilizer_generators_bound` : theorem berggren_stabilizer_generators_bound (m : ℕ) :
     (file: Cryptography/BerggrenSymplecticCodes.lean)
  3. `tropical_owf_collision_bound` : theorem tropical_owf_collision_bound (m n B : ℕ) (hlt : m < n) (hB : 0 < B) :
     (file: Cryptography/PostIdempotentCrypto.lean)
  4. `tropical_security_dimension_bound` : theorem tropical_security_dimension_bound (params : TropicalOWFSecurity)
     (file: Cryptography/TropicalOneWayFoundations.lean)
  5. `berggren_normal_form_exists_unique` : theorem berggren_normal_form_exists_unique (t : ℤ × ℤ × ℤ) :
     (file: Cryptography/Freeness.lean)

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



Recent successful concepts: tropical_cryptography_breakthrough_bridge, Foundations of Information-Theoretic Shared Structures, Foundations of Information-Theoretic Shared Structures


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

Research domain: Cryptography
Research mode: formalize
