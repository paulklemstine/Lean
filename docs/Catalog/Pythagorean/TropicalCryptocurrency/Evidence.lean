import Mathlib

/-!
# Tropical Cryptocurrency: computational evidence

Reproducible `#eval` experiments backing the numerical claims recorded in
`ComputationalEvidence.md`.  Nothing here is used in a proof; the formal results
live in `RecessionCone.lean`, `HallCriterion.lean`, `BoundedAlphabet.lean` and
`Inversion.lean`.

The model is the integer min-plus digest `dg A m i = min_j (A i j + m j)`.
-/

namespace TropicalRecession.Evidence

/-- Integer min-plus digest of a message `m` under the `r × k` key table `A`. -/
def dg (A : List (List Int)) (m : List Int) : List Int :=
  A.map fun row => ((row.zip m).map fun p => p.1 + p.2).foldr min 1000000

/-- The active (minimizing) coordinates of each digest component. -/
def actives (A : List (List Int)) (m : List Int) : List (List Nat) :=
  (A.zip (dg A m)).map fun p =>
    (List.range m.length).filter fun j => (p.1.getD j 0) + (m.getD j 0) = p.2

/-- All subsets of `{0, …, k-1}`. -/
def subsets (k : Nat) : List (List Nat) :=
  (List.range (2 ^ k)).map fun s => (List.range k).filter fun j => (s >>> j) % 2 = 1

/-- Minimum size of a set meeting every active set (the hitting number `τ`). -/
def tau (A : List (List Int)) (m : List Int) : Nat :=
  let acts := actives A m
  let cands := (subsets m.length).filter fun H => acts.all fun a => a.any fun j => H.contains j
  (cands.map List.length).foldr min 999

/-- Largest `|S|` such that bumping all coordinates of `S` leaves the digest fixed. -/
def maxConeDim (A : List (List Int)) (m : List Int) : Nat :=
  let ok := (subsets m.length).filter fun S =>
    dg A ((List.range m.length).map fun j =>
      m.getD j 0 + (if S.contains j then 1 else 0)) = dg A m
  (ok.map List.length).foldr max 0

/-- The canonical (coordinatewise least) candidate preimage of `y`. -/
def canon (A : List (List Int)) (y : List Int) (k : Nat) : List Int :=
  (List.range k).map fun j =>
    ((A.zip y).map fun p => p.2 - p.1.getD j 0).foldr max (-1000000)

def prand (seed n : Nat) : Nat := (seed * 1103515245 + 12345) % n

def mkKey (seed r k : Nat) : List (List Int) :=
  (List.range r).map fun i =>
    (List.range k).map fun j => (prand (seed + 7 * i + 13 * j + i * j * 31) 6 : Nat)

def boxMsgs (k B : Nat) : List (List Int) :=
  (List.range ((B + 1) ^ k)).map fun s =>
    (List.range k).map fun j => ((s / (B + 1) ^ j) % (B + 1) : Nat)

/-! Three worked examples: `(digest, active sets, τ, max cone dimension, k - r)`. -/
#eval let A := [[0,3,5,2],[4,1,7,6],[9,8,2,3]]; let m := [0,0,0,0];
  (dg A m, actives A m, tau A m, maxConeDim A m, m.length - A.length)
#eval let A := [[0,0,5,2],[0,1,7,6]]; let m := [0,0,0,0];
  (dg A m, actives A m, tau A m, maxConeDim A m, m.length - A.length)
#eval let A := [[0,1],[0,1]]; let m := [0,0];
  (dg A m, actives A m, tau A m, maxConeDim A m, m.length - A.length)

/-! 400 pseudorandom instances (`k = 4`, `r ∈ {1,2,3}`):
the maximal coordinate-cone dimension always equals `k - τ`, and always dominates
`k - r`.  Expected output `(true, true)`. -/
#eval let tests := (List.range 400).map fun s =>
        let r := 1 + s % 3
        let A := mkKey (s * 17 + 1) r 4
        let m := (List.range 4).map fun j => (prand (s * 5 + j * 3) 4 : Nat)
        (decide (maxConeDim A m = 4 - tau A m), decide (maxConeDim A m ≥ 4 - r))
      (tests.all fun p => p.1, tests.all fun p => p.2)

/-! 50 pseudorandom instances (`k = 3`, `B = 12`): a preimage inside the box exists
iff the single candidate `max (canon A y) 0` is a preimage inside the box.
Expected output `true`. -/
#eval let res := (List.range 50).map fun s =>
        let r := 1 + s % 2
        let A := mkKey (s * 11 + 3) r 3
        let y := (List.range r).map fun i => (prand (s * 3 + i * 7) 8 : Nat) - 2
        let brute := (boxMsgs 3 12).any fun m => decide (dg A m = y)
        let w := (canon A y 3).map fun x => max x 0
        let candOk := (w.all fun x => decide (x ≤ 12)) && decide (dg A w = y)
        decide (brute = candOk)
      res.all id

end TropicalRecession.Evidence