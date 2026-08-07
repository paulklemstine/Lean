import Mathlib

/-!
# Soft selection beats hard selection: refuting the `Ω(1/N)` resolution barrier for softmax heads

`Catalog/MachineLearning/TransformerUniversality/FiniteLookupSeparation.lean` proves that a
*hard* lookup architecture that reads one of `N` stored values has uniform error at least
`1/(2N)` against the identity on `[0,1]`, and that the bound is attained.  The first
next-cycle sub-conjecture of `FUTURE_DIRECTIONS.md` proposed that the same `Ω(1/N)` barrier
survives softmax: *"a softmax attention layer with `N` fixed keys and arbitrary score scale has
uniform error at least `c/N` on the identity."*

**This file refutes that conjecture.**  Softmax weights are strictly interior points of the
simplex and vary continuously with the input, so a *two*-key softmax head with values `0` and
`1` already approximates the identity on `[0,1]` to arbitrary accuracy: choosing the logit
gap `log ((x+ε)/(1+ε-x))` gives the attention weight `(x+ε)/(1+2ε)`, whose distance from `x`
is at most `ε` uniformly on `[0,1]`.  No lower bound of the form `c/N` can therefore hold.

Main results:

* `softmaxHead_le_of_le`, `le_softmaxHead_of_le` — a softmax head always outputs a point of
  the convex hull of its values (the only thing hard and soft selection have in common);
* `logitHead_eq` — the closed form `(x+ε)/(1+2ε)` of the two-key head used below;
* `two_key_softmax_approx_identity` — **`ε`-approximation of the identity on `[0,1]` with two
  keys**, for every `ε > 0`;
* `no_universal_softmax_resolution_bound` — the formal refutation: there is no constant
  `c > 0` with `c/N` uniform error for all `N`-key softmax heads;
* `hardHead_error_ge` — the contrasting hard-selection bound `1/(2N)`, proved here by
  pigeonhole on the `N+1` grid points `k/N` so that the dichotomy is self-contained;
* `soft_hard_dichotomy` — the two statements side by side at `N = 2`: error `≤ ε` for every
  `ε > 0` on the soft side, error `≥ 1/4` unconditionally on the hard side.

The moral for the scope qualification of the original development is that the `Θ(1/N)`
resolution barrier proved in `FiniteLookupSeparation.lean` is an artifact of **hard**
selection — of reading a finite value table — and not of the number of heads or keys.  A
genuine lower bound for softmax models must therefore constrain the score family (e.g. to
bilinear scores), not merely count keys.
-/

open scoped BigOperators

namespace SoftmaxResolution

section General

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- Softmax weights of a score vector (any inverse temperature is absorbed into `s`). -/
noncomputable def weight (s : ι → ℝ) (j : ι) : ℝ := Real.exp (s j) / ∑ k, Real.exp (s k)

theorem denom_pos (s : ι → ℝ) : 0 < ∑ k, Real.exp (s k) :=
  Finset.sum_pos (fun _ _ => Real.exp_pos _) Finset.univ_nonempty

theorem weight_pos (s : ι → ℝ) (j : ι) : 0 < weight s j :=
  div_pos (Real.exp_pos _) (denom_pos s)

theorem sum_weight (s : ι → ℝ) : ∑ j, weight s j = 1 := by
  simp only [weight]
  rw [← Finset.sum_div, div_self (denom_pos s).ne']

/-- A softmax attention head with input-dependent scores `s` and fixed values `v`. -/
noncomputable def softmaxHead (s : ℝ → ι → ℝ) (v : ι → ℝ) (x : ℝ) : ℝ :=
  ∑ j, weight (s x) j * v j

/-- A softmax head never exceeds the largest of its values. -/
theorem softmaxHead_le_of_le (s : ℝ → ι → ℝ) (v : ι → ℝ) (x M : ℝ) (hv : ∀ j, v j ≤ M) :
    softmaxHead s v x ≤ M := by
  have h : ∑ j, weight (s x) j * v j ≤ ∑ j, weight (s x) j * M :=
    Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_left (hv j) (weight_pos _ j).le
  calc softmaxHead s v x ≤ ∑ j, weight (s x) j * M := h
    _ = M := by rw [← Finset.sum_mul, sum_weight, one_mul]

/-- A softmax head never falls below the smallest of its values. -/
theorem le_softmaxHead_of_le (s : ℝ → ι → ℝ) (v : ι → ℝ) (x m : ℝ) (hv : ∀ j, m ≤ v j) :
    m ≤ softmaxHead s v x := by
  have h : ∑ j, weight (s x) j * m ≤ ∑ j, weight (s x) j * v j :=
    Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_left (hv j) (weight_pos _ j).le
  calc m = ∑ j, weight (s x) j * m := by rw [← Finset.sum_mul, sum_weight, one_mul]
    _ ≤ softmaxHead s v x := h

end General

section TwoKey

/-- The two-key score family used to approximate the identity: key `0` has logit `0`, key `1`
has logit `log ((x+ε)/(1+ε-x))`. -/
noncomputable def logitScore (eps : ℝ) (x : ℝ) (j : Fin 2) : ℝ :=
  if j = 0 then 0 else Real.log ((x + eps) / (1 + eps - x))

/-- The two values: `0` on key `0` and `1` on key `1`. -/
def unitValues (j : Fin 2) : ℝ := if j = 0 then 0 else 1

/-- **Closed form of the two-key head.**  On `[0,1]` the head computes the affine function
`(x+ε)/(1+2ε)`. -/
theorem logitHead_eq {eps : ℝ} (heps : 0 < eps) {x : ℝ} (hx : x ∈ Set.Icc (0 : ℝ) 1) :
    softmaxHead (logitScore eps) unitValues x = (x + eps) / (1 + 2 * eps) := by
  obtain ⟨hx0, hx1⟩ := hx
  have hnum : 0 < x + eps := by linarith
  have hden : 0 < 1 + eps - x := by linarith
  have hr : Real.exp (Real.log ((x + eps) / (1 + eps - x))) = (x + eps) / (1 + eps - x) :=
    Real.exp_log (div_pos hnum hden)
  simp only [softmaxHead, weight, logitScore, unitValues, Fin.sum_univ_two]
  norm_num [hr]
  rw [div_eq_div_iff (by positivity) (by linarith)]
  field_simp
  ring

/-- **Two keys suffice.**  For every `ε > 0` there is a softmax head with just two keys whose
output is within `ε` of the identity, uniformly on `[0,1]`.

This is the refutation of the conjectured `Ω(1/N)` resolution barrier for softmax heads: the
key count `N` does not control the achievable resolution at all. -/
theorem two_key_softmax_approx_identity {eps : ℝ} (heps : 0 < eps) :
    ∀ x ∈ Set.Icc (0 : ℝ) 1, |softmaxHead (logitScore eps) unitValues x - x| ≤ eps := by
  intro x hx
  obtain ⟨hx0, hx1⟩ := hx
  rw [logitHead_eq heps ⟨hx0, hx1⟩, abs_le]
  constructor
  · rw [le_sub_iff_add_le, le_div_iff₀ (by linarith)]
    nlinarith
  · rw [sub_le_iff_le_add, div_le_iff₀ (by linarith)]
    nlinarith

/-- Existence form of the previous theorem. -/
theorem exists_two_key_softmax_approx {eps : ℝ} (heps : 0 < eps) :
    ∃ (s : ℝ → Fin 2 → ℝ) (v : Fin 2 → ℝ),
      ∀ x ∈ Set.Icc (0 : ℝ) 1, |softmaxHead s v x - x| ≤ eps :=
  ⟨logitScore eps, unitValues, two_key_softmax_approx_identity heps⟩

/-- **Refutation of the `c/N` resolution conjecture for softmax heads.**  No positive constant
`c` makes `c/N` a valid uniform error lower bound for `N`-key softmax heads approximating the
identity on `[0,1]`: already `N = 2` beats every such bound. -/
theorem no_universal_softmax_resolution_bound :
    ¬ ∃ c : ℝ, 0 < c ∧ ∀ (N : ℕ), 0 < N → ∀ (s : ℝ → Fin N → ℝ) (v : Fin N → ℝ),
        ∃ x ∈ Set.Icc (0 : ℝ) 1, c / N ≤ |softmaxHead s v x - x| := by
  rintro ⟨c, hc, hbound⟩
  obtain ⟨x, hx, hxb⟩ := hbound 2 (by norm_num) (logitScore (c / 4)) unitValues
  have happrox := two_key_softmax_approx_identity (eps := c / 4) (by linarith) x hx
  have h2 : c / ((2 : ℕ) : ℝ) = c / 2 := by norm_num
  rw [h2] at hxb
  linarith

end TwoKey

section Hard

/-- A hard-selection head: pick one of `N` stored values by an arbitrary selector. -/
def hardHead {N : ℕ} (sel : ℝ → Fin N) (v : Fin N → ℝ) (x : ℝ) : ℝ := v (sel x)

/-- **Hard selection is stuck at `1/(2N)`.**  Whatever the selector and the stored values, a
hard `N`-way lookup misses the identity by at least `1/(2N)` somewhere on `[0,1]`.

Proof by pigeonhole on the `N+1` grid points `k/N`: two of them must select the same value,
yet they are `1/N` apart. -/
theorem hardHead_error_ge {N : ℕ} (hN : 0 < N) (sel : ℝ → Fin N) (v : Fin N → ℝ) :
    ∃ x ∈ Set.Icc (0 : ℝ) 1, (1 : ℝ) / (2 * N) ≤ |hardHead sel v x - x| := by
  by_contra hcon
  push_neg at hcon
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  have hmem : ∀ k : Fin (N + 1), ((k : ℝ) / N) ∈ Set.Icc (0 : ℝ) 1 := by
    intro k
    refine ⟨by positivity, ?_⟩
    rw [div_le_one hNR]
    have : (k : ℕ) ≤ N := Nat.lt_succ_iff.mp k.isLt
    exact_mod_cast this
  obtain ⟨k, l, hkl, heq⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun k : Fin (N + 1) => sel ((k : ℝ) / N)) (by simp)
  have h1 := hcon _ (hmem k)
  have h2 := hcon _ (hmem l)
  simp only [hardHead] at h1 h2
  rw [heq] at h1
  have hdist : |((k : ℝ) / N) - ((l : ℝ) / N)| < 1 / N := by
    calc |((k : ℝ) / N) - ((l : ℝ) / N)|
        ≤ |v (sel ((l : ℝ) / N)) - (k : ℝ) / N| + |v (sel ((l : ℝ) / N)) - (l : ℝ) / N| := by
          rw [abs_sub_comm (v (sel ((l : ℝ) / N))) ((k : ℝ) / N)]
          exact abs_sub_le _ _ _
      _ < 1 / (2 * N) + 1 / (2 * N) := by linarith
      _ = 1 / N := by field_simp; ring
  have hklR : (k : ℕ) ≠ (l : ℕ) := fun h => hkl (Fin.ext h)
  have hlow : (1 : ℝ) / N ≤ |((k : ℝ) / N) - ((l : ℝ) / N)| := by
    have h1' : (1 : ℝ) ≤ |((k : ℕ) : ℝ) - ((l : ℕ) : ℝ)| := by
      rcases lt_or_gt_of_ne hklR with hlt | hlt
      · have hle : (((k : ℕ) : ℝ)) + 1 ≤ ((l : ℕ) : ℝ) := by exact_mod_cast hlt
        rw [abs_of_nonpos (by linarith)]
        linarith
      · have hle : (((l : ℕ) : ℝ)) + 1 ≤ ((k : ℕ) : ℝ) := by exact_mod_cast hlt
        rw [abs_of_nonneg (by linarith)]
        linarith
    rw [div_sub_div_same, abs_div, abs_of_pos hNR]
    gcongr
  linarith

/-- **The soft/hard dichotomy at two keys.**  With two keys, softmax selection approximates the
identity on `[0,1]` to arbitrary accuracy, while hard selection is stuck at error `1/4`.

This is the precise sense in which the `Θ(1/N)` barrier of `FiniteLookupSeparation.lean` is a
statement about reading a finite value table, not about the number of heads. -/
theorem soft_hard_dichotomy {eps : ℝ} (heps : 0 < eps) :
    (∃ (s : ℝ → Fin 2 → ℝ) (v : Fin 2 → ℝ),
        ∀ x ∈ Set.Icc (0 : ℝ) 1, |softmaxHead s v x - x| ≤ eps) ∧
      (∀ (sel : ℝ → Fin 2) (v : Fin 2 → ℝ),
        ∃ x ∈ Set.Icc (0 : ℝ) 1, (1 : ℝ) / 4 ≤ |hardHead sel v x - x|) := by
  refine ⟨exists_two_key_softmax_approx heps, fun sel v => ?_⟩
  obtain ⟨x, hx, hxb⟩ := hardHead_error_ge (N := 2) (by norm_num) sel v
  refine ⟨x, hx, ?_⟩
  norm_num at hxb
  linarith

end Hard

end SoftmaxResolution