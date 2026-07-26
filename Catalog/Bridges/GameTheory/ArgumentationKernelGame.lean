import Mathlib

/-!
# Argumentation, kernels, and terminating games

A self-contained dictionary between stable extensions, graph kernels, and
normal-play P-positions.  The final section advances the dictionary from the
odd three-cycle obstruction to a positive four-cycle example.
-/

namespace ArgumentationKernelGame

variable {α : Type*}

/-- A set is independent and absorbs every vertex outside it. -/
def Kernel (R : α → α → Prop) (K : Set α) : Prop :=
  (∀ ⦃x⦄, x ∈ K → ∀ ⦃y⦄, y ∈ K → ¬ R x y) ∧
  (∀ ⦃x⦄, x ∉ K → ∃ y ∈ K, R x y)

/-- A conflict-free set attacking every argument outside it. -/
def Stable (R : α → α → Prop) (S : Set α) : Prop :=
  (∀ ⦃x⦄, x ∈ S → ∀ ⦃y⦄, y ∈ S → ¬ R x y) ∧
  (∀ ⦃x⦄, x ∉ S → ∃ y ∈ S, R y x)

/-- A consistent normal-play labelling by P-positions. -/
def GameSolution (R : α → α → Prop) (P : Set α) : Prop :=
  ∀ x, x ∈ P ↔ ∀ y, R x y → y ∉ P

/-
Stable semantics is precisely kernel semantics after reversing arrows.
-/
theorem stable_iff_kernel (R : α → α → Prop) (S : Set α) :
    Stable R S ↔ Kernel (flip R) S := by
  unfold Stable Kernel; aesop;

/-
Kernels are precisely consistent P-position solutions.
-/
theorem kernel_iff_gameSolution (R : α → α → Prop) (K : Set α) :
    Kernel R K ↔ GameSolution R K := by
  grind +locals

/-
The three vocabularies therefore form one dictionary.
-/
theorem stable_iff_gameSolution (R : α → α → Prop) (S : Set α) :
    Stable R S ↔ GameSolution (flip R) S := by
  rw [ ← kernel_iff_gameSolution, stable_iff_kernel ]

/-
A position with no move belongs to every kernel.
-/
theorem terminal_mem_of_kernel {R : α → α → Prop} {K : Set α}
    (hK : Kernel R K) {x : α} (hx : ∀ y, ¬ R x y) : x ∈ K := by
  by_contra h;
  exact absurd ( hK.2 h ) ( by tauto )

section WellFounded

variable (R : α → α → Prop) (hwf : WellFounded (flip R))

/-- The recursively defined predicate of losing positions. -/
noncomputable def isLoss : α → Prop :=
  hwf.fix fun x rec => ∀ y, ∀ h : R x y, ¬ rec y h

/-
The recursion equation for losing positions.
-/
theorem isLoss_iff (x : α) :
    isLoss R hwf x ↔ ∀ y, R x y → ¬ isLoss R hwf y := by
  rw [ isLoss, WellFounded.fix_eq ]

/-
Recursive losing positions form a graph kernel.
-/
theorem kernel_isLoss : Kernel R {x | isLoss R hwf x} := by
  refine ⟨ ?_, fun x hx => ?_ ⟩;
  · grind +suggestions;
  · grind +suggestions

include hwf in
/-- A kernel of a well-founded digraph is unique. -/
theorem kernel_unique {K L : Set α} (hK : Kernel R K) (hL : Kernel R L) : K = L := by
  ext x;
  induction' x using hwf.induction with x ih;
  constructor <;> intro hx <;> by_contra h;
  · obtain ⟨ y, hyL, hyx ⟩ := hL.2 h;
    exact hK.1 hx ( ih y hyx |>.2 hyL ) hyx;
  · obtain ⟨ y, hyK, hyx ⟩ := hK.2 h;
    exact hL.1 hx ( ih y hyx |>.1 hyK ) hyx

include hwf in
/-- Every well-founded digraph has exactly one kernel. -/
theorem exists_unique_kernel : ∃! K : Set α, Kernel R K := by
  refine' ⟨ _, kernel_isLoss R hwf, fun K hK => kernel_unique R hwf hK ( kernel_isLoss R hwf ) ⟩

include hwf in
/-- Every terminating normal-play game has exactly one P-position solution. -/
theorem wf_game_determined : ∃! P : Set α, GameSolution R P := by
  have := @exists_unique_kernel;
  convert this R hwf using 1;
  ext; simp +decide [ kernel_iff_gameSolution ] ;

/-
A well-founded attack relation has exactly one stable extension.
-/
theorem exists_unique_stable_of_wf (hattack : WellFounded R) :
    ∃! S : Set α, Stable R S := by
  convert exists_unique_kernel ( flip R ) with K L;
  simp +decide [ stable_iff_kernel ];
  exact Or.inl ( by simpa [ flip ] using hattack )

end WellFounded

section Cycles

/-- The directed three-cycle. -/
def cyc3 : Fin 3 → Fin 3 → Prop := fun x y =>
  (x = 0 ∧ y = 1) ∨ (x = 1 ∧ y = 2) ∨ (x = 2 ∧ y = 0)

/-
The directed three-cycle has no kernel.
-/
theorem no_kernel_cyc3 : ¬ ∃ K : Set (Fin 3), Kernel cyc3 K := by
  simp +decide [ Kernel, cyc3 ];
  grind

/-
Consequently the directed three-cycle has no stable extension.
-/
theorem no_stable_cyc3 : ¬ ∃ S : Set (Fin 3), Stable cyc3 S := by
  simp +decide [ Stable ];
  simp +decide [ Fin.forall_fin_succ, Fin.exists_fin_succ, cyc3 ];
  grind

/-- The directed four-cycle. -/
def cyc4 : Fin 4 → Fin 4 → Prop := fun x y =>
  (x = 0 ∧ y = 1) ∨ (x = 1 ∧ y = 2) ∨
  (x = 2 ∧ y = 3) ∨ (x = 3 ∧ y = 0)

/-
The alternating vertices form a kernel of the even four-cycle.
-/
theorem even_kernel_cyc4 : Kernel cyc4 ({0, 2} : Set (Fin 4)) := by
  constructor; all_goals simp +decide [ cyc4 ]

/-
Reversing the alternating kernel gives a stable extension of the four-cycle.
-/
theorem stable_cyc4 : Stable cyc4 ({0, 2} : Set (Fin 4)) := by
  rw [stable_iff_kernel]
  simp +decide [Kernel, cyc4, flip, Fin.forall_fin_succ]

/-
The four-cycle has two distinct stable extensions, unlike well-founded games.
-/
theorem two_stable_cyc4 :
    Stable cyc4 ({0, 2} : Set (Fin 4)) ∧
    Stable cyc4 ({1, 3} : Set (Fin 4)) ∧
    ({0, 2} : Set (Fin 4)) ≠ {1, 3} := by
  refine ⟨stable_cyc4, ?_, by simp +decide [Set.ext_iff]⟩
  constructor <;> simp +decide [cyc4]

end Cycles

end ArgumentationKernelGame