import Mathlib

/-!
# Keys own the cliff: the structural asymmetry of KV-cache quantisation (NET-93)

The NET-93 measurement (llama-perplexity, ctx = 2048, 250KB held-out wikitext
slice) produced a four-order-of-magnitude asymmetry between the two halves of
the attention cache:

| arm            | PPL      | dPPL vs control |
|----------------|----------|-----------------|
| K q4_1 / V q4_1| 3158.07  | +44,322%        |
| K iq4_nl/V iq4_nl | 1627.35 | +22,790%      |
| K q4_0 / V f16 | 2537.80  | +35,597%        |
| K f16 / V q4_0 | 7.1211   | +0.166%         |

Two claims were extracted:

* **P1 (refuted empirically).**  A richer 4-bit block format (scale + offset
  `q4_1`, or the nonuniform codebook `iq4_nl`) rescues the keys.  It does not.
* **P2 (confirmed beyond prediction).**  Keys are astronomically more sensitive
  than values; the measured damage ratio is ~2.1 · 10⁵, not the predicted ≥ 5.

This file proves that both facts are *theorems about the attention functional*,
not artefacts of one implementation family inside `llama.cpp`.

Main results.

* `attn_value_perturbation_le` — **values are free, unconditionally.**  Softmax
  weights form a convex combination, so a `δ`-perturbation of the value cache
  moves the attention output by at most `δ`: the map is `1`-Lipschitz in the
  values, with no dependence on the query, the scores, the context length or
  the depth.  (`attn_value_perturbation_sharp`: the constant `1` is attained.)
* `score_error_le_of_key_error` / `score_error_dim_amplified` — **keys are
  amplified before the nonlinearity.**  A key perturbation is contracted with
  the query, so a `δ`-perturbation of the keys moves the *logits* by up to
  `‖q‖₁ · δ`, and this dimension-times-query-norm amplification is attained.
* `key_quantization_annihilates` — for *every* resolution `δ > 0` there is a
  configuration in which a `δ`-key-perturbation moves the output by at least
  `1/4`, i.e. by a constant independent of `δ`.
* `damage_ratio_unbounded` — hence the K-vs-V damage ratio admits **no finite
  upper bound**: the measured 2.1 · 10⁵ is not a ceiling.
* `no_codebook_rescues_keys` — **P1, refuted structurally.**  For *any* key
  quantiser whatsoever whose per-block codebook has at most `N` entries —
  uniform `q4_0`, affine `q4_1`, nonuniform `iq4_nl`, or any format not yet
  invented — there are two keys separated by at least `1/N` that the codebook
  identifies, and a query of norm at most `2N` under which the exact attention
  output and the quantised one differ by at least `1/4`.  Only the *cardinality*
  of the codebook enters; no amount of representational cleverness helps.
* `value_codebook_damage_le` — the contrast: the same pigeonhole argument
  applied to a value codebook of resolution `δ` yields damage at most `δ`.

The mechanism the theorems isolate is exactly the one conjectured in NET-93:
key error enters *multiplicatively, upstream of the softmax*, where it is scaled
by the query norm and then passed through a selection nonlinearity; value error
enters *additively, downstream*, where a convex combination averages it away.
-/

namespace Catalog.Novelty.KeysOwnTheCliff

open Finset

variable {n d : ℕ}

/-! ### 1. The attention functional -/

/-- Softmax over `n+1` cached positions. -/
noncomputable def softmax (s : Fin (n + 1) → ℝ) (i : Fin (n + 1)) : ℝ :=
  Real.exp (s i) / ∑ j, Real.exp (s j)

/-- Single-head attention read-out: the softmax-weighted average of the values. -/
noncomputable def attnOut (s v : Fin (n + 1) → ℝ) : ℝ := ∑ i, softmax s i * v i

/-- The logits produced by a query `q` against a key cache `k`. -/
def scores (q : Fin d → ℝ) (k : Fin (n + 1) → Fin d → ℝ) : Fin (n + 1) → ℝ :=
  fun i => ∑ t, q t * k i t

lemma sum_exp_pos (s : Fin (n + 1) → ℝ) : 0 < ∑ j, Real.exp (s j) :=
  Finset.sum_pos (fun _ _ => Real.exp_pos _) ⟨0, Finset.mem_univ 0⟩

lemma softmax_pos (s : Fin (n + 1) → ℝ) (i : Fin (n + 1)) : 0 < softmax s i :=
  div_pos (Real.exp_pos _) (sum_exp_pos s)

lemma softmax_sum_one (s : Fin (n + 1) → ℝ) : ∑ i, softmax s i = 1 := by
  simp only [softmax, ← Finset.sum_div]
  exact div_self (ne_of_gt (sum_exp_pos s))

/-! ### 2. Values are free: the read-out is `1`-Lipschitz downstream -/

/-- A convex combination is non-expansive in the sup-norm: this is the whole
reason a quantised **value** cache is harmless. -/
theorem convex_combination_nonexpansive {m : ℕ} (p v w : Fin m → ℝ) (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i, p i = 1) (eps : ℝ) (h : ∀ i, |v i - w i| ≤ eps) :
    |∑ i, p i * v i - ∑ i, p i * w i| ≤ eps := by
  have hrw : ∑ i, p i * v i - ∑ i, p i * w i = ∑ i, p i * (v i - w i) := by
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun i _ => by ring
  rw [hrw]
  calc |∑ i, p i * (v i - w i)| ≤ ∑ i, |p i * (v i - w i)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i, p i * eps := by
        refine Finset.sum_le_sum fun i _ => ?_
        rw [abs_mul, abs_of_nonneg (hp i)]
        exact mul_le_mul_of_nonneg_left (h i) (hp i)
    _ = eps := by rw [← Finset.sum_mul, hsum, one_mul]

/-- **Values are free.**  Perturbing the value cache by at most `δ` in every
entry moves the attention output by at most `δ`, whatever the scores, the query,
the context length or the head dimension.  This is the `+0.166%` arm. -/
theorem attn_value_perturbation_le (s v w : Fin (n + 1) → ℝ) (eps : ℝ)
    (h : ∀ i, |v i - w i| ≤ eps) : |attnOut s v - attnOut s w| ≤ eps :=
  convex_combination_nonexpansive _ _ _ (fun i => le_of_lt (softmax_pos s i))
    (softmax_sum_one s) eps h

/-- The read-out reproduces a constant value cache exactly. -/
lemma attnOut_const (s : Fin (n + 1) → ℝ) (c : ℝ) : attnOut s (fun _ => c) = c := by
  simp only [attnOut, ← Finset.sum_mul, softmax_sum_one s, one_mul]

/-- The Lipschitz constant `1` of `attn_value_perturbation_le` is attained, so
the value bound cannot be improved — but it also never degrades. -/
theorem attn_value_perturbation_sharp (s : Fin (n + 1) → ℝ) (eps : ℝ) (heps : 0 ≤ eps) :
    |attnOut s (fun _ => eps) - attnOut s (fun _ => (0 : ℝ))| = eps := by
  rw [attnOut_const, attnOut_const, sub_zero, abs_of_nonneg heps]

/-! ### 3. Keys are amplified: the query contracts against the key error -/

/-- A key perturbation of size `δ` becomes a logit perturbation of size up to
`‖q‖₁ · δ`.  The amplification factor is the query's `ℓ¹` norm — it grows with
the head dimension and with the activation scale. -/
theorem score_error_le_of_key_error (q : Fin d → ℝ) (k k' : Fin (n + 1) → Fin d → ℝ)
    (eps : ℝ) (h : ∀ i t, |k i t - k' i t| ≤ eps) (i : Fin (n + 1)) :
    |scores q k i - scores q k' i| ≤ (∑ t, |q t|) * eps := by
  have hrw : scores q k i - scores q k' i = ∑ t, q t * (k i t - k' i t) := by
    simp only [scores]
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun t _ => by ring
  rw [hrw, Finset.sum_mul]
  calc |∑ t, q t * (k i t - k' i t)| ≤ ∑ t, |q t * (k i t - k' i t)| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ t, |q t| * eps := by
        refine Finset.sum_le_sum fun t _ => ?_
        rw [abs_mul]
        exact mul_le_mul_of_nonneg_left (h i t) (abs_nonneg _)

/-- The amplification is attained: with an all-ones query in dimension `d`, a
`δ`-perturbation of one key moves its logit by exactly `d · δ`.  Contrast with
`attn_value_perturbation_le`, where no such factor can ever appear. -/
theorem score_error_dim_amplified (d : ℕ) (eps : ℝ) (i : Fin (n + 1)) :
    |scores (fun _ : Fin d => (1 : ℝ)) (fun _ _ => eps) i
      - scores (fun _ : Fin d => (1 : ℝ)) (fun _ _ => 0) i| = d * |eps| := by
  simp only [scores, one_mul, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
    nsmul_eq_mul, mul_zero, sub_zero, abs_mul, Nat.abs_cast]

/-! ### 4. Two positions: tie versus decided -/

lemma attnOut_two (a b : ℝ) :
    attnOut (n := 1) ![a, b] ![1, 0] = Real.exp a / (Real.exp a + Real.exp b) := by
  simp [attnOut, softmax, Fin.sum_univ_two]

lemma attnOut_two_tie (a : ℝ) : attnOut (n := 1) ![a, a] ![1, 0] = 1 / 2 := by
  rw [attnOut_two]
  rw [div_eq_div_iff (by positivity) (by norm_num)]
  ring

/-- Three units of exponential: `exp 2 ≥ 3`. -/
lemma three_le_exp_two : (3 : ℝ) ≤ Real.exp 2 := by
  have := Real.add_one_le_exp (2 : ℝ)
  linarith

/-- A logit gap of `2` already forces the read-out past `3/4`: the softmax is a
*selection* nonlinearity, so an `O(1)` logit error is an `O(1)` output error. -/
lemma attnOut_two_gap (a b : ℝ) (h : b + 2 ≤ a) :
    3 / 4 ≤ attnOut (n := 1) ![a, b] ![1, 0] := by
  rw [attnOut_two, le_div_iff₀ (by positivity)]
  have h1 : Real.exp (b + 2) ≤ Real.exp a := Real.exp_le_exp.2 h
  have h2 : Real.exp (b + 2) = Real.exp b * Real.exp 2 := by
    rw [Real.exp_add]
  have h3 : (3 : ℝ) * Real.exp b ≤ Real.exp b * Real.exp 2 :=
    (mul_le_mul_of_nonneg_left three_le_exp_two (le_of_lt (Real.exp_pos b))).trans_eq'
      (by ring)
  linarith [h1, h2 ▸ h1]

/-! ### 5. Keys own the cliff -/

/-- **The cliff.**  For *every* key resolution `δ > 0` there is a query and a
pair of key caches within `δ` of each other whose attention read-outs differ by
at least `1/4`.  The damage does not shrink with `δ`: the key path has no
Lipschitz constant at all, because the query rescales the resolution away. -/
theorem key_quantization_annihilates (delta : ℝ) (hdelta : 0 < delta) :
    ∃ (q : Fin 1 → ℝ) (k k' : Fin 2 → Fin 1 → ℝ),
      (∀ i t, |k i t - k' i t| ≤ delta) ∧
      1 / 4 ≤ |attnOut (scores q k) ![1, 0] - attnOut (scores q k') ![1, 0]| := by
  refine ⟨![2 / delta], ![![delta], ![0]], ![![0], ![0]], ?_, ?_⟩
  · intro i t
    fin_cases i <;> fin_cases t <;>
      simp [abs_of_nonneg hdelta.le]
    linarith
  · have hk : scores ![2 / delta] ![![delta], ![0]] = ![2, 0] := by
      funext i
      fin_cases i <;>
        simp [scores, ne_of_gt hdelta]
    have hk' : scores ![2 / delta] ![![0], ![0]] = ![0, 0] := by
      funext i
      fin_cases i <;> simp [scores]
    rw [hk, hk']
    have h1 : 3 / 4 ≤ attnOut (n := 1) ![2, 0] ![1, 0] :=
      attnOut_two_gap 2 0 (by norm_num)
    have h2 : attnOut (n := 1) ![0, 0] ![1, 0] = 1 / 2 := attnOut_two_tie 0
    rw [h2]
    rw [abs_of_nonneg (by linarith)]
    linarith

/-- **The damage ratio is unbounded.**  For every `M` there is a cache
resolution `δ > 0` at which the worst-case key damage exceeds `M · δ`, while by
`attn_value_perturbation_le` the worst-case *value* damage at the same
resolution is at most `δ`.  No finite constant relates the two halves of the
cache; the measured `2.1 · 10⁵` is a property of the slice, not a ceiling. -/
theorem damage_ratio_unbounded (M : ℝ) (hM : 0 < M) :
    ∃ delta : ℝ, 0 < delta ∧
      ∃ (q : Fin 1 → ℝ) (k k' : Fin 2 → Fin 1 → ℝ),
        (∀ i t, |k i t - k' i t| ≤ delta) ∧
        M * delta ≤ |attnOut (scores q k) ![1, 0] - attnOut (scores q k') ![1, 0]| := by
  refine ⟨1 / (4 * M), by positivity, ?_⟩
  obtain ⟨q, k, k', hclose, hdam⟩ := key_quantization_annihilates (1 / (4 * M)) (by positivity)
  refine ⟨q, k, k', hclose, le_trans (le_of_eq ?_) hdam⟩
  field_simp

/-! ### 6. P1 refuted: no codebook of a given size can rescue the keys -/

/-- The damage inflicted by a *collision*: if a quantiser maps the two keys
`a ≠ b` to the same code `z`, then with the query `2/(a-b)` the exact read-out
is at least `3/4` while the quantised one is exactly `1/2`. -/
lemma key_collision_damage (a b z : ℝ) (hne : a ≠ b) :
    1 / 4 ≤ |attnOut (scores ![2 / (a - b)] ![![a], ![b]]) ![1, 0]
              - attnOut (scores ![2 / (a - b)] ![![z], ![z]]) ![1, 0]| := by
  have hab : a - b ≠ 0 := sub_ne_zero.2 hne
  have hk : scores ![2 / (a - b)] ![![a], ![b]] = ![2 / (a - b) * a, 2 / (a - b) * b] := by
    funext x
    fin_cases x <;> simp [scores]
  have hk' : scores ![2 / (a - b)] ![![z], ![z]] = ![2 / (a - b) * z, 2 / (a - b) * z] := by
    funext x
    fin_cases x <;> simp [scores]
  rw [hk, hk']
  have hgap : 2 / (a - b) * b + 2 ≤ 2 / (a - b) * a := by
    have hid : 2 / (a - b) * a - 2 / (a - b) * b = 2 := by
      field_simp
    linarith
  have h1 : 3 / 4 ≤ attnOut (n := 1) ![2 / (a - b) * a, 2 / (a - b) * b] ![1, 0] :=
    attnOut_two_gap _ _ hgap
  have h2 : attnOut (n := 1) ![2 / (a - b) * z, 2 / (a - b) * z] ![1, 0] = 1 / 2 :=
    attnOut_two_tie _
  rw [h2, abs_of_nonneg (by linarith)]
  linarith

/-- **No 4-bit format rescues the keys.**  Let `Q` be *any* key quantiser whose
codebook `C` has at most `N` entries (`q4_0`, `q4_1`, `iq4_nl`, or anything
else: no structure on `Q` is assumed).  Then there are two keys separated by at
least `1/N` that `Q` identifies, together with a query of norm at most `2N` for
which the exact read-out and the quantised read-out differ by at least `1/4`.

The bound depends only on the *cardinality* of the codebook, so block scales,
offsets and nonuniform codepoints are irrelevant — precisely the NET-93
observation that `q4_1` is marginally *worse* than raw `q4_0`. -/
theorem no_codebook_rescues_keys (N : ℕ) (hN : 0 < N) (Q : ℝ → ℝ) (C : Finset ℝ)
    (hQ : ∀ x, Q x ∈ C) (hC : C.card ≤ N) :
    ∃ a b : ℝ, a ≠ b ∧ Q a = Q b ∧ (1 : ℝ) / N ≤ |a - b| ∧
      ∃ q : Fin 1 → ℝ, |q 0| ≤ 2 * N ∧
        1 / 4 ≤ |attnOut (scores q ![![a], ![b]]) ![1, 0]
                  - attnOut (scores q ![![Q a], ![Q b]]) ![1, 0]| := by
  -- Pigeonhole: `N+1` equally spaced probes cannot receive `N+1` distinct codes.
  have hcard : C.card < (Finset.univ : Finset (Fin (N + 1))).card := by
    simpa using Nat.lt_succ_of_le hC
  obtain ⟨i, -, j, -, hij, hQij⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to hcard
      (f := fun i : Fin (N + 1) => Q ((i : ℝ) / N)) (fun i _ => hQ _)
  have hNpos : (0 : ℝ) < N := by exact_mod_cast hN
  have hN0 : (N : ℝ) ≠ 0 := ne_of_gt hNpos
  have hijR : ((i : ℕ) : ℝ) ≠ ((j : ℕ) : ℝ) := by
    intro h
    exact hij (Fin.ext (by exact_mod_cast h))
  have hne : ((i : ℕ) : ℝ) / N ≠ ((j : ℕ) : ℝ) / N := by
    intro h
    exact hijR (by field_simp at h; exact h)
  have hone : (1 : ℝ) ≤ |((i : ℕ) : ℝ) - ((j : ℕ) : ℝ)| := by
    rcases lt_or_gt_of_ne (fun h : (i : ℕ) = (j : ℕ) => hij (Fin.ext h)) with h | h
    · have hlt : ((i : ℕ) : ℝ) + 1 ≤ ((j : ℕ) : ℝ) := by exact_mod_cast h
      rw [abs_sub_comm, abs_of_nonneg (by linarith)]
      linarith
    · have hlt : ((j : ℕ) : ℝ) + 1 ≤ ((i : ℕ) : ℝ) := by exact_mod_cast h
      rw [abs_of_nonneg (by linarith)]
      linarith
  have hsep : (1 : ℝ) / N ≤ |((i : ℕ) : ℝ) / N - ((j : ℕ) : ℝ) / N| := by
    have hsub : ((i : ℕ) : ℝ) / N - ((j : ℕ) : ℝ) / N
        = (((i : ℕ) : ℝ) - ((j : ℕ) : ℝ)) / N := by ring
    rw [hsub, abs_div, abs_of_pos hNpos]
    gcongr
  refine ⟨((i : ℕ) : ℝ) / N, ((j : ℕ) : ℝ) / N, hne, hQij, hsep,
    ⟨![2 / (((i : ℕ) : ℝ) / N - ((j : ℕ) : ℝ) / N)], ?_, ?_⟩⟩
  · have hpos : 0 < |((i : ℕ) : ℝ) / N - ((j : ℕ) : ℝ) / N| := lt_of_lt_of_le (by positivity) hsep
    have hid : (2 * (N : ℝ)) * (1 / N) = 2 := by field_simp
    have hmul : (2 * (N : ℝ)) * (1 / N)
        ≤ (2 * (N : ℝ)) * |((i : ℕ) : ℝ) / N - ((j : ℕ) : ℝ) / N| := by
      exact mul_le_mul_of_nonneg_left hsep (by positivity)
    simp only [Matrix.cons_val_zero, abs_div]
    rw [div_le_iff₀ hpos]
    rw [hid] at hmul
    calc |(2 : ℝ)| = 2 := abs_of_nonneg (by norm_num)
      _ ≤ 2 * (N : ℝ) * |((i : ℕ) : ℝ) / N - ((j : ℕ) : ℝ) / N| := hmul
  · rw [← hQij]
    exact key_collision_damage _ _ (Q (((i : ℕ) : ℝ) / N)) hne

/-- **The value contrast.**  If a value quantiser has *resolution* `δ` (each
entry is moved by at most `δ` — the only thing a codebook needs to guarantee),
the read-out damage is at most `δ`, no matter the codebook size, the query, or
the context length.  Together with `no_codebook_rescues_keys` this is the NET-93
law: the entire cliff lives in the keys. -/
theorem value_codebook_damage_le (Qv : ℝ → ℝ) (delta : ℝ) (hres : ∀ x, |x - Qv x| ≤ delta)
    (s v : Fin (n + 1) → ℝ) :
    |attnOut s v - attnOut s (fun i => Qv (v i))| ≤ delta :=
  attn_value_perturbation_le s v _ delta (fun i => hres (v i))

end Catalog.Novelty.KeysOwnTheCliff