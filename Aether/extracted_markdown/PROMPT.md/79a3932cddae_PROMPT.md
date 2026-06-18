## YOUR ASSIGNMENT: Lorentzian Berggren geodesic rigidity for gravitational factoring via hyperbolic length spectra

Work in a new Lean file that turns the positive Berggren semigroup into a genuinely Lorentzian object, then proves a rigidity theorem strong enough to support unique decoding of Berggren words from a computable displacement/height profile. If full hyperbolic translation length is too heavy, formalize a surrogate profile first and prove uniqueness there.

### Core mathematical objects

Use the Minkowski form
```lean
def J : Matrix (Fin 3) (Fin 3) ℤ :=
!![1, 0, 0;
   0, 1, 0;
   0, 0, -1]
```

Define Lorentzian preservation:
```lean
def preservesMinkowski (M : Matrix (Fin 3) (Fin 3) ℤ) : Prop :=
  M.transpose ⬝ J ⬝ M = J
```

Define the three classical Berggren generators as integer matrices:
```lean
def A : Matrix (Fin 3) (Fin 3) ℤ :=
!![1, -2, 2;
   2, -1, 2;
   2, -2, 3]

def B : Matrix (Fin 3) (Fin 3) ℤ :=
!![1, 2, 2;
   2, 1, 2;
   2, 2, 3]

def C : Matrix (Fin 3) (Fin 3) ℤ :=
!![-1, 2, 2;
    -2, 1, 2;
    -2, 2, 3]
```

Prove first:
```lean
theorem A_preservesMinkowski : preservesMinkowski A
theorem B_preservesMinkowski : preservesMinkowski B
theorem C_preservesMinkowski : preservesMinkowski C
```

and then semigroup closure:
```lean
theorem preservesMinkowski_mul
    {M N : Matrix (Fin 3) (Fin 3) ℤ}
    (hM : preservesMinkowski M) (hN : preservesMinkowski N) :
    preservesMinkowski (M ⬝ N)
```

This is not just bookkeeping: it identifies the Berggren semigroup as a positive cone inside an arithmetic Lorentz group, which is the geometric engine behind any length-spectrum rigidity statement.

---

### Primitive null-cone model

Define the Lorentz quadratic form:
```lean
def minkowskiQ (v : Fin 3 → ℤ) : ℤ :=
  v 0 * v 0 + v 1 * v 1 - v 2 * v 2
```

Define positivity and primitiveness:
```lean
def primitiveVec (v : Fin 3 → ℤ) : Prop :=
  Int.gcd (Int.gcd (v 0) (v 1)) (v 2) = 1

def positiveTriple (v : Fin 3 → ℤ) : Prop :=
  0 < v 0 ∧ 0 < v 1 ∧ 0 < v 2

def primitiveNullTriple (v : Fin 3 → ℤ) : Prop :=
  minkowskiQ v = 0 ∧ primitiveVec v ∧ positiveTriple v
```

Use the root triple
```lean
def rootTriple : Fin 3 → ℤ
| 0 => 3
| 1 => 4
| 2 => 5
```

Prove:
```lean
theorem rootTriple_primitiveNull : primitiveNullTriple rootTriple
```

Then prove each generator preserves the null cone:
```lean
theorem preserves_nullcone
    {M : Matrix (Fin 3) (Fin 3) ℤ}
    (hM : preservesMinkowski M)
    {v : Fin 3 → ℤ} :
    minkowskiQ (M.mulVec v) = minkowskiQ v
```

and specialize:
```lean
theorem berggren_maps_primitiveNull
    {G : Matrix (Fin 3) (Fin 3) ℤ}
    (hG : G = A ∨ G = B ∨ G = C)
    {v : Fin 3 → ℤ} :
    primitiveNullTriple v → primitiveNullTriple (G.mulVec v)
```

If full primitiveness preservation is awkward at first, prove the weaker null-cone-and-positivity statement:
```lean
theorem berggren_maps_positiveNull
    {G : Matrix (Fin 3) (Fin 3) ℤ}
    (hG : G = A ∨ G = B ∨ G = C)
    {v : Fin 3 → ℤ} :
    minkowskiQ v = 0 → positiveTriple v →
    minkowskiQ (G.mulVec v) = 0 ∧ positiveTriple (G.mulVec v)
```

This positivity theorem is the first geometric rigidity input: the generators do not merely act by isometries, they move the future light cone strictly into disjoint positive sectors.

---

### Word evaluation and reducedness

Define a generator alphabet and evaluation:
```lean
inductive Gen where
| a | b | c
deriving DecidableEq, Repr

def genMatrix : Gen → Matrix (Fin 3) (Fin 3) ℤ
| .a => A
| .b => B
| .c => C

def evalWord : List Gen → Matrix (Fin 3) (Fin 3) ℤ
| [] => 1
| g :: w => genMatrix g ⬝ evalWord w
```

Use a reduced-word notion tailored to your eventual decoding invariant. Since this is a free positive semigroup, the simplest viable choice is:
```lean
def reducedWord (w : List Gen) : Prop := True
```
only if existing infrastructure already proves freeness of the Berggren semigroup and you can import that theorem directly. Otherwise define a stronger syntactic condition that prevents immediate ambiguities in the surrogate profile. For example:
```lean
def reducedWord : List Gen → Prop
| [] => True
| [_] => True
| g₁ :: g₂ :: t => g₁ ≠ g₂ ∧ reducedWord (g₂ :: t)
```
But the best target is to connect to any existing free-semigroup theorem from the Berggren-tree infrastructure and use genuine freeness.

Define the orbit triple:
```lean
def tripleOfWord (w : List Gen) : Fin 3 → ℤ :=
  (evalWord w).mulVec rootTriple
```

---

### Height/displacement profile: formal proxy for hyperbolic length

If direct translation length in a hyperboloid model is too expensive, define a computable surrogate that still separates first letters and supports induction. A strong candidate is ordered coordinate growth.

Define:
```lean
def height1 (v : Fin 3 → ℤ) : ℤ := v 0
def height2 (v : Fin 3 → ℤ) : ℤ := v 1
def height3 (v : Fin 3 → ℤ) : ℤ := v 2

def displacementProfileVec (v : Fin 3 → ℤ) : ℤ × ℤ × ℤ :=
  (height1 v, height2 v, height3 v)

def displacementProfile (M : Matrix (Fin 3) (Fin 3) ℤ) : ℤ × ℤ × ℤ :=
  displacementProfileVec (M.mulVec rootTriple)
```

A more geometric surrogate, if available, is:
```lean
def maxEntryAbs (M : Matrix (Fin 3) (Fin 3) ℤ) : ℤ := ...
def energyProfile (M : Matrix (Fin 3) (Fin 3) ℤ) : ℤ := maxEntryAbs M
```
and then prove generator-specific strict inequalities. But the triple-valued profile from the orbit of `rootTriple` is preferable, because it remembers more geometry and is easier to make injective.

The decisive intermediate theorem should be a **prefix-separation theorem**: the three generators send any positive null triple into three pairwise disjoint regions detectable by inequalities among coordinates.

A particularly promising exact statement is:
```lean
def regionA (v : Fin 3 → ℤ) : Prop := v 1 < v 0
def regionB (v : Fin 3 → ℤ) : Prop := v 0 < v 1
def regionC (v : Fin 3 → ℤ) : Prop := v 0 = v 1
```
but this exact partition may fail globally. A more realistic target is to derive explicit linear inequalities from the formulas:
- `A(x,y,z) = (x - 2y + 2z, 2x - y + 2z, 2x - 2y + 3z)`
- `B(x,y,z) = (x + 2y + 2z, 2x + y + 2z, 2x + 2y + 3z)`
- `C(x,y,z) = (-x + 2y + 2z, -2x + y + 2z, -2x + 2y + 3z)`

On positive null triples, compute:
- `A(v)_1 - A(v)_0 = x + y`
- `B(v)_0 - B(v)_1 = -(x + y)`
- `C(v)_0 - C(v)_1 = x - y`

This suggests using an **ordered profile with sign tests** to decode the first letter. For triples arising in the Berggren tree, one can often distinguish:
- `A` by `v 1 > v 0`
- `B` by `v 0 < v 1` plus larger symmetric growth
- `C` by a different comparison involving `v 0 - v 1`
So if the simple partition is insufficient, define a richer profile:
```lean
def signedGapProfile (v : Fin 3 → ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (v 0, v 1, v 2, v 0 - v 1)

def displacementProfile (M : Matrix (Fin 3) (Fin 3) ℤ) : ℤ × ℤ × ℤ × ℤ :=
  signedGapProfile (M.mulVec rootTriple)
```

Then prove pairwise disjoint image conditions for the three generators on the Berggren orbit. Even a theorem only on orbit points, not all positive null vectors, is already powerful and enough for induction.

---

### Main rigidity target

The strongest realistic theorem in Lean is not equality from an arbitrary scalar energy, but equality from the full orbit-profile of the root triple. State the main theorem as:

```lean
theorem berggren_decode_unique
    {w w' : List Gen}
    (hw : reducedWord w)
    (hw' : reducedWord w')
    (hprof : displacementProfile (evalWord w) = displacementProfile (evalWord w')) :
    w = w'
```

A more geometric and often easier equivalent target is:
```lean
theorem berggren_orbit_injective
    {w w' : List Gen}
    (h : tripleOfWord w = tripleOfWord w') :
    w = w'
```
and then derive `berggren_decode_unique` by unfolding `displacementProfile`. If the catalog already contains uniqueness of Berggren enumeration for primitive triples, this theorem should be the central bridge: **word rigidity is converted into Lorentzian orbit rigidity**.

If you can prove only a one-step decoding theorem first, state and prove:
```lean
theorem berggren_first_letter_unique
    {g h : Gen} {w w' : List Gen}
    (hne : g ≠ h) :
    displacementProfile (evalWord (g :: w)) ≠ displacementProfile (evalWord (h :: w'))
```
This is already revolutionary because it formalizes the disjointness of geometric sectors and gives the inductive kernel of full decoding.

---

### Concrete proof strategy

1. **Matrix-level Lorentz verification**
   - Expand `A.transpose ⬝ J ⬝ A`, `B.transpose ⬝ J ⬝ B`, `C.transpose ⬝ J ⬝ C`.
   - Use `fin_cases` on indices and `native_decide` or `ring` after normalization.
   - Then prove `preservesMinkowski_mul` abstractly using associativity of matrix multiplication and the hypotheses.
   - Key lemmas:
     ```lean
     by
       ext i j <;> fin_cases i <;> fin_cases j <;> norm_num
     ```
     and matrix associativity rewrites with `Matrix.mul_assoc`.

2. **Null-cone invariance and positivity**
   - Prove a coordinate formula for each generator action on a vector `v`.
   - Rewrite `minkowskiQ (G.mulVec v)` and use the preservation theorem to avoid brute-force polynomial expansion when possible.
   - For positivity, derive explicit inequalities from the coordinate formulas under `0 < x`, `0 < y`, `0 < z`, and on the null cone use `z > x`, `z > y` for positive primitive triples.
   - Useful intermediate lemma:
     ```lean
     theorem positive_null_lt_hypotenuse
         {v : Fin 3 → ℤ}
         (hnull : minkowskiQ v = 0)
         (hpos : positiveTriple v) :
         v 0 < v 2 ∧ v 1 < v 2
     ```
     This follows from `x^2 + y^2 = z^2` and positivity.

3. **Region separation / first-letter decoding**
   - Compute exact formulas for coordinate differences after applying each generator.
   - Prove that for orbit points `tripleOfWord w`, these differences satisfy generator-specific signs or strict inequalities.
   - Example target lemmas:
     ```lean
     theorem gap_after_A
         {v : Fin 3 → ℤ}
         (hnull : minkowskiQ v = 0)
         (hpos : positiveTriple v) :
         ((A.mulVec v) 1 - (A.mulVec v) 0) = v 0 + v 1

     theorem gap_after_B
         {v : Fin 3 → ℤ}
         (hnull : minkowskiQ v = 0)
         (hpos : positiveTriple v) :
         ((B.mulVec v) 0 - (B.mulVec v) 1) = -(v 0 + v 1)
     ```
   - If `C` is harder to distinguish by one gap, introduce a second invariant such as `(v 2 - v 0, v 2 - v 1)` or the ordered tuple of all three coordinates.

4. **Induction on words**
   - Once first letters are separated by the profile, prove injectivity by induction on `w`.
   - If `displacementProfile (evalWord (g::w)) = displacementProfile (evalWord (h::w'))`, first deduce `g = h`.
   - Cancel the common prefix by applying a left inverse or using an already-proved injectivity of each generator on the orbit.
   - Strong cancellation lemma to target:
     ```lean
     theorem gen_left_cancel_on_orbit
         {g : Gen} {w w' : List Gen}
         (h : tripleOfWord (g :: w) = tripleOfWord (g :: w')) :
         tripleOfWord w = tripleOfWord w'
     ```
   - This follows because `genMatrix g` is invertible over `ℤ` or `ℚ` by Minkowski preservation and determinant `±1`.

5. **Upgrade surrogate profile toward length spectrum**
   - If time permits, define a real-valued Lorentzian/hyperbolic surrogate by embedding integer matrices into `Matrix (Fin 3) (Fin 3) ℝ`.
   - Candidate:
     ```lean
     def lorentzNormSq (v : Fin 3 → ℝ) : ℝ := v 2^2 - v 0^2 - v 1^2
     def hyperboloidLift (v : Fin 3 → ℤ) : Fin 3 → ℝ := fun i => (v i : ℝ)
     ```
   - Then show monotonicity of `Real.log (v 2)` or `Real.log (max (v 0) (max (v 1) (v 2)))` along nonempty words.
   - This does not replace orbit injectivity, but it interprets the combinatorial decoding as a proto-length-spectrum rigidity theorem.

---

### Exact Lean targets to prioritize

These are the most actionable theorem signatures:

```lean
def J : Matrix (Fin 3) (Fin 3) ℤ := ...
def preservesMinkowski (M : Matrix (Fin 3) (Fin 3) ℤ) : Prop := ...

theorem A_preservesMinkowski : preservesMinkowski A
theorem B_preservesMinkowski : preservesMinkowski B
theorem C_preservesMinkowski : preservesMinkowski C

def minkowskiQ (v : Fin 3 → ℤ) : ℤ := ...
def primitiveVec (v : Fin 3 → ℤ) : Prop := ...
def positiveTriple (v : Fin 3 → ℤ) : Prop := ...
def primitiveNullTriple (v : Fin 3 → ℤ) : Prop := ...

theorem preserves_nullcone
    {M : Matrix (Fin 3) (Fin 3) ℤ}
    (hM : preservesMinkowski M)
    {v : Fin 3 → ℤ} :
    minkowskiQ (M.mulVec v) = minkowskiQ v

theorem rootTriple_primitiveNull : primitiveNullTriple rootTriple

inductive Gen where | a | b | c
def genMatrix : Gen → Matrix (Fin 3) (Fin 3) ℤ
def evalWord : List Gen → Matrix (Fin 3) (Fin 3) ℤ
def tripleOfWord (w : List Gen) : Fin 3 → ℤ := ...
def displacementProfile (M : Matrix (Fin 3) (Fin 3) ℤ) : ℤ × ℤ × ℤ × ℤ := ...

theorem berggren_first_letter_unique
    {g h : Gen} {w w' : List Gen}
    (hne : g ≠ h) :
    displacementProfile (evalWord (g :: w)) ≠
    displacementProfile (evalWord (h :: w'))

theorem berggren_orbit_injective
    {w w' : List Gen}
    (h : tripleOfWord w = tripleOfWord w') :
    w = w'

theorem berggren_decode_unique
    {w w' : List Gen}
    (hw : reducedWord w)
    (hw' : reducedWord w')
    (hprof : displacementProfile (evalWord w) = displacementProfile (evalWord w')) :
    w = w'
```

If `berggren_orbit_injective` is too ambitious immediately, prove the nontrivial special case:
```lean
theorem berggren_eval_root_injective_len2
    {g₁ g₂ h₁ h₂ : Gen}
    (h :
      tripleOfWord [g₁, g₂] =
      tripleOfWord [h₁, h₂]) :
    [g₁, g₂] = [h₁, h₂]
```
This is a good finite prototype for the sector-separation mechanism.

---

### Why this matters

This theorem is not just about Pythagorean triples. It formalizes a new bridge:

- **Arithmetic group theory**: the Berggren semigroup becomes a positive, discrete Lorentzian semigroup inside an integral isometry group.
- **Hyperbolic geometry**: primitive triples become boundary/light-cone data, and word reconstruction from displacement profiles becomes a formal length-spectrum rigidity phenomenon.
- **Cryptography / factoring vision**: if Berggren words encode arithmetic structure, then rigidity from a small geometric profile is a prototype for recovering hidden semigroup elements from spectral leakage.
- **Physics connection**: the null cone and future-directed positivity are exactly the language of Lorentzian causality; this imports causal separation ideas into discrete arithmetic decoding.
- **Algorithmic shadow**: the proof should yield a recursive decoder from profile inequalities, not merely an existence theorem.

The deepest version of this program would replace the surrogate profile by true hyperbolic translation lengths of an associated `SL₂` or Lorentz action. Even the surrogate theorem already opens that road: once first-letter separation and inductive cancellation are formalized, one can swap in finer spectral invariants later.

---

### If the full theorem resists

Prove the strongest available chain:

1. `A_preservesMinkowski`, `B_preservesMinkowski`, `C_preservesMinkowski`
2. null-cone invariance
3. positivity preservation on the Berggren orbit
4. a pairwise-disjoint image theorem for `A`, `B`, `C` on orbit triples
5. `berggren_first_letter_unique`
6. finite-length injectivity (`len ≤ 2` or `len ≤ 3`)
7. conjecture the full rigidity theorem with exact signature

A precise conjecture, if needed:
```lean
conjecture berggren_decode_unique
    {w w' : List Gen}
    (hw : reducedWord w)
    (hw' : reducedWord w')
    (hprof : displacementProfile (evalWord w) = displacementProfile (evalWord w')) :
    w = w'
```

Also produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, such as:
1. replace surrogate profiles by genuine hyperbolic translation lengths;
2. prove freeness of the positive Lorentzian Berggren semigroup internally in Lean;
3. transfer the rigidity theorem to an `SL₂(ℤ)` or modular-geodesic model;
4. formulate a certified decoding algorithm from noisy profiles;
5. connect Lorentzian Berggren rigidity to hidden-subsemigroup recovery in post-quantum cryptographic models.

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

Research domain: Physics
Research mode: prove
