import Cryptography.FHE.NoiseGrowth

/-!
# The bootstrapping dichotomy: when is a levelled FHE scheme noise-stable?

Homomorphic multiplication followed by relinearization transforms the
(normalized) noise level `x` by the quadratic map

`noiseStep γ D x = γ · x² + D`,

where `γ ≥ 1` is the ring expansion factor and `D ≥ 0` is the key-switching
noise surcharge.  Everything about unbounded-depth evaluation is governed by the
orbit structure of this one-dimensional quadratic dynamical system, and the
governing quantity is the discriminant `1 - 4γD`.

## Main results

* `noiseStep_dichotomy` — **the dichotomy**: an invariant noise budget exists
  (i.e. `∃ Q ≥ 0, γQ² + D ≤ Q`) **iff** `4γD ≤ 1`.  There is no middle ground.
* `iterD_le_of_invariant` — inside the stable regime the noise never leaves the
  invariant interval, at *any* multiplicative depth: no bootstrapping needed.
* `noiseFixedPoint_spec` — the explicit stable budget
  `Q = (1 - √(1 - 4γD)) / (2γ)`, an exact fixed point, with `Q ≤ 1/(2γ)`.
* `iterD_ge_linear` and `exists_depth_exceeding` — **bootstrapping necessity**:
  when `4γD > 1` the noise grows at least linearly with slope
  `c = D - 1/(4γ) > 0`, so *every* decryption radius is exceeded after finitely
  many levels, and an explicit depth bound is given.
* `sqChain_noise_eq_iterD` — sharpness: over `ℤ` the recursion is *attained*, so
  the dichotomy is not an artefact of lossy bounding.
* `unbounded_depth_correct` / `bootstrap_needed_at_depth` — the two sides of the
  dichotomy transported back to statements about decrypting circuits.
-/

namespace FHENoise

open Polynomial

noncomputable section

/-! ## 1. The quadratic noise map and its orbits -/

/-- One multiplication level: square (paying the expansion factor `γ`), then pay
the relinearization surcharge `D`. -/
def noiseStep (gamma D x : ℝ) : ℝ := gamma * x ^ 2 + D

/-- The noise level after `d` multiplication levels. -/
def iterD (gamma D : ℝ) : ℕ → ℝ → ℝ
  | 0, x => x
  | (d + 1), x => noiseStep gamma D (iterD gamma D d x)

@[simp] lemma iterD_zero (gamma D x : ℝ) : iterD gamma D 0 x = x := rfl

@[simp] lemma iterD_succ (gamma D x : ℝ) (d : ℕ) :
    iterD gamma D (d + 1) x = noiseStep gamma D (iterD gamma D d x) := rfl

lemma iterD_nonneg {gamma D x : ℝ} (hg : 0 ≤ gamma) (hD : 0 ≤ D) (hx : 0 ≤ x) :
    ∀ d, 0 ≤ iterD gamma D d x
  | 0 => hx
  | (d + 1) => by
      have := iterD_nonneg hg hD hx d
      simp only [iterD_succ, noiseStep]
      positivity

/-- With `D = 0` this is the pure squaring iteration of `NoiseGrowth`. -/
lemma iterD_zero_relin (gamma x : ℝ) : ∀ d, iterD gamma 0 d x = iterNoise gamma d x
  | 0 => rfl
  | (d + 1) => by simp [iterD, noiseStep, iterNoise, iterD_zero_relin gamma x d]

/-! ## 2. The stable regime -/

/-- An **invariant noise budget**: a level that the multiplication step cannot
exceed. -/
def InvariantBudget (gamma D Q : ℝ) : Prop := 0 ≤ Q ∧ noiseStep gamma D Q ≤ Q

/-- Inside an invariant budget the noise stays bounded at every depth: the
scheme evaluates arbitrarily deep circuits *without bootstrapping*. -/
theorem iterD_le_of_invariant {gamma D Q x : ℝ} (hg : 0 ≤ gamma) (hD : 0 ≤ D)
    (hQ : InvariantBudget gamma D Q) (hx0 : 0 ≤ x) (hx : x ≤ Q) :
    ∀ d, iterD gamma D d x ≤ Q
  | 0 => hx
  | (d + 1) => by
      have ih := iterD_le_of_invariant hg hD hQ hx0 hx d
      have hpos := iterD_nonneg hg hD hx0 d
      have hstep : gamma * (iterD gamma D d x) ^ 2 ≤ gamma * Q ^ 2 := by
        have hsq := mul_self_le_mul_self hpos ih
        nlinarith [hsq, hg]
      have := hQ.2
      simp only [iterD_succ, noiseStep] at *
      linarith

/-- The canonical stable budget, the smaller root of `γx² - x + D = 0`. -/
def noiseFixedPoint (gamma D : ℝ) : ℝ := (1 - Real.sqrt (1 - 4 * gamma * D)) / (2 * gamma)

/-- **Existence of the stable budget.**  When the discriminant `1 - 4γD` is
nonnegative, `noiseFixedPoint γ D` is an exact fixed point of the noise step, it
is nonnegative, and it never exceeds `1/(2γ)`. -/
theorem noiseFixedPoint_spec {gamma D : ℝ} (hg : 0 < gamma) (hD : 0 ≤ D)
    (hdisc : 4 * gamma * D ≤ 1) :
    noiseStep gamma D (noiseFixedPoint gamma D) = noiseFixedPoint gamma D ∧
      0 ≤ noiseFixedPoint gamma D ∧ noiseFixedPoint gamma D ≤ 1 / (2 * gamma) := by
  set r := Real.sqrt (1 - 4 * gamma * D) with hr
  have hnn : 0 ≤ 1 - 4 * gamma * D := by linarith
  have hr2 : r ^ 2 = 1 - 4 * gamma * D := Real.sq_sqrt hnn
  have hr0 : 0 ≤ r := Real.sqrt_nonneg _
  have hr1 : r ≤ 1 := by
    nlinarith [hr2, hr0, mul_nonneg (le_of_lt hg) hD]
  have h2g : 0 < 2 * gamma := by linarith
  refine ⟨?_, ?_, ?_⟩
  · have hfix : noiseStep gamma D ((1 - r) / (2 * gamma)) = (1 - r) / (2 * gamma) := by
      rw [noiseStep]
      field_simp
      nlinarith [hr2]
    simpa only [noiseFixedPoint, ← hr] using hfix
  · simp only [noiseFixedPoint, ← hr]
    apply div_nonneg (by linarith) (le_of_lt h2g)
  · simp only [noiseFixedPoint, ← hr]
    rw [div_le_div_iff_of_pos_right h2g]
    linarith

/-! ## 3. The unstable regime -/

/-- Beyond the discriminant threshold every multiplication level adds at least
the fixed amount `c = D - 1/(4γ) > 0`: the quadratic map has no fixed point and
therefore uniformly pushes noise upwards. -/
theorem noiseStep_ge_add {gamma D : ℝ} (hg : 0 < gamma) (x : ℝ) :
    x + (D - 1 / (4 * gamma)) ≤ noiseStep gamma D x := by
  have hkey : gamma * (x - 1 / (2 * gamma)) ^ 2 ≥ 0 := by positivity
  have hexpand : gamma * (x - 1 / (2 * gamma)) ^ 2
      = gamma * x ^ 2 - x + 1 / (4 * gamma) := by
    field_simp
    ring
  simp only [noiseStep]
  linarith [hexpand ▸ hkey]

/-- Linear divergence of the noise in the unstable regime. -/
theorem iterD_ge_linear {gamma D x : ℝ} (hg : 0 < gamma) :
    ∀ d : ℕ, x + d * (D - 1 / (4 * gamma)) ≤ iterD gamma D d x
  | 0 => by simp
  | (d + 1) => by
      have ih := iterD_ge_linear (gamma := gamma) (D := D) (x := x) hg d
      have hstep := noiseStep_ge_add (D := D) hg (iterD gamma D d x)
      have : ((d : ℝ) + 1) * (D - 1 / (4 * gamma))
          = (d : ℝ) * (D - 1 / (4 * gamma)) + (D - 1 / (4 * gamma)) := by ring
      simp only [iterD_succ, Nat.cast_succ, this]
      linarith

/-- **Bootstrapping is necessary.**  If `4γD > 1` then for every decryption
radius `T` there is a multiplicative depth at which the noise provably exceeds
`T`; no parameter choice postpones it forever. -/
theorem exists_depth_exceeding {gamma D x : ℝ} (hg : 0 < gamma)
    (hunstable : 1 < 4 * gamma * D) (T : ℝ) :
    ∃ d : ℕ, T < iterD gamma D d x := by
  have hc : 0 < D - 1 / (4 * gamma) := by
    have h4 : 0 < 4 * gamma := by linarith
    rw [sub_pos, div_lt_iff₀ h4]
    linarith
  obtain ⟨d, hd⟩ := exists_nat_gt ((T - x) / (D - 1 / (4 * gamma)))
  refine ⟨d, lt_of_lt_of_le ?_ (iterD_ge_linear (gamma := gamma) (D := D) (x := x) hg d)⟩
  have := (div_lt_iff₀ hc).mp hd
  linarith

/-- **The bootstrapping dichotomy.**  An invariant noise budget exists if and
only if the discriminant condition `4γD ≤ 1` holds.  Equivalently: a levelled
BGV/BFV scheme is unbounded-depth stable exactly when the relinearization
surcharge satisfies `D ≤ 1/(4γ)`; otherwise bootstrapping is unavoidable. -/
theorem noiseStep_dichotomy {gamma D : ℝ} (hg : 0 < gamma) (hD : 0 ≤ D) :
    (∃ Q, InvariantBudget gamma D Q) ↔ 4 * gamma * D ≤ 1 := by
  constructor
  · rintro ⟨Q, -, hQ⟩
    simp only [noiseStep] at hQ
    nlinarith [sq_nonneg (2 * gamma * Q - 1)]
  · intro hdisc
    obtain ⟨hfix, hnn, -⟩ := noiseFixedPoint_spec hg hD hdisc
    exact ⟨noiseFixedPoint gamma D, hnn, le_of_eq hfix⟩

/-! ## 3b. Convergence of the stable orbit -/

/-- Below an exact fixed point the noise map is increasing: the orbit climbs
towards the budget instead of oscillating. -/
lemma le_noiseStep_of_le_fixedPoint {gamma D Q y : ℝ} (hg : 0 < gamma)
    (hQfix : noiseStep gamma D Q = Q) (hQle : Q ≤ 1 / (2 * gamma))
    (hy : y ≤ Q) : y ≤ noiseStep gamma D y := by
  have h2g : 0 < 2 * gamma := by linarith
  have hQ2 : 2 * gamma * Q ≤ 1 := by
    rw [le_div_iff₀ h2g] at hQle
    linarith
  have hD : D = Q - gamma * Q ^ 2 := by
    rw [noiseStep] at hQfix; linarith
  have hfac : gamma * y ^ 2 + D - y = (Q - y) * (1 - gamma * (y + Q)) := by
    rw [hD]; ring
  have hpos : 0 ≤ (Q - y) * (1 - gamma * (y + Q)) := by
    apply mul_nonneg (by linarith)
    nlinarith
  simp only [noiseStep]
  linarith

/-- **The stable orbit converges to the fixed point.**  In the stable regime,
starting anywhere in `[0, Q]`, the noise increases monotonically and converges
exactly to the invariant budget `Q`; the budget is thus the asymptotic noise
level of a levelled scheme, attained in the limit of infinite depth. -/
theorem tendsto_iterD_fixedPoint {gamma D Q x : ℝ} (hg : 0 < gamma) (hD : 0 ≤ D)
    (hQfix : noiseStep gamma D Q = Q) (hQ0 : 0 ≤ Q) (hQle : Q ≤ 1 / (2 * gamma))
    (hx0 : 0 ≤ x) (hx : x ≤ Q) :
    Filter.Tendsto (fun d => iterD gamma D d x) Filter.atTop (nhds Q) := by
  have hg0 : (0:ℝ) ≤ gamma := le_of_lt hg
  have hinv : InvariantBudget gamma D Q := ⟨hQ0, le_of_eq hQfix⟩
  have hle : ∀ d, iterD gamma D d x ≤ Q := iterD_le_of_invariant hg0 hD hinv hx0 hx
  have hnn : ∀ d, 0 ≤ iterD gamma D d x := iterD_nonneg hg0 hD hx0
  have hmono : Monotone fun d => iterD gamma D d x := by
    refine monotone_nat_of_le_succ fun d => ?_
    simpa [iterD_succ] using
      le_noiseStep_of_le_fixedPoint hg hQfix hQle (hle d)
  have hbdd : BddAbove (Set.range fun d => iterD gamma D d x) :=
    ⟨Q, by rintro y ⟨d, rfl⟩; exact hle d⟩
  set L := ⨆ d, iterD gamma D d x with hL
  have htend : Filter.Tendsto (fun d => iterD gamma D d x) Filter.atTop (nhds L) :=
    tendsto_atTop_ciSup hmono hbdd
  have hcont : Continuous (noiseStep gamma D) := by
    unfold noiseStep; fun_prop
  have hshift : Filter.Tendsto (fun d => iterD gamma D (d + 1) x) Filter.atTop (nhds L) :=
    htend.comp (Filter.tendsto_add_atTop_nat 1)
  have hstep : Filter.Tendsto (fun d => iterD gamma D (d + 1) x) Filter.atTop
      (nhds (noiseStep gamma D L)) := by
    simpa [iterD_succ] using (hcont.tendsto L).comp htend
  have hfixL : noiseStep gamma D L = L := tendsto_nhds_unique hstep hshift
  have hLQ : L ≤ Q := ciSup_le hle
  have hL0 : 0 ≤ L := le_trans (hnn 0) (le_ciSup hbdd 0)
  have h2g : 0 < 2 * gamma := by linarith
  have hQ2 : 2 * gamma * Q ≤ 1 := by
    rw [le_div_iff₀ h2g] at hQle
    linarith
  have hfac : (L - Q) * (gamma * (L + Q) - 1) = 0 := by
    have h1 : gamma * L ^ 2 + D = L := hfixL
    have h2 : gamma * Q ^ 2 + D = Q := hQfix
    nlinarith [h1, h2]
  rcases mul_eq_zero.mp hfac with h | h
  · have : L = Q := by linarith
    rwa [this] at htend
  · have : L = Q := by nlinarith
    rwa [this] at htend

/-! ## 4. Sharpness: the recursion is attained over `ℤ` -/

namespace NoiseCkt

/-- The syntactic noise bound of the depth-`d` squaring circuit is *exactly* the
`d`-fold noise iteration. -/
theorem noiseBound_sqChain (gamma D B : ℝ) :
    ∀ d, (sqChain d).noiseBound gamma D (fun _ => B) = iterD gamma D d B
  | 0 => rfl
  | (d + 1) => by
      rw [sqChain, noiseBound, noiseBound_sqChain gamma D B d, iterD_succ, noiseStep]
      ring

/-- **Sharpness.**  Over `ℤ` (expansion factor `γ = 1`), with a relinearization
that adds exactly `k ≥ 0` to the phase and an input of phase `b ≥ 0`, the noise
of the depth-`d` squaring circuit equals the iterate `iterD 1 k d b` exactly.
Hence the master bound of `NoiseGrowth`, and with it the dichotomy above, is
tight and not an artefact of the estimates. -/
theorem sqChain_noise_eq_iterD (s b k : ℤ) (hb : 0 ≤ b) (hk : 0 ≤ k) :
    ∀ d, noise intGauge s
        ((sqChain d).evalEnc (fun c => c + Polynomial.C k) (fun _ => Polynomial.C b))
      = iterD 1 (k : ℝ) d (b : ℝ) := by
  have key : ∀ d, ∃ v : ℤ, 0 ≤ v ∧
      phase s ((sqChain d).evalEnc (fun c => c + Polynomial.C k)
        (fun _ => Polynomial.C b)) = v ∧ (v : ℝ) = iterD 1 (k : ℝ) d (b : ℝ) := by
    intro d
    induction d with
    | zero => exact ⟨b, hb, by simp [sqChain, evalEnc, phase], by simp⟩
    | succ d ih =>
        obtain ⟨v, hv0, hv, hvr⟩ := ih
        refine ⟨v * v + k, by positivity, ?_, ?_⟩
        · simp only [sqChain, evalEnc, phase_add, phase_mul, phase_C, hv]
        · push_cast
          rw [hvr]
          simp only [iterD_succ, noiseStep, sq]
          ring
  intro d
  obtain ⟨v, hv0, hv, hvr⟩ := key d
  have : (0:ℝ) ≤ (v : ℝ) := by exact_mod_cast hv0
  simp only [noise, hv, intGauge_nu]
  rw [abs_of_nonneg this, hvr]

end NoiseCkt

/-! ## 5. Consequences for homomorphic evaluation -/

variable {R : Type*} [CommRing R]

/-- **Unbounded-depth correctness in the stable regime.**  If the leaf noise is
below an invariant budget `Q` and the decoding radius exceeds `Q`, then squaring
circuits of *every* multiplicative depth decrypt correctly — bootstrapping is
never invoked. -/
theorem unbounded_depth_correct {M : Type*} [CommRing M] {D T B Q : ℝ}
    (G : NoiseGauge R) (s : R) (pi : R →+* M) (dec : R → M)
    (hdec : ∀ x, G.nu x < T → dec x = pi x)
    (relin : Cipher R → Cipher R)
    (hrelinN : ∀ c, G.nu (phase s (relin c) - phase s c) ≤ D) (hD : 0 ≤ D)
    (hrelinP : ∀ c, pi (phase s (relin c)) = pi (phase s c))
    (rho : ℕ → Cipher R) (hleaf : ∀ i, noise G s (rho i) ≤ B) (hB : 0 ≤ B)
    (hQ : InvariantBudget G.gamma D Q) (hBQ : B ≤ Q) (hT : Q < T) (d : ℕ) :
    dec (phase s ((NoiseCkt.sqChain d).evalEnc relin rho))
      = (NoiseCkt.sqChain d).evalPlain (fun i => pi (phase s (rho i))) := by
  have hbudget : (NoiseCkt.sqChain d).noiseBound G.gamma D (fun _ => B) < T := by
    rw [NoiseCkt.noiseBound_sqChain]
    exact lt_of_le_of_lt
      (iterD_le_of_invariant G.gamma_nonneg hD hQ hB hBQ d) hT
  exact NoiseCkt.decrypt_evalEnc G s pi dec hdec relin hrelinN hrelinP rho
    (fun _ => B) hleaf _ hbudget

/-- **Bootstrapping necessity, transported to circuits.**  Over `ℤ` with an
exactly-`k` relinearization in the unstable regime `4k > 1`, the noise of the
squaring circuit exceeds any decoding radius `T` at some finite depth: a refresh
operation must be inserted. -/
theorem bootstrap_needed_at_depth (s b k : ℤ) (hb : 0 ≤ b) (hk : 0 ≤ k)
    (hunstable : 1 < 4 * (k : ℝ)) (T : ℝ) :
    ∃ d : ℕ, T < noise intGauge s
      ((NoiseCkt.sqChain d).evalEnc (fun c => c + Polynomial.C k)
        (fun _ => Polynomial.C b)) := by
  obtain ⟨d, hd⟩ := exists_depth_exceeding (gamma := 1) (D := (k : ℝ)) (x := (b : ℝ))
    one_pos (by linarith) T
  exact ⟨d, by rw [NoiseCkt.sqChain_noise_eq_iterD s b k hb hk d]; exact hd⟩

end

end FHENoise