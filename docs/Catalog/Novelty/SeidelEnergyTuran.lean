/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Seidel matrices, spectral moments, and an energy lower bound

The **Seidel matrix** of a finite simple graph `G` on `n` vertices is the real
symmetric matrix `S` with `S i i = 0`, `S i j = -1` when `i` and `j` are adjacent,
and `S i j = +1` when `i ≠ j` are non-adjacent.  Equivalently `S = J - I - 2A`
where `A` is the ordinary adjacency matrix, `J` the all-ones matrix and `I` the
identity.  The **Seidel energy** of `G` is `E_S(G) = ∑ |λ|`, the sum of the
absolute values of the eigenvalues of `S`.

Seidel energy is central to the spectral theory of *two-graphs* and *switching
classes* and appears in the recent work of Tian, Haemers and others on how the
energy responds to local perturbations (e.g. edge deletion in Turán graphs).
This file develops the elementary but load-bearing foundations of that theory:

* `seidel` — the Seidel matrix of a symmetric irreflexive adjacency relation,
  together with its structural facts (`seidel_isSymm`, `seidel_diag`,
  `seidel_offdiag_sq`).
* `seidel_trace` — the first spectral moment vanishes: `tr S = ∑ λ = 0`.
* `seidel_trace_sq` — the second spectral moment is graph-independent:
  `tr (S²) = ∑ λ² = n(n-1)`.  This is the reason the Seidel *spectrum* of every
  `n`-vertex graph lives on the sphere `∑ λ² = n(n-1)` in `ℝⁿ`, and why energy
  comparisons (as in the Turán edge-deletion problem) are subtle: the first two
  moments cannot distinguish two graphs on the same vertex set.
* `energy` and `energy_nonneg` — the Seidel energy of an arbitrary Hermitian
  matrix.
* `sum_sq_eigenvalues` — `∑ λ² = tr(S²)`, the spectral form of the second moment.
* `energy_sq_ge_trace_sq` — the Cauchy–Schwarz inequality `E² ≥ ∑ λ² = tr(S²)`.
* `seidelEnergy_ge_sqrt` — consequently every `n`-vertex graph has Seidel energy
  at least `√(n(n-1))`, a universal lower bound achieved (up to lower order) by
  conference two-graphs.
* `switching_eigenpair_seidel` — Seidel *switching* (conjugation by a `±1`
  diagonal) transports every eigenpair at the same eigenvalue, so the Seidel
  spectrum, and hence the energy, is a switching-class invariant.

This is a **cross-domain bridge**: Graph theory (Seidel/two-graph adjacency,
switching classes, Turán graphs) ⨯ spectral / linear algebra (Hermitian
eigenvalues, trace moments, Cauchy–Schwarz).  It extends the catalog files
`Novelty/SignedGraphSpectralEquality.lean` and `Novelty/SpectralBound.lean` from
the signed-adjacency Δ-bound to the *complete* signed (Seidel) setting.
-/
import Mathlib

open Matrix BigOperators

namespace SeidelEnergy

variable {n r : ℕ}

/-! ## The Seidel matrix -/

/-- The **Seidel matrix** of an adjacency relation `adj` on `Fin n`:
`0` on the diagonal, `-1` on adjacent pairs, `+1` on non-adjacent pairs. -/
def seidel (adj : Fin n → Fin n → Prop) [DecidableRel adj] : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of (fun i j => if i = j then 0 else if adj i j then -1 else 1)

@[simp] lemma seidel_apply (adj : Fin n → Fin n → Prop) [DecidableRel adj] (i j : Fin n) :
    seidel adj i j = if i = j then 0 else if adj i j then -1 else 1 := rfl

/-- The Seidel matrix has zero diagonal. -/
@[simp] lemma seidel_diag (adj : Fin n → Fin n → Prop) [DecidableRel adj] (i : Fin n) :
    seidel adj i i = 0 := by simp [seidel]

/-
The Seidel matrix is symmetric when the adjacency relation is symmetric.
-/
theorem seidel_isSymm (adj : Fin n → Fin n → Prop) [DecidableRel adj]
    (hsymm : ∀ i j, adj i j ↔ adj j i) : (seidel adj).IsSymm := by
  exact Matrix.ext fun i j => by unfold seidel; aesop;

/-
The Seidel matrix is Hermitian (over `ℝ`, symmetric) for a symmetric relation.
-/
theorem seidel_isHermitian (adj : Fin n → Fin n → Prop) [DecidableRel adj]
    (hsymm : ∀ i j, adj i j ↔ adj j i) : (seidel adj).IsHermitian := by
  ext i j; simp [Matrix.conjTranspose]
  grind +revert

/-
Every off-diagonal Seidel entry squares to `1`.
-/
lemma seidel_offdiag_sq (adj : Fin n → Fin n → Prop) [DecidableRel adj]
    {i j : Fin n} (h : i ≠ j) : seidel adj i j * seidel adj i j = 1 := by
  unfold seidel; aesop;

/-! ## Spectral moments -/

/-
**First spectral moment.**  The trace of the Seidel matrix is zero, so the
Seidel eigenvalues sum to zero.
-/
theorem seidel_trace (adj : Fin n → Fin n → Prop) [DecidableRel adj] :
    (seidel adj).trace = 0 := by
  simp +decide [ Matrix.trace, seidel ]

/-
**Second spectral moment (graph-independent).**  For every `n`-vertex graph,
`tr(S²) = n(n-1)`.  Since the diagonal of `S²` is the vector of squared row
norms and each off-diagonal entry squares to `1`, every diagonal entry equals
`n - 1`.
-/
theorem seidel_trace_sq (adj : Fin n → Fin n → Prop) [DecidableRel adj]
    (hsymm : ∀ i j, adj i j ↔ adj j i) :
    (seidel adj * seidel adj).trace = (n : ℝ) * (n - 1) := by
  simp +decide [ Matrix.trace, Matrix.mul_apply ];
  simp +decide [ Finset.sum_ite, Finset.filter_ne, Finset.filter_eq, hsymm ];
  simp +decide [ Finset.filter_filter, Finset.filter_ne' ] ; ring;
  rw [ Finset.sum_congr rfl fun i hi => by rw [ ← Nat.cast_add, Finset.card_filter_add_card_filter_not ] ] ; norm_num ; ring;
  cases n <;> norm_num ; ring

/-! ## Seidel energy of a Hermitian matrix -/

/-- The **energy** of a Hermitian matrix: the sum of the absolute values of its
(real) eigenvalues.  Applied to a Seidel matrix this is the *Seidel energy* of
the underlying graph. -/
noncomputable def energy (A : Matrix (Fin n) (Fin n) ℝ) (hA : A.IsHermitian) : ℝ :=
  ∑ i, |hA.eigenvalues i|

/-
Energy is nonnegative.
-/
theorem energy_nonneg (A : Matrix (Fin n) (Fin n) ℝ) (hA : A.IsHermitian) :
    0 ≤ energy A hA := by
  exact Finset.sum_nonneg fun _ _ => abs_nonneg _

/-
**Second moment in spectral form.**  The sum of the squared eigenvalues of a
real Hermitian matrix equals `tr(A²)`.
-/
theorem sum_sq_eigenvalues (A : Matrix (Fin n) (Fin n) ℝ) (hA : A.IsHermitian) :
    ∑ i, (hA.eigenvalues i) ^ 2 = (A * A).trace := by
  have := hA.spectral_theorem; (
  conv_rhs => rw [ this ] ; norm_num [ mul_assoc, Matrix.trace_mul_comm A ] ;
  simp +decide [ ← mul_assoc, Matrix.trace_mul_comm ];
  exact Finset.sum_congr rfl fun _ _ => sq _)

/-
**Cauchy–Schwarz for energy.**  The square of the energy dominates the sum of
squared eigenvalues, i.e. `E(A)² ≥ tr(A²)`.
-/
theorem energy_sq_ge_trace_sq (A : Matrix (Fin n) (Fin n) ℝ) (hA : A.IsHermitian) :
    (A * A).trace ≤ (energy A hA) ^ 2 := by
  rw [ ← sum_sq_eigenvalues A hA ];
  rw [ ← Finset.sum_congr rfl fun i _ => sq_abs ( hA.eigenvalues i ) ];
  simpa only [ sq, energy ] using by simpa only [ Finset.sum_mul _ _ _ ] using Finset.sum_le_sum fun i hi => mul_le_mul_of_nonneg_left ( Finset.single_le_sum ( fun i _ => abs_nonneg ( hA.eigenvalues i ) ) hi ) ( abs_nonneg ( hA.eigenvalues i ) ) ;

/-
**Universal Seidel energy lower bound.**  Every `n`-vertex graph has Seidel
energy at least `√(n(n-1))`.  The whole content is the invariance of the second
spectral moment (`seidel_trace_sq`) combined with Cauchy–Schwarz.
-/
theorem seidelEnergy_ge_sqrt (adj : Fin n → Fin n → Prop) [DecidableRel adj]
    (hsymm : ∀ i j, adj i j ↔ adj j i) :
    Real.sqrt ((n : ℝ) * (n - 1)) ≤ energy (seidel adj) (seidel_isHermitian adj hsymm) := by
  rw [ Real.sqrt_le_iff ];
  exact ⟨ energy_nonneg _ _, by have := energy_sq_ge_trace_sq ( seidel adj ) ( seidel_isHermitian adj hsymm ) ; have := seidel_trace_sq adj hsymm; norm_num at *; linarith ⟩

/-! ## Switching invariance

Seidel *switching* with respect to a vertex set `X` negates all edges between `X`
and its complement; on matrices this is conjugation by the diagonal `±1` matrix
`diag d` with `d i = -1 ⇔ i ∈ X`.  Since `diag d` is an involutory orthogonal
matrix, `diag d · S · diag d` is orthogonally similar to `S`, hence has the same
spectrum and the same energy.  Switching is the fundamental equivalence of
two-graph theory, and the Seidel energy is constant on switching classes. -/

/-
**Switching transports eigenpairs.**  For a `±1` vector `d`, if `S *ᵥ v = μ v`
then the switched matrix `diag d · S · diag d` has `i ↦ d i · v i` as an
eigenvector with the *same* eigenvalue `μ`.  Hence the Seidel spectrum is a
switching invariant.
-/
theorem switching_eigenpair_seidel (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ)
    (μ : ℝ) (d : Fin n → ℝ) (hd : ∀ i, d i = 1 ∨ d i = -1)
    (heig : A *ᵥ v = μ • v) :
    (Matrix.diagonal d * A * Matrix.diagonal d) *ᵥ (fun i => d i * v i)
      = μ • (fun i => d i * v i) := by
  -- By definition of matrix multiplication and the properties of diagonal matrices, we can simplify the expression.
  have h_simp : (diagonal d * A * diagonal d) *ᵥ (fun i => d i * v i) = diagonal d *ᵥ (A *ᵥ v) := by
    ext i; simp +decide [ Matrix.mulVec, dotProduct ] ; ring;
    simp +decide [ Matrix.diagonal, Finset.mul_sum _ _ _, mul_comm, mul_left_comm, sq ];
    exact Finset.sum_congr rfl fun j _ => by rcases hd j with ( hj | hj ) <;> rw [ hj ] <;> ring;
  simp_all +decide [ mul_comm, mul_left_comm, funext_iff, Matrix.mulVec ];
  simp_all +decide [ mul_comm, mul_left_comm, dotProduct ];
  simp_all +decide [ ← mul_assoc, ← Finset.sum_mul _ _ _ ]

/-! ## Examples and boundaries -/

/-- The **complete graph** adjacency: all distinct pairs adjacent.  Its Seidel
matrix is the all-`(-1)` off-diagonal matrix `I - J`. -/
def completeAdj (n : ℕ) : Fin n → Fin n → Prop := fun i j => i ≠ j

instance (n : ℕ) : DecidableRel (completeAdj n) := fun _ _ => inferInstanceAs (Decidable (_ ≠ _))

lemma completeAdj_symm (n : ℕ) : ∀ i j : Fin n, completeAdj n i j ↔ completeAdj n j i := by
  intro i j; simp [completeAdj, ne_comm]

/-- Concrete instance of the universal lower bound for the complete graph. -/
theorem completeGraph_energy_ge (n : ℕ) :
    Real.sqrt ((n : ℝ) * (n - 1)) ≤
      energy (seidel (completeAdj n)) (seidel_isHermitian _ (completeAdj_symm n)) :=
  seidelEnergy_ge_sqrt (completeAdj n) (completeAdj_symm n)

/-- **Complete multipartite (Turán-type) adjacency.**  Given a colouring
`part : Fin n → Fin r`, two vertices are adjacent iff they lie in different
parts.  With parts as equal as possible this is the Turán graph `T(n, r)`. -/
def multipartiteAdj (part : Fin n → Fin r) : Fin n → Fin n → Prop :=
  fun i j => part i ≠ part j

instance (part : Fin n → Fin r) : DecidableRel (multipartiteAdj part) :=
  fun _ _ => inferInstanceAs (Decidable (_ ≠ _))

lemma multipartiteAdj_symm (part : Fin n → Fin r) :
    ∀ i j : Fin n, multipartiteAdj part i j ↔ multipartiteAdj part j i := by
  intro i j; simp [multipartiteAdj, ne_comm]

/-- **Seidel energy lower bound for every complete multipartite / Turán graph.**
Independently of the partition, the Seidel energy is at least `√(n(n-1))`. -/
theorem turan_energy_ge (part : Fin n → Fin r) :
    Real.sqrt ((n : ℝ) * (n - 1)) ≤
      energy (seidel (multipartiteAdj part))
        (seidel_isHermitian _ (multipartiteAdj_symm part)) :=
  seidelEnergy_ge_sqrt (multipartiteAdj part) (multipartiteAdj_symm part)

/-- **Boundary phenomenon behind the Tian et al. edge-deletion problem.**  The
second Seidel moment `tr(S²) = n(n-1)` depends only on the number of vertices,
not on the edge set, so it is invariant under deleting or adding an edge.  Hence
the first two spectral moments cannot detect the energy change caused by an edge
deletion in a Turán graph: a strictly finer, eigenvalue-level analysis is
needed. -/
theorem trace_sq_edge_deletion_invariant
    (adj adj' : Fin n → Fin n → Prop) [DecidableRel adj] [DecidableRel adj']
    (hsymm : ∀ i j, adj i j ↔ adj j i) (hsymm' : ∀ i j, adj' i j ↔ adj' j i) :
    (seidel adj * seidel adj).trace = (seidel adj' * seidel adj').trace := by
  rw [seidel_trace_sq adj hsymm, seidel_trace_sq adj' hsymm']

/-- Sanity check: for a single vertex the bound degenerates to `0 ≤ E`. -/
example : Real.sqrt ((1 : ℝ) * (1 - 1)) ≤
    energy (seidel (completeAdj 1)) (seidel_isHermitian _ (completeAdj_symm 1)) := by
  simpa using completeGraph_energy_ge 1

#check @seidelEnergy_ge_sqrt
#check @seidel_trace_sq
#check @switching_eigenpair_seidel
#check @turan_energy_ge
#check @trace_sq_edge_deletion_invariant

end SeidelEnergy

/-
-- !-- Lab Notes -- !--

Category (Menu Balance): CROSS-DOMAIN BRIDGE
  Graph theory (Seidel / two-graph adjacency, switching classes, Turán graphs)
  ⨯ spectral & linear algebra (Hermitian eigenvalues, trace moments,
  Cauchy–Schwarz).  Extends the catalog files
  `Novelty/SignedGraphSpectralEquality.lean` (signed-adjacency Δ-bound and
  switching) and `Novelty/SpectralBound.lean` from the general signed setting to
  the complete signed (Seidel) matrices underlying Seidel-energy theory, and
  toward the Turán edge-deletion problem of Tian et al.

External signal: the target is Theorem 1.2 of the recent line of work on how the
Seidel energy of Turán graphs reacts to edge deletion (resolving a problem of
Tian and collaborators).  The full theorem needs reduced-order spectral
machinery for blow-up graphs; here we build the elementary spectral-moment layer
it rests on, plus the switching symmetry that makes the Seidel spectrum a class
invariant.

=== CYCLE 1: Seidel matrix and its spectral moments ===

Hypotheses (Hypothesizer):
  H1. The Seidel matrix S of any graph is real symmetric with 0 diagonal and
      ±1 off-diagonal entries; hence Hermitian with a real spectrum.
  H2. The first two spectral moments are graph-independent: tr S = ∑λ = 0 and
      tr S² = ∑λ² = n(n-1).  (Bold: this is the exact obstruction that makes the
      Turán edge-deletion problem hard — the cheap invariants are blind to it.)
  H3. Every n-vertex graph has Seidel energy ≥ √(n(n-1)), a universal lower
      bound from Cauchy–Schwarz on the fixed second moment.

Experiments (Experimenter):
  * `seidel_isSymm` / `seidel_isHermitian` : entrywise case analysis on the
    diagonal / adjacency using symmetry of the relation.  Confirmed H1.
  * `seidel_trace` : the diagonal is identically 0.  `seidel_trace_sq` :
    expanding tr(S²) = ∑_{i,j} S_ij S_ji = ∑_{i,j} S_ij² and counting the n-1
    off-diagonal ones per row.  Confirmed H2.
  * `sum_sq_eigenvalues` : ∑λ² = tr(S²) via the unitary spectral theorem
    (A = U D U*, so tr(A²) = tr(D²) = ∑λ²).  `energy_sq_ge_trace_sq` :
    (∑|λ|)² ≥ ∑|λ|² = ∑λ².  Chaining with `seidel_trace_sq` yields
    `seidelEnergy_ge_sqrt`, specialised to Turán graphs in `turan_energy_ge`.
    Confirmed H3.

Analysis (Analyst):
  - The decisive invariant is the SECOND MOMENT tr(S²) = n(n-1): it pins the
    Seidel spectrum to a sphere of fixed radius and yields the universal energy
    floor, yet it is constant across all graphs on n vertices
    (`trace_sq_edge_deletion_invariant`).  This is precisely why the Tian et al.
    edge-deletion inequality is subtle: it is invisible to the first two moments.
  - Over ℝ, "Hermitian" = "symmetric", and the real-part cast is the identity,
    keeping the eigenvalue bookkeeping real-valued throughout.

=== CYCLE 2: switching invariance ===

Hypotheses:
  H4. Seidel switching (conjugation by a ±1 diagonal) transports every eigenpair
      at the same eigenvalue, so the Seidel spectrum — and hence the energy — is
      a switching-class invariant.

Experiments:
  * `switching_eigenpair_seidel` : with w i = d i · v i and d² = 1, the switched
    matrix diag d · S · diag d sends w to μ·w.  Proved via mulVec associativity
    and diag d *ᵥ w = v.  Confirmed H4 at the eigenpair level.

Critique (Critic):
  - No result is vacuous: the moment identities are genuine counting/trace
    computations; the energy bound consumes the full spectral theorem via
    Cauchy–Schwarz; switching is a real conjugation argument (d² = 1).
  - Corner cases: n = 0, 1 give the bound 0 ≤ E consistently (the `example`
    checks n = 1).  The edge-deletion invariance is stated for arbitrary pairs
    of graphs, exposing the moment's blindness directly.

Generalization / extension:
  The moment identities and the energy floor hold verbatim for any complete
  signed graph (two-graph), not just Seidel matrices of ordinary graphs; and the
  switching argument works for any real symmetric matrix conjugated by a ±1
  diagonal.  The Turán specialisation is one instance of the universal bound.

Synthesis (PI):
  The second spectral moment is simultaneously the source of the universal energy
  lower bound and the reason edge-deletion effects are moment-invisible; switching
  is the symmetry that makes the whole spectrum a class invariant.  The next step
  is to upgrade from the sphere constraint ∑λ² = n(n-1) to eigenvalue-interlacing
  / reduced-order analysis on blow-up graphs needed for the strict Turán
  edge-deletion inequality — see FUTURE_DIRECTIONS.md.
-/