/-
# Tropical ε-Rank: Structural Properties

This file proves the key structural properties of the tropical ε-rank
complexity invariant:
- Nonemptiness: every function on a finite grid has finite tropical ε-rank
- Monotonicity: larger ε allows fewer terms
- Max-subadditivity: the rank of max(f, g) is bounded by the sum of ranks
-/
import Computation.TropicalApprox.Defs
import Computation.TropicalApprox.FiniteExact

open Finset TropicalApprox

namespace TropicalApprox

/-! ## RealizesWithin monotonicity in ε -/

/-
If n terms realize f within ε₁, they also realize f within any ε₂ ≥ ε₁.
-/
lemma RealizesWithin.mono_eps {X Y : Type*} [Fintype X] [Fintype Y]
    (f : X → Y → ℝ) {ε₁ ε₂ : ℝ} {n : ℕ}
    (hε : ε₁ ≤ ε₂) (h : RealizesWithin f ε₁ n) :
    RealizesWithin f ε₂ n := by
  obtain ⟨ ts, hts ⟩ := h;
  exact ⟨ ts, fun x y => ⟨ fun i => by linarith [ hts x y |>.1 i ], by obtain ⟨ i, hi ⟩ := hts x y |>.2; exact ⟨ i, by linarith ⟩ ⟩ ⟩

/-! ## RealizesWithin monotonicity in n -/

/-
If n terms realize f within ε, then n + m terms also do
    (by extending with dummy terms).
-/
lemma RealizesWithin.mono_n {X Y : Type*} [Fintype X] [Fintype Y]
    (f : X → Y → ℝ) {ε : ℝ} {n m : ℕ}
    (h : RealizesWithin f ε n) :
    RealizesWithin f ε (n + m) := by
  by_cases hn : n = 0;
  · cases isEmpty_or_nonempty X <;> cases isEmpty_or_nonempty Y <;> simp_all +decide [ RealizesWithin ];
    · exact Or.inr ⟨ ⟨ 0, fun _ => 0, fun _ => 0 ⟩ ⟩;
    · exact Or.inr ⟨ ⟨ 0, fun _ => 0, fun _ => 0 ⟩ ⟩;
    · exact Or.inr ⟨ ⟨ 0, fun _ => 0, fun _ => 0 ⟩ ⟩;
    · aesop;
  · obtain ⟨ ts, hts ⟩ := h;
    refine' ⟨ fun i => if hi : i.val < n then ts ⟨ i.val, hi ⟩ else ts ⟨ 0, Nat.pos_of_ne_zero hn ⟩, fun x y => ⟨ _, _ ⟩ ⟩ <;> simp_all +decide;
    · intro i; split_ifs <;> [ exact hts x y |>.1 _; exact hts x y |>.1 _ ] ;
    · obtain ⟨ i, hi ⟩ := hts x y |>.2; use ⟨ i, by linarith [ Fin.is_lt i ] ⟩ ; aesop;

/-! ## Nonemptiness of tropical rank set -/

/-
Exact representation implies `RealizesWithin f 0 n`.
-/
lemma realizesWithin_zero_of_exact {X Y : Type*} [Fintype X] [Fintype Y]
    (f : X → Y → ℝ) (n : ℕ)
    (h : ∃ ts : Fin n → MaxPlusTerm X Y,
      ∀ x y, (∀ i, (ts i).eval x y ≤ f x y) ∧ (∃ i, (ts i).eval x y = f x y)) :
    RealizesWithin f 0 n := by
  exact ⟨ h.choose, fun x y => ⟨ fun i => le_trans ( h.choose_spec x y |>.1 i ) ( by norm_num ), by obtain ⟨ i, hi ⟩ := h.choose_spec x y |>.2; exact ⟨ i, by norm_num [ hi ] ⟩ ⟩ ⟩

/-
The tropical ε-rank set is nonempty for any ε ≥ 0 on nonempty finite types.
-/
theorem tropicalRankEpsSet_nonempty
    {X Y : Type*} [Fintype X] [Fintype Y] [DecidableEq X] [DecidableEq Y]
    [Nonempty X] [Nonempty Y]
    (f : X → Y → ℝ) {ε : ℝ} (hε : 0 ≤ ε) :
    (tropicalRankEpsSet f ε).Nonempty := by
  obtain ⟨ ts, hts ⟩ := exists_exact_maxplus_representation_finite f;
  -- Apply the lemma that states if n terms realize f within ε₁, they also realize f within ε₂ for ε₂ ≥ ε₁.
  apply Set.nonempty_of_mem; exact RealizesWithin.mono_eps f hε (realizesWithin_zero_of_exact f (Fintype.card X * Fintype.card Y) ⟨ts, hts⟩)

/-! ## Monotonicity of tropical ε-rank -/

/-
**Monotonicity**: larger ε cannot increase the tropical rank.
-/
theorem tropicalRankEps_mono
    {X Y : Type*} [Fintype X] [Fintype Y] [DecidableEq X] [DecidableEq Y]
    [Nonempty X] [Nonempty Y]
    (f : X → Y → ℝ) {ε₁ ε₂ : ℝ}
    (hε₁ : 0 ≤ ε₁) (hε : ε₁ ≤ ε₂) :
    tropicalRankEps f ε₂ ≤ tropicalRankEps f ε₁ := by
  refine' le_csInf _ _
  · exact tropicalRankEpsSet_nonempty f hε₁
  · exact fun n hn => Nat.sInf_le (RealizesWithin.mono_eps _ hε hn)

/-! ## Max-subadditivity -/

/-
Concatenation of term families for max-subadditivity.
-/
lemma RealizesWithin_max_add {X Y : Type*} [Fintype X] [Fintype Y]
    (f g : X → Y → ℝ) {ε₁ ε₂ : ℝ} {n₁ n₂ : ℕ}
    (hf : RealizesWithin f ε₁ n₁)
    (hg : RealizesWithin g ε₂ n₂) :
    RealizesWithin (fun x y => max (f x y) (g x y)) (max ε₁ ε₂) (n₁ + n₂) := by
  obtain ⟨ ts₁, hts₁ ⟩ := hf
  obtain ⟨ ts₂, hts₂ ⟩ := hg;
  refine' ⟨ Fin.addCases ts₁ ts₂, fun x y ↦ ⟨ _, _ ⟩ ⟩;
  · intro i; cases i using Fin.addCases <;> simp +decide [ * ] ;
    · exact le_trans ( hts₁ x y |>.1 _ ) ( add_le_add ( le_max_left _ _ ) ( le_max_left _ _ ) );
    · exact le_trans ( hts₂ x y |>.1 _ ) ( add_le_add ( le_max_right _ _ ) ( le_max_right _ _ ) );
  · cases max_cases ( f x y ) ( g x y ) <;> cases max_cases ε₁ ε₂ <;> simp +decide [ * ];
    · obtain ⟨ i, hi ⟩ := hts₁ x y |>.2; use Fin.castAdd n₂ i; simp +decide;
      linarith;
    · obtain ⟨ i, hi ⟩ := hts₁ x y |>.2;
      exact ⟨ Fin.castAdd n₂ i, by simpa [ Fin.addCases ] using by linarith ⟩;
    · obtain ⟨ i, hi ⟩ := hts₂ x y |>.2;
      exact ⟨ Fin.natAdd n₁ i, by simpa [ Fin.addCases ] using by linarith ⟩;
    · obtain ⟨ i, hi ⟩ := hts₂ x y |>.2; use Fin.natAdd n₁ i; simp +decide [Fin.addCases]; linarith;

/-
**Max-subadditivity**: the tropical ε-rank of max(f, g) is bounded
    by the sum of the individual ranks. This reflects the fundamental
    algebraic property that taking the maximum of two max-plus expansions
    simply concatenates their term families.
-/
theorem tropicalRankEps_max_add
    {X Y : Type*} [Fintype X] [Fintype Y] [DecidableEq X] [DecidableEq Y]
    [Nonempty X] [Nonempty Y]
    (f g : X → Y → ℝ) {ε₁ ε₂ : ℝ}
    (hε₁ : 0 ≤ ε₁) (hε₂ : 0 ≤ ε₂) :
    tropicalRankEps (fun x y => max (f x y) (g x y)) (max ε₁ ε₂)
      ≤ tropicalRankEps f ε₁ + tropicalRankEps g ε₂ := by
  refine' Nat.sInf_le _;
  apply RealizesWithin_max_add;
  · exact Nat.sInf_mem ( tropicalRankEpsSet_nonempty f hε₁ );
  · exact Nat.sInf_mem ( tropicalRankEpsSet_nonempty g hε₂ )

end TropicalApprox