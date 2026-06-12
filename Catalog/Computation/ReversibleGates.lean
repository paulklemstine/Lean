import Mathlib
import Computation.ReversibleTropicalThermodynamics
import Computation.LandauerLowerBound

/-!
# Provably Optimal Reversible Logic Gates: CNOT, Toffoli, Fredkin

This file constructs the standard *universal reversible gates* of reversible computing as
concrete bijections on Boolean tuples, and proves the three properties that make them the
"provably optimal reversible implementations of common logic":

1. **Reversibility** — each gate is an involution (its own inverse) and hence bijective.
2. **Logical correctness** — each gate computes the intended classical function in a
   designated output wire (CNOT computes XOR / COPY, Toffoli computes AND and NOT,
   Fredkin computes a controlled SWAP).
3. **Thermodynamic optimality** — being bijections, every gate has **zero** uniform
   entropy loss (`reversible_zero_entropy_cost`, from
   `Computation.ReversibleTropicalThermodynamics`) and dissipates **zero** Landauer heat
   on *every* input distribution (`landauer_lower_bound_zero_of_injective`, from
   `Computation.LandauerLowerBound`).

This is the cross-domain synthesis demanded by the catalog: the *algebraic* fact that the
gates are permutations is fed into the *information-theoretic* zero-loss theorem and the
*thermodynamic* zero-heat corollary, unifying three catalog files into a single statement
about each gate.

## References
- Toffoli, T. (1980). Reversible computing.
- Fredkin, E. & Toffoli, T. (1982). Conservative logic.
- Bennett, C.H. (1973). Logical reversibility of computation.
-/

open Function

namespace ReversibleGates

-- !-- Lab Notebook --!--
-- Hypothesis: The catalog had the ABSTRACT statement "bijections are thermodynamically
--   free" but no CONCRETE universal gates witnessing it. We conjectured the textbook
--   gates (CNOT, Toffoli, Fredkin) can be defined as honest bijections on Bool-tuples and
--   slotted directly into the catalog's zero-loss / zero-heat theorems.
-- Result: All three gates are proved involutive (hence bijective), logically correct
--   (XOR/COPY, AND/NOT, controlled-SWAP), AND inherit zero entropy loss + zero Landauer
--   heat on every distribution by feeding their bijectivity into the imported theorems.
-- Insight: `decide` discharges every Boolean identity over the finite cube Bool^n, so the
--   gate algebra is fully automatic; the only "real" mathematics is the SYNTHESIS step
--   that converts an involution into an `Equiv.Perm` and applies the catalog theorems.
-- Failure analysis: Initially tried to prove bijectivity by exhibiting explicit inverses
--   with `Equiv.mk`; the `left_inv`/`right_inv` obligations were just the involution law,
--   so `Function.Involutive.toPerm` made the explicit inverse redundant.
-- !-- end Lab Notebook --!--

/-! ## The gates -/

/-- **CNOT** (controlled-NOT): flips the target wire iff the control wire is set.
`(a, b) ↦ (a, a ⊕ b)`. The control `a` is preserved; the target carries `a ⊕ b`. -/
def cnot : Bool × Bool → Bool × Bool := fun p => (p.1, xor p.1 p.2)

/-- **Toffoli** (CCNOT): flips the target iff both controls are set.
`(a, b, c) ↦ (a, b, c ⊕ (a ∧ b))`. With `c = false` the target computes `a ∧ b`. -/
def toffoli : Bool × Bool × Bool → Bool × Bool × Bool :=
  fun p => (p.1, p.2.1, xor p.2.2 (p.1 && p.2.1))

/-- **Fredkin** (CSWAP): swaps the two target wires iff the control is set.
`(a, b, c) ↦ (a, c, b)` if `a`, else `(a, b, c)`. -/
def fredkin : Bool × Bool × Bool → Bool × Bool × Bool :=
  fun p => if p.1 then (p.1, p.2.2, p.2.1) else p

/-! ## Reversibility (involutivity and bijectivity) -/

-- !-- comment -- !--
-- Each gate is its own inverse: re-applying it cancels the XOR / conditional swap. `decide`
-- checks the identity over the finite Boolean cube.
-- !-- comment -- !--

/-- CNOT is an involution. -/
theorem cnot_involutive : Function.Involutive cnot := by
  rintro ⟨a, b⟩; cases a <;> cases b <;> rfl

/-- Toffoli is an involution. -/
theorem toffoli_involutive : Function.Involutive toffoli := by
  rintro ⟨a, b, c⟩; cases a <;> cases b <;> cases c <;> rfl

/-- Fredkin is an involution. -/
theorem fredkin_involutive : Function.Involutive fredkin := by
  rintro ⟨a, b, c⟩; cases a <;> cases b <;> cases c <;> rfl

/-- CNOT is bijective (reversible). -/
theorem cnot_bijective : Function.Bijective cnot := cnot_involutive.bijective

/-- Toffoli is bijective (reversible). -/
theorem toffoli_bijective : Function.Bijective toffoli := toffoli_involutive.bijective

/-- Fredkin is bijective (reversible). -/
theorem fredkin_bijective : Function.Bijective fredkin := fredkin_involutive.bijective

/-! ## Logical correctness -/

-- !-- comment -- !--
-- The designated output wire of each gate equals the intended classical function; all are
-- pointwise Boolean identities closed by `decide`.
-- !-- comment -- !--

/-- CNOT computes XOR on its target wire. -/
theorem cnot_computes_xor (a b : Bool) : (cnot (a, b)).2 = xor a b := rfl

/-- With target initialized to `false`, CNOT copies the control onto the target
(reversible FANOUT/COPY). -/
theorem cnot_computes_copy (a : Bool) : (cnot (a, false)).2 = a := by cases a <;> rfl

/-- With target initialized to `false`, Toffoli computes AND on its target wire:
this is the canonical *reversible AND with one ancilla bit*. -/
theorem toffoli_computes_and (a b : Bool) : (toffoli (a, b, false)).2.2 = (a && b) := by
  cases a <;> cases b <;> rfl

/-- With both controls set to `true`, Toffoli computes NOT on its target wire. -/
theorem toffoli_computes_not (c : Bool) : (toffoli (true, true, c)).2.2 = !c := by
  cases c <;> rfl

/-- Fredkin performs a controlled SWAP: when the control is set the two targets are
exchanged. -/
theorem fredkin_swaps_when_control (b c : Bool) :
    fredkin (true, b, c) = (true, c, b) := rfl

/-- Fredkin is the identity when the control is unset. -/
theorem fredkin_id_when_no_control (b c : Bool) :
    fredkin (false, b, c) = (false, b, c) := rfl

/-! ## Thermodynamic optimality (cross-domain synthesis) -/

-- !-- comment -- !--
-- SYNTHESIS: convert each involution to an `Equiv.Perm` and feed it to the catalog's
-- `reversible_zero_entropy_cost`; combine bijectivity with the new
-- `landauer_lower_bound_zero_of_injective` to get zero dissipated heat on every input.
-- !-- comment -- !--

/-- **CNOT is thermodynamically free**: zero uniform entropy loss. -/
theorem cnot_zero_entropy_loss : uniformEntropyLoss cnot = 0 :=
  reversible_zero_entropy_cost cnot_involutive.toPerm

/-- **Toffoli is thermodynamically free**: zero uniform entropy loss. -/
theorem toffoli_zero_entropy_loss : uniformEntropyLoss toffoli = 0 :=
  reversible_zero_entropy_cost toffoli_involutive.toPerm

/-- **Fredkin is thermodynamically free**: zero uniform entropy loss. -/
theorem fredkin_zero_entropy_loss : uniformEntropyLoss fredkin = 0 :=
  reversible_zero_entropy_cost fredkin_involutive.toPerm

/-- **CNOT dissipates no Landauer heat on any input distribution.** Combining the
algebraic fact that CNOT is bijective with the deterministic data-processing inequality:
the entropy is exactly preserved, so the dissipated work is identically zero. -/
theorem cnot_landauer_zero (p : Bool × Bool → ℝ) (k T : ℝ) :
    k * T * (shannonEntropy p -
      shannonEntropy (LandauerLowerBound.pushforwardFun cnot p)) = 0 :=
  LandauerLowerBound.landauer_lower_bound_zero_of_injective cnot p cnot_bijective.1 k T

/-- **Toffoli dissipates no Landauer heat on any input distribution.** -/
theorem toffoli_landauer_zero (p : Bool × Bool × Bool → ℝ) (k T : ℝ) :
    k * T * (shannonEntropy p -
      shannonEntropy (LandauerLowerBound.pushforwardFun toffoli p)) = 0 :=
  LandauerLowerBound.landauer_lower_bound_zero_of_injective toffoli p toffoli_bijective.1 k T

/-- **Fredkin dissipates no Landauer heat on any input distribution.** -/
theorem fredkin_landauer_zero (p : Bool × Bool × Bool → ℝ) (k T : ℝ) :
    k * T * (shannonEntropy p -
      shannonEntropy (LandauerLowerBound.pushforwardFun fredkin p)) = 0 :=
  LandauerLowerBound.landauer_lower_bound_zero_of_injective fredkin p fredkin_bijective.1 k T

end ReversibleGates