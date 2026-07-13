/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Sharp Lower Bounds for Sumsets in L₁ Balls in ℤᵈ — a Cross-Domain Connector

This file builds a **bridge between three areas**:

* **Additive combinatorics** — the Cauchy–Davenport lower bound on sumset
  cardinality in a torsion-free group;
* **Discrete geometry** — L₁ (cross-polytope) balls `{x ∈ ℤᵈ : ∑ |xᵢ| ≤ m}`
  and how their sub-sumsets stay inside a dilated ball;
* **Real analysis** — the transcendental "sharp exponent"
  `p = n·log(m+1) / log(nm+1)`, which is exactly the value making the extremal
  configuration attain equality.

## Setting

Fix a dimension `d`, a radius `m`, and `n` finite nonempty sets
`A₁, …, Aₙ ⊆ {x ∈ ℤᵈ : ∑ᵢ |xᵢ| ≤ m}`.  The *sumset* is
`A₁ + ⋯ + Aₙ = {a₁ + ⋯ + aₙ : aⱼ ∈ Aⱼ}`.

The research target (Becker–Ivanisvili–Krachun–Madrid style) is a lower bound
`|A₁ + ⋯ + Aₙ| ≥ (|A₁| ⋯ |Aₙ|)^{1/p}`.

## Main results

* `iterated_cauchy_davenport` — additive engine:
  `∑ⱼ |Aⱼ| + 1 ≤ |A₁ + ⋯ + Aₙ| + n`, i.e. `|∑ⱼ Aⱼ| ≥ ∑ⱼ|Aⱼ| − (n−1)`.
* `sumset_prod_le_pow` — multiplicative form: `∏ⱼ |Aⱼ| ≤ |A₁ + ⋯ + Aₙ|^n`.
* `sumset_geom_mean_le` — real geometric-mean form:
  `(∏ⱼ |Aⱼ|)^{1/n} ≤ |A₁ + ⋯ + Aₙ|` (the exponent-`n`, i.e. `p = n`, bound).
* `sumset_L1Ball_subset` — geometry: sub-sumsets of the radius-`m` ball land in
  the radius-`nm` ball.
* `pExp` with `pExp_sharp_equality`, `one_le_pExp`, `pExp_le_n` — the
  transcendental exponent, its range `1 ≤ p ≤ n`, and the fact that the extremal
  interval configuration attains equality with exponent `p` (so `p` cannot be
  replaced by anything smaller).
* `extremal_interval_sharp` — the extremal configuration `Aⱼ = {0,…,m}` in `d=1`
  simultaneously attains equality in the additive bound and in the sharp
  exponent bound.
* `L1Ball_sumset_bridge` — the packaged connector theorem combining the additive,
  multiplicative, geometric and geometric-containment statements for the L₁ ball.

None of the statements use `sorry`.
-/

open Finset Pointwise

noncomputable section

namespace SumsetL1Ball

/-! ## Part 1 : Additive engine — iterated Cauchy–Davenport -/

/-- The pointwise sum of finitely many nonempty finite sets is nonempty. -/
theorem sumset_nonempty {G : Type*} [DecidableEq G] [AddCommGroup G]
    {ι : Type*} {s : Finset ι} (A : ι → Finset G)
    (hA : ∀ i ∈ s, (A i).Nonempty) (hs : s.Nonempty) :
    (∑ i ∈ s, A i).Nonempty := by
  induction hs using Finset.Nonempty.cons_induction with
  | singleton a => simpa using hA a (by simp)
  | cons a s ha hs ih =>
      rw [Finset.sum_cons]
      exact (hA a (by simp)).add (ih (fun i hi => hA i (by simp [hi])))

/-- **Iterated Cauchy–Davenport in a torsion-free abelian group.**
For nonempty finite sets `Aᵢ`, `i ∈ s`, we have
`(∑ᵢ |Aᵢ|) + 1 ≤ |∑ᵢ Aᵢ| + |s|`, equivalently `|∑ᵢ Aᵢ| ≥ (∑ᵢ|Aᵢ|) − (|s|−1)`.

This is the additive-combinatorics engine of the whole file: it is proved by
induction from the single-step bound `cauchy_davenport_of_isAddTorsionFree`. -/
theorem iterated_cauchy_davenport {G : Type*} [DecidableEq G] [AddCommGroup G]
    [IsAddTorsionFree G] {ι : Type*} {s : Finset ι} (hs : s.Nonempty)
    (A : ι → Finset G) (hA : ∀ i ∈ s, (A i).Nonempty) :
    (∑ i ∈ s, (A i).card) + 1 ≤ (∑ i ∈ s, A i).card + s.card := by
  induction hs using Finset.Nonempty.cons_induction with
  | singleton a => simp
  | cons a s ha hs ih =>
      have hAa : (A a).Nonempty := hA a (by simp)
      have hA' : ∀ i ∈ s, (A i).Nonempty := fun i hi => hA i (by simp [hi])
      have hsum : (∑ i ∈ s, A i).Nonempty := sumset_nonempty A hA' hs
      have hcd := cauchy_davenport_of_isAddTorsionFree hAa hsum
      simp only [Finset.sum_cons, Finset.card_cons]
      have := ih hA'
      omega

/-! ## Part 2 : Multiplicative form -/

/-- Each factor embeds into the sumset (translation is injective), so
`|Aⱼ| ≤ |∑ᵢ Aᵢ|` for `j ∈ s`. -/
theorem card_A_le_sumset {G : Type*} [DecidableEq G] [AddCommGroup G]
    {ι : Type*} {s : Finset ι} (A : ι → Finset G)
    (hA : ∀ i ∈ s, (A i).Nonempty) {j : ι} (hj : j ∈ s) :
    (A j).card ≤ (∑ i ∈ s, A i).card := by
  classical
  rw [← Finset.add_sum_erase s A hj]
  rcases Finset.eq_empty_or_nonempty (s.erase j) with h | h
  · simp [h]
  · exact Finset.card_le_card_add_right
      (sumset_nonempty A (fun i hi => hA i (Finset.mem_of_mem_erase hi)) h)

/-- **Multiplicative sumset lower bound.**
`∏ᵢ |Aᵢ| ≤ |∑ᵢ Aᵢ|^{|s|}`, i.e. `|∑ᵢ Aᵢ| ≥ (∏ᵢ|Aᵢ|)^{1/|s|}`.  This is the
`p = n` (weakest sharp-shape) instance of the target inequality. -/
theorem sumset_prod_le_pow {G : Type*} [DecidableEq G] [AddCommGroup G]
    {ι : Type*} {s : Finset ι} (A : ι → Finset G)
    (hA : ∀ i ∈ s, (A i).Nonempty) :
    (∏ i ∈ s, (A i).card) ≤ (∑ i ∈ s, A i).card ^ s.card := by
  calc (∏ i ∈ s, (A i).card) ≤ ∏ i ∈ s, (∑ j ∈ s, A j).card :=
        Finset.prod_le_prod' (fun i hi => card_A_le_sumset A hA hi)
    _ = (∑ i ∈ s, A i).card ^ s.card := by rw [Finset.prod_const]

/-! ## Part 3 : Real geometric-mean form -/

/-- Elementary real lemma: `P ≤ Cⁿ` (naturals, `n ≥ 1`) gives `P^{1/n} ≤ C`. -/
theorem rpow_root_le {P C n : ℕ} (hn : 1 ≤ n) (h : P ≤ C ^ n) :
    ((P : ℝ)) ^ ((n : ℝ)⁻¹) ≤ (C : ℝ) := by
  have hn0 : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  rw [show (C : ℝ) = ((C : ℝ) ^ n) ^ ((n : ℝ)⁻¹) by
        rw [← Real.rpow_natCast (C : ℝ) n, ← Real.rpow_mul (by positivity),
          mul_inv_cancel₀ (by positivity), Real.rpow_one]]
  apply Real.rpow_le_rpow (by positivity) _ (by positivity)
  exact_mod_cast h

/-- **Geometric-mean sumset lower bound** (`p = n`):
`(∏ᵢ |Aᵢ|)^{1/n} ≤ |∑ᵢ Aᵢ|`, with `n = |s|`. -/
theorem sumset_geom_mean_le {G : Type*} [DecidableEq G] [AddCommGroup G]
    {ι : Type*} {s : Finset ι} (hs : s.Nonempty) (A : ι → Finset G)
    (hA : ∀ i ∈ s, (A i).Nonempty) :
    ((∏ i ∈ s, (A i).card : ℕ) : ℝ) ^ ((s.card : ℝ)⁻¹)
      ≤ ((∑ i ∈ s, A i).card : ℝ) :=
  rpow_root_le (Finset.card_pos.mpr hs) (sumset_prod_le_pow A hA)

/-! ## Part 4 : Discrete geometry — L₁ balls in ℤᵈ -/

/-- The L₁ (taxicab) norm on `ℤᵈ`. -/
def l1norm {d : ℕ} (x : Fin d → ℤ) : ℤ := ∑ i, |x i|

/-- Subadditivity (triangle inequality) of the L₁ norm. -/
theorem l1norm_add_le {d : ℕ} (x y : Fin d → ℤ) :
    l1norm (x + y) ≤ l1norm x + l1norm y := by
  unfold l1norm
  rw [← Finset.sum_add_distrib]
  exact Finset.sum_le_sum (fun i _ => by simpa using abs_add_le (x i) (y i))

/-- The L₁ ball of radius `m` in `ℤᵈ`, as a `Finset`. -/
def L1Ball (d : ℕ) (m : ℤ) : Finset (Fin d → ℤ) :=
  (Fintype.piFinset (fun _ => Finset.Icc (-m) m)).filter (fun x => l1norm x ≤ m)

@[simp] theorem mem_L1Ball {d : ℕ} {m : ℤ} {x : Fin d → ℤ} :
    x ∈ L1Ball d m ↔ l1norm x ≤ m := by
  unfold L1Ball
  rw [Finset.mem_filter]
  refine ⟨fun h => h.2, fun h => ⟨?_, h⟩⟩
  rw [Fintype.mem_piFinset]
  intro i
  rw [Finset.mem_Icc]
  have hi : |x i| ≤ l1norm x :=
    Finset.single_le_sum (f := fun j => |x j|) (fun j _ => abs_nonneg _) (Finset.mem_univ i)
  constructor <;> [nlinarith [abs_nonneg (x i), neg_abs_le (x i)];
                   nlinarith [le_abs_self (x i)]]

/-- Adding a radius-`p` ball set to a radius-`q` ball set lands in the
radius-`(p+q)` ball. -/
theorem add_L1Ball_subset {d : ℕ} {p q : ℤ} {B C : Finset (Fin d → ℤ)}
    (hB : B ⊆ L1Ball d p) (hC : C ⊆ L1Ball d q) : B + C ⊆ L1Ball d (p + q) := by
  intro z hz
  rw [Finset.mem_add] at hz
  obtain ⟨b, hb, c, hc, rfl⟩ := hz
  rw [mem_L1Ball]
  have h := l1norm_add_le b c
  have hb2 := mem_L1Ball.1 (hB hb)
  have hc2 := mem_L1Ball.1 (hC hc)
  linarith

theorem zero_mem_L1Ball {d : ℕ} {m : ℤ} (hm : 0 ≤ m) :
    (0 : Finset (Fin d → ℤ)) ⊆ L1Ball d m := by
  intro z hz
  rw [Finset.mem_zero] at hz
  subst hz
  rw [mem_L1Ball]
  have h0 : l1norm (0 : Fin d → ℤ) = 0 := by simp [l1norm]
  rw [h0]
  exact hm

/-- **Geometry bridge.** If each `Aᵢ` is inside the radius-`m` L₁ ball, then the
`n`-fold sumset is inside the radius-`(n·m)` L₁ ball. -/
theorem sumset_L1Ball_subset {d : ℕ} {m : ℤ} {ι : Type*}
    {s : Finset ι} (A : ι → Finset (Fin d → ℤ))
    (hA : ∀ i ∈ s, A i ⊆ L1Ball d m) :
    (∑ i ∈ s, A i) ⊆ L1Ball d (s.card * m) := by
  classical
  induction s using Finset.induction with
  | empty =>
      simp only [Finset.card_empty, Finset.sum_empty, Nat.cast_zero, zero_mul]
      exact zero_mem_L1Ball (le_refl 0)
  | insert a s ha ih =>
      rw [Finset.sum_insert ha, Finset.card_insert_of_notMem ha]
      have h1 : A a ⊆ L1Ball d m := hA a (by simp)
      have h2 : (∑ i ∈ s, A i) ⊆ L1Ball d (s.card * m) :=
        ih (fun i hi => hA i (by simp [hi]))
      have h := add_L1Ball_subset h1 h2
      have heq : m + s.card * m = (s.card + 1 : ℕ) * m := by push_cast; ring
      rwa [heq] at h

/-! ## Part 5 : Real analysis — the sharp transcendental exponent -/

/-- The **sharp exponent** `p = n·log(m+1) / log(nm+1)`. -/
def pExp (n m : ℕ) : ℝ := n * Real.log (m + 1) / Real.log (n * m + 1)

/-- **Sharpness equality.** With the sharp exponent `p`,
`(m+1)^{n/p} = nm+1`.  Since the extremal configuration has `|Aⱼ| = m+1` and
`|∑Aⱼ| = nm+1`, this says `(∏|Aⱼ|)^{1/p} = (m+1)^{n/p} = nm+1 = |∑Aⱼ|`, i.e. the
target bound is *attained with equality* for the exponent `p`. -/
theorem pExp_sharp_equality (n m : ℕ) (hn : 1 ≤ n) (hm : 1 ≤ m) :
    ((m : ℝ) + 1) ^ ((n : ℝ) / pExp n m) = (n : ℝ) * m + 1 := by
  have hmr : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hnr : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hm1 : (1 : ℝ) < (m : ℝ) + 1 := by linarith
  have hlogm : Real.log ((m : ℝ) + 1) ≠ 0 := ne_of_gt (Real.log_pos hm1)
  have hnm1 : (0 : ℝ) < (n : ℝ) * m + 1 := by positivity
  have hnne : (n : ℝ) ≠ 0 := by linarith
  have hkey : (n : ℝ) / pExp n m
      = Real.log ((n : ℝ) * m + 1) / Real.log ((m : ℝ) + 1) := by
    unfold pExp; field_simp
  rw [hkey, Real.rpow_def_of_pos (by linarith), mul_div_cancel₀ _ hlogm,
    Real.exp_log hnm1]

/-- The sharp exponent is at most `n` (so the sharp bound is at least as strong
as the geometric-mean bound `sumset_geom_mean_le`). -/
theorem pExp_le_n (n m : ℕ) (hn : 1 ≤ n) (hm : 1 ≤ m) : pExp n m ≤ (n : ℝ) := by
  have hmr : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hnr : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hm1 : (1 : ℝ) < (m : ℝ) + 1 := by linarith
  have hlognm : (0 : ℝ) < Real.log ((n : ℝ) * m + 1) := Real.log_pos (by nlinarith)
  rw [pExp, div_le_iff₀ hlognm]
  have : Real.log ((m : ℝ) + 1) ≤ Real.log ((n : ℝ) * m + 1) :=
    Real.log_le_log (by linarith) (by nlinarith)
  nlinarith [Real.log_pos hm1]

/-- The sharp exponent is at least `1`. -/
theorem one_le_pExp (n m : ℕ) (hn : 1 ≤ n) (hm : 1 ≤ m) : 1 ≤ pExp n m := by
  have hmr : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hnr : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hm1 : (1 : ℝ) < (m : ℝ) + 1 := by linarith
  have hlognm : (0 : ℝ) < Real.log ((n : ℝ) * m + 1) := Real.log_pos (by nlinarith)
  rw [pExp, le_div_iff₀ hlognm, one_mul]
  have hpow : ((n : ℝ) * m + 1) ≤ ((m : ℝ) + 1) ^ (n : ℕ) := by
    have hb := one_add_mul_le_pow (a := (m : ℝ)) (by linarith) n
    calc ((n : ℝ) * m + 1) = 1 + (n : ℝ) * m := by ring
      _ ≤ ((m : ℝ) + 1) ^ (n : ℕ) := by rw [add_comm (m : ℝ) 1]; nlinarith [hb]
  calc Real.log ((n : ℝ) * m + 1)
      ≤ Real.log (((m : ℝ) + 1) ^ (n : ℕ)) := Real.log_le_log (by positivity) hpow
    _ = (n : ℝ) * Real.log ((m : ℝ) + 1) := by rw [Real.log_pow]

/-! ## Part 6 : The extremal configuration (`d = 1`, `Aⱼ = {0, …, m}`) -/

theorem Icc_add_Icc_int (a b c d : ℤ) (h1 : a ≤ b) (h2 : c ≤ d) :
    Finset.Icc a b + Finset.Icc c d = Finset.Icc (a + c) (b + d) := by
  ext x
  simp only [mem_add, Finset.mem_Icc]
  constructor
  · rintro ⟨p, ⟨hp1, hp2⟩, q, ⟨hq1, hq2⟩, rfl⟩; omega
  · rintro ⟨hx1, hx2⟩
    exact ⟨max a (x - d), ⟨by omega, by omega⟩, x - max a (x - d),
      ⟨by omega, by omega⟩, by ring⟩

/-- The `n`-fold sumset of the interval `{0, …, m}` is `{0, …, nm}`. -/
theorem nfold_Icc (n : ℕ) (m : ℤ) (hm : 0 ≤ m) :
    (∑ _i ∈ Finset.range n, Finset.Icc (0 : ℤ) m) = Finset.Icc 0 (n * m) := by
  induction n with
  | zero => simp only [Finset.sum_range_zero, Nat.cast_zero, zero_mul, Finset.Icc_self]; rfl
  | succ k ih =>
      rw [Finset.sum_range_succ, ih, Icc_add_Icc_int 0 (k * m) 0 m (by positivity) hm]
      congr 1
      push_cast; ring

theorem card_Icc_zero_nat (M : ℕ) : (Finset.Icc (0 : ℤ) (M : ℤ)).card = M + 1 := by
  rw [Int.card_Icc]; omega

/-- **Extremal sharpness.** In dimension `1`, take each `Aⱼ = {0, 1, …, m}`
(a subset of the radius-`m` L₁ ball).  Then:

* the additive Cauchy–Davenport bound holds *with equality*:
  `∑ⱼ |Aⱼ| + 1 = |∑ⱼ Aⱼ| + n`;
* the sharp exponent bound holds *with equality*:
  `(∏ⱼ |Aⱼ|)^{1/p} = |∑ⱼ Aⱼ|`, where `p = pExp n m`.

Hence the exponent `p` is sharp: it cannot be decreased. -/
theorem extremal_interval_sharp (n m : ℕ) (hn : 1 ≤ n) (hm : 1 ≤ m) :
    let A : ℕ → Finset ℤ := fun _ => Finset.Icc (0 : ℤ) (m : ℤ)
    let s : Finset ℕ := Finset.range n
    ((∑ i ∈ s, (A i).card) + 1 = (∑ i ∈ s, A i).card + s.card) ∧
    (((∏ i ∈ s, (A i).card : ℕ) : ℝ) ^ ((pExp n m)⁻¹)
      = ((∑ i ∈ s, A i).card : ℝ)) := by
  intro A s
  have hmz : (0 : ℤ) ≤ (m : ℤ) := by exact_mod_cast Nat.zero_le m
  have hsum : (∑ i ∈ s, A i) = Finset.Icc (0 : ℤ) ((n : ℤ) * m) := nfold_Icc n (m : ℤ) hmz
  have hcardSum : (∑ i ∈ s, A i).card = n * m + 1 := by
    rw [hsum]
    have hc : ((n : ℤ) * m) = ((n * m : ℕ) : ℤ) := by push_cast; ring
    rw [hc, card_Icc_zero_nat]
  constructor
  · have h1 : (∑ i ∈ s, (A i).card) = n * (m + 1) := by
      simp only [A, s]; rw [Finset.sum_const, Finset.card_range, card_Icc_zero_nat, smul_eq_mul]
    rw [h1, hcardSum]
    simp only [s, Finset.card_range]; ring
  · have hprod : (∏ i ∈ s, (A i).card) = (m + 1) ^ n := by
      simp only [A, s]; rw [Finset.prod_const, Finset.card_range, card_Icc_zero_nat]
    rw [hprod, hcardSum]
    have hcast : (((m + 1) ^ n : ℕ) : ℝ) = ((m : ℝ) + 1) ^ (n : ℕ) := by push_cast; ring
    rw [hcast, ← Real.rpow_natCast ((m : ℝ) + 1) n,
      ← Real.rpow_mul (by positivity)]
    have hmul : (n : ℝ) * (pExp n m)⁻¹ = (n : ℝ) / pExp n m := by rw [div_eq_mul_inv]
    rw [hmul, pExp_sharp_equality n m hn hm]
    push_cast; ring

/-! ## Part 7 : The packaged connector theorem -/

/-- **L₁-ball sumset connector.**  For finite nonempty sets
`A₁, …, Aₙ ⊆ {x ∈ ℤᵈ : ∑ᵢ |xᵢ| ≤ m}` (with `m ≥ 0`), all four faces of the
bridge hold simultaneously:

1. **(additive / Cauchy–Davenport)** `∑ⱼ |Aⱼ| + 1 ≤ |∑ⱼ Aⱼ| + n`;
2. **(multiplicative)** `∏ⱼ |Aⱼ| ≤ |∑ⱼ Aⱼ|ⁿ`;
3. **(real geometric mean)** `(∏ⱼ |Aⱼ|)^{1/n} ≤ |∑ⱼ Aⱼ|`;
4. **(geometry)** `∑ⱼ Aⱼ ⊆ {x ∈ ℤᵈ : ∑ᵢ |xᵢ| ≤ n·m}`.

Together with `extremal_interval_sharp` (equality in 1 and, with the sharp
exponent `p ≤ n`, in the geometric bound), this connects additive combinatorics,
discrete geometry, and the transcendental exponent `p`. -/
theorem L1Ball_sumset_bridge {d : ℕ} {m : ℤ} {ι : Type*}
    {s : Finset ι} (hs : s.Nonempty) (A : ι → Finset (Fin d → ℤ))
    (hne : ∀ i ∈ s, (A i).Nonempty) (hsub : ∀ i ∈ s, A i ⊆ L1Ball d m) :
    ((∑ i ∈ s, (A i).card) + 1 ≤ (∑ i ∈ s, A i).card + s.card) ∧
    ((∏ i ∈ s, (A i).card) ≤ (∑ i ∈ s, A i).card ^ s.card) ∧
    (((∏ i ∈ s, (A i).card : ℕ) : ℝ) ^ ((s.card : ℝ)⁻¹)
      ≤ ((∑ i ∈ s, A i).card : ℝ)) ∧
    ((∑ i ∈ s, A i) ⊆ L1Ball d (s.card * m)) :=
  ⟨iterated_cauchy_davenport hs A hne,
   sumset_prod_le_pow A hne,
   sumset_geom_mean_le hs A hne,
   sumset_L1Ball_subset A hsub⟩

end SumsetL1Ball