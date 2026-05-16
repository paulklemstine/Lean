/-
# Tropical Width Collapse and Cycle-Mean Rigidity

We prove that for a real matrix viewed in max-plus convention, the following are equivalent:
1. All directed cycles have the same mean weight ("all cycle means equal").
2. The matrix admits a coboundary decomposition A(i,j) = μ + p(i) - p(j)
   ("cohomologous to a constant").

This is a genuine rigidity theorem: the cycle-mean equality is a combinatorial
certificate for the algebraic normal form of the matrix. It connects tropical
spectral theory to discrete gauge theory / graph cohomology.

We also prove supporting results about tropical eigenpairs, vector width,
and the relationship between coboundary form and eigenvector structure.
-/
import Mathlib

open Finset

noncomputable section

variable {n : ℕ}

/-! ## Vector Width -/

/-- The width of a vector: max coordinate minus min coordinate. -/
def vecWidth (x : Fin n → ℝ) (hne : Nonempty (Fin n)) : ℝ :=
  Finset.univ.sup' univ_nonempty x - Finset.univ.inf' univ_nonempty x

/-- Width is always nonneg. -/
lemma vecWidth_nonneg (x : Fin n → ℝ) (hne : Nonempty (Fin n)) :
    0 ≤ vecWidth x hne := by
  unfold vecWidth
  obtain ⟨i⟩ := hne
  linarith [Finset.inf'_le (f := x) (Finset.mem_univ i),
            Finset.le_sup' (f := x) (Finset.mem_univ i)]

/-
Width zero iff the vector is constant.
-/
theorem vecWidth_eq_zero_iff (x : Fin n → ℝ) (hne : Nonempty (Fin n)) :
    vecWidth x hne = 0 ↔ ∃ c : ℝ, ∀ i : Fin n, x i = c := by
  constructor;
  · unfold vecWidth;
    exact fun h => ⟨ Finset.inf' Finset.univ Finset.univ_nonempty x, fun i => by linarith [ Finset.le_sup' x ( Finset.mem_univ i ), Finset.inf'_le x ( Finset.mem_univ i ) ] ⟩;
  · simp [vecWidth];
    intro c hc; simp +decide [ hc, Finset.sup'_eq_csSup_image, Finset.inf'_eq_csInf_image ] ;

/-! ## Tropical Matrix-Vector Product and Eigenpairs -/

/-- Tropical matrix-vector product (max-plus): (A ⊙ x)_i = max_j (A i j + x j). -/
def tropMatVec (A : Fin n → Fin n → ℝ) (x : Fin n → ℝ)
    (hne : Nonempty (Fin n)) : Fin n → ℝ :=
  fun i => Finset.univ.sup' univ_nonempty (fun j => A i j + x j)

/-- A tropical eigenpair: A ⊙ x = λ + x coordinatewise. -/
def TropEigenpair (A : Fin n → Fin n → ℝ) (eigenval : ℝ) (x : Fin n → ℝ)
    (hne : Nonempty (Fin n)) : Prop :=
  ∀ i, tropMatVec A x hne i = eigenval + x i

/-! ## Cycle Weight and Cycle Mean -/

/-- Weight along consecutive edges of a list (not closing the cycle). -/
def pathWeight (A : Fin n → Fin n → ℝ) : List (Fin n) → ℝ
  | [] => 0
  | [_] => 0
  | a :: b :: rest => A a b + pathWeight A (b :: rest)

/-- Weight of a directed cycle given as a nonempty list [i₀, i₁, …, i_{k-1}].
    Equals A(i₀,i₁) + A(i₁,i₂) + ⋯ + A(i_{k-1},i₀). -/
def cycleWeight (A : Fin n → Fin n → ℝ) : List (Fin n) → ℝ
  | [] => 0
  | [a] => A a a
  | a :: b :: rest =>
    A a b + pathWeight A (b :: rest) +
      A ((a :: b :: rest).getLast (by simp)) a

/-- Mean weight of a directed cycle. -/
def cycleMean (A : Fin n → Fin n → ℝ) (l : List (Fin n)) : ℝ :=
  cycleWeight A l / l.length

/-! ## Key Predicates -/

/-- All directed cycles have the same mean weight. -/
def AllCycleMeansEqual (A : Fin n → Fin n → ℝ) : Prop :=
  ∃ μ : ℝ, ∀ l : List (Fin n), l ≠ [] → cycleMean A l = μ

/-- A is cohomologous to a constant: ∃ μ p, ∀ i j, A i j = μ + p i − p j. -/
def CohomologousToConst (A : Fin n → Fin n → ℝ) : Prop :=
  ∃ μ : ℝ, ∃ p : Fin n → ℝ, ∀ i j, A i j = μ + p i - p j

/-! ## Computational Lemmas for Cycle Weights -/

@[simp]
lemma pathWeight_nil (A : Fin n → Fin n → ℝ) : pathWeight A [] = 0 := rfl

@[simp]
lemma pathWeight_singleton (A : Fin n → Fin n → ℝ) (a : Fin n) :
    pathWeight A [a] = 0 := rfl

@[simp]
lemma pathWeight_cons₂ (A : Fin n → Fin n → ℝ) (a b : Fin n) (rest : List (Fin n)) :
    pathWeight A (a :: b :: rest) = A a b + pathWeight A (b :: rest) := rfl

@[simp]
lemma cycleWeight_nil (A : Fin n → Fin n → ℝ) : cycleWeight A [] = 0 := rfl

lemma cycleWeight_singleton (A : Fin n → Fin n → ℝ) (a : Fin n) :
    cycleWeight A [a] = A a a := rfl

lemma cycleWeight_pair (A : Fin n → Fin n → ℝ) (a b : Fin n) :
    cycleWeight A [a, b] = A a b + A b a := by
  unfold cycleWeight; simp [pathWeight, List.getLast_cons]

lemma cycleWeight_triple (A : Fin n → Fin n → ℝ) (a b c : Fin n) :
    cycleWeight A [a, b, c] = A a b + A b c + A c a := by
  unfold cycleWeight; simp [pathWeight, List.getLast_cons]

lemma cycleMean_singleton (A : Fin n → Fin n → ℝ) (a : Fin n) :
    cycleMean A [a] = A a a := by simp [cycleMean, cycleWeight_singleton]

lemma cycleMean_pair (A : Fin n → Fin n → ℝ) (a b : Fin n) :
    cycleMean A [a, b] = (A a b + A b a) / 2 := by
  unfold cycleMean; rw [cycleWeight_pair]; simp

lemma cycleMean_triple (A : Fin n → Fin n → ℝ) (a b c : Fin n) :
    cycleMean A [a, b, c] = (A a b + A b c + A c a) / 3 := by
  unfold cycleMean; rw [cycleWeight_triple]; simp

/-! ## Telescoping: CohomologousToConst → AllCycleMeansEqual -/

/-
If A is cohomologous to const, the path weight telescopes:
    pathWeight A [v₀, v₁, ..., v_{k-1}] = (k-1)·μ + p(v₀) - p(v_{k-1}).
-/
lemma pathWeight_cohomologous (A : Fin n → Fin n → ℝ)
    (μ : ℝ) (p : Fin n → ℝ)
    (hA : ∀ i j, A i j = μ + p i - p j)
    : ∀ (l : List (Fin n)) (hl : l ≠ []),
      pathWeight A l = μ * (l.length - 1) + p (l.head hl) - p (l.getLast hl) := by
  intro l hlempty
  induction' l with a l ih;
  · contradiction;
  · rcases l with ( _ | ⟨ b, l ⟩ ) <;> simp_all +decide;
    grind

/-
Cycle weight under coboundary = k * μ (telescoping).
-/
lemma cycleWeight_cohomologous (A : Fin n → Fin n → ℝ)
    (μ : ℝ) (p : Fin n → ℝ)
    (hA : ∀ i j, A i j = μ + p i - p j)
    (l : List (Fin n)) (hl : l ≠ []) :
    cycleWeight A l = μ * l.length := by
  induction' l with hd tl ih <;> simp_all +decide [ List.getLast ] ; ring;
  rcases tl with ( _ | ⟨ a, _ | ⟨ b, tl ⟩ ⟩ ) <;> simp_all +decide [ cycleWeight ] ; ring;
  linarith

/-
Coboundary implies all cycle means equal.
-/
theorem allCycleMeansEqual_of_cohomologousToConst (A : Fin n → Fin n → ℝ)
    (hcoh : CohomologousToConst A) :
    AllCycleMeansEqual A := by
  -- Use the obtained μ, p from hcoh.
  obtain ⟨μ, p, hA⟩ := hcoh;
  use μ;
  intro l hl;
  rw [ cycleMean, cycleWeight_cohomologous A μ p hA l hl, mul_div_cancel_right₀ _ ( by aesop ) ]

/-! ## Converse: AllCycleMeansEqual → CohomologousToConst -/

/-
If all cycle means equal μ, then A(i,j) + A(j,i) = 2μ.
-/
lemma sum_pair_eq (A : Fin n → Fin n → ℝ) (μ : ℝ)
    (hμ : ∀ l : List (Fin n), l ≠ [] → cycleMean A l = μ)
    (i j : Fin n) :
    A i j + A j i = 2 * μ := by
  have := hμ [ i, j ] ?_ <;> norm_num [ cycleMean ] at *;
  · convert congr_arg ( · * 2 ) this using 1 ; ring!;
    · exact?;
    · ring;
  · grind

/-
If all cycle means equal μ, then A(i,j) + A(j,k) + A(k,i) = 3μ.
-/
lemma sum_triple_eq (A : Fin n → Fin n → ℝ) (μ : ℝ)
    (hμ : ∀ l : List (Fin n), l ≠ [] → cycleMean A l = μ)
    (i j k : Fin n) :
    A i j + A j k + A k i = 3 * μ := by
  have := hμ [ i, j, k ] ; simp_all +decide [ cycleMean, cycleWeight_triple ];
  linarith

/-
From cycle identities, derive the coboundary decomposition.
    Define p(i) = A(i, 0) − μ and show A(i,j) = μ + p(i) − p(j).
-/
theorem cohomologousToConst_of_allCycleMeansEqual (A : Fin n → Fin n → ℝ)
    (hn : 0 < n)
    (hA : AllCycleMeansEqual A) :
    CohomologousToConst A := by
  obtain ⟨ μ, hμ ⟩ := hA;
  -- Define base vertex r := ⟨0, hn⟩ : Fin n. Define p : Fin n → ℝ by p i := A i r - μ.
  set r : Fin n := ⟨0, hn⟩
  set p : Fin n → ℝ := fun i => A i r - μ;
  use μ, p;
  intro i j; have := sum_triple_eq A μ hμ i j r; have := sum_pair_eq A μ hμ i r; have := sum_pair_eq A μ hμ j r; norm_num at *; linarith;

/-! ## Main Equivalence -/

/-- **Tropical Cycle-Mean Rigidity Theorem.**
    A matrix has all cycle means equal if and only if it is cohomologous to a constant.
    Equivalently, the cycle geometry is spectrally flat iff a discrete gauge trivialization
    exists. -/
theorem allCycleMeansEqual_iff_cohomologousToConst
    (A : Fin n → Fin n → ℝ) (hn : 0 < n) :
    AllCycleMeansEqual A ↔ CohomologousToConst A :=
  ⟨cohomologousToConst_of_allCycleMeansEqual A hn,
   allCycleMeansEqual_of_cohomologousToConst A⟩

/-! ## Eigenvector from Coboundary -/

/-
If A is cohomologous to const with potential p, then p is a tropical eigenvector.
-/
theorem tropEigenpair_of_cohomologousToConst (A : Fin n → Fin n → ℝ)
    (hne : Nonempty (Fin n))
    (μ : ℝ) (p : Fin n → ℝ)
    (hA : ∀ i j, A i j = μ + p i - p j) :
    TropEigenpair A μ p hne := by
  intro i;
  exact le_antisymm ( Finset.sup'_le _ _ fun j _ => by norm_num [ tropMatVec, hA ] ) ( Finset.le_sup' ( fun j => A i j + p j ) ( Finset.mem_univ i ) |> le_trans ( by norm_num [ tropMatVec, hA ] ) )

/-- Coboundary form implies existence of a tropical eigenpair. -/
theorem tropEigenpair_exists_of_cohomologousToConst (A : Fin n → Fin n → ℝ)
    (hne : Nonempty (Fin n))
    (hcoh : CohomologousToConst A) :
    ∃ eigenval x, TropEigenpair A eigenval x hne := by
  obtain ⟨μ, p, hA⟩ := hcoh
  exact ⟨μ, p, tropEigenpair_of_cohomologousToConst A hne μ p hA⟩

/-! ## Width and Eigenvectors -/

/-- A tropical eigenvector with width zero must be constant. -/
theorem width_zero_eigenvec_const (A : Fin n → Fin n → ℝ) (hne : Nonempty (Fin n))
    (eigenval : ℝ) (x : Fin n → ℝ)
    (_heig : TropEigenpair A eigenval x hne) (hw : vecWidth x hne = 0) :
    ∃ c : ℝ, ∀ i, x i = c :=
  (vecWidth_eq_zero_iff x hne).mp hw

/-
When A = μ + p(i) − p(j) and the potential p has width zero,
    all entries of A equal μ (the matrix is constant).
-/
theorem constant_matrix_of_cohomologous_width_zero (A : Fin n → Fin n → ℝ)
    (hne : Nonempty (Fin n))
    (μ : ℝ) (p : Fin n → ℝ)
    (hA : ∀ i j, A i j = μ + p i - p j)
    (hw : vecWidth p hne = 0) :
    ∀ i j, A i j = μ := by
  rw [ vecWidth_eq_zero_iff ] at hw;
  aesop

/-
If A is a constant matrix (all entries = μ), any constant vector
    is a width-zero eigenvector.
-/
theorem width_zero_eigenpair_of_constant_matrix (A : Fin n → Fin n → ℝ)
    (hne : Nonempty (Fin n)) (μ : ℝ)
    (hA : ∀ i j, A i j = μ) :
    ∃ x, TropEigenpair A μ x hne ∧ vecWidth x hne = 0 := by
  use fun _ => 0;
  refine' ⟨ _, _ ⟩;
  · intro i; simp +decide [ *, tropMatVec ] ;
  · exact vecWidth_eq_zero_iff _ hne |>.2 ⟨ 0, fun _ => rfl ⟩

/-
A width-zero eigenvector exists iff all row maxima are equal.
-/
theorem width_zero_eigenpair_iff_row_maxima_equal (A : Fin n → Fin n → ℝ)
    (hne : Nonempty (Fin n)) :
    (∃ eigenval x, TropEigenpair A eigenval x hne ∧ vecWidth x hne = 0) ↔
    ∃ μ : ℝ, ∀ i : Fin n, Finset.univ.sup' univ_nonempty (fun j => A i j) = μ := by
  constructor;
  · rintro ⟨ eigenval, x, hx, hx' ⟩;
    -- Since $x$ has width zero, it must be constant. Let $c$ be this constant.
    obtain ⟨ c, hc ⟩ := vecWidth_eq_zero_iff x hne |>.1 hx';
    use eigenval + c - c; intro i; specialize hx i; simp_all +decide [ TropEigenpair, tropMatVec ] ;
    convert congr_arg ( fun x => x - c ) hx using 1 <;> norm_num [ Finset.sup'_add ];
    refine' le_antisymm _ _ <;> simp +decide [ Finset.sup'_le_iff, Finset.le_sup' ];
    · exact fun j => le_tsub_of_add_le_right <| Finset.le_sup' ( fun x => A i x + c ) <| Finset.mem_univ j;
    · simpa using Finset.exists_max_image Finset.univ ( fun j => A i j ) ⟨ i, Finset.mem_univ i ⟩;
  · rintro ⟨ μ, hμ ⟩;
    use μ, fun _ => 0;
    unfold TropEigenpair vecWidth;
    unfold tropMatVec; aesop;

end