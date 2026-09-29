/-
# MASTER-TABLE (paper 119) — fibre-shape evaluation of the counting entropy

Two general evaluation principles for the catalog's counting Shannon entropy
`uEnt` (from `Shared.CyclicTypeChannel`), which between them compute every entry
of the degree-`3…6` master table without any case-by-case enumeration:

* `uEnt_uniform_fibres` — if every fibre of the read-out has the same size `c`,
  then `H = log₂ |s| - log₂ c` (the read-out is uniform on `|s| / c` values);
* `uEnt_pinned` — if the read-out isolates a single point `a₀` and is constant on
  the rest, then `H = pinEnt |s|`, the binary entropy of the split `{1, |s| - 1}`:
  `pinEnt N = log₂ N - ((N - 1)/N) log₂ (N - 1)`.

`pinEnt` is the *pinning entropy*: it is the root-count channel of every cyclic
degree-`n` field and the rotation fibre of every dihedral degree-`n` field.
-/
import Shared.CyclicTypeChannelProduct

namespace MasterTable

open CyclicTypeChannel Finset

/-- The **pinning entropy** `h(1/N)`: the Shannon entropy (bits) of a variable that
singles out one of `N` equally likely points,
`pinEnt N = log₂ N - ((N - 1)/N) · log₂ (N - 1)`. -/
noncomputable def pinEnt (N : ℕ) : ℝ :=
  Real.logb 2 N - ((N : ℝ) - 1) / N * Real.logb 2 ((N : ℝ) - 1)

lemma pinEnt_one : pinEnt 1 = 0 := by simp [pinEnt]

lemma pinEnt_two : pinEnt 2 = 1 := by
  norm_num [pinEnt]

section General

variable {α β : Type*} [DecidableEq β]

/-- **Uniform fibres.** If every fibre of `g` on `s` has exactly `c` elements, then
`H(g) = log₂ |s| - log₂ c`. -/
theorem uEnt_uniform_fibres {s : Finset α} {g : α → β} {c : ℕ} (hs : s.Nonempty)
    (hc : ∀ a ∈ s, #{x ∈ s | g x = g a} = c) :
    uEnt s g = Real.logb 2 s.card - Real.logb 2 c := by
  have hN : (0 : ℝ) < s.card := by exact_mod_cast hs.card_pos
  rw [uEnt, Finset.sum_congr rfl (fun a ha => by rw [hc a ha]), sum_const, nsmul_eq_mul,
    mul_div_cancel_left₀ _ hN.ne']

/-- A read-out that is constant on `s` carries no information. -/
theorem uEnt_const_on {s : Finset α} {g : α → β} (hg : ∀ x ∈ s, ∀ y ∈ s, g x = g y) :
    uEnt s g = 0 := by
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [uEnt]
  rw [uEnt_uniform_fibres (c := s.card) hs fun a ha => by
    rw [filter_true_of_mem fun x hx => hg x hx a ha]]
  ring

/-- **Pinned read-out.** If `g` separates the point `a₀ ∈ s` from everything else
and is constant on `s \ {a₀}`, then `H(g) = pinEnt |s|`. -/
theorem uEnt_pinned [DecidableEq α] {s : Finset α} {g : α → β} {a₀ : α} (h₀ : a₀ ∈ s)
    (hpin : ∀ x ∈ s, g x = g a₀ → x = a₀)
    (hrest : ∀ x ∈ s, ∀ y ∈ s, x ≠ a₀ → y ≠ a₀ → g x = g y) :
    uEnt s g = pinEnt s.card := by
  have hfib0 : {x ∈ s | g x = g a₀} = {a₀} := by
    ext x
    simp only [mem_filter, mem_singleton]
    exact ⟨fun hx => hpin x hx.1 hx.2, fun hx => by subst hx; exact ⟨h₀, rfl⟩⟩
  have hfib : ∀ a ∈ s.erase a₀, {x ∈ s | g x = g a} = s.erase a₀ := by
    intro a ha
    obtain ⟨hane, has⟩ := mem_erase.1 ha
    ext x
    simp only [mem_filter, mem_erase]
    constructor
    · rintro ⟨hx, hgx⟩
      refine ⟨fun hxa => hane ?_, hx⟩
      subst hxa
      exact hpin a has hgx.symm
    · rintro ⟨hxne, hx⟩
      exact ⟨hx, hrest x hx a has hxne hane⟩
  have hsum : ∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ)
      = ((s.card : ℝ) - 1) * Real.logb 2 ((s.card : ℝ) - 1) := by
    rw [← add_sum_erase s _ h₀, hfib0, card_singleton, Nat.cast_one, Real.logb_one, zero_add,
      Finset.sum_congr rfl (fun a ha => by rw [hfib a ha]), sum_const, nsmul_eq_mul,
      card_erase_of_mem h₀, Nat.cast_sub (card_pos.2 ⟨a₀, h₀⟩), Nat.cast_one]
  rw [uEnt, hsum, pinEnt]
  ring

end General

end MasterTable