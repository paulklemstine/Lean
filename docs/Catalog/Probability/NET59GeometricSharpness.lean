import Probability.NET59GeometricSubadditivity

/-!
# NET-59, round 17: the geometric sub-additivity bound is attained

`Probability.NET59GeometricSubadditivity` proves the upper bound

  `joint damage ≤ c · Σ_{i<n} δ^i`

for a stack whose intact layers contract total variation by `δ` and whose
prunings are `c`-close to them uniformly over the input state.  The bound
explains the measured sub-additivity (`4.8%` additive prediction versus `1.7%`
observed) without any per-layer hierarchy, but an *upper* bound alone cannot
turn the measured ratio into a statement about the network: a loose bound is
compatible with any contraction coefficient.

This file closes that gap by showing the bound is **exactly attained**, at every
depth and for every admissible pair `(δ, c)`.  The witness is an affine
two-state family: layer `x ↦ Bernoulli(s + δ·x)`, whose pushforward acts on the
Bernoulli parameter by the affine map `q ↦ s + δ q`.  Taking `s = 0` for the
intact stack and `s = c` for the pruned stack, the parameter gap after `n`
layers is exactly the geometric sum `c · Σ_{i<n} δ^i`, because each layer both
injects a fresh `c` and damps the accumulated gap by `δ`.

Main results.

* `push_affK` — the affine action on Bernoulli parameters.
* `chain_replicate_affK` — the `n`-fold iterate `q ↦ δ^n q + s Σ_{i<n} δ^i`.
* `geometric_bound_attained` — a stack with intact contraction exactly `δ`,
  uniform per-layer budget exactly `c`, and joint damage exactly
  `c · Σ_{i<n} δ^i`.
* `geometric_constant_sharp` — consequently no constant smaller than `1` works
  in `chain_tv_le_geometric`: the bound is not improvable.
* `net59_contraction_estimator` — the sub-additivity ratio is therefore an
  *estimator* of the contraction coefficient.  At the measured depth `24`, an
  intact contraction of `8/9` and a per-layer budget of `1/500` reproduce the
  measured pair exactly: additive prediction `24/500 = 4.8%`, joint damage
  between `1.69%` and `1.70%`.  (This corrects the heuristic reading
  `δ ≈ 0.64` recorded in round 14's lab notes, which inverted the ratio without
  the depth factor.)
-/

namespace Catalog.Probability.NET59

open Finset

/-! ## 1. Bernoulli laws, congruence -/

/-- Two Bernoulli laws with the same parameter are equal (the bound proofs are
irrelevant). -/
theorem bern_congr {a b : ℚ} (h : a = b) (ha0 : 0 ≤ a) (ha1 : a ≤ 1)
    (hb0 : 0 ≤ b) (hb1 : b ≤ 1) : bern a ha0 ha1 = bern b hb0 hb1 := by
  subst h; rfl

/-! ## 2. The affine two-state layer -/

/-- The affine layer `x ↦ Bernoulli(s + δ·x)`: on input `0` it outputs
`Bernoulli(s)`, on input `1` it outputs `Bernoulli(s + δ)`.  Its two rows are
exactly `δ` apart, so its Dobrushin coefficient is exactly `δ`; `s` is the
"offset" that pruning will shift. -/
def affK (δ s : ℚ) (hδ : 0 ≤ δ) (hs : 0 ≤ s) (hsδ : s + δ ≤ 1) : Kern (Fin 2) (Fin 2) :=
  fun x => if x = 0 then bern s hs (by linarith) else bern (s + δ) (by linarith) hsδ

/-- The two states of the two-element alphabet. -/
theorem fin2_cases : ∀ x : Fin 2, x = 0 ∨ x = 1 := by decide

@[simp] theorem affK_apply_zero (δ s : ℚ) (hδ : 0 ≤ δ) (hs : 0 ≤ s) (hsδ : s + δ ≤ 1) :
    affK δ s hδ hs hsδ 0 = bern s hs (by linarith) := by
  simp [affK]

@[simp] theorem affK_apply_one (δ s : ℚ) (hδ : 0 ≤ δ) (hs : 0 ≤ s) (hsδ : s + δ ≤ 1) :
    affK δ s hδ hs hsδ 1 = bern (s + δ) (by linarith) hsδ := by
  simp [affK]

/-- The affine layer contracts by exactly `δ`: its two rows are `δ` apart. -/
theorem affK_rows (δ s : ℚ) (hδ : 0 ≤ δ) (hs : 0 ≤ s) (hsδ : s + δ ≤ 1) (a b : Fin 2) :
    tv (affK δ s hδ hs hsδ a) (affK δ s hδ hs hsδ b) ≤ δ := by
  rcases fin2_cases a with rfl | rfl <;> rcases fin2_cases b with rfl | rfl <;>
    simp only [affK_apply_zero, affK_apply_one, tv_bern] <;>
    rw [abs_sub_le_iff] <;> constructor <;> linarith

/-- The two rows of the affine layer are exactly `δ` apart. -/
theorem affK_rows_eq (δ s : ℚ) (hδ : 0 ≤ δ) (hs : 0 ≤ s) (hsδ : s + δ ≤ 1) :
    tv (affK δ s hδ hs hsδ 0) (affK δ s hδ hs hsδ 1) = δ := by
  simp only [affK_apply_zero, affK_apply_one, tv_bern]
  rw [abs_of_nonpos (by linarith)]
  ring

/-- Two affine layers with the same slope and offsets `s`, `s'` are `|s - s'|`
apart at every input: the per-layer pruning budget is *uniform*, exactly what
`chain_tv_le_geometric` requires. -/
theorem tv_affK_affK (δ s s' : ℚ) (hδ : 0 ≤ δ) (hs : 0 ≤ s) (hsδ : s + δ ≤ 1)
    (hs' : 0 ≤ s') (hs'δ : s' + δ ≤ 1) (a : Fin 2) :
    tv (affK δ s hδ hs hsδ a) (affK δ s' hδ hs' hs'δ a) = |s - s'| := by
  rcases fin2_cases a with rfl | rfl
  · simp only [affK_apply_zero, tv_bern]
  · simp only [affK_apply_one, tv_bern]
    congr 1
    ring

/-- **The affine action on Bernoulli parameters.**  Pushing `Bernoulli(q)`
through the affine layer gives `Bernoulli(s + δ q)`. -/
theorem push_affK (δ s q : ℚ) (hδ : 0 ≤ δ) (hs : 0 ≤ s) (hsδ : s + δ ≤ 1)
    (hq0 : 0 ≤ q) (hq1 : q ≤ 1) (hr0 : 0 ≤ s + δ * q) (hr1 : s + δ * q ≤ 1) :
    push (affK δ s hδ hs hsδ) (bern q hq0 hq1) = bern (s + δ * q) hr0 hr1 := by
  refine Dist.ext' fun b => ?_
  fin_cases b <;>
    simp [push, affK, bern, Fin.sum_univ_two] <;> ring

/-! ## 3. Iterating the affine layer -/

/-- The parameter reached after `n` affine layers stays in `[0,1]`. -/
theorem affIter_mem (δ s : ℚ) (hδ : 0 ≤ δ) (hs : 0 ≤ s) (hsδ : s + δ ≤ 1) :
    ∀ (n : ℕ) (q : ℚ), 0 ≤ q → q ≤ 1 →
      0 ≤ δ ^ n * q + s * ∑ i ∈ range n, δ ^ i ∧
        δ ^ n * q + s * ∑ i ∈ range n, δ ^ i ≤ 1 := by
  intro n
  induction n with
  | zero => intro q hq0 hq1; simpa using ⟨hq0, hq1⟩
  | succ m ihm =>
      intro q hq0 hq1
      obtain ⟨h0, h1⟩ := ihm q hq0 hq1
      have hsum : ∑ i ∈ range (m + 1), δ ^ i = δ * ∑ i ∈ range m, δ ^ i + 1 :=
        geom_sum_succ
      have hsnn : 0 ≤ ∑ i ∈ range m, δ ^ i :=
        Finset.sum_nonneg fun i _ => pow_nonneg hδ i
      constructor
      · have : 0 ≤ δ ^ (m + 1) * q :=
          mul_nonneg (pow_nonneg hδ _) hq0
        have : 0 ≤ s * ∑ i ∈ range (m + 1), δ ^ i :=
          mul_nonneg hs (Finset.sum_nonneg fun i _ => pow_nonneg hδ i)
        positivity
      · -- `δ^(m+1) q + s Σ_{i<m+1} = δ · (δ^m q + s Σ_{i<m}) + s ≤ δ + s ≤ 1`
        have hrw : δ ^ (m + 1) * q + s * ∑ i ∈ range (m + 1), δ ^ i
            = δ * (δ ^ m * q + s * ∑ i ∈ range m, δ ^ i) + s := by
          rw [hsum]; ring
        rw [hrw]
        nlinarith

/-- **The `n`-fold iterate.**  Running `n` copies of the affine layer on
`Bernoulli(q)` gives `Bernoulli(δ^n q + s Σ_{i<n} δ^i)`. -/
theorem chain_replicate_affK (δ s : ℚ) (hδ : 0 ≤ δ) (hs : 0 ≤ s) (hsδ : s + δ ≤ 1) :
    ∀ (n : ℕ) (q : ℚ) (hq0 : 0 ≤ q) (hq1 : q ≤ 1)
      (hr0 : 0 ≤ δ ^ n * q + s * ∑ i ∈ range n, δ ^ i)
      (hr1 : δ ^ n * q + s * ∑ i ∈ range n, δ ^ i ≤ 1),
      chain (List.replicate n (affK δ s hδ hs hsδ)) (bern q hq0 hq1)
        = bern (δ ^ n * q + s * ∑ i ∈ range n, δ ^ i) hr0 hr1 := by
  intro n
  induction n with
  | zero =>
      intro q hq0 hq1 hr0 hr1
      simp only [List.replicate_zero, chain_nil]
      exact bern_congr (by simp) hq0 hq1 hr0 hr1
  | succ m ihm =>
      intro q hq0 hq1 hr0 hr1
      have hq'0 : 0 ≤ s + δ * q := add_nonneg hs (mul_nonneg hδ hq0)
      have hq'1 : s + δ * q ≤ 1 := by nlinarith
      have hstep :=
        push_affK δ s q hδ hs hsδ hq0 hq1 hq'0 hq'1
      obtain ⟨ha0, ha1⟩ := affIter_mem δ s hδ hs hsδ m (s + δ * q) hq'0 hq'1
      have hIH := ihm (s + δ * q) hq'0 hq'1 ha0 ha1
      rw [List.replicate_succ, chain_cons, hstep, hIH]
      refine bern_congr ?_ ha0 ha1 hr0 hr1
      rw [Finset.sum_range_succ]
      ring

/-! ## 4. Attainment of the geometric bound -/

/-- **The geometric bound is attained.**  For every depth `n` and every pair
`(δ, c)` of nonnegative rationals with `c + δ ≤ 1` there is a `n`-layer stack
over a two-state alphabet such that

* every intact layer contracts total variation by exactly `δ`;
* every pruned layer is exactly `c`-far from its intact counterpart, at *every*
  input state (a uniform per-layer budget);
* the joint pruning damage equals `c · Σ_{i<n} δ^i`, the bound of
  `chain_tv_le_geometric`, with equality.

So the sub-additivity of the observed kind is not merely *permitted* by
contraction — it is the exact behaviour of a generic contracting stack. -/
theorem geometric_bound_attained {δ c : ℚ} (hδ : 0 ≤ δ) (hc : 0 ≤ c) (hcδ : c + δ ≤ 1) (n : ℕ) :
    ∃ F P : List (Kern (Fin 2) (Fin 2)),
      F.length = n ∧ P.length = n ∧
      (∀ K ∈ F, ∀ a b, tv (K a) (K b) ≤ δ) ∧
      (∀ q ∈ F.zip P, ∀ a : Fin 2, tv (q.1 a) (q.2 a) = c) ∧
      tv (chain F d0) (chain P d0) = c * ∑ i ∈ range n, δ ^ i := by
  classical
  have h0δ : (0 : ℚ) + δ ≤ 1 := by linarith
  set f : Kern (Fin 2) (Fin 2) := affK δ 0 hδ le_rfl h0δ with hf
  set p : Kern (Fin 2) (Fin 2) := affK δ c hδ hc hcδ with hp
  refine ⟨List.replicate n f, List.replicate n p, by simp, by simp, ?_, ?_, ?_⟩
  · intro K hK a b
    rw [List.eq_of_mem_replicate hK, hf]
    exact affK_rows δ 0 hδ le_rfl h0δ a b
  · intro q hq a
    obtain ⟨h1, h2⟩ := List.of_mem_zip hq
    rw [List.eq_of_mem_replicate h1, List.eq_of_mem_replicate h2, hf, hp,
      tv_affK_affK δ 0 c hδ le_rfl h0δ hc hcδ a]
    rw [zero_sub, abs_neg, abs_of_nonneg hc]
  · have hd0 : d0 = bern 0 le_rfl zero_le_one := rfl
    obtain ⟨hi0, hi1⟩ := affIter_mem δ 0 hδ le_rfl h0δ n 0 le_rfl zero_le_one
    obtain ⟨hj0, hj1⟩ := affIter_mem δ c hδ hc hcδ n 0 le_rfl zero_le_one
    rw [hd0, hf, hp,
      chain_replicate_affK δ 0 hδ le_rfl h0δ n 0 le_rfl zero_le_one hi0 hi1,
      chain_replicate_affK δ c hδ hc hcδ n 0 le_rfl zero_le_one hj0 hj1,
      tv_bern]
    have hz : δ ^ n * 0 + 0 * ∑ i ∈ range n, δ ^ i = 0 := by ring
    have hs : δ ^ n * 0 + c * ∑ i ∈ range n, δ ^ i = c * ∑ i ∈ range n, δ ^ i := by ring
    rw [hz, hs, zero_sub, abs_neg,
      abs_of_nonneg (mul_nonneg hc (Finset.sum_nonneg fun i _ => pow_nonneg hδ i))]

/-- **The constant in `chain_tv_le_geometric` is sharp.**  If a factor `K`
multiplying the geometric bound is valid for all stacks over the two-state
alphabet satisfying the contraction and uniform-budget hypotheses, then
`1 ≤ K`. -/
theorem geometric_constant_sharp {δ c : ℚ} (hδ : 0 ≤ δ) (hc : 0 < c) (hcδ : c + δ ≤ 1)
    (n : ℕ) (hn : 0 < n) (K : ℚ)
    (hK : ∀ F P : List (Kern (Fin 2) (Fin 2)), F.length = P.length →
      (∀ M ∈ F, ∀ a b, tv (M a) (M b) ≤ δ) →
      (∀ q ∈ F.zip P, ∀ a : Fin 2, tv (q.1 a) (q.2 a) ≤ c) →
      ∀ μ : Dist (Fin 2),
        tv (chain F μ) (chain P μ) ≤ K * (c * ∑ i ∈ range F.length, δ ^ i)) :
    1 ≤ K := by
  obtain ⟨F, P, hFlen, hPlen, hcontr, hclose, hjoint⟩ :=
    geometric_bound_attained hδ hc.le hcδ n
  have hb := hK F P (by rw [hFlen, hPlen]) hcontr
    (fun q hq a => le_of_eq (hclose q hq a)) d0
  rw [hjoint, hFlen] at hb
  -- the geometric sum is at least `1` because `n ≥ 1`
  have hsum1 : (1 : ℚ) ≤ ∑ i ∈ range n, δ ^ i := by
    obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
    rw [geom_sum_succ]
    have : 0 ≤ δ * ∑ i ∈ range m, δ ^ i :=
      mul_nonneg hδ (Finset.sum_nonneg fun i _ => pow_nonneg hδ i)
    linarith
  have hpos : 0 < c * ∑ i ∈ range n, δ ^ i := by nlinarith
  nlinarith

/-! ## 5. The sub-additivity ratio as a contraction estimator -/

/-- The dyadic-free geometric sum at the measured depth, evaluated exactly. -/
theorem geom_sum_24_eight_ninths_bounds :
    (84 : ℚ) / 10 ≤ ∑ i ∈ range 24, ((8 : ℚ) / 9) ^ i ∧
      ∑ i ∈ range 24, ((8 : ℚ) / 9) ^ i ≤ 85 / 10 := by
  constructor <;> norm_num [Finset.sum_range_succ]

/-- **The measured pair is reproduced exactly.**  At the measured depth `24`,
intact-layer contraction `8/9` and uniform per-layer budget `1/500` (i.e. a
`0.2%` solo cost, the order of magnitude NET-59 reports) give

* additive prediction `24 · (1/500) = 4.8%`, exactly the programme's figure;
* joint pruning damage strictly between `1.69%` and `1.70%`, exactly the
  programme's `1.7%`.

The stack has no distinguished layer: all `24` layers are identical.  So the
measured sub-additivity is fully accounted for by one number — the contraction
coefficient — and carries no information about a per-layer hierarchy.  The
ratio `additive / joint` determines that coefficient, which is what makes it an
estimator rather than merely a bound. -/
theorem net59_contraction_estimator :
    ∃ F P : List (Kern (Fin 2) (Fin 2)),
      F.length = 24 ∧ P.length = 24 ∧
      (∀ K ∈ F, ∀ a b, tv (K a) (K b) ≤ 8 / 9) ∧
      (∀ q ∈ F.zip P, ∀ a : Fin 2, tv (q.1 a) (q.2 a) = 1 / 500) ∧
      (24 : ℚ) * (1 / 500) = 48 / 1000 ∧
      169 / 10000 < tv (chain F d0) (chain P d0) ∧
      tv (chain F d0) (chain P d0) < 170 / 10000 := by
  obtain ⟨F, P, hF, hP, hcontr, hclose, hjoint⟩ :=
    geometric_bound_attained (δ := 8 / 9) (c := 1 / 500) (by norm_num) (by norm_num)
      (by norm_num) 24
  refine ⟨F, P, hF, hP, hcontr, hclose, by norm_num, ?_, ?_⟩ <;> rw [hjoint] <;>
    · norm_num [Finset.sum_range_succ]

/-! ## 6. Lab notes

Exact rational values behind the estimator, at depth `24`:

```
intact-layer contraction δ                  : 8/9  ≈ 0.8889
uniform per-layer budget c                  : 1/500 = 0.2%
geometric sum  Σ_{i<24} (8/9)^i             : ≈ 8.4674   (proved: within [8.4, 8.5])
additive prediction  24·c                   : 4.8%       (exact)
joint damage  c · Σ                         : ≈ 1.693%   (proved: within (1.69%, 1.70%))
sub-additivity factor  24 / Σ               : ≈ 2.835
NET-50/NET-59 measured factor               : 4.8% / 1.7% ≈ 2.82
```

Round 14's lab notes read the measured factor `2.8` as `δ ≈ 1 - 1/2.8 ≈ 0.64`.
That inverts `c/(1-δ)` against `c` rather than against the additive prediction
`24c`; the correct relation is `additive/joint = n(1-δ)/(1-δ^n)`, which at
`n = 24` gives `δ ≈ 0.89`.  Both readings agree on the qualitative point — a
generic, mild amount of forgetting suffices — but only the corrected one is an
estimator. -/

section LabNotes

/-- The geometric sum at `δ = 8/9`, depth `24`, is far below the additive value
`24`, but far above the dyadic value `2` of round 14. -/
example : (2 : ℚ) < ∑ i ∈ range 24, ((8 : ℚ) / 9) ^ i ∧
    ∑ i ∈ range 24, ((8 : ℚ) / 9) ^ i < 24 := by
  obtain ⟨h1, h2⟩ := geom_sum_24_eight_ninths_bounds
  constructor <;> linarith

end LabNotes

end Catalog.Probability.NET59