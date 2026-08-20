import Catalog.Shared.ImmuneAlgebra

/-!
# Algorithmic Immune System — Lab Notes (executable experimental data)

Every claim below is *executed*: the `example`s are closed by `decide`, i.e. by
kernel evaluation of the interpreter of Parts I–II, and the `#eval`s print the
raw experimental data reported in `ComputationalEvidence.md`.

Experiments:

1. attestation tags of small ASTs and their pairwise distinctness (Part I);
2. the diagonal parasite of the *silent* detector really attacks, while the
   diagonal parasite of the *paranoid* detector really is harmless (Part III) —
   the two horns of `detector_dilemma`, executed;
3. sizes of parasites, confirming `size_parasite`;
4. distinctness of the `2 ^ n` benign padded variants (Part IV);
5. a simulated guarded run against an adversary that injects `attack` at every
   step: containment and zero forbidden actions (Part IV).
-/

namespace ImmuneSystem
namespace PAst

/-! ## 1. Attestation tags -/

#eval (code inp, code attack, code (lit 0), code (lit 7))
#eval code (ite (lit 0) attack (lit 3))
#eval code (call (lit 2) inp)

example : code (lit 0) ≠ code attack := by decide
example : code (ite (lit 0) attack (lit 3)) ≠ code (call (lit 2) inp) := by decide

/-! ## 2. The two horns of the detector dilemma, executed -/

-- Silent detector `lit 0`: never accuses; its diagonal parasite attacks.
#eval run (parasite (lit 0) [])
example : run (parasite (lit 0) []) = true := by decide

-- Paranoid detector `lit 1`: always accuses; its diagonal parasite is harmless,
-- so the accusation is a false alarm.
#eval run (parasite (lit 1) [])
example : run (parasite (lit 1) []) = false := by decide

/-- The paranoid detector also accuses the perfectly harmless constant program. -/
example : ¬ malicious (lit 0) := by decide

-- Padded parasites of the silent detector all attack.
#eval (List.range 4).map fun n => run (parasite (lit 0) (List.replicate n true))
example : run (parasite (lit 0) [true, false, true]) = true := by decide

/-! ## 3. Program sizes -/

#eval (List.range 5).map fun n => size (parasite (lit 0) (List.replicate n true))
#eval (List.range 5).map fun n => size (pad (List.replicate n true))

example : size (parasite (lit 0) (List.replicate 3 true)) = size (lit 0) + 3 * 3 + 5 := by decide

/-! ## 4. The benign padded family -/

-- All `2 ^ 3` padded variants of length `3` are effect-free, evaluate to `0`,
-- and carry pairwise distinct attestation tags.
#eval ((List.replicate 3 [false, true]).foldr
    (fun opts acc => opts.flatMap fun b => acc.map fun l => b :: l) [([] : List Bool)]).length
#eval (((List.replicate 3 [false, true]).foldr
    (fun opts acc => opts.flatMap fun b => acc.map fun l => b :: l)
    [([] : List Bool)]).map fun l => code (pad l))

example :
    (((List.replicate 3 [false, true]).foldr
      (fun opts acc => opts.flatMap fun b => acc.map fun l => b :: l)
      [([] : List Bool)]).map fun l => (eval (pad l) 17, effect (pad l) 17)).all
      (fun p => p.1 == 0 && p.2 == false) = true := by decide

/-! ## 5. A guarded run against an `attack`-injecting adversary -/

/-- Sanctioned set: the baseline `lit 0` together with one legitimate patch. -/
def demoS : Finset PAst := {lit 0, lit 5}

/-- Adversary: on even steps it splices in an `attack`, on odd steps it performs a
sanctioned patch. -/
def demoAdv : ℕ → PAst → PAst := fun n t => if n % 2 = 0 then ite (lit 1) attack t else lit 5

#eval (List.range 6).map fun n => (trace demoS (lit 0) demoAdv n)
#eval (List.range 6).map fun n => effect (trace demoS (lit 0) demoAdv n) 0

/-- Executed containment: every state of the guarded run is sanctioned … -/
example : (List.range 6).all (fun n => decide (trace demoS (lit 0) demoAdv n ∈ demoS)) = true := by
  decide

/-- … and no forbidden action is ever executed, although the adversary splices in
`attack` at every even step. -/
example : (List.range 6).all (fun n => !run (trace demoS (lit 0) demoAdv n)) = true := by
  decide

/-- Unguarded, the very first mutation is already lethal. -/
example : run (demoAdv 0 (lit 0)) = true := by decide

end PAst
end ImmuneSystem