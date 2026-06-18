## YOUR ASSIGNMENT: Quantum Berggren hidden-subsemigroup rigidity via abelianized length spectra and certified collision obstructions

### Core formalization target

Work in the existing Berggren infrastructure where the positive Berggren semigroup is already realized as a free semigroup/monoid on three generators acting on primitive Pythagorean triples. The decisive new layer is to formalize **abelianized word spectra** and prove that, on bounded balls, these spectra certify reconstruction and collision-freeness.

You should introduce a clean finite-alphabet word model if not already present, ideally reducing everything to `FreeMonoid (Fin 3)` or an equivalent existing Berggren word type.

A good concrete setup is:

```lean
inductive BerggrenGen : Type
| A | B | C
deriving DecidableEq, Fintype

abbrev BergWord := FreeMonoid BerggrenGen
```

If the library already uses lists instead of `FreeMonoid`, mirror all statements with `List BerggrenGen` and prove compatibility via quotient-normal-form lemmas.

### Definitions to add

The key definitions should be executable and finite.

```lean
def parikhVec (w : BergWord) : BerggrenGen → ℕ

def wordLength (w : BergWord) : ℕ := FreeMonoid.length w

def boundedWords (R : ℕ) : Finset BergWord

def boundedParikhSpectrum (S : Set BergWord) (R : ℕ) : Finset (BerggrenGen → ℕ)

def boundedLengthSpectrum (S : Set BergWord) (R : ℕ) : Finset ℕ
```

If functions into `ℕ` are awkward for `Finset`, replace `BerggrenGen → ℕ` by a concrete triple:

```lean
def ParikhTriple := ℕ × ℕ × ℕ
def parikhTriple (w : BergWord) : ParikhTriple
```

This is often the better Lean choice. Then use:

```lean
def boundedParikhSpectrum (S : Set BergWord) (R : ℕ) : Finset ParikhTriple
```

You also need the action-profile layer. If there is already a base primitive triple `rootTriple` and a word action `act : BergWord → PrimitiveTriple → PrimitiveTriple`, define:

```lean
def orbitLengthProfile (w : BergWord) : ℕ
```

or, better, if the existing catalog has a norm/height/perimeter map:

```lean
def tripleSize : PrimitiveTriple → ℕ
def orbitProfile (w : BergWord) : ℕ := tripleSize (act w rootTriple)
```

Then define bounded profile spectra for subsemigroups:

```lean
def boundedProfileSpectrum (S : Set BergWord) (R : ℕ) : Finset ℕ
```

For finitely generated subsemigroups, define closure under multiplication from a finite generator set:

```lean
def subsemigroupClosure (G : Finset BergWord) : Set BergWord
```

If an existing `Subsemigroup` object is already available, use that instead:

```lean
def generatedSubsemigroup (G : Finset BergWord) : Subsemigroup BergWord
```

### Precise theorem package

The target should be split into four theorem layers.

---

### 1. Radius-injective reconstruction from bounded Parikh data for short words

This is the foundational rigidity lemma. In a free monoid, if two short words have the same Parikh data and the same action-profile data, then they are equal. The exact profile invariant may need adjustment to fit the existing catalog, but the theorem should be stated in a directly reusable way.

A strong Lean target:

```lean
theorem short_word_reconstruction
    (R : ℕ)
    (w₁ w₂ : BergWord)
    (h₁ : wordLength w₁ ≤ R)
    (h₂ : wordLength w₂ ≤ R)
    (hp : parikhTriple w₁ = parikhTriple w₂)
    (ha : act w₁ rootTriple = act w₂ rootTriple) :
    w₁ = w₂
```

If equality of actions on `rootTriple` is too strong or already known to imply equality by freeness, replace `ha` with equality of a weaker profile invariant and prove the strongest version you can:

```lean
theorem short_word_profile_rigidity
    (R : ℕ)
    (w₁ w₂ : BergWord)
    (h₁ : wordLength w₁ ≤ R)
    (h₂ : wordLength w₂ ≤ R)
    (hp : parikhTriple w₁ = parikhTriple w₂)
    (hprof : orbitProfile w₁ = orbitProfile w₂) :
    w₁ = w₂
```

If full profile rigidity is too ambitious, prove the special case where one compares words with the same first letter or same last letter, then bootstrap by induction.

**Why this matters:** this theorem converts an abelianized invariant, which by itself forgets order, into a complete short-word identifier once coupled with the geometric Berggren action. That is exactly the hidden-subsemigroup/cryptographic bridge: commutative statistics plus noncommutative dynamics recover the secret word.

---

### 2. Equality of bounded spectra implies equality on the radius ball

Define the radius ball:

```lean
def radiusBall (R : ℕ) : Finset BergWord :=
  boundedWords R
```

Then prove a bounded reconstruction theorem for subsemigroups.

A precise target:

```lean
theorem bounded_spectrum_ext
    (S T : Set BergWord) (R : ℕ)
    (hpar :
      boundedParikhSpectrum S R = boundedParikhSpectrum T R)
    (hprof :
      boundedProfileSpectrum S R = boundedProfileSpectrum T R)
    (hrealS :
      ∀ w, w ∈ radiusBall R → w ∈ S →
        ∃ u, u ∈ S ∧ wordLength u ≤ R ∧ parikhTriple u = parikhTriple w)
    (hrealT :
      ∀ w, w ∈ radiusBall R → w ∈ T →
        ∃ u, u ∈ T ∧ wordLength u ≤ R ∧ parikhTriple u = parikhTriple w) :
    ∀ w, w ∈ radiusBall R → (w ∈ S ↔ w ∈ T)
```

This may need specialization to finitely generated subsemigroups:

```lean
theorem bounded_generated_subsemigroup_ext
    (G H : Finset BergWord) (R : ℕ)
    (hpar :
      boundedParikhSpectrum (subsemigroupClosure G) R =
      boundedParikhSpectrum (subsemigroupClosure H) R)
    (hprof :
      boundedProfileSpectrum (subsemigroupClosure G) R =
      boundedProfileSpectrum (subsemigroupClosure H) R) :
    ∀ w, w ∈ radiusBall R →
      (w ∈ subsemigroupClosure G ↔ w ∈ subsemigroupClosure H)
```

If direct extensionality is hard, first prove a pointwise witness extraction lemma:

```lean
theorem spectrum_membership_witness
    (S : Set BergWord) (R : ℕ) (w : BergWord)
    (hw : wordLength w ≤ R)
    (hs : parikhTriple w ∈ boundedParikhSpectrum S R)
    (hp : orbitProfile w ∈ boundedProfileSpectrum S R) :
    ∃ u, u ∈ S ∧ wordLength u ≤ R ∧
      parikhTriple u = parikhTriple w ∧ orbitProfile u = orbitProfile w
```

and then combine with `short_word_reconstruction`.

**Why this matters:** this is the hidden-subsemigroup identification theorem in bounded radius. It says that finite spectral data determine membership in the secret semigroup on the entire search ball. That is a genuine algebraic-cryptographic primitive, not just another freeness lemma.

---

### 3. Certified no-collision theorem on bounded balls

Define collisions for the Berggren action hash:

```lean
def collidesOnRadius (R : ℕ) : Prop :=
  ∃ w₁ w₂,
    wordLength w₁ ≤ R ∧
    wordLength w₂ ≤ R ∧
    w₁ ≠ w₂ ∧
    act w₁ rootTriple = act w₂ rootTriple
```

Then prove the certification theorem:

```lean
theorem certified_no_collision_of_reconstruction
    (R : ℕ)
    (hrec :
      ∀ w₁ w₂,
        wordLength w₁ ≤ R →
        wordLength w₂ ≤ R →
        parikhTriple w₁ = parikhTriple w₂ →
        act w₁ rootTriple = act w₂ rootTriple →
        w₁ = w₂) :
    ¬ collidesOnRadius R
```

A stronger algorithmic form is preferable:

```lean
def collisionCertificate (R : ℕ) : Bool

theorem collisionCertificate_sound
    (R : ℕ)
    (hcert : collisionCertificate R = true) :
    ¬ collidesOnRadius R
```

If the certificate computes by exhaustive finite search over `boundedWords R`, prove soundness first and defer completeness:

```lean
theorem collisionCertificate_complete
    (R : ℕ) :
    collisionCertificate R = true ↔ ¬ collidesOnRadius R
```

Even the one-way implication is valuable if the executable search is already practical.

**Why this matters:** this turns structural semigroup rigidity into an explicit cryptographic assurance statement. It is the formal analogue of a collision-resistance certificate for a noncommutative hash built from Berggren dynamics.

---

### 4. Hidden-subsemigroup recovery guarantee

Package the previous results into a theorem saying that spectral agreement recovers the bounded secret.

A concrete target:

```lean
theorem hidden_subsemigroup_recovery
    (G H : Finset BergWord) (R : ℕ)
    (hpar :
      boundedParikhSpectrum (subsemigroupClosure G) R =
      boundedParikhSpectrum (subsemigroupClosure H) R)
    (hprof :
      boundedProfileSpectrum (subsemigroupClosure G) R =
      boundedProfileSpectrum (subsemigroupClosure H) R) :
    ∀ w, wordLength w ≤ R →
      (w ∈ subsemigroupClosure G ↔ w ∈ subsemigroupClosure H)
```

If possible, strengthen this to equality of the finite truncations:

```lean
def truncation (S : Set BergWord) (R : ℕ) : Finset BergWord :=
  (boundedWords R).filter (fun w => w ∈ S)

theorem hidden_subsemigroup_recovery_finset
    (G H : Finset BergWord) (R : ℕ)
    (hpar :
      boundedParikhSpectrum (subsemigroupClosure G) R =
      boundedParikhSpectrum (subsemigroupClosure H) R)
    (hprof :
      boundedProfileSpectrum (subsemigroupClosure G) R =
      boundedProfileSpectrum (subsemigroupClosure H) R) :
    truncation (subsemigroupClosure G) R =
    truncation (subsemigroupClosure H) R
```

This is likely the most usable theorem for downstream computation.

---

## Proof strategy

### Strategy A: Free-monoid normal forms + induction on word length
This is the most promising route.

1. **Implement Parikh additivity**
   Prove:
   ```lean
   theorem parikhTriple_mul (u v : BergWord) :
     parikhTriple (u * v) = parikhTriple u + parikhTriple v
   ```
   with the obvious componentwise addition on triples.

2. **Exploit first-letter or last-letter decomposition**
   In a free monoid, every nonempty word decomposes uniquely. Prove helper lemmas:
   ```lean
   theorem eq_of_same_head_same_tail ...
   theorem head_ne_of_generator_mismatch ...
   theorem cancellation_left ...
   theorem cancellation_right ...
   ```
   Use existing freeness/cancellation results from the Berggren semigroup infrastructure whenever possible rather than reproving abstractly.

3. **Bridge action equality to generator agreement**
   Use the known Berggren action freeness/normal-form theorem: if `act w₁ rootTriple = act w₂ rootTriple`, then under the existing positive-semigroup rigidity results one gets equality of words, or at least equality of first generators after comparing image growth/shape invariants. If full freeness is already available, `short_word_reconstruction` becomes immediate and Parikh data is only needed for the bounded-spectrum extraction theorem.

4. **Induct on `R` or on word length**
   For bounded reconstruction, choose a witness in the matching spectrum, then use profile equality plus Parikh equality to force equality by the short-word lemma.

This route is best because the free Berggren semigroup is already a rigid combinatorial object; the new content is packaging that rigidity into finite spectral reconstruction.

### Strategy B: Matrix/action separation via monotone invariants
If direct word induction becomes messy, work through the matrix action.

1. Define an explicit size invariant on primitive triples, e.g. hypotenuse, perimeter, or a weighted norm.
2. Prove each generator transforms this invariant in a distinguishable way on the positive cone.
3. Show that equal action on `rootTriple` plus equal Parikh data forces the same first generator, then cancel and recurse.

This strategy is attractive if the catalog already contains positivity and monotonicity lemmas for the Berggren matrices.

### Strategy C: Finite search certification + abstract soundness
For the executable theorem, separate computation from structure.

1. Enumerate all words of length `≤ R`.
2. Map them to `(parikhTriple, orbitProfile)` or directly to action outputs.
3. Define a boolean duplicate test.
4. Prove that `true` means injectivity/no collision.

This is the right route for the `collisionCertificate_sound` theorem even if the deeper rigidity theorem remains partially conjectural.

---

## Concrete intermediate lemmas to prove

These are the likely keystone statements.

```lean
theorem mem_boundedWords_iff (R : ℕ) (w : BergWord) :
  w ∈ boundedWords R ↔ wordLength w ≤ R
```

```lean
theorem parikhTriple_empty :
  parikhTriple 1 = (0,0,0)
```

```lean
theorem parikhTriple_generator_A :
  parikhTriple (of BerggrenGen.A) = (1,0,0)
```

and similarly for `B`, `C`.

```lean
theorem parikhTriple_mul (u v : BergWord) :
  parikhTriple (u * v) =
    addParikhTriple (parikhTriple u) (parikhTriple v)
```

```lean
theorem boundedParikhSpectrum_finite (S : Set BergWord) (R : ℕ) :
  (boundedParikhSpectrum S R).Finite
```

If using `Finset`, this is automatic, but a membership characterization is useful:

```lean
theorem mem_boundedParikhSpectrum_iff
    (S : Set BergWord) (R : ℕ) (p : ParikhTriple) :
    p ∈ boundedParikhSpectrum S R ↔
      ∃ w, w ∈ S ∧ wordLength w ≤ R ∧ parikhTriple w = p
```

Similarly for profiles:

```lean
theorem mem_boundedProfileSpectrum_iff
    (S : Set BergWord) (R : ℕ) (n : ℕ) :
    n ∈ boundedProfileSpectrum S R ↔
      ∃ w, w ∈ S ∧ wordLength w ≤ R ∧ orbitProfile w = n
```

Then the witness-extraction theorem becomes straightforward.

For collision certification:

```lean
def hasCollisionInList (L : List BergWord) : Bool
def boundedWordList (R : ℕ) : List BergWord
```

Prove:

```lean
theorem hasCollisionInList_sound
    (L : List BergWord)
    (h : hasCollisionInList L = false) :
    List.Pairwise (fun w₁ w₂ => act w₁ rootTriple ≠ act w₂ rootTriple) L
```

and derive the radius theorem from `boundedWordList`.

---

## Structural significance

This project is not just about one semigroup. It establishes a new principle:

- **abelianized statistics + geometric action = bounded noncommutative identifiability**.

That principle is potentially portable to free semigroups, automaton groups, matrix semigroups, and tropical dynamical systems. In cryptographic language, it creates a formal pipeline from easy-to-compute public invariants to provable collision obstructions and hidden-generator recovery guarantees. In algebraic language, it shows that a commutative shadow of a noncommutative semigroup can become complete when coupled to a rigid orbit profile. In computational terms, it yields finite certificates rather than merely existential uniqueness.

This opens at least three directions immediately:
1. hidden-subsemigroup recovery for other free positive matrix semigroups,
2. certified noncommutative hash constructions from semigroup actions,
3. tropical/quantum analogues where Parikh data is replaced by weight spectra and orbit profiles by energy levels.

If the full rigidity theorem is too hard, prove the strongest bounded version with explicit `R`, or prove the executable soundness theorem plus a sharp conjecture:

```lean
conjecture bounded_profile_parikh_rigidity
    (R : ℕ) :
    ∀ w₁ w₂,
      wordLength w₁ ≤ R →
      wordLength w₂ ≤ R →
      parikhTriple w₁ = parikhTriple w₂ →
      orbitProfile w₁ = orbitProfile w₂ →
      w₁ = w₂
```

State clearly which profile you chose and why it should separate orderings in the Berggren action.

## Deliverables

Produce the Lean file with:
- the new word-spectrum definitions,
- the finite-spectrum membership lemmas,
- at least one nontrivial reconstruction theorem,
- the certified no-collision theorem,
- and a structured `FUTURE_DIRECTIONS.md` containing 3–5 concrete next theorems, each with a proposed Lean signature and a one-paragraph explanation of why it would open a new frontier.

### Catalog Reference Files
            @Speculative/AutoResearch/TropicalBerggrenAnalysis.lean
```lean
import Mathlib

/-!
# Tropical Berggren Rank Factorization: Analysis and Counterexamples

## Summary

This file formalizes the Berggren tree infrastructure and provides a rigorous analysis
of the conjecture that the tropical rank of p-adic valuation matrices derived from
Berggren tree paths equals the number of distinct prime factors of the hypotenuse.

## Conclusion: The Conjecture Is False

The central claim — that `tropicalRank(T_p(N)) = ω(N)` — is **false**, for multiple
independent reasons:

### 1. Dimensional Obstruction (Fatal)
The "path matrix" B(N) has dimensions (path_length × 3), since each Pythagorean triple
is a vector in ℤ³. Therefore its tropical rank is at most min(path_length, 3) ≤ 3.
But ω(N) can be arbitrarily large, so the equality fails for any N with ω(N) > 3.

### 2. Concrete Counterexample: N = 169 = 13²
- Path: (3,4,5) → (21,20,29) → (119,120,169), using B₂ twice.
- For p = 13: T₁₃(169) = [[0,0,0],[0,0,0],[0,0,2]]
- Tropical rank of this matrix is ≥ 2 (proof below: it cannot be written as an
  outer sum a[i] + b[j], since all entries are 0 except the (2,2) entry which is 2).
- But ω(169) = ω(13²) = 1.
- So tropical rank ≥ 2 > 1 = ω(N). **Equality fails.**

### 3. Concrete Counterexample: N = 25 = 5²
- Path: (3,4,5) → (5,12,13) → (7,24,25), using B₁ twice.
- For p = 5: T₅(25) = [[0,0,1],[1,0,0],[0,0,2]]
- Tropical rank ≥ 2 (the Monge condition fails: T[0,0]+T[1,1]=0 ≠ 1=T[0,1]+T[1,0]),
  so the matrix cannot be tropically rank 1.
- But ω(25) = 1. **Equality fails again.**

### 4. Domain Restriction (Fundamental)
Not every N > 1 appears as a hypotenuse of a primitive Pythagorean triple.
For a primitive triple (a,b,c), every prime factor of c must be ≡ 1 (mod 4).
So N = 6, 10, 14, 15, 21, ... have no Berggren path at all, making B(N) undefined.

### 5. Non-Uniqueness
When N is the hypotenuse of multiple primitive triples (e.g., N = 65 = 5 × 13
is the hypotenuse of both (33,56,65) and (63,16,65)), the "path matrix" B(N)
is ambiguous without choosing a specific triple.

### 6. Newton Polygon Claim Is Ill-Formed
The tropical determinant of T_p(N) is a single element of ℝ ∪ {∞} (a scalar in the
min-plus semiring), not a polynomial. A single scalar does not have a Newton polygon.
The claim that "Newton polygon breakpoints occur at the exponents eᵢ" is therefore
mathematically meaningless as stated.

## What IS True

We formalize and prove genuine properties of the Berggren matrices:
- B₁ and B₃ have determinant 1, B₂ has determinant -1
- All three preserve the Pythagorean property: if a²+b²=c², then the transformed
  triple also satisfies this equation
- The Berggren tree path computation is well-defined for any tree path
- Verified counterexamples with machine-checked p-adic valuations
-/

section BerggrenInfrastructure

/-! ## Berggren Matrices (3×3 integer matrices) -/

/-- Berggren matrix B₁ (the "left" branch). -/
def berggrenMat₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B₂ (the "middle" branch). -/
def berggrenMat₂ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix B₃ (the "right" branch). -/
def berggrenMat₃ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-! ## Determinants -/

/-- B₁ has determinant 1 (it is in SL(3,ℤ)). -/
theorem det_berggrenMat₁ : Matrix.det berggrenMat₁ = 1 := by native_decide

/-- B₂ has determinant -1. -/
theorem det_berggrenMat₂ : Matrix.det berggrenMat₂ = -1 := by native_decide

/-- B₃ has determinant 1 (it is in SL(3,ℤ)). -/
theorem det_berggrenMat₃ : Matrix.det berggrenMat₃ = 1 := by native_decide

/-! ## Tree Paths and Triple Computation -/

/-- A path in the Berggren ternary tree. -/
inductive BerggrenPath' : Type
  | root : BerggrenPath'
  | left : BerggrenPath' → BerggrenPath'
  | mid : BerggrenPath' → BerggrenPath'
  | right : BerggrenPath' → BerggrenPath'
  deriving Repr

/-- The depth of a Berggren path. -/
def BerggrenPath'.depth : BerggrenPath' → ℕ
  | .root => 0
  | .left p => p.depth + 1
  | .mid p => p.depth + 1
  | .right p => p.depth + 1

/-- The Pythagorean triple (a, b, c) at a given path in the Berggren tree.
    Each branch applies one of the three Berggren transformations. -/
def berggrenTriple' : BerggrenPath' → ℤ × ℤ × ℤ
  | .root => (3, 4, 5)
  | .left p =>
    let (a, b, c) := berggrenTriple' p
    (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .mid p =>
    let (a, b, c) := berggrenTriple' p
    (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .right p =>
    let (a, b, c) := berggrenTriple' p
    (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-! ## Pythagorean Preservation -/

/-- B₁ preserves the Pythagorean property. -/
theorem berggren_left_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2*b + 2*c) ^ 2 + (2*a - b + 2*c) ^ 2 = (2*a - 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a - b)]

/-- B₂ preserves the Pythagorean property. -/
theorem berggren_mid_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + 2*b + 2*c) ^ 2 + (2*a + b + 2*c) ^ 2 = (2*a + 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a - b)]

/-- B₃ preserves the Pythagorean property. -/
theorem berggren_right_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2*b + 2*c) ^ 2 + (-2*a + b + 2*c) ^ 2 = (-2*a + 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a - b)]

/-- Every triple generated by the Berggren tree is Pythagorean. -/
theorem berggren_pythagorean' (p : BerggrenPath') :
    let (a, b, c) := berggrenTriple' p; a ^ 2 + b ^ 2 = c ^ 2 := by
  induction p with
  | root => norm_num [berggrenTriple']
  | left p ih => simp only [berggrenTriple']; exact berggren_left_preserves _ _ _ ih
  | mid p ih => simp only [berggrenTriple']; exact berggren_mid_preserves _ _ _ ih
  | right p ih => simp only [berggrenTriple']; exact berggren_right_preserves _ _ _ ih

end BerggrenInfrastructure

/-! ## Verified Counterexamples -/

-- ... (truncated, full file has 270 lines)
```


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

Research domain: Cryptography
Research mode: prove
