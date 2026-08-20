import Mathlib
import Catalog.Novelty.Counting

/-!
# Computational evidence for `Shared.RecodingCriticalGeometry` and companions

Small-case checks backing the theorems of the critical-geometry files.  The
numerical output produced by these `#eval`s is transcribed in
`ComputationalEvidence.md`.
-/

namespace CriticalGeometryEvidence

open Finset

-- Ambient counts `S k n` for `k = 2, 3`.
#eval (List.range 5).map (fun n => (ProofSpace.S 2 n, ProofSpace.S 3 n))

-- The shift identity `S k (n+b) = (∑_{i<b} k^i) + k^b * S k n`.
#eval ((List.range 4).flatMap (fun n => (List.range 4).map (fun b =>
  decide (ProofSpace.S 2 (n+b) = (∑ i ∈ range b, 2^i) + 2^b * ProofSpace.S 2 n)))).all (· == true)

-- The distortion bound `S k (n+b) ≤ 2 k^b S k n`.
#eval ((List.range 6).flatMap (fun n => (List.range 4).map (fun b =>
  decide (ProofSpace.S 3 (n+b) ≤ 2 * 3^b * ProofSpace.S 3 n)))).all (· == true)

-- A derivable family of exact exponential order (3/2)^n inside the binary language.
def expCount (n : Nat) : Nat := Nat.ceil (((3 : ℚ)/2)^n)

-- Its ambient density.
def expDensity (n : Nat) : ℚ := (expCount n : ℚ) / (ProofSpace.S 2 n : ℚ)

#eval (List.range 12).map (fun n => (n, expCount n, (expDensity n).toFloat))

-- Last cutoff at level eps and first cutoff below it: the transition window.
def lastAbove (eps : ℚ) : Nat :=
  ((List.range 60).filter (fun n => eps ≤ expDensity n)).foldl max 0

def firstBelow (eps : ℚ) : Nat :=
  ((List.range 60).find? (fun n => expDensity n < eps)).getD 0

#eval [(1:ℚ)/2, 1/4, 1/10, 1/100, 1/1000, 1/1000000].map
  (fun e => (e, lastAbove e, firstBelow e))

-- The two profiles of criticalIndex_gap_unbounded.
def pProfile (n : Nat) : ℚ := 1/(n+1)

def qProfile (n : Nat) : ℚ := 1/(2*n+2)

def critIdx (f : Nat → ℚ) (eps : ℚ) : Nat :=
  ((List.range 300).filter (fun n => eps ≤ f n)).foldl max 0

-- Critical indices at level `1/(2D+2)`: `2D+1` versus `D`.
#eval [0,1,2,5,10,50].map
  (fun D => (D, critIdx pProfile (1/(2*D+2)), critIdx qProfile (1/(2*D+2))))

-- Both profiles satisfy the `b = 1`, factor-`4` recoding distortion bounds.
#eval ((List.range 50).map
  (fun n => decide (pProfile n ≤ 4 * qProfile (n+1) ∧ qProfile n ≤ 4 * pProfile (n+1)))).all
    (· == true)

-- The uniform mixture of geometric regimes, (1 - e^{-x})/x.
def mixedTailFloat (x : Float) : Float := (1 - Float.exp (-x))/x

-- `x · mixedTail x → 1`: regular variation of index `-1`.
#eval ([1,2,3,5,10,20,50] : List Nat).map
  (fun n => (n, mixedTailFloat n.toFloat, mixedTailFloat n.toFloat * n.toFloat))

-- Successive ratios tend to `1`, not to a constant `< 1`.
#eval ([1,2,5,10,50,200] : List Nat).map
  (fun n => mixedTailFloat (n.toFloat+1) / mixedTailFloat n.toFloat)

end CriticalGeometryEvidence