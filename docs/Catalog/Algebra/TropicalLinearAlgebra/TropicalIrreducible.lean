/-
# Tropical Perron–Frobenius with `−∞` entries

This file settles conjecture **C4** of `FUTURE_DIRECTIONS.md`.  Matrices are now
allowed genuine tropical zeros `⊥ = −∞`, i.e. `A : Matrix ι ι (WithBot ℝ)`, and an
*eigenvector* is still required to be **finite** (`v : ι → ℝ`):

  `IsTropEigenBot A lam v : ∀ i, ⨆ j (A i j + v j) = lam + v i`   (sup in `WithBot ℝ`).

Main results:

* `exists_tropEigenBot_of_stronglyConnected` — **existence**: if the support digraph
  `Supp A` (the pairs with `A i j ≠ ⊥`) is strongly connected, then `A` has a tropical
  eigenvalue with a finite eigenvector.  The proof is a *perturbation* argument: replace
  every `⊥` by a finite but very negative penalty, apply the finite-entry
  Perron–Frobenius theorem `exists_tropEigen`, normalise the eigenvector to have maximum
  `0`, and show — using short support walks — that its entries stay in a fixed compact
  interval that does not depend on the penalty.  Hence for a large enough penalty no
  optimal row entry can use a `⊥` position, and the eigenvector of the perturbed matrix
  is an eigenvector of `A` itself.
* `IsTropEigenBot.isGreatest_suppCycleMean` — the eigenvalue is exactly the maximum mean
  weight of a closed walk in the support digraph, and hence
* `tropEigenvalueBot_unique` — **uniqueness** of the eigenvalue, *without* any
  irreducibility hypothesis.
* `not_stronglyConnected_of_isTropEigenBot_false` — the converse half of C4 is **false**:
  the `2 × 2` matrix `diag(0, 0)` (with `⊥` off the diagonal) has the finite eigenvector
  `(0,0)` although its support digraph is not strongly connected.  So strong connectivity
  is sufficient but not necessary, and C4 must be weakened to the implication proved here.

Auxiliary combinatorics, of independent interest:

* `exists_short_supp_walk` — in a strongly connected digraph on `n` vertices any two
  vertices are joined by a walk of length between `1` and `n` (proved by excising
  repeated vertices);
* `IsTropEigen.pathWeight_le` — the telescoping bound `w(p) + v(p m) ≤ m·lam + v(p 0)`
  for a finite-entry eigenpair, which generalises `IsTropEigen.cycle_le`.
-/
import Mathlib
import Algebra.TropicalLinearAlgebra.TropicalPerronFrobenius

namespace TropicalLA

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-! ## Matrices over `WithBot ℝ`: support, walks, eigenpairs -/

section Defs

variable (A : Matrix ι ι (WithBot ℝ))

/-- The **support digraph** of a tropical matrix: `i → j` is an edge when `A i j ≠ ⊥`. -/
def Supp (i j : ι) : Prop := A i j ≠ ⊥

/-- `A` is **irreducible** when its support digraph is strongly connected: any two
vertices (including a vertex and itself) are joined by a walk of positive length. -/
def StronglyConnected : Prop := ∀ i j, Relation.TransGen (Supp A) i j

/-- The finite part of a tropical matrix (`⊥` entries are sent to `0`; the value there
is irrelevant, all statements below only use `finPart` on the support). -/
noncomputable def finPart : Matrix ι ι ℝ := fun i j => (A i j).unbotD 0

/-- A walk all of whose steps are edges of the support digraph. -/
def IsSuppWalk (p : ℕ → ι) (m : ℕ) : Prop := ∀ t < m, Supp A (p t) (p (t + 1))

/-- Tropical matrix–vector product with `⊥` allowed in the matrix and a finite vector. -/
noncomputable def tmulVecBot (v : ι → ℝ) : ι → WithBot ℝ :=
  fun i => Finset.univ.sup fun j => A i j + (v j : WithBot ℝ)

/-- `lam` is a tropical eigenvalue of `A` with **finite** eigenvector `v`. -/
def IsTropEigenBot (lam : ℝ) (v : ι → ℝ) : Prop :=
  ∀ i, tmulVecBot A v i = ((lam + v i : ℝ) : WithBot ℝ)

end Defs

variable {A : Matrix ι ι (WithBot ℝ)}

omit [Fintype ι] [Nonempty ι] in
theorem coe_finPart {i j : ι} (h : A i j ≠ ⊥) : ((finPart A i j : ℝ) : WithBot ℝ) = A i j := by
  obtain ⟨a, ha⟩ := WithBot.ne_bot_iff_exists.mp h
  simp [finPart, ← ha]

omit [Nonempty ι] in
/-- Criterion for an eigenpair: a uniform upper bound attained in each row. -/
theorem isTropEigenBot_of {lam : ℝ} {v : ι → ℝ}
    (hup : ∀ i j, A i j + (v j : WithBot ℝ) ≤ ((lam + v i : ℝ) : WithBot ℝ))
    (ht : ∀ i, ∃ j, A i j + (v j : WithBot ℝ) = ((lam + v i : ℝ) : WithBot ℝ)) :
    IsTropEigenBot A lam v := by
  intro i
  rw [tmulVecBot]
  refine le_antisymm (Finset.sup_le fun j _ => hup i j) ?_
  obtain ⟨j, hj⟩ := ht i
  rw [← hj]
  exact Finset.le_sup (f := fun j => A i j + (v j : WithBot ℝ)) (Finset.mem_univ j)

namespace IsTropEigenBot

variable {lam : ℝ} {v : ι → ℝ}

omit [Nonempty ι] in
theorem le_of (h : IsTropEigenBot A lam v) (i j : ι) :
    A i j + (v j : WithBot ℝ) ≤ ((lam + v i : ℝ) : WithBot ℝ) := by
  rw [← h i, tmulVecBot]
  exact Finset.le_sup (f := fun j => A i j + (v j : WithBot ℝ)) (Finset.mem_univ j)

omit [Nonempty ι] in
/-- Real form of the eigenvector inequality, along a support edge. -/
theorem real_le_of (h : IsTropEigenBot A lam v) {i j : ι} (hij : A i j ≠ ⊥) :
    finPart A i j + v j ≤ lam + v i := by
  have := h.le_of i j
  rw [← coe_finPart hij, ← WithBot.coe_add, WithBot.coe_le_coe] at this
  exact this

/-- In every row the maximum is attained, and it is attained at a support edge. -/
theorem exists_tight (h : IsTropEigenBot A lam v) (i : ι) :
    ∃ j, A i j ≠ ⊥ ∧ finPart A i j + v j = lam + v i := by
  obtain ⟨j, -, hj⟩ :=
    Finset.exists_mem_eq_sup (Finset.univ : Finset ι) Finset.univ_nonempty
      (fun j => A i j + (v j : WithBot ℝ))
  have hval : A i j + (v j : WithBot ℝ) = ((lam + v i : ℝ) : WithBot ℝ) := by
    rw [← hj]; exact h i
  have hne : A i j ≠ ⊥ := by
    intro hb
    rw [hb, WithBot.bot_add] at hval
    exact WithBot.bot_ne_coe hval
  refine ⟨j, hne, ?_⟩
  rw [← coe_finPart hne, ← WithBot.coe_add, WithBot.coe_inj] at hval
  exact hval

end IsTropEigenBot

/-! ## Short walks in a strongly connected support digraph -/

omit [Fintype ι] [Nonempty ι] in
/-- A transitive-closure witness yields a support walk of positive length. -/
theorem exists_suppWalk_of_transGen {i j : ι} (h : Relation.TransGen (Supp A) i j) :
    ∃ (m : ℕ) (p : ℕ → ι), 0 < m ∧ p 0 = i ∧ p m = j ∧ IsSuppWalk A p m := by
  induction h with
  | single hij =>
      rename_i b
      refine ⟨1, fun t => if t = 0 then i else b, one_pos, by simp, by simp, ?_⟩
      intro t ht
      interval_cases t
      simpa using hij
  | tail hab hbc ih =>
      rename_i b c
      obtain ⟨m, p, hm, hp0, hpm, hw⟩ := ih
      refine ⟨m + 1, fun t => if t ≤ m then p t else c, by omega, by simp [hp0], by simp, ?_⟩
      intro t ht
      rcases lt_or_eq_of_le (Nat.lt_succ_iff.mp ht) with h1 | h1
      · have h2 : t ≤ m := by omega
        have h3 : t + 1 ≤ m := by omega
        simpa [h2, h3] using hw t h1
      · subst h1
        have h4 : ¬ (t + 1 ≤ t) := by omega
        simp only [le_refl, if_true, h4, if_false]
        rw [hpm]
        exact hbc

omit [Nonempty ι] in
/-- **Shortening a support walk.**  Any support walk of positive length can be replaced by
one of length between `1` and `n = |ι|` with the same endpoints. -/
theorem exists_short_suppWalk_aux :
    ∀ (m : ℕ), 0 < m → ∀ p : ℕ → ι, IsSuppWalk A p m →
      ∃ (m' : ℕ) (q : ℕ → ι), 0 < m' ∧ m' ≤ Fintype.card ι ∧ q 0 = p 0 ∧ q m' = p m ∧
        IsSuppWalk A q m' := by
  intro m
  induction m using Nat.strong_induction_on with
  | _ m ih =>
    intro hm p hw
    by_cases hmn : m ≤ Fintype.card ι
    · exact ⟨m, p, hm, hmn, rfl, rfl, hw⟩
    · push_neg at hmn
      obtain ⟨a, b, hab, hbn, hpab⟩ := exists_repeat p
      have hbm : b ≤ m := le_of_lt (lt_of_le_of_lt hbn hmn)
      set d := b - a with hd
      have hd0 : 0 < d := by omega
      have hdm : d < m := by omega
      set q : ℕ → ι := fun t => if t < a then p t else p (t + d) with hq
      have hqle : ∀ t, t ≤ a → q t = p t := by
        intro t ht
        rcases lt_or_eq_of_le ht with h | h
        · simp [hq, h]
        · subst h
          simp only [hq, lt_irrefl, if_false]
          rw [show t + d = b by omega, ← hpab]
      have hqge : ∀ t, a ≤ t → q t = p (t + d) := by
        intro t ht
        rcases lt_or_eq_of_le ht with h | h
        · simp [hq, Nat.not_lt.mpr (le_of_lt h)]
        · subst h; simp [hq]
      have hq0 : q 0 = p 0 := hqle 0 (Nat.zero_le a)
      have hqend : q (m - d) = p m := by
        rw [hqge (m - d) (by omega), show m - d + d = m by omega]
      have hwq : IsSuppWalk A q (m - d) := by
        intro t ht
        rcases Nat.lt_or_ge t a with h | h
        · rw [hqle t (le_of_lt h), hqle (t + 1) (by omega)]
          exact hw t (by omega)
        · rw [hqge t h, hqge (t + 1) (by omega), show t + 1 + d = (t + d) + 1 by omega]
          exact hw (t + d) (by omega)
      obtain ⟨m', r, h1, h2, h3, h4, h5⟩ := ih (m - d) (by omega) (by omega) q hwq
      exact ⟨m', r, h1, h2, by rw [h3, hq0], by rw [h4, hqend], h5⟩

omit [Nonempty ι] in
/-- In a strongly connected support digraph any two vertices are joined by a support walk
of length between `1` and `n = |ι|`. -/
theorem exists_short_supp_walk (hSC : StronglyConnected A) (i j : ι) :
    ∃ (m : ℕ) (p : ℕ → ι), 0 < m ∧ m ≤ Fintype.card ι ∧ p 0 = i ∧ p m = j ∧
      IsSuppWalk A p m := by
  obtain ⟨m, p, hm, hp0, hpm, hw⟩ := exists_suppWalk_of_transGen (hSC i j)
  obtain ⟨m', q, h1, h2, h3, h4, h5⟩ := exists_short_suppWalk_aux m hm p hw
  exact ⟨m', q, h1, h2, by rw [h3, hp0], by rw [h4, hpm], h5⟩

/-! ## Telescoping along a walk, for finite-entry eigenpairs -/

/-- **Telescoping bound.**  For a finite-entry eigenpair the weight of any walk is
controlled by the eigenvector potentials at its endpoints. -/
theorem IsTropEigen.pathWeight_le {B : Matrix ι ι ℝ} {lam : ℝ} {w : ι → ℝ}
    (h : IsTropEigen B lam w) (p : ℕ → ι) (m : ℕ) :
    pathWeight B p m + w (p m) ≤ m * lam + w (p 0) := by
  have step : ∀ t ∈ Finset.range m,
      B (p t) (p (t + 1)) ≤ lam + ((fun t => w (p t)) t - (fun t => w (p t)) (t + 1)) := by
    intro t _
    have := h.le_of (p t) (p (t + 1))
    simp only
    linarith
  have hsum := Finset.sum_le_sum step
  rw [Finset.sum_add_distrib, Finset.sum_range_sub' (fun t => w (p t)) m] at hsum
  simp only [Finset.sum_const, Finset.card_range, nsmul_eq_mul] at hsum
  rw [pathWeight]
  linarith

/-- Translating an eigenvector by a constant gives an eigenvector. -/
theorem IsTropEigen.sub_const {B : Matrix ι ι ℝ} {lam : ℝ} {w : ι → ℝ}
    (h : IsTropEigen B lam w) (c : ℝ) : IsTropEigen B lam (fun j => w j - c) := by
  refine isTropEigen_of B lam _ (fun i j => ?_) (fun i => ?_)
  · have := h.le_of i j
    show B i j + (w j - c) ≤ lam + (w i - c)
    linarith
  · obtain ⟨j, hj⟩ := h.exists_tight i
    exact ⟨j, by show B i j + (w j - c) = lam + (w i - c); linarith⟩

/-! ## The perturbed matrix -/

section Perturb

variable (A)

/-- The smallest entry of the finite part (over *all* index pairs). -/
noncomputable def entryMin : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty (fun p : ι × ι => finPart A p.1 p.2)

/-- The largest entry of the finite part (over *all* index pairs). -/
noncomputable def entryMax : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun p : ι × ι => finPart A p.1 p.2)

/-- The spread bound `n · (max − min)`; the normalised eigenvector of the perturbed
matrix will be shown to lie in `[-spreadBound, 0]`. -/
noncomputable def spreadBound : ℝ := Fintype.card ι * (entryMax A - entryMin A)

/-- The penalty replacing `⊥`: chosen so large that no optimal choice can use it. -/
noncomputable def penalty : ℝ := spreadBound A - entryMin A + 1

/-- The perturbed (finite-entry) matrix: every `⊥` is replaced by `-penalty A`. -/
noncomputable def approx : Matrix ι ι ℝ := fun i j => (A i j).unbotD (-penalty A)

variable {A}

theorem entryMin_le (i j : ι) : entryMin A ≤ finPart A i j := by
  rw [entryMin]
  exact Finset.inf'_le (fun p : ι × ι => finPart A p.1 p.2) (Finset.mem_univ (i, j))

theorem le_entryMax (i j : ι) : finPart A i j ≤ entryMax A := by
  rw [entryMax]
  exact Finset.le_sup' (fun p : ι × ι => finPart A p.1 p.2) (Finset.mem_univ (i, j))

theorem entryMin_le_entryMax : entryMin A ≤ entryMax A := by
  obtain ⟨i⟩ := ‹Nonempty ι›
  exact le_trans (entryMin_le i i) (le_entryMax i i)

theorem spreadBound_nonneg : 0 ≤ spreadBound A := by
  have h := entryMin_le_entryMax (A := A)
  have : (0 : ℝ) ≤ (Fintype.card ι : ℝ) := by positivity
  rw [spreadBound]
  nlinarith

theorem approx_of_supp {i j : ι} (h : A i j ≠ ⊥) : approx A i j = finPart A i j := by
  obtain ⟨a, ha⟩ := WithBot.ne_bot_iff_exists.mp h
  simp [approx, finPart, ← ha]

theorem approx_of_bot {i j : ι} (h : A i j = ⊥) : approx A i j = -penalty A := by
  simp [approx, h]

theorem neg_penalty_le_entryMin : -penalty A ≤ entryMin A := by
  have := spreadBound_nonneg (A := A)
  rw [penalty]
  linarith

theorem approx_le_entryMax (i j : ι) : approx A i j ≤ entryMax A := by
  by_cases h : A i j = ⊥
  · rw [approx_of_bot h]
    exact le_trans neg_penalty_le_entryMin entryMin_le_entryMax
  · rw [approx_of_supp h]
    exact le_entryMax i j

theorem entryMin_le_approx_of_supp {i j : ι} (h : A i j ≠ ⊥) : entryMin A ≤ approx A i j := by
  rw [approx_of_supp h]; exact entryMin_le i j

/-- Along a support walk the perturbed weight is at least `m · entryMin`. -/
theorem entryMin_mul_le_pathWeight {p : ℕ → ι} {m : ℕ} (hw : IsSuppWalk A p m) :
    (m : ℝ) * entryMin A ≤ pathWeight (approx A) p m := by
  rw [pathWeight]
  calc (m : ℝ) * entryMin A = ∑ _t ∈ Finset.range m, entryMin A := by
        simp [Finset.sum_const]
    _ ≤ ∑ t ∈ Finset.range m, approx A (p t) (p (t + 1)) := by
        refine Finset.sum_le_sum fun t ht => ?_
        exact entryMin_le_approx_of_supp (hw t (Finset.mem_range.mp ht))

/-- Every cycle weight of the perturbed matrix is at most `m · entryMax`. -/
theorem pathWeight_le_entryMax (p : ℕ → ι) (m : ℕ) :
    pathWeight (approx A) p m ≤ (m : ℝ) * entryMax A := by
  rw [pathWeight]
  calc ∑ t ∈ Finset.range m, approx A (p t) (p (t + 1))
      ≤ ∑ _t ∈ Finset.range m, entryMax A :=
        Finset.sum_le_sum fun t _ => approx_le_entryMax _ _
    _ = (m : ℝ) * entryMax A := by simp [Finset.sum_const]

theorem maxCycleMean_approx_le : maxCycleMean (approx A) ≤ entryMax A := by
  obtain ⟨m, c, hm, -, -, hcw⟩ := exists_critical_cycle_maxCycleMean (A := approx A)
  have h1 := pathWeight_le_entryMax (A := A) c m
  have hm' : (0 : ℝ) < m := by exact_mod_cast hm
  rw [hcw] at h1
  exact le_of_mul_le_mul_left (by linarith) hm'

theorem entryMin_le_maxCycleMean (hSC : StronglyConnected A) :
    entryMin A ≤ maxCycleMean (approx A) := by
  obtain ⟨i⟩ := ‹Nonempty ι›
  obtain ⟨m, p, hm, -, hp0, hpm, hw⟩ := exists_short_supp_walk hSC i i
  have hcyc : p m = p 0 := by rw [hpm, hp0]
  have h1 := entryMin_mul_le_pathWeight (A := A) hw
  have h2 := cycle_le_maxCycleMean (A := approx A) m p hcyc
  have hm' : (0 : ℝ) < m := by exact_mod_cast hm
  exact le_of_mul_le_mul_left (by linarith) hm'

end Perturb

/-! ## Existence of an eigenvector with `⊥` entries -/

/-- **Tropical Perron–Frobenius with tropical zeros.**  An irreducible max-plus matrix
(one whose support digraph is strongly connected) has a tropical eigenvalue with a
finite eigenvector; the eigenvalue lies between the smallest and largest finite entry. -/
theorem exists_tropEigenBot_of_stronglyConnected (hSC : StronglyConnected A) :
    ∃ (lam : ℝ) (v : ι → ℝ), IsTropEigenBot A lam v ∧
      entryMin A ≤ lam ∧ lam ≤ entryMax A := by
  classical
  set lam := maxCycleMean (approx A) with hlamdef
  have hlam_lb : entryMin A ≤ lam := entryMin_le_maxCycleMean hSC
  have hlam_ub : lam ≤ entryMax A := maxCycleMean_approx_le
  obtain ⟨v₀, hv₀⟩ := exists_tropEigen (approx A)
  -- normalise so that the maximum of the eigenvector is `0`
  obtain ⟨i₁, -, hi₁⟩ :=
    Finset.exists_max_image (Finset.univ : Finset ι) v₀ Finset.univ_nonempty
  set v : ι → ℝ := fun j => v₀ j - v₀ i₁ with hvdef
  have hv : IsTropEigen (approx A) lam v := hv₀.sub_const (v₀ i₁)
  have hv_nonpos : ∀ j, v j ≤ 0 := by
    intro j
    have := hi₁ j (Finset.mem_univ j)
    simp only [hvdef]
    linarith
  have hv_lb : ∀ j, -spreadBound A ≤ v j := by
    intro j
    obtain ⟨m, p, hm, hmn, hp0, hpm, hw⟩ := exists_short_supp_walk hSC j i₁
    have h1 := hv.pathWeight_le p m
    have h2 := entryMin_mul_le_pathWeight (A := A) hw
    have hvi₁ : v i₁ = 0 := by simp [hvdef]
    rw [hpm, hp0, hvi₁] at h1
    -- `m * entryMin ≤ m * lam + v j`
    have h3 : (m : ℝ) * entryMin A ≤ (m : ℝ) * lam + v j := by linarith
    have h4 : (m : ℝ) * (entryMin A - lam) ≤ v j := by nlinarith
    have hmn' : (m : ℝ) ≤ (Fintype.card ι : ℝ) := by exact_mod_cast hmn
    have h5 : (Fintype.card ι : ℝ) * (entryMin A - lam) ≤ (m : ℝ) * (entryMin A - lam) := by
      have hneg : entryMin A - lam ≤ 0 := by linarith
      nlinarith
    have h6 : -spreadBound A ≤ (Fintype.card ι : ℝ) * (entryMin A - lam) := by
      rw [spreadBound]
      have hc : (0 : ℝ) ≤ (Fintype.card ι : ℝ) := by positivity
      nlinarith
    linarith
  -- the optimal entry in each row cannot be a `⊥` position
  have htight : ∀ i, ∃ j, A i j ≠ ⊥ ∧ approx A i j + v j = lam + v i := by
    intro i
    obtain ⟨j, hj⟩ := hv.exists_tight i
    refine ⟨j, ?_, hj⟩
    intro hbot
    rw [approx_of_bot hbot] at hj
    have h1 := hv_nonpos j
    have h2 := hv_lb i
    have h3 : (0 : ℝ) ≤ spreadBound A := spreadBound_nonneg
    rw [penalty] at hj
    linarith
  refine ⟨lam, v, isTropEigenBot_of (fun i j => ?_) (fun i => ?_), hlam_lb, hlam_ub⟩
  · by_cases hbot : A i j = ⊥
    · rw [hbot]; simp
    · rw [← coe_finPart hbot, ← WithBot.coe_add, WithBot.coe_le_coe]
      have := hv.le_of i j
      rw [approx_of_supp hbot] at this
      exact this
  · obtain ⟨j, hne, hj⟩ := htight i
    refine ⟨j, ?_⟩
    rw [← coe_finPart hne, ← WithBot.coe_add, WithBot.coe_inj]
    rw [approx_of_supp hne] at hj
    exact hj

/-! ## The eigenvalue is the maximum support cycle mean -/

namespace IsTropEigenBot

variable {lam : ℝ} {v : ι → ℝ}

omit [Nonempty ι] in
/-- Every closed support walk has mean weight at most the eigenvalue. -/
theorem suppCycle_le (h : IsTropEigenBot A lam v) {m : ℕ} {c : ℕ → ι}
    (hw : IsSuppWalk A c m) (hc : c m = c 0) :
    pathWeight (finPart A) c m ≤ m * lam := by
  have step : ∀ t ∈ Finset.range m,
      finPart A (c t) (c (t + 1)) ≤
        lam + ((fun t => v (c t)) t - (fun t => v (c t)) (t + 1)) := by
    intro t ht
    have := h.real_le_of (hw t (Finset.mem_range.mp ht))
    simp only
    linarith
  have hsum := Finset.sum_le_sum step
  rw [Finset.sum_add_distrib, Finset.sum_range_sub' (fun t => v (c t)) m] at hsum
  simp only [Finset.sum_const, Finset.card_range, nsmul_eq_mul] at hsum
  rw [pathWeight]
  simp only [hc] at hsum
  linarith

/-- A **critical support cycle** exists: following the tight successors must close up. -/
theorem exists_critical_suppCycle (h : IsTropEigenBot A lam v) :
    ∃ (m : ℕ) (c : ℕ → ι), 0 < m ∧ c m = c 0 ∧ IsSuppWalk A c m ∧
      pathWeight (finPart A) c m = m * lam := by
  classical
  choose f hfsupp hf using h.exists_tight
  obtain ⟨i₀⟩ := ‹Nonempty ι›
  obtain ⟨a, b, hab, hfab⟩ : ∃ a b : ℕ, a < b ∧ f^[a] i₀ = f^[b] i₀ := by
    obtain ⟨x, y, hxy, hfxy⟩ := Finite.exists_ne_map_eq_of_infinite (fun n : ℕ => f^[n] i₀)
    rcases lt_or_gt_of_ne hxy with h | h
    · exact ⟨x, y, h, hfxy⟩
    · exact ⟨y, x, h, hfxy.symm⟩
  set c : ℕ → ι := fun t => f^[a + t] i₀ with hc
  refine ⟨b - a, c, by omega, ?_, ?_, ?_⟩
  · show f^[a + (b - a)] i₀ = f^[a + 0] i₀
    rw [show a + (b - a) = b by omega, show a + 0 = a by omega, hfab]
  · intro t _
    have : c (t + 1) = f (c t) := by
      simp only [hc, show a + (t + 1) = (a + t) + 1 by omega, Function.iterate_succ_apply']
    rw [this]
    exact hfsupp (c t)
  · have hterm : ∀ t : ℕ, finPart A (c t) (c (t + 1)) =
        lam + ((fun t => v (c t)) t - (fun t => v (c t)) (t + 1)) := by
      intro t
      have hstep : c (t + 1) = f (c t) := by
        simp only [hc, show a + (t + 1) = (a + t) + 1 by omega, Function.iterate_succ_apply']
      have := hf (c t)
      rw [hstep]
      simp only
      rw [hstep]
      linarith
    rw [pathWeight, Finset.sum_congr rfl (fun t _ => hterm t), Finset.sum_add_distrib,
      Finset.sum_range_sub' (fun t => v (c t)) (b - a)]
    have hcend : c (b - a) = c 0 := by
      show f^[a + (b - a)] i₀ = f^[a + 0] i₀
      rw [show a + (b - a) = b by omega, show a + 0 = a by omega, hfab]
    simp only [Finset.sum_const, Finset.card_range, nsmul_eq_mul, hcend]
    ring

/-- **The eigenvalue is exactly the maximum support cycle mean.** -/
theorem isGreatest_suppCycleMean (h : IsTropEigenBot A lam v) :
    IsGreatest {μ : ℝ | ∃ (m : ℕ) (c : ℕ → ι), 0 < m ∧ c m = c 0 ∧ IsSuppWalk A c m ∧
      μ = pathWeight (finPart A) c m / m} lam := by
  constructor
  · obtain ⟨m, c, hm, hc, hw, hval⟩ := h.exists_critical_suppCycle
    refine ⟨m, c, hm, hc, hw, ?_⟩
    rw [hval]
    have : (m : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
    field_simp
  · rintro μ ⟨m, c, hm, hc, hw, rfl⟩
    have hm' : (0 : ℝ) < m := by exact_mod_cast hm
    rw [div_le_iff₀ hm']
    have := h.suppCycle_le hw hc
    linarith

end IsTropEigenBot

/-- **Uniqueness of the tropical eigenvalue with `⊥` entries** — no irreducibility needed:
both eigenvalues equal the maximum mean of a closed support walk. -/
theorem tropEigenvalueBot_unique {lam₁ lam₂ : ℝ} {v₁ v₂ : ι → ℝ}
    (h₁ : IsTropEigenBot A lam₁ v₁) (h₂ : IsTropEigenBot A lam₂ v₂) : lam₁ = lam₂ := by
  have key : ∀ {a b : ℝ} {w₁ w₂ : ι → ℝ}, IsTropEigenBot A a w₁ → IsTropEigenBot A b w₂ → a ≤ b := by
    intro a b w₁ w₂ ha hb
    obtain ⟨m, c, hm, hc, hw, hval⟩ := ha.exists_critical_suppCycle
    have hle := hb.suppCycle_le hw hc
    rw [hval] at hle
    have hm' : (0 : ℝ) < m := by exact_mod_cast hm
    nlinarith
  exact le_antisymm (key h₁ h₂) (key h₂ h₁)

/-- **Tropical Perron–Frobenius with `⊥` entries, full statement.**  An irreducible
max-plus matrix has exactly one eigenvalue, namely the maximum mean weight of a closed
walk in its support digraph. -/
theorem tropEigenBot_iff_isGreatest_suppCycleMean (hSC : StronglyConnected A) (lam : ℝ) :
    (∃ v : ι → ℝ, IsTropEigenBot A lam v) ↔
      IsGreatest {μ : ℝ | ∃ (m : ℕ) (c : ℕ → ι), 0 < m ∧ c m = c 0 ∧ IsSuppWalk A c m ∧
        μ = pathWeight (finPart A) c m / m} lam := by
  constructor
  · rintro ⟨v, hv⟩
    exact hv.isGreatest_suppCycleMean
  · intro hgr
    obtain ⟨lam', v, hv, -, -⟩ := exists_tropEigenBot_of_stronglyConnected hSC
    have : lam = lam' := hgr.unique hv.isGreatest_suppCycleMean
    exact ⟨v, this ▸ hv⟩

/-! ## The converse of C4 is false -/

/-- The `2 × 2` diagonal matrix `diag(0,0)` with `⊥` off the diagonal. -/
noncomputable def diagBotExample : Matrix (Fin 2) (Fin 2) (WithBot ℝ) :=
  fun i j => if i = j then ((0 : ℝ) : WithBot ℝ) else ⊥

theorem diagBotExample_isTropEigenBot :
    IsTropEigenBot diagBotExample 0 (fun _ => 0) := by
  refine isTropEigenBot_of (fun i j => ?_) (fun i => ⟨i, ?_⟩)
  · by_cases h : i = j
    · subst h; simp [diagBotExample]
    · simp [diagBotExample, h]
  · simp [diagBotExample]

theorem diagBotExample_not_stronglyConnected : ¬ StronglyConnected diagBotExample := by
  intro hSC
  have key : ∀ i j : Fin 2, Relation.TransGen (Supp diagBotExample) i j → i = j := by
    intro i j h
    induction h with
    | single hij =>
        rename_i b
        by_contra hne
        exact hij (by simp [diagBotExample, hne])
    | tail hab hbc ih =>
        rename_i b c
        subst ih
        by_contra hne
        exact hbc (by simp [diagBotExample, hne])
  exact absurd (key 0 1 (hSC 0 1)) (by decide)

/-- **Conjecture C4 is refuted in the stated `iff` form.**  There is a matrix with a
finite tropical eigenvector whose support digraph is *not* strongly connected; so strong
connectivity is sufficient (`exists_tropEigenBot_of_stronglyConnected`) but not necessary. -/
theorem not_stronglyConnected_of_isTropEigenBot_false :
    ¬ ∀ (B : Matrix (Fin 2) (Fin 2) (WithBot ℝ)),
        (∃ (lam : ℝ) (v : Fin 2 → ℝ), IsTropEigenBot B lam v) → StronglyConnected B := by
  intro h
  exact diagBotExample_not_stronglyConnected
    (h diagBotExample ⟨0, fun _ => 0, diagBotExample_isTropEigenBot⟩)

end TropicalLA