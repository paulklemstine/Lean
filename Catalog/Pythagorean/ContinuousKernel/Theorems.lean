/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Continuous Canonical Kernel Calculus — Theorems

This file proves the main theorems of the continuous canonical kernel calculus
on metric graphs, establishing uniqueness, symmetry, and resistance identities
for the canonical Green kernel.

## Main Results

### Laplacian Infrastructure
* `MetricGraph.laplacian_row_sum_zero` — rows sum to zero (conservation law)
* `MetricGraph.laplacian_symm` — Laplacian is symmetric
* `MetricGraph.lapply_const` — constants are in the kernel
* `MetricGraph.lapply_add` — linearity: L(f+g) = Lf + Lg
* `MetricGraph.lapply_sub` — linearity: L(f-g) = Lf - Lg

### Energy Theory
* `MetricGraph.energy_nonneg` — E(f) ≥ 0
* `MetricGraph.energy_eq_zero_iff_const` — E(f) = 0 ↔ f is constant (connected)
* `MetricGraph.energy_strict_pos_of_nonconstant` — E(f) > 0 for non-constant f
* `MetricGraph.energyBilin_symm` — symmetry of energy bilinear form
* `MetricGraph.energyBilin_eq_sum_fLg` — E(f,g) = Σ f(v)·(Lg)(v)

### Canonical Kernel Theorems
* `CanonicalKernel.greenIdentity` — **Green's identity**: ⟨g_p, f⟩_E = f(p) for
    mean-zero f (Theorem 1 — the master identity)
* `CanonicalKernel.kernel_symm` — **Kernel symmetry**: g(p,q) = g(q,p)
    (Theorem 2 — follows from Green's identity)
* `CanonicalKernel.unique` — **Uniqueness**: any two canonical kernels agree
    (Theorem 3 — from energy positivity)

### Cross-Domain: Resistance–Energy Duality
* `CanonicalKernel.resistance_eq_dipole_energy` — **Resistance–energy identity**:
    r(p,q) = E(g_p − g_q) (Theorem 4 — bridges tropical geometry to
    electrical network theory and quantum graph spectral theory)

## References

* Baker–Faber, "Metrized graphs, Laplacian operators, and electrical networks" (2006)
-/

import Pythagorean.ContinuousKernel.Defs

open Finset BigOperators

/-! ## Section 1: Laplacian Properties -/

namespace MetricGraph

variable (Γ : MetricGraph)

/-
Each row of the Laplacian sums to zero: the conservation law.
-/
theorem laplacian_row_sum_zero (i : Γ.V) :
    ∑ j : Γ.V, Γ.laplacian i j = 0 := by
      unfold MetricGraph.laplacian;
      simp +decide [ Finset.sum_ite, Finset.filter_eq, Finset.filter_ne ];
      rw [ Finset.filter_erase ] ; aesop

/-
The Laplacian is symmetric when weights are symmetric.
-/
theorem laplacian_symm (i j : Γ.V) :
    Γ.laplacian i j = Γ.laplacian j i := by
      by_cases hij : i = j <;> simp_all +decide [ MetricGraph.laplacian, SimpleGraph.adj_comm ];
      split_ifs <;> simp_all +singlePass [ MetricGraph.w_symm ]

/-
Constant functions lie in the Laplacian kernel.
-/
theorem lapply_const (c : ℝ) (v : Γ.V) :
    Γ.lapply (fun _ => c) v = 0 := by
      convert congr_arg ( fun x : ℝ => x * c ) ( MetricGraph.laplacian_row_sum_zero Γ v ) using 1 ; ring!;
      · rw [ Finset.sum_mul _ _ _ ] ; rfl;
      · ring

/-
Linearity: L(f + g) = Lf + Lg.
-/
theorem lapply_add (f g : Γ.V → ℝ) (v : Γ.V) :
    Γ.lapply (f + g) v = Γ.lapply f v + Γ.lapply g v := by
      unfold MetricGraph.lapply;
      simp +decide [ mul_add, Finset.sum_add_distrib ]

/-
Linearity: L(f - g) = Lf - Lg.
-/
theorem lapply_sub (f g : Γ.V → ℝ) (v : Γ.V) :
    Γ.lapply (f - g) v = Γ.lapply f v - Γ.lapply g v := by
      unfold MetricGraph.lapply;
      simp +decide only [Pi.sub_apply, mul_sub, sum_sub_distrib]

/-
Linearity: L(c • f) = c • Lf.
-/
theorem lapply_smul (c : ℝ) (f : Γ.V → ℝ) (v : Γ.V) :
    Γ.lapply (c • f) v = c * Γ.lapply f v := by
      unfold MetricGraph.lapply;
      simp +decide [ mul_assoc, mul_left_comm, Finset.mul_sum _ _ _ ]

/-
Total Laplacian output sums to zero: Σ_v (Lf)(v) = 0.
-/
theorem lapply_total_sum_zero (f : Γ.V → ℝ) :
    ∑ v : Γ.V, Γ.lapply f v = 0 := by
      unfold MetricGraph.lapply;
      rw [ Finset.sum_comm, Finset.sum_congr rfl fun _ _ => ?_ ];
      convert Finset.sum_const_zero;
      convert congr_arg ( fun x : ℝ => x * f ‹_› ) ( laplacian_row_sum_zero Γ ‹_› ) using 1 ; ring;
      · rw [ Finset.mul_sum _ _ _, Finset.sum_congr rfl ] ; intros ; rw [ laplacian_symm ] ; ring;
      · ring

/-! ## Section 2: Energy Theory -/

/-
The energy bilinear form equals Σ_v f(v) · (Lg)(v).
-/
theorem energyBilin_eq_sum_fLg (f g : Γ.V → ℝ) :
    Γ.energyBilin f g = ∑ v : Γ.V, f v * Γ.lapply g v := by
      unfold MetricGraph.energyBilin MetricGraph.lapply;
      simp +decide only [mul_assoc, mul_left_comm, Finset.mul_sum _ _ _]

/-
The energy bilinear form is symmetric.
-/
theorem energyBilin_symm (f g : Γ.V → ℝ) :
    Γ.energyBilin f g = Γ.energyBilin g f := by
      unfold MetricGraph.energyBilin;
      rw [ Finset.sum_comm ];
      exact Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by rw [ MetricGraph.laplacian_symm ] ; ring;

/-
The self-pairing equals the Dirichlet energy.
-/
theorem energyBilin_self (f : Γ.V → ℝ) :
    Γ.energyBilin f f = Γ.energy f := rfl

/-
Dirichlet energy is non-negative.
-/
theorem energy_nonneg (f : Γ.V → ℝ) :
    0 ≤ Γ.energy f := by
      -- Rewrite the energy using the definition of the Laplacian matrix.
      have h_energy_def : Γ.energy f = ∑ i, ∑ j, (-Γ.laplacian i j) * (f i - f j)^2 / 2 := by
        have h_expand : Γ.energy f = (1 / 2) * ∑ i, ∑ j, -(Γ.laplacian i j) * (f i - f j)^2 := by
          have h_expand : ∀ i j, Γ.laplacian i j * f i * f j = -(Γ.laplacian i j) * (f i - f j)^2 / 2 + (Γ.laplacian i j) * f i^2 / 2 + (Γ.laplacian i j) * f j^2 / 2 := by
            intro i j; ring;
          convert Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => h_expand i j using 1;
          simp +decide [ Finset.sum_add_distrib, ← Finset.mul_sum _ _ _, ← Finset.sum_div, div_eq_inv_mul ];
          simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, laplacian_row_sum_zero ];
          convert MetricGraph.lapply_total_sum_zero Γ ( fun i => f i ^ 2 ) using 1;
        simpa only [ one_div, inv_mul_eq_div, Finset.mul_sum _ _ _, Finset.sum_div ] using h_expand;
      rw [ h_energy_def ];
      -- Since $-Γ.laplacian i j$ is non-negative for all $i$ and $j$, and $(f i - f j)^2$ is non-negative, their product is non-negative.
      have h_nonneg : ∀ i j, 0 ≤ -Γ.laplacian i j * (f i - f j)^2 := by
        unfold MetricGraph.laplacian;
        intro i j; split_ifs <;> simp_all +decide [ MetricGraph.w_pos ] ;
        positivity;
      exact Finset.sum_nonneg fun i hi => Finset.sum_nonneg fun j hj => div_nonneg ( h_nonneg i j ) zero_le_two

/-
On a connected graph, E(f) = 0 if and only if f is constant.
-/
theorem energy_eq_zero_iff_const (f : Γ.V → ℝ) (hconn : Γ.G.Connected) :
    Γ.energy f = 0 ↔ ∃ c : ℝ, f = fun _ => c := by
      constructor <;> intro h;
      · -- Since $E(f) = 0$, we have $\sum_{i,j} (-L(i,j)) (f(i) - f(j))^2 = 0$.
        have h_sum_zero : ∑ i, ∑ j, (-Γ.laplacian i j) * (f i - f j) ^ 2 = 0 := by
          convert congr_arg ( · * 2 ) h using 1 <;> ring!;
          unfold MetricGraph.energy;
          simp +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, sq ];
          simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, MetricGraph.laplacian_row_sum_zero ];
          convert MetricGraph.lapply_total_sum_zero Γ ( fun x => f x * f x ) using 1;
        -- Since $L(i,j) < 0$ for adjacent $i$ and $j$, we have $f(i) = f(j)$ for all adjacent $i$ and $j$.
        have h_adj_eq : ∀ i j, Γ.G.Adj i j → f i = f j := by
          have h_adj_eq : ∀ i j, Γ.G.Adj i j → (-Γ.laplacian i j) * (f i - f j) ^ 2 = 0 := by
            have h_each_zero : ∀ i j, -Γ.laplacian i j * (f i - f j) ^ 2 ≥ 0 := by
              unfold MetricGraph.laplacian;
              intro i j; split_ifs <;> simp_all +decide [ MetricGraph.w_pos ] ;
              positivity;
            exact fun i j hij => le_antisymm ( le_trans ( Finset.single_le_sum ( fun i _ => Finset.sum_nonneg fun j _ => h_each_zero i j ) ( Finset.mem_univ i ) |> le_trans ( Finset.single_le_sum ( fun j _ => h_each_zero i j ) ( Finset.mem_univ j ) ) ) h_sum_zero.le ) ( h_each_zero i j );
          simp_all +decide [ sub_eq_iff_eq_add, MetricGraph.laplacian ];
          exact fun i j hij => Or.resolve_left ( h_adj_eq i j hij hij.ne ) ( ne_of_gt ( Γ.w_pos i j hij ) );
        have h_const : ∀ i j, Γ.G.Reachable i j → f i = f j := by
          intros i j hij
          induction' hij with i j hij ih;
          induction i <;> [ rfl; linarith [ h_adj_eq _ _ ‹_› ] ];
        exact ⟨ f ( Classical.choose ( Finset.card_pos.mp ( Fintype.card_pos_iff.mpr ⟨ Classical.choose ( show ∃ x : Γ.V, True from by
                                                                                                            simp +zetaDelta at *;
                                                                                                            grind +splitIndPred ) ⟩ ) ) ), funext fun x => h_const _ _ ( hconn _ _ ) ⟩;
      · -- If f is constant, � then� each term in the sum is zero because the Laplacian of a constant function is zero.
        obtain ⟨c, hc⟩ := h;
        simp [hc, MetricGraph.energy];
        simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, MetricGraph.laplacian_row_sum_zero ]

/-
**Energy strict positivity**: on a connected graph, any non-constant
    function has strictly positive Dirichlet energy.

    This is the analytic engine behind uniqueness: the energy form
    is strictly convex modulo constants, so the normalized kernel
    is a strict minimizer.

    The proof proceeds by contradiction: if E(f) = 0, then by
    `energy_eq_zero_iff_const`, f must be constant, contradicting
    the hypothesis.
-/
theorem energy_strict_pos_of_nonconstant
    (f : Γ.V → ℝ) (hconn : Γ.G.Connected)
    (hnonconst : ¬∃ c : ℝ, f = fun _ => c) :
    0 < Γ.energy f := by
      exact lt_of_le_of_ne ( MetricGraph.energy_nonneg Γ f ) ( Ne.symm <| by contrapose! hnonconst; exact MetricGraph.energy_eq_zero_iff_const Γ f hconn |>.1 hnonconst )

/-
Bilinearity: E(f+g, h) = E(f,h) + E(g,h).
-/
theorem energyBilin_add_left (f g h : Γ.V → ℝ) :
    Γ.energyBilin (f + g) h = Γ.energyBilin f h + Γ.energyBilin g h := by
      unfold MetricGraph.energyBilin;
      simpa only [ ← sum_add_distrib ] using Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by rw [ Pi.add_apply ] ; ring;

/-
Bilinearity: E(f, g+h) = E(f,g) + E(f,h).
-/
theorem energyBilin_add_right (f g h : Γ.V → ℝ) :
    Γ.energyBilin f (g + h) = Γ.energyBilin f g + Γ.energyBilin f h := by
      unfold MetricGraph.energyBilin;
      simp +decide only [Pi.add_apply, mul_add, sum_add_distrib]

/-
Bilinearity: E(c·f, g) = c·E(f,g).
-/
theorem energyBilin_smul_left (c : ℝ) (f g : Γ.V → ℝ) :
    Γ.energyBilin (c • f) g = c * Γ.energyBilin f g := by
      convert energyBilin_eq_sum_fLg Γ ( c • f ) g using 1;
      convert congr_arg ( fun x : ℝ => c * x ) ( energyBilin_eq_sum_fLg Γ f g ) using 1 ; ring;
      simp +decide [ mul_assoc, Finset.mul_sum _ _ _ ]

/-
Bilinearity: E(f-g, h) = E(f,h) - E(g,h).
-/
theorem energyBilin_sub_left (f g h : Γ.V → ℝ) :
    Γ.energyBilin (f - g) h = Γ.energyBilin f h - Γ.energyBilin g h := by
      unfold MetricGraph.energyBilin;
      simp +decide only [Pi.sub_apply, mul_sub, sub_mul, sum_sub_distrib]

/-
A globally harmonic function on a connected graph with mean zero is identically zero.
-/
theorem harmonic_meanZero_eq_zero
    (f : Γ.V → ℝ) (hconn : Γ.G.Connected)
    (hharm : Γ.isHarmonic f) (hmean : Γ.meanZero f) :
    f = fun _ => (0 : ℝ) := by
      have h_energy_zero : Γ.energy f = 0 := by
        convert energyBilin_eq_sum_fLg Γ f f using 1;
        rw [ Finset.sum_congr rfl fun _ _ => by rw [ hharm ] ] ; norm_num;
      have := MetricGraph.energy_eq_zero_iff_const Γ f hconn; simp_all +decide [ funext_iff ] ;
      cases isEmpty_or_nonempty Γ.V <;> simp_all +decide [ MetricGraph.meanZero ];
      aesop

end MetricGraph

/-! ## Section 3: Canonical Kernel — Green's Identity -/

namespace CanonicalKernel

variable {Γ : MetricGraph} (K : CanonicalKernel Γ)

/-
**Green's identity for the canonical kernel** (Theorem 1).

    For any mean-zero function `f`, the energy pairing of the kernel
    column `g_p` with `f` equals `f(p)`.

    This is the master identity from which symmetry, resistance formulas,
    and Abel–Jacobi compatibility all follow. It says that the canonical
    kernel is the reproducing kernel for the energy inner product on the
    space of mean-zero functions.

    **Proof sketch**: By `energyBilin_eq_sum_fLg`,
      `⟨g_p, f⟩_E = Σ_v g_p(v) · (Lf)(v)`.
    By `energyBilin_symm`, this also equals
      `Σ_v f(v) · (Lg_p)(v) = Σ_v f(v) · (δ_p(v) - 1/n)`.
    The δ_p term gives `f(p)`. The uniform term gives `-(1/n)·Σ f(v) = 0`
    by mean-zero.
-/
theorem greenIdentity
    (p : Γ.V) (f : Γ.V → ℝ) (hf : Γ.meanZero f) :
    Γ.energyBilin (K.g p) f = f p := by
      convert MetricGraph.energyBilin_eq_sum_fLg Γ f ( K.g p ) using 1;
      · exact?;
      · simp +decide [ K.lap_col ];
        simp +decide [ mul_sub, Finset.sum_sub_distrib ];
        simp_all +decide [ ← Finset.sum_mul _ _ _, MetricGraph.meanZero ]

/-
**Kernel symmetry** (Theorem 2).

    The canonical kernel is symmetric: `g(p, q) = g(q, p)`.

    This follows from Green's identity applied twice:
    - `g(p, q) = ⟨g_q, g_p⟩_E` (by Green's identity for g_q at p, using mean_col)
    - `g(q, p) = ⟨g_p, g_q⟩_E` (by Green's identity for g_p at q, using mean_col)
    - These are equal by `energyBilin_symm`.
-/
theorem kernel_symm (p q : Γ.V) :
    K.g p q = K.g q p := by
      have h_symm : ∀ p q, K.g p q = Γ.energyBilin (K.g q) (K.g p) := by
        intro p q;
        rw [ greenIdentity ];
        exact K.mean_col p;
      rw [ h_symm, h_symm, MetricGraph.energyBilin_symm ]

/-
**Uniqueness of canonical kernel** (Theorem 3).

    Any two canonical kernels on the same metric graph agree,
    provided the graph is connected.

    **Proof**: Let `K₁` and `K₂` be two canonical kernels. For each `p`,
    the difference `h = K₁.g p - K₂.g p` satisfies:
    - `Δh = 0` (both solve the same Laplacian equation)
    - `Σ h(v) = 0` (both are mean-zero)
    By `harmonic_meanZero_eq_zero` on connected graphs, `h = 0`.
-/
theorem unique (K' : CanonicalKernel Γ) (hconn : Γ.G.Connected) :
    K.g = K'.g := by
      ext p q;
      -- By definition of harmonic mean-zero functions, we have $h = K.g p - K'.g p$ is harmonic and has mean zero.
      have h_harmonic : Γ.isHarmonic (K.g p - K'.g p) := by
        intro v; have := K.lap_col p v; have := K'.lap_col p v; simp_all +decide [ MetricGraph.lapply ] ;
        simp_all +decide [ mul_sub ]
      have h_mean_zero : Γ.meanZero (K.g p - K'.g p) := by
        convert sub_eq_zero.mpr ( sub_eq_zero.mpr <| K.mean_col p |> Eq.trans <| ( K'.mean_col p |> Eq.symm ) ) using 1;
        unfold MetricGraph.meanZero; aesop;
      exact sub_eq_zero.mp ( congr_fun ( MetricGraph.harmonic_meanZero_eq_zero _ _ hconn h_harmonic h_mean_zero ) q )

/-! ## Section 4: Cross-Domain — Resistance–Energy Duality -/

/-
**Resistance equals dipole energy** (Theorem 4 — Cross-Domain).

    The effective resistance between `p` and `q` equals the Dirichlet
    energy of the dipole potential `g_p - g_q`.

    This theorem bridges three domains:
    1. **Tropical geometry**: the kernel columns are tropical Green functions
    2. **Electrical networks**: resistance is the energy cost of unit current flow
    3. **Quantum graphs**: resistance controls the zero-frequency resolvent

    **Proof**: Using bilinearity and Green's identity,
      `E(g_p - g_q) = E(g_p) - 2·E(g_p, g_q) + E(g_q)`
                    `= g_p(p) - 2·g_p(q) + g_q(q)`
                    `= g(p,p) + g(q,q) - 2·g(p,q)`
                    `= r(p,q)`.
-/
theorem resistance_eq_dipole_energy (p q : Γ.V) :
    K.effectiveResistance p q = Γ.energy (K.dipolePotential p q) := by
      -- We need to prove that the effective resistance between `p` and `q` equals the Dirichlet energy of the dipole potential `g_p - g_q`.
      have hCross : K.effectiveResistance p q = Γ.energyBilin (K.g p - K.g q) (K.g p - K.g q) := by
        have hCross : Γ.energyBilin (K.g p) (K.g p) - 2 * Γ.energyBilin (K.g p) (K.g q) + Γ.energyBilin (K.g q) (K.g q) = K.effectiveResistance p q := by
          -- Apply Green's identity to each term in the sum.
          have h_green_p : Γ.energyBilin (K.g p) (K.g p) = K.g p p := by
            convert greenIdentity K p ( K.g p ) ( K.mean_col p ) using 1
          have h_green_q : Γ.energyBilin (K.g q) (K.g q) = K.g q q := by
            convert greenIdentity K q ( K.g q ) ( K.mean_col q ) using 1
          have h_green_pq : Γ.energyBilin (K.g p) (K.g q) = K.g q p := by
            convert greenIdentity K p ( K.g q ) ( K.mean_col q ) using 1;
          linarith [ K.kernel_symm p q, show K.effectiveResistance p q = K.g p p + K.g q q - 2 * K.g p q from rfl ];
        grind +suggestions;
      exact hCross.trans ( MetricGraph.energyBilin_self _ _ )

/-
The effective resistance is symmetric.
-/
theorem effectiveResistance_symm (p q : Γ.V) :
    K.effectiveResistance p q = K.effectiveResistance q p := by
      unfold CanonicalKernel.effectiveResistance; ring;
      grind +suggestions

/-
The effective resistance to self is zero.
-/
theorem effectiveResistance_self (p : Γ.V) :
    K.effectiveResistance p p = 0 := by
      unfold CanonicalKernel.effectiveResistance;
      ring

end CanonicalKernel