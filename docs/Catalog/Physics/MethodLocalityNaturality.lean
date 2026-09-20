import Mathlib
import Physics.MethodLocalityFactorLocal
import Physics.MethodLocalityPolynomialECM

/-!
# Cycle 2: naturality is the mechanism, and the boundary of factor locality

Cycle 1 (`MethodLocalityFactorLocal`, `MethodLocalityPolynomialECM`) proved that
polynomial-iteration methods are cofactor flat and that trial division is not.  The
proof of the polynomial case used only one property of `x ↦ x² + c`: it commutes with
every ring map.  This file isolates that property as a definition and proves the
locality theorem once and for all, then uses it to place a *third* method — the
`p - 1` method, whose update `x ↦ x^k` is not a fixed polynomial iteration — on the
same plane, and finally maps the boundary of the phenomenon.

* `UniformStep`, `uniform_cofactor_flat`, `uniformTime_le_factor` — a *uniform step*
  is a family of state maps, one per commutative ring, commuting with all ring maps.
  Every uniform step is cofactor flat with cost at most `p`.  The round-28 flatness is
  therefore a corollary of naturality, not an empirical accident.
* `polyUniform`, `powUniform` — the ρ family (`X² + c`, and any `f ∈ ℤ[X]`) and the
  `p - 1` family (`x ↦ x^k`) are uniform, so both are factor local; `pow_cofactor_flat`
  states the `p - 1` case explicitly.
* `pMinusOne_fires_le`, `pMinusOneBound_le` — the `p - 1` method's smoothness budget is
  bounded by `p - 1`, again a function of the factor alone.
* `collTime_map_le`, `shadow_le_modulus_time` — *the modulus run is never faster than
  its shadows*: the cost of a search modulo `N` is at least the cost modulo any factor.
  Locality is thus a lower-bound phenomenon as well: nothing is lost by projecting.
* `rho_fails_of_simultaneous`, `reveal_dichotomy` — the boundary.  A mod-`p` collision
  yields a proper factor *unless* the same pair of states also collides modulo the
  cofactor, in which case the gcd is `N` and the run is wasted.  This is the exact
  failure mode that the medians of the experiment average over.
* `locality_is_naturality` — the cycle-2 synthesis.
-/

namespace MethodLocalityNat

open MethodLocality MethodLocalityPoly ECMStage1 ECMWall

/-! ## 1. Uniform steps: naturality as a definition -/

/-- A **uniform step** is a state update defined simultaneously for all commutative
rings and commuting with every ring map: the algebraic form of "the method does not
look at the modulus". -/
structure UniformStep where
  /-- the state update on each commutative ring -/
  step : ∀ (R : Type) [CommRing R], R → R
  /-- naturality: ring maps intertwine the updates -/
  natural : ∀ {R S : Type} [CommRing R] [CommRing S] (φ : R →+* S) (x : R),
    φ (step R x) = step S (φ x)

/-- The orbit of a uniform step. -/
def UniformStep.orbit (M : UniformStep) (R : Type) [CommRing R] (x0 : R) (n : ℕ) : R :=
  (M.step R)^[n] x0

theorem UniformStep.map_orbit (M : UniformStep) {R S : Type} [CommRing R] [CommRing S]
    (φ : R →+* S) (x0 : R) (n : ℕ) : φ (M.orbit R x0 n) = M.orbit S (φ x0) n := by
  induction n with
  | zero => simp [UniformStep.orbit]
  | succ n ih =>
      simp only [UniformStep.orbit, Function.iterate_succ_apply'] at *
      rw [M.natural, ih]

/-- The mod-`p` shadow of a uniform run modulo `N` is the uniform run modulo `p`. -/
theorem UniformStep.orbit_reduce (M : UniformStep) {p N : ℕ} (h : p ∣ N) (x0 : ℤ) (n : ℕ) :
    (ZMod.castHom h (ZMod p)) (M.orbit (ZMod N) ((x0 : ZMod N)) n)
      = M.orbit (ZMod p) ((x0 : ZMod p)) n := by
  rw [M.map_orbit]
  simp [map_intCast]

/-- Cost of a uniform method run modulo `N` while hunting the factor `p`. -/
noncomputable def uniformTime (M : UniformStep) (p N : ℕ) (h : p ∣ N) (x0 : ℤ) : ℕ :=
  collTime (fun n => (ZMod.castHom h (ZMod p)) (M.orbit (ZMod N) ((x0 : ZMod N)) n))

/-- The intrinsic cost attached to the factor. -/
noncomputable def uniformTimeAtFactor (M : UniformStep) (p : ℕ) (x0 : ℤ) : ℕ :=
  collTime (M.orbit (ZMod p) ((x0 : ZMod p)))

theorem uniformTime_eq_factor_time (M : UniformStep) {p N : ℕ} (h : p ∣ N) (x0 : ℤ) :
    uniformTime M p N h x0 = uniformTimeAtFactor M p x0 :=
  collTime_congr (M.orbit_reduce h x0)

/-- **Naturality ⇒ factor locality.**  Every uniform method is cofactor flat. -/
theorem uniform_cofactor_flat (M : UniformStep) {p q q' : ℕ} (x0 : ℤ)
    (h : p ∣ p * q) (h' : p ∣ p * q') :
    uniformTime M p (p * q) h x0 = uniformTime M p (p * q') h' x0 := by
  rw [uniformTime_eq_factor_time, uniformTime_eq_factor_time]

/-- …and bounded by the size of the factor's state space. -/
theorem uniformTime_le_factor (M : UniformStep) {p N : ℕ} [NeZero p] (h : p ∣ N) (x0 : ℤ) :
    uniformTime M p N h x0 ≤ p := by
  rw [uniformTime_eq_factor_time, uniformTimeAtFactor]
  simpa using collTime_le_card (β := ZMod p) (M.orbit (ZMod p) ((x0 : ZMod p)))

/-! ## 2. The three uniform families -/

/-- The polynomial family: Pollard ρ and all its polynomial variants. -/
def polyUniform (f : Polynomial ℤ) : UniformStep where
  step _ _ x := polyStep f x
  natural φ x := map_polyStep φ f x

/-- The `p - 1` family: the exponentiation step `x ↦ x ^ k`. -/
def powUniform (k : ℕ) : UniformStep where
  step _ _ x := x ^ k
  natural φ x := map_pow φ x k

/-- Pollard ρ, as a uniform method, agrees with the ρ orbit of cycle 1. -/
theorem polyUniform_rho (c : ℤ) {R : Type} [CommRing R] (x0 : R) (n : ℕ) :
    (polyUniform (Polynomial.X ^ 2 + Polynomial.C c)).orbit R x0 n = rhoSeq ((c : R)) x0 n :=
  rho_eq_polyOrbit c x0 n

/-- **The `p - 1` method is factor local.**  Its repeated-exponentiation step is
uniform, so its cost on `p·q` is independent of the cofactor `q`. -/
theorem pow_cofactor_flat (k : ℕ) {p q q' : ℕ} (x0 : ℤ)
    (h : p ∣ p * q) (h' : p ∣ p * q') :
    uniformTime (powUniform k) p (p * q) h x0 = uniformTime (powUniform k) p (p * q') h' x0 :=
  uniform_cofactor_flat _ x0 h h'

/-- Ditto for every polynomial variant, including the cubic map used on restarts. -/
theorem polyUniform_cofactor_flat (f : Polynomial ℤ) {p q q' : ℕ} (x0 : ℤ)
    (h : p ∣ p * q) (h' : p ∣ p * q') :
    uniformTime (polyUniform f) p (p * q) h x0
      = uniformTime (polyUniform f) p (p * q') h' x0 :=
  uniform_cofactor_flat _ x0 h h'

/-! ## 3. The `p - 1` budget is a function of the factor -/

/-- **The `p - 1` method fires by budget `p - 1`.**  The multiplicative group modulo a
prime `p` has order `p - 1`, which divides the stage-1 scalar as soon as the smoothness
budget reaches `p - 1`. -/
theorem pMinusOne_fires_le {p B : ℕ} (hp : 2 ≤ p) (hB : p - 1 ≤ B) :
    (p - 1) ∣ stage1Scalar B :=
  fires_of_le (by omega) hB

/-- The least stage-1 budget that guarantees the `p - 1` method fires is at most
`p - 1`: a factor-bounded cost, with no reference to the modulus. -/
noncomputable def pMinusOneBound (p : ℕ) : ℕ := sInf {B | (p - 1) ∣ stage1Scalar B}

theorem pMinusOneBound_le {p : ℕ} (hp : 2 ≤ p) : pMinusOneBound p ≤ p - 1 :=
  Nat.sInf_le (pMinusOne_fires_le hp le_rfl)

/-- The budget is genuinely attained: at `B = pMinusOneBound p` the group order does
divide the stage-1 scalar. -/
theorem pMinusOneBound_spec {p : ℕ} (hp : 2 ≤ p) :
    (p - 1) ∣ stage1Scalar (pMinusOneBound p) := by
  have hne : {B | (p - 1) ∣ stage1Scalar B}.Nonempty := ⟨p - 1, pMinusOne_fires_le hp le_rfl⟩
  simpa [pMinusOneBound, Set.mem_setOf_eq] using Nat.sInf_mem hne

/-! ## 4. Shadows are never slower than the modulus run -/

/-- Any post-composition can only make a collision happen earlier. -/
theorem collTime_map_le {β γ : Type*} [Finite β] (φ : β → γ) (s : ℕ → β) :
    collTime (fun n => φ (s n)) ≤ collTime s := by
  obtain ⟨i, hi, hEq⟩ := collTime_mem s
  exact collTime_le ⟨i, hi, by simp [hEq]⟩

/-- **Locality as a lower bound.**  The cost of the search performed modulo `N` is at
least the cost of the search modulo any factor `p`: projecting to the factor loses
nothing, which is why factor-local methods are optimal among reduction-equivariant
ones. -/
theorem shadow_le_modulus_time (M : UniformStep) {p N : ℕ} [NeZero N] (h : p ∣ N) (x0 : ℤ) :
    uniformTime M p N h x0 ≤ collTime (M.orbit (ZMod N) ((x0 : ZMod N))) :=
  collTime_map_le _ _

/-! ## 5. The boundary: when the reveal fails -/

/-- **Simultaneous collision is total failure.**  If the two colliding states agree
modulo *both* factors, the gcd is the modulus itself and the run reveals nothing. -/
theorem rho_fails_of_simultaneous {p q a b : ℕ} (hco : Nat.Coprime p q)
    (hp : p ∣ a - b) (hq : q ∣ a - b) :
    (p * q) ∣ a - b ∧ Nat.gcd (a - b) (p * q) = p * q := by
  have hdvd : (p * q) ∣ a - b := Nat.Coprime.mul_dvd_of_dvd_of_dvd hco hp hq
  exact ⟨hdvd, Nat.gcd_eq_right hdvd⟩

/-- **Reveal dichotomy.**  At a mod-`p` collision below the modulus, either the
cofactor also collides — and the gcd is `N`, a wasted run — or the gcd is a proper
nontrivial divisor of `N` that is a multiple of `p`.  Exactly one of the two branches
occurs, and the second is the success recorded by the experiment. -/
theorem reveal_dichotomy {p q a b : ℕ} (hp : 2 ≤ p) (hco : Nat.Coprime p q)
    (hba : b < a) (haN : a < p * q) (hcong : a ≡ b [MOD p]) :
    (q ∣ a - b ∧ Nat.gcd (a - b) (p * q) = p * q) ∨
      (p ∣ Nat.gcd (a - b) (p * q) ∧ Nat.gcd (a - b) (p * q) < p * q ∧
        2 ≤ Nat.gcd (a - b) (p * q)) := by
  by_cases hq : q ∣ a - b
  · exact Or.inl ⟨hq, ((rho_fails_of_simultaneous hco
      ((Nat.modEq_iff_dvd' hba.le).mp hcong.symm) hq).2)⟩
  · obtain ⟨h1, _, h3, h4⟩ :=
      factor_revealed hp (Dvd.intro q rfl) hba haN hcong
    exact Or.inr ⟨h1, h3, h4⟩

/-! ## 6. Cycle-2 synthesis -/

/-- **LOCALITY IS NATURALITY.**  Any method whose step is natural in the ring — ρ and
all its polynomial variants, and the `p - 1` exponentiation step — is cofactor flat and
costs at most `p`; the shadow cost is a lower bound for the modulus-level cost; and
trial division, whose step reads the modulus, is provably not cofactor flat. -/
theorem locality_is_naturality :
    (∀ (M : UniformStep) (p q q' : ℕ) (x0 : ℤ) (h : p ∣ p * q) (h' : p ∣ p * q'),
        uniformTime M p (p * q) h x0 = uniformTime M p (p * q') h' x0) ∧
      (∀ (M : UniformStep) (p N : ℕ) (_ : NeZero p) (h : p ∣ N) (x0 : ℤ),
        uniformTime M p N h x0 ≤ p) ∧
      ¬ CofactorFlat trialCost :=
  ⟨fun M _ _ _ x0 h h' => uniform_cofactor_flat M x0 h h',
    fun M _ _ _ h x0 => uniformTime_le_factor M h x0,
    trial_not_cofactorFlat⟩

end MethodLocalityNat