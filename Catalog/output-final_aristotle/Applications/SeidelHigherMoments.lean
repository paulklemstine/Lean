/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Higher spectral moments of the Seidel matrix under edge flips

The **Seidel matrix** `S` of a finite simple graph has `0` on the diagonal, `-1`
on adjacent pairs and `+1` on non-adjacent distinct pairs.  The foundational
theory (see `Novelty/SeidelEnergyTuran.lean`) shows the *second* spectral moment
is **graph-independent**, `tr(S²) = n(n-1)`, and hence completely *blind* to
edge deletion: deleting one edge `{a,b}` only flips the two symmetric entries
`S a b, S b a` from `-1` to `+1`, which does not change `tr(S²)`.

This file establishes the contrarian companion fact: the *third* spectral moment
is **not** blind to an edge flip, and its change has a closed form.  An edge flip
is the symmetric rank-two update `S ↦ S + c·(Eᵃᵇ + Eᵇᵃ)`.  The main result

* `trace_cube_flip` : for any real symmetric zero-diagonal `M`, `a ≠ b`, `c`,
  `tr((M+P)³) − tr(M³) = 6·c·(M²)_{a b}` where `P = c·(Eᵃᵇ + Eᵇᵃ)`;

specialises (via the bridge `seidel_delete_eq`, with `c = 2` for a deletion) to

* `seidel_trace_cube_delete` : the third Seidel moment changes by
  `12·(S²)_{a b}` under deleting the edge `{a,b}`, while
* `seidel_trace_sq_delete_invariant` : the second moment does not change at all.

A concrete `K₃` vs `K₃ − e` computation (`K3_vs_P3_third_moment`,
`K3_vs_P3_second_moment`) exhibits the phenomenon: `tr(S³)` jumps `-6 → +6`
whereas `tr(S²)` stays fixed.

Finally `seidel_compl_eq` / `seidel_energy_compl` record that complementation
negates the Seidel matrix and therefore preserves the Seidel energy — so energy
cannot be a monotone function of the number of edges.

This is a cross-domain bridge: graph theory (edge flips, complementation) ⨯
linear algebra (trace moments, rank-two updates, Hermitian spectra).
-/
import Mathlib

open Matrix BigOperators

namespace SeidelHigherMoments

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Trace algebra for the rank-two edge-flip update -/

/-
Trace of a matrix multiplied on the right by a `single` matrix.
-/
lemma trace_mul_single (A : Matrix V V ℝ) (a b : V) (r : ℝ) :
    (A * Matrix.single a b r).trace = r * A b a := by
  simp +decide [ Matrix.trace, Matrix.mul_apply, mul_comm ];
  rw [ Finset.sum_eq_single b ];
  · simp +decide [ mul_comm, single ];
  · simp +contextual [ Matrix.single, Finset.sum_ite ];
    exact fun x hx => Finset.sum_eq_zero fun y hy => False.elim <| hx <| by aesop;
  · grind

/-
Cubic expansion of the trace, using cyclicity of the trace to collect the
mixed terms.
-/
lemma trace_cube_add (M P : Matrix V V ℝ) :
    ((M + P) * (M + P) * (M + P)).trace
      = (M * M * M).trace + 3 * (M * M * P).trace + 3 * (M * P * P).trace
        + (P * P * P).trace := by
  simp +decide only [mul_add, add_mul, mul_assoc, trace_add, trace_mul_comm M];
  norm_num [ ← mul_assoc, Matrix.trace_mul_comm M ] ; ring;
  rw [ show P * M * P = P * ( M * P ) by rw [ Matrix.mul_assoc ], show P * P * M = P * ( P * M ) by rw [ Matrix.mul_assoc ], show P * P * P = P * ( P * P ) by rw [ Matrix.mul_assoc ] ] ; simp +decide [ Matrix.trace_mul_comm P, mul_assoc ] ; ring;

/-- The symmetric rank-two "edge-flip" perturbation at the pair `{a,b}` with
weight `c`. -/
def flipPert (a b : V) (c : ℝ) : Matrix V V ℝ :=
  c • (Matrix.single a b 1 + Matrix.single b a 1)

/-
**Third-moment edge-flip formula.**  For a real symmetric matrix `M` with
zero diagonal and `a ≠ b`, flipping the entry pair `{a,b}` with weight `c`
changes the third spectral moment by exactly `6·c·(M²)_{a b}`.
-/
theorem trace_cube_flip (M : Matrix V V ℝ) (hsymm : M.IsSymm)
    (hdiag : ∀ i, M i i = 0) (a b : V) (hab : a ≠ b) (c : ℝ) :
    ((M + flipPert a b c) * (M + flipPert a b c) * (M + flipPert a b c)).trace
      - (M * M * M).trace
      = 6 * c * (M * M) a b := by
  rw [ trace_cube_add ];
  unfold flipPert;
  simp +decide [ Matrix.mul_add, Matrix.add_mul, Matrix.mul_smul, Matrix.smul_mul, hdiag, mul_assoc, hab.symm ] ; ring;
  simp +decide [ ← mul_assoc, trace_mul_single, hdiag, hab ] ; ring;
  simp +decide [ Matrix.mul_apply, mul_comm, hsymm.apply ] ; ring

/-! ## The Seidel matrix -/

/-- The **Seidel matrix** of an adjacency relation `adj`. -/
def seidel (adj : V → V → Prop) [DecidableRel adj] : Matrix V V ℝ :=
  Matrix.of (fun i j => if i = j then 0 else if adj i j then -1 else 1)

@[simp] lemma seidel_apply (adj : V → V → Prop) [DecidableRel adj] (i j : V) :
    seidel adj i j = if i = j then 0 else if adj i j then -1 else 1 := rfl

@[simp] lemma seidel_diag (adj : V → V → Prop) [DecidableRel adj] (i : V) :
    seidel adj i i = 0 := by simp [seidel]

theorem seidel_isSymm (adj : V → V → Prop) [DecidableRel adj]
    (hsymm : ∀ i j, adj i j ↔ adj j i) : (seidel adj).IsSymm := by
  ext i j; simp +decide [ seidel, hsymm i j ] ;
  grind

theorem seidel_isHermitian (adj : V → V → Prop) [DecidableRel adj]
    (hsymm : ∀ i j, adj i j ↔ adj j i) : (seidel adj).IsHermitian := by
  ext i j; aesop;

/-! ## Edge deletion as a rank-two flip -/

/-
**Bridge lemma.**  If `adj'` agrees with `adj` everywhere except that the
edge `{a,b}` (present in `adj`) has been deleted, then the Seidel matrix picks up
exactly the rank-two flip `+2·(Eᵃᵇ + Eᵇᵃ)`.
-/
theorem seidel_delete_eq (adj adj' : V → V → Prop) [DecidableRel adj] [DecidableRel adj']
    (a b : V) (hab : a ≠ b) (hadj : adj a b) (hadj' : ¬ adj' a b)
    (hsymm : ∀ i j, adj i j ↔ adj j i) (hsymm' : ∀ i j, adj' i j ↔ adj' j i)
    (hother : ∀ i j, ¬ (i = a ∧ j = b) → ¬ (i = b ∧ j = a) → (adj' i j ↔ adj i j)) :
    seidel adj' = seidel adj + flipPert a b 2 := by
  ext i j;
  unfold seidel flipPert; by_cases hi : i = a <;> by_cases hj : j = b <;> simp +decide [ *, Matrix.single ] ;
  · norm_num;
  · grobner;
  · grind;
  · grind

/-
**Second moment is blind to edge deletion.**  The diagonal of `S²` counts the
off-diagonal pairs, independently of the adjacency, so `tr(S²)` is unchanged.
-/
theorem seidel_trace_sq_delete_invariant
    (adj adj' : V → V → Prop) [DecidableRel adj] [DecidableRel adj']
    (hsymm : ∀ i j, adj i j ↔ adj j i) (hsymm' : ∀ i j, adj' i j ↔ adj' j i) :
    (seidel adj' * seidel adj').trace = (seidel adj * seidel adj).trace := by
  exact Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by aesop;

/-
**Third moment detects edge deletion.**  Deleting the edge `{a,b}` changes
the third Seidel moment by `12·(S²)_{a b}`.
-/
theorem seidel_trace_cube_delete
    (adj adj' : V → V → Prop) [DecidableRel adj] [DecidableRel adj']
    (a b : V) (hab : a ≠ b) (hadj : adj a b) (hadj' : ¬ adj' a b)
    (hsymm : ∀ i j, adj i j ↔ adj j i) (hsymm' : ∀ i j, adj' i j ↔ adj' j i)
    (hother : ∀ i j, ¬ (i = a ∧ j = b) → ¬ (i = b ∧ j = a) → (adj' i j ↔ adj i j)) :
    (seidel adj' * seidel adj' * seidel adj').trace
      - (seidel adj * seidel adj * seidel adj).trace
      = 12 * (seidel adj * seidel adj) a b := by
  have h_delete : seidel adj' = seidel adj + flipPert a b 2 := by
    apply seidel_delete_eq adj adj' a b hab hadj hadj' hsymm hsymm' hother;
  rw [ h_delete ];
  convert trace_cube_flip ( seidel adj ) ( seidel_isSymm adj hsymm ) ( seidel_diag adj ) a b hab 2 using 1 ; ring!

/-! ## Concrete witness: `K₃` versus `K₃ − e` (the path `P₃`) -/

/-- Seidel matrix of the triangle `K₃`. -/
def SK3 : Matrix (Fin 3) (Fin 3) ℝ := !![0,-1,-1;-1,0,-1;-1,-1,0]

/-- Seidel matrix of `K₃` with the edge `{1,2}` deleted (the path `P₃`). -/
def SP3 : Matrix (Fin 3) (Fin 3) ℝ := !![0,-1,-1;-1,0,1;-1,1,0]

/-
The third moment changes (`-6 → +6`) under the single edge deletion.
-/
theorem K3_vs_P3_third_moment :
    (SK3 * SK3 * SK3).trace = -6 ∧ (SP3 * SP3 * SP3).trace = 6 := by
  norm_num [ SK3, SP3, Matrix.trace ];
  norm_num [ Fin.sum_univ_succ ]

/-
The second moment is unchanged by that same deletion.
-/
theorem K3_vs_P3_second_moment :
    (SK3 * SK3).trace = (SP3 * SP3).trace := by
  norm_num [ Fin.sum_univ_succ, SK3, SP3 ]

/-
The predicted flip quantity `(S²)_{1,2} = 1`, matching
`6 - (-6) = 12 = 12·1`.
-/
theorem K3_flip_quantity : (SK3 * SK3) 1 2 = 1 := by
  unfold SK3;
  aesop

/-! ## Complementation negates the Seidel matrix -/

/-- The complement adjacency: distinct vertices that are non-adjacent in `adj`. -/
def complAdj (adj : V → V → Prop) : V → V → Prop := fun i j => i ≠ j ∧ ¬ adj i j

instance (adj : V → V → Prop) [DecidableRel adj] : DecidableRel (complAdj adj) :=
  fun _ _ => inferInstanceAs (Decidable (_ ∧ _))

/-
**Complementation negates the Seidel matrix.**
-/
theorem seidel_compl_eq (adj : V → V → Prop) [DecidableRel adj] :
    seidel (complAdj adj) = - seidel adj := by
  ext i j; by_cases hij : i = j <;> simp +decide [ hij, seidel, complAdj ] ;
  split_ifs <;> norm_num

/-- The **Seidel energy**: the sum of the absolute values of the eigenvalues. -/
noncomputable def energy (A : Matrix V V ℝ) (hA : A.IsHermitian) : ℝ :=
  ∑ i, |hA.eigenvalues i|

/-
Energy is invariant under negation of the matrix.
-/
theorem energy_neg (A : Matrix V V ℝ) (hA : A.IsHermitian) :
    energy (-A) hA.neg = energy A hA := by
  unfold energy;
  have h_charpoly_roots : Multiset.map (fun x => |x|) (Matrix.charpoly A).roots = Multiset.map (fun x => |x|) (Matrix.charpoly (-A)).roots := by
    have h_charpoly_roots : (Matrix.charpoly (-A)) = Polynomial.comp (Matrix.charpoly A) (-Polynomial.X) * (-1) ^ (Fintype.card V) := by
      simp +decide [ Matrix.charpoly, Matrix.det_apply' ];
      simp +decide [ Matrix.charmatrix, Polynomial.comp, Polynomial.eval₂_finset_prod ];
      rw [ Finset.sum_mul _ _ _ ] ; refine' Finset.sum_congr rfl fun σ _ => _ ; simp +decide [ Matrix.diagonal ] ; ring;
      rw [ mul_assoc, ← Finset.prod_congr rfl fun _ _ => neg_sub _ _ ] ; rw [ Finset.prod_congr rfl fun _ _ => neg_eq_neg_one_mul _, Finset.prod_mul_distrib ] ; simp +decide [ Finset.prod_const, Finset.card_univ ] ; ring;
      rw [ pow_mul' ] ; norm_num [ ← mul_pow ] ; congr ; ext ; aesop;
    rw [ h_charpoly_roots, Polynomial.roots_mul ] <;> norm_num;
    · have h_charpoly_roots : Polynomial.roots (Matrix.charpoly A) = Multiset.map (fun x => -x) (Polynomial.roots (Polynomial.comp (Matrix.charpoly A) (-Polynomial.X))) := by
        have h_charpoly_roots : Polynomial.comp (Matrix.charpoly A) (-Polynomial.X) = Polynomial.C ((-1) ^ Fintype.card V) * Multiset.prod (Multiset.map (fun x => Polynomial.X + Polynomial.C x) (Polynomial.roots (Matrix.charpoly A))) := by
          have h_charpoly_roots : Matrix.charpoly A = Polynomial.C 1 * Multiset.prod (Multiset.map (fun x => Polynomial.X - Polynomial.C x) (Polynomial.roots (Matrix.charpoly A))) := by
            convert Polynomial.Splits.eq_prod_roots _;
            · rw [ Matrix.charpoly_monic ];
            · exact IsHermitian.splits_charpoly hA;
          conv_lhs => rw [ h_charpoly_roots ];
          norm_num [ Polynomial.multiset_prod_comp ];
          rw [ show ( Multiset.map ( fun x => -Polynomial.X - Polynomial.C x ) A.charpoly.roots ) = Multiset.map ( fun x => -1 * ( Polynomial.X + Polynomial.C x ) ) A.charpoly.roots by exact Multiset.map_congr rfl fun x hx => by ring, Multiset.prod_map_mul ] ; norm_num;
          replace h_charpoly_roots := congr_arg Polynomial.natDegree h_charpoly_roots; rw [ Matrix.charpoly_natDegree_eq_dim ] at *; simp +decide at *;
          exact Or.inl ( by rw [ ← h_charpoly_roots ] )
        rw [ h_charpoly_roots, Polynomial.roots_C_mul ] <;> norm_num;
        rw [ Polynomial.roots_multiset_prod ];
        · simp +decide [ Multiset.bind ];
          simp +decide [ Multiset.join ];
        · simp +decide [ Polynomial.X_add_C_ne_zero ];
      rw [ h_charpoly_roots, Multiset.map_map ] ; norm_num;
    · exact Matrix.charpoly_monic A |> fun h => h.ne_zero;
  convert congr_arg Multiset.sum h_charpoly_roots.symm using 1;
  · have := hA.neg.roots_charpoly_eq_eigenvalues;
    simp +decide [ this ];
  · rw [ hA.roots_charpoly_eq_eigenvalues ];
    norm_num [ Function.comp ]

/-
**Complementation preserves the Seidel energy.**  Hence Seidel energy cannot
be a monotone function of the number of edges.
-/
theorem seidel_energy_compl (adj : V → V → Prop) [DecidableRel adj]
    (hsymm : ∀ i j, adj i j ↔ adj j i) :
    energy (seidel (complAdj adj))
        (by rw [seidel_compl_eq]; exact (seidel_isHermitian adj hsymm).neg)
      = energy (seidel adj) (seidel_isHermitian adj hsymm) := by
  convert energy_neg ( seidel adj ) ( seidel_isHermitian adj hsymm ) using 1;
  convert rfl;
  exact seidel_compl_eq adj ▸ rfl

end SeidelHigherMoments