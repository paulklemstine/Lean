import Mathlib

/-!
# Transfinite cellular automata: limit stages on `ℕ`

This file develops a minimal core theory of *transfinite* cellular automata, focusing
exclusively on the construction of limit stages.

A cellular automaton acts on configurations `Config σ = ℕ → σ` via a radius-`1` local
rule `f : σ → σ → σ → σ`. The successor dynamics is the global update `step f`. To talk
about limit stages we record, for each ordinal stage, the configuration reached so far as
a *history* `H : Ordinal → Config σ`, and we ask that each coordinate be *eventually
constant below* a limit ordinal `λ`. Under that hypothesis the limit configuration exists
and is unique (`limit_exists_unique`), with an explicit characterization
(`limit_characterization`).

The concrete payload is the Boolean `ω`-stage: if a global map `F : Config Bool → Config
Bool` is pointwise inflationary, then along the chain of finite iterates every coordinate
is monotone, hence eventually constant, so the `ω`-limit configuration exists
(`omega_limit_exists`). The local "or" rule `l || c || r` is one such automaton
(`orRule_inflationary`, `orRule_omega_limit_exists`).
-/

namespace TransfiniteCA

open Ordinal

/-- A configuration assigns a state in `σ` to each cell of `ℕ`. -/
def Config (σ : Type*) : Type _ := ℕ → σ

/-- The one-step global update induced by a radius-`1` local rule `f`.
The left neighbour of cell `n` is `n - 1` in natural-number subtraction, so the left
neighbour of cell `0` is `0` itself. -/
def step {σ : Type*} (f : σ → σ → σ → σ) (c : Config σ) : Config σ :=
  fun n => f (c (n - 1)) (c n) (c (n + 1))

/-- A history `h : Ordinal → σ` is eventually constant with value `v` below `lam` if there
is a witness ordinal `β < lam` past which (and still below `lam`) `h` is always `v`. -/
def EventuallyConstBelow {σ : Type*} (h : Ordinal → σ) (v : σ) (lam : Ordinal) : Prop :=
  ∃ β, β < lam ∧ ∀ γ, β ≤ γ → γ < lam → h γ = v

/-- Coordinatewise eventual constancy: each coordinate history of `H` is eventually
constant below `lam`, with value given by the configuration `c`. -/
def EventuallyConstBelowConfig {σ : Type*} (H : Ordinal → Config σ) (c : Config σ)
    (lam : Ordinal) : Prop :=
  ∀ n, EventuallyConstBelow (fun α => H α n) (c n) lam

/--
The eventual value of a coordinate history below `lam` is unique.
-/
theorem eventuallyConstBelow_unique {σ : Type*} {h : Ordinal → σ} {u v : σ} {lam : Ordinal}
    (hu : EventuallyConstBelow h u lam) (hv : EventuallyConstBelow h v lam) : u = v := by
  obtain ⟨ βu, hβu, hu ⟩ := hu
  obtain ⟨ βv, hβv, hv ⟩ := hv;
  rw [ ← hu ( Max.max βu βv ) ( le_max_left _ _ ) ( max_lt hβu hβv ), ← hv ( Max.max βu βv ) ( le_max_right _ _ ) ( max_lt hβu hβv ) ]

/-- Choice of the eventual value at each coordinate, when one exists. -/
noncomputable def limitConfig {σ : Type*} (H : Ordinal → Config σ) (lam : Ordinal)
    (hyp : ∀ n, ∃ v, EventuallyConstBelow (fun α => H α n) v lam) : Config σ :=
  fun n => (hyp n).choose

/--
The constructed limit configuration realizes the eventual value at every coordinate.
-/
theorem limit_characterization {σ : Type*} (H : Ordinal → Config σ) (lam : Ordinal)
    (hyp : ∀ n, ∃ v, EventuallyConstBelow (fun α => H α n) v lam) :
    EventuallyConstBelowConfig H (limitConfig H lam hyp) lam := by
  exact fun n => ( hyp n ).choose_spec

/--
**Limit stage, existence and uniqueness.** If every coordinate history of `H` is
eventually constant below `lam`, then there is a unique configuration whose coordinates are
exactly those eventual values.
-/
theorem limit_exists_unique {σ : Type*} (H : Ordinal → Config σ) (lam : Ordinal)
    (hyp : ∀ n, ∃ v, EventuallyConstBelow (fun α => H α n) v lam) :
    ∃! c : Config σ, EventuallyConstBelowConfig H c lam := by
  refine' ⟨ limitConfig H lam hyp, limit_characterization H lam hyp, _ ⟩;
  intro y hy; funext n; apply eventuallyConstBelow_unique; exact hy n; exact (hyp n).choose_spec;

/-- Pointwise inflationarity of a global map on Boolean configurations. -/
def Inflationary (F : Config Bool → Config Bool) : Prop := ∀ c n, c n ≤ F c n

/--
Along the chain of finite iterates of an inflationary map, every coordinate is a
monotone Boolean sequence.
-/
theorem iterate_monotone (F : Config Bool → Config Bool) (hF : Inflationary F)
    (c0 : Config Bool) (n : ℕ) : Monotone (fun k => (F^[k] c0) n) := by
  refine' monotone_nat_of_le_succ _;
  exact fun k => by simpa only [ Function.iterate_succ_apply' ] using hF _ _;

/--
A monotone Boolean sequence is eventually constant.
-/
theorem bool_monotone_eventually_const (s : ℕ → Bool) (hs : Monotone s) :
    ∃ N, ∀ k, N ≤ k → s k = s N := by
  by_cases h : ∃ j, s j = true;
  · cases' h with N hN; use N; intros k hk; have := hs hk; aesop;
  · aesop

/-- A noncomputable retraction `Ordinal → ℕ` that is a genuine inverse of the cast below
`ω`. It is used to index the chain of finite iterates by ordinals `< ω`. -/
noncomputable def natOfOrdinal (α : Ordinal) : ℕ :=
  if h : α < ω then (lt_omega0.1 h).choose else 0

theorem natOfOrdinal_natCast (n : ℕ) : natOfOrdinal (n : Ordinal) = n := by
  unfold natOfOrdinal;
  split_ifs with h;
  · exact Nat.cast_injective ( lt_omega0.1 h |>.choose_spec.symm );
  · exact False.elim <| h <| Ordinal.nat_lt_omega0 n

theorem natCast_natOfOrdinal {α : Ordinal} (h : α < ω) : (natOfOrdinal α : Ordinal) = α := by
  unfold natOfOrdinal;
  grind

/--
**Boolean `ω`-limit.** For any pointwise inflationary global map `F` and any initial
configuration `c0`, the coordinate histories of the iterate chain (indexed by ordinals
`< ω`) are eventually constant below `ω`, so the `ω`-limit configuration exists uniquely.
-/
theorem omega_limit_exists (F : Config Bool → Config Bool) (hF : Inflationary F)
    (c0 : Config Bool) :
    ∃! c : Config Bool,
      EventuallyConstBelowConfig (fun α => F^[natOfOrdinal α] c0) c ω := by
  apply limit_exists_unique;
  intro n
  obtain ⟨N, hN⟩ : ∃ N, ∀ k, N ≤ k → (F^[k] c0) n = (F^[N] c0) n := by
    have := bool_monotone_eventually_const ( fun k => ( F^[k] c0 ) n ) ( iterate_monotone F hF c0 n ) ; aesop;
  refine' ⟨ _, N, Ordinal.nat_lt_omega0 N, _ ⟩;
  exact F^[N] c0 n;
  intro γ hγ₁ hγ₂; exact hN _ ( by exact_mod_cast natCast_natOfOrdinal hγ₂ ▸ hγ₁ ) ;

/-- The Boolean local "or" rule: a cell becomes `true` if it or either neighbour is. -/
def orRule : Bool → Bool → Bool → Bool := fun l c r => l || c || r

/--
The global step of the "or" rule is pointwise inflationary.
-/
theorem orRule_inflationary : Inflationary (step orRule) := by
  intro c n; simp +decide [ step ] ;
  cases c n <;> simp +decide [ orRule ]

/--
The `ω`-limit of the "or" cellular automaton exists and is unique.
-/
theorem orRule_omega_limit_exists (c0 : Config Bool) :
    ∃! c : Config Bool,
      EventuallyConstBelowConfig (fun α => (step orRule)^[natOfOrdinal α] c0) c ω := by
  convert omega_limit_exists ( step orRule ) orRule_inflationary c0

end TransfiniteCA