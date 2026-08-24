import Probability.NET76RationalDilation

/-!
# NET-76, cycle 3: the *token-matched* reading of the domain factor

Cycles 1 and 2 (`Probability.NET76DomainDilation`,
`Probability.NET76RationalDilation`) analysed the reported five-domain table under a
**matched-context** reading: a domain whose profile is a `c`-fold block dilation of the
English profile was compared with English at the *dilated* context `c·n`.  Under that
reading the factor law holds inside one dilation block,
`c·(k* − 1) < k*_dilated ≤ c·k*`.

But that is *not* how the reported experiment was run.  Every row of the NET-76 table
is measured at the **same token budget** — `ctx = 512` for every domain, then
`ctx = 1024` for every domain.  This file settles what the dilation mechanism predicts
under that, correct, **token-matched** reading, and the answer is sharply negative:

* `token_matched_factor_forces_stability` — if the token-matched factor law
  `k*(dilate c w, N) = c · k*(w, N)` holds at a single context `N = c·n`, then the base
  curve must satisfy `k*(w, n) = k*(w, N)`: the base knee is **flat** over the whole
  ratio `c`.  A constant domain factor at equal token counts is therefore possible only
  for a context-stable base curve.
* `rising_base_excludes_token_matched_factor` — contrapositive: a base curve that
  strictly rises over the ratio `c` (the reported `16 → 20` English chain does) admits
  *no* exact token-matched factor for any `c > 0`.
* `token_matched_window` — the exact quantitative reconciliation: the token-matched
  knee sits `c·D` below the naive prediction `c·k*(w, N)`, where `D` is the base
  increment over the ratio, with a residual window of width `c`.
* `french_row_token_matched_refuted` and `french_token_matched_factor_bound` — applied
  to the reported numbers: with English `k*@256 = 12`, `k*@512 = 16` (the `+4`
  law read backwards), *every* two-fold dilation has `k*@512 ≤ 24`, so the reported
  French value `32` is impossible, and the honest token-matched French factor is at
  most `3/2`, not the reported `2.0`.
* `french_row_forces_flat_english` — conversely, if one insists on the French `32`,
  then English must be flat between `256` and `512`, contradicting the very `+4`
  increment that the same table reports.
* On the compression side the merging law is *exact*, so the code row can be computed
  rather than bracketed: `code_row_token_matched_exact` gives
  `k*(contract 2 w, N) = 10` from `k*(w, 2N) = 20` — not the `8` that a factor `0.5`
  predicts — and `code_row_flatness_refuted` shows the token-matched merged curve moves
  by `+2` per doubling, so the reported `+0` code increment is not a merging artefact
  either.
* `net76_token_matched_verdict` collects the three findings into one statement.

Net verdict of cycle 3: **the reported multiplicative factor is a matched-context
quantity, and the experiment measured a token-matched one.**  The two agree only when
the base budget curve is flat over the factor's ratio — exactly the situation the same
table denies by reporting a positive doubling increment.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 3, 5 conjectures):
 (K1) Token-matched and matched-context factors differ by exactly the base increment
      over the factor ratio.                                            [confirmed: `token_matched_window`]
 (K2) An exact token-matched factor forces base context-stability.      [confirmed: `token_matched_factor_forces_stability`]
 (K3) The French row `32 @ 512` survives the token-matched reading.     [REFUTED: `french_row_token_matched_refuted`]
 (K4) The code row's `+0` increment is a merging (ceiling) artefact.    [REFUTED: `code_row_flatness_refuted`, increment is `+2`]
 (K5) Some hypothesis rescues the table token-matched.                  [only flatness of the base curve: K2 is an iff up to the gate condition,
                                                                         `stable_base_gives_token_matched_factor`]

Experimenter: the arithmetic inputs are the reported values
  English  k*@512 = 16, k*@1024 = 20   (so k*@256 = 12 under the reported +4 law)
  French   k*@512 = 32, k*@1024 = 40
  code     k*@512 = 12, k*@1024 = 12
and they enter every theorem below as *hypotheses*, never as axioms.

Analyst: the failure of K3 is of the "needs a different definition" kind for the
report and of the "false" kind for the mechanism: no positive profile, context or gate
makes a two-fold dilation reach `32` at the context where the base reaches `16` while
the base also rises by `4` per doubling.  The failure of K4 is quantitative: merging
transports the *doubled-context* base knee, so a base increment `+4` becomes `+2` after
merging by `2` — never `+0`.

Critic: no statement here is vacuous.  Each refutation is accompanied by the exact
window it violates (`token_matched_window`), the positive direction of K2 is supplied
with its gate hypothesis (`stable_base_gives_token_matched_factor`), and the code-row
computations are exact equalities obtained from the ceiling law, not bounds.
-/

namespace Catalog.Probability.NET76TokenMatched

open Finset AttentionBudget Catalog.Probability.NET76DomainDilation
open Catalog.Probability.NET76RationalDilation

variable {w : ℕ → ℝ} {c n : ℕ} {tau : ℝ}

/-! ## 1.  Token-matched versus matched-context factors -/

/-- **The reconciliation window.**  Write `K = k*(w, c·n)` for the base knee measured at
the *reported* context and `D = K - k*(w, n)` for the base increment across the ratio
`c`.  Then the dilated knee measured at the same context `c·n` lies in the window
`(c·(K - D) - c, c·(K - D)]`.  The naive token-matched prediction `c·K` is therefore too
large by exactly `c·D`, up to one dilation block. -/
theorem token_matched_window (hw : ∀ i, 0 < w i) (hc : 0 < c) (hn : 0 < n)
    (htau0 : 0 < tau) (htau : tau ≤ 1) :
    kstar (dilate c w) (c * n) tau ≤ c * kstar w n tau ∧
      c * kstar w n tau < kstar (dilate c w) (c * n) tau + c := by
  refine ⟨kstar_dilate_le_mul hw hc hn htau, ?_⟩
  have hlow := mul_pred_lt_kstar_dilate hw hc hn htau0 htau
  have hpos := kstar_pos hw hn htau0 htau
  have hck : c ≤ c * kstar w n tau := Nat.le_mul_of_pos_right c hpos
  have hsub : c * (kstar w n tau - 1) = c * kstar w n tau - c := by
    rw [Nat.mul_sub, Nat.mul_one]
  omega

/-- **K2 — an exact token-matched factor forces a flat base curve.**  If a domain's knee
at context `N = c·n` is exactly `c` times the *base* knee at the same context `N`, then
the base knee cannot have moved between `n` and `N`.  In other words: the multiplicative
domain factor, read at equal token counts, is available only to a context-stable base
budget curve. -/
theorem token_matched_factor_forces_stability (hw : ∀ i, 0 < w i) (hc : 0 < c) (hn : 0 < n)
    (htau0 : 0 < tau) (htau : tau ≤ 1)
    (hfactor : kstar (dilate c w) (c * n) tau = c * kstar w (c * n) tau) :
    kstar w n tau = kstar w (c * n) tau := by
  have hlow := mul_pred_lt_kstar_dilate hw hc hn htau0 htau
  have hup := kstar_dilate_le_mul hw hc hn htau
  have hpos := kstar_pos hw hn htau0 htau
  rw [hfactor] at hlow hup
  have h1 : kstar w (c * n) tau ≤ kstar w n tau := Nat.le_of_mul_le_mul_left hup hc
  have h2 : kstar w n tau - 1 < kstar w (c * n) tau := Nat.lt_of_mul_lt_mul_left hlow
  omega

/-- **Contrapositive of K2.**  A base curve that strictly rises across the ratio `c` —
which is precisely what the reported `+4` per doubling asserts — admits no exact
token-matched factor, for any dilation depth `c`. -/
theorem rising_base_excludes_token_matched_factor (hw : ∀ i, 0 < w i) (hc : 0 < c)
    (hn : 0 < n) (htau0 : 0 < tau) (htau : tau ≤ 1)
    (hrise : kstar w n tau < kstar w (c * n) tau) :
    kstar (dilate c w) (c * n) tau ≠ c * kstar w (c * n) tau := by
  intro hfactor
  have := token_matched_factor_forces_stability hw hc hn htau0 htau hfactor
  omega

/-- **Positive direction of K2.**  If the base curve *is* flat across the ratio `c`, and
the gate is not already cleared one key before the block boundary, the token-matched
factor law holds exactly.  Flatness is thus not merely necessary but (with the usual
gate condition) sufficient. -/
theorem stable_base_gives_token_matched_factor (hw : ∀ i, 0 < w i) (hc : 0 < c) (hn : 0 < n)
    (htau0 : 0 < tau) (htau : tau ≤ 1)
    (hstab : kstar w n tau = kstar w (c * n) tau)
    (hgate : retained (dilate c w) (c * n) (c * kstar w n tau - 1) < tau) :
    kstar (dilate c w) (c * n) tau = c * kstar w (c * n) tau := by
  rw [← hstab]
  exact kstar_dilate_eq_mul hw hc hn htau0 htau hgate

/-! ## 2.  The French row under the token-matched reading -/

/-- **K3 refuted.**  Take the reported English chain read backwards by its own `+4` law:
`k*@256 = 12`, `k*@512 = 16`.  Then *every* two-fold dilation of that profile has a knee
of at most `24` at `ctx = 512`.  The reported French value `32` is out of reach — no
positive profile, no context scale and no gate can produce it by two-fold dilation at
equal token counts. -/
theorem french_row_token_matched_refuted (hw : ∀ i, 0 < w i) (hn : 0 < n)
    (htau : tau ≤ 1) (h256 : kstar w n tau = 12) :
    kstar (dilate 2 w) (2 * n) tau ≤ 24 ∧ kstar (dilate 2 w) (2 * n) tau ≠ 32 := by
  have hup := kstar_dilate_le_mul (w := w) (c := 2) hw (by norm_num) hn htau
  rw [h256] at hup
  refine ⟨by omega, by omega⟩

/-- **The honest French factor.**  Under the same hypotheses the token-matched French
factor — the ratio of the dilated knee to the base knee *at the same context* — is at
most `3/2`, and at least `11/8`; the reported `2.0` lies outside that window. -/
theorem french_token_matched_factor_bound (hw : ∀ i, 0 < w i) (hn : 0 < n)
    (htau0 : 0 < tau) (htau : tau ≤ 1)
    (h256 : kstar w n tau = 12) (h512 : kstar w (2 * n) tau = 16) :
    (11 / 8 : ℝ) * kstar w (2 * n) tau < (kstar (dilate 2 w) (2 * n) tau : ℝ) ∧
      (kstar (dilate 2 w) (2 * n) tau : ℝ) ≤ (3 / 2 : ℝ) * kstar w (2 * n) tau := by
  have hup := kstar_dilate_le_mul (w := w) (c := 2) hw (by norm_num) hn htau
  have hlow := mul_pred_lt_kstar_dilate (w := w) (c := 2) hw (by norm_num) hn htau0 htau
  rw [h256] at hup hlow
  have h1 : (22 : ℕ) < kstar (dilate 2 w) (2 * n) tau := by omega
  have h2 : kstar (dilate 2 w) (2 * n) tau ≤ 24 := by omega
  have h1' : (22 : ℝ) < (kstar (dilate 2 w) (2 * n) tau : ℝ) := by exact_mod_cast h1
  have h2' : (kstar (dilate 2 w) (2 * n) tau : ℝ) ≤ 24 := by exact_mod_cast h2
  rw [h512]
  constructor
  · push_cast; linarith
  · push_cast; linarith

/-- **The price of keeping the French `32`.**  If one insists that the French knee at
`ctx = 512` really is `32` *and* that French is a two-fold dilation of English, then the
English knee at `256` equals the English knee at `512`: the base curve is flat over that
doubling.  The same table reports a `+4` increment per doubling, so the two claims are
inconsistent. -/
theorem french_row_forces_flat_english (hw : ∀ i, 0 < w i) (hn : 0 < n)
    (htau0 : 0 < tau) (htau : tau ≤ 1)
    (h512 : kstar w (2 * n) tau = 16)
    (hfr : kstar (dilate 2 w) (2 * n) tau = 32) :
    kstar w n tau = 16 ∧ kstar w n tau = kstar w (2 * n) tau := by
  have hstab : kstar w n tau = kstar w (2 * n) tau :=
    token_matched_factor_forces_stability (w := w) (c := 2) hw (by norm_num) hn htau0 htau
      (by rw [hfr, h512])
  exact ⟨by rw [hstab, h512], hstab⟩

/-! ## 3.  The code row: exact values from the merging law -/

/-- **The code row, computed exactly.**  Merging pairs of keys transports the base knee
measured at the *doubled* context.  With the reported English `k*@1024 = 20`, the merged
profile has knee exactly `10` at `ctx = 512` — not the `8` that a naive factor `0.5`
applied to `k*@512 = 16` predicts.  The token-matched compression factor is `5/8`, not
`1/2`. -/
theorem code_row_token_matched_exact (hw : ∀ i, 0 < w i) (hn : 0 < n) (htau : tau ≤ 1)
    (h1024 : kstar w (2 * n) tau = 20) :
    kstar (contract 2 w) n tau = 10 := by
  rw [kstar_contract_eq hw (by norm_num) hn htau, h1024]

/-- **K4 refuted.**  Continue the reported `+4` law one step (`k*@2048 = 24`).  Then the
merged curve reads `10` at `512` and `12` at `1024`: a `+2` increment.  A flat `+0`
column — the signature the report attributes to the code domain — cannot be produced by
merging a base curve with a positive increment. -/
theorem code_row_flatness_refuted (hw : ∀ i, 0 < w i) (hn : 0 < n) (htau : tau ≤ 1)
    (h1024 : kstar w (2 * n) tau = 20) (h2048 : kstar w (2 * (2 * n)) tau = 24) :
    kstar (contract 2 w) n tau = 10 ∧ kstar (contract 2 w) (2 * n) tau = 12 ∧
      kstar (contract 2 w) n tau ≠ kstar (contract 2 w) (2 * n) tau := by
  have h1 : kstar (contract 2 w) n tau = 10 := code_row_token_matched_exact hw hn htau h1024
  have h2 : kstar (contract 2 w) (2 * n) tau = 12 := by
    rw [kstar_contract_eq hw (by norm_num) (by omega) htau, h2048]
  exact ⟨h1, h2, by omega⟩

/-- **General merging increment law.**  Merging by `q` turns a base increment
`k*(w, 2·q·n) = k*(w, q·n) + D` into a merged increment of `⌈(K+D)/q⌉ - ⌈K/q⌉`, which is
zero only if the ceiling absorbs the whole increment.  Quantitatively: the merged
increment is at least `(D - q + 1)/q`, so a base increment `D ≥ q` always survives
merging. -/
theorem merged_increment_positive (hw : ∀ i, 0 < w i) {q : ℕ} (hq : 0 < q) (hn : 0 < n)
    (htau : tau ≤ 1) {K D : ℕ} (hD : q ≤ D)
    (hbase : kstar w (q * n) tau = K)
    (hbase2 : kstar w (q * (2 * n)) tau = K + D) :
    kstar (contract q w) n tau < kstar (contract q w) (2 * n) tau := by
  rw [kstar_contract_eq hw hq hn htau, hbase,
    kstar_contract_eq hw hq (by omega) htau, hbase2]
  -- adding `D ≥ q` to the numerator raises the quotient by at least one
  have hmono : (K + q - 1) / q + 1 ≤ (K + q - 1 + q) / q := by
    rw [Nat.add_div_right _ hq]
  have hle : (K + q - 1 + q) / q ≤ (K + D + q - 1) / q :=
    Nat.div_le_div_right (by omega)
  omega

/-! ## 4.  Cycle-3 verdict -/

/-- **Cycle-3 capstone.**  For one and the same English profile, context scale and gate,
all three findings hold simultaneously:

1. no exact token-matched factor exists at any depth `c` while the base curve rises
   across the ratio (here: across the doubling `n → 2n`);
2. the reported French value `32 @ 512` is unattainable by two-fold dilation, the true
   token-matched window being `(22, 24]`;
3. the reported flat code column is unattainable by pair merging, the merged curve
   moving by `+2`.

Hence the verdict "the domain factor is multiplicative" is a matched-context statement
that the token-matched experiment cannot support. -/
theorem net76_token_matched_verdict (hw : ∀ i, 0 < w i) (hn : 0 < n)
    (htau0 : 0 < tau) (htau : tau ≤ 1)
    (h256 : kstar w n tau = 12) (h512 : kstar w (2 * n) tau = 16)
    (h1024 : kstar w (2 * (2 * n)) tau = 20) (h2048 : kstar w (2 * (2 * (2 * n))) tau = 24) :
    kstar (dilate 2 w) (2 * n) tau ≠ 2 * kstar w (2 * n) tau ∧
      (22 < kstar (dilate 2 w) (2 * n) tau ∧ kstar (dilate 2 w) (2 * n) tau ≤ 24) ∧
      kstar (contract 2 w) (2 * n) tau = 10 ∧
        kstar (contract 2 w) (2 * (2 * n)) tau = 12 := by
  have hup := kstar_dilate_le_mul (w := w) (c := 2) hw (by norm_num) hn htau
  have hlow := mul_pred_lt_kstar_dilate (w := w) (c := 2) hw (by norm_num) hn htau0 htau
  rw [h256] at hup hlow
  refine ⟨?_, ⟨by omega, by omega⟩, ?_, ?_⟩
  · rw [h512]; omega
  · exact code_row_token_matched_exact hw (by omega) htau h1024
  · rw [kstar_contract_eq hw (by norm_num) (by omega) htau, h2048]

end Catalog.Probability.NET76TokenMatched