import Mathlib

/-!
# External information is priced linearly: the `t`-bit guessing bound (paper 138)

The barrier map's third row claims that external hints buy work **linearly in
bits**: a hint carrying `t` bits can never buy more than a factor `2^t`.  This
file proves that claim for *every* guessing strategy, with no model
assumptions beyond a uniformly distributed target.

Setting.  The target is uniform on a finite set `α` of size `M`.  A hint is any
map `H : α → β`.  A strategy, having seen the hint value `h`, tests candidates
in some order; `g x ≥ 1` is the position at which candidate `x` is tested when
it is the target.  The only constraint is that two candidates with the same
hint value are tested at different positions (`FibreInjective`).

* `two_mul_sum_ge_of_pos` — `n` distinct positive integers sum to at least
  `n(n+1)/2`.
* `fibre_sum_bound` — hence each hint fibre of size `n_h` costs at least
  `n_h(n_h+1)/2` guesses in total.
* `guessing_bound` — **main inequality**: `|β| · 2 Σ g ≥ M² + |β| M`, i.e. the
  expected number of guesses is at least `(M/|β| + 1)/2` (Cauchy–Schwarz over
  the fibres).
* `speedup_le_card` — the speedup over the hint-free optimum `(M+1)/2` is at
  most `|β|`, so `speedup_le_two_pow`: a `t`-bit hint (`|β| ≤ 2^t`) buys at most
  `2^t`.  Work bits are additive: no capacity synergy.
* `guessing_bound_attained` — the bound is attained by a perfect balanced hint
  with in-fibre ranking, so the inequality is sharp.
-/

namespace Catalog.Novelty.ExternalHintGuessing

open Finset BigOperators

/-- `n` distinct positive integers have sum at least `n(n+1)/2`. -/
theorem two_mul_sum_ge_of_pos (s : Finset ℕ) (hs : ∀ x ∈ s, 1 ≤ x) :
    s.card * (s.card + 1) ≤ 2 * ∑ x ∈ s, x := by
  induction s using Finset.induction_on_max with
  | h0 => simp
  | step a s hlt ih =>
    have ha : a ∉ s := fun h => lt_irrefl a (hlt a h)
    have hsub : s ⊆ Finset.Ico 1 a := by
      intro x hx
      rw [Finset.mem_Ico]
      exact ⟨hs x (Finset.mem_insert_of_mem hx), hlt x hx⟩
    have hcard : s.card ≤ a - 1 := by
      simpa using Finset.card_le_card hsub
    have ha1 : 1 ≤ a := hs a (Finset.mem_insert_self a s)
    have ih' := ih fun x hx => hs x (Finset.mem_insert_of_mem hx)
    rw [Finset.card_insert_of_notMem ha, Finset.sum_insert ha]
    have : s.card + 1 ≤ a := by omega
    nlinarith

/-- A guessing strategy that has seen the hint never tests two candidates with
the same hint value at the same position. -/
def FibreInjective {α β : Type*} (H : α → β) (g : α → ℕ) : Prop :=
  ∀ x y, H x = H y → g x = g y → x = y

variable {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]

omit [Fintype β] in
/-- Each hint fibre of size `n` costs at least `n(n+1)/2` guesses in total. -/
theorem fibre_sum_bound (H : α → β) (g : α → ℕ) (hg : ∀ x, 1 ≤ g x)
    (hinj : FibreInjective H g) (b : β) :
    (univ.filter (fun x => H x = b)).card * ((univ.filter (fun x => H x = b)).card + 1)
      ≤ 2 * ∑ x ∈ univ.filter (fun x => H x = b), g x := by
  set F := univ.filter (fun x => H x = b)
  have hinjOn : Set.InjOn g F := by
    intro x hx y hy hxy
    have hx' := (Finset.mem_filter.1 hx).2
    have hy' := (Finset.mem_filter.1 hy).2
    exact hinj x y (hx'.trans hy'.symm) hxy
  have hc : (F.image g).card = F.card := Finset.card_image_of_injOn hinjOn
  have hsum : ∑ x ∈ F, g x = ∑ n ∈ F.image g, n := (Finset.sum_image (f := fun n => n) hinjOn).symm
  have := two_mul_sum_ge_of_pos (F.image g) (by
    intro n hn
    obtain ⟨x, -, rfl⟩ := Finset.mem_image.1 hn
    exact hg x)
  rw [hc] at this; rw [hsum]; exact this

/-- **The guessing bound.**  Whatever the strategy,
`|β| · (2 Σ_x g x) ≥ M² + |β| · M`; equivalently the expected number of
guesses is at least `(M/|β| + 1)/2`. -/
theorem guessing_bound (H : α → β) (g : α → ℕ) (hg : ∀ x, 1 ≤ g x)
    (hinj : FibreInjective H g) :
    Fintype.card α ^ 2 + Fintype.card β * Fintype.card α
      ≤ Fintype.card β * (2 * ∑ x, g x) := by
  set n : β → ℕ := fun b => (univ.filter (fun x => H x = b)).card
  have hM : ∑ b, n b = Fintype.card α := by
    simp only [n]
    rw [← Finset.card_univ (α := α)]
    exact (Finset.card_eq_sum_card_fiberwise (fun x _ => Finset.mem_univ (H x))).symm
  have hsplit : ∑ x, g x = ∑ b, ∑ x ∈ univ.filter (fun x => H x = b), g x :=
    (Finset.sum_fiberwise univ H g).symm
  have hfib : ∑ b, n b * (n b + 1) ≤ 2 * ∑ x, g x := by
    rw [hsplit, Finset.mul_sum]
    exact Finset.sum_le_sum fun b _ => fibre_sum_bound H g hg hinj b
  have hcs : (∑ b, n b) ^ 2 ≤ Fintype.card β * ∑ b, n b ^ 2 := by
    have := sq_sum_le_card_mul_sum_sq (s := (univ : Finset β)) (f := n)
    simpa using this
  have hexp : ∑ b, n b * (n b + 1) = ∑ b, n b ^ 2 + ∑ b, n b := by
    rw [← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun b _ => by ring
  rw [hM] at hcs
  rw [hexp, hM] at hfib
  calc Fintype.card α ^ 2 + Fintype.card β * Fintype.card α
      ≤ Fintype.card β * ∑ b, n b ^ 2 + Fintype.card β * Fintype.card α := by omega
    _ = Fintype.card β * (∑ b, n b ^ 2 + Fintype.card α) := by ring
    _ ≤ Fintype.card β * (2 * ∑ x, g x) := Nat.mul_le_mul_left _ hfib

/-- Expected number of guesses under a uniform target. -/
noncomputable def expectedGuesses (g : α → ℕ) : ℝ :=
  (∑ x, (g x : ℝ)) / Fintype.card α

/-- **Speedup is at most the number of hint values.**  Relative to the
hint-free optimum `(M+1)/2`, any hinted strategy is at most `|β|` times faster. -/
theorem speedup_le_card [Nonempty α] (H : α → β) (g : α → ℕ) (hg : ∀ x, 1 ≤ g x)
    (hinj : FibreInjective H g) :
    ((Fintype.card α + 1) / 2 : ℝ) / expectedGuesses g ≤ Fintype.card β := by
  have hb := guessing_bound H g hg hinj
  have hM : (0 : ℝ) < Fintype.card α := by exact_mod_cast Fintype.card_pos
  have hBpos : 0 < Fintype.card β := by
    by_contra h
    push_neg at h
    have h0 : Fintype.card β = 0 := by omega
    rw [h0] at hb
    have : 0 < Fintype.card α ^ 2 := by positivity
    omega
  have hB : (0 : ℝ) < Fintype.card β := by exact_mod_cast hBpos
  have hbR : (Fintype.card α : ℝ) ^ 2 + Fintype.card β * Fintype.card α
      ≤ Fintype.card β * (2 * ∑ x, (g x : ℝ)) := by exact_mod_cast hb
  have hS : (0 : ℝ) < ∑ x, (g x : ℝ) := by
    have : (Fintype.card α : ℝ) ≤ ∑ x, (g x : ℝ) := by
      have : ∑ _x : α, (1 : ℝ) ≤ ∑ x, (g x : ℝ) :=
        Finset.sum_le_sum fun x _ => by exact_mod_cast hg x
      simpa using this
    linarith
  unfold expectedGuesses
  rw [div_div_eq_mul_div, div_le_iff₀ hS]
  have hB1 : (1 : ℝ) ≤ Fintype.card β := by exact_mod_cast hBpos
  nlinarith

/-- **External information is priced linearly in bits**: a hint with at most
`2^t` values buys at most a factor `2^t`. -/
theorem speedup_le_two_pow [Nonempty α] (t : ℕ) (hβ : Fintype.card β ≤ 2 ^ t)
    (H : α → β) (g : α → ℕ) (hg : ∀ x, 1 ≤ g x) (hinj : FibreInjective H g) :
    ((Fintype.card α + 1) / 2 : ℝ) / expectedGuesses g ≤ 2 ^ t := by
  refine (speedup_le_card H g hg hinj).trans ?_
  exact_mod_cast hβ

/-- **No synergy.**  Two independent hints with `t₁` and `t₂` bits, used
jointly, buy at most `2^(t₁+t₂) = 2^t₁ · 2^t₂`. -/
theorem joint_hint_no_synergy {β₁ β₂ : Type*} [Fintype β₁] [Fintype β₂]
    [DecidableEq β₁] [DecidableEq β₂] [Nonempty α] (t₁ t₂ : ℕ)
    (h₁ : Fintype.card β₁ ≤ 2 ^ t₁) (h₂ : Fintype.card β₂ ≤ 2 ^ t₂)
    (H₁ : α → β₁) (H₂ : α → β₂) (g : α → ℕ) (hg : ∀ x, 1 ≤ g x)
    (hinj : FibreInjective (fun x => (H₁ x, H₂ x)) g) :
    ((Fintype.card α + 1) / 2 : ℝ) / expectedGuesses g ≤ 2 ^ t₁ * 2 ^ t₂ := by
  have := speedup_le_two_pow (β := β₁ × β₂) (t₁ + t₂)
    (by rw [Fintype.card_prod, pow_add]; exact Nat.mul_le_mul h₁ h₂) _ g hg hinj
  rwa [pow_add] at this

/-- **Sharpness.**  On `Fin B × Fin m` with the perfect hint `H = Prod.fst` and
the in-fibre ranking `g (b, i) = i + 1`, the guessing bound is an equality:
`B · 2 Σ g = (Bm)² + B · (Bm)`. -/
theorem guessing_bound_attained (B m : ℕ) :
    Fintype.card (Fin B × Fin m) ^ 2 + Fintype.card (Fin B) * Fintype.card (Fin B × Fin m)
      = Fintype.card (Fin B) * (2 * ∑ x : Fin B × Fin m, ((x.2 : ℕ) + 1)) := by
  simp only [Fintype.card_prod, Fintype.card_fin]
  rw [Fintype.sum_prod_type]
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, smul_eq_mul]
  rw [Fin.sum_univ_eq_sum_range (fun i => i + 1), Finset.sum_add_distrib,
    Finset.sum_const, Finset.card_range, smul_eq_mul, mul_one]
  have h := Finset.sum_range_id_mul_two m
  rcases m with _ | m
  · simp
  · simp only [Nat.add_sub_cancel] at h
    zify at h ⊢
    linear_combination (-(B : ℤ) ^ 2) * h

theorem guessing_bound_attained_fibreInjective (B m : ℕ) :
    FibreInjective (Prod.fst : Fin B × Fin m → Fin B) (fun x => (x.2 : ℕ) + 1) := by
  rintro ⟨b, i⟩ ⟨b', i'⟩ hb hi
  simp only at hb hi
  subst hb
  have : i = i' := Fin.ext (by omega)
  rw [this]

/-- **Isolation cost.**  Isolating the wanted factor among `M` candidates with
`q` yes/no oracle queries (the query answers must separate all candidates)
requires `M ≤ 2^q`, i.e. at least `⌈log₂ M⌉` queries.  With `M = π(√N)`
candidate primes this is the `log₂ π(√N)` isolation price of breaking the
which-factor ceiling. -/
theorem isolation_queries_lower {γ : Type*} [Fintype γ] (q : ℕ) (Q : γ → Fin q → Bool)
    (hQ : Function.Injective Q) : Fintype.card γ ≤ 2 ^ q ∧ Nat.clog 2 (Fintype.card γ) ≤ q := by
  have h : Fintype.card γ ≤ 2 ^ q := by
    simpa [Fintype.card_fun, Fintype.card_bool, Fintype.card_fin] using
      Fintype.card_le_of_injective Q hQ
  exact ⟨h, Nat.clog_le_of_le_pow h⟩

/-- … and `⌈log₂ M⌉` queries suffice (binary encoding of the candidate index). -/
theorem isolation_queries_upper (M : ℕ) :
    ∃ Q : Fin M → Fin (Nat.clog 2 M) → Bool, Function.Injective Q := by
  have hM : M ≤ 2 ^ Nat.clog 2 M := Nat.le_pow_clog (by norm_num) M
  have hcard : Fintype.card (Fin M) ≤ Fintype.card (Fin (Nat.clog 2 M) → Bool) := by
    simpa [Fintype.card_fun, Fintype.card_bool, Fintype.card_fin] using hM
  obtain ⟨f⟩ := Function.Embedding.nonempty_of_card_le hcard
  exact ⟨f, f.injective⟩

end Catalog.Novelty.ExternalHintGuessing