import Cryptography.ChebotarevPrecision.FineDial
import Cryptography.NonabelianTypeChannel.Fields

/-!
# Paper 134 — Chebotarev precision III: diagnosing the `S3d` anomaly

The one anomaly of the simultaneous re-measurement: the `S3d` field (a cubic field with
Galois group `S₃`, read through a sparse residue dial) had a *historical* channel value
`1.0078` bits, while the exact law is `1` and the simultaneous re-measurement gave
`0.9998 ± 0.001`.  The diagnosis was "small-population plug-in bias on the sparse dial —
not physics, not dictionary drift".  This file proves both halves of that diagnosis.

**Not physics.**  `S3_anyDial_law` — for *every* uniform Artin dial over the `S₃` sign
readout (any number of residue classes, any fibre size), the population channel is
exactly `1` bit (fine-dial reduction + the `S₃` row).  So no population value of any
dial equals `1.0078`: `S3d_anomaly_diagnosis`.

**A concrete instance.**  For `x³ − x − 1` (discriminant `−23`) the Artin dial is the
quadratic character modulo `23` on the `22` nonzero residues (`S3d_dial_uniform`), and
`S3d_dial_law` gives the population value `1` exactly.  `S3d_dictionary` checks the class
field theory dictionary (root count `1` ⇔ non-residue mod `23`) on all primes below `100`,
from the explicit root counts of `x³ − x − 1 mod p`.

**Plug-in bias.**  `sparseDial_saturation` — on any finite sample on which the dial is
injective (every residue class seen at most once: the sparse regime) the plug-in channel
equals the plug-in type entropy, *whatever the law*.  `S3d_plugin_overshoot` exhibits it
on real primes: on the sample `{2, 5, 59}` of `x³ − x − 1` (inert, `1+2`, split) the
plug-in channel of the mod-`23` dial is `log₂ 3 ≈ 1.585` bits, above the law cap `1`.
-/

namespace TypeChannel

open Finset Real

set_option maxRecDepth 4000000

/-! ### Not physics: every dial over `S₃` has law exactly one bit -/

/-- **Every uniform Artin dial over `S₃` carries exactly one bit.** -/
theorem S3_anyDial_law {ρ : Type*} [DecidableEq ρ] {R : Finset ρ} {φ : ρ → ℕ} {m : ℕ}
    (hd : UniformDial S3 R signIdx φ m) :
    mutualInfo (fibreProduct S3 R signIdx φ) (fun w => w.2) (fun w => splitType w.1) = 1 := by
  rw [fineDial_reduction hd, S3_channel]

/-- **Diagnosis of the `S3d` anomaly.**  For every uniform dial over `S₃`, the historical
value `1.0078` exceeds the population law by more than `0.0075` bits (it is *not* a law
value of any dial), while the simultaneous re-measurement `0.9998` lies within `3σ = 0.003`
of it. -/
theorem S3d_anomaly_diagnosis {ρ : Type*} [DecidableEq ρ] {R : Finset ρ} {φ : ρ → ℕ} {m : ℕ}
    (hd : UniformDial S3 R signIdx φ m) :
    (0.0075 : ℝ) < 1.0078 -
        mutualInfo (fibreProduct S3 R signIdx φ) (fun w => w.2) (fun w => splitType w.1) ∧
      |(0.9998 : ℝ) -
        mutualInfo (fibreProduct S3 R signIdx φ) (fun w => w.2) (fun w => splitType w.1)|
          < 0.003 := by
  rw [S3_anyDial_law hd]
  constructor
  · norm_num
  · rw [abs_lt]; constructor <;> norm_num

/-! ### The concrete dial of `x³ − x − 1` -/

/-- The nonzero residues modulo `23`. -/
def R23 : Finset ℕ := (range 23).filter (fun r => r ≠ 0)

/-- The quadratic-character dial: `0` on squares mod `23`, `1` on non-squares. -/
def qr23 (r : ℕ) : ℕ := if r % 23 ∈ (List.range 23).map (fun x => x * x % 23) then 0 else 1

/-- The mod-`23` quadratic character is a uniform Artin dial over the `S₃` sign readout:
eleven residues over each coset. -/
theorem S3d_dial_uniform : UniformDial S3 R23 signIdx qr23 11 :=
  ⟨by norm_num, by decide⟩

/-- **The `S3d` population law**: the 22-class mod-`23` dial carries exactly one bit. -/
theorem S3d_dial_law :
    mutualInfo (fibreProduct S3 R23 signIdx qr23) (fun w => w.2) (fun w => splitType w.1) = 1 :=
  S3_anyDial_law S3d_dial_uniform

/-- Number of roots of `x³ − x − 1` modulo `p` (`0`: inert, `1`: type `1+2`, `3`: split). -/
def rootCount (p : ℕ) : ℕ :=
  ((range p).filter (fun x => (x ^ 3 + (p - 1) * x + (p - 1)) % p = 0)).card

/-- The unramified primes below `100`. -/
def smallPrimes : List ℕ :=
  [2, 3, 5, 7, 11, 13, 17, 19, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

/-- **Ground-truth dictionary check.**  For every unramified prime `p < 100`, the
splitting of `x³ − x − 1` is one of the three `S₃` shapes, and the prime has the
odd-Frobenius shape `1+2` (exactly one root) iff `p` is a non-residue modulo `23`. -/
theorem S3d_dictionary :
    ∀ p ∈ smallPrimes, (rootCount p = 0 ∨ rootCount p = 1 ∨ rootCount p = 3) ∧
      (rootCount p = 1 ↔ qr23 p = 1) := by
  decide

/-! ### Plug-in bias on a sparse dial -/

section Sparse

variable {Ω α β : Type*} [DecidableEq α] [DecidableEq β]

/-- **Sparse-dial saturation.**  If the dial separates the sample (each residue class is
seen at most once), the plug-in channel equals the plug-in type entropy, independently of
the true law. -/
theorem sparseDial_saturation {S : Finset Ω} {r : Ω → α} (T : Ω → β)
    (hinj : ∀ w ∈ S, ∀ w' ∈ S, r w = r w' → w = w') :
    mutualInfo S r T = entropy S T :=
  mutualInfo_eq_entropy_of_injOn hinj

end Sparse

/-- The three-prime sample `{2, 5, 59}`. -/
def S3dSample : Finset ℕ := {2, 5, 59}

theorem S3dSample_types : rootCount 2 = 0 ∧ rootCount 5 = 1 ∧ rootCount 59 = 3 := by decide

/-- **Plug-in overshoot on real primes.**  On the sample `{2, 5, 59}` the mod-`23` dial is
injective and the three splitting shapes are distinct, so the plug-in channel is
`log₂ 3`, strictly above the law cap of one bit (and above the historical `1.0078`). -/
theorem S3d_plugin_overshoot :
    mutualInfo S3dSample (fun p => p % 23) rootCount = logb 2 3 ∧
      (1.0078 : ℝ) < mutualInfo S3dSample (fun p => p % 23) rootCount := by
  have h : mutualInfo S3dSample (fun p => p % 23) rootCount = logb 2 3 := by
    rw [sparseDial_saturation rootCount (by decide)]
    have hcard : S3dSample.card = 3 := by decide
    rw [entropy_eq_sumList (A := [0, 1, 3]) (L := [1, 1, 1]) (by decide) (by decide)
      (by decide), hcard]
    simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
    rw [neg_prob_logb_real 1 3 (by norm_num) (by norm_num)]
    simp only [Real.logb_one]
    ring
  refine ⟨h, ?_⟩
  rw [h]
  have := logb2_three_gt_one
  have h2 : (1.0078 : ℝ) < 1.5 := by norm_num
  have h3 : (3 : ℝ) / 2 < logb 2 3 := by
    rw [Real.lt_logb_iff_rpow_lt (by norm_num) (by norm_num)]
    have hsq : ((2:ℝ) ^ ((3:ℝ)/2)) ^ (2:ℕ) < (3:ℝ) ^ (2:ℕ) := by
      rw [← Real.rpow_natCast, ← Real.rpow_mul (by norm_num)]
      norm_num
    exact lt_of_pow_lt_pow_left₀ 2 (by norm_num) hsq
  linarith

/-- **The overshoot is a finite-sample artefact, not a law.**  The same dial that reads
`log₂ 3` bits on the sparse sample reads exactly `1` bit on the Chebotarev population. -/
theorem S3d_sample_vs_population :
    mutualInfo (fibreProduct S3 R23 signIdx qr23) (fun w => w.2) (fun w => splitType w.1) <
      mutualInfo S3dSample (fun p => p % 23) rootCount := by
  rw [S3d_dial_law, S3d_plugin_overshoot.1]
  exact logb2_three_gt_one

end TypeChannel