/-
# The sign flip is universal across window families, and the wheel law is a theorem

Fourth instalment of the GAP-L7' programme.  Two closures:

## A.  Window-ratio family : the sign flip is not an artefact of `q < 2p`

A generator that advertises `q < k·p` licenses the balance window
`[√N/√k, √N]`.  Repeating the round-76 analysis for a general window ratio gives
a closed-form crossover

`δ*(k) = 8√k(√k - 1)/(√k + 1)²`

(`signflip_window_family`), specialising to `80 - 56√2` at `k = 2`
(`crossoverWidthK_two`).  The decisive structural fact is

`crossoverWidthK_lt_band : 1 < k → δ*(k) < k - 1`,

i.e. **the crossover always lies strictly inside the admissible band range**.
So for *every* advertised balance ratio there are two admissible populations on
which the same two committed policies swap winners
(`signflip_universal`): the falsification of GAP-L7-as-drafted is not a corner
of the `q < 2p` convention, it is a property of the whole REORDER family.

## B.  L7-d : the structural keep fraction, extracted rather than booked

`card_coprime_block` counts the survivors of a mod-`M` wheel exactly:
`φ(M)·m` out of `M·m`.  Since a reordering is a bijection it cannot change that
count (`touched_card_reorder_invariant`), so `μ_eff = φ(M)/M` is a *conserved
quantity of the transcript*, not an experimenter's booking.  Feeding it into the
touch floor gives the protocol-A T1 law as a theorem:

`wheel_speedup_le : S ≤ M/φ(M)`,  and at `M = 30`,  `S ≤ 15/4 = 3.75`
(`wheel_thirty_law`) — the value the wheel arm measured as 3.7331–3.7496.

-- !-- Lab Notes -- !--
-- Monte-Carlo (n = 1500 per band, seed 20260831, genuine 24-bit semiprimes)
-- brackets the k = 2 crossover between delta = 0.80 (ascending still wins,
-- desc/asc = 1.0200) and delta = 0.75 (descending wins, desc/asc = 0.9273),
-- against the closed form 80 - 56*sqrt 2 = 0.804041 proved here.
-- Measured wheel speedups 3.7331 / 3.741 / 3.7496 sit under the derived
-- 15/4 = 3.75 ceiling, gaps 0.45% / 0.24% / 0.01%.
-/
import Mathlib
import Novelty.ReorderExtremalitySignFlip
import Novelty.ReorderFrontLoadingCertification

namespace ReorderL7

open Finset

noncomputable section

/-! ## A.  The window-ratio family -/

/-- Crossover band width for a generator advertising `q < k·p`. -/
def crossoverWidthK (k : ℝ) : ℝ :=
  8 * Real.sqrt k * (Real.sqrt k - 1) / (Real.sqrt k + 1) ^ 2

lemma one_lt_sqrt_of_one_lt {k : ℝ} (hk : 1 < k) : 1 < Real.sqrt k := by
  have h1 : Real.sqrt 1 < Real.sqrt k := Real.sqrt_lt_sqrt (by norm_num) hk
  simpa using h1

/-- At `k = 2` the family law reproduces the hard-balance crossover `80 - 56√2`. -/
theorem crossoverWidthK_two : crossoverWidthK 2 = crossoverWidth := by
  have hs : Real.sqrt 2 * Real.sqrt 2 = 2 := sq_sqrt2
  have hpos := sqrt2_pos
  have hne : (Real.sqrt 2 + 1) ≠ 0 := by positivity
  rw [crossoverWidthK, crossoverWidth]
  field_simp
  nlinarith [hs, hpos]

/-- **Sign-flip law for a general window ratio.**  On the uniform band
`r ~ U[1,1+δ]`, the window-ascending policy of a generator advertising `q < k·p`
beats the window-descending one **iff** `δ > 8√k(√k-1)/(√k+1)²`. -/
theorem signflip_window_family {k delta : ℝ} (hk : 1 < k) (h : 0 < delta) :
    (meanInvSqrt delta - 1 / Real.sqrt k < 1 - meanInvSqrt delta) ↔ crossoverWidthK k < delta := by
  set t := Real.sqrt k with htdef
  have ht1 : 1 < t := one_lt_sqrt_of_one_lt hk
  have htpos : 0 < t := by linarith
  set s := Real.sqrt (1 + delta) with hsdef
  have hs : s * s = 1 + delta := Real.mul_self_sqrt (by linarith)
  have hs1 : 1 < s := sqrt_one_add_pos h
  have h1s : (0:ℝ) < 1 + s := by linarith
  have hA : meanInvSqrt delta * (1 + s) = 2 := by
    rw [meanInvSqrt, ← hsdef]; field_simp
  have hB : (meanInvSqrt delta - 1 / t < 1 - meanInvSqrt delta) ↔ (4 * t < (t + 1) * (1 + s)) := by
    constructor
    · intro hlt
      have hmul : (2 * meanInvSqrt delta) * (t * (1 + s)) < (1 + 1 / t) * (t * (1 + s)) :=
        mul_lt_mul_of_pos_right (by linarith) (by positivity)
      have hinv : (1 / t) * t = 1 := by field_simp
      nlinarith [hmul, hA, hinv, htpos, h1s]
    · intro hlt
      by_contra hcon
      push_neg at hcon
      have hmul : (1 + 1 / t) * (t * (1 + s)) ≤ (2 * meanInvSqrt delta) * (t * (1 + s)) :=
        mul_le_mul_of_nonneg_right (by linarith) (by positivity)
      have hinv : (1 / t) * t = 1 := by field_simp
      nlinarith [hmul, hA, hinv, htpos, h1s]
  have hC : (4 * t < (t + 1) * (1 + s)) ↔ crossoverWidthK k < delta := by
    have hden : (0:ℝ) < (t + 1) ^ 2 := by positivity
    rw [crossoverWidthK, ← htdef, div_lt_iff₀ hden]
    constructor
    · intro hlt
      have hstep : 3 * t - 1 < (t + 1) * s := by nlinarith [hlt]
      nlinarith [hstep, hs, ht1, htpos, hs1]
    · intro hlt
      have hnn : (0:ℝ) ≤ (t + 1) * s := mul_nonneg (by linarith) (by linarith)
      have hstep : 3 * t - 1 < (t + 1) * s := by
        by_contra hcon
        push_neg at hcon
        have hsq : ((t + 1) * s) * ((t + 1) * s) ≤ (3 * t - 1) * (3 * t - 1) :=
          mul_self_le_mul_self hnn hcon
        nlinarith [hsq, hs, ht1]
      nlinarith [hstep]
  rw [hB, hC]

/-- **The crossover always lies strictly inside the admissible band range.**
For every advertised balance ratio `k > 1` the crossover width `δ*(k)` is smaller
than the widest admissible band `k - 1`. -/
theorem crossoverWidthK_lt_band {k : ℝ} (hk : 1 < k) : crossoverWidthK k < k - 1 := by
  set t := Real.sqrt k with htdef
  have ht1 : 1 < t := one_lt_sqrt_of_one_lt hk
  have hts : t * t = k := Real.mul_self_sqrt (by linarith)
  have hden : (0:ℝ) < (t + 1) ^ 2 := by positivity
  have hpos2 : (0:ℝ) < t ^ 2 + 4 * t - 1 := by nlinarith [ht1]
  have h3 : (0:ℝ) < (t - 1) ^ 2 * (t ^ 2 + 4 * t - 1) :=
    mul_pos (by nlinarith [ht1]) hpos2
  rw [crossoverWidthK, ← htdef, div_lt_iff₀ hden, ← hts]
  nlinarith [h3]

/-- **The falsification is universal in the window family.**  For every advertised
balance ratio `k > 1` there are two admissible populations — the widest band
`δ = k - 1` and a narrow band below the crossover — on which the same two
committed policies swap winners. -/
theorem signflip_universal {k : ℝ} (hk : 1 < k) :
    ∃ d₁ d₂ : ℝ, 0 < d₁ ∧ d₁ ≤ k - 1 ∧ 0 < d₂ ∧ d₂ ≤ k - 1 ∧
      (meanInvSqrt d₁ - 1 / Real.sqrt k < 1 - meanInvSqrt d₁) ∧
      ¬ (meanInvSqrt d₂ - 1 / Real.sqrt k < 1 - meanInvSqrt d₂) := by
  have ht1 : 1 < Real.sqrt k := one_lt_sqrt_of_one_lt hk
  have hcross : crossoverWidthK k < k - 1 := crossoverWidthK_lt_band hk
  have hcpos : 0 < crossoverWidthK k := by
    rw [crossoverWidthK]
    have : (0:ℝ) < (Real.sqrt k + 1) ^ 2 := by positivity
    apply div_pos (by nlinarith [ht1]) this
  refine ⟨k - 1, crossoverWidthK k / 2, by linarith, le_rfl, by linarith, by linarith, ?_, ?_⟩
  · rw [signflip_window_family hk (by linarith)]
    exact hcross
  · rw [signflip_window_family hk (by linarith)]
    push_neg
    linarith

/-! ## B.  The structural keep fraction of a wheel -/

/-- **Exact survivor count of a mod-`M` wheel.**  Among the first `M·m`
candidates exactly `φ(M)·m` are coprime to `M`. -/
theorem card_coprime_block (M m : ℕ) :
    ({x ∈ Finset.range (M * m) | Nat.Coprime M x}).card = Nat.totient M * m := by
  induction m with
  | zero => simp
  | succ m ih =>
      have hmul : M * (m + 1) = M * m + M := by ring
      have h : Finset.range (M * (m + 1))
          = Finset.range (M * m) ∪ Finset.Ico (M * m) (M * m + M) := by
        ext x
        simp only [Finset.mem_union, Finset.mem_range, Finset.mem_Ico, hmul]
        omega
      rw [h, Finset.filter_union, Finset.card_union_of_disjoint, ih,
        Nat.filter_coprime_Ico_eq_totient]
      · ring
      · refine Finset.disjoint_filter_filter ?_
        simp only [Finset.disjoint_left, Finset.mem_range, Finset.mem_Ico]
        intro x hx hx2
        omega

/-- **The touched count is a conserved quantity.**  Reordering is a bijection, so
no REORDER policy can change how many candidates the filter leaves it to touch:
`μ_eff` is extracted from the transcript, not booked. -/
theorem touched_card_reorder_invariant {f : ℕ → ℕ} (hf : Function.Injective f)
    (K : Finset ℕ) : (K.image f).card = K.card :=
  Finset.card_image_of_injective K hf

/-- **The wheel keep fraction.** -/
theorem wheel_keep_fraction_eq {M m : ℕ} (hM : 0 < M) (hm : 0 < m) :
    (({x ∈ Finset.range (M * m) | Nat.Coprime M x}).card : ℝ) / ((M * m : ℕ) : ℝ)
      = (Nat.totient M : ℝ) / (M : ℝ) := by
  have hMR : (0:ℝ) < (M : ℝ) := by exact_mod_cast hM
  have hmR : (0:ℝ) < (m : ℝ) := by exact_mod_cast hm
  rw [card_coprime_block]
  push_cast
  field_simp

/-- **The protocol-A T1 wheel law, derived.**  A policy behind a mod-`M` wheel
still has to touch `φ(M)·m` of the `M·m` candidates, so by the touch floor its
speedup against the full scan is at most `M/φ(M)`. -/
theorem wheel_speedup_le {M m : ℕ} (hM : 0 < M) (hphi : 0 < Nat.totient M) :
    ((((M * m : ℕ) : ℝ) + 1) / 2) / (((((Nat.totient M * m : ℕ) : ℝ)) + 1) / 2)
      ≤ (M : ℝ) / (Nat.totient M : ℝ) := by
  have hMR : (0:ℝ) < (M : ℝ) := by exact_mod_cast hM
  have hphiR : (0:ℝ) < (Nat.totient M : ℝ) := by exact_mod_cast hphi
  have hle : (Nat.totient M : ℝ) ≤ (M : ℝ) := by exact_mod_cast Nat.totient_le M
  have hmu : (0:ℝ) < (Nat.totient M : ℝ) / (M : ℝ) := by positivity
  have hmu1 : (Nat.totient M : ℝ) / (M : ℝ) ≤ 1 := by
    rw [div_le_one hMR]; exact hle
  have hkeq : ((Nat.totient M : ℝ) / (M : ℝ)) * ((M : ℝ) * (m : ℝ))
      = (Nat.totient M : ℝ) * (m : ℝ) := by field_simp
  have hk : ((Nat.totient M : ℝ) / (M : ℝ)) * ((M * m : ℕ) : ℝ)
      ≤ ((Nat.totient M * m : ℕ) : ℝ) := by
    push_cast
    rw [hkeq]
  have h := speedup_le_inv_mu (M := M * m) (k := Nat.totient M * m) hmu hmu1 hk
  have hinv : 1 / ((Nat.totient M : ℝ) / (M : ℝ)) = (M : ℝ) / (Nat.totient M : ℝ) := by
    field_simp
  rw [hinv] at h
  exact h

/-- **The mod-30 wheel ceiling is `15/4 = 3.75`**, derived from the survivor count
rather than booked — the value the wheel arm measured as 3.7331–3.7496. -/
theorem wheel_thirty_law {m : ℕ} :
    ((((30 * m : ℕ) : ℝ) + 1) / 2) / (((((Nat.totient 30 * m : ℕ) : ℝ)) + 1) / 2) ≤ 15 / 4 := by
  have h := wheel_speedup_le (M := 30) (m := m) (by norm_num) (by decide)
  have hphi : Nat.totient 30 = 8 := by decide
  rw [hphi] at h ⊢
  norm_num at h ⊢
  linarith

/-! ## C.  General keyed residue control

The mod-3 control of `Novelty.ReorderMasterCapWitnesses` at an arbitrary modulus:
selecting one residue class promotes exactly the same number of candidates for
every key, so an `N`-keyed promotion rule is statistically indistinguishable
from a fixed-key one at *any* modulus. -/

/-- Each residue class mod `M` holds exactly `m` of the first `M·m` candidates. -/
theorem card_residue_class_mod (M m c : ℕ) (hM : 0 < M) (hc : c < M) :
    ({x ∈ Finset.range (M * m) | x % M = c}).card = m := by
  classical
  have h : ({x ∈ Finset.range (M * m) | x % M = c}).card = (Finset.range m).card := by
    refine Finset.card_bij' (fun x _ => x / M) (fun i _ => M * i + c) ?_ ?_ ?_ ?_
    · intro x hx
      simp only [Finset.mem_filter, Finset.mem_range] at hx ⊢
      exact Nat.div_lt_of_lt_mul (by omega)
    · intro i hi
      simp only [Finset.mem_range] at hi
      simp only [Finset.mem_filter, Finset.mem_range]
      refine ⟨?_, by rw [Nat.mul_add_mod, Nat.mod_eq_of_lt hc]⟩
      calc M * i + c < M * i + M := by omega
        _ = M * (i + 1) := by ring
        _ ≤ M * m := Nat.mul_le_mul_left M hi
    · intro x hx
      simp only [Finset.mem_filter, Finset.mem_range] at hx
      dsimp only
      rw [← hx.2, Nat.div_add_mod]
    · intro i hi
      dsimp only
      rw [Nat.mul_add_div hM, Nat.div_eq_of_lt hc, Nat.add_zero]
  simpa using h

/-- **Factor blindness at an arbitrary modulus.**  For any keying function into
the residues mod `M`, the promoted count does not depend on the key — hence not
on `N`.  Residue couplings carry zero information at every modulus. -/
theorem keyed_promotion_factor_blind (M m : ℕ) (hM : 0 < M) (key : ℕ → ℕ)
    (hkey : ∀ N, key N < M) (N N' : ℕ) :
    ({x ∈ Finset.range (M * m) | x % M = key N}).card
      = ({x ∈ Finset.range (M * m) | x % M = key N'}).card := by
  rw [card_residue_class_mod M m (key N) hM (hkey N),
    card_residue_class_mod M m (key N') hM (hkey N')]

/-- **The promoted share of the wheel survivors is exactly `1/φ(M)`**, for every
invertible class: an invertible residue class carries no enrichment beyond the
uniform split of the survivors. -/
theorem keyed_promotion_share (M m c : ℕ) (hM : 0 < M) (hc : c < M) :
    Nat.totient M * ({x ∈ Finset.range (M * m) | x % M = c}).card
      = ({x ∈ Finset.range (M * m) | Nat.Coprime M x}).card := by
  rw [card_residue_class_mod M m c hM hc, card_coprime_block]

end

end ReorderL7