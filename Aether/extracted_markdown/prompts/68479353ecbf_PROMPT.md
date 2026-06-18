## YOUR ASSIGNMENT: Quantum Berggren hidden-shift rigidity via geodesic length fingerprints and collision-resistant key extraction

### Core objects to define in Lean

Work with the existing Berggren generators `berggrenMat₁`, `berggrenMat₂`, `berggrenMat₃` and the existing action on primitive Pythagorean triples. Introduce a concrete word model and a concrete truncated fingerprint.

A good starting point is:

```lean
abbrev BerggrenWord := List (Fin 3)
```

Define the generator lookup:

```lean
def berggrenGen : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
| ⟨0, _⟩ => berggrenMat₁
| ⟨1, _⟩ => berggrenMat₂
| ⟨2, _⟩ => berggrenMat₃
```

Define word evaluation by left-multiplication:

```lean
def evalWord : BerggrenWord → Matrix (Fin 3) (Fin 3) ℤ
| [] => 1
| i :: w => berggrenGen i * evalWord w
```

Define abelianized generator counts:

```lean
def abelianCount (w : BerggrenWord) : Fin 3 → ℕ :=
  fun i => w.count i
```

If distributions over words are needed, use finitely supported functions:

```lean
def WordDist := BerggrenWord →₀ ℤ
```

and define the aggregated abelianized profile

```lean
def distAbelianProfile (μ : WordDist) : Fin 3 → ℤ :=
  fun i => μ.sum (fun w c => c * (abelianCount w i : ℤ))
```

You should also define a concrete triple type if not already present. If the catalog already contains a primitive triple structure, use it. Otherwise a minimal fallback is:

```lean
structure PTTriple where
  x y z : ℤ
  primitive : Int.gcd x.natAbs (Int.gcd y.natAbs z.natAbs) = 1
  pythagorean : x*x + y*y = z*z
  positive : 0 < x ∧ 0 < y ∧ 0 < z
```

For the geometric statistic, use a logarithmic hyperbolic surrogate if a true geodesic length already exists in the catalog; otherwise define an arithmetic proxy that is monotone under Berggren generators. The preferred interface is:

```lean
def geomLen (t : PTTriple) : ℝ := Real.log (t.z : ℝ)
```

or, if already available, reuse the catalog’s Lorentzian/hyperbolic length.

Define a height and finite ball:

```lean
def height (t : PTTriple) : ℕ := t.z.natAbs

def finiteBall (R : ℕ) : Finset PTTriple := ...
```

where `finiteBall R` enumerates primitive triples with `height t ≤ R`. If full enumeration is hard, first define a certified finite subset with the correct containment property and prove theorems relative to that subset.

Then define the truncated fingerprint:

```lean
def fingerprintR (R : ℕ) (w : BerggrenWord) : Finset ℝ :=
  (finiteBall R).image (fun t => geomLen (actMatrixTriple (evalWord w) t))
```

For aggregated distributions, define:

```lean
def distFingerprintR (R : ℕ) (μ : WordDist) : Finset ℝ :=
  μ.support.biUnion (fun w => fingerprintR R w)
```

If multiset multiplicities are essential, prefer `Finset (ℕ × ℝ)` or a finitely supported frequency map over bare `Finset ℝ`; collision-resistance is stronger with multiplicity retained.

---

### Precise target theorem

The theorem should not be a vague injectivity claim; it should explicitly identify what finite-ball equality forces. A robust Lean-facing target is:

```lean
theorem finiteBall_fingerprint_injective_abelianized
  (R : ℕ)
  (hR : R0 ≤ R)
  {w₁ w₂ : BerggrenWord}
  (hfp : fingerprintR R w₁ = fingerprintR R w₂) :
  abelianCount w₁ = abelianCount w₂
```

for some explicit certified threshold `R0 : ℕ` that you construct.

A stronger and more research-significant distributional version is:

```lean
theorem finiteBall_distFingerprint_rigidity
  (R : ℕ)
  (hR : R0 ≤ R)
  {μ ν : WordDist}
  (hfp : distFingerprintR R μ = distFingerprintR R ν) :
  distAbelianProfile μ = distAbelianProfile ν
```

If equality of raw fingerprints is too strong or too brittle, replace it by equality of a richer statistic map:

```lean
def fingerprintStatsR (R : ℕ) (w : BerggrenWord) : Fin 3 → ℤ := ...
```

and prove

```lean
theorem fingerprintStatsR_complete_for_abelianization
  (R : ℕ) (hR : R0 ≤ R) {w₁ w₂ : BerggrenWord}
  (h : fingerprintStatsR R w₁ = fingerprintStatsR R w₂) :
  abelianCount w₁ = abelianCount w₂
```

This is likely the best formal target if direct set-level injectivity is difficult.

---

### Intermediate monotonicity/separation lemmas you should prove

The main theorem will stand or fall with one well-chosen statistic. You need a statistic on triples whose change under each generator has a distinct, controlled signature. Good candidates are `z`, `x+y`, `z-x`, `z-y`, or a Lorentzian linear form already present in the catalog.

A concrete and formalizable route is to define three generator-sensitive observables:

```lean
def statA (t : PTTriple) : ℤ := t.z
def statB (t : PTTriple) : ℤ := t.z - t.y
def statC (t : PTTriple) : ℤ := t.z - t.x
```

Then prove exact transformation formulas or at least strict inequalities for each generator:

```lean
theorem statA_gen1_gt (t : PTTriple) :
  statA (actMatrixTriple berggrenMat₁ t) > statA t := ...

theorem statA_gen2_gt (t : PTTriple) :
  statA (actMatrixTriple berggrenMat₂ t) > statA t := ...

theorem statA_gen3_gt (t : PTTriple) :
  statA (actMatrixTriple berggrenMat₃ t) > statA t := ...
```

More importantly, prove **relative separation**:

```lean
theorem generator_separation_on_stats (t : PTTriple) :
  Pairwise (fun u v : Fin 3 =>
    u ≠ v →
    statVec (actMatrixTriple (berggrenGen u) t) ≠
    statVec (actMatrixTriple (berggrenGen v) t)) := ...
```

where

```lean
def statVec (t : PTTriple) : ℤ × ℤ × ℤ := (statA t, statB t, statC t)
```

Even better is an exact affine update law:

```lean
theorem statVec_gen_update (i : Fin 3) (t : PTTriple) :
  statVec (actMatrixTriple (berggrenGen i) t) =
    genUpdate i (statVec t) := ...
```

for explicitly computed `genUpdate`. This gives a linear-dynamical system on statistics and makes abelianization visible.

The crucial finite-ball witness theorem should then have the form:

```lean
theorem exists_small_witness_of_abelian_difference
  {w₁ w₂ : BerggrenWord}
  (hneq : abelianCount w₁ ≠ abelianCount w₂) :
  ∃ R ≤ R0, fingerprintR R w₁ ≠ fingerprintR R w₂
```

This theorem is the true cryptographic collision obstruction: any abelian mismatch is detected on a certified bounded test set.

---

### Suggested proof architecture

#### Strategy A: linear-statistic transport on a base triple (most promising)

Use the root primitive triple, usually `(3,4,5)` or its catalog equivalent, and track a small vector of integer observables under the Berggren generators. The aim is to show that these observables evolve by generator-dependent affine transformations whose cumulative effect depends only on abelianized counts at the truncation level you test.

Concrete steps:

1. **Compute generator action on a statistic basis.**  
   For each generator `berggrenMatᵢ`, explicitly compute the image of `(x,y,z)` and derive formulas for `statA`, `statB`, `statC`.  
   Key goal: distinct first-order increments or triangular recurrences.

2. **Prove monotonic growth and positivity preservation.**  
   Show each generator sends primitive positive triples to primitive positive triples and strictly increases `height`.  
   This gives termination/control for finite-ball searches and ensures no spurious cancellations.

3. **Extract abelianized information from aggregated statistics.**  
   Show that for a carefully chosen finite set of seed triples inside `finiteBall R`, the multiset of transformed lengths determines the sums of generator increments.  
   Formally, prove that equality of fingerprints implies equality of the induced statistic sums, then solve for `abelianCount`.

4. **Certify a finite radius `R0`.**  
   Pick enough low-height primitive triples so that the resulting linear system in the unknown counts has full rank.  
   In Lean this may appear as a determinant-nonzero statement for a small explicit integer matrix.

5. **Package the executable distinguisher.**  
   Implement a decision procedure comparing `fingerprintR R w₁` and `fingerprintR R w₂`, and prove:
   ```lean
   theorem compareFingerprint_correct
     (R : ℕ) (w₁ w₂ : BerggrenWord) :
     compareFingerprint R w₁ w₂ = true ↔ fingerprintR R w₁ = fingerprintR R w₂ := ...
   ```

Why this is most promising: it converts the semigroup problem into explicit finite-dimensional integer linear algebra, which Lean handles well once the formulas are concrete.

---

#### Strategy B: length-spectrum rigidity via ordered minima

Instead of using the whole fingerprint set, order the transformed lengths and look at the smallest few values. Because Berggren generators are height-increasing and asymmetric, the first one or two minima may already encode the leading generator counts.

Possible formalization:

```lean
def minFingerprintR (R : ℕ) (w : BerggrenWord) : Option ℝ := ...
def firstKFingerprintR (R k : ℕ) (w : BerggrenWord) : List ℝ := ...
```

Then prove that distinct abelianized profiles force distinct first-`k` ordered spectra for some fixed `k` and `R0`.

This route is elegant and closer to genuine spectral rigidity, but it depends on stronger ordering lemmas over `ℝ` and more delicate combinatorics of minima in `Finset.image`.

---

#### Strategy C: generating-function / tropical shadow approach

Encode each word by a monomial in three commuting variables recording generator counts, and show the finite-ball fingerprint induces a tropicalized evaluation functional that separates exponent vectors.

For example, define a commutative shadow:

```lean
def abelMonomial (w : BerggrenWord) : MvPolynomial (Fin 3) ℤ := ...
```

and prove that a suitable statistic extracted from `fingerprintR` equals evaluation of a linear/tropical functional on this monomial. Then injectivity follows from separation of exponent vectors by enough evaluations.

This is conceptually powerful because it links hidden-shift rigidity to tropical information extraction, but it is probably heavier formally unless the catalog already contains the tropical infrastructure.

---

### Concrete proof steps and key lemmas

1. **Word evaluation homomorphism**
   ```lean
   theorem evalWord_append (u v : BerggrenWord) :
     evalWord (u ++ v) = evalWord u * evalWord v := ...
   ```
   This is essential for inductive arguments on words.

2. **Abelianization additivity**
   ```lean
   theorem abelianCount_append (u v : BerggrenWord) :
     abelianCount (u ++ v) = fun i => abelianCount u i + abelianCount v i := ...
   ```

3. **Primitive-triple invariance under generators**
   ```lean
   theorem act_gen_preserves_PTTriple (i : Fin 3) (t : PTTriple) :
     IsPrimitiveTriple t → IsPrimitiveTriple (actMatrixTriple (berggrenGen i) t) := ...
   ```
   If the catalog already has this, reuse it aggressively.

4. **Height growth**
   ```lean
   theorem height_strict_mono_gen (i : Fin 3) (t : PTTriple) :
     height (actMatrixTriple (berggrenGen i) t) > height t := ...
   ```
   This gives finite search and spectral ordering control.

5. **Generator separation on a finite seed set**
   Define a tiny explicit seed set `S ⊆ finiteBall R0` and prove:
   ```lean
   theorem seed_stat_matrix_nondegenerate :
     Int.det seedMatrix ≠ 0 := ...
   ```
   where `seedMatrix` records the effect of each generator on each chosen seed/statistic. This is the algebraic heart of finite-ball injectivity.

6. **Witness extraction**
   ```lean
   theorem abelian_difference_detected_on_seed
     {w₁ w₂ : BerggrenWord}
     (hneq : abelianCount w₁ ≠ abelianCount w₂) :
     ∃ t ∈ finiteBall R0,
       geomLen (actMatrixTriple (evalWord w₁) t) ≠
       geomLen (actMatrixTriple (evalWord w₂) t) := ...
   ```
   This is stronger than set inequality and easier to use computationally.

---

### Executable algorithmic target

You should not stop at existence theorems. Define and verify a computable distinguisher.

A clean API is:

```lean
def fingerprintCodeR (R : ℕ) (w : BerggrenWord) : List ℤ := ...
```

where `fingerprintCodeR` uses an exact integer-coded statistic, e.g. sorted list of transformed hypotenuses or transformed `(z, z-y, z-x)` triples, instead of raw `ℝ` logs. Then define:

```lean
def compareFingerprint (R : ℕ) (w₁ w₂ : BerggrenWord) : Bool :=
  fingerprintCodeR R w₁ == fingerprintCodeR R w₂
```

and prove:

```lean
theorem compareFingerprint_sound
  (R : ℕ) {w₁ w₂ : BerggrenWord} :
  compareFingerprint R w₁ w₂ = true →
  abelianCount w₁ = abelianCount w₂ := ...

theorem compareFingerprint_complete
  (R : ℕ) (hR : R0 ≤ R) {w₁ w₂ : BerggrenWord} :
  abelianCount w₁ = abelianCount w₂ →
  compareFingerprint R w₁ w₂ = true := ...
```

If completeness is false for your chosen code, prove soundness and exhibit a counterexample to completeness. Soundness already gives a collision-resistant key extraction invariant.

Then define the key extractor:

```lean
def keyExtract (R : ℕ) (w : BerggrenWord) : Fin 3 → ℕ :=
  recoverAbelianProfileFromFingerprint R (fingerprintCodeR R w)
```

and prove:

```lean
theorem keyExtract_correct
  (R : ℕ) (hR : R0 ≤ R) (w : BerggrenWord) :
  keyExtract R w = abelianCount w := ...
```

This is the sharpest cryptographic theorem in the project: the finite truncated length-spectrum yields a canonical extractable key.

---

### If the full theorem is too strong

If direct injectivity of `fingerprintR` on all words fails, isolate the strongest true statement. Three excellent fallback theorems are:

1. **Single-step rigidity**
   ```lean
   theorem fingerprintR_gen_injective
     (R : ℕ) (hR : R1 ≤ R) {i j : Fin 3} :
     fingerprintR R [i] = fingerprintR R [j] → i = j
   ```

2. **Fixed-length-word abelian rigidity**
   ```lean
   theorem fingerprintR_injective_on_length_n
     (R n : ℕ) (hR : Rn ≤ R) {w₁ w₂ : BerggrenWord}
     (hw₁ : w₁.length = n) (hw₂ : w₂.length = n)
     (hfp : fingerprintR R w₁ = fingerprintR R w₂) :
     abelianCount w₁ = abelianCount w₂
   ```

3. **Witnessed non-collision theorem**
   ```lean
   theorem fingerprintR_separates_distinct_abelianizations
     (R : ℕ) (hR : R0 ≤ R) {w₁ w₂ : BerggrenWord}
     (hneq : abelianCount w₁ ≠ abelianCount w₂) :
     fingerprintR R w₁ ≠ fingerprintR R w₂
   ```

This third theorem is mathematically cleaner than the implication-from-equality formulation and often easier to prove.

---

### Why this matters

This result creates a formal bridge between three worlds that are usually disjoint:

1. **Berggren dynamics / arithmetic semigroups**  
   You turn the primitive-triple tree into a rigid spectral object. That is already a new arithmetic rigidity principle.

2. **Hidden-shift and hidden-subsemigroup paradigms in quantum algorithms**  
   The theorem says that a truncated, classically computable length spectrum carries enough information to obstruct collisions in the positive Berggren semigroup at the abelianized level. This is a formal analogue of extracting a hidden invariant from partial spectral data.

3. **Cryptographic key extraction from discrete geometric dynamics**  
   The certified finite-ball regime gives an actual algorithm: compute a bounded fingerprint, recover a canonical profile, and use it as a collision-resistant invariant. This is not merely structural—it is computational.

If you can prove the distributional version, you open a genuinely new program: **spectral cryptography on arithmetic semigroup actions**, where hidden algebraic data are recovered from bounded geometric probes. That would make the Berggren tree a testbed for formally verified hidden-structure extraction, with possible extensions to thin groups, hyperbolic monoids, and tropicalized quantum invariants.

---

### Deliverables

1. Precise definitions:
   - `BerggrenWord`
   - `berggrenGen`
   - `evalWord`
   - `abelianCount`
   - `height`
   - `finiteBall`
   - `fingerprintR` or a stronger exact-coded variant

2. Main theorem:
   - `finiteBall_fingerprint_injective_abelianized`
   - or the strongest true separation/rigidity theorem you can certify

3. Algorithm:
   - `compareFingerprint`
   - correctness theorem(s)
   - if possible `keyExtract` with proof of correctness

4. At least one explicit certified radius theorem:
   ```lean
   theorem exists_certified_radius :
     ∃ R0 : ℕ, ∀ {w₁ w₂}, ...
   ```

5. A structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, such as:
   - full distributional rigidity for finitely supported word measures
   - extension from abelianized profiles to partial ordered-word recovery
   - tropicalization of the fingerprint and data-processing inequalities
   - analogues for other arithmetic semigroups or thin matrix groups
   - quantum query lower bounds derived from certified collision obstructions

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

Research domain: Cryptography
Research mode: prove
