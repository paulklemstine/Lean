/-
# Tropical Width Collapse and Cycle-Mean Rigidity

## Main Results

We prove the **Tropical Cycle-Mean Rigidity Theorem**: for a real-valued matrix
viewed in max-plus convention, the following are equivalent:

1. **All cycle means equal** — every directed cycle has the same mean weight.
2. **Cohomologous to a constant** — there exist `μ : ℝ` and `p : Fin n → ℝ` such that
   `A i j = μ + p i - p j` for all `i, j`.

This is a genuine rigidity theorem connecting tropical spectral theory to discrete
gauge theory and graph cohomology. The coboundary decomposition `A i j = μ + p i - p j`
is a discrete gauge trivialization: equal cycle means means the "curvature" of the
edge-weight 1-cocycle vanishes, forcing exactness.

## Supporting Results

- `vecWidth_eq_zero_iff`: Width zero iff the vector is constant.
- `tropEigenpair_of_cohomologousToConst`: The potential `p` is automatically a tropical
  eigenvector with eigenvalue `μ`.
- `eigenvector_unique_of_cohomologousToConst`: Under the coboundary form, eigenvectors
  for eigenvalue `μ` are unique up to an additive constant.
- `width_zero_eigenpair_iff_row_maxima_equal`: Width-zero eigenpairs exist iff all row
  maxima coincide — an independent condition from cycle-mean equality.
- `constant_matrix_iff_width_zero_and_cycle_means`: The conjunction of width-zero
  eigenvector existence AND all cycle means equal characterizes constant matrices.

## Remark on the Originally Conjectured Equivalence

The original conjecture was that "width-zero eigenvector exists ↔ all cycle means equal."
This is **false** in general:

- **Counterexample (→ fails):** `A = [[2,1],[1,2]]` has all row maxima = 2
  (so a width-zero eigenvector exists with eigenvalue 2), but cycle means are
  2 (self-loops) vs 1 (two-cycle), which are not all equal.

- **Counterexample (← fails):** `A = [[0,1],[-1,0]]` is cohomologous to constant
  (μ=0, p=(0,-1)) so all cycle means = 0, but row maxima are 1 and 0 (unequal),
  so no width-zero eigenvector exists.

The correct characterizations are:
- Width-zero eigenvector exists ↔ all row maxima are equal.
- All cycle means equal ↔ cohomologous to a constant.
These are **independent** conditions. Their conjunction characterizes constant matrices.
-/
import Mathlib

open Finset

noncomputable section

variable {n : ℕ}

/-! ## Vector Width -/

/-- The width of a vector: max coordinate minus min coordinate.
    This measures the "tropical projective diameter" of the vector. -/
def vecWidth (x : Fin n → ℝ) (hne : Nonempty (Fin n)) : ℝ :=
  Finset.univ.sup' univ_nonempty x - Finset.univ.inf' univ_nonempty x

/-- Width is always nonnegative. -/
lemma vecWidth_nonneg (x : Fin n → ℝ) (hne : Nonempty (Fin n)) :
    0 ≤ vecWidth x hne := by
  unfold vecWidth
  obtain ⟨i⟩ := hne
  linarith [Finset.inf'_le (f := x) (Finset.mem_univ i),
            Finset.le_sup' (f := x) (Finset.mem_univ i)]

/-- **Width-Zero Characterization.** A vector has width zero if and only if it is constant. -/
theorem vecWidth_eq_zero_iff (x : Fin n → ℝ) (hne : Nonempty (Fin n)) :
    vecWidth x hne = 0 ↔ ∃ c : ℝ, ∀ i : Fin n, x i = c := by
  constructor
  · unfold vecWidth
    exact fun h => ⟨Finset.inf' Finset.univ Finset.univ_nonempty x, fun i => by
      linarith [Finset.le_sup' x (Finset.mem_univ i),
                Finset.inf'_le x (Finset.mem_univ i)]⟩
  · simp [vecWidth]
    intro c hc
    simp +decide [hc, Finset.sup'_eq_csSup_image, Finset.inf'_eq_csInf_image]

/-! ## Tropical Matrix-Vector Product and Eigenpairs -/

/-- Tropical matrix-vector product (max-plus): `(A ⊙ x)_i = max_j (A i j + x j)`. -/
def tropMatVec (A : Fin n → Fin n → ℝ) (x : Fin n → ℝ)
    (hne : Nonempty (Fin n)) : Fin n → ℝ :=
  fun i => Finset.univ.sup' univ_nonempty (fun j => A i j + x j)

/-- A tropical eigenpair: `A ⊙ x = λ + x` coordinatewise. -/
def TropEigenpair (A : Fin n → Fin n → ℝ) (eigenval : ℝ) (x : Fin n → ℝ)
    (hne : Nonempty (Fin n)) : Prop :=
  ∀ i, tropMatVec A x hne i = eigenval + x i

/-! ## Cycle Weight and Cycle Mean -/

/-- Weight along consecutive edges of a list (not closing the cycle). -/
def pathWeight (A : Fin n → Fin n → ℝ) : List (Fin n) → ℝ
  | [] => 0
  | [_] => 0
  | a :: b :: rest => A a b + pathWeight A (b :: rest)

/-- Weight of a directed cycle given as a nonempty list `[i₀, i₁, …, i_{k-1}]`.
    Equals `A(i₀,i₁) + A(i₁,i₂) + ⋯ + A(i_{k-1},i₀)`. -/
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

/-- All directed cycles have the same mean weight. This is the combinatorial
    certificate for spectral flatness in tropical geometry. -/
def AllCycleMeansEqual (A : Fin n → Fin n → ℝ) : Prop :=
  ∃ μ : ℝ, ∀ l : List (Fin n), l ≠ [] → cycleMean A l = μ

/-- A is cohomologous to a constant: `∃ μ p, ∀ i j, A i j = μ + p i − p j`.
    This is a discrete gauge trivialization — the edge weights are an exact 1-coboundary
    plus a uniform shift. -/
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

/-- If A is cohomologous to const, path weights telescope. -/
lemma pathWeight_cohomologous (A : Fin n → Fin n → ℝ)
    (μ : ℝ) (p : Fin n → ℝ)
    (hA : ∀ i j, A i j = μ + p i - p j)
    : ∀ (l : List (Fin n)) (hl : l ≠ []),
      pathWeight A l = μ * (l.length - 1) + p (l.head hl) - p (l.getLast hl) := by
  intro l hlempty
  induction' l with a l ih
  · contradiction
  · rcases l with (_ | ⟨b, l⟩) <;> simp_all +decide
    grind

/-- Cycle weight under coboundary decomposition telescopes to `k * μ`. -/
lemma cycleWeight_cohomologous (A : Fin n → Fin n → ℝ)
    (μ : ℝ) (p : Fin n → ℝ)
    (hA : ∀ i j, A i j = μ + p i - p j)
    (l : List (Fin n)) (hl : l ≠ []) :
    cycleWeight A l = μ * l.length := by
  induction' l with hd tl ih <;> simp_all +decide [List.getLast]; ring
  rcases tl with (_ | ⟨a, _ | ⟨b, tl⟩⟩) <;> simp_all +decide [cycleWeight]; ring
  linarith

/-- **Forward direction of the Rigidity Theorem.**
    Coboundary form implies all cycle means equal the gauge constant `μ`. -/
theorem allCycleMeansEqual_of_cohomologousToConst (A : Fin n → Fin n → ℝ)
    (hcoh : CohomologousToConst A) :
    AllCycleMeansEqual A := by
  obtain ⟨μ, p, hA⟩ := hcoh
  use μ
  intro l hl
  rw [cycleMean, cycleWeight_cohomologous A μ p hA l hl,
      mul_div_cancel_right₀ _ (by aesop)]

/-! ## Converse: AllCycleMeansEqual → CohomologousToConst -/

/-- If all cycle means equal `μ`, then every 2-cycle sums to `2μ`. -/
lemma sum_pair_eq (A : Fin n → Fin n → ℝ) (μ : ℝ)
    (hμ : ∀ l : List (Fin n), l ≠ [] → cycleMean A l = μ)
    (i j : Fin n) :
    A i j + A j i = 2 * μ := by
  have := hμ [i, j] ?_ <;> norm_num [cycleMean] at *
  · convert congr_arg (· * 2) this using 1; ring!
    · exact Eq.symm (cycleWeight_pair A i j)
    · ring
  · grind

/-- If all cycle means equal `μ`, then every 3-cycle sums to `3μ`. -/
lemma sum_triple_eq (A : Fin n → Fin n → ℝ) (μ : ℝ)
    (hμ : ∀ l : List (Fin n), l ≠ [] → cycleMean A l = μ)
    (i j k : Fin n) :
    A i j + A j k + A k i = 3 * μ := by
  have := hμ [i, j, k]; simp_all +decide [cycleMean, cycleWeight_triple]
  linarith

/-- **Converse direction of the Rigidity Theorem.**
    Equal cycle means force a coboundary decomposition.
    The proof constructs the potential `p(i) = A(i, r) - μ` for a fixed base vertex `r`,
    then uses the 2-cycle and 3-cycle identities to verify `A(i,j) = μ + p(i) - p(j)`. -/
theorem cohomologousToConst_of_allCycleMeansEqual (A : Fin n → Fin n → ℝ)
    (hn : 0 < n)
    (hA : AllCycleMeansEqual A) :
    CohomologousToConst A := by
  obtain ⟨μ, hμ⟩ := hA
  set r : Fin n := ⟨0, hn⟩
  set p : Fin n → ℝ := fun i => A i r - μ
  use μ, p
  intro i j
  have := sum_triple_eq A μ hμ i j r
  have := sum_pair_eq A μ hμ i r
  have := sum_pair_eq A μ hμ j r
  norm_num at *; linarith

/-! ## Main Equivalence: The Tropical Cycle-Mean Rigidity Theorem -/

/-- **Tropical Cycle-Mean Rigidity Theorem.**
    A matrix has all cycle means equal if and only if it is cohomologous to a constant.
    This is the tropical analogue of the classical fact that a 1-cocycle on a graph
    is exact (a coboundary) iff it integrates to zero around every cycle.
    The common cycle mean `μ` becomes the gauge constant,
    and the potential `p` is the gauge field. -/
theorem allCycleMeansEqual_iff_cohomologousToConst
    (A : Fin n → Fin n → ℝ) (hn : 0 < n) :
    AllCycleMeansEqual A ↔ CohomologousToConst A :=
  ⟨cohomologousToConst_of_allCycleMeansEqual A hn,
   allCycleMeansEqual_of_cohomologousToConst A⟩

/-! ## Eigenvector from Coboundary -/

/-- **Eigenvector from gauge potential.** If `A i j = μ + p i - p j`, then `p` is
    automatically a tropical eigenvector with eigenvalue `μ`. -/
theorem tropEigenpair_of_cohomologousToConst (A : Fin n → Fin n → ℝ)
    (hne : Nonempty (Fin n))
    (μ : ℝ) (p : Fin n → ℝ)
    (hA : ∀ i j, A i j = μ + p i - p j) :
    TropEigenpair A μ p hne := by
  intro i
  exact le_antisymm
    (Finset.sup'_le _ _ fun j _ => by norm_num [tropMatVec, hA])
    (Finset.le_sup' (fun j => A i j + p j) (Finset.mem_univ i)
      |> le_trans (by norm_num [tropMatVec, hA]))

/-- Coboundary form implies existence of a tropical eigenpair. -/
theorem tropEigenpair_exists_of_cohomologousToConst (A : Fin n → Fin n → ℝ)
    (hne : Nonempty (Fin n))
    (hcoh : CohomologousToConst A) :
    ∃ eigenval x, TropEigenpair A eigenval x hne := by
  obtain ⟨μ, p, hA⟩ := hcoh
  exact ⟨μ, p, tropEigenpair_of_cohomologousToConst A hne μ p hA⟩

/-! ## Eigenvector Uniqueness under Coboundary Form -/

/-- **Eigenvector uniqueness.** Under the coboundary form `A i j = μ + p i - p j`,
    every tropical eigenvector for eigenvalue `μ` differs from `p` by a constant.
    This is tropical projective uniqueness: the eigenspace is a single projective class. -/
theorem eigenvector_unique_of_cohomologousToConst (A : Fin n → Fin n → ℝ)
    (hne : Nonempty (Fin n))
    (μ : ℝ) (p x : Fin n → ℝ)
    (hA : ∀ i j, A i j = μ + p i - p j)
    (hx : TropEigenpair A μ x hne) :
    ∃ c : ℝ, ∀ i, x i = p i + c := by
  obtain ⟨i₀⟩ := hne
  use x i₀ - p i₀
  intro i
  have key : ∀ j k, x j - p j ≤ x k - p k := by
    intro j k
    have hk := hx k
    simp only [tropMatVec] at hk
    have hle := Finset.le_sup' (fun j => A k j + x j) (Finset.mem_univ j)
    rw [hA k j] at hle
    linarith [hle, le_of_eq hk]
  linarith [key i i₀, key i₀ i]

/-! ## Width and Eigenvectors -/

/-- A tropical eigenvector with width zero must be constant. -/
theorem width_zero_eigenvec_const (A : Fin n → Fin n → ℝ) (hne : Nonempty (Fin n))
    (eigenval : ℝ) (x : Fin n → ℝ)
    (_heig : TropEigenpair A eigenval x hne) (hw : vecWidth x hne = 0) :
    ∃ c : ℝ, ∀ i, x i = c :=
  (vecWidth_eq_zero_iff x hne).mp hw

/-- When `A = μ + p(i) − p(j)` and the potential `p` has width zero,
    all entries of `A` equal `μ` (the matrix is constant). -/
theorem constant_matrix_of_cohomologous_width_zero (A : Fin n → Fin n → ℝ)
    (hne : Nonempty (Fin n))
    (μ : ℝ) (p : Fin n → ℝ)
    (hA : ∀ i j, A i j = μ + p i - p j)
    (hw : vecWidth p hne = 0) :
    ∀ i j, A i j = μ := by
  rw [vecWidth_eq_zero_iff] at hw
  aesop

/-- If `A` is a constant matrix (all entries = `μ`), any constant vector
    is a width-zero eigenvector. -/
theorem width_zero_eigenpair_of_constant_matrix (A : Fin n → Fin n → ℝ)
    (hne : Nonempty (Fin n)) (μ : ℝ)
    (hA : ∀ i j, A i j = μ) :
    ∃ x, TropEigenpair A μ x hne ∧ vecWidth x hne = 0 := by
  use fun _ => 0
  refine ⟨?_, ?_⟩
  · intro i; simp +decide [*, tropMatVec]
  · exact vecWidth_eq_zero_iff _ hne |>.2 ⟨0, fun _ => rfl⟩

/-- **Width-zero eigenpair characterization.**
    A width-zero eigenvector exists iff all row maxima are equal. -/
theorem width_zero_eigenpair_iff_row_maxima_equal (A : Fin n → Fin n → ℝ)
    (hne : Nonempty (Fin n)) :
    (∃ eigenval x, TropEigenpair A eigenval x hne ∧ vecWidth x hne = 0) ↔
    ∃ μ : ℝ, ∀ i : Fin n, Finset.univ.sup' univ_nonempty (fun j => A i j) = μ := by
  constructor
  · rintro ⟨eigenval, x, hx, hx'⟩
    obtain ⟨c, hc⟩ := vecWidth_eq_zero_iff x hne |>.1 hx'
    use eigenval + c - c; intro i; specialize hx i
    simp_all +decide [TropEigenpair, tropMatVec]
    convert congr_arg (fun x => x - c) hx using 1 <;> norm_num [Finset.sup'_add]
    refine le_antisymm ?_ ?_ <;> simp +decide [Finset.sup'_le_iff, Finset.le_sup']
    · exact fun j =>
        le_tsub_of_add_le_right <|
          Finset.le_sup' (fun x => A i x + c) <| Finset.mem_univ j
    · simpa using Finset.exists_max_image Finset.univ (fun j => A i j) ⟨i, Finset.mem_univ i⟩
  · rintro ⟨μ, hμ⟩
    use μ, fun _ => 0
    unfold TropEigenpair vecWidth tropMatVec
    aesop

/-! ## Constant Matrix Characterization -/

/-
If all row maxima equal `μ` and `A i j = μ + p i - p j` for all `i, j`,
    then `p` is constant.
-/
lemma potential_const_of_row_max_and_coboundary
    (A : Fin n → Fin n → ℝ) (hne : Nonempty (Fin n))
    (mu lam : ℝ) (p : Fin n → ℝ)
    (hA : ∀ i j, A i j = mu + p i - p j)
    (hrow : ∀ i, Finset.univ.sup' univ_nonempty (fun j => A i j) = lam) :
    ∃ c : ℝ, ∀ i, p i = c := by
      simp_all +decide [ Finset.sup'_eq_sup, Finset.inf'_eq_inf ];
      -- We can rewrite the sup'_eq_sup condition using the definition of A.
      have h_sup_eq : ∀ i, (mu + p i - (Finset.univ.inf' (Finset.univ_nonempty) (fun j => p j))) = lam := by
        convert hrow using 2;
        refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_sup' ];
        · exact ⟨ Classical.choose ( Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun j => p j ) ), by linarith [ Classical.choose_spec ( Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun j => p j ) ) ] ⟩;
        · exact fun j => by linarith [ Finset.inf'_le ( fun j => p j ) ( Finset.mem_univ j ) ] ;
      exact ⟨ lam - mu + Finset.univ.inf' ( Finset.univ_nonempty ) ( fun j => p j ), fun i => by linear_combination h_sup_eq i ⟩

/-- **Constant Matrix Characterization.** A matrix is constant (all entries equal)
    iff it admits a width-zero eigenvector AND all cycle means are equal.
    This is the conjunction of the two independent rigidity conditions. -/
theorem constant_matrix_iff_width_zero_and_cycle_means (A : Fin n → Fin n → ℝ)
    (hn : 0 < n)
    (hne : Nonempty (Fin n) := Fin.pos_iff_nonempty.mp hn) :
    (∃ μ : ℝ, ∀ i j, A i j = μ) ↔
    (∃ eigenval x, TropEigenpair A eigenval x hne ∧ vecWidth x hne = 0) ∧
    AllCycleMeansEqual A := by
  constructor
  · rintro ⟨μ, hconst⟩
    exact ⟨⟨μ, fun _ => 0,
            fun i => by simp +decide [tropMatVec, hconst],
            (vecWidth_eq_zero_iff _ hne).mpr ⟨0, fun _ => rfl⟩⟩,
           allCycleMeansEqual_of_cohomologousToConst A ⟨μ, fun _ => 0, by simp [hconst]⟩⟩
  · rintro ⟨⟨eigenval, x, hx, hw⟩, hcyc⟩
    obtain ⟨μ, p, hA⟩ := (allCycleMeansEqual_iff_cohomologousToConst A hn).mp hcyc
    -- From width zero: row maxima all equal eigenval
    have hrow_ex := (width_zero_eigenpair_iff_row_maxima_equal A hne).mp ⟨eigenval, x, hx, hw⟩
    obtain ⟨rm, hrm⟩ := hrow_ex
    -- All row maxima equal rm. From eigenpair: rm = eigenval.
    have hrow : ∀ i, Finset.univ.sup' univ_nonempty (fun j => A i j) = rm := hrm
    -- From coboundary + equal row maxima: potential p is constant
    obtain ⟨cp, hcp⟩ := potential_const_of_row_max_and_coboundary A hne μ rm p hA hrow
    use μ
    intro i j
    rw [hA i j, hcp i, hcp j]; ring

/-! ## Combined Rigidity Summary -/

/-- **Tropical Rigidity Summary.** Assembles the main results into a single theorem. -/
theorem tropical_rigidity_summary (A : Fin n → Fin n → ℝ) (hn : 0 < n)
    (hne : Nonempty (Fin n) := Fin.pos_iff_nonempty.mp hn) :
    -- Part 1: Cycle-mean rigidity (THE main theorem)
    (AllCycleMeansEqual A ↔ CohomologousToConst A) ∧
    -- Part 2: Coboundary form guarantees an eigenpair
    (CohomologousToConst A → ∃ eigenval x, TropEigenpair A eigenval x hne) ∧
    -- Part 3: Width-zero eigenpairs ↔ equal row maxima
    ((∃ eigenval x, TropEigenpair A eigenval x hne ∧ vecWidth x hne = 0) ↔
      ∃ μ, ∀ i, Finset.univ.sup' univ_nonempty (fun j => A i j) = μ) ∧
    -- Part 4: Constant matrix = width-zero eigenpair + all cycle means equal
    ((∃ μ : ℝ, ∀ i j, A i j = μ) ↔
      (∃ eigenval x, TropEigenpair A eigenval x hne ∧ vecWidth x hne = 0) ∧
      AllCycleMeansEqual A) :=
  ⟨allCycleMeansEqual_iff_cohomologousToConst A hn,
   tropEigenpair_exists_of_cohomologousToConst A hne,
   width_zero_eigenpair_iff_row_maxima_equal A hne,
   constant_matrix_iff_width_zero_and_cycle_means A hn⟩

end