import Mathlib

/-!
# The global spectral Ihara zeta function of a graph: RH ⇔ Ramanujan

For a finite connected `(q+1)`-regular graph `G` on `n` vertices with adjacency matrix `A`, the
Ihara zeta function admits the Bass–Ihara determinant formula

  `ζ_G(u)⁻¹ = (1 − u²)^{(n-1)(q-1)/2} · det(I − A·u + q·u²·I)`.

The nontrivial poles of `ζ_G` are the reciprocals of the roots of the *spectral* determinant
`det(I − A u + q u² I)`, which factors over the adjacency spectrum `{λ_i}` as a product of the
local **Euler factors**

  `p(λ, q, u) = 1 − λ·u + q·u²`,

one per eigenvalue.  Each such factor has the exact shape of the Euler factor of an elliptic
curve `1 − a·T + p·T²`.

Where the companion file `IharaZeta` studies a *single* local factor, this file assembles the
factors into the **global** spectral zeta

  `Z⁻¹(u) = ∏_i (1 − λ_i·u + q·u²)`

and lifts the local number theory to the whole graph.  The headline is a genuine equivalence:

  **`ζ_G` satisfies the Riemann Hypothesis  ⇔  `G` is a Ramanujan graph**,

i.e. *every* zero of the global spectral zeta lies on the critical circle `|u| = 1/√q` **iff**
every eigenvalue obeys the Ramanujan bound `λ² ≤ 4q`.

## Main results

* `zetaInv_zero` — normalization `Z⁻¹(0) = 1`.
* `zetaInv_union` — **Euler-product multiplicativity** over a disjoint union of spectra:
  `Z⁻¹_{s ⊔ t} = Z⁻¹_s · Z⁻¹_t`, the graph analogue of the factorization of a Dedekind zeta.
* `zetaInv_funeq` — the **global functional equation** `(q u²)^n · Z⁻¹(1/(q u)) = Z⁻¹(u)`.
* `zetaInv_global_RH` — **Ramanujan ⇒ RH**: if every eigenvalue satisfies `λ² ≤ 4q` then every
  zero of `Z⁻¹` lies on the critical circle `|u| = 1/√q`.
* `zetaInv_offCircle_ne_zero` — the nonvanishing reformulation: off the critical circle `Z⁻¹` has
  no zeros.
* `zetaInv_RH_fails_of_nonRamanujan` — **converse**: if some eigenvalue violates the Ramanujan
  bound (`λ² > 4q`) then `Z⁻¹` has a zero *off* the critical circle, so RH fails.
* `zetaInv_RH_iff_ramanujan` — the equivalence **RH ⇔ Ramanujan** for the whole graph.
-/

namespace Novelty.GraphZetaGlobalRH

open scoped Real
open Finset

/-- The Bass–Ihara **local factor** at a spectral value `λ` of a `(q+1)`-regular graph:
`p(λ, q, u) = 1 − λ·u + q·u²`.  It has the shape of an elliptic-curve Euler factor with
"trace of Frobenius" `λ` and "residue characteristic" `q`. -/
def factor (l q u : ℂ) : ℂ := 1 - l * u + q * u ^ 2

/-- The **global spectral Ihara zeta** (reciprocal) of a graph with spectrum `l : ι → ℂ`
supported on `s`: the product of the local Euler factors, `Z⁻¹(u) = ∏_{i ∈ s} (1 − λ_i u + q u²)`.
This is `det(I − A u + q u² I)` expressed over the spectrum. -/
def zetaInv {ι : Type*} (s : Finset ι) (l : ι → ℂ) (q u : ℂ) : ℂ :=
  ∏ i ∈ s, factor (l i) q u

/-
**Normalization.** The spectral zeta is normalized to `Z⁻¹(0) = 1`.
-/
theorem zetaInv_zero {ι : Type*} (s : Finset ι) (l : ι → ℂ) (q : ℂ) :
    zetaInv s l q 0 = 1 := by
  unfold zetaInv factor; aesop;

/-
**Euler-product multiplicativity.** Over a disjoint union of spectra the spectral zeta
factors, `Z⁻¹_{s ⊔ t} = Z⁻¹_s · Z⁻¹_t` — the graph-theoretic analogue of the multiplicativity of
a Dedekind zeta function over its primes.
-/
theorem zetaInv_union {ι : Type*} [DecidableEq ι] (s t : Finset ι) (hst : Disjoint s t)
    (l : ι → ℂ) (q u : ℂ) :
    zetaInv (s ∪ t) l q u = zetaInv s l q u * zetaInv t l q u := by
  unfold zetaInv; rw [ Finset.prod_union hst ] ;

/-
**Functional equation of the local factor.** Under the Ihara reflection `u ↦ 1/(q u)` the
local factor is reproduced up to the automorphy factor `q u²`.
-/
theorem factor_funeq (l q u : ℂ) (hq : q ≠ 0) (hu : u ≠ 0) :
    q * u ^ 2 * factor l q (1 / (q * u)) = factor l q u := by
  unfold factor
  field_simp [hq, hu]
  ring

/-
**Global functional equation.** The reflection `u ↦ 1/(q u)` reproduces the whole spectral
zeta up to the automorphy factor `(q u²)^n`, where `n = #s` is the number of eigenvalues.
-/
theorem zetaInv_funeq {ι : Type*} (s : Finset ι) (l : ι → ℂ) (q u : ℂ)
    (hq : q ≠ 0) (hu : u ≠ 0) :
    (q * u ^ 2) ^ s.card * zetaInv s l q (1 / (q * u)) = zetaInv s l q u := by
  convert Finset.prod_congr rfl fun i _ => factor_funeq ( l i ) q u hq hu using 1;
  rw [ Finset.prod_mul_distrib, Finset.prod_const, Finset.card_eq_sum_ones ];
  rfl

/-
**Local Riemann Hypothesis (squared form).** If a real eigenvalue `λ` obeys the Ramanujan
bound `λ² ≤ 4q` (`q > 0`), then every complex zero `z` of the local factor lies on the critical
circle: `|z|² = 1/q`.
-/
theorem factor_root_normSq (l q : ℝ) (hq : 0 < q) (hl : l ^ 2 ≤ 4 * q)
    (z : ℂ) (hz : factor (l : ℂ) (q : ℂ) z = 0) :
    Complex.normSq z = 1 / q := by
  unfold factor at hz;
  norm_num [ Complex.ext_iff, sq ] at *;
  by_cases h : z.im = 0 <;> simp_all +decide [ Complex.normSq ];
  · exact eq_inv_of_mul_eq_one_right ( by nlinarith [ sq_nonneg ( l - 2 * q * z.re ) ] );
  · grind

/-
**Non-Ramanujan local factor has an off-circle real zero.** If `λ² > 4q` (`q > 0`), the local
factor has two distinct *real* zeros whose product is `1/q`; at least one of them fails to lie on
the critical circle `|z| = 1/√q`.
-/
theorem factor_offCircle_root (l q : ℝ) (hq : 0 < q) (hl : 4 * q < l ^ 2) :
    ∃ z : ℂ, factor (l : ℂ) (q : ℂ) z = 0 ∧ ‖z‖ ≠ 1 / Real.sqrt q := by
  -- Show that the root $z = \frac{l + \sqrt{l^2 - 4q}}{2q}$ satisfies the conditions.
  use (l + Real.sqrt (l^2 - 4 * q)) / (2 * q);
  unfold factor; norm_cast; simp +decide ; ring_nf ;
  grind

/-
**Global Riemann Hypothesis: Ramanujan ⇒ RH.** If every eigenvalue of the graph satisfies the
Ramanujan bound `λ² ≤ 4q` (`q > 0`), then every zero of the global spectral zeta lies on the
critical circle `|z| = 1/√q`.
-/
theorem zetaInv_global_RH {ι : Type*} (s : Finset ι) (lam : ι → ℝ) (q : ℝ) (hq : 0 < q)
    (hR : ∀ i ∈ s, (lam i) ^ 2 ≤ 4 * q)
    (z : ℂ) (hz : zetaInv s (fun i => (lam i : ℂ)) (q : ℂ) z = 0) :
    ‖z‖ = 1 / Real.sqrt q := by
  -- By definition of $zetaInv$, we know that if $zetaInv s (fun i => (lam i : ℂ)) q z = 0$, then there exists $i \in s$ such that $factor (lam i) q z = 0$.
  obtain ⟨i, hi⟩ : ∃ i ∈ s, factor (lam i : ℂ) q z = 0 := by
    exact Finset.prod_eq_zero_iff.mp hz;
  convert congrArg Real.sqrt ( factor_root_normSq ( lam i ) q hq ( hR i hi.1 ) z hi.2 ) using 1 ; norm_num [ Complex.normSq, Complex.norm_def ]

/-
**Nonvanishing off the critical circle.** Reformulation of `zetaInv_global_RH`: for a Ramanujan
graph the spectral zeta has no zeros off the critical circle `|z| = 1/√q`.
-/
theorem zetaInv_offCircle_ne_zero {ι : Type*} (s : Finset ι) (lam : ι → ℝ) (q : ℝ) (hq : 0 < q)
    (hR : ∀ i ∈ s, (lam i) ^ 2 ≤ 4 * q)
    (z : ℂ) (hz : ‖z‖ ≠ 1 / Real.sqrt q) :
    zetaInv s (fun i => (lam i : ℂ)) (q : ℂ) z ≠ 0 := by
  exact fun h => hz <| by simpa [ hq.le ] using zetaInv_global_RH s lam q hq hR z h;

/-
**Converse: non-Ramanujan ⇒ RH fails.** If some eigenvalue violates the Ramanujan bound
(`λ² > 4q`), then the global spectral zeta has a zero *off* the critical circle.
-/
theorem zetaInv_RH_fails_of_nonRamanujan {ι : Type*} (s : Finset ι) (lam : ι → ℝ) (q : ℝ)
    (hq : 0 < q) (i₀ : ι) (hi₀ : i₀ ∈ s) (hbad : 4 * q < (lam i₀) ^ 2) :
    ∃ z : ℂ, zetaInv s (fun i => (lam i : ℂ)) (q : ℂ) z = 0 ∧ ‖z‖ ≠ 1 / Real.sqrt q := by
  obtain ⟨ z, hz₁, hz₂ ⟩ := factor_offCircle_root ( lam i₀ ) q hq hbad; use z; simp_all +decide [ zetaInv ] ;
  exact Finset.prod_eq_zero hi₀ hz₁

/-
**The Riemann Hypothesis for the graph zeta ⇔ the graph is Ramanujan.**
Every zero of the global spectral Ihara zeta lies on the critical circle `|z| = 1/√q` **iff**
every eigenvalue satisfies the Ramanujan bound `λ² ≤ 4q`.
-/
theorem zetaInv_RH_iff_ramanujan {ι : Type*} (s : Finset ι) (lam : ι → ℝ) (q : ℝ) (hq : 0 < q) :
    (∀ z : ℂ, zetaInv s (fun i => (lam i : ℂ)) (q : ℂ) z = 0 → ‖z‖ = 1 / Real.sqrt q)
      ↔ (∀ i ∈ s, (lam i) ^ 2 ≤ 4 * q) := by
  refine' ⟨ fun h => _, fun h => _ ⟩;
  · intro i hi
    by_contra h_contra
    push_neg at h_contra
    have h_nonram : 4 * q < (lam i) ^ 2 := by
      exact h_contra
    obtain ⟨z, hz0, hznorm⟩ := zetaInv_RH_fails_of_nonRamanujan s lam q hq i hi h_nonram
    exact hznorm (h z hz0);
  · convert zetaInv_global_RH s lam q hq h using 1

/-!
## Concrete instances

The equivalence applied to the adjacency spectra of genuine Ramanujan graphs.
-/

/-- **Petersen graph** (`3`-regular, `q = 2`).  Its full adjacency spectrum is
`{3, 1, 1, 1, 1, 1, -2, -2, -2, -2}`; every eigenvalue lies in the Ramanujan window
`λ² ≤ 8` *except* the trivial Perron eigenvalue `3`.  Restricting to the non-trivial spectrum
`{1, -2}` (the distinct nontrivial eigenvalues), the Riemann Hypothesis holds: every zero of the
global spectral zeta lies on the critical circle `|z| = 1/√2`. -/
example :
    ∀ z : ℂ, zetaInv ({(1 : ℝ), -2} : Finset ℝ) (fun l => (l : ℂ)) (2 : ℂ) z = 0 →
      ‖z‖ = 1 / Real.sqrt 2 := by
  refine (zetaInv_RH_iff_ramanujan ({(1 : ℝ), -2} : Finset ℝ) (fun l => l) 2 (by norm_num)).2 ?_
  intro i hi
  simp only [Finset.mem_insert, Finset.mem_singleton] at hi
  rcases hi with h | h <;> subst h <;> norm_num

/-- **Cycle graph `C₅`** (`2`-regular, `q = 1`).  Its adjacency spectrum consists of the values
`2 cos(2πk/5)`, all within the Ramanujan window `λ² ≤ 4`.  Taking the two nontrivial extremal
values `2cos(2π/5) = (√5-1)/2` and `2cos(4π/5) = -(√5+1)/2`, both satisfy `λ² ≤ 4`, so RH holds on
the unit circle `|z| = 1`.  Here we record the simplest boundary instance: the Perron value `2`
saturates the bound and gives the double root `z = 1` on the unit circle. -/
example :
    ∀ z : ℂ, zetaInv ({(2 : ℝ)} : Finset ℝ) (fun l => (l : ℂ)) (1 : ℂ) z = 0 →
      ‖z‖ = 1 / Real.sqrt 1 := by
  refine (zetaInv_RH_iff_ramanujan ({(2 : ℝ)} : Finset ℝ) (fun l => l) 1 (by norm_num)).2 ?_
  intro i hi
  simp only [Finset.mem_singleton] at hi
  subst hi; norm_num

/-- **Failure of RH off the Ramanujan range.**  A hypothetical `3`-regular graph (`q = 2`) with a
non-trivial eigenvalue `λ = 3` violates the Ramanujan bound (`9 > 8`); the global spectral zeta
then has a zero off the critical circle `|z| = 1/√2`. -/
example :
    ∃ z : ℂ, zetaInv ({(3 : ℝ)} : Finset ℝ) (fun l => (l : ℂ)) (2 : ℂ) z = 0 ∧
      ‖z‖ ≠ 1 / Real.sqrt 2 :=
  zetaInv_RH_fails_of_nonRamanujan ({(3 : ℝ)} : Finset ℝ) (fun l => l) 2 (by norm_num) 3
    (by norm_num) (by norm_num)

end Novelty.GraphZetaGlobalRH