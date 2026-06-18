
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: Close Proofs: The order-theoretic core of the Cook–Reckhow program in this catalog n
**Domain**: Novelty
**Mathematical framing**: Cycle d4cda211 (Q=0.469) proved 51 theorems in Novelty but left 2 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions: From Height and Width to the Full Order Type of the p-Degrees

## Synthesis

The order-theoretic core of the Cook–Reckhow program in this catalog now describes the
poset of p-degr
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/StableReduction.lean
/-
Copyright (c) 2025. All rights reserved.

# Stable Reduction: Variable Adjunction Preserves Invertibility

The stable lift `F↑m` of a polynomial map `F : k^n → k^n` adjoins `m` identity
coordinates: `F↑m(x,y) = (F(x), y)`. This file proves:

1. The Jacobian matrix of `F↑m` is block-diagonal: `J(F) ⊕ I_m`.
2. The Jacobian determinant is preserved: `det J(F↑m) = det J(F)` (as a
   polynomial in the extended variables, via renaming).
3. Polynomial invertibility is preserved in both directions.

These are foundational reduction theorems: they show that the Jacobian
conjecture for dimension `n` follows from the conjecture for any `n+m`.

## Keywords
stable equivalence, variable adjunction, block matrix, Jacobian determinant
-/

import Mathlib
import Algebra.Jacobian.Defs
import Algebra.Jacobian.Basic

namespace JacobianConjecture

open MvPolynomial Matrix

variable {k : Type*} [CommRing k] {n m : ℕ}

/-! ### Stable lift of the inverse -/

/-- If `G` is the polynomial inverse of `F`, then `stableLift G m` is the
    polynomial inverse of `stableLift F m`. -/
noncomputable def stableLiftInverse (G : PolyMap k n) (m : ℕ) : PolyMap k (n + m) :=
  stableLift G m

/-! ### Forward direction: invertibility lifts -/

/-
If `F` is a polynomial automorphism, then `stableLift F m` is too.
-/
theorem isPolyAuto_stableLift_of_isPolyAuto
    (F : PolyMap k n) (hF : isPolyAuto F) :
    isPolyAuto (stableLift F m) := by
  -- By definition of stableLift, we have G = stableLift G m.
  have hG : isPolyAuto (stableLift F m) := by
    obtain ⟨G, hFG⟩ := hF
    refine' ⟨ stableLift G m, _, _ ⟩ <;> simp_all +decide [ isPolyInverse, polyMapComp, stableLift ];
    · ext i;
      by_cases hi : i.val < n <;> simp_all +decide [ stableLift, polyMapComp ];
      · have h_bind₁_rename : ∀ (p : MvPolynomial (Fin n) k), bind₁ (stableLift G m) (rename (Fin.castAdd m) p) = rename (Fin.castAdd m) (bind₁ G p) := by
          intro p;
          induction p using MvPolynomial.induction_on <;> simp_all +decide [ MvPolynomial.bind₁_X_right ];
          unfold stableLift; aesop;
        have := congr_fun hFG.1 ⟨ i, hi ⟩ ; simp_all +decide [ polyMapComp, polyMapId ] ;
      · split_ifs <;> simp_all +decide [ stableLift, polyMapId ];
        · linarith;
        · grind +splitImp;
    · funext i;
      by_cases hi : i.val < n <;> simp_all +decide [ polyMapComp, stableLift ];
      · convert congr_arg ( fun p => MvPolynomial.rename ( Fin.castAdd m ) p ) ( congr_fun hFG.2 ⟨ i, hi ⟩ ) using 1;
        · unfold polyMapComp;
          unfold stableLift; simp +decide [ Fin.castAdd, Fin.castLE ] ;
          induction' ( G ⟨ i, hi ⟩ ) using MvPolynomial.induction_on with i p q hp hq <;> simp +decide [ *, MvPolynomial.rename_X ];
        · unfold polyMapId; aesop;
      · split_ifs <;> simp_all +decide [ polyMapId, stableLift ];
        grind;
  exact hG

/-! ### Backward direction: invertibility descends -/

/-
If `stableLift F m` is a polynomial automorphism, then so is `F`.
-/
set_option maxHeartbeats 800000 in
theorem isPolyAuto_of_stableLift_isPolyAuto
    (F : PolyMap k n) (hF : isPolyAuto (stableLift F m)) :
    isPolyAuto F := by
  -- By definition of stableLift, we know that if stableLift F m is a polynomial automorphism, then F is also a polynomial automorphism.
  obtain ⟨G, hG⟩ := hF;
  refine' ⟨ fun i => MvPolynomial.bind₁ ( fun j => if hj : j.val < n then MvPolynomial.X ⟨ j.val, hj ⟩ else 0 ) ( G ( Fin.castAdd m i ) ), _, _ ⟩;
  · have h_comp : ∀ i : Fin n, MvPolynomial.bind₁ (fun j => if hj : j.val < n then MvPolynomial.X ⟨j.val, hj⟩ else 0) (MvPolynomial.bind₁ G (stableLift F m (Fin.castAdd m i))) = MvPolynomial.X i := by
      intro i
      have h_comp : MvPolynomial.bind₁ G (stableLift F m (Fin.castAdd m i)) = MvPolynomial.X (Fin.castAdd m i) := by
        exact congr_fun hG.1 ( Fin.castAdd m i );
      aesop;
    convert h_comp using 1;
    unfold polyMapComp polyMapId stableLift; simp +decide [ funext_iff ] ;
    congr! 2;
    induction' ( F ‹_› ) using MvPolynomial.induction_on with i p q hp hq <;> simp +decide [ *, bind₁_rename ];
  · have := congr_fun hG.2;
    ext i specialize this ( Fin.castAdd m i ) ; simp_all +decide [ polyMapComp, polyMapId ] ;
    convert congr_arg ( fun p => coeff specialize ( MvPolynomial.bind₁ ( fun j => if hj : j.val < n then MvPolynomial.X ⟨ j.val, hj ⟩ else 0 ) p ) ) ( this ( Fin.castAdd m i ) ) using 1;
    · congr! 1;
      induction' G ( Fin.castAdd m i ) using MvPolynomial.induction_on with i p q hp hq <;> simp +decide [ *, bind₁_X_right ];
      split_ifs <;> simp_all +decide [ stableLift ];
      · induction' F ⟨ _, ‹_› ⟩ using MvPolynomial.induction_on with i p q hp hq <;> simp +decide [ *, bind₁_X_right ];
        · rw [ mul_add, mul_add, hp, hq ];
        · grind;
      · split_ifs <;> simp_all +decide [ Fin.castAdd ];
        linarith;
    · simp +decide [ Fin.castAdd ]

/-! ### Biconditional -/

/-- **Stable invertibility theorem**: `F` is a polynomial automorphism if and only if
    `stableLift F m` is. -/
theorem isPolyAuto_stableLift_iff (F : PolyMap k n) :
    isPolyAuto F ↔ isPolyAuto (stableLift F m) :=
  ⟨isPolyAuto_stableLift_of_isPolyAuto F, isPolyAuto_of_stableLift_isPolyAuto F⟩

/-! ### Jacobian matrix of stable lift -/

/-
The Jacobian matrix of the stable lift has block structure:
    the (i,j) entry for `i, j < n` comes from the Jacobian of `F` (renamed),
    the diagonal entries for `i ≥ n` are 1, and all off-diagonal cross-blocks are 0.
-/
set_option maxHeartbeats 800000 in
theorem jacobianMatrix_stableLift_entry
    (F : PolyMap k n) (i j : Fin (n + m)) :
    jacobianMatrix (stableLift F m) i j =
      if hi : i.val < n then
        if hj : j.val < n then
          MvPolynomial.rename (Fin.castAdd m)
            (MvPolynomial.pderiv ⟨j.val, hj⟩ (F ⟨i.val, hi⟩))
        else 0
      else if i = j then 1 else 0 := by
  -- By definition of stableLift, we can split into cases based on whether i is less than n or not.
  by_cases hi : i.val < n;
  · by_cases hj : j.val < n <;> simp +decide [ *, jacobianMatrix, stableLift ];
    · grind +suggestions;
    · -- Since $j$ is not in the range of $Fin.castAdd m$, the derivative of the renamed polynomial with respect to $j$ is zero.
      have h_deriv_zero : ∀ (p : MvPolynomial (Fin n) k), (MvPolynomial.pderiv j) (MvPolynomial.rename (Fin.castAdd m) p) = 0 := by
        intro p;
        induction p using MvPolynomial.induction_on <;> simp_all +decide [ MvPolynomial.pderiv_X ];
        grind;
      exact h_deriv_zero _;
  · unfold jacobianMatrix stableLift;
    simp +decide [ hi, MvPolynomial.pderiv_X ];
    grind +splitIndPred

end JacobianConjecture


-- NEW_FILE: Catalog/Algebra/StandardRep.lean
/-
Copyright (c) 2025. All rights reserved.
Character-Theoretic Rigidity: Standard Representation and Decomposition

This file defines the standard representation of `S_n` and proves
that the permutation character decomposes as trivial + standard.
-/
import Mathlib
import Algebra.RepresentationTheory.Symmetric.PermutationRep

open Finset

/-! ## Trivial and Standard Characters

We define characters as functions on the group and establish
the decomposition of the permutation character. -/

/-- The trivial character of a finite group: constantly 1. -/
noncomputable def trivialCharFn (K : Type*) [Field K]
    (G : Type*) [Group G] [Fintype G] : G → K :=
  fun _ => 1

/-- The sign character of `S_n`: maps `σ` to its sign `±1`. -/
noncomputable def signCharFn (K : Type*) [Field K] {n : ℕ} :
    Equiv.Perm (Fin n) → K :=
  fun σ => Equiv.Perm.sign σ

/-- The permutation character: maps `σ` to the number of fixed points. -/
noncomputable def permCharFn (K : Type*) [Field K] {n : ℕ} :
    Equiv.Perm (Fin n) → K :=
  fun σ => ↑(Fintype.card {i : Fin n // σ i = i})

/-- The standard character of `S_n`: `χ_std(σ) = fix(σ) - 1`.
    This corresponds to the `(n-1)`-dimensional irreducible representation. -/
noncomputable def standardCharFn (K : Type*) [Field K
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: The Full Order Type of the p-Degrees

## Synthesis

The order-theoretic core of the Cook–Reckhow program in this catalog has, over successive
cycles, been assembled from the simulation preorder `Simulates` on abstract proof systems
(`Catalog/Logic/ProofComplexity/SimulationPreorder.lean`), the generic separation template
and the antisymmetrized **poset of p-degrees**
(`.../SimulationDegrees.lean`), and the lattice/height results
(`.../DegreeLattice.lean`: binary meets via `sumSystem`, an infinite increasing chain
`powSystem`). This cycle adds the three remaining coordinates needed to talk about the
*order type* of the p-degrees, all in `.../OrderType.lean` and all `sorry`-free:

* **Infinite width.** The 2-adic valuation partitions `ℕ` into infinitely many infinite
  "spike sets"; placing an exponential spike `2^n` on the `i`-th set yields pairwise
  *incomparable* systems `spikeSys i` (`spikeSys_incomparable`), giving an injective
  infinite antichain in the poset (`spikeSys_isAntichain`, `spikeSys_pdegrees_injective`).
* **A least p-degree.** The size-`0` system `zeroSys` simulates *every* proof system over
  `ℕ` (`simulates_zeroSys`), hence is a bottom element (`zeroSys_isBot`), strictly below the
  whole height ladder (`zeroSys_lt_lin`).
* **Density at the Fibonacci separation.** A parity-thinned size function (Fibonacci on the
  evens, linear on the odds) is a degree strictly between `linSystem` and `fibSystem`
  (`exists_strictly_between_lin_fib`).

The unifying engine is the domination characterisation `simulates_sysOfSize_iff`:
simulation between size-indexed systems is *polynomial domination of size functions*. Width,
height, the bottom, and density are all read off as elementary growth-class facts, with the
single analytic input `exp_dominates_poly` (exponential beats polynomial).

## Results Summary

| Result | Statement | File |
| --- | --- | --- |
| `exp_dominates_poly` | `∀ a k, ∃ m, (2m+a)^k < 2^m` | `OrderType.lean` |
| `simulates_zeroSys` / `zeroSys_isBot` | the size-`0` system is a least p-degree | `OrderType.lean` |
| `zeroSys_lt_lin` | the bottom is strictly below `linSystem` | `OrderType.lean` |
| `spikeSys_incomparable` | spike systems are pairwise incomparable | `OrderType.lean` |
| `spikeSys_isAntichain` / `_pdegrees_injective` | an infinite antichain of p-degrees (infinite width) | `OrderType.lean` |
| `exists_incomparable_pair` | the simulation order is not total | `OrderType.lean` |
| `exists_strictly_between_lin_fib` | density witness between `lin` and `fib` | `OrderType.lean` |

Together with the earlier `powSystem_strictMono` (infinite height) and `isGLB_sumSystem`
(binary meets), the poset of p-degrees is now known to be a meet-semilattice of infinite
height and infinite width, with a least element and at least one density witness.

## Research Directions

### 1. Joins fail: the p-degrees are a meet-semilattice but **not** a lattice

We proved binary meets exist (`isGLB_sumSystem`) via the "run 
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
