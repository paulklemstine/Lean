/-
Small, kernel-checked instances supporting the exact first-moment bridge.  These checks
are supplementary; the general theorem is proved structurally in
`FixedPointRootBridge.lean` rather than by finite computation.
-/
import StochasticGalois.FixedPointRootBridge

open Finset Equiv
open scoped BigOperators
open StochasticGaloisBridge

namespace StochasticGaloisBridge.ComputationalChecks

/-- Over `F₂`, the four monic quadratics have altogether four root incidences. -/
example :
    ∑ v : Fin 2 → ZMod 2,
      #(univ.filter (fun r : ZMod 2 => monicEval 2 v r = 0)) = 4 := by
  simpa using total_root_incidences (K := ZMod 2) 2 (by norm_num)

/-- Over `F₃`, the nine monic quadratics have altogether nine root incidences. -/
example :
    ∑ v : Fin 2 → ZMod 3,
      #(univ.filter (fun r : ZMod 3 => monicEval 2 v r = 0)) = 9 := by
  simpa using total_root_incidences (K := ZMod 3) 2 (by norm_num)

/-- Across `S₃`, the six permutations have six fixed-point incidences. -/
example :
    ∑ σ : Perm (Fin 3), #(univ.filter (fun i : Fin 3 => σ i = i)) = 6 := by
  simpa using total_fixed_point_incidences 3 (by norm_num)

/-- The cross-domain equality in the concrete `F₃`, degree-three case. -/
example :
    (∑ v : Fin 3 → ZMod 3, #(univ.filter (fun r : ZMod 3 => monicEval 3 v r = 0))) * 6
      = (∑ σ : Perm (Fin 3), #(univ.filter (fun i : Fin 3 => σ i = i))) * 27 := by
  simpa using root_fixed_point_bridge (K := ZMod 3) 3 (by norm_num)

end StochasticGaloisBridge.ComputationalChecks