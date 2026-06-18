

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

## FILE TARGETS

Create at least two new Lean files, with the first one carrying the core formalization and the second one extracting algorithmic / cross-domain consequences.

1. `Pythagorean/BerggrenGroupoid.lean`
2. `Bridges/BerggrenChronometricEntropy.lean`

The first file should be self-contained enough to compile with Mathlib imports for matrices, integers, gcd, lists / free monoids, and basic order / arithmetic automation. The second file should reuse the first and package computational bounds and “Bridge” theorems with explicit quantum / cryptographic / certified-robustness vocabulary in theorem names and doc comments.

You must produce a complete mathematical narrative: definitions, examples, preservation lemmas, monotonicity lemmas, branch-separation lemmas, rooted injectivity, and a word-uniqueness theorem. If a full free-monoid equivalence is too strong globally, prove the strongest rooted-orbit uniqueness theorem with exact hypotheses and state the remaining conjecture precisely.

---

## CORE DEFINITIONS AND EXACT LEAN TARGETS

Work with triples as `Fin 3 → ℤ` to match `Matrix (Fin 3) (Fin 3) ℤ`.

### Primitive data

Define the three Berggren matrices exactly:

```lean
def berggrenA : Matrix (Fin 3) (Fin 3) ℤ
def berggrenB : Matrix (Fin 3) (Fin 3) ℤ
def berggrenC : Matrix (Fin 3) (Fin 3) ℤ
```

Use the classical matrices
\[
A=\begin{pmatrix}
1&-2&2\\
2&-1&2\\
2&-2&3
\end{pmatrix},\quad
B=\begin{pmatrix}
1&2&2\\
2&1&2\\
2&2&3
\end{pmatrix},\quad
C=\begin{pmatrix}
-1&2&2\\
-2&1&2\\
-2&2&3
\end{pmatrix}.
\]

Define the quadratic form:

```lean
def pythagoreanForm (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2
```

Define positivity / normalization predicates:

```lean
def IsPositiveTriple (v : Fin 3 → ℤ) : Prop := 0 < v 0 ∧ 0 < v 1 ∧ 0 < v 2
def IsSortedLegTriple (v : Fin 3 → ℤ) : Prop := v 0 ≤ v 1
def IsPythagoreanTriple (v : Fin 3 → ℤ) : Prop := pythagoreanForm v = 0
def IsPrimitiveTriple (v : Fin 3 → ℤ) : Prop := Int.gcd (Int.gcd (v 0) (v 1)) (v 2) = 1
def IsRootedPrimitiveTriple (v : Fin 3 → ℤ) : Prop :=
  IsPositiveTriple v ∧ IsSortedLegTriple v ∧ IsPythagoreanTriple v ∧ IsPrimitiveTriple v
```

Define the root triple:

```lean
def rootTriple : Fin 3 → ℤ
```

with values `(3,4,5)` in sorted-leg order.

Define matrix action:

```lean
def berggrenAct (M : Matrix (Fin 3) (Fin 3) ℤ) (v : Fin 3 → ℤ) : Fin 3 → ℤ :=
  M.mulVec v
```

Define the alphabet and word action. Prefer a bespoke finite alphabet plus a recursive action, even if you also provide a `FreeMonoid` wrapper.

```lean
inductive BerggrenLetter
| A | B | C
deriving DecidableEq, Repr

def BerggrenLetter.toMatrix : BerggrenLetter → Matrix (Fin 3) (Fin 3) ℤ
def berggrenWordAct : List BerggrenLetter → (Fin 3 → ℤ) → (Fin 3 → ℤ)
```

with recursion
```lean
| [], v => v
| l :: w, v => berggrenWordAct w (berggrenAct l.toMatrix v)
```
or the reverse convention, but state composition lemmas clearly.

Define height / complexity observables needed for rooted freeness:

```lean
def hypotenuse (v : Fin 3 → ℤ) : ℤ := v 2
def legGap (v : Fin 3 → ℤ) : ℤ := v 1 - v 0
def wordCost (w : List BerggrenLetter) : ℕ := w.length
```

Define branch tags and inverse-selection heuristics for disjointness proofs:

```lean
def BerggrenBranchTag (v : Fin 3 → ℤ) : Option BerggrenLetter
def hasUniqueParentCandidate (v : Fin 3 → ℤ) : Prop
```

You should also define at least 5 additional utility structures / predicates with algorithmic meaning, for example:

```lean
def IsChronometricState (v : Fin 3 → ℤ) : Prop := IsRootedPrimitiveTriple v
def EntropyLikeHeight (v : Fin 3 → ℤ) : ℤ := Int.natAbs (v 2 - v 1 - v 0)
def CertifiedOrbitRadius (w : List BerggrenLetter) : ℕ := w.length
def PostQuantumLatticeShadow (v : Fin 3 → ℤ) : ℤ := v 0 + v 1 + v 2
def LipschitzShadow (M : Matrix (Fin 3) (Fin 3) ℤ) : ℕ := ...
```

The exact formulas may be simple, but they must support proved bounds.

---

## REQUIRED THEOREMS: EXACT TARGET SHAPE

You should prove at least 20 theorems, and at minimum the following 12 core theorems.

### 1. Root triple certification

```lean
theorem rootTriple_pythagorean : IsPythagoreanTriple rootTriple
theorem rootTriple_primitive : IsPrimitiveTriple rootTriple
theorem rootTriple_positive : IsPositiveTriple rootTriple
theorem rootTriple_sorted : IsSortedLegTriple rootTriple
theorem rootTriple_rooted : IsRootedPrimitiveTriple rootTriple
```

Use `native_decide`, `norm_num`, `ring_nf`, and explicit `simp` on `rootTriple`.

### 2. Determinant / SL(3,ℤ)-semantics

```lean
theorem det_berggrenA : berggrenA.det = 1
theorem det_berggrenB : berggrenB.det = 1
theorem det_berggrenC : berggrenC.det = 1
```

Also provide the semantic package theorem:

```lean
theorem berggren_matrices_in_SL3_semantics :
  berggrenA.det = 1 ∧ berggrenB.det = 1 ∧ berggrenC.det = 1
```

If useful, prove explicit inverse candidates over `ℤ` or `ℚ`, but determinant 1 is the mandatory semantic bridge.

### 3. Quadratic-form preservation

For each matrix separately:

```lean
theorem berggrenA_preserves_pythagoreanForm (v : Fin 3 → ℤ) :
  pythagoreanForm (berggrenAct berggrenA v) = pythagoreanForm v

theorem berggrenB_preserves_pythagoreanForm (v : Fin 3 → ℤ) :
  pythagoreanForm (berggrenAct berggrenB v) = pythagoreanForm v

theorem berggrenC_preserves_pythagoreanForm (v : Fin 3 → ℤ) :
  pythagoreanForm (berggrenAct berggrenC v) = pythagoreanForm v
```

Then derive:

```lean
theorem berggrenAct_preserves_pythagorean
  (M : Matrix (Fin 3) (Fin 3) ℤ)
  (hM : M = berggrenA ∨ M = berggrenB ∨ M = berggrenC)
  {v : Fin 3 → ℤ} :
  IsPythagoreanTriple v → IsPythagoreanTriple (berggrenAct M v)
```

The proof should explicitly use matrix-coordinate expansion, `fin_cases`, `ring_nf`, and not merely a black-box decision procedure.

### 4. Primitivity preservation

Prove each branch preserves gcd-1:

```lean
theorem berggrenA_preserves_primitivity {v : Fin 3 → ℤ} :
  IsPrimitiveTriple v → IsPrimitiveTriple (berggrenAct berggrenA v)

theorem berggrenB_preserves_primitivity {v : Fin 3 → ℤ} :
  IsPrimitiveTriple v → IsPrimitiveTriple (berggrenAct berggrenB v)

theorem berggrenC_preserves_primitivity {v : Fin 3 → ℤ} :
  IsPrimitiveTriple v → IsPrimitiveTriple (berggrenAct berggrenC v)
```

Recommended route: prove a general lemma that a unimodular integer matrix preserves the gcd ideal generated by coordinates, then instantiate. If that abstraction is too heavy, prove divisibility both directions using explicit inverse linear combinations. This is a place to use `rcases`, divisibility lemmas, and `by_contra`.

A useful exact target if you can support it:

```lean
def TripleContent (v : Fin 3 → ℤ) : ℤ := Int.gcd (Int.gcd (v 0) (v 1)) (v 2)

theorem berggrenA_preserves_content (v : Fin 3 → ℤ) :
  TripleContent (berggrenAct berggrenA v) = TripleContent v
```

and similarly for `B`, `C`.

### 5. Positivity and strict hypotenuse growth

For rooted positive primitive triples, each branch should remain rooted and strictly increase hypotenuse.

```lean
theorem berggrenA_preserves_rooted {v : Fin 3 → ℤ} :
  IsRootedPrimitiveTriple v → IsRootedPrimitiveTriple (berggrenAct berggrenA v)

theorem berggrenB_preserves_rooted {v : Fin 3 → ℤ} :
  IsRootedPrimitiveTriple v → IsRootedPrimitiveTriple (berggrenAct berggrenB v)

theorem berggrenC_preserves_rooted {v : Fin 3 → ℤ} :
  IsRootedPrimitiveTriple v → IsRootedPrimitiveTriple (berggrenAct berggrenC v)
```

And the key monotonicity lemmas:

```lean
theorem berggrenA_hypotenuse_strictly_grows {v : Fin 3 → ℤ} :
  IsPositiveTriple v → hypotenuse v < hypotenuse (berggrenAct berggrenA v)

theorem berggrenB_hypotenuse_strictly_grows {v : Fin 3 → ℤ} :
  IsPositiveTriple v → hypotenuse v < hypotenuse (berggrenAct berggrenB v)

theorem berggrenC_hypotenuse_strictly_grows {v : Fin 3 → ℤ} :
  IsPositiveTriple v → hypotenuse v < hypotenuse (berggrenAct berggrenC v)
```

These should be proved by explicit coordinate formulas and `linarith`, not by brute force.

A stronger quantitative theorem is required for utility:

```lean
theorem berggrenA_hypotenuse_growth_lower_bound {v : Fin 3 → ℤ} :
  IsPositiveTriple v →
  hypotenuse (berggrenAct berggrenA v) ≥ hypotenuse v + 2

theorem berggrenB_hypotenuse_growth_lower_bound {v : Fin 3 → ℤ} :
  IsPositiveTriple v →
  hypotenuse (berggrenAct berggrenB v) ≥ hypotenuse v + 7

theorem berggrenC_hypotenuse_growth_lower_bound {v : Fin 3 → ℤ} :
  IsPositiveTriple v →
  hypotenuse (berggrenAct berggrenC v) ≥ hypotenuse v + 1
```

If exact constants differ under your sorted-leg convention, prove valid explicit constants and state them precisely. Do not leave this qualitative.

### 6. Word-action infrastructure

Prove recursion / composition lemmas:

```lean
theorem berggrenWordAct_nil (v : Fin 3 → ℤ) :
  berggrenWordAct [] v = v

theorem berggrenWordAct_cons (l : BerggrenLetter) (w : List BerggrenLetter) (v : Fin 3 → ℤ) :
  berggrenWordAct (l :: w) v = berggrenWordAct w (berggrenAct l.toMatrix v)

theorem berggrenWordAct_append (u w : List BerggrenLetter) (v : Fin 3 → ℤ) :
  berggrenWordAct (u ++ w) v = berggrenWordAct w (berggrenWordAct u v)
```

Then inductively propagate rootedness and strict growth:

```lean
theorem berggrenWordAct_preserves_rooted {w : List BerggrenLetter} {v : Fin 3 → ℤ} :
  IsRootedPrimitiveTriple v → IsRootedPrimitiveTriple (berggrenWordAct w v)

theorem hypotenuse_le_wordAct_hypotenuse {w : List BerggrenLetter} {v : Fin 3 → ℤ} :
  IsPositiveTriple v → hypotenuse v ≤ hypotenuse (berggrenWordAct w v)
```

and a strict version for nonempty words:

```lean
theorem hypotenuse_strictly_grows_along_nonempty_word
  {w : List BerggrenLetter} {v : Fin 3 → ℤ} :
  IsPositiveTriple v → w ≠ [] →
  hypotenuse v < hypotenuse (berggrenWordAct w v)
```

### 7. Quantitative complexity bounds

You must prove at least one explicit asymptotic-style bound in exact Lean arithmetic form. A clean target is linear lower growth in word length:

```lean
theorem hypotenuse_word_lower_bound_linear
  (w : List BerggrenLetter) :
  hypotenuse (berggrenWordAct w rootTriple) ≥ hypotenuse rootTriple + (w.length : ℤ)
```

A stronger theorem is encouraged if your branch constants support it:

```lean
theorem hypotenuse_word_lower_bound_two_per_step
  (w : List BerggrenLetter) :
  hypotenuse (berggrenWordAct w rootTriple) ≥ hypotenuse rootTriple + 2 * (w.length : ℤ)
```

Package this in a doc comment with the explicit phrase:
“algorithmic complexity bound: hypotenuse growth is Ω(n) in word length.”

Also prove an upper-Lipschitz style shadow:

```lean
theorem berggren_letter_lipschitz_shadow
  (l : BerggrenLetter) (v : Fin 3 → ℤ) :
  Int.natAbs (hypotenuse (berggrenAct l.toMatrix v)) ≤
    (LipschitzShadow l.toMatrix) * (Int.natAbs (v 0) + Int.natAbs (v 1) + Int.natAbs (v 2))
```

You may choose a coarse constant from row-sum norms. The theorem name must include `lipschitz` and `certified`.

### 8. Branch disjointness and rooted injectivity

This is the conceptual heart.

Prove pairwise branch separation on rooted triples. Ideal target:

```lean
theorem berggren_branch_disjoint_AB {v w : Fin 3 → ℤ} :
  IsRootedPrimitiveTriple v → IsRootedPrimitiveTriple w →
  berggrenAct berggrenA v ≠ berggrenAct berggrenB w

theorem berggren_branch_disjoint_AC {v w : Fin 3 → ℤ} :
  IsRootedPrimitiveTriple v → IsRootedPrimitiveTriple w →
  berggrenAct berggrenA v ≠ berggrenAct berggrenC w

theorem berggren_branch_disjoint_BC {v w : Fin 3 → ℤ} :
  IsRootedPrimitiveTriple v → IsRootedPrimitiveTriple w →
  berggrenAct berggrenB v ≠ berggrenAct berggrenC w
```

A very effective route is to prove distinct inequalities on the leg gap:
- `A`-image gives a negative or small signature,
- `B`-image gives a large positive signature,
- `C`-image gives another distinct signature.

For example, compute exact formulas for `legGap (berggrenAct ... v)` and derive mutually exclusive sign conditions under `0 < v 0 ≤ v 1 < v 2`. Then use `linarith`.

After pairwise branch disjointness, prove same-branch injectivity using determinant-1 semantics or explicit inverse formulas:

```lean
theorem berggrenA_injective : Function.Injective (berggrenAct berggrenA)
theorem berggrenB_injective : Function.Injective (berggrenAct berggrenB)
theorem berggrenC_injective : Function.Injective (berggrenAct berggrenC)
```

Then package one-step rooted injectivity:

```lean
theorem berggren_one_step_rooted_injective
  {l₁ l₂ : BerggrenLetter} {v₁ v₂ : Fin 3 → ℤ} :
  IsRootedPrimitiveTriple v₁ →
  IsRootedPrimitiveTriple v₂ →
  berggrenAct l₁.toMatrix v₁ = berggrenAct l₂.toMatrix v₂ →
  l₁ = l₂ ∧ v₁ = v₂
```

### 9. Word uniqueness / rooted orbit freeness

This is the final target. State and prove the strongest version you can.

Preferred exact theorem:

```lean
theorem berggrenWordAct_root_free
  {u w : List BerggrenLetter} :
  berggrenWordAct u rootTriple = berggrenWordAct w rootTriple → u = w
```

Recommended proof: induction on one of the lists, using
1. nonempty words strictly raise hypotenuse above `rootTriple`,
2. one-step rooted injectivity to strip the first letter,
3. recursive rootedness preservation for the suffix state.

If full equality of words is technically difficult because of action orientation, prove the equivalent orientation-adjusted theorem with exact statement. Do not settle for merely “same length”.

Also prove the existential alternation theorem:

```lean
theorem rooted_orbit_has_unique_word_prefix_decomposition
  (w : List BerggrenLetter) :
  ∀ x, x = berggrenWordAct w rootTriple →
    ∃! u, berggrenWordAct u rootTriple = x
```

This quantifier alternation is required for aesthetic score.

If possible, strengthen to:
```lean
theorem rooted_orbit_code_equivalence_quantum_certified
  (x : Fin 3 → ℤ) :
  (∃ w, berggrenWordAct w rootTriple = x) →
  ∃! w, berggrenWordAct w rootTriple = x
```

This theorem name is intentionally application-facing; include a doc comment saying:
“Bridge: connects Diophantine orbit rigidity to quantum-certified state encoding and post_quantum_security style unique decoding.”

---

## PROOF ARCHITECTURE

Use at least three distinct proof styles across the file.

### Strategy A: Coordinate-expansion algebra
Best for quadratic-form preservation, positivity, leg-gap formulas, and growth bounds.

Concrete steps:
1. Prove explicit coordinate lemmas:
   ```lean
   theorem berggrenA_apply0 (v) : berggrenAct berggrenA v 0 = v 0 - 2*v 1 + 2*v 2 := ...
   theorem berggrenA_apply1 (v) : berggrenAct berggrenA v 1 = 2*v 0 - v 1 + 2*v 2 := ...
   theorem berggrenA_apply2 (v) : berggrenAct berggrenA v 2 = 2*v 0 - 2*v 1 + 3*v 2 := ...
   ```
   and similarly for `B`, `C`.
2. Use `fin_cases i <;> simp [berggrenAct, berggrenA, Matrix.mulVec, dotProduct]`.
3. For form preservation, unfold `pythagoreanForm`; substitute coordinate formulas; finish with `ring_nf`.
4. For growth, derive linear formulas for `hypotenuse` and `legGap`; use positivity hypotheses and `linarith`.

### Strategy B: Divisibility / gcd ideal method
Best for primitiveness preservation.

Concrete steps:
1. Define `TripleContent`.
2. Show each output coordinate is an integer linear combination of input coordinates, so every common divisor of inputs divides outputs.
3. Either prove inverse coordinate formulas or use determinant-1 / explicit inverse matrix to get the reverse divisibility.
4. Conclude equality of contents; specialize content `= 1`.

This is where `rcases hprim with ...`, `Int.dvd_gcd`, `Int.gcd_dvd_left`, `Int.gcd_dvd_right`, and `dvd_add`, `dvd_sub`, `dvd_mul_of_dvd_left/right` should appear.

### Strategy C: Induction on words + branch disjointness
Best for rooted freeness.

Concrete steps:
1. Induct on `u` or on the pair `(u,w)`.
2. Base case: if `u = []`, then `berggrenWordAct [] rootTriple = rootTriple`; show nonempty `w` is impossible via strict hypotenuse growth.
3. Step case: compare heads. Use `berggren_one_step_rooted_injective` to deduce equal first letters and equal intermediate states.
4. Apply induction to suffixes.

This should use `cases u with`, `cases w with`, `simp [berggrenWordAct]`, `by_contra`, and monotonicity.

### Strategy D: Semantic SL(3,ℤ) bridge
Use determinant and invertibility as conceptual infrastructure.

Concrete steps:
1. Prove determinant-1 exactly.
2. Optionally define explicit inverse matrices and show `M ⬝ M⁻¹ = 1`.
3. Deduce injectivity of `mulVec` by left-cancellation.
4. Reuse this for same-branch injectivity.

This is the cleanest “Bridge” to algebraic semantics.

---

## SUGGESTED SUPPORTING LEMMAS

You should add many helper lemmas with explicit names, for example:

```lean
theorem TripleContent_nonneg (v : Fin 3 → ℤ) : 0 ≤ TripleContent v
theorem IsPrimitiveTriple_iff_content_eq_one (v : Fin 3 → ℤ) :
  IsPrimitiveTriple v ↔ TripleContent v = 1

theorem legGap_A_formula (v : Fin 3 → ℤ) :
  legGap (berggrenAct berggrenA v) = v 0 + v 1

theorem legGap_B_formula (v : Fin 3 → ℤ) :
  legGap (berggrenAct berggrenB v) = -v 0 + v 1

theorem legGap_C_formula (v : Fin 3 → ℤ) :
  legGap (berggrenAct berggrenC v) = - (v 0 + v 1)
```

If these exact formulas differ, derive the correct ones explicitly and exploit their sign patterns.

Also add parent-exclusion style lemmas:

```lean
theorem root_not_in_nonempty_image
  {w : List BerggrenLetter} :
  w ≠ [] → berggrenWordAct w rootTriple ≠ rootTriple

theorem berggren_nonempty_word_hypotenuse_gt_root
  {w : List BerggrenLetter} :
  w ≠ [] → hypotenuse rootTriple < hypotenuse (berggrenWordAct w rootTriple)
```

These are the gateway to uniqueness.

---

## CROSS-DOMAIN BRIDGE THEOREMS

In `Bridges/BerggrenChronometricEntropy.lean`, define lightweight wrappers and prove simple but explicit consequences with application-facing names and doc comments. The mathematics can remain elementary, but the names and statements must be precise and nontrivial.

### Required bridge definitions

```lean
def ChronometricEnergy (v : Fin 3 → ℤ) : ℤ := hypotenuse v
def QuantumCertifiedCodeword (w : List BerggrenLetter) : Fin 3 → ℤ := berggrenWordAct w rootTriple
def PostQuantumSecurityLevel (w : List BerggrenLetter) : ℕ := w.length
def CertifiedRobustnessMargin (v : Fin 3 → ℤ) : ℤ := hypotenuse v - v 1
def TropicalHashCollisionScore (v : Fin 3 → ℤ) : ℤ := max (v 0) (v 1) - v 2
```

### Required bridge theorems

```lean
/-- Bridge: connects Diophantine orbit rigidity to quantum-certified unique decoding. -/
theorem quantum_certified_codeword_injective
  : Function.Injective QuantumCertifiedCodeword
```

```lean
/-- Bridge: connects primitive-triple tree depth to post_quantum_security style key growth. 
algorithmic complexity bound: security level n forces hypotenuse growth Ω(n). -/
theorem post_quantum_security_linear_growth
  (w : List BerggrenLetter) :
  ChronometricEnergy (QuantumCertifiedCodeword w) ≥ 5 + (w.length : ℤ)
```

```lean
/-- Bridge: connects Berggren dynamics to certified robustness via a coarse Lipschitz shadow. -/
theorem lipschitz_certified_robustness_berggren_shadow
  (l : BerggrenLetter) (v : Fin 3 → ℤ) :
  Int.natAbs (CertifiedRobustnessMargin (berggrenAct l.toMatrix v)) ≤
    (LipschitzShadow l.toMatrix) * (Int.natAbs (v 0) + Int.natAbs (v 1) + Int.natAbs (v 2))
```

```lean
/-- Bridge: connects branch disjointness to tropical_hash_collision exclusion. -/
theorem tropical_hash_collision_free_on_root_orbit
  {u w : List BerggrenLetter} :
  QuantumCertifiedCodeword u = QuantumCertifiedCodeword w → u = w
```

These bridge theorems may be wrappers around core theorems, but they must be formally proved and documented.

---

## MINIMAL IMPORT / TYPECLASS DISCIPLINE

Prefer general lemmas where natural, but the core Berggren file can remain over `ℤ`. Still, add at least a few abstract linear-algebra helper lemmas with typeclass abstraction, for example:

```lean
theorem mulVec_zero_preserves_form
  {R : Type*} [Semiring R] ...
```

or abstract list-action lemmas:

```lean
theorem wordAct_append_generic
  {α β : Type*} (f : α → β → β) ...
```

This is required for rigor and originality: not everything should be hard-coded to one concrete type.

---

## TACTIC DIVERSITY REQUIREMENT INSIDE THE FILE

Use all of the following somewhere naturally:
- `induction`
- `rcases`
- `by_contra`
- `linarith`
- `ring_nf`
- `omega` for length / natural-number inequalities
- `field_simp` if you introduce rational inverse formulas or norm bounds
- `simp`, but not as the sole engine

A good place for `omega` is converting `w.length ≠ 0` into positivity for complexity bounds.  
A good place for `field_simp` is any optional proof over `ℚ` of inverse-semantic formulas.

---

## CONJECTURE IF NEEDED

If the full rooted freeness theorem becomes technically blocked, state precisely:

```lean
conjecture berggren_complete_orbit_classification
  (x : Fin 3 → ℤ) :
  IsRootedPrimitiveTriple x → ∃! w, berggrenWordAct w rootTriple = x
```

Then prove all infrastructure that makes this conjecture credible: one-step injectivity, branch disjointness, strict hypotenuse growth, and uniqueness on the reachable orbit from `rootTriple`.

But the preferred outcome is still the actual theorem `berggrenWordAct_root_free`.

---

## SIGNIFICANCE TO THE RESEARCH PROGRAM

This development should formalize a genuine semantic bridge:

1. **Number theory × algebraic dynamics**: Berggren transforms are not just generators of primitive triples; they become a formally verified rooted groupoid action with SL(3,ℤ) semantics.
2. **Computation × certified uniqueness**: the rooted orbit freeness theorem gives a canonical code for primitive-triple states, analogous to unique decoding in cryptographic and certified-ML settings.
3. **Physics × entropy language**: strict hypotenuse growth acts as a chronometric / entropy-like Lyapunov function, making the tree into a formally acyclic causal dynamical system.
4. **Cryptographic vocabulary**: word uniqueness supplies a toy but exact model of collision-freeness and post-quantum-style structural key separation.
5. **Algorithmic utility**: the linear lower bound on hypotenuse growth gives an explicit complexity invariant, not merely an existence theorem.

Use theorem names and doc comments to make these bridges visible without sacrificing mathematical precision.

---

## FUTURE-DIRECTION HOOKS TO PREPARE IN THE CODE

At the end of the main file, include clearly marked comments or theorem stubs (proved if possible, conjectured if not) pointing toward:

1. complete classification of all positive primitive triples by unique Berggren words;
2. extraction of a certified enumeration algorithm with complexity bound in hypotenuse cutoff;
3. extension from rooted tree action to a true Berggren groupoid with parent maps and partial inverses;
4. comparison with lattice / automata semantics for post-quantum coding analogies;
5. a tropical or entropy-theoretic shadow invariant on the rooted orbit.

Also produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, each naming exact candidate Lean declarations and the breakthrough they would unlock.

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
            Formalize the concrete 3×3 Berggren matrices A, B, C acting on ℤ³, prove each preserves the quadratic form q(a,b,c)=a^2+b^2-c^2 and primitive-triple coprimality, and establish that the positive Berggren action defines a free orbit groupoid on primitive Pythagorean triples rooted at (3,4,5). The central target is a rigidity theorem: two positive Berggren words yielding the same primitive triple must be identical, giving a certified unique-coordinate system for primitive triples by words in {A,B,C}. This would complete the abstract-to-concrete passage suggested by the existing Berggren automata work and create an algorithmic pipeline for verified enumeration, canonical encoding, and reversible navigation of primitive triple space.

            ### Precise Mathematical Framing
            Define explicit matrices A,B,C : Matrix (Fin 3) (Fin 3) ℤ corresponding to the classical Berggren transforms. Prove (1) q(Mv)=q(v) for M∈{A,B,C}; (2) if v is a primitive positive Pythagorean triple, then Mv is again primitive and positive; (3) every positive Berggren word acts on the root triple to produce a primitive triple; (4) positivity/monotonicity invariants imply no nontrivial positive word fixes a primitive triple; (5) using descent on hypotenuse or inverse-branch exclusion, prove injectivity of the word action on the rooted orbit, hence freeness of the generated monoid on the orbit; (6) package the result as a concrete orbit groupoid / reversible automaton semantics compatible with prior chronometric and automata abstractions. Algorithmically, this yields canonical word addresses for primitive triples, certified enumeration by depth, and decision procedures for ancestry in the Berggren tree. The cross-domain significance is that a number-theoretic tree becomes a formally reversible symbolic dynamical system with exact matrix semantics.

            ### Lean 4 Sketch
Create a new file in Bridges or Pythagorean defining `berggrenA`, `berggrenB`, `berggrenC : Matrix (Fin 3) (Fin 3) ℤ`, `pythagorean_form`, `IsPrimitiveTriple`, and `berggrenWordAct`. Prove preservation lemmas with `matrix`, `ring_nf`, `linarith`, gcd lemmas over ℤ, then establish rooted injectivity via hypotenuse monotonicity and branch disjointness. Finish with a `FreeMonoid`-style uniqueness theorem for words acting on `rootTriple`.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `berggren_certified_extraction_pipeline` : theorem berggren_certified_extraction_pipeline
     (file: Bridges/BerggrenEntropyExtractor.lean)
  2. `berggren_left_preserves_primitive` : theorem berggren_left_preserves_primitive :
     (file: Bridges/BerggrenLatticeReduction/Core.lean)
  3. `berggren_generator_preserves_pythagorean` : theorem berggren_generator_preserves_pythagorean (g : Generator) (t : Triple)
     (file: Bridges/BerggrenResidualAutomata.lean)
  4. `arithmeticTrace_coordinate_bound_quantum_certified` : theorem arithmeticTrace_coordinate_bound_quantum_certified
     (file: Bridges/ArithmeticVCDimension.lean)
  5. `hecke_score_beatpath_unique_winner_of_positive_gap` : theorem hecke_score_beatpath_unique_winner_of_positive_gap
     (file: Bridges/BeatpathRobustness.lean)

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



Recent successful concepts: Algebra–Speculative Ultrametric Oracle Capacity via Non-Archimedean Fixed-Point Compression, Algebra–EML Turing–Myhill Reconstruction via Closure Semimodule Dynamics and Intrinsic Computation Capacity, Berggren–Chronometric Reversible Automata via Primitive Triple Orbit Groupoids and Causal Entropy Separation


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

            7. **PACKAGE.json** — MANDATORY JSON Data Package
               Bundle ALL artifacts into a single JSON file for the web frontend:
               • Output a strictly valid JSON object:
                 {
                   "title": "Title", "domain": "Domain",
                   "article": "Markdown content...",
                   "research_paper": "Markdown content...",
                   "future_directions": "Markdown content...",
                   "demos": [ { "name": "...", "code": "..." } ],
                   "algorithms": [ { "name": "...", "pseudocode": "..." } ],
                   "visualizations": [ { "name": "...", "data": "base64 URI or inline SVG" } ],
                   "lean_proofs": "Raw lean code..."
                 }
               • Ensure all Markdown and code is properly JSON-escaped.
               • ALL images MUST be embedded as base64 data URIs or inline SVG within the `data` field.
                 If you generate matplotlib/plotly charts, convert to base64.
                 NEVER reference external image files — they won't exist standalone.
               • This JSON file powers the dynamic web UI. Include ALL content.

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
    "demos": [ { "name": "...", "code": "..." } ],
    "algorithms": [ { "name": "...", "pseudocode": "..." } ],
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
Research mode: formalize
