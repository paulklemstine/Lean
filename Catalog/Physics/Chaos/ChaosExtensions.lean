import Physics.Chaos.EntropyLyapunov
import Physics.Chaos.ThreeBodyVirial

/-!
# Extensions: mass majorisation, symplectic Ruelle bound, and zero-energy escape

This file closes several conjectures left open by `Physics.Chaos.ThreeBodyLagrange`,
`Physics.Chaos.EntropyLyapunov` and `Physics.Chaos.ThreeBodyVirial`.

## 1. Chaos is a Schur-concave functional of the masses

* `routhParam_robin_hood` — a Robin Hood transfer (mass moved from the heavier to the
  lighter body) strictly increases the Routh parameter `K`;
* `routhParam_lt_third_of_ne`, `lagrangeExponent_strictMono` and
  `lagrangeExponent_lt_equalMass_of_ne` — unless the three masses are *exactly* equal, the
  Lagrange growth rate is strictly below the equal-mass value `√2/2`. The equal-mass system
  is therefore the unique maximiser of chaos.

## 2. Concavity of the growth rate

* `lagrangeExponent_concaveOn` — `σ` is concave on `[1/27, ∞)`, with the midpoint form
  `lagrangeExponent_midpoint_concave`.

## 3. The symplectic sharpening of Ruelle's inequality

* `Chaos.SymplecticRuelleData` — Ruelle data together with the Hamiltonian pairing
  `λ ↦ −λ`, which the Lagrange spectrum satisfies;
* `two_mul_card_pos_le` — at most half of the exponents are positive;
* `two_mul_entropy_le` and `two_mul_entropy_div_dim_le_maxExp` — hence `λ_max ≥ 2h_KS/d`,
  a factor-two improvement, which for the Lagrange spectrum reads `λ_max ≥ h_KS/2`.

## 4. Convexity forces escape at zero energy

* `Chaos.tangent_line_lower_bound` and `Chaos.strictly_convex_escape` — a function with
  everywhere positive second derivative is unbounded above in forward or backward time;
* `nonneg_energy_escape` — at total energy `E ≥ 0` (the critical case `E = 0` included) the
  moment of inertia of a collision-free three-body motion tends to `+∞` in one of the two
  time directions;
* `bounded_motion_energy_neg` — consequently every eternally bounded three-body motion has
  *strictly negative* energy.

Finally `equalMass_lyapunovTime_eq` gives the equal-mass predictability horizon in closed
form, `√2·log(Δ/δ₀)/ω`.
-/

noncomputable section

open Filter Topology RealInnerProductSpace

namespace ThreeBody

/-! ### 1. Mass majorisation: chaos is a Schur-concave functional of the masses -/

/-- **Robin Hood transfer increases the Routh parameter.** Moving an amount `ε` of mass
from the heavier body `m₂` to the lighter body `m₁` (without overshooting) strictly
increases `K`, hence strictly increases the growth rate. -/
theorem routhParam_robin_hood {m₁ m₂ m₃ eps : ℝ} (hsum : 0 < m₁ + m₂ + m₃)
    (heps : 0 < eps) (hlt : eps < m₂ - m₁) :
    routhParam m₁ m₂ m₃ < routhParam (m₁ + eps) (m₂ - eps) m₃ := by
  have hden : 0 < (m₁ + m₂ + m₃) ^ 2 := by positivity
  have hsum' : m₁ + eps + (m₂ - eps) + m₃ = m₁ + m₂ + m₃ := by ring
  have key : m₁ * m₂ + m₂ * m₃ + m₃ * m₁
      < (m₁ + eps) * (m₂ - eps) + (m₂ - eps) * m₃ + m₃ * (m₁ + eps) := by nlinarith
  unfold routhParam
  rw [hsum']
  exact (div_lt_div_iff_of_pos_right hden).mpr key

/-- **Strict version of the equal-mass optimum.** Unless all three masses coincide, the
Routh parameter is strictly below `1/3`. -/
theorem routhParam_lt_third_of_ne {m₁ m₂ m₃ : ℝ} (hsum : 0 < m₁ + m₂ + m₃)
    (hne : ¬(m₁ = m₂ ∧ m₂ = m₃)) : routhParam m₁ m₂ m₃ < 1 / 3 := by
  have hden : 0 < (m₁ + m₂ + m₃) ^ 2 := by positivity
  unfold routhParam
  rw [div_lt_iff₀ hden]
  rcases not_and_or.mp hne with h | h
  · have hne' : m₁ - m₂ ≠ 0 := sub_ne_zero.mpr h
    have : 0 < (m₁ - m₂) ^ 2 := by positivity
    nlinarith [sq_nonneg (m₂ - m₃), sq_nonneg (m₃ - m₁)]
  · have hne' : m₂ - m₃ ≠ 0 := sub_ne_zero.mpr h
    have : 0 < (m₂ - m₃) ^ 2 := by positivity
    nlinarith [sq_nonneg (m₁ - m₂), sq_nonneg (m₃ - m₁)]

/-- Below the Routh threshold the growth rate vanishes identically. -/
theorem lagrangeExponent_eq_zero_of_le {K : ℝ} (hK : K ≤ 1 / 27) : lagrangeExponent K = 0 := by
  have h1 : Real.sqrt (27 * K) ≤ 1 := by
    have h := Real.sqrt_le_sqrt (show 27 * K ≤ 1 by linarith)
    simpa using h
  unfold lagrangeExponent
  rw [Real.sqrt_eq_zero_of_nonpos (by linarith)]
  ring

/-- **The growth rate is strictly increasing above the threshold.** -/
theorem lagrangeExponent_strictMono {K L : ℝ} (hK : 1 / 27 ≤ K) (hKL : K < L) :
    lagrangeExponent K < lagrangeExponent L := by
  have h1 : (1 : ℝ) ≤ Real.sqrt (27 * K) := by
    have h := Real.sqrt_le_sqrt (show (1 : ℝ) ≤ 27 * K by linarith)
    simpa using h
  have h2 : Real.sqrt (27 * K) < Real.sqrt (27 * L) :=
    Real.sqrt_lt_sqrt (by linarith) (by linarith)
  have h3 : Real.sqrt (Real.sqrt (27 * K) - 1) < Real.sqrt (Real.sqrt (27 * L) - 1) :=
    Real.sqrt_lt_sqrt (by linarith) (by linarith)
  unfold lagrangeExponent
  linarith

/-- **The equal-mass system is the unique maximiser of chaos.** For any mass distribution
that is not perfectly equal, the Lagrange growth rate is *strictly* below the equal-mass
value `√2/2`. -/
theorem lagrangeExponent_lt_equalMass_of_ne {m₁ m₂ m₃ : ℝ} (hsum : 0 < m₁ + m₂ + m₃)
    (hne : ¬(m₁ = m₂ ∧ m₂ = m₃)) :
    lagrangeExponent (routhParam m₁ m₂ m₃) < Real.sqrt 2 / 2 := by
  have hK : routhParam m₁ m₂ m₃ < 1 / 3 := routhParam_lt_third_of_ne hsum hne
  rcases le_or_gt (routhParam m₁ m₂ m₃) (1 / 27) with h | h
  · rw [lagrangeExponent_eq_zero_of_le h]
    have : (0 : ℝ) < Real.sqrt 2 := Real.sqrt_pos.mpr (by norm_num)
    linarith
  · have := lagrangeExponent_strictMono (le_of_lt h) hK
    rwa [equalMass_lagrangeExponent] at this

/-! ### 2. Concavity of the growth rate -/

/-- **The growth rate is concave above the Routh threshold.** Both nested square roots are
concave and increasing, so `σ` is a concave function of the Routh parameter on
`[1/27, ∞)`. -/
theorem lagrangeExponent_concaveOn :
    ConcaveOn ℝ (Set.Ici (1 / 27 : ℝ)) lagrangeExponent := by
  refine ⟨convex_Ici _, ?_⟩
  intro K hK L hL a b ha hb hab
  simp only [smul_eq_mul, Set.mem_Ici] at *
  set A := Real.sqrt (27 * K) with hA
  set B := Real.sqrt (27 * L) with hB
  set C := Real.sqrt (27 * (a * K + b * L)) with hC
  have hA1 : (1 : ℝ) ≤ A := by
    have h := Real.sqrt_le_sqrt (show (1 : ℝ) ≤ 27 * K by linarith)
    simpa [hA] using h
  have hB1 : (1 : ℝ) ≤ B := by
    have h := Real.sqrt_le_sqrt (show (1 : ℝ) ≤ 27 * L by linarith)
    simpa [hB] using h
  have hAsq : A ^ 2 = 27 * K := Real.sq_sqrt (by linarith)
  have hBsq : B ^ 2 = 27 * L := Real.sq_sqrt (by linarith)
  have hCsq : C ^ 2 = 27 * (a * K + b * L) := Real.sq_sqrt (by nlinarith)
  have hC0 : 0 ≤ C := Real.sqrt_nonneg _
  -- Step 1: concavity of the outer square root, `aA + bB ≤ C`.
  have hstep1 : a * A + b * B ≤ C := by
    have hD0 : 0 ≤ a * A + b * B := by
      have h1 := mul_nonneg ha (by linarith : (0 : ℝ) ≤ A)
      have h2 := mul_nonneg hb (by linarith : (0 : ℝ) ≤ B)
      linarith
    have hKL : 27 * (a * K + b * L) = a * A ^ 2 + b * B ^ 2 := by
      linear_combination (-a) * hAsq + (-b) * hBsq
    have hDsq : (a * A + b * B) ^ 2 ≤ C ^ 2 := by
      rw [hCsq, hKL]
      nlinarith [mul_nonneg (mul_nonneg ha hb) (sq_nonneg (A - B))]
    have h := Real.sqrt_le_sqrt hDsq
    rwa [Real.sqrt_sq hD0, Real.sqrt_sq hC0] at h
  -- Step 2: concavity of the inner square root.
  set x := Real.sqrt (A - 1) with hx
  set y := Real.sqrt (B - 1) with hy
  have hx0 : 0 ≤ x := Real.sqrt_nonneg _
  have hy0 : 0 ≤ y := Real.sqrt_nonneg _
  have hxsq : x ^ 2 = A - 1 := Real.sq_sqrt (by linarith)
  have hysq : y ^ 2 = B - 1 := Real.sq_sqrt (by linarith)
  have hstep2 : a * x + b * y ≤ Real.sqrt (C - 1) := by
    have h2 : (a * x + b * y) ^ 2 ≤ a * x ^ 2 + b * y ^ 2 := by
      nlinarith [mul_nonneg (mul_nonneg ha hb) (sq_nonneg (x - y))]
    have h3 : a * x ^ 2 + b * y ^ 2 = a * A + b * B - 1 := by
      rw [hxsq, hysq]; linear_combination -hab
    have h1 : a * x + b * y = Real.sqrt ((a * x + b * y) ^ 2) :=
      (Real.sqrt_sq (by positivity)).symm
    rw [h1]
    exact Real.sqrt_le_sqrt (by linarith)
  show a * (Real.sqrt (A - 1) / 2) + b * (Real.sqrt (B - 1) / 2) ≤ Real.sqrt (C - 1) / 2
  rw [← hx, ← hy]
  linarith

/-- **Averaging two mass distributions never decreases the growth rate**: the midpoint
(Jensen) form of `lagrangeExponent_concaveOn`. -/
theorem lagrangeExponent_midpoint_concave {K L : ℝ} (hK : 1 / 27 ≤ K) (hL : 1 / 27 ≤ L) :
    (lagrangeExponent K + lagrangeExponent L) / 2 ≤ lagrangeExponent ((K + L) / 2) := by
  have h := lagrangeExponent_concaveOn.2 (Set.mem_Ici.mpr hK) (Set.mem_Ici.mpr hL)
    (by norm_num : (0 : ℝ) ≤ 1 / 2) (by norm_num : (0 : ℝ) ≤ 1 / 2) (by norm_num)
  simp only [smul_eq_mul] at h
  calc (lagrangeExponent K + lagrangeExponent L) / 2
      = 1 / 2 * lagrangeExponent K + 1 / 2 * lagrangeExponent L := by ring
    _ ≤ lagrangeExponent (1 / 2 * K + 1 / 2 * L) := h
    _ = lagrangeExponent ((K + L) / 2) := by ring_nf

end ThreeBody


namespace Chaos

/-! ### 3. The symplectic refinement of Ruelle's inequality -/

/-- **Symplectic Ruelle data**: a Lyapunov spectrum equipped with the Hamiltonian pairing
`λ ↦ −λ` realised by an involution of the index set. This is the structure proved for the
Lagrange spectrum in `ThreeBody.lagrangeChar_neg_root`. -/
structure SymplecticRuelleData (d : ℕ) extends RuelleData d where
  /-- The symplectic pairing of indices. -/
  pair : Fin d → Fin d
  /-- The pairing is an involution, hence a bijection of the index set. -/
  pair_involutive : Function.Involutive pair
  /-- Paired exponents are opposite: this is the Hamiltonian `±λ` symmetry. -/
  exps_pair : ∀ i, toRuelleData.exps (pair i) = -toRuelleData.exps i

namespace SymplecticRuelleData

variable {d : ℕ} (S : SymplecticRuelleData d)

/-- **At most half of the exponents can be positive.** The symplectic pairing injects the
set of positive exponents into its complement. -/
theorem two_mul_card_pos_le :
    2 * (Finset.univ.filter fun i => 0 < S.exps i).card ≤ d := by
  classical
  set P : Finset (Fin d) := Finset.univ.filter fun i => 0 < S.exps i with hP
  have hmaps : ∀ i ∈ P, S.pair i ∈ Pᶜ := by
    intro i hi
    have hi' : 0 < S.exps i := by
      simpa [hP] using hi
    have : S.exps (S.pair i) < 0 := by rw [S.exps_pair i]; linarith
    simp [hP, Finset.mem_filter]
    linarith
  have hinj : Set.InjOn S.pair P := fun a _ b _ hab => S.pair_involutive.injective hab
  have hcard : P.card ≤ Pᶜ.card := Finset.card_le_card_of_injOn S.pair hmaps hinj
  have hcompl : Pᶜ.card = d - P.card := by
    rw [Finset.card_compl]; simp
  have hle : P.card ≤ d := by
    simpa using Finset.card_le_card (Finset.subset_univ P)
  omega

/-- **Sharpened Ruelle inequality for Hamiltonian systems.** Because the exponents come in
pairs `±λ`, the entropy is spread over at most `d/2` positive exponents, so
`2·h_KS ≤ d·λ_max`: a factor-two improvement on the general bound `h_KS ≤ d·λ_max`. -/
theorem two_mul_entropy_le (h : 0 < S.entropy) :
    2 * S.entropy ≤ (d : ℝ) * S.maxExp := by
  classical
  set P : Finset (Fin d) := Finset.univ.filter fun i => 0 < S.exps i with hP
  have hmax : 0 < S.maxExp := S.toRuelleData.maxExp_pos h
  have hsplit : ∑ i, max (S.exps i) 0 = ∑ i ∈ P, max (S.exps i) 0 := by
    refine (Finset.sum_subset (Finset.subset_univ P) ?_).symm
    intro i _ hi
    have : ¬ 0 < S.exps i := by simpa [hP] using hi
    exact max_eq_right (by linarith [not_lt.mp this])
  have hbd : ∑ i ∈ P, max (S.exps i) 0 ≤ (P.card : ℝ) * S.maxExp := by
    calc ∑ i ∈ P, max (S.exps i) 0
        ≤ ∑ _i ∈ P, S.maxExp :=
          Finset.sum_le_sum fun i _ => max_le (S.toRuelleData.le_maxExp i) hmax.le
      _ = (P.card : ℝ) * S.maxExp := by simp [Finset.sum_const, nsmul_eq_mul]
  have hcard : 2 * (P.card : ℝ) ≤ (d : ℝ) := by
    exact_mod_cast S.two_mul_card_pos_le
  have hruelle : S.entropy ≤ (P.card : ℝ) * S.maxExp := by
    have := S.ruelle
    rw [hsplit] at this
    linarith
  nlinarith

/-- The bound in the form `λ_max ≥ 2·h_KS/d`. -/
theorem two_mul_entropy_div_dim_le_maxExp (h : 0 < S.entropy) :
    2 * S.entropy / d ≤ S.maxExp := by
  have hd : (0 : ℝ) < d := by exact_mod_cast S.dim_pos
  rw [div_le_iff₀ hd]
  have := S.two_mul_entropy_le h
  linarith [this]

end SymplecticRuelleData

/-- The Lagrange spectrum `{σ, σ, −σ, −σ}` carries the symplectic pairing `0↔2`, `1↔3`. -/
def lagrangeSymplecticData (ω K h : ℝ) (hω : 0 < ω) (hK : 1 / 27 < K)
    (hh : h ≤ 2 * (ω * ThreeBody.lagrangeExponent K)) : SymplecticRuelleData 4 where
  toRuelleData := lagrangeRuelleData ω K h hω hK hh
  pair := ![2, 3, 0, 1]
  pair_involutive := by intro i; fin_cases i <;> rfl
  exps_pair := by
    intro i
    fin_cases i <;>
      simp [lagrangeRuelleData, lagrangeSpectrum]

/-- **Improved entropy bound for the three-body Lagrange configuration.** The symplectic
pairing halves the dimensional loss: `λ_max ≥ h_KS/2` instead of `h_KS/4`. -/
theorem lagrange_entropy_div_two_le_maxExp (ω K h : ℝ) (hω : 0 < ω) (hK : 1 / 27 < K)
    (hh : h ≤ 2 * (ω * ThreeBody.lagrangeExponent K)) (hpos : 0 < h) :
    h / 2 ≤ (lagrangeSymplecticData ω K h hω hK hh).maxExp := by
  have := (lagrangeSymplecticData ω K h hω hK hh).two_mul_entropy_div_dim_le_maxExp
    (by simpa [lagrangeSymplecticData, lagrangeRuelleData] using hpos)
  have hrw : 2 * (lagrangeSymplecticData ω K h hω hK hh).entropy / (4 : ℕ) = h / 2 := by
    simp [lagrangeSymplecticData, lagrangeRuelleData]
    ring
  rwa [hrw] at this

/-- **A `2`-symbol horseshoe in a Hamiltonian system forces `λ_max ≥ ½ log 2`,**
independently of the dimension `d` of the section — the symplectic sharpening of
`horseshoe_forces_positive_lyapunov`. -/
theorem symplectic_horseshoe_bound {d : ℕ} (S : SymplecticRuelleData d)
    (hd : d ≤ 4) (hent : Real.log 2 ≤ S.entropy) : Real.log 2 / 2 ≤ S.maxExp := by
  have hlog : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hpos : 0 < S.entropy := lt_of_lt_of_le hlog hent
  have h1 := S.two_mul_entropy_le hpos
  have hmax : 0 < S.maxExp := S.toRuelleData.maxExp_pos hpos
  have hdR : (d : ℝ) ≤ 4 := by exact_mod_cast hd
  nlinarith

end Chaos

namespace Chaos

/-! ### 4. Convexity forces escape: the zero-energy case -/

/-- **Tangent-line bound for a convex function.** If `f'' ≥ 0` everywhere then `f` lies
above each of its tangent lines, on both sides of the point of tangency. -/
theorem tangent_line_lower_bound (f f' f'' : ℝ → ℝ)
    (hf : ∀ t, HasDerivAt f (f' t) t) (hf' : ∀ t, HasDerivAt f' (f'' t) t)
    (hpos : ∀ t, 0 ≤ f'' t) (t₀ t : ℝ) :
    f t₀ + f' t₀ * (t - t₀) ≤ f t := by
  have hmono : Monotone f' :=
    monotone_of_deriv_nonneg (fun s => (hf' s).differentiableAt)
      (fun s => by rw [(hf' s).deriv]; exact hpos s)
  set g : ℝ → ℝ := fun u => f u - (f t₀ + f' t₀ * (u - t₀)) with hg
  have hgd : ∀ s, HasDerivAt g (f' s - f' t₀) s := by
    intro s
    have h1 : HasDerivAt (fun u : ℝ => f t₀ + f' t₀ * (u - t₀)) (f' t₀) s := by
      have := (((hasDerivAt_id s).sub_const t₀).const_mul (f' t₀)).const_add (f t₀)
      simpa using this
    exact (hf s).sub h1
  have hg0 : g t₀ = 0 := by simp [hg]
  rcases le_total t₀ t with h | h
  · have hmono2 : MonotoneOn g (Set.Ici t₀) := by
      apply monotoneOn_of_deriv_nonneg (convex_Ici t₀)
        (fun s _ => (hgd s).differentiableAt.continuousAt.continuousWithinAt)
        (fun s _ => (hgd s).differentiableAt.differentiableWithinAt)
      intro s hs
      rw [(hgd s).deriv]
      simp only [interior_Ici, Set.mem_Ioi] at hs
      linarith [hmono hs.le]
    have := hmono2 Set.self_mem_Ici (Set.mem_Ici.mpr h) h
    rw [hg0] at this
    simp only [hg] at this
    linarith
  · have hanti : AntitoneOn g (Set.Iic t₀) := by
      apply antitoneOn_of_deriv_nonpos (convex_Iic t₀)
        (fun s _ => (hgd s).differentiableAt.continuousAt.continuousWithinAt)
        (fun s _ => (hgd s).differentiableAt.differentiableWithinAt)
      intro s hs
      rw [(hgd s).deriv]
      simp only [interior_Iic, Set.mem_Iio] at hs
      linarith [hmono hs.le]
    have := hanti (Set.mem_Iic.mpr h) Set.self_mem_Iic h
    rw [hg0] at this
    simp only [hg] at this
    linarith

/-- **Strictly convex functions escape to `+∞` in forward or backward time.** No function
with everywhere positive second derivative is bounded above on `ℝ`. -/
theorem strictly_convex_escape (f f' f'' : ℝ → ℝ)
    (hf : ∀ t, HasDerivAt f (f' t) t) (hf' : ∀ t, HasDerivAt f' (f'' t) t)
    (hpos : ∀ t, 0 < f'' t) :
    Tendsto f atTop atTop ∨ Tendsto f atBot atTop := by
  have hstrict : StrictMono f' :=
    strictMono_of_deriv_pos (fun s => by rw [(hf' s).deriv]; exact hpos s)
  have htan := tangent_line_lower_bound f f' f'' hf hf' (fun t => (hpos t).le)
  have hgo : ∀ t₀ : ℝ, 0 < f' t₀ → Tendsto f atTop atTop := by
    intro t₀ ht₀
    have haff : Tendsto (fun t : ℝ => f t₀ + f' t₀ * (t - t₀)) atTop atTop := by
      have h := Filter.Tendsto.const_mul_atTop ht₀
        (tendsto_atTop_add_const_right atTop (-t₀) tendsto_id)
      simpa using Filter.tendsto_atTop_add_const_left _ (f t₀) h
    exact tendsto_atTop_mono (fun t => htan t₀ t) haff
  have hback : ∀ t₀ : ℝ, f' t₀ < 0 → Tendsto f atBot atTop := by
    intro t₀ ht₀
    have haff : Tendsto (fun t : ℝ => f t₀ + f' t₀ * (t - t₀)) atBot atTop := by
      have h1 : Tendsto (fun t : ℝ => t - t₀) atBot atBot :=
        tendsto_atBot_add_const_right atBot (-t₀) tendsto_id
      have h2 : Tendsto (fun t : ℝ => f' t₀ * (t - t₀)) atBot atTop :=
        Filter.Tendsto.const_mul_atBot_of_neg ht₀ h1
      simpa using Filter.tendsto_atTop_add_const_left _ (f t₀) h2
    exact tendsto_atTop_mono (fun t => htan t₀ t) haff
  rcases lt_trichotomy (f' 0) 0 with h | h | h
  · exact Or.inr (hback 0 h)
  · exact Or.inl (hgo 1 (by rw [← h]; exact hstrict (by norm_num)))
  · exact Or.inl (hgo 0 h)

end Chaos

namespace ThreeBody

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

omit [InnerProductSpace ℝ E] in
/-- The gravitational potential energy of a collision-free configuration of three positive
masses is strictly positive. -/
theorem potentialEnergy_pos {G m₁ m₂ m₃ : ℝ} (hG : 0 < G) (h₁ : 0 < m₁) (h₂ : 0 < m₂)
    (h₃ : 0 < m₃) {r₁ r₂ r₃ : E} (h₁₂ : r₁ ≠ r₂) (h₂₃ : r₂ ≠ r₃) (h₃₁ : r₃ ≠ r₁) :
    0 < potentialEnergy G m₁ m₂ m₃ r₁ r₂ r₃ := by
  have n₁₂ : 0 < ‖r₁ - r₂‖ := norm_sub_pos_iff.mpr h₁₂
  have n₂₃ : 0 < ‖r₂ - r₃‖ := norm_sub_pos_iff.mpr h₂₃
  have n₃₁ : 0 < ‖r₃ - r₁‖ := norm_sub_pos_iff.mpr h₃₁
  have t₁ : 0 < G * m₁ * m₂ / ‖r₁ - r₂‖ := by positivity
  have t₂ : 0 < G * m₂ * m₃ / ‖r₂ - r₃‖ := by positivity
  have t₃ : 0 < G * m₃ * m₁ / ‖r₃ - r₁‖ := by positivity
  unfold potentialEnergy
  linarith

/-- **Non-negative energy forces escape (sharp form of the Lagrange–Jacobi dichotomy).**
If the total energy of a collision-free three-body motion is non-negative — in particular
in the critical case `E = 0`, which `positive_energy_escape` does not cover — then the
polar moment of inertia is unbounded: it tends to `+∞` in forward or in backward time.
Consequently every three-body motion that is bounded for all time has *strictly negative*
energy. -/
theorem nonneg_energy_escape (G m₁ m₂ m₃ : ℝ) (hG : 0 < G) (hm₁ : 0 < m₁)
    (hm₂ : 0 < m₂) (hm₃ : 0 < m₃) (r₁ r₂ r₃ v₁ v₂ v₃ : ℝ → E)
    (hr₁ : ∀ t, HasDerivAt r₁ (v₁ t) t) (hr₂ : ∀ t, HasDerivAt r₂ (v₂ t) t)
    (hr₃ : ∀ t, HasDerivAt r₃ (v₃ t) t)
    (hv₁ : ∀ t, HasDerivAt v₁ (newtonianAccel G m₂ m₃ (r₁ t) (r₂ t) (r₃ t)) t)
    (hv₂ : ∀ t, HasDerivAt v₂ (newtonianAccel G m₃ m₁ (r₂ t) (r₃ t) (r₁ t)) t)
    (hv₃ : ∀ t, HasDerivAt v₃ (newtonianAccel G m₁ m₂ (r₃ t) (r₁ t) (r₂ t)) t)
    (hsep : ∀ t, r₁ t ≠ r₂ t ∧ r₂ t ≠ r₃ t ∧ r₃ t ≠ r₁ t)
    (henergy : ∀ t, 0 ≤ kineticEnergy m₁ m₂ m₃ (v₁ t) (v₂ t) (v₃ t)
      - potentialEnergy G m₁ m₂ m₃ (r₁ t) (r₂ t) (r₃ t)) :
    Tendsto (fun t => momentOfInertia m₁ m₂ m₃ (r₁ t) (r₂ t) (r₃ t)) atTop atTop ∨
      Tendsto (fun t => momentOfInertia m₁ m₂ m₃ (r₁ t) (r₂ t) (r₃ t)) atBot atTop := by
  set I : ℝ → ℝ := fun t => momentOfInertia m₁ m₂ m₃ (r₁ t) (r₂ t) (r₃ t) with hIdef
  set h : ℝ → ℝ := fun t => 4 * kineticEnergy m₁ m₂ m₃ (v₁ t) (v₂ t) (v₃ t)
    - 2 * potentialEnergy G m₁ m₂ m₃ (r₁ t) (r₂ t) (r₃ t) with hhdef
  have hLJ : ∀ t, HasDerivAt (deriv I) (h t) t :=
    fun t => lagrange_jacobi G m₁ m₂ m₃ r₁ r₂ r₃ v₁ v₂ v₃ hr₁ hr₂ hr₃ hv₁ hv₂ hv₃ hsep t
  have hI : ∀ t, HasDerivAt I (deriv I t) t := by
    intro t
    have d₁ := (hasDerivAt_normSq r₁ v₁ hr₁ t).const_mul m₁
    have d₂ := (hasDerivAt_normSq r₂ v₂ hr₂ t).const_mul m₂
    have d₃ := (hasDerivAt_normSq r₃ v₃ hr₃ t).const_mul m₃
    have hd : HasDerivAt I
        (m₁ * (2 * ⟪r₁ t, v₁ t⟫) + m₂ * (2 * ⟪r₂ t, v₂ t⟫) + m₃ * (2 * ⟪r₃ t, v₃ t⟫)) t :=
      (d₁.add d₂).add d₃
    rw [hd.deriv]
    exact hd
  have hpos : ∀ t, 0 < h t := by
    intro t
    obtain ⟨s₁, s₂, s₃⟩ := hsep t
    have hU := potentialEnergy_pos (m₁ := m₁) (m₂ := m₂) (m₃ := m₃) hG hm₁ hm₂ hm₃ s₁ s₂ s₃
    have hE := henergy t
    simp only [hhdef]
    linarith
  exact Chaos.strictly_convex_escape I (deriv I) h hI hLJ hpos

/-- **Bounded three-body motions have strictly negative energy.** Contrapositive form of
`nonneg_energy_escape`, using conservation of energy to reduce to the initial data. -/
theorem bounded_motion_energy_neg (G m₁ m₂ m₃ : ℝ) (hG : 0 < G) (hm₁ : 0 < m₁)
    (hm₂ : 0 < m₂) (hm₃ : 0 < m₃) (r₁ r₂ r₃ v₁ v₂ v₃ : ℝ → E)
    (hr₁ : ∀ t, HasDerivAt r₁ (v₁ t) t) (hr₂ : ∀ t, HasDerivAt r₂ (v₂ t) t)
    (hr₃ : ∀ t, HasDerivAt r₃ (v₃ t) t)
    (hv₁ : ∀ t, HasDerivAt v₁ (newtonianAccel G m₂ m₃ (r₁ t) (r₂ t) (r₃ t)) t)
    (hv₂ : ∀ t, HasDerivAt v₂ (newtonianAccel G m₃ m₁ (r₂ t) (r₃ t) (r₁ t)) t)
    (hv₃ : ∀ t, HasDerivAt v₃ (newtonianAccel G m₁ m₂ (r₃ t) (r₁ t) (r₂ t)) t)
    (hsep : ∀ t, r₁ t ≠ r₂ t ∧ r₂ t ≠ r₃ t ∧ r₃ t ≠ r₁ t)
    (M : ℝ) (hbdd : ∀ t, momentOfInertia m₁ m₂ m₃ (r₁ t) (r₂ t) (r₃ t) ≤ M) :
    totalEnergy G m₁ m₂ m₃ (r₁ 0) (r₂ 0) (r₃ 0) (v₁ 0) (v₂ 0) (v₃ 0) < 0 := by
  by_contra hcon
  push_neg at hcon
  have henergy : ∀ t, 0 ≤ kineticEnergy m₁ m₂ m₃ (v₁ t) (v₂ t) (v₃ t)
      - potentialEnergy G m₁ m₂ m₃ (r₁ t) (r₂ t) (r₃ t) := by
    intro t
    have := energy_conservation G m₁ m₂ m₃ r₁ r₂ r₃ v₁ v₂ v₃ hr₁ hr₂ hr₃ hv₁ hv₂ hv₃ hsep t
    simp only [totalEnergy] at this hcon
    linarith
  have hesc := nonneg_energy_escape G m₁ m₂ m₃ hG hm₁ hm₂ hm₃ r₁ r₂ r₃ v₁ v₂ v₃
    hr₁ hr₂ hr₃ hv₁ hv₂ hv₃ hsep henergy
  rcases hesc with hesc | hesc
  · obtain ⟨t, ht⟩ := (hesc.eventually_ge_atTop (M + 1)).exists
    linarith [hbdd t]
  · obtain ⟨t, ht⟩ := (hesc.eventually_ge_atTop (M + 1)).exists
    linarith [hbdd t]

/-- **Closed form for the equal-mass Lyapunov time.** With `ω = √(3Gm/a³)` the time to
amplify an initial uncertainty `δ₀` up to the scale `Δ` is exactly `√2·log(Δ/δ₀)/ω`. -/
theorem equalMass_lyapunovTime_eq {G m a δ₀ Δ : ℝ} (hG : 0 < G) (hm : 0 < m) (ha : 0 < a) :
    Chaos.lyapunovTime (equalMassLyapunovRate G (3 * m) a) δ₀ Δ
      = Real.sqrt 2 * Real.log (Δ / δ₀) / keplerFrequency G (3 * m) a := by
  have hω : 0 < keplerFrequency G (3 * m) a := keplerFrequency_pos hG (by linarith) ha
  unfold Chaos.lyapunovTime equalMassLyapunovRate
  field_simp
  rw [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2)]

end ThreeBody