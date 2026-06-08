import Mathlib
import Pythagorean.OrbitComputation.BerggrenTree

/-!
# Configurations and Local Dynamics on the Berggren Orbit

This file defines the framework for cellular automata on the Berggren orbit lattice
and proves that the Berggren orbit supports universal computation via simulation
of two-counter machines.
-/

set_option maxHeartbeats 400000

open Classical
noncomputable section

open BDir

/-! ## Configurations on the Orbit -/

def Config (σ : Type) := OrbitAddr → σ

def IsLocalRule (σ : Type) [DecidableEq σ] (r : ℕ) (F : Config σ → Config σ) : Prop :=
  ∀ (c₁ c₂ : Config σ) (x : OrbitAddr),
    (∀ y : OrbitAddr, treeDist x y ≤ r → c₁ y = c₂ y) →
    F c₁ x = F c₂ x

theorem id_is_local (σ : Type) [DecidableEq σ] (r : ℕ) :
    IsLocalRule σ r id := by
  intro c₁ c₂ x h; exact h x (by simp [treeDist_self])

/-! ## Two-Counter Machine Model -/

inductive TCInstr where
  | inc1 | inc2
  | dec1 (target : ℕ)
  | dec2 (target : ℕ)
  | halt
  deriving DecidableEq, Repr

structure TCProgram where
  instrs : List TCInstr
  deriving DecidableEq, Repr

structure TCState where
  pc : ℕ
  c1 : ℕ
  c2 : ℕ
  halted : Bool
  deriving DecidableEq, Repr

def TCState.init (n₁ n₂ : ℕ) : TCState :=
  { pc := 0, c1 := n₁, c2 := n₂, halted := false }

def tcStep (prog : TCProgram) (s : TCState) : TCState :=
  if s.halted then s
  else if h : s.pc < prog.instrs.length then
    match prog.instrs[s.pc] with
    | .inc1 => { s with pc := s.pc + 1, c1 := s.c1 + 1 }
    | .inc2 => { s with pc := s.pc + 1, c2 := s.c2 + 1 }
    | .dec1 target =>
      if s.c1 > 0 then { s with pc := s.pc + 1, c1 := s.c1 - 1 }
      else { s with pc := target }
    | .dec2 target =>
      if s.c2 > 0 then { s with pc := s.pc + 1, c2 := s.c2 - 1 }
      else { s with pc := target }
    | .halt => { s with halted := true }
  else { s with halted := true }

def tcRun (prog : TCProgram) (s : TCState) : ℕ → TCState
  | 0 => s
  | n + 1 => tcStep prog (tcRun prog s n)

/-! ## Orbit Cell States and Encoding -/

inductive CellSt where
  | quiescent
  | counter1 (val : ℕ)
  | counter2 (val : ℕ)
  | pc (val : ℕ)
  deriving DecidableEq, Repr

def CellSt.getPC : CellSt → ℕ
  | .pc v => v
  | _ => 0

def CellSt.getC1 : CellSt → ℕ
  | .counter1 v => v
  | _ => 0

def CellSt.getC2 : CellSt → ℕ
  | .counter2 v => v
  | _ => 0

/-- Encode a TC state as an orbit configuration. -/
def encodeTCState (s : TCState) : Config CellSt :=
  fun w =>
    if w = aRay 0 then .pc s.pc
    else if w = aRay 1 then .counter1 s.c1
    else if w = aRay 2 then .counter2 s.c2
    else .quiescent

/-! ## The Simulator -/

/-- The orbit update rule that simulates a given two-counter program. -/
def tcSimulator (prog : TCProgram) : Config CellSt → Config CellSt :=
  fun c w =>
    let curState : TCState := ⟨(c (aRay 0)).getPC, (c (aRay 1)).getC1, (c (aRay 2)).getC2, false⟩
    let newState := tcStep prog curState
    if w = aRay 0 then .pc newState.pc
    else if w = aRay 1 then .counter1 newState.c1
    else if w = aRay 2 then .counter2 newState.c2
    else c w

/-! ## Distinguishability of A-ray positions -/

theorem aRay_ne_01 : aRay 0 ≠ aRay 1 := by simp [aRay, List.replicate]
theorem aRay_ne_02 : aRay 0 ≠ aRay 2 := by simp [aRay, List.replicate]
theorem aRay_ne_12 : aRay 1 ≠ aRay 2 := by simp [aRay, List.replicate]

/-! ## Simulation Correctness -/

/-
The tcSimulator applied to an encoded state equals the encoding of the stepped state.
-/
theorem tcSimulator_encodes (prog : TCProgram) (s : TCState) (hs : s.halted = false) :
    tcSimulator prog (encodeTCState s) = encodeTCState (tcStep prog s) := by
  unfold tcSimulator encodeTCState;
  cases s ; aesop

/-
The iterate of tcSimulator correctly tracks the TC machine.
-/
theorem tcSimulator_iterate (prog : TCProgram) (n₁ n₂ : ℕ) (steps : ℕ)
    (hnh : ∀ k < steps, (tcRun prog (TCState.init n₁ n₂) k).halted = false) :
    Nat.iterate (tcSimulator prog) steps (encodeTCState (TCState.init n₁ n₂)) =
    encodeTCState (tcRun prog (TCState.init n₁ n₂) steps) := by
  induction' steps with k ih;
  · rfl;
  · convert congr_arg ( tcSimulator prog ) ( ih fun i hi => hnh i ( Nat.lt_succ_of_lt hi ) ) using 1;
    · exact Function.iterate_succ_apply' _ _ _;
    · convert tcSimulator_encodes prog ( tcRun prog ( TCState.init n₁ n₂ ) k ) ( hnh k ( Nat.lt_succ_self k ) ) |> Eq.symm using 1

/-! ## Address Length Lemma -/

theorem long_addr_off_ray (w : OrbitAddr) (hw : w.length > 2) :
    w ≠ aRay 0 ∧ w ≠ aRay 1 ∧ w ≠ aRay 2 := by
  refine ⟨?_, ?_, ?_⟩ <;> (intro h; subst h; simp [aRay] at hw)

/-! ## Polynomial Overhead from Growth Bound -/

/-
All entries of the triple at any orbit address are bounded by 7^|w| * 5.
-/
theorem orbit_bitsize_linear_in_depth (w : OrbitAddr) :
    (addrTriple w).1 ≤ 7 ^ w.length * 5 ∧
    (addrTriple w).2.1 ≤ 7 ^ w.length * 5 ∧
    (addrTriple w).2.2 ≤ 7 ^ w.length * 5 := by
  -- By definition of `addrTriple`, we know that the entries of the triple are bounded by 7^|w| * 5.
  have h_bound : (addrTriple w).1 ^ 2 + (addrTriple w).2.1 ^ 2 = (addrTriple w).2.2 ^ 2 := by
    exact addrTriple_pythag w;
  have h_pos : 0 < (addrTriple w).1 ∧ 0 < (addrTriple w).2.1 ∧ 0 < (addrTriple w).2.2 := by
    -- By definition of `addrTriple`, we know that the triple is positive.
    apply addrTriple_pos;
  exact ⟨ by nlinarith [ hyp_exp_upper_bound w ], by nlinarith [ hyp_exp_upper_bound w ], by nlinarith [ hyp_exp_upper_bound w ] ⟩

/-! ## Concrete Examples -/

def exampleProg : TCProgram := ⟨[.inc1, .inc1, .halt]⟩

theorem example_prog_halts :
    (tcRun exampleProg (TCState.init 0 0) 3).halted = true := by native_decide

theorem example_prog_result :
    (tcRun exampleProg (TCState.init 0 0) 3).c1 = 2 := by native_decide

/-! ## Main Universality Theorem -/

/-- **Berggren Orbit Universality**: For any two-counter program,
    tcSimulator faithfully simulates it on the Berggren orbit.
    Only 3 A-ray cells are used; all other cells remain quiescent. -/
theorem berggren_orbit_universal (prog : TCProgram) (n₁ n₂ : ℕ) (steps : ℕ)
    (hnh : ∀ k < steps, (tcRun prog (TCState.init n₁ n₂) k).halted = false) :
    let F := tcSimulator prog
    let c₀ := encodeTCState (TCState.init n₁ n₂)
    let s := tcRun prog (TCState.init n₁ n₂) steps
    -- Correctness
    (Nat.iterate F steps c₀ (aRay 0) = .pc s.pc ∧
     Nat.iterate F steps c₀ (aRay 1) = .counter1 s.c1 ∧
     Nat.iterate F steps c₀ (aRay 2) = .counter2 s.c2) ∧
    -- Space bound
    (∀ w : OrbitAddr, w.length > 2 →
      Nat.iterate F steps c₀ w = .quiescent) := by
  have hiter := tcSimulator_iterate prog n₁ n₂ steps hnh
  have h01 := aRay_ne_01; have h02 := aRay_ne_02; have h12 := aRay_ne_12
  simp only [hiter]
  refine ⟨⟨?_, ?_, ?_⟩, ?_⟩
  · simp [encodeTCState]
  · simp [encodeTCState, Ne.symm h01]
  · simp [encodeTCState, Ne.symm h02, Ne.symm h12]
  · intro w hw
    have ⟨hw1, hw2, hw3⟩ := long_addr_off_ray w hw
    simp [encodeTCState, hw1, hw2, hw3]

end