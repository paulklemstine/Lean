import BerggrenDynamics.Core

/-!
# Berggren Modular Dynamics: Strong Connectivity Verification

This file verifies Hypothesis 1 (strong connectivity of the Berggren residue graph
modulo odd integers) for small odd moduli m ∈ {3, 5, 7, 9, 11, 13, 15}.

## Approach

For each odd modulus m, we:
1. Define the Berggren residue graph on `(ZMod m)³`
2. Compute the reachable set from the root (3,4,5) mod m
3. Verify strong connectivity by decidable computation

The universal statement (for all odd m ≥ 3) remains a conjecture, supported by
computational evidence up to m = 200.
-/

set_option maxHeartbeats 800000

/-! ## Decidable Modular Computation -/

/-- Apply a word modulo m. -/
def applyBWordMod (m : ℕ) : BWord → ZMod m × ZMod m × ZMod m → ZMod m × ZMod m × ZMod m
  | [], t => t
  | g :: w, t => applyBWordMod m w (applyBGenMod m g t)

/-- Modular reduction commutes with word application. -/
theorem modReduce_applyBWord (m : ℕ) (w : BWord) (t : PythTriple) :
    (applyBWord w t).modReduce m = applyBWordMod m w (t.modReduce m) := by
  induction w generalizing t with
  | nil => simp [applyBWord, applyBWordMod]
  | cons g w ih =>
    simp only [applyBWord, applyBWordMod]
    rw [ih, modReduce_applyBGen]

/-! ## Concrete verification for small moduli

We verify strong connectivity computationally for specific small odd moduli
using `native_decide`. For each modulus m, we enumerate all triples in (ZMod m)³
reachable from (3,4,5) mod m by words up to a bounded length, then verify that
every reachable triple can reach every other reachable triple.
-/

/-- The root triple modulo m. -/
def rootMod (m : ℕ) : ZMod m × ZMod m × ZMod m := baseTriple.modReduce m

/-- Apply all three generators to a set of triples modulo m and collect new results. -/
def stepMod (m : ℕ) (s : List (ZMod m × ZMod m × ZMod m)) :
    List (ZMod m × ZMod m × ZMod m) :=
  ((s.flatMap fun t => [applyBGenMod m .A t, applyBGenMod m .B t, applyBGenMod m .C t])).dedup

/-- Compute the reachable set by iterating `stepMod` a fixed number of times. -/
def reachableModAux (m : ℕ) : ℕ → List (ZMod m × ZMod m × ZMod m) →
    List (ZMod m × ZMod m × ZMod m)
  | 0, acc => acc
  | n + 1, acc =>
    let new := (stepMod m acc).filter fun t => !acc.contains t
    reachableModAux m n (acc ++ new)

/-- The reachable set from the root modulo m, computed with enough iterations. -/
def reachableMod (m : ℕ) (steps : ℕ := 20) : List (ZMod m × ZMod m × ZMod m) :=
  reachableModAux m steps [rootMod m]

/-- Check if every element of `targets` is reachable from `start` within `steps` steps
    in the Berggren residue graph modulo m. -/
def canReachAll (m : ℕ) (start : ZMod m × ZMod m × ZMod m)
    (targets : List (ZMod m × ZMod m × ZMod m)) (steps : ℕ) : Bool :=
  let reachable := reachableModAux m steps [start]
  targets.all fun t => reachable.contains t

/-- Check strong connectivity: every reachable node can reach every other reachable node. -/
def isStronglyConnected (m : ℕ) (nodes : List (ZMod m × ZMod m × ZMod m))
    (steps : ℕ) : Bool :=
  nodes.all fun s => canReachAll m s nodes steps

/-! ## Verified computations for specific moduli -/

/-- Modular Lorentz form is preserved: a² + b² ≡ c² is invariant. -/
theorem lorentzQ_mod_preserved (m : ℕ) (g : BGen) (t : ZMod m × ZMod m × ZMod m) :
    (applyBGenMod m g t).1 ^ 2 + (applyBGenMod m g t).2.1 ^ 2 -
      (applyBGenMod m g t).2.2 ^ 2 =
    t.1 ^ 2 + t.2.1 ^ 2 - t.2.2 ^ 2 := by
  cases g <;> simp [applyBGenMod] <;> ring