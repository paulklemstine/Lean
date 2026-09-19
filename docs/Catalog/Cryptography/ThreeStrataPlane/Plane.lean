import Cryptography.ThreeStrataPlane.ExponentCalculus
import Cryptography.ThreeStrataPlane.StratumA
import Cryptography.FactoringBarriers.ResourceClassification

/-!
# The three-strata plane

One plane, one coordinate (`α`, the measured exponent on `N`), three strata:

| stratum | representative | profile in `x = log N` | exponent |
|---------|----------------|------------------------|----------|
| A — definition-routes | `τ(N)`, `σ₁(N)` by trial division | `exp (x/2)` | `1/2` |
| B — classical methods | Pollard `ρ` | `exp (x/4)` | `1/4` |
| C — quantum           | Shor          | `8 x³`      | `0`   |

Main results.

* `scanProfile_exponent`, `rhoProfile_exponent`, `shorProfile_exponent` — the
  three coordinates, proved from the exponent calculus, not asserted.
* `rhoProfile_eq_randomness_barrier` — Stratum B's profile *is* the randomness
  barrier already classified in `FactoringBarriers.ResourceClassification`, so
  the plane extends the existing catalog rather than duplicating it.
* `three_strata_strictly_ordered` — the three strata are eventually strictly
  ordered; no two of them coincide asymptotically.
* `blindnessPrice_eq`, `blindnessPrice_strictMono`,
  `blindnessPrice_tendsto_atTop` — **the price of structure-blindness**.  The
  ratio (definition-route cost)/(method cost) equals `exp (x/4) = N^{1/4}`
  exactly: strictly increasing in `N` and unbounded.  This is the asymptotic law
  behind the measured factors `173× (2¹⁶) → 8310× (2²⁸)`.
* `rhoBitProfile_exponent_per_prime_bit`, `rho_exponent_on_N`,
  `rho_units_mismatch` — **the units ledger**.  A slope of `1/2` measured per
  *prime bit* is an exponent of `1/4` on `N`, because `log N = 2 log p`; the two
  readings are provably different numbers, so the mismatch is a theorem, not a
  matter of taste.
* `quantum_below_classical`, `definition_route_not_polyBounded` — Stratum C is
  polynomially bounded while Strata A and B are not.
* `scanProfile_log_nat`, `scanCost_le_scanProfile` — the bridge from the
  continuous profile back to the discrete `⌊√N⌋` scan of `StratumA.lean`.
-/

namespace ThreeStrata

open Filter Real FactoringBarriers
open scoped Topology

/-! ## The three profiles -/

/-- Stratum A: cost of a structure-blind definition-route (`τ`, `σ₁` by trial
division); also the worst case of trial division and of Fermat's method. -/
noncomputable def scanProfile : ℝ → ℝ := fun x => Real.exp (x / 2)

/-- Stratum B: cost of Pollard's `ρ`, the birthday-bound method. -/
noncomputable def rhoProfile : ℝ → ℝ := fun x => Real.exp (x / 4)

/-- Stratum C: cost of Shor's algorithm, a polynomial in the bit-size. -/
noncomputable def shorProfile : ℝ → ℝ := fun x => 8 * x ^ (3 : ℝ)

theorem scanProfile_pos (x : ℝ) : 0 < scanProfile x := Real.exp_pos _

theorem rhoProfile_pos (x : ℝ) : 0 < rhoProfile x := Real.exp_pos _

theorem shorProfile_pos {x : ℝ} (hx : 0 < x) : 0 < shorProfile x := by
  have : (0:ℝ) < x ^ (3 : ℝ) := Real.rpow_pos_of_pos hx 3
  simpa [shorProfile] using by positivity

/-- Stratum B's profile is exactly the randomness barrier of the existing
classification. -/
theorem rhoProfile_eq_randomness_barrier : rhoProfile = barrierCost .randomness := by
  funext x; simp [rhoProfile, barrierCost]; ring_nf

/-! ## The three measured coordinates -/

/-- Stratum A sits at `α = 1/2`. -/
theorem scanProfile_exponent : HasExponent scanProfile (1 / 2) := by
  have := hasExponent_exp_linear (1 / 2 : ℝ)
  refine this.congr' ?_
  filter_upwards with x
  simp [scanProfile]
  ring_nf

/-- Stratum B sits at `α = 1/4`. -/
theorem rhoProfile_exponent : HasExponent rhoProfile (1 / 4) := by
  have := hasExponent_exp_linear (1 / 4 : ℝ)
  refine this.congr' ?_
  filter_upwards with x
  simp [rhoProfile]
  ring_nf

/-- Stratum C sits at `α = 0`. -/
theorem shorProfile_exponent : HasExponent shorProfile 0 :=
  hasExponent_rpow (C := 8) (d := 3) (by norm_num)

/-! ## The strata are strictly ordered -/

/-- Stratum B is strictly cheaper than Stratum A for every `N > 1`. -/
theorem rhoProfile_lt_scanProfile {x : ℝ} (hx : 0 < x) : rhoProfile x < scanProfile x := by
  rw [rhoProfile, scanProfile, Real.exp_lt_exp]
  linarith

/-- Stratum C is eventually strictly cheaper than Stratum B. -/
theorem shorProfile_lt_rhoProfile : ∀ᶠ x in atTop, shorProfile x < rhoProfile x := by
  have hprice := exponent_gap_price shorProfile_exponent rhoProfile_exponent
    (by norm_num : (0:ℝ) < 1 / 4)
    (by filter_upwards [eventually_gt_atTop (0:ℝ)] with x hx using shorProfile_pos hx)
    (Eventually.of_forall (fun x => rhoProfile_pos x))
  have hgt : ∀ᶠ x in atTop, 1 < rhoProfile x / shorProfile x :=
    hprice.2.eventually_gt_atTop 1
  filter_upwards [hgt, eventually_gt_atTop (0:ℝ)] with x hx hx0
  have hs : 0 < shorProfile x := shorProfile_pos hx0
  rw [lt_div_iff₀ hs] at hx
  linarith

/-- **The plane is non-degenerate.**  Eventually
`shor < ρ < definition-route`, strictly. -/
theorem three_strata_strictly_ordered :
    ∀ᶠ x in atTop, shorProfile x < rhoProfile x ∧ rhoProfile x < scanProfile x := by
  filter_upwards [shorProfile_lt_rhoProfile, eventually_gt_atTop (0:ℝ)] with x h hx
  exact ⟨h, rhoProfile_lt_scanProfile hx⟩

/-- The three exponents are three distinct numbers. -/
theorem three_exponents_distinct :
    ¬ HasExponent scanProfile (1 / 4) ∧ ¬ HasExponent rhoProfile 0 := by
  constructor
  · intro h
    have := scanProfile_exponent.unique h
    norm_num at this
  · intro h
    have := rhoProfile_exponent.unique h
    norm_num at this

/-! ## The price of structure-blindness -/

/-- The cost ratio between the structure-blind definition-route and the
structure-exploiting method. -/
noncomputable def blindnessPrice (x : ℝ) : ℝ := scanProfile x / rhoProfile x

/-- **The price is exactly `N^{1/4}`.** -/
theorem blindnessPrice_eq (x : ℝ) : blindnessPrice x = Real.exp (x / 4) := by
  rw [blindnessPrice, scanProfile, rhoProfile, ← Real.exp_sub]
  ring_nf

/-- The price grows strictly with `N`: it is not a constant overhead. -/
theorem blindnessPrice_strictMono : StrictMono blindnessPrice := by
  intro a b hab
  rw [blindnessPrice_eq, blindnessPrice_eq, Real.exp_lt_exp]
  linarith

/-- The price has its own measured exponent `1/4`, and diverges. -/
theorem blindnessPrice_exponent_and_divergence :
    HasExponent blindnessPrice (1 / 4) ∧ Tendsto blindnessPrice atTop atTop := by
  have h := exponent_gap_price rhoProfile_exponent scanProfile_exponent (by norm_num)
    (Eventually.of_forall (fun x => rhoProfile_pos x))
    (Eventually.of_forall (fun x => scanProfile_pos x))
  have hcongr : (fun x => scanProfile x / rhoProfile x) = blindnessPrice := rfl
  rw [hcongr] at h
  refine ⟨?_, h.2⟩
  have : (1:ℝ) / 2 - 1 / 4 = 1 / 4 := by norm_num
  rw [this] at h
  exact h.1

theorem blindnessPrice_tendsto_atTop : Tendsto blindnessPrice atTop atTop :=
  blindnessPrice_exponent_and_divergence.2

/-! ## The units ledger: per-prime-bit slope versus exponent on `N` -/

/-- Pollard `ρ` measured in the *prime* bit-size `b = log p`: `log(ops) = b/2 - log 2`,
the standalone calibration. -/
noncomputable def rhoBitProfile : ℝ → ℝ := fun b => Real.exp (b / 2 - Real.log 2)

/-- In prime-bit units the slope is `1/2`. -/
theorem rhoBitProfile_exponent_per_prime_bit : HasExponent rhoBitProfile (1 / 2) := by
  have := hasExponent_exp_affine (1 / 2 : ℝ) (-Real.log 2)
  refine this.congr' ?_
  filter_upwards with x
  simp [rhoBitProfile]
  ring_nf

/-- **The units correction.**  For a balanced semiprime `log N = 2 log p`, so the
same cost, read on `N`, has exponent `1/4` — the birthday exponent. -/
theorem rho_exponent_on_N : HasExponent (fun x => rhoBitProfile (x / 2)) (1 / 4) := by
  have h := rhoBitProfile_exponent_per_prime_bit.comp_div (c := 2) (by norm_num)
  have : (1:ℝ) / 2 / 2 = 1 / 4 := by norm_num
  rwa [this] at h

/-- **The mismatch is a theorem.**  The per-prime-bit slope `1/2` is *not* the
exponent on `N`: reading it as such is off by the factor `log N / log p = 2`. -/
theorem rho_units_mismatch : ¬ HasExponent (fun x => rhoBitProfile (x / 2)) (1 / 2) := by
  intro h
  have := rho_exponent_on_N.unique h
  norm_num at this

/-- The corrected reading agrees with the birthday bound `α = 1/4` recorded for
the randomness barrier. -/
theorem rho_matches_birthday_bound :
    HasExponent (fun x => rhoBitProfile (x / 2)) (1 / 4) ∧ HasExponent rhoProfile (1 / 4) :=
  ⟨rho_exponent_on_N, rhoProfile_exponent⟩

/-! ## Quantum versus classical on the same plane -/

/-- Stratum C is polynomially bounded. -/
theorem shorProfile_polyBounded : PolyBounded shorProfile :=
  ⟨8, 3, Eventually.of_forall (fun _ => le_refl _)⟩

/-- Stratum B is not polynomially bounded. -/
theorem rhoProfile_not_polyBounded : ¬ PolyBounded rhoProfile :=
  rhoProfile_exponent.not_polyBounded (by norm_num)
    (Eventually.of_forall (fun x => rhoProfile_pos x))

/-- Stratum A is not polynomially bounded: a definition-route evaluated from `N`
alone cannot be a polynomial-time factoring algorithm. -/
theorem definition_route_not_polyBounded : ¬ PolyBounded scanProfile :=
  scanProfile_exponent.not_polyBounded (by norm_num)
    (Eventually.of_forall (fun x => scanProfile_pos x))

/-- **Quantum corner.**  Stratum C is polynomially bounded while Strata A and B
are not; the quantum stratum is therefore separated from both classical strata
by the same measurement. -/
theorem quantum_below_classical :
    PolyBounded shorProfile ∧ ¬ PolyBounded rhoProfile ∧ ¬ PolyBounded scanProfile :=
  ⟨shorProfile_polyBounded, rhoProfile_not_polyBounded, definition_route_not_polyBounded⟩

/-! ## Bridge to the discrete Stratum A -/

/-- The continuous Stratum A profile evaluated at `x = log N` is `√N`. -/
theorem scanProfile_log_nat {N : ℕ} (hN : 0 < N) :
    scanProfile (Real.log N) = Real.sqrt N := by
  have hpos : (0:ℝ) < (N:ℝ) := by exact_mod_cast hN
  rw [scanProfile, Real.sqrt_eq_rpow, Real.rpow_def_of_pos hpos]
  ring_nf

/-- The discrete trial-division scan cost of `StratumA.lean` is sandwiched by the
continuous profile: `scanCost N ≤ √N < scanCost N + 1`. -/
theorem scanCost_le_scanProfile {N : ℕ} (hN : 0 < N) :
    (scanCost N : ℝ) ≤ scanProfile (Real.log N) ∧
      scanProfile (Real.log N) < (scanCost N : ℝ) + 1 := by
  rw [scanProfile_log_nat hN]
  have h1 : ((Nat.sqrt N : ℝ)) ^ 2 ≤ (N : ℝ) := by exact_mod_cast Nat.sqrt_le' N
  have h2 : (N : ℝ) < ((Nat.sqrt N : ℝ) + 1) ^ 2 := by exact_mod_cast Nat.lt_succ_sqrt' N
  constructor
  · exact (Real.le_sqrt (by positivity) (by positivity)).2 h1
  · have : Real.sqrt (N:ℝ) < (Nat.sqrt N : ℝ) + 1 := by
      refine (Real.sqrt_lt' (by positivity)).2 h2
    simpa [scanCost] using this

/-! ## Capstone -/

/-- **The three-strata plane.**  One measurement, three strata, strictly ordered
exponents `0 < 1/4 < 1/2`, with the gap between the definition-route stratum and
the method stratum realised as an unbounded, strictly increasing price. -/
theorem three_strata_plane :
    HasExponent shorProfile 0 ∧
    HasExponent rhoProfile (1 / 4) ∧
    HasExponent scanProfile (1 / 2) ∧
    (∀ᶠ x in atTop, shorProfile x < rhoProfile x ∧ rhoProfile x < scanProfile x) ∧
    StrictMono blindnessPrice ∧
    Tendsto blindnessPrice atTop atTop :=
  ⟨shorProfile_exponent, rhoProfile_exponent, scanProfile_exponent,
    three_strata_strictly_ordered, blindnessPrice_strictMono, blindnessPrice_tendsto_atTop⟩

end ThreeStrata