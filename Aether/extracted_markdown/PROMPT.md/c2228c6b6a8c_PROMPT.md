## YOUR ASSIGNMENT: Spectral Jacobson–Evaluation Elimination for Coherent Idempotent Semirings

Work in a coherent idempotent commutative semiring `S` and polynomial semirings
`SX := MvPolynomial σ S`, `SXY := MvPolynomial (σ ⊕ τ) S`, where `σ` are the
`x`-variables and `τ` the eliminated `y`-variables. The goal is to replace
determinantal/resultant elimination by a genuinely spectral construction:
elimination should be reconstructed as an infimum of contractions along
evaluation maps, and then shown to agree with the intrinsic elimination
congruence by prime separation plus quasicompactness.

### Core definitions to introduce

You should define the contraction of a semiring congruence along a semiring hom,
and then define the spectral evaluation elimination congruence as the infimum of
all such contractions along admissible evaluations.

A good concrete Lean shape is:

```lean
import Mathlib

open scoped BigOperators

universe u v w

variable {S : Type u} [CommSemiring S]
variable {σ : Type v} {τ : Type w}

abbrev SX  := MvPolynomial σ S
abbrev SXY := MvPolynomial (Sum σ τ) S

/-- Pull back a semiring congruence along a semiring hom. -/
def SemiringCong.comap
    {R A : Type*} [Semiring R] [Semiring A]
    (f : R →+* A) (C : SemiringCong A) : SemiringCong R :=
{ toSetoid := Setoid.comap f C.toSetoid
  mul' := by
    intro a b c d hab hcd
    simpa using C.mul hab hcd
  add' := by
    intro a b c d hab hcd
    simpa using C.add hab hcd }

/-- The `x`-part inclusion into `(x,y)` variables. -/
def liftX : SX →+* SXY :=
  MvPolynomial.rename (Sum.inl : σ → Sum σ τ)

/-- Evaluate the `y`-variables by `x`-polynomials, fixing `x`. -/
def evalXY (φ : τ → SX) : SXY →+* SX :=
  MvPolynomial.eval₂Hom
    (MvPolynomial.C : S →+* SX)
    (Sum.elim
      (fun i => MvPolynomial.X i)
      (fun j => φ j))

/-- Intrinsic elimination congruence: pairs of `x`-polynomials identified by `C`
after embedding into `S[x,y]`. -/
def eliminationCong (C : SemiringCong SXY) : SemiringCong SX :=
  C.comap liftX

/-- Spectral/evaluation elimination: infimum of all contractions along admissible
evaluation maps. The first version may quantify over all `φ : τ → SX`; later
refine to an `AdmissibleEval C φ` predicate if needed. -/
def SemiringCong.elimEval (C : SemiringCong SXY) : SemiringCong SX :=
  sInf {D : SemiringCong SX | ∃ φ : τ → SX, D = (C.comap (evalXY φ))}
```

If the admissibility condition from the existing elimination infrastructure is
already available, use it immediately:

```lean
def AdmissibleEval (C : SemiringCong SXY) (φ : τ → SX) : Prop := ...
def SemiringCong.elimEval (C : SemiringCong SXY) : SemiringCong SX :=
  sInf {D : SemiringCong SX | ∃ φ, AdmissibleEval C φ ∧ D = C.comap (evalXY φ)}
```

The entire project becomes sharper if admissibility encodes “evaluation preserves
vanishing on the relevant prime spectrum” rather than a syntactic side condition.

---

## TARGET THEOREMS

### 1. Basic contraction inequality

First prove the easy direction: every evaluation contraction contains intrinsic
elimination, hence the infimum does too.

A precise Lean target:

```lean
theorem eliminationCong_le_comap_evalXY
    (C : SemiringCong SXY) (φ : τ → SX) :
    eliminationCong C ≤ C.comap (evalXY φ) := by
  ...
```

and therefore

```lean
theorem eliminationCong_le_elimEval
    (C : SemiringCong SXY) :
    eliminationCong C ≤ C.elimEval := by
  ...
```

If your chosen convention reverses the order, prove the corresponding statement
with the names adjusted. The mathematical content required by the assignment is:

> `elimEval ≤ eliminationCong` or `eliminationCong ≤ elimEval`
> depending on the lattice orientation already used in the congruence files.

Before proving anything, verify the order convention for `SemiringCong`; then
state both theorem names so the direction is unambiguous.

### 2. Reverse inclusion by prime separation

This is the breakthrough theorem. Under coherence / compact-prime hypotheses,
show that no pair outside elimination can survive all admissible evaluations.

A precise target should look like:

```lean
theorem elimEval_le_eliminationCong
    (hcoh : IsCoherentIdempotentSemiring S)
    (hcmp : CompactlyGeneratedPrimeCongruenceSpace S)
    (C : SemiringCong SXY) :
    C.elimEval ≤ eliminationCong C := by
  ...
```

or, if the hypotheses already exist in the catalog under different names, use
those exact structures. The theorem should conclude the equality:

```lean
theorem elimEval_eq_eliminationCong
    (hcoh : IsCoherentIdempotentSemiring S)
    (hcmp : CompactlyGeneratedPrimeCongruenceSpace S)
    (C : SemiringCong SXY) :
    C.elimEval = eliminationCong C := by
  exact le_antisymm
    (elimEval_le_eliminationCong hcoh hcmp C)
    (eliminationCong_le_elimEval C)
```

### 3. Finite witness theorem

The conceptual payoff is not just equality by an infinite infimum, but finite
reconstruction by quasicompactness. Prove that for finitely generated / compact
congruences there is a finite family of evaluations whose intersection already
equals elimination.

A precise target:

```lean
theorem exists_finite_elimEval_subfamily
    (hcoh : IsCoherentIdempotentSemiring S)
    (hcmp : CompactlyGeneratedPrimeCongruenceSpace S)
    (C : SemiringCong SXY)
    (hfg : C.IsCompact) :
    ∃ Φ : Finset (τ → SX),
      eliminationCong C =
        sInf {D : SemiringCong SX | ∃ φ ∈ Φ, D = C.comap (evalXY φ)} := by
  ...
```

If function types are inconvenient in `Finset`, replace `Finset (τ → SX)` by a
finite indexed family:

```lean
∃ n : ℕ, ∃ Φ : Fin n → (τ → SX), ...
```

This finite witness theorem is where coherence becomes algorithmic: elimination
is no longer an abstract spectral closure, but computable from finitely many
evaluation tests.

---

## PROOF STRATEGY

### Strategy A: Order-theoretic contraction + prime reconstruction
This is the most promising route.

1. **Prove functorial contraction lemmas.**
   Establish:
   ```lean
   theorem SemiringCong.comap_mono ...
   theorem SemiringCong.le_comap_iff ...
   theorem liftX_eq_evalXY_on_x (φ : τ → SX) :
     evalXY φ.comp? liftX = RingHom.id _  -- semiring version
   ```
   The key identity is that `evalXY φ` fixes the embedded `x`-subsemiring:
   for all `p : SX`,
   ```lean
   evalXY φ (liftX p) = p
   ```
   This immediately gives the easy inclusion.

2. **Reduce equality of congruences to prime testing.**
   Use the existing nucleus-spectrum comparison / prime reconstruction theorem:
   if two congruences have the same prime over-congruences (or same radical /
   nucleus), then they are equal under coherence hypotheses. You want a lemma of
   the form:
   ```lean
   theorem eq_of_same_prime_support
       (D E : SemiringCong SX) :
       primeSupport D = primeSupport E → D = E
   ```
   or whatever the catalog already gives in terms of nuclei or radicals.

3. **Separate a pair not in elimination.**
   Suppose `(f,g) ∉ eliminationCong C`. By spectral reconstruction, find a prime
   congruence `P` on `SX` with
   ```lean
   eliminationCong C ≤ P ∧ ¬ P.Rel f g
   ```
   Then use the projection/evaluation reconstruction theorem to lift `P` to a
   prime (or nucleus-prime) object over `SXY` compatible with `C`, and obtain an
   admissible evaluation `φ` whose contraction still misses `(f,g)`.

4. **Convert prime witness to evaluation witness.**
   This is the key intermediate lemma:
   ```lean
   theorem exists_eval_separating_pair
       (hcoh : ...)
       (C : SemiringCong SXY)
       {f g : SX}
       (hfg : ¬ eliminationCong C.Rel f g) :
       ∃ φ : τ → SX, ¬ (C.comap (evalXY φ)).Rel f g
   ```
   Once this is proved, the reverse inclusion follows immediately by unfolding
   `sInf`.

5. **Extract a finite family by quasicompactness.**
   For each non-related pair `(f,g)` outside elimination, obtain an open set of
   admissible evaluations separating it. Use quasicompactness of the relevant
   spectral space / zero locus to extract finitely many evaluations covering the
   complement. Then translate the cover back into equality of congruences.

Why this route is strongest: it aligns perfectly with the existing
nucleus-spectrum comparison machinery, and it converts the theorem from an
elementwise algebraic statement into a spectral compactness statement, which is
exactly the new field-opening viewpoint.

---

### Strategy B: Radical/nucleus equality first, then descend to congruences
If direct prime separation at the congruence level is messy, prove equality after
passing to the radical or compact nucleus.

1. Show:
   ```lean
   nucleus (C.elimEval) = nucleus (eliminationCong C)
   ```
   by comparing the prime spectra of both sides.

2. Use the catalog theorem that coherent congruences are reconstructed from their
   compact nuclei / radicals.

3. Deduce congruence equality.

This may avoid direct handling of all semiring-congruence relations in favor of
a cleaner locale/spectral language.

---

### Strategy C: Finite-generation first
If the full theorem is too hard globally, first prove it for compact/finitely
generated `C`, then derive the general statement by directed suprema if the
catalog contains continuity of elimination and of `comap`.

1. Show both `eliminationCong` and `elimEval` commute with directed `sSup`.
2. Reduce to compact `C`.
3. Apply quasicompact spectral reconstruction there.

This is especially good if coherence is already packaged as compact generation.

---

## KEY INTERMEDIATE LEMMAS TO TARGET

These are the likely bottlenecks. Prove them cleanly; the main theorem should
then collapse.

```lean
theorem evalXY_liftX (φ : τ → SX) (p : SX) :
    evalXY φ (liftX p) = p := by
  ...
```

```lean
theorem eliminationCong_le_comap_evalXY
    (C : SemiringCong SXY) (φ : τ → SX) :
    eliminationCong C ≤ C.comap (evalXY φ) := by
  intro f g hfg
  simpa [eliminationCong, SemiringCong.comap, evalXY_liftX φ] using hfg
```

```lean
theorem rel_of_elimEval
    (C : SemiringCong SXY) {f g : SX}
    (h : C.elimEval.Rel f g) :
    ∀ φ : τ → SX, (C.comap (evalXY φ)).Rel f g := by
  ...
```

```lean
theorem exists_prime_separating_not_elimination
    (hcoh : ...)
    (C : SemiringCong SXY) {f g : SX}
    (hfg : ¬ eliminationCong C.Rel f g) :
    ∃ P : SemiringCong SX, IsPrimeCongruence P ∧
      eliminationCong C ≤ P ∧ ¬ P.Rel f g := by
  ...
```

```lean
theorem prime_lifts_to_admissible_eval
    (hcoh : ...)
    (hcmp : ...)
    (C : SemiringCong SXY)
    (P : SemiringCong SX)
    (hP : IsPrimeCongruence P)
    (hPC : eliminationCong C ≤ P) :
    ∃ φ : τ → SX, AdmissibleEval C φ ∧ C.comap (evalXY φ) ≤ P := by
  ...
```

```lean
theorem exists_eval_separating_pair
    (hcoh : ...)
    (hcmp : ...)
    (C : SemiringCong SXY) {f g : SX}
    (hfg : ¬ eliminationCong C.Rel f g) :
    ∃ φ : τ → SX, AdmissibleEval C φ ∧
      ¬ (C.comap (evalXY φ)).Rel f g := by
  ...
```

The last lemma is the conceptual heart of the project.

---

## LEAN IMPLEMENTATION NOTES

1. **Check existing names before introducing new classes.**
   The hypotheses `IsCoherentIdempotentSemiring S`,
   `CompactlyGeneratedPrimeCongruenceSpace S`, `IsPrimeCongruence`, `IsCompact`
   are placeholders here. Replace them by the exact catalog names if they exist.

2. **Prefer `MvPolynomial` over ad hoc polynomial towers.**
   The variables split naturally via `Sum σ τ`, and `rename`/`eval₂Hom` make the
   `liftX` and `evalXY` maps canonical.

3. **Be explicit about lattice operations on congruences.**
   You will likely need:
   ```lean
   show ∀ D ∈ {D | ∃ φ, ...}, eliminationCong C ≤ D
   ```
   then conclude by `le_iInf` / `le_sInf` depending on the actual complete-lattice
   API for `SemiringCong`.

4. **Expect to prove helper lemmas about `Setoid.comap`.**
   Mathlib often has the ring-ideal analogues, but semiring-congruence versions
   may need to be supplied.

5. **If admissibility is spectral, isolate it from algebraic manipulations.**
   First develop the unrestricted theorem over all `φ`; then prove that the same
   infimum is unchanged if restricted to admissible `φ` using the prime-lifting
   theorem.

---

## STRONGEST SPECIAL CASE IF THE FULL THEOREM STALLS

If the full coherent spectral theorem is not yet reachable, prove the unrestricted
evaluation theorem and a compact one-variable case.

### Special case A: unrestricted evaluations
```lean
theorem eliminationCong_le_elimEval_all
    (C : SemiringCong SXY) :
    eliminationCong C ≤
      sInf {D : SemiringCong SX | ∃ φ : τ → SX, D = C.comap (evalXY φ)} := by
  ...
```

### Special case B: one eliminated variable over `ℕ∞`-style idempotent semirings
Take `τ = PUnit` and prove the separation theorem there. Even this would be
substantial and likely enough to expose the right spectral argument.

### Special case C: equality after radicalization
```lean
theorem radical_elimEval_eq_radical_eliminationCong
    (hcoh : ...)
    (hcmp : ...)
    (C : SemiringCong SXY) :
    radical (C.elimEval) = radical (eliminationCong C) := by
  ...
```

This is not a consolation prize: radical equality already says evaluation maps
detect the same geometric locus as elimination, which is a major conceptual step.

---

## WHY THIS MATTERS

This theorem would create a new elimination theory for idempotent semirings that
is spectral rather than determinant-based. That is a genuine change of paradigm.

- It says elimination is not fundamentally about resultants or Gröbner-style
  symbolic manipulation; it is about reconstructing congruences from their prime
  geometric shadows and testing them by admissible evaluations.
- It turns elimination into a Jacobson-type principle: to know whether two
  `x`-polynomials become identified after eliminating `y`, it suffices to test
  them against enough evaluation morphisms.
- The finite witness theorem gives an algorithmic shadow: quasicompact geometry
  implies finite certificates for elimination. That opens the door to certified
  elimination algorithms in tropical and idempotent settings.
- This is the missing bridge between congruence geometry, tropical substitution,
  and constructive decision procedures. It could become the foundation for:
  1. evaluation-based tropical quantifier elimination,
  2. finite certificate systems for idempotent algebraic dependence,
  3. spectral algorithms for congruence membership,
  4. new semantics for tropical/interpretable neural architectures where hidden
     variables are eliminated by finite evaluation witnesses.

This is exactly the kind of theorem that makes the spectrum do computational
work.

---

## FILE TARGET

Create and develop:

```lean
Algebra/AutoResearch/SpectralEvaluationElimination.lean
```

Structure the file so that the basic algebraic lemmas (`comap`, `evalXY_liftX`,
monotonicity, infimum lemmas) are reusable independently of the spectral theorem.

---

## REQUIRED FUTURE_DIRECTIONS.md

Produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps that build directly
on this theorem. They must be specific and breakthrough-level, for example:

1. Jacobson–Chevalley theorem for multi-stage elimination in coherent idempotent
   semirings.
2. Effective finite witness bounds: quantify the number/degree of evaluations
   needed in terms of compact generators.
3. Tropical quantifier elimination via admissible evaluation spectra.
4. Categorical reformulation: elimination as a right Kan extension over the
   evaluation site.
5. Algorithm extraction: certified decision procedure for congruence elimination
   from quasicompact prime covers.

Be precise: each next step should include a theorem-level target, not a vague
theme.

### Catalog Reference Files
            @Speculative/AutoResearch/CongruenceElimination.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Functorial Resultant and Projection Reconstruction for Idempotent Semiring Congruences

This file builds an elimination mechanism for semiring congruences on multivariate
polynomials, parallel to classical resultant elimination but adapted to semiring
congruences rather than ideals.

## Overview

We work in a commutative semiring `S` with polynomial variables split as `Option σ`,
where `none` is the eliminated variable and `some i` are the retained variables.

Using the Mathlib equivalence `MvPolynomial.optionEquivLeft`, we view
`MvPolynomial (Option σ) S` as `Polynomial (MvPolynomial σ S)` — a univariate polynomial
in the distinguished variable `none` with coefficients in the retained-variable ring.

## Main definitions

* `SemiringCong` — a semiring congruence (equivalence compatible with `+` and `*`)
* `coeffNone` — extracts the n-th coefficient in the `none` variable
* `noneDegree` — maximum exponent of `none` in the support
* `PolyPair` — a pair of polynomials representing a congruence generator
* `liftSome` — the embedding `MvPolynomial σ S →ₐ[S] MvPolynomial (Option σ) S`
* `eliminationCong` — pullback of a semiring congruence along `liftSome`
* `linResultantPair` — cross-multiplied coefficient pair for linear generators

## Main results

* `coeffNone_add` — coefficient extraction is additive
* `coeffNone_X_none_pow_mul_liftSome` — key computation for `X none ^ k * liftSome a`
* `linear_expand_of_noneDegree_le_one` — decomposition of linear polynomials
* `mem_eliminationCong_iff` — characterization of elimination congruence
* `cross_mul_mem` — cross-multiplication theorem for congruence pairs
* `eliminationCong_mono` — monotonicity of elimination
-/

import Mathlib

open MvPolynomial Polynomial

/-! ## Semiring Congruence -/

/-- A semiring congruence: an equivalence relation compatible with `+` and `*`. -/
structure SemiringCong (A : Type*) [Semiring A] where
  r : A → A → Prop
  refl' : ∀ a, r a a
  symm' : ∀ {a b}, r a b → r b a
  trans' : ∀ {a b c}, r a b → r b c → r a c
  add' : ∀ {a b c d}, r a b → r c d → r (a + c) (b + d)
  mul' : ∀ {a b c d}, r a b → r c d → r (a * c) (b * d)

namespace SemiringCong

variable {A : Type*} [Semiring A]

instance : LE (SemiringCong A) where
  le C D := ∀ ⦃a b⦄, C.r a b → D.r a b

end SemiringCong

/-! ## Type Abbreviations -/

/-- The "full" polynomial ring with the distinguished variable. -/
abbrev PolyFull (S : Type*) (σ : Type*) [CommSemiring S] := MvPolynomial (Option σ) S

/-- The "retained" polynomial ring without the distinguished variable. -/
abbrev PolyRet (S : Type*) (σ : Type*) [CommSemiring S] := MvPolynomial σ S

/-! ## Additive Idempotency -/

/-- A type with addition is additively idempotent if `a + a = a` for all elements. -/
class AddIdempotent (S : Type*) [Add S] : Prop where
  add_self : ∀ a : S, a + a = a

theorem add_self_eq {S : Type*} [Add S] [AddIdempotent S] (a : S) : a + a = a :=
  AddIdempotent.add_self a

/-! ## Coefficient Extraction -/

/-- Extract the n-th coefficient of the distinguished variable `none`. -/
noncomputable def coeffNone {S : Type*} [CommSemiring S] {σ : Type*}
    (n : ℕ) (f : PolyFull S σ) : PolyRet S σ :=
  Polynomial.coeff (optionEquivLeft S σ f) n

/-- `coeffNone` as an additive group homomorphism. -/
noncomputable def coeffNoneHom {S : Type*} [CommSemiring S] {σ : Type*}
    (n : ℕ) : PolyFull S σ →+ PolyRet S σ where
  toFun := coeffNone n
  map_zero' := by simp [coeffNone, map_zero]
  map_add' f g := by simp [coeffNone, map_add]

/-! ## Degree in the Distinguished Variable -/

/-- Maximum exponent of `none` in the support of `f`. -/
noncomputable def noneDegree {S : Type*} [CommSemiring S] {σ : Type*}
    (f : PolyFull S σ) : ℕ :=
  (optionEquivLeft S σ f).natDegree

/-! ## Polynomial Pairs -/

/-- A pair of polynomials representing a congruence generator. -/
structure PolyPair (S : Type*) (σ : Type*) [CommSemiring S] where
  lhs : PolyFull S σ
  rhs : PolyFull S σ

/-! ## Embedding and Elimination -/

/-- The canonical embedding `MvPolynomial σ S →ₐ[S] MvPolynomial (Option σ) S`. -/
noncomputable def liftSome {S : Type*} [CommSemiring S] {σ : Type*} :
    PolyRet S σ →ₐ[S] PolyFull S σ :=
  MvPolynomial.rename Option.some

/-- Elimination congruence: pullback of `C` along `liftSome`. -/
def eliminationCong {S : Type*} [CommSemiring S] {σ : Type*}
    (C : SemiringCong (PolyFull S σ)) : SemiringCong (PolyRet S σ) where
  r f g := C.r (liftSome f) (liftSome g)
  refl' a := C.refl' (liftSome a)
  symm' h := C.symm' h
  trans' h1 h2 := C.trans' h1 h2
  add' h1 h2 := by
    show C.r (liftSome (_ + _)) (liftSome (_ + _))
    simp only [map_add]; exact C.add' h1 h2
  mul' h1 h2 := by
    show C.r (liftSome (_ * _)) (liftSome (_ * _))
    simp only [map_mul]; exact C.mul' h1 h2

/-! ## Structural Lemmas for coeffNone -/

section CoeffNone

variable {S : Type*} [CommSemiring S] {σ : Type*}

@[simp]
theorem coeffNone_add (n : ℕ) (f g : PolyFull S σ) :
    coeffNone n (f + g) = coeffNone n f + coeffNone n g := by
  simp [coeffNone, map_add]

@[simp]
theorem coeffNone_zero (n : ℕ) : coeffNone n (0 : PolyFull S σ) = 0 := by
  simp [coeffNone, map_zero]

/-- `optionEquivLeft` sends `liftSome r` to `Polynomial.C r`. -/
theorem optionEquivLeft_liftSome (r : PolyRet S σ) :
    optionEquivLeft S σ (liftSome r) = Polynomial.C r := by
  show optionEquivLeft S σ ((MvPolynomial.rename Option.some) r) = _
  induction r using MvPolynomial.induction_on with
  | C a => simp [optionEquivLeft_C]
-- ... (truncated, full file has 387 lines)
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

Research domain: Algebra
Research mode: prove
