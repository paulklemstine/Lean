## YOUR ASSIGNMENT: Berggren-tree lattice reduction and shortest-word rigidity for post-quantum key recovery via hyperbolic height descent

### Core formal objects

Work in Lean 4 with the existing primitive-triple infrastructure and the three standard Berggren matrices already present as `berggrenMat₁`, `berggrenMat₂`, `berggrenMat₃`.

Introduce the generator family:
```lean
def berggrenGen : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
| ⟨0, _⟩ => berggrenMat₁
| ⟨1, _⟩ => berggrenMat₂
| ⟨2, _⟩ => berggrenMat₃
```

Use the ambient triple type
```lean
abbrev Triple := Fin 3 → ℤ
```
and define the primitive positive Pythagorean triples as a subtype:
```lean
def PrimitiveTriple : Type := {v : Triple // pythagorean_primitive v}
```
If positivity is not already included in `pythagorean_primitive`, refine to
```lean
def positive_triple (v : Triple) : Prop := 0 < v 0 ∧ 0 < v 1 ∧ 0 < v 2

def PrimitiveTriple : Type :=
  {v : Triple // pythagorean_primitive v ∧ positive_triple v}
```

Define the root triple:
```lean
def rootTriple : PrimitiveTriple := ⟨![3, 4, 5], by
  -- primitive + pythagorean + positivity
⟩
```
or the equivalent `Fin 3 → ℤ` representation used in the file.

Define the action of a generator and of a word:
```lean
def actGen (i : Fin 3) (v : Triple) : Triple := berggrenGen i *ᵥ v

def actWord : List (Fin 3) → Triple → Triple
| [], v => v
| i :: w, v => actWord w (actGen i v)

def evalWord (w : List (Fin 3)) : PrimitiveTriple :=
  ⟨actWord w rootTriple.1, by
    -- preservation of primitive Pythagorean positivity
  ⟩
```

Define the height potential on primitive triples using the hypotenuse coordinate:
```lean
def cCoord (v : Triple) : ℤ := v 2

def berggrenHeight (v : PrimitiveTriple) : ℝ :=
  Real.log (Int.toReal (cCoord v.1))
```
You will likely need the positivity lemma
```lean
lemma cCoord_pos (v : PrimitiveTriple) : 0 < cCoord v.1 := ...
```
to justify `Real.log`.

### Parent map and canonical descent

Define the inverse-branch test. For each generator `i`, let
```lean
def invGen (i : Fin 3) : Matrix (Fin 3) (Fin 3) ℤ := (berggrenGen i)⁻¹
```
using the existing unimodularity facts, or define explicit inverse matrices if this is easier computationally.

Then define a branch predicate saying the inverse image stays inside `PrimitiveTriple`:
```lean
def isParentCandidate (i : Fin 3) (v : PrimitiveTriple) : Prop :=
  let w : Triple := invGen i *ᵥ v.1
  pythagorean_primitive w ∧ positive_triple w
```

Define the actual parent map by searching the three branches:
```lean
def parentBranch (v : PrimitiveTriple) : Option (Fin 3 × PrimitiveTriple) :=
  if hroot : v = rootTriple then none else
    if h0 : isParentCandidate ⟨0, by decide⟩ v then
      some (⟨0, by decide⟩, ⟨invGen ⟨0, by decide⟩ *ᵥ v.1, by ...⟩)
    else if h1 : isParentCandidate ⟨1, by decide⟩ v then
      some (⟨1, by decide⟩, ⟨invGen ⟨1, by decide⟩ *ᵥ v.1, by ...⟩)
    else if h2 : isParentCandidate ⟨2, by decide⟩ v then
      some (⟨2, by decide⟩, ⟨invGen ⟨2, by decide⟩ *ᵥ v.1, by ...⟩)
    else none
```

The intended theorem is that for every non-root primitive positive triple, exactly one branch succeeds.

### Precise target theorem statements

Prove as many of the following exact statements as possible, adjusting names only to fit local conventions.

#### 1. Uniqueness of parent branch
```lean
theorem parentBranch_unique
    (v : PrimitiveTriple) :
    ∀ {i j : Fin 3} {p q : PrimitiveTriple},
      parentBranch v = some (i, p) →
      parentBranch v = some (j, q) →
      i = j ∧ p = q
```

A stronger and more useful formulation is:
```lean
theorem exists_unique_parent_of_ne_root
    {v : PrimitiveTriple} (h : v ≠ rootTriple) :
    ∃! iq : Fin 3 × PrimitiveTriple, parentBranch v = some iq
```

And ideally branch exclusivity:
```lean
theorem inverse_branch_exclusive
    {v : PrimitiveTriple} {i j : Fin 3}
    (hi : isParentCandidate i v) (hj : isParentCandidate j v) :
    i = j
```

#### 2. Strict descent of height
```lean
theorem parent_height_lt
    {v p : PrimitiveTriple} {i : Fin 3}
    (h : parentBranch v = some (i, p)) :
    berggrenHeight p < berggrenHeight v
```

A stronger arithmetic version, often easier to prove first:
```lean
theorem parent_cCoord_lt
    {v p : PrimitiveTriple} {i : Fin 3}
    (h : parentBranch v = some (i, p)) :
    cCoord p.1 < cCoord v.1
```
Then derive `parent_height_lt` from monotonicity of `Real.log` on positive reals.

#### 3. Termination of iterated parent descent
Define the iterated parent chain:
```lean
def parentIter : ℕ → PrimitiveTriple → PrimitiveTriple
| 0, v => v
| n+1, v =>
    match parentBranch v with
    | none => v
    | some (_, p) => parentIter n p
```

Then prove:
```lean
theorem iterate_parent_terminates
    (v : PrimitiveTriple) :
    ∃ n : ℕ, parentIter n v = rootTriple
```

A more structural formulation is better for recursion:
```lean
theorem wellFounded_parent :
    WellFounded (fun v w : PrimitiveTriple => ∃ i, parentBranch w = some (i, v))
```

#### 4. Canonical normal form and uniqueness
Define the normal form word by recursively collecting parent labels:
```lean
def normalForm : PrimitiveTriple → List (Fin 3)
```
with the specification
```lean
theorem normalForm_spec
    (v : PrimitiveTriple) :
    evalWord (normalForm v) = v
```

Then prove uniqueness:
```lean
theorem normalForm_unique
    {v : PrimitiveTriple} {w₁ w₂ : List (Fin 3)}
    (h₁ : evalWord w₁ = v)
    (h₂ : evalWord w₂ = v)
    (hn₁ : w₁ = normalForm v)
    (hn₂ : w₂ = normalForm v) :
    w₁ = w₂
```
This is tautological as stated; the real target should be:

```lean
theorem evalWord_injective
    {w₁ w₂ : List (Fin 3)}
    (h : evalWord w₁ = evalWord w₂) :
    w₁ = w₂
```

or equivalently the faithfulness theorem on the root orbit:
```lean
theorem berggren_action_faithful_on_root_orbit
    {w₁ w₂ : List (Fin 3)}
    (h : actWord w₁ rootTriple.1 = actWord w₂ rootTriple.1) :
    w₁ = w₂
```

This is the formal shortest-word rigidity statement: two words giving the same primitive triple must coincide exactly, not merely after reduction.

#### 5. Greedy descent recovers the unique word
Define:
```lean
def decodeExact (v : PrimitiveTriple) : List (Fin 3) := normalForm v
```
and prove
```lean
theorem decodeExact_correct
    (v : PrimitiveTriple) :
    evalWord (decodeExact v) = v
```

### Noisy decoding / nearest-word infrastructure

Formalize a defect model on triples. If a full Euclidean nearest-plane theorem is too ambitious in one pass, start with a certified exact-recovery theorem under branch-stability inequalities.

Define a defect norm, e.g.
```lean
def tripleDefect (u v : Triple) : ℤ := |u 0 - v 0| + |u 1 - v 1| + |u 2 - v 2|
```
or a real-valued norm if existing infrastructure is easier.

Define a one-step decoder selecting the branch whose inverse image is “closest” to positive primitive shape:
```lean
def decodeStep (v : Triple) : Option (Fin 3 × Triple) := ...
```
Then recursively:
```lean
def decodeNearestWord : Triple → List (Fin 3) := ...
```

The bounded-defect correctness theorem should be stated in a form you can actually prove:

```lean
theorem decodeNearestWord_correct_of_bounded_defect
    (w : List (Fin 3)) (η : Triple)
    (hη : tripleDefect η (actWord w rootTriple.1) ≤ D)  -- choose explicit D
    (hsep : branch_separation_condition (actWord w rootTriple.1) D) :
    decodeNearestWord η = w
```

If a global uniform `D` is too strong, use a local certified-radius statement:
```lean
def certifiedRadius (v : PrimitiveTriple) : ℤ := ...

theorem decodeNearestWord_correct_of_local_radius
    (w : List (Fin 3)) (η : Triple)
    (hη : tripleDefect η (actWord w rootTriple.1) < certifiedRadius (evalWord w)) :
    decodeNearestWord η = w
```

This is fully aligned with the “lattice reduction” vision: nearest-normal-form descent replaces Euclidean basis reduction by a noncommutative geodesic descent on the Berggren tree.

---

## Proof strategy

### Strategy A: tree-theoretic rigidity via explicit inverse branches
This is the most promising route.

1. **Show each generator preserves primitive positive Pythagorean triples.**  
   Prove:
   ```lean
   lemma actGen_preserves_primitive
       (i : Fin 3) {v : Triple}
       (hv : pythagorean_primitive v ∧ positive_triple v) :
       pythagorean_primitive (actGen i v) ∧ positive_triple (actGen i v)
   ```
   This should come from explicit matrix identities, determinant `±1`/`1`, and the classical Berggren formulas.

2. **Write explicit inverse formulas and classify positivity regions.**  
   For each `i`, compute the coordinates of `invGen i *ᵥ v`. The key lemma is that for a primitive positive triple `v ≠ rootTriple`, exactly one inverse image has all coordinates positive and remains primitive. This is the formal heart:
   ```lean
   lemma unique_positive_inverse_branch
       {v : PrimitiveTriple} (h : v ≠ rootTriple) :
       ∃! i : Fin 3, isParentCandidate i v
   ```
   This gives `parentBranch_unique` and existence simultaneously.

3. **Use strict hypotenuse descent.**  
   Compute the third coordinate under each inverse branch explicitly and prove it is strictly smaller. You likely want arithmetic lemmas of the form
   ```lean
   lemma inv_branch_c_smaller
       {v : PrimitiveTriple} {i : Fin 3}
       (hi : isParentCandidate i v) :
       cCoord (invGen i *ᵥ v.1) < cCoord v.1
   ```
   Once this is in place, termination follows by well-founded descent on `Nat` via `Int.toNat (cCoord v.1)`.

4. **Define `normalForm` by well-founded recursion.**  
   Use the parent relation and `measure (fun v => Int.toNat (cCoord v.1))`. The recursive equation should append the unique parent label at the front or back consistently. Then prove `evalWord (normalForm v) = v` by induction along the parent recursion.

5. **Deduce faithfulness by comparing terminal parent chains.**  
   If `evalWord w₁ = evalWord w₂`, repeatedly apply `parentBranch` to both sides. Since the parent is unique, the first letters agree; recurse on the parent triple. This is the clean semigroup-freeness argument.

Why this route is best: it uses the arithmetic asymmetry of the three inverse branches directly, avoids abstract automata machinery, and produces the decoding algorithm almost for free.

### Strategy B: free-semigroup action via rooted-tree isomorphism
This is elegant if the file already contains enough combinatorial tree infrastructure.

1. Define the directed graph on `PrimitiveTriple` with edges `v → actGen i v`.
2. Prove every non-root node has indegree exactly `1` and root has indegree `0`.
3. Prove every node is reachable from root.
4. Conclude the graph is a rooted `3`-ary tree and identify vertices with words in `List (Fin 3)`.
5. Extract injectivity of `evalWord`.

This route is conceptually powerful, but in Lean it can be heavier because graph/tree infrastructure often creates more overhead than the arithmetic proof.

### Strategy C: matrix-word rigidity via coordinate invariants / cone separation
Use coordinate inequalities to separate the images of the three generators:
```lean
lemma branch_cone_separation :
  -- images of the three positive cones under inverse generators are disjoint
```
Then prove injectivity by showing the first letter of a word is determined by which cone the output lies in, and recurse. This is especially useful for the noisy decoder, because the cone inequalities naturally become robust separation margins.

This is the best route for the decoding theorem once exact rigidity is established.

---

## Concrete intermediate lemmas to target first

Prove these in order; they are the real engine.

```lean
lemma berggrenGen_det_one (i : Fin 3) :
  Matrix.det (berggrenGen i) = 1
```

```lean
lemma berggrenGen_inv_integer (i : Fin 3) :
  ∃ M : Matrix (Fin 3) (Fin 3) ℤ, M ⬝ berggrenGen i = 1 ∧ berggrenGen i ⬝ M = 1
```

```lean
lemma actGen_preserves_pythagorean
    (i : Fin 3) {v : Triple}
    (hv : pythagorean_primitive v) :
    pythagorean_primitive (actGen i v)
```

```lean
lemma root_has_no_parent :
  parentBranch rootTriple = none
```

```lean
lemma nonroot_has_parent
    {v : PrimitiveTriple} (h : v ≠ rootTriple) :
    ∃ i p, parentBranch v = some (i, p)
```

```lean
lemma parent_evalWord_tail
    {i : Fin 3} {w : List (Fin 3)} :
    parentBranch (evalWord (i :: w)) = some (i, evalWord w)
```
This lemma is extremely valuable: once proved, injectivity of `evalWord` becomes a one-line induction on words.

```lean
theorem evalWord_injective
    {w₁ w₂ : List (Fin 3)}
    (h : evalWord w₁ = evalWord w₂) :
    w₁ = w₂
```

```lean
theorem normalForm_eq_inverse_eval
    (w : List (Fin 3)) :
    normalForm (evalWord w) = w
```
This is the cleanest expression of shortest-word rigidity.

---

## Lean-specific implementation guidance

- If matrix multiplication on vectors becomes cumbersome, define triples as column vectors:
  ```lean
  abbrev TripleVec := Matrix (Fin 3) (Fin 1) ℤ
  ```
  and then use ordinary matrix multiplication. This can simplify `simp` with explicit entries.
- For explicit coordinate formulas, it may be easier to define:
  ```lean
  def aCoord (v : Triple) : ℤ := v 0
  def bCoord (v : Triple) : ℤ := v 1
  def cCoord (v : Triple) : ℤ := v 2
  ```
  and prove `ext` lemmas for triples.
- Use `fin_cases i` aggressively for generator-indexed proofs.
- If `Matrix.inv` over `ℤ` is inconvenient, define explicit inverse matrices by hand and prove two-sided inverse lemmas.
- For termination, avoid a direct recursion on `berggrenHeight : ℝ`; recurse on
  ```lean
  Int.toNat (cCoord v.1)
  ```
  and only later derive the logarithmic descent theorem.
- For noisy decoding, first formalize a decidable branch score and prove a theorem under a strong “separation margin” hypothesis rather than trying to solve the fully general nearest-word problem immediately.

---

## Why this matters

This is not just another formalization of Berggren’s theorem. The decisive new structure is:

1. **Free-semigroup rigidity on a natural arithmetic orbit.**  
   `evalWord_injective` upgrades generation into unique factorization inside a noncommutative arithmetic semigroup. This is a genuine algebraic infrastructure result.

2. **Hyperbolic-height descent as an algorithmic normal form.**  
   `parent_height_lt` and `iterate_parent_terminates` turn classical number theory into a certified reduction algorithm, analogous in spirit to lattice reduction but in a nonlinear arithmetic tree.

3. **A new cryptographic primitive.**  
   `decodeNearestWord_correct_of_bounded_defect` is the formal core of key recovery from noisy public data in a Berggren-word cryptosystem. The security/computation tradeoff comes from noncommutative factorization rigidity rather than abelian hidden structure.

4. **Cross-domain bridge.**  
   The height potential is a discrete geodesic energy; the normal form is a symbolic geodesic code; the decoder is a nearest-plane analogue in a hyperbolic arithmetic tree. This connects arithmetic dynamics, automata, lattice reduction, and post-quantum cryptography in one formal package.

If the full noisy decoder is too much for one pass, get the exact rigidity pipeline complete:
- `parentBranch_unique`
- `parent_height_lt`
- `iterate_parent_terminates`
- `evalWord_injective`
- `normalForm_eq_inverse_eval`

That already establishes the field-opening theorem: **primitive Pythagorean triples admit a unique Berggren normal form recovered by greedy height descent.**

---

## Minimum acceptable fallback if full theorem resists

If the complete `PrimitiveTriple` infrastructure is too heavy, prove the root-orbit version first:

```lean
def InRootOrbit (v : Triple) : Prop := ∃ w : List (Fin 3), actWord w rootTriple.1 = v
```

Then show:
```lean
theorem berggren_action_faithful_on_root_orbit
    {w₁ w₂ : List (Fin 3)}
    (h : actWord w₁ rootTriple.1 = actWord w₂ rootTriple.1) :
    w₁ = w₂
```

and
```lean
theorem exists_unique_normalForm_of_root_orbit
    {v : Triple} (hv : InRootOrbit v) :
    ∃! w : List (Fin 3), actWord w rootTriple.1 = v
```

This still delivers the shortest-word rigidity theorem in its strongest computational form.

---

## FUTURE_DIRECTIONS.md

Produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, at breakthrough level, for example:

1. Formal branch-separation radii yielding explicit certified decoding thresholds.
2. A Berggren nearest-plane analogue with complexity bounds polynomial in word length.
3. Symbolic geodesic coding for Lorentzian/hyperbolic Berggren dynamics beyond Pythagorean triples.
4. Cryptographic hardness reductions from noisy Berggren decoding to free-semigroup word recovery.
5. Higher-dimensional analogues for Markov-Hurwitz or Lorentzian norm-form trees.

Be precise: each future direction should include at least one exact Lean theorem signature or formal definition target.

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
Research mode: formalize
