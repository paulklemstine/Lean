/-
# Eichler–Shimura and the local Frobenius data for GL₂ over ℚ

This file formalizes the **arithmetic skeleton of the GL₂ Langlands correspondence over `ℚ`**:
the way a weight-`2` Hecke eigenform `f` produces, at each good prime `p`, a `2`-dimensional
local Frobenius datum.  The classical dictionary is:

* the Hecke eigenvalue `a_p = a` of `f` is the **trace** of `Frob_p`;
* the prime `p` (the value of the cyclotomic character) is the **determinant** of `Frob_p`;
* the **characteristic polynomial** of `Frob_p` is the *Hecke polynomial* `X² − a·X + p`;
* the **Euler factor** of the `L`-function at `p` is `(1 − a·X + p·X²)⁻¹`;
* `Frob_p` satisfies the **Eichler–Shimura congruence relation**
  `Frob_p² − a·Frob_p + p = 0`, the rank-2 Cayley–Hamilton identity. Geometrically this is
  the relation `T_p ≡ Frob + ⟨p⟩·Frob∨ (mod p)` on the reduction of the modular curve.

These statements are exactly the GL₂ analogues of the GL₁ (cyclotomic) data already in the
catalog (`Catalog.NumberTheory.GL1Correspondence`, `Catalog.NumberTheory.Langlands.HeckeFactorization`):
there the Frobenius datum is a single unit (a Dirichlet character value); here it is a `2 × 2`
matrix, and the new content is the *quadratic* relation tying trace, determinant and Frobenius.

Main results:

* `EichlerShimuraGL2.heckePoly` — the Hecke / Frobenius characteristic polynomial `X² − a·X + b`.
* `EichlerShimuraGL2.eichlerShimura` — the Eichler–Shimura congruence relation as the rank-2
  Cayley–Hamilton identity `M·M = (tr M)·M − (det M)·1`.
* `EichlerShimuraGL2.heckePoly_factor` — Vieta: `heckePoly a b = (X − α)(X − β)` for eigenvalues
  `α, β` with `α + β = a`, `αβ = b`.
* `EichlerShimuraGL2.eulerFactor_factor` — the local Euler factor factors as
  `1 − a·X + b·X² = (1 − α·X)(1 − β·X)`.
* `EichlerShimuraGL2.frobMatrix` — the companion matrix realizing a Frobenius with prescribed
  trace `a` and determinant `p`, together with `frobMatrix_trace`, `frobMatrix_det`, and the
  Eichler–Shimura relation `frobMatrix_eichlerShimura`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the GL(1) correspondence in the catalog packages the local datum
of a Hecke character as a single unit (trace = determinant).  The bold GL₂ jump is that the
local datum becomes a genuine `2 × 2` matrix, and the *one new equation* governing it — beyond
"trace = a_p, det = p" — is the Eichler–Shimura congruence `Frob² = a·Frob − p`.  Conjecture:
this is not an extra axiom but a *theorem*, namely rank-2 Cayley–Hamilton, hence provable
unconditionally and uniformly in any commutative ring of coefficients.

Experiment (Experimenter): we avoid the heavy `Matrix.charpoly` / `aeval_self_charpoly`
machinery and instead prove the identity entrywise via `fin_cases` + `Matrix.mul_apply`,
`Matrix.trace_fin_two`, `Matrix.det_fin_two` and `ring`.  The companion matrix `!![0,-p;1,a]`
is then checked to have trace `a`, determinant `p`, and to satisfy the relation by specialization.
Vieta and the Euler-factor factorization are pure `ring` identities after `C_add`/`C_mul`.

Analysis (Analyst): the relation `M² = (tr M)M − (det M)·1` is the precise finite shadow of
"`Frob_p` has characteristic polynomial `X² − a_p X + p`"; it holds for *every* `2 × 2` matrix,
so the arithmetic input of Eichler–Shimura is the *identification* of `tr` with `a_p` and `det`
with `p`, not the algebraic relation itself.  The companion matrix shows the datum is realizable:
for any `(a, p)` there is a concrete Frobenius with that trace and determinant.

Critique (Critic): is `eichlerShimura` trivial?  No — it is the rank-2 Cayley–Hamilton theorem,
proved by an honest entrywise computation, not `rfl`/`decide`.  Is the companion matrix a wrapper?
No — it supplies the *existence* half (realizability of arbitrary local data) and feeds the
Deligne-bound file, where its eigenvalues are shown to be Weil numbers.  Corner cases: the
identities hold over any `CommRing`, including characteristic `p` (where Eichler–Shimura is
usually stated), so nothing is lost at bad reduction.

Synthesis (PI): the local GL₂ Frobenius datum is formalized as a `2 × 2` matrix constrained by
Cayley–Hamilton, with trace/determinant carrying the Hecke eigenvalue and the cyclotomic value.
This is the algebraic half of the correspondence; the analytic half (Deligne's Weil bound) is in
`Catalog.Novelty.DeligneBoundGL2`, which imports this file.
-/
import Mathlib

open Polynomial Matrix

namespace EichlerShimuraGL2

/-- The Hecke / Frobenius characteristic polynomial `X² − a·X + b`.
For a weight-2 eigenform, `a` is the Hecke eigenvalue `a_p` and `b` is the prime `p`. -/
noncomputable def heckePoly {R : Type*} [CommRing R] (a b : R) : R[X] := X ^ 2 - C a * X + C b

@[simp] lemma heckePoly_eval {R : Type*} [CommRing R] (a b r : R) :
    (heckePoly a b).eval r = r ^ 2 - a * r + b := by
  simp [heckePoly]

/-- **Eichler–Shimura congruence relation** (rank-2 Cayley–Hamilton):
`Frob² = T·Frob − p`, where the Hecke operator `T` is the trace and `p` the determinant. -/
theorem eichlerShimura {R : Type*} [CommRing R] (M : Matrix (Fin 2) (Fin 2) R) :
    M * M = (Matrix.trace M) • M - (Matrix.det M) • (1 : Matrix (Fin 2) (Fin 2) R) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Matrix.mul_apply, Fin.sum_univ_two, Matrix.trace_fin_two, Matrix.det_fin_two] <;> ring

/-- Vieta: the Hecke polynomial factors through its Frobenius eigenvalues `α, β`. -/
theorem heckePoly_factor {R : Type*} [CommRing R] (a b α β : R)
    (hs : α + β = a) (hp : α * β = b) :
    heckePoly a b = (X - C α) * (X - C β) := by
  subst hs hp; simp only [heckePoly, C_add, C_mul]; ring

/-- The local Euler factor `1 − a·X + b·X²` factors through the Frobenius eigenvalues. -/
theorem eulerFactor_factor {R : Type*} [CommRing R] (a b α β : R)
    (hs : α + β = a) (hp : α * β = b) :
    (1 - C a * X + C b * X ^ 2 : R[X]) = (1 - C α * X) * (1 - C β * X) := by
  subst hs hp; simp only [C_add, C_mul]; ring

/-- The **Frobenius companion matrix** with trace `a` and determinant `p`:
a concrete realization of the local Frobenius datum. -/
def frobMatrix {R : Type*} [CommRing R] (a p : R) : Matrix (Fin 2) (Fin 2) R :=
  !![0, -p; 1, a]

@[simp] lemma frobMatrix_trace {R : Type*} [CommRing R] (a p : R) :
    Matrix.trace (frobMatrix a p) = a := by simp [frobMatrix, Matrix.trace_fin_two]

@[simp] lemma frobMatrix_det {R : Type*} [CommRing R] (a p : R) :
    Matrix.det (frobMatrix a p) = p := by simp [frobMatrix, Matrix.det_fin_two]

/-- Eichler–Shimura for the Frobenius companion matrix: `Frob² = a·Frob − p·1`. -/
theorem frobMatrix_eichlerShimura {R : Type*} [CommRing R] (a p : R) :
    (frobMatrix a p) * (frobMatrix a p)
      = a • frobMatrix a p - p • (1 : Matrix (Fin 2) (Fin 2) R) := by
  have h := eichlerShimura (frobMatrix a p)
  rwa [frobMatrix_trace, frobMatrix_det] at h

end EichlerShimuraGL2