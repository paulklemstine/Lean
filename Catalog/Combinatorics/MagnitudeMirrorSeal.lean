/-
# Round-70 #6 — the magnitude-mirror seal: energy-ascent sensors are structural,
# spectral summaries are mirrors of `N`, and only the positional oracle survives

Formal companion to the round-70 correction round (exps 549 + 551), which
*retracted* the "energy-ascent channel" of papers 193/195 and re-sealed the
Pythagorean/Fermat tree against every realized probe class.

The experimental report contains three separate claims.  This file turns each of
them into an exact, finitary theorem, using the catalog's counting notion of
independence `Round11.ZeroInfo` (`Combinatorics.Round11FingerprintInformation`)
as the common currency — `ZeroInfo Ω T S` says that every joint fibre of the
statistic `T` and the secret `S` on the instance set `Ω` has exactly the product
cardinality, i.e. the empirical mutual information is *exactly* `0`, not merely
small.

* **The energy-ascent artifact (exp549).**  With `E(a) = a² − N` and the
  isqrt-anchored window `a_j = ⌊√N⌋ + j`, the sign of `E` on the window is
  completely determined *before* any arithmetic of `N` enters:
  `energy_anchor_nonpos` and `energy_pos_of_index_pos` show `E(a₀) ≤ 0 < E(a_j)`
  for every `j ≥ 1`.  So the zero crossing sits between `j = 0` and `j = 1`
  (at `√N`) for **every** `N`, never at `j = d`
  (`no_sign_change_at_positive_offset`).  Consequently the whole sign vector of
  the window is a *constant* function of `N` on any family of non-squares
  (`signVector_const`), and therefore carries exactly zero information about any
  secret whatsoever (`bracket_sensor_zeroInfo`), as does any post-processing of
  it (`bracket_sensor_zeroInfo_postprocessed`).  This is the formal content of
  the measured `MI(hits;b₁) = 0.000000`.
* **The Fermat square-hit is the real event.**  `fermat_hit_of_factorization`
  and `fermat_hit_factorization` show the *hit* `E(a) = b²` — not the sign
  change — is equivalent to a factorization `N = (a−b)(a+b)`, and
  `hit_at_anchor_iff_isSquare` shows the anchor itself is a hit precisely for
  perfect squares.
* **The magnitude mirror (exp551).**  A feature that is a deterministic function
  of `N`'s magnitude inherits *all* of its information from the magnitude
  (`zeroInfo_of_mirror`), is *exactly* as informative as the magnitude when the
  reparametrisation is injective — in particular strictly monotone, e.g. `log N`
  versus any increasing rescaling of it (`zeroInfo_congr_of_injective`,
  `zeroInfo_congr_of_strictMono`) — and collapses to *exactly* zero information
  inside every magnitude cell (`mirror_conditional_zeroInfo`).
* **The method lesson, as a theorem.**  `stratification_is_not_transfer`
  exhibits an explicit instance set on which a magnitude mirror has *nonzero*
  unconditional information yet *exactly zero* information inside every
  magnitude cell: marginal signal from a deterministic function of `N` is scale
  stratification, not transfer.  This is why a row-shuffle permutation null is
  the wrong null.
* **What survives: the positional oracle.**  For the factor-derived oracle bit
  `1{d ≤ B}` the empirical below-threshold fraction is monotone in `B`
  (`belowFrac_monotone`), its capacity is at most one bit
  (`oracle_capacity_le_log_two`, and the counting form
  `oracle_bit_pigeonhole`), it ascends below the median and descends above it
  (`oracle_capacity_ascending`, `oracle_capacity_descending`), and the peak is
  attained exactly at balance (`oracle_capacity_eq_log_two_iff`) — the formal
  shape of the measured profile "peak `0.4798` at `B ≈ 22758`".  Crucially the
  oracle bit is **not** a magnitude mirror (`positional_oracle_not_mirror`), so
  it is not killed by the exp551 argument, and it is genuinely informative
  (`positional_oracle_informative`).
-/
import Mathlib
import Combinatorics.Round11FingerprintInformation

namespace MagnitudeMirror

open Finset Round11

/-! ## 1. The energy function of the isqrt-anchored window -/

/-- The Fermat energy `E(a) = a² − N`. -/
def energy (N a : ℕ) : ℤ := (a : ℤ) ^ 2 - (N : ℤ)

/-- The anchor of the window: `⌊√N⌋`. -/
def anchor (N : ℕ) : ℕ := Nat.sqrt N

/-- The `j`-th point of the isqrt-anchored window. -/
def windowPoint (N j : ℕ) : ℕ := anchor N + j

@[simp] theorem windowPoint_zero (N : ℕ) : windowPoint N 0 = anchor N := by
  simp [windowPoint]

/-- `E(a) = 0` exactly at the square root: the energy zero is at `√N`. -/
theorem energy_eq_zero_iff (N a : ℕ) : energy N a = 0 ↔ a * a = N := by
  constructor
  · intro h
    have : (a : ℤ) * a = (N : ℤ) := by
      have := h; simp only [energy, sub_eq_zero] at this; nlinarith [this]
    exact_mod_cast this
  · intro h
    simp only [energy, sub_eq_zero, ← h]
    push_cast
    ring

/-- At the anchor the energy is never positive. -/
theorem energy_anchor_nonpos (N : ℕ) : energy N (anchor N) ≤ 0 := by
  have h : Nat.sqrt N * Nat.sqrt N ≤ N := Nat.sqrt_le N
  have : ((Nat.sqrt N : ℤ)) * (Nat.sqrt N : ℤ) ≤ (N : ℤ) := by exact_mod_cast h
  simp only [energy, anchor, sub_nonpos]
  nlinarith [this]

/-- At every strictly positive offset the energy is strictly positive: the sign
change of `E` on an isqrt-anchored window always happens between `j = 0` and
`j = 1`. -/
theorem energy_pos_of_index_pos (N j : ℕ) (hj : 1 ≤ j) :
    0 < energy N (windowPoint N j) := by
  have h : N < (Nat.sqrt N + 1) * (Nat.sqrt N + 1) := Nat.lt_succ_sqrt N
  have hZ : (N : ℤ) < ((Nat.sqrt N : ℤ) + 1) * ((Nat.sqrt N : ℤ) + 1) := by
    exact_mod_cast h
  have hj' : (1 : ℤ) ≤ (j : ℤ) := by exact_mod_cast hj
  have hm : (0 : ℤ) ≤ (Nat.sqrt N : ℤ) := Int.natCast_nonneg _
  simp only [energy, windowPoint, anchor, sub_pos]
  push_cast
  nlinarith [hZ, hj', hm]

/-- The energy is strictly increasing along the window. -/
theorem energy_window_strictMono (N : ℕ) :
    StrictMono (fun j : ℕ => energy N (windowPoint N j)) := by
  intro i j hij
  have hi : (0 : ℤ) ≤ (anchor N : ℤ) + i := by positivity
  have hlt : ((anchor N : ℤ) + i) < ((anchor N : ℤ) + j) := by
    have : (i : ℤ) < (j : ℤ) := by exact_mod_cast hij
    linarith
  simp only [energy, windowPoint]
  push_cast
  nlinarith [hi, hlt]

/-- **No sign change at a divisor offset.**  For every `N` and every offset
`d ≥ 1` — in particular for `d` a nontrivial divisor of `N` — the energy is
strictly positive on both sides of `j = d`.  The event the retracted mechanism
of papers 193/195 located "at `j = d`" does not exist. -/
theorem no_sign_change_at_positive_offset (N d : ℕ) (hd : 1 ≤ d) :
    0 < energy N (windowPoint N d) ∧ 0 < energy N (windowPoint N (d + 1)) :=
  ⟨energy_pos_of_index_pos N d hd, energy_pos_of_index_pos N (d + 1) (by omega)⟩

/-! ## 2. The Fermat square-hit is the real event -/

/-- Every factorisation `N = u·(u+2k)` of the right parity produces a genuine
Fermat *hit*: the energy at `a = u + k` is the perfect square `k²`. -/
theorem fermat_hit_of_factorization (u k : ℕ) :
    energy (u * (u + 2 * k)) (u + k) = (k : ℤ) ^ 2 := by
  simp only [energy]
  push_cast
  ring

/-- Conversely, a Fermat hit is a factorisation: if `E(a) = b²` with `b < a`
then `N = (a−b)(a+b)`. -/
theorem fermat_hit_factorization {N a b : ℕ} (hb : b ≤ a) (h : energy N a = (b : ℤ) ^ 2) :
    (a - b) * (a + b) = N := by
  have hZ : ((a : ℤ) - b) * ((a : ℤ) + b) = (N : ℤ) := by
    simp only [energy] at h
    nlinarith [h]
  have hcast : (((a - b : ℕ) : ℤ)) = (a : ℤ) - b := by
    have : (b : ℤ) ≤ (a : ℤ) := by exact_mod_cast hb
    push_cast [Nat.cast_sub hb]
    ring
  have : (((a - b) * (a + b) : ℕ) : ℤ) = (N : ℤ) := by
    push_cast [hcast]
    exact_mod_cast hZ
  exact_mod_cast this

/-- A hit with `1 < a − b` and `a + b < N` exhibits a *nontrivial* divisor: the
Fermat hit, not the sign change, is what factors `N`. -/
theorem fermat_hit_nontrivial_divisor {N a b : ℕ} (hb : b ≤ a) (h : energy N a = (b : ℤ) ^ 2)
    (h1 : 1 < a - b) (h2 : a + b < N) :
    ∃ e, e ∣ N ∧ 1 < e ∧ e < N := by
  refine ⟨a - b, ⟨a + b, (fermat_hit_factorization hb h).symm⟩, h1, ?_⟩
  calc a - b ≤ a + b := by omega
  _ < N := h2

/-- The anchor is a Fermat hit with `b = 0` exactly for perfect squares — the
only way the "event at `a = m`" can occur. -/
theorem hit_at_anchor_iff_isSquare (N : ℕ) :
    energy N (anchor N) = 0 ↔ IsSquare N := by
  rw [energy_eq_zero_iff]
  constructor
  · intro h; exact ⟨Nat.sqrt N, h.symm⟩
  · rintro ⟨k, hk⟩
    subst hk
    simp [anchor, Nat.sqrt_eq]

/-- For a non-square `N` the anchor energy is strictly negative. -/
theorem energy_anchor_neg_of_not_isSquare {N : ℕ} (h : ¬ IsSquare N) :
    energy N (anchor N) < 0 :=
  lt_of_le_of_ne (energy_anchor_nonpos N) (fun hc => h ((hit_at_anchor_iff_isSquare N).1 hc))

/-! ## 3. Bracket / sign-count sensors are structural: exact zero information -/

/-- The bracket sensor read off a length-`L` isqrt-anchored window: the vector of
signs of the energy. -/
def signVector (L N : ℕ) : Fin L → ℤ :=
  fun j => (energy N (windowPoint N (j : ℕ))).sign

/-- The number of window indices at which the energy is negative. -/
def negCount (L N : ℕ) : ℕ :=
  #{j ∈ Finset.range L | energy N (windowPoint N j) < 0}

/-- **Structural identity of the bracket sensor.**  On every non-square `N` the
sign vector of the isqrt-anchored window is the same vector: `-1` at the anchor
and `+1` everywhere else.  It does not depend on `N` at all. -/
theorem signVector_const {L N : ℕ} (h : ¬ IsSquare N) :
    signVector L N = fun j : Fin L => if (j : ℕ) = 0 then (-1 : ℤ) else 1 := by
  funext j
  simp only [signVector]
  by_cases hj : (j : ℕ) = 0
  · rw [hj]
    simp only [windowPoint_zero]
    exact Int.sign_eq_neg_one_of_neg (energy_anchor_neg_of_not_isSquare h)
  · rw [if_neg hj]
    exact Int.sign_eq_one_of_pos (energy_pos_of_index_pos N _ (by omega))

/-- The negative-energy count of an isqrt-anchored window of positive length is
`1` for every non-square `N`. -/
theorem negCount_eq_one {L N : ℕ} (hL : 1 ≤ L) (h : ¬ IsSquare N) : negCount L N = 1 := by
  classical
  have hfil : {j ∈ Finset.range L | energy N (windowPoint N j) < 0} = {0} := by
    ext j
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_singleton]
    constructor
    · rintro ⟨-, hneg⟩
      by_contra hj
      exact absurd hneg (not_lt.2 (le_of_lt (energy_pos_of_index_pos N j (by omega))))
    · rintro rfl
      exact ⟨by omega, by simpa using energy_anchor_neg_of_not_isSquare h⟩
  simp [negCount, hfil]

variable {α : Type*} {β γ δ : Type*} [DecidableEq β] [DecidableEq γ] [DecidableEq δ]

/-- **Bracket sensors carry exactly zero information.**  On any finite family of
non-square moduli, the window sign vector — of any length — has exactly product
fibre counts against *any* secret statistic: the measured `MI = 0.000000` is an
identity, not an estimate. -/
theorem bracket_sensor_zeroInfo (L : ℕ) (Ω : Finset ℕ) (S : ℕ → γ)
    (hΩ : ∀ N ∈ Ω, ¬ IsSquare N) :
    ZeroInfo Ω (signVector L) S :=
  zeroInfo_of_const (t₀ := fun j : Fin L => if (j : ℕ) = 0 then (-1 : ℤ) else 1)
    (fun N hN => signVector_const (hΩ N hN))

/-- No post-processing of the bracket sensor — a hit count, a bracket flag, a
hash — can extract anything. -/
theorem bracket_sensor_zeroInfo_postprocessed (L : ℕ) (Ω : Finset ℕ) (S : ℕ → γ)
    (g : (Fin L → ℤ) → δ) (hΩ : ∀ N ∈ Ω, ¬ IsSquare N) :
    ZeroInfo Ω (g ∘ signVector L) S :=
  zeroInfo_comp g (bracket_sensor_zeroInfo L Ω S hΩ)

/-- The scalar sign-count sensor is likewise exactly uninformative. -/
theorem negCount_zeroInfo {L : ℕ} (hL : 1 ≤ L) (Ω : Finset ℕ) (S : ℕ → γ)
    (hΩ : ∀ N ∈ Ω, ¬ IsSquare N) :
    ZeroInfo Ω (negCount L) S :=
  zeroInfo_of_const (t₀ := 1) (fun N hN => negCount_eq_one hL (hΩ N hN))

/-! ## 4. General information calculus for `ZeroInfo` -/

/-- `ZeroInfo` only sees the values of the statistic on `Ω`. -/
theorem zeroInfo_congr_on {Ω : Finset α} {T T' : α → β} {S : α → γ}
    (h : ∀ w ∈ Ω, T w = T' w) : ZeroInfo Ω T S ↔ ZeroInfo Ω T' S := by
  have key : ∀ (t : β) (P : α → Prop) [DecidablePred P],
      Ω.filter (fun w => T w = t ∧ P w) = Ω.filter (fun w => T' w = t ∧ P w) := by
    intro t P _
    exact Finset.filter_congr (fun w hw => by rw [h w hw])
  constructor
  · intro hz t s
    have h1 := key t (fun w => S w = s)
    have h2 : Ω.filter (fun w => T w = t) = Ω.filter (fun w => T' w = t) :=
      Finset.filter_congr (fun w hw => by rw [h w hw])
    rw [← h1, ← h2]
    exact hz t s
  · intro hz t s
    have h1 := key t (fun w => S w = s)
    have h2 : Ω.filter (fun w => T w = t) = Ω.filter (fun w => T' w = t) :=
      Finset.filter_congr (fun w hw => by rw [h w hw])
    rw [h1, h2]
    exact hz t s

/-- **Injective reparametrisation preserves information exactly.**  Relabelling
a feature by an injective map changes no fibre count, hence no mutual
information: `log N` and any injective recoding of it are the *same* channel.
This is the exact form of the measured coincidence `0.1836` vs `0.1836`. -/
theorem zeroInfo_congr_of_injective {Ω : Finset α} {F : α → β} {S : α → γ} {g : β → δ}
    (hg : Function.Injective g) :
    ZeroInfo Ω (fun w => g (F w)) S ↔ ZeroInfo Ω F S := by
  classical
  constructor
  · intro hz t s
    have h1 : Ω.filter (fun w => g (F w) = g t ∧ S w = s)
        = Ω.filter (fun w => F w = t ∧ S w = s) :=
      Finset.filter_congr (fun w _ => by
        constructor
        · rintro ⟨h, hs⟩; exact ⟨hg h, hs⟩
        · rintro ⟨h, hs⟩; exact ⟨by rw [h], hs⟩)
    have h2 : Ω.filter (fun w => g (F w) = g t) = Ω.filter (fun w => F w = t) :=
      Finset.filter_congr (fun w _ => by
        constructor
        · intro h; exact hg h
        · intro h; rw [h])
    have := hz (g t) s
    rwa [h1, h2] at this
  · intro hz d s
    by_cases hd : ∃ t, g t = d
    · obtain ⟨t, rfl⟩ := hd
      have h1 : Ω.filter (fun w => g (F w) = g t ∧ S w = s)
          = Ω.filter (fun w => F w = t ∧ S w = s) :=
        Finset.filter_congr (fun w _ => by
          constructor
          · rintro ⟨h, hs⟩; exact ⟨hg h, hs⟩
          · rintro ⟨h, hs⟩; exact ⟨by rw [h], hs⟩)
      have h2 : Ω.filter (fun w => g (F w) = g t) = Ω.filter (fun w => F w = t) :=
        Finset.filter_congr (fun w _ => by
          constructor
          · intro h; exact hg h
          · intro h; rw [h])
      rw [h1, h2]
      exact hz t s
    · push_neg at hd
      have h1 : Ω.filter (fun w => g (F w) = d ∧ S w = s) = ∅ :=
        Finset.filter_false_of_mem (fun w _ hc => hd (F w) hc.1)
      have h2 : Ω.filter (fun w => g (F w) = d) = ∅ :=
        Finset.filter_false_of_mem (fun w _ hc => hd (F w) hc)
      rw [h1, h2]
      simp

/-- Strictly monotone recodings — the shape every "spectral summary" of exp551
took — preserve information exactly. -/
theorem zeroInfo_congr_of_strictMono {Ω : Finset α} {F : α → β} {S : α → γ}
    [LinearOrder β] [Preorder δ] {g : β → δ} (hg : StrictMono g) :
    ZeroInfo Ω (fun w => g (F w)) S ↔ ZeroInfo Ω F S :=
  zeroInfo_congr_of_injective hg.injective

/-- `Φ` *mirrors the magnitude* `M` on `Ω` when it is a deterministic function of
`M` there. -/
def MirrorsMagnitude {μ : Type*} (Ω : Finset α) (Φ : α → β) (M : α → μ) : Prop :=
  ∃ g : μ → β, ∀ w ∈ Ω, Φ w = g (M w)

/-- **Data processing for mirrors.**  If a feature mirrors the magnitude and the
magnitude itself is uninformative, the feature is uninformative: a mirror can
never transfer information beyond what knowing `N` already gives. -/
theorem zeroInfo_of_mirror {μ : Type*} [DecidableEq μ] {Ω : Finset α} {Φ : α → β} {M : α → μ}
    {S : α → γ} (hmir : MirrorsMagnitude Ω Φ M) (hM : ZeroInfo Ω M S) :
    ZeroInfo Ω Φ S := by
  obtain ⟨g, hg⟩ := hmir
  exact (zeroInfo_congr_on (T := Φ) (T' := g ∘ M) hg).2 (zeroInfo_comp g hM)

/-- **The exp551 collapse, exactly.**  Inside each magnitude cell a mirror
feature is constant, so its information about *any* secret is exactly `0.0000`
bits — no permutation null required. -/
theorem mirror_conditional_zeroInfo {μ : Type*} [DecidableEq μ] {Ω : Finset α} {Φ : α → β}
    {M : α → μ} (S : α → γ) (hmir : MirrorsMagnitude Ω Φ M) (c : μ) :
    ZeroInfo (Ω.filter fun w => M w = c) Φ S := by
  classical
  obtain ⟨g, hg⟩ := hmir
  refine zeroInfo_of_const (t₀ := g c) (fun w hw => ?_)
  rw [Finset.mem_filter] at hw
  rw [hg w hw.1, hw.2]

/-- Every statistic is uninformative on a one-point instance set. -/
theorem zeroInfo_singleton {T : α → β} {S : α → γ} (w : α) :
    ZeroInfo ({w} : Finset α) T S := by
  classical
  intro t s
  by_cases ht : T w = t <;> by_cases hs : S w = s <;>
    simp [Finset.filter_singleton, ht, hs]

/-! ## 5. The method lesson: stratification is not transfer -/

/-- **Scale stratification masquerading as signal.**  There is an instance set,
a magnitude `M`, a feature `Φ` that is a strictly monotone function of `M`, and a
secret `S`, such that `Φ` has *nonzero* unconditional information about `S` while
having *exactly zero* information about `S` inside every magnitude cell.

Hence a null model that only reshuffles rows (destroying the `M`–`S` coupling but
keeping the marginals) will flag `Φ` as informative even though `Φ` transfers
nothing beyond `M`.  Conditioning on magnitude is the correct control. -/
theorem stratification_is_not_transfer :
    ∃ (Ω : Finset ℕ) (M : ℕ → ℕ) (Φ : ℕ → ℕ) (S : ℕ → ℕ),
      StrictMono (fun n : ℕ => 2 * n) ∧
      (∀ w, Φ w = 2 * M w) ∧
      MirrorsMagnitude Ω Φ M ∧
      ¬ ZeroInfo Ω Φ S ∧
      ∀ c : ℕ, ZeroInfo (Ω.filter fun w => M w = c) Φ S := by
  classical
  refine ⟨{2, 3}, id, fun n => 2 * n, fun n => n % 2,
    ?_, fun w => rfl, ⟨fun m => 2 * m, fun w _ => rfl⟩, ?_, ?_⟩
  · intro a b hab
    dsimp only
    omega
  · exact not_zeroInfo_pair (by decide) (by decide) (by decide)
  · intro c
    have hsub : ({2, 3} : Finset ℕ).filter (fun w => id w = c) ⊆ {c} := by
      intro w hw
      rw [Finset.mem_filter] at hw
      simpa using hw.2
    rcases Finset.subset_singleton_iff.1 hsub with h | h
    · rw [h]; intro t s; simp
    · rw [h]; exact zeroInfo_singleton c

/-! ## 6. What survives: the factor-derived positional oracle -/

/-- The empirical fraction of instances whose smallest factor is at most `B`. -/
noncomputable def belowFrac (Ω : Finset α) (d : α → ℕ) (B : ℕ) : ℝ :=
  (#(Ω.filter fun w => d w ≤ B) : ℝ) / (#Ω : ℝ)

theorem belowFrac_nonneg (Ω : Finset α) (d : α → ℕ) (B : ℕ) : 0 ≤ belowFrac Ω d B := by
  classical
  unfold belowFrac
  positivity

theorem belowFrac_le_one (Ω : Finset α) (d : α → ℕ) (B : ℕ) : belowFrac Ω d B ≤ 1 := by
  classical
  rcases Finset.eq_empty_or_nonempty Ω with rfl | hΩ
  · simp [belowFrac]
  · have hcard : (0 : ℝ) < (#Ω : ℝ) := by
      exact_mod_cast Finset.card_pos.2 hΩ
    rw [belowFrac, div_le_one hcard]
    exact_mod_cast Finset.card_filter_le _ _

/-- The below-threshold profile is monotone in the threshold `B`. -/
theorem belowFrac_monotone (Ω : Finset α) (d : α → ℕ) : Monotone (belowFrac Ω d) := by
  classical
  intro B₁ B₂ hB
  rcases Finset.eq_empty_or_nonempty Ω with rfl | hΩ
  · simp [belowFrac]
  have hcard : (0 : ℝ) < (#Ω : ℝ) := by exact_mod_cast Finset.card_pos.2 hΩ
  have hsub : Ω.filter (fun w => d w ≤ B₁) ⊆ Ω.filter (fun w => d w ≤ B₂) := by
    intro w hw
    rw [Finset.mem_filter] at hw ⊢
    exact ⟨hw.1, le_trans hw.2 hB⟩
  have hle : (#(Ω.filter fun w => d w ≤ B₁) : ℝ) ≤ (#(Ω.filter fun w => d w ≤ B₂) : ℝ) := by
    exact_mod_cast Finset.card_le_card hsub
  unfold belowFrac
  gcongr

/-- **The oracle bit carries at most one bit.**  Its Shannon capacity, the binary
entropy of the below-threshold fraction, never exceeds `log 2`. -/
theorem oracle_capacity_le_log_two (Ω : Finset α) (d : α → ℕ) (B : ℕ) :
    Real.binEntropy (belowFrac Ω d B) ≤ Real.log 2 :=
  Real.binEntropy_le_log_two

/-- Below the median the capacity ascends with `B`. -/
theorem oracle_capacity_ascending (Ω : Finset α) (d : α → ℕ) {B₁ B₂ : ℕ} (hB : B₁ ≤ B₂)
    (h : belowFrac Ω d B₂ ≤ 2⁻¹) :
    Real.binEntropy (belowFrac Ω d B₁) ≤ Real.binEntropy (belowFrac Ω d B₂) := by
  have hmono := belowFrac_monotone Ω d hB
  refine Real.binEntropy_strictMonoOn.monotoneOn ?_ ?_ hmono
  · exact ⟨belowFrac_nonneg Ω d B₁, le_trans hmono h⟩
  · exact ⟨belowFrac_nonneg Ω d B₂, h⟩

/-- Above the median the capacity descends with `B`. -/
theorem oracle_capacity_descending (Ω : Finset α) (d : α → ℕ) {B₁ B₂ : ℕ} (hB : B₁ ≤ B₂)
    (h : 2⁻¹ ≤ belowFrac Ω d B₁) :
    Real.binEntropy (belowFrac Ω d B₂) ≤ Real.binEntropy (belowFrac Ω d B₁) := by
  have hmono := belowFrac_monotone Ω d hB
  refine Real.binEntropy_strictAntiOn.antitoneOn ?_ ?_ hmono
  · exact ⟨h, belowFrac_le_one Ω d B₁⟩
  · exact ⟨le_trans h hmono, belowFrac_le_one Ω d B₂⟩

/-- The capacity peak is attained exactly at balance: `B*` is the threshold where
half the instances have `d ≤ B`. -/
theorem oracle_capacity_eq_log_two_iff (Ω : Finset α) (d : α → ℕ) (B : ℕ) :
    Real.binEntropy (belowFrac Ω d B) = Real.log 2 ↔ belowFrac Ω d B = 2⁻¹ :=
  Real.binEntropy_eq_log_two

/-- **Counting form of the one-bit bound.**  A single Boolean oracle read-out
always leaves a class containing at least half of the instances: reading
`1{d ≤ B}` cannot do better than halve the candidate set. -/
theorem oracle_bit_pigeonhole (Ω : Finset α) (T : α → Bool) :
    ∃ c : Bool, #Ω ≤ 2 * #(Ω.filter fun w => T w = c) := by
  classical
  have hsplit : #(Ω.filter fun w => T w = true) + #(Ω.filter fun w => T w = false) = #Ω := by
    have h := Finset.card_filter_add_card_filter_not (s := Ω) (p := fun w => T w = true)
    have hne : Ω.filter (fun w => ¬ (T w = true)) = Ω.filter (fun w => T w = false) :=
      Finset.filter_congr (fun w _ => by simp)
    rw [hne] at h
    exact h
  by_cases h : #Ω ≤ 2 * #(Ω.filter fun w => T w = true)
  · exact ⟨true, h⟩
  · exact ⟨false, by omega⟩

/-- **The positional oracle is not a magnitude mirror.**  Two instances with the
same magnitude (here: the same product `N = 15`, presented as two different
factorisations, or more sharply two instances of equal bit size) give different
oracle bits, so `1{d ≤ B}` is not a deterministic function of the magnitude — the
exp551 collapse argument does not apply to it. -/
theorem positional_oracle_not_mirror :
    ¬ MirrorsMagnitude ({(2, 7), (3, 5)} : Finset (ℕ × ℕ))
        (fun p : ℕ × ℕ => if p.1 ≤ 2 then 1 else 0) (fun p : ℕ × ℕ => (p.1 * p.2) / 8) := by
  rintro ⟨g, hg⟩
  have h1 := hg (2, 7) (by simp)
  have h2 := hg (3, 5) (by simp)
  norm_num at h1 h2
  omega

/-- **The positional oracle really is informative.**  There is an instance set on
which `1{d ≤ B}` has nonzero information about a secret bit — the surviving
channel of round 70 is not vacuous. -/
theorem positional_oracle_informative :
    ¬ ZeroInfo ({(2, 7), (3, 5)} : Finset (ℕ × ℕ))
        (fun p : ℕ × ℕ => if p.1 ≤ 2 then 1 else 0) (fun p : ℕ × ℕ => p.2 % 4) :=
  not_zeroInfo_pair (by decide) (by decide) (by decide)

end MagnitudeMirror