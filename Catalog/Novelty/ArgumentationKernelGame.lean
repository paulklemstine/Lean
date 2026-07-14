import Mathlib

/-!
# The topology of argumentation, X: the kernel/game bridge

This file is **self-contained** and builds a cross-domain bridge connecting three
areas that are usually developed independently:

* **Dung argumentation semantics** — *stable extensions* of an argumentation
  framework `(A, R)` (`R a b` reads "`a` attacks `b`").
* **Digraph theory** — *kernels* of a directed graph (an independent, absorbing
  set), a notion going back to von Neumann and Morgenstern.
* **Combinatorial game theory** — the set of *P-positions* (losing positions for
  the player to move) of the game whose move relation is `M` (`M p q` reads
  "from `p` one may move to `q`").

The unifying observation is elementary but load-bearing:

> A **stable extension** of the attack relation `R` is exactly a **kernel** of the
> transposed digraph `flip R`, which is exactly the **P-position set** of the game
> with move relation `flip R`.

Building on this dictionary we prove genuinely non-definitional results:

## The dictionary

* `stable_iff_kernel`        — stable extensions of `R` = kernels of `flip R`.
* `stable_iff_gameSolution`  — stable extensions of `R` = solutions (P-position
  sets) of the reversed-attack game.
* `terminal_mem_of_kernel`   — terminal positions are always losing (in the
  kernel): the normal-play convention falls out of the kernel axioms.

## Non-existence: the odd cycle

* `no_kernel_cyc3` / `no_stable_cyc3` — **the directed 3-cycle has no kernel and
  the 3-cycle framework has no stable extension.**  This is the classical
  obstruction (odd cycles) and explains why, with *no* well-foundedness
  hypothesis, stable extensions need not exist — in contrast to the maximal
  (preferred) extensions of the earlier cycles, which always exist.

## Well-founded existence and uniqueness (Zermelo determinacy)

For a **well-founded** move relation the game is *determined*: there is a unique
P-position set, computed by the standard game recursion "a position is losing iff
every move leads to a winning position".

* `isLoss`                   — the P-position predicate via well-founded recursion.
* `isLoss_iff`               — its defining fixed-point equation.
* `kernel_isLoss`            — the P-positions form a kernel.
* `kernel_unique`            — a well-founded digraph has at most one kernel.
* `exists_unique_kernel`     — **a well-founded digraph has a unique kernel.**
* `wf_game_determined`       — **every well-founded game has a unique solution**
  (a determinacy theorem in the spirit of Zermelo).
* `exists_unique_stable_of_wf` — **a well-founded argumentation framework has a
  unique stable extension.**  Existence of stable extensions, which fails on the
  odd cycle, is *restored* by well-foundedness.
-/

namespace ArgKernelGame

open Function

variable {A : Type*}

/-! ## Argumentation semantics (self-contained) -/

/-- `S` is *conflict-free*: no argument in `S` attacks another in `S`. -/
def ConflictFree (R : A → A → Prop) (S : Set A) : Prop := ∀ a ∈ S, ∀ b ∈ S, ¬ R a b

/-- `S` is a **stable extension**: conflict-free and it attacks every argument it
does not contain. -/
def Stable (R : A → A → Prop) (S : Set A) : Prop :=
  ConflictFree R S ∧ ∀ a, a ∉ S → ∃ b ∈ S, R b a

/-! ## Digraph kernels -/

/-- `S` is an *independent set* of the digraph `D`: no edge joins two members. -/
def Independent (D : A → A → Prop) (S : Set A) : Prop := ∀ a ∈ S, ∀ b ∈ S, ¬ D a b

/-- `S` is *absorbing* (dominating): every vertex outside `S` has an edge *into*
`S`. -/
def Absorbing (D : A → A → Prop) (S : Set A) : Prop := ∀ a, a ∉ S → ∃ b ∈ S, D a b

/-- `S` is a **kernel** of the digraph `D`: an independent, absorbing set. -/
def Kernel (D : A → A → Prop) (S : Set A) : Prop := Independent D S ∧ Absorbing D S

/-! ## Combinatorial games -/

/-- A **game solution** for the move relation `M`: the set `P` of P-positions
(losing positions for the player to move) is precisely a kernel of the move
digraph — no move from a losing position reaches a losing position, and from every
non-losing position there is a move to a losing one. -/
def GameSolution (M : A → A → Prop) (P : Set A) : Prop := Kernel M P

/-! ## The dictionary -/

/-
**Bridge (argumentation ⋈ graph theory).**  A set is a stable extension of the
attack relation `R` iff it is a kernel of the transposed digraph `flip R`.
-/
theorem stable_iff_kernel (R : A → A → Prop) (S : Set A) :
    Stable R S ↔ Kernel (flip R) S := by
  constructor <;> intro h;
  · exact ⟨ fun a ha b hb => h.1 b hb a ha, fun a ha => h.2 a ha ⟩;
  · exact ⟨ fun a ha b hb hab => h.1 b hb a ha hab, fun a ha => h.2 a ha ⟩

/-- **Bridge (argumentation ⋈ game theory).**  Stable extensions of `R` are
exactly the P-position solutions of the reversed-attack game `flip R`. -/
theorem stable_iff_gameSolution (R : A → A → Prop) (S : Set A) :
    Stable R S ↔ GameSolution (flip R) S :=
  stable_iff_kernel R S

/-
**Terminal positions are losing.**  A position with no outgoing move must lie
in every kernel — the normal-play convention "no move ⇒ you lose" is forced by the
kernel axioms rather than assumed.
-/
theorem terminal_mem_of_kernel {M : A → A → Prop} {P : Set A} (hK : Kernel M P)
    {a : A} (hterm : ∀ b, ¬ M a b) : a ∈ P := by
  exact Classical.not_not.1 fun ha => hK.2 a ha |> fun ⟨ _, h, h' ⟩ => hterm _ h'

/-! ## Non-existence on the odd cycle -/

/-- The directed **3-cycle** `0 → 1 → 2 → 0`. -/
def cyc3 : Fin 3 → Fin 3 → Prop := fun a b => b = a + 1

/-
**The directed 3-cycle has no kernel.**  This is the classical odd-cycle
obstruction to kernel existence (von Neumann–Morgenstern / Richardson).
-/
theorem no_kernel_cyc3 : ¬ ∃ S : Set (Fin 3), Kernel cyc3 S := by
  simp +decide [ Kernel, Independent, Absorbing ];
  simp +decide [ Fin.forall_fin_succ, Fin.exists_fin_succ, cyc3 ];
  grind

/-
**The 3-cycle argumentation framework has no stable extension.**  Transported
across the dictionary, the odd-cycle obstruction says: with no well-foundedness
hypothesis, stable extensions can fail to exist.
-/
theorem no_stable_cyc3 : ¬ ∃ S : Set (Fin 3), Stable cyc3 S := by
  simp +decide [ stable_iff_kernel, Kernel, Independent, Absorbing ];
  simp +decide [ flip ];
  simp +decide [ Fin.forall_fin_succ, Fin.exists_fin_succ, cyc3 ];
  grind

/-! ## Well-founded existence and uniqueness -/

/-- The **P-position predicate** built by the standard game recursion: a position
`a` is *losing* iff every move `a → b` leads to a non-losing position `b`.  The
recursion is over the well-founded reverse-move relation `flip M` (no infinite
play). -/
noncomputable def isLoss (M : A → A → Prop) (hwf : WellFounded (flip M)) : A → Prop :=
  hwf.fix (fun a ih => ∀ b, (h : flip M b a) → ¬ ih b h)

/-
The defining fixed-point equation of `isLoss`.
-/
theorem isLoss_iff (M : A → A → Prop) (hwf : WellFounded (flip M)) (a : A) :
    isLoss M hwf a ↔ ∀ b, M a b → ¬ isLoss M hwf b := by
  rw [ isLoss ];
  grind +suggestions

/-
**The P-positions form a kernel** of the move digraph: the game recursion
produces a genuine solution.
-/
theorem kernel_isLoss (M : A → A → Prop) (hwf : WellFounded (flip M)) :
    Kernel M {a | isLoss M hwf a} := by
  unfold Kernel;
  simp +decide [ Independent, Absorbing ];
  grind +suggestions

/-
**A well-founded digraph has at most one kernel.**  Any kernel `S` agrees with
the P-position set, by well-founded induction along `flip M`.
-/
theorem kernel_unique (M : A → A → Prop) (hwf : WellFounded (flip M)) {S : Set A}
    (hS : Kernel M S) : S = {a | isLoss M hwf a} := by
  ext a;
  induction' a using hwf.induction with a ih;
  rw [ Set.mem_setOf_eq, isLoss_iff ];
  constructor;
  · exact fun ha b hb => fun hb' => hS.1 a ha b ( ih b hb |>.2 hb' ) hb;
  · exact fun h => Classical.not_not.1 fun ha => by obtain ⟨ b, hbS, hb ⟩ := hS.2 a ha; specialize ih b hb; aesop;

/-
**A well-founded digraph has a unique kernel.**
-/
theorem exists_unique_kernel (M : A → A → Prop) (hwf : WellFounded (flip M)) :
    ∃! S : Set A, Kernel M S := by
  refine' ⟨ _, ⟨ kernel_isLoss M hwf, fun S hS => kernel_unique M hwf hS ⟩ ⟩

/-- **Zermelo determinacy.**  Every well-founded game has a unique solution: the
set of P-positions is uniquely determined. -/
theorem wf_game_determined (M : A → A → Prop) (hwf : WellFounded (flip M)) :
    ∃! P : Set A, GameSolution M P :=
  exists_unique_kernel M hwf

/-
**A well-founded argumentation framework has a unique stable extension.**
Well-foundedness of the attack relation restores the existence of stable
extensions that failed on the odd cycle (`no_stable_cyc3`), and forces uniqueness.
-/
theorem exists_unique_stable_of_wf (R : A → A → Prop) (hwf : WellFounded R) :
    ∃! S : Set A, Stable R S := by
  obtain ⟨ S, hS₁, hS₂ ⟩ := exists_unique_kernel ( flip R ) ( show WellFounded ( flip ( flip R ) ) from hwf );
  exact ⟨ S, by simpa only [ stable_iff_kernel ] using hS₁, fun T hT => hS₂ T ( by simpa only [ stable_iff_kernel ] using hT ) ⟩

end ArgKernelGame