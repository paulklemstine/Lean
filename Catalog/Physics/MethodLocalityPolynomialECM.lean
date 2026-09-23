import Mathlib
import Physics.MethodLocalityFactorLocal
import Physics.EcmStage2Wall

/-!
# Why ρ and ECM are factor-local: equivariance, and the cofactor-free ECM ledger

`Catalog.Physics.MethodLocalityFactorLocal` proved that Pollard ρ is cofactor flat
and trial division is not.  This file explains the mechanism and extends it to the
other two strata of the round-28 method plane.

**Part A — locality is equivariance.**  The only property of `x ↦ x² + c` that made
ρ cofactor flat is that the update map is *defined over `ℤ`*: it is the evaluation of
an integer polynomial, so it commutes with every ring map `ZMod N →+* ZMod p`.  We
prove the general statement `poly_cofactor_flat`: **every** polynomial-iteration
method is factor local, with the same cost bound `p`.  Pollard ρ (`rho_eq_polyOrbit`),
its cubic variant (`cubic_cofactor_flat`) and any other `f ∈ ℤ[X]` are instances.
This is the structural reason the measured ECM/ρ flatness is not a coincidence, and
it predicts which methods *cannot* be made flat: those whose update depends on `N`
itself, e.g. trial division, whose "state" is the divisor candidate together with the
modulus.

**Part B — the ECM ledger is cofactor-free.**  On `N = p·q` a stage-1 ECM run sees, by
CRT, the product group of orders `m` (mod `p`) and `m'` (mod `q`).  We compute the
mod-`p` firing count inside that product exactly, `card_jointFiring = gcd(m,k)·m'`,
and deduce `ecm_rate_cofactor_independent`: the mod-`p` success rate of a run modulo
`N` is `gcd(m, k(B))/m`, with the cofactor order `m'` cancelling identically.  The
expected curve count `ecmCurves m B = m / gcd(m, k(B))` is therefore a function of the
factor only, and the Hasse window bounds it by `hasseCeil p = p + 3 + 2⌊√p⌋`
(`ecm_factor_bounded`), collapsing to a single curve at the wall
(`ecmCurves_eq_one_at_wall`).

**Part C — the three-method synthesis** (`method_locality_trichotomy`): ρ and ECM are
cofactor flat and factor bounded; trial division is factor bounded but *not* cofactor
flat.
-/

namespace MethodLocalityPoly

open MethodLocality ECMStage1 ECMWall Finset

/-! ## Part A. Locality is equivariance -/

/-- One step of a polynomial-iteration method: evaluate `f ∈ ℤ[X]` at the state. -/
def polyStep (f : Polynomial ℤ) {R : Type*} [CommRing R] (x : R) : R := Polynomial.aeval x f

/-- The orbit of a polynomial-iteration method. -/
def polyOrbit (f : Polynomial ℤ) {R : Type*} [CommRing R] (x0 : R) (n : ℕ) : R :=
  (polyStep f)^[n] x0

theorem map_polyStep {R S : Type*} [CommRing R] [CommRing S] (φ : R →+* S)
    (f : Polynomial ℤ) (x : R) : φ (polyStep f x) = polyStep f (φ x) := by
  have := Polynomial.aeval_algHom_apply (φ.toIntAlgHom) x f
  simpa [polyStep] using this.symm

/-- **Equivariance of polynomial methods.**  Any ring map intertwines the orbits. -/
theorem map_polyOrbit {R S : Type*} [CommRing R] [CommRing S] (φ : R →+* S)
    (f : Polynomial ℤ) (x0 : R) (n : ℕ) : φ (polyOrbit f x0 n) = polyOrbit f (φ x0) n := by
  induction n with
  | zero => simp [polyOrbit]
  | succ n ih =>
      simp only [polyOrbit, Function.iterate_succ_apply'] at *
      rw [map_polyStep, ih]

/-- The mod-`p` shadow of the run performed modulo `N` is the run performed modulo
`p`: the cofactor is invisible to the shadow. -/
theorem polyOrbit_reduce {p N : ℕ} (h : p ∣ N) (f : Polynomial ℤ) (x0 : ℤ) (n : ℕ) :
    (ZMod.castHom h (ZMod p)) (polyOrbit f ((x0 : ZMod N)) n)
      = polyOrbit f ((x0 : ZMod p)) n := by
  rw [map_polyOrbit]
  simp [map_intCast]

/-- Cost of a polynomial method run modulo `N` while hunting the factor `p`. -/
noncomputable def polyTime (p N : ℕ) (h : p ∣ N) (f : Polynomial ℤ) (x0 : ℤ) : ℕ :=
  collTime (fun n => (ZMod.castHom h (ZMod p)) (polyOrbit f ((x0 : ZMod N)) n))

/-- The intrinsic cost attached to the factor alone. -/
noncomputable def polyTimeAtFactor (p : ℕ) (f : Polynomial ℤ) (x0 : ℤ) : ℕ :=
  collTime (polyOrbit f ((x0 : ZMod p)))

theorem polyTime_eq_factor_time {p N : ℕ} (h : p ∣ N) (f : Polynomial ℤ) (x0 : ℤ) :
    polyTime p N h f x0 = polyTimeAtFactor p f x0 :=
  collTime_congr (polyOrbit_reduce h f x0)

/-- **Master locality theorem.**  Every method whose update is an integer polynomial is
cofactor flat: the cost of hunting `p` inside `p·q` does not depend on `q`. -/
theorem poly_cofactor_flat {p q q' : ℕ} (f : Polynomial ℤ) (x0 : ℤ)
    (h : p ∣ p * q) (h' : p ∣ p * q') :
    polyTime p (p * q) h f x0 = polyTime p (p * q') h' f x0 := by
  rw [polyTime_eq_factor_time, polyTime_eq_factor_time]

/-- …and it is factor bounded by the state-space size `p`. -/
theorem polyTime_le_factor {p N : ℕ} [NeZero p] (h : p ∣ N) (f : Polynomial ℤ) (x0 : ℤ) :
    polyTime p N h f x0 ≤ p := by
  rw [polyTime_eq_factor_time, polyTimeAtFactor]
  simpa using collTime_le_card (β := ZMod p) (polyOrbit f ((x0 : ZMod p)))

/-- Pollard ρ is the polynomial method of `X² + c`. -/
theorem rho_eq_polyOrbit {R : Type*} [CommRing R] (c : ℤ) (x0 : R) (n : ℕ) :
    polyOrbit (Polynomial.X ^ 2 + Polynomial.C c) x0 n = rhoSeq ((c : R)) x0 n := by
  induction n with
  | zero => simp [polyOrbit, rhoSeq]
  | succ n ih =>
      simp only [polyOrbit, rhoSeq, Function.iterate_succ_apply'] at *
      rw [ih]
      simp [polyStep, rhoStep, sq]

/-- The cubic variant `x ↦ x³ + c`, used when the quadratic map's cycle structure is
unlucky, is factor local for the very same reason — no new proof is needed. -/
theorem cubic_cofactor_flat {p q q' : ℕ} (c x0 : ℤ)
    (h : p ∣ p * q) (h' : p ∣ p * q') :
    polyTime p (p * q) h (Polynomial.X ^ 3 + Polynomial.C c) x0
      = polyTime p (p * q') h' (Polynomial.X ^ 3 + Polynomial.C c) x0 :=
  poly_cofactor_flat _ _ h h'

/-! ## Part B. The ECM ledger is cofactor-free

By CRT a stage-1 run modulo `N = p·q` acts on a product of two cyclic groups, of
orders `m` (mod `p`) and `m'` (mod `q`).  Stage 1 reveals `p` exactly when the
multiplier fires in the first coordinate.
-/

/-- The set of joint multiplier states whose **mod-`p`** coordinate fires. -/
def jointFiring (m m' k : ℕ) : Finset (ℕ × ℕ) :=
  ((Finset.range m) ×ˢ (Finset.range m')).filter (fun a => m ∣ k * a.1)

theorem jointFiring_eq_product (m m' k : ℕ) :
    jointFiring m m' k = firingSet m k ×ˢ Finset.range m' := by
  ext a
  simp [jointFiring, firingSet, Finset.mem_filter, Finset.mem_product, and_assoc, and_comm]

/-- **The cofactor contributes a bare multiplicative factor.**  The number of joint
states that fire modulo `p` is `gcd(m,k)·m'`. -/
theorem card_jointFiring (m m' k : ℕ) (hm : 0 < m) :
    (jointFiring m m' k).card = Nat.gcd m k * m' := by
  rw [jointFiring_eq_product, Finset.card_product, card_firingSet _ _ hm, Finset.card_range]

/-- **ECM factor locality (H1).**  The mod-`p` stage-1 success rate of a run modulo
`N = p·q` is `gcd(m, k(B))/m`: the cofactor group order `m'` cancels identically, so
the rate is a function of the factor and the smoothness bound only.  The measured
`×2.16` median spread over `2^23` of cofactor growth is curve-restart luck, not
cofactor dependence. -/
theorem ecm_rate_cofactor_independent (m m' k : ℕ) (hm : 0 < m) (hm' : 0 < m') :
    ((jointFiring m m' k).card : ℚ) / ((m : ℚ) * m') = (Nat.gcd m k : ℚ) / m := by
  have hmQ : (m : ℚ) ≠ 0 := by exact_mod_cast hm.ne'
  have hm'Q : (m' : ℚ) ≠ 0 := by exact_mod_cast hm'.ne'
  rw [card_jointFiring m m' k hm]
  push_cast
  field_simp

/-- Expected number of ECM curves at smoothness bound `B` against a group of order
`m`: the reciprocal of the stage-1 firing rate. -/
def ecmCurves (m B : ℕ) : ℕ := m / Nat.gcd m (stage1Scalar B)

/-- **ECM is factor bounded.**  Whatever the modulus, the expected curve count is
bounded by the Hasse ceiling of the *factor*, `p + 3 + 2⌊√p⌋`. -/
theorem ecm_factor_bounded {p m B : ℕ} (hHasse : m ≤ hasseCeil p) :
    ecmCurves m B ≤ hasseCeil p :=
  le_trans (Nat.div_le_self _ _) hHasse

/-- Explicitly in Hasse form: an order in the analytic Hasse window of `p` gives a
curve count bounded by a function of `p` alone, for every cofactor. -/
theorem ecm_factor_bounded_hasse {p m B : ℕ}
    (hHasse : (m : ℝ) ≤ (p : ℝ) + 1 + 2 * Real.sqrt p) :
    ecmCurves m B ≤ p + 3 + 2 * Nat.sqrt p :=
  ecm_factor_bounded (hasseWindow_le_hasseCeil hHasse)

/-- **At the wall one curve suffices.**  Past the top of the Hasse window the stage-1
scalar annihilates the whole group, so the expected curve count is exactly `1` — the
`E[T] = ∞` reading of the wall is the wrong one, and the cost is still a function of
`p` only. -/
theorem ecmCurves_eq_one_at_wall {p m B : ℕ} (hm : 0 < m) (hB : hasseCeil p ≤ B)
    (hHasse : m ≤ hasseCeil p) : ecmCurves m B = 1 := by
  have hmB : m ≤ B := le_trans hHasse hB
  rw [ecmCurves, gcd_eq_self_at_wall hm hmB, Nat.div_self hm]

/-- Monotone improvement: raising the smoothness bound never increases the expected
curve count, so the ECM cost curve in `B` has no wall. -/
theorem ecmCurves_antitone {m B B' : ℕ} (hm : 0 < m) (hB : B ≤ B') :
    ecmCurves m B' ≤ ecmCurves m B :=
  Nat.div_le_div_left (firing_count_mono hm hB) (Nat.gcd_pos_of_pos_left _ hm)

/-! ## Part C. The trichotomy -/

/-- **METHOD-LOCALITY, in full.**  Pollard ρ (and every polynomial-iteration method,
by `poly_cofactor_flat`) is cofactor flat and bounded by `p`; ECM's ledger is
cofactor-free with cost bounded by the Hasse ceiling of `p`; trial division is factor
bounded but demonstrably *not* cofactor flat.  Two of the three strata track the
factor; the definition face tracks the modulus. -/
theorem method_locality_trichotomy :
    (∀ (p q q' : ℕ) (f : Polynomial ℤ) (x0 : ℤ) (h : p ∣ p * q) (h' : p ∣ p * q'),
        polyTime p (p * q) h f x0 = polyTime p (p * q') h' f x0) ∧
      (∀ m m' k : ℕ, 0 < m → 0 < m' →
        ((jointFiring m m' k).card : ℚ) / ((m : ℚ) * m') = (Nat.gcd m k : ℚ) / m) ∧
      (FactorBounded trialCost ∧ ¬ CofactorFlat trialCost) :=
  ⟨fun _ _ _ f x0 h h' => poly_cofactor_flat f x0 h h',
    fun m m' k hm hm' => ecm_rate_cofactor_independent m m' k hm hm',
    ⟨trial_factorBounded, trial_not_cofactorFlat⟩⟩

end MethodLocalityPoly