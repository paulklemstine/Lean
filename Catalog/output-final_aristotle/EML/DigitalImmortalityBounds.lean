/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Information-Theoretic Bounds on Encoding a Mind

Can a mind be *encoded*? This file develops the quantitative side of that question by
studying the **minimum description length of a connectome** — the wiring diagram of a
neural system — and by translating a physical information-capacity constraint (a
Bekenstein-style bound) into a hard obstruction to faithful digital storage.

## The model

A *connectome* on `n` neurons is an assignment of a present/absent bit to each of the
`C(n, 2)` candidate synapses between distinct neurons:

  `Connectome n := Fin (n.choose 2) → Bool`.

A *lossless code* into a substrate of `L` physical bits is an **injective** map
`Connectome n → (Fin L → Bool)`: distinct wiring diagrams must receive distinct
physical representations, otherwise two different minds would be stored identically.

## Main results

* `mdl_lower_bound` — every lossless `L`-bit code satisfies `C(n, 2) ≤ L`. The wiring
  diagram of `n` neurons cannot be stored in fewer than `C(n, 2)` bits.
* `min_code_length` — `C(n, 2)` is exactly the least achievable code length
  (`IsLeast`), so the bound is sharp: the identity code attains it.
* `choose_two_double`, `mdl_at_least_quadratic` — the code length grows at least
  **quadratically** in the neuron count: `(n - 1)^2 ≤ 2 · L` and `n·(n-1) ≤ 2·L`.
* `bekenstein_no_encoding`, `bekenstein_neuron_bound` — a substrate holding at most `B`
  bits of information cannot losslessly store any connectome with `B < C(n, 2)`; and if
  it can, then `n·(n-1) ≤ 2·B`, capping the number of encodable neurons.
* `connectome_worstcase_length` — even with *variable-length* codes into arbitrary bit
  strings, some connectome is forced to a codeword of length at least `C(n, 2)`: no
  compression scheme beats the counting bound in the worst case.
* `mind_dynamics_not_finitely_captured`, `mind_dynamics_incompressible` — bridging to
  the EML complexity theory: the space of a mind's dynamical laws is infinite while only
  finitely many are describable within any fixed budget, so the laws are incompressible.
-/

import Mathlib
import EML.KolmogorovComplexityBound

open scoped BigOperators

namespace DigitalImmortality

/-- A **connectome** on `n` neurons: one present/absent bit for each of the `C(n, 2)`
candidate synapses between distinct neurons. -/
abbrev Connectome (n : ℕ) : Type := Fin (n.choose 2) → Bool

/-! ### Counting the space of connectomes -/

/-
There are exactly `2 ^ C(n, 2)` connectomes on `n` neurons.
-/
theorem card_connectome (n : ℕ) :
    Fintype.card (Connectome n) = 2 ^ (n.choose 2) := by
  simp +zetaDelta at *

/-! ### The minimum description length of a connectome -/

/-
**Minimum description length.** Any lossless `L`-bit code of the connectomes on `n`
neurons must use at least `C(n, 2)` bits.
-/
theorem mdl_lower_bound {n L : ℕ} (enc : Connectome n → (Fin L → Bool))
    (hinj : Function.Injective enc) : n.choose 2 ≤ L := by
  have := Fintype.card_le_of_injective enc hinj;
  simp_all +decide [ Fintype.card_pi ];
  rwa [ pow_le_pow_iff_right₀ ( by decide ) ] at this

/-- The identity code stores a connectome in exactly `C(n, 2)` bits, so the lower bound
is attainable. -/
theorem optimal_code_exists (n : ℕ) :
    ∃ enc : Connectome n → (Fin (n.choose 2) → Bool), Function.Injective enc :=
  ⟨id, Function.injective_id⟩

/-
**Sharp characterization.** `C(n, 2)` is exactly the least number of bits for which a
lossless fixed-length code of the connectomes on `n` neurons exists.
-/
theorem min_code_length (n : ℕ) :
    IsLeast {L | ∃ enc : Connectome n → (Fin L → Bool), Function.Injective enc}
      (n.choose 2) := by
  refine' ⟨ _, fun L hL => _ ⟩;
  · convert optimal_code_exists n;
  · exact mdl_lower_bound _ hL.choose_spec

/-! ### The description length is at least quadratic in the neuron count -/

/-
`2 · C(n, 2) = n·(n-1)`: the exact synapse count.
-/
theorem choose_two_double (n : ℕ) : 2 * n.choose 2 = n * (n - 1) := by
  rw [ Nat.choose_two_right, mul_comm ];
  exact Nat.div_mul_cancel ( even_iff_two_dvd.mp ( Nat.even_mul_pred_self _ ) )

/-
`(n - 1)^2 ≤ 2 · C(n, 2)`: the synapse count is quadratic in the neuron count.
-/
theorem choose_two_ge_sq (n : ℕ) : (n - 1) ^ 2 ≤ 2 * n.choose 2 := by
  cases n <;> simp +arith +decide [ Nat.choose_two_right ];
  nlinarith [ Nat.div_mul_cancel ( show 2 ∣ ( ‹_› + 1 ) * ‹_› from Nat.dvd_of_mod_eq_zero ( by norm_num [ Nat.add_mod, Nat.mod_two_of_bodd ] ) ) ]

/-
**Quadratic description length.** Every lossless `L`-bit code of `n` neurons obeys
`(n - 1)^2 ≤ 2·L`: the storage cost grows at least quadratically in the neuron count.
-/
theorem mdl_at_least_quadratic {n L : ℕ} (enc : Connectome n → (Fin L → Bool))
    (hinj : Function.Injective enc) : (n - 1) ^ 2 ≤ 2 * L := by
  linarith [ choose_two_ge_sq n, mdl_lower_bound enc hinj ]

/-! ### Bekenstein-style capacity obstructions -/

/-
**Capacity obstruction.** A substrate holding at most `B` bits of information cannot
losslessly store any connectome whose synapse count exceeds `B`.
-/
theorem bekenstein_no_encoding {n B : ℕ} (h : B < n.choose 2) :
    ¬ ∃ enc : Connectome n → (Fin B → Bool), Function.Injective enc := by
  rintro ⟨ enc, hinj ⟩;
  exact h.not_ge ( mdl_lower_bound enc hinj )

/-
**Neuron ceiling.** If a `B`-bit substrate can losslessly store the connectome of `n`
neurons, then `n·(n-1) ≤ 2·B`, bounding the number of storable neurons.
-/
theorem bekenstein_neuron_bound {n B : ℕ}
    (enc : Connectome n → (Fin B → Bool)) (hinj : Function.Injective enc) :
    n * (n - 1) ≤ 2 * B := by
  by_contra h_contra;
  exact bekenstein_no_encoding ( show B < n.choose 2 from by linarith [ choose_two_double n ] ) ⟨ enc, hinj ⟩

/-! ### No variable-length compression beats the counting bound -/

/-
**Worst-case incompressibility.** For *any* lossless variable-length code into bit
strings, some connectome is forced to a codeword of length at least `C(n, 2)`. No
compression scheme can store every connectome below the counting bound.
-/
theorem connectome_worstcase_length {n : ℕ} (enc : Connectome n → List Bool)
    (hinj : Function.Injective enc) :
    ∃ c : Connectome n, n.choose 2 ≤ (enc c).length := by
  by_contra! h_contra;
  -- Build an injection from `Connectome n` into the finite type `σ k : Fin m, List.Vector Bool k`:
  let m := n.choose 2
  let e : Connectome n → Σ k : Fin m, List.Vector Bool k := fun c => ⟨⟨(enc c).length, h_contra c⟩, ⟨enc c, rfl⟩⟩
  have he : Function.Injective e := by
    intro c₁ c₂ h; have := congr_arg ( fun x => x.2.1 ) h; aesop;
  -- Therefore, `Fintype.card (Connectome n) ≤ Fintype.card (Σ k : Fin m, List.Vector Bool k)` by `Fintype.card_le_of_injective e he`.
  have h_card : Fintype.card (Connectome n) ≤ Fintype.card (Σ k : Fin m, List.Vector Bool k) := by
    exact Fintype.card_le_of_injective e he;
  -- Now compute both cardinalities:
  have h_card_connectome : Fintype.card (Connectome n) = 2 ^ m := by
    convert card_connectome n
  have h_card_sigma : Fintype.card (Σ k : Fin m, List.Vector Bool k) = ∑ k ∈ Finset.range m, 2 ^ k := by
    simp +decide [ Fintype.card_sigma, Finset.sum_range ];
  linarith [ Nat.sub_add_cancel ( Nat.one_le_pow m 2 zero_lt_two ), geom_sum_mul_neg ( 2 : ℤ ) m ]

/-! ### Bridge to EML complexity: a mind's dynamics are incompressible -/

/-- The dynamical laws describable within the connectome's own bit budget form a finite
set, whereas the space of all laws `ℝ → ℝ` is infinite. -/
theorem mind_dynamics_not_finitely_captured (n : ℕ) :
    (EMLKolmogorov.computableLE (n.choose 2)).Finite ∧
      Infinite (ℝ → ℝ) :=
  ⟨EMLKolmogorov.finite_computableLE _, EMLKolmogorov.infinite_real_fun⟩

/-- **Incompressible dynamics.** Within the connectome's bit budget there is always a
dynamical law that no EML description of that size can compute. -/
theorem mind_dynamics_incompressible (n : ℕ) :
    ∃ f : ℝ → ℝ, f ∉ EMLKolmogorov.computableLE (n.choose 2) :=
  EMLKolmogorov.exists_incompressible _

/-!
-- !-- Lab Notes -- !--

**Hypothesis.** Encoding a mind is fundamentally an information-storage problem. If a
mind is (at least) its connectome — the present/absent state of every candidate synapse
between its neurons — then the space of possible minds on `n` neurons has size
`2 ^ C(n,2)`, and no lossless storage scheme can beat the resulting counting bound. We
conjectured a *quadratic* floor on description length and a hard capacity obstruction of
Bekenstein type.

**Experiment.** We modelled a connectome as `Fin (C(n,2)) → Bool` and a lossless code as
an injection into a bit substrate. `card_connectome` fixes the state count at `2^C(n,2)`;
`mdl_lower_bound` turns injectivity + the cardinality comparison into `C(n,2) ≤ L`;
`min_code_length` shows the bound is exactly attained (`IsLeast`). The identity
`choose_two_double` (`2·C(n,2) = n(n-1)`) and `choose_two_ge_sq` upgrade the linear bit
bound to the quadratic `mdl_at_least_quadratic` and `bekenstein_neuron_bound`. The
variable-length version `connectome_worstcase_length` required a genuinely different
argument: an injection of connectomes into `Σ k : Fin C(n,2), Vector Bool k`, whose
cardinality is the geometric sum `2^C(n,2) − 1`, one short of what injectivity demands.

**Analysis.** The fixed-length results are sharp (attained by the identity code), so the
quadratic growth is not an artifact of a wasteful encoding — it is intrinsic to the
combinatorics of pairwise wiring. The `−1` in the variable-length count is the crux: it
is exactly why *some* codeword must reach the full length `C(n,2)`; a shorter worst case
would need one more short string than the binary alphabet provides.

**Critique.** None of the theorems is vacuous: `optimal_code_exists` exhibits a witness,
so the hypothesis classes are inhabited and the `IsLeast` set is nonempty. The bounds are
tight, not merely one-sided. The Bekenstein statements are genuine impossibility results
(`bekenstein_no_encoding` is a negation with a nontrivial proof), not definitional
rewrites. The bridge theorems reuse the EML complexity theory rather than re-deriving it.

**Synthesis.** A connectome of `n` neurons cannot be stored losslessly in fewer than
`C(n,2)` bits, this floor grows quadratically in `n`, is attained exactly, survives to
variable-length codes in the worst case, and — combined with the infinitude of dynamical
laws describable only within a fixed budget — shows that the *static* wiring already
imposes a quadratic information cost while the *dynamics* remain incompressible.
-/

end DigitalImmortality