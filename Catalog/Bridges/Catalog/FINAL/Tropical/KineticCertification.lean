import Mathlib

/-!
# Tropical Kinetic Certification, Data Processing, and Polyhedral Compilation

This file formalizes three tightly coupled breakthrough results in tropical mathematics:

1. **Kinetic Tropical Certification**: Stability of tropical argmax decisions under time evolution.
2. **Tropical Data Processing Inequality**: Spread monotonicity under coarse-graining.
3. **Polyhedral Membership Certification**: Stability of polyhedral region membership
   under perturbation.

These theorems form the formal nucleus for a verified theory of tropical certified computation,
bridging tropical geometry, information theory, and geometric compilation.
-/

noncomputable section
open Finset

/-! ## Part I: Kinetic Tropical Certification -/

/-- Tropical affine score: b + max_i (w_i + x_i).
This is the fundamental building block for tropicalized neural network scores. -/
def tropAffineScore {n : ℕ} (hn : 0 < n) (w x : Fin n → ℝ) (b : ℝ) : ℝ :=
  let _ : Nonempty (Fin n) := Fin.pos_iff_nonempty.mp hn
  b + Finset.univ.sup' Finset.univ_nonempty (fun i => w i + x i)

/-- Linear path: x(t) = x0 + t * v. -/
def linePath {n : ℕ} (x0 v : Fin n → ℝ) (t : ℝ) : Fin n → ℝ :=
  fun i => x0 i + t * v i

/-
Key perturbation lemma: the sup of (a_i + t * v_i) is Lipschitz in t with
constant max_i |v_i|.
-/
theorem sup'_add_smul_lipschitz {n : ℕ} (hn : 0 < n) (a v : Fin n → ℝ) (t : ℝ) :
    let _ : Nonempty (Fin n) := Fin.pos_iff_nonempty.mp hn
    |Finset.univ.sup' Finset.univ_nonempty (fun i => a i + t * v i) -
     Finset.univ.sup' Finset.univ_nonempty (fun i => a i)| ≤
    |t| * Finset.univ.sup' Finset.univ_nonempty (fun i => |v i|) := by
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
  · simp +zetaDelta at *;
    intro i; cases abs_cases t <;> nlinarith [ abs_le.mp ( Finset.le_sup' ( fun i => |v i| ) ( Finset.mem_univ i ) ), Finset.le_sup' ( fun i => a i ) ( Finset.mem_univ i ) ] ;
  · simp_all +decide [ Finset.sup'_le_iff ];
    intro i; cases abs_cases t <;> nlinarith [ abs_le.mp ( Finset.le_sup' ( fun i => |v i| ) ( Finset.mem_univ i ) ), Finset.le_sup' ( fun i => a i + t * v i ) ( Finset.mem_univ i ) ] ;

/-
Tropical affine score is Lipschitz along a linear path.
-/
theorem tropAffineScore_lipschitz_along_path {n : ℕ} (hn : 0 < n)
    (w x0 v : Fin n → ℝ) (b : ℝ) (t : ℝ) :
    let _ : Nonempty (Fin n) := Fin.pos_iff_nonempty.mp hn
    |tropAffineScore hn w (linePath x0 v t) b - tropAffineScore hn w x0 b| ≤
    |t| * Finset.univ.sup' Finset.univ_nonempty (fun i => |v i|) := by
  convert sup'_add_smul_lipschitz hn _ _ t using 1;
  rotate_left;
  exact fun i => w i + x0 i;
  exact v;
  unfold tropAffineScore linePath; ring;
  grind

/-
**Kinetic Tropical Margin Stability** (qualitative version):
If the margin between two tropical affine scores is positive at t=0,
then the winning class remains unchanged for all sufficiently small |t|.
-/
theorem kinetic_tropical_margin_stability {n : ℕ} (hn : 0 < n)
    (w₁ w₂ x0 v : Fin n → ℝ) (b₁ b₂ : ℝ)
    (hmargin : 0 < tropAffineScore hn w₁ x0 b₁ - tropAffineScore hn w₂ x0 b₂) :
    ∃ ε > 0, ∀ t : ℝ, |t| < ε →
      tropAffineScore hn w₁ (linePath x0 v t) b₁ >
      tropAffineScore hn w₂ (linePath x0 v t) b₂ := by
  -- By the Lipschitz continuity of the tropical affine score, we have:
  have h_lip : ∀ t, |tropAffineScore hn w₁ (linePath x0 v t) b₁ - tropAffineScore hn w₁ x0 b₁| ≤ |t| * Finset.univ.sup' (by
  exact ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩) (fun i => |v i|) ∧
                      |tropAffineScore hn w₂ (linePath x0 v t) b₂ - tropAffineScore hn w₂ x0 b₂| ≤ |t| * Finset.univ.sup' (by
                      exact ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩) (fun i => |v i|) := by
                        exact fun t => ⟨ tropAffineScore_lipschitz_along_path hn w₁ x0 v b₁ t, tropAffineScore_lipschitz_along_path hn w₂ x0 v b₂ t ⟩
  generalize_proofs at *;
  refine' ⟨ ( tropAffineScore hn w₁ x0 b₁ - tropAffineScore hn w₂ x0 b₂ ) / ( 2 * ( Finset.univ.sup' ( Finset.univ_nonempty_iff.mpr ⟨ 0, hn ⟩ ) fun i => |v i| ) + 1 ), div_pos hmargin ( by linarith [ show 0 ≤ Finset.univ.sup' ( Finset.univ_nonempty_iff.mpr ⟨ 0, hn ⟩ ) fun i => |v i| from by exact le_trans ( by norm_num ) ( Finset.le_sup' ( fun i => |v i| ) ( Finset.mem_univ ⟨ 0, hn ⟩ ) ) ] ), fun t ht => _ ⟩;
  rw [ lt_div_iff₀ ] at ht <;> nlinarith [ abs_le.mp ( h_lip t |>.1 ), abs_le.mp ( h_lip t |>.2 ), show 0 ≤ Finset.univ.sup' ( Finset.univ_nonempty_iff.mpr ⟨ 0, hn ⟩ ) fun i => |v i| from Finset.le_sup' ( fun i => |v i| ) ( Finset.mem_univ ⟨ 0, hn ⟩ ) |> le_trans ( abs_nonneg _ ) ]

/-
**Kinetic Tropical Margin Stability** (explicit quantitative version):
Provides an explicit lower bound on the stability interval.
-/
theorem kinetic_tropical_margin_stability_explicit {n : ℕ} (hn : 0 < n)
    (w₁ w₂ x0 v : Fin n → ℝ) (b₁ b₂ : ℝ)
    (hmargin : 0 < tropAffineScore hn w₁ x0 b₁ - tropAffineScore hn w₂ x0 b₂) :
    let _ : Nonempty (Fin n) := Fin.pos_iff_nonempty.mp hn
    let L := Finset.univ.sup' Finset.univ_nonempty (fun i => |v i|)
    ∀ t : ℝ,
      |t| < (tropAffineScore hn w₁ x0 b₁ - tropAffineScore hn w₂ x0 b₂) / (2 * L + 1) →
      tropAffineScore hn w₁ (linePath x0 v t) b₁ >
      tropAffineScore hn w₂ (linePath x0 v t) b₂ := by
  simp +zetaDelta at *;
  intro t ht;
  rw [ lt_div_iff₀ ] at ht;
  · have := tropAffineScore_lipschitz_along_path hn w₁ x0 v b₁ t;
    have := tropAffineScore_lipschitz_along_path hn w₂ x0 v b₂ t;
    grind;
  · exact add_pos_of_nonneg_of_pos ( mul_nonneg zero_le_two ( Finset.le_sup' ( fun i => |v i| ) ( Finset.mem_univ ⟨ 0, hn ⟩ ) |> le_trans ( abs_nonneg _ ) ) ) zero_lt_one

/-! ## Part II: Tropical Data Processing Inequality -/

/-- Tropical spread: max_i x_i - min_i x_i. Measures the dynamic range of a score vector. -/
def tropSpread {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) : ℝ :=
  let _ : Nonempty (Fin n) := Fin.pos_iff_nonempty.mp hn
  Finset.univ.sup' Finset.univ_nonempty x -
  Finset.univ.inf' Finset.univ_nonempty x

/-- Coarse-graining by taking the max over fibers of a surjection π. -/
def coarseGrainMax {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (π : Fin n → Fin m) (hπ : Function.Surjective π)
    (x : Fin n → ℝ) : Fin m → ℝ :=
  fun j =>
    (Finset.univ.filter (fun i => π i = j)).sup'
      (by obtain ⟨i, rfl⟩ := hπ j
          exact ⟨i, Finset.mem_filter.mpr ⟨Finset.mem_univ _, rfl⟩⟩)
      x

/-
The global maximum is preserved by coarse-graining: max of block maxima = global max.
-/
theorem coarseGrainMax_sup_eq {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (π : Fin n → Fin m) (hπ : Function.Surjective π)
    (x : Fin n → ℝ) :
    let _ : Nonempty (Fin n) := Fin.pos_iff_nonempty.mp hn
    let _ : Nonempty (Fin m) := Fin.pos_iff_nonempty.mp hm
    Finset.univ.sup' Finset.univ_nonempty (coarseGrainMax hn hm π hπ x) =
    Finset.univ.sup' Finset.univ_nonempty x := by
  refine le_antisymm ?_ ?_;
  · simp +decide [ coarseGrainMax ];
    cases' Finset.exists_max_image Finset.univ x ( Finset.univ_nonempty_iff.mpr ⟨ ⟨ 0, hn ⟩ ⟩ ) with b hb ; use b ; aesop;
  · simp +decide [ Finset.le_sup', coarseGrainMax ];
    simpa using Finset.exists_max_image Finset.univ x ( Finset.univ_nonempty_iff.mpr ⟨ _, hn ⟩ )

/-
The global minimum can only increase under coarse-graining.
-/
theorem coarseGrainMax_inf_ge {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (π : Fin n → Fin m) (hπ : Function.Surjective π)
    (x : Fin n → ℝ) :
    let _ : Nonempty (Fin n) := Fin.pos_iff_nonempty.mp hn
    let _ : Nonempty (Fin m) := Fin.pos_iff_nonempty.mp hm
    Finset.univ.inf' Finset.univ_nonempty x ≤
    Finset.univ.inf' Finset.univ_nonempty (coarseGrainMax hn hm π hπ x) := by
  simp +decide [ coarseGrainMax ];
  exact fun b => by obtain ⟨ i, hi ⟩ := hπ b; exact ⟨ i, hi, i, le_rfl ⟩ ;

/-
**Tropical Data Processing Inequality**:
Deterministic coarse-graining by block maxima cannot increase tropical spread.
This is a max-plus analogue of the data processing inequality.
-/
theorem tropSpread_coarseGrainMax_le {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (π : Fin n → Fin m) (hπ : Function.Surjective π)
    (x : Fin n → ℝ) :
    tropSpread hm (coarseGrainMax hn hm π hπ x) ≤ tropSpread hn x := by
  convert sub_le_sub_left ( coarseGrainMax_inf_ge hn hm π hπ x ) _ using 1;
  rw [ coarseGrainMax_sup_eq ];
  rfl

/-! ## Part III: Polyhedral Membership Certification -/

/-- Affine form: the dot product ∑ c_i * x_i. -/
def affineForm {n : ℕ} (c : Fin n → ℝ) (x : Fin n → ℝ) : ℝ :=
  ∑ i, c i * x i

/-- Polyhedral slack: b_j - ∑ c_{j,i} * x_i. Positive slack means the constraint is strictly satisfied. -/
def polySlack {n k : ℕ} (A : Fin k → Fin n → ℝ) (b : Fin k → ℝ)
    (x : Fin n → ℝ) (j : Fin k) : ℝ :=
  b j - affineForm (A j) x

/-- Membership in a polyhedron: all affine constraints are satisfied. -/
def inPolyhedron {n k : ℕ} (A : Fin k → Fin n → ℝ) (b : Fin k → ℝ)
    (x : Fin n → ℝ) : Prop :=
  ∀ j, affineForm (A j) x ≤ b j

/-
Affine form perturbation bound: |∑ c_i (y_i - x_i)| ≤ ε * ∑ |c_i| when |y_i - x_i| < ε.
-/
theorem affineForm_perturbation_bound {n : ℕ}
    (c x y : Fin n → ℝ) (ε : ℝ) (hε : 0 < ε)
    (hclose : ∀ i, |y i - x i| < ε) :
    |affineForm c y - affineForm c x| ≤ ε * ∑ i, |c i| := by
  -- By Lemma 25, we can expand the difference of affine forms.
  have h_affine_form_diff : affineForm c y - affineForm c x = ∑ i, c i * (y i - x i) := by
    unfold affineForm; rw [ ← Finset.sum_sub_distrib ] ; exact Finset.sum_congr rfl fun _ _ => by ring;
  exact h_affine_form_diff ▸ le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( by rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_le_sum fun i _ => by rw [ abs_mul, mul_comm ] ; exact mul_le_mul_of_nonneg_right ( le_of_lt ( hclose i ) ) ( abs_nonneg _ ) )

/-
**Polyhedral Membership Stability** (qualitative):
If a point is in the strict interior of a polyhedron (all slacks positive),
then nearby points are also in the polyhedron.
-/
theorem polyhedral_membership_stable {n k : ℕ}
    (A : Fin k → Fin n → ℝ) (b : Fin k → ℝ)
    (x : Fin n → ℝ)
    (hinside : inPolyhedron A b x)
    (hslack : ∀ j, 0 < polySlack A b x j) :
    ∃ ε > 0, ∀ y : Fin n → ℝ,
      (∀ i, |y i - x i| < ε) →
      inPolyhedron A b y := by
  rcases k with ( _ | k ) <;> simp_all +decide [ inPolyhedron ];
  · exact ⟨ 1, by norm_num ⟩;
  · -- By the properties of the affine form, we can bound the difference between the affine forms of $y$ and $x$.
    have h_affine_bound : ∀ j : Fin (k + 1), ∃ ε_j > 0, ∀ y : Fin n → ℝ, (∀ i, |y i - x i| < ε_j) → affineForm (A j) y ≤ b j := by
      intro j
      obtain ⟨ε_j, hε_j_pos, hε_j⟩ : ∃ ε_j > 0, ∀ y : Fin n → ℝ, (∀ i, |y i - x i| < ε_j) → |affineForm (A j) y - affineForm (A j) x| < polySlack A b x j := by
        have := affineForm_perturbation_bound ( A j ) x;
        exact ⟨ ( polySlack A b x j ) / ( ∑ i, |A j i| + 1 ), div_pos ( hslack j ) ( add_pos_of_nonneg_of_pos ( Finset.sum_nonneg fun _ _ => abs_nonneg _ ) zero_lt_one ), fun y hy => lt_of_le_of_lt ( this y _ ( div_pos ( hslack j ) ( add_pos_of_nonneg_of_pos ( Finset.sum_nonneg fun _ _ => abs_nonneg _ ) zero_lt_one ) ) hy ) ( by nlinarith [ hslack j, div_mul_cancel₀ ( polySlack A b x j ) ( show ( ∑ i, |A j i| + 1 ) ≠ 0 by exact ne_of_gt ( add_pos_of_nonneg_of_pos ( Finset.sum_nonneg fun _ _ => abs_nonneg _ ) zero_lt_one ) ), show 0 ≤ ∑ i, |A j i| by exact Finset.sum_nonneg fun _ _ => abs_nonneg _ ] ) ⟩;
      exact ⟨ ε_j, hε_j_pos, fun y hy => by linarith [ abs_lt.mp ( hε_j y hy ), hinside j, hslack j, show polySlack A b x j = b j - affineForm ( A j ) x from rfl ] ⟩;
    choose ε hε₁ hε₂ using h_affine_bound;
    exact ⟨ Finset.min' ( Finset.univ.image ε ) ⟨ _, Finset.mem_image_of_mem _ ( Finset.mem_univ 0 ) ⟩, by have := Finset.min'_mem ( Finset.univ.image ε ) ⟨ _, Finset.mem_image_of_mem _ ( Finset.mem_univ 0 ) ⟩ ; aesop, fun y hy j => hε₂ j y fun i => lt_of_lt_of_le ( hy i ) ( Finset.min'_le _ _ <| Finset.mem_image_of_mem _ <| Finset.mem_univ _ ) ⟩

/-- Row norm: ∑ |A_{j,i}| for a single constraint row. -/
def rowNorm {n : ℕ} (c : Fin n → ℝ) : ℝ := ∑ i, |c i|

/-
**Polyhedral Membership Stability** (explicit quantitative version):
Provides an explicit stability radius.
-/
theorem polyhedral_membership_stable_explicit {n k : ℕ} (hk : 0 < k)
    (A : Fin k → Fin n → ℝ) (b : Fin k → ℝ)
    (x : Fin n → ℝ)
    (hinside : inPolyhedron A b x)
    (hslack : ∀ j, 0 < polySlack A b x j) :
    let _ : Nonempty (Fin k) := Fin.pos_iff_nonempty.mp hk
    let ε := Finset.univ.inf' Finset.univ_nonempty
        (fun j => polySlack A b x j / (rowNorm (A j) + 1))
    0 < ε ∧ ∀ y : Fin n → ℝ,
      (∀ i, |y i - x i| < ε) →
      inPolyhedron A b y := by
  refine' ⟨ _, fun y hy j => _ ⟩;
  · simp +zetaDelta at *;
    exact fun j => div_pos ( hslack j ) ( add_pos_of_nonneg_of_pos ( Finset.sum_nonneg fun _ _ => abs_nonneg _ ) zero_lt_one );
  · -- By definition of $ε$, we know that for all $i$, $|y i - x i| < ε$.
    have h_eps : ∀ i, |y i - x i| < polySlack A b x j / (rowNorm (A j) + 1) := by
      exact fun i => lt_of_lt_of_le ( hy i ) ( Finset.inf'_le _ ( Finset.mem_univ _ ) );
    -- By definition of $ε$, we know that for all $i$, $|y i - x i| < ε$ implies $|affineForm (A j) y - affineForm (A j) x| ≤ ε * rowNorm (A j)$.
    have h_affineForm : |affineForm (A j) y - affineForm (A j) x| ≤ polySlack A b x j / (rowNorm (A j) + 1) * rowNorm (A j) := by
      convert affineForm_perturbation_bound ( A j ) x y ( polySlack A b x j / ( rowNorm ( A j ) + 1 ) ) ( div_pos ( hslack j ) ( add_pos_of_nonneg_of_pos ( Finset.sum_nonneg fun _ _ => abs_nonneg _ ) zero_lt_one ) ) h_eps using 1;
    unfold polySlack at *;
    nlinarith [ abs_le.mp h_affineForm, hslack j, show 0 ≤ rowNorm ( A j ) from Finset.sum_nonneg fun _ _ => abs_nonneg _, mul_div_cancel₀ ( b j - affineForm ( A j ) x ) ( show ( rowNorm ( A j ) + 1 ) ≠ 0 from by linarith [ show 0 ≤ rowNorm ( A j ) from Finset.sum_nonneg fun _ _ => abs_nonneg _ ] ) ]

/-! ## Part IV: Synthesis — Kinetic Polyhedral Stability

Combined theorem: if a point is in the interior of a polyhedron and moves
along a bounded-speed path, the point remains inside for an explicit time horizon. -/

/-
**Kinetic Polyhedral Stability**: If a point is in the strict interior of a polyhedron
and moves along a linear path, membership is preserved for an explicit time interval.
This combines polyhedral certification with kinetic stability.
-/
theorem kinetic_polyhedral_stability {n k : ℕ} (hk : 0 < k)
    (A : Fin k → Fin n → ℝ) (b : Fin k → ℝ)
    (x0 v : Fin n → ℝ)
    (hinside : inPolyhedron A b x0)
    (hslack : ∀ j, 0 < polySlack A b x0 j) :
    ∃ ε > 0, ∀ t : ℝ, |t| < ε →
      inPolyhedron A b (linePath x0 v t) := by
  obtain ⟨ δ, hδ_pos, hδ ⟩ := polyhedral_membership_stable A b x0 hinside hslack;
  refine' ⟨ δ / ( ∑ i, |v i| + 1 ), div_pos hδ_pos ( add_pos_of_nonneg_of_pos ( Finset.sum_nonneg fun _ _ => abs_nonneg _ ) zero_lt_one ), fun t ht => hδ _ fun i => _ ⟩;
  rw [ lt_div_iff₀ ] at ht <;> try linarith [ show 0 ≤ ∑ i, |v i| from Finset.sum_nonneg fun _ _ => abs_nonneg _ ];
  exact lt_of_le_of_lt ( by simpa [ abs_mul, linePath ] using mul_le_mul_of_nonneg_left ( Finset.single_le_sum ( fun i _ => abs_nonneg ( v i ) ) ( Finset.mem_univ i ) ) ( abs_nonneg t ) ) ( lt_of_le_of_lt ( mul_le_mul_of_nonneg_left ( le_add_of_nonneg_right zero_le_one ) ( abs_nonneg t ) ) ht )

end