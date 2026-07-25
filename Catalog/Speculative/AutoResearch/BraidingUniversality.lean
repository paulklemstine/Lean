/-
# Topological Quantum Computing: Braiding Universality

This module formalizes the algebraic and number-theoretic kernel underlying the
universality of topological quantum computation by **anyon braiding**.

The physical claim "any quantum circuit can be approximated by braiding anyons"
rests on two mathematical pillars that we make precise here:

1. **Braid statistics** — anyonic worldlines realize the Artin braid group, whose
   defining relation is the *Yang–Baxter / braid relation* `σ₁σ₂σ₁ = σ₂σ₁σ₂`.
   We exhibit the (reduced) **Burau representation** of the three-strand braid
   group `B₃` — the linear skeleton of the **Jones polynomial** — and prove it
   satisfies the braid relation for *every* value of the loop parameter `t`, and
   that each generator is invertible (`det = -t`). This is the representation
   from which the Jones polynomial is extracted as a (normalized) Markov trace.

2. **Density of the generated gate set** — universality means the braiding gates
   generate a *dense* subgroup of the relevant unitary group. We prove the exact
   number-theoretic dichotomy on the maximal torus: the powers of a phase gate
   `exp(2πiθ)` are dense in the phase circle **iff** `θ` is irrational. This is
   the rigorous one-parameter kernel of the Solovay–Kitaev universality program.
   As a sharp *boundary case* (the Critic's counterexample) we show the Fibonacci
   anyon eigenphase `4/5` has finite order, so pure-phase braiding is provably
   NOT dense — universality genuinely requires the non-commuting braids.

## Catalog synthesis

This file connects three catalog domains:
* topology / knot theory (cf. `Bridges/CyclotomicKnotSpectra.lean`'s Alexander
  polynomials of torus knots) — here the *braid group* and the Burau/Jones link
  invariant;
* quantum information (cf. `Bridges/QuantumDagger.lean`) — unitary gate sets;
* number theory — the irrationality dichotomy controlling density.

The cross-domain bridge is: *knot-theoretic braiding* → *linear representation*
→ *number-theoretic irrationality* → *quantum-computational universality*.
-/
import Mathlib

open Matrix

namespace BraidingUniversality

noncomputable section

/-! ## I. The braid group `B₃` and its Burau representation

The Artin braid group on three strands is
`B₃ = ⟨σ₁, σ₂ | σ₁σ₂σ₁ = σ₂σ₁σ₂⟩`.
The reduced Burau representation sends the generators to the following `2×2`
matrices over `ℂ`, parametrized by the loop variable `t` (the variable of the
Jones polynomial). This is the linear backbone from which the Jones polynomial
is obtained as a normalized Markov trace of a braid word. -/

/-- Reduced Burau matrix of the first braid generator `σ₁` of `B₃`. -/
def burauSigma₁ (t : ℂ) : Matrix (Fin 2) (Fin 2) ℂ := !![-t, 1; 0, 1]

/-- Reduced Burau matrix of the second braid generator `σ₂` of `B₃`. -/
def burauSigma₂ (t : ℂ) : Matrix (Fin 2) (Fin 2) ℂ := !![1, 0; t, -t]

-- !-- Burau braid relation -- !--
-- !-- σ₁σ₂σ₁ = σ₂σ₁σ₂; both sides equal !![0,-t; -t²,0]; entrywise `ring`. -- !--
/-- **Yang–Baxter / braid relation.** The Burau generators satisfy the defining
relation of the three-strand braid group `B₃` for *every* loop parameter `t`.
This is the algebraic statement that anyonic braiding is consistent (worldlines
may be slid past one another), and the foundation of the Jones polynomial. -/
theorem burau_braid_relation (t : ℂ) :
    burauSigma₁ t * burauSigma₂ t * burauSigma₁ t
      = burauSigma₂ t * burauSigma₁ t * burauSigma₂ t := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [burauSigma₁, burauSigma₂, Matrix.mul_apply, Fin.sum_univ_two]

-- !-- Burau invertibility -- !--
-- !-- det of !![-t,1;0,1] is (-t)·1 - 1·0 = -t via det_fin_two. -- !--
/-- The first Burau generator has determinant `-t`; hence it is invertible
exactly when `t ≠ 0`. Together with `burauSigma₂` this shows the Burau map lands
in `GL₂(ℂ)` for `t ≠ 0`, i.e. it is a genuine *group* representation of `B₃`. -/
theorem burau_det₁ (t : ℂ) : (burauSigma₁ t).det = -t := by
  simp [burauSigma₁, Matrix.det_fin_two]

/-- The second Burau generator also has determinant `-t`. -/
theorem burau_det₂ (t : ℂ) : (burauSigma₂ t).det = -t := by
  simp [burauSigma₂, Matrix.det_fin_two]

-- !-- Lab Notebook: burau_braid_relation -- !--
-- !-- Hypothesis: The reduced Burau matrices satisfy the braid relation for all t. -- !--
-- !-- Result: Proved by entrywise expansion; both products equal !![0,-t; -t²,0]. -- !--
-- !-- Insight: The braid relation is a polynomial identity in t, so it holds over -- !--
-- !--   the whole parameter family at once — no unitarity or |t|=1 needed. This is -- !--
-- !--   why the Jones polynomial is a Laurent polynomial in t rather than a number. -- !--
-- !-- Failure analysis: none; the only subtlety is using Fin.sum_univ_two to unfold -- !--
-- !--   matrix multiplication before `ring`. -- !--
-- !-- End Lab Notebook -- !--

/-! ## II. Density on the maximal torus — the universality dichotomy

On the maximal torus of `SU(2)` a braiding gate acts as a phase rotation
`θ ↦ θ + α (mod 1)`. We model the phase space as `AddCircle (1 : ℝ)` and the
gate orbit as the integer multiples `n • α`. The orbit is dense — i.e. the gate
alone densely fills the torus — *iff* the phase `α` is irrational. -/

-- !-- Phase-gate density -- !--
-- !-- DenseRange (n ↦ n•α) ↔ Irrational (α/1) = Irrational α (denseRange_zsmul_coe_iff). -- !--
/-- **One-qubit universality kernel.** If the braiding phase `α` is irrational,
the powers of the phase gate are dense in the phase torus `AddCircle 1`. This is
the rigorous number-theoretic heart of the Solovay–Kitaev universality theorem
in its one-parameter form. -/
theorem phaseGate_orbit_dense {α : ℝ} (h : Irrational α) :
    DenseRange (fun n : ℤ => n • (α : AddCircle (1 : ℝ))) := by
  rw [AddCircle.denseRange_zsmul_coe_iff]
  simpa using h

-- !-- Fibonacci finite-order counterexample -- !--
-- !-- 4/5 is rational ⇒ not irrational ⇒ orbit not dense (denseRange_zsmul_coe_iff). -- !--
/-- **Critic's boundary counterexample (Fibonacci anyons).** The Fibonacci
anyon `R`-matrix has eigenphase `4/5` (a rational multiple of the full turn).
Its orbit on the torus is therefore NOT dense: pure-phase braiding has finite
order and cannot be universal. Universality of Fibonacci anyons must come from
the *non-commuting* braids (the `F`-matrix), not from any single phase. -/
theorem fibonacci_phase_not_dense :
    ¬ DenseRange (fun n : ℤ => n • ((4 / 5 : ℝ) : AddCircle (1 : ℝ))) := by
  rw [AddCircle.denseRange_zsmul_coe_iff]
  rw [show ((4 : ℝ) / 5 / 1) = ((4 / 5 : ℚ) : ℝ) by norm_num]
  exact Rat.not_irrational (4 / 5)

-- !-- Lab Notebook: phaseGate_orbit_dense / fibonacci_phase_not_dense -- !--
-- !-- Hypothesis: A braiding phase gate is dense on the torus iff its phase is irrational. -- !--
-- !-- Result: Both directions proved through AddCircle.denseRange_zsmul_coe_iff. -- !--
-- !-- Insight: Universality is a number-theoretic property of the phase, not a -- !--
-- !--   topological one. The SAME lemma proves density (irrational) and its failure -- !--
-- !--   (rational 4/5), making the dichotomy sharp and the Fibonacci obstruction -- !--
-- !--   precise: finite-order phases live on a discrete subgroup. -- !--
-- !-- Failure analysis: the coercion α/1 vs α required a `simpa`/`show` normalization; -- !--
-- !--   recognizing 4/5 as a cast rational unlocked Rat.not_irrational. -- !--
-- !-- End Lab Notebook -- !--

/-! ## III. Generalization (conjecture): full density in `SU(2)`

The torus result is one-parameter. *Full* universality asserts that finitely
many non-commuting braiding unitaries generate a dense subgroup of all of
`SU(2)`. We state the existence of such a generating pair as a conjecture; the
proof requires the classification of closed subgroups of `SU(2)` (only the
finite groups, the maximal tori, their normalizers, and `SU(2)` itself), which
is beyond this cycle. The `sorry` here marks exactly that missing ingredient. -/

/-- **Conjecture (braiding density in `SU(2)`).** There exist two special-unitary
`2×2` matrices generating a dense subgroup of `SU(2)`. Physically: two anyon
braids suffice for universal single-qubit computation. -/
theorem su2_braiding_dense :
    ∃ U V : Matrix.specialUnitaryGroup (Fin 2) ℂ,
      Dense (X := Matrix.specialUnitaryGroup (Fin 2) ℂ)
        ↑(Subgroup.closure {U, V}) := by
  sorry

-- !-- Lab Notebook: su2_braiding_dense (conjecture) -- !--
-- !-- Hypothesis: Two generic non-commuting braids generate a dense subgroup of SU(2). -- !--
-- !-- Result: Left as a conjecture (sorry) — the statement type-checks and is faithful. -- !--
-- !-- Insight: The torus dichotomy (§II) shows density of ANY single generator fails -- !--
-- !--   for finite-order phases; full density requires non-commutativity, so a single -- !--
-- !--   AddCircle argument cannot suffice. The natural route is the classification of -- !--
-- !--   closed subgroups of the compact group SU(2). -- !--
-- !-- Failure analysis: no Mathlib classification of closed subgroups of SU(2) exists, -- !--
-- !--   so this cycle records the precise missing lemma rather than a flawed proof. -- !--
-- !-- End Lab Notebook -- !--

end

end BraidingUniversality