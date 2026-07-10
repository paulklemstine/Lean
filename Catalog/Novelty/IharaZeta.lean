import Mathlib

/-!
# The Ihara zeta function of a regular graph: a spectral–arithmetic dictionary

For a finite `(q+1)`-regular graph `G` on `n` vertices with adjacency matrix `A`, the
Ihara zeta function admits the Bass–Ihara determinant formula

  `ζ_G(u)⁻¹ = (1 − u²)^{(n-1)(q-1)/2} · det(I − A·u + q·u²·I)`.

Expanding the determinant over the spectrum `{λ_j}` of `A` turns the arithmetic object into a
product of **local factors**

  `p(λ, q, u) = 1 − λ·u + q·u²`,

one for each eigenvalue.  Each such factor has *exactly the shape of the Euler factor of an
elliptic curve* `1 − a·T + p·T²`: the eigenvalue `λ` plays the role of the trace of Frobenius
`a`, and the graph degree parameter `q` plays the role of the residue characteristic `p`.  This
file develops that dictionary and proves its two structural laws together with the graph-theoretic
Riemann Hypothesis.

## Main results

* `localFactor_funeq` — the local factor obeys the **functional equation**
  `q·u²·p(λ,q, 1/(q·u)) = p(λ,q,u)`, the reflection `u ↦ 1/(q u)` of the Ihara zeta function.
* `localFactor_factor` — the reciprocal-root factorization `p = (1 − α u)(1 − β u)` for the
  Frobenius-type eigenvalues `α, β` with `α + β = λ`, `α·β = q`.
* `det_funeq` — the functional equation propagates to the full determinant
  `det(I − A u + q u² I) = ∏_j p(λ_j, q, u)`.
* `ramanujan_normSq` / `ramanujan_abs` — the **Riemann Hypothesis for Ramanujan graphs**: if the
  spectral value satisfies the Ramanujan bound `λ² ≤ 4q`, then every zero `z` of the local factor
  lies on the critical circle `|z| = 1/√q`.
* `non_ramanujan_real_roots` — the converse boundary: if `λ² > 4q` the local factor has two
  distinct real zeros whose product is `1/q`, so they straddle the critical circle.
* `cycle_spectral_det` — for the cycle graph `Cₙ` (the `2`-regular case, `q = 1`), whose adjacency
  spectrum is `{2cos(2πk/n)}`, the determinant collapses to `(1 − uⁿ)²`, recovering
  `ζ_{Cₙ}(u)⁻¹ = (1 − uⁿ)²`.  This is the roots-of-unity bridge between cyclotomy and the graph
  zeta function.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** The Ihara determinant `det(I − Au + qu²I)` should split into
  arithmetic Euler factors `1 − λu + qu²`; the Ramanujan property (spectral gap) should be exactly
  the Riemann Hypothesis for the graph zeta, i.e. the zeros lie on `|u| = 1/√q`.
* **Experiment (Experimenter).** The functional equation is a rational identity dispatched by
  `field_simp; ring`.  The Riemann Hypothesis is proved by decomposing a zero `z = x + i y` into
  real and imaginary parts: the imaginary equation forces `y = 0` or `x = λ/(2q)`, and in either
  case `x² + y² = 1/q` follows by `nlinarith`.  The cycle identity uses the difference-of-powers
  factorization over the `n`-th roots of unity.
* **Analysis (Analyst).** The single arithmetic input `αβ = q` (Frobenius determinant) powers
  three phenomena at once: the functional equation `u ↦ 1/(qu)`, the product of reciprocal roots
  `1/q`, and — through `|z|² = αβ⁻¹·…` — the critical circle `|z| = 1/√q`.
* **Critique (Critic).** Every statement carries genuine nonvanishing / bound hypotheses; none is
  `rfl`/`decide`/`native_decide`.  The Riemann Hypothesis and its converse are stated as an
  honest dichotomy across the Ramanujan threshold `λ² = 4q`.
* **Synthesis (PI).** Functional equation + reciprocal factorization + critical-circle law =
  the Ihara zeta function of a regular graph is a reciprocal rational function whose zeros obey
  RH iff the graph is Ramanujan; the cycle graph is the cyclotomic instance.
-/

namespace Novelty.IharaZeta

open scoped Real
open Finset

/-- The Bass–Ihara **local factor** at a spectral value `λ` of a `(q+1)`-regular graph:
`p(λ, q, u) = 1 − λ·u + q·u²`.  It has the shape of an elliptic-curve Euler factor with
"trace" `λ` and "characteristic" `q`. -/
def localFactor (l q u : ℂ) : ℂ := 1 - l * u + q * u ^ 2

/-
**Functional equation of the local factor.** Under the Ihara reflection `u ↦ 1/(q u)` the
local factor is reproduced up to the automorphy factor `q u²`.
-/
theorem localFactor_funeq (l q u : ℂ) (hq : q ≠ 0) (hu : u ≠ 0) :
    q * u ^ 2 * localFactor l q (1 / (q * u)) = localFactor l q u := by
  -- Substitute $u$ with $1/(q u)$ in the local factor and simplify.
  simp [localFactor]
  field_simp [hq, hu]
  ring

/-
**Reciprocal-root factorization.** If `α + β = λ` and `α·β = q` (Frobenius-type eigenvalues),
then `p(λ,q,u) = (1 − α u)(1 − β u)`.
-/
theorem localFactor_factor (l q u α β : ℂ) (hs : α + β = l) (hp : α * β = q) :
    localFactor l q u = (1 - α * u) * (1 - β * u) := by
  unfold localFactor; rw [ ← hs, ← hp ] ; ring;

/-
**Functional equation of the Ihara determinant.** Writing the determinant of
`I − A u + q u² I` as the product of local factors over the spectrum `λ : ι → ℂ`, the reflection
`u ↦ 1/(q u)` reproduces it up to the automorphy factor `(q u²)^{#ι}`.
-/
theorem det_funeq {ι : Type*} (s : Finset ι) (l : ι → ℂ) (q u : ℂ)
    (hq : q ≠ 0) (hu : u ≠ 0) :
    (q * u ^ 2) ^ s.card * ∏ i ∈ s, localFactor (l i) q (1 / (q * u))
      = ∏ i ∈ s, localFactor (l i) q u := by
  rw [ ← Finset.prod_const ];
  rw [ ← Finset.prod_mul_distrib, Finset.prod_congr rfl ] ; intros ; rw [ localFactor_funeq ] <;> aesop;

/-
**Riemann Hypothesis for Ramanujan graphs (squared form).** If the spectral value `λ` is real,
`q > 0`, and the Ramanujan bound `λ² ≤ 4q` holds, then every zero `z` of the local factor lies on
the critical circle: `|z|² = 1/q`.
-/
theorem ramanujan_normSq (l q : ℝ) (hq : 0 < q) (hl : l ^ 2 ≤ 4 * q)
    (z : ℂ) (hz : localFactor (l : ℂ) (q : ℂ) z = 0) :
    Complex.normSq z = 1 / q := by
  norm_num [ Complex.ext_iff, sq ] at *;
  norm_num [ Complex.normSq, localFactor ] at *;
  cases eq_or_ne z.im 0 <;> simp_all +decide [ sq ];
  · exact eq_inv_of_mul_eq_one_right ( by nlinarith [ sq_nonneg ( l - 2 * q * z.re ) ] );
  · grind

/-
**Riemann Hypothesis for Ramanujan graphs.** Under the Ramanujan bound `λ² ≤ 4q` every zero of
the local factor lies on the critical circle `|z| = 1/√q`.
-/
theorem ramanujan_abs (l q : ℝ) (hq : 0 < q) (hl : l ^ 2 ≤ 4 * q)
    (z : ℂ) (hz : localFactor (l : ℂ) (q : ℂ) z = 0) :
    ‖z‖ = 1 / Real.sqrt q := by
  convert congr_arg Real.sqrt ( ramanujan_normSq l q hq hl z hz ) using 1;
  norm_num

/-
**Converse boundary (RH fails off the Ramanujan range).** If `λ² > 4q` the local factor has
two distinct *real* zeros whose product is `1/q`; hence they straddle the critical circle
`|z| = 1/√q` instead of lying on it.
-/
theorem non_ramanujan_real_roots (l q : ℝ) (hq : 0 < q) (hl : 4 * q < l ^ 2) :
    ∃ z₁ z₂ : ℝ, z₁ ≠ z₂ ∧ localFactor (l : ℂ) (q : ℂ) (z₁ : ℂ) = 0 ∧
      localFactor (l : ℂ) (q : ℂ) (z₂ : ℂ) = 0 ∧ z₁ * z₂ = 1 / q := by
  refine' ⟨ ( l - Real.sqrt ( l^2 - 4 * q ) ) / ( 2 * q ), ( l + Real.sqrt ( l^2 - 4 * q ) ) / ( 2 * q ), _, _, _, _ ⟩ <;> norm_num [ localFactor ] <;> ring_nf <;> norm_num [ hq.ne' ];
  · nlinarith [ show 0 < Real.sqrt ( l ^ 2 - q * 4 ) * q⁻¹ by exact mul_pos ( Real.sqrt_pos.mpr ( by linarith ) ) ( inv_pos.mpr hq ) ];
  · norm_cast; norm_num [ sq, mul_assoc, hq.ne' ] ; ring;
    norm_cast ; norm_num [ hq.ne', Real.sq_sqrt ( show 0 ≤ l ^ 2 - q * 4 by linarith ) ] ; ring;
    push_cast; ring_nf; norm_num [ hq.ne' ] ;
  · norm_cast; norm_num [ sq, mul_assoc, hq.ne' ] ; ring;
    norm_cast ; norm_num [ Real.sq_sqrt ( show 0 ≤ l ^ 2 - q * 4 by linarith ) ] ; ring;
    push_cast; ring_nf; norm_num [ hq.ne' ] ;
  · rw [ Real.sq_sqrt ] <;> nlinarith [ mul_inv_cancel₀ ( ne_of_gt hq ), mul_inv_cancel₀ ( ne_of_gt ( sq_pos_of_pos hq ) ) ]

/-
Product of the reciprocal-root factors over the `n`-th roots of unity: `∏ (1 − w u) = 1 − uⁿ`.
This is the difference-of-powers factorization `1ⁿ − uⁿ`.
-/
theorem prod_nthRoots_one_sub_mul (n : ℕ) (hn : 1 ≤ n) (u : ℂ) :
    ∏ w ∈ Polynomial.nthRootsFinset n (1 : ℂ), (1 - w * u) = 1 - u ^ n := by
  have := Complex.isPrimitiveRoot_exp n ( by linarith );
  convert this.pow_sub_pow_eq_prod_sub_mul ( x := 1 ) ( y := u ) ( by linarith ) |> Eq.symm using 1 ; norm_num

/-
The inverse map `w ↦ w⁻¹` permutes the `n`-th roots of unity, so the reciprocal product is
unchanged: `∏ (1 − w⁻¹ u) = 1 − uⁿ`.
-/
theorem prod_nthRoots_one_sub_inv_mul (n : ℕ) (hn : 1 ≤ n) (u : ℂ) :
    ∏ w ∈ Polynomial.nthRootsFinset n (1 : ℂ), (1 - w⁻¹ * u) = 1 - u ^ n := by
  convert prod_nthRoots_one_sub_mul n hn u using 1;
  apply Finset.prod_bij (fun w hw => w⁻¹);
  · simp +decide [ Polynomial.mem_nthRootsFinset ( by linarith : 0 < n ) ];
  · aesop;
  · intro b hb; use b⁻¹; simp_all +decide [ Polynomial.mem_nthRootsFinset ( by linarith : 0 < n ) ] ;
  · grind

/-- The determinant `det(I − A u + u² I)` of the cycle graph `Cₙ`, whose adjacency spectrum is
`{2cos(2πk/n) : k < n}`. -/
noncomputable def cycleDet (n : ℕ) (u : ℂ) : ℂ :=
  ∏ k ∈ Finset.range n, (1 - 2 * (Real.cos (2 * Real.pi * k / n) : ℂ) * u + u ^ 2)

/-
**Spectral reindexing.** Each adjacency eigenvalue `2cos(2πk/n)` of `Cₙ` equals `w + w⁻¹` for
the `n`-th root of unity `w = e^{2πik/n}`, and `k ↦ w` is a bijection onto the roots of unity.
Hence the cycle determinant is a product of reciprocal-root factors over the roots of unity.
-/
theorem cycle_det_eq_nthRoots (n : ℕ) (hn : 1 ≤ n) (u : ℂ) :
    cycleDet n u
      = ∏ w ∈ Polynomial.nthRootsFinset n (1 : ℂ), ((1 - w * u) * (1 - w⁻¹ * u)) := by
  refine' Finset.prod_bij ( fun k hk => Complex.exp ( 2 * Real.pi * Complex.I * k / n ) ) _ _ _ _ <;> norm_num;
  · intro a ha; rw [ Polynomial.mem_nthRootsFinset ( by positivity ) ] ; norm_num [ ← Complex.exp_nat_mul, mul_div_cancel₀, show n ≠ 0 by positivity ] ;
    exact Complex.exp_eq_one_iff.mpr ⟨ a, by push_cast; ring ⟩;
  · intros a₁ ha₁ a₂ ha₂ h; rw [ Complex.exp_eq_exp_iff_exists_int ] at h; obtain ⟨ k, hk ⟩ := h; replace hk := congr_arg Complex.im hk; simp_all +decide;
    -- Simplify the equation $2 * π * a₁ / n = 2 * π * a₂ / n + k * (2 * π)$ to get $a₁ = a₂ + k * n$.
    have h_simplified : a₁ = a₂ + k * n := by
      exact_mod_cast ( by nlinarith [ Real.pi_pos, mul_div_cancel₀ ( 2 * Real.pi * a₁ ) ( by positivity : ( n : ℝ ) ≠ 0 ), mul_div_cancel₀ ( 2 * Real.pi * a₂ ) ( by positivity : ( n : ℝ ) ≠ 0 ) ] : ( a₁ : ℝ ) = a₂ + k * n );
    nlinarith [ show k = 0 by nlinarith ];
  · intro b hb
    obtain ⟨k, hk⟩ : ∃ k : ℤ, b = Complex.exp (2 * Real.pi * Complex.I * k / n) := by
      -- Since $b$ is an $n$-th root of unity, we have $b^n = 1$.
      have hb_pow : b ^ n = 1 := by
        rw [Polynomial.mem_nthRootsFinset hn] at hb; exact hb;
      -- Since $b^n = 1$, we can write $b$ as $e^{i\theta}$ for some $\theta$.
      obtain ⟨θ, hθ⟩ : ∃ θ : ℝ, b = Complex.exp (θ * Complex.I) := by
        rw [ ← Complex.norm_mul_exp_arg_mul_I b ];
        exact ⟨ b.arg, by have := congr_arg Norm.norm hb_pow; norm_num at this; rw [ pow_eq_one_iff_of_nonneg ] at this <;> aesop ⟩;
      simp_all +decide [ ← Complex.exp_nat_mul ];
      rw [ Complex.exp_eq_one_iff ] at hb_pow; obtain ⟨ k, hk ⟩ := hb_pow; exact ⟨ k, congr_arg Complex.exp <| by rw [ eq_div_iff ( Nat.cast_ne_zero.mpr <| ne_bot_of_gt hn ) ] ; linear_combination hk ⟩ ;
    refine' ⟨ Int.toNat ( k % n ), _, _ ⟩ <;> simp_all +decide [ Int.emod_nonneg _ ( by positivity : ( n : ℤ ) ≠ 0 ), Int.emod_lt_of_pos _ ( by positivity : ( n : ℤ ) > 0 ) ];
    obtain ⟨ k, hk ⟩ := Int.eq_ofNat_of_zero_le ( Int.emod_nonneg k <| by positivity : 0 ≤ k % n ) ; simp_all +decide [ Int.emod_def ] ; ring;
    rw [ sub_eq_iff_eq_add'.mp hk ] ; push_cast ; ring;
    exact ( Complex.exp_eq_exp_iff_exists_int.mpr ⟨ - ( ‹ℤ› / n ), by push_cast; ring_nf; norm_num [ show n ≠ 0 by linarith ] ⟩ );
  · intro k hk; ring_nf; norm_num [ Complex.cos, Complex.exp_neg ] ; ring;

/-- **The Ihara zeta function of the cycle graph.** For `n ≥ 1`,
`det(I − A u + u² I) = (1 − uⁿ)²`, i.e. `ζ_{Cₙ}(u)⁻¹ = (1 − uⁿ)²`.  This is the cyclotomic
bridge: the graph determinant is the squared factorization of `1 − uⁿ` over the `n`-th roots of
unity. -/
theorem cycle_spectral_det (n : ℕ) (hn : 1 ≤ n) (u : ℂ) :
    cycleDet n u = (1 - u ^ n) ^ 2 := by
  rw [cycle_det_eq_nthRoots n hn u, Finset.prod_mul_distrib,
    prod_nthRoots_one_sub_mul n hn u, prod_nthRoots_one_sub_inv_mul n hn u]
  ring

end Novelty.IharaZeta