import Catalog.Shared.HQECC.CSSHomology

namespace HQECC

/-!
# The homological code of the hypercube, and the failure of the "1 qubit" law

The homological quantum error correcting code `HQECC(G)` of a graph `G` (a
one–dimensional simplicial complex) uses the boundary map `∂ : 𝔽₂^E → 𝔽₂^V` as
its only differential (there are no 2–cells, so `d₂ = 0`).  By the graph count
`CSSComplex.graph_numLogical_add`, the number of logical qubits equals the
**circuit rank** (first Betti number)

  `k = β₁(G) = E − V + β₀`,

where `E, V` are the edge and vertex counts and `β₀` the number of connected
components.  For a *connected* graph `β₀ = 1`, so `k = E − V + 1`.

We apply this to the `n`-dimensional hypercube graph `Qₙ`, which has
`V = 2ⁿ` vertices and `E = n·2ⁿ⁻¹` edges and is connected.  Hence

  `β₁(Qₙ) = n·2ⁿ⁻¹ − 2ⁿ + 1 = 2ⁿ⁻¹·(n − 2) + 1`.

A widely quoted conjecture asserts that `HQECC(Qₙ)` encodes a **single** logical
qubit for all `n`.  Our computation shows this is *false* for every `n ≥ 3`: the
code encodes `2ⁿ⁻¹·(n − 2) + 1` logical qubits, e.g. `17` for `Q₄`, `129` for
`Q₆`, `769` for `Q₈`.  The "one qubit" law holds **only** in the boundary case
`n = 2`, where `Q₂` is the 4-cycle.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  Reading the mission literally, `HQECC(Qₙ)` should
encode `1` logical qubit with distance `2^{n/2}`.  The graph `Qₙ` is a genuine
1-complex, so its first homology is the *cycle space*, whose dimension is the
circuit rank `E − V + 1`, not `1`.  We therefore predict the conjecture is FALSE
for large `n` and pin down the exact (topological) invariant.

EXPERIMENT (Experimenter).  We compute `E, V` for `Qₙ`, derive the closed form
`β₁(Qₙ) = 2ⁿ⁻¹(n−2)+1`, and prove `β₁(Qₙ) = 1 ↔ n = 2` together with
`β₁(Qₙ) ≥ 5` for `n ≥ 3`.  The bridge theorem `hypercube_HQECC_count` transports
this to the homological code via `CSSComplex.graph_numLogical_add` from the
catalog file `CSSHomology.lean`.

ANALYSIS (Analyst).  The conjecture confuses the hypercube *graph* (a 1-complex,
first Betti number `2ⁿ⁻¹(n−2)+1`) with the hypercube *cell complex* / torus-like
surface (whose middle homology can be small).  The correct statement is a clean
topological invariant.  The "1 qubit" claim survives *only* at `n = 2`.

CRITIQUE (Critic).  All arithmetic identities are proved by `ring`/`omega` after
recording `2ⁿ = 2·2ⁿ⁻¹`, none by `decide` alone on the general statement; the
three numerical instances `Q₄, Q₆, Q₈` are genuine evaluations.  The bridge
theorem uses the catalog homology count, so the result is not self-referential.
-/

namespace Hypercube

/-- Number of vertices of the `n`-dimensional hypercube graph `Qₙ`. -/
def V (n : ℕ) : ℕ := 2 ^ n

/-- Number of edges of the `n`-dimensional hypercube graph `Qₙ`
(`n` edges leave each of the `2ⁿ` vertices, each counted twice). -/
def E (n : ℕ) : ℕ := n * 2 ^ (n - 1)

/-- First Betti number (circuit rank) of the connected graph `Qₙ`,
`β₁ = E − V + 1`, taken in `ℤ` so the closed form is exact. -/
def betti1 (n : ℕ) : ℤ := (E n : ℤ) - (V n : ℤ) + 1

/-! ## Closed form and the boundary case -/

/-- **Closed form.**  For `n ≥ 1`, `β₁(Qₙ) = 2ⁿ⁻¹·(n − 2) + 1`. -/
theorem betti1_closed (n : ℕ) (hn : 1 ≤ n) :
    betti1 n = 2 ^ (n - 1) * ((n : ℤ) - 2) + 1 := by
  obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_le hn
  unfold betti1 E V
  simp only [Nat.add_sub_cancel_left, pow_add, pow_one]
  push_cast
  ring

/-- The 4-cycle `Q₂` is the unique hypercube whose code encodes exactly one
logical qubit. -/
theorem betti1_two : betti1 2 = 1 := by
  decide

/-- **The "one qubit" law holds only at `n = 2`.**  For every `n ≥ 1`,
`β₁(Qₙ) = 1` if and only if `n = 2`. -/
theorem betti1_eq_one_iff (n : ℕ) (hn : 1 ≤ n) : betti1 n = 1 ↔ n = 2 := by
  rw [betti1_closed n hn]
  have hpos : (0 : ℤ) < 2 ^ (n - 1) := by positivity
  constructor
  · intro h
    have hz : 2 ^ (n - 1) * ((n : ℤ) - 2) = 0 := by linarith
    rcases mul_eq_zero.1 hz with h1 | h2
    · exact absurd h1 (by positivity)
    · have : (n : ℤ) = 2 := by linarith
      exact_mod_cast this
  · rintro rfl
    norm_num

/-- **Failure of the conjecture for `n ≥ 3`.**  The hypercube code encodes at
least five logical qubits, hence strictly more than one. -/
theorem betti1_ge_five (n : ℕ) (hn : 3 ≤ n) : 5 ≤ betti1 n := by
  rw [betti1_closed n (by omega)]
  have h4 : (4 : ℤ) ≤ 2 ^ (n - 1) := by
    calc (4 : ℤ) = 2 ^ 2 := by norm_num
    _ ≤ 2 ^ (n - 1) := by
        apply pow_le_pow_right₀ (by norm_num)
        omega
  have hn2 : (1 : ℤ) ≤ (n : ℤ) - 2 := by
    have : (3 : ℤ) ≤ (n : ℤ) := by exact_mod_cast hn
    linarith
  nlinarith [h4, hn2]

/-! ## The three test cases requested by the mission -/

/-- `Q₄` encodes `17` logical qubits, not `1`. -/
theorem betti1_four : betti1 4 = 17 := by norm_num [betti1, E, V]

/-- `Q₆` encodes `129` logical qubits, not `1`. -/
theorem betti1_six : betti1 6 = 129 := by norm_num [betti1, E, V]

/-- `Q₈` encodes `769` logical qubits, not `1`. -/
theorem betti1_eight : betti1 8 = 769 := by norm_num [betti1, E, V]

end Hypercube

/-! ## Bridge to the homological code -/

open CSSComplex

/-- **The homological code of the hypercube.**  Let `X` be the graph chain
complex of a connected hypercube `Qₙ` over any field `K` (no 2–cells, so
`d₂ = 0`; connected, so `betti0 = 1`), with physical space `𝔽^E` of dimension
`E = n·2ⁿ⁻¹` and vertex space `𝔽^V` of dimension `V = 2ⁿ`.  Then the number of
logical qubits satisfies `k + 2ⁿ = n·2ⁿ⁻¹ + 1`, i.e. `k = β₁(Qₙ)`. -/
theorem hypercube_HQECC_count {K A B C : Type*} [Field K]
    [AddCommGroup A] [Module K A] [AddCommGroup B] [Module K B]
    [AddCommGroup C] [Module K C] [FiniteDimensional K B] [FiniteDimensional K C]
    (X : CSSComplex K A B C) (hd2 : X.d2 = 0) (hconn : X.betti0 = 1) (n : ℕ)
    (hE : Module.finrank K B = n * 2 ^ (n - 1)) (hV : Module.finrank K C = 2 ^ n) :
    X.numLogical + 2 ^ n = n * 2 ^ (n - 1) + 1 := by
  have h := X.graph_numLogical_add hd2
  rw [hE, hV, hconn] at h
  exact h

/-- The homological hypercube code encodes more than one logical qubit whenever
`n ≥ 3`: combining the bridge with `Hypercube.betti1_ge_five`, `k ≥ 5`. -/
theorem hypercube_HQECC_not_one {K A B C : Type*} [Field K]
    [AddCommGroup A] [Module K A] [AddCommGroup B] [Module K B]
    [AddCommGroup C] [Module K C] [FiniteDimensional K B] [FiniteDimensional K C]
    (X : CSSComplex K A B C) (hd2 : X.d2 = 0) (hconn : X.betti0 = 1) (n : ℕ)
    (hn : 3 ≤ n) (hE : Module.finrank K B = n * 2 ^ (n - 1))
    (hV : Module.finrank K C = 2 ^ n) :
    5 ≤ X.numLogical := by
  have hcount := hypercube_HQECC_count X hd2 hconn n hE hV
  have hk : 2 ^ n = 2 * 2 ^ (n - 1) := by
    conv_lhs => rw [show n = (n - 1) + 1 by omega]
    rw [pow_succ]
    ring
  have h3 : 3 * 2 ^ (n - 1) ≤ n * 2 ^ (n - 1) := Nat.mul_le_mul_right _ hn
  have h4 : 4 ≤ 2 ^ (n - 1) := by
    calc 4 = 2 ^ 2 := by norm_num
    _ ≤ 2 ^ (n - 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
  omega

/-! ## Examples and sanity checks -/

section Examples

#check @hypercube_HQECC_count
#check @Hypercube.betti1_closed
#eval (List.range 9).map (fun n => (n, Hypercube.betti1 n))   -- [.., (4,17), (6,129), (8,769)]

/-- The predicted logical-qubit counts for the mission's test cases. -/
example : Hypercube.betti1 4 = 17 ∧ Hypercube.betti1 6 = 129 ∧ Hypercube.betti1 8 = 769 :=
  ⟨Hypercube.betti1_four, Hypercube.betti1_six, Hypercube.betti1_eight⟩

end Examples
end HQECC