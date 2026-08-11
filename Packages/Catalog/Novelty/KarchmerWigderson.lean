import Logic.BasicMonotoneCircuit.Basic

/-!
# The Karchmer–Wigderson connection (upper-bound direction)

The Karchmer–Wigderson theorem identifies the minimal *depth* of a circuit
computing a Boolean function `f` with the deterministic *communication
complexity* of the associated KW relation: Alice holds an input `x` with
`f x = 1`, Bob holds `y` with `f y = 0`, and they must agree on a coordinate `i`
on which `x` and `y` differ.  For *monotone* circuits the relation is the
*monotone* KW relation: the players must find `i` with `x i = 1` and `y i = 0`.

We formalize the algorithmic ("upper bound") direction: a monotone circuit
yields a communication protocol for the monotone KW relation whose cost is at
most the circuit depth.

* `kwFind` — the protocol: walk down the circuit, communicating at each gate one
  bit to choose a subcircuit.
* `kwFind_spec` — correctness: the returned coordinate `i` satisfies `x i = true`
  and `y i = false` (a *monotone separator*).
* `kwCost_le_depth` — the number of bits communicated is at most the depth.
* `monotone_separator_exists` — the clean existential consequence: every monotone
  circuit separating a `1`-input from a `0`-input exposes a separating
  coordinate.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): a monotone circuit of depth d gives a d-bit
communication protocol that solves the monotone KW relation; conversely a
protocol gives a circuit (the hard converse, not formalized here).

EXPERIMENT (Experimenter): define `kwFind` descending the circuit and a matching
cost `kwCost`; prove correctness and the depth bound by induction.

ANALYSIS (Analyst): the key invariant is preserved by construction — at an AND
gate the false output forces some child false (which we route to) while the true
input keeps both children true; at an OR gate the roles swap.  `kwFind` never
reaches a constant leaf under the invariant, which is exactly why the existence
of the separator drops out.

CRITIQUE (Critic): `kwFind` is total (returns `Option`) so it is well defined even
on inputs violating the invariant; correctness is only asserted under the genuine
KW hypotheses, so the theorem is not vacuous.  `kwCost_le_depth` is a true bound
relating two independently defined quantities.

SYNTHESIS (PI): this is the constructive half of Karchmer–Wigderson for monotone
circuits; combined with `Basic.card_le_size_of_relevant` it places both size and
depth lower-bound techniques on a common formal footing.
-/

namespace CircuitComplexity
namespace MCircuit

variable {ι : Type*}

/-- The monotone Karchmer–Wigderson protocol.  Given a `1`-input `x` and a
`0`-input `y`, descend the circuit, at each gate communicating one bit to pick the
child to recurse into, returning the separating coordinate. -/
def kwFind : MCircuit ι → (ι → Bool) → (ι → Bool) → Option ι
  | var i, _, _ => some i
  | top, _, _ => none
  | bot, _, _ => none
  | and a b, x, y => if a.eval y = false then kwFind a x y else kwFind b x y
  | or a b, x, y => if a.eval x = true then kwFind a x y else kwFind b x y

/-- The communication cost of `kwFind`: the number of gates traversed, i.e. the
number of bits exchanged. -/
def kwCost : MCircuit ι → (ι → Bool) → (ι → Bool) → ℕ
  | var _, _, _ => 0
  | top, _, _ => 0
  | bot, _, _ => 0
  | and a b, x, y => (if a.eval y = false then kwCost a x y else kwCost b x y) + 1
  | or a b, x, y => (if a.eval x = true then kwCost a x y else kwCost b x y) + 1

/-
**Correctness of the monotone KW protocol.**  If `C.eval x = true` and
`C.eval y = false`, then `kwFind C x y` returns a coordinate `i` with
`x i = true` and `y i = false`.
-/
theorem kwFind_spec (C : MCircuit ι) {x y : ι → Bool}
    (hx : C.eval x = true) (hy : C.eval y = false) :
    ∃ i, kwFind C x y = some i ∧ x i = true ∧ y i = false := by
  induction C generalizing x y with
  | var i => exact ⟨i, rfl, hx, hy⟩
  | top => simp [MCircuit.eval] at hy
  | bot => simp [MCircuit.eval] at hx
  | and a b iha ihb =>
      have hxab : a.eval x = true ∧ b.eval x = true := by
        simpa [MCircuit.eval, Bool.and_eq_true] using hx
      by_cases h : a.eval y = false
      · simpa [kwFind, h] using iha hxab.1 h
      · have ha : a.eval y = true := by simpa using h
        have hby : b.eval y = false := by
          have hand : (a.eval y && b.eval y) = false := by simpa [MCircuit.eval] using hy
          rw [ha] at hand
          simpa using hand
        simpa [kwFind, h] using ihb hxab.2 hby
  | or a b iha ihb =>
      have hyab : a.eval y = false ∧ b.eval y = false := by
        simpa [MCircuit.eval, Bool.or_eq_false_iff] using hy
      by_cases h : a.eval x = true
      · simpa [kwFind, h] using iha h hyab.1
      · have hax : a.eval x = false := by simpa using h
        have hbx : b.eval x = true := by
          have hor : (a.eval x || b.eval x) = true := by simpa [MCircuit.eval] using hx
          rw [hax] at hor
          simpa using hor
        simpa [kwFind, h] using ihb hbx hyab.2

/-
**The protocol cost is at most the depth.**  This is the upper-bound half of
the Karchmer–Wigderson correspondence: the monotone KW relation of the function
computed by `C` has a communication protocol of cost `≤ depth C`.
-/
theorem kwCost_le_depth (C : MCircuit ι) (x y : ι → Bool) :
    kwCost C x y ≤ C.depth := by
  induction' C with i a b ih_a ih_b;
  · rfl;
  · rfl;
  · rfl;
  · by_cases ha : a.eval y = false <;> simp_all +decide [ MCircuit.kwCost, MCircuit.depth ];
  · rename_i a b ha hb;
    by_cases ha' : a.eval x = true <;> simp +decide [ *, MCircuit.kwCost, MCircuit.depth ]

/-- **Monotone separator existence.**  Every monotone circuit that outputs `true`
on `x` and `false` on `y` exposes a coordinate that is set in `x` but not in `y`.
This is the combinatorial heart of the monotone KW connection. -/
theorem monotone_separator_exists (C : MCircuit ι) {x y : ι → Bool}
    (hx : C.eval x = true) (hy : C.eval y = false) :
    ∃ i, x i = true ∧ y i = false := by
  obtain ⟨i, _, hxi, hyi⟩ := kwFind_spec C hx hy
  exact ⟨i, hxi, hyi⟩

end MCircuit
end CircuitComplexity