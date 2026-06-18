
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
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
  ],
  "visualizations": [
    {"name": "descriptive_name", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Interactive Widget Title", "description": "What users can explore", "html": "<!DOCTYPE html><html>...</html>"}
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

**Title**: Close Proofs: Close Proofs: Tropical Compactification of Moduli Spaces
**Domain**: Tropical
**Mathematical framing**: Cycle 484dd4da (Q=0.419) proved 2147 theorems in Tropical but left 4 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Cycle ad2be92e (Q=0.442) proved 750 theorems in Novelty but left 36 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Prove that the tropical 
Research domain: Tropical
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Pythagorean/DiagonalObstruction.lean
import Mathlib

/-!
# Diagonal Obstruction Calculus for Higher-Degree Sums of Powers

This file develops a uniform local obstruction framework for diagonal
hypersurfaces of the form x₁ⁿ + x₂ⁿ + ⋯ + xₛⁿ = k.

The theory generalizes the three-cubes local admissibility machinery
to arbitrary degree n ≥ 1 and variable count s ≥ 1, providing:
- A definition of local admissibility modulo m
- A proof that global representability implies local admissibility
- Monotonicity of admissibility along divisibility
- Universal surjectivity and its consequences
- Symmetry under multiplication by n-th powers of units

## Main Definitions

* `DiagonalLocalAdmissible` — k is a sum of s n-th powers mod m
* `EverywhereLocallyAdmissible` — local admissibility at every modulus
* `UniversallySurjectiveMod` — every residue is a sum of s n-th powers mod m

## Main Results

* `global_represents_implies_local_admissible` — global ⟹ local
* `local_admissible_of_dvd` — admissibility descends along divisibility
* `universally_surjective_implies_all_locally_admissible` — surjectivity ⟹ completeness
* `diagonal_residue_sums_unit_power_invariant` — symmetry under n-th power units
* `mem_computeDiagonalResidueSums_iff` — correctness of the computational algorithm
-/

open Finset

/-! ## Core Definitions -/

/-- An integer `k` is locally admissible for the diagonal equation
x₁ⁿ + ⋯ + xₛⁿ = k modulo `m`: there exist residues whose n-th
powers sum to k mod m. -/
def DiagonalLocalAdmissible (n s : ℕ) (k : ℤ) (m : ℕ) : Prop :=
  ∃ x : Fin s → ZMod m, (∑ i, x i ^ n) = (k : ZMod m)

/-- An integer `k` is everywhere locally admissible for degree `n`
and `s` variables: it is locally admissible at every positive modulus. -/
def EverywhereLocallyAdmissible (n s : ℕ) (k : ℤ) : Prop :=
  ∀ m : ℕ, m > 0 → DiagonalLocalAdmissible n s k m

/-- A modulus `m` is universally surjective for degree `n` and `s` variables:
every residue class mod m is a sum of s n-th powers. -/
def UniversallySurjectiveMod (n s m : ℕ) : Prop :=
  ∀ a : ZMod m, ∃ x : Fin s → ZMod m, a = ∑ i, x i ^ n

/-- Global representability: k equals a sum of s n-th powers over ℤ. -/
def DiagonalGlobalRep (n s : ℕ) (k : ℤ) : Prop :=
  ∃ x : Fin s → ℤ, (∑ i, x i ^ n) = k

/-! ## Theorem 1: Global representability implies local admissibility -/

/-
**Global-to-local principle for diagonal forms.**
If k is globally representable as a sum of s n-th powers over ℤ,
then k is locally admissible modulo every positive modulus m.
This is the foundational backbone theorem of the obstruction calculus.
-/
theorem global_represents_implies_local_admissible
    (n s : ℕ) (k : ℤ) (m : ℕ) (_hm : 0 < m)
    (hrep : DiagonalGlobalRep n s k) :
    DiagonalLocalAdmissible n s k m := by
  obtain ⟨x, hx⟩ : ∃ x : Fin s → ℤ, ∑ i, x i ^ n = k := hrep;
  exact ⟨ fun i => x i, by simpa [ ← ZMod.intCast_eq_intCast_iff ] using congr_arg ( ( ↑ ) : ℤ → ZMod m ) hx ⟩

/-
Corollary: global representability implies everywhere local admissibility.
-/
theorem global_rep_implies_everywhere_local
    (n s : ℕ) (k : ℤ)
    (hrep : DiagonalGlobalRep n s k) :
    EverywhereLocallyAdmissible n s k := by
  exact fun m hm => global_represents_implies_local_admissible n s k m hm hrep

/-! ## Theorem 2: Monotonicity along divisibility -/

/-
**Divisibility descent for local admissibility.**
If m divides M, then admissibility modulo M implies admissibility modulo m.
This captures the fact that obstruction information flows downward through
quotient maps, justifying computational focus on prime powers.
-/
theorem local_admissible_of_dvd
    (n s : ℕ) (k : ℤ) (m M : ℕ)
    (_hm : 0 < m) (hM : 0 < M)
    (hdiv : m ∣ M) :
    DiagonalLocalAdmissible n s k M →
    DiagonalLocalAdmissible n s k m := by
  rintro ⟨ x, hx ⟩;
  use fun i => (ZMod.castHom hdiv (ZMod m)) (x i);
  convert congr_arg ( ZMod.castHom hdiv ( ZMod m ) ) hx using 1 ; simp +decide [ map_sum, map_pow ];
  cases M <;> aesop

/-! ## Theorem 3: Universal surjectivity implies all locally admissible -/

/-
**Surjectivity completeness theorem.**
If every residue class modulo m is a sum of s n-th powers,
then every integer is locally admissible modulo m.
-/
theorem universally_surjective_implies_all_locally_admissible
    (n s m : ℕ) (_hm : 0 < m)
    (hsurj : UniversallySurjectiveMod n s m) :
    ∀ k : ℤ, DiagonalLocalAdmissible n s k m := by
  exact fun k => by obtain ⟨ x, hx ⟩ := hsurj k; exact ⟨ x, by simpa [ ← eq_comm ] using hx ⟩ ;

/-! ## Theorem 4: Symmetry under multiplication by n-th powers of units -/

/-
**Unit power symmetry theorem.**
The set of sums of s n-th powers modulo m is invariant under
multiplication by n-th powers of units. This reveals that the
local admissibility set carries multiplicative symmetry from
the unit group of the residue ring.

Cross-domain connection: this bridges additive number theory
(sums of powers) with algebraic number theory (n-th power
residue classes) and finite group theory (unit group actions).
-/
theorem diagonal_residue_sums_unit_power_invariant
    (n s m : ℕ) (_hm : 0 < m)
    (u a : ZMod m) (_ha : IsUnit a) (hu : u = a ^ n)
    (r : ZMod m) (hr : ∃ x : Fin s → ZMod m, r = ∑ i, x i ^ n) :
    ∃ x : Fin s → ZMod m, u * r = ∑ i, x i ^ n := by
  rcases hr with ⟨ x, hx ⟩ ; use fun i => a * x i; simp_all +decide [ Finset.mul_sum _ _ _, mul_pow ] ;

/-! ## Verified computation of diagonal residue sums -/

/-- Compute the set of all sums of s n-th powers modulo m. -/
noncomputable def computeDiagonalResidueSums (n s : ℕ) (m : ℕ) [NeZero m] : Finset (ZMod m) :=
  Finset.univ.image (fun x : Fin s → ZMod m => ∑ i, x i ^ n)

/-
**Correctness of the computational algorithm.**
Membership in the computed set is equivalent to the existential
characterization of local admissibility.
-/
theorem mem_computeDiagonalResidueSums_iff
    (n s m : ℕ) [NeZero m] (k : ZMod m) :
    k ∈ computeDiagonalResidueSums n s m ↔
    ∃ x : Fin s → ZMod m, (∑ i, x i ^ n) = k := by
  unfold computeDiagonalResidueSums; aesop;

/-! ## Coprime product surjectivity (CRT-based) -/

/-
**CRT surjectivity composition.**
If m₁ and m₂ are coprime and both universally surjective,
then their product is universally surjective. This reduces
obstruction search to prime powers.
-/
theorem universally_surjective_mul_of_coprime
    (n s m₁ m₂ : ℕ)
    (_hm₁ : 0 < m₁) (_hm₂ : 0 < m₂)
    (hcop : Nat.Coprime m₁ m₂)
    (h₁ : UniversallySurjectiveMod n s m₁)
    (h₂ : UniversallySurjectiveMod n s m₂) :
    UniversallySurjectiveMod n s (m₁ * m₂) := by
  intro a;
  -- By the Chinese Remainder Theorem, there exist unique $a₁ \in \mathbb{Z}/m₁$ and $a₂ \in \mathbb{Z}/m₂$ such that $a \equiv a₁ \pmod{m₁}$ and $a \equiv a₂ \pmod{m₂}$.
  obtain ⟨a₁, a₂, ha₁, ha₂⟩ : ∃ a₁ : ZMod m₁, ∃ a₂ : ZMod m₂, a = (ZMod.chineseRemainder hcop).symm (a₁, a₂) := by
    exact ⟨ _, _, Eq.symm <| RingEquiv.apply_symm_apply _ _ ⟩;
  obtain ⟨ x₁, hx₁ ⟩ := h₁ a₁; obtain ⟨ x₂, hx₂ ⟩ := h₂ a₂; use fun i => ( ZMod.chineseRemainder hcop ).symm ( x₁ i, x₂ i ) ; simp_all +decide [ ← map_sum, ← map_pow ] ;
  simp +decide [ Prod.ext_iff ];
  simp +decide [ Prod.fst_sum, Prod.snd_sum ]


-- NEW_FILE: Catalog/Pythagorean/EntanglementCompression.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Entanglement Compression via Elementary Symmetric Coordinates

This file establishes a rigorous algebraic framework for compressed sensing of
spectral entanglement data. The central insight: if the elementary symmetric
polynomial coefficients of a spectrum decay geometrically, then entropy admits
certified logarithmic-complexity reconstruction.

## Main Definitions

* `esymm` — the k-th elementary symmetric polynomial of a finite sequence
* `ESymmExponentiallyCompressible` — exponential decay of esymm coefficients
* `vonNeumannEntropy` — the Shannon/von Neumann entropy of a spectrum
* `genPolyEval` — the generating polynomial ∏(1 + pᵢt) evaluated at a point

```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Tropical Compactification of Moduli Spaces

The file `Catalog/Tropical/TropicalModuliCompactification.lean` formalizes the
combinatorial core of the tropical moduli space of genus-0 curves
`M_{0,n}^trop`, realized as the space of phylogenetic trees and, equivalently,
the tropical Grassmannian `Gr(2,n)`. We proved that ultrametrics (the
equidistant / rooted locus) are isosceles, are genuine metrics, and satisfy the
four-point / tropical Plücker condition (`ultrametric_four_point` and its
"attained-twice" strengthening), together with max-plus homogeneity
(`tropical_homogeneity`) that gives the moduli object its fan/cone structure.

These results connect to existing catalog material: the min-plus monotonicity of
`Catalog/Tropical/TropicalFormula.lean` (`TropFormula`) is the order-theoretic
companion of `tropical_homogeneity`, and the Plücker-style certificates in
`Catalog/Bridges/TropicalProofCertificates` and `AlgebraTropicalGeometry` are
candidate consumers of the four-point relation proved here. Below are concrete,
falsifiable next steps.

## Direction 1 — A full Buneman recovery theorem (metric ⇒ tree)

Conjecture: a symmetric nonnegative `d : ι → ι → ℝ` on a finite type satisfies
the four-point condition `ultrametric_four_point_attained_twice` for *every*
quadruple **if and only if** there is a weighted tree (a finite graph metric)
realizing `d` exactly. The forward direction generalizes our `ultrametric_*`
lemmas from the equidistant locus to all tree metrics; the converse is the
constructive heart of `M_{0,n}^trop`.

The key insight is that the four-point condition is not merely *necessary* for an
ultrametric — it is the exact tropical Plücker locus, so the "attained-twice"
disjunction we proved is precisely the gluing data of the Buneman split system,
and a tree can be reconstructed split-by-split from the equality cases.

Why now? We have already isolated the attained-twice relation as a clean,
machine-checked disjunction; the remaining work is a finite induction on the
number of leaves, which is exactly the regime where Lean's `Finset` and
`grind`-style case analysis are now strong enough to discharge the splits.

## Direction 2 — The tropical Grassmannian `Gr(2,n)` as a balanced fan

Conjecture: the set of `d` satisfying `ultrametric_four_point` is closed under
the max-plus cone operations (tropical scaling by nonnegative `c` and tropical
addition), i.e. it is a *tropical (max-plus) submodule*, and modulo the lineality
space of "tree-additive" functions it is a balanced polyhedral fan of pure
dimension `n - 3`.

The key insight is that `tropical_homogeneity` already certifies closure under
scaling, so the only missing ingredient is closure under coordinatewise `max`,
which reduces to a *single* three-term inequality between quartet sums — the same
shape of statement `grind +splitIndPred` dispatched for the four-point lemma.

Why now? The dimension `n-3` is the classical statement of Speyer–Sturmfels;
having the defin
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
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
