/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Tropical.MinPlusAlgebra
import Tropical.TropicalMatrixPower
import Tropical.TropicalMagnitudeLeak

/-!
# Global-Min Superadditivity: the Fekete Seed of the Tropical Min Spectral Radius

This file isolates a single scalar invariant of a tropical matrix — its **global minimum
entry** `gmin A = min_{i,j} A_{ij}` — and shows it is **superadditive** under the tropical
(min-plus) product:

  `gmin A + gmin B ≤ gmin (A ⊗ B)`,

hence under tropical powers `gmin (A^{⊗a}) + gmin (A^{⊗b}) ≤ gmin (A^{⊗(a+b)})`.

By Fekete's subadditive lemma this is exactly the structural input that forces the limit
`lim_m gmin(A^{⊗m}) / m` to exist; that limit is the **tropical (min) spectral radius**,
i.e. the minimum cycle mean of the weighted digraph of `A`.  Cryptanalytically, `gmin` is a
single, cheaply computable, *monotonically growing* functional of the public key that
lower-bounds the secret exponent (`(k+1)·gmin A ≤ gmin (A^{⊗(k+1)})`) — a coarse but
unconditional companion to the entrywise magnitude leak of
`Tropical.TropicalMagnitudeLeak`.

## Main results

* `gmin_le` / `le_gmin` — `gmin` is the greatest entrywise lower bound.
* `gmin_tropMatMul_superadd` — **superadditivity** under the tropical product.
* `gmin_tropMatPow_superadd` — superadditivity under tropical powers (`a + b + 1`).
* `gmin_tropMatPow_double` — the doubling inequality `gmin(A^{⊗(2k+1)}) ≥ 2·gmin(A^{⊗k})`,
  the invariant tracked by repeated tropical squaring.
* `gmin_tropMatPow_lower` — the linear lower bound `(k+1)·gmin A ≤ gmin (A^{⊗(k+1)})`.

Bridge: connects Tropical Algebra to Ergodic/Spectral Theory (minimum cycle mean) and to
Cryptanalysis (a monotone exponent witness).
-/

noncomputable section

open Finset Matrix
open TropicalPower

namespace TropicalGmin

variable {n : ℕ} [NeZero n]

/-- The **global minimum entry** of a tropical matrix.  For a weighted digraph this is the
lightest single edge weight; iterated, its growth rate is the minimum cycle mean. -/
def gmin (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty (fun p : Fin n × Fin n => A p.1 p.2)

/-
`gmin A` is an entrywise lower bound.
-/
theorem gmin_le (A : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) : gmin A ≤ A i j := by
  exact Finset.inf'_le _ ( Finset.mem_univ ( i, j ) )

/-
`gmin A` is the *greatest* entrywise lower bound.
-/
theorem le_gmin (A : Matrix (Fin n) (Fin n) ℝ) (c : ℝ) (h : ∀ i j, c ≤ A i j) :
    c ≤ gmin A := by
  convert Finset.le_inf' _ _ _ ; aesop

/-
**Superadditivity of `gmin` under the tropical product.**  Every entry of `A ⊗ B`
is a sum `A_{ik} + B_{kj} ≥ gmin A + gmin B`, so the whole product is bounded below by
`gmin A + gmin B`.
-/
theorem gmin_tropMatMul_superadd (A B : Matrix (Fin n) (Fin n) ℝ) :
    gmin A + gmin B ≤ gmin (tropMatMul A B) := by
  refine' le_gmin _ _ _;
  intro i j; exact (by
  exact Finset.le_inf' _ _ fun k _ => add_le_add ( gmin_le A i k ) ( gmin_le B k j ))

/-
**Superadditivity under tropical powers.**  Using power multiplicativity
`A^{⊗(a+1)} ⊗ A^{⊗(b+1)} = A^{⊗(a+b+2)}` (`tropMatMul_tropMatPow_add`), the global min is
superadditive along the exponent.
-/
theorem gmin_tropMatPow_superadd (A : Matrix (Fin n) (Fin n) ℝ) (a b : ℕ) :
    gmin (tropMatPow A a) + gmin (tropMatPow A b) ≤ gmin (tropMatPow A (a + b + 1)) := by
  -- By TropicalPower.tropMatMul_tropMatPow_add, tropMatMul (tropMatPow A a) (tropMatPow A b) = tropMatPow A (a + b + 1).
  have h_mul : tropMatMul (tropMatPow A a) (tropMatPow A b) = tropMatPow A (a + b + 1) :=
    tropMatMul_tropMatPow_add A a b
  exact h_mul ▸ gmin_tropMatMul_superadd _ _

/-
**Doubling inequality.**  Specializing superadditivity to `a = b = k` gives the
inequality tracked by one step of repeated tropical squaring:
`2·gmin(A^{⊗(k+1)}) ≤ gmin(A^{⊗(2k+2)})`.
-/
theorem gmin_tropMatPow_double (A : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) :
    2 * gmin (tropMatPow A k) ≤ gmin (tropMatPow A (2 * k + 1)) := by
  rw [ two_mul ];
  convert gmin_tropMatPow_superadd A k k using 1 ; ring

/-
**Linear lower bound.**  The global min of the public power grows at least linearly in
the secret exponent: `(k+1)·gmin A ≤ gmin (A^{⊗(k+1)})`.  This is the `gmin`-shadow of the
entrywise sandwich `Tropical.TropicalMagnitudeLeak.tropMatPow_entry_lower`.
-/
theorem gmin_tropMatPow_lower (A : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) :
    (k + 1 : ℝ) * gmin A ≤ gmin (tropMatPow A k) := by
  refine' le_gmin _ _ _;
  exact fun i j => TropicalMagnitude.tropMatPow_entry_lower A ( gmin A ) ( fun i j => gmin_le A i j ) k i j

end TropicalGmin

end

/-!
-- !-- Lab Notes -- !--

## Hypothesis (Hypothesizer)
Conjectures about a single scalar invariant of the public key:
1. (bold) The global minimum entry `gmin` is *superadditive* under the tropical product,
   `gmin A + gmin B ≤ gmin (A ⊗ B)`.  [Headline: this is the Fekete seed of the tropical
   min spectral radius / minimum cycle mean.]
2. Superadditivity transports to powers, `gmin(A^{⊗a}) + gmin(A^{⊗b}) ≤ gmin(A^{⊗(a+b)})`.
3. Hence `gmin(A^{⊗(k+1)}) ≥ (k+1)·gmin A`: a monotone, cheap, unconditional lower bound on
   the secret exponent.
4. The doubling form `gmin(A^{⊗(2k+1)}) ≥ 2·gmin(A^{⊗k})` is the invariant that grows under
   repeated tropical squaring (the very algorithm used to build the public key).

## Experiment (Experimenter)
- `gmin_le` / `le_gmin` via `Finset.inf'_le` / `Finset.le_inf'`.
- `gmin_tropMatMul_superadd`: each entry of `A ⊗ B` is `≥ gmin A + gmin B` (an `inf'` of
  sums of two entries, each bounded by `gmin_le`); then `le_gmin`.
- `gmin_tropMatPow_superadd`: rewrite with `tropMatMul_tropMatPow_add` and apply the
  product superadditivity.
- `gmin_tropMatPow_double`: specialize `a = b = k` (`2*k+1 = k+k+1`).
- `gmin_tropMatPow_lower`: combine `gmin_le` with
  `TropicalMagnitudeLeak.tropMatPow_entry_lower` (amin := gmin A) and `le_gmin`.
- All checked numerically over ℚ first (see `ComputationalEvidence.md`): for
  `A = [[1,3],[3,1]]`, `gmin(A^{⊗(m+1)}) = m+1`, satisfying every inequality (with equality
  on this circulant example, where the minimum cycle mean equals the diagonal weight `1`).

## Analysis (Analyst)
- SURVIVED: superadditivity (product and power), doubling, linear lower bound.
- `gmin` is the lower analogue of the entrywise sandwich, condensed to one number.  Its
  superadditivity is exactly the hypothesis of Fekete's lemma, so the normalized sequence
  `gmin(A^{⊗m})/m` converges — the minimum cycle mean.  We stopped at the inequalities
  (the convergence itself is left as a future direction) because the inequalities already
  give the cryptanalytic content: a monotone exponent witness.
- Failure mode considered: superADDitivity (not subadditivity) is correct because `gmin`
  is a *minimum* and the product *sums* weights along the minimizing walk; a min of sums of
  bounded-below terms is bounded below by the sum of the bounds.  The dual functional
  `gmax` would instead be *subadditive*.

## Critique (Critic) — counterexample mandate
- Counterexample hunt against superadditivity: none.  The inequality direction is forced by
  `gmin (A⊗B) = min_{i,j} min_k (A_{ik}+B_{kj}) ≥ min A + min B`; reversing it would require
  some entry of `A ⊗ B` below `gmin A + gmin B`, impossible since every summand is bounded
  below.  Tested on random ℚ matrices.
- No theorem is trivial: each uses `inf'` order lemmas and a genuine bound transfer, not
  `rfl`/`native_decide`.  `gmin_tropMatPow_lower` chains an induction-proved sandwich with
  the order characterization of `gmin`.

## Synthesis (PI)
The public key carries a one-dimensional, monotonically growing fingerprint of the secret
exponent — the global min — whose growth slope is an intrinsic spectral invariant (the
minimum cycle mean).  Superadditivity guarantees this fingerprint cannot be "hidden" by the
exponentiation: it accumulates additively.  This reinforces the central finding that
tropical exponentiation leaks the exponent through *multiple* homomorphic shadows.
-/