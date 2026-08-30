import Mathlib
import Bridges.TwoTreeClosure.TreeCore

/-!
# Every magnitude window supports every ascent letter

The blindness theorems of `Bridges.TwoTreeClosure.TreeCore` are *pointwise*: a single
hypotenuse carries two nodes with different letters.  The empirical claim they were
built to explain is *statistical* — "exact null given log-N deciles", i.e. knowing the
dyadic window `[X, 2X)` of the hypotenuse tells you nothing about the letter.  This
file proves the support version of that claim, which is the part accessible to a
finite construction:

* `window_hit` : a general discrete intermediate-value lemma — a strictly increasing
  integer sequence that never more than doubles hits every window `[X, 2X)`;
* `windowA`, `windowB`, `windowC` : three explicit node families,
  `(m+1, m)` (letter `A`), `(4u+1, 2u)` (letter `B`) and `(8u+1, 2u)` (letter `C`),
  whose hypotenuses `2m² + 2m + 1`, `20u² + 8u + 1` and `68u² + 16u + 1` satisfy the
  hypotheses of `window_hit`;
* `all_letters_in_every_window` : **every dyadic window `[X, 2X)` with `X ≥ 661`
  contains a node of each of the three letters.**

So the letter is not merely uncomputable from `N` (that is
`magnitude_probe_letterBlind`); the magnitude *decile* does not even restrict the
letter's support.  Any residual positional information must live in the relative
frequencies, not in the support — which is exactly where the measured null sits.
-/

namespace TwoTreeClosure

/-- **Discrete intermediate value.**  A strictly increasing sequence of naturals whose
successive gaps never double it, beyond an index `M`, meets every window `[X, 2X)`
above the value `f M`. -/
theorem window_hit (f : ℕ → ℕ) (M : ℕ) (hmono : StrictMono f)
    (hgrow : ∀ m, M ≤ m → f (m + 1) < 2 * f m) (X : ℕ) (hX : f M ≤ X) (hX0 : 0 < X) :
    ∃ m, M ≤ m ∧ X ≤ f m ∧ f m < 2 * X := by
  classical
  have hex : ∃ m, X ≤ f m := ⟨X, hmono.le_apply⟩
  have hspec : X ≤ f (Nat.find hex) := Nat.find_spec hex
  have hMfind : M ≤ Nat.find hex := by
    by_contra hc
    push_neg at hc
    have : f (Nat.find hex) < f M := hmono hc
    omega
  refine ⟨Nat.find hex, hMfind, hspec, ?_⟩
  rcases eq_or_lt_of_le hMfind with heq | hlt
  · have : f (Nat.find hex) = f M := by rw [← heq]
    omega
  · obtain ⟨k, hk⟩ : ∃ k, Nat.find hex = k + 1 := ⟨Nat.find hex - 1, by omega⟩
    have hkM : M ≤ k := by omega
    have hkmin : ¬ X ≤ f k := Nat.find_min hex (by omega)
    have hstep := hgrow k hkM
    rw [hk]
    omega

/-! ### The three families -/

/-- The `A`-family: `(m+1, m)` for `m ≥ 1`, with hypotenuse `2m² + 2m + 1`. -/
theorem windowA (m : ℕ) (hm : 2 ≤ m) :
    IsNode (m + 1) m ∧ letterOf (m + 1) m = Letter.A ∧ hyp (m + 1) m = 2 * m ^ 2 + 2 * m + 1 := by
  have hcop : Nat.Coprime (m + 1) m := by simp [Nat.Coprime]
  refine ⟨⟨by omega, by omega, hcop, by omega⟩, letterOf_eq_A (by omega), ?_⟩
  simp only [hyp]
  ring

/-- The `B`-family: `(4u+1, 2u)` for `u ≥ 1`, with hypotenuse `20u² + 8u + 1`. -/
theorem windowB (u : ℕ) (hu : 1 ≤ u) :
    IsNode (4 * u + 1) (2 * u) ∧ letterOf (4 * u + 1) (2 * u) = Letter.B ∧
      hyp (4 * u + 1) (2 * u) = 20 * u ^ 2 + 8 * u + 1 := by
  have hcop : Nat.Coprime (4 * u + 1) (2 * u) := by
    have h1 : Nat.gcd (4 * u + 1) (2 * u) ∣ 4 * u + 1 := Nat.gcd_dvd_left _ _
    have h2 : Nat.gcd (4 * u + 1) (2 * u) ∣ 2 * u := Nat.gcd_dvd_right _ _
    have h3 : Nat.gcd (4 * u + 1) (2 * u) ∣ 4 * u := by
      have := h2.mul_left 2
      simpa [show 2 * (2 * u) = 4 * u from by ring] using this
    have h4 : Nat.gcd (4 * u + 1) (2 * u) ∣ 1 := by
      have := Nat.dvd_sub h1 h3
      simpa using this
    exact Nat.eq_one_of_dvd_one h4
  refine ⟨⟨by omega, by omega, hcop, by omega⟩, letterOf_eq_B (by omega) (by omega), ?_⟩
  simp only [hyp]
  ring

/-- The `C`-family: `(8u+1, 2u)` for `u ≥ 1`, with hypotenuse `68u² + 16u + 1`. -/
theorem windowC (u : ℕ) (hu : 1 ≤ u) :
    IsNode (8 * u + 1) (2 * u) ∧ letterOf (8 * u + 1) (2 * u) = Letter.C ∧
      hyp (8 * u + 1) (2 * u) = 68 * u ^ 2 + 16 * u + 1 := by
  have hcop : Nat.Coprime (8 * u + 1) (2 * u) := by
    have h1 : Nat.gcd (8 * u + 1) (2 * u) ∣ 8 * u + 1 := Nat.gcd_dvd_left _ _
    have h2 : Nat.gcd (8 * u + 1) (2 * u) ∣ 2 * u := Nat.gcd_dvd_right _ _
    have h3 : Nat.gcd (8 * u + 1) (2 * u) ∣ 8 * u := by
      have := h2.mul_left 4
      simpa [show 4 * (2 * u) = 8 * u from by ring] using this
    have h4 : Nat.gcd (8 * u + 1) (2 * u) ∣ 1 := by
      have := Nat.dvd_sub h1 h3
      simpa using this
    exact Nat.eq_one_of_dvd_one h4
  refine ⟨⟨by omega, by omega, hcop, by omega⟩, letterOf_eq_C (by omega), ?_⟩
  simp only [hyp]
  ring

/-! ### Every window carries every letter -/

/-- **All three letters occur in every dyadic magnitude window.**  For every `X ≥ 661`
and every letter `L` there is a Berggren/Price node whose letter is `L` and whose
hypotenuse lies in `[X, 2X)`.  Knowing the log-magnitude decile of `N` therefore does
not even restrict the *support* of the letter distribution. -/
theorem all_letters_in_every_window (X : ℕ) (hX : 661 ≤ X) (l : Letter) :
    ∃ m n : ℕ, IsNode m n ∧ letterOf m n = l ∧ X ≤ hyp m n ∧ hyp m n < 2 * X := by
  cases l
  · -- letter A, family `2m² + 2m + 1` from `M = 3`
    obtain ⟨m, hm3, hlo, hhi⟩ :=
      window_hit (fun m => 2 * m ^ 2 + 2 * m + 1) 3
        (fun a b hab => by simp only; nlinarith)
        (fun m hm => by simp only; nlinarith) X (by norm_num; omega) (by omega)
    obtain ⟨hnode, hletter, hhyp⟩ := windowA m (by omega)
    exact ⟨m + 1, m, hnode, hletter, by rw [hhyp]; exact hlo, by rw [hhyp]; exact hhi⟩
  · -- letter B, family `20u² + 8u + 1` from `M = 3`
    obtain ⟨u, hu3, hlo, hhi⟩ :=
      window_hit (fun u => 20 * u ^ 2 + 8 * u + 1) 3
        (fun a b hab => by simp only; nlinarith)
        (fun u hu => by simp only; nlinarith) X (by norm_num; omega) (by omega)
    obtain ⟨hnode, hletter, hhyp⟩ := windowB u (by omega)
    exact ⟨4 * u + 1, 2 * u, hnode, hletter, by rw [hhyp]; exact hlo, by rw [hhyp]; exact hhi⟩
  · -- letter C, family `68u² + 16u + 1` from `M = 3`
    obtain ⟨u, hu3, hlo, hhi⟩ :=
      window_hit (fun u => 68 * u ^ 2 + 16 * u + 1) 3
        (fun a b hab => by simp only; nlinarith)
        (fun u hu => by simp only; nlinarith) X (by norm_num; omega) (by omega)
    obtain ⟨hnode, hletter, hhyp⟩ := windowC u (by omega)
    exact ⟨8 * u + 1, 2 * u, hnode, hletter, by rw [hhyp]; exact hlo, by rw [hhyp]; exact hhi⟩

/-- **Support-level null.**  No predicate of the magnitude window can exclude a letter:
for every window above `661` the three letters all occur, so a "decile sensor" — a
function of `⌊log₂ N⌋` — is exactly as blind as the residue dials of `TreeCore`. -/
theorem decile_sensor_letterBlind (D : ℕ → Letter) :
    ¬ (∀ m n, IsNode m n → 661 ≤ hyp m n → D (Nat.log 2 (hyp m n)) = letterOf m n) := by
  intro hD
  obtain ⟨m, n, hnode, hletter, hlo, hhi⟩ := all_letters_in_every_window 1024 (by norm_num) Letter.A
  obtain ⟨m', n', hnode', hletter', hlo', hhi'⟩ :=
    all_letters_in_every_window 1024 (by norm_num) Letter.B
  have hlog : Nat.log 2 (hyp m n) = 10 := by
    have h1 : 2 ^ 10 ≤ hyp m n := by omega
    have h2 : hyp m n < 2 ^ 11 := by omega
    exact Nat.log_eq_of_pow_le_of_lt_pow h1 h2
  have hlog' : Nat.log 2 (hyp m' n') = 10 := by
    have h1 : 2 ^ 10 ≤ hyp m' n' := by omega
    have h2 : hyp m' n' < 2 ^ 11 := by omega
    exact Nat.log_eq_of_pow_le_of_lt_pow h1 h2
  have e1 := hD m n hnode (by omega)
  have e2 := hD m' n' hnode' (by omega)
  rw [hlog, hletter] at e1
  rw [hlog', hletter'] at e2
  rw [e1] at e2
  exact absurd e2 (by decide)

end TwoTreeClosure