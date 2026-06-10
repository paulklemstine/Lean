import Bridges.EBC.Defs

/-!
# Entropy-Bounded Computation (EBC): Quantum Circuits

We extend the EBC cost model to quantum circuits.  The key thermodynamic fact is
that unitary (reversible) gates are *free* — only measurements, which extract
classical bits that must ultimately be erased, carry Landauer cost.  Thus the
entropy cost of a quantum computation depends only on the number of classical
bits it extracts, not on the number of gates or on *when* the measurements occur.

## Main results

* `QuantumCircuit.cost` — cost is `measurementCount · tf`, independent of gates.
* `unitary_compose_free` — a measurement-free circuit has zero cost.
* `quantum_cost_additive` — cost is additive over circuit composition.
* `measurement_budget_bound` — a budget caps the number of measurements.
* `deferred_measurement_cost_invariant` — deferring all measurements to the end
  preserves the total Landauer cost (a formal deferred-measurement principle at
  the level of cost accounting).
-/

namespace EBC

/-- A quantum circuit, abstracted by its gate count and measurement count. -/
structure QuantumCircuit where
  gateCount : ℕ
  measurementCount : ℕ

/-- Landauer cost of a quantum circuit: unitary gates are free, each measurement
costs one bit erasure. -/
noncomputable def QuantumCircuit.cost (c : QuantumCircuit) (tf : ℝ) : ℝ :=
  (c.measurementCount : ℝ) * tf

/-- Composition of quantum circuits: gate and measurement counts add. -/
def QuantumCircuit.comp (c d : QuantumCircuit) : QuantumCircuit :=
  ⟨c.gateCount + d.gateCount, c.measurementCount + d.measurementCount⟩

/-- The deferred-measurement transform: push every measurement to the end.  At
the level of cost accounting this only reshuffles gates and measurements, leaving
both counts unchanged. -/
def QuantumCircuit.defer (c : QuantumCircuit) : QuantumCircuit :=
  ⟨c.gateCount, c.measurementCount⟩

-- !-- Lab Notebook: quantum_circuit_cost / gate independence -- !--
-- !-- Hypothesis: Quantum entropy cost is measurementCount·tf, independent of gates. -- !--
-- !-- Result: Holds by definition of cost; the content is that two circuits with -- !--
-- !-- equal measurement counts have equal cost regardless of gate count. -- !--
-- !-- Insight: Reversibility of unitaries is the quantum analogue of EBC's -- !--
-- !-- ReversibleComputation zero-cost principle. -- !--
-- !-- Failure analysis: none. -- !--
-- !-- End Lab Notebook -- !--

/-- **Gate independence of cost.** Two circuits with the same number of
measurements have the same Landauer cost, irrespective of their gate counts. -/
theorem quantum_circuit_cost (g₁ g₂ m : ℕ) (tf : ℝ) :
    QuantumCircuit.cost ⟨g₁, m⟩ tf = QuantumCircuit.cost ⟨g₂, m⟩ tf := rfl

/-- A measurement-free (purely unitary) circuit has zero Landauer cost. -/
theorem unitary_compose_free (g : ℕ) (tf : ℝ) :
    QuantumCircuit.cost ⟨g, 0⟩ tf = 0 := by
  simp [QuantumCircuit.cost]

-- !-- Lab Notebook: quantum_cost_additive -- !--
-- !-- Hypothesis: Cost is additive over circuit composition. -- !--
-- !-- Result: Proved from comp adding measurement counts and add_mul. -- !--
-- !-- Insight: Mirrors totalCost_append; the quantum and classical cost models -- !--
-- !-- are the same additive monoid hom into (ℝ, +). -- !--
-- !-- Failure analysis: none. -- !--
-- !-- End Lab Notebook -- !--

/-- Quantum cost is additive over circuit composition. -/
theorem quantum_cost_additive (c d : QuantumCircuit) (tf : ℝ) :
    (c.comp d).cost tf = c.cost tf + d.cost tf := by
  unfold QuantumCircuit.comp QuantumCircuit.cost
  push_cast
  ring

/-- **Measurement budget bound.** A circuit whose cost is within budget `B`
satisfies `measurementCount · tf ≤ B` (so at most `B / tf` measurements when
`tf > 0`). -/
theorem measurement_budget_bound (c : QuantumCircuit) (tf : ℝ)
    (B : ℝ) (hB : c.cost tf ≤ B) : (c.measurementCount : ℝ) * tf ≤ B := hB

-- !-- Lab Notebook: deferred_measurement_cost_invariant -- !--
-- !-- Hypothesis: Deferring all measurements to the end preserves total cost. -- !--
-- !-- Result: defer preserves measurementCount, hence cost, by definition. -- !--
-- !-- Insight: A cost-level deferred-measurement principle: WHEN you extract -- !--
-- !-- classical bits is thermodynamically irrelevant; only HOW MANY matters. -- !--
-- !-- Failure analysis: the full principle needs circuit equivalence (same -- !--
-- !-- measurement statistics); here we capture its cost-accounting shadow. -- !--
-- !-- End Lab Notebook -- !--

/-- **Deferred-measurement cost invariance.** Pushing every measurement to the
end of the circuit leaves the total Landauer cost unchanged. -/
theorem deferred_measurement_cost_invariant (c : QuantumCircuit) (tf : ℝ) :
    c.defer.cost tf = c.cost tf := rfl

end EBC