import Mathlib
import Physics.MethodLocalityFactorLocal
import Physics.MethodLocalityNaturality

/-!
# Cycle 3: a rigidity theorem — reading the modulus forbids flatness

Cycle 1 refuted cofactor flatness for trial division by a numerical counterexample
(`trial_not_cofactor_flat`).  Cycle 3 replaces that counterexample by a structural
reason, and closes the loop of the round-28 verdict.

* `ModulusDetermined` — a cost model *reads the modulus* if its value does not depend
  on which factor is being hunted.  Trial division is of this kind
  (`trial_modulusDetermined`): its ledger is `minFac N - 1`, a function of `N` alone.
* `rigidity_of_modulusDetermined_flat` — **the rigidity theorem**: a modulus-determined
  cost model that is cofactor flat is *constant on all composite moduli*.  Flatness and
  modulus-dependence are therefore incompatible for any nonconstant method: there is no
  clever trial-division variant that becomes factor local while still reading only `N`.
* `trial_not_cofactorFlat_structural` — trial division's non-flatness re-derived from
  rigidity alone, with no appeal to the `4093·3` versus `4093·4093` computation.
* `rho_not_modulusDetermined` — conversely ρ's ledger genuinely reads the *factor*:
  `1` step at `p = 3` against `70` at `p = 4093` for the same seed.
* `rho_time_1009`, `advantage_grows` — a second kernel-verified anchor, `p = 1009`
  with ρ time `49`, and the resulting advantage over trial division: `20×` at
  `p = 1009` and `58×` at `p = 4093`, i.e. the separation widens with the factor, as
  the birthday exponent `1/2` against the definition exponent `1` predicts.
* `method_plane` — the cycle-3 synthesis: the two axes of the round-28 plane are
  "reads the factor" versus "reads the modulus", and flatness is exactly the first.
-/

namespace MethodLocalityRigid

open MethodLocality MethodLocalityNat

/-! ## 1. Reading the modulus -/

/-- A cost model is *modulus determined* if the hunted factor does not enter its
ledger: the run costs the same whichever factor it is aimed at. -/
def ModulusDetermined (cost : ℕ → ℕ → ℕ) : Prop := ∀ N p p' : ℕ, cost N p = cost N p'

theorem trial_modulusDetermined : ModulusDetermined trialCost := fun _ _ _ => rfl

/-- **Rigidity.**  A modulus-determined cost model that is cofactor flat takes the same
value on every composite `a·b` with positive factors: flatness plus modulus-dependence
forces triviality.  Hence no nonconstant method that reads only `N` can be factor
local. -/
theorem rigidity_of_modulusDetermined_flat {cost : ℕ → ℕ → ℕ}
    (hmd : ModulusDetermined cost) (hflat : CofactorFlat cost)
    {a b c d : ℕ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d) :
    cost (a * b) 0 = cost (c * d) 0 := by
  have hcd : 0 < c * d := Nat.mul_pos hc hd
  have step1 : cost (a * b) a = cost (a * (c * d)) a := hflat a b (c * d) hb hcd
  have step2 : cost ((c * d) * a) (c * d) = cost ((c * d) * 1) (c * d) :=
    hflat (c * d) a 1 ha Nat.one_pos
  have hcomm : a * (c * d) = (c * d) * a := Nat.mul_comm _ _
  calc cost (a * b) 0 = cost (a * b) a := hmd _ _ _
    _ = cost (a * (c * d)) a := step1
    _ = cost ((c * d) * a) (c * d) := by rw [hcomm]; exact hmd _ _ _
    _ = cost ((c * d) * 1) (c * d) := step2
    _ = cost (c * d) 0 := by rw [Nat.mul_one]; exact hmd _ _ _

/-- **Trial division is not cofactor flat — structurally.**  Its ledger reads the
modulus, so flatness would force it to cost the same on `4` and on `9`; it does
not (`1` versus `2` trial divisions). -/
theorem trial_not_cofactorFlat_structural : ¬ CofactorFlat trialCost := by
  intro hflat
  have h := rigidity_of_modulusDetermined_flat trial_modulusDetermined hflat
    (a := 2) (b := 2) (c := 3) (d := 3) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h4 : trialSteps (2 * 2) = 1 := by
    rw [trialSteps_eq_of_le (by norm_num) (by norm_num) (le_refl 2)]
  have h9 : trialSteps (3 * 3) = 2 := by
    rw [trialSteps_eq_of_le (by norm_num) (by norm_num) (le_refl 3)]
  rw [trialCost, trialCost, h4, h9] at h
  omega

/-! ## 2. ρ reads the factor -/

/-- At the prime `3` the ρ orbit of `x ↦ x² + 1` from `2` is stationary: cost `1`. -/
theorem rho_time_3 : rhoTimeAtFactor 3 1 2 = 1 := by
  have hseq : ∀ n : ℕ, rhoSeq ((1 : ℤ) : ZMod 3) ((2 : ℤ) : ZMod 3) n
      = rhoSeq (1 : ZMod 3) 2 n := by
    intro n; norm_num
  rw [rhoTimeAtFactor, collTime_congr hseq]
  refine collTime_eq ⟨0, Nat.zero_lt_one, by decide⟩ ?_
  rintro m hm ⟨i, him, -⟩
  omega

/-- **ρ's ledger is not modulus determined**: with the same seed it costs `1` step
against the factor `3` and `70` against the factor `4093`.  The factor, not the
modulus, is the argument of the cost function — the positive half of the round-28
verdict. -/
theorem rho_not_modulusDetermined : ¬ ModulusDetermined rhoCost := by
  intro h
  have := h 12279 3 4093
  rw [rhoCost, rhoCost, rho_time_3, rho_time_4093] at this
  omega

/-! ## 3. A second anchor, and the widening advantage -/

set_option maxRecDepth 100000 in
theorem rho_1009_nodup :
    ((List.range 49).map (fun n => rhoSeq (1 : ZMod 1009) 2 n)).Nodup := by
  decide

set_option maxRecDepth 100000 in
theorem rho_1009_collide : rhoSeq (1 : ZMod 1009) 2 0 = rhoSeq (1 : ZMod 1009) 2 49 := by
  decide

/-- Kernel-verified second anchor: at `p = 1009` the ρ orbit closes after `49` steps
(`√1009 ≈ 31`). -/
theorem rho_time_1009 : rhoTimeAtFactor 1009 1 2 = 49 := by
  have hseq : ∀ n : ℕ, rhoSeq ((1 : ℤ) : ZMod 1009) ((2 : ℤ) : ZMod 1009) n
      = rhoSeq (1 : ZMod 1009) 2 n := by
    intro n; norm_num
  rw [rhoTimeAtFactor, collTime_congr hseq]
  refine collTime_eq ⟨0, by norm_num, rho_1009_collide⟩ ?_
  rintro m hm ⟨i, him, hEq⟩
  have := List.inj_on_of_nodup_map rho_1009_nodup
    (x := i) (List.mem_range.mpr (by omega)) (y := m) (List.mem_range.mpr (by omega)) hEq
  omega

/-- **The advantage widens with the factor.**  Against trial division, ρ is at least
`20×` cheaper at `p = 1009` and at least `58×` cheaper at `p = 4093`: two points of the
`0.45` versus `1.09` slope separation, both verified rather than fitted. -/
theorem advantage_grows :
    20 * rhoTimeAtFactor 1009 1 2 ≤ trialSteps (1009 * 1009) ∧
      58 * rhoTimeAtFactor 4093 1 2 ≤ trialSteps (4093 * 4093) ∧
      20 < 58 := by
  refine ⟨?_, ?_, by norm_num⟩
  · rw [rho_time_1009, trialSteps_eq_of_le (by norm_num) (by norm_num) (le_refl 1009)]
    norm_num
  · rw [rho_time_4093, trialSteps_eq_of_le (by norm_num) (by norm_num) (le_refl 4093)]
    norm_num

/-! ## 4. The method plane -/

/-- **The round-28 plane, closed.**  A method is factor local exactly when its ledger
reads the factor: uniform (natural) methods are cofactor flat and bounded by `p`;
a method that reads only the modulus is cofactor flat only if it is constant, so trial
division — whose cost `minFac N - 1` is a genuine function of `N` — cannot be. -/
theorem method_plane :
    (∀ (M : UniformStep) (p q q' : ℕ) (x0 : ℤ) (h : p ∣ p * q) (h' : p ∣ p * q'),
        uniformTime M p (p * q) h x0 = uniformTime M p (p * q') h' x0) ∧
      (∀ cost : ℕ → ℕ → ℕ, ModulusDetermined cost → CofactorFlat cost →
        ∀ a b c d : ℕ, 0 < a → 0 < b → 0 < c → 0 < d →
          cost (a * b) 0 = cost (c * d) 0) ∧
      (ModulusDetermined trialCost ∧ ¬ CofactorFlat trialCost) ∧
      ¬ ModulusDetermined rhoCost :=
  ⟨fun M _ _ _ x0 h h' => uniform_cofactor_flat M x0 h h',
    fun _ hmd hflat _ _ _ _ ha hb hc hd =>
      rigidity_of_modulusDetermined_flat hmd hflat ha hb hc hd,
    ⟨trial_modulusDetermined, trial_not_cofactorFlat_structural⟩,
    rho_not_modulusDetermined⟩

end MethodLocalityRigid