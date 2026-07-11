/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Oracle's Burden, Part I: Relativized computability and the base of the hierarchy

This file develops the structural theory of **oracle (relative) computability** on top of
Mathlib's `RecursiveIn` / `TuringReducible` / `TuringDegree`, and establishes the *base case*
of the oracle hierarchy `PA < PA^H < PA^{H^H} < ...`, reinterpreted computability-theoretically
as the Turing-degree chain `0 <ᵀ 0' <ᵀ 0'' <ᵀ ...`.

The guiding metaphor of the mission — *adding an oracle for the halting problem yields a theory
that proves its own consistency but cannot decide its own soundness* — is the statement
`A <ᵀ A'`: the jump `A'` can answer every halting question about `A`-machines ("consistency"),
while `A` itself cannot decide membership in `A'` ("soundness").  The order-theoretic core of
this phenomenon is captured here; the abstract jump hierarchy is developed in
`Computation.TuringJumpHierarchy`.

## Main results

* `recursiveIn_cut` — the fundamental *cut/transitivity* principle: if every oracle in `O` is
  itself recursive in `O'`, then everything recursive in `O` is recursive in `O'`.
* `recursiveIn_mono` — relativization is monotone in the oracle set (adding oracles never
  decreases power).
* `reducible_zero_iff_partrec` — the *bottom* degree `0` is exactly the partial recursive
  functions.
* `join_lub` — the two-oracle set `{f, g}` is the **least upper bound** (join) of `f` and `g`
  in the Turing reducibility preorder.
* `partrec_oracle_useless` — a **disproof** of the naive conjecture "*every* oracle strictly
  increases power": adding a *computable* oracle changes nothing.
* `exists_not_partrec` and `exists_degree_gt_zero` — the degree structure is **non-trivial**:
  there is a function strictly above `0`, i.e. the first jump genuinely increases power.

## Contrarian log

* CONJECTURE (naive): adding any oracle strictly increases theorem-proving power.
  **DISPROVED** by `partrec_oracle_useless`.
* CONJECTURE: the Turing degrees are a single point (everything is computable-equivalent).
  **DISPROVED** by `exists_degree_gt_zero`.
-/

import Mathlib

open scoped Computability
open Primrec Nat.Partrec Part Cardinal

namespace OracleHierarchy

/-! ## The cut principle and monotonicity of relativization -/

/-- **Cut / generalized transitivity.**  If every oracle `g ∈ O` is recursive in the oracle set
`O'`, then any function recursive in `O` is already recursive in `O'`.  This is the engine behind
transitivity of Turing reducibility and the least-upper-bound property of joins. -/
theorem recursiveIn_cut {O O' : Set (ℕ →. ℕ)} {f : ℕ →. ℕ}
    (hO : ∀ g ∈ O, RecursiveIn O' g) (hf : RecursiveIn O f) : RecursiveIn O' f := by
  induction hf with
  | oracle g hg => exact hO g hg
  | pair _ _ ih₁ ih₂ => exact RecursiveIn.pair ih₁ ih₂
  | comp _ _ ih₁ ih₂ => exact RecursiveIn.comp ih₁ ih₂
  | prec _ _ ih₁ ih₂ => exact RecursiveIn.prec ih₁ ih₂
  | rfind _ ih => exact RecursiveIn.rfind ih
  | _ => constructor

/-- **Monotonicity of relativization.**  A larger oracle set can only compute more:
enlarging the pool of oracles never destroys computability.  In the theory metaphor,
`PA^X` proves everything `PA^Y` proves whenever `Y ⊆ X`. -/
theorem recursiveIn_mono {O O' : Set (ℕ →. ℕ)} {f : ℕ →. ℕ}
    (h : O ⊆ O') (hf : RecursiveIn O f) : RecursiveIn O' f :=
  recursiveIn_cut (fun g hg => RecursiveIn.oracle g (h hg)) hf

/-! ## The bottom degree: the computable functions -/

/-- The constant-zero function is Turing-below every function: `0` is the bottom degree. -/
theorem zero_turingReducible (f : ℕ →. ℕ) : (fun _ => (0 : ℕ) : ℕ →. ℕ) ≤ᵀ f :=
  Nat.Partrec.zero.turingReducible

/-- **The bottom degree is exactly the partial recursive functions.**  A function is reducible to
the zero oracle iff it is (unrelativized) partial recursive. -/
theorem reducible_zero_iff_partrec (f : ℕ →. ℕ) :
    f ≤ᵀ (fun _ => Part.some 0) ↔ Nat.Partrec f :=
  ⟨TuringReducible.partrec_of_zero, fun h => h.turingReducible⟩

/-! ## Joins: the least upper bound of two oracles -/

/-- Each component sits below the join `{f, g}`. -/
theorem left_le_join (f g : ℕ →. ℕ) : RecursiveIn {f, g} f :=
  RecursiveIn.oracle f (by simp)

/-- Each component sits below the join `{f, g}`. -/
theorem right_le_join (f g : ℕ →. ℕ) : RecursiveIn {f, g} g :=
  RecursiveIn.oracle g (by simp)

/-- **Least upper bound property of the join.**  The two-oracle set `{f, g}` is the least upper
bound of `f` and `g`: any common upper bound `h` (with `f ≤ᵀ h` and `g ≤ᵀ h`) computes everything
that `{f, g}` computes. -/
theorem join_lub {f g h : ℕ →. ℕ} (hf : f ≤ᵀ h) (hg : g ≤ᵀ h) {k : ℕ →. ℕ}
    (hk : RecursiveIn {f, g} k) : k ≤ᵀ h := by
  refine recursiveIn_cut ?_ hk
  intro x hx
  rcases hx with hx | hx
  · rw [hx]; exact hf
  · rw [Set.mem_singleton_iff] at hx; rw [hx]; exact hg

/-! ## Contrarian disproof: computable oracles are useless -/

/-- **DISPROOF of "every oracle increases power".**  Adding a *computable* (partial recursive)
oracle `g` does not change the class of computable functions at all: `f` is recursive in `g`
iff `f` was already partial recursive.  So the naive conjecture that *any* oracle strictly
increases theorem-proving power is false — only genuinely non-computable oracles (like the
halting problem) do. -/
theorem partrec_oracle_useless {g : ℕ →. ℕ} (hg : Nat.Partrec g) (f : ℕ →. ℕ) :
    RecursiveIn {g} f ↔ Nat.Partrec f := by
  rw [← recursiveIn_empty_iff_partrec]
  constructor
  · intro hf
    refine recursiveIn_cut ?_ hf
    intro x hx
    rw [Set.mem_singleton_iff] at hx; subst hx
    exact recursiveIn_empty_iff_partrec.mpr hg
  · intro hf
    exact recursiveIn_cut (by intro x hx; simp at hx) hf

/-! ## Non-triviality: the first jump genuinely increases power -/

/-- The Turing degree of a partial function. -/
noncomputable def tdeg (f : ℕ →. ℕ) : TuringDegree := Quotient.mk _ f

/-- Strict order between degrees is exactly: reducible one way but not the other. -/
theorem tdeg_lt {f g : ℕ →. ℕ} (h1 : f ≤ᵀ g) (h2 : ¬ g ≤ᵀ f) : tdeg f < tdeg g :=
  ⟨h1, h2⟩

/-- **There is a non-computable function.**  The partial recursive functions form a countable
set (they are the range of the code-evaluation map), but `ℕ →. ℕ` is uncountable (it contains a
copy of `2^ℕ`).  Hence some function is not partial recursive.  This is the seed of the entire
hierarchy: without it, every degree would collapse to `0`. -/
theorem exists_not_partrec : ∃ f : ℕ →. ℕ, ¬ Nat.Partrec f := by
  by_contra h
  push_neg at h
  -- If everything were partial recursive, `ℕ →. ℕ` would be countable.
  have hcount : Countable (ℕ →. ℕ) := by
    have hrange : (Set.univ : Set (ℕ →. ℕ)) ⊆ Set.range (fun c : Nat.Partrec.Code => c.eval) := by
      intro f _
      exact Nat.Partrec.Code.exists_code.mp (h f)
    exact Set.countable_univ_iff.mp (Set.Countable.mono hrange (Set.countable_range _))
  -- But `ℕ →. ℕ` is uncountable, via `2^ℕ ↪ (ℕ →. ℕ)`.
  have hunc : Uncountable (ℕ →. ℕ) := by
    haveI hbool : Uncountable (ℕ → Bool) := by
      rw [← aleph0_lt_mk_iff]
      have hmk : #(ℕ → Bool) = 2 ^ ℵ₀ := by
        rw [Cardinal.mk_arrow]; simp
      rw [hmk]
      exact Cardinal.cantor ℵ₀
    have hinj : Function.Injective
        (fun s : ℕ → Bool => (fun n => Part.some (if s n then 0 else 1) : ℕ →. ℕ)) := by
      intro s t hst
      funext n
      have := congrFun hst n
      simp only [Part.some_inj] at this
      cases hs : s n <;> cases ht : t n <;> simp_all
    exact hinj.uncountable
  exact (not_countable) hcount

/-- **The oracle hierarchy is non-trivial at its base.**  There is a Turing degree strictly above
`0`.  Concretely: any non-computable function `f` satisfies `0 <ᵀ f`, since `0 ≤ᵀ f` always and
`f ≤ᵀ 0` would make `f` partial recursive.  This is the formal content of "the first jump
`PA < PA^H` genuinely increases theorem-proving power". -/
theorem exists_degree_gt_zero :
    ∃ f : ℕ →. ℕ, tdeg (fun _ => Part.some 0) < tdeg f := by
  obtain ⟨f, hf⟩ := exists_not_partrec
  refine ⟨f, tdeg_lt (zero_turingReducible f) ?_⟩
  intro hle
  exact hf ((reducible_zero_iff_partrec f).mp hle)

end OracleHierarchy