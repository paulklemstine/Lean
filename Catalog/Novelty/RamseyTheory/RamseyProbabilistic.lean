import Mathlib

/-!
# The Erdős probabilistic lower bound for diagonal Ramsey numbers

This file formalizes the classical *first-moment* (probabilistic method) proof of a
lower bound for diagonal Ramsey numbers, following Erdős (1947), but phrased entirely
through **finite cardinality counting** — no measure theory is required.

## Model

A red/blue colouring of the edges of the complete graph `K_n` is a function
`c : Sym2 (Fin n) → Bool` (the diagonal loops of `Sym2` are colour coordinates that
are simply never inspected). For a set of vertices `S`, its *internal edges* are the
unordered pairs of distinct vertices of `S`; a colouring is *monochromatic* on `S`
when `c` is constant on those internal edges.

## Main results

* `card_const_on_le` : an abstract counting bound — the number of Boolean functions
  on a finite type that are constant on a nonempty finset `T` is at most
  `2 ^ (card α - card T + 1)`.
* `exists_avoiding` : the abstract first-moment principle — if a finite family of
  "bad" subsets of a finite type has total size smaller than the whole type, then a
  point avoiding every bad set exists.
* `ramsey_lower_bound` : if `2 * n.choose k < 2 ^ (k.choose 2)` (and `2 ≤ k ≤ n`),
  then there is a 2-colouring of `K_n` with **no** monochromatic `K_k`.
* `no_mono_K4_in_K6` : a concrete instance — `K_6` has a 2-colouring with no
  monochromatic `K_4` (so the diagonal Ramsey number `R(4,4) > 6`).

The criterion `2 * n.choose k < 2 ^ (k.choose 2)` is exactly the Erdős inequality
`\binom{n}{k} 2^{1 - \binom{k}{2}} < 1` cleared of denominators, which yields the
classical exponential lower bound `R(k,k) > 2^{k/2}`.
-/

open Finset

namespace RamseyProbabilistic

/-! ## Abstract counting: functions constant on a subset -/

/-- The number of Boolean functions on a finite type `α` that are constant on a
nonempty finset `T` is at most `2 ^ (card α - card T + 1)`.

Intuition: such a function is determined by its (free) values off `T` together with a
single Boolean value on `T`. Restricting to the complement of `T` is at most
two-to-one on the set of `T`-constant functions. -/
lemma card_const_on_le {α : Type*} [Fintype α] [DecidableEq α]
    (T : Finset α) (hT : T.Nonempty) :
    (Finset.univ.filter (fun f : α → Bool => ∀ x ∈ T, ∀ y ∈ T, f x = f y)).card
      ≤ 2 ^ (Fintype.card α - T.card + 1) := by
  classical
  obtain ⟨x0, hx0⟩ := hT
  set s := Finset.univ.filter (fun f : α → Bool => ∀ x ∈ T, ∀ y ∈ T, f x = f y) with hs
  set φ : (α → Bool) → ({x // x ∈ (Tᶜ : Finset α)} → Bool) := fun f x => f x.1 with hφ
  have hfib : ∀ b ∈ s.image φ, (s.filter (fun a => φ a = b)).card ≤ 2 := by
    intro b _
    have hle : (s.filter (fun a => φ a = b)).card ≤ (Finset.univ : Finset Bool).card := by
      apply Finset.card_le_card_of_injOn (f := fun g => g x0)
        (t := (Finset.univ : Finset Bool))
      · intro g _; simp
      · intro g hg h hh hgh
        rw [Finset.mem_coe, Finset.mem_filter] at hg hh
        obtain ⟨hgs, hgb⟩ := hg
        obtain ⟨hhs, hhb⟩ := hh
        have hgconst := (Finset.mem_filter.1 hgs).2
        have hhconst := (Finset.mem_filter.1 hhs).2
        have hgh' : g x0 = h x0 := hgh
        funext a
        by_cases ha : a ∈ T
        · rw [hgconst a ha x0 hx0, hgh', hhconst a ha x0 hx0]
        · have hac : a ∈ (Tᶜ : Finset α) := by simp [ha]
          have hh2 : φ g ⟨a, hac⟩ = φ h ⟨a, hac⟩ := by rw [hgb, hhb]
          simpa [hφ] using hh2
    simpa using hle
  have hmain := Finset.card_le_mul_card_image s 2 hfib
  have himg : (s.image φ).card ≤ 2 ^ (Fintype.card α - T.card) := by
    have h1 : (s.image φ).card ≤ Fintype.card ({x // x ∈ (Tᶜ : Finset α)} → Bool) :=
      Finset.card_le_univ _
    rwa [Fintype.card_fun, Fintype.card_bool, Fintype.card_coe, Finset.card_compl] at h1
  calc s.card ≤ 2 * (s.image φ).card := hmain
    _ ≤ 2 * 2 ^ (Fintype.card α - T.card) := Nat.mul_le_mul_left 2 himg
    _ = 2 ^ (Fintype.card α - T.card + 1) := by rw [pow_succ]; ring

/-! ## The abstract first-moment principle -/

/-- First-moment / union-bound existence. If the total size of a finite family of
"bad" subsets `B i` (indexed by `i ∈ I`) of a finite type `Ω` is strictly smaller than
`Ω` itself, then some `ω : Ω` avoids every bad set. -/
lemma exists_avoiding {Ω : Type*} [Fintype Ω] [DecidableEq Ω] {ι : Type*}
    (I : Finset ι) (B : ι → Finset Ω)
    (h : ∑ i ∈ I, (B i).card < Fintype.card Ω) :
    ∃ ω, ∀ i ∈ I, ω ∉ B i := by
  have hcard : (I.biUnion B).card < Fintype.card Ω :=
    lt_of_le_of_lt (Finset.card_biUnion_le) h
  have hne : (I.biUnion B) ≠ Finset.univ := by
    intro he; rw [he, Finset.card_univ] at hcard; exact lt_irrefl _ hcard
  obtain ⟨ω, hω⟩ := Finset.exists_of_ssubset (Finset.ssubset_univ_iff.2 hne)
  exact ⟨ω, fun i hi hmem => hω.2 (Finset.mem_biUnion.2 ⟨i, hi, hmem⟩)⟩

/-! ## Ramsey lower bound -/

/-- The internal edges of a vertex set `S`: the unordered pairs of *distinct*
vertices of `S`. -/
def internalEdges {n : ℕ} (S : Finset (Fin n)) : Finset (Sym2 (Fin n)) :=
  S.offDiag.image Sym2.mk

lemma card_internalEdges {n : ℕ} (S : Finset (Fin n)) :
    (internalEdges S).card = S.card.choose 2 :=
  Sym2.card_image_offDiag S

lemma internalEdges_nonempty {n : ℕ} {S : Finset (Fin n)} (hS : 2 ≤ S.card) :
    (internalEdges S).Nonempty := by
  apply Finset.Nonempty.image
  rw [← Finset.card_pos, Finset.offDiag_card]
  have hlt : S.card < S.card * S.card := by nlinarith [hS]
  omega

/-- **Erdős' probabilistic lower bound for Ramsey numbers.**
If `2 * n.choose k < 2 ^ (k.choose 2)` (with `2 ≤ k ≤ n`), then there is a
2-colouring of the edges of `K_n` such that every `k`-subset of vertices contains two
internal edges of different colours — i.e. there is no monochromatic `K_k`. -/
theorem ramsey_lower_bound (n k : ℕ) (hk : 2 ≤ k) (hkn : k ≤ n)
    (hcrit : 2 * n.choose k < 2 ^ (k.choose 2)) :
    ∃ c : Sym2 (Fin n) → Bool,
      ∀ S ∈ Finset.univ.powersetCard k,
        ∃ e ∈ internalEdges S, ∃ f ∈ internalEdges S, c e ≠ c f := by
  classical
  set M := Fintype.card (Sym2 (Fin n)) with hM
  set I := (Finset.univ : Finset (Fin n)).powersetCard k with hI
  set B : Finset (Fin n) → Finset (Sym2 (Fin n) → Bool) :=
    fun S => Finset.univ.filter
      (fun c => ∀ e ∈ internalEdges S, ∀ f ∈ internalEdges S, c e = c f) with hB
  -- M = (n+1).choose 2, and k.choose 2 ≤ M.
  have hMeq : M = (n + 1).choose 2 := by
    rw [hM, Sym2.card, Fintype.card_fin]
  have hMk : k.choose 2 ≤ M := by
    have h1 : k.choose 2 ≤ n.choose 2 := Nat.choose_le_choose 2 hkn
    have h2 : n.choose 2 ≤ (n + 1).choose 2 := Nat.choose_le_choose 2 (Nat.le_succ n)
    omega
  -- Each bad set is small.
  have hbound : ∀ S ∈ I, (B S).card ≤ 2 ^ (M - k.choose 2 + 1) := by
    intro S hS
    rw [hI, Finset.mem_powersetCard] at hS
    have hSk : S.card = k := hS.2
    have hcard : (internalEdges S).card = k.choose 2 := by
      rw [card_internalEdges, hSk]
    have hne : (internalEdges S).Nonempty := internalEdges_nonempty (by rw [hSk]; exact hk)
    have hcount := card_const_on_le (internalEdges S) hne
    rw [hcard] at hcount
    simpa [hB, hM] using hcount
  -- Sum of bad sets is below the total.
  have hsum : ∑ S ∈ I, (B S).card ≤ I.card * 2 ^ (M - k.choose 2 + 1) := by
    have := Finset.sum_le_card_nsmul I (fun S => (B S).card)
      (2 ^ (M - k.choose 2 + 1)) hbound
    simpa [smul_eq_mul] using this
  have hIcard : I.card = n.choose k := by
    rw [hI, Finset.card_powersetCard, Finset.card_univ, Fintype.card_fin]
  -- The arithmetic first-moment inequality.
  have harith : I.card * 2 ^ (M - k.choose 2 + 1) < 2 ^ M := by
    rw [hIcard, pow_succ]
    have hXpos : 0 < 2 ^ (M - k.choose 2) := pow_pos (by norm_num) _
    calc n.choose k * (2 ^ (M - k.choose 2) * 2)
          = (2 * n.choose k) * 2 ^ (M - k.choose 2) := by ring
      _ < 2 ^ (k.choose 2) * 2 ^ (M - k.choose 2) :=
            mul_lt_mul_of_pos_right hcrit hXpos
      _ = 2 ^ M := by rw [← pow_add]; congr 1; omega
  -- Assemble via the first-moment principle.
  have hlt : ∑ S ∈ I, (B S).card < Fintype.card (Sym2 (Fin n) → Bool) := by
    have hΩ : Fintype.card (Sym2 (Fin n) → Bool) = 2 ^ M := by
      rw [Fintype.card_fun, Fintype.card_bool, hM]
    rw [hΩ]
    exact lt_of_le_of_lt hsum harith
  obtain ⟨c, hc⟩ := exists_avoiding I B hlt
  refine ⟨c, ?_⟩
  intro S hS
  have hcS := hc S hS
  rw [hB] at hcS
  simp only [Finset.mem_filter, Finset.mem_univ, true_and, not_forall, exists_prop] at hcS
  obtain ⟨e, he, f, hf, hef⟩ := hcS
  exact ⟨e, he, f, hf, hef⟩

/-! ## The uniform exponential bound `R(k,k) > 2^{k/2}`

The finite criterion `2 * n.choose k < 2 ^ (k.choose 2)` is upgraded to the classical
asymptotic Ramsey lower bound. Working entirely over `ℕ`, the clean sufficient
condition is `n ^ 2 ≤ 2 ^ k` (i.e. `n ≤ 2 ^ (k/2)`): for such `n` the method already
produces a good colouring. Since the largest `n` with `n ^ 2 ≤ 2 ^ k` is `⌊2^{k/2}⌋`,
this yields `R(k,k) > 2^{k/2}` for every `k ≥ 3`. -/

/-- Arithmetic engine: `2 ^ (k+2) < (k!)^2` for `k ≥ 3` (proved by induction). -/
theorem two_pow_lt_factorial_sq (k : ℕ) (hk : 3 ≤ k) :
    2 ^ (k + 2) < (Nat.factorial k) ^ 2 := by
  induction k with
  | zero => omega
  | succ m ih =>
    rcases Nat.lt_or_ge m 3 with hm | hm
    · interval_cases m
      · omega
      · omega
      · decide
    · have := ih hm
      have hfac : Nat.factorial (m + 1) = (m + 1) * Nat.factorial m := rfl
      have h1 : 2 ^ (m + 3) = 2 * 2 ^ (m + 2) := by ring
      rw [hfac]
      have h2 : ((m + 1) * Nat.factorial m) ^ 2
          = (m + 1) ^ 2 * (Nat.factorial m) ^ 2 := by ring
      rw [h2, h1]
      have hm1 : 2 ≤ (m + 1) ^ 2 := by nlinarith
      calc 2 * 2 ^ (m + 2) < 2 * (Nat.factorial m) ^ 2 := by omega
        _ ≤ (m + 1) ^ 2 * (Nat.factorial m) ^ 2 := by nlinarith

/-- The Erdős first-moment criterion holds whenever `n ^ 2 ≤ 2 ^ k` and `k ≥ 3`.
This is the denominator-free form of `binom(n,k) · 2^{1-binom(k,2)} < 1` for the
exponential regime `n ≤ 2^{k/2}`. The proof compares squares: using
`k! · C(n,k) ≤ n^k` and `n^2 ≤ 2^k` one gets `(2·C(n,k))² · (k!)² ≤ 2^{k²+2}`, and
`2^{k+2} < (k!)²` (from `two_pow_lt_factorial_sq`) closes the gap against
`(2^{C(k,2)})² = 2^{k(k-1)}`. -/
theorem choose_sq_bound (n k : ℕ) (hk : 3 ≤ k) (hsq : n ^ 2 ≤ 2 ^ k) :
    2 * n.choose k < 2 ^ (k.choose 2) := by
  set C := n.choose k with hC
  set F := Nat.factorial k with hF
  have hFpos : 0 < F := Nat.factorial_pos k
  have he2 : 2 * k.choose 2 = k * (k - 1) := by
    rw [Nat.choose_two_right]
    rcases Nat.even_or_odd k with h | h
    · obtain ⟨m, rfl⟩ := h; ring_nf; omega
    · obtain ⟨m, rfl⟩ := h; ring_nf; omega
  set e2 := k * (k - 1) with he2def
  have hkey : F * C ≤ n ^ k := by
    calc F * C = n.descFactorial k := by
          rw [hF, hC, Nat.descFactorial_eq_factorial_mul_choose]
      _ ≤ n ^ k := Nat.descFactorial_le_pow n k
  have hFC2 : (F * C) ^ 2 ≤ 2 ^ (k * k) := by
    calc (F * C) ^ 2 ≤ (n ^ k) ^ 2 := Nat.pow_le_pow_left hkey 2
      _ = (n ^ 2) ^ k := by rw [← pow_mul, ← pow_mul]; ring_nf
      _ ≤ (2 ^ k) ^ k := Nat.pow_le_pow_left hsq k
      _ = 2 ^ (k * k) := by rw [← pow_mul]
  have hkk : k * k = e2 + k := by
    rw [he2def, ← Nat.mul_succ]; congr 1; omega
  have hfac := two_pow_lt_factorial_sq k hk
  have hmain : 4 * C ^ 2 * F ^ 2 < 2 ^ e2 * F ^ 2 := by
    have hL : 4 * C ^ 2 * F ^ 2 = 4 * (F * C) ^ 2 := by ring
    have hstep1 : 4 * (F * C) ^ 2 ≤ 4 * 2 ^ (k * k) := by nlinarith [hFC2]
    have h4 : 4 * 2 ^ (k * k) = 2 ^ (k * k + 2) := by rw [pow_add]; ring
    have hsplit : 2 ^ (k * k + 2) = 2 ^ e2 * 2 ^ (k + 2) := by
      rw [← pow_add]; congr 1; omega
    have hfinal : 2 ^ e2 * 2 ^ (k + 2) < 2 ^ e2 * F ^ 2 :=
      (Nat.mul_lt_mul_left (by positivity)).mpr hfac
    calc 4 * C ^ 2 * F ^ 2 = 4 * (F * C) ^ 2 := hL
      _ ≤ 4 * 2 ^ (k * k) := hstep1
      _ = 2 ^ (k * k + 2) := h4
      _ = 2 ^ e2 * 2 ^ (k + 2) := hsplit
      _ < 2 ^ e2 * F ^ 2 := hfinal
  have hcancel : 4 * C ^ 2 < 2 ^ e2 := Nat.lt_of_mul_lt_mul_right hmain
  have hsq2 : (2 * C) ^ 2 < (2 ^ (k.choose 2)) ^ 2 := by
    have h5 : (2 * C) ^ 2 = 4 * C ^ 2 := by ring
    rw [h5]
    have h6 : (2 ^ (k.choose 2)) ^ 2 = 2 ^ e2 := by
      rw [← pow_mul, Nat.mul_comm, he2]
    rw [h6]; exact hcancel
  exact lt_of_pow_lt_pow_left' 2 hsq2

/-- **Exponential Ramsey lower bound.** For `k ≥ 3` and any `n` with `k ≤ n` and
`n ^ 2 ≤ 2 ^ k` (i.e. `n ≤ 2^{k/2}`), the complete graph `K_n` admits a 2-colouring
with no monochromatic `K_k`. Taking `n = ⌊2^{k/2}⌋` (which satisfies `n^2 ≤ 2^k`, and
`k ≤ n` for `k ≥ 4` since `k^2 ≤ 2^k`) gives the classical bound `R(k,k) > 2^{k/2}`. -/
theorem ramsey_lower_bound_exp (n k : ℕ) (hk : 3 ≤ k) (hkn : k ≤ n)
    (hsq : n ^ 2 ≤ 2 ^ k) :
    ∃ c : Sym2 (Fin n) → Bool,
      ∀ S ∈ Finset.univ.powersetCard k,
        ∃ e ∈ internalEdges S, ∃ f ∈ internalEdges S, c e ≠ c f :=
  ramsey_lower_bound n k (by omega) hkn (choose_sq_bound n k hk hsq)

/-- Concrete instance: `K_6` admits a 2-colouring with no monochromatic `K_4`.
Equivalently, the diagonal Ramsey number satisfies `R(4,4) > 6`. -/
theorem no_mono_K4_in_K6 :
    ∃ c : Sym2 (Fin 6) → Bool,
      ∀ S ∈ Finset.univ.powersetCard 4,
        ∃ e ∈ internalEdges S, ∃ f ∈ internalEdges S, c e ≠ c f :=
  ramsey_lower_bound 6 4 (by norm_num) (by norm_num) (by decide)

/-- Concrete instance of the exponential bound: `K_8` admits a 2-colouring with no
monochromatic `K_6` (so `R(6,6) > 8 = 2^{6/2}`), obtained from `ramsey_lower_bound_exp`
with `8 ^ 2 = 64 = 2 ^ 6`. -/
theorem no_mono_K6_in_K8 :
    ∃ c : Sym2 (Fin 8) → Bool,
      ∀ S ∈ Finset.univ.powersetCard 6,
        ∃ e ∈ internalEdges S, ∃ f ∈ internalEdges S, c e ≠ c f :=
  ramsey_lower_bound_exp 8 6 (by norm_num) (by norm_num) (by norm_num)

end RamseyProbabilistic