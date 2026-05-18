/-
  # Longest Common Valued Prefix — Foundational Combinatorics

  Bridge: connects ultrametric valuation geometry to prefix-agreement
  combinatorics on finite lists. Defines `lcvpLen` and proves its core
  algebraic properties including the min-prefix (ultrametric valuation)
  inequality.

  Keywords: ultrametric, valuation, prefix_agreement, non_archimedean
-/
import Mathlib

open List Finset

namespace OracleTrace

/-! ## Core Definitions -/

/-- `lcvpLen u v` is the length of the longest common prefix of lists
`u` and `v`. Acts as a discrete non-Archimedean valuation on list space.

Bridge: connects algebra (valuation theory) to speculative oracle
semantics (trace agreement depth). -/
def lcvpLen [DecidableEq α] : List α → List α → Nat
  | [], _ => 0
  | _, [] => 0
  | a :: u, b :: v => if a = b then Nat.succ (lcvpLen u v) else 0

/-- Prefix agreement up to depth `k`. -/
def PrefixAgreeUpTo [DecidableEq α] (k : Nat) (u v : List α) : Prop :=
  List.take k u = List.take k v

/-- Prefix injectivity: an encoding is injective on list traces.
Bridge: connects to post_quantum_security (collision resistance). -/
def PrefixInjective {β α : Type*} (encode : β → List α) : Prop :=
  Function.Injective encode

variable {α : Type*} [DecidableEq α]

/-! ## Foundational Recursion -/

@[simp]
theorem lcvpLen_nil_left (u : List α) :
    lcvpLen ([] : List α) u = 0 := by
  simp [lcvpLen]

@[simp]
theorem lcvpLen_nil_right (u : List α) :
    lcvpLen u ([] : List α) = 0 := by
  cases u <;> simp [lcvpLen]

theorem lcvpLen_cons_cons_eq (a : α) (u v : List α) :
    lcvpLen (a :: u) (a :: v) = Nat.succ (lcvpLen u v) := by
  simp [lcvpLen]

theorem lcvpLen_cons_cons_ne {a b : α} (h : a ≠ b) (u v : List α) :
    lcvpLen (a :: u) (b :: v) = 0 := by
  simp [lcvpLen, h]

/-! ## Symmetry -/

/-- `lcvpLen` is symmetric.
Bridge: connects to ultrametric geometry and quantum oracle semantics. -/
theorem lcvpLen_symmetric (u v : List α) :
    lcvpLen u v = lcvpLen v u := by
  induction u generalizing v with
  | nil => simp
  | cons a u ih =>
    cases v with
    | nil => simp
    | cons b v =>
      simp only [lcvpLen]
      by_cases h : a = b
      · subst h; simp [ih v]
      · simp [h, Ne.symm h]

/-! ## Length Bounds -/

theorem lcvpLen_le_left (u v : List α) :
    lcvpLen u v ≤ u.length := by
  induction u generalizing v with
  | nil => simp
  | cons a u ih =>
    cases v with
    | nil => simp
    | cons b v =>
      simp only [lcvpLen, List.length_cons]
      by_cases h : a = b
      · simp [h]; exact ih v
      · simp [h]

theorem lcvpLen_le_right (u v : List α) :
    lcvpLen u v ≤ v.length := by
  rw [lcvpLen_symmetric]; exact lcvpLen_le_left v u

theorem lcvpLen_le_min (u v : List α) :
    lcvpLen u v ≤ min u.length v.length :=
  Nat.le_min.mpr ⟨lcvpLen_le_left u v, lcvpLen_le_right u v⟩

/-! ## Self-agreement -/

@[simp]
theorem lcvpLen_self (u : List α) :
    lcvpLen u u = u.length := by
  induction u with
  | nil => simp
  | cons a u ih => simp [lcvpLen, ih]

/-! ## Prefix Agreement Characterization -/

/-- Taking the first `lcvpLen u v` elements from `u` and `v` yields
the same list. -/
theorem take_lcvpLen_eq (u v : List α) :
    List.take (lcvpLen u v) u = List.take (lcvpLen u v) v := by
  induction u generalizing v with
  | nil => simp [lcvpLen]
  | cons a u ih =>
    cases v with
    | nil => simp [lcvpLen]
    | cons b v =>
      simp only [lcvpLen]
      by_cases hab : a = b
      · subst hab; simp [take_succ_cons, ih v]
      · simp [hab]

/-- If `k ≤ lcvpLen u v`, then `take k u = take k v`. -/
theorem take_eq_of_le_lcvpLen {u v : List α} {k : Nat}
    (hk : k ≤ lcvpLen u v) :
    List.take k u = List.take k v := by
  induction u generalizing v k with
  | nil => simp [lcvpLen] at hk; subst hk; simp
  | cons a u ih =>
    cases v with
    | nil => simp [lcvpLen] at hk; subst hk; simp
    | cons b v =>
      simp only [lcvpLen] at hk
      by_cases hab : a = b
      · subst hab; simp only [ite_true] at hk
        cases k with
        | zero => simp
        | succ k =>
          simp only [take_succ_cons]
          congr 1; exact ih (Nat.le_of_succ_le_succ hk)
      · simp [hab] at hk; subst hk; simp

/-! ## Maximality -/

/-- `lcvpLen` is maximal among bounded prefix agreements. -/
theorem lcvpLen_maximal_prefix (u v : List α) (k : Nat)
    (hbound : k ≤ min u.length v.length)
    (h : List.take k u = List.take k v) : k ≤ lcvpLen u v := by
  induction u generalizing v k with
  | nil => simp at hbound; omega
  | cons a u ih =>
    cases v with
    | nil => simp at hbound; omega
    | cons b v =>
      cases k with
      | zero => omega
      | succ k =>
        simp only [take_succ_cons, cons.injEq] at h
        obtain ⟨hab, htl⟩ := h
        subst hab
        simp only [lcvpLen, ite_true, length_cons] at *
        exact Nat.succ_le_succ (ih v k (by omega) htl)

/-- Bidirectional characterization for bounded `k`. -/
theorem take_eq_iff_le_lcvpLen (u v : List α) {k : Nat}
    (hk : k ≤ min u.length v.length) :
    List.take k u = List.take k v ↔ k ≤ lcvpLen u v :=
  ⟨lcvpLen_maximal_prefix u v k hk, take_eq_of_le_lcvpLen⟩

/-! ## Equality Detection -/

theorem lcvpLen_eq_length_of_eq (u v : List α) (h : u = v) :
    lcvpLen u v = u.length := by
  subst h; simp

theorem eq_of_lcvpLen_eq_lengths (u v : List α)
    (h₁ : lcvpLen u v = u.length) (h₂ : u.length = v.length) :
    u = v := by
  have htake := take_lcvpLen_eq u v
  rw [h₁, take_length] at htake
  rw [show u.length = v.length from h₂] at htake
  rw [take_length] at htake
  exact htake

/-! ## The Ultrametric Valuation Inequality -/

/-- **The min-prefix inequality** — the central algebraic theorem.
Bridge: connects valuation_theory to ultrametric_geometry. -/
theorem lcvpLen_ge_min_of_triangle (u v w : List α) :
    min (lcvpLen u v) (lcvpLen v w) ≤ lcvpLen u w := by
  set k := min (lcvpLen u v) (lcvpLen v w)
  have h1 : k ≤ lcvpLen u v := Nat.min_le_left _ _
  have h2 : k ≤ lcvpLen v w := Nat.min_le_right _ _
  have hkbound : k ≤ min u.length w.length := by
    exact Nat.le_min.mpr ⟨le_trans h1 (lcvpLen_le_left u v),
      le_trans h2 (lcvpLen_le_right v w)⟩
  exact lcvpLen_maximal_prefix u w k hkbound
    ((take_eq_of_le_lcvpLen h1).trans (take_eq_of_le_lcvpLen h2))

/-! ## Concatenation Principle -/

/-- Appending a common prefix increments `lcvpLen` by exactly the prefix length.
Bridge: connects to certified_robustness (context contraction) and
lattice_crypto (prefix extension preserves separation). -/
theorem lcvpLen_append_left (p u v : List α) :
    lcvpLen (p ++ u) (p ++ v) = p.length + lcvpLen u v := by
  induction p with
  | nil => simp
  | cons a p ih =>
    simp only [List.cons_append, lcvpLen, ite_true, List.length_cons]
    omega

end OracleTrace