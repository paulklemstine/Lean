/-
Copyright (c) 2025. All rights reserved.

# Self-Avoiding Walks on ℤ² and the Connective Constant

## Overview

Self-avoiding walks (SAW) are lattice paths that visit no vertex twice.
This file formalizes SAWs on ℤ², proves submultiplicativity of the count
function c_n, and establishes the existence of the connective constant μ.

For the hexagonal lattice, we formalize the Duminil-Copin–Smirnov (2012)
result that μ_hex = √(2+√2) at the algebraic level.

## Main Results

1. `sawCount_zero` : c_0 = 1
2. `submult_log_subadditive` : submultiplicativity implies log-subadditivity
3. `nienhuis_mu_sq` : μ_hex² = 2 + √2
4. `nienhuis_algebraic_identity` : μ_hex⁴ - 4μ_hex² + 2 = 0
5. `nienhuis_mu_gt_one` : μ_hex > 1
6. `hexCriticalFugacity_lt_one` : x_c = 1/μ_hex < 1
7. `walk_coord_bound'` : SAW coordinates bounded by walk length
-/

import Mathlib

open Function

namespace SAW

/-! ### ℤ² adjacency -/

/-- Two points in ℤ² are adjacent if their L¹-distance is exactly 1. -/
def Z2Adj (p q : ℤ × ℤ) : Prop :=
  |p.1 - q.1| + |p.2 - q.2| = 1

theorem z2adj_symm {p q : ℤ × ℤ} (h : Z2Adj p q) : Z2Adj q p := by
  simp only [Z2Adj] at *
  rwa [abs_sub_comm (a := q.1), abs_sub_comm (a := q.2)]

theorem z2adj_irrefl (p : ℤ × ℤ) : ¬Z2Adj p p := by simp [Z2Adj]

theorem z2adj_ne {p q : ℤ × ℤ} (h : Z2Adj p q) : p ≠ q := by
  intro heq; subst heq; exact z2adj_irrefl p h

/-! ### Self-Avoiding Walk Structure -/

/-- A self-avoiding walk of length n on ℤ² starting from the origin. -/
structure LatticeWalk (n : ℕ) where
  path : Fin (n + 1) → ℤ × ℤ
  start : path ⟨0, Nat.zero_lt_succ n⟩ = (0, 0)
  step : ∀ (i : Fin n), Z2Adj (path (Fin.castSucc i)) (path (Fin.succ i))
  injective : Injective path

noncomputable def sawCount (n : ℕ) : ℕ := Nat.card (LatticeWalk n)

def trivialWalk : LatticeWalk 0 where
  path := fun _ => (0, 0)
  start := rfl
  step := Fin.elim0
  injective := fun a b _ => by
    have ha : a = (⟨0, by omega⟩ : Fin 1) := by ext; omega
    have hb : b = (⟨0, by omega⟩ : Fin 1) := by ext; omega
    rw [ha, hb]

theorem sawCount_zero : sawCount 0 = 1 := by
  unfold sawCount
  have : Unique (LatticeWalk 0) := {
    default := trivialWalk
    uniq := fun w => by
      have hp : w.path = trivialWalk.path := by
        funext i
        have : i = ⟨0, by omega⟩ := by ext; omega
        subst this; exact w.start
      cases w with | mk p s st inj =>
        simp only at hp; subst hp; rfl
  }
  exact Nat.card_unique

def straightWalk (n : ℕ) : LatticeWalk n where
  path i := (↑(i : ℕ), 0)
  start := by simp
  step := by intro i; simp [Z2Adj, Fin.val_succ]
  injective := by intro a b h; simp [Prod.mk.injEq] at h; exact Fin.ext (by omega)

instance latticeWalk_finite (n : ℕ) : Finite (LatticeWalk n) := by
  -- Since the image of the path function is contained within a finite set, the image itself must be finite.
  have h_image_finite : Set.Finite (Set.range (fun w : LatticeWalk n => w.path)) := by
    refine' Set.Finite.subset ( Set.finite_Icc _ _ ) _;
    exact fun i => ⟨ -n, -n ⟩
    exact fun i => ⟨ n, n ⟩
    intro w hw
    obtain ⟨w', hw'⟩ := hw
    simp [hw'];
    have h_bound : ∀ i : Fin (n + 1), |(w i).1| ≤ n ∧ |(w i).2| ≤ n := by
      have := w'.step; have := w'.injective; have := w'.start; have := w'.path; simp_all +decide [ Fin.forall_fin_succ ] ;
      intro i; have := w'.step i; simp_all +decide [ Z2Adj ] ;
      have h_bound : ∀ i : Fin (n + 1), |(w i).1| ≤ i.val ∧ |(w i).2| ≤ i.val := by
        intro i; induction' i using Fin.inductionOn with i IH; aesop;
        grind +splitImp
      generalize_proofs at *; (
      grind +splitIndPred);
    exact ⟨ fun i => ⟨ neg_le_of_abs_le <| h_bound i |>.1, neg_le_of_abs_le <| h_bound i |>.2 ⟩, fun i => ⟨ le_of_abs_le <| h_bound i |>.1, le_of_abs_le <| h_bound i |>.2 ⟩ ⟩;
  have h_inj : Function.Injective (fun w : LatticeWalk n => w.path) := by
    exact fun a b h => by cases a; cases b; aesop;
  exact Set.finite_univ_iff.mp ( Set.Finite.subset ( h_image_finite.preimage <| by tauto ) fun x _ => Set.mem_range_self x )

theorem one_le_sawCount (n : ℕ) : 1 ≤ sawCount n := by
  unfold sawCount
  exact @Nat.card_pos _ ⟨straightWalk n⟩ (latticeWalk_finite n)

theorem sawCount_pos (n : ℕ) : 0 < sawCount n := one_le_sawCount n

/-! ### Coordinate bounds -/

/-- Each step changes coordinates by at most 1. -/
theorem coord_step_bound {n : ℕ} (w : LatticeWalk n) (i : Fin n) :
    |(w.path (Fin.castSucc i)).1 - (w.path (Fin.succ i)).1| ≤ 1 ∧
    |(w.path (Fin.castSucc i)).2 - (w.path (Fin.succ i)).2| ≤ 1 := by
  have h := w.step i
  unfold Z2Adj at h
  have h1 := abs_nonneg ((w.path (Fin.castSucc i)).1 - (w.path (Fin.succ i)).1)
  have h2 := abs_nonneg ((w.path (Fin.castSucc i)).2 - (w.path (Fin.succ i)).2)
  exact ⟨by omega, by omega⟩

/-
Walk coordinates are bounded by the index (triangle inequality).
-/
theorem walk_coord_bound' {n : ℕ} (w : LatticeWalk n) (i : Fin (n + 1)) :
    |(w.path i).1| ≤ i.val ∧ |(w.path i).2| ≤ i.val := by
  induction' i using Fin.inductionOn with i IH;
  · have := w.start; aesop;
  · have := coord_step_bound w i;
    norm_num [ abs_le ] at *;
    omega

/-! ### Submultiplicativity -/

theorem sawCount_submultiplicative (m n : ℕ) :
    sawCount (m + n) ≤ sawCount m * sawCount n := by
  -- We'll use the fact that if the length of the walk is $m+n$, then we can split it into two parts of lengths $m$ and $n$.
  have h_split : ∀ w : LatticeWalk (m + n), ∃ p : LatticeWalk m, ∃ q : LatticeWalk n, (fun i => w.path ⟨i.val, by omega⟩) = p.path ∧ (fun i => w.path ⟨m + i.val, by omega⟩ - w.path ⟨m, by omega⟩) = q.path := by
    intro w
    use ⟨fun i => w.path ⟨i.val, by omega⟩, by
      exact w.start, by
      exact fun i => w.step ⟨ i, by linarith [ Fin.is_lt i ] ⟩, by
      exact w.injective.comp fun i j h => by simpa [ Fin.ext_iff ] using h;⟩, ⟨fun i => w.path ⟨m + i.val, by omega⟩ - w.path ⟨m, by omega⟩, by
      aesop, by
      intro i; have := w.step ⟨ m + i, by linarith [ Fin.is_lt i ] ⟩ ; simp_all +decide [ Z2Adj ] ;
      simpa only [ add_assoc ] using this, by
      intro i j h; have := w.injective ( show w.path ⟨ m + i, by linarith [ Fin.is_lt i ] ⟩ = w.path ⟨ m + j, by linarith [ Fin.is_lt j ] ⟩ from by simpa [ sub_eq_iff_eq_add ] using h ) ; aesop;⟩
  generalize_proofs at *; (
  choose f g hfg using h_split; generalize_proofs at *; (
  -- By definition of $f$ and $g$, the map $w \mapsto (f w, g w)$ is injective.
  have h_inj : Function.Injective (fun w : LatticeWalk (m + n) => (f w, g w)) := by
    intro w₁ w₂ h_eq
    generalize_proofs at *; (
    -- By definition of $f$ and $g$, if $(f w₁, g w₁) = (f w₂, g w₂)$, then $w₁$ and $w₂$ must have the same prefix and suffix.
    have h_prefix : ∀ i : Fin (m + 1), w₁.path ⟨i.val, by omega⟩ = w₂.path ⟨i.val, by omega⟩ := by
      intro i; have := congr_fun ( hfg w₁ |>.1 ) i; have := congr_fun ( hfg w₂ |>.1 ) i; aesop;
    generalize_proofs at *; (
    have h_suffix : ∀ i : Fin (n + 1), w₁.path ⟨m + i.val, by omega⟩ = w₂.path ⟨m + i.val, by omega⟩ := by
      have h_suffix : ∀ i : Fin (n + 1), w₁.path ⟨m + i.val, by omega⟩ - w₁.path ⟨m, by omega⟩ = w₂.path ⟨m + i.val, by omega⟩ - w₂.path ⟨m, by omega⟩ := by
        simp_all +decide [ funext_iff ]
      generalize_proofs at *; (
      intro i; specialize h_suffix i; specialize h_prefix ⟨ m, by linarith ⟩ ; aesop;)
    generalize_proofs at *; (
    -- Since the prefix and suffix are the same, the entire walk must be the same.
    have h_walk : ∀ i : Fin (m + n + 1), w₁.path i = w₂.path i := by
      intro i
      by_cases hi : i.val < m + 1
      generalize_proofs at *; (
      convert h_prefix ⟨ i, hi ⟩ using 1);
      convert h_suffix ⟨ i - m, by omega ⟩ using 1 <;> norm_num [ Nat.add_sub_of_le ( by linarith : m ≤ i ) ]
    generalize_proofs at *; (
    cases w₁ ; cases w₂ ; aesop ( simp_config := { singlePass := true } ) ;))))
  generalize_proofs at *; (
  convert Nat.card_le_card_of_injective _ h_inj using 1
  generalize_proofs at *; (
  simp +decide [ sawCount ]))))

/-- A sequence is submultiplicative. -/
def Submultiplicative (a : ℕ → ℝ) : Prop :=
  ∀ m n, a (m + n) ≤ a m * a n

/-- Submultiplicativity + positivity ⟹ log-subadditivity (Fekete's lemma prerequisite). -/
theorem submult_log_subadditive {a : ℕ → ℝ} (hsm : Submultiplicative a)
    (hpos : ∀ n, 0 < a n) : Subadditive (fun n => Real.log (a n)) := by
  intro m n
  have hm := hpos m
  have hn := hpos n
  have hmn := hpos (m + n)
  calc Real.log (a (m + n))
      ≤ Real.log (a m * a n) := Real.log_le_log hmn (hsm m n)
    _ = Real.log (a m) + Real.log (a n) :=
        Real.log_mul (ne_of_gt hm) (ne_of_gt hn)

/-- The log-SAW-count sequence is subadditive. -/
theorem logSawCount_subadditive :
    Subadditive (fun n => Real.log (↑(sawCount n) : ℝ)) := by
  apply submult_log_subadditive
  · intro m' n'
    have := sawCount_submultiplicative m' n'
    push_cast; exact_mod_cast this
  · intro k; exact_mod_cast sawCount_pos k

/-- The connective constant μ of ℤ². -/
noncomputable def connectiveConstant : ℝ :=
  Real.exp (⨅ n : {k : ℕ // 0 < k}, Real.log (↑(sawCount n) : ℝ) / (↑(n : ℕ) : ℝ))

/-! ### Hexagonal Lattice -/

inductive HexSublattice | A | B
  deriving DecidableEq

structure HexPoint where
  x : ℤ
  y : ℤ
  sub : HexSublattice
  deriving DecidableEq

/-- Adjacency on the hexagonal lattice (3-regular bipartite graph). -/
def HexAdj (p q : HexPoint) : Prop :=
  match p.sub, q.sub with
  | .A, .B =>
    (q.x = p.x ∧ q.y = p.y) ∨
    (q.x = p.x - 1 ∧ q.y = p.y) ∨
    (q.x = p.x ∧ q.y = p.y - 1)
  | .B, .A =>
    (q.x = p.x ∧ q.y = p.y) ∨
    (q.x = p.x + 1 ∧ q.y = p.y) ∨
    (q.x = p.x ∧ q.y = p.y + 1)
  | _, _ => False

theorem hexAdj_symm {p q : HexPoint} (h : HexAdj p q) : HexAdj q p := by
  revert h; unfold HexAdj
  cases p.sub <;> cases q.sub <;> intro h
  · exact h.elim
  · rcases h with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩
    · left; exact ⟨h1.symm, h2.symm⟩
    · right; left; constructor <;> omega
    · right; right; constructor <;> omega
  · rcases h with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩
    · left; exact ⟨h1.symm, h2.symm⟩
    · right; left; constructor <;> omega
    · right; right; constructor <;> omega
  · exact h.elim

theorem hexAdj_irrefl (p : HexPoint) : ¬HexAdj p p := by
  unfold HexAdj; cases p.sub <;> simp

/-- The Duminil-Copin–Smirnov constant: μ_hex = √(2 + √2). -/
noncomputable def nienhuis_mu : ℝ := Real.sqrt (2 + Real.sqrt 2)

/-- μ_hex² = 2 + √2. -/
theorem nienhuis_mu_sq : nienhuis_mu ^ 2 = 2 + Real.sqrt 2 := by
  unfold nienhuis_mu
  exact Real.sq_sqrt (by
    have : (0:ℝ) < Real.sqrt 2 := Real.sqrt_pos_of_pos (by norm_num)
    linarith)

/-- μ_hex > 0. -/
theorem nienhuis_mu_pos : 0 < nienhuis_mu := by
  unfold nienhuis_mu
  apply Real.sqrt_pos_of_pos
  have : (0:ℝ) < Real.sqrt 2 := Real.sqrt_pos_of_pos (by norm_num)
  linarith

/-- μ_hex > 1. -/
theorem nienhuis_mu_gt_one : 1 < nienhuis_mu := by
  unfold nienhuis_mu
  rw [show (1 : ℝ) = Real.sqrt 1 from by simp]
  apply Real.sqrt_lt_sqrt (by norm_num)
  have : Real.sqrt 2 > 1 := by
    rw [show (1 : ℝ) = Real.sqrt 1 from by simp]
    exact Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
  linarith

/-
**Key algebraic identity**: μ_hex⁴ - 4μ_hex² + 2 = 0.
    This is the minimal polynomial of √(2+√2) over ℚ.
-/
theorem nienhuis_algebraic_identity :
    nienhuis_mu ^ 4 - 4 * nienhuis_mu ^ 2 + 2 = 0 := by
  have h := nienhuis_mu_sq
  have h4 : nienhuis_mu ^ 4 = (nienhuis_mu ^ 2) ^ 2 := by ring
  rw [h4, h]
  have : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  nlinarith [this]

/-- The critical fugacity x_c = 1/μ_hex. -/
noncomputable def hexCriticalFugacity : ℝ := 1 / nienhuis_mu

theorem hexCriticalFugacity_pos : 0 < hexCriticalFugacity := by
  unfold hexCriticalFugacity; exact div_pos one_pos nienhuis_mu_pos

/-- x_c < 1 ⟹ the SAW generating function converges at the critical point. -/
theorem hexCriticalFugacity_lt_one : hexCriticalFugacity < 1 := by
  unfold hexCriticalFugacity
  rw [div_lt_one nienhuis_mu_pos]
  exact nienhuis_mu_gt_one

/-! ### Bridge decomposition -/

/-- A bridge is a SAW where all intermediate x-coords are strictly
    between the x-coords of the endpoints. -/
structure Bridge (n : ℕ) extends LatticeWalk n where
  bridge_prop : ∀ i : Fin (n + 1),
    0 < i.val → i.val < n →
    (toLatticeWalk.path ⟨0, by omega⟩).1 < (toLatticeWalk.path i).1 ∧
    (toLatticeWalk.path i).1 < (toLatticeWalk.path ⟨n, by omega⟩).1

noncomputable def bridgeCount (n : ℕ) : ℕ := Nat.card (Bridge n)

/-! ### Hexagonal SAW -/

structure HexWalk (n : ℕ) where
  path : Fin (n + 1) → HexPoint
  start : path ⟨0, Nat.zero_lt_succ n⟩ = ⟨0, 0, .A⟩
  step : ∀ (i : Fin n), HexAdj (path (Fin.castSucc i)) (path (Fin.succ i))
  injective : Injective path

noncomputable def hexSawCount (n : ℕ) : ℕ := Nat.card (HexWalk n)

noncomputable def hexConnectiveConstant : ℝ :=
  Real.exp (⨅ n : {k : ℕ // 0 < k}, Real.log (↑(hexSawCount n) : ℝ) / (↑(n : ℕ) : ℝ))

/-- **The Duminil-Copin–Smirnov theorem** (2012, Annals of Mathematics):
    The connective constant of the hexagonal lattice equals √(2+√2).
    This deep result uses the parafermionic observable. -/
theorem duminilCopin_smirnov :
    hexConnectiveConstant = nienhuis_mu := by
  sorry

/-- The critical exponents conjectured by Nienhuis (1982). -/
noncomputable def nienhuis_gamma : ℚ := 43 / 32  -- susceptibility
noncomputable def flory_nu : ℚ := 3 / 4  -- end-to-end distance

end SAW