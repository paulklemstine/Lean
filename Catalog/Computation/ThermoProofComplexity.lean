/-
# Thermodynamic Lower Bounds from Proof-Size Lower Bounds

Future Direction 4 of the "Proof Complexity and Thermodynamic Cost" thread conjectured that
proof-size lower bounds become *physical* lower bounds once the verifier is denied enough
ancillary memory to retain its intermediate distinctions.  This file proves that
implication in a guarded, fully explicit form.

## Model

A memory-constrained verifier for a workload of `2^S` distinguishable proofs, allowed only
`M` bits of retained state, is a map `f : Fin (2^S) → Fin (2^M)`.  No assumption is made
about *how* it computes — only about the sizes of its input and output registers.

* `verifier_heat_lower_bound` — such a verifier necessarily erases at least `S − M` bits and
  therefore dissipates at least `(S − M) · k_B T ln 2` of heat at temperature `T`.
* `heat_superpolynomial` — **main theorem**: if a formula family forces proof workloads of
  size `2^n` (an exponential proof-size lower bound) while the verifier's ancillary memory
  is polynomially bounded, then the dissipated heat is *superpolynomial*: it eventually
  exceeds `C · n^d` for every constant `C` and every degree `d`, at fixed positive
  temperature.
* `heat_unbounded_of_subexponential_memory` — the same conclusion in unbounded form.

The theorem is deliberately conditional: the proof-complexity input (`2^n ≤ proofSize n`)
appears as a hypothesis, since it is exactly the kind of statement that concrete lower-bound
families supply.  What is proved here is the *bridge* — that such a bound, together with a
memory constraint, forces superpolynomial dissipation.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): a proof-size lower bound alone has no thermodynamic content (Bennett
  reversibility makes computation free); it acquires content only when a memory constraint
  forbids retaining the history.  The `ReversibleVerificationFrontier` results make this
  precise, so the bridge should be a corollary of the entropy-drop bound.
Experiment (Stage 2): combined `ThermoProof.erasedBits_lower_bound` with the asymptotic
  domination of polynomials by exponentials (`isLittleO_pow_const_const_pow_of_one_lt`).
Analysis (Stage 3): the physical content is entirely in the register-size gap `S − M`; the
  proof-complexity hypothesis enters only through `S`.  This confirms the Stage-4 critique of
  the previous cycle: written proof length, description complexity and thermodynamic cost are
  three different quantities, and only the *retained-versus-processed* gap is dissipative.
Critique (Stage 4): the bound is vacuous when `M ≥ S` (a verifier allowed to keep everything
  can be reversible, `ReversibleFrontier.reversible_history_iff`), which is precisely why the
  memory constraint is a hypothesis rather than a conclusion.  We state it explicitly.
Synthesis (Stage 5): exponential proof-size lower bounds + polynomial memory ⇒
  superpolynomial heat, at fixed positive temperature.
-/
import Mathlib
import Novelty.ThermodynamicsOfProof

open Finset Real ThermoProof Filter

namespace ThermoProofComplexity

/-- The Landauer quantum: heat per erased bit at temperature `T`. -/
noncomputable def heatPerBit (kB T : ℝ) : ℝ := kB * T * Real.log 2

lemma heatPerBit_pos {kB T : ℝ} (hk : 0 < kB) (hT : 0 < T) : 0 < heatPerBit kB T := by
  unfold heatPerBit
  have : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  positivity

lemma logb_two_pow_card (k : ℕ) : Real.logb 2 (Fintype.card (Fin (2 ^ k))) = k := by
  rw [Fintype.card_fin]
  have h : ((2 ^ k : ℕ) : ℝ) = (2:ℝ) ^ k := by push_cast; ring
  rw [h, Real.logb_pow]
  simp

/-- **Memory-constrained verifiers dissipate.**  A verifier that must distinguish `2^S`
proofs but retains only `M` bits erases at least `S − M` bits, hence dissipates at least
`(S − M) · k_B T ln 2` of heat. -/
theorem verifier_heat_lower_bound (S M : ℕ) (f : Fin (2 ^ S) → Fin (2 ^ M)) {kB T : ℝ}
    (hk : 0 < kB) (hT : 0 < T) :
    ((S : ℝ) - M) * heatPerBit kB T ≤ landauerCost (erasedBits f) kB T := by
  have hbits : (S : ℝ) - M ≤ erasedBits f := by
    have := erasedBits_lower_bound f
    rwa [logb_two_pow_card S, logb_two_pow_card M] at this
  unfold landauerCost heatPerBit
  exact mul_le_mul_of_nonneg_right hbits (le_of_lt (heatPerBit_pos hk hT))

/-- Polynomials are eventually dominated by `2^n`, in the explicit form needed below. -/
lemma eventually_poly_le_two_pow (d : ℕ) (A : ℝ) :
    ∀ᶠ n : ℕ in atTop, A * (n : ℝ) ^ d ≤ (2:ℝ) ^ n := by
  rcases le_or_gt A 0 with hA | hA
  · filter_upwards with n
    have h1 : A * (n : ℝ) ^ d ≤ 0 := mul_nonpos_of_nonpos_of_nonneg hA (by positivity)
    have h2 : (0:ℝ) < 2 ^ n := by positivity
    linarith
  · have hlo := isLittleO_pow_const_const_pow_of_one_lt (R := ℝ) d (by norm_num : (1:ℝ) < 2)
    have := hlo.def (c := A⁻¹) (by positivity)
    filter_upwards [this] with n hn
    have h2 : (0:ℝ) < (2:ℝ) ^ n := by positivity
    rw [Real.norm_eq_abs, Real.norm_eq_abs, abs_of_nonneg (by positivity : (0:ℝ) ≤ (n:ℝ) ^ d),
      abs_of_nonneg (le_of_lt h2)] at hn
    calc A * (n : ℝ) ^ d ≤ A * (A⁻¹ * 2 ^ n) := by
          exact mul_le_mul_of_nonneg_left hn (le_of_lt hA)
      _ = 2 ^ n := by field_simp

/-- **Main theorem: proof-size lower bounds become superpolynomial heat.**  Suppose a family
of workloads forces `2^n` distinguishable proofs (an exponential proof-size lower bound) while
the verifier's ancillary memory is only polynomially large.  Then at fixed positive
temperature the dissipated heat eventually exceeds *every* polynomial `C · n^d`. -/
theorem heat_superpolynomial (d : ℕ) (C : ℝ) (proofSize memory : ℕ → ℕ)
    (hps : ∀ n, 2 ^ n ≤ proofSize n) (hmem : ∀ n, memory n ≤ n ^ d)
    (f : ∀ n, Fin (2 ^ proofSize n) → Fin (2 ^ memory n)) {kB T : ℝ}
    (hk : 0 < kB) (hT : 0 < T) :
    ∀ᶠ n : ℕ in atTop, C * (n : ℝ) ^ d ≤ landauerCost (erasedBits (f n)) kB T := by
  have hkappa := heatPerBit_pos hk hT
  filter_upwards [eventually_poly_le_two_pow d (C / heatPerBit kB T + 1)] with n hn
  have h1 := verifier_heat_lower_bound (proofSize n) (memory n) (f n) hk hT
  have hps' : (2:ℝ) ^ n ≤ (proofSize n : ℝ) := by exact_mod_cast hps n
  have hmem' : (memory n : ℝ) ≤ (n : ℝ) ^ d := by exact_mod_cast hmem n
  have hmul := mul_le_mul_of_nonneg_right hn (le_of_lt hkappa)
  have hexp : (C / heatPerBit kB T + 1) * (n : ℝ) ^ d * heatPerBit kB T
      = C * (n : ℝ) ^ d + (n : ℝ) ^ d * heatPerBit kB T := by
    field_simp
  rw [hexp] at hmul
  have hstep : (2:ℝ) ^ n * heatPerBit kB T
      ≤ ((proofSize n : ℝ) - memory n) * heatPerBit kB T + (n : ℝ) ^ d * heatPerBit kB T := by
    nlinarith [hps', hmem', hkappa]
  linarith [h1, hmul, hstep]

/-- The unbounded form: under an exponential proof-size lower bound and constant-order
memory the dissipated heat exceeds every constant. -/
theorem heat_unbounded_of_subexponential_memory (C : ℝ) (proofSize memory : ℕ → ℕ)
    (hps : ∀ n, 2 ^ n ≤ proofSize n) (hmem : ∀ n, memory n ≤ 1)
    (f : ∀ n, Fin (2 ^ proofSize n) → Fin (2 ^ memory n)) {kB T : ℝ}
    (hk : 0 < kB) (hT : 0 < T) :
    ∀ᶠ n : ℕ in atTop, C ≤ landauerCost (erasedBits (f n)) kB T := by
  have := heat_superpolynomial 0 C proofSize memory hps (by simpa using hmem) f hk hT
  filter_upwards [this] with n hn
  simpa using hn

end ThermoProofComplexity