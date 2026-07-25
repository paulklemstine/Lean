/-
# Spectral Depth Thresholds for Hodge-Laplacian Message Passing

A rigorous, sorry-free linear-algebraic skeleton for the conjecture
*"Spectral Universality Threshold for Hypergraph Neural Tangent Kernels on
Simplicial Complexes."*

We model one layer of linearized / infinite-width message passing on `k`-cochains
as the self-adjoint operator `T = 1 - t·Δ`, where `Δ = up + down` is the abstract
combinatorial **Hodge Laplacian** — the sum of a positive-semidefinite upper
Laplacian (`δδ*`) and a positive-semidefinite lower Laplacian (`d*d`).  Depth-`L`
message passing is the iterate `Tᴸ`.

Two halves of the conjecture become theorems:

* **Topology is depth-invariant.**  The harmonic subspace `ker Δ` (= cohomology, by
  discrete Hodge theory) consists of exact fixed points of `Tᴸ` at every depth, is
  characterised intrinsically as `ker Δ = ker up ⊓ ker down`, and its orthogonal
  complement is `T`-invariant.
* **Everything non-harmonic is geometrically suppressed.**  After diagonalisation a
  mode of eigenvalue `λ ≥ μ > 0` evolves by `(1 - tλ)ᴸ ≤ (1 - tμ)ᴸ → 0`, giving an
  explicit, spectrum-uniform depth threshold `L_c`.

-- !-- Lab Notebook -- !--
Hypothesis:  "Depth in Hodge-Laplacian message passing acts as a low-pass filter on
  the combinatorial spectrum whose only fixed amplitudes are the topological
  (harmonic) ones; the transition scale is set explicitly by the spectral gap."
Result:  Formalised and proved, with no finite-dimensionality assumption needed.
  `psd_inner_self_eq_zero` (Hodge vanishing), `harmonic_iff` / `ker_hodgeLaplacian`
  (harmonic = closed ∧ coclosed), `harmonic_depth_invariant` (exact fixed points at
  every depth), `harmonic_orthogonal_invariant` (T-invariance of `(ker Δ)ᗮ`),
  `mode_decay` / `gap_mode_tendsto_zero` / `depth_threshold` (uniform geometric
  suppression of non-harmonic modes), and `harmonic_mode_invariant` (harmonic modes
  stay at amplitude 1).
Insight:  The vanishing principle `⟪Δx,x⟫ = 0 ⇒ Δx = 0` for a symmetric PSD operator
  needs only a 1-parameter quadratic positivity argument (Cauchy–Schwarz for
  semidefinite forms), so the entire harmonic-side theory is dimension-free.  The
  spectral-gap side decouples completely into scalar real-analysis on `(1 - tμ)ᴸ`.
Failure analysis:  An earlier attempt phrased `T` via `LinearMap.id`, which left the
  scalar/identity type ambiguous on application; using the monoid identity `1` of
  `Module.End ℝ E` fixes elaboration.  The cross term in the quadratic expansion
  needs `real_inner_comm`, not just operator symmetry.
-- !-- Lab Notebook -- !--
-/
import Mathlib

open scoped InnerProductSpace BigOperators Topology

namespace HodgeSpectralThreshold

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-! ## The Hodge vanishing principle -/

/-
!-- comment: For a symmetric PSD operator `S`, the Dirichlet energy `⟪Sx,x⟫`
controls `S` via Cauchy–Schwarz for semidefinite forms, so zero energy kills `Sx`. -- !--

**Hodge vanishing principle.** If `S` is symmetric and positive semidefinite and
the Dirichlet energy `⟪S x, x⟫` vanishes, then `S x = 0`.
-/
theorem psd_inner_self_eq_zero (S : E →ₗ[ℝ] E)
    (hsymm : ∀ x y, ⟪S x, y⟫_ℝ = ⟪x, S y⟫_ℝ)
    (hpos : ∀ x, 0 ≤ ⟪S x, x⟫_ℝ)
    {x : E} (hx : ⟪S x, x⟫_ℝ = 0) : S x = 0 := by
  -- For every real s, by positivity hpos (x + s • y) ≥ 0. Expand using bilinearity and symmetry: ⟪S (x + s•y), x + s•y⟫_ℝ = ⟪S x, x⟫_ℝ + 2*s*⟪S x, y⟫_ℝ + s^2 * ⟪S y, y⟫_ℝ.
  have h_expand : ∀ s : ℝ, 0 ≤ 2 * s * ⟪S x, x⟫_ℝ + s^2 * ⟪S x, x⟫_ℝ := by
    aesop;
  contrapose! h_expand;
  -- By the properties of the inner product and the symmetry of $S$, we have $⟪S x, y⟫_ℝ = ⟪x, S y⟫_ℝ$ for all $y$.
  have h_inner_symm : ∀ y : E, ⟪S x, y⟫_ℝ = 0 := by
    intro y
    have h_inner_zero : ∀ s : ℝ, 0 ≤ 2 * s * ⟪S x, y⟫_ℝ + s^2 * ⟪S y, y⟫_ℝ := by
      intro s
      have := hpos (x + s • y)
      simp_all +decide [ inner_add_left, inner_add_right, inner_smul_left, inner_smul_right ];
      convert this using 1 ; rw [ ← hsymm ] ; ring;
      grind +suggestions;
    by_cases hy : ⟪S y, y⟫_ℝ = 0;
    · contrapose! h_inner_zero;
      exact ⟨ -1 / ⟪S x, y⟫_ℝ, by rw [ hy ] ; ring_nf; norm_num [ h_inner_zero ] ⟩;
    · nlinarith [ h_inner_zero ( -⟪S x, y⟫_ℝ / ⟪S y, y⟫_ℝ ), mul_div_cancel₀ ( -⟪S x, y⟫_ℝ ) hy, hpos y ];
  exact absurd ( h_inner_symm ( S x ) ) ( by simp +decide [ h_expand ] )

/-! ## Harmonic = closed and coclosed -/

variable (up down : E →ₗ[ℝ] E)

/-- The abstract combinatorial **Hodge Laplacian** `Δ = up + down`. -/
def hodgeLaplacian : E →ₗ[ℝ] E := up + down

/-
!-- comment: With `up, down` symmetric PSD, `⟪Δx,x⟫ = ⟪up x,x⟫ + ⟪down x,x⟫` is a
sum of nonnegatives, so it vanishes iff each does; apply the vanishing principle. -- !--

**Harmonic = closed ∧ coclosed.** A cochain is harmonic (`Δ x = 0`) iff it is both
in the kernel of the upper and the lower Laplacian.
-/
theorem harmonic_iff
    (hsymm_up : ∀ x y, ⟪up x, y⟫_ℝ = ⟪x, up y⟫_ℝ)
    (hpos_up : ∀ x, 0 ≤ ⟪up x, x⟫_ℝ)
    (hsymm_down : ∀ x y, ⟪down x, y⟫_ℝ = ⟪x, down y⟫_ℝ)
    (hpos_down : ∀ x, 0 ≤ ⟪down x, x⟫_ℝ)
    (x : E) :
    hodgeLaplacian up down x = 0 ↔ up x = 0 ∧ down x = 0 := by
  constructor <;> intro h;
  · -- By the properties of the inner product and the definition of the Hodge Laplacian, we have:
    have h_inner : ⟪up x, x⟫_ℝ + ⟪down x, x⟫_ℝ = 0 := by
      convert congr_arg ( fun y => ⟪y, x⟫_ℝ ) h using 1 <;> simp +decide [ *, hodgeLaplacian ];
      rw [ ← hsymm_up, ← hsymm_down, inner_add_left ];
    exact ⟨ psd_inner_self_eq_zero up hsymm_up hpos_up ( by linarith [ hpos_up x, hpos_down x ] ), psd_inner_self_eq_zero down hsymm_down hpos_down ( by linarith [ hpos_up x, hpos_down x ] ) ⟩;
  · unfold hodgeLaplacian; aesop;

/-
!-- comment: Pointwise rephrasing of `harmonic_iff` as an equality of submodules. -- !--

**Discrete Hodge harmonics.** `ker Δ = ker up ⊓ ker down`.
-/
theorem ker_hodgeLaplacian
    (hsymm_up : ∀ x y, ⟪up x, y⟫_ℝ = ⟪x, up y⟫_ℝ)
    (hpos_up : ∀ x, 0 ≤ ⟪up x, x⟫_ℝ)
    (hsymm_down : ∀ x y, ⟪down x, y⟫_ℝ = ⟪x, down y⟫_ℝ)
    (hpos_down : ∀ x, 0 ≤ ⟪down x, x⟫_ℝ) :
    LinearMap.ker (hodgeLaplacian up down)
      = LinearMap.ker up ⊓ LinearMap.ker down := by
  exact SetLike.ext fun x => by simpa using harmonic_iff up down hsymm_up hpos_up hsymm_down hpos_down x;

/-! ## Depth-`L` message passing and topology invariance -/

/-- One linearized message-passing layer `T = 1 - t·Δ` on cochains. -/
def layer (t : ℝ) : E →ₗ[ℝ] E := (1 : Module.End ℝ E) - t • hodgeLaplacian up down

@[simp] theorem layer_apply (t : ℝ) (x : E) :
    layer up down t x = x - t • (hodgeLaplacian up down x) := by
  simp [layer]

/-- Depth-`L` message passing is the `L`-fold iterate `Tᴸ`. -/
def depthMap (t : ℝ) (L : ℕ) : E →ₗ[ℝ] E := (layer up down t) ^ L

/-
!-- comment: If `Δ x = 0` then one layer fixes `x` (`T x = x - t·0 = x`); iterate by
induction on the depth `L`. -- !--

**Topology is depth-invariant.** A harmonic cochain is an exact fixed point of
depth-`L` message passing at every depth `L`.
-/
theorem harmonic_depth_invariant (t : ℝ) {x : E}
    (hx : hodgeLaplacian up down x = 0) (L : ℕ) :
    depthMap up down t L x = x := by
  -- By definition of composition of linear maps, we can write
  have h_comp : ((layer up down t) ^ L) x = (layer up down t ^ L) x := by
    rfl;
  exact h_comp.trans ( Nat.recOn L ( by simp +decide ) fun n ihn => by simp +decide [ *, pow_succ' ] )

/-
!-- comment: For `y ∈ ker Δ`, symmetry of `Δ` gives `⟪Δx,y⟫ = ⟪x,Δy⟫ = 0`, and
`x ⟂ y`, so `T x = x - t·Δx` is still orthogonal to all of `ker Δ`. -- !--

**`T`-invariance of the non-harmonic block.** The orthogonal complement of the
harmonic space `ker Δ` is invariant under one message-passing layer `T = 1 - t·Δ`.
-/
theorem harmonic_orthogonal_invariant (t : ℝ)
    (hsymm : ∀ x y, ⟪hodgeLaplacian up down x, y⟫_ℝ
                      = ⟪x, hodgeLaplacian up down y⟫_ℝ)
    {x : E} (hx : x ∈ (LinearMap.ker (hodgeLaplacian up down))ᗮ) :
    layer up down t x ∈ (LinearMap.ker (hodgeLaplacian up down))ᗮ := by
  simp_all +decide [ Submodule.mem_orthogonal', real_inner_comm ];
  grind +suggestions

/-! ## Scalar mode dynamics and the explicit depth threshold -/

/-
!-- comment: With a normalised step (`t·λ ≤ 1`), `0 ≤ 1 - tλ ≤ 1 - tμ`, so raising
to the `L`-th power preserves the inequality. -- !--

**Mode decay is monotone in the eigenvalue.** With a normalised step, a mode of
larger eigenvalue is suppressed at least as fast: `(1 - tλ)ᴸ ≤ (1 - tμ)ᴸ`.
-/
theorem mode_decay {t mu lam : ℝ} (ht : 0 ≤ t)
    (hle : mu ≤ lam) (hnorm : t * lam ≤ 1) (L : ℕ) :
    (1 - t * lam) ^ L ≤ (1 - t * mu) ^ L := by
  exact pow_le_pow_left₀ ( by nlinarith ) ( by nlinarith ) _

/-
!-- comment: A harmonic mode has eigenvalue `λ = 0`, so its amplitude `(1 - t·0)ᴸ`
equals `1` at every depth. -- !--

**Harmonic modes are fixed.** The amplitude of a harmonic (eigenvalue `0`) mode is
`1` at every depth.
-/
theorem harmonic_mode_invariant (t : ℝ) (L : ℕ) :
    (1 - t * (0 : ℝ)) ^ L = 1 := by
  norm_num

/-
!-- comment: With `0 < tμ < 1` we have `|1 - tμ| < 1`, so the geometric sequence
`(1 - tμ)ᴸ` tends to `0`. -- !--

**Geometric suppression.** Every gap mode decays to zero with depth:
`(1 - tμ)ᴸ → 0` as `L → ∞`.
-/
theorem gap_mode_tendsto_zero {t mu : ℝ} (hpos : 0 < t * mu) (hlt : t * mu < 1) :
    Filter.Tendsto (fun L : ℕ => (1 - t * mu) ^ L) Filter.atTop (𝓝 0) := by
  exact tendsto_pow_atTop_nhds_zero_of_lt_one ( by linarith ) ( by linarith )

/-
!-- comment: From `gap_mode_tendsto_zero`, the gap amplitude is eventually `< ε`;
`mode_decay` then suppresses every mode of eigenvalue `≥ μ` below `ε` uniformly. -- !--

**Explicit, spectrum-uniform depth threshold.** Given a spectral gap `μ > 0`, a
normalised step (so every admissible eigenvalue `λ` satisfies `t·λ ≤ 1`) and a
tolerance `ε > 0`, there is a critical depth `L_c` beyond which *every* non-harmonic
mode of eigenvalue `λ ≥ μ` is suppressed below `ε`, while harmonic modes (`λ = 0`)
retain amplitude `1`.
-/
theorem depth_threshold {t mu : ℝ} (ht : 0 < t) (hmu : 0 < mu) (hlt : t * mu < 1)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ L_c : ℕ, ∀ L ≥ L_c, ∀ lam : ℝ, mu ≤ lam → t * lam ≤ 1 →
      (1 - t * lam) ^ L < ε := by
  -- By gap_mode_tendsto_zero, there exists an L_c such that for all L ≥ L_c, (1 - t * mu) ^ L < ε.
  obtain ⟨L_c, hL_c⟩ : ∃ L_c, ∀ L ≥ L_c, (1 - t * mu) ^ L < ε := by
    simpa using ( tendsto_pow_atTop_nhds_zero_of_lt_one ( by nlinarith ) ( by nlinarith : 1 - t * mu < 1 ) ) |> fun h => h.eventually ( gt_mem_nhds hε );
  use L_c; intros L hL lam hlam hlam'; exact lt_of_le_of_lt (by
  exact pow_le_pow_left₀ ( by nlinarith ) ( by nlinarith ) _) (hL_c L hL)

end HodgeSpectralThreshold